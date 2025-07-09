
`include "defines.v"

//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//
//
//
//   ####   #####     ##    #    #   ####
//  #       #    #   #  #   ##  ##  #
//   ####   #    #  #    #  # ## #   ####
//       #  #####   ######  #    #       #
//  #    #  #   #   #    #  #    #  #    #
//   ####   #    #  #    #  #    #   ####
//
// ===========================================================================
//
// @f:rams
//
// Description:
// @p
//  The |srams| module instantiates the all memories in the design.
// @e
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_srams (

  ////////// SRAM  interface ////////////////////////////////////////////
  //
  input   iccm0_clk,
  input  [`ICCM0_DRAM_RANGE] iccm0_din,
  input  [`ICCM0_ADR_RANGE] iccm0_addr,
  input   iccm0_cs,
  input   iccm0_we,
  input  [`ICCM_MASK_RANGE] iccm0_wem,
  output [`ICCM0_DRAM_RANGE] iccm0_dout,



  ////////// SRAM  interface ////////////////////////////////////////////
  //

  input   dccm_even_clk,
  input  [`DCCM_DRAM_RANGE] dccm_din_even,
  input  [`DCCM_ADR_RANGE] dccm_addr_even,
  input   dccm_cs_even,
  input   dccm_we_even,
  input  [`DCCM_MASK_RANGE] dccm_wem_even,
  output [`DCCM_DRAM_RANGE] dccm_dout_even,
  input   dccm_odd_clk,
  input  [`DCCM_DRAM_RANGE] dccm_din_odd,
  input  [`DCCM_ADR_RANGE] dccm_addr_odd,
  input   dccm_cs_odd,
  input   dccm_we_odd,
  input  [`DCCM_MASK_RANGE] dccm_wem_odd,
  output [`DCCM_DRAM_RANGE] dccm_dout_odd,

  ////////// SRAM IC TAG interface ////////////////////////////////////////////////
  input   ic_tag_mem_clk,
  input  [`IC_TAG_SET_RANGE] ic_tag_mem_din,
  input  [`IC_IDX_RANGE] ic_tag_mem_addr,
  input   ic_tag_mem_cs,
  input   ic_tag_mem_we,
  input  [`IC_TAG_SET_RANGE] ic_tag_mem_wem,
  output [`IC_TAG_SET_RANGE] ic_tag_mem_dout,
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  input   ic_data_mem_clk,
  input  [`IC_DATA_SET_RANGE] ic_data_mem_din,
  input  [`IC_DATA_ADR_RANGE] ic_data_mem_addr,
  input   ic_data_mem_cs,
  input   ic_data_mem_we,
  input  [`IC_DATA_SET_RANGE] ic_data_mem_wem,
  output [`IC_DATA_SET_RANGE] ic_data_mem_dout,


//spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                          test_mode,  // configure ram bypass mux if SCANTEST_RAM_BYPASS_MUX switch on
  input                          clk,
//spyglass enable_block W240
  input                          ls
);
//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Specifies modules such as memories that are designed with a bypass between data-in port and dataout port
// spyglass disable_block NoGates
// SMD: instantiate primitive gates
// SJ:  RAM instances are simulation models and black-box for spyglass
// spyglass disable_block SETUP_BBOXPIN_UNCONSTRAINED
// SMD: Reports black-box pins are unconstrained
// SJ:  RAM models are black-box for spyglass
ic_tag_ram # (
  .par_data_msb (`IC_TAG_SET_MSB),
  .par_be_msb   (`IC_TAG_SET_MSB),  
  .par_addr_msb (`IC_IDX_MSB), 
  .par_addr_lsb (`IC_IDX_LSB)
  ) u_ic_tag_ram (
  .clk              (ic_tag_mem_clk),
  .din              (ic_tag_mem_din),
  .addr             (ic_tag_mem_addr),
  .cs               (ic_tag_mem_cs),
  .we               (ic_tag_mem_we),
  .wem              (ic_tag_mem_wem),
  .ls               (1'b0),
  .dout             (ic_tag_mem_dout)
);

ic_data_ram # (
  .par_data_msb (`IC_DATA_SET_MSB),
  .par_be_msb   (`IC_DATA_SET_MSB),  
  .par_addr_msb (`IC_DATA_ADR_MSB), 
  .par_addr_lsb (`IC_DATA_ADR_LSB)
  ) u_ic_data_ram (
  .clk              (ic_data_mem_clk),
  .din              (ic_data_mem_din),
  .addr             (ic_data_mem_addr),
  .cs               (ic_data_mem_cs),
  .we               (ic_data_mem_we),
  .wem              (ic_data_mem_wem),
  .ls               (1'b0),
  .dout             (ic_data_mem_dout)
);



`define ADDR(x)  x
`define ADJUST_SIZE(x) x
`define ADJUST_MSB(x)  x


//////////////////////////////////////////////////////////////////////////////
// Module instantiation - ICCM0 RAM wrappers                                 //
//////////////////////////////////////////////////////////////////////////////

iccm0_ram  # (
  .par_data_msb (`ICCM0_DRAM_MSB),
  .par_be_msb   (`ICCM0_MASK_MSB),  
  .par_addr_msb (`ADJUST_MSB(`ICCM0_ADR_MSB)),
  .par_addr_lsb (`ICCM0_ADR_LSB)
  ) u_iccm0_even (
  .clk              (iccm0_clk),
  .din              (iccm0_din),
  .addr             (`ADDR(iccm0_addr)),
  .cs               (iccm0_cs),
  .we               (iccm0_we),
  .wem              (iccm0_wem),
  .ls               (ls),
  .dout             (iccm0_dout)
);






dccm_ram  # (
  .par_data_msb (`DCCM_DRAM_MSB),
  .par_be_msb   (`DCCM_MASK_MSB),
  .par_addr_msb (`ADJUST_MSB(`DCCM_ADR_MSB)),
  .par_addr_lsb (`DCCM_ADR_LSB)
  ) u_dccm_even (
  .clk              (dccm_even_clk),
  .din              (dccm_din_even),
  .addr             (`ADDR(dccm_addr_even)),
  .cs               (dccm_cs_even),
  .we               (dccm_we_even),
  .wem              (dccm_wem_even),
  .ls               (ls),
  .dout             (dccm_dout_even)
);

dccm_ram   # (
  .par_data_msb (`DCCM_DRAM_MSB),
  .par_be_msb   (`DCCM_MASK_MSB),
  .par_addr_msb (`ADJUST_MSB(`DCCM_ADR_MSB)),
  .par_addr_lsb (`DCCM_ADR_LSB)
  ) u_dccm_odd (
  .clk              (dccm_odd_clk),
  .din              (dccm_din_odd),
  .addr             (`ADDR(dccm_addr_odd)),
  .cs               (dccm_cs_odd),
  .we               (dccm_we_odd),
  .wem              (dccm_wem_odd),
  .ls               (ls),
  .dout             (dccm_dout_odd)
);






`undef ADJUST_MSB
// spyglass enable_block SETUP_BBOXPIN_UNCONSTRAINED
// spyglass enable_block NoGates
//spyglass enable_block TA_09
endmodule // rl_srams


