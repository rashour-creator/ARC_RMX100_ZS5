// Library ARCv5EM-3.5.999999999
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
// Description:
// @p
//  
//  
// @e
//
//  
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions 
//
`include "defines.v"
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_dmp_store_aligner (
  ////////// General input signals /////////////////////////////////////////////
  //
  input [`DATA_RANGE]        data_in,
  input                      ctl_byte,
  input                      ctl_half,
  input [1:0]                addr_in,
  output reg [`DATA_RANGE]   data_out

);

// Local declarations
//
reg [`DATA_RANGE]   data1_out;
reg [3:0]           mask1_out;
reg [3:0]           mask_out;

// spyglass disable_block STARC05-2.8.1.3
// spyglass disable_block W398
// SMD: Possible case covered by multiple case statments.
// SJ:  Cases have priority, code more readable, optimized by synthesizer.
always @*
begin : dmp_store_aligner_PROC
  // Default values
  //
  data_out = data_in;
  mask_out = 4'b1111;
 data1_out = {`DATA_SIZE{1'b0}};
 mask1_out = 4'b0000;
// spyglass disable_block DisallowCaseZ-ML
// SMD: Disallow casez statements
// SJ:  casez is intentional for priority   
  casez ({ctl_byte, ctl_half, addr_in})
  // Byte
  //
  4'b1_?_00: {data_out, mask_out} = {data_in[7:0], data_in[7:0], data_in[7:0], data_in[7:0], 4'b0001};
  4'b1_?_01: {data_out, mask_out} = {data_in[7:0], data_in[7:0], data_in[7:0], data_in[7:0], 4'b0010};
  4'b1_?_10: {data_out, mask_out} = {data_in[7:0], data_in[7:0], data_in[7:0], data_in[7:0], 4'b0100};
  4'b1_?_11: {data_out, mask_out} = {data_in[7:0], data_in[7:0], data_in[7:0], data_in[7:0], 4'b1000};
  
  
  // Half
  //
  4'b?_1_00: {data_out, mask_out} = {data_in[15:0], data_in[15:0],  4'b0011}; 
  4'b?_1_01: {data_out, mask_out} = {data_in[7:0],  data_in[15:0],  8'd0,  4'b0110};
  4'b?_1_10: {data_out, mask_out} = {data_in[15:0], data_in[15:0],  4'b1100};
 
  4'b?_1_11: {data1_out, mask1_out, data_out, mask_out} = {8'd0, data_in[31:8], 4'b0001, data_in[7:0], data_in[31:8],  4'b1000};
  
  // Word
  //
  4'b0_0_01: {data1_out, mask1_out, data_out, mask_out} = {24'd0, data_in[31:24], 4'b0001, data_in[23:0], data_in[31:24],  4'b1110};
  4'b0_0_10: {data1_out, mask1_out, data_out, mask_out} = {16'd0, data_in[31:16], 4'b0011, data_in[15:0], data_in[31:16],  4'b1100};
  4'b0_0_11: {data1_out, mask1_out, data_out, mask_out} = {8'd0,  data_in[31:8],  4'b0111, data_in[7:0],  data_in[31:8],   4'b1000};
  default:   {data1_out, mask1_out, data_out, mask_out} = {{`DATA_SIZE{1'b0}}, 4'b0000, data_in, 4'b1111};
  endcase
// spyglass enable_block DisallowCaseZ-ML
end
// spyglass enable_block W398
// spyglass enable_block STARC05-2.8.1.3

endmodule // rl_dmp_store_aligner

