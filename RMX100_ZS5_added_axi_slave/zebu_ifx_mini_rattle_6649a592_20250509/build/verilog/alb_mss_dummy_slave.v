// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2014 Synopsys, Inc. All rights reserved.
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
//----------------------------------------------------------------------------
//
//   alb_mss_dummy_slave: provide a dummy slave to connect with Bus Fabric
//    supported bus protocols includes:
//                     AHB-Lite
//                     BVCI
//                     AXI
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_mss_dummy_slave.vpp
//
// ===========================================================================
`include "alb_mss_dummy_slave_defines.v"
module alb_mss_dummy_slave (
                              input              dslv1_sel,
                              input              dslv1_enable,
                              input              dslv1_write,
                              input [11:2]       dslv1_addr,
                              input [31:0]       dslv1_wdata,
                              input [3:0]        dslv1_wstrb,
                              output [31:0]      dslv1_rdata,
                              output             dslv1_slverr,
                              output             dslv1_ready,
                              input             dslv2_arvalid,
                              output            dslv2_arready,
                              input  [24-1:0]  dslv2_araddr,
                              input  [1:0]      dslv2_arburst,
                              input  [2:0]      dslv2_arsize,
                              input  [3:0]      dslv2_arlen,
                              input  [16-1:0] dslv2_arid,
                              output            dslv2_rvalid,
                              input             dslv2_rready,
                              output [64-1:0]  dslv2_rdata,
                              output [1:0]      dslv2_rresp,
                              output            dslv2_rlast,
                              output [16-1:0] dslv2_rid,
                              input             dslv2_awvalid,
                              output            dslv2_awready,
                              input  [24-1:0]  dslv2_awaddr,
                              input  [1:0]      dslv2_awburst,
                              input  [2:0]      dslv2_awsize,
                              input  [3:0]      dslv2_awlen,
                              input  [16-1:0] dslv2_awid,
                              input             dslv2_wvalid,
                              output            dslv2_wready,
                              input [64-1:0]   dslv2_wdata,
                              input [64/8-1:0] dslv2_wstrb,
                              input             dslv2_wlast,
                              output            dslv2_bvalid,
                              input             dslv2_bready,
                              output [1:0]      dslv2_bresp,
                              output [16-1:0] dslv2_bid,
                              input mss_clk,
                              input rst_b
                             );

// instantiate sub-modules
   apb_dummy_slave i1_apb_slave   (.psel           (dslv1_sel),
                                      .penable        (dslv1_enable),
                                      .pwrite         (dslv1_write),
                                      .paddr          (dslv1_addr),
                                      .pwdata         (dslv1_wdata),
                                      .pwstrb         (dslv1_wstrb),
                                      .prdata         (dslv1_rdata),
                                      .pslverr        (dslv1_slverr),
                                      .pready         (dslv1_ready),
                                      .pclk           (mss_clk),
                                      .preset_n       (rst_b)
                                      );
    axi_dummy_slave  #(.aw(24),
                       .dw(64),
                       .idw(16))
                     i2_axi_slave ( .arvalid       (dslv2_arvalid),
                                       .arready       (dslv2_arready),
                                       .arid          (dslv2_arid),
                                       .araddr        (dslv2_araddr),
                                       .arburst       (dslv2_arburst),
                                       .arsize        (dslv2_arsize),
                                       .arlen         (dslv2_arlen),
                                       .rvalid        (dslv2_rvalid),
                                       .rready        (dslv2_rready),
                                       .rdata         (dslv2_rdata),
                                       .rresp         (dslv2_rresp),
                                       .rlast         (dslv2_rlast),
                                       .rid           (dslv2_rid),
                                       .awvalid       (dslv2_awvalid),
                                       .awready       (dslv2_awready),
                                       .awid          (dslv2_awid),
                                       .awaddr        (dslv2_awaddr),
                                       .awburst       (dslv2_awburst),
                                       .awsize        (dslv2_awsize),
                                       .awlen         (dslv2_awlen),
                                       .wvalid        (dslv2_wvalid),
                                       .wready        (dslv2_wready),
                                       .wdata         (dslv2_wdata),
                                       .wstrb         (dslv2_wstrb),
                                       .wlast         (dslv2_wlast),
                                       .bvalid        (dslv2_bvalid),
                                       .bready        (dslv2_bready),
                                       .bid           (dslv2_bid),
                                       .bresp         (dslv2_bresp),
                                       .aclk          (mss_clk),
                                       .areset_n      (rst_b)
                                       );

 endmodule
