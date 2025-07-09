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

module reset_handshake (
  input       clk,          // clock input
  input       rst_a,        // asynchronous reset input
  input       rst_req,      // reset request
  input       ack,          // signal acknowledgement for 1 cycle
  output reg  rst_ack_r     // ack for reset request
);

// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: Source signals from same domain converge after synchronization
// SJ: There is no dependency between these source signals
always @(posedge clk or posedge rst_a)
  begin : rst_ack_PROC
  if (rst_a == 1'b1)
    rst_ack_r <= 1'b0;
  else
    rst_ack_r <= (rst_req & ack) | (rst_ack_r & (rst_req | ack));
  end
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ

endmodule
