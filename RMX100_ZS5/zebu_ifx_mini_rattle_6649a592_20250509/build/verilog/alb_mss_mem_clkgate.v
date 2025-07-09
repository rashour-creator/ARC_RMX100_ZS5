// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
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
module alb_mss_mem_clkgate (input   clk_in,
                            input   rst_a,
                            input   clock_enable,
                            output  clk_out);
  reg i_latch /* verilator clock_enable */;

  always @*
    begin : cg_PROC
      if (!clk_in)
        begin
          // COMBDLY from Verilator warns against delayed (non-blocking)
          // assignments in combo blocks - and it is considered hazardous
          // code that risks simulation and synthesis not matching.
          i_latch = clock_enable;
        end
    end // cg_PROC

  assign clk_out = clk_in & i_latch;

endmodule // alb_mss_mem_clkgate
