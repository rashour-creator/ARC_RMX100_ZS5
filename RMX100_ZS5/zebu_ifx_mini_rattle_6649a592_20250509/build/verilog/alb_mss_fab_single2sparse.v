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
// single-ibp to check the sparse mask
//
// ===========================================================================
//
// Description:
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"




module alb_mss_fab_single2sparse
  #(
    // ADDR_W indicate the width of address
        // It can be any value
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
        // It can be any value
    parameter DATA_W = 64,
    // ALSB indicate least significant bit of the address
        // It should be log2(DATA_W/8), eg: 2 for 32b, 3 for 64b, 4 for 128b
    parameter ALSB = 3
    )
  (

  input  clk,  // clock signal
  input  rst_a, // reset signal
  //input  bigendian,   // If true, then bigendian

  // The "i_xxx" bus is the one IBP in
  //
  input  wire              i_ibp_cmd_valid ,
  output wire              i_ibp_cmd_accept,
  input  wire              i_ibp_cmd_read,
  input  wire [ADDR_W-1:0] i_ibp_cmd_addr,
  input  wire              i_ibp_cmd_wrap,
  input  wire [3-1:0]      i_ibp_cmd_data_size,
  input  wire [4-1:0]      i_ibp_cmd_burst_size,
  input  wire              i_ibp_cmd_lock,
  input  wire [2-1:0]      i_ibp_cmd_prot,
  input  wire [4-1:0]      i_ibp_cmd_cache,
  input  wire              i_ibp_cmd_excl,

  input  wire              i_ibp_cmd_burst_en,
  input  wire [3-1:0]      i_ibp_cmd_burst_type,
  input  wire              i_ibp_cmd_burst_last,

  output wire              i_ibp_rd_valid,
  input  wire              i_ibp_rd_accept,
  output wire [DATA_W-1:0] i_ibp_rd_data,
  output wire              i_ibp_err_rd,
  output wire              i_ibp_rd_excl_ok,

    // write data channel
  input  wire              i_ibp_wr_valid,
  output wire              i_ibp_wr_accept,
  input  wire [DATA_W-1:0] i_ibp_wr_data,
  input  wire [(DATA_W/8)-1:0] i_ibp_wr_mask,

    // write response channel
    // This module do not support id
  output wire              i_ibp_wr_done,
  output wire              i_ibp_err_wr,
  input  wire              i_ibp_wr_resp_accept,
  output wire              i_ibp_wr_excl_done,

  // The "o_xxx" bus is the one IBP out
  //
  output wire              o_ibp_cmd_valid ,
  input  wire              o_ibp_cmd_accept,
  output wire              o_ibp_cmd_read,
  output wire [ADDR_W-1:0] o_ibp_cmd_addr,
  output wire              o_ibp_cmd_wrap,
  output wire [3-1:0]      o_ibp_cmd_data_size,
  output wire [4-1:0]      o_ibp_cmd_burst_size,
  output wire              o_ibp_cmd_lock,
  output wire [2-1:0]      o_ibp_cmd_prot,
  output wire [4-1:0]      o_ibp_cmd_cache,
  output wire              o_ibp_cmd_excl,

  output wire              o_ibp_cmd_burst_en,
  output wire [3-1:0]      o_ibp_cmd_burst_type,
  output wire              o_ibp_cmd_burst_last,
  output wire              o_ibp_cmd_wr_splt_last,

  input  wire              o_ibp_rd_valid,
  output wire              o_ibp_rd_accept,
  input  wire [DATA_W-1:0] o_ibp_rd_data,
  input  wire              o_ibp_err_rd,

  input  wire              o_ibp_rd_excl_ok,

    // write data channel
  output wire              o_ibp_wr_valid,
  input  wire              o_ibp_wr_accept,
  output wire [DATA_W-1:0] o_ibp_wr_data,

    // write response channel
    // This module do not support id
  input                    o_ibp_wr_done,
  input                    o_ibp_err_wr,
  output                   o_ibp_wr_resp_accept,
  input                    o_ibp_wr_excl_done

  );

  //--------------------------------------------
  // Parameters Definition
  //--------------------------------------------
  localparam WR_OUT_CMD_DEP = 5;        // at least 4 to ensure full piplined
                                        //   (the min value of 4 is determined by wcmd-wrsp latency)
                                        // use 5 to align with FIFOs depth in ahb_single2ahb
  //localparam LOG2_WR_OUT_CMD_DEP = 2;   // at least 4 to ensure full piplined

  // Because ibp2ahb at most have 5 outstandings (2 Afifo entries + 3 Rfifo entries)
  localparam OUT_CMD_CNT_W  = 3;// no need to worry about the cnt overflow then

  // 0:  i_ibp_data_size takes precedence over i_ibp_wr_mask,
  //     i_ibp_wr_mask should only assert bit field indicated by i_ibp_data_size and i_ibp_cmd_addr[ALSB-1:0]
  // 1:  i_ibp_wr_mask takes precedence over i_ibp_data_size,
  //     i_ibp_data_size are ignored when being not aligned with i_ibp_wr_mask
  localparam WRITE_MASK_PRECEDENCE = 0;

  //--------------------------------------------
  // Local wires/regs
  //--------------------------------------------
  // ibp side buffer wires/registers
  wire                            ibp_wr_sel_sdb;
  wire                            ibp_wr_sparse_splt;
  //reg                             ibp_wr_sel_sdb_r;
  //wire                            ibp_wr_sel_sdb_start;

  //wire                            ibp_wr_cmd_valid;
  //wire                            ibp_wr_cmd_accept;
  //wire [ADDR_W-1:0]               ibp_wr_cmd_addr;
  wire [3-1:0]                    ibp_wr_cmd_data_size;

  wire                            ibp_sw_full_mask;
  wire [(DATA_W/8)-1:0]           ibp_wr_mask_fnl;

  wire                            ibp_cmd_accept_tmp;
  wire                            ibp_wr_accept_tmp;

  //wire                            i_ibp_cmd_enable;
  //wire                            i_ibp_wr_enable;
  //wire                            o_ibp_cmd_enable;
  wire                            o_ibp_wr_enable;
  wire                            o_ibp_wresp_enable;

  wire                            sdb_ibp_splt_wresp_sel;
  wire                            sdb_ibp_dummy_wresp_sel;
  wire                            sdb_ibp_splt_wresp_sel_tmp;
  wire                            sdb_ibp_dummy_wresp_sel_tmp;
  wire                            sdb_ibp_wr_done_tmp;
  wire                            sdb_ibp_err_wr_tmp;
  wire                            sdb_ibp_wr_excl_done_tmp;
  wire                            sdb_ibp_wr_resp_accept_tmp;
  wire                            sdb_ibp_dummy_wr_resp_accept;
  //reg                             sdb_ibp_wr_done_r;
  reg                             sdb_ibp_err_wr_r;
  reg                             sdb_ibp_wr_excl_done_r;
  reg                             sdb_ibp_dummy_wr_done_r;

  wire                            sdb_ibp_splt_valid;
  wire                            sdb_ibp_cmd_valid;
  wire                            sdb_ibp_wr_valid;
  wire                            sdb_ibp_dummy_valid;

  wire [ADDR_W-1:0]               sdb_ibp_cmd_addr;

  // sdb ibp wcmd side buffer
  //wire [ADDR_W-1:ALSB]            sdb_ibp_cmd_addr;
  wire                            sdb_ibp_cmd_read;
  wire                            sdb_ibp_cmd_wrap;
  //wire [3-1:0]                    sdb_ibp_cmd_data_size;
  wire [4-1:0]                    sdb_ibp_cmd_burst_size;
  wire                            sdb_ibp_cmd_lock;
  wire [2-1:0]                    sdb_ibp_cmd_prot;
  wire [4-1:0]                    sdb_ibp_cmd_cache;
  wire                            sdb_ibp_cmd_excl;
  wire                            sdb_ibp_cmd_burst_en;
  wire [3-1:0]                    sdb_ibp_cmd_burst_type;
  wire                            sdb_ibp_cmd_burst_last;

  wire                            sdb_ibp_fifo_i_ready;

  wire [(DATA_W/8)-1:0]           wfifo_o_wr_mask;
  wire [DATA_W-1:0]               wfifo_o_wr_data;

  wire                            sdb_ibp_cmd_enable;
  wire                            sdb_ibp_wr_enable;
  wire                            sdb_ibp_dummy_wr_enable;
  wire                            sdb_ibp_dummy_wresp_enable;

  //reg [(DATA_W/8)-1:0]            sdb_ibp_wr_mask_r;
  //reg                             sdb_ibp_wr_accept_r;
  wire                            sdb_ibp_wr_accept;

  // ibp wr resp fifo control signals
  wire                            ibp_sfifo_push;
  wire [2-1:0]                    ibp_sfifo_in;
  wire                            ibp_sfifo_pop;
  wire [2-1:0]                    ibp_sfifo_out;
  wire                            ibp_sfifo_empty;
  wire                            ibp_sfifo_full;

  // ibp sparse split registers
  reg [(DATA_W/8)-1:0]            sdb_ibp_wr_mask_2bdone;    // ibp mask to be split
  reg [(DATA_W/8)-1:0]            sdb_ibp_wr_mask_done_r;    // ibp mask split done
  reg [(DATA_W/8)-1:0]            sdb_ibp_wr_mask;           // sdb ibp mask corresponding to sdb_ibp_cmd_data_size
  reg [(DATA_W/8)-1:0]            mask_zero;                 // all zero mask
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: it is indeed driving nothing
  reg [(DATA_W/8)-1:0]            mask_tmp;                  // ibp temp mask for iteration
