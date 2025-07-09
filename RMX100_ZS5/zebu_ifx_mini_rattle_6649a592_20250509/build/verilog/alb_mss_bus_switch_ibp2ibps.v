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
//  ###   ######  ######   #####   #####    ###   #     #  #####  #       #######
//   #    #     # #     # #     # #     #    #    ##    # #     # #       #
//   #    #     # #     #       # #          #    # #   # #       #       #
//   #    ######  ######   #####   #####     #    #  #  # #  #### #       #####
//   #    #     # #       #             #    #    #   # # #     # #       #
//   #    #     # #       #       #     #    #    #    ## #     # #       #
//  ###   ######  #       #######  #####    ###   #     #  #####  ####### #######
//
// ===========================================================================
//
// Description:
//  Verilog module to convert the IBP to single-beat IBP
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"


module mss_bus_switch_ibp2ibps
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
    parameter SPLT_FIFO_DEPTH = 4,

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

  input  clk,  // clock signal
  input  rst_a, // reset signal

  // The "i_xxx" bus is the one IBP in
  //
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

  input  [RGON_W-1:0] i_ibp_cmd_chnl_rgon,
  input  [USER_W-1:0] i_ibp_cmd_chnl_user,
  // The "o_xxx" bus is the one IBP out
  //
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

  output [RGON_W-1:0] o_ibp_cmd_chnl_rgon,
  output [USER_W-1:0] o_ibp_cmd_chnl_user
  );

wire i_ibp_cmd_valid ;
wire i_ibp_cmd_accept;
wire i_ibp_cmd_read;
wire [ADDR_W-1:0] i_ibp_cmd_addr;
wire i_ibp_cmd_wrap;
wire [CMD_CHNL_DATA_SIZE_W-1:0] i_ibp_cmd_data_size;
wire [CMD_CHNL_BURST_SIZE_W-1:0] i_ibp_cmd_burst_size;
wire i_ibp_cmd_lock;
wire i_ibp_cmd_excl;
wire [CMD_CHNL_PROT_W-1:0] i_ibp_cmd_prot;
wire [CMD_CHNL_CACHE_W-1:0] i_ibp_cmd_cache;

wire [RGON_W-1:0] i_ibp_cmd_rgon;
wire [USER_W-1:0] i_ibp_cmd_user;

wire i_ibp_rd_valid;
wire i_ibp_rd_accept;
wire [DATA_W-1:0] i_ibp_rd_data;
wire i_ibp_rd_last;
wire i_ibp_err_rd;
wire i_ibp_rd_excl_ok;

  // write data channel
wire i_ibp_wr_valid;
wire i_ibp_wr_accept;
wire [DATA_W-1:0] i_ibp_wr_data;
wire [(DATA_W/8)-1:0] i_ibp_wr_mask;
wire i_ibp_wr_last;

  // write response channel
  // This module do not support id
wire i_ibp_wr_done;
wire i_ibp_wr_excl_done;
wire i_ibp_err_wr;
wire i_ibp_wr_resp_accept;

  // command channel
  // This module Do not support the id and snoop
wire o_ibp_cmd_valid;
wire o_ibp_cmd_accept;
wire o_ibp_cmd_read;
wire [ADDR_W-1:0] o_ibp_cmd_addr;
wire o_ibp_cmd_wrap;
wire [CMD_CHNL_DATA_SIZE_W-1:0] o_ibp_cmd_data_size;
wire [CMD_CHNL_BURST_SIZE_W-1:0] o_ibp_cmd_burst_size;
wire o_ibp_cmd_lock;
wire o_ibp_cmd_excl;
wire [CMD_CHNL_PROT_W-1:0] o_ibp_cmd_prot;
wire [CMD_CHNL_CACHE_W-1:0] o_ibp_cmd_cache;

wire [RGON_W-1:0] o_ibp_cmd_rgon;
wire [USER_W-1:0] o_ibp_cmd_user;
  //
  // read data channel
  // This module do not support id; snoop rd_resp, rd_ack and rd_abort
wire o_ibp_rd_valid;
wire o_ibp_rd_accept;
wire [DATA_W-1:0] o_ibp_rd_data;
wire o_ibp_rd_last;
wire o_ibp_err_rd;
wire o_ibp_rd_excl_ok;
  //
  // write data channel
wire o_ibp_wr_valid;
wire o_ibp_wr_accept;
wire [DATA_W-1:0] o_ibp_wr_data;
wire [(DATA_W/8)-1:0] o_ibp_wr_mask;
wire o_ibp_wr_last;
  //
  // write response channel
  // This module do not support id
