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
`include "mpy_defines.v"
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"


module rl_regfile (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                    clk,            // clock signal
  input                    rst_a,          // reset signal
  ////////// User mode SP save/restore //////////////////////////////
  //
  output [`DATA_RANGE]     sp_u,
  input                    sp_u_recover,
  input  [`DATA_RANGE]     mtsp_r,

  ////////// Read port0 /////////////////////////////////////////////
  //
  input [4:0]              rf_rd_addr0,    // read address 0
  output reg [`DATA_RANGE] rf_rd_data0,    // read data 0

  ////////// Read port1 /////////////////////////////////////////////
  //
  input [4:0]              rf_rd_addr1,   // read address 1
  output reg [`DATA_RANGE] rf_rd_data1,   // read data 1



  ////////// Write port0 /////////////////////////////////////////////
  //
  input                    rf_write0,     // write enable 0
  input [4:0]              rf_wr_addr0,   // write address 0
  input [`DATA_RANGE]      rf_wr_data0,   // write data 0

  ////////// Write port1 /////////////////////////////////////////////
  //
  input                    rf_write1,     // write enable 0
  input [4:0]              rf_wr_addr1,   // write address 0
  input [`DATA_RANGE]      rf_wr_data1    // write data 0
);


// Local declarations
//
reg [`DATA_RANGE] x1_r;
reg [`DATA_RANGE] x2_r;
reg [`DATA_RANGE] x3_r;
reg [`DATA_RANGE] x4_r;
reg [`DATA_RANGE] x5_r;
reg [`DATA_RANGE] x6_r;
reg [`DATA_RANGE] x7_r;
reg [`DATA_RANGE] x8_r;
reg [`DATA_RANGE] x9_r;
reg [`DATA_RANGE] x10_r;
reg [`DATA_RANGE] x11_r;
reg [`DATA_RANGE] x12_r;
reg [`DATA_RANGE] x13_r;
reg [`DATA_RANGE] x14_r;
reg [`DATA_RANGE] x15_r;
reg [`DATA_RANGE] x16_r;
reg [`DATA_RANGE] x17_r;
reg [`DATA_RANGE] x18_r;
reg [`DATA_RANGE] x19_r;
reg [`DATA_RANGE] x20_r;
reg [`DATA_RANGE] x21_r;
reg [`DATA_RANGE] x22_r;
reg [`DATA_RANGE] x23_r;
reg [`DATA_RANGE] x24_r;
reg [`DATA_RANGE] x25_r;
reg [`DATA_RANGE] x26_r;
reg [`DATA_RANGE] x27_r;
reg [`DATA_RANGE] x28_r;
reg [`DATA_RANGE] x29_r;
reg [`DATA_RANGE] x30_r;
reg [`DATA_RANGE] x31_r;


reg [`DATA_RANGE] x1_nxt;
reg [`DATA_RANGE] x2_nxt;
reg [`DATA_RANGE] x3_nxt;
reg [`DATA_RANGE] x4_nxt;
reg [`DATA_RANGE] x5_nxt;
reg [`DATA_RANGE] x6_nxt;
reg [`DATA_RANGE] x7_nxt;
reg [`DATA_RANGE] x8_nxt;
reg [`DATA_RANGE] x9_nxt;
reg [`DATA_RANGE] x10_nxt;
reg [`DATA_RANGE] x11_nxt;
reg [`DATA_RANGE] x12_nxt;
reg [`DATA_RANGE] x13_nxt;
reg [`DATA_RANGE] x14_nxt;
reg [`DATA_RANGE] x15_nxt;
reg [`DATA_RANGE] x16_nxt;
reg [`DATA_RANGE] x17_nxt;
reg [`DATA_RANGE] x18_nxt;
reg [`DATA_RANGE] x19_nxt;
reg [`DATA_RANGE] x20_nxt;
reg [`DATA_RANGE] x21_nxt;
reg [`DATA_RANGE] x22_nxt;
reg [`DATA_RANGE] x23_nxt;
reg [`DATA_RANGE] x24_nxt;
reg [`DATA_RANGE] x25_nxt;
reg [`DATA_RANGE] x26_nxt;
reg [`DATA_RANGE] x27_nxt;
reg [`DATA_RANGE] x28_nxt;
reg [`DATA_RANGE] x29_nxt;
reg [`DATA_RANGE] x30_nxt;
reg [`DATA_RANGE] x31_nxt;

reg [`RGF_NUM_RANGE]        rf_wr0_1h;
reg [`RGF_NUM_RANGE]        rf_wr1_1h;
reg [`RGF_NUM_RANGE]        rf_wr_1h;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous read port logic                                           //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

