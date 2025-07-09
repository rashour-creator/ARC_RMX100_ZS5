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
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// #     #  #######  ######   ######  ######        ###    ###   #     #  #   #
// #  #  #     #     #     #  #       #            #   #  #   #   #   #   #   #
// #  #  #     #     #     #  #       #                #  #   #    # #    #   #
// #  #  #     #     ######   ####    ####          ###      #      #     #####
// #  #  #     #     #   #    #       #                #    #      # #        #
// #  #  #     #     #    #   #       #            #   #   #      #   #       #
//  ## ##      #     #     #  ######  ######  ####  ###   #####  #     #      #
//
// ===========================================================================
//
// Description:
//
//  The 32x4 Wallace tree module implements a 32x4 combinational multiplier
//  for use by the multiply module.
//
//  The following instructions use this module:
//    MPY, MPYU, MPYHI, MPYHIU, MPYW, MPYWU
//
//  To support data-gating, for dynamic power reduction, the 'enb' signal
//  should be set to 1 when performing multiplication operations and 0 if not.
//
//  When enb == 0, the psum and pcarry outputs are guaranteed to be zero.
//
//  This file is formatted with 2-characters-per-tab indentation
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a
//  command line such as:
//
//   vpp +q +o wtree_32x4.vpp
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"

module rl_wtree_32x4 (
  input   [32:0]    a,          // input multiplicand
  input   [3:0]     b,          // input multiplier
  input             signed_op,  // 1 => signed, 0 => unsigned multiplication
  input             slice_0,    // 1 <=> first of eight 32x4 slice computations
  input             slice_7,    // 1 <=> last of eight 32x4 slice computations
  input             enb,        // power gating control for a[] and b[] inputs
  input   [33:0]    acc,        // accumulator input

  output  [36:0]    psum,       // partial sum output
  output  [36:0]    pcarry      // partial carry output
);


// Declare the gated multiplicands
//
wire      [31:0]    mcnd_0;     // b[0]  * a[30:0] / 2^0
wire      [31:0]    mcnd_1;     // b[1]  * a[30:0] / 2^1
wire      [31:0]    mcnd_2;     // b[2]  * a[30:0] / 2^2
wire      [33:0]    mcnd_3;     // b[3]  * a[30:0] / 2^3
wire      [4:0]     mcnd_4;     // a[31] * b[2:0]  / 2^31
wire      [1:0]     mcnd_5;     // a[31] * b[3]    / 2^34

// Declare the multiplicand carry-in signal for negation of
// a[30:0] when computing slice 7 and b[3] == 1 (i.e. negative).
//
wire                cin_a_3;

// Declare the multiplicand carry-in signal for negation of
// b[3:0] when a[31] == 1 (i.e. negative).
//
wire                cin_b_31;

// Declare the inter-column carry signals for the CSA tree.
//
wire      [36:2]    c1;         // inter-column CSA tree carry 1
wire      [33:3]    c2;         // inter-column CSA tree carry 2
wire      [32:32]   c3;         // inter-column CSA tree carry 3

// Declare the gated slice_7 and signed_op controls
//
wire                s7;         // slice_7 & enb
wire                sgnd;       // signed_op & enb

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// Compute the gated multiplicands                                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

// Compute the carry-in bits, cin_a_3 and cin_b_31, which are needed
// respectively for mcnd_4 and mcnd_3, when they are negated by a
// signed operation requiring bits a[31] and b[3] to be negative.
//
assign cin_a_3      = slice_7 & sgnd;
assign cin_b_31     = slice_0 & sgnd;

// Compute the data-gated versions of slice_7 and signed_op, which are always
// zero if enb is zero.
//
assign s7           = slice_7   & enb;
assign sgnd         = signed_op & enb;

