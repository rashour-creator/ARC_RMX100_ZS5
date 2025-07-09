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
`include "alu_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_alu_data_path (
    input        [`DATA_RANGE]       x1_src0_data,
    input        [`DATA_RANGE]       x1_src1_data,
    input        [`PC_RANGE]         x1_src2_data,
    input        [`ALU_FU_CTL_RANGE] x1_alu_ctl,
    output  reg  [5:0]               alu_x1_comparison,
    output  reg  [`DATA_RANGE]       alu_x1_result,
    input                            db_write,
    input        [`DATA_RANGE]       db_wdata
);
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Declare local reg signals                                                //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

////////// Microcode control signals for the ALU ///////////////////////////
//
reg                       sub_op_r;
reg                       mov_op_r;
reg                       mva_op_r;
reg                       or_op_r;
reg                       and_op_r;
reg                       xor_op_r;
reg                       barrel_shift_op_r;
reg                       left_shift_r;
reg                       inv_src1_r;
reg                       signed_op_r;
reg                       byte_size_r;
reg                       half_size_r;
reg                       word_size_r;
reg                       setcc_op_r;
reg                       link_r;
reg                       bit_op_r;
reg                       src2_mask_sel_r;
reg                [2:0]  src0_shx_r;
reg                       src0_sh1_r;
reg                       src0_sh2_r;
reg                       src0_sh3_r;
reg                       abs_op_r;
reg                       min_op_r;
reg                       max_op_r;
reg                       rotate_op_r;
reg                       norm_op_r;
reg                       swap_op_r;
reg                       cpop_op_r;
reg                       bext_op_r;


// @mask_opd_sel_PROC
//
reg   [`RV_XLEN_RANGE]        mask_src;         // source field for bit mask

reg                           neq_op_r;
reg                           eqz_op_r;

