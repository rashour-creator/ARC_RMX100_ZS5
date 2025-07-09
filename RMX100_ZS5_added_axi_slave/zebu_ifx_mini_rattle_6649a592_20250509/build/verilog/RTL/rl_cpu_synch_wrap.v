// Library ARCv5EM-3.5.999999999
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
//  The rl_cpu_synch_wrap module implements synchronizers for all cpu inputs.
//
//  This file is indented with 2 space characters per tab.
//
// ===========================================================================
// Set simulation timescale
//
`include "defines.v"
`include "const.def"

module rl_cpu_synch_wrap (
  output  cpu_synch_top_parity_error_r,
  output  soft_reset_req_synch_r,
  output  soft_reset_prepare_synch_r,
  output  ndmreset_synch_r,
  output  dm2arc_hartreset_synch_r,
  output  dm2arc_hartreset2_synch_r,
  output  dm2arc_havereset_ack_synch_r,
  output  dm2arc_halt_on_reset_synch_r,
  output  rst_init_disable_synch_r,
  output  rst_cpu_req_synch_r,
  output  rst_synch_r,
  output  tm_clk_enable_sync,
  input   wdt_feedback_bit,
  output  wdt_clk_enable_sync,
  output  dm2arc_halt_req_synch_r,
  output  dm2arc_run_req_synch_r,
  output  dm2arc_relaxedpriv_synch_r,
  output  safety_iso_enb_synch_r,
  output  rnmi_synch_r,
  input   ref_clk,
  input   wdt_clk,
  output  wdt_reset_wdt_clk0,
  input   soft_reset_req_a,
  input   soft_reset_prepare_a,
  input   ndmreset_a,
  input   dm2arc_hartreset_a,
  input   dm2arc_hartreset2_a,
  input   dm2arc_havereset_ack_a,
  input   dm2arc_halt_on_reset_a,
  input   rst_init_disable_a,
  input   rst_cpu_req_a,
  input   rst_a,
  input   test_mode,
  input   LBIST_EN,
  input   dm2arc_halt_req_a,
  input   dm2arc_run_req_a,
  input   dm2arc_relaxedpriv_a,
  input   safety_iso_enb_a,
  input   rnmi_a,

  
  input       cpu_clk_gated,          // clock input from reset ctrl
  input       cpu_rst_gated,          // reset input from reset ctrl
  input       clk          // clock input for this reset domain
);

 localparam RST_TMR_CDC = 1;

wire lb_test_mode;
assign lb_test_mode = LBIST_EN | test_mode;

rl_reset_ctrl_synch 
#(.RST_TMR_CDC(RST_TMR_CDC))
u_rl_reset_ctrl_synch
(
  .soft_reset_req_synch_r	(soft_reset_req_synch_r),
  .soft_reset_prepare_synch_r	(soft_reset_prepare_synch_r),
  .ndmreset_synch_r	(ndmreset_synch_r),
  .dm2arc_hartreset_synch_r	(dm2arc_hartreset_synch_r),
  .dm2arc_hartreset2_synch_r	(dm2arc_hartreset2_synch_r),
  .dm2arc_havereset_ack_synch_r	(dm2arc_havereset_ack_synch_r),
  .dm2arc_halt_on_reset_synch_r	(dm2arc_halt_on_reset_synch_r),
  .rst_init_disable_synch_r	(rst_init_disable_synch_r),
  .rst_cpu_req_synch_r	(rst_cpu_req_synch_r),
  .rst_synch_r	(rst_synch_r),
  .soft_reset_req_a	(soft_reset_req_a),
  .soft_reset_prepare_a	(soft_reset_prepare_a),
  .ndmreset_a	(ndmreset_a),
  .dm2arc_hartreset_a	(dm2arc_hartreset_a),
  .dm2arc_hartreset2_a	(dm2arc_hartreset2_a),
  .dm2arc_havereset_ack_a	(dm2arc_havereset_ack_a),
  .dm2arc_halt_on_reset_a	(dm2arc_halt_on_reset_a),
  .rst_init_disable_a	(rst_init_disable_a),
  .rst_cpu_req_a	(rst_cpu_req_a),
  .rst_a	(rst_a),
  .test_mode	(test_mode),
  .LBIST_EN	(LBIST_EN),
        .clk        (clk         ) // clock input for this reset domain \
);

wire cpu_misc_synch_parity_error;
rl_cpu_misc_synch u_rl_cpu_misc_synch (
  .dm2arc_halt_req_synch_r	(dm2arc_halt_req_synch_r),
  .dm2arc_run_req_synch_r	(dm2arc_run_req_synch_r),
  .dm2arc_relaxedpriv_synch_r	(dm2arc_relaxedpriv_synch_r),
  .safety_iso_enb_synch_r	(safety_iso_enb_synch_r),
  .rnmi_synch_r	(rnmi_synch_r),
  .dm2arc_halt_req_a	(dm2arc_halt_req_a),
  .dm2arc_run_req_a	(dm2arc_run_req_a),
  .dm2arc_relaxedpriv_a	(dm2arc_relaxedpriv_a),
  .safety_iso_enb_a	(safety_iso_enb_a),
  .rnmi_a	(rnmi_a),
       .cpu_misc_synch_parity_error       (cpu_misc_synch_parity_error       ), // parity error from synch module \
       .clk       (cpu_clk_gated       ), // clock from reset ctrl \
       .rst       (cpu_rst_gated       ) // reset from reset ctrl \
);

arcv_timer_synch
#(.RST_TMR_CDC(RST_TMR_CDC))
 u_rl_timer_synch 
(
  .tm_clk_enable_sync	(tm_clk_enable_sync),
  .ref_clk	(ref_clk),
       .clk       (cpu_clk_gated       ), // clock from reset ctrl \
       .rst       (cpu_rst_gated       ), // reset from reset ctrl \
       .test_mode (lb_test_mode        ) // test_mode \
);

arcv_wdt_synch 
#(.RST_TMR_CDC(RST_TMR_CDC))
u_rl_wdt_synch (
  .wdt_feedback_bit	(wdt_feedback_bit),
  .wdt_clk_enable_sync	(wdt_clk_enable_sync),
  .wdt_clk	(wdt_clk),
  .wdt_reset_wdt_clk0	(wdt_reset_wdt_clk0),
        .clk       (cpu_clk_gated       ), // clock from reset ctrl \
        .rst       (cpu_rst_gated       ), // reset from reset ctrl \
       .test_mode  (lb_test_mode        ) // test_mode \
);

reg  cpu_synch_top_parity_error_dly_r;
wire cpu_synch_top_parity_error_nxt;
assign cpu_synch_top_parity_error_nxt = 1'b0
                                        | cpu_misc_synch_parity_error;

// spyglass disable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH
// SMD: reset pin is driven by combinational logic
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so it's intended combinational logic on reset pins and it will not have glitch issue.  
always @(posedge cpu_clk_gated or posedge cpu_rst_gated)
  begin : parity_error_PROC
  if (cpu_rst_gated == 1'b1)
    begin
      cpu_synch_top_parity_error_dly_r              <= 1'b0;
    end
  else
    begin
      cpu_synch_top_parity_error_dly_r              <= cpu_synch_top_parity_error_nxt;
    end
  end // parity_error_PROC
// spyglass enable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH
assign cpu_synch_top_parity_error_r = cpu_synch_top_parity_error_dly_r;

endmodule
