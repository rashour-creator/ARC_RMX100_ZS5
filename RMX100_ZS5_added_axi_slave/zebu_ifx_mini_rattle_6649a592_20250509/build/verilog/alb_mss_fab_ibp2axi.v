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
//  ###   ######  ######   #####     #    #     #   ###
//   #    #     # #     # #     #   # #    #   #     #
//   #    #     # #     #       #  #   #    # #      #
//   #    ######  ######   #####  #     #    #       #
//   #    #     # #       #       #######   # #      #
//   #    #     # #       #       #     #  #   #     #
//  ###   ######  #       ####### #     # #     #   ###
//
// ===========================================================================
//
// Description:
//  Verilog module to convert the IBP to AXI protocol
//  The IBP is standard IBP protocol, besides, this module
//  have some limitation or extention to standard IBP protocol
//     * Support narrow transfer: the data-size can be narrower than the
//       data bus width
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"


module alb_mss_fab_ibp2axi
  #(
    parameter CHNL_FIFO_DEPTH = 2,
    parameter ID_W = 4,
    parameter USER_W = 1,
    // ADDR_W indicate the width of address
        // It can be any value
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
        // It can be any value
    parameter DATA_W = 32,
    // OUT_CMD_CNT_W indicate the width of counter
        // how many read/write commands supported
    parameter OUT_CMD_NUM = 8,
    parameter OUT_CMD_CNT_W = 3
    )
  (
  // The "ibp_xxx" bus is the one IBP to be converted
  //
  // command channel
  // This module Do not support the id and snoop
  input  ibp_cmd_valid,
  output ibp_cmd_accept,
  input  ibp_cmd_read,
  input  [ADDR_W-1:0] ibp_cmd_addr,
  input  ibp_cmd_wrap,
  input  [2:0] ibp_cmd_data_size,
  input  [3:0] ibp_cmd_burst_size,
  input  ibp_cmd_lock,
  input  ibp_cmd_excl,
  input  [1:0] ibp_cmd_prot,
  input  [3:0] ibp_cmd_cache,
  //
  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  output ibp_rd_valid,
  input  ibp_rd_accept,
  output [DATA_W-1:0] ibp_rd_data,
  output ibp_rd_last,
  output ibp_err_rd,
  output ibp_rd_excl_ok,
  //
  // write data channel
  input  ibp_wr_valid,
  output ibp_wr_accept,
  input  [DATA_W-1:0] ibp_wr_data,
  input  [(DATA_W/8)-1:0] ibp_wr_mask,
  input  ibp_wr_last,
  //
  // write response channel
  // This module do not support id
  output ibp_wr_done,
  output ibp_wr_excl_done,
  output ibp_err_wr,
  input  ibp_wr_resp_accept,

  input  [USER_W-1:0] ibp_cmd_user ,

  input  [ID_W-1:0] ibp_cmd_chnl_id ,
  output [ID_W-1:0] ibp_rd_chnl_id  ,
  input  [ID_W-1:0] ibp_wd_chnl_id  ,
  output [ID_W-1:0] ibp_wrsp_chnl_id,

  // The "axi_xxx" bus is the one AXI after converted
  //
  output [ID_W-1:0]   axi_arid,
  output [ID_W-1:0]   axi_awid,
  output [ID_W-1:0]   axi_wid,
  input  [ID_W-1:0]   axi_rid,
  input  [ID_W-1:0]   axi_bid,
  // Read address channel
  output axi_arvalid,
  input  axi_arready,
  output [ADDR_W-1:0] axi_araddr,
  output [3:0] axi_arcache,
  output [2:0] axi_arprot,
  output [1:0] axi_arlock,
  output [1:0] axi_arburst,
  output [3:0] axi_arlen,
  output [2:0] axi_arsize,
  output [USER_W-1:0] axi_aruser,

  // Write address channel
  output axi_awvalid,
  input  axi_awready,
  output [ADDR_W-1:0] axi_awaddr,
  output [3:0] axi_awcache,
  output [2:0] axi_awprot,
  output [1:0] axi_awlock,
  output [1:0] axi_awburst,
  output [3:0] axi_awlen,
  output [2:0] axi_awsize,
  output [USER_W-1:0] axi_awuser,

  // Read data channel
  input  axi_rvalid,
  output axi_rready,
  input  [DATA_W-1:0] axi_rdata,
  input  [1:0] axi_rresp,
  input  axi_rlast,

  // Write data channel
  output axi_wvalid,
  input  axi_wready,
  output [DATA_W-1:0] axi_wdata,
  output [(DATA_W/8)-1:0] axi_wstrb,
  output axi_wlast,

  // Write response channel
  input  axi_bvalid,
  output axi_bready,
  input  [1:0] axi_bresp,

  input  clk,  // clock signal
  input  bus_clk_en,  // clock enable signal to control the 1:N clock ratios
  input  rst_a // reset signal
  );



