// Library safety-1.1.999999999
////////////////////////////////////////////////////////////////////////////////
//
//                  (C) COPYRIGHT 2015 - 2020 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
//  The entire notice above must be reproduced on all authorized copies.
//
// Filename    : DWbb_bcm99_n.v
// Revision    : $Id: $
// Author      : Liming SU    10/23/15
// Description : DWbb_bcm99_n.v Verilog module for DWbb
//
// DesignWare IP ID: 6c105232
//
////////////////////////////////////////////////////////////////////////////////
// spyglass disable_block Ar_glitch01
// SMD: Signal driving clear pin of the flop has glitch
// SJ: source is coming from the recirculation stage of the synchronizer, this warning can be ignored.

module DWbb_bcm99_n (
  clk_d,
  rst_d_n,
  data_s,
  data_d
);

parameter ACCURATE_MISSAMPLING = 0; // RANGE 0 to 1

input  clk_d;      // clock input from destination domain
input  rst_d_n;    // active low asynchronous reset from destination domain
input  data_s;     // data to be synchronized from source domain
output data_d;     // data synchronized to destination domain

localparam WIDTH = 1;

wire data_meta;

//############################### NOTE ABOUT TECHNOLOGY CELL MAPPING ##################################
// Replace code between "NEG_EDGE TRIGGERED SYNCHRONIZER BEGIN" and "NEG_EDGE TRIGGERED SYNCHRONIZER END"
// with a customized negative-edge triggered register cell with an instance name
// that must be "sample_meta_n".
//
// Replace code between "POS_EDGE TRIGGERED SYNCHRONIZER BEGIN" and "POS_EDGE TRIGGERED SYNCHRONIZER END"
// with your customized positive-edge triggered register cell with an instance name
// that must be "sample_syncl".
//
// Here's an example of replacing both "sample_meta_n" and "sample_syncl" RTL into GTECH instances:
//   wire  n1, n2;
//   GTECH_NOT U11 ( .A(clk_d), .Z(n1) );
//   GTECH_FD2 sample_meta_n ( .D(data_s), .CP(n1), .CD(rst_d_n), .Q(n2) );
//   GTECH_FD2 sample_syncl ( .D(n2), .CP(clk_d), .CD(rst_d_n), .Q(data_d) );
//
//############################# END NOTE ABOUT TECHNOLOGY CELL MAPPING ################################
// NEG_EDGE TRIGGERED SYNCHRONIZER BEGIN
reg  sample_meta_n;
// spyglass disable_block Clock_check04
// SMD: Use rising edge flipflop
// SJ: The module was intentionally implemented to use negative edge clocking flip-flops cells.
// spyglass disable_block Clock_check06a
// SMD: Reports unexpected cells found in a clock tree
// SJ: The module was intentionally implemented to use negative edge clocking flip-flops cells.
always @(negedge clk_d or negedge rst_d_n) begin : a1000_PROC
// spyglass enable_block Clock_check06a
// spyglass enable_block Clock_check04
// spyglass disable_block Reset_sync02 Reset_check07
// SMD: Asynchronous resets that are synchronized more than once in the same clock domain
// SJ: Spyglass recognizes every multi-flop synchronizer as a reset synchronizer.
  if (!rst_d_n)
    sample_meta_n <= 1'b0;
// spyglass enable_block Reset_sync02 Reset_check07
  else
// spyglass disable_block W391
// SMD: Design has a clock driving it on both edges
// SJ: This module is configured such that both edges of the same clock are used for different flip-flops.
// spyglass disable_block Reset_sync04 
// SMD: Asynchronous resets that are synchronized more than once in the same clock domain
// SJ: Spyglass recognizes every multi-flop synchronizer as a reset synchronizer, hence any design with a reset that feeds more than one synchronizer gets reported as violating this rule. This rule is waivered temporarily.
// spyglass disable_block Ac_glitch03 Ac_glitch01 Ar_asyncdeassert01 Ar_unsync01
// SMD: Destination flop can glitch
// SJ:  glitch won't cause any issue after the synchronizer
// spyglass disable_block Ac_cdc01a
// SMD: Fast clock to slow clock crossing
// SJ:  No issues, handled by design
    sample_meta_n <= data_s;
// spyglass enable_block Ac_cdc01a
// spyglass enable_block Ac_glitch03 Ac_glitch01 Ar_asyncdeassert01 Ar_unsync01
// spyglass enable_block W391
// spyglass enable_block Reset_sync04
end
assign data_meta = sample_meta_n;
// NEG_EDGE TRIGGERED SYNCHRONIZER END

// POS TRIGGERED SYNCHRONIZER BEGIN
reg  sample_syncl;
always @(posedge clk_d or negedge rst_d_n) begin : a1001_PROC
  if (!rst_d_n)
    sample_syncl <= 1'b0;
  else
// spyglass disable_block W402b
// SMD: gated or internally generated
// SJ:  design on purpose
    sample_syncl <= data_meta;
// spyglass enable_block W402b
end
assign data_d = sample_syncl;
// POS TRIGGERED SYNCHRONIZER END

endmodule
// spyglass enable_block Ar_glitch01
