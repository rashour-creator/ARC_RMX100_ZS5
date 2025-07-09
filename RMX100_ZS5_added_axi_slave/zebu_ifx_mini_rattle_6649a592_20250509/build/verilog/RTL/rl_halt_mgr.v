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
`include "csr_defines.v"
`include "ifu_defines.v"
`include "mpy_defines.v"
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_halt_mgr (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                // clock signal
  input                          rst_a,              // reset signal

  ////////// Debug Halt Request Interface ////////////////////////////////////
  //
  input                          db_request,         // Debug halt request
  output reg                     cpu_db_ack_r,       // Debug ack


  ////////// Machine Global Halt/Run request Interface ///////////////////////
  //
  input                          dm2arc_halt_on_reset,// DM asserted halt on reset
  input                          is_dm_rst,
  input                          gb_sys_run_req_r,   // Machine run request
  input                          gb_sys_halt_req_r,  // Machine halt request

  output reg                     gb_sys_run_ack_r,   // Machine run acknowledge
  output reg                     gb_sys_halt_ack_r,  // Machine halt acknowledge

  ////////// Pipeline Interface //////////////////////////////////////////////
  //
  input                          commit,             // Instruction Commit
  input                          x1_inst_break_r,     // Trigger inst break in I-stage
  input                          x2_inst_break,       // Trigger inst break in X2
  input                          dmp_addr_trig_break,
  input                          dmp_ld_data_trig_break,
  input                          dmp_st_data_trig_break,
  input                          ext_trig_break,
  input                          x1_pass,            // To save inst break in X1
  input                          ebreak,             // EBREAK instruction
  input                          fatal_err,          // FATAL double trap
  input                          fatal_err_dbg,      // Fatal double trap debug or not
  input                          wfi,                // WFI instruction
  input                          irq_wakeup,         // IRQ Wake
  output reg [2:0]               halt_cond_r,
  input                          ato_vec_jmp,       // Atomic vetor jump, don't disturb

  output reg                     halt_restart_r,    // Request a pipe flush
  output reg                     halt_stop_r,       // Tell IFU to stop fetching
  input                          cpu_db_done,       // Debug instruction finished
  output reg                     halt_req_asserted_r,
  output                         halt_fsm_in_rst,
  output                         debug_mode,
  input                          single_step,
  input                          db_active,

  ////////// Machine status ///////////////////////////////////////////////
  //
  output                         pipe_blocks_trap,
  output                         step_blocks_irq,
  input                          stepie,

  input                          ifu_idle_r,         // IFU is idle
  input                          dmp_idle_r,         // DMP is idle
  input                          biu_idle_r,         // BIU is idle
  input                          spc_x2_stall,       // special insn in X2, potential pipe restart
  input                          mpy_busy,

  input                          uop_busy_del,
  input                          uop_busy_ato,

  output reg                     gb_sys_halt_r,      // Machine is Halted
  output reg                     gb_sys_sleep_r      // Machine is Sleeping
);

// Local Declarations
//

reg       debug_mode_r;
reg       debug_mode_nxt;
reg       wfi_r;
reg       wfi_nxt;
reg       halt_req_asserted_nxt;

reg       inst_x2_break_r;

reg [2:0] halt_state_r;
reg [2:0] halt_state_nxt;
reg       halt_ctl_cg0;

reg       halt_restart_nxt;
reg       halt_stop_nxt;
reg       cpu_db_ack_nxt;

reg       gb_sys_halt_ack_nxt;
reg       gb_sys_run_ack_nxt;
reg       gb_sys_halt_nxt;
reg       gb_sys_sleep_nxt;
reg       arch_h_r;
reg       arch_h_nxt;
reg       in_step_r;
reg       in_step_nxt;

wire      hold_halt;
wire      sync_halt;
wire      all_idle;
wire      ebreak_halt;
wire      single_step_halt;
wire      ce_halt;
reg [2:0] halt_cond_nxt;
reg       trig_action;
reg       dbl_trap_ce_nxt;
reg       dbl_trap_ce_r;

// Handy
//
reg uop_busy_ato_r;
always @(posedge clk or posedge rst_a)
begin: uop_busy_ato_r_PROC
  if (rst_a)
    uop_busy_ato_r <= 1'b0;
  else
    uop_busy_ato_r <= uop_busy_ato;
end

assign all_idle  = ifu_idle_r
                 & dmp_idle_r
                 & biu_idle_r
                 & ~mpy_busy
                 & (~uop_busy_del)
                 & (~uop_busy_ato_r)
                 ;


assign ebreak_halt      = ebreak & commit;
assign single_step_halt = single_step & commit & (~db_active)
                        & (~uop_busy_del)
                        & (~uop_busy_ato_r)
                            ;
assign ce_halt          = (fatal_err & fatal_err_dbg);
assign sync_halt = ((ebreak | wfi)  & commit) | single_step_halt
                    | trig_action
                    | ce_halt
                    ;
always @(posedge clk or posedge rst_a)
begin : trigger_regs_PROC
  if (rst_a == 1'b1)
  begin
      trig_action      <= 1'b0;
  end
  else
  begin
      trig_action      <= ((x1_inst_break_r & x1_pass)
                          | (x2_inst_break & commit)
                          | (dmp_addr_trig_break & commit)
                          | dmp_ld_data_trig_break
                          | ext_trig_break
                          | (dmp_st_data_trig_break & commit)
                          );
  end
end
assign hold_halt = spc_x2_stall // don't halt if there is one potential pipe restart pending in X2
                 | ato_vec_jmp // don't halt during atomic vector jump
                 | uop_busy_del
                 ;


//////////////////////////////////////////////////////////////////////////////
//
// Halt FSM
//
//////////////////////////////////////////////////////////////////////////////

localparam FSM_RUN          = 3'b000;
localparam FSM_HALTING      = 3'b001;
localparam FSM_HALTED       = 3'b010;
localparam FSM_RESET        = 3'b011;
localparam FSM_WAIT_DB_DONE = 3'b100;
localparam FSM_UNHALT       = 3'b101;
localparam FSM_RUN_DB       = 3'b110;
localparam FSM_RUN_DB_DONE  = 3'b111;

// spyglass disable_block  Ac_conv01
// SMD: Reports signals from the same domain that are synchronized in the same destination domain and converge after any number of sequential elements
// SJ : Unrelated pins converging at csr_rdata
always @*
begin : halt_fsm_PROC
  // Default values
  //

  cpu_db_ack_nxt      = 1'b0;

  halt_restart_nxt    = 1'b0;
  halt_stop_nxt       = 1'b0;

  halt_ctl_cg0        = 1'b1;
  in_step_nxt         = in_step_r;
  halt_state_nxt      = halt_state_r;
  arch_h_nxt          = 1'b0;
  wfi_nxt             = wfi_r;
  debug_mode_nxt      = debug_mode_r;
  dbl_trap_ce_nxt     = dbl_trap_ce_r;
  halt_req_asserted_nxt   = 1'b0;

  case (halt_state_r)
  FSM_RESET:
  begin
    // Wait for HW initialization before we halt
    //
    halt_restart_nxt    = 1'b1;

    if (is_dm_rst)
    begin
      halt_state_nxt      = dm2arc_halt_on_reset ? FSM_HALTED : FSM_RUN;
      halt_stop_nxt       = dm2arc_halt_on_reset ? 1'b1 : 1'b0;
      arch_h_nxt          = dm2arc_halt_on_reset ? 1'b1 : 1'b0;
      debug_mode_nxt      = dm2arc_halt_on_reset ? 1'b1 : 1'b0;
    end
    else
    begin
      halt_state_nxt      = FSM_HALTED;
      halt_stop_nxt       = 1'b1;
      arch_h_nxt          = 1'b1;
      debug_mode_nxt      = 1'b1;
    end
  end

  FSM_RUN:
  begin
    // gb_sys_run_ack_r is evaluated for halt_ctl_cg0 so that halt manager can de-assert gb_sys_run_ack_r when gb_sys_run_req_r is de-asserted
    halt_ctl_cg0 = 1'b0 |
                   sync_halt | 
	               gb_sys_halt_req_r | 
				   db_request | 
				   halt_restart_r | 
				   gb_sys_run_ack_r |
				   fatal_err
				   ; 
    arch_h_nxt   = arch_h_r;
    if (sync_halt)
    begin
      // Software break-point...
      //
      arch_h_nxt       = 1'b1;
      halt_restart_nxt = 1'b1;
      halt_stop_nxt    = 1'b1;
      in_step_nxt      = 1'b0;
      halt_state_nxt   = FSM_HALTING;
      wfi_nxt          = wfi;
      halt_req_asserted_nxt= 1'b1;
    end
    else if (fatal_err & (~fatal_err_dbg))
    begin
      arch_h_nxt       = 1'b0;
      halt_restart_nxt = 1'b1;
      halt_stop_nxt    = 1'b1;
      in_step_nxt      = 1'b0;
      halt_state_nxt   = FSM_HALTING;
      dbl_trap_ce_nxt  = 1'b1;
      halt_req_asserted_nxt= 1'b1;
    end
    else if (  gb_sys_halt_req_r 
            || arch_h_r
            )
    begin
      if (hold_halt == 1'b0)
      begin
        // Tell the IFU to stop fetching
        //
        arch_h_nxt       = 1'b0;
        halt_restart_nxt = 1'b1;
        halt_stop_nxt    = 1'b1;
        in_step_nxt      = 1'b0;
        halt_state_nxt   = FSM_HALTING;
        halt_req_asserted_nxt= 1'b1;
      end
    end
    else if (db_request)
    begin
      // Debugger wants to come in
      //
      if (hold_halt == 1'b0)
      begin
        // Tell the IFU to stop fetching - do not ack the debugger yet
        //
        halt_restart_nxt = 1'b1;
        halt_stop_nxt    = 1'b1;
        halt_state_nxt   = FSM_RUN_DB;
      end
    end
  end

  FSM_RUN_DB:
  begin
    if (all_idle)
    begin
      cpu_db_ack_nxt   = 1'b1;
      halt_state_nxt   = FSM_RUN_DB_DONE;
    end
    else
    begin
      halt_stop_nxt    = 1'b1;  // Keep IFU stop
    end
  end

  FSM_RUN_DB_DONE:
  begin
    if (cpu_db_done)
    begin
      // Debugger inserted instruction completed
      //
      halt_restart_nxt = 1'b1;
      halt_state_nxt   = FSM_RUN;
    end
  end

  FSM_HALTING:
  begin
    arch_h_nxt       = 1'b0;
    halt_req_asserted_nxt= 1'b1;
    if (all_idle)
    begin
      arch_h_nxt       = 1'b1;
      halt_state_nxt   = FSM_HALTED;
      debug_mode_nxt   = ~(wfi_r | dbl_trap_ce_r);
      halt_stop_nxt    = 1'b1;  // Keep IFU stop
    end
    else
      halt_stop_nxt    = 1'b1;  // Keep IFU stop
  end

  FSM_HALTED:
  begin
    arch_h_nxt       = 1'b1;
    in_step_nxt      = 1'b0;
    halt_stop_nxt    = 1'b1;
    if (db_request)
    begin
      cpu_db_ack_nxt = 1'b1;
      halt_state_nxt = FSM_WAIT_DB_DONE;
    end
    else if (wfi_r == 1'b1)
    begin
	  if (irq_wakeup == 1'b1)
      begin
        wfi_nxt           = 1'b0;
        halt_state_nxt    = FSM_UNHALT;
        halt_stop_nxt     = 1'b0;
      end
      else if (gb_sys_halt_req_r
		      )
      begin
        wfi_nxt           = 1'b0;
        debug_mode_nxt    = 1'b1;
      end
    end
    else
    begin
      // Anyone unhalting the core?
      //
      if (((gb_sys_run_req_r == 1'b1) 
           & (gb_sys_halt_req_r == 1'b0)
           )
		  )
      begin
        halt_state_nxt    = FSM_UNHALT;
        halt_stop_nxt     = 1'b0;
        if (single_step)
        begin
          in_step_nxt     = 1'b1;
        end
        dbl_trap_ce_nxt   = 1'b0;
      end
    end
  end

  FSM_WAIT_DB_DONE:
  begin
    arch_h_nxt     =  arch_h_r;
    halt_stop_nxt  = 1'b1;
    if (cpu_db_done)
    begin
      // Debugger inserted instruction completed
      //
      halt_state_nxt = FSM_HALTED;
    end
  end

  default: // FSM_UNHALT
  begin
    // Flush the pipe and start runnin again
    //
    arch_h_nxt       = 1'b0;
    halt_restart_nxt = 1'b1;
    debug_mode_nxt   = 1'b0;
    halt_state_nxt   = FSM_RUN;
  end
  endcase
end
// spyglass enable_block  Ac_conv01

always@*
begin: sys_PROC
  gb_sys_halt_nxt  = ((halt_state_nxt == FSM_HALTED) |
                     (halt_state_nxt == FSM_WAIT_DB_DONE)) & (~wfi_r);
  gb_sys_sleep_nxt = ((halt_state_nxt == FSM_HALTED) |
                     (halt_state_nxt == FSM_WAIT_DB_DONE)) & (wfi_r);
end

always@*
begin: sys_ack_PROC
  gb_sys_run_ack_nxt  = ((gb_sys_run_req_r  == 1'b1)
                         & (halt_state_r == FSM_RUN));

// halt should not acked before wfi cleared
  gb_sys_halt_ack_nxt  = gb_sys_halt_ack_r ? gb_sys_halt_req_r :
                                            (gb_sys_halt_req_r & (halt_state_nxt == FSM_HALTED) & (!wfi_r));
end


//////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin: halt_regs_PROC
  if (rst_a == 1'b1)
  begin
    halt_state_r      <= FSM_RESET;
    arch_h_r          <= 1'b1;
    cpu_db_ack_r      <= 1'b0;
    gb_sys_halt_r     <= 1'b1;
    gb_sys_sleep_r    <= 1'b0;
    gb_sys_halt_ack_r <= 1'b0;
    gb_sys_run_ack_r  <= 1'b0;
    halt_restart_r    <= 1'b0;
    halt_stop_r       <= 1'b0;
    in_step_r         <= 1'b0;
    wfi_r             <= 1'b0;
    dbl_trap_ce_r     <= 1'b0;
    halt_req_asserted_r <= 1'b0;
    debug_mode_r      <= 1'b1;
  end
  else
  begin
    if (halt_ctl_cg0 == 1'b1)
    begin
// spyglass disable_block CDC_COHERENCY_RECONV_SEQ CDC_COHERENCY_RECONV_COMB
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals
      halt_state_r      <= halt_state_nxt;
      arch_h_r          <= arch_h_nxt;
      cpu_db_ack_r      <= cpu_db_ack_nxt;
      gb_sys_halt_r     <= gb_sys_halt_nxt;
      gb_sys_sleep_r    <= gb_sys_sleep_nxt;
      gb_sys_halt_ack_r <= gb_sys_halt_ack_nxt; 
      gb_sys_run_ack_r  <= gb_sys_run_ack_nxt;  
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ CDC_COHERENCY_RECONV_COMB
      halt_restart_r    <= halt_restart_nxt;    
      halt_stop_r       <= halt_stop_nxt;       
      in_step_r         <= in_step_nxt;
     halt_req_asserted_r<= halt_req_asserted_nxt;
    end
    wfi_r             <= wfi_nxt;
    dbl_trap_ce_r     <= dbl_trap_ce_nxt;
    debug_mode_r      <= debug_mode_nxt;
  end
end

//////////////////////////////////////////////////////////////////////////////
//
// Output assignments
//
//////////////////////////////////////////////////////////////////////////////
always@*
begin
  halt_cond_nxt = halt_cond_r;
  if (halt_state_r == FSM_UNHALT)
  begin
    halt_cond_nxt = 3'b000;
  end
  else if ((halt_state_r == FSM_HALTED) & wfi_r & gb_sys_halt_req_r)
  begin
    halt_cond_nxt =  3'b011;
  end
  else if (halt_state_r == FSM_RUN)
  begin
  // spyglass disable_block DisallowCaseZ-ML
  // SMD: Do not use casez constructs in the design
  // SJ : Intended as per the design
    casez({ce_halt, trig_action, ebreak_halt, single_step_halt,gb_sys_halt_req_r})
    5'b1zzzz:
    begin
      halt_cond_nxt =  3'b111;
    end
    5'b01zzz:
    begin
      halt_cond_nxt =  3'b010;
    end
    5'b001zz:
    begin
      halt_cond_nxt =  3'b001;
    end
    5'b0001z:
    begin
      halt_cond_nxt =  3'b100;
    end
    5'b00001:
    begin
      halt_cond_nxt =  3'b011;
    end
    default:
    begin
    end
    endcase
    // spyglass enable_block DisallowCaseZ-ML
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    halt_cond_r <= 3'b000;
  end
  else
  begin
    halt_cond_r <= halt_cond_nxt;
  end
end

assign pipe_blocks_trap  = (halt_state_r != FSM_RUN)
                         |  ato_vec_jmp
                         |  uop_busy_ato_r
                         ;
assign debug_mode       = debug_mode_r;
assign step_blocks_irq  = in_step_r & (!stepie);
assign halt_fsm_in_rst  = (halt_state_r == FSM_RESET);


endmodule // rl_halt_mgr
