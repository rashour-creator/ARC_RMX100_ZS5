// Library ARC_Soc_Trace-1.0.999999999
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
//   rtt_cgm
//
// ===========================================================================
//
// Description:
//    RTT clock gating module to generate the gates clocks to producer front
//   end modules, transport modules and register block
//
//   vpp +q +o dm_cgm.vpp
//
// ===========================================================================

`include "arcv_dm_defines.v"
// Set simulation timescale
//
`include "const.def"
module dm_cgm (

clk,
rst_a,
dm_clken,
clk_ug,
clk_cg);

localparam         CG_HGLD_CNT    = 4; 

//global signals
  input                     clk;
  input                     rst_a;

  input                     dm_clken;


  output                   clk_ug;
  output                   clk_cg;


  wire        dm_clken_qual;
  reg [CG_HGLD_CNT-1:0] cg_holdoff_r;
  

  assign clk_ug = clk;
  assign dm_clken_qual = (|cg_holdoff_r) || dm_clken;  // delay shut off edge
  
  always @(posedge clk or posedge rst_a)
  begin : CLOCK_DELAY_reg_PROC

          if (rst_a == 1'b1)
          begin
            cg_holdoff_r  <= {CG_HGLD_CNT{1'b0}};
          end
          else
          begin
            cg_holdoff_r  <= {cg_holdoff_r[1+:CG_HGLD_CNT-1],dm_clken};
          end

  end // CLOCK_DELAY_reg_PROC



//gate clock for main dm control block
  dm_clock_gate u_clkgate_dm (
  .clk_in            (clk),
  .clock_enable_r    (dm_clken_qual),
  .clk_out           (clk_cg)
);

endmodule


