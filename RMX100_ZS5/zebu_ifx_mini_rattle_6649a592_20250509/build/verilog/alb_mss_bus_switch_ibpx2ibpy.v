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
//  ###   ######  ######  #     #  #####    ###   ######  ######  #     #
//   #    #     # #     #  #   #  #     #    #    #     # #     #  #   #
//   #    #     # #     #   # #         #    #    #     # #     #   # #
//   #    ######  ######     #     #####     #    ######  ######     #
//   #    #     # #         # #   #          #    #     # #          #
//   #    #     # #        #   #  #          #    #     # #          #
//  ###   ######  #       #     # #######   ###   ######  #          #
//
// ===========================================================================
//
// Description:
//  Verilog module to support the IBP data width conversion
//  The IBP is standard IBP, it have some constraints:
//    * input IBP no-narrow transfer supported for burst mode
//    * onput IBP can support or non-support narrow transfer depend on the parameter
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"


module mss_bus_switch_ibpx2ibpy
  #(
    parameter N2W_SUPPORT_NARROW_TRANS = 1,
    parameter W2N_SUPPORT_BURST_TRANS = 1,
    parameter E2E_SUPPORT_BURST_TRANS = 1,

    parameter BYPBUF_WD_CHNL      = 0,
    parameter SPLT_FIFO_DEPTH      = 8,
    parameter X_W = 32, // only can be 32,64,128
    parameter Y_W = 32, // only can be 32,64,128

// leda W175 off
// LMD: A parameter XXX has been defined but is not used
// LJ: We always list out all IBP relevant defines although not used

    parameter X_CMD_CHNL_READ           = 0     ,
    parameter X_CMD_CHNL_WRAP           = 1     ,
    parameter X_CMD_CHNL_DATA_SIZE_LSB  = 2     ,
    parameter X_CMD_CHNL_DATA_SIZE_W    = 3     ,
    parameter X_CMD_CHNL_BURST_SIZE_LSB = 5     ,
    parameter X_CMD_CHNL_BURST_SIZE_W   = 4     ,
    parameter X_CMD_CHNL_PROT_LSB       = 9     ,
    parameter X_CMD_CHNL_PROT_W         = 2     ,
    parameter X_CMD_CHNL_CACHE_LSB      = 11    ,
    parameter X_CMD_CHNL_CACHE_W        = 4     ,
    parameter X_CMD_CHNL_LOCK           = 15    ,
    parameter X_CMD_CHNL_EXCL           = 16    ,
    parameter X_CMD_CHNL_ADDR_LSB       = 24    ,
    parameter X_CMD_CHNL_ADDR_W         = 32    ,
    parameter X_CMD_CHNL_W              = 57    ,

    parameter X_RGON_W = 7,
    parameter X_USER_W = 7,

    parameter X_WD_CHNL_LAST            = 0     ,
    parameter X_WD_CHNL_DATA_LSB        = 1     ,
    parameter X_WD_CHNL_DATA_W          = 32    ,
    parameter X_WD_CHNL_MASK_LSB        = 33    ,
    parameter X_WD_CHNL_MASK_W          = 8     ,
    parameter X_WD_CHNL_W               = 41    ,

    parameter X_RD_CHNL_ERR_RD          = 0     ,
    parameter X_RD_CHNL_RD_LAST         = 1     ,
    parameter X_RD_CHNL_RD_EXCL_OK      = 2     ,
    parameter X_RD_CHNL_RD_DATA_LSB     = 3     ,
    parameter X_RD_CHNL_RD_DATA_W       = 32    ,
    parameter X_RD_CHNL_W               = 35    ,

    parameter X_WRSP_CHNL_WR_DONE       = 0     ,
    parameter X_WRSP_CHNL_WR_EXCL_DONE  = 1     ,
    parameter X_WRSP_CHNL_ERR_WR        = 2     ,
    parameter X_WRSP_CHNL_W             = 3     ,

    parameter Y_CMD_CHNL_READ           = 0     ,
    parameter Y_CMD_CHNL_WRAP           = 1     ,
    parameter Y_CMD_CHNL_DATA_SIZE_LSB  = 2     ,
    parameter Y_CMD_CHNL_DATA_SIZE_W    = 3     ,
    parameter Y_CMD_CHNL_BURST_SIZE_LSB = 5     ,
    parameter Y_CMD_CHNL_BURST_SIZE_W   = 4     ,
    parameter Y_CMD_CHNL_PROT_LSB       = 9     ,
    parameter Y_CMD_CHNL_PROT_W         = 2     ,
    parameter Y_CMD_CHNL_CACHE_LSB      = 11    ,
    parameter Y_CMD_CHNL_CACHE_W        = 4     ,
    parameter Y_CMD_CHNL_LOCK           = 15    ,
    parameter Y_CMD_CHNL_EXCL           = 16    ,
    parameter Y_CMD_CHNL_ADDR_LSB       = 24    ,
    parameter Y_CMD_CHNL_ADDR_W         = 32    ,
    parameter Y_CMD_CHNL_W              = 57    ,

    parameter Y_RGON_W = 7,
    parameter Y_USER_W = 7,

    parameter Y_WD_CHNL_LAST            = 0     ,
    parameter Y_WD_CHNL_DATA_LSB        = 1     ,
    parameter Y_WD_CHNL_DATA_W          = 32    ,
    parameter Y_WD_CHNL_MASK_LSB        = 33    ,
    parameter Y_WD_CHNL_MASK_W          = 8     ,
    parameter Y_WD_CHNL_W               = 41    ,

    parameter Y_RD_CHNL_ERR_RD          = 0     ,
    parameter Y_RD_CHNL_RD_LAST         = 1     ,
    parameter Y_RD_CHNL_RD_EXCL_OK      = 2     ,
    parameter Y_RD_CHNL_RD_DATA_LSB     = 3     ,
    parameter Y_RD_CHNL_RD_DATA_W       = 32    ,
    parameter Y_RD_CHNL_W               = 35    ,

    parameter Y_WRSP_CHNL_WR_DONE       = 0     ,
    parameter Y_WRSP_CHNL_WR_EXCL_DONE  = 1     ,
    parameter Y_WRSP_CHNL_ERR_WR        = 2     ,
    parameter Y_WRSP_CHNL_W             = 3
