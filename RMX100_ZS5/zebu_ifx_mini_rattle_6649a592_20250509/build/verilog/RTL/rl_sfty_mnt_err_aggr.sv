
//----------------------------------------------------------------------------
//
// Copyright 2015-2024 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//
// ===========================================================================
//
// @f:rl_sfty_mnt_err_aggr
//
// Description:
// @p
//   safety monitor error aggregator module.
// @e
//
// ===========================================================================
`include "defines.v"
`include "rv_safety_defines.v"













`define def_dr_illegal_chk(name) \
  (~(^name))

`define def_dr_err_chk(name) \
  ((name != 2'b01)? 1'b1: 1'b0)

`define def_dr_en_chk(name) \
  ((name == 2'b10)? 1'b1: 1'b0)

`define def_smi_inj(id) \
  (((dr_sfty_smi_diag_mode == 2'b10) && sfty_smi_valid_mask[id]) ? sfty_smi_error_mask[id] : 1'b0)














`include "const.def"


module rl_sfty_mnt_err_aggr #(
    parameter SMI_WIDTH = 20
    )
(
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"  
    input [1:0]                   dr_sfty_smi_diag_mode,
    input [SMI_WIDTH-1:0]         sfty_smi_error_mask,
    input [SMI_WIDTH-1:0]         sfty_smi_valid_mask,
    input [1:0]                   dr_sfty_smi_diag_inj_end,
    input [1:0]                   dr_sfty_smi_mask_pty_err,
    input [1:0]  cpu_dr_mismatch_r,
    input [1:0]  cpu_dr_sfty_ctrl_parity_error,
    input [1:0]  cpu_dr_sfty_diag_inj_end,
    input [1:0]  cpu_dr_mask_pty_err,
    input [1:0]  cpu_dr_sfty_diag_mode_sc,

    // The signals specific to the replicated entity, not the controller:
    input [1:0]                    dr_lsc_stl_ctrl_aux_r,
    input [1:0]                    dr_sfty_aux_parity_err_r,
    input [1:0]                    dr_bus_fatal_err,
    input [1:0]                    dr_safety_iso_err,
    input [1:0]                    dr_secure_trig_iso_err,
    input                          sfty_mem_sbe_err,
    input                          sfty_mem_dbe_err,
    input                          sfty_mem_adr_err,
    input                          sfty_mem_sbe_overflow,
    input                          high_prio_ras,
    output[`rv_lsc_err_stat_msb:0] lsc_err_stat_aux,
    output [1:0]                   dr_sfty_eic,
    input      [1:0]  safety_enabled,
    output reg [1:0]  safety_error,
    output     [1:0]  safety_mem_dbe,
    output     [1:0]  safety_mem_sbe,

    output [`rv_lsc_latt_err_stat_msb:0]  lsc_latt_err_stat_aux,
    input  [1:0]  dr_sfty_e2e_diag_mode,
    input  [1:0]  dr_sfty_e2e_diag_inj_end,
    input  [1:0]  dr_sfty_e2e_mask_pty_err,
    input  [1:0]  dr_e2e_check_error_sticky,
    input  [1:0]  dr_sfty_mei_diag_mode,
    input         lock_reset,
    input         clear_latent_fault,
    input         enable_error_injection,
    input [1:0]   dr_sfty_mmio_fsm_pe,
    input         wdt_reset0,
    input         sfty_ibp_mmio_tgt_e2e_err,
    input         sfty_ibp_mmio_ini_e2e_err,
    input         sfty_dmsi_tgt_e2e_err,



    input clk,
    input rst
// spyglass enable_block W240
    );



logic [1:0] dr_sfty_parity_err;
logic [1:0] dr_sfty_dcls_err_sticky;
logic check_error;
logic clear_latent_fault_r;
logic [1:0] dr_sfty_mask_pty_err;
logic sfty_diag_inject_end;
logic [1:0] dr_smi_check_error;
logic [1:0] dr_sfty_aggr_smi;
logic       sfty_error_inj_aggregate_smi;
logic       sfty_smi_mask_pty_err;
logic [1:0] dr_sfty_wdt_err_sticky;
logic [1:0] dr_safety_iso_agg_err;
logic [1:0] dr_sfty_e2e_err;

always_ff @( posedge clk or posedge rst )
begin: clear_latent_fault_r_PROC
  if( rst) 
    clear_latent_fault_r <= 1'b0;
  else              
    clear_latent_fault_r <= clear_latent_fault;
end

//Error Aggregate for safety mechanisms DCLS
assign dr_sfty_dcls_err_sticky   = (1'b0
                                | `def_dr_err_chk(cpu_dr_mismatch_r) 
                                | `def_smi_inj(0)
                                )? 2'b10 : 2'b01;

//Error Aggregate for safety mechanisms Safety Monitor
assign dr_sfty_parity_err   = (1'b0
                                | `def_dr_err_chk(dr_sfty_aux_parity_err_r) 
                                | `def_dr_err_chk(cpu_dr_sfty_ctrl_parity_error) 
                                | `def_dr_err_chk(dr_sfty_mmio_fsm_pe) 
                                | `def_smi_inj(1)
                                )? 2'b10 : 2'b01;
logic sfty_parity_err_tmp;
logic [1:0] dr_sfty_parity_err_sticky, sfty_parity_err_r, sfty_parity_err_nxt;

assign sfty_parity_err_tmp     = (dr_sfty_parity_err != 2'b01)? 1'b1 : 1'b0;
assign sfty_parity_err_nxt = (dr_sfty_parity_err_sticky == 2'b01)? {sfty_parity_err_tmp, sfty_parity_err_tmp} : sfty_parity_err_r;

always_ff @(posedge clk or posedge rst)
begin: sfty_parity_err_r_PROC
  if(rst == 1) begin
    sfty_parity_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    sfty_parity_err_r <= 2'b00;
  end
  else begin
    sfty_parity_err_r <= {sfty_parity_err_nxt[1], sfty_parity_err_nxt[0]};
  end
end

always_comb
begin: dr_sfty_parity_err_sticky_PROC
  dr_sfty_parity_err_sticky = {sfty_parity_err_r[1],~sfty_parity_err_r[0]};
end

//Error Aggregate for safety mechanisms STL
logic lsc_stl_ctrl_aux_r_tmp;
logic [1:0] dr_lsc_stl_ctrl_aux_r_sticky, lsc_stl_ctrl_aux_r_r, lsc_stl_ctrl_aux_r_nxt;

assign lsc_stl_ctrl_aux_r_tmp     = (dr_lsc_stl_ctrl_aux_r != 2'b01)? 1'b1 : 1'b0;
assign lsc_stl_ctrl_aux_r_nxt = (dr_lsc_stl_ctrl_aux_r_sticky == 2'b01)? {lsc_stl_ctrl_aux_r_tmp, lsc_stl_ctrl_aux_r_tmp} : lsc_stl_ctrl_aux_r_r;

always_ff @(posedge clk or posedge rst)
begin: lsc_stl_ctrl_aux_r_r_PROC
  if(rst == 1) begin
    lsc_stl_ctrl_aux_r_r <= 2'b00;
  end
  else if(lock_reset) begin
    lsc_stl_ctrl_aux_r_r <= 2'b00;
  end
  else begin
    lsc_stl_ctrl_aux_r_r <= {lsc_stl_ctrl_aux_r_nxt[1], lsc_stl_ctrl_aux_r_nxt[0]};
  end
end

always_comb
begin: dr_lsc_stl_ctrl_aux_r_sticky_PROC
  dr_lsc_stl_ctrl_aux_r_sticky = {lsc_stl_ctrl_aux_r_r[1],~lsc_stl_ctrl_aux_r_r[0]};
end

//Error Aggregate for safety mechanisms Bus Protection
logic bus_fatal_err_tmp;
logic [1:0] dr_bus_fatal_err_sticky, bus_fatal_err_r, bus_fatal_err_nxt;

assign bus_fatal_err_tmp     = (dr_bus_fatal_err != 2'b01)? 1'b1 : 1'b0;
assign bus_fatal_err_nxt = (dr_bus_fatal_err_sticky == 2'b01)? {bus_fatal_err_tmp, bus_fatal_err_tmp} : bus_fatal_err_r;

always_ff @(posedge clk or posedge rst)
begin: bus_fatal_err_r_PROC
  if(rst == 1) begin
    bus_fatal_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    bus_fatal_err_r <= 2'b00;
  end
  else begin
    bus_fatal_err_r <= {bus_fatal_err_nxt[1], bus_fatal_err_nxt[0]};
  end
end

always_comb
begin: dr_bus_fatal_err_sticky_PROC
  dr_bus_fatal_err_sticky = {bus_fatal_err_r[1],~bus_fatal_err_r[0]};
end

//Error Aggregate for safety mechanisms E2E Protection
assign dr_sfty_e2e_err   = (1'b0
                                | sfty_ibp_mmio_ini_e2e_err 
                                | sfty_ibp_mmio_tgt_e2e_err 
                                | sfty_dmsi_tgt_e2e_err
                                | `def_smi_inj(2)
                                )? 2'b10 : 2'b01;
logic sfty_e2e_err_tmp;
logic [1:0] dr_sfty_e2e_err_sticky, sfty_e2e_err_r, sfty_e2e_err_nxt;

assign sfty_e2e_err_tmp     = (dr_sfty_e2e_err != 2'b01)? 1'b1 : 1'b0;
assign sfty_e2e_err_nxt = (dr_sfty_e2e_err_sticky == 2'b01)? {sfty_e2e_err_tmp, sfty_e2e_err_tmp} : sfty_e2e_err_r;

always_ff @(posedge clk or posedge rst)
begin: sfty_e2e_err_r_PROC
  if(rst == 1) begin
    sfty_e2e_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    sfty_e2e_err_r <= 2'b00;
  end
  else begin
    sfty_e2e_err_r <= {sfty_e2e_err_nxt[1], sfty_e2e_err_nxt[0]};
  end
end

always_comb
begin: dr_sfty_e2e_err_sticky_PROC
  dr_sfty_e2e_err_sticky = {sfty_e2e_err_r[1],~sfty_e2e_err_r[0]};
end

//Error Aggregate for safety isolation
assign dr_safety_iso_agg_err   = (1'b0
                                | `def_dr_err_chk(dr_safety_iso_err) 
                                | `def_dr_err_chk(dr_secure_trig_iso_err) 
                                | `def_smi_inj(3)
                                )? 2'b10 : 2'b01;
logic safety_iso_agg_err_tmp;
logic [1:0] dr_safety_iso_agg_err_sticky, safety_iso_agg_err_r, safety_iso_agg_err_nxt;

assign safety_iso_agg_err_tmp     = (dr_safety_iso_agg_err != 2'b01)? 1'b1 : 1'b0;
assign safety_iso_agg_err_nxt = (dr_safety_iso_agg_err_sticky == 2'b01)? {safety_iso_agg_err_tmp, safety_iso_agg_err_tmp} : safety_iso_agg_err_r;

always_ff @(posedge clk or posedge rst)
begin: safety_iso_agg_err_r_PROC
  if(rst == 1) begin
    safety_iso_agg_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    safety_iso_agg_err_r <= 2'b00;
  end
  else begin
    safety_iso_agg_err_r <= {safety_iso_agg_err_nxt[1], safety_iso_agg_err_nxt[0]};
  end
end

always_comb
begin: dr_safety_iso_agg_err_sticky_PROC
  dr_safety_iso_agg_err_sticky = {safety_iso_agg_err_r[1],~safety_iso_agg_err_r[0]};
end

//Error Aggregate for safety mechanisms memory ecc
logic [1:0] dr_sfty_mem_dbe_err;
logic [1:0] dr_sfty_mem_adr_err;
assign dr_sfty_mem_dbe_err     = sfty_mem_dbe_err ? 2'b10 : 2'b01;
assign dr_sfty_mem_adr_err     = sfty_mem_adr_err ? 2'b10 : 2'b01;
logic sfty_mem_dbe_err_tmp;
logic [1:0] dr_sfty_mem_dbe_err_sticky, sfty_mem_dbe_err_r, sfty_mem_dbe_err_nxt;

assign sfty_mem_dbe_err_tmp     = (dr_sfty_mem_dbe_err != 2'b01)? 1'b1 : 1'b0;
assign sfty_mem_dbe_err_nxt = (dr_sfty_mem_dbe_err_sticky == 2'b01)? {sfty_mem_dbe_err_tmp, sfty_mem_dbe_err_tmp} : sfty_mem_dbe_err_r;

always_ff @(posedge clk or posedge rst)
begin: sfty_mem_dbe_err_r_PROC
  if(rst == 1) begin
    sfty_mem_dbe_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    sfty_mem_dbe_err_r <= 2'b00;
  end
  else begin
    sfty_mem_dbe_err_r <= {sfty_mem_dbe_err_nxt[1], sfty_mem_dbe_err_nxt[0]};
  end
end

always_comb
begin: dr_sfty_mem_dbe_err_sticky_PROC
  dr_sfty_mem_dbe_err_sticky = {sfty_mem_dbe_err_r[1],~sfty_mem_dbe_err_r[0]};
end
logic sfty_mem_adr_err_tmp;
logic [1:0] dr_sfty_mem_adr_err_sticky, sfty_mem_adr_err_r, sfty_mem_adr_err_nxt;

assign sfty_mem_adr_err_tmp     = (dr_sfty_mem_adr_err != 2'b01)? 1'b1 : 1'b0;
assign sfty_mem_adr_err_nxt = (dr_sfty_mem_adr_err_sticky == 2'b01)? {sfty_mem_adr_err_tmp, sfty_mem_adr_err_tmp} : sfty_mem_adr_err_r;

always_ff @(posedge clk or posedge rst)
begin: sfty_mem_adr_err_r_PROC
  if(rst == 1) begin
    sfty_mem_adr_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    sfty_mem_adr_err_r <= 2'b00;
  end
  else begin
    sfty_mem_adr_err_r <= {sfty_mem_adr_err_nxt[1], sfty_mem_adr_err_nxt[0]};
  end
end

always_comb
begin: dr_sfty_mem_adr_err_sticky_PROC
  dr_sfty_mem_adr_err_sticky = {sfty_mem_adr_err_r[1],~sfty_mem_adr_err_r[0]};
end

//Error Aggregate for safety mechanisms WDT
assign dr_sfty_wdt_err_sticky   = (1'b0
                                | wdt_reset0 
                                | `def_smi_inj(4)
                                )? 2'b10 : 2'b01;

//Mask Parity Error for Diagnostic Error injection
assign dr_sfty_mask_pty_err   = (1'b0
                                | ((dr_sfty_smi_diag_mode == 2'b10) && ((dr_sfty_smi_mask_pty_err != 2'b01) ? 1'b1 : 1'b0))
                                | ((cpu_dr_sfty_diag_mode_sc == 2'b10) &&((cpu_dr_mask_pty_err!= 2'b01) ? 1'b1 : 1'b0))
                                | ((dr_sfty_e2e_diag_mode == 2'b10) && ((dr_sfty_e2e_mask_pty_err != 2'b01) ? 1'b1 : 1'b0))
                             )? 2'b10 : 2'b01;

logic sfty_mask_pty_err_tmp;
logic [1:0] dr_sfty_mask_pty_err_sticky, sfty_mask_pty_err_r, sfty_mask_pty_err_nxt;

assign sfty_mask_pty_err_tmp     = (dr_sfty_mask_pty_err != 2'b01)? 1'b1 : 1'b0;
assign sfty_mask_pty_err_nxt = (dr_sfty_mask_pty_err_sticky == 2'b01)? {sfty_mask_pty_err_tmp, sfty_mask_pty_err_tmp} : sfty_mask_pty_err_r;

always_ff @(posedge clk or posedge rst)
begin: sfty_mask_pty_err_r_PROC
  if(rst == 1) begin
    sfty_mask_pty_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    sfty_mask_pty_err_r <= 2'b00;
  end
  else begin
    sfty_mask_pty_err_r <= {sfty_mask_pty_err_nxt[1], sfty_mask_pty_err_nxt[0]};
  end
end

always_comb
begin: dr_sfty_mask_pty_err_sticky_PROC
  dr_sfty_mask_pty_err_sticky = {sfty_mask_pty_err_r[1],~sfty_mask_pty_err_r[0]};
end

// Diagnostic Error Injection End
assign sfty_diag_inject_end = enable_error_injection
                              && ((dr_sfty_smi_diag_mode == 2'b01) || ((dr_sfty_smi_diag_mode == 2'b10) && (dr_sfty_smi_diag_inj_end == 2'b10)))
                              && ((cpu_dr_sfty_diag_mode_sc == 2'b01) || ((cpu_dr_sfty_diag_mode_sc == 2'b10) && (cpu_dr_sfty_diag_inj_end == 2'b10)))
                              && ((dr_sfty_e2e_diag_mode == 2'b01) || ((dr_sfty_e2e_diag_mode == 2'b10) && (dr_sfty_e2e_diag_inj_end == 2'b10)))
                              ;

logic [1:0] dr_sfty_diag_inject_end_r;
always_ff @( posedge clk or posedge rst )
begin: dr_sfty_diag_inject_end_r_PROC
  if( rst) 
    dr_sfty_diag_inject_end_r <= 2'b01;
  else              
    dr_sfty_diag_inject_end_r <= {sfty_diag_inject_end, ~sfty_diag_inject_end};
end

assign dr_sfty_eic = dr_sfty_diag_inject_end_r;


//Diagnostic Mode Enable pty error
logic [1:0] dr_sfty_diag_mode_pty_err;
assign dr_sfty_diag_mode_pty_err   = (1'b0
                                | (~(^cpu_dr_sfty_diag_mode_sc))
                                | (~(^dr_sfty_smi_diag_mode))
                                | (~(^dr_sfty_e2e_diag_mode))
                                | (~(^dr_sfty_mei_diag_mode))
                                )? 2'b10: 2'b01;
logic sfty_diag_mode_pty_err_tmp;
logic [1:0] dr_sfty_diag_mode_pty_err_sticky, sfty_diag_mode_pty_err_r, sfty_diag_mode_pty_err_nxt;

assign sfty_diag_mode_pty_err_tmp     = (dr_sfty_diag_mode_pty_err != 2'b01)? 1'b1 : 1'b0;
assign sfty_diag_mode_pty_err_nxt = (dr_sfty_diag_mode_pty_err_sticky == 2'b01)? {sfty_diag_mode_pty_err_tmp, sfty_diag_mode_pty_err_tmp} : sfty_diag_mode_pty_err_r;

always_ff @(posedge clk or posedge rst)
begin: sfty_diag_mode_pty_err_r_PROC
  if(rst == 1) begin
    sfty_diag_mode_pty_err_r <= 2'b00;
  end
  else if(lock_reset) begin
    sfty_diag_mode_pty_err_r <= 2'b00;
  end
  else begin
    sfty_diag_mode_pty_err_r <= {sfty_diag_mode_pty_err_nxt[1], sfty_diag_mode_pty_err_nxt[0]};
  end
end

always_comb
begin: dr_sfty_diag_mode_pty_err_sticky_PROC
  dr_sfty_diag_mode_pty_err_sticky = {sfty_diag_mode_pty_err_r[1],~sfty_diag_mode_pty_err_r[0]};
end

//Diagnostic Error Injection chk error
//CEI
logic [1:0] cpu_dr_sfty_diag_mode_sc_r;
always_ff @( posedge clk or posedge rst )
begin: cpu_dr_sfty_diag_mode_sc_r_PROC
  if( rst) 
    cpu_dr_sfty_diag_mode_sc_r <= 2'b01;
  else              
    cpu_dr_sfty_diag_mode_sc_r <= cpu_dr_sfty_diag_mode_sc;
end

logic [1:0] dr_sc_check_error;
assign dr_sc_check_error = (1'b0 
                        | ((cpu_dr_sfty_diag_mode_sc_r == 2'b10) && (cpu_dr_mismatch_r    != 2'b10))  
                        ) ? 2'b10 : 2'b01;

logic sc_check_error_tmp;
logic [1:0] dr_sc_check_error_sticky, sc_check_error_r, sc_check_error_nxt;

assign sc_check_error_tmp     = (dr_sc_check_error != 2'b01)? 1'b1 : 1'b0;
assign sc_check_error_nxt = (dr_sc_check_error_sticky == 2'b01)? {sc_check_error_tmp, sc_check_error_tmp} : sc_check_error_r;

always_ff @(posedge clk or posedge rst)
begin: sc_check_error_r_PROC
  if(rst == 1) begin
    sc_check_error_r <= 2'b00;
  end
  else if(clear_latent_fault_r) begin
    sc_check_error_r <= 2'b00;
  end
  else begin
    sc_check_error_r <= {sc_check_error_nxt[1], sc_check_error_nxt[0]};
  end
end

always_comb
begin: dr_sc_check_error_sticky_PROC
  dr_sc_check_error_sticky = {sc_check_error_r[1],~sc_check_error_r[0]};
end
//SMI
logic smi_check_error_tmp;
logic [1:0] dr_smi_check_error_sticky, smi_check_error_r, smi_check_error_nxt;

assign smi_check_error_tmp     = (dr_smi_check_error != 2'b01)? 1'b1 : 1'b0;
assign smi_check_error_nxt = (dr_smi_check_error_sticky == 2'b01)? {smi_check_error_tmp, smi_check_error_tmp} : smi_check_error_r;

always_ff @(posedge clk or posedge rst)
begin: smi_check_error_r_PROC
  if(rst == 1) begin
    smi_check_error_r <= 2'b00;
  end
  else if(clear_latent_fault_r) begin
    smi_check_error_r <= 2'b00;
  end
  else begin
    smi_check_error_r <= {smi_check_error_nxt[1], smi_check_error_nxt[0]};
  end
end

always_comb
begin: dr_smi_check_error_sticky_PROC
  dr_smi_check_error_sticky = {smi_check_error_r[1],~smi_check_error_r[0]};
end


//msfty_error_status
assign lsc_err_stat_aux[`rv_lsc_err_stat_cm_impl]     = `def_dr_err_chk(dr_sfty_dcls_err_sticky) 
                                                     | `def_smi_inj(5)
                                                     ;
assign lsc_err_stat_aux[`rv_lsc_err_stat_me_impl]     = `def_dr_err_chk(dr_sfty_mem_dbe_err_sticky)
                                                     | `def_smi_inj(6)
                                                     ;
assign lsc_err_stat_aux[`rv_lsc_err_stat_mae_impl]    = `def_dr_err_chk(dr_sfty_mem_adr_err_sticky)
                                                     | `def_smi_inj(7)
                                                     ;

assign lsc_err_stat_aux[`rv_lsc_err_stat_wdp_impl]    = 1'b0;

assign lsc_err_stat_aux[`rv_lsc_err_stat_wdt_impl]    = `def_dr_err_chk(dr_sfty_wdt_err_sticky)
                                                     | `def_smi_inj(8)
                                                     ; 

assign lsc_err_stat_aux[`rv_lsc_err_stat_e2e_impl]    = ((dr_sfty_smi_diag_mode == 2'b10) ? `def_dr_err_chk(dr_sfty_e2e_err) : `def_dr_err_chk(dr_sfty_e2e_err_sticky))
                                                     | `def_smi_inj(9)
                                                     ; 
assign lsc_err_stat_aux[`rv_lsc_err_stat_tre_impl]    = 1'b0; 
assign lsc_err_stat_aux[`rv_lsc_err_stat_sme_impl]    = ((dr_sfty_smi_diag_mode == 2'b10) ? `def_dr_err_chk(dr_sfty_parity_err) : `def_dr_err_chk(dr_sfty_parity_err_sticky))
                                                     | `def_dr_err_chk(dr_sfty_diag_mode_pty_err_sticky)
                                                     | `def_dr_err_chk(dr_sfty_mask_pty_err_sticky)
                                                     | `def_smi_inj(10);

assign lsc_err_stat_aux[`rv_lsc_err_stat_iso_impl]    = ((dr_sfty_smi_diag_mode == 2'b10) ? `def_dr_err_chk(dr_safety_iso_agg_err) : `def_dr_err_chk(dr_safety_iso_agg_err_sticky))
                                                     | `def_smi_inj(11);

assign lsc_err_stat_aux[`rv_lsc_err_stat_lf_impl]     = check_error;

assign lsc_err_stat_aux[`rv_lsc_err_stat_stl_impl]    = `def_dr_err_chk(dr_lsc_stl_ctrl_aux_r_sticky) 
                                                     | `def_smi_inj(12)
                                                     ;

assign lsc_err_stat_aux[`rv_lsc_err_stat_sbo_impl]    = sfty_mem_sbe_overflow
                                                     | `def_smi_inj(13)
                                                     ;

assign lsc_err_stat_aux[`rv_lsc_err_stat_be_impl]     = `def_dr_err_chk(dr_bus_fatal_err_sticky) 
                                                     | `def_smi_inj(14)
                                                     ; 

assign lsc_err_stat_aux[`rv_lsc_err_stat_hpras_impl]    = high_prio_ras
                                                     | `def_smi_inj(15)
                                                     ;

//msfty_latent_error_status
assign lsc_latt_err_stat_aux[`rv_lsc_latt_err_stat_e2ef_impl] = `def_dr_err_chk(dr_e2e_check_error_sticky)
                                                            | `def_smi_inj(16);
assign lsc_latt_err_stat_aux[`rv_lsc_latt_err_stat_mef_impl] = 1'b0;
assign lsc_latt_err_stat_aux[`rv_lsc_latt_err_stat_cef_impl] = `def_dr_err_chk(dr_sc_check_error_sticky)
                                                            | `def_smi_inj(17);
                                                            
assign lsc_latt_err_stat_aux[`rv_lsc_latt_err_stat_smf_impl] = `def_dr_err_chk(dr_smi_check_error_sticky)
                                                            | `def_smi_inj(18);
assign lsc_latt_err_stat_aux[`rv_lsc_latt_err_stat_wdf_impl] = 1'b0;

//safety aggregator error injection
assign sfty_error_inj_aggregate_smi = (1'b0 
                                | dr_sfty_dcls_err_sticky[1]
                                | dr_sfty_parity_err[1]
                                | dr_sfty_e2e_err[1]
                                | dr_safety_iso_agg_err[1]
                                | dr_sfty_wdt_err_sticky[1] 
                                | (|lsc_err_stat_aux[8:0])
                                | (|lsc_err_stat_aux[`rv_lsc_err_stat_msb:10])
                                | (|lsc_latt_err_stat_aux)
                                ) ? 1'b1 : 1'b0; 

assign dr_sfty_aggr_smi = (sfty_error_inj_aggregate_smi) ? 2'b01 : 2'b10;   
logic diag_mode_valid; 
assign diag_mode_valid  = `def_dr_en_chk(dr_sfty_smi_diag_mode) && sfty_smi_valid_mask[18]; 
assign dr_smi_check_error  =  (diag_mode_valid) ? dr_sfty_aggr_smi : 2'b01;


assign  check_error  = (1'b0
                       | (dr_sc_check_error_sticky  != 2'b01)
                       | (dr_smi_check_error_sticky != 2'b01)
                       | (dr_e2e_check_error_sticky != 2'b01)
                       ) ? 1'b1 : 1'b0;
logic [1:0] dr_safety_mem_dbe_sticky;
assign dr_safety_mem_dbe_sticky    = (1'b0
                             | `def_dr_err_chk(dr_sfty_mem_dbe_err_sticky)
                             | `def_dr_err_chk(dr_sfty_mem_adr_err_sticky))

                                                && ~`def_dr_en_chk(dr_sfty_mei_diag_mode)
                             ? 2'b10 : 2'b01;


//Aggregate top error signal
logic safety_error_sel;
logic [1:0] safety_error_nxt;
// spyglass disable_block Ac_conv02
// SMD: Checks combinational convergence of same-domain signals synchronized in the same destination domain
// SJ: Error are sticky and independent
assign safety_error_sel = (1'b0
                         | (( `def_dr_err_chk(dr_sfty_dcls_err_sticky)
                         | `def_dr_err_chk(dr_lsc_stl_ctrl_aux_r_sticky)
                         | `def_dr_err_chk(dr_safety_iso_agg_err_sticky)
                         | `def_dr_err_chk(dr_bus_fatal_err_sticky)
                         | `def_dr_err_chk(dr_sfty_e2e_err_sticky)
                         | `def_dr_err_chk(dr_safety_mem_dbe_sticky)
                         | high_prio_ras
                         | `def_dr_err_chk(dr_sfty_wdt_err_sticky)
                         | `def_dr_err_chk(dr_sfty_parity_err_sticky))& !enable_error_injection)
                         | `def_dr_err_chk(dr_sfty_diag_mode_pty_err_sticky)
                         | `def_dr_err_chk(dr_sfty_mask_pty_err_sticky)
                         | check_error
                         ) && `def_dr_en_chk(safety_enabled)
                         ;        
// spyglass enable_block Ac_conv02

always_ff @( posedge clk or posedge rst )
begin: safety_error_PROC
  if( rst) 
    safety_error <= 2'b01;
  else              
    safety_error <= safety_error_nxt;
end

assign safety_error_nxt = safety_error_sel ? 2'b10 : 2'b01;


logic [1:0] safety_mem_dbe_nxt;
logic [1:0] safety_mem_sbe_nxt;
logic [1:0] safety_mem_dbe_r;
logic [1:0] safety_mem_sbe_r;
assign safety_mem_dbe_nxt    = (1'b0
                             | sfty_mem_dbe_err
                             | sfty_mem_adr_err)
                                                && ~`def_dr_en_chk(dr_sfty_mei_diag_mode)
                             ? 2'b10 : 2'b01;
assign safety_mem_sbe_nxt    = sfty_mem_sbe_err
                                                && ~`def_dr_en_chk(dr_sfty_mei_diag_mode)
                             ? 2'b10 : 2'b01;

always_ff @( posedge clk or posedge rst )
begin: mem_error_PROC
  if( rst) begin
    safety_mem_dbe_r <= 2'b01;
    safety_mem_sbe_r <= 2'b01;
  end
  else begin              
    safety_mem_dbe_r <= safety_mem_dbe_nxt;
    safety_mem_sbe_r <= safety_mem_sbe_nxt;
  end
end

assign safety_mem_dbe = safety_mem_dbe_r;
assign safety_mem_sbe = safety_mem_sbe_r;


endmodule