// leda NTL_CON13A on

  wire [(DATA_W/8)-1:0]           sdb_ibp_wr_mask_done_next; // next ibp mask done
// leda NTL_CON33 off
// LMD: none of the inputs have any effect on net Range 0-2
// LJ: it is indeed driving nothing
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: it is indeed driving nothing
  reg [2:0]                       data_size_tmp;             // temp data size for iteration
// leda NTL_CON33 on
// leda NTL_CON13A on
  reg [2:0]                       sdb_ibp_cmd_data_size;     // next ibp write data size
  reg [ALSB-1:0]                  sdb_ibp_cmd_addr_alsb;
  reg                             sdb_ibp_wr_splt_done;      // sparse write split done

  // endian conversion signals
  //reg  [DATA_W-1:0]               i_ibp_wr_data_tmp;
  //reg  [DATA_W-1:0]               o_ibp_rd_data_tmp;

  // Miscellaneous Assignments
  // Notes: To handle the direct write data path only,
  //        dead lock might be introduced when handling side buffer data path
  wire cmd_wait_wd_cnt_udf;
  //wire ibp_cmd_wait_wd = (i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read)) | (~cmd_wait_wd_cnt_udf);
  //wire ibp_cmd_wait_wd = (i_ibp_cmd_accept & (~i_ibp_cmd_read)) | (~cmd_wait_wd_cnt_udf);
  // Notes: to cut in2out timing path
  wire ibp_cmd_wait_wd = i_ibp_cmd_accept | (~cmd_wait_wd_cnt_udf);

  // IBP command channel signals
  // Notes: only accept wr_cmd after wr_valid asserted
  //assign i_ibp_cmd_accept      = i_ibp_cmd_read ? o_ibp_cmd_accept : (ibp_wr_cmd_accept & i_ibp_wr_valid);
  //assign ibp_wr_cmd_accept     = ibp_wr_sel_sdb ? sdb_ibp_wr_accept_r : ibp_cmd_accept_tmp;
  //assign ibp_wr_cmd_accept     = ibp_wr_sel_sdb ? sdb_ibp_wr_accept : ibp_cmd_accept_tmp;
  assign i_ibp_cmd_accept      = (ibp_wr_sel_sdb | ibp_wr_sparse_splt) ? (ibp_wr_sparse_splt & sdb_ibp_fifo_i_ready) : ibp_cmd_accept_tmp;
  assign ibp_cmd_accept_tmp    = o_ibp_cmd_accept & (i_ibp_cmd_read | (i_ibp_wr_valid & (~ibp_sfifo_full)));

  //assign o_ibp_cmd_valid       = i_ibp_cmd_read ? i_ibp_cmd_valid : (ibp_wr_cmd_valid & i_ibp_wr_valid);
  //assign ibp_wr_cmd_valid      = ibp_wr_sel_sdb ? sdb_ibp_cmd_valid : (i_ibp_cmd_valid & (~ibp_sfifo_full));
  assign o_ibp_cmd_valid       = (ibp_wr_sel_sdb | ibp_wr_sparse_splt) ? sdb_ibp_cmd_valid :
                                         (i_ibp_cmd_valid & (i_ibp_cmd_read | (i_ibp_wr_valid & (~ibp_sfifo_full))));

  assign o_ibp_cmd_read        = ibp_wr_sel_sdb ? sdb_ibp_cmd_read : i_ibp_cmd_read;
  assign o_ibp_cmd_addr        = ibp_wr_sel_sdb ? sdb_ibp_cmd_addr : i_ibp_cmd_addr;
  assign o_ibp_cmd_wrap        = ibp_wr_sel_sdb ? sdb_ibp_cmd_wrap : i_ibp_cmd_wrap;
  //assign o_ibp_cmd_data_size   = (i_ibp_cmd_read | ibp_sw_full_mask) ? i_ibp_cmd_data_size : ibp_wr_cmd_data_size;
  assign o_ibp_cmd_data_size   = ibp_wr_sel_sdb ? sdb_ibp_cmd_data_size : ibp_wr_cmd_data_size;
  // Notes: fix probable mis-alignment between ibp_cmd_data_size and ibp_wr_mask,
  //        use ALSB to force ibp_wr_cmd_data_size to data width for all non-sparse write mask
