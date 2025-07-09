//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Description:
// @p
//  
//  
// @e
//
//  
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions 
//
`include "defines.v"
`include "ifu_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_ifu_fetcher (
  ////////// Fetch requests (F0)  /////////////////////////////////////////////
  //
  output reg                     fa0_req,                // Fetch request from FTB
  output reg [`IFU_ADDR_RANGE]   fa0_addr,               // Fetch block addr (4 byte aligned)
  output reg                     fa_offset,              // Fetch block offset
  
  output reg [`FTB_DEPTH_RANGE]  f0_id,                   // Fetch address ID entering IFU pipe
  output reg                     f0_id_valid,             // Valid ID
  
  output reg                     ftb_idle,                // IFU in the process of going idle 

  output reg [`IFU_ADDR_RANGE]   f1_addr0_r,              // Fetch block addr (4 byte aligned)
  output reg                     f1_offset_r,             // Fetch block addr (4 byte aligned)

  ////////// Memory target prediction (I$, ICCM0, ICCM1) /////////////////////////
  //
  output [3:0]        f0_pred_target,         // NVM Hole: 4 CCM Hole: 3 prediction: 2: I$/IFQ, 1: ICCM1, 0: ICCM0
  input  [3:0]        f1_mem_target,
  output reg [3:0]    f1_mem_target_r,

  ////////// PMP interface ////////////////////////////////////////////////
  //
  output [`IFU_ADDR_RANGE]       ifu_pmp_addr0,           // fetch addr0 to PMP: F1

  ////////// PMA interface ////////////////////////////////////////////////
  //
  output [`IFU_ADDR_RANGE]       ifu_pma_addr0,           // fetch addr0 to PMP: F1

  ////////////////// IFU IDs ///////////////////////////////////////////////////
  //
  output [`FTB_DEPTH_RANGE]      ftb_top_id,             // Top of the FTB
  

  ////////// Branch interface interface  ///////////////////////////////////////
  //
  input                          br_req_ifu,
  input [`PC_RANGE]              br_restart_pc,           // BR target
  
  input [`PC_RANGE]              fch_pc_nxt,            // restart fetch block

  ////////// Fetch-Restart Interface /////////////////////////////////////////
  //
  input                          fch_restart,             // EXU requests IFU restart
  input [`PC_RANGE]              fch_target,              //
  input                          fch_stop_r,              // EXU requests IFU halt
  output reg                     ifu_idle_r,              // IFU is idle

  ////////// IFU status /////////////////////////////////////////
  //
  output reg                     ftb_serializing,        // IFU waiting for IC to go idle as a result of a full barrier
  output reg                     ftb_ic_going_idle,      // Inform I-Cache we are going idle
  input                          ic_idle,                // I-Cache status
  input                          iccm_idle,              // ICCM status 
  output reg                     f1_mem_target_mispred_r,
  input                          halt_fsm_in_rst,

  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                    // clock signal
  input                          rst_a                   // reset signal
);

// Local declarations
//

//
reg [`FTB_DEPTH_RANGE]    ftb_valid_r;                    // valid                                       
reg                       ftb_offset_r[`FTB_DEPTH_RANGE]; // fetch block offset of BR target
reg [`IFU_ADDR_RANGE]     ftb_fa0_r[`FTB_DEPTH_RANGE];    // Fetch address0                             

reg [`FTB_DEPTH_RANGE]    ftb_valid_nxt;
reg [`FTB_DEPTH_RANGE]    ftb_fa0_valid_nxt;


// FTB pointers are one-hot encoded (timing)
//

reg [`FTB_DEPTH_RANGE]    ftb_wr_ptr_1h_r;
reg [`FTB_DEPTH_RANGE]    ftb_wr_ptr_1h_nxt;  
reg [`FTB_DEPTH_RANGE]    ftb_rd_ptr_1h_r;  
reg [`FTB_DEPTH_RANGE]    ftb_rd_ptr_1h_nxt;  
reg                       ftb_rd_ptr_cg0;

reg [`FTB_DEPTH_RANGE]    ftb_insert_ptr;  

wire                      ftb_rd_ptr;

// Helpers
//
reg [`FTB_DEPTH_RANGE]    ftb_rd_ptr_1h_p1;

reg                       f1_addr0_cg0;
reg                       f1_offset_nxt;
reg [3:0]      f1_mem_target_nxt;
reg [`IFU_ADDR_RANGE]     f1_addr0_nxt;

// Local variables
//
reg                       fa_seq;  // seq fetch


reg                       ftb_write;
reg                       ftb_write_fast;  // timing optimization
reg                       ftb_read;
//reg                       ftb_read_partial;
reg                       ftb_bypass;

reg                       ftb_write_valid_cg0;

reg                       ifu_idle_nxt;
reg [1:0]                 ifu_idle_state_r;
reg [1:0]                 ifu_idle_state_nxt;