wire o_ibp_wr_done;
wire o_ibp_wr_excl_done;
wire o_ibp_err_wr;
wire o_ibp_wr_resp_accept;

mss_bus_switch_pack2ibp
  #(
    .ADDR_W (ADDR_W),
    .DATA_W (DATA_W),
    .RGON_W (RGON_W),
    .USER_W (USER_W),
    .CMD_CHNL_READ           (CMD_CHNL_READ           ),
    .CMD_CHNL_WRAP           (CMD_CHNL_WRAP           ),
    .CMD_CHNL_DATA_SIZE_LSB  (CMD_CHNL_DATA_SIZE_LSB  ),
    .CMD_CHNL_DATA_SIZE_W    (CMD_CHNL_DATA_SIZE_W    ),
    .CMD_CHNL_BURST_SIZE_LSB (CMD_CHNL_BURST_SIZE_LSB ),
    .CMD_CHNL_BURST_SIZE_W   (CMD_CHNL_BURST_SIZE_W   ),
    .CMD_CHNL_PROT_LSB       (CMD_CHNL_PROT_LSB       ),
    .CMD_CHNL_PROT_W         (CMD_CHNL_PROT_W         ),
    .CMD_CHNL_CACHE_LSB      (CMD_CHNL_CACHE_LSB      ),
    .CMD_CHNL_CACHE_W        (CMD_CHNL_CACHE_W        ),
    .CMD_CHNL_LOCK           (CMD_CHNL_LOCK           ),
    .CMD_CHNL_EXCL           (CMD_CHNL_EXCL           ),
    .CMD_CHNL_ADDR_LSB       (CMD_CHNL_ADDR_LSB       ),
    .CMD_CHNL_ADDR_W         (CMD_CHNL_ADDR_W         ),
    .CMD_CHNL_W              (CMD_CHNL_W              ),

    .WD_CHNL_LAST            (WD_CHNL_LAST            ),
    .WD_CHNL_DATA_LSB        (WD_CHNL_DATA_LSB        ),
    .WD_CHNL_DATA_W          (WD_CHNL_DATA_W          ),
    .WD_CHNL_MASK_LSB        (WD_CHNL_MASK_LSB        ),
    .WD_CHNL_MASK_W          (WD_CHNL_MASK_W          ),
    .WD_CHNL_W               (WD_CHNL_W               ),

    .RD_CHNL_ERR_RD          (RD_CHNL_ERR_RD          ),
    .RD_CHNL_RD_EXCL_OK      (RD_CHNL_RD_EXCL_OK      ),
    .RD_CHNL_RD_LAST         (RD_CHNL_RD_LAST         ),
    .RD_CHNL_RD_DATA_LSB     (RD_CHNL_RD_DATA_LSB     ),
    .RD_CHNL_RD_DATA_W       (RD_CHNL_RD_DATA_W       ),
    .RD_CHNL_W               (RD_CHNL_W               ),

    .WRSP_CHNL_WR_DONE       (WRSP_CHNL_WR_DONE       ),
    .WRSP_CHNL_WR_EXCL_DONE  (WRSP_CHNL_WR_EXCL_DONE  ),
    .WRSP_CHNL_ERR_WR        (WRSP_CHNL_ERR_WR        ),
    .WRSP_CHNL_W             (WRSP_CHNL_W             )
    )
