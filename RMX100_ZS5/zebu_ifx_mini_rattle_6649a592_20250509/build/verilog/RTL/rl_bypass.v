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
// Desrciption:
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
`include "dmp_defines.v"
`include "mpy_defines.v"
`include "alu_defines.v"
`include "fpu_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_bypass (

  ////////// X1 stage interface /////////////////////////////////////////////
  //
  input                          x1_valid_r,           // Valid instruction

  input                          x1_rs1_valid,         // RF rs1 valid
  input [4:0]                    x1_rs1,               // RF rs1 reg

  input                          x1_rs2_valid,         // RF rs2 valid
  input [4:0]                    x1_rs2,               // RF rs2 reg

  input                          x1_rd_valid,          // RF rd valid
  input [4:0]                    x1_rd,                // RF rd reg
  input [4:0]                    mva_dst_id,
  input                          csr_raw_hazard,

  ////////// Functional Unit X2 interface /////////////////////////////////////////
  //
  input                          alu_x2_dst_id_valid,
  input [4:0]                    alu_x2_dst_id_r,

  input [`MPY_CTL_RANGE]         x1_fu_mpy_ctl,
  input                          mpy_x1_ready,
  input                          mpy_x2_dst_id_valid,
  input [4:0]                    mpy_x2_dst_id_r,


  input                          dmp_x2_dst_id_valid,
  input                          dmp_x2_grad,
  input [4:0]                    dmp_x2_dst_id_r,

  input                          dmp_x2_retire_req,
  input [4:0]                    dmp_x2_retire_dst_id,

  input                          csr_x2_dst_id_valid,
  input [4:0]                    csr_x2_dst_id_r,

  ////////// Functional Unit X3 (post-commit) interface /////////////////////////////
  //
  input                          mpy_x3_dst_id_valid,
  input [4:0]                    mpy_x3_dst_id_r,

  input                          dmp_lsq0_dst_valid,
  input [4:0]                    dmp_lsq0_dst_id,
  input                          dmp_lsq1_dst_valid,
  input [4:0]                    dmp_lsq1_dst_id,

  ////////// Data from Decoder, RF and FUs /////////////////////////////////////////
  //
  input                          x1_use_imm,
  input [`DATA_RANGE]            x1_imm_data,

  input                          x1_use_zimm,
  input [`DATA_RANGE]            x1_zimm_data,

  input                          x1_use_pc,
  input [`DATA_RANGE]            x1_pc_data,

  input [`DATA_RANGE]            rf_src0_data,
  input [`DATA_RANGE]            rf_src1_data,

  input [`DATA_RANGE]            alu_x2_data,

  input [`DATA_RANGE]            dmp_x2_data,

  input [`DATA_RANGE]            csr_x2_data,
  input [`DATA_RANGE]            mpy_x3_data,

  ////////// Outputs to FUs ////////////////////////////////////////////
  //
  output reg [`DATA_RANGE]       x1_src0_data,
  output reg [`DATA_RANGE]       x1_src1_data,

////////// outputs to HPM //////////////////////////////////////////////
  output reg                     x1_raw_hazard,
  output reg                     x1_waw_hazard,

  ////////// Interface with pipe control //////////////////////////////
  //
  output reg                     x1_stall
);

// Local declarations
//
reg x1_src0_stall;
reg x1_src1_stall;

reg src0_x2_alu_match;
reg src0_x2_mpy_match;
reg src0_x2_dmp_match;
reg src0_x2_dmp_ret_match;
reg src0_x2_csr_match;

reg src1_x2_alu_match;
reg src1_x2_mpy_match;
reg src1_x2_dmp_match;
reg src1_x2_dmp_ret_match;
reg src1_x2_csr_match;


reg src0_x3_mpy_match;
reg src0_lsq_dmp_match;

reg src1_x3_mpy_match;
reg src1_lsq_dmp_match;



reg dst_x2_alu_match;
reg dst_x2_mpy_match;
reg dst_x2_dmp_match;
reg dst_x2_csr_match;

reg dst_x3_mpy_match;
reg dst_lsq_dmp_match;

reg src0_lsq0_dmp_match;
reg src1_lsq0_dmp_match;
reg dst_lsq0_dmp_match;
reg src0_lsq1_dmp_match;
reg src1_lsq1_dmp_match;
reg dst_lsq1_dmp_match;



