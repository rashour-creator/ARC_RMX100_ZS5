// Library ARCv2_ZEBU_RDF-2.0.999999999
/*
 * Copyright (C) 2015 Synopsys, Inc. All rights reserved.
 *
 * SYNOPSYS CONFIDENTIAL - This is an unpublished, confidential, and
 * proprietary work of Synopsys, Inc., and may be subject to patent,
 * copyright, trade secret, and other legal or contractual protection.
 * This work may be used only pursuant to the terms and conditions of a
 * written license agreement with Synopsys, Inc. All other use, reproduction,
 * distribution, or disclosure of this work is strictly prohibited.
 *
 * The entire notice above must be reproduced on all authorized copies.
 */

// Components in UMRBus Ring: umr_tb_in - cnn(cnn present & dgb option = 2) - xtor - gpio(gpio present) - umr_tb_out

`include "zebu_axi_xtor_defines.v"

//`if(`HAS_XACTOR_GPIO == 1 )
//    `let xtor_gpio = 1
//`else 
//    `let xtor_gpio = 0
//`endif


module zebu_axi_xtor (

    input         mss_clk                       // AXI Clock
  , input         rst_a                    // AXI Reset
  , output  [`AXI_ID_WIDTH-1:0]  xtor_axi_awid                     // write addressID
  , output  [`AXI_ADDR_WIDTH-1:0]          xtor_axi_awaddr                   // write address
  , output  [3:0]           xtor_axi_awlen                     // write burst length
  , output  [2:0]           xtor_axi_awsize                   // write burst size
  , output  [1:0]           xtor_axi_awburst                  // write burst type
  , output  [1:0]           xtor_axi_awlock
  , output  [3:0]           xtor_axi_awcache                  // write cache type
  , output  [2:0]           xtor_axi_awprot                   // write protection level
  , output                  xtor_axi_awvalid                  // write address valid
  , input                   xtor_axi_awready                  // address ready
  , output [`AXI_DATA_WIDTH -1:0]   xtor_axi_wdata
  , output [`AXI_DATA_WIDTH/8-1:0] xtor_axi_wstrb
  , output                               xtor_axi_wlast
  , output                               xtor_axi_wvalid
  , input                                xtor_axi_wready
    // Write response channel
  , input [`AXI_ID_WIDTH-1:0]      xtor_axi_bid
  , input [1:0]                          xtor_axi_bresp
  , input                                xtor_axi_bvalid
  , output                               xtor_axi_bready
   // Read address channel
  , output [`AXI_ID_WIDTH-1:0]     xtor_axi_arid
  , output [`AXI_ADDR_WIDTH-1:0]   xtor_axi_araddr
  , output [`AXI_BLEN_WIDTH-1:0]                         xtor_axi_arlen
  , output [2:0]                         xtor_axi_arsize
  , output [1:0]                         xtor_axi_arburst
  , output  [1:0]                             xtor_axi_arlock
  , output [3:0]                         xtor_axi_arcache
  , output [2:0]                         xtor_axi_arprot
  , output                               xtor_axi_arvalid
  , input                                xtor_axi_arready
 // Read data channel
  , input [`AXI_ID_WIDTH-1:0]      xtor_axi_rid
  , input [`AXI_DATA_WIDTH-1:0]    xtor_axi_rdata
  , input [1:0]                          xtor_axi_rresp
  , input                                xtor_axi_rlast
  , input                                xtor_axi_rvalid
  , output                               xtor_axi_rready
  , output  [3:0]                        xtor_axi_wid        
  );

   parameter CLOCK_PERIOD         = 20;
    parameter RST_PERIOD           = 1000;
    //parameter GPIO_XACTOR_COMMENT       = "GPIO_Master";
    parameter DATA_WIDTH           = `AXI_DATA_WIDTH  ;
    parameter ADDR_WIDTH           = `AXI_ADDR_WIDTH  ;
    parameter ID_WIDTH             = `AXI_ID_WIDTH    ; 
    parameter WSTRB_WIDTH          = `AXI_WSTRB_WIDTH ;
    parameter BLEN_WIDTH           = `AXI_BLEN_WIDTH  ;
    parameter XTOR_DEBUG_WIDTH     = `AXI_DEBUG_WIDTH;
    parameter AXI_INTERLEAVE_DEPTH = 1;

    bit [XTOR_DEBUG_WIDTH-1 :0] xtor_info;

xtor_amba_master_axi3_svs #(  .DATA_WIDTH (DATA_WIDTH),
                        .ADDR_WIDTH (ADDR_WIDTH), 
                        .ID_WIDTH   (ID_WIDTH), 
                        .WSTRB_WIDTH(WSTRB_WIDTH), 
                        .BLEN_WIDTH (BLEN_WIDTH),
                        .AXI_INTERLEAVE_DEPTH(AXI_INTERLEAVE_DEPTH),
                        .XTOR_DEBUG_WIDTH(XTOR_DEBUG_WIDTH)) 
                                   
                                   master_node_i (

                                  .ACLK(mss_clk),
                                  .ARESETn(~rst_a),
                                  .WDATA(xtor_axi_wdata),  
                                  .WSTRB(xtor_axi_wstrb), 
                                  .WLAST(xtor_axi_wlast), 
                                  .WVALID(xtor_axi_wvalid), 
                                  .WREADY(xtor_axi_wready), 
                                  .AWADDR(xtor_axi_awaddr), 
                                  .AWID(xtor_axi_awid), 
                                  .AWLEN(xtor_axi_awlen), 
                                  .AWSIZE(xtor_axi_awsize), 
                                  .AWPROT(xtor_axi_awprot), 
                                  .AWBURST(xtor_axi_awburst), 
                                  .AWLOCK(xtor_axi_awlock), 
                                  .AWCACHE(xtor_axi_awcache), 
                                  .AWVALID(xtor_axi_awvalid), 
                                  .AWREADY(xtor_axi_awready), 
                                  .BID(xtor_axi_bid), 
                                  .BRESP(xtor_axi_bresp), 
                                  .BVALID(xtor_axi_bvalid), 
                                  .BREADY(xtor_axi_bready), 
                                  .ARADDR(xtor_axi_araddr), 
                                  .ARID(xtor_axi_arid), 
                                  .ARLEN(xtor_axi_arlen), 
                                  .ARSIZE(xtor_axi_arsize), 
                                  .ARPROT(xtor_axi_arprot), 
                                  .ARBURST(xtor_axi_arburst), 
                                  .ARLOCK(xtor_axi_arlock), 
                                  .ARCACHE(xtor_axi_arcache), 
                                  .ARVALID(xtor_axi_arvalid), 
                                  .ARREADY(xtor_axi_arready), 
                                  .RDATA(xtor_axi_rdata), 
                                  .RID(xtor_axi_rid), 
                                  .RRESP(xtor_axi_rresp), 
                                  .RLAST(xtor_axi_rlast), 
                                  .RVALID(xtor_axi_rvalid), 
                                  .RREADY(xtor_axi_rready),
                                  .WID(xtor_axi_wid),
                                  .xtor_info_port(xtor_info)
                              );

endmodule

