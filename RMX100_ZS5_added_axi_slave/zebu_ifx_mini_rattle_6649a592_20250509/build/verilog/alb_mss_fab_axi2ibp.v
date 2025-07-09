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
//    #    #     #   ###    #####    ###   ######  ######
//   # #    #   #     #    #     #    #    #     # #     #
//  #   #    # #      #          #    #    #     # #     #
// #     #    #       #     #####     #    ######  ######
// #######   # #      #    #          #    #     # #
// #     #  #   #     #    #          #    #     # #
// #     # #     #   ###   #######   ###   ######  #
//
// ===========================================================================
//
// Description:
//  Verilog module to convert the AXI to IBP protocol
//  The converted IBP is standard IBP, it have some constraints:
//    * no-narrow transfer supported for burst mode
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"

module alb_mss_fab_axi2ibp
  #(
    parameter BUS_SUPPORT_RTIO = 0,
    parameter FORCE_TO_SINGLE = 0,
    parameter X_W = 32,
    parameter Y_W = 32,

    parameter RGON_W = 7,
    parameter BUS_ID_W = 16,
    parameter BYPBUF_DEPTH = 16,
   // The FIFO Depth indicated the FIFO entries
    parameter SPLT_FIFO_DEPTH = 16,
    parameter CHNL_FIFO_DEPTH = 1,
    parameter OUT_CMD_NUM = 16,
    parameter OUT_CMD_CNT_W = 4,
    // ADDR_W indicate the width of address
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
    parameter DATA_W = 32
    )
  (
  // We need to force the bus ready signals to be low during reset applied
  input  sync_rst_r, //Synced version of external reset, when value is 1, means resetted
  // The "AXI_xxx" bus is the one AXI to be converted
  //
  // Read address channel
  input  axi_arvalid,
  output axi_arready,
  input  [ADDR_W-1:0] axi_araddr,
  input  [3:0] axi_arcache,
  input  [2:0] axi_arprot,
  input  [1:0] axi_arlock,
  input  [1:0] axi_arburst,
  input  [3:0] axi_arlen,
  input  [2:0] axi_arsize,

  input  [RGON_W-1:0] axi_arregion,
  input  [BUS_ID_W-1:0] axi_arid,

  // Write address channel
  input  axi_awvalid,
  output axi_awready,
  input  [ADDR_W-1:0] axi_awaddr,
  input  [3:0] axi_awcache,
  input  [2:0] axi_awprot,
  input  [1:0] axi_awlock,
  input  [1:0] axi_awburst,
  input  [3:0] axi_awlen,
  input  [2:0] axi_awsize,

  input  [RGON_W-1:0] axi_awregion,
  input  [BUS_ID_W-1:0] axi_awid,

  // Read data channel
  output axi_rvalid,
  input  axi_rready,
  output [DATA_W-1:0] axi_rdata,
  output [1:0] axi_rresp,
  output axi_rlast,

  output [BUS_ID_W-1:0] axi_rid,

  // Write data channel
  input  axi_wvalid,
  output axi_wready,
  input  [DATA_W-1:0] axi_wdata,
  input  [(DATA_W/8)-1:0] axi_wstrb,
  input  axi_wlast,

  // Write response channel
  output axi_bvalid,
  input  axi_bready,
  output [1:0] axi_bresp,

  output [BUS_ID_W-1:0] axi_bid,

  // The "ibp_xxx" bus is the one IBP after converted
  //
  // command channel
  // This module Do not support the id and snoop
  output ibp_cmd_valid,
  input  ibp_cmd_accept,
  output ibp_cmd_read,
  output [ADDR_W-1:0] ibp_cmd_addr,
  output ibp_cmd_wrap,
  output [2:0] ibp_cmd_data_size,
  output [3:0] ibp_cmd_burst_size,
  output ibp_cmd_lock,
  output ibp_cmd_excl,
  output [1:0] ibp_cmd_prot,
  output [3:0] ibp_cmd_cache,
  output [RGON_W-1:0] ibp_cmd_rgon,
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


  input  bus_clk_en,  // clock ratio signal
  input  clk,  // clock signal
  input  rst_a // reset signal
  );



  wire i_ibp_cmd_valid;
  wire i_ibp_cmd_accept;
  wire i_ibp_cmd_read;
  wire [ADDR_W-1:0] i_ibp_cmd_addr;
  wire i_ibp_cmd_wrap;
  wire [2:0] i_ibp_cmd_data_size;
  wire [3:0] i_ibp_cmd_burst_size;
  wire i_ibp_cmd_lock;
  wire i_ibp_cmd_excl;
  wire [1:0] i_ibp_cmd_prot;
  wire [3:0] i_ibp_cmd_cache;
  wire [RGON_W-1:0] i_ibp_cmd_rgon;

  wire                  i_axi_arvalid;
  wire                  i_axi_arready;
  wire [ADDR_W-1:0]     i_axi_araddr;
  wire [3:0]            i_axi_arcache;
  wire [2:0]            i_axi_arprot;
  wire [1:0]            i_axi_arlock;
  wire [1:0]            i_axi_arburst;
  wire [3:0]            i_axi_arlen;
  wire [2:0]            i_axi_arsize;
  wire [RGON_W-1:0]     i_axi_arregion;
  wire [BUS_ID_W-1:0]   i_axi_arid;

  // Write address channel
  wire                  i_axi_awvalid;
  wire                  i_axi_awready;
  wire [ADDR_W-1:0]     i_axi_awaddr;
  wire [3:0]            i_axi_awcache;
  wire [2:0]            i_axi_awprot;
  wire [1:0]            i_axi_awlock;
  wire [1:0]            i_axi_awburst;
  wire [3:0]            i_axi_awlen;
  wire [2:0]            i_axi_awsize;
  wire [RGON_W-1:0]     i_axi_awregion;
  wire [BUS_ID_W-1:0]   i_axi_awid;

  // Read data channel
  wire                  i_axi_rvalid;
  wire                  i_axi_rready;
  wire [DATA_W-1:0]     i_axi_rdata;
  wire [1:0]            i_axi_rresp;
  wire                  i_axi_rlast;
  wire [BUS_ID_W-1:0]   i_axi_rid;

  // Write data channel
  wire                  i_axi_wvalid;
  wire                  i_axi_wready;
  wire [DATA_W-1:0]     i_axi_wdata;
  wire [(DATA_W/8)-1:0] i_axi_wstrb;
  wire                  i_axi_wlast;

  // Write response channel
  wire                  i_axi_bvalid;
  wire                  i_axi_bready;
  wire [1:0]            i_axi_bresp;
  wire [BUS_ID_W-1:0]   i_axi_bid;



