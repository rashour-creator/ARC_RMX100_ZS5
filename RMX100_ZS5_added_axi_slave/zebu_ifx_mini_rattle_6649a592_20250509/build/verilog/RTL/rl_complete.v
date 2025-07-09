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
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_complete (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                   // clock signal
  input                          rst_a,                 // reset signal

 ///////// Reset PC ////////////////////////////////////////////////////////////////
 //
  input  [21:0]                  reset_pc_in,           // Input pins  defining RESET_PC[31:10]

  output  reg                    cycle_delay,

  ////////// X1 stage interface /////////////////////////////////////////////
  //
  input                          x1_pass,               // instruction passing to X2
  input [`PC_RANGE]              x1_pc,                 // X1 PC
  input [`INST_RANGE]            x1_inst,

  input                          x1_uop_commit,
  input                          x1_uop_valid,
  input [`UOP_CTL_RANGE]         x1_uop_ctl,

  ////////// X2 stage interface /////////////////////////////////////////////
  //
  input                          x2_valid_r,
  input                          x2_pass,
  input                          x2_replay,
  input                          x2_enable,
  input                          fencei_restart,
  input                          icmo_restart,
  input                          x1_inst_size,

  input                          br_x2_taken_r,
  input [`PC_RANGE]              br_x2_target_r,

  input                          csr_x2_write_pc,
  input [`DATA_RANGE]            csr_x2_wdata,

  input                          dmp_x2_load_r,
  input                          dmp_x2_grad_r,
  input                          dmp_x2_retire_req,

  input                          ebreak,

  ////////// Halt manager interface /////////////////////////////////////////
  //
  input                          halt_restart_r,    // Request a pipe flush
  input                          halt_stop_r,       // Tell IFU to stop fetching

  ////////// Fetch restart Interface /////////////////////////////////////
  //
  output reg                     fch_restart,             // EXU requests IFU restart
  output reg                     fch_restart_vec,         //
  output reg [`PC_RANGE]         fch_target,              //
  output reg                     fch_stop_r,              // EXU requests IFU halt

  ////////// Debugger interface /////////////////////////////////////////////
  //
  input                          db_active,
  input                          rb_rf_write1,
  input                          db_exception,
  output reg                     cpu_db_done,           // Debug instruction retired

  ////////// CSR flush interface /////////////////////////////////////////////
  //
  input                          csr_flush_r,           // CSR write causes pipe flush

  ////////// Trap interface and pipe control /////////////////////////////////
  //
  input                          trap_valid,            // valid trap
  input [`PC_RANGE]              trap_base,             // trap base
  input                          fatal_err,             // fatal double trap
  input                          int_valid,
  input                          irq_enable,
  input [7:0]                    irq_id,
  input                          vec_mode,
  input                          rnmi_synch_r,

  input                          trap_return,           // return from trap
  input [`ADDR_RANGE]            trap_epc,              // trap return address

  output reg                     cp_flush,              // (X2/commit) pipe flush
  output reg                     cp_flush_no_excp,      // Pipe flush not caused by trap

  ////////// Outputs /////////////////////////////////////////////////
  //
  output reg [`PC_RANGE]         x2_pc_r,               // x2 pc
  output reg                     x2_inst_size_r,        // x2 inst size 1:16bit/0:32bit
  output reg [`INST_RANGE]       x2_inst_r,             // x2 inst
  output reg [`PC_RANGE]         ar_pc_r                // architectural PC
);

// Local declarations
//
reg                  x2_pc_cg0;
reg [`PC_RANGE]      x2_pc_nxt;

reg                  ar_pc_cg0;
reg [`PC_RANGE]      ar_pc_nxt;
reg                  x2_uop_commit_r;
reg                  x2_uop_valid_r;
reg [`UOP_CTL_RANGE] x2_uop_ctl_r;

wire             x2_valid_replay;
wire             x2_taken_branch;

// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width
// SJ:  Intended as per the design. No possible loss of data
wire [`PC_RANGE]   int_base;
assign int_base = trap_base + {22'b0, irq_id, 1'b0};
// spyglass enable_block W164a

assign x2_valid_replay = x2_valid_r & x2_replay;
assign x2_taken_branch = x2_pass    & br_x2_taken_r;

//////////////////////////////////////////////////////////////////////////////////////////
// Select where to restart the IFU
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : fch_target_PROC
  // There are four different sources for the IFU restart target PC
  //
  fch_restart = 1'b0;
  fch_stop_r  = halt_stop_r;

  if (trap_valid)
  begin // enter should have higher priority than return
    fch_restart          = 1'b1;
    fch_target           = (int_valid & vec_mode & irq_enable & (!rnmi_synch_r)) ? int_base : trap_base;
    fch_restart_vec      = 1'b1;
  end
  else if (trap_return)
  begin
    // This is a post-commit action
    //
    fch_restart          = 1'b1;

    fch_target           = trap_epc[`PC_RANGE];
    fch_restart_vec      = 1'b0;
  end
  else if (x2_valid_replay)
  begin
    fch_restart          = 1'b1;

    fch_target           = x2_pc_r;
    fch_restart_vec      = 1'b0;
  end
  else if ((fencei_restart) | (icmo_restart))
  begin
    fch_restart          = 1'b1;

    fch_target           = ar_pc_r + 2'b10;
    fch_restart_vec      = 1'b0;
  end
  else
  begin
    fch_restart          = halt_restart_r // @@@ debug flush, etc
                         | csr_flush_r
                         ;

    fch_target           = ar_pc_r;
    fch_restart_vec      = 1'b0;
  end
end


//////////////////////////////////////////////////////////////////////////////////////////
// Architectural PC next value
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : ar_pc_nxt_PROC
  // Default values
  //
  ar_pc_cg0 = fch_restart
            | csr_x2_write_pc
            | (x2_pass & (~db_active))
            | ebreak
            //|
            ;
// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width
// SJ:  Intended as per the design. No possible loss of data
  ar_pc_nxt = ar_pc_r + (x2_inst_size_r ? 2'b01 : 2'b10);
// spyglass enable_block W164a

  if (fch_restart)
  begin
    ar_pc_nxt = fch_target;
  end
  else if (csr_x2_write_pc & db_active) // /*debug writing to CSR*/
  begin
    ar_pc_nxt = csr_x2_wdata[`PC_RANGE];
  end
  else if (  ebreak
           | (x2_uop_valid_r & ~x2_uop_commit_r)
           | (|x2_uop_ctl_r)
          )
  begin
    ar_pc_nxt = ar_pc_r;
  end
  else if (x2_taken_branch)
  begin
    ar_pc_nxt = br_x2_target_r;
  end
end

wire  cp_int_allowed;
assign cp_int_allowed             = 1'b1; // @@@ place holder (e.g.: executing AMO instruction, not in halt mode, etc.)


//////////////////////////////////////////////////////////////////////////////////////////
//
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : cp_int_exc_PROC
  // Flusing the pipeline
  //
  cp_flush        = x2_valid_replay
                  | halt_restart_r
                  | csr_flush_r
                  | trap_valid
                  | trap_return
                  | fatal_err;

  cp_flush_no_excp = csr_flush_r | trap_return | halt_restart_r;
end


wire x2_load_uncached;
assign x2_load_uncached = dmp_x2_load_r & dmp_x2_grad_r;

//////////////////////////////////////////////////////////////////////////////////////////
//  Debug
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : db_done_PROC
  // Commit/retirement of debug instructions
  //
  cpu_db_done = db_active
              & (   rb_rf_write1 | dmp_x2_retire_req // LD retiring
                 | (x2_pass & (~x2_load_uncached))   // Commit of instruction, excluding ucached loads
                 | db_exception                      // Commits with a precise exception
                );
end

//////////////////////////////////////////////////////////////////////////////////////////
// Commit stage PC next value
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : x2_pc_nxt_PROC
  // Default values
  //
  x2_pc_cg0 = x1_pass;
  x2_pc_nxt = x1_pc;
end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : delay_reg_PROC
  if (rst_a == 1'b1)
  begin
    cycle_delay <= 1'b1;
  end
  else
  begin
      cycle_delay <= 1'b0;
  end
end

always @(posedge clk or posedge rst_a)
begin : x2_pc_reg_PROC
  if (rst_a == 1'b1)
  begin
    x2_pc_r <= `PC_SIZE'd`CORE_RESET_PC;
  end
  else
  begin
    if (x2_pc_cg0 == 1'b1)
    begin
      x2_pc_r <= x2_pc_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : x2_inst_reg_PROC
  if (rst_a == 1'b1) begin
    x2_inst_r <= `INST_SIZE'd0;
  end
  else begin
    if (x1_pass & x2_enable) begin
      x2_inst_r <= x1_inst;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : ar_pc_reg_PROC
  if (rst_a == 1'b1)
  begin
    ar_pc_r <= `PC_SIZE'd`CORE_RESET_PC;
  end
  else
  begin
    if (ar_pc_cg0
                | cycle_delay
        )
    begin
      ar_pc_r <=
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ : Intended as per the design
                 cycle_delay ? {reset_pc_in, 9'd0} :
// spyglass enable_block RegInputOutput-ML
          ar_pc_nxt;
    end
  end
end
always @(posedge clk or posedge rst_a)
begin : uop_commit_reg_PROC
  if (rst_a == 1'b1)
  begin
    x2_uop_commit_r <= 1'b0;
  end
  else
  begin
    if (x2_enable == 1'b1)
    begin
      x2_uop_commit_r <= x1_uop_commit;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : inst_size_reg_PROC
  if (rst_a == 1'b1)
  begin
    x2_inst_size_r <= 1'b0;
  end
  else
  begin
    if (x2_enable
                & (!x1_uop_valid)  // x2_inst_size should stick to the original push/pop during uop sequence
                )
    begin
      x2_inst_size_r <= x1_inst_size;
    end
  end
end
always @(posedge clk or posedge rst_a)
begin : uop_valid_reg_PROC
  if (rst_a == 1'b1)
  begin
    x2_uop_valid_r <= 1'b0;
    x2_uop_ctl_r   <= `UOP_CTL_WIDTH'b0;
  end
  else
  begin
    if (x2_enable == 1'b1)
    begin
      x2_uop_valid_r <= x1_uop_valid;
      x2_uop_ctl_r   <= x1_uop_ctl;
    end
  end
end


endmodule // rl_complete

