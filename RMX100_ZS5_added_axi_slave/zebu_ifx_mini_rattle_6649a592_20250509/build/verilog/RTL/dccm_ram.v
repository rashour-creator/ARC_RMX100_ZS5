// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2016 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// 
// 
// 
// DCCM_RAM
// 
// 
// 
//
// ===========================================================================
//
// Description:
//
//  This file implements a behavioural model of an DCCM memory
//
//
//  NOTE: this module should not be synthesized, nor should it be used
//  for gate-level simulation as it contains no delay information.
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o DCCM_ram.vpp
//
// ===========================================================================

// spyglass disable_block ALL
// SMD: ALL
// SJ: Function model only, will be replaced by memory compiler
// Configuration-dependent macro definitions
//
`include "defines.v"

// Simulation timestep information
//
// synopsys translate_off

///////////////////////////////////////////////////////////////////////////
// Common Verilog definitions
///////////////////////////////////////////////////////////////////////////

// Verilog simulator timescale definition for all modules
//
`timescale 1 ns / 10 ps

// synopsys translate_on
`ifdef VERILATOR
`define XCAM_MODEL
`endif
`ifdef TTVTOC
`define XCAM_MODEL
`endif
`ifndef RAM_MODEL_INIT      
`define RAM_MODEL_INIT      
`endif
// leda off
module dccm_ram #(
  parameter  par_data_msb =  31,
  parameter  par_be_msb   =  3,
  parameter  par_addr_msb =  17,
  parameter  par_addr_lsb =  3
  ) (
  input   [par_data_msb: 0]            din,      // write data input
  input   [par_addr_msb:par_addr_lsb]  addr,     // address for read or write
  input                                cs,       // RAM chip select, active high
  input                                we,       // memory write enable, active high
  input   [par_be_msb             :0]  wem,      // byte write enables, active high
  input                                ls,       // light sleep
  output  [par_data_msb           :0]  dout,     // read data output
  input                                clk       // clock input
  );
parameter par_addr_width = (par_addr_msb-par_addr_lsb+1);
parameter par_mem_size = (1 << par_addr_width);
parameter par_byte_addressing = (par_data_msb > 31);
parameter par_dpi_addr_msb = par_byte_addressing ? par_addr_msb : (par_addr_msb-par_addr_lsb);

`ifdef FPGA_INFER_MEMORIES // {

wire                  rden; // memory read enable
wire [par_data_msb:0] wren; // write enables

assign rden = cs & ~we;
assign wren = {40{cs & we}} & {

                 {8{wem[par_be_msb]}},
                 {8{wem[3]}},{8{wem[2]}},{8{wem[1]}},{8{wem[0]}}};

fpga_sram #(
  .MEM_SIZE(par_mem_size),
  .ADDR_MSB(par_addr_msb),
  .ADDR_LSB(par_addr_lsb),
  .PIPELINED(1'b0),
  .DATA_WIDTH(par_data_msb+1),
  .WR_SIZE     (1), 
  .SYNC_OUT(0),
  .RAM_STL("no_rw_check"))
u_DCCM_sram (
  .clk              (clk),
  .din              (din),
  .addr             (addr),
  .regen            (1'b1),
  .rden             (rden),
  .wren             (wren),
  .dout             (dout));

`else  // } { not FPGA_INFER_MEMORIES follows...

// form write data bit mask
wire [par_data_msb:0] dmask;
assign dmask = {
                 {8{wem[par_be_msb]}},
                 {8{wem[3]}},{8{wem[2]}},{8{wem[1]}},{8{wem[0]}}
               }; 

// Initialize memory with random values
// synopsys translate_off
`ifndef XCAM_MODEL      // {
`ifdef RAM_MODEL_INIT      // {

integer i;
initial 
begin : init
  localparam DCCM_SIZE = 1<<par_addr_msb;
  for (i=0; i < DCCM_SIZE/16; i=i+1) begin
    // u_ram_core_inst.ram_core_0[i] = ({$random} % `DCCM_BANK_WIDTH);
    // Initializing rams with Zero. Partail stores to un-initalized location is getting exception when ecc is present. 
    // Fixing the star - 9001278913
    u_ram_core_inst.ram_core_0[i] = 0;
  end 
end
`endif                 // }  ifdef RAM_MODEL_INIT


`endif                 // }  ifndef XCAM_MODEL
// synopsys translate_on

// synopsys translate_off
ram_core #(
  .par_data_msb (par_data_msb),
  .par_be_msb   (par_data_msb), // data bit write mask
  .par_addr_msb (par_addr_msb),
  .par_addr_lsb (par_addr_lsb)
  ) u_ram_core_inst (
  .clk  (clk),
  .din  (din),
  .addr (addr),
  .cs   (cs),
  .we   (we),
  .wem  (dmask),
  .dout (dout)
);
// synopsys translate_on
`endif       // }
endmodule
// leda on
// spyglass enable_block ALL