// Read port0
//
always @*
begin : rf_rd_port0_PROC
  case (rf_rd_addr0)
    5'd1:   rf_rd_data0 = x1_r;
    5'd2:   rf_rd_data0 = x2_r;
    5'd3:   rf_rd_data0 = x3_r;
    5'd4:   rf_rd_data0 = x4_r;
    5'd5:   rf_rd_data0 = x5_r;
    5'd6:   rf_rd_data0 = x6_r;
    5'd7:   rf_rd_data0 = x7_r;
    5'd8:   rf_rd_data0 = x8_r;
    5'd9:   rf_rd_data0 = x9_r;
    5'd10:   rf_rd_data0 = x10_r;
    5'd11:   rf_rd_data0 = x11_r;
    5'd12:   rf_rd_data0 = x12_r;
    5'd13:   rf_rd_data0 = x13_r;
    5'd14:   rf_rd_data0 = x14_r;
    5'd15:   rf_rd_data0 = x15_r;
    5'd16:   rf_rd_data0 = x16_r;
    5'd17:   rf_rd_data0 = x17_r;
    5'd18:   rf_rd_data0 = x18_r;
    5'd19:   rf_rd_data0 = x19_r;
    5'd20:   rf_rd_data0 = x20_r;
    5'd21:   rf_rd_data0 = x21_r;
    5'd22:   rf_rd_data0 = x22_r;
    5'd23:   rf_rd_data0 = x23_r;
    5'd24:   rf_rd_data0 = x24_r;
    5'd25:   rf_rd_data0 = x25_r;
    5'd26:   rf_rd_data0 = x26_r;
    5'd27:   rf_rd_data0 = x27_r;
    5'd28:   rf_rd_data0 = x28_r;
    5'd29:   rf_rd_data0 = x29_r;
    5'd30:   rf_rd_data0 = x30_r;
    5'd31:   rf_rd_data0 = x31_r;
    default: rf_rd_data0 = {`DATA_SIZE{1'b0}};
  endcase
end


// Read port1
//
always @*
begin : rf_rd_port1_PROC
  case (rf_rd_addr1)
    5'd1:   rf_rd_data1 = x1_r;
    5'd2:   rf_rd_data1 = x2_r;
    5'd3:   rf_rd_data1 = x3_r;
    5'd4:   rf_rd_data1 = x4_r;
    5'd5:   rf_rd_data1 = x5_r;
    5'd6:   rf_rd_data1 = x6_r;
    5'd7:   rf_rd_data1 = x7_r;
    5'd8:   rf_rd_data1 = x8_r;
    5'd9:   rf_rd_data1 = x9_r;
    5'd10:   rf_rd_data1 = x10_r;
    5'd11:   rf_rd_data1 = x11_r;
    5'd12:   rf_rd_data1 = x12_r;
    5'd13:   rf_rd_data1 = x13_r;
    5'd14:   rf_rd_data1 = x14_r;
    5'd15:   rf_rd_data1 = x15_r;
    5'd16:   rf_rd_data1 = x16_r;
    5'd17:   rf_rd_data1 = x17_r;
    5'd18:   rf_rd_data1 = x18_r;
    5'd19:   rf_rd_data1 = x19_r;
    5'd20:   rf_rd_data1 = x20_r;
    5'd21:   rf_rd_data1 = x21_r;
    5'd22:   rf_rd_data1 = x22_r;
    5'd23:   rf_rd_data1 = x23_r;
    5'd24:   rf_rd_data1 = x24_r;
    5'd25:   rf_rd_data1 = x25_r;
    5'd26:   rf_rd_data1 = x26_r;
    5'd27:   rf_rd_data1 = x27_r;
    5'd28:   rf_rd_data1 = x28_r;
    5'd29:   rf_rd_data1 = x29_r;
    5'd30:   rf_rd_data1 = x30_r;
    5'd31:   rf_rd_data1 = x31_r;
    default: rf_rd_data1 = {`DATA_SIZE{1'b0}};
  endcase
end




////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous write port address decode logic                           //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
always @*
begin : rf_write_dec_PROC
  // One-hot encoding for write ports
  //
  rf_wr0_1h[1] = ((rf_wr_addr0 == 5'd1) & rf_write0);
  rf_wr1_1h[1] = ((rf_wr_addr1 == 5'd1) & rf_write1);
  rf_wr0_1h[2] = ((rf_wr_addr0 == 5'd2) & rf_write0);
  rf_wr1_1h[2] = ((rf_wr_addr1 == 5'd2) & rf_write1);
  rf_wr0_1h[3] = ((rf_wr_addr0 == 5'd3) & rf_write0);
  rf_wr1_1h[3] = ((rf_wr_addr1 == 5'd3) & rf_write1);
  rf_wr0_1h[4] = ((rf_wr_addr0 == 5'd4) & rf_write0);
  rf_wr1_1h[4] = ((rf_wr_addr1 == 5'd4) & rf_write1);
  rf_wr0_1h[5] = ((rf_wr_addr0 == 5'd5) & rf_write0);
  rf_wr1_1h[5] = ((rf_wr_addr1 == 5'd5) & rf_write1);
  rf_wr0_1h[6] = ((rf_wr_addr0 == 5'd6) & rf_write0);
  rf_wr1_1h[6] = ((rf_wr_addr1 == 5'd6) & rf_write1);
  rf_wr0_1h[7] = ((rf_wr_addr0 == 5'd7) & rf_write0);
  rf_wr1_1h[7] = ((rf_wr_addr1 == 5'd7) & rf_write1);
  rf_wr0_1h[8] = ((rf_wr_addr0 == 5'd8) & rf_write0);
  rf_wr1_1h[8] = ((rf_wr_addr1 == 5'd8) & rf_write1);
  rf_wr0_1h[9] = ((rf_wr_addr0 == 5'd9) & rf_write0);
  rf_wr1_1h[9] = ((rf_wr_addr1 == 5'd9) & rf_write1);
  rf_wr0_1h[10] = ((rf_wr_addr0 == 5'd10) & rf_write0);
  rf_wr1_1h[10] = ((rf_wr_addr1 == 5'd10) & rf_write1);
  rf_wr0_1h[11] = ((rf_wr_addr0 == 5'd11) & rf_write0);
  rf_wr1_1h[11] = ((rf_wr_addr1 == 5'd11) & rf_write1);
  rf_wr0_1h[12] = ((rf_wr_addr0 == 5'd12) & rf_write0);
  rf_wr1_1h[12] = ((rf_wr_addr1 == 5'd12) & rf_write1);
  rf_wr0_1h[13] = ((rf_wr_addr0 == 5'd13) & rf_write0);
  rf_wr1_1h[13] = ((rf_wr_addr1 == 5'd13) & rf_write1);
  rf_wr0_1h[14] = ((rf_wr_addr0 == 5'd14) & rf_write0);
  rf_wr1_1h[14] = ((rf_wr_addr1 == 5'd14) & rf_write1);
  rf_wr0_1h[15] = ((rf_wr_addr0 == 5'd15) & rf_write0);
  rf_wr1_1h[15] = ((rf_wr_addr1 == 5'd15) & rf_write1);
  rf_wr0_1h[16] = ((rf_wr_addr0 == 5'd16) & rf_write0);
  rf_wr1_1h[16] = ((rf_wr_addr1 == 5'd16) & rf_write1);
  rf_wr0_1h[17] = ((rf_wr_addr0 == 5'd17) & rf_write0);
  rf_wr1_1h[17] = ((rf_wr_addr1 == 5'd17) & rf_write1);
  rf_wr0_1h[18] = ((rf_wr_addr0 == 5'd18) & rf_write0);
  rf_wr1_1h[18] = ((rf_wr_addr1 == 5'd18) & rf_write1);
  rf_wr0_1h[19] = ((rf_wr_addr0 == 5'd19) & rf_write0);
  rf_wr1_1h[19] = ((rf_wr_addr1 == 5'd19) & rf_write1);
  rf_wr0_1h[20] = ((rf_wr_addr0 == 5'd20) & rf_write0);
  rf_wr1_1h[20] = ((rf_wr_addr1 == 5'd20) & rf_write1);
  rf_wr0_1h[21] = ((rf_wr_addr0 == 5'd21) & rf_write0);
  rf_wr1_1h[21] = ((rf_wr_addr1 == 5'd21) & rf_write1);
  rf_wr0_1h[22] = ((rf_wr_addr0 == 5'd22) & rf_write0);
  rf_wr1_1h[22] = ((rf_wr_addr1 == 5'd22) & rf_write1);
  rf_wr0_1h[23] = ((rf_wr_addr0 == 5'd23) & rf_write0);
  rf_wr1_1h[23] = ((rf_wr_addr1 == 5'd23) & rf_write1);
  rf_wr0_1h[24] = ((rf_wr_addr0 == 5'd24) & rf_write0);
  rf_wr1_1h[24] = ((rf_wr_addr1 == 5'd24) & rf_write1);
  rf_wr0_1h[25] = ((rf_wr_addr0 == 5'd25) & rf_write0);
  rf_wr1_1h[25] = ((rf_wr_addr1 == 5'd25) & rf_write1);
  rf_wr0_1h[26] = ((rf_wr_addr0 == 5'd26) & rf_write0);
  rf_wr1_1h[26] = ((rf_wr_addr1 == 5'd26) & rf_write1);
  rf_wr0_1h[27] = ((rf_wr_addr0 == 5'd27) & rf_write0);
  rf_wr1_1h[27] = ((rf_wr_addr1 == 5'd27) & rf_write1);
  rf_wr0_1h[28] = ((rf_wr_addr0 == 5'd28) & rf_write0);
  rf_wr1_1h[28] = ((rf_wr_addr1 == 5'd28) & rf_write1);
  rf_wr0_1h[29] = ((rf_wr_addr0 == 5'd29) & rf_write0);
  rf_wr1_1h[29] = ((rf_wr_addr1 == 5'd29) & rf_write1);
  rf_wr0_1h[30] = ((rf_wr_addr0 == 5'd30) & rf_write0);
  rf_wr1_1h[30] = ((rf_wr_addr1 == 5'd30) & rf_write1);
  rf_wr0_1h[31] = ((rf_wr_addr0 == 5'd31) & rf_write0);
  rf_wr1_1h[31] = ((rf_wr_addr1 == 5'd31) & rf_write1);



  rf_wr_1h[1] = rf_wr0_1h[1] | rf_wr1_1h[1];
  rf_wr_1h[2] = rf_wr0_1h[2] | rf_wr1_1h[2];
  rf_wr_1h[2] |= sp_u_recover;
  rf_wr_1h[3] = rf_wr0_1h[3] | rf_wr1_1h[3];
  rf_wr_1h[4] = rf_wr0_1h[4] | rf_wr1_1h[4];
  rf_wr_1h[5] = rf_wr0_1h[5] | rf_wr1_1h[5];
  rf_wr_1h[6] = rf_wr0_1h[6] | rf_wr1_1h[6];
  rf_wr_1h[7] = rf_wr0_1h[7] | rf_wr1_1h[7];
  rf_wr_1h[8] = rf_wr0_1h[8] | rf_wr1_1h[8];
  rf_wr_1h[9] = rf_wr0_1h[9] | rf_wr1_1h[9];
  rf_wr_1h[10] = rf_wr0_1h[10] | rf_wr1_1h[10];
  rf_wr_1h[11] = rf_wr0_1h[11] | rf_wr1_1h[11];
  rf_wr_1h[12] = rf_wr0_1h[12] | rf_wr1_1h[12];
  rf_wr_1h[13] = rf_wr0_1h[13] | rf_wr1_1h[13];
  rf_wr_1h[14] = rf_wr0_1h[14] | rf_wr1_1h[14];
  rf_wr_1h[15] = rf_wr0_1h[15] | rf_wr1_1h[15];
  rf_wr_1h[16] = rf_wr0_1h[16] | rf_wr1_1h[16];
  rf_wr_1h[17] = rf_wr0_1h[17] | rf_wr1_1h[17];
  rf_wr_1h[18] = rf_wr0_1h[18] | rf_wr1_1h[18];
  rf_wr_1h[19] = rf_wr0_1h[19] | rf_wr1_1h[19];
  rf_wr_1h[20] = rf_wr0_1h[20] | rf_wr1_1h[20];
  rf_wr_1h[21] = rf_wr0_1h[21] | rf_wr1_1h[21];
  rf_wr_1h[22] = rf_wr0_1h[22] | rf_wr1_1h[22];
  rf_wr_1h[23] = rf_wr0_1h[23] | rf_wr1_1h[23];
  rf_wr_1h[24] = rf_wr0_1h[24] | rf_wr1_1h[24];
  rf_wr_1h[25] = rf_wr0_1h[25] | rf_wr1_1h[25];
  rf_wr_1h[26] = rf_wr0_1h[26] | rf_wr1_1h[26];
  rf_wr_1h[27] = rf_wr0_1h[27] | rf_wr1_1h[27];
  rf_wr_1h[28] = rf_wr0_1h[28] | rf_wr1_1h[28];
  rf_wr_1h[29] = rf_wr0_1h[29] | rf_wr1_1h[29];
  rf_wr_1h[30] = rf_wr0_1h[30] | rf_wr1_1h[30];
  rf_wr_1h[31] = rf_wr0_1h[31] | rf_wr1_1h[31];
end

always @*
begin : rf_write_data_nxt_PROC
  // Data to be written
  //
  x1_nxt = rf_wr0_1h[1]   ? rf_wr_data0   : rf_wr_data1;
  x2_nxt = rf_wr0_1h[2]   ? rf_wr_data0   : rf_wr_data1;
  x2_nxt = sp_u_recover ? mtsp_r : x2_nxt;
  x3_nxt = rf_wr0_1h[3]   ? rf_wr_data0   : rf_wr_data1;
  x4_nxt = rf_wr0_1h[4]   ? rf_wr_data0   : rf_wr_data1;
  x5_nxt = rf_wr0_1h[5]   ? rf_wr_data0   : rf_wr_data1;
  x6_nxt = rf_wr0_1h[6]   ? rf_wr_data0   : rf_wr_data1;
  x7_nxt = rf_wr0_1h[7]   ? rf_wr_data0   : rf_wr_data1;
  x8_nxt = rf_wr0_1h[8]   ? rf_wr_data0   : rf_wr_data1;
  x9_nxt = rf_wr0_1h[9]   ? rf_wr_data0   : rf_wr_data1;
  x10_nxt = rf_wr0_1h[10]   ? rf_wr_data0   : rf_wr_data1;
  x11_nxt = rf_wr0_1h[11]   ? rf_wr_data0   : rf_wr_data1;
  x12_nxt = rf_wr0_1h[12]   ? rf_wr_data0   : rf_wr_data1;
  x13_nxt = rf_wr0_1h[13]   ? rf_wr_data0   : rf_wr_data1;
  x14_nxt = rf_wr0_1h[14]   ? rf_wr_data0   : rf_wr_data1;
  x15_nxt = rf_wr0_1h[15]   ? rf_wr_data0   : rf_wr_data1;
  x16_nxt = rf_wr0_1h[16]   ? rf_wr_data0   : rf_wr_data1;
  x17_nxt = rf_wr0_1h[17]   ? rf_wr_data0   : rf_wr_data1;
  x18_nxt = rf_wr0_1h[18]   ? rf_wr_data0   : rf_wr_data1;
  x19_nxt = rf_wr0_1h[19]   ? rf_wr_data0   : rf_wr_data1;
  x20_nxt = rf_wr0_1h[20]   ? rf_wr_data0   : rf_wr_data1;
  x21_nxt = rf_wr0_1h[21]   ? rf_wr_data0   : rf_wr_data1;
  x22_nxt = rf_wr0_1h[22]   ? rf_wr_data0   : rf_wr_data1;
  x23_nxt = rf_wr0_1h[23]   ? rf_wr_data0   : rf_wr_data1;
  x24_nxt = rf_wr0_1h[24]   ? rf_wr_data0   : rf_wr_data1;
  x25_nxt = rf_wr0_1h[25]   ? rf_wr_data0   : rf_wr_data1;
  x26_nxt = rf_wr0_1h[26]   ? rf_wr_data0   : rf_wr_data1;
  x27_nxt = rf_wr0_1h[27]   ? rf_wr_data0   : rf_wr_data1;
  x28_nxt = rf_wr0_1h[28]   ? rf_wr_data0   : rf_wr_data1;
  x29_nxt = rf_wr0_1h[29]   ? rf_wr_data0   : rf_wr_data1;
  x30_nxt = rf_wr0_1h[30]   ? rf_wr_data0   : rf_wr_data1;
  x31_nxt = rf_wr0_1h[31]   ? rf_wr_data0   : rf_wr_data1;
end


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Synchronous write port logic                                           //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : rf_regs_PROC
  if (rst_a == 1'b1)
  begin
    x1_r <= {`DATA_SIZE{1'b0}};
    x2_r <= {`DATA_SIZE{1'b0}};
    x3_r <= {`DATA_SIZE{1'b0}};
    x4_r <= {`DATA_SIZE{1'b0}};
    x5_r <= {`DATA_SIZE{1'b0}};
    x6_r <= {`DATA_SIZE{1'b0}};
    x7_r <= {`DATA_SIZE{1'b0}};
    x8_r <= {`DATA_SIZE{1'b0}};
    x9_r <= {`DATA_SIZE{1'b0}};
    x10_r <= {`DATA_SIZE{1'b0}};
    x11_r <= {`DATA_SIZE{1'b0}};
    x12_r <= {`DATA_SIZE{1'b0}};
    x13_r <= {`DATA_SIZE{1'b0}};
    x14_r <= {`DATA_SIZE{1'b0}};
    x15_r <= {`DATA_SIZE{1'b0}};
    x16_r <= {`DATA_SIZE{1'b0}};
    x17_r <= {`DATA_SIZE{1'b0}};
    x18_r <= {`DATA_SIZE{1'b0}};
    x19_r <= {`DATA_SIZE{1'b0}};
    x20_r <= {`DATA_SIZE{1'b0}};
    x21_r <= {`DATA_SIZE{1'b0}};
    x22_r <= {`DATA_SIZE{1'b0}};
    x23_r <= {`DATA_SIZE{1'b0}};
    x24_r <= {`DATA_SIZE{1'b0}};
    x25_r <= {`DATA_SIZE{1'b0}};
    x26_r <= {`DATA_SIZE{1'b0}};
    x27_r <= {`DATA_SIZE{1'b0}};
    x28_r <= {`DATA_SIZE{1'b0}};
    x29_r <= {`DATA_SIZE{1'b0}};
    x30_r <= {`DATA_SIZE{1'b0}};
    x31_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (rf_wr_1h[1]) x1_r <=  x1_nxt;
    if (rf_wr_1h[2]) x2_r <=  x2_nxt;
    if (rf_wr_1h[3]) x3_r <=  x3_nxt;
    if (rf_wr_1h[4]) x4_r <=  x4_nxt;
    if (rf_wr_1h[5]) x5_r <=  x5_nxt;
    if (rf_wr_1h[6]) x6_r <=  x6_nxt;
    if (rf_wr_1h[7]) x7_r <=  x7_nxt;
    if (rf_wr_1h[8]) x8_r <=  x8_nxt;
    if (rf_wr_1h[9]) x9_r <=  x9_nxt;
    if (rf_wr_1h[10]) x10_r <=  x10_nxt;
    if (rf_wr_1h[11]) x11_r <=  x11_nxt;
    if (rf_wr_1h[12]) x12_r <=  x12_nxt;
    if (rf_wr_1h[13]) x13_r <=  x13_nxt;
    if (rf_wr_1h[14]) x14_r <=  x14_nxt;
    if (rf_wr_1h[15]) x15_r <=  x15_nxt;
    if (rf_wr_1h[16]) x16_r <=  x16_nxt;
    if (rf_wr_1h[17]) x17_r <=  x17_nxt;
    if (rf_wr_1h[18]) x18_r <=  x18_nxt;
    if (rf_wr_1h[19]) x19_r <=  x19_nxt;
    if (rf_wr_1h[20]) x20_r <=  x20_nxt;
    if (rf_wr_1h[21]) x21_r <=  x21_nxt;
    if (rf_wr_1h[22]) x22_r <=  x22_nxt;
    if (rf_wr_1h[23]) x23_r <=  x23_nxt;
    if (rf_wr_1h[24]) x24_r <=  x24_nxt;
    if (rf_wr_1h[25]) x25_r <=  x25_nxt;
    if (rf_wr_1h[26]) x26_r <=  x26_nxt;
    if (rf_wr_1h[27]) x27_r <=  x27_nxt;
    if (rf_wr_1h[28]) x28_r <=  x28_nxt;
    if (rf_wr_1h[29]) x29_r <=  x29_nxt;
    if (rf_wr_1h[30]) x30_r <=  x30_nxt;
    if (rf_wr_1h[31]) x31_r <=  x31_nxt;
  end
end

assign sp_u = x2_r;

endmodule // rl_regfile

