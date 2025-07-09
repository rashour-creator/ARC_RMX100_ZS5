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
//  ###   ######  ######   #####    ###   ######  ######
//   #    #     # #     # #     #    #    #     # #     #
//   #    #     # #     #       #    #    #     # #     #
//   #    ######  ######   #####     #    ######  ######
//   #    #     # #       #          #    #     # #
//   #    #     # #       #          #    #     # #
//  ###   ######  #       #######   ###   ######  #
//
// ===========================================================================
//
// Description:
//  Verilog module to support the IBP data width conversion
//  The IBP is standard IBP, it have some constraints:
//    * Input IBP no-narrow transfer supported for burst mode
//    * Onput IBP met the following conditions will be packed to wider IBP burst
//       (1) If the beats number of N IBP can be divided by the upsizing ratio.
//           Such as the N=32, W=128, then the upsizing ratio is 4(128/32)
//           If the beats of N IBP is 16, then it can be divided by ratio 4
//       (2) The start address (after round to N size) is rounded to begining of W
//           Suche as the W is 128bits, then the start address of N (64bits)
//           IBP (after round to size of 64bits) is rounded to beginning of 128bits.
//    * Onput IBP donot met the abvoe conditions will be outputed as narrow
//      transfer which is actually not standard IBP
//
// ===========================================================================
// Configuration-dependent macro definitions
//
`include "alb_mss_bus_switch_defines.v"

// Set simulation timescale
//
`include "const.def"

module mss_bus_switch_ibpn2ibpw
  #(
    parameter SPLT_FIFO_DEPTH      = 8,
    parameter X_W = 32, // only can be 32,64,128
    parameter Y_W = 64, // only can be 32,64,128

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
    parameter Y_WD_CHNL_DATA_W          = 64    ,
    parameter Y_WD_CHNL_MASK_LSB        = 65    ,
    parameter Y_WD_CHNL_MASK_W          = 8     ,
    parameter Y_WD_CHNL_W               = 73    ,

    parameter Y_RD_CHNL_ERR_RD          = 0     ,
    parameter Y_RD_CHNL_RD_LAST         = 1     ,
    parameter Y_RD_CHNL_RD_EXCL_OK      = 2     ,
    parameter Y_RD_CHNL_RD_DATA_LSB     = 3     ,
    parameter Y_RD_CHNL_RD_DATA_W       = 64    ,
    parameter Y_RD_CHNL_W               = 67    ,

    parameter Y_WRSP_CHNL_WR_DONE       = 0     ,
    parameter Y_WRSP_CHNL_WR_EXCL_DONE  = 1     ,
    parameter Y_WRSP_CHNL_ERR_WR        = 2     ,
    parameter Y_WRSP_CHNL_W             = 3
// leda W175 on
    )
  (
  // The "i_xxx" bus is the one IBP to be buffered
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
  // The "o_xxx" bus is the one IBP after buffered
  //
  // command channel
  output o_ibp_cmd_chnl_valid,
  input  o_ibp_cmd_chnl_accept,
  output reg [Y_CMD_CHNL_W-1:0] o_ibp_cmd_chnl,
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

  input                         clk,  // clock signal
  input                         rst_a // reset signal
  );


// write data channel
wire npck_o_ibp_wd_chnl_valid;
wire npck_i_ibp_wd_chnl_accept;
wire [Y_WD_CHNL_W-1:0] npck_o_ibp_wd_chnl;

wire pack_o_ibp_wd_chnl_valid;
wire pack_i_ibp_wd_chnl_accept;
wire [Y_WD_CHNL_W-1:0] pack_o_ibp_wd_chnl;

// The condtions for which the N IBP met can be packed to wider burst
wire n_bstlen_divided;
wire n_addr_start_w;
wire [2:0] w_ibp_full_size;
wire n2w_pack_cond = n_bstlen_divided & n_addr_start_w;

wire [X_CMD_CHNL_BURST_SIZE_W-1:0] i_ibp_cmd_burst_size = i_ibp_cmd_chnl[(X_CMD_CHNL_BURST_SIZE_W-1+X_CMD_CHNL_BURST_SIZE_LSB) : X_CMD_CHNL_BURST_SIZE_LSB];
wire [X_CMD_CHNL_ADDR_W-1:0] i_ibp_cmd_addr = i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_W-1+X_CMD_CHNL_ADDR_LSB) : X_CMD_CHNL_ADDR_LSB];

generate //{
    if(X_W == 32) begin:xw_is_32
        if(Y_W == 64) begin:xw32_yw64
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(i_ibp_cmd_addr[2]);
          assign w_ibp_full_size = 3'd3;
        end
        if(Y_W == 128) begin:xw32_yw128
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[1] & i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[3:2]);
          assign w_ibp_full_size = 3'd4;
        end
        if(Y_W == 256) begin:xw32_yw256
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[2] & i_ibp_cmd_burst_size[1] & i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(i_ibp_cmd_addr[4:2]);
          assign w_ibp_full_size = 3'd5;
        end
        if(Y_W == 512) begin:xw32_yw512
          assign n_bstlen_divided = (X_CMD_CHNL_BURST_SIZE_W > 4) && (i_ibp_cmd_burst_size[3] & i_ibp_cmd_burst_size[2] & i_ibp_cmd_burst_size[1] & i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[5:2]);
          assign w_ibp_full_size = 3'd6;
        end
    end
    if(X_W == 64) begin:xw_is_64
        if(Y_W == 128) begin:xw64_yw128
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(i_ibp_cmd_addr[3]);
          assign w_ibp_full_size = 3'd4;
        end
        if(Y_W == 256) begin:xw64_yw256
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[1] & i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[4:3]);
          assign w_ibp_full_size = 3'd5;
        end
        if(Y_W == 512) begin:xw64_yw512
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[2] & i_ibp_cmd_burst_size[1] & i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[5:3]);
          assign w_ibp_full_size = 3'd6;
        end
    end
    if(X_W == 128) begin:xw_is_128
        if(Y_W == 256) begin:xw128_yw256
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[4]);
          assign w_ibp_full_size = 3'd5;
        end
        if(Y_W == 512) begin:xw128_yw512
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[1] & i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[5:4]);
          assign w_ibp_full_size = 3'd6;
        end
    end
    if(X_W == 256) begin:xw_is_256
        if(Y_W == 512) begin:xw256_yw512
          assign n_bstlen_divided = (i_ibp_cmd_burst_size[0]);
          assign n_addr_start_w = ~(i_ibp_cmd_addr[5]);
          assign w_ibp_full_size = 3'd6;
        end
    end
