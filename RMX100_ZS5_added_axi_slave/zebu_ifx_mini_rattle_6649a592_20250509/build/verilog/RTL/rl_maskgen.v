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
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// #     #                  #
// ##   ##                  #
// # # # #                  #
// #  #  #   ####    ####   #   #    ### #   ####   # ###
// #     #       #  #    #  #  #    #   #   #    #  ##   #
// #     #   #####   ##     ###     #   #   ######  #    #
// #     #  #    #     ##   #  #     ###    #       #    #
// #     #  #   ##  #    #  #   #   #       #    #  #    #
// #     #   ### #   ####   #    #   ####    ####   #    #
//                                  #    #
//                                   ####
//
// ===========================================================================
//
// Description:
//
//  The maskgen module is used to create a bit mask for use by instructions
//  that require such a bit-mask as an operand for logical operations.
//
//  The following instructions use this module:
//    BCLR, BSET, BTST, BBIT, BXOR, BMSK, BMSKN
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_maskgen (
  ////////// Operands //////////////////////////////////////////////////////
  //
  input   [4:0]             src2_val,     // Source operand 2, bits 0 to 4
  input                     bit_op,       // src2 is a bit select operand
  input                     mask_op,      // src2 should create a mask
  input                     inv_mask,     // mask should be inverted

  ////////// Mask generator ouptut /////////////////////////////////////////
  //
  output reg  [`WORD_RANGE] mask_result   // output is either a bit mask
);                                        //  or a one-hot decoded value


////////////////////////////////////////////////////////////////////////////
// Internal reg declarations
////////////////////////////////////////////////////////////////////////////

reg     [`WORD_RANGE]       one_hot;      // one-hot decoding of src2[4:0]
reg     [`WORD_RANGE]       bit_mask;     // mask decoding of src2[4:0]

////////////////////////////////////////////////////////////////////////////
// Aynchronous process to implement combinational logic for this unit
////////////////////////////////////////////////////////////////////////////

always @*
begin : mask_gen_PROC

  // Decode the bit mask required by BMSK instructions
  // This excludes bit 0, which is always 1.
  //
  case (src2_val)
    5'b00000: bit_mask = 32'b00000000000000000000000000000001;
    5'b00001: bit_mask = 32'b00000000000000000000000000000011;
    5'b00010: bit_mask = 32'b00000000000000000000000000000111;
    5'b00011: bit_mask = 32'b00000000000000000000000000001111;
    5'b00100: bit_mask = 32'b00000000000000000000000000011111;
    5'b00101: bit_mask = 32'b00000000000000000000000000111111;
    5'b00110: bit_mask = 32'b00000000000000000000000001111111;
    5'b00111: bit_mask = 32'b00000000000000000000000011111111;
    5'b01000: bit_mask = 32'b00000000000000000000000111111111;
    5'b01001: bit_mask = 32'b00000000000000000000001111111111;
    5'b01010: bit_mask = 32'b00000000000000000000011111111111;
    5'b01011: bit_mask = 32'b00000000000000000000111111111111;
    5'b01100: bit_mask = 32'b00000000000000000001111111111111;
    5'b01101: bit_mask = 32'b00000000000000000011111111111111;
    5'b01110: bit_mask = 32'b00000000000000000111111111111111;
    5'b01111: bit_mask = 32'b00000000000000001111111111111111;
    5'b10000: bit_mask = 32'b00000000000000011111111111111111;
    5'b10001: bit_mask = 32'b00000000000000111111111111111111;
    5'b10010: bit_mask = 32'b00000000000001111111111111111111;
    5'b10011: bit_mask = 32'b00000000000011111111111111111111;
    5'b10100: bit_mask = 32'b00000000000111111111111111111111;
    5'b10101: bit_mask = 32'b00000000001111111111111111111111;
    5'b10110: bit_mask = 32'b00000000011111111111111111111111;
    5'b10111: bit_mask = 32'b00000000111111111111111111111111;
    5'b11000: bit_mask = 32'b00000001111111111111111111111111;
    5'b11001: bit_mask = 32'b00000011111111111111111111111111;
    5'b11010: bit_mask = 32'b00000111111111111111111111111111;
    5'b11011: bit_mask = 32'b00001111111111111111111111111111;
    5'b11100: bit_mask = 32'b00011111111111111111111111111111;
    5'b11101: bit_mask = 32'b00111111111111111111111111111111;
    5'b11110: bit_mask = 32'b01111111111111111111111111111111;
    5'b11111: bit_mask = 32'b11111111111111111111111111111111;
  endcase

  // Decode the one-hot mask required by BTST, BCLR, BSET, BBIT, BXOR
  //
  case (src2_val)
    5'b00000: one_hot  = 32'b00000000000000000000000000000001;
    5'b00001: one_hot  = 32'b00000000000000000000000000000010;
    5'b00010: one_hot  = 32'b00000000000000000000000000000100;
    5'b00011: one_hot  = 32'b00000000000000000000000000001000;
    5'b00100: one_hot  = 32'b00000000000000000000000000010000;
    5'b00101: one_hot  = 32'b00000000000000000000000000100000;
    5'b00110: one_hot  = 32'b00000000000000000000000001000000;
    5'b00111: one_hot  = 32'b00000000000000000000000010000000;
    5'b01000: one_hot  = 32'b00000000000000000000000100000000;
    5'b01001: one_hot  = 32'b00000000000000000000001000000000;
    5'b01010: one_hot  = 32'b00000000000000000000010000000000;
    5'b01011: one_hot  = 32'b00000000000000000000100000000000;
    5'b01100: one_hot  = 32'b00000000000000000001000000000000;
    5'b01101: one_hot  = 32'b00000000000000000010000000000000;
    5'b01110: one_hot  = 32'b00000000000000000100000000000000;
    5'b01111: one_hot  = 32'b00000000000000001000000000000000;
    5'b10000: one_hot  = 32'b00000000000000010000000000000000;
    5'b10001: one_hot  = 32'b00000000000000100000000000000000;
    5'b10010: one_hot  = 32'b00000000000001000000000000000000;
    5'b10011: one_hot  = 32'b00000000000010000000000000000000;
    5'b10100: one_hot  = 32'b00000000000100000000000000000000;
    5'b10101: one_hot  = 32'b00000000001000000000000000000000;
    5'b10110: one_hot  = 32'b00000000010000000000000000000000;
    5'b10111: one_hot  = 32'b00000000100000000000000000000000;
    5'b11000: one_hot  = 32'b00000001000000000000000000000000;
    5'b11001: one_hot  = 32'b00000010000000000000000000000000;
    5'b11010: one_hot  = 32'b00000100000000000000000000000000;
    5'b11011: one_hot  = 32'b00001000000000000000000000000000;
    5'b11100: one_hot  = 32'b00010000000000000000000000000000;
    5'b11101: one_hot  = 32'b00100000000000000000000000000000;
    5'b11110: one_hot  = 32'b01000000000000000000000000000000;
    5'b11111: one_hot  = 32'b10000000000000000000000000000000;
  endcase

  // Select either the bit mask or the one-hot decoded operand
  // and optionally invert the result
  //
  mask_result = {32{inv_mask}}
              ^ (   ( bit_mask & {32{mask_op}} )
                  | ( one_hot  & {32{bit_op}}  )
                );

end

endmodule // rl_maskgen
