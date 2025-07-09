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

// Set simulation timescale
//
`include "const.def"

module rl_special (
  ////////// Dispatch interface /////////////////////////////////////////////
  //
  input                      x1_pass,               // instruction dispatched to the SPECIAL FU
  input [`SPC_CTL_RANGE]     x1_spc_ctl,            // Indicates the instructon to be executed in this FU
  input [`DATA_RANGE]        x1_src0_data,
  input [`DATA_RANGE]        x1_src2_data,          // imm
  
  ////////// Complete interface /////////////////////////////////////////////
  //
  input                      fch_restart,

  ////////// X2 stage interface /////////////////////////////////////////////
  //
  input                      x2_valid_r,            // X2 valid instruction from pipe ctrl
  output reg                 fencei_restart,      // fch restart
  output                     icmo_restart,

  output                     spc_x2_ebreak,         // EBREAK instruction in X2
  output                     spc_x2_hbreak,
  input                      break_excpn,
  input                      break_halt,
  output                     spc_x2_ecall,          // ECALL instruction in X2
  output reg                 spc_x2_stall,          // X2 stall on behalf of FENCE

  output                     spc_x2_clean,
  output                     spc_x2_flush,
  output                     spc_x2_inval,
  output                     spc_x2_zero,
  output                     spc_x2_prefetch,
  output reg [`DATA_RANGE]   spc_x2_data,
  input                      icmo_done,
  output                     kill_ic_op,
  output                     spc_x2_wfi,
  
  
  ////////// Machine state /////////////////////////////////////////////
  //
  input                      dmp_idle_r,            // Needed for FENCE/memory barrier
  
  ////////// FENCEI I$ Invalidate interface ///////////////////////////
  //
  output reg                 spc_fence_i_inv_req,   // Invalidate request to IFU
  input                      spc_fence_i_inv_ack,   // Acknowledgement that Invalidation is complete

  ////////// Debug interface ///////////////////////////
  //
  input                      db_active,
  
  output                     hpm_bifsync         ,
  output                     hpm_bdfsync         ,
  ////////// General input signals /////////////////////////////////////////////
  //
  input                      clk,                   // clock signal
  input                      rst_a                  // reset signal

);

// Local declarations
//
wire                  spc_x1_pass;

reg                   spc_x2_ctl_cg0;

reg                   spc_x2_valid_r;
reg                   spc_x2_valid_nxt;
reg                   spc_fence_i_inv_req_nxt;
reg                   fencei_stall,fencei_stall_r;
reg                   icmo_stall_r;
reg                   icmo_stall_nxt;
reg                   fch_restart_r;

reg [`SPC_CTL_RANGE]  spc_x2_ctl_r;
wire                  spc_x2_fence;
wire                  spc_x2_fencei;

parameter IDLE = 2'b00;
parameter WAIT_DMP_IDLE = 2'b01;
parameter WAIT_IFU_INV_ACK = 2'b10;

reg [1:0] fencei_state_r, fencei_state_nxt;

// Handy assignments
//
assign spc_x1_pass          = x1_pass & (| x1_spc_ctl);

// X2
//
always @*
begin : spc_x2_PROC
  // Clock-gate
  //
  //spc_x2_ctl_cg0    = spc_x1_pass | (spc_x2_valid_r & ~spc_x2_stall);  
  spc_x2_ctl_cg0    = spc_x1_pass | 
                     (spc_x2_fencei & spc_fence_i_inv_ack) |
                     (spc_x2_fence & dmp_idle_r);
  spc_x2_valid_nxt  = spc_x1_pass;
end

//////////////////////////////////////////////////////////////////////////////////////////
// FENCE memory barrier - implemented as a total barrier
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : spc_fence_PROC
  // Stall FENCE in X2 untill all outstanding LD/ST transactions are completed
  //
  spc_x2_stall = x2_valid_r & 
                 ((spc_x2_fence & (~dmp_idle_r))
                  | fencei_stall
                 | icmo_stall_nxt 
                 )
                 ;
