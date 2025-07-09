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
//   alb_mss_fab: MxS bus switch including latency units, and protocol
//                    converters
//
// ===========================================================================
//
// Description:
//  Verilog module defining a switch module
//  Including support for multiple masters, slaves
//  and exclusive access support
//  Masters and slaves can have a mix of protocols (AXI/AHB_Lite/BVCI/APB)
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_mss_fab.vpp
//
// ===========================================================================
`include "alb_mss_fab_defines.v"
`timescale 1ns/10ps
module alb_mss_fab(
                   // Master section
                   // 0: AHB master interface, pref: ahb_h, data-width: 32, r/w: rw, excl: 1, lock: 0
                   input   [1:0]       ahb_htrans,
                   input               ahb_hwrite,
                   input   [32-1:0]   ahb_haddr,
                   input   [2:0]       ahb_hsize,
                   input   [2:0]       ahb_hburst,
                   input   [6:0]       ahb_hprot,
                   input               ahb_hnonsec,
                   input               ahb_hexcl,
                   input   [4-1:0]   ahb_hmaster,
                   output              ahb_hexokay,
                   input   [32-1:0]   ahb_hwdata,
                   input   [32/8-1:0]   ahb_hwstrb, 
                   output  [3:0]       ahb_hrdatachk,
                   output  [32-1:0]   ahb_hrdata,
                   output              ahb_hreadychk,
                   output              ahb_hrespchk,
                   input   [3:0]       ahb_haddrchk,
                   input               ahb_htranschk,
                   input               ahb_hctrlchk1,
                   input               ahb_hprotchk,
         
                   output              ahb_hresp,
                   output              ahb_hready,
                   // 1: AHB master interface, pref: dbu_per_ahb_h, data-width: 32, r/w: rw, excl: 1, lock: 0
                   input   [1:0]       dbu_per_ahb_htrans,
                   input               dbu_per_ahb_hwrite,
                   input   [32-1:0]   dbu_per_ahb_haddr,
                   input   [2:0]       dbu_per_ahb_hsize,
                   input   [2:0]       dbu_per_ahb_hburst,
                   input   [6:0]       dbu_per_ahb_hprot,
                   input               dbu_per_ahb_hnonsec,
                   input               dbu_per_ahb_hexcl,
                   input   [4-1:0]   dbu_per_ahb_hmaster,
                   output              dbu_per_ahb_hexokay,
                   input   [32-1:0]   dbu_per_ahb_hwdata,
                   input   [32/8-1:0]   dbu_per_ahb_hwstrb, 
                   output  [3:0]       dbu_per_ahb_hrdatachk,
                   output  [32-1:0]   dbu_per_ahb_hrdata,
                   output              dbu_per_ahb_hreadychk,
                   output              dbu_per_ahb_hrespchk,
                   input   [3:0]       dbu_per_ahb_haddrchk,
                   input               dbu_per_ahb_htranschk,
                   input               dbu_per_ahb_hctrlchk1,
                   input               dbu_per_ahb_hprotchk,
         
                   output              dbu_per_ahb_hresp,
                   output              dbu_per_ahb_hready,
                   // 2: AXI master interface, pref: bri_, data-width: 32, r/w: rw, excl: 0
                   input   [4-1:0]   bri_arid,
                   input               bri_arvalid,
                   output              bri_arready,
                   input   [32-1:0]   bri_araddr,
                   input   [1:0]       bri_arburst,
                   input   [2:0]       bri_arsize,
                   input   [3:0]       bri_arlen,
                   input   [3:0]       bri_arcache,
                   input   [2:0]       bri_arprot,
                   output  [4-1:0]   bri_rid,
                   output              bri_rvalid,
                   input               bri_rready,
                   output  [32-1:0]   bri_rdata,
                   output  [1:0]       bri_rresp,
                   output              bri_rlast,
                   input   [4-1:0]   bri_awid,
                   input               bri_awvalid,
                   output              bri_awready,
                   input   [32-1:0]   bri_awaddr,
                   input   [1:0]       bri_awburst,
                   input   [2:0]       bri_awsize,
                   input   [3:0]       bri_awlen,
                   input   [3:0]       bri_awcache,
                   input   [2:0]       bri_awprot,
                   input   [4-1:0]   bri_wid,
                   input               bri_wvalid,
                   output              bri_wready,
                   input   [32-1:0]   bri_wdata,
                   input   [32/8-1:0] bri_wstrb,
                   input               bri_wlast,
                   output  [4-1:0]   bri_bid,
                   output              bri_bvalid,
                   input               bri_bready,
                   output  [1:0]       bri_bresp,
                   // 3: AXI master interface, pref: xtor_axi_, data-width: 512, r/w: rw, excl: 0
                   input   [4-1:0]   xtor_axi_arid,
                   input               xtor_axi_arvalid,
                   output              xtor_axi_arready,
                   input   [32-1:0]   xtor_axi_araddr,
                   input   [1:0]       xtor_axi_arburst,
                   input   [2:0]       xtor_axi_arsize,
                   input   [3:0]       xtor_axi_arlen,
                   input   [3:0]       xtor_axi_arcache,
                   input   [2:0]       xtor_axi_arprot,
                   output  [4-1:0]   xtor_axi_rid,
                   output              xtor_axi_rvalid,
                   input               xtor_axi_rready,
                   output  [512-1:0]   xtor_axi_rdata,
                   output  [1:0]       xtor_axi_rresp,
                   output              xtor_axi_rlast,
                   input   [4-1:0]   xtor_axi_awid,
                   input               xtor_axi_awvalid,
                   output              xtor_axi_awready,
                   input   [32-1:0]   xtor_axi_awaddr,
                   input   [1:0]       xtor_axi_awburst,
                   input   [2:0]       xtor_axi_awsize,
                   input   [3:0]       xtor_axi_awlen,
                   input   [3:0]       xtor_axi_awcache,
                   input   [2:0]       xtor_axi_awprot,
                   input   [4-1:0]   xtor_axi_wid,
                   input               xtor_axi_wvalid,
                   output              xtor_axi_wready,
                   input   [512-1:0]   xtor_axi_wdata,
                   input   [512/8-1:0] xtor_axi_wstrb,
                   input               xtor_axi_wlast,
                   output  [4-1:0]   xtor_axi_bid,
                   output              xtor_axi_bvalid,
                   input               xtor_axi_bready,
                   output  [1:0]       xtor_axi_bresp,
               // Slave interfaces
                 //     region 0, base: 262144 (0x40000), address width: 19
                   // 0: AHB slave interface, data-width: 32, pref: iccm_ahb_h
                   output  [1-1:0]    iccm_ahb_hsel,
                   output  [1:0]       iccm_ahb_htrans,
                   output              iccm_ahb_hwrite,
                   output  [32-1:0]   iccm_ahb_haddr,
                   output  [2:0]       iccm_ahb_hsize,
                   output  [2:0]       iccm_ahb_hburst,
                   output  [32-1:0]   iccm_ahb_hwdata,
                   input   [32-1:0]   iccm_ahb_hrdata,
                   output  [4-1:0]   iccm_ahb_haddrchk,
                   output               iccm_ahb_htranschk,
                   output               iccm_ahb_hctrlchk1,
                   output               iccm_ahb_hctrlchk2,
                   output               iccm_ahb_hwstrbchk,
                   output               iccm_ahb_hprotchk,
                   output               iccm_ahb_hreadychk,
                   output  [3:0]        iccm_ahb_hwdatachk,
                   input               iccm_ahb_hresp,
                   input               iccm_ahb_hreadyout,
                   output              iccm_ahb_hready,
                 //     region 0, base: 262400 (0x40100), address width: 20
                   // 1: AHB slave interface, data-width: 32, pref: dccm_ahb_h
                   output  [1-1:0]    dccm_ahb_hsel,
                   output  [1:0]       dccm_ahb_htrans,
                   output              dccm_ahb_hwrite,
                   output  [32-1:0]   dccm_ahb_haddr,
                   output  [2:0]       dccm_ahb_hsize,
                   output  [2:0]       dccm_ahb_hburst,
                   output  [32-1:0]   dccm_ahb_hwdata,
                   input   [32-1:0]   dccm_ahb_hrdata,
                   output  [4-1:0]   dccm_ahb_haddrchk,
                   output               dccm_ahb_htranschk,
                   output               dccm_ahb_hctrlchk1,
                   output               dccm_ahb_hctrlchk2,
                   output               dccm_ahb_hwstrbchk,
                   output               dccm_ahb_hprotchk,
                   output               dccm_ahb_hreadychk,
                   output  [3:0]        dccm_ahb_hwdatachk,
                   input               dccm_ahb_hresp,
                   input               dccm_ahb_hreadyout,
                   output              dccm_ahb_hready,
                 //     region 0, base: 262656 (0x40200), address width: 20
                   // 2: AHB slave interface, data-width: 32, pref: mmio_ahb_h
                   output  [1-1:0]    mmio_ahb_hsel,
                   output  [1:0]       mmio_ahb_htrans,
                   output              mmio_ahb_hwrite,
                   output  [32-1:0]   mmio_ahb_haddr,
                   output  [2:0]       mmio_ahb_hsize,
                   output  [2:0]       mmio_ahb_hburst,
                   output  [32-1:0]   mmio_ahb_hwdata,
                   input   [32-1:0]   mmio_ahb_hrdata,
                   output  [4-1:0]   mmio_ahb_haddrchk,
                   output               mmio_ahb_htranschk,
                   output               mmio_ahb_hctrlchk1,
                   output               mmio_ahb_hctrlchk2,
                   output               mmio_ahb_hwstrbchk,
                   output               mmio_ahb_hprotchk,
                   output               mmio_ahb_hreadychk,
                   output  [3:0]        mmio_ahb_hwdatachk,
                   input               mmio_ahb_hresp,
                   input               mmio_ahb_hreadyout,
                   output              mmio_ahb_hready,
                 //     region 0, base: 786432 (0xc0000), address width: 12
                   // 3: APB slave interface, data-width: 32, pref: mss_clkctrl_
                   output  [1-1:0]    mss_clkctrl_sel,
                   output              mss_clkctrl_enable,
                   output              mss_clkctrl_write,
                   output  [12-1:2]   mss_clkctrl_addr,
                   output  [31:0]      mss_clkctrl_wdata,
                   output  [3:0]       mss_clkctrl_wstrb,
                   input   [31:0]      mss_clkctrl_rdata,
                   input               mss_clkctrl_slverr,
                   input               mss_clkctrl_ready,
                 //     region 0, base: 786438 (0xc0006), address width: 12
                   // 4: APB slave interface, data-width: 32, pref: dslv1_
                   output  [1-1:0]    dslv1_sel,
                   output              dslv1_enable,
                   output              dslv1_write,
                   output  [12-1:2]   dslv1_addr,
                   output  [31:0]      dslv1_wdata,
                   output  [3:0]       dslv1_wstrb,
                   input   [31:0]      dslv1_rdata,
                   input               dslv1_slverr,
                   input               dslv1_ready,
                 //     region 0, base: 790528 (0xc1000), address width: 24
                   // 5: AXI slave interface, data-width: 64, pref: dslv2_
                   output              dslv2_arvalid,
                   input               dslv2_arready,
                   output  [16-1:0]   dslv2_arid,
                   output  [1-1:0]  dslv2_arregion,
                   output  [24-1:0]   dslv2_araddr,
                   output  [1:0]       dslv2_arburst,
                   output  [2:0]       dslv2_arsize,
                   output   [3:0]       dslv2_arlen,
                   input   [16-1:0]   dslv2_rid,
                   input               dslv2_rvalid,
                   output              dslv2_rready,
                   input   [64-1:0]   dslv2_rdata,
                   input   [1:0]       dslv2_rresp,
                   input               dslv2_rlast,
                   output              dslv2_awvalid,
                   input               dslv2_awready,
                   output  [16-1:0]   dslv2_awid,
                   output  [1-1:0]  dslv2_awregion,
                   output  [24-1:0]   dslv2_awaddr,
                   output  [1:0]       dslv2_awburst,
                   output  [2:0]       dslv2_awsize,
                   output   [3:0]       dslv2_awlen,
                   output              dslv2_wvalid,
                   input               dslv2_wready,
                   output  [16-1:0]   dslv2_wid,
                   output  [64-1:0]   dslv2_wdata,
                   output  [64/8-1:0] dslv2_wstrb,
                   output              dslv2_wlast,
                   input   [16-1:0]   dslv2_bid,
                   input               dslv2_bvalid,
                   output              dslv2_bready,
                   input   [1:0]       dslv2_bresp,


                 //     region 0, base: 786434 (0xc0002), address width: 13
                   // 6: APB slave interface, data-width: 32, pref: mss_perfctrl_
                   output  [1-1:0]    mss_perfctrl_sel,
                   output              mss_perfctrl_enable,
                   output              mss_perfctrl_write,
                   output  [13-1:2]   mss_perfctrl_addr,
                   output  [31:0]      mss_perfctrl_wdata,
                   output  [3:0]       mss_perfctrl_wstrb,
                   input   [31:0]      mss_perfctrl_rdata,
                   input               mss_perfctrl_slverr,
                   input               mss_perfctrl_ready,
                 //     region 0, base: 0 (0x0), address width: 32
                   // 7: IBP slave interface, data-width: 128, pref: mss_mem_
                   output              mss_mem_cmd_valid,
                   input               mss_mem_cmd_accept,
                   output              mss_mem_cmd_read,
                   output  [32-1:0]   mss_mem_cmd_addr,
                   output              mss_mem_cmd_wrap,
                   output  [2:0]       mss_mem_cmd_data_size,
                   output  [3:0]       mss_mem_cmd_burst_size,
                   output              mss_mem_cmd_lock,
                   output              mss_mem_cmd_excl,
                   output  [1:0]       mss_mem_cmd_prot,
                   output  [3:0]       mss_mem_cmd_cache,
                   output  [1-1:0]  mss_mem_cmd_region,
                   output  [6-1:0] mss_mem_cmd_id, // side-signal to support exclusive memory access
                   output  [4-1:0] mss_mem_cmd_user, // side-signal to user signals
                   input               mss_mem_rd_valid,
                   output              mss_mem_rd_accept,
                   input               mss_mem_rd_excl_ok,
                   input   [128-1:0]   mss_mem_rd_data,
                   input               mss_mem_err_rd,
                   input               mss_mem_rd_last,
                   output              mss_mem_wr_valid,
                   input               mss_mem_wr_accept,
                   output  [128-1:0]   mss_mem_wr_data,
                   output  [128/8-1:0] mss_mem_wr_mask,
                   output              mss_mem_wr_last,
                   input               mss_mem_wr_done,
                   input               mss_mem_wr_excl_done,
                   input               mss_mem_err_wr,
                   output              mss_mem_wr_resp_accept,
                   // Latency unit and performance monitor interfaces
                   input   [4*12-1:0]  mss_fab_cfg_lat_w,
                   input   [4*12-1:0]  mss_fab_cfg_lat_r,
                   input   [4*10-1:0]  mss_fab_cfg_wr_bw,
                   input   [4*10-1:0]  mss_fab_cfg_rd_bw,
                   output  [4-1:0]    mss_fab_perf_awf,
                   output  [4-1:0]    mss_fab_perf_arf,
                   output  [4-1:0]    mss_fab_perf_aw,
                   output  [4-1:0]    mss_fab_perf_ar,
                   output  [4-1:0]    mss_fab_perf_w,
                   output  [4-1:0]    mss_fab_perf_wl,
                   output  [4-1:0]    mss_fab_perf_r,
                   output  [4-1:0]    mss_fab_perf_rl,
                   output  [4-1:0]    mss_fab_perf_b,
                   // output system address base signal
                   // clock and clock enables
                   input               clk,
                   input               mss_clk,
                   input               iccm_ahb_clk_en,
                   input               dccm_ahb_clk_en,
                   input               mmio_ahb_clk_en,
                   input               mss_fab_mst0_clk_en,
                   input               mss_fab_mst1_clk_en,
                   input               mss_fab_mst2_clk_en,
                   input               mss_fab_mst3_clk_en,
                   input               mss_fab_slv0_clk_en,
                   input               mss_fab_slv1_clk_en,
                   input               mss_fab_slv2_clk_en,
                   input               mss_fab_slv3_clk_en,
                   input               mss_fab_slv4_clk_en,
                   input               mss_fab_slv5_clk_en,
                   input               mss_fab_slv6_clk_en,
                   input               mss_fab_slv7_clk_en,
                   input                rst_b
);

//Internal wires

//
//wires for master side
//


  wire                                  mst_ahb_hibp_cmd_valid;
  wire                                  mst_ahb_hibp_cmd_accept;
  wire                                  mst_ahb_hibp_cmd_read;
  wire  [42                -1:0]       mst_ahb_hibp_cmd_addr;
  wire                                  mst_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       mst_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       mst_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       mst_ahb_hibp_cmd_prot;
  wire  [4-1:0]       mst_ahb_hibp_cmd_cache;
  wire                                  mst_ahb_hibp_cmd_lock;
  wire                                  mst_ahb_hibp_cmd_excl;

  wire                                  mst_ahb_hibp_rd_valid;
  wire                                  mst_ahb_hibp_rd_excl_ok;
  wire                                  mst_ahb_hibp_rd_accept;
  wire                                  mst_ahb_hibp_err_rd;
  wire  [32               -1:0]        mst_ahb_hibp_rd_data;
  wire                                  mst_ahb_hibp_rd_last;

  wire                                  mst_ahb_hibp_wr_valid;
  wire                                  mst_ahb_hibp_wr_accept;
  wire  [32               -1:0]        mst_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        mst_ahb_hibp_wr_mask;
  wire                                  mst_ahb_hibp_wr_last;

  wire                                  mst_ahb_hibp_wr_done;
  wire                                  mst_ahb_hibp_wr_excl_done;
  wire                                  mst_ahb_hibp_err_wr;
  wire                                  mst_ahb_hibp_wr_resp_accept;
wire [1-1:0] mst_ahb_hibp_cmd_rgon;



 wire [1-1:0] mst_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] mst_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] mst_ahb_hibp_cmd_chnl;

 wire [1-1:0] mst_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] mst_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] mst_ahb_hibp_wd_chnl;

 wire [1-1:0] mst_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] mst_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] mst_ahb_hibp_rd_chnl;

 wire [1-1:0] mst_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] mst_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] mst_ahb_hibp_wrsp_chnl;

wire [1-1:0]mst_ahb_hibp_cmd_chnl_rgon;



 wire [1-1:0] mst_o_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] mst_o_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] mst_o_ahb_hibp_cmd_chnl;

 wire [1-1:0] mst_o_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] mst_o_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] mst_o_ahb_hibp_wd_chnl;

 wire [1-1:0] mst_o_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] mst_o_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] mst_o_ahb_hibp_rd_chnl;

 wire [1-1:0] mst_o_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] mst_o_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] mst_o_ahb_hibp_wrsp_chnl;

wire [1-1:0] mst_o_ahb_hibp_cmd_chnl_rgon;



 wire [1-1:0] lat_i_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] lat_i_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] lat_i_ahb_hibp_cmd_chnl;

 wire [1-1:0] lat_i_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] lat_i_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] lat_i_ahb_hibp_wd_chnl;

 wire [1-1:0] lat_i_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] lat_i_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] lat_i_ahb_hibp_rd_chnl;

 wire [1-1:0] lat_i_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] lat_i_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] lat_i_ahb_hibp_wrsp_chnl;

wire [1-1:0] lat_i_ahb_hibp_cmd_chnl_rgon;


  wire                                  lat_i_ahb_hibp_cmd_valid;
  wire                                  lat_i_ahb_hibp_cmd_accept;
  wire                                  lat_i_ahb_hibp_cmd_read;
  wire  [42                -1:0]       lat_i_ahb_hibp_cmd_addr;
  wire                                  lat_i_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       lat_i_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       lat_i_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       lat_i_ahb_hibp_cmd_prot;
  wire  [4-1:0]       lat_i_ahb_hibp_cmd_cache;
  wire                                  lat_i_ahb_hibp_cmd_lock;
  wire                                  lat_i_ahb_hibp_cmd_excl;

  wire                                  lat_i_ahb_hibp_rd_valid;
  wire                                  lat_i_ahb_hibp_rd_excl_ok;
  wire                                  lat_i_ahb_hibp_rd_accept;
  wire                                  lat_i_ahb_hibp_err_rd;
  wire  [32               -1:0]        lat_i_ahb_hibp_rd_data;
  wire                                  lat_i_ahb_hibp_rd_last;

  wire                                  lat_i_ahb_hibp_wr_valid;
  wire                                  lat_i_ahb_hibp_wr_accept;
  wire  [32               -1:0]        lat_i_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        lat_i_ahb_hibp_wr_mask;
  wire                                  lat_i_ahb_hibp_wr_last;

  wire                                  lat_i_ahb_hibp_wr_done;
  wire                                  lat_i_ahb_hibp_wr_excl_done;
  wire                                  lat_i_ahb_hibp_err_wr;
  wire                                  lat_i_ahb_hibp_wr_resp_accept;


  wire                                  lat_o_ahb_hibp_cmd_valid;
  wire                                  lat_o_ahb_hibp_cmd_accept;
  wire                                  lat_o_ahb_hibp_cmd_read;
  wire  [42                -1:0]       lat_o_ahb_hibp_cmd_addr;
  wire                                  lat_o_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       lat_o_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       lat_o_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       lat_o_ahb_hibp_cmd_prot;
  wire  [4-1:0]       lat_o_ahb_hibp_cmd_cache;
  wire                                  lat_o_ahb_hibp_cmd_lock;
  wire                                  lat_o_ahb_hibp_cmd_excl;

  wire                                  lat_o_ahb_hibp_rd_valid;
  wire                                  lat_o_ahb_hibp_rd_excl_ok;
  wire                                  lat_o_ahb_hibp_rd_accept;
  wire                                  lat_o_ahb_hibp_err_rd;
  wire  [32               -1:0]        lat_o_ahb_hibp_rd_data;
  wire                                  lat_o_ahb_hibp_rd_last;

  wire                                  lat_o_ahb_hibp_wr_valid;
  wire                                  lat_o_ahb_hibp_wr_accept;
  wire  [32               -1:0]        lat_o_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        lat_o_ahb_hibp_wr_mask;
  wire                                  lat_o_ahb_hibp_wr_last;

  wire                                  lat_o_ahb_hibp_wr_done;
  wire                                  lat_o_ahb_hibp_wr_excl_done;
  wire                                  lat_o_ahb_hibp_err_wr;
  wire                                  lat_o_ahb_hibp_wr_resp_accept;


  wire                                  mst_dbu_per_ahb_hibp_cmd_valid;
  wire                                  mst_dbu_per_ahb_hibp_cmd_accept;
  wire                                  mst_dbu_per_ahb_hibp_cmd_read;
  wire  [42                -1:0]       mst_dbu_per_ahb_hibp_cmd_addr;
  wire                                  mst_dbu_per_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       mst_dbu_per_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       mst_dbu_per_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       mst_dbu_per_ahb_hibp_cmd_prot;
  wire  [4-1:0]       mst_dbu_per_ahb_hibp_cmd_cache;
  wire                                  mst_dbu_per_ahb_hibp_cmd_lock;
  wire                                  mst_dbu_per_ahb_hibp_cmd_excl;

  wire                                  mst_dbu_per_ahb_hibp_rd_valid;
  wire                                  mst_dbu_per_ahb_hibp_rd_excl_ok;
  wire                                  mst_dbu_per_ahb_hibp_rd_accept;
  wire                                  mst_dbu_per_ahb_hibp_err_rd;
  wire  [32               -1:0]        mst_dbu_per_ahb_hibp_rd_data;
  wire                                  mst_dbu_per_ahb_hibp_rd_last;

  wire                                  mst_dbu_per_ahb_hibp_wr_valid;
  wire                                  mst_dbu_per_ahb_hibp_wr_accept;
  wire  [32               -1:0]        mst_dbu_per_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        mst_dbu_per_ahb_hibp_wr_mask;
  wire                                  mst_dbu_per_ahb_hibp_wr_last;

  wire                                  mst_dbu_per_ahb_hibp_wr_done;
  wire                                  mst_dbu_per_ahb_hibp_wr_excl_done;
  wire                                  mst_dbu_per_ahb_hibp_err_wr;
  wire                                  mst_dbu_per_ahb_hibp_wr_resp_accept;
wire [1-1:0] mst_dbu_per_ahb_hibp_cmd_rgon;



 wire [1-1:0] mst_dbu_per_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] mst_dbu_per_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] mst_dbu_per_ahb_hibp_cmd_chnl;

 wire [1-1:0] mst_dbu_per_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] mst_dbu_per_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] mst_dbu_per_ahb_hibp_wd_chnl;

 wire [1-1:0] mst_dbu_per_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] mst_dbu_per_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] mst_dbu_per_ahb_hibp_rd_chnl;

 wire [1-1:0] mst_dbu_per_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] mst_dbu_per_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] mst_dbu_per_ahb_hibp_wrsp_chnl;

wire [1-1:0]mst_dbu_per_ahb_hibp_cmd_chnl_rgon;



 wire [1-1:0] mst_o_dbu_per_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] mst_o_dbu_per_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] mst_o_dbu_per_ahb_hibp_cmd_chnl;

 wire [1-1:0] mst_o_dbu_per_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] mst_o_dbu_per_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] mst_o_dbu_per_ahb_hibp_wd_chnl;

 wire [1-1:0] mst_o_dbu_per_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] mst_o_dbu_per_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] mst_o_dbu_per_ahb_hibp_rd_chnl;

 wire [1-1:0] mst_o_dbu_per_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] mst_o_dbu_per_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] mst_o_dbu_per_ahb_hibp_wrsp_chnl;

wire [1-1:0] mst_o_dbu_per_ahb_hibp_cmd_chnl_rgon;



 wire [1-1:0] lat_i_dbu_per_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] lat_i_dbu_per_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] lat_i_dbu_per_ahb_hibp_cmd_chnl;

 wire [1-1:0] lat_i_dbu_per_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] lat_i_dbu_per_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] lat_i_dbu_per_ahb_hibp_wd_chnl;

 wire [1-1:0] lat_i_dbu_per_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] lat_i_dbu_per_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] lat_i_dbu_per_ahb_hibp_rd_chnl;

 wire [1-1:0] lat_i_dbu_per_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] lat_i_dbu_per_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] lat_i_dbu_per_ahb_hibp_wrsp_chnl;

wire [1-1:0] lat_i_dbu_per_ahb_hibp_cmd_chnl_rgon;


  wire                                  lat_i_dbu_per_ahb_hibp_cmd_valid;
  wire                                  lat_i_dbu_per_ahb_hibp_cmd_accept;
  wire                                  lat_i_dbu_per_ahb_hibp_cmd_read;
  wire  [42                -1:0]       lat_i_dbu_per_ahb_hibp_cmd_addr;
  wire                                  lat_i_dbu_per_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       lat_i_dbu_per_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       lat_i_dbu_per_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       lat_i_dbu_per_ahb_hibp_cmd_prot;
  wire  [4-1:0]       lat_i_dbu_per_ahb_hibp_cmd_cache;
  wire                                  lat_i_dbu_per_ahb_hibp_cmd_lock;
  wire                                  lat_i_dbu_per_ahb_hibp_cmd_excl;

  wire                                  lat_i_dbu_per_ahb_hibp_rd_valid;
  wire                                  lat_i_dbu_per_ahb_hibp_rd_excl_ok;
  wire                                  lat_i_dbu_per_ahb_hibp_rd_accept;
  wire                                  lat_i_dbu_per_ahb_hibp_err_rd;
  wire  [32               -1:0]        lat_i_dbu_per_ahb_hibp_rd_data;
  wire                                  lat_i_dbu_per_ahb_hibp_rd_last;

  wire                                  lat_i_dbu_per_ahb_hibp_wr_valid;
  wire                                  lat_i_dbu_per_ahb_hibp_wr_accept;
  wire  [32               -1:0]        lat_i_dbu_per_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        lat_i_dbu_per_ahb_hibp_wr_mask;
  wire                                  lat_i_dbu_per_ahb_hibp_wr_last;

  wire                                  lat_i_dbu_per_ahb_hibp_wr_done;
  wire                                  lat_i_dbu_per_ahb_hibp_wr_excl_done;
  wire                                  lat_i_dbu_per_ahb_hibp_err_wr;
  wire                                  lat_i_dbu_per_ahb_hibp_wr_resp_accept;


  wire                                  lat_o_dbu_per_ahb_hibp_cmd_valid;
  wire                                  lat_o_dbu_per_ahb_hibp_cmd_accept;
  wire                                  lat_o_dbu_per_ahb_hibp_cmd_read;
  wire  [42                -1:0]       lat_o_dbu_per_ahb_hibp_cmd_addr;
  wire                                  lat_o_dbu_per_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       lat_o_dbu_per_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       lat_o_dbu_per_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       lat_o_dbu_per_ahb_hibp_cmd_prot;
  wire  [4-1:0]       lat_o_dbu_per_ahb_hibp_cmd_cache;
  wire                                  lat_o_dbu_per_ahb_hibp_cmd_lock;
  wire                                  lat_o_dbu_per_ahb_hibp_cmd_excl;

  wire                                  lat_o_dbu_per_ahb_hibp_rd_valid;
  wire                                  lat_o_dbu_per_ahb_hibp_rd_excl_ok;
  wire                                  lat_o_dbu_per_ahb_hibp_rd_accept;
  wire                                  lat_o_dbu_per_ahb_hibp_err_rd;
  wire  [32               -1:0]        lat_o_dbu_per_ahb_hibp_rd_data;
  wire                                  lat_o_dbu_per_ahb_hibp_rd_last;

  wire                                  lat_o_dbu_per_ahb_hibp_wr_valid;
  wire                                  lat_o_dbu_per_ahb_hibp_wr_accept;
  wire  [32               -1:0]        lat_o_dbu_per_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        lat_o_dbu_per_ahb_hibp_wr_mask;
  wire                                  lat_o_dbu_per_ahb_hibp_wr_last;

  wire                                  lat_o_dbu_per_ahb_hibp_wr_done;
  wire                                  lat_o_dbu_per_ahb_hibp_wr_excl_done;
  wire                                  lat_o_dbu_per_ahb_hibp_err_wr;
  wire                                  lat_o_dbu_per_ahb_hibp_wr_resp_accept;


  wire                                  mst_bri_ibp_cmd_valid;
  wire                                  mst_bri_ibp_cmd_accept;
  wire                                  mst_bri_ibp_cmd_read;
  wire  [42                -1:0]       mst_bri_ibp_cmd_addr;
  wire                                  mst_bri_ibp_cmd_wrap;
  wire  [3-1:0]       mst_bri_ibp_cmd_data_size;
  wire  [4-1:0]       mst_bri_ibp_cmd_burst_size;
  wire  [2-1:0]       mst_bri_ibp_cmd_prot;
  wire  [4-1:0]       mst_bri_ibp_cmd_cache;
  wire                                  mst_bri_ibp_cmd_lock;
  wire                                  mst_bri_ibp_cmd_excl;

  wire                                  mst_bri_ibp_rd_valid;
  wire                                  mst_bri_ibp_rd_excl_ok;
  wire                                  mst_bri_ibp_rd_accept;
  wire                                  mst_bri_ibp_err_rd;
  wire  [32               -1:0]        mst_bri_ibp_rd_data;
  wire                                  mst_bri_ibp_rd_last;

  wire                                  mst_bri_ibp_wr_valid;
  wire                                  mst_bri_ibp_wr_accept;
  wire  [32               -1:0]        mst_bri_ibp_wr_data;
  wire  [(32         /8)  -1:0]        mst_bri_ibp_wr_mask;
  wire                                  mst_bri_ibp_wr_last;

  wire                                  mst_bri_ibp_wr_done;
  wire                                  mst_bri_ibp_wr_excl_done;
  wire                                  mst_bri_ibp_err_wr;
  wire                                  mst_bri_ibp_wr_resp_accept;
wire [1-1:0] mst_bri_ibp_cmd_rgon;



 wire [1-1:0] mst_bri_ibp_cmd_chnl_valid;
 wire [1-1:0] mst_bri_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] mst_bri_ibp_cmd_chnl;

 wire [1-1:0] mst_bri_ibp_wd_chnl_valid;
 wire [1-1:0] mst_bri_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] mst_bri_ibp_wd_chnl;

 wire [1-1:0] mst_bri_ibp_rd_chnl_accept;
 wire [1-1:0] mst_bri_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] mst_bri_ibp_rd_chnl;

 wire [1-1:0] mst_bri_ibp_wrsp_chnl_valid;
 wire [1-1:0] mst_bri_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] mst_bri_ibp_wrsp_chnl;

wire [1-1:0]mst_bri_ibp_cmd_chnl_rgon;



 wire [1-1:0] lat_i_bri_ibp_cmd_chnl_valid;
 wire [1-1:0] lat_i_bri_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] lat_i_bri_ibp_cmd_chnl;

 wire [1-1:0] lat_i_bri_ibp_wd_chnl_valid;
 wire [1-1:0] lat_i_bri_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] lat_i_bri_ibp_wd_chnl;

 wire [1-1:0] lat_i_bri_ibp_rd_chnl_accept;
 wire [1-1:0] lat_i_bri_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] lat_i_bri_ibp_rd_chnl;

 wire [1-1:0] lat_i_bri_ibp_wrsp_chnl_valid;
 wire [1-1:0] lat_i_bri_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] lat_i_bri_ibp_wrsp_chnl;

