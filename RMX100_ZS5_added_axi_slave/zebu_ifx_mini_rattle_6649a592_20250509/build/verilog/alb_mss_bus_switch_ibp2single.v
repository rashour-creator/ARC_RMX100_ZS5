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
// ibp2single module
//
// ===========================================================================
//
// Description:
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"

module mss_bus_switch_ibp2single
  #(
    parameter CUT_IN2OUT_WR_ACPT = 0,
    // ADDR_W indicate the width of address
        // It can be any value
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
        // It can be any value
    parameter DATA_W = 32,
    parameter RGON_W = 16,
    parameter USER_W = 16,
    parameter SPLT_FIFO_DEPTH = 4
    )
  (

  input  clk,  // clock signal
  input  rst_a, // reset signal

  // The "i_xxx" bus is the one IBP in
  //
  input  i_ibp_cmd_valid ,
  output i_ibp_cmd_accept,
  input  i_ibp_cmd_read,
  input  [ADDR_W-1:0] i_ibp_cmd_addr,
  input  i_ibp_cmd_wrap,
  input  [3-1:0] i_ibp_cmd_data_size,
  input  [4-1:0] i_ibp_cmd_burst_size,
  input  i_ibp_cmd_lock,
  input  [2-1:0] i_ibp_cmd_prot,
  input  [4-1:0] i_ibp_cmd_cache,
  input  i_ibp_cmd_excl,

  output i_ibp_rd_valid,
  input  i_ibp_rd_accept,
  output [DATA_W-1:0] i_ibp_rd_data,
  output i_ibp_rd_last,
  output i_ibp_err_rd,
  output i_ibp_rd_excl_ok,

  input  i_ibp_wr_valid,
  output i_ibp_wr_accept,
  input  [DATA_W-1:0] i_ibp_wr_data,
  input  [(DATA_W/8)-1:0] i_ibp_wr_mask,
  input  i_ibp_wr_last,

  output i_ibp_wr_done,
  output i_ibp_err_wr,
  output i_ibp_wr_excl_done,
  input  i_ibp_wr_resp_accept,

  input  [RGON_W-1:0] i_ibp_cmd_rgon,
  input  [USER_W-1:0] i_ibp_cmd_user,
  // The "o_xxx" bus is the one IBP out
  //
  output o_ibp_cmd_valid ,
  input  o_ibp_cmd_accept,
  output o_ibp_cmd_read,
  output [ADDR_W-1:0] o_ibp_cmd_addr,
  output o_ibp_cmd_wrap,
  output [3-1:0] o_ibp_cmd_data_size,
  output [4-1:0] o_ibp_cmd_burst_size,
  output o_ibp_cmd_lock,
  output o_ibp_cmd_excl,
  output [2-1:0] o_ibp_cmd_prot,
  output [4-1:0] o_ibp_cmd_cache,

  output o_ibp_cmd_burst_en,
  output [3-1:0] o_ibp_cmd_burst_type,
  output o_ibp_cmd_burst_last,

  output [RGON_W-1:0] o_ibp_cmd_rgon,
  output [USER_W-1:0] o_ibp_cmd_user,

  input  o_ibp_rd_valid,
  output o_ibp_rd_accept,
  input  [DATA_W-1:0] o_ibp_rd_data,
  input  o_ibp_err_rd,
  input o_ibp_rd_last,
  input o_ibp_rd_excl_ok,

  output o_ibp_wr_valid,
  input  o_ibp_wr_accept,
  output [DATA_W-1:0] o_ibp_wr_data,
  output [(DATA_W/8)-1:0] o_ibp_wr_mask,
  output o_ibp_wr_last,

  input  o_ibp_wr_done,
  input  o_ibp_err_wr,
  output o_ibp_wr_resp_accept,
  input  o_ibp_wr_excl_done

  );


