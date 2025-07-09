// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2021 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
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
`include "csr_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_soft_reset_aux (
  ///////////// AUX pipeline ctl interface ///////////////////////////////////
  //
  input [`DATA_RANGE]             aux_wdata,               //  (WA) Aux write data

  input                           aux_write,               //  (x3) Aux reagion write
  input                           aux_ren,                 //  (X3) Aux region select
  input [11:0]                    aux_raddr,               //  (X3) Aux region addr
  input                           aux_wen,                 //  (WA) Aux region select
  input [11:0]                    aux_waddr,               //  (WA) Aux write addr 
  
  output reg [`DATA_RANGE]        aux_rdata,               //  (X3) LR read data
  output reg                      aux_illegal,             //  (X3) SR/LR illegal
  input                           biu_idle,                //  Biu Finished all outstanding transactions

  ////////// Cache/TLB/MMU initialization upon reset ////////////////////////////
  //
  input                           cpu_in_reset_state, // driven by a reset register
  input                           is_soft_reset,      // reset ctrl input
  output                          sr_dbg_cache_rst_disable,   // qualified output              
   
  ////////// Soft reset interface ///////////////////////////////////////////
  //
  input                           soft_reset_prepare,      // driven by the cluster, synchronized to the core clk
  output reg                      soft_reset_ready_r,      // goes to the cluster
  
  ////////// Input signals (core state) ///////////////////////////////////////
  //
  input [`PC_RANGE]               ar_pc_r,
  input [`DATA_RANGE]             mstatus,
  input                           db_active_r,
  input [23:0]                    core_state,           // core state to be saved 
  
  ////////// General input signals //////////////////////////////////////////
  //
  input                           clk,                  // clock signal
  input                           rst_a                 // (hard) reset signal
);

// Local declarations
//
reg               soft_reset_prepare_r; 

reg               sr_saved_epc_cg0;
reg [`PC_RANGE]   sr_saved_epc_r;
reg [`PC_RANGE]   sr_saved_epc_nxt;

reg               sr_saved_mstatus_cg0;
reg [31:0]        sr_saved_mstatus_r;
reg [31:0]        sr_saved_mstatus_nxt;

reg               sr_saved_xstate_cg0;
reg [23:0]        sr_saved_xstate_r;
reg [23:0]        sr_saved_xstate_nxt;


reg [`DATA_RANGE] aux_sr_wdata; 

reg               sr_capture_state;

////////////////////////////////////////////////////////////////////////////////
//                                                                          
// AUX read mux
//                                                                           
//////////////////////////////////////////////////////////////////////////////

