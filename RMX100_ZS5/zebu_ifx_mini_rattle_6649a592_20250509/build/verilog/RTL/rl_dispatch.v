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
`include "ifu_defines.v"
`include "dmp_defines.v"
`include "clint_defines.v"
`include "csr_defines.v"
`include "csr_debug_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_dispatch (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                       clk,               // clock signal
  input                       rst_a,             // reset signal

  ////////// IFU issue interface /////////////////////////////////////////////
  //
  input                       ifu_issue,         // IFU issues instruction
  input [`PC_RANGE]           ifu_pc,            // I-stage PC
  input [2:0]                 ifu_size,
  input [4:0]                 ifu_pd_addr0,      // pre-decoded reg addr0
  input [4:0]                 ifu_pd_addr1,      // pre-decoded reg addr1
  input [`INST_RANGE]         ifu_inst,          // acutal instruction word
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: fusion input is not used in this configuration
  input [1:0]                 ifu_fusion,        // fusion info
  // spyglass enable_block W240
  input [`IFU_EXCP_RANGE]     ifu_exception,     // IFU exception info
  input                       ifu_inst_break,
  input [`IFU_ADDR_RANGE]     pmp_viol_addr,

  input                       x1_valid_r,        // X1 stage is valid
  input                       x1_pass,           // X1 pass
  input                       x1_enable,         // X1: Dispatch pipe flops are enabled
  input                       csr_raw_hazard,    // X1: CSR raw hazard
  input                       mstatus_tw,
  input [1:0]                 priv_level_r,
  ////////// UOP control interface /////////////////////////////////////////////
  //
  output                      uop_busy,          // suspend fetch
  output                      uop_busy_del,
  output                      uop_busy_ato,
  output                      uop_commit,        // last UOP
  output                      uop_valid,
  output [4:0]                x1_dst1_id,
  input                       x1_holdup,
  input                       fch_restart,


  ////////// Nested vector trap jump /////////////////////////////////////////
  //
  input                       trap_valid,
  input                       mtvec_mode,
  input                       rnmi_synch_r,
  input                       mdt_r,
  input                       x2_pass,
  input                       cp_flush,
  output                      ato_vec_jmp,
  output reg                  shadow_decoder,

  ////////// Debug Interface /////////////////////////////////////////////////
  //
  input                       db_active,        // debug unit is active
  input                       db_valid,         //
  input [`INST_RANGE]         db_inst,          //
  input [`INST_RANGE]         db_limm,          //
  input [4:0]                 db_reg_addr,      // register file ID

  ////////// Register file read data interface ///////////////////////////
  //
  output reg [4:0]            x1_rd_addr0,
  output reg [4:0]            x1_rd_addr1,


  input [`DATA_RANGE]         rf_src0_data,
  input [`DATA_RANGE]         rf_src1_data,

  ////////// Dispatch to FUs ////////////////////////////////////////////
  //
  output [`ALU_CTL_RANGE]     x1_fu_alu_ctl,
  input                       br_x1_stall,
  input                       br_pc_fake,
  output [`BR_CTL_RANGE]      x1_fu_br_ctl,
  output [`MPY_CTL_RANGE]     x1_fu_mpy_ctl,
  output [`DMP_CTL_RANGE]     x1_fu_dmp_ctl,
  output [`CSR_CTL_RANGE]     x1_fu_csr_ctl,
  output [`UOP_CTL_RANGE]     x1_fu_uop_ctl,
  output [`SPC_CTL_RANGE]     x1_fu_spc_ctl,

  output [`DATA_RANGE]        x1_src0_data,
  output [`DATA_RANGE]        x1_src1_data,
  output [`DATA_RANGE]        x1_src2_data,
  output                      x1_raw_hazard,
  output                      x1_waw_hazard,

  output [`PC_RANGE]          x1_pc,
  output [`PC_RANGE]          x1_link_addr,   // Next seq PC
  output reg [`INST_RANGE]    x1_inst,

  output [4:0]                x1_dst_id,
  output                      x1_inst_size,
  output reg                  x1_inst_cg0,
  output reg [`DATA_RANGE]    br_real_base,
  output reg                  br_real_ready,

  ////////// Dispatch to trap module ////////////////////////////////////////////
  //
  output reg[`IFU_EXCP_RANGE] x1_ifu_exception,
  output reg                  x1_inst_break_r,
  output reg[`IFU_ADDR_RANGE] x1_pmp_addr_r,
  output                      illegal_inst,

  ////////// Functional Unit X2 interface /////////////////////////////////////////
  //
  input                       alu_x2_dst_id_valid,
  input [4:0]                 alu_x2_dst_id_r,
  input [`DATA_RANGE]         alu_x2_data,

  input                       mpy_x1_ready,
  input                       mpy_x2_dst_id_valid,
  input [4:0]                 mpy_x2_dst_id_r,

  input                       dmp_x2_dst_id_valid,
  input [4:0]                 dmp_x2_dst_id_r,
  input                       dmp_x2_grad,
  input                       dmp_x2_retire_req,
  input [4:0]                 dmp_x2_retire_dst_id,
  input [`DATA_RANGE]         dmp_x2_data,

  input                       dmp_lsq0_dst_valid,
  input [4:0]                 dmp_lsq0_dst_id,
  input                       dmp_lsq1_dst_valid,
  input [4:0]                 dmp_lsq1_dst_id,

  input                       csr_x2_dst_id_valid,
  input [4:0]                 csr_x2_dst_id_r,
  input [`DATA_RANGE]         csr_x2_data,
  input                       csr_x2_dbg_rd_err,


  ////////// Functional Unit X3 (post-commit) interface /////////////////////////////
  //
  input                       mpy_x3_dst_id_valid,
  input [4:0]                 mpy_x3_dst_id_r,
  input [`DATA_RANGE]         mpy_x3_data,




  ////////// Debug interface ///////////////////////////////////////////////////
  //
  output reg [`DATA_RANGE]    cpu_rdata,             // data returned by CPU
  output reg                  cpu_rd_err,

  ////////// Interface with pipe control //////////////////////////////
  //
  output                      x1_stall

);

