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
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_dmp_lsq_cmd_port (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                    // clock signal
  input                          rst_a,                  // reset signal

  ////////// Interface with cmd FIFO /////////////////////////////////////////
  //
  input                          lsq_fifo_cmd_valid,     // top of FIFO
  input [1:0]                    lsq_fifo_cmd_size,      // top of FIFO
  input                          lsq_fifo_cmd_read,      // top of FIFO
  input [`ADDR_RANGE]            lsq_fifo_cmd_addr,      // top of FIFO
  input [`DMP_TARGET_RANGE]      lsq_fifo_cmd_target,    // top of FIFO
  input                          lsq_fifo_cmd_amo,       // top of FIFO
  input [`IBP_CTL_AMO_RANGE]     lsq_fifo_cmd_atop,     // top of FIFO
  input                          lsq_fifo_cmd_excl,      // top of FIFO
  input                          lsq_fifo_cmd_unaligned, // top of FIFO
  input [3:0]                    lsq_fifo_wr_mask1,      //top  of FIFO

  input [`DATA_RANGE]            lsq_fifo_wr_data,       // top of FIFO
  input [3:0]                    lsq_fifo_wr_mask,       // top of FIFO

  input                          lsq_cmd_allowed,

  ////////// Pushing  LSQ LD/ST  FIFO ////////////////////////////////////////
  output reg                     lsq_cmd_to_fifo,
  ////////// Popping  LQ  cmd FIFO ///////////////////////////////////////////
  output reg                     lsq_cmd_pop,
  ////////// Memory Target //////////////////////////////////////////////////
  //
  output reg [`DMP_TARGET_RANGE] lsq_cmd_target_r,

  ////////// Command handshake /////////////////////////////////////////////
  //
  output reg                     lsq_cmd_valid,
  output [1:0]                   lsq_cmd_data_size,
  output                         lsq_cmd_read,
  output reg [`ADDR_RANGE]       lsq_cmd_addr,
  output [`IBP_CTL_AMO_RANGE]    lsq_cmd_atomic,
  output                         lsq_cmd_excl,
  input                          lsq_cmd_accept,

  ////////// Write data handshake ///////////////////////////////////////////
  //
  output reg                     lsq_wr_valid,
  input                          lsq_wr_accept,
  output [`DATA_RANGE]           lsq_wr_data,
  output reg [3:0]               lsq_wr_mask
);


// Local declarations
//
wire       lsq_cmd_state_cg0;
wire       lsq_cmd_target_cg0;


reg        lsq_cmd_accepted;
reg        lsq_cmd_accepted_nxt;
reg        lsq_cmd_accepted_r;
reg        lsq_wr_accepted;
reg        lsq_wr_accepted_nxt;
reg        lsq_wr_accepted_r;



