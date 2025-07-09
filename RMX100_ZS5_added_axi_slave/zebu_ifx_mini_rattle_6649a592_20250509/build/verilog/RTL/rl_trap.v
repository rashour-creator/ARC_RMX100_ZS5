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
//  The module hierarchy, at and below this module, is:
//
//         rl_trap
//
// ===========================================================================
//
// Configuration-dependent macro definitions
//
`include "defines.v"
`include "ifu_defines.v"
`include "clint_defines.v"
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_trap (
  ////////// IFU exceptions ////////////////////////////////////////////////
  //
  input [`IFU_EXCP_RANGE]    ifu_x1_excp,     // (X1) IFU exception
  input                      x2_inst_trap,    // (X2) INST exception
  input                      ext_trig_trap,
  input [`IFU_ADDR_RANGE]    x1_pmp_addr_r,
  
  //////////  EXU violations //////////////////////////////////////////////
  //
  input                      csr_x1_illegal,   // (X1) illegal X1 access
  input                      inst_x1_illegal,  // (X1) illegal X1 inst
  input                      spc_x2_ecall,     // (X2) ECALL
  input                      spc_x2_ebreak,

  ////////// DMP exceptions ////////////////////////////////////////////////
  //
  input [`DMP_EXCP_RANGE]    dmp_x2_excp,       // (X2) DMP exception
  input [1:0]                dmp_excp_async,    // (Post-commit) DMP exception
  input [`ADDR_RANGE]        dmp_x2_addr,       // (X2) DMP address

  ////////// Interrupts ////////////////////////////////////////////////////
  //
  input                      irq_trap,          // (X2) Interrupts
  input [7:0]                irq_id,            // (X2) Cause code
  input                      irq_enable,

  ////////// Pipe control /////////////////////////////////////////////////
  //
  input                      x1_pass,           // pipe control
  input [`INST_RANGE]        x1_inst,
  input [`PC_RANGE]          x1_pc,
  input                      x2_enable,         // pipe control
  input                      x2_valid_r,
  input                      x2_flush,
  input                      jalt_done,
  input                      i_cp_flush_no_excp,  // pipe flush caused by other reason
  input                      iesb_barrier,
  input [1:0]                priv_level_r,
  input                      mdt_r,
  input                      iesb_replay,
  input                      iesb_block_excpn,
  input                      iesb_block_int,

  //////////// Outputs ////////////////////////////////////////////////////////
  //
  output reg                 trap_x2_valid,     // Trap indication - interrupt or exception
  output reg [`DATA_RANGE]   trap_x2_cause,     // Cause code
  output reg [`DATA_RANGE]   trap_x2_data,      // Exception data for mtval
  output                     trap_ack,
  output                     irq_wakeup,
  output reg                 fatal_err,         // Fatal double trap that halt the core

  output                     precise_x2_excpn,
  output                     imprecise_x2_excpn,
  output reg                 take_int,

  //////////// Debug //////////////////////////////////////////////////////////
  //
  input                      debug_mode,
  input                      relaxedpriv,
  output                     db_exception,      // dmp exception during debug, used by dmp for store qualifier
  output                     cpu_invalid_inst,

  //////////// NMI ////////////////////////////////////////////////////////////
  //
  input                      rnmi_synch_r,
  input                      rnmi_enable,
  input                      pipe_blocks_trap,
  
  ////////// General input signals /////////////////////////////////////////////
  //
  input                      clk,               // clock signal
  input                      rst_a              // reset signal
);

// Local Declarations
//
reg                   x2_cg0;
reg [`PC_RANGE]       x2_pc_r;

reg [`IFU_EXCP_RANGE] ifu_x2_excp_r;
reg [`IFU_EXCP_RANGE] ifu_x2_excp;  
reg                   csr_x2_illegal_r;
reg                   inst_x2_illegal_r;

reg                   x2_illegal_instruction;
reg [`INST_RANGE]     x2_inst_r;
reg [`IFU_ADDR_RANGE] x2_pmp_addr_r;
wire                  x2_pmp_viol;
wire                  irq_trap_e;
assign irq_trap_e = irq_trap & irq_enable
                    ;

