// Library ARCv5EM-3.5.999999999
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
// clkgate 
// ===========================================================================
//
// Description:
//
// Note: This is a behavioral block that is replaced by the RDF flow before
// synthesis. The replaced block instantiates the proper clockgate cell of
// the synthesis library.
//
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o bc_ram.vpp
//
// ===========================================================================

// Simulation timestep information
//
`include "const.def"

// LEDA off
// spyglass disable_block ALL
// SMD: NA
// SJ: This is purely function model which will be replaced after P&R
module clkgate (
  input   clk_in,
  input   clock_enable_r,
  
  output  clk_out
);

reg latch /* verilator clock_enable */;

always @*
begin
  if (!clk_in)
  begin
    // COMBDLY from Verilator warns against delayed (non-blocking)
    // assignments in combo blocks - and it is considered hazardous
    // code that risks simulation and synthesis not matching.
    //
    // The first version of this change attempted to use delayed_ifdef
    // to leave the original form in place, but for this particular
    // source file VPP does something different (or nothing at all?)
    // and so that broke the build
    latch = clock_enable_r;
  end
end

assign clk_out = clk_in & latch;

endmodule // clkgate
// spyglass enable_block ALL
// LEDA on
