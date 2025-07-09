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
// Certain materials incorporated herein are copyright (C) 2010 - 2012, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//  CW binder
//
// ===========================================================================
//
// Description:
//  This module bind the cmd and wdata channel together.
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"

module alb_mss_mem_ibp_cwbind
  #(

// leda W175 off
// LMD: A parameter XXX has been defined but is not used
// LJ: We always list out all IBP relevant defines although not used




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
    parameter WD_CHNL_DATA_W          = 32,
    parameter WD_CHNL_MASK_LSB        = 33,
    parameter WD_CHNL_MASK_W          = 4,
    parameter WD_CHNL_W               = 37,

    parameter RD_CHNL_ERR_RD          = 0,
    parameter RD_CHNL_RD_EXCL_OK      = 2,
    parameter RD_CHNL_RD_LAST         = 1,
    parameter RD_CHNL_RD_DATA_LSB     = 3,
    parameter RD_CHNL_RD_DATA_W       = 32,
    parameter RD_CHNL_W               = 35,

    parameter WRSP_CHNL_WR_DONE       = 0,
    parameter WRSP_CHNL_WR_EXCL_DONE  = 1,
    parameter WRSP_CHNL_ERR_WR        = 2,
    parameter WRSP_CHNL_W             = 3,
    parameter OUT_CMD_CNT_W  = 1,
    parameter OUT_CMD_NUM  = 1,
    parameter O_RESP_ALWAYS_ACCEPT  = 0,
    parameter USER_W  = 1,
    parameter ENABLE_CWBIND  = 1

 // leda W175 on
    )
  (
  ////////////
  // The "i_xxx" bus is the one IBP in
  output i_ibp_clk_en_req,//Any transaction accepted
  //
  // command channel
  input  i_ibp_cmd_chnl_valid,
  output i_ibp_cmd_chnl_accept,
  input  [CMD_CHNL_W-1:0] i_ibp_cmd_chnl,
  input  [USER_W-1:0] i_ibp_cmd_chnl_user,
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

  ////////////
  // The "o_xxx" bus is the one IBP out
  //
  // command channel
  output o_ibp_cmd_chnl_valid,
  input  o_ibp_cmd_chnl_accept,
  output [CMD_CHNL_W-1:0] o_ibp_cmd_chnl,
  output [USER_W-1:0] o_ibp_cmd_chnl_user,
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


  // leda NTL_CON12 off
  // leda NTL_CON12A off
  // leda NTL_CON13C off
  // LMD: undriven internal net
  // LJ: This only used when ENABLE_CWBIND is on
  ////////
  input                         clk,  // clock signal
  input                         rst_a // reset signal
  // leda NTL_CON12 on
  // leda NTL_CON12A on
  // leda NTL_CON13C on
  );


generate
  if(ENABLE_CWBIND == 1)  begin: cwbind_gen//{



wire i_ibp_idle;



assign i_ibp_clk_en_req = (i_ibp_cmd_chnl_valid | i_ibp_wd_chnl_valid | (~i_ibp_idle));


