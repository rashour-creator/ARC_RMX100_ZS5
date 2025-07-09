// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2014 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
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
//  ###   ######  ######           #####  ######  #         ###   #######
//   #    #     # #     #         #     # #     # #          #       #
//   #    #     # #     #         #       #     # #          #       #
//   #    ######  ######           #####  ######  #          #       #
//   #    #     # #                     # #       #          #       #
//   #    #     # #               #     # #       #          #       #
//  ###   ######  #       #######  #####  #       #######   ###      #
//
// ===========================================================================
//
// Description:
//  Verilog module to split one IBP to multiple IBPs
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"


module alb_mss_mem_ibp_split
  #(
// leda W175 off
// LMD: A parameter XXX has been defined but is not used
// LJ: We always list out all IBP relevant defines although not used

    ////////////
    //SPLT_NUM indicate how much of IBPs this module to split
    parameter ALLOW_DIFF_BRANCH = 1,
    parameter SPLT_NUM = 4,




    parameter CMD_CHNL_READ           = 0,
    parameter CMD_CHNL_WRAP           = 1,
    parameter CMD_CHNL_DATA_SIZE_LSB  = 2,
    parameter CMD_CHNL_DATA_SIZE_W    = 3,
    parameter CMD_CHNL_BURST_SIZE_LSB = 5,
    parameter CMD_CHNL_BURST_SIZE_W   = 4,
    parameter CMD_CHNL_PROT_LSB       = 9,
    parameter CMD_CHNL_PROT_W         = 2,
    parameter CMD_CHNL_CACHE_LSB      = 11,
    parameter CMD_CHNL_CACHE_W        = 4,
    parameter CMD_CHNL_LOCK           = 15,
    parameter CMD_CHNL_EXCL           = 16,
    parameter CMD_CHNL_ADDR_LSB       = 17,
    parameter CMD_CHNL_ADDR_W         = 32,
    parameter CMD_CHNL_W              = 49,

    parameter WD_CHNL_LAST            = 0,
    parameter WD_CHNL_DATA_LSB        = 1,
    parameter WD_CHNL_DATA_W          = 128,
    parameter WD_CHNL_MASK_LSB        = 129,
    parameter WD_CHNL_MASK_W          = 16,
    parameter WD_CHNL_W               = 145,

    parameter RD_CHNL_ERR_RD          = 0,
    parameter RD_CHNL_RD_EXCL_OK      = 2,
    parameter RD_CHNL_RD_LAST         = 1,
    parameter RD_CHNL_RD_DATA_LSB     = 3,
    parameter RD_CHNL_RD_DATA_W       = 128,
    parameter RD_CHNL_W               = 131,

    parameter WRSP_CHNL_WR_DONE       = 0,
    parameter WRSP_CHNL_WR_EXCL_DONE  = 1,
    parameter WRSP_CHNL_ERR_WR        = 2,
    parameter WRSP_CHNL_W             = 3,

    parameter USER_W = 8,
    ////////////
    // The Splitter FIFOs parameter
    //
    // The FIFO Depth indicated the FIFO entries
    parameter SPLT_FIFO_DEPTH = 8,
    // FIFO_WIDTH to save the splitter port id, SPLT_NUM=4 ports,
    // so 2 bits for port id
    parameter SPLT_FIFO_WIDTH = 2
 // leda W175 on
    )
  (
  ////////////
  // The "i_xxx" bus is the one IBP to be split
  //
  // command channel
  input  i_ibp_cmd_chnl_valid,
  output i_ibp_cmd_chnl_accept,
  input  [CMD_CHNL_W-1:0] i_ibp_cmd_chnl,
  input  [USER_W-1:0] i_ibp_cmd_chnl_user,
  //
  // read data channel
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

  ////////////
  // Each bit in i_ibp_split_indicator indicate which input  IBP the outputIBP should be split to
  // E.g,
  // if i_ibp_split_indicator == N'b00...001, it indicate the outputIBP should be routed to input  IBP0
  // if i_ibp_split_indicator == N'b00...010, it indicate the outputIBP should be routed to input  IBP1
// leda NTL_CON13C off
// LMD: non driving internal net
// LJ: Some signals bit field are indeed no driven
  input  [SPLT_NUM-1:0] i_ibp_split_indicator,
// leda NTL_CON13C on

  ////////////
  // Because verilog do not support the multiple-dimension array, so we
  // packed different split IBP buses into a very wide bus named as
  // "o_bus_xxx". E.g, if there are <x> IBPs to be split, it will be
  // packed as o_bus_ibp_cmd_chnl = {ibp0_cmd_chnl, ibp1_cmd_chnl, ..., ibp<x-1>_cmd_chnl};
  // and the width of o_bus_ibp_cmd_chnl is SPLT_NUM*CMD_CHNL_W
  //
  // command channel
  output [SPLT_NUM-1:0] o_bus_ibp_cmd_chnl_valid,
  input  [SPLT_NUM-1:0] o_bus_ibp_cmd_chnl_accept,
  output [SPLT_NUM*CMD_CHNL_W-1:0] o_bus_ibp_cmd_chnl,
  output [SPLT_NUM*USER_W-1:0] o_bus_ibp_cmd_chnl_user,
  //
  // read data channel
  input  [SPLT_NUM-1:0] o_bus_ibp_rd_chnl_valid,
  output [SPLT_NUM-1:0] o_bus_ibp_rd_chnl_accept,
  input  [SPLT_NUM*RD_CHNL_W-1:0] o_bus_ibp_rd_chnl,
  //
  // write data channel
  output [SPLT_NUM-1:0] o_bus_ibp_wd_chnl_valid,
  input  [SPLT_NUM-1:0] o_bus_ibp_wd_chnl_accept,
  output [SPLT_NUM*WD_CHNL_W-1:0] o_bus_ibp_wd_chnl,
  //
  // write response channel
  input  [SPLT_NUM-1:0] o_bus_ibp_wrsp_chnl_valid,
  output [SPLT_NUM-1:0] o_bus_ibp_wrsp_chnl_accept,
  input  [SPLT_NUM*WRSP_CHNL_W-1:0] o_bus_ibp_wrsp_chnl,

  ////////
// leda NTL_CON13C off
// LMD: non driving internal net
// LJ: Some signals bit field are indeed no driven
  input                         clk,  // clock signal
  input                         rst_a // reset signal
// leda NTL_CON13C on
  );