// leda W175 on
    )
  (
  // The "i_xxx" bus is the one IBP in
  //
  // command channel
  input  i_ibp_cmd_chnl_valid,
  output i_ibp_cmd_chnl_accept,
  input  [X_CMD_CHNL_W-1:0] i_ibp_cmd_chnl,
  //
  // read data channel
  // This module do not support rd_abort
  output i_ibp_rd_chnl_valid,
  input  i_ibp_rd_chnl_accept,
  output [X_RD_CHNL_W-1:0] i_ibp_rd_chnl,
  //
  // write data channel
  input  i_ibp_wd_chnl_valid,
  output i_ibp_wd_chnl_accept,
  input  [X_WD_CHNL_W-1:0] i_ibp_wd_chnl,
  //
  // write response channel
  output i_ibp_wrsp_chnl_valid,
  input  i_ibp_wrsp_chnl_accept,
  output [X_WRSP_CHNL_W-1:0] i_ibp_wrsp_chnl,

  input  [X_RGON_W-1:0] i_ibp_cmd_chnl_rgon,
  input  [X_USER_W-1:0] i_ibp_cmd_chnl_user,
  // The "o_xxx" bus is the one IBP out
  //
  // command channel
  output o_ibp_cmd_chnl_valid,
  input  o_ibp_cmd_chnl_accept,
  output [Y_CMD_CHNL_W-1:0] o_ibp_cmd_chnl,
  //
  // read data channel
  // This module do not support rd_abort
  input  o_ibp_rd_chnl_valid,
  output o_ibp_rd_chnl_accept,
  input  [Y_RD_CHNL_W-1:0] o_ibp_rd_chnl,
  //
  // write data channel
  output o_ibp_wd_chnl_valid,
  input  o_ibp_wd_chnl_accept,
  output [Y_WD_CHNL_W-1:0] o_ibp_wd_chnl,
  //
  // write response channel
  input  o_ibp_wrsp_chnl_valid,
  output o_ibp_wrsp_chnl_accept,
  input  [Y_WRSP_CHNL_W-1:0] o_ibp_wrsp_chnl,

  output [Y_RGON_W-1:0] o_ibp_cmd_chnl_rgon,
  output [Y_USER_W-1:0] o_ibp_cmd_chnl_user,

// leda NTL_CON13C off
// LMD: non driving internal net
// LJ: When the X_W is same as Y_W, then clk and rst have no use
  input                         clk,  // clock signal
  input                         rst_a // reset signal
// leda NTL_CON13C on
  );

genvar i;
genvar j;

generate //{
if(X_W == Y_W) begin: x_w_equal_y_w //{
    if(E2E_SUPPORT_BURST_TRANS == 1) begin: e2e_support_burst //{
        // No convert needed because the width is same
        assign o_ibp_cmd_chnl_valid = i_ibp_cmd_chnl_valid;
        assign i_ibp_cmd_chnl_accept = o_ibp_cmd_chnl_accept;
        assign o_ibp_cmd_chnl = i_ibp_cmd_chnl;

        assign o_ibp_wd_chnl_valid = i_ibp_wd_chnl_valid;
        assign i_ibp_wd_chnl_accept = o_ibp_wd_chnl_accept;
        assign o_ibp_wd_chnl = i_ibp_wd_chnl;

        assign i_ibp_rd_chnl_valid = o_ibp_rd_chnl_valid;
        assign o_ibp_rd_chnl_accept = i_ibp_rd_chnl_accept;
        assign i_ibp_rd_chnl = o_ibp_rd_chnl;

        assign i_ibp_wrsp_chnl_valid = o_ibp_wrsp_chnl_valid;
        assign o_ibp_wrsp_chnl_accept = i_ibp_wrsp_chnl_accept;
        assign i_ibp_wrsp_chnl = o_ibp_wrsp_chnl;

        assign o_ibp_cmd_chnl_rgon = i_ibp_cmd_chnl_rgon;
        assign o_ibp_cmd_chnl_user = i_ibp_cmd_chnl_user;
    end //}
    else begin: e2e_no_support_burst//{

 mss_bus_switch_ibp2ibps
  #(
    .CUT_IN2OUT_WR_ACPT (1),
    .ADDR_W(Y_CMD_CHNL_ADDR_W),
    .DATA_W(Y_W),
    .RGON_W(Y_RGON_W    ),
    .USER_W(Y_USER_W    ),
    .SPLT_FIFO_DEPTH(SPLT_FIFO_DEPTH),

    .CMD_CHNL_READ           (Y_CMD_CHNL_READ           ),
    .CMD_CHNL_WRAP           (Y_CMD_CHNL_WRAP           ),
    .CMD_CHNL_DATA_SIZE_LSB  (Y_CMD_CHNL_DATA_SIZE_LSB  ),
    .CMD_CHNL_DATA_SIZE_W    (Y_CMD_CHNL_DATA_SIZE_W    ),
    .CMD_CHNL_BURST_SIZE_LSB (Y_CMD_CHNL_BURST_SIZE_LSB ),
    .CMD_CHNL_BURST_SIZE_W   (Y_CMD_CHNL_BURST_SIZE_W   ),
    .CMD_CHNL_PROT_LSB       (Y_CMD_CHNL_PROT_LSB       ),
    .CMD_CHNL_PROT_W         (Y_CMD_CHNL_PROT_W         ),
    .CMD_CHNL_CACHE_LSB      (Y_CMD_CHNL_CACHE_LSB      ),
    .CMD_CHNL_CACHE_W        (Y_CMD_CHNL_CACHE_W        ),
    .CMD_CHNL_LOCK           (Y_CMD_CHNL_LOCK           ),
    .CMD_CHNL_EXCL           (Y_CMD_CHNL_EXCL           ),
    .CMD_CHNL_ADDR_LSB       (Y_CMD_CHNL_ADDR_LSB       ),
    .CMD_CHNL_ADDR_W         (Y_CMD_CHNL_ADDR_W         ),
    .CMD_CHNL_W              (Y_CMD_CHNL_W              ),

    .WD_CHNL_LAST            (Y_WD_CHNL_LAST            ),
    .WD_CHNL_DATA_LSB        (Y_WD_CHNL_DATA_LSB        ),
    .WD_CHNL_DATA_W          (Y_WD_CHNL_DATA_W          ),
    .WD_CHNL_MASK_LSB        (Y_WD_CHNL_MASK_LSB        ),
    .WD_CHNL_MASK_W          (Y_WD_CHNL_MASK_W          ),
    .WD_CHNL_W               (Y_WD_CHNL_W               ),

    .RD_CHNL_ERR_RD          (Y_RD_CHNL_ERR_RD          ),
    .RD_CHNL_RD_EXCL_OK      (Y_RD_CHNL_RD_EXCL_OK      ),
    .RD_CHNL_RD_LAST         (Y_RD_CHNL_RD_LAST         ),
    .RD_CHNL_RD_DATA_LSB     (Y_RD_CHNL_RD_DATA_LSB     ),
    .RD_CHNL_RD_DATA_W       (Y_RD_CHNL_RD_DATA_W       ),
    .RD_CHNL_W               (Y_RD_CHNL_W               ),

    .WRSP_CHNL_WR_DONE       (Y_WRSP_CHNL_WR_DONE       ),
    .WRSP_CHNL_WR_EXCL_DONE  (Y_WRSP_CHNL_WR_EXCL_DONE  ),
    .WRSP_CHNL_ERR_WR        (Y_WRSP_CHNL_ERR_WR        ),
    .WRSP_CHNL_W             (Y_WRSP_CHNL_W             )
    ) u_nibp2oibpl
  (

    .clk                       (clk  ),
    .rst_a                     (rst_a),


    .i_ibp_cmd_chnl_rgon       (i_ibp_cmd_chnl_rgon),
    .i_ibp_cmd_chnl_user       (i_ibp_cmd_chnl_user),

    .i_ibp_cmd_chnl            (i_ibp_cmd_chnl),
    .i_ibp_rd_chnl             (i_ibp_rd_chnl),
    .i_ibp_wd_chnl             (i_ibp_wd_chnl),
    .i_ibp_wrsp_chnl           (i_ibp_wrsp_chnl),
    .i_ibp_cmd_chnl_valid      (i_ibp_cmd_chnl_valid),
    .i_ibp_rd_chnl_valid       (i_ibp_rd_chnl_valid),
    .i_ibp_wd_chnl_valid       (i_ibp_wd_chnl_valid),
    .i_ibp_wrsp_chnl_valid     (i_ibp_wrsp_chnl_valid),
    .i_ibp_cmd_chnl_accept     (i_ibp_cmd_chnl_accept),
    .i_ibp_rd_chnl_accept      (i_ibp_rd_chnl_accept),
    .i_ibp_wd_chnl_accept      (i_ibp_wd_chnl_accept),
    .i_ibp_wrsp_chnl_accept    (i_ibp_wrsp_chnl_accept),


    .o_ibp_cmd_chnl_rgon       (o_ibp_cmd_chnl_rgon),
    .o_ibp_cmd_chnl_user       (o_ibp_cmd_chnl_user),

    .o_ibp_cmd_chnl            (o_ibp_cmd_chnl),
    .o_ibp_rd_chnl             (o_ibp_rd_chnl),
    .o_ibp_wd_chnl             (o_ibp_wd_chnl),
    .o_ibp_wrsp_chnl           (o_ibp_wrsp_chnl),
    .o_ibp_cmd_chnl_valid      (o_ibp_cmd_chnl_valid),
    .o_ibp_rd_chnl_valid       (o_ibp_rd_chnl_valid),
    .o_ibp_wd_chnl_valid       (o_ibp_wd_chnl_valid),
    .o_ibp_wrsp_chnl_valid     (o_ibp_wrsp_chnl_valid),
    .o_ibp_cmd_chnl_accept     (o_ibp_cmd_chnl_accept),
    .o_ibp_rd_chnl_accept      (o_ibp_rd_chnl_accept),
    .o_ibp_wd_chnl_accept      (o_ibp_wd_chnl_accept),
    .o_ibp_wrsp_chnl_accept    (o_ibp_wrsp_chnl_accept)

  );

    end //}

