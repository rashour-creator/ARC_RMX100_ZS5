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
//  The reset_ctrl wrap module implements local reset control within a specific
//  reset domain.
//
//  This file is indented with 2 space characters per tab.
//
// ===========================================================================

// Set simulation timescale
//
`include "defines.v"
`include "const.def"

module rl_reset_ctrl_wrap (
  input       clk,          // clock input for this reset domain
  input       rst_synch_r,        //Global synchronized async reset
  input       LBIST_EN,
  input       test_mode,
  input       rst_cpu_req_synch_r,    // external cpu hard reset request
  input       soft_reset_req_synch_r,   // external soft reset commit
  input       soft_reset_prepare_synch_r,  // external soft reset prepare
  input       dm2arc_hartreset_synch_r,    // DM2ARC hard hart reset
  input       dm2arc_hartreset2_synch_r,   // DM2ARC soft hart reset
  input       ndmreset_synch_r,            // DM2ARC ndm reset

  output reg  is_dm_rst_r,
  output      rst_cpu_ack,        // external cpu hard reset acknowledge
  output      soft_reset_ack,     // external soft reset reset acknowledge
  output      is_soft_reset,      // indicate soft reset to soft_reset_aux
  output      cpu_clk_gated,    // output clock for controlled reset domain
  output      cpu_rst_hard,     // output hard reset
  output      cpu_rst_gated     // output reset controlled reset domain
);

wire rst_sft_req1 = soft_reset_req_synch_r & soft_reset_prepare_synch_r;

wire lb_test_mode;
assign lb_test_mode = LBIST_EN | test_mode;
wire dm2arc_hartreset_ack;
wire ndmreset_ack;
wire dm2arc_hartreset2_ack;
wire is_dm_rst;

  rl_reset_ctrl u_rl_reset_ctrl (
        .clk        (clk          ), // clock input for this reset domain
        .rst_synch_r(rst_synch_r  ), // Global synchronized async reset input
        .test_mode  (lb_test_mode ), // test mode control input

        .rst_hd_req0  (rst_cpu_req_synch_r      ),  // synchronous hard reset request #0
        .rst_hd_req1  (dm2arc_hartreset_synch_r ),  // synchronous hard reset request #1
        .rst_hd_req2  (ndmreset_synch_r         ),  // synchronous hard reset request #2

        .rst_sft_req0 (dm2arc_hartreset2_synch_r),  // synchronous soft reset request #0
        .rst_sft_req1 (rst_sft_req1             ), // synchronous soft reset request #1
        .rst_hd_ack0  (rst_cpu_ack              ),  // hard reset acknowledge #0 
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, reserve for future use
        .rst_hd_ack1    (dm2arc_hartreset_ack ),
        .rst_hd_ack2    (ndmreset_ack         ),
        .rst_sft_ack0   (dm2arc_hartreset2_ack),
        .is_hard_reset  (                    ), // indicate hard reset
// spyglass enable_block UnloadedOutTerm-ML
        .rst_sft_ack1   (soft_reset_ack      ), // soft reset acknowledge #1
        .is_soft_reset  (is_soft_reset       ), // indicate soft reset
        .clk_out    (cpu_clk_gated           ), // output clock for controlled reset domain
        .rst_out    (cpu_rst_gated           ), // output reset controlled reset domain
        .rst_hard   (cpu_rst_hard            ) // output hard reset
        );

assign is_dm_rst = dm2arc_hartreset_ack | ndmreset_ack | dm2arc_hartreset2_ack;

always@(posedge clk or posedge rst_synch_r)
begin
  if (rst_synch_r)
  begin
    is_dm_rst_r <= 1'b0;
  end
  else
  begin
    is_dm_rst_r <= is_dm_rst;
  end
end



endmodule
