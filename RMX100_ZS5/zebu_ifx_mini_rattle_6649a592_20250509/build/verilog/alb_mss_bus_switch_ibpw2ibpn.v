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
//  ###   ######  ######    #####    ###   ######  ######
//   #    #     # #     #  #     #    #    #     # #     #
//   #    #     # #     #        #    #    #     # #     #
//   #    ######  ######    #####     #    ######  ######
//   #    #     # #        #          #    #     # #
//   #    #     # #        #          #    #     # #
//  ###   ######  #        #######   ###   ######  #
//
// ===========================================================================
//
// Description:
//  Verilog module to support the IBP data width conversion from wide to narrow
//  The IBP is standard IBP, it have some constraints:
//    * input IBP no-narrow transfer supported for burst mode
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"


module mss_bus_switch_ibpw2ibpn
  #(

    parameter BYPBUF_WD_CHNL      = 0,
    parameter SPLT_FIFO_DEPTH      = 8,
    parameter X_W = 64, // only can be 32,64,128
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
    parameter X_WD_CHNL_DATA_W          = 64    ,
    parameter X_WD_CHNL_MASK_LSB        = 65    ,
    parameter X_WD_CHNL_MASK_W          = 8     ,
    parameter X_WD_CHNL_W               = 73    ,

    parameter X_RD_CHNL_ERR_RD          = 0     ,
    parameter X_RD_CHNL_RD_LAST         = 1     ,
    parameter X_RD_CHNL_RD_EXCL_OK      = 2     ,
    parameter X_RD_CHNL_RD_DATA_LSB     = 3     ,
    parameter X_RD_CHNL_RD_DATA_W       = 64    ,
    parameter X_RD_CHNL_W               = 67    ,

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

  input                         clk,  // clock signal
  input                         rst_a // reset signal
  );


// The IBP protocol require wr_accept cannot proceed the cmd_accept,
// so means wr_accept can only get asserted after some IBP write
// command have passed from command channel indicated by
// "ibp_cmd_wait_wd".
wire wd_splt_info_fifo_empty;
wire i_ibp_cmd_wait_wd = (~wd_splt_info_fifo_empty) | i_ibp_cmd_chnl_accept;
wire i_ibp_wd_chnl_valid_pre;
wire i_ibp_wd_chnl_accept_pre;
assign i_ibp_wd_chnl_valid_pre = i_ibp_wd_chnl_valid & i_ibp_cmd_wait_wd;
assign i_ibp_wd_chnl_accept = i_ibp_wd_chnl_accept_pre & i_ibp_cmd_wait_wd;
wire i_i_ibp_wd_chnl_valid;
wire i_i_ibp_wd_chnl_accept;
wire [X_WD_CHNL_W-1:0] i_i_ibp_wd_chnl;

generate //{
    if(BYPBUF_WD_CHNL == 1) begin: bypbuf_wd_chnl_gen
mss_bus_switch_bypbuf # (
  .BUF_DEPTH(1),
  .BUF_WIDTH(X_WD_CHNL_W)
) ibp_wd_chnl_bypbuf (
  .i_ready    (i_ibp_wd_chnl_accept_pre),
  .i_valid    (i_ibp_wd_chnl_valid_pre),
  .i_data     (i_ibp_wd_chnl),
  .o_ready    (i_i_ibp_wd_chnl_accept),
  .o_valid    (i_i_ibp_wd_chnl_valid),
  .o_data     (i_i_ibp_wd_chnl),
  .clk        (clk  ),
  .rst_a      (rst_a)
  );

    end
    else begin: no_bypbuf_wd_chnl_gen
assign i_i_ibp_wd_chnl          = i_ibp_wd_chnl;
assign i_i_ibp_wd_chnl_valid    = i_ibp_wd_chnl_valid_pre;
assign i_ibp_wd_chnl_accept_pre = i_i_ibp_wd_chnl_accept;
    end
endgenerate



// Convert from larger width to smaller width:

assign o_ibp_cmd_chnl_rgon = i_ibp_cmd_chnl_rgon;
assign o_ibp_cmd_chnl_user = i_ibp_cmd_chnl_user;

// For the cmd channel: Directly convert the command attribute
wire wd_splt_info_fifo_full;
wire rd_splt_info_fifo_full;
assign o_ibp_cmd_chnl_valid = i_ibp_cmd_chnl_valid
                          & (~wd_splt_info_fifo_full)
                          & (~rd_splt_info_fifo_full);
assign i_ibp_cmd_chnl_accept = o_ibp_cmd_chnl_accept
                          & (~wd_splt_info_fifo_full)
                          & (~rd_splt_info_fifo_full);

// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire [X_CMD_CHNL_ADDR_W      -1 : 0] i_ibp_cmd_addr;
// leda NTL_CON13A on
wire [X_CMD_CHNL_DATA_SIZE_W -1 : 0] i_ibp_cmd_data_size ;
wire [X_CMD_CHNL_BURST_SIZE_W-1 : 0] i_ibp_cmd_burst_size;
reg  [Y_CMD_CHNL_DATA_SIZE_W -1 : 0] o_ibp_cmd_data_size ;
reg  [Y_CMD_CHNL_BURST_SIZE_W-1 : 0] o_ibp_cmd_burst_size;

assign i_ibp_cmd_addr  = i_ibp_cmd_chnl[X_CMD_CHNL_ADDR_W +X_CMD_CHNL_ADDR_LSB -1 : X_CMD_CHNL_ADDR_LSB ];
assign i_ibp_cmd_data_size  = i_ibp_cmd_chnl[X_CMD_CHNL_DATA_SIZE_W +X_CMD_CHNL_DATA_SIZE_LSB -1 : X_CMD_CHNL_DATA_SIZE_LSB ];
assign i_ibp_cmd_burst_size = i_ibp_cmd_chnl[X_CMD_CHNL_BURST_SIZE_W+X_CMD_CHNL_BURST_SIZE_LSB-1 : X_CMD_CHNL_BURST_SIZE_LSB];

// The split scheme:
// * For transcation with data size equal to X_W, split to more (X_W/Y_W times of) beats of burst transaction
// * Otherwise, For single-beat transaction with data size wider than Y_W but not equal to
//   X_W, this is only happened when X_W == 128 (datasize == 64), Y_W == 32, split to data_size/Y_W (=2) beats of burst transaction
// * Otherwise, For single-beat transaction with data size narrower than or equal to Y_W, just still use one beat of transaction
wire i_splt_case_1 ;
wire i_splt_case_2 ;
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire i_splt_case_3 ;
// leda NTL_CON13A on
assign i_splt_case_1 = ((1<<i_ibp_cmd_data_size) == (X_W/8));
assign i_splt_case_2 = (~i_splt_case_1) & ((1<<i_ibp_cmd_data_size) > (Y_W/8));
assign i_splt_case_3 = (~i_splt_case_1) & (~i_splt_case_2);

//assign o_ibp_cmd_burst_size =
//     i_splt_case_1 ?  (((X_W/Y_W) == 4) ? ((i_ibp_cmd_burst_size << 2) | 3) : ((i_ibp_cmd_burst_size << 1) | 1 )) :
//     i_splt_case_2 ?  ((i_ibp_cmd_burst_size << 1) | 1) :
//                    {X_CMD_CHNL_BURST_SIZE_W{1'b0}};