end //}

if (X_W < Y_W) begin: x_w_lt_y_w//{
  wire n_ibp_cmd_chnl_valid;
  wire n_ibp_cmd_chnl_accept;
  wire [Y_CMD_CHNL_W-1:0] n_ibp_cmd_chnl;
  //
  // read data channel
  // This module do not support rd_abort
  wire n_ibp_rd_chnl_valid;
  wire n_ibp_rd_chnl_accept;
  wire [Y_RD_CHNL_W-1:0] n_ibp_rd_chnl;
  //
  // write data channel
  wire n_ibp_wd_chnl_valid;
  wire n_ibp_wd_chnl_accept;
  wire [Y_WD_CHNL_W-1:0] n_ibp_wd_chnl;
  //
  // write response channel
  wire n_ibp_wrsp_chnl_valid;
  wire n_ibp_wrsp_chnl_accept;
  wire [Y_WRSP_CHNL_W-1:0] n_ibp_wrsp_chnl;

  wire [Y_RGON_W-1:0] n_ibp_cmd_chnl_rgon;
  wire [Y_USER_W-1:0] n_ibp_cmd_chnl_user;

// leda NTL_CON10 off
// leda NTL_CON10B off
// LMD: output tied to supply Ranges
// LJ: No care about the constant tied
    mss_bus_switch_ibpn2ibpw
  #(
    .SPLT_FIFO_DEPTH      (SPLT_FIFO_DEPTH),
    .X_W  (X_W),
    .Y_W  (Y_W),
    .X_RGON_W  (X_RGON_W),
    .Y_RGON_W  (Y_RGON_W),
    .X_USER_W  (X_USER_W),
    .Y_USER_W  (Y_USER_W),

    .X_CMD_CHNL_READ           (X_CMD_CHNL_READ           ),
    .X_CMD_CHNL_WRAP           (X_CMD_CHNL_WRAP           ),
    .X_CMD_CHNL_DATA_SIZE_LSB  (X_CMD_CHNL_DATA_SIZE_LSB  ),
    .X_CMD_CHNL_DATA_SIZE_W    (X_CMD_CHNL_DATA_SIZE_W    ),
    .X_CMD_CHNL_BURST_SIZE_LSB (X_CMD_CHNL_BURST_SIZE_LSB ),
    .X_CMD_CHNL_BURST_SIZE_W   (X_CMD_CHNL_BURST_SIZE_W   ),
    .X_CMD_CHNL_PROT_LSB       (X_CMD_CHNL_PROT_LSB       ),
    .X_CMD_CHNL_PROT_W         (X_CMD_CHNL_PROT_W         ),
    .X_CMD_CHNL_CACHE_LSB      (X_CMD_CHNL_CACHE_LSB      ),
    .X_CMD_CHNL_CACHE_W        (X_CMD_CHNL_CACHE_W        ),
    .X_CMD_CHNL_LOCK           (X_CMD_CHNL_LOCK           ),
    .X_CMD_CHNL_EXCL           (X_CMD_CHNL_EXCL           ),
    .X_CMD_CHNL_ADDR_LSB       (X_CMD_CHNL_ADDR_LSB       ),
    .X_CMD_CHNL_ADDR_W         (X_CMD_CHNL_ADDR_W         ),
    .X_CMD_CHNL_W              (X_CMD_CHNL_W              ),

    .X_WD_CHNL_LAST            (X_WD_CHNL_LAST            ),
    .X_WD_CHNL_DATA_LSB        (X_WD_CHNL_DATA_LSB        ),
    .X_WD_CHNL_DATA_W          (X_WD_CHNL_DATA_W          ),
    .X_WD_CHNL_MASK_LSB        (X_WD_CHNL_MASK_LSB        ),
    .X_WD_CHNL_MASK_W          (X_WD_CHNL_MASK_W          ),
    .X_WD_CHNL_W               (X_WD_CHNL_W               ),

    .X_RD_CHNL_ERR_RD          (X_RD_CHNL_ERR_RD          ),
    .X_RD_CHNL_RD_EXCL_OK      (X_RD_CHNL_RD_EXCL_OK      ),
    .X_RD_CHNL_RD_LAST         (X_RD_CHNL_RD_LAST         ),
    .X_RD_CHNL_RD_DATA_LSB     (X_RD_CHNL_RD_DATA_LSB     ),
    .X_RD_CHNL_RD_DATA_W       (X_RD_CHNL_RD_DATA_W       ),
    .X_RD_CHNL_W               (X_RD_CHNL_W               ),

    .X_WRSP_CHNL_WR_DONE       (X_WRSP_CHNL_WR_DONE       ),
    .X_WRSP_CHNL_WR_EXCL_DONE  (X_WRSP_CHNL_WR_EXCL_DONE  ),
    .X_WRSP_CHNL_ERR_WR        (X_WRSP_CHNL_ERR_WR        ),
    .X_WRSP_CHNL_W             (X_WRSP_CHNL_W             ),

    .Y_CMD_CHNL_READ           (Y_CMD_CHNL_READ           ),
    .Y_CMD_CHNL_WRAP           (Y_CMD_CHNL_WRAP           ),
    .Y_CMD_CHNL_DATA_SIZE_LSB  (Y_CMD_CHNL_DATA_SIZE_LSB  ),
    .Y_CMD_CHNL_DATA_SIZE_W    (Y_CMD_CHNL_DATA_SIZE_W    ),
    .Y_CMD_CHNL_BURST_SIZE_LSB (Y_CMD_CHNL_BURST_SIZE_LSB ),
    .Y_CMD_CHNL_BURST_SIZE_W   (Y_CMD_CHNL_BURST_SIZE_W   ),
    .Y_CMD_CHNL_PROT_LSB       (Y_CMD_CHNL_PROT_LSB       ),
    .Y_CMD_CHNL_PROT_W         (Y_CMD_CHNL_PROT_W         ),
    .Y_CMD_CHNL_CACHE_LSB      (Y_CMD_CHNL_CACHE_LSB      ),
    .Y_CMD_CHNL_CACHE_W        (Y_CMD_CHNL_CACHE_W        ),
    .Y_CMD_CHNL_LOCK           (Y_CMD_CHNL_LOCK           ),
    .Y_CMD_CHNL_EXCL           (Y_CMD_CHNL_EXCL           ),
    .Y_CMD_CHNL_ADDR_LSB       (Y_CMD_CHNL_ADDR_LSB       ),
    .Y_CMD_CHNL_ADDR_W         (Y_CMD_CHNL_ADDR_W         ),
    .Y_CMD_CHNL_W              (Y_CMD_CHNL_W              ),

    .Y_WD_CHNL_LAST            (Y_WD_CHNL_LAST            ),
    .Y_WD_CHNL_DATA_LSB        (Y_WD_CHNL_DATA_LSB        ),
    .Y_WD_CHNL_DATA_W          (Y_WD_CHNL_DATA_W          ),
    .Y_WD_CHNL_MASK_LSB        (Y_WD_CHNL_MASK_LSB        ),
    .Y_WD_CHNL_MASK_W          (Y_WD_CHNL_MASK_W          ),
    .Y_WD_CHNL_W               (Y_WD_CHNL_W               ),

    .Y_RD_CHNL_ERR_RD          (Y_RD_CHNL_ERR_RD          ),
    .Y_RD_CHNL_RD_EXCL_OK      (Y_RD_CHNL_RD_EXCL_OK      ),
    .Y_RD_CHNL_RD_LAST         (Y_RD_CHNL_RD_LAST         ),
    .Y_RD_CHNL_RD_DATA_LSB     (Y_RD_CHNL_RD_DATA_LSB     ),
    .Y_RD_CHNL_RD_DATA_W       (Y_RD_CHNL_RD_DATA_W       ),
    .Y_RD_CHNL_W               (Y_RD_CHNL_W               ),

    .Y_WRSP_CHNL_WR_DONE       (Y_WRSP_CHNL_WR_DONE       ),
    .Y_WRSP_CHNL_WR_EXCL_DONE  (Y_WRSP_CHNL_WR_EXCL_DONE  ),
    .Y_WRSP_CHNL_ERR_WR        (Y_WRSP_CHNL_ERR_WR        ),
    .Y_WRSP_CHNL_W             (Y_WRSP_CHNL_W             )
    )
 u_ibpn2ibpw (
    .i_ibp_cmd_chnl        (i_ibp_cmd_chnl),
    .i_ibp_rd_chnl         (i_ibp_rd_chnl),
    .i_ibp_wd_chnl         (i_ibp_wd_chnl),
    .i_ibp_wrsp_chnl       (i_ibp_wrsp_chnl),
    .i_ibp_cmd_chnl_valid  (i_ibp_cmd_chnl_valid),
    .i_ibp_rd_chnl_valid   (i_ibp_rd_chnl_valid),
    .i_ibp_wd_chnl_valid   (i_ibp_wd_chnl_valid),
    .i_ibp_wrsp_chnl_valid (i_ibp_wrsp_chnl_valid),
    .i_ibp_cmd_chnl_accept (i_ibp_cmd_chnl_accept),
    .i_ibp_rd_chnl_accept  (i_ibp_rd_chnl_accept),
    .i_ibp_wd_chnl_accept  (i_ibp_wd_chnl_accept),
    .i_ibp_wrsp_chnl_accept(i_ibp_wrsp_chnl_accept),

    .i_ibp_cmd_chnl_rgon   (i_ibp_cmd_chnl_rgon),
    .i_ibp_cmd_chnl_user   (i_ibp_cmd_chnl_user),

    .o_ibp_cmd_chnl        (n_ibp_cmd_chnl),
    .o_ibp_rd_chnl         (n_ibp_rd_chnl),
    .o_ibp_wd_chnl         (n_ibp_wd_chnl),
    .o_ibp_wrsp_chnl       (n_ibp_wrsp_chnl),
    .o_ibp_cmd_chnl_valid  (n_ibp_cmd_chnl_valid),
    .o_ibp_rd_chnl_valid   (n_ibp_rd_chnl_valid),
    .o_ibp_wd_chnl_valid   (n_ibp_wd_chnl_valid),
    .o_ibp_wrsp_chnl_valid (n_ibp_wrsp_chnl_valid),
    .o_ibp_cmd_chnl_accept (n_ibp_cmd_chnl_accept),
    .o_ibp_rd_chnl_accept  (n_ibp_rd_chnl_accept),
    .o_ibp_wd_chnl_accept  (n_ibp_wd_chnl_accept),
    .o_ibp_wrsp_chnl_accept(n_ibp_wrsp_chnl_accept),

    .o_ibp_cmd_chnl_rgon   (n_ibp_cmd_chnl_rgon),
    .o_ibp_cmd_chnl_user   (n_ibp_cmd_chnl_user),

    .rst_a               (rst_a),
    .clk                 (clk               )
);
// leda NTL_CON10 on
// leda NTL_CON10B on

    if(N2W_SUPPORT_NARROW_TRANS == 1) begin: support_nar //{
        // No convert needed because the width is same
        assign o_ibp_cmd_chnl_valid = n_ibp_cmd_chnl_valid;
        assign n_ibp_cmd_chnl_accept = o_ibp_cmd_chnl_accept;
        assign o_ibp_cmd_chnl = n_ibp_cmd_chnl;

        assign o_ibp_wd_chnl_valid = n_ibp_wd_chnl_valid;
        assign n_ibp_wd_chnl_accept = o_ibp_wd_chnl_accept;
        assign o_ibp_wd_chnl = n_ibp_wd_chnl;

        assign n_ibp_rd_chnl_valid = o_ibp_rd_chnl_valid;
        assign o_ibp_rd_chnl_accept = n_ibp_rd_chnl_accept;
        assign n_ibp_rd_chnl = o_ibp_rd_chnl;

        assign n_ibp_wrsp_chnl_valid = o_ibp_wrsp_chnl_valid;
        assign o_ibp_wrsp_chnl_accept = n_ibp_wrsp_chnl_accept;
        assign n_ibp_wrsp_chnl = o_ibp_wrsp_chnl;

        assign o_ibp_cmd_chnl_rgon = n_ibp_cmd_chnl_rgon;
        assign o_ibp_cmd_chnl_user = n_ibp_cmd_chnl_user;
    end //}
    else begin: no_support_nar//{

 mss_bus_switch_ibp2ibps
  #(
    .CUT_IN2OUT_WR_ACPT (1),
    .ADDR_W(Y_CMD_CHNL_ADDR_W),
    .DATA_W(Y_W),
    .RGON_W(Y_RGON_W    ),
    .USER_W(Y_USER_W    ),
    .SPLT_FIFO_DEPTH(SPLT_FIFO_DEPTH),

    .CMD_CHNL_READ           (Y_CMD_CHNL_READ           ),
    .CMD_CHNL_WRAP           (Y_CMD_CHNL_WRAP           ),
    .CMD_CHNL_DATA_SIZE_LSB  (Y_CMD_CHNL_DATA_SIZE_LSB  ),
    .CMD_CHNL_DATA_SIZE_W    (Y_CMD_CHNL_DATA_SIZE_W    ),
    .CMD_CHNL_BURST_SIZE_LSB (Y_CMD_CHNL_BURST_SIZE_LSB ),
    .CMD_CHNL_BURST_SIZE_W   (Y_CMD_CHNL_BURST_SIZE_W   ),
    .CMD_CHNL_PROT_LSB       (Y_CMD_CHNL_PROT_LSB       ),
    .CMD_CHNL_PROT_W         (Y_CMD_CHNL_PROT_W         ),
    .CMD_CHNL_CACHE_LSB      (Y_CMD_CHNL_CACHE_LSB      ),
    .CMD_CHNL_CACHE_W        (Y_CMD_CHNL_CACHE_W        ),
    .CMD_CHNL_LOCK           (Y_CMD_CHNL_LOCK           ),
    .CMD_CHNL_EXCL           (Y_CMD_CHNL_EXCL           ),
    .CMD_CHNL_ADDR_LSB       (Y_CMD_CHNL_ADDR_LSB       ),
    .CMD_CHNL_ADDR_W         (Y_CMD_CHNL_ADDR_W         ),
    .CMD_CHNL_W              (Y_CMD_CHNL_W              ),

    .WD_CHNL_LAST            (Y_WD_CHNL_LAST            ),
    .WD_CHNL_DATA_LSB        (Y_WD_CHNL_DATA_LSB        ),
    .WD_CHNL_DATA_W          (Y_WD_CHNL_DATA_W          ),
    .WD_CHNL_MASK_LSB        (Y_WD_CHNL_MASK_LSB        ),
    .WD_CHNL_MASK_W          (Y_WD_CHNL_MASK_W          ),
    .WD_CHNL_W               (Y_WD_CHNL_W               ),

    .RD_CHNL_ERR_RD          (Y_RD_CHNL_ERR_RD          ),
    .RD_CHNL_RD_EXCL_OK      (Y_RD_CHNL_RD_EXCL_OK      ),
    .RD_CHNL_RD_LAST         (Y_RD_CHNL_RD_LAST         ),
    .RD_CHNL_RD_DATA_LSB     (Y_RD_CHNL_RD_DATA_LSB     ),
    .RD_CHNL_RD_DATA_W       (Y_RD_CHNL_RD_DATA_W       ),
    .RD_CHNL_W               (Y_RD_CHNL_W               ),

    .WRSP_CHNL_WR_DONE       (Y_WRSP_CHNL_WR_DONE       ),
    .WRSP_CHNL_WR_EXCL_DONE  (Y_WRSP_CHNL_WR_EXCL_DONE  ),
    .WRSP_CHNL_ERR_WR        (Y_WRSP_CHNL_ERR_WR        ),
    .WRSP_CHNL_W             (Y_WRSP_CHNL_W             )
    ) u_nibp2oibpl
  (

    .clk                       (clk  ),
    .rst_a                     (rst_a),


    .i_ibp_cmd_chnl_rgon       (n_ibp_cmd_chnl_rgon),
    .i_ibp_cmd_chnl_user       (n_ibp_cmd_chnl_user),

    .i_ibp_cmd_chnl            (n_ibp_cmd_chnl),
    .i_ibp_rd_chnl             (n_ibp_rd_chnl),
    .i_ibp_wd_chnl             (n_ibp_wd_chnl),
    .i_ibp_wrsp_chnl           (n_ibp_wrsp_chnl),
    .i_ibp_cmd_chnl_valid      (n_ibp_cmd_chnl_valid),
    .i_ibp_rd_chnl_valid       (n_ibp_rd_chnl_valid),
    .i_ibp_wd_chnl_valid       (n_ibp_wd_chnl_valid),
    .i_ibp_wrsp_chnl_valid     (n_ibp_wrsp_chnl_valid),
    .i_ibp_cmd_chnl_accept     (n_ibp_cmd_chnl_accept),
    .i_ibp_rd_chnl_accept      (n_ibp_rd_chnl_accept),
    .i_ibp_wd_chnl_accept      (n_ibp_wd_chnl_accept),
    .i_ibp_wrsp_chnl_accept    (n_ibp_wrsp_chnl_accept),


    .o_ibp_cmd_chnl_rgon       (o_ibp_cmd_chnl_rgon),
    .o_ibp_cmd_chnl_user       (o_ibp_cmd_chnl_user),

    .o_ibp_cmd_chnl            (o_ibp_cmd_chnl),
    .o_ibp_rd_chnl             (o_ibp_rd_chnl),
    .o_ibp_wd_chnl             (o_ibp_wd_chnl),
    .o_ibp_wrsp_chnl           (o_ibp_wrsp_chnl),
    .o_ibp_cmd_chnl_valid      (o_ibp_cmd_chnl_valid),
    .o_ibp_rd_chnl_valid       (o_ibp_rd_chnl_valid),
    .o_ibp_wd_chnl_valid       (o_ibp_wd_chnl_valid),
    .o_ibp_wrsp_chnl_valid     (o_ibp_wrsp_chnl_valid),
    .o_ibp_cmd_chnl_accept     (o_ibp_cmd_chnl_accept),
    .o_ibp_rd_chnl_accept      (o_ibp_rd_chnl_accept),
    .o_ibp_wd_chnl_accept      (o_ibp_wd_chnl_accept),
    .o_ibp_wrsp_chnl_accept    (o_ibp_wrsp_chnl_accept)

  );

    end //}
