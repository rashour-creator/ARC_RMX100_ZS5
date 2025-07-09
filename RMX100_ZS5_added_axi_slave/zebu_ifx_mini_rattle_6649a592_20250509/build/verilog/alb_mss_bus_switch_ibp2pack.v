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
//  ###   ######  ######   #####  ######     #     #####  #    #
//   #    #     # #     # #     # #     #   # #   #     # #   #
//   #    #     # #     #       # #     #  #   #  #       #  #
//   #    ######  ######   #####  ######  #     # #       ###
//   #    #     # #       #       #       ####### #       #  #
//   #    #     # #       #       #       #     # #     # #   #
//  ###   ######  #       ####### #       #     #  #####  #    #
//
//
// ===========================================================================
//
// Description:
//  Verilog module to convert the IBP to Pack
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"


module mss_bus_switch_ibp2pack
  #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32,
    parameter USER_W = 7,
    parameter RGON_W = 7,
    parameter CMD_CHNL_READ           = 0     ,
    parameter CMD_CHNL_WRAP           = 1     ,
    parameter CMD_CHNL_DATA_SIZE_LSB  = 2     ,
    parameter CMD_CHNL_DATA_SIZE_W    = 3     ,
    parameter CMD_CHNL_BURST_SIZE_LSB = 5     ,
    parameter CMD_CHNL_BURST_SIZE_W   = 4     ,
    parameter CMD_CHNL_PROT_LSB       = 9     ,
    parameter CMD_CHNL_PROT_W         = 2     ,
    parameter CMD_CHNL_CACHE_LSB      = 11    ,
    parameter CMD_CHNL_CACHE_W        = 4     ,
    parameter CMD_CHNL_LOCK           = 15    ,
    parameter CMD_CHNL_EXCL           = 16    ,
    parameter CMD_CHNL_ADDR_LSB       = 24    ,
    parameter CMD_CHNL_ADDR_W         = 32    ,
    parameter CMD_CHNL_W              = 57    ,

    parameter WD_CHNL_LAST            = 0     ,
    parameter WD_CHNL_DATA_LSB        = 1     ,
    parameter WD_CHNL_DATA_W          = 32    ,
    parameter WD_CHNL_MASK_LSB        = 33    ,
    parameter WD_CHNL_MASK_W          = 4     ,
    parameter WD_CHNL_W               = 37    ,

    parameter RD_CHNL_ERR_RD          = 0     ,
    parameter RD_CHNL_RD_LAST         = 1     ,
    parameter RD_CHNL_RD_EXCL_OK      = 2     ,
    parameter RD_CHNL_RD_DATA_LSB     = 3     ,
    parameter RD_CHNL_RD_DATA_W       = 32    ,
    parameter RD_CHNL_W               = 35    ,

    parameter WRSP_CHNL_WR_DONE       = 0     ,
    parameter WRSP_CHNL_WR_EXCL_DONE  = 1     ,
    parameter WRSP_CHNL_ERR_WR        = 2     ,
    parameter WRSP_CHNL_W             = 3
    )
  (
  // The "ibp_xxx" bus is the one IBP to be packed
  //
  // command channel
  // This module Do not support the id and snoop
  input  ibp_cmd_valid,
  output ibp_cmd_accept,
  input  ibp_cmd_read,
  input  [ADDR_W-1:0] ibp_cmd_addr,
  input  ibp_cmd_wrap,
  input  [CMD_CHNL_DATA_SIZE_W-1:0] ibp_cmd_data_size,
  input  [CMD_CHNL_BURST_SIZE_W-1:0] ibp_cmd_burst_size,
  input  ibp_cmd_lock,
  input  ibp_cmd_excl,
  input  [CMD_CHNL_PROT_W-1:0] ibp_cmd_prot,
  input  [CMD_CHNL_CACHE_W-1:0] ibp_cmd_cache,

  input  [RGON_W-1:0] ibp_cmd_rgon,
  input  [USER_W-1:0] ibp_cmd_user,
  //
  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  output ibp_rd_valid,
  output ibp_rd_excl_ok,
  input  ibp_rd_accept,
  output [DATA_W-1:0] ibp_rd_data,
  output ibp_rd_last,
  output ibp_err_rd,
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


  // The "ibp_chnl_xxx" bus is the one after packed
  //
  output  [RGON_W-1:0] ibp_cmd_chnl_rgon,
  output  [USER_W-1:0] ibp_cmd_chnl_user,

  output [CMD_CHNL_W -1:0] ibp_cmd_chnl,
  input  [RD_CHNL_W  -1:0] ibp_rd_chnl,
  output [WD_CHNL_W  -1:0] ibp_wd_chnl,
  input  [WRSP_CHNL_W-1:0] ibp_wrsp_chnl,
  output ibp_cmd_chnl_valid,
  input  ibp_rd_chnl_valid,
  output ibp_wd_chnl_valid,
  input  ibp_wrsp_chnl_valid,
  input  ibp_cmd_chnl_accept,
  output ibp_rd_chnl_accept,
  input  ibp_wd_chnl_accept,
  output ibp_wrsp_chnl_accept,

// leda NTL_CON13C off
// LMD: non driving internal net
// LJ: The clk is only used for assertion
  input clk,
  input rst_a
// leda NTL_CON13C on
  );

