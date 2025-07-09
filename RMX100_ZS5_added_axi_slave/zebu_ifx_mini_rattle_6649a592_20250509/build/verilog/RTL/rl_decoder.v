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
`include "alu_defines.v"
`include "mpy_defines.v"
`include "fpu_defines.v"
`include "dmp_defines.v"
`include "csr_defines.v"
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_decoder (

  input [31:0]                inst,           // instruction to be decoded
  input [4:0]                 pd_rf_src0,     // predecode - rs1
  input [4:0]                 pd_rf_src1,     // predecode - rs2
  input                       shadow_decoder,
  input                       mstatus_tw,
  input [1:0]                 priv_level_r,

  ////////// Decoder outputs  /////////////////////////////////////////////
  //
  output reg                  use_imm,       // Instruction uses imm
  output reg                  use_zimm,      // Instruction uses zimm
  output reg                  use_pc,        // Instruction uses PC as src0

  output reg [`DATA_RANGE]    imm,           // Imm data
  output reg [`DATA_RANGE]    zimm,          // zimm data

  output reg                  rs1_valid,     // First source register is valid
  output reg [4:0]            rs1,           // First source addr

  output reg                  rs2_valid,     // Second source register is valid
  output reg [4:0]            rs2,           // Second source addr

  output reg                  rd_valid,      // Destination register is valid
  output reg [4:0]            rd,            // Destination addr
  output reg [4:0]            rd1,           // Only for mva
  output reg                  illegal_inst,
  output reg                  compressed_inst, // Inst is 16-bit



  ////////// Outpts to the FUs /////////////////////////////////////////////
  //
  output reg [`ALU_CTL_RANGE] fu_alu_ctl,
  output reg [`UOP_CTL_RANGE] fu_uop_ctl,
  output reg [`BR_CTL_RANGE]  fu_br_ctl,
  output reg [`MPY_CTL_RANGE] fu_mpy_ctl,
  output reg [`DMP_CTL_RANGE] fu_dmp_ctl,
  output reg [`SPC_CTL_RANGE] fu_spc_ctl,
  output reg [`CSR_CTL_RANGE] fu_csr_ctl
);

localparam OpcodeSystem         = 5'b111_00;
localparam OpcodeFence          = 5'b000_11;
localparam OpcodeOp             = 5'b011_00;
localparam OpcodeOp32           = 5'b011_10;
localparam OpcodeOpimm          = 5'b001_00;
localparam OpcodeOpimm32        = 5'b001_10;
localparam OpcodeStore          = 5'b010_00;
localparam OpcodeStoreFP        = 5'b010_01;
localparam OpcodeLoad           = 5'b000_00;
localparam OpcodeLoadFP         = 5'b000_01;
localparam OpcodeBranch         = 5'b110_00;
localparam OpcodeJalr           = 5'b110_01;
localparam OpcodeJal            = 5'b110_11;
localparam OpcodeAuipc          = 5'b001_01;
localparam OpcodeLui            = 5'b011_01;
localparam OpcodeAmo            = 5'b010_11;
localparam OpcodeFP             = 5'b101_00;
localparam OpcodeFMADD          = 5'b100_00;
localparam OpcodeFMSUB          = 5'b100_01;
localparam OpcodeFNMADD         = 5'b100_11;
localparam OpcodeFNMSUB         = 5'b100_10;
localparam OpcodeXSNPS          = 5'b101_10;
localparam OpcodeRVV            = 5'b101_01;
localparam OpcodeCustom0        = 5'b000_10;


// Local declarations
//
reg [15:0]            c_inst;


reg [2:0]             funct3;
reg [6:0]             funct7;

