// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
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
//   alb_mss_mem_model: SRAM memory model
//
// ===========================================================================
//
// Description:
//  Verilog module defining an SRAM memory model
//  Supporting RASCAL backdoor access and FPGA mapping
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o alb_mss_mem.vpp
//
// ===========================================================================
`timescale 1ns/10ps



module alb_mss_mem_model
   #(
     parameter value1 = 1,
     parameter value8 = 8|1<<6,
     parameter mem_num = (255<<24),
     parameter a_w  = 10,
     parameter d_w  = 64,
     parameter base_addr = 0,
     parameter sz   = 1024,
     parameter alsb = (d_w == 64) ? 3 : 4)
    (input  wire              clk,
     input  wire              mem_cs,
     input  wire              mem_we,
     input  wire [d_w/8-1:0]  mem_bwe,
     input  wire [a_w-1:alsb] mem_addr,
     input  wire [d_w-1:0]    mem_wdata,
     output wire [d_w-1:0]    mem_rdata);

`ifdef VERILATOR  // {
// ============== Verilator RAM model instantiation ====================
chandle dpi_inst;
wire             dpi_ck   /* verilator public_flat */;
wire             dpi_ce_n /* verilator public_flat */; // chip enable, active 0
wire             dpi_we_n /* verilator public_flat */; // write enable, active 0
wire [d_w/8-1:0] dpi_bw_n /* verilator public_flat */; // byte enables for write, active 0
wire [a_w-1  :0] dpi_addr /* verilator public_flat */;
wire [d_w-1  :0] dpi_din  /* verilator public_flat */;
wire [d_w-1  :0] dpi_dout /* verilator public_flat */;
reg  [d_w-1  :0] i_dout;
import "DPI-C" context function chandle dpi_ssram_init(
    input string init_filename,
    input int pwrup_clr,        // CLEAR_ON_POWER_UP,
    input int dnld_on_pwrup,    // DOWNLOAD_ON_POWER_UP,
    input int base_addr,        // BASE_ADDRESS,
    input int memory_size,      // par_mem_size,
    input int address_width,    // par_addr_width,
    input int memory_model_num, // MEMORY_MODEL_NUM,
    input string ck,                // clock
    input string ce_n,              // chip enable, active 0
    input string we_n,              // write enable, active 0
    input string bw_n,              // byte enables for write, active 0
    input string addr,
    input string din,
    input string dout,
    input int options           // Endianness etc.
);
import "DPI-C" function void dpi_ssram(input chandle inst);

initial
  begin
  dpi_inst =  dpi_ssram_init(
    "init_mem.hex",           // download filename
    value1,                   // clear on power up
    value1,                   // download on power up
    base_addr,                // base address
    sz,                       // memory size
    a_w,                      // address width
    mem_num,                  // memory model num
    "dpi_ck",
    "dpi_ce_n",
    "dpi_we_n",
    "dpi_bw_n",
    "dpi_addr",
    "dpi_din",
    "dpi_dout",
    value8
  );
  end

assign dpi_ck   =  clk;
assign dpi_ce_n = ~mem_cs;
assign dpi_we_n = ~mem_we;
assign dpi_bw_n = ~mem_bwe;
assign dpi_addr = {mem_addr,{alsb{1'b0}}};
assign dpi_din  =  mem_wdata;

always @(posedge clk)
  begin
  dpi_ssram(dpi_inst);
  i_dout <= dpi_dout;
  end

assign mem_rdata = i_dout;

`else  // } {
`ifdef FPGA_INFER_MEMORIES  // {
// ============= FPGA RAM model instantiation ===================
alb_mss_fpga_sram #(
    .MEM_SIZE   (sz),
    .ADDR_MSB   (a_w-1),
    .ADDR_LSB   (alsb),
    .PIPELINED  (1'b0),
    .DATA_WIDTH (d_w),
    .WR_SIZE    (8),
    .SYNC_OUT   (1),
    .RAM_STL    ("no_rw_check"))
  u_alb_mss_mem_ram (
    .clk   (clk),
    .din   (mem_wdata),
    .addr  (mem_addr),
    .regen (1'b1),
    .rden  (mem_cs & !mem_we),
    .wren  ({d_w/8 {mem_cs & mem_we}} & mem_bwe ),
    .dout  (mem_rdata)
);

`else  // } {

// synopsys translate_off
reg  [d_w-1:0]    rdata;
wire              ce_n;
wire              we_n;
wire [d_w/8-1:0]  bw_n;
wire [a_w-1:0]    addr;

assign ce_n  = !mem_cs;
assign we_n  = !mem_we;
assign bw_n  = ~mem_bwe;
assign mem_rdata = rdata;
assign addr = {mem_addr,{alsb{1'b0}}};


`ifdef TTVTOC  // {
always @(posedge clk)
`else          // } {
initial
`endif         // }
  begin : model_PROC
    $ssram("init_mem.hex",           // download filename
           value1,                   // clear on power up
           value1,                   // download on power up
           base_addr,                // base address
           sz,                       // memory size
           a_w,                      // address width
           mem_num,                  // memory model num
           clk,
           ce_n,
           we_n,
           bw_n,
           addr,
           mem_wdata,
           rdata,
           value8);
  end // model_PROC
// synopsys translate_on
`endif  // }
`endif  // }
endmodule // alb_mss_mem_model
