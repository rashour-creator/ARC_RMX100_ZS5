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

// Set simulation timescale
//
`include "const.def"

module rl_alu (
  ////////// Dispatch interface /////////////////////////////////////////////
  //
  input                      x1_pass,               // instruction dispatched to the ALU FU
  input [`ALU_FU_CTL_RANGE]  x1_alu_ctl,            // Indicates the instructon to be executed in this FU
  input [`DATA_RANGE]        x1_src0_data,          // source0 operand
  input [`DATA_RANGE]        x1_src1_data,          // source1 operand
  input [`PC_RANGE]          x1_src2_data,          // source2 operand  -- link addr
  input [4:0]                x1_dst_id,             // destination register - used for scoreaboarding
  input [4:0]                x1_dst1_id,
  input                      dmp_x2_mva_stall_r,    // DMP requests to stall MVA instruction in X2 stage

  output [`BR_CMP_RANGE]     alu_x1_comparison,     // For BR resolution

  ////////// Debug access /////////////////////////////////////////////////
  //
  input                      db_write,              // Debug writing to a GPT
  input [`DATA_RANGE]        db_wdata,              // Debug write data

  ////////// X2 stage interface /////////////////////////////////////////////
  //
  input                      x2_valid_r,            // X2 valid instruction from pipe ctrl
  input                      x2_pass,               // X2 commit
  output [`DATA_RANGE]       alu_x2_data,           // ALU X2 result available for bypass
  output reg [4:0]           alu_x2_dst_id_r,       // ALU X2 destination register - used for scoreaboarding
  output                     alu_x2_dst_id_valid,   // ALU X2 valid destination
  output reg                 alu_x2_rb_req_r,       // ALU requests result bus to write to register file
  input                      x2_alu_rb_ack,         // results bus granted ALU access (write port)


  output reg                 alu_x2_stall,          // only stall if there is a RF write port conflict

  ////////// X3 stage interface /////////////////////////////////////////////
  //
  input                      x3_flush_r,            // Pipeline has been flushed

  ////////// General input signals /////////////////////////////////////////////
  //
  input                      clk,                   // clock signal
  input                      rst_a                  // reset signal

);

// Local declarations
//

reg                alu_x2_valid_r;
reg                alu_x2_valid_nxt;
reg [4:0]          alu_x2_dst_id_nxt;
reg               alu_x2_mva_r;
reg                alu_x2_ctl_cg0;
reg                alu_x2_data_cg0;


reg [`DATA_RANGE]  alu_x2_data_r;


reg                alu_x2_rb_req_nxt;
reg                alu_x2_rb_req_cg0;

wire               alu_x1_no_dst;
wire               alu_x1_valid;
wire               alu_x1_pass;
wire               alu_x1_dst_id_valid;

wire               alu_x2_valid;
wire               alu_x2_pass;


// Handy assignments
//

assign alu_x1_no_dst        = x1_alu_ctl[`ALU_CTL_BEQ]
                            | x1_alu_ctl[`ALU_CTL_BNE]
                            | x1_alu_ctl[`ALU_CTL_BLTS]
                            | x1_alu_ctl[`ALU_CTL_BGES]
                            | x1_alu_ctl[`ALU_CTL_BLTU]
                            | x1_alu_ctl[`ALU_CTL_BGEU];

assign alu_x1_valid         = (| x1_alu_ctl);
assign alu_x1_pass          = x1_pass       & alu_x1_valid;
assign alu_x1_dst_id_valid  = ((| x1_dst_id) & alu_x1_valid & (~alu_x1_no_dst))
                            | ((| x1_dst1_id) & (x1_alu_ctl[`ALU_CTL_MVA] | x1_alu_ctl[`ALU_CTL_MVAS]))
                                                            ;

assign alu_x2_valid         = alu_x2_valid_r & x2_valid_r;
assign alu_x2_pass          = alu_x2_valid   & x2_pass;
assign alu_x2_dst_id_valid  = alu_x2_valid   & (| alu_x2_dst_id_r);


//////////////////////////////////////////////////////////////////////////////////////////
//
// Instantiate the actual ALU functional unit
//
//////////////////////////////////////////////////////////////////////////////////////////
logic [`DATA_RANGE] alu_x1_result;
rl_alu_data_path u_rl_alu_data_path (.*);

// X2
//
always @*
begin : alu_x2_PROC
  // Clock-gate
  //
  alu_x2_ctl_cg0 = x1_pass;
  alu_x2_data_cg0   = x1_pass & (| x1_alu_ctl);

  alu_x2_valid_nxt  = alu_x1_pass;
  alu_x2_dst_id_nxt =
                        (x1_alu_ctl[`ALU_CTL_MVA] | x1_alu_ctl[`ALU_CTL_MVAS]) ? x1_dst1_id :
                        (x1_dst_id & {5{alu_x1_valid}} & {5{(~alu_x1_no_dst)}});
end


// Result bus
//
always @*
begin : alu_rb_PROC
  // Clock-gate
  //
  alu_x2_rb_req_cg0 = alu_x1_valid
                    | alu_x2_rb_req_r
                    | x3_flush_r
                    | (alu_x2_mva_r & dmp_x2_mva_stall_r)
                    ;


  // Request the result bus when a ALU instruction is in X2 - Hold the request until we get the ack
  //
  alu_x2_rb_req_nxt = (alu_x1_pass      & alu_x1_dst_id_valid)
                    | (alu_x2_mva_r & dmp_x2_mva_stall_r & (~x3_flush_r))
                    | ((alu_x2_rb_req_r & (~x2_alu_rb_ack)) & (~x3_flush_r));


  alu_x2_stall      = alu_x2_rb_req_r & (~x2_alu_rb_ack);
end


/////////////////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

// spyglass disable_block Reset_check07
// SMD: Clear pin of sequential element is driven by combinational logic
// SJ:  Intended to merge all reset sources
always @(posedge clk or posedge rst_a)
begin : alu_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    alu_x2_valid_r    <= 1'b0;
    alu_x2_dst_id_r   <= 5'd0;
    alu_x2_mva_r      <= 1'b0;
    alu_x2_rb_req_r   <= 1'b0;
  end
  else
  begin
    if (alu_x2_ctl_cg0 == 1'b1)
    begin
      alu_x2_valid_r    <= alu_x2_valid_nxt;
      alu_x2_dst_id_r   <= alu_x2_dst_id_nxt;
      alu_x2_mva_r      <= x1_alu_ctl[`ALU_CTL_MVA] | x1_alu_ctl[`ALU_CTL_MVAS];
    end

    if (alu_x2_rb_req_cg0 == 1'b1)
      alu_x2_rb_req_r <= alu_x2_rb_req_nxt;
  end
end
// spyglass enable_block Reset_check07


always @(posedge clk or posedge rst_a)
begin : alu_x2_data_regs_PROC
  if (rst_a == 1'b1)
    alu_x2_data_r <= {`DATA_SIZE{1'b0}};
  else if (alu_x2_data_cg0 == 1'b1)
      alu_x2_data_r <= alu_x1_result;
end


/////////////////////////////////////////////////////////////////////////////////////////
//
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////

assign alu_x2_data = alu_x2_data_r;

endmodule // rl_alu