always @*
begin : x1_src_id_match_PROC
  // Is the src0 ID somehere in X2?
  //
  src0_x2_alu_match     =  x1_rs1_valid
                        &  alu_x2_dst_id_valid
                        &  (x1_rs1 == alu_x2_dst_id_r);

  src0_x2_mpy_match     = x1_rs1_valid
                        & mpy_x2_dst_id_valid
                        & (x1_rs1 == mpy_x2_dst_id_r);

  src0_x2_dmp_match     = x1_rs1_valid
                        & dmp_x2_dst_id_valid
                        & (x1_rs1 == dmp_x2_dst_id_r);

  src0_x2_dmp_ret_match = x1_rs1_valid
                        & dmp_x2_retire_req
                        & (|dmp_x2_retire_dst_id)
                        & (x1_rs1 == dmp_x2_retire_dst_id);

  src0_x2_csr_match     = x1_rs1_valid
                        & csr_x2_dst_id_valid
                        & (x1_rs1 == csr_x2_dst_id_r);


  // Is the src0 ID somehere in X3 (post-commit)?
  //
  src0_x3_mpy_match     = x1_rs1_valid
                        & mpy_x3_dst_id_valid
                        & (x1_rs1 == mpy_x3_dst_id_r);

  // DMP LSQ (post-commit)
  //
  src0_lsq0_dmp_match = dmp_lsq0_dst_valid & (x1_rs1 == dmp_lsq0_dst_id);
  src0_lsq1_dmp_match = dmp_lsq1_dst_valid & (x1_rs1 == dmp_lsq1_dst_id);

  src0_lsq_dmp_match    = x1_rs1_valid
                        & (  1'b0
                           | src0_lsq0_dmp_match
                           | src0_lsq1_dmp_match
                          );

  // Is the src1 ID somehere in X2?
  //
  src1_x2_alu_match     = x1_rs2_valid
                        & alu_x2_dst_id_valid
                        & (x1_rs2 == alu_x2_dst_id_r);

  src1_x2_mpy_match     = x1_rs2_valid
                        & mpy_x2_dst_id_valid
                        & (x1_rs2 == mpy_x2_dst_id_r);



  src1_x2_dmp_match     = x1_rs2_valid
                        & dmp_x2_dst_id_valid
                        & (x1_rs2 == dmp_x2_dst_id_r);

  src1_x2_dmp_ret_match = x1_rs2_valid
                        & dmp_x2_retire_req
                        & (|dmp_x2_retire_dst_id)
                        & (x1_rs2 == dmp_x2_retire_dst_id);

  src1_x2_csr_match     = x1_rs2_valid
                        & csr_x2_dst_id_valid
                        & (x1_rs2 == csr_x2_dst_id_r);

  // Is the src1 ID somehere in X3 (post-commit)?
  //
  src1_x3_mpy_match     = x1_rs2_valid
                        & mpy_x3_dst_id_valid
                        & (x1_rs2 == mpy_x3_dst_id_r);


  // DMP LSQ (post-commit)
  //
  src1_lsq0_dmp_match = dmp_lsq0_dst_valid & (x1_rs2 == dmp_lsq0_dst_id);
  src1_lsq1_dmp_match = dmp_lsq1_dst_valid & (x1_rs2 == dmp_lsq1_dst_id);

  src1_lsq_dmp_match    = x1_rs2_valid
                        & (  1'b0
                           | src1_lsq0_dmp_match
                           | src1_lsq1_dmp_match
                          );

end


always @*
begin : x1_dst_id_match_PROC
  // Is the dst ID somehere in X2?
  //
  dst_x2_alu_match = x1_rd_valid
                    & alu_x2_dst_id_valid
                    & ((x1_rd == alu_x2_dst_id_r)
                    | (mva_dst_id == alu_x2_dst_id_r)
                    );

  dst_x2_mpy_match = x1_rd_valid
                    & mpy_x2_dst_id_valid
                    & ((x1_rd == mpy_x2_dst_id_r)
                    | (mva_dst_id == mpy_x2_dst_id_r)
                    );


  dst_x2_dmp_match = x1_rd_valid
                    & dmp_x2_dst_id_valid
                    & ((x1_rd == dmp_x2_dst_id_r)
                    | (mva_dst_id == dmp_x2_dst_id_r)
                    );

  dst_x2_csr_match = x1_rd_valid
                    & csr_x2_dst_id_valid
                    & ((x1_rd == csr_x2_dst_id_r)
                    | (mva_dst_id == csr_x2_dst_id_r)
                    );


  // Is the dst ID somehere in X3?
  //
  dst_x3_mpy_match = x1_rd_valid
                    & mpy_x3_dst_id_valid
                    & ((x1_rd == mpy_x3_dst_id_r)
                    | (mva_dst_id == mpy_x3_dst_id_r)
                    );



  // DMP LSQ (post-commit)
  //
  dst_lsq0_dmp_match = dmp_lsq0_dst_valid
                         & ((x1_rd == dmp_lsq0_dst_id)
                         | (mva_dst_id == dmp_lsq0_dst_id)
                         );

  dst_lsq1_dmp_match = dmp_lsq1_dst_valid
                         & ((x1_rd == dmp_lsq1_dst_id)
                         | (mva_dst_id == dmp_lsq1_dst_id)
                         );



  dst_lsq_dmp_match = x1_rd_valid
                     & (  1'b0
                        | dst_lsq0_dmp_match
                        | dst_lsq1_dmp_match
                       )
                       ;
end

reg dst_x2_waw_hazard;
reg dst_x3_waw_hazard;

