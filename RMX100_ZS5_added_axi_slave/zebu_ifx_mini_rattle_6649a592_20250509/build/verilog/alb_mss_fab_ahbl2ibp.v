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
//     #     #     #  ######   #####  ### ######  ######
//    # #    #     #  #     # #     #  #  #     # #     #
//   #   #   #     #  #     #       #  #  #     # #     #
//  #     #  #######  ######   #####   #  ######  ######
//  #######  #     #  #     # #        #  #     # #
//  #     #  #     #  #     # #        #  #     # #
//  #     #  #     #  ######  ####### ### ######  #
//
// ===========================================================================
//
// Description:
//  Verilog module to convert the AHB-Lite to IBP Single protocol
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"

module alb_mss_fab_ahbl2ibp
  #(
    parameter BUS_SUPPORT_RTIO = 0,
    parameter FORCE_TO_SINGLE = 1,
    parameter SUPPORT_LOCK = 0,
    parameter AHBL_EBT = 1,
    parameter X_W = 32,
    parameter Y_W = 32,

    parameter SEL_W = 4,
    parameter RGON_W = 2,
    // SEL_W indicate the width of hsel
    // RGON_W indicate the width of region
        // It should be log2(SEL_W), eg: 2 for SEL_W=4
   // The FIFO Depth indicated the FIFO entries
    parameter SPLT_FIFO_DEPTH = 8,
    parameter CHNL_FIFO_DEPTH = 1,
    // ADDR_W indicate the width of address
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
    parameter DATA_W = 32,



    // ALSB indicate least significant bit of the address
        // It should be log2(DATA_W/8), eg: 2 for 32b, 3 for 64b, 4 for 128b
    parameter ALSB = 2
    )
  (
  // We need to force bus ready signals to LOW to hold external master when CCM/CC_TOP reset applied
  // Notes: ahb_hready_resp can't be forced to LOW during reset, then use sync_rst_r to force ibp signals
  input  wire                  sync_rst_r, //Synced version of external reset, when value is 1, means resetted

  // The "ahb_xxx" bus is the AHB-Lite interface to be converted
  input  wire [1:0]            ahb_htrans,    // AHB transaction type (IDLE, BUSY, SEQ, NSEQ)
  input  wire                  ahb_hwrite,    // If true then write
  input  wire [SEL_W-1:0]      ahb_hsel,      // Select one or the other CCM
  input  wire [ADDR_W-1:0]     ahb_haddr,     // Address
  input  wire [2:0]            ahb_hsize,     // Transaction size
// leda NTL_CON13C off
// LMD: non-driving port
// LJ: it is indeed driving nothing
// leda NTL_CON37 off
// LMD: Signal/Net must read from the input port
// LJ: it is indeed driving nothing
  input  wire                  ahb_hlock,     // If true then locked
  input  wire [2:0]            ahb_hburst,    // Burst type SINGLE, INCR, etc
  input  wire [3:0]            ahb_hprot,     // Protection attributes
// leda NTL_CON13C on
// leda NTL_CON37 on
  input  wire [DATA_W-1:0]     ahb_hwdata,    // Write data
  input  wire [DATA_W/8-1:0]   ahb_hwstrb,

  output wire [DATA_W-1:0]     ahb_hrdata,    // Read data
  output wire                  ahb_hresp,     // Response 0=OK, 1=ERROR
  output wire                  ahb_hready_resp,    // AHB transfer ready output to AHB mux
  input  wire                  ahb_hready,  // AHB transfer ready input from AHB mux

  input  wire                  ahb_hexcl,
  output wire                  ahb_hexokay,

  // The "ibp_xxx" bus is the IBP interface after converted
  // command channel
  // This module do not support the id and snoop
  output  wire                  ibp_cmd_valid,
  input   wire                  ibp_cmd_accept,
  output  wire                  ibp_cmd_read,
  output  wire [ADDR_W-1:0]     ibp_cmd_addr,
  output  wire [RGON_W-1:0]     ibp_cmd_rgon,
  output  wire                  ibp_cmd_wrap,
  output  wire [2:0]            ibp_cmd_data_size,
  output  wire [3:0]            ibp_cmd_burst_size,
  output  wire                  ibp_cmd_lock,
  output  wire                  ibp_cmd_excl,
  output  wire [1:0]            ibp_cmd_prot,
  output  wire [3:0]            ibp_cmd_cache,
  //


  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  input  wire                  ibp_rd_valid,
  output wire                  ibp_rd_accept,
  input  wire [DATA_W-1:0]     ibp_rd_data,
  input  wire                  ibp_err_rd,
// leda NTL_CON13C off
// LMD: non-driving port
// LJ: it is indeed driving nothing
// leda NTL_CON37 off
// LMD: Signal/Net must read from the input port
// LJ: it is indeed driving nothing
  input  wire                  ibp_rd_excl_ok,
  input  wire                  ibp_rd_last,
// leda NTL_CON13C on
// leda NTL_CON37 on
  //
  // write data channel
  output wire                  ibp_wr_valid,
  input  wire                  ibp_wr_accept,
  output wire [DATA_W-1:0]     ibp_wr_data,
  output wire [(DATA_W/8)-1:0] ibp_wr_mask,
  output wire                  ibp_wr_last,
  //
  // write response channel
  // This module do not support id
  input  wire                  ibp_wr_done,
// leda NTL_CON13C off
// LMD: non-driving port
// LJ: it is indeed driving nothing
// leda NTL_CON37 off
// LMD: Signal/Net must read from the input port
// LJ: it is indeed driving nothing
  input  wire                  ibp_wr_excl_done,
// leda NTL_CON13C on
// leda NTL_CON37 on
  input  wire                  ibp_err_wr,
  output wire                  ibp_wr_resp_accept,

  // Clock and reset
  input                   clk,           // clock signal
  input                   bus_clk_en,    // clock enable signal to control the N:1 clock ratios
  input                   rst_a,         // reset signal
  input                   bigendian      // If true, then bigendian
  );

  localparam IBP_CFIFO_DW = (ADDR_W+RGON_W+3+1+1+3+SUPPORT_LOCK+SUPPORT_LOCK+1);
  //--------------------------------------------
  // Parameters Definition
  //--------------------------------------------
  // local parameters
  localparam AHB_TRANS_IDLE   = 2'b00;    // AHB Transfer Type
  localparam AHB_TRANS_BUSY   = 2'b01;
  localparam AHB_TRANS_NONSEQ = 2'b10;
  localparam AHB_TRANS_SEQ    = 2'b11;

  localparam AHB_BURST_SINGLE = 3'b000;   // AHB Burst Type
  localparam AHB_BURST_INCR   = 3'b001;
  localparam AHB_BURST_WRAP4  = 3'b010;
  localparam AHB_BURST_INCR4  = 3'b011;
  localparam AHB_BURST_WRAP8  = 3'b100;
  localparam AHB_BURST_INCR8  = 3'b101;
  localparam AHB_BURST_WRAP16 = 3'b110;
  localparam AHB_BURST_INCR16 = 3'b111;

  localparam AHB_SIZE_8       = 3'b000;   // AHB Transfer Size
  localparam AHB_SIZE_16      = 3'b001;
  localparam AHB_SIZE_32      = 3'b010;
  localparam AHB_SIZE_64      = 3'b011;
  localparam AHB_SIZE_128     = 3'b100;
  localparam AHB_SIZE_256     = 3'b101;
  localparam AHB_SIZE_512     = 3'b110;
  localparam AHB_SIZE_1024    = 3'b111;


  //--------------------------------------------
  // Local wires/regs
  //--------------------------------------------
  wire [2:0] ibp_cmd_hburst;
  assign ibp_cmd_wrap        = (
                               (ibp_cmd_hburst == AHB_BURST_WRAP4)
                             | (ibp_cmd_hburst == AHB_BURST_WRAP8)
                             | (ibp_cmd_hburst == AHB_BURST_WRAP16)
                               ) & (|ibp_cmd_burst_size);
  assign ibp_cmd_prot        =  {2{1'b0}};
  assign ibp_cmd_cache       =  {4{1'b0}};
  assign ibp_cmd_excl        =  1'b0;

  // internal ibp cmd registers
  wire   [2:0]             ahbl2ibp_cmd_hburst;
  wire                     ahbl2ibp_cmd_read;
  wire   [ADDR_W-1:0]      ahbl2ibp_cmd_addr;
  wire   [2:0]             ahbl2ibp_cmd_data_size;
  wire                     ahbl2ibp_cmd_excl;

  reg    [DATA_W-1:0]      ahbl2ibp_wr_data;
  reg    [(DATA_W/8)-1:0]  ahbl2ibp_wr_mask_r;
  wire   [(DATA_W/8)-1:0]  ahbl2ibp_wr_mask;

  // internal ahb signals

  reg  [DATA_W-1:0]      ibp_rd_data_endian;

  wire                   ahb_wresp;
  wire                   ahb_rresp;

  reg                    ahb_hresp_mux;
  reg                    ahb_hresp_d1;
  wire                   ahb_hresp_1st_err;
  reg                    ahb_hresp_2nd_err;

  wire                   ahb_hreadyout_mux;
  wire                   ahb_rd_excl_ok;
  wire                   ahb_wr_excl_done;

// leda NTL_CON32 off
// LMD: Change on net has no effect on any of the outputs
// LJ: ahb_htrans_d1[0] is indeed driving nothing
  reg  [1:0]             ahb_htrans_d1;
// leda NTL_CON32 on
  reg                    ahb_hwrite_d1;

  // ibp cmd fifo control signals
  wire                            ibp_cfifo_i_valid;
  wire [IBP_CFIFO_DW       -1:0]  ibp_cfifo_i_data;
  wire [IBP_CFIFO_DW       -1:0]  ibp_cfifo_o_data;
  wire                            ibp_cfifo_i_ready;

  // ibp wdata fifo control signals
  reg                             ibp_wfifo_i_valid_pre;
  wire                            ibp_wfifo_i_valid;
  wire [DATA_W+(DATA_W/8)-1:0]    ibp_wfifo_i_data;
  wire [DATA_W+(DATA_W/8)-1:0]    ibp_wfifo_o_data;
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: it is indeed driving nothing
  wire                            ibp_wfifo_i_ready;
// leda NTL_CON13A on

  // ibp rdata fifo control signals
  wire                            ibp_rfifo_i_valid;
  wire [DATA_W+4-1:0]             ibp_rfifo_i_data;
  wire                            ibp_rfifo_o_ready;
  wire [DATA_W+4-1:0]             ibp_rfifo_o_data;
  wire                            ibp_rfifo_i_ready;
  wire                            ibp_rfifo_o_valid;


  // ibp internal handshaking signals
  wire                            ibp_cmd_valid_int;
  wire                            ibp_cmd_accept_int;

  wire                            ibp_wr_valid_int;
  wire                            ibp_wr_accept_int;

  wire                            ibp_wr_done_int;
  wire                            ibp_err_wr_int;
  wire                            ibp_wr_resp_accept_int;
  wire                            ibp_wr_excl_done_int;

  wire                            ibp_rd_valid_int;
  wire                            ibp_err_rd_int;
  wire                            ibp_rd_accept_int;
  wire                            ibp_rd_excl_ok_int;


  integer i, j;

  // Conversion for AHB-Lite
  // Split AHB-Lite transfer to IBP four channels: cmd/wr/rd/wr_resp

  reg   [RGON_W-1:0]      ahbl2ibp_cmd_rgon;

  always @ (*)
    begin : ahbl2ibp_cmd_rgon_PROC
       ahbl2ibp_cmd_rgon = {RGON_W{1'b0}};
       for (i=0; i<SEL_W; i=i+1)
             ahbl2ibp_cmd_rgon= ahbl2ibp_cmd_rgon | {RGON_W{ahb_hsel[i]}} & $unsigned(i);
    end

  // Misc assignments


  // AHB2IPB signal mapping
  assign ahbl2ibp_cmd_hburst = ahb_hburst;
  assign ahbl2ibp_cmd_read = ~ahb_hwrite;
  assign ahbl2ibp_cmd_addr = ahb_haddr;
  assign ahbl2ibp_cmd_data_size = ahb_hsize;
  wire   ahbl2ibp_cmd_seq = (ahb_htrans == AHB_TRANS_SEQ);
  assign ahbl2ibp_cmd_excl = ahb_hexcl;


  // AHB bus transaction phase
  wire ahb_hsel_mux = (|ahb_hsel);
  wire ahb_addr_ph  = ahb_hsel_mux & ahb_htrans[1];
  wire ahb_wdata_ph = ahb_htrans_d1[1] & ahb_hwrite_d1;
  wire ahb_rdata_ph = ahb_htrans_d1[1] & (~ahb_hwrite_d1);

  // the cycle of AHB valid transaction
  wire ahb_addr_en  = bus_clk_en & ahb_hsel_mux & ahb_htrans[1] & ahb_hready_resp & ahb_hready;
  wire ahb_data_en  = bus_clk_en & ahb_htrans_d1[1] & ahb_hready_resp & ahb_hready;
  wire ahbl_resp_accept       = ahb_data_en;

  always @(posedge clk or posedge rst_a)
    begin: ahb_htrans_d1_PROC
       if (rst_a == 1'b1)
         begin
            ahb_htrans_d1 <= AHB_TRANS_IDLE;
            ahb_hwrite_d1 <= 1'b0;
         end
       else if (ahb_addr_en)
         begin
            ahb_htrans_d1 <= ahb_htrans;
            ahb_hwrite_d1 <= ahb_hwrite;
         end
       else if (bus_clk_en & ahb_hready_resp & ahb_hready)
         begin
            ahb_htrans_d1 <= AHB_TRANS_IDLE;
            ahb_hwrite_d1 <= 1'b0;
         end
    end

  wire ahbl_wait_resp = ahb_htrans_d1[1] & ((ahb_hwrite_d1 & ibp_wfifo_i_ready) | (~ahb_hwrite_d1));

  always @(posedge clk or posedge rst_a)
    begin: ibp_wdata_samp_PROC
       if (rst_a == 1'b1)
         ibp_wfifo_i_valid_pre <= 1'b0;
       // -- STAR_9000781604 --
       // Fix bug: ibp_wr_valid asserted unexpectly during ibp read transfer
       else if (ahb_addr_en & ahb_hwrite)
         ibp_wfifo_i_valid_pre <= 1'b1;
        else if (bus_clk_en & ibp_wfifo_i_valid_pre & ibp_wfifo_i_ready)
         ibp_wfifo_i_valid_pre <= 1'b0;
    end


  // Notes: fix in2out path from hsel/htrans to hreadyout
  wire ahbl_resp_valid;
  reg ibp_wait_forged_unlock_resp;
  reg wait_forged_unlock_resp;

  generate
    if(SUPPORT_LOCK == 0) begin: no_support_lock_decl
       always @*
        begin: no_support_lock_PROC
          ibp_wait_forged_unlock_resp = 1'b0;
          wait_forged_unlock_resp = 1'b0;
        end
    end

    if(SUPPORT_LOCK == 1) begin: support_lock_hready
  assign ahb_hreadyout_mux = (((~ahb_htrans_d1[1])) | (ahbl_resp_valid & (~wait_forged_unlock_resp) & ibp_cfifo_i_ready));
    end
    else begin: no_support_lock_hready
  assign ahb_hreadyout_mux = ((~ahb_htrans_d1[1]) | (ahbl_resp_valid & ibp_cfifo_i_ready));
    end
  endgenerate

  assign ahb_hready_resp = ahb_hreadyout_mux & (~ahb_hresp_1st_err);

  always @ (*)
    begin: ahb_hresp_PROC
       case ({ahb_rdata_ph, ahb_wdata_ph})
         2'b01:
                 ahb_hresp_mux = ahb_wresp;
         2'b10:
                 ahb_hresp_mux = ahb_rresp;
         default:
                 ahb_hresp_mux = 1'b0;
       endcase
    end

  always @ (posedge clk or posedge rst_a)
    begin: ahb_hresp_d1_PROC
       if (rst_a == 1'b1)
         ahb_hresp_d1 <= 1'b0;
       // -- STAR 9000785444 --
       // Fix bug: ahb_hresp_d1 not de-asserted for ahb_hreadyout_mux LOW, the next ahb_hresp_1st_err corrupt
       // Notes: To fix back-to-back error response, ahb_hresp_d1 de-asserted on the rising edge of clk, not qualify bus_clk_en.
       else if (~ahb_hresp_mux)
         ahb_hresp_d1 <= 1'b0;
       else if (bus_clk_en & ahb_hresp_mux & ahb_hreadyout_mux)
         ahb_hresp_d1 <= 1'b1;
    end


  generate
    if(SUPPORT_LOCK == 1) begin: support_lock_hresp
  assign ahb_hresp_1st_err = ahb_hresp_mux & (~ahb_hresp_d1) & ahb_hreadyout_mux & (~wait_forged_unlock_resp);
    end
    else begin: no_support_lock_hresp
  assign ahb_hresp_1st_err = ahb_hresp_mux & (~ahb_hresp_d1) & ahb_hreadyout_mux;
    end
  endgenerate


  always @ (posedge clk or posedge rst_a)
    begin: ahb_hresp_2nd_err_PROC
       if (rst_a == 1'b1)
         ahb_hresp_2nd_err <= 1'b0;
       else if (ahb_data_en)
         ahb_hresp_2nd_err <= 1'b0;
       else if (bus_clk_en & ahb_hresp_1st_err)
         ahb_hresp_2nd_err <= 1'b1;
    end

  assign ahb_hresp = ahb_hresp_1st_err | ahb_hresp_2nd_err;

  //--------------------------------------------------
  // IBP Command FIFO instantiation
  //--------------------------------------------------
  wire ibp_cmd_seq;
  wire forged_unlock_uop;
  wire ibp_forged_unlock_uop;

  generate
    if(SUPPORT_LOCK == 0) begin: no_support_lock_forged_decl
       assign forged_unlock_uop = 1'b0;
       assign ibp_forged_unlock_uop = 1'b0;
    end

    if(SUPPORT_LOCK == 1) begin: support_lock

  reg ahb_hlock_d1;
  reg [ADDR_W-1:0] ahbl2ibp_cmd_addr_d1;
  reg [RGON_W-1:0] ahbl2ibp_cmd_rgon_d1;
  always @(posedge clk or posedge rst_a)
    begin: ahb_hlock_d1_PROC
       if (rst_a == 1'b1)
         begin
            ahb_hlock_d1 <= 1'b0;
            ahbl2ibp_cmd_addr_d1 <= {ADDR_W{1'b0}};
            ahbl2ibp_cmd_rgon_d1 <= {RGON_W{1'b0}};
         end
       else if (ahb_addr_en)
         begin
            ahb_hlock_d1 <= ahb_hlock;
            ahbl2ibp_cmd_addr_d1 <= ahbl2ibp_cmd_addr;
            ahbl2ibp_cmd_rgon_d1 <= ahbl2ibp_cmd_rgon;
         end
       else if (bus_clk_en & ahb_hready_resp & ahb_hready)
         begin
            ahb_hlock_d1 <= 1'b0;
            ahbl2ibp_cmd_addr_d1 <= {ADDR_W{1'b0}};
            ahbl2ibp_cmd_rgon_d1 <= {RGON_W{1'b0}};
         end
    end

  assign forged_unlock_uop   = ahb_hlock_d1 & (~ahb_hlock) & (ahb_htrans == AHB_TRANS_IDLE) & bus_clk_en & ahb_hready_resp & ahb_hready;
  wire ibp_cmd_forged_unlock;
  assign ibp_forged_unlock_uop   = ibp_cmd_valid & ibp_cmd_accept & ibp_cmd_forged_unlock;

  always @(posedge clk or posedge rst_a)
    begin: ibp_wait_forge_unlock_PROC
       if (rst_a == 1'b1)
         begin
            ibp_wait_forged_unlock_resp <= 1'b0;
         end
       else if (ibp_forged_unlock_uop)
         begin
            ibp_wait_forged_unlock_resp <= 1'b1;
         end
       else if (bus_clk_en & ibp_rfifo_o_valid & wait_forged_unlock_resp)
         begin
            ibp_wait_forged_unlock_resp <= 1'b0;
         end
    end

  always @(posedge clk or posedge rst_a)
    begin: ahb_wait_forge_unlock_PROC
       if (rst_a == 1'b1)
         begin
            wait_forged_unlock_resp <= 1'b0;
         end
       else if (forged_unlock_uop)
         begin
            wait_forged_unlock_resp <= 1'b1;
         end
       else if (bus_clk_en & ibp_rfifo_o_valid & wait_forged_unlock_resp)
         begin
            wait_forged_unlock_resp <= 1'b0;
         end
    end

  assign ibp_cfifo_i_valid   = ahb_addr_en | forged_unlock_uop;
  assign ibp_cfifo_i_data    = forged_unlock_uop ?
                               {//single-beat write uop
                                ahbl2ibp_cmd_addr_d1,
                                ahbl2ibp_cmd_rgon_d1,
                                1'b0,
                                1'b0,
                                3'b0,
                                3'b0,
                                1'b0,
                                1'b1,
                                1'b0
                               }:
                                {ahbl2ibp_cmd_addr,
                                ahbl2ibp_cmd_rgon,
                                ahbl2ibp_cmd_read,
                                ahbl2ibp_cmd_seq,
                                ahbl2ibp_cmd_hburst,
                                ahbl2ibp_cmd_data_size,
                                ahb_hlock,
                                1'b0,
                                ahb_hexcl
                               }
                               ;
  assign {ibp_cmd_addr,
          ibp_cmd_rgon,
          ibp_cmd_read,
          ibp_cmd_seq,
          ibp_cmd_hburst,
          ibp_cmd_data_size,
          ibp_cmd_lock,
          ibp_cmd_forged_unlock,
          ibp_cmd_excl
          }      = ibp_cfifo_o_data;
    end
    else begin: no_support_lock

  assign ibp_cfifo_i_valid   = ahb_addr_en;
  assign ibp_cfifo_i_data    = {ahbl2ibp_cmd_addr,
                                ahbl2ibp_cmd_rgon,
                                ahbl2ibp_cmd_read,
                                ahbl2ibp_cmd_seq,
                                ahbl2ibp_cmd_hburst,
                                ahbl2ibp_cmd_data_size,
                                ahbl2ibp_cmd_excl
                               };
  assign {ibp_cmd_addr,
          ibp_cmd_rgon,
          ibp_cmd_read,
          ibp_cmd_seq,
          ibp_cmd_hburst,
          ibp_cmd_data_size,
          ibp_cmd_excl}      = ibp_cfifo_o_data;
  assign ibp_cmd_lock        =  1'b0;
    end
  endgenerate

  wire [3:0] ibp_cmd_burst_size_pre =
          (  {4{ibp_cmd_hburst == AHB_BURST_SINGLE}} & 4'd0
           | {4{ibp_cmd_hburst == AHB_BURST_INCR  }} & 4'd1//Intentionally forge this number
           | {4{ibp_cmd_hburst == AHB_BURST_WRAP4 }} & 4'd3
           | {4{ibp_cmd_hburst == AHB_BURST_INCR4 }} & 4'd3
           | {4{ibp_cmd_hburst == AHB_BURST_WRAP8 }} & 4'd7
           | {4{ibp_cmd_hburst == AHB_BURST_INCR8 }} & 4'd7
           | {4{ibp_cmd_hburst == AHB_BURST_WRAP16}} & 4'd15
           | {4{ibp_cmd_hburst == AHB_BURST_INCR16}} & 4'd15
    );

  wire n_bstlen_divided;
  wire n_addr_start_w;
  wire n2w_pack_cond = n_bstlen_divided & n_addr_start_w;

  generate //{
      if(X_W >= Y_W) begin: xw_gt_yw_decl
        assign n_bstlen_divided = 1'b0;
        assign n_addr_start_w = 1'b0;
      end
      if(X_W == 32) begin: divided_32
          if(Y_W == 64) begin: divided_32_64
            assign n_bstlen_divided = (ibp_cmd_burst_size_pre[0]);
            assign n_addr_start_w = ~(ibp_cmd_addr[2]);
          end
          if(Y_W == 128) begin: divided_32_128
            assign n_bstlen_divided = (ibp_cmd_burst_size_pre[1] & ibp_cmd_burst_size_pre[0]);
            assign n_addr_start_w = ~(|ibp_cmd_addr[3:2]);
          end
      end
      if(X_W == 64) begin: divided_64
          if(Y_W == 128) begin: divided_64_128
            assign n_bstlen_divided = (ibp_cmd_burst_size_pre[0]);
            assign n_addr_start_w = ~(ibp_cmd_addr[3]);
          end
      end
  endgenerate //}
  wire ahbl2ibp_narrow_trans = (~((32'd1 << ibp_cmd_data_size) == (DATA_W/8)));
  wire ahbl2ibp_burst_is_incr = (ibp_cmd_hburst == AHB_BURST_INCR);


  wire ahbl_non_ibp_burst   = (  ahbl2ibp_narrow_trans
                                  | ahbl2ibp_burst_is_incr
                                 ) & (~(ibp_cmd_burst_size_pre == 4'b0));

  wire ibp_need_splt;

  generate
   if((FORCE_TO_SINGLE == 1) || (AHBL_EBT == 1)) begin: splt_force_single
       // Always split every AXI transactions into single IBP beat transaction
     assign ibp_need_splt = (~(ibp_cmd_burst_size_pre == 4'b0));
   end
   else if (X_W == Y_W) begin: splt_x_eq_y
       // Only split non-IBP compliant AXI transactions into single IBP beat transaction
     assign ibp_need_splt = ahbl_non_ibp_burst;
   end
   else if (X_W > Y_W) begin: splt_x_gt_y
       if ((X_W == 128) && (Y_W == 32)) begin: splt_x_gt_y_128_32
           // Split the burst lenth equal or more than 4 beats
           // Split non-IBP compliant AXI transactions into single IBP beat transaction
         assign ibp_need_splt = (~(ibp_cmd_burst_size_pre[3:2] == 2'b0))
                               | ahbl_non_ibp_burst;
       end
       else if (((X_W == 64) && (Y_W == 32)) || ((X_W == 128) && (Y_W == 64))) begin: splt_x_gt_y_64_32
           // Split the burst lenth equal or more than 8 beats
           // Split non-IBP compliant AXI transactions into single IBP beat transaction
         assign ibp_need_splt = (~(ibp_cmd_burst_size_pre[3] == 1'b0))
                               | ahbl_non_ibp_burst;
       end
   end
   else if (X_W < Y_W) begin: splt_x_st_y
       // Split the burst which cannot be packed into wider bus
       // Split non-IBP compliant AXI transactions into single IBP beat transaction
     assign ibp_need_splt = ((~n2w_pack_cond) & (~(ibp_cmd_burst_size_pre == 4'b0)))
                               | ahbl_non_ibp_burst;
   end

  endgenerate

  reg  this_burst_need_splt_r;
  wire this_burst_need_splt_en = ibp_cmd_valid & ibp_cmd_accept;
  wire this_burst_need_splt_nxt = ibp_need_splt & (~(ibp_cmd_burst_size_pre == 4'b0));

  always @(posedge clk or posedge rst_a)
  begin: this_burst_need_splt_PROC
       if (rst_a == 1'b1)
          this_burst_need_splt_r <= 1'b0;
       else if (this_burst_need_splt_en)
          this_burst_need_splt_r <= this_burst_need_splt_nxt;
  end

  wire ibp_cfifo_o_valid;
  wire ibp_cfifo_o_ready;

// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
  reg  [3:0] ahbl2ibp_burst_cnt_r;
  wire ahbl2ibp_burst_cnt_set = ibp_cmd_valid & ibp_cmd_accept;
  wire ahbl2ibp_burst_cnt_dec = ibp_cfifo_o_valid & ibp_cfifo_o_ready;
  wire ahbl2ibp_burst_cnt_en = ahbl2ibp_burst_cnt_set | ahbl2ibp_burst_cnt_dec;
  wire [3:0] ahbl2ibp_burst_cnt_nxt = ahbl2ibp_burst_cnt_set ? ibp_cmd_burst_size
            : (ahbl2ibp_burst_cnt_r - 1'b1);

  always @(posedge clk or posedge rst_a)
  begin: ahbl2ibp_burst_cnt_PROC
       if (rst_a == 1'b1)
          ahbl2ibp_burst_cnt_r <= 4'b0;
       else if (ahbl2ibp_burst_cnt_en)
          ahbl2ibp_burst_cnt_r <= ahbl2ibp_burst_cnt_nxt;
  end
// leda B_3200 on
// leda B_3219 on
// leda W484 on
// leda BTTF_D002 on

  wire ahbl2ibp_burst_nonstart_uop = ~(ahbl2ibp_burst_cnt_r == 4'b0);
  wire ahbl2ibp_burst_go_ibp_burst = (~this_burst_need_splt_r);
  wire ahbl2ibp_burst_vanish_uop;

  generate
   if((FORCE_TO_SINGLE == 1) || (AHBL_EBT == 1)) begin: force_single
  assign ahbl2ibp_burst_vanish_uop = 1'b0;
   end
   else begin:no_force_single
  assign ahbl2ibp_burst_vanish_uop = ahbl2ibp_burst_nonstart_uop & ahbl2ibp_burst_go_ibp_burst;
   end
  endgenerate


  assign ibp_cmd_burst_size  = ibp_need_splt ? 4'd0 : ibp_cmd_burst_size_pre;

    generate
    if(SUPPORT_LOCK == 1) begin: support_lock4cfifo
  assign ibp_cmd_valid_int = (ibp_cfifo_o_valid & (~ahbl2ibp_burst_vanish_uop)) & (~ibp_wait_forged_unlock_resp);
  assign ibp_cfifo_o_ready = (ibp_cmd_accept_int | ahbl2ibp_burst_vanish_uop) & (~ibp_wait_forged_unlock_resp);
    end
    else begin: no_support_lock4cfifo
  assign ibp_cmd_valid_int = ibp_cfifo_o_valid & (~ahbl2ibp_burst_vanish_uop);
  assign ibp_cfifo_o_ready = ibp_cmd_accept_int | ahbl2ibp_burst_vanish_uop;
    end
    endgenerate

  alb_mss_fab_fifo # (
    .FIFO_DEPTH(CHNL_FIFO_DEPTH),
    .FIFO_WIDTH(IBP_CFIFO_DW),
    .IN_OUT_MWHILE (0),
    .O_SUPPORT_RTIO(0),
    .I_SUPPORT_RTIO(BUS_SUPPORT_RTIO)
  ) u_ibp_cmd_fifo (
                        .i_valid      (ibp_cfifo_i_valid  ),
                        .i_data       (ibp_cfifo_i_data   ),
                        .i_ready      (ibp_cfifo_i_ready),
                        .o_valid      (ibp_cfifo_o_valid),
                        .o_data       (ibp_cfifo_o_data   ),
                        .o_ready      (ibp_cfifo_o_ready),
                        // leda B_1011 off
                        // leda WV951025 off
                        // LMD: Port is not completely connected
                        // LJ: unused in this instantiation
                        .i_occp       (),
                        .o_occp       (),
                        // leda B_1011 on
                        // leda WV951025 on
                        .clk          (clk             ),
                        .o_clk_en     (1'b1      ),
                        .i_clk_en     (bus_clk_en      ),
                        .rst_a        (rst_a           )
                       );

  //--------------------------------------------------
  // IBP Write Data FIFO instantiation
  //--------------------------------------------------

  reg forged_unlock_uop_wd;

    generate
    if(SUPPORT_LOCK == 0) begin: no_support_lock_uop_wd_decl
       always @*
        begin: no_support_lock_uop_wd_PROC
          forged_unlock_uop_wd = 1'b0;
        end
    end

    if(SUPPORT_LOCK == 1) begin: support_lock4wfifo

  always @(posedge clk or posedge rst_a)
    begin: forged_unlock_uop_wd_PROC
       if (rst_a == 1'b1)
         forged_unlock_uop_wd <= 1'b0;
       else if (forged_unlock_uop)
         forged_unlock_uop_wd <= 1'b1;
        else if (bus_clk_en & ibp_wfifo_i_valid & ibp_wfifo_i_ready)
         forged_unlock_uop_wd <= 1'b0;
    end

  assign ibp_wfifo_i_valid = ibp_wfifo_i_valid_pre | forged_unlock_uop_wd;
  assign ibp_wfifo_i_data  =
                          forged_unlock_uop_wd ?
                          {   {DATA_W{1'b0}},
                              {DATA_W/8{1'b0}}
                          }
                          :
                          {   ahbl2ibp_wr_data,
                              ahbl2ibp_wr_mask
                          };


    end else begin: no_support_lock4wfifo

  assign ibp_wfifo_i_valid = ibp_wfifo_i_valid_pre;
  assign ibp_wfifo_i_data  = {ahbl2ibp_wr_data,
                              ahbl2ibp_wr_mask
                          };


    end
  endgenerate


  assign {ibp_wr_data,
          ibp_wr_mask}  = ibp_wfifo_o_data;

  wire ibp_wfifo_o_valid;
  wire ibp_wfifo_o_ready;

  assign ibp_wr_valid_int = ibp_wfifo_o_valid;
  assign ibp_wfifo_o_ready = ibp_wr_accept_int;
  alb_mss_fab_fifo # (
    .FIFO_DEPTH(CHNL_FIFO_DEPTH),
    .FIFO_WIDTH(DATA_W+(DATA_W/8)),
    .IN_OUT_MWHILE (0),
    .O_SUPPORT_RTIO(0),
    .I_SUPPORT_RTIO(BUS_SUPPORT_RTIO)
  ) u_ibp_wdata_fifo (
                          .i_valid      (ibp_wfifo_i_valid  ),
                          .i_data       (ibp_wfifo_i_data    ),
                          .i_ready      (ibp_wfifo_i_ready),
                          .o_valid      (ibp_wfifo_o_valid),
                          .o_data       (ibp_wfifo_o_data   ),
                          .o_ready      (ibp_wfifo_o_ready),
                          // leda B_1011 off
                          // leda WV951025 off
                          // LMD: Port is not completely connected
                          // LJ: unused in this instantiation
                          .i_occp       (),
                          .o_occp       (),
                          // leda B_1011 on
                          // leda WV951025 on
                          .clk          (clk             ),
                          .o_clk_en     (1'b1      ),
                          .i_clk_en     (bus_clk_en      ),
                          .rst_a        (rst_a           )
                         );

  //--------------------------------------------------
  // AHB Read Data FIFO instantiation
  //--------------------------------------------------

// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
  reg  [3:0] ibp_wr_cnt_r;
  wire ibp_wr_cnt_inc = ibp_wr_valid & ibp_wr_accept & (~ibp_wr_last);
  wire ibp_wr_cnt_clr = ibp_wr_valid & ibp_wr_accept & ibp_wr_last;
  wire ibp_wr_cnt_en = ibp_wr_cnt_inc | ibp_wr_cnt_clr;
  wire [3:0] ibp_wr_cnt_nxt = ibp_wr_cnt_clr ? 4'b0 : ibp_wr_cnt_inc ? (ibp_wr_cnt_r + 1'b1) : 4'b0;
// leda B_3200 on
// leda B_3219 on
// leda W484 on
// leda BTTF_D002 on

  always @(posedge clk or posedge rst_a)
  begin: ibp_wr_cnt_PROC
       if (rst_a == 1'b1)
          ibp_wr_cnt_r <= 4'b0;
       else if (ibp_wr_cnt_en)
          ibp_wr_cnt_r <= ibp_wr_cnt_nxt;
  end

  reg  [3:0] ibp_cmd_burst_size_d;
  wire ibp_cmd_burst_size_en = ibp_cmd_valid;

  always @(posedge clk or posedge rst_a)
  begin: ibp_cmd_burst_size_PROC
       if (rst_a == 1'b1)
          ibp_cmd_burst_size_d <= 4'b0;
       else if (ibp_cmd_burst_size_en)
          ibp_cmd_burst_size_d <= ibp_cmd_burst_size;
  end

  assign ibp_wr_last = (ibp_wr_cnt_r == ibp_cmd_burst_size_d);


// leda B_3200 off
// leda B_3219 off
// LMD: Unequal length operand in bit/arithmetic operator
// LJ: there is no overflow risk
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction
// LJ: there is no overflow risk
// leda BTTF_D002 off
// LMD: Unequal length LHS and RHS in assignment
// LJ: there is no overflow risk
  reg  [3:0] forg_wburst_cnt_r;
  wire forg_ibp_wrsp_chnl_valid = (~(forg_wburst_cnt_r == 4'b0));
  wire forg_ibp_wrsp_chnl_accept;
  wire forg_wburst_cnt_set = ibp_cmd_valid & ibp_cmd_accept & (~ibp_cmd_read) & (~(ibp_cmd_burst_size == 4'b0));
  wire forg_wburst_cnt_dec = forg_ibp_wrsp_chnl_valid & forg_ibp_wrsp_chnl_accept;
  wire forg_wburst_cnt_en = forg_wburst_cnt_set | forg_wburst_cnt_dec;
  wire [3:0] forg_wburst_cnt_nxt = forg_wburst_cnt_set ? ibp_cmd_burst_size
            : (forg_wburst_cnt_r - 1'b1);
// leda B_3200 on
// leda B_3219 on
// leda W484 on
// leda BTTF_D002 on

  always @(posedge clk or posedge rst_a)
  begin: forg_wburst_cnt_PROC
       if (rst_a == 1'b1)
          forg_wburst_cnt_r <= 4'b0;
       else if (forg_wburst_cnt_en)
          forg_wburst_cnt_r <= forg_wburst_cnt_nxt;
  end


  wire ibp_rd_chnl_valid = ibp_rd_valid_int | ibp_err_rd_int;
  wire ibp_wrsp_chnl_valid = ibp_wr_done_int | ibp_err_wr_int | ibp_wr_excl_done_int;

  assign ibp_rfifo_i_valid = ibp_rd_chnl_valid | ibp_wrsp_chnl_valid | forg_ibp_wrsp_chnl_valid;

  assign forg_ibp_wrsp_chnl_accept = ibp_rfifo_i_ready;
  assign ibp_wr_resp_accept_int    = ibp_rfifo_i_ready;
  assign ibp_rd_accept_int         = ibp_rfifo_i_ready;

  // Notes: merge wresp fifo into rdata fifo
  assign ibp_rfifo_i_data    = {ibp_rd_data_endian,
                                ibp_err_rd_int,
                                (ibp_wrsp_chnl_valid ? ibp_err_wr_int : 1'b0),
                                ibp_rd_excl_ok_int,
                                (ibp_wrsp_chnl_valid ? ibp_wr_excl_done_int : 1'b0)
                               };

  assign ahbl_resp_valid        = ahbl_wait_resp & ibp_rfifo_o_valid;
  generate
    if(SUPPORT_LOCK == 1) begin: support_lock4rfifo
  assign ibp_rfifo_o_ready      = (ahbl_wait_resp & ahbl_resp_accept) | wait_forged_unlock_resp;
    end
    else begin: no_support_lock4rfifo
  assign ibp_rfifo_o_ready      = ahbl_wait_resp & ahbl_resp_accept;
    end
  endgenerate



  assign {ahb_hrdata,
          ahb_rresp,
          ahb_wresp,
          ahb_rd_excl_ok,
          ahb_wr_excl_done}     = ibp_rfifo_o_data;

  assign ahb_hexokay = ahb_rd_excl_ok | ahb_wr_excl_done;

  alb_mss_fab_fifo # (
     .FIFO_DEPTH(CHNL_FIFO_DEPTH),
     .FIFO_WIDTH(DATA_W+4),
     .IN_OUT_MWHILE (0),
     .O_SUPPORT_RTIO(BUS_SUPPORT_RTIO),
     .I_SUPPORT_RTIO(0)
  ) u_ibp_rdata_fifo (
                           .i_valid      (ibp_rfifo_i_valid   ),
                           .i_data       (ibp_rfifo_i_data     ),
                           .i_ready      (ibp_rfifo_i_ready ),

                           .o_valid      (ibp_rfifo_o_valid),
                           .o_data       (ibp_rfifo_o_data    ),
                           .o_ready      (ibp_rfifo_o_ready    ),

                           // leda B_1011 off
                           // leda WV951025 off
                           // LMD: Port is not completely connected
                           // LJ: unused in this instantiation
                           .i_occp       (),
                           .o_occp       (),
                           // leda B_1011 on
                           // leda WV951025 on

                           .i_clk_en     (1'b1       ),
                           .o_clk_en     (bus_clk_en       ),
                           .clk          (clk              ),
                           .rst_a        (rst_a            )
                          );



  //--------------------------------------------------
  // IBP ibp_wr_mask generation
  //--------------------------------------------------
  reg  [(DATA_W/8)-1:0]  ahbl2ibp_wr_mask_tmp;
  always @ (*)
    begin: ahbl2ibp_wr_mask_tmp_PROC
       reg [ALSB-1:0] mask;
       //integer      i;
       //integer      j;

       mask = {(ALSB){1'b0}};

       for (i=0; i<ALSB; i=i+1)
          mask[i] = ($unsigned(i) >= ahb_hsize);

       for (j=0; j<(DATA_W/8); j=j+1)
          ahbl2ibp_wr_mask_tmp[j] = (($unsigned(j) & mask) == (ahb_haddr[ALSB-1:0] & mask));

    end

        // -- STAR 9000800944 --
        // Fix bug: generate incorrect write mask when bigendian
        //          if bigendian, ahbl2ibp_wr_mask is also the right write mask, no conversion needed
  always @(posedge clk or posedge rst_a)
    begin: ahbl2ibp_wr_mask_PROC
       if (rst_a == 1'b1)
          ahbl2ibp_wr_mask_r <= {(DATA_W/8){1'b0}};
       else if (ahb_addr_en & ahb_hwrite)
          ahbl2ibp_wr_mask_r <= ahbl2ibp_wr_mask_tmp;
    end

  assign ahbl2ibp_wr_mask = ahbl2ibp_wr_mask_r & ahb_hwstrb;

  // endian convert
  // outputs: ahb_hwdata
  always @ (*)
    begin: endian_convert_PROC
        //integer i;
        if (bigendian)
          for (i = 0; i < DATA_W/8; i = i + 1) begin
             ahbl2ibp_wr_data[i*8+:8]   = ahb_hwdata[DATA_W-8-i*8+:8];
             ibp_rd_data_endian[i*8+:8] = ibp_rd_data[DATA_W-8-i*8+:8];
          end
        else begin
           ahbl2ibp_wr_data = ahb_hwdata;
           ibp_rd_data_endian = ibp_rd_data;
        end
    end // endian_convert_PROC

  //------------------------------------------------------------
  // block IBP interface during sync_rst_r (synced reset)
  //------------------------------------------------------------
  assign ibp_cmd_valid      = ibp_cmd_valid_int & (~sync_rst_r);
  assign ibp_cmd_accept_int = ibp_cmd_accept & (~sync_rst_r);

  assign ibp_wr_valid       = ibp_wr_valid_int & (~sync_rst_r);
  assign ibp_wr_accept_int  = ibp_wr_accept & (~sync_rst_r);

  assign ibp_wr_done_int    = ibp_wr_done & (~sync_rst_r);
  assign ibp_err_wr_int     = ibp_err_wr & (~sync_rst_r);
  assign ibp_wr_resp_accept = ibp_wr_resp_accept_int & (~sync_rst_r);
  assign ibp_wr_excl_done_int = ibp_wr_excl_done & (~sync_rst_r);

  assign ibp_rd_valid_int   = ibp_rd_valid & (~sync_rst_r);
  assign ibp_err_rd_int     = ibp_err_rd & (~sync_rst_r);
  assign ibp_rd_accept      = ibp_rd_accept_int & (~sync_rst_r);
  assign ibp_rd_excl_ok_int = ibp_rd_excl_ok & (~sync_rst_r);

  //--------------------------------------------------
  // SV Assertion Checkers
  //--------------------------------------------------

endmodule // alb_mss_fab_ahbl2ibp