always @* begin
    if(i_splt_case_1) begin
        if((X_W/Y_W) == 16)
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 4) | 15);
        else if((X_W/Y_W) == 8)
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 3) | 7);
        else if((X_W/Y_W) == 4)
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 2) | 3);
        else
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 1) | 1 );
    end
    else if(i_splt_case_2) begin
        if((1<<i_ibp_cmd_data_size) == Y_W/4)
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 1) | 1);   //data size = 2*Y_W
        else if((1<<i_ibp_cmd_data_size) == Y_W/2)
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 2) | 3);   //data size = 4*Y_W
        else if((1<<i_ibp_cmd_data_size) == Y_W)
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 3) | 7);   //data size = 8*Y_W
        else
            o_ibp_cmd_burst_size = ((i_ibp_cmd_burst_size << 1) | 1);
    end
    else
        o_ibp_cmd_burst_size = {X_CMD_CHNL_BURST_SIZE_W{1'b0}};
end

// leda B_3208_A off
// LMD: Unequal length  operand in conditional expression
// LJ: to easy the coding here

//assign o_ibp_cmd_data_size =
//     i_splt_case_1 ?  ((Y_W == 64) ? 3 : (Y_W == 32) ? 2 : 0) :
//     i_splt_case_2 ?  2 :
//                    i_ibp_cmd_data_size;

always @* begin
    if(i_splt_case_1 || i_splt_case_2) begin
        if(Y_W == 256)
            o_ibp_cmd_data_size = 'd5;
        else if(Y_W == 128)
            o_ibp_cmd_data_size = 'd4;
        else if(Y_W == 64)
            o_ibp_cmd_data_size = 'd3;
        else if(Y_W == 32)
            o_ibp_cmd_data_size = 'd2;
        else
            o_ibp_cmd_data_size = 'd0;
    end
    else begin 
        o_ibp_cmd_data_size = i_ibp_cmd_data_size;
    end
end


// leda B_3208_A on

// The splt vector to indicator the needed wdata portion, e.g, if X_W/Y_W == 4, then
// 4'b0001 indicate X bus's 1st portion ( each portion is Y_W wide) is wanted at the 1st beat
//
// leda B_3208 off
// LMD: Unequal length  operand in conditional expression
// LJ: to easy the coding here
// leda B_3208_A off
// LMD: Unequal length  operand in conditional expression
// LJ: to easy the coding here
// leda B_3200 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk

reg [3:0] size_mask;

always @*
    if((1<<i_ibp_cmd_data_size) == Y_W/8)
        size_mask = 4'b1111;
    else if((1<<i_ibp_cmd_data_size) == Y_W/4)
        size_mask = 4'b1110;
    else if((1<<i_ibp_cmd_data_size) == Y_W/2)
        size_mask = 4'b1100;
    else if((1<<i_ibp_cmd_data_size) == Y_W)
        size_mask = 4'b1000;
    else
        size_mask = 4'b0;

wire [(X_W/Y_W)-1:0] splt_1st_lane =
     i_splt_case_1 ?  {{(X_W/Y_W)-1{1'b0}}, 1'b1} :
     // Because only when X_W == 128, Y_W==32, and X-data_size is 64 for case2, so for
     // data_size == 64, we need to check the addr[3]
     i_splt_case_2 ? (
     ((Y_W == 32)  & (X_W == 512)) ?  (1<<(i_ibp_cmd_addr[5:2] & size_mask[3:0])) :
     ((Y_W == 64)  & (X_W == 512)) ?  (1<<(i_ibp_cmd_addr[5:3] & size_mask[2:0])) :
     ((Y_W == 128) & (X_W == 512)) ?  (1<<(i_ibp_cmd_addr[5:4] & size_mask[1:0])) :
     ((Y_W == 32)  & (X_W == 256)) ?  (1<<(i_ibp_cmd_addr[4:2] & size_mask[2:0])) :
     ((Y_W == 64)  & (X_W == 256)) ?  (1<<(i_ibp_cmd_addr[4:3] & size_mask[1:0])) :
     ((Y_W == 32)  & (X_W == 128)) ?  (1<<(i_ibp_cmd_addr[3:2] & size_mask[1:0])) : 0) :
     ((Y_W == 256) & (X_W == 512)) ?  (1<<i_ibp_cmd_addr[5])   :
     ((Y_W == 128) & (X_W == 512)) ?  (1<<i_ibp_cmd_addr[5:4]) :
     ((Y_W == 64)  & (X_W == 512)) ?  (1<<i_ibp_cmd_addr[5:3]) :
     ((Y_W == 32)  & (X_W == 512)) ?  (1<<i_ibp_cmd_addr[5:2]) :
     ((Y_W == 128) & (X_W == 256)) ?  (1<<i_ibp_cmd_addr[4])   :
     ((Y_W == 64)  & (X_W == 256)) ?  (1<<i_ibp_cmd_addr[4:3]) :
     ((Y_W == 32)  & (X_W == 256)) ?  (1<<i_ibp_cmd_addr[4:2]) :
     ((Y_W == 64)  & (X_W == 128)) ?  (1<<i_ibp_cmd_addr[3])   :
     ((Y_W == 32)  & (X_W == 128)) ?  (1<<i_ibp_cmd_addr[3:2]) :
     ((Y_W == 32)  & (X_W == 64))  ?  (1<<i_ibp_cmd_addr[2])  : 0;
// leda B_3200 on
// leda BTTF_D002 on
// leda B_3208_A on
// leda B_3208 on

// The o-ibp address generation is tricky
//   In case2: o_ibp_cmd_addr just same as i_ibp_cmd_addr
//   In case3: o_ibp_cmd_addr just same as i_ibp_cmd_addr
//   But In case1: The i_ibp is full-datasize, so the output IBP will be a burst as X_W/Y_W length,
//      If the starting address i_ibp_cmd_addr is in the first Y_W portion of X_W, then everything it fine
//      If the starting address i_ibp_cmd_addr is not in the first Y_W portion of X_W, then We must forcely make o_ibp_cmd_addr fell in 1st portion
//         But to notify the downstream IBP (such as SCU DMA) this is a empty beat, we should forcely make the o_ibp_cmd_addr unaligned (with the Y_W)
//
wire [X_CMD_CHNL_ADDR_W-1:0] i_ibp_cmd_addr_forged1;

wire n_addr_start_w;
generate //{
    if(Y_W == 32) begin:yw_is_32
        if(X_W == 64) begin:yw32_xw64
          assign n_addr_start_w = ~(i_ibp_cmd_addr[2]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:3] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:3];
          assign i_ibp_cmd_addr_forged1[2] = 1'b0;
          assign i_ibp_cmd_addr_forged1[1:0] = 2'b1;
        end
        if(X_W == 128) begin:yw32_xw128
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[3:2]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:4] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:4];
          assign i_ibp_cmd_addr_forged1[3:2] = 2'b0;
          assign i_ibp_cmd_addr_forged1[1:0] = 2'b1;
        end
        if(X_W == 256) begin:yw32_xw256
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[4:2]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:5] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:5];
          assign i_ibp_cmd_addr_forged1[4:2] = 3'b0;
          assign i_ibp_cmd_addr_forged1[1:0] = 2'b1;
        end
        if(X_W == 512) begin:yw32_xw512
          assign n_addr_start_w = ~(|i_ibp_cmd_addr[5:2]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:6] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:6];
          assign i_ibp_cmd_addr_forged1[5:2] = 4'b0;
          assign i_ibp_cmd_addr_forged1[1:0] = 2'b1;
        end
    end
    if(Y_W == 64) begin:yw_is_64
        if(X_W == 128) begin:yw64_xw128
          assign n_addr_start_w = ~(i_ibp_cmd_addr[3]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:4] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:4];
          assign i_ibp_cmd_addr_forged1[3] = 1'b0;
          assign i_ibp_cmd_addr_forged1[2:0] = 3'b1;
        end
        if(X_W == 256) begin:yw64_xw256
          assign n_addr_start_w = ~(i_ibp_cmd_addr[4:3]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:5] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:5];
          assign i_ibp_cmd_addr_forged1[4:3] = 2'b0;
          assign i_ibp_cmd_addr_forged1[2:0] = 3'b1;
        end
        if(X_W == 512) begin:yw64_xw512
          assign n_addr_start_w = ~(i_ibp_cmd_addr[5:3]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:6] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:6];
          assign i_ibp_cmd_addr_forged1[5:3] = 3'b0;
          assign i_ibp_cmd_addr_forged1[2:0] = 3'b1;
        end
    end
    if(Y_W == 128) begin:yw_is_128
        if(X_W == 256) begin:yw128_xw256
          assign n_addr_start_w = ~(i_ibp_cmd_addr[4]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:5] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:5];
          assign i_ibp_cmd_addr_forged1[4] = 1'b0;
          assign i_ibp_cmd_addr_forged1[3:0] = 4'b1;
        end
        if(X_W == 512) begin:yw128_xw512
          assign n_addr_start_w = ~(i_ibp_cmd_addr[5:4]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:6] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:6];
          assign i_ibp_cmd_addr_forged1[5:4] = 2'b0;
          assign i_ibp_cmd_addr_forged1[3:0] = 4'b1;
        end
    end
    if(Y_W == 256) begin:yw_is_256
        if(X_W == 512) begin:yw256_xw512
          assign n_addr_start_w = ~(i_ibp_cmd_addr[5]);
          assign i_ibp_cmd_addr_forged1[X_CMD_CHNL_ADDR_W-1:6] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:6];
          assign i_ibp_cmd_addr_forged1[5] = 2'b0;
          assign i_ibp_cmd_addr_forged1[4:0] = 5'b1;
        end
    end

