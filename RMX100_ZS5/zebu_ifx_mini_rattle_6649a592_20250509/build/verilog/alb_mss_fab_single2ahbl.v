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
// ibp-single-to-AHB
//
// ===========================================================================
//
// Description:
//  Verilog module to convert the IBP single to AHB-Lite protocol
//  No support exclusive, no support the sparse mask
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"

module alb_mss_fab_single2ahbl
  #(
    parameter CHNL_FIFO_DEPTH = 2,
    parameter ADDR_W = 32,
    parameter DATA_W = 64
    )
  (
  // The "ibp_xxx" bus is the one IBP to be converted
  // command channel
  // This module do not support the id and snoop
  input  wire                  ibp_cmd_valid,
  output wire                  ibp_cmd_accept,
  input  wire                  ibp_cmd_read,
  input  wire [ADDR_W-1:0]     ibp_cmd_addr,
  input  wire                  ibp_cmd_wrap,
  input  wire [2:0]            ibp_cmd_data_size,
  input  wire [3:0]            ibp_cmd_burst_size,
  input  wire                  ibp_cmd_lock,
  input  wire [1:0]            ibp_cmd_prot,
  input  wire [3:0]            ibp_cmd_cache,
  input  wire                  ibp_cmd_excl,
  input  wire                  ibp_cmd_burst_en,
  input  wire [2:0]            ibp_cmd_burst_type,
  input  wire                  ibp_cmd_burst_last,
  input  wire                  ibp_cmd_wr_splt_last,
  //
  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  output wire                  ibp_rd_valid,
  input  wire                  ibp_rd_accept,
  output reg  [DATA_W-1:0]     ibp_rd_data,
  output wire                  ibp_err_rd,
  output wire                  ibp_rd_excl_ok,
  //
  // write data channel
  input  wire                  ibp_wr_valid,
  output wire                  ibp_wr_accept,
  input  wire [DATA_W-1:0]     ibp_wr_data,
  //
  // write response channel
  // This module do not support id
  output wire                  ibp_wr_done,
  output wire                  ibp_err_wr,
  input  wire                  ibp_wr_resp_accept,
  output wire                  ibp_wr_excl_done,

  // The "ahb_xxx" bus is the AHB-Lite interface after converted
  output wire [1:0]            ahb_htrans,    // AHB transaction type (IDLE, BUSY, SEQ, NSEQ)
  output wire                  ahb_hwrite,    // If true then write
  output wire                  ahb_hlock,     // If true then locked
  output wire [ADDR_W-1:0]     ahb_haddr,     // Address
  output wire [2:0]            ahb_hsize,     // Transaction size
  output wire [2:0]            ahb_hburst,    // Burst type SINGLE, INCR, etc
  output wire [3:0]            ahb_hprot,     // Protection attributes
  output wire                  ahb_hexcl,     // If true then exclusive
  output wire [DATA_W-1:0]     ahb_hwdata,    // Write data
  input  wire [DATA_W-1:0]     ahb_hrdata,    // Read data
  input  wire                  ahb_hresp,     // Response 0=OK, 1=ERROR
  input  wire                  ahb_hrexok,    // Exclusive response 0=FAIL, 1=SUCCESS (non standard)
  input  wire                  ahb_hready,    // AHB transfer ready

  // Clock and reset
  input                   clk,           // clock signal
  input                   bus_clk_en,    // clock enable signal to control the N:1 clock ratios
  input                   rst_a,         // reset signal
  input                   bigendian      // support big endian
  );

  //--------------------------------------------
  // Parameters Definition
  //--------------------------------------------
  // local parameters
  localparam AFIFO_DEPTH = (CHNL_FIFO_DEPTH+0);
  localparam WFIFO_DEPTH = (CHNL_FIFO_DEPTH+1);
  localparam RFIFO_DEPTH = (CHNL_FIFO_DEPTH+1);

  // Because ibp2ahb at most have 5 outstandings (2 Afifo entries + 3 Rfifo entries)
  //localparam OUT_CMD_CNT_W    = 3;// no need to worry about the cnt overflow then

  // AHB FSM states
  localparam STA_W            = 2;
  localparam STA_ADDR_ONLY    = 2'b00;    // AHB state machine
  localparam STA_ADDR_WDATA   = 2'b01;
  localparam STA_ADDR_RDATA   = 2'b10;

  // AHB protocol macros
  localparam AHB_BURST_SINGLE = 3'b000;   // AHB Burst Type
  localparam AHB_BURST_INCR   = 3'b001;
  localparam AHB_BURST_WRAP4  = 3'b010;
  localparam AHB_BURST_INCR4  = 3'b011;
  localparam AHB_BURST_WRAP8  = 3'b100;
  localparam AHB_BURST_INCR8  = 3'b101;
  localparam AHB_BURST_WRAP16 = 3'b110;
  localparam AHB_BURST_INCR16 = 3'b111;

  localparam AHB_TRANS_IDLE   = 2'b00;    // AHB Transfer Type
  localparam AHB_TRANS_BUSY   = 2'b01;
  localparam AHB_TRANS_NONSEQ = 2'b10;
  localparam AHB_TRANS_SEQ    = 2'b11;

  //--------------------------------------------------
  // Local wires/regs
  //--------------------------------------------------
  reg [STA_W-1:0] ahb_state_r;
  reg             ahb_lock_flag_r;
  reg             ahb_lock2idle_r;

  reg [DATA_W-1:0]  ibp_wr_data_tmp;
  wire [DATA_W-1:0] ibp_rd_data_tmp;

  //--------------------------------------------------
  // Miscellaneous Logics
  //--------------------------------------------------
  wire [ADDR_W-1:0] ibp_cmd_addr_aligned =
  //3'b100: Quad-word transfer
  (ibp_cmd_data_size == 4) ? {ibp_cmd_addr[ADDR_W-1:4],4'b0000} :
  //3'b011: Double-word transfer
  (ibp_cmd_data_size == 3) ? {ibp_cmd_addr[ADDR_W-1:3],3'b000} :
  //3'b010: Word transfer
  (ibp_cmd_data_size == 2) ? {ibp_cmd_addr[ADDR_W-1:2],2'b00} :
  //3'b001: Half-word transfer
  (ibp_cmd_data_size == 1) ? {ibp_cmd_addr[ADDR_W-1:1],1'b0} :
  //3'b000: Byte transfer
                                  ibp_cmd_addr[ADDR_W-1:0];

  //--------------------------------------------------
  // IBP Command FIFO instantiation
  //--------------------------------------------------
 // The Ping-pong buffers to save the IBP commands
  wire                  afifo_o_cmd_read;
  wire [ADDR_W-1:0]     afifo_o_cmd_addr;
  wire                  afifo_o_cmd_wrap;
  wire [2:0]            afifo_o_cmd_data_size;
  wire [3:0]            afifo_o_cmd_burst_size;
  wire                  afifo_o_cmd_lock;
  wire [1:0]            afifo_o_cmd_prot;
  wire [3:0]            afifo_o_cmd_cache;
  wire                  afifo_o_cmd_excl;

  wire                  afifo_o_cmd_burst_en;
  wire [2:0]            afifo_o_cmd_burst_type;
  wire                  afifo_o_cmd_burst_last;
  wire                  afifo_o_cmd_wr_splt_last;

  assign ahb_hwrite   =  (~afifo_o_cmd_read);
  assign ahb_hlock    =  (afifo_o_cmd_lock | ahb_lock_flag_r) & (~ahb_lock2idle_r);
  assign ahb_hexcl    =  afifo_o_cmd_excl;
  assign ahb_haddr    =  afifo_o_cmd_addr;
  assign ahb_hsize    =  afifo_o_cmd_data_size;
  assign ahb_hburst   =  afifo_o_cmd_burst_type;
  assign ahb_hprot    =  {
                          afifo_o_cmd_cache[2],
                          afifo_o_cmd_cache[3],
                          afifo_o_cmd_prot[0],
                          (~afifo_o_cmd_prot[1])
                         };

  wire afifo_o_ready;
  wire afifo_o_valid;

  wire afifo_i_ready;
  wire afifo_i_valid = ibp_cmd_valid;
  assign ibp_cmd_accept = afifo_i_ready;

  localparam AFIFO_W = (1+ADDR_W+1+3+4+1+2+4+1+1+3+1+1);
  wire [AFIFO_W-1:0] afifo_o_data;
  wire [AFIFO_W-1:0] afifo_i_data =
                                    {
                                     ibp_cmd_read,
                                     ibp_cmd_addr_aligned,
                                     ibp_cmd_wrap,
                                     ibp_cmd_data_size,
                                     ibp_cmd_burst_size,
                                     ibp_cmd_lock,
                                     ibp_cmd_prot,
                                     ibp_cmd_cache,
                                     ibp_cmd_excl,
                                     ibp_cmd_burst_en,
                                     ibp_cmd_burst_type,
                                     ibp_cmd_burst_last,
                                     ibp_cmd_wr_splt_last
                                    };

  assign {
          afifo_o_cmd_read,
          afifo_o_cmd_addr,
          afifo_o_cmd_wrap,
          afifo_o_cmd_data_size,
          afifo_o_cmd_burst_size,
          afifo_o_cmd_lock,
          afifo_o_cmd_prot,
          afifo_o_cmd_cache,
          afifo_o_cmd_excl,
          afifo_o_cmd_burst_en,
          afifo_o_cmd_burst_type,
          afifo_o_cmd_burst_last,
          afifo_o_cmd_wr_splt_last
        }                         = afifo_o_data;

    alb_mss_fab_fifo #(
      .FIFO_DEPTH(AFIFO_DEPTH),
      .FIFO_WIDTH(AFIFO_W),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(1),
      .I_SUPPORT_RTIO(0)
    ) u_ahb_afifo (
      .i_clk_en    (1'b1),
      .i_ready     (afifo_i_ready),
      .i_valid     (afifo_i_valid),
      .i_data      (afifo_i_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
      .i_occp      (),
      .o_occp      (),
// leda B_1011 on
// leda WV951025 on

      .o_clk_en    (bus_clk_en),
      .o_ready     (afifo_o_ready),
      .o_valid     (afifo_o_valid),
      .o_data      (afifo_o_data ),

      .clk         (clk  ),
      .rst_a       (rst_a)
      );

  //--------------------------------------------------
  // IBP Write Data FIFO instantiation
  //--------------------------------------------------
  // The 3-entries FIFO to save the IBP wdatas
  wire [DATA_W-1:0]     wfifo_o_wr_data;

  wire wfifo_o_ready;
  wire wfifo_o_valid;

  // Notes: Move to ahb_single2sparse to handle the direct write data path only,
  //        because dead lock might be introduced when handling side buffer data path
  //wire cmd_wait_wd_cnt_udf;
  //wire ibp_cmd_wait_wd = (ibp_cmd_valid & ibp_cmd_accept & (~ibp_cmd_read)) | (~cmd_wait_wd_cnt_udf);

  wire wfifo_i_ready;
  //wire wfifo_i_valid = ibp_wr_valid & ibp_cmd_wait_wd;
  wire wfifo_i_valid = ibp_wr_valid;
  //assign ibp_wr_accept = wfifo_i_ready & ibp_cmd_wait_wd;
  assign ibp_wr_accept = wfifo_i_ready;

  localparam WFIFO_W = DATA_W;
  wire [WFIFO_W-1:0] wfifo_o_data;
  wire [WFIFO_W-1:0] wfifo_i_data =
                                    {
                                     ibp_wr_data_tmp
                                    };

  assign {
            wfifo_o_wr_data
         }                        = wfifo_o_data;

  wire [WFIFO_DEPTH:0] wfifo_occp;

  alb_mss_fab_fifo #(
      .FIFO_DEPTH(WFIFO_DEPTH),
      .FIFO_WIDTH(WFIFO_W),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(1),
      .I_SUPPORT_RTIO(0)
    ) u_ahb_wfifo (
      .i_clk_en    (1'b1),
      .i_ready     (wfifo_i_ready),
      .i_valid     (wfifo_i_valid),
      .i_data      (wfifo_i_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
      .i_occp      (),
// leda B_1011 on
// leda WV951025 on

      .o_clk_en    (bus_clk_en),
      .o_ready     (wfifo_o_ready),
      .o_valid     (wfifo_o_valid),
      .o_data      (wfifo_o_data ),
      .o_occp      (wfifo_occp ),

      .clk         (clk  ),
      .rst_a       (rst_a)
      );

  assign ahb_hwdata   = wfifo_o_wr_data;

  //--------------------------------------------------
  // IBP Read Data & Write Response FIFO instantiation
  //--------------------------------------------------
  // The 3-entries FIFO to save the IBP rdatas & bresp
  wire                  rfifo_i_wr_done      = (ahb_state_r == STA_ADDR_WDATA) & (~ahb_hrexok) & (~ahb_hresp);
  wire                  rfifo_i_err_wr       = (ahb_state_r == STA_ADDR_WDATA) & ahb_hresp;
  wire                  rfifo_i_wr_excl_done = (ahb_state_r == STA_ADDR_WDATA) & ahb_hrexok & (~ahb_hresp);

  wire [DATA_W-1:0]     rfifo_i_rd_data    = ahb_hrdata;
  wire                  rfifo_i_err_rd     = (ahb_state_r == STA_ADDR_RDATA) & ahb_hresp;
  wire                  rfifo_i_rd_valid   = (ahb_state_r == STA_ADDR_RDATA) & (~ahb_hresp);
  wire                  rfifo_i_rd_excl_ok = (ahb_state_r == STA_ADDR_RDATA) & ahb_hrexok & (~ahb_hresp);

  wire                  rfifo_o_wr_done;
  wire                  rfifo_o_err_wr;
  wire                  rfifo_o_wr_excl_done;

  wire                  rfifo_o_rd_valid;
  wire [DATA_W-1:0]     rfifo_o_rd_data;
  wire                  rfifo_o_err_rd;
  wire                  rfifo_o_rd_excl_ok;

  wire                  rfifo_o_valid;

  assign ibp_rd_data_tmp  = rfifo_o_rd_data;
  assign ibp_rd_valid     = rfifo_o_valid & rfifo_o_rd_valid;
  assign ibp_err_rd       = rfifo_o_valid & rfifo_o_err_rd;
  assign ibp_rd_excl_ok   = rfifo_o_valid & rfifo_o_rd_excl_ok;
  assign ibp_wr_done      = rfifo_o_valid & rfifo_o_wr_done;
  assign ibp_err_wr       = rfifo_o_valid & rfifo_o_err_wr;
  assign ibp_wr_excl_done = rfifo_o_valid & rfifo_o_wr_excl_done;

  wire ibp_rd_chnl_valid   = (ibp_rd_valid | ibp_err_rd);
  wire ibp_wrsp_chnl_valid = rfifo_o_valid & (rfifo_o_wr_done | rfifo_o_err_wr | rfifo_o_wr_excl_done);
  wire rfifo_o_ready       = (ibp_rd_chnl_valid & ibp_rd_accept) | (ibp_wrsp_chnl_valid & ibp_wr_resp_accept);

  localparam RFIFO_W = (DATA_W+1+3+1+1);
  wire [RFIFO_W-1:0] rfifo_o_data;
  wire [RFIFO_W-1:0] rfifo_i_data =
                                    {
                                     rfifo_i_rd_valid,
                                     rfifo_i_rd_data,
                                     rfifo_i_err_rd,
                                     rfifo_i_rd_excl_ok,
                                     rfifo_i_wr_done,
                                     rfifo_i_err_wr,
                                     rfifo_i_wr_excl_done
                                    };

  assign {
          rfifo_o_rd_valid,
          rfifo_o_rd_data,
          rfifo_o_err_rd,
          rfifo_o_rd_excl_ok,
          rfifo_o_wr_done,
          rfifo_o_err_wr,
          rfifo_o_wr_excl_done
         }                        = rfifo_o_data;

  wire [RFIFO_DEPTH:0] rfifo_occp;
  wire rfifo_i_ready;
  wire rfifo_i_valid;

  alb_mss_fab_fifo #(
      .FIFO_DEPTH(RFIFO_DEPTH),
      .FIFO_WIDTH(RFIFO_W),
      .IN_OUT_MWHILE (0),
      .O_SUPPORT_RTIO(0),
      .I_SUPPORT_RTIO(1)
    ) u_ahb_rfifo (
      .i_clk_en    (bus_clk_en),
      .i_ready     (rfifo_i_ready),
      .i_valid     (rfifo_i_valid),
      .i_data      (rfifo_i_data),
      .i_occp      (rfifo_occp ),

      .o_clk_en    (1'b1),
      .o_ready     (rfifo_o_ready),
      .o_valid     (rfifo_o_valid),
      .o_data      (rfifo_o_data ),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
      .o_occp      (),
// leda B_1011 on
// leda WV951025 on


      .clk         (clk  ),
      .rst_a       (rst_a)
      );

  //--------------------------------------------------
  // AHB Bus Control FSM
  //--------------------------------------------------
  // response fifo is enough:
  //   * If current state is STA_ADDR_ONLY, then need 1 empty entry
  //   * If current state is not STA_ADDR_ONLY, then need 2 empty entries
  wire rfifo_1empty = (~rfifo_occp[RFIFO_DEPTH-1]);
  wire rfifo_2empty = (~rfifo_occp[RFIFO_DEPTH-2]);
  wire rfifo_enough = (ahb_state_r == STA_ADDR_ONLY) ? rfifo_1empty : rfifo_2empty;

  // wdata fifo is enough:
  //   * If current state is STA_ADDR_WDATA, then need 2 occupied entries
  //   * If current state is not STA_ADDR_WDATA, then need 1 occupied entry
  wire wfifo_1occp = wfifo_occp[0];
  wire wfifo_2occp = wfifo_occp[1];
  wire wfifo_enough = (ahb_state_r == STA_ADDR_WDATA) ? wfifo_2occp : wfifo_1occp;

  wire[STA_W-1:0] ahb_state_nxt;

  wire ahb_hready_real = ahb_hready & bus_clk_en;

  wire afifo_o_efct_wd = afifo_o_valid & (~afifo_o_cmd_read) & rfifo_enough & wfifo_enough & (~ahb_lock2idle_r);
  wire afifo_o_efct_rd = afifo_o_valid & afifo_o_cmd_read & rfifo_enough & (~ahb_lock2idle_r);

  wire to_addr_wdata_sta =  ahb_hready_real & afifo_o_efct_wd;
  wire to_addr_rdata_sta =  ahb_hready_real & afifo_o_efct_rd;
  wire to_addr_only_sta  =  ahb_hready_real & (~afifo_o_efct_wd) & (~afifo_o_efct_rd);

  // Control the fifos
  assign afifo_o_ready = (to_addr_wdata_sta | to_addr_rdata_sta);
  assign wfifo_o_ready = ahb_hready_real & (ahb_state_r == STA_ADDR_WDATA);
  assign rfifo_i_valid = ahb_hready_real & ((ahb_state_r == STA_ADDR_RDATA) | (ahb_state_r == STA_ADDR_WDATA));

  // Next state generation
  assign ahb_state_nxt = ahb_hready_real ?
                                           (
                                               {STA_W{to_addr_only_sta }} & (STA_ADDR_ONLY)
                                             | {STA_W{to_addr_wdata_sta}} & (STA_ADDR_WDATA)
                                             | {STA_W{to_addr_rdata_sta}} & (STA_ADDR_RDATA)
                                           )
                                         : ahb_state_r;

  // FSM sequential block
  always @(posedge clk or posedge rst_a)
  begin : ahb_state_PROC
       if (rst_a == 1'b1) begin
            ahb_state_r   <= STA_ADDR_ONLY;
       end
       else begin
            ahb_state_r   <= ahb_state_nxt;
       end
  end

  // AHB control signal generation
  //assign ahb_htrans = (afifo_o_efct_wd | afifo_o_efct_rd) ? AHB_TRANS_NONSEQ : AHB_TRANS_IDLE;
  assign ahb_htrans[1] = (afifo_o_efct_wd | afifo_o_efct_rd);
  assign ahb_htrans[0] = afifo_o_cmd_burst_en;

  // ahb_wr_lock_last
  wire ahb_wr_lock_last = ahb_hlock & afifo_o_cmd_burst_last & afifo_o_cmd_wr_splt_last;

  // ahb_lock_flag_r
  always @(posedge clk or posedge rst_a)
    begin: ahb_lock_flag_DFFEAR_PROC
       if (rst_a == 1'b1)
          ahb_lock_flag_r <= 1'b0;
       else if (to_addr_wdata_sta & ahb_wr_lock_last)
          ahb_lock_flag_r <= 1'b0;
       else if (to_addr_rdata_sta & afifo_o_cmd_lock)
          ahb_lock_flag_r <= 1'b1;
    end

  // ahb_lock2idle_r: insert idle after ahb locked write
  always @(posedge clk or posedge rst_a)
    begin: ahb_lock2idle_DFFEAR_PROC
       if (rst_a == 1'b1)
          ahb_lock2idle_r <= 1'b0;
       else if (to_addr_only_sta)
          ahb_lock2idle_r <= 1'b0;
       else if (to_addr_wdata_sta & ahb_wr_lock_last)
          ahb_lock2idle_r <= 1'b1;
    end

  //--------------------------------------------------------
  // Count how much of the cmd is waiting write burst data
  //--------------------------------------------------------
  // Notes: Move to ahb_single2sparse to handle the direct write data path only,
  //        because dead lock might be introduced when handling side buffer data path
  //reg [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_r;
  //wire cmd_wait_wd_cnt_ovf = (cmd_wait_wd_cnt_r[OUT_CMD_CNT_W] == 1'b1);
  //assign cmd_wait_wd_cnt_udf = (cmd_wait_wd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
  //wire cmd_wait_wd_cnt_inc = ibp_cmd_valid & ibp_cmd_accept & (~ibp_cmd_read);
  //wire cmd_wait_wd_cnt_dec = (ibp_wr_valid & ibp_wr_accept);
  //wire cmd_wait_wd_cnt_ena = cmd_wait_wd_cnt_inc | cmd_wait_wd_cnt_dec;
  //wire [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_nxt =
  //      ( cmd_wait_wd_cnt_inc & (~cmd_wait_wd_cnt_dec)) ? (cmd_wait_wd_cnt_r + 1'b1)
  //    : (~cmd_wait_wd_cnt_inc &  cmd_wait_wd_cnt_dec) ? (cmd_wait_wd_cnt_r - 1'b1)
  //    : cmd_wait_wd_cnt_r ;

  //always @(posedge clk or posedge rst_a)
  //begin : cmd_wait_wd_cnt_DFFEAR_PROC
  //  if (rst_a == 1'b1) begin
  //      cmd_wait_wd_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
  //  end
  //  else if (cmd_wait_wd_cnt_ena == 1'b1) begin
  //      cmd_wait_wd_cnt_r        <= cmd_wait_wd_cnt_nxt;
  //  end
  //end

  // endian convert
  // outputs: ibp_wr_data_tmp, ibp_rd_data_tmp
  // Notes: ibp_wr_mask needn't be converted for ahb sparse being handled
  integer i;
  always @ (*)
    begin: endian_convert_PROC
        if (bigendian)
          for (i = 0; i < DATA_W/8; i = i + 1) begin
             ibp_wr_data_tmp[i*8+:8] = ibp_wr_data[DATA_W-8-i*8+:8];
             //ibp_wr_mask_tmp[i]      = ibp_wr_mask[DATA_W/8-i-1];
             ibp_rd_data[i*8+:8]  = ibp_rd_data_tmp[DATA_W-8-i*8+:8];
          end
        else begin
           ibp_wr_data_tmp   = ibp_wr_data;
           //ibp_wr_mask_tmp  = ibp_wr_mask;
           ibp_rd_data  = ibp_rd_data_tmp;
        end
    end // endian_convert_PROC

  //--------------------------------------------------
  // SV Assertion Checkers
  //--------------------------------------------------

endmodule // alb_mss_fab_single2ahbl
