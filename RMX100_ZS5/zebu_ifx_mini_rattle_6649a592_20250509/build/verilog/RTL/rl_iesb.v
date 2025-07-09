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
//  This module implements implicit error synchronization barrier at the entry
//  and exit of all interrupt, exception handlers. The purpose of such barrier
//  is to provide error isolation, preventing errors triggered by one thread
//  interfering with another thread.
//
// @e
//
//
//
//  The module hierarchy, at and below this module, is:
//
//      rl_exu
//      |------ rl_iesb
//
// ===========================================================================
//
// Configuration-dependent macro definitions
//
`include "defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_iesb (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                         clk                     , // clock signal
  input                         rst_a                   , // reset signal
  
  // Exception interface
  input                         x2_valid_r              ,
  input                         precise_x2_excpn        ,
  input                         imprecise_x2_excpn      ,
  input                         take_int                ,
  input                         trap_return             ,
  input  [1:0]                  arcv_mesb_ctrl          ,
  input  [1:0]                  priv_level_r            ,

  //  DMP interface
  input                         dmp_empty               , // DMP queue empty

  input                         uop_valid               ,
  input                         uop_commit              ,

  // 
  output                        iesb_barrier            , // Exception barrier
  output                        iesb_replay             , // Pipeline replay
  output                        iesb_block_excpn        , // Block imprecise exception
  output                        iesb_block_int          ,
  output                        iesb_x2_holdup            // Pipeline stall
  
);

// debug mode: no traps in debug mode, so no barrier

localparam  IDLE                = 3'b000,
            WAIT_PRCS_TRAP_ENT  = 3'b001,
            WAIT_IMP_TRAP_ENT   = 3'b010,
            WAIT_INT_ENT        = 3'b011,
            WAIT_TRAP_RET       = 3'b100;

reg                 uop_dmp_empty_nxt     ;
reg                 uop_dmp_empty_r       ;
reg                 uop_valid_r           ;
reg [2:0]           iesb_cst_r            ;
reg [2:0]           iesb_nst              ;
wire                iesb_int_no_barrier   ;
wire                iesb_int_stall        ;
wire                iesb_imp_stall        ;
wire                iesb_prc_stall        ;
wire                iesb_replay_nxt       ;
wire                iesb_int_byp          ;
reg                 iesb_replay_r         ;

//////////////////////////////////////////////////////////////////////////////////////////
//  Helper assignments
///////////////////////////////////////////////////////////////////////////////////////////

// replay signal should be present till we receive x2 valid_r, as the replay is
// considered only when this valid is present. This signal is used in extending
// the replay till x2_valid is present.
assign  iesb_replay_nxt     = x2_valid_r ? 1'b0 : (iesb_replay ? 1'b1 : iesb_replay_r);

// This signal indicates the condition to bypass the exception barrier for interrupts.
assign  iesb_int_byp        = (dmp_empty | (priv_level_r == `PRIV_M) | arcv_mesb_ctrl[0]);

// Following signal indicates barrier enable signal for imprecise exceptions
assign  iesb_imp_stall      = (imprecise_x2_excpn & (~dmp_empty));

// Following signal indicates barrier enable signal for interrupts
assign  iesb_int_stall      = (take_int & (~iesb_int_byp));

// Following signal indicates that the interrupt is taken without barrier
assign  iesb_int_no_barrier = take_int & iesb_int_byp;

//////////////////////////////////////////////////////////////////////////////////////////
// Next state logic of the state machine
//----------------------------------------------------------------------------------------
// State machine will be in IDLE after reset, this is the default state. If
// there is any condition to apply exception barrier occurs, state machine
// moves to corresponding state. Return from the state is when the dmp is
// empty, indicating all pending transactions are complete. If there is
// imprecise exception while barrier is applied for precise exception or
// interrupt, statemachine moves to imprecise exception state, to capture the
// imprecise exception.
//////////////////////////////////////////////////////////////////////////////////////////
always @*
begin
  iesb_nst      = iesb_cst_r;

  case( iesb_cst_r )
    IDLE      :
      begin
        iesb_nst     = iesb_imp_stall ? WAIT_IMP_TRAP_ENT :
                       iesb_prc_stall ? WAIT_PRCS_TRAP_ENT :
                       (trap_return & (~dmp_empty)) ? WAIT_TRAP_RET :
                       iesb_int_stall ? WAIT_INT_ENT :
                          IDLE;
      end
    WAIT_PRCS_TRAP_ENT  :
      begin
        iesb_nst     = iesb_imp_stall ? WAIT_IMP_TRAP_ENT :
                       (~dmp_empty) ? WAIT_PRCS_TRAP_ENT : IDLE;
      end
    WAIT_INT_ENT :
      begin
        iesb_nst     = iesb_imp_stall ? WAIT_IMP_TRAP_ENT :
                       (~dmp_empty) ? WAIT_INT_ENT : IDLE;
      end
    WAIT_IMP_TRAP_ENT :
      begin
        iesb_nst     = (~dmp_empty) ? WAIT_IMP_TRAP_ENT : IDLE;
      end
    WAIT_TRAP_RET :
      begin
        iesb_nst     = iesb_imp_stall ? WAIT_IMP_TRAP_ENT :
                       (~dmp_empty) ? WAIT_TRAP_RET : IDLE;
      end
  endcase
end

always @*
begin
  uop_dmp_empty_nxt = uop_dmp_empty_r;
  if( uop_commit | iesb_int_no_barrier )
    uop_dmp_empty_nxt = 1'b0;
  else if( uop_valid & (~uop_valid_r) )
    uop_dmp_empty_nxt = dmp_empty;
end


//////////////////////////////////////////////////////////////////////////////////////////
//  Sequential process
///////////////////////////////////////////////////////////////////////////////////////////
always @( posedge clk or posedge rst_a )
begin : SEQ_PROC
  if( rst_a )
  begin
    iesb_cst_r      <= IDLE;
    iesb_replay_r   <= 1'b0;
    uop_valid_r     <= 1'b0;
    uop_dmp_empty_r <= 1'b0;
  end
  else
  begin
    iesb_cst_r      <= iesb_int_no_barrier ? IDLE : iesb_nst;
    iesb_replay_r   <= iesb_replay_nxt;
    uop_valid_r     <= uop_valid;
    uop_dmp_empty_r <= uop_dmp_empty_nxt;
  end
end

//////////////////////////////////////////////////////////////////////////////////////////
//  Output assignments
///////////////////////////////////////////////////////////////////////////////////////////
assign  iesb_barrier    = (~(dmp_empty
                             | uop_dmp_empty_r
                            ));
assign  iesb_prc_stall  = precise_x2_excpn & ( (~dmp_empty)
                             | uop_dmp_empty_r
                             );
assign  iesb_replay     = ((((precise_x2_excpn
                             & (~uop_dmp_empty_r)
                            )| trap_return) &  (~imprecise_x2_excpn) & (~iesb_int_no_barrier) & (~dmp_empty)) & (iesb_cst_r == IDLE)) | iesb_replay_r ;

assign  iesb_x2_holdup      = (iesb_cst_r != IDLE);
assign  iesb_block_excpn    = (iesb_cst_r == WAIT_IMP_TRAP_ENT);
assign  iesb_block_int      = (iesb_cst_r == WAIT_INT_ENT);


endmodule


