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
//   alb_mss_mem: BUS memory model including latency unit
//
// ===========================================================================
//
// Description:
//  Verilog module defining a BUS memory controller
//  Supporting RASCAL backdoor access and FPGA mapping
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_mss_mem.vpp
//
// ===========================================================================
`timescale 1ns/10ps
`include "alb_mss_mem_defines.v"
module alb_mss_mem
    (input               mss_clk,
     input               rst_b,
     // IBP I/F
     input               mss_mem_cmd_valid,
     output              mss_mem_cmd_accept,
     input               mss_mem_cmd_read,
     input   [32-1:0]   mss_mem_cmd_addr,
     input               mss_mem_cmd_wrap,
     input   [2:0]       mss_mem_cmd_data_size,
     input   [3:0]       mss_mem_cmd_burst_size,
     input               mss_mem_cmd_lock,
     input               mss_mem_cmd_excl,
     input   [1:0]       mss_mem_cmd_prot,
     input   [3:0]       mss_mem_cmd_cache,
     input   [6-1:0]  mss_mem_cmd_id,
     input   [4-1:0]   mss_mem_cmd_user,
     input   [1-1:0]  mss_mem_cmd_region,
     output              mss_mem_rd_valid,
     input               mss_mem_rd_accept,
     output              mss_mem_rd_excl_ok,
     output  [128-1:0]   mss_mem_rd_data,
     output              mss_mem_err_rd,
     output              mss_mem_rd_last,
     input               mss_mem_wr_valid,
     output              mss_mem_wr_accept,
     input   [128-1:0]   mss_mem_wr_data,
     input   [128/8-1:0] mss_mem_wr_mask,
     input               mss_mem_wr_last,
     output              mss_mem_wr_done,
     output              mss_mem_wr_excl_done,
     output              mss_mem_err_wr,
     input               mss_mem_wr_resp_accept,
     input  [1*10-1:0] mss_mem_cfg_lat_w,
     input  [1*10-1:0] mss_mem_cfg_lat_r,
     output [1-1:0]    mss_mem_perf_awf,
     output [1-1:0]    mss_mem_perf_arf,
     output [1-1:0]    mss_mem_perf_aw,
     output [1-1:0]    mss_mem_perf_ar,
     output [1-1:0]    mss_mem_perf_w,
     output [1-1:0]    mss_mem_perf_wl,
     output [1-1:0]    mss_mem_perf_r,
     output [1-1:0]    mss_mem_perf_rl,
     output [1-1:0]    mss_mem_perf_b,
     output              mss_mem_dummy);
    // local parameters
    localparam alsb = 4;
    // local wires
    wire               i_mem_clk;


    wire                buf_ibp_cmd_valid;
    wire                buf_ibp_cmd_accept;
    wire                buf_ibp_cmd_read;
    wire  [4-1:0]     buf_ibp_cmd_user;
    wire  [32-1:0]     buf_ibp_cmd_addr;
    wire                buf_ibp_cmd_wrap;
    wire  [2:0]         buf_ibp_cmd_data_size;
    wire  [3:0]         buf_ibp_cmd_burst_size;
    wire  [1:0]         buf_ibp_cmd_prot;
    wire  [3:0]         buf_ibp_cmd_cache;
    wire                buf_ibp_cmd_lock;
    wire                buf_ibp_cmd_excl;
    wire  [6-1:0]    buf_ibp_cmd_id;
    wire  [1-1:0]    buf_ibp_cmd_region;

    wire                buf_ibp_wr_valid;
    wire                buf_ibp_wr_accept;
    wire  [128-1:0]     buf_ibp_wr_data;
    wire  [128/8-1:0]   buf_ibp_wr_mask;
    wire                buf_ibp_wr_last;


  wire                                  splt_i_ibp_cmd_valid;
  wire                                  splt_i_ibp_cmd_accept;
  wire                                  splt_i_ibp_cmd_read;
  wire  [32                -1:0]       splt_i_ibp_cmd_addr;
  wire                                  splt_i_ibp_cmd_wrap;
  wire  [3-1:0]       splt_i_ibp_cmd_data_size;
  wire  [4-1:0]       splt_i_ibp_cmd_burst_size;
  wire  [2-1:0]       splt_i_ibp_cmd_prot;
  wire  [4-1:0]       splt_i_ibp_cmd_cache;
  wire                                  splt_i_ibp_cmd_lock;
  wire                                  splt_i_ibp_cmd_excl;

  wire                                  splt_i_ibp_rd_valid;
  wire                                  splt_i_ibp_rd_excl_ok;
  wire                                  splt_i_ibp_rd_accept;
  wire                                  splt_i_ibp_err_rd;
  wire  [128               -1:0]        splt_i_ibp_rd_data;
  wire                                  splt_i_ibp_rd_last;

  wire                                  splt_i_ibp_wr_valid;
  wire                                  splt_i_ibp_wr_accept;
  wire  [128               -1:0]        splt_i_ibp_wr_data;
  wire  [(128         /8)  -1:0]        splt_i_ibp_wr_mask;
  wire                                  splt_i_ibp_wr_last;

  wire                                  splt_i_ibp_wr_done;
  wire                                  splt_i_ibp_wr_excl_done;
  wire                                  splt_i_ibp_err_wr;
  wire                                  splt_i_ibp_wr_resp_accept;
    wire  [4-1:0]    splt_i_cmd_user;
    wire  [1-1:0]   splt_i_cmd_region;




 wire [1-1:0] splt_i_ibp_cmd_chnl_valid;
 wire [1-1:0] splt_i_ibp_cmd_chnl_accept;
 wire [49 * 1 -1:0] splt_i_ibp_cmd_chnl;

 wire [1-1:0] splt_i_ibp_wd_chnl_valid;
 wire [1-1:0] splt_i_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] splt_i_ibp_wd_chnl;

 wire [1-1:0] splt_i_ibp_rd_chnl_accept;
 wire [1-1:0] splt_i_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] splt_i_ibp_rd_chnl;

 wire [1-1:0] splt_i_ibp_wrsp_chnl_valid;
 wire [1-1:0] splt_i_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] splt_i_ibp_wrsp_chnl;

    wire  [4-1:0]    splt_i_cmd_chnl_user;
    wire  [1-1:0]   splt_i_cmd_chnl_region;

    wire split_0_ibp_rgon_hit;

    wire splt_indicator_dummy;
    wire [1-1:0] splt_i_indicator;




 wire [1-1:0] splt_o_bus_ibp_cmd_chnl_valid;
 wire [1-1:0] splt_o_bus_ibp_cmd_chnl_accept;
 wire [49 * 1 -1:0] splt_o_bus_ibp_cmd_chnl;

 wire [1-1:0] splt_o_bus_ibp_wd_chnl_valid;
 wire [1-1:0] splt_o_bus_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] splt_o_bus_ibp_wd_chnl;

 wire [1-1:0] splt_o_bus_ibp_rd_chnl_accept;
 wire [1-1:0] splt_o_bus_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] splt_o_bus_ibp_rd_chnl;

 wire [1-1:0] splt_o_bus_ibp_wrsp_chnl_valid;
 wire [1-1:0] splt_o_bus_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] splt_o_bus_ibp_wrsp_chnl;

    wire [4*1-1:0]    splt_o_bus_ibp_cmd_chnl_user;
    wire splt_dummy0, splt_dummy1;





 wire [1-1:0] split_0_ibp_cmd_chnl_valid;
 wire [1-1:0] split_0_ibp_cmd_chnl_accept;
 wire [49 * 1 -1:0] split_0_ibp_cmd_chnl;

 wire [1-1:0] split_0_ibp_wd_chnl_valid;
 wire [1-1:0] split_0_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] split_0_ibp_wd_chnl;

 wire [1-1:0] split_0_ibp_rd_chnl_accept;
 wire [1-1:0] split_0_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] split_0_ibp_rd_chnl;

 wire [1-1:0] split_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] split_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] split_0_ibp_wrsp_chnl;

    wire [4-1:0]    split_0_ibp_cmd_chnl_user;

  wire                                  split_0_ibp_cmd_valid;
  wire                                  split_0_ibp_cmd_accept;
  wire                                  split_0_ibp_cmd_read;
  wire  [32                -1:0]       split_0_ibp_cmd_addr;
  wire                                  split_0_ibp_cmd_wrap;
  wire  [3-1:0]       split_0_ibp_cmd_data_size;
  wire  [4-1:0]       split_0_ibp_cmd_burst_size;
  wire  [2-1:0]       split_0_ibp_cmd_prot;
  wire  [4-1:0]       split_0_ibp_cmd_cache;
  wire                                  split_0_ibp_cmd_lock;
  wire                                  split_0_ibp_cmd_excl;

  wire                                  split_0_ibp_rd_valid;
  wire                                  split_0_ibp_rd_excl_ok;
  wire                                  split_0_ibp_rd_accept;
  wire                                  split_0_ibp_err_rd;
  wire  [128               -1:0]        split_0_ibp_rd_data;
  wire                                  split_0_ibp_rd_last;

  wire                                  split_0_ibp_wr_valid;
  wire                                  split_0_ibp_wr_accept;
  wire  [128               -1:0]        split_0_ibp_wr_data;
  wire  [(128         /8)  -1:0]        split_0_ibp_wr_mask;
  wire                                  split_0_ibp_wr_last;

  wire                                  split_0_ibp_wr_done;
  wire                                  split_0_ibp_wr_excl_done;
  wire                                  split_0_ibp_err_wr;
  wire                                  split_0_ibp_wr_resp_accept;
    wire [4-1:0]    split_0_ibp_cmd_user;

  wire                                  lat_o_rgon0_ibp_cmd_valid;
  wire                                  lat_o_rgon0_ibp_cmd_accept;
  wire                                  lat_o_rgon0_ibp_cmd_read;
  wire  [32                -1:0]       lat_o_rgon0_ibp_cmd_addr;
  wire                                  lat_o_rgon0_ibp_cmd_wrap;
  wire  [3-1:0]       lat_o_rgon0_ibp_cmd_data_size;
  wire  [4-1:0]       lat_o_rgon0_ibp_cmd_burst_size;
  wire  [2-1:0]       lat_o_rgon0_ibp_cmd_prot;
  wire  [4-1:0]       lat_o_rgon0_ibp_cmd_cache;
  wire                                  lat_o_rgon0_ibp_cmd_lock;
  wire                                  lat_o_rgon0_ibp_cmd_excl;

  wire                                  lat_o_rgon0_ibp_rd_valid;
  wire                                  lat_o_rgon0_ibp_rd_excl_ok;
  wire                                  lat_o_rgon0_ibp_rd_accept;
  wire                                  lat_o_rgon0_ibp_err_rd;
  wire  [128               -1:0]        lat_o_rgon0_ibp_rd_data;
  wire                                  lat_o_rgon0_ibp_rd_last;

  wire                                  lat_o_rgon0_ibp_wr_valid;
  wire                                  lat_o_rgon0_ibp_wr_accept;
  wire  [128               -1:0]        lat_o_rgon0_ibp_wr_data;
  wire  [(128         /8)  -1:0]        lat_o_rgon0_ibp_wr_mask;
  wire                                  lat_o_rgon0_ibp_wr_last;

  wire                                  lat_o_rgon0_ibp_wr_done;
  wire                                  lat_o_rgon0_ibp_wr_excl_done;
  wire                                  lat_o_rgon0_ibp_err_wr;
  wire                                  lat_o_rgon0_ibp_wr_resp_accept;
    wire [4-1:0]    lat_o_rgon0_ibp_cmd_user;

  wire                                  pre_byp_rgon0_ibp_cmd_valid;
  wire                                  pre_byp_rgon0_ibp_cmd_accept;
  wire                                  pre_byp_rgon0_ibp_cmd_read;
  wire  [32                -1:0]       pre_byp_rgon0_ibp_cmd_addr;
  wire                                  pre_byp_rgon0_ibp_cmd_wrap;
  wire  [3-1:0]       pre_byp_rgon0_ibp_cmd_data_size;
  wire  [4-1:0]       pre_byp_rgon0_ibp_cmd_burst_size;
  wire  [2-1:0]       pre_byp_rgon0_ibp_cmd_prot;
  wire  [4-1:0]       pre_byp_rgon0_ibp_cmd_cache;
  wire                                  pre_byp_rgon0_ibp_cmd_lock;
  wire                                  pre_byp_rgon0_ibp_cmd_excl;

  wire                                  pre_byp_rgon0_ibp_rd_valid;
  wire                                  pre_byp_rgon0_ibp_rd_excl_ok;
  wire                                  pre_byp_rgon0_ibp_rd_accept;
  wire                                  pre_byp_rgon0_ibp_err_rd;
  wire  [128               -1:0]        pre_byp_rgon0_ibp_rd_data;
  wire                                  pre_byp_rgon0_ibp_rd_last;

  wire                                  pre_byp_rgon0_ibp_wr_valid;
  wire                                  pre_byp_rgon0_ibp_wr_accept;
  wire  [128               -1:0]        pre_byp_rgon0_ibp_wr_data;
  wire  [(128         /8)  -1:0]        pre_byp_rgon0_ibp_wr_mask;
  wire                                  pre_byp_rgon0_ibp_wr_last;

  wire                                  pre_byp_rgon0_ibp_wr_done;
  wire                                  pre_byp_rgon0_ibp_wr_excl_done;
  wire                                  pre_byp_rgon0_ibp_err_wr;
  wire                                  pre_byp_rgon0_ibp_wr_resp_accept;
    wire [4-1:0]    pre_byp_rgon0_ibp_cmd_user;




 wire [1-1:0] pre_byp_rgon0_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_byp_rgon0_ibp_cmd_chnl_accept;
 wire [49 * 1 -1:0] pre_byp_rgon0_ibp_cmd_chnl;

 wire [1-1:0] pre_byp_rgon0_ibp_wd_chnl_valid;
 wire [1-1:0] pre_byp_rgon0_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] pre_byp_rgon0_ibp_wd_chnl;

 wire [1-1:0] pre_byp_rgon0_ibp_rd_chnl_accept;
 wire [1-1:0] pre_byp_rgon0_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] pre_byp_rgon0_ibp_rd_chnl;

 wire [1-1:0] pre_byp_rgon0_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_byp_rgon0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_byp_rgon0_ibp_wrsp_chnl;

    wire [4-1:0]    pre_byp_rgon0_ibp_cmd_chnl_user;




 wire [1-1:0] pre_bind_rgon0_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_rgon0_ibp_cmd_chnl_accept;
 wire [49 * 1 -1:0] pre_bind_rgon0_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_rgon0_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_rgon0_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] pre_bind_rgon0_ibp_wd_chnl;

 wire [1-1:0] pre_bind_rgon0_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_rgon0_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] pre_bind_rgon0_ibp_rd_chnl;

 wire [1-1:0] pre_bind_rgon0_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_rgon0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_rgon0_ibp_wrsp_chnl;

    wire [4-1:0]    pre_bind_rgon0_ibp_cmd_chnl_user;

  wire                                  bind_rgon0_ibp_cmd_valid;
  wire                                  bind_rgon0_ibp_cmd_accept;
  wire                                  bind_rgon0_ibp_cmd_read;
  wire  [32                -1:0]       bind_rgon0_ibp_cmd_addr;
  wire                                  bind_rgon0_ibp_cmd_wrap;
  wire  [3-1:0]       bind_rgon0_ibp_cmd_data_size;
  wire  [4-1:0]       bind_rgon0_ibp_cmd_burst_size;
  wire  [2-1:0]       bind_rgon0_ibp_cmd_prot;
  wire  [4-1:0]       bind_rgon0_ibp_cmd_cache;
  wire                                  bind_rgon0_ibp_cmd_lock;
  wire                                  bind_rgon0_ibp_cmd_excl;

  wire                                  bind_rgon0_ibp_rd_valid;
  wire                                  bind_rgon0_ibp_rd_excl_ok;
  wire                                  bind_rgon0_ibp_rd_accept;
  wire                                  bind_rgon0_ibp_err_rd;
  wire  [128               -1:0]        bind_rgon0_ibp_rd_data;
  wire                                  bind_rgon0_ibp_rd_last;

  wire                                  bind_rgon0_ibp_wr_valid;
  wire                                  bind_rgon0_ibp_wr_accept;
  wire  [128               -1:0]        bind_rgon0_ibp_wr_data;
  wire  [(128         /8)  -1:0]        bind_rgon0_ibp_wr_mask;
  wire                                  bind_rgon0_ibp_wr_last;

  wire                                  bind_rgon0_ibp_wr_done;
  wire                                  bind_rgon0_ibp_wr_excl_done;
  wire                                  bind_rgon0_ibp_err_wr;
  wire                                  bind_rgon0_ibp_wr_resp_accept;
    wire [4-1:0]    bind_rgon0_ibp_cmd_user;




 wire [1-1:0] bind_rgon0_ibp_cmd_chnl_valid;
 wire [1-1:0] bind_rgon0_ibp_cmd_chnl_accept;
 wire [49 * 1 -1:0] bind_rgon0_ibp_cmd_chnl;

 wire [1-1:0] bind_rgon0_ibp_wd_chnl_valid;
 wire [1-1:0] bind_rgon0_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] bind_rgon0_ibp_wd_chnl;

 wire [1-1:0] bind_rgon0_ibp_rd_chnl_accept;
 wire [1-1:0] bind_rgon0_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] bind_rgon0_ibp_rd_chnl;

 wire [1-1:0] bind_rgon0_ibp_wrsp_chnl_valid;
 wire [1-1:0] bind_rgon0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bind_rgon0_ibp_wrsp_chnl;

    wire [4-1:0]    bind_rgon0_ibp_cmd_chnl_user;
    wire bind_rgon0_i_mem_cs;
    wire bind_rgon0_i_mem_we;
    wire [128/8-1:0]  bind_rgon0_i_mem_bwe;
    wire [32-1:4] bind_rgon0_i_mem_addr;
    wire [128-1:0]    bind_rgon0_i_mem_wdata;
    wire [128-1:0]    bind_rgon0_i_mem_rdata;



    // Buffer Unit to cut-down combination loop and generate correct sequence for IBP protocol's cmd channel and write data channel relationship
    alb_mss_mem_ibp_buf #(.id_w(6),
                          .rg_w(1),
                          .u_w(4),
                          .a_w(32),
                          .d_w(128)) u_ibp_buf_inst(
                                                 .clk(mss_clk),
                                                 .rst_b(rst_b),
                                                 .i_ibp_cmd_valid(mss_mem_cmd_valid),
                                                 .i_ibp_cmd_accept(mss_mem_cmd_accept),
                                                 .i_ibp_cmd_read(mss_mem_cmd_read),
                                                 .i_ibp_cmd_addr(mss_mem_cmd_addr),
                                                 .i_ibp_cmd_wrap(mss_mem_cmd_wrap),
                                                 .i_ibp_cmd_data_size(mss_mem_cmd_data_size),
                                                 .i_ibp_cmd_burst_size(mss_mem_cmd_burst_size),
                                                 .i_ibp_cmd_prot(mss_mem_cmd_prot),
                                                 .i_ibp_cmd_cache(mss_mem_cmd_cache),
                                                 .i_ibp_cmd_lock(mss_mem_cmd_lock),
                                                 .i_ibp_cmd_excl(mss_mem_cmd_excl),
                                                 .i_ibp_cmd_id(mss_mem_cmd_id),
                                                 .i_ibp_cmd_user(mss_mem_cmd_user),
                                                 .i_ibp_cmd_region(mss_mem_cmd_region),
                                                 .i_ibp_wr_valid(mss_mem_wr_valid),
                                                 .i_ibp_wr_accept(mss_mem_wr_accept),
                                                 .i_ibp_wr_data(mss_mem_wr_data),
                                                 .i_ibp_wr_mask(mss_mem_wr_mask),
                                                 .i_ibp_wr_last(mss_mem_wr_last),

                                                 .o_ibp_cmd_valid(buf_ibp_cmd_valid),
                                                 .o_ibp_cmd_accept(buf_ibp_cmd_accept),
                                                 .o_ibp_cmd_read(buf_ibp_cmd_read),
                                                 .o_ibp_cmd_addr(buf_ibp_cmd_addr),
                                                 .o_ibp_cmd_wrap(buf_ibp_cmd_wrap),
                                                 .o_ibp_cmd_data_size(buf_ibp_cmd_data_size),
                                                 .o_ibp_cmd_burst_size(buf_ibp_cmd_burst_size),
                                                 .o_ibp_cmd_prot(buf_ibp_cmd_prot),
                                                 .o_ibp_cmd_cache(buf_ibp_cmd_cache),
                                                 .o_ibp_cmd_lock(buf_ibp_cmd_lock),
                                                 .o_ibp_cmd_excl(buf_ibp_cmd_excl),
                                                 .o_ibp_cmd_id(buf_ibp_cmd_id),
                                                 .o_ibp_cmd_user(buf_ibp_cmd_user),
                                                 .o_ibp_cmd_region(buf_ibp_cmd_region),
                                                 .o_ibp_wr_valid(buf_ibp_wr_valid),
                                                 .o_ibp_wr_accept(buf_ibp_wr_accept),
                                                 .o_ibp_wr_data(buf_ibp_wr_data),
                                                 .o_ibp_wr_mask(buf_ibp_wr_mask),
                                                 .o_ibp_wr_last(buf_ibp_wr_last)
                                                 );

    // Exclusive Monidtore Hardware
    alb_mss_mem_ibp_excl #(
                           .port_id_w(2),
                           .port_id_msb(6-1),
                           .port_id_lsb(6-2),
                           .u_w(4),
                           .id_w(6),
                           .rg_w(1),
                           .a_w(32),
                           .d_w(128)) u_mem_exclusive_monitor(.clk(mss_clk),
                                                           .rst_b(rst_b),

                                                           .i_ibp_cmd_valid(buf_ibp_cmd_valid),
                                                           .i_ibp_cmd_accept(buf_ibp_cmd_accept),
                                                           .i_ibp_cmd_read(buf_ibp_cmd_read),
                                                           .i_ibp_cmd_addr(buf_ibp_cmd_addr),
                                                           .i_ibp_cmd_wrap(buf_ibp_cmd_wrap),
                                                           .i_ibp_cmd_data_size(buf_ibp_cmd_data_size),
                                                           .i_ibp_cmd_burst_size(buf_ibp_cmd_burst_size),
                                                           .i_ibp_cmd_prot(buf_ibp_cmd_prot),
                                                           .i_ibp_cmd_cache(buf_ibp_cmd_cache),
                                                           .i_ibp_cmd_lock(buf_ibp_cmd_lock),
                                                           .i_ibp_cmd_excl(buf_ibp_cmd_excl),
                                                           .i_ibp_cmd_id(buf_ibp_cmd_id),
                                                           .i_ibp_cmd_user(buf_ibp_cmd_user),
                                                           .i_ibp_cmd_region(buf_ibp_cmd_region),

                                                           .i_ibp_rd_valid(mss_mem_rd_valid),
                                                           .i_ibp_rd_accept(mss_mem_rd_accept),
                                                           .i_ibp_rd_data(mss_mem_rd_data),
                                                           .i_ibp_err_rd(mss_mem_err_rd),
                                                           .i_ibp_rd_last(mss_mem_rd_last),
                                                           .i_ibp_rd_excl_ok(mss_mem_rd_excl_ok),
                                                           .i_ibp_wr_valid(buf_ibp_wr_valid),
                                                           .i_ibp_wr_accept(buf_ibp_wr_accept),
                                                           .i_ibp_wr_data(buf_ibp_wr_data),
                                                           .i_ibp_wr_mask(buf_ibp_wr_mask),
                                                           .i_ibp_wr_last(buf_ibp_wr_last),
                                                           .i_ibp_wr_done(mss_mem_wr_done),
                                                           .i_ibp_wr_resp_accept(mss_mem_wr_resp_accept),
                                                           .i_ibp_wr_excl_done(mss_mem_wr_excl_done),
                                                           .i_ibp_err_wr(mss_mem_err_wr),


  .o_ibp_cmd_valid             (splt_i_ibp_cmd_valid),
  .o_ibp_cmd_accept            (splt_i_ibp_cmd_accept),
  .o_ibp_cmd_read              (splt_i_ibp_cmd_read),
  .o_ibp_cmd_addr              (splt_i_ibp_cmd_addr),
  .o_ibp_cmd_wrap              (splt_i_ibp_cmd_wrap),
  .o_ibp_cmd_data_size         (splt_i_ibp_cmd_data_size),
  .o_ibp_cmd_burst_size        (splt_i_ibp_cmd_burst_size),
  .o_ibp_cmd_prot              (splt_i_ibp_cmd_prot),
  .o_ibp_cmd_cache             (splt_i_ibp_cmd_cache),
  .o_ibp_cmd_lock              (splt_i_ibp_cmd_lock),
  .o_ibp_cmd_excl              (splt_i_ibp_cmd_excl),

  .o_ibp_rd_valid              (splt_i_ibp_rd_valid),
  .o_ibp_rd_excl_ok            (splt_i_ibp_rd_excl_ok),
  .o_ibp_rd_accept             (splt_i_ibp_rd_accept),
  .o_ibp_err_rd                (splt_i_ibp_err_rd),
  .o_ibp_rd_data               (splt_i_ibp_rd_data),
  .o_ibp_rd_last               (splt_i_ibp_rd_last),

  .o_ibp_wr_valid              (splt_i_ibp_wr_valid),
  .o_ibp_wr_accept             (splt_i_ibp_wr_accept),
  .o_ibp_wr_data               (splt_i_ibp_wr_data),
  .o_ibp_wr_mask               (splt_i_ibp_wr_mask),
  .o_ibp_wr_last               (splt_i_ibp_wr_last),

  .o_ibp_wr_done               (splt_i_ibp_wr_done),
  .o_ibp_wr_excl_done          (splt_i_ibp_wr_excl_done),
  .o_ibp_err_wr                (splt_i_ibp_err_wr),
  .o_ibp_wr_resp_accept        (splt_i_ibp_wr_resp_accept),
                                                           .o_ibp_cmd_user(splt_i_cmd_user),
                                                           .o_ibp_cmd_region(splt_i_cmd_region)
                                                           );
    // pack IBP signals
    alb_mss_mem_ibp2pack #(
                           .ADDR_W(32),
                           .DATA_W(128),
                           .USER_W(4),



    .CMD_CHNL_READ           (0),
    .CMD_CHNL_WRAP           (1),
    .CMD_CHNL_DATA_SIZE_LSB  (2),
    .CMD_CHNL_DATA_SIZE_W    (3),
    .CMD_CHNL_BURST_SIZE_LSB (5),
    .CMD_CHNL_BURST_SIZE_W   (4),
    .CMD_CHNL_PROT_LSB       (9),
    .CMD_CHNL_PROT_W         (2),
    .CMD_CHNL_CACHE_LSB      (11),
    .CMD_CHNL_CACHE_W        (4),
    .CMD_CHNL_LOCK           (15),
    .CMD_CHNL_EXCL           (16),
    .CMD_CHNL_ADDR_LSB       (17),
    .CMD_CHNL_ADDR_W         (32),
    .CMD_CHNL_W              (49),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (128),
    .WD_CHNL_MASK_LSB        (129),
    .WD_CHNL_MASK_W          (16),
    .WD_CHNL_W               (145),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (128),
    .RD_CHNL_W               (131),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_ibp2pack_inst(
                           .ibp_cmd_rgon(splt_i_cmd_region),
                           .ibp_cmd_user(splt_i_cmd_user),

  .ibp_cmd_valid             (splt_i_ibp_cmd_valid),
  .ibp_cmd_accept            (splt_i_ibp_cmd_accept),
  .ibp_cmd_read              (splt_i_ibp_cmd_read),
  .ibp_cmd_addr              (splt_i_ibp_cmd_addr),
  .ibp_cmd_wrap              (splt_i_ibp_cmd_wrap),
  .ibp_cmd_data_size         (splt_i_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (splt_i_ibp_cmd_burst_size),
  .ibp_cmd_prot              (splt_i_ibp_cmd_prot),
  .ibp_cmd_cache             (splt_i_ibp_cmd_cache),
  .ibp_cmd_lock              (splt_i_ibp_cmd_lock),
  .ibp_cmd_excl              (splt_i_ibp_cmd_excl),

  .ibp_rd_valid              (splt_i_ibp_rd_valid),
  .ibp_rd_excl_ok            (splt_i_ibp_rd_excl_ok),
  .ibp_rd_accept             (splt_i_ibp_rd_accept),
  .ibp_err_rd                (splt_i_ibp_err_rd),
  .ibp_rd_data               (splt_i_ibp_rd_data),
  .ibp_rd_last               (splt_i_ibp_rd_last),

  .ibp_wr_valid              (splt_i_ibp_wr_valid),
  .ibp_wr_accept             (splt_i_ibp_wr_accept),
  .ibp_wr_data               (splt_i_ibp_wr_data),
  .ibp_wr_mask               (splt_i_ibp_wr_mask),
  .ibp_wr_last               (splt_i_ibp_wr_last),

  .ibp_wr_done               (splt_i_ibp_wr_done),
  .ibp_wr_excl_done          (splt_i_ibp_wr_excl_done),
  .ibp_err_wr                (splt_i_ibp_err_wr),
  .ibp_wr_resp_accept        (splt_i_ibp_wr_resp_accept),




    .ibp_cmd_chnl_valid  (splt_i_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (splt_i_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (splt_i_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (splt_i_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (splt_i_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (splt_i_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (splt_i_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (splt_i_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (splt_i_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (splt_i_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(splt_i_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (splt_i_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_user(splt_i_cmd_chnl_user),
                           .ibp_cmd_chnl_rgon(splt_i_cmd_chnl_region),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );

    // IBP splitter



    assign split_0_ibp_rgon_hit = (splt_i_cmd_chnl_region == 0);

    assign {
          splt_indicator_dummy,
          splt_i_indicator
           } = {1'b0
       , split_0_ibp_rgon_hit
           };

    alb_mss_mem_ibp_split #(
                            .SPLT_NUM(1),



    .CMD_CHNL_READ           (0),
    .CMD_CHNL_WRAP           (1),
    .CMD_CHNL_DATA_SIZE_LSB  (2),
    .CMD_CHNL_DATA_SIZE_W    (3),
    .CMD_CHNL_BURST_SIZE_LSB (5),
    .CMD_CHNL_BURST_SIZE_W   (4),
    .CMD_CHNL_PROT_LSB       (9),
    .CMD_CHNL_PROT_W         (2),
    .CMD_CHNL_CACHE_LSB      (11),
    .CMD_CHNL_CACHE_W        (4),
    .CMD_CHNL_LOCK           (15),
    .CMD_CHNL_EXCL           (16),
    .CMD_CHNL_ADDR_LSB       (17),
    .CMD_CHNL_ADDR_W         (32),
    .CMD_CHNL_W              (49),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (128),
    .WD_CHNL_MASK_LSB        (129),
    .WD_CHNL_MASK_W          (16),
    .WD_CHNL_W               (145),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (128),
    .RD_CHNL_W               (131),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                            .USER_W(4),
                            .SPLT_FIFO_DEPTH(16),
                            .SPLT_FIFO_WIDTH(1)
                            ) u_ibp_splitter (
                            .i_ibp_split_indicator(splt_i_indicator),
                            .i_ibp_cmd_chnl_user(splt_i_cmd_chnl_user),




    .i_ibp_cmd_chnl_valid  (splt_i_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (splt_i_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (splt_i_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (splt_i_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (splt_i_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (splt_i_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (splt_i_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (splt_i_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (splt_i_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (splt_i_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(splt_i_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (splt_i_ibp_wrsp_chnl),





    .o_bus_ibp_cmd_chnl_valid  (splt_o_bus_ibp_cmd_chnl_valid),
    .o_bus_ibp_cmd_chnl_accept (splt_o_bus_ibp_cmd_chnl_accept),
    .o_bus_ibp_cmd_chnl        (splt_o_bus_ibp_cmd_chnl),

    .o_bus_ibp_rd_chnl_valid   (splt_o_bus_ibp_rd_chnl_valid),
    .o_bus_ibp_rd_chnl_accept  (splt_o_bus_ibp_rd_chnl_accept),
    .o_bus_ibp_rd_chnl         (splt_o_bus_ibp_rd_chnl),

    .o_bus_ibp_wd_chnl_valid   (splt_o_bus_ibp_wd_chnl_valid),
    .o_bus_ibp_wd_chnl_accept  (splt_o_bus_ibp_wd_chnl_accept),
    .o_bus_ibp_wd_chnl         (splt_o_bus_ibp_wd_chnl),

    .o_bus_ibp_wrsp_chnl_valid (splt_o_bus_ibp_wrsp_chnl_valid),
    .o_bus_ibp_wrsp_chnl_accept(splt_o_bus_ibp_wrsp_chnl_accept),
    .o_bus_ibp_wrsp_chnl       (splt_o_bus_ibp_wrsp_chnl),

                            .o_bus_ibp_cmd_chnl_user(splt_o_bus_ibp_cmd_chnl_user),
                            .clk(mss_clk),
                            .rst_a(~rst_b)
                            );

   //split the bus into each IBP channel
   assign {
           splt_dummy0
       , split_0_ibp_cmd_chnl
       , split_0_ibp_cmd_chnl_user
       , split_0_ibp_cmd_chnl_valid
       , split_0_ibp_wd_chnl
       , split_0_ibp_wd_chnl_valid
       , split_0_ibp_rd_chnl_accept
       , split_0_ibp_wrsp_chnl_accept
          }
          = { 1'b1,
              splt_o_bus_ibp_cmd_chnl,
              splt_o_bus_ibp_cmd_chnl_user,
              splt_o_bus_ibp_cmd_chnl_valid,
              splt_o_bus_ibp_wd_chnl,
              splt_o_bus_ibp_wd_chnl_valid,
              splt_o_bus_ibp_rd_chnl_accept,
              splt_o_bus_ibp_wrsp_chnl_accept
          };

   assign {
           splt_dummy1,
           splt_o_bus_ibp_rd_chnl,
           splt_o_bus_ibp_rd_chnl_valid,
           splt_o_bus_ibp_wrsp_chnl,
           splt_o_bus_ibp_wrsp_chnl_valid,
           splt_o_bus_ibp_cmd_chnl_accept,
           splt_o_bus_ibp_wd_chnl_accept
           } = { 1'b1
       , split_0_ibp_rd_chnl
       , split_0_ibp_rd_chnl_valid
       , split_0_ibp_wrsp_chnl
       , split_0_ibp_wrsp_chnl_valid
       , split_0_ibp_cmd_chnl_accept
       , split_0_ibp_wd_chnl_accept
           };


    // route transaction to each region of SRAMCtrl


      //unpack IBP
      alb_mss_mem_pack2ibp #(
                           .ADDR_W(32),
                           .DATA_W(128),
                           .USER_W(4),



    .CMD_CHNL_READ           (0),
    .CMD_CHNL_WRAP           (1),
    .CMD_CHNL_DATA_SIZE_LSB  (2),
    .CMD_CHNL_DATA_SIZE_W    (3),
    .CMD_CHNL_BURST_SIZE_LSB (5),
    .CMD_CHNL_BURST_SIZE_W   (4),
    .CMD_CHNL_PROT_LSB       (9),
    .CMD_CHNL_PROT_W         (2),
    .CMD_CHNL_CACHE_LSB      (11),
    .CMD_CHNL_CACHE_W        (4),
    .CMD_CHNL_LOCK           (15),
    .CMD_CHNL_EXCL           (16),
    .CMD_CHNL_ADDR_LSB       (17),
    .CMD_CHNL_ADDR_W         (32),
    .CMD_CHNL_W              (49),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (128),
    .WD_CHNL_MASK_LSB        (129),
    .WD_CHNL_MASK_W          (16),
    .WD_CHNL_W               (145),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (128),
    .RD_CHNL_W               (131),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_rgon0_pack2ibp_inst_1(
                           .ibp_cmd_rgon(),
                           .ibp_cmd_user(split_0_ibp_cmd_user),

  .ibp_cmd_valid             (split_0_ibp_cmd_valid),
  .ibp_cmd_accept            (split_0_ibp_cmd_accept),
  .ibp_cmd_read              (split_0_ibp_cmd_read),
  .ibp_cmd_addr              (split_0_ibp_cmd_addr),
  .ibp_cmd_wrap              (split_0_ibp_cmd_wrap),
  .ibp_cmd_data_size         (split_0_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (split_0_ibp_cmd_burst_size),
  .ibp_cmd_prot              (split_0_ibp_cmd_prot),
  .ibp_cmd_cache             (split_0_ibp_cmd_cache),
  .ibp_cmd_lock              (split_0_ibp_cmd_lock),
  .ibp_cmd_excl              (split_0_ibp_cmd_excl),

  .ibp_rd_valid              (split_0_ibp_rd_valid),
  .ibp_rd_excl_ok            (split_0_ibp_rd_excl_ok),
  .ibp_rd_accept             (split_0_ibp_rd_accept),
  .ibp_err_rd                (split_0_ibp_err_rd),
  .ibp_rd_data               (split_0_ibp_rd_data),
  .ibp_rd_last               (split_0_ibp_rd_last),

  .ibp_wr_valid              (split_0_ibp_wr_valid),
  .ibp_wr_accept             (split_0_ibp_wr_accept),
  .ibp_wr_data               (split_0_ibp_wr_data),
  .ibp_wr_mask               (split_0_ibp_wr_mask),
  .ibp_wr_last               (split_0_ibp_wr_last),

  .ibp_wr_done               (split_0_ibp_wr_done),
  .ibp_wr_excl_done          (split_0_ibp_wr_excl_done),
  .ibp_err_wr                (split_0_ibp_err_wr),
  .ibp_wr_resp_accept        (split_0_ibp_wr_resp_accept),




    .ibp_cmd_chnl_valid  (split_0_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (split_0_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (split_0_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (split_0_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (split_0_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (split_0_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (split_0_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (split_0_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (split_0_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (split_0_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(split_0_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (split_0_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_user(split_0_ibp_cmd_chnl_user),
                           .ibp_cmd_chnl_rgon(1'b0)
                           );

    // Latency unit
    alb_mss_mem_ibp_lat #(.a_w(32),
                      .d_w(128),
                      .u_w(4),
                      .depl2(10)) u_rgon0_lat_inst(.clk(mss_clk),
                                                 .clk_en(1'b1),
                                                 .rst_b(rst_b),

                                                 .i_ibp_cmd_valid(split_0_ibp_cmd_valid),
                                                 .i_ibp_cmd_accept(split_0_ibp_cmd_accept),
                                                 .i_ibp_cmd_read(split_0_ibp_cmd_read),
                                                 .i_ibp_cmd_addr(split_0_ibp_cmd_addr[32-1:0]),
                                                 .i_ibp_cmd_wrap(split_0_ibp_cmd_wrap),
                                                 .i_ibp_cmd_data_size(split_0_ibp_cmd_data_size),
                                                 .i_ibp_cmd_burst_size(split_0_ibp_cmd_burst_size),
                                                 .i_ibp_cmd_lock(split_0_ibp_cmd_lock),
                                                 .i_ibp_cmd_excl(split_0_ibp_cmd_excl),
                                                 .i_ibp_cmd_prot(split_0_ibp_cmd_prot),
                                                 .i_ibp_cmd_cache(split_0_ibp_cmd_cache),
                                                 .i_ibp_cmd_user(split_0_ibp_cmd_user),
                                                 .i_ibp_rd_valid(split_0_ibp_rd_valid),
                                                 .i_ibp_rd_accept(split_0_ibp_rd_accept),
                                                 .i_ibp_rd_data(split_0_ibp_rd_data),
                                                 .i_ibp_rd_last(split_0_ibp_rd_last),
                                                 .i_ibp_err_rd(split_0_ibp_err_rd),
                                                 .i_ibp_rd_excl_ok(split_0_ibp_rd_excl_ok),
                                                 .i_ibp_wr_valid(split_0_ibp_wr_valid),
                                                 .i_ibp_wr_accept(split_0_ibp_wr_accept),
                                                 .i_ibp_wr_data(split_0_ibp_wr_data),
                                                 .i_ibp_wr_mask(split_0_ibp_wr_mask),
                                                 .i_ibp_wr_last(split_0_ibp_wr_last),
                                                 .i_ibp_wr_done(split_0_ibp_wr_done),
                                                 .i_ibp_wr_excl_done(split_0_ibp_wr_excl_done),
                                                 .i_ibp_err_wr(split_0_ibp_err_wr),
                                                 .i_ibp_wr_resp_accept(split_0_ibp_wr_resp_accept),

  .o_ibp_cmd_valid             (lat_o_rgon0_ibp_cmd_valid),
  .o_ibp_cmd_accept            (lat_o_rgon0_ibp_cmd_accept),
  .o_ibp_cmd_read              (lat_o_rgon0_ibp_cmd_read),
  .o_ibp_cmd_addr              (lat_o_rgon0_ibp_cmd_addr),
  .o_ibp_cmd_wrap              (lat_o_rgon0_ibp_cmd_wrap),
  .o_ibp_cmd_data_size         (lat_o_rgon0_ibp_cmd_data_size),
  .o_ibp_cmd_burst_size        (lat_o_rgon0_ibp_cmd_burst_size),
  .o_ibp_cmd_prot              (lat_o_rgon0_ibp_cmd_prot),
  .o_ibp_cmd_cache             (lat_o_rgon0_ibp_cmd_cache),
  .o_ibp_cmd_lock              (lat_o_rgon0_ibp_cmd_lock),
  .o_ibp_cmd_excl              (lat_o_rgon0_ibp_cmd_excl),

  .o_ibp_rd_valid              (lat_o_rgon0_ibp_rd_valid),
  .o_ibp_rd_excl_ok            (lat_o_rgon0_ibp_rd_excl_ok),
  .o_ibp_rd_accept             (lat_o_rgon0_ibp_rd_accept),
  .o_ibp_err_rd                (lat_o_rgon0_ibp_err_rd),
  .o_ibp_rd_data               (lat_o_rgon0_ibp_rd_data),
  .o_ibp_rd_last               (lat_o_rgon0_ibp_rd_last),

  .o_ibp_wr_valid              (lat_o_rgon0_ibp_wr_valid),
  .o_ibp_wr_accept             (lat_o_rgon0_ibp_wr_accept),
  .o_ibp_wr_data               (lat_o_rgon0_ibp_wr_data),
  .o_ibp_wr_mask               (lat_o_rgon0_ibp_wr_mask),
  .o_ibp_wr_last               (lat_o_rgon0_ibp_wr_last),

  .o_ibp_wr_done               (lat_o_rgon0_ibp_wr_done),
  .o_ibp_wr_excl_done          (lat_o_rgon0_ibp_wr_excl_done),
  .o_ibp_err_wr                (lat_o_rgon0_ibp_err_wr),
  .o_ibp_wr_resp_accept        (lat_o_rgon0_ibp_wr_resp_accept),
                                                 .o_ibp_cmd_user(lat_o_rgon0_ibp_cmd_user),

                                                 .cfg_lat_w(mss_mem_cfg_lat_w[10*(1-0-1)+:10]),
                                                 .cfg_lat_r(mss_mem_cfg_lat_r[10*(1-0-1)+:10]),
                                                 .perf_awf(mss_mem_perf_awf[0]),
                                                 .perf_arf(mss_mem_perf_arf[0]),
                                                 .perf_aw(mss_mem_perf_aw[0]),
                                                 .perf_ar(mss_mem_perf_ar[0]),
                                                 .perf_w(mss_mem_perf_w[0]),
                                                 .perf_wl(mss_mem_perf_wl[0]),
                                                 .perf_r(mss_mem_perf_r[0]),
                                                 .perf_rl(mss_mem_perf_rl[0]),
                                                 .perf_b(mss_mem_perf_b[0]));

    // burst2single
    alb_mss_mem_ibp2single #(.ADDR_W(32),
                           .DATA_W(128),
                           .USER_W(4),
                           .RGON_W(1)
                           ) u_rgon0_ibp2single (
                           .clk(mss_clk),
                           .rst_a(~rst_b),

  .i_ibp_cmd_valid             (lat_o_rgon0_ibp_cmd_valid),
  .i_ibp_cmd_accept            (lat_o_rgon0_ibp_cmd_accept),
  .i_ibp_cmd_read              (lat_o_rgon0_ibp_cmd_read),
  .i_ibp_cmd_addr              (lat_o_rgon0_ibp_cmd_addr),
  .i_ibp_cmd_wrap              (lat_o_rgon0_ibp_cmd_wrap),
  .i_ibp_cmd_data_size         (lat_o_rgon0_ibp_cmd_data_size),
  .i_ibp_cmd_burst_size        (lat_o_rgon0_ibp_cmd_burst_size),
  .i_ibp_cmd_prot              (lat_o_rgon0_ibp_cmd_prot),
  .i_ibp_cmd_cache             (lat_o_rgon0_ibp_cmd_cache),
  .i_ibp_cmd_lock              (lat_o_rgon0_ibp_cmd_lock),
  .i_ibp_cmd_excl              (lat_o_rgon0_ibp_cmd_excl),

  .i_ibp_rd_valid              (lat_o_rgon0_ibp_rd_valid),
  .i_ibp_rd_excl_ok            (lat_o_rgon0_ibp_rd_excl_ok),
  .i_ibp_rd_accept             (lat_o_rgon0_ibp_rd_accept),
  .i_ibp_err_rd                (lat_o_rgon0_ibp_err_rd),
  .i_ibp_rd_data               (lat_o_rgon0_ibp_rd_data),
  .i_ibp_rd_last               (lat_o_rgon0_ibp_rd_last),

  .i_ibp_wr_valid              (lat_o_rgon0_ibp_wr_valid),
  .i_ibp_wr_accept             (lat_o_rgon0_ibp_wr_accept),
  .i_ibp_wr_data               (lat_o_rgon0_ibp_wr_data),
  .i_ibp_wr_mask               (lat_o_rgon0_ibp_wr_mask),
  .i_ibp_wr_last               (lat_o_rgon0_ibp_wr_last),

  .i_ibp_wr_done               (lat_o_rgon0_ibp_wr_done),
  .i_ibp_wr_excl_done          (lat_o_rgon0_ibp_wr_excl_done),
  .i_ibp_err_wr                (lat_o_rgon0_ibp_err_wr),
  .i_ibp_wr_resp_accept        (lat_o_rgon0_ibp_wr_resp_accept),
                           .i_ibp_cmd_user(lat_o_rgon0_ibp_cmd_user),
                           .i_ibp_cmd_rgon(1'b0),

  .o_ibp_cmd_valid             (pre_byp_rgon0_ibp_cmd_valid),
  .o_ibp_cmd_accept            (pre_byp_rgon0_ibp_cmd_accept),
  .o_ibp_cmd_read              (pre_byp_rgon0_ibp_cmd_read),
  .o_ibp_cmd_addr              (pre_byp_rgon0_ibp_cmd_addr),
  .o_ibp_cmd_wrap              (pre_byp_rgon0_ibp_cmd_wrap),
  .o_ibp_cmd_data_size         (pre_byp_rgon0_ibp_cmd_data_size),
  .o_ibp_cmd_burst_size        (pre_byp_rgon0_ibp_cmd_burst_size),
  .o_ibp_cmd_prot              (pre_byp_rgon0_ibp_cmd_prot),
  .o_ibp_cmd_cache             (pre_byp_rgon0_ibp_cmd_cache),
  .o_ibp_cmd_lock              (pre_byp_rgon0_ibp_cmd_lock),
  .o_ibp_cmd_excl              (pre_byp_rgon0_ibp_cmd_excl),

  .o_ibp_rd_valid              (pre_byp_rgon0_ibp_rd_valid),
  .o_ibp_rd_excl_ok            (pre_byp_rgon0_ibp_rd_excl_ok),
  .o_ibp_rd_accept             (pre_byp_rgon0_ibp_rd_accept),
  .o_ibp_err_rd                (pre_byp_rgon0_ibp_err_rd),
  .o_ibp_rd_data               (pre_byp_rgon0_ibp_rd_data),
  .o_ibp_rd_last               (pre_byp_rgon0_ibp_rd_last),

  .o_ibp_wr_valid              (pre_byp_rgon0_ibp_wr_valid),
  .o_ibp_wr_accept             (pre_byp_rgon0_ibp_wr_accept),
  .o_ibp_wr_data               (pre_byp_rgon0_ibp_wr_data),
  .o_ibp_wr_mask               (pre_byp_rgon0_ibp_wr_mask),
  .o_ibp_wr_last               (pre_byp_rgon0_ibp_wr_last),

  .o_ibp_wr_done               (pre_byp_rgon0_ibp_wr_done),
  .o_ibp_wr_excl_done          (pre_byp_rgon0_ibp_wr_excl_done),
  .o_ibp_err_wr                (pre_byp_rgon0_ibp_err_wr),
  .o_ibp_wr_resp_accept        (pre_byp_rgon0_ibp_wr_resp_accept),
                           .o_ibp_cmd_burst_en   (),
                           .o_ibp_cmd_burst_type (),
                           .o_ibp_cmd_burst_last (),
                           .o_ibp_cmd_user(pre_byp_rgon0_ibp_cmd_user),
                           .o_ibp_cmd_rgon()
                           );

    // pack IBP signals
    alb_mss_mem_ibp2pack #(
                           .ADDR_W(32),
                           .DATA_W(128),
                           .USER_W(4),



    .CMD_CHNL_READ           (0),
    .CMD_CHNL_WRAP           (1),
    .CMD_CHNL_DATA_SIZE_LSB  (2),
    .CMD_CHNL_DATA_SIZE_W    (3),
    .CMD_CHNL_BURST_SIZE_LSB (5),
    .CMD_CHNL_BURST_SIZE_W   (4),
    .CMD_CHNL_PROT_LSB       (9),
    .CMD_CHNL_PROT_W         (2),
    .CMD_CHNL_CACHE_LSB      (11),
    .CMD_CHNL_CACHE_W        (4),
    .CMD_CHNL_LOCK           (15),
    .CMD_CHNL_EXCL           (16),
    .CMD_CHNL_ADDR_LSB       (17),
    .CMD_CHNL_ADDR_W         (32),
    .CMD_CHNL_W              (49),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (128),
    .WD_CHNL_MASK_LSB        (129),
    .WD_CHNL_MASK_W          (16),
    .WD_CHNL_W               (145),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (128),
    .RD_CHNL_W               (131),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_rgon0_ibp2pack_inst(
                           .ibp_cmd_rgon(1'b0),
                           .ibp_cmd_user(pre_byp_rgon0_ibp_cmd_user),

  .ibp_cmd_valid             (pre_byp_rgon0_ibp_cmd_valid),
  .ibp_cmd_accept            (pre_byp_rgon0_ibp_cmd_accept),
  .ibp_cmd_read              (pre_byp_rgon0_ibp_cmd_read),
  .ibp_cmd_addr              (pre_byp_rgon0_ibp_cmd_addr),
  .ibp_cmd_wrap              (pre_byp_rgon0_ibp_cmd_wrap),
  .ibp_cmd_data_size         (pre_byp_rgon0_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (pre_byp_rgon0_ibp_cmd_burst_size),
  .ibp_cmd_prot              (pre_byp_rgon0_ibp_cmd_prot),
  .ibp_cmd_cache             (pre_byp_rgon0_ibp_cmd_cache),
  .ibp_cmd_lock              (pre_byp_rgon0_ibp_cmd_lock),
  .ibp_cmd_excl              (pre_byp_rgon0_ibp_cmd_excl),

  .ibp_rd_valid              (pre_byp_rgon0_ibp_rd_valid),
  .ibp_rd_excl_ok            (pre_byp_rgon0_ibp_rd_excl_ok),
  .ibp_rd_accept             (pre_byp_rgon0_ibp_rd_accept),
  .ibp_err_rd                (pre_byp_rgon0_ibp_err_rd),
  .ibp_rd_data               (pre_byp_rgon0_ibp_rd_data),
  .ibp_rd_last               (pre_byp_rgon0_ibp_rd_last),

  .ibp_wr_valid              (pre_byp_rgon0_ibp_wr_valid),
  .ibp_wr_accept             (pre_byp_rgon0_ibp_wr_accept),
  .ibp_wr_data               (pre_byp_rgon0_ibp_wr_data),
  .ibp_wr_mask               (pre_byp_rgon0_ibp_wr_mask),
  .ibp_wr_last               (pre_byp_rgon0_ibp_wr_last),

  .ibp_wr_done               (pre_byp_rgon0_ibp_wr_done),
  .ibp_wr_excl_done          (pre_byp_rgon0_ibp_wr_excl_done),
  .ibp_err_wr                (pre_byp_rgon0_ibp_err_wr),
  .ibp_wr_resp_accept        (pre_byp_rgon0_ibp_wr_resp_accept),




    .ibp_cmd_chnl_valid  (pre_byp_rgon0_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (pre_byp_rgon0_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (pre_byp_rgon0_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (pre_byp_rgon0_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (pre_byp_rgon0_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (pre_byp_rgon0_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (pre_byp_rgon0_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (pre_byp_rgon0_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (pre_byp_rgon0_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (pre_byp_rgon0_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(pre_byp_rgon0_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (pre_byp_rgon0_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_user(pre_byp_rgon0_ibp_cmd_chnl_user),
                           .ibp_cmd_chnl_rgon(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );

    //insert bypass buffer to cut timing and provide correct response status
    alb_mss_mem_ibp_bypbuf #(



    .CMD_CHNL_READ           (0),
    .CMD_CHNL_WRAP           (1),
    .CMD_CHNL_DATA_SIZE_LSB  (2),
    .CMD_CHNL_DATA_SIZE_W    (3),
    .CMD_CHNL_BURST_SIZE_LSB (5),
    .CMD_CHNL_BURST_SIZE_W   (4),
    .CMD_CHNL_PROT_LSB       (9),
    .CMD_CHNL_PROT_W         (2),
    .CMD_CHNL_CACHE_LSB      (11),
    .CMD_CHNL_CACHE_W        (4),
    .CMD_CHNL_LOCK           (15),
    .CMD_CHNL_EXCL           (16),
    .CMD_CHNL_ADDR_LSB       (17),
    .CMD_CHNL_ADDR_W         (32),
    .CMD_CHNL_W              (49),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (128),
    .WD_CHNL_MASK_LSB        (129),
    .WD_CHNL_MASK_W          (16),
    .WD_CHNL_W               (145),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (128),
    .RD_CHNL_W               (131),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                            .RGON_W(1),
                            .USER_W(4)
                            ) u_rgon0_ibp_bypbuf (
                            .i_ibp_cmd_chnl_rgon(1'b0),




    .i_ibp_cmd_chnl_valid  (pre_byp_rgon0_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_byp_rgon0_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_byp_rgon0_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_byp_rgon0_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_byp_rgon0_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_byp_rgon0_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_byp_rgon0_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_byp_rgon0_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_byp_rgon0_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_byp_rgon0_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_byp_rgon0_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_byp_rgon0_ibp_wrsp_chnl),

                            .i_ibp_cmd_chnl_user(pre_byp_rgon0_ibp_cmd_chnl_user),




    .o_ibp_cmd_chnl_valid  (pre_bind_rgon0_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_rgon0_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_rgon0_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_rgon0_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_rgon0_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_rgon0_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_rgon0_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_rgon0_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_rgon0_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_rgon0_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_rgon0_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_rgon0_ibp_wrsp_chnl),

                             .o_ibp_cmd_chnl_rgon(),
                             .o_ibp_cmd_chnl_user(pre_bind_rgon0_ibp_cmd_chnl_user),
                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                            );
    //bind cmd channel with write data channel
    alb_mss_mem_ibp_cwbind #(



    .CMD_CHNL_READ           (0),
    .CMD_CHNL_WRAP           (1),
    .CMD_CHNL_DATA_SIZE_LSB  (2),
    .CMD_CHNL_DATA_SIZE_W    (3),
    .CMD_CHNL_BURST_SIZE_LSB (5),
    .CMD_CHNL_BURST_SIZE_W   (4),
    .CMD_CHNL_PROT_LSB       (9),
    .CMD_CHNL_PROT_W         (2),
    .CMD_CHNL_CACHE_LSB      (11),
    .CMD_CHNL_CACHE_W        (4),
    .CMD_CHNL_LOCK           (15),
    .CMD_CHNL_EXCL           (16),
    .CMD_CHNL_ADDR_LSB       (17),
    .CMD_CHNL_ADDR_W         (32),
    .CMD_CHNL_W              (49),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (128),
    .WD_CHNL_MASK_LSB        (129),
    .WD_CHNL_MASK_W          (16),
    .WD_CHNL_W               (145),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (128),
    .RD_CHNL_W               (131),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .OUT_CMD_CNT_W(6),
                           .OUT_CMD_NUM(64),
                           .O_RESP_ALWAYS_ACCEPT(0),
                           .USER_W(4),
                           .ENABLE_CWBIND (1)
                           ) u_rgon0_ibp_cwbind (




    .i_ibp_cmd_chnl_valid  (pre_bind_rgon0_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_rgon0_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_rgon0_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_rgon0_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_rgon0_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_rgon0_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_rgon0_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_rgon0_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_rgon0_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_rgon0_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_rgon0_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_rgon0_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (bind_rgon0_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (bind_rgon0_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (bind_rgon0_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (bind_rgon0_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (bind_rgon0_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (bind_rgon0_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (bind_rgon0_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (bind_rgon0_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (bind_rgon0_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (bind_rgon0_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(bind_rgon0_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (bind_rgon0_ibp_wrsp_chnl),

                           .i_ibp_cmd_chnl_user(pre_bind_rgon0_ibp_cmd_chnl_user),
                           .o_ibp_cmd_chnl_user(bind_rgon0_ibp_cmd_chnl_user),
                           .i_ibp_clk_en_req  (),
                           .clk   (mss_clk),
                           .rst_a (~rst_b)
                            );

      //unpack IBP
      alb_mss_mem_pack2ibp #(
                           .ADDR_W(32),
                           .DATA_W(128),
                           .USER_W(4),



    .CMD_CHNL_READ           (0),
    .CMD_CHNL_WRAP           (1),
    .CMD_CHNL_DATA_SIZE_LSB  (2),
    .CMD_CHNL_DATA_SIZE_W    (3),
    .CMD_CHNL_BURST_SIZE_LSB (5),
    .CMD_CHNL_BURST_SIZE_W   (4),
    .CMD_CHNL_PROT_LSB       (9),
    .CMD_CHNL_PROT_W         (2),
    .CMD_CHNL_CACHE_LSB      (11),
    .CMD_CHNL_CACHE_W        (4),
    .CMD_CHNL_LOCK           (15),
    .CMD_CHNL_EXCL           (16),
    .CMD_CHNL_ADDR_LSB       (17),
    .CMD_CHNL_ADDR_W         (32),
    .CMD_CHNL_W              (49),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (128),
    .WD_CHNL_MASK_LSB        (129),
    .WD_CHNL_MASK_W          (16),
    .WD_CHNL_W               (145),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (128),
    .RD_CHNL_W               (131),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_rgon0_pack2ibp_inst_2(
                           .ibp_cmd_user(bind_rgon0_ibp_cmd_user),
                           .ibp_cmd_rgon(),

  .ibp_cmd_valid             (bind_rgon0_ibp_cmd_valid),
  .ibp_cmd_accept            (bind_rgon0_ibp_cmd_accept),
  .ibp_cmd_read              (bind_rgon0_ibp_cmd_read),
  .ibp_cmd_addr              (bind_rgon0_ibp_cmd_addr),
  .ibp_cmd_wrap              (bind_rgon0_ibp_cmd_wrap),
  .ibp_cmd_data_size         (bind_rgon0_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (bind_rgon0_ibp_cmd_burst_size),
  .ibp_cmd_prot              (bind_rgon0_ibp_cmd_prot),
  .ibp_cmd_cache             (bind_rgon0_ibp_cmd_cache),
  .ibp_cmd_lock              (bind_rgon0_ibp_cmd_lock),
  .ibp_cmd_excl              (bind_rgon0_ibp_cmd_excl),

  .ibp_rd_valid              (bind_rgon0_ibp_rd_valid),
  .ibp_rd_excl_ok            (bind_rgon0_ibp_rd_excl_ok),
  .ibp_rd_accept             (bind_rgon0_ibp_rd_accept),
  .ibp_err_rd                (bind_rgon0_ibp_err_rd),
  .ibp_rd_data               (bind_rgon0_ibp_rd_data),
  .ibp_rd_last               (bind_rgon0_ibp_rd_last),

  .ibp_wr_valid              (bind_rgon0_ibp_wr_valid),
  .ibp_wr_accept             (bind_rgon0_ibp_wr_accept),
  .ibp_wr_data               (bind_rgon0_ibp_wr_data),
  .ibp_wr_mask               (bind_rgon0_ibp_wr_mask),
  .ibp_wr_last               (bind_rgon0_ibp_wr_last),

  .ibp_wr_done               (bind_rgon0_ibp_wr_done),
  .ibp_wr_excl_done          (bind_rgon0_ibp_wr_excl_done),
  .ibp_err_wr                (bind_rgon0_ibp_err_wr),
  .ibp_wr_resp_accept        (bind_rgon0_ibp_wr_resp_accept),




    .ibp_cmd_chnl_valid  (bind_rgon0_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bind_rgon0_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bind_rgon0_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bind_rgon0_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bind_rgon0_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (bind_rgon0_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (bind_rgon0_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bind_rgon0_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (bind_rgon0_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bind_rgon0_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bind_rgon0_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bind_rgon0_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_user(bind_rgon0_ibp_cmd_chnl_user),
                           .ibp_cmd_chnl_rgon(1'b0)
                           );

    // Memory controller
    alb_mss_mem_ctrl #(.attr(2),
                       .secure(0),
                       .a_w(32))
                     u_rgon0_ctrl_inst (.clk(mss_clk),
                                  .rst_b(rst_b),
                                  .cmd_valid(bind_rgon0_ibp_cmd_valid),
                                  .cmd_accept(bind_rgon0_ibp_cmd_accept),
                                  .cmd_read(bind_rgon0_ibp_cmd_read),
                                  .cmd_addr(bind_rgon0_ibp_cmd_addr),
                                  .cmd_wrap(bind_rgon0_ibp_cmd_wrap),
                                  .cmd_data_size(bind_rgon0_ibp_cmd_data_size),
                                  .cmd_burst_size(bind_rgon0_ibp_cmd_burst_size),
                                  .cmd_nonsec(bind_rgon0_ibp_cmd_user[0]),
                                  .rd_valid(bind_rgon0_ibp_rd_valid),
                                  .rd_accept(bind_rgon0_ibp_rd_accept),
                                  .rd_data(bind_rgon0_ibp_rd_data),
                                  .rd_last(bind_rgon0_ibp_rd_last),
                                  .err_rd(bind_rgon0_ibp_err_rd),
                                  .rd_excl_ok(bind_rgon0_ibp_rd_excl_ok),
                                  .wr_valid(bind_rgon0_ibp_wr_valid),
                                  .wr_accept(bind_rgon0_ibp_wr_accept),
                                  .wr_data(bind_rgon0_ibp_wr_data),
                                  .wr_mask(bind_rgon0_ibp_wr_mask),
                                  .wr_last(bind_rgon0_ibp_wr_last),
                                  .wr_done(bind_rgon0_ibp_wr_done),
                                  .wr_resp_accept(bind_rgon0_ibp_wr_resp_accept),
                                  .wr_excl_done(bind_rgon0_ibp_wr_excl_done),
                                  .err_wr(bind_rgon0_ibp_err_wr),
                                  .mem_cs(bind_rgon0_i_mem_cs),
                                  .mem_we(bind_rgon0_i_mem_we),
                                  .mem_bwe(bind_rgon0_i_mem_bwe),
                                  .mem_addr(bind_rgon0_i_mem_addr),
                                  .mem_wdata(bind_rgon0_i_mem_wdata),
                                  .mem_rdata(bind_rgon0_i_mem_rdata)
                                  );

    // Memory model
//    `if (0 > 1048575) //{ base_addr exceed 32-bit
//    alb_mss_mem_sim_model #(
//          .MEM_SIZE   (268435456),
//          .ADDR_MSB   (32-1),
//          .ADDR_LSB   (4),
//          .PIPELINED  (1'b0),
//          .DATA_WIDTH (128),
//          .WR_SIZE    (8),
//          .SYNC_OUT   (0),
//          .RAM_STL    ("no_rw_check"))
//      u_rgon0_mem_inst (
//          .clk   (i_mem_clk),
//          .din   (bind_rgon0_i_mem_wdata),
//          .addr  (bind_rgon0_i_mem_addr),
//          .regen (1'b1),
//          .rden  (bind_rgon0_i_mem_cs & !(bind_rgon0_i_mem_we)),
//          .wren  ({128/8 {bind_rgon0_i_mem_cs & bind_rgon0_i_mem_we}} & bind_rgon0_i_mem_bwe ),
//          .dout  (bind_rgon0_i_mem_rdata)
//      );
//
//    `else //}{
    alb_mss_mem_model #(.a_w(32),
                        .d_w(128),
                        .base_addr('h0),//0x0
                        .mem_num((255<<24)|0),// Need separate memory model number for different base address.
                        .sz(268435456),
                        .alsb(4)) u_rgon0_mem_inst(.clk(i_mem_clk),
                                                .mem_cs(bind_rgon0_i_mem_cs),
                                                .mem_we(bind_rgon0_i_mem_we),
                                                .mem_bwe(bind_rgon0_i_mem_bwe),
                                                .mem_addr(bind_rgon0_i_mem_addr),
                                                .mem_wdata(bind_rgon0_i_mem_wdata),
                                                .mem_rdata(bind_rgon0_i_mem_rdata));

//      `endif //}

    // Memory model clock gate
    alb_mss_mem_clkgate u_cg_inst(.clk_in(mss_clk),
                                  .rst_a(!rst_b),
                                  .clock_enable(1'b1),
                                  .clk_out(i_mem_clk));
    // assignments
    assign mss_mem_dummy = 1'b0;

endmodule // alb_mss_mem