// The IBP protocol require wr_accept cannot proceed the cmd_accept,
// so means wr_accept can only get asserted after some IBP write
// command have passed from command channel indicated by
// "ibp_cmd_wait_wd".
wire cmd_wait_wd_cnt_udf;
wire ibp_cmd_wait_wd = (ibp_cmd_accept) | (~cmd_wait_wd_cnt_udf);
// Count how much of the cmd is waiting write burst data
//
reg [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_r;
assign cmd_wait_wd_cnt_udf = (cmd_wait_wd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
// The ibp wr burst counter increased when a IBP write command accepted to the axi_aw stage
wire cmd_wait_wd_cnt_inc = ibp_cmd_valid & ibp_cmd_accept & (~ibp_cmd_read);
// The ibp wr burst counter decreased when a last beat of IBP write burst accepted to axi_wd stage
wire cmd_wait_wd_cnt_dec = (ibp_wr_valid & ibp_wr_accept & ibp_wr_last);
wire cmd_wait_wd_cnt_ena = cmd_wait_wd_cnt_inc | cmd_wait_wd_cnt_dec;
// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
wire [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_nxt =
      ( cmd_wait_wd_cnt_inc & (~cmd_wait_wd_cnt_dec)) ? (cmd_wait_wd_cnt_r + 1'b1)
    : (~cmd_wait_wd_cnt_inc &  cmd_wait_wd_cnt_dec) ? (cmd_wait_wd_cnt_r - 1'b1)
    : cmd_wait_wd_cnt_r ;
// leda B_3200 on
// leda BTTF_D002 on
// leda W484 on
// leda B_3219 on

always @(posedge clk or posedge rst_a)
begin : cmd_wait_wd_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      cmd_wait_wd_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
  end
  else if (cmd_wait_wd_cnt_ena == 1'b1) begin
      cmd_wait_wd_cnt_r        <= cmd_wait_wd_cnt_nxt;
  end
end
//


wire [1+1+ADDR_W+4+3+1+1+2+4+USER_W+ID_W-1:0] i_ibp_cmd_chnl_pack;
wire [1+1+ADDR_W+4+3+1+1+2+4+USER_W+ID_W-1:0] ibp_cmd_chnl_pack =
      {
      ibp_cmd_read,
      ibp_cmd_wrap,
      ibp_cmd_addr,
      ibp_cmd_burst_size,
      ibp_cmd_data_size,
      ibp_cmd_lock,
      ibp_cmd_excl,
      ibp_cmd_prot,
      ibp_cmd_cache,
      ibp_cmd_user,
      ibp_cmd_chnl_id
      };

wire i_ibp_cmd_valid;
wire i_ibp_cmd_accept;
wire i_ibp_cmd_read;
wire [ADDR_W-1:0] i_ibp_cmd_addr;
wire i_ibp_cmd_wrap;
wire [2:0] i_ibp_cmd_data_size;
wire [3:0] i_ibp_cmd_burst_size;
wire i_ibp_cmd_lock;
wire i_ibp_cmd_excl;
wire [1:0] i_ibp_cmd_prot;
wire [3:0] i_ibp_cmd_cache;
wire [ID_W-1:0] i_ibp_cmd_chnl_id;
wire [USER_W-1:0] i_ibp_cmd_user;

assign {
      i_ibp_cmd_read,
      i_ibp_cmd_wrap,
      i_ibp_cmd_addr,
      i_ibp_cmd_burst_size,
      i_ibp_cmd_data_size,
      i_ibp_cmd_lock,
      i_ibp_cmd_excl,
      i_ibp_cmd_prot,
      i_ibp_cmd_cache,
      i_ibp_cmd_user,
      i_ibp_cmd_chnl_id
      } = i_ibp_cmd_chnl_pack;


alb_mss_fab_bypbuf #(
  .BUF_DEPTH(1),
  .BUF_WIDTH((1+1+ADDR_W+4+3+1+1+2+4+ID_W+USER_W))
) ibp_cmd_bypbuf (
  .i_ready    (ibp_cmd_accept),
  .i_valid    (ibp_cmd_valid),
  .i_data     (ibp_cmd_chnl_pack),
  .o_ready    (i_ibp_cmd_accept),
  .o_valid    (i_ibp_cmd_valid),
  .o_data     (i_ibp_cmd_chnl_pack),

  .clk        (clk  ),
  .rst_a      (rst_a)
  );

// The coming IBP do not need to be flopped, it will just be directly
// converted to AXI protocol by some combinational logics
//
// Convert for Read/Write address channel
    // Just direct assigned from IBP command channel to AXI address
//
// The valid and address is just direct got from IBP command channel
wire ibp2axi_arvalid = i_ibp_cmd_valid & i_ibp_cmd_read;
wire ibp2axi_awvalid = i_ibp_cmd_valid & (~i_ibp_cmd_read);
//
wire [ADDR_W-1:0] i_ibp_cmd_addr_aligned;
assign i_ibp_cmd_addr_aligned =
  //3'b100: Quad-word transfer
  (i_ibp_cmd_data_size == 4) ? {i_ibp_cmd_addr[ADDR_W-1:4],4'b0000} :
  //3'b011: Double-word transfer
  (i_ibp_cmd_data_size == 3) ? {i_ibp_cmd_addr[ADDR_W-1:3],3'b000} :
  //3'b010: Word transfer
  (i_ibp_cmd_data_size == 2) ? {i_ibp_cmd_addr[ADDR_W-1:2],2'b00} :
  //3'b001: Half-word transfer
  (i_ibp_cmd_data_size == 1) ? {i_ibp_cmd_addr[ADDR_W-1:1],1'b0} :
  //3'b000: Byte transfer
                                  i_ibp_cmd_addr[ADDR_W-1:0];

wire [ADDR_W-1:0] ibp2axi_araddr = i_ibp_cmd_addr_aligned;
wire [ADDR_W-1:0] ibp2axi_awaddr = ibp2axi_araddr;

wire [ID_W-1:0] ibp2axi_arid = i_ibp_cmd_chnl_id;
wire [ID_W-1:0] ibp2axi_awid = i_ibp_cmd_chnl_id;
wire [USER_W-1:0] ibp2axi_aruser = i_ibp_cmd_user;
wire [USER_W-1:0] ibp2axi_awuser = i_ibp_cmd_user;
//
wire[3:0] ibp2axi_arcache = {i_ibp_cmd_cache[0], i_ibp_cmd_cache[1], i_ibp_cmd_cache[2], i_ibp_cmd_cache[3]};
wire[3:0] ibp2axi_awcache = ibp2axi_arcache;
//
// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
wire[2:0] ibp2axi_arprot = {i_ibp_cmd_prot[1], 1'b1, i_ibp_cmd_prot[0]};
// leda NTL_CON16 on
wire[2:0] ibp2axi_awprot = ibp2axi_arprot;
//
wire [1:0] ibp2axi_lock = i_ibp_cmd_excl? 2'b01 : i_ibp_cmd_lock ? 2'b10 : 2'b0;
wire [1:0] ibp2axi_arlock = ibp2axi_lock;
wire [1:0] ibp2axi_awlock = ibp2axi_lock;
//
// If cmd_wrap is high, the transaction is mapped to WRAP; otherwise mapped to INCR. No other type of AxBURST supported.
wire[1:0] ibp2axi_arburst = {i_ibp_cmd_wrap, ~i_ibp_cmd_wrap};
wire[1:0] ibp2axi_awburst = ibp2axi_arburst;
//
// Same width of cmd_burst_size and axlen, so just direct assignment
wire[3:0] ibp2axi_arlen = i_ibp_cmd_burst_size;
wire[3:0] ibp2axi_awlen = ibp2axi_arlen;
//
// If non-burst mode: AxSIZE[2:0] = cmd_data_size; if burst mode, AxSIZE[2:0] is always the same to data bus width, e.g., 64bits IBP data width is always have 8 bytes data size (3'b011) for burst mode.
wire[2:0] ibp2axi_arsize = i_ibp_cmd_data_size;
wire[2:0] ibp2axi_awsize = ibp2axi_arsize;
//
wire ibp2axi_awready;
wire ibp2axi_arready;
assign i_ibp_cmd_accept = ((i_ibp_cmd_read & ibp2axi_arready) | (~i_ibp_cmd_read & ibp2axi_awready));
//
// Convert for Write data channel
    // Just direct assigned from IBP wdata channel to AXI
wire [DATA_W-1:0]   ibp2axi_wdata = ibp_wr_data;
wire [ID_W-1:0] ibp2axi_wid = ibp_wd_chnl_id;
wire [(DATA_W/8)-1:0] ibp2axi_wstrb = ibp_wr_mask;
wire ibp2axi_wlast = ibp_wr_last;
wire ibp2axi_wready;
assign ibp_wr_accept = ibp2axi_wready & ibp_cmd_wait_wd;
wire ibp2axi_wvalid = ibp_wr_valid & ibp_cmd_wait_wd;
// Convert for Read data channel
    // Just direct assigned from FIFOed AXI rdata channel to IBP
wire ibp2axi_rvalid;

// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire [1:0] ibp2axi_rresp;
// leda NTL_CON13A on
wire  [DATA_W-1:0] ibp2axi_rdata;
wire  [ID_W-1:0] ibp2axi_rid;
wire ibp2axi_rlast;
assign ibp_err_rd = ibp2axi_rvalid & ibp2axi_rresp[1];//SLVERR and DECERR
assign ibp_rd_excl_ok = ibp2axi_rvalid & (~ibp2axi_rresp[1]) & ibp2axi_rresp[0];//EXOKAY
assign ibp_rd_valid = (ibp2axi_rvalid & (~ibp2axi_rresp[1]) & (~ibp2axi_rresp[0])) | ibp_rd_excl_ok;//OKAY
assign ibp_rd_data = ibp2axi_rdata;
assign ibp_rd_last = ibp2axi_rlast;
assign ibp_rd_chnl_id = ibp2axi_rid;
assign ibp2axi_rready = ibp_rd_accept;
//
// Convert for Write response channel
    // Just direct assigned from Flip-floped AXI wresp channel to IBP
wire ibp2axi_bvalid;
wire [1:0] ibp2axi_bresp;
wire [ID_W-1:0] ibp2axi_bid;
assign ibp_err_wr = ibp2axi_bvalid & ibp2axi_bresp[1];//SLVERR and DECERR
assign ibp_wr_excl_done = ibp2axi_bvalid & (ibp2axi_bresp == 2'b01);//EXOKAY
assign ibp_wr_done = ibp2axi_bvalid & (ibp2axi_bresp == 2'b00);//OKAY
assign ibp_wrsp_chnl_id = ibp2axi_bid;
assign ibp2axi_bready = ibp_wr_resp_accept;


//
// read address stage is ready to upstream (ibp2axi_AR channel)
// only when read address stage is empty(i.e,
// xxx_valid_r is cleared) to cut the timing path
// Also Need to care no cmd counter overflowed
// Also Need to care when it is a lock transaction, then there mustn't be any outstanding
// transactions.
reg [1:0] ibp2axi_lock_r;
reg [1:0] ibp2axi_lock_r_r;
wire ibp2axi_lock_set;
assign ibp2axi_lock_set = ((ibp2axi_awvalid & ibp2axi_awready) | (ibp2axi_arvalid & ibp2axi_arready));

always @(posedge clk or posedge rst_a)
begin : ibp2axi_lock_DFFEAR_PROC
  if (rst_a == 1'b1) begin
    ibp2axi_lock_r  <= 2'b0;
    ibp2axi_lock_r_r  <= 2'b0;
  end
  else if (ibp2axi_lock_set == 1'b1) begin
    ibp2axi_lock_r    <= ibp2axi_lock   ;
    ibp2axi_lock_r_r  <= ibp2axi_lock_r   ;
  end
end


wire lock_need_out_clean =
    // It is a lock transaction itself
    ((ibp2axi_arlock == 2'b10) |
    // Or, There is a lock transaction ahead (so it is a unlock itself)
     (ibp2axi_lock_r == 2'b10) |
    // Or, There is a unlock-after-lock transaction ahead
     (ibp2axi_lock_r_r == 2'b10));

wire no_out_cmd;
wire out_cmd_cnt_ovf;

wire ibp2axi_arvalid_raw;
wire ibp2axi_arready_raw;

assign ibp2axi_arready = (
                           (
                             lock_need_out_clean
                           )
                           ?  (no_out_cmd & ibp2axi_arready_raw) : ibp2axi_arready_raw)
                         & (~out_cmd_cnt_ovf);

assign ibp2axi_arvalid_raw = (
                           (
                             lock_need_out_clean
                           )
                           ?  (no_out_cmd & ibp2axi_arvalid) : ibp2axi_arvalid)
                         & (~out_cmd_cnt_ovf);
//
//
//
// write address stage is ready to upstream (ibp2axi_AW channel)
// only when write address stage is empty(i.e,
// xxx_valid_r is cleared) to cut the timing path
// Also Need to care no cmd counter overflowed
// Also Need to care when it is a lock transaction, then there mustn't be any outstanding
// transactions.
wire ibp2axi_awvalid_raw;
wire ibp2axi_awready_raw;

assign ibp2axi_awready = (
                           (
                             lock_need_out_clean
                           )
                           ?  (no_out_cmd & ibp2axi_awready_raw) : ibp2axi_awready_raw)
                         & (~out_cmd_cnt_ovf);

assign ibp2axi_awvalid_raw =   (
                           (
                             lock_need_out_clean
                           )
                           ?  (no_out_cmd & ibp2axi_awvalid) : ibp2axi_awvalid)
                         & (~out_cmd_cnt_ovf);





wire out_rd_cmd_cnt_udf;

wire ibp2axi_rready_raw;
wire ibp2axi_rvalid_raw;

// Also make sure the cnt is not underflowing
assign ibp2axi_rready_raw = ibp2axi_rready & (~out_rd_cmd_cnt_udf);
assign ibp2axi_rvalid = (ibp2axi_rvalid_raw) & (~out_rd_cmd_cnt_udf);
//

//
wire ibp2axi_bvalid_raw;
wire ibp2axi_bready_raw;
wire out_wr_cmd_cnt_udf;
assign ibp2axi_bvalid = ibp2axi_bvalid_raw & (~out_wr_cmd_cnt_udf);
assign ibp2axi_bready_raw = ibp2axi_bready & (~out_wr_cmd_cnt_udf);
//


// Count how much of the write commands outstanding
reg [OUT_CMD_CNT_W:0] out_wr_cmd_cnt_r;
wire out_wr_cmd_cnt_ovf = (out_wr_cmd_cnt_r == $unsigned(OUT_CMD_NUM));
assign out_wr_cmd_cnt_udf = (out_wr_cmd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
// The ibp wr cmd counter increased when a write trsancation going to issue to AXI
wire out_wr_cmd_cnt_inc = ibp2axi_awvalid & ibp2axi_awready;
// The ibp wr cmd counter decreased when a IBP write response sent back from AXI to ibp
wire out_wr_cmd_cnt_dec = ibp2axi_bvalid & ibp2axi_bready;
wire out_wr_cmd_cnt_ena = (out_wr_cmd_cnt_inc | out_wr_cmd_cnt_dec);
// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
wire [OUT_CMD_CNT_W:0] out_wr_cmd_cnt_nxt =
      ( out_wr_cmd_cnt_inc & (~out_wr_cmd_cnt_dec)) ? (out_wr_cmd_cnt_r + 1'b1)
    : (~out_wr_cmd_cnt_inc &  out_wr_cmd_cnt_dec) ? (out_wr_cmd_cnt_r - 1'b1)
    : out_wr_cmd_cnt_r ;
// leda B_3219 on
// leda B_3200 on
// leda BTTF_D002 on
// leda W484 on

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

// Count how much of the read commands outstanding
reg [OUT_CMD_CNT_W:0] out_rd_cmd_cnt_r;
wire out_rd_cmd_cnt_ovf = (out_rd_cmd_cnt_r == $unsigned(OUT_CMD_NUM));
assign out_rd_cmd_cnt_udf = (out_rd_cmd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
// The ibp_rd cmd counter increased when a IBP read command accepted to the axi_ibp_rd stage
wire out_rd_cmd_cnt_inc = (ibp2axi_arvalid & ibp2axi_arready);
// The ibp_rd cmd counter decreased when a IBP read response (last) sent back to ibp
wire ibp2axi_rd_last_hshked = ibp2axi_rvalid & ibp2axi_rready & ibp2axi_rlast;
wire out_rd_cmd_cnt_dec = ibp2axi_rd_last_hshked;
wire out_rd_cmd_cnt_ena = (out_rd_cmd_cnt_inc | out_rd_cmd_cnt_dec ) ;
// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
wire [OUT_CMD_CNT_W:0] out_rd_cmd_cnt_nxt =
      ( out_rd_cmd_cnt_inc & (~out_rd_cmd_cnt_dec)) ? (out_rd_cmd_cnt_r + 1'b1)
    : (~out_rd_cmd_cnt_inc &  out_rd_cmd_cnt_dec) ? (out_rd_cmd_cnt_r - 1'b1)
    : out_rd_cmd_cnt_r ;
// leda B_3219 on
// leda B_3200 on
// leda BTTF_D002 on
// leda W484 on

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

assign out_cmd_cnt_ovf = (out_wr_cmd_cnt_ovf | out_rd_cmd_cnt_ovf);
assign no_out_cmd = (out_wr_cmd_cnt_udf & out_rd_cmd_cnt_udf);

alb_mss_fab_mst_axi_buffer
  #(
    .O_SUPPORT_RTIO (1),
    .I_SUPPORT_RTIO (0),
    .CHNL_FIFO_DEPTH(CHNL_FIFO_DEPTH),
    .ID_W           (ID_W),
    .USER_W         (USER_W),
    .RGON_W         (1),
    .ADDR_W         (ADDR_W),
    .DATA_W         (DATA_W)
    ) u_ibp2axi_axi_buffer
  (
  .i_sync_rst_r     (1'b0       ),

  .i_axi_arid       (ibp2axi_arid       ),
  .i_axi_arvalid    (ibp2axi_arvalid_raw),
  .i_axi_arready    (ibp2axi_arready_raw),
  .i_axi_araddr     (ibp2axi_araddr     ),
  .i_axi_arcache    (ibp2axi_arcache    ),
  .i_axi_arprot     (ibp2axi_arprot     ),
  .i_axi_arlock     (ibp2axi_arlock     ),
  .i_axi_arburst    (ibp2axi_arburst    ),
  .i_axi_arlen      (ibp2axi_arlen      ),
  .i_axi_arsize     (ibp2axi_arsize     ),
  .i_axi_aruser     (ibp2axi_aruser     ),
  .i_axi_arregion   (1'b0),

  .i_axi_awid       (ibp2axi_awid       ),
  .i_axi_awvalid    (ibp2axi_awvalid_raw),
  .i_axi_awready    (ibp2axi_awready_raw),
  .i_axi_awaddr     (ibp2axi_awaddr     ),
  .i_axi_awcache    (ibp2axi_awcache    ),
  .i_axi_awprot     (ibp2axi_awprot     ),
  .i_axi_awlock     (ibp2axi_awlock     ),
  .i_axi_awburst    (ibp2axi_awburst    ),
  .i_axi_awlen      (ibp2axi_awlen      ),
  .i_axi_awsize     (ibp2axi_awsize     ),
  .i_axi_awuser     (ibp2axi_awuser     ),
  .i_axi_awregion   (1'b0),

  .i_axi_rid        (ibp2axi_rid        ),
  .i_axi_rvalid     (ibp2axi_rvalid_raw ),
  .i_axi_rready     (ibp2axi_rready_raw ),
  .i_axi_rdata      (ibp2axi_rdata      ),
  .i_axi_rresp      (ibp2axi_rresp      ),
  .i_axi_rlast      (ibp2axi_rlast      ),

  .i_axi_wid        (ibp2axi_wid        ),
  .i_axi_wvalid     (ibp2axi_wvalid     ),
  .i_axi_wready     (ibp2axi_wready     ),
  .i_axi_wdata      (ibp2axi_wdata      ),
  .i_axi_wstrb      (ibp2axi_wstrb      ),
  .i_axi_wlast      (ibp2axi_wlast      ),

  .i_axi_bid        (ibp2axi_bid        ),
  .i_axi_bvalid     (ibp2axi_bvalid_raw ),
  .i_axi_bready     (ibp2axi_bready_raw ),
  .i_axi_bresp      (ibp2axi_bresp      ),

  .o_axi_arid       (axi_arid       ),
  .o_axi_arvalid    (axi_arvalid    ),
  .o_axi_arready    (axi_arready    ),
  .o_axi_araddr     (axi_araddr     ),
  .o_axi_arcache    (axi_arcache    ),
  .o_axi_arprot     (axi_arprot     ),
  .o_axi_arlock     (axi_arlock     ),
  .o_axi_arburst    (axi_arburst    ),
  .o_axi_arlen      (axi_arlen      ),
  .o_axi_arsize     (axi_arsize     ),
  .o_axi_aruser     (axi_aruser     ),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .o_axi_arregion   (),
// leda B_1011 on
// leda WV951025 on

  .o_axi_awid       (axi_awid       ),
  .o_axi_awvalid    (axi_awvalid    ),
  .o_axi_awready    (axi_awready    ),
  .o_axi_awaddr     (axi_awaddr     ),
  .o_axi_awcache    (axi_awcache    ),
  .o_axi_awprot     (axi_awprot     ),
  .o_axi_awlock     (axi_awlock     ),
  .o_axi_awburst    (axi_awburst    ),
  .o_axi_awlen      (axi_awlen      ),
  .o_axi_awsize     (axi_awsize     ),
  .o_axi_awuser     (axi_awuser     ),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .o_axi_awregion   (),
// leda B_1011 on
// leda WV951025 on

  .o_axi_rid        (axi_rid        ),
  .o_axi_rvalid     (axi_rvalid     ),
  .o_axi_rready     (axi_rready     ),
  .o_axi_rdata      (axi_rdata      ),
  .o_axi_rresp      (axi_rresp      ),
  .o_axi_rlast      (axi_rlast      ),

  .o_axi_wid        (axi_wid        ),
  .o_axi_wvalid     (axi_wvalid     ),
  .o_axi_wready     (axi_wready     ),
  .o_axi_wdata      (axi_wdata      ),
  .o_axi_wstrb      (axi_wstrb      ),
  .o_axi_wlast      (axi_wlast      ),

  .o_axi_bid        (axi_bid        ),
  .o_axi_bvalid     (axi_bvalid     ),
  .o_axi_bready     (axi_bready     ),
  .o_axi_bresp      (axi_bresp      ),

  .clk              (clk              ),
  .i_clk_en         (1'b1             ),
  .o_clk_en         (bus_clk_en       ),
  .rst_a            (rst_a            )
  );

endmodule // alb_mss_fab_ibp2axi