// @cc_result_PROC
//
reg                           eq_test;          // bitwise == test
reg                           lt_test;          // signed < test
reg                           lo_test;          // unsigned < test
reg                           min_max_cond;     // LT test for MIN,MAX inst
reg                           sel_src1;         // MIN, MAX logic
reg                           sel_src2;         // MIN, MAX, ABS logic
reg                           sel_zero;
reg   [`DATA_RANGE]           cpop_src;

// @x1_result_PROC
//
reg                           logic_op;         // 1 => logic unit operation
reg                           select_ll_mux;    // need link_addr or logical op
reg   [`DATA_RANGE]           link_or_logic;    // link address or logic result


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Control
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : alu_ctl_PROC
  // Derive the microcode control bits
  //
  sub_op_r          = x1_alu_ctl[`ALU_CTL_SUB]
                    ;
  inv_src1_r        = sub_op_r
                    | x1_alu_ctl[`ALU_CTL_ANDN]
                    | x1_alu_ctl[`ALU_CTL_ORN]
                    | x1_alu_ctl[`ALU_CTL_XNOR]
                    | x1_alu_ctl[`ALU_CTL_BCLR]
                    ;
  neq_op_r          = x1_alu_ctl[`ALU_CTL_NEQ];
  eqz_op_r          = x1_alu_ctl[`ALU_CTL_EQZ];
  xor_op_r          = x1_alu_ctl[`ALU_CTL_XOR]
                    | x1_alu_ctl[`ALU_CTL_XNOR]
                    | x1_alu_ctl[`ALU_CTL_BINV]
                    ;
  or_op_r           = x1_alu_ctl[`ALU_CTL_OR]
                    | x1_alu_ctl[`ALU_CTL_ORN]
                    | x1_alu_ctl[`ALU_CTL_ORC]
                    | x1_alu_ctl[`ALU_CTL_BSET]
                    ;
  and_op_r          = x1_alu_ctl[`ALU_CTL_AND]
                    | x1_alu_ctl[`ALU_CTL_ANDN]
                    | x1_alu_ctl[`ALU_CTL_BCLR]
                    ;
  barrel_shift_op_r = x1_alu_ctl[`ALU_CTL_SLL]
                    | x1_alu_ctl[`ALU_CTL_SRL]
                    | x1_alu_ctl[`ALU_CTL_SRA]
                    | x1_alu_ctl[`ALU_CTL_ROL]
                    | x1_alu_ctl[`ALU_CTL_ROR]
                    | x1_alu_ctl[`ALU_CTL_BEXT]
                    ;
  left_shift_r      = x1_alu_ctl[`ALU_CTL_SLL]
                    | x1_alu_ctl[`ALU_CTL_ROL]
                    ;
  signed_op_r       = x1_alu_ctl[`ALU_CTL_SRA]
                    | x1_alu_ctl[`ALU_CTL_SLTS]
                    | x1_alu_ctl[`ALU_CTL_MAX]
                    | x1_alu_ctl[`ALU_CTL_MIN]
                    | x1_alu_ctl[`ALU_CTL_SEXTB]
                    | x1_alu_ctl[`ALU_CTL_SEXTH]
                    ;
  setcc_op_r        = x1_alu_ctl[`ALU_CTL_SLTS]
                    | x1_alu_ctl[`ALU_CTL_SLTU]
                    ;
  link_r            = x1_alu_ctl[`ALU_CTL_JAL]
                    | x1_alu_ctl[`ALU_CTL_JALR]
                    ;
  bit_op_r          = x1_alu_ctl[`ALU_CTL_BCLR]
                    | x1_alu_ctl[`ALU_CTL_BINV]
                    | x1_alu_ctl[`ALU_CTL_BSET]
                    ;
  src2_mask_sel_r   = x1_alu_ctl[`ALU_CTL_BCLR]
                    | x1_alu_ctl[`ALU_CTL_BINV]
                    | x1_alu_ctl[`ALU_CTL_BSET]
                    | x1_alu_ctl[`ALU_CTL_BEXT]
                    ;
  src0_sh1_r        = x1_alu_ctl[`ALU_CTL_SH1ADD];
  src0_sh2_r        = x1_alu_ctl[`ALU_CTL_SH2ADD];
  src0_sh3_r        = x1_alu_ctl[`ALU_CTL_SH3ADD];
  src0_shx_r        = {src0_sh3_r, src0_sh2_r, src0_sh1_r};
  max_op_r          = x1_alu_ctl[`ALU_CTL_MAX]
                    | x1_alu_ctl[`ALU_CTL_MAXU]
                    ;
  min_op_r          = x1_alu_ctl[`ALU_CTL_MIN]
                    | x1_alu_ctl[`ALU_CTL_MINU]
                    ;
  abs_op_r          = 1'b0;
  rotate_op_r       = x1_alu_ctl[`ALU_CTL_ROL]
                    | x1_alu_ctl[`ALU_CTL_ROR]
                    | x1_alu_ctl[`ALU_CTL_REV8]
                    ;
  swap_op_r         = x1_alu_ctl[`ALU_CTL_REV8];
  norm_op_r         = x1_alu_ctl[`ALU_CTL_CLZ]
                    | x1_alu_ctl[`ALU_CTL_CTZ]
                    ;
  cpop_op_r         = x1_alu_ctl[`ALU_CTL_CPOP];
  bext_op_r         = x1_alu_ctl[`ALU_CTL_BEXT];
  mov_op_r          = 1'b0
                    | x1_alu_ctl[`ALU_CTL_SEXTB]
                    | x1_alu_ctl[`ALU_CTL_SEXTH]
                    | x1_alu_ctl[`ALU_CTL_ZEXTH]
                    | x1_alu_ctl[`ALU_CTL_ZEXTB]
                    ;
  mva_op_r          = x1_alu_ctl[`ALU_CTL_MVA]
                    | x1_alu_ctl[`ALU_CTL_MVAS];
  byte_size_r       = 1'b0
                    | x1_alu_ctl[`ALU_CTL_CLZ]
                    | x1_alu_ctl[`ALU_CTL_SEXTB]
                    | x1_alu_ctl[`ALU_CTL_ORC]
                    | x1_alu_ctl[`ALU_CTL_ZEXTB]
                    ;
  half_size_r       = 1'b0
                    | x1_alu_ctl[`ALU_CTL_SEXTH]
                    | x1_alu_ctl[`ALU_CTL_ZEXTH]
                    ;
  word_size_r       = 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational process to select maskgen inputs                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : mask_opd_sel_PROC
  mask_src          = x1_src1_data[4:0];
end // mask_opd_sel_PROC

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational process to implement population count (cpop)               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// spyglass disable_block W164b
reg   [`DATA_RANGE]  cpop_result;      // cpop result value
// SMD: Identifies assignments in which the LHS width is less than the RHS width
// SJ: Intended as per the design. No possible loss of data
always @*
begin: cpop_PROC
  // compute the number of set bits in the source operand
  //
  cpop_src    = x1_src0_data;
  cpop_result = {`DATA_SIZE{1'b0}};

  if (cpop_op_r)
  begin
    cpop_result = cpop_src[0]
                + cpop_src[1]
                + cpop_src[2]
                + cpop_src[3]
                + cpop_src[4]
                + cpop_src[5]
                + cpop_src[6]
                + cpop_src[7]
                + cpop_src[8]
                + cpop_src[9]
                + cpop_src[10]
                + cpop_src[11]
                + cpop_src[12]
                + cpop_src[13]
                + cpop_src[14]
                + cpop_src[15]
                + cpop_src[16]
                + cpop_src[17]
                + cpop_src[18]
                + cpop_src[19]
                + cpop_src[20]
                + cpop_src[21]
                + cpop_src[22]
                + cpop_src[23]
                + cpop_src[24]
                + cpop_src[25]
                + cpop_src[26]
                + cpop_src[27]
                + cpop_src[28]
                + cpop_src[29]
                + cpop_src[30]
                + cpop_src[31]
                ;
  end
end
// spyglass enable_block W164b

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational process to implement the generic add/sub logic             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

logic  [`DATA_RANGE]  mpy_adder_src0, mpy_adder_src1;
logic  [`DATA_RANGE]  alu_x1_src0, alu_x1_src1;
logic                 alu_vec_op;
assign alu_x1_src0 = x1_src0_data;
assign alu_x1_src1 = x1_src1_data ^ {`DATA_SIZE{inv_src1_r}};

