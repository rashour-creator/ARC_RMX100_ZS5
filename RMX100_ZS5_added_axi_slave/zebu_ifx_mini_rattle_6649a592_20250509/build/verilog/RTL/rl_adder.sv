
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2013 Synopsys, Inc. All rights reserved.
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
//  ####        #       #                                                #
// #    #       #       #                                          #     #
// #    #       #       #                                                #
// #    #       #       #          #####         #    #  # ###    ##    ####
// ######   #####   #####   ####   #    #        #    #  ##   #    #     #
// #    #  #    #  #    #  #    #  #             #    #  #    #    #     #
// #    #  #    #  #    #  #####   #             #    #  #    #    #     #
// #    #  #    #  #    #  #       #             #   ##  #    #    #     #  #
// #    #   #####   #####   ####   #              ### #  #    #  #####    ##
//
// ===========================================================================
//
// Description:
//
//  This module implements the Adder Unit within the ALU.
// ===========================================================================
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"
`include "mpy_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_adder #(
  parameter   SIMD = 1,                        // Number of parallel slices for packed-SIMD operations.
  localparam  MIN_SEW = `DATA_SIZE/SIMD,       // Smallest SEW supported for SIMD/RVV operations.
  localparam  NUM_VARIANTS = $clog2(SIMD)      // Number of SIMD operation variants, excluding scalar.
)(
  ////////// Operands //////////////////////////////////////////////////////
  //
  input          [`DATA_RANGE]   src0,         // source operand 0
  input          [`DATA_RANGE]   src1,         // source operand 1, already inverted in case of subtract

  ////////// Control signals ///////////////////////////////////////////////
  //
  input                          force_cin,    // force a +1 on cin in case of a SUB operator
  input                  [3:1]   src0_shx_ctl, // Fused-shift-add control, 1-hot endocded.
  ////////// Adder unit ouptuts ////////////////////////////////////////////
  //
  output  reg    [`DATA_RANGE]   result        // Adder result
);

localparam u0 = MIN_SEW;
localparam u1 = u0 - 1;
localparam u2 = u0 - 2;
localparam u3 = u0 - 3;

logic    [MIN_SEW-1:0]  slice_src0[SIMD];
logic    [MIN_SEW-1:0]  slice_src1[SIMD];
logic                   slice_cin[SIMD];
logic    [MIN_SEW-1:0]  slice_result[SIMD];
logic                   slice_cout[SIMD];


//==========================================================================
// Prepare SIMD slice inputs
//
generate
  for (genvar i=0; i<SIMD; i++)
  begin: simd_slice_inputs

if (i == 0)
    assign slice_src0[i] = ( {u0{!(|src0_shx_ctl) }} &  src0[i*u0 +: u0]       )
                         | ( {u0{  src0_shx_ctl[1]}} & {src0[i*u0 +: u1], 1'b0} )
                         | ( {u0{  src0_shx_ctl[2]}} & {src0[i*u0 +: u2], 2'b00} )
                         | ( {u0{  src0_shx_ctl[3]}} & {src0[i*u0 +: u3], 3'b000} );
else
    assign slice_src0[i] = ( {u0{!(|src0_shx_ctl) }} & src0[i*u0 +: u0])
                         | ( {u0{  src0_shx_ctl[1]}} & src0[i*u1 +: u0])
                         | ( {u0{  src0_shx_ctl[2]}} & src0[i*u2 +: u0])
                         | ( {u0{  src0_shx_ctl[3]}} & src0[i*u3 +: u0]);
    assign slice_src1[i] = src1[i*u0 +: u0];

    // Without RV_UDSP_OPTION, there should be only 1 slice and it takes
    // force_cin as carry-in.
    assign slice_cin[i] = force_cin;
  end
endgenerate

//==========================================================================
// Calculate sums and carry-outs using inferred adders.
//
generate
  for (genvar i=0; i<SIMD; i++)
  begin: sum_and_carry
    logic discard;
    assign {discard, slice_cout[i], slice_result[i]} = slice_src0[i] + slice_src1[i] + slice_cin[i];

  end
endgenerate

//==========================================================================
// Map SIMD slice-resuls to result port.
//
always @*
begin: alu_result_PROC
  for (int i=0; i<SIMD; i++)
    result[i*MIN_SEW +: MIN_SEW] = slice_result[i];

end // alu_result_PROC

endmodule
