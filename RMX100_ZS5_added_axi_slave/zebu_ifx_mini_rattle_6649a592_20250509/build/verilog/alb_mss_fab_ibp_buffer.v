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
//  ###   ######  ######          ######  #     # ####### #######
//   #    #     # #     #         #     # #     # #       #
//   #    #     # #     #         #     # #     # #       #
//   #    ######  ######          ######  #     # #####   #####
//   #    #     # #               #     # #     # #       #
//   #    #     # #               #     # #     # #       #
//  ###   ######  #       ####### ######   #####  #       #
//
// ===========================================================================
//
// Description:
//  Verilog module to buffer one IBP for one flip-flops stage
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"


module alb_mss_fab_ibp_buffer
  #(

// leda W175 off
// LMD: A parameter XXX has been defined but is not used
// LJ: We always list out all IBP relevant defines although not used

    parameter THROUGH_MODE = 0,
    parameter I_IBP_SUPPORT_RTIO = 0,
    parameter O_IBP_SUPPORT_RTIO = 0,
    // Outstanding counter
    parameter OUTSTAND_NUM = 8,
    parameter OUTSTAND_CNT_W = 3,



    parameter CMD_CHNL_READ           = 0,
    parameter CMD_CHNL_WRAP           = 1,
    parameter CMD_CHNL_DATA_SIZE_LSB  = 2,
    parameter CMD_CHNL_DATA_SIZE_W    = 3,
    parameter CMD_CHNL_BURST_SIZE_LSB = 5,
    parameter CMD_CHNL_BURST_SIZE_W   = 4,
    parameter CMD_CHNL_PROT_LSB       = 9,
    parameter CMD_CHNL_PROT_W         = 2,
    parameter CMD_CHNL_CACHE_LSB      = 11,
    parameter CMD_CHNL_CACHE_W        = 4,
    parameter CMD_CHNL_LOCK           = 15,
    parameter CMD_CHNL_EXCL           = 16,
    parameter CMD_CHNL_ADDR_LSB       = 17,
    parameter CMD_CHNL_ADDR_W         = 32,
    parameter CMD_CHNL_W              = 49,

    parameter WD_CHNL_LAST            = 0,
    parameter WD_CHNL_DATA_LSB        = 1,
    parameter WD_CHNL_DATA_W          = 128,
    parameter WD_CHNL_MASK_LSB        = 129,
    parameter WD_CHNL_MASK_W          = 16,
    parameter WD_CHNL_W               = 145,

    parameter RD_CHNL_ERR_RD          = 0,
    parameter RD_CHNL_RD_EXCL_OK      = 2,
    parameter RD_CHNL_RD_LAST         = 1,
    parameter RD_CHNL_RD_DATA_LSB     = 3,
    parameter RD_CHNL_RD_DATA_W       = 128,
    parameter RD_CHNL_W               = 131,

    parameter WRSP_CHNL_WR_DONE       = 0,
    parameter WRSP_CHNL_WR_EXCL_DONE  = 1,
    parameter WRSP_CHNL_ERR_WR        = 2,
    parameter WRSP_CHNL_W             = 3,

    parameter RGON_W = 7,
    parameter USER_W = 7,
    // The stage FIFO entries
    parameter CMD_CHNL_FIFO_MWHILE = 1,
    parameter WDATA_CHNL_FIFO_MWHILE = 1,
    parameter RDATA_CHNL_FIFO_MWHILE = 1,
    parameter WRESP_CHNL_FIFO_MWHILE = 1,
    parameter CMD_CHNL_FIFO_DEPTH = 1,
    parameter WDATA_CHNL_FIFO_DEPTH = 1,
    parameter RDATA_CHNL_FIFO_DEPTH = 1,
    parameter WRESP_CHNL_FIFO_DEPTH = 1
 // leda W175 on
    )
  (
  // The "i_xxx" bus is the one IBP to be buffered
// leda NTL_CON13C off
// LMD: non driving internal net
// LJ: Some signals bit field are indeed no driven
// leda NTL_CON37 off
// LMD: Signal/Net must read from the input port in module
// LJ: Some signals bit field are indeed not read and used
  //
  input  i_ibp_clk_en,
  input  [RGON_W-1:0] i_ibp_cmd_chnl_rgon,
  input  [USER_W-1:0] i_ibp_cmd_chnl_user,
  // command channel
  input  i_ibp_cmd_chnl_valid,
  output i_ibp_cmd_chnl_accept,
  input  [CMD_CHNL_W-1:0] i_ibp_cmd_chnl,
  //
  // read data channel
  // This module do not support rd_abort
  output i_ibp_rd_chnl_valid,
  input  i_ibp_rd_chnl_accept,
  output [RD_CHNL_W-1:0] i_ibp_rd_chnl,
  //
  // write data channel
  input  i_ibp_wd_chnl_valid,
  output i_ibp_wd_chnl_accept,
  input  [WD_CHNL_W-1:0] i_ibp_wd_chnl,
  //
  // write response channel
  output i_ibp_wrsp_chnl_valid,
  input  i_ibp_wrsp_chnl_accept,
  output [WRSP_CHNL_W-1:0] i_ibp_wrsp_chnl,

  // The "o_xxx" bus is the one IBP after buffered
  //
  input  o_ibp_clk_en,
  output [RGON_W-1:0] o_ibp_cmd_chnl_rgon,
  output [USER_W-1:0] o_ibp_cmd_chnl_user,
  // command channel
  output o_ibp_cmd_chnl_valid,
  input  o_ibp_cmd_chnl_accept,
  output [CMD_CHNL_W-1:0] o_ibp_cmd_chnl,
  //
  // read data channel
  // This module do not support rd_abort
  input  o_ibp_rd_chnl_valid,
  output o_ibp_rd_chnl_accept,
  input  [RD_CHNL_W-1:0] o_ibp_rd_chnl,
  //
  // write data channel
  output o_ibp_wd_chnl_valid,
  input  o_ibp_wd_chnl_accept,
  output [WD_CHNL_W-1:0] o_ibp_wd_chnl,
  //
  // write response channel
  input  o_ibp_wrsp_chnl_valid,
  output o_ibp_wrsp_chnl_accept,
  input  [WRSP_CHNL_W-1:0] o_ibp_wrsp_chnl,

  output ibp_buffer_idle,
// leda NTL_CON13C on
// leda NTL_CON37 on

  input                         clk,  // clock signal
  input                         rst_a // reset signal
  );


