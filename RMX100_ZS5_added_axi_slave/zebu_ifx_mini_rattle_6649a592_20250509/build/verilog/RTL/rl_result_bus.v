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

module rl_result_bus (
  ////////// Functional Unit interface /////////////////////////////////////////////
  //
  input                     alu_rb_req_r,         // ALU requests result bus to write to register file
  input  [4:0]              alu_dst_id_r,         // ALU X2 destination register
  input [`DATA_RANGE]       alu_data,             // ALU X2 result data
  output reg                rb_alu_ack,           // results bus granted ALU access (write port)

  input                     mpy_rb_req_r,         // MPY requests result bus to write to register file
  input  [4:0]              mpy_dst_id_r,         // MPY X2 destination register
  input [`DATA_RANGE]       mpy_data,             // MPY X2 result data
  output reg                rb_mpy_ack,           // results bus granted MPY access (write port)


  input                     dmp_rb_req_r,         // DMP requests result bus to write to register file
  input                     dmp_rb_post_commit_r, // DMP retiring post-commit load - qualifies rb_req
  input                     dmp_rb_retire_err_r,  // DMP retires post-commit load with a bus error
  input  [4:0]              dmp_dst_id_r,         // DMP  destination register (X2 or post-commit)
  input [`DATA_RANGE]       dmp_data,             // DMP  result data
  output  reg               rb_dmp_ack,           // results bus granted DMP access (write port)

  input                     csr_rb_req_r,         // CSR requests result bus to write to register file
  input  [4:0]              csr_dst_id_r,         // CSR X2 destination register
  input [`DATA_RANGE]       csr_data,             // CSR X2 result data
  output reg                rb_csr_ack,           // results bus granted CSR access (write port)

  ////////// Pipe control interface /////////////////////////////////////////////
  //
  input                     x2_pass,              // Instruction commit

  ////////// Register file interface /////////////////////////////////////////////
  //
  output reg                rb_rf_write0,         // port0 write
  output reg [4:0]          rb_rf_addr0,          // port0 addr
  output reg [`DATA_RANGE]  rb_rf_wdata0,         // port0 data

  output reg                rb_rf_write1,         // port1 write
  output reg [4:0]          rb_rf_addr1,          // port1 addr
  output reg [`DATA_RANGE]  rb_rf_wdata1          // port1 data
);

// Local declarations
//



reg               x2_rb_req;
reg [`DATA_RANGE] x2_rb_data;
reg [4:0]         x2_rb_reg_id;
reg               x3_rb_req;
reg [`DATA_RANGE] x3_rb_data;
reg [4:0]         x3_rb_reg_id;

always @*
begin : rb_x2_PROC

  // Combine non-graduating, non-dmp x2 result bus requests. These are mutually exclusive
  //
  x2_rb_req    = alu_rb_req_r
               | csr_rb_req_r
               ;

  x2_rb_data   = (alu_data   & {32{alu_rb_req_r}})
               | (csr_data   & {32{csr_rb_req_r}})
               ;

  x2_rb_reg_id = (alu_dst_id_r & {5{alu_rb_req_r}})
               | (csr_dst_id_r & {5{csr_rb_req_r}})
               ;
end


always @*
begin : rb_x3_PROC

  // Combine post-commit, non-dmp, x3 result bus requests. These are mutually exclusive
  //
  x3_rb_req    = 1'b0
               | mpy_rb_req_r
               ;
  x3_rb_data   =  `DATA_SIZE'b0
               | (mpy_data   & {32{mpy_rb_req_r}})
               ;

  x3_rb_reg_id = `RV_XLEN_BITS'b0
               | (mpy_dst_id_r   & {5{mpy_rb_req_r}})
               ;

end

