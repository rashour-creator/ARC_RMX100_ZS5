// Library ARCv5EM-3.5.999999999
////////////////////////////////////////////////////////////////////////////////
//
//                  (C) COPYRIGHT 2006 - 2024 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
//  The entire notice above must be reproduced on all authorized copies.
//
// Description : DWbb_bcm00_maj.v Verilog module for DWbb
//
// DesignWare IP ID: 9d31356c
//
////////////////////////////////////////////////////////////////////////////////


module DWbb_bcm00_maj (
    a,
    b,
    c,
    z
    );

parameter integer WIDTH        = 1;  // RANGE 1 to 8192


input  [WIDTH-1:0]      a;    // 1st voter data input bus
input  [WIDTH-1:0]      b;    // 2nd voter data input bus
input  [WIDTH-1:0]      c;    // 3rd voter data input bus
output [WIDTH-1:0]      z;    // majority voted data output bus

// spyglass disable_block Ac_conv01
// SMD: Synchronized sequential element(s) converge on combinational logic
// SJ: The single-bit signals converging into sequential elements are triplicated from the same signal at the source and run through parallel paths of synchronizers with the identical number of stages.  This synchronized convergence is intentional and directly supplies combinational logic that produces a majority vote result which is immune to non-gray code transitions.
// spyglass disable_block Ac_conv02
// SMD: Synchronizers converge on combinational logic
// SJ: The single-bit signals converging into the combinational logic are triplicated from the same signal at the source and run through parallel paths of synchronizers with the identical number of stages.  This synchronized convergence is intentional as the combinational logic produces a majority vote result which is immune to non-gray code transitions.
  assign z = (a & b) | (a & c) | (b & c);
// spyglass enable_block Ac_conv01
// spyglass enable_block Ac_conv02

endmodule