endgenerate //}





// Convert from smaller width to larger width: Just use the narrow transfer

assign o_ibp_cmd_chnl_rgon = i_ibp_cmd_chnl_rgon;
assign o_ibp_cmd_chnl_user = i_ibp_cmd_chnl_user;

// For the cmd channel: Directly convert the command attribute
wire wd_lane_vec_fifo_full;
wire rd_lane_vec_fifo_full;
assign o_ibp_cmd_chnl_valid = i_ibp_cmd_chnl_valid
                     & (~wd_lane_vec_fifo_full)
                     & (~rd_lane_vec_fifo_full);
assign i_ibp_cmd_chnl_accept = o_ibp_cmd_chnl_accept
                     & (~wd_lane_vec_fifo_full)
                     & (~rd_lane_vec_fifo_full);
always @ *
begin : o_ibp_cmd_chnl_gen_PROC
  o_ibp_cmd_chnl = i_ibp_cmd_chnl;
  o_ibp_cmd_chnl [(Y_CMD_CHNL_DATA_SIZE_W-1+Y_CMD_CHNL_DATA_SIZE_LSB) : Y_CMD_CHNL_DATA_SIZE_LSB] =
       n2w_pack_cond ? w_ibp_full_size : i_ibp_cmd_chnl[(X_CMD_CHNL_DATA_SIZE_W-1+X_CMD_CHNL_DATA_SIZE_LSB) : X_CMD_CHNL_DATA_SIZE_LSB];
  o_ibp_cmd_chnl [(Y_CMD_CHNL_BURST_SIZE_W-1+Y_CMD_CHNL_BURST_SIZE_LSB) : Y_CMD_CHNL_BURST_SIZE_LSB] =
       n2w_pack_cond ? (
//                        ({Y_CMD_CHNL_BURST_SIZE_W{(Y_W/X_W) == 16}} & {4'b0, i_ibp_cmd_burst_size[X_CMD_CHNL_BURST_SIZE_W-1:4]})
                           ({Y_CMD_CHNL_BURST_SIZE_W{(Y_W/X_W) == 8}} & {3'b0, i_ibp_cmd_burst_size[X_CMD_CHNL_BURST_SIZE_W-1:3]})
                         | ({Y_CMD_CHNL_BURST_SIZE_W{(Y_W/X_W) == 4}} & {2'b0, i_ibp_cmd_burst_size[X_CMD_CHNL_BURST_SIZE_W-1:2]})
                         | ({Y_CMD_CHNL_BURST_SIZE_W{(Y_W/X_W) == 2}} & {1'b0, i_ibp_cmd_burst_size[X_CMD_CHNL_BURST_SIZE_W-1:1]})
                       )
                     : i_ibp_cmd_burst_size;
  o_ibp_cmd_chnl [Y_CMD_CHNL_WRAP] =
         (o_ibp_cmd_chnl [(Y_CMD_CHNL_BURST_SIZE_W-1+Y_CMD_CHNL_BURST_SIZE_LSB) : Y_CMD_CHNL_BURST_SIZE_LSB] == {Y_CMD_CHNL_BURST_SIZE_W{1'b0}})
         ? 1'b0 : i_ibp_cmd_chnl [X_CMD_CHNL_WRAP];
end

// The wd_lane_vec_fifo is just store the "wd_lane_vec" indication, so that
// when the wdata is coming from IBP, it know its wd lane
// The MSB bit of wdata is used to specially indicate if this is a wrap with boundry inside half of data bus
//     in our design only 32-to-128 case could have such possiblity
wire wd_lane_vec_fifo_wen  ;
wire wd_lane_vec_fifo_ren  ;
wire wd_lane_vec_fifo_wen_raw  ;
wire wd_lane_vec_fifo_ren_raw  ;
wire wd_lane_vec_fifo_empty;
wire byp_wd_lane_vec_fifo = wd_lane_vec_fifo_empty & wd_lane_vec_fifo_wen_raw & wd_lane_vec_fifo_ren_raw;



wire [(Y_W/X_W)+2-1:0] wd_lane_vec_fifo_wdat ;
// Write when IBP cmd channel is handshaked
assign wd_lane_vec_fifo_wen_raw  = i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & (~i_ibp_cmd_chnl[X_CMD_CHNL_READ]);
assign wd_lane_vec_fifo_wen = wd_lane_vec_fifo_wen_raw & (~byp_wd_lane_vec_fifo);
// Read when IBP wd channel is handshaked (last)
assign wd_lane_vec_fifo_ren_raw  = i_ibp_wd_chnl_valid & i_ibp_wd_chnl_accept & i_ibp_wd_chnl[X_WD_CHNL_LAST];
assign wd_lane_vec_fifo_ren = wd_lane_vec_fifo_ren_raw & (~byp_wd_lane_vec_fifo);

wire [(Y_W/X_W)+2-1:0] wd_lane_vec_fifo_rdat ;

generate //{
    if(X_W == 32) begin:wd_xw32
        if(Y_W == 64) begin:wd_xw32_yw64
            // If the address [2] is 0, then put 32bits i_ibp data in lower part of 64bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = ~i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+2];
            assign wd_lane_vec_fifo_wdat[1] =  i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+2];
// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
            assign wd_lane_vec_fifo_wdat[2] =  1'b0; // 32-to-64 have no half-wrap case
// leda NTL_CON16 on
            assign wd_lane_vec_fifo_wdat[3] =  n2w_pack_cond;
        end
        if(Y_W == 128) begin:wd_xw32_yw128
            // If the address [3:2] is 2'b0, then put 32bits i_ibp data in lower 1/4 part of 64bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+3):(X_CMD_CHNL_ADDR_LSB+2)] == 2'd0);
            assign wd_lane_vec_fifo_wdat[1] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+3):(X_CMD_CHNL_ADDR_LSB+2)] == 2'd1);
            assign wd_lane_vec_fifo_wdat[2] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+3):(X_CMD_CHNL_ADDR_LSB+2)] == 2'd2);
            assign wd_lane_vec_fifo_wdat[3] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+3):(X_CMD_CHNL_ADDR_LSB+2)] == 2'd3);
               // When 32-to-128 buses, the burst length is 2, wrap mode, then the wrap boundry is in the middle of data bus
            assign wd_lane_vec_fifo_wdat[4] =  i_ibp_cmd_chnl[X_CMD_CHNL_WRAP] &
                               (i_ibp_cmd_chnl[(X_CMD_CHNL_BURST_SIZE_W-1+X_CMD_CHNL_BURST_SIZE_LSB) : X_CMD_CHNL_BURST_SIZE_LSB] == 1);
            assign wd_lane_vec_fifo_wdat[5] =  n2w_pack_cond;
        end
        if(Y_W == 256) begin:wd_xw32_yw256
            // If the address [3:2] is 2'b0, then put 32bits i_ibp data in lower 1/4 part of 64bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd0);
            assign wd_lane_vec_fifo_wdat[1] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd1);
            assign wd_lane_vec_fifo_wdat[2] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd2);
            assign wd_lane_vec_fifo_wdat[3] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd3);
            assign wd_lane_vec_fifo_wdat[4] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd4);
            assign wd_lane_vec_fifo_wdat[5] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd5);
            assign wd_lane_vec_fifo_wdat[6] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd6);
            assign wd_lane_vec_fifo_wdat[7] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 3'd7);
               // When 32-to-128 buses, the burst length is 2, wrap mode, then the wrap boundry is in the middle of data bus
            assign wd_lane_vec_fifo_wdat[8] =  i_ibp_cmd_chnl[X_CMD_CHNL_WRAP] &
                               (i_ibp_cmd_chnl[(X_CMD_CHNL_BURST_SIZE_W-1+X_CMD_CHNL_BURST_SIZE_LSB) : X_CMD_CHNL_BURST_SIZE_LSB] == 1);
            assign wd_lane_vec_fifo_wdat[9] =  n2w_pack_cond;
        end
        if(Y_W == 512) begin:wd_xw32_yw512
            // If the address [3:2] is 2'b0, then put 32bits i_ibp data in lower 1/4 part of 64bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd0);
            assign wd_lane_vec_fifo_wdat[1]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd1);
            assign wd_lane_vec_fifo_wdat[2]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd2);
            assign wd_lane_vec_fifo_wdat[3]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd3);
            assign wd_lane_vec_fifo_wdat[4]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd4);
            assign wd_lane_vec_fifo_wdat[5]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd5);
            assign wd_lane_vec_fifo_wdat[6]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd6);
            assign wd_lane_vec_fifo_wdat[7]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd7);
            assign wd_lane_vec_fifo_wdat[8]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd8);
            assign wd_lane_vec_fifo_wdat[9]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd9);
            assign wd_lane_vec_fifo_wdat[10] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd10);
            assign wd_lane_vec_fifo_wdat[11] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd11);
            assign wd_lane_vec_fifo_wdat[12] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd12);
            assign wd_lane_vec_fifo_wdat[13] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd13);
            assign wd_lane_vec_fifo_wdat[14] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd14);
            assign wd_lane_vec_fifo_wdat[15] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+2)] == 4'd15);
               // When 32-to-128 buses, the burst length is 2, wrap mode, then the wrap boundry is in the middle of data bus
            assign wd_lane_vec_fifo_wdat[16] =  i_ibp_cmd_chnl[X_CMD_CHNL_WRAP] &
                               (i_ibp_cmd_chnl[(X_CMD_CHNL_BURST_SIZE_W-1+X_CMD_CHNL_BURST_SIZE_LSB) : X_CMD_CHNL_BURST_SIZE_LSB] == 1);
            assign wd_lane_vec_fifo_wdat[17] =  n2w_pack_cond;
        end


    end
    if(X_W == 64) begin:wd_xw64
        if(Y_W == 128) begin:wd_xw64_yw128
            // If the address [3] is 0, then put 64bits i_ibp data in lower part of 128bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = ~i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+3];
            assign wd_lane_vec_fifo_wdat[1] =  i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+3];
// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
            assign wd_lane_vec_fifo_wdat[2] =  1'b0; // 64-to-128 have no half-wrap case
// leda NTL_CON16 on
            assign wd_lane_vec_fifo_wdat[3] =  n2w_pack_cond;
        end
        if(Y_W == 256) begin:wd_xw64_yw256
            // If the address [3:2] is 2'b0, then put 32bits i_ibp data in lower 1/4 part of 64bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+3)] == 2'd0);
            assign wd_lane_vec_fifo_wdat[1] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+3)] == 2'd1);
            assign wd_lane_vec_fifo_wdat[2] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+3)] == 2'd2);
            assign wd_lane_vec_fifo_wdat[3] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+4):(X_CMD_CHNL_ADDR_LSB+3)] == 2'd3);
               // When 32-to-128 buses, the burst length is 2, wrap mode, then the wrap boundry is in the middle of data bus
            assign wd_lane_vec_fifo_wdat[4] =  i_ibp_cmd_chnl[X_CMD_CHNL_WRAP] &
                               (i_ibp_cmd_chnl[(X_CMD_CHNL_BURST_SIZE_W-1+X_CMD_CHNL_BURST_SIZE_LSB) : X_CMD_CHNL_BURST_SIZE_LSB] == 1);
            assign wd_lane_vec_fifo_wdat[5] =  n2w_pack_cond;
        end
        if(Y_W == 512) begin:wd_xw64_yw512
            // If the address [3:2] is 2'b0, then put 32bits i_ibp data in lower 1/4 part of 64bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd0);
            assign wd_lane_vec_fifo_wdat[1]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd1);
            assign wd_lane_vec_fifo_wdat[2]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd2);
            assign wd_lane_vec_fifo_wdat[3]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd3);
            assign wd_lane_vec_fifo_wdat[4]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd4);
            assign wd_lane_vec_fifo_wdat[5]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd5);
            assign wd_lane_vec_fifo_wdat[6]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd6);
            assign wd_lane_vec_fifo_wdat[7]  = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+3)] == 3'd7);
               // When 32-to-128 buses, the burst length is 2, wrap mode, then the wrap boundry is in the middle of data bus
            assign wd_lane_vec_fifo_wdat[8] =  i_ibp_cmd_chnl[X_CMD_CHNL_WRAP] &
                               (i_ibp_cmd_chnl[(X_CMD_CHNL_BURST_SIZE_W-1+X_CMD_CHNL_BURST_SIZE_LSB) : X_CMD_CHNL_BURST_SIZE_LSB] == 1);
            assign wd_lane_vec_fifo_wdat[9] =  n2w_pack_cond;
        end
    end
    if(X_W == 128) begin:wd_xw128
        if(Y_W == 256) begin:wd_xw128_yw256
            // If the address [3] is 0, then put 64bits i_ibp data in lower part of 128bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = ~i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+4];
            assign wd_lane_vec_fifo_wdat[1] =  i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+4];
// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
            assign wd_lane_vec_fifo_wdat[2] =  1'b0; // 64-to-128 have no half-wrap case
// leda NTL_CON16 on
            assign wd_lane_vec_fifo_wdat[3] =  n2w_pack_cond;
        end
        if(Y_W == 512) begin:wd_xw128_yw512
            // If the address [3:2] is 2'b0, then put 32bits i_ibp data in lower 1/4 part of 64bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+4)] == 2'd0);
            assign wd_lane_vec_fifo_wdat[1] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+4)] == 2'd1);
            assign wd_lane_vec_fifo_wdat[2] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+4)] == 2'd2);
            assign wd_lane_vec_fifo_wdat[3] = (i_ibp_cmd_chnl[(X_CMD_CHNL_ADDR_LSB+5):(X_CMD_CHNL_ADDR_LSB+4)] == 2'd3);
               // When 32-to-128 buses, the burst length is 2, wrap mode, then the wrap boundry is in the middle of data bus
            assign wd_lane_vec_fifo_wdat[4] =  i_ibp_cmd_chnl[X_CMD_CHNL_WRAP] &
                               (i_ibp_cmd_chnl[(X_CMD_CHNL_BURST_SIZE_W-1+X_CMD_CHNL_BURST_SIZE_LSB) : X_CMD_CHNL_BURST_SIZE_LSB] == 1);
            assign wd_lane_vec_fifo_wdat[5] =  n2w_pack_cond;
        end
    end
    if(X_W == 256) begin:wd_xw256
        if(Y_W == 512) begin:wd_xw256_yw512
            // If the address [3] is 0, then put 64bits i_ibp data in lower part of 128bits o_ibp data bus, etc.
            assign wd_lane_vec_fifo_wdat[0] = ~i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+5];
            assign wd_lane_vec_fifo_wdat[1] =  i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_LSB+5];
// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
            assign wd_lane_vec_fifo_wdat[2] =  1'b0; // 64-to-128 have no half-wrap case
// leda NTL_CON16 on
            assign wd_lane_vec_fifo_wdat[3] =  n2w_pack_cond;
        end
    end

endgenerate //}


wire wd_lane_vec_fifo_i_valid;
wire wd_lane_vec_fifo_o_valid;
wire wd_lane_vec_fifo_i_ready;
wire wd_lane_vec_fifo_o_ready;
assign wd_lane_vec_fifo_i_valid = wd_lane_vec_fifo_wen;
assign wd_lane_vec_fifo_full    = (~wd_lane_vec_fifo_i_ready);
assign wd_lane_vec_fifo_o_ready = wd_lane_vec_fifo_ren;
assign wd_lane_vec_fifo_empty   = (~wd_lane_vec_fifo_o_valid);

mss_bus_switch_fifo # (
  .FIFO_WIDTH(((Y_W/X_W)+2)),
  .FIFO_DEPTH(SPLT_FIFO_DEPTH),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) wd_lane_vec_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (wd_lane_vec_fifo_i_valid),
  .i_ready   (wd_lane_vec_fifo_i_ready),
  .o_valid   (wd_lane_vec_fifo_o_valid),
  .o_ready   (wd_lane_vec_fifo_o_ready),
  .i_data    (wd_lane_vec_fifo_wdat ),
  .o_data    (wd_lane_vec_fifo_rdat ),
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