// the following wire definitions are VTOC code generation bug work arounds
wire [RD_CHNL_W  -1:0] ibp_rd_chnl_masked   = (ibp_rd_chnl_valid   == 1'b1) ? ibp_rd_chnl   : {RD_CHNL_W{1'b0}};
wire [WRSP_CHNL_W-1:0] ibp_wrsp_chnl_masked = (ibp_wrsp_chnl_valid == 1'b1) ? ibp_wrsp_chnl : {WRSP_CHNL_W{1'b0}};

// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign ibp_cmd_chnl_valid                                                                       = ibp_cmd_valid;
assign ibp_cmd_accept                                                                           = ibp_cmd_chnl_accept;
assign ibp_cmd_chnl = { ibp_cmd_addr,
                        ibp_cmd_excl,
                        ibp_cmd_lock,
                        ibp_cmd_cache,
                        ibp_cmd_prot,
                        ibp_cmd_burst_size,
                        ibp_cmd_data_size,
                        ibp_cmd_wrap,
                        ibp_cmd_read };

assign ibp_wd_chnl_valid                                                                        = ibp_wr_valid;
assign ibp_wr_accept                                                                            = ibp_wd_chnl_accept;
assign ibp_wd_chnl = { ibp_wr_mask,
                       ibp_wr_data,
                       ibp_wr_last };

assign ibp_rd_chnl_accept                                                                       = ibp_rd_accept;
assign ibp_rd_valid                                                                             = ibp_rd_chnl_valid & (~ibp_rd_chnl[RD_CHNL_ERR_RD      ]);
assign ibp_rd_excl_ok                                                                           = ibp_rd_chnl_masked[RD_CHNL_RD_EXCL_OK    ];
assign ibp_err_rd                                                                               = ibp_rd_chnl_masked[RD_CHNL_ERR_RD      ];
assign ibp_rd_last                                                                              = ibp_rd_chnl_masked[RD_CHNL_RD_LAST     ];
assign ibp_rd_data                                                                              = ibp_rd_chnl_masked[RD_CHNL_RD_DATA_W+RD_CHNL_RD_DATA_LSB-1:RD_CHNL_RD_DATA_LSB];

assign ibp_wrsp_chnl_accept                                                                     = ibp_wr_resp_accept;
assign ibp_wr_done                                                                              = ibp_wrsp_chnl_masked[WRSP_CHNL_WR_DONE     ];
assign ibp_wr_excl_done                                                                         = ibp_wrsp_chnl_masked[WRSP_CHNL_WR_EXCL_DONE];
assign ibp_err_wr                                                                               = ibp_wrsp_chnl_masked[WRSP_CHNL_ERR_WR      ];

assign ibp_cmd_chnl_rgon                                                                        = ibp_cmd_rgon;
assign ibp_cmd_chnl_user                                                                        = ibp_cmd_user;

// leda NTL_CON16 on


endmodule // mss_bus_switch_ibp2pack