wire [1-1:0] lat_i_bri_ibp_cmd_chnl_rgon;


  wire                                  lat_i_bri_ibp_cmd_valid;
  wire                                  lat_i_bri_ibp_cmd_accept;
  wire                                  lat_i_bri_ibp_cmd_read;
  wire  [42                -1:0]       lat_i_bri_ibp_cmd_addr;
  wire                                  lat_i_bri_ibp_cmd_wrap;
  wire  [3-1:0]       lat_i_bri_ibp_cmd_data_size;
  wire  [4-1:0]       lat_i_bri_ibp_cmd_burst_size;
  wire  [2-1:0]       lat_i_bri_ibp_cmd_prot;
  wire  [4-1:0]       lat_i_bri_ibp_cmd_cache;
  wire                                  lat_i_bri_ibp_cmd_lock;
  wire                                  lat_i_bri_ibp_cmd_excl;

  wire                                  lat_i_bri_ibp_rd_valid;
  wire                                  lat_i_bri_ibp_rd_excl_ok;
  wire                                  lat_i_bri_ibp_rd_accept;
  wire                                  lat_i_bri_ibp_err_rd;
  wire  [32               -1:0]        lat_i_bri_ibp_rd_data;
  wire                                  lat_i_bri_ibp_rd_last;

  wire                                  lat_i_bri_ibp_wr_valid;
  wire                                  lat_i_bri_ibp_wr_accept;
  wire  [32               -1:0]        lat_i_bri_ibp_wr_data;
  wire  [(32         /8)  -1:0]        lat_i_bri_ibp_wr_mask;
  wire                                  lat_i_bri_ibp_wr_last;

  wire                                  lat_i_bri_ibp_wr_done;
  wire                                  lat_i_bri_ibp_wr_excl_done;
  wire                                  lat_i_bri_ibp_err_wr;
  wire                                  lat_i_bri_ibp_wr_resp_accept;


  wire                                  lat_o_bri_ibp_cmd_valid;
  wire                                  lat_o_bri_ibp_cmd_accept;
  wire                                  lat_o_bri_ibp_cmd_read;
  wire  [42                -1:0]       lat_o_bri_ibp_cmd_addr;
  wire                                  lat_o_bri_ibp_cmd_wrap;
  wire  [3-1:0]       lat_o_bri_ibp_cmd_data_size;
  wire  [4-1:0]       lat_o_bri_ibp_cmd_burst_size;
  wire  [2-1:0]       lat_o_bri_ibp_cmd_prot;
  wire  [4-1:0]       lat_o_bri_ibp_cmd_cache;
  wire                                  lat_o_bri_ibp_cmd_lock;
  wire                                  lat_o_bri_ibp_cmd_excl;

  wire                                  lat_o_bri_ibp_rd_valid;
  wire                                  lat_o_bri_ibp_rd_excl_ok;
  wire                                  lat_o_bri_ibp_rd_accept;
  wire                                  lat_o_bri_ibp_err_rd;
  wire  [32               -1:0]        lat_o_bri_ibp_rd_data;
  wire                                  lat_o_bri_ibp_rd_last;

  wire                                  lat_o_bri_ibp_wr_valid;
  wire                                  lat_o_bri_ibp_wr_accept;
  wire  [32               -1:0]        lat_o_bri_ibp_wr_data;
  wire  [(32         /8)  -1:0]        lat_o_bri_ibp_wr_mask;
  wire                                  lat_o_bri_ibp_wr_last;

  wire                                  lat_o_bri_ibp_wr_done;
  wire                                  lat_o_bri_ibp_wr_excl_done;
  wire                                  lat_o_bri_ibp_err_wr;
  wire                                  lat_o_bri_ibp_wr_resp_accept;


  wire                                  mst_xtor_axi_ibp_cmd_valid;
  wire                                  mst_xtor_axi_ibp_cmd_accept;
  wire                                  mst_xtor_axi_ibp_cmd_read;
  wire  [42                -1:0]       mst_xtor_axi_ibp_cmd_addr;
  wire                                  mst_xtor_axi_ibp_cmd_wrap;
  wire  [3-1:0]       mst_xtor_axi_ibp_cmd_data_size;
  wire  [4-1:0]       mst_xtor_axi_ibp_cmd_burst_size;
  wire  [2-1:0]       mst_xtor_axi_ibp_cmd_prot;
  wire  [4-1:0]       mst_xtor_axi_ibp_cmd_cache;
  wire                                  mst_xtor_axi_ibp_cmd_lock;
  wire                                  mst_xtor_axi_ibp_cmd_excl;

  wire                                  mst_xtor_axi_ibp_rd_valid;
  wire                                  mst_xtor_axi_ibp_rd_excl_ok;
  wire                                  mst_xtor_axi_ibp_rd_accept;
  wire                                  mst_xtor_axi_ibp_err_rd;
  wire  [512               -1:0]        mst_xtor_axi_ibp_rd_data;
  wire                                  mst_xtor_axi_ibp_rd_last;

  wire                                  mst_xtor_axi_ibp_wr_valid;
  wire                                  mst_xtor_axi_ibp_wr_accept;
  wire  [512               -1:0]        mst_xtor_axi_ibp_wr_data;
  wire  [(512         /8)  -1:0]        mst_xtor_axi_ibp_wr_mask;
  wire                                  mst_xtor_axi_ibp_wr_last;

  wire                                  mst_xtor_axi_ibp_wr_done;
  wire                                  mst_xtor_axi_ibp_wr_excl_done;
  wire                                  mst_xtor_axi_ibp_err_wr;
  wire                                  mst_xtor_axi_ibp_wr_resp_accept;
wire [1-1:0] mst_xtor_axi_ibp_cmd_rgon;



 wire [1-1:0] mst_xtor_axi_ibp_cmd_chnl_valid;
 wire [1-1:0] mst_xtor_axi_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] mst_xtor_axi_ibp_cmd_chnl;

 wire [1-1:0] mst_xtor_axi_ibp_wd_chnl_valid;
 wire [1-1:0] mst_xtor_axi_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] mst_xtor_axi_ibp_wd_chnl;

 wire [1-1:0] mst_xtor_axi_ibp_rd_chnl_accept;
 wire [1-1:0] mst_xtor_axi_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] mst_xtor_axi_ibp_rd_chnl;

 wire [1-1:0] mst_xtor_axi_ibp_wrsp_chnl_valid;
 wire [1-1:0] mst_xtor_axi_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] mst_xtor_axi_ibp_wrsp_chnl;

wire [1-1:0]mst_xtor_axi_ibp_cmd_chnl_rgon;



 wire [1-1:0] lat_i_xtor_axi_ibp_cmd_chnl_valid;
 wire [1-1:0] lat_i_xtor_axi_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] lat_i_xtor_axi_ibp_cmd_chnl;

 wire [1-1:0] lat_i_xtor_axi_ibp_wd_chnl_valid;
 wire [1-1:0] lat_i_xtor_axi_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] lat_i_xtor_axi_ibp_wd_chnl;

 wire [1-1:0] lat_i_xtor_axi_ibp_rd_chnl_accept;
 wire [1-1:0] lat_i_xtor_axi_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] lat_i_xtor_axi_ibp_rd_chnl;

 wire [1-1:0] lat_i_xtor_axi_ibp_wrsp_chnl_valid;
 wire [1-1:0] lat_i_xtor_axi_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] lat_i_xtor_axi_ibp_wrsp_chnl;

wire [1-1:0] lat_i_xtor_axi_ibp_cmd_chnl_rgon;


  wire                                  lat_i_xtor_axi_ibp_cmd_valid;
  wire                                  lat_i_xtor_axi_ibp_cmd_accept;
  wire                                  lat_i_xtor_axi_ibp_cmd_read;
  wire  [42                -1:0]       lat_i_xtor_axi_ibp_cmd_addr;
  wire                                  lat_i_xtor_axi_ibp_cmd_wrap;
  wire  [3-1:0]       lat_i_xtor_axi_ibp_cmd_data_size;
  wire  [4-1:0]       lat_i_xtor_axi_ibp_cmd_burst_size;
  wire  [2-1:0]       lat_i_xtor_axi_ibp_cmd_prot;
  wire  [4-1:0]       lat_i_xtor_axi_ibp_cmd_cache;
  wire                                  lat_i_xtor_axi_ibp_cmd_lock;
  wire                                  lat_i_xtor_axi_ibp_cmd_excl;

  wire                                  lat_i_xtor_axi_ibp_rd_valid;
  wire                                  lat_i_xtor_axi_ibp_rd_excl_ok;
  wire                                  lat_i_xtor_axi_ibp_rd_accept;
  wire                                  lat_i_xtor_axi_ibp_err_rd;
  wire  [512               -1:0]        lat_i_xtor_axi_ibp_rd_data;
  wire                                  lat_i_xtor_axi_ibp_rd_last;

  wire                                  lat_i_xtor_axi_ibp_wr_valid;
  wire                                  lat_i_xtor_axi_ibp_wr_accept;
  wire  [512               -1:0]        lat_i_xtor_axi_ibp_wr_data;
  wire  [(512         /8)  -1:0]        lat_i_xtor_axi_ibp_wr_mask;
  wire                                  lat_i_xtor_axi_ibp_wr_last;

  wire                                  lat_i_xtor_axi_ibp_wr_done;
  wire                                  lat_i_xtor_axi_ibp_wr_excl_done;
  wire                                  lat_i_xtor_axi_ibp_err_wr;
  wire                                  lat_i_xtor_axi_ibp_wr_resp_accept;


  wire                                  lat_o_xtor_axi_ibp_cmd_valid;
  wire                                  lat_o_xtor_axi_ibp_cmd_accept;
  wire                                  lat_o_xtor_axi_ibp_cmd_read;
  wire  [42                -1:0]       lat_o_xtor_axi_ibp_cmd_addr;
  wire                                  lat_o_xtor_axi_ibp_cmd_wrap;
  wire  [3-1:0]       lat_o_xtor_axi_ibp_cmd_data_size;
  wire  [4-1:0]       lat_o_xtor_axi_ibp_cmd_burst_size;
  wire  [2-1:0]       lat_o_xtor_axi_ibp_cmd_prot;
  wire  [4-1:0]       lat_o_xtor_axi_ibp_cmd_cache;
  wire                                  lat_o_xtor_axi_ibp_cmd_lock;
  wire                                  lat_o_xtor_axi_ibp_cmd_excl;

  wire                                  lat_o_xtor_axi_ibp_rd_valid;
  wire                                  lat_o_xtor_axi_ibp_rd_excl_ok;
  wire                                  lat_o_xtor_axi_ibp_rd_accept;
  wire                                  lat_o_xtor_axi_ibp_err_rd;
  wire  [512               -1:0]        lat_o_xtor_axi_ibp_rd_data;
  wire                                  lat_o_xtor_axi_ibp_rd_last;

  wire                                  lat_o_xtor_axi_ibp_wr_valid;
  wire                                  lat_o_xtor_axi_ibp_wr_accept;
  wire  [512               -1:0]        lat_o_xtor_axi_ibp_wr_data;
  wire  [(512         /8)  -1:0]        lat_o_xtor_axi_ibp_wr_mask;
  wire                                  lat_o_xtor_axi_ibp_wr_last;

  wire                                  lat_o_xtor_axi_ibp_wr_done;
  wire                                  lat_o_xtor_axi_ibp_wr_excl_done;
  wire                                  lat_o_xtor_axi_ibp_err_wr;
  wire                                  lat_o_xtor_axi_ibp_wr_resp_accept;
//
//wires for slave side
//

  wire                                  bs_o_iccm_ahb_hibp_cmd_valid;
  wire                                  bs_o_iccm_ahb_hibp_cmd_accept;
  wire                                  bs_o_iccm_ahb_hibp_cmd_read;
  wire  [42                -1:0]       bs_o_iccm_ahb_hibp_cmd_addr;
  wire                                  bs_o_iccm_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       bs_o_iccm_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       bs_o_iccm_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_iccm_ahb_hibp_cmd_prot;
  wire  [4-1:0]       bs_o_iccm_ahb_hibp_cmd_cache;
  wire                                  bs_o_iccm_ahb_hibp_cmd_lock;
  wire                                  bs_o_iccm_ahb_hibp_cmd_excl;

  wire                                  bs_o_iccm_ahb_hibp_rd_valid;
  wire                                  bs_o_iccm_ahb_hibp_rd_excl_ok;
  wire                                  bs_o_iccm_ahb_hibp_rd_accept;
  wire                                  bs_o_iccm_ahb_hibp_err_rd;
  wire  [32               -1:0]        bs_o_iccm_ahb_hibp_rd_data;
  wire                                  bs_o_iccm_ahb_hibp_rd_last;

  wire                                  bs_o_iccm_ahb_hibp_wr_valid;
  wire                                  bs_o_iccm_ahb_hibp_wr_accept;
  wire  [32               -1:0]        bs_o_iccm_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        bs_o_iccm_ahb_hibp_wr_mask;
  wire                                  bs_o_iccm_ahb_hibp_wr_last;

  wire                                  bs_o_iccm_ahb_hibp_wr_done;
  wire                                  bs_o_iccm_ahb_hibp_wr_excl_done;
  wire                                  bs_o_iccm_ahb_hibp_err_wr;
  wire                                  bs_o_iccm_ahb_hibp_wr_resp_accept;
wire [1-1:0] bs_o_iccm_ahb_hibp_cmd_region;



 wire [1-1:0] bs_o_iccm_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_iccm_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] bs_o_iccm_ahb_hibp_cmd_chnl;

 wire [1-1:0] bs_o_iccm_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] bs_o_iccm_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] bs_o_iccm_ahb_hibp_wd_chnl;

 wire [1-1:0] bs_o_iccm_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] bs_o_iccm_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] bs_o_iccm_ahb_hibp_rd_chnl;

 wire [1-1:0] bs_o_iccm_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_iccm_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_iccm_ahb_hibp_wrsp_chnl;

wire [1-1:0] bs_o_iccm_ahb_hibp_cmd_chnl_region;



 wire [1-1:0] slv_o_iccm_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_iccm_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] slv_o_iccm_ahb_hibp_cmd_chnl;

 wire [1-1:0] slv_o_iccm_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] slv_o_iccm_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_o_iccm_ahb_hibp_wd_chnl;

 wire [1-1:0] slv_o_iccm_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] slv_o_iccm_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_o_iccm_ahb_hibp_rd_chnl;

 wire [1-1:0] slv_o_iccm_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_iccm_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_iccm_ahb_hibp_wrsp_chnl;

wire [1-1:0] slv_o_iccm_ahb_hibp_cmd_chnl_region;


  wire                                  slv_o_iccm_ahb_hibp_cmd_valid;
  wire                                  slv_o_iccm_ahb_hibp_cmd_accept;
  wire                                  slv_o_iccm_ahb_hibp_cmd_read;
  wire  [42                -1:0]       slv_o_iccm_ahb_hibp_cmd_addr;
  wire                                  slv_o_iccm_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       slv_o_iccm_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       slv_o_iccm_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_iccm_ahb_hibp_cmd_prot;
  wire  [4-1:0]       slv_o_iccm_ahb_hibp_cmd_cache;
  wire                                  slv_o_iccm_ahb_hibp_cmd_lock;
  wire                                  slv_o_iccm_ahb_hibp_cmd_excl;

  wire                                  slv_o_iccm_ahb_hibp_rd_valid;
  wire                                  slv_o_iccm_ahb_hibp_rd_excl_ok;
  wire                                  slv_o_iccm_ahb_hibp_rd_accept;
  wire                                  slv_o_iccm_ahb_hibp_err_rd;
  wire  [32               -1:0]        slv_o_iccm_ahb_hibp_rd_data;
  wire                                  slv_o_iccm_ahb_hibp_rd_last;

  wire                                  slv_o_iccm_ahb_hibp_wr_valid;
  wire                                  slv_o_iccm_ahb_hibp_wr_accept;
  wire  [32               -1:0]        slv_o_iccm_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        slv_o_iccm_ahb_hibp_wr_mask;
  wire                                  slv_o_iccm_ahb_hibp_wr_last;

  wire                                  slv_o_iccm_ahb_hibp_wr_done;
  wire                                  slv_o_iccm_ahb_hibp_wr_excl_done;
  wire                                  slv_o_iccm_ahb_hibp_err_wr;
  wire                                  slv_o_iccm_ahb_hibp_wr_resp_accept;
wire [1-1:0] slv_o_iccm_ahb_hibp_cmd_region;
  


  wire                                  bs_o_dccm_ahb_hibp_cmd_valid;
  wire                                  bs_o_dccm_ahb_hibp_cmd_accept;
  wire                                  bs_o_dccm_ahb_hibp_cmd_read;
  wire  [42                -1:0]       bs_o_dccm_ahb_hibp_cmd_addr;
  wire                                  bs_o_dccm_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       bs_o_dccm_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       bs_o_dccm_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_dccm_ahb_hibp_cmd_prot;
  wire  [4-1:0]       bs_o_dccm_ahb_hibp_cmd_cache;
  wire                                  bs_o_dccm_ahb_hibp_cmd_lock;
  wire                                  bs_o_dccm_ahb_hibp_cmd_excl;

  wire                                  bs_o_dccm_ahb_hibp_rd_valid;
  wire                                  bs_o_dccm_ahb_hibp_rd_excl_ok;
  wire                                  bs_o_dccm_ahb_hibp_rd_accept;
  wire                                  bs_o_dccm_ahb_hibp_err_rd;
  wire  [32               -1:0]        bs_o_dccm_ahb_hibp_rd_data;
  wire                                  bs_o_dccm_ahb_hibp_rd_last;

  wire                                  bs_o_dccm_ahb_hibp_wr_valid;
  wire                                  bs_o_dccm_ahb_hibp_wr_accept;
  wire  [32               -1:0]        bs_o_dccm_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        bs_o_dccm_ahb_hibp_wr_mask;
  wire                                  bs_o_dccm_ahb_hibp_wr_last;

  wire                                  bs_o_dccm_ahb_hibp_wr_done;
  wire                                  bs_o_dccm_ahb_hibp_wr_excl_done;
  wire                                  bs_o_dccm_ahb_hibp_err_wr;
  wire                                  bs_o_dccm_ahb_hibp_wr_resp_accept;
wire [1-1:0] bs_o_dccm_ahb_hibp_cmd_region;



 wire [1-1:0] bs_o_dccm_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_dccm_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] bs_o_dccm_ahb_hibp_cmd_chnl;

 wire [1-1:0] bs_o_dccm_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] bs_o_dccm_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] bs_o_dccm_ahb_hibp_wd_chnl;

 wire [1-1:0] bs_o_dccm_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] bs_o_dccm_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] bs_o_dccm_ahb_hibp_rd_chnl;

 wire [1-1:0] bs_o_dccm_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_dccm_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_dccm_ahb_hibp_wrsp_chnl;

wire [1-1:0] bs_o_dccm_ahb_hibp_cmd_chnl_region;



 wire [1-1:0] slv_o_dccm_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_dccm_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] slv_o_dccm_ahb_hibp_cmd_chnl;

 wire [1-1:0] slv_o_dccm_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] slv_o_dccm_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_o_dccm_ahb_hibp_wd_chnl;

 wire [1-1:0] slv_o_dccm_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] slv_o_dccm_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_o_dccm_ahb_hibp_rd_chnl;

 wire [1-1:0] slv_o_dccm_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_dccm_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_dccm_ahb_hibp_wrsp_chnl;

wire [1-1:0] slv_o_dccm_ahb_hibp_cmd_chnl_region;


  wire                                  slv_o_dccm_ahb_hibp_cmd_valid;
  wire                                  slv_o_dccm_ahb_hibp_cmd_accept;
  wire                                  slv_o_dccm_ahb_hibp_cmd_read;
  wire  [42                -1:0]       slv_o_dccm_ahb_hibp_cmd_addr;
  wire                                  slv_o_dccm_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       slv_o_dccm_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       slv_o_dccm_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_dccm_ahb_hibp_cmd_prot;
  wire  [4-1:0]       slv_o_dccm_ahb_hibp_cmd_cache;
  wire                                  slv_o_dccm_ahb_hibp_cmd_lock;
  wire                                  slv_o_dccm_ahb_hibp_cmd_excl;

  wire                                  slv_o_dccm_ahb_hibp_rd_valid;
  wire                                  slv_o_dccm_ahb_hibp_rd_excl_ok;
  wire                                  slv_o_dccm_ahb_hibp_rd_accept;
  wire                                  slv_o_dccm_ahb_hibp_err_rd;
  wire  [32               -1:0]        slv_o_dccm_ahb_hibp_rd_data;
  wire                                  slv_o_dccm_ahb_hibp_rd_last;

  wire                                  slv_o_dccm_ahb_hibp_wr_valid;
  wire                                  slv_o_dccm_ahb_hibp_wr_accept;
  wire  [32               -1:0]        slv_o_dccm_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        slv_o_dccm_ahb_hibp_wr_mask;
  wire                                  slv_o_dccm_ahb_hibp_wr_last;

  wire                                  slv_o_dccm_ahb_hibp_wr_done;
  wire                                  slv_o_dccm_ahb_hibp_wr_excl_done;
  wire                                  slv_o_dccm_ahb_hibp_err_wr;
  wire                                  slv_o_dccm_ahb_hibp_wr_resp_accept;
wire [1-1:0] slv_o_dccm_ahb_hibp_cmd_region;
  


  wire                                  bs_o_mmio_ahb_hibp_cmd_valid;
  wire                                  bs_o_mmio_ahb_hibp_cmd_accept;
  wire                                  bs_o_mmio_ahb_hibp_cmd_read;
  wire  [42                -1:0]       bs_o_mmio_ahb_hibp_cmd_addr;
  wire                                  bs_o_mmio_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       bs_o_mmio_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       bs_o_mmio_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_mmio_ahb_hibp_cmd_prot;
  wire  [4-1:0]       bs_o_mmio_ahb_hibp_cmd_cache;
  wire                                  bs_o_mmio_ahb_hibp_cmd_lock;
  wire                                  bs_o_mmio_ahb_hibp_cmd_excl;

  wire                                  bs_o_mmio_ahb_hibp_rd_valid;
  wire                                  bs_o_mmio_ahb_hibp_rd_excl_ok;
  wire                                  bs_o_mmio_ahb_hibp_rd_accept;
  wire                                  bs_o_mmio_ahb_hibp_err_rd;
  wire  [32               -1:0]        bs_o_mmio_ahb_hibp_rd_data;
  wire                                  bs_o_mmio_ahb_hibp_rd_last;

  wire                                  bs_o_mmio_ahb_hibp_wr_valid;
  wire                                  bs_o_mmio_ahb_hibp_wr_accept;
  wire  [32               -1:0]        bs_o_mmio_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        bs_o_mmio_ahb_hibp_wr_mask;
  wire                                  bs_o_mmio_ahb_hibp_wr_last;

  wire                                  bs_o_mmio_ahb_hibp_wr_done;
  wire                                  bs_o_mmio_ahb_hibp_wr_excl_done;
  wire                                  bs_o_mmio_ahb_hibp_err_wr;
  wire                                  bs_o_mmio_ahb_hibp_wr_resp_accept;
wire [1-1:0] bs_o_mmio_ahb_hibp_cmd_region;



 wire [1-1:0] bs_o_mmio_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_mmio_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] bs_o_mmio_ahb_hibp_cmd_chnl;

 wire [1-1:0] bs_o_mmio_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] bs_o_mmio_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] bs_o_mmio_ahb_hibp_wd_chnl;

 wire [1-1:0] bs_o_mmio_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] bs_o_mmio_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] bs_o_mmio_ahb_hibp_rd_chnl;

 wire [1-1:0] bs_o_mmio_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_mmio_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_mmio_ahb_hibp_wrsp_chnl;

wire [1-1:0] bs_o_mmio_ahb_hibp_cmd_chnl_region;



 wire [1-1:0] slv_o_mmio_ahb_hibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_mmio_ahb_hibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] slv_o_mmio_ahb_hibp_cmd_chnl;

 wire [1-1:0] slv_o_mmio_ahb_hibp_wd_chnl_valid;
 wire [1-1:0] slv_o_mmio_ahb_hibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_o_mmio_ahb_hibp_wd_chnl;

 wire [1-1:0] slv_o_mmio_ahb_hibp_rd_chnl_accept;
 wire [1-1:0] slv_o_mmio_ahb_hibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_o_mmio_ahb_hibp_rd_chnl;

 wire [1-1:0] slv_o_mmio_ahb_hibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_mmio_ahb_hibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_mmio_ahb_hibp_wrsp_chnl;

wire [1-1:0] slv_o_mmio_ahb_hibp_cmd_chnl_region;


  wire                                  slv_o_mmio_ahb_hibp_cmd_valid;
  wire                                  slv_o_mmio_ahb_hibp_cmd_accept;
  wire                                  slv_o_mmio_ahb_hibp_cmd_read;
  wire  [42                -1:0]       slv_o_mmio_ahb_hibp_cmd_addr;
  wire                                  slv_o_mmio_ahb_hibp_cmd_wrap;
  wire  [3-1:0]       slv_o_mmio_ahb_hibp_cmd_data_size;
  wire  [4-1:0]       slv_o_mmio_ahb_hibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_mmio_ahb_hibp_cmd_prot;
  wire  [4-1:0]       slv_o_mmio_ahb_hibp_cmd_cache;
  wire                                  slv_o_mmio_ahb_hibp_cmd_lock;
  wire                                  slv_o_mmio_ahb_hibp_cmd_excl;

  wire                                  slv_o_mmio_ahb_hibp_rd_valid;
  wire                                  slv_o_mmio_ahb_hibp_rd_excl_ok;
  wire                                  slv_o_mmio_ahb_hibp_rd_accept;
  wire                                  slv_o_mmio_ahb_hibp_err_rd;
  wire  [32               -1:0]        slv_o_mmio_ahb_hibp_rd_data;
  wire                                  slv_o_mmio_ahb_hibp_rd_last;

  wire                                  slv_o_mmio_ahb_hibp_wr_valid;
  wire                                  slv_o_mmio_ahb_hibp_wr_accept;
  wire  [32               -1:0]        slv_o_mmio_ahb_hibp_wr_data;
  wire  [(32         /8)  -1:0]        slv_o_mmio_ahb_hibp_wr_mask;
  wire                                  slv_o_mmio_ahb_hibp_wr_last;

  wire                                  slv_o_mmio_ahb_hibp_wr_done;
  wire                                  slv_o_mmio_ahb_hibp_wr_excl_done;
  wire                                  slv_o_mmio_ahb_hibp_err_wr;
  wire                                  slv_o_mmio_ahb_hibp_wr_resp_accept;
wire [1-1:0] slv_o_mmio_ahb_hibp_cmd_region;
  


  wire                                  bs_o_mss_clkctrl_ibp_cmd_valid;
  wire                                  bs_o_mss_clkctrl_ibp_cmd_accept;
  wire                                  bs_o_mss_clkctrl_ibp_cmd_read;
  wire  [22                -1:0]       bs_o_mss_clkctrl_ibp_cmd_addr;
  wire                                  bs_o_mss_clkctrl_ibp_cmd_wrap;
  wire  [3-1:0]       bs_o_mss_clkctrl_ibp_cmd_data_size;
  wire  [4-1:0]       bs_o_mss_clkctrl_ibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_mss_clkctrl_ibp_cmd_prot;
  wire  [4-1:0]       bs_o_mss_clkctrl_ibp_cmd_cache;
  wire                                  bs_o_mss_clkctrl_ibp_cmd_lock;
  wire                                  bs_o_mss_clkctrl_ibp_cmd_excl;

  wire                                  bs_o_mss_clkctrl_ibp_rd_valid;
  wire                                  bs_o_mss_clkctrl_ibp_rd_excl_ok;
  wire                                  bs_o_mss_clkctrl_ibp_rd_accept;
  wire                                  bs_o_mss_clkctrl_ibp_err_rd;
  wire  [32               -1:0]        bs_o_mss_clkctrl_ibp_rd_data;
  wire                                  bs_o_mss_clkctrl_ibp_rd_last;

  wire                                  bs_o_mss_clkctrl_ibp_wr_valid;
  wire                                  bs_o_mss_clkctrl_ibp_wr_accept;
  wire  [32               -1:0]        bs_o_mss_clkctrl_ibp_wr_data;
  wire  [(32         /8)  -1:0]        bs_o_mss_clkctrl_ibp_wr_mask;
  wire                                  bs_o_mss_clkctrl_ibp_wr_last;

  wire                                  bs_o_mss_clkctrl_ibp_wr_done;
  wire                                  bs_o_mss_clkctrl_ibp_wr_excl_done;
  wire                                  bs_o_mss_clkctrl_ibp_err_wr;
  wire                                  bs_o_mss_clkctrl_ibp_wr_resp_accept;
wire [42-1:0]  bs_o_mss_clkctrl_ibp_cmd_addr_temp;
wire [1-1:0] bs_o_mss_clkctrl_ibp_cmd_region;



 wire [1-1:0] bs_o_mss_clkctrl_ibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_mss_clkctrl_ibp_cmd_chnl_accept;
 wire [39 * 1 -1:0] bs_o_mss_clkctrl_ibp_cmd_chnl;

 wire [1-1:0] bs_o_mss_clkctrl_ibp_wd_chnl_valid;
 wire [1-1:0] bs_o_mss_clkctrl_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] bs_o_mss_clkctrl_ibp_wd_chnl;

 wire [1-1:0] bs_o_mss_clkctrl_ibp_rd_chnl_accept;
 wire [1-1:0] bs_o_mss_clkctrl_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] bs_o_mss_clkctrl_ibp_rd_chnl;

 wire [1-1:0] bs_o_mss_clkctrl_ibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_mss_clkctrl_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_mss_clkctrl_ibp_wrsp_chnl;

wire [1-1:0] bs_o_mss_clkctrl_ibp_cmd_chnl_region;



 wire [1-1:0] slv_i_mss_clkctrl_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_i_mss_clkctrl_ibp_cmd_chnl_accept;
 wire [39 * 1 -1:0] slv_i_mss_clkctrl_ibp_cmd_chnl;

 wire [1-1:0] slv_i_mss_clkctrl_ibp_wd_chnl_valid;
 wire [1-1:0] slv_i_mss_clkctrl_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_i_mss_clkctrl_ibp_wd_chnl;

 wire [1-1:0] slv_i_mss_clkctrl_ibp_rd_chnl_accept;
 wire [1-1:0] slv_i_mss_clkctrl_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_i_mss_clkctrl_ibp_rd_chnl;

 wire [1-1:0] slv_i_mss_clkctrl_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_i_mss_clkctrl_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_i_mss_clkctrl_ibp_wrsp_chnl;

wire [1-1:0] slv_i_mss_clkctrl_ibp_cmd_chnl_region;



 wire [1-1:0] slv_o_mss_clkctrl_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_mss_clkctrl_ibp_cmd_chnl_accept;
 wire [39 * 1 -1:0] slv_o_mss_clkctrl_ibp_cmd_chnl;

 wire [1-1:0] slv_o_mss_clkctrl_ibp_wd_chnl_valid;
 wire [1-1:0] slv_o_mss_clkctrl_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_o_mss_clkctrl_ibp_wd_chnl;

 wire [1-1:0] slv_o_mss_clkctrl_ibp_rd_chnl_accept;
 wire [1-1:0] slv_o_mss_clkctrl_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_o_mss_clkctrl_ibp_rd_chnl;

 wire [1-1:0] slv_o_mss_clkctrl_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_mss_clkctrl_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_mss_clkctrl_ibp_wrsp_chnl;

wire [1-1:0] slv_o_mss_clkctrl_ibp_cmd_chnl_region;


  wire                                  slv_o_mss_clkctrl_ibp_cmd_valid;
  wire                                  slv_o_mss_clkctrl_ibp_cmd_accept;
  wire                                  slv_o_mss_clkctrl_ibp_cmd_read;
  wire  [22                -1:0]       slv_o_mss_clkctrl_ibp_cmd_addr;
  wire                                  slv_o_mss_clkctrl_ibp_cmd_wrap;
  wire  [3-1:0]       slv_o_mss_clkctrl_ibp_cmd_data_size;
  wire  [4-1:0]       slv_o_mss_clkctrl_ibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_mss_clkctrl_ibp_cmd_prot;
  wire  [4-1:0]       slv_o_mss_clkctrl_ibp_cmd_cache;
  wire                                  slv_o_mss_clkctrl_ibp_cmd_lock;
  wire                                  slv_o_mss_clkctrl_ibp_cmd_excl;

  wire                                  slv_o_mss_clkctrl_ibp_rd_valid;
  wire                                  slv_o_mss_clkctrl_ibp_rd_excl_ok;
  wire                                  slv_o_mss_clkctrl_ibp_rd_accept;
  wire                                  slv_o_mss_clkctrl_ibp_err_rd;
  wire  [32               -1:0]        slv_o_mss_clkctrl_ibp_rd_data;
  wire                                  slv_o_mss_clkctrl_ibp_rd_last;

  wire                                  slv_o_mss_clkctrl_ibp_wr_valid;
  wire                                  slv_o_mss_clkctrl_ibp_wr_accept;
  wire  [32               -1:0]        slv_o_mss_clkctrl_ibp_wr_data;
  wire  [(32         /8)  -1:0]        slv_o_mss_clkctrl_ibp_wr_mask;
  wire                                  slv_o_mss_clkctrl_ibp_wr_last;

  wire                                  slv_o_mss_clkctrl_ibp_wr_done;
  wire                                  slv_o_mss_clkctrl_ibp_wr_excl_done;
  wire                                  slv_o_mss_clkctrl_ibp_err_wr;
  wire                                  slv_o_mss_clkctrl_ibp_wr_resp_accept;
wire [1-1:0] slv_o_mss_clkctrl_ibp_cmd_region;
  


  wire                                  bs_o_dslv1_ibp_cmd_valid;
  wire                                  bs_o_dslv1_ibp_cmd_accept;
  wire                                  bs_o_dslv1_ibp_cmd_read;
  wire  [22                -1:0]       bs_o_dslv1_ibp_cmd_addr;
  wire                                  bs_o_dslv1_ibp_cmd_wrap;
  wire  [3-1:0]       bs_o_dslv1_ibp_cmd_data_size;
  wire  [4-1:0]       bs_o_dslv1_ibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_dslv1_ibp_cmd_prot;
  wire  [4-1:0]       bs_o_dslv1_ibp_cmd_cache;
  wire                                  bs_o_dslv1_ibp_cmd_lock;
  wire                                  bs_o_dslv1_ibp_cmd_excl;

  wire                                  bs_o_dslv1_ibp_rd_valid;
  wire                                  bs_o_dslv1_ibp_rd_excl_ok;
  wire                                  bs_o_dslv1_ibp_rd_accept;
  wire                                  bs_o_dslv1_ibp_err_rd;
  wire  [32               -1:0]        bs_o_dslv1_ibp_rd_data;
  wire                                  bs_o_dslv1_ibp_rd_last;

  wire                                  bs_o_dslv1_ibp_wr_valid;
  wire                                  bs_o_dslv1_ibp_wr_accept;
  wire  [32               -1:0]        bs_o_dslv1_ibp_wr_data;
  wire  [(32         /8)  -1:0]        bs_o_dslv1_ibp_wr_mask;
  wire                                  bs_o_dslv1_ibp_wr_last;

  wire                                  bs_o_dslv1_ibp_wr_done;
  wire                                  bs_o_dslv1_ibp_wr_excl_done;
  wire                                  bs_o_dslv1_ibp_err_wr;
  wire                                  bs_o_dslv1_ibp_wr_resp_accept;
wire [42-1:0]  bs_o_dslv1_ibp_cmd_addr_temp;
wire [1-1:0] bs_o_dslv1_ibp_cmd_region;



 wire [1-1:0] bs_o_dslv1_ibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_dslv1_ibp_cmd_chnl_accept;
 wire [39 * 1 -1:0] bs_o_dslv1_ibp_cmd_chnl;

 wire [1-1:0] bs_o_dslv1_ibp_wd_chnl_valid;
 wire [1-1:0] bs_o_dslv1_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] bs_o_dslv1_ibp_wd_chnl;

 wire [1-1:0] bs_o_dslv1_ibp_rd_chnl_accept;
 wire [1-1:0] bs_o_dslv1_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] bs_o_dslv1_ibp_rd_chnl;

 wire [1-1:0] bs_o_dslv1_ibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_dslv1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_dslv1_ibp_wrsp_chnl;

wire [1-1:0] bs_o_dslv1_ibp_cmd_chnl_region;



 wire [1-1:0] slv_i_dslv1_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_i_dslv1_ibp_cmd_chnl_accept;
 wire [39 * 1 -1:0] slv_i_dslv1_ibp_cmd_chnl;

 wire [1-1:0] slv_i_dslv1_ibp_wd_chnl_valid;
 wire [1-1:0] slv_i_dslv1_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_i_dslv1_ibp_wd_chnl;

 wire [1-1:0] slv_i_dslv1_ibp_rd_chnl_accept;
 wire [1-1:0] slv_i_dslv1_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_i_dslv1_ibp_rd_chnl;

 wire [1-1:0] slv_i_dslv1_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_i_dslv1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_i_dslv1_ibp_wrsp_chnl;

