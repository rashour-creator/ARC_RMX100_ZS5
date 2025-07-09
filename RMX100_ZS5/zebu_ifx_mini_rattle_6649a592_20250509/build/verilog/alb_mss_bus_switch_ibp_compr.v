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
//  ###   ######  ######           #####  ####### #     # ######  ######
//   #    #     # #     #         #     # #     # ##   ## #     # #     #
//   #    #     # #     #         #       #     # # # # # #     # #     #
//   #    ######  ######          #       #     # #  #  # ######  ######
//   #    #     # #               #       #     # #     # #       #   #
//   #    #     # #               #     # #     # #     # #       #    #
//  ###   ######  #       #######  #####  ####### #     # #       #     #
//
// ===========================================================================
//
// Description:
//  Verilog module to compress multiple IBPs to one IBP
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "alb_mss_bus_switch_defines.v"

// Set simulation timescale
//
`include "const.def"



module mss_bus_switch_ibp_compr
  #(
// leda W175 off
// LMD: A parameter XXX has been defined but is not used
// LJ: Some parameters are not used in different configuraiton
    //COMP_NUM indicate how much of IBPs this module to compress
    parameter COMP_NUM = 4,
    // The Compressor FIFOs parameter
    //
    // The FIFO Depth indicated the FIFO entries
    parameter COMP_FIFO_DEPTH = 32,
    // FIFO_WIDTH to save the compressor port id, COMP_NUM=4 ports,
    // so 2 bits for port id
    parameter COMP_FIFO_WIDTH = 4,




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

    parameter RGON_W = 7,
    parameter USER_W = 7,
    parameter ID_WIDTH = 4

// leda W175 on
    )
  (
  // Because verilog do not support the multiple-dimension array, so we
  // packed different compressed IBP buses into a very wide bus named as
  // "i_bus_xxx". E.g, if there are <x> IBPs to be compressed, it will be
  // packed as i_bus_ibp_cmd_chnl = {ibp<x-1>_cmd_chnl, ... , ibp1_cmd_chnl, ibp0_cmd_chnl};
  // and the width of i_bus_ibp_cmd_chnl is COMP_NUM*CMD_CHNL_W
  //
  // Indicate which IBP can sent lock transaction, the unlock transaction is
  // coming from the same IBP
  // leda NTL_CON13C off
  // LMD: non driving internal net
  // LJ: Some signals bit field are indeed no driven
  // leda NTL_CON37 off
  // LMD: Signal/Net must read from the input port in module
  // LJ: Some signals bit field are indeed not read and used
  input  [COMP_NUM-1:0] i_bus_ibp_lockable,
  // leda NTL_CON37 on
  // leda NTL_CON13C on


  input  [COMP_NUM*ID_WIDTH-1:0] i_bus_ibp_uniq_id,
  input  [COMP_NUM*USER_W-1:0] i_bus_ibp_cmd_chnl_user,

  // command channel
  input  [COMP_NUM-1:0] i_bus_ibp_cmd_chnl_valid,
  output [COMP_NUM-1:0] i_bus_ibp_cmd_chnl_accept,
  input  [COMP_NUM*CMD_CHNL_W-1:0] i_bus_ibp_cmd_chnl,
  //
  // read data channel
  output [COMP_NUM-1:0] i_bus_ibp_rd_chnl_valid,
  input  [COMP_NUM-1:0] i_bus_ibp_rd_chnl_accept,
  output [COMP_NUM*RD_CHNL_W-1:0] i_bus_ibp_rd_chnl,
  //
  // write data channel
  input  [COMP_NUM-1:0] i_bus_ibp_wd_chnl_valid,
  output [COMP_NUM-1:0] i_bus_ibp_wd_chnl_accept,
  input  [COMP_NUM*WD_CHNL_W-1:0] i_bus_ibp_wd_chnl,
  //
  // write response channel
  output [COMP_NUM-1:0] i_bus_ibp_wrsp_chnl_valid,
  input  [COMP_NUM-1:0] i_bus_ibp_wrsp_chnl_accept,
  output [COMP_NUM*WRSP_CHNL_W-1:0] i_bus_ibp_wrsp_chnl,

  // The "o_xxx" bus is the compressed result IBP
  //
  // command channel
  output o_ibp_cmd_chnl_valid,
  input  o_ibp_cmd_chnl_accept,
  output reg [CMD_CHNL_W-1:0] o_ibp_cmd_chnl,
  output [ID_WIDTH-1:0] o_ibp_cmd_chnl_id,
  output [USER_W-1:0] o_ibp_cmd_chnl_user,
  //
  // read data channel
  input  o_ibp_rd_chnl_valid,
  output reg o_ibp_rd_chnl_accept,
  input  [RD_CHNL_W-1:0] o_ibp_rd_chnl,

  //
  // write data channel
  output o_ibp_wd_chnl_valid,
  input  o_ibp_wd_chnl_accept,
  output [WD_CHNL_W-1:0] o_ibp_wd_chnl,
  output [ID_WIDTH-1:0] o_ibp_wd_chnl_id,
  //
  // write response channel
  input  o_ibp_wrsp_chnl_valid,
  output reg o_ibp_wrsp_chnl_accept,
  input  [WRSP_CHNL_W-1:0] o_ibp_wrsp_chnl,

// leda NTL_CON13C off
// LMD: non driving port
// LJ: no care about this
  input                         clk,  // clock signal
  input                         rst_a // reset signal
// leda NTL_CON13C on
  );


genvar i;
generate //{
  if(COMP_NUM == 1) begin: comp_num_eq_1_gen//{
    assign i_bus_ibp_cmd_chnl_accept    = o_ibp_cmd_chnl_accept;
    assign o_ibp_cmd_chnl_valid         = i_bus_ibp_cmd_chnl_valid;
    assign o_ibp_cmd_chnl_id            = i_bus_ibp_uniq_id;
    assign o_ibp_wd_chnl_id             = i_bus_ibp_uniq_id;
    assign o_ibp_cmd_chnl_user          = i_bus_ibp_cmd_chnl_user;

    assign i_bus_ibp_rd_chnl_valid      = o_ibp_rd_chnl_valid;
    assign i_bus_ibp_rd_chnl            = o_ibp_rd_chnl;

    assign i_bus_ibp_wd_chnl_accept     = o_ibp_wd_chnl_accept;
    assign o_ibp_wd_chnl_valid          = i_bus_ibp_wd_chnl_valid ;
    assign o_ibp_wd_chnl                = i_bus_ibp_wd_chnl;

    always @ (*) begin: o_ibpt_PROC
      o_ibp_wrsp_chnl_accept       = i_bus_ibp_wrsp_chnl_accept;
      o_ibp_rd_chnl_accept         = i_bus_ibp_rd_chnl_accept;
      o_ibp_cmd_chnl               = i_bus_ibp_cmd_chnl;
    end

    assign i_bus_ibp_wrsp_chnl_valid    = o_ibp_wrsp_chnl_valid ;
    assign i_bus_ibp_wrsp_chnl          = o_ibp_wrsp_chnl;
  end//}
  else begin: comp_num_gt_1_gen//{
    // Distract different IBPs from packed i_bus_xxx,
    // and different IBPs will be declared as a two-dimension
    // array. E.g, i_ibp_cmd_chnl[0] will be IBP0, i_ibp_cmd_chnl[1]
    // will be IBP1, .etc.
    // The xxx_chnl_valid/accept/last signals are the channel handshake signals.
    //
    wire [COMP_NUM-1:0] i_ibp_cmd_chnl_valid;
    wire [COMP_NUM-1:0] i_ibp_cmd_chnl_valid_real;
    wire [COMP_NUM-1:0] i_ibp_cmd_chnl_accept;
    wire [CMD_CHNL_W-1:0] i_ibp_cmd_chnl[COMP_NUM-1:0];
    wire [ID_WIDTH-1:0] i_ibp_uniq_id[COMP_NUM-1:0];
    wire [USER_W-1:0] i_ibp_cmd_chnl_user[COMP_NUM-1:0];

      // IBP read data channel
    wire [COMP_NUM-1:0] i_ibp_rd_chnl_valid;
    wire [COMP_NUM-1:0] i_ibp_rd_chnl_accept;
    wire [RD_CHNL_W-1:0] i_ibp_rd_chnl[COMP_NUM-1:0];

      // IBP write data channel
    wire [COMP_NUM-1:0] i_ibp_wd_chnl_valid;
    wire [COMP_NUM-1:0] i_ibp_wd_chnl_accept;
    wire [WD_CHNL_W-1:0] i_ibp_wd_chnl[COMP_NUM-1:0];

      // IBP write data channel
    wire [COMP_NUM-1:0] i_ibp_wrsp_chnl_valid;
    wire [COMP_NUM-1:0] i_ibp_wrsp_chnl_accept;
    wire [WRSP_CHNL_W-1:0] i_ibp_wrsp_chnl[COMP_NUM-1:0];


    for(i = 0; i < COMP_NUM; i = i+1)//{
    begin:ibp_i_bus_decompact_gen
        assign i_ibp_cmd_chnl_valid[i] = i_bus_ibp_cmd_chnl_valid[i];
        assign i_bus_ibp_cmd_chnl_accept[i] = i_ibp_cmd_chnl_accept[i];
        assign i_ibp_cmd_chnl[i] = i_bus_ibp_cmd_chnl[(i*CMD_CHNL_W)+CMD_CHNL_W-1:(i*CMD_CHNL_W)];
        assign i_ibp_uniq_id[i] = i_bus_ibp_uniq_id[(i*ID_WIDTH)+ID_WIDTH-1:(i*ID_WIDTH)];
        assign i_ibp_cmd_chnl_user[i] = i_bus_ibp_cmd_chnl_user[(i*USER_W)+USER_W-1:(i*USER_W)];

          // IBP read data channel
        assign i_bus_ibp_rd_chnl_valid[i] = i_ibp_rd_chnl_valid[i];
        assign i_ibp_rd_chnl_accept[i] = i_bus_ibp_rd_chnl_accept[i];
        assign i_bus_ibp_rd_chnl[(i*RD_CHNL_W)+RD_CHNL_W-1:(i*RD_CHNL_W)] = i_ibp_rd_chnl[i];

          // IBP write data channel
        assign i_ibp_wd_chnl_valid[i] = i_bus_ibp_wd_chnl_valid[i];
        assign i_bus_ibp_wd_chnl_accept[i] = i_ibp_wd_chnl_accept[i];
        assign i_ibp_wd_chnl[i] = i_bus_ibp_wd_chnl[(i*WD_CHNL_W)+WD_CHNL_W-1:(i*WD_CHNL_W)];

          // IBP write resp channel
        assign i_bus_ibp_wrsp_chnl_valid[i] = i_ibp_wrsp_chnl_valid[i];
        assign i_ibp_wrsp_chnl_accept[i] = i_bus_ibp_wrsp_chnl_accept[i];
        assign i_bus_ibp_wrsp_chnl[(i*WRSP_CHNL_W)+WRSP_CHNL_W-1:(i*WRSP_CHNL_W)] = i_ibp_wrsp_chnl[i];

    end//}


    // The request vector to arbitration module, this reqeust vector contain valid requests for IBPs
    // valid request for each IBP met several conditions:
    // (*) IBP cmd_valid asserted, means there is a valid cmd coming
    // (*) Other requesting port is not locked up

    wire wdata_chnl_fifo_full;
    wire rdata_chnl_fifo_full;
    wire wresp_chnl_fifo_full;

    wire [COMP_NUM-1:0] ibp_compressor_req;
    reg  [COMP_NUM-1:0] other_i_ibp_locked;
    wire [COMP_NUM-1:0] ibp_compressor_wr_req;

    // leda NTL_CON13A off
    // LMD: non driving internal net
    // LJ: some of bit are indeed unused
    wire [COMP_NUM-1:0] i_ibp_wait_unlock;
    // leda NTL_CON13A on


    integer j;

    // leda NTL_CON16 off
    // LMD: Nets or cell pins should not be tied to logic 0 / logic 1
    // LJ: No care about the constant here
    // leda W159 off
    // LMD: Constant condition expression $unsigned(j) != i
    // LJ: No care about the constant here
    // leda W159 on
    // leda NTL_CON16 on
     always @*
     begin : other_ibp_PROC
         other_i_ibp_locked = 0;
         for (int i = 0; i < COMP_NUM; i = i+1) begin       // moved inside the always block
           for (int j = 0; j < COMP_NUM; j = j+1) begin
             if (i != j) begin
               other_i_ibp_locked[i] = other_i_ibp_locked[i] | i_ibp_wait_unlock[j];
             end
           end
         end
     end

    for(i = 0; i < COMP_NUM; i = i+1)//{
    begin:ibp_compressor_req_gen
      assign i_ibp_cmd_chnl_valid_real[i] = i_ibp_cmd_chnl_valid[i] & (~other_i_ibp_locked[i])
                            & (~rdata_chnl_fifo_full)
                            & (~wresp_chnl_fifo_full)
                            & (~wdata_chnl_fifo_full);

      assign ibp_compressor_req[i] = i_ibp_cmd_chnl_valid_real[i];
      assign ibp_compressor_wr_req[i] = (~i_ibp_cmd_chnl[i][CMD_CHNL_READ]);
    end//}

    wire [COMP_NUM-1:0] ibp_compressor_grt;

    wire o_ibp_cmd_chnl_hashked;
    // Maintain the round-robin token
    mss_bus_switch_rrobin # (
      .ARB_NUM(COMP_NUM)
      ) u_ibp_compressor_rrobin(
      .req_vector          (ibp_compressor_req),
      .grt_vector          (ibp_compressor_grt),
      .arb_taken           (o_ibp_cmd_chnl_hashked),
      .clk                 (clk                ),
      .rst_a               (rst_a              )
    );

    wire wdata_chnl_fifo_empty;
    wire wdata_chnl_fifo_wen_raw;
    wire wdata_chnl_fifo_ren_raw;
    // When the cmd and wdata can be handshaked together, and wdata_chnl_fifo is empty
    // and the write is a single-beat transaction, then
    // then we skip write the wdata_chnl_fifo with port IDs
    wire byp_wdata_chnl_fifo = wdata_chnl_fifo_empty & wdata_chnl_fifo_wen_raw & wdata_chnl_fifo_ren_raw;


    // Each in IBP will be accepted (i_ibp_cmd_chnl_accept[i]) when met several conditions:
    // (*) Arbiter granted
    // (*) The o_ibp_cmd channel can accept
    assign i_ibp_cmd_chnl_accept = ibp_compressor_grt & {COMP_NUM{o_ibp_cmd_chnl_accept}};

    assign o_ibp_cmd_chnl_hashked = o_ibp_cmd_chnl_accept & o_ibp_cmd_chnl_valid;

    wire [COMP_FIFO_WIDTH-1:0] wdata_chnl_fifo_rdat;

    reg [ID_WIDTH-1:0] ibp_compressor_grt_uniq_id;
    reg [USER_W-1:0] ibp_compressor_grt_user;
    always @ (*) begin: ibp_compressor_grt_PROC
      ibp_compressor_grt_uniq_id = {ID_WIDTH{1'b0}};
      ibp_compressor_grt_user = {USER_W{1'b0}};
      for(j = 0; j < COMP_NUM; j = j+1) begin//{
        ibp_compressor_grt_uniq_id = ibp_compressor_grt_uniq_id | {ID_WIDTH{ibp_compressor_grt[j]}} & i_ibp_uniq_id[j];
        ibp_compressor_grt_user    = ibp_compressor_grt_user    | {USER_W  {ibp_compressor_grt[j]}} & i_ibp_cmd_chnl_user[j];
      end//}
    end


    wire [COMP_FIFO_WIDTH-1:0] wdata_chnl_fifo_wdat = ibp_compressor_grt_uniq_id;


    // Because the wd channel is independent and in-ordered, we need a fifo to save the outstanding cmd port id
    assign wdata_chnl_fifo_wen_raw = o_ibp_cmd_chnl_hashked & (~o_ibp_cmd_chnl[CMD_CHNL_READ]);
    wire wdata_chnl_fifo_wen = wdata_chnl_fifo_wen_raw & (~byp_wdata_chnl_fifo);
    // wdata channel FIFO is read when:
    // (*) Any transactions in wdata channel is hanshaked
    // (*) It is the last beat for this transaction
    wire o_ibp_wd_chnl_last = o_ibp_wd_chnl[WD_CHNL_LAST];
    wire o_ibp_wd_chnl_last_hashked = o_ibp_wd_chnl_accept & o_ibp_wd_chnl_valid & o_ibp_wd_chnl_last;
    assign wdata_chnl_fifo_ren_raw = o_ibp_wd_chnl_last_hashked;
    wire wdata_chnl_fifo_ren = wdata_chnl_fifo_ren_raw & (~byp_wdata_chnl_fifo);
    // fifo_rdat is used for the wdata channel port ID pointer


    wire wdata_chnl_fifo_i_valid;
    wire wdata_chnl_fifo_o_valid;
    wire wdata_chnl_fifo_i_ready;
    wire wdata_chnl_fifo_o_ready;
    assign wdata_chnl_fifo_i_valid = wdata_chnl_fifo_wen;
    assign wdata_chnl_fifo_full    = (~wdata_chnl_fifo_i_ready);
    assign wdata_chnl_fifo_o_ready = wdata_chnl_fifo_ren;
    assign wdata_chnl_fifo_empty   = (~wdata_chnl_fifo_o_valid);

    mss_bus_switch_fifo # (
      .FIFO_DEPTH(COMP_FIFO_DEPTH),
      .FIFO_WIDTH(COMP_FIFO_WIDTH),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
    ) wdata_chnl_fifo(
      .i_clk_en  (1'b1  ),
      .o_clk_en  (1'b1  ),
      .i_valid   (wdata_chnl_fifo_i_valid),
      .i_ready   (wdata_chnl_fifo_i_ready),
      .o_valid   (wdata_chnl_fifo_o_valid),
      .o_ready   (wdata_chnl_fifo_o_ready),
      .i_data    (wdata_chnl_fifo_wdat ),
      .o_data    (wdata_chnl_fifo_rdat ),
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


    wire [COMP_FIFO_WIDTH-1:0] back_rdata_chnl_uniq_id;
    wire [COMP_FIFO_WIDTH-1:0] back_wresp_chnl_uniq_id;

    // The FIFOs generation including
    // rdata_chnl_fifo, wresp_chnl_fifo
    // Because the IBP is in-ordered bus and each channel are independent with each other,
    // So when any transactions is passed to output command channel, all the FIFOs
    // are enqueued, and when any transactions get back from wdata/rdata/wresp channels
    // they dequeue respective FIFO to get port ID.

    // wdata/rdata/wresp channel FIFO is wrote when:
    // (*) Any transactions in command channel is handshaked to out command channel
    wire rdata_chnl_fifo_wen = o_ibp_cmd_chnl_hashked & o_ibp_cmd_chnl[CMD_CHNL_READ];
    wire wresp_chnl_fifo_wen = o_ibp_cmd_chnl_hashked & (~o_ibp_cmd_chnl[CMD_CHNL_READ]);
    // All wrote with the port ID.
    wire [COMP_FIFO_WIDTH-1:0] rdata_chnl_fifo_wdat = ibp_compressor_grt_uniq_id;
    wire [COMP_FIFO_WIDTH-1:0] wresp_chnl_fifo_wdat = ibp_compressor_grt_uniq_id;


    // rdata channel FIFO is read when:
    // (*) Any transactions in rdata channel is hanshaked
    // (*) It is the last beat for this transaction
    // Or:
    wire o_ibp_rd_chnl_last = o_ibp_rd_chnl[RD_CHNL_RD_LAST];
    wire o_ibp_rd_chnl_hashked = (o_ibp_rd_chnl_accept & o_ibp_rd_chnl_valid & o_ibp_rd_chnl_last);
    wire rdata_chnl_fifo_ren = o_ibp_rd_chnl_hashked;
    // fifo_rdat is used for the rdata channel port ID pointer
    wire [COMP_FIFO_WIDTH-1:0] rdata_chnl_fifo_rdat;

    // wresp channel FIFO is read when:
    // (*) Any transactions in wresp channel is hanshaked
    wire o_ibp_wrsp_chnl_hashked = o_ibp_wrsp_chnl_accept & o_ibp_wrsp_chnl_valid;
    wire wresp_chnl_fifo_ren = o_ibp_wrsp_chnl_hashked;
    // fifo_rdat is used for the wresp channel port ID pointer
    wire [COMP_FIFO_WIDTH-1:0] wresp_chnl_fifo_rdat;

    //
    wire rdata_chnl_fifo_empty;
    wire wresp_chnl_fifo_empty;


    wire rdata_chnl_fifo_i_valid;
    wire rdata_chnl_fifo_o_valid;
    wire rdata_chnl_fifo_i_ready;
    wire rdata_chnl_fifo_o_ready;
    assign rdata_chnl_fifo_i_valid = rdata_chnl_fifo_wen;
    assign rdata_chnl_fifo_full    = (~rdata_chnl_fifo_i_ready);
    assign rdata_chnl_fifo_o_ready = rdata_chnl_fifo_ren;
    assign rdata_chnl_fifo_empty   = (~rdata_chnl_fifo_o_valid);

    mss_bus_switch_fifo # (
      .FIFO_DEPTH(COMP_FIFO_DEPTH),
      .FIFO_WIDTH(COMP_FIFO_WIDTH),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
    ) rdata_chnl_fifo(
      .i_clk_en  (1'b1  ),
      .o_clk_en  (1'b1  ),
      .i_valid   (rdata_chnl_fifo_i_valid),
      .i_ready   (rdata_chnl_fifo_i_ready),
      .o_valid   (rdata_chnl_fifo_o_valid),
      .o_ready   (rdata_chnl_fifo_o_ready),
      .i_data    (rdata_chnl_fifo_wdat ),
      .o_data    (rdata_chnl_fifo_rdat ),
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

    wire wresp_chnl_fifo_i_valid;
    wire wresp_chnl_fifo_o_valid;
    wire wresp_chnl_fifo_i_ready;
    wire wresp_chnl_fifo_o_ready;
    assign wresp_chnl_fifo_i_valid = wresp_chnl_fifo_wen;
    assign wresp_chnl_fifo_full    = (~wresp_chnl_fifo_i_ready);
    assign wresp_chnl_fifo_o_ready = wresp_chnl_fifo_ren;
    assign wresp_chnl_fifo_empty   = (~wresp_chnl_fifo_o_valid);

    mss_bus_switch_fifo # (
      .FIFO_DEPTH(COMP_FIFO_DEPTH),
      .FIFO_WIDTH(COMP_FIFO_WIDTH),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(0)
    ) wresp_chnl_fifo(
      .i_clk_en  (1'b1  ),
      .o_clk_en  (1'b1  ),
      .i_valid   (wresp_chnl_fifo_i_valid),
      .i_ready   (wresp_chnl_fifo_i_ready),
      .o_valid   (wresp_chnl_fifo_o_valid),
      .o_ready   (wresp_chnl_fifo_o_ready),
      .i_data    (wresp_chnl_fifo_wdat ),
      .o_data    (wresp_chnl_fifo_rdat ),
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


    assign back_rdata_chnl_uniq_id = rdata_chnl_fifo_rdat;
    assign back_wresp_chnl_uniq_id = wresp_chnl_fifo_rdat;

    assign o_ibp_wd_chnl_id = wdata_chnl_fifo_empty ? ibp_compressor_grt_uniq_id : wdata_chnl_fifo_rdat;
    assign o_ibp_cmd_chnl_id = ibp_compressor_grt_uniq_id;
    assign o_ibp_cmd_chnl_user    = ibp_compressor_grt_user;

    // The Lock indication generation
    //
    // Because the IBP require the lock transactions go with back-to-back pairs,
    // So we must make sure the lock pairs from one request port going through
    // IBP compressor cannot be break up and interleaved by transactions
    // from other requesting port.
    // i.e, if any port have sent a lock trsnaction, the compressor arbitor is
    // locked up for this port until this port sent another non-lock transaction
    // to unlock this port.
    // So, The lock is marked for each requesting port, to support the lock behavior
    // leda NTL_CON32 off
    // LMD: Change on net has no effect
    // LJ: no care about this
    reg  [COMP_NUM-1:0] i_ibp_locked_r;
    // leda NTL_CON32 on
    wire [COMP_NUM-1:0] i_ibp_locked_set;
    wire [COMP_NUM-1:0] i_ibp_locked_clr;
    wire [COMP_NUM-1:0] i_ibp_locked_ena;
    wire [COMP_NUM-1:0] i_ibp_locked_nxt;

    for(i = 0; i < COMP_NUM; i = i+1)//{
    begin:i_ibp_locked_r_gen
      // The lock_r is set when this lockable port cmd have lock read attribute and is handshaked
      assign i_ibp_locked_set[i] = i_ibp_cmd_chnl_valid[i] & i_ibp_cmd_chnl_accept[i] & i_ibp_cmd_chnl[i][CMD_CHNL_LOCK] & i_bus_ibp_lockable[i];
      // The lock_r is cleared when its corrospending unlock port (same i port) cmd have non-lock attribute write and is handshaked
      assign i_ibp_locked_clr[i] = i_ibp_cmd_chnl_valid[i] & i_ibp_cmd_chnl_accept[i] & (~i_ibp_cmd_chnl[i][CMD_CHNL_LOCK]);
      assign i_ibp_locked_ena[i] = i_ibp_locked_set[i] | i_ibp_locked_clr[i];
      assign i_ibp_locked_nxt[i] = i_ibp_locked_set[i] & (~i_ibp_locked_clr[i]);

    // spyglass disable_block FlopEConst
    // SMD: Flip-flop enable pin is permanently disabled or enabled
    // SJ: No care about enable pin is a constant value
      always @(posedge clk or posedge rst_a)
      begin : i_ibp_locked_DFFEAR_PROC
        if (rst_a == 1'b1) begin
            i_ibp_locked_r[i]        <= 1'b0;
        end
        else if (i_ibp_locked_ena[i] == 1'b1) begin
            i_ibp_locked_r[i]        <= i_ibp_locked_nxt[i];
        end
      end
    // spyglasss enable_block FlopEConst


    end//}

    // The same IBP locked IBP is the wanted unlocking IBP
    // leda NTL_CON13A off
    // LMD: non driving internal net
    // LJ: some of bit are indeed unused
    // leda NTL_CON16 off
    // LMD: Nets or cell pins should not be tied to logic 0 / logic 1
    // LJ: No care about the constant here
    assign i_ibp_wait_unlock = i_ibp_locked_r;
    // leda NTL_CON16 on
    // leda NTL_CON13A on






    // The out command channel generation
    //
    // The o_ibp_cmd_chnl_valid need to be generated very carefully,
    // it is generated when several conditions met:
    // (*) Any IBP (to be compressed) have cmd_chnl_valid (real) asserted
    // Must exclude the o_ibp_cmd_chnl_accept here because we need to make sure
    // the o_ibp_cmd_chnl_valid is asserting for request even when out IBP bus cannot accept.
    assign o_ibp_cmd_chnl_valid = (|i_ibp_cmd_chnl_valid_real);
    //
    // The o_ibp_cmd_chnl is generated by a MUX with one-hot select vector ibp_compressor_grt

    wire [COMP_NUM-1:0] byp_i_ibp_wd_chnl_accept = (ibp_compressor_wr_req & ibp_compressor_grt & {COMP_NUM{o_ibp_wd_chnl_accept}});
    wire byp_o_ibp_wd_chnl_valid = (|(ibp_compressor_wr_req & ibp_compressor_grt & i_ibp_wd_chnl_valid));

    reg [WD_CHNL_W-1:0] byp_o_ibp_wd_chnl;
    always @ (*) begin: o_ibp_cmd_chnl_PROC
      o_ibp_cmd_chnl = {CMD_CHNL_W{1'b0}};
      byp_o_ibp_wd_chnl = {WD_CHNL_W{1'b0}};
      for(j = 0; j < COMP_NUM; j = j+1) begin//{
        o_ibp_cmd_chnl = o_ibp_cmd_chnl | {CMD_CHNL_W{ibp_compressor_grt[j]}} & i_ibp_cmd_chnl[j];
        byp_o_ibp_wd_chnl = byp_o_ibp_wd_chnl | ({WD_CHNL_W{ibp_compressor_grt[j]}} & i_ibp_wd_chnl[j]);
      end//}
    end

    // The out wdata channel generation
    //
    reg fifoed_o_ibp_wd_chnl_valid;
    reg [WD_CHNL_W-1:0] fifoed_o_ibp_wd_chnl;

    always @ (*) begin: o_ibp_wd_chnl_PROC
      fifoed_o_ibp_wd_chnl_valid = 1'b0;
      fifoed_o_ibp_wd_chnl           = {WD_CHNL_W{1'b0}};
      for(j = 0; j < COMP_NUM; j = j+1) begin//{
        fifoed_o_ibp_wd_chnl_valid = (fifoed_o_ibp_wd_chnl_valid
                  | ((wdata_chnl_fifo_rdat == i_ibp_uniq_id[j]) & i_ibp_wd_chnl_valid[j] & (~wdata_chnl_fifo_empty)) );
        fifoed_o_ibp_wd_chnl = (fifoed_o_ibp_wd_chnl
                  | ({WD_CHNL_W{(wdata_chnl_fifo_rdat == i_ibp_uniq_id[j])}} & i_ibp_wd_chnl[j]) );
      end//}
    end

    wire [COMP_NUM-1:0] fifoed_i_ibp_wd_chnl_accept;
    for(i = 0; i < COMP_NUM; i = i+1)//{
    begin:o_ibp_wd_chnl_routing_gen
      assign fifoed_i_ibp_wd_chnl_accept[i] = (wdata_chnl_fifo_rdat == i_ibp_uniq_id[i])
                                         & o_ibp_wd_chnl_accept
                                         & (~wdata_chnl_fifo_empty);
    end//}

    assign i_ibp_wd_chnl_accept = wdata_chnl_fifo_empty ? byp_i_ibp_wd_chnl_accept : fifoed_i_ibp_wd_chnl_accept;
    assign o_ibp_wd_chnl_valid = wdata_chnl_fifo_empty ? byp_o_ibp_wd_chnl_valid : fifoed_o_ibp_wd_chnl_valid;
    assign o_ibp_wd_chnl = wdata_chnl_fifo_empty ? byp_o_ibp_wd_chnl : fifoed_o_ibp_wd_chnl;



    // The out rdata channel generation
    //
    // The o_ibp_rd_chnl_accept is generated when several conditions met:
    // (*) Any rdata ptr pointed IBP (to be compressed) have rdata_chnl_accept asserted
    // leda FM_2_22 off
    // LMD: Possible range overflow
    // LJ:  The id_ptr is generated correctly, so never overflow
    always @ (*) begin: o_ibp_rd_chnl_accept_PROC
      o_ibp_rd_chnl_accept = 1'b0;
      for(j = 0; j < COMP_NUM; j = j+1) begin//{
        o_ibp_rd_chnl_accept = (o_ibp_rd_chnl_accept
                  | ((back_rdata_chnl_uniq_id == i_ibp_uniq_id[j]) & i_ibp_rd_chnl_accept[j]) );
      end//}
    end
    // leda FM_2_22 on
    //
    // The o_ibp_rd_chnl is routed to the all IBPs (to be compressed)
    for(i = 0; i < COMP_NUM; i = i+1)//{
    begin:o_ibp_rd_chnl_routing_gen
      assign i_ibp_rd_chnl[i] = o_ibp_rd_chnl;
      assign i_ibp_rd_chnl_valid[i] = (back_rdata_chnl_uniq_id == i_ibp_uniq_id[i]) & o_ibp_rd_chnl_valid ;
    end//}

    // The out wresp channel generation
    //
    // The o_ibp_wrsp_chnl_accept is generated when several conditions met:
    // (*) Any wresp ptr pointed IBP (to be compressed) have wresp_chnl_accept asserted
    // leda FM_2_22 off
    // LMD: Possible range overflow
    // LJ:  The id_ptr is generated correctly, so never overflow
    always @ (*) begin: o_ibp_wrsp_chnl_accept_PROC
      o_ibp_wrsp_chnl_accept = 1'b0;
      for(j = 0; j < COMP_NUM; j = j+1) begin//{
        o_ibp_wrsp_chnl_accept = (o_ibp_wrsp_chnl_accept
                  | ((back_wresp_chnl_uniq_id == i_ibp_uniq_id[j]) & i_ibp_wrsp_chnl_accept[j]) );
      end//}
    end
    // leda FM_2_22 on
    //
    // The o_ibp_wrsp_chnl is routed to the all IBPs (to be compressed)
    for(i = 0; i < COMP_NUM; i = i+1)//{
    begin:o_ibp_wrsp_chnl_routing_gen
      assign i_ibp_wrsp_chnl[i] = o_ibp_wrsp_chnl;
      assign i_ibp_wrsp_chnl_valid[i] = (back_wresp_chnl_uniq_id == i_ibp_uniq_id[i]) & o_ibp_wrsp_chnl_valid;
    end//}



  end//}
endgenerate//}


endmodule //