reg                   zimm_type;       // rs1 is an immediate
reg [`IMM_TYPE_RANGE] imm_type;         // I-IMM, S-IMM, SB-IMM, U-IMMM, UJ_IMM, BI-IMM

reg [`DATA_RANGE]     i_type_imm;       // I-type immediate value
reg [`DATA_RANGE]     s_type_imm;       // S-type immediate value
reg [`DATA_RANGE]     sb_type_imm;      // SB-type immediate value
reg [`DATA_RANGE]     u_type_imm;       // U-type immediate value
reg [`DATA_RANGE]     j_type_imm;       // J-type immediate value
reg [`DATA_RANGE]     c_type_imm;       // CSR field (12-bit uimm)
reg                   isgn;             // sign bit for all immediates

reg [`DATA_RANGE]     c_s_imm;          // C_S immediate value
reg [`DATA_RANGE]     c_z_imm;          // C_Z immediate value
reg [`DATA_RANGE]     c_zt_imm;         // C_ZT immediate value
reg [`DATA_RANGE]     c_u_imm;          // C_U immediate value
reg [`DATA_RANGE]     c_spn4_imm;       // SPN4 immediate value
reg [`DATA_RANGE]     c_sp16_imm;       // SP16 immediate value
reg [`DATA_RANGE]     c_lwsp_imm;       // C_LWSP immediate value
reg [`DATA_RANGE]     c_ldsp_imm;       // C_LDSP immediate value
reg [`DATA_RANGE]     c_swsp_imm;       // C_SWSP immediate value
reg [`DATA_RANGE]     c_sdsp_imm;       // C_SDSP immediate value
reg [`DATA_RANGE]     c_lw_imm;         // C_LW immediate value
reg [`DATA_RANGE]     c_ld_imm;         // C_LD immediate value
reg [`DATA_RANGE]     c_lb_imm;         // C_LB immediate value
reg [`DATA_RANGE]     c_lh_imm;         // C_LH immediate value
reg [`DATA_RANGE]     c_j_imm;          // C_J immediate value
reg [`DATA_RANGE]     c_b_imm;          // C_B immediate value
reg                   csgn;             // sign bit for immediates in 16bits


always @*
begin : decoder_PROC
  // Default values
  //
  compressed_inst          = 1'b0;
  illegal_inst             = 1'b0;
  rs1_valid                = 1'b1;
  rs1                      = inst[19:15];
  rs2_valid                = 1'b1;
  rs2                      = inst[24:20];
  rd_valid                 = 1'b1;
  rd                       = inst[11:7];
  funct3                   = 3'b000;
  funct7                   = 7'b0000000;

  zimm_type                = 1'b0;
  imm_type                 = {`IMM_TYPE_WIDTH{1'b0}};
  imm_type[`IMM_TYPE_NONE] = 1'b1;
  use_pc                   = 1'b0;

  fu_alu_ctl               = {`ALU_CTL_WIDTH{1'b0}};
  fu_uop_ctl               = {`UOP_CTL_WIDTH{1'b0}};
  rd1                      = 5'b0;
  fu_br_ctl                = {`BR_CTL_WIDTH{1'b0}};
  fu_mpy_ctl               = {`MPY_CTL_WIDTH{1'b0}};
  fu_dmp_ctl               = {`DMP_CTL_WIDTH{1'b0}};
  fu_spc_ctl               = {`SPC_CTL_WIDTH{1'b0}};
  fu_csr_ctl               = {`CSR_CTL_WIDTH{1'b0}};
  c_inst                   = inst[15:0];

  if (shadow_decoder)       // force jump used by nested vector irq
  begin
      rs1                       = 5'b0;
      rs2_valid                 = 1'b0;
      rd_valid                  = 1'b0;
      imm_type[`IMM_TYPE_IMM]   = 1'b1;

      fu_br_ctl[`BR_CTL_JALR]   = 1'b1;
  end
  else begin

  case (inst[1:0])
  2'b00,
  2'b01,
  2'b10:
  begin
    //==========================================================================
    // Extract the register operand fields from 16-bit instruction encodings
    // (the rf_ra0 and rf_ra1 fields are normally set by the predecoder)
    //
    rs1             = pd_rf_src0;     // first src reg from predecoder
    rs2             = pd_rf_src1;     // second src reg from predecoder

    case (c_inst[1:0])
    2'b01:   rd = pd_rf_src0;       // Q1, default rd (C.JAL overrides)
    2'b10:   rd = c_inst[11:7];     // Q2
    default: rd = { 2'b01,          // rd is restricted register set for Q0,
                    c_inst[4:2]     // and located in the rs2 position
                  };
    endcase

    compressed_inst = 1'b1;           // these encodings are all 16 bits

    case (inst[1:0])
    ////////////////////////////////////////////////////////////////////////////
    //                                                                        //
    //          Quadrant 0, defined by (c_inst[1:0] == 2'b00)                 //
    //                                                                        //
    ////////////////////////////////////////////////////////////////////////////
    2'b00:
    begin
      case (c_inst[15:13])
      3'b000: //------------------ C.ADDI4SPN ---
      begin
        rs2_valid                = 1'b0;
        fu_alu_ctl[`ALU_CTL_ADD] = 1'b1;
        imm_type[`IMM_TYPE_CSPN] = 1'b1;
        illegal_inst             = !(| c_inst[12:2]);
      end


      3'b010: //------------------ C.LW ---
      begin
        imm_type[`IMM_TYPE_CLW]  = 1'b1;
        rs2_valid                = 1'b0;
        fu_dmp_ctl[`DMP_CTL_LW]  = 1'b1;
      end


      3'b110: //------------------ C.SW ---
      begin
        imm_type[`IMM_TYPE_CLW]  = 1'b1;
        fu_dmp_ctl[`DMP_CTL_SW]  = 1'b1;
        rd_valid                 = 1'b0;
      end

      3'b100: //------------------ C.LBU/LHU/LH/SB/SH ---
      begin
        case (c_inst[12:10])
            3'b000: begin   //LBU
                fu_dmp_ctl[`DMP_CTL_LBU] = 1'b1;
                rs2_valid                = 1'b0;
                imm_type[`IMM_TYPE_CLB]  = 1'b1;
            end
            3'b001: begin //LHU LH
                rs2_valid                = 1'b0;
                imm_type[`IMM_TYPE_CLH]  = 1'b1;
                if (c_inst[6])
                    fu_dmp_ctl[`DMP_CTL_LH]  = 1'b1;
                else
                    fu_dmp_ctl[`DMP_CTL_LHU] = 1'b1;
            end
            3'b010: begin //SB
                rd_valid                 = 1'b0;
                imm_type[`IMM_TYPE_CLB]  = 1'b1;
                fu_dmp_ctl[`DMP_CTL_SB]  = 1'b1;
            end
            3'b011: begin //SH
                rd_valid                 = 1'b0;
                imm_type[`IMM_TYPE_CLB]  = 1'b1;
                fu_dmp_ctl[`DMP_CTL_SH]  = 1'b1;
            end
            default: begin
                illegal_inst    = 1'b1;
            end
        endcase

      end

      default:
        illegal_inst    = 1'b1;
      endcase
    end

    ////////////////////////////////////////////////////////////////////////////
    //                                                                        //
    //          Quadrant 1, defined by (c_inst[1:0] == 2'b01)                 //
    //                                                                        //
    ////////////////////////////////////////////////////////////////////////////
    2'b01:
    begin
      case (c_inst[15:13])
      3'b000: //-------------- C.ADDI, C.NOP
      begin
        fu_alu_ctl[`ALU_CTL_ADD] = 1'b1;
        imm_type[`IMM_TYPE_CS]   = 1'b1;
        rs2_valid                = 1'b0;
        rd_valid                 = (| c_inst[11:7]) & (| {c_inst[12], c_inst[6:2]});
      end

      3'b001:  //------------------ C.JAL
      begin
      rs1_valid                 = 1'b0;
      rs2_valid                 = 1'b0;

      rd                        = 5'd1;

      use_pc                    = 1'b1;
      imm_type[`IMM_TYPE_CJ]    = 1'b1;

      fu_br_ctl[`BR_CTL_JAL]    = 1'b1;
      fu_alu_ctl[`ALU_CTL_JAL]  = 1'b1; // rd_valid
      end

      3'b010:  //------------------ C.LI -
      begin
        rs1_valid               = 1'b0;
        rs2_valid               = 1'b0;
        fu_alu_ctl[`ALU_CTL_OR] = 1'b1;
        imm_type[`IMM_TYPE_CS]  = 1'b1;
      end

      3'b011:  //------------ C.ADDI16SP, C.LUI -
      begin
        if (rd == 5'd2) begin
            rs2_valid                 = 1'b0;
            fu_alu_ctl[`ALU_CTL_ADD]  = 1'b1;
            imm_type[`IMM_TYPE_CSP16] = 1'b1;
        end
        else if (rd == 5'd0)
            illegal_inst              = 1'b1;
        else begin
            rs1_valid               = 1'b0;
            rs2_valid               = 1'b0;
            fu_alu_ctl[`ALU_CTL_OR] = 1'b1;
            imm_type[`IMM_TYPE_CU]  = 1'b1;
        end
      end

      3'b100: //--------- C.SRLI C.SRAI C.ANDI C.SUB C.XOR C.OR C.AND ---
      begin
        casez ({c_inst[12:10], c_inst[6:5]})
            5'b?_00_??, //-------------- C.SRLI
            5'b?_01_??: //-------------- C.SRAI
            begin
                imm_type[`IMM_TYPE_CS]   = 1'b1;
                rs2_valid                = 1'b0;
                fu_alu_ctl[`ALU_CTL_SRL] = !c_inst[11];
                fu_alu_ctl[`ALU_CTL_SRA] = c_inst[10];
                illegal_inst             = c_inst[12];
            end
            5'b?_10_??: //-------------- C.ANDI
            begin
                imm_type[`IMM_TYPE_CS]   = 1'b1;
                rs2_valid                = 1'b0;
                fu_alu_ctl[`ALU_CTL_AND] = 1'b1;
            end
            5'b0_11_00, //-------------- C.SUB
            5'b0_11_01, //-------------- C.XOR
            5'b0_11_10, //-------------- C.OR
            5'b0_11_11: //-------------- C.AND
            begin
                fu_alu_ctl[`ALU_CTL_SUB] = !c_inst[6] & !c_inst[5];
                fu_alu_ctl[`ALU_CTL_XOR] = !c_inst[6] &  c_inst[5];
                fu_alu_ctl[`ALU_CTL_OR]  =  c_inst[6] & !c_inst[5];
                fu_alu_ctl[`ALU_CTL_AND] =  c_inst[6] &  c_inst[5];
            end
            5'b1_11_10: //-------------- C.MUL
            begin
                fu_mpy_ctl[`MPY_CTL_MUL] = 1'b1;
            end
            5'b1_11_11: // C.ZEXT.B, C.SEXT.B, C.ZEXT.H, C.SEXT.H, C.NOT
            begin
            rs2_valid                = 1'b0;
            case (c_inst[4:2])
                3'b000: //-------------- C.ZEXT.B - coded [Y] --- tested [ ] -----
                    fu_alu_ctl[`ALU_CTL_ZEXTB] = 1'b1;
                3'b001: //-------------- C.SEXT.B - coded [Y] --- tested [ ] -----
                    fu_alu_ctl[`ALU_CTL_SEXTB] = 1'b1;
                3'b010: //-------------- C.ZEXT.H - coded [Y] --- tested [ ] -----
                    fu_alu_ctl[`ALU_CTL_ZEXTH] = 1'b1;
                3'b011: //-------------- C.SEXT.H - coded [Y] --- tested [ ] -----
                    fu_alu_ctl[`ALU_CTL_SEXTH] = 1'b1;
                3'b101: //-------------- C.NOT    - coded [Y] --- tested [ ] -----
                begin
                    fu_alu_ctl[`ALU_CTL_XOR] = 1'b1;
                    imm_type[`IMM_TYPE_CI]   = 1'b1;
                end
            endcase
            end
        endcase
      end

      3'b101: //-------------------- C.J ---
      begin
      rs1_valid                 = 1'b0;
      rs2_valid                 = 1'b0;
      rd_valid                  = 1'b0;


      use_pc                    = 1'b1;
      imm_type[`IMM_TYPE_CJ]  = 1'b1;

      fu_br_ctl[`BR_CTL_JAL]    = 1'b1;
      fu_alu_ctl[`ALU_CTL_JAL]  = 1'b1; // rd_valid
      end

      3'b110, //-------------------- C.BEQZ ---
      3'b111: //-------------------- C.BNEZ ---
      begin
        imm_type[`IMM_TYPE_CB]   = 1'b1;
        rs2_valid                = 1'b0;
        rd_valid                 = 1'b0;
        if (c_inst[13]) begin
        fu_br_ctl[`BR_CTL_BNE]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BNE] = 1'b1;
        end
        else begin
        fu_br_ctl[`BR_CTL_BEQ]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BEQ] = 1'b1;
        end
      end

      default:
        illegal_inst    = 1'b1;
      endcase


    end

    ////////////////////////////////////////////////////////////////////////////
    //                                                                        //
    //          Quadrant 2, defined by (c_inst[1:0] == 2'b10)                 //
    //                                                                        //
    ////////////////////////////////////////////////////////////////////////////
    2'b10:
    begin
      case (c_inst[15:13])
      3'b000:  //-------------------- C.SLLI
      begin
        imm_type[`IMM_TYPE_CS]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_SLL] = 1'b1;
        rs2_valid                = 1'b0;
        illegal_inst             = c_inst[12];
      end


      3'b010://-------------------- C.LWSP
      begin
        imm_type[`IMM_TYPE_CLWSP]   = 1'b1;
        fu_dmp_ctl[`DMP_CTL_LW]  = 1'b1;
      end


      3'b101: //CM
	  begin
          if ({c_inst[12:11], c_inst[8]} == 3'b110) begin  // CM.PUSH to CM.POPRETZ
            fu_uop_ctl[`UOP_CTL_RLIST] = c_inst[7:4];
            fu_uop_ctl[`UOP_CTL_SP]    = c_inst[3:2];
            fu_uop_ctl[`UOP_CTL_PUSH] = (c_inst[10:9] == 2'b00);
            fu_uop_ctl[`UOP_CTL_POP] = (c_inst[10:9] != 2'b00);
            fu_uop_ctl[`UOP_CTL_RET] = (c_inst[10] == 1'b1);
            fu_uop_ctl[`UOP_CTL_LI]  = (c_inst[9] == 1'b0);
        end
        else if (c_inst[12:10] == 3'b011) begin // MVA
            rd_valid                = 1'b1;
            if (c_inst[6]) begin
                fu_alu_ctl[`ALU_CTL_MVAS] = 1'b1;
                fu_dmp_ctl[`DMP_CTL_MVAS] = 1'b1;
                rd  = 5'b01011;
                rd1 = 5'b01010;
                end
                else begin
                fu_alu_ctl[`ALU_CTL_MVA] = 1'b1;
                fu_dmp_ctl[`DMP_CTL_MVA] = 1'b1;
                rd  = {(c_inst[4:3]>0),(c_inst[4:3]==0),c_inst[4:2]};
                rd1 = {(c_inst[9:8]>0),(c_inst[9:8]==0),c_inst[9:7]}; 
                end
        end
        else if (c_inst[12:10] == 3'b000) begin // JT
            rs1_valid = 1'b0;
            rs2_valid = 1'b0;
            if (c_inst[9:2] < 8'd32) begin
            fu_br_ctl[`BR_CTL_JT] = 1'b1;
            imm_type[`IMM_TYPE_CZ] = 1'b1;
            rd_valid               = 1'b0;
            end
            else begin
            fu_br_ctl[`BR_CTL_JALT] = 1'b1;
            fu_alu_ctl[`ALU_CTL_JAL]  = 1'b1;
            use_pc                  = 1'b1;
            imm_type[`IMM_TYPE_CZT] = 1'b1;
            rd                      = 5'd1;
        end
        end
        else
            illegal_inst = 1'b1;
      end

      3'b100: //---- C.JR  C.MV C.EBREAK C.JALR C.ADD ----------------------------
      begin
        case ({c_inst[12], (|c_inst[11:7]), (|c_inst[6:2])})
            3'b110, //------------------ C.JALR
            3'b010: //------------------ C.JR
                begin
                    rs2_valid                 = 1'b0;
                    rd_valid                  = c_inst[12];
                    rd                        = 5'd1;

                    fu_br_ctl[`BR_CTL_JALR]   = 1'b1;
                    fu_alu_ctl[`ALU_CTL_JALR] = 1'b1; // rd_valid
                end
            3'b011: //------------------ C.MV
                begin //
                    fu_alu_ctl[`ALU_CTL_OR]  = 1'b1;
                    rs1_valid                = 1'b0;
                end
            3'b100: //------------------ C.EBREAK
                begin
                    rs1_valid                   = 1'b0;
                    rs2_valid                   = 1'b0;
                    rd_valid                    = 1'b0;
                    fu_spc_ctl[`SPC_CTL_EBREAK] = 1'b1;
                end
            3'b111: //------------------ C.ADD
                begin // add rd, rd, rs2
                    fu_alu_ctl[`ALU_CTL_ADD] = 1'b1;
                end
            endcase
      end

      3'b110://-------------------- C.SWSP
      begin
        imm_type[`IMM_TYPE_CSWSP]   = 1'b1;
        fu_dmp_ctl[`DMP_CTL_SW]  = 1'b1;
      end

      default:
        illegal_inst    = 1'b1;
      endcase
    end

    default:
      compressed_inst = 1'b0;
    endcase
  end

  2'b11:
  begin
    // Non-compressed instructions decoder                                    
    //                                                                  
    case (inst[6:2]) //  opcode                                         
    OpcodeLoad: //------------------ LOAD I-type format -----------------------
    begin
      // Register-Immediate operations
      //
      rs1                      = inst[19:15];
      rs2_valid                = 1'b0;
      rd                       = inst[11:7];
      rd_valid                 = | inst[11:7];

      funct3                   = inst[14:12];
      imm_type[`IMM_TYPE_IIMM] = 1'b1;

      case (funct3)
      3'b000:
      begin
        fu_dmp_ctl[`DMP_CTL_LB]  = 1'b1; // LB
      end

      3'b001:
      begin
        fu_dmp_ctl[`DMP_CTL_LH]  = 1'b1; // LH
      end

      3'b010:
      begin
        fu_dmp_ctl[`DMP_CTL_LW]  = 1'b1; // LW
      end

      3'b100:
      begin
        fu_dmp_ctl[`DMP_CTL_LBU] = 1'b1; // LBU
      end

      3'b101:
      begin
        fu_dmp_ctl[`DMP_CTL_LHU] = 1'b1; // LHU
      end


      default:
        illegal_inst = 1'b1;
      endcase
    end

    OpcodeStore:  //------------------ STORE S-type format ----------------------
    begin
      // Register-Immediate operations
      //
      rs1                      = inst[19:15];
      rs2                      = inst[24:20];
      rd_valid                 = 1'b0;

      funct3                   = inst[14:12];
      imm_type[`IMM_TYPE_SIMM] = 1'b1;

      case (funct3)
      3'b000:
      begin
        fu_dmp_ctl[`DMP_CTL_SB]  = 1'b1; // SB
      end

      3'b001:
      begin
        fu_dmp_ctl[`DMP_CTL_SH]  = 1'b1; // SH
      end

      3'b010:
      begin
        fu_dmp_ctl[`DMP_CTL_SW]  = 1'b1; // SW
      end


      default:
        illegal_inst = 1'b1;
      endcase
    end

    OpcodeBranch: //------------------ BRANCH SB-type format --------------------
    begin
      // Control-flow instructions
      //
      rs1                       = inst[19:15];
      rs2                       = inst[24:20];
      rd_valid                  = 1'b0;

      funct3                    = inst[14:12];
      imm_type[`IMM_TYPE_SBIMM] = 1'b1;

      case (funct3)
      3'b000: // BEQ;
      begin

        fu_br_ctl[`BR_CTL_BEQ]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BEQ] = 1'b1;
      end

      3'b001: // BNE;
      begin

        fu_br_ctl[`BR_CTL_BNE]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BNE] = 1'b1;
      end

      3'b100: // BLTS;
      begin

        fu_br_ctl[`BR_CTL_BLTS]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BLTS] = 1'b1;
      end

      3'b101: // BGES;
      begin

        fu_br_ctl[`BR_CTL_BGES]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BGES] = 1'b1;
      end

      3'b110: // BLTU;
      begin

        fu_br_ctl[`BR_CTL_BLTU]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BLTU] = 1'b1;
      end

      3'b111: // BGEU;
      begin

        fu_br_ctl[`BR_CTL_BGEU]   = 1'b1;
        fu_alu_ctl[`ALU_CTL_BGEU] = 1'b1;
      end

      default:
        illegal_inst = 1'b1;
      endcase
    end

    OpcodeJalr://------------------ JALR I-type format -----------------------
    begin
      rs1                       = inst[19:15];
      rs2_valid                 = 1'b0;

      rd                        = inst[11:7];
      rd_valid                  = (| inst[11:7]);

      funct3                    = inst[14:12];
      imm_type[`IMM_TYPE_IIMM]  = 1'b1;


      fu_br_ctl[`BR_CTL_JALR]   = 1'b1;
      fu_alu_ctl[`ALU_CTL_JALR] = 1'b1; // rd_valid

      if (funct3 != 3'b000)
        illegal_inst = 1'b1;
    end

    OpcodeJal://------------------ JAL UJ-type format -----------------------
    begin
      rs1_valid                 = 1'b0;
      rs2_valid                 = 1'b0;

      rd                        = inst[11:7];
      rd_valid                  = (| inst[11:7]);

      use_pc                    = 1'b1;
      imm_type[`IMM_TYPE_JIMM]  = 1'b1;

      fu_br_ctl[`BR_CTL_JAL]    = 1'b1;
      fu_alu_ctl[`ALU_CTL_JAL]  = 1'b1; // rd_valid
    end

    OpcodeAuipc://------------------ AUIPC U-type format ----------------------
    begin
      // Add upeer immediate to PC
      //
      rs1_valid                  = 1'b0;
      rs2_valid                  = 1'b0;

      rd                         = inst[11:7];
      rd_valid                   = (| inst[11:7]);

      use_pc                     = 1'b1;
      imm_type[`IMM_TYPE_UIMM]   = 1'b1;

      fu_alu_ctl[`ALU_CTL_AUIPC] = 1'b1;
    end

    OpcodeLui://------------------ LUI U-type format ------------------------
    begin
      rs1_valid                  = 1'b0;
      rs2_valid                  = 1'b0;

      rd                         = inst[11:7];
      rd_valid                   = (| inst[11:7]);

      imm_type[`IMM_TYPE_UIMM]   = 1'b1;

      fu_alu_ctl[`ALU_CTL_LUI]   = 1'b1;
    end

    OpcodeAmo: //------------------ AMO R-type format ------------------------
    begin
      rs1_valid                  = 1'b1;
      rd                         = inst[11:7];
      rd_valid                   = (| inst[11:7]);
      casez ({inst[31:27], inst[24:20], inst[14:12]})
          13'b000_10_00000_010: // LR.W (load-word reserved)
          begin
              rs2_valid          = 1'b0;
              fu_dmp_ctl[`DMP_CTL_LOCK] = 1'b1;
              fu_dmp_ctl[`DMP_CTL_LW]   = 1'b1;
          end
          13'b000_11_?????_010: // SC.W (store-word conditional)
          begin
              rs2_valid          = 1'b1;
              fu_dmp_ctl[`DMP_CTL_LOCK] = 1'b1;
              fu_dmp_ctl[`DMP_CTL_SW]   = 1'b1;
          end
          13'b000_01_?????_010: // AMOSWAP.W (atomic swap-word)
          begin
              rs2_valid          = 1'b1;
              fu_dmp_ctl[`DMP_CTL_LW]   = 1'b1;
              fu_dmp_ctl[`DMP_CTL_SW]   = 1'b1;
          end
          13'b???_00_?????_010: // AMO*.W (ADD, XOR, OR, AND, MIN, MAX, MINU, MAXU)
          begin
              rs2_valid          = 1'b1;
              fu_dmp_ctl[`DMP_CTL_LW]   = 1'b1;
              fu_dmp_ctl[`DMP_CTL_SW]   = 1'b1;
              case (inst[31:29])
                  3'b000: fu_dmp_ctl[`DMP_CTL_AMOADD]   = 1'b1;
                  3'b001: fu_dmp_ctl[`DMP_CTL_AMOXOR]   = 1'b1;
                  3'b011: fu_dmp_ctl[`DMP_CTL_AMOAND]   = 1'b1;
                  3'b010: fu_dmp_ctl[`DMP_CTL_AMOOR]    = 1'b1;
                  3'b100: fu_dmp_ctl[`DMP_CTL_AMOMIN]   = 1'b1;
                  3'b101: fu_dmp_ctl[`DMP_CTL_AMOMAX]   = 1'b1;
                  3'b110: fu_dmp_ctl[`DMP_CTL_AMOMINU]  = 1'b1;
                  3'b111: fu_dmp_ctl[`DMP_CTL_AMOMAXU]  = 1'b1;
              endcase
          end
          default:
          begin
            illegal_inst = 1'b1;
          end
      endcase
    end

    OpcodeSystem: //------------------ SYSTEM R-type format ---------------------
    begin
      rs1_valid                  = 1'b1;
      funct3                     = inst[14:12];

      case (funct3)
      3'b000: /*ecall, ebreak, etc*/
      begin
      casez ({inst[31:20], rs1, rd})
        22'b000000000000_00000_00000: //-- ECALL I-type fmt -----
        begin
          rs1_valid                   = 1'b0;
          rs2_valid                   = 1'b0;
          rd_valid                    = 1'b0;
          fu_spc_ctl[`SPC_CTL_ECALL] = 1'b1;
        end

        22'b000000000001_00000_00000: //-- EBREAK I-type fmt ----
        begin
          rs1_valid                   = 1'b0;
          rs2_valid                   = 1'b0;
          rd_valid                    = 1'b0;

          fu_spc_ctl[`SPC_CTL_EBREAK] = 1'b1;
        end

        22'b0??100000010_00000_00000: //-- *RET I-type fmt ----
        begin
          // @@@ Correct decoding of MRET, SRET
          //
          case (inst[30:29])
              2'b00:   fu_csr_ctl[`CSR_CTL_SRET]   = 1'b1;
              2'b01:   fu_csr_ctl[`CSR_CTL_MRET]   = 1'b1;
              2'b11:   fu_csr_ctl[`CSR_CTL_MNRET]   = 1'b1;
              default: illegal_inst = 1'b1;
          endcase
        end

        22'b000100000101_00000_00000: //-- WFI I-type fmt ----
        begin
            if ((priv_level_r == `PRIV_U) & mstatus_tw)
                illegal_inst = 1'b1;
            else begin
                rs1_valid                   = 1'b0;
                rs2_valid                   = 1'b0;
                rd_valid                    = 1'b0;
                fu_spc_ctl[`SPC_CTL_WFI]    = 1'b1;
            end
        end

        22'b000100000100_?????_00000: //-- SFENCE.VM I-type fmt ----
        begin

        end

        default:
          illegal_inst = 1'b1;
      endcase
      end

      3'b001:
      begin
        // CSRRW
        //
        rd                         = inst[11:7];
        rd_valid                   = (| inst[11:7]);

        rs2_valid                  = 1'b0;
        imm_type[`IMM_TYPE_CIMM]   = 1'b1;
        if (inst[31:20] == 12'h35C)     // mtopei
        begin
            if (rd_valid)
            begin
            fu_csr_ctl[`CSR_CTL_BYP]  = 1'b1;
            fu_csr_ctl[`CSR_CTL_READ] = 1'b1;
            end
        end
        else
        fu_csr_ctl[`CSR_CTL_READ]  = 1'b1;

        fu_csr_ctl[`CSR_CTL_WRITE] = 1'b1;
      end

      3'b010:
      begin
        // CSRRS
        //
        rd                         = inst[11:7];
        rd_valid                   = (| inst[11:7]);

        rs2_valid                  = 1'b0;
        imm_type[`IMM_TYPE_CIMM]   = 1'b1;
        if (inst[31:20] == 12'h35C)     // mtopei
        begin
            fu_csr_ctl[`CSR_CTL_BYP]  = 1'b1;
        end
        else
        fu_csr_ctl[`CSR_CTL_SET]   = (| inst[19:15]);

        fu_csr_ctl[`CSR_CTL_READ]  = 1'b1;
        fu_csr_ctl[`CSR_CTL_WRITE] = (| inst[19:15]);
      end

      3'b011:
      begin
        // CSRRC
        //
        rd                         = inst[11:7];
        rd_valid                   = (| inst[11:7]);

        rs2_valid                  = 1'b0;
        imm_type[`IMM_TYPE_CIMM]   = 1'b1;
        if (inst[31:20] == 12'h35C)     // mtopei
        begin
            fu_csr_ctl[`CSR_CTL_BYP]  = 1'b1;
        end
        else
        fu_csr_ctl[`CSR_CTL_CLEAR] = (| inst[19:15]);

        fu_csr_ctl[`CSR_CTL_READ]  = 1'b1;
        fu_csr_ctl[`CSR_CTL_WRITE] = (| inst[19:15]);
      end

      3'b101:
      begin
        // CSRRWI
        //
        rs1_valid                  = 1'b0;

        rd                         = inst[11:7];
        rd_valid                   = (| inst[11:7]);

        rs2_valid                  = 1'b0;
        zimm_type                  = 1'b1;
        imm_type[`IMM_TYPE_CIMM]   = 1'b1;
        if (inst[31:20] == 12'h35C)     // mtopei
        begin
            if (rd_valid)
            begin
            fu_csr_ctl[`CSR_CTL_BYP]  = 1'b1;
            fu_csr_ctl[`CSR_CTL_READ] = 1'b1;
            end
        end
        else
        fu_csr_ctl[`CSR_CTL_READ]  = 1'b1;
        fu_csr_ctl[`CSR_CTL_WRITE] = 1'b1;
      end

      3'b110:
      begin
        // CSRRSI
        //
        rs1_valid                  = 1'b0;

        rd                         = inst[11:7];
        rd_valid                   = (| inst[11:7]);

        rs2_valid                  = 1'b0;
        zimm_type                  = 1'b1;
        imm_type[`IMM_TYPE_CIMM]   = 1'b1;
        if (inst[31:20] == 12'h35C)     // mtopei
        begin
            fu_csr_ctl[`CSR_CTL_BYP]  = 1'b1;
        end
        else
        fu_csr_ctl[`CSR_CTL_SET]   = (| inst[19:15]);

        fu_csr_ctl[`CSR_CTL_READ]  = 1'b1;
        fu_csr_ctl[`CSR_CTL_WRITE] = (| inst[19:15]);

      end

      3'b111:
      begin
        // CSRRCI
        //
        rs1_valid                  = 1'b0;

        rd                         = inst[11:7];
        rd_valid                   = (| inst[11:7]);

        rs2_valid                  = 1'b0;
        zimm_type                  = 1'b1;
        imm_type[`IMM_TYPE_CIMM]   = 1'b1;
        if (inst[31:20] == 12'h35C)     // mtopei
        begin
            fu_csr_ctl[`CSR_CTL_BYP]  = 1'b1;
        end
        else
        fu_csr_ctl[`CSR_CTL_CLEAR] = (| inst[19:15]);

        fu_csr_ctl[`CSR_CTL_READ]  = 1'b1;
        fu_csr_ctl[`CSR_CTL_WRITE] = (| inst[19:15]);
      end

      default:
        illegal_inst = 1'b1;
      endcase

    end

    OpcodeFence://------------------ MISC-MEM R-type format -------------------
    begin
        rs1     =   inst[19:15];
        funct3  =   inst[14:12];
        case (funct3)
        3'b000:  // FENCE
        begin
          fu_spc_ctl[`SPC_CTL_FENCE] = 1'b1;
          imm_type[`IMM_TYPE_IIMM]   = 1'b1;
        end

        3'b001: // FENCE.I
        begin
          fu_spc_ctl[`SPC_CTL_FENCEI] = 1'b1;
        end

        3'b010: // CBO
        begin
          //
          rs2_valid                  = 1'b0;
          rd_valid                   = 1'b0;
          if (inst[31:23] == 9'b0)
            case (inst[22:20])
            3'b001: fu_spc_ctl[`SPC_CTL_CLEAN] = 1'b1; // CLEAN
            3'b010: fu_spc_ctl[`SPC_CTL_FLUSH] = 1'b1; // FLUSH
            3'b000: fu_spc_ctl[`SPC_CTL_INVAL] = 1'b1; // INVAL
            default:illegal_inst = 1'b1;
            endcase
          else
            illegal_inst = 1'b1;
         end

        default:
          illegal_inst = 1'b1;
        endcase
    end

    OpcodeOp: //------------------ OP R-type format -------------------------
    begin
      // Register-Register operations
      //
      rs1    = inst[19:15];
      rs2    = inst[24:20];
      rd     = inst[11:7];

      funct3 = inst[14:12];
      funct7 = inst[31:25];

      case ({funct7, funct3})
      10'b0000000_000:
      begin
        fu_alu_ctl[`ALU_CTL_ADD] = 1'b1;
      end

      10'b0000111_101:                    // CZERO.EQZ
      begin
        fu_alu_ctl[`ALU_CTL_EQZ] = 1'b1;
      end

      10'b0000111_111:                    // CZERO.NEQ
      begin
        fu_alu_ctl[`ALU_CTL_NEQ] = 1'b1;
      end

      10'b0100000_000:
      begin
        fu_alu_ctl[`ALU_CTL_SUB] = 1'b1;
      end

      10'b0000000_010:
      begin
        fu_alu_ctl[`ALU_CTL_SLTS] = 1'b1;  // set-lower-than (signed)
      end

      10'b0000000_011:
      begin
        fu_alu_ctl[`ALU_CTL_SLTU] = 1'b1;  // set-lower-than (unsigned)
      end

      10'b0000000_100:
      begin
        fu_alu_ctl[`ALU_CTL_XOR] = 1'b1;  // XOR
      end

      10'b0000000_110:
      begin
        fu_alu_ctl[`ALU_CTL_OR] = 1'b1;  // OR
      end

      10'b0000000_111:
      begin
        fu_alu_ctl[`ALU_CTL_AND] = 1'b1;  // AND
      end

      10'b0000000_001:
      begin
        fu_alu_ctl[`ALU_CTL_SLL] = 1'b1;  // Shift-Left-Logical
      end

      10'b0000000_101:
      begin
        fu_alu_ctl[`ALU_CTL_SRL] = 1'b1;  // Shift-Right-Logical
      end

      10'b0100000_101:
      begin
        fu_alu_ctl[`ALU_CTL_SRA] = 1'b1;  // Shift-Right-Arithmetic
      end

      // -- Multiplications/divisions

      10'b0000001_000:
      begin
        fu_mpy_ctl[`MPY_CTL_MUL] = 1'b1;  // MUL
      end

      10'b0000001_001:
      begin
        fu_mpy_ctl[`MPY_CTL_MULH] = 1'b1;  // MULH
      end

      10'b0000001_010:
      begin
        fu_mpy_ctl[`MPY_CTL_MULHSU] = 1'b1;  // MULHSU
      end

      10'b0000001_011:
      begin
        fu_mpy_ctl[`MPY_CTL_MULHU]  = 1'b1;  // MULHU
      end

      10'b0000001_100:
      begin
        fu_mpy_ctl[`MPY_CTL_DIV] = 1'b1;    // DIV
      end

      10'b0000001_101:
      begin
        fu_mpy_ctl[`MPY_CTL_DIVU] = 1'b1;   // DIVU
      end

      10'b0000001_110:
      begin
        fu_mpy_ctl[`MPY_CTL_REM] = 1'b1;   // REM
      end

      10'b0000001_111:
      begin
        fu_mpy_ctl[`MPY_CTL_REMU] = 1'b1;  // REMU
      end

      // -- Bit manipulation extensions

      10'b0010000_010:
      begin
        fu_alu_ctl[`ALU_CTL_SH1ADD] = 1'b1;  // SH1ADD
      end

      10'b0010000_100:
      begin
        fu_alu_ctl[`ALU_CTL_SH2ADD] = 1'b1;  // SH2ADD
      end

      10'b0010000_110:
      begin
        fu_alu_ctl[`ALU_CTL_SH3ADD] = 1'b1;  // SH3ADD
      end

      10'b0100000_111:
      begin
        fu_alu_ctl[`ALU_CTL_ANDN]  = 1'b1;  // ANDN
      end

      10'b0100000_110:
      begin
        fu_alu_ctl[`ALU_CTL_ORN]   = 1'b1;  // ORN
      end

      10'b0100000_100:
      begin
        fu_alu_ctl[`ALU_CTL_XNOR]  = 1'b1;  // XNOR
      end

      10'b0000101_110:
      begin
        fu_alu_ctl[`ALU_CTL_MAX]   = 1'b1;  // MAX
      end

      10'b0000101_111:
      begin
        fu_alu_ctl[`ALU_CTL_MAXU]  = 1'b1;  // MAXU
      end

      10'b0000101_100:
      begin
        fu_alu_ctl[`ALU_CTL_MIN]   = 1'b1;  // MIN
      end

      10'b0000101_101:
      begin
        fu_alu_ctl[`ALU_CTL_MINU]  = 1'b1;  // MINU
      end

      10'b0000100_100:
      begin
        fu_alu_ctl[`ALU_CTL_ZEXTH] = 1'b1;  // ZEXT.H

        if (inst[24:20] != 5'd0)
        begin
          illegal_inst = 1'b1;
        end
      end

      10'b0110000_001:
      begin
        fu_alu_ctl[`ALU_CTL_ROL]   = 1'b1;  // ROL
      end

      10'b0110000_101:
      begin
        fu_alu_ctl[`ALU_CTL_ROR]   = 1'b1;  // ROR
      end

      10'b0100100_001:
      begin
        fu_alu_ctl[`ALU_CTL_BCLR]  = 1'b1;  // BCLR
      end

      10'b0100100_101:
      begin
        fu_alu_ctl[`ALU_CTL_BEXT]  = 1'b1;  // BEXT
      end

      10'b0110100_001:
      begin
        fu_alu_ctl[`ALU_CTL_BINV]  = 1'b1;  // BINV
      end

      10'b0010100_001:
      begin
        fu_alu_ctl[`ALU_CTL_BSET]  = 1'b1;  // BSET
      end

      default:
        illegal_inst = 1'b1;
      endcase
    end


    OpcodeOpimm:  //------------------ OP-IMM I-type format ---------------------
    begin
      // Register-Immediate operations
      //
      rs1                      = inst[19:15];
      rs2_valid                = 1'b0;
      rd                       = inst[11:7];

      funct3                   = inst[14:12];
      imm_type[`IMM_TYPE_IIMM] = 1'b1;

      case (funct3)
      3'b000:
      begin
        fu_alu_ctl[`ALU_CTL_ADD] = 1'b1;  // ADD rs1, imm
      end

      3'b010:
      begin
        fu_alu_ctl[`ALU_CTL_SLTS] = 1'b1;  // SLT(Signed) rd,rs1,imm
      end

      3'b011:
      begin
        fu_alu_ctl[`ALU_CTL_SLTU] = 1'b1;  // SLTU rd,rs1,imm
      end

      3'b100:
      begin
        fu_alu_ctl[`ALU_CTL_XOR] = 1'b1;  // XOR rd,rs1,imm
      end

      3'b110:
      begin
        if (| inst[11:7]) begin
        fu_alu_ctl[`ALU_CTL_OR]   = 1'b1;  // OR rd,rs1,imm
        end
        else if (inst[24:20] == 5'b0) begin  // PREFETCH.I
          fu_spc_ctl[`SPC_CTL_PREFETCH] = 1'b1;
          imm_type[`IMM_TYPE_SIMM]      = 1'b1;
          rd_valid                      = 1'b0;
        end
      end

      3'b111:
      begin
        fu_alu_ctl[`ALU_CTL_AND]  = 1'b1;  // AND rd,rs1,imm
      end

      3'b001:
      begin
        case (inst[31:25])
        7'b0000000:  fu_alu_ctl[`ALU_CTL_SLL]   = 1'b1;  // SLLI rd,rs1,imm
        7'b0110000:
          case (inst[24:20])
          5'b00000:  fu_alu_ctl[`ALU_CTL_CLZ]   = 1'b1;  // CLZ rd,rs
          5'b00001:  fu_alu_ctl[`ALU_CTL_CTZ]   = 1'b1;  // CTZ rd,rs
          5'b00010:  fu_alu_ctl[`ALU_CTL_CPOP]  = 1'b1;  // CPOP rd,rs
          5'b00100:  fu_alu_ctl[`ALU_CTL_SEXTB] = 1'b1;  // SEXT.B rd,rs
          5'b00101:  fu_alu_ctl[`ALU_CTL_SEXTH] = 1'b1;  // SEXT.H rd,rs
          default:   illegal_inst = 1'b1;
          endcase
        7'b0100100:  fu_alu_ctl[`ALU_CTL_BCLR]  = 1'b1;  // BCLRI rd,rs1,imm
        7'b0110100:  fu_alu_ctl[`ALU_CTL_BINV]  = 1'b1;  // BINVI rd,rs1,imm
        7'b0010100:  fu_alu_ctl[`ALU_CTL_BSET]  = 1'b1;  // BSETI rd,rs1,imm
        default:     illegal_inst = 1'b1;
        endcase
      end

      3'b101:
      begin
        case (inst[31:25])
        7'b0000000:  fu_alu_ctl[`ALU_CTL_SRL]  = 1'b1;  // SRLI rd,rs1,imm
        7'b0100000:  fu_alu_ctl[`ALU_CTL_SRA]  = 1'b1;  // SRAI rd,rs1,imm
        7'b0110000:  fu_alu_ctl[`ALU_CTL_ROR]  = 1'b1;  // RORI rd,rs11,imm
        7'b0010100:  fu_alu_ctl[`ALU_CTL_ORC]  = 1'b1;  // ORC.B rd, rs
        7'b0110100:  fu_alu_ctl[`ALU_CTL_REV8] = 1'b1;  // REV8 rd,rs
        7'b0100100:  fu_alu_ctl[`ALU_CTL_BEXT] = 1'b1;  // BEXTI rd,rs1,imm
        default:     illegal_inst = 1'b1;
        endcase
      end

      default:
        illegal_inst = 1'b1;
      endcase

    end


    default:
        illegal_inst = 1'b1;
    endcase
  end

  default:
        illegal_inst = 1'b1;
  endcase
end

end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Immediate decoding
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : imm_dec_PROC
  //==========================================================================
  // Extract the various forms of immediate value for 32-bit RV encodings
  //
  isgn        = inst[31];
  i_type_imm  = { {`I_IMM_EXT{isgn}}, inst[30:25], inst[24:21], inst[20] };
  s_type_imm  = { {`S_IMM_EXT{isgn}}, inst[30:25], inst[11:8], inst[7] };
  sb_type_imm = { {`B_IMM_EXT{isgn}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
  u_type_imm  = { {`U_IMM_EXT{isgn}}, inst[30:12], 12'h000 };
  j_type_imm  = { {`J_IMM_EXT{isgn}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0 };
  c_type_imm  = { {`C_IMM_EXT{1'b0}}, inst[31:20] };

  //==========================================================================
  // Extract the various forms of immediate value for 16-bit RV encodings
  //
  csgn        = c_inst[12];   // fixed position of sign bit for extensions
  c_s_imm     = { {`CS_IMM_EXT{csgn}}, c_inst[6:2]};
  c_z_imm     = { {`CZ_IMM_EXT{1'b0}}, c_inst[12], c_inst[6:2]};
  c_zt_imm    = { 24'b0, c_inst[9:2]};
  c_u_imm     = { {`CU_IMM_EXT{csgn}}, c_inst[6:2], 12'h000};
  c_spn4_imm  = { {`CSPN4_IMM_EXT{1'b0}}, c_inst[10:7], c_inst[12:11], c_inst[5], c_inst[6], 2'b0};
  c_sp16_imm  = { {`CSP16_IMM_EXT{csgn}}, c_inst[4:3], c_inst[5], c_inst[2], c_inst[6], 4'b0};
  c_lwsp_imm  = { {`CLWSP_IMM_EXT{1'b0}}, c_inst[3:2], c_inst[12], c_inst[6:4], 2'b0};
  c_ldsp_imm  = { {`CLDSP_IMM_EXT{1'b0}}, c_inst[4:2], c_inst[12], c_inst[6:5], 3'b0};
  c_swsp_imm  = { {`CSWSP_IMM_EXT{1'b0}}, c_inst[8:7], c_inst[12:9], 2'b0};
  c_sdsp_imm  = { {`CSDSP_IMM_EXT{1'b0}}, c_inst[9:7], c_inst[12:10], 3'b0};
  c_lw_imm    = { {`CLW_IMM_EXT{1'b0}}, c_inst[5], c_inst[12:10], c_inst[6], 2'b0};
  c_ld_imm    = { {`CLD_IMM_EXT{1'b0}}, c_inst[6:5], c_inst[12:10], 3'b0};
  c_j_imm     = { {`CJ_IMM_EXT{csgn}}, c_inst[8], c_inst[10:9], c_inst[6], c_inst[7], c_inst[2], c_inst[11], c_inst[5:3], 1'b0};
  c_b_imm     = { {`CB_IMM_EXT{csgn}}, c_inst[6:5], c_inst[2], c_inst[11:10], c_inst[4:3], 1'b0};
  c_lb_imm     = {30'b0, c_inst[5], c_inst[6]};
  c_lh_imm     = {30'b0, c_inst[5], 1'b0};

  // Default values:
  //
  use_imm  = 1'b1;
  use_zimm = zimm_type;

  imm      = 32'b0;
  zimm     =  { {`Z_IMM_EXT{1'b0}}, inst[19:15] };

  case (1'b1)
  imm_type[`IMM_TYPE_IIMM]:  imm     = i_type_imm;
  imm_type[`IMM_TYPE_IMM] :  imm     = inst;
  imm_type[`IMM_TYPE_SIMM]:
  begin
                             imm     = s_type_imm;
                             use_imm = 1'b0;
  end
  imm_type[`IMM_TYPE_SBIMM]:
  begin
                             imm     = sb_type_imm;
                             use_imm = 1'b0;
  end
  imm_type[`IMM_TYPE_UIMM]:  imm     = u_type_imm;
  imm_type[`IMM_TYPE_JIMM]:  imm     = j_type_imm;
  imm_type[`IMM_TYPE_CIMM]:  imm     = c_type_imm;
  imm_type[`IMM_TYPE_CS]:    imm     = c_s_imm;
  imm_type[`IMM_TYPE_CZ]:    imm     = c_z_imm;
  imm_type[`IMM_TYPE_CZT]:   imm     = c_zt_imm;
  imm_type[`IMM_TYPE_CU]:    imm     = c_u_imm;
  imm_type[`IMM_TYPE_CSPN]:  imm     = c_spn4_imm;
  imm_type[`IMM_TYPE_CSP16]: imm     = c_sp16_imm;
  imm_type[`IMM_TYPE_CLWSP]: imm     = c_lwsp_imm;
  imm_type[`IMM_TYPE_CSWSP]:
  begin
                             imm     = c_swsp_imm;
                             use_imm = 1'b0;
  end
  imm_type[`IMM_TYPE_CLW]:
  begin
                             imm     = c_lw_imm;
                             use_imm = 1'b0;
  end
  imm_type[`IMM_TYPE_CJ]:    imm     = c_j_imm;
  imm_type[`IMM_TYPE_CB]:
  begin
                             imm     = c_b_imm;
                             use_imm = 1'b0;
  end
  imm_type[`IMM_TYPE_CI]:    imm     = 32'hFFFF_FFFF;
  imm_type[`IMM_TYPE_CLB]:
  begin
                             imm     = c_lb_imm;
                             use_imm = 1'b0;
  end
  imm_type[`IMM_TYPE_CLH]:   imm     = c_lh_imm;
  default:                   use_imm = 1'b0;
  endcase
end


endmodule // rl_decoder



