// Library ARCv5EM-3.5.999999999
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
// #                                                                   #
// #                        #                                    #     #
// #                                                                   #
// #       ####    ### #   ##     ####         #    #  # ###    ##    ####
// #      #    #  #   #     #    #    #        #    #  ##   #    #     #
// #      #    #  #   #     #    #             #    #  #    #    #     #
// #      #    #   ###      #    #             #    #  #    #    #     #
// #      #    #  #         #    #    #        #   ##  #    #    #     #  #
// #####   ####    ####   #####   ####          ### #  #    #  #####    ##
//                #    #
//                 ####
//
// ===========================================================================
//
// Description:
//
//  This module implements the Logic Unit within the ALU.
/// ===========================================================================
//  The function computed by the logic unit is determined by 9 ucode bits
//  detailed below. The setting of each microcode bit is determined by the
//  decoding of each instruction.
//
// ----------------------------------------------
//  \ _  Inst    A A O X X N  B B B B   M   Z S S  
//    \ _        N N R O N O  C E S I   O   E E E  
//        \ _    D D   R O T  L X E N   V   X X X  
//  ucode    \     N     R    R T T V       T T T  
//                                          . . .
//                                          H H B
// ----------------------------------------------
//  and_op       1 1 0 0 0 1  1 1 0 0   0   0 0 0  
//  or_op        0 0 1 0 0 0  0 0 1 0   0   0 0 0  
//  xor_op       0 0 0 1 1 0  0 0 0 1   0   0 0 0  
//  mov_op       0 0 0 0 0 0  0 0 0 0   1   1 1 1  
//  shift_op     0 0 0 0 0 0  0 0 0 0   0   0 0 0  
//  mask_sel     0 0 0 0 0 0  1 1 1 1   0   0 0 0  
//  byte_size    0 0 0 0 0 0  0 0 0 0   0   0 0 1  
//  half_size    0 0 0 0 0 0  0 0 0 0   0   1 1 0  
//  signed_op    0 0 0 0 0 0  0 0 0 0   0   0 1 1  
//  ---------------------------------------------
//
//  The mutual-exclusivity of the microcode bits is essential for the
//  correct operation of the Logical Unit, as they control the muxing of
//  values in the large assign statement which implements the Logic Unit.
// =======================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_logic_unit (
  ////////// Operands //////////////////////////////////////////////////////
  //
  input       [`DATA_RANGE]   src1,         // source operand 1
  input       [`DATA_RANGE]   src2,         // source operand 2
  input       [`DATA_RANGE]   src2_mask,    // alternative mask input for src2

  ////////// Control signals ///////////////////////////////////////////////
  //
  input                       or_op,        // logical OR operator
  input                       and_op,       // logical AND operator
  input                       xor_op,       // logical XOR operator
  input                       mov_op,       // mov or extend operator
  input                       signed_op,    // signed vs. unsigned operations
  input                       mask_sel,     // enables mask operand as src2
  input                       half_size,    // mov or extend is half-word sized
  input                       byte_size,    // mov or extend is byte sized

  ////////// Logic unit ouptuts ////////////////////////////////////////////
  //
  output      [`DATA_RANGE]   result        // logic unit result
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Local declarations                                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

wire    [`DATA_RANGE]         gated_src1;   // muxed version of src1
wire    [`DATA_RANGE]         gated_src2;   // muxed version of src2

// Create multiplexed gated_src2 from src2 or src2_mask
//
assign gated_src2       = (src2      & {32{~mask_sel}})
                        | (src2_mask & {32{ mask_sel}});

assign gated_src1[7:0] = {8{|src1[7:0]}};
assign gated_src1[15:8] = {8{|src1[15:8]}};
assign gated_src1[23:16] = {8{|src1[23:16]}};
assign gated_src1[31:24] = {8{|src1[31:24]}};

// Perform the bit-wise logical operations
//
assign result =
    (src1 & gated_src2) & {`DATA_SIZE{and_op}}             // AND, BCLR, BEXT, ANDN
  | (src1 | gated_src2) & {`DATA_SIZE{or_op & ~byte_size}} // OR, BSET
  | (gated_src1 & {`DATA_SIZE{or_op & byte_size}})         // ORC.B
  | (src1 ^ gated_src2) & {`DATA_SIZE{xor_op}}             // XOR, XNOR, BINV
  | (src1 & {`DATA_SIZE{  mov_op                           // MOV
                        & (~byte_size) & (~half_size) & (~signed_op)}})
  | (    {16'd0, src1[15:0]}                             // ZEXT.H
      & {`DATA_SIZE{mov_op & half_size & (~signed_op)}})
  | (   { {16{src1[15]}}, src1[15:0] }                   // SEXT.H
      & {`DATA_SIZE{mov_op & half_size &  signed_op}})
  | (   { {24{src1[7]}}, src1[7:0] }                      // SEXT.B
      & {`DATA_SIZE{mov_op & byte_size &  signed_op}})
  | (    {24'd0, src1[7:0]}                                
      & {`DATA_SIZE{mov_op & byte_size & (~signed_op)}})   // ZEXT.B
  ;

endmodule
