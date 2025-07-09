// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2014 Synopsys, Inc. All rights reserved.
//
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
//  AXI Buffer
//
// ===========================================================================
//
// Description:
//  Verilog module to buffer the AXI bus
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"


module alb_mss_fab_mst_axi_buffer
  #(
    parameter O_SUPPORT_RTIO = 0,
    parameter I_SUPPORT_RTIO = 0,
    parameter CHNL_FIFO_DEPTH = 2,
    parameter ID_W = 4,
    parameter RGON_W = 7,
    parameter USER_W = 1,
    // ADDR_W indicate the width of address
        // It can be any value
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
        // It can be any value
    parameter DATA_W = 32
    )
  (

  // The "i_axi_xxx" bus is the one AXI before buffered
  //
  // Read address channel
  input  i_sync_rst_r, // synced reset signal

  input  [ID_W-1:0]   i_axi_arid,
  input  i_axi_arvalid,
  output i_axi_arready,
  input  [ADDR_W-1:0] i_axi_araddr,
  input  [3:0] i_axi_arcache,
  input  [2:0] i_axi_arprot,
  input  [1:0] i_axi_arlock,
  input  [1:0] i_axi_arburst,
  input  [3:0] i_axi_arlen,
  input  [2:0] i_axi_arsize,
  input  [USER_W-1:0] i_axi_aruser,
  input  [RGON_W-1:0] i_axi_arregion,

  // Write address channel
  input  [ID_W-1:0]   i_axi_awid,
  input  i_axi_awvalid,
  output i_axi_awready,
  input  [ADDR_W-1:0] i_axi_awaddr,
  input  [3:0] i_axi_awcache,
  input  [2:0] i_axi_awprot,
  input  [1:0] i_axi_awlock,
  input  [1:0] i_axi_awburst,
  input  [3:0] i_axi_awlen,
  input  [2:0] i_axi_awsize,
  input  [USER_W-1:0] i_axi_awuser,
  input  [RGON_W-1:0] i_axi_awregion,

  // Read data channel
  output [ID_W-1:0]   i_axi_rid,
  output i_axi_rvalid,
  input  i_axi_rready,
  output [DATA_W-1:0] i_axi_rdata,
  output [1:0] i_axi_rresp,
  output i_axi_rlast,

  // Write data channel
  input  [ID_W-1:0]   i_axi_wid,
  input  i_axi_wvalid,
  output i_axi_wready,
  input  [DATA_W-1:0] i_axi_wdata,
  input  [(DATA_W/8)-1:0] i_axi_wstrb,
  input  i_axi_wlast,

  // Write response channel
  output [ID_W-1:0]   i_axi_bid,
  output i_axi_bvalid,
  input  i_axi_bready,
  output [1:0] i_axi_bresp,

  // The "o_axi_xxx" bus is the one AXI after buffer
  //
  // Read address channel
  output [ID_W-1:0]   o_axi_arid,
  output o_axi_arvalid,
  input  o_axi_arready,
  output [ADDR_W-1:0] o_axi_araddr,
  output [3:0] o_axi_arcache,
  output [2:0] o_axi_arprot,
  output [1:0] o_axi_arlock,
  output [1:0] o_axi_arburst,
  output [3:0] o_axi_arlen,
  output [2:0] o_axi_arsize,
  output [USER_W-1:0] o_axi_aruser,
  output [RGON_W-1:0] o_axi_arregion,

  // Write address channel
  output [ID_W-1:0]   o_axi_awid,
  output o_axi_awvalid,
  input  o_axi_awready,
  output [ADDR_W-1:0] o_axi_awaddr,
  output [3:0] o_axi_awcache,
  output [2:0] o_axi_awprot,
  output [1:0] o_axi_awlock,
  output [1:0] o_axi_awburst,
  output [3:0] o_axi_awlen,
  output [2:0] o_axi_awsize,
  output [USER_W-1:0] o_axi_awuser,
  output [RGON_W-1:0] o_axi_awregion,

  // Read data channel
  input  [ID_W-1:0]   o_axi_rid,
  input  o_axi_rvalid,
  output o_axi_rready,
  input  [DATA_W-1:0] o_axi_rdata,
  input  [1:0] o_axi_rresp,
  input  o_axi_rlast,

  // Write data channel
  output [ID_W-1:0]   o_axi_wid,
  output o_axi_wvalid,
  input  o_axi_wready,
  output [DATA_W-1:0] o_axi_wdata,
  output [(DATA_W/8)-1:0] o_axi_wstrb,
  output o_axi_wlast,

  // Write response channel
  input  [ID_W-1:0]   o_axi_bid,
  input  o_axi_bvalid,
  output o_axi_bready,
  input  [1:0] o_axi_bresp,

  input  clk,  // clock signal
  input  i_clk_en,  // i clock enable signal to control the 1:N clock ratios
  input  o_clk_en,  // o clock enable signal to control the 1:N clock ratios
  input  rst_a // reset signal
  );