// Compute the three unsigned partial products comprising b[2:0] x a[30:0]
//
assign mcnd_0[31:0] = {32{b[0] & enb}} & a[31:0]; // b[0] x a[30:0] (unsigned)
assign mcnd_1[31:0] = {32{b[1] & enb}} & a[31:0]; // b[1] x a[30:0] (unsigned)
assign mcnd_2[31:0] = {32{b[2] & enb}} & a[31:0]; // b[2] x a[30:0] (unsigned)

// Compute the partial product b[3] x a[30:0], which may be optionally
// signed during the final slice of an iterative multiply operation.
//
assign mcnd_3[33:0] = {2'b0, ({32{b[3] & enb}} & a[31:0])} ^ {34{cin_a_3}};

// Compute the optionally signed partial product a[31] x b[2:0]
//
assign mcnd_4[2:0]  = ({3{a[32] & enb}} & b[2:0]) ^ {3{sgnd}};

// mcnd_4[3] = a[31] x b[4*slice + 3], so if slice = 7 we must treat b[31]
// as the sign bit of b[]. For all other slices, it is simply a[31] x b[i],
// and must be inverted if performing signed multiplication.
//
assign mcnd_4[3]    = s7 ? sgnd : ((a[32] & b[3] & enb) ^ sgnd);

// mcnd_4[4] is normally zero, but for slice 7 must be inverted as part
// of the negation of mcnd_4.
//
assign mcnd_4[4]    = (s7 & sgnd);

// Compute the (always positive) partial product a[31] x b[31]
//
assign mcnd_5[1:0] = {1'b0, (a[32] & b[3] & s7)};

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// Combine the gated multiplicands in a carry-save adder tree                //
//                                                                           //
// In total there are 95 full adders and 5 half adders in this CSA tree.     //
// No path through the tree traverses more than 3 full adders.               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

assign { pcarry[0], psum[0]} = acc[0] + mcnd_0[0];

rl_wtree_comp302 u_csa_col1(
  .x1     (acc[1]     ),
  .x2     (mcnd_0[1]  ),
  .x3     (mcnd_1[0]  ),
  .s      (psum[1]    ),
  .c      (pcarry[1]  )
);

rl_wtree_comp402 u_csa_col2(
  .x1     (acc[2]     ),
  .x2     (mcnd_0[2]  ),
  .x3     (mcnd_1[1]  ),
  .x4     (mcnd_2[0]  ),
  .s      (psum[2]    ),
  .c      (pcarry[2]  ),
  .co1    (c1[2]      )
);

rl_wtree_comp612 u_csa_col3(
  .x1     (acc[3]     ),
  .x2     (mcnd_0[3]  ),
  .x3     (mcnd_1[2]  ),
  .x4     (mcnd_2[1]  ),
  .x5     (mcnd_3[0]  ),
  .x6     (cin_a_3    ),
  .ci1    (c1[2]      ),
  .s      (psum[3]    ),
  .c      (pcarry[3]  ),
  .co1    (c1[3]      ),
  .co2    (c2[3]      )
);

rl_wtree_comp522 u_csa_col4(
  .x1     (acc[4]     ),
  .x2     (mcnd_0[4]  ),
  .x3     (mcnd_1[3]  ),
  .x4     (mcnd_2[2]  ),
  .x5     (mcnd_3[1]  ),
  .ci1    (c1[3]      ),
  .ci2    (c2[3]      ),
  .s      (psum[4]    ),
  .c      (pcarry[4]  ),
  .co1    (c1[4]      ),
  .co2    (c2[4]      )
);

rl_wtree_comp522 u_csa_col5(
  .x1     (acc[5]     ),
  .x2     (mcnd_0[5]  ),
  .x3     (mcnd_1[4]  ),
  .x4     (mcnd_2[3]  ),
  .x5     (mcnd_3[2]  ),
  .ci1    (c1[4]      ),
  .ci2    (c2[4]      ),
  .s      (psum[5]    ),
  .c      (pcarry[5]  ),
  .co1    (c1[5]      ),
  .co2    (c2[5]      )
);

rl_wtree_comp522 u_csa_col6(
  .x1     (acc[6]     ),
  .x2     (mcnd_0[6]  ),
  .x3     (mcnd_1[5]  ),
  .x4     (mcnd_2[4]  ),
  .x5     (mcnd_3[3]  ),
  .ci1    (c1[5]      ),
  .ci2    (c2[5]      ),
  .s      (psum[6]    ),
  .c      (pcarry[6]  ),
  .co1    (c1[6]      ),
  .co2    (c2[6]      )
);

rl_wtree_comp522 u_csa_col7(
  .x1     (acc[7]     ),
  .x2     (mcnd_0[7]  ),
  .x3     (mcnd_1[6]  ),
  .x4     (mcnd_2[5]  ),
  .x5     (mcnd_3[4]  ),
  .ci1    (c1[6]      ),
  .ci2    (c2[6]      ),
  .s      (psum[7]    ),
  .c      (pcarry[7]  ),
  .co1    (c1[7]      ),
  .co2    (c2[7]      )
);

rl_wtree_comp522 u_csa_col8(
  .x1     (acc[8]     ),
  .x2     (mcnd_0[8]  ),
  .x3     (mcnd_1[7]  ),
  .x4     (mcnd_2[6]  ),
  .x5     (mcnd_3[5]  ),
  .ci1    (c1[7]      ),
  .ci2    (c2[7]      ),
  .s      (psum[8]    ),
  .c      (pcarry[8]  ),
  .co1    (c1[8]      ),
  .co2    (c2[8]      )
);

rl_wtree_comp522 u_csa_col9(
  .x1     (acc[9]     ),
  .x2     (mcnd_0[9]  ),
  .x3     (mcnd_1[8]  ),
  .x4     (mcnd_2[7]  ),
  .x5     (mcnd_3[6]  ),
  .ci1    (c1[8]      ),
  .ci2    (c2[8]      ),
  .s      (psum[9]    ),
  .c      (pcarry[9]  ),
  .co1    (c1[9]      ),
  .co2    (c2[9]      )
);

rl_wtree_comp522 u_csa_col10(
  .x1     (acc[10]     ),
  .x2     (mcnd_0[10]  ),
  .x3     (mcnd_1[9]  ),
  .x4     (mcnd_2[8]  ),
  .x5     (mcnd_3[7]  ),
  .ci1    (c1[9]      ),
  .ci2    (c2[9]      ),
  .s      (psum[10]    ),
  .c      (pcarry[10]  ),
  .co1    (c1[10]      ),
  .co2    (c2[10]      )
);

rl_wtree_comp522 u_csa_col11(
  .x1     (acc[11]     ),
  .x2     (mcnd_0[11]  ),
  .x3     (mcnd_1[10]  ),
  .x4     (mcnd_2[9]  ),
  .x5     (mcnd_3[8]  ),
  .ci1    (c1[10]      ),
  .ci2    (c2[10]      ),
  .s      (psum[11]    ),
  .c      (pcarry[11]  ),
  .co1    (c1[11]      ),
  .co2    (c2[11]      )
);

rl_wtree_comp522 u_csa_col12(
  .x1     (acc[12]     ),
  .x2     (mcnd_0[12]  ),
  .x3     (mcnd_1[11]  ),
  .x4     (mcnd_2[10]  ),
  .x5     (mcnd_3[9]  ),
  .ci1    (c1[11]      ),
  .ci2    (c2[11]      ),
  .s      (psum[12]    ),
  .c      (pcarry[12]  ),
  .co1    (c1[12]      ),
  .co2    (c2[12]      )
);

rl_wtree_comp522 u_csa_col13(
  .x1     (acc[13]     ),
  .x2     (mcnd_0[13]  ),
  .x3     (mcnd_1[12]  ),
  .x4     (mcnd_2[11]  ),
  .x5     (mcnd_3[10]  ),
  .ci1    (c1[12]      ),
  .ci2    (c2[12]      ),
  .s      (psum[13]    ),
  .c      (pcarry[13]  ),
  .co1    (c1[13]      ),
  .co2    (c2[13]      )
);

rl_wtree_comp522 u_csa_col14(
  .x1     (acc[14]     ),
  .x2     (mcnd_0[14]  ),
  .x3     (mcnd_1[13]  ),
  .x4     (mcnd_2[12]  ),
  .x5     (mcnd_3[11]  ),
  .ci1    (c1[13]      ),
  .ci2    (c2[13]      ),
  .s      (psum[14]    ),
  .c      (pcarry[14]  ),
  .co1    (c1[14]      ),
  .co2    (c2[14]      )
);

rl_wtree_comp522 u_csa_col15(
  .x1     (acc[15]     ),
  .x2     (mcnd_0[15]  ),
  .x3     (mcnd_1[14]  ),
  .x4     (mcnd_2[13]  ),
  .x5     (mcnd_3[12]  ),
  .ci1    (c1[14]      ),
  .ci2    (c2[14]      ),
  .s      (psum[15]    ),
  .c      (pcarry[15]  ),
  .co1    (c1[15]      ),
  .co2    (c2[15]      )
);

rl_wtree_comp522 u_csa_col16(
  .x1     (acc[16]     ),
  .x2     (mcnd_0[16]  ),
  .x3     (mcnd_1[15]  ),
  .x4     (mcnd_2[14]  ),
  .x5     (mcnd_3[13]  ),
  .ci1    (c1[15]      ),
  .ci2    (c2[15]      ),
  .s      (psum[16]    ),
  .c      (pcarry[16]  ),
  .co1    (c1[16]      ),
  .co2    (c2[16]      )
);

rl_wtree_comp522 u_csa_col17(
  .x1     (acc[17]     ),
  .x2     (mcnd_0[17]  ),
  .x3     (mcnd_1[16]  ),
  .x4     (mcnd_2[15]  ),
  .x5     (mcnd_3[14]  ),
  .ci1    (c1[16]      ),
  .ci2    (c2[16]      ),
  .s      (psum[17]    ),
  .c      (pcarry[17]  ),
  .co1    (c1[17]      ),
  .co2    (c2[17]      )
);

rl_wtree_comp522 u_csa_col18(
  .x1     (acc[18]     ),
  .x2     (mcnd_0[18]  ),
  .x3     (mcnd_1[17]  ),
  .x4     (mcnd_2[16]  ),
  .x5     (mcnd_3[15]  ),
  .ci1    (c1[17]      ),
  .ci2    (c2[17]      ),
  .s      (psum[18]    ),
  .c      (pcarry[18]  ),
  .co1    (c1[18]      ),
  .co2    (c2[18]      )
);

rl_wtree_comp522 u_csa_col19(
  .x1     (acc[19]     ),
  .x2     (mcnd_0[19]  ),
  .x3     (mcnd_1[18]  ),
  .x4     (mcnd_2[17]  ),
  .x5     (mcnd_3[16]  ),
  .ci1    (c1[18]      ),
  .ci2    (c2[18]      ),
  .s      (psum[19]    ),
  .c      (pcarry[19]  ),
  .co1    (c1[19]      ),
  .co2    (c2[19]      )
);

rl_wtree_comp522 u_csa_col20(
  .x1     (acc[20]     ),
  .x2     (mcnd_0[20]  ),
  .x3     (mcnd_1[19]  ),
  .x4     (mcnd_2[18]  ),
  .x5     (mcnd_3[17]  ),
  .ci1    (c1[19]      ),
  .ci2    (c2[19]      ),
  .s      (psum[20]    ),
  .c      (pcarry[20]  ),
  .co1    (c1[20]      ),
  .co2    (c2[20]      )
);

rl_wtree_comp522 u_csa_col21(
  .x1     (acc[21]     ),
  .x2     (mcnd_0[21]  ),
  .x3     (mcnd_1[20]  ),
  .x4     (mcnd_2[19]  ),
  .x5     (mcnd_3[18]  ),
  .ci1    (c1[20]      ),
  .ci2    (c2[20]      ),
  .s      (psum[21]    ),
  .c      (pcarry[21]  ),
  .co1    (c1[21]      ),
  .co2    (c2[21]      )
);

rl_wtree_comp522 u_csa_col22(
  .x1     (acc[22]     ),
  .x2     (mcnd_0[22]  ),
  .x3     (mcnd_1[21]  ),
  .x4     (mcnd_2[20]  ),
  .x5     (mcnd_3[19]  ),
  .ci1    (c1[21]      ),
  .ci2    (c2[21]      ),
  .s      (psum[22]    ),
  .c      (pcarry[22]  ),
  .co1    (c1[22]      ),
  .co2    (c2[22]      )
);

rl_wtree_comp522 u_csa_col23(
  .x1     (acc[23]     ),
  .x2     (mcnd_0[23]  ),
  .x3     (mcnd_1[22]  ),
  .x4     (mcnd_2[21]  ),
  .x5     (mcnd_3[20]  ),
  .ci1    (c1[22]      ),
  .ci2    (c2[22]      ),
  .s      (psum[23]    ),
  .c      (pcarry[23]  ),
  .co1    (c1[23]      ),
  .co2    (c2[23]      )
);

rl_wtree_comp522 u_csa_col24(
  .x1     (acc[24]     ),
  .x2     (mcnd_0[24]  ),
  .x3     (mcnd_1[23]  ),
  .x4     (mcnd_2[22]  ),
  .x5     (mcnd_3[21]  ),
  .ci1    (c1[23]      ),
  .ci2    (c2[23]      ),
  .s      (psum[24]    ),
  .c      (pcarry[24]  ),
  .co1    (c1[24]      ),
  .co2    (c2[24]      )
);

rl_wtree_comp522 u_csa_col25(
  .x1     (acc[25]     ),
  .x2     (mcnd_0[25]  ),
  .x3     (mcnd_1[24]  ),
  .x4     (mcnd_2[23]  ),
  .x5     (mcnd_3[22]  ),
  .ci1    (c1[24]      ),
  .ci2    (c2[24]      ),
  .s      (psum[25]    ),
  .c      (pcarry[25]  ),
  .co1    (c1[25]      ),
  .co2    (c2[25]      )
);

rl_wtree_comp522 u_csa_col26(
  .x1     (acc[26]     ),
  .x2     (mcnd_0[26]  ),
  .x3     (mcnd_1[25]  ),
  .x4     (mcnd_2[24]  ),
  .x5     (mcnd_3[23]  ),
  .ci1    (c1[25]      ),
  .ci2    (c2[25]      ),
  .s      (psum[26]    ),
  .c      (pcarry[26]  ),
  .co1    (c1[26]      ),
  .co2    (c2[26]      )
);

rl_wtree_comp522 u_csa_col27(
  .x1     (acc[27]     ),
  .x2     (mcnd_0[27]  ),
  .x3     (mcnd_1[26]  ),
  .x4     (mcnd_2[25]  ),
  .x5     (mcnd_3[24]  ),
  .ci1    (c1[26]      ),
  .ci2    (c2[26]      ),
  .s      (psum[27]    ),
  .c      (pcarry[27]  ),
  .co1    (c1[27]      ),
  .co2    (c2[27]      )
);

rl_wtree_comp522 u_csa_col28(
  .x1     (acc[28]     ),
  .x2     (mcnd_0[28]  ),
  .x3     (mcnd_1[27]  ),
  .x4     (mcnd_2[26]  ),
  .x5     (mcnd_3[25]  ),
  .ci1    (c1[27]      ),
  .ci2    (c2[27]      ),
  .s      (psum[28]    ),
  .c      (pcarry[28]  ),
  .co1    (c1[28]      ),
  .co2    (c2[28]      )
);

rl_wtree_comp522 u_csa_col29(
  .x1     (acc[29]     ),
  .x2     (mcnd_0[29]  ),
  .x3     (mcnd_1[28]  ),
  .x4     (mcnd_2[27]  ),
  .x5     (mcnd_3[26]  ),
  .ci1    (c1[28]      ),
  .ci2    (c2[28]      ),
  .s      (psum[29]    ),
  .c      (pcarry[29]  ),
  .co1    (c1[29]      ),
  .co2    (c2[29]      )
);

rl_wtree_comp522 u_csa_col30(
  .x1     (acc[30]     ),
  .x2     (mcnd_0[30]  ),
  .x3     (mcnd_1[29]  ),
  .x4     (mcnd_2[28]  ),
  .x5     (mcnd_3[27]  ),
  .ci1    (c1[29]      ),
  .ci2    (c2[29]      ),
  .s      (psum[30]    ),
  .c      (pcarry[30]  ),
  .co1    (c1[30]      ),
  .co2    (c2[30]      )
);

rl_wtree_comp522 u_csa_col31(
  .x1     (acc[31]     ),
  .x2     (mcnd_0[31]  ),
  .x3     (mcnd_1[30]  ),
  .x4     (mcnd_2[29]  ),
  .x5     (mcnd_3[28]  ),
  .ci1    (c1[30]      ),
  .ci2    (c2[30]      ),
  .s      (psum[31]    ),
  .c      (pcarry[31]  ),
  .co1    (c1[31]      ),
  .co2    (c2[31]      )
);


rl_wtree_comp622 u_csa_col32(
  .x1     (acc[32]    ),
  .x2     (mcnd_1[31] ),
  .x3     (mcnd_2[30] ),
  .x4     (mcnd_3[29] ),
  .x5     (mcnd_4[0]  ),
  .x6     (cin_b_31   ),
  .ci1    (c1[31]     ),
  .ci2    (c2[31]     ),
  .s      (psum[32]   ),
  .c      (pcarry[32] ),
  .co1    (c1[32]     ),
  .co2    (c2[32]     ),
  .co3    (c3[32]     )
);

rl_wtree_comp432 u_csa_col33(
  .x1     (acc[33]),
  .x2     (mcnd_2[31] ),
  .x3     (mcnd_3[30] ),
  .x4     (mcnd_4[1]  ),
  .ci1    (c1[32]     ),
  .ci2    (c2[32]     ),
  .ci3    (c3[32]     ),
  .s      (psum[33]   ),
  .c      (pcarry[33] ),
  .co1    (c1[33]     ),
  .co2    (c2[33]     )
);

rl_wtree_comp222 u_csa_col34(
  .x1     (mcnd_3[31] ),
  .x2     (mcnd_4[2]  ),
  .ci1    (c1[33]     ),
  .ci2    (c2[33]     ),
  .s      (psum[34]   ),
  .c      (pcarry[34] ),
  .co1    (c1[34]     )
);

rl_wtree_comp312 u_csa_col35(
  .x1     (mcnd_3[32] ),
  .x2     (mcnd_4[3]  ),
  .x3     (mcnd_5[0]  ),
  .ci1    (c1[34]     ),
  .s      (psum[35]   ),
  .c      (pcarry[35] ),
  .co1    (c1[35]     )
);

rl_wtree_comp312 u_csa_col36(
  .x1     (mcnd_3[33] ),
  .x2     (mcnd_4[4]  ),
  .x3     (mcnd_5[1]  ),
  .ci1    (c1[35]     ),
  .s      (psum[36]   ),
  .c      (pcarry[36] ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ : Redundant bit, not used
  .co1    (c1[36]     )
// spyglass enable_block UnloadedOutTerm-ML
);

endmodule
