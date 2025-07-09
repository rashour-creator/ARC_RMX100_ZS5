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
// Certain materials incorporated herein are copyright (C) 2010 - 2012, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//   alb_mss_clkctrl: Clock control unit
//
// ===========================================================================
//
// Description:
//  Verilog module defining a clock controller
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +o alb_mss_clkctrl.vpp
//
// ==========================================================================

`include "alb_mss_clkctrl_defines.v"

`timescale 1ns/10ps
module alb_mss_clkctrl(input              ref_clk,
                       output             clk,
                       output             wdt_clk,
                       output             mss_clk,
                       output             iccm_ahb_clk_en,
                       output             dccm_ahb_clk_en,
                       output             mmio_ahb_clk_en,
                       output             mss_fab_mst0_clk_en,
                       output             mss_fab_mst1_clk_en,
                       output             mss_fab_mst2_clk_en,
                       output             mss_fab_mst3_clk_en,
                       output             mss_fab_slv0_clk_en,
                       output             mss_fab_slv1_clk_en,
                       output             mss_fab_slv2_clk_en,
                       output             mss_fab_slv3_clk_en,
                       output             mss_fab_slv4_clk_en,
                       output             mss_fab_slv5_clk_en,
                       input              rst_a,
                       output             rst_b /* verilator public_flat */,





                       input              mss_clkctrl_sel,
                       input              mss_clkctrl_enable,
                       input              mss_clkctrl_write,
                       input  [11:2]      mss_clkctrl_addr,
                       input  [31:0]      mss_clkctrl_wdata,
                       input  [3:0]       mss_clkctrl_wstrb,
                       output [31:0]      mss_clkctrl_rdata,
                       output             mss_clkctrl_slverr,
                       output             mss_clkctrl_ready,

                       output             mss_clkctrl_dummy
                     );


    reg [31:0] i_rdata_r;

    wire       clkctrl_clk;

    wire       nmi_trigger;
    reg [31:0] nmi_counter;


    // assignments
    assign rst_b = !rst_a;

    assign mss_clkctrl_dummy  = 1'b0;
    assign mss_clkctrl_ready  = 1'b1;
    assign mss_clkctrl_slverr = 1'b0;
    assign mss_clkctrl_rdata  = i_rdata_r;



    // If no DVFS feature supported, the clkctrl_clk equals to original ref_clk
    assign clkctrl_clk = ref_clk;



    //-----------------------------------------------------------
    // Generate source clock for each component
    //-----------------------------------------------------------
    reg         dfc_clk_stop_req;
    wire        dfc_clk_stop_ack;
    wire        dfc_clk_stop_rdy;
    reg  [4:0]  clk_rst_cnt;

    reg         dfc_ratio_calc_start;
    reg         dfc_clk_stop_start;
    wire        dfc_clk_stop_done;
    reg         dfc_clk_in_align;

    // clkctrl_clk is the default clock during reset process,
    // count 16 cycles after reset released, then div_cof take effect
    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: clk_rst_cnt_PROC // {
         if (rst_b == 0)
            clk_rst_cnt <= 5'h0;
         else if (clk_rst_cnt[4] == 1'b0)
            clk_rst_cnt <= clk_rst_cnt + 1'b1;
      end // }

    // clk generation logic
    wire       clk_stop_rdy;
    wire       clk_stop_ack;
    reg  [7:0] clk_div_cof;
    reg  [7:0] clk_div_reg;
    wire       clk_enable;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: clk_div_cof_PROC //{
         if (rst_b == 0)
            clk_div_cof <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            clk_div_cof <= 8'd1;
         else if (dfc_clk_stop_done)
            clk_div_cof <= clk_div_reg;
      end //}

    alb_mss_clkctrl_clkgen u_clk_gen (
                                                .clk_in         (clkctrl_clk),
                                                .rst_b          (rst_b),
                                                .div_cof_in     (clk_div_cof),
                                                .clk_in_align   (dfc_clk_in_align),
                                                .clk_stop_req   (dfc_clk_stop_req),
                                                .clk_stop_ack   (clk_stop_ack),
                                                .clk_stop_rdyin (dfc_clk_stop_rdy),
                                                .clk_stop_rdyout(clk_stop_rdy),
                                                .clk_enable     (clk_enable),
                                                .clk_out        (clk)
                                               );

    // wdt_clk generation logic
    wire       wdt_clk_stop_rdy;
    wire       wdt_clk_stop_ack;
    reg  [7:0] wdt_clk_div_cof;
    reg  [7:0] wdt_clk_div_reg;
    wire       wdt_clk_enable;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: wdt_clk_div_cof_PROC //{
         if (rst_b == 0)
            wdt_clk_div_cof <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            wdt_clk_div_cof <= 8'd1;
         else if (dfc_clk_stop_done)
            wdt_clk_div_cof <= wdt_clk_div_reg;
      end //}

    alb_mss_clkctrl_clkgen u_wdt_clk_gen (
                                                .clk_in         (clkctrl_clk),
                                                .rst_b          (rst_b),
                                                .div_cof_in     (wdt_clk_div_cof),
                                                .clk_in_align   (dfc_clk_in_align),
                                                .clk_stop_req   (dfc_clk_stop_req),
                                                .clk_stop_ack   (wdt_clk_stop_ack),
                                                .clk_stop_rdyin (dfc_clk_stop_rdy),
                                                .clk_stop_rdyout(wdt_clk_stop_rdy),
                                                .clk_enable     (wdt_clk_enable),
                                                .clk_out        (wdt_clk)
                                               );

    // mss_clk generation logic
    wire       mss_clk_stop_rdy;
    wire       mss_clk_stop_ack;
    reg  [7:0] mss_clk_div_cof;
    reg  [7:0] mss_clk_div_reg;
    wire       mss_clk_enable;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_clk_div_cof_PROC //{
         if (rst_b == 0)
            mss_clk_div_cof <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_clk_div_cof <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_clk_div_cof <= mss_clk_div_reg;
      end //}

    alb_mss_clkctrl_clkgen u_mss_clk_gen (
                                                .clk_in         (clkctrl_clk),
                                                .rst_b          (rst_b),
                                                .div_cof_in     (mss_clk_div_cof),
                                                .clk_in_align   (dfc_clk_in_align),
                                                .clk_stop_req   (dfc_clk_stop_req),
                                                .clk_stop_ack   (mss_clk_stop_ack),
                                                .clk_stop_rdyin (dfc_clk_stop_rdy),
                                                .clk_stop_rdyout(mss_clk_stop_rdy),
                                                .clk_enable     (mss_clk_enable),
                                                .clk_out        (mss_clk)
                                               );


    //-----------------------------------------------------------
    // Generate clock enable for each component
    //-----------------------------------------------------------
    // generate clock enable: iccm_ahb_clk_en
    wire [7:0] iccm_ahb_clk_en_ratio;
    reg  [7:0] iccm_ahb_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: iccm_ahb_clk_en_ratio_PROC // {
         if (rst_b == 0)
            iccm_ahb_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            iccm_ahb_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            iccm_ahb_clk_en_ratio_r <= iccm_ahb_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_iccm_ahb_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (iccm_ahb_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (iccm_ahb_clk_en)
                                                     );

    // generate clock enable: dccm_ahb_clk_en
    wire [7:0] dccm_ahb_clk_en_ratio;
    reg  [7:0] dccm_ahb_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: dccm_ahb_clk_en_ratio_PROC // {
         if (rst_b == 0)
            dccm_ahb_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            dccm_ahb_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            dccm_ahb_clk_en_ratio_r <= dccm_ahb_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_dccm_ahb_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (dccm_ahb_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (dccm_ahb_clk_en)
                                                     );

    // generate clock enable: mmio_ahb_clk_en
    wire [7:0] mmio_ahb_clk_en_ratio;
    reg  [7:0] mmio_ahb_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mmio_ahb_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mmio_ahb_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mmio_ahb_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mmio_ahb_clk_en_ratio_r <= mmio_ahb_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mmio_ahb_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mmio_ahb_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mmio_ahb_clk_en)
                                                     );

    // generate clock enable: mss_fab_mst0_clk_en
    wire [7:0] mss_fab_mst0_clk_en_ratio;
    reg  [7:0] mss_fab_mst0_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst0_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_mst0_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_mst0_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_mst0_clk_en_ratio_r <= mss_fab_mst0_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_mst0_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_mst0_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_mst0_clk_en)
                                                     );

    // generate clock enable: mss_fab_mst1_clk_en
    wire [7:0] mss_fab_mst1_clk_en_ratio;
    reg  [7:0] mss_fab_mst1_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst1_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_mst1_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_mst1_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_mst1_clk_en_ratio_r <= mss_fab_mst1_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_mst1_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_mst1_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_mst1_clk_en)
                                                     );

    // generate clock enable: mss_fab_mst2_clk_en
    wire [7:0] mss_fab_mst2_clk_en_ratio;
    reg  [7:0] mss_fab_mst2_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst2_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_mst2_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_mst2_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_mst2_clk_en_ratio_r <= mss_fab_mst2_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_mst2_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_mst2_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_mst2_clk_en)
                                                     );

    // generate clock enable: mss_fab_mst3_clk_en
    wire [7:0] mss_fab_mst3_clk_en_ratio;
    reg  [7:0] mss_fab_mst3_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst3_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_mst3_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_mst3_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_mst3_clk_en_ratio_r <= mss_fab_mst3_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_mst3_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_mst3_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_mst3_clk_en)
                                                     );

    // generate clock enable: mss_fab_slv0_clk_en
    wire [7:0] mss_fab_slv0_clk_en_ratio;
    reg  [7:0] mss_fab_slv0_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv0_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_slv0_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_slv0_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_slv0_clk_en_ratio_r <= mss_fab_slv0_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_slv0_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_slv0_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_slv0_clk_en)
                                                     );

    // generate clock enable: mss_fab_slv1_clk_en
    wire [7:0] mss_fab_slv1_clk_en_ratio;
    reg  [7:0] mss_fab_slv1_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv1_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_slv1_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_slv1_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_slv1_clk_en_ratio_r <= mss_fab_slv1_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_slv1_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_slv1_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_slv1_clk_en)
                                                     );

    // generate clock enable: mss_fab_slv2_clk_en
    wire [7:0] mss_fab_slv2_clk_en_ratio;
    reg  [7:0] mss_fab_slv2_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv2_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_slv2_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_slv2_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_slv2_clk_en_ratio_r <= mss_fab_slv2_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_slv2_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_slv2_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_slv2_clk_en)
                                                     );

    // generate clock enable: mss_fab_slv3_clk_en
    wire [7:0] mss_fab_slv3_clk_en_ratio;
    reg  [7:0] mss_fab_slv3_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv3_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_slv3_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_slv3_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_slv3_clk_en_ratio_r <= mss_fab_slv3_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_slv3_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_slv3_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_slv3_clk_en)
                                                     );

    // generate clock enable: mss_fab_slv4_clk_en
    wire [7:0] mss_fab_slv4_clk_en_ratio;
    reg  [7:0] mss_fab_slv4_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv4_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_slv4_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_slv4_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_slv4_clk_en_ratio_r <= mss_fab_slv4_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_slv4_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_slv4_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_slv4_clk_en)
                                                     );

    // generate clock enable: mss_fab_slv5_clk_en
    wire [7:0] mss_fab_slv5_clk_en_ratio;
    reg  [7:0] mss_fab_slv5_clk_en_ratio_r;

    always @ (posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv5_clk_en_ratio_PROC // {
         if (rst_b == 0)
            mss_fab_slv5_clk_en_ratio_r <= 8'h1;
         else if (clk_rst_cnt == 5'hF)
            mss_fab_slv5_clk_en_ratio_r <= 8'd1;
         else if (dfc_clk_stop_done)
            mss_fab_slv5_clk_en_ratio_r <= mss_fab_slv5_clk_en_ratio;
      end // }

    alb_mss_clkctrl_clken_gen u_mss_fab_slv5_clk_en_gen (
                                                      .clk_in         (clkctrl_clk),
                                                      .clk_en_in      (mss_clk_enable),
                                                      .rst_b          (rst_b),
                                                      .ratio          (mss_fab_slv5_clk_en_ratio_r),
                                                      .clk_in_align   (dfc_clk_in_align),
                                                      .clk_en_out     (mss_fab_slv5_clk_en)
                                                     );


    //-----------------------------------------------------------
    // Generate clock enable stop ready signals
    //-----------------------------------------------------------
    wire clk_stop_rdy_dummy = 1'b1;
    assign dfc_clk_stop_rdy =
                              clk_stop_rdy &
                              wdt_clk_stop_rdy &
                              mss_clk_stop_rdy &
                              clk_stop_rdy_dummy;

  //-----------------------------------------------------------
  // Clock Ratio Programming Logic
  //-----------------------------------------------------------
  // control logic to make all settings to different clock source
  // and clock enable source to be valid at the same time
    wire [7:0]  mss_clkctrl_cfg_ctrl;
    wire        dfc_calc_err;
    wire        dfc_chk_err;

    reg         dfc_start;
    reg  [1:0]  dfc_cur_state;
    reg  [1:0]  dfc_next_state;
    wire        dfc_ratio_calc_done;
    wire        dfc_ratio_calc_err;
    wire        dfc_ratio_chk_err;

    reg         clr_calc_status;
    reg         store_calc_status;
    reg         go2idle_calc_err;

    reg         dfc_clk_align_done;
    reg [7:0]   dfc_clk_align_cnt;

    /*************************************************/
    /* Dynamic clock frequency change state machine  */
    /*************************************************/
    localparam  P_DFC_IDLE       = 2'b00;
    localparam  P_DFC_RATIO_CALC = 2'b01;
    localparam  P_DFC_CLK_STOP   = 2'b10;
    localparam  P_DFC_CLK_ALIGN  = 2'b11;

    always @(posedge clkctrl_clk or negedge rst_b)
      begin: dfc_cur_state_PROC //{
         if (!rst_b)
            dfc_cur_state <= P_DFC_IDLE;
         else
            dfc_cur_state <= dfc_next_state;
      end //} dfc_cur_state_PROC

    always @(*)
      begin: dfc_next_state_PROC

         dfc_next_state       = dfc_cur_state;

         dfc_ratio_calc_start = 1'b0;
         dfc_clk_stop_start   = 1'b0;
         clr_calc_status      = 1'b0;
         store_calc_status    = 1'b0;
         go2idle_calc_err     = 1'b0;
         dfc_clk_in_align     = 1'b0;
         dfc_clk_align_done   = 1'b0;

         case (dfc_cur_state)
           P_DFC_IDLE:
                             begin
                                if (dfc_start)
                                  begin
                                     dfc_next_state  = P_DFC_RATIO_CALC;
                                     dfc_ratio_calc_start = 1'b1;
                                     clr_calc_status      = 1'b1;
                                  end
                             end
           P_DFC_RATIO_CALC:
                             begin
                                if (dfc_ratio_calc_done & (~dfc_ratio_calc_err) & (~dfc_ratio_chk_err))
                                  begin
                                     dfc_next_state = P_DFC_CLK_STOP;
                                     dfc_clk_stop_start  = 1'b1;
                                     store_calc_status   = 1'b1;
                                  end
                                else if (dfc_ratio_calc_done & (dfc_ratio_calc_err | dfc_ratio_chk_err))
                                  begin
                                     dfc_next_state = P_DFC_IDLE;
                                     store_calc_status = 1'b1;
                                     go2idle_calc_err  = 1'b1;
                                  end
                             end
           P_DFC_CLK_STOP:
                             begin
                                if (dfc_clk_stop_done)
                                  dfc_next_state = P_DFC_CLK_ALIGN;
                             end
           P_DFC_CLK_ALIGN:
                             begin
                                dfc_clk_in_align = 1'b1;
                                if (dfc_clk_align_cnt == 8'h0F)
                                  begin
                                     dfc_next_state = P_DFC_IDLE;
                                     dfc_clk_align_done = 1'b1;
                                  end
                             end
           default:
                             begin
                                  dfc_next_state = P_DFC_IDLE;
                                  end
         endcase
                             end

    always @(posedge clkctrl_clk or negedge rst_b)
      begin: dfc_clk_align_cnt_PROC //{
         if (!rst_b)
            dfc_clk_align_cnt <= 8'h0;
         else if (~dfc_clk_in_align)
            dfc_clk_align_cnt <= 8'h0;
         else if (dfc_clk_in_align)
            dfc_clk_align_cnt <= dfc_clk_align_cnt + 1;
      end //} dfc_clk_align_cnt_PROC

    /***********************************************************/
    /* iccm_ahb_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         iccm_ahb_clk_en_calc_req;
    wire        iccm_ahb_clk_en_calc_ack;
    reg         iccm_ahb_clk_en_calc_done;
    wire        iccm_ahb_clk_en_calc_err;

    // iccm_ahb_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: iccm_ahb_clk_en_calc_req_PROC //{
         if (!rst_b)
            iccm_ahb_clk_en_calc_req <= 1'b0;
         else if (iccm_ahb_clk_en_calc_req & iccm_ahb_clk_en_calc_ack)
            iccm_ahb_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            iccm_ahb_clk_en_calc_req <= 1'b1;
      end //} iccm_ahb_clk_en_calc_req_PROC

    // iccm_ahb_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: iccm_ahb_clk_en_calc_done_PROC //{
         if (!rst_b)
            iccm_ahb_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            iccm_ahb_clk_en_calc_done <= 1'b0;
         else if (iccm_ahb_clk_en_calc_req & iccm_ahb_clk_en_calc_ack)
            iccm_ahb_clk_en_calc_done <= 1'b1;
     end //} iccm_ahb_clk_en_calc_done_PROC

    // iccm_ahb_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_iccm_ahb_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (clk_div_reg),
                                                              .ratio_in_B   (mss_clk_div_reg),
                                                              .ratio_req    (iccm_ahb_clk_en_calc_req),
                                                              .ratio_ack    (iccm_ahb_clk_en_calc_ack),
                                                              .ratio_err    (iccm_ahb_clk_en_calc_err),
                                                              .ratio_result (iccm_ahb_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* iccm_ahb_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        iccm_ahb_clk_en_chk_err = 1'b0;

    // iccm_ahb_clk_en_calc_status
    wire [7:0]  iccm_ahb_clk_en_calc_status;
    reg         iccm_ahb_clk_en_calc_done_r;
    reg         iccm_ahb_clk_en_calc_err_r;
    reg         iccm_ahb_clk_en_chk_err_r;

    assign      iccm_ahb_clk_en_calc_status = {5'b0, iccm_ahb_clk_en_chk_err_r,
                                                    iccm_ahb_clk_en_calc_err_r,
                                                    iccm_ahb_clk_en_calc_done_r};

    // iccm_ahb_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: iccm_ahb_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              iccm_ahb_clk_en_calc_done_r <= 1'b0;
              iccm_ahb_clk_en_calc_err_r  <= 1'b0;
              iccm_ahb_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              iccm_ahb_clk_en_calc_done_r <= 1'b0;
              iccm_ahb_clk_en_calc_err_r  <= 1'b0;
              iccm_ahb_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              iccm_ahb_clk_en_calc_done_r <= iccm_ahb_clk_en_calc_done;
              iccm_ahb_clk_en_calc_err_r  <= iccm_ahb_clk_en_calc_err;
              iccm_ahb_clk_en_chk_err_r   <= iccm_ahb_clk_en_chk_err;
           end
     end //} iccm_ahb_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* dccm_ahb_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         dccm_ahb_clk_en_calc_req;
    wire        dccm_ahb_clk_en_calc_ack;
    reg         dccm_ahb_clk_en_calc_done;
    wire        dccm_ahb_clk_en_calc_err;

    // dccm_ahb_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: dccm_ahb_clk_en_calc_req_PROC //{
         if (!rst_b)
            dccm_ahb_clk_en_calc_req <= 1'b0;
         else if (dccm_ahb_clk_en_calc_req & dccm_ahb_clk_en_calc_ack)
            dccm_ahb_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            dccm_ahb_clk_en_calc_req <= 1'b1;
      end //} dccm_ahb_clk_en_calc_req_PROC

    // dccm_ahb_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: dccm_ahb_clk_en_calc_done_PROC //{
         if (!rst_b)
            dccm_ahb_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            dccm_ahb_clk_en_calc_done <= 1'b0;
         else if (dccm_ahb_clk_en_calc_req & dccm_ahb_clk_en_calc_ack)
            dccm_ahb_clk_en_calc_done <= 1'b1;
     end //} dccm_ahb_clk_en_calc_done_PROC

    // dccm_ahb_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_dccm_ahb_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (clk_div_reg),
                                                              .ratio_in_B   (mss_clk_div_reg),
                                                              .ratio_req    (dccm_ahb_clk_en_calc_req),
                                                              .ratio_ack    (dccm_ahb_clk_en_calc_ack),
                                                              .ratio_err    (dccm_ahb_clk_en_calc_err),
                                                              .ratio_result (dccm_ahb_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* dccm_ahb_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        dccm_ahb_clk_en_chk_err = 1'b0;

    // dccm_ahb_clk_en_calc_status
    wire [7:0]  dccm_ahb_clk_en_calc_status;
    reg         dccm_ahb_clk_en_calc_done_r;
    reg         dccm_ahb_clk_en_calc_err_r;
    reg         dccm_ahb_clk_en_chk_err_r;

    assign      dccm_ahb_clk_en_calc_status = {5'b0, dccm_ahb_clk_en_chk_err_r,
                                                    dccm_ahb_clk_en_calc_err_r,
                                                    dccm_ahb_clk_en_calc_done_r};

    // dccm_ahb_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: dccm_ahb_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              dccm_ahb_clk_en_calc_done_r <= 1'b0;
              dccm_ahb_clk_en_calc_err_r  <= 1'b0;
              dccm_ahb_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              dccm_ahb_clk_en_calc_done_r <= 1'b0;
              dccm_ahb_clk_en_calc_err_r  <= 1'b0;
              dccm_ahb_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              dccm_ahb_clk_en_calc_done_r <= dccm_ahb_clk_en_calc_done;
              dccm_ahb_clk_en_calc_err_r  <= dccm_ahb_clk_en_calc_err;
              dccm_ahb_clk_en_chk_err_r   <= dccm_ahb_clk_en_chk_err;
           end
     end //} dccm_ahb_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mmio_ahb_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         mmio_ahb_clk_en_calc_req;
    wire        mmio_ahb_clk_en_calc_ack;
    reg         mmio_ahb_clk_en_calc_done;
    wire        mmio_ahb_clk_en_calc_err;

    // mmio_ahb_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mmio_ahb_clk_en_calc_req_PROC //{
         if (!rst_b)
            mmio_ahb_clk_en_calc_req <= 1'b0;
         else if (mmio_ahb_clk_en_calc_req & mmio_ahb_clk_en_calc_ack)
            mmio_ahb_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            mmio_ahb_clk_en_calc_req <= 1'b1;
      end //} mmio_ahb_clk_en_calc_req_PROC

    // mmio_ahb_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mmio_ahb_clk_en_calc_done_PROC //{
         if (!rst_b)
            mmio_ahb_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            mmio_ahb_clk_en_calc_done <= 1'b0;
         else if (mmio_ahb_clk_en_calc_req & mmio_ahb_clk_en_calc_ack)
            mmio_ahb_clk_en_calc_done <= 1'b1;
     end //} mmio_ahb_clk_en_calc_done_PROC

    // mmio_ahb_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_mmio_ahb_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (clk_div_reg),
                                                              .ratio_in_B   (mss_clk_div_reg),
                                                              .ratio_req    (mmio_ahb_clk_en_calc_req),
                                                              .ratio_ack    (mmio_ahb_clk_en_calc_ack),
                                                              .ratio_err    (mmio_ahb_clk_en_calc_err),
                                                              .ratio_result (mmio_ahb_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* mmio_ahb_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mmio_ahb_clk_en_chk_err = 1'b0;

    // mmio_ahb_clk_en_calc_status
    wire [7:0]  mmio_ahb_clk_en_calc_status;
    reg         mmio_ahb_clk_en_calc_done_r;
    reg         mmio_ahb_clk_en_calc_err_r;
    reg         mmio_ahb_clk_en_chk_err_r;

    assign      mmio_ahb_clk_en_calc_status = {5'b0, mmio_ahb_clk_en_chk_err_r,
                                                    mmio_ahb_clk_en_calc_err_r,
                                                    mmio_ahb_clk_en_calc_done_r};

    // mmio_ahb_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mmio_ahb_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mmio_ahb_clk_en_calc_done_r <= 1'b0;
              mmio_ahb_clk_en_calc_err_r  <= 1'b0;
              mmio_ahb_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mmio_ahb_clk_en_calc_done_r <= 1'b0;
              mmio_ahb_clk_en_calc_err_r  <= 1'b0;
              mmio_ahb_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mmio_ahb_clk_en_calc_done_r <= mmio_ahb_clk_en_calc_done;
              mmio_ahb_clk_en_calc_err_r  <= mmio_ahb_clk_en_calc_err;
              mmio_ahb_clk_en_chk_err_r   <= mmio_ahb_clk_en_chk_err;
           end
     end //} mmio_ahb_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_mst0_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         mss_fab_mst0_clk_en_calc_req;
    wire        mss_fab_mst0_clk_en_calc_ack;
    reg         mss_fab_mst0_clk_en_calc_done;
    wire        mss_fab_mst0_clk_en_calc_err;

    // mss_fab_mst0_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst0_clk_en_calc_req_PROC //{
         if (!rst_b)
            mss_fab_mst0_clk_en_calc_req <= 1'b0;
         else if (mss_fab_mst0_clk_en_calc_req & mss_fab_mst0_clk_en_calc_ack)
            mss_fab_mst0_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            mss_fab_mst0_clk_en_calc_req <= 1'b1;
      end //} mss_fab_mst0_clk_en_calc_req_PROC

    // mss_fab_mst0_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst0_clk_en_calc_done_PROC //{
         if (!rst_b)
            mss_fab_mst0_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            mss_fab_mst0_clk_en_calc_done <= 1'b0;
         else if (mss_fab_mst0_clk_en_calc_req & mss_fab_mst0_clk_en_calc_ack)
            mss_fab_mst0_clk_en_calc_done <= 1'b1;
     end //} mss_fab_mst0_clk_en_calc_done_PROC

    // mss_fab_mst0_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_mss_fab_mst0_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (mss_clk_div_reg),
                                                              .ratio_in_B   (clk_div_reg),
                                                              .ratio_req    (mss_fab_mst0_clk_en_calc_req),
                                                              .ratio_ack    (mss_fab_mst0_clk_en_calc_ack),
                                                              .ratio_err    (mss_fab_mst0_clk_en_calc_err),
                                                              .ratio_result (mss_fab_mst0_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* mss_fab_mst0_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_mst0_clk_en_chk_err = 1'b0;

    // mss_fab_mst0_clk_en_calc_status
    wire [7:0]  mss_fab_mst0_clk_en_calc_status;
    reg         mss_fab_mst0_clk_en_calc_done_r;
    reg         mss_fab_mst0_clk_en_calc_err_r;
    reg         mss_fab_mst0_clk_en_chk_err_r;

    assign      mss_fab_mst0_clk_en_calc_status = {5'b0, mss_fab_mst0_clk_en_chk_err_r,
                                                    mss_fab_mst0_clk_en_calc_err_r,
                                                    mss_fab_mst0_clk_en_calc_done_r};

    // mss_fab_mst0_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst0_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_mst0_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst0_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst0_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_mst0_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst0_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst0_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_mst0_clk_en_calc_done_r <= mss_fab_mst0_clk_en_calc_done;
              mss_fab_mst0_clk_en_calc_err_r  <= mss_fab_mst0_clk_en_calc_err;
              mss_fab_mst0_clk_en_chk_err_r   <= mss_fab_mst0_clk_en_chk_err;
           end
     end //} mss_fab_mst0_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_mst1_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         mss_fab_mst1_clk_en_calc_req;
    wire        mss_fab_mst1_clk_en_calc_ack;
    reg         mss_fab_mst1_clk_en_calc_done;
    wire        mss_fab_mst1_clk_en_calc_err;

    // mss_fab_mst1_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst1_clk_en_calc_req_PROC //{
         if (!rst_b)
            mss_fab_mst1_clk_en_calc_req <= 1'b0;
         else if (mss_fab_mst1_clk_en_calc_req & mss_fab_mst1_clk_en_calc_ack)
            mss_fab_mst1_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            mss_fab_mst1_clk_en_calc_req <= 1'b1;
      end //} mss_fab_mst1_clk_en_calc_req_PROC

    // mss_fab_mst1_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst1_clk_en_calc_done_PROC //{
         if (!rst_b)
            mss_fab_mst1_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            mss_fab_mst1_clk_en_calc_done <= 1'b0;
         else if (mss_fab_mst1_clk_en_calc_req & mss_fab_mst1_clk_en_calc_ack)
            mss_fab_mst1_clk_en_calc_done <= 1'b1;
     end //} mss_fab_mst1_clk_en_calc_done_PROC

    // mss_fab_mst1_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_mss_fab_mst1_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (mss_clk_div_reg),
                                                              .ratio_in_B   (clk_div_reg),
                                                              .ratio_req    (mss_fab_mst1_clk_en_calc_req),
                                                              .ratio_ack    (mss_fab_mst1_clk_en_calc_ack),
                                                              .ratio_err    (mss_fab_mst1_clk_en_calc_err),
                                                              .ratio_result (mss_fab_mst1_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* mss_fab_mst1_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_mst1_clk_en_chk_err = 1'b0;

    // mss_fab_mst1_clk_en_calc_status
    wire [7:0]  mss_fab_mst1_clk_en_calc_status;
    reg         mss_fab_mst1_clk_en_calc_done_r;
    reg         mss_fab_mst1_clk_en_calc_err_r;
    reg         mss_fab_mst1_clk_en_chk_err_r;

    assign      mss_fab_mst1_clk_en_calc_status = {5'b0, mss_fab_mst1_clk_en_chk_err_r,
                                                    mss_fab_mst1_clk_en_calc_err_r,
                                                    mss_fab_mst1_clk_en_calc_done_r};

    // mss_fab_mst1_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst1_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_mst1_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst1_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst1_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_mst1_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst1_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst1_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_mst1_clk_en_calc_done_r <= mss_fab_mst1_clk_en_calc_done;
              mss_fab_mst1_clk_en_calc_err_r  <= mss_fab_mst1_clk_en_calc_err;
              mss_fab_mst1_clk_en_chk_err_r   <= mss_fab_mst1_clk_en_chk_err;
           end
     end //} mss_fab_mst1_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_mst2_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         mss_fab_mst2_clk_en_calc_req;
    wire        mss_fab_mst2_clk_en_calc_ack;
    reg         mss_fab_mst2_clk_en_calc_done;
    wire        mss_fab_mst2_clk_en_calc_err;

    // mss_fab_mst2_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst2_clk_en_calc_req_PROC //{
         if (!rst_b)
            mss_fab_mst2_clk_en_calc_req <= 1'b0;
         else if (mss_fab_mst2_clk_en_calc_req & mss_fab_mst2_clk_en_calc_ack)
            mss_fab_mst2_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            mss_fab_mst2_clk_en_calc_req <= 1'b1;
      end //} mss_fab_mst2_clk_en_calc_req_PROC

    // mss_fab_mst2_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst2_clk_en_calc_done_PROC //{
         if (!rst_b)
            mss_fab_mst2_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            mss_fab_mst2_clk_en_calc_done <= 1'b0;
         else if (mss_fab_mst2_clk_en_calc_req & mss_fab_mst2_clk_en_calc_ack)
            mss_fab_mst2_clk_en_calc_done <= 1'b1;
     end //} mss_fab_mst2_clk_en_calc_done_PROC

    // mss_fab_mst2_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_mss_fab_mst2_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (mss_clk_div_reg),
                                                              .ratio_in_B   (clk_div_reg),
                                                              .ratio_req    (mss_fab_mst2_clk_en_calc_req),
                                                              .ratio_ack    (mss_fab_mst2_clk_en_calc_ack),
                                                              .ratio_err    (mss_fab_mst2_clk_en_calc_err),
                                                              .ratio_result (mss_fab_mst2_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* mss_fab_mst2_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_mst2_clk_en_chk_err = 1'b0;

    // mss_fab_mst2_clk_en_calc_status
    wire [7:0]  mss_fab_mst2_clk_en_calc_status;
    reg         mss_fab_mst2_clk_en_calc_done_r;
    reg         mss_fab_mst2_clk_en_calc_err_r;
    reg         mss_fab_mst2_clk_en_chk_err_r;

    assign      mss_fab_mst2_clk_en_calc_status = {5'b0, mss_fab_mst2_clk_en_chk_err_r,
                                                    mss_fab_mst2_clk_en_calc_err_r,
                                                    mss_fab_mst2_clk_en_calc_done_r};

    // mss_fab_mst2_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst2_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_mst2_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst2_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst2_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_mst2_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst2_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst2_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_mst2_clk_en_calc_done_r <= mss_fab_mst2_clk_en_calc_done;
              mss_fab_mst2_clk_en_calc_err_r  <= mss_fab_mst2_clk_en_calc_err;
              mss_fab_mst2_clk_en_chk_err_r   <= mss_fab_mst2_clk_en_chk_err;
           end
     end //} mss_fab_mst2_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_mst3_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    wire        mss_fab_mst3_clk_en_calc_req  = 1'b0;
    wire        mss_fab_mst3_clk_en_calc_ack  = 1'b0;
    wire        mss_fab_mst3_clk_en_calc_done = 1'b1;
    wire        mss_fab_mst3_clk_en_calc_err  = 1'b0;
    assign      mss_fab_mst3_clk_en_ratio     = 8'h1;

    /***********************************************************/
    /* mss_fab_mst3_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_mst3_clk_en_chk_err = 1'b0;

    // mss_fab_mst3_clk_en_calc_status
    wire [7:0]  mss_fab_mst3_clk_en_calc_status;
    reg         mss_fab_mst3_clk_en_calc_done_r;
    reg         mss_fab_mst3_clk_en_calc_err_r;
    reg         mss_fab_mst3_clk_en_chk_err_r;

    assign      mss_fab_mst3_clk_en_calc_status = {5'b0, mss_fab_mst3_clk_en_chk_err_r,
                                                    mss_fab_mst3_clk_en_calc_err_r,
                                                    mss_fab_mst3_clk_en_calc_done_r};

    // mss_fab_mst3_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_mst3_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_mst3_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst3_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst3_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_mst3_clk_en_calc_done_r <= 1'b0;
              mss_fab_mst3_clk_en_calc_err_r  <= 1'b0;
              mss_fab_mst3_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_mst3_clk_en_calc_done_r <= mss_fab_mst3_clk_en_calc_done;
              mss_fab_mst3_clk_en_calc_err_r  <= mss_fab_mst3_clk_en_calc_err;
              mss_fab_mst3_clk_en_chk_err_r   <= mss_fab_mst3_clk_en_chk_err;
           end
     end //} mss_fab_mst3_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_slv0_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         mss_fab_slv0_clk_en_calc_req;
    wire        mss_fab_slv0_clk_en_calc_ack;
    reg         mss_fab_slv0_clk_en_calc_done;
    wire        mss_fab_slv0_clk_en_calc_err;

    // mss_fab_slv0_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv0_clk_en_calc_req_PROC //{
         if (!rst_b)
            mss_fab_slv0_clk_en_calc_req <= 1'b0;
         else if (mss_fab_slv0_clk_en_calc_req & mss_fab_slv0_clk_en_calc_ack)
            mss_fab_slv0_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            mss_fab_slv0_clk_en_calc_req <= 1'b1;
      end //} mss_fab_slv0_clk_en_calc_req_PROC

    // mss_fab_slv0_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv0_clk_en_calc_done_PROC //{
         if (!rst_b)
            mss_fab_slv0_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            mss_fab_slv0_clk_en_calc_done <= 1'b0;
         else if (mss_fab_slv0_clk_en_calc_req & mss_fab_slv0_clk_en_calc_ack)
            mss_fab_slv0_clk_en_calc_done <= 1'b1;
     end //} mss_fab_slv0_clk_en_calc_done_PROC

    // mss_fab_slv0_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_mss_fab_slv0_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (mss_clk_div_reg),
                                                              .ratio_in_B   (clk_div_reg),
                                                              .ratio_req    (mss_fab_slv0_clk_en_calc_req),
                                                              .ratio_ack    (mss_fab_slv0_clk_en_calc_ack),
                                                              .ratio_err    (mss_fab_slv0_clk_en_calc_err),
                                                              .ratio_result (mss_fab_slv0_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* mss_fab_slv0_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_slv0_clk_en_chk_err = 1'b0;

    // mss_fab_slv0_clk_en_calc_status
    wire [7:0]  mss_fab_slv0_clk_en_calc_status;
    reg         mss_fab_slv0_clk_en_calc_done_r;
    reg         mss_fab_slv0_clk_en_calc_err_r;
    reg         mss_fab_slv0_clk_en_chk_err_r;

    assign      mss_fab_slv0_clk_en_calc_status = {5'b0, mss_fab_slv0_clk_en_chk_err_r,
                                                    mss_fab_slv0_clk_en_calc_err_r,
                                                    mss_fab_slv0_clk_en_calc_done_r};

    // mss_fab_slv0_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv0_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_slv0_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv0_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv0_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_slv0_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv0_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv0_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_slv0_clk_en_calc_done_r <= mss_fab_slv0_clk_en_calc_done;
              mss_fab_slv0_clk_en_calc_err_r  <= mss_fab_slv0_clk_en_calc_err;
              mss_fab_slv0_clk_en_chk_err_r   <= mss_fab_slv0_clk_en_chk_err;
           end
     end //} mss_fab_slv0_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_slv1_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         mss_fab_slv1_clk_en_calc_req;
    wire        mss_fab_slv1_clk_en_calc_ack;
    reg         mss_fab_slv1_clk_en_calc_done;
    wire        mss_fab_slv1_clk_en_calc_err;

    // mss_fab_slv1_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv1_clk_en_calc_req_PROC //{
         if (!rst_b)
            mss_fab_slv1_clk_en_calc_req <= 1'b0;
         else if (mss_fab_slv1_clk_en_calc_req & mss_fab_slv1_clk_en_calc_ack)
            mss_fab_slv1_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            mss_fab_slv1_clk_en_calc_req <= 1'b1;
      end //} mss_fab_slv1_clk_en_calc_req_PROC

    // mss_fab_slv1_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv1_clk_en_calc_done_PROC //{
         if (!rst_b)
            mss_fab_slv1_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            mss_fab_slv1_clk_en_calc_done <= 1'b0;
         else if (mss_fab_slv1_clk_en_calc_req & mss_fab_slv1_clk_en_calc_ack)
            mss_fab_slv1_clk_en_calc_done <= 1'b1;
     end //} mss_fab_slv1_clk_en_calc_done_PROC

    // mss_fab_slv1_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_mss_fab_slv1_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (mss_clk_div_reg),
                                                              .ratio_in_B   (clk_div_reg),
                                                              .ratio_req    (mss_fab_slv1_clk_en_calc_req),
                                                              .ratio_ack    (mss_fab_slv1_clk_en_calc_ack),
                                                              .ratio_err    (mss_fab_slv1_clk_en_calc_err),
                                                              .ratio_result (mss_fab_slv1_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* mss_fab_slv1_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_slv1_clk_en_chk_err = 1'b0;

    // mss_fab_slv1_clk_en_calc_status
    wire [7:0]  mss_fab_slv1_clk_en_calc_status;
    reg         mss_fab_slv1_clk_en_calc_done_r;
    reg         mss_fab_slv1_clk_en_calc_err_r;
    reg         mss_fab_slv1_clk_en_chk_err_r;

    assign      mss_fab_slv1_clk_en_calc_status = {5'b0, mss_fab_slv1_clk_en_chk_err_r,
                                                    mss_fab_slv1_clk_en_calc_err_r,
                                                    mss_fab_slv1_clk_en_calc_done_r};

    // mss_fab_slv1_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv1_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_slv1_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv1_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv1_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_slv1_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv1_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv1_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_slv1_clk_en_calc_done_r <= mss_fab_slv1_clk_en_calc_done;
              mss_fab_slv1_clk_en_calc_err_r  <= mss_fab_slv1_clk_en_calc_err;
              mss_fab_slv1_clk_en_chk_err_r   <= mss_fab_slv1_clk_en_chk_err;
           end
     end //} mss_fab_slv1_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_slv2_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    reg         mss_fab_slv2_clk_en_calc_req;
    wire        mss_fab_slv2_clk_en_calc_ack;
    reg         mss_fab_slv2_clk_en_calc_done;
    wire        mss_fab_slv2_clk_en_calc_err;

    // mss_fab_slv2_clk_en_calc_req
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv2_clk_en_calc_req_PROC //{
         if (!rst_b)
            mss_fab_slv2_clk_en_calc_req <= 1'b0;
         else if (mss_fab_slv2_clk_en_calc_req & mss_fab_slv2_clk_en_calc_ack)
            mss_fab_slv2_clk_en_calc_req <= 1'b0;
         else if (dfc_ratio_calc_start)
            mss_fab_slv2_clk_en_calc_req <= 1'b1;
      end //} mss_fab_slv2_clk_en_calc_req_PROC

    // mss_fab_slv2_clk_en_calc_done
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv2_clk_en_calc_done_PROC //{
         if (!rst_b)
            mss_fab_slv2_clk_en_calc_done <= 1'b0;
         else if (store_calc_status)
            mss_fab_slv2_clk_en_calc_done <= 1'b0;
         else if (mss_fab_slv2_clk_en_calc_req & mss_fab_slv2_clk_en_calc_ack)
            mss_fab_slv2_clk_en_calc_done <= 1'b1;
     end //} mss_fab_slv2_clk_en_calc_done_PROC

    // mss_fab_slv2_clk_en_ratio run-time calculation logic
    alb_mss_clkctrl_ratio_calc u_mss_fab_slv2_clk_en_ratio_calc (
                                                              .clk          (clkctrl_clk),
                                                              .rst_a        (~rst_b),
                                                              .ratio_in_A   (mss_clk_div_reg),
                                                              .ratio_in_B   (clk_div_reg),
                                                              .ratio_req    (mss_fab_slv2_clk_en_calc_req),
                                                              .ratio_ack    (mss_fab_slv2_clk_en_calc_ack),
                                                              .ratio_err    (mss_fab_slv2_clk_en_calc_err),
                                                              .ratio_result (mss_fab_slv2_clk_en_ratio)
                                                             );

    /***********************************************************/
    /* mss_fab_slv2_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_slv2_clk_en_chk_err = 1'b0;

    // mss_fab_slv2_clk_en_calc_status
    wire [7:0]  mss_fab_slv2_clk_en_calc_status;
    reg         mss_fab_slv2_clk_en_calc_done_r;
    reg         mss_fab_slv2_clk_en_calc_err_r;
    reg         mss_fab_slv2_clk_en_chk_err_r;

    assign      mss_fab_slv2_clk_en_calc_status = {5'b0, mss_fab_slv2_clk_en_chk_err_r,
                                                    mss_fab_slv2_clk_en_calc_err_r,
                                                    mss_fab_slv2_clk_en_calc_done_r};

    // mss_fab_slv2_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv2_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_slv2_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv2_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv2_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_slv2_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv2_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv2_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_slv2_clk_en_calc_done_r <= mss_fab_slv2_clk_en_calc_done;
              mss_fab_slv2_clk_en_calc_err_r  <= mss_fab_slv2_clk_en_calc_err;
              mss_fab_slv2_clk_en_chk_err_r   <= mss_fab_slv2_clk_en_chk_err;
           end
     end //} mss_fab_slv2_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_slv3_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    wire        mss_fab_slv3_clk_en_calc_req  = 1'b0;
    wire        mss_fab_slv3_clk_en_calc_ack  = 1'b0;
    wire        mss_fab_slv3_clk_en_calc_done = 1'b1;
    wire        mss_fab_slv3_clk_en_calc_err  = 1'b0;
    assign      mss_fab_slv3_clk_en_ratio     = 8'h1;

    /***********************************************************/
    /* mss_fab_slv3_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_slv3_clk_en_chk_err = 1'b0;

    // mss_fab_slv3_clk_en_calc_status
    wire [7:0]  mss_fab_slv3_clk_en_calc_status;
    reg         mss_fab_slv3_clk_en_calc_done_r;
    reg         mss_fab_slv3_clk_en_calc_err_r;
    reg         mss_fab_slv3_clk_en_chk_err_r;

    assign      mss_fab_slv3_clk_en_calc_status = {5'b0, mss_fab_slv3_clk_en_chk_err_r,
                                                    mss_fab_slv3_clk_en_calc_err_r,
                                                    mss_fab_slv3_clk_en_calc_done_r};

    // mss_fab_slv3_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv3_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_slv3_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv3_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv3_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_slv3_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv3_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv3_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_slv3_clk_en_calc_done_r <= mss_fab_slv3_clk_en_calc_done;
              mss_fab_slv3_clk_en_calc_err_r  <= mss_fab_slv3_clk_en_calc_err;
              mss_fab_slv3_clk_en_chk_err_r   <= mss_fab_slv3_clk_en_chk_err;
           end
     end //} mss_fab_slv3_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_slv4_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    wire        mss_fab_slv4_clk_en_calc_req  = 1'b0;
    wire        mss_fab_slv4_clk_en_calc_ack  = 1'b0;
    wire        mss_fab_slv4_clk_en_calc_done = 1'b1;
    wire        mss_fab_slv4_clk_en_calc_err  = 1'b0;
    assign      mss_fab_slv4_clk_en_ratio     = 8'h1;

    /***********************************************************/
    /* mss_fab_slv4_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_slv4_clk_en_chk_err = 1'b0;

    // mss_fab_slv4_clk_en_calc_status
    wire [7:0]  mss_fab_slv4_clk_en_calc_status;
    reg         mss_fab_slv4_clk_en_calc_done_r;
    reg         mss_fab_slv4_clk_en_calc_err_r;
    reg         mss_fab_slv4_clk_en_chk_err_r;

    assign      mss_fab_slv4_clk_en_calc_status = {5'b0, mss_fab_slv4_clk_en_chk_err_r,
                                                    mss_fab_slv4_clk_en_calc_err_r,
                                                    mss_fab_slv4_clk_en_calc_done_r};

    // mss_fab_slv4_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv4_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_slv4_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv4_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv4_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_slv4_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv4_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv4_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_slv4_clk_en_calc_done_r <= mss_fab_slv4_clk_en_calc_done;
              mss_fab_slv4_clk_en_calc_err_r  <= mss_fab_slv4_clk_en_calc_err;
              mss_fab_slv4_clk_en_chk_err_r   <= mss_fab_slv4_clk_en_chk_err;
           end
     end //} mss_fab_slv4_clk_en_calc_done_r_PROC

    /***********************************************************/
    /* mss_fab_slv5_clk_en: clock ratio run-time calculation  */
    /***********************************************************/
    wire        mss_fab_slv5_clk_en_calc_req  = 1'b0;
    wire        mss_fab_slv5_clk_en_calc_ack  = 1'b0;
    wire        mss_fab_slv5_clk_en_calc_done = 1'b1;
    wire        mss_fab_slv5_clk_en_calc_err  = 1'b0;
    assign      mss_fab_slv5_clk_en_ratio     = 8'h1;

    /***********************************************************/
    /* mss_fab_slv5_clk_en: clock ratio run-time checking  */
    /***********************************************************/
    wire        mss_fab_slv5_clk_en_chk_err = 1'b0;

    // mss_fab_slv5_clk_en_calc_status
    wire [7:0]  mss_fab_slv5_clk_en_calc_status;
    reg         mss_fab_slv5_clk_en_calc_done_r;
    reg         mss_fab_slv5_clk_en_calc_err_r;
    reg         mss_fab_slv5_clk_en_chk_err_r;

    assign      mss_fab_slv5_clk_en_calc_status = {5'b0, mss_fab_slv5_clk_en_chk_err_r,
                                                    mss_fab_slv5_clk_en_calc_err_r,
                                                    mss_fab_slv5_clk_en_calc_done_r};

    // mss_fab_slv5_clk_en_calc_done_r/_calc_err_r
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: mss_fab_slv5_clk_en_calc_done_r_PROC //{
         if (!rst_b)
           begin
              mss_fab_slv5_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv5_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv5_clk_en_chk_err_r   <= 1'b0;
      end
         else if (clr_calc_status)
           begin
              mss_fab_slv5_clk_en_calc_done_r <= 1'b0;
              mss_fab_slv5_clk_en_calc_err_r  <= 1'b0;
              mss_fab_slv5_clk_en_chk_err_r   <= 1'b0;
      end
         else if (store_calc_status)
           begin
              mss_fab_slv5_clk_en_calc_done_r <= mss_fab_slv5_clk_en_calc_done;
              mss_fab_slv5_clk_en_calc_err_r  <= mss_fab_slv5_clk_en_calc_err;
              mss_fab_slv5_clk_en_chk_err_r   <= mss_fab_slv5_clk_en_chk_err;
           end
     end //} mss_fab_slv5_clk_en_calc_done_r_PROC


    /***********************************************************/
    /* global calculation status                               */
    /***********************************************************/
    // all ratio calculation done
    assign      dfc_ratio_calc_done =
                                       iccm_ahb_clk_en_calc_done &
                                       dccm_ahb_clk_en_calc_done &
                                       mmio_ahb_clk_en_calc_done &
                                       mss_fab_mst0_clk_en_calc_done &
                                       mss_fab_mst1_clk_en_calc_done &
                                       mss_fab_mst2_clk_en_calc_done &
                                       mss_fab_mst3_clk_en_calc_done &
                                       mss_fab_slv0_clk_en_calc_done &
                                       mss_fab_slv1_clk_en_calc_done &
                                       mss_fab_slv2_clk_en_calc_done &
                                       mss_fab_slv3_clk_en_calc_done &
                                       mss_fab_slv4_clk_en_calc_done &
                                       mss_fab_slv5_clk_en_calc_done ;

    // ratio calc run-time error
    assign      dfc_ratio_calc_err =
                                       iccm_ahb_clk_en_calc_err |
                                       dccm_ahb_clk_en_calc_err |
                                       mmio_ahb_clk_en_calc_err |
                                       mss_fab_mst0_clk_en_calc_err |
                                       mss_fab_mst1_clk_en_calc_err |
                                       mss_fab_mst2_clk_en_calc_err |
                                       mss_fab_mst3_clk_en_calc_err |
                                       mss_fab_slv0_clk_en_calc_err |
                                       mss_fab_slv1_clk_en_calc_err |
                                       mss_fab_slv2_clk_en_calc_err |
                                       mss_fab_slv3_clk_en_calc_err |
                                       mss_fab_slv4_clk_en_calc_err |
                                       mss_fab_slv5_clk_en_calc_err ;

    // ratio check run-time error
    assign      dfc_ratio_chk_err =
                                       iccm_ahb_clk_en_chk_err |
                                       dccm_ahb_clk_en_chk_err |
                                       mmio_ahb_clk_en_chk_err |
                                       mss_fab_mst0_clk_en_chk_err |
                                       mss_fab_mst1_clk_en_chk_err |
                                       mss_fab_mst2_clk_en_chk_err |
                                       mss_fab_mst3_clk_en_chk_err |
                                       mss_fab_slv0_clk_en_chk_err |
                                       mss_fab_slv1_clk_en_chk_err |
                                       mss_fab_slv2_clk_en_chk_err |
                                       mss_fab_slv3_clk_en_chk_err |
                                       mss_fab_slv4_clk_en_chk_err |
                                       mss_fab_slv5_clk_en_chk_err ;

    // ratio calc error in MSS_CLKCTRL_CFG_CTRL
    assign      dfc_calc_err =
                                       iccm_ahb_clk_en_calc_err_r |
                                       dccm_ahb_clk_en_calc_err_r |
                                       mmio_ahb_clk_en_calc_err_r |
                                       mss_fab_mst0_clk_en_calc_err_r |
                                       mss_fab_mst1_clk_en_calc_err_r |
                                       mss_fab_mst2_clk_en_calc_err_r |
                                       mss_fab_mst3_clk_en_calc_err_r |
                                       mss_fab_slv0_clk_en_calc_err_r |
                                       mss_fab_slv1_clk_en_calc_err_r |
                                       mss_fab_slv2_clk_en_calc_err_r |
                                       mss_fab_slv3_clk_en_calc_err_r |
                                       mss_fab_slv4_clk_en_calc_err_r |
                                       mss_fab_slv5_clk_en_calc_err_r ;

    // ratio check error in MSS_CLKCTRL_CFG_CTRL
    assign      dfc_chk_err =
                                       iccm_ahb_clk_en_chk_err_r |
                                       dccm_ahb_clk_en_chk_err_r |
                                       mmio_ahb_clk_en_chk_err_r |
                                       mss_fab_mst0_clk_en_chk_err_r |
                                       mss_fab_mst1_clk_en_chk_err_r |
                                       mss_fab_mst2_clk_en_chk_err_r |
                                       mss_fab_mst3_clk_en_chk_err_r |
                                       mss_fab_slv0_clk_en_chk_err_r |
                                       mss_fab_slv1_clk_en_chk_err_r |
                                       mss_fab_slv2_clk_en_chk_err_r |
                                       mss_fab_slv3_clk_en_chk_err_r |
                                       mss_fab_slv4_clk_en_chk_err_r |
                                       mss_fab_slv5_clk_en_chk_err_r ;

    /**************************************************/
    /* clock stop req/ack handshaking                 */
    /**************************************************/
    wire        dfc_clk_stop_ack_dummy = 1'b1;
    assign      dfc_clk_stop_ack =
                                    clk_stop_ack &
                                    wdt_clk_stop_ack &
                                    mss_clk_stop_ack &
                                    dfc_clk_stop_ack_dummy;

    assign dfc_clk_stop_done = dfc_clk_stop_req & dfc_clk_stop_ack;

    always @(posedge clkctrl_clk or negedge rst_b)
      begin: dfc_clk_stop_req_PROC //{
         if (!rst_b)
            dfc_clk_stop_req <= 1'b0;
         else if (dfc_clk_stop_done)
            dfc_clk_stop_req <= 1'b0;
         else if (dfc_clk_stop_start)
            dfc_clk_stop_req <= 1'b1;
     end //} dfc_clk_stop_req_PROC

   //-----------------------------------------------------------
   // APB Programming Interface
   //-----------------------------------------------------------
     // MSS_CLKCTRL Registers Read
     always @(posedge clkctrl_clk or negedge rst_b)
       begin : apb_read_PROC // {
          if (!rst_b)
            begin // {
               i_rdata_r <= 32'h0000000;
            end // }
          else if (mss_clkctrl_sel && !mss_clkctrl_enable && !mss_clkctrl_write)
            begin // {
             // read
              case (mss_clkctrl_addr)
                10'd0 : i_rdata_r <= {24'h0, mss_clkctrl_cfg_ctrl};
                10'd1 : i_rdata_r <= {24'h0, clk_div_reg};
                10'd2 : i_rdata_r <= {24'h0, wdt_clk_div_reg};
                10'd3 : i_rdata_r <= {24'h0, mss_clk_div_reg};
                10'd4 : i_rdata_r <= {24'h0, iccm_ahb_clk_en_ratio_r};     // read only
                10'd5 : i_rdata_r <= {24'h0, iccm_ahb_clk_en_calc_status}; // read only
                10'd6 : i_rdata_r <= {24'h0, dccm_ahb_clk_en_ratio_r};     // read only
                10'd7 : i_rdata_r <= {24'h0, dccm_ahb_clk_en_calc_status}; // read only
                10'd8 : i_rdata_r <= {24'h0, mmio_ahb_clk_en_ratio_r};     // read only
                10'd9 : i_rdata_r <= {24'h0, mmio_ahb_clk_en_calc_status}; // read only
                10'd10 : i_rdata_r <= {24'h0, mss_fab_mst0_clk_en_ratio_r};     // read only
                10'd11 : i_rdata_r <= {24'h0, mss_fab_mst0_clk_en_calc_status}; // read only
                10'd12 : i_rdata_r <= {24'h0, mss_fab_mst1_clk_en_ratio_r};     // read only
                10'd13 : i_rdata_r <= {24'h0, mss_fab_mst1_clk_en_calc_status}; // read only
                10'd14 : i_rdata_r <= {24'h0, mss_fab_mst2_clk_en_ratio_r};     // read only
                10'd15 : i_rdata_r <= {24'h0, mss_fab_mst2_clk_en_calc_status}; // read only
                10'd16 : i_rdata_r <= {24'h0, mss_fab_mst3_clk_en_ratio_r};     // read only
                10'd17 : i_rdata_r <= {24'h0, mss_fab_mst3_clk_en_calc_status}; // read only
                10'd18 : i_rdata_r <= {24'h0, mss_fab_slv0_clk_en_ratio_r};     // read only
                10'd19 : i_rdata_r <= {24'h0, mss_fab_slv0_clk_en_calc_status}; // read only
                10'd20 : i_rdata_r <= {24'h0, mss_fab_slv1_clk_en_ratio_r};     // read only
                10'd21 : i_rdata_r <= {24'h0, mss_fab_slv1_clk_en_calc_status}; // read only
                10'd22 : i_rdata_r <= {24'h0, mss_fab_slv2_clk_en_ratio_r};     // read only
                10'd23 : i_rdata_r <= {24'h0, mss_fab_slv2_clk_en_calc_status}; // read only
                10'd24 : i_rdata_r <= {24'h0, mss_fab_slv3_clk_en_ratio_r};     // read only
                10'd25 : i_rdata_r <= {24'h0, mss_fab_slv3_clk_en_calc_status}; // read only
                10'd26 : i_rdata_r <= {24'h0, mss_fab_slv4_clk_en_ratio_r};     // read only
                10'd27 : i_rdata_r <= {24'h0, mss_fab_slv4_clk_en_calc_status}; // read only
                10'd28 : i_rdata_r <= {24'h0, mss_fab_slv5_clk_en_ratio_r};     // read only
                10'd29 : i_rdata_r <= {24'h0, mss_fab_slv5_clk_en_calc_status}; // read only
                10'd30 : i_rdata_r <= nmi_counter;
                default : i_rdata_r <= 32'h0;
              endcase // case (mss_clkctrl_addr)
            end // }
       end // } apb_read_PROC

     // MSS_CLKCTRL_xxx_DIV registers write
     always @(posedge clkctrl_clk or negedge rst_b)
       begin : apb_write_PROC // {
          if (!rst_b)
            begin // {
               clk_div_reg <= 8'd1;
               wdt_clk_div_reg <= 8'd1;
               mss_clk_div_reg <= 8'd1;
            end // }
          else if (mss_clkctrl_sel & mss_clkctrl_enable & mss_clkctrl_write & (~dfc_start))
            begin // {
              case (mss_clkctrl_addr)
                10'd1 : clk_div_reg <= ((mss_clkctrl_wdata[7:0]==8'b0) ? 8'b1 : mss_clkctrl_wdata[7:0]);  //clock div can't be 0
                10'd2 : wdt_clk_div_reg <= ((mss_clkctrl_wdata[7:0]==8'b0) ? 8'b1 : mss_clkctrl_wdata[7:0]);  //clock div can't be 0
                10'd3 : mss_clk_div_reg <= ((mss_clkctrl_wdata[7:0]==8'b0) ? 8'b1 : mss_clkctrl_wdata[7:0]);  //clock div can't be 0
              endcase // case (mss_clkctrl_addr)
            end // }
       end // } apb_write_PROC

    // MSS_CLKCTRL_CFG_CTRL register write
    assign mss_clkctrl_cfg_ctrl = {5'b0, dfc_chk_err, dfc_calc_err, dfc_start};

    always @(posedge clkctrl_clk or negedge rst_b)
      begin: apb_cfg_action_PROC // {
         if (!rst_b)
           begin
              dfc_start <= 1'b0;
          end
         else if (clk_rst_cnt == 5'hF)
              dfc_start <= 1'b1;
         else if (dfc_clk_align_done | go2idle_calc_err)
           begin
              dfc_start <= 1'b0;
              end
         else if (mss_clkctrl_sel && mss_clkctrl_enable && mss_clkctrl_write
                  && (mss_clkctrl_addr == 10'd0) && (~dfc_start))
           begin //write to CFG_CTRL reg
              dfc_start <= mss_clkctrl_wdata[0];
              end
      end // } apb_cfg_action_PROC

    // MSS_CLKCTRL_NMI_COUNTER register write
    assign nmi_trigger = mss_clkctrl_sel && mss_clkctrl_enable && mss_clkctrl_write
                         && (mss_clkctrl_addr == 10'd30);
    always @(posedge clkctrl_clk or negedge rst_b)
      begin: apb_nmi_counter_PROC // {
         if (!rst_b)
           begin
              nmi_counter <= 32'b0;
          end
         else if (nmi_trigger == 1'b1)
           begin //write to NMI_COUNTER reg
              nmi_counter <= mss_clkctrl_wdata;
              end
      end // } apb_nmi_counter_PROC


endmodule // alb_mss_clkctrl



module alb_mss_clkctrl_clkgen (input       clk_in,
                               input       rst_b,
                               input [7:0] div_cof_in,
                               input       clk_in_align,
                               input       clk_stop_req,
                               output reg  clk_stop_ack,
                               input       clk_stop_rdyin,
                               output      clk_stop_rdyout,
                               output      clk_enable,
                               output      clk_out);

    // global clock counter counting ref_clk (clkctrl_clk)
    reg [7:0] clk_div_cnt;

    wire   count_last = (clk_div_cnt == (div_cof_in - 1));
    assign clk_enable = count_last & (~clk_stop_ack) & (~clk_in_align);
    assign clk_stop_rdyout = count_last;

    always @ (posedge clk_in or negedge rst_b)
      begin: clkgen_div_cnt_PROC // {
         if (rst_b == 0)
            clk_div_cnt <= 8'h0;
         else if (count_last | clk_stop_ack | clk_in_align)
            clk_div_cnt <= 8'h0;
        else
            clk_div_cnt <= clk_div_cnt + 1;
      end // }

    always @ (posedge clk_in or negedge rst_b)
      begin: clk_stop_ack_PROC // {
         if (rst_b == 0)
            clk_stop_ack <= 1'b0;
         else if (~clk_stop_req)
            clk_stop_ack <= 1'b0;
         else if (clk_stop_req & clk_stop_rdyin & count_last)
            clk_stop_ack <= 1'b1;
      end // }

    alb_mss_clkctrl_clkgate u_alb_mss_clkctrl_clkgate (
                                                       .clk_in       (clk_in     ),
                                                       .rst_a        (~rst_b     ),
                                                       .clock_enable (clk_enable ),
                                                       .clk_out      (clk_out    )
                          );

endmodule // alb_mss_clkctrl_clkgen


module alb_mss_clkctrl_clken_gen (input       clk_in,
                                  input       clk_en_in,
                                  input       rst_b,
                                  input [7:0] ratio,
                                  input       clk_in_align,
                                  output      clk_en_out);

    // local clock counter counting comp_clk
    reg [7:0] clk_div_cnt;

    wire   count_last = (clk_div_cnt == (ratio - 1));
    assign clk_en_out = count_last & (~clk_in_align);

    always @ (posedge clk_in or negedge rst_b)
      begin: clken_div_cnt_PROC // {
         if (rst_b == 0)
            clk_div_cnt <= 8'h0;
         else if ((clk_en_in & count_last) | clk_in_align)
            clk_div_cnt <= 8'h0;
         else if (clk_en_in)
            clk_div_cnt <= clk_div_cnt + 1;
      end // }

endmodule // alb_mss_clkctrl_clken_gen


module alb_mss_clkctrl_clkgate (input   clk_in,
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

endmodule // alb_mss_clkctrl_clkgate