// FIFO the command channel
wire [CMD_CHNL_W+RGON_W+USER_W-1:0] cmd_chnl_fifo_i_data ;
wire [CMD_CHNL_W+RGON_W+USER_W-1:0] cmd_chnl_fifo_o_data ;

// The command stage valid is set when i_ibp_cmd_chnl channel is handshaked
// The command stage valid is cleared when o_ibp_cmd_chnl channel is handshaked

assign cmd_chnl_fifo_i_data =
       {  i_ibp_cmd_chnl
        , i_ibp_cmd_chnl_user
        , i_ibp_cmd_chnl_rgon };

assign {  o_ibp_cmd_chnl
        , o_ibp_cmd_chnl_user
        , o_ibp_cmd_chnl_rgon } = cmd_chnl_fifo_o_data;

wire cmd_chnl_fifo_i_valid;
wire cmd_chnl_fifo_i_ready;
wire cmd_chnl_fifo_o_valid;
wire cmd_chnl_fifo_o_ready;

alb_mss_fab_fifo # (
  .FIFO_DEPTH(CMD_CHNL_FIFO_DEPTH),
  .FIFO_WIDTH((CMD_CHNL_W + RGON_W + USER_W)),
  .IN_OUT_MWHILE (CMD_CHNL_FIFO_MWHILE),
  .O_SUPPORT_RTIO(O_IBP_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(I_IBP_SUPPORT_RTIO)
) cmd_chnl_fifo(
  .i_valid  (cmd_chnl_fifo_i_valid),
  .i_ready  (cmd_chnl_fifo_i_ready),
  .o_valid  (cmd_chnl_fifo_o_valid),
  .o_ready  (cmd_chnl_fifo_o_ready),
  .i_data   (cmd_chnl_fifo_i_data ),
  .o_data   (cmd_chnl_fifo_o_data ),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on
  .i_clk_en(i_ibp_clk_en),
  .o_clk_en(o_ibp_clk_en),
  .clk       (clk  ),
  .rst_a     (rst_a)
);


