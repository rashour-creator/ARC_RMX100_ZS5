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
//  Verilog module of mss_bus_switch_dw512 slave port
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "alb_mss_bus_switch_defines.v"

// Set simulation timescale
//
`include "const.def"



module mss_bus_switch_dw512_slv
// leda G_521_2_B off
// LMD: Use lowercase letters for all signal reg, net and port names
// LJ: Pfx may include the uppercase, so disable the lint checking rule
  (



































  input  [9 -1:0]      dw512_in_ibp_cmd_rgon,

  input                                   dw512_in_ibp_cmd_valid,
  output                                  dw512_in_ibp_cmd_accept,
  input                                   dw512_in_ibp_cmd_read,
  input   [42                -1:0]       dw512_in_ibp_cmd_addr,
  input                                   dw512_in_ibp_cmd_wrap,
  input   [3-1:0]       dw512_in_ibp_cmd_data_size,
  input   [4-1:0]       dw512_in_ibp_cmd_burst_size,
  input   [2-1:0]       dw512_in_ibp_cmd_prot,
  input   [4-1:0]       dw512_in_ibp_cmd_cache,
  input                                   dw512_in_ibp_cmd_lock,
  input                                   dw512_in_ibp_cmd_excl,

  output                                  dw512_in_ibp_rd_valid,
  output                                  dw512_in_ibp_rd_excl_ok,
  input                                   dw512_in_ibp_rd_accept,
  output                                  dw512_in_ibp_err_rd,
  output  [512               -1:0]        dw512_in_ibp_rd_data,
  output                                  dw512_in_ibp_rd_last,

  input                                   dw512_in_ibp_wr_valid,
  output                                  dw512_in_ibp_wr_accept,
  input   [512               -1:0]        dw512_in_ibp_wr_data,
  input   [(512         /8)  -1:0]        dw512_in_ibp_wr_mask,
  input                                   dw512_in_ibp_wr_last,

  output                                  dw512_in_ibp_wr_done,
  output                                  dw512_in_ibp_wr_excl_done,
  output                                  dw512_in_ibp_err_wr,
  input                                   dw512_in_ibp_wr_resp_accept,




 output [1-1:0] dw512_out_0_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_0_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_0_ibp_cmd_chnl,

 output [1-1:0] dw512_out_0_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_0_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_0_ibp_wd_chnl,

 output [1-1:0] dw512_out_0_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_0_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_0_ibp_rd_chnl,

 input  [1-1:0] dw512_out_0_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_0_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_0_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_1_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_1_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_1_ibp_cmd_chnl,

 output [1-1:0] dw512_out_1_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_1_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_1_ibp_wd_chnl,

 output [1-1:0] dw512_out_1_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_1_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_1_ibp_rd_chnl,

 input  [1-1:0] dw512_out_1_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_1_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_1_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_2_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_2_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_2_ibp_cmd_chnl,

 output [1-1:0] dw512_out_2_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_2_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_2_ibp_wd_chnl,

 output [1-1:0] dw512_out_2_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_2_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_2_ibp_rd_chnl,

 input  [1-1:0] dw512_out_2_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_2_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_2_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_3_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_3_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_3_ibp_cmd_chnl,

 output [1-1:0] dw512_out_3_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_3_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_3_ibp_wd_chnl,

 output [1-1:0] dw512_out_3_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_3_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_3_ibp_rd_chnl,

 input  [1-1:0] dw512_out_3_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_3_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_3_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_4_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_4_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_4_ibp_cmd_chnl,

 output [1-1:0] dw512_out_4_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_4_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_4_ibp_wd_chnl,

 output [1-1:0] dw512_out_4_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_4_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_4_ibp_rd_chnl,

 input  [1-1:0] dw512_out_4_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_4_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_4_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_5_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_5_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_5_ibp_cmd_chnl,

 output [1-1:0] dw512_out_5_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_5_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_5_ibp_wd_chnl,

 output [1-1:0] dw512_out_5_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_5_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_5_ibp_rd_chnl,

 input  [1-1:0] dw512_out_5_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_5_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_5_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_6_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_6_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_6_ibp_cmd_chnl,

 output [1-1:0] dw512_out_6_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_6_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_6_ibp_wd_chnl,

 output [1-1:0] dw512_out_6_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_6_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_6_ibp_rd_chnl,

 input  [1-1:0] dw512_out_6_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_6_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_6_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_7_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_7_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_7_ibp_cmd_chnl,

 output [1-1:0] dw512_out_7_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_7_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_7_ibp_wd_chnl,

 output [1-1:0] dw512_out_7_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_7_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_7_ibp_rd_chnl,

 input  [1-1:0] dw512_out_7_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_7_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_7_ibp_wrsp_chnl,





 output [1-1:0] dw512_out_8_ibp_cmd_chnl_valid,
 input  [1-1:0] dw512_out_8_ibp_cmd_chnl_accept,
 output [59 * 1 -1:0] dw512_out_8_ibp_cmd_chnl,

 output [1-1:0] dw512_out_8_ibp_wd_chnl_valid,
 input  [1-1:0] dw512_out_8_ibp_wd_chnl_accept,
 output [577 * 1 -1:0] dw512_out_8_ibp_wd_chnl,

 output [1-1:0] dw512_out_8_ibp_rd_chnl_accept,
 input  [1-1:0] dw512_out_8_ibp_rd_chnl_valid,
 input  [515 * 1 -1:0] dw512_out_8_ibp_rd_chnl,

 input  [1-1:0] dw512_out_8_ibp_wrsp_chnl_valid,
 output [1-1:0] dw512_out_8_ibp_wrsp_chnl_accept,
 input  [3 * 1 -1:0] dw512_out_8_ibp_wrsp_chnl,




  input                                   clk,
// leda NTL_CON13C off
// LMD: non driving internal net
// LJ: Some signals bit field are indeed no driven
  input                                   sync_rst_r,
  input                                   async_rst,
// leda NTL_CON13C on
  input                                   rst_a
);




wire [9 -1:0] i_ibp_cmd_chnl_rgon;
wire [1 -1:0] i_ibp_cmd_chnl_user;



 wire [1-1:0] i_ibp_cmd_chnl_valid;
 wire [1-1:0] i_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] i_ibp_cmd_chnl;

 wire [1-1:0] i_ibp_wd_chnl_valid;
 wire [1-1:0] i_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] i_ibp_wd_chnl;

 wire [1-1:0] i_ibp_rd_chnl_accept;
 wire [1-1:0] i_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] i_ibp_rd_chnl;

 wire [1-1:0] i_ibp_wrsp_chnl_valid;
 wire [1-1:0] i_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] i_ibp_wrsp_chnl;














wire  [1 -1:0]      dw512_in_ibp_cmd_user = {1{1'b0}};

wire [9 -1:0] dw512_in_ibp_cmd_chnl_rgon;
wire [1 -1:0] dw512_in_ibp_cmd_chnl_user;



 wire [1-1:0] dw512_in_ibp_cmd_chnl_valid;
 wire [1-1:0] dw512_in_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] dw512_in_ibp_cmd_chnl;

 wire [1-1:0] dw512_in_ibp_wd_chnl_valid;
 wire [1-1:0] dw512_in_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] dw512_in_ibp_wd_chnl;

 wire [1-1:0] dw512_in_ibp_rd_chnl_accept;
 wire [1-1:0] dw512_in_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] dw512_in_ibp_rd_chnl;

 wire [1-1:0] dw512_in_ibp_wrsp_chnl_valid;
 wire [1-1:0] dw512_in_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] dw512_in_ibp_wrsp_chnl;


// leda NTL_CON10 off
// leda NTL_CON10B off
// LMD: output tied to supply Ranges
// LJ: No care about the constant tied
mss_bus_switch_ibp2pack
  #(
    .ADDR_W (42),
    .DATA_W (512),



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
    .USER_W(1),
    .RGON_W(9)
    )
u_dw512_in_ibp2pack
  (
    .rst_a                     (rst_a),
    .clk                       (clk               ) ,
    .ibp_cmd_user              (dw512_in_ibp_cmd_user),
    .ibp_cmd_chnl_user         (dw512_in_ibp_cmd_chnl_user),

  .ibp_cmd_valid             (dw512_in_ibp_cmd_valid),
  .ibp_cmd_accept            (dw512_in_ibp_cmd_accept),
  .ibp_cmd_read              (dw512_in_ibp_cmd_read),
  .ibp_cmd_addr              (dw512_in_ibp_cmd_addr),
  .ibp_cmd_wrap              (dw512_in_ibp_cmd_wrap),
  .ibp_cmd_data_size         (dw512_in_ibp_cmd_data_size),
  .ibp_cmd_burst_size        (dw512_in_ibp_cmd_burst_size),
  .ibp_cmd_prot              (dw512_in_ibp_cmd_prot),
  .ibp_cmd_cache             (dw512_in_ibp_cmd_cache),
  .ibp_cmd_lock              (dw512_in_ibp_cmd_lock),
  .ibp_cmd_excl              (dw512_in_ibp_cmd_excl),

  .ibp_rd_valid              (dw512_in_ibp_rd_valid),
  .ibp_rd_excl_ok            (dw512_in_ibp_rd_excl_ok),
  .ibp_rd_accept             (dw512_in_ibp_rd_accept),
  .ibp_err_rd                (dw512_in_ibp_err_rd),
  .ibp_rd_data               (dw512_in_ibp_rd_data),
  .ibp_rd_last               (dw512_in_ibp_rd_last),

  .ibp_wr_valid              (dw512_in_ibp_wr_valid),
  .ibp_wr_accept             (dw512_in_ibp_wr_accept),
  .ibp_wr_data               (dw512_in_ibp_wr_data),
  .ibp_wr_mask               (dw512_in_ibp_wr_mask),
  .ibp_wr_last               (dw512_in_ibp_wr_last),

  .ibp_wr_done               (dw512_in_ibp_wr_done),
  .ibp_wr_excl_done          (dw512_in_ibp_wr_excl_done),
  .ibp_err_wr                (dw512_in_ibp_err_wr),
  .ibp_wr_resp_accept        (dw512_in_ibp_wr_resp_accept),



    .ibp_cmd_chnl_valid  (dw512_in_ibp_cmd_chnl_valid),
    .ibp_cmd_chnl_accept (dw512_in_ibp_cmd_chnl_accept),
    .ibp_cmd_chnl        (dw512_in_ibp_cmd_chnl),

    .ibp_rd_chnl_valid   (dw512_in_ibp_rd_chnl_valid),
    .ibp_rd_chnl_accept  (dw512_in_ibp_rd_chnl_accept),
    .ibp_rd_chnl         (dw512_in_ibp_rd_chnl),

    .ibp_wd_chnl_valid   (dw512_in_ibp_wd_chnl_valid),
    .ibp_wd_chnl_accept  (dw512_in_ibp_wd_chnl_accept),
    .ibp_wd_chnl         (dw512_in_ibp_wd_chnl),

    .ibp_wrsp_chnl_valid (dw512_in_ibp_wrsp_chnl_valid),
    .ibp_wrsp_chnl_accept(dw512_in_ibp_wrsp_chnl_accept),
    .ibp_wrsp_chnl       (dw512_in_ibp_wrsp_chnl),

    .ibp_cmd_rgon              (dw512_in_ibp_cmd_rgon),
    .ibp_cmd_chnl_rgon         (dw512_in_ibp_cmd_chnl_rgon)
   );
// leda NTL_CON10 on
// leda NTL_CON10B on


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE(0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE   (0),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),
    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(9)
    )
 u_i_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .ibp_buffer_idle       (),
// leda B_1011 on
// leda WV951025 on

    .i_ibp_cmd_chnl_rgon   (dw512_in_ibp_cmd_chnl_rgon),
    .o_ibp_cmd_chnl_rgon   (i_ibp_cmd_chnl_rgon),




    .i_ibp_cmd_chnl_valid  (dw512_in_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (dw512_in_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (dw512_in_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (dw512_in_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (dw512_in_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (dw512_in_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (dw512_in_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (dw512_in_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (dw512_in_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (dw512_in_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(dw512_in_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (dw512_in_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user         (dw512_in_ibp_cmd_chnl_user),



    .o_ibp_cmd_chnl_valid  (i_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (i_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (i_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (i_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (i_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (i_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (i_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (i_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (i_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (i_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(i_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (i_ibp_wrsp_chnl),

    .o_ibp_cmd_chnl_user         (i_ibp_cmd_chnl_user),

    .rst_a               (rst_a),
    .clk                 (clk               )
);








// Covert the IBP width



 wire [1-1:0] cvted_i_ibp_cmd_chnl_valid;
 wire [1-1:0] cvted_i_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] cvted_i_ibp_cmd_chnl;

 wire [1-1:0] cvted_i_ibp_wd_chnl_valid;
 wire [1-1:0] cvted_i_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] cvted_i_ibp_wd_chnl;

 wire [1-1:0] cvted_i_ibp_rd_chnl_accept;
 wire [1-1:0] cvted_i_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] cvted_i_ibp_rd_chnl;

 wire [1-1:0] cvted_i_ibp_wrsp_chnl_valid;
 wire [1-1:0] cvted_i_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] cvted_i_ibp_wrsp_chnl;

wire [1 -1:0] cvted_i_ibp_cmd_chnl_user;
wire [9 -1:0] cvted_i_ibp_cmd_chnl_rgon;
wire [9 -1:0] cvted_i_ibp_cmd_chnl_rgon_corr;
wire cvted_i_ibp_cmd_chnl_rgon_vld = 1'b0
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd1)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd2)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd4)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd8)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd16)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd32)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd64)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd128)
      | (cvted_i_ibp_cmd_chnl_rgon == 9'd256)
    ;
assign cvted_i_ibp_cmd_chnl_rgon_corr =
  cvted_i_ibp_cmd_chnl_rgon_vld ? cvted_i_ibp_cmd_chnl_rgon : 9'd1;



mss_bus_switch_ibpx2ibpy
  #(
           .N2W_SUPPORT_NARROW_TRANS (1),
           .W2N_SUPPORT_BURST_TRANS  (1),

    .SPLT_FIFO_DEPTH      (64),
    .BYPBUF_WD_CHNL       (0),
    .X_W  (512),
    .Y_W  (512),




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
    .Y_WD_CHNL_DATA_W          (512),
    .Y_WD_CHNL_MASK_LSB        (513),
    .Y_WD_CHNL_MASK_W          (64),
    .Y_WD_CHNL_W               (577),

    .Y_RD_CHNL_ERR_RD          (0),
    .Y_RD_CHNL_RD_EXCL_OK      (2),
    .Y_RD_CHNL_RD_LAST         (1),
    .Y_RD_CHNL_RD_DATA_LSB     (3),
    .Y_RD_CHNL_RD_DATA_W       (512),
    .Y_RD_CHNL_W               (515),

    .Y_WRSP_CHNL_WR_DONE       (0),
    .Y_WRSP_CHNL_WR_EXCL_DONE  (1),
    .Y_WRSP_CHNL_ERR_WR        (2),
    .Y_WRSP_CHNL_W             (3),

    .X_USER_W(1),
    .Y_USER_W(1),
    .X_RGON_W  (9),
    .Y_RGON_W  (9)
    )
 u_i_ibp512toibp512 (



    .i_ibp_cmd_chnl_valid  (i_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (i_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (i_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (i_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (i_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (i_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (i_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (i_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (i_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (i_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(i_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (i_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (cvted_i_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (cvted_i_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (cvted_i_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (cvted_i_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (cvted_i_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (cvted_i_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (cvted_i_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (cvted_i_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (cvted_i_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (cvted_i_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(cvted_i_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (cvted_i_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (i_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (cvted_i_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (i_ibp_cmd_chnl_rgon),
    .o_ibp_cmd_chnl_rgon   (cvted_i_ibp_cmd_chnl_rgon),

    .rst_a               (rst_a),
    .clk                 (clk               )
);

// Buffer the IBP for better timing

// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: The region is not used for IOC port
wire [9   -1:0] mid_ibp_cmd_chnl_rgon;
wire [1-1:0] mid_ibp_cmd_chnl_user;
// leda NTL_CON13A on



 wire [1-1:0] mid_ibp_cmd_chnl_valid;
 wire [1-1:0] mid_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] mid_ibp_cmd_chnl;

 wire [1-1:0] mid_ibp_wd_chnl_valid;
 wire [1-1:0] mid_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] mid_ibp_wd_chnl;

 wire [1-1:0] mid_ibp_rd_chnl_accept;
 wire [1-1:0] mid_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] mid_ibp_rd_chnl;

 wire [1-1:0] mid_ibp_wrsp_chnl_valid;
 wire [1-1:0] mid_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] mid_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0 ),
    .WDATA_CHNL_FIFO_MWHILE(0  ),
    .RDATA_CHNL_FIFO_MWHILE(0  ),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE   (0 ),
    .CMD_CHNL_FIFO_DEPTH   (0 ),
    .WDATA_CHNL_FIFO_DEPTH (0  ),
    .RDATA_CHNL_FIFO_DEPTH (0  ),
    .WRESP_CHNL_FIFO_DEPTH (0),
    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(9)
    )
 u_mid_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .ibp_buffer_idle       (),
// leda B_1011 on
// leda WV951025 on




    .i_ibp_cmd_chnl_valid  (cvted_i_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (cvted_i_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (cvted_i_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (cvted_i_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (cvted_i_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (cvted_i_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (cvted_i_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (cvted_i_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (cvted_i_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (cvted_i_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(cvted_i_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (cvted_i_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (mid_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (mid_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (mid_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (mid_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (mid_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (mid_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (mid_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (mid_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (mid_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (mid_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(mid_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (mid_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (cvted_i_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (mid_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (cvted_i_ibp_cmd_chnl_rgon_corr),
    .o_ibp_cmd_chnl_rgon   (mid_ibp_cmd_chnl_rgon),

    .rst_a               (rst_a),
    .clk                 (clk               )
);






 wire [1-1:0] pre_bind_dw512_out_0_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_0_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_0_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_0_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_0_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_0_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_0_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_0_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_0_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_0_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_0_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_0_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 1);






 wire [1-1:0] pre_bind_dw512_out_1_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_1_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_1_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_1_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_1_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_1_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_1_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_1_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_1_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_1_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_1_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_1_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_1_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 2);






 wire [1-1:0] pre_bind_dw512_out_2_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_2_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_2_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_2_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_2_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_2_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_2_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_2_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_2_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_2_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_2_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_2_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_2_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 4);






 wire [1-1:0] pre_bind_dw512_out_3_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_3_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_3_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_3_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_3_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_3_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_3_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_3_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_3_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_3_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_3_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 8);






 wire [1-1:0] pre_bind_dw512_out_4_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_4_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_4_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_4_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_4_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_4_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_4_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_4_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_4_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_4_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_4_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_4_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_4_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_4_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 16);






 wire [1-1:0] pre_bind_dw512_out_5_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_5_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_5_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_5_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_5_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_5_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_5_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_5_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_5_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_5_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_5_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_5_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_5_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_5_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 32);






 wire [1-1:0] pre_bind_dw512_out_6_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_6_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_6_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_6_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_6_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_6_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_6_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_6_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_6_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_6_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_6_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_6_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_6_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_6_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 64);






 wire [1-1:0] pre_bind_dw512_out_7_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_7_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_7_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_7_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_7_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_7_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_7_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_7_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_7_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_7_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_7_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_7_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_7_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_7_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 128);






 wire [1-1:0] pre_bind_dw512_out_8_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_8_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_dw512_out_8_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_dw512_out_8_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_8_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_dw512_out_8_ibp_wd_chnl;

 wire [1-1:0] pre_bind_dw512_out_8_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_dw512_out_8_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_dw512_out_8_ibp_rd_chnl;

 wire [1-1:0] pre_bind_dw512_out_8_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_dw512_out_8_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_dw512_out_8_ibp_wrsp_chnl;

wire [1-1:0] pre_bind_dw512_out_8_ibp_cmd_chnl_user;


wire pre_bind_dw512_out_8_ibp_rgon_hit = (mid_ibp_cmd_chnl_rgon == 256);








// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: Dummy signals are indeed no driven
wire mid_ibp_split_indicator_dummy;
// leda NTL_CON13A on
wire [9-1:0] mid_ibp_split_indicator;



// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign {
    mid_ibp_split_indicator_dummy,
    mid_ibp_split_indicator
    } = { 1'b0
       , pre_bind_dw512_out_0_ibp_rgon_hit
       , pre_bind_dw512_out_1_ibp_rgon_hit
       , pre_bind_dw512_out_2_ibp_rgon_hit
       , pre_bind_dw512_out_3_ibp_rgon_hit
       , pre_bind_dw512_out_4_ibp_rgon_hit
       , pre_bind_dw512_out_5_ibp_rgon_hit
       , pre_bind_dw512_out_6_ibp_rgon_hit
       , pre_bind_dw512_out_7_ibp_rgon_hit
       , pre_bind_dw512_out_8_ibp_rgon_hit
        };
// leda NTL_CON16 on

// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: Dummy signals are indeed no driven
wire mid_splt_dummy0;
wire mid_splt_dummy1;
// leda NTL_CON13A on



 wire [9-1:0] mid_splt_ibp_cmd_chnl_valid;
 wire [9-1:0] mid_splt_ibp_cmd_chnl_accept;
 wire [59 * 9 -1:0] mid_splt_ibp_cmd_chnl;

 wire [9-1:0] mid_splt_ibp_wd_chnl_valid;
 wire [9-1:0] mid_splt_ibp_wd_chnl_accept;
 wire [577 * 9 -1:0] mid_splt_ibp_wd_chnl;

 wire [9-1:0] mid_splt_ibp_rd_chnl_accept;
 wire [9-1:0] mid_splt_ibp_rd_chnl_valid;
 wire [515 * 9 -1:0] mid_splt_ibp_rd_chnl;

 wire [9-1:0] mid_splt_ibp_wrsp_chnl_valid;
 wire [9-1:0] mid_splt_ibp_wrsp_chnl_accept;
 wire [3 * 9 -1:0] mid_splt_ibp_wrsp_chnl;

wire [1*9-1:0] mid_splt_ibp_cmd_chnl_user;

mss_bus_switch_ibp_split
  #(
    .ALLOW_DIFF_BRANCH  (0),
    .SPLT_NUM  (9),
    .USER_W  (1),



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
    .SPLT_FIFO_WIDTH  (4),
    .SPLT_FIFO_DEPTH  (64)
  )
u_mid_ibp_splitter(
    .i_ibp_split_indicator  (mid_ibp_split_indicator  ),

    .i_ibp_cmd_chnl_user    (mid_ibp_cmd_chnl_user    ),
    .o_bus_ibp_cmd_chnl_user(mid_splt_ibp_cmd_chnl_user),




    .i_ibp_cmd_chnl_valid  (mid_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (mid_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (mid_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (mid_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (mid_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (mid_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (mid_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (mid_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (mid_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (mid_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(mid_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (mid_ibp_wrsp_chnl),




    .o_bus_ibp_cmd_chnl_valid  (mid_splt_ibp_cmd_chnl_valid),
    .o_bus_ibp_cmd_chnl_accept (mid_splt_ibp_cmd_chnl_accept),
    .o_bus_ibp_cmd_chnl        (mid_splt_ibp_cmd_chnl),

    .o_bus_ibp_rd_chnl_valid   (mid_splt_ibp_rd_chnl_valid),
    .o_bus_ibp_rd_chnl_accept  (mid_splt_ibp_rd_chnl_accept),
    .o_bus_ibp_rd_chnl         (mid_splt_ibp_rd_chnl),

    .o_bus_ibp_wd_chnl_valid   (mid_splt_ibp_wd_chnl_valid),
    .o_bus_ibp_wd_chnl_accept  (mid_splt_ibp_wd_chnl_accept),
    .o_bus_ibp_wd_chnl         (mid_splt_ibp_wd_chnl),

    .o_bus_ibp_wrsp_chnl_valid (mid_splt_ibp_wrsp_chnl_valid),
    .o_bus_ibp_wrsp_chnl_accept(mid_splt_ibp_wrsp_chnl_accept),
    .o_bus_ibp_wrsp_chnl       (mid_splt_ibp_wrsp_chnl),


    .rst_a               (rst_a),
    .clk                 (clk               )
);

// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign
  {
    mid_splt_dummy0
       , pre_bind_dw512_out_0_ibp_cmd_chnl_user
       , pre_bind_dw512_out_1_ibp_cmd_chnl_user
       , pre_bind_dw512_out_2_ibp_cmd_chnl_user
       , pre_bind_dw512_out_3_ibp_cmd_chnl_user
       , pre_bind_dw512_out_4_ibp_cmd_chnl_user
       , pre_bind_dw512_out_5_ibp_cmd_chnl_user
       , pre_bind_dw512_out_6_ibp_cmd_chnl_user
       , pre_bind_dw512_out_7_ibp_cmd_chnl_user
       , pre_bind_dw512_out_8_ibp_cmd_chnl_user
       , pre_bind_dw512_out_0_ibp_cmd_chnl
       , pre_bind_dw512_out_1_ibp_cmd_chnl
       , pre_bind_dw512_out_2_ibp_cmd_chnl
       , pre_bind_dw512_out_3_ibp_cmd_chnl
       , pre_bind_dw512_out_4_ibp_cmd_chnl
       , pre_bind_dw512_out_5_ibp_cmd_chnl
       , pre_bind_dw512_out_6_ibp_cmd_chnl
       , pre_bind_dw512_out_7_ibp_cmd_chnl
       , pre_bind_dw512_out_8_ibp_cmd_chnl
       , pre_bind_dw512_out_0_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_1_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_2_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_3_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_4_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_5_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_6_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_7_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_8_ibp_cmd_chnl_valid
       , pre_bind_dw512_out_0_ibp_wd_chnl
       , pre_bind_dw512_out_1_ibp_wd_chnl
       , pre_bind_dw512_out_2_ibp_wd_chnl
       , pre_bind_dw512_out_3_ibp_wd_chnl
       , pre_bind_dw512_out_4_ibp_wd_chnl
       , pre_bind_dw512_out_5_ibp_wd_chnl
       , pre_bind_dw512_out_6_ibp_wd_chnl
       , pre_bind_dw512_out_7_ibp_wd_chnl
       , pre_bind_dw512_out_8_ibp_wd_chnl
       , pre_bind_dw512_out_0_ibp_wd_chnl_valid
       , pre_bind_dw512_out_1_ibp_wd_chnl_valid
       , pre_bind_dw512_out_2_ibp_wd_chnl_valid
       , pre_bind_dw512_out_3_ibp_wd_chnl_valid
       , pre_bind_dw512_out_4_ibp_wd_chnl_valid
       , pre_bind_dw512_out_5_ibp_wd_chnl_valid
       , pre_bind_dw512_out_6_ibp_wd_chnl_valid
       , pre_bind_dw512_out_7_ibp_wd_chnl_valid
       , pre_bind_dw512_out_8_ibp_wd_chnl_valid
       , pre_bind_dw512_out_0_ibp_rd_chnl_accept
       , pre_bind_dw512_out_1_ibp_rd_chnl_accept
       , pre_bind_dw512_out_2_ibp_rd_chnl_accept
       , pre_bind_dw512_out_3_ibp_rd_chnl_accept
       , pre_bind_dw512_out_4_ibp_rd_chnl_accept
       , pre_bind_dw512_out_5_ibp_rd_chnl_accept
       , pre_bind_dw512_out_6_ibp_rd_chnl_accept
       , pre_bind_dw512_out_7_ibp_rd_chnl_accept
       , pre_bind_dw512_out_8_ibp_rd_chnl_accept
       , pre_bind_dw512_out_0_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_1_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_2_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_3_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_4_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_5_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_6_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_7_ibp_wrsp_chnl_accept
       , pre_bind_dw512_out_8_ibp_wrsp_chnl_accept
  }
  =
    {
    1'b1,
    mid_splt_ibp_cmd_chnl_user,
    mid_splt_ibp_cmd_chnl,
    mid_splt_ibp_cmd_chnl_valid,
    mid_splt_ibp_wd_chnl,
    mid_splt_ibp_wd_chnl_valid,
    mid_splt_ibp_rd_chnl_accept,
    mid_splt_ibp_wrsp_chnl_accept
    } ;
// leda NTL_CON16 on

// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign
  {
    mid_splt_dummy1,
    mid_splt_ibp_rd_chnl,
    mid_splt_ibp_rd_chnl_valid,
    mid_splt_ibp_wrsp_chnl,
    mid_splt_ibp_wrsp_chnl_valid,
    mid_splt_ibp_cmd_chnl_accept,
    mid_splt_ibp_wd_chnl_accept
    }
  =
  {
      1'b1
       , pre_bind_dw512_out_0_ibp_rd_chnl
       , pre_bind_dw512_out_1_ibp_rd_chnl
       , pre_bind_dw512_out_2_ibp_rd_chnl
       , pre_bind_dw512_out_3_ibp_rd_chnl
       , pre_bind_dw512_out_4_ibp_rd_chnl
       , pre_bind_dw512_out_5_ibp_rd_chnl
       , pre_bind_dw512_out_6_ibp_rd_chnl
       , pre_bind_dw512_out_7_ibp_rd_chnl
       , pre_bind_dw512_out_8_ibp_rd_chnl
       , pre_bind_dw512_out_0_ibp_rd_chnl_valid
       , pre_bind_dw512_out_1_ibp_rd_chnl_valid
       , pre_bind_dw512_out_2_ibp_rd_chnl_valid
       , pre_bind_dw512_out_3_ibp_rd_chnl_valid
       , pre_bind_dw512_out_4_ibp_rd_chnl_valid
       , pre_bind_dw512_out_5_ibp_rd_chnl_valid
       , pre_bind_dw512_out_6_ibp_rd_chnl_valid
       , pre_bind_dw512_out_7_ibp_rd_chnl_valid
       , pre_bind_dw512_out_8_ibp_rd_chnl_valid
       , pre_bind_dw512_out_0_ibp_wrsp_chnl
       , pre_bind_dw512_out_1_ibp_wrsp_chnl
       , pre_bind_dw512_out_2_ibp_wrsp_chnl
       , pre_bind_dw512_out_3_ibp_wrsp_chnl
       , pre_bind_dw512_out_4_ibp_wrsp_chnl
       , pre_bind_dw512_out_5_ibp_wrsp_chnl
       , pre_bind_dw512_out_6_ibp_wrsp_chnl
       , pre_bind_dw512_out_7_ibp_wrsp_chnl
       , pre_bind_dw512_out_8_ibp_wrsp_chnl
       , pre_bind_dw512_out_0_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_1_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_2_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_3_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_4_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_5_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_6_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_7_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_8_ibp_wrsp_chnl_valid
       , pre_bind_dw512_out_0_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_1_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_2_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_3_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_4_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_5_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_6_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_7_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_8_ibp_cmd_chnl_accept
       , pre_bind_dw512_out_0_ibp_wd_chnl_accept
       , pre_bind_dw512_out_1_ibp_wd_chnl_accept
       , pre_bind_dw512_out_2_ibp_wd_chnl_accept
       , pre_bind_dw512_out_3_ibp_wd_chnl_accept
       , pre_bind_dw512_out_4_ibp_wd_chnl_accept
       , pre_bind_dw512_out_5_ibp_wd_chnl_accept
       , pre_bind_dw512_out_6_ibp_wd_chnl_accept
       , pre_bind_dw512_out_7_ibp_wd_chnl_accept
       , pre_bind_dw512_out_8_ibp_wd_chnl_accept
  };
// leda NTL_CON16 on




wire pre_bind_buf_dw512_out_0_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_0_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_0_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_0_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_0_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_0_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_0_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_0_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_0_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_0_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_0_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_0_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_0_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_0_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_0_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_0_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_0_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_0_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_0_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_0_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_0_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_0_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_0_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_0_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_0_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_0_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_0_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_0_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_0_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_0_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_0_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_0_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_0_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_0_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_0_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_0_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_0_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_0_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_0_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_0_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_0_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_0_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_0_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_0_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_0_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_0_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_0_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_0_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_0_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_0_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_0_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_0_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_0_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_0_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_0_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_0_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_0_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_0_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_0_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_0_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_0_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_0_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_0_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_1_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_1_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_1_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_1_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_1_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_1_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_1_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_1_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_1_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_1_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_1_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_1_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_1_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_1_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_1_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_1_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_1_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_1_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_1_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_1_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_1_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_1_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_1_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_1_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_1_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_1_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_1_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_1_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_1_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_1_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_1_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_1_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_1_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_1_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_1_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_1_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_1_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_1_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_1_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_1_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_1_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_1_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_1_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_1_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_1_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_1_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_1_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_1_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_1_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_1_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_1_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_1_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_1_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_1_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_1_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_1_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_1_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_1_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_1_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_1_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_1_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_1_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_1_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_2_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_2_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_2_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_2_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_2_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_2_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_2_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_2_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_2_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_2_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_2_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_2_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_2_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_2_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_2_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_2_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_2_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_2_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_2_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_2_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_2_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_2_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_2_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_2_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_2_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_2_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_2_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_2_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_2_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_2_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_2_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_2_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_2_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_2_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_2_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_2_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_2_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_2_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_2_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_2_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_2_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_2_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_2_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_2_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_2_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_2_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_2_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_2_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_2_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_2_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_2_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_2_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_2_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_2_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_2_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_2_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_2_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_2_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_2_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_2_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_2_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_2_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_2_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_3_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_3_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_3_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_3_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_3_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_3_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_3_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_3_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_3_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_3_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_3_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_3_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_3_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_3_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_3_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_3_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_3_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_3_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_3_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_3_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_3_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_3_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_3_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_3_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_3_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_3_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_3_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_3_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_3_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_3_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_3_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_3_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_3_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_3_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_3_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_3_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_3_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_3_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_3_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_3_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_3_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_3_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_3_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_3_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_3_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_3_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_3_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_3_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_3_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_3_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_3_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_3_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_3_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_3_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_3_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_3_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_3_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_3_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_3_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_3_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_3_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_3_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_3_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_4_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_4_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_4_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_4_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_4_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_4_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_4_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_4_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_4_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_4_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_4_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_4_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_4_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_4_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_4_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_4_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_4_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_4_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_4_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_4_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_4_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_4_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_4_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_4_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_4_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_4_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_4_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_4_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_4_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_4_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_4_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_4_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_4_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_4_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_4_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_4_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_4_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_4_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_4_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_4_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_4_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_4_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_4_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_4_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_4_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_4_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_4_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_4_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_4_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_4_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_4_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_4_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_4_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_4_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_4_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_4_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_4_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_4_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_4_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_4_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_4_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_4_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_4_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_4_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_5_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_5_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_5_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_5_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_5_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_5_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_5_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_5_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_5_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_5_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_5_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_5_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_5_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_5_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_5_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_5_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_5_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_5_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_5_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_5_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_5_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_5_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_5_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_5_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_5_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_5_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_5_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_5_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_5_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_5_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_5_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_5_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_5_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_5_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_5_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_5_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_5_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_5_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_5_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_5_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_5_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_5_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_5_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_5_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_5_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_5_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_5_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_5_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_5_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_5_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_5_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_5_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_5_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_5_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_5_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_5_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_5_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_5_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_5_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_5_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_5_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_5_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_5_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_5_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_6_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_6_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_6_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_6_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_6_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_6_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_6_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_6_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_6_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_6_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_6_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_6_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_6_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_6_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_6_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_6_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_6_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_6_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_6_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_6_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_6_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_6_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_6_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_6_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_6_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_6_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_6_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_6_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_6_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_6_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_6_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_6_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_6_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_6_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_6_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_6_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_6_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_6_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_6_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_6_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_6_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_6_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_6_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_6_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_6_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_6_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_6_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_6_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_6_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_6_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_6_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_6_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_6_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_6_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_6_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_6_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_6_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_6_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_6_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_6_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_6_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_6_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_6_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_6_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_7_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_7_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_7_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_7_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_7_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_7_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_7_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_7_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_7_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_7_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_7_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_7_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_7_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_7_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_7_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_7_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_7_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_7_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_7_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_7_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_7_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_7_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_7_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_7_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_7_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_7_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_7_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_7_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_7_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_7_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_7_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_7_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_7_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_7_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_7_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_7_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_7_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_7_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_7_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_7_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_7_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_7_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_7_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_7_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_7_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_7_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_7_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_7_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_7_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_7_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_7_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_7_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_7_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_7_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_7_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_7_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_7_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_7_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_7_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_7_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_7_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_7_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_7_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_7_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );





wire pre_bind_buf_dw512_out_8_ibp_idle;

wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_cmd_chnl_user;



 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_cmd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] pre_bind_buf_dw512_out_8_ibp_cmd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_wd_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] pre_bind_buf_dw512_out_8_ibp_wd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_rd_chnl_accept;
 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] pre_bind_buf_dw512_out_8_ibp_rd_chnl;

 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_wrsp_chnl_valid;
 wire [1-1:0] pre_bind_buf_dw512_out_8_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] pre_bind_buf_dw512_out_8_ibp_wrsp_chnl;


mss_bus_switch_slv_ibp_buffer
  #(
    .I_IBP_SUPPORT_RTIO    (0),
    .O_IBP_SUPPORT_RTIO    (0),
    .CMD_CHNL_FIFO_MWHILE  (0),
    .WDATA_CHNL_FIFO_MWHILE(0),
    .RDATA_CHNL_FIFO_MWHILE(0),
    .WRESP_CHNL_FIFO_MWHILE(0),
    .THROUGH_MODE          (1),
    .CMD_CHNL_FIFO_DEPTH   (0),
    .WDATA_CHNL_FIFO_DEPTH (0),
    .RDATA_CHNL_FIFO_DEPTH (0),
    .WRESP_CHNL_FIFO_DEPTH (0),



    .OUTSTAND_NUM    (64),
    .OUTSTAND_CNT_W  (6),




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

    .USER_W(1),
    .RGON_W(1)
    )
 u_pre_bind_buf_dw512_out_8_ibp_buffer(
    .i_ibp_clk_en   (1'b1),
    .o_ibp_clk_en   (1'b1),
    .ibp_buffer_idle       (pre_bind_buf_dw512_out_8_ibp_idle),




    .i_ibp_cmd_chnl_valid  (pre_bind_dw512_out_8_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_dw512_out_8_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_dw512_out_8_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_dw512_out_8_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_dw512_out_8_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_dw512_out_8_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_dw512_out_8_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_dw512_out_8_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_dw512_out_8_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_dw512_out_8_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_dw512_out_8_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_dw512_out_8_ibp_wrsp_chnl),





    .o_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_8_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_8_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (pre_bind_buf_dw512_out_8_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_8_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_8_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (pre_bind_buf_dw512_out_8_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_8_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_8_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (pre_bind_buf_dw512_out_8_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_8_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_8_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_8_ibp_wrsp_chnl),

    .i_ibp_cmd_chnl_user   (pre_bind_dw512_out_8_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user   (pre_bind_buf_dw512_out_8_ibp_cmd_chnl_user),
    .i_ibp_cmd_chnl_rgon   (1'b0),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_chnl_rgon   (),
// leda B_1011 on
// leda WV951025 on

    .rst_a               (rst_a),
    .clk                 (clk               )
);



wire dw512_out_8_ibp_cwbind_ibp_req;


wire  [1 -1:0]      dw512_out_8_ibp_cmd_chnl_user;

mss_bus_switch_ibp_cwbind
  #(



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
    .USER_W(1),
    .OUT_CMD_CNT_W(6),
    .OUT_CMD_NUM  (64),
    .O_RESP_ALWAYS_ACCEPT (0),
    .ENABLE_CWBIND (0)
    )
u_dw512_out_8_ibp_cwbind
  (
    .i_ibp_cmd_chnl_user  (pre_bind_buf_dw512_out_8_ibp_cmd_chnl_user),
    .o_ibp_cmd_chnl_user  (dw512_out_8_ibp_cmd_chnl_user),



    .i_ibp_cmd_chnl_valid  (pre_bind_buf_dw512_out_8_ibp_cmd_chnl_valid),
    .i_ibp_cmd_chnl_accept (pre_bind_buf_dw512_out_8_ibp_cmd_chnl_accept),
    .i_ibp_cmd_chnl        (pre_bind_buf_dw512_out_8_ibp_cmd_chnl),

    .i_ibp_rd_chnl_valid   (pre_bind_buf_dw512_out_8_ibp_rd_chnl_valid),
    .i_ibp_rd_chnl_accept  (pre_bind_buf_dw512_out_8_ibp_rd_chnl_accept),
    .i_ibp_rd_chnl         (pre_bind_buf_dw512_out_8_ibp_rd_chnl),

    .i_ibp_wd_chnl_valid   (pre_bind_buf_dw512_out_8_ibp_wd_chnl_valid),
    .i_ibp_wd_chnl_accept  (pre_bind_buf_dw512_out_8_ibp_wd_chnl_accept),
    .i_ibp_wd_chnl         (pre_bind_buf_dw512_out_8_ibp_wd_chnl),

    .i_ibp_wrsp_chnl_valid (pre_bind_buf_dw512_out_8_ibp_wrsp_chnl_valid),
    .i_ibp_wrsp_chnl_accept(pre_bind_buf_dw512_out_8_ibp_wrsp_chnl_accept),
    .i_ibp_wrsp_chnl       (pre_bind_buf_dw512_out_8_ibp_wrsp_chnl),




    .o_ibp_cmd_chnl_valid  (dw512_out_8_ibp_cmd_chnl_valid),
    .o_ibp_cmd_chnl_accept (dw512_out_8_ibp_cmd_chnl_accept),
    .o_ibp_cmd_chnl        (dw512_out_8_ibp_cmd_chnl),

    .o_ibp_rd_chnl_valid   (dw512_out_8_ibp_rd_chnl_valid),
    .o_ibp_rd_chnl_accept  (dw512_out_8_ibp_rd_chnl_accept),
    .o_ibp_rd_chnl         (dw512_out_8_ibp_rd_chnl),

    .o_ibp_wd_chnl_valid   (dw512_out_8_ibp_wd_chnl_valid),
    .o_ibp_wd_chnl_accept  (dw512_out_8_ibp_wd_chnl_accept),
    .o_ibp_wd_chnl         (dw512_out_8_ibp_wd_chnl),

    .o_ibp_wrsp_chnl_valid (dw512_out_8_ibp_wrsp_chnl_valid),
    .o_ibp_wrsp_chnl_accept(dw512_out_8_ibp_wrsp_chnl_accept),
    .o_ibp_wrsp_chnl       (dw512_out_8_ibp_wrsp_chnl),

    .i_ibp_clk_en_req  (dw512_out_8_ibp_cwbind_ibp_req),
    .clk               (clk                           ),
    .rst_a             (rst_a)
   );










// leda G_521_2_B on
endmodule // mss_bus_switch_dw512_slv