//

wire i_axi_arvalid_raw;
wire i_axi_arready_raw;
wire i_axi_awvalid_raw;
wire i_axi_awready_raw;
wire i_axi_wvalid_raw;
wire i_axi_wready_raw;
wire i_axi_rready_raw;
wire i_axi_rvalid_raw;
wire i_axi_bvalid_raw;
wire i_axi_bready_raw;
assign i_axi_arvalid_raw = i_axi_arvalid & (~i_sync_rst_r);
assign i_axi_arready = i_axi_arready_raw & (~i_sync_rst_r);
assign i_axi_awvalid_raw = i_axi_awvalid & (~i_sync_rst_r);
assign i_axi_awready = i_axi_awready_raw & (~i_sync_rst_r);
assign i_axi_wvalid_raw = i_axi_wvalid & (~i_sync_rst_r);
assign i_axi_wready = i_axi_wready_raw & (~i_sync_rst_r);
assign i_axi_rready_raw = i_axi_rready & (~i_sync_rst_r);
assign i_axi_rvalid = i_axi_rvalid_raw & (~i_sync_rst_r);
assign i_axi_bready_raw = i_axi_bready & (~i_sync_rst_r);
assign i_axi_bvalid = i_axi_bvalid_raw & (~i_sync_rst_r);

// Qualified the input with x_clk_en to support 1:N clock ratios
//
// FIFO the AXI read address channel
localparam AR_CHNL_W = 4+3+2+4+3+2+ ID_W + ADDR_W + RGON_W +USER_W;
localparam AW_CHNL_W = AR_CHNL_W;

wire [AR_CHNL_W -1:0] i_axi_ar_chnl =
    {
    i_axi_araddr,
    i_axi_arid,
    i_axi_arcache,
    i_axi_arprot ,
    i_axi_arlock ,
    i_axi_arburst,
    i_axi_arlen  ,
    i_axi_arsize ,
    i_axi_aruser ,
    i_axi_arregion
    };

wire [AR_CHNL_W -1:0] o_axi_ar_chnl;
assign   {
    o_axi_araddr,
    o_axi_arid,
    o_axi_arcache,
    o_axi_arprot ,
    o_axi_arlock ,
    o_axi_arburst,
    o_axi_arlen  ,
    o_axi_arsize ,
    o_axi_aruser ,
    o_axi_arregion
    } = o_axi_ar_chnl;

