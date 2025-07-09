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
// This module implements the Read-modify-write merging in case of partial
// stores. 
//  
// @e
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

module rl_dmp_ecc_store_aligner (
  input [1:0]                   addr_r,
  input [1:0]                   size_r,
  input [`DATA_RANGE]           wr_data_r,
  input [`DATA_RANGE]           rd_data0,
  input [`DATA_RANGE]           rd_data1,
  
  output [`DATA_RANGE]          cwb_ecc_data1,
  output [3:0]                  cwb_ecc_data1_mask,
  output [`DATA_RANGE]          cwb_ecc_data0,
  output [3:0]                  cwb_ecc_data0_mask
);

// Local declarations
//
reg [3:0]              size0_mask;

reg [3:0]              wr_data0_mask;
reg [3:0]              wr_data1_mask;

reg [`DATA_RANGE]      wr_data0;
reg [`DATA_RANGE]      wr_data1;

//////////////////////////////////////////////////////////////////////////////
//
// Size0 mask calculation
//
//////////////////////////////////////////////////////////////////////////////
// Based on the size information, mask is calculated 
// This mask will be used to calculate the masks for write data0 and data1
// 
// 
always @*
begin : size0_calc_PROC
  case (size_r)
  2'b00:   size0_mask = 4'b0001;
  2'b01:   size0_mask = 4'b0011;
  2'b10:   size0_mask = 4'b1111;
  default: size0_mask = 4'b0001;
  endcase
end

//////////////////////////////////////////////////////////////////////////////
//
//  Write0, and Write1 data, bank mask calculation
//
//////////////////////////////////////////////////////////////////////////////
// The Size0 mask is used to calculate the read and write masks
// This will help in writing the data in the correct lane
//

always @*
begin : read_write_mask_PROC
  //
  // Use the addr to determine which banks to start
  
  // Default values:
  //
  wr_data0      = wr_data_r;
  wr_data0_mask = 4'd0;
  wr_data1      = rd_data1;
  wr_data1_mask = 4'd0;
  
  case (addr_r)
  2'b00: 
  begin
    wr_data0[7:0]    = size0_mask[0] ? wr_data_r[7:0]   : rd_data0[7:0];
    wr_data0[15:8]   = size0_mask[1] ? wr_data_r[15:8]  : rd_data0[15:8];
    wr_data0[23:16]  = size0_mask[2] ? wr_data_r[23:16] : rd_data0[23:16];
    wr_data0[31:24]  = size0_mask[3] ? wr_data_r[31:24] : rd_data0[31:24];

    wr_data0_mask    = 4'b1111;
    wr_data1         = wr_data_r;

    wr_data1_mask    = 4'd0;
  end
  2'b01:
  begin
    wr_data0[7:0]    = rd_data0[7:0];
    wr_data0[15:8]   = size0_mask[0]  ? wr_data_r[7:0]   : rd_data0[15:8];
    wr_data0[23:16]  = size0_mask[1]  ? wr_data_r[15:8]  : rd_data0[23:16];
    wr_data0[31:24]  = size0_mask[2]  ? wr_data_r[23:16] : rd_data0[31:24];

    wr_data0_mask    = 4'b1111;
    wr_data1[7:0]    = size0_mask[3]  ? wr_data_r[31:24] : rd_data1[7:0];

    wr_data1_mask    = {3'd0, size0_mask[3]};  
  end
  2'b10:
  begin
    wr_data0[7:0]    = rd_data0[7:0];
    wr_data0[15:8]   = rd_data0[15:8];
    wr_data0[23:16]  = size0_mask[0]  ? wr_data_r[7:0]  : rd_data0[23:16];
    wr_data0[31:24]  = size0_mask[1]  ? wr_data_r[15:8] : rd_data0[31:24];

    wr_data0_mask    = 4'b1111;
    wr_data1[7:0]    = size0_mask[2]  ? wr_data_r[23:16] : rd_data1[7:0];
    wr_data1[15:8]   = size0_mask[3]  ? wr_data_r[31:24] : rd_data1[15:8];

    wr_data1_mask    = {2'd0, size0_mask[3:2]};
  end
  2'b11:
  begin
    wr_data0[7:0]    = rd_data0[7:0];
    wr_data0[15:8]   = rd_data0[15:8];
    wr_data0[23:16]  = rd_data0[23:16];
    wr_data0[31:24]  = size0_mask[0]  ? wr_data_r[7:0] : rd_data0[31:24];

    wr_data0_mask    = 4'b1111;
    wr_data1[7:0]    = size0_mask[1]  ? wr_data_r[15:8]  : rd_data1[7:0];
    wr_data1[15:8]   = size0_mask[2]  ? wr_data_r[23:16] : rd_data1[15:8];
    wr_data1[23:16]  = size0_mask[3]  ? wr_data_r[31:24] : rd_data1[23:16];

    wr_data1_mask    = {1'd0, size0_mask[3:1]};
  end
// spyglass disable_block W193
// SMD: empty statement
// SJ:  default values are covered but empty default kept   
  default: ;
// spyglass enable_block W193  
  endcase
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Output assignments
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

assign cwb_ecc_data0      = wr_data0;
assign cwb_ecc_data0_mask = wr_data0_mask;

assign cwb_ecc_data1      = wr_data1;
assign cwb_ecc_data1_mask = (|wr_data1_mask) ? 4'b1111 : 4'b0000;
endmodule

