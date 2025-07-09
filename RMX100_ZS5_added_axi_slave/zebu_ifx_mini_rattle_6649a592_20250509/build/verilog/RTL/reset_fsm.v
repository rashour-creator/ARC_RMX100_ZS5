//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2024 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2014, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
// ===========================================================================
//
// Description: 
//  
//  The reset_fsm module implements local reset control fsm for a specific
//  reset domain.
//
//  This file is indented with 2 space characters per tab.
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"

module reset_fsm (
  input       clk,          // clock input for this reset domain
  input       rst_a,        // async asserted, sync deasserted reset input
  input       reset_req,    // synchronous request for a reset sequence
  input       is_hard_reset,    // synchronous request for a reset sequence
  
  output reg  clk_enable_r, // clock enable for child modules
  output reg  rst_r,        // synchronized async reset for child modules
  output reg  rst_hard_r,        // synchronized async reset for child modules
  output reg  reset_ack_r   // ack for reset_req
);

reg         count_r;    // state bit to time certain state transitions
wire  [3:0] fsm_state_r;
reg   [3:0] fsm_state_nxt;

assign fsm_state_r = {clk_enable_r, rst_r, reset_ack_r, count_r};

localparam [3:0]  NORMAL    = 4'b1001;
localparam [3:0]  OFF_C1    = 4'b0000;
localparam [3:0]  OFF_C2    = 4'b0001;
localparam [3:0]  RST_C1    = 4'b0100;
localparam [3:0]  RST_C2    = 4'b0101;
localparam [3:0]  ACK_C1    = 4'b0010;
localparam [3:0]  ACK_C2    = 4'b0011;

reg         clk_enable_nxt;
reg         rst_nxt;
reg         reset_ack_nxt;
reg         count_nxt;
wire        rst_hard_nxt;

always @*
  begin : fsm_logic_PROC
  
  fsm_state_nxt = fsm_state_r;
  
  case (fsm_state_r)
    NORMAL: if (reset_req == 1'b1) fsm_state_nxt = OFF_C1;
    OFF_C1: fsm_state_nxt = OFF_C2;
    OFF_C2: fsm_state_nxt = RST_C1;
    RST_C1: fsm_state_nxt = RST_C2;
    RST_C2: fsm_state_nxt = ACK_C1;
    ACK_C1: fsm_state_nxt = ACK_C2;
    ACK_C2: if (reset_req == 1'b0) fsm_state_nxt = NORMAL;
    default:fsm_state_nxt = NORMAL;
  endcase

  {clk_enable_nxt, rst_nxt, reset_ack_nxt, count_nxt} = fsm_state_nxt;

  end // fsm_logic_PROC

assign  rst_hard_nxt = rst_nxt & is_hard_reset;

// spyglass disable_block INTEGRITY_RESET_GLITCH, Ar_glitch01
// SMD: Preset pin of sequential element is driven by combinational logic
// SMD: Report glitch in reset paths
// SJ: if TMR is enabled, the tripple synchronized reset signal will go through majority vote. 
// But it doesn't matters if the de-assertion of reset is one cycle ealier or later,this warning can be ignored.
// Glitch can be ignored
// spyglass disable_block SETUP_RESET_DRIVING_NON_ASYNC_PIN
// SMD: Asynchronous reset signal is reaching to data pin
// SJ: Intended to generate internal gated reset using below flops. 
always @(posedge clk or posedge rst_a)
  begin : fsm_sync_PROC
  if (rst_a == 1'b1)
    begin
    {clk_enable_r, rst_r, reset_ack_r, count_r} <= NORMAL;
    rst_hard_r                                  <= 1'b0;
    end
  else
    begin
    {clk_enable_r, rst_r, reset_ack_r, count_r} <= fsm_state_nxt;
    rst_hard_r                                  <= rst_hard_nxt;
    end
  end // fsm_sync_PROC
// spyglass enable_block SETUP_RESET_DRIVING_NON_ASYNC_PIN
// spyglass enable_block INTEGRITY_RESET_GLITCH, Ar_glitch01

endmodule // reset_fsm