wire [1-1:0] slv_i_dslv1_ibp_cmd_chnl_region;



 wire [1-1:0] slv_o_dslv1_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_dslv1_ibp_cmd_chnl_accept;
 wire [39 * 1 -1:0] slv_o_dslv1_ibp_cmd_chnl;

 wire [1-1:0] slv_o_dslv1_ibp_wd_chnl_valid;
 wire [1-1:0] slv_o_dslv1_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_o_dslv1_ibp_wd_chnl;

 wire [1-1:0] slv_o_dslv1_ibp_rd_chnl_accept;
 wire [1-1:0] slv_o_dslv1_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_o_dslv1_ibp_rd_chnl;

 wire [1-1:0] slv_o_dslv1_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_dslv1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_dslv1_ibp_wrsp_chnl;

wire [1-1:0] slv_o_dslv1_ibp_cmd_chnl_region;


  wire                                  slv_o_dslv1_ibp_cmd_valid;
  wire                                  slv_o_dslv1_ibp_cmd_accept;
  wire                                  slv_o_dslv1_ibp_cmd_read;
  wire  [22                -1:0]       slv_o_dslv1_ibp_cmd_addr;
  wire                                  slv_o_dslv1_ibp_cmd_wrap;
  wire  [3-1:0]       slv_o_dslv1_ibp_cmd_data_size;
  wire  [4-1:0]       slv_o_dslv1_ibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_dslv1_ibp_cmd_prot;
  wire  [4-1:0]       slv_o_dslv1_ibp_cmd_cache;
  wire                                  slv_o_dslv1_ibp_cmd_lock;
  wire                                  slv_o_dslv1_ibp_cmd_excl;

  wire                                  slv_o_dslv1_ibp_rd_valid;
  wire                                  slv_o_dslv1_ibp_rd_excl_ok;
  wire                                  slv_o_dslv1_ibp_rd_accept;
  wire                                  slv_o_dslv1_ibp_err_rd;
  wire  [32               -1:0]        slv_o_dslv1_ibp_rd_data;
  wire                                  slv_o_dslv1_ibp_rd_last;

  wire                                  slv_o_dslv1_ibp_wr_valid;
  wire                                  slv_o_dslv1_ibp_wr_accept;
  wire  [32               -1:0]        slv_o_dslv1_ibp_wr_data;
  wire  [(32         /8)  -1:0]        slv_o_dslv1_ibp_wr_mask;
  wire                                  slv_o_dslv1_ibp_wr_last;

  wire                                  slv_o_dslv1_ibp_wr_done;
  wire                                  slv_o_dslv1_ibp_wr_excl_done;
  wire                                  slv_o_dslv1_ibp_err_wr;
  wire                                  slv_o_dslv1_ibp_wr_resp_accept;
wire [1-1:0] slv_o_dslv1_ibp_cmd_region;
  


  wire                                  bs_o_dslv2_ibp_cmd_valid;
  wire                                  bs_o_dslv2_ibp_cmd_accept;
  wire                                  bs_o_dslv2_ibp_cmd_read;
  wire  [34                -1:0]       bs_o_dslv2_ibp_cmd_addr;
  wire                                  bs_o_dslv2_ibp_cmd_wrap;
  wire  [3-1:0]       bs_o_dslv2_ibp_cmd_data_size;
  wire  [4-1:0]       bs_o_dslv2_ibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_dslv2_ibp_cmd_prot;
  wire  [4-1:0]       bs_o_dslv2_ibp_cmd_cache;
  wire                                  bs_o_dslv2_ibp_cmd_lock;
  wire                                  bs_o_dslv2_ibp_cmd_excl;

  wire                                  bs_o_dslv2_ibp_rd_valid;
  wire                                  bs_o_dslv2_ibp_rd_excl_ok;
  wire                                  bs_o_dslv2_ibp_rd_accept;
  wire                                  bs_o_dslv2_ibp_err_rd;
  wire  [64               -1:0]        bs_o_dslv2_ibp_rd_data;
  wire                                  bs_o_dslv2_ibp_rd_last;

  wire                                  bs_o_dslv2_ibp_wr_valid;
  wire                                  bs_o_dslv2_ibp_wr_accept;
  wire  [64               -1:0]        bs_o_dslv2_ibp_wr_data;
  wire  [(64         /8)  -1:0]        bs_o_dslv2_ibp_wr_mask;
  wire                                  bs_o_dslv2_ibp_wr_last;

  wire                                  bs_o_dslv2_ibp_wr_done;
  wire                                  bs_o_dslv2_ibp_wr_excl_done;
  wire                                  bs_o_dslv2_ibp_err_wr;
  wire                                  bs_o_dslv2_ibp_wr_resp_accept;
wire [42-1:0]  bs_o_dslv2_ibp_cmd_addr_temp;
wire [1-1:0] bs_o_dslv2_ibp_cmd_region;



 wire [1-1:0] bs_o_dslv2_ibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_dslv2_ibp_cmd_chnl_accept;
 wire [51 * 1 -1:0] bs_o_dslv2_ibp_cmd_chnl;

 wire [1-1:0] bs_o_dslv2_ibp_wd_chnl_valid;
 wire [1-1:0] bs_o_dslv2_ibp_wd_chnl_accept;
 wire [73 * 1 -1:0] bs_o_dslv2_ibp_wd_chnl;

 wire [1-1:0] bs_o_dslv2_ibp_rd_chnl_accept;
 wire [1-1:0] bs_o_dslv2_ibp_rd_chnl_valid;
 wire [67 * 1 -1:0] bs_o_dslv2_ibp_rd_chnl;

 wire [1-1:0] bs_o_dslv2_ibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_dslv2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_dslv2_ibp_wrsp_chnl;

wire [1-1:0] bs_o_dslv2_ibp_cmd_chnl_region;



 wire [1-1:0] slv_i_dslv2_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_i_dslv2_ibp_cmd_chnl_accept;
 wire [51 * 1 -1:0] slv_i_dslv2_ibp_cmd_chnl;

 wire [1-1:0] slv_i_dslv2_ibp_wd_chnl_valid;
 wire [1-1:0] slv_i_dslv2_ibp_wd_chnl_accept;
 wire [73 * 1 -1:0] slv_i_dslv2_ibp_wd_chnl;

 wire [1-1:0] slv_i_dslv2_ibp_rd_chnl_accept;
 wire [1-1:0] slv_i_dslv2_ibp_rd_chnl_valid;
 wire [67 * 1 -1:0] slv_i_dslv2_ibp_rd_chnl;

 wire [1-1:0] slv_i_dslv2_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_i_dslv2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_i_dslv2_ibp_wrsp_chnl;

wire [1-1:0] slv_i_dslv2_ibp_cmd_chnl_region;



 wire [1-1:0] slv_o_dslv2_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_dslv2_ibp_cmd_chnl_accept;
 wire [51 * 1 -1:0] slv_o_dslv2_ibp_cmd_chnl;

 wire [1-1:0] slv_o_dslv2_ibp_wd_chnl_valid;
 wire [1-1:0] slv_o_dslv2_ibp_wd_chnl_accept;
 wire [73 * 1 -1:0] slv_o_dslv2_ibp_wd_chnl;

 wire [1-1:0] slv_o_dslv2_ibp_rd_chnl_accept;
 wire [1-1:0] slv_o_dslv2_ibp_rd_chnl_valid;
 wire [67 * 1 -1:0] slv_o_dslv2_ibp_rd_chnl;

 wire [1-1:0] slv_o_dslv2_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_dslv2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_dslv2_ibp_wrsp_chnl;

wire [1-1:0] slv_o_dslv2_ibp_cmd_chnl_region;


  wire                                  slv_o_dslv2_ibp_cmd_valid;
  wire                                  slv_o_dslv2_ibp_cmd_accept;
  wire                                  slv_o_dslv2_ibp_cmd_read;
  wire  [34                -1:0]       slv_o_dslv2_ibp_cmd_addr;
  wire                                  slv_o_dslv2_ibp_cmd_wrap;
  wire  [3-1:0]       slv_o_dslv2_ibp_cmd_data_size;
  wire  [4-1:0]       slv_o_dslv2_ibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_dslv2_ibp_cmd_prot;
  wire  [4-1:0]       slv_o_dslv2_ibp_cmd_cache;
  wire                                  slv_o_dslv2_ibp_cmd_lock;
  wire                                  slv_o_dslv2_ibp_cmd_excl;

  wire                                  slv_o_dslv2_ibp_rd_valid;
  wire                                  slv_o_dslv2_ibp_rd_excl_ok;
  wire                                  slv_o_dslv2_ibp_rd_accept;
  wire                                  slv_o_dslv2_ibp_err_rd;
  wire  [64               -1:0]        slv_o_dslv2_ibp_rd_data;
  wire                                  slv_o_dslv2_ibp_rd_last;

  wire                                  slv_o_dslv2_ibp_wr_valid;
  wire                                  slv_o_dslv2_ibp_wr_accept;
  wire  [64               -1:0]        slv_o_dslv2_ibp_wr_data;
  wire  [(64         /8)  -1:0]        slv_o_dslv2_ibp_wr_mask;
  wire                                  slv_o_dslv2_ibp_wr_last;

  wire                                  slv_o_dslv2_ibp_wr_done;
  wire                                  slv_o_dslv2_ibp_wr_excl_done;
  wire                                  slv_o_dslv2_ibp_err_wr;
  wire                                  slv_o_dslv2_ibp_wr_resp_accept;
wire [1-1:0] slv_o_dslv2_ibp_cmd_region;
  


  wire                                  bs_o_mss_perfctrl_ibp_cmd_valid;
  wire                                  bs_o_mss_perfctrl_ibp_cmd_accept;
  wire                                  bs_o_mss_perfctrl_ibp_cmd_read;
  wire  [23                -1:0]       bs_o_mss_perfctrl_ibp_cmd_addr;
  wire                                  bs_o_mss_perfctrl_ibp_cmd_wrap;
  wire  [3-1:0]       bs_o_mss_perfctrl_ibp_cmd_data_size;
  wire  [4-1:0]       bs_o_mss_perfctrl_ibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_mss_perfctrl_ibp_cmd_prot;
  wire  [4-1:0]       bs_o_mss_perfctrl_ibp_cmd_cache;
  wire                                  bs_o_mss_perfctrl_ibp_cmd_lock;
  wire                                  bs_o_mss_perfctrl_ibp_cmd_excl;

  wire                                  bs_o_mss_perfctrl_ibp_rd_valid;
  wire                                  bs_o_mss_perfctrl_ibp_rd_excl_ok;
  wire                                  bs_o_mss_perfctrl_ibp_rd_accept;
  wire                                  bs_o_mss_perfctrl_ibp_err_rd;
  wire  [32               -1:0]        bs_o_mss_perfctrl_ibp_rd_data;
  wire                                  bs_o_mss_perfctrl_ibp_rd_last;

  wire                                  bs_o_mss_perfctrl_ibp_wr_valid;
  wire                                  bs_o_mss_perfctrl_ibp_wr_accept;
  wire  [32               -1:0]        bs_o_mss_perfctrl_ibp_wr_data;
  wire  [(32         /8)  -1:0]        bs_o_mss_perfctrl_ibp_wr_mask;
  wire                                  bs_o_mss_perfctrl_ibp_wr_last;

  wire                                  bs_o_mss_perfctrl_ibp_wr_done;
  wire                                  bs_o_mss_perfctrl_ibp_wr_excl_done;
  wire                                  bs_o_mss_perfctrl_ibp_err_wr;
  wire                                  bs_o_mss_perfctrl_ibp_wr_resp_accept;
wire [42-1:0]  bs_o_mss_perfctrl_ibp_cmd_addr_temp;
wire [1-1:0] bs_o_mss_perfctrl_ibp_cmd_region;



 wire [1-1:0] bs_o_mss_perfctrl_ibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_mss_perfctrl_ibp_cmd_chnl_accept;
 wire [40 * 1 -1:0] bs_o_mss_perfctrl_ibp_cmd_chnl;

 wire [1-1:0] bs_o_mss_perfctrl_ibp_wd_chnl_valid;
 wire [1-1:0] bs_o_mss_perfctrl_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] bs_o_mss_perfctrl_ibp_wd_chnl;

 wire [1-1:0] bs_o_mss_perfctrl_ibp_rd_chnl_accept;
 wire [1-1:0] bs_o_mss_perfctrl_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] bs_o_mss_perfctrl_ibp_rd_chnl;

 wire [1-1:0] bs_o_mss_perfctrl_ibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_mss_perfctrl_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_mss_perfctrl_ibp_wrsp_chnl;

wire [1-1:0] bs_o_mss_perfctrl_ibp_cmd_chnl_region;



 wire [1-1:0] slv_i_mss_perfctrl_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_i_mss_perfctrl_ibp_cmd_chnl_accept;
 wire [40 * 1 -1:0] slv_i_mss_perfctrl_ibp_cmd_chnl;

 wire [1-1:0] slv_i_mss_perfctrl_ibp_wd_chnl_valid;
 wire [1-1:0] slv_i_mss_perfctrl_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_i_mss_perfctrl_ibp_wd_chnl;

 wire [1-1:0] slv_i_mss_perfctrl_ibp_rd_chnl_accept;
 wire [1-1:0] slv_i_mss_perfctrl_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_i_mss_perfctrl_ibp_rd_chnl;

 wire [1-1:0] slv_i_mss_perfctrl_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_i_mss_perfctrl_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_i_mss_perfctrl_ibp_wrsp_chnl;

wire [1-1:0] slv_i_mss_perfctrl_ibp_cmd_chnl_region;



 wire [1-1:0] slv_o_mss_perfctrl_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_mss_perfctrl_ibp_cmd_chnl_accept;
 wire [40 * 1 -1:0] slv_o_mss_perfctrl_ibp_cmd_chnl;

 wire [1-1:0] slv_o_mss_perfctrl_ibp_wd_chnl_valid;
 wire [1-1:0] slv_o_mss_perfctrl_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] slv_o_mss_perfctrl_ibp_wd_chnl;

 wire [1-1:0] slv_o_mss_perfctrl_ibp_rd_chnl_accept;
 wire [1-1:0] slv_o_mss_perfctrl_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] slv_o_mss_perfctrl_ibp_rd_chnl;

 wire [1-1:0] slv_o_mss_perfctrl_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_mss_perfctrl_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_mss_perfctrl_ibp_wrsp_chnl;

wire [1-1:0] slv_o_mss_perfctrl_ibp_cmd_chnl_region;


  wire                                  slv_o_mss_perfctrl_ibp_cmd_valid;
  wire                                  slv_o_mss_perfctrl_ibp_cmd_accept;
  wire                                  slv_o_mss_perfctrl_ibp_cmd_read;
  wire  [23                -1:0]       slv_o_mss_perfctrl_ibp_cmd_addr;
  wire                                  slv_o_mss_perfctrl_ibp_cmd_wrap;
  wire  [3-1:0]       slv_o_mss_perfctrl_ibp_cmd_data_size;
  wire  [4-1:0]       slv_o_mss_perfctrl_ibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_mss_perfctrl_ibp_cmd_prot;
  wire  [4-1:0]       slv_o_mss_perfctrl_ibp_cmd_cache;
  wire                                  slv_o_mss_perfctrl_ibp_cmd_lock;
  wire                                  slv_o_mss_perfctrl_ibp_cmd_excl;

  wire                                  slv_o_mss_perfctrl_ibp_rd_valid;
  wire                                  slv_o_mss_perfctrl_ibp_rd_excl_ok;
  wire                                  slv_o_mss_perfctrl_ibp_rd_accept;
  wire                                  slv_o_mss_perfctrl_ibp_err_rd;
  wire  [32               -1:0]        slv_o_mss_perfctrl_ibp_rd_data;
  wire                                  slv_o_mss_perfctrl_ibp_rd_last;

  wire                                  slv_o_mss_perfctrl_ibp_wr_valid;
  wire                                  slv_o_mss_perfctrl_ibp_wr_accept;
  wire  [32               -1:0]        slv_o_mss_perfctrl_ibp_wr_data;
  wire  [(32         /8)  -1:0]        slv_o_mss_perfctrl_ibp_wr_mask;
  wire                                  slv_o_mss_perfctrl_ibp_wr_last;

  wire                                  slv_o_mss_perfctrl_ibp_wr_done;
  wire                                  slv_o_mss_perfctrl_ibp_wr_excl_done;
  wire                                  slv_o_mss_perfctrl_ibp_err_wr;
  wire                                  slv_o_mss_perfctrl_ibp_wr_resp_accept;
wire [1-1:0] slv_o_mss_perfctrl_ibp_cmd_region;
  


  wire                                  bs_o_mss_mem_ibp_cmd_valid;
  wire                                  bs_o_mss_mem_ibp_cmd_accept;
  wire                                  bs_o_mss_mem_ibp_cmd_read;
  wire  [42                -1:0]       bs_o_mss_mem_ibp_cmd_addr;
  wire                                  bs_o_mss_mem_ibp_cmd_wrap;
  wire  [3-1:0]       bs_o_mss_mem_ibp_cmd_data_size;
  wire  [4-1:0]       bs_o_mss_mem_ibp_cmd_burst_size;
  wire  [2-1:0]       bs_o_mss_mem_ibp_cmd_prot;
  wire  [4-1:0]       bs_o_mss_mem_ibp_cmd_cache;
  wire                                  bs_o_mss_mem_ibp_cmd_lock;
  wire                                  bs_o_mss_mem_ibp_cmd_excl;

  wire                                  bs_o_mss_mem_ibp_rd_valid;
  wire                                  bs_o_mss_mem_ibp_rd_excl_ok;
  wire                                  bs_o_mss_mem_ibp_rd_accept;
  wire                                  bs_o_mss_mem_ibp_err_rd;
  wire  [128               -1:0]        bs_o_mss_mem_ibp_rd_data;
  wire                                  bs_o_mss_mem_ibp_rd_last;

  wire                                  bs_o_mss_mem_ibp_wr_valid;
  wire                                  bs_o_mss_mem_ibp_wr_accept;
  wire  [128               -1:0]        bs_o_mss_mem_ibp_wr_data;
  wire  [(128         /8)  -1:0]        bs_o_mss_mem_ibp_wr_mask;
  wire                                  bs_o_mss_mem_ibp_wr_last;

  wire                                  bs_o_mss_mem_ibp_wr_done;
  wire                                  bs_o_mss_mem_ibp_wr_excl_done;
  wire                                  bs_o_mss_mem_ibp_err_wr;
  wire                                  bs_o_mss_mem_ibp_wr_resp_accept;
wire [1-1:0] bs_o_mss_mem_ibp_cmd_region;



 wire [1-1:0] bs_o_mss_mem_ibp_cmd_chnl_valid;
 wire [1-1:0] bs_o_mss_mem_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] bs_o_mss_mem_ibp_cmd_chnl;

 wire [1-1:0] bs_o_mss_mem_ibp_wd_chnl_valid;
 wire [1-1:0] bs_o_mss_mem_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] bs_o_mss_mem_ibp_wd_chnl;

 wire [1-1:0] bs_o_mss_mem_ibp_rd_chnl_accept;
 wire [1-1:0] bs_o_mss_mem_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] bs_o_mss_mem_ibp_rd_chnl;

 wire [1-1:0] bs_o_mss_mem_ibp_wrsp_chnl_valid;
 wire [1-1:0] bs_o_mss_mem_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bs_o_mss_mem_ibp_wrsp_chnl;

wire [1-1:0] bs_o_mss_mem_ibp_cmd_chnl_region;



 wire [1-1:0] slv_i_mss_mem_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_i_mss_mem_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] slv_i_mss_mem_ibp_cmd_chnl;

 wire [1-1:0] slv_i_mss_mem_ibp_wd_chnl_valid;
 wire [1-1:0] slv_i_mss_mem_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] slv_i_mss_mem_ibp_wd_chnl;

 wire [1-1:0] slv_i_mss_mem_ibp_rd_chnl_accept;
 wire [1-1:0] slv_i_mss_mem_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] slv_i_mss_mem_ibp_rd_chnl;

 wire [1-1:0] slv_i_mss_mem_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_i_mss_mem_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_i_mss_mem_ibp_wrsp_chnl;

wire [1-1:0] slv_i_mss_mem_ibp_cmd_chnl_region;



 wire [1-1:0] slv_o_mss_mem_ibp_cmd_chnl_valid;
 wire [1-1:0] slv_o_mss_mem_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] slv_o_mss_mem_ibp_cmd_chnl;

 wire [1-1:0] slv_o_mss_mem_ibp_wd_chnl_valid;
 wire [1-1:0] slv_o_mss_mem_ibp_wd_chnl_accept;
 wire [145 * 1 -1:0] slv_o_mss_mem_ibp_wd_chnl;

 wire [1-1:0] slv_o_mss_mem_ibp_rd_chnl_accept;
 wire [1-1:0] slv_o_mss_mem_ibp_rd_chnl_valid;
 wire [131 * 1 -1:0] slv_o_mss_mem_ibp_rd_chnl;

 wire [1-1:0] slv_o_mss_mem_ibp_wrsp_chnl_valid;
 wire [1-1:0] slv_o_mss_mem_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] slv_o_mss_mem_ibp_wrsp_chnl;

wire [1-1:0] slv_o_mss_mem_ibp_cmd_chnl_region;


  wire                                  slv_o_mss_mem_ibp_cmd_valid;
  wire                                  slv_o_mss_mem_ibp_cmd_accept;
  wire                                  slv_o_mss_mem_ibp_cmd_read;
  wire  [42                -1:0]       slv_o_mss_mem_ibp_cmd_addr;
  wire                                  slv_o_mss_mem_ibp_cmd_wrap;
  wire  [3-1:0]       slv_o_mss_mem_ibp_cmd_data_size;
  wire  [4-1:0]       slv_o_mss_mem_ibp_cmd_burst_size;
  wire  [2-1:0]       slv_o_mss_mem_ibp_cmd_prot;
  wire  [4-1:0]       slv_o_mss_mem_ibp_cmd_cache;
  wire                                  slv_o_mss_mem_ibp_cmd_lock;
  wire                                  slv_o_mss_mem_ibp_cmd_excl;

  wire                                  slv_o_mss_mem_ibp_rd_valid;
  wire                                  slv_o_mss_mem_ibp_rd_excl_ok;
  wire                                  slv_o_mss_mem_ibp_rd_accept;
  wire                                  slv_o_mss_mem_ibp_err_rd;
  wire  [128               -1:0]        slv_o_mss_mem_ibp_rd_data;
  wire                                  slv_o_mss_mem_ibp_rd_last;

  wire                                  slv_o_mss_mem_ibp_wr_valid;
  wire                                  slv_o_mss_mem_ibp_wr_accept;
  wire  [128               -1:0]        slv_o_mss_mem_ibp_wr_data;
  wire  [(128         /8)  -1:0]        slv_o_mss_mem_ibp_wr_mask;
  wire                                  slv_o_mss_mem_ibp_wr_last;

  wire                                  slv_o_mss_mem_ibp_wr_done;
  wire                                  slv_o_mss_mem_ibp_wr_excl_done;
  wire                                  slv_o_mss_mem_ibp_err_wr;
  wire                                  slv_o_mss_mem_ibp_wr_resp_accept;
