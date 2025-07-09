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


// Set simulation timescale
//
`include "const.def"

module rl_predecoder (

  input [31:0]              inst,  // incoming instruction

  ////////// Pre-Decoder outputs  /////////////////////////////////////////////
  //
  output reg                pd_is_16bit,
  output reg [4:0]          pd_rf_src0,
  output reg                pd_rf_src0_valid,
  output reg [4:0]          pd_rf_src1,
  output reg                pd_rf_src1_valid,
  output reg [`FU_1H_RANGE] pd_fu
);


// Local Declarations
//
reg [1:0]   opcode;
reg [2:0]   funct3;           // 3-bit sub-function field

reg [15:0]  c_inst;           // compact 16-bit instruction
reg [5:0]   c_funct6;         // 6-bit sub-function field
reg [1:0]   c_funct2;         // 2-bit sub-function field

wire [4:0]  mva_src0;
wire [4:0]  mva_src1;

assign mva_src0 = {(c_inst[9:8]>0),(c_inst[9:8]==0),c_inst[9:7]};
assign mva_src1 = {(c_inst[4:3]>0),(c_inst[4:3]==0),c_inst[4:2]};

always @*
begin : predecoder_PROC
  // Default values
  //
  pd_fu              = {`FU_1H_WIDTH{1'b0}};
  pd_rf_src0         = 5'd0;
  pd_rf_src0_valid   = 1'b0;
  pd_rf_src1         = 5'd0;
  pd_rf_src1_valid   = 1'b0;
  pd_is_16bit        = 1'b0;

  // Extract common top-level opcode for all encodings
  //
  opcode             = inst[1:0];      // top-level 2-bit opcode
  funct3             = inst[14:12];    // R, I, S, SB and R4-type

  //==========================================================================
  // Extract the 16-bit RV instruction
  //
  c_inst             = inst[15:0];     // extract 16-bit inst from lower half of word

  //==========================================================================
  // Extract fixed sub-function fields from 16-bit instruction
  //
  c_funct6           = c_inst[15:10];  // most compact formats
  c_funct2           = c_inst[6:5];    // CA-type

  case (opcode)
  2'b00,
  2'b01,
  2'b10: // 16-bit compact instructions
  begin
    pd_is_16bit = 1'b1;
    //==========================================================================
    // Extract the register operand fields from 16-bit instruction encodings
    //
    pd_rf_src0[4:0] = c_inst[11:7];   // extract rs1 and rs1'[2:0]
    pd_rf_src1[4:0] = c_inst[6:2];    // extract rs2 and rs2'[2:0]

  // spyglass disable_block DisallowCaseZ-ML
  // SMD: Disallow casez statements
  // SJ:  casez is intentional for priority
	casez ({c_inst[15], opcode})
    3'b?_00, // quadrant 0 always uses restricted register set
    3'b1_01: // quadrant 1 uses restricted regsiter set when c_inst[15] == 1
    begin    // (quadrant 2 never uses restricted register set)
      pd_rf_src0[4:3] = 2'b01;      // convert rs1 to rs1'
      pd_rf_src1[4:3] = 2'b01;      // convert rs2 to rs2'
    end
  endcase
  // spyglass enable_block DisallowCaseZ-ML

    case ({c_inst[15:13], opcode})
    //////////////////////////////////////////////////////////////////////////
    //                                                                      //
    //          Quadrant 0, defined by (c_inst[1:0] == 2'b00)               //
    //                                                                      //
    //////////////////////////////////////////////////////////////////////////
    5'b000_00: //------------------ C.ADDI4SPN -------------------------------
    begin
      pd_rf_src0[4:0]  = 5'd2;   // set rs1 to sp (x2)
      pd_rf_src0_valid = 1'b1;   // enable read of register rs1
    end
    5'b010_00, //------------------ C.LW -------------------------------------
    5'b110_00: //------------------ C.SW -------------------------------------
    begin
      pd_fu[`FU_DMP_1H]  = 1'b1;
      pd_rf_src0_valid   = 1'b1; // enable read of rs1 for base address
      pd_rf_src1_valid   = 1'b0; // enable read of rs2 for store data
    end
    5'b100_00: //------------------ C.LBU/LHU/LH/SB/SH -----------------------
    begin
      pd_fu[`FU_DMP_1H]  = 1'b1;
      pd_rf_src0_valid   = 1'b1; // enable read of rs1 for base address
      if (c_inst[12:11] == 2'b01)
        pd_rf_src1_valid   = 1'b1; // enable read of rs2 for store data
    end

    //////////////////////////////////////////////////////////////////////////
    //                                                                      //
    //          Quadrant 1, defined by (c_inst[1:0] == 2'b01)               //
    //                                                                      //
    //////////////////////////////////////////////////////////////////////////
    5'b000_01: //------------------ C.ADDI, C.NOP ----------------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_rf_src0_valid   = | pd_rf_src0;
    end
    5'b001_01: //------------------ C.JAL ------------------------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_fu[`FU_BR_1H]   = 1'b1;
    end
    5'b010_01: //------------------ C.LI -------------------------------------
      pd_fu[`FU_ALU_1H]  = 1'b1;   // no src register operands

    5'b011_01: //------------------ C.ADDI16SP, C.LUI ------------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_rf_src0_valid   = (pd_rf_src0[4:0] == 5'd2); // C.ADDI16SP only
    end
    5'b100_01: // C.SRLI C.SRAI C.ANDI C.SUB C.XOR C.OR C.AND C.SUBW C.ADDW --
    // spyglass disable_block DisallowCaseZ-ML
    // SMD: Disallow casez statements
    // SJ:  casez is intentional for priority
	  casez ({c_inst[12:10], c_inst[6:5]})
        5'b0_00_??, //--------------- C.SRLI -----------------------------------
        5'b0_01_??, //--------------- C.SRAI -----------------------------------
        5'b?_10_??, //--------------- C.ANDI -----------------------------------
        5'b0_11_00, //--------------- C.SUB  -----------------------------------
        5'b0_11_01, //--------------- C.XOR  -----------------------------------
        5'b0_11_10, //--------------- C.OR   -----------------------------------
        5'b0_11_11: //--------------- C.AND  -----------------------------------
        begin
          pd_fu[`FU_ALU_1H]  = 1'b1;
          pd_rf_src0_valid   = 1'b1;
          pd_rf_src1_valid   = &c_inst[11:10];
        end
        5'b1_11_10: //-------------- C.MUL
        begin
          pd_fu[`FU_MPY_1H] = 1'b1;
        end
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue
        default: ; // do nothing with encodings that are Reserved or Hints
// spyglass enable_block W193
      endcase
      // spyglass enable_block DisallowCaseZ-ML
    5'b101_01: //------------------ C.J --------------------------------------
       pd_fu[`FU_BR_1H]  = 1'b1;   // no src register operands;
    5'b101_10: //------------------ CM.MVA -----------------------------------
    begin
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b1;
      pd_rf_src0 = c_inst[6] ? mva_src0 : 5'b01010;
      pd_rf_src1 = c_inst[6] ? mva_src1 : 5'b01011;
    end

    5'b110_01, //------------------ C.BEQZ -----------------------------------
    5'b111_01: //------------------ C.BNEZ -----------------------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_fu[`FU_BR_1H]   = 1'b1;
      pd_rf_src0_valid   = 1'b1;
    end

    //////////////////////////////////////////////////////////////////////////
    //                                                                      //
    //          Quadrant 2, defined by (c_inst[1:0] == 2'b10)               //
    //                                                                      //
    //////////////////////////////////////////////////////////////////////////
    5'b000_10: //------------------ C.SLLI -----------------------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_rf_src0_valid   = | pd_rf_src0;
    end

    5'b010_10, //------------------ C.LWSP -----------------------------------
    5'b011_10, //------------------ C.LDSP -----------------------------------
    5'b110_10, //------------------ C.SWSP -----------------------------------
    5'b111_10: //------------------ C.FSWSP or C.SDSP ------------------------
    begin
      pd_fu[`FU_DMP_1H]  = 1'b1;
      pd_rf_src0         = 5'd2; // rs1 selects the stack pointer (x2) as base address
      pd_rf_src0_valid   = 1'b1; // always enable the reading of rs1
      pd_rf_src1_valid   = c_inst[15] & |pd_rf_src1[4:0]; // read store data register

    end
    5'b100_10: // C.JR C.MV C.EBREAK C.JALR C.ADD ---------------------------
    begin
      pd_rf_src0_valid = | pd_rf_src0[4:0];
      pd_rf_src1_valid = | pd_rf_src1[4:0];
      case ({c_inst[12], pd_rf_src0_valid, pd_rf_src1_valid})
      3'b010,  // C.JR
      3'b110,  // C.JALR
      3'b100:  // C.EBREAK
        pd_fu[`FU_BR_1H]  = 1'b1;
      default:
         pd_fu[`FU_ALU_1H] = 1'b1;
      endcase
    end
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue
    default: ; // do nothing with encodings that are Reserved or Hints
// spyglass enable_block W193
    endcase
  end
  2'b11:
  begin
    // Non-compressed, 32-bit instructions (and larger)
    //
    pd_rf_src0 = inst[19:15]; // rs1 field (32-bit encodings only)
    pd_rf_src1 = inst[24:20]; // rs2 field (32-bit encodings only)

    case (inst[6:2])
    5'b00_000: //------------------ LOAD I-type format -----------------------
    begin
      pd_fu[`FU_DMP_1H]  = 1'b1;
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b0;
    end

    5'b01_000: //------------------ STORE S-type format ----------------------
    begin
      pd_fu[`FU_DMP_1H]  = 1'b1;
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b1;
    end
    5'b11_000: //------------------ BRANCH SB-type format --------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_fu[`FU_BR_1H]   = 1'b1;
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b1;
    end

    5'b11_001: //------------------ JALR I-type format -----------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_fu[`FU_BR_1H]   = 1'b1;
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b0;
    end

    5'b00_010, //------------------ custom-0, e.g. APEX ----------------------
    5'b01_010: //------------------ custom-1, e.g. APEX 64-bit ---------------
    begin
    end


    5'b00_011: //------------------ MISC-MEM R-type format -------------------
    begin
        if (inst[14:12] == 3'b010) //CBO
            pd_rf_src0_valid   = 1'b1;
    end

    5'b01_011: //------------------ AMO R-type format ------------------------
    begin
      pd_fu[`FU_DMP_1H]  = 1'b1;
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b1;
    end


    5'b11_011: //------------------ JAL UJ-type format -----------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_fu[`FU_BR_1H]   = 1'b1;
      pd_rf_src0_valid   = 1'b0;
      pd_rf_src1_valid   = 1'b0;
    end

    5'b00_100: //------------------ OP-IMM I-type format ---------------------
    begin
      //pd_fu[`]   = 1'b1;   // @@@ need some more pre-decoding to figure out the the FU?
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b0;
    end

    5'b01_100: //------------------ OP R-type format -------------------------
    begin
      //pd_fu[`]   = 1'b1;   // @@@ need some more pre-decoding to figure out the the FU?
      pd_rf_src0_valid   = 1'b1;
      pd_rf_src1_valid   = 1'b1;
      case ({inst[31:25], inst[14:12]}) // {funct7, funct3}
      // -- Multiplications/divisions
        10'b0000001_000,
        10'b0000001_001,
        10'b0000001_010,
        10'b0000001_011,
        10'b0000001_100,
        10'b0000001_101,
        10'b0000001_110,
        10'b0000001_111:
        begin
          pd_fu[`FU_MPY_1H] = 1'b1;
        end
        default:
        begin
          pd_fu[`FU_MPY_1H] = 1'b0;
        end
      endcase
    end
    5'b11_100: //------------------ SYSTEM R-type format ---------------------
    begin
      //pd_fu[`]   = 1'b1;   // @@@ need some more pre-decoding to figure out the the FU?
      pd_rf_src0_valid   = !funct3[2];
      pd_rf_src1_valid   = 1'b0;
    end

    5'b00_101, //------------------ AUIPC U-type format ----------------------
    5'b01_101: //------------------ LUI U-type format ------------------------
    begin
      pd_fu[`FU_ALU_1H]  = 1'b1;
      pd_rf_src0_valid   = 1'b0;
      pd_rf_src1_valid   = 1'b0;
    end


    5'b11_101: //------------------ Reserved ---------------------------------
    begin
      pd_rf_src0_valid   = 1'b0;
      pd_rf_src1_valid   = 1'b0;
    end

// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue. Added 20240201 for lint.
    default:;
    endcase
  end
  default:;
// spyglass enable_block W193
  endcase
end


endmodule // rl_predecoder