u_ibp2ibps_pack2ibp
  (
    .ibp_cmd_rgon              (i_ibp_cmd_rgon),
    .ibp_cmd_user              (i_ibp_cmd_user),

    .ibp_cmd_valid             (i_ibp_cmd_valid),
    .ibp_cmd_accept            (i_ibp_cmd_accept),
    .ibp_cmd_read              (i_ibp_cmd_read),
    .ibp_cmd_addr              (i_ibp_cmd_addr),
    .ibp_cmd_wrap              (i_ibp_cmd_wrap),
    .ibp_cmd_data_size         (i_ibp_cmd_data_size),
    .ibp_cmd_burst_size        (i_ibp_cmd_burst_size),
    .ibp_cmd_prot              (i_ibp_cmd_prot),
    .ibp_cmd_cache             (i_ibp_cmd_cache),
    .ibp_cmd_lock              (i_ibp_cmd_lock),
    .ibp_cmd_excl              (i_ibp_cmd_excl),

    .ibp_rd_valid              (i_ibp_rd_valid),
    .ibp_rd_accept             (i_ibp_rd_accept),
    .ibp_err_rd                (i_ibp_err_rd),
    .ibp_rd_data               (i_ibp_rd_data),
    .ibp_rd_excl_ok            (i_ibp_rd_excl_ok),
    .ibp_rd_last               (i_ibp_rd_last),

    .ibp_wr_valid              (i_ibp_wr_valid),
    .ibp_wr_accept             (i_ibp_wr_accept),
    .ibp_wr_data               (i_ibp_wr_data),
    .ibp_wr_mask               (i_ibp_wr_mask),
    .ibp_wr_last               (i_ibp_wr_last),

    .ibp_wr_done               (i_ibp_wr_done),
    .ibp_wr_resp_accept        (i_ibp_wr_resp_accept),
    .ibp_wr_excl_done          (i_ibp_wr_excl_done),
    .ibp_err_wr                (i_ibp_err_wr),


    .ibp_cmd_chnl_rgon         (i_ibp_cmd_chnl_rgon),
    .ibp_cmd_chnl_user         (i_ibp_cmd_chnl_user),

    .ibp_cmd_chnl              (i_ibp_cmd_chnl),
    .ibp_rd_chnl               (i_ibp_rd_chnl),
    .ibp_wd_chnl               (i_ibp_wd_chnl),
    .ibp_wrsp_chnl             (i_ibp_wrsp_chnl),
    .ibp_cmd_chnl_valid        (i_ibp_cmd_chnl_valid),
    .ibp_rd_chnl_valid         (i_ibp_rd_chnl_valid),
    .ibp_wd_chnl_valid         (i_ibp_wd_chnl_valid),
    .ibp_wrsp_chnl_valid       (i_ibp_wrsp_chnl_valid),
    .ibp_cmd_chnl_accept       (i_ibp_cmd_chnl_accept),
    .ibp_rd_chnl_accept        (i_ibp_rd_chnl_accept),
    .ibp_wd_chnl_accept        (i_ibp_wd_chnl_accept),
    .ibp_wrsp_chnl_accept      (i_ibp_wrsp_chnl_accept)
   );

