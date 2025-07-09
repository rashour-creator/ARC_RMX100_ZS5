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
//  ######     #     #####  #    #   #####    ###   ######  ######
//  #     #   # #   #     # #   #   #     #    #    #     # #     #
//  #     #  #   #  #       #  #          #    #    #     # #     #
//  ######  #     # #       ###      #####     #    ######  ######
//  #       ####### #       #  #    #          #    #     # #
//  #       #     # #     # #   #   #          #    #     # #
//  #       #     #  #####  #    #  #######   ###   ######  #
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

module alb_mss_fab_pack2ibp
  #(
// leda W175 off
// LMD: A parameter XXX has been defined but is not used
// LJ: We always list out all IBP relevant defines although not used
    parameter ADDR_W = 32,
    parameter DATA_W = 32,
    parameter RGON_W = 7,
    parameter USER_W = 7,
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
    parameter CMD_CHNL_RGON_LSB     = 17    ,
    parameter CMD_CHNL_RGON_W       = 7     ,
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
// leda W175 on
    )
  (
  // The "ibp_xxx" bus is the one IBP after unpacked
  //
  // command channel
  // This module Do not support the id and snoop
  output ibp_cmd_valid,
  input  ibp_cmd_accept,
  output ibp_cmd_read,
  output [ADDR_W-1:0] ibp_cmd_addr,
  output ibp_cmd_wrap,
  output [CMD_CHNL_DATA_SIZE_W-1:0] ibp_cmd_data_size,
  output [CMD_CHNL_BURST_SIZE_W-1:0] ibp_cmd_burst_size,
  output ibp_cmd_lock,
  output ibp_cmd_excl,
  output [CMD_CHNL_PROT_W-1:0] ibp_cmd_prot,
  output [CMD_CHNL_CACHE_W-1:0] ibp_cmd_cache,

  output [RGON_W-1:0] ibp_cmd_rgon,
  output [USER_W-1:0] ibp_cmd_user,
  //
  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  input  ibp_rd_valid,
  output ibp_rd_accept,
  input  [DATA_W-1:0] ibp_rd_data,
  input  ibp_rd_last,
  input  ibp_err_rd,
  input  ibp_rd_excl_ok,
  //
  // write data channel
  output ibp_wr_valid,
  input  ibp_wr_accept,
  output [DATA_W-1:0] ibp_wr_data,
  output [(DATA_W/8)-1:0] ibp_wr_mask,
  output ibp_wr_last,
  //
  // write response channel
  // This module do not support id
  input  ibp_wr_done,
  input  ibp_wr_excl_done,
  input  ibp_err_wr,
  output ibp_wr_resp_accept,


  // The "ibp_chnl_xxx" bus is the one to be unpacked
  //
  input  [RGON_W-1:0] ibp_cmd_chnl_rgon,
  input  [USER_W-1:0] ibp_cmd_chnl_user,

  input  [CMD_CHNL_W -1:0] ibp_cmd_chnl,
  output [RD_CHNL_W  -1:0] ibp_rd_chnl,
  input  [WD_CHNL_W  -1:0] ibp_wd_chnl,
  output [WRSP_CHNL_W-1:0] ibp_wrsp_chnl,
  input  ibp_cmd_chnl_valid,
  output ibp_rd_chnl_valid,
  input  ibp_wd_chnl_valid,
  output ibp_wrsp_chnl_valid,
  output ibp_cmd_chnl_accept,
  input  ibp_rd_chnl_accept,
  output ibp_wd_chnl_accept,
  input  ibp_wrsp_chnl_accept
  );


// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign ibp_cmd_valid                                                             = ibp_cmd_chnl_valid                                                                       ;
assign ibp_cmd_chnl_accept                                                       = ibp_cmd_accept                                                                           ;
assign ibp_cmd_read                                                              = ibp_cmd_chnl[CMD_CHNL_READ      ]                                                        ;
assign ibp_cmd_wrap                                                              = ibp_cmd_chnl[CMD_CHNL_WRAP      ]                                                        ;
assign ibp_cmd_addr                                                              = ibp_cmd_chnl[CMD_CHNL_ADDR_W      +CMD_CHNL_ADDR_LSB      -1 : CMD_CHNL_ADDR_LSB      ]  ;
assign ibp_cmd_data_size                                                         = ibp_cmd_chnl[CMD_CHNL_DATA_SIZE_W +CMD_CHNL_DATA_SIZE_LSB -1 : CMD_CHNL_DATA_SIZE_LSB ]  ;
assign ibp_cmd_burst_size                                                        = ibp_cmd_chnl[CMD_CHNL_BURST_SIZE_W+CMD_CHNL_BURST_SIZE_LSB-1 : CMD_CHNL_BURST_SIZE_LSB]  ;
assign ibp_cmd_prot                                                              = ibp_cmd_chnl[CMD_CHNL_PROT_W+CMD_CHNL_PROT_LSB-1 : CMD_CHNL_PROT_LSB]                    ;
assign ibp_cmd_cache                                                             = ibp_cmd_chnl[CMD_CHNL_CACHE_W+CMD_CHNL_CACHE_LSB-1 : CMD_CHNL_CACHE_LSB]                 ;
assign ibp_cmd_lock                                                              = ibp_cmd_chnl[CMD_CHNL_LOCK      ]                                                        ;
assign ibp_cmd_excl                                                              = ibp_cmd_chnl[CMD_CHNL_EXCL      ]                                                        ;

assign ibp_wr_valid                                                              = ibp_wd_chnl_valid                                                                        ;
assign ibp_wd_chnl_accept                                                        = ibp_wr_accept                                                                            ;
assign ibp_wr_data                                                               = ibp_wd_chnl[WD_CHNL_DATA_W+WD_CHNL_DATA_LSB-1 : WD_CHNL_DATA_LSB]                        ;
assign ibp_wr_mask                                                               = ibp_wd_chnl[WD_CHNL_MASK_W+WD_CHNL_MASK_LSB-1 : WD_CHNL_MASK_LSB]                        ;
assign ibp_wr_last                                                               = ibp_wd_chnl[WD_CHNL_LAST       ]                                                         ;

assign ibp_rd_accept                                                             = ibp_rd_chnl_accept                                                                       ;
assign ibp_rd_chnl_valid                                                         = ibp_rd_valid   | ibp_err_rd                                                              ;
assign ibp_rd_chnl = {ibp_rd_data, ibp_rd_excl_ok, ibp_rd_last, ibp_err_rd}                                                                                                 ;

assign ibp_wr_resp_accept                                                        = ibp_wrsp_chnl_accept                                                                     ;
assign ibp_wrsp_chnl_valid                                                       = ibp_wr_done | ibp_wr_excl_done | ibp_err_wr                                              ;
assign ibp_wrsp_chnl = {ibp_err_wr, ibp_wr_excl_done, ibp_wr_done}                                                                                                          ;

assign ibp_cmd_rgon  = ibp_cmd_chnl_rgon;
assign ibp_cmd_user  = ibp_cmd_chnl_user;
// leda NTL_CON16 on

endmodule // alb_mss_fab_pack2ibp
