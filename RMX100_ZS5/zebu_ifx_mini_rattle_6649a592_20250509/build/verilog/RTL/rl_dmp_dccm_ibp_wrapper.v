// Library ARCv5EM-3.5.999999999
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
//  This module implements the DCCM IBP replay buffer
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
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"



module rl_dmp_dccm_ibp_wrapper 
  #(parameter DEPTH = 1)   // FIFO depth
  (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                                 clk,                   // clock signal
  input                                 rst_a,                // reset signal

  ////////// IBPv3.1 target interface //////////////////////////////////////////////////
  //
  input                                 dmi_dccm_prio,       // DMI priority pin 
  input                                 dmi_dccm_cmd_valid,
  input                                 dmi_dccm_cmd_read,
  input  [`ADDR_RANGE]                  dmi_dccm_cmd_addr,
  input                                 dmi_dccm_cmd_excl,
  input  [3:0]                          dmi_dccm_cmd_id,
  output                                dmi_dccm_cmd_accept,

  input                                 dmi_dccm_wr_valid,
// spyglass disable_block W240
// SMD: Signal declared but not used
// SJ:  not used because all DMI transactions are single and no burst   
  input                                 dmi_dccm_wr_last,
// spyglass enable_block W240   
  input  [`DCCM_MEM_MASK_WIDTH-1:0]     dmi_dccm_wr_mask,
  input  [`DCCM_DMI_DATA_RANGE]         dmi_dccm_wr_data,
  output                                dmi_dccm_wr_accept,

  output reg                            dmi_dccm_rd_valid,
  output reg                            dmi_dccm_rd_err,
  output                                dmi_dccm_rd_excl_ok,
  output reg [`DCCM_DMI_DATA_RANGE]     dmi_dccm_rd_data,
  output reg                            dmi_dccm_rd_last,
  input                                 dmi_dccm_rd_accept,

  output                                dmi_dccm_wr_done,
  output                                dmi_dccm_wr_excl_okay,
  output                                dmi_dccm_wr_err,
// spyglass disable_block W240
// SMD: Signal declared but not used
// SJ:  not used because this interface constraints wr_resp to be always accepted  
  input                                 dmi_dccm_wr_resp_accept,
// spyglass enable_block W240 
  ////////// Interface to the X3 stage ////////////////////////////////////////////////////////////////////
  //
  input [`ADDR_RANGE]                   x3_lpa_r,         // Locked Physical Addr reg 
  input [1:0]                           x3_lock_flag_r,   // LF  reg value, [0] - LF_CORE, [1] - LF_DMI 
  input [3:0]                           x3_lock_dmi_id_r, // ID of the DMI initiator that set the reservation

  ////////// Interface with the X2 stage ////////////////////////////////////////////////////////////////////
  //
  output reg [31:2]                     x2_dmi_addr_r,
  output reg [3:0]                      x2_dmi_id_r,

  ////////// Interface with the DCCM DMI pipeline /////////////////////////////////////////////////////////
  //    
  output reg [1:0]                      dmi_hp_req,        // High priority DMI req
  output reg [1:0]                      dmi_req,           // DMI request
  output [1:0]                          dmi_req_early,     //  DMI request early signal
  output reg                            dmi_read,          // DMI read transaction
  output reg [31:2]                     dmi_addr,          // DMI Address
  output reg                            dmi_excl,          // Exclusive DMI transaction
  output reg [3:0]                      dmi_id,            // ID of the exclusive initiator
  input [1:0]                           dmi_ack,           // DCCM ack to DMI request
  output reg                            dmi_rmw,           // Atomic or partial write
  input                                 dmi_scrub_r,       // DMI scrubbing in progress
  input                                 dmi_scrub_reset,   // DMI scrubbing complete
  output reg [31:0]                     dmi_wr_data,      // DMI write data
  output reg [3:0]                      dmi_wr_mask,      // DMI write mask
  input                                 dmi_wr_done,      // DMI write is completed

  input [31:0]                          dmi_rd_data,      // DMI read data from DCCM
  input                                 dmi_rd_valid,     // DMI read valid
  input                                 pipe_lost_to_dmi, // 
  input                                 dmi_rd_err,       // ECC error 
  input                                 dmi_sb_err,       // SB error
  input [11:0]                          dccm_base         // DCCM base from CSR
);


// Local declarations
//

reg                     dmi_insert_from_rb;

reg                     rb_cmd_push;
reg                     rb_cmd_pop;
reg                     rb_data_push;
reg                     rb_data_pop;
reg                     rb_cmd_update;
reg                     rb_cmd_update_rmw;
reg                     rb_cmd_scrub_upd;


// Command buffer
//
reg                     rb_cmd_valid_r;
reg                     rb_cmd_read_r;
reg [`DCCM_ADR_MSB:1]   rb_cmd_addr_r;
reg                     rb_cmd_excl_r;
reg [3:0]               rb_cmd_id_r;
reg                     rb_cmd_inserted_r;

reg                     rb_cmd_valid_nxt;

// Write data buffer
//
reg                     rb_data_valid_r;
reg                     rb_data_rmw_r;
reg                     rb_data_err_r;    // error during read-modify-write
reg                     rb_data_rmw_nxt;
reg [31:0]              rb_data_data_r;
reg [3:0]               rb_data_mask_r;

reg                     rb_data_valid_nxt;
reg [31:0]              rb_data_data_nxt;
reg                     dmi_exc_status_r;

reg                     ibp_full_write;
reg                     rd_resp_set;
reg                     rd_resp_reset;
reg                     rd_resp_r;
wire [`DCCM_ADR_MSB:2]  dmi_addr_prel;
wire                    wr_mask_prel;
wire                    dmi_exc_wr_allowed;
wire                    dmi_excl_prel;
wire [3:0]              dmi_id_prel;

wire                    dmi_hp;

reg                     prio_r;
reg                     prio_rr;

reg                     prio_state_cg0;
reg                     prio_state_r;
reg                     prio_state_nxt;
reg  [4:0]              prio_cnt_r;
reg                     prio_cnt_cg0;
reg  [4:0]              prio_cnt_nxt;


assign dmi_addr_prel      = (dmi_insert_from_rb) ? rb_cmd_addr_r[`DCCM_ADR_MSB:2] : dmi_dccm_cmd_addr[`DCCM_ADR_MSB:2];

assign dmi_id_prel        = (dmi_insert_from_rb) ? rb_cmd_id_r   : dmi_dccm_cmd_id;
assign dmi_exc_wr_allowed = ((dmi_addr[31:3] == x3_lpa_r[31:3]) & x3_lock_flag_r[1] & (dmi_id_prel == x3_lock_dmi_id_r)); // reservation is 32-bit aligned

assign dmi_excl_prel      = (dmi_insert_from_rb) ? rb_cmd_excl_r : dmi_dccm_cmd_excl;
assign wr_mask_prel       = ((dmi_exc_wr_allowed & dmi_excl_prel) | ~dmi_excl_prel)
                          | dmi_scrub_r                                                // Allow SB err scrubbing on exclusive reads
                          ;                            

always @*
begin : dmi_pa_PROC
  dmi_addr[19:2]                   = 18'd0;
  dmi_addr[`DCCM_ADR_MSB:2]        = dmi_addr_prel;
  dmi_addr[31:`DCCM_REGN_ADDR_LSB] = dccm_base[`DCCM_REGN_RANGE];
end

////////////////////////////////////////////////////////////////////////////////////////////////
// Inserting IBP transactions in the DCCM pipeline: 
// 1. Insert the DMI transaction from the RB, if the RB is not empty and is not being popped and
//    the entry in RB is not acked.
// 2. Insert the DMI transaction from the IBP interface, if the RB is empty or the RB is being
//    popped.
////////////////////////////////////////////////////////////////////////////////////////////////

always @*
begin : dmi_insert_PROC
  
  dmi_insert_from_rb = rb_cmd_valid_r & (~rb_data_pop);

  if (dmi_insert_from_rb)
  begin
    // Insert from the Replay Buffer
    //
    dmi_req     = {rb_cmd_addr_r[2], ~rb_cmd_addr_r[2]} 
                & {2{~rb_cmd_inserted_r}};
    dmi_hp_req  = dmi_req & ({2{dmi_hp}});
    dmi_read    = rb_cmd_read_r
                | rb_data_rmw_r
                ;
    dmi_excl    = rb_cmd_excl_r
                & (rb_cmd_read_r | (~rb_data_rmw_r))
                ;
    dmi_id      = rb_cmd_id_r;            

    dmi_wr_data = rb_data_data_r;
    dmi_wr_mask = (   rb_data_mask_r
                    & ({4{wr_mask_prel}})
                  );
    dmi_rmw     = 1'b0
                | rb_data_rmw_r
                ;
  end
  else
  begin
    // Insert from the IBP Interface
    //
    dmi_req     = {dmi_dccm_cmd_addr[2], ~dmi_dccm_cmd_addr[2]}
                & {2{dmi_dccm_cmd_accept & dmi_dccm_cmd_valid}};
    dmi_hp_req  = dmi_req & {2{dmi_hp}};
    dmi_read    = dmi_dccm_cmd_read
                | (~ibp_full_write)
                ;
    dmi_excl    = dmi_dccm_cmd_excl
                & (dmi_dccm_cmd_read | ibp_full_write)
                ;    
    dmi_id      = dmi_dccm_cmd_id;        

    dmi_wr_data = dmi_dccm_wr_data;
    dmi_wr_mask = (   dmi_dccm_wr_mask
                    & ({4{wr_mask_prel}})                  
                  );
    dmi_rmw     = 1'b0
                | (dmi_dccm_wr_valid & (~ibp_full_write))
                ;
  end
end

always @*
begin: x2_dmi_outputs_PROC
  x2_dmi_addr_r[19:2]                   = 18'd0;
  x2_dmi_addr_r[`DCCM_ADR_MSB:2]        = rb_cmd_addr_r[`DCCM_ADR_MSB:2];
  x2_dmi_addr_r[31:`DCCM_REGN_ADDR_LSB] = dccm_base[`DCCM_REGN_RANGE]; 
  
  x2_dmi_id_r                           = rb_cmd_id_r;
end

////////////////////////////////////////////////////////////////////////////////////////////
// Command and write acceptance
//
// 1. Write command is accepted only if the write data channel has valid write data
// 2. Accept an exclusive transaction only if the buffer is empty, to be able to deal with 
//    back to back exclusive transactions.
////////////////////////////////////////////////////////////////////////////////////////////

assign dmi_dccm_cmd_accept = (~rb_cmd_valid_r   | (rb_data_pop & ~dmi_dccm_cmd_excl)) 
                           & (dmi_dccm_cmd_read | dmi_dccm_wr_valid)
                           ;
                                                   
assign dmi_dccm_wr_accept  = dmi_dccm_cmd_accept;

////////////////////////////////////////////////////////////////////////////////////////////
// Push and pop
//
////////////////////////////////////////////////////////////////////////////////////////////

always @*
begin : ibp_push_pop_PROC
  // We push a IBP command when the command is accepted
  //
  rb_cmd_push      = dmi_dccm_cmd_valid & dmi_dccm_cmd_accept;
  
  // We push a IBP write data when the IBP write command is accepted
  // or we push read data when the read response is not accepted 
  //
  rb_data_push     = (dmi_dccm_wr_valid & dmi_dccm_wr_accept)
                   | (dmi_dccm_rd_valid & ~dmi_dccm_rd_accept & ~rb_data_valid_r);

  // We pop data on completion of a write transaction
  // or acceptance of read data
  //
  rb_data_pop      = ((( dmi_dccm_rd_valid & dmi_dccm_rd_accept
                      & ~dmi_sb_err & ~dmi_scrub_r // Do not pop if DMI scrub is in-progress 
                     )
                     | (rd_resp_r & ~dmi_scrub_r) // Pop if rd_accept is received and scrubbing done
                     )
                     )
                   | (  dmi_wr_done
                     )
                     ;
  
  // Update cmd_inserted_r when DMI trans is inserted into the pipeline
  //
  rb_cmd_update     = (|dmi_ack);
  // Update RB fields after 
  //   a. Read part of DMI RMW or
  //   b. Detection of SB err on a DMI read
  rb_cmd_update_rmw = (dmi_rd_valid & ~rb_cmd_read_r & rb_data_rmw_r) // (a)
                    | (rb_cmd_read_r & dmi_sb_err);                   // (b)

  // 1. Update cmd_read_r as a write cmd to perform DMI scrubbing 
  // 2. Update cmd_inserted_r to replay RMW for core and DMI arb_freeze cross
  rb_cmd_scrub_upd  = (  rb_cmd_inserted_r & ~dmi_rd_valid 
                       & (  rb_data_rmw_r
                         )) // (2)
                    | (  rb_cmd_inserted_r & dmi_rd_valid & dmi_sb_err
                      );    // (1)
end

always @*
begin : rb_cmd_valid_nxt_PROC
  case ({rb_cmd_push, rb_data_pop})
  2'b10: rb_cmd_valid_nxt = 1'b1;
  2'b01: rb_cmd_valid_nxt = 1'b0;
  2'b11: rb_cmd_valid_nxt = 1'b1;
  default: rb_cmd_valid_nxt = rb_cmd_valid_r;
  endcase
end

always @*
begin : rb_data_valid_nxt_PROC
  case ({rb_data_push, rb_data_pop})
  2'b10: rb_data_valid_nxt = 1'b1;
  2'b01: rb_data_valid_nxt = 1'b0;
  2'b11: rb_data_valid_nxt = 1'b1;
  default: rb_data_valid_nxt = rb_data_valid_r;
  endcase
end

always @*
begin :rb_data_nxt_PROC
  rb_data_data_nxt = (dmi_dccm_wr_valid & dmi_dccm_wr_accept) 
                   ? dmi_dccm_wr_data : dmi_dccm_rd_data; 
  rb_data_rmw_nxt  = (dmi_dccm_wr_valid & dmi_dccm_wr_accept) ? (~ibp_full_write) : 1'b0;
end

////////////////////////////////////////////////////////////////////////////////////////////
// IBP read data channel
//
////////////////////////////////////////////////////////////////////////////////////////////
wire rb_rd_data_valid;
assign rb_rd_data_valid =  rb_data_valid_r & (  rb_cmd_read_r
                                               | dmi_scrub_r 
                                              )
                                           & (~rd_resp_r)
                        ;
always @*
begin : ibp_rd_data_PROC
  dmi_dccm_rd_valid = (rb_rd_data_valid) ? 1'b1 
                                         : (  dmi_rd_valid                                      
                                            & (  rb_cmd_read_r  // No rd_response for read part of RMW
                                              )
                                           );
  dmi_dccm_rd_err   = (rb_rd_data_valid) ? rb_data_err_r  : dmi_rd_err;
  dmi_dccm_rd_data  = (rb_rd_data_valid) ? 
                      rb_data_data_r : dmi_rd_data;
  dmi_dccm_rd_last  = dmi_dccm_rd_valid;
end

//////////////////////////////////////////////////////////////////////////////
// Merging read from memory and partial write
//
//////////////////////////////////////////////////////////////////////////////

reg [3:0]   rmw_merge_mask;
reg [31:0]  rmw_merge_data;

always @*
begin : rmw_merge_PROC
  // We are merging dmi_rd_data with rb_data_data_r.
  //
  
  // If we get an unrecoverable error while doing the read portion of a rmw, 
  // we set the merged mask to zero, i.e.:do not write incorrect data
  //
  rmw_merge_mask = (dmi_rd_err & (~dmi_sb_err)) ? 4'b0000 : 4'b1111;
  
  if (dmi_rd_err & dmi_sb_err)
  begin
    // If SB err is detected on a partial write and SB err is configured with excp,
    // then only do scrubbing and do not perform write operation
    rmw_merge_data = dmi_rd_data;
  end
  else 
  begin
    rmw_merge_data[7:0]   = rb_data_mask_r[0] ? rb_data_data_r[7:0]   : dmi_rd_data[7:0];
    rmw_merge_data[15:8]  = rb_data_mask_r[1] ? rb_data_data_r[15:8]  : dmi_rd_data[15:8];
    rmw_merge_data[23:16] = rb_data_mask_r[2] ? rb_data_data_r[23:16] : dmi_rd_data[23:16];
    rmw_merge_data[31:24] = rb_data_mask_r[3] ? rb_data_data_r[31:24] : dmi_rd_data[31:24];
  end
end

always @*
begin : rd_resp_cg0_PROC
  // Set the rd_resp flop if, read response is accepted
  // (1)  when a DMI scrubbing in-progress for non-atomic op
  // (2)  when a atomic operation in-progress
  rd_resp_set   = (dmi_dccm_rd_valid & dmi_dccm_rd_accept)
                & (dmi_sb_err | dmi_scrub_r                // (1)
                  );

  // Reset the rd_resp flop after 
  // (1) scrubbing is completed for non-atomic op or
  // (2) atomic operation is completed and rd_response accepted
  rd_resp_reset = (  rd_resp_r & (~dmi_scrub_r)   // (1)
                  )
                ;
end

////////////////////////////////////////////////////////////////////////////////////////////
// Partial write detection
//
////////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : ibp_rmw_PROC
  // We need to perform a rmw whenever the IBP write transaction is not accessing an entire 32-bit
  // bank
  //
  ibp_full_write = ((&dmi_dccm_wr_mask)    // All 1's
                 | (~(|dmi_dccm_wr_mask)) // All 0's
                 )
                 ;
end


//////////////////////////////////////////////////////////////////////////////
// Priority counter
//
//////////////////////////////////////////////////////////////////////////////
localparam DMI_LO = 1'b0;
localparam DMI_HI = 1'b1;

always @*
begin : prio_counter_PROC
  prio_cnt_cg0   = 1'b0;
  prio_cnt_nxt   = prio_cnt_r;
  prio_state_cg0 = 1'b0;
  prio_state_nxt = prio_state_r;
  case (prio_state_r)
  DMI_LO:
  begin
    // DMI Low priority
    if (prio_cnt_r[4])
    begin
      prio_cnt_cg0   = 1'b1;
      prio_cnt_nxt   = 5'd0;
      prio_state_cg0 = 1'b1;
      prio_state_nxt = DMI_HI; 
    end
    else if (|(dmi_req & ~dmi_ack))
    begin
      prio_cnt_cg0 = 1'b1;
      prio_cnt_nxt = prio_cnt_r + 1'b1;
    end  
  end
  default:
  begin
    // DMI High priority
    if (prio_cnt_r[4])
    begin
      prio_cnt_cg0   = 1'b1;
      prio_cnt_nxt   = 5'd0;
      prio_state_cg0 = 1'b1;
      prio_state_nxt = DMI_LO; 
    end
    else if (pipe_lost_to_dmi)
    begin
      prio_cnt_cg0 = 1'b1;
      prio_cnt_nxt = prio_cnt_r + 1'b1;
    end  
  end
  endcase
end

assign dmi_hp = prio_rr | (prio_state_r == DMI_HI);

//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////

// Command buffer
//
always @(posedge clk or posedge rst_a)
begin : rb_cmd_buff_regs_PROC
  if (rst_a == 1'b1)
  begin
    rb_cmd_valid_r      <= 1'b0;
    rb_cmd_read_r       <= 1'b0;
    rb_cmd_excl_r       <= 1'b0;
    rb_cmd_id_r         <= 4'h0; 
    rb_cmd_addr_r       <= {19{1'b0}};
    rb_cmd_inserted_r   <= 1'b0;
  end
  else
  begin
    if (rb_cmd_push | rb_data_pop)
    begin
      rb_cmd_valid_r <= rb_cmd_valid_nxt;
    end

    if (  rb_cmd_push | rb_cmd_update | rb_cmd_update_rmw | rb_cmd_scrub_upd
       )
    begin
      rb_cmd_inserted_r <= (|dmi_ack);
    end
 
    if (rb_cmd_push)
    begin         
      rb_cmd_excl_r       <= dmi_dccm_cmd_excl;
      rb_cmd_id_r         <= dmi_dccm_cmd_id;          
      rb_cmd_addr_r       <= dmi_dccm_cmd_addr[`DCCM_ADR_MSB:1];
    end

// spyglass disable_block STARC05-2.2.3.3
// SMD: Flipflop value assigned more than once over same signal in always construct
// SJ:  Enables are not asserted simultaneously; Design intent is to reset/set 
//      read on scrub_upd/back pressure.
    if (rb_cmd_push)
    begin       
      rb_cmd_read_r       <= dmi_dccm_cmd_read;
    end

    if (rb_cmd_scrub_upd)
    begin
      rb_cmd_read_r <= 1'b0;
    end

// Restore rb_cmd_read_r after scrubbing is done, to handle back pressure
    if (dmi_dccm_rd_valid & ~dmi_dccm_rd_accept & dmi_scrub_reset)
    begin
      rb_cmd_read_r <= 1'b1;
    end
// spyglass enable_block STARC05-2.2.3.3    
  end
end

// Data buffer
//
always @(posedge clk or posedge rst_a)
begin : rb_data_buff_regs_PROC
  if (rst_a == 1'b1)
  begin
    rb_data_valid_r     <= 1'b0;
    rb_data_rmw_r       <= 1'b0;
    rb_data_err_r       <= 1'b0;
    rb_data_data_r      <= {32{1'b0}};
    rb_data_mask_r      <= {4{1'b0}};
  end
  else
  begin
    if (rb_data_push | rb_data_pop)
    begin
      rb_data_valid_r <= rb_data_valid_nxt;
    end

   if (rb_cmd_update_rmw)
    begin
      rb_data_rmw_r  <= 1'b0;
      rb_data_data_r <= (rb_cmd_read_r) ? dmi_rd_data : rmw_merge_data;
      rb_data_mask_r <= rmw_merge_mask;
    end  
   else
   begin
     if (rb_data_push)
     begin
       rb_data_rmw_r   <= rb_data_rmw_nxt; // Partial write 
       rb_data_data_r  <= rb_data_data_nxt;
       rb_data_mask_r  <= dmi_dccm_wr_mask;
     end
   end
  
  if (rb_data_pop)
  begin
    rb_data_err_r <= 1'b0;
  end
  else if (  rb_data_push | rb_cmd_update_rmw
          )
   begin
     rb_data_err_r  <= dmi_dccm_rd_err;
   end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmi_exc_status_reg_PROC
  if (rst_a == 1'b1)
  begin
    dmi_exc_status_r <= 1'b0;
  end
  else
  begin
    if (rb_cmd_update == 1'b1)
    begin
      dmi_exc_status_r <= (dmi_exc_wr_allowed & dmi_excl);
    end
  end
end


always @(posedge clk or posedge rst_a)
begin: rd_resp_reg_PROC
  if (rst_a == 1'b1)
  begin
    rd_resp_r      <= 1'b0;
  end
  else
  begin
    if (rd_resp_set == 1'b1)
    begin
      rd_resp_r <= 1'b1;
    end

    else if (rd_resp_reset == 1'b1)
    begin
      rd_resp_r <= 1'b0;
    end

  end
end

// Synchronizer for priority pin
always @(posedge clk or posedge rst_a)
begin: prio_pin_reg_PROC
  if (rst_a == 1'b1)
  begin
    prio_r  <= 1'b0;
    prio_rr <= 1'b0;
  end
  else 
  begin
    prio_r  <= dmi_dccm_prio;  
    prio_rr <= prio_r;
  end
end

always @(posedge clk or posedge rst_a)
begin: prio_state_reg_PROC
  if (rst_a == 1'b1)
  begin
    prio_state_r <= DMI_LO;
  end
  else 
  begin
    if (prio_state_cg0 == 1'b1)
    begin
      prio_state_r <= prio_state_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin: prio_cnt_reg_PROC
  if (rst_a == 1'b1)
  begin
    prio_cnt_r <= 5'd0;
  end
  else 
  begin
    if (prio_cnt_cg0 == 1'b1)
    begin
      prio_cnt_r <= prio_cnt_nxt;
    end
  end
end

////////////////////////////////////////////////////////////////////////////////////////
//                                                                          
// Output assignments
//                                                                         
//////////////////////////////////////////////////////////////////////////////////////
assign dmi_dccm_rd_excl_ok   = dmi_dccm_rd_valid & ~dmi_dccm_rd_err & rb_cmd_excl_r;
assign dmi_dccm_wr_excl_okay = dmi_wr_done       & ~dmi_dccm_wr_err & dmi_exc_status_r;
assign dmi_dccm_wr_done      = dmi_wr_done;
assign dmi_dccm_wr_err       = dmi_wr_done & rb_data_err_r;
assign dmi_req_early         = {(  (dmi_dccm_cmd_valid & dmi_hp & dmi_dccm_cmd_addr[2]) 
                                 | (rb_cmd_valid_r & dmi_hp & ~rb_cmd_inserted_r & rb_cmd_addr_r[2])),
                                (  (dmi_dccm_cmd_valid & dmi_hp & (~dmi_dccm_cmd_addr[2])) 
                                 | (rb_cmd_valid_r & dmi_hp & ~rb_cmd_inserted_r & (~rb_cmd_addr_r[2])))};


endmodule

