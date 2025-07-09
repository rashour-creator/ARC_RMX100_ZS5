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

module rl_dmp_load_aligner (
  ////////// General input signals /////////////////////////////////////////////
  //
  input [`DATA_RANGE]        data_in,
  input [1:0]                size_in,
  input                      ctl_sex, 
  input [`DATA_RANGE]        data1_in, 
  input [2:0]                addr_in,   
  output reg [`DATA_RANGE]   data_out
);

// Local declarations
//
wire ctl_byte;
wire ctl_half;

assign ctl_byte = size_in == 2'b00;
assign ctl_half = size_in == 2'b01;


// spyglass disable_block W398 STARC05-2.8.1.3 
// SMD: Redundant case expression
// SJ: Redundant selectors cannot occur
always @*
begin : dmp_aligner_PROC
  // Default values
  //
  data_out = data_in;

// spyglass disable_block DisallowCaseZ-ML
// SMD: Disallow casez statements
// SJ:  casez is intentional for priority   
  casez ({ctl_sex, ctl_byte, ctl_half, addr_in})
  // Byte
  //
  6'b0_1_?_000: data_out = {{24{1'b0}}, data_in[7:0]};
  6'b0_1_?_001: data_out = {{24{1'b0}}, data_in[15:8]};
  6'b0_1_?_010: data_out = {{24{1'b0}}, data_in[23:16]};
  6'b0_1_?_011: data_out = {{24{1'b0}}, data_in[31:24]};
  
  6'b1_1_?_000: data_out = {{24{data_in[7]}},  data_in[7:0]};
  6'b1_1_?_001: data_out = {{24{data_in[15]}}, data_in[15:8]};
  6'b1_1_?_010: data_out = {{24{data_in[23]}}, data_in[23:16]};
  6'b1_1_?_011: data_out = {{24{data_in[31]}}, data_in[31:24]};

  6'b0_1_?_100: data_out = {{24{1'b0}}, data1_in[7:0]};
  6'b0_1_?_101: data_out = {{24{1'b0}}, data1_in[15:8]};
  6'b0_1_?_110: data_out = {{24{1'b0}}, data1_in[23:16]};
  6'b0_1_?_111: data_out = {{24{1'b0}}, data1_in[31:24]};
  
  6'b1_1_?_100: data_out = {{24{data1_in[7]}},  data1_in[7:0]};
  6'b1_1_?_101: data_out = {{24{data1_in[15]}}, data1_in[15:8]};
  6'b1_1_?_110: data_out = {{24{data1_in[23]}}, data1_in[23:16]};
  6'b1_1_?_111: data_out = {{24{data1_in[31]}}, data1_in[31:24]};
  
  // Half
  //
  6'b0_?_1_000: data_out = {{16{1'b0}}, data_in[15:0]};
  6'b0_?_1_001: data_out = {{16{1'b0}}, data_in[23:8]};
  6'b0_?_1_010: data_out = {{16{1'b0}}, data_in[31:16]};
  6'b0_?_1_011: data_out = {{16{1'b0}}, data1_in[7:0], data_in[31:24]}; 
  
  6'b1_?_1_000: data_out = {{16{data_in[15]}}, data_in[15:0]};
  6'b1_?_1_001: data_out = {{16{data_in[23]}}, data_in[23:8]};
  6'b1_?_1_010: data_out = {{16{data_in[31]}}, data_in[31:16]};
  6'b1_?_1_011: data_out = {{16{data1_in[7]}}, data1_in[7:0], data_in[31:24]}; 

  6'b0_?_1_100: data_out = {{16{1'b0}}, data1_in[15:0]};
  6'b0_?_1_101: data_out = {{16{1'b0}}, data1_in[23:8]};
  6'b0_?_1_110: data_out = {{16{1'b0}}, data1_in[31:16]};
  6'b0_?_1_111: data_out = {{16{1'b0}}, data_in[7:0], data1_in[31:24]};
  
  6'b1_?_1_100: data_out = {{16{data1_in[15]}}, data1_in[15:0]};
  6'b1_?_1_101: data_out = {{16{data1_in[23]}}, data1_in[23:8]};
  6'b1_?_1_110: data_out = {{16{data1_in[31]}}, data1_in[31:16]};
  6'b1_?_1_111: data_out = {{16{data_in[7]}}, data_in[7:0], data1_in[31:24]}; 

  // Word
  //
  6'b?_0_0_001: data_out = {data1_in[7:0], data_in[31:8]}; 
  6'b?_0_0_010: data_out = {data1_in[15:0], data_in[31:16]};
  6'b?_0_0_011: data_out = {data1_in[23:0], data_in[31:24]};

  6'b?_0_0_101: data_out = {data_in[7:0], data1_in[31:8]}; 
  6'b?_0_0_110: data_out = {data_in[15:0], data1_in[31:16]};
  6'b?_0_0_111: data_out = {data_in[23:0], data1_in[31:24]};

  default:     data_out = (addr_in[2]) ? data1_in : data_in;
  endcase 
// spyglass enable_block DisallowCaseZ-ML
end
// spyglass enable_block W398 STARC05-2.8.1.3
endmodule // rl_dmp_load_aligner

