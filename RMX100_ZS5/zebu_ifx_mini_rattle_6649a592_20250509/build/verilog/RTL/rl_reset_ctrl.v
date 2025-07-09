// Library ARCv5EM-3.5.999999999
`include "defines.v"
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
//  The reset_ctrl module implements local reset control within a specific
//  reset domain.
//
//  This file is indented with 2 space characters per tab.
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"

module rl_reset_ctrl (
  input       clk,          // clock input for this reset domain
  input       rst_synch_r,        // Global synchronized async reset input
  input       test_mode,
  input       rst_hd_req0,       // synchronous hard reset request #0
  output      rst_hd_ack0,       // ack for hard reset request #0
  input       rst_hd_req1,       // synchronous hard reset request #1
  output      rst_hd_ack1,       // ack for hard reset request #1
  input       rst_hd_req2,       // synchronous hard reset request #2
  output      rst_hd_ack2,       // ack for hard reset request #2
  input       rst_sft_req0,       // synchronous soft reset request #0
  output      rst_sft_ack0,       // ack for soft reset request #0
  input       rst_sft_req1,       // synchronous soft reset request #1
  output      rst_sft_ack1,       // ack for soft reset request #1

  output      is_hard_reset,        // indicate hard reset source
  output      is_soft_reset,        // indicate soft reset source
// spyglass disable_block W401
// SMD: clock signal is not an input to the design unit
// SJ : Intended to internally generate clock signals
  output      clk_out,      // output clock for controlled reset domain
// spyglass enable_block W401
  output      rst_hard,     // output hard reset
  output      rst_out       // output reset controlled reset domain
);

// Create a combined reset request signal as the OR of all synchronized
// reset requests

// spyglass disable_block CDC_COHERENCY_RECONV_COMB
// SMD: Source signals from same domain converge after synchronization
// SJ: There is no dependency between these source signals
wire reset_req = 1'b0
                |rst_hd_req0
                |rst_hd_req1
                |rst_hd_req2
                |rst_sft_req0
                |rst_sft_req1
                 ;
// spyglass enable_block CDC_COHERENCY_RECONV_COMB
assign is_hard_reset = 1'b0
                |rst_hd_req0
                |rst_hd_req1
                |rst_hd_req2
                 ;


assign is_soft_reset = reset_req & ~is_hard_reset;

////////////////////////////////////////////////////////////////////////////
//                                                              //
// Instantiate the reset sequencer FSM                          //
//                                                              //
////////////////////////////////////////////////////////////////////////////
//
wire clk_enable_r;  // clock enable for child modules
wire rst_r;         // synchronized async reset for child modules
wire reset_ack_r;   // ack for reset_req
wire rst_hard_r;

reset_fsm u_reset_fsm (
  .clk          (clk          ), // clock input for this reset domain
  .rst_a        (rst_synch_r  ), // async asserted, sync deasserted reset input
  .reset_req    (reset_req    ), // synchronous request for a reset sequence
  .is_hard_reset(is_hard_reset), // indicate hard reset source
  
  .clk_enable_r (clk_enable_r ), // clock enable for child modules
  .rst_r        (rst_r        ), // synchronized async reset for child modules
  .rst_hard_r   (rst_hard_r   ), // synchronized async reset for child modules
  .reset_ack_r  (reset_ack_r  )  // ack for reset_req
);

// Create a combined asynchronous and synchronized reset output
// (test-mode reset can be included here..

// spyglass disable_block W402b
// SMD: Asynchronous set/reset signal is not an input to the module
// SJ : Intended to internally generate asynchronous set/reset signals
assign rst_out = test_mode
               ? rst_synch_r
               : (rst_synch_r | rst_r)
               ;

// spyglass enable_block W402b

assign rst_hard = test_mode
               ? rst_synch_r
               : (rst_synch_r | rst_hard_r)
               ;

// Gate the input clock to create the output clock
//
clkgate u_clkgate (
  .clk_in       (clk          ), // clock input for this reset domain
  .clock_enable_r (clk_enable_r ), // clock enable control from reset FSM
  .clk_out      (clk_out      )  // gated clock for this reset domain
);

// Instantiate a reset_handshake module for each reset request interface
//
reset_handshake u_reset_hd_handshake_0 (
  .clk          (clk              ), // clock input
  .rst_a        (rst_synch_r       ), // reset input
  .rst_req      (rst_hd_req0    ), // reset request
  .ack          (reset_ack_r      ), // signals acknowledgement for 1 cycle
  .rst_ack_r    (rst_hd_ack0    )  // ack for reset request
);
reset_handshake u_reset_hd_handshake_1 (
  .clk          (clk              ), // clock input
  .rst_a        (rst_synch_r       ), // reset input
  .rst_req      (rst_hd_req1    ), // reset request
  .ack          (reset_ack_r      ), // signals acknowledgement for 1 cycle
  .rst_ack_r    (rst_hd_ack1    )  // ack for reset request
);
reset_handshake u_reset_hd_handshake_2 (
  .clk          (clk              ), // clock input
  .rst_a        (rst_synch_r       ), // reset input
  .rst_req      (rst_hd_req2    ), // reset request
  .ack          (reset_ack_r      ), // signals acknowledgement for 1 cycle
  .rst_ack_r    (rst_hd_ack2    )  // ack for reset request
);

reset_handshake u_reset_sft_handshake_0 (
  .clk          (clk              ), // clock input
  .rst_a        (rst_synch_r       ), // reset input
  .rst_req      (rst_sft_req0   ), // reset request
  .ack          (reset_ack_r      ), // signals acknowledgement for 1 cycle
  .rst_ack_r    (rst_sft_ack0   )  // ack for reset request
);
reset_handshake u_reset_sft_handshake_1 (
  .clk          (clk              ), // clock input
  .rst_a        (rst_synch_r       ), // reset input
  .rst_req      (rst_sft_req1   ), // reset request
  .ack          (reset_ack_r      ), // signals acknowledgement for 1 cycle
  .rst_ack_r    (rst_sft_ack1   )  // ack for reset request
);

endmodule

