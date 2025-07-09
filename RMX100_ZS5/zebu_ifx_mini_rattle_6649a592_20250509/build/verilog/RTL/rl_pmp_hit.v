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
`include "ifu_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_pmp_hit # (
  parameter PMP_LEN    = 30

 )(
  input [PMP_LEN-1:0] addr,                 // input address (IFU, DMP)
  
  input [PMP_LEN-1:0]    pmp_addr,
  input [PMP_LEN-1:0]    pmp_addr_prev,
  input [PMP_LEN-1:0]    pmp_addr_mask,
  input [1:0]            pmp_addr_mode,
  
  output reg             pmp_hit
 
);

// Local Declarations
//
reg  napot_hit; 
reg  tor_hit;   
reg  na4_hit;   

wire addr_ge_bottom;
wire addr_lt_top;

assign addr_ge_bottom = addr >= pmp_addr_prev;
assign addr_lt_top    = addr < pmp_addr;


always @*
begin
  // Evaluate hit in different modes
  //
  napot_hit = (~| ( (addr ^ pmp_addr) & pmp_addr_mask));

  // The NA4 mask is "all ones"
  //
  na4_hit   = (~| (addr ^ pmp_addr));
  
  // TOR
  //
  tor_hit   = addr_ge_bottom & addr_lt_top;
end 


always @*
begin : pmp_hit_mux_PROC
  case (pmp_addr_mode)
  2'b01:   pmp_hit = tor_hit;
  2'b10:   pmp_hit = na4_hit;
  2'b11:   pmp_hit = napot_hit;
  default: pmp_hit = 1'b0;
  endcase
end

endmodule // rl_pmp_hit