// The input command channel is accepted when command stage is ready
// ALso note the cmd countr cannot overflow
wire o_cmd_wait_wd_cnt_ovf;
wire o_cmd_wait_wd_cnt_udf;
wire cmd_wait_wd_cnt_ovf;
wire cmd_wait_wd_cnt_udf;
wire out_wr_cmd_cnt_ovf;
wire out_wr_cmd_cnt_udf;
wire out_rd_cmd_cnt_ovf;
wire out_rd_cmd_cnt_udf;
generate
if(THROUGH_MODE == 0) begin: cmd_no_through
  assign cmd_chnl_fifo_i_valid = i_ibp_cmd_chnl_valid
                             & (~cmd_wait_wd_cnt_ovf)
                             & (~out_wr_cmd_cnt_ovf)
                             & (~out_rd_cmd_cnt_ovf);
  assign i_ibp_cmd_chnl_accept = cmd_chnl_fifo_i_ready
                             & (~cmd_wait_wd_cnt_ovf)
                             & (~out_wr_cmd_cnt_ovf)
                             & (~out_rd_cmd_cnt_ovf);
  // The output command channel is valid when command stage is valid
  assign o_ibp_cmd_chnl_valid = cmd_chnl_fifo_o_valid
                             & (~o_cmd_wait_wd_cnt_ovf);
  assign cmd_chnl_fifo_o_ready = o_ibp_cmd_chnl_accept
                             & (~o_cmd_wait_wd_cnt_ovf);
end
else begin: cmd_through
  assign cmd_chnl_fifo_i_valid = i_ibp_cmd_chnl_valid;
  assign i_ibp_cmd_chnl_accept = cmd_chnl_fifo_i_ready;
  assign o_ibp_cmd_chnl_valid = cmd_chnl_fifo_o_valid;
  assign cmd_chnl_fifo_o_ready = o_ibp_cmd_chnl_accept;
end
endgenerate




// FIFO the wdata channel, by default the FIFO is 2 entries as Ping-pong buffer
wire wdata_chnl_fifo_i_valid;
wire wdata_chnl_fifo_i_ready;
wire wdata_chnl_fifo_o_valid;
wire wdata_chnl_fifo_o_ready;
// The FIFO is wrote when i_ibp_wd_chnl is handshaked
// The FIFO is read when o_ibp_wd_chnl is handshaked
// The FIFO is wrote with i_ibp_wd_chnl
wire [WD_CHNL_W-1:0] wdata_chnl_fifo_i_data = i_ibp_wd_chnl;
// The FIFO is read as o_ibp_wd_chnl
wire [WD_CHNL_W-1:0] wdata_chnl_fifo_o_data;
assign o_ibp_wd_chnl = wdata_chnl_fifo_o_data;
// The input wdata channel can be accpeted when FIFO is ready (not full)
// ALso IBP protocol require wr_accept cannot proceed the cmd_accept