endgenerate //}

wire n_addr_start_case_2 = ~(i_ibp_cmd_addr[2]);
wire [Y_CMD_CHNL_ADDR_W-1:0] i_ibp_cmd_addr_forged2;
assign i_ibp_cmd_addr_forged2[X_CMD_CHNL_ADDR_W-1:3] =  i_ibp_cmd_addr[X_CMD_CHNL_ADDR_W-1:3];
assign i_ibp_cmd_addr_forged2[2] = 1'b0;
assign i_ibp_cmd_addr_forged2[1:0] = 2'b1;
wire [Y_CMD_CHNL_ADDR_W-1:0] o_ibp_cmd_addr = (i_splt_case_1 & (~n_addr_start_w)) ?  i_ibp_cmd_addr_forged1
                                             //: (i_splt_case_2 & (~n_addr_start_case_2)) ?  i_ibp_cmd_addr_forged2
                                             : i_ibp_cmd_addr;

assign o_ibp_cmd_chnl[Y_CMD_CHNL_READ      ]                                                           = i_ibp_cmd_chnl[X_CMD_CHNL_READ      ]                                                       ;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_WRAP      ]                                                           = i_ibp_cmd_chnl[X_CMD_CHNL_WRAP      ]                                                       ;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_ADDR_W      +Y_CMD_CHNL_ADDR_LSB      -1 : Y_CMD_CHNL_ADDR_LSB      ] = o_ibp_cmd_addr;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_DATA_SIZE_W +Y_CMD_CHNL_DATA_SIZE_LSB -1 : Y_CMD_CHNL_DATA_SIZE_LSB ] = o_ibp_cmd_data_size;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_BURST_SIZE_W+Y_CMD_CHNL_BURST_SIZE_LSB-1 : Y_CMD_CHNL_BURST_SIZE_LSB] = o_ibp_cmd_burst_size;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_PROT_W+Y_CMD_CHNL_PROT_LSB-1 : Y_CMD_CHNL_PROT_LSB]                   = i_ibp_cmd_chnl[X_CMD_CHNL_PROT_W+X_CMD_CHNL_PROT_LSB-1 : X_CMD_CHNL_PROT_LSB]                   ;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_CACHE_W+Y_CMD_CHNL_CACHE_LSB-1 : Y_CMD_CHNL_CACHE_LSB]                = i_ibp_cmd_chnl[X_CMD_CHNL_CACHE_W+X_CMD_CHNL_CACHE_LSB-1 : X_CMD_CHNL_CACHE_LSB]                ;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_LOCK      ]                                                           = i_ibp_cmd_chnl[X_CMD_CHNL_LOCK      ]                                                       ;
assign o_ibp_cmd_chnl[Y_CMD_CHNL_EXCL      ]                                                           = i_ibp_cmd_chnl[X_CMD_CHNL_EXCL      ]                                                       ;

// The wd_splt_info_fifo is just store the "splt_1st_lane" indication and the "case1/2/3" info, so that
// when the wdata is coming from IBP, it know its splt info
wire wd_splt_info_fifo_wen  ;
wire wd_splt_info_fifo_ren  ;
wire wd_splt_info_fifo_wen_raw  ;
wire wd_splt_info_fifo_ren_raw  ;
wire byp_wd_splt_info_fifo = wd_splt_info_fifo_empty & wd_splt_info_fifo_wen_raw & wd_splt_info_fifo_ren_raw;


wire [(X_W/Y_W)-1+2+4:0] wd_splt_info_fifo_wdat ;
wire [(X_W/Y_W)-1+2+4:0] wd_splt_info_fifo_rdat ;
// Write when IBP cmd channel is handshaked
assign wd_splt_info_fifo_wen_raw  = i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & (~i_ibp_cmd_chnl[X_CMD_CHNL_READ]);
assign wd_splt_info_fifo_wen = wd_splt_info_fifo_wen_raw & (~byp_wd_splt_info_fifo);
wire [1:0] i_splt_case;
assign i_splt_case = (i_splt_case_1 ? 2'd1 : i_splt_case_2 ? 2'd2 : 2'd3);
assign wd_splt_info_fifo_wdat  = {i_ibp_cmd_data_size, splt_1st_lane, i_splt_case};

// Read when IBP wd channel is handshaked (last)
assign wd_splt_info_fifo_ren_raw  = i_i_ibp_wd_chnl_valid & i_i_ibp_wd_chnl_accept & i_i_ibp_wd_chnl[X_WD_CHNL_LAST];
assign wd_splt_info_fifo_ren = wd_splt_info_fifo_ren_raw & (~byp_wd_splt_info_fifo);

wire wd_splt_info_fifo_i_valid;
wire wd_splt_info_fifo_o_valid;
wire wd_splt_info_fifo_i_ready;
wire wd_splt_info_fifo_o_ready;
assign wd_splt_info_fifo_i_valid = wd_splt_info_fifo_wen;
assign wd_splt_info_fifo_full    = (~wd_splt_info_fifo_i_ready);
assign wd_splt_info_fifo_o_ready = wd_splt_info_fifo_ren;
assign wd_splt_info_fifo_empty   = (~wd_splt_info_fifo_o_valid);

mss_bus_switch_fifo # (
  .FIFO_WIDTH(((X_W/Y_W)+2+4)),
  .FIFO_DEPTH(SPLT_FIFO_DEPTH),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) wd_splt_info_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (wd_splt_info_fifo_i_valid),
  .i_ready   (wd_splt_info_fifo_i_ready),
  .o_valid   (wd_splt_info_fifo_o_valid),
  .o_ready   (wd_splt_info_fifo_o_ready),
  .i_data    (wd_splt_info_fifo_wdat ),
  .o_data    (wd_splt_info_fifo_rdat ),
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

// The rd_splt_info_fifo is just store the "rd_splt" indication, so that
// when the rdata is coming from IBP, it know its rd lane
wire rd_splt_info_fifo_wen  ;
wire rd_splt_info_fifo_ren  ;
wire [(X_W/Y_W)-1+2+4:0] rd_splt_info_fifo_wdat ;
wire [(X_W/Y_W)-1+2+4:0] rd_splt_info_fifo_rdat ;
wire rd_splt_info_fifo_empty;
// Write when IBP cmd channel is handshaked
assign rd_splt_info_fifo_wen  = i_ibp_cmd_chnl_valid & i_ibp_cmd_chnl_accept & i_ibp_cmd_chnl[X_CMD_CHNL_READ];
assign rd_splt_info_fifo_wdat = wd_splt_info_fifo_wdat;
// Read when IBP rd channel is handshaked (last)
assign rd_splt_info_fifo_ren  = i_ibp_rd_chnl_valid & i_ibp_rd_chnl_accept & i_ibp_rd_chnl[X_RD_CHNL_RD_LAST];

wire rd_splt_info_fifo_i_valid;
wire rd_splt_info_fifo_o_valid;
wire rd_splt_info_fifo_i_ready;
wire rd_splt_info_fifo_o_ready;
assign rd_splt_info_fifo_i_valid = rd_splt_info_fifo_wen;
assign rd_splt_info_fifo_full    = (~rd_splt_info_fifo_i_ready);
assign rd_splt_info_fifo_o_ready = rd_splt_info_fifo_ren;
assign rd_splt_info_fifo_empty   = (~rd_splt_info_fifo_o_valid);