alb_mss_fab_fifo #(
  .FIFO_DEPTH(CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(AR_CHNL_W),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(O_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(I_SUPPORT_RTIO)
) o_axi_ar_fifo (
  .i_clk_en   (i_clk_en),
  .i_ready    (i_axi_arready_raw),
  .i_valid    (i_axi_arvalid_raw),
  .i_data     (i_axi_ar_chnl),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on

  .o_clk_en   (o_clk_en),
  .o_ready    (o_axi_arready),
  .o_valid    (o_axi_arvalid),
  .o_data     (o_axi_ar_chnl),

  .clk        (clk  ),
  .rst_a      (rst_a)
  );

//
//
// FIFO the AXI write address channel

wire [AW_CHNL_W-1:0] i_axi_aw_chnl =
    {
    i_axi_awaddr,
    i_axi_awid,
    i_axi_awcache,
    i_axi_awprot ,
    i_axi_awlock ,
    i_axi_awburst,
    i_axi_awlen  ,
    i_axi_awsize ,
    i_axi_awuser ,
    i_axi_awregion
    };

wire [AW_CHNL_W-1:0] o_axi_aw_chnl;
assign   {
    o_axi_awaddr,
    o_axi_awid,
    o_axi_awcache,
    o_axi_awprot ,
    o_axi_awlock ,
    o_axi_awburst,
    o_axi_awlen  ,
    o_axi_awsize ,
    o_axi_awuser ,
    o_axi_awregion
    } = o_axi_aw_chnl;

alb_mss_fab_fifo #(
  .FIFO_DEPTH(CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(AW_CHNL_W),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(O_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(I_SUPPORT_RTIO)
) o_axi_aw_fifo (
  .i_clk_en   (i_clk_en),
  .i_ready    (i_axi_awready_raw),
  .i_valid    (i_axi_awvalid_raw),
  .i_data     (i_axi_aw_chnl ),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on

  .o_clk_en   (o_clk_en),
  .o_ready    (o_axi_awready ),
  .o_valid    (o_axi_awvalid ),
  .o_data     (o_axi_aw_chnl),

  .clk        (clk  ),
  .rst_a      (rst_a)
  );


// FIFO the wdata channel
localparam W_CHNL_W = ID_W+DATA_W+(DATA_W/8)+1;
wire [W_CHNL_W-1:0] i_axi_w_chnl = {
                                                i_axi_wid,
                                                i_axi_wdata,
                                                i_axi_wstrb,
                                                i_axi_wlast
                                                 };
// The FIFO is read as AXI WDATA channel
wire [W_CHNL_W-1:0] o_axi_w_chnl;
assign { o_axi_wid,
         o_axi_wdata,
         o_axi_wstrb,
         o_axi_wlast} = o_axi_w_chnl;

//
alb_mss_fab_fifo # (
  .FIFO_DEPTH(CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(W_CHNL_W),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(O_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(I_SUPPORT_RTIO)
) o_axi_wdata_fifo(
  .i_clk_en   (i_clk_en),
  .i_ready    (i_axi_wready_raw),
  .i_valid    (i_axi_wvalid_raw),
  .i_data     (i_axi_w_chnl ),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on

  .o_clk_en   (o_clk_en),
  .o_ready    (o_axi_wready),
  .o_valid    (o_axi_wvalid),
  .o_data     (o_axi_w_chnl),

  .clk        (clk  ),
  .rst_a      (rst_a)
);
//


// FIFO the rdata channel
localparam R_CHNL_W = ID_W+DATA_W+2+1;
wire [R_CHNL_W-1:0] o_axi_r_chnl = {
                                                o_axi_rid,
                                                o_axi_rdata,
                                                o_axi_rresp,
                                                o_axi_rlast
                                                 };
// The FIFO is read as i_axi_rdata
wire [R_CHNL_W-1:0] i_axi_r_chnl;
assign {
        i_axi_rid,
        i_axi_rdata,
        i_axi_rresp,
        i_axi_rlast} = i_axi_r_chnl;

alb_mss_fab_fifo # (
  .FIFO_DEPTH(CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(R_CHNL_W),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(I_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(O_SUPPORT_RTIO)
) o_axi_rdata_fifo(
  .i_clk_en   (o_clk_en),
  .i_ready    (o_axi_rready),
  .i_valid    (o_axi_rvalid),
  .i_data     (o_axi_r_chnl ),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on

  .o_clk_en   (i_clk_en),
  .o_ready    (i_axi_rready_raw),
  .o_valid    (i_axi_rvalid_raw),
  .o_data     (i_axi_r_chnl),
  .clk        (clk  ),
  .rst_a      (rst_a)
);
//


// FIFO the bresp channel
localparam B_CHNL_W = 2 + ID_W;

wire [B_CHNL_W -1:0] o_axi_b_chnl = {
           o_axi_bid,
           o_axi_bresp
           };

wire [B_CHNL_W -1:0] i_axi_b_chnl;
assign {
           i_axi_bid,
           i_axi_bresp
           } = i_axi_b_chnl;

alb_mss_fab_fifo #(
  .FIFO_DEPTH(CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(B_CHNL_W),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(I_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(O_SUPPORT_RTIO)
) o_axi_bresp_fifo (
  .i_clk_en   (o_clk_en),
  .i_ready    (o_axi_bready     ),
  .i_valid    (o_axi_bvalid     ),
  .i_data     (o_axi_b_chnl),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on

  .o_clk_en   (i_clk_en),
  .o_ready    (i_axi_bready_raw),
  .o_valid    (i_axi_bvalid_raw),
  .o_data     (i_axi_b_chnl),

  .clk        (clk  ),
  .rst_a      (rst_a)
  );



endmodule // alb_mss_fab_axi_buffer

