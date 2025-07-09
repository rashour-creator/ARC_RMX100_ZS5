
//----------------------------------------------------------------------------
//
// Copyright 2010-2015 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2012, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// #     #  #######  ######           #####   #######   #####
// #     #  #     #  #     #         #     #  #        #     #
// #     #  #     #  #     #         #        #        #     #
// #     #  #     #  ######           #####   #####    #     #
// #     #  #     #  #                     #  #        #   # #
// #     #  #     #  #               #     #  #        #    #
//  #####   #######  #        #####   #####   #######   #### #
//
// ===========================================================================
//
// Description:
//
// @f:uop_seq:
// @p
//  This module implements the micro-operation sequence of the ARCv5EM
//  processor. Its purpose is to emit the series of micro-instructions
//  associated with macro operations such as the reset vector, exceptions
//  fast- and slow- interrupts, and enter/leave instructions.
// @e
//  This .vpp source file may be pre-processed with the Verilog Pre-Processor
// (VPP) to produce the equivalent .v file using a command line such as:
//
//   vpp +q +o uop_seq.vpp
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"
`include "clint_defines.v"
`include "mpy_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_uop_seq (
  ////////// Control signals ///////////////////////////////////////////////
  //
  input                       x1_holdup,         // DA holdup
  input                       x1_pass,
  input [`UOP_CTL_RANGE]      fu_uop_ctl,

  input                       fch_restart,       // pipeline flush

  ////////// Micro-op outputs //////////////////////////////////////////////
  //
  output reg [`DATA_RANGE]    uop_inst,          // micro-op instruction
  output reg                  uop_valid,         // sequencer is source of insns
  output reg                  uop_busy,          // Holdup further operations
  output reg                  uop_busy_del,      // Holdup further operations, delayed signal
  output reg                  uop_busy_ato,      // sequence is atomic, prevent traps.
  output reg                  uop_commit,        // Final cycle of multi-cycle

  ////////// General input signals /////////////////////////////////////////
  //
  input                       clk,               // Processor clock
  input                       rst_a              // Asynchronous reset
);