// The IBP protocol require wr_accept cannot proceed the cmd_accept,
// so means wr_accept can only get asserted after some IBP write
// command have passed from command channel indicated by
// "ibp_cmd_wait_wd". If there is a incoming wr cmd accepted, the wr_accept
// can also asserted at the same cycle.
wire ibp_cmd_wait_wd = i_ibp_cmd_chnl_accept | (~cmd_wait_wd_cnt_udf);
// The output wdata channel is valid when FIFO have contents (not empty)
wire o_ibp_cmd_wait_wd = (o_ibp_cmd_chnl_valid & (~o_ibp_cmd_chnl[CMD_CHNL_READ])) | (~o_cmd_wait_wd_cnt_udf);

generate
if(THROUGH_MODE == 0) begin: wd_no_through
  assign i_ibp_wd_chnl_accept    = wdata_chnl_fifo_i_ready & ibp_cmd_wait_wd;
  assign wdata_chnl_fifo_i_valid = i_ibp_wd_chnl_valid     & ibp_cmd_wait_wd;
  assign o_ibp_wd_chnl_valid = wdata_chnl_fifo_o_valid & o_ibp_cmd_wait_wd;
  assign wdata_chnl_fifo_o_ready = o_ibp_wd_chnl_accept & o_ibp_cmd_wait_wd;
end
else begin: wd_through
  assign i_ibp_wd_chnl_accept    = wdata_chnl_fifo_i_ready;
  assign wdata_chnl_fifo_i_valid = i_ibp_wd_chnl_valid    ;
  assign o_ibp_wd_chnl_valid = wdata_chnl_fifo_o_valid ;
  assign wdata_chnl_fifo_o_ready = o_ibp_wd_chnl_accept;
end
endgenerate
//