genvar i;
generate //{
  if(SPLT_NUM == 1) begin:split_num_eq_1_gen// {
    assign i_ibp_cmd_chnl_accept    = o_bus_ibp_cmd_chnl_accept;
    assign o_bus_ibp_cmd_chnl_valid = i_ibp_cmd_chnl_valid     ;
    assign o_bus_ibp_cmd_chnl       = i_ibp_cmd_chnl           ;
    assign o_bus_ibp_cmd_chnl_user  = i_ibp_cmd_chnl_user           ;

    assign i_ibp_rd_chnl_valid      = o_bus_ibp_rd_chnl_valid;
    assign i_ibp_rd_chnl            = o_bus_ibp_rd_chnl      ;
    assign o_bus_ibp_rd_chnl_accept = i_ibp_rd_chnl_accept   ;

    assign i_ibp_wd_chnl_accept     = o_bus_ibp_wd_chnl_accept;
    assign o_bus_ibp_wd_chnl_valid  = i_ibp_wd_chnl_valid ;
    assign o_bus_ibp_wd_chnl        = i_ibp_wd_chnl       ;

    assign o_bus_ibp_wrsp_chnl_accept = i_ibp_wrsp_chnl_accept;
    assign i_ibp_wrsp_chnl_valid      = o_bus_ibp_wrsp_chnl_valid ;
    assign i_ibp_wrsp_chnl            = o_bus_ibp_wrsp_chnl;
  end//}
  else begin:split_num_gt_1_gen//{

    ///////////////////////
    // Distract different IBPs from packed o_bus_xxx,
    // and different IBPs will be declared as a two-dimension
    // array. E.g, o_cmd_chnl[0] will be IBP0, o_cmd_chnl[1]
    // will be IBP1, .etc.
    // The xxx_chnl_valid/accept signals are the channel handshake signals.
    //
    wire [SPLT_NUM-1:0] o_cmd_chnl_valid;
    wire [SPLT_NUM-1:0] o_cmd_chnl_accept;
    wire [CMD_CHNL_W-1:0] o_cmd_chnl[SPLT_NUM-1:0];
    wire [USER_W-1:0] o_cmd_chnl_user[SPLT_NUM-1:0];

      // IBP read data channel
    wire [SPLT_NUM-1:0] o_rd_chnl_valid;
    wire [SPLT_NUM-1:0] o_rd_chnl_accept;
    wire [RD_CHNL_W-1:0] o_rd_chnl[SPLT_NUM-1:0];

      // IBP write data channel
    wire [SPLT_NUM-1:0] o_wd_chnl_valid;
    wire [SPLT_NUM-1:0] o_wd_chnl_accept;
    wire [WD_CHNL_W-1:0] o_wd_chnl[SPLT_NUM-1:0];

      // IBP write data channel
    wire [SPLT_NUM-1:0] o_wrsp_chnl_valid;
    wire [SPLT_NUM-1:0] o_wrsp_chnl_accept;
    wire [WRSP_CHNL_W-1:0] o_wrsp_chnl[SPLT_NUM-1:0];


    for(i = 0; i < SPLT_NUM; i = i+1)//{
    begin:ibp_inbus_decompact_gen
        assign o_bus_ibp_cmd_chnl_valid[i] = o_cmd_chnl_valid[i];
        assign o_cmd_chnl_accept[i] = o_bus_ibp_cmd_chnl_accept[i];
        assign o_bus_ibp_cmd_chnl[(i*CMD_CHNL_W)+CMD_CHNL_W-1:(i*CMD_CHNL_W)] = o_cmd_chnl[i];
        assign o_bus_ibp_cmd_chnl_user[(i*USER_W)+USER_W-1:(i*USER_W)] = o_cmd_chnl_user[i];

          // IBP read data channel
        assign o_rd_chnl_valid[i] = o_bus_ibp_rd_chnl_valid[i];
        assign o_bus_ibp_rd_chnl_accept[i] = o_rd_chnl_accept[i];
        assign o_rd_chnl[i] = o_bus_ibp_rd_chnl[(i*RD_CHNL_W)+RD_CHNL_W-1:(i*RD_CHNL_W)];

          // IBP write data channel
        assign o_bus_ibp_wd_chnl_valid[i] = o_wd_chnl_valid[i];
        assign o_wd_chnl_accept[i] = o_bus_ibp_wd_chnl_accept[i];
        assign o_bus_ibp_wd_chnl[(i*WD_CHNL_W)+WD_CHNL_W-1:(i*WD_CHNL_W)] = o_wd_chnl[i];

          // IBP write resp channel
        assign o_wrsp_chnl_valid[i] = o_bus_ibp_wrsp_chnl_valid[i];
        assign o_bus_ibp_wrsp_chnl_accept[i] = o_wrsp_chnl_accept[i];
        assign o_wrsp_chnl[i] = o_bus_ibp_wrsp_chnl[(i*WRSP_CHNL_W)+WRSP_CHNL_W-1:(i*WRSP_CHNL_W)];

    end//}




    ///////////////////////
    // The input IBP will be accepted when met several conditions:
    // (*) The target IBP have "accept" asserted
    // (*) All the FIFOs are not full
    reg sel_o_cmd_chnl_accept;

    integer j;
    always @ (*) begin : sel_o_cmd_chnl_accept_PROC
      sel_o_cmd_chnl_accept = 1'b0;
      for(j = 0; j < SPLT_NUM; j = j+1) begin//{
        sel_o_cmd_chnl_accept = sel_o_cmd_chnl_accept | (i_ibp_split_indicator[j] & o_cmd_chnl_accept[j]);
      end//}
    end

    wire i_ibp_cmd_chnl_accept_pre = sel_o_cmd_chnl_accept;

    wire wd_chnl_fifo_full;
    wire rd_chnl_fifo_full;
    wire wrsp_chnl_fifo_full;
    wire wd_chnl_fifo_empty;
    wire rd_chnl_fifo_empty;
    wire wrsp_chnl_fifo_empty;
    wire [SPLT_FIFO_WIDTH-1:0] rd_chnl_port_id_ptr;
    wire [SPLT_FIFO_WIDTH-1:0] wrsp_chnl_port_id_ptr;
    reg [SPLT_FIFO_WIDTH-1:0] i_split_indicator_id;
    wire i_ibp_cmd_chnl_valid_pre;

      if(ALLOW_DIFF_BRANCH == 1) begin: allow_diff_branch_gen

          assign i_ibp_cmd_chnl_valid_pre =  i_ibp_cmd_chnl_valid
                                         & (~rd_chnl_fifo_full)
                                         & (~wd_chnl_fifo_full)
                                         & (~wrsp_chnl_fifo_full);
          assign i_ibp_cmd_chnl_accept   = i_ibp_cmd_chnl_accept_pre
                                               & (~rd_chnl_fifo_full)
                                               & (~wd_chnl_fifo_full)
                                               & (~wrsp_chnl_fifo_full);
      end
      else begin: not_allow_diff_branch_gen

          wire to_diff_branch_stall =
             // There is read-outstanding
                 ((~rd_chnl_fifo_empty  ) & (~(rd_chnl_port_id_ptr == i_split_indicator_id)))
             // There is write-outstanding
               | ((~wrsp_chnl_fifo_empty) & (~(wrsp_chnl_port_id_ptr == i_split_indicator_id)));

          assign i_ibp_cmd_chnl_valid_pre =  i_ibp_cmd_chnl_valid
                                         & (~to_diff_branch_stall)
                                         & (~rd_chnl_fifo_full)
                                         & (~wd_chnl_fifo_full)
                                         & (~wrsp_chnl_fifo_full);
          assign i_ibp_cmd_chnl_accept   = i_ibp_cmd_chnl_accept_pre
                                               & (~to_diff_branch_stall)
                                               & (~rd_chnl_fifo_full)
                                               & (~wd_chnl_fifo_full)
                                               & (~wrsp_chnl_fifo_full);
      end

    ///////////////////////
    // The input IBP WD channel will be accepted when met several conditions:
    // (*) The target IBP have "accept" asserted
    // (*) The wd chnal fifo are not empty
    wire sel_o_wd_chnl_accept;
    wire [SPLT_FIFO_WIDTH-1:0] wd_chnl_port_id_ptr;
    // leda FM_2_22 off
    // LMD: Possible range overflow
    // LJ:  The id_ptr is generated correctly, so never overflow
    assign sel_o_wd_chnl_accept = o_wd_chnl_accept[wd_chnl_port_id_ptr];
    // leda FM_2_22 on



    ///////////////////////
    // The FIFOs generation including
    // wd_chnl_fifo, rd_chnl_fifo, wrsp_chnl_fifo
    // Because the IBP is in-ordered bus and each channel are independent with each other,
    // So when any transactions is passed to output command channel, all the FIFOs
    // are enqueued, and when any transactions get back from wdata/rdata/wresp channels
    // they dequeue respective FIFO to get port ID.


    // wdata/rdata/wresp channel FIFO is wrote when:
    // (*) Any transactions in command channel is handshaked to out command channel
    wire i_ibp_cmd_chnl_hashked = i_ibp_cmd_chnl_accept & i_ibp_cmd_chnl_valid;
    wire i_cmd_wr_hashked = i_ibp_cmd_chnl_hashked & (~i_ibp_cmd_chnl[CMD_CHNL_READ]);

    wire i_cmd_rd_hashked = i_ibp_cmd_chnl_hashked & i_ibp_cmd_chnl[CMD_CHNL_READ];
    wire wd_chnl_fifo_wen_raw = i_cmd_wr_hashked ;
    wire wrsp_chnl_fifo_wen = i_cmd_wr_hashked;
    wire rd_chnl_fifo_wen = i_cmd_rd_hashked;
    // All wrote with the port ID.
    always @ (*) begin : i_split_indicator_id_PROC
      i_split_indicator_id = {SPLT_FIFO_WIDTH{1'b0}};
      for(j = 0; j < SPLT_NUM; j = j+1) begin//{
        i_split_indicator_id = i_split_indicator_id | {SPLT_FIFO_WIDTH{i_ibp_split_indicator[j]}} & $unsigned(j);
      end//}
    end

    wire [SPLT_FIFO_WIDTH-1:0] wd_chnl_fifo_wdat = i_split_indicator_id;
    wire [SPLT_FIFO_WIDTH-1:0] rd_chnl_fifo_wdat = i_split_indicator_id;
    wire [SPLT_FIFO_WIDTH-1:0] wrsp_chnl_fifo_wdat = i_split_indicator_id;

    // wdata channel FIFO is read when:
    // (*) Any transactions in wdata channel is hanshaked
    // (*) It is the last beat for this transaction
    wire i_ibp_wd_chnl_hashked = i_ibp_wd_chnl_accept & i_ibp_wd_chnl_valid & i_ibp_wd_chnl[WD_CHNL_LAST];
    wire wd_chnl_fifo_ren_raw = i_ibp_wd_chnl_hashked;
    // fifo_rdat is used for the wdata channel port ID pointer
    wire [SPLT_FIFO_WIDTH-1:0] wd_chnl_fifo_rdat;
    assign wd_chnl_port_id_ptr = wd_chnl_fifo_rdat;

    // rdata channel FIFO is read when:
    // (*) Any transactions in rdata channel is hanshaked
    // (*) It is the last beat for this transaction
    // Or:
    wire i_ibp_rd_chnl_hashked = (i_ibp_rd_chnl_accept & i_ibp_rd_chnl_valid & i_ibp_rd_chnl[RD_CHNL_RD_LAST]);
    wire rd_chnl_fifo_ren = i_ibp_rd_chnl_hashked;
    // fifo_rdat is used for the rdata channel port ID pointer
    wire [SPLT_FIFO_WIDTH-1:0] rd_chnl_fifo_rdat;
    assign rd_chnl_port_id_ptr = rd_chnl_fifo_rdat;

    // wresp channel FIFO is read when:
    // (*) Any transactions in wresp channel is hanshaked
    wire i_ibp_wrsp_chnl_hashked = i_ibp_wrsp_chnl_accept & i_ibp_wrsp_chnl_valid;
    wire wrsp_chnl_fifo_ren = i_ibp_wrsp_chnl_hashked;
    // fifo_rdat is used for the wresp channel port ID pointer
    wire [SPLT_FIFO_WIDTH-1:0] wrsp_chnl_fifo_rdat;
    assign wrsp_chnl_port_id_ptr = wrsp_chnl_fifo_rdat;


    wire wd_chnl_fifo_wen;
    wire wd_chnl_fifo_ren;

    // There is a special case, when the wd_chnl_fifo is empty, and next the cmd
    // and wr channel come (a paired transaction) and accepted
    // at the same time. Then for this case, the wd_chnl_fifo is not needed
    // to be enqueued (for cmd channel hsk) and dequeued (for wd chnl hsk).
    wire byp_wd_chnl_fifo = wd_chnl_fifo_empty & wd_chnl_fifo_ren_raw & wd_chnl_fifo_wen_raw;


    assign wd_chnl_fifo_wen = wd_chnl_fifo_wen_raw & (~byp_wd_chnl_fifo);
    assign wd_chnl_fifo_ren = wd_chnl_fifo_ren_raw & (~byp_wd_chnl_fifo);

    reg indic_o_wd_chnl_accept;
    always @ * begin: gen_indic_o_wd_chnl_accept_PROC
      indic_o_wd_chnl_accept = 1'b0;
      for(j = 0; j < SPLT_NUM; j = j+1) begin: loop_indic_o_wd_chnl_accept//{
        indic_o_wd_chnl_accept = indic_o_wd_chnl_accept | (o_cmd_chnl_valid[j] & (~o_cmd_chnl[j][CMD_CHNL_READ]) & i_ibp_split_indicator[j] & o_wd_chnl_accept[j]);
      end//}
    end
    assign i_ibp_wd_chnl_accept = (indic_o_wd_chnl_accept & wd_chnl_fifo_empty) | (sel_o_wd_chnl_accept & (~wd_chnl_fifo_empty));


    wire wd_chnl_fifo_i_valid;
    wire wd_chnl_fifo_o_valid;
    wire wd_chnl_fifo_i_ready;
    wire wd_chnl_fifo_o_ready;
    assign wd_chnl_fifo_i_valid = wd_chnl_fifo_wen;
    assign wd_chnl_fifo_full    = (~wd_chnl_fifo_i_ready);
    assign wd_chnl_fifo_o_ready = wd_chnl_fifo_ren;
    assign wd_chnl_fifo_empty   = (~wd_chnl_fifo_o_valid);

    alb_mss_mem_fifo # (
      .FIFO_DEPTH(SPLT_FIFO_DEPTH),
      .FIFO_WIDTH(SPLT_FIFO_WIDTH),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
    ) wd_splt_info_fifo(
      .i_clk_en  (1'b1  ),
      .o_clk_en  (1'b1  ),
      .i_valid   (wd_chnl_fifo_i_valid),
      .i_ready   (wd_chnl_fifo_i_ready),
      .o_valid   (wd_chnl_fifo_o_valid),
      .o_ready   (wd_chnl_fifo_o_ready),
      .i_data    (wd_chnl_fifo_wdat ),
      .o_data    (wd_chnl_fifo_rdat ),
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

    wire rd_chnl_fifo_i_valid;
    wire rd_chnl_fifo_o_valid;
    wire rd_chnl_fifo_i_ready;
    wire rd_chnl_fifo_o_ready;
    assign rd_chnl_fifo_i_valid = rd_chnl_fifo_wen;
    assign rd_chnl_fifo_full    = (~rd_chnl_fifo_i_ready);
    assign rd_chnl_fifo_o_ready = rd_chnl_fifo_ren;
    assign rd_chnl_fifo_empty   = (~rd_chnl_fifo_o_valid);

     alb_mss_mem_fifo # (
      .FIFO_DEPTH(SPLT_FIFO_DEPTH),
      .FIFO_WIDTH(SPLT_FIFO_WIDTH),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
    ) rd_splt_info_fifo(
      .i_clk_en  (1'b1  ),
      .o_clk_en  (1'b1  ),
      .i_valid   (rd_chnl_fifo_i_valid),
      .i_ready   (rd_chnl_fifo_i_ready),
      .o_valid   (rd_chnl_fifo_o_valid),
      .o_ready   (rd_chnl_fifo_o_ready),
      .i_data    (rd_chnl_fifo_wdat ),
      .o_data    (rd_chnl_fifo_rdat ),
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

    wire wrsp_chnl_fifo_i_valid;
    wire wrsp_chnl_fifo_o_valid;
    wire wrsp_chnl_fifo_i_ready;
    wire wrsp_chnl_fifo_o_ready;
    assign wrsp_chnl_fifo_i_valid = wrsp_chnl_fifo_wen;
    assign wrsp_chnl_fifo_full    = (~wrsp_chnl_fifo_i_ready);
    assign wrsp_chnl_fifo_o_ready = wrsp_chnl_fifo_ren;
    assign wrsp_chnl_fifo_empty   = (~wrsp_chnl_fifo_o_valid);

    alb_mss_mem_fifo # (
      .FIFO_DEPTH(SPLT_FIFO_DEPTH),
      .FIFO_WIDTH(SPLT_FIFO_WIDTH),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
    ) wrsp_splt_info_fifo(
      .i_clk_en  (1'b1  ),
      .o_clk_en  (1'b1  ),
      .i_valid   (wrsp_chnl_fifo_i_valid),
      .i_ready   (wrsp_chnl_fifo_i_ready),
      .o_valid   (wrsp_chnl_fifo_o_valid),
      .o_ready   (wrsp_chnl_fifo_o_ready),
      .i_data    (wrsp_chnl_fifo_wdat ),
      .o_data    (wrsp_chnl_fifo_rdat ),
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

    ///////////////////////
    // The out command channel generation
    //
    // The o_cmd_chnl_valid is generated when several conditions met:
    // (*) The split_indicator is pointing to this IBP.
    // (*) i_ibp_cmd_chnl_valid is asserted
    // (*) All the FIFOs are not full
    //
    // The i_ibp_cmd_chnl is routed to all output IBPs
    for(i = 0; i < SPLT_NUM; i = i+1)//{
    begin:o_cmd_chnl_valid_gen
      assign o_cmd_chnl_valid[i] = i_ibp_split_indicator[i]
                                   & i_ibp_cmd_chnl_valid_pre;
      assign o_cmd_chnl[i] = i_ibp_cmd_chnl;
      assign o_cmd_chnl_user[i] = i_ibp_cmd_chnl_user;
    end//}
    //


    ///////////////////////
    // The out wdata channel generation
    //
    // The o_wd_chnl_valid is generated when several conditions met:
    // (*) The wdata_fifo is pointing to this IBP.
    // (*) i_ibp_wd_chnl_valid is asserted
    // (*) The wdata_FIFO are not empty
    //
    // The i_ibp_wd_chnl is routed to all output IBPs
    for(i = 0; i < SPLT_NUM; i = i+1)//{
    begin:o_wd_chnl_valid_gen

     assign o_wd_chnl_valid[i] = i_ibp_wd_chnl_valid & (
                                     ( o_cmd_chnl_valid[i]
                                       & (~o_cmd_chnl[i][CMD_CHNL_READ])
                                       & wd_chnl_fifo_empty)
                                   | ((wd_chnl_port_id_ptr == i)
                                       & (~wd_chnl_fifo_empty))
                                     );
     assign o_wd_chnl[i] = i_ibp_wd_chnl;
    end//}
    //


    ///////////////////////
    // The out rdata channel generation
    //
    // The o_rd_chnl_accept is generated when several conditions met:
    // (*) The rdata_fifo is pointing to this IBP.
    // (*) o_rd_chnl_accept is asserted
    // (*) The rdata_FIFO are not empty
      for(i = 0; i < SPLT_NUM; i = i+1)//{
      begin:o_rd_chnl_accept_gen
      assign o_rd_chnl_accept[i] = (rd_chnl_port_id_ptr == i)
                                   & i_ibp_rd_chnl_accept
                                   & (~rd_chnl_fifo_empty);
    end//}
    //
    // The i_ibp_rd_chnl is selected by a MUX with encoded port id ptr
    // leda FM_2_22 off
    // LMD: Possible range overflow
    // LJ:  The id_ptr is generated correctly, so never overflow
    assign i_ibp_rd_chnl = o_rd_chnl[rd_chnl_port_id_ptr];
    assign i_ibp_rd_chnl_valid = (~rd_chnl_fifo_empty) & o_rd_chnl_valid[rd_chnl_port_id_ptr];
    // leda FM_2_22 on


    ///////////////////////
    // The out wresp channel generation
    //
    // The i_ibp_wrsp_chnl_accept is generated when several conditions met:
    // (*) The wresp_fifo is pointing to this IBP.
    // (*) o_wrsp_chnl_accept is asserted
    // (*) The wresp_FIFO are not empty
    for(i = 0; i < SPLT_NUM; i = i+1)//{
    begin:o_wrsp_chnl_accept_gen
      assign o_wrsp_chnl_accept[i] = (wrsp_chnl_port_id_ptr == i)
                                   & i_ibp_wrsp_chnl_accept
                                   & (~wrsp_chnl_fifo_empty);
    end//}
    //
    // The i_ibp_wrsp_chnl is selected by a MUX with encoded port id ptr
    // leda FM_2_22 off
    // LMD: Possible range overflow
    // LJ:  The id_ptr is generated correctly, so never overflow
    assign i_ibp_wrsp_chnl = o_wrsp_chnl[wrsp_chnl_port_id_ptr];
    assign i_ibp_wrsp_chnl_valid = (~wrsp_chnl_fifo_empty) & o_wrsp_chnl_valid[wrsp_chnl_port_id_ptr];
    // leda FM_2_22 on

  end//}
  endgenerate //}

endmodule //alb_mss_mem_ibp_split