reg                       f0_pred_targt_cg0;
reg [3:0]      f0_pred_target_r;
reg [3:0]      f0_pred_target_nxt;
reg [3:0]      f1_pred_target_r;
reg                       f1_mem_target_misp;
reg                       f1_pred_target_cg0;

wire                      ftb_full;
wire                      ifu_all_idle;

////////////////////////////////////////////////////////////////////////////
//
//
//        F0      |      F1        |         
//                |                |         
//                |                |         
//       FTB      |    Mem acc     |   IQ    
//                | (align, issue) |         
//                |                |         
//                |                |         
//
////////////////////////////////////////////////////////////////////////////

// F0 - F1

// PC select
// Actual FTB
//

/*
The maximum fetch bandwith is 2*4 bytes every  cycle
The instruction memories support unaligned fetch. A given fetch is comprised
of FA0 and FA1, with FA0 pointing to the start of the fetch.

The instruction memories use FA_even and FA_odd to access their even and odd banks,
respectively. 

Note that FA_even corresponds to either FA0 or FA1: 
FA_even = FA0: Start of the fetch is on an even bank (FA0[2] == 1'b0)
FA_even = FA1: Start of the fetch is on an odd bank (FA0[2] == 1'b1)


*/


////////////////////////////////////////////////////////////////////////////////////////////
// Determining next values of FTB entries and ptrs - support for simultaneous reads and writes
//
////////////////////////////////////////////////////////////////////////////////////////////
wire restart;
assign restart = fch_restart ;


////////////////////////////////////////////////////////////////////////////////////////////
// Bypass FTB on empty (or on restart)
//
////////////////////////////////////////////////////////////////////////////////////////////