alb_mss_fab_fifo # (
  .FIFO_DEPTH(WDATA_CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(WD_CHNL_W),
  .IN_OUT_MWHILE (WDATA_CHNL_FIFO_MWHILE),
  .O_SUPPORT_RTIO(O_IBP_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(I_IBP_SUPPORT_RTIO)
) wdata_chnl_fifo(
  .i_valid (wdata_chnl_fifo_i_valid),
  .i_ready (wdata_chnl_fifo_i_ready),
  .o_valid (wdata_chnl_fifo_o_valid),
  .o_ready (wdata_chnl_fifo_o_ready),
  .i_data  (wdata_chnl_fifo_i_data),
  .o_data  (wdata_chnl_fifo_o_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on
  .i_clk_en(i_ibp_clk_en),
  .o_clk_en(o_ibp_clk_en),
  .clk          (clk  ),
  .rst_a        (rst_a)
);
//


// FIFO the rdata channel, by default the FIFO is 2 entries as Ping-pong buffer
wire rdata_chnl_fifo_i_valid;
wire rdata_chnl_fifo_i_ready;
wire rdata_chnl_fifo_o_valid;
wire rdata_chnl_fifo_o_ready;
// The FIFO is wrote when o_ibp_rd_chnl is handshaked
// The FIFO is read when i_ibp_rd_chnl is handshaked
// The FIFO is wrote with o_ibp_rd_chnl
wire [RD_CHNL_W-1:0] rdata_chnl_fifo_i_data = o_ibp_rd_chnl;
// The FIFO is read as i_ibp_rd_chnl
wire [RD_CHNL_W-1:0] rdata_chnl_fifo_o_data;
assign i_ibp_rd_chnl = rdata_chnl_fifo_o_data;
// The output rdata channel can be accpeted when FIFO is ready (not full)
  assign o_ibp_rd_chnl_accept    = rdata_chnl_fifo_i_ready;
  assign rdata_chnl_fifo_i_valid = o_ibp_rd_chnl_valid;
// The input rdata channel is valid when FIFO have contents (not empty)

generate
if(THROUGH_MODE == 0) begin: rd_no_through
  assign i_ibp_rd_chnl_valid = rdata_chnl_fifo_o_valid & (~out_rd_cmd_cnt_udf);
  assign rdata_chnl_fifo_o_ready = i_ibp_rd_chnl_accept & (~out_rd_cmd_cnt_udf);
end
else begin: rd_through
  assign i_ibp_rd_chnl_valid = rdata_chnl_fifo_o_valid ;
  assign rdata_chnl_fifo_o_ready = i_ibp_rd_chnl_accept;
end
endgenerate
//
alb_mss_fab_fifo # (
  .FIFO_DEPTH(RDATA_CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(RD_CHNL_W),
  .IN_OUT_MWHILE (RDATA_CHNL_FIFO_MWHILE),
  .O_SUPPORT_RTIO(I_IBP_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(O_IBP_SUPPORT_RTIO)
) rdata_chnl_fifo(
  .i_valid (rdata_chnl_fifo_i_valid),
  .i_ready (rdata_chnl_fifo_i_ready),
  .o_valid (rdata_chnl_fifo_o_valid),
  .o_ready (rdata_chnl_fifo_o_ready),
  .i_data  (rdata_chnl_fifo_i_data),
  .o_data  (rdata_chnl_fifo_o_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on
  .i_clk_en(o_ibp_clk_en),
  .o_clk_en(i_ibp_clk_en),
  .clk       (clk  ),
  .rst_a     (rst_a)
);
//


// FIFO the wresp channel
wire wresp_chnl_fifo_i_valid;
wire wresp_chnl_fifo_i_ready;
wire wresp_chnl_fifo_o_valid;
wire wresp_chnl_fifo_o_ready;
wire [WRSP_CHNL_W-1:0] wresp_chnl_fifo_i_data ;
wire [WRSP_CHNL_W-1:0] wresp_chnl_fifo_o_data ;

assign wresp_chnl_fifo_i_data = o_ibp_wrsp_chnl;
assign i_ibp_wrsp_chnl = wresp_chnl_fifo_o_data;

alb_mss_fab_fifo # (
  .FIFO_DEPTH(WRESP_CHNL_FIFO_DEPTH),
  .FIFO_WIDTH(WRSP_CHNL_W),
  .IN_OUT_MWHILE (WRESP_CHNL_FIFO_MWHILE),
  .O_SUPPORT_RTIO(I_IBP_SUPPORT_RTIO),
  .I_SUPPORT_RTIO(O_IBP_SUPPORT_RTIO)
) wresp_chnl_fifo(
  .i_valid (wresp_chnl_fifo_i_valid),
  .i_ready (wresp_chnl_fifo_i_ready),
  .o_valid (wresp_chnl_fifo_o_valid),
  .o_ready (wresp_chnl_fifo_o_ready),
  .i_data  (wresp_chnl_fifo_i_data),
  .o_data  (wresp_chnl_fifo_o_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on
  .i_clk_en(o_ibp_clk_en),
  .o_clk_en(i_ibp_clk_en),
  .clk          (clk  ),
  .rst_a        (rst_a)
);
//
//
assign o_ibp_wrsp_chnl_accept  = wresp_chnl_fifo_i_ready;
assign wresp_chnl_fifo_i_valid = o_ibp_wrsp_chnl_valid;
//
generate
if(THROUGH_MODE == 0) begin: wrsp_no_through
  assign i_ibp_wrsp_chnl_valid   = wresp_chnl_fifo_o_valid & (~out_wr_cmd_cnt_udf);
  assign wresp_chnl_fifo_o_ready = i_ibp_wrsp_chnl_accept  & (~out_wr_cmd_cnt_udf);
end
else begin: wrsp_through
  assign i_ibp_wrsp_chnl_valid   = wresp_chnl_fifo_o_valid;
  assign wresp_chnl_fifo_o_ready = i_ibp_wrsp_chnl_accept ;
end
endgenerate

//


// Count how much of the cmd is waiting write burst data
//
reg [OUTSTAND_CNT_W:0] cmd_wait_wd_cnt_r;
assign cmd_wait_wd_cnt_ovf = (cmd_wait_wd_cnt_r == $unsigned(OUTSTAND_NUM));
assign cmd_wait_wd_cnt_udf = (cmd_wait_wd_cnt_r == {OUTSTAND_CNT_W+1{1'b0}});
// The ibp wr burst counter increased when a IBP write command accepted to the cmd stage
// also note no overflow allowed
wire cmd_wait_wd_cnt_inc = i_ibp_clk_en & i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & (~i_ibp_cmd_chnl[CMD_CHNL_READ]);
// The ibp wr burst counter decreased when a last beat of IBP write burst accepted to wd stage
// also note no underflow allowed
wire cmd_wait_wd_cnt_dec = (i_ibp_clk_en & i_ibp_wd_chnl_valid & i_ibp_wd_chnl_accept & i_ibp_wd_chnl[WD_CHNL_LAST]);
wire cmd_wait_wd_cnt_ena = cmd_wait_wd_cnt_inc | cmd_wait_wd_cnt_dec;
// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
wire [OUTSTAND_CNT_W:0] cmd_wait_wd_cnt_nxt =
      ( cmd_wait_wd_cnt_inc & (~cmd_wait_wd_cnt_dec)) ? (cmd_wait_wd_cnt_r + 1'b1)
    : (~cmd_wait_wd_cnt_inc &  cmd_wait_wd_cnt_dec) ? (cmd_wait_wd_cnt_r - 1'b1)
    : cmd_wait_wd_cnt_r ;
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on

always @(posedge clk or posedge rst_a)
begin : cmd_wait_wd_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      cmd_wait_wd_cnt_r        <= {OUTSTAND_CNT_W+1{1'b0}};
  end
  else if (cmd_wait_wd_cnt_ena == 1'b1) begin
      cmd_wait_wd_cnt_r        <= cmd_wait_wd_cnt_nxt;
  end
end

// Count how much of the cmd is waiting write burst data
//
reg [OUTSTAND_CNT_W:0] o_cmd_wait_wd_cnt_r;
assign o_cmd_wait_wd_cnt_ovf = (o_cmd_wait_wd_cnt_r == $unsigned(OUTSTAND_NUM));
assign o_cmd_wait_wd_cnt_udf = (o_cmd_wait_wd_cnt_r == {OUTSTAND_CNT_W+1{1'b0}});
// The ibp wr burst counter increased when a IBP write command accepted to the cmd stage
// also note no overflow allowed
wire o_cmd_wait_wd_cnt_inc = o_ibp_clk_en & o_ibp_cmd_chnl_valid & o_ibp_cmd_chnl_accept & (~o_ibp_cmd_chnl[CMD_CHNL_READ]);
// The ibp wr burst counter decreased when a last beat of IBP write burst accepted to wd stage
// also note no underflow allowed
wire o_cmd_wait_wd_cnt_dec = (o_ibp_clk_en & o_ibp_wd_chnl_valid & o_ibp_wd_chnl_accept & o_ibp_wd_chnl[WD_CHNL_LAST]);
wire o_cmd_wait_wd_cnt_ena = o_cmd_wait_wd_cnt_inc | o_cmd_wait_wd_cnt_dec;
// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
wire [OUTSTAND_CNT_W:0] o_cmd_wait_wd_cnt_nxt =
      ( o_cmd_wait_wd_cnt_inc & (~o_cmd_wait_wd_cnt_dec)) ? (o_cmd_wait_wd_cnt_r + 1'b1)
    : (~o_cmd_wait_wd_cnt_inc &  o_cmd_wait_wd_cnt_dec) ? (o_cmd_wait_wd_cnt_r - 1'b1)
    : o_cmd_wait_wd_cnt_r ;
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on

always @(posedge clk or posedge rst_a)
begin : o_cmd_wait_wd_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      o_cmd_wait_wd_cnt_r        <= {OUTSTAND_CNT_W+1{1'b0}};
  end
  else if (o_cmd_wait_wd_cnt_ena == 1'b1) begin
      o_cmd_wait_wd_cnt_r        <= o_cmd_wait_wd_cnt_nxt;
  end
end

//
// Count how much of the write commands outstanding
reg [OUTSTAND_CNT_W:0] out_wr_cmd_cnt_r;
assign out_wr_cmd_cnt_ovf = (out_wr_cmd_cnt_r == $unsigned(OUTSTAND_NUM));
assign out_wr_cmd_cnt_udf = (out_wr_cmd_cnt_r == {OUTSTAND_CNT_W+1{1'b0}});
// The ibp wr cmd counter increased when a write trsancation going
wire out_wr_cmd_cnt_inc = i_ibp_clk_en & i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & (~i_ibp_cmd_chnl[CMD_CHNL_READ]);
// The ibp wr cmd counter decreased when a IBP write response sent back
wire out_wr_cmd_cnt_dec = i_ibp_clk_en & i_ibp_wrsp_chnl_valid & i_ibp_wrsp_chnl_accept;
wire out_wr_cmd_cnt_ena = (out_wr_cmd_cnt_inc | out_wr_cmd_cnt_dec);
// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
wire [OUTSTAND_CNT_W:0] out_wr_cmd_cnt_nxt =
      ( out_wr_cmd_cnt_inc & (~out_wr_cmd_cnt_dec)) ? (out_wr_cmd_cnt_r + 1'b1)
    : (~out_wr_cmd_cnt_inc &  out_wr_cmd_cnt_dec) ? (out_wr_cmd_cnt_r - 1'b1)
    : out_wr_cmd_cnt_r ;
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on

always @(posedge clk or posedge rst_a)
begin : out_wr_cmd_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      out_wr_cmd_cnt_r        <= {OUTSTAND_CNT_W+1{1'b0}};
  end
  else if (out_wr_cmd_cnt_ena == 1'b1) begin
      out_wr_cmd_cnt_r        <= out_wr_cmd_cnt_nxt;
  end
end
//

// Count how much of the read commands outstanding
reg [OUTSTAND_CNT_W:0] out_rd_cmd_cnt_r;
assign out_rd_cmd_cnt_ovf = (out_rd_cmd_cnt_r == $unsigned(OUTSTAND_NUM));
assign out_rd_cmd_cnt_udf = (out_rd_cmd_cnt_r == {OUTSTAND_CNT_W+1{1'b0}});
// The ibp_rd cmd counter increased when a IBP read command accepted
wire out_rd_cmd_cnt_inc = i_ibp_clk_en & i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & i_ibp_cmd_chnl[CMD_CHNL_READ];
// The ibp_rd cmd counter decreased when a IBP read response (last) sent back to ibp
wire out_rd_cmd_cnt_dec = i_ibp_clk_en & i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & i_ibp_rd_chnl[RD_CHNL_RD_LAST];
wire out_rd_cmd_cnt_ena = (out_rd_cmd_cnt_inc | out_rd_cmd_cnt_dec ) ;
// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
wire [OUTSTAND_CNT_W:0] out_rd_cmd_cnt_nxt =
      ( out_rd_cmd_cnt_inc & (~out_rd_cmd_cnt_dec)) ? (out_rd_cmd_cnt_r + 1'b1)
    : (~out_rd_cmd_cnt_inc &  out_rd_cmd_cnt_dec) ? (out_rd_cmd_cnt_r - 1'b1)
    : out_rd_cmd_cnt_r ;
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on

always @(posedge clk or posedge rst_a)
begin : out_rd_cmd_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      out_rd_cmd_cnt_r        <= {OUTSTAND_CNT_W+1{1'b0}};
  end
  else if (out_rd_cmd_cnt_ena == 1'b1) begin
      out_rd_cmd_cnt_r        <= out_rd_cmd_cnt_nxt;
  end
end
//

wire no_out_cmd = (out_wr_cmd_cnt_udf & out_rd_cmd_cnt_udf);

assign ibp_buffer_idle = no_out_cmd;

endmodule // alb_mss_fab_ibp_buffer