wire                  rnmi_e;   // RNMI interrupt
// any trap that (1) M-mode when NMIE is 0 (2) any mode when MDT is 1 and NMIE is 0
wire                  dbl_trap_sync;
wire                  dbl_trap_async;
wire                  dbl_trap;
assign dbl_trap_sync   = (|ifu_x2_excp) | x2_illegal_instruction | spc_x2_ecall | (|dmp_x2_excp) | spc_x2_ebreak;
assign dbl_trap_async  = (|dmp_excp_async) | irq_trap_e; 
assign dbl_trap = (dbl_trap_sync | dbl_trap_async) & (!rnmi_enable) & ((priv_level_r == `PRIV_M) | mdt_r);
wire                  cp_flush_no_excp;

assign cp_flush_no_excp = i_cp_flush_no_excp | iesb_barrier;
assign rnmi_e     = rnmi_synch_r & rnmi_enable;

always @* 
begin : x2_trig_trap_PROC
  // Mix x2_inst_trap in ifu_x2_excp
  ifu_x2_excp = ifu_x2_excp_r;
  ifu_x2_excp[`IFU_EXCP_BREAK] = x2_inst_trap;
end

always @*
begin : x2_cg_PROC
  // Derive clock-gates for transferring exception info from X1 to X2
  //
  x2_cg0 = trap_x2_valid | iesb_replay | x2_flush
         | (x1_pass & x2_enable)
         ;
end

always @*
begin : x2_illegal_PROC
  // Combine all sources of illegal instruction exception
  //
  x2_illegal_instruction = csr_x2_illegal_r
                           | inst_x2_illegal_r
                         //|                  // others
                         ;
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Exception prioritization                                                      
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : excp_prio_PROC
  // Default values
  //
  trap_x2_valid = 1'b0;
  trap_x2_cause = {`DATA_WIDTH{1'b0}};
  trap_x2_data  = {`DATA_WIDTH{1'b0}};
  fatal_err     = 1'b0;
  take_int      = 1'b0;

  if (~debug_mode) begin
  case (1'b1)

  // Fatal double trap
  dbl_trap:
  begin
    fatal_err   = dbl_trap_sync ? (x2_valid_r & (!cp_flush_no_excp)) : 1'b1;
  end
  
  // External RNMI
  //
  rnmi_e:
  begin
    take_int      = 1'b1;
    trap_x2_valid = !(pipe_blocks_trap|iesb_block_int);
    trap_x2_cause = {`TRAP_CAUSE_INT, `RV_RNMI_EXT}; 
  end

  // Interrupts
  //
  irq_trap_e:
  begin
    take_int      = 1'b1;
    trap_x2_valid = !(pipe_blocks_trap|iesb_block_int);
    trap_x2_cause = {`TRAP_CAUSE_INT, 23'b0, irq_id};
  end

  // Bus error
  dmp_excp_async[`DMP_EXCP_BUS]:
  begin
    trap_x2_valid = !(pipe_blocks_trap|iesb_block_excpn);
    trap_x2_cause = (priv_level_r == `PRIV_M) ? {`TRAP_CAUSE_EXC, `RV_BUS_ERR_M} : {`TRAP_CAUSE_EXC, `RV_BUS_ERR_U};
  end
  // DMP breakpoint
  //
  dmp_excp_async[`DMP_EXCP_BREAK]:
  begin
    trap_x2_valid = !(pipe_blocks_trap|iesb_block_excpn);   // imprecise exception, x2_valid is not needed
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_BREAK};  
    trap_x2_data  = dmp_x2_addr;
  end

  ext_trig_trap:
  begin
    trap_x2_valid = !(pipe_blocks_trap|iesb_block_excpn);   // imprecise exception, x2_valid is not needed
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_BREAK};  
  end

  // ECC error which is precise
  //
  ifu_x2_excp[`IFU_EXCP_ECC]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_UNC_HW_ERROR};
  end

  dmp_x2_excp[`DMP_EXCP_ECC]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_UNC_HW_ERROR};
  end

  // Instruction breakpoint
  //
  ifu_x2_excp[`IFU_EXCP_BREAK]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_BREAK};  
    trap_x2_data  = {x2_pc_r, 1'b0};
  end

  ifu_x2_excp[`IFU_EXCP_BUS]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = (priv_level_r == `PRIV_M) ? {`TRAP_CAUSE_EXC, `RV_BUS_ERR_M} : {`TRAP_CAUSE_EXC, `RV_BUS_ERR_U};
  end

  // Instruction access spans two targets
  //

  // Instruction access fault
  //
  ifu_x2_excp[`IFU_EXCP_FA_BLACK_HOLE]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_ACC_FAULT};
  end

  // Instruction PMP violation
  //
  ifu_x2_excp[`IFU_EXCP_PMP_FAULT]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_ACC_FAULT};  
    trap_x2_data  = (({x2_pc_r, 1'b0} > {x2_pmp_addr_r, 2'b0}) & (!jalt_done)) ? {x2_pc_r, 1'b0} : {x2_pmp_addr_r, 2'b0};
  end

  // Illegal instruction....
  //
  x2_illegal_instruction:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_ILLEGAL};  
  end

  // Environment call
  //
  spc_x2_ecall:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = (priv_level_r == `PRIV_M) ? {`TRAP_CAUSE_EXC, `RV_MCALL} : {`TRAP_CAUSE_EXC, `RV_UCALL}; //@@@ SCALL to be added
  end
  
  // Instruction breakpoint
  //
  spc_x2_ebreak:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_BREAK};  
    trap_x2_data  = {x2_pc_r, 1'b0};
  end
  dmp_x2_excp[`DMP_EXCP_ABREAK]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_INST_BREAK};  
    trap_x2_data  = dmp_x2_addr;
  end

  dmp_x2_excp[`DMP_EXCP_LD_SP_MULT_MEM]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_LD_STRADDLE};
  end

  dmp_x2_excp[`DMP_EXCP_ST_SP_MULT_MEM]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_ST_STRADDLE};
  end

  // LD address misaligned
  //
  dmp_x2_excp[`DMP_EXCP_LD_MISALIGNED]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_LD_MISAL};
    trap_x2_data  = dmp_x2_addr;
  end

  // ST/AMO address misaligned
  //
  dmp_x2_excp[`DMP_EXCP_ST_MISALIGNED]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_ST_MISAL};
    trap_x2_data  = dmp_x2_addr;
  end
  
  // LD access fault
  //
  dmp_x2_excp[`DMP_EXCP_LD_PMP_FAULT]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_LD_FAULT};
    trap_x2_data  = dmp_x2_addr;
  end

  // ST/AMO access fault
  //
  dmp_x2_excp[`DMP_EXCP_ST_PMP_FAULT],
  dmp_x2_excp[`DMP_EXCP_ST_ACC_FAULT]:
  begin
    trap_x2_valid = x2_valid_r & (!cp_flush_no_excp);
    trap_x2_cause = {`TRAP_CAUSE_EXC, `RV_ST_FAULT};
    trap_x2_data  = dmp_x2_addr;
  end

  
  default:
  begin
    trap_x2_valid = 1'b0;
    trap_x2_cause = {`DATA_WIDTH{1'b0}};
    trap_x2_data  = {`DATA_WIDTH{1'b0}};
  end
  endcase   
  end

end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : ifu_excp_regs_PROC
  if (rst_a == 1'b1)
  begin
    ifu_x2_excp_r     <= {`IFU_EXCP_WIDTH{1'b0}};
    csr_x2_illegal_r  <= 1'b0;
    inst_x2_illegal_r <= 1'b0;
    x2_inst_r         <= `DATA_SIZE'h0;
    x2_pc_r           <= `PC_SIZE'h0;
    x2_pmp_addr_r     <= `IFU_ADDR_BITS'h0;
  end
  else
  begin
    if (x2_cg0 == 1'b1)
    begin
      ifu_x2_excp_r     <= ifu_x1_excp     & {`IFU_EXCP_WIDTH{x1_pass}};
      csr_x2_illegal_r  <= csr_x1_illegal  & x1_pass;
      inst_x2_illegal_r <= inst_x1_illegal & x1_pass;
      x2_pc_r           <= x1_pc           & {`PC_SIZE{x1_pass}};
      x2_inst_r         <= x1_inst         & {`INST_SIZE{x1_pass}};
      x2_pmp_addr_r     <= x1_pmp_addr_r   & {`IFU_ADDR_BITS{x1_pass}};
    end
  end

end

assign trap_ack = irq_trap_e & (!pipe_blocks_trap) & (!debug_mode) & (!rnmi_e);

assign irq_wakeup = 1'b0
                    | irq_trap
                    | rnmi_synch_r
                    ;

assign cpu_invalid_inst = inst_x2_illegal_r | db_exception;
assign x2_pmp_viol = dmp_x2_excp[`DMP_EXCP_LD_PMP_FAULT] | dmp_x2_excp[`DMP_EXCP_ST_PMP_FAULT];
assign db_exception = ((x2_pmp_viol & (!relaxedpriv))
                    | dmp_x2_excp[`DMP_EXCP_LD_MISALIGNED]
                    | dmp_x2_excp[`DMP_EXCP_LD_SP_MULT_MEM]
                    | dmp_x2_excp[`DMP_EXCP_ST_SP_MULT_MEM]
                    | dmp_x2_excp[`DMP_EXCP_ST_MISALIGNED]
                    | dmp_x2_excp[`DMP_EXCP_ST_ACC_FAULT]
                    | dmp_x2_excp[`DMP_EXCP_ECC]) & debug_mode & x2_valid_r
                    ;

assign precise_x2_excpn = (x2_illegal_instruction | (|ifu_x2_excp) | (|dmp_x2_excp) | spc_x2_ecall | spc_x2_ebreak) & (x2_valid_r) & (~debug_mode) & (!i_cp_flush_no_excp);
assign imprecise_x2_excpn = (|dmp_excp_async) & (~debug_mode);

endmodule // rl_regfile

