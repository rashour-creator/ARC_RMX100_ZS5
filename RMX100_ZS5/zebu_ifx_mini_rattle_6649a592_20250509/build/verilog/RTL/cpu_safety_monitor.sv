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
// @f:cpu_safety_monitor
//
// Description:
// @p
//   CPU safety monitor module for error aggregation, hw error injection and error register access.
// @e
//
// ===========================================================================
`include "defines.v"
`include "rv_safety_defines.v"
`include "const.def"













`define def_dr_illegal_chk(name) \
  (~(^name))

`define def_dr_err_chk(name) \
  ((name != 2'b01)? 1'b1: 1'b0)

`define def_dr_en_chk(name) \
  ((name == 2'b10)? 1'b1: 1'b0)

`define def_smi_inj(id) \
  (((dr_sfty_smi_diag_mode == 2'b10) && sfty_smi_valid_mask[id]) ? sfty_smi_error_mask[id] : 1'b0)

















module cpu_safety_monitor(
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"  
    input [1:0]  cpu_dr_mismatch_r,
    input [1:0]  cpu_dr_sfty_ctrl_parity_error,
    input [1:0]  cpu_lsAsafety_comparator_enabled,
    input [1:0]  cpu_lsBsafety_comparator_enabled,
    input        cpu_lsAls_lock_reset,
    input [1:0]  cpu_dr_sfty_diag_inj_end,
    input [1:0]  cpu_dr_mask_pty_err,
    output reg[1:0]  cpu_dr_sfty_diag_mode_sc,

    // The signals specific to the replicated entity, not the controller:
    input [`RV_LSC_DIAG_RANGE]     lsc_diag_aux_r,
    input                          sfty_nsi_r,
    output [1:0]                   dr_safety_comparator_enabled,
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
    output [1:0]  safety_error,
    output [1:0]  safety_mem_dbe,
    output [1:0]  safety_mem_sbe,

    output [1:0]  safety_enabled,
    input                sfty_ibp_mmio_cmd_valid, 
    input  [3:0]         sfty_ibp_mmio_cmd_cache, 
    input                sfty_ibp_mmio_cmd_burst_size,              
    input                sfty_ibp_mmio_cmd_read,                
    input                sfty_ibp_mmio_cmd_aux,                
    output               sfty_ibp_mmio_cmd_accept,              
    input  [7:0]         sfty_ibp_mmio_cmd_addr,                          
    input                sfty_ibp_mmio_cmd_excl,
    input  [5:0]         sfty_ibp_mmio_cmd_atomic,
    input  [2:0]         sfty_ibp_mmio_cmd_data_size,               
    input  [1:0]         sfty_ibp_mmio_cmd_prot,                

    input                sfty_ibp_mmio_wr_valid,    
    input                sfty_ibp_mmio_wr_last,    
    output               sfty_ibp_mmio_wr_accept,   
    input  [3:0]         sfty_ibp_mmio_wr_mask,    
    input  [31:0]        sfty_ibp_mmio_wr_data,    
    
    output               sfty_ibp_mmio_rd_valid,                
    output               sfty_ibp_mmio_rd_err,                
    output               sfty_ibp_mmio_rd_excl_ok,
    output               sfty_ibp_mmio_rd_last,                 
    input                sfty_ibp_mmio_rd_accept,               
    output  [31:0]       sfty_ibp_mmio_rd_data,     
    
    output               sfty_ibp_mmio_wr_done,
    output               sfty_ibp_mmio_wr_excl_okay,
    output               sfty_ibp_mmio_wr_err,
    input                sfty_ibp_mmio_wr_resp_accept,
// IBP e2e protection interface
    input                sfty_ibp_mmio_cmd_valid_pty,
    output               sfty_ibp_mmio_cmd_accept_pty,              
    input                sfty_ibp_mmio_cmd_addr_pty,                        
    input  [3:0]         sfty_ibp_mmio_cmd_ctrl_pty,

    input                sfty_ibp_mmio_wr_valid_pty,    
    output               sfty_ibp_mmio_wr_accept_pty,   
    input                sfty_ibp_mmio_wr_last_pty,    
    
    output               sfty_ibp_mmio_rd_valid_pty,                
    input                sfty_ibp_mmio_rd_accept_pty,               
    output               sfty_ibp_mmio_rd_ctrl_pty,                
    output [3:0]         sfty_ibp_mmio_rd_data_pty,     
    
    output               sfty_ibp_mmio_wr_done_pty,
    output               sfty_ibp_mmio_wr_ctrl_pty,
    input                sfty_ibp_mmio_wr_resp_accept_pty,
    input                sfty_ibp_mmio_ini_e2e_err,

    input                sfty_dmsi_tgt_e2e_err,
 input 					   wdt_reset0,


    input test_mode,
    input cpu_clk_gated,
    input cpu_rst_gated
// spyglass enable_block W240
    );

