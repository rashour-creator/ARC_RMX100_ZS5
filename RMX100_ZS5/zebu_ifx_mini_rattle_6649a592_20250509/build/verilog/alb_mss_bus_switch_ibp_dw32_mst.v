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
//
// ===========================================================================
//
// Description:
//  Verilog module of mss_bus_switch_ibp_dw32 master port
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "alb_mss_bus_switch_defines.v"

// Set simulation timescale
//
`include "const.def"


module mss_bus_switch_ibp_dw32_mst
// leda G_521_2_B off
// LMD: Use lowercase letters for all signal reg, net and port names
// LJ: Pfx may include the uppercase, so disable the lint checking rule
  (



 input  [1-1:0] ibp_dw32_in_0_ibp_cmd_chnl_valid,
 output [1-1:0] ibp_dw32_in_0_ibp_cmd_chnl_accept,
 input  [59 * 1 -1:0] ibp_dw32_in_0_ibp_cmd_chnl,

 input  [1-1:0] ibp_dw32_in_0_ibp_wd_chnl_valid,
 output [1-1:0] ibp_dw32_in_0_ibp_wd_chnl_accept,
 input  [37 * 1 -1:0] ibp_dw32_in_0_ibp_wd_chnl,

 input  [1-1:0] ibp_dw32_in_0_ibp_rd_chnl_accept,
 output [1-1:0] ibp_dw32_in_0_ibp_rd_chnl_valid,
 output [35 * 1 -1:0] ibp_dw32_in_0_ibp_rd_chnl,

 output [1-1:0] ibp_dw32_in_0_ibp_wrsp_chnl_valid,
 input  [1-1:0] ibp_dw32_in_0_ibp_wrsp_chnl_accept,
 output [3 * 1 -1:0] ibp_dw32_in_0_ibp_wrsp_chnl,





 input  [1-1:0] ibp_dw32_in_1_ibp_cmd_chnl_valid,
 output [1-1:0] ibp_dw32_in_1_ibp_cmd_chnl_accept,
 input  [59 * 1 -1:0] ibp_dw32_in_1_ibp_cmd_chnl,

 input  [1-1:0] ibp_dw32_in_1_ibp_wd_chnl_valid,
 output [1-1:0] ibp_dw32_in_1_ibp_wd_chnl_accept,
 input  [37 * 1 -1:0] ibp_dw32_in_1_ibp_wd_chnl,

 input  [1-1:0] ibp_dw32_in_1_ibp_rd_chnl_accept,
 output [1-1:0] ibp_dw32_in_1_ibp_rd_chnl_valid,
 output [35 * 1 -1:0] ibp_dw32_in_1_ibp_rd_chnl,

 output [1-1:0] ibp_dw32_in_1_ibp_wrsp_chnl_valid,
 input  [1-1:0] ibp_dw32_in_1_ibp_wrsp_chnl_accept,
 output [3 * 1 -1:0] ibp_dw32_in_1_ibp_wrsp_chnl,





 input  [1-1:0] ibp_dw32_in_2_ibp_cmd_chnl_valid,
 output [1-1:0] ibp_dw32_in_2_ibp_cmd_chnl_accept,
 input  [59 * 1 -1:0] ibp_dw32_in_2_ibp_cmd_chnl,

 input  [1-1:0] ibp_dw32_in_2_ibp_wd_chnl_valid,
 output [1-1:0] ibp_dw32_in_2_ibp_wd_chnl_accept,
 input  [37 * 1 -1:0] ibp_dw32_in_2_ibp_wd_chnl,

 input  [1-1:0] ibp_dw32_in_2_ibp_rd_chnl_accept,
 output [1-1:0] ibp_dw32_in_2_ibp_rd_chnl_valid,
 output [35 * 1 -1:0] ibp_dw32_in_2_ibp_rd_chnl,

 output [1-1:0] ibp_dw32_in_2_ibp_wrsp_chnl_valid,
 input  [1-1:0] ibp_dw32_in_2_ibp_wrsp_chnl_accept,
 output [3 * 1 -1:0] ibp_dw32_in_2_ibp_wrsp_chnl,





 input  [1-1:0] ibp_dw32_in_3_ibp_cmd_chnl_valid,
 output [1-1:0] ibp_dw32_in_3_ibp_cmd_chnl_accept,
 input  [59 * 1 -1:0] ibp_dw32_in_3_ibp_cmd_chnl,

 input  [1-1:0] ibp_dw32_in_3_ibp_wd_chnl_valid,
 output [1-1:0] ibp_dw32_in_3_ibp_wd_chnl_accept,
 input  [577 * 1 -1:0] ibp_dw32_in_3_ibp_wd_chnl,

 input  [1-1:0] ibp_dw32_in_3_ibp_rd_chnl_accept,
 output [1-1:0] ibp_dw32_in_3_ibp_rd_chnl_valid,
 output [515 * 1 -1:0] ibp_dw32_in_3_ibp_rd_chnl,

 output [1-1:0] ibp_dw32_in_3_ibp_wrsp_chnl_valid,
 input  [1-1:0] ibp_dw32_in_3_ibp_wrsp_chnl_accept,
 output [3 * 1 -1:0] ibp_dw32_in_3_ibp_wrsp_chnl,



  output                                  ibp_dw32_out_ibp_cmd_valid,
  input                                   ibp_dw32_out_ibp_cmd_accept,
  output                                  ibp_dw32_out_ibp_cmd_read,
  output  [42                -1:0]       ibp_dw32_out_ibp_cmd_addr,
  output                                  ibp_dw32_out_ibp_cmd_wrap,
  output  [3-1:0]       ibp_dw32_out_ibp_cmd_data_size,
  output  [4-1:0]       ibp_dw32_out_ibp_cmd_burst_size,
  output  [2-1:0]       ibp_dw32_out_ibp_cmd_prot,
  output  [4-1:0]       ibp_dw32_out_ibp_cmd_cache,
  output                                  ibp_dw32_out_ibp_cmd_lock,
  output                                  ibp_dw32_out_ibp_cmd_excl,

  input                                   ibp_dw32_out_ibp_rd_valid,
  input                                   ibp_dw32_out_ibp_rd_excl_ok,
  output                                  ibp_dw32_out_ibp_rd_accept,
  input                                   ibp_dw32_out_ibp_err_rd,
  input   [32               -1:0]        ibp_dw32_out_ibp_rd_data,
  input                                   ibp_dw32_out_ibp_rd_last,

  output                                  ibp_dw32_out_ibp_wr_valid,
  input                                   ibp_dw32_out_ibp_wr_accept,
  output  [32               -1:0]        ibp_dw32_out_ibp_wr_data,
  output  [(32         /8)  -1:0]        ibp_dw32_out_ibp_wr_mask,
  output                                  ibp_dw32_out_ibp_wr_last,

  input                                   ibp_dw32_out_ibp_wr_done,
  input                                   ibp_dw32_out_ibp_wr_excl_done,
  input                                   ibp_dw32_out_ibp_err_wr,
  output                                  ibp_dw32_out_ibp_wr_resp_accept,
  input                                  clk,
  input                                  rst_a
);






// Pack all the IBP buses



    wire [1-1:0] ibp_dw32_in_0_ibp_cmd_chnl_user = {1{1'b0}};

// Covert the ibp_dw32_in_0_ IBP width



 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_cmd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] cvted_ibp_dw32_in_0_ibp_cmd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_wd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] cvted_ibp_dw32_in_0_ibp_wd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_rd_chnl_accept;
 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] cvted_ibp_dw32_in_0_ibp_rd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] cvted_ibp_dw32_in_0_ibp_wrsp_chnl;

wire [1-1:0] cvted_ibp_dw32_in_0_ibp_cmd_chnl_user;


mss_bus_switch_ibpx2ibpy
  #(
     .N2W_SUPPORT_NARROW_TRANS (0),
    .W2N_SUPPORT_BURST_TRANS  (1),

    .BYPBUF_WD_CHNL (0),
    .SPLT_FIFO_DEPTH (64),
    .X_W  (32),
    .Y_W  (32),



    .X_CMD_CHNL_READ           (0),
    .X_CMD_CHNL_WRAP           (1),
    .X_CMD_CHNL_DATA_SIZE_LSB  (2),
    .X_CMD_CHNL_DATA_SIZE_W    (3),
    .X_CMD_CHNL_BURST_SIZE_LSB (5),
    .X_CMD_CHNL_BURST_SIZE_W   (4),
    .X_CMD_CHNL_PROT_LSB       (9),
    .X_CMD_CHNL_PROT_W         (2),
    .X_CMD_CHNL_CACHE_LSB      (11),
    .X_CMD_CHNL_CACHE_W        (4),
    .X_CMD_CHNL_LOCK           (15),
    .X_CMD_CHNL_EXCL           (16),
    .X_CMD_CHNL_ADDR_LSB       (17),
    .X_CMD_CHNL_ADDR_W         (42),
    .X_CMD_CHNL_W              (59),

    .X_WD_CHNL_LAST            (0),
    .X_WD_CHNL_DATA_LSB        (1),
    .X_WD_CHNL_DATA_W          (32),
    .X_WD_CHNL_MASK_LSB        (33),
    .X_WD_CHNL_MASK_W          (4),
    .X_WD_CHNL_W               (37),

    .X_RD_CHNL_ERR_RD          (0),
    .X_RD_CHNL_RD_EXCL_OK      (2),
    .X_RD_CHNL_RD_LAST         (1),
    .X_RD_CHNL_RD_DATA_LSB     (3),
    .X_RD_CHNL_RD_DATA_W       (32),
    .X_RD_CHNL_W               (35),

    .X_WRSP_CHNL_WR_DONE       (0),
    .X_WRSP_CHNL_WR_EXCL_DONE  (1),
    .X_WRSP_CHNL_ERR_WR        (2),
    .X_WRSP_CHNL_W             (3),



    .Y_CMD_CHNL_READ           (0),
    .Y_CMD_CHNL_WRAP           (1),
    .Y_CMD_CHNL_DATA_SIZE_LSB  (2),
    .Y_CMD_CHNL_DATA_SIZE_W    (3),
    .Y_CMD_CHNL_BURST_SIZE_LSB (5),
    .Y_CMD_CHNL_BURST_SIZE_W   (4),
    .Y_CMD_CHNL_PROT_LSB       (9),
    .Y_CMD_CHNL_PROT_W         (2),
    .Y_CMD_CHNL_CACHE_LSB      (11),
    .Y_CMD_CHNL_CACHE_W        (4),
    .Y_CMD_CHNL_LOCK           (15),
    .Y_CMD_CHNL_EXCL           (16),
    .Y_CMD_CHNL_ADDR_LSB       (17),
    .Y_CMD_CHNL_ADDR_W         (42),
    .Y_CMD_CHNL_W              (59),

    .Y_WD_CHNL_LAST            (0),
    .Y_WD_CHNL_DATA_LSB        (1),
    .Y_WD_CHNL_DATA_W          (32),
    .Y_WD_CHNL_MASK_LSB        (33),
    .Y_WD_CHNL_MASK_W          (4),
    .Y_WD_CHNL_W               (37),

    .Y_RD_CHNL_ERR_RD          (0),
    .Y_RD_CHNL_RD_EXCL_OK      (2),
    .Y_RD_CHNL_RD_LAST         (1),
    .Y_RD_CHNL_RD_DATA_LSB     (3),
    .Y_RD_CHNL_RD_DATA_W       (32),
    .Y_RD_CHNL_W               (35),

    .Y_WRSP_CHNL_WR_DONE       (0),
    .Y_WRSP_CHNL_WR_EXCL_DONE  (1),
    .Y_WRSP_CHNL_ERR_WR        (2),
    .Y_WRSP_CHNL_W             (3),
    .X_USER_W  (1),
    .Y_USER_W  (1),
    .X_RGON_W  (1),
    .Y_RGON_W  (1)
    )
 u_ibp_dw32_in_0_ibp32toibp32 (
    .i_ibp_cmd_chnl_rgon   (1'b1),



    .i_ibp_cmd_chnl_valid  (ibp_dw32_in_0_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (ibp_dw32_in_0_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (ibp_dw32_in_0_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (ibp_dw32_in_0_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (ibp_dw32_in_0_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (ibp_dw32_in_0_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (ibp_dw32_in_0_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (ibp_dw32_in_0_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (ibp_dw32_in_0_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (ibp_dw32_in_0_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(ibp_dw32_in_0_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (ibp_dw32_in_0_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (ibp_dw32_in_0_ibp_cmd_chnl_user),





    .o_ibp_cmd_chnl_valid  (cvted_ibp_dw32_in_0_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (cvted_ibp_dw32_in_0_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (cvted_ibp_dw32_in_0_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (cvted_ibp_dw32_in_0_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (cvted_ibp_dw32_in_0_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (cvted_ibp_dw32_in_0_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (cvted_ibp_dw32_in_0_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (cvted_ibp_dw32_in_0_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (cvted_ibp_dw32_in_0_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (cvted_ibp_dw32_in_0_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(cvted_ibp_dw32_in_0_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (cvted_ibp_dw32_in_0_ibp_wrsp_chnl),


// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
    .o_ibp_cmd_chnl_user   (cvted_ibp_dw32_in_0_ibp_cmd_chnl_user),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);





    wire [1-1:0] ibp_dw32_in_1_ibp_cmd_chnl_user = {1{1'b0}};

// Covert the ibp_dw32_in_1_ IBP width



 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_cmd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] cvted_ibp_dw32_in_1_ibp_cmd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_wd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] cvted_ibp_dw32_in_1_ibp_wd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_rd_chnl_accept;
 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] cvted_ibp_dw32_in_1_ibp_rd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_wrsp_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] cvted_ibp_dw32_in_1_ibp_wrsp_chnl;

wire [1-1:0] cvted_ibp_dw32_in_1_ibp_cmd_chnl_user;


mss_bus_switch_ibpx2ibpy
  #(
     .N2W_SUPPORT_NARROW_TRANS (0),
    .W2N_SUPPORT_BURST_TRANS  (1),

    .BYPBUF_WD_CHNL (0),
    .SPLT_FIFO_DEPTH (64),
    .X_W  (32),
    .Y_W  (32),



    .X_CMD_CHNL_READ           (0),
    .X_CMD_CHNL_WRAP           (1),
    .X_CMD_CHNL_DATA_SIZE_LSB  (2),
    .X_CMD_CHNL_DATA_SIZE_W    (3),
    .X_CMD_CHNL_BURST_SIZE_LSB (5),
    .X_CMD_CHNL_BURST_SIZE_W   (4),
    .X_CMD_CHNL_PROT_LSB       (9),
    .X_CMD_CHNL_PROT_W         (2),
    .X_CMD_CHNL_CACHE_LSB      (11),
    .X_CMD_CHNL_CACHE_W        (4),
    .X_CMD_CHNL_LOCK           (15),
    .X_CMD_CHNL_EXCL           (16),
    .X_CMD_CHNL_ADDR_LSB       (17),
    .X_CMD_CHNL_ADDR_W         (42),
    .X_CMD_CHNL_W              (59),

    .X_WD_CHNL_LAST            (0),
    .X_WD_CHNL_DATA_LSB        (1),
    .X_WD_CHNL_DATA_W          (32),
    .X_WD_CHNL_MASK_LSB        (33),
    .X_WD_CHNL_MASK_W          (4),
    .X_WD_CHNL_W               (37),

    .X_RD_CHNL_ERR_RD          (0),
    .X_RD_CHNL_RD_EXCL_OK      (2),
    .X_RD_CHNL_RD_LAST         (1),
    .X_RD_CHNL_RD_DATA_LSB     (3),
    .X_RD_CHNL_RD_DATA_W       (32),
    .X_RD_CHNL_W               (35),

    .X_WRSP_CHNL_WR_DONE       (0),
    .X_WRSP_CHNL_WR_EXCL_DONE  (1),
    .X_WRSP_CHNL_ERR_WR        (2),
    .X_WRSP_CHNL_W             (3),



    .Y_CMD_CHNL_READ           (0),
    .Y_CMD_CHNL_WRAP           (1),
    .Y_CMD_CHNL_DATA_SIZE_LSB  (2),
    .Y_CMD_CHNL_DATA_SIZE_W    (3),
    .Y_CMD_CHNL_BURST_SIZE_LSB (5),
    .Y_CMD_CHNL_BURST_SIZE_W   (4),
    .Y_CMD_CHNL_PROT_LSB       (9),
    .Y_CMD_CHNL_PROT_W         (2),
    .Y_CMD_CHNL_CACHE_LSB      (11),
    .Y_CMD_CHNL_CACHE_W        (4),
    .Y_CMD_CHNL_LOCK           (15),
    .Y_CMD_CHNL_EXCL           (16),
    .Y_CMD_CHNL_ADDR_LSB       (17),
    .Y_CMD_CHNL_ADDR_W         (42),
    .Y_CMD_CHNL_W              (59),

    .Y_WD_CHNL_LAST            (0),
    .Y_WD_CHNL_DATA_LSB        (1),
    .Y_WD_CHNL_DATA_W          (32),
    .Y_WD_CHNL_MASK_LSB        (33),
    .Y_WD_CHNL_MASK_W          (4),
    .Y_WD_CHNL_W               (37),

    .Y_RD_CHNL_ERR_RD          (0),
    .Y_RD_CHNL_RD_EXCL_OK      (2),
    .Y_RD_CHNL_RD_LAST         (1),
    .Y_RD_CHNL_RD_DATA_LSB     (3),
    .Y_RD_CHNL_RD_DATA_W       (32),
    .Y_RD_CHNL_W               (35),

    .Y_WRSP_CHNL_WR_DONE       (0),
    .Y_WRSP_CHNL_WR_EXCL_DONE  (1),
    .Y_WRSP_CHNL_ERR_WR        (2),
    .Y_WRSP_CHNL_W             (3),
    .X_USER_W  (1),
    .Y_USER_W  (1),
    .X_RGON_W  (1),
    .Y_RGON_W  (1)
    )
 u_ibp_dw32_in_1_ibp32toibp32 (
    .i_ibp_cmd_chnl_rgon   (1'b1),



    .i_ibp_cmd_chnl_valid  (ibp_dw32_in_1_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (ibp_dw32_in_1_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (ibp_dw32_in_1_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (ibp_dw32_in_1_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (ibp_dw32_in_1_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (ibp_dw32_in_1_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (ibp_dw32_in_1_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (ibp_dw32_in_1_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (ibp_dw32_in_1_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (ibp_dw32_in_1_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(ibp_dw32_in_1_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (ibp_dw32_in_1_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (ibp_dw32_in_1_ibp_cmd_chnl_user),





    .o_ibp_cmd_chnl_valid  (cvted_ibp_dw32_in_1_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (cvted_ibp_dw32_in_1_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (cvted_ibp_dw32_in_1_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (cvted_ibp_dw32_in_1_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (cvted_ibp_dw32_in_1_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (cvted_ibp_dw32_in_1_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (cvted_ibp_dw32_in_1_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (cvted_ibp_dw32_in_1_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (cvted_ibp_dw32_in_1_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (cvted_ibp_dw32_in_1_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(cvted_ibp_dw32_in_1_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (cvted_ibp_dw32_in_1_ibp_wrsp_chnl),


// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
    .o_ibp_cmd_chnl_user   (cvted_ibp_dw32_in_1_ibp_cmd_chnl_user),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);





    wire [1-1:0] ibp_dw32_in_2_ibp_cmd_chnl_user = {1{1'b0}};

// Covert the ibp_dw32_in_2_ IBP width



 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_cmd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] cvted_ibp_dw32_in_2_ibp_cmd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_wd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] cvted_ibp_dw32_in_2_ibp_wd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_rd_chnl_accept;
 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] cvted_ibp_dw32_in_2_ibp_rd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_wrsp_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] cvted_ibp_dw32_in_2_ibp_wrsp_chnl;

wire [1-1:0] cvted_ibp_dw32_in_2_ibp_cmd_chnl_user;


mss_bus_switch_ibpx2ibpy
  #(
     .N2W_SUPPORT_NARROW_TRANS (0),
    .W2N_SUPPORT_BURST_TRANS  (1),

    .BYPBUF_WD_CHNL (0),
    .SPLT_FIFO_DEPTH (64),
    .X_W  (32),
    .Y_W  (32),



    .X_CMD_CHNL_READ           (0),
    .X_CMD_CHNL_WRAP           (1),
    .X_CMD_CHNL_DATA_SIZE_LSB  (2),
    .X_CMD_CHNL_DATA_SIZE_W    (3),
    .X_CMD_CHNL_BURST_SIZE_LSB (5),
    .X_CMD_CHNL_BURST_SIZE_W   (4),
    .X_CMD_CHNL_PROT_LSB       (9),
    .X_CMD_CHNL_PROT_W         (2),
    .X_CMD_CHNL_CACHE_LSB      (11),
    .X_CMD_CHNL_CACHE_W        (4),
    .X_CMD_CHNL_LOCK           (15),
    .X_CMD_CHNL_EXCL           (16),
    .X_CMD_CHNL_ADDR_LSB       (17),
    .X_CMD_CHNL_ADDR_W         (42),
    .X_CMD_CHNL_W              (59),

    .X_WD_CHNL_LAST            (0),
    .X_WD_CHNL_DATA_LSB        (1),
    .X_WD_CHNL_DATA_W          (32),
    .X_WD_CHNL_MASK_LSB        (33),
    .X_WD_CHNL_MASK_W          (4),
    .X_WD_CHNL_W               (37),

    .X_RD_CHNL_ERR_RD          (0),
    .X_RD_CHNL_RD_EXCL_OK      (2),
    .X_RD_CHNL_RD_LAST         (1),
    .X_RD_CHNL_RD_DATA_LSB     (3),
    .X_RD_CHNL_RD_DATA_W       (32),
    .X_RD_CHNL_W               (35),

    .X_WRSP_CHNL_WR_DONE       (0),
    .X_WRSP_CHNL_WR_EXCL_DONE  (1),
    .X_WRSP_CHNL_ERR_WR        (2),
    .X_WRSP_CHNL_W             (3),



    .Y_CMD_CHNL_READ           (0),
    .Y_CMD_CHNL_WRAP           (1),
    .Y_CMD_CHNL_DATA_SIZE_LSB  (2),
    .Y_CMD_CHNL_DATA_SIZE_W    (3),
    .Y_CMD_CHNL_BURST_SIZE_LSB (5),
    .Y_CMD_CHNL_BURST_SIZE_W   (4),
    .Y_CMD_CHNL_PROT_LSB       (9),
    .Y_CMD_CHNL_PROT_W         (2),
    .Y_CMD_CHNL_CACHE_LSB      (11),
    .Y_CMD_CHNL_CACHE_W        (4),
    .Y_CMD_CHNL_LOCK           (15),
    .Y_CMD_CHNL_EXCL           (16),
    .Y_CMD_CHNL_ADDR_LSB       (17),
    .Y_CMD_CHNL_ADDR_W         (42),
    .Y_CMD_CHNL_W              (59),

    .Y_WD_CHNL_LAST            (0),
    .Y_WD_CHNL_DATA_LSB        (1),
    .Y_WD_CHNL_DATA_W          (32),
    .Y_WD_CHNL_MASK_LSB        (33),
    .Y_WD_CHNL_MASK_W          (4),
    .Y_WD_CHNL_W               (37),

    .Y_RD_CHNL_ERR_RD          (0),
    .Y_RD_CHNL_RD_EXCL_OK      (2),
    .Y_RD_CHNL_RD_LAST         (1),
    .Y_RD_CHNL_RD_DATA_LSB     (3),
    .Y_RD_CHNL_RD_DATA_W       (32),
    .Y_RD_CHNL_W               (35),

    .Y_WRSP_CHNL_WR_DONE       (0),
    .Y_WRSP_CHNL_WR_EXCL_DONE  (1),
    .Y_WRSP_CHNL_ERR_WR        (2),
    .Y_WRSP_CHNL_W             (3),
    .X_USER_W  (1),
    .Y_USER_W  (1),
    .X_RGON_W  (1),
    .Y_RGON_W  (1)
    )
 u_ibp_dw32_in_2_ibp32toibp32 (
    .i_ibp_cmd_chnl_rgon   (1'b1),



    .i_ibp_cmd_chnl_valid  (ibp_dw32_in_2_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (ibp_dw32_in_2_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (ibp_dw32_in_2_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (ibp_dw32_in_2_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (ibp_dw32_in_2_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (ibp_dw32_in_2_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (ibp_dw32_in_2_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (ibp_dw32_in_2_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (ibp_dw32_in_2_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (ibp_dw32_in_2_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(ibp_dw32_in_2_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (ibp_dw32_in_2_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (ibp_dw32_in_2_ibp_cmd_chnl_user),





    .o_ibp_cmd_chnl_valid  (cvted_ibp_dw32_in_2_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (cvted_ibp_dw32_in_2_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (cvted_ibp_dw32_in_2_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (cvted_ibp_dw32_in_2_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (cvted_ibp_dw32_in_2_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (cvted_ibp_dw32_in_2_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (cvted_ibp_dw32_in_2_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (cvted_ibp_dw32_in_2_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (cvted_ibp_dw32_in_2_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (cvted_ibp_dw32_in_2_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(cvted_ibp_dw32_in_2_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (cvted_ibp_dw32_in_2_ibp_wrsp_chnl),


// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
    .o_ibp_cmd_chnl_user   (cvted_ibp_dw32_in_2_ibp_cmd_chnl_user),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);





    wire [1-1:0] ibp_dw32_in_3_ibp_cmd_chnl_user = {1{1'b0}};

// Covert the ibp_dw32_in_3_ IBP width



 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_cmd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] cvted_ibp_dw32_in_3_ibp_cmd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_wd_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] cvted_ibp_dw32_in_3_ibp_wd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_rd_chnl_accept;
 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] cvted_ibp_dw32_in_3_ibp_rd_chnl;

 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] cvted_ibp_dw32_in_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] cvted_ibp_dw32_in_3_ibp_wrsp_chnl;

wire [1-1:0] cvted_ibp_dw32_in_3_ibp_cmd_chnl_user;




 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_cmd_chnl_valid;
 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] splt_i_ibp_dw32_in_3_ibp_cmd_chnl;

 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_wd_chnl_valid;
 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] splt_i_ibp_dw32_in_3_ibp_wd_chnl;

 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_rd_chnl_accept;
 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] splt_i_ibp_dw32_in_3_ibp_rd_chnl;

 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] splt_i_ibp_dw32_in_3_ibp_wrsp_chnl;

wire [1-1:0] splt_i_ibp_dw32_in_3_ibp_cmd_chnl_user;

 mss_bus_switch_ibp2ibps
  #(
    .CUT_IN2OUT_WR_ACPT (1),
    .ADDR_W(42),
    .DATA_W(512),
    .USER_W(1),
    .RGON_W(1),



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
    .SPLT_FIFO_DEPTH(64)
    ) u_ibp_dw32_in_3__ibp2ibps
  (
    .clk                       (clk  ),
    .rst_a                     (rst_a),





    .i_ibp_cmd_chnl_valid  (ibp_dw32_in_3_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (ibp_dw32_in_3_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (ibp_dw32_in_3_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (ibp_dw32_in_3_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (ibp_dw32_in_3_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (ibp_dw32_in_3_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (ibp_dw32_in_3_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (ibp_dw32_in_3_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (ibp_dw32_in_3_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (ibp_dw32_in_3_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(ibp_dw32_in_3_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (ibp_dw32_in_3_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (splt_i_ibp_dw32_in_3_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (splt_i_ibp_dw32_in_3_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (splt_i_ibp_dw32_in_3_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (splt_i_ibp_dw32_in_3_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (splt_i_ibp_dw32_in_3_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (splt_i_ibp_dw32_in_3_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (splt_i_ibp_dw32_in_3_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (splt_i_ibp_dw32_in_3_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (splt_i_ibp_dw32_in_3_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (splt_i_ibp_dw32_in_3_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(splt_i_ibp_dw32_in_3_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (splt_i_ibp_dw32_in_3_ibp_wrsp_chnl),


    .i_ibp_cmd_chnl_rgon   (1'b1),
    .i_ibp_cmd_chnl_user   (ibp_dw32_in_3_ibp_cmd_chnl_user),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
    .o_ibp_cmd_chnl_user   (splt_i_ibp_dw32_in_3_ibp_cmd_chnl_user)
// leda B_1011 on
// leda WV951025 on
  );

mss_bus_switch_ibpx2ibpy
  #(
     .N2W_SUPPORT_NARROW_TRANS (0),
    .W2N_SUPPORT_BURST_TRANS  (1),

    .BYPBUF_WD_CHNL (0),
    .SPLT_FIFO_DEPTH (64),
    .X_W  (512),
    .Y_W  (32),



    .X_CMD_CHNL_READ           (0),
    .X_CMD_CHNL_WRAP           (1),
    .X_CMD_CHNL_DATA_SIZE_LSB  (2),
    .X_CMD_CHNL_DATA_SIZE_W    (3),
    .X_CMD_CHNL_BURST_SIZE_LSB (5),
    .X_CMD_CHNL_BURST_SIZE_W   (4),
    .X_CMD_CHNL_PROT_LSB       (9),
    .X_CMD_CHNL_PROT_W         (2),
    .X_CMD_CHNL_CACHE_LSB      (11),
    .X_CMD_CHNL_CACHE_W        (4),
    .X_CMD_CHNL_LOCK           (15),
    .X_CMD_CHNL_EXCL           (16),
    .X_CMD_CHNL_ADDR_LSB       (17),
    .X_CMD_CHNL_ADDR_W         (42),
    .X_CMD_CHNL_W              (59),

    .X_WD_CHNL_LAST            (0),
    .X_WD_CHNL_DATA_LSB        (1),
    .X_WD_CHNL_DATA_W          (512),
    .X_WD_CHNL_MASK_LSB        (513),
    .X_WD_CHNL_MASK_W          (64),
    .X_WD_CHNL_W               (577),

    .X_RD_CHNL_ERR_RD          (0),
    .X_RD_CHNL_RD_EXCL_OK      (2),
    .X_RD_CHNL_RD_LAST         (1),
    .X_RD_CHNL_RD_DATA_LSB     (3),
    .X_RD_CHNL_RD_DATA_W       (512),
    .X_RD_CHNL_W               (515),

    .X_WRSP_CHNL_WR_DONE       (0),
    .X_WRSP_CHNL_WR_EXCL_DONE  (1),
    .X_WRSP_CHNL_ERR_WR        (2),
    .X_WRSP_CHNL_W             (3),



    .Y_CMD_CHNL_READ           (0),
    .Y_CMD_CHNL_WRAP           (1),
    .Y_CMD_CHNL_DATA_SIZE_LSB  (2),
    .Y_CMD_CHNL_DATA_SIZE_W    (3),
    .Y_CMD_CHNL_BURST_SIZE_LSB (5),
    .Y_CMD_CHNL_BURST_SIZE_W   (4),
    .Y_CMD_CHNL_PROT_LSB       (9),
    .Y_CMD_CHNL_PROT_W         (2),
    .Y_CMD_CHNL_CACHE_LSB      (11),
    .Y_CMD_CHNL_CACHE_W        (4),
    .Y_CMD_CHNL_LOCK           (15),
    .Y_CMD_CHNL_EXCL           (16),
    .Y_CMD_CHNL_ADDR_LSB       (17),
    .Y_CMD_CHNL_ADDR_W         (42),
    .Y_CMD_CHNL_W              (59),

    .Y_WD_CHNL_LAST            (0),
    .Y_WD_CHNL_DATA_LSB        (1),
    .Y_WD_CHNL_DATA_W          (32),
    .Y_WD_CHNL_MASK_LSB        (33),
    .Y_WD_CHNL_MASK_W          (4),
    .Y_WD_CHNL_W               (37),

    .Y_RD_CHNL_ERR_RD          (0),
    .Y_RD_CHNL_RD_EXCL_OK      (2),
    .Y_RD_CHNL_RD_LAST         (1),
    .Y_RD_CHNL_RD_DATA_LSB     (3),
    .Y_RD_CHNL_RD_DATA_W       (32),
    .Y_RD_CHNL_W               (35),

    .Y_WRSP_CHNL_WR_DONE       (0),
    .Y_WRSP_CHNL_WR_EXCL_DONE  (1),
    .Y_WRSP_CHNL_ERR_WR        (2),
    .Y_WRSP_CHNL_W             (3),
    .X_USER_W  (1),
    .Y_USER_W  (1),
    .X_RGON_W  (1),
    .Y_RGON_W  (1)
    )
 u_ibp_dw32_in_3_ibp512toibp32 (
    .i_ibp_cmd_chnl_rgon   (1'b1),



    .i_ibp_cmd_chnl_valid  (splt_i_ibp_dw32_in_3_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (splt_i_ibp_dw32_in_3_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (splt_i_ibp_dw32_in_3_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (splt_i_ibp_dw32_in_3_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (splt_i_ibp_dw32_in_3_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (splt_i_ibp_dw32_in_3_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (splt_i_ibp_dw32_in_3_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (splt_i_ibp_dw32_in_3_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (splt_i_ibp_dw32_in_3_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (splt_i_ibp_dw32_in_3_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(splt_i_ibp_dw32_in_3_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (splt_i_ibp_dw32_in_3_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (splt_i_ibp_dw32_in_3_ibp_cmd_chnl_user),





    .o_ibp_cmd_chnl_valid  (cvted_ibp_dw32_in_3_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (cvted_ibp_dw32_in_3_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (cvted_ibp_dw32_in_3_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (cvted_ibp_dw32_in_3_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (cvted_ibp_dw32_in_3_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (cvted_ibp_dw32_in_3_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (cvted_ibp_dw32_in_3_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (cvted_ibp_dw32_in_3_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (cvted_ibp_dw32_in_3_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (cvted_ibp_dw32_in_3_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(cvted_ibp_dw32_in_3_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (cvted_ibp_dw32_in_3_ibp_wrsp_chnl),


// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
    .o_ibp_cmd_chnl_user   (cvted_ibp_dw32_in_3_ibp_cmd_chnl_user),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);














// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: Dummy signals are indeed no driven
wire cming_dummy0;
wire cming_dummy1;
wire cming_ibp_lockable_dummy;
// leda NTL_CON13A on


// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: When there is no ibp compr, this signal no driving indeed
wire [4*4 -1:0] cming_ibp_uniq_id;
wire [1*4 -1:0] cming_ibp_cmd_chnl_user;
wire [4 -1:0] cming_ibp_lockable;
// leda NTL_CON13A on



 wire [4-1:0] cming_ibp_cmd_chnl_valid;
 wire [4-1:0] cming_ibp_cmd_chnl_accept;
 wire [59 * 4 -1:0] cming_ibp_cmd_chnl;

 wire [4-1:0] cming_ibp_wd_chnl_valid;
 wire [4-1:0] cming_ibp_wd_chnl_accept;
 wire [37 * 4 -1:0] cming_ibp_wd_chnl;

 wire [4-1:0] cming_ibp_rd_chnl_accept;
 wire [4-1:0] cming_ibp_rd_chnl_valid;
 wire [35 * 4 -1:0] cming_ibp_rd_chnl;

 wire [4-1:0] cming_ibp_wrsp_chnl_valid;
 wire [4-1:0] cming_ibp_wrsp_chnl_accept;
 wire [3 * 4 -1:0] cming_ibp_wrsp_chnl;




    // no more 64 FIFO depth allowed to hurt timing



wire ibp_dw32_in_0_ibp_lockable = 1;
wire ibp_dw32_in_1_ibp_lockable = 1;
wire ibp_dw32_in_2_ibp_lockable = 1;
wire ibp_dw32_in_3_ibp_lockable = 1;

// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign {cming_ibp_lockable_dummy,
        cming_ibp_lockable}
        = {
            1'b0
                  ,ibp_dw32_in_0_ibp_lockable
                  ,ibp_dw32_in_1_ibp_lockable
                  ,ibp_dw32_in_2_ibp_lockable
                  ,ibp_dw32_in_3_ibp_lockable
   };
// leda NTL_CON16 on



// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign
  {
    cming_dummy0,
    cming_ibp_uniq_id,
    cming_ibp_cmd_chnl_user,
    cming_ibp_cmd_chnl,
    cming_ibp_cmd_chnl_valid,
    cming_ibp_wd_chnl,
    cming_ibp_wd_chnl_valid,
    cming_ibp_rd_chnl_accept,
    cming_ibp_wrsp_chnl_accept
    }
  =
  {
    1'b1
              ,4'd0
              ,4'd1
              ,4'd2
              ,4'd3
                  ,cvted_ibp_dw32_in_0_ibp_cmd_chnl_user
                  ,cvted_ibp_dw32_in_1_ibp_cmd_chnl_user
                  ,cvted_ibp_dw32_in_2_ibp_cmd_chnl_user
                  ,cvted_ibp_dw32_in_3_ibp_cmd_chnl_user
                  ,cvted_ibp_dw32_in_0_ibp_cmd_chnl
                  ,cvted_ibp_dw32_in_1_ibp_cmd_chnl
                  ,cvted_ibp_dw32_in_2_ibp_cmd_chnl
                  ,cvted_ibp_dw32_in_3_ibp_cmd_chnl
                  ,cvted_ibp_dw32_in_0_ibp_cmd_chnl_valid
                  ,cvted_ibp_dw32_in_1_ibp_cmd_chnl_valid
                  ,cvted_ibp_dw32_in_2_ibp_cmd_chnl_valid
                  ,cvted_ibp_dw32_in_3_ibp_cmd_chnl_valid
                  ,cvted_ibp_dw32_in_0_ibp_wd_chnl
                  ,cvted_ibp_dw32_in_1_ibp_wd_chnl
                  ,cvted_ibp_dw32_in_2_ibp_wd_chnl
                  ,cvted_ibp_dw32_in_3_ibp_wd_chnl
                  ,cvted_ibp_dw32_in_0_ibp_wd_chnl_valid
                  ,cvted_ibp_dw32_in_1_ibp_wd_chnl_valid
                  ,cvted_ibp_dw32_in_2_ibp_wd_chnl_valid
                  ,cvted_ibp_dw32_in_3_ibp_wd_chnl_valid
                  ,cvted_ibp_dw32_in_0_ibp_rd_chnl_accept
                  ,cvted_ibp_dw32_in_1_ibp_rd_chnl_accept
                  ,cvted_ibp_dw32_in_2_ibp_rd_chnl_accept
                  ,cvted_ibp_dw32_in_3_ibp_rd_chnl_accept
                  ,cvted_ibp_dw32_in_0_ibp_wrsp_chnl_accept
                  ,cvted_ibp_dw32_in_1_ibp_wrsp_chnl_accept
                  ,cvted_ibp_dw32_in_2_ibp_wrsp_chnl_accept
                  ,cvted_ibp_dw32_in_3_ibp_wrsp_chnl_accept
  };
// leda NTL_CON16 on

// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign
  {
    cming_dummy1
                  ,cvted_ibp_dw32_in_0_ibp_rd_chnl
                  ,cvted_ibp_dw32_in_1_ibp_rd_chnl
                  ,cvted_ibp_dw32_in_2_ibp_rd_chnl
                  ,cvted_ibp_dw32_in_3_ibp_rd_chnl
                  ,cvted_ibp_dw32_in_0_ibp_rd_chnl_valid
                  ,cvted_ibp_dw32_in_1_ibp_rd_chnl_valid
                  ,cvted_ibp_dw32_in_2_ibp_rd_chnl_valid
                  ,cvted_ibp_dw32_in_3_ibp_rd_chnl_valid
                  ,cvted_ibp_dw32_in_0_ibp_wrsp_chnl
                  ,cvted_ibp_dw32_in_1_ibp_wrsp_chnl
                  ,cvted_ibp_dw32_in_2_ibp_wrsp_chnl
                  ,cvted_ibp_dw32_in_3_ibp_wrsp_chnl
                  ,cvted_ibp_dw32_in_0_ibp_wrsp_chnl_valid
                  ,cvted_ibp_dw32_in_1_ibp_wrsp_chnl_valid
                  ,cvted_ibp_dw32_in_2_ibp_wrsp_chnl_valid
                  ,cvted_ibp_dw32_in_3_ibp_wrsp_chnl_valid
                  ,cvted_ibp_dw32_in_0_ibp_cmd_chnl_accept
                  ,cvted_ibp_dw32_in_1_ibp_cmd_chnl_accept
                  ,cvted_ibp_dw32_in_2_ibp_cmd_chnl_accept
                  ,cvted_ibp_dw32_in_3_ibp_cmd_chnl_accept
                  ,cvted_ibp_dw32_in_0_ibp_wd_chnl_accept
                  ,cvted_ibp_dw32_in_1_ibp_wd_chnl_accept
                  ,cvted_ibp_dw32_in_2_ibp_wd_chnl_accept
                  ,cvted_ibp_dw32_in_3_ibp_wd_chnl_accept
  }
  =
    {
    1'b1,
    cming_ibp_rd_chnl,
    cming_ibp_rd_chnl_valid,
    cming_ibp_wrsp_chnl,
    cming_ibp_wrsp_chnl_valid,
    cming_ibp_cmd_chnl_accept,
    cming_ibp_wd_chnl_accept
    } ;
// leda NTL_CON16 on





 wire [1-1:0] cmed_ibp_cmd_chnl_valid;
 wire [1-1:0] cmed_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] cmed_ibp_cmd_chnl;

 wire [1-1:0] cmed_ibp_wd_chnl_valid;
 wire [1-1:0] cmed_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] cmed_ibp_wd_chnl;

 wire [1-1:0] cmed_ibp_rd_chnl_accept;
 wire [1-1:0] cmed_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] cmed_ibp_rd_chnl;

 wire [1-1:0] cmed_ibp_wrsp_chnl_valid;
 wire [1-1:0] cmed_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] cmed_ibp_wrsp_chnl;


// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: Some of ID signals are not used
wire [1-1:0] cmed_ibp_cmd_chnl_user;
wire [4-1:0] cmed_ibp_cmd_chnl_id;
wire [4-1:0] cmed_ibp_wd_chnl_id;
// leda NTL_CON13A on

// Compress all IBPs into one IBP
mss_bus_switch_ibp_compr
  #(
    .COMP_NUM         (4),
    .COMP_FIFO_WIDTH  (4),
    .COMP_FIFO_DEPTH  (64),




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

    .USER_W           (1),
    .RGON_W           (1),
    .ID_WIDTH         (4)
    )
 u_cming_ibp_compr(
    .i_bus_ibp_uniq_id         (cming_ibp_uniq_id),
    .i_bus_ibp_cmd_chnl_user   (cming_ibp_cmd_chnl_user),
    .i_bus_ibp_lockable        (cming_ibp_lockable),




    .i_bus_ibp_cmd_chnl_valid  (cming_ibp_cmd_chnl_valid),
    .i_bus_ibp_cmd_chnl_accept (cming_ibp_cmd_chnl_accept),
    .i_bus_ibp_cmd_chnl        (cming_ibp_cmd_chnl),

    .i_bus_ibp_rd_chnl_valid   (cming_ibp_rd_chnl_valid),
    .i_bus_ibp_rd_chnl_accept  (cming_ibp_rd_chnl_accept),
    .i_bus_ibp_rd_chnl         (cming_ibp_rd_chnl),

    .i_bus_ibp_wd_chnl_valid   (cming_ibp_wd_chnl_valid),
    .i_bus_ibp_wd_chnl_accept  (cming_ibp_wd_chnl_accept),
    .i_bus_ibp_wd_chnl         (cming_ibp_wd_chnl),

    .i_bus_ibp_wrsp_chnl_valid (cming_ibp_wrsp_chnl_valid),
    .i_bus_ibp_wrsp_chnl_accept(cming_ibp_wrsp_chnl_accept),
    .i_bus_ibp_wrsp_chnl       (cming_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (cmed_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (cmed_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (cmed_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (cmed_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (cmed_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (cmed_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (cmed_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (cmed_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (cmed_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (cmed_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(cmed_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (cmed_ibp_wrsp_chnl),


    .o_ibp_cmd_chnl_id         (cmed_ibp_cmd_chnl_id),
    .o_ibp_cmd_chnl_user       (cmed_ibp_cmd_chnl_user),
    .o_ibp_wd_chnl_id          (cmed_ibp_wd_chnl_id),

    .rst_a                     (rst_a),
    .clk                       (clk               )
);




 wire [1-1:0] bfed_cmed_ibp_cmd_chnl_valid;
 wire [1-1:0] bfed_cmed_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] bfed_cmed_ibp_cmd_chnl;

 wire [1-1:0] bfed_cmed_ibp_wd_chnl_valid;
 wire [1-1:0] bfed_cmed_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] bfed_cmed_ibp_wd_chnl;

 wire [1-1:0] bfed_cmed_ibp_rd_chnl_accept;
 wire [1-1:0] bfed_cmed_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] bfed_cmed_ibp_rd_chnl;

 wire [1-1:0] bfed_cmed_ibp_wrsp_chnl_valid;
 wire [1-1:0] bfed_cmed_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] bfed_cmed_ibp_wrsp_chnl;

wire [1-1:0] bfed_cmed_ibp_cmd_chnl_user;


mss_bus_switch_mst_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),
    .USER_W          (1),
    .RGON_W          (1),



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
    .CMD_CHNL_FIFO_MWHILE(0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE   (0),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0)
    )
 u_cmed_ibp_buffer(
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .ibp_buffer_idle       (),
// leda B_1011 on
// leda WV951025 on
    .i_ibp_clk_en   (1'b1),

    .i_ibp_cmd_chnl_rgon   (1'b1),



    .i_ibp_cmd_chnl_valid  (cmed_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (cmed_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (cmed_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (cmed_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (cmed_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (cmed_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (cmed_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (cmed_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (cmed_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (cmed_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(cmed_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (cmed_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (cmed_ibp_cmd_chnl_user),


    .o_ibp_clk_en   (1'b1),




    .o_ibp_cmd_chnl_valid  (bfed_cmed_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (bfed_cmed_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (bfed_cmed_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (bfed_cmed_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (bfed_cmed_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (bfed_cmed_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (bfed_cmed_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (bfed_cmed_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (bfed_cmed_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (bfed_cmed_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(bfed_cmed_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (bfed_cmed_ibp_wrsp_chnl),


// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
    .o_ibp_cmd_chnl_user   (bfed_cmed_ibp_cmd_chnl_user),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



    wire [1-1:0] ibp_dw32_out_ibp_cmd_user;
// leda NTL_CON10 off
// leda NTL_CON10B off
// LMD: output tied to supply Ranges
// LJ: No care about the constant tied
mss_bus_switch_pack2ibp
  #(
    .ADDR_W                  (42),
    .DATA_W                  (32),



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
    .USER_W                  (1),
    .RGON_W                  (1)

    )
u_bfed_cmed_pack2ibp
  (
    .ibp_cmd_chnl_rgon   (1'b1),
    .ibp_cmd_chnl_user   (bfed_cmed_ibp_cmd_chnl_user),



    .ibp_cmd_chnl_valid  (bfed_cmed_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (bfed_cmed_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (bfed_cmed_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (bfed_cmed_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (bfed_cmed_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (bfed_cmed_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (bfed_cmed_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (bfed_cmed_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (bfed_cmed_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (bfed_cmed_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(bfed_cmed_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (bfed_cmed_ibp_wrsp_chnl),



  .ibp_cmd_valid             (ibp_dw32_out_ibp_cmd_valid),
  .ibp_cmd_accept            (ibp_dw32_out_ibp_cmd_accept),
  .ibp_cmd_read              (ibp_dw32_out_ibp_cmd_read),
  .ibp_cmd_addr              (ibp_dw32_out_ibp_cmd_addr),
  .ibp_cmd_wrap              (ibp_dw32_out_ibp_cmd_wrap),
  .ibp_cmd_data_size         (ibp_dw32_out_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (ibp_dw32_out_ibp_cmd_burst_size),
  .ibp_cmd_prot              (ibp_dw32_out_ibp_cmd_prot),
  .ibp_cmd_cache             (ibp_dw32_out_ibp_cmd_cache),
  .ibp_cmd_lock              (ibp_dw32_out_ibp_cmd_lock),
  .ibp_cmd_excl              (ibp_dw32_out_ibp_cmd_excl),

  .ibp_rd_valid              (ibp_dw32_out_ibp_rd_valid),
  .ibp_rd_excl_ok            (ibp_dw32_out_ibp_rd_excl_ok),
  .ibp_rd_accept             (ibp_dw32_out_ibp_rd_accept),
  .ibp_err_rd                (ibp_dw32_out_ibp_err_rd),
  .ibp_rd_data               (ibp_dw32_out_ibp_rd_data),
  .ibp_rd_last               (ibp_dw32_out_ibp_rd_last),

  .ibp_wr_valid              (ibp_dw32_out_ibp_wr_valid),
  .ibp_wr_accept             (ibp_dw32_out_ibp_wr_accept),
  .ibp_wr_data               (ibp_dw32_out_ibp_wr_data),
  .ibp_wr_mask               (ibp_dw32_out_ibp_wr_mask),
  .ibp_wr_last               (ibp_dw32_out_ibp_wr_last),

  .ibp_wr_done               (ibp_dw32_out_ibp_wr_done),
  .ibp_wr_excl_done          (ibp_dw32_out_ibp_wr_excl_done),
  .ibp_err_wr                (ibp_dw32_out_ibp_err_wr),
  .ibp_wr_resp_accept        (ibp_dw32_out_ibp_wr_resp_accept),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .ibp_cmd_rgon   (),
    .ibp_cmd_user   (ibp_dw32_out_ibp_cmd_user)
// leda B_1011 on
// leda WV951025 on

   );
// leda NTL_CON10 on
// leda NTL_CON10B on





// leda G_521_2_B on
endmodule // mss_bus_switch_ibp_dw32_mst


