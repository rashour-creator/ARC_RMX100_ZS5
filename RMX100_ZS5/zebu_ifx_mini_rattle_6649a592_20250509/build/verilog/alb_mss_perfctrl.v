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
//   alb_mss_perfctrl: Latency control unit and performance monitor
//
// ===========================================================================
//
// Description:
//  Verilog module defining a Bus latency controller
//  Just a GPIO driving the latency inputs to all
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_mss_perfctrl.vpp
//
// ==========================================================================
`timescale 1ns/10ps
`include "alb_mss_perfctrl_defines.v"

// check <  > < 2 > 0

// mcnt: 4
module alb_mss_perfctrl(input               mss_clk,
                        input               rst_b,
                        input               mss_perfctrl_sel,
                        input               mss_perfctrl_enable,
                        input               mss_perfctrl_write,
                        input   [12:2]      mss_perfctrl_addr,
                        input   [31:0]      mss_perfctrl_wdata,
                        input   [3:0]       mss_perfctrl_wstrb,
                        output  [31:0]      mss_perfctrl_rdata,
                        output              mss_perfctrl_slverr,
                        output              mss_perfctrl_ready,
                        output  [4*12-1:0]  mss_fab_cfg_lat_w,
                        output  [4*12-1:0]  mss_fab_cfg_lat_r,
                        output  [4*10-1:0]  mss_fab_cfg_wr_bw,
                        output  [4*10-1:0]  mss_fab_cfg_rd_bw,
                        input   [4-1:0]    mss_fab_perf_awf,
                        input   [4-1:0]    mss_fab_perf_arf,
                        input   [4-1:0]    mss_fab_perf_aw,
                        input   [4-1:0]    mss_fab_perf_ar,
                        input   [4-1:0]    mss_fab_perf_w,
                        input   [4-1:0]    mss_fab_perf_wl,
                        input   [4-1:0]    mss_fab_perf_r,
                        input   [4-1:0]    mss_fab_perf_rl,
                        input   [4-1:0]    mss_fab_perf_b,
                        output  [1*10-1:0]  mss_mem_cfg_lat_w,
                        output  [1*10-1:0]  mss_mem_cfg_lat_r,

                        input   [1-1:0]     mss_mem_perf_awf,
                        input   [1-1:0]     mss_mem_perf_arf,
                        input   [1-1:0]     mss_mem_perf_aw,
                        input   [1-1:0]     mss_mem_perf_ar,
                        input   [1-1:0]     mss_mem_perf_w,
                        input   [1-1:0]     mss_mem_perf_wl,
                        input   [1-1:0]     mss_mem_perf_r,
                        input   [1-1:0]     mss_mem_perf_rl,
                        input   [1-1:0]     mss_mem_perf_b,
                        output              mss_perfctrl_dummy);

    // local parameters
    localparam max_fab_lat_masters = 4 < 32 ? 4 : 32;
    localparam mem_lat_regions = 1; // number of memory regions
    localparam glob_comp_version      = 32'h00020000; // Set to version 2.0
    localparam glob_comp_type         = 32'h41443F3F; // Set to AD?? (ARC Development ??)
    // local wires
    reg                                   i_ready_r;
    reg                                   i_ready_d;
    reg [31:0]                            i_rdata_r;
    reg [31:0]                            i_rdata_d;

    reg                                   i_mss_cfg_lat_sel;
    reg                                   i_mss_cfg_wr_bw_sel;
    reg                                   i_mss_cfg_rd_bw_sel;
    reg                                   i_mss_cnt_aw_sel;
    reg                                   i_mss_cnt_w_sel;
    reg                                   i_mss_cnt_aw_lat_sel;
    reg                                   i_mss_cnt_wf_lat_sel;
    reg                                   i_mss_cnt_wl_lat_sel;
    reg                                   i_mss_cnt_b_lat_sel;
    reg                                   i_mss_cnt_ar_sel;
    reg                                   i_mss_cnt_r_sel;
    reg                                   i_mss_cnt_ar_lat_sel;
    reg                                   i_mss_cnt_rf_lat_sel;
    reg                                   i_mss_cnt_rl_lat_sel;
    reg                                   i_mss_glob_sel;

    reg [63:0]                            i_mss_tick_count_r;
    reg                                   i_mss_perf_reset_d;
    reg                                   i_mss_perf_reset_r;
    reg                                   i_mss_perf_running_d;
    reg                                   i_mss_perf_running_r;

    wire [4-1:0]   i_mss_fab_perf_wf;
    wire [4-1:0]   i_mss_fab_perf_rf;
    reg [4-1:0]    i_mss_fab_perf_wl_r;
    reg [4-1:0]    i_mss_fab_perf_rl_r;
    reg [4-1:0]    i_mss_fab_lat_sel;
    reg [4*12-1:0]  i_mss_fab_cfg_lat_wr_r;
    reg [4*12-1:0]  i_mss_fab_cfg_lat_rd_r;
    reg [4*10-1:0]  i_mss_fab_cfg_wr_bw_r;
    reg [4*10-1:0]  i_mss_fab_cfg_rd_bw_r;
    reg [4*12-1:0]  i_mss_fab_cfg_lat_wr_d;
    reg [4*12-1:0]  i_mss_fab_cfg_lat_rd_d;
    reg [4*10-1:0]  i_mss_fab_cfg_wr_bw_d;
    reg [4*10-1:0]  i_mss_fab_cfg_rd_bw_d;
    reg [4*64-1:0] i_mss_fab_cnt_aw_d;
    reg [4*64-1:0] i_mss_fab_cnt_aw_r;
    reg [4*64-1:0] i_mss_fab_cnt_w_d;
    reg [4*64-1:0] i_mss_fab_cnt_w_r;
    reg [4*64-1:0] i_mss_fab_cnt_ar_d;
    reg [4*64-1:0] i_mss_fab_cnt_ar_r;
    reg [4*64-1:0] i_mss_fab_cnt_r_d;
    reg [4*64-1:0] i_mss_fab_cnt_r_r;
    reg [4*64-1:0] i_mss_fab_cnt_aw_lat_d;
    reg [4*64-1:0] i_mss_fab_cnt_aw_lat_r;
    reg [4*64-1:0] i_mss_fab_cnt_ar_lat_d;
    reg [4*64-1:0] i_mss_fab_cnt_ar_lat_r;
    reg [4-1:0]    i_mss_fab_st_aw_lat_d;
    reg [4-1:0]    i_mss_fab_st_aw_lat_r;
    reg [4-1:0]    i_mss_fab_st_ar_lat_d;
    reg [4-1:0]    i_mss_fab_st_ar_lat_r;
    reg [4*5-1:0]  i_mss_fab_inc_wf_lat_d;
    reg [4*5-1:0]  i_mss_fab_inc_wf_lat_r;
    reg [4*5-1:0]  i_mss_fab_inc_wl_lat_d;
    reg [4*5-1:0]  i_mss_fab_inc_wl_lat_r;
    reg [4*5-1:0]  i_mss_fab_inc_b_lat_d;
    reg [4*5-1:0]  i_mss_fab_inc_b_lat_r;
    reg [4*5-1:0]  i_mss_fab_inc_rf_lat_d;
    reg [4*5-1:0]  i_mss_fab_inc_rf_lat_r;
    reg [4*5-1:0]  i_mss_fab_inc_rl_lat_d;
    reg [4*5-1:0]  i_mss_fab_inc_rl_lat_r;
    reg [4*64-1:0] i_mss_fab_cnt_wf_lat_d;
    reg [4*64-1:0] i_mss_fab_cnt_wf_lat_r;
    reg [4*64-1:0] i_mss_fab_cnt_wl_lat_d;
    reg [4*64-1:0] i_mss_fab_cnt_wl_lat_r;
    reg [4*64-1:0] i_mss_fab_cnt_b_lat_d;
    reg [4*64-1:0] i_mss_fab_cnt_b_lat_r;
    reg [4*64-1:0] i_mss_fab_cnt_rf_lat_d;
    reg [4*64-1:0] i_mss_fab_cnt_rf_lat_r;
    reg [4*64-1:0] i_mss_fab_cnt_rl_lat_d;
    reg [4*64-1:0] i_mss_fab_cnt_rl_lat_r;
    reg [1-1:0]                    i_mss_mem_lat_sel;
    wire [1-1:0]                   i_mss_mem_perf_wf;
    wire [1-1:0]                   i_mss_mem_perf_rf;
    reg [1-1:0]                    i_mss_mem_perf_wl_r;
    reg [1-1:0]                    i_mss_mem_perf_rl_r;
    reg [1*10-1:0]                 i_mss_mem_cfg_lat_rd_r;
    reg [1*10-1:0]                 i_mss_mem_cfg_lat_wr_r;
    reg [1*10-1:0]                 i_mss_mem_cfg_lat_rd_d;
    reg [1*10-1:0]                 i_mss_mem_cfg_lat_wr_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_aw_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_aw_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_w_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_w_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_ar_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_ar_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_r_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_r_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_aw_lat_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_aw_lat_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_ar_lat_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_ar_lat_r;
    reg [1-1:0]                    i_mss_mem_st_aw_lat_d;
    reg [1-1:0]                    i_mss_mem_st_aw_lat_r;
    reg [1-1:0]                    i_mss_mem_st_ar_lat_d;
    reg [1-1:0]                    i_mss_mem_st_ar_lat_r;
    reg [1*5-1:0]                  i_mss_mem_inc_wf_lat_d;
    reg [1*5-1:0]                  i_mss_mem_inc_wf_lat_r;
    reg [1*5-1:0]                  i_mss_mem_inc_wl_lat_d;
    reg [1*5-1:0]                  i_mss_mem_inc_wl_lat_r;
    reg [1*5-1:0]                  i_mss_mem_inc_b_lat_d;
    reg [1*5-1:0]                  i_mss_mem_inc_b_lat_r;
    reg [1*5-1:0]                  i_mss_mem_inc_rf_lat_d;
    reg [1*5-1:0]                  i_mss_mem_inc_rf_lat_r;
    reg [1*5-1:0]                  i_mss_mem_inc_rl_lat_d;
    reg [1*5-1:0]                  i_mss_mem_inc_rl_lat_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_wf_lat_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_wf_lat_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_wl_lat_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_wl_lat_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_b_lat_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_b_lat_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_rf_lat_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_rf_lat_r;
    reg [1*64-1:0]                 i_mss_mem_cnt_rl_lat_d;
    reg [1*64-1:0]                 i_mss_mem_cnt_rl_lat_r;


    // assignments
    assign mss_perfctrl_ready  = i_ready_r;
    assign mss_perfctrl_slverr = 1'b0;
    assign mss_perfctrl_rdata  = i_rdata_r;
    assign mss_fab_cfg_lat_w     = i_mss_fab_cfg_lat_wr_r;
    assign mss_fab_cfg_lat_r     = i_mss_fab_cfg_lat_rd_r;
    assign mss_fab_cfg_wr_bw     = i_mss_fab_cfg_wr_bw_r;
    assign mss_fab_cfg_rd_bw     = i_mss_fab_cfg_rd_bw_r;
    assign i_mss_fab_perf_wf   = mss_fab_perf_w & i_mss_fab_perf_wl_r;
    assign i_mss_fab_perf_rf   = mss_fab_perf_r & i_mss_fab_perf_rl_r;
    assign mss_mem_cfg_lat_w     = i_mss_mem_cfg_lat_wr_r;
    assign mss_mem_cfg_lat_r     = i_mss_mem_cfg_lat_rd_r;

    assign i_mss_mem_perf_wf   = mss_mem_perf_w & i_mss_mem_perf_wl_r;
    assign i_mss_mem_perf_rf   = mss_mem_perf_r & i_mss_mem_perf_rl_r;
    assign mss_perfctrl_dummy  = 1'b0;


    always @*
      begin : stnxt_PROC
          integer i,j;
          // default outputs
          i_rdata_d                 = 32'h00000000;
          // address decoding
          i_mss_cfg_lat_sel         = 1'b0;
          i_mss_cnt_aw_sel          = 1'b0;
          i_mss_cnt_w_sel           = 1'b0;
          i_mss_cnt_aw_lat_sel      = 1'b0;
          i_mss_cnt_wf_lat_sel      = 1'b0;
          i_mss_cnt_wl_lat_sel      = 1'b0;
          i_mss_cnt_b_lat_sel       = 1'b0;
          i_mss_cnt_ar_sel          = 1'b0;
          i_mss_cnt_r_sel           = 1'b0;
          i_mss_cnt_ar_lat_sel      = 1'b0;
          i_mss_cnt_rf_lat_sel      = 1'b0;
          i_mss_cnt_rl_lat_sel      = 1'b0;
          i_mss_perf_running_d      = i_mss_perf_running_r;
          i_mss_perf_reset_d        = 1'b0;
          i_mss_cfg_wr_bw_sel       = 1'b0;
          i_mss_cfg_rd_bw_sel       = 1'b0;
          i_mss_fab_cfg_lat_wr_d       = i_mss_fab_cfg_lat_wr_r;
          i_mss_fab_cfg_lat_rd_d       = i_mss_fab_cfg_lat_rd_r;
          i_mss_fab_cfg_wr_bw_d       = i_mss_fab_cfg_wr_bw_r;
          i_mss_fab_cfg_rd_bw_d       = i_mss_fab_cfg_rd_bw_r;
          i_mss_fab_lat_sel         = {4{1'b0}};

          for (i = 0; i < max_fab_lat_masters; i = i + 1) //maximum master num is 32
              if (!mss_perfctrl_addr[12] & (mss_perfctrl_addr[11:7] == i))
                  i_mss_fab_lat_sel[i] = 1'b1;
          i_mss_mem_cfg_lat_rd_d = i_mss_mem_cfg_lat_rd_r;
          i_mss_mem_cfg_lat_wr_d = i_mss_mem_cfg_lat_wr_r;
          i_mss_mem_lat_sel = {1{1'b0}};

          for (j = 0; j < mem_lat_regions; j = j + 1) // maximum mem region num is 16
             if (mss_perfctrl_addr[12] & !mss_perfctrl_addr[11] & (mss_perfctrl_addr[10:7] == j))
                 i_mss_mem_lat_sel[j] = 1'b1;
          i_mss_glob_sel = (mss_perfctrl_addr[12] & mss_perfctrl_addr[11]); //above 0x1800 offset
          case(mss_perfctrl_addr[6:3])
              4'h0 : i_mss_cfg_lat_sel    = 1'b1; //lat_ctrl(lo,hi)
              4'h1 : i_mss_cnt_aw_sel     = 1'b1; //aw_count(lo,hi)
              4'h2 : i_mss_cnt_w_sel      = 1'b1; //w_count(lo,hi)
              4'h3 : i_mss_cnt_aw_lat_sel = 1'b1; //aw_lat(lo, hi)
              4'h4 : i_mss_cnt_wf_lat_sel = 1'b1; //w_first_lat(lo,hi)
              4'h5 : i_mss_cnt_wl_lat_sel = 1'b1; //w_last_lat(lo,hi)
              4'h6 : i_mss_cnt_b_lat_sel  = 1'b1; //b_lat(lo,hi)
              4'h7 : i_mss_cnt_ar_sel     = 1'b1; //ar_count(lo,hi)
              4'h8 : i_mss_cnt_r_sel      = 1'b1; //r_count(lo,hi)
              4'h9 : i_mss_cnt_ar_lat_sel = 1'b1; //ar_lat(lo,hi)
              4'hA : i_mss_cnt_rf_lat_sel = 1'b1; //r_first_lat(lo,hi)
              4'hB : i_mss_cnt_rl_lat_sel = 1'b1; //r_last_lat(lo,hi)
              4'hC : begin
                     i_mss_cfg_wr_bw_sel  = ~mss_perfctrl_addr[2]; //r_last_lat(lo,hi)
                     i_mss_cfg_rd_bw_sel  = mss_perfctrl_addr[2]; //r_last_lat(lo,hi)
                     end
          endcase

          if (mss_perfctrl_sel && mss_perfctrl_enable) begin
              i_ready_d = 1'b1;
              if (mss_perfctrl_write) begin //write registers
                  for (i = 0; i < 4; i = i + 1)
                  begin
                      i_mss_fab_cfg_lat_rd_d[12*i+:12] = (i_mss_fab_lat_sel[i] & i_mss_cfg_lat_sel) ? mss_perfctrl_wdata[11:0] : i_mss_fab_cfg_lat_rd_r[12*i+:12];
                      i_mss_fab_cfg_lat_wr_d[12*i+:12] = (i_mss_fab_lat_sel[i] & i_mss_cfg_lat_sel) ? mss_perfctrl_wdata[27:16] : i_mss_fab_cfg_lat_wr_r[12*i+:12];
                      i_mss_fab_cfg_wr_bw_d[10*i+:10] = (i_mss_fab_lat_sel[i] & i_mss_cfg_wr_bw_sel) ? mss_perfctrl_wdata[9:0] : i_mss_fab_cfg_wr_bw_r[10*i+:10];
                      i_mss_fab_cfg_rd_bw_d[10*i+:10] = (i_mss_fab_lat_sel[i] & i_mss_cfg_rd_bw_sel) ? mss_perfctrl_wdata[9:0] : i_mss_fab_cfg_rd_bw_r[10*i+:10];
                  end
                  for (j = 0; j < 1; j = j + 1)
                  begin
                      i_mss_mem_cfg_lat_rd_d[10*j+:10] = (i_mss_mem_lat_sel[j] & i_mss_cfg_lat_sel) ? mss_perfctrl_wdata[9:0] : i_mss_mem_cfg_lat_rd_r[10*j+:10];
                      i_mss_mem_cfg_lat_wr_d[10*j+:10] = (i_mss_mem_lat_sel[j] & i_mss_cfg_lat_sel) ? mss_perfctrl_wdata[25:16] : i_mss_mem_cfg_lat_wr_r[10*j+:10];
                  end
                  if (i_mss_glob_sel && (mss_perfctrl_addr[4:2]== 5'h00)) begin //perfctrl_reg_ctrl
                      case(mss_perfctrl_wdata[1:0])
                         2'b01 :  i_mss_perf_running_d = 1'b1; //enable
                         2'b10 :  i_mss_perf_running_d = 1'b0; //disable
                         default: i_mss_perf_running_d = i_mss_perf_running_r;
                      endcase
                      i_mss_perf_reset_d = mss_perfctrl_wdata[2]; //reset
                  end
              end
              else begin //read register
                  for (i = 0; i < 4; i = i + 1)
                      if (i_mss_fab_lat_sel[i])
                          if (mss_perfctrl_addr[2]) begin // MSB 32bit
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_sel     ? i_mss_fab_cnt_aw_r[64*i+32+:32]           : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_w_sel      ? i_mss_fab_cnt_w_r[64*i+32+:32]            : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_lat_sel ? i_mss_fab_cnt_aw_lat_r[64*i+32+:32]       : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wf_lat_sel ? i_mss_fab_cnt_wf_lat_r[64*i+32+:32]       : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wl_lat_sel ? i_mss_fab_cnt_wl_lat_r[64*i+32+:32]       : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_b_lat_sel  ? i_mss_fab_cnt_b_lat_r[64*i+32+:32]        : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_sel     ? i_mss_fab_cnt_ar_r[64*i+32+:32]           : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_r_sel      ? i_mss_fab_cnt_r_r[64*i+32+:32]            : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_lat_sel ? i_mss_fab_cnt_ar_lat_r[64*i+32+:32]       : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rf_lat_sel ? i_mss_fab_cnt_rf_lat_r[64*i+32+:32]       : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rl_lat_sel ? i_mss_fab_cnt_rl_lat_r[64*i+32+:32]       : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cfg_rd_bw_sel    ? {22'h000000, i_mss_fab_cfg_rd_bw_r[10*i+:10]} : 32'h00000000);
                          end
                          else begin //ctrl and LSB 32bit
                              i_rdata_d = i_rdata_d | (i_mss_cfg_lat_sel    ? {4'h0,i_mss_fab_cfg_lat_wr_r[12*i+:12],4'h0,i_mss_fab_cfg_lat_rd_r[12*i+:12]} : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cfg_wr_bw_sel    ? {22'h000000, i_mss_fab_cfg_wr_bw_r[10*i+:10]} : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_sel     ? i_mss_fab_cnt_aw_r[64*i+:32]              : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_w_sel      ? i_mss_fab_cnt_w_r[64*i+:32]               : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_lat_sel ? i_mss_fab_cnt_aw_lat_r[64*i+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wf_lat_sel ? i_mss_fab_cnt_wf_lat_r[64*i+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wl_lat_sel ? i_mss_fab_cnt_wl_lat_r[64*i+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_b_lat_sel  ? i_mss_fab_cnt_b_lat_r[64*i+:32]           : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_sel     ? i_mss_fab_cnt_ar_r[64*i+:32]              : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_r_sel      ? i_mss_fab_cnt_r_r[64*i+:32]               : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_lat_sel ? i_mss_fab_cnt_ar_lat_r[64*i+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rf_lat_sel ? i_mss_fab_cnt_rf_lat_r[64*i+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rl_lat_sel ? i_mss_fab_cnt_rl_lat_r[64*i+:32]          : 32'h00000000);
                          end

                  for (j = 0; j < 1; j = j + 1)
                      if (i_mss_mem_lat_sel[j])
                          if (mss_perfctrl_addr[2]) begin // MSB 32bit
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_sel     ? i_mss_mem_cnt_aw_r[64*j+32+:32]         : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_w_sel      ? i_mss_mem_cnt_w_r[64*j+32+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_lat_sel ? i_mss_mem_cnt_aw_lat_r[64*j+32+:32]     : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wf_lat_sel ? i_mss_mem_cnt_wf_lat_r[64*j+32+:32]     : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wl_lat_sel ? i_mss_mem_cnt_wl_lat_r[64*j+32+:32]     : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_b_lat_sel  ? i_mss_mem_cnt_b_lat_r[64*j+32+:32]      : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_sel     ? i_mss_mem_cnt_ar_r[64*j+32+:32]         : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_r_sel      ? i_mss_mem_cnt_r_r[64*j+32+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_lat_sel ? i_mss_mem_cnt_ar_lat_r[64*j+32+:32]     : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rf_lat_sel ? i_mss_mem_cnt_rf_lat_r[64*j+32+:32]     : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rl_lat_sel ? i_mss_mem_cnt_rl_lat_r[64*j+32+:32]     : 32'h00000000);
                          end
                          else begin
                              i_rdata_d = i_rdata_d | (i_mss_cfg_lat_sel    ? {6'h0,i_mss_mem_cfg_lat_wr_r[10*j+:10], 6'h0,i_mss_mem_cfg_lat_rd_r[10*j+:10]} : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_sel     ? i_mss_mem_cnt_aw_r[64*j+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_w_sel      ? i_mss_mem_cnt_w_r[64*j+:32]           : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_aw_lat_sel ? i_mss_mem_cnt_aw_lat_r[64*j+:32]      : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wf_lat_sel ? i_mss_mem_cnt_wf_lat_r[64*j+:32]      : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_wl_lat_sel ? i_mss_mem_cnt_wl_lat_r[64*j+:32]      : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_b_lat_sel  ? i_mss_mem_cnt_b_lat_r[64*j+:32]       : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_sel     ? i_mss_mem_cnt_ar_r[64*j+:32]          : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_r_sel      ? i_mss_mem_cnt_r_r[64*j+:32]           : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_ar_lat_sel ? i_mss_mem_cnt_ar_lat_r[64*j+:32]      : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rf_lat_sel ? i_mss_mem_cnt_rf_lat_r[64*j+:32]      : 32'h00000000);
                              i_rdata_d = i_rdata_d | (i_mss_cnt_rl_lat_sel ? i_mss_mem_cnt_rl_lat_r[64*j+:32]      : 32'h00000000);
                          end
                  if (i_mss_glob_sel) begin
                      i_rdata_d = i_rdata_d | ((mss_perfctrl_addr[7:2] == 6'd1)  ? i_mss_tick_count_r[63:32] : 32'h00000000);
                      i_rdata_d = i_rdata_d | ((mss_perfctrl_addr[7:2] == 6'd2)  ? i_mss_tick_count_r[31:0]  : 32'h00000000);
                      i_rdata_d = i_rdata_d | ((mss_perfctrl_addr[7:2] == 6'd3)  ? glob_comp_version         : 32'h00000000);
                      i_rdata_d = i_rdata_d | ((mss_perfctrl_addr[7:2] == 6'd4)  ? glob_comp_type            : 32'h00000000);
                  end
              end
          end
          else if (mss_perfctrl_sel)
            i_ready_d = 1'b0;
          else
            i_ready_d = 1'b1;
      end // stnxt_PROC

    always @*
      begin : stnxt_cnt_perf_PROC
         integer i,j;
         i_mss_fab_st_aw_lat_d  = ~mss_fab_perf_aw & (i_mss_fab_st_aw_lat_r | mss_fab_perf_awf);
         i_mss_fab_st_ar_lat_d  = ~mss_fab_perf_ar & (i_mss_fab_st_ar_lat_r | mss_fab_perf_arf);
         i_mss_fab_cnt_wf_lat_d = i_mss_fab_cnt_wf_lat_r;
         i_mss_fab_cnt_wl_lat_d = i_mss_fab_cnt_wl_lat_r;
         i_mss_fab_cnt_b_lat_d  = i_mss_fab_cnt_b_lat_r;
         i_mss_fab_cnt_rf_lat_d = i_mss_fab_cnt_rf_lat_r;
         i_mss_fab_cnt_rl_lat_d = i_mss_fab_cnt_rl_lat_r;

         for (i = 0; i < 4; i = i + 1) begin
             i_mss_fab_cnt_aw_d[64*i+:64]     = i_mss_fab_cnt_aw_r[64*i+:64]     + {{63{1'b0}},(mss_fab_perf_aw[i] & i_mss_perf_running_r)};
             i_mss_fab_cnt_w_d[64*i+:64]      = i_mss_fab_cnt_w_r[64*i+:64]      + {{63{1'b0}},(mss_fab_perf_w[i] & i_mss_perf_running_r)};
             i_mss_fab_cnt_ar_d[64*i+:64]     = i_mss_fab_cnt_ar_r[64*i+:64]     + {{63{1'b0}},(mss_fab_perf_ar[i] & i_mss_perf_running_r)};
             i_mss_fab_cnt_r_d[64*i+:64]      = i_mss_fab_cnt_r_r[64*i+:64]      + {{63{1'b0}},(mss_fab_perf_r[i] & i_mss_perf_running_r)};
             i_mss_fab_cnt_aw_lat_d[64*i+:64] = i_mss_fab_cnt_aw_lat_r[64*i+:64] + {{63{1'b0}},(i_mss_fab_st_aw_lat_d[i] & i_mss_perf_running_r)};
             i_mss_fab_cnt_ar_lat_d[64*i+:64] = i_mss_fab_cnt_ar_lat_r[64*i+:64] + {{63{1'b0}},(i_mss_fab_st_ar_lat_d[i] & i_mss_perf_running_r)};
             case ({mss_fab_perf_aw[i], i_mss_fab_perf_wf[i]})
               2'b01:   i_mss_fab_inc_wf_lat_d[5*i+:5] = i_mss_fab_inc_wf_lat_r[5*i+:5] - 1'b1;
               2'b10:   i_mss_fab_inc_wf_lat_d[5*i+:5] = i_mss_fab_inc_wf_lat_r[5*i+:5] + 1'b1;
               default: i_mss_fab_inc_wf_lat_d[5*i+:5] = i_mss_fab_inc_wf_lat_r[5*i+:5];
             endcase
             case ({mss_fab_perf_aw[i], mss_fab_perf_wl[i]})
               2'b01:   i_mss_fab_inc_wl_lat_d[5*i+:5] = i_mss_fab_inc_wl_lat_r[5*i+:5] - 1'b1;
               2'b10:   i_mss_fab_inc_wl_lat_d[5*i+:5] = i_mss_fab_inc_wl_lat_r[5*i+:5] + 1'b1;
               default: i_mss_fab_inc_wl_lat_d[5*i+:5] = i_mss_fab_inc_wl_lat_r[5*i+:5];
             endcase
             case ({mss_fab_perf_aw[i], mss_fab_perf_b[i]})
               2'b01:   i_mss_fab_inc_b_lat_d[5*i+:5] = i_mss_fab_inc_b_lat_r[5*i+:5] - 1'b1;
               2'b10:   i_mss_fab_inc_b_lat_d[5*i+:5] = i_mss_fab_inc_b_lat_r[5*i+:5] + 1'b1;
               default: i_mss_fab_inc_b_lat_d[5*i+:5] = i_mss_fab_inc_b_lat_r[5*i+:5];
             endcase
             case ({mss_fab_perf_ar[i], i_mss_fab_perf_rf[i]})
               2'b01:   i_mss_fab_inc_rf_lat_d[5*i+:5] = i_mss_fab_inc_rf_lat_r[5*i+:5] - 1'b1;
               2'b10:   i_mss_fab_inc_rf_lat_d[5*i+:5] = i_mss_fab_inc_rf_lat_r[5*i+:5] + 1'b1;
               default: i_mss_fab_inc_rf_lat_d[5*i+:5] = i_mss_fab_inc_rf_lat_r[5*i+:5];
             endcase
             case ({mss_fab_perf_ar[i], mss_fab_perf_rl[i]})
               2'b01:   i_mss_fab_inc_rl_lat_d[5*i+:5] = i_mss_fab_inc_rl_lat_r[5*i+:5] - 1'b1;
               2'b10:   i_mss_fab_inc_rl_lat_d[5*i+:5] = i_mss_fab_inc_rl_lat_r[5*i+:5] + 1'b1;
               default: i_mss_fab_inc_rl_lat_d[5*i+:5] = i_mss_fab_inc_rl_lat_r[5*i+:5];
             endcase

             if (i_mss_perf_running_r) begin
                 i_mss_fab_cnt_wf_lat_d[64*i+:64] = i_mss_fab_cnt_wf_lat_r[64*i+:64] + i_mss_fab_inc_wf_lat_r[5*i+:5];
                 i_mss_fab_cnt_wl_lat_d[64*i+:64] = i_mss_fab_cnt_wl_lat_r[64*i+:64] + i_mss_fab_inc_wl_lat_r[5*i+:5];
                 i_mss_fab_cnt_b_lat_d[64*i+:64]  = i_mss_fab_cnt_b_lat_r[64*i+:64]  + i_mss_fab_inc_b_lat_r[5*i+:5];
                 i_mss_fab_cnt_rf_lat_d[64*i+:64] = i_mss_fab_cnt_rf_lat_r[64*i+:64] + i_mss_fab_inc_rf_lat_r[5*i+:5];
                 i_mss_fab_cnt_rl_lat_d[64*i+:64] = i_mss_fab_cnt_rl_lat_r[64*i+:64] + i_mss_fab_inc_rl_lat_r[5*i+:5];
             end
         end
         i_mss_mem_st_aw_lat_d  = ~mss_mem_perf_aw & (i_mss_mem_st_aw_lat_r | mss_mem_perf_awf);
         i_mss_mem_st_ar_lat_d  = ~mss_mem_perf_ar & (i_mss_mem_st_ar_lat_r | mss_mem_perf_arf);
         i_mss_mem_cnt_wf_lat_d = i_mss_mem_cnt_wf_lat_r;
         i_mss_mem_cnt_wl_lat_d = i_mss_mem_cnt_wl_lat_r;
         i_mss_mem_cnt_b_lat_d  = i_mss_mem_cnt_b_lat_r;
         i_mss_mem_cnt_rf_lat_d = i_mss_mem_cnt_rf_lat_r;
         i_mss_mem_cnt_rl_lat_d = i_mss_mem_cnt_rl_lat_r;

         for (j = 0; j < 1; j = j + 1) begin
         i_mss_mem_cnt_aw_d[64*j+:64]     = i_mss_mem_cnt_aw_r[64*j+:64]     + {{63{1'b0}},(mss_mem_perf_aw[j] & i_mss_perf_running_r)};
         i_mss_mem_cnt_w_d[64*j+:64]      = i_mss_mem_cnt_w_r[64*j+:64]      + {{63{1'b0}},(mss_mem_perf_w[j] & i_mss_perf_running_r)};
         i_mss_mem_cnt_ar_d[64*j+:64]     = i_mss_mem_cnt_ar_r[64*j+:64]     + {{63{1'b0}},(mss_mem_perf_ar[j] & i_mss_perf_running_r)};
         i_mss_mem_cnt_r_d[64*j+:64]      = i_mss_mem_cnt_r_r[64*j+:64]      + {{63{1'b0}},(mss_mem_perf_r[j] & i_mss_perf_running_r)};
         i_mss_mem_cnt_aw_lat_d[64*j+:64] = i_mss_mem_cnt_aw_lat_r[64*j+:64] + {{63{1'b0}},(i_mss_mem_st_aw_lat_d[j] & i_mss_perf_running_r)};
         i_mss_mem_cnt_ar_lat_d[64*j+:64] = i_mss_mem_cnt_ar_lat_r[64*j+:64] + {{63{1'b0}},(i_mss_mem_st_ar_lat_d[j] & i_mss_perf_running_r)};
         case ({mss_mem_perf_aw[j], i_mss_mem_perf_wf[j]})
           2'b01:   i_mss_mem_inc_wf_lat_d[5*j+:5] = i_mss_mem_inc_wf_lat_r[5*j+:5] - 1'b1;
           2'b10:   i_mss_mem_inc_wf_lat_d[5*j+:5] = i_mss_mem_inc_wf_lat_r[5*j+:5] + 1'b1;
           default: i_mss_mem_inc_wf_lat_d[5*j+:5] = i_mss_mem_inc_wf_lat_r[5*j+:5];
         endcase
         case ({mss_mem_perf_aw[j], mss_mem_perf_wl[j]})
           2'b01:   i_mss_mem_inc_wl_lat_d[5*j+:5] = i_mss_mem_inc_wl_lat_r[5*j+:5] - 1'b1;
           2'b10:   i_mss_mem_inc_wl_lat_d[5*j+:5] = i_mss_mem_inc_wl_lat_r[5*j+:5] + 1'b1;
           default: i_mss_mem_inc_wl_lat_d[5*j+:5] = i_mss_mem_inc_wl_lat_r[5*j+:5];
         endcase
         case ({mss_mem_perf_aw[j], mss_mem_perf_b[j]})
           2'b01:   i_mss_mem_inc_b_lat_d[5*j+:5] = i_mss_mem_inc_b_lat_r[5*j+:5] - 1'b1;
           2'b10:   i_mss_mem_inc_b_lat_d[5*j+:5] = i_mss_mem_inc_b_lat_r[5*j+:5] + 1'b1;
           default: i_mss_mem_inc_b_lat_d[5*j+:5] = i_mss_mem_inc_b_lat_r[5*j+:5];
         endcase
         case ({mss_mem_perf_ar[j], i_mss_mem_perf_rf[j]})
           2'b01:   i_mss_mem_inc_rf_lat_d[5*j+:5] = i_mss_mem_inc_rf_lat_r[5*j+:5] - 1'b1;
           2'b10:   i_mss_mem_inc_rf_lat_d[5*j+:5] = i_mss_mem_inc_rf_lat_r[5*j+:5] + 1'b1;
           default: i_mss_mem_inc_rf_lat_d[5*j+:5] = i_mss_mem_inc_rf_lat_r[5*j+:5];
         endcase
         case ({mss_mem_perf_ar[j], mss_mem_perf_rl[j]})
           2'b01:   i_mss_mem_inc_rl_lat_d[5*j+:5] = i_mss_mem_inc_rl_lat_r[5*j+:5] - 1'b1;
           2'b10:   i_mss_mem_inc_rl_lat_d[5*j+:5] = i_mss_mem_inc_rl_lat_r[5*j+:5] + 1'b1;
           default: i_mss_mem_inc_rl_lat_d[5*j+:5] = i_mss_mem_inc_rl_lat_r[5*j+:5];
         endcase
         if (i_mss_perf_running_r) begin
             i_mss_mem_cnt_wf_lat_d[64*j+:64] = i_mss_mem_cnt_wf_lat_r[64*j+:64] + i_mss_mem_inc_wf_lat_r[5*j+:5];
             i_mss_mem_cnt_wl_lat_d[64*j+:64] = i_mss_mem_cnt_wl_lat_r[64*j+:64] + i_mss_mem_inc_wl_lat_r[5*j+:5];
             i_mss_mem_cnt_b_lat_d[64*j+:64]  = i_mss_mem_cnt_b_lat_r[64*j+:64]  + i_mss_mem_inc_b_lat_r[5*j+:5];
             i_mss_mem_cnt_rf_lat_d[64*j+:64] = i_mss_mem_cnt_rf_lat_r[64*j+:64] + i_mss_mem_inc_rf_lat_r[5*j+:5];
             i_mss_mem_cnt_rl_lat_d[64*j+:64] = i_mss_mem_cnt_rl_lat_r[64*j+:64] + i_mss_mem_inc_rl_lat_r[5*j+:5];
         end
        end
      end // stnxt_cnt_perf_PROC

    // state
    // outputs: i_ready_r, i_rdata_r, i_mss_fab_cfg_lat_r, i_mss_mem_cfg_lat_r
    always @(posedge mss_clk or
             negedge rst_b)
      begin : st_PROC
          if (!rst_b) begin
              i_ready_r                   <= 1'b1;
              i_rdata_r                   <= 32'h00000000;
              i_mss_perf_running_r        <= 1'b0;
              i_mss_tick_count_r          <= 64'h0000000000000000;
              i_mss_perf_reset_r          <= 1'b0;
              i_mss_fab_cfg_lat_wr_r         <= {4{`ALB_MSS_PERFCTRL_FAB_DEF_WR}};
              i_mss_fab_cfg_lat_rd_r         <= {4{`ALB_MSS_PERFCTRL_FAB_DEF_RD}};
              i_mss_fab_cfg_wr_bw_r         <= {4{`ALB_MSS_PERFCTRL_FAB_WR_BW}};
              i_mss_fab_cfg_rd_bw_r         <= {4{`ALB_MSS_PERFCTRL_FAB_RD_BW}};
              i_mss_fab_perf_wl_r         <= {4{1'b1}};
              i_mss_fab_perf_rl_r         <= {4{1'b1}};
              i_mss_fab_cnt_aw_r          <= {4{64'd0}};
              i_mss_fab_cnt_w_r           <= {4{64'd0}};
              i_mss_fab_cnt_ar_r          <= {4{64'd0}};
              i_mss_fab_cnt_r_r           <= {4{64'd0}};
              i_mss_fab_cnt_aw_lat_r      <= {4{64'd0}};
              i_mss_fab_cnt_ar_lat_r      <= {4{64'd0}};
              i_mss_fab_st_aw_lat_r       <= {4{1'b0}};
              i_mss_fab_st_ar_lat_r       <= {4{1'b0}};
              i_mss_fab_inc_wf_lat_r      <= {4{5'd0}};
              i_mss_fab_inc_wl_lat_r      <= {4{5'd0}};
              i_mss_fab_inc_b_lat_r       <= {4{5'd0}};
              i_mss_fab_inc_rf_lat_r      <= {4{5'd0}};
              i_mss_fab_inc_rl_lat_r      <= {4{5'd0}};
              i_mss_fab_cnt_wf_lat_r      <= {4{64'd0}};
              i_mss_fab_cnt_wl_lat_r      <= {4{64'd0}};
              i_mss_fab_cnt_b_lat_r       <= {4{64'd0}};
              i_mss_fab_cnt_rf_lat_r      <= {4{64'd0}};
              i_mss_fab_cnt_rl_lat_r      <= {4{64'd0}};
              i_mss_mem_cfg_lat_rd_r         <= {1{10'b0}} 
                                             | {
                                             10'd0
                                             };
              i_mss_mem_cfg_lat_wr_r         <= {1{10'b0}} 
                                             | {
                                             10'd0
                                             };

              i_mss_mem_perf_wl_r         <= {1{1'b1}};
              i_mss_mem_perf_rl_r         <= {1{1'b1}};
              i_mss_mem_cnt_aw_r          <= {1{64'd0}};
              i_mss_mem_cnt_w_r           <= {1{64'd0}};
              i_mss_mem_cnt_ar_r          <= {1{64'd0}};
              i_mss_mem_cnt_r_r           <= {1{64'd0}};
              i_mss_mem_cnt_aw_lat_r      <= {1{64'd0}};
              i_mss_mem_cnt_ar_lat_r      <= {1{64'd0}};
              i_mss_mem_st_aw_lat_r       <= {1{1'b0}};
              i_mss_mem_st_ar_lat_r       <= {1{1'b0}};
              i_mss_mem_inc_wf_lat_r      <= {1{5'd0}};
              i_mss_mem_inc_wl_lat_r      <= {1{5'd0}};
              i_mss_mem_inc_b_lat_r       <= {1{5'd0}};
              i_mss_mem_inc_rf_lat_r      <= {1{5'd0}};
              i_mss_mem_inc_rl_lat_r      <= {1{5'd0}};
              i_mss_mem_cnt_wf_lat_r      <= {1{64'd0}};
              i_mss_mem_cnt_wl_lat_r      <= {1{64'd0}};
              i_mss_mem_cnt_b_lat_r       <= {1{64'd0}};
              i_mss_mem_cnt_rf_lat_r      <= {1{64'd0}};
              i_mss_mem_cnt_rl_lat_r      <= {1{64'd0}};
          end
          else begin
                  i_mss_perf_reset_r      <= i_mss_perf_reset_d;
                  i_ready_r               <= i_ready_d;
                  i_rdata_r               <= i_rdata_d;
                  i_mss_perf_running_r    <= i_mss_perf_running_d;
                  i_mss_fab_cfg_lat_wr_r     <= i_mss_fab_cfg_lat_wr_d;
                  i_mss_fab_cfg_lat_rd_r     <= i_mss_fab_cfg_lat_rd_d;
                  i_mss_fab_cfg_wr_bw_r     <= i_mss_fab_cfg_wr_bw_d;
                  i_mss_fab_cfg_rd_bw_r     <= i_mss_fab_cfg_rd_bw_d;
                  i_mss_mem_cfg_lat_rd_r     <= i_mss_mem_cfg_lat_rd_d;
                  i_mss_mem_cfg_lat_wr_r     <= i_mss_mem_cfg_lat_wr_d;
              if (i_mss_perf_reset_r)
                  i_mss_tick_count_r      <= 64'h0000000000000000;
              else
                  i_mss_tick_count_r      <= i_mss_tick_count_r + {63'd0,i_mss_perf_running_r};

              i_mss_fab_perf_wl_r         <= (i_mss_fab_perf_wl_r & ~mss_fab_perf_w) | mss_fab_perf_wl;
              i_mss_fab_perf_rl_r         <= (i_mss_fab_perf_rl_r & ~mss_fab_perf_r) | mss_fab_perf_rl;
              i_mss_fab_st_aw_lat_r       <= i_mss_fab_st_aw_lat_d;
              i_mss_fab_st_ar_lat_r       <= i_mss_fab_st_ar_lat_d;
              i_mss_fab_inc_wf_lat_r      <= i_mss_fab_inc_wf_lat_d;
              i_mss_fab_inc_wl_lat_r      <= i_mss_fab_inc_wl_lat_d;
              i_mss_fab_inc_b_lat_r       <= i_mss_fab_inc_b_lat_d;
              i_mss_fab_inc_rf_lat_r      <= i_mss_fab_inc_rf_lat_d;
              i_mss_fab_inc_rl_lat_r      <= i_mss_fab_inc_rl_lat_d;
              if (i_mss_perf_reset_r) begin
                  i_mss_fab_cnt_aw_r      <= {4{64'd0}};
                  i_mss_fab_cnt_w_r       <= {4{64'd0}};
                  i_mss_fab_cnt_ar_r      <= {4{64'd0}};
                  i_mss_fab_cnt_r_r       <= {4{64'd0}};
                  i_mss_fab_cnt_aw_lat_r  <= {4{64'd0}};
                  i_mss_fab_cnt_ar_lat_r  <= {4{64'd0}};
                  i_mss_fab_cnt_wf_lat_r  <= {4{64'd0}};
                  i_mss_fab_cnt_wl_lat_r  <= {4{64'd0}};
                  i_mss_fab_cnt_b_lat_r   <= {4{64'd0}};
                  i_mss_fab_cnt_rf_lat_r  <= {4{64'd0}};
                  i_mss_fab_cnt_rl_lat_r  <= {4{64'd0}};
              end
              else begin
                  i_mss_fab_cnt_aw_r      <= i_mss_fab_cnt_aw_d;
                  i_mss_fab_cnt_w_r       <= i_mss_fab_cnt_w_d;
                  i_mss_fab_cnt_ar_r      <= i_mss_fab_cnt_ar_d;
                  i_mss_fab_cnt_r_r       <= i_mss_fab_cnt_r_d;
                  i_mss_fab_cnt_aw_lat_r  <= i_mss_fab_cnt_aw_lat_d;
                  i_mss_fab_cnt_ar_lat_r  <= i_mss_fab_cnt_ar_lat_d;
                  i_mss_fab_cnt_wf_lat_r  <= i_mss_fab_cnt_wf_lat_d;
                  i_mss_fab_cnt_wl_lat_r  <= i_mss_fab_cnt_wl_lat_d;
                  i_mss_fab_cnt_b_lat_r   <= i_mss_fab_cnt_b_lat_d;
                  i_mss_fab_cnt_rf_lat_r  <= i_mss_fab_cnt_rf_lat_d;
                  i_mss_fab_cnt_rl_lat_r  <= i_mss_fab_cnt_rl_lat_d;
              end
              i_mss_mem_perf_wl_r         <= (i_mss_mem_perf_wl_r & ~mss_mem_perf_w) | mss_mem_perf_wl;
              i_mss_mem_perf_rl_r         <= (i_mss_mem_perf_rl_r & ~mss_mem_perf_r) | mss_mem_perf_rl;
              i_mss_mem_st_aw_lat_r       <= i_mss_mem_st_aw_lat_d;
              i_mss_mem_st_ar_lat_r       <= i_mss_mem_st_ar_lat_d;
              i_mss_mem_inc_wf_lat_r      <= i_mss_mem_inc_wf_lat_d;
              i_mss_mem_inc_wl_lat_r      <= i_mss_mem_inc_wl_lat_d;
              i_mss_mem_inc_b_lat_r       <= i_mss_mem_inc_b_lat_d;
              i_mss_mem_inc_rf_lat_r      <= i_mss_mem_inc_rf_lat_d;
              i_mss_mem_inc_rl_lat_r      <= i_mss_mem_inc_rl_lat_d;
              if (i_mss_perf_reset_r) begin
                  i_mss_mem_cnt_aw_r      <= {1{64'd0}};
                  i_mss_mem_cnt_w_r       <= {1{64'd0}};
                  i_mss_mem_cnt_ar_r      <= {1{64'd0}};
                  i_mss_mem_cnt_r_r       <= {1{64'd0}};
                  i_mss_mem_cnt_aw_lat_r  <= {1{64'd0}};
                  i_mss_mem_cnt_ar_lat_r  <= {1{64'd0}};
                  i_mss_mem_cnt_wf_lat_r  <= {1{64'd0}};
                  i_mss_mem_cnt_wl_lat_r  <= {1{64'd0}};
                  i_mss_mem_cnt_b_lat_r   <= {1{64'd0}};
                  i_mss_mem_cnt_rf_lat_r  <= {1{64'd0}};
                  i_mss_mem_cnt_rl_lat_r  <= {1{64'd0}};
              end
              else begin
                  i_mss_mem_cnt_aw_r      <= i_mss_mem_cnt_aw_d;
                  i_mss_mem_cnt_w_r       <= i_mss_mem_cnt_w_d;
                  i_mss_mem_cnt_ar_r      <= i_mss_mem_cnt_ar_d;
                  i_mss_mem_cnt_r_r       <= i_mss_mem_cnt_r_d;
                  i_mss_mem_cnt_aw_lat_r  <= i_mss_mem_cnt_aw_lat_d;
                  i_mss_mem_cnt_ar_lat_r  <= i_mss_mem_cnt_ar_lat_d;
                  i_mss_mem_cnt_wf_lat_r  <= i_mss_mem_cnt_wf_lat_d;
                  i_mss_mem_cnt_wl_lat_r  <= i_mss_mem_cnt_wl_lat_d;
                  i_mss_mem_cnt_b_lat_r   <= i_mss_mem_cnt_b_lat_d;
                  i_mss_mem_cnt_rl_lat_r  <= i_mss_mem_cnt_rl_lat_d;
                  i_mss_mem_cnt_rf_lat_r  <= i_mss_mem_cnt_rf_lat_d;
              end

          end
      end // st_PROC

endmodule // alb_mss_perfctrl