//Signal Declare
localparam SMI_WIDTH = 20;
//Synchronous reset signals
logic                    clk;
logic                    sync_rst_as;
//SMI Diagnostic error injection signals
logic [1:0]              dr_sfty_smi_diag_mode;
logic [SMI_WIDTH-1:0]    sfty_smi_error_mask;
logic [SMI_WIDTH-1:0]    sfty_smi_valid_mask;
logic [1:0]              dr_sfty_smi_diag_inj_end;
logic [1:0]              dr_sfty_smi_mask_pty_err;
logic [`rv_lsc_latt_err_stat_msb:0]    lsc_latt_err_stat_aux;
//E2E Diagnostic error injection signals
logic [1:0]              dr_sfty_e2e_diag_mode;
logic [1:0]              dr_sfty_e2e_diag_inj_end;
logic [1:0]              dr_sfty_e2e_mask_pty_err;
logic [1:0]              dr_e2e_check_error_sticky;
//MEM ECC Diagnostic error injection signals
logic [1:0]              dr_sfty_mei_diag_mode;
//Lock reset signals
logic                    lock_reset;
logic                    clear_latent_fault;
//Diagnostic error injection enable
logic                    enable_error_injection;
//MMIO One-Hot FSM error and E2E error
logic [1:0]              dr_sfty_mmio_fsm_pe;
logic                    sfty_ibp_mmio_tgt_e2e_err;

//Par1: Safety Monitor Register Access
rl_sfty_mnt_reg_agent u_rl_sfty_mnt_reg_agent(
  .sfty_ibp_mmio_cmd_valid      (sfty_ibp_mmio_cmd_valid     ),   // Connect to Core          
  .sfty_ibp_mmio_cmd_cache      (sfty_ibp_mmio_cmd_cache     ),        
  .sfty_ibp_mmio_cmd_burst_size (sfty_ibp_mmio_cmd_burst_size),                             
  .sfty_ibp_mmio_cmd_read       (sfty_ibp_mmio_cmd_read      ),                      
  .sfty_ibp_mmio_cmd_aux        (sfty_ibp_mmio_cmd_aux       ),                     
  .sfty_ibp_mmio_cmd_accept     (sfty_ibp_mmio_cmd_accept    ),                      
  .sfty_ibp_mmio_cmd_addr       (sfty_ibp_mmio_cmd_addr      ),                                   
  .sfty_ibp_mmio_cmd_excl       (sfty_ibp_mmio_cmd_excl      ),
  .sfty_ibp_mmio_cmd_atomic     (sfty_ibp_mmio_cmd_atomic    ),        
  .sfty_ibp_mmio_cmd_data_size  (sfty_ibp_mmio_cmd_data_size ),                           
  .sfty_ibp_mmio_cmd_prot       (sfty_ibp_mmio_cmd_prot      ),                      

  .sfty_ibp_mmio_wr_valid       (sfty_ibp_mmio_wr_valid      ),          
  .sfty_ibp_mmio_wr_last        (sfty_ibp_mmio_wr_last       ),         
  .sfty_ibp_mmio_wr_accept      (sfty_ibp_mmio_wr_accept     ),          
  .sfty_ibp_mmio_wr_mask        (sfty_ibp_mmio_wr_mask       ),         
  .sfty_ibp_mmio_wr_data        (sfty_ibp_mmio_wr_data       ),         
  
  .sfty_ibp_mmio_rd_valid       (sfty_ibp_mmio_rd_valid      ),                      
  .sfty_ibp_mmio_rd_err         (sfty_ibp_mmio_rd_err        ),                    
  .sfty_ibp_mmio_rd_excl_ok     (sfty_ibp_mmio_rd_excl_ok    ),        
  .sfty_ibp_mmio_rd_last        (sfty_ibp_mmio_rd_last       ),                      
  .sfty_ibp_mmio_rd_accept      (sfty_ibp_mmio_rd_accept     ),                      
  .sfty_ibp_mmio_rd_data        (sfty_ibp_mmio_rd_data       ),          
  
  .sfty_ibp_mmio_wr_done        (sfty_ibp_mmio_wr_done       ),
  .sfty_ibp_mmio_wr_excl_okay   (sfty_ibp_mmio_wr_excl_okay  ),          
  .sfty_ibp_mmio_wr_err         (sfty_ibp_mmio_wr_err        ),
  .sfty_ibp_mmio_wr_resp_accept (sfty_ibp_mmio_wr_resp_accept),
// IBP e2e protection interface
  .sfty_ibp_mmio_cmd_valid_pty  (sfty_ibp_mmio_cmd_valid_pty ),
  .sfty_ibp_mmio_cmd_accept_pty (sfty_ibp_mmio_cmd_accept_pty),              
  .sfty_ibp_mmio_cmd_addr_pty   (sfty_ibp_mmio_cmd_addr_pty  ),             
  .sfty_ibp_mmio_cmd_ctrl_pty   (sfty_ibp_mmio_cmd_ctrl_pty  ),
  
  .sfty_ibp_mmio_wr_valid_pty   (sfty_ibp_mmio_wr_valid_pty  ),    
  .sfty_ibp_mmio_wr_accept_pty  (sfty_ibp_mmio_wr_accept_pty ),   
  .sfty_ibp_mmio_wr_last_pty    (sfty_ibp_mmio_wr_last_pty   ),    
  
  .sfty_ibp_mmio_rd_valid_pty   (sfty_ibp_mmio_rd_valid_pty  ),                
  .sfty_ibp_mmio_rd_accept_pty  (sfty_ibp_mmio_rd_accept_pty ),               
  .sfty_ibp_mmio_rd_ctrl_pty    (sfty_ibp_mmio_rd_ctrl_pty   ),              
  .sfty_ibp_mmio_rd_data_pty    (sfty_ibp_mmio_rd_data_pty   ),
  
  .sfty_ibp_mmio_wr_done_pty    (sfty_ibp_mmio_wr_done_pty   ),
  .sfty_ibp_mmio_wr_ctrl_pty    (sfty_ibp_mmio_wr_ctrl_pty   ),
  .sfty_ibp_mmio_wr_resp_accept_pty(sfty_ibp_mmio_wr_resp_accept_pty),

// msic
  .sfty_ibp_mmio_tgt_e2e_err    (sfty_ibp_mmio_tgt_e2e_err   ),
  
  .lsc_err_stat_aux             (lsc_err_stat_aux),
  .sfty_nsi_r                   (sfty_nsi_r),
  .lsc_latt_err_stat_aux        (lsc_latt_err_stat_aux),
  .dr_sfty_e2e_diag_mode        (dr_sfty_e2e_diag_mode),
  .dr_sfty_e2e_diag_inj_end     (dr_sfty_e2e_diag_inj_end),
  .dr_sfty_e2e_mask_pty_err     (dr_sfty_e2e_mask_pty_err),
  .dr_e2e_check_error_sticky    (dr_e2e_check_error_sticky),
  .clear_latent_fault           (clear_latent_fault),
  .dr_sfty_mmio_fsm_pe          (dr_sfty_mmio_fsm_pe),
  
  .clk                          (clk),
  .rst                          (sync_rst_as)
);

//Part2: Safety Monitor Error Aggregator

rl_sfty_mnt_err_aggr  #(
       .SMI_WIDTH        (SMI_WIDTH)
) u_rl_sfty_mnt_err_aggr(
  .dr_sfty_smi_diag_mode        (dr_sfty_smi_diag_mode),    // Connect to u_ls_sfty_mnt_diag_ctrl
  .sfty_smi_error_mask          (sfty_smi_error_mask),   // Connect to u_ls_sfty_mnt_diag_ctrl
  .sfty_smi_valid_mask          (sfty_smi_valid_mask),   // Connect to u_ls_sfty_mnt_diag_ctrl
  .dr_sfty_smi_diag_inj_end     (dr_sfty_smi_diag_inj_end), // Connect to u_ls_sfty_mnt_diag_ctrl
  .dr_sfty_smi_mask_pty_err     (dr_sfty_smi_mask_pty_err), // Connect to u_ls_sfty_mnt_diag_ctrl
  .cpu_dr_mismatch_r                (cpu_dr_mismatch_r),
  .cpu_dr_sfty_ctrl_parity_error    (cpu_dr_sfty_ctrl_parity_error),
  .cpu_dr_sfty_diag_inj_end         (cpu_dr_sfty_diag_inj_end),
  .cpu_dr_mask_pty_err              (cpu_dr_mask_pty_err),
  .cpu_dr_sfty_diag_mode_sc         (cpu_dr_sfty_diag_mode_sc),

    // The signals specific to the replicated entity, not the controller:
  .dr_lsc_stl_ctrl_aux_r     (dr_lsc_stl_ctrl_aux_r),
  .dr_sfty_aux_parity_err_r  (dr_sfty_aux_parity_err_r),
  .dr_bus_fatal_err          (dr_bus_fatal_err),
  .dr_safety_iso_err         (dr_safety_iso_err),
  .dr_secure_trig_iso_err    (dr_secure_trig_iso_err),
  .sfty_mem_sbe_err          (sfty_mem_sbe_err     ),
  .sfty_mem_dbe_err          (sfty_mem_dbe_err     ),
  .sfty_mem_adr_err          (sfty_mem_adr_err     ),
  .sfty_mem_sbe_overflow     (sfty_mem_sbe_overflow),
  .high_prio_ras             (high_prio_ras),
  .lsc_err_stat_aux          (lsc_err_stat_aux),
  .dr_sfty_eic               (dr_sfty_eic),
  .safety_enabled               (safety_enabled),
  .safety_error                 (safety_error),
  .safety_mem_dbe               (safety_mem_dbe),
  .safety_mem_sbe               (safety_mem_sbe),
  .lsc_latt_err_stat_aux        (lsc_latt_err_stat_aux),
  .dr_sfty_mei_diag_mode        (dr_sfty_mei_diag_mode),
  .dr_sfty_e2e_diag_mode        (dr_sfty_e2e_diag_mode),
  .dr_sfty_e2e_diag_inj_end     (dr_sfty_e2e_diag_inj_end),
  .dr_sfty_e2e_mask_pty_err     (dr_sfty_e2e_mask_pty_err),
  .dr_e2e_check_error_sticky    (dr_e2e_check_error_sticky),
  .lock_reset                   (lock_reset),
  .clear_latent_fault           (clear_latent_fault),
  .enable_error_injection       (enable_error_injection),
  .dr_sfty_mmio_fsm_pe          (dr_sfty_mmio_fsm_pe),
  .wdt_reset0               (wdt_reset0),
  .sfty_ibp_mmio_tgt_e2e_err     (sfty_ibp_mmio_tgt_e2e_err),
  .sfty_ibp_mmio_ini_e2e_err     (sfty_ibp_mmio_ini_e2e_err),
  .sfty_dmsi_tgt_e2e_err         (sfty_dmsi_tgt_e2e_err),
  .clk                          (clk),
  .rst                          (sync_rst_as)
);



//Part3: Safety Monitor Diagnostic Error Injection Control 
ls_sfty_mnt_diag_ctrl  #(
       .SMI_WIDTH        (SMI_WIDTH)
) u_rl_sfty_mnt_diag_ctrl(
  .dr_sfty_smi_diag_mode        (dr_sfty_smi_diag_mode),    // Connect to rl_sfty_mnt_err_aggr
  .sfty_smi_error_mask          (sfty_smi_error_mask),   // Connect to rl_sfty_mnt_err_aggr
  .sfty_smi_valid_mask          (sfty_smi_valid_mask),   // Connect to rl_sfty_mnt_err_aggr
  .dr_sfty_smi_diag_inj_end     (dr_sfty_smi_diag_inj_end), // Connect to rl_sfty_mnt_err_aggr
  .dr_sfty_smi_mask_pty_err     (dr_sfty_smi_mask_pty_err), // Connect to rl_sfty_mnt_err_aggr
  .clk                          (clk),
  .rst                          (sync_rst_as)
); 

//Part4: Glue logic: Reset synchronizer; Safety Isolation; Lock Reset; Safety Enable; Hybrid Mode Ctrl
//Reset Sychronizer
//ls_cdc_reset_sync        u_rst_cdc_sync (
//.clk   (clk),
//.rst_a (rst_a),
//.test_mode (test_mode),
//.dout  (sync_rst_as)
//);
assign clk = cpu_clk_gated;
assign sync_rst_as = cpu_rst_gated;

//Lock Reset
assign lock_reset = 1'b0
	|cpu_lsAls_lock_reset
;

//Safety Enabled
assign dr_safety_comparator_enabled = cpu_lsAsafety_comparator_enabled;
assign safety_enabled = (1'b1
                      && `def_dr_en_chk(cpu_lsAsafety_comparator_enabled)
                         )? 2'b10 : 2'b01;