//
// Count how much of the cmd wait the wdata
reg [OUT_CMD_CNT_W:0] cmd_wait_data_cnt_r;
wire cmd_wait_data_cnt_udf;
assign cmd_wait_data_cnt_udf = (cmd_wait_data_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
// The ibp wr cmd counter increased when a write trsancation going
wire cmd_wait_data_cnt_inc = i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & (~i_ibp_cmd_chnl[CMD_CHNL_READ]);
// The ibp wr cmd counter decreased when a IBP write data handshaked
wire cmd_wait_data_cnt_dec = i_ibp_wd_chnl_valid & i_ibp_wd_chnl_accept;
wire cmd_wait_data_cnt_ena = (cmd_wait_data_cnt_inc | cmd_wait_data_cnt_dec);
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
wire [OUT_CMD_CNT_W:0] cmd_wait_data_cnt_nxt =
      ( cmd_wait_data_cnt_inc & (~cmd_wait_data_cnt_dec)) ? (cmd_wait_data_cnt_r + 1'b1)
    : (~cmd_wait_data_cnt_inc &  cmd_wait_data_cnt_dec) ? (cmd_wait_data_cnt_r - 1'b1)
    : cmd_wait_data_cnt_r ;
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on

always @(posedge clk or posedge rst_a)
begin : cmd_wait_data_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      cmd_wait_data_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
  end
  else if (cmd_wait_data_cnt_ena == 1'b1) begin
      cmd_wait_data_cnt_r        <= cmd_wait_data_cnt_nxt;
  end
end
//
wire i_cmd_wait_data = (~cmd_wait_data_cnt_udf) | (o_ibp_cmd_chnl_valid & (~o_ibp_cmd_chnl[CMD_CHNL_READ]));

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
//
// Count how much of the write commands outstanding
reg [OUT_CMD_CNT_W:0] out_wr_cmd_cnt_r;
wire out_wr_cmd_cnt_ovf;
wire out_wr_cmd_cnt_udf;
assign out_wr_cmd_cnt_ovf = (out_wr_cmd_cnt_r == $unsigned(OUT_CMD_NUM));
assign out_wr_cmd_cnt_udf = (out_wr_cmd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
// The ibp wr cmd counter increased when a write trsancation going
wire out_wr_cmd_cnt_inc = i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & (~i_ibp_cmd_chnl[CMD_CHNL_READ]);
// The ibp wr cmd counter decreased when a IBP write response sent back
wire out_wr_cmd_cnt_dec = i_ibp_wrsp_chnl_valid & i_ibp_wrsp_chnl_accept;
wire out_wr_cmd_cnt_ena = (out_wr_cmd_cnt_inc | out_wr_cmd_cnt_dec);
wire [OUT_CMD_CNT_W:0] out_wr_cmd_cnt_nxt =
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
      out_wr_cmd_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
  end
  else if (out_wr_cmd_cnt_ena == 1'b1) begin
      out_wr_cmd_cnt_r        <= out_wr_cmd_cnt_nxt;
  end
end
//

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
// Count how much of the read commands outstanding
reg [OUT_CMD_CNT_W:0] out_rd_cmd_cnt_r;
wire out_rd_cmd_cnt_ovf;
wire out_rd_cmd_cnt_udf;
assign out_rd_cmd_cnt_ovf = (out_rd_cmd_cnt_r == $unsigned(OUT_CMD_NUM));
assign out_rd_cmd_cnt_udf = (out_rd_cmd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
// The ibp_rd cmd counter increased when a IBP read command accepted
wire out_rd_cmd_cnt_inc = i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & i_ibp_cmd_chnl[CMD_CHNL_READ];
// The ibp_rd cmd counter decreased when a IBP read response (last) sent back to ibp
wire out_rd_cmd_cnt_dec = i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & i_ibp_rd_chnl[RD_CHNL_RD_LAST];
wire out_rd_cmd_cnt_ena = (out_rd_cmd_cnt_inc | out_rd_cmd_cnt_dec ) ;
wire [OUT_CMD_CNT_W:0] out_rd_cmd_cnt_nxt =
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
      out_rd_cmd_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
  end
  else if (out_rd_cmd_cnt_ena == 1'b1) begin
      out_rd_cmd_cnt_r        <= out_rd_cmd_cnt_nxt;
  end
end
//

assign i_ibp_idle = (out_wr_cmd_cnt_udf & out_rd_cmd_cnt_udf);

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
wire wr_cmd_need_wdvalid = (~i_ibp_cmd_chnl[CMD_CHNL_READ]) ? i_ibp_wd_chnl_valid : 1'b1;

wire i_ibp_cmd_chnl_valid_int  ;
wire i_ibp_cmd_chnl_accept_int ;
wire i_ibp_wd_chnl_valid_int   ;
wire i_ibp_wd_chnl_accept_int  ;
wire i_ibp_rd_chnl_valid_int   ;
wire i_ibp_rd_chnl_accept_int  ;
wire i_ibp_wrsp_chnl_valid_int ;
wire i_ibp_wrsp_chnl_accept_int;

assign i_ibp_cmd_chnl_valid_int   = wr_cmd_need_wdvalid & (cmd_wait_data_cnt_udf) & (~out_wr_cmd_cnt_ovf) & (~out_rd_cmd_cnt_ovf) & i_ibp_cmd_chnl_valid ;
assign i_ibp_cmd_chnl_accept      = wr_cmd_need_wdvalid & (cmd_wait_data_cnt_udf) & (~out_wr_cmd_cnt_ovf) & (~out_rd_cmd_cnt_ovf) & i_ibp_cmd_chnl_accept_int;
assign i_ibp_wd_chnl_valid_int    = i_cmd_wait_data & i_ibp_wd_chnl_valid  ;
assign i_ibp_wd_chnl_accept       = i_cmd_wait_data & i_ibp_wd_chnl_accept_int ;
assign i_ibp_rd_chnl_valid        = (~out_rd_cmd_cnt_udf) & i_ibp_rd_chnl_valid_int;
assign i_ibp_rd_chnl_accept_int   = (~out_rd_cmd_cnt_udf) & i_ibp_rd_chnl_accept;
assign i_ibp_wrsp_chnl_valid      = (~out_wr_cmd_cnt_udf) & i_ibp_wrsp_chnl_valid_int;
assign i_ibp_wrsp_chnl_accept_int = (~out_wr_cmd_cnt_udf) & i_ibp_wrsp_chnl_accept;





assign o_ibp_cmd_chnl             = i_ibp_cmd_chnl;
assign o_ibp_cmd_chnl_user        = i_ibp_cmd_chnl_user;
assign o_ibp_cmd_chnl_valid       = i_ibp_cmd_chnl_valid_int;
assign i_ibp_cmd_chnl_accept_int  = o_ibp_cmd_chnl_accept;

assign o_ibp_wd_chnl              = i_ibp_wd_chnl;
assign o_ibp_wd_chnl_valid        = i_ibp_wd_chnl_valid_int;
assign i_ibp_wd_chnl_accept_int   = o_ibp_wd_chnl_accept;

assign i_ibp_rd_chnl              = o_ibp_rd_chnl;
assign i_ibp_rd_chnl_valid_int    = o_ibp_rd_chnl_valid;

assign i_ibp_wrsp_chnl            = o_ibp_wrsp_chnl;
assign i_ibp_wrsp_chnl_valid_int  = o_ibp_wrsp_chnl_valid;

  if(O_RESP_ALWAYS_ACCEPT == 1) begin:o_resp_always_accept
assign o_ibp_rd_chnl_accept       = 1'b1;
assign o_ibp_wrsp_chnl_accept     = 1'b1;
  end
  else begin:o_resp_not_always_accept
assign o_ibp_rd_chnl_accept       = i_ibp_rd_chnl_accept_int;
assign o_ibp_wrsp_chnl_accept     = i_ibp_wrsp_chnl_accept_int;
  end


  end
  else begin: no_cwbind_gen //}{
assign i_ibp_clk_en_req = 1'b0;

assign o_ibp_cmd_chnl             = i_ibp_cmd_chnl;
assign o_ibp_cmd_chnl_user        = i_ibp_cmd_chnl_user;
assign o_ibp_cmd_chnl_valid       = i_ibp_cmd_chnl_valid;
assign i_ibp_cmd_chnl_accept      = o_ibp_cmd_chnl_accept;

assign o_ibp_wd_chnl              = i_ibp_wd_chnl;
assign o_ibp_wd_chnl_valid        = i_ibp_wd_chnl_valid;
assign i_ibp_wd_chnl_accept       = o_ibp_wd_chnl_accept;

assign i_ibp_rd_chnl              = o_ibp_rd_chnl;
assign i_ibp_rd_chnl_valid        = o_ibp_rd_chnl_valid;

assign i_ibp_wrsp_chnl            = o_ibp_wrsp_chnl;
assign i_ibp_wrsp_chnl_valid      = o_ibp_wrsp_chnl_valid;


  if(O_RESP_ALWAYS_ACCEPT == 1) begin:o_resp_always_accept
assign o_ibp_rd_chnl_accept       = 1'b1;
assign o_ibp_wrsp_chnl_accept     = 1'b1;
  end
  else begin:o_resp_not_always_accept
assign o_ibp_rd_chnl_accept       = i_ibp_rd_chnl_accept;
assign o_ibp_wrsp_chnl_accept     = i_ibp_wrsp_chnl_accept;
  end

  end//}
endgenerate



endmodule