// The rd_lane_vec_fifo is just store the "rd_lane_vec" indication, so that
// when the rdata is coming from IBP, it know its rd lane
wire rd_lane_vec_fifo_wen  ;
wire rd_lane_vec_fifo_ren  ;
wire [(Y_W/X_W)+2-1:0] rd_lane_vec_fifo_wdat ;
wire [(Y_W/X_W)+2-1:0] rd_lane_vec_fifo_rdat ;
wire rd_lane_vec_fifo_empty;
// Write when IBP cmd channel is handshaked
assign rd_lane_vec_fifo_wen  = i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & i_ibp_cmd_chnl[X_CMD_CHNL_READ];
// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign rd_lane_vec_fifo_wdat = wd_lane_vec_fifo_wdat;
// leda NTL_CON16 on
// Read when IBP rd channel is handshaked (last)
assign rd_lane_vec_fifo_ren  = i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & i_ibp_rd_chnl[X_RD_CHNL_RD_LAST];

wire rd_lane_vec_fifo_i_valid;
wire rd_lane_vec_fifo_o_valid;
wire rd_lane_vec_fifo_i_ready;
wire rd_lane_vec_fifo_o_ready;
assign rd_lane_vec_fifo_i_valid = rd_lane_vec_fifo_wen;
assign rd_lane_vec_fifo_full    = (~rd_lane_vec_fifo_i_ready);
assign rd_lane_vec_fifo_o_ready = rd_lane_vec_fifo_ren;
assign rd_lane_vec_fifo_empty   = (~rd_lane_vec_fifo_o_valid);

mss_bus_switch_fifo # (
  .FIFO_WIDTH(((Y_W/X_W)+2)),
  .FIFO_DEPTH(SPLT_FIFO_DEPTH),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) rd_lane_vec_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (rd_lane_vec_fifo_i_valid),
  .i_ready   (rd_lane_vec_fifo_i_ready),
  .o_valid   (rd_lane_vec_fifo_o_valid),
  .o_ready   (rd_lane_vec_fifo_o_ready),
  .i_data    (rd_lane_vec_fifo_wdat ),
  .o_data    (rd_lane_vec_fifo_rdat ),
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


// For the write response channel: Directly convert the write response
assign i_ibp_wrsp_chnl_valid = o_ibp_wrsp_chnl_valid;
assign o_ibp_wrsp_chnl_accept = i_ibp_wrsp_chnl_accept;
assign i_ibp_wrsp_chnl = o_ibp_wrsp_chnl;

// For the rdata channel: Put the data into approprate postion for narrow transfer

// Implement 1 bit register to indicate the 1st beat rd
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg rd_1st_beat_r;
// leda NTL_CON32 on
wire rd_1st_beat_ena;
wire rd_1st_beat_set;
wire rd_1st_beat_clr;
// When the "last" beat handshaked, then set the rd_1st indication for next coming beat
assign rd_1st_beat_set = i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & i_ibp_rd_chnl[X_RD_CHNL_RD_LAST];
// When the "non-last" beat handshaked, then clear the rd_1st indication for next coming beat
assign rd_1st_beat_clr = i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & (~i_ibp_rd_chnl[X_RD_CHNL_RD_LAST]);
assign rd_1st_beat_ena = rd_1st_beat_clr | rd_1st_beat_set;
wire rd_1st_beat_nxt = rd_1st_beat_set | (~rd_1st_beat_clr);

