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
//   ###   #                ###    #
//  #   #  #         #     #   #   #
//  #      #               #       #
//  #      # ###    ##     #      ####    ####   # ##
//   ###   ##   #    #    ####     #     #    #   #
//      #  #    #    #     #       #     ######   #
//      #  #    #    #     #       #     #        #
//  #   #  #    #    #     #       #  #  #    #   #
//   ###   #    #  #####   #        ##    ####    #
//
// ===========================================================================
//
// Description:
//
//  The shifter module is a 32-bit barrel shifter capable of performing
//  the shift and rotate operations :
//        SLL, SLLI   - logical shift left
//        SRL, SRLI   - logical shift right
//        SRA, SRAI   - arithmetic shift right
//        ROL         - rotate left
//        ROR, RORI   - rotate right
//        BEXT, BEXTI - extract bit field
//
//  The extended arithmetic shift operations are not implemented in
//  this design (i.e. no support for saturating shifts or for signed
//  shift distances).
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_shifter #(
  parameter   SIMD = 1,                        // Number of parallel slices for packed-SIMD operations.
  localparam  MIN_SEW = `DATA_SIZE/SIMD,       // Smallest SEW supported for SIMD/RVV operations.
  localparam  NUM_VARIANTS = $clog2(SIMD)      // Number of SIMD operation variants, excluding scalar.
)(
  ////////// Input operands ////////////////////////////////////////////////
  //
  input   [`DATA_RANGE]     src0,       // src0 (value to be shifted)
  input   [`DATA_RANGE]     src1_s6,    // src1[5:0] (shift distance)

  ////////// Control inputs ////////////////////////////////////////////////
  //
  input                     arith,      // perform arithmetic shift (only for left==1'b0)
  input                     left,       // perform left shift
  input                     rotate,     // perform rotation
  input                     bext_op,    // BEXT operation

  ////////// Result and status values //////////////////////////////////////
  //
  output reg [`DATA_RANGE]  result      // Shifter result
);

//==========================================================================
//==========================================================================


//==========================================================================
// Construct a pre-processed input-vector for each of the supported SIMD widths.
// A shift distance is similarly computed seperately for each variant, as the
// number of bit from src1_6 that should be used to compute it depends on SEW.
// Entry [NUM_VARIANTS] in these vectors correspond to the scalar variant.
//
// For left-shifts we compute the equivalent right-shift distance, but by
// only negated the value we also undershoots the required distance by 1.
// "left" and "nclip_op" are mutually-exclusive, and in both cases the
// off-by-1 shift-distance is corrected in the output stage.
//
logic               [4:0]  dist_simd[NUM_VARIANTS+1]; // Computed distances.
logic  [2*`DATA_SIZE-1:0]  data_simd[NUM_VARIANTS+1]; // Constructed data-variants

generate
  for (genvar i=0; i<NUM_VARIANTS+1; i++)
  begin: dist_sew
    localparam SLICES = 2**i;
    localparam SEW = SLICES * MIN_SEW;
    localparam NUM_ELEM = `DATA_SIZE / SEW;
    localparam SEW_SIZE = $clog2(SEW);

    logic [SEW_SIZE-1:0] dist_sew, dist_sew_inv;
    assign dist_sew = src1_s6[SEW_SIZE-1:0];
    assign dist_sew_inv = ~dist_sew;
    // Invert shift-distance in case of a left-shift. Only inverting undershoots the distance by 1 (on purpose).
    // A bitrev instruction is implemented with a right-shift after reversing the SEW-bit element to return only
    // the src1 lsbs in reversed order. The amount to right-shift by is SEW-src0, which we approximate by inverting
    // the distance, undershooting by 1.
    assign dist_simd[i] = (left 

                            ) ? dist_sew_inv :
                                                dist_sew;

    always @*
    begin
      logic      [SEW-1:0] elem;
      logic                s;

      for (int j=0; j<NUM_ELEM; j++)
      begin
        elem       = src0[j*SEW +: SEW];
        s          = arith && elem[SEW-1];

        data_simd[i][2*j*SEW +: 2*SEW] =
          rotate    ? {    elem, elem} :
          left      ? {    elem, {SEW{1'b0}}} :
                      {{SEW{s}}, elem};
      end
    end
  end
endgenerate

//==========================================================================
// Select the initial input vector and shift-distance according to the type
// of operation.
//

logic               [4:0]  dist_in;  // shift-distance input to the right-shift
logic  [2*`DATA_SIZE-1:0]  stage_in; // data input to the right-shift
logic                      off_by_1; // Signal to record that for the selected
                                     // operation the computed shift-distance
                                     // is currently off by 1.
always @*
begin
  // Intialize with the vector and distance that correspond to a scalar shift.
  dist_in   = dist_simd[NUM_VARIANTS];
  stage_in  = data_simd[NUM_VARIANTS];
  // Shift-distane for scalar left-shifts is off by 1.
  off_by_1  = left;
end

//==========================================================================
// Perform the shift using an inferred shifter.
//
logic  [2*`DATA_SIZE-1:0]  stage_out;    // this is the output stage
assign stage_out = stage_in >> dist_in;

//==========================================================================
// Collect results for the different SIMD variants.
//
logic  [`DATA_SIZE-1:0]  result_variants[NUM_VARIANTS+1];
generate
  for (genvar i=0; i<NUM_VARIANTS+1; i++)
  begin
    localparam SLICES = 2**i;
    localparam SEW = SLICES * MIN_SEW;
    localparam NUM_ELEM = `DATA_SIZE / SEW;
    localparam SEW_SIZE = $clog2(SEW);

    always @*
    begin
      logic  [SEW-2:0]  data, discard;
      logic             s, half_lsb;
      logic  [SEW-1:0]  elem;

      for (int j=0; j<NUM_ELEM; j++)
      begin
        // half_lsb is discarded (left) or used for rounding (nclip).
        {discard, s, data, half_lsb} = off_by_1 ?  stage_out[2*j*SEW +: 2*SEW] :
        // If this is not a left or nclip op, shifted results are aligned to 2*SEW boundaries.
                                                  {stage_out[2*j*SEW +: 2*SEW-1], 1'b0};

        elem =
        // BEXT only returns the lsb of every shifted element.
                   bext_op ? data[0] :
        // For other operations we recombine with the sign_bit.
                             {s, data};

        result_variants[i][j*SEW +: SEW] = elem;
      end
    end
  end
endgenerate

//==========================================================================
// Mux out the final result.
//
logic clip_l, clip_m;
always @*
begin
  result = result_variants[NUM_VARIANTS];
end

endmodule