always @*
begin : x1_dst_waw_hazard_PROC
  // We have a write-after-write hazard when the destination register address in X1 matches with the
  // destination register address of an instruction in X2/X3 which provides its result post-commit
  //
  dst_x2_waw_hazard = (dst_x2_dmp_match & dmp_x2_grad)
                    | dst_x2_mpy_match
                    ;

  dst_x3_waw_hazard = dst_lsq_dmp_match
                    | dst_x3_mpy_match
                    ;

end

reg x1_mpy_fu_hazard;

always @*
begin : x1_fu_hazard_PROC
  // We have a FU structural hazard when non-pipelined FU can't start executing a new instruction
  //
  x1_mpy_fu_hazard = (| x1_fu_mpy_ctl) & (~mpy_x1_ready);
end

//////////////////////////////////////////////////////////////////////////////////////////
// Bypass network
//
///////////////////////////////////////////////////////////////////////////////////////////


reg src0_no_byp; // get it from the RF
reg src0_x2_dmp_byp;
reg src0_x2_dmp_ret_byp;
reg src1_no_byp; // get it from the RF
reg src1_x2_dmp_byp;
reg src1_x2_dmp_ret_byp;

always @*
begin : bypass_PROC

  // Figure it out if we get the operands from the RF
  //
  src0_no_byp     = (~src0_x2_alu_match)
                  & (~src0_x2_csr_match)
                  & (~src0_x2_dmp_match)
                  & (~src0_x2_dmp_ret_match)
                  & (~src0_x3_mpy_match)
                  & x1_rs1_valid
                  ;
  src0_x2_dmp_ret_byp =  (src0_x2_dmp_ret_match & (~(dmp_x2_dst_id_valid & (~dmp_x2_grad))));

  src0_x2_dmp_byp = (src0_x2_dmp_match & (~dmp_x2_grad) & (~dmp_x2_retire_req))
                  | src0_x2_dmp_ret_byp;

  x1_src0_data    = (alu_x2_data  & {32{src0_x2_alu_match}})
                  | (csr_x2_data  & {32{src0_x2_csr_match}})
                  | (dmp_x2_data  & {32{src0_x2_dmp_byp}})
                  | (mpy_x3_data  & {32{src0_x3_mpy_match}})
                  | (rf_src0_data & {32{src0_no_byp}})
                  | (x1_zimm_data & {32{x1_use_zimm}})
                  | (x1_pc_data   & {32{x1_use_pc}})
                  ;
  // Figure it out if we get the operands from the RF
  //
  src1_no_byp     = (~src1_x2_alu_match)
                  & (~src1_x2_csr_match)
                  & (~src1_x2_dmp_match)
                  & (~src1_x2_dmp_ret_match)
                  & (~src1_x3_mpy_match)
                  & x1_rs2_valid
                  ;

  src1_x2_dmp_ret_byp =  (src1_x2_dmp_ret_match & (~(dmp_x2_dst_id_valid & (~dmp_x2_grad))));

  src1_x2_dmp_byp = (src1_x2_dmp_match & (~dmp_x2_grad) & (~dmp_x2_retire_req))
                  | src1_x2_dmp_ret_byp;

  x1_src1_data    = (alu_x2_data  & {32{src1_x2_alu_match}})
                  | (csr_x2_data  & {32{src1_x2_csr_match}})
                  | (dmp_x2_data  & {32{src1_x2_dmp_byp}})
                  | (mpy_x3_data  & {32{src1_x3_mpy_match}})
                  | (rf_src1_data & {32{src1_no_byp}})
                  | (x1_imm_data  & {32{x1_use_imm}})
               ;


end

reg src0_x2_no_byp;
reg src0_x3_no_byp; // for LSQ scoreboarding

reg src1_x2_no_byp;
reg src1_x3_no_byp; // for LSQ scoreboarding

reg x1_fu_hazard;

always @*
begin : x1_stall_PROC
  // Is the src0 data available for dispatch? If not, we need to stall
  //
  src0_x2_no_byp = 1'b0
                 | src0_x2_mpy_match
                 | (src0_x2_dmp_match & dmp_x2_grad)
                 | (src0_lsq_dmp_match & (~src0_x2_dmp_ret_byp))
                 ;



  // Is the src1 data available for dispatch? If not, we need to stall
  //
  src1_x2_no_byp = 1'b0
                 | src1_x2_mpy_match
                 | (src1_x2_dmp_match & dmp_x2_grad)
                 | (src1_lsq_dmp_match & (~src1_x2_dmp_ret_byp))
                 ;



  // RAW hazard
  //
  x1_raw_hazard = src0_x2_no_byp
                | src1_x2_no_byp
                | csr_raw_hazard
                ;

  // WAW hazard
  //
  x1_waw_hazard = dst_x2_waw_hazard
                | dst_x3_waw_hazard
                ;

  // FU hazard
  //
  x1_fu_hazard = 1'b0
               | x1_mpy_fu_hazard
               ;

  // Create stall signal
  //
  x1_stall       = x1_valid_r
                 & (  x1_raw_hazard
                    | x1_fu_hazard
                    | x1_waw_hazard
                   )
                 ;

end

endmodule // rl_bypass