// Local Declarations
//

reg [`INST_RANGE]       x1_inst_r;         // Incoming instruction from IFU
reg [`IFU_EXCP_RANGE]   x1_ifu_exception_r;
reg [4:0]          x1_rd_addr0_r;
reg [4:0]          x1_rd_addr1_r;
reg                x1_inst_valid_r;   // is valid
reg [`PC_RANGE]    x1_pc_r;
reg [`PC_RANGE]    x1_link_addr_r;

reg                x1_inst_valid;
reg [`INST_RANGE]  x1_limm;

reg                db_inst_cg0;
reg                db_csr_r;
reg                db_mem_r;
reg                db_csr_nxt;
reg                db_mem_nxt;


/////////////////////////////////////////////////////////////////////////////
//
// Source of instruction
//
//////////////////////////////////////////////////////////////////////////////

wire [`INST_RANGE] uop_inst;

localparam OpcodeRVV = 5'b101_01;

always @*
begin : ra_inst_sel_PROC
  // Where is the instruction coming from?
  //
  x1_inst_valid   = 1'b0;
  x1_inst         = db_inst;
  x1_limm         = db_limm;
  x1_rd_addr0     = x1_rd_addr0_r;
  x1_rd_addr1     = x1_rd_addr1_r;
  x1_ifu_exception= {`IFU_EXCP_WIDTH{1'b0}};

  casez ({db_active, uop_valid, x1_inst_valid_r})
  3'b1_?_?:
  begin
    x1_inst_valid    = db_valid;
    x1_inst          = db_inst;
    x1_limm          = db_limm;
    x1_rd_addr0      = db_reg_addr;
    x1_rd_addr1      = 5'd0; // not used
    x1_ifu_exception = {`IFU_EXCP_WIDTH{1'b0}};
  end

  3'b0_1_?:
  begin
    x1_inst_valid    = 1'b1;
    x1_inst          = uop_inst;
    x1_rd_addr0      = uop_inst[19:15];
    x1_rd_addr1      = uop_inst[24:20];
    x1_ifu_exception = {`IFU_EXCP_WIDTH{1'b0}};
  end

  3'b0_0_1:
  begin
    x1_inst_valid = 1'b1;
    x1_inst       = x1_inst_r;
    x1_rd_addr0   =
                    shadow_decoder ? 5'b0 :
                    x1_rd_addr0_r;
    x1_rd_addr1   =
                    shadow_decoder ? 5'b0 :
                    x1_rd_addr1_r;
    x1_ifu_exception = x1_ifu_exception_r;
  end

  default:
  begin
    x1_inst_valid = 1'b0;
    x1_inst       = 32'h0;
    x1_limm       = db_limm;
    x1_rd_addr0   = x1_rd_addr0_r;
    x1_rd_addr1   = x1_rd_addr1_r;
    x1_ifu_exception = x1_ifu_exception_r;
  end
  endcase

  // Clock-gate
  //
  x1_inst_cg0 = ifu_issue & x1_enable;
end

/////////////////////////////////////////////////////////////////////////////
//
// Provide data to debug interface
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : cpu_rdata_PROC
  // What debug instructions we are performing?
  //
  db_inst_cg0 = db_active & x1_pass;
  db_csr_nxt  = (| x1_fu_csr_ctl);
  db_mem_nxt  = (| x1_fu_dmp_ctl);


  // Provide data debug asked for
  //
  case (1'b1)
  db_csr_r: cpu_rdata = csr_x2_data;
  db_mem_r: cpu_rdata = dmp_x2_data;
  default:  cpu_rdata = alu_x2_data;
  endcase

  case (1'b1)
  db_csr_r: cpu_rd_err = csr_x2_dbg_rd_err;
  db_mem_r: cpu_rd_err = 1'b0; // @@
  default:  cpu_rd_err = 1'b0; // @@
  endcase
end

/////////////////////////////////////////////////////////////////////////////
//
// Special decoder mode for nested vector jump
//
//////////////////////////////////////////////////////////////////////////////
reg [1:0]   decode_state_nxt;
reg [1:0]   decode_state_r;

always @(posedge clk or posedge rst_a)
begin : decode_state_PROC
    if (rst_a)
        decode_state_r <= 2'b0;
    else
        decode_state_r <= decode_state_nxt;
end

always @*
begin: decode_nxt_PROC
decode_state_nxt = decode_state_r;
shadow_decoder = 1'b0;
case (decode_state_r)
    2'b0: begin
        if (trap_valid & mtvec_mode & (!rnmi_synch_r)
            & (!mdt_r)
            )
            decode_state_nxt = 2'b1;
    end
    2'b01: begin
        if (x1_inst_valid_r)
        begin
            if (x1_pass)
                decode_state_nxt = 2'b10;
            shadow_decoder = 1'b1;
        end
    end
    2'b10: begin
        if (x2_pass | cp_flush)
            decode_state_nxt = 2'b0;
    end
    default: begin
        shadow_decoder = 1'b0;
    end
endcase
end

assign ato_vec_jmp = (decode_state_r != 2'b0);


/////////////////////////////////////////////////////////////////////////////
//
// Module instantiation
//
//////////////////////////////////////////////////////////////////////////////

wire                  x1_use_imm;
wire                  x1_use_zimm;
wire [`DATA_RANGE]    x1_imm;
wire [`DATA_RANGE]    x1_zimm;
wire                  x1_use_pc;

wire                  x1_rs1_valid; // First source register is valid
wire [4:0]            x1_rs1;       // First source addr

wire                  x1_rs2_valid; // Second source register is valid
wire [4:0]            x1_rs2;       // Second source addr

wire                  x1_rd_valid;  // Destination register is valid
wire [4:0]            x1_rd;        // Destination addr
wire [4:0]            x1_rd1;


rl_decoder u_rl_decoder (
  .inst                    (x1_inst),
  .pd_rf_src0              (x1_rd_addr0),
  .pd_rf_src1              (x1_rd_addr1),

  .use_imm                 (x1_use_imm),
  .use_zimm                (x1_use_zimm),
  .use_pc                  (x1_use_pc),
  .shadow_decoder          (shadow_decoder),

  .imm                     (x1_imm),
  .zimm                    (x1_zimm),

  .rs1_valid               (x1_rs1_valid),
  .rs1                     (x1_rs1),

  .rs2_valid               (x1_rs2_valid),
  .rs2                     (x1_rs2),

  .rd_valid                (x1_rd_valid),
  .rd                      (x1_rd),
  .mstatus_tw              (mstatus_tw),
  .priv_level_r            (priv_level_r),

  .illegal_inst            (illegal_inst),
  .compressed_inst         (x1_inst_size),
  .fu_alu_ctl              (x1_fu_alu_ctl),
  .fu_uop_ctl              (x1_fu_uop_ctl),
  .rd1                     (x1_rd1),
  .fu_br_ctl               (x1_fu_br_ctl),
  .fu_mpy_ctl              (x1_fu_mpy_ctl),
  .fu_dmp_ctl              (x1_fu_dmp_ctl),
  .fu_spc_ctl              (x1_fu_spc_ctl),
  .fu_csr_ctl              (x1_fu_csr_ctl)
);

rl_bypass u_rl_bypass (
  .x1_valid_r             (x1_valid_r         ),

  .x1_rs1_valid           (x1_rs1_valid       ),
  .x1_rs1                 (x1_rs1             ),

  .x1_rs2_valid           (x1_rs2_valid       ),
  .x1_rs2                 (x1_rs2             ),

  .x1_rd_valid            (x1_rd_valid        ),
  .x1_rd                  (x1_rd              ),

  
  .mva_dst_id              (x1_rd1             ),
  .csr_raw_hazard          (csr_raw_hazard     ),

  .alu_x2_dst_id_valid     (alu_x2_dst_id_valid),
  .alu_x2_dst_id_r         (alu_x2_dst_id_r    ),

  .x1_fu_mpy_ctl           (x1_fu_mpy_ctl      ),
  .mpy_x1_ready            (mpy_x1_ready       ),
  .mpy_x2_dst_id_valid     (mpy_x2_dst_id_valid),
  .mpy_x2_dst_id_r         (mpy_x2_dst_id_r    ),
  .mpy_x3_dst_id_valid     (mpy_x3_dst_id_valid),
  .mpy_x3_dst_id_r         (mpy_x3_dst_id_r    ),


  .dmp_x2_dst_id_valid     (dmp_x2_dst_id_valid),
  .dmp_x2_grad             (dmp_x2_grad        ),
  .dmp_x2_dst_id_r         (dmp_x2_dst_id_r    ),
  .dmp_x2_retire_req       (dmp_x2_retire_req  ),
  .dmp_x2_retire_dst_id    (dmp_x2_retire_dst_id),
  .dmp_lsq0_dst_valid   (dmp_lsq0_dst_valid),
  .dmp_lsq0_dst_id      (dmp_lsq0_dst_id),
  .dmp_lsq1_dst_valid   (dmp_lsq1_dst_valid),
  .dmp_lsq1_dst_id      (dmp_lsq1_dst_id),

  .csr_x2_dst_id_valid     (csr_x2_dst_id_valid),
  .csr_x2_dst_id_r         (csr_x2_dst_id_r    ),

  

  .x1_use_imm              (x1_use_imm         ),
  .x1_imm_data             (x1_imm             ),

  .x1_use_zimm             (x1_use_zimm        ),
  .x1_zimm_data            (x1_zimm            ),

  .x1_use_pc               (x1_use_pc          ),
  .x1_pc_data              ({x1_pc_r, 1'b0}    ),

  .rf_src0_data            (rf_src0_data       ),
  .rf_src1_data            (rf_src1_data       ),

  .alu_x2_data             (alu_x2_data        ),

  .dmp_x2_data             (dmp_x2_data        ),

  .csr_x2_data             (csr_x2_data        ),
  .mpy_x3_data             (mpy_x3_data        ),

  .x1_src0_data            (x1_src0_data       ),
  .x1_src1_data            (x1_src1_data       ),

  .x1_raw_hazard           (x1_raw_hazard      ),
  .x1_waw_hazard           (x1_waw_hazard      ),
  .x1_stall                (x1_stall           )
);

rl_uop_seq u_rl_uop_seq (
  .clk                     (clk                ),
  .rst_a                   (rst_a              ),
  .x1_holdup               (x1_holdup          ),
  .x1_pass                 (x1_pass            ),
  .fu_uop_ctl              (x1_fu_uop_ctl      ),
  .fch_restart             (fch_restart        ),
  .uop_inst                (uop_inst           ),
  .uop_valid               (uop_valid          ),
  .uop_busy                (uop_busy           ),
  .uop_busy_del            (uop_busy_del       ),
  .uop_busy_ato            (uop_busy_ato       ),
  .uop_commit              (uop_commit         )

);

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : x1_inst_regs_PROC
  if (rst_a == 1'b1)
  begin
    x1_inst_valid_r     <= 1'b0;
    x1_inst_r           <= {`INST_SIZE{1'b0}};
    x1_pc_r             <= {`PC_SIZE{1'b0}};
    x1_link_addr_r      <= {`PC_SIZE{1'b0}};
    x1_rd_addr0_r       <= {5{1'b0}};
    x1_rd_addr1_r       <= {5{1'b0}};
    x1_ifu_exception_r  <= {`IFU_EXCP_WIDTH{1'b0}};
    x1_inst_break_r     <= 1'b0;
    x1_pmp_addr_r       <= `IFU_ADDR_BITS'h0;
    br_real_base        <= 32'h0;
    br_real_ready       <= 1'b0;
  end
  else
  begin
    if (x1_enable == 1'b1)
    begin
      x1_inst_valid_r <= ifu_issue;
    end

    if (x1_inst_cg0 == 1'b1)
    begin
      x1_inst_r           <= ifu_inst;
      x1_pc_r             <= ifu_pc;
      x1_ifu_exception_r  <= ifu_exception;
      x1_inst_break_r     <= ifu_inst_break;
      x1_pmp_addr_r       <= pmp_viol_addr;
      x1_link_addr_r      <= (ifu_size == 3'b010) ? (ifu_pc + 2'b1) : (ifu_pc + 2'b10);
      x1_rd_addr0_r       <= ifu_pd_addr0;
      x1_rd_addr1_r       <= ifu_pd_addr1;
    end
    else if (br_x1_stall & (!br_pc_fake) & (| ifu_exception))   // br_x1_stall can be used to save ifu exception, but not clear exception
    begin
      x1_ifu_exception_r  <= ifu_exception;
      x1_pmp_addr_r       <= pmp_viol_addr;
    end
      br_real_base        <= ifu_inst;
      br_real_ready       <= ifu_issue;

  end
end

always @(posedge clk or posedge rst_a)
begin : db_inst_regs_PROC
  if (rst_a == 1'b1)
  begin
    db_csr_r <= 1'b0;
    db_mem_r <= 1'b0;
  end
  else
  begin
    if (db_inst_cg0 == 1'b1)
    begin
      db_csr_r <= db_csr_nxt;
      db_mem_r <= db_mem_nxt;
    end
  end
end

//////////////////////////////////////////////////////////////////////////////////////////
// Output assignmnets
//
///////////////////////////////////////////////////////////////////////////////////////////
assign x1_dst_id    = x1_rd_valid ? x1_rd : 5'd0;
assign x1_dst1_id   = x1_rd_valid ? x1_rd1: 5'd0;
assign x1_pc        = x1_pc_r;
assign x1_link_addr = x1_link_addr_r;
assign x1_src2_data = x1_imm;

endmodule // rl_dispatch