mss_bus_switch_ibp2single
  #(
    .ADDR_W                (ADDR_W ),
    .DATA_W                (DATA_W ),
    .RGON_W                (RGON_W         ),
    .USER_W                (USER_W         ),
    .CUT_IN2OUT_WR_ACPT    (CUT_IN2OUT_WR_ACPT),
    .SPLT_FIFO_DEPTH       (SPLT_FIFO_DEPTH)
    ) u_ibp2single
  (
    .clk          (clk),
    .rst_a        (rst_a),

    .i_ibp_cmd_valid      ( i_ibp_cmd_valid     ),
    .i_ibp_cmd_accept     ( i_ibp_cmd_accept    ),
    .i_ibp_cmd_read       ( i_ibp_cmd_read      ),
    .i_ibp_cmd_addr       ( i_ibp_cmd_addr      ),
    .i_ibp_cmd_wrap       ( i_ibp_cmd_wrap      ),
    .i_ibp_cmd_data_size  ( i_ibp_cmd_data_size ),
    .i_ibp_cmd_burst_size ( i_ibp_cmd_burst_size),
    .i_ibp_cmd_lock       ( i_ibp_cmd_lock      ),
    .i_ibp_cmd_prot       ( i_ibp_cmd_prot      ),
    .i_ibp_cmd_cache      ( i_ibp_cmd_cache     ),
    .i_ibp_cmd_excl       ( i_ibp_cmd_excl      ),

    .i_ibp_rd_valid       ( i_ibp_rd_valid  ),
    .i_ibp_rd_accept      ( i_ibp_rd_accept ),
    .i_ibp_rd_data        ( i_ibp_rd_data   ),
    .i_ibp_rd_last        ( i_ibp_rd_last   ),
    .i_ibp_err_rd         ( i_ibp_err_rd    ),
    .i_ibp_rd_excl_ok     ( i_ibp_rd_excl_ok),

    .i_ibp_wr_valid       ( i_ibp_wr_valid  ),
    .i_ibp_wr_accept      ( i_ibp_wr_accept ),
    .i_ibp_wr_data        ( i_ibp_wr_data   ),
    .i_ibp_wr_mask        ( i_ibp_wr_mask   ),
    .i_ibp_wr_last        ( i_ibp_wr_last   ),

    .i_ibp_wr_done        ( i_ibp_wr_done       ),
    .i_ibp_err_wr         ( i_ibp_err_wr        ),
    .i_ibp_wr_resp_accept ( i_ibp_wr_resp_accept),
    .i_ibp_wr_excl_done   ( i_ibp_wr_excl_done  ),

    .i_ibp_cmd_rgon       ( i_ibp_cmd_rgon),
    .i_ibp_cmd_user       ( i_ibp_cmd_user),

    .o_ibp_cmd_valid      ( o_ibp_cmd_valid     ),
    .o_ibp_cmd_accept     ( o_ibp_cmd_accept    ),
    .o_ibp_cmd_read       ( o_ibp_cmd_read      ),
    .o_ibp_cmd_addr       ( o_ibp_cmd_addr      ),
    .o_ibp_cmd_wrap       ( o_ibp_cmd_wrap      ),
    .o_ibp_cmd_data_size  ( o_ibp_cmd_data_size ),
    .o_ibp_cmd_burst_size ( o_ibp_cmd_burst_size),
    .o_ibp_cmd_lock       ( o_ibp_cmd_lock      ),
    .o_ibp_cmd_prot       ( o_ibp_cmd_prot      ),
    .o_ibp_cmd_cache      ( o_ibp_cmd_cache     ),
    .o_ibp_cmd_excl       ( o_ibp_cmd_excl      ),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_burst_en   (),
    .o_ibp_cmd_burst_type (),
    .o_ibp_cmd_burst_last (),
// leda B_1011 on
// leda WV951025 on

    .o_ibp_rd_valid       ( o_ibp_rd_valid  ),
    .o_ibp_rd_accept      ( o_ibp_rd_accept ),
    .o_ibp_rd_data        ( o_ibp_rd_data   ),
    .o_ibp_rd_last        ( o_ibp_rd_last   ),
    .o_ibp_err_rd         ( o_ibp_err_rd    ),
    .o_ibp_rd_excl_ok     ( o_ibp_rd_excl_ok),

    .o_ibp_wr_valid       ( o_ibp_wr_valid  ),
    .o_ibp_wr_accept      ( o_ibp_wr_accept ),
    .o_ibp_wr_data        ( o_ibp_wr_data   ),
    .o_ibp_wr_mask        ( o_ibp_wr_mask   ),
    .o_ibp_wr_last        ( o_ibp_wr_last   ),

    .o_ibp_wr_done        ( o_ibp_wr_done       ),
    .o_ibp_err_wr         ( o_ibp_err_wr        ),
    .o_ibp_wr_resp_accept ( o_ibp_wr_resp_accept),
    .o_ibp_wr_excl_done   ( o_ibp_wr_excl_done  ),

    .o_ibp_cmd_rgon       ( o_ibp_cmd_rgon),
    .o_ibp_cmd_user       ( o_ibp_cmd_user)
    );


mss_bus_switch_ibp2pack
  #(
    .ADDR_W (ADDR_W),
    .DATA_W (DATA_W),
    .RGON_W (RGON_W),
    .USER_W (USER_W),
    .CMD_CHNL_READ           (CMD_CHNL_READ           ),
    .CMD_CHNL_WRAP           (CMD_CHNL_WRAP           ),
    .CMD_CHNL_DATA_SIZE_LSB  (CMD_CHNL_DATA_SIZE_LSB  ),
    .CMD_CHNL_DATA_SIZE_W    (CMD_CHNL_DATA_SIZE_W    ),
    .CMD_CHNL_BURST_SIZE_LSB (CMD_CHNL_BURST_SIZE_LSB ),
    .CMD_CHNL_BURST_SIZE_W   (CMD_CHNL_BURST_SIZE_W   ),
    .CMD_CHNL_PROT_LSB       (CMD_CHNL_PROT_LSB       ),
    .CMD_CHNL_PROT_W         (CMD_CHNL_PROT_W         ),
    .CMD_CHNL_CACHE_LSB      (CMD_CHNL_CACHE_LSB      ),
    .CMD_CHNL_CACHE_W        (CMD_CHNL_CACHE_W        ),
    .CMD_CHNL_LOCK           (CMD_CHNL_LOCK           ),
    .CMD_CHNL_EXCL           (CMD_CHNL_EXCL           ),
    .CMD_CHNL_ADDR_LSB       (CMD_CHNL_ADDR_LSB       ),
    .CMD_CHNL_ADDR_W         (CMD_CHNL_ADDR_W         ),
    .CMD_CHNL_W              (CMD_CHNL_W              ),

    .WD_CHNL_LAST            (WD_CHNL_LAST            ),
    .WD_CHNL_DATA_LSB        (WD_CHNL_DATA_LSB        ),
    .WD_CHNL_DATA_W          (WD_CHNL_DATA_W          ),
    .WD_CHNL_MASK_LSB        (WD_CHNL_MASK_LSB        ),
    .WD_CHNL_MASK_W          (WD_CHNL_MASK_W          ),
    .WD_CHNL_W               (WD_CHNL_W               ),

    .RD_CHNL_ERR_RD          (RD_CHNL_ERR_RD          ),
    .RD_CHNL_RD_EXCL_OK      (RD_CHNL_RD_EXCL_OK      ),
    .RD_CHNL_RD_LAST         (RD_CHNL_RD_LAST         ),
    .RD_CHNL_RD_DATA_LSB     (RD_CHNL_RD_DATA_LSB     ),
    .RD_CHNL_RD_DATA_W       (RD_CHNL_RD_DATA_W       ),
    .RD_CHNL_W               (RD_CHNL_W               ),

    .WRSP_CHNL_WR_DONE       (WRSP_CHNL_WR_DONE       ),
    .WRSP_CHNL_WR_EXCL_DONE  (WRSP_CHNL_WR_EXCL_DONE  ),
    .WRSP_CHNL_ERR_WR        (WRSP_CHNL_ERR_WR        ),
    .WRSP_CHNL_W             (WRSP_CHNL_W             )
    )
