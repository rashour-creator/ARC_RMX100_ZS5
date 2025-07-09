// Copyright (C) 2012-2013 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//   clock_gate
//
// ===========================================================================
//
// Description:
//  The Clock Generation block contains logic for driving the gated clocks
//   of the system.
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_rtt_rst.vpp
//
// ==========================================================================



// LEDA off
//spyglass disable_block ALL
module dm_ssync_clkgate (
  input   clk_in,
  input   clock_enable_r,
  output  clk_out
);

// Note: This is a behavioral block that is replaced by the RDF flow before
// synthesis. The replaced block intantiates the propoer clockgate cell of the
// synthesis library

reg latch /* verilator clock_enable */;


always @*
begin
  if (!clk_in)
  begin
          // COMBDLY from Verilator warns against delayed (non-blocking)
          // assignments in combo blocks - and it is considered hazardous
          // code that risks simulation and synthesis not matching.
    latch = clock_enable_r;
  end

end



assign clk_out = clk_in & latch;

endmodule // clkgate
//spyglass enable_block ALL
// LEDA on