// Full IBP to be split into single-beat IBP transactions:
// * non-burst transaction will be unchanged
// * any burst transaction will be split into single-beat IBP
//
wire i_ibp_need_splt = (~(i_ibp_cmd_burst_size == 4'b0));


// Implement a side-buffer to split the bursts to single-beat transactions
reg [3:0] sdb_ibp_splt_cnt_r;
// When o_ibp cmd chnl handshaked and it is a IBP burst mode
wire o_ibp_cmd_sel_sdb;
wire o_ibp_cmd_sel_i;
wire sdb_ibp_splt_cnt_set = o_ibp_cmd_sel_i & i_ibp_need_splt & o_ibp_cmd_valid & o_ibp_cmd_accept;
// When o_ibp cmd chnl handshaked and it is selecting side-buffer
wire sdb_ibp_splt_cnt_last = (sdb_ibp_splt_cnt_r == 4'b0);
wire sdb_ibp_cmd_hshked = o_ibp_cmd_sel_sdb & o_ibp_cmd_valid & o_ibp_cmd_accept;
wire sdb_ibp_splt_cnt_dec_last = sdb_ibp_cmd_hshked & sdb_ibp_splt_cnt_last;
wire sdb_ibp_splt_cnt_dec_nonlast = sdb_ibp_cmd_hshked & (~(sdb_ibp_splt_cnt_last));
wire sdb_ibp_splt_cnt_ena = sdb_ibp_splt_cnt_set | sdb_ibp_splt_cnt_dec_nonlast;
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
wire [3:0] sdb_ibp_splt_cnt_nxt = ({4{sdb_ibp_splt_cnt_set}} & (i_ibp_cmd_burst_size - 1)) | ({4{sdb_ibp_splt_cnt_dec_nonlast}} & (sdb_ibp_splt_cnt_r - 1));
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on

reg [ADDR_W-1:0] sdb_ibp_cmd_addr_r;
wire [ADDR_W-1:0] sdb_ibp_cmd_addr_r_nxt;
reg sdb_ibp_cmd_wrap_r;
reg [3:0] sdb_ibp_cmd_burst_size_r;
reg [2:0] sdb_ibp_cmd_data_size_r;

wire [ADDR_W-1:0] sdb_ibp_cmd_addr_nxt;


wire [ADDR_W-1:0] i_ibp_cmd_addr_round;
assign i_ibp_cmd_addr_round =
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
wire [ADDR_W-1:0] sdb_ibp_cmd_addr_inc_nxt = (sdb_ibp_cmd_addr_r + (1 << sdb_ibp_cmd_data_size_r));
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on
wire [ADDR_W-1:0] sdb_ibp_cmd_wrap_vec = (~{{ADDR_W-4{1'b0}}, sdb_ibp_cmd_burst_size_r}) << sdb_ibp_cmd_data_size_r;
wire [ADDR_W-1:0] sdb_ibp_cmd_addr_wrap_nxt = (sdb_ibp_cmd_wrap_vec & sdb_ibp_cmd_addr_r)
                                              | ((~sdb_ibp_cmd_wrap_vec) & sdb_ibp_cmd_addr_inc_nxt);

assign sdb_ibp_cmd_addr_r_nxt     = sdb_ibp_cmd_wrap_r ? sdb_ibp_cmd_addr_wrap_nxt : sdb_ibp_cmd_addr_inc_nxt;

assign sdb_ibp_cmd_addr_nxt       =   ({ADDR_W{sdb_ibp_splt_cnt_set}} & i_ibp_cmd_addr_round)
                                    | ({ADDR_W{sdb_ibp_splt_cnt_dec_nonlast}} & sdb_ibp_cmd_addr_r_nxt);

always @(posedge clk or posedge rst_a)
begin : sdb_ibp_splt_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      sdb_ibp_splt_cnt_r       <= 4'b0;
      sdb_ibp_cmd_addr_r       <= {ADDR_W{1'b0}}  ;
  end
  else if (sdb_ibp_splt_cnt_ena == 1'b1) begin
      sdb_ibp_splt_cnt_r       <= sdb_ibp_splt_cnt_nxt;
      sdb_ibp_cmd_addr_r       <= sdb_ibp_cmd_addr_nxt        ;
  end
end

reg  sdb_ibp_cmd_valid_r;
wire sdb_ibp_cmd_valid_set = sdb_ibp_splt_cnt_set;
// When ibp cmd chnl handshaked and it is selecting side-buffer and the cnt is zero
wire sdb_ibp_cmd_valid_clr = sdb_ibp_splt_cnt_dec_last;
wire sdb_ibp_cmd_valid_ena = sdb_ibp_cmd_valid_set |  sdb_ibp_cmd_valid_clr;
wire sdb_ibp_cmd_valid_nxt = sdb_ibp_cmd_valid_set | (~sdb_ibp_cmd_valid_clr);

always @(posedge clk or posedge rst_a)
begin : sdb_ibp_cmd_valid_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      sdb_ibp_cmd_valid_r        <= 1'b0;
  end
  else if (sdb_ibp_cmd_valid_ena == 1'b1) begin
      sdb_ibp_cmd_valid_r        <= sdb_ibp_cmd_valid_nxt;
  end
end

// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg sdb_ibp_cmd_read_r;
reg sdb_ibp_cmd_lock_r;
reg sdb_ibp_cmd_excl_r;
reg [1:0] sdb_ibp_cmd_prot_r;
reg [3:0] sdb_ibp_cmd_cache_r;
reg [RGON_W-1:0] sdb_ibp_cmd_rgon_r;
reg [USER_W-1:0] sdb_ibp_cmd_user_r;
// leda NTL_CON32 on

always @(posedge clk or posedge rst_a)
begin : sdb_ibp_cmd_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      sdb_ibp_cmd_read_r       <= 1'b0  ;
      sdb_ibp_cmd_wrap_r       <= 1'b0  ;
      sdb_ibp_cmd_burst_size_r <= 4'b0  ;
      sdb_ibp_cmd_data_size_r  <= 3'b0  ;
      sdb_ibp_cmd_lock_r       <= 1'b0  ;
      sdb_ibp_cmd_excl_r       <= 1'b0  ;
      sdb_ibp_cmd_prot_r       <= 2'b0  ;
      sdb_ibp_cmd_cache_r      <= 4'b0  ;
      sdb_ibp_cmd_rgon_r       <= {RGON_W{1'b0}}  ;
      sdb_ibp_cmd_user_r       <= {USER_W{1'b0}}  ;
  end
  else if (sdb_ibp_splt_cnt_set == 1'b1) begin
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
      sdb_ibp_cmd_read_r       <= i_ibp_cmd_read        ;
      sdb_ibp_cmd_wrap_r       <= i_ibp_cmd_wrap;
      sdb_ibp_cmd_burst_size_r <= i_ibp_cmd_burst_size;
      sdb_ibp_cmd_data_size_r  <= i_ibp_cmd_data_size   ;
      sdb_ibp_cmd_lock_r       <= i_ibp_cmd_lock        ;
      sdb_ibp_cmd_excl_r       <= i_ibp_cmd_excl        ;
      sdb_ibp_cmd_prot_r       <= i_ibp_cmd_prot        ;
      sdb_ibp_cmd_cache_r      <= i_ibp_cmd_cache       ;
      sdb_ibp_cmd_rgon_r       <= i_ibp_cmd_rgon        ;
      sdb_ibp_cmd_user_r       <= i_ibp_cmd_user        ;
// leda NTL_CON32 on
  end
end

//
wire wd_splt_uop_fifo_full ;
wire rd_splt_uop_fifo_full ;
wire wrsp_splt_uop_fifo_full ;

assign o_ibp_cmd_sel_sdb = sdb_ibp_cmd_valid_r;
assign o_ibp_cmd_sel_i = ~o_ibp_cmd_sel_sdb;
assign i_ibp_cmd_accept = o_ibp_cmd_accept & o_ibp_cmd_valid & o_ibp_cmd_sel_i
                        & (~rd_splt_uop_fifo_full)
                        & (~wd_splt_uop_fifo_full)
                        & (~wrsp_splt_uop_fifo_full);


assign o_ibp_cmd_valid = (sdb_ibp_cmd_valid_r | i_ibp_cmd_valid)
                        & (~rd_splt_uop_fifo_full)
                        & (~wd_splt_uop_fifo_full)
                        & (~wrsp_splt_uop_fifo_full);
wire o_ibp_cmd_splt_uop = o_ibp_cmd_sel_sdb ? (sdb_ibp_cmd_valid_r & (~sdb_ibp_splt_cnt_last)) : i_ibp_need_splt;
assign o_ibp_cmd_read  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_read_r : i_ibp_cmd_read;
assign o_ibp_cmd_addr  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_addr_r_nxt : i_ibp_cmd_addr;
assign o_ibp_cmd_wrap  = o_ibp_cmd_sel_sdb ? 1'b0 : (i_ibp_cmd_wrap & (~i_ibp_need_splt));
assign o_ibp_cmd_burst_size  = o_ibp_cmd_sel_sdb ? 4'b0 : (i_ibp_need_splt ? 4'b0 : i_ibp_cmd_burst_size);
assign o_ibp_cmd_data_size  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_data_size_r : i_ibp_cmd_data_size;
assign o_ibp_cmd_lock  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_lock_r : i_ibp_cmd_lock;
assign o_ibp_cmd_excl  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_excl_r : i_ibp_cmd_excl;
assign o_ibp_cmd_prot  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_prot_r : i_ibp_cmd_prot;
assign o_ibp_cmd_cache  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_cache_r : i_ibp_cmd_cache;

assign o_ibp_cmd_rgon  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_rgon_r : i_ibp_cmd_rgon;
assign o_ibp_cmd_user  = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_user_r : i_ibp_cmd_user;

// The wd_splt_uop_fifo is just store the 1bit "split_uop" indication, so that
// when the wdata is coming from i_IBP, it know it is the split uop into
// single-beat and have xx_last asserted.
wire wd_splt_uop_fifo_wen_raw  ;
wire wd_splt_uop_fifo_ren_raw  ;
wire wd_splt_uop_fifo_wen  ;
wire wd_splt_uop_fifo_ren  ;
wire wd_splt_uop_fifo_empty;
wire byp_wd_uop_info_fifo = wd_splt_uop_fifo_empty & wd_splt_uop_fifo_wen_raw & wd_splt_uop_fifo_ren_raw;


wire wd_splt_uop_fifo_wdat ;
wire wd_splt_uop_fifo_rdat ;
// Write when IBP cmd (write) is handshaked
assign wd_splt_uop_fifo_wen_raw  = o_ibp_cmd_valid & o_ibp_cmd_accept & (~o_ibp_cmd_read);
assign wd_splt_uop_fifo_wen = wd_splt_uop_fifo_wen_raw & (~byp_wd_uop_info_fifo);
assign wd_splt_uop_fifo_wdat = o_ibp_cmd_splt_uop;
// Read when IBP wd channel is handshaked (last)
assign wd_splt_uop_fifo_ren_raw  = o_ibp_wr_valid & o_ibp_wr_accept & o_ibp_wr_last;
assign wd_splt_uop_fifo_ren  = wd_splt_uop_fifo_ren_raw & (~byp_wd_uop_info_fifo);

wire wd_is_splt_uop = wd_splt_uop_fifo_rdat & (~wd_splt_uop_fifo_empty) | (wd_splt_uop_fifo_wdat & wd_splt_uop_fifo_empty);



wire wd_splt_uop_fifo_i_valid;
wire wd_splt_uop_fifo_o_valid;
wire wd_splt_uop_fifo_i_ready;
wire wd_splt_uop_fifo_o_ready;
assign wd_splt_uop_fifo_i_valid = wd_splt_uop_fifo_wen;
assign wd_splt_uop_fifo_full    = (~wd_splt_uop_fifo_i_ready);
assign wd_splt_uop_fifo_o_ready = wd_splt_uop_fifo_ren;
assign wd_splt_uop_fifo_empty   = (~wd_splt_uop_fifo_o_valid);

mss_bus_switch_fifo # (
  .FIFO_WIDTH(1),
  .FIFO_DEPTH(SPLT_FIFO_DEPTH),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) wd_splt_uop_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (wd_splt_uop_fifo_i_valid),
  .i_ready   (wd_splt_uop_fifo_i_ready),
  .o_valid   (wd_splt_uop_fifo_o_valid),
  .o_ready   (wd_splt_uop_fifo_o_ready),
  .i_data    (wd_splt_uop_fifo_wdat ),
  .o_data    (wd_splt_uop_fifo_rdat ),
  // leda B_1011 off
  // leda WV951025 off
  // LMD: Port is not completely connected
  // LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
  // leda B_1011 on
  // leda WV951025 on
  .clk       (clk  ),
  .rst_a     (rst_a)
);

// The rd_splt_uop_fifo is just store the 1bit "split_uop" indication, so that
// when the rdata is coming from IBP, it know it is the split uop and
// have xx_last de-asserted.
wire rd_splt_uop_fifo_wen  ;
wire rd_splt_uop_fifo_ren  ;
wire rd_splt_uop_fifo_wdat ;
wire rd_splt_uop_fifo_rdat ;
wire rd_splt_uop_fifo_empty;
wire o_ibp_rdchnl_valid;
// Write when IBP cmd (read) is handshaked
assign rd_splt_uop_fifo_wen  = o_ibp_cmd_valid & o_ibp_cmd_accept & o_ibp_cmd_read;
assign rd_splt_uop_fifo_wdat = o_ibp_cmd_splt_uop;
// Read when IBP rd channel is handshaked (last)
assign rd_splt_uop_fifo_ren  = o_ibp_rdchnl_valid & o_ibp_rd_accept & o_ibp_rd_last;

wire rd_is_splt_uop = rd_splt_uop_fifo_rdat & (~rd_splt_uop_fifo_empty);


wire rd_splt_uop_fifo_i_valid;
wire rd_splt_uop_fifo_o_valid;
wire rd_splt_uop_fifo_i_ready;
wire rd_splt_uop_fifo_o_ready;
assign rd_splt_uop_fifo_i_valid = rd_splt_uop_fifo_wen;
assign rd_splt_uop_fifo_full    = (~rd_splt_uop_fifo_i_ready);
assign rd_splt_uop_fifo_o_ready = rd_splt_uop_fifo_ren;
assign rd_splt_uop_fifo_empty   = (~rd_splt_uop_fifo_o_valid);

mss_bus_switch_fifo # (
  .FIFO_WIDTH(1),
  .FIFO_DEPTH(SPLT_FIFO_DEPTH),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) rd_splt_uop_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (rd_splt_uop_fifo_i_valid),
  .i_ready   (rd_splt_uop_fifo_i_ready),
  .o_valid   (rd_splt_uop_fifo_o_valid),
  .o_ready   (rd_splt_uop_fifo_o_ready),
  .i_data    (rd_splt_uop_fifo_wdat ),
  .o_data    (rd_splt_uop_fifo_rdat ),
  // leda B_1011 off
  // leda WV951025 off
  // LMD: Port is not completely connected
  // LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
  // leda B_1011 on
  // leda WV951025 on
  .clk       (clk  ),
  .rst_a     (rst_a)
);

// The wrsp_splt_uop_fifo is just store the 1bit "split_uop" indication, so that
// when the wrsp is coming from IBP, it know it is the split uop and
// have wrsp_valid de-asserted.
wire wrsp_splt_uop_fifo_wen  ;
wire wrsp_splt_uop_fifo_ren  ;
wire wrsp_splt_uop_fifo_wdat ;
wire wrsp_splt_uop_fifo_rdat ;
wire wrsp_splt_uop_fifo_empty;
wire o_ibp_wr_resp_valid;

// Write when IBP cmd (write) is handshaked
assign wrsp_splt_uop_fifo_wen  = o_ibp_cmd_valid & o_ibp_cmd_accept & (~o_ibp_cmd_read);
assign wrsp_splt_uop_fifo_wdat = o_ibp_cmd_splt_uop;
// Read when IBP wrsp channel is handshaked (last)
assign wrsp_splt_uop_fifo_ren  = o_ibp_wr_resp_valid & o_ibp_wr_resp_accept;

wire wrsp_is_splt_uop = wrsp_splt_uop_fifo_rdat & (~wrsp_splt_uop_fifo_empty);


wire wrsp_splt_uop_fifo_i_valid;
wire wrsp_splt_uop_fifo_o_valid;
wire wrsp_splt_uop_fifo_i_ready;
wire wrsp_splt_uop_fifo_o_ready;
assign wrsp_splt_uop_fifo_i_valid = wrsp_splt_uop_fifo_wen;
assign wrsp_splt_uop_fifo_full    = (~wrsp_splt_uop_fifo_i_ready);
assign wrsp_splt_uop_fifo_o_ready = wrsp_splt_uop_fifo_ren;
assign wrsp_splt_uop_fifo_empty   = (~wrsp_splt_uop_fifo_o_valid);

mss_bus_switch_fifo # (
  .FIFO_WIDTH(1),
  .FIFO_DEPTH(SPLT_FIFO_DEPTH),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) wrsp_splt_uop_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (wrsp_splt_uop_fifo_i_valid),
  .i_ready   (wrsp_splt_uop_fifo_i_ready),
  .o_valid   (wrsp_splt_uop_fifo_o_valid),
  .o_ready   (wrsp_splt_uop_fifo_o_ready),
  .i_data    (wrsp_splt_uop_fifo_wdat ),
  .o_data    (wrsp_splt_uop_fifo_rdat ),
  // leda B_1011 off
  // leda WV951025 off
  // LMD: Port is not completely connected
  // LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
  // leda B_1011 on
  // leda WV951025 on
  .clk       (clk  ),
  .rst_a     (rst_a)
);

wire o_ibp_cmd_wait_wd;
generate
    if(CUT_IN2OUT_WR_ACPT == 1) begin: cut_in2out_wr_acpt_gen
      assign o_ibp_cmd_wait_wd = (~wd_splt_uop_fifo_empty) | i_ibp_cmd_accept;
    end
    else begin: no_cut_in2out_wr_acpt_gen
      assign o_ibp_cmd_wait_wd = (~wd_splt_uop_fifo_empty) | (o_ibp_cmd_valid & (~o_ibp_cmd_read));
    end
endgenerate

// Convert for Write data channel
    // Just direct assigned from IBP wdata channel to o_IBP
assign o_ibp_wr_valid = i_ibp_wr_valid & o_ibp_cmd_wait_wd;
assign o_ibp_wr_data = i_ibp_wr_data;
assign o_ibp_wr_mask = i_ibp_wr_mask;
assign o_ibp_wr_last = i_ibp_wr_last | wd_is_splt_uop;
assign i_ibp_wr_accept = o_ibp_wr_accept & o_ibp_cmd_wait_wd;
//
// Convert for Read data channel
    // Just direct assigned from o_IBP rdata channel to IBP
assign i_ibp_rd_data = o_ibp_rd_data;
assign i_ibp_rd_last = o_ibp_rd_last & (~rd_is_splt_uop);
assign o_ibp_rdchnl_valid = (o_ibp_rd_valid | o_ibp_err_rd);
assign i_ibp_rdchnl_valid = o_ibp_rdchnl_valid & (~rd_splt_uop_fifo_empty);
assign i_ibp_err_rd = i_ibp_rdchnl_valid & o_ibp_err_rd;
assign i_ibp_rd_excl_ok = o_ibp_rd_excl_ok;
assign i_ibp_rd_valid = i_ibp_rdchnl_valid & (~o_ibp_err_rd);
assign o_ibp_rd_accept = i_ibp_rdchnl_valid & i_ibp_rd_accept & (~rd_splt_uop_fifo_empty);

// Convert for Write response channel
    // Just direct assigned from o_IBP wresp channel to IBP
reg o_ibp_err_wr_r;
wire o_ibp_err_wr_nxt;
wire o_ibp_err_wr_ena;
wire i_ibp_wr_resp_valid;
wire o_ibp_err_wr_set = (o_ibp_wr_resp_valid & o_ibp_wr_resp_accept & wrsp_is_splt_uop);
wire o_ibp_err_wr_clr = i_ibp_wr_resp_valid & i_ibp_wr_resp_accept;
assign o_ibp_err_wr_nxt = o_ibp_err_wr_set ? (o_ibp_err_wr_r | o_ibp_err_wr) : o_ibp_err_wr_clr ? 1'b0 : o_ibp_err_wr_r;
assign o_ibp_err_wr_ena = o_ibp_err_wr_set | o_ibp_err_wr_clr;

always @(posedge clk or posedge rst_a)
begin : o_ibp_err_wr_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      o_ibp_err_wr_r        <= 1'b0;
  end
  else if (o_ibp_err_wr_ena == 1'b1) begin
      o_ibp_err_wr_r        <= o_ibp_err_wr_nxt;
  end
end
//
assign o_ibp_wr_resp_valid = o_ibp_err_wr | o_ibp_wr_done | o_ibp_wr_excl_done;
assign o_ibp_wr_resp_accept = ((i_ibp_wr_resp_valid & i_ibp_wr_resp_accept) | wrsp_is_splt_uop) & (~wrsp_splt_uop_fifo_empty);

assign i_ibp_wr_resp_valid = o_ibp_wr_resp_valid & (~wrsp_is_splt_uop) & (~wrsp_splt_uop_fifo_empty);
assign i_ibp_err_wr = i_ibp_wr_resp_valid & (o_ibp_err_wr | o_ibp_err_wr_r); // The error response need to be accumulated
assign i_ibp_wr_done = i_ibp_wr_resp_valid & (~i_ibp_err_wr) & o_ibp_wr_done;
assign i_ibp_wr_excl_done = i_ibp_wr_resp_valid & (~i_ibp_err_wr) & o_ibp_wr_excl_done;


  // AHB protocol macros
  localparam AHB_BURST_SINGLE = 3'b000;   // AHB Burst Type
  localparam AHB_BURST_INCR   = 3'b001;
  localparam AHB_BURST_WRAP4  = 3'b010;
  localparam AHB_BURST_INCR4  = 3'b011;
  localparam AHB_BURST_WRAP8  = 3'b100;
  localparam AHB_BURST_INCR8  = 3'b101;
  localparam AHB_BURST_WRAP16 = 3'b110;
  localparam AHB_BURST_INCR16 = 3'b111;

  // AHB related side-band signals
  wire  [3-1:0] ibp_cmd_burst_type_mux;

  wire       ibp_cmd_wrap_mux       = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_wrap_r : i_ibp_cmd_wrap;
  wire       ibp_cmd_read_mux       = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_read_r : i_ibp_cmd_read;
  wire [3:0] ibp_cmd_burst_size_mux = o_ibp_cmd_sel_sdb ? sdb_ibp_cmd_burst_size_r : i_ibp_cmd_burst_size;
  wire       ibp_cmd_wrap2_ind      = (sdb_ibp_cmd_wrap_r) && (sdb_ibp_cmd_burst_size_r == 4'h1);

  assign     o_ibp_cmd_burst_en     = o_ibp_cmd_sel_sdb & (sdb_ibp_cmd_read_r & (~ibp_cmd_wrap2_ind)); // only for burst_read
  assign     o_ibp_cmd_burst_type   = ibp_cmd_burst_type_mux;                                          // only for burst_read
  assign     o_ibp_cmd_burst_last   = sdb_ibp_splt_cnt_last & (~(o_ibp_cmd_sel_i & i_ibp_need_splt));  // for both read/write

  assign ibp_cmd_burst_type_mux = (~ibp_cmd_read_mux) ? AHB_BURST_SINGLE :
                 (ibp_cmd_burst_size_mux == 4'b0000) ? AHB_BURST_SINGLE :
                 (ibp_cmd_burst_size_mux == 4'b0011) ? {2'b01, ~ibp_cmd_wrap_mux} : // WRAP4/INCR4;
                 (ibp_cmd_burst_size_mux == 4'b0111) ? {2'b10, ~ibp_cmd_wrap_mux} : // WRAP8/INCR8;
                 (ibp_cmd_burst_size_mux == 4'b1111) ? {2'b11, ~ibp_cmd_wrap_mux} : // WRAP16/INCR16;
                                                          AHB_BURST_INCR;

endmodule // mss_bus_switch_ibp2single
