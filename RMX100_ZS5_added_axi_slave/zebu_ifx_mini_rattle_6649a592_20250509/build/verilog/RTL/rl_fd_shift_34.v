// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright 2010-2023 Synopsys, Inc. All rights reserved.
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
// Description:
//
// FAST DIVIDER SUPPORT MODULE.
// 34-bit arithmetic shift left (dir = 0) or right (sign extended, dir = 1)
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a
//  command line such as:
//
//   vpp +q +o rl_fd_shift_34.vpp
//
// ===========================================================================
//
module rl_fd_shift_34 ( din, count, dir, dout );

input   [33:0]     din;       // 34-bit
input   [5:0]      count;     // actual number of bits to shift
input              dir;       // shift direction: 0 = left, 1 = right

output  [33:0]     dout;

reg     [33:0]     dout_ext;
wire    [33:0]     dout;

wire               sign_bit;

assign sign_bit  = din[33];

// Main logic for the barrel shifter

always @ (*)
begin : dout_ext_PROC

  casez ({dir, count})
  
   // LEFT
   
   7'b0_000001: dout_ext = {din[32:0],  1'h0};
   7'b0_000010: dout_ext = {din[31:0],  2'h0};
   7'b0_000011: dout_ext = {din[30:0],  3'h0};
   7'b0_000100: dout_ext = {din[29:0],  4'h0};
   7'b0_000101: dout_ext = {din[28:0],  5'h0};
   7'b0_000110: dout_ext = {din[27:0],  6'h0};
   7'b0_000111: dout_ext = {din[26:0],  7'h0};
   7'b0_001000: dout_ext = {din[25:0],  8'h0};
   7'b0_001001: dout_ext = {din[24:0],  9'h0};
   7'b0_001010: dout_ext = {din[23:0], 10'h0};
   7'b0_001011: dout_ext = {din[22:0], 11'h0};
   7'b0_001100: dout_ext = {din[21:0], 12'h0};
   7'b0_001101: dout_ext = {din[20:0], 13'h0};
   7'b0_001110: dout_ext = {din[19:0], 14'h0};
   7'b0_001111: dout_ext = {din[18:0], 15'h0};
   7'b0_010000: dout_ext = {din[17:0], 16'h0};
   7'b0_010001: dout_ext = {din[16:0], 17'h0};
   7'b0_010010: dout_ext = {din[15:0], 18'h0};
   7'b0_010011: dout_ext = {din[14:0], 19'h0};
   7'b0_010100: dout_ext = {din[13:0], 20'h0};
   7'b0_010101: dout_ext = {din[12:0], 21'h0};
   7'b0_010110: dout_ext = {din[11:0], 22'h0};
   7'b0_010111: dout_ext = {din[10:0], 23'h0};
   7'b0_011000: dout_ext = {din[ 9:0], 24'h0};
   7'b0_011001: dout_ext = {din[ 8:0], 25'h0};
   7'b0_011010: dout_ext = {din[ 7:0], 26'h0};
   7'b0_011011: dout_ext = {din[ 6:0], 27'h0};
   7'b0_011100: dout_ext = {din[ 5:0], 28'h0};
   7'b0_011101: dout_ext = {din[ 4:0], 29'h0};
   7'b0_011110: dout_ext = {din[ 3:0], 30'h0};
   7'b0_011111: dout_ext = {din[ 2:0], 31'h0};
   7'b0_100000: dout_ext = {din[ 1:0], 32'h0};
  
   // RIGHT
   
   7'b1_000001: dout_ext = {{ 1{sign_bit}},din[33: 1]};
   7'b1_000010: dout_ext = {{ 2{sign_bit}},din[33: 2]};
   7'b1_000011: dout_ext = {{ 3{sign_bit}},din[33: 3]};
   7'b1_000100: dout_ext = {{ 4{sign_bit}},din[33: 4]};
   7'b1_000101: dout_ext = {{ 5{sign_bit}},din[33: 5]};
   7'b1_000110: dout_ext = {{ 6{sign_bit}},din[33: 6]};
   7'b1_000111: dout_ext = {{ 7{sign_bit}},din[33: 7]};
   7'b1_001000: dout_ext = {{ 8{sign_bit}},din[33: 8]};
   7'b1_001001: dout_ext = {{ 9{sign_bit}},din[33: 9]};
   7'b1_001010: dout_ext = {{10{sign_bit}},din[33:10]};
   7'b1_001011: dout_ext = {{11{sign_bit}},din[33:11]};
   7'b1_001100: dout_ext = {{12{sign_bit}},din[33:12]};
   7'b1_001101: dout_ext = {{13{sign_bit}},din[33:13]};
   7'b1_001110: dout_ext = {{14{sign_bit}},din[33:14]};
   7'b1_001111: dout_ext = {{15{sign_bit}},din[33:15]};
   7'b1_010000: dout_ext = {{16{sign_bit}},din[33:16]};
   7'b1_010001: dout_ext = {{17{sign_bit}},din[33:17]};
   7'b1_010010: dout_ext = {{18{sign_bit}},din[33:18]};
   7'b1_010011: dout_ext = {{19{sign_bit}},din[33:19]};
   7'b1_010100: dout_ext = {{20{sign_bit}},din[33:20]};
   7'b1_010101: dout_ext = {{21{sign_bit}},din[33:21]};
   7'b1_010110: dout_ext = {{22{sign_bit}},din[33:22]};
   7'b1_010111: dout_ext = {{23{sign_bit}},din[33:23]};
   7'b1_011000: dout_ext = {{24{sign_bit}},din[33:24]};
   7'b1_011001: dout_ext = {{25{sign_bit}},din[33:25]};
   7'b1_011010: dout_ext = {{26{sign_bit}},din[33:26]};
   7'b1_011011: dout_ext = {{27{sign_bit}},din[33:27]};
   7'b1_011100: dout_ext = {{28{sign_bit}},din[33:28]};
   7'b1_011101: dout_ext = {{29{sign_bit}},din[33:29]};
   7'b1_011110: dout_ext = {{30{sign_bit}},din[33:30]};
   7'b1_011111: dout_ext = {{31{sign_bit}},din[33:31]};
   7'b1_100000: dout_ext = {{32{sign_bit}},din[33:32]};

   default:     dout_ext = din;
  endcase

end

assign dout = dout_ext[33:0];

endmodule   // rl_fd_shift_34