alb_mss_fab_slv_axi_buffer
  #(
    .O_SUPPORT_RTIO (0),
    .I_SUPPORT_RTIO (BUS_SUPPORT_RTIO),
    .CHNL_FIFO_DEPTH(CHNL_FIFO_DEPTH),
    .ID_W           (BUS_ID_W),
    .USER_W         (1),
    .RGON_W         (RGON_W),
    .ADDR_W         (ADDR_W),
    .DATA_W         (DATA_W)
    ) u_axi2ibp_axi_buffer
  (
  .i_sync_rst_r     (sync_rst_r     ),

  .i_axi_arid       (axi_arid       ),
  .i_axi_arvalid    (axi_arvalid    ),
  .i_axi_arready    (axi_arready    ),
  .i_axi_araddr     (axi_araddr     ),
  .i_axi_arcache    (axi_arcache    ),
  .i_axi_arprot     (axi_arprot     ),
  .i_axi_arlock     (axi_arlock     ),
  .i_axi_arburst    (axi_arburst    ),
  .i_axi_arlen      (axi_arlen      ),
  .i_axi_arsize     (axi_arsize     ),
  .i_axi_aruser     (1'b0     ),
  .i_axi_arregion   (axi_arregion   ),

  .i_axi_awid       (axi_awid       ),
  .i_axi_awvalid    (axi_awvalid    ),
  .i_axi_awready    (axi_awready    ),
  .i_axi_awaddr     (axi_awaddr     ),
  .i_axi_awcache    (axi_awcache    ),
  .i_axi_awprot     (axi_awprot     ),
  .i_axi_awlock     (axi_awlock     ),
  .i_axi_awburst    (axi_awburst    ),
  .i_axi_awlen      (axi_awlen      ),
  .i_axi_awsize     (axi_awsize     ),
  .i_axi_awuser     (1'b0     ),
  .i_axi_awregion   (axi_awregion   ),

  .i_axi_rid        (axi_rid        ),
  .i_axi_rvalid     (axi_rvalid     ),
  .i_axi_rready     (axi_rready     ),
  .i_axi_rdata      (axi_rdata      ),
  .i_axi_rresp      (axi_rresp      ),
  .i_axi_rlast      (axi_rlast      ),

  .i_axi_wid        ({BUS_ID_W{1'b0}}        ),
  .i_axi_wvalid     (axi_wvalid     ),
  .i_axi_wready     (axi_wready     ),
  .i_axi_wdata      (axi_wdata      ),
  .i_axi_wstrb      (axi_wstrb      ),
  .i_axi_wlast      (axi_wlast      ),

  .i_axi_bid        (axi_bid        ),
  .i_axi_bvalid     (axi_bvalid     ),
  .i_axi_bready     (axi_bready     ),
  .i_axi_bresp      (axi_bresp      ),

  .o_axi_arid       (i_axi_arid       ),
  .o_axi_arvalid    (i_axi_arvalid    ),
  .o_axi_arready    (i_axi_arready    ),
  .o_axi_araddr     (i_axi_araddr     ),
  .o_axi_arcache    (i_axi_arcache    ),
  .o_axi_arprot     (i_axi_arprot     ),
  .o_axi_arlock     (i_axi_arlock     ),
  .o_axi_arburst    (i_axi_arburst    ),
  .o_axi_arlen      (i_axi_arlen      ),
  .o_axi_arsize     (i_axi_arsize     ),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .o_axi_aruser     (),
// leda B_1011 on
// leda WV951025 on
  .o_axi_arregion   (i_axi_arregion   ),

  .o_axi_awid       (i_axi_awid       ),
  .o_axi_awvalid    (i_axi_awvalid    ),
  .o_axi_awready    (i_axi_awready    ),
  .o_axi_awaddr     (i_axi_awaddr     ),
  .o_axi_awcache    (i_axi_awcache    ),
  .o_axi_awprot     (i_axi_awprot     ),
  .o_axi_awlock     (i_axi_awlock     ),
  .o_axi_awburst    (i_axi_awburst    ),
  .o_axi_awlen      (i_axi_awlen      ),
  .o_axi_awsize     (i_axi_awsize     ),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .o_axi_awuser     (),
// leda B_1011 on
// leda WV951025 on
  .o_axi_awregion   (i_axi_awregion   ),

  .o_axi_rid        (i_axi_rid        ),
  .o_axi_rvalid     (i_axi_rvalid     ),
  .o_axi_rready     (i_axi_rready     ),
  .o_axi_rdata      (i_axi_rdata      ),
  .o_axi_rresp      (i_axi_rresp      ),
  .o_axi_rlast      (i_axi_rlast      ),

// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .o_axi_wid        (),
// leda B_1011 on
// leda WV951025 on
  .o_axi_wvalid     (i_axi_wvalid     ),
  .o_axi_wready     (i_axi_wready     ),
  .o_axi_wdata      (i_axi_wdata      ),
  .o_axi_wstrb      (i_axi_wstrb      ),
  .o_axi_wlast      (i_axi_wlast      ),

  .o_axi_bid        (i_axi_bid        ),
  .o_axi_bvalid     (i_axi_bvalid     ),
  .o_axi_bready     (i_axi_bready     ),
  .o_axi_bresp      (i_axi_bresp      ),

  .clk              (clk              ),
  .i_clk_en         (bus_clk_en       ),
  .o_clk_en         (1'b1             ),
  .rst_a            (rst_a            )
  );


// Converted from AXI protocol and output as combinational logics
//
// Convert for Read/Write address channel
    // Just direct assigned from IBP command channel to AXI address
//
wire axi2ibp_cmd_valid = (i_axi_arvalid | i_axi_awvalid);
//
// Because the i_axi_AW and i_axi_AR shared the same IBP command interface,
// it might be the conflict happened. So we need a round-robin arbitration
wire axi2ibp_hashked;
wire [1:0] axi2ibp_req;
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire [1:0] axi2ibp_grt;
// leda NTL_CON13A on
wire axi2ibp_cmd_accept;
assign axi2ibp_hashked = (axi2ibp_cmd_valid & axi2ibp_cmd_accept);
assign axi2ibp_req = {i_axi_arvalid, i_axi_awvalid};
// Maintain the round-robin token
alb_mss_fab_axi2ibp_rrobin # (
  .ARB_NUM(2)
  ) u_axi2ibp_rrobin(
  .req_vector          (axi2ibp_req),
  .arb_taken           (axi2ibp_hashked),
  .grt_vector          (axi2ibp_grt),
  .clk                 (clk                ),
  .rst_a               (rst_a              )
);


wire axi2ibp_cmd_sel_ar;
assign axi2ibp_cmd_sel_ar = axi2ibp_grt[1];

wire axi2ibp_cmd_read = axi2ibp_cmd_sel_ar;
//
wire [ADDR_W-1:0] axi2ibp_cmd_addr = axi2ibp_cmd_sel_ar ? i_axi_araddr : i_axi_awaddr;
//
wire [3:0] axi2ibp_acache = axi2ibp_cmd_sel_ar ? i_axi_arcache : i_axi_awcache;
wire [3:0] axi2ibp_cmd_cache = {axi2ibp_acache[0], axi2ibp_acache[1], axi2ibp_acache[2], axi2ibp_acache[3]};
//
wire [RGON_W-1:0] axi2ibp_cmd_rgon = axi2ibp_cmd_sel_ar ? i_axi_arregion : i_axi_awregion;
wire [BUS_ID_W-1:0] axi2ibp_cmd_id = axi2ibp_cmd_sel_ar ? i_axi_arid : i_axi_awid;
//
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire [2:0] axi2ibp_aprot = axi2ibp_cmd_sel_ar ? i_axi_arprot : i_axi_awprot;
// leda NTL_CON13A on
wire [1:0] axi2ibp_cmd_prot = {axi2ibp_aprot[2], axi2ibp_aprot[0]};
//
wire [1:0] axi2ibp_alock = axi2ibp_cmd_sel_ar ? i_axi_arlock : i_axi_awlock;
wire axi2ibp_cmd_lock = (axi2ibp_alock == 2'b10);
wire axi2ibp_cmd_excl = (axi2ibp_alock == 2'b01);
//
wire [2:0] axi2ibp_asize = axi2ibp_cmd_sel_ar ? i_axi_arsize : i_axi_awsize;//
wire [2:0] axi2ibp_cmd_data_size = axi2ibp_asize;
// Same width of cmd_burst_size and axlen, so just direct assignment
wire [3:0] axi2ibp_alen = axi2ibp_cmd_sel_ar ? i_axi_arlen : i_axi_awlen;//
wire [3:0] axi2ibp_cmd_burst_size = axi2ibp_alen;

// Some AXI transaction (burst) must be split into single-beat IBP transactions:
// * Because IBP only support WRAP and INCR mode, so the FIXED mode of AXI
//   need to be split into single non-burst transaction to IBP.
// * Because IBP only support WRAP and INCR mode without narrow transfer,
//   so the WRAP/INCR mode of AXI (without data_size euqal to the bus width)
//   need to be split into single beat.
//
wire[1:0] axi2ibp_aburst = axi2ibp_cmd_sel_ar ? i_axi_arburst : i_axi_awburst;
wire axi2ibp_burst_is_wrap = (axi2ibp_aburst == 2'b10);
wire axi2ibp_burst_is_incr = (axi2ibp_aburst == 2'b01);
wire axi2ibp_burst_is_fixed = (axi2ibp_aburst == 2'b00);

reg axi2ibp_sdb_wrap_r;
reg axi2ibp_sdb_fixed_r;
wire sdb_burst_is_wrap = axi2ibp_sdb_wrap_r;
wire sdb_burst_is_incr = (~axi2ibp_sdb_wrap_r) & (~axi2ibp_sdb_fixed_r);
wire sdb_burst_is_fixed = axi2ibp_sdb_fixed_r;

wire axi2ibp_narrow_trans = (~((32'd1 << axi2ibp_asize) == (DATA_W/8)));

wire axi2ibp_need_splt;


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
          assign n_bstlen_divided = (axi2ibp_alen[0]);
          assign n_addr_start_w = ~(axi2ibp_cmd_addr[2]);
        end
        if(Y_W == 128) begin: divided_32_128
          assign n_bstlen_divided = (axi2ibp_alen[1] & axi2ibp_alen[0]);
          assign n_addr_start_w = ~(|axi2ibp_cmd_addr[3:2]);
        end
    end
    if(X_W == 64) begin: divided_64
        if(Y_W == 128) begin: divided_64_128
          assign n_bstlen_divided = (axi2ibp_alen[0]);
          assign n_addr_start_w = ~(axi2ibp_cmd_addr[3]);
        end
    end
endgenerate //}

wire axi_non_ibp_burst   = (  axi2ibp_narrow_trans
                                | axi2ibp_burst_is_fixed
                               ) & (~(axi2ibp_alen == 4'b0));

generate
 if(FORCE_TO_SINGLE == 1) begin: splt_force_single
     // Always split every AXI transactions into single IBP beat transaction
   assign axi2ibp_need_splt = (~(axi2ibp_alen == 4'b0));
 end
 else if (X_W == Y_W) begin: splt_x_eq_y
     // Only split non-IBP compliant AXI transactions into single IBP beat transaction
   assign axi2ibp_need_splt = axi_non_ibp_burst;
 end
 else if (X_W > Y_W) begin: splt_x_gt_y
     if ((X_W == 128) && (Y_W == 32)) begin: splt_x_gt_y_128_32
         // Split the burst lenth equal or more than 4 beats
         // Split non-IBP compliant AXI transactions into single IBP beat transaction
       assign axi2ibp_need_splt = (~(axi2ibp_alen[3:2] == 2'b0))
                             | axi_non_ibp_burst;
     end
     else if (((X_W == 64) && (Y_W == 32)) || ((X_W == 128) && (Y_W == 64))) begin: splt_x_gt_y_64_32
         // Split the burst lenth equal or more than 8 beats
         // Split non-IBP compliant AXI transactions into single IBP beat transaction
       assign axi2ibp_need_splt = (~(axi2ibp_alen[3] == 1'b0))
                             | axi_non_ibp_burst;
     end
 end
 else if (X_W < Y_W) begin: splt_x_st_y
     // Split the burst which cannot be packed into wider bus
     // Split non-IBP compliant AXI transactions into single IBP beat transaction
   assign axi2ibp_need_splt = ((~n2w_pack_cond) & (~(axi2ibp_alen == 4'b0)))
                             | axi_non_ibp_burst;
 end

endgenerate



// If cmd_wrap is high, the transaction is mapped to WRAP; otherwise mapped to INCR. No other type of AxBURST supported.
wire axi2ibp_cmd_wrap = axi2ibp_burst_is_wrap;
wire axi2ibp_cmd_fixed = axi2ibp_burst_is_fixed;

// Implement a side-buffer to split the bursts to single-beat transactions
reg [3:0] axi2ibp_splt_cnt_r;
// When ibp cmd chnl handshaked and it is a IBP non-supported burst mode FIXED from AXI
wire ibp_cmd_sel_sdb;
wire ibp_cmd_sel_axi;
wire axi2ibp_splt_cnt_set = ibp_cmd_sel_axi & axi2ibp_need_splt & i_ibp_cmd_valid & i_ibp_cmd_accept;
// When ibp cmd chnl handshaked and it is selecting side-buffer
wire axi2ibp_splt_cnt_last = (axi2ibp_splt_cnt_r == 4'b0);
wire sdb_ibp_cmd_hshked = ibp_cmd_sel_sdb & i_ibp_cmd_valid & i_ibp_cmd_accept;
wire axi2ibp_splt_cnt_dec_last = sdb_ibp_cmd_hshked & axi2ibp_splt_cnt_last;
wire axi2ibp_splt_cnt_dec_nonlast = sdb_ibp_cmd_hshked & (~(axi2ibp_splt_cnt_last));
wire axi2ibp_splt_cnt_ena = axi2ibp_splt_cnt_set | axi2ibp_splt_cnt_dec_nonlast;
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
wire [3:0] axi2ibp_splt_cnt_nxt = ({4{axi2ibp_splt_cnt_set}} & (axi2ibp_alen - 1))
                          | ({4{axi2ibp_splt_cnt_dec_nonlast}} & (axi2ibp_splt_cnt_r - 1));
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on

reg [ADDR_W-1:0] axi2ibp_sdb_addr_r;
reg [3:0] axi2ibp_sdb_burst_size_r;
reg [2:0] axi2ibp_sdb_data_size_r;

wire [ADDR_W-1:0] axi2ibp_sdb_addr_nxt;

wire [ADDR_W-1:0] axi2ibp_cmd_addr_round;
assign axi2ibp_cmd_addr_round =
  //3'b110: 64 bytes transfer
  ({ADDR_W{axi2ibp_cmd_data_size == 3'd6}} & {axi2ibp_cmd_addr[ADDR_W-1:6],6'b000000}) |
  //3'b101: 32 bytes transfer
  ({ADDR_W{axi2ibp_cmd_data_size == 3'd5}} & {axi2ibp_cmd_addr[ADDR_W-1:5],5'b0000}) |
  //3'b100: Quad-word transfer
  ({ADDR_W{axi2ibp_cmd_data_size == 3'd4}} & {axi2ibp_cmd_addr[ADDR_W-1:4],4'b0000}) |
  //3'b011: Double-word transfer
  ({ADDR_W{axi2ibp_cmd_data_size == 3'd3}} & {axi2ibp_cmd_addr[ADDR_W-1:3],3'b000}) |
  //3'b010: Word transfer
  ({ADDR_W{axi2ibp_cmd_data_size == 3'd2}} & {axi2ibp_cmd_addr[ADDR_W-1:2],2'b00}) |
  //3'b001: Half-word transfer
  ({ADDR_W{axi2ibp_cmd_data_size == 3'd1}} & {axi2ibp_cmd_addr[ADDR_W-1:1],1'b0}) |
  //3'b000: Byte transfer
  ({ADDR_W{axi2ibp_cmd_data_size == 3'd0}} & axi2ibp_cmd_addr[ADDR_W-1:0]);


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
wire [ADDR_W-1:0] axi2ibp_cmd_addr_inc_nxt = (axi2ibp_cmd_addr_round +
       (
       //3'b110: 64 bytes transfer
       {ADDR_W{axi2ibp_cmd_data_size == 3'd6}} & 64
       //3'b101: 32 bytes transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd5}} & 32
       //3'b100: Quad-word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd4}} & 16
       //3'b011: Double-word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd3}} & 8
       //3'b010: Word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd2}} & 4
       //3'b001: Half-word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd1}} & 2
       //3'b000: Byte transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd0}} & 1
       )
       );
// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on
wire [ADDR_W-1:0] axi2ibp_cmd_wrap_vec =
        //3'b110: 64 bytes transfer
       {ADDR_W{axi2ibp_cmd_data_size == 3'd6}} & {~{{ADDR_W-10{1'b0}}, axi2ibp_cmd_burst_size}, 6'b0}
       //3'b101: 32 bytes transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd5}} & {~{{ADDR_W-9{1'b0}}, axi2ibp_cmd_burst_size}, 5'b0}
       //3'b100: Quad-word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd4}} & {~{{ADDR_W-8{1'b0}}, axi2ibp_cmd_burst_size}, 4'b0}
       //3'b011: Double-word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd3}} & {~{{ADDR_W-7{1'b0}}, axi2ibp_cmd_burst_size}, 3'b0}
       //3'b010: Word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd2}} & {~{{ADDR_W-6{1'b0}}, axi2ibp_cmd_burst_size}, 2'b0}
       //3'b001: Half-word transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd1}} & {~{{ADDR_W-5{1'b0}}, axi2ibp_cmd_burst_size}, 1'b0}
       //3'b000: Byte transfer
      |{ADDR_W{axi2ibp_cmd_data_size == 3'd0}} & {~{{ADDR_W-4{1'b0}}, axi2ibp_cmd_burst_size}};

wire [ADDR_W-1:0] axi2ibp_cmd_addr_wrap_nxt = (axi2ibp_cmd_wrap_vec & axi2ibp_cmd_addr)
                                              | ((~axi2ibp_cmd_wrap_vec) & axi2ibp_cmd_addr_inc_nxt);

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
wire [ADDR_W-1:0] axi2ibp_sdb_addr_inc_nxt = (axi2ibp_sdb_addr_r +
       (
       //3'b110: 64 bytes transfer
       {ADDR_W{axi2ibp_sdb_data_size_r == 3'd6}} & 64
       //3'b101: 32 bytes transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd5}} & 32
       //3'b100: Quad-word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd4}} & 16
       //3'b011: Double-word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd3}} & 8
       //3'b010: Word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd2}} & 4
       //3'b001: Half-word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd1}} & 2
       //3'b000: Byte transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd0}} & 1
       )
       );

// leda B_3219 on
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on
wire [ADDR_W-1:0] axi2ibp_sdb_wrap_vec =
       //3'b110: 64 bytes transfer
       {ADDR_W{axi2ibp_sdb_data_size_r == 3'd6}} & {~{{ADDR_W-10{1'b0}}, axi2ibp_sdb_burst_size_r}, 6'b0}
       //3'b101: 32 bytes transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd5}} & {~{{ADDR_W-9{1'b0}}, axi2ibp_sdb_burst_size_r}, 5'b0}
       //3'b100: Quad-word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd4}} & {~{{ADDR_W-8{1'b0}}, axi2ibp_sdb_burst_size_r}, 4'b0}
       //3'b011: Double-word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd3}} & {~{{ADDR_W-7{1'b0}}, axi2ibp_sdb_burst_size_r}, 3'b0}
       //3'b010: Word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd2}} & {~{{ADDR_W-6{1'b0}}, axi2ibp_sdb_burst_size_r}, 2'b0}
       //3'b001: Half-word transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd1}} & {~{{ADDR_W-5{1'b0}}, axi2ibp_sdb_burst_size_r}, 1'b0}
       //3'b000: Byte transfer
      |{ADDR_W{axi2ibp_sdb_data_size_r == 3'd0}} & {~{{ADDR_W-4{1'b0}}, axi2ibp_sdb_burst_size_r}};

wire [ADDR_W-1:0] axi2ibp_sdb_addr_wrap_nxt = (axi2ibp_sdb_wrap_vec & axi2ibp_sdb_addr_r)
                                              | ((~axi2ibp_sdb_wrap_vec) & axi2ibp_sdb_addr_inc_nxt);

assign axi2ibp_sdb_addr_nxt       = ({ADDR_W{axi2ibp_splt_cnt_set}} &
                                     (
                                     axi2ibp_burst_is_incr ? axi2ibp_cmd_addr_inc_nxt :
                                     axi2ibp_burst_is_wrap ? axi2ibp_cmd_addr_wrap_nxt :
                                     axi2ibp_burst_is_fixed ? axi2ibp_cmd_addr : {ADDR_W{1'b0}}
                                     )
                                    )
                                    |
                                    ({ADDR_W{axi2ibp_splt_cnt_dec_nonlast}} &
                                     (
                                     sdb_burst_is_incr ? axi2ibp_sdb_addr_inc_nxt :
                                     sdb_burst_is_wrap ? axi2ibp_sdb_addr_wrap_nxt :
                                     sdb_burst_is_fixed ? axi2ibp_sdb_addr_r : {ADDR_W{1'b0}}
                                     )
                                    );

always @(posedge clk or posedge rst_a)
begin : axi2ibp_splt_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      axi2ibp_splt_cnt_r       <= 4'b0;
      axi2ibp_sdb_addr_r       <= {ADDR_W{1'b0}}  ;
  end
  else if (axi2ibp_splt_cnt_ena == 1'b1) begin
      axi2ibp_splt_cnt_r       <= axi2ibp_splt_cnt_nxt;
      axi2ibp_sdb_addr_r       <= axi2ibp_sdb_addr_nxt        ;
  end
end

reg  axi2ibp_sdb_valid_r;
wire axi2ibp_sdb_valid_set = axi2ibp_splt_cnt_set;
// When ibp cmd chnl handshaked and it is selecting side-buffer and the cnt is zero
wire axi2ibp_sdb_valid_clr = axi2ibp_splt_cnt_dec_last;
wire axi2ibp_sdb_valid_ena = axi2ibp_sdb_valid_set |   axi2ibp_sdb_valid_clr;
wire axi2ibp_sdb_valid_nxt = axi2ibp_sdb_valid_set | (~axi2ibp_sdb_valid_clr);

always @(posedge clk or posedge rst_a)
begin : axi2ibp_sdb_valid_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      axi2ibp_sdb_valid_r        <= 1'b0;
  end
  else if (axi2ibp_sdb_valid_ena == 1'b1) begin
      axi2ibp_sdb_valid_r        <= axi2ibp_sdb_valid_nxt;
  end
end

reg axi2ibp_sdb_read_r;
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
reg axi2ibp_sdb_excl_r;
reg axi2ibp_sdb_lock_r;
reg [1:0] axi2ibp_sdb_prot_r;
reg [3:0] axi2ibp_sdb_cache_r;
reg [RGON_W-1:0] axi2ibp_sdb_rgon_r;
reg [BUS_ID_W-1:0] axi2ibp_sdb_id_r;
// leda NTL_CON32 on

always @(posedge clk or posedge rst_a)
begin : axi2ibp_sdb_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      axi2ibp_sdb_read_r       <= 1'b0  ;
      axi2ibp_sdb_wrap_r       <= 1'b0  ;
      axi2ibp_sdb_fixed_r      <= 1'b0  ;
      axi2ibp_sdb_burst_size_r <= 4'b0  ;
      axi2ibp_sdb_data_size_r  <= 3'b0  ;
      axi2ibp_sdb_lock_r       <= 1'b0  ;
      axi2ibp_sdb_excl_r       <= 1'b0  ;
      axi2ibp_sdb_prot_r       <= 2'b0  ;
      axi2ibp_sdb_cache_r      <= 4'b0  ;
      axi2ibp_sdb_rgon_r       <= {RGON_W{1'b0}}  ;
      axi2ibp_sdb_id_r         <= {BUS_ID_W{1'b0}}  ;
  end
  else if (axi2ibp_splt_cnt_set == 1'b1) begin
      axi2ibp_sdb_read_r       <= axi2ibp_cmd_read        ;
      axi2ibp_sdb_wrap_r       <= axi2ibp_cmd_wrap;
      axi2ibp_sdb_fixed_r      <= axi2ibp_cmd_fixed;
      axi2ibp_sdb_burst_size_r <= axi2ibp_cmd_burst_size;
      axi2ibp_sdb_data_size_r  <= axi2ibp_cmd_data_size   ;
// leda NTL_CON32 off
// LMD: Change on net has no effect
// LJ: no care about this
      axi2ibp_sdb_lock_r       <= axi2ibp_cmd_lock        ;
      axi2ibp_sdb_excl_r       <= axi2ibp_cmd_excl        ;
      axi2ibp_sdb_prot_r       <= axi2ibp_cmd_prot        ;
      axi2ibp_sdb_cache_r      <= axi2ibp_cmd_cache       ;
      axi2ibp_sdb_rgon_r       <= axi2ibp_cmd_rgon        ;
      axi2ibp_sdb_id_r         <= axi2ibp_cmd_id          ;
// leda NTL_CON32 on
  end
end

//
wire wrsp_id_fifo_full ;
wire rd_id_fifo_full ;
wire wd_splt_uop_fifo_full ;
wire rd_splt_uop_fifo_full ;
wire wrsp_splt_uop_fifo_full ;

assign i_axi_awready = axi2ibp_cmd_accept & (~axi2ibp_cmd_sel_ar) & (~wrsp_id_fifo_full);
assign i_axi_arready = axi2ibp_cmd_accept & axi2ibp_cmd_sel_ar & (~rd_id_fifo_full);

assign ibp_cmd_sel_sdb = axi2ibp_sdb_valid_r;
assign ibp_cmd_sel_axi = ~ibp_cmd_sel_sdb;
assign axi2ibp_cmd_accept = i_ibp_cmd_accept & i_ibp_cmd_valid & ibp_cmd_sel_axi;

wire cmd_wait_wd_cnt_ovf;
assign i_ibp_cmd_valid = (axi2ibp_sdb_valid_r | axi2ibp_cmd_valid)
                        & (~cmd_wait_wd_cnt_ovf)
                        & (~rd_splt_uop_fifo_full)
                        & (~wd_splt_uop_fifo_full)
                        & (~wrsp_splt_uop_fifo_full);
assign ibp_cmd_splt_uop = ibp_cmd_sel_sdb ? (axi2ibp_sdb_valid_r & (~axi2ibp_splt_cnt_last)) : axi2ibp_need_splt;
assign i_ibp_cmd_read  = ibp_cmd_sel_sdb ? axi2ibp_sdb_read_r : axi2ibp_cmd_read;
wire [ADDR_W-1:0] ibp_cmd_addr_orig;
assign ibp_cmd_addr_orig  = ibp_cmd_sel_sdb ? axi2ibp_sdb_addr_r : axi2ibp_cmd_addr;
assign i_ibp_cmd_addr  = ibp_cmd_addr_orig;
assign i_ibp_cmd_wrap  = ibp_cmd_sel_sdb ? 1'b0 : (axi2ibp_cmd_wrap & (~axi2ibp_need_splt));
assign i_ibp_cmd_burst_size  = ibp_cmd_sel_sdb ? 4'b0 : (axi2ibp_need_splt ? 4'b0 : axi2ibp_cmd_burst_size);
assign i_ibp_cmd_data_size  = ibp_cmd_sel_sdb ? axi2ibp_sdb_data_size_r : axi2ibp_cmd_data_size;
assign i_ibp_cmd_lock  = ibp_cmd_sel_sdb ? axi2ibp_sdb_lock_r : axi2ibp_cmd_lock;
assign i_ibp_cmd_excl  = ibp_cmd_sel_sdb ? axi2ibp_sdb_excl_r : axi2ibp_cmd_excl;
assign i_ibp_cmd_prot  = ibp_cmd_sel_sdb ? axi2ibp_sdb_prot_r : axi2ibp_cmd_prot;
assign i_ibp_cmd_cache  = ibp_cmd_sel_sdb ? axi2ibp_sdb_cache_r : axi2ibp_cmd_cache;

assign i_ibp_cmd_rgon  = ibp_cmd_sel_sdb ? axi2ibp_sdb_rgon_r : axi2ibp_cmd_rgon;
// leda NTL_CON13A off
// LMD: non driving internal net
// LJ: No care about the unused bit
wire [BUS_ID_W-1:0] ibp_cmd_id;
assign ibp_cmd_id  = ibp_cmd_sel_sdb ? axi2ibp_sdb_id_r : axi2ibp_cmd_id;
// leda NTL_CON13A on


wire [1+1+ADDR_W+4+3+1+1+2+4+RGON_W-1:0] i_ibp_cmd_chnl_pack;
wire [1+1+ADDR_W+4+3+1+1+2+4+RGON_W-1:0] ibp_cmd_chnl_pack;
assign i_ibp_cmd_chnl_pack =
      {
      i_ibp_cmd_read,
      i_ibp_cmd_wrap,
      i_ibp_cmd_addr,
      i_ibp_cmd_burst_size,
      i_ibp_cmd_data_size,
      i_ibp_cmd_lock,
      i_ibp_cmd_excl,
      i_ibp_cmd_prot,
      i_ibp_cmd_cache,
      i_ibp_cmd_rgon
      };

assign {
      ibp_cmd_read,
      ibp_cmd_wrap,
      ibp_cmd_addr,
      ibp_cmd_burst_size,
      ibp_cmd_data_size,
      ibp_cmd_lock,
      ibp_cmd_excl,
      ibp_cmd_prot,
      ibp_cmd_cache,
      ibp_cmd_rgon
      } = ibp_cmd_chnl_pack;


alb_mss_fab_bypbuf #(
  .BUF_DEPTH(BYPBUF_DEPTH),
  .BUF_WIDTH((1+1+ADDR_W+4+3+1+1+2+4+RGON_W))
) ibp_cmd_bypbuf (
  .i_ready    (i_ibp_cmd_accept),
  .i_valid    (i_ibp_cmd_valid),
  .i_data     (i_ibp_cmd_chnl_pack),
  .o_ready    (ibp_cmd_accept),
  .o_valid    (ibp_cmd_valid),
  .o_data     (ibp_cmd_chnl_pack),

  .clk        (clk  ),
  .rst_a      (rst_a)
  );



// The wd_splt_uop_fifo is just store the 1bit "split_uop" indication, so that
// when the wdata is coming from AXI, it know it is the split uop into
// single-beat and have xx_last asserted.
wire wd_splt_uop_fifo_wen_raw  ;
wire wd_splt_uop_fifo_ren_raw  ;
wire wd_splt_uop_fifo_wen  ;
wire wd_splt_uop_fifo_ren  ;
wire wd_splt_uop_fifo_empty;
wire byp_wd_splt_uop_info_fifo = wd_splt_uop_fifo_empty & wd_splt_uop_fifo_wen_raw & wd_splt_uop_fifo_ren_raw;

wire wd_splt_uop_fifo_wdat ;
wire wd_splt_uop_fifo_rdat ;
// Write when IBP cmd (write) is handshaked
assign wd_splt_uop_fifo_wen_raw  = i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read);
assign wd_splt_uop_fifo_wen  = wd_splt_uop_fifo_wen_raw & (~byp_wd_splt_uop_info_fifo);
assign wd_splt_uop_fifo_wdat = ibp_cmd_splt_uop;
// Read when IBP wd channel is handshaked (last)
assign wd_splt_uop_fifo_ren_raw  = ibp_wr_valid & ibp_wr_accept & ibp_wr_last;
assign wd_splt_uop_fifo_ren  = wd_splt_uop_fifo_ren_raw & (~byp_wd_splt_uop_info_fifo);

assign wd_is_splt_uop = wd_splt_uop_fifo_rdat & (~wd_splt_uop_fifo_empty) | (wd_splt_uop_fifo_wdat & wd_splt_uop_fifo_empty);

wire wd_splt_uop_fifo_i_valid;
wire wd_splt_uop_fifo_o_valid;
wire wd_splt_uop_fifo_i_ready;
wire wd_splt_uop_fifo_o_ready;
assign wd_splt_uop_fifo_i_valid = wd_splt_uop_fifo_wen;
assign wd_splt_uop_fifo_full = (~wd_splt_uop_fifo_i_ready);
assign wd_splt_uop_fifo_o_ready = wd_splt_uop_fifo_ren;
assign wd_splt_uop_fifo_empty = (~wd_splt_uop_fifo_o_valid);

alb_mss_fab_fifo # (
     .FIFO_DEPTH(SPLT_FIFO_DEPTH),
     .FIFO_WIDTH(1),
     .IN_OUT_MWHILE (0),
     .O_SUPPORT_RTIO(0),
     .I_SUPPORT_RTIO(0)
) wd_splt_uop_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (wd_splt_uop_fifo_i_valid),
  .i_ready   (wd_splt_uop_fifo_i_ready),
  .i_data    (wd_splt_uop_fifo_wdat),
  .o_valid   (wd_splt_uop_fifo_o_valid),
  .o_ready   (wd_splt_uop_fifo_o_ready),
  .o_data    (wd_splt_uop_fifo_rdat),

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




// The rd_splt_uop_fifo is just store the 1bit "split_uop" indication, so that
// when the rdata is coming from IBP, it know it is the split uop and
// have xx_last de-asserted.
wire rd_splt_uop_fifo_wen  ;
wire rd_splt_uop_fifo_ren  ;
wire rd_splt_uop_fifo_wdat ;
wire rd_splt_uop_fifo_rdat ;
wire rd_splt_uop_fifo_empty;
wire ibp_rdata_valid;
// Write when IBP cmd (read) is handshaked
assign rd_splt_uop_fifo_wen  = i_ibp_cmd_valid & i_ibp_cmd_accept & i_ibp_cmd_read;
assign rd_splt_uop_fifo_wdat = ibp_cmd_splt_uop;
// Read when IBP rd channel is handshaked (last)
assign rd_splt_uop_fifo_ren  = ibp_rdata_valid & ibp_rd_accept & ibp_rd_last;

assign rd_is_splt_uop = rd_splt_uop_fifo_rdat & (~rd_splt_uop_fifo_empty);


wire rd_splt_uop_fifo_i_valid;
wire rd_splt_uop_fifo_o_valid;
wire rd_splt_uop_fifo_i_ready;
wire rd_splt_uop_fifo_o_ready;
assign rd_splt_uop_fifo_i_valid = rd_splt_uop_fifo_wen;
assign rd_splt_uop_fifo_full = (~rd_splt_uop_fifo_i_ready);
assign rd_splt_uop_fifo_o_ready = rd_splt_uop_fifo_ren;
assign rd_splt_uop_fifo_empty = (~rd_splt_uop_fifo_o_valid);

alb_mss_fab_fifo # (
     .FIFO_DEPTH(SPLT_FIFO_DEPTH),
     .FIFO_WIDTH(1),
     .IN_OUT_MWHILE (0),
     .O_SUPPORT_RTIO(0),
     .I_SUPPORT_RTIO(0)
) rd_splt_uop_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (rd_splt_uop_fifo_i_valid),
  .i_ready   (rd_splt_uop_fifo_i_ready),
  .i_data    (rd_splt_uop_fifo_wdat),
  .o_valid   (rd_splt_uop_fifo_o_valid),
  .o_ready   (rd_splt_uop_fifo_o_ready),
  .o_data    (rd_splt_uop_fifo_rdat),
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

// The wrsp_splt_uop_fifo is just store the 1bit "split_uop" indication, so that
// when the wrsp is coming from IBP, it know it is the split uop and
// have wrsp_valid de-asserted.
wire wrsp_splt_uop_fifo_wen  ;
wire wrsp_splt_uop_fifo_ren  ;
wire wrsp_splt_uop_fifo_wdat ;
wire wrsp_splt_uop_fifo_rdat ;
wire wrsp_splt_uop_fifo_empty;
wire ibp_wr_resp_valid;

// Write when IBP cmd (write) is handshaked
assign wrsp_splt_uop_fifo_wen  = i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read);
assign wrsp_splt_uop_fifo_wdat = ibp_cmd_splt_uop;
// Read when IBP wrsp channel is handshaked (last)
assign wrsp_splt_uop_fifo_ren  = ibp_wr_resp_valid & ibp_wr_resp_accept;

assign wrsp_is_splt_uop = wrsp_splt_uop_fifo_rdat & (~wrsp_splt_uop_fifo_empty);

wire wrsp_splt_uop_fifo_i_valid;
wire wrsp_splt_uop_fifo_o_valid;
wire wrsp_splt_uop_fifo_i_ready;
wire wrsp_splt_uop_fifo_o_ready;
assign wrsp_splt_uop_fifo_i_valid = wrsp_splt_uop_fifo_wen;
assign wrsp_splt_uop_fifo_full = (~wrsp_splt_uop_fifo_i_ready);
assign wrsp_splt_uop_fifo_o_ready = wrsp_splt_uop_fifo_ren;
assign wrsp_splt_uop_fifo_empty = (~wrsp_splt_uop_fifo_o_valid);

alb_mss_fab_fifo # (
     .FIFO_DEPTH(SPLT_FIFO_DEPTH),
     .FIFO_WIDTH(1),
     .IN_OUT_MWHILE (0),
     .O_SUPPORT_RTIO(0),
     .I_SUPPORT_RTIO(0)
) wrsp_splt_uop_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (wrsp_splt_uop_fifo_i_valid),
  .i_ready   (wrsp_splt_uop_fifo_i_ready),
  .i_data    (wrsp_splt_uop_fifo_wdat),
  .o_valid   (wrsp_splt_uop_fifo_o_valid),
  .o_ready   (wrsp_splt_uop_fifo_o_ready),
  .o_data    (wrsp_splt_uop_fifo_rdat),
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


// The rd_id_fifo is just store the "rd_id" indication, so that
// when the rdata is coming from IBP, it know its ID
wire rd_id_fifo_wen  ;
wire rd_id_fifo_ren  ;
wire [BUS_ID_W-1:0] rd_id_fifo_wdat ;
wire [BUS_ID_W-1:0] rd_id_fifo_rdat ;
wire rd_id_fifo_empty;
// Write when AXI ar channel is handshaked
assign rd_id_fifo_wen  = i_axi_arvalid & i_axi_arready;
assign rd_id_fifo_wdat = i_axi_arid;
// Read when AXI rd channel is handshaked (last)
assign rd_id_fifo_ren  = i_axi_rvalid & i_axi_rready & i_axi_rlast;


wire rd_id_fifo_i_valid;
wire rd_id_fifo_o_valid;
wire rd_id_fifo_i_ready;
wire rd_id_fifo_o_ready;
assign rd_id_fifo_i_valid = rd_id_fifo_wen;
assign rd_id_fifo_full  = (~rd_id_fifo_i_ready);
assign rd_id_fifo_o_ready = rd_id_fifo_ren;
assign rd_id_fifo_empty = (~rd_id_fifo_o_valid);

alb_mss_fab_fifo # (
     .FIFO_DEPTH(SPLT_FIFO_DEPTH),
     .FIFO_WIDTH(BUS_ID_W),
     .IN_OUT_MWHILE (0),
     .O_SUPPORT_RTIO(0),
     .I_SUPPORT_RTIO(0)
) rd_id_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (rd_id_fifo_i_valid),
  .i_ready   (rd_id_fifo_i_ready),
  .i_data    (rd_id_fifo_wdat),
  .o_valid   (rd_id_fifo_o_valid),
  .o_ready   (rd_id_fifo_o_ready),
  .o_data    (rd_id_fifo_rdat),
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


// The wrsp_id_fifo is just store the "wrsp_id" indication, so that
// when the wrsp is coming from IBP, it know its ID
wire wrsp_id_fifo_wen  ;
wire wrsp_id_fifo_ren  ;
wire [BUS_ID_W-1:0] wrsp_id_fifo_wdat ;
wire [BUS_ID_W-1:0] wrsp_id_fifo_rdat ;
wire wrsp_id_fifo_empty;
// Write when AXI aw channel is handshaked
assign wrsp_id_fifo_wen  = i_axi_awvalid & i_axi_awready;
assign wrsp_id_fifo_wdat = i_axi_awid;
// Read when AXI brsp channel is handshaked (last)
assign wrsp_id_fifo_ren  = i_axi_bvalid & i_axi_bready;


wire wrsp_id_fifo_i_valid;
wire wrsp_id_fifo_o_valid;
wire wrsp_id_fifo_i_ready;
wire wrsp_id_fifo_o_ready;
assign wrsp_id_fifo_i_valid = wrsp_id_fifo_wen;
assign wrsp_id_fifo_full  = (~wrsp_id_fifo_i_ready);
assign wrsp_id_fifo_o_ready = wrsp_id_fifo_ren;
assign wrsp_id_fifo_empty = (~wrsp_id_fifo_o_valid);

alb_mss_fab_fifo # (
     .FIFO_DEPTH(SPLT_FIFO_DEPTH),
     .FIFO_WIDTH(BUS_ID_W),
     .IN_OUT_MWHILE (0),
     .O_SUPPORT_RTIO(0),
     .I_SUPPORT_RTIO(0)
) wrsp_id_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (wrsp_id_fifo_i_valid),
  .i_ready   (wrsp_id_fifo_i_ready),
  .i_data    (wrsp_id_fifo_wdat),
  .o_valid   (wrsp_id_fifo_o_valid),
  .o_ready   (wrsp_id_fifo_o_ready),
  .o_data    (wrsp_id_fifo_rdat),
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



// Convert for Write data channel
    // Just direct assigned from IBP wdata channel to AXI
wire ibp_cmd_wait_wd;
assign ibp_wr_valid = i_axi_wvalid & ibp_cmd_wait_wd;
assign ibp_wr_data = i_axi_wdata;
assign ibp_wr_mask = i_axi_wstrb;
assign ibp_wr_last = i_axi_wlast | wd_is_splt_uop;
assign i_axi_wready = ibp_wr_accept & ibp_wr_valid;
//
// Convert for Read data channel
    // Just direct assigned from AXI rdata channel to IBP
assign ibp_rdata_valid = (ibp_rd_valid | ibp_err_rd);
assign i_axi_rdata = ibp_rd_data;
// leda NTL_CON16 off
// LMD: Nets or cell pins should not be tied to logic 0 / logic 1
// LJ: No care about the constant here
assign i_axi_rresp = ibp_err_rd ? 2'b10 : ibp_rd_excl_ok ? 2'b01 : 2'b00;//SLVERR or OKAY
// leda NTL_CON16 on
assign i_axi_rlast = ibp_rd_last & (~rd_is_splt_uop);
assign i_axi_rid = rd_id_fifo_rdat;
assign i_axi_rvalid = ibp_rdata_valid & (~rd_id_fifo_empty);
assign ibp_rd_accept = i_axi_rready & (~rd_splt_uop_fifo_empty);

//
// Convert for Write response channel
    // Just direct assigned from AXI wresp channel to IBP
assign ibp_wr_resp_valid = ibp_err_wr | ibp_wr_done | ibp_wr_excl_done;
assign i_axi_bid = wrsp_id_fifo_rdat;
wire i_axi_bvalid_splt_uop = ibp_wr_resp_valid & wrsp_is_splt_uop
                       & (~wrsp_id_fifo_empty);
assign i_axi_bvalid = ibp_wr_resp_valid & (~wrsp_is_splt_uop)
                       & (~wrsp_id_fifo_empty);

reg ibp_err_wr_r;
wire ibp_err_wr_nxt;
wire ibp_err_wr_ena;
wire ibp_err_wr_set = i_axi_bvalid_splt_uop;
wire ibp_err_wr_clr = i_axi_bvalid & i_axi_bready;
assign ibp_err_wr_nxt = ibp_err_wr_set ? (ibp_err_wr_r | ibp_err_wr) : ibp_err_wr_clr ? 1'b0 : ibp_err_wr_r;
assign ibp_err_wr_ena = ibp_err_wr_set | ibp_err_wr_clr;

always @(posedge clk or posedge rst_a)
begin : ibp_err_wr_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      ibp_err_wr_r        <= 1'b0;
  end
  else if (ibp_err_wr_ena == 1'b1) begin
      ibp_err_wr_r        <= ibp_err_wr_nxt;
  end
end

assign i_axi_bresp = (ibp_err_wr | ibp_err_wr_r) ? 2'b10 //SLVERR,we need to make sure all the response accumulated
                         : ibp_wr_excl_done ? 2'b01 //or EXOKAY
                         : 2'b00;//OKAY
assign ibp_wr_resp_accept = ((i_axi_bvalid & i_axi_bready) | i_axi_bvalid_splt_uop) & (~wrsp_splt_uop_fifo_empty);
// Count how much of the cmd is waiting write burst data

wire cmd_wait_wd_cnt_udf;
reg [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_r;
assign cmd_wait_wd_cnt_ovf = (cmd_wait_wd_cnt_r == $unsigned(OUT_CMD_NUM));
assign cmd_wait_wd_cnt_udf = (cmd_wait_wd_cnt_r == {OUT_CMD_CNT_W+1{1'b0}});
// The ibp wr burst counter increased when a IBP write command accepted to the IBP end
wire cmd_wait_wd_cnt_inc = i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read);
// The ibp wr burst counter decreased when a last beat of IBP write burst accepted to IBP end
wire cmd_wait_wd_cnt_dec = ibp_wr_valid & ibp_wr_accept & ibp_wr_last;
wire cmd_wait_wd_cnt_ena = cmd_wait_wd_cnt_inc | cmd_wait_wd_cnt_dec;
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
wire [OUT_CMD_CNT_W:0] cmd_wait_wd_cnt_nxt =
      ( cmd_wait_wd_cnt_inc & (~cmd_wait_wd_cnt_dec)) ? (cmd_wait_wd_cnt_r + 1'b1)
    : (~cmd_wait_wd_cnt_inc &  cmd_wait_wd_cnt_dec) ? (cmd_wait_wd_cnt_r - 1'b1)
    : cmd_wait_wd_cnt_r ;
// leda B_3200 on
// leda W484 on
// leda BTTF_D002 on
// leda B_3219 on

always @(posedge clk or posedge rst_a)
begin : cmd_wait_wd_cnt_DFFEAR_PROC
  if (rst_a == 1'b1) begin
      cmd_wait_wd_cnt_r        <= {OUT_CMD_CNT_W+1{1'b0}};
  end
  else if (cmd_wait_wd_cnt_ena == 1'b1) begin
      cmd_wait_wd_cnt_r        <= cmd_wait_wd_cnt_nxt;
  end
end


assign ibp_cmd_wait_wd = (i_ibp_cmd_valid & (~i_ibp_cmd_read) & i_ibp_cmd_accept) | (~cmd_wait_wd_cnt_udf);





endmodule // alb_mss_fab_axi2ibp