wire       lsq_rd_needed;
wire       lsq_wr_needed;
wire       lsq_cmd_amo;
reg                  lsq_second_cmd_r;
reg                  lsq_second_cmd_nxt;
wire [`ADDR_RANGE]   lsq_fifo_cmd_addr1;

assign lsq_fifo_cmd_addr1 = {lsq_fifo_cmd_addr[`ADDR_MSB:2] + {{`ADDR_SIZE-3{1'b0}},1'b1}, 2'b00}; // @@@ is this correct? What if there is a big wrap-around?
assign lsq_cmd_data_size = lsq_fifo_cmd_size    == 2'b01
                        && lsq_fifo_cmd_addr[0] == 1'b1 ? 2'b10 : lsq_fifo_cmd_size;

  // Overrides for atomic/excl fields when RV_A is present.
assign lsq_cmd_atomic = lsq_fifo_cmd_atop;
assign lsq_cmd_excl   = lsq_fifo_cmd_excl;
assign lsq_cmd_amo    = lsq_fifo_cmd_amo;

assign lsq_cmd_read = lsq_fifo_cmd_read & (~lsq_cmd_amo);
assign lsq_wr_data  = lsq_fifo_wr_data;

assign lsq_rd_needed =  lsq_cmd_read || lsq_cmd_amo;
assign lsq_wr_needed = !lsq_cmd_read || lsq_cmd_amo;

//////////////////////////////////////////////////////////////////////////////
// Command transfer process
//
//////////////////////////////////////////////////////////////////////////////

always @*
begin : lsq_cmd_PROC
  lsq_cmd_accepted_nxt = lsq_cmd_accepted_r;
  lsq_wr_accepted_nxt  = lsq_wr_accepted_r;
  lsq_second_cmd_nxt   = lsq_second_cmd_r;
  lsq_cmd_addr = lsq_fifo_cmd_addr;
  lsq_wr_mask  = lsq_fifo_wr_mask;
  // Overrides for the 2nd cmd in case of unalignement
  if (lsq_second_cmd_r)
  begin
    lsq_cmd_addr = lsq_fifo_cmd_addr1;
    lsq_wr_mask  = lsq_fifo_wr_mask1;
  end

  // Validate cmd/wr channels
  lsq_cmd_valid = lsq_fifo_cmd_valid && lsq_cmd_allowed && !lsq_cmd_accepted_r;
  lsq_wr_valid  = lsq_fifo_cmd_valid && lsq_cmd_allowed && !lsq_wr_accepted_r && lsq_wr_needed;

  // Check for accepts
  lsq_cmd_accepted = lsq_cmd_valid && lsq_cmd_accept;
  lsq_wr_accepted  = lsq_wr_valid  && lsq_wr_accept;

  // Inform fifo in case of accepts
  lsq_cmd_to_fifo = ((lsq_cmd_accepted && (!lsq_wr_needed || lsq_cmd_amo)) || (lsq_wr_accepted && (lsq_wr_needed && !lsq_cmd_amo))) 
                  && !lsq_second_cmd_r
                  ;

  lsq_cmd_pop = 1'b0;
  // Pop fifo if both the cmd and possible wr_data have been accepted.
  if ((lsq_cmd_accepted || lsq_cmd_accepted_r)
  &&  (lsq_wr_accepted  || lsq_wr_accepted_r || !lsq_wr_needed))
  begin
    // Done with this cmd. Reset registers. We either pop the fifo,
    // or send a 2nd cmd in case of unalignment.
    lsq_cmd_accepted_nxt = 1'b0;
    lsq_wr_accepted_nxt = 1'b0;
    lsq_second_cmd_nxt = (!lsq_second_cmd_r) && lsq_fifo_cmd_unaligned;
    if (!lsq_fifo_cmd_unaligned || lsq_second_cmd_r)
      lsq_cmd_pop = 1'b1;
  end
  else // Not done yet, store partial accepts
  begin
    lsq_cmd_accepted_nxt  = lsq_cmd_accepted_nxt | lsq_cmd_accepted;
    lsq_wr_accepted_nxt   = lsq_wr_accepted_nxt  | lsq_wr_accepted;
  end
end

assign lsq_cmd_target_cg0 = lsq_cmd_pop      || lsq_cmd_to_fifo;
assign lsq_cmd_state_cg0  = lsq_cmd_accepted || lsq_wr_accepted;

/////////////////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : lsq_cmd_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_cmd_accepted_r <= 1'b0;
    lsq_wr_accepted_r  <= 1'b0;
    lsq_cmd_target_r   <= {3{1'b0}};
  end
  else
  begin
    if (lsq_cmd_state_cg0 == 1'b1)
    begin
      lsq_cmd_accepted_r <= lsq_cmd_accepted_nxt;
      lsq_wr_accepted_r  <= lsq_wr_accepted_nxt;
    end

    if (lsq_cmd_target_cg0 == 1'b1)
    begin
      lsq_cmd_target_r <= lsq_fifo_cmd_target;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : lsq_second_cmd_PROC
  if (rst_a == 1'b1)
  begin
    lsq_second_cmd_r <= 1'b0;
  end
  else
  begin
    if (lsq_cmd_state_cg0 == 1'b1)
    begin
      lsq_second_cmd_r <= lsq_second_cmd_nxt;
    end
  end
end

endmodule // rl_dmp_lsq_cmd_port

