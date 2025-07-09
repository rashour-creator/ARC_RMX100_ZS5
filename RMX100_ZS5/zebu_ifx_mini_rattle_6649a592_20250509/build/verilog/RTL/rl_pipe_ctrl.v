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
`include "ifu_defines.v"
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_pipe_ctrl (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                   // clock signal
  input                          rst_a,                 // reset signal

  ////////// I stage interface /////////////////////////////////////////////
  //
  input                          ifu_issue,             // Valid instruction from IFU
  input                          db_valid,              // Debugger inserted instruction
  output reg                     x1_holdup,             // holds-up the IFU

  ////////// X1 stage interface /////////////////////////////////////////////
  //
  output reg                     x1_valid_r,            // X1 valid instruction
  output reg                     x1_pass,               // instruction passing to X2
  output reg                     x1_enable,             // X1 accepts new info
  input                          x1_br_taken,           // X1 BR taken
  input                          uop_busy,
  input                          uop_valid,
  input                          br_x1_stall,
  output reg                     x2_uop_valid_r,
  output reg                     x1_flush,
  input [1:0]                    x1_fu_stall,           // Dispatch stall, and DMP AMO aq/lr stall

  ////////// X2 stage interface /////////////////////////////////////////////
  //
  output reg                     x2_valid_r,            // X2 valid instructio
  output reg                     x2_pass,               // instruction passing to X3 (commit)
  output reg                     x2_enable,             // Enables X2 stage
  output reg                     x2_flush,              // pipeline flush
  output reg                     x2_retain,             // pipeline retain
  input [3:0]                    x2_fu_stall,           // from the functional units -- SPC, MPY, ALU, DMP
  input                          fencei_restart,        // Fencei instruction in x2 is restarting the X1
  input                          icmo_restart,
  input                          iesb_x2_holdup,

  ////////// X3 stage interface /////////////////////////////////////////////
  //
  output reg                     x3_valid_r,            // X3 valid instruction
  input [1:0]                    x3_fu_stall,           // from the functional units -- MPY, FPU
  output reg                     x3_flush_r,            // pipeline flush
  ////////// System interface /////////////////////////////////////////////
  //
  input                          cp_flush               // Complete unit requests a pipe flush
);

// Local declarations
//

reg x1_retain;
reg x1_stall;

reg x2_br_taken_r;
reg x2_holdup;
reg x2_stall;

reg x3_retain;
reg x3_enable;
reg x3_holdup;
reg x3_stall;

//===

reg x3_flush_nxt;


always @*
begin : pipe_flush_PROC
  //==========================================================================
  // Derive pipe flush signals (formerly known as k*ll)
  //
  x1_flush     = x2_br_taken_r
               | x3_flush_r
               | fencei_restart
               | icmo_restart
               | cp_flush;

  x2_flush     = x3_flush_r
               | cp_flush;

  x3_flush_nxt = x2_valid_r
               & (   1'b0 // x2_br_taken_r
                  |  cp_flush
                 // | ...
                  );
end


always @*
begin : pipe_stall_PROC
  //==========================================================================
  // Derive x1 stall signal
  //
  x1_stall = | x1_fu_stall; // any FU is stalling instruction in X1

  //==========================================================================
  // Derive x2 stall signal
  //
  x2_stall = | x2_fu_stall; // any FU is stalling instruction in X2

  //==========================================================================
  // Derive x3 stall signal
  //
  x3_stall = | x3_fu_stall; // any FU is stalling instruction in X3?
end


always @*
begin : pipe_ctrl_PROC
  //==========================================================================
  // Define the stage control signals for the x3 stage.
  //
  x3_holdup   = x3_valid_r & x3_stall;
  x3_retain   = 1'b0;
  x3_enable   = x3_flush_r | (~x3_retain);

  //==========================================================================
  // Define the stage control signals for the x2 stage.
  //
  x2_holdup   = (x2_valid_r & (x3_holdup | x2_stall))| iesb_x2_holdup;
  x2_retain   = ((x2_valid_r & x3_holdup) | x2_stall) & (~x2_flush);
  x2_enable   = x2_flush | (~x2_retain);
  x2_pass     = x2_valid_r & (~(x2_flush | x2_retain));

  //==========================================================================
  // Define the stage control signals for the x1 stage.
  //
  x1_holdup   = x1_valid_r   & (x2_holdup | x1_stall
                                | br_x1_stall
                                ) & (~x1_flush);
// spyglass disable_block CDC_COHERENCY_RECONV_SEQ CDC_COHERENCY_RECONV_COMB
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals
  x1_retain   = ((x1_valid_r & x2_holdup) | x1_stall
                                | br_x1_stall
                                ) & (~x1_flush);
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ CDC_COHERENCY_RECONV_COMB
  x1_enable   = x1_flush | (~x1_retain);
  x1_pass     = x1_valid_r & (~(x1_flush 
                               | x1_retain
                               ));

end


//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : pipe_valid_reg_PROC
  if (rst_a == 1'b1)
  begin
    x1_valid_r <= 1'b0;
    x2_valid_r <= 1'b0;
    x2_uop_valid_r <= 1'b0;
    x3_valid_r <= 1'b0;
  end
  else
  begin
    if (x1_enable == 1'b1)
    begin
      x1_valid_r <= ifu_issue | db_valid
                                        | uop_busy
                                        ;
    end

    if (x2_enable == 1'b1)
    begin
      x2_valid_r <= x1_pass;
      x2_uop_valid_r <= uop_valid;
    end

      x3_valid_r <= x2_pass;    // was x3_enable
  end
end

always @(posedge clk or posedge rst_a)
begin : misp_reg_PROC
  if (rst_a == 1'b1)
  begin
    x2_br_taken_r <= 1'b0;
  end
  else
  begin
    if (x2_enable == 1'b1)
    begin
      x2_br_taken_r <= x1_pass & x1_br_taken;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : x3_regs_PROC
  if (rst_a == 1'b1)
  begin
    x3_flush_r <= 1'b0;
  end
  else
  begin
    x3_flush_r <= x3_flush_nxt; // was x3_enable
  end
end

endmodule // rl_pipe_ctrl

