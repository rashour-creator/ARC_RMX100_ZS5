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
//  ### ######  ######   #####      #     #     #  ######
//   #  #     # #     # #     #    # #    #     #  #     #
//   #  #     # #     #       #   #   #   #     #  #     #
//   #  ######  ######   #####   #     #  #######  ######
//   #  #     # #       #        #######  #     #  #     #
//   #  #     # #       #        #     #  #     #  #     #
//  ### ######  #       #######  #     #  #     #  ######
//
// ===========================================================================
//
// Description:
//  Verilog module to convert the IBP to AHB-Lite protocol
//
// ===========================================================================
//

// Set simulation timescale
//
`include "const.def"


module alb_mss_fab_ibp2ahbl
  #(
    parameter CHNL_FIFO_DEPTH = 2,
    // ADDR_W indicate the width of address
        // It can be any value
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
        // It can be 32, 64, 128
    parameter DATA_W = 64,
    // ALSB indicate least significant bit of the address
        // It should be log2(DATA_W/8), eg: 2 for 32b, 3 for 64b, 4 for 128b
    parameter ALSB = 3
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
  input  wire                  ibp_cmd_excl,
  input  wire [1:0]            ibp_cmd_prot,
  input  wire [3:0]            ibp_cmd_cache,
  //
  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  output wire                  ibp_rd_valid,
  output wire                  ibp_rd_excl_ok,
  input  wire                  ibp_rd_accept,
  output wire [DATA_W-1:0]     ibp_rd_data,
  output wire                  ibp_rd_last,
  output wire                  ibp_err_rd,
  //
  // write data channel
  input  wire                  ibp_wr_valid,
  output wire                  ibp_wr_accept,
  input  wire [DATA_W-1:0]     ibp_wr_data,
  input  wire [(DATA_W/8)-1:0] ibp_wr_mask,
  input  wire                  ibp_wr_last,
  //
  // write response channel
  // This module do not support id
  output wire                  ibp_wr_done,
  output wire                  ibp_wr_excl_done,
  output wire                  ibp_err_wr,
  input  wire                  ibp_wr_resp_accept,

  // The "ahb_xxx" bus is the AHB-Lite interface after converted
  output wire [1:0]            ahb_htrans,    // AHB transaction type (IDLE, BUSY, SEQ, NSEQ)
  output wire                  ahb_hwrite,    // If true then write
  output wire                  ahb_hlock,     // If true then locked
  output wire [ADDR_W-1:0]     ahb_haddr,     // Address
  output wire [2:0]            ahb_hsize,     // Transaction size
  output wire [2:0]            ahb_hburst,    // Burst type SINGLE, INCR, etc
  output wire [3:0]            ahb_hprot,     // Protection attributes
  output wire                  ahb_hexcl,     // Exclusive access sideband (non standard)
  output wire [DATA_W-1:0]     ahb_hwdata,    // Write data
  input  wire [DATA_W-1:0]     ahb_hrdata,    // Read data
  input  wire                  ahb_hresp,     // Response 0=OK, 1=ERROR
  input  wire                  ahb_hrexok,    // Exclusive response 0=FAIL, 1=SUCCESS (non standard)
  input  wire                  ahb_hready,    // AHB transfer ready

  // Clock and reset
  input                   clk,           // clock signal
  input                   bus_clk_en,    // clock enable signal to control the N:1 clock ratios
  input                   rst_a,         // reset signal
  input                   bigendian      // If true, then bigendian
  );

  //-------------------------------------------------------------
  // Parameters Definition
  //-------------------------------------------------------------
  localparam IBP_CMD_CHNL_PACK_WIDTH = 1+ADDR_W+1+3+4+1+1+2+4;
  localparam IBP_WR_CHNL_PACK_WIDTH  = DATA_W+(DATA_W/8)+1;

  // Because ibp2ahb at most have 5+1 outstandings (2 Afifo entries + 3 Rfifo entries + 1 cmd_bybuf entry)
  localparam OUT_CMD_CNT_W  = 3;// no need to worry about the cnt overflow then

  // No suppor the excl trans
  //assign ahb_hexcl = 1'b0;
  //assign ibp_wr_excl_done = 1'b0;
  //assign ibp_rd_excl_ok = 1'b0;

  // The "ibp_cmd_bypbuf" is to cut the timing path of ibp_cmd_accept
  // Notes: might create timing loop with ibp_buffer if there is no bypbuf
  wire                  ibp_cmd_valid_int;
  wire                  ibp_cmd_accept_int;
  wire                  ibp_cmd_read_int;
  wire [ADDR_W-1:0]     ibp_cmd_addr_int;
  wire                  ibp_cmd_wrap_int;
  wire [2:0]            ibp_cmd_data_size_int;
  wire [3:0]            ibp_cmd_burst_size_int;
  wire                  ibp_cmd_lock_int;
  wire                  ibp_cmd_excl_int;
  wire [1:0]            ibp_cmd_prot_int;
  wire [3:0]            ibp_cmd_cache_int;

  wire [IBP_CMD_CHNL_PACK_WIDTH-1:0] ibp_cmd_chnl_pack =
                                                         {
                                                          ibp_cmd_read,
                                                          ibp_cmd_addr,
                                                          ibp_cmd_wrap,
                                                          ibp_cmd_data_size,
                                                          ibp_cmd_burst_size,
                                                          ibp_cmd_lock,
                                                          ibp_cmd_excl,
                                                          ibp_cmd_prot,
                                                          ibp_cmd_cache
                                                         };

  wire [IBP_CMD_CHNL_PACK_WIDTH-1:0] ibp_cmd_chnl_pack_int;

  assign {
          ibp_cmd_read_int,
          ibp_cmd_addr_int,
          ibp_cmd_wrap_int,
          ibp_cmd_data_size_int,
          ibp_cmd_burst_size_int,
          ibp_cmd_lock_int,
          ibp_cmd_excl_int,
          ibp_cmd_prot_int,
          ibp_cmd_cache_int
         }
          = ibp_cmd_chnl_pack_int;

  alb_mss_fab_bypbuf
    #(
      .BUF_DEPTH(1),
      .BUF_WIDTH(IBP_CMD_CHNL_PACK_WIDTH)
    ) u_ibp_cmd_bypbuf
    (
    .i_ready    (ibp_cmd_accept       ),
    .i_valid    (ibp_cmd_valid        ),
    .i_data     (ibp_cmd_chnl_pack    ),
    .o_ready    (ibp_cmd_accept_int   ),
    .o_valid    (ibp_cmd_valid_int    ),
    .o_data     (ibp_cmd_chnl_pack_int),

    .clk        (clk                  ),
    .rst_a      (rst_a                )
    );

  // The "ibp_wd_bypbuf" is to cut the timing path of ibp_wr_accept
  wire                  ibp_wr_valid_int;
  wire                  ibp_wr_accept_int;  // from bypbuf
  wire [DATA_W-1:0]     ibp_wr_data_int;
  wire [(DATA_W/8)-1:0] ibp_wr_mask_int;
  wire                  ibp_wr_last_int;

  wire                  ibp_wr_valid_tmp;   // for internally handling before sending to bypbuf
  wire                  ibp_wr_accept_tmp;  // for internally handling before sending out

  wire [IBP_WR_CHNL_PACK_WIDTH-1:0] ibp_wr_chnl_pack =
                                                      {
                                                       ibp_wr_data,
                                                       ibp_wr_mask,
                                                       ibp_wr_last
                                                      };

  wire [IBP_WR_CHNL_PACK_WIDTH-1:0] ibp_wr_chnl_pack_int;

  assign {
          ibp_wr_data_int,
          ibp_wr_mask_int,
          ibp_wr_last_int
         }
          = ibp_wr_chnl_pack_int;

  alb_mss_fab_bypbuf
    #(
      .BUF_DEPTH(1),
      .BUF_WIDTH(IBP_WR_CHNL_PACK_WIDTH)
    ) u_ibp_wd_bypbuf
    (
    .i_ready    (ibp_wr_accept_tmp    ),
    .i_valid    (ibp_wr_valid_tmp     ),
    .i_data     (ibp_wr_chnl_pack     ),
    .o_ready    (ibp_wr_accept_int    ),
    .o_valid    (ibp_wr_valid_int     ),
    .o_data     (ibp_wr_chnl_pack_int ),

    .clk        (clk                  ),
    .rst_a      (rst_a                )
    );

  // Notes: cmd_wait_wd_cnt to guarantee ibp_wr_accept not asserted before ibp_cmd_accept
  wire cmd_wait_wd_cnt_udf;
  //wire ibp_cmd_wait_wd = (ibp_cmd_accept & (~ibp_cmd_read)) | (~cmd_wait_wd_cnt_udf);
  wire ibp_cmd_wait_wd = ibp_cmd_accept | (~cmd_wait_wd_cnt_udf);

  assign ibp_wr_valid_tmp = ibp_wr_valid & ibp_cmd_wait_wd;
  assign ibp_wr_accept    = ibp_wr_accept_tmp & ibp_cmd_wait_wd;

  //--------------------------------------------------------
  // Count how much of the cmd is waiting write burst data
  //--------------------------------------------------------
  // Notes: Move from ahb_single2ahbl to handle the direct write data path only,
  //        because dead lock might be introduced when handling side buffer data path
  reg [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_r;
  wire cmd_wait_wd_cnt_ovf = (cmd_wait_wd_cnt_r[OUT_CMD_CNT_W] == 1'b1);
  assign cmd_wait_wd_cnt_udf = (cmd_wait_wd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
  // The ibp wr burst counter increased when a IBP write command accepted to the axi_aw stage
  wire cmd_wait_wd_cnt_inc = ibp_cmd_valid & ibp_cmd_accept & (~ibp_cmd_read);
  // The ibp wr burst counter decreased when a last beat of IBP write burst accepted to axi_wd stage
  //wire cmd_wait_wd_cnt_dec = (ibp_wr_valid & ibp_wr_accept);
  wire cmd_wait_wd_cnt_dec = (ibp_wr_valid & ibp_wr_accept & ibp_wr_last);
  wire cmd_wait_wd_cnt_ena = cmd_wait_wd_cnt_inc | cmd_wait_wd_cnt_dec;
  // leda B_3200 off
  // leda B_3219 off
  // LMD: Unequal length operand in bit/arithmetic operator
  // LJ: there is no overflow risk
  // leda BTTF_D002 off
  // LMD: Unequal length LHS and RHS in assignment
  // LJ: there is no overflow risk
  // leda W484 off
  // LMD: Possible loss of carry/borrow in addition/subtraction
  // LJ: there is no overflow risk
  wire [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_nxt =
        ( cmd_wait_wd_cnt_inc & (~cmd_wait_wd_cnt_dec)) ? (cmd_wait_wd_cnt_r + 1'b1)
      : (~cmd_wait_wd_cnt_inc &  cmd_wait_wd_cnt_dec) ? (cmd_wait_wd_cnt_r - 1'b1)
      : cmd_wait_wd_cnt_r ;
  // leda B_3219 on
  // leda B_3200 on
  // leda BTTF_D002 on
  // leda W484 on

  always @(posedge clk or posedge rst_a)
  begin : cmd_wait_wd_cnt_DFFEAR_PROC
    if (rst_a == 1'b1) begin
        cmd_wait_wd_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
    end
    else if (cmd_wait_wd_cnt_ena == 1'b1) begin
        cmd_wait_wd_cnt_r        <= cmd_wait_wd_cnt_nxt;
    end
  end

// The "sgl_ibp_xxx" bus is the one IBP after split into single-beat
wire                  sgl_ibp_cmd_valid;
wire                  sgl_ibp_cmd_accept;
wire                  sgl_ibp_cmd_read;
wire [ADDR_W-1:0]     sgl_ibp_cmd_addr;
wire                  sgl_ibp_cmd_wrap;
wire [2:0]            sgl_ibp_cmd_data_size;
wire [3:0]            sgl_ibp_cmd_burst_size;
wire                  sgl_ibp_cmd_lock;
wire [1:0]            sgl_ibp_cmd_prot;
wire [3:0]            sgl_ibp_cmd_cache;
wire                  sgl_ibp_cmd_excl;

wire                  sgl_ibp_cmd_burst_en;
wire [2:0]            sgl_ibp_cmd_burst_type;
wire                  sgl_ibp_cmd_burst_last;

wire                  sgl_ibp_rd_valid;
wire                  sgl_ibp_rd_accept;
wire [DATA_W-1:0]     sgl_ibp_rd_data;
wire                  sgl_ibp_err_rd;
wire                  sgl_ibp_rd_excl_ok;

wire                  sgl_ibp_wr_valid;
wire                  sgl_ibp_wr_accept;
wire [DATA_W-1:0]     sgl_ibp_wr_data;
wire [(DATA_W/8)-1:0] sgl_ibp_wr_mask;

wire                  sgl_ibp_wr_done;
wire                  sgl_ibp_err_wr;
wire                  sgl_ibp_wr_resp_accept;
wire                  sgl_ibp_wr_excl_done;

alb_mss_fab_ibp2single
  #(
    .CUT_IN2OUT_WR_ACPT    (0),
    .ADDR_W                (ADDR_W ),
    .DATA_W                (DATA_W ),
    .USER_W                (1),
    .RGON_W                (1),
    .SPLT_FIFO_DEPTH       (5)
    ) u_ahb_ibp2single
  (

    .clk                  (clk),
    .rst_a                (rst_a),

    .i_ibp_cmd_valid      (ibp_cmd_valid_int      ),
    .i_ibp_cmd_accept     (ibp_cmd_accept_int     ),
    .i_ibp_cmd_read       (ibp_cmd_read_int       ),
    .i_ibp_cmd_addr       (ibp_cmd_addr_int       ),
    .i_ibp_cmd_wrap       (ibp_cmd_wrap_int       ),
    .i_ibp_cmd_data_size  (ibp_cmd_data_size_int  ),
    .i_ibp_cmd_burst_size (ibp_cmd_burst_size_int ),
    .i_ibp_cmd_lock       (ibp_cmd_lock_int       ),
    .i_ibp_cmd_prot       (ibp_cmd_prot_int       ),
    .i_ibp_cmd_cache      (ibp_cmd_cache_int      ),
    .i_ibp_cmd_excl       (ibp_cmd_excl_int       ),

    .i_ibp_cmd_rgon       (1'b0),
    .i_ibp_cmd_user       (1'b0),

    .i_ibp_rd_valid       (ibp_rd_valid       ),
    .i_ibp_rd_accept      (ibp_rd_accept      ),
    .i_ibp_rd_data        (ibp_rd_data        ),
    .i_ibp_rd_last        (ibp_rd_last        ),
    .i_ibp_err_rd         (ibp_err_rd         ),
    .i_ibp_rd_excl_ok     (ibp_rd_excl_ok     ),

    .i_ibp_wr_valid       (ibp_wr_valid_int   ),
    .i_ibp_wr_accept      (ibp_wr_accept_int  ),
    .i_ibp_wr_data        (ibp_wr_data_int    ),
    .i_ibp_wr_mask        (ibp_wr_mask_int    ),
    .i_ibp_wr_last        (ibp_wr_last_int    ),

    .i_ibp_wr_done        (ibp_wr_done        ),
    .i_ibp_err_wr         (ibp_err_wr         ),
    .i_ibp_wr_resp_accept (ibp_wr_resp_accept ),
    .i_ibp_wr_excl_done   (ibp_wr_excl_done   ),

    .o_ibp_cmd_valid      (sgl_ibp_cmd_valid     ),
    .o_ibp_cmd_accept     (sgl_ibp_cmd_accept    ),
    .o_ibp_cmd_read       (sgl_ibp_cmd_read      ),
    .o_ibp_cmd_addr       (sgl_ibp_cmd_addr      ),
    .o_ibp_cmd_wrap       (sgl_ibp_cmd_wrap      ),
    .o_ibp_cmd_data_size  (sgl_ibp_cmd_data_size ),
    .o_ibp_cmd_burst_size (sgl_ibp_cmd_burst_size),
    .o_ibp_cmd_lock       (sgl_ibp_cmd_lock      ),
    .o_ibp_cmd_prot       (sgl_ibp_cmd_prot      ),
    .o_ibp_cmd_cache      (sgl_ibp_cmd_cache     ),
    .o_ibp_cmd_excl       (sgl_ibp_cmd_excl      ),

    .o_ibp_cmd_burst_en   (sgl_ibp_cmd_burst_en  ), // side-band signals
    .o_ibp_cmd_burst_type (sgl_ibp_cmd_burst_type), // side-band signals
    .o_ibp_cmd_burst_last (sgl_ibp_cmd_burst_last), // side-band signals

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_cmd_rgon       (),
    .o_ibp_cmd_user       (),
// leda B_1011 on
// leda WV951025 on

    .o_ibp_rd_valid       (sgl_ibp_rd_valid      ),
    .o_ibp_rd_accept      (sgl_ibp_rd_accept     ),
    .o_ibp_rd_data        (sgl_ibp_rd_data       ),
    .o_ibp_err_rd         (sgl_ibp_err_rd        ),
    .o_ibp_rd_last        (1'b1),
    .o_ibp_rd_excl_ok     (sgl_ibp_rd_excl_ok    ),

    .o_ibp_wr_valid       (sgl_ibp_wr_valid      ),
    .o_ibp_wr_accept      (sgl_ibp_wr_accept     ),
    .o_ibp_wr_data        (sgl_ibp_wr_data       ),
    .o_ibp_wr_mask        (sgl_ibp_wr_mask       ),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
    .o_ibp_wr_last        (),
// leda B_1011 on
// leda WV951025 on

    .o_ibp_wr_done        (sgl_ibp_wr_done       ),
    .o_ibp_err_wr         (sgl_ibp_err_wr        ),
    .o_ibp_wr_resp_accept (sgl_ibp_wr_resp_accept),
    .o_ibp_wr_excl_done   (sgl_ibp_wr_excl_done  )
  );

// The "spr_ibp_xxx" bus is the one IBP after sparse mask checking
wire                  spr_ibp_cmd_valid;
wire                  spr_ibp_cmd_accept;
wire                  spr_ibp_cmd_read;
wire [ADDR_W-1:0]     spr_ibp_cmd_addr;
wire                  spr_ibp_cmd_wrap;
wire [2:0]            spr_ibp_cmd_data_size;
wire [3:0]            spr_ibp_cmd_burst_size;
wire                  spr_ibp_cmd_lock;
wire [1:0]            spr_ibp_cmd_prot;
wire [3:0]            spr_ibp_cmd_cache;
wire                  spr_ibp_cmd_excl;

wire                  spr_ibp_cmd_burst_en;
wire [2:0]            spr_ibp_cmd_burst_type;
wire                  spr_ibp_cmd_burst_last;
wire                  spr_ibp_cmd_wr_splt_last;

wire                  spr_ibp_rd_valid;
wire                  spr_ibp_rd_accept;
wire [DATA_W-1:0]     spr_ibp_rd_data;
wire                  spr_ibp_err_rd;
wire                  spr_ibp_rd_excl_ok;

wire                  spr_ibp_wr_valid;
wire                  spr_ibp_wr_accept;
wire [DATA_W-1:0]     spr_ibp_wr_data;

wire                  spr_ibp_wr_done;
wire                  spr_ibp_err_wr;
wire                  spr_ibp_wr_resp_accept;
wire                  spr_ibp_wr_excl_done;

alb_mss_fab_single2sparse
  #(
    .ADDR_W                (ADDR_W ),
    .DATA_W                (DATA_W ),
    .ALSB                  (ALSB   )
    ) u_ahb_single2sparse
  (
    .clk                  (clk),
    .rst_a                (rst_a),

    .i_ibp_cmd_valid      (sgl_ibp_cmd_valid      ),
    .i_ibp_cmd_accept     (sgl_ibp_cmd_accept     ),
    .i_ibp_cmd_read       (sgl_ibp_cmd_read       ),
    .i_ibp_cmd_addr       (sgl_ibp_cmd_addr       ),
    .i_ibp_cmd_wrap       (sgl_ibp_cmd_wrap       ),
    .i_ibp_cmd_data_size  (sgl_ibp_cmd_data_size  ),
    .i_ibp_cmd_burst_size (sgl_ibp_cmd_burst_size ),
    .i_ibp_cmd_lock       (sgl_ibp_cmd_lock       ),
    .i_ibp_cmd_prot       (sgl_ibp_cmd_prot       ),
    .i_ibp_cmd_cache      (sgl_ibp_cmd_cache      ),
    .i_ibp_cmd_excl       (sgl_ibp_cmd_excl       ),

    .i_ibp_cmd_burst_en   (sgl_ibp_cmd_burst_en   ), // side-band signals
    .i_ibp_cmd_burst_type (sgl_ibp_cmd_burst_type ), // side-band signals
    .i_ibp_cmd_burst_last (sgl_ibp_cmd_burst_last ), // side-band signals

    .i_ibp_rd_valid       (sgl_ibp_rd_valid       ),
    .i_ibp_rd_accept      (sgl_ibp_rd_accept      ),
    .i_ibp_rd_data        (sgl_ibp_rd_data        ),
    .i_ibp_err_rd         (sgl_ibp_err_rd         ),
    .i_ibp_rd_excl_ok     (sgl_ibp_rd_excl_ok     ),

    .i_ibp_wr_valid       (sgl_ibp_wr_valid       ),
    .i_ibp_wr_accept      (sgl_ibp_wr_accept      ),
    .i_ibp_wr_data        (sgl_ibp_wr_data        ),
    .i_ibp_wr_mask        (sgl_ibp_wr_mask        ),

    .i_ibp_wr_done        (sgl_ibp_wr_done        ),
    .i_ibp_err_wr         (sgl_ibp_err_wr         ),
    .i_ibp_wr_resp_accept (sgl_ibp_wr_resp_accept ),
    .i_ibp_wr_excl_done   (sgl_ibp_wr_excl_done   ),

    .o_ibp_cmd_valid      (spr_ibp_cmd_valid     ),
    .o_ibp_cmd_accept     (spr_ibp_cmd_accept    ),
    .o_ibp_cmd_read       (spr_ibp_cmd_read      ),
    .o_ibp_cmd_addr       (spr_ibp_cmd_addr      ),
    .o_ibp_cmd_wrap       (spr_ibp_cmd_wrap      ),
    .o_ibp_cmd_data_size  (spr_ibp_cmd_data_size ),
    .o_ibp_cmd_burst_size (spr_ibp_cmd_burst_size),
    .o_ibp_cmd_lock       (spr_ibp_cmd_lock      ),
    .o_ibp_cmd_prot       (spr_ibp_cmd_prot      ),
    .o_ibp_cmd_cache      (spr_ibp_cmd_cache     ),
    .o_ibp_cmd_excl       (spr_ibp_cmd_excl      ),

    .o_ibp_cmd_burst_en   (spr_ibp_cmd_burst_en  ),    // side-band signals
    .o_ibp_cmd_burst_type (spr_ibp_cmd_burst_type),    // side-band signals
    .o_ibp_cmd_burst_last (spr_ibp_cmd_burst_last),    // side-band signals
    .o_ibp_cmd_wr_splt_last(spr_ibp_cmd_wr_splt_last), // side-band signals

    .o_ibp_rd_valid       (spr_ibp_rd_valid      ),
    .o_ibp_rd_accept      (spr_ibp_rd_accept     ),
    .o_ibp_rd_data        (spr_ibp_rd_data       ),
    .o_ibp_err_rd         (spr_ibp_err_rd        ),
    .o_ibp_rd_excl_ok     (spr_ibp_rd_excl_ok    ),


    .o_ibp_wr_valid       (spr_ibp_wr_valid      ),
    .o_ibp_wr_accept      (spr_ibp_wr_accept     ),
    .o_ibp_wr_data        (spr_ibp_wr_data       ),

    .o_ibp_wr_done        (spr_ibp_wr_done       ),
    .o_ibp_err_wr         (spr_ibp_err_wr        ),
    .o_ibp_wr_resp_accept (spr_ibp_wr_resp_accept),
    .o_ibp_wr_excl_done   (spr_ibp_wr_excl_done  )
    );

alb_mss_fab_single2ahbl
  #(
    .CHNL_FIFO_DEPTH       (CHNL_FIFO_DEPTH ),
    .ADDR_W                (ADDR_W ),
    .DATA_W                (DATA_W )
    ) u_ahb_single2ahbl
  (
  .ibp_cmd_valid         (spr_ibp_cmd_valid     ),
  .ibp_cmd_accept        (spr_ibp_cmd_accept    ),
  .ibp_cmd_read          (spr_ibp_cmd_read      ),
  .ibp_cmd_addr          (spr_ibp_cmd_addr      ),
  .ibp_cmd_wrap          (spr_ibp_cmd_wrap      ),
  .ibp_cmd_data_size     (spr_ibp_cmd_data_size ),
  .ibp_cmd_burst_size    (spr_ibp_cmd_burst_size),
  .ibp_cmd_lock          (spr_ibp_cmd_lock      ),
  .ibp_cmd_prot          (spr_ibp_cmd_prot      ),
  .ibp_cmd_cache         (spr_ibp_cmd_cache     ),
  .ibp_cmd_excl          (spr_ibp_cmd_excl      ),

  .ibp_cmd_burst_en      (spr_ibp_cmd_burst_en  ),  // side-band signals
  .ibp_cmd_burst_type    (spr_ibp_cmd_burst_type),  // side-band signals
  .ibp_cmd_burst_last    (spr_ibp_cmd_burst_last),  // side-band signals
  .ibp_cmd_wr_splt_last  (spr_ibp_cmd_wr_splt_last),// side-band signals

  .ibp_rd_valid          (spr_ibp_rd_valid      ),
  .ibp_rd_accept         (spr_ibp_rd_accept     ),
  .ibp_rd_data           (spr_ibp_rd_data       ),
  .ibp_err_rd            (spr_ibp_err_rd        ),
  .ibp_rd_excl_ok        (spr_ibp_rd_excl_ok    ),

  .ibp_wr_valid          (spr_ibp_wr_valid      ),
  .ibp_wr_accept         (spr_ibp_wr_accept     ),
  .ibp_wr_data           (spr_ibp_wr_data       ),

  .ibp_wr_done           (spr_ibp_wr_done       ),
  .ibp_err_wr            (spr_ibp_err_wr        ),
  .ibp_wr_resp_accept    (spr_ibp_wr_resp_accept),
  .ibp_wr_excl_done      (spr_ibp_wr_excl_done  ),

  .ahb_htrans            (ahb_htrans ),
  .ahb_hwrite            (ahb_hwrite ),
  .ahb_hlock             (ahb_hlock  ),
  .ahb_haddr             (ahb_haddr  ),
  .ahb_hsize             (ahb_hsize  ),
  .ahb_hburst            (ahb_hburst ),
  .ahb_hprot             (ahb_hprot  ),
  .ahb_hexcl             (ahb_hexcl  ),
  .ahb_hwdata            (ahb_hwdata ),
  .ahb_hrdata            (ahb_hrdata ),
  .ahb_hresp             (ahb_hresp  ),
  .ahb_hrexok            (ahb_hrexok ),
  .ahb_hready            (ahb_hready ),

  .clk                   (clk       ),
  .bus_clk_en            (bus_clk_en),
  .rst_a                 (rst_a     ),
  .bigendian             (bigendian )
  );

  //--------------------------------------------------
  // SV Assertion Checkers
  //--------------------------------------------------


endmodule // alb_mss_fab_ibp2ahbl
