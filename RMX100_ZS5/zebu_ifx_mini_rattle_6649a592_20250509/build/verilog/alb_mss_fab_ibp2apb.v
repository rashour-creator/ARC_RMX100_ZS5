// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
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
//   alb_mss_fab_ibp2apb: IBP to APB bridge
//
// ===========================================================================
//
// Description:
//  Verilog module defining a BUS to APB bridge
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_mss_fab_ibp2apb.vpp
//
// ===========================================================================
`timescale 1ns/10ps
module alb_mss_fab_ibp2apb
   #(parameter a_w = 32,    // Address-width
     parameter d_w = 32,    // Data-width: 32/64
     parameter rg_w = 2,     // region width
     parameter l_w = 1)      // Number of select outputs
    (input  wire                clk,
     input  wire                clk_en,
     input  wire                rst_a,
     input  wire                ibp_cmd_valid,
     output wire                ibp_cmd_accept,
     input  wire                ibp_cmd_read,
     input  wire  [a_w-1:0]     ibp_cmd_addr,
     input  wire                ibp_cmd_wrap,
     input  wire  [2:0]         ibp_cmd_data_size,
     input  wire  [3:0]         ibp_cmd_burst_size,
     input  wire  [1:0]         ibp_cmd_prot,
     input  wire  [3:0]         ibp_cmd_cache,
     input  wire                ibp_cmd_lock,
     input  wire                ibp_cmd_excl,
     input  wire  [rg_w-1:0]    ibp_cmd_region,

     output wire                ibp_rd_valid,
     input  wire                ibp_rd_accept,
     output wire  [d_w-1:0]     ibp_rd_data,
     output wire                ibp_err_rd,
     output wire                ibp_rd_last,
     output wire                ibp_rd_excl_ok,

     input  wire                ibp_wr_valid,
     output wire                ibp_wr_accept,
     input  wire  [d_w-1:0]     ibp_wr_data,
     input  wire  [(d_w/8)-1:0] ibp_wr_mask,
     input  wire                ibp_wr_last,

     output wire                ibp_wr_done,
     input  wire                ibp_wr_resp_accept,
     output wire                ibp_wr_excl_done,
     output wire                ibp_err_wr,

     output reg  [l_w-1:0]      apb_sel,
     output wire                apb_enable,
     output wire                apb_write,
     output wire [a_w-1:2]      apb_addr,
     output wire [31:0]         apb_wdata,
     output wire [3:0]          apb_wstrb,
     input  wire [31:0]         apb_rdata,
     input  wire                apb_slverr,
     input  wire                apb_ready);


     wire                o_ibp_cmd_valid;
     reg                 o_ibp_cmd_accept /*verilator isolate_assignments*/;
     wire                o_ibp_cmd_read;
     wire  [a_w-1:0]     o_ibp_cmd_addr;
     wire                o_ibp_cmd_wrap;
     wire  [2:0]         o_ibp_cmd_data_size;
     wire  [3:0]         o_ibp_cmd_burst_size;
     wire  [1:0]         o_ibp_cmd_prot;
     wire  [3:0]         o_ibp_cmd_cache;
     wire                o_ibp_cmd_lock;
     wire                o_ibp_cmd_excl;

     wire [rg_w-1:0]     o_ibp_cmd_region;

     reg                 o_ibp_rd_valid /*verilator isolate_assignments*/;
     wire                o_ibp_rd_accept;
     wire [d_w-1:0]      o_ibp_rd_data;
     reg                 o_ibp_err_rd /*verilator isolate_assignments*/;
     wire                o_ibp_rd_last;

     wire                o_ibp_wr_valid;
     reg                 o_ibp_wr_accept /*verilator isolate_assignments*/;
     wire  [d_w-1:0]     o_ibp_wr_data;
     wire  [(d_w/8)-1:0] o_ibp_wr_mask;
     wire                o_ibp_wr_last;

     reg                 o_ibp_wr_done /*verilator isolate_assignments*/;
     wire                o_ibp_wr_resp_accept;
     reg                 o_ibp_err_wr /*verilator isolate_assignments*/;


    // burst-2-single beat logic
alb_mss_fab_ibp2single #(
.ADDR_W(a_w),
.DATA_W(d_w),
.USER_W(1),
.RGON_W(rg_w)
) u_ibp2single(
  .clk(clk),
  .rst_a(rst_a),

  .i_ibp_cmd_valid(ibp_cmd_valid),
  .i_ibp_cmd_accept(ibp_cmd_accept),
  .i_ibp_cmd_read(ibp_cmd_read),
  .i_ibp_cmd_addr(ibp_cmd_addr),
  .i_ibp_cmd_wrap(ibp_cmd_wrap),
  .i_ibp_cmd_data_size(ibp_cmd_data_size),
  .i_ibp_cmd_burst_size(ibp_cmd_burst_size),
  .i_ibp_cmd_lock(ibp_cmd_lock),
  .i_ibp_cmd_prot(ibp_cmd_prot),
  .i_ibp_cmd_cache(ibp_cmd_cache),
  .i_ibp_cmd_excl(ibp_cmd_excl),
  .i_ibp_cmd_user(1'b0),

  .i_ibp_rd_valid(ibp_rd_valid),
  .i_ibp_rd_accept(ibp_rd_accept),
  .i_ibp_rd_data(ibp_rd_data),
  .i_ibp_rd_last(ibp_rd_last),
  .i_ibp_err_rd(ibp_err_rd),
  .i_ibp_rd_excl_ok(ibp_rd_excl_ok),

  .i_ibp_wr_valid(ibp_wr_valid),
  .i_ibp_wr_accept(ibp_wr_accept),
  .i_ibp_wr_data(ibp_wr_data),
  .i_ibp_wr_mask(ibp_wr_mask),
  .i_ibp_wr_last(ibp_wr_last),

  .i_ibp_wr_done(ibp_wr_done),
  .i_ibp_err_wr(ibp_err_wr),
  .i_ibp_wr_excl_done(ibp_wr_excl_done),
  .i_ibp_wr_resp_accept(ibp_wr_resp_accept),

  .i_ibp_cmd_rgon(ibp_cmd_region),

  .o_ibp_cmd_valid(o_ibp_cmd_valid),
  .o_ibp_cmd_accept(o_ibp_cmd_accept),
  .o_ibp_cmd_read(o_ibp_cmd_read),
  .o_ibp_cmd_addr(o_ibp_cmd_addr),
  .o_ibp_cmd_wrap(o_ibp_cmd_wrap),
  .o_ibp_cmd_data_size(o_ibp_cmd_data_size),
  .o_ibp_cmd_burst_size(o_ibp_cmd_burst_size),
  .o_ibp_cmd_lock(o_ibp_cmd_lock),
  .o_ibp_cmd_excl(o_ibp_cmd_excl),
  .o_ibp_cmd_prot(o_ibp_cmd_prot),
  .o_ibp_cmd_cache(o_ibp_cmd_cache),
  .o_ibp_cmd_user(),

  .o_ibp_cmd_burst_en(),
  .o_ibp_cmd_burst_type(),
  .o_ibp_cmd_burst_last(),

  .o_ibp_cmd_rgon(o_ibp_cmd_region),

  .o_ibp_rd_valid(o_ibp_rd_valid),
  .o_ibp_rd_accept(o_ibp_rd_accept),
  .o_ibp_rd_data(o_ibp_rd_data),
  .o_ibp_err_rd(o_ibp_err_rd),
  .o_ibp_rd_last(o_ibp_rd_last),
  .o_ibp_rd_excl_ok(1'b0),

  .o_ibp_wr_valid(o_ibp_wr_valid),
  .o_ibp_wr_accept(o_ibp_wr_accept),
  .o_ibp_wr_data(o_ibp_wr_data),
  .o_ibp_wr_mask(o_ibp_wr_mask),
  .o_ibp_wr_last(o_ibp_wr_last),

  .o_ibp_wr_done(o_ibp_wr_done),
  .o_ibp_err_wr(o_ibp_err_wr),
  .o_ibp_wr_resp_accept(o_ibp_wr_resp_accept),
  .o_ibp_wr_excl_done(1'b0)

);
    // localparams
    localparam st_idle   = 4'b0000;
    localparam st_wd     = 4'b0100;
    localparam st_sel    = 4'b0001;
    localparam st_en     = 4'b0010;
    localparam st_rsp    = 4'b0011;
    localparam st_err_c  = 4'b1000;
    localparam st_err_w  = 4'b1001;
    localparam st_err_b  = 4'b1010;
    localparam st_err_r  = 4'b1011;

    // local wires
    reg [3:0]     i_st_r;
    reg [3:0]     i_st_d;
    reg [3:0]     i_cnt_r;
    reg [3:0]     i_cnt_d;
    reg           i_rd_r;
    reg           i_resp_r;
    reg [31:0]    i_wdata_r;
    reg [3:0]     i_wstrb_r;
    reg [31:0]    i_rdata_r;
    reg [a_w-1:2] i_addr_r;
    wire          i_ready;
    wire          i_apb_sel_enabled;


    // assignments
    assign o_ibp_rd_last  = (i_cnt_r == 4'd0);
    assign i_ready    = ((|apb_sel) & apb_ready);
    assign apb_enable = (i_st_r == st_en);
    assign apb_write  = !i_rd_r;
    assign apb_addr   = i_addr_r;
    assign apb_wdata  = i_wdata_r;
    assign apb_wstrb  = i_wstrb_r;
    assign o_ibp_rd_data  = (d_w == 64)? {2{i_rdata_r}} : i_rdata_r;

    assign i_apb_sel_enabled = (i_st_r == st_en) || (i_st_r == st_sel);
    // select decoding
    // outputs: apb_sel
    always @*
      begin : sel_PROC
          integer i;
          apb_sel = {l_w{1'b0}};
          for (i = 0; i < l_w; i = i + 1)
            apb_sel[i] = (o_ibp_cmd_region == i) && i_apb_sel_enabled;
      end // selPROC

    // next state
    // outputs: i_st_d, i_cnt_d, bus_aready, bus_wready, bus_rvalid, bus_bvalid, bus_rresp, bus_bresp
    always @*
      begin : st_nxt_PROC
          // default outputs
          i_st_d     = i_st_r;
          i_cnt_d    = i_cnt_r;
          o_ibp_cmd_accept = 1'b0;
          o_ibp_wr_accept = 1'b0;
          o_ibp_rd_valid = 1'b0;
          o_ibp_err_rd = 1'b0;
          o_ibp_wr_done = 1'b0;
          o_ibp_err_wr = 1'b0;
          // FSM
          case (i_st_r)
            st_rsp: begin
                if (clk_en) begin
                    if (i_rd_r) begin
                        o_ibp_err_rd   = i_resp_r;
                        if (i_resp_r == 1'b1) begin
                            o_ibp_rd_valid = 1'b0;
                        end
                        else begin
                            o_ibp_rd_valid = 1'b1;
                        end
                        if (o_ibp_rd_accept)
                          i_st_d = st_idle;
                    end
                    else begin
                        o_ibp_err_wr  = i_resp_r;
                        if (i_resp_r == 1'b1) begin
                            o_ibp_wr_done = 1'b0;
                        end
                        else begin
                           o_ibp_wr_done = 1'b1;
                        end
                        if (o_ibp_wr_resp_accept)
                          i_st_d = st_idle;
                    end
                end
            end
            st_en: begin
                if (i_ready)
                  i_st_d = st_rsp;
            end
            st_sel: begin
                i_st_d = st_en;
            end
            st_wd: begin
                if (clk_en) begin
                  o_ibp_wr_accept = 1'b1;
                end
                if (o_ibp_wr_valid)
                  i_st_d = st_sel;
            end
            st_err_r: begin
                if (clk_en) begin
                  o_ibp_rd_valid = 1'b0;
                  o_ibp_err_rd = 1'b1;
                end
                if (o_ibp_rd_accept) begin
                    i_cnt_d = i_cnt_d - 1;
                    if (o_ibp_rd_last)
                      i_st_d = st_idle;
                end
            end
            st_err_b: begin
                if (clk_en) begin
                  o_ibp_wr_done = 1'b0;
                  o_ibp_err_wr = 1'b1;
                end
                if (o_ibp_wr_resp_accept)
                  i_st_d = st_idle;
            end
            st_err_w: begin
                if (clk_en) begin
                  o_ibp_wr_accept = 1'b1;
                end
                if (o_ibp_wr_valid && o_ibp_wr_last)
                  i_st_d = st_err_b;
            end
            default: begin //st_idle
                if (clk_en) begin
                  o_ibp_cmd_accept = 1'b1;
                  i_cnt_d = o_ibp_cmd_burst_size;
                end
                if (o_ibp_cmd_valid) begin
                    //if ((bus_alen != 0) || ((bus_asize == 3'b011) || (bus_asize == 3'b100))) begin
                    if (o_ibp_cmd_burst_size != 0) begin
                        // error
                        if (o_ibp_cmd_read)
                          i_st_d = st_err_r;
                        else
                          i_st_d = st_err_w;
                    end
                    else if (o_ibp_cmd_read)
                      i_st_d = st_sel;
                    else
                      i_st_d = st_wd;
                end
            end
          endcase // case (i_st_r)
      end // st_nxt_PROC

    // state
    // outputs: i_st_r, i_cnt_r, i_rd_r, i_resp_r, i_rdata_r, i_addr_r
    always @(posedge clk or
             posedge rst_a)
      begin : st_PROC
          if (rst_a) begin
              i_st_r    <= st_idle;
              i_cnt_r   <= 4'd0;
              i_rd_r    <= 1'b0;
              i_resp_r  <= 1'b0;
              i_rdata_r <= 32'd0;
              i_addr_r  <= {(a_w-2){1'b0}};
              i_wdata_r <= {d_w{1'b0}};
              i_wstrb_r <= {(d_w/8){1'b0}};
          end
          else if (clk_en) begin
              if (o_ibp_cmd_valid && o_ibp_cmd_accept) begin
                  i_rd_r   <= o_ibp_cmd_read;
                  i_addr_r <= o_ibp_cmd_addr[a_w-1:2];
              end
              if (o_ibp_wr_valid && o_ibp_wr_accept) begin
                  if (d_w == 64) begin
                      i_wdata_r <= i_addr_r[2] ? o_ibp_wr_data >> 32 : o_ibp_wr_data;
                      i_wstrb_r <= i_addr_r[2] ? o_ibp_wr_mask >> 4  : o_ibp_wr_mask;
                  end
                  else begin
                      i_wdata_r <= o_ibp_wr_data;
                      i_wstrb_r <= o_ibp_wr_mask;
                  end
              end
              if (o_ibp_rd_valid && o_ibp_rd_accept) begin
                 i_wdata_r <= {d_w{1'b0}};
                 i_wstrb_r <= {(d_w/8){1'b0}};
              end
              i_st_r   <= i_st_d;
              i_cnt_r  <= i_cnt_d;
              if ((i_st_r == st_en) && i_ready) begin
                  i_resp_r  <= apb_slverr;
                  i_rdata_r <= apb_rdata;
              end
          end
      end // st_PROC

endmodule // alb_mss_fab_ibp2apb