mss_bus_switch_fifo # (
  .FIFO_WIDTH(((X_W/Y_W)+2+4)),
  .FIFO_DEPTH(SPLT_FIFO_DEPTH),
  .IN_OUT_MWHILE (0),
  .O_SUPPORT_RTIO(0),
  .I_SUPPORT_RTIO(0)
) rd_splt_info_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (rd_splt_info_fifo_i_valid),
  .i_ready   (rd_splt_info_fifo_i_ready),
  .o_valid   (rd_splt_info_fifo_o_valid),
  .o_ready   (rd_splt_info_fifo_o_ready),
  .i_data    (rd_splt_info_fifo_wdat ),
  .o_data    (rd_splt_info_fifo_rdat ),
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
wire [1:0] rd_splt_case;
wire rd_splt_case_1;
wire rd_splt_case_2;
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire rd_splt_case_3;
// leda NTL_CON13A on
wire [(X_W/Y_W)-1:0] rd_splt_1st_lane;
wire [X_W-1: 0] i_ibp_rd_data;
wire [Y_W-1: 0] o_ibp_rd_data;
wire [3:0] rd_data_size;
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg [Y_W-1:0] sdb_ibp_rd_data_r[((X_W/Y_W)-2) : 0];
reg [((X_W/Y_W)-2) : 0]sdb_ibp_err_rd_r;
reg [((X_W/Y_W)-2) : 0]sdb_ibp_rd_excl_ok_r;
wire [(X_W/Y_W)-1:0] rd_splt_lane_real;

// leda NTL_CON32 on