end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width 
// SJ:  Intended as per the design. No possible loss of data 
always @(posedge clk or posedge rst_a)
begin : x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    spc_x2_valid_r <= 1'b0;
    spc_x2_ctl_r   <= {`SPC_CTL_WIDTH{1'b0}};
    fencei_state_r <= IDLE;
    spc_fence_i_inv_req <= 1'b0;
    spc_x2_data    <= `DATA_SIZE'b0;
    fencei_stall_r <= 1'b0;
  end
  else
  begin
    if (fch_restart == 1'b1)
      spc_x2_ctl_r   <= {`SPC_CTL_WIDTH{1'b0}};
    else if (x1_pass)
      spc_x2_ctl_r  <= x1_spc_ctl;  //x2_ctl should be updated in time

    if (spc_x2_ctl_cg0 == 1'b1)
    begin
      spc_x2_valid_r <= spc_x2_valid_nxt;
      if (x1_spc_ctl[`SPC_CTL_PREFETCH])
        spc_x2_data    <= x1_src0_data + x1_src2_data;
      else
        spc_x2_data    <= x1_src0_data;
    end
    fencei_state_r <= fencei_state_nxt;
    spc_fence_i_inv_req <= spc_fence_i_inv_req_nxt;
    fencei_stall_r <= fencei_stall;
  end
end
// spyglass enable_block W164a

//////////////////////////////////////////////////////////////////////////////////////////
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////


always @*
begin : spc_fencei_PROC
  // FENCEI FSM
  //
  fencei_state_nxt = fencei_state_r;
  fencei_stall = fencei_stall_r;
  fencei_restart = 1'b0;
  spc_fence_i_inv_req_nxt = spc_fence_i_inv_req;
  case (fencei_state_r)
  IDLE: begin
      if (spc_x2_fencei)
      begin
        fencei_state_nxt = WAIT_DMP_IDLE;
        fencei_stall = 1'b1;
      end
  end
  WAIT_DMP_IDLE: begin
      if (fch_restart_r)
      begin
        fencei_state_nxt = IDLE;
        spc_fence_i_inv_req_nxt = 1'b0;
        fencei_stall = 1'b0;
      end
      else if (dmp_idle_r)
      begin
        fencei_state_nxt = WAIT_IFU_INV_ACK;
        spc_fence_i_inv_req_nxt = 1'b1;
      end
  end
  WAIT_IFU_INV_ACK: begin
      if (fch_restart_r)
      begin
        fencei_stall = 1'b0;
        spc_fence_i_inv_req_nxt = 1'b0;
        fencei_state_nxt = IDLE;
      end
      else if (spc_fence_i_inv_ack)
      begin
        fencei_state_nxt = IDLE;
        fencei_restart   = 1'b1;
        fencei_stall = 1'b0;
        spc_fence_i_inv_req_nxt = 1'b0;
      end
  end
  default: begin 
  end
  endcase
end

assign icmo_restart = icmo_done & (~db_active);

always@*
begin
  icmo_stall_nxt = icmo_stall_r; 
  if (fch_restart_r)
  begin
    icmo_stall_nxt = 1'b0;
  end
  else if (icmo_done)
  begin
    icmo_stall_nxt = 1'b0;
  end
  else if (spc_x2_inval | spc_x2_flush | spc_x2_prefetch)
  begin
    icmo_stall_nxt = 1'b1;
  end
end



always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
    begin
      icmo_stall_r   <= 1'b0;
    end
  else
    begin
      icmo_stall_r   <= icmo_stall_nxt; 
    end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
    begin
      fch_restart_r <= 1'b0;
    end
  else
    begin
      fch_restart_r <= fch_restart; 
    end
end


assign spc_x2_ebreak     = spc_x2_ctl_r[`SPC_CTL_EBREAK]   & x2_valid_r & break_excpn;
assign spc_x2_hbreak     = spc_x2_ctl_r[`SPC_CTL_EBREAK]   & x2_valid_r & break_halt;
assign spc_x2_ecall      = spc_x2_ctl_r[`SPC_CTL_ECALL]    & x2_valid_r;
assign spc_x2_flush      = spc_x2_ctl_r[`SPC_CTL_FLUSH]    & x2_valid_r;
assign spc_x2_clean      = spc_x2_ctl_r[`SPC_CTL_CLEAN]    & x2_valid_r;  
assign spc_x2_inval      = spc_x2_ctl_r[`SPC_CTL_INVAL]    & x2_valid_r;
assign spc_x2_zero       = spc_x2_ctl_r[`SPC_CTL_ZERO]     & x2_valid_r;
assign spc_x2_prefetch   = spc_x2_ctl_r[`SPC_CTL_PREFETCH] & x2_valid_r; 
assign spc_x2_wfi        = spc_x2_ctl_r[`SPC_CTL_WFI]      & x2_valid_r;
assign spc_x2_fence      = spc_x2_ctl_r[`SPC_CTL_FENCE]    & x2_valid_r; 
assign spc_x2_fencei     = spc_x2_ctl_r[`SPC_CTL_FENCEI]   & x2_valid_r; 
assign kill_ic_op        = (icmo_stall_r | spc_fence_i_inv_req) & (fch_restart);

assign  hpm_bifsync  = x2_valid_r & 
                 ( fencei_stall
                 | icmo_stall_nxt 
                 )
                 ;
assign  hpm_bdfsync  = x2_valid_r & 
                 (spc_x2_fence & (~dmp_idle_r));


endmodule // rl_special
