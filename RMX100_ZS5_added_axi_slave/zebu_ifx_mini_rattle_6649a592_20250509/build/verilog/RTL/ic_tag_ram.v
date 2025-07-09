// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2011 Synopsys, Inc. All rights reserved.
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
// ###   #####      #######     #      #####        ######      #     #     #
//  #   #     #        #       # #    #     #       #     #    # #    ##   ##
//  #   #              #      #   #   #             #     #   #   #   # # # #
//  #   #              #     #     #  #  ####       ######   #     #  #  #  #
//  #   #              #     #######  #     #       #   #    #######  #     #
//  #   #     #        #     #     #  #     #       #    #   #     #  #     #
// ###   #####  #####  #     #     #   #####  ##### #     #  #     #  #     #
//
//
// ===========================================================================
//
// Description:
//
//  This file implements a behavioural model of an I-cache tag memory, for
//  use in simulation of the ARCv2HS processor.
//
//
//  NOTE: this module should not be synthesized, nor should it be used
//  for gate-level simulation as it contains no delay information.
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o ic_tag_ram.vpp
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

// leda off
module ic_tag_ram #(
  parameter  par_data_msb =  31,
  parameter  par_be_msb   =  3,
  parameter  par_addr_msb =  17,
  parameter  par_addr_lsb =  3
  )(
  input                                   clk,      // clock input
  input   [par_data_msb:0]                din,      // write data input
  input   [par_addr_msb:par_addr_lsb]     addr,     // address for read or write
  input                                   cs,       // RAM chip select, active high 
  input                                   we,       // write enable, active high    
  input   [par_be_msb:0]                  wem,      // bit-mask                     
  input                                   ls,       // light sleep
  output  [par_data_msb:0]                dout      // read data output

);
localparam par_data_width      = (par_data_msb + 1);
localparam par_addr_width      = (par_addr_msb - par_addr_lsb+1);
localparam par_mem_size        = (1 << par_addr_width);
localparam par_byte_addressing = (par_data_msb > 31);


`ifndef FPGA_INFER_MEMORIES  // {
`ifdef VERILATOR  // {
`define XCAM_MODEL
`endif            // }
`ifdef TTVTOC     // {
`define XCAM_MODEL
`endif            // }

// synopsys translate_off

ram_core #(  
  .par_data_msb (par_data_msb),
  .par_be_msb   (par_be_msb),
  .par_addr_msb (par_addr_msb),
  .par_addr_lsb (par_addr_lsb)
  ) ram_core (
  .clk        (clk),
  .din        (din),
  .addr       (addr),
  .cs         (cs),
  .we         (we),
  .wem        (wem),  
  .dout       (dout)   
);

// synopsys translate_on

`else  // } {

// This part is for FPGA memory modelling

wire rden                   = cs & ~we;
wire [55:0] wrcs  = {56{cs & we}};
wire [55:0] wren  = wrcs & wem;

fpga_sram #(
  .MEM_SIZE     (par_mem_size),
  .ADDR_MSB     (par_addr_msb),
  .ADDR_LSB     (par_addr_lsb),
  .PIPELINED    (0),
  .DATA_WIDTH   (par_data_width),
  .WR_SIZE      (1), 
  .SYNC_OUT(0),
  .RAM_STL("no_rw_check"))
u_ic_tag_ram (
  .clk              (clk),
  .din              (din),
  .addr             (addr),
  .regen            (1'b1),
  .rden             (rden),
  .wren             (wren),
  .dout             (dout)
 );



`endif  // }

endmodule

// leda on
// spyglass enable_block ALL