//Hybrid Mode

assign clear_latent_fault     = 1'b0
                                 | (lsc_diag_aux_r[`rv_diag_clf_impl] == 2'b10)
                                 ;
//Diagnostic Error Injection Control
assign enable_error_injection     = 1'b0
                                 | (lsc_diag_aux_r[`rv_diag_mode_enable_impl] == 2'b10)
                                 ;

always_comb
begin: error_inject_PROC
  dr_sfty_smi_diag_mode                    = 2'b01;
  cpu_dr_sfty_diag_mode_sc            = 2'b01;
  dr_sfty_mei_diag_mode                    = 2'b01;
  dr_sfty_e2e_diag_mode                    = 2'b01;
	if (enable_error_injection && (lsc_diag_aux_r[`rv_diag_smi_error_impl] == 2'b10))
	  dr_sfty_smi_diag_mode                = 2'b10;
	if (enable_error_injection && (lsc_diag_aux_r[`rv_diag_cei_error_impl] == 2'b10))
      cpu_dr_sfty_diag_mode_sc        = 2'b10;
	if (enable_error_injection && (lsc_diag_aux_r[`rv_diag_e2e_error_impl] == 2'b10))
	  dr_sfty_e2e_diag_mode                = 2'b10;
	if (enable_error_injection && (lsc_diag_aux_r[`rv_diag_mei_error_impl] == 2'b10))
	  dr_sfty_mei_diag_mode                = 2'b10;
end // block: error_inject_PROC

endmodule