always @(posedge clk or posedge rst_a)
begin : rd_1st_beat_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      rd_1st_beat_r       <= 1'b1;
  end
  else if (rd_1st_beat_ena == 1'b1) begin
      rd_1st_beat_r       <= rd_1st_beat_nxt;
  end
end

// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire rd_wrap_half;
assign rd_wrap_half = rd_lane_vec_fifo_rdat[(Y_W/X_W)];
// leda NTL_CON13A on

// Implement a counter to indicate the lane in rd channel
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg [(Y_W/X_W)-1:0] rd_lane_vec_r;
wire [(Y_W/X_W)-1:0] rd_lane_vec_nxt;
wire [(Y_W/X_W)-1:0] rd_lane_vec_nxt_raw;
// leda NTL_CON32 on
wire rd_lane_vec_ena;
wire rd_lane_vec_inc;
wire rd_lane_vec_set;
assign rd_lane_vec_inc = i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & (~i_ibp_rd_chnl[X_RD_CHNL_RD_LAST]);
wire rd_1st_beat_hshked = i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & rd_1st_beat_r;
assign rd_lane_vec_set = rd_1st_beat_hshked;
assign rd_lane_vec_ena = rd_lane_vec_inc | rd_lane_vec_set;
assign rd_lane_vec_nxt_raw = rd_lane_vec_set ? rd_lane_vec_fifo_rdat[(Y_W/X_W)-1:0] : rd_lane_vec_r[(Y_W/X_W)-1:0];
generate //{
    if((Y_W/X_W) == 4) begin:rd_ywxw_4//{
assign rd_lane_vec_nxt =  rd_wrap_half ? {//  Only when 32-to-128 buses
                                             rd_lane_vec_nxt_raw[2],
                                             rd_lane_vec_nxt_raw[3],
                                             rd_lane_vec_nxt_raw[0],
                                             rd_lane_vec_nxt_raw[1]
                                             }
                              : {rd_lane_vec_nxt_raw[(Y_W/X_W)-2:0], rd_lane_vec_nxt_raw[(Y_W/X_W)-1]};
    end//}{
    else begin:rd_ywxw_not_4
assign rd_lane_vec_nxt =  {rd_lane_vec_nxt_raw[(Y_W/X_W)-2:0], rd_lane_vec_nxt_raw[(Y_W/X_W)-1]};
    end//}
endgenerate //}


always @(posedge clk or posedge rst_a)
begin : rd_lane_vec_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      rd_lane_vec_r       <= {(Y_W/X_W){1'b0}};
  end
  else if (rd_lane_vec_ena == 1'b1) begin
      rd_lane_vec_r       <= rd_lane_vec_nxt;
  end
end

wire [(Y_W/X_W)-1:0] rd_lane_vec_real = rd_1st_beat_r ? rd_lane_vec_fifo_rdat[(Y_W/X_W)-1:0] : rd_lane_vec_r;


reg rd_pack_ind_r;
wire rd_pack_ind_nxt = rd_lane_vec_fifo_rdat[(Y_W/X_W)+1];

always @(posedge clk or posedge rst_a)
begin : rd_pack_ind_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      rd_pack_ind_r       <= 1'b0;
  end
  else if (rd_lane_vec_set == 1'b1) begin
      rd_pack_ind_r       <= rd_pack_ind_nxt;
  end
end

wire rd_pack_ind_real = rd_1st_beat_r ? rd_lane_vec_fifo_rdat[(Y_W/X_W)+1] : rd_pack_ind_r;

assign i_ibp_rd_chnl[X_RD_CHNL_ERR_RD] = o_ibp_rd_chnl[Y_RD_CHNL_ERR_RD] ;
assign i_ibp_rd_chnl[X_RD_CHNL_RD_EXCL_OK] = o_ibp_rd_chnl[Y_RD_CHNL_RD_EXCL_OK] ;

generate //{
    if((Y_W/X_W) == 16) begin:i_rd_ywxw_is_16
     assign   i_ibp_rd_chnl[(X_W-1+X_RD_CHNL_RD_DATA_LSB) : X_RD_CHNL_RD_DATA_LSB] =
                        ({X_W{rd_lane_vec_real[0]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*0)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*0)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[1]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*1)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*1)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[2]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*2)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*2)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[3]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*3)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*3)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[4]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*4)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*4)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[5]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*5)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*5)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[6]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*6)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*6)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[7]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*7)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*7)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[8]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*8)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*8)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[9]}}  & o_ibp_rd_chnl[(X_W-1+(X_W*9)+Y_RD_CHNL_RD_DATA_LSB)  : ((X_W*9)+Y_RD_CHNL_RD_DATA_LSB)]  )
                      | ({X_W{rd_lane_vec_real[10]}} & o_ibp_rd_chnl[(X_W-1+(X_W*10)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*10)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[11]}} & o_ibp_rd_chnl[(X_W-1+(X_W*11)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*11)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[12]}} & o_ibp_rd_chnl[(X_W-1+(X_W*12)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*12)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[13]}} & o_ibp_rd_chnl[(X_W-1+(X_W*13)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*13)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[14]}} & o_ibp_rd_chnl[(X_W-1+(X_W*14)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*14)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[15]}} & o_ibp_rd_chnl[(X_W-1+(X_W*15)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*15)+Y_RD_CHNL_RD_DATA_LSB)] );
    end

    if((Y_W/X_W) == 8) begin:i_rd_ywxw_is_8
     assign   i_ibp_rd_chnl[(X_W-1+X_RD_CHNL_RD_DATA_LSB) : X_RD_CHNL_RD_DATA_LSB] =
                        ({X_W{rd_lane_vec_real[0]}} & o_ibp_rd_chnl[(X_W-1+(X_W*0)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*0)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[1]}} & o_ibp_rd_chnl[(X_W-1+(X_W*1)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*1)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[2]}} & o_ibp_rd_chnl[(X_W-1+(X_W*2)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*2)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[3]}} & o_ibp_rd_chnl[(X_W-1+(X_W*3)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*3)+Y_RD_CHNL_RD_DATA_LSB)] ) 
                      | ({X_W{rd_lane_vec_real[4]}} & o_ibp_rd_chnl[(X_W-1+(X_W*4)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*4)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[5]}} & o_ibp_rd_chnl[(X_W-1+(X_W*5)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*5)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[6]}} & o_ibp_rd_chnl[(X_W-1+(X_W*6)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*6)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[7]}} & o_ibp_rd_chnl[(X_W-1+(X_W*7)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*7)+Y_RD_CHNL_RD_DATA_LSB)] );
    end


    if((Y_W/X_W) == 4) begin:i_rd_ywxw_is_4
     assign   i_ibp_rd_chnl[(X_W-1+X_RD_CHNL_RD_DATA_LSB) : X_RD_CHNL_RD_DATA_LSB] =
                        ({X_W{rd_lane_vec_real[0]}} & o_ibp_rd_chnl[(X_W-1+(X_W*0)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*0)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[1]}} & o_ibp_rd_chnl[(X_W-1+(X_W*1)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*1)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[2]}} & o_ibp_rd_chnl[(X_W-1+(X_W*2)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*2)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[3]}} & o_ibp_rd_chnl[(X_W-1+(X_W*3)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*3)+Y_RD_CHNL_RD_DATA_LSB)] ) ;
    end

    if((Y_W/X_W) == 2) begin:i_rd_ywxw_is_2
     assign  i_ibp_rd_chnl[(X_W-1+X_RD_CHNL_RD_DATA_LSB) : X_RD_CHNL_RD_DATA_LSB] =
                        ({X_W{rd_lane_vec_real[0]}} & o_ibp_rd_chnl[(X_W-1+(X_W*0)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*0)+Y_RD_CHNL_RD_DATA_LSB)] )
                      | ({X_W{rd_lane_vec_real[1]}} & o_ibp_rd_chnl[(X_W-1+(X_W*1)+Y_RD_CHNL_RD_DATA_LSB) : ((X_W*1)+Y_RD_CHNL_RD_DATA_LSB)] ) ;
    end
endgenerate //}

wire pack_o_ibp_rd_chnl_accept = i_ibp_rd_chnl_accept & rd_lane_vec_real[Y_W/X_W-1];
wire npck_o_ibp_rd_chnl_accept = i_ibp_rd_chnl_accept;
wire pack_i_ibp_rd_last = o_ibp_rd_chnl[Y_RD_CHNL_RD_LAST] & rd_lane_vec_real[Y_W/X_W-1];
wire npck_i_ibp_rd_last = o_ibp_rd_chnl[Y_RD_CHNL_RD_LAST];

