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
//   alb_mss_fab_bus_lat: latency unit
//
// ===========================================================================
//
// Description:
//  Verilog module defining a Bus latency unit
//  Delaying read data and write responses by a number of cycles
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_fab_mss_bus_lat.vpp
//
// ===========================================================================
`timescale 1ns/10ps
module alb_mss_fab_bus_lat
   #(parameter a_w   = 32,    // Address-width: 32b or 40b
     parameter d_w   = 32,    // Data-width: 32/64
     parameter depl2 = 5)     // log2 of buffer size (0..8)
    (input  wire                clk,
     input  wire                clk_en,
     input  wire                rst_b,
     input  wire                busp_avalid,
     output wire                busp_aready,
     input  wire                busp_aread,
     input  wire  [a_w-1:0]     busp_aaddr,
     input  wire  [1:0]         busp_alock,
     input  wire                busp_aburst,
     input  wire  [7:0]         busp_alen,
     input  wire  [2:0]         busp_asize,
     output wire                busp_rvalid,
     input  wire                busp_rready,
     output wire  [d_w-1:0]     busp_rdata,
     output wire  [1:0]         busp_rresp,
     output wire                busp_rlast,
     input  wire                busp_wvalid,
     output wire                busp_wready,
     input  wire  [d_w-1:0]     busp_wdata,
     input  wire  [(d_w/8)-1:0] busp_wstrb,
     input  wire                busp_wlast,
     output wire                busp_bvalid,
     input  wire                busp_bready,
     output wire  [1:0]         busp_bresp,
     output wire                buss_avalid,
     input  wire                buss_aready,
     output wire                buss_aread,
     output wire  [a_w-1:0]     buss_aaddr,
     output wire  [1:0]         buss_alock,
     output wire                buss_aburst,
     output wire  [7:0]         buss_alen,
     output wire  [2:0]         buss_asize,
     input  wire                buss_rvalid,
     output wire                buss_rready,
     input  wire  [d_w-1:0]     buss_rdata,
     input  wire  [1:0]         buss_rresp,
     input  wire                buss_rlast,
     output wire                buss_wvalid,
     input  wire                buss_wready,
     output wire  [d_w-1:0]     buss_wdata,
     output wire  [(d_w/8)-1:0] buss_wstrb,
     output wire                buss_wlast,
     input  wire                buss_bvalid,
     output wire                buss_bready,
     input  wire  [1:0]         buss_bresp,
     input  wire  [11:0]        cfg_lat_w,
     input  wire  [11:0]        cfg_lat_r,
     input  wire  [9:0]         cfg_wr_bw,
     input  wire  [9:0]         cfg_rd_bw,
     output wire                perf_awf,
     output wire                perf_arf,
     output wire                perf_aw,
     output wire                perf_ar,
     output wire                perf_w,
     output wire                perf_wl,
     output wire                perf_r,
     output wire                perf_rl,
     output wire                perf_b);
    // local parameters
    localparam rw  = d_w+3;
    localparam bw  = 2;
    localparam dl2 = depl2 >= 2 ? depl2 : 1;
    localparam dep = 1<<dl2;
    // Delay lines
    wire [d_w-1:0] i_busp_rdata;
    wire [1:0]     i_busp_rresp;
    wire [1:0]     i_busp_bresp;
    wire           i_busp_rlast;

    reg [rw-1:0]       i_rdel_mem[0:dep-1] /* synthesis syn_ramstyle = "block_ram" */;
    reg [dep-1:0]      i_rdel_valid_r;
    reg [dl2-1:0]      i_rcnt_r;
    reg [dl2-1:0]      i_rram_addr_r;
    reg [dl2-1:0]      i_rrptr_r;
    reg [dl2-1:0]      i_rwptr_r;
    reg [11:0]         i_rcfg_lat_r;
    reg [bw-1:0]       i_bdel_mem[0:dep-1] /* synthesis syn_ramstyle = "block_ram" */;
    reg [dep-1:0]      i_bdel_valid_r;
    reg [dl2-1:0]      i_bcnt_r;
    reg [dl2-1:0]      i_bram_addr_r;
    reg [dl2-1:0]      i_brptr_r;
    reg [dl2-1:0]      i_bwptr_r;
    reg [11:0]         i_bcfg_lat_r;
    reg                i_first_r;
    reg [dep-1:0]      i_rdel_valid_d;
    reg [dl2-1:0]      i_rcnt_d;
    reg [dl2-1:0]      i_rram_addr_d;
    reg [dl2-1:0]      i_rrptr_d;
    reg [dl2-1:0]      i_rwptr_d;
    reg                i_rbuf_wr;
    reg [11:0]         i_rcfg_lat_d;
    reg [dep-1:0]      i_bdel_valid_d;
    reg [dl2-1:0]      i_bcnt_d;
    reg [dl2-1:0]      i_bram_addr_d;
    reg [dl2-1:0]      i_brptr_d;
    reg [dl2-1:0]      i_bwptr_d;
    reg [11:0]         i_bcfg_lat_d;
    reg                i_bbuf_wr;
    wire [11:0]        i_cfg_lat_w;
    wire [11:0]        i_cfg_lat_r;

    reg [9:0]         buss_bw_rd_cnt;
    //reg                buss_bw_rd_pls;
    reg [9:0]         buss_bw_wr_cnt;
    //reg                buss_bw_wr_pls;

    // profiling outputs
    assign perf_awf = clk_en && busp_avalid && i_first_r && !busp_aread;
    assign perf_arf = clk_en && busp_avalid && i_first_r && busp_aread;
    assign perf_aw  = clk_en && busp_avalid && busp_aready && !busp_aread;
    assign perf_ar  = clk_en && busp_avalid && busp_aready && busp_aread;
    assign perf_w   = clk_en && busp_wvalid && busp_wready;
    assign perf_wl  = clk_en && busp_wvalid && busp_wready && busp_wlast;
    assign perf_r   = clk_en && busp_rvalid && busp_rready;
    assign perf_rl  = clk_en && busp_rvalid && busp_rready && busp_rlast;
    assign perf_b   = clk_en && busp_bvalid && busp_bready;

    // Commands directly forwarded
    assign buss_avalid = busp_avalid;
    assign busp_aready = buss_aready;
    assign buss_aread  = busp_aread;
    assign buss_aaddr  = busp_aaddr;
    assign buss_alock  = busp_alock;
    assign buss_aburst = busp_aburst;
    assign buss_alen   = busp_alen;
    assign buss_asize  = busp_asize;

    // Write data directly forwarded
    assign buss_wvalid = busp_wvalid & (buss_bw_wr_cnt[9:0] == cfg_wr_bw[9:0]);//buss_bw_wr_pls;
    assign busp_wready = buss_wready & (buss_bw_wr_cnt[9:0] == cfg_wr_bw[9:0]);//buss_bw_wr_pls;
    assign buss_wdata  = busp_wdata;
    assign buss_wstrb  = busp_wstrb;
    assign buss_wlast  = busp_wlast;



assign busp_rdata = (|i_busp_rdata === 1'bx) ? {d_w{1'b0}} : i_busp_rdata;
assign busp_rresp = (|i_busp_rresp === 1'bx) ? 2'd0 : i_busp_rresp;
assign busp_rlast = (i_busp_rlast === 1'bx) ? 1'd0 : i_busp_rlast;
assign busp_bresp = (|i_busp_bresp === 1'bx) ? 2'd0 : i_busp_bresp;

wire buss_rvalid_temp;
wire buss_rready_temp;
    //bandwidth limit control
generate
    if (dl2 < 2) begin : cntpass_PROC
    always @(posedge clk or negedge rst_b)
    begin : read_counter
        if(!rst_b)
        begin
            buss_bw_rd_cnt[9:0] <= 16'd0;
            //buss_bw_rd_pls <= 1'b0;
        end
        else if(clk_en)
        begin
            //if(buss_rvalid == 1'b1)
            //begin
                if(busp_rvalid == 1'b1 && buss_rready == 1'b1)
                begin
                    buss_bw_rd_cnt[9:0] <= 10'd0;
                    //buss_bw_rd_pls <= 1'b1;
                end
                else if(buss_bw_rd_cnt[9:0] != cfg_rd_bw)
                begin
                    buss_bw_rd_cnt[9:0] <= buss_bw_rd_cnt[9:0] + 10'd1;
                    //buss_bw_rd_pls <= 1'b0;
                end
            //end
        end
    end
    end // block: cntpass_PROC
    else begin : nocntpass_PROC
    always @(posedge clk or negedge rst_b)
    begin : read_counter
        if(!rst_b)
        begin
            buss_bw_rd_cnt[9:0] <= 16'd0;
            //buss_bw_rd_pls <= 1'b0;
        end
        else if(clk_en)
        begin
            //if(buss_rvalid == 1'b1)
            //begin
                if(buss_rvalid_temp == 1'b1 && buss_rready == 1'b1)
                begin
                    buss_bw_rd_cnt[9:0] <= 10'd0;
                    //buss_bw_rd_pls <= 1'b1;
                end
                else if(buss_bw_rd_cnt[9:0] != cfg_rd_bw)
                begin
                    buss_bw_rd_cnt[9:0] <= buss_bw_rd_cnt[9:0] + 10'd1;
                    //buss_bw_rd_pls <= 1'b0;
                end
            //end
        end
    end
    end // block: nocntpass_PROC
endgenerate

    always @(posedge clk or negedge rst_b)
    begin : write_counter
        if(!rst_b)
        begin
            buss_bw_wr_cnt[9:0] <= 10'd0;
            //buss_bw_wr_pls <= 1'b0;
        end
        else if(clk_en)
        begin
            //if(busp_wvalid == 1'b1)
            //begin
                if(buss_wvalid == 1'b1 && busp_wready == 1'b1)
                begin
                    buss_bw_wr_cnt[9:0] <= 10'd0;
                    //buss_bw_wr_pls <= 1'b1;
                end
                else if(buss_bw_wr_cnt[9:0] != cfg_wr_bw[9:0])
                begin
                    buss_bw_wr_cnt[9:0] <= buss_bw_wr_cnt[9:0] + 10'd1;
                    //buss_bw_wr_pls <= 1'b0;
                end
            //end
        end
    end


   // state
   always @(posedge clk or
            negedge rst_b)
     begin : first_PROC
         if (!rst_b) begin
             i_first_r  <= 1'b1;
         end
         else if (clk_en) begin
             if (busp_aready)
                 i_first_r   <= 1'b1;
             else if (busp_avalid)
                 i_first_r   <= 1'b0;
         end
     end

generate
    if (dl2 < 2) begin : cnt_PROC
        // no latency unit, pass all signals
        assign busp_rvalid = buss_rvalid & (buss_bw_rd_cnt[9:0] == cfg_rd_bw);//buss_bw_rd_pls;
        assign buss_rready = busp_rready & (buss_bw_rd_cnt[9:0] == cfg_rd_bw);//buss_bw_rd_pls;
        assign i_busp_rdata  = buss_rdata;
        assign i_busp_rresp  = buss_rresp;
        assign i_busp_rlast  = buss_rlast;
        assign busp_bvalid = buss_bvalid;
        assign buss_bready = busp_bready;
        assign i_busp_bresp  = buss_bresp;
    end // block: pass_PROC
    else begin : nopass_PROC

        // latency at least 2 and at most (1<<dep)-1
        assign i_cfg_lat_w = (cfg_lat_w > 12'd1) ? (cfg_lat_w < dep ? cfg_lat_w : 12'd0 | {dl2{1'b1}}) : 12'd1;
        assign i_cfg_lat_r = (cfg_lat_r > 12'd1) ? (cfg_lat_r < dep ? cfg_lat_r : 12'd0 | {dl2{1'b1}}) : 12'd1;

        // Read data
        assign { i_busp_rdata,
                 i_busp_rresp,
                 i_busp_rlast } = i_rdel_mem[i_rram_addr_r];
        assign buss_rvalid_temp = buss_rvalid & (buss_bw_rd_cnt[9:0] == cfg_rd_bw);//buss_bw_rd_pls;
        assign buss_rready = buss_rready_temp & (buss_bw_rd_cnt[9:0] == cfg_rd_bw);//buss_bw_rd_pls;

        assign busp_rvalid = i_rdel_valid_r[i_rrptr_r];//buss_bw_rd_pls;
        assign buss_rready_temp = (i_rcnt_r < i_rcfg_lat_r);//buss_bw_rd_pls;
        always @*
          begin : rd_PROC
              // default outputs
              i_rdel_valid_d = i_rdel_valid_r;
              i_rcnt_d       = i_rcnt_r;
              i_rrptr_d      = i_rrptr_r;
              i_rwptr_d      = i_rwptr_r;
              i_rcfg_lat_d   = i_rcfg_lat_r;
              i_rbuf_wr      = 1'b0;
              // write to fifo
              if (buss_rvalid_temp && buss_rready_temp) begin
                 i_rcnt_d                  = i_rcfg_lat_r;
                 i_rdel_valid_d[i_rwptr_r] = 1'b1;
                 i_rbuf_wr                 = 1'b1;
              end
              // read from fifo
              if (busp_rready || !busp_rvalid) begin
                 i_rdel_valid_d[i_rrptr_r] = 1'b0; // disable rvalid after transfer
                 if (|i_rcnt_d) begin
                    i_rcnt_d  = i_rcnt_d - 1'b1;
                    i_rrptr_d = i_rrptr_r + 1'b1; // Wrap-around pointer
                    i_rwptr_d = i_rwptr_r + 1'b1; // Wrap-around pointer
                 end
              end
              if (i_cfg_lat_r > i_rcnt_d) begin
                 i_rwptr_d    = i_rrptr_d + i_cfg_lat_r;
                 i_rcfg_lat_d = i_cfg_lat_r;
              end
          end // rd_PROC

        // Write responses
        assign i_busp_bresp  = i_bdel_mem[i_bram_addr_r];
        assign busp_bvalid = i_bdel_valid_r[i_brptr_r];
        assign buss_bready = (i_bcnt_r < i_bcfg_lat_r);
        always @*
          begin : br_PROC
              // default outputs
              i_bdel_valid_d = i_bdel_valid_r;
              i_bcnt_d       = i_bcnt_r;
              i_brptr_d      = i_brptr_r;
              i_bwptr_d      = i_bwptr_r;
              i_bcfg_lat_d   = i_bcfg_lat_r;
              i_bbuf_wr      = 1'b0;

              // write to fifo
              if (buss_bvalid && buss_bready) begin
                 i_bcnt_d                  = i_bcfg_lat_r;
                 i_bdel_valid_d[i_bwptr_r] = 1'b1;
                 i_bbuf_wr                 = 1'b1;
              end
              // read from fifo
              if (busp_bready || !busp_bvalid) begin
                 i_bdel_valid_d[i_brptr_r]=1'b0;
                 if (|i_bcnt_d) begin
                    i_bcnt_d  = i_bcnt_d - 1'b1;
                    i_brptr_d = i_brptr_r + 1'b1; // Wrap-around pointer
                    i_bwptr_d = i_bwptr_r + 1'b1; // Wrap-around pointer
                 end
              end
              if (i_cfg_lat_w > i_bcnt_d) begin
                 i_bwptr_d    = i_brptr_d + i_cfg_lat_w;
                 i_bcfg_lat_d = i_cfg_lat_w;
              end
          end // br_PROC

        // state
        always @(posedge clk or
                 negedge rst_b)
          begin : rdst_PROC
              if (!rst_b) begin
                 i_rdel_valid_r <= {dep{1'b0}};
                 i_rcnt_r       <= {dl2{1'b0}};
                 i_rrptr_r      <= {dl2{1'b0}};
                 i_rwptr_r      <= {{dl2-1{1'b0}},1'b1}; // set to latency(=1)
                 i_rcfg_lat_r   <= 12'd1; // Set latency to 1 (minimum) after reset
                 i_bdel_valid_r <= {dep{1'b0}};
                 i_bcnt_r       <= {dl2{1'b0}};
                 i_brptr_r      <= {dl2{1'b0}};
                 i_bwptr_r      <= {{dl2-1{1'b0}},1'b1}; // set to latency(=1)
                 i_bcfg_lat_r   <= 12'd1; // Set latency to 1 (minimum) after reset
              end
              else if (clk_en) begin
                 i_rdel_valid_r <= i_rdel_valid_d;
                 i_rcnt_r       <= i_rcnt_d;
                 i_rrptr_r      <= i_rrptr_d;
                 i_rwptr_r      <= i_rwptr_d;
                 i_rcfg_lat_r   <= i_rcfg_lat_d;

                 i_bdel_valid_r <= i_bdel_valid_d;
                 i_bcnt_r       <= i_bcnt_d;
                 i_brptr_r      <= i_brptr_d;
                 i_bwptr_r      <= i_bwptr_d;
                 i_bcfg_lat_r   <= i_bcfg_lat_d;
              end
          end

        always @*
          begin : ramaddr_PROC
             // Following statements are added as Xilinx memory does not accept rd_en
             if (clk_en) begin
                i_rram_addr_d = i_rrptr_d;
                i_bram_addr_d = i_brptr_d;
             end
             else begin
                i_rram_addr_d = i_rram_addr_r;
                i_bram_addr_d = i_bram_addr_r;
             end
          end // ramaddr_PROC

        always @(posedge clk)
          begin : ram_PROC
              i_rram_addr_r <= i_rram_addr_d;
              i_bram_addr_r <= i_bram_addr_d;
              if (clk_en) begin
                 if (i_rbuf_wr)
                    i_rdel_mem[i_rwptr_r] <= { buss_rdata,
                                               buss_rresp,
                                               buss_rlast };
                 if (i_bbuf_wr)
                    i_bdel_mem[i_bwptr_r] <= buss_bresp;
             end
          end // ram_PROC

    end // block: nopass_PROC
endgenerate

endmodule // alb_mss_fab_bus_lat