logic [`DATA_SIZE-1:0] adder_result;
rl_adder    u_rl_adder (
  .src0               (alu_x1_src0 ),  // first source operand
  .src1               (alu_x1_src1 ),  // second source operand, inverted in case of subtract
  .force_cin          (sub_op_r),      // ucode selects sub ops, adder needs to +1
  .src0_shx_ctl       (src0_shx_r  ),  // Ctl bits for SH<x>ADD ops
  .result             (adder_result)   // result of adder unit
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Instantiate the mask generator                                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

wire  [`DATA_RANGE]  mask_result;
rl_maskgen u_rl_maskgen (
  .src2_val           (mask_src         ),  // mask size operand
  .bit_op             (bit_op_r         ),  // ucode selects all bit ops
  .mask_op            (1'b0             ),  // ucode selects all mask ops
  .inv_mask           (inv_src1_r       ),  // ucode forces mask inversion
  .mask_result        (mask_result      )   // result from mask generator
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Instantiate the logical unit                                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

//==========================================================================
// The (ARC) debug uses an OR instruction (logic) unit to write to a GPR
//
logic  [`DATA_RANGE]  alu_x1_src0_db;   // generated source 0 qualified with debug info
assign alu_x1_src0_db = db_write ? db_wdata : x1_src0_data;

wire  [`DATA_RANGE]  logic_result;
rl_logic_unit u_rl_logic_unit (
  .src1               (alu_x1_src0_db   ),  // first source operand, possibly debug data
  .src2               (alu_x1_src1      ),  // second source operand, possibly inverted
  .src2_mask          (mask_result      ),  // mas operand from maskgen
  .or_op              (or_op_r          ),  // ucode selects OR operations
  .and_op             (and_op_r         ),  // ucode selects AND operations
  .xor_op             (xor_op_r         ),  // ucode selects XOR operations
  .mov_op             (mov_op_r         ),  // ucode selects MOV/SEXT/ZEXT
  .signed_op          (signed_op_r      ),  // ucode selects signed ops
  .mask_sel           (src2_mask_sel_r  ),  // ucode selects mask as src2
  .half_size          (half_size_r      ),  // ucode selects 16-bit ops
  .byte_size          (byte_size_r      ),  // ucode selects 8-bit ops
  .result             (logic_result     )   // result of logic unit
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Instantiate the barrel shifter unit                                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


wire  [`DATA_RANGE]  shifter_result;
rl_shifter  u_rl_shifter (
  .src0               (x1_src0_data     ),  // first source operand
  .src1_s6            (x1_src1_data     ),  // second source operand
  .arith              (signed_op_r      ),  // ucode selects signed ops
  .left               (left_shift_r     ),  // ucode selects left shift
  .rotate             (rotate_op_r      ),  // ucode selects rotations
  .bext_op            (bext_op_r        ),  // selects BEXT
  .result             (shifter_result   )   // result of shifter
);

wire  [`DATA_RANGE]  barrel_result;
assign barrel_result =
                        shifter_result;


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Instantiate the byte manipulation unit                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

wire  [`DATA_RANGE]  byte_result;
rl_byte_unit u_rl_byte_unit (
  .src                (x1_src0_data     ),  // source operand
  .swap_op            (swap_op_r        ),  // ucode enables swap operations
  .half_size          (half_size_r      ),  // ucode selects 16-bit ops
  .byte_size          (byte_size_r      ),  // ucode selects 8-bit ops
  .signed_op          (signed_op_r      ),  // ucode selects signed ops
  .left               (left_shift_r     ),  // ucode selects left shift/rotate
  .rotate             (rotate_op_r      ),  // ucode selects rotate vs shift
  .byte_result        (byte_result      )   // result of byte unit
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Instantiate the bit-scanning unit                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

wire  [`RV_BITSCAN_RANGE]  bitscan_result;
rl_bitscan u_rl_bitscan (
  .src2_val           (x1_src0_data     ),  // source operand
  .norm_op            (norm_op_r        ),  // ucode selects norm operations
  .byte_size          (byte_size_r      ),  // ucode selects last vs first
  .bitscan_result     (bitscan_result   )   // result of bitscan unit
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational process for computing relational tests and other signals   //
// used by instructions that yield conditional results                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

reg  setcc_result;
always @*
begin: cc_result_PROC

  //==========================================================================
  // Compute comparisons
  //
  eq_test = (          x1_src0_data  ==           x1_src1_data ); // (a)
  lt_test = (  $signed(x1_src0_data) <    $signed(x1_src1_data)); // (b)
  lo_test = (          x1_src0_data  <            x1_src1_data ); // (c)

  alu_x1_comparison[`EQ]  = eq_test;
  alu_x1_comparison[`NE]  = !eq_test;
  alu_x1_comparison[`LTS] = lt_test;
  alu_x1_comparison[`GES] = !lt_test;
  alu_x1_comparison[`LTU] = lo_test;
  alu_x1_comparison[`GEU] = !lo_test;

  //==========================================================================
  // set cc_result to 1 whenever signed/unsigned comparision of src0 is
  // less than src1 for SLTS/SLTU operations
  //
  setcc_result  = signed_op_r ? lt_test : lo_test;

  //==========================================================================
  // Compute the selection condition used by MIN, MINU, MAX, MAXU, ABS
  // (although the B extension does not support ABS, it may arise as a
  // consequence of fusing a NEG instruction and a MAX instruction).
  //
  min_max_cond  = signed_op_r ? lt_test : lo_test;

  //==========================================================================
  // Determine whether the src0 or src1 values should be selected as the
  // ALU result for MIN, MAX or ABS operations.
  //
  // ABS:        src1 = 0, src2 = B, min_max_cond = (0 < B), i.e. B non-neg
  //             select B if min_max_cond, i.e. B > 0.
  //             else return adder result by default, which is (0 - B).
  //             If B == 0, min_max_cond = 0, and adder result is also 0.
  //
  // MAX/MAXU:   src1 = A, src2 = B, min_max_cond = (A < B)
  //             select A if ~min_max_cond, i.e. ~(A < B), i.e. (A >= B)
  //             select B if min_max_cond, i.e. (A < B), i.e. (B > A)
  //
  // MIN/MINU:   src1 = A, src2 = B, min_max_cond = (A < B)
  //             select A if min_max_cond, i.e. (A < B)
  //             select B if ~min_max_cond, i.e. ~(A < B), i.e. (B >= A)
  //
  sel_src1    = ( min_max_cond & min_op_r)
              | (~min_max_cond & max_op_r)
              | (eqz_op_r & (x1_src1_data != 32'h0))
              | (neq_op_r & (x1_src1_data == 32'h0))
              | mva_op_r
              ;

  sel_src2    = (~min_max_cond & min_op_r)
              | ( min_max_cond & (max_op_r | abs_op_r))
              ;

  sel_zero    = (eqz_op_r & (x1_src1_data == 32'h0))
              | (neq_op_r & (x1_src1_data != 32'h0))
              ;

end // cc_result_PROC

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational process for selecting the ALU result value                 //
//                                                                          //
// Form the ALU result by multiplexing the results from each of the units   //
// within the ALU.                                                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : x1_result_PROC

  //==========================================================================
  // Select the logic unit output as the ALU result if any one of the
  // logical operations is being performed. The MOV instruction is classed
  // as a logical operation, as the logic_unit simply passes gen_src2 to its
  // output when a MOV operation is performed.
  //
  logic_op      = mov_op_r
                | or_op_r
                | and_op_r
                | xor_op_r
                ;

  //==========================================================================
  // Select the combined result from the logic_unit and the link_addr_r
  // value when either logic_op or link_r are asserted.
  //
  select_ll_mux = link_r
                | logic_op
                ;

  link_or_logic = link_r
                ? {x1_src2_data, 1'b0}
                : logic_result
                ;

  // ALU result selection mux
  //
  // spyglass disable_block DisallowCaseZ-ML
  // SMD: Disallow casez statements
  // SJ:  casez is intentional for priority
  casez ({   sel_src1
            ,sel_src2
            ,sel_zero
            ,select_ll_mux
            ,setcc_op_r
            ,barrel_shift_op_r
            ,swap_op_r
            ,norm_op_r
            ,cpop_op_r
         })
    9'b1????????: alu_x1_result = x1_src0_data;
    9'b01???????: alu_x1_result = x1_src1_data;
    9'b001??????: alu_x1_result = 32'h0;
    9'b0001?????: alu_x1_result = link_or_logic;
    9'b00001????: alu_x1_result = {31'd0, setcc_result};
    9'b000001???: alu_x1_result = barrel_result;
    9'b0000001??: alu_x1_result = byte_result;
    9'b00000001?: alu_x1_result = {26'd0, bitscan_result};
    9'b000000001: alu_x1_result = cpop_result;
    default:      alu_x1_result = adder_result;
  endcase
  // spyglass enable_block DisallowCaseZ-ML
end // block: x1_result_PROC


endmodule