assign rd_splt_case = rd_splt_info_fifo_rdat[1:0];
assign rd_splt_case_1 = (rd_splt_case == 2'd1);
assign rd_splt_case_2 = (rd_splt_case == 2'd2);
assign rd_splt_case_3 = (rd_splt_case == 2'd3);
assign rd_splt_1st_lane = rd_splt_info_fifo_rdat [(X_W/Y_W)-1+2:2];
assign rd_data_size = rd_splt_info_fifo_rdat [(X_W/Y_W)-1+2+4:(X_W/Y_W)-1+2+1];

assign o_ibp_rd_data = o_ibp_rd_chnl[(Y_W-1+Y_RD_CHNL_RD_DATA_LSB) : Y_RD_CHNL_RD_DATA_LSB];

/*generate //{
    if((X_W/Y_W) == 4) begin: rd_xw_div_yw_is_4
    assign i_ibp_rd_data = rd_splt_case_1 ?
                                 (
                                           {o_ibp_rd_data, sdb_ibp_rd_data_r[2], sdb_ibp_rd_data_r[1], sdb_ibp_rd_data_r[0]}
                                 ) :
                           rd_splt_case_2 ?
                                 (
                                           (rd_splt_1st_lane == 4'b0001 ) ?
                                                        {o_ibp_rd_data, sdb_ibp_rd_data_r[0], o_ibp_rd_data, sdb_ibp_rd_data_r[0]}
                                                      : {o_ibp_rd_data, sdb_ibp_rd_data_r[2], o_ibp_rd_data, sdb_ibp_rd_data_r[2]}
                                 ) :
                                 (
                                           {4{o_ibp_rd_data}}
                                 ) ;
    end
    if((X_W/Y_W) == 2) begin: rd_xw_div_yw_is_2
    assign i_ibp_rd_data = rd_splt_case_1 ?
                                 (
                                           {o_ibp_rd_data, sdb_ibp_rd_data_r[0]}
                                 ) :
                                 (
                                           {2{o_ibp_rd_data}}
                                 ) ;
    end
endgenerate //}
*/

generate //{
    if((X_W/Y_W) == 16) begin: rd_xw_div_yw_is_16
    assign i_ibp_rd_data = rd_splt_case_1 ?
                                 (
                                        {o_ibp_rd_data, sdb_ibp_rd_data_r[14], sdb_ibp_rd_data_r[13], sdb_ibp_rd_data_r[12], sdb_ibp_rd_data_r[11], sdb_ibp_rd_data_r[10],sdb_ibp_rd_data_r[9], sdb_ibp_rd_data_r[8], sdb_ibp_rd_data_r[7], sdb_ibp_rd_data_r[6], sdb_ibp_rd_data_r[5], sdb_ibp_rd_data_r[4], sdb_ibp_rd_data_r[3], sdb_ibp_rd_data_r[2], sdb_ibp_rd_data_r[1], sdb_ibp_rd_data_r[0]}
                                 ) :
                           rd_splt_case_2 ?
                                 (   //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[0]}}  :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[2]}}  :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[4]}}  :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[6]}}  :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[8]}}  :
((rd_splt_1st_lane == 'h400 )&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[10]}}  :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[12]}}  :
((rd_splt_1st_lane == 'h4000)&&((1<<rd_data_size) == Y_W/4)) ? {8{o_ibp_rd_data, sdb_ibp_rd_data_r[14]}}  :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[2] , sdb_ibp_rd_data_r[1] , sdb_ibp_rd_data_r[0]}}  :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[6] , sdb_ibp_rd_data_r[5] , sdb_ibp_rd_data_r[4]}}  :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[10], sdb_ibp_rd_data_r[9] , sdb_ibp_rd_data_r[8]}}  :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/2)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[14], sdb_ibp_rd_data_r[13], sdb_ibp_rd_data_r[12]}} :
                                    //data size = 8*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W)) ? {2{o_ibp_rd_data, sdb_ibp_rd_data_r[6], sdb_ibp_rd_data_r[5], sdb_ibp_rd_data_r[4], sdb_ibp_rd_data_r[3], sdb_ibp_rd_data_r[2], sdb_ibp_rd_data_r[1], sdb_ibp_rd_data_r[0]}}  :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W)) ? {2{o_ibp_rd_data, sdb_ibp_rd_data_r[14], sdb_ibp_rd_data_r[13], sdb_ibp_rd_data_r[12], sdb_ibp_rd_data_r[11], sdb_ibp_rd_data_r[10],sdb_ibp_rd_data_r[9], sdb_ibp_rd_data_r[8]}} :  {16{o_ibp_rd_data}}

                                 ) :
                                 (
                                        {16{o_ibp_rd_data}}
                                 ) ;
    end

    if((X_W/Y_W) == 8) begin: rd_xw_div_yw_is_8
    assign i_ibp_rd_data = rd_splt_case_1 ?
                                 (
                                        {o_ibp_rd_data, sdb_ibp_rd_data_r[6], sdb_ibp_rd_data_r[5], sdb_ibp_rd_data_r[4], sdb_ibp_rd_data_r[3], sdb_ibp_rd_data_r[2], sdb_ibp_rd_data_r[1], sdb_ibp_rd_data_r[0]}
                                 ) :
                           rd_splt_case_2 ?
                                 (  //data size = 2*Y_W
((rd_splt_1st_lane == 'h1 )&&((1<<rd_data_size) == Y_W/4)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[0]}}  :
((rd_splt_1st_lane == 'h4 )&&((1<<rd_data_size) == Y_W/4)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[2]}}  :
((rd_splt_1st_lane == 'h10)&&((1<<rd_data_size) == Y_W/4)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[4]}}  :
((rd_splt_1st_lane == 'h40)&&((1<<rd_data_size) == Y_W/4)) ? {4{o_ibp_rd_data, sdb_ibp_rd_data_r[6]}}  :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1 )&&((1<<rd_data_size) == Y_W/2)) ? {2{o_ibp_rd_data, sdb_ibp_rd_data_r[2], sdb_ibp_rd_data_r[1], sdb_ibp_rd_data_r[0]}}  :
((rd_splt_1st_lane == 'h10)&&((1<<rd_data_size) == Y_W/2)) ? {2{o_ibp_rd_data, sdb_ibp_rd_data_r[6], sdb_ibp_rd_data_r[5], sdb_ibp_rd_data_r[4]}}  : {8{o_ibp_rd_data}}
                                    
                                 ) :
                                 (
                                        {8{o_ibp_rd_data}}
                                 ) ;
    end
    if((X_W/Y_W) == 4) begin: rd_xw_div_yw_is_4
    assign i_ibp_rd_data = rd_splt_case_1 ?
                                 (
                                           {o_ibp_rd_data, sdb_ibp_rd_data_r[2], sdb_ibp_rd_data_r[1], sdb_ibp_rd_data_r[0]}
                                 ) :
                           rd_splt_case_2 ?
                                 (
                                           (rd_splt_1st_lane == 4'b0001 ) ?
                                                        {o_ibp_rd_data, sdb_ibp_rd_data_r[0], o_ibp_rd_data, sdb_ibp_rd_data_r[0]}
                                                      : {o_ibp_rd_data, sdb_ibp_rd_data_r[2], o_ibp_rd_data, sdb_ibp_rd_data_r[2]}
                                 ) :
                                 (
                                           {4{o_ibp_rd_data}}
                                 ) ;
    end
    if((X_W/Y_W) == 2) begin: rd_xw_div_yw_is_2
    assign i_ibp_rd_data = rd_splt_case_1 ?
                                 (
                                           {o_ibp_rd_data, sdb_ibp_rd_data_r[0]}
                                 ) :
                                 (
                                           {2{o_ibp_rd_data}}
                                 ) ;
    end
endgenerate //}


wire o_ibp_err_rd = o_ibp_rd_chnl[Y_RD_CHNL_ERR_RD];
wire o_ibp_rd_excl_ok = o_ibp_rd_chnl[Y_RD_CHNL_RD_EXCL_OK];

wire i_ibp_err_rd;
wire i_ibp_rd_excl_ok;

generate //{
    if((X_W/Y_W) == 16) begin: err_rd_xw_div_yw_is_16
    assign i_ibp_err_rd = rd_splt_case_1 ?
                                 (
                                           (o_ibp_err_rd | (|sdb_ibp_err_rd_r[X_W/Y_W-2:0]))
                                 ) :
                           rd_splt_case_2 ?
                                 (  //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[0] ) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[2] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[4] ) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[6] ) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[8] ) :
((rd_splt_1st_lane == 'h400 )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[10]) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[12]) :
((rd_splt_1st_lane == 'h4000)&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[14]) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[2]  | sdb_ibp_err_rd_r[1] | sdb_ibp_err_rd_r[0] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[6]  | sdb_ibp_err_rd_r[5] | sdb_ibp_err_rd_r[4] ) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[10] | sdb_ibp_err_rd_r[9] | sdb_ibp_err_rd_r[8] ) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[14] | sdb_ibp_err_rd_r[13]| sdb_ibp_err_rd_r[12]) :
                                    //data size = 8*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | (|sdb_ibp_err_rd_r[6:0])  ) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | (|sdb_ibp_err_rd_r[14:8]) ) : o_ibp_err_rd

                                   ) :
                                 (
                                              o_ibp_err_rd
                                 ) ;
    assign i_ibp_rd_excl_ok = rd_splt_case_1 ?
                                 (
                                           (o_ibp_rd_excl_ok & (&sdb_ibp_rd_excl_ok_r[X_W/Y_W-2:0]))
                                 ) :
                           rd_splt_case_2 ?
                                 (  //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[0] ) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[2] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[4] ) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[6] ) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[8] ) :
((rd_splt_1st_lane == 'h400 )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[10]) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[12]) :
((rd_splt_1st_lane == 'h4000)&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[14]) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[2]  & sdb_ibp_rd_excl_ok_r[1] & sdb_ibp_rd_excl_ok_r[0] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[6]  & sdb_ibp_rd_excl_ok_r[5] & sdb_ibp_rd_excl_ok_r[4] ) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[10] & sdb_ibp_rd_excl_ok_r[9] & sdb_ibp_rd_excl_ok_r[8] ) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[14] & sdb_ibp_rd_excl_ok_r[13]& sdb_ibp_rd_excl_ok_r[12]) :
                                    //data size = 8*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & (&sdb_ibp_rd_excl_ok_r[6:0])  ) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & (&sdb_ibp_rd_excl_ok_r[14:8]) ) : o_ibp_rd_excl_ok 

                                    ) :
                                 (
                                              o_ibp_rd_excl_ok
                                 ) ;

    assign i_ibp_rd_chnl_valid = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                     (rd_splt_lane_real[(X_W/Y_W)-1]  & o_ibp_rd_chnl_valid)
                             ) :
                       rd_splt_case_2 ?
                             (      //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[1]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[3]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[5]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[7]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[9]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h400 )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[11] & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[13] & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h4000)&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[15] & o_ibp_rd_chnl_valid) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[3]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[7]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[11] & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[15] & o_ibp_rd_chnl_valid) :
                                    //data size = 8*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[7]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[15] & o_ibp_rd_chnl_valid) : o_ibp_rd_chnl_valid 

                             ) :
                             (
                                     o_ibp_rd_chnl_valid
                             ) );
                             
    assign o_ibp_rd_chnl_accept = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                        (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                       rd_splt_case_2 ?
                             (      //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[1] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[3] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[5] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[7] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[9] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h400 )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[11]? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[13]? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h4000)&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[15]? i_ibp_rd_chnl_accept : 1'b1) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[3] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[7] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[11]? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h1000)&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[15]? i_ibp_rd_chnl_accept : 1'b1) :
                                    //data size = 8*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[7] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h100 )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[15]? i_ibp_rd_chnl_accept : 1'b1) : i_ibp_rd_chnl_accept 

                             ) :
                             (
                                     i_ibp_rd_chnl_accept
                             ));
                         end


    if((X_W/Y_W) == 8) begin: err_rd_xw_div_yw_is_8
    assign i_ibp_err_rd = rd_splt_case_1 ?
                                 (
                                           (o_ibp_err_rd | (|sdb_ibp_err_rd_r[X_W/Y_W-2:0]))
                                 ) :
                           rd_splt_case_2 ?
                                 (  //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[0] ) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[2] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[4] ) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[6] ) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[2]  | sdb_ibp_err_rd_r[1] | sdb_ibp_err_rd_r[0] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_err_rd | sdb_ibp_err_rd_r[6]  | sdb_ibp_err_rd_r[5] | sdb_ibp_err_rd_r[4] ) : o_ibp_err_rd
                                    
                                    ) :
                                 (
                                              o_ibp_err_rd
                                 ) ;
    assign i_ibp_rd_excl_ok = rd_splt_case_1 ?
                                 (
                                           (o_ibp_rd_excl_ok & (&sdb_ibp_rd_excl_ok_r[X_W/Y_W-2:0]))
                                 ) :
                           rd_splt_case_2 ?
                                 (  //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[0] ) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[2] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[4] ) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[6] ) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[2]  & sdb_ibp_rd_excl_ok_r[1] & sdb_ibp_rd_excl_ok_r[0] ) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[6]  & sdb_ibp_rd_excl_ok_r[5] & sdb_ibp_rd_excl_ok_r[4] ) : o_ibp_rd_excl_ok

                                 ) :
                                 (
                                              o_ibp_rd_excl_ok
                                 ) ;

    assign i_ibp_rd_chnl_valid = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                     (rd_splt_lane_real[(X_W/Y_W)-1]  & o_ibp_rd_chnl_valid)
                             ) :
                       rd_splt_case_2 ?
                             (      //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[1]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[3]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[5]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[7]  & o_ibp_rd_chnl_valid) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[3]  & o_ibp_rd_chnl_valid) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[7]  & o_ibp_rd_chnl_valid) : o_ibp_rd_chnl_valid
                                    
                             ) :
                             (
                                     o_ibp_rd_chnl_valid
                             ) );
                             
    assign o_ibp_rd_chnl_accept = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                        (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                       rd_splt_case_2 ?
                             (      //data size = 2*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[1] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h4   )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[3] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[5] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h40  )&&((1<<rd_data_size) == Y_W/4)) ? (rd_splt_lane_real[7] ? i_ibp_rd_chnl_accept : 1'b1) :
                                    //data size = 4*Y_W
((rd_splt_1st_lane == 'h1   )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[3] ? i_ibp_rd_chnl_accept : 1'b1) :
((rd_splt_1st_lane == 'h10  )&&((1<<rd_data_size) == Y_W/2)) ? (rd_splt_lane_real[7] ? i_ibp_rd_chnl_accept : 1'b1) : i_ibp_rd_chnl_accept

                             ) :
                             (
                                     i_ibp_rd_chnl_accept
                             ));

    end

    if((X_W/Y_W) == 4) begin: err_rd_xw_div_yw_is_4
    assign i_ibp_err_rd = rd_splt_case_1 ?
                                 (
                                           (o_ibp_err_rd | sdb_ibp_err_rd_r[2] | sdb_ibp_err_rd_r[1] | sdb_ibp_err_rd_r[0])
                                 ) :
                           rd_splt_case_2 ?
                                 (
                                        (rd_splt_1st_lane == 4'b0001 ) ?
                                                        (o_ibp_err_rd | sdb_ibp_err_rd_r[0])
                                                      : (o_ibp_err_rd | sdb_ibp_err_rd_r[2])
                                 ) :
                                 (
                                              o_ibp_err_rd
                                 ) ;
    assign i_ibp_rd_excl_ok = rd_splt_case_1 ?
                                 (
                                           (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[2] & sdb_ibp_rd_excl_ok_r[1] & sdb_ibp_rd_excl_ok_r[0])
                                 ) :
                           rd_splt_case_2 ?
                                 (
                                        (rd_splt_1st_lane == 4'b0001 ) ?
                                                        (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[0])
                                                      : (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[2])
                                 ) :
                                 (
                                              o_ibp_rd_excl_ok
                                 ) ;

    assign i_ibp_rd_chnl_valid = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                     (rd_splt_lane_real[(X_W/Y_W)-1]  & o_ibp_rd_chnl_valid)
                             ) :
                       rd_splt_case_2 ?
                             (
                             rd_splt_1st_lane[0] ?
                                                    (rd_splt_lane_real[1] & o_ibp_rd_chnl_valid)
                                                  : (rd_splt_lane_real[(X_W/Y_W)-1] & o_ibp_rd_chnl_valid)
                             ) :
                             (
                                     o_ibp_rd_chnl_valid
                             ) );
                             
    assign o_ibp_rd_chnl_accept = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                        (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                       rd_splt_case_2 ?
                             (       
                             rd_splt_1st_lane[0] ?
                                                    (rd_splt_lane_real[1] ? i_ibp_rd_chnl_accept : 1'b1)
                                                  : (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                             (
                                     i_ibp_rd_chnl_accept
                             ));

    end

    if((X_W/Y_W) == 2) begin: err_rd_xw_div_yw_is_2
    assign i_ibp_err_rd = rd_splt_case_1 ?
                                 (
                                           (o_ibp_err_rd | sdb_ibp_err_rd_r[0])
                                 ) :
                                 (
                                              o_ibp_err_rd
                                 ) ;
    assign i_ibp_rd_excl_ok = rd_splt_case_1 ?
                                 (
                                           (o_ibp_rd_excl_ok & sdb_ibp_rd_excl_ok_r[0])
                                 ) :
                                 (
                                              o_ibp_rd_excl_ok
                                 ) ;

    assign i_ibp_rd_chnl_valid = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                     (rd_splt_lane_real[(X_W/Y_W)-1]  & o_ibp_rd_chnl_valid)
                             ) :
                       rd_splt_case_2 ?
                             (
                                     rd_splt_1st_lane[0] ?
                                                    (rd_splt_lane_real[1] & o_ibp_rd_chnl_valid)
                                                  : (rd_splt_lane_real[(X_W/Y_W)-1] & o_ibp_rd_chnl_valid)
                             ) :
                             (
                                     o_ibp_rd_chnl_valid
                             ) );
    assign o_ibp_rd_chnl_accept = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                        (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                       rd_splt_case_2 ?
                             (
                                     rd_splt_1st_lane[0] ?
                                                    (rd_splt_lane_real[1] ? i_ibp_rd_chnl_accept : 1'b1)
                                                  : (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                             (
                                     i_ibp_rd_chnl_accept
                             ));
                         end

endgenerate //}


/*
assign i_ibp_rd_chnl_valid = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                     (rd_splt_lane_real[(X_W/Y_W)-1]  & o_ibp_rd_chnl_valid)
                             ) :
                       rd_splt_case_2 ?
                             (
                                     rd_splt_1st_lane[0] ?
                                                    (rd_splt_lane_real[1] & o_ibp_rd_chnl_valid)
                                                  : (rd_splt_lane_real[(X_W/Y_W)-1] & o_ibp_rd_chnl_valid)
                             ) :
                             (
                                     o_ibp_rd_chnl_valid
                             ) );
assign o_ibp_rd_chnl_accept = (~rd_splt_info_fifo_empty) & (
                   rd_splt_case_1 ?
                             (
                                        (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                       rd_splt_case_2 ?
                             (
                                     rd_splt_1st_lane[0] ?
                                                    (rd_splt_lane_real[1] ? i_ibp_rd_chnl_accept : 1'b1)
                                                  : (rd_splt_lane_real[(X_W/Y_W)-1] ? i_ibp_rd_chnl_accept : 1'b1)
                             ) :
                             (
                                     i_ibp_rd_chnl_accept
                             ));
*/

assign i_ibp_rd_chnl[(X_W-1+X_RD_CHNL_RD_DATA_LSB) : X_RD_CHNL_RD_DATA_LSB] = i_ibp_rd_data;
assign i_ibp_rd_chnl[X_RD_CHNL_RD_LAST] = o_ibp_rd_chnl[Y_RD_CHNL_RD_LAST];
assign i_ibp_rd_chnl[X_RD_CHNL_ERR_RD] = i_ibp_err_rd;
assign i_ibp_rd_chnl[X_RD_CHNL_RD_EXCL_OK] = i_ibp_rd_excl_ok;

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
assign rd_1st_beat_set = o_ibp_rd_chnl_valid & o_ibp_rd_chnl_accept & o_ibp_rd_chnl[Y_RD_CHNL_RD_LAST];
// When the "non-last" beat handshaked, then clear the rd_1st indication for next coming beat
assign rd_1st_beat_clr = o_ibp_rd_chnl_valid & o_ibp_rd_chnl_accept & (~o_ibp_rd_chnl[Y_RD_CHNL_RD_LAST]);
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

// Implement a counter to indicate the lane in rd channel
reg [(X_W/Y_W)-1:0] rd_splt_lane_r;
wire [(X_W/Y_W)-1:0] rd_splt_lane_nxt;
wire rd_splt_lane_ena;
wire rd_splt_lane_inc;
wire rd_splt_lane_set;
assign rd_splt_lane_inc = o_ibp_rd_chnl_valid & o_ibp_rd_chnl_accept & (~o_ibp_rd_chnl[Y_RD_CHNL_RD_LAST]);
assign rd_splt_lane_set = o_ibp_rd_chnl_valid & o_ibp_rd_chnl_accept & rd_1st_beat_r;
assign rd_splt_lane_ena = rd_splt_lane_inc | rd_splt_lane_set;
assign rd_splt_lane_nxt = rd_splt_lane_set ? {rd_splt_1st_lane[(X_W/Y_W)-2:0], rd_splt_1st_lane[(X_W/Y_W)-1]}
                         : {rd_splt_lane_r[(X_W/Y_W)-2:0], rd_splt_lane_r[(X_W/Y_W)-1]};

always @(posedge clk or posedge rst_a)
begin : rd_splt_lane_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      rd_splt_lane_r       <= {X_W/Y_W{1'b0}}  ;
  end
  else if (rd_splt_lane_ena == 1'b1) begin
      rd_splt_lane_r       <= rd_splt_lane_nxt;
  end
end

assign rd_splt_lane_real = rd_1st_beat_r ? rd_splt_1st_lane : rd_splt_lane_r;

// Implement a side buffer to save the read back data
wire [((X_W/Y_W)-2) : 0] sdb_ibp_rd_chnl_ena;

genvar j;
generate //{
    for(j=0; j<((X_W/Y_W)-1); j=j+1) begin: sdb_ibp_rd_data_r_gen//{
        assign sdb_ibp_rd_chnl_ena[j] = o_ibp_rd_chnl_valid & o_ibp_rd_chnl_accept & rd_splt_lane_real[j];

        always @(posedge clk or posedge rst_a)
        begin : sdb_ibp_rd_DFFEAR_PROC
          if (rst_a == 1'b1) begin
              sdb_ibp_rd_data_r[j]       <= {Y_W{1'b0}}  ;
              sdb_ibp_err_rd_r[j]       <= 1'b0;
              sdb_ibp_rd_excl_ok_r[j]       <= 1'b0;
          end
          else if (sdb_ibp_rd_chnl_ena[j] == 1'b1) begin
              sdb_ibp_rd_data_r[j]       <= o_ibp_rd_data;
              sdb_ibp_err_rd_r[j]       <= o_ibp_err_rd;
              sdb_ibp_rd_excl_ok_r[j]       <= o_ibp_rd_excl_ok;
          end
        end
    end//}
endgenerate //}



// For the wdata channel: Put the data into approprate postion for narrow transfer
wire [1:0] wd_splt_case;
wire wd_splt_case_1;
wire wd_splt_case_2;
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire wd_splt_case_3;
// leda NTL_CON13A on
// leda NTL_CON32 on
wire [(X_W/Y_W)-1:0] wd_splt_1st_lane ;
wire [X_W-1: 0] i_ibp_wd_data;
wire [(X_W/8)-1: 0] i_ibp_wd_mask;
wire [3:0] wd_data_size;

assign wd_splt_case = wd_splt_info_fifo_empty ? wd_splt_info_fifo_wdat[1:0] : wd_splt_info_fifo_rdat[1:0];
assign wd_splt_case_1 = (wd_splt_case == 2'd1);
assign wd_splt_case_2 = (wd_splt_case == 2'd2);
assign wd_splt_case_3 = (wd_splt_case == 2'd3);
assign i_ibp_wd_data = i_i_ibp_wd_chnl[(X_W-1+X_WD_CHNL_DATA_LSB) : X_WD_CHNL_DATA_LSB];
assign i_ibp_wd_mask = i_i_ibp_wd_chnl[((X_W/8)-1+X_WD_CHNL_MASK_LSB) : X_WD_CHNL_MASK_LSB];
assign wd_splt_1st_lane = wd_splt_info_fifo_empty ? wd_splt_info_fifo_wdat [(X_W/Y_W)-1+2:2] : wd_splt_info_fifo_rdat [(X_W/Y_W)-1+2:2];
assign wd_data_size = wd_splt_info_fifo_rdat [(X_W/Y_W)-1+2+4:(X_W/Y_W)-1+2+1];

assign o_ibp_wd_chnl_valid = i_i_ibp_wd_chnl_valid;

wire [(X_W/Y_W)-1:0] wd_lane_vec_real;
/*
assign i_i_ibp_wd_chnl_accept = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? o_ibp_wd_chnl_accept : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (
                                     wd_splt_1st_lane[0] ?
                                                    (wd_lane_vec_real[1] ? o_ibp_wd_chnl_accept : 1'b0)
                                                  : (wd_lane_vec_real[(X_W/Y_W)-1] ? o_ibp_wd_chnl_accept : 1'b0)
                             ) :
                             (
                                     o_ibp_wd_chnl_accept
                     )
              );
*/
wire o_ibp_wd_chnl_last;
wire i_ibp_wd_chnl_last;
assign i_ibp_wd_chnl_last = i_i_ibp_wd_chnl[X_WD_CHNL_LAST];
/*
assign o_ibp_wd_chnl_last = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? i_ibp_wd_chnl_last : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (
                                     wd_splt_1st_lane[0] ?
                                                    (wd_lane_vec_real[1] ? i_ibp_wd_chnl_last : 1'b0)
                                                  : (wd_lane_vec_real[(X_W/Y_W)-1] ? i_ibp_wd_chnl_last : 1'b0)
                             ) :
                             (
                                     i_ibp_wd_chnl_last
                     )
              );
*/
wire[Y_W-1:0] o_ibp_wd_data;
wire[(Y_W/8)-1:0] o_ibp_wd_mask;

generate //}
    if ((X_W/Y_W) == 16 ) begin: wd_xw_div_yw_is_16
    assign o_ibp_wd_data = (
                                             (i_ibp_wd_data[Y_W-1+(15*Y_W):(15*Y_W)] & {Y_W{wd_lane_vec_real[15]}})
                                           | (i_ibp_wd_data[Y_W-1+(14*Y_W):(14*Y_W)] & {Y_W{wd_lane_vec_real[14]}})
                                           | (i_ibp_wd_data[Y_W-1+(13*Y_W):(13*Y_W)] & {Y_W{wd_lane_vec_real[13]}})
                                           | (i_ibp_wd_data[Y_W-1+(12*Y_W):(12*Y_W)] & {Y_W{wd_lane_vec_real[12]}})
                                           | (i_ibp_wd_data[Y_W-1+(11*Y_W):(11*Y_W)] & {Y_W{wd_lane_vec_real[11]}})
                                           | (i_ibp_wd_data[Y_W-1+(10*Y_W):(10*Y_W)] & {Y_W{wd_lane_vec_real[10]}})
                                           | (i_ibp_wd_data[Y_W-1+(9*Y_W):(9*Y_W)] & {Y_W{wd_lane_vec_real[9]}})
                                           | (i_ibp_wd_data[Y_W-1+(8*Y_W):(8*Y_W)] & {Y_W{wd_lane_vec_real[8]}})
                                           | (i_ibp_wd_data[Y_W-1+(7*Y_W):(7*Y_W)] & {Y_W{wd_lane_vec_real[7]}})
                                           | (i_ibp_wd_data[Y_W-1+(6*Y_W):(6*Y_W)] & {Y_W{wd_lane_vec_real[6]}})
                                           | (i_ibp_wd_data[Y_W-1+(5*Y_W):(5*Y_W)] & {Y_W{wd_lane_vec_real[5]}})
                                           | (i_ibp_wd_data[Y_W-1+(4*Y_W):(4*Y_W)] & {Y_W{wd_lane_vec_real[4]}})
                                           | (i_ibp_wd_data[Y_W-1+(3*Y_W):(3*Y_W)] & {Y_W{wd_lane_vec_real[3]}})
                                           | (i_ibp_wd_data[Y_W-1+(2*Y_W):(2*Y_W)] & {Y_W{wd_lane_vec_real[2]}})
                                           | (i_ibp_wd_data[Y_W-1+(1*Y_W):(1*Y_W)] & {Y_W{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_data[Y_W-1+(0*Y_W):(0*Y_W)] & {Y_W{wd_lane_vec_real[0]}})
                                 );

    assign o_ibp_wd_mask = {
                                             (i_ibp_wd_mask[(Y_W/8)-1+(15*(Y_W/8)):(15*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[15]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(14*(Y_W/8)):(14*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[14]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(13*(Y_W/8)):(13*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[13]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(12*(Y_W/8)):(12*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[12]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(11*(Y_W/8)):(11*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[11]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(10*(Y_W/8)):(10*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[10]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(9*(Y_W/8)):(9*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[9]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(8*(Y_W/8)):(8*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[8]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(7*(Y_W/8)):(7*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[7]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(6*(Y_W/8)):(6*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[6]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(5*(Y_W/8)):(5*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[5]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(4*(Y_W/8)):(4*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[4]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(3*(Y_W/8)):(3*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[3]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(2*(Y_W/8)):(2*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[2]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(1*(Y_W/8)):(1*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(0*(Y_W/8)):(0*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[0]}})
                                 };

    assign i_i_ibp_wd_chnl_accept = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? o_ibp_wd_chnl_accept : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (      //data size = 2*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[1] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h4   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[3] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[5] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h40  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[7] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h100 )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[9] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h400 )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[11]? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h1000)&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[13]? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h4000)&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[15]? o_ibp_wd_chnl_accept : 1'b0) :
                                    //data size = 4*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[3] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[7] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h100 )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[11]? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h1000)&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[15]? o_ibp_wd_chnl_accept : 1'b0) :
                                    //data size = 8*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[7] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h100 )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[15]? o_ibp_wd_chnl_accept : 1'b0) : o_ibp_wd_chnl_accept

                             ) :
                             (
                                     o_ibp_wd_chnl_accept
                     )
              );

    assign o_ibp_wd_chnl_last = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? i_ibp_wd_chnl_last : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (       //data size = 2*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[1] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h4   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[3] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[5] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h40  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[7] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h100 )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[9] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h400 )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[11]? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h1000)&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[13]? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h4000)&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[15]? i_ibp_wd_chnl_last : 1'b0) :
                                    //data size = 4*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[3] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[7] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h100 )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[11]? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h1000)&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[15]? i_ibp_wd_chnl_last : 1'b0) :
                                    //data size = 8*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[7] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h100 )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[15]? i_ibp_wd_chnl_last : 1'b0) : i_ibp_wd_chnl_last

                             ) :
                             (
                                     i_ibp_wd_chnl_last
                     )
              );

    end

    if ((X_W/Y_W) == 8 ) begin: wd_xw_div_yw_is_8
    assign o_ibp_wd_data = (
                                             (i_ibp_wd_data[Y_W-1+(7*Y_W):(7*Y_W)] & {Y_W{wd_lane_vec_real[7]}})
                                           | (i_ibp_wd_data[Y_W-1+(6*Y_W):(6*Y_W)] & {Y_W{wd_lane_vec_real[6]}})
                                           | (i_ibp_wd_data[Y_W-1+(5*Y_W):(5*Y_W)] & {Y_W{wd_lane_vec_real[5]}})
                                           | (i_ibp_wd_data[Y_W-1+(4*Y_W):(4*Y_W)] & {Y_W{wd_lane_vec_real[4]}})
                                           | (i_ibp_wd_data[Y_W-1+(3*Y_W):(3*Y_W)] & {Y_W{wd_lane_vec_real[3]}})
                                           | (i_ibp_wd_data[Y_W-1+(2*Y_W):(2*Y_W)] & {Y_W{wd_lane_vec_real[2]}})
                                           | (i_ibp_wd_data[Y_W-1+(1*Y_W):(1*Y_W)] & {Y_W{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_data[Y_W-1+(0*Y_W):(0*Y_W)] & {Y_W{wd_lane_vec_real[0]}})
                                 );

    assign o_ibp_wd_mask = {
                                             (i_ibp_wd_mask[(Y_W/8)-1+(7*(Y_W/8)):(7*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[7]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(6*(Y_W/8)):(6*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[6]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(5*(Y_W/8)):(5*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[5]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(4*(Y_W/8)):(4*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[4]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(3*(Y_W/8)):(3*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[3]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(2*(Y_W/8)):(2*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[2]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(1*(Y_W/8)):(1*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(0*(Y_W/8)):(0*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[0]}})
                                 };

    assign i_i_ibp_wd_chnl_accept = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? o_ibp_wd_chnl_accept : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (      //data size = 2*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[1] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h4   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[3] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[5] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h40  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[7] ? o_ibp_wd_chnl_accept : 1'b0) :
                                    //data size = 4*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[3] ? o_ibp_wd_chnl_accept : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[7] ? o_ibp_wd_chnl_accept : 1'b0) : o_ibp_wd_chnl_accept

                             ) :
                             (
                                     o_ibp_wd_chnl_accept
                     )
              );

    assign o_ibp_wd_chnl_last = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? i_ibp_wd_chnl_last : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (       //data size = 2*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[1] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h4   )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[3] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[5] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h40  )&&((1<<wd_data_size) == Y_W/4)) ? (wd_lane_vec_real[7] ? i_ibp_wd_chnl_last : 1'b0) :
                                    //data size = 4*Y_W
((wd_splt_1st_lane == 'h1   )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[3] ? i_ibp_wd_chnl_last : 1'b0) :
((wd_splt_1st_lane == 'h10  )&&((1<<wd_data_size) == Y_W/2)) ? (wd_lane_vec_real[7] ? i_ibp_wd_chnl_last : 1'b0) :  i_ibp_wd_chnl_last

                             ) :
                             (
                                     i_ibp_wd_chnl_last
                     )
              );

    end


    if ((X_W/Y_W) == 4 ) begin: wd_xw_div_yw_is_4
    assign o_ibp_wd_data = (
                                             (i_ibp_wd_data[Y_W-1+(3*Y_W):(3*Y_W)] & {Y_W{wd_lane_vec_real[3]}})
                                           | (i_ibp_wd_data[Y_W-1+(2*Y_W):(2*Y_W)] & {Y_W{wd_lane_vec_real[2]}})
                                           | (i_ibp_wd_data[Y_W-1+(1*Y_W):(1*Y_W)] & {Y_W{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_data[Y_W-1+(0*Y_W):(0*Y_W)] & {Y_W{wd_lane_vec_real[0]}})
                                 );

    assign o_ibp_wd_mask = {
                                             (i_ibp_wd_mask[(Y_W/8)-1+(3*(Y_W/8)):(3*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[3]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(2*(Y_W/8)):(2*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[2]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(1*(Y_W/8)):(1*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(0*(Y_W/8)):(0*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[0]}})
                                 };
    assign i_i_ibp_wd_chnl_accept = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? o_ibp_wd_chnl_accept : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (
                                     wd_splt_1st_lane[0] ?
                                                    (wd_lane_vec_real[1] ? o_ibp_wd_chnl_accept : 1'b0)
                                                  : (wd_lane_vec_real[(X_W/Y_W)-1] ? o_ibp_wd_chnl_accept : 1'b0)
                             ) :
                             (
                                     o_ibp_wd_chnl_accept
                     )
              );

    assign o_ibp_wd_chnl_last = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? i_ibp_wd_chnl_last : 1'b0)
                             ) :
                       wd_splt_case_2 ?
                             (
                                     wd_splt_1st_lane[0] ?
                                                    (wd_lane_vec_real[1] ? i_ibp_wd_chnl_last : 1'b0)
                                                  : (wd_lane_vec_real[(X_W/Y_W)-1] ? i_ibp_wd_chnl_last : 1'b0)
                             ) :
                             (
                                     i_ibp_wd_chnl_last
                     )
              );

    end

    if ((X_W/Y_W) == 2 ) begin: wd_xw_div_yw_is_2
    assign o_ibp_wd_data = {
                                             (i_ibp_wd_data[Y_W-1+(1*Y_W):(1*Y_W)] & {Y_W{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_data[Y_W-1+(0*Y_W):(0*Y_W)] & {Y_W{wd_lane_vec_real[0]}})
                               };
    
    assign o_ibp_wd_mask = {
                                             (i_ibp_wd_mask[(Y_W/8)-1+(1*(Y_W/8)):(1*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[1]}})
                                           | (i_ibp_wd_mask[(Y_W/8)-1+(0*(Y_W/8)):(0*(Y_W/8))] & {Y_W/8{wd_lane_vec_real[0]}})
                               };

    assign i_i_ibp_wd_chnl_accept = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? o_ibp_wd_chnl_accept : 1'b0)
                             ) :
                             (
                                     o_ibp_wd_chnl_accept
                             )
              );

    assign o_ibp_wd_chnl_last = (
                       wd_splt_case_1 ?
                             (
                                      (wd_lane_vec_real[(X_W/Y_W)-1] ? i_ibp_wd_chnl_last : 1'b0)
                             ) :
                             (
                                     i_ibp_wd_chnl_last
                     )
              );

    end
endgenerate //}

assign o_ibp_wd_chnl[Y_WD_CHNL_LAST       ]  = o_ibp_wd_chnl_last;
assign o_ibp_wd_chnl[(Y_W-1+Y_WD_CHNL_DATA_LSB) : Y_WD_CHNL_DATA_LSB] = o_ibp_wd_data;
assign o_ibp_wd_chnl[((Y_W/8)-1+Y_WD_CHNL_MASK_LSB) : Y_WD_CHNL_MASK_LSB] = o_ibp_wd_mask;


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
assign wd_1st_beat_set = o_ibp_wd_chnl_valid & o_ibp_wd_chnl_accept & o_ibp_wd_chnl[Y_WD_CHNL_LAST];
// When the "non-last" beat handshaked, then clear the wd_1st indication for next coming beat
assign wd_1st_beat_clr = o_ibp_wd_chnl_valid & o_ibp_wd_chnl_accept & (~o_ibp_wd_chnl[Y_WD_CHNL_LAST]);
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

// Implement a counter to indicate the lane in wd channel
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg [(X_W/Y_W)-1:0] wd_lane_vec_r;
// leda NTL_CON32 on
wire [(X_W/Y_W)-1:0] wd_lane_vec_nxt;
wire wd_lane_vec_ena;
wire wd_lane_vec_inc;
wire wd_lane_vec_set;
assign wd_lane_vec_inc = o_ibp_wd_chnl_valid & o_ibp_wd_chnl_accept & (~o_ibp_wd_chnl[Y_WD_CHNL_LAST]);
assign wd_lane_vec_set = o_ibp_wd_chnl_valid & o_ibp_wd_chnl_accept & wd_1st_beat_r;
assign wd_lane_vec_ena = wd_lane_vec_inc | wd_lane_vec_set;
assign wd_lane_vec_nxt = wd_lane_vec_set ? {wd_splt_1st_lane[(X_W/Y_W)-2:0], wd_splt_1st_lane[(X_W/Y_W)-1]}
                         : {wd_lane_vec_r[(X_W/Y_W)-2:0], wd_lane_vec_r[(X_W/Y_W)-1]};
always @(posedge clk or posedge rst_a)
begin : wd_lane_vec_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      wd_lane_vec_r       <= {X_W/Y_W{1'b0}}  ;
  end
  else if (wd_lane_vec_ena == 1'b1) begin
      wd_lane_vec_r       <= wd_lane_vec_nxt;
  end
end

assign wd_lane_vec_real = wd_1st_beat_r ? wd_splt_1st_lane : wd_lane_vec_r;




endmodule // mss_bus_switch_ibpw2ibpn