always @*
begin : ftb_byp_PROC
  // Whenever the cmd_insert_ptr points to an entry that is not valid, it could be we are about to write
  // to that entry. The bypass mechanism ensures we pick-up the entry we are inserting into the FTB and
  // and also inserts it in the IFU pipeline
  //
 
  
  
  // Default values
  //
  fa0_req        = 1'b0; 
  fa0_addr       = f1_addr0_r;  // do not toggle
  fa_offset      = 1'b0;
  fa_seq         = 1'b0;
   
  // The F0 ID is the FTB entry we are writing
  //
  f0_id          = {{1 {1'b0}}, 1'b1}; // ftb_wr_ptr_1h_r;
  f0_id_valid    = 1'b1;
  
  if (restart)
  begin
   // Insert it right away with the ID corresponding to the FTB entry will will write into:
   //
    fa0_req        = (~fch_stop_r);
    fa0_addr       = fch_target[`IFU_ADDR_RANGE];
    fa_offset      = fch_target[1];
   
    // The F0 ID is the FTB entry we are writing
    //
    f0_id          = {{1 {1'b0}}, 1'b1}; // ftb_wr_ptr_1h_r;
    f0_id_valid    = (~fch_stop_r);
  end
  else if ( br_req_ifu )
  begin
    // Bypass FTB or a redirection from BR unit
    //
    fa0_req        = 1'b1; 
    fa0_addr       = br_restart_pc[`IFU_ADDR_RANGE];
    fa_offset      = br_restart_pc[1];
    fa_seq         = (~br_req_ifu);
   
    // The F0 ID is the FTB entry we are writing
    //
    f0_id          = {{1 {1'b0}}, 1'b1}; // ftb_wr_ptr_1h_r;
    f0_id_valid    = 1'b1;
  end
  else
  begin
   // Insert it right away with the ID corresponding to the FTB entry will will write into:
   //
    fa0_req        = (~fch_stop_r) & (~halt_fsm_in_rst);
    fa0_addr       = fch_pc_nxt[`IFU_ADDR_RANGE];
    fa_offset      = fch_pc_nxt[1];
   
    // The F0 ID is the FTB entry we are writing
    //
    f0_id          = {{1 {1'b0}}, 1'b1}; // ftb_wr_ptr_1h_r;
    f0_id_valid    = (~fch_stop_r) & (~halt_fsm_in_rst);
  end
end



////////////////////////////////////////////////////////////////////////////////////////////
// Memory target prediction
//
// Simple prediction scheme: the memory target for a subsequent fetch is the same as the
// memory target of the current fetch. The memory target prediction is validated or corrected
// in F1
//
////////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : ftb_mem_target_PROC
  // Default value
  //
  f0_pred_targt_cg0  = 1'b0;
  f0_pred_target_nxt = f0_pred_target_r;
  
  f1_pred_target_cg0 = fa0_req;
  
  // Do we have a misprediction?
  //
  f1_mem_target_misp = (f1_pred_target_r != f1_mem_target);
  
  if (f1_mem_target_misp)
  begin
    f0_pred_targt_cg0  = 1'b1;
    f0_pred_target_nxt = f1_mem_target;
  end
end

// Helper
//
assign ifu_all_idle = 1'b1
                    & ic_idle
                    & iccm_idle
                    ;
////////////////////////////////////////////////////////////////////////////////////////////
//
// IFU idle FSM
//
////////////////////////////////////////////////////////////////////////////////////////////

localparam IFU_STATE_DEFAULT      = 2'b00;
localparam IFU_STATE_WAIT_IDLE    = 2'b01;
localparam IFU_STATE_IDLE         = 2'b10;

always @*
begin : ftb_idle_fsm_PROC
  // Default values
  //
  ftb_idle           = ifu_idle_r;
  ftb_serializing    = 1'b0;
  ftb_ic_going_idle  = 1'b0;
  ifu_idle_nxt       = ifu_idle_r;
  ifu_idle_state_nxt = ifu_idle_state_r;
  
  
  case (ifu_idle_state_r)
  IFU_STATE_DEFAULT:
  begin
    
    if (fch_restart & fch_stop_r)
    begin
      // Request for the IFU to go idle
      //
      ifu_idle_state_nxt = IFU_STATE_WAIT_IDLE;
    end
  end
  
  IFU_STATE_WAIT_IDLE:
  begin
    ftb_idle = 1'b1;
    
    // In this state we wait until all I-Cache IBP transactions are completed
    // 
    if (  fch_restart 
        & (~fch_stop_r))
    begin
      // Need to run again
      //
      ifu_idle_state_nxt = IFU_STATE_DEFAULT;
    end
    else
    begin
      // Make sure all outstanding transactions are finished
      //
      if (ifu_all_idle == 1'b1)
      begin
        ifu_idle_nxt       = 1'b1;
        ftb_ic_going_idle  = 1'b1;
        ifu_idle_state_nxt = IFU_STATE_IDLE;
      end
    end
  end
  
  default: // IFU_STATE_IDLE
  begin
    ftb_idle     = 1'b1;
    ifu_idle_nxt = ifu_all_idle;
    
    if (  fch_restart 
        & (~fch_stop_r))
    begin
      // Need to run again
      //
      ifu_idle_nxt       = 1'b0;
      ifu_idle_state_nxt = IFU_STATE_DEFAULT;
    end
  end
  endcase
end
//////////////////////////////////////////////////////////////////////////////////////////
// Register F0 address (power savings for IFU memories)
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : f1_addr_PROC
  // Derive the IFU address to send for MPU-PMP credential checks
  //
  f1_addr0_cg0 = fa0_req; 
  f1_addr0_nxt = fa0_addr;
  f1_offset_nxt = fa_offset;
  f1_mem_target_nxt = f1_mem_target;
end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////


// spyglass disable_block FlopEConst
// SMD: Enable pin is always high/low
// SJ:  In some configurations this enables is always low
always @(posedge clk or posedge rst_a)
begin : f1_addr_regs_PROC
  if (rst_a == 1'b1)
  begin
    f1_addr0_r    <= {`IFU_ADDR_BITS{1'b0}};
    f1_offset_r   <= 1'b0;
    f1_mem_target_r <= 4'h0;
  end
  else
  begin
    if (f1_addr0_cg0 == 1'b1)
    begin
      f1_addr0_r  <= f1_addr0_nxt;
      f1_offset_r <= f1_offset_nxt;
      f1_mem_target_r <= f1_mem_target_nxt;
    end
    
  end
end
// spyglass enable_block FlopEConst

always @(posedge clk or posedge rst_a)
begin : ftb_idle_regs_PROC
  if (rst_a == 1'b1)
  begin
    ifu_idle_state_r <= IFU_STATE_IDLE;
    ifu_idle_r       <= 1'b0;
  end
  else
  begin
    ifu_idle_state_r <= ifu_idle_state_nxt;
    ifu_idle_r       <= ifu_idle_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : f1_pred_target_regs_PROC
  if (rst_a == 1'b1)
  begin
    f0_pred_target_r <= 4'd1; // ICCM0 target
    f1_pred_target_r <= 4'd1; // ICCM0 target
  end
  else
  begin
    if (f1_pred_target_cg0 == 1'b1)
    begin
      f0_pred_target_r <= f0_pred_target_nxt;
    end
    
    if (f1_pred_target_cg0 == 1'b1)
    begin
      f1_pred_target_r <= f0_pred_target_r;
    end
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    f1_mem_target_mispred_r <= 1'b0;
  end
  else
  begin
    f1_mem_target_mispred_r <= f1_mem_target_misp;
  end
end


//////////////////////////////////////////////////////////////////////////////
//                                                                          
// Output assignments                               
//                                                                          
//////////////////////////////////////////////////////////////////////////////

//assign ftb_top_id            = ftb_read ? ftb_rd_ptr_1h_p1 : ftb_rd_ptr_1h_r;
assign ftb_top_id            = {{1 {1'b0}}, 1'b1}; // ftb_rd_ptr_1h_r;
assign f0_pred_target        = f0_pred_target_r;

assign ifu_pmp_addr0         = f1_addr0_r; 

assign ifu_pma_addr0         = f1_addr0_r; 


endmodule // rl_ifu_fetcher

