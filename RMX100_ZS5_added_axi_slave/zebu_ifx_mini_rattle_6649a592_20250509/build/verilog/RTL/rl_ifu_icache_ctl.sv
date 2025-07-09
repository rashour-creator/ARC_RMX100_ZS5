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

module rl_ifu_icache_ctl (

  ////////// General input signals ///////////////////////////////////////////
  //
  input                           clk,
  input                           rst_a,
  input                           fch_restart,
  ////////// I-Cache Refill State /////////////////////////////////////////////
  //
  input [2:0]                     ic_state,
  ////////// Aux Interface - Cache CSR /////////////////////////////////////////////
  //
  input                            arcv_icache_op_init,       // Initiate Cache Maintenance Operation
  input      [`ARCV_MC_CTL_RANGE]  arcv_mcache_ctl,           // I-Cache CSR Control
  input      [`ARCV_MC_OP_RANGE]   arcv_mcache_op,            // I-Cache CSR Op Type
  input      [`ARCV_MC_ADDR_RANGE] arcv_mcache_addr,          // I-Cache CSR Op Address
  input      [`ARCV_MC_LN_RANGE]   arcv_mcache_lines,         // I-Cache Op Number of Lines
  input      [`DATA_RANGE]         arcv_mcache_data,          // I-Cache Op Data to be written 

  output                           arcv_icache_op_done,            // I-Cache Operation Complete
  output     [`DATA_RANGE]         arcv_icache_data,               // I-Cache TAG/DATA/STATUS 
  output                           arcv_icache_op_in_progress , 

  /////////// I-CACHE CMO/CBO /////////////////////
  //
  input                           spc_x2_flush,
  input                           spc_x2_inval,
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read 
  // SJ:  These ops not applicable for I-Cache
  input                           spc_x2_clean,
  input                           spc_x2_zero,
  // spyglass enable_block W240
  input                           spc_x2_prefetch,
  input [`DATA_RANGE]             spc_x2_data,
  output                          icmo_op_done,
  output                          spc_op_in_prg, 
  input                           halt_req_asserted,

  /////////// I-CACHE RF Interface /////////////////////
  //
  input                           rf_ic_cache_instr_done,

  output                          ic_disabled,
  output                          ic_op_inv_all,
  output                          ic_op_adr_inv,
  output                          ic_op_adr_lock,
  output                          ic_op_adr_unlock,
  output                          ic_op_idx_inv,
  output                          ic_op_idx_rd_tag,
  output                          ic_op_idx_rd_data,
  output                          ic_op_idx_wr_tag,
  output                          ic_op_idx_wr_data,
//  output                          ic_ctl_read_cache,
  output                          ic_op_prefetch,
  output  [`DATA_RANGE]           ic_icmo_adr,
  output  [`DATA_RANGE]           ic_op_wr_data,
  input   [`IC_TRAM_DATA_RANGE]   ic_ctl_tag,
  input   [`DATA_RANGE]           ic_ctl_data
);


wire                    ic_op_init;
wire [3:0]              ic_op;
reg  [`DATA_RANGE]      ic_op_data_nxt;
reg  [`DATA_RANGE]      ic_op_data_r;
reg  [`ARCV_MC_LN_RANGE] ic_op_range_nxt;
reg  [`ARCV_MC_LN_RANGE] ic_op_range_r;
reg                     ic_disabled_r;

reg                     ic_op_inv_all_nxt;
reg                     ic_op_adr_inv_nxt;
reg                     ic_op_adr_lock_nxt;
reg                     ic_op_adr_unlock_nxt;
reg                     ic_op_idx_inv_nxt;
reg                     ic_op_idx_rd_tag_nxt;
reg                     ic_op_idx_rd_data_nxt;
reg                     ic_op_idx_wr_tag_nxt;
reg                     ic_op_idx_wr_data_nxt;
reg                     ic_op_inv_all_r;
reg                     ic_op_adr_inv_r;
reg                     ic_op_adr_lock_r;
reg                     ic_op_adr_unlock_r;
reg                     ic_op_idx_inv_r;
reg                     ic_op_idx_rd_tag_r;
reg                     ic_op_idx_rd_data_r;
reg                     ic_op_idx_wr_tag_r;
reg                     ic_op_idx_wr_data_r;
reg [`DATA_RANGE]       ic_opmo_adr_nxt;
reg [`DATA_RANGE]       ic_opmo_adr_r;
reg [`ARCV_MC_ADDR_RANGE] icmo_adr_nxt;
reg [`ARCV_MC_ADDR_RANGE] icmo_adr_r;
reg                     icmo_region_req;
reg                     icmo_region_start;
reg                     icmo_region_end;
reg [`ARCV_MC_LN_RANGE] icl_ctr; 
reg [`ARCV_MC_LN_RANGE] icl_ctr_nxt;
reg [`ARCV_MC_LN_RANGE] total_cache_lines;
reg                     ic_op_adr_inv_done;
reg                     arcv_ic_region_op_done;
reg                     ic_op_done;
wire                    arcv_ic_region_op;
reg                     arcv_icache_op_done_nxt;
reg                     arcv_icache_op_done_r;
reg [`DATA_RANGE]       arcv_icache_data_nxt;
reg [`DATA_RANGE]       arcv_icache_data_r;
reg                     arcv_icache_op_complete_r;
reg [`DATA_RANGE]       spc_x2_data_r;
reg                     cmo_nxt;
reg                     cmo_r;
reg                     icmo_done;
reg                     icmo_done_r;
reg                     ic_prefetch_r;
reg                     ic_prefetch_nxt;
reg                     icmo_op_state_r;
reg                     icmo_op_state_nxt;
reg                     icmo_op_in_prg;
reg                     arcv_ic_op_in_prg;
reg                     arcv_ic_op_in_prg_r;
reg                     spc_x2_inval_r;
reg                     spc_x2_flush_r;
reg                     dis_icmo_restart;
reg                     dis_icmo_restart_r;
reg                     fch_restart_r;
reg                     rf_ic_cache_instr_done_r;
reg                     spc_x2_op_r;
wire                    dont_init_spc_op;

assign dont_init_spc_op = (~spc_x2_op_r & fch_restart_r
                            & (spc_x2_flush_r | spc_x2_inval_r | ic_prefetch_r)
                          );

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    spc_x2_op_r <= 1'b0;
  end
  else
  begin
    spc_x2_op_r <= (spc_x2_flush_r | spc_x2_inval_r | ic_prefetch_r); 
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    spc_x2_flush_r <= 1'b0;
    spc_x2_inval_r <= 1'b0;
  end
  else
  begin
     if ((rf_ic_cache_instr_done == 1'b1) & (arcv_ic_op_in_prg_r == 1'b0))
     begin
       spc_x2_flush_r <= 1'b0; 
       spc_x2_inval_r <= 1'b0; 
     end
     else if (rf_ic_cache_instr_done_r == 1'b1)
     begin
       spc_x2_flush_r <= 1'b0; 
       spc_x2_inval_r <= 1'b0; 
     end
     else if (dont_init_spc_op)
     begin
       spc_x2_flush_r <= 1'b0; 
       spc_x2_inval_r <= 1'b0; 
     end
     else if (cmo_r == 1'b0)
     begin
       spc_x2_flush_r <= spc_x2_flush;
       spc_x2_inval_r <= spc_x2_inval;
     end
  end
end


always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    spc_x2_data_r <= `DATA_WIDTH'b0;
  end
  else
  begin
    if (cmo_r == 1'b0)
    begin
      spc_x2_data_r <= spc_x2_data;
    end
  end
end


always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    arcv_icache_op_complete_r <= 1'b0;
  end
  else
  begin
    arcv_icache_op_complete_r <= arcv_icache_op_done_nxt;
  end
end


always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    rf_ic_cache_instr_done_r <= 1'b0;
  end
  else
  begin
    rf_ic_cache_instr_done_r <= rf_ic_cache_instr_done;
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    ic_disabled_r <= 1'b1;
  end
  else
  begin
    ic_disabled_r <= ic_disabled;
  end
end


assign ic_disabled   = ((ic_state == 3'b000) | (ic_state == 3'b101)) ? ~arcv_mcache_ctl[0]: ic_disabled_r;
assign ic_op_init    = arcv_icache_op_init; 
assign ic_op         = arcv_mcache_op[3:0]; 

always@*
begin: ic_op_inv_all_PROC
  ic_op_inv_all_nxt = ic_op_inv_all_r;
  if (rf_ic_cache_instr_done == 1'b1)
  begin
    ic_op_inv_all_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_inv_all_nxt = 1'b0;
  end
  else if ((ic_op == `I_INV_ALL) & arcv_icache_op_init)
  begin
    ic_op_inv_all_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_inv_all_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_inv_all_r <= 1'b0;
  end
  else
  begin
    ic_op_inv_all_r <= ic_op_inv_all_nxt;
  end
end

always@*
begin: ic_op_adr_inv_PROC
  ic_op_adr_inv_nxt = ic_op_adr_inv_r;
  if (arcv_ic_region_op_done == 1'b1)
  begin
    ic_op_adr_inv_nxt = 1'b0;
  end
  else if ((arcv_icache_op_complete_r == 1'b1) | (icmo_done_r == 1'b1))
  begin
    ic_op_adr_inv_nxt = 1'b0;
  end
  else if (((ic_op == `I_ADR_INV) & arcv_icache_op_init) | ((spc_x2_flush_r | spc_x2_inval_r) & (~arcv_ic_op_in_prg) & (~dont_init_spc_op)))
  begin
    ic_op_adr_inv_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_adr_inv_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_adr_inv_r <= 1'b0;
  end
  else
  begin
    ic_op_adr_inv_r <= ic_op_adr_inv_nxt;
  end
end


always@*
begin: ic_op_adr_lock_PROC
  ic_op_adr_lock_nxt = ic_op_adr_lock_r;
  //if (rf_ic_cache_instr_done == 1'b1)
  if (arcv_ic_region_op_done == 1'b1)
  begin
    ic_op_adr_lock_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_adr_lock_nxt = 1'b0;
  end
  else if ((ic_op == `I_ADR_LOCK) & arcv_icache_op_init)
  begin
    ic_op_adr_lock_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_adr_lock_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_adr_lock_r <= 1'b0;
  end
  else
  begin
    ic_op_adr_lock_r <= ic_op_adr_lock_nxt & (~rf_ic_cache_instr_done);
  end
end


always@*
begin: ic_op_adr_unlock_PROC
  ic_op_adr_unlock_nxt = ic_op_adr_unlock_r;
  //if (rf_ic_cache_instr_done == 1'b1)
  if (arcv_ic_region_op_done == 1'b1)
  begin
    ic_op_adr_unlock_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_adr_unlock_nxt = 1'b0;
  end
  else if ((ic_op == `I_ADR_UNLOCK) & arcv_icache_op_init)
  begin
    ic_op_adr_unlock_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_adr_unlock_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_adr_unlock_r <= 1'b0;
  end
  else
  begin
    ic_op_adr_unlock_r <= ic_op_adr_unlock_nxt & (~rf_ic_cache_instr_done);
  end
end


always@*
begin: ic_op_idx_inv_PROC
  ic_op_idx_inv_nxt = ic_op_idx_inv_r;
  if (rf_ic_cache_instr_done == 1'b1)
  begin
    ic_op_idx_inv_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_idx_inv_nxt = 1'b0;
  end
  else if ((ic_op == `I_IDX_INV) & arcv_icache_op_init)
  begin
    ic_op_idx_inv_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
  begin: ic_op_idx_inv_reg_PROC
    if (rst_a == 1'b1)
      begin
        ic_op_idx_inv_r <= 1'b0;
      end
    else
      begin
        ic_op_idx_inv_r <= ic_op_idx_inv_nxt;
      end
  end


always@*
begin: ic_op_idx_rd_tag_PROC
  ic_op_idx_rd_tag_nxt = ic_op_idx_rd_tag_r;
  if (rf_ic_cache_instr_done == 1'b1)
  begin
    ic_op_idx_rd_tag_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_idx_rd_tag_nxt = 1'b0;
  end
  else if ((ic_op == `I_IDX_READ_TAG) & arcv_icache_op_init)
  begin
    ic_op_idx_rd_tag_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_idx_rd_tag_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_idx_rd_tag_r <= 1'b0;
  end
  else
  begin
    ic_op_idx_rd_tag_r <= ic_op_idx_rd_tag_nxt;
  end
end


always@*
begin: ic_op_idx_rd_data_PROC
  ic_op_idx_rd_data_nxt = ic_op_idx_rd_data_r;
  if (rf_ic_cache_instr_done == 1'b1)
  begin
    ic_op_idx_rd_data_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_idx_rd_data_nxt = 1'b0;
  end
  else if ((ic_op == `I_IDX_READ_DATA) & arcv_icache_op_init)
  begin
    ic_op_idx_rd_data_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_idx_rd_data_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_idx_rd_data_r <= 1'b0;
  end
  else
  begin
    ic_op_idx_rd_data_r <= ic_op_idx_rd_data_nxt;
  end
end

always@*
begin: ic_op_idx_wr_tag_PROC
  ic_op_idx_wr_tag_nxt = ic_op_idx_wr_tag_r;
  if (rf_ic_cache_instr_done == 1'b1)
  begin
    ic_op_idx_wr_tag_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_idx_wr_tag_nxt = 1'b0;
  end
  else if ((ic_op == `I_IDX_WRITE_TAG) & arcv_icache_op_init)
  begin
    ic_op_idx_wr_tag_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_idx_wr_tag_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_idx_wr_tag_r <= 1'b0;
  end
  else
  begin
    ic_op_idx_wr_tag_r <= ic_op_idx_wr_tag_nxt;
  end
end

always@*
begin: ic_op_idx_wr_data_PROC
  ic_op_idx_wr_data_nxt = ic_op_idx_wr_data_r;
  if (rf_ic_cache_instr_done == 1'b1)
  begin
    ic_op_idx_wr_data_nxt = 1'b0;
  end
  else if (arcv_icache_op_complete_r == 1'b1)
  begin
    ic_op_idx_wr_data_nxt = 1'b0;
  end
  else if ((ic_op == `I_IDX_WRITE_DATA) & arcv_icache_op_init)
  begin
    ic_op_idx_wr_data_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin: ic_op_idx_wr_data_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_op_idx_wr_data_r <= 1'b0;
  end
  else
  begin
    ic_op_idx_wr_data_r <= ic_op_idx_wr_data_nxt;
  end
end

always@*
begin
  ic_op_data_nxt   = ic_op_data_r; 
  ic_op_range_nxt  = ic_op_range_r;
  if (arcv_icache_op_init == 1'b1)
  begin
    ic_op_data_nxt   = arcv_mcache_data; 
    ic_op_range_nxt  = (|arcv_mcache_lines) ? arcv_mcache_lines: `ARCV_MC_LN_WDT'b1;
  end
end

assign arcv_ic_region_op = (ic_op_adr_inv | ic_op_adr_lock | ic_op_adr_unlock);

always@*
begin
  ic_prefetch_nxt = ic_prefetch_r;
  if ((rf_ic_cache_instr_done == 1'b1) & (arcv_ic_op_in_prg_r == 1'b0))
  begin
    ic_prefetch_nxt = 1'b0;
  end
  else if (rf_ic_cache_instr_done_r == 1'b1)
  begin
    ic_prefetch_nxt = 1'b0;
  end
  else if (dont_init_spc_op)
  begin
    ic_prefetch_nxt = 1'b0;
  end
  else if (cmo_r == 1'b0)
  begin
    ic_prefetch_nxt = spc_x2_prefetch;
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    ic_prefetch_r <= 1'b0;
  end
  else
  begin
    ic_prefetch_r <= ic_prefetch_nxt;
  end
end



always@*
begin
  cmo_nxt   = cmo_r;
  icmo_done = 1'b0;
  if (icmo_done_r)
  begin
    cmo_nxt   = 1'b0; 
    icmo_done = 1'b0;
  end
  else if (cmo_r)
  begin
    if ((rf_ic_cache_instr_done == 1'b1) & (arcv_ic_op_in_prg_r == 1'b0))
    begin
      cmo_nxt   = 1'b0; 
      icmo_done = (~dis_icmo_restart); 
    end
    else if (dont_init_spc_op)
    begin
      cmo_nxt   = 1'b0; 
      icmo_done = 1'b0;
    end
  end
  else if (spc_x2_flush | spc_x2_inval | spc_x2_prefetch)
  begin
    cmo_nxt = 1'b1;
    if (rf_ic_cache_instr_done_r == 1'b1)
    begin
      cmo_nxt = 1'b0;
    end
  end
  else
  begin
    cmo_nxt = 1'b0;
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    cmo_r               <= 1'b0;
    icmo_done_r         <= 1'b0;
    fch_restart_r       <= 1'b0;
    dis_icmo_restart_r  <= 1'b0;
    arcv_ic_op_in_prg_r <= 1'b0;
  end
  else
  begin
    cmo_r               <= cmo_nxt;
    icmo_done_r         <= icmo_done; 
    fch_restart_r       <= fch_restart;
    dis_icmo_restart_r  <= dis_icmo_restart; 
    arcv_ic_op_in_prg_r <= arcv_ic_op_in_prg; 
  end
end


always@*
begin
  dis_icmo_restart = dis_icmo_restart_r; 
  if (cmo_r == 1'b0)
  begin
    dis_icmo_restart = 1'b0;
  end
  else 
    if (fch_restart_r)
    begin
      dis_icmo_restart = 1'b1;
    end
end


assign icmo_op_done = icmo_done_r & (~halt_req_asserted) & (~fch_restart_r);
assign spc_op_in_prg= cmo_r;

localparam IC_OP_STATE_IDLE      = 1'b0;
localparam IC_OP_STATE_WAIT4DONE = 1'b1;

always@(posedge clk or posedge rst_a)
begin: ic_opmo_reg_PROC 
  if (rst_a == 1'b1)
  begin
    icmo_adr_r          <= `ARCV_MC_ADDR_WIDTH'b0; 
    icmo_op_state_r     <= IC_OP_STATE_IDLE;
    icl_ctr             <= `ARCV_MC_LN_WDT'b0; 
    ic_op_range_r       <= `ARCV_MC_LN_WDT'b0;
    ic_op_data_r        <= `DATA_SIZE'b0;
  end
  else
  begin
    icmo_adr_r          <= icmo_adr_nxt; 
    icl_ctr             <= icl_ctr_nxt;
    ic_op_range_r       <= ic_op_range_nxt; 
    ic_op_data_r        <= ic_op_data_nxt;
    icmo_op_state_r     <= icmo_op_state_nxt;
  end
end


always@*
begin
  icmo_op_state_nxt      = icmo_op_state_r;
  icl_ctr_nxt            = icl_ctr; 
  ic_op_adr_inv_done     = 1'b0;
  icmo_adr_nxt           = icmo_adr_r;
  icmo_op_in_prg         = 1'b0;
  arcv_ic_op_in_prg      = 1'b0;
  arcv_ic_region_op_done = 1'b0; 
  //arcv_icache_op_in_progress = 1'b0;
  case (icmo_op_state_r)
  IC_OP_STATE_IDLE:
  begin
    if (cmo_r == 1'b1)
      begin
        icmo_op_state_nxt  = IC_OP_STATE_WAIT4DONE;
        icmo_adr_nxt       = spc_x2_data_r[`IFU_ADDR_RANGE];
        icl_ctr_nxt        = `ARCV_MC_LN_WDT'b1;
        icmo_op_in_prg     = 1'b1;
      end
    else if ((arcv_icache_op_init == 1'b1) & (arcv_icache_op_complete_r == 1'b0))
      begin
        icmo_op_state_nxt  = IC_OP_STATE_WAIT4DONE;
        icmo_adr_nxt       = arcv_mcache_addr;
        icl_ctr_nxt        = `ARCV_MC_LN_WDT'b1;
        arcv_ic_op_in_prg  = 1'b1;
      end
  end
  IC_OP_STATE_WAIT4DONE:
  begin
    if (cmo_r == 1'b1)
      begin
        icmo_op_in_prg    = 1'b1;
      end
    else
      begin
        arcv_ic_op_in_prg = 1'b1;
      end
    if (rf_ic_cache_instr_done == 1'b1)
      begin
        icmo_op_in_prg = 1'b0;
        case ({cmo_r, arcv_ic_region_op})
        2'b01:
        begin
// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width 
// SJ:   Intended. no possible loss of data
          icmo_adr_nxt           = arcv_mcache_addr + {icl_ctr, `IC_WRD_WIDTH'b0};
// spyglass enable_block W164a
          if (icl_ctr != ic_op_range_r)
            begin
// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width 
// SJ:   Intended. no possible loss of data
              icl_ctr_nxt            = icl_ctr + 1'b1;
// spyglass enable_block W164a
              ic_op_adr_inv_done     = 1'b0;
              arcv_ic_op_in_prg      = 1'b1;
              arcv_ic_region_op_done = 1'b0;
            end
          else
            begin
              icmo_op_state_nxt      = IC_OP_STATE_IDLE;
              icl_ctr_nxt            = `ARCV_MC_LN_WDT'b0; 
              ic_op_adr_inv_done     = 1'b1;
              arcv_ic_op_in_prg      = 1'b0;
              arcv_ic_region_op_done = 1'b1;
            end
        end
        2'b10, 2'b11:
        begin
          icmo_op_in_prg         = 1'b0;
          icmo_op_state_nxt      = IC_OP_STATE_IDLE;
          arcv_ic_op_in_prg      = 1'b0;
          ic_op_adr_inv_done     = 1'b1;
          icl_ctr_nxt            = `ARCV_MC_LN_WDT'b0; 
          arcv_ic_region_op_done = 1'b1;
        end
        default:
        begin
          icmo_op_in_prg     = 1'b0;
          arcv_ic_op_in_prg  = 1'b0;
          icmo_op_state_nxt  = IC_OP_STATE_IDLE;
          icl_ctr_nxt        = `ARCV_MC_LN_WDT'b0; 
          ic_op_adr_inv_done = 1'b0;
          arcv_ic_region_op_done  = 1'b1;
        end
        endcase
      end
  end
  default:
  begin
  end
  endcase
end


always@*
begin
  //arcv_icache_op_done_nxt = ic_op_adr_inv ? ic_op_adr_inv_done: rf_ic_cache_instr_done;
  arcv_icache_op_done_nxt = arcv_icache_op_init ? (arcv_ic_region_op ? arcv_ic_region_op_done : rf_ic_cache_instr_done)
                                                  : 1'b0;
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    arcv_icache_op_done_r <= 1'b0;
    arcv_icache_data_r    <= `DATA_SIZE'b0;
  end
  else
  begin
    arcv_icache_op_done_r <= arcv_icache_op_done_nxt;
    arcv_icache_data_r    <= arcv_icache_data_nxt; 
  end
end

always@*
begin
  arcv_icache_data_nxt = arcv_icache_data_r; 
  case (1'b1)
  ic_op_idx_rd_tag:
  begin
    arcv_icache_data_nxt = {ic_ctl_tag[`IC_TAG_TAG_RANGE], 11'b0, ic_ctl_tag[1:0]};
  end
  ic_op_idx_rd_data:
  begin
    arcv_icache_data_nxt = ic_ctl_data;
  end
  default:
  begin
  end
  endcase
end

assign  arcv_icache_data    = arcv_icache_data_r;
assign  arcv_icache_op_done = arcv_icache_op_done_r;
assign  arcv_icache_op_in_progress = arcv_ic_op_in_prg;

assign  ic_icmo_adr        = {icmo_adr_r, 2'b0};
assign  ic_op_inv_all      = ic_op_inv_all_r;
assign  ic_op_adr_inv      = ic_op_adr_inv_r;
assign  ic_op_adr_lock     = ic_op_adr_lock_r;
assign  ic_op_adr_unlock   = ic_op_adr_unlock_r;
assign  ic_op_idx_inv      = ic_op_idx_inv_r;
assign  ic_op_idx_rd_tag   = ic_op_idx_rd_tag_r;
assign  ic_op_idx_rd_data  = ic_op_idx_rd_data_r;
assign  ic_op_idx_wr_tag   = ic_op_idx_wr_tag_r;
assign  ic_op_idx_wr_data  = ic_op_idx_wr_data_r;
//assign  ic_ctl_read_cache  = ic_op_adr_inv;
assign  ic_op_prefetch     = ic_prefetch_r & (~dont_init_spc_op);
assign  ic_op_wr_data      = ic_op_data_r;


endmodule // rl_ifu_icache_ctl