// @dstreg_PROC
//
reg                         dstreg_en;
reg                         dstreg_init;
reg [`CNT_RANGE]            dstreg_delta;
reg [`CNT_RANGE]            dstreg_r;
reg [`CNT_RANGE]            dstreg_nxt;

// @uop_spoff_PROC
//
reg                         spoff_en;
reg [11:0]                  spoff_init;
reg [11:0]                  spoff_fin;
reg                         spoff_set;
reg [11:0]                  spoff_r;
reg [11:0]                  spoff_nxt;

// @uop_code_PROC
//
reg [`DATA_RANGE]           rd_opd;
reg [`DATA_RANGE]           rs2_opd;
reg [`DATA_RANGE]           imm1_opd;
reg [`DATA_RANGE]           imm2_opd;

wire uop_enter;
wire uop_leave;
assign uop_enter = fu_uop_ctl[`UOP_CTL_PUSH] & x1_pass;
assign uop_leave = fu_uop_ctl[`UOP_CTL_POP]  & x1_pass;

reg  [`UOP_CTL_RANGE] uop_opd_r;
wire     [`CNT_RANGE] uop_dstreg_max;
assign uop_dstreg_max = (uop_opd_r[`UOP_CTL_RLIST] == 4'd15) ? `CNT_BITS'd27 :
                        (uop_opd_r[`UOP_CTL_RLIST]  > 4'd6)  ? (uop_opd_r[`UOP_CTL_RLIST] + 4'd11) :
                        (uop_opd_r[`UOP_CTL_RLIST]  > 4'd4)  ? (uop_opd_r[`UOP_CTL_RLIST] + 4'd3) :
                        `CNT_BITS'd1;

reg eop_cond0, lop_cond0, lop_cond1, lop_cond2;
assign eop_cond0 = (dstreg_r == uop_dstreg_max);
assign lop_cond0 = (dstreg_r == uop_dstreg_max);
assign lop_cond1 = uop_opd_r[`UOP_CTL_RET];
assign lop_cond2 = uop_opd_r[`UOP_CTL_LI];


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @fsm_state_nxt_PROC                                                    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

// state enum
typedef enum int {
   FSM_IDLE
  ,FSM_ENTER_S1
  ,FSM_ENTER_S2
  ,FSM_LEAVE_S1
  ,FSM_LEAVE_S2
  ,FSM_LEAVE_S3
  ,FSM_LEAVE_S4
} fsm_state_e;

localparam NUM_STATES = 1 + 6 * `RV_C_OPTION + 2 * `RV_UDSP_OPTION;

// @fsm_state_nxt_PROC
//
logic [NUM_STATES-1:0] fsm_state_r, fsm_state_nxt;
always @*
begin: fsm_state_nxt_PROC

  // -------------------------------------------------------------------- //
  //                                                                      //
  //  Enter/Leave state transition logic                                  //
  //                                                                      //
  // -------------------------------------------------------------------- //

  // leda W71 off
  // leda FM_2_11 off
  fsm_state_nxt = fsm_state_r;
  if (fch_restart == 1'b1)
    fsm_state_nxt = (1 << FSM_IDLE);
  else case (1'b1)
    fsm_state_r[FSM_IDLE]:
      case (1'b1)
        uop_enter: fsm_state_nxt = (1 << FSM_ENTER_S1);
        uop_leave: fsm_state_nxt = (1 << FSM_LEAVE_S1);
      endcase

    fsm_state_r[FSM_ENTER_S1]:         //sw sx, -i(sp)
      if (eop_cond0)
          fsm_state_nxt = (1 << FSM_ENTER_S2);

    fsm_state_r[FSM_ENTER_S2]:         //addi sp, sp, -i
      fsm_state_nxt = (1 << FSM_IDLE);

    fsm_state_r[FSM_LEAVE_S1]:         //lw
      if (lop_cond0) begin
        if (lop_cond1 && lop_cond2)
           fsm_state_nxt = (1 << FSM_LEAVE_S2);
        else
           fsm_state_nxt = (1 << FSM_LEAVE_S3);
      end

    fsm_state_r[FSM_LEAVE_S2]:          //li
      fsm_state_nxt = (1 << FSM_LEAVE_S3);

    fsm_state_r[FSM_LEAVE_S3]:          //addi sp
      if (lop_cond1)
        fsm_state_nxt = (1 << FSM_LEAVE_S4);
      else
        fsm_state_nxt = (1 << FSM_IDLE);

    fsm_state_r[FSM_LEAVE_S4]:          //ret
      fsm_state_nxt = (1 << FSM_IDLE);

  endcase // casez (fsm_state_r)
  // leda W71 on
  // leda FM_2_11 on
end // block: fsm_state_nxt_PROC

// Update the UOP state whenever the pipeline 'holdup' is deasserted
// or when restarting the sequence (during a pipeline restart).
//
//
logic fsm_en;
assign fsm_en = ~x1_holdup | fch_restart;

logic fsm_idle, fsm_idle_nxt;
assign fsm_idle = fsm_state_r[FSM_IDLE];
assign fsm_idle_nxt = fsm_state_nxt[FSM_IDLE];

// Enter FSM is busy when not back to the IDLE state
//
logic fsm_busy;
assign fsm_busy = !fsm_idle_nxt & fsm_en;

// The Enter INT FSM sequence is committed when transitioning back
// into the IDLE state.
//
logic fsm_commit;
assign fsm_commit = fsm_en & !fsm_idle & fsm_idle_nxt;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @enter_inst_PROC:                                                      //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

parameter UOP_INST_LD      =   32'h00012003;
parameter UOP_INST_ST      =   32'h00012023;
parameter UOP_INST_ADD     =   32'h00010113;
parameter UOP_INST_RET     =   32'h00008067;
parameter UOP_INST_LI      =   32'h00000513;

always @*
begin: enter_inst_PROC
  uop_inst = `DATA_SIZE'd0;
  case (1'b1)
    fsm_state_r[FSM_LEAVE_S2]: uop_inst = UOP_INST_LI;
    fsm_state_r[FSM_LEAVE_S4]: uop_inst = UOP_INST_RET;
    fsm_state_r[FSM_LEAVE_S1]: uop_inst = UOP_INST_LD | rd_opd | imm1_opd;
    fsm_state_r[FSM_ENTER_S1]: uop_inst = UOP_INST_ST | rs2_opd | imm2_opd;
    fsm_state_r[FSM_ENTER_S2],
    fsm_state_r[FSM_LEAVE_S3]: uop_inst = UOP_INST_ADD | imm1_opd;
  endcase // case (uop_enter_code)
end

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @uop_dstreg_PROC:                                                      //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width
// SJ:  Intended as per the design. No possible loss of data
always @*
begin: dstreg_PROC

  dstreg_init = 1'b0
              | uop_commit
              | fch_restart
              | uop_enter
              | uop_leave
              ;

  dstreg_en = dstreg_init
            | (fsm_en & (fsm_state_r[FSM_ENTER_S1] | fsm_state_r[FSM_LEAVE_S1]));

  if (dstreg_r == `CNT_BITS'd1)
    dstreg_delta = `CNT_BITS'd7;
  else if (dstreg_r == `CNT_BITS'd9)
    dstreg_delta = `CNT_BITS'd9;
  else
    dstreg_delta = `CNT_BITS'd1;

  // leda W484 off
  dstreg_nxt = dstreg_init ? `CNT_BITS'd1 : (dstreg_r + dstreg_delta);
  // leda W484 on
end // block: dstreg_PROC
// spyglass enable_block W164a

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @uop_spoff_enter_init                                                  //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

wire [11:0] uop_rlist_bytes;
wire [11:0] uop_align_bytes;
wire [11:0] uop_spimm_bytes;
wire [11:0] uop_stack_adj_bytes;

wire [11:0] fin_rlist_bytes;
wire [11:0] fin_align_bytes;
wire [11:0] fin_spimm_bytes;
wire [11:0] fin_stack_adj_bytes;

// spyglass disable_block W164a W164b
// SMD: Identifies assignments in which the LHS width is less than the RHS width
// SJ:  Intended as per the design. No possible loss of data
assign uop_rlist_bytes     = ((fu_uop_ctl[`UOP_CTL_RLIST] - 3) + (&fu_uop_ctl[`UOP_CTL_RLIST])) << 2;
assign uop_align_bytes     = ({ (~fu_uop_ctl[5] | (&fu_uop_ctl[`UOP_CTL_RLIST])),
                                (~fu_uop_ctl[4] | (&fu_uop_ctl[`UOP_CTL_RLIST]))
                             }) << 2;
assign uop_spimm_bytes     = {fu_uop_ctl[`UOP_CTL_SP], 4'b0};
assign uop_stack_adj_bytes = (uop_rlist_bytes + uop_align_bytes + uop_spimm_bytes);

assign fin_rlist_bytes     = ((uop_opd_r[`UOP_CTL_RLIST] - 3) + (&uop_opd_r[`UOP_CTL_RLIST])) << 2;
assign fin_align_bytes     = ({ (~uop_opd_r[5] | (& uop_opd_r[`UOP_CTL_RLIST])),
                                (~uop_opd_r[4] | (& uop_opd_r[`UOP_CTL_RLIST]))
                             }) << 2;
assign fin_spimm_bytes     = {uop_opd_r[`UOP_CTL_SP], 4'b0};
assign fin_stack_adj_bytes = (fin_rlist_bytes + fin_align_bytes + fin_spimm_bytes);

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @spoff_PROC:                                                           //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin: spoff_PROC

  // Initialise Stack-Pointer offset on the transition into a
  // interrupt prologue/epilogue or the execution of an
  // ENTER_S/LEAVE_S instruction.
  //
  spoff_set = 1'b0
            | uop_enter
            | uop_leave
            ;

  // Stack pointer offset enable.
  //
  spoff_en = spoff_set
           | (fsm_en & (fsm_state_r[FSM_ENTER_S1] | fsm_state_r[FSM_LEAVE_S1] | fsm_state_r[FSM_LEAVE_S2]));

  // Stack Pointer Offset initialisation as a function of the current
  // operation being performed (interrupt prologue/epilogue, or
  // enter/leave).
  //
  if (uop_enter)
    spoff_init = ~uop_rlist_bytes + 1;
  else
    spoff_init = uop_align_bytes + uop_spimm_bytes;

  if (uop_opd_r[`UOP_CTL_PUSH])
    // PUSH SP final offset:
    spoff_fin = ~fin_stack_adj_bytes+1'b1;
  else
    // POP SP final offset:
    spoff_fin = fin_stack_adj_bytes;

  // Stack-Pointer offset next value calculation.
  //
  spoff_nxt = spoff_set ? spoff_init :
              ((fsm_state_nxt[FSM_ENTER_S2] | fsm_state_nxt[FSM_LEAVE_S3]) ? spoff_fin :
              (spoff_r + 12'h4));
end // block: uop_spoff_PROC
// spyglass enable_block W164a W164b

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @uop_code_PROC:                                                        //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin: uop_code_PROC
  // Special note on instruction decoding.
  //
  // During interrupt prologue/epilogue sequences, the uop sequencer
  // specifically overloads normal pipeline behaviour to denote
  // STATUS32 and XPC registers. Typically, during an ordinary
  // instruction sequences, any references to such registers would
  // result in the assertion of the invalid instruction ucode bit in
  // XA. We do not wish this to happen in this controlled case so we
  // specifically disable any ability for the instruction decode unit
  // to assert the invalid instruction bit in a uop seq. if it detects
  // a reference to an otherwise invalid register.
  //

  // register operand
  //
  rd_opd              = `DATA_SIZE'b0;
  rs2_opd             = `DATA_SIZE'b0;

  rd_opd[11:7]        = dstreg_r[4:0];
  rs2_opd[24:20]      = dstreg_r[4:0];

  imm1_opd            = `DATA_SIZE'b0;
  imm1_opd[31:20]     = spoff_r;

  imm2_opd            = `DATA_SIZE'b0;
  imm2_opd[31:25]     = spoff_r[11:5];
  imm2_opd[11:7]      = spoff_r[4:0];
end // block: uop_code_PROC

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @uop_control_PROC:                                                     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin: uop_control_PROC
  // An instruction is emitted when (1) transitioning out of the IDLE
  // state 'uop_p1' or transitioning back into it and (2) the machine
  // is not attempting to emit a LIMM that is not available at the FA.
  //
  uop_valid    = (uop_inst != 32'd0);

  // uOP sequence can indicate whether they can be interupted.
  // uDSP uOP sequences should be atomic and should not be interrupted.
  uop_busy_ato = 1'b0
               | fsm_state_r[FSM_LEAVE_S4]
               ;

  // The machine is busy when transitioning out of the IDLE state
  // and thereafter .
  //
  uop_busy     = fsm_busy;
  uop_busy_del = !fsm_idle;

  // The commit output is asserted on the last instruction of the UOP
  // sequence. This occurs (1) on the cycle transitioning back to the
  // idle state, (2) the transition to the non-emitting, wait state.
  //
  uop_commit   = ~x1_holdup & fsm_commit;
end // block: uop_control_PROC

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @fsm_reg_PROC:                                                         //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin: fsm_reg_PROC
  if (rst_a == 1'b1)
    fsm_state_r <= (1 << FSM_IDLE);
  else if (fsm_en)
    fsm_state_r <= fsm_state_nxt;
end // block: fsm_reg_PROC

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @dstreg_reg_PROC:                                                      //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin: dstreg_reg_PROC
  if (rst_a == 1'b1)
    dstreg_r <= `CNT_BITS'd0;
  else if (dstreg_en == 1'b1)
    dstreg_r <= dstreg_nxt;
end // block: dstreg_reg_PROC

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @spoff_reg_PROC:                                                       //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin: spoff_reg_PROC
  if (rst_a == 1'b1)
    spoff_r <= 12'b0;
  else if (spoff_en == 1'b1)
    spoff_r <= spoff_nxt;
end // block: spoff_reg_PROC

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @uop_opd_reg_PROC:                                                     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

// Register ENTER_S/LEAVE_S operand when present instruction
// has been decode in the execute stage.
//
reg uop_opd_en;
assign uop_opd_en = (uop_enter | uop_leave);

always @(posedge clk or posedge rst_a)
begin: uop_opd_reg_PROC
  if (rst_a == 1'b1)
    uop_opd_r <= `UOP_CTL_WIDTH'b0;
  else if (uop_opd_en == 1'b1)
    uop_opd_r <= fu_uop_ctl;
end

endmodule // uop_seq