assign i_ibp_rd_chnl_valid =  o_ibp_rd_chnl_valid & (~rd_lane_vec_fifo_empty);
assign o_ibp_rd_chnl_accept = (rd_pack_ind_real ? pack_o_ibp_rd_chnl_accept : npck_o_ibp_rd_chnl_accept) & (~rd_lane_vec_fifo_empty);
assign i_ibp_rd_chnl[X_RD_CHNL_RD_LAST] = rd_pack_ind_real ? pack_i_ibp_rd_last : npck_i_ibp_rd_last;

// For the wdata channel: Put the data into approprate postion for narrow transfer
assign npck_o_ibp_wd_chnl_valid = i_ibp_wd_chnl_valid;
assign npck_i_ibp_wd_chnl_accept = o_ibp_wd_chnl_accept;
assign npck_o_ibp_wd_chnl[Y_WD_CHNL_LAST       ]  = i_ibp_wd_chnl[X_WD_CHNL_LAST];


// Implement 1 bit register to indicate the 1st beat wd
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg wd_1st_beat_r;
// leda NTL_CON32 on
wire wd_1st_beat_ena;
wire wd_1st_beat_set;
wire wd_1st_beat_clr;
// When the "last" beat handshaked, then set the wd_1st indication for next coming beat
assign wd_1st_beat_set = i_ibp_wd_chnl_valid & i_ibp_wd_chnl_accept & i_ibp_wd_chnl[X_WD_CHNL_LAST];
// When the "non-last" beat handshaked, then clear the wd_1st indication for next coming beat
assign wd_1st_beat_clr = i_ibp_wd_chnl_valid & i_ibp_wd_chnl_accept & (~i_ibp_wd_chnl[X_WD_CHNL_LAST]);
assign wd_1st_beat_ena = wd_1st_beat_clr | wd_1st_beat_set;
wire wd_1st_beat_nxt = wd_1st_beat_set | (~wd_1st_beat_clr);