u_ibp2ibps_ibp2pack
  (
    .clk          (clk),
    .rst_a        (rst_a),
    .ibp_cmd_rgon              (o_ibp_cmd_rgon),
    .ibp_cmd_user              (o_ibp_cmd_user),

    .ibp_cmd_valid             (o_ibp_cmd_valid),
    .ibp_cmd_accept            (o_ibp_cmd_accept),
    .ibp_cmd_read              (o_ibp_cmd_read),
    .ibp_cmd_addr              (o_ibp_cmd_addr),
    .ibp_cmd_wrap              (o_ibp_cmd_wrap),
    .ibp_cmd_data_size         (o_ibp_cmd_data_size),
    .ibp_cmd_burst_size        (o_ibp_cmd_burst_size),
    .ibp_cmd_prot              (o_ibp_cmd_prot),
    .ibp_cmd_cache             (o_ibp_cmd_cache),
    .ibp_cmd_lock              (o_ibp_cmd_lock),
    .ibp_cmd_excl              (o_ibp_cmd_excl),

    .ibp_rd_valid              (o_ibp_rd_valid),
    .ibp_rd_accept             (o_ibp_rd_accept),
    .ibp_err_rd                (o_ibp_err_rd),
    .ibp_rd_data               (o_ibp_rd_data),
    .ibp_rd_excl_ok            (o_ibp_rd_excl_ok),
    .ibp_rd_last               (o_ibp_rd_last),

    .ibp_wr_valid              (o_ibp_wr_valid),
    .ibp_wr_accept             (o_ibp_wr_accept),
    .ibp_wr_data               (o_ibp_wr_data),
    .ibp_wr_mask               (o_ibp_wr_mask),
    .ibp_wr_last               (o_ibp_wr_last),

    .ibp_wr_done               (o_ibp_wr_done),
    .ibp_wr_resp_accept        (o_ibp_wr_resp_accept),
    .ibp_wr_excl_done          (o_ibp_wr_excl_done),
    .ibp_err_wr                (o_ibp_err_wr),


    .ibp_cmd_chnl_rgon         (o_ibp_cmd_chnl_rgon),
    .ibp_cmd_chnl_user         (o_ibp_cmd_chnl_user),

    .ibp_cmd_chnl              (o_ibp_cmd_chnl),
    .ibp_rd_chnl               (o_ibp_rd_chnl),
    .ibp_wd_chnl               (o_ibp_wd_chnl),
    .ibp_wrsp_chnl             (o_ibp_wrsp_chnl),
    .ibp_cmd_chnl_valid        (o_ibp_cmd_chnl_valid),
    .ibp_rd_chnl_valid         (o_ibp_rd_chnl_valid),
    .ibp_wd_chnl_valid         (o_ibp_wd_chnl_valid),
    .ibp_wrsp_chnl_valid       (o_ibp_wrsp_chnl_valid),
    .ibp_cmd_chnl_accept       (o_ibp_cmd_chnl_accept),
    .ibp_rd_chnl_accept        (o_ibp_rd_chnl_accept),
    .ibp_wd_chnl_accept        (o_ibp_wd_chnl_accept),
    .ibp_wrsp_chnl_accept      (o_ibp_wrsp_chnl_accept)
   );

endmodule // mss_bus_switch_ibp2ibps
