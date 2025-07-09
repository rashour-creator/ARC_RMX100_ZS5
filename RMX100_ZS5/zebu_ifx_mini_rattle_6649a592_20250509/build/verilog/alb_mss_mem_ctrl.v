// Library ARCv2MSS-2.1.999999999
`timescale 1ns/10ps
`include "alb_mss_mem_defines.v"
module alb_mss_mem_ctrl
 #(parameter attr = 2,       // memory attribute: 0: read_only; 1: write_only; 2: read_write
   parameter secure = 0,     // secure region: 0: non-secure region; 1: secure region
   parameter a_w = 32)       //Address-width: 32b or 40b
  (
input              cmd_valid,
output             cmd_accept,
input              cmd_read,
input [a_w-1:0]    cmd_addr,
input              cmd_wrap,
input [2:0]        cmd_data_size,
input [3:0]        cmd_burst_size,
input              cmd_nonsec,

output             rd_valid,
output             rd_excl_ok,
input              rd_accept,
output [127:0]   rd_data,
output             rd_last,
output             err_rd,

input              wr_valid,
output             wr_accept,
input [127:0]    wr_data,
input [15:0]    wr_mask,
input              wr_last,

output             wr_done,
output             wr_excl_done,
output             err_wr,
input              wr_resp_accept,

output                mem_cs,
output                mem_we,
output [15:0]    mem_bwe,
output [a_w-1:4]  mem_addr,
output [127:0]    mem_wdata,
input  [127:0]    mem_rdata,

input               clk,
input               rst_b
);


wire i_cmd_accept;
wire i_mem_rd;
wire i_mem_wr;
wire rd_chnl_i_valid;
wire rd_chnl_i_ready;
wire rd_valid_int;
wire rd_valid_comb;
wire rdata_i_valid;
reg  rd_i_valid_r;
wire rdata_i_ready;
wire wrsp_chnl_i_valid;
wire wrsp_chnl_i_ready;
wire wr_done_int;
wire i_sec_fail;
wire rd_sec_fail;
wire wr_sec_fail;
wire [127:0] i_rd_data;
// Output to IBP bus
assign cmd_accept = i_cmd_accept;

//for write-only region, never assert rd_valid
assign rd_valid   = (attr == 1)? 1'b0 :
                    (rd_sec_fail) ? 1'b0
                               : rd_valid_int;
assign rd_excl_ok = 1'b0;
assign rd_last    = rd_valid_int;
//for write-only region, assert err_rd for write response
assign err_rd     = (attr == 1)? rd_valid_int :
                    (rd_sec_fail) ? rd_valid_int
                               : 1'b0;
assign rd_data    = {128{~err_rd}} & i_rd_data;

//for read-only region, never assert wr_done
assign wr_done    = (attr == 0) ? 1'b0 :
                    (wr_sec_fail) ? 1'b0
                                : wr_done_int;
//for read-only region, assert err_wr for write response
assign err_wr     = (attr == 0) ? wr_done_int :
                    (wr_sec_fail) ? wr_done_int
                                : 1'b0;
assign wr_excl_done = 1'b0;

// Output to Memory Model
assign mem_we     = cmd_valid & i_cmd_accept & !cmd_read;
assign mem_cs     = cmd_valid & i_cmd_accept;

assign mem_addr   = cmd_addr[a_w-1:4];
// for read-only region, mask the write operation
assign mem_bwe    = (attr == 0) ? {16{1'b0}} : wr_mask;
assign mem_wdata  = wr_data;


assign wr_accept = wrsp_chnl_i_ready;


assign i_cmd_accept = i_mem_rd | i_mem_wr;
assign i_mem_rd = cmd_read & (rd_chnl_i_ready & rdata_i_ready);
assign i_mem_wr = !cmd_read & wrsp_chnl_i_ready;
assign i_sec_fail = (secure == 1) ? cmd_nonsec : 1'b0;


assign rd_chnl_i_valid = cmd_valid & i_mem_rd;
alb_mss_mem_fifo #(
           .FIFO_DEPTH(2),
           .FIFO_WIDTH(2),
           .IN_OUT_MWHILE(0),
           .O_SUPPORT_RTIO(0),
           .I_SUPPORT_RTIO(0)
       ) rd_chnl_fifo (
           .i_valid(rd_chnl_i_valid), //wen
           .i_ready(rd_chnl_i_ready), //not full
           .i_data({i_sec_fail, 1'b1}),
           .o_valid(), //not empty
           .o_ready(rd_accept), //ren
           .o_data({rd_sec_fail, rd_valid_int}),
           .i_occp(),
           .o_occp(),
           .i_clk_en(1'b1),
           .o_clk_en(1'b1),
           .clk(clk),
           .rst_a(~rst_b)
       );

assign rd_valid_comb = rd_valid | err_rd;
assign rdata_i_valid = rd_i_valid_r;
always @(posedge clk or negedge rst_b)
  begin: rd_i_valid_r_PROC
    if (rst_b == 1'b0)
        rd_i_valid_r <= 1'b0;
    else
        rd_i_valid_r <= rd_chnl_i_valid;
  end
alb_mss_mem_bypbuf #(
           .BUF_DEPTH(2),
           .BUF_WIDTH(128)
       ) rdata_bypbuf (
           .i_valid(rdata_i_valid), //wen
           .i_ready(rdata_i_ready), //not full
           .i_data(mem_rdata),
           .o_valid(), //not empty
           .o_ready(rd_valid_comb & rd_accept), //ren
           .o_data(i_rd_data),
           .clk(clk),
           .rst_a(~rst_b)
       );

assign wrsp_chnl_i_valid = cmd_valid & i_mem_wr;
alb_mss_mem_fifo #(
           .FIFO_DEPTH(2),
           .FIFO_WIDTH(2),
           .IN_OUT_MWHILE(0),
           .O_SUPPORT_RTIO(0),
           .I_SUPPORT_RTIO(0)
       ) wrsp_chnl_fifo (
           .i_valid(wrsp_chnl_i_valid), //wen
           .i_ready(wrsp_chnl_i_ready), //not full
           .i_data({i_sec_fail, 1'b1}),
           .o_valid(), //not empty
           .o_ready(wr_resp_accept), //ren
           .o_data({wr_sec_fail, wr_done_int}),
           .i_occp(),
           .o_occp(),
           .i_clk_en(1'b1),
           .o_clk_en(1'b1),
           .clk(clk),
           .rst_a(~rst_b)
       );
endmodule