wire [1-1:0] slv_o_mss_mem_ibp_cmd_region;
  



    // Master protocol converters


    wire [2-1:0] ahb_hport_id;      // master0 port ID
    wire [4-1:0] ahb_huser_signal;  // master0 user signal, user_iw >= 1
    wire [6-1:0]   ahb_hsb_addr;      // master0 side-band address (exclude iw)
    assign ahb_hport_id = 0;
    assign ahb_huser_signal = {ahb_hprot[6:4], ahb_hnonsec};
    assign ahb_hsb_addr = {ahb_huser_signal
                            ,ahb_hport_id
                           };

    assign ahb_hrdatachk[0] = ~(^ahb_hrdata[7:0]);
    assign ahb_hrdatachk[1] = ~(^ahb_hrdata[15:8]);
    assign ahb_hrdatachk[2] = ~(^ahb_hrdata[23:16]);
    assign ahb_hrdatachk[3] = ~(^ahb_hrdata[31:24]);
    assign ahb_hreadychk = ~ahb_hready;
    assign ahb_hrespchk  = ~ahb_hresp;







    alb_mss_fab_ahbl2ibp    #(.FORCE_TO_SINGLE(0),
                              .SUPPORT_LOCK (1),
                              .AHBL_EBT(0),
                              .X_W(32),
                              .Y_W(32),
                              .SEL_W(1),
                              .RGON_W(1),
                              .CHNL_FIFO_DEPTH(0),
                              .BUS_SUPPORT_RTIO(1),
                              .ADDR_W(42),
                              .DATA_W(32),
                              .ALSB(2)) u_ahb_hprot_inst(
                                                     .bigendian(1'b0),
                                                     .ahb_htrans(ahb_htrans),
                                                     .ahb_hwrite(ahb_hwrite),
                                                     .ahb_hsel(1'b1),
                                                     .ahb_haddr({ahb_hsb_addr,ahb_hmaster,ahb_haddr}),
                                                     .ahb_hsize(ahb_hsize),
                                                     .ahb_hlock(1'b0),
                                                     .ahb_hburst(ahb_hburst),
                                                     .ahb_hprot(ahb_hprot[3:0]),
                                                     .ahb_hwdata(ahb_hwdata),
                                                     .ahb_hwstrb(ahb_hwstrb),
                                                     .ahb_hrdata(ahb_hrdata),
                                                     .ahb_hresp(ahb_hresp),
                                                     .ahb_hready_resp(ahb_hready),
                                                     .ahb_hready(1'b1),
                                                     .ahb_hexcl(ahb_hexcl),
                                                     .ahb_hexokay(ahb_hexokay),
                                                     // IBP I/F

  .ibp_cmd_valid             (mst_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (mst_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (mst_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (mst_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (mst_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (mst_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (mst_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (mst_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (mst_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (mst_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (mst_ahb_hibp_rd_accept),
  .ibp_err_rd                (mst_ahb_hibp_err_rd),
  .ibp_rd_data               (mst_ahb_hibp_rd_data),
  .ibp_rd_last               (mst_ahb_hibp_rd_last),

  .ibp_wr_valid              (mst_ahb_hibp_wr_valid),
  .ibp_wr_accept             (mst_ahb_hibp_wr_accept),
  .ibp_wr_data               (mst_ahb_hibp_wr_data),
  .ibp_wr_mask               (mst_ahb_hibp_wr_mask),
  .ibp_wr_last               (mst_ahb_hibp_wr_last),

  .ibp_wr_done               (mst_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (mst_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (mst_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (mst_ahb_hibp_wr_resp_accept),
                                                     .ibp_cmd_rgon(mst_ahb_hibp_cmd_rgon),
                                                     // clock and reset
                                                     .clk(clk),
                                                     .bus_clk_en(1'b1),
                                                     .rst_a(~rst_b),
                                                     .sync_rst_r(~rst_b)
                                                     );


    wire [2-1:0] dbu_per_ahb_hport_id;      // master1 port ID
    wire [4-1:0] dbu_per_ahb_huser_signal;  // master1 user signal, user_iw >= 1
    wire [6-1:0]   dbu_per_ahb_hsb_addr;      // master1 side-band address (exclude iw)
    assign dbu_per_ahb_hport_id = 1;
    assign dbu_per_ahb_huser_signal = {dbu_per_ahb_hprot[6:4], dbu_per_ahb_hnonsec};
    assign dbu_per_ahb_hsb_addr = {dbu_per_ahb_huser_signal
                            ,dbu_per_ahb_hport_id
                           };

    assign dbu_per_ahb_hrdatachk[0] = ~(^dbu_per_ahb_hrdata[7:0]);
    assign dbu_per_ahb_hrdatachk[1] = ~(^dbu_per_ahb_hrdata[15:8]);
    assign dbu_per_ahb_hrdatachk[2] = ~(^dbu_per_ahb_hrdata[23:16]);
    assign dbu_per_ahb_hrdatachk[3] = ~(^dbu_per_ahb_hrdata[31:24]);
    assign dbu_per_ahb_hreadychk = ~dbu_per_ahb_hready;
    assign dbu_per_ahb_hrespchk  = ~dbu_per_ahb_hresp;







    alb_mss_fab_ahbl2ibp    #(.FORCE_TO_SINGLE(0),
                              .SUPPORT_LOCK (1),
                              .AHBL_EBT(0),
                              .X_W(32),
                              .Y_W(32),
                              .SEL_W(1),
                              .RGON_W(1),
                              .CHNL_FIFO_DEPTH(0),
                              .BUS_SUPPORT_RTIO(1),
                              .ADDR_W(42),
                              .DATA_W(32),
                              .ALSB(2)) u_dbu_per_ahb_hprot_inst(
                                                     .bigendian(1'b0),
                                                     .ahb_htrans(dbu_per_ahb_htrans),
                                                     .ahb_hwrite(dbu_per_ahb_hwrite),
                                                     .ahb_hsel(1'b1),
                                                     .ahb_haddr({dbu_per_ahb_hsb_addr,dbu_per_ahb_hmaster,dbu_per_ahb_haddr}),
                                                     .ahb_hsize(dbu_per_ahb_hsize),
                                                     .ahb_hlock(1'b0),
                                                     .ahb_hburst(dbu_per_ahb_hburst),
                                                     .ahb_hprot(dbu_per_ahb_hprot[3:0]),
                                                     .ahb_hwdata(dbu_per_ahb_hwdata),
                                                     .ahb_hwstrb(dbu_per_ahb_hwstrb),
                                                     .ahb_hrdata(dbu_per_ahb_hrdata),
                                                     .ahb_hresp(dbu_per_ahb_hresp),
                                                     .ahb_hready_resp(dbu_per_ahb_hready),
                                                     .ahb_hready(1'b1),
                                                     .ahb_hexcl(dbu_per_ahb_hexcl),
                                                     .ahb_hexokay(dbu_per_ahb_hexokay),
                                                     // IBP I/F

  .ibp_cmd_valid             (mst_dbu_per_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (mst_dbu_per_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (mst_dbu_per_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (mst_dbu_per_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (mst_dbu_per_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_dbu_per_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_dbu_per_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_dbu_per_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (mst_dbu_per_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (mst_dbu_per_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (mst_dbu_per_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (mst_dbu_per_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (mst_dbu_per_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (mst_dbu_per_ahb_hibp_rd_accept),
  .ibp_err_rd                (mst_dbu_per_ahb_hibp_err_rd),
  .ibp_rd_data               (mst_dbu_per_ahb_hibp_rd_data),
  .ibp_rd_last               (mst_dbu_per_ahb_hibp_rd_last),

  .ibp_wr_valid              (mst_dbu_per_ahb_hibp_wr_valid),
  .ibp_wr_accept             (mst_dbu_per_ahb_hibp_wr_accept),
  .ibp_wr_data               (mst_dbu_per_ahb_hibp_wr_data),
  .ibp_wr_mask               (mst_dbu_per_ahb_hibp_wr_mask),
  .ibp_wr_last               (mst_dbu_per_ahb_hibp_wr_last),

  .ibp_wr_done               (mst_dbu_per_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (mst_dbu_per_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (mst_dbu_per_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (mst_dbu_per_ahb_hibp_wr_resp_accept),
                                                     .ibp_cmd_rgon(mst_dbu_per_ahb_hibp_cmd_rgon),
                                                     // clock and reset
                                                     .clk(clk),
                                                     .bus_clk_en(1'b1),
                                                     .rst_a(~rst_b),
                                                     .sync_rst_r(~rst_b)
                                                     );
    wire [2-1:0] bri_port_id;        // master2 port ID
    wire [4-1:0] bri_aruser_signal;  // master2 user signal, user_iw >= 1
    wire [4-1:0] bri_awuser_signal;  // master2 user signal
    wire [6-1:0]   bri_sb_raddr;       // master2 side-band address (exclude iw)
    wire [6-1:0]   bri_sb_waddr;       // master2 side-band address (exclude iw)
    assign bri_port_id = 2;
    assign bri_aruser_signal = {
                                   {(4-1){1'b0}},
                                   bri_arprot[1]
                                  };
    assign bri_awuser_signal = {
                                   {(4-1){1'b0}},
                                   bri_awprot[1]
                                  };
    assign bri_sb_raddr = {bri_aruser_signal
                             ,bri_port_id
                             };
    assign bri_sb_waddr = {bri_awuser_signal
                             ,bri_port_id
                             };
    alb_mss_fab_axi2ibp #(.FORCE_TO_SINGLE(0),
                          .X_W(32),
                          .Y_W(32),
                          .RGON_W(1),
                          .BYPBUF_DEPTH(16),
                          .BUS_ID_W(4),
                          .CHNL_FIFO_DEPTH(0),
                          .ADDR_W(42),
                          .DATA_W(32)) u_bri_prot_inst(
                                                     // AXI I/F
                                                     //read addr chl
                                                     .axi_arvalid(bri_arvalid),
                                                     .axi_arready(bri_arready),
                                                     .axi_araddr({bri_sb_raddr,bri_arid,bri_araddr}),
                                                     .axi_arcache(bri_arcache),
                                                     .axi_arprot(bri_arprot),
                                                     .axi_arlock(2'd0),
                                                     .axi_arlen(bri_arlen),
                                                     .axi_arburst(bri_arburst),
                                                     .axi_arsize(bri_arsize),
                                                     .axi_arregion(1'd0),
                                                     .axi_arid(bri_arid),
                                                     // read data chl
                                                     .axi_rvalid(bri_rvalid),
                                                     .axi_rready(bri_rready),
                                                     .axi_rdata(bri_rdata),
                                                     .axi_rresp(bri_rresp),
                                                     .axi_rlast(bri_rlast),
                                                     .axi_rid(bri_rid),
                                                     //write addr chl
                                                     .axi_awvalid(bri_awvalid),
                                                     .axi_awready(bri_awready),
                                                     .axi_awaddr({bri_sb_waddr,bri_awid,bri_awaddr}),
                                                     .axi_awcache(bri_awcache),
                                                     .axi_awprot(bri_awprot),
                                                     .axi_awlock(2'd0),
                                                     .axi_awlen(bri_awlen),
                                                     .axi_awburst(bri_awburst),
                                                     .axi_awsize(bri_awsize),
                                                     .axi_awregion(1'd0),
                                                     .axi_awid(bri_awid),
                                                     // write data chl
                                                     .axi_wvalid(bri_wvalid),
                                                     .axi_wready(bri_wready),
                                                     .axi_wdata(bri_wdata),
                                                     .axi_wstrb(bri_wstrb),
                                                     .axi_wlast(bri_wlast),
                                                     //write resp chl
                                                     .axi_bvalid(bri_bvalid),
                                                     .axi_bready(bri_bready),
                                                     .axi_bresp(bri_bresp),
                                                     .axi_bid(bri_bid),
                                                     //IBP I/F

  .ibp_cmd_valid             (mst_bri_ibp_cmd_valid),
  .ibp_cmd_accept            (mst_bri_ibp_cmd_accept),
  .ibp_cmd_read              (mst_bri_ibp_cmd_read),
  .ibp_cmd_addr              (mst_bri_ibp_cmd_addr),
  .ibp_cmd_wrap              (mst_bri_ibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_bri_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_bri_ibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_bri_ibp_cmd_prot),
  .ibp_cmd_cache             (mst_bri_ibp_cmd_cache),
  .ibp_cmd_lock              (mst_bri_ibp_cmd_lock),
  .ibp_cmd_excl              (mst_bri_ibp_cmd_excl),

  .ibp_rd_valid              (mst_bri_ibp_rd_valid),
  .ibp_rd_excl_ok            (mst_bri_ibp_rd_excl_ok),
  .ibp_rd_accept             (mst_bri_ibp_rd_accept),
  .ibp_err_rd                (mst_bri_ibp_err_rd),
  .ibp_rd_data               (mst_bri_ibp_rd_data),
  .ibp_rd_last               (mst_bri_ibp_rd_last),

  .ibp_wr_valid              (mst_bri_ibp_wr_valid),
  .ibp_wr_accept             (mst_bri_ibp_wr_accept),
  .ibp_wr_data               (mst_bri_ibp_wr_data),
  .ibp_wr_mask               (mst_bri_ibp_wr_mask),
  .ibp_wr_last               (mst_bri_ibp_wr_last),

  .ibp_wr_done               (mst_bri_ibp_wr_done),
  .ibp_wr_excl_done          (mst_bri_ibp_wr_excl_done),
  .ibp_err_wr                (mst_bri_ibp_err_wr),
  .ibp_wr_resp_accept        (mst_bri_ibp_wr_resp_accept),
                                                     .ibp_cmd_rgon(mst_bri_ibp_cmd_rgon),
                                                     //clock and resets
                                                     .clk(mss_clk),
                                                     .bus_clk_en(mss_fab_mst2_clk_en),
                                                     .sync_rst_r(~rst_b),
                                                     .rst_a(~rst_b)
                                                     );

    
    




    wire [2-1:0] xtor_axi_port_id;        // master3 port ID
    wire [4-1:0] xtor_axi_aruser_signal;  // master3 user signal, user_iw >= 1
    wire [4-1:0] xtor_axi_awuser_signal;  // master3 user signal
    wire [6-1:0]   xtor_axi_sb_raddr;       // master3 side-band address (exclude iw)
    wire [6-1:0]   xtor_axi_sb_waddr;       // master3 side-band address (exclude iw)
    assign xtor_axi_port_id = 3;
    assign xtor_axi_aruser_signal = {
                                   {(4-1){1'b0}},
                                   xtor_axi_arprot[1]
                                  };
    assign xtor_axi_awuser_signal = {
                                   {(4-1){1'b0}},
                                   xtor_axi_awprot[1]
                                  };
    assign xtor_axi_sb_raddr = {xtor_axi_aruser_signal
                             ,xtor_axi_port_id
                             };
    assign xtor_axi_sb_waddr = {xtor_axi_awuser_signal
                             ,xtor_axi_port_id
                             };
    alb_mss_fab_axi2ibp #(.FORCE_TO_SINGLE(0),
                          .X_W(512),
                          .Y_W(512),
                          .RGON_W(1),
                          .BYPBUF_DEPTH(16),
                          .BUS_ID_W(4),
                          .CHNL_FIFO_DEPTH(0),
                          .ADDR_W(42),
                          .DATA_W(512)) u_xtor_axi_prot_inst(
                                                     // AXI I/F
                                                     //read addr chl
                                                     .axi_arvalid(xtor_axi_arvalid),
                                                     .axi_arready(xtor_axi_arready),
                                                     .axi_araddr({xtor_axi_sb_raddr,xtor_axi_arid,xtor_axi_araddr}),
                                                     .axi_arcache(xtor_axi_arcache),
                                                     .axi_arprot(xtor_axi_arprot),
                                                     .axi_arlock(2'd0),
                                                     .axi_arlen(xtor_axi_arlen),
                                                     .axi_arburst(xtor_axi_arburst),
                                                     .axi_arsize(xtor_axi_arsize),
                                                     .axi_arregion(1'd0),
                                                     .axi_arid(xtor_axi_arid),
                                                     // read data chl
                                                     .axi_rvalid(xtor_axi_rvalid),
                                                     .axi_rready(xtor_axi_rready),
                                                     .axi_rdata(xtor_axi_rdata),
                                                     .axi_rresp(xtor_axi_rresp),
                                                     .axi_rlast(xtor_axi_rlast),
                                                     .axi_rid(xtor_axi_rid),
                                                     //write addr chl
                                                     .axi_awvalid(xtor_axi_awvalid),
                                                     .axi_awready(xtor_axi_awready),
                                                     .axi_awaddr({xtor_axi_sb_waddr,xtor_axi_awid,xtor_axi_awaddr}),
                                                     .axi_awcache(xtor_axi_awcache),
                                                     .axi_awprot(xtor_axi_awprot),
                                                     .axi_awlock(2'd0),
                                                     .axi_awlen(xtor_axi_awlen),
                                                     .axi_awburst(xtor_axi_awburst),
                                                     .axi_awsize(xtor_axi_awsize),
                                                     .axi_awregion(1'd0),
                                                     .axi_awid(xtor_axi_awid),
                                                     // write data chl
                                                     .axi_wvalid(xtor_axi_wvalid),
                                                     .axi_wready(xtor_axi_wready),
                                                     .axi_wdata(xtor_axi_wdata),
                                                     .axi_wstrb(xtor_axi_wstrb),
                                                     .axi_wlast(xtor_axi_wlast),
                                                     //write resp chl
                                                     .axi_bvalid(xtor_axi_bvalid),
                                                     .axi_bready(xtor_axi_bready),
                                                     .axi_bresp(xtor_axi_bresp),
                                                     .axi_bid(xtor_axi_bid),
                                                     //IBP I/F

  .ibp_cmd_valid             (mst_xtor_axi_ibp_cmd_valid),
  .ibp_cmd_accept            (mst_xtor_axi_ibp_cmd_accept),
  .ibp_cmd_read              (mst_xtor_axi_ibp_cmd_read),
  .ibp_cmd_addr              (mst_xtor_axi_ibp_cmd_addr),
  .ibp_cmd_wrap              (mst_xtor_axi_ibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_xtor_axi_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_xtor_axi_ibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_xtor_axi_ibp_cmd_prot),
  .ibp_cmd_cache             (mst_xtor_axi_ibp_cmd_cache),
  .ibp_cmd_lock              (mst_xtor_axi_ibp_cmd_lock),
  .ibp_cmd_excl              (mst_xtor_axi_ibp_cmd_excl),

  .ibp_rd_valid              (mst_xtor_axi_ibp_rd_valid),
  .ibp_rd_excl_ok            (mst_xtor_axi_ibp_rd_excl_ok),
  .ibp_rd_accept             (mst_xtor_axi_ibp_rd_accept),
  .ibp_err_rd                (mst_xtor_axi_ibp_err_rd),
  .ibp_rd_data               (mst_xtor_axi_ibp_rd_data),
  .ibp_rd_last               (mst_xtor_axi_ibp_rd_last),

  .ibp_wr_valid              (mst_xtor_axi_ibp_wr_valid),
  .ibp_wr_accept             (mst_xtor_axi_ibp_wr_accept),
  .ibp_wr_data               (mst_xtor_axi_ibp_wr_data),
  .ibp_wr_mask               (mst_xtor_axi_ibp_wr_mask),
  .ibp_wr_last               (mst_xtor_axi_ibp_wr_last),

  .ibp_wr_done               (mst_xtor_axi_ibp_wr_done),
  .ibp_wr_excl_done          (mst_xtor_axi_ibp_wr_excl_done),
  .ibp_err_wr                (mst_xtor_axi_ibp_err_wr),
  .ibp_wr_resp_accept        (mst_xtor_axi_ibp_wr_resp_accept),
                                                     .ibp_cmd_rgon(mst_xtor_axi_ibp_cmd_rgon),
                                                     //clock and resets
                                                     .clk(mss_clk),
                                                     .bus_clk_en(mss_fab_mst3_clk_en),
                                                     .sync_rst_r(~rst_b),
                                                     .rst_a(~rst_b)
                                                     );

    
    






    // To support flexible clock ratio configuration, there is a clk_domain converting logic here
    // handles from master clock domain to ARCv2MSS fabric clock domain
    // If master port already support clock ratio, the signals are just bypassed to fabric
    // If master port doesn't support clock ratio, invloves two ibp_buffer to do domain conversion


    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_ahb_h_ibp2pack_inst(
                           .ibp_cmd_rgon(mst_ahb_hibp_cmd_rgon),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (mst_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (mst_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (mst_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (mst_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (mst_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (mst_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (mst_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (mst_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (mst_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (mst_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (mst_ahb_hibp_rd_accept),
  .ibp_err_rd                (mst_ahb_hibp_err_rd),
  .ibp_rd_data               (mst_ahb_hibp_rd_data),
  .ibp_rd_last               (mst_ahb_hibp_rd_last),

  .ibp_wr_valid              (mst_ahb_hibp_wr_valid),
  .ibp_wr_accept             (mst_ahb_hibp_wr_accept),
  .ibp_wr_data               (mst_ahb_hibp_wr_data),
  .ibp_wr_mask               (mst_ahb_hibp_wr_mask),
  .ibp_wr_last               (mst_ahb_hibp_wr_last),

  .ibp_wr_done               (mst_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (mst_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (mst_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (mst_ahb_hibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (mst_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (mst_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (mst_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (mst_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (mst_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (mst_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (mst_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (mst_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (mst_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (mst_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(mst_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (mst_ahb_hibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(mst_ahb_hibp_cmd_chnl_rgon),
                           .ibp_cmd_chnl_user(),
                           .clk(clk),
                           .rst_a(~rst_b)
                           );
    // use master's (with prefix ahb_h) clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(1),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_ahb_h_ibp_buffer_0_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(mst_ahb_hibp_cmd_chnl_rgon),



    .i_ibp_cmd_chnl_valid  (mst_ahb_hibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (mst_ahb_hibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (mst_ahb_hibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (mst_ahb_hibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (mst_ahb_hibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (mst_ahb_hibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (mst_ahb_hibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (mst_ahb_hibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (mst_ahb_hibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (mst_ahb_hibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(mst_ahb_hibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (mst_ahb_hibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(mst_o_ahb_hibp_cmd_chnl_rgon),



    .o_ibp_cmd_chnl_valid  (mst_o_ahb_hibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (mst_o_ahb_hibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (mst_o_ahb_hibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (mst_o_ahb_hibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (mst_o_ahb_hibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (mst_o_ahb_hibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (mst_o_ahb_hibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (mst_o_ahb_hibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (mst_o_ahb_hibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (mst_o_ahb_hibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(mst_o_ahb_hibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (mst_o_ahb_hibp_wrsp_chnl),

                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),
                             .ibp_buffer_idle(),
                             .clk(clk),
                             .rst_a(~rst_b)
                             );

    // use fabric's clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(1),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_ahb_h_ibp_buffer_1_inst (
                             .i_ibp_clk_en(mss_fab_mst0_clk_en),
                             .i_ibp_cmd_chnl_rgon(mst_o_ahb_hibp_cmd_chnl_rgon),



    .i_ibp_cmd_chnl_valid  (mst_o_ahb_hibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (mst_o_ahb_hibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (mst_o_ahb_hibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (mst_o_ahb_hibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (mst_o_ahb_hibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (mst_o_ahb_hibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (mst_o_ahb_hibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (mst_o_ahb_hibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (mst_o_ahb_hibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (mst_o_ahb_hibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(mst_o_ahb_hibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (mst_o_ahb_hibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(lat_i_ahb_hibp_cmd_chnl_rgon),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (lat_i_ahb_hibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (lat_i_ahb_hibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (lat_i_ahb_hibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (lat_i_ahb_hibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (lat_i_ahb_hibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (lat_i_ahb_hibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (lat_i_ahb_hibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (lat_i_ahb_hibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (lat_i_ahb_hibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (lat_i_ahb_hibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(lat_i_ahb_hibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (lat_i_ahb_hibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );
    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_ahb_h_pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(lat_i_ahb_hibp_cmd_chnl_rgon),



    .ibp_cmd_chnl_valid  (lat_i_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (lat_i_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (lat_i_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (lat_i_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (lat_i_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (lat_i_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (lat_i_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (lat_i_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (lat_i_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (lat_i_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(lat_i_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (lat_i_ahb_hibp_wrsp_chnl),


  .ibp_cmd_valid             (lat_i_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (lat_i_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (lat_i_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (lat_i_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (lat_i_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (lat_i_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (lat_i_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (lat_i_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (lat_i_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (lat_i_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (lat_i_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (lat_i_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (lat_i_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (lat_i_ahb_hibp_rd_accept),
  .ibp_err_rd                (lat_i_ahb_hibp_err_rd),
  .ibp_rd_data               (lat_i_ahb_hibp_rd_data),
  .ibp_rd_last               (lat_i_ahb_hibp_rd_last),

  .ibp_wr_valid              (lat_i_ahb_hibp_wr_valid),
  .ibp_wr_accept             (lat_i_ahb_hibp_wr_accept),
  .ibp_wr_data               (lat_i_ahb_hibp_wr_data),
  .ibp_wr_mask               (lat_i_ahb_hibp_wr_mask),
  .ibp_wr_last               (lat_i_ahb_hibp_wr_last),

  .ibp_wr_done               (lat_i_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (lat_i_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (lat_i_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (lat_i_ahb_hibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon()
                           );

    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dbu_per_ahb_h_ibp2pack_inst(
                           .ibp_cmd_rgon(mst_dbu_per_ahb_hibp_cmd_rgon),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (mst_dbu_per_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (mst_dbu_per_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (mst_dbu_per_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (mst_dbu_per_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (mst_dbu_per_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_dbu_per_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_dbu_per_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_dbu_per_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (mst_dbu_per_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (mst_dbu_per_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (mst_dbu_per_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (mst_dbu_per_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (mst_dbu_per_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (mst_dbu_per_ahb_hibp_rd_accept),
  .ibp_err_rd                (mst_dbu_per_ahb_hibp_err_rd),
  .ibp_rd_data               (mst_dbu_per_ahb_hibp_rd_data),
  .ibp_rd_last               (mst_dbu_per_ahb_hibp_rd_last),

  .ibp_wr_valid              (mst_dbu_per_ahb_hibp_wr_valid),
  .ibp_wr_accept             (mst_dbu_per_ahb_hibp_wr_accept),
  .ibp_wr_data               (mst_dbu_per_ahb_hibp_wr_data),
  .ibp_wr_mask               (mst_dbu_per_ahb_hibp_wr_mask),
  .ibp_wr_last               (mst_dbu_per_ahb_hibp_wr_last),

  .ibp_wr_done               (mst_dbu_per_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (mst_dbu_per_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (mst_dbu_per_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (mst_dbu_per_ahb_hibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (mst_dbu_per_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (mst_dbu_per_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (mst_dbu_per_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (mst_dbu_per_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (mst_dbu_per_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (mst_dbu_per_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (mst_dbu_per_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (mst_dbu_per_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (mst_dbu_per_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (mst_dbu_per_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(mst_dbu_per_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (mst_dbu_per_ahb_hibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(mst_dbu_per_ahb_hibp_cmd_chnl_rgon),
                           .ibp_cmd_chnl_user(),
                           .clk(clk),
                           .rst_a(~rst_b)
                           );
    // use master's (with prefix dbu_per_ahb_h) clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(1),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_dbu_per_ahb_h_ibp_buffer_0_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(mst_dbu_per_ahb_hibp_cmd_chnl_rgon),



    .i_ibp_cmd_chnl_valid  (mst_dbu_per_ahb_hibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (mst_dbu_per_ahb_hibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (mst_dbu_per_ahb_hibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (mst_dbu_per_ahb_hibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (mst_dbu_per_ahb_hibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (mst_dbu_per_ahb_hibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (mst_dbu_per_ahb_hibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (mst_dbu_per_ahb_hibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (mst_dbu_per_ahb_hibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (mst_dbu_per_ahb_hibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(mst_dbu_per_ahb_hibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (mst_dbu_per_ahb_hibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(mst_o_dbu_per_ahb_hibp_cmd_chnl_rgon),



    .o_ibp_cmd_chnl_valid  (mst_o_dbu_per_ahb_hibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (mst_o_dbu_per_ahb_hibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (mst_o_dbu_per_ahb_hibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (mst_o_dbu_per_ahb_hibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (mst_o_dbu_per_ahb_hibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (mst_o_dbu_per_ahb_hibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (mst_o_dbu_per_ahb_hibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (mst_o_dbu_per_ahb_hibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (mst_o_dbu_per_ahb_hibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (mst_o_dbu_per_ahb_hibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(mst_o_dbu_per_ahb_hibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (mst_o_dbu_per_ahb_hibp_wrsp_chnl),

                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),
                             .ibp_buffer_idle(),
                             .clk(clk),
                             .rst_a(~rst_b)
                             );

    // use fabric's clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(1),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_dbu_per_ahb_h_ibp_buffer_1_inst (
                             .i_ibp_clk_en(mss_fab_mst1_clk_en),
                             .i_ibp_cmd_chnl_rgon(mst_o_dbu_per_ahb_hibp_cmd_chnl_rgon),



    .i_ibp_cmd_chnl_valid  (mst_o_dbu_per_ahb_hibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (mst_o_dbu_per_ahb_hibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (mst_o_dbu_per_ahb_hibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (mst_o_dbu_per_ahb_hibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (mst_o_dbu_per_ahb_hibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (mst_o_dbu_per_ahb_hibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (mst_o_dbu_per_ahb_hibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (mst_o_dbu_per_ahb_hibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (mst_o_dbu_per_ahb_hibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (mst_o_dbu_per_ahb_hibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(mst_o_dbu_per_ahb_hibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (mst_o_dbu_per_ahb_hibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(lat_i_dbu_per_ahb_hibp_cmd_chnl_rgon),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (lat_i_dbu_per_ahb_hibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (lat_i_dbu_per_ahb_hibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (lat_i_dbu_per_ahb_hibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (lat_i_dbu_per_ahb_hibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (lat_i_dbu_per_ahb_hibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (lat_i_dbu_per_ahb_hibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (lat_i_dbu_per_ahb_hibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (lat_i_dbu_per_ahb_hibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (lat_i_dbu_per_ahb_hibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (lat_i_dbu_per_ahb_hibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(lat_i_dbu_per_ahb_hibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (lat_i_dbu_per_ahb_hibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );
    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dbu_per_ahb_h_pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(lat_i_dbu_per_ahb_hibp_cmd_chnl_rgon),



    .ibp_cmd_chnl_valid  (lat_i_dbu_per_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (lat_i_dbu_per_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (lat_i_dbu_per_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (lat_i_dbu_per_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (lat_i_dbu_per_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (lat_i_dbu_per_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (lat_i_dbu_per_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (lat_i_dbu_per_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (lat_i_dbu_per_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (lat_i_dbu_per_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(lat_i_dbu_per_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (lat_i_dbu_per_ahb_hibp_wrsp_chnl),


  .ibp_cmd_valid             (lat_i_dbu_per_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (lat_i_dbu_per_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (lat_i_dbu_per_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (lat_i_dbu_per_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (lat_i_dbu_per_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (lat_i_dbu_per_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (lat_i_dbu_per_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (lat_i_dbu_per_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (lat_i_dbu_per_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (lat_i_dbu_per_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (lat_i_dbu_per_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (lat_i_dbu_per_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (lat_i_dbu_per_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (lat_i_dbu_per_ahb_hibp_rd_accept),
  .ibp_err_rd                (lat_i_dbu_per_ahb_hibp_err_rd),
  .ibp_rd_data               (lat_i_dbu_per_ahb_hibp_rd_data),
  .ibp_rd_last               (lat_i_dbu_per_ahb_hibp_rd_last),

  .ibp_wr_valid              (lat_i_dbu_per_ahb_hibp_wr_valid),
  .ibp_wr_accept             (lat_i_dbu_per_ahb_hibp_wr_accept),
  .ibp_wr_data               (lat_i_dbu_per_ahb_hibp_wr_data),
  .ibp_wr_mask               (lat_i_dbu_per_ahb_hibp_wr_mask),
  .ibp_wr_last               (lat_i_dbu_per_ahb_hibp_wr_last),

  .ibp_wr_done               (lat_i_dbu_per_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (lat_i_dbu_per_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (lat_i_dbu_per_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (lat_i_dbu_per_ahb_hibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon()
                           );

    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_bri__ibp2pack_inst(
                           .ibp_cmd_rgon(mst_bri_ibp_cmd_rgon),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (mst_bri_ibp_cmd_valid),
  .ibp_cmd_accept            (mst_bri_ibp_cmd_accept),
  .ibp_cmd_read              (mst_bri_ibp_cmd_read),
  .ibp_cmd_addr              (mst_bri_ibp_cmd_addr),
  .ibp_cmd_wrap              (mst_bri_ibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_bri_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_bri_ibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_bri_ibp_cmd_prot),
  .ibp_cmd_cache             (mst_bri_ibp_cmd_cache),
  .ibp_cmd_lock              (mst_bri_ibp_cmd_lock),
  .ibp_cmd_excl              (mst_bri_ibp_cmd_excl),

  .ibp_rd_valid              (mst_bri_ibp_rd_valid),
  .ibp_rd_excl_ok            (mst_bri_ibp_rd_excl_ok),
  .ibp_rd_accept             (mst_bri_ibp_rd_accept),
  .ibp_err_rd                (mst_bri_ibp_err_rd),
  .ibp_rd_data               (mst_bri_ibp_rd_data),
  .ibp_rd_last               (mst_bri_ibp_rd_last),

  .ibp_wr_valid              (mst_bri_ibp_wr_valid),
  .ibp_wr_accept             (mst_bri_ibp_wr_accept),
  .ibp_wr_data               (mst_bri_ibp_wr_data),
  .ibp_wr_mask               (mst_bri_ibp_wr_mask),
  .ibp_wr_last               (mst_bri_ibp_wr_last),

  .ibp_wr_done               (mst_bri_ibp_wr_done),
  .ibp_wr_excl_done          (mst_bri_ibp_wr_excl_done),
  .ibp_err_wr                (mst_bri_ibp_err_wr),
  .ibp_wr_resp_accept        (mst_bri_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (mst_bri_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (mst_bri_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (mst_bri_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (mst_bri_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (mst_bri_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (mst_bri_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (mst_bri_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (mst_bri_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (mst_bri_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (mst_bri_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(mst_bri_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (mst_bri_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(mst_bri_ibp_cmd_chnl_rgon),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // bypass signals from master port to latency units
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_bri__ibp_buffer_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(mst_bri_ibp_cmd_chnl_rgon),



    .i_ibp_cmd_chnl_valid  (mst_bri_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (mst_bri_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (mst_bri_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (mst_bri_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (mst_bri_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (mst_bri_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (mst_bri_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (mst_bri_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (mst_bri_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (mst_bri_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(mst_bri_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (mst_bri_ibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(lat_i_bri_ibp_cmd_chnl_rgon),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (lat_i_bri_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (lat_i_bri_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (lat_i_bri_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (lat_i_bri_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (lat_i_bri_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (lat_i_bri_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (lat_i_bri_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (lat_i_bri_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (lat_i_bri_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (lat_i_bri_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(lat_i_bri_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (lat_i_bri_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_bri__pack2ibp_inst(



    .ibp_cmd_chnl_valid  (lat_i_bri_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (lat_i_bri_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (lat_i_bri_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (lat_i_bri_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (lat_i_bri_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (lat_i_bri_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (lat_i_bri_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (lat_i_bri_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (lat_i_bri_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (lat_i_bri_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(lat_i_bri_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (lat_i_bri_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(lat_i_bri_ibp_cmd_chnl_rgon),

  .ibp_cmd_valid             (lat_i_bri_ibp_cmd_valid),
  .ibp_cmd_accept            (lat_i_bri_ibp_cmd_accept),
  .ibp_cmd_read              (lat_i_bri_ibp_cmd_read),
  .ibp_cmd_addr              (lat_i_bri_ibp_cmd_addr),
  .ibp_cmd_wrap              (lat_i_bri_ibp_cmd_wrap),
  .ibp_cmd_data_size         (lat_i_bri_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (lat_i_bri_ibp_cmd_burst_size),
  .ibp_cmd_prot              (lat_i_bri_ibp_cmd_prot),
  .ibp_cmd_cache             (lat_i_bri_ibp_cmd_cache),
  .ibp_cmd_lock              (lat_i_bri_ibp_cmd_lock),
  .ibp_cmd_excl              (lat_i_bri_ibp_cmd_excl),

  .ibp_rd_valid              (lat_i_bri_ibp_rd_valid),
  .ibp_rd_excl_ok            (lat_i_bri_ibp_rd_excl_ok),
  .ibp_rd_accept             (lat_i_bri_ibp_rd_accept),
  .ibp_err_rd                (lat_i_bri_ibp_err_rd),
  .ibp_rd_data               (lat_i_bri_ibp_rd_data),
  .ibp_rd_last               (lat_i_bri_ibp_rd_last),

  .ibp_wr_valid              (lat_i_bri_ibp_wr_valid),
  .ibp_wr_accept             (lat_i_bri_ibp_wr_accept),
  .ibp_wr_data               (lat_i_bri_ibp_wr_data),
  .ibp_wr_mask               (lat_i_bri_ibp_wr_mask),
  .ibp_wr_last               (lat_i_bri_ibp_wr_last),

  .ibp_wr_done               (lat_i_bri_ibp_wr_done),
  .ibp_wr_excl_done          (lat_i_bri_ibp_wr_excl_done),
  .ibp_err_wr                (lat_i_bri_ibp_err_wr),
  .ibp_wr_resp_accept        (lat_i_bri_ibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon()
                           );

    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(512),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (512),
    .WD_CHNL_MASK_LSB        (513),
    .WD_CHNL_MASK_W          (64),
    .WD_CHNL_W               (577),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (512),
    .RD_CHNL_W               (515),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_xtor_axi__ibp2pack_inst(
                           .ibp_cmd_rgon(mst_xtor_axi_ibp_cmd_rgon),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (mst_xtor_axi_ibp_cmd_valid),
  .ibp_cmd_accept            (mst_xtor_axi_ibp_cmd_accept),
  .ibp_cmd_read              (mst_xtor_axi_ibp_cmd_read),
  .ibp_cmd_addr              (mst_xtor_axi_ibp_cmd_addr),
  .ibp_cmd_wrap              (mst_xtor_axi_ibp_cmd_wrap),
  .ibp_cmd_data_size         (mst_xtor_axi_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (mst_xtor_axi_ibp_cmd_burst_size),
  .ibp_cmd_prot              (mst_xtor_axi_ibp_cmd_prot),
  .ibp_cmd_cache             (mst_xtor_axi_ibp_cmd_cache),
  .ibp_cmd_lock              (mst_xtor_axi_ibp_cmd_lock),
  .ibp_cmd_excl              (mst_xtor_axi_ibp_cmd_excl),

  .ibp_rd_valid              (mst_xtor_axi_ibp_rd_valid),
  .ibp_rd_excl_ok            (mst_xtor_axi_ibp_rd_excl_ok),
  .ibp_rd_accept             (mst_xtor_axi_ibp_rd_accept),
  .ibp_err_rd                (mst_xtor_axi_ibp_err_rd),
  .ibp_rd_data               (mst_xtor_axi_ibp_rd_data),
  .ibp_rd_last               (mst_xtor_axi_ibp_rd_last),

  .ibp_wr_valid              (mst_xtor_axi_ibp_wr_valid),
  .ibp_wr_accept             (mst_xtor_axi_ibp_wr_accept),
  .ibp_wr_data               (mst_xtor_axi_ibp_wr_data),
  .ibp_wr_mask               (mst_xtor_axi_ibp_wr_mask),
  .ibp_wr_last               (mst_xtor_axi_ibp_wr_last),

  .ibp_wr_done               (mst_xtor_axi_ibp_wr_done),
  .ibp_wr_excl_done          (mst_xtor_axi_ibp_wr_excl_done),
  .ibp_err_wr                (mst_xtor_axi_ibp_err_wr),
  .ibp_wr_resp_accept        (mst_xtor_axi_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (mst_xtor_axi_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (mst_xtor_axi_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (mst_xtor_axi_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (mst_xtor_axi_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (mst_xtor_axi_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (mst_xtor_axi_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (mst_xtor_axi_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (mst_xtor_axi_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (mst_xtor_axi_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (mst_xtor_axi_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(mst_xtor_axi_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (mst_xtor_axi_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(mst_xtor_axi_ibp_cmd_chnl_rgon),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // bypass signals from master port to latency units
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (512),
    .WD_CHNL_MASK_LSB        (513),
    .WD_CHNL_MASK_W          (64),
    .WD_CHNL_W               (577),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (512),
    .RD_CHNL_W               (515),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_xtor_axi__ibp_buffer_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(mst_xtor_axi_ibp_cmd_chnl_rgon),



    .i_ibp_cmd_chnl_valid  (mst_xtor_axi_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (mst_xtor_axi_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (mst_xtor_axi_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (mst_xtor_axi_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (mst_xtor_axi_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (mst_xtor_axi_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (mst_xtor_axi_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (mst_xtor_axi_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (mst_xtor_axi_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (mst_xtor_axi_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(mst_xtor_axi_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (mst_xtor_axi_ibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(lat_i_xtor_axi_ibp_cmd_chnl_rgon),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (lat_i_xtor_axi_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (lat_i_xtor_axi_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (lat_i_xtor_axi_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (lat_i_xtor_axi_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (lat_i_xtor_axi_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (lat_i_xtor_axi_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (lat_i_xtor_axi_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (lat_i_xtor_axi_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (lat_i_xtor_axi_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (lat_i_xtor_axi_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(lat_i_xtor_axi_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (lat_i_xtor_axi_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(512),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (512),
    .WD_CHNL_MASK_LSB        (513),
    .WD_CHNL_MASK_W          (64),
    .WD_CHNL_W               (577),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (512),
    .RD_CHNL_W               (515),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_xtor_axi__pack2ibp_inst(



    .ibp_cmd_chnl_valid  (lat_i_xtor_axi_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (lat_i_xtor_axi_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (lat_i_xtor_axi_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (lat_i_xtor_axi_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (lat_i_xtor_axi_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (lat_i_xtor_axi_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (lat_i_xtor_axi_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (lat_i_xtor_axi_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (lat_i_xtor_axi_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (lat_i_xtor_axi_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(lat_i_xtor_axi_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (lat_i_xtor_axi_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(lat_i_xtor_axi_ibp_cmd_chnl_rgon),

  .ibp_cmd_valid             (lat_i_xtor_axi_ibp_cmd_valid),
  .ibp_cmd_accept            (lat_i_xtor_axi_ibp_cmd_accept),
  .ibp_cmd_read              (lat_i_xtor_axi_ibp_cmd_read),
  .ibp_cmd_addr              (lat_i_xtor_axi_ibp_cmd_addr),
  .ibp_cmd_wrap              (lat_i_xtor_axi_ibp_cmd_wrap),
  .ibp_cmd_data_size         (lat_i_xtor_axi_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (lat_i_xtor_axi_ibp_cmd_burst_size),
  .ibp_cmd_prot              (lat_i_xtor_axi_ibp_cmd_prot),
  .ibp_cmd_cache             (lat_i_xtor_axi_ibp_cmd_cache),
  .ibp_cmd_lock              (lat_i_xtor_axi_ibp_cmd_lock),
  .ibp_cmd_excl              (lat_i_xtor_axi_ibp_cmd_excl),

  .ibp_rd_valid              (lat_i_xtor_axi_ibp_rd_valid),
  .ibp_rd_excl_ok            (lat_i_xtor_axi_ibp_rd_excl_ok),
  .ibp_rd_accept             (lat_i_xtor_axi_ibp_rd_accept),
  .ibp_err_rd                (lat_i_xtor_axi_ibp_err_rd),
  .ibp_rd_data               (lat_i_xtor_axi_ibp_rd_data),
  .ibp_rd_last               (lat_i_xtor_axi_ibp_rd_last),

  .ibp_wr_valid              (lat_i_xtor_axi_ibp_wr_valid),
  .ibp_wr_accept             (lat_i_xtor_axi_ibp_wr_accept),
  .ibp_wr_data               (lat_i_xtor_axi_ibp_wr_data),
  .ibp_wr_mask               (lat_i_xtor_axi_ibp_wr_mask),
  .ibp_wr_last               (lat_i_xtor_axi_ibp_wr_last),

  .ibp_wr_done               (lat_i_xtor_axi_ibp_wr_done),
  .ibp_wr_excl_done          (lat_i_xtor_axi_ibp_wr_excl_done),
  .ibp_err_wr                (lat_i_xtor_axi_ibp_err_wr),
  .ibp_wr_resp_accept        (lat_i_xtor_axi_ibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon()
                           );


    // Latency units
    alb_mss_fab_ibp_lat #(.a_w(42),
                          .d_w(32),
                          .depl2(0)
                          ) u_ahb_hibp_lat_inst(
                                                     // clock and reset
                                                     .clk(mss_clk),
                                                     .clk_en(1'b1),
                                                     .rst_b(rst_b),
                                                      // Input IBP I/F

  .i_ibp_cmd_valid             (lat_i_ahb_hibp_cmd_valid),
  .i_ibp_cmd_accept            (lat_i_ahb_hibp_cmd_accept),
  .i_ibp_cmd_read              (lat_i_ahb_hibp_cmd_read),
  .i_ibp_cmd_addr              (lat_i_ahb_hibp_cmd_addr),
  .i_ibp_cmd_wrap              (lat_i_ahb_hibp_cmd_wrap),
  .i_ibp_cmd_data_size         (lat_i_ahb_hibp_cmd_data_size),
  .i_ibp_cmd_burst_size        (lat_i_ahb_hibp_cmd_burst_size),
  .i_ibp_cmd_prot              (lat_i_ahb_hibp_cmd_prot),
  .i_ibp_cmd_cache             (lat_i_ahb_hibp_cmd_cache),
  .i_ibp_cmd_lock              (lat_i_ahb_hibp_cmd_lock),
  .i_ibp_cmd_excl              (lat_i_ahb_hibp_cmd_excl),

  .i_ibp_rd_valid              (lat_i_ahb_hibp_rd_valid),
  .i_ibp_rd_excl_ok            (lat_i_ahb_hibp_rd_excl_ok),
  .i_ibp_rd_accept             (lat_i_ahb_hibp_rd_accept),
  .i_ibp_err_rd                (lat_i_ahb_hibp_err_rd),
  .i_ibp_rd_data               (lat_i_ahb_hibp_rd_data),
  .i_ibp_rd_last               (lat_i_ahb_hibp_rd_last),

  .i_ibp_wr_valid              (lat_i_ahb_hibp_wr_valid),
  .i_ibp_wr_accept             (lat_i_ahb_hibp_wr_accept),
  .i_ibp_wr_data               (lat_i_ahb_hibp_wr_data),
  .i_ibp_wr_mask               (lat_i_ahb_hibp_wr_mask),
  .i_ibp_wr_last               (lat_i_ahb_hibp_wr_last),

  .i_ibp_wr_done               (lat_i_ahb_hibp_wr_done),
  .i_ibp_wr_excl_done          (lat_i_ahb_hibp_wr_excl_done),
  .i_ibp_err_wr                (lat_i_ahb_hibp_err_wr),
  .i_ibp_wr_resp_accept        (lat_i_ahb_hibp_wr_resp_accept),
                                                     // Output IBP I/F

  .o_ibp_cmd_valid             (lat_o_ahb_hibp_cmd_valid),
  .o_ibp_cmd_accept            (lat_o_ahb_hibp_cmd_accept),
  .o_ibp_cmd_read              (lat_o_ahb_hibp_cmd_read),
  .o_ibp_cmd_addr              (lat_o_ahb_hibp_cmd_addr),
  .o_ibp_cmd_wrap              (lat_o_ahb_hibp_cmd_wrap),
  .o_ibp_cmd_data_size         (lat_o_ahb_hibp_cmd_data_size),
  .o_ibp_cmd_burst_size        (lat_o_ahb_hibp_cmd_burst_size),
  .o_ibp_cmd_prot              (lat_o_ahb_hibp_cmd_prot),
  .o_ibp_cmd_cache             (lat_o_ahb_hibp_cmd_cache),
  .o_ibp_cmd_lock              (lat_o_ahb_hibp_cmd_lock),
  .o_ibp_cmd_excl              (lat_o_ahb_hibp_cmd_excl),

  .o_ibp_rd_valid              (lat_o_ahb_hibp_rd_valid),
  .o_ibp_rd_excl_ok            (lat_o_ahb_hibp_rd_excl_ok),
  .o_ibp_rd_accept             (lat_o_ahb_hibp_rd_accept),
  .o_ibp_err_rd                (lat_o_ahb_hibp_err_rd),
  .o_ibp_rd_data               (lat_o_ahb_hibp_rd_data),
  .o_ibp_rd_last               (lat_o_ahb_hibp_rd_last),

  .o_ibp_wr_valid              (lat_o_ahb_hibp_wr_valid),
  .o_ibp_wr_accept             (lat_o_ahb_hibp_wr_accept),
  .o_ibp_wr_data               (lat_o_ahb_hibp_wr_data),
  .o_ibp_wr_mask               (lat_o_ahb_hibp_wr_mask),
  .o_ibp_wr_last               (lat_o_ahb_hibp_wr_last),

  .o_ibp_wr_done               (lat_o_ahb_hibp_wr_done),
  .o_ibp_wr_excl_done          (lat_o_ahb_hibp_wr_excl_done),
  .o_ibp_err_wr                (lat_o_ahb_hibp_err_wr),
  .o_ibp_wr_resp_accept        (lat_o_ahb_hibp_wr_resp_accept),
                                                      // Profiler I/F
                                                     .cfg_lat_w(mss_fab_cfg_lat_w[0*12+:12]),
                                                     .cfg_lat_r(mss_fab_cfg_lat_r[0*12+:12]),
                                                     .cfg_wr_bw(mss_fab_cfg_wr_bw[0*10+:10]),
                                                     .cfg_rd_bw(mss_fab_cfg_rd_bw[0*10+:10]),
                                                     .perf_awf(mss_fab_perf_awf[0]),
                                                     .perf_arf(mss_fab_perf_arf[0]),
                                                     .perf_aw(mss_fab_perf_aw[0]),
                                                     .perf_ar(mss_fab_perf_ar[0]),
                                                     .perf_w(mss_fab_perf_w[0]),
                                                     .perf_wl(mss_fab_perf_wl[0]),
                                                     .perf_r(mss_fab_perf_r[0]),
                                                     .perf_rl(mss_fab_perf_rl[0]),
                                                     .perf_b(mss_fab_perf_b[0]));
    alb_mss_fab_ibp_lat #(.a_w(42),
                          .d_w(32),
                          .depl2(0)
                          ) u_dbu_per_ahb_hibp_lat_inst(
                                                     // clock and reset
                                                     .clk(mss_clk),
                                                     .clk_en(1'b1),
                                                     .rst_b(rst_b),
                                                      // Input IBP I/F

  .i_ibp_cmd_valid             (lat_i_dbu_per_ahb_hibp_cmd_valid),
  .i_ibp_cmd_accept            (lat_i_dbu_per_ahb_hibp_cmd_accept),
  .i_ibp_cmd_read              (lat_i_dbu_per_ahb_hibp_cmd_read),
  .i_ibp_cmd_addr              (lat_i_dbu_per_ahb_hibp_cmd_addr),
  .i_ibp_cmd_wrap              (lat_i_dbu_per_ahb_hibp_cmd_wrap),
  .i_ibp_cmd_data_size         (lat_i_dbu_per_ahb_hibp_cmd_data_size),
  .i_ibp_cmd_burst_size        (lat_i_dbu_per_ahb_hibp_cmd_burst_size),
  .i_ibp_cmd_prot              (lat_i_dbu_per_ahb_hibp_cmd_prot),
  .i_ibp_cmd_cache             (lat_i_dbu_per_ahb_hibp_cmd_cache),
  .i_ibp_cmd_lock              (lat_i_dbu_per_ahb_hibp_cmd_lock),
  .i_ibp_cmd_excl              (lat_i_dbu_per_ahb_hibp_cmd_excl),

  .i_ibp_rd_valid              (lat_i_dbu_per_ahb_hibp_rd_valid),
  .i_ibp_rd_excl_ok            (lat_i_dbu_per_ahb_hibp_rd_excl_ok),
  .i_ibp_rd_accept             (lat_i_dbu_per_ahb_hibp_rd_accept),
  .i_ibp_err_rd                (lat_i_dbu_per_ahb_hibp_err_rd),
  .i_ibp_rd_data               (lat_i_dbu_per_ahb_hibp_rd_data),
  .i_ibp_rd_last               (lat_i_dbu_per_ahb_hibp_rd_last),

  .i_ibp_wr_valid              (lat_i_dbu_per_ahb_hibp_wr_valid),
  .i_ibp_wr_accept             (lat_i_dbu_per_ahb_hibp_wr_accept),
  .i_ibp_wr_data               (lat_i_dbu_per_ahb_hibp_wr_data),
  .i_ibp_wr_mask               (lat_i_dbu_per_ahb_hibp_wr_mask),
  .i_ibp_wr_last               (lat_i_dbu_per_ahb_hibp_wr_last),

  .i_ibp_wr_done               (lat_i_dbu_per_ahb_hibp_wr_done),
  .i_ibp_wr_excl_done          (lat_i_dbu_per_ahb_hibp_wr_excl_done),
  .i_ibp_err_wr                (lat_i_dbu_per_ahb_hibp_err_wr),
  .i_ibp_wr_resp_accept        (lat_i_dbu_per_ahb_hibp_wr_resp_accept),
                                                     // Output IBP I/F

  .o_ibp_cmd_valid             (lat_o_dbu_per_ahb_hibp_cmd_valid),
  .o_ibp_cmd_accept            (lat_o_dbu_per_ahb_hibp_cmd_accept),
  .o_ibp_cmd_read              (lat_o_dbu_per_ahb_hibp_cmd_read),
  .o_ibp_cmd_addr              (lat_o_dbu_per_ahb_hibp_cmd_addr),
  .o_ibp_cmd_wrap              (lat_o_dbu_per_ahb_hibp_cmd_wrap),
  .o_ibp_cmd_data_size         (lat_o_dbu_per_ahb_hibp_cmd_data_size),
  .o_ibp_cmd_burst_size        (lat_o_dbu_per_ahb_hibp_cmd_burst_size),
  .o_ibp_cmd_prot              (lat_o_dbu_per_ahb_hibp_cmd_prot),
  .o_ibp_cmd_cache             (lat_o_dbu_per_ahb_hibp_cmd_cache),
  .o_ibp_cmd_lock              (lat_o_dbu_per_ahb_hibp_cmd_lock),
  .o_ibp_cmd_excl              (lat_o_dbu_per_ahb_hibp_cmd_excl),

  .o_ibp_rd_valid              (lat_o_dbu_per_ahb_hibp_rd_valid),
  .o_ibp_rd_excl_ok            (lat_o_dbu_per_ahb_hibp_rd_excl_ok),
  .o_ibp_rd_accept             (lat_o_dbu_per_ahb_hibp_rd_accept),
  .o_ibp_err_rd                (lat_o_dbu_per_ahb_hibp_err_rd),
  .o_ibp_rd_data               (lat_o_dbu_per_ahb_hibp_rd_data),
  .o_ibp_rd_last               (lat_o_dbu_per_ahb_hibp_rd_last),

  .o_ibp_wr_valid              (lat_o_dbu_per_ahb_hibp_wr_valid),
  .o_ibp_wr_accept             (lat_o_dbu_per_ahb_hibp_wr_accept),
  .o_ibp_wr_data               (lat_o_dbu_per_ahb_hibp_wr_data),
  .o_ibp_wr_mask               (lat_o_dbu_per_ahb_hibp_wr_mask),
  .o_ibp_wr_last               (lat_o_dbu_per_ahb_hibp_wr_last),

  .o_ibp_wr_done               (lat_o_dbu_per_ahb_hibp_wr_done),
  .o_ibp_wr_excl_done          (lat_o_dbu_per_ahb_hibp_wr_excl_done),
  .o_ibp_err_wr                (lat_o_dbu_per_ahb_hibp_err_wr),
  .o_ibp_wr_resp_accept        (lat_o_dbu_per_ahb_hibp_wr_resp_accept),
                                                      // Profiler I/F
                                                     .cfg_lat_w(mss_fab_cfg_lat_w[1*12+:12]),
                                                     .cfg_lat_r(mss_fab_cfg_lat_r[1*12+:12]),
                                                     .cfg_wr_bw(mss_fab_cfg_wr_bw[1*10+:10]),
                                                     .cfg_rd_bw(mss_fab_cfg_rd_bw[1*10+:10]),
                                                     .perf_awf(mss_fab_perf_awf[1]),
                                                     .perf_arf(mss_fab_perf_arf[1]),
                                                     .perf_aw(mss_fab_perf_aw[1]),
                                                     .perf_ar(mss_fab_perf_ar[1]),
                                                     .perf_w(mss_fab_perf_w[1]),
                                                     .perf_wl(mss_fab_perf_wl[1]),
                                                     .perf_r(mss_fab_perf_r[1]),
                                                     .perf_rl(mss_fab_perf_rl[1]),
                                                     .perf_b(mss_fab_perf_b[1]));
    alb_mss_fab_ibp_lat #(.a_w(42),
                          .d_w(32),
                          .depl2(0)
                          ) u_bri_ibp_lat_inst(
                                                     // clock and reset
                                                     .clk(mss_clk),
                                                     .clk_en(1'b1),
                                                     .rst_b(rst_b),
                                                      // Input IBP I/F

  .i_ibp_cmd_valid             (lat_i_bri_ibp_cmd_valid),
  .i_ibp_cmd_accept            (lat_i_bri_ibp_cmd_accept),
  .i_ibp_cmd_read              (lat_i_bri_ibp_cmd_read),
  .i_ibp_cmd_addr              (lat_i_bri_ibp_cmd_addr),
  .i_ibp_cmd_wrap              (lat_i_bri_ibp_cmd_wrap),
  .i_ibp_cmd_data_size         (lat_i_bri_ibp_cmd_data_size),
  .i_ibp_cmd_burst_size        (lat_i_bri_ibp_cmd_burst_size),
  .i_ibp_cmd_prot              (lat_i_bri_ibp_cmd_prot),
  .i_ibp_cmd_cache             (lat_i_bri_ibp_cmd_cache),
  .i_ibp_cmd_lock              (lat_i_bri_ibp_cmd_lock),
  .i_ibp_cmd_excl              (lat_i_bri_ibp_cmd_excl),

  .i_ibp_rd_valid              (lat_i_bri_ibp_rd_valid),
  .i_ibp_rd_excl_ok            (lat_i_bri_ibp_rd_excl_ok),
  .i_ibp_rd_accept             (lat_i_bri_ibp_rd_accept),
  .i_ibp_err_rd                (lat_i_bri_ibp_err_rd),
  .i_ibp_rd_data               (lat_i_bri_ibp_rd_data),
  .i_ibp_rd_last               (lat_i_bri_ibp_rd_last),

  .i_ibp_wr_valid              (lat_i_bri_ibp_wr_valid),
  .i_ibp_wr_accept             (lat_i_bri_ibp_wr_accept),
  .i_ibp_wr_data               (lat_i_bri_ibp_wr_data),
  .i_ibp_wr_mask               (lat_i_bri_ibp_wr_mask),
  .i_ibp_wr_last               (lat_i_bri_ibp_wr_last),

  .i_ibp_wr_done               (lat_i_bri_ibp_wr_done),
  .i_ibp_wr_excl_done          (lat_i_bri_ibp_wr_excl_done),
  .i_ibp_err_wr                (lat_i_bri_ibp_err_wr),
  .i_ibp_wr_resp_accept        (lat_i_bri_ibp_wr_resp_accept),
                                                     // Output IBP I/F

  .o_ibp_cmd_valid             (lat_o_bri_ibp_cmd_valid),
  .o_ibp_cmd_accept            (lat_o_bri_ibp_cmd_accept),
  .o_ibp_cmd_read              (lat_o_bri_ibp_cmd_read),
  .o_ibp_cmd_addr              (lat_o_bri_ibp_cmd_addr),
  .o_ibp_cmd_wrap              (lat_o_bri_ibp_cmd_wrap),
  .o_ibp_cmd_data_size         (lat_o_bri_ibp_cmd_data_size),
  .o_ibp_cmd_burst_size        (lat_o_bri_ibp_cmd_burst_size),
  .o_ibp_cmd_prot              (lat_o_bri_ibp_cmd_prot),
  .o_ibp_cmd_cache             (lat_o_bri_ibp_cmd_cache),
  .o_ibp_cmd_lock              (lat_o_bri_ibp_cmd_lock),
  .o_ibp_cmd_excl              (lat_o_bri_ibp_cmd_excl),

  .o_ibp_rd_valid              (lat_o_bri_ibp_rd_valid),
  .o_ibp_rd_excl_ok            (lat_o_bri_ibp_rd_excl_ok),
  .o_ibp_rd_accept             (lat_o_bri_ibp_rd_accept),
  .o_ibp_err_rd                (lat_o_bri_ibp_err_rd),
  .o_ibp_rd_data               (lat_o_bri_ibp_rd_data),
  .o_ibp_rd_last               (lat_o_bri_ibp_rd_last),

  .o_ibp_wr_valid              (lat_o_bri_ibp_wr_valid),
  .o_ibp_wr_accept             (lat_o_bri_ibp_wr_accept),
  .o_ibp_wr_data               (lat_o_bri_ibp_wr_data),
  .o_ibp_wr_mask               (lat_o_bri_ibp_wr_mask),
  .o_ibp_wr_last               (lat_o_bri_ibp_wr_last),

  .o_ibp_wr_done               (lat_o_bri_ibp_wr_done),
  .o_ibp_wr_excl_done          (lat_o_bri_ibp_wr_excl_done),
  .o_ibp_err_wr                (lat_o_bri_ibp_err_wr),
  .o_ibp_wr_resp_accept        (lat_o_bri_ibp_wr_resp_accept),
                                                      // Profiler I/F
                                                     .cfg_lat_w(mss_fab_cfg_lat_w[2*12+:12]),
                                                     .cfg_lat_r(mss_fab_cfg_lat_r[2*12+:12]),
                                                     .cfg_wr_bw(mss_fab_cfg_wr_bw[2*10+:10]),
                                                     .cfg_rd_bw(mss_fab_cfg_rd_bw[2*10+:10]),
                                                     .perf_awf(mss_fab_perf_awf[2]),
                                                     .perf_arf(mss_fab_perf_arf[2]),
                                                     .perf_aw(mss_fab_perf_aw[2]),
                                                     .perf_ar(mss_fab_perf_ar[2]),
                                                     .perf_w(mss_fab_perf_w[2]),
                                                     .perf_wl(mss_fab_perf_wl[2]),
                                                     .perf_r(mss_fab_perf_r[2]),
                                                     .perf_rl(mss_fab_perf_rl[2]),
                                                     .perf_b(mss_fab_perf_b[2]));
    alb_mss_fab_ibp_lat #(.a_w(42),
                          .d_w(512),
                          .depl2(0)
                          ) u_xtor_axi_ibp_lat_inst(
                                                     // clock and reset
                                                     .clk(mss_clk),
                                                     .clk_en(1'b1),
                                                     .rst_b(rst_b),
                                                      // Input IBP I/F

  .i_ibp_cmd_valid             (lat_i_xtor_axi_ibp_cmd_valid),
  .i_ibp_cmd_accept            (lat_i_xtor_axi_ibp_cmd_accept),
  .i_ibp_cmd_read              (lat_i_xtor_axi_ibp_cmd_read),
  .i_ibp_cmd_addr              (lat_i_xtor_axi_ibp_cmd_addr),
  .i_ibp_cmd_wrap              (lat_i_xtor_axi_ibp_cmd_wrap),
  .i_ibp_cmd_data_size         (lat_i_xtor_axi_ibp_cmd_data_size),
  .i_ibp_cmd_burst_size        (lat_i_xtor_axi_ibp_cmd_burst_size),
  .i_ibp_cmd_prot              (lat_i_xtor_axi_ibp_cmd_prot),
  .i_ibp_cmd_cache             (lat_i_xtor_axi_ibp_cmd_cache),
  .i_ibp_cmd_lock              (lat_i_xtor_axi_ibp_cmd_lock),
  .i_ibp_cmd_excl              (lat_i_xtor_axi_ibp_cmd_excl),

  .i_ibp_rd_valid              (lat_i_xtor_axi_ibp_rd_valid),
  .i_ibp_rd_excl_ok            (lat_i_xtor_axi_ibp_rd_excl_ok),
  .i_ibp_rd_accept             (lat_i_xtor_axi_ibp_rd_accept),
  .i_ibp_err_rd                (lat_i_xtor_axi_ibp_err_rd),
  .i_ibp_rd_data               (lat_i_xtor_axi_ibp_rd_data),
  .i_ibp_rd_last               (lat_i_xtor_axi_ibp_rd_last),

  .i_ibp_wr_valid              (lat_i_xtor_axi_ibp_wr_valid),
  .i_ibp_wr_accept             (lat_i_xtor_axi_ibp_wr_accept),
  .i_ibp_wr_data               (lat_i_xtor_axi_ibp_wr_data),
  .i_ibp_wr_mask               (lat_i_xtor_axi_ibp_wr_mask),
  .i_ibp_wr_last               (lat_i_xtor_axi_ibp_wr_last),

  .i_ibp_wr_done               (lat_i_xtor_axi_ibp_wr_done),
  .i_ibp_wr_excl_done          (lat_i_xtor_axi_ibp_wr_excl_done),
  .i_ibp_err_wr                (lat_i_xtor_axi_ibp_err_wr),
  .i_ibp_wr_resp_accept        (lat_i_xtor_axi_ibp_wr_resp_accept),
                                                     // Output IBP I/F

  .o_ibp_cmd_valid             (lat_o_xtor_axi_ibp_cmd_valid),
  .o_ibp_cmd_accept            (lat_o_xtor_axi_ibp_cmd_accept),
  .o_ibp_cmd_read              (lat_o_xtor_axi_ibp_cmd_read),
  .o_ibp_cmd_addr              (lat_o_xtor_axi_ibp_cmd_addr),
  .o_ibp_cmd_wrap              (lat_o_xtor_axi_ibp_cmd_wrap),
  .o_ibp_cmd_data_size         (lat_o_xtor_axi_ibp_cmd_data_size),
  .o_ibp_cmd_burst_size        (lat_o_xtor_axi_ibp_cmd_burst_size),
  .o_ibp_cmd_prot              (lat_o_xtor_axi_ibp_cmd_prot),
  .o_ibp_cmd_cache             (lat_o_xtor_axi_ibp_cmd_cache),
  .o_ibp_cmd_lock              (lat_o_xtor_axi_ibp_cmd_lock),
  .o_ibp_cmd_excl              (lat_o_xtor_axi_ibp_cmd_excl),

  .o_ibp_rd_valid              (lat_o_xtor_axi_ibp_rd_valid),
  .o_ibp_rd_excl_ok            (lat_o_xtor_axi_ibp_rd_excl_ok),
  .o_ibp_rd_accept             (lat_o_xtor_axi_ibp_rd_accept),
  .o_ibp_err_rd                (lat_o_xtor_axi_ibp_err_rd),
  .o_ibp_rd_data               (lat_o_xtor_axi_ibp_rd_data),
  .o_ibp_rd_last               (lat_o_xtor_axi_ibp_rd_last),

  .o_ibp_wr_valid              (lat_o_xtor_axi_ibp_wr_valid),
  .o_ibp_wr_accept             (lat_o_xtor_axi_ibp_wr_accept),
  .o_ibp_wr_data               (lat_o_xtor_axi_ibp_wr_data),
  .o_ibp_wr_mask               (lat_o_xtor_axi_ibp_wr_mask),
  .o_ibp_wr_last               (lat_o_xtor_axi_ibp_wr_last),

  .o_ibp_wr_done               (lat_o_xtor_axi_ibp_wr_done),
  .o_ibp_wr_excl_done          (lat_o_xtor_axi_ibp_wr_excl_done),
  .o_ibp_err_wr                (lat_o_xtor_axi_ibp_err_wr),
  .o_ibp_wr_resp_accept        (lat_o_xtor_axi_ibp_wr_resp_accept),
                                                      // Profiler I/F
                                                     .cfg_lat_w(mss_fab_cfg_lat_w[3*12+:12]),
                                                     .cfg_lat_r(mss_fab_cfg_lat_r[3*12+:12]),
                                                     .cfg_wr_bw(mss_fab_cfg_wr_bw[3*10+:10]),
                                                     .cfg_rd_bw(mss_fab_cfg_rd_bw[3*10+:10]),
                                                     .perf_awf(mss_fab_perf_awf[3]),
                                                     .perf_arf(mss_fab_perf_arf[3]),
                                                     .perf_aw(mss_fab_perf_aw[3]),
                                                     .perf_ar(mss_fab_perf_ar[3]),
                                                     .perf_w(mss_fab_perf_w[3]),
                                                     .perf_wl(mss_fab_perf_wl[3]),
                                                     .perf_r(mss_fab_perf_r[3]),
                                                     .perf_rl(mss_fab_perf_rl[3]),
                                                     .perf_b(mss_fab_perf_b[3]));

    // Bus switch
    // all master and slave ports are aligned to system space
    alb_mss_bus_switch u_switch_inst(
                                                   // master side
                                                   .ahb_hbs_ibp_cmd_valid(lat_o_ahb_hibp_cmd_valid),
                                                   .ahb_hbs_ibp_cmd_accept(lat_o_ahb_hibp_cmd_accept),
                                                   .ahb_hbs_ibp_cmd_read(lat_o_ahb_hibp_cmd_read),
                                                   .ahb_hbs_ibp_cmd_addr(lat_o_ahb_hibp_cmd_addr),
                                                   .ahb_hbs_ibp_cmd_wrap(lat_o_ahb_hibp_cmd_wrap),
                                                   .ahb_hbs_ibp_cmd_data_size(lat_o_ahb_hibp_cmd_data_size),
                                                   .ahb_hbs_ibp_cmd_burst_size(lat_o_ahb_hibp_cmd_burst_size),
                                                   .ahb_hbs_ibp_cmd_lock(lat_o_ahb_hibp_cmd_lock),
                                                   .ahb_hbs_ibp_cmd_excl(lat_o_ahb_hibp_cmd_excl),
                                                   .ahb_hbs_ibp_cmd_prot(lat_o_ahb_hibp_cmd_prot),
                                                   .ahb_hbs_ibp_cmd_cache(lat_o_ahb_hibp_cmd_cache),
                                                   .ahb_hbs_ibp_rd_valid(lat_o_ahb_hibp_rd_valid),
                                                   .ahb_hbs_ibp_rd_accept(lat_o_ahb_hibp_rd_accept),
                                                   .ahb_hbs_ibp_rd_data(lat_o_ahb_hibp_rd_data),
                                                   .ahb_hbs_ibp_rd_last(lat_o_ahb_hibp_rd_last),
                                                   .ahb_hbs_ibp_err_rd(lat_o_ahb_hibp_err_rd),
                                                   .ahb_hbs_ibp_rd_excl_ok(lat_o_ahb_hibp_rd_excl_ok),
                                                   .ahb_hbs_ibp_wr_valid(lat_o_ahb_hibp_wr_valid),
                                                   .ahb_hbs_ibp_wr_accept(lat_o_ahb_hibp_wr_accept),
                                                   .ahb_hbs_ibp_wr_data(lat_o_ahb_hibp_wr_data),
                                                   .ahb_hbs_ibp_wr_mask(lat_o_ahb_hibp_wr_mask),
                                                   .ahb_hbs_ibp_wr_last(lat_o_ahb_hibp_wr_last),
                                                   .ahb_hbs_ibp_wr_done(lat_o_ahb_hibp_wr_done),
                                                   .ahb_hbs_ibp_wr_excl_done(lat_o_ahb_hibp_wr_excl_done),
                                                   .ahb_hbs_ibp_err_wr(lat_o_ahb_hibp_err_wr),
                                                   .ahb_hbs_ibp_wr_resp_accept(lat_o_ahb_hibp_wr_resp_accept),

                                                   .dbu_per_ahb_hbs_ibp_cmd_valid(lat_o_dbu_per_ahb_hibp_cmd_valid),
                                                   .dbu_per_ahb_hbs_ibp_cmd_accept(lat_o_dbu_per_ahb_hibp_cmd_accept),
                                                   .dbu_per_ahb_hbs_ibp_cmd_read(lat_o_dbu_per_ahb_hibp_cmd_read),
                                                   .dbu_per_ahb_hbs_ibp_cmd_addr(lat_o_dbu_per_ahb_hibp_cmd_addr),
                                                   .dbu_per_ahb_hbs_ibp_cmd_wrap(lat_o_dbu_per_ahb_hibp_cmd_wrap),
                                                   .dbu_per_ahb_hbs_ibp_cmd_data_size(lat_o_dbu_per_ahb_hibp_cmd_data_size),
                                                   .dbu_per_ahb_hbs_ibp_cmd_burst_size(lat_o_dbu_per_ahb_hibp_cmd_burst_size),
                                                   .dbu_per_ahb_hbs_ibp_cmd_lock(lat_o_dbu_per_ahb_hibp_cmd_lock),
                                                   .dbu_per_ahb_hbs_ibp_cmd_excl(lat_o_dbu_per_ahb_hibp_cmd_excl),
                                                   .dbu_per_ahb_hbs_ibp_cmd_prot(lat_o_dbu_per_ahb_hibp_cmd_prot),
                                                   .dbu_per_ahb_hbs_ibp_cmd_cache(lat_o_dbu_per_ahb_hibp_cmd_cache),
                                                   .dbu_per_ahb_hbs_ibp_rd_valid(lat_o_dbu_per_ahb_hibp_rd_valid),
                                                   .dbu_per_ahb_hbs_ibp_rd_accept(lat_o_dbu_per_ahb_hibp_rd_accept),
                                                   .dbu_per_ahb_hbs_ibp_rd_data(lat_o_dbu_per_ahb_hibp_rd_data),
                                                   .dbu_per_ahb_hbs_ibp_rd_last(lat_o_dbu_per_ahb_hibp_rd_last),
                                                   .dbu_per_ahb_hbs_ibp_err_rd(lat_o_dbu_per_ahb_hibp_err_rd),
                                                   .dbu_per_ahb_hbs_ibp_rd_excl_ok(lat_o_dbu_per_ahb_hibp_rd_excl_ok),
                                                   .dbu_per_ahb_hbs_ibp_wr_valid(lat_o_dbu_per_ahb_hibp_wr_valid),
                                                   .dbu_per_ahb_hbs_ibp_wr_accept(lat_o_dbu_per_ahb_hibp_wr_accept),
                                                   .dbu_per_ahb_hbs_ibp_wr_data(lat_o_dbu_per_ahb_hibp_wr_data),
                                                   .dbu_per_ahb_hbs_ibp_wr_mask(lat_o_dbu_per_ahb_hibp_wr_mask),
                                                   .dbu_per_ahb_hbs_ibp_wr_last(lat_o_dbu_per_ahb_hibp_wr_last),
                                                   .dbu_per_ahb_hbs_ibp_wr_done(lat_o_dbu_per_ahb_hibp_wr_done),
                                                   .dbu_per_ahb_hbs_ibp_wr_excl_done(lat_o_dbu_per_ahb_hibp_wr_excl_done),
                                                   .dbu_per_ahb_hbs_ibp_err_wr(lat_o_dbu_per_ahb_hibp_err_wr),
                                                   .dbu_per_ahb_hbs_ibp_wr_resp_accept(lat_o_dbu_per_ahb_hibp_wr_resp_accept),

                                                   .bri_bs_ibp_cmd_valid(lat_o_bri_ibp_cmd_valid),
                                                   .bri_bs_ibp_cmd_accept(lat_o_bri_ibp_cmd_accept),
                                                   .bri_bs_ibp_cmd_read(lat_o_bri_ibp_cmd_read),
                                                   .bri_bs_ibp_cmd_addr(lat_o_bri_ibp_cmd_addr),
                                                   .bri_bs_ibp_cmd_wrap(lat_o_bri_ibp_cmd_wrap),
                                                   .bri_bs_ibp_cmd_data_size(lat_o_bri_ibp_cmd_data_size),
                                                   .bri_bs_ibp_cmd_burst_size(lat_o_bri_ibp_cmd_burst_size),
                                                   .bri_bs_ibp_cmd_lock(lat_o_bri_ibp_cmd_lock),
                                                   .bri_bs_ibp_cmd_excl(lat_o_bri_ibp_cmd_excl),
                                                   .bri_bs_ibp_cmd_prot(lat_o_bri_ibp_cmd_prot),
                                                   .bri_bs_ibp_cmd_cache(lat_o_bri_ibp_cmd_cache),
                                                   .bri_bs_ibp_rd_valid(lat_o_bri_ibp_rd_valid),
                                                   .bri_bs_ibp_rd_accept(lat_o_bri_ibp_rd_accept),
                                                   .bri_bs_ibp_rd_data(lat_o_bri_ibp_rd_data),
                                                   .bri_bs_ibp_rd_last(lat_o_bri_ibp_rd_last),
                                                   .bri_bs_ibp_err_rd(lat_o_bri_ibp_err_rd),
                                                   .bri_bs_ibp_rd_excl_ok(lat_o_bri_ibp_rd_excl_ok),
                                                   .bri_bs_ibp_wr_valid(lat_o_bri_ibp_wr_valid),
                                                   .bri_bs_ibp_wr_accept(lat_o_bri_ibp_wr_accept),
                                                   .bri_bs_ibp_wr_data(lat_o_bri_ibp_wr_data),
                                                   .bri_bs_ibp_wr_mask(lat_o_bri_ibp_wr_mask),
                                                   .bri_bs_ibp_wr_last(lat_o_bri_ibp_wr_last),
                                                   .bri_bs_ibp_wr_done(lat_o_bri_ibp_wr_done),
                                                   .bri_bs_ibp_wr_excl_done(lat_o_bri_ibp_wr_excl_done),
                                                   .bri_bs_ibp_err_wr(lat_o_bri_ibp_err_wr),
                                                   .bri_bs_ibp_wr_resp_accept(lat_o_bri_ibp_wr_resp_accept),

                                                   .xtor_axi_bs_ibp_cmd_valid(lat_o_xtor_axi_ibp_cmd_valid),
                                                   .xtor_axi_bs_ibp_cmd_accept(lat_o_xtor_axi_ibp_cmd_accept),
                                                   .xtor_axi_bs_ibp_cmd_read(lat_o_xtor_axi_ibp_cmd_read),
                                                   .xtor_axi_bs_ibp_cmd_addr(lat_o_xtor_axi_ibp_cmd_addr),
                                                   .xtor_axi_bs_ibp_cmd_wrap(lat_o_xtor_axi_ibp_cmd_wrap),
                                                   .xtor_axi_bs_ibp_cmd_data_size(lat_o_xtor_axi_ibp_cmd_data_size),
                                                   .xtor_axi_bs_ibp_cmd_burst_size(lat_o_xtor_axi_ibp_cmd_burst_size),
                                                   .xtor_axi_bs_ibp_cmd_lock(lat_o_xtor_axi_ibp_cmd_lock),
                                                   .xtor_axi_bs_ibp_cmd_excl(lat_o_xtor_axi_ibp_cmd_excl),
                                                   .xtor_axi_bs_ibp_cmd_prot(lat_o_xtor_axi_ibp_cmd_prot),
                                                   .xtor_axi_bs_ibp_cmd_cache(lat_o_xtor_axi_ibp_cmd_cache),
                                                   .xtor_axi_bs_ibp_rd_valid(lat_o_xtor_axi_ibp_rd_valid),
                                                   .xtor_axi_bs_ibp_rd_accept(lat_o_xtor_axi_ibp_rd_accept),
                                                   .xtor_axi_bs_ibp_rd_data(lat_o_xtor_axi_ibp_rd_data),
                                                   .xtor_axi_bs_ibp_rd_last(lat_o_xtor_axi_ibp_rd_last),
                                                   .xtor_axi_bs_ibp_err_rd(lat_o_xtor_axi_ibp_err_rd),
                                                   .xtor_axi_bs_ibp_rd_excl_ok(lat_o_xtor_axi_ibp_rd_excl_ok),
                                                   .xtor_axi_bs_ibp_wr_valid(lat_o_xtor_axi_ibp_wr_valid),
                                                   .xtor_axi_bs_ibp_wr_accept(lat_o_xtor_axi_ibp_wr_accept),
                                                   .xtor_axi_bs_ibp_wr_data(lat_o_xtor_axi_ibp_wr_data),
                                                   .xtor_axi_bs_ibp_wr_mask(lat_o_xtor_axi_ibp_wr_mask),
                                                   .xtor_axi_bs_ibp_wr_last(lat_o_xtor_axi_ibp_wr_last),
                                                   .xtor_axi_bs_ibp_wr_done(lat_o_xtor_axi_ibp_wr_done),
                                                   .xtor_axi_bs_ibp_wr_excl_done(lat_o_xtor_axi_ibp_wr_excl_done),
                                                   .xtor_axi_bs_ibp_err_wr(lat_o_xtor_axi_ibp_err_wr),
                                                   .xtor_axi_bs_ibp_wr_resp_accept(lat_o_xtor_axi_ibp_wr_resp_accept),

                                                   // slave side
                                                   .iccm_ahb_hbs_ibp_cmd_valid(bs_o_iccm_ahb_hibp_cmd_valid),
                                                   .iccm_ahb_hbs_ibp_cmd_accept(bs_o_iccm_ahb_hibp_cmd_accept),
                                                   .iccm_ahb_hbs_ibp_cmd_read(bs_o_iccm_ahb_hibp_cmd_read),
                                                   .iccm_ahb_hbs_ibp_cmd_addr(bs_o_iccm_ahb_hibp_cmd_addr),
                                                   .iccm_ahb_hbs_ibp_cmd_wrap(bs_o_iccm_ahb_hibp_cmd_wrap),
                                                   .iccm_ahb_hbs_ibp_cmd_data_size(bs_o_iccm_ahb_hibp_cmd_data_size),
                                                   .iccm_ahb_hbs_ibp_cmd_burst_size(bs_o_iccm_ahb_hibp_cmd_burst_size),
                                                   .iccm_ahb_hbs_ibp_cmd_lock(bs_o_iccm_ahb_hibp_cmd_lock),
                                                   .iccm_ahb_hbs_ibp_cmd_excl(bs_o_iccm_ahb_hibp_cmd_excl),
                                                   .iccm_ahb_hbs_ibp_cmd_prot(bs_o_iccm_ahb_hibp_cmd_prot),
                                                   .iccm_ahb_hbs_ibp_cmd_cache(bs_o_iccm_ahb_hibp_cmd_cache),
                                                   .iccm_ahb_hbs_ibp_cmd_region(bs_o_iccm_ahb_hibp_cmd_region),
                                                   .iccm_ahb_hbs_ibp_rd_valid(bs_o_iccm_ahb_hibp_rd_valid),
                                                   .iccm_ahb_hbs_ibp_rd_accept(bs_o_iccm_ahb_hibp_rd_accept),
                                                   .iccm_ahb_hbs_ibp_rd_data(bs_o_iccm_ahb_hibp_rd_data),
                                                   .iccm_ahb_hbs_ibp_rd_last(bs_o_iccm_ahb_hibp_rd_last),
                                                   .iccm_ahb_hbs_ibp_err_rd(bs_o_iccm_ahb_hibp_err_rd),
                                                   .iccm_ahb_hbs_ibp_rd_excl_ok(bs_o_iccm_ahb_hibp_rd_excl_ok),
                                                   .iccm_ahb_hbs_ibp_wr_valid(bs_o_iccm_ahb_hibp_wr_valid),
                                                   .iccm_ahb_hbs_ibp_wr_accept(bs_o_iccm_ahb_hibp_wr_accept),
                                                   .iccm_ahb_hbs_ibp_wr_data(bs_o_iccm_ahb_hibp_wr_data),
                                                   .iccm_ahb_hbs_ibp_wr_mask(bs_o_iccm_ahb_hibp_wr_mask),
                                                   .iccm_ahb_hbs_ibp_wr_last(bs_o_iccm_ahb_hibp_wr_last),
                                                   .iccm_ahb_hbs_ibp_wr_done(bs_o_iccm_ahb_hibp_wr_done),
                                                   .iccm_ahb_hbs_ibp_wr_excl_done(bs_o_iccm_ahb_hibp_wr_excl_done),
                                                   .iccm_ahb_hbs_ibp_err_wr(bs_o_iccm_ahb_hibp_err_wr),
                                                   .iccm_ahb_hbs_ibp_wr_resp_accept(bs_o_iccm_ahb_hibp_wr_resp_accept),

                                                   .dccm_ahb_hbs_ibp_cmd_valid(bs_o_dccm_ahb_hibp_cmd_valid),
                                                   .dccm_ahb_hbs_ibp_cmd_accept(bs_o_dccm_ahb_hibp_cmd_accept),
                                                   .dccm_ahb_hbs_ibp_cmd_read(bs_o_dccm_ahb_hibp_cmd_read),
                                                   .dccm_ahb_hbs_ibp_cmd_addr(bs_o_dccm_ahb_hibp_cmd_addr),
                                                   .dccm_ahb_hbs_ibp_cmd_wrap(bs_o_dccm_ahb_hibp_cmd_wrap),
                                                   .dccm_ahb_hbs_ibp_cmd_data_size(bs_o_dccm_ahb_hibp_cmd_data_size),
                                                   .dccm_ahb_hbs_ibp_cmd_burst_size(bs_o_dccm_ahb_hibp_cmd_burst_size),
                                                   .dccm_ahb_hbs_ibp_cmd_lock(bs_o_dccm_ahb_hibp_cmd_lock),
                                                   .dccm_ahb_hbs_ibp_cmd_excl(bs_o_dccm_ahb_hibp_cmd_excl),
                                                   .dccm_ahb_hbs_ibp_cmd_prot(bs_o_dccm_ahb_hibp_cmd_prot),
                                                   .dccm_ahb_hbs_ibp_cmd_cache(bs_o_dccm_ahb_hibp_cmd_cache),
                                                   .dccm_ahb_hbs_ibp_cmd_region(bs_o_dccm_ahb_hibp_cmd_region),
                                                   .dccm_ahb_hbs_ibp_rd_valid(bs_o_dccm_ahb_hibp_rd_valid),
                                                   .dccm_ahb_hbs_ibp_rd_accept(bs_o_dccm_ahb_hibp_rd_accept),
                                                   .dccm_ahb_hbs_ibp_rd_data(bs_o_dccm_ahb_hibp_rd_data),
                                                   .dccm_ahb_hbs_ibp_rd_last(bs_o_dccm_ahb_hibp_rd_last),
                                                   .dccm_ahb_hbs_ibp_err_rd(bs_o_dccm_ahb_hibp_err_rd),
                                                   .dccm_ahb_hbs_ibp_rd_excl_ok(bs_o_dccm_ahb_hibp_rd_excl_ok),
                                                   .dccm_ahb_hbs_ibp_wr_valid(bs_o_dccm_ahb_hibp_wr_valid),
                                                   .dccm_ahb_hbs_ibp_wr_accept(bs_o_dccm_ahb_hibp_wr_accept),
                                                   .dccm_ahb_hbs_ibp_wr_data(bs_o_dccm_ahb_hibp_wr_data),
                                                   .dccm_ahb_hbs_ibp_wr_mask(bs_o_dccm_ahb_hibp_wr_mask),
                                                   .dccm_ahb_hbs_ibp_wr_last(bs_o_dccm_ahb_hibp_wr_last),
                                                   .dccm_ahb_hbs_ibp_wr_done(bs_o_dccm_ahb_hibp_wr_done),
                                                   .dccm_ahb_hbs_ibp_wr_excl_done(bs_o_dccm_ahb_hibp_wr_excl_done),
                                                   .dccm_ahb_hbs_ibp_err_wr(bs_o_dccm_ahb_hibp_err_wr),
                                                   .dccm_ahb_hbs_ibp_wr_resp_accept(bs_o_dccm_ahb_hibp_wr_resp_accept),

                                                   .mmio_ahb_hbs_ibp_cmd_valid(bs_o_mmio_ahb_hibp_cmd_valid),
                                                   .mmio_ahb_hbs_ibp_cmd_accept(bs_o_mmio_ahb_hibp_cmd_accept),
                                                   .mmio_ahb_hbs_ibp_cmd_read(bs_o_mmio_ahb_hibp_cmd_read),
                                                   .mmio_ahb_hbs_ibp_cmd_addr(bs_o_mmio_ahb_hibp_cmd_addr),
                                                   .mmio_ahb_hbs_ibp_cmd_wrap(bs_o_mmio_ahb_hibp_cmd_wrap),
                                                   .mmio_ahb_hbs_ibp_cmd_data_size(bs_o_mmio_ahb_hibp_cmd_data_size),
                                                   .mmio_ahb_hbs_ibp_cmd_burst_size(bs_o_mmio_ahb_hibp_cmd_burst_size),
                                                   .mmio_ahb_hbs_ibp_cmd_lock(bs_o_mmio_ahb_hibp_cmd_lock),
                                                   .mmio_ahb_hbs_ibp_cmd_excl(bs_o_mmio_ahb_hibp_cmd_excl),
                                                   .mmio_ahb_hbs_ibp_cmd_prot(bs_o_mmio_ahb_hibp_cmd_prot),
                                                   .mmio_ahb_hbs_ibp_cmd_cache(bs_o_mmio_ahb_hibp_cmd_cache),
                                                   .mmio_ahb_hbs_ibp_cmd_region(bs_o_mmio_ahb_hibp_cmd_region),
                                                   .mmio_ahb_hbs_ibp_rd_valid(bs_o_mmio_ahb_hibp_rd_valid),
                                                   .mmio_ahb_hbs_ibp_rd_accept(bs_o_mmio_ahb_hibp_rd_accept),
                                                   .mmio_ahb_hbs_ibp_rd_data(bs_o_mmio_ahb_hibp_rd_data),
                                                   .mmio_ahb_hbs_ibp_rd_last(bs_o_mmio_ahb_hibp_rd_last),
                                                   .mmio_ahb_hbs_ibp_err_rd(bs_o_mmio_ahb_hibp_err_rd),
                                                   .mmio_ahb_hbs_ibp_rd_excl_ok(bs_o_mmio_ahb_hibp_rd_excl_ok),
                                                   .mmio_ahb_hbs_ibp_wr_valid(bs_o_mmio_ahb_hibp_wr_valid),
                                                   .mmio_ahb_hbs_ibp_wr_accept(bs_o_mmio_ahb_hibp_wr_accept),
                                                   .mmio_ahb_hbs_ibp_wr_data(bs_o_mmio_ahb_hibp_wr_data),
                                                   .mmio_ahb_hbs_ibp_wr_mask(bs_o_mmio_ahb_hibp_wr_mask),
                                                   .mmio_ahb_hbs_ibp_wr_last(bs_o_mmio_ahb_hibp_wr_last),
                                                   .mmio_ahb_hbs_ibp_wr_done(bs_o_mmio_ahb_hibp_wr_done),
                                                   .mmio_ahb_hbs_ibp_wr_excl_done(bs_o_mmio_ahb_hibp_wr_excl_done),
                                                   .mmio_ahb_hbs_ibp_err_wr(bs_o_mmio_ahb_hibp_err_wr),
                                                   .mmio_ahb_hbs_ibp_wr_resp_accept(bs_o_mmio_ahb_hibp_wr_resp_accept),

                                                   .mss_clkctrl_bs_ibp_cmd_valid(bs_o_mss_clkctrl_ibp_cmd_valid),
                                                   .mss_clkctrl_bs_ibp_cmd_accept(bs_o_mss_clkctrl_ibp_cmd_accept),
                                                   .mss_clkctrl_bs_ibp_cmd_read(bs_o_mss_clkctrl_ibp_cmd_read),
                                                   .mss_clkctrl_bs_ibp_cmd_addr(bs_o_mss_clkctrl_ibp_cmd_addr_temp),
                                                   .mss_clkctrl_bs_ibp_cmd_wrap(bs_o_mss_clkctrl_ibp_cmd_wrap),
                                                   .mss_clkctrl_bs_ibp_cmd_data_size(bs_o_mss_clkctrl_ibp_cmd_data_size),
                                                   .mss_clkctrl_bs_ibp_cmd_burst_size(bs_o_mss_clkctrl_ibp_cmd_burst_size),
                                                   .mss_clkctrl_bs_ibp_cmd_lock(bs_o_mss_clkctrl_ibp_cmd_lock),
                                                   .mss_clkctrl_bs_ibp_cmd_excl(bs_o_mss_clkctrl_ibp_cmd_excl),
                                                   .mss_clkctrl_bs_ibp_cmd_prot(bs_o_mss_clkctrl_ibp_cmd_prot),
                                                   .mss_clkctrl_bs_ibp_cmd_cache(bs_o_mss_clkctrl_ibp_cmd_cache),
                                                   .mss_clkctrl_bs_ibp_cmd_region(bs_o_mss_clkctrl_ibp_cmd_region),
                                                   .mss_clkctrl_bs_ibp_rd_valid(bs_o_mss_clkctrl_ibp_rd_valid),
                                                   .mss_clkctrl_bs_ibp_rd_accept(bs_o_mss_clkctrl_ibp_rd_accept),
                                                   .mss_clkctrl_bs_ibp_rd_data(bs_o_mss_clkctrl_ibp_rd_data),
                                                   .mss_clkctrl_bs_ibp_rd_last(bs_o_mss_clkctrl_ibp_rd_last),
                                                   .mss_clkctrl_bs_ibp_err_rd(bs_o_mss_clkctrl_ibp_err_rd),
                                                   .mss_clkctrl_bs_ibp_rd_excl_ok(bs_o_mss_clkctrl_ibp_rd_excl_ok),
                                                   .mss_clkctrl_bs_ibp_wr_valid(bs_o_mss_clkctrl_ibp_wr_valid),
                                                   .mss_clkctrl_bs_ibp_wr_accept(bs_o_mss_clkctrl_ibp_wr_accept),
                                                   .mss_clkctrl_bs_ibp_wr_data(bs_o_mss_clkctrl_ibp_wr_data),
                                                   .mss_clkctrl_bs_ibp_wr_mask(bs_o_mss_clkctrl_ibp_wr_mask),
                                                   .mss_clkctrl_bs_ibp_wr_last(bs_o_mss_clkctrl_ibp_wr_last),
                                                   .mss_clkctrl_bs_ibp_wr_done(bs_o_mss_clkctrl_ibp_wr_done),
                                                   .mss_clkctrl_bs_ibp_wr_excl_done(bs_o_mss_clkctrl_ibp_wr_excl_done),
                                                   .mss_clkctrl_bs_ibp_err_wr(bs_o_mss_clkctrl_ibp_err_wr),
                                                   .mss_clkctrl_bs_ibp_wr_resp_accept(bs_o_mss_clkctrl_ibp_wr_resp_accept),

                                                   .dslv1_bs_ibp_cmd_valid(bs_o_dslv1_ibp_cmd_valid),
                                                   .dslv1_bs_ibp_cmd_accept(bs_o_dslv1_ibp_cmd_accept),
                                                   .dslv1_bs_ibp_cmd_read(bs_o_dslv1_ibp_cmd_read),
                                                   .dslv1_bs_ibp_cmd_addr(bs_o_dslv1_ibp_cmd_addr_temp),
                                                   .dslv1_bs_ibp_cmd_wrap(bs_o_dslv1_ibp_cmd_wrap),
                                                   .dslv1_bs_ibp_cmd_data_size(bs_o_dslv1_ibp_cmd_data_size),
                                                   .dslv1_bs_ibp_cmd_burst_size(bs_o_dslv1_ibp_cmd_burst_size),
                                                   .dslv1_bs_ibp_cmd_lock(bs_o_dslv1_ibp_cmd_lock),
                                                   .dslv1_bs_ibp_cmd_excl(bs_o_dslv1_ibp_cmd_excl),
                                                   .dslv1_bs_ibp_cmd_prot(bs_o_dslv1_ibp_cmd_prot),
                                                   .dslv1_bs_ibp_cmd_cache(bs_o_dslv1_ibp_cmd_cache),
                                                   .dslv1_bs_ibp_cmd_region(bs_o_dslv1_ibp_cmd_region),
                                                   .dslv1_bs_ibp_rd_valid(bs_o_dslv1_ibp_rd_valid),
                                                   .dslv1_bs_ibp_rd_accept(bs_o_dslv1_ibp_rd_accept),
                                                   .dslv1_bs_ibp_rd_data(bs_o_dslv1_ibp_rd_data),
                                                   .dslv1_bs_ibp_rd_last(bs_o_dslv1_ibp_rd_last),
                                                   .dslv1_bs_ibp_err_rd(bs_o_dslv1_ibp_err_rd),
                                                   .dslv1_bs_ibp_rd_excl_ok(bs_o_dslv1_ibp_rd_excl_ok),
                                                   .dslv1_bs_ibp_wr_valid(bs_o_dslv1_ibp_wr_valid),
                                                   .dslv1_bs_ibp_wr_accept(bs_o_dslv1_ibp_wr_accept),
                                                   .dslv1_bs_ibp_wr_data(bs_o_dslv1_ibp_wr_data),
                                                   .dslv1_bs_ibp_wr_mask(bs_o_dslv1_ibp_wr_mask),
                                                   .dslv1_bs_ibp_wr_last(bs_o_dslv1_ibp_wr_last),
                                                   .dslv1_bs_ibp_wr_done(bs_o_dslv1_ibp_wr_done),
                                                   .dslv1_bs_ibp_wr_excl_done(bs_o_dslv1_ibp_wr_excl_done),
                                                   .dslv1_bs_ibp_err_wr(bs_o_dslv1_ibp_err_wr),
                                                   .dslv1_bs_ibp_wr_resp_accept(bs_o_dslv1_ibp_wr_resp_accept),

                                                   .dslv2_bs_ibp_cmd_valid(bs_o_dslv2_ibp_cmd_valid),
                                                   .dslv2_bs_ibp_cmd_accept(bs_o_dslv2_ibp_cmd_accept),
                                                   .dslv2_bs_ibp_cmd_read(bs_o_dslv2_ibp_cmd_read),
                                                   .dslv2_bs_ibp_cmd_addr(bs_o_dslv2_ibp_cmd_addr_temp),
                                                   .dslv2_bs_ibp_cmd_wrap(bs_o_dslv2_ibp_cmd_wrap),
                                                   .dslv2_bs_ibp_cmd_data_size(bs_o_dslv2_ibp_cmd_data_size),
                                                   .dslv2_bs_ibp_cmd_burst_size(bs_o_dslv2_ibp_cmd_burst_size),
                                                   .dslv2_bs_ibp_cmd_lock(bs_o_dslv2_ibp_cmd_lock),
                                                   .dslv2_bs_ibp_cmd_excl(bs_o_dslv2_ibp_cmd_excl),
                                                   .dslv2_bs_ibp_cmd_prot(bs_o_dslv2_ibp_cmd_prot),
                                                   .dslv2_bs_ibp_cmd_cache(bs_o_dslv2_ibp_cmd_cache),
                                                   .dslv2_bs_ibp_cmd_region(bs_o_dslv2_ibp_cmd_region),
                                                   .dslv2_bs_ibp_rd_valid(bs_o_dslv2_ibp_rd_valid),
                                                   .dslv2_bs_ibp_rd_accept(bs_o_dslv2_ibp_rd_accept),
                                                   .dslv2_bs_ibp_rd_data(bs_o_dslv2_ibp_rd_data),
                                                   .dslv2_bs_ibp_rd_last(bs_o_dslv2_ibp_rd_last),
                                                   .dslv2_bs_ibp_err_rd(bs_o_dslv2_ibp_err_rd),
                                                   .dslv2_bs_ibp_rd_excl_ok(bs_o_dslv2_ibp_rd_excl_ok),
                                                   .dslv2_bs_ibp_wr_valid(bs_o_dslv2_ibp_wr_valid),
                                                   .dslv2_bs_ibp_wr_accept(bs_o_dslv2_ibp_wr_accept),
                                                   .dslv2_bs_ibp_wr_data(bs_o_dslv2_ibp_wr_data),
                                                   .dslv2_bs_ibp_wr_mask(bs_o_dslv2_ibp_wr_mask),
                                                   .dslv2_bs_ibp_wr_last(bs_o_dslv2_ibp_wr_last),
                                                   .dslv2_bs_ibp_wr_done(bs_o_dslv2_ibp_wr_done),
                                                   .dslv2_bs_ibp_wr_excl_done(bs_o_dslv2_ibp_wr_excl_done),
                                                   .dslv2_bs_ibp_err_wr(bs_o_dslv2_ibp_err_wr),
                                                   .dslv2_bs_ibp_wr_resp_accept(bs_o_dslv2_ibp_wr_resp_accept),

                                                   .mss_perfctrl_bs_ibp_cmd_valid(bs_o_mss_perfctrl_ibp_cmd_valid),
                                                   .mss_perfctrl_bs_ibp_cmd_accept(bs_o_mss_perfctrl_ibp_cmd_accept),
                                                   .mss_perfctrl_bs_ibp_cmd_read(bs_o_mss_perfctrl_ibp_cmd_read),
                                                   .mss_perfctrl_bs_ibp_cmd_addr(bs_o_mss_perfctrl_ibp_cmd_addr_temp),
                                                   .mss_perfctrl_bs_ibp_cmd_wrap(bs_o_mss_perfctrl_ibp_cmd_wrap),
                                                   .mss_perfctrl_bs_ibp_cmd_data_size(bs_o_mss_perfctrl_ibp_cmd_data_size),
                                                   .mss_perfctrl_bs_ibp_cmd_burst_size(bs_o_mss_perfctrl_ibp_cmd_burst_size),
                                                   .mss_perfctrl_bs_ibp_cmd_lock(bs_o_mss_perfctrl_ibp_cmd_lock),
                                                   .mss_perfctrl_bs_ibp_cmd_excl(bs_o_mss_perfctrl_ibp_cmd_excl),
                                                   .mss_perfctrl_bs_ibp_cmd_prot(bs_o_mss_perfctrl_ibp_cmd_prot),
                                                   .mss_perfctrl_bs_ibp_cmd_cache(bs_o_mss_perfctrl_ibp_cmd_cache),
                                                   .mss_perfctrl_bs_ibp_cmd_region(bs_o_mss_perfctrl_ibp_cmd_region),
                                                   .mss_perfctrl_bs_ibp_rd_valid(bs_o_mss_perfctrl_ibp_rd_valid),
                                                   .mss_perfctrl_bs_ibp_rd_accept(bs_o_mss_perfctrl_ibp_rd_accept),
                                                   .mss_perfctrl_bs_ibp_rd_data(bs_o_mss_perfctrl_ibp_rd_data),
                                                   .mss_perfctrl_bs_ibp_rd_last(bs_o_mss_perfctrl_ibp_rd_last),
                                                   .mss_perfctrl_bs_ibp_err_rd(bs_o_mss_perfctrl_ibp_err_rd),
                                                   .mss_perfctrl_bs_ibp_rd_excl_ok(bs_o_mss_perfctrl_ibp_rd_excl_ok),
                                                   .mss_perfctrl_bs_ibp_wr_valid(bs_o_mss_perfctrl_ibp_wr_valid),
                                                   .mss_perfctrl_bs_ibp_wr_accept(bs_o_mss_perfctrl_ibp_wr_accept),
                                                   .mss_perfctrl_bs_ibp_wr_data(bs_o_mss_perfctrl_ibp_wr_data),
                                                   .mss_perfctrl_bs_ibp_wr_mask(bs_o_mss_perfctrl_ibp_wr_mask),
                                                   .mss_perfctrl_bs_ibp_wr_last(bs_o_mss_perfctrl_ibp_wr_last),
                                                   .mss_perfctrl_bs_ibp_wr_done(bs_o_mss_perfctrl_ibp_wr_done),
                                                   .mss_perfctrl_bs_ibp_wr_excl_done(bs_o_mss_perfctrl_ibp_wr_excl_done),
                                                   .mss_perfctrl_bs_ibp_err_wr(bs_o_mss_perfctrl_ibp_err_wr),
                                                   .mss_perfctrl_bs_ibp_wr_resp_accept(bs_o_mss_perfctrl_ibp_wr_resp_accept),

                                                   .mss_mem_bs_ibp_cmd_valid(bs_o_mss_mem_ibp_cmd_valid),
                                                   .mss_mem_bs_ibp_cmd_accept(bs_o_mss_mem_ibp_cmd_accept),
                                                   .mss_mem_bs_ibp_cmd_read(bs_o_mss_mem_ibp_cmd_read),
                                                   .mss_mem_bs_ibp_cmd_addr(bs_o_mss_mem_ibp_cmd_addr),
                                                   .mss_mem_bs_ibp_cmd_wrap(bs_o_mss_mem_ibp_cmd_wrap),
                                                   .mss_mem_bs_ibp_cmd_data_size(bs_o_mss_mem_ibp_cmd_data_size),
                                                   .mss_mem_bs_ibp_cmd_burst_size(bs_o_mss_mem_ibp_cmd_burst_size),
                                                   .mss_mem_bs_ibp_cmd_lock(bs_o_mss_mem_ibp_cmd_lock),
                                                   .mss_mem_bs_ibp_cmd_excl(bs_o_mss_mem_ibp_cmd_excl),
                                                   .mss_mem_bs_ibp_cmd_prot(bs_o_mss_mem_ibp_cmd_prot),
                                                   .mss_mem_bs_ibp_cmd_cache(bs_o_mss_mem_ibp_cmd_cache),
                                                   .mss_mem_bs_ibp_cmd_region(bs_o_mss_mem_ibp_cmd_region),
                                                   .mss_mem_bs_ibp_rd_valid(bs_o_mss_mem_ibp_rd_valid),
                                                   .mss_mem_bs_ibp_rd_accept(bs_o_mss_mem_ibp_rd_accept),
                                                   .mss_mem_bs_ibp_rd_data(bs_o_mss_mem_ibp_rd_data),
                                                   .mss_mem_bs_ibp_rd_last(bs_o_mss_mem_ibp_rd_last),
                                                   .mss_mem_bs_ibp_err_rd(bs_o_mss_mem_ibp_err_rd),
                                                   .mss_mem_bs_ibp_rd_excl_ok(bs_o_mss_mem_ibp_rd_excl_ok),
                                                   .mss_mem_bs_ibp_wr_valid(bs_o_mss_mem_ibp_wr_valid),
                                                   .mss_mem_bs_ibp_wr_accept(bs_o_mss_mem_ibp_wr_accept),
                                                   .mss_mem_bs_ibp_wr_data(bs_o_mss_mem_ibp_wr_data),
                                                   .mss_mem_bs_ibp_wr_mask(bs_o_mss_mem_ibp_wr_mask),
                                                   .mss_mem_bs_ibp_wr_last(bs_o_mss_mem_ibp_wr_last),
                                                   .mss_mem_bs_ibp_wr_done(bs_o_mss_mem_ibp_wr_done),
                                                   .mss_mem_bs_ibp_wr_excl_done(bs_o_mss_mem_ibp_wr_excl_done),
                                                   .mss_mem_bs_ibp_err_wr(bs_o_mss_mem_ibp_err_wr),
                                                   .mss_mem_bs_ibp_wr_resp_accept(bs_o_mss_mem_ibp_wr_resp_accept),

                                                   // clock and reset
                                                   .clk(mss_clk),
                                                   .rst_a(~rst_b)
                                                   );
assign bs_o_mss_clkctrl_ibp_cmd_addr = {bs_o_mss_clkctrl_ibp_cmd_addr_temp[10+32-1:32],bs_o_mss_clkctrl_ibp_cmd_addr_temp[12-1:0]};
assign bs_o_dslv1_ibp_cmd_addr = {bs_o_dslv1_ibp_cmd_addr_temp[10+32-1:32],bs_o_dslv1_ibp_cmd_addr_temp[12-1:0]};
assign bs_o_dslv2_ibp_cmd_addr = {bs_o_dslv2_ibp_cmd_addr_temp[10+32-1:32],bs_o_dslv2_ibp_cmd_addr_temp[24-1:0]};
assign bs_o_mss_perfctrl_ibp_cmd_addr = {bs_o_mss_perfctrl_ibp_cmd_addr_temp[10+32-1:32],bs_o_mss_perfctrl_ibp_cmd_addr_temp[13-1:0]};

    // To support flexible clock ratio configuration, there is a clk_domain converting logic here
    // handles from ARCv2MSS fabric clock domain to slave clock domain
    // If slave port already support clock ratio, the signals are just bypassed from fabric
    // If slave port doesn't support clock ratio, invloves two ibp_buffer to do domain conversion
      //
      // current slave prefix is iccm_ahb_h, cfree attr is 0, ratio attr is 1
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_iccm_ahb_h_ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_iccm_ahb_hibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_iccm_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_iccm_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (bs_o_iccm_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (bs_o_iccm_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_iccm_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_iccm_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_iccm_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_iccm_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_iccm_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_iccm_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_iccm_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (bs_o_iccm_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_iccm_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_iccm_ahb_hibp_rd_accept),
  .ibp_err_rd                (bs_o_iccm_ahb_hibp_err_rd),
  .ibp_rd_data               (bs_o_iccm_ahb_hibp_rd_data),
  .ibp_rd_last               (bs_o_iccm_ahb_hibp_rd_last),

  .ibp_wr_valid              (bs_o_iccm_ahb_hibp_wr_valid),
  .ibp_wr_accept             (bs_o_iccm_ahb_hibp_wr_accept),
  .ibp_wr_data               (bs_o_iccm_ahb_hibp_wr_data),
  .ibp_wr_mask               (bs_o_iccm_ahb_hibp_wr_mask),
  .ibp_wr_last               (bs_o_iccm_ahb_hibp_wr_last),

  .ibp_wr_done               (bs_o_iccm_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (bs_o_iccm_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (bs_o_iccm_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_iccm_ahb_hibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_iccm_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_iccm_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_iccm_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_iccm_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_iccm_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_iccm_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_iccm_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_iccm_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_iccm_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_iccm_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_iccm_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_iccm_ahb_hibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_iccm_ahb_hibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // bypass the signals from bus_switch to slave port
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_iccm_ahb_h_ibp_buffer_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_iccm_ahb_hibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_iccm_ahb_hibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_iccm_ahb_hibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_iccm_ahb_hibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_iccm_ahb_hibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_iccm_ahb_hibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_iccm_ahb_hibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_iccm_ahb_hibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_iccm_ahb_hibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_iccm_ahb_hibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_iccm_ahb_hibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_iccm_ahb_hibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_iccm_ahb_hibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_iccm_ahb_hibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_iccm_ahb_hibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_iccm_ahb_hibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_iccm_ahb_hibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_iccm_ahb_hibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_iccm_ahb_hibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_iccm_ahb_hibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_iccm_ahb_hibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_iccm_ahb_hibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_iccm_ahb_hibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_iccm_ahb_hibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_iccm_ahb_hibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_iccm_ahb_hibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_iccm_ahb_h_pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_iccm_ahb_hibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_iccm_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_iccm_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_iccm_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_iccm_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_iccm_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_iccm_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_iccm_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_iccm_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_iccm_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_iccm_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_iccm_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_iccm_ahb_hibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_iccm_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_iccm_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (slv_o_iccm_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (slv_o_iccm_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_iccm_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_iccm_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_iccm_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_iccm_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_iccm_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_iccm_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_iccm_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (slv_o_iccm_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_iccm_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_iccm_ahb_hibp_rd_accept),
  .ibp_err_rd                (slv_o_iccm_ahb_hibp_err_rd),
  .ibp_rd_data               (slv_o_iccm_ahb_hibp_rd_data),
  .ibp_rd_last               (slv_o_iccm_ahb_hibp_rd_last),

  .ibp_wr_valid              (slv_o_iccm_ahb_hibp_wr_valid),
  .ibp_wr_accept             (slv_o_iccm_ahb_hibp_wr_accept),
  .ibp_wr_data               (slv_o_iccm_ahb_hibp_wr_data),
  .ibp_wr_mask               (slv_o_iccm_ahb_hibp_wr_mask),
  .ibp_wr_last               (slv_o_iccm_ahb_hibp_wr_last),

  .ibp_wr_done               (slv_o_iccm_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (slv_o_iccm_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (slv_o_iccm_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_iccm_ahb_hibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_iccm_ahb_hibp_cmd_region)
                           );
      //
      // current slave prefix is dccm_ahb_h, cfree attr is 0, ratio attr is 1
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dccm_ahb_h_ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_dccm_ahb_hibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_dccm_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_dccm_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (bs_o_dccm_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (bs_o_dccm_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_dccm_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_dccm_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_dccm_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_dccm_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_dccm_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_dccm_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_dccm_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (bs_o_dccm_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_dccm_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_dccm_ahb_hibp_rd_accept),
  .ibp_err_rd                (bs_o_dccm_ahb_hibp_err_rd),
  .ibp_rd_data               (bs_o_dccm_ahb_hibp_rd_data),
  .ibp_rd_last               (bs_o_dccm_ahb_hibp_rd_last),

  .ibp_wr_valid              (bs_o_dccm_ahb_hibp_wr_valid),
  .ibp_wr_accept             (bs_o_dccm_ahb_hibp_wr_accept),
  .ibp_wr_data               (bs_o_dccm_ahb_hibp_wr_data),
  .ibp_wr_mask               (bs_o_dccm_ahb_hibp_wr_mask),
  .ibp_wr_last               (bs_o_dccm_ahb_hibp_wr_last),

  .ibp_wr_done               (bs_o_dccm_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (bs_o_dccm_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (bs_o_dccm_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_dccm_ahb_hibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_dccm_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_dccm_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_dccm_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_dccm_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_dccm_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_dccm_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_dccm_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_dccm_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_dccm_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_dccm_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_dccm_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_dccm_ahb_hibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_dccm_ahb_hibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // bypass the signals from bus_switch to slave port
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_dccm_ahb_h_ibp_buffer_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_dccm_ahb_hibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_dccm_ahb_hibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_dccm_ahb_hibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_dccm_ahb_hibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_dccm_ahb_hibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_dccm_ahb_hibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_dccm_ahb_hibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_dccm_ahb_hibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_dccm_ahb_hibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_dccm_ahb_hibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_dccm_ahb_hibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_dccm_ahb_hibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_dccm_ahb_hibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_dccm_ahb_hibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_dccm_ahb_hibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_dccm_ahb_hibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_dccm_ahb_hibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_dccm_ahb_hibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_dccm_ahb_hibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_dccm_ahb_hibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_dccm_ahb_hibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_dccm_ahb_hibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_dccm_ahb_hibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_dccm_ahb_hibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_dccm_ahb_hibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_dccm_ahb_hibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dccm_ahb_h_pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_dccm_ahb_hibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_dccm_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_dccm_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_dccm_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_dccm_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_dccm_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_dccm_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_dccm_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_dccm_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_dccm_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_dccm_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_dccm_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_dccm_ahb_hibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_dccm_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_dccm_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (slv_o_dccm_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (slv_o_dccm_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_dccm_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_dccm_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_dccm_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_dccm_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_dccm_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_dccm_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_dccm_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (slv_o_dccm_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_dccm_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_dccm_ahb_hibp_rd_accept),
  .ibp_err_rd                (slv_o_dccm_ahb_hibp_err_rd),
  .ibp_rd_data               (slv_o_dccm_ahb_hibp_rd_data),
  .ibp_rd_last               (slv_o_dccm_ahb_hibp_rd_last),

  .ibp_wr_valid              (slv_o_dccm_ahb_hibp_wr_valid),
  .ibp_wr_accept             (slv_o_dccm_ahb_hibp_wr_accept),
  .ibp_wr_data               (slv_o_dccm_ahb_hibp_wr_data),
  .ibp_wr_mask               (slv_o_dccm_ahb_hibp_wr_mask),
  .ibp_wr_last               (slv_o_dccm_ahb_hibp_wr_last),

  .ibp_wr_done               (slv_o_dccm_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (slv_o_dccm_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (slv_o_dccm_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_dccm_ahb_hibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_dccm_ahb_hibp_cmd_region)
                           );
      //
      // current slave prefix is mmio_ahb_h, cfree attr is 0, ratio attr is 1
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_mmio_ahb_h_ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_mmio_ahb_hibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_mmio_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_mmio_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (bs_o_mmio_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (bs_o_mmio_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_mmio_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_mmio_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_mmio_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_mmio_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_mmio_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_mmio_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_mmio_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (bs_o_mmio_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_mmio_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_mmio_ahb_hibp_rd_accept),
  .ibp_err_rd                (bs_o_mmio_ahb_hibp_err_rd),
  .ibp_rd_data               (bs_o_mmio_ahb_hibp_rd_data),
  .ibp_rd_last               (bs_o_mmio_ahb_hibp_rd_last),

  .ibp_wr_valid              (bs_o_mmio_ahb_hibp_wr_valid),
  .ibp_wr_accept             (bs_o_mmio_ahb_hibp_wr_accept),
  .ibp_wr_data               (bs_o_mmio_ahb_hibp_wr_data),
  .ibp_wr_mask               (bs_o_mmio_ahb_hibp_wr_mask),
  .ibp_wr_last               (bs_o_mmio_ahb_hibp_wr_last),

  .ibp_wr_done               (bs_o_mmio_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (bs_o_mmio_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (bs_o_mmio_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_mmio_ahb_hibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_mmio_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_mmio_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_mmio_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_mmio_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_mmio_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_mmio_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_mmio_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_mmio_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_mmio_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_mmio_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_mmio_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_mmio_ahb_hibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_mmio_ahb_hibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // bypass the signals from bus_switch to slave port
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_mmio_ahb_h_ibp_buffer_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_mmio_ahb_hibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_mmio_ahb_hibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_mmio_ahb_hibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_mmio_ahb_hibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_mmio_ahb_hibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_mmio_ahb_hibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_mmio_ahb_hibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_mmio_ahb_hibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_mmio_ahb_hibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_mmio_ahb_hibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_mmio_ahb_hibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_mmio_ahb_hibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_mmio_ahb_hibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_mmio_ahb_hibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_mmio_ahb_hibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_mmio_ahb_hibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_mmio_ahb_hibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_mmio_ahb_hibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_mmio_ahb_hibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_mmio_ahb_hibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_mmio_ahb_hibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_mmio_ahb_hibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_mmio_ahb_hibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_mmio_ahb_hibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_mmio_ahb_hibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_mmio_ahb_hibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_mmio_ahb_h_pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_mmio_ahb_hibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_mmio_ahb_hibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_mmio_ahb_hibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_mmio_ahb_hibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_mmio_ahb_hibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_mmio_ahb_hibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_mmio_ahb_hibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_mmio_ahb_hibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_mmio_ahb_hibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_mmio_ahb_hibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_mmio_ahb_hibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_mmio_ahb_hibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_mmio_ahb_hibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_mmio_ahb_hibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_mmio_ahb_hibp_cmd_accept),
  .ibp_cmd_read              (slv_o_mmio_ahb_hibp_cmd_read),
  .ibp_cmd_addr              (slv_o_mmio_ahb_hibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_mmio_ahb_hibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_mmio_ahb_hibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_mmio_ahb_hibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_mmio_ahb_hibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_mmio_ahb_hibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_mmio_ahb_hibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_mmio_ahb_hibp_cmd_excl),

  .ibp_rd_valid              (slv_o_mmio_ahb_hibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_mmio_ahb_hibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_mmio_ahb_hibp_rd_accept),
  .ibp_err_rd                (slv_o_mmio_ahb_hibp_err_rd),
  .ibp_rd_data               (slv_o_mmio_ahb_hibp_rd_data),
  .ibp_rd_last               (slv_o_mmio_ahb_hibp_rd_last),

  .ibp_wr_valid              (slv_o_mmio_ahb_hibp_wr_valid),
  .ibp_wr_accept             (slv_o_mmio_ahb_hibp_wr_accept),
  .ibp_wr_data               (slv_o_mmio_ahb_hibp_wr_data),
  .ibp_wr_mask               (slv_o_mmio_ahb_hibp_wr_mask),
  .ibp_wr_last               (slv_o_mmio_ahb_hibp_wr_last),

  .ibp_wr_done               (slv_o_mmio_ahb_hibp_wr_done),
  .ibp_wr_excl_done          (slv_o_mmio_ahb_hibp_wr_excl_done),
  .ibp_err_wr                (slv_o_mmio_ahb_hibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_mmio_ahb_hibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_mmio_ahb_hibp_cmd_region)
                           );
      //
      // current slave prefix is mss_clkctrl_, cfree attr is 0, ratio attr is 0
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(22),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_mss_clkctrl__ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_mss_clkctrl_ibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_mss_clkctrl_ibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_mss_clkctrl_ibp_cmd_accept),
  .ibp_cmd_read              (bs_o_mss_clkctrl_ibp_cmd_read),
  .ibp_cmd_addr              (bs_o_mss_clkctrl_ibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_mss_clkctrl_ibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_mss_clkctrl_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_mss_clkctrl_ibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_mss_clkctrl_ibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_mss_clkctrl_ibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_mss_clkctrl_ibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_mss_clkctrl_ibp_cmd_excl),

  .ibp_rd_valid              (bs_o_mss_clkctrl_ibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_mss_clkctrl_ibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_mss_clkctrl_ibp_rd_accept),
  .ibp_err_rd                (bs_o_mss_clkctrl_ibp_err_rd),
  .ibp_rd_data               (bs_o_mss_clkctrl_ibp_rd_data),
  .ibp_rd_last               (bs_o_mss_clkctrl_ibp_rd_last),

  .ibp_wr_valid              (bs_o_mss_clkctrl_ibp_wr_valid),
  .ibp_wr_accept             (bs_o_mss_clkctrl_ibp_wr_accept),
  .ibp_wr_data               (bs_o_mss_clkctrl_ibp_wr_data),
  .ibp_wr_mask               (bs_o_mss_clkctrl_ibp_wr_mask),
  .ibp_wr_last               (bs_o_mss_clkctrl_ibp_wr_last),

  .ibp_wr_done               (bs_o_mss_clkctrl_ibp_wr_done),
  .ibp_wr_excl_done          (bs_o_mss_clkctrl_ibp_wr_excl_done),
  .ibp_err_wr                (bs_o_mss_clkctrl_ibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_mss_clkctrl_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_mss_clkctrl_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_mss_clkctrl_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_mss_clkctrl_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_mss_clkctrl_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_mss_clkctrl_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_mss_clkctrl_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_mss_clkctrl_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_mss_clkctrl_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_mss_clkctrl_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_mss_clkctrl_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_mss_clkctrl_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_mss_clkctrl_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_mss_clkctrl_ibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // use fabric's clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(1),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_mss_clkctrl__ibp_buffer_0_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_mss_clkctrl_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_mss_clkctrl_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_mss_clkctrl_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_mss_clkctrl_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_mss_clkctrl_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_mss_clkctrl_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_mss_clkctrl_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_mss_clkctrl_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_mss_clkctrl_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_mss_clkctrl_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_mss_clkctrl_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_mss_clkctrl_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_mss_clkctrl_ibp_wrsp_chnl),

                             .o_ibp_clk_en(mss_fab_slv3_clk_en),
                             .o_ibp_cmd_chnl_rgon(slv_i_mss_clkctrl_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_i_mss_clkctrl_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_i_mss_clkctrl_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_i_mss_clkctrl_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_i_mss_clkctrl_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_i_mss_clkctrl_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_i_mss_clkctrl_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_i_mss_clkctrl_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_i_mss_clkctrl_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_i_mss_clkctrl_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_i_mss_clkctrl_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_i_mss_clkctrl_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_i_mss_clkctrl_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // use slave's clock (with prefix mss_clkctrl_) and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(1),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_mss_clkctrl__ibp_buffer_1_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(slv_i_mss_clkctrl_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (slv_i_mss_clkctrl_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (slv_i_mss_clkctrl_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (slv_i_mss_clkctrl_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (slv_i_mss_clkctrl_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (slv_i_mss_clkctrl_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (slv_i_mss_clkctrl_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (slv_i_mss_clkctrl_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (slv_i_mss_clkctrl_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (slv_i_mss_clkctrl_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (slv_i_mss_clkctrl_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(slv_i_mss_clkctrl_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (slv_i_mss_clkctrl_ibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_mss_clkctrl_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_mss_clkctrl_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_mss_clkctrl_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_mss_clkctrl_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_mss_clkctrl_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_mss_clkctrl_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_mss_clkctrl_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_mss_clkctrl_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_mss_clkctrl_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_mss_clkctrl_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_mss_clkctrl_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_mss_clkctrl_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_mss_clkctrl_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );
    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(22),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_mss_clkctrl__pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_mss_clkctrl_ibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_mss_clkctrl_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_mss_clkctrl_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_mss_clkctrl_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_mss_clkctrl_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_mss_clkctrl_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_mss_clkctrl_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_mss_clkctrl_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_mss_clkctrl_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_mss_clkctrl_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_mss_clkctrl_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_mss_clkctrl_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_mss_clkctrl_ibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_mss_clkctrl_ibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_mss_clkctrl_ibp_cmd_accept),
  .ibp_cmd_read              (slv_o_mss_clkctrl_ibp_cmd_read),
  .ibp_cmd_addr              (slv_o_mss_clkctrl_ibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_mss_clkctrl_ibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_mss_clkctrl_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_mss_clkctrl_ibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_mss_clkctrl_ibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_mss_clkctrl_ibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_mss_clkctrl_ibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_mss_clkctrl_ibp_cmd_excl),

  .ibp_rd_valid              (slv_o_mss_clkctrl_ibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_mss_clkctrl_ibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_mss_clkctrl_ibp_rd_accept),
  .ibp_err_rd                (slv_o_mss_clkctrl_ibp_err_rd),
  .ibp_rd_data               (slv_o_mss_clkctrl_ibp_rd_data),
  .ibp_rd_last               (slv_o_mss_clkctrl_ibp_rd_last),

  .ibp_wr_valid              (slv_o_mss_clkctrl_ibp_wr_valid),
  .ibp_wr_accept             (slv_o_mss_clkctrl_ibp_wr_accept),
  .ibp_wr_data               (slv_o_mss_clkctrl_ibp_wr_data),
  .ibp_wr_mask               (slv_o_mss_clkctrl_ibp_wr_mask),
  .ibp_wr_last               (slv_o_mss_clkctrl_ibp_wr_last),

  .ibp_wr_done               (slv_o_mss_clkctrl_ibp_wr_done),
  .ibp_wr_excl_done          (slv_o_mss_clkctrl_ibp_wr_excl_done),
  .ibp_err_wr                (slv_o_mss_clkctrl_ibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_mss_clkctrl_ibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_mss_clkctrl_ibp_cmd_region)
                           );

      //
      // current slave prefix is dslv1_, cfree attr is 0, ratio attr is 0
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(22),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dslv1__ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_dslv1_ibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_dslv1_ibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_dslv1_ibp_cmd_accept),
  .ibp_cmd_read              (bs_o_dslv1_ibp_cmd_read),
  .ibp_cmd_addr              (bs_o_dslv1_ibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_dslv1_ibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_dslv1_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_dslv1_ibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_dslv1_ibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_dslv1_ibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_dslv1_ibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_dslv1_ibp_cmd_excl),

  .ibp_rd_valid              (bs_o_dslv1_ibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_dslv1_ibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_dslv1_ibp_rd_accept),
  .ibp_err_rd                (bs_o_dslv1_ibp_err_rd),
  .ibp_rd_data               (bs_o_dslv1_ibp_rd_data),
  .ibp_rd_last               (bs_o_dslv1_ibp_rd_last),

  .ibp_wr_valid              (bs_o_dslv1_ibp_wr_valid),
  .ibp_wr_accept             (bs_o_dslv1_ibp_wr_accept),
  .ibp_wr_data               (bs_o_dslv1_ibp_wr_data),
  .ibp_wr_mask               (bs_o_dslv1_ibp_wr_mask),
  .ibp_wr_last               (bs_o_dslv1_ibp_wr_last),

  .ibp_wr_done               (bs_o_dslv1_ibp_wr_done),
  .ibp_wr_excl_done          (bs_o_dslv1_ibp_wr_excl_done),
  .ibp_err_wr                (bs_o_dslv1_ibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_dslv1_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_dslv1_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_dslv1_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_dslv1_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_dslv1_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_dslv1_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_dslv1_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_dslv1_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_dslv1_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_dslv1_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_dslv1_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_dslv1_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_dslv1_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_dslv1_ibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // use fabric's clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(1),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_dslv1__ibp_buffer_0_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_dslv1_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_dslv1_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_dslv1_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_dslv1_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_dslv1_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_dslv1_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_dslv1_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_dslv1_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_dslv1_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_dslv1_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_dslv1_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_dslv1_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_dslv1_ibp_wrsp_chnl),

                             .o_ibp_clk_en(mss_fab_slv4_clk_en),
                             .o_ibp_cmd_chnl_rgon(slv_i_dslv1_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_i_dslv1_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_i_dslv1_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_i_dslv1_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_i_dslv1_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_i_dslv1_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_i_dslv1_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_i_dslv1_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_i_dslv1_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_i_dslv1_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_i_dslv1_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_i_dslv1_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_i_dslv1_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // use slave's clock (with prefix dslv1_) and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(1),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_dslv1__ibp_buffer_1_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(slv_i_dslv1_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (slv_i_dslv1_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (slv_i_dslv1_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (slv_i_dslv1_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (slv_i_dslv1_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (slv_i_dslv1_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (slv_i_dslv1_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (slv_i_dslv1_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (slv_i_dslv1_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (slv_i_dslv1_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (slv_i_dslv1_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(slv_i_dslv1_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (slv_i_dslv1_ibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_dslv1_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_dslv1_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_dslv1_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_dslv1_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_dslv1_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_dslv1_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_dslv1_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_dslv1_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_dslv1_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_dslv1_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_dslv1_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_dslv1_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_dslv1_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );
    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(22),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (22),
    .CMD_CHNL_W              (39),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dslv1__pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_dslv1_ibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_dslv1_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_dslv1_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_dslv1_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_dslv1_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_dslv1_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_dslv1_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_dslv1_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_dslv1_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_dslv1_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_dslv1_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_dslv1_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_dslv1_ibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_dslv1_ibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_dslv1_ibp_cmd_accept),
  .ibp_cmd_read              (slv_o_dslv1_ibp_cmd_read),
  .ibp_cmd_addr              (slv_o_dslv1_ibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_dslv1_ibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_dslv1_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_dslv1_ibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_dslv1_ibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_dslv1_ibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_dslv1_ibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_dslv1_ibp_cmd_excl),

  .ibp_rd_valid              (slv_o_dslv1_ibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_dslv1_ibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_dslv1_ibp_rd_accept),
  .ibp_err_rd                (slv_o_dslv1_ibp_err_rd),
  .ibp_rd_data               (slv_o_dslv1_ibp_rd_data),
  .ibp_rd_last               (slv_o_dslv1_ibp_rd_last),

  .ibp_wr_valid              (slv_o_dslv1_ibp_wr_valid),
  .ibp_wr_accept             (slv_o_dslv1_ibp_wr_accept),
  .ibp_wr_data               (slv_o_dslv1_ibp_wr_data),
  .ibp_wr_mask               (slv_o_dslv1_ibp_wr_mask),
  .ibp_wr_last               (slv_o_dslv1_ibp_wr_last),

  .ibp_wr_done               (slv_o_dslv1_ibp_wr_done),
  .ibp_wr_excl_done          (slv_o_dslv1_ibp_wr_excl_done),
  .ibp_err_wr                (slv_o_dslv1_ibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_dslv1_ibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_dslv1_ibp_cmd_region)
                           );

      //
      // current slave prefix is dslv2_, cfree attr is 0, ratio attr is 0
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(34),
                           .DATA_W(64),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (34),
    .CMD_CHNL_W              (51),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (64),
    .WD_CHNL_MASK_LSB        (65),
    .WD_CHNL_MASK_W          (8),
    .WD_CHNL_W               (73),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (64),
    .RD_CHNL_W               (67),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dslv2__ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_dslv2_ibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_dslv2_ibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_dslv2_ibp_cmd_accept),
  .ibp_cmd_read              (bs_o_dslv2_ibp_cmd_read),
  .ibp_cmd_addr              (bs_o_dslv2_ibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_dslv2_ibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_dslv2_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_dslv2_ibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_dslv2_ibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_dslv2_ibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_dslv2_ibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_dslv2_ibp_cmd_excl),

  .ibp_rd_valid              (bs_o_dslv2_ibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_dslv2_ibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_dslv2_ibp_rd_accept),
  .ibp_err_rd                (bs_o_dslv2_ibp_err_rd),
  .ibp_rd_data               (bs_o_dslv2_ibp_rd_data),
  .ibp_rd_last               (bs_o_dslv2_ibp_rd_last),

  .ibp_wr_valid              (bs_o_dslv2_ibp_wr_valid),
  .ibp_wr_accept             (bs_o_dslv2_ibp_wr_accept),
  .ibp_wr_data               (bs_o_dslv2_ibp_wr_data),
  .ibp_wr_mask               (bs_o_dslv2_ibp_wr_mask),
  .ibp_wr_last               (bs_o_dslv2_ibp_wr_last),

  .ibp_wr_done               (bs_o_dslv2_ibp_wr_done),
  .ibp_wr_excl_done          (bs_o_dslv2_ibp_wr_excl_done),
  .ibp_err_wr                (bs_o_dslv2_ibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_dslv2_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_dslv2_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_dslv2_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_dslv2_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_dslv2_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_dslv2_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_dslv2_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_dslv2_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_dslv2_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_dslv2_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_dslv2_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_dslv2_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_dslv2_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_dslv2_ibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // use fabric's clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(1),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (34),
    .CMD_CHNL_W              (51),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (64),
    .WD_CHNL_MASK_LSB        (65),
    .WD_CHNL_MASK_W          (8),
    .WD_CHNL_W               (73),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (64),
    .RD_CHNL_W               (67),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_dslv2__ibp_buffer_0_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_dslv2_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_dslv2_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_dslv2_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_dslv2_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_dslv2_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_dslv2_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_dslv2_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_dslv2_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_dslv2_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_dslv2_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_dslv2_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_dslv2_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_dslv2_ibp_wrsp_chnl),

                             .o_ibp_clk_en(mss_fab_slv5_clk_en),
                             .o_ibp_cmd_chnl_rgon(slv_i_dslv2_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_i_dslv2_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_i_dslv2_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_i_dslv2_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_i_dslv2_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_i_dslv2_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_i_dslv2_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_i_dslv2_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_i_dslv2_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_i_dslv2_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_i_dslv2_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_i_dslv2_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_i_dslv2_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // use slave's clock (with prefix dslv2_) and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(1),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (34),
    .CMD_CHNL_W              (51),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (64),
    .WD_CHNL_MASK_LSB        (65),
    .WD_CHNL_MASK_W          (8),
    .WD_CHNL_W               (73),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (64),
    .RD_CHNL_W               (67),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_dslv2__ibp_buffer_1_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(slv_i_dslv2_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (slv_i_dslv2_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (slv_i_dslv2_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (slv_i_dslv2_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (slv_i_dslv2_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (slv_i_dslv2_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (slv_i_dslv2_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (slv_i_dslv2_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (slv_i_dslv2_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (slv_i_dslv2_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (slv_i_dslv2_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(slv_i_dslv2_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (slv_i_dslv2_ibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_dslv2_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_dslv2_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_dslv2_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_dslv2_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_dslv2_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_dslv2_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_dslv2_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_dslv2_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_dslv2_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_dslv2_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_dslv2_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_dslv2_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_dslv2_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );
    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(34),
                           .DATA_W(64),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (34),
    .CMD_CHNL_W              (51),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (64),
    .WD_CHNL_MASK_LSB        (65),
    .WD_CHNL_MASK_W          (8),
    .WD_CHNL_W               (73),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (64),
    .RD_CHNL_W               (67),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_dslv2__pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_dslv2_ibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_dslv2_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_dslv2_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_dslv2_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_dslv2_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_dslv2_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_dslv2_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_dslv2_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_dslv2_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_dslv2_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_dslv2_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_dslv2_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_dslv2_ibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_dslv2_ibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_dslv2_ibp_cmd_accept),
  .ibp_cmd_read              (slv_o_dslv2_ibp_cmd_read),
  .ibp_cmd_addr              (slv_o_dslv2_ibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_dslv2_ibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_dslv2_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_dslv2_ibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_dslv2_ibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_dslv2_ibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_dslv2_ibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_dslv2_ibp_cmd_excl),

  .ibp_rd_valid              (slv_o_dslv2_ibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_dslv2_ibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_dslv2_ibp_rd_accept),
  .ibp_err_rd                (slv_o_dslv2_ibp_err_rd),
  .ibp_rd_data               (slv_o_dslv2_ibp_rd_data),
  .ibp_rd_last               (slv_o_dslv2_ibp_rd_last),

  .ibp_wr_valid              (slv_o_dslv2_ibp_wr_valid),
  .ibp_wr_accept             (slv_o_dslv2_ibp_wr_accept),
  .ibp_wr_data               (slv_o_dslv2_ibp_wr_data),
  .ibp_wr_mask               (slv_o_dslv2_ibp_wr_mask),
  .ibp_wr_last               (slv_o_dslv2_ibp_wr_last),

  .ibp_wr_done               (slv_o_dslv2_ibp_wr_done),
  .ibp_wr_excl_done          (slv_o_dslv2_ibp_wr_excl_done),
  .ibp_err_wr                (slv_o_dslv2_ibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_dslv2_ibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_dslv2_ibp_cmd_region)
                           );

      //
      // current slave prefix is mss_perfctrl_, cfree attr is 0, ratio attr is 0
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(23),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (23),
    .CMD_CHNL_W              (40),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_mss_perfctrl__ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_mss_perfctrl_ibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_mss_perfctrl_ibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_mss_perfctrl_ibp_cmd_accept),
  .ibp_cmd_read              (bs_o_mss_perfctrl_ibp_cmd_read),
  .ibp_cmd_addr              (bs_o_mss_perfctrl_ibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_mss_perfctrl_ibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_mss_perfctrl_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_mss_perfctrl_ibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_mss_perfctrl_ibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_mss_perfctrl_ibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_mss_perfctrl_ibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_mss_perfctrl_ibp_cmd_excl),

  .ibp_rd_valid              (bs_o_mss_perfctrl_ibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_mss_perfctrl_ibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_mss_perfctrl_ibp_rd_accept),
  .ibp_err_rd                (bs_o_mss_perfctrl_ibp_err_rd),
  .ibp_rd_data               (bs_o_mss_perfctrl_ibp_rd_data),
  .ibp_rd_last               (bs_o_mss_perfctrl_ibp_rd_last),

  .ibp_wr_valid              (bs_o_mss_perfctrl_ibp_wr_valid),
  .ibp_wr_accept             (bs_o_mss_perfctrl_ibp_wr_accept),
  .ibp_wr_data               (bs_o_mss_perfctrl_ibp_wr_data),
  .ibp_wr_mask               (bs_o_mss_perfctrl_ibp_wr_mask),
  .ibp_wr_last               (bs_o_mss_perfctrl_ibp_wr_last),

  .ibp_wr_done               (bs_o_mss_perfctrl_ibp_wr_done),
  .ibp_wr_excl_done          (bs_o_mss_perfctrl_ibp_wr_excl_done),
  .ibp_err_wr                (bs_o_mss_perfctrl_ibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_mss_perfctrl_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_mss_perfctrl_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_mss_perfctrl_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_mss_perfctrl_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_mss_perfctrl_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_mss_perfctrl_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_mss_perfctrl_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_mss_perfctrl_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_mss_perfctrl_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_mss_perfctrl_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_mss_perfctrl_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_mss_perfctrl_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_mss_perfctrl_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_mss_perfctrl_ibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // use fabric's clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(1),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (23),
    .CMD_CHNL_W              (40),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_mss_perfctrl__ibp_buffer_0_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_mss_perfctrl_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_mss_perfctrl_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_mss_perfctrl_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_mss_perfctrl_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_mss_perfctrl_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_mss_perfctrl_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_mss_perfctrl_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_mss_perfctrl_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_mss_perfctrl_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_mss_perfctrl_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_mss_perfctrl_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_mss_perfctrl_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_mss_perfctrl_ibp_wrsp_chnl),

                             .o_ibp_clk_en(mss_fab_slv6_clk_en),
                             .o_ibp_cmd_chnl_rgon(slv_i_mss_perfctrl_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_i_mss_perfctrl_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_i_mss_perfctrl_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_i_mss_perfctrl_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_i_mss_perfctrl_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_i_mss_perfctrl_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_i_mss_perfctrl_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_i_mss_perfctrl_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_i_mss_perfctrl_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_i_mss_perfctrl_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_i_mss_perfctrl_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_i_mss_perfctrl_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_i_mss_perfctrl_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // use slave's clock (with prefix mss_perfctrl_) and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(1),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (23),
    .CMD_CHNL_W              (40),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                             .RGON_W(1),
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_mss_perfctrl__ibp_buffer_1_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(slv_i_mss_perfctrl_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (slv_i_mss_perfctrl_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (slv_i_mss_perfctrl_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (slv_i_mss_perfctrl_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (slv_i_mss_perfctrl_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (slv_i_mss_perfctrl_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (slv_i_mss_perfctrl_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (slv_i_mss_perfctrl_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (slv_i_mss_perfctrl_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (slv_i_mss_perfctrl_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (slv_i_mss_perfctrl_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(slv_i_mss_perfctrl_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (slv_i_mss_perfctrl_ibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_mss_perfctrl_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_mss_perfctrl_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_mss_perfctrl_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_mss_perfctrl_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_mss_perfctrl_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_mss_perfctrl_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_mss_perfctrl_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_mss_perfctrl_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_mss_perfctrl_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_mss_perfctrl_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_mss_perfctrl_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_mss_perfctrl_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_mss_perfctrl_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );
    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(23),
                           .DATA_W(32),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (23),
    .CMD_CHNL_W              (40),

    .WD_CHNL_LAST            (0),
    .WD_CHNL_DATA_LSB        (1),
    .WD_CHNL_DATA_W          (32),
    .WD_CHNL_MASK_LSB        (33),
    .WD_CHNL_MASK_W          (4),
    .WD_CHNL_W               (37),

    .RD_CHNL_ERR_RD          (0),
    .RD_CHNL_RD_EXCL_OK      (2),
    .RD_CHNL_RD_LAST         (1),
    .RD_CHNL_RD_DATA_LSB     (3),
    .RD_CHNL_RD_DATA_W       (32),
    .RD_CHNL_W               (35),

    .WRSP_CHNL_WR_DONE       (0),
    .WRSP_CHNL_WR_EXCL_DONE  (1),
    .WRSP_CHNL_ERR_WR        (2),
    .WRSP_CHNL_W             (3),
                           .RGON_W(1)
                           ) u_mss_perfctrl__pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_mss_perfctrl_ibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_mss_perfctrl_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_mss_perfctrl_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_mss_perfctrl_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_mss_perfctrl_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_mss_perfctrl_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_mss_perfctrl_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_mss_perfctrl_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_mss_perfctrl_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_mss_perfctrl_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_mss_perfctrl_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_mss_perfctrl_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_mss_perfctrl_ibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_mss_perfctrl_ibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_mss_perfctrl_ibp_cmd_accept),
  .ibp_cmd_read              (slv_o_mss_perfctrl_ibp_cmd_read),
  .ibp_cmd_addr              (slv_o_mss_perfctrl_ibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_mss_perfctrl_ibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_mss_perfctrl_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_mss_perfctrl_ibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_mss_perfctrl_ibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_mss_perfctrl_ibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_mss_perfctrl_ibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_mss_perfctrl_ibp_cmd_excl),

  .ibp_rd_valid              (slv_o_mss_perfctrl_ibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_mss_perfctrl_ibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_mss_perfctrl_ibp_rd_accept),
  .ibp_err_rd                (slv_o_mss_perfctrl_ibp_err_rd),
  .ibp_rd_data               (slv_o_mss_perfctrl_ibp_rd_data),
  .ibp_rd_last               (slv_o_mss_perfctrl_ibp_rd_last),

  .ibp_wr_valid              (slv_o_mss_perfctrl_ibp_wr_valid),
  .ibp_wr_accept             (slv_o_mss_perfctrl_ibp_wr_accept),
  .ibp_wr_data               (slv_o_mss_perfctrl_ibp_wr_data),
  .ibp_wr_mask               (slv_o_mss_perfctrl_ibp_wr_mask),
  .ibp_wr_last               (slv_o_mss_perfctrl_ibp_wr_last),

  .ibp_wr_done               (slv_o_mss_perfctrl_ibp_wr_done),
  .ibp_wr_excl_done          (slv_o_mss_perfctrl_ibp_wr_excl_done),
  .ibp_err_wr                (slv_o_mss_perfctrl_ibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_mss_perfctrl_ibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_mss_perfctrl_ibp_cmd_region)
                           );

      //
      // current slave prefix is mss_mem_, cfree attr is 0, ratio attr is 0
      //
    // pack the IBP interface
    alb_mss_fab_ibp2pack #(
                           .ADDR_W(42),
                           .DATA_W(128),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

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
                           ) u_mss_mem__ibp2pack_inst(
                           .ibp_cmd_rgon(bs_o_mss_mem_ibp_cmd_region),
                           .ibp_cmd_user(1'b0),

  .ibp_cmd_valid             (bs_o_mss_mem_ibp_cmd_valid),
  .ibp_cmd_accept            (bs_o_mss_mem_ibp_cmd_accept),
  .ibp_cmd_read              (bs_o_mss_mem_ibp_cmd_read),
  .ibp_cmd_addr              (bs_o_mss_mem_ibp_cmd_addr),
  .ibp_cmd_wrap              (bs_o_mss_mem_ibp_cmd_wrap),
  .ibp_cmd_data_size         (bs_o_mss_mem_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (bs_o_mss_mem_ibp_cmd_burst_size),
  .ibp_cmd_prot              (bs_o_mss_mem_ibp_cmd_prot),
  .ibp_cmd_cache             (bs_o_mss_mem_ibp_cmd_cache),
  .ibp_cmd_lock              (bs_o_mss_mem_ibp_cmd_lock),
  .ibp_cmd_excl              (bs_o_mss_mem_ibp_cmd_excl),

  .ibp_rd_valid              (bs_o_mss_mem_ibp_rd_valid),
  .ibp_rd_excl_ok            (bs_o_mss_mem_ibp_rd_excl_ok),
  .ibp_rd_accept             (bs_o_mss_mem_ibp_rd_accept),
  .ibp_err_rd                (bs_o_mss_mem_ibp_err_rd),
  .ibp_rd_data               (bs_o_mss_mem_ibp_rd_data),
  .ibp_rd_last               (bs_o_mss_mem_ibp_rd_last),

  .ibp_wr_valid              (bs_o_mss_mem_ibp_wr_valid),
  .ibp_wr_accept             (bs_o_mss_mem_ibp_wr_accept),
  .ibp_wr_data               (bs_o_mss_mem_ibp_wr_data),
  .ibp_wr_mask               (bs_o_mss_mem_ibp_wr_mask),
  .ibp_wr_last               (bs_o_mss_mem_ibp_wr_last),

  .ibp_wr_done               (bs_o_mss_mem_ibp_wr_done),
  .ibp_wr_excl_done          (bs_o_mss_mem_ibp_wr_excl_done),
  .ibp_err_wr                (bs_o_mss_mem_ibp_err_wr),
  .ibp_wr_resp_accept        (bs_o_mss_mem_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (bs_o_mss_mem_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bs_o_mss_mem_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bs_o_mss_mem_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bs_o_mss_mem_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bs_o_mss_mem_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (bs_o_mss_mem_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (bs_o_mss_mem_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bs_o_mss_mem_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (bs_o_mss_mem_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bs_o_mss_mem_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bs_o_mss_mem_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bs_o_mss_mem_ibp_wrsp_chnl),

                           .ibp_cmd_chnl_rgon(bs_o_mss_mem_ibp_cmd_chnl_region),
                           .ibp_cmd_chnl_user(),
                           .clk(mss_clk),
                           .rst_a(~rst_b)
                           );
    // use fabric's clock and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(0),
                             .O_IBP_SUPPORT_RTIO(1),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

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
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_mss_mem__ibp_buffer_0_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(bs_o_mss_mem_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (bs_o_mss_mem_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (bs_o_mss_mem_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (bs_o_mss_mem_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (bs_o_mss_mem_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (bs_o_mss_mem_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (bs_o_mss_mem_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (bs_o_mss_mem_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (bs_o_mss_mem_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (bs_o_mss_mem_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (bs_o_mss_mem_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(bs_o_mss_mem_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (bs_o_mss_mem_ibp_wrsp_chnl),

                             .o_ibp_clk_en(mss_fab_slv7_clk_en),
                             .o_ibp_cmd_chnl_rgon(slv_i_mss_mem_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_i_mss_mem_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_i_mss_mem_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_i_mss_mem_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_i_mss_mem_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_i_mss_mem_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_i_mss_mem_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_i_mss_mem_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_i_mss_mem_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_i_mss_mem_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_i_mss_mem_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_i_mss_mem_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_i_mss_mem_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );

    // use slave's clock (with prefix mss_mem_) and clk_en for sampling
    alb_mss_fab_ibp_buffer #(.I_IBP_SUPPORT_RTIO(1),
                             .O_IBP_SUPPORT_RTIO(0),
                             .OUTSTAND_NUM(64),
                             .OUTSTAND_CNT_W(6),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

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
                             .USER_W(1),
                             .CMD_CHNL_FIFO_MWHILE(0),
                             .WDATA_CHNL_FIFO_MWHILE(0),
                             .RDATA_CHNL_FIFO_MWHILE(0),
                             .WRESP_CHNL_FIFO_MWHILE(0),
                             .CMD_CHNL_FIFO_DEPTH(0),
                             .WDATA_CHNL_FIFO_DEPTH(0),
                             .RDATA_CHNL_FIFO_DEPTH(0),
                             .WRESP_CHNL_FIFO_DEPTH(0)
                             ) u_mss_mem__ibp_buffer_1_inst (
                             .i_ibp_clk_en(1'b1),
                             .i_ibp_cmd_chnl_rgon(slv_i_mss_mem_ibp_cmd_chnl_region),



    .i_ibp_cmd_chnl_valid  (slv_i_mss_mem_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (slv_i_mss_mem_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (slv_i_mss_mem_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (slv_i_mss_mem_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (slv_i_mss_mem_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (slv_i_mss_mem_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (slv_i_mss_mem_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (slv_i_mss_mem_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (slv_i_mss_mem_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (slv_i_mss_mem_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(slv_i_mss_mem_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (slv_i_mss_mem_ibp_wrsp_chnl),

                             .o_ibp_clk_en(1'b1),
                             .o_ibp_cmd_chnl_rgon(slv_o_mss_mem_ibp_cmd_chnl_region),
                             .i_ibp_cmd_chnl_user(1'b0),
                             .o_ibp_cmd_chnl_user(),



    .o_ibp_cmd_chnl_valid  (slv_o_mss_mem_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (slv_o_mss_mem_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (slv_o_mss_mem_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (slv_o_mss_mem_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (slv_o_mss_mem_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (slv_o_mss_mem_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (slv_o_mss_mem_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (slv_o_mss_mem_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (slv_o_mss_mem_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (slv_o_mss_mem_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(slv_o_mss_mem_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (slv_o_mss_mem_ibp_wrsp_chnl),

                             .ibp_buffer_idle(),
                             .clk(mss_clk),
                             .rst_a(~rst_b)
                             );
    // unpack the IBP interface
    alb_mss_fab_pack2ibp #(
                           .ADDR_W(42),
                           .DATA_W(128),
                           .USER_W(1),



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
    .CMD_CHNL_ADDR_W         (42),
    .CMD_CHNL_W              (59),

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
                           ) u_mss_mem__pack2ibp_inst(
                           .ibp_cmd_chnl_user(1'b0),
                           .ibp_cmd_chnl_rgon(slv_o_mss_mem_ibp_cmd_chnl_region),



    .ibp_cmd_chnl_valid  (slv_o_mss_mem_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (slv_o_mss_mem_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (slv_o_mss_mem_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (slv_o_mss_mem_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (slv_o_mss_mem_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (slv_o_mss_mem_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (slv_o_mss_mem_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (slv_o_mss_mem_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (slv_o_mss_mem_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (slv_o_mss_mem_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(slv_o_mss_mem_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (slv_o_mss_mem_ibp_wrsp_chnl),


  .ibp_cmd_valid             (slv_o_mss_mem_ibp_cmd_valid),
  .ibp_cmd_accept            (slv_o_mss_mem_ibp_cmd_accept),
  .ibp_cmd_read              (slv_o_mss_mem_ibp_cmd_read),
  .ibp_cmd_addr              (slv_o_mss_mem_ibp_cmd_addr),
  .ibp_cmd_wrap              (slv_o_mss_mem_ibp_cmd_wrap),
  .ibp_cmd_data_size         (slv_o_mss_mem_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (slv_o_mss_mem_ibp_cmd_burst_size),
  .ibp_cmd_prot              (slv_o_mss_mem_ibp_cmd_prot),
  .ibp_cmd_cache             (slv_o_mss_mem_ibp_cmd_cache),
  .ibp_cmd_lock              (slv_o_mss_mem_ibp_cmd_lock),
  .ibp_cmd_excl              (slv_o_mss_mem_ibp_cmd_excl),

  .ibp_rd_valid              (slv_o_mss_mem_ibp_rd_valid),
  .ibp_rd_excl_ok            (slv_o_mss_mem_ibp_rd_excl_ok),
  .ibp_rd_accept             (slv_o_mss_mem_ibp_rd_accept),
  .ibp_err_rd                (slv_o_mss_mem_ibp_err_rd),
  .ibp_rd_data               (slv_o_mss_mem_ibp_rd_data),
  .ibp_rd_last               (slv_o_mss_mem_ibp_rd_last),

  .ibp_wr_valid              (slv_o_mss_mem_ibp_wr_valid),
  .ibp_wr_accept             (slv_o_mss_mem_ibp_wr_accept),
  .ibp_wr_data               (slv_o_mss_mem_ibp_wr_data),
  .ibp_wr_mask               (slv_o_mss_mem_ibp_wr_mask),
  .ibp_wr_last               (slv_o_mss_mem_ibp_wr_last),

  .ibp_wr_done               (slv_o_mss_mem_ibp_wr_done),
  .ibp_wr_excl_done          (slv_o_mss_mem_ibp_wr_excl_done),
  .ibp_err_wr                (slv_o_mss_mem_ibp_err_wr),
  .ibp_wr_resp_accept        (slv_o_mss_mem_ibp_wr_resp_accept),
                           .ibp_cmd_user(),
                           .ibp_cmd_rgon(slv_o_mss_mem_ibp_cmd_region)
                           );


    // Output protocol converters

    alb_mss_fab_ibp2ahbl_sel #(
                               .CHNL_FIFO_DEPTH(2),
                               .ADDR_W(32),
                               .DATA_W(32),
                               .ALSB(2),
                               .RGON_W(1),
                               .L_W(1)) u_iccm_ahb_hprot_inst(
                                                    .clk(mss_clk),
                                                    .bus_clk_en(mss_fab_slv0_clk_en),
                                                    .rst_a(~rst_b),
                                                    .bigendian(1'b0),
                                                    //IBP I/F
                                                    .ibp_cmd_region(slv_o_iccm_ahb_hibp_cmd_region),
                                                    .ibp_cmd_valid(slv_o_iccm_ahb_hibp_cmd_valid),
                                                    .ibp_cmd_accept(slv_o_iccm_ahb_hibp_cmd_accept),
                                                    .ibp_cmd_read(slv_o_iccm_ahb_hibp_cmd_read),
                                                    .ibp_cmd_addr(slv_o_iccm_ahb_hibp_cmd_addr[32-1:0]),
                                                    .ibp_cmd_wrap(slv_o_iccm_ahb_hibp_cmd_wrap),
                                                    .ibp_cmd_data_size(slv_o_iccm_ahb_hibp_cmd_data_size),
                                                    .ibp_cmd_burst_size(slv_o_iccm_ahb_hibp_cmd_burst_size),
                                                    .ibp_cmd_prot(slv_o_iccm_ahb_hibp_cmd_prot),
                                                    .ibp_cmd_cache(slv_o_iccm_ahb_hibp_cmd_cache),
                                                    .ibp_cmd_lock(slv_o_iccm_ahb_hibp_cmd_lock),
                                                    .ibp_cmd_excl(slv_o_iccm_ahb_hibp_cmd_excl),

                                                    .ibp_rd_valid(slv_o_iccm_ahb_hibp_rd_valid),
                                                    .ibp_rd_accept(slv_o_iccm_ahb_hibp_rd_accept),
                                                    .ibp_rd_data(slv_o_iccm_ahb_hibp_rd_data),
                                                    .ibp_err_rd(slv_o_iccm_ahb_hibp_err_rd),
                                                    .ibp_rd_last(slv_o_iccm_ahb_hibp_rd_last),
                                                    .ibp_rd_excl_ok(slv_o_iccm_ahb_hibp_rd_excl_ok),

                                                    .ibp_wr_valid(slv_o_iccm_ahb_hibp_wr_valid),
                                                    .ibp_wr_accept(slv_o_iccm_ahb_hibp_wr_accept),
                                                    .ibp_wr_data(slv_o_iccm_ahb_hibp_wr_data),
                                                    .ibp_wr_mask(slv_o_iccm_ahb_hibp_wr_mask),
                                                    .ibp_wr_last(slv_o_iccm_ahb_hibp_wr_last),

                                                    .ibp_wr_done(slv_o_iccm_ahb_hibp_wr_done),
                                                    .ibp_wr_excl_done(slv_o_iccm_ahb_hibp_wr_excl_done),
                                                    .ibp_err_wr(slv_o_iccm_ahb_hibp_err_wr),
                                                    .ibp_wr_resp_accept(slv_o_iccm_ahb_hibp_wr_resp_accept),
                                                    // AHB_Lite I/F
                                                    .ahb_hsel(iccm_ahb_hsel),
                                                    .ahb_htrans(iccm_ahb_htrans),
                                                    .ahb_hwrite(iccm_ahb_hwrite),
                                                    .ahb_haddr(iccm_ahb_haddr),
                                                    .ahb_hsize(iccm_ahb_hsize),
                                                    .ahb_hburst(iccm_ahb_hburst),
                                                    .ahb_hwdata(iccm_ahb_hwdata),
                                                    .ahb_hrdata(iccm_ahb_hrdata),
                                                    .ahb_hresp(iccm_ahb_hresp),
                                                    .ahb_hready_resp(iccm_ahb_hreadyout),
                                                    .ahb_hready(iccm_ahb_hready)
                                                    );

// ahb_parity

assign   iccm_ahb_haddrchk[0] = ~(^{iccm_ahb_haddr[7:2],2'b0});
assign iccm_ahb_haddrchk[1] = ~(^iccm_ahb_haddr[1*8 +: 8]);
assign iccm_ahb_haddrchk[2] = ~(^iccm_ahb_haddr[2*8 +: 8]);
assign iccm_ahb_haddrchk[3] = ~(^iccm_ahb_haddr[32-1 : 3*8]);
assign   iccm_ahb_htranschk = ~(^iccm_ahb_htrans);
assign   iccm_ahb_hctrlchk1 = ~(^{iccm_ahb_hburst, iccm_ahb_hwrite, iccm_ahb_hsize, 1'b0});
assign   iccm_ahb_hctrlchk2 = 1'b1;
assign   iccm_ahb_hwstrbchk = 1'b1;
assign   iccm_ahb_hprotchk =  1'b1;
assign   iccm_ahb_hreadychk = ~(^iccm_ahb_hready);
assign   iccm_ahb_hwdatachk[0] = ~(^iccm_ahb_hwdata[7:0]);
assign   iccm_ahb_hwdatachk[1] = ~(^iccm_ahb_hwdata[15:8]);
assign   iccm_ahb_hwdatachk[2] = ~(^iccm_ahb_hwdata[23:16]);
assign   iccm_ahb_hwdatachk[3] = ~(^iccm_ahb_hwdata[31:24]);


// ahb5 part


    alb_mss_fab_ibp2ahbl_sel #(
                               .CHNL_FIFO_DEPTH(2),
                               .ADDR_W(32),
                               .DATA_W(32),
                               .ALSB(2),
                               .RGON_W(1),
                               .L_W(1)) u_dccm_ahb_hprot_inst(
                                                    .clk(mss_clk),
                                                    .bus_clk_en(mss_fab_slv1_clk_en),
                                                    .rst_a(~rst_b),
                                                    .bigendian(1'b0),
                                                    //IBP I/F
                                                    .ibp_cmd_region(slv_o_dccm_ahb_hibp_cmd_region),
                                                    .ibp_cmd_valid(slv_o_dccm_ahb_hibp_cmd_valid),
                                                    .ibp_cmd_accept(slv_o_dccm_ahb_hibp_cmd_accept),
                                                    .ibp_cmd_read(slv_o_dccm_ahb_hibp_cmd_read),
                                                    .ibp_cmd_addr(slv_o_dccm_ahb_hibp_cmd_addr[32-1:0]),
                                                    .ibp_cmd_wrap(slv_o_dccm_ahb_hibp_cmd_wrap),
                                                    .ibp_cmd_data_size(slv_o_dccm_ahb_hibp_cmd_data_size),
                                                    .ibp_cmd_burst_size(slv_o_dccm_ahb_hibp_cmd_burst_size),
                                                    .ibp_cmd_prot(slv_o_dccm_ahb_hibp_cmd_prot),
                                                    .ibp_cmd_cache(slv_o_dccm_ahb_hibp_cmd_cache),
                                                    .ibp_cmd_lock(slv_o_dccm_ahb_hibp_cmd_lock),
                                                    .ibp_cmd_excl(slv_o_dccm_ahb_hibp_cmd_excl),

                                                    .ibp_rd_valid(slv_o_dccm_ahb_hibp_rd_valid),
                                                    .ibp_rd_accept(slv_o_dccm_ahb_hibp_rd_accept),
                                                    .ibp_rd_data(slv_o_dccm_ahb_hibp_rd_data),
                                                    .ibp_err_rd(slv_o_dccm_ahb_hibp_err_rd),
                                                    .ibp_rd_last(slv_o_dccm_ahb_hibp_rd_last),
                                                    .ibp_rd_excl_ok(slv_o_dccm_ahb_hibp_rd_excl_ok),

                                                    .ibp_wr_valid(slv_o_dccm_ahb_hibp_wr_valid),
                                                    .ibp_wr_accept(slv_o_dccm_ahb_hibp_wr_accept),
                                                    .ibp_wr_data(slv_o_dccm_ahb_hibp_wr_data),
                                                    .ibp_wr_mask(slv_o_dccm_ahb_hibp_wr_mask),
                                                    .ibp_wr_last(slv_o_dccm_ahb_hibp_wr_last),

                                                    .ibp_wr_done(slv_o_dccm_ahb_hibp_wr_done),
                                                    .ibp_wr_excl_done(slv_o_dccm_ahb_hibp_wr_excl_done),
                                                    .ibp_err_wr(slv_o_dccm_ahb_hibp_err_wr),
                                                    .ibp_wr_resp_accept(slv_o_dccm_ahb_hibp_wr_resp_accept),
                                                    // AHB_Lite I/F
                                                    .ahb_hsel(dccm_ahb_hsel),
                                                    .ahb_htrans(dccm_ahb_htrans),
                                                    .ahb_hwrite(dccm_ahb_hwrite),
                                                    .ahb_haddr(dccm_ahb_haddr),
                                                    .ahb_hsize(dccm_ahb_hsize),
                                                    .ahb_hburst(dccm_ahb_hburst),
                                                    .ahb_hwdata(dccm_ahb_hwdata),
                                                    .ahb_hrdata(dccm_ahb_hrdata),
                                                    .ahb_hresp(dccm_ahb_hresp),
                                                    .ahb_hready_resp(dccm_ahb_hreadyout),
                                                    .ahb_hready(dccm_ahb_hready)
                                                    );

// ahb_parity

assign   dccm_ahb_haddrchk[0] = ~(^{dccm_ahb_haddr[7:2],2'b0});
assign dccm_ahb_haddrchk[1] = ~(^dccm_ahb_haddr[1*8 +: 8]);
assign dccm_ahb_haddrchk[2] = ~(^dccm_ahb_haddr[2*8 +: 8]);
assign dccm_ahb_haddrchk[3] = ~(^dccm_ahb_haddr[32-1 : 3*8]);
assign   dccm_ahb_htranschk = ~(^dccm_ahb_htrans);
assign   dccm_ahb_hctrlchk1 = ~(^{dccm_ahb_hburst, dccm_ahb_hwrite, dccm_ahb_hsize, 1'b0});
assign   dccm_ahb_hctrlchk2 = 1'b1;
assign   dccm_ahb_hwstrbchk = 1'b1;
assign   dccm_ahb_hprotchk =  1'b1;
assign   dccm_ahb_hreadychk = ~(^dccm_ahb_hready);
assign   dccm_ahb_hwdatachk[0] = ~(^dccm_ahb_hwdata[7:0]);
assign   dccm_ahb_hwdatachk[1] = ~(^dccm_ahb_hwdata[15:8]);
assign   dccm_ahb_hwdatachk[2] = ~(^dccm_ahb_hwdata[23:16]);
assign   dccm_ahb_hwdatachk[3] = ~(^dccm_ahb_hwdata[31:24]);


// ahb5 part


    alb_mss_fab_ibp2ahbl_sel #(
                               .CHNL_FIFO_DEPTH(2),
                               .ADDR_W(32),
                               .DATA_W(32),
                               .ALSB(2),
                               .RGON_W(1),
                               .L_W(1)) u_mmio_ahb_hprot_inst(
                                                    .clk(mss_clk),
                                                    .bus_clk_en(mss_fab_slv2_clk_en),
                                                    .rst_a(~rst_b),
                                                    .bigendian(1'b0),
                                                    //IBP I/F
                                                    .ibp_cmd_region(slv_o_mmio_ahb_hibp_cmd_region),
                                                    .ibp_cmd_valid(slv_o_mmio_ahb_hibp_cmd_valid),
                                                    .ibp_cmd_accept(slv_o_mmio_ahb_hibp_cmd_accept),
                                                    .ibp_cmd_read(slv_o_mmio_ahb_hibp_cmd_read),
                                                    .ibp_cmd_addr(slv_o_mmio_ahb_hibp_cmd_addr[32-1:0]),
                                                    .ibp_cmd_wrap(slv_o_mmio_ahb_hibp_cmd_wrap),
                                                    .ibp_cmd_data_size(slv_o_mmio_ahb_hibp_cmd_data_size),
                                                    .ibp_cmd_burst_size(slv_o_mmio_ahb_hibp_cmd_burst_size),
                                                    .ibp_cmd_prot(slv_o_mmio_ahb_hibp_cmd_prot),
                                                    .ibp_cmd_cache(slv_o_mmio_ahb_hibp_cmd_cache),
                                                    .ibp_cmd_lock(slv_o_mmio_ahb_hibp_cmd_lock),
                                                    .ibp_cmd_excl(slv_o_mmio_ahb_hibp_cmd_excl),

                                                    .ibp_rd_valid(slv_o_mmio_ahb_hibp_rd_valid),
                                                    .ibp_rd_accept(slv_o_mmio_ahb_hibp_rd_accept),
                                                    .ibp_rd_data(slv_o_mmio_ahb_hibp_rd_data),
                                                    .ibp_err_rd(slv_o_mmio_ahb_hibp_err_rd),
                                                    .ibp_rd_last(slv_o_mmio_ahb_hibp_rd_last),
                                                    .ibp_rd_excl_ok(slv_o_mmio_ahb_hibp_rd_excl_ok),

                                                    .ibp_wr_valid(slv_o_mmio_ahb_hibp_wr_valid),
                                                    .ibp_wr_accept(slv_o_mmio_ahb_hibp_wr_accept),
                                                    .ibp_wr_data(slv_o_mmio_ahb_hibp_wr_data),
                                                    .ibp_wr_mask(slv_o_mmio_ahb_hibp_wr_mask),
                                                    .ibp_wr_last(slv_o_mmio_ahb_hibp_wr_last),

                                                    .ibp_wr_done(slv_o_mmio_ahb_hibp_wr_done),
                                                    .ibp_wr_excl_done(slv_o_mmio_ahb_hibp_wr_excl_done),
                                                    .ibp_err_wr(slv_o_mmio_ahb_hibp_err_wr),
                                                    .ibp_wr_resp_accept(slv_o_mmio_ahb_hibp_wr_resp_accept),
                                                    // AHB_Lite I/F
                                                    .ahb_hsel(mmio_ahb_hsel),
                                                    .ahb_htrans(mmio_ahb_htrans),
                                                    .ahb_hwrite(mmio_ahb_hwrite),
                                                    .ahb_haddr(mmio_ahb_haddr),
                                                    .ahb_hsize(mmio_ahb_hsize),
                                                    .ahb_hburst(mmio_ahb_hburst),
                                                    .ahb_hwdata(mmio_ahb_hwdata),
                                                    .ahb_hrdata(mmio_ahb_hrdata),
                                                    .ahb_hresp(mmio_ahb_hresp),
                                                    .ahb_hready_resp(mmio_ahb_hreadyout),
                                                    .ahb_hready(mmio_ahb_hready)
                                                    );

// ahb_parity

assign   mmio_ahb_haddrchk[0] = ~(^{mmio_ahb_haddr[7:2],2'b0});
assign mmio_ahb_haddrchk[1] = ~(^mmio_ahb_haddr[1*8 +: 8]);
assign mmio_ahb_haddrchk[2] = ~(^mmio_ahb_haddr[2*8 +: 8]);
assign mmio_ahb_haddrchk[3] = ~(^mmio_ahb_haddr[32-1 : 3*8]);
assign   mmio_ahb_htranschk = ~(^mmio_ahb_htrans);
assign   mmio_ahb_hctrlchk1 = ~(^{mmio_ahb_hburst, mmio_ahb_hwrite, mmio_ahb_hsize, 1'b0});
assign   mmio_ahb_hctrlchk2 = 1'b1;
assign   mmio_ahb_hwstrbchk = 1'b1;
assign   mmio_ahb_hprotchk =  1'b1;
assign   mmio_ahb_hreadychk = ~(^mmio_ahb_hready);
assign   mmio_ahb_hwdatachk[0] = ~(^mmio_ahb_hwdata[7:0]);
assign   mmio_ahb_hwdatachk[1] = ~(^mmio_ahb_hwdata[15:8]);
assign   mmio_ahb_hwdatachk[2] = ~(^mmio_ahb_hwdata[23:16]);
assign   mmio_ahb_hwdatachk[3] = ~(^mmio_ahb_hwdata[31:24]);


// ahb5 part


    alb_mss_fab_ibp2apb #(.a_w(12),
                          .d_w(32),
                          .rg_w(1),
                          .l_w(1)) u_mss_clkctrl_prot_inst(
                                                    // clock and reset
                                                    .clk(mss_clk),
                                                    .clk_en(1'b1),
                                                    .rst_a(~rst_b),
                                                    // IBP I/F
                                                    .ibp_cmd_region(slv_o_mss_clkctrl_ibp_cmd_region),
                                                    .ibp_cmd_valid(slv_o_mss_clkctrl_ibp_cmd_valid),
                                                    .ibp_cmd_accept(slv_o_mss_clkctrl_ibp_cmd_accept),
                                                    .ibp_cmd_read(slv_o_mss_clkctrl_ibp_cmd_read),
                                                    .ibp_cmd_addr(slv_o_mss_clkctrl_ibp_cmd_addr[12-1:0]),
                                                    .ibp_cmd_wrap(slv_o_mss_clkctrl_ibp_cmd_wrap),
                                                    .ibp_cmd_data_size(slv_o_mss_clkctrl_ibp_cmd_data_size),
                                                    .ibp_cmd_burst_size(slv_o_mss_clkctrl_ibp_cmd_burst_size),
                                                    .ibp_cmd_prot(slv_o_mss_clkctrl_ibp_cmd_prot),
                                                    .ibp_cmd_cache(slv_o_mss_clkctrl_ibp_cmd_cache),
                                                    .ibp_cmd_lock(slv_o_mss_clkctrl_ibp_cmd_lock),
                                                    .ibp_cmd_excl(slv_o_mss_clkctrl_ibp_cmd_excl),

                                                    .ibp_rd_valid(slv_o_mss_clkctrl_ibp_rd_valid),
                                                    .ibp_rd_accept(slv_o_mss_clkctrl_ibp_rd_accept),
                                                    .ibp_rd_data(slv_o_mss_clkctrl_ibp_rd_data),
                                                    .ibp_err_rd(slv_o_mss_clkctrl_ibp_err_rd),
                                                    .ibp_rd_last(slv_o_mss_clkctrl_ibp_rd_last),
                                                    .ibp_rd_excl_ok(slv_o_mss_clkctrl_ibp_rd_excl_ok),

                                                    .ibp_wr_valid(slv_o_mss_clkctrl_ibp_wr_valid),
                                                    .ibp_wr_accept(slv_o_mss_clkctrl_ibp_wr_accept),
                                                    .ibp_wr_data(slv_o_mss_clkctrl_ibp_wr_data),
                                                    .ibp_wr_mask(slv_o_mss_clkctrl_ibp_wr_mask),
                                                    .ibp_wr_last(slv_o_mss_clkctrl_ibp_wr_last),

                                                    .ibp_wr_done(slv_o_mss_clkctrl_ibp_wr_done),
                                                    .ibp_wr_resp_accept(slv_o_mss_clkctrl_ibp_wr_resp_accept),
                                                    .ibp_wr_excl_done(slv_o_mss_clkctrl_ibp_wr_excl_done),
                                                    .ibp_err_wr(slv_o_mss_clkctrl_ibp_err_wr),
                                                    // APB I/F
                                                    .apb_sel(mss_clkctrl_sel),
                                                    .apb_enable(mss_clkctrl_enable),
                                                    .apb_write(mss_clkctrl_write),
                                                    .apb_addr(mss_clkctrl_addr[12-1:2]),
                                                    .apb_wdata(mss_clkctrl_wdata),
                                                    .apb_wstrb(mss_clkctrl_wstrb),
                                                    .apb_rdata(mss_clkctrl_rdata),
                                                    .apb_slverr(mss_clkctrl_slverr),
                                                    .apb_ready(mss_clkctrl_ready));


    alb_mss_fab_ibp2apb #(.a_w(12),
                          .d_w(32),
                          .rg_w(1),
                          .l_w(1)) u_dslv1_prot_inst(
                                                    // clock and reset
                                                    .clk(mss_clk),
                                                    .clk_en(1'b1),
                                                    .rst_a(~rst_b),
                                                    // IBP I/F
                                                    .ibp_cmd_region(slv_o_dslv1_ibp_cmd_region),
                                                    .ibp_cmd_valid(slv_o_dslv1_ibp_cmd_valid),
                                                    .ibp_cmd_accept(slv_o_dslv1_ibp_cmd_accept),
                                                    .ibp_cmd_read(slv_o_dslv1_ibp_cmd_read),
                                                    .ibp_cmd_addr(slv_o_dslv1_ibp_cmd_addr[12-1:0]),
                                                    .ibp_cmd_wrap(slv_o_dslv1_ibp_cmd_wrap),
                                                    .ibp_cmd_data_size(slv_o_dslv1_ibp_cmd_data_size),
                                                    .ibp_cmd_burst_size(slv_o_dslv1_ibp_cmd_burst_size),
                                                    .ibp_cmd_prot(slv_o_dslv1_ibp_cmd_prot),
                                                    .ibp_cmd_cache(slv_o_dslv1_ibp_cmd_cache),
                                                    .ibp_cmd_lock(slv_o_dslv1_ibp_cmd_lock),
                                                    .ibp_cmd_excl(slv_o_dslv1_ibp_cmd_excl),

                                                    .ibp_rd_valid(slv_o_dslv1_ibp_rd_valid),
                                                    .ibp_rd_accept(slv_o_dslv1_ibp_rd_accept),
                                                    .ibp_rd_data(slv_o_dslv1_ibp_rd_data),
                                                    .ibp_err_rd(slv_o_dslv1_ibp_err_rd),
                                                    .ibp_rd_last(slv_o_dslv1_ibp_rd_last),
                                                    .ibp_rd_excl_ok(slv_o_dslv1_ibp_rd_excl_ok),

                                                    .ibp_wr_valid(slv_o_dslv1_ibp_wr_valid),
                                                    .ibp_wr_accept(slv_o_dslv1_ibp_wr_accept),
                                                    .ibp_wr_data(slv_o_dslv1_ibp_wr_data),
                                                    .ibp_wr_mask(slv_o_dslv1_ibp_wr_mask),
                                                    .ibp_wr_last(slv_o_dslv1_ibp_wr_last),

                                                    .ibp_wr_done(slv_o_dslv1_ibp_wr_done),
                                                    .ibp_wr_resp_accept(slv_o_dslv1_ibp_wr_resp_accept),
                                                    .ibp_wr_excl_done(slv_o_dslv1_ibp_wr_excl_done),
                                                    .ibp_err_wr(slv_o_dslv1_ibp_err_wr),
                                                    // APB I/F
                                                    .apb_sel(dslv1_sel),
                                                    .apb_enable(dslv1_enable),
                                                    .apb_write(dslv1_write),
                                                    .apb_addr(dslv1_addr[12-1:2]),
                                                    .apb_wdata(dslv1_wdata),
                                                    .apb_wstrb(dslv1_wstrb),
                                                    .apb_rdata(dslv1_rdata),
                                                    .apb_slverr(dslv1_slverr),
                                                    .apb_ready(dslv1_ready));




    alb_mss_fab_ibp2axi_rg #(
                          .CHNL_FIFO_DEPTH(2),
                          .ID_W(16),
                          .RGON_W(1),
                          .ADDR_W(24),
                          .DATA_W(64)) u_dslv2_prot_inst(
                                                    .clk(mss_clk),
                                                    .bus_clk_en(1'b1),
                                                    .rst_a(~rst_b),
                                                    //IBP I/F
                                                    .ibp_cmd_region(slv_o_dslv2_ibp_cmd_region),
                                                    .ibp_cmd_valid(slv_o_dslv2_ibp_cmd_valid),
                                                    .ibp_cmd_accept(slv_o_dslv2_ibp_cmd_accept),
                                                    .ibp_cmd_read(slv_o_dslv2_ibp_cmd_read),
                                                    .ibp_cmd_addr(slv_o_dslv2_ibp_cmd_addr[24-1:0]),
                                                    .ibp_cmd_wrap(slv_o_dslv2_ibp_cmd_wrap),
                                                    .ibp_cmd_data_size(slv_o_dslv2_ibp_cmd_data_size),
                                                    .ibp_cmd_burst_size(slv_o_dslv2_ibp_cmd_burst_size),
                                                    .ibp_cmd_prot(slv_o_dslv2_ibp_cmd_prot),
                                                    .ibp_cmd_cache(slv_o_dslv2_ibp_cmd_cache),
                                                    .ibp_cmd_lock(slv_o_dslv2_ibp_cmd_lock),
                                                    .ibp_cmd_excl(slv_o_dslv2_ibp_cmd_excl),

                                                    .ibp_rd_valid(slv_o_dslv2_ibp_rd_valid),
                                                    .ibp_rd_accept(slv_o_dslv2_ibp_rd_accept),
                                                    .ibp_rd_data(slv_o_dslv2_ibp_rd_data),
                                                    .ibp_err_rd(slv_o_dslv2_ibp_err_rd),
                                                    .ibp_rd_last(slv_o_dslv2_ibp_rd_last),
                                                    .ibp_rd_excl_ok(slv_o_dslv2_ibp_rd_excl_ok),

                                                    .ibp_wr_valid(slv_o_dslv2_ibp_wr_valid),
                                                    .ibp_wr_accept(slv_o_dslv2_ibp_wr_accept),
                                                    .ibp_wr_data(slv_o_dslv2_ibp_wr_data),
                                                    .ibp_wr_mask(slv_o_dslv2_ibp_wr_mask),
                                                    .ibp_wr_last(slv_o_dslv2_ibp_wr_last),

                                                    .ibp_wr_done(slv_o_dslv2_ibp_wr_done),
                                                    .ibp_wr_excl_done(slv_o_dslv2_ibp_wr_excl_done),
                                                    .ibp_err_wr(slv_o_dslv2_ibp_err_wr),
                                                    .ibp_wr_resp_accept(slv_o_dslv2_ibp_wr_resp_accept),
                                                    //extra id signals
                                                    .ibp_cmd_chnl_id({16{1'b0}}),
                                                    .ibp_rd_chnl_id(),
                                                    .ibp_wd_chnl_id({16{1'b0}}),
                                                    .ibp_wrsp_chnl_id(),
                                                    // AXI I/F
                                                    .axi_arvalid(dslv2_arvalid),
                                                    .axi_arready(dslv2_arready),
                                                    .axi_arregion(dslv2_arregion),
                                                    .axi_araddr(dslv2_araddr),
                                                    .axi_arburst(dslv2_arburst),
                                                    .axi_arsize(dslv2_arsize),
                                                    .axi_arlen(dslv2_arlen),
                                                    .axi_arcache(),
                                                    .axi_arprot(),
                                                    .axi_arlock(),
                                                    .axi_arid(dslv2_arid),
                                                    .axi_awvalid(dslv2_awvalid),
                                                    .axi_awready(dslv2_awready),
                                                    .axi_awregion(dslv2_awregion),
                                                    .axi_awaddr(dslv2_awaddr),
                                                    .axi_awcache(),
                                                    .axi_awprot(),
                                                    .axi_awlock(),
                                                    .axi_awburst(dslv2_awburst),
                                                    .axi_awsize(dslv2_awsize),
                                                    .axi_awlen(dslv2_awlen),
                                                    .axi_awid(dslv2_awid),
                                                    .axi_rvalid(dslv2_rvalid),
                                                    .axi_rready(dslv2_rready),
                                                    .axi_rdata(dslv2_rdata),
                                                    .axi_rresp(dslv2_rresp),
                                                    .axi_rlast(dslv2_rlast),
                                                    .axi_rid(dslv2_rid),
                                                    .axi_wvalid(dslv2_wvalid),
                                                    .axi_wready(dslv2_wready),
                                                    .axi_wdata(dslv2_wdata),
                                                    .axi_wstrb(dslv2_wstrb),
                                                    .axi_wlast(dslv2_wlast),
                                                    .axi_wid(dslv2_wid),
                                                    .axi_bid(dslv2_bid),
                                                    .axi_bvalid(dslv2_bvalid),
                                                    .axi_bready(dslv2_bready),
                                                    .axi_bresp(dslv2_bresp));




    alb_mss_fab_ibp2apb #(.a_w(13),
                          .d_w(32),
                          .rg_w(1),
                          .l_w(1)) u_mss_perfctrl_prot_inst(
                                                    // clock and reset
                                                    .clk(mss_clk),
                                                    .clk_en(1'b1),
                                                    .rst_a(~rst_b),
                                                    // IBP I/F
                                                    .ibp_cmd_region(slv_o_mss_perfctrl_ibp_cmd_region),
                                                    .ibp_cmd_valid(slv_o_mss_perfctrl_ibp_cmd_valid),
                                                    .ibp_cmd_accept(slv_o_mss_perfctrl_ibp_cmd_accept),
                                                    .ibp_cmd_read(slv_o_mss_perfctrl_ibp_cmd_read),
                                                    .ibp_cmd_addr(slv_o_mss_perfctrl_ibp_cmd_addr[13-1:0]),
                                                    .ibp_cmd_wrap(slv_o_mss_perfctrl_ibp_cmd_wrap),
                                                    .ibp_cmd_data_size(slv_o_mss_perfctrl_ibp_cmd_data_size),
                                                    .ibp_cmd_burst_size(slv_o_mss_perfctrl_ibp_cmd_burst_size),
                                                    .ibp_cmd_prot(slv_o_mss_perfctrl_ibp_cmd_prot),
                                                    .ibp_cmd_cache(slv_o_mss_perfctrl_ibp_cmd_cache),
                                                    .ibp_cmd_lock(slv_o_mss_perfctrl_ibp_cmd_lock),
                                                    .ibp_cmd_excl(slv_o_mss_perfctrl_ibp_cmd_excl),

                                                    .ibp_rd_valid(slv_o_mss_perfctrl_ibp_rd_valid),
                                                    .ibp_rd_accept(slv_o_mss_perfctrl_ibp_rd_accept),
                                                    .ibp_rd_data(slv_o_mss_perfctrl_ibp_rd_data),
                                                    .ibp_err_rd(slv_o_mss_perfctrl_ibp_err_rd),
                                                    .ibp_rd_last(slv_o_mss_perfctrl_ibp_rd_last),
                                                    .ibp_rd_excl_ok(slv_o_mss_perfctrl_ibp_rd_excl_ok),

                                                    .ibp_wr_valid(slv_o_mss_perfctrl_ibp_wr_valid),
                                                    .ibp_wr_accept(slv_o_mss_perfctrl_ibp_wr_accept),
                                                    .ibp_wr_data(slv_o_mss_perfctrl_ibp_wr_data),
                                                    .ibp_wr_mask(slv_o_mss_perfctrl_ibp_wr_mask),
                                                    .ibp_wr_last(slv_o_mss_perfctrl_ibp_wr_last),

                                                    .ibp_wr_done(slv_o_mss_perfctrl_ibp_wr_done),
                                                    .ibp_wr_resp_accept(slv_o_mss_perfctrl_ibp_wr_resp_accept),
                                                    .ibp_wr_excl_done(slv_o_mss_perfctrl_ibp_wr_excl_done),
                                                    .ibp_err_wr(slv_o_mss_perfctrl_ibp_err_wr),
                                                    // APB I/F
                                                    .apb_sel(mss_perfctrl_sel),
                                                    .apb_enable(mss_perfctrl_enable),
                                                    .apb_write(mss_perfctrl_write),
                                                    .apb_addr(mss_perfctrl_addr[13-1:2]),
                                                    .apb_wdata(mss_perfctrl_wdata),
                                                    .apb_wstrb(mss_perfctrl_wstrb),
                                                    .apb_rdata(mss_perfctrl_rdata),
                                                    .apb_slverr(mss_perfctrl_slverr),
                                                    .apb_ready(mss_perfctrl_ready));


    assign mss_mem_cmd_valid = slv_o_mss_mem_ibp_cmd_valid;
    assign mss_mem_cmd_read  = slv_o_mss_mem_ibp_cmd_read;
    assign mss_mem_cmd_addr  = slv_o_mss_mem_ibp_cmd_addr[32-1:0];
    assign mss_mem_cmd_wrap  = slv_o_mss_mem_ibp_cmd_wrap;
    assign mss_mem_cmd_data_size = slv_o_mss_mem_ibp_cmd_data_size;
    assign mss_mem_cmd_burst_size = slv_o_mss_mem_ibp_cmd_burst_size;
    assign mss_mem_cmd_lock  = slv_o_mss_mem_ibp_cmd_lock;
    assign mss_mem_cmd_excl  = slv_o_mss_mem_ibp_cmd_excl;
    assign mss_mem_cmd_prot  = slv_o_mss_mem_ibp_cmd_prot;
    assign mss_mem_cmd_cache = slv_o_mss_mem_ibp_cmd_cache;
    assign mss_mem_cmd_region = slv_o_mss_mem_ibp_cmd_region;
    assign mss_mem_cmd_id    = slv_o_mss_mem_ibp_cmd_addr[32+6-1:32];
    assign mss_mem_cmd_user  = slv_o_mss_mem_ibp_cmd_addr[42-1:32+6];

    assign mss_mem_rd_accept = slv_o_mss_mem_ibp_rd_accept;

    assign mss_mem_wr_valid  = slv_o_mss_mem_ibp_wr_valid;
    assign mss_mem_wr_data   = slv_o_mss_mem_ibp_wr_data;
    assign mss_mem_wr_mask   = slv_o_mss_mem_ibp_wr_mask;
    assign mss_mem_wr_last   = slv_o_mss_mem_ibp_wr_last;

    assign mss_mem_wr_resp_accept = slv_o_mss_mem_ibp_wr_resp_accept;

    assign slv_o_mss_mem_ibp_cmd_accept = mss_mem_cmd_accept;
    assign slv_o_mss_mem_ibp_rd_valid  = mss_mem_rd_valid;
    assign slv_o_mss_mem_ibp_rd_excl_ok = mss_mem_rd_excl_ok;
    assign slv_o_mss_mem_ibp_rd_data   = mss_mem_rd_data;
    assign slv_o_mss_mem_ibp_err_rd    = mss_mem_err_rd;
    assign slv_o_mss_mem_ibp_rd_last   = mss_mem_rd_last;
    assign slv_o_mss_mem_ibp_wr_accept = mss_mem_wr_accept;
    assign slv_o_mss_mem_ibp_wr_done   = mss_mem_wr_done;
    assign slv_o_mss_mem_ibp_wr_excl_done = mss_mem_wr_excl_done;
    assign slv_o_mss_mem_ibp_err_wr    = mss_mem_err_wr;

    // output system address base signal

endmodule // alb_mss_fab_bus