//////////////////////////////////////////////////////////////////////////////////////////
// Arbiter. This assumes a regfile with 2 write ports. We could also support a single-write
// port register file. Only this arbiter would need to change, and nothing else.
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : rb_arbiter_PROC
  rb_dmp_ack   = 1'b0;
  rb_alu_ack   = 1'b0;
  rb_mpy_ack   = 1'b0;
  rb_csr_ack   = 1'b0;

  rb_rf_write0 = 1'b0;
  rb_rf_addr0  = x2_rb_reg_id;
  rb_rf_wdata0 = x2_rb_data;

  rb_rf_write1 = 1'b0;
  rb_rf_addr1  = dmp_dst_id_r;
  rb_rf_wdata1 = dmp_data;

  // spyglass disable_block DisallowCaseZ-ML
  // SMD: Disallow casez statements
  // SJ:  casez is intentional for priority
  casez ({dmp_rb_req_r,   // DMP - can be post-commit
          x2_rb_req,      // pre-commit
          x3_rb_req,       // post-commit
          1'b0
          })

  4'b0_0_?_?:
  begin
    // Only x3 (mpy, fpu, apex) - port0
    //
    rb_mpy_ack   = x3_rb_req;
    rb_rf_write0 = x3_rb_req;
    rb_rf_addr0  = x3_rb_reg_id;
    rb_rf_wdata0 = x3_rb_data;
  end
  
  4'b0_1_0_0:
  begin
    // Only pre-commit - port0
    //
    rb_alu_ack   = alu_rb_req_r;
    rb_csr_ack   = csr_rb_req_r;
    rb_rf_wdata0 = x2_rb_data;
    rb_rf_addr0  = x2_rb_reg_id;
    rb_rf_write0 = x2_pass;
  end

  4'b0_1_1_?:
  begin
    // pre-commit - port1 and post-commit non-dmp - port0
    //
    rb_alu_ack   = alu_rb_req_r;
    rb_csr_ack   = csr_rb_req_r;
    rb_rf_wdata0 = x2_rb_data;
    rb_rf_addr0  = x2_rb_reg_id;
    rb_rf_write0 = x2_pass;
    rb_mpy_ack   = x3_rb_req;
    rb_rf_write1 = 1'b1;
    rb_rf_addr1  = x3_rb_reg_id;
    rb_rf_wdata1 = x3_rb_data;
  end
  4'b0_1_0_1:
  begin
    // pre-commit - port0 and post-commit non-dmp - port1
    //
    rb_alu_ack   = alu_rb_req_r;
    rb_csr_ack   = csr_rb_req_r;
    rb_rf_wdata0 = x2_rb_data;
    rb_rf_addr0  = x2_rb_reg_id;
    rb_rf_write0 = x2_pass;
  end
  
  4'b1_0_0_0:
  begin
    // Only DMP - port1
    //
    rb_dmp_ack   = 1'b1;
    rb_rf_wdata1 = dmp_data;
    rb_rf_addr1  = dmp_dst_id_r;
    rb_rf_write1 = dmp_rb_post_commit_r ? (~dmp_rb_retire_err_r) : x2_pass;
  end

  4'b1_0_1_?:
  begin
    // DMP and x3. DMP takes port1 and x3 takes port0
    //
    rb_mpy_ack   = x3_rb_req;

    rb_rf_write0 = 1'b1;
    rb_rf_addr0  = x3_rb_reg_id;
    rb_rf_wdata0 = x3_rb_data;

    rb_dmp_ack   = 1'b1;
    rb_rf_wdata1 = dmp_data;
    rb_rf_addr1  = dmp_dst_id_r;
    rb_rf_write1 = dmp_rb_post_commit_r ? (~dmp_rb_retire_err_r) : x2_pass;
  end
  4'b1_0_0_1:
  begin
    // DMP and x3. DMP takes port1 and x3 takes port0
    //
    
    rb_dmp_ack   = 1'b1;
    rb_rf_wdata1 = dmp_data;
    rb_rf_addr1  = dmp_dst_id_r;
    rb_rf_write1 = dmp_rb_post_commit_r ? (~dmp_rb_retire_err_r) : x2_pass;
  end

  4'b1_1_?_?:
  begin
    // DMP and pre-commit. DMP takes port11 and pre-commit takes port0
    //
    rb_alu_ack   = alu_rb_req_r;
    rb_csr_ack   = csr_rb_req_r;
    rb_rf_wdata0 = x2_rb_data;
    rb_rf_addr0  = x2_rb_reg_id;
    rb_rf_write0 = x2_pass;

    rb_dmp_ack   = 1'b1;
    rb_rf_wdata1 = dmp_data;
    rb_rf_addr1  = dmp_dst_id_r;
    rb_rf_write1 = dmp_rb_post_commit_r ? (~dmp_rb_retire_err_r) : x2_pass;
  end

  default:
  begin
    rb_alu_ack   = 1'b0;
    rb_mpy_ack   = 1'b0;
    rb_csr_ack   = 1'b0;
    rb_dmp_ack   = 1'b0;

    rb_rf_write0 = 1'b0;
    rb_rf_write1 = 1'b0;
  end
  endcase
  // spyglass enable_block DisallowCaseZ-ML
end

endmodule // rl_result_bus

