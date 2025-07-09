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

module rl_ifu_id_ctrl (

  ////////// Fetch restart interface. IFU status //////////////////////////////////////
  //
  input                          fch_restart,               // Restart IFU  
  input                          br_req_ifu,                // BR  Restart IFU  
//  input                          iq_write_partial,          // IQ:only fetch block0 written
  input                          iq_full,                   // IQ full
  input                          ftb_idle,                  // fetcher going idle
  input                          ftb_serializing,           // full barrier

  ////////// Input ID from Fetcher /////////////////////////////////////////////
  //
  input [`FTB_DEPTH_RANGE]       f0_id,                     // Fetch address ID entering IFU pipe
  input                          f0_id_valid,               // Valid ID
  
  input [`FTB_DEPTH_RANGE]       ftb_top_id,                // FTB read pointer (top ID)

  ////////// I-Cache interface /////////////////////////////////////////////
  //
  input [1:0]                    ic_f1_data_in_valid,       // From I-Cache
  output reg [1:0]               ic_f1_data_out_valid,      // Validated with ID
  output reg[1:0]                ic_f1_data_fwd,
  
  
  ////////// ICCM0 interface /////////////////////////////////////////////
  //
  input [1:0]                    iccm0_f1_data_in_valid,    // From I-Cache
  output reg [1:0]               iccm0_f1_data_out_valid,   // Validated with ID
  

  ////////// Combined I$, ICCM qualification //////////////////////////////////
  //
  input [2:0]                    f1_mem_target_r,          // actual mem target
  input                          f1_mem_target_mispred,    // target misprediction 
  output reg [1:0]               f1_id_data_out_valid,     // 
  output reg                     f1_id_on_top,             // F1 ID matches FTB top ID: used in the I-Cache

  ////////// Output IDs //////////////////////////////////////////////////////
  //
  output reg [`FTB_DEPTH_RANGE]  f1_id_r,                   // F1 ID
//  output reg                     f1_id_valid_partial,       // Valid ID
  output reg                     f1_id_invalidate,          // F1 ID was invalidated
  
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                       // clock signal
  input                          rst_a                      // reset signal

);

// Local Declarations
//
reg                     f1_id_valid_r;
reg                     f1_id_valid_nxt;
reg [`FTB_DEPTH_RANGE]  f1_id_nxt;

reg                     id_inv_state_r;
reg                     id_inv_state_nxt;

reg [`FTB_DEPTH_RANGE]  f1_saved_id_r;
reg [`FTB_DEPTH_RANGE]  f1_saved_id_nxt;

wire                    ifu_restart;
wire                    iccm0_f1_id_valid;

wire                    f1_sync_id;

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

wire  ic_f1_id_valid;
assign ic_f1_id_valid    = 1'b1; //ic_f1_data_in_valid[0];
assign iccm0_f1_id_valid = iccm0_f1_data_in_valid[0];

assign ifu_restart       = fch_restart | br_req_ifu;

//////////////////////////////////////////////////////////////////////////////////////////
// Validate memory outputs
//
///////////////////////////////////////////////////////////////////////////////////////////

always @*
begin : ic_id_qual_PROC
  // The memory ouputs going out are only valid if their correspondents ID
  // match with the top of the FTB at F1
  //
  ic_f1_data_out_valid = ic_f1_data_in_valid;
  ic_f1_data_fwd       = 2'b11;
  if (  (ftb_top_id != f1_id_r)
      | (f1_id_valid_r == 1'b0)
      | (f1_mem_target_r[2] != 1'b1) 
      | f1_mem_target_mispred
      | iq_full
      | ftb_idle
      | ftb_serializing
      | ifu_restart
      )
  begin
    ic_f1_data_out_valid = 2'b00;
    ic_f1_data_fwd       = 2'b00;
  end
end

always @*
begin : iccm0_id_qual_PROC
  // The memory ouputs going out are only valid if their correspondents ID
  // match with the top of the FTB at F1
  //
  iccm0_f1_data_out_valid = iccm0_f1_data_in_valid;
  
  if (  (ftb_top_id != f1_id_r)
      | (f1_id_valid_r == 1'b0)
      | (f1_mem_target_r[0] != 1'b1) 
      | f1_mem_target_mispred
      | iq_full
      | ftb_idle
      | ftb_serializing
      | ifu_restart
      )
  begin
    iccm0_f1_data_out_valid = 2'b00;
  end
end



//////////////////////////////////////////////////////////////////////////////////////////
// Invalidating F1 ID
//
///////////////////////////////////////////////////////////////////////////////////////////
wire f1_id_invalid;
wire f1_sync_not_ok;

  // This sinal indicates the F1 ID got invalidated
  //
//assign  f1_id_invalid = iq_write_partial
assign  f1_id_invalid = 1'b0
                      | ((iccm0_f1_data_in_valid[0] == 1'b1) & f1_id_valid_r & (iccm0_f1_data_out_valid[0] == 1'b0))
                      | (f1_mem_target_r[0]                    & f1_id_valid_r & (iccm0_f1_id_valid == 1'b0)) 
                      | ((ic_f1_data_in_valid[0] == 1'b1)    & f1_id_valid_r & (ic_f1_data_out_valid[0] == 1'b0)) 
                      | (f1_mem_target_r[2]                    & f1_id_valid_r & (ic_f1_id_valid == 1'b0)) 
                      ; 

assign f1_sync_id     = f1_id_valid_r & (f1_id_r == f1_saved_id_r);

assign f1_sync_not_ok = iq_full
                      | (f1_mem_target_r[0] & (~iccm0_f1_id_valid))  // ICCM0 hiccup
                      | (f1_mem_target_r[2] & (~ic_f1_id_valid))     // IC hiccup
                      ; 

localparam ID_INV_DEFAULT = 1'b0;
localparam ID_INV_SYNC    = 1'b1;

always @*
begin : id_inv_fsm_PROC
   // Default values
   //
   f1_id_invalidate = 1'b0;
   f1_saved_id_nxt  = f1_saved_id_r;
   id_inv_state_nxt = id_inv_state_r;
   
   case (id_inv_state_r)
   ID_INV_DEFAULT:
   begin
     f1_id_invalidate = f1_id_invalid; 
     
     if (f1_id_invalid) 
     begin
       f1_saved_id_nxt  = f1_id_r;
       id_inv_state_nxt = ID_INV_SYNC;
     end
   end
   
   default: // ID_INV_SYNC
   begin
     f1_id_invalidate = 1'b0;
     
     if (ifu_restart)
     begin
       id_inv_state_nxt  = ID_INV_DEFAULT;
     end
     else if (f1_sync_id)
     begin
       f1_id_invalidate = f1_sync_not_ok;
       f1_saved_id_nxt  = f1_id_r;
       
       if (f1_sync_not_ok == 1'b0)
       begin
         // Stay here in case of a hiccup
         //
         id_inv_state_nxt  = ID_INV_DEFAULT;
       end
     end
   end
   endcase
end


//////////////////////////////////////////////////////////////////////////////////////////
// Determine value for nxt IDs
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : id_nxt_PROC
  
  // Default values
  //
  f1_id_nxt       = f0_id;

  casez ({ifu_restart, f1_id_invalidate})
  2'b1?:
  begin
    f1_id_valid_nxt = f0_id_valid;
  end
  
  2'b01:
  begin
    f1_id_valid_nxt = 1'b0;
  end
  
  default:
  begin
    f1_id_valid_nxt = f0_id_valid;
  end
  endcase
  
  // On any hiccup, the F1 ID is invalidated.
  //
  
//  f1_id_valid_partial = 1'b0;
  
  if ( iq_full
      | f1_mem_target_mispred
      | ftb_idle
      | ftb_serializing
      | ifu_restart)
  begin
//    f1_id_valid_partial = 1'b0;
  end
  else
  begin
                
//    f1_id_valid_partial = iq_write_partial
//`if (`HAS_ICCM0 == 1) // {
//                        | (f1_mem_target_r[0] & (iccm0_f1_data_out_valid == 2'b01))
//`endif // }
//`if (`HAS_ICCM1 == 1) // {
//                        | (f1_mem_target_r[1] & (iccm1_f1_data_out_valid == 2'b01)) 
//`endif // }
//`if (`HAS_ICACHE == 1) // {
//                        | (f1_mem_target_r[2] & (ic_f1_data_out_valid    == 2'b01)) 
//`endif // }
//`if (`HAS_IFQ == 1) // {
//                        | (f1_mem_target_r[2] & (ifq_f1_data_out_valid   == 2'b01)) 
//`endif // }
//                        ;
  end
end

always @*
begin : f1_id_PROC
  
  f1_id_data_out_valid = 2'b00
                        | ({2{f1_mem_target_r[0]}} & iccm0_f1_data_out_valid)
                        | ({2{f1_mem_target_r[2]}} & ic_f1_data_out_valid) 
                        ;
  // F1 ID relation to FTB top id
  //
  f1_id_on_top = (f1_id_r == ftb_top_id);
  
end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : id_regs_PROC
  if (rst_a == 1'b1)
  begin
    f1_id_r       <= {`FTB_DEPTH{1'b0}};         
    f1_id_valid_r <= 1'b0;
  end
  else
  begin
    f1_id_r       <= f1_id_nxt;
    f1_id_valid_r <= f1_id_valid_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : id_inv_regs_PROC
  if (rst_a == 1'b1)
  begin
    id_inv_state_r <= ID_INV_DEFAULT;
    f1_saved_id_r  <= {`FTB_DEPTH{1'b0}};        
  end
  else
  begin
    id_inv_state_r <= id_inv_state_nxt;
    f1_saved_id_r  <= f1_saved_id_nxt;    
  end
end


//////////////////////////////////////////////////////////////////////////////////////////
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////

endmodule // rl_ifu_id_ctrl