always @(posedge clk or posedge rst_a)
begin : wd_1st_beat_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      wd_1st_beat_r       <= 1'b1;
  end
  else if (wd_1st_beat_ena == 1'b1) begin
      wd_1st_beat_r       <= wd_1st_beat_nxt;
  end
end

// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire wd_wrap_half;
assign wd_wrap_half = wd_lane_vec_fifo_empty ? wd_lane_vec_fifo_wdat[(Y_W/X_W)] : wd_lane_vec_fifo_rdat[(Y_W/X_W)];
// leda NTL_CON13A on

// Implement a counter to indicate the lane in wd channel
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg [(Y_W/X_W)-1:0] wd_lane_vec_r;
wire [(Y_W/X_W)-1:0] wd_lane_vec_nxt;
wire [(Y_W/X_W)-1:0] wd_lane_vec_nxt_raw;
// leda NTL_CON32 on
wire wd_lane_vec_ena;
wire wd_lane_vec_inc;
wire wd_lane_vec_set;
assign wd_lane_vec_inc = i_ibp_wd_chnl_valid & i_ibp_wd_chnl_accept & (~i_ibp_wd_chnl[X_WD_CHNL_LAST]);
wire wd_1st_beat_hshked = i_ibp_wd_chnl_valid & i_ibp_wd_chnl_accept & wd_1st_beat_r;
assign wd_lane_vec_set = wd_1st_beat_hshked;
assign wd_lane_vec_ena = wd_lane_vec_inc | wd_lane_vec_set;

assign wd_lane_vec_nxt_raw =
            wd_lane_vec_set
            ? (wd_lane_vec_fifo_empty ? wd_lane_vec_fifo_wdat[(Y_W/X_W)-1:0] : wd_lane_vec_fifo_rdat[(Y_W/X_W)-1:0])
            : wd_lane_vec_r[(Y_W/X_W)-1:0];

generate //{
    if((Y_W/X_W) == 4) begin:wd_lane_ywxw_4//{
assign wd_lane_vec_nxt =  wd_wrap_half ? {//  Only when 32-to-128 buses
                                             wd_lane_vec_nxt_raw[2],
                                             wd_lane_vec_nxt_raw[3],
                                             wd_lane_vec_nxt_raw[0],
                                             wd_lane_vec_nxt_raw[1]
                                             }
                              : {wd_lane_vec_nxt_raw[(Y_W/X_W)-2:0], wd_lane_vec_nxt_raw[(Y_W/X_W)-1]};
    end//}{
    else begin:wd_lane_ywxw_not_4
assign wd_lane_vec_nxt =  {wd_lane_vec_nxt_raw[(Y_W/X_W)-2:0], wd_lane_vec_nxt_raw[(Y_W/X_W)-1]};
    end//}
endgenerate //}

always @(posedge clk or posedge rst_a)
begin : wd_lane_vec_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      wd_lane_vec_r       <= {(Y_W/X_W){1'b0}}  ;
  end
  else if (wd_lane_vec_ena == 1'b1) begin
      wd_lane_vec_r       <= wd_lane_vec_nxt;
  end
end

reg  wd_pack_ind_r;
wire wd_pack_ind_nxt = (wd_lane_vec_fifo_empty ? wd_lane_vec_fifo_wdat[(Y_W/X_W)+1] : wd_lane_vec_fifo_rdat[(Y_W/X_W)+1]);

always @(posedge clk or posedge rst_a)
begin : wd_pack_ind_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      wd_pack_ind_r       <= 1'b0;
  end
  else if (wd_lane_vec_set == 1'b1) begin
      wd_pack_ind_r       <= wd_pack_ind_nxt;
  end
end

wire [(Y_W/X_W)-1:0] wd_lane_vec_real =
         wd_1st_beat_r
         ? ( wd_lane_vec_fifo_empty ? wd_lane_vec_fifo_wdat[(Y_W/X_W)-1:0] : wd_lane_vec_fifo_rdat[(Y_W/X_W)-1:0])
         : wd_lane_vec_r;

wire wd_pack_ind_real =
         wd_1st_beat_r
         ? (wd_lane_vec_fifo_empty ? wd_lane_vec_fifo_wdat[(Y_W/X_W)+1] : wd_lane_vec_fifo_rdat[(Y_W/X_W)+1])
         : wd_pack_ind_r;

genvar i;
generate //{
    for (i=0; i<(Y_W/X_W); i=i+1) begin : o_ibp_wd_chnl_gen
        // Duplicate the data at each narror transfer lane, be masked by write enalble
        assign npck_o_ibp_wd_chnl[(X_W-1+(X_W*i)+Y_WD_CHNL_DATA_LSB) : ((X_W*i)+Y_WD_CHNL_DATA_LSB)]
               = {X_WD_CHNL_DATA_W{wd_lane_vec_real[i]}} & i_ibp_wd_chnl[X_WD_CHNL_DATA_W+X_WD_CHNL_DATA_LSB-1 : X_WD_CHNL_DATA_LSB];
        assign npck_o_ibp_wd_chnl[((X_W/8)-1+((X_W/8)*i)+Y_WD_CHNL_MASK_LSB) : (((X_W/8)*i)+Y_WD_CHNL_MASK_LSB)]
               = {X_WD_CHNL_MASK_W{wd_lane_vec_real[i]}} & i_ibp_wd_chnl[X_WD_CHNL_MASK_W+X_WD_CHNL_MASK_LSB-1 : X_WD_CHNL_MASK_LSB];
    end
endgenerate //}


reg [(X_W/8)-1:0] sdb_pack_o_ibp_wmask_r [(Y_W/X_W)-2:0];
reg [X_W-1:0] sdb_pack_o_ibp_wdata_r [(Y_W/X_W)-2:0];
wire [(Y_W/X_W)-2:0] sdb_pack_o_ibp_wdata_ena;

generate //{
  for (i=0; i<(Y_W/X_W-1); i=i+1) begin : sdb_pack_o_ibp_wdata

    assign sdb_pack_o_ibp_wdata_ena[i] = wd_lane_vec_real[i] & wd_lane_vec_ena;

    always @(posedge clk or posedge rst_a)
    begin : sdb_pack_o_ibp_wdata_DFFEAR_PROC
      if (rst_a == 1'b1) begin
          sdb_pack_o_ibp_wdata_r[i]       <= {X_W{1'b0}}  ;
          sdb_pack_o_ibp_wmask_r[i]       <= {X_W/8{1'b0}}  ;
      end
      else if (sdb_pack_o_ibp_wdata_ena[i] == 1'b1) begin
          sdb_pack_o_ibp_wdata_r[i]       <= i_ibp_wd_chnl[X_WD_CHNL_DATA_W+X_WD_CHNL_DATA_LSB-1 : X_WD_CHNL_DATA_LSB];
          sdb_pack_o_ibp_wmask_r[i]       <= i_ibp_wd_chnl[X_WD_CHNL_MASK_W+X_WD_CHNL_MASK_LSB-1 : X_WD_CHNL_MASK_LSB];
      end
    end

    assign pack_o_ibp_wd_chnl[(X_W-1+(X_W*i)+Y_WD_CHNL_DATA_LSB) : ((X_W*i)+Y_WD_CHNL_DATA_LSB)]
               = sdb_pack_o_ibp_wdata_r[i];
    assign pack_o_ibp_wd_chnl[((X_W/8)-1+((X_W/8)*i)+Y_WD_CHNL_MASK_LSB) : (((X_W/8)*i)+Y_WD_CHNL_MASK_LSB)]
               = sdb_pack_o_ibp_wmask_r[i];

  end

  assign pack_o_ibp_wd_chnl[(X_W-1+(X_W*(Y_W/X_W-1))+Y_WD_CHNL_DATA_LSB) : ((X_W*(Y_W/X_W-1))+Y_WD_CHNL_DATA_LSB)]
               = i_ibp_wd_chnl[X_WD_CHNL_DATA_W+X_WD_CHNL_DATA_LSB-1 : X_WD_CHNL_DATA_LSB];
  assign pack_o_ibp_wd_chnl[((X_W/8)-1+((X_W/8)*(Y_W/X_W-1))+Y_WD_CHNL_MASK_LSB) : (((X_W/8)*(Y_W/X_W-1))+Y_WD_CHNL_MASK_LSB)]
               = i_ibp_wd_chnl[X_WD_CHNL_MASK_W+X_WD_CHNL_MASK_LSB-1 : X_WD_CHNL_MASK_LSB];

endgenerate //}

assign pack_o_ibp_wd_chnl[Y_WD_CHNL_LAST       ]  = i_ibp_wd_chnl[X_WD_CHNL_LAST];
assign pack_o_ibp_wd_chnl_valid = i_ibp_wd_chnl_valid & wd_lane_vec_real[(Y_W/X_W-1)];
assign pack_i_ibp_wd_chnl_accept = wd_lane_vec_real[(Y_W/X_W-1)] ? o_ibp_wd_chnl_accept : 1'b1;

wire i_ibp_cmd_wait_wd = (~wd_lane_vec_fifo_empty) | i_ibp_cmd_chnl_accept;
assign o_ibp_wd_chnl = (wd_pack_ind_real ?  pack_o_ibp_wd_chnl : npck_o_ibp_wd_chnl);
assign o_ibp_wd_chnl_valid = (wd_pack_ind_real ?  pack_o_ibp_wd_chnl_valid : npck_o_ibp_wd_chnl_valid) & i_ibp_cmd_wait_wd;
assign i_ibp_wd_chnl_accept = (wd_pack_ind_real ? pack_i_ibp_wd_chnl_accept : npck_i_ibp_wd_chnl_accept ) & i_ibp_cmd_wait_wd;


endmodule // mss_bus_switch_ibpn2ibpw