always @*
begin : aux_read_PROC
  aux_rdata      = {`DATA_SIZE{1'b0}};       
  aux_illegal    = 1'b0;     
  
  if (aux_ren)
  begin
    // We have got selected
    //
          
    case (aux_raddr)
//!BCR { num: 4080, val: 0, name: "ARCV_SR_EPC" }
    `CSR_ARCV_SR_EPC:      // RG
    begin
      aux_rdata       = {sr_saved_epc_r, 1'b0};
      aux_illegal     = aux_write & (~db_active_r);
    end
    
    `CSR_ARCV_SR_MSTATUS:  // RG
    begin
      aux_rdata       = sr_saved_mstatus_r;
      aux_illegal     = aux_write & (~db_active_r);
    end
    
    `CSR_ARCV_SR_MSTATUSH:       // RG -- Not Applicable for RMX-100
    begin
      aux_rdata[13:0] = 14'b0; 
      aux_illegal     = aux_write & (~db_active_r);
    end
    
    `CSR_ARCV_SR_XSTATE:       // RG
    begin
      aux_rdata       = {8'b0, sr_saved_xstate_r};
      aux_illegal     = aux_write & (~db_active_r);
    end
    
    default:
    begin
      aux_rdata      = {`DATA_SIZE{1'b0}};       
      aux_illegal    = 1'b1;
    end
    endcase
  end
end

reg sr_capture_state_r;
reg sr_capture_state_nxt;
reg is_soft_reset_r;

localparam SR_CAPTURE_DEFAULT = 1'b0;
localparam SR_CAPTURE_RETAIN  = 1'b1;

always @*
begin : sr_capture_fsm_PROC
  // Default values. We capture the state of the core before the actual soft-reset is applied.
  //
  sr_capture_state     = 1'b0
                       | (is_soft_reset   & (~is_soft_reset_r));
  sr_capture_state_nxt = sr_capture_state_r;
  
  case (sr_capture_state_r)
  SR_CAPTURE_DEFAULT:
  begin
    if (sr_capture_state)
    begin
      // Capture state just one time
      //
      sr_capture_state_nxt = SR_CAPTURE_RETAIN;
    end
  end
  
  default: // SR_CAPTURE_RETAIN
  begin
    // We will likely stay here until a hard reset is applied. In any case, check the state of the SR bit
    //
    sr_capture_state = 1'b0;
    
    if (sr_saved_xstate_r[0] == 1'b0)
    begin
      // If there is an explicit debugger write clearing the SR bit, we resume
      //
      sr_capture_state_nxt = SR_CAPTURE_DEFAULT;
    end
  end
  endcase
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          
// AUX writes
//                                                                           
//////////////////////////////////////////////////////////////////////////////
// spyglass disable_block Ac_conv01 Ac_conv02
// SMD: Checks combinational convergence of same-domain signals synchronized in the same destination domain
// SMD: Checks sequential convergence of same-domain signals synchronized in the same destination domain
// SJ: Reset/NMI are independent, both of them will impact icache refill and reflect in biu_idle, that's intended
// SJ: Reset/NMI are independent, both of them will impact soft reset register and reflect in sr_saved_*, that's intended
always @*
begin : aux_write_PROC
  // Write data
  //
  aux_sr_wdata          = {`DATA_SIZE{aux_wen}} & aux_wdata;
  
  // Default assignments
  //
  sr_saved_epc_cg0       = 1'b0;
  sr_saved_epc_nxt       = sr_saved_epc_r;
    
  sr_saved_mstatus_cg0 = 1'b0;
  sr_saved_mstatus_nxt = sr_saved_mstatus_r;
  
  sr_saved_xstate_cg0    = 1'b0;
  sr_saved_xstate_nxt    = sr_saved_xstate_r;
  
  // Preparing for a soft reset
  //
  if (sr_capture_state)
  begin
    // Save state
    //
    sr_saved_epc_cg0       = 1'b1;
    sr_saved_epc_nxt       = ar_pc_r;
      
    sr_saved_mstatus_cg0 = 1'b1;
    sr_saved_mstatus_nxt = mstatus;
    
    
    sr_saved_xstate_cg0    = 1'b1;
    sr_saved_xstate_nxt    = {
                            core_state[23:1],  // core state to be saved
                            1'b1         // soft-reset (SR)
                            };
  end
  else if (aux_wen & db_active_r)
  begin
    // Debugger can write to these AUX registers
    //
    case (aux_waddr)
    `CSR_ARCV_SR_EPC:      {sr_saved_epc_cg0,     sr_saved_epc_nxt}     = {1'b1, aux_sr_wdata[`PC_RANGE]};         
    `CSR_ARCV_SR_MSTATUS:  {sr_saved_mstatus_cg0, sr_saved_mstatus_nxt} = {1'b1, aux_sr_wdata[31:0]};     
    //CSR_ARCV_SR_MSTATUSH: {sr_saved_xstate_cg0,    sr_saved_xstate_nxt}    = {1'b1, aux_sr_wdata[13:0]};
    `CSR_ARCV_SR_XSTATE:   {sr_saved_xstate_cg0,  sr_saved_xstate_nxt}  = {1'b1, aux_sr_wdata[23:0]};     

// spyglass disable_block W193
// SMD: empty statement
// SJ:  intentional empty default statement
    default:
      ;
    endcase
// spyglass enable_block W193
  end
  else
  begin
    sr_saved_epc_cg0       = 1'b0;
    sr_saved_epc_nxt       = sr_saved_epc_r;
      
    sr_saved_mstatus_cg0 = 1'b0;
    sr_saved_mstatus_nxt = sr_saved_mstatus_r;
    
    sr_saved_xstate_cg0    = 1'b0;
    sr_saved_xstate_nxt    = sr_saved_xstate_r;
  end
  
end

reg soft_reset_ready_cg0;
reg soft_reset_ready_nxt;

always @*
begin : sr_ready_cg0
  // Enable the ready flop when the core is asked to prepare for a soft reset
  //
  soft_reset_ready_cg0 = soft_reset_prepare | soft_reset_ready_r;
  
  // In case the soft reset is initiate by the debugger, provide the ready response right away
  //
  
  // spyglass disable_block DisallowCaseZ-ML
  // SMD: Do not use casez constructs in the design
  // SJ : Intended as per the design
  casez ({soft_reset_prepare, soft_reset_ready_r})
  2'b1_?:  soft_reset_ready_nxt = biu_idle; 
  2'b0_1:  soft_reset_ready_nxt = 1'b0; 
  default: soft_reset_ready_nxt = soft_reset_ready_r;
  endcase
  // spyglass enable_block DisallowCaseZ-ML
  
end
// spyglass enable_block Ac_conv01 Ac_conv02

////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////

// spyglass disable_block INTEGRITY_RESET_GLITCH INTEGRITY_ASYNCRESET_COMBO_MUX
// SMD: Clear pin of sequential element is driven by combinational logic
// SJ:  Intended to merge all reset sources
// spyglass disable_block Ar_glitch01
// SMD: Report glitch in reset paths
// SJ: if TMR is enabled, the tripple synchronized reset signal will go through majority vote. 
// But it doesn't matters if the de-assertion of reset is one cycle ealier or later,this warning can be ignored.
// Glitch can be ignored
always @(posedge clk or posedge rst_a)
begin : aux_sr_regs_PROC
  if (rst_a == 1'b1)
  begin
    sr_saved_epc_r        <= `PC_SIZE'd`RESET_PC;
    sr_saved_mstatus_r    <= {32{1'b0}};
    sr_saved_xstate_r     <= {24{1'b0}};
  end
  else
  begin
    if (sr_saved_epc_cg0 == 1'b1)
    begin
      sr_saved_epc_r       <= sr_saved_epc_nxt;
    end
    
    if (sr_saved_mstatus_cg0 == 1'b1)
    begin
      sr_saved_mstatus_r <= sr_saved_mstatus_nxt;
    end
    
    if (sr_saved_xstate_cg0 == 1'b1)
    begin
      sr_saved_xstate_r    <= sr_saved_xstate_nxt;
    end
    
  end
end
// spyglass enable_block Ar_glitch01
// spyglass enable_block INTEGRITY_RESET_GLITCH INTEGRITY_ASYNCRESET_COMBO_MUX

always @(posedge clk or posedge rst_a)
begin : sr_capture_regs_PROC
  if (rst_a == 1'b1)
  begin
    sr_capture_state_r <= SR_CAPTURE_DEFAULT;
  end
  else
  begin
     sr_capture_state_r <= sr_capture_state_nxt;
  end

end

always @(posedge clk or posedge rst_a)
begin : sr_ready_reg_PROC
  if (rst_a == 1'b1)
  begin
    soft_reset_ready_r <= 1'b0;
  end
  else
  begin
    
    if (soft_reset_ready_cg0 == 1'b1)
    begin
      soft_reset_ready_r <= soft_reset_ready_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : sr_prepare_reg_PROC
  if (rst_a == 1'b1)
  begin
    soft_reset_prepare_r <= 1'b0;
  end
  else
  begin
    soft_reset_prepare_r <= soft_reset_prepare;
  end
end

reg cpu_in_reset_state_r;
reg cpu_in_reset_state_fell_r,cpu_in_reset_state_fell_dly1_r,cpu_in_reset_state_fell_dly2_r;
reg soft_reset_init_disable_r,soft_reset_init_disable_nxt;
wire cpu_in_reset_state_fell;
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets that are synchronized more than once in the same clock domain
// SJ:  Intentionally added to check reset state used to forward cache init
always @(posedge clk or posedge rst_a)
begin : soft_reset_PROC
  if (rst_a == 1'b1)
  begin
    is_soft_reset_r        <= 1'b0;
    cpu_in_reset_state_r   <= 1'b0;
    cpu_in_reset_state_fell_r     <= 1'b0;
    cpu_in_reset_state_fell_dly1_r <= 1'b0;
    cpu_in_reset_state_fell_dly2_r <= 1'b0;
  end
  else
  begin
    is_soft_reset_r        <= is_soft_reset;
    cpu_in_reset_state_r   <= cpu_in_reset_state;
    cpu_in_reset_state_fell_r   <= cpu_in_reset_state_fell;
    cpu_in_reset_state_fell_dly1_r   <= cpu_in_reset_state_fell_r;
    cpu_in_reset_state_fell_dly2_r   <= cpu_in_reset_state_fell_dly1_r;
  end
end
// spyglass enable_block Reset_sync04

always @(posedge clk or posedge rst_a)
begin : soft_reset_init_disable_r_PROC
  if (rst_a == 1'b1)
  begin
    soft_reset_init_disable_r   <= 1'b0;
  end
  else
  begin
    soft_reset_init_disable_r   <= soft_reset_init_disable_nxt;
  end
end

always @*
begin : soft_reset_init_disable_nxt_PROC
  soft_reset_init_disable_nxt = soft_reset_init_disable_r;

//After receiving soft reset, assert soft reset initialization disable 
  if(is_soft_reset)
  begin
    soft_reset_init_disable_nxt = 1'b1;
  end
//After several cycles CPU get out of reset, de-assert soft reset initialization disable 
  else if(cpu_in_reset_state_fell_dly2_r)
  begin
    soft_reset_init_disable_nxt = 1'b0;
  end

end

assign cpu_in_reset_state_fell = cpu_in_reset_state_r & (~cpu_in_reset_state);
////////////////////////////////////////////////////////////////////////////
// Output assignments
//
//////////////////////////////////////////////////////////////////////////////

assign sr_dbg_cache_rst_disable = soft_reset_init_disable_r;    // soft reset skip initilization
                             
endmodule // rl_soft_reset_aux