// leda B_3208_A off
// LMD: Unequal length operand in conditional expression, false_alt: 2, true_alt : 3
// LJ: it is not a problem
  //assign ibp_wr_cmd_data_size  = ibp_wr_sel_sdb ? sdb_ibp_cmd_data_size : $unsigned(ALSB);
  generate
    if (WRITE_MASK_PRECEDENCE == 0)
      begin : wr_mask_no_prcd_data_size_PROC
         assign ibp_wr_cmd_data_size  = i_ibp_cmd_data_size;
      end
    else
      begin : wr_mask_tk_prcd_data_size_PROC
         assign ibp_wr_cmd_data_size  = i_ibp_cmd_read ? i_ibp_cmd_data_size : $unsigned(ALSB);
      end
  endgenerate
// leda B_3208_A on
  assign o_ibp_cmd_burst_size  = ibp_wr_sel_sdb ? sdb_ibp_cmd_burst_size : i_ibp_cmd_burst_size;
  assign o_ibp_cmd_lock        = ibp_wr_sel_sdb ? sdb_ibp_cmd_lock       : i_ibp_cmd_lock;
  assign o_ibp_cmd_prot        = ibp_wr_sel_sdb ? sdb_ibp_cmd_prot       : i_ibp_cmd_prot;
  assign o_ibp_cmd_cache       = ibp_wr_sel_sdb ? sdb_ibp_cmd_cache      : i_ibp_cmd_cache;
  assign o_ibp_cmd_excl        = ibp_wr_sel_sdb ? sdb_ibp_cmd_excl       : i_ibp_cmd_excl;
  assign o_ibp_cmd_burst_en    = ibp_wr_sel_sdb ? sdb_ibp_cmd_burst_en   : i_ibp_cmd_burst_en;    // only for burst_read
  assign o_ibp_cmd_burst_type  = ibp_wr_sel_sdb ? sdb_ibp_cmd_burst_type : i_ibp_cmd_burst_type;  // only for burst_read
  assign o_ibp_cmd_burst_last  = ibp_wr_sel_sdb ? sdb_ibp_cmd_burst_last : i_ibp_cmd_burst_last;  // for both read/write

  assign o_ibp_cmd_wr_splt_last= (~ibp_wr_sel_sdb) | sdb_ibp_wr_splt_done; // for read, don't care about wr_splt_last
                                                                           // when read,fixed to 1'b1 for convenience

  // IBP write data channel signals
  //assign i_ibp_wr_accept       = ibp_wr_sel_sdb ? sdb_ibp_wr_accept_r : (ibp_wr_accept_tmp & ibp_cmd_wait_wd);
  //assign i_ibp_wr_accept       = ibp_wr_sel_sdb ? sdb_ibp_wr_accept : (ibp_wr_accept_tmp & ibp_cmd_wait_wd);
  assign i_ibp_wr_accept       = (ibp_wr_sel_sdb | ibp_wr_sparse_splt) ? (ibp_wr_sparse_splt & sdb_ibp_fifo_i_ready) :
                                                                            (ibp_wr_accept_tmp & ibp_cmd_wait_wd);
  assign ibp_wr_accept_tmp     = o_ibp_wr_accept & (~ibp_sfifo_full);

  assign o_ibp_wr_valid        = (ibp_wr_sel_sdb | ibp_wr_sparse_splt) ? sdb_ibp_wr_valid :
                                                           (i_ibp_wr_valid & (~ibp_sfifo_full) & ibp_cmd_wait_wd) ;
  //assign o_ibp_wr_data         = i_ibp_wr_data;
  assign o_ibp_wr_data         = ibp_wr_sel_sdb ? wfifo_o_wr_data : i_ibp_wr_data;
  // Notes: not output o_ibp_wr_mask to ahb_single2ahb
  //assign o_ibp_wr_mask         = ibp_wr_sel_sdb ? sdb_ibp_wr_mask : i_ibp_wr_mask;

  // IBP write response channel signals
  // first mux for split write response
  assign sdb_ibp_wr_done_tmp   = (o_ibp_wr_done | (o_ibp_wr_excl_done & (~sdb_ibp_wr_excl_done_r)))
                                 & (~sdb_ibp_err_wr_r)
                                 & (~sdb_ibp_splt_wresp_sel);
  assign sdb_ibp_err_wr_tmp    = (o_ibp_err_wr | ((o_ibp_wr_done | o_ibp_wr_excl_done) & sdb_ibp_err_wr_r))
                                 & (~sdb_ibp_splt_wresp_sel);
  assign sdb_ibp_wr_excl_done_tmp = (o_ibp_wr_excl_done & sdb_ibp_wr_excl_done_r & (~sdb_ibp_err_wr_r))
                                    & (~sdb_ibp_splt_wresp_sel);
  assign o_ibp_wr_resp_accept  = sdb_ibp_splt_wresp_sel ? 1'b1 : sdb_ibp_wr_resp_accept_tmp;
  // second mux for dummy write response
  assign i_ibp_wr_done         = sdb_ibp_dummy_wresp_sel ? sdb_ibp_dummy_wr_done_r : sdb_ibp_wr_done_tmp;
  assign i_ibp_err_wr          = sdb_ibp_dummy_wresp_sel ? 1'b0 : sdb_ibp_err_wr_tmp;
  assign i_ibp_wr_excl_done    = sdb_ibp_dummy_wresp_sel ? 1'b0 : sdb_ibp_wr_excl_done_tmp;
  assign sdb_ibp_wr_resp_accept_tmp   = (~sdb_ibp_dummy_wresp_sel) & i_ibp_wr_resp_accept;
  assign sdb_ibp_dummy_wr_resp_accept = sdb_ibp_dummy_wresp_sel & i_ibp_wr_resp_accept;

  // IBP read channel signals
  assign o_ibp_rd_accept       = i_ibp_rd_accept;
  assign i_ibp_rd_valid        = o_ibp_rd_valid;
  assign i_ibp_err_rd          = o_ibp_err_rd;
  assign i_ibp_rd_data         = o_ibp_rd_data;
  assign i_ibp_rd_excl_ok      = o_ibp_rd_excl_ok;

  // IBP chnl enables
  //assign i_ibp_cmd_enable      = i_ibp_cmd_valid & i_ibp_cmd_accept;
  //assign i_ibp_wr_enable       = i_ibp_wr_valid & i_ibp_wr_accept;
  //assign o_ibp_cmd_enable      = o_ibp_cmd_valid & ibp_cmd_accept; //o_ibp_cmd_accept;
  assign o_ibp_wr_enable       = o_ibp_wr_valid & o_ibp_wr_accept;
  assign o_ibp_wresp_enable    = (o_ibp_wr_done | o_ibp_err_wr | o_ibp_wr_excl_done) & o_ibp_wr_resp_accept;

  // ibp command side buffer instantiation
  wire afifo_i_ready;
  wire afifo_i_valid;
  wire afifo_o_ready;
  wire afifo_o_valid;

  wire wfifo_i_ready;
  wire wfifo_i_valid;
  wire wfifo_o_ready;
  wire wfifo_o_valid;

  assign sdb_ibp_fifo_i_ready  = afifo_i_ready & wfifo_i_ready;

  assign afifo_i_valid = ibp_wr_sparse_splt & wfifo_i_ready;
  assign afifo_o_ready = sdb_ibp_wr_accept;

  //localparam AFIFO_W = (ADDR_W-ALSB+1+1+3+4+1+2+4+1+1+3+1);
  localparam AFIFO_W = (ADDR_W-ALSB+1+1+4+1+2+4+1+1+3+1); // remove data_size
  wire [AFIFO_W-1:0] afifo_o_data;
  wire [AFIFO_W-1:0] afifo_i_data =
                                    {
                                     i_ibp_cmd_addr[ADDR_W-1:ALSB],
                                     i_ibp_cmd_read,
                                     i_ibp_cmd_wrap,
                                     //i_ibp_cmd_data_size,
                                     i_ibp_cmd_burst_size,
                                     i_ibp_cmd_lock,
                                     i_ibp_cmd_prot,
                                     i_ibp_cmd_cache,
                                     i_ibp_cmd_excl,
                                     i_ibp_cmd_burst_en,
                                     i_ibp_cmd_burst_type,
                                     i_ibp_cmd_burst_last
                                    };

  assign {
          sdb_ibp_cmd_addr[ADDR_W-1:ALSB],
          sdb_ibp_cmd_read,
          sdb_ibp_cmd_wrap,
          //sdb_ibp_cmd_data_size,
          sdb_ibp_cmd_burst_size,
          sdb_ibp_cmd_lock,
          sdb_ibp_cmd_prot,
          sdb_ibp_cmd_cache,
          sdb_ibp_cmd_excl,
          sdb_ibp_cmd_burst_en,
          sdb_ibp_cmd_burst_type,
          sdb_ibp_cmd_burst_last
        }                         = afifo_o_data;

  alb_mss_fab_fifo #(
      .FIFO_DEPTH(1),
      .FIFO_WIDTH(AFIFO_W),
      .IN_OUT_MWHILE (1),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
  ) u_ibp_cmd_side_buf (
                            .i_clk_en    (1'b1),
                            .i_ready     (afifo_i_ready),
                            .i_valid     (afifo_i_valid),
                            .i_data      (afifo_i_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
                            .i_occp      (),
                            .o_occp      (),
// leda B_1011 on
// leda WV951025 on
                            .o_clk_en    (1'b1),
                            .o_ready     (afifo_o_ready),
                            .o_valid     (afifo_o_valid),
                            .o_data      (afifo_o_data ),

                            .clk         (clk  ),
                            .rst_a       (rst_a)
                            );

  // ibp wdata side buffer instantiation
  assign wfifo_i_valid = ibp_wr_sparse_splt & afifo_i_ready;
  assign wfifo_o_ready = sdb_ibp_wr_accept;

  localparam WFIFO_W = (DATA_W/8) + DATA_W;
  wire [WFIFO_W-1:0] wfifo_o_data;
  wire [WFIFO_W-1:0] wfifo_i_data =
                                    {
                                     ibp_wr_mask_fnl,
                                     i_ibp_wr_data
                                    };

  assign {
          wfifo_o_wr_mask,
          wfifo_o_wr_data
         }                        = wfifo_o_data;

  alb_mss_fab_fifo #(
      .FIFO_DEPTH(1),
      .FIFO_WIDTH(WFIFO_W),
      .IN_OUT_MWHILE (1),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
  ) u_ibp_wd_side_buf (
                            .i_clk_en    (1'b1),
                            .i_ready     (wfifo_i_ready),
                            .i_valid     (wfifo_i_valid),
                            .i_data      (wfifo_i_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
                            .i_occp      (),
                            .o_occp      (),
// leda B_1011 on
// leda WV951025 on
                            .o_clk_en    (1'b1),
                            .o_ready     (wfifo_o_ready),
                            .o_valid     (wfifo_o_valid),
                            .o_data      (wfifo_o_data ),

                            .clk         (clk  ),
                            .rst_a       (rst_a)
                            );

  // ibp wd chnl side buffer control
// leda B_3208 off
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment LHS : x, RHS : y  (Replacement rule for B_3208)
// LJ: there is no overflow risk
  // Caculated ibp_sw_wr_mask by i_ibp_cmd_data_size[2:0] and i_ibp_cmd_addr[ALSB-1:0]
  reg [(DATA_W/8)-1:0]            ibp_sw_wr_mask;
  generate
    if (WRITE_MASK_PRECEDENCE == 1) begin: write_mask_precedence_eq_1_decl
      always @ (*)
         begin: write_mask_precedence_eq_1_PROC
                  ibp_sw_wr_mask = {(DATA_W/8){1'b1}};
         end
    end

    if (WRITE_MASK_PRECEDENCE == 0)
      begin : wr_mask_no_prcd_sw_wr_mask_PROC //{
         if (DATA_W == 32)
           begin : ibp_sw_wr_mask_dw32b_PROC
              always @ (*)
                begin: ibp_sw_wr_mask_dw32b_case_PROC
                   case (i_ibp_cmd_data_size)
                      3'b000:  // byte
                         ibp_sw_wr_mask = 1 << i_ibp_cmd_addr[1:0];
                      3'b001:  // halfword
                         ibp_sw_wr_mask = 3 << {i_ibp_cmd_addr[1], 1'b0};
                      //3'b010:  // word
                      //3'b011,  // dword
                      //3'b100,  // qword
                      default:
                         ibp_sw_wr_mask = {(DATA_W/8){1'b1}};
                   endcase
                end
           end
         else if (DATA_W == 64)
           begin : ibp_sw_wr_mask_dw64b_PROC
              always @ (*)
                begin: ibp_sw_wr_mask_dw64b_case_PROC
                   case (i_ibp_cmd_data_size)
                      3'b000:  // byte
                         ibp_sw_wr_mask = 1 << i_ibp_cmd_addr[2:0];
                      3'b001:  // halfword
                         ibp_sw_wr_mask = 3 << {i_ibp_cmd_addr[2:1], 1'b0};
                      3'b010:  // word
                         ibp_sw_wr_mask = 15 << {i_ibp_cmd_addr[2], 2'b0};
                      //3'b011,  // dword
                      //3'b100,  // qword
                      default:
                         ibp_sw_wr_mask = {(DATA_W/8){1'b1}};
                   endcase
                end
           end
         else if (DATA_W == 128)
           begin : ibp_sw_wr_mask_dw128b_PROC
              always @ (*)
                begin: ibp_sw_wr_mask_dw128b_case_PROC
                   case (i_ibp_cmd_data_size)
                      3'b000:  // byte
                         ibp_sw_wr_mask = 1 << i_ibp_cmd_addr[3:0];
                      3'b001:  // halfword
                         ibp_sw_wr_mask = 3 << {i_ibp_cmd_addr[3:1], 1'b0};
                      3'b010:  // word
                         ibp_sw_wr_mask = 15 << {i_ibp_cmd_addr[3:2], 2'b0};
                      3'b011:  // dword
                         ibp_sw_wr_mask = 255 << {i_ibp_cmd_addr[3], 3'b0};
                      //3'b100,  // qword
                      default:
                         ibp_sw_wr_mask = {(DATA_W/8){1'b1}};
                   endcase
                end
           end
      end //}
  endgenerate
// leda B_3208 on
// leda BTTF_D002 on

  // Notes: take 32-bit transfer with partial full mask on 64bit bus as non-sparse transfer
  //assign ibp_sw_full_mask      = (i_ibp_cmd_data_size == 3'h2) ?
  //                               (i_ibp_cmd_addr[2] ? (&i_ibp_wr_mask[7:4]) : (&i_ibp_wr_mask[3:0])) : 1'b0;
  //assign ibp_sw_full_mask      = 1'b0;  // temporarily fixed
  generate
    if (WRITE_MASK_PRECEDENCE == 0)
      begin : wr_mask_no_prcd_sw_full_mask_PROC
         assign ibp_sw_full_mask      = (&(i_ibp_wr_mask | (~ibp_sw_wr_mask)));
         assign ibp_wr_mask_fnl       = i_ibp_wr_mask & ibp_sw_wr_mask;
      end
    else
      begin : wr_mask_tk_prcd_sw_full_mask_PROC
         assign ibp_sw_full_mask      = 1'b0;
         assign ibp_wr_mask_fnl       = i_ibp_wr_mask;
      end
  endgenerate

  //assign ibp_wr_sparse_splt    = i_ibp_wr_valid & (~(i_ibp_wr_mask == {(DATA_W/8){1'b1}}));
  assign ibp_wr_sparse_splt    = i_ibp_wr_valid & (~(&i_ibp_wr_mask)) & (~ibp_sw_full_mask);
  //assign ibp_wr_sel_sdb        = ibp_wr_sparse_splt;
  assign ibp_wr_sel_sdb        = wfifo_o_valid;  // afifo_o_valid == wfifo_o_valid
  //assign ibp_wr_sel_sdb_start  = ibp_wr_sparse_splt & (~ibp_wr_sel_sdb_r);

  assign sdb_ibp_splt_valid    = (|sdb_ibp_wr_mask_2bdone) & (~ibp_sfifo_full);
  //assign sdb_ibp_cmd_valid     = sdb_ibp_splt_valid & o_ibp_wr_accept;   // push cmd/wd at the same cycle
  assign sdb_ibp_cmd_valid     = afifo_o_valid & sdb_ibp_splt_valid & o_ibp_wr_accept;
  //assign sdb_ibp_wr_valid      = sdb_ibp_splt_valid & o_ibp_cmd_accept;
  assign sdb_ibp_wr_valid      = wfifo_o_valid & sdb_ibp_splt_valid & o_ibp_cmd_accept;
  //assign sdb_ibp_dummy_valid   = ibp_wr_sel_sdb_r & (~(|sdb_ibp_wr_mask_r)) & (~ibp_sfifo_full); // dummy valid for zero wr mask
  assign sdb_ibp_dummy_valid   = ibp_wr_sel_sdb & (~(|wfifo_o_wr_mask)) & (~ibp_sfifo_full); // dummy valid for zero wr mask

  //assign sdb_ibp_cmd_addr      = {sdb_ibp_cmd_addr_r[ADDR_W-1:ALSB], sdb_ibp_cmd_addr_alsb[ALSB-1:0]};
  assign sdb_ibp_cmd_addr[ALSB-1:0] = sdb_ibp_cmd_addr_alsb[ALSB-1:0];

  assign sdb_ibp_cmd_enable    = sdb_ibp_cmd_valid & o_ibp_cmd_accept;
  assign sdb_ibp_wr_enable     = sdb_ibp_wr_valid & o_ibp_wr_accept;

  //assign sdb_ibp_dummy_wr_enable    = sdb_ibp_dummy_valid & sdb_ibp_wr_accept_r;
  assign sdb_ibp_dummy_wr_enable    = sdb_ibp_dummy_valid;
  assign sdb_ibp_dummy_wresp_enable = sdb_ibp_dummy_wr_done_r & sdb_ibp_dummy_wr_resp_accept;

  // ibp_wr_sel_sdb_r
  //always @(posedge clk or posedge rst_a)
  //  begin : ibp_wr_sel_sdb_DFFEAR_PROC
  //     if (rst_a == 1'b1)
  //        ibp_wr_sel_sdb_r <= 1'b0;
  //     //else if (sdb_ibp_wr_accept_r)
  //     else if (sdb_ibp_wr_accept)
  //        ibp_wr_sel_sdb_r <= 1'b0;
  //     else if (ibp_wr_sparse_splt)
  //        ibp_wr_sel_sdb_r <= 1'b1;
  //  end

  // sdb_ibp_wr_accept: comb output instead of sdb_ibp_wr_accept_r to reduce one cycle latency
  assign sdb_ibp_wr_accept = (sdb_ibp_wr_enable & sdb_ibp_wr_splt_done) | sdb_ibp_dummy_valid;

  // sdb_ibp_wr_accept_r
  //always @(posedge clk or posedge rst_a)
  //  begin : sdb_ibp_wr_accept_DFFEAR_PROC
  //     if (rst_a == 1'b1)
  //        sdb_ibp_wr_accept_r <= 1'b0;
  //     else if (sdb_ibp_wr_accept_r)
  //        sdb_ibp_wr_accept_r <= 1'b0;
  //     else if ((sdb_ibp_wr_enable & sdb_ibp_wr_splt_done) | sdb_ibp_dummy_valid)
  //        sdb_ibp_wr_accept_r <= 1'b1;
  //  end

  // sdb_ibp_wr_mask_r
  //always @(posedge clk or posedge rst_a)
  //  begin : sdb_ibp_wr_mask_DFFEAR_PROC
  //     if (rst_a == 1'b1)
  //        sdb_ibp_wr_mask_r <= {(DATA_W/8){1'b0}};
  //     else if (ibp_wr_sel_sdb_start)
  //        sdb_ibp_wr_mask_r <= i_ibp_wr_mask;
  //  end

  // sdb_ibp_dummy_wr_done_r
  always @(posedge clk or posedge rst_a)
    begin : sdb_ibp_dummy_wr_done_DFFEAR_PROC
       if (rst_a == 1'b1)
          sdb_ibp_dummy_wr_done_r <= 1'b0;
       else if (sdb_ibp_dummy_wresp_enable)
          sdb_ibp_dummy_wr_done_r <= 1'b0;
       else if (sdb_ibp_dummy_wresp_sel)
          sdb_ibp_dummy_wr_done_r <= 1'b1;
    end

  // ibp write response fifo
  assign ibp_sfifo_push      = o_ibp_wr_enable | sdb_ibp_dummy_wr_enable;

  //assign ibp_sfifo_in        = {(sdb_ibp_splt_valid & (~sdb_ibp_wr_splt_done)),
  assign ibp_sfifo_in        = {(ibp_wr_sel_sdb & (~sdb_ibp_wr_splt_done)),
                                sdb_ibp_dummy_valid
                               };

  assign ibp_sfifo_pop       = o_ibp_wresp_enable | sdb_ibp_dummy_wresp_enable ;

  // sdb_ibp_splt_wresp_sel: 0: valid response to be forwarded directly
  //                         1: split response to be accumulated
  assign {sdb_ibp_splt_wresp_sel_tmp,
          sdb_ibp_dummy_wresp_sel_tmp
                                 } = ibp_sfifo_out;

  // select signals only available when sfifo not empty
  assign sdb_ibp_splt_wresp_sel  = sdb_ibp_splt_wresp_sel_tmp & (~ibp_sfifo_empty);
  assign sdb_ibp_dummy_wresp_sel = sdb_ibp_dummy_wresp_sel_tmp & (~ibp_sfifo_empty);

  // Notes: This FIFO doesn't store write response signals,
  //        it stores the info where write response be routed.
wire ibp_wresp_fifo_i_valid;
wire ibp_wresp_fifo_o_valid;
wire ibp_wresp_fifo_i_ready;
wire ibp_wresp_fifo_o_ready;
assign ibp_wresp_fifo_i_valid = ibp_sfifo_push;
assign ibp_sfifo_full = (~ibp_wresp_fifo_i_ready);
assign ibp_wresp_fifo_o_ready = ibp_sfifo_pop;
assign ibp_sfifo_empty = (~ibp_wresp_fifo_o_valid);

alb_mss_fab_fifo # (
  .FIFO_WIDTH(2),
  .FIFO_DEPTH(WR_OUT_CMD_DEP),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) u_ibp_wresp_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (ibp_wresp_fifo_i_valid),
  .i_ready   (ibp_wresp_fifo_i_ready),
  .o_valid   (ibp_wresp_fifo_o_valid),
  .o_ready   (ibp_wresp_fifo_o_ready),
  .i_data    (ibp_sfifo_in ),
  .o_data    (ibp_sfifo_out ),
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

  // sdb_ibp_err_wr_r: accumulate split error wr response
  always @(posedge clk or posedge rst_a)
    begin : sdb_ibp_err_wr_DFFEAR_PROC
       if (rst_a == 1'b1)
          sdb_ibp_err_wr_r  <= 1'b0;
       else if (o_ibp_wresp_enable & (~sdb_ibp_splt_wresp_sel))
          sdb_ibp_err_wr_r  <= 1'b0;
       else if (o_ibp_wresp_enable & sdb_ibp_splt_wresp_sel)
          sdb_ibp_err_wr_r  <= sdb_ibp_err_wr_r | o_ibp_err_wr;
    end

  // sdb_ibp_wr_excl_done_r: accumulate split wr excl response
  always @(posedge clk or posedge rst_a)
    begin : sdb_ibp_wr_excl_done_DFFEAR_PROC
       if (rst_a == 1'b1)
          sdb_ibp_wr_excl_done_r  <= 1'b1;
       else if (o_ibp_wresp_enable & (~sdb_ibp_splt_wresp_sel))
          sdb_ibp_wr_excl_done_r  <= 1'b1;
       else if (o_ibp_wresp_enable & sdb_ibp_splt_wresp_sel)
          sdb_ibp_wr_excl_done_r  <= sdb_ibp_wr_excl_done_r & o_ibp_wr_excl_done;
    end

  // ibp sparse write splitting logic
  // sdb_ibp_wr_mask_done_r
  always @(posedge clk or posedge rst_a)
    begin : sdb_ibp_wr_mask_done_DFFEAR_PROC
       if (rst_a == 1'b1)
          sdb_ibp_wr_mask_done_r <= {(DATA_W/8){1'b0}};
       //else if (sdb_ibp_wr_enable & sdb_ibp_wr_splt_done)
       //else if (sdb_ibp_wr_accept_r)
       //else if (ibp_wr_sel_sdb_start) // reset wr_mask_done_r
       else if (afifo_i_valid & afifo_i_ready) // reset wr_mask_done_r
          sdb_ibp_wr_mask_done_r <= {(DATA_W/8){1'b0}};
       else if (sdb_ibp_wr_enable)
          sdb_ibp_wr_mask_done_r <= sdb_ibp_wr_mask_done_next;
    end

  assign sdb_ibp_wr_mask_done_next  = (sdb_ibp_wr_mask_done_r | sdb_ibp_wr_mask);

  // Notes: handle ibp write specially to support sparse write mask,
  //        ibp write with sparse write mask is splitted into several writes with narrow hsize
  // sdb_ibp_cmd_data_size for ibp write
// leda NTL_CON13A off
// leda NTL_CON12A off
// LMD: non driving internal net
// LJ: j,k are driving, no issue
  integer i;
  integer j;
  integer k;
// leda NTL_CON13A on
// leda NTL_CON12A on
  always @ (*)
    begin : sdb_ibp_cmd_data_size_PROC

       mask_zero                  = {(DATA_W/8){1'b0}};
       mask_tmp                   = mask_zero;
       data_size_tmp              = 3'b000;

       sdb_ibp_wr_mask            = {(DATA_W/8){1'b0}};
       sdb_ibp_cmd_data_size      = 3'b000;
       sdb_ibp_cmd_addr_alsb      = {ALSB{1'b0}};

       sdb_ibp_wr_mask_2bdone     = wfifo_o_wr_mask & (~sdb_ibp_wr_mask_done_r);   // should use LE wr_mask to caculate the address offset
       //sdb_ibp_wr_mask_done_next  = (sdb_ibp_wr_mask_done_r | sdb_ibp_wr_mask);
       sdb_ibp_wr_splt_done       = (wfifo_o_wr_mask == sdb_ibp_wr_mask_done_next);

       // start with one bit mask, and double number of bits, ...
       for (i = 1; i <= (DATA_W/8); i = i << 1) begin

          // iterate over data width
          for (j = 0; j < (DATA_W/8); j = j + i) begin

              // initialize mask_tmp with zero
              mask_tmp = mask_zero;

// leda FM_2_22 off
// LMD: Possible range overflow
// LJ:  Max value of j+k is DATA_W/8
              for (k = 0; k < i; k = k + 1)  // i=1,2,4,8,16
                 mask_tmp[j+k] = 1'b1;
// leda FM_2_22 on

              // get ahb_hsize/ahb_haddr when mask_tmp matches mask_2bdone partially (non-zero MSBs)
              if ((sdb_ibp_wr_mask_2bdone & mask_tmp) == mask_tmp) begin
                  sdb_ibp_wr_mask       = mask_tmp;
                  sdb_ibp_cmd_data_size = data_size_tmp;
// leda B_3208 off
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment LHS : x, RHS : y  (Replacement rule for B_3208)
// LJ:  alsb = clog2(d_w/8) so no problem
                  sdb_ibp_cmd_addr_alsb[ALSB-1:0] = $unsigned(j);
              end

          end // for (j=0; ...)

          // ahb_hsize: 8b -> 16b -> 32b -> 64b -> 128b
// leda NTL_CON33 off
// LMD: none of the inputs have any effect on net Range 0-2
// LJ: it is indeed driving nothing
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/substration
// LJ: there is no overflow risk
          data_size_tmp = data_size_tmp + 1;
// leda NTL_CON33 on
// leda W484 on
// leda B_3208 on
// leda BTTF_D002 on

       end // for (i=1; ...)
    end

  //--------------------------------------------------------
  // Count how much of the cmd is waiting write burst data
  //--------------------------------------------------------
  // Notes: Move from ahb_single2ahb to handle the direct write data path only,
  //        because dead lock might be introduced when handling side buffer data path
  reg [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_r;
  wire cmd_wait_wd_cnt_ovf = (cmd_wait_wd_cnt_r[OUT_CMD_CNT_W] == 1'b1);
  assign cmd_wait_wd_cnt_udf = (cmd_wait_wd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
  // The ibp wr burst counter increased when a IBP write command accepted to the axi_aw stage
  wire cmd_wait_wd_cnt_inc = i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read);
  // The ibp wr burst counter decreased when a last beat of IBP write burst accepted to axi_wd stage
  wire cmd_wait_wd_cnt_dec = (i_ibp_wr_valid & i_ibp_wr_accept);
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
  // leda B_3219 on
  // leda B_3200 on
  // leda BTTF_D002 on
  // leda W484 on

  always @(posedge clk or posedge rst_a)
  begin : cmd_wait_wd_cnt_DFFEAR_PROC
    if (rst_a == 1'b1) begin
        cmd_wait_wd_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
    end
    else if (cmd_wait_wd_cnt_ena == 1'b1) begin
        cmd_wait_wd_cnt_r        <= cmd_wait_wd_cnt_nxt;
    end
  end

  // Notes: Do endian conversion in ahb_single2ahb,
  //        not involve bigendian input to make the code clean
  // endian convert
  // outputs: i_ibp_wr_data, i_ibp_wr_mask,
  //integer i;
  //always @ (*)
  //  begin: endian_convert_PROC
  //      if (bigendian)
  //        for (i = 0; i < DATA_W/8; i = i + 1) begin
  //           i_ibp_wr_data_tmp[i*8+:8] = i_ibp_wr_data[DATA_W-8-i*8+:8];
  //           //i_ibp_wr_mask_tmp[i]      = i_ibp_wr_mask[DATA_W/8-i-1];
  //           o_ibp_rd_data_tmp[i*8+:8]  = o_ibp_rd_data[DATA_W-8-i*8+:8];
  //        end
  //      else begin
  //         i_ibp_wr_data_tmp   = i_ibp_wr_data;
  //         //i_ibp_wr_mask_tmp  = i_ibp_wr_mask;
  //         o_ibp_rd_data_tmp  = o_ibp_rd_data;
  //      end
  //  end // endian_convert_PROC

  //--------------------------------------------------
  // SV Assertion Checkers
  //--------------------------------------------------

endmodule // alb_mss_fab_single2sparse