end//}


if (X_W > Y_W) begin: x_w_gt_y_w //{
  wire w_ibp_cmd_chnl_valid;
  wire w_ibp_cmd_chnl_accept;
  wire [Y_CMD_CHNL_W-1:0] w_ibp_cmd_chnl;
  //
  // read data channel
  // This module do not support rd_abort
  wire w_ibp_rd_chnl_valid;
  wire w_ibp_rd_chnl_accept;
  wire [Y_RD_CHNL_W-1:0] w_ibp_rd_chnl;
  //
  // write data channel
  wire w_ibp_wd_chnl_valid;
  wire w_ibp_wd_chnl_accept;
  wire [Y_WD_CHNL_W-1:0] w_ibp_wd_chnl;
  //
  // write response channel
  wire w_ibp_wrsp_chnl_valid;
  wire w_ibp_wrsp_chnl_accept;
  wire [Y_WRSP_CHNL_W-1:0] w_ibp_wrsp_chnl;

  wire [Y_RGON_W-1:0] w_ibp_cmd_chnl_rgon;
  wire [Y_USER_W-1:0] w_ibp_cmd_chnl_user;

// leda NTL_CON10 off
// leda NTL_CON10B off
// LMD: output tied to supply Ranges
// LJ: No care about the constant tied
    mss_bus_switch_ibpw2ibpn
  #(
    .BYPBUF_WD_CHNL       (BYPBUF_WD_CHNL),
    .SPLT_FIFO_DEPTH      (SPLT_FIFO_DEPTH),
    .X_W  (X_W),
    .Y_W  (Y_W),
    .X_RGON_W  (X_RGON_W),
    .Y_RGON_W  (Y_RGON_W),
    .X_USER_W  (X_USER_W),
    .Y_USER_W  (Y_USER_W),

    .X_CMD_CHNL_READ           (X_CMD_CHNL_READ           ),
    .X_CMD_CHNL_WRAP           (X_CMD_CHNL_WRAP           ),
    .X_CMD_CHNL_DATA_SIZE_LSB  (X_CMD_CHNL_DATA_SIZE_LSB  ),
    .X_CMD_CHNL_DATA_SIZE_W    (X_CMD_CHNL_DATA_SIZE_W    ),
    .X_CMD_CHNL_BURST_SIZE_LSB (X_CMD_CHNL_BURST_SIZE_LSB ),
    .X_CMD_CHNL_BURST_SIZE_W   (X_CMD_CHNL_BURST_SIZE_W   ),
    .X_CMD_CHNL_PROT_LSB       (X_CMD_CHNL_PROT_LSB       ),
    .X_CMD_CHNL_PROT_W         (X_CMD_CHNL_PROT_W         ),
    .X_CMD_CHNL_CACHE_LSB      (X_CMD_CHNL_CACHE_LSB      ),
    .X_CMD_CHNL_CACHE_W        (X_CMD_CHNL_CACHE_W        ),
    .X_CMD_CHNL_LOCK           (X_CMD_CHNL_LOCK           ),
    .X_CMD_CHNL_EXCL           (X_CMD_CHNL_EXCL           ),
    .X_CMD_CHNL_ADDR_LSB       (X_CMD_CHNL_ADDR_LSB       ),
    .X_CMD_CHNL_ADDR_W         (X_CMD_CHNL_ADDR_W         ),
    .X_CMD_CHNL_W              (X_CMD_CHNL_W              ),

    .X_WD_CHNL_LAST            (X_WD_CHNL_LAST            ),
    .X_WD_CHNL_DATA_LSB        (X_WD_CHNL_DATA_LSB        ),
    .X_WD_CHNL_DATA_W          (X_WD_CHNL_DATA_W          ),
    .X_WD_CHNL_MASK_LSB        (X_WD_CHNL_MASK_LSB        ),
    .X_WD_CHNL_MASK_W          (X_WD_CHNL_MASK_W          ),
    .X_WD_CHNL_W               (X_WD_CHNL_W               ),

    .X_RD_CHNL_ERR_RD          (X_RD_CHNL_ERR_RD          ),
    .X_RD_CHNL_RD_EXCL_OK      (X_RD_CHNL_RD_EXCL_OK      ),
    .X_RD_CHNL_RD_LAST         (X_RD_CHNL_RD_LAST         ),
    .X_RD_CHNL_RD_DATA_LSB     (X_RD_CHNL_RD_DATA_LSB     ),
    .X_RD_CHNL_RD_DATA_W       (X_RD_CHNL_RD_DATA_W       ),
    .X_RD_CHNL_W               (X_RD_CHNL_W               ),

    .X_WRSP_CHNL_WR_DONE       (X_WRSP_CHNL_WR_DONE       ),
    .X_WRSP_CHNL_WR_EXCL_DONE  (X_WRSP_CHNL_WR_EXCL_DONE  ),
    .X_WRSP_CHNL_ERR_WR        (X_WRSP_CHNL_ERR_WR        ),
    .X_WRSP_CHNL_W             (X_WRSP_CHNL_W             ),

    .Y_CMD_CHNL_READ           (Y_CMD_CHNL_READ           ),
    .Y_CMD_CHNL_WRAP           (Y_CMD_CHNL_WRAP           ),
    .Y_CMD_CHNL_DATA_SIZE_LSB  (Y_CMD_CHNL_DATA_SIZE_LSB  ),
    .Y_CMD_CHNL_DATA_SIZE_W    (Y_CMD_CHNL_DATA_SIZE_W    ),
    .Y_CMD_CHNL_BURST_SIZE_LSB (Y_CMD_CHNL_BURST_SIZE_LSB ),
    .Y_CMD_CHNL_BURST_SIZE_W   (Y_CMD_CHNL_BURST_SIZE_W   ),
    .Y_CMD_CHNL_PROT_LSB       (Y_CMD_CHNL_PROT_LSB       ),
    .Y_CMD_CHNL_PROT_W         (Y_CMD_CHNL_PROT_W         ),
    .Y_CMD_CHNL_CACHE_LSB      (Y_CMD_CHNL_CACHE_LSB      ),
    .Y_CMD_CHNL_CACHE_W        (Y_CMD_CHNL_CACHE_W        ),
    .Y_CMD_CHNL_LOCK           (Y_CMD_CHNL_LOCK           ),
    .Y_CMD_CHNL_EXCL           (Y_CMD_CHNL_EXCL           ),
    .Y_CMD_CHNL_ADDR_LSB       (Y_CMD_CHNL_ADDR_LSB       ),
    .Y_CMD_CHNL_ADDR_W         (Y_CMD_CHNL_ADDR_W         ),
    .Y_CMD_CHNL_W              (Y_CMD_CHNL_W              ),

    .Y_WD_CHNL_LAST            (Y_WD_CHNL_LAST            ),
    .Y_WD_CHNL_DATA_LSB        (Y_WD_CHNL_DATA_LSB        ),
    .Y_WD_CHNL_DATA_W          (Y_WD_CHNL_DATA_W          ),
    .Y_WD_CHNL_MASK_LSB        (Y_WD_CHNL_MASK_LSB        ),
    .Y_WD_CHNL_MASK_W          (Y_WD_CHNL_MASK_W          ),
    .Y_WD_CHNL_W               (Y_WD_CHNL_W               ),

    .Y_RD_CHNL_ERR_RD          (Y_RD_CHNL_ERR_RD          ),
    .Y_RD_CHNL_RD_EXCL_OK      (Y_RD_CHNL_RD_EXCL_OK      ),
    .Y_RD_CHNL_RD_LAST         (Y_RD_CHNL_RD_LAST         ),
    .Y_RD_CHNL_RD_DATA_LSB     (Y_RD_CHNL_RD_DATA_LSB     ),
    .Y_RD_CHNL_RD_DATA_W       (Y_RD_CHNL_RD_DATA_W       ),
    .Y_RD_CHNL_W               (Y_RD_CHNL_W               ),

    .Y_WRSP_CHNL_WR_DONE       (Y_WRSP_CHNL_WR_DONE       ),
    .Y_WRSP_CHNL_WR_EXCL_DONE  (Y_WRSP_CHNL_WR_EXCL_DONE  ),
    .Y_WRSP_CHNL_ERR_WR        (Y_WRSP_CHNL_ERR_WR        ),
    .Y_WRSP_CHNL_W             (Y_WRSP_CHNL_W             )
    )
 u_ibpw2ibpn (
    .i_ibp_cmd_chnl        (i_ibp_cmd_chnl),
    .i_ibp_rd_chnl         (i_ibp_rd_chnl),
    .i_ibp_wd_chnl         (i_ibp_wd_chnl),
    .i_ibp_wrsp_chnl       (i_ibp_wrsp_chnl),
    .i_ibp_cmd_chnl_valid  (i_ibp_cmd_chnl_valid),
    .i_ibp_rd_chnl_valid   (i_ibp_rd_chnl_valid),
    .i_ibp_wd_chnl_valid   (i_ibp_wd_chnl_valid),
    .i_ibp_wrsp_chnl_valid (i_ibp_wrsp_chnl_valid),
    .i_ibp_cmd_chnl_accept (i_ibp_cmd_chnl_accept),
    .i_ibp_rd_chnl_accept  (i_ibp_rd_chnl_accept),
    .i_ibp_wd_chnl_accept  (i_ibp_wd_chnl_accept),
    .i_ibp_wrsp_chnl_accept(i_ibp_wrsp_chnl_accept),

    .i_ibp_cmd_chnl_rgon   (i_ibp_cmd_chnl_rgon),
    .i_ibp_cmd_chnl_user   (i_ibp_cmd_chnl_user),

    .o_ibp_cmd_chnl        (w_ibp_cmd_chnl),
    .o_ibp_rd_chnl         (w_ibp_rd_chnl),
    .o_ibp_wd_chnl         (w_ibp_wd_chnl),
    .o_ibp_wrsp_chnl       (w_ibp_wrsp_chnl),
    .o_ibp_cmd_chnl_valid  (w_ibp_cmd_chnl_valid),
    .o_ibp_rd_chnl_valid   (w_ibp_rd_chnl_valid),
    .o_ibp_wd_chnl_valid   (w_ibp_wd_chnl_valid),
    .o_ibp_wrsp_chnl_valid (w_ibp_wrsp_chnl_valid),
    .o_ibp_cmd_chnl_accept (w_ibp_cmd_chnl_accept),
    .o_ibp_rd_chnl_accept  (w_ibp_rd_chnl_accept),
    .o_ibp_wd_chnl_accept  (w_ibp_wd_chnl_accept),
    .o_ibp_wrsp_chnl_accept(w_ibp_wrsp_chnl_accept),

    .o_ibp_cmd_chnl_rgon   (w_ibp_cmd_chnl_rgon),
    .o_ibp_cmd_chnl_user   (w_ibp_cmd_chnl_user),

    .rst_a               (rst_a),
    .clk                 (clk               )
);
// leda NTL_CON10 on
// leda NTL_CON10B on

    if(W2N_SUPPORT_BURST_TRANS == 1) begin: support_burst //{
        // No convert needed because the width is same
        assign o_ibp_cmd_chnl_valid = w_ibp_cmd_chnl_valid;
        assign w_ibp_cmd_chnl_accept = o_ibp_cmd_chnl_accept;
        assign o_ibp_cmd_chnl = w_ibp_cmd_chnl;

        assign o_ibp_wd_chnl_valid = w_ibp_wd_chnl_valid;
        assign w_ibp_wd_chnl_accept = o_ibp_wd_chnl_accept;
        assign o_ibp_wd_chnl = w_ibp_wd_chnl;

        assign w_ibp_rd_chnl_valid = o_ibp_rd_chnl_valid;
        assign o_ibp_rd_chnl_accept = w_ibp_rd_chnl_accept;
        assign w_ibp_rd_chnl = o_ibp_rd_chnl;

        assign w_ibp_wrsp_chnl_valid = o_ibp_wrsp_chnl_valid;
        assign o_ibp_wrsp_chnl_accept = w_ibp_wrsp_chnl_accept;
        assign w_ibp_wrsp_chnl = o_ibp_wrsp_chnl;

        assign o_ibp_cmd_chnl_rgon = w_ibp_cmd_chnl_rgon;
        assign o_ibp_cmd_chnl_user = w_ibp_cmd_chnl_user;
    end //}
    else begin: no_support_burst//{

 mss_bus_switch_ibp2ibps
  #(
    .CUT_IN2OUT_WR_ACPT (1),
    .ADDR_W(Y_CMD_CHNL_ADDR_W),
    .DATA_W(Y_W),
    .RGON_W(Y_RGON_W    ),
    .USER_W(Y_USER_W    ),
    .SPLT_FIFO_DEPTH(SPLT_FIFO_DEPTH),

    .CMD_CHNL_READ           (Y_CMD_CHNL_READ           ),
    .CMD_CHNL_WRAP           (Y_CMD_CHNL_WRAP           ),
    .CMD_CHNL_DATA_SIZE_LSB  (Y_CMD_CHNL_DATA_SIZE_LSB  ),
    .CMD_CHNL_DATA_SIZE_W    (Y_CMD_CHNL_DATA_SIZE_W    ),
    .CMD_CHNL_BURST_SIZE_LSB (Y_CMD_CHNL_BURST_SIZE_LSB ),
    .CMD_CHNL_BURST_SIZE_W   (Y_CMD_CHNL_BURST_SIZE_W   ),
    .CMD_CHNL_PROT_LSB       (Y_CMD_CHNL_PROT_LSB       ),
    .CMD_CHNL_PROT_W         (Y_CMD_CHNL_PROT_W         ),
    .CMD_CHNL_CACHE_LSB      (Y_CMD_CHNL_CACHE_LSB      ),
    .CMD_CHNL_CACHE_W        (Y_CMD_CHNL_CACHE_W        ),
    .CMD_CHNL_LOCK           (Y_CMD_CHNL_LOCK           ),
    .CMD_CHNL_EXCL           (Y_CMD_CHNL_EXCL           ),
    .CMD_CHNL_ADDR_LSB       (Y_CMD_CHNL_ADDR_LSB       ),
    .CMD_CHNL_ADDR_W         (Y_CMD_CHNL_ADDR_W         ),
    .CMD_CHNL_W              (Y_CMD_CHNL_W              ),

    .WD_CHNL_LAST            (Y_WD_CHNL_LAST            ),
    .WD_CHNL_DATA_LSB        (Y_WD_CHNL_DATA_LSB        ),
    .WD_CHNL_DATA_W          (Y_WD_CHNL_DATA_W          ),
    .WD_CHNL_MASK_LSB        (Y_WD_CHNL_MASK_LSB        ),
    .WD_CHNL_MASK_W          (Y_WD_CHNL_MASK_W          ),
    .WD_CHNL_W               (Y_WD_CHNL_W               ),

    .RD_CHNL_ERR_RD          (Y_RD_CHNL_ERR_RD          ),
    .RD_CHNL_RD_EXCL_OK      (Y_RD_CHNL_RD_EXCL_OK      ),
    .RD_CHNL_RD_LAST         (Y_RD_CHNL_RD_LAST         ),
    .RD_CHNL_RD_DATA_LSB     (Y_RD_CHNL_RD_DATA_LSB     ),
    .RD_CHNL_RD_DATA_W       (Y_RD_CHNL_RD_DATA_W       ),
    .RD_CHNL_W               (Y_RD_CHNL_W               ),

    .WRSP_CHNL_WR_DONE       (Y_WRSP_CHNL_WR_DONE       ),
    .WRSP_CHNL_WR_EXCL_DONE  (Y_WRSP_CHNL_WR_EXCL_DONE  ),
    .WRSP_CHNL_ERR_WR        (Y_WRSP_CHNL_ERR_WR        ),
    .WRSP_CHNL_W             (Y_WRSP_CHNL_W             )
    ) u_nibp2oibpl
  (

    .clk                       (clk  ),
    .rst_a                     (rst_a),


    .i_ibp_cmd_chnl_rgon       (w_ibp_cmd_chnl_rgon),
    .i_ibp_cmd_chnl_user       (w_ibp_cmd_chnl_user),

    .i_ibp_cmd_chnl            (w_ibp_cmd_chnl),
    .i_ibp_rd_chnl             (w_ibp_rd_chnl),
    .i_ibp_wd_chnl             (w_ibp_wd_chnl),
    .i_ibp_wrsp_chnl           (w_ibp_wrsp_chnl),
    .i_ibp_cmd_chnl_valid      (w_ibp_cmd_chnl_valid),
    .i_ibp_rd_chnl_valid       (w_ibp_rd_chnl_valid),
    .i_ibp_wd_chnl_valid       (w_ibp_wd_chnl_valid),
    .i_ibp_wrsp_chnl_valid     (w_ibp_wrsp_chnl_valid),
    .i_ibp_cmd_chnl_accept     (w_ibp_cmd_chnl_accept),
    .i_ibp_rd_chnl_accept      (w_ibp_rd_chnl_accept),
    .i_ibp_wd_chnl_accept      (w_ibp_wd_chnl_accept),
    .i_ibp_wrsp_chnl_accept    (w_ibp_wrsp_chnl_accept),


    .o_ibp_cmd_chnl_rgon       (o_ibp_cmd_chnl_rgon),
    .o_ibp_cmd_chnl_user       (o_ibp_cmd_chnl_user),

    .o_ibp_cmd_chnl            (o_ibp_cmd_chnl),
    .o_ibp_rd_chnl             (o_ibp_rd_chnl),
    .o_ibp_wd_chnl             (o_ibp_wd_chnl),
    .o_ibp_wrsp_chnl           (o_ibp_wrsp_chnl),
    .o_ibp_cmd_chnl_valid      (o_ibp_cmd_chnl_valid),
    .o_ibp_rd_chnl_valid       (o_ibp_rd_chnl_valid),
    .o_ibp_wd_chnl_valid       (o_ibp_wd_chnl_valid),
    .o_ibp_wrsp_chnl_valid     (o_ibp_wrsp_chnl_valid),
    .o_ibp_cmd_chnl_accept     (o_ibp_cmd_chnl_accept),
    .o_ibp_rd_chnl_accept      (o_ibp_rd_chnl_accept),
    .o_ibp_wd_chnl_accept      (o_ibp_wd_chnl_accept),
    .o_ibp_wrsp_chnl_accept    (o_ibp_wrsp_chnl_accept)

  );

    end//}
end//}

endgenerate //}


endmodule // mss_bus_switch_ibpx2ibpy
