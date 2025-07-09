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
`include "dmp_defines.v"
`include "alu_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_dmp (
  ////////// Dispatch interface /////////////////////////////////////////////
  //
  input                      x1_pass,                // instruction dispatched to the DMP FU
  input [`DMP_CTL_RANGE]     x1_dmp_ctl,             // Indicates the instructon to be executed in this FU
  input                      x1_valid_r,             // X1 valid instruction from pipe control
  output                     lsq_empty,
  input [`DATA_RANGE]        x1_src0_data,           // source0 operand  -- address base
  input [`DATA_RANGE]        x1_src1_data,           // source1 operand  -- store data
  input [`DATA_RANGE]        x1_src2_data,           // source2 operand  -- address computation
  input [4:0]                x1_dst_id,              // destination register - used for scoreboarding
  output                     dmp_x1_stall,           // DMP stalls X1

  ////////// Debug access /////////////////////////////////////////////////
  //
  input [1:0]                db_mem_op_1h,           // 0: read, 1: write
  input [`DATA_RANGE]        db_addr,                // Debug mem addr
  input [`DATA_RANGE]        db_wdata,               // Debug mem write data
  input                      db_exception,           // exception in debug mode

  ////////// X2 stage interface /////////////////////////////////////////////
  //
  input                      x2_valid_r,             // X2 valid instruction from pipe ctrl
  input                      x2_pass,                // X2 commit
  input                      x2_enable,              // X2 enable
  output reg [`DATA_RANGE]   dmp_x2_data,            // DMP X2 result available for bypass
  output reg [`DATA_RANGE]   dmp_x2_data_r,
  output reg [`DATA_RANGE]   dmp_x2_addr_r,          // DMP mem addr X2
  output reg                 dmp_x2_load_r,          // DMP X2 load
  output reg                 dmp_x2_mva_stall_r,     // DMP stalls X2 MVA
  output                     dmp_x2_no_mva,
  output reg                 dmp_x2_word_r,
  output reg                 dmp_x2_half_r,
  output [1:0]               lsq_rb_size,
  input                      dmp_addr_trig_trap,
  input                      dmp_ld_data_trig_trap,
  input                      dmp_st_data_trig_trap,

  output                     dmp_x2_grad,            // DMP X2 load graduation
  output reg [4:0]           dmp_x2_dst_id_r,        // DMP X2 destination register - used for scoreboarding
  output                     dmp_x2_dst_id_valid,    // DMP X2 valid destination

  output                     dmp_retire_req,         // DMP retirement request
  output [4:0]               dmp_retire_dst_id,      // DMP retirement destination register - used for scoreboarding

  output                     dmp_rb_req_r,           // DMP requests result bus to write to register file
  output reg                 dmp_rb_post_commit,     // DMP requests result bus qualifier
  output reg                 dmp_rb_retire_err,      // DMP requests result bus with a bus error
  output [4:0]               dmp_rb_dst_id,          // DMP destination register to be written
  input                      x2_dmp_rb_ack,          // results bus granted DMP access (write port)

  output reg                 dmp_x2_stall,           // DMP stalls X2
  output reg                 dmp_x2_replay,          // DMP replays X2
  
  ////////// Privilege Mode ////////////////////////////////////////////
  //
  input [1:0]                priv_level_r,
  input [`DATA_RANGE]        mstatus_r,
  input                      debug_mode,
  input                      mprven_r,

  ////////// PMP interface /////////////////////////////////////////////
  //
  input                      dpmp_hit,               // PMP hit
  input [5:0]                dpmp_perm,              // {L, X, W, R}
  output reg [`ADDR_RANGE]   dmp_x2_addr1_r,
  output reg                 dmp_x2_bank_cross_r,
  input                      cross_region,

  ////////// PMA interface /////////////////////////////////////////////
  //
  input  [5:0]                   dpma_attr,
  output reg [`DMP_TARGET_RANGE] dmp_x2_target_r,
  output reg                     dmp_x2_ccm_hole_r,


  output reg [`DMP_EXCP_RANGE] dmp_exception_sync,
  output reg [1:0]             dmp_exception_async,
  input                        trap_clear_lf,
  ////////// X3 stage interface /////////////////////////////////////////////
  //
  input                      x3_flush_r,             // Pipeline has been flushed

  ////////// LSQ scoreboarding /////////////////////////////////////////////
  //
  output                     dmp_lsq0_dst_valid,  // load destination
  output [4:0]               dmp_lsq0_dst_id,      // destination register - used for scoreboarding
  output                     dmp_lsq1_dst_valid,  // load destination
  output [4:0]               dmp_lsq1_dst_id,      // destination register - used for scoreboarding

  ////////// SRAM interface ////////////////////////////////////////////////
  //

  output  dccm_even_clk,
  output [`DCCM_DRAM_RANGE] dccm_din_even,
  output [`DCCM_ADR_RANGE] dccm_addr_even,
  output  dccm_cs_even,
  output  dccm_we_even,
  output [`DCCM_MASK_RANGE] dccm_wem_even,
  input  [`DCCM_DRAM_RANGE] dccm_dout_even,
  output  dccm_odd_clk,
  output [`DCCM_DRAM_RANGE] dccm_din_odd,
  output [`DCCM_ADR_RANGE] dccm_addr_odd,
  output  dccm_cs_odd,
  output  dccm_we_odd,
  output [`DCCM_MASK_RANGE] dccm_wem_odd,
  input  [`DCCM_DRAM_RANGE] dccm_dout_odd,

  ////////// CSR interface ///////////////////////////////////////////////
  //
  input  [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input  [7:0]                     csr_sel_addr,          // (X1) CSR address

  output [`DATA_RANGE]             csr_rdata,             // (X1) CSR read data
  output                           csr_illegal,           // (X1) illegal
  output                           csr_unimpl,            // (X1) Invalid CSR
  output                           csr_serial_sr,         // (X1) SR group flush pipe
  output                           csr_strict_sr,         // (X1) SR flush pipe

  input                            csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input  [7:0]                     csr_waddr,             // (X2) CSR addr
  input  [`DATA_RANGE]             csr_wdata,             // (X2) Write data

  ////////// IBP target interface ///////////////////////////////////////////////
  //
  input                                 dmi_dccm_prio,  
  input                                 dmi_dccm_cmd_valid,
  input                                 dmi_dccm_cmd_read,
  input  [`ADDR_RANGE]                  dmi_dccm_cmd_addr,
  input                                 dmi_dccm_cmd_excl,
  input  [3:0]                          dmi_dccm_cmd_id,
  output                                dmi_dccm_cmd_accept,

  input                                 dmi_dccm_wr_valid,
  input                                 dmi_dccm_wr_last,
  input  [`DCCM_MEM_MASK_WIDTH-1:0]     dmi_dccm_wr_mask,
  input  [`DCCM_DMI_DATA_RANGE]         dmi_dccm_wr_data,
  output                                dmi_dccm_wr_accept,

  output                                dmi_dccm_rd_valid,
  output                                dmi_dccm_rd_err,
  output                                dmi_dccm_rd_excl_ok,
  output [`DCCM_DMI_DATA_RANGE]         dmi_dccm_rd_data,
  output                                dmi_dccm_rd_last,
  input                                 dmi_dccm_rd_accept,

  output                                dmi_dccm_wr_done,
  output                                dmi_dccm_wr_excl_okay,
  output                                dmi_dccm_wr_err,
  input                                 dmi_dccm_wr_resp_accept,

  input   [11:0]             iccm_base,
  input                      csr_iccm_off,

  output                     lsq_iccm_cmd_valid,
  output  [3:0]              lsq_iccm_cmd_cache,
  output                     lsq_iccm_cmd_burst_size,
  output                     lsq_iccm_cmd_read,
  output                     lsq_iccm_cmd_aux,
  input                      lsq_iccm_cmd_accept,
  output  [`ADDR_RANGE]      lsq_iccm_cmd_addr,
  output                     lsq_iccm_cmd_excl,
  output  [5:0]              lsq_iccm_cmd_atomic,
  output  [2:0]              lsq_iccm_cmd_data_size,
  output  [1:0]              lsq_iccm_cmd_prot,

  output                     lsq_iccm_wr_valid,
  output                     lsq_iccm_wr_last,
  input                      lsq_iccm_wr_accept,
  output  [3:0]              lsq_iccm_wr_mask,
  output  [31:0]             lsq_iccm_wr_data,

  input                      lsq_iccm_rd_valid,
  input                      lsq_iccm_rd_err,
  input                      lsq_iccm_rd_excl_ok,
  input                      lsq_iccm_rd_last,
  output                     lsq_iccm_rd_accept,
  input  [31:0]              lsq_iccm_rd_data,

  input                      lsq_iccm_wr_done,
  input                      lsq_iccm_wr_excl_okay,
  input                      lsq_iccm_wr_err,
  output                     lsq_iccm_wr_resp_accept,

  output                     lsq_mem_cmd_valid,
  output  [3:0]              lsq_mem_cmd_cache,
  output                     lsq_mem_cmd_burst_size,
  output                     lsq_mem_cmd_read,
  output                     lsq_mem_cmd_aux,
  input                      lsq_mem_cmd_accept,
  output  [`ADDR_RANGE]      lsq_mem_cmd_addr,
  output                     lsq_mem_cmd_excl,
  output  [5:0]              lsq_mem_cmd_atomic,
  output  [2:0]              lsq_mem_cmd_data_size,
  output  [1:0]              lsq_mem_cmd_prot,

  output                     lsq_mem_wr_valid,
  output                     lsq_mem_wr_last,
  input                      lsq_mem_wr_accept,
  output  [3:0]              lsq_mem_wr_mask,
  output  [31:0]             lsq_mem_wr_data,

  input                      lsq_mem_rd_valid,
  input                      lsq_mem_rd_err,
  input                      lsq_mem_rd_excl_ok,
  input                      lsq_mem_rd_last,
  output                     lsq_mem_rd_accept,
  input  [31:0]              lsq_mem_rd_data,

  input                      lsq_mem_wr_done,
  input                      lsq_mem_wr_excl_okay,
  input                      lsq_mem_wr_err,
  output                     lsq_mem_wr_resp_accept,

  ////////// LSQ IBP per interface ////////////////////////////////////////////////
  //
  output                     lsq_per_cmd_valid,
  output [3:0]               lsq_per_cmd_cache,
  output                     lsq_per_cmd_burst_size,
  output                     lsq_per_cmd_read,
  output                     lsq_per_cmd_aux,
  input                      lsq_per_cmd_accept,
  output [`ADDR_RANGE]       lsq_per_cmd_addr,
  output                     lsq_per_cmd_excl,
  output [5:0]               lsq_per_cmd_atomic,
  output [2:0]               lsq_per_cmd_data_size,
  output [1:0]               lsq_per_cmd_prot,

  output                     lsq_per_wr_valid,
  output                     lsq_per_wr_last,
  input                      lsq_per_wr_accept,
  output [3:0]               lsq_per_wr_mask,
  output [31:0]              lsq_per_wr_data,

  input                      lsq_per_rd_valid,
  input                      lsq_per_rd_err,
  input                      lsq_per_rd_excl_ok,
  input                      lsq_per_rd_last,
  output                     lsq_per_rd_accept,
  input  [31:0]              lsq_per_rd_data,

  input                      lsq_per_wr_done,
  input                      lsq_per_wr_excl_okay,
  input                      lsq_per_wr_err,
  output                     lsq_per_wr_resp_accept,

  output                     lsq_mmio_cmd_valid,
  output  [3:0]              lsq_mmio_cmd_cache,
  output                     lsq_mmio_cmd_burst_size,
  output                     lsq_mmio_cmd_read,
  output                     lsq_mmio_cmd_aux,
  input                      lsq_mmio_cmd_accept,
  output  [`ADDR_RANGE]      lsq_mmio_cmd_addr,
  output                     lsq_mmio_cmd_excl,
  output  [5:0]              lsq_mmio_cmd_atomic,
  output  [2:0]              lsq_mmio_cmd_data_size,
  output  [1:0]              lsq_mmio_cmd_prot,

  output                     lsq_mmio_wr_valid,
  output                     lsq_mmio_wr_last,
  input                      lsq_mmio_wr_accept,
  output  [3:0]              lsq_mmio_wr_mask,
  output  [31:0]             lsq_mmio_wr_data,

  input                      lsq_mmio_rd_valid,
  input                      lsq_mmio_rd_err,
  input                      lsq_mmio_rd_excl_ok,
  input                      lsq_mmio_rd_last,
  output                     lsq_mmio_rd_accept,
  input  [31:0]              lsq_mmio_rd_data,

  input                      lsq_mmio_wr_done,
  input                      lsq_mmio_wr_excl_okay,
  input                      lsq_mmio_wr_err,
  output                     lsq_mmio_wr_resp_accept,
  input [11:0]               core_mmio_base_r,


 ////////// DMP status ////////////////////////////////////////////////
  //
  output reg                 dmp_idle_r,           // DMP is Idle
  output                     dmp_uncached_busy,
  output                     dmp_per_busy,
  output                     dmp_st_pending,

 ////////// DCCM ECC Interface ////////////////////////////////////////////////
 //
  output                      dccm_ecc_sb_err_even_cnt,

  output                      dccm_ecc_db_err_even_cnt,
  output [`DCCM_ECC_MSB-1:0]  dccm_ecc_syndrome_even,
  output [`DCCM_ADR_RANGE]    dccm_ecc_address_even,  
  output                      dccm_ecc_addr_err_even_cnt,
  output                      dccm_ecc_sb_err_odd_cnt,
  output                      dccm_ecc_db_err_odd_cnt,  
  output [`DCCM_ECC_MSB-1:0]  dccm_ecc_syndrome_odd,
  output [`DCCM_ADR_RANGE]    dccm_ecc_address_odd,
  output                      dccm_ecc_addr_err_odd_cnt,
  output [`DCCM_BANKS-1:0]    dccm_ecc_scrub_err,         // scrub SB err [0] - even bank, [1] - odd bank

  input [7:0]                 arcv_mecc_diag_ecc,
  output                      dccm_ecc_excpn,
  output                      dccm_ecc_wr,
  output [`DCCM_ECC_RANGE]    dccm_ecc_out,


  ////////// HPM Interface /////////////////////////////////////////////
  //
  output                      dmp_hpm_dmpreplay,     // LD/ST replay
  output                      dmp_hpm_bdmplsq,       // LSQ full stall
  output                      dmp_hpm_bdmpcwb,       // CWB full stall

  output reg                  dmp_x2_store_r,        // DMP X2 store
  output reg                  dmp_x2_lr_r,           // DMP X2 load reserved
  output reg                  dmp_x2_sc_r,           // DMP X2 store conditional
  output reg                  dmp_x2_amo_r,          // DMP X2 AMO
  ////////// General input signals /////////////////////////////////////////////
  //
  input                      clk,                   // clock signal
  input                      rst_a                  // reset signal

);

// Local declarations
//
wire [`ADDR_RANGE]            dmp_x1_addr;
wire                          dmp_x1_pass;
wire                          dmp_x1_dst_id_valid;
wire                          dmp_x2_valid;
wire                          dmp_x2_pass;
reg                           dmp_x2_valid_r;
reg                           dmp_x2_valid_nxt;
reg                           dmp_x2_no_mva_r;
reg                           dmp_x2_no_mva_nxt;

reg                           dmp_x2_ctl_cg0;
reg                           dmp_x2_data_cg0;
reg [4:0]                     dmp_x2_dst_id_nxt;

reg                           dmp_x2_rb_req_r;
reg                           dmp_x2_rb_req_nxt;
reg                           dmp_x2_rb_req_cg0;

reg                           dmp_x2_grad_r;
reg                           dmp_x2_grad_nxt;

reg                           dmp_x2_hazard_stall_r;
reg                           dmp_x2_hazard_stall_nxt;
reg                           dmp_x2_hazard_stall_cg0;

wire                          dmp_x1_target_dccm;
wire                          dmp_x2_target_dccm;
wire                          dmp_x2_target_per;
wire                          dmp_x2_target_nvm;

wire [1:0]                    cwb_req;      
wire                          cwb_prio;      
wire [3:0]                    cwb_mask;
wire [`DATA_RANGE]            cwb_data;
wire [`DCCM_ADR_RANGE]        cwb_addr;
wire [1:0]                    cwb_ack;
wire                          cwb_full;
wire                          cwb_one_empty;
wire                          cwb_empty;
wire                          cwb_has_amo;
wire                          dmp_x2_set_lf;
wire                          dmp_x2_clear_lf;
wire                          dmp_x2_lpa_match;

wire                          dmi_set_lf;
wire                          dmi_clear_lf;
wire [31:2]                   x2_dmi_addr_r;
wire [3:0]                    x2_dmi_id_r;

reg                           x3_lpa_cg0;
reg [`ADDR_RANGE]             x3_lpa_nxt;
reg                           x3_lf_cg0;
reg [1:0]                     x3_lock_flag_nxt;
reg [`DMP_TTL_RANGE]          x3_lock_counter_r;
reg                           set_lock_counter;
reg                           dmi_id_cg0;
reg                           lf_clear;
reg [`ADDR_RANGE]             x3_lpa_r;
reg [1:0]                     x3_lock_flag_r;
reg [3:0]                     x3_lock_dmi_id_r;
wire [`PER_BASE_RANGE]        csr_per0_base_r;
wire [`PER_BASE_RANGE]        csr_per0_limit;
wire                          dmp_x1_ccm_hole;
wire [11:0]                   dccm_base;
wire                          csr_dccm_off;
wire [1:0]                    dccm_ecc_enable;
wire                          csr_dccm_rwecc;
wire                          dccm_ecc_sb_error_even;
wire                          dccm_ecc_sb_error_odd;
wire                          dccm_ecc_db_error_even;
wire                          dccm_ecc_db_error_odd;
wire                          dmp_x2_scrub_sb_err_even;
wire                          dmp_x2_scrub_sb_err_odd;
wire                          dmp_x2_dccm_ecc_sb_err_even;
wire                          dmp_x2_dccm_ecc_sb_err_odd;
wire                          dmp_x2_dccm_ecc_db_err_even;
wire                          dmp_x2_dccm_ecc_db_err_odd;
wire                          dccm_ecc_addr_error_even;
wire                          dccm_ecc_addr_error_odd;

wire [`DCCM_ECC_RANGE]        dccm_ecc_even_out;
wire [`DCCM_ECC_RANGE]        dccm_ecc_odd_out;
wire [`DCCM_DATA_RANGE]       dccm_dout_even_correct;
wire [`DCCM_DATA_RANGE]       dccm_dout_odd_correct;
wire                          x2_dmi_sb_error_even;
wire                          x2_dmi_sb_error_odd;
wire                          dmp_x1_dccm_target;
wire                          dmp_x1_dccm_hole;
wire [`ADDR_RANGE]            dccm_physical_limit;
wire                          dmp_x2_cwb_stall;

wire [1:0]                    dmi_arb_freeze;
wire [1:0]                    dmi_hp_req;
wire [1:0]                    dmi_req;
wire [1:0]                    dmi_req_early;
wire                          dmi_read;
wire                          dmi_excl;
wire [3:0]                    dmi_id;
wire [31:2]                   dmi_addr;
wire [1:0]                    dmi_ack;
wire                          dmi_rmw;
wire                          dmi_scrub_r;
wire                          dmi_scrub_reset;

wire [31:0]                   dmi_wr_data;
wire [3:0]                    dmi_wr_mask;
wire                          dmi_wr_done;

wire [31:0]                   dmi_rd_data;
wire                          dmi_rd_valid;
wire                          pipe_lost_to_dmi;
wire                          dmi_rd_err;
wire                          dmi_sb_err;
wire                          dmp_x1_iccm_target;
wire                          dmp_x1_iccm_hole;
wire [`ADDR_RANGE]            iccm_physical_limit;
reg                           dmp_x1_iccm;
reg                           dmp_x1_dccm;
reg                           dmp_x1_per;
reg                           dmp_x1_mmio;
reg                           dmp_x1_nvm;
reg                           dmp_x1_sfty_mmio;
reg [`DMP_TARGET_RANGE]       dmp_x1_target;
reg [`DMP_TARGET_RANGE]       pma_x1_target;
reg                           pma_x1_iccm;
reg                           pma_x1_dccm;
reg                           dmp_x1_load;
reg                           dmp_x1_store;
reg                           dmp_x1_partial_store;
reg                           dmp_x1_mem_read;
reg                           dmp_x1_byte;
reg                           dmp_x1_half;
reg                           dmp_x1_word;
reg                           dmp_x1_sex;
reg                           dmp_x1_amo;
reg [`DMP_CTL_AMO_RANGE]      dmp_x1_amo_ctl;
reg                           dmp_x1_lr;
reg                           dmp_x1_sc;
wire                          dmp_x1_amo_stall;
wire                          dccm_amo_in_progress;
wire                          dmp_x1_mem_read_qual;

reg                           dmp_x1_dccm_req_even;
reg                           dmp_x1_dccm_req_odd;
reg [`ADDR_RANGE]             dmp_x1_addr_even;
reg [`ADDR_RANGE]             dmp_x1_addr_odd;
reg                           dmp_x1_dccm_rb_req;
wire [1:0]                    dmp_x1_dccm_ack;

wire                          dmp_x1_ack;


reg [`DMP_CTL_AMO_RANGE]      dmp_x2_amo_ctl_r;
reg                           dmp_x2_sc_lpa_match_r;
reg                           dmp_x2_sc_lpa_match_nxt;

wire                          dmp_x2_sc_go;
wire                          dmp_x2_sc_rb_req;
wire                          dmp_x2_amo_or_sc;
reg [`DATA_RANGE]             dmp_x2_amo_mem_data_nxt;
reg [`DATA_RANGE]             dmp_x2_amo_mem_data_r;
wire [`DATA_RANGE]            dmp_x2_amo_result;
reg                           dmp_x2_amo_result_valid_nxt;
reg                           dmp_x2_amo_result_valid_r;
reg                           dmp_x2_amo_result_valid_cg0;
reg                           dmp_x2_dccm_even_freeze_r;
reg                           dmp_x2_dccm_odd_freeze_r;
wire [`ADDR_RANGE]            dmp_x1_addr1;
reg                           dmp_x1_bank_cross;
wire [`DATA_RANGE]            dmp_x2_st_data1;
wire [3:0]                    dmp_x2_st_mask1;
wire                          dmp_x2_ack;
reg                           dmp_x2_dccm_req_even;
reg                           dmp_x2_dccm_req_odd;
reg [`ADDR_RANGE]             dmp_x2_addr_even;
reg [`ADDR_RANGE]             dmp_x2_addr_odd;
wire [1:0]                    dmp_x2_dccm_ack;

reg                           dmp_x2_sex_r;
reg                           dmp_x2_byte_r;
reg                           dmp_x2_mva_r;
reg                           dmp_x2_mva_stall_cg0;
reg                           dmp_x2_mva_stall_nxt;
reg                           dmp_x1_mva;

reg [`DATA_RANGE]             dmp_x2_data_nxt;

reg                           dmp_x2_even_r;
reg [2:0]                    dmp_x2_addr_2_to_0_r;

reg [`DATA_RANGE]             dmp_x2_data_even;
reg [`DATA_RANGE]             dmp_x2_data_odd;
reg                           dmp_x2_sex;
reg [1:0]                     dmp_x2_size;
reg                           dmp_st_data_trig_trap_r;
reg                           dmp_ld_data_trig_trap_r;
reg [2:0]                    dmp_x2_addr_2_to_0;
reg                           dmp_x2_even;
reg [4:0]                     dmp_x2_dst_id;
reg                           dmp_x2_retire_req;
reg                           dmp_lsq_rb_ack;
reg                           dmp_lsq_rb_ack_r;
reg                           dmp_lsq_rb_even_r;

reg                           dmp_cwb_write;
reg                           dmp_cwb_target;
reg [`ADDR_RANGE]             dmp_cwb_addr;
reg [`DATA_RANGE]             dmp_cwb_data;
reg [3:0]                     dmp_cwb_mask;
reg                           dmp_cwb_amo;

reg                           x2_pass_prel;

reg                           dmp_x1_rmw;
reg                           dmp_x2_rmw_r;
reg  [`DATA_RANGE]            dmp_x2_rd_data0;
reg  [`DATA_RANGE]            dmp_x2_rd_data1;
reg                           dmp_x2_scrub_sb_err;

wire                          dmp_x2_dccm_ecc_sb_err; 
wire                          dmp_x2_dccm_ecc_db_err;
wire                          dmp_x2_dccm_ecc_err;
wire                          dmp_x2_ecc_replay;
wire                          cwb_ovf;

wire [`DATA_RANGE]            cwb_ecc_data0;
wire [3:0]                    cwb_ecc_data0_mask;
wire [`DATA_RANGE]            cwb_ecc_data1;
wire [3:0]                    cwb_ecc_data1_mask;
wire [`DATA_RANGE]            dmp_x2_data_bank_even;
wire [`DATA_RANGE]            dmp_x2_data_bank_odd;
reg                           dmp_cwb_write1;
reg [`ADDR_RANGE]             dmp_cwb_addr1;
reg [`DATA_RANGE]             dmp_cwb_data1;
reg [3:0]                     dmp_cwb_mask1;
wire [`DATA_RANGE]            dmp_x2_st_data;
wire [3:0]                    dmp_x2_st_mask;
wire                          dmp_x2_store_qual;

wire                          cwb_x2_bypass_even;
wire                          cwb_x2_bypass_odd;
wire                          cwb_x2_bypass_replay;
wire  [`DATA_RANGE]           cwb_x2_bypass_data_even;
wire  [`DATA_RANGE]           cwb_x2_bypass_data_odd;

wire [`DATA_RANGE]            dmp_aln_data_even;
wire [`DATA_RANGE]            dmp_aln_data_odd;

reg                           dmp_lsq_write;
reg [4:0]                     dmp_lsq_reg_id;
reg                           dmp_lsq_read;
reg                           dmp_lsq_store;
reg                           dmp_lsq_sex;
reg                           dmp_lsq_privileged;
reg                           dmp_lsq_buff;
reg [`DMP_TARGET_RANGE]       dmp_lsq_target;
reg [1:0]                     dmp_lsq_size;
reg [`ADDR_RANGE]             dmp_lsq_addr;
reg [`ADDR_RANGE]             dmp_lsq_addr1;
reg [`DATA_RANGE]             dmp_lsq_data;
wire                          lsq_has_amo;
reg                           dmp_lsq_amo;
reg [`DMP_CTL_AMO_RANGE]      dmp_lsq_amo_ctl;
reg                           dmp_lsq_unaligned;
wire [`DATA_RANGE]            dmp_aln_data;

wire                          dmp_x1_cross_target;
reg                           dmp_x2_cross_target_r;
reg                           scrubbing_even_set;
reg                           scrubbing_odd_set;
reg                           scrubbing_even_reset;
reg                           scrubbing_odd_reset;
reg                           scrubbing_even_in_progress_r;
reg                           scrubbing_odd_in_progress_r;
wire [1:0]                    scrubbing_in_progress;
wire                          lsq_rb_req_even;
wire                          lsq_rb_req_odd;
wire [4:0]                    lsq_dst_id;
wire                          lsq_rb_err;
wire [`DATA_RANGE]            lsq_rb_data_even;
wire [`DATA_RANGE]            lsq_rb_data_odd;
wire [2:0]                   lsq_rb_addr_2_to_0;
wire                          lsq_rb_sex;

wire                          lsq_full;
wire                          lsq_bus_err;
wire                          lsq_wr_allowed;
wire                          lsq_st_pending;
wire [1:0]                    priv_level;
wire                          dmp_x2_buff;
wire                          dmp_x2_ld_acc_fault;
wire                          dmp_x2_st_acc_fault;
wire                          dmp_x2_strict_order;
reg [5:0]                     mem_attr;
wire                          mem_attr_viol_ld;
wire                          mem_attr_viol_st;


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Local Address Generation Unit (AGU)
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// spyglass disable_block W164a
// SMD: LHS width is less than RHS in assignment
// SJ:  Wrap-around on overflow is intentional
//
assign dmp_x1_addr = (| db_mem_op_1h)
                   ? db_addr
                   : (x1_src0_data + x1_src2_data);
assign dmp_x1_addr1 = x1_src0_data + x1_src2_data + 3'b100;  // db_addr is always aligned
// spyglass enable_block W164a



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Find out X1 memory target based on the address (DCCM, PER, ICCM)
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

assign iccm_physical_limit[`ICCM0_REGN_ADDR_LSB-1:0] = `ICCM0_REGN_ADDR_LSB'd524287;
assign iccm_physical_limit[`ICCM0_REGN_ADDR_RANGE]   = iccm_base[`ICCM0_REGN_RANGE];
assign dmp_x1_iccm_target                            = (dmp_x1_addr[`ICCM0_REGN_ADDR_RANGE] == iccm_base[`ICCM0_REGN_RANGE])
                                                     & (~csr_iccm_off);
assign dmp_x1_iccm_hole                              = (dmp_x1_addr > iccm_physical_limit);

assign dccm_physical_limit[`DCCM_REGN_ADDR_LSB-1:0]  = `DCCM_REGN_ADDR_LSB'd1048575;
assign dccm_physical_limit[`DCCM_REGN_ADDR_RANGE]    = dccm_base[`DCCM_REGN_RANGE];
assign dmp_x1_dccm_target                            = (dmp_x1_addr[`DCCM_REGN_ADDR_RANGE] == dccm_base[`DCCM_REGN_RANGE])
                                                     & (~csr_dccm_off);
assign dmp_x1_dccm_hole                              = (dmp_x1_addr > dccm_physical_limit);

assign dmp_x1_ccm_hole                               = 1'b0
                                                     | (dmp_x1_iccm_target & dmp_x1_iccm_hole)
                                                     | (dmp_x1_dccm_target & dmp_x1_dccm_hole)
                                                     ;

always @*
begin : dmp_x1_target_PROC

  dmp_x1_iccm = 1'b0
              |  (dmp_x1_iccm_target & (~dmp_x1_iccm_hole))
              ;
  dmp_x1_dccm = 1'b0
              |  (dmp_x1_dccm_target & (~dmp_x1_dccm_hole))
              ;
// Per0 region: PER0_BASE <= PER0 <= PER0_LIMIT
  dmp_x1_per  = 1'b0
              | (  (dmp_x1_addr[`PER_BASE_RANGE] >= csr_per0_base_r)
                 & (dmp_x1_addr[`PER_BASE_RANGE] <= csr_per0_limit )
                )
              ;
  dmp_x1_mmio = 1'b0
              | (dmp_x1_addr[31:20] == core_mmio_base_r)
              ;

  dmp_x1_nvm  = 1'b0
              ;

// spyglass disable_block SM_CLNM
// SMD: Case label will never match
// SJ:  Some configurations don't have few memory targets so can be tied to 0
//      Code more readable, unused labels will be optimized away by synthesizer
// spyglass disable_block SM_CLAC
// SMD: Case label is already covered
// SJ:  Some configurations don't have few memory targets so can be tied to 0
//      Code more readable, unused labels will be optimized away by synthesizer
  case (1'b1)
  dmp_x1_iccm: dmp_x1_target = `DMP_TARGET_ICCM;
  dmp_x1_dccm: dmp_x1_target = `DMP_TARGET_DCCM;
  dmp_x1_per:  dmp_x1_target = `DMP_TARGET_PER;
  dmp_x1_mmio: dmp_x1_target = `DMP_TARGET_MMIO;
  dmp_x1_nvm:  dmp_x1_target = `DMP_TARGET_NVM;
  default:     dmp_x1_target = `DMP_TARGET_MEM;
  endcase
// spyglass enable_block SM_CLAC
// spyglass enable_block SM_CLNM
end


always @*
begin : dmp_x1_PROC
  // Default values
  //
  dmp_x1_load          = x1_dmp_ctl[`DMP_CTL_LB] | x1_dmp_ctl[`DMP_CTL_LBU] | x1_dmp_ctl[`DMP_CTL_LH] | x1_dmp_ctl[`DMP_CTL_LHU] | x1_dmp_ctl[`DMP_CTL_LW];
  dmp_x1_mva           = x1_dmp_ctl[`DMP_CTL_MVA] | x1_dmp_ctl[`DMP_CTL_MVAS];
  dmp_x1_store         = x1_dmp_ctl[`DMP_CTL_SB] | x1_dmp_ctl[`DMP_CTL_SH]  | x1_dmp_ctl[`DMP_CTL_SW];
  dmp_x1_partial_store = x1_dmp_ctl[`DMP_CTL_SB] | x1_dmp_ctl[`DMP_CTL_SH];
  dmp_x1_rmw           = dmp_x1_partial_store
                       | (dmp_x1_store & dmp_x1_bank_cross)
                       ;
  
  dmp_x1_mem_read      = dmp_x1_load
                       | dmp_x1_rmw
                       ;

  dmp_x1_byte          = x1_dmp_ctl[`DMP_CTL_LB] | x1_dmp_ctl[`DMP_CTL_LBU] | x1_dmp_ctl[`DMP_CTL_SB];
  dmp_x1_half          = x1_dmp_ctl[`DMP_CTL_LH] | x1_dmp_ctl[`DMP_CTL_LHU] | x1_dmp_ctl[`DMP_CTL_SH];
  dmp_x1_word          = x1_dmp_ctl[`DMP_CTL_LW] |                            x1_dmp_ctl[`DMP_CTL_SW];

  dmp_x1_sex           = x1_dmp_ctl[`DMP_CTL_LB] | x1_dmp_ctl[`DMP_CTL_LH];

  dmp_x1_amo           = x1_dmp_ctl[`DMP_CTL_LW] & x1_dmp_ctl[`DMP_CTL_SW];
  dmp_x1_amo_ctl       = x1_dmp_ctl[`DMP_CTL_AMO_RANGE];
  dmp_x1_lr            = x1_dmp_ctl[`DMP_CTL_LW] & x1_dmp_ctl[`DMP_CTL_LOCK];
  dmp_x1_sc            = x1_dmp_ctl[`DMP_CTL_SW] & x1_dmp_ctl[`DMP_CTL_LOCK];

  if (dmp_x1_addr[2] == 1'b0)
  begin
    dmp_x1_addr_even = dmp_x1_addr;
    dmp_x1_addr_odd  = dmp_x1_addr + 3'b100;
  end
  else
  begin
    dmp_x1_addr_even = dmp_x1_addr + 3'b100;
    dmp_x1_addr_odd  = dmp_x1_addr;
  end
end

always @*
begin: dmp_x1_bank_cross_PROC
  // Byte   -> never crosses
  // Half   -> crosses when [addr[1:0]=(11)]
  // Word   -> crosses when [addr[1:0]=01,10,11]
  //
  case(1'b1)
  dmp_x1_byte: dmp_x1_bank_cross = 1'b0;
  dmp_x1_half: dmp_x1_bank_cross = (&dmp_x1_addr[1:0]);
  dmp_x1_word: dmp_x1_bank_cross = (|dmp_x1_addr[1:0]);
  default:     dmp_x1_bank_cross = 1'b0;
  endcase
end

always @*
begin : dmp_x1_dccm_PROC
  // Default values
  //
  dmp_x1_dccm_req_even = dmp_x1_mem_read & dmp_x1_target_dccm & x1_pass
                       & (dmp_x1_addr[2] == 1'b0
                       | dmp_x1_bank_cross
                         );
  dmp_x1_dccm_req_odd  = dmp_x1_mem_read & dmp_x1_target_dccm & x1_pass
                       & (dmp_x1_addr[2] == 1'b1
                       | dmp_x1_bank_cross
                         );

  dmp_x1_dccm_rb_req   = dmp_x1_load & dmp_x1_pass & dmp_x1_ack
                       & (~dmp_x1_amo)
                       ;
end

// Handy assignments
//
assign dmp_x1_pass          = x1_pass & (| x1_dmp_ctl);
assign dmp_x1_dst_id_valid  = (((|x1_dst_id) | db_mem_op_1h[0]) & dmp_x1_load)
                            | dmp_x1_amo  // AMO inst needs DCCM output for AMO computation irrespective of dest reg
                            ;
assign dmp_x1_ack           = 1'b0
                            | (   (dmp_x1_dccm_ack == {dmp_x1_dccm_req_odd, dmp_x1_dccm_req_even})
                                & (dmp_x1_dccm_req_odd | dmp_x1_dccm_req_even))
                              ;
assign dccm_amo_in_progress = (dmp_x2_amo_r & dmp_x2_valid_r) 
                            | cwb_has_amo;
assign dmp_x1_amo_stall = ((dmp_x1_amo   || dmp_x1_lr   || dmp_x1_sc)   && (dmp_x2_valid_r 
                                                                                        || !cwb_empty 
                                                                                        || !lsq_empty))
                       || ((    ((dmp_x2_amo_r || dmp_x2_lr_r || dmp_x2_sc_r) &&  dmp_x2_valid_r)
                            ||   cwb_has_amo  // cwb_has_amo also signals an active SC
                            ||   lsq_has_amo  // lsq_has_amo also signals an active LR/SC
                           ) && x1_valid_r); 


assign dmp_x1_mem_read_qual = dmp_x1_dst_id_valid
                            | dmp_x1_rmw
                             ;           
assign dmp_x1_target_dccm   = (dmp_x1_target == `DMP_TARGET_DCCM);

assign dmp_x2_valid         = dmp_x2_valid_r & x2_valid_r;
assign dmp_x2_no_mva        = dmp_x2_no_mva_r & x2_valid_r;
assign dmp_x2_pass          = dmp_x2_valid   & x2_pass;
assign dmp_x2_dst_id_valid  = dmp_x2_valid   & (| dmp_x2_dst_id_r) & (dmp_x2_load_r
                            | dmp_x2_mva_r
                            | dmp_x2_sc_r
                            );
assign dmp_x2_target_dccm   = (dmp_x2_target_r == `DMP_TARGET_DCCM);
assign dmp_x2_target_per    = (dmp_x2_target_r == `DMP_TARGET_PER);
assign dmp_x2_target_nvm    = (dmp_x2_target_r == `DMP_TARGET_NVM);
assign dmp_x2_ack           = 1'b0
                            | (   (dmp_x2_dccm_ack == {dmp_x2_dccm_req_odd, dmp_x2_dccm_req_even})
                                & (dmp_x2_dccm_req_odd | dmp_x2_dccm_req_even))
                            ;
assign dmp_x2_amo_or_sc     = dmp_x2_amo_r | dmp_x2_sc_r;
assign priv_level = (mstatus_r[`MPRV] & (!debug_mode | mprven_r)) ? mstatus_r[`MPP_RANGE] : (debug_mode ? `PRIV_M : priv_level_r);

assign dmp_x2_buff = ((mem_attr[3:0] == 4'b0010) | (mem_attr[3:0] == 4'b0100))
                   & (~dmp_x2_amo_or_sc)
                   ;

assign dmp_x2_store_qual = dmp_x2_store_r
                         & (!dmp_x2_sc_r | dmp_x2_sc_go) // store that is not an SC or that matches the lock-flag address. 
                         ;
                       
// X2
//
always @*
begin : dmp_x2_PROC
  // Clock-gate
  //
  dmp_x2_ctl_cg0    = x2_enable; // dmp_x1_pass | dmp_x2_valid_r;
  dmp_x2_data_cg0   = dmp_x1_pass;

  dmp_x2_valid_nxt  = dmp_x1_pass;
  dmp_x2_no_mva_nxt = x1_pass & (| x1_dmp_ctl) 
                    & (~dmp_x1_mva)
                    ;
  dmp_x2_dst_id_nxt = x1_dst_id & (   {5{(dmp_x1_load)}}
                                   | {5{dmp_x1_mva}}
                                   |  {5{(dmp_x1_sc)}}
                                  );

  dmp_x2_grad_nxt   = (  dmp_x1_load
                       | dmp_x1_sc
                      )
                    & (  (dmp_x1_target == `DMP_TARGET_ICCM)
                       | (dmp_x1_target == `DMP_TARGET_MEM)
                       | (dmp_x1_target == `DMP_TARGET_PER)
                       | (dmp_x1_target == `DMP_TARGET_MMIO)
                       | (dmp_x1_target == `DMP_TARGET_NVM)
                      );
end

always @*
begin : dmp_x2_dccm_PROC
  // Requesting DCCM in case we get stalled in X2
  //
  dmp_x2_dccm_req_even = dmp_x2_target_dccm & dmp_x2_hazard_stall_r
                       & (dmp_x2_even_r == 1'b1
                       | dmp_x2_bank_cross_r
                       );
  dmp_x2_dccm_req_odd  = dmp_x2_target_dccm & dmp_x2_hazard_stall_r
                       & (dmp_x2_even_r == 1'b0
                       | dmp_x2_bank_cross_r
                       );

  if (dmp_x2_even_r)
  begin
    dmp_x2_addr_even = dmp_x2_addr_r;
    dmp_x2_addr_odd  = dmp_x2_addr_r + 3'b100;
  end
  else
  begin
    dmp_x2_addr_even = dmp_x2_addr_r + 3'b100;
    dmp_x2_addr_odd  = dmp_x2_addr_r;
  end
end

always @*
begin : dmp_rb_PROC
  // Clock-gate
  //
  dmp_x2_rb_req_cg0 = dmp_x1_load
                    | lsq_rb_req_even
                    | lsq_rb_req_odd
                    | dmp_x2_rb_req_r
                    | dmp_x1_mva
                    | (dmp_x2_mva_r & dmp_x2_mva_stall_r)
                    | dmp_x1_sc
                    | (dmp_x2_load_r & dmp_x2_hazard_stall_r)
                    | x3_flush_r
                    ;


  // Request the result bus when a dmp instruction is in X2 - Hold the request until we get the ack
  //
  dmp_x2_rb_req_nxt = lsq_rb_req_even
                    | lsq_rb_req_odd
                    | dmp_x1_dccm_rb_req
                    | (dmp_x1_mva & dmp_x1_pass)
                    | (dmp_x2_mva_r & dmp_x2_mva_stall_r & (~x3_flush_r))
                    | ((dmp_x1_sc & dmp_x1_pass & dmp_x1_target_dccm))
                    | ((   dmp_x2_load_r & dmp_x2_ack & dmp_x2_hazard_stall_r
                         & (~dmp_x2_amo_r)
                       ) & (~x3_flush_r))
                    | ((dmp_x2_rb_req_r & (~x2_dmp_rb_ack)) & (~x3_flush_r));
end

always @*
begin : dmp_x2_haz_PROC
  // We have a structural hazard
  // (1) when a post-commit load from the LSQ and an in-order DCCM load
  //     attempt to retire at the same cycle. The retirement from the LSQ would take precedence over
  //     the retirement from X2. Hence stall the in-order DCCM load at X2.
  // (2) when a DCCM load in x1 with valid destination register or a stalled DCCM load in x2 doesn't get acknowledgement due to other high priority DCCM requests
  // (3) When a partial store stalls in X2 due to CWB_FULL. The CWB gets the priority and the bank read data of the partial store is corrupted hence stall
  //     the partial store in X2 and re-request the DCCM. 
  //
  
  // @@@ Better to derive these stall conditions separatelty and combined them all in the end, e.g.:
  // dmp_x2_hazard_stall_nxt = cond A
  //                        | cond B
  //                        | ...
  //
  
  dmp_x2_hazard_stall_nxt = (dmp_x1_dccm_rb_req & (lsq_rb_req_even | lsq_rb_req_odd))
                          | (dmp_x2_valid_r & dmp_x2_load_r & dmp_x2_target_dccm & (~x2_pass) & (lsq_rb_req_even | lsq_rb_req_odd))
                          | ((~dmp_x1_ack)  & (dmp_x1_dccm_req_even | dmp_x1_dccm_req_odd) & dmp_x1_mem_read_qual) 
                          | (dmp_x2_valid_r & (~dmp_x2_ack) & (dmp_x2_dccm_req_even | dmp_x2_dccm_req_odd))
                          | (dmp_x2_valid_r & dmp_x2_target_dccm & dmp_x2_rmw_r & dmp_x2_cwb_stall)
                          ;
  dmp_x2_hazard_stall_cg0 = ~(lsq_empty)
                          | dmp_x2_hazard_stall_r
                          | (dmp_x1_mem_read & dmp_x1_target_dccm)
                          | (dmp_x2_target_dccm & dmp_x2_rmw_r)
                          ;
end

always @*
begin : dmp_x2_mva_stall_PROC
  dmp_x2_mva_stall_cg0    =  dmp_x1_mva
                          | dmp_x2_mva_stall_r;

  dmp_x2_mva_stall_nxt    =  (dmp_x1_mva & x1_pass & (lsq_rb_req_even | lsq_rb_req_odd))
                          |  (dmp_x2_valid_r & dmp_x2_mva_r & (~x2_pass) & (lsq_rb_req_even | lsq_rb_req_odd));
end

reg dmp_x2_rb_stall;
reg dmp_x2_lsq_stall;
reg dmp_x2_amo_stall;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Mux-in debug write data
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_x2_data_nxt_PROC
  // When the debugger is inserting a store instruction, the write data comes in
  // through the architectuaral invisible db_data reg
  //
  dmp_x2_data_nxt = db_mem_op_1h[1] ? db_wdata : x1_src1_data;
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// DMP x2 stall
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_x2_stall_PROC
  // Conditions:
  // - result bus not available
  // - LSQ is full
  // - X2 load with
  // - X2 hazard
  //
  dmp_x2_rb_stall  = dmp_x2_rb_req_r & (~x2_dmp_rb_ack);
  dmp_x2_lsq_stall = dmp_x2_valid_r
                   & (!dmp_x2_mva_r)
                   & (  (dmp_x2_target_r == `DMP_TARGET_ICCM)
                      | (dmp_x2_target_r == `DMP_TARGET_MEM)
                      | (dmp_x2_target_r == `DMP_TARGET_PER)
                      | (dmp_x2_target_r == `DMP_TARGET_MMIO)
                      | (dmp_x2_target_r == `DMP_TARGET_NVM))
                   & lsq_full & (~lsq_wr_allowed);

  dmp_x2_amo_stall = dmp_x2_valid_r & dmp_x2_amo_r
                   & dmp_x2_target_dccm & ~dmp_x2_amo_result_valid_r;

  // Summary
  //
  dmp_x2_stall     = dmp_x2_rb_stall
                   | dmp_x2_lsq_stall
                   | dmp_x2_amo_stall
                   | dmp_x2_cwb_stall 
                   | dmp_x2_hazard_stall_r                                   
                   | dmp_x2_mva_stall_r
                   ;
end

/////////////////////////////////////////////////////////////////////////////
//                                                                          //
// CWB Full Stall
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
reg dmp_x1_cwb_wr_one;
reg dmp_x1_cwb_wr_two;

reg dmp_x2_cwb_cg0;
reg dmp_x2_cwb_wr_one_r;
reg dmp_x2_cwb_wr_two_r;

always @*
begin : X1_cwb_write_PROC
  // Pre-compute in X1 the number of CWB entries we will need in X2
  //
  dmp_x1_cwb_wr_one = dmp_x1_store
                    & (dmp_x1_target == `DMP_TARGET_DCCM)
                    & (~dmp_x1_amo)
                    & (~dmp_x1_bank_cross)
                    ;
  dmp_x1_cwb_wr_two = dmp_x1_store
                    & (dmp_x1_target == `DMP_TARGET_DCCM)
                    & dmp_x1_bank_cross
                    ;
  // Clock-gate
  //
  dmp_x2_cwb_cg0 = dmp_x1_pass
                 | ((  dmp_x2_cwb_wr_one_r
                     | dmp_x2_cwb_wr_two_r)
                   & dmp_x2_pass
                   );
end

// Stall X2 stage when:
// - We need two entries and the CWB is full 
//   or the CWB has a single entry and the CWB can't drain one due to DMI hp-req.
// - The CWB is full and we need to commit at least one DCCM write and the CWB can't
//   drain one due to DMI hp-req.
//

assign dmp_x2_cwb_stall = dmp_x2_valid_r
                        & (  1'b0
                           | (dmp_x2_cwb_wr_two_r & (   cwb_full 
                                                     |  (cwb_one_empty & |((dmi_req_early | dmi_arb_freeze) & cwb_req & (~scrubbing_in_progress)))
                                                    ))
                           | (dmp_x2_cwb_wr_one_r & cwb_full & |(cwb_req & (dmi_req_early | dmi_arb_freeze)))
                          );


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// DMP result bus: selection between pre and post-commit LD results
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_arb_PROC
  // Default value
  //

  dmp_x2_data_even    = lsq_rb_data_even;
  dmp_x2_data_odd     = lsq_rb_data_odd;
  dmp_x2_sex          = dmp_x2_sex_r;
  dmp_x2_size         = {dmp_x2_word_r, dmp_x2_half_r};
  dmp_x2_addr_2_to_0  = dmp_x2_addr_2_to_0_r;
  dmp_x2_even         = dmp_x2_even_r;
  dmp_x2_dst_id       = dmp_x2_dst_id_r;
  dmp_x2_retire_req   = 1'b0;

  dmp_rb_post_commit  = 1'b0;
  dmp_rb_retire_err   = 1'b0;

  if (dmp_lsq_rb_ack_r)
  begin

    dmp_x2_data_even    = lsq_rb_data_even;
    dmp_x2_data_odd     = lsq_rb_data_odd;
    dmp_x2_sex          = lsq_rb_sex;
    dmp_x2_size         = lsq_rb_size;
    dmp_x2_addr_2_to_0  = lsq_rb_addr_2_to_0;
    dmp_x2_even         = dmp_lsq_rb_even_r;
    dmp_x2_dst_id       = lsq_dst_id;
    dmp_x2_retire_req   = 1'b1;

    dmp_rb_post_commit = 1'b1;
    dmp_rb_retire_err  = lsq_rb_err;
  end
  else
  begin
    dmp_x2_data_even   = cwb_x2_bypass_even ? cwb_x2_bypass_data_even : dccm_dout_even[`DCCM_DATA_RANGE];
    dmp_x2_data_odd    = cwb_x2_bypass_odd  ? cwb_x2_bypass_data_odd  : dccm_dout_odd[`DCCM_DATA_RANGE];  
    dmp_x2_sex         = dmp_x2_sex_r;
    dmp_x2_size        = {dmp_x2_word_r, dmp_x2_half_r};
    dmp_x2_addr_2_to_0 = dmp_x2_addr_2_to_0_r;
    dmp_x2_even        = dmp_x2_even_r;
    dmp_x2_dst_id      = dmp_x2_dst_id_r;
  end
end


always @*
begin : scrubbing_cg0_PROC
  scrubbing_even_set   = dmp_x2_dccm_ecc_sb_err_even & (~dmp_x2_dccm_ecc_err) & (~dmi_arb_freeze[0]);
  scrubbing_odd_set    = dmp_x2_dccm_ecc_sb_err_odd  & (~dmp_x2_dccm_ecc_err) & (~dmi_arb_freeze[1]);  

  scrubbing_even_reset = scrubbing_even_in_progress_r 
                       & x2_pass;
  scrubbing_odd_reset  = scrubbing_odd_in_progress_r 
                       & x2_pass;
end

assign scrubbing_in_progress = {scrubbing_odd_in_progress_r, scrubbing_even_in_progress_r};
assign dmp_x2_dccm_ecc_sb_err_even = dccm_ecc_sb_error_even & ~cwb_x2_bypass_even;

assign dmp_x2_dccm_ecc_db_err_even = dccm_ecc_db_error_even
                                   | (dccm_ecc_sb_error_even & (dccm_ecc_enable == 2'b10));

assign dmp_x2_dccm_ecc_sb_err_odd  = dccm_ecc_sb_error_odd  & ~cwb_x2_bypass_odd;                                   
assign dmp_x2_dccm_ecc_db_err_odd  = dccm_ecc_db_error_odd
                                   | (dccm_ecc_sb_error_odd &  (dccm_ecc_enable == 2'b10));

assign dmp_x2_dccm_ecc_sb_err      = dmp_x2_dccm_ecc_sb_err_even | dmp_x2_dccm_ecc_sb_err_odd;

assign dmp_x2_dccm_ecc_db_err      = dmp_x2_dccm_ecc_db_err_even | dmp_x2_dccm_ecc_db_err_odd
                                   | dccm_ecc_addr_error_even
                                   | dccm_ecc_addr_error_odd
                                   ;
assign dmp_x2_dccm_ecc_err         = dccm_ecc_db_error_even
                                   | dccm_ecc_db_error_odd
                                   | dccm_ecc_addr_error_even
                                   | dccm_ecc_addr_error_odd
                                   ;
assign dmp_x2_ecc_replay           = (dmp_x2_dccm_ecc_sb_err_even | dmp_x2_dccm_ecc_sb_err_odd)
                                   & (~dmp_x2_dccm_ecc_db_err);
  //@@@ This is based on writing only those banks that need err scrub
assign cwb_ovf                     = (  (  dccm_ecc_sb_error_even 
                                         | dccm_ecc_sb_error_odd
                                        ) 
                                      & cwb_full)
                                   | (dccm_ecc_sb_error_even & dccm_ecc_sb_error_odd & ~cwb_empty)
                                   ;

assign dmp_x2_scrub_sb_err_even    = (  (dmp_x2_dccm_ecc_sb_err_even) // SB err with no st to ld fwd
                                      & (scrubbing_even_in_progress_r | (~dmi_req[0]))
                                     );
assign dmp_x2_scrub_sb_err_odd     = (  (dmp_x2_dccm_ecc_sb_err_odd)  // SB err with no st to ld fwd
                                      & (scrubbing_odd_in_progress_r | (~dmi_req[1]))
                                     );
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Writing into the CWB
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_cwb_write_PROC

  dmp_x2_scrub_sb_err = (dmp_x2_scrub_sb_err_even | dmp_x2_scrub_sb_err_odd)
                      & (~cwb_ovf);    // Space available for scrubbing; 

  x2_pass_prel    = x2_pass
                  | (   dmp_x2_scrub_sb_err
                     & (~dmp_x2_dccm_ecc_err) // No double bit error
                    )
                  ;
  dmp_cwb_write   = ((  (dmp_x2_store_qual & (~db_exception))
                    | (dmp_x2_dccm_ecc_sb_err_even | dmp_x2_dccm_ecc_sb_err_odd)
                    )
                  & x2_pass_prel 
                  & (dmp_x2_target_r == `DMP_TARGET_DCCM)
                  )
                  ;   
  dmp_cwb_target  = 1'b0;
  dmp_cwb_amo     = (dmp_x2_amo_r || dmp_x2_sc_r) && x2_pass;
  dmp_cwb_write1  = (
                      (
                        dmp_x2_store_r
                      & ~(dmp_x2_dccm_ecc_sb_err_even | dmp_x2_dccm_ecc_sb_err_odd)
                     )
                    | (dmp_x2_dccm_ecc_sb_err_even & dmp_x2_dccm_ecc_sb_err_odd)
                    )
                  & x2_pass_prel 
                  & dmp_x2_bank_cross_r
                  & (dmp_x2_target_r == `DMP_TARGET_DCCM);  
end

always @*
begin : dmp_cwb_data_PROC
  if (dmp_x2_dccm_ecc_sb_err_even | dmp_x2_dccm_ecc_sb_err_odd)
  begin
    dmp_cwb_mask = 4'b1111;
    dmp_cwb_mask1 = 4'b1111;
    dmp_cwb_addr1 = dmp_x2_addr_odd;
    dmp_cwb_data1 = dmp_x2_data_bank_odd;
    case ({dccm_ecc_sb_error_even,dccm_ecc_sb_error_odd})
    2'b01:
    begin
      dmp_cwb_addr = dmp_x2_addr_odd;
      dmp_cwb_data = dmp_x2_data_bank_odd;
    end
    2'b10:
    begin
      dmp_cwb_addr = dmp_x2_addr_even;
      dmp_cwb_data = dmp_x2_data_bank_even;
    end
    default:
    begin
      // Error in both the banks
      dmp_cwb_addr = dmp_x2_addr_even;
      dmp_cwb_data = dmp_x2_data_bank_even;
      dmp_cwb_addr1 = dmp_x2_addr_odd;
      dmp_cwb_data1 = dmp_x2_data_bank_odd;
    end
    endcase
  end
  else
  begin
    dmp_cwb_addr  = dmp_x2_addr_r;
    dmp_cwb_data  = dmp_x2_amo_result_valid_r ? dmp_x2_amo_result : cwb_ecc_data0;
    dmp_cwb_mask  = (  dmp_x2_amo_result_valid_r
                    )
                  ?  4'b1111 : cwb_ecc_data0_mask;    
    dmp_cwb_data1 = cwb_ecc_data1; 
    dmp_cwb_mask1 = cwb_ecc_data1_mask;
    dmp_cwb_addr1 = dmp_x2_addr1_r;
  end
end

assign dmp_x2_data_bank_even = cwb_x2_bypass_even ? cwb_x2_bypass_data_even                              
                             : ((dccm_ecc_sb_error_even) ? dccm_dout_even_correct : dccm_dout_even[`DCCM_DATA_RANGE]);
assign dmp_x2_data_bank_odd  = cwb_x2_bypass_odd  ? cwb_x2_bypass_data_odd  
                             : ((dccm_ecc_sb_error_odd) ? dccm_dout_odd_correct : dccm_dout_odd[`DCCM_DATA_RANGE]);

always @*
begin : dmp_x2_rd_data_PROC
  case (dmp_x2_addr_r[2])
  1'b0:
  begin
    dmp_x2_rd_data0 = dmp_x2_data_bank_even;
    dmp_x2_rd_data1 = dmp_x2_data_bank_odd;
  end
  default:
  begin
    dmp_x2_rd_data0 = dmp_x2_data_bank_odd;
    dmp_x2_rd_data1 = dmp_x2_data_bank_even;
  end
  endcase
end

rl_dmp_ecc_store_aligner u_rl_dmp_ecc_store_aligner (
  .addr_r                     (dmp_x2_addr_2_to_0_r[1:0]   ),
  .size_r                     ({dmp_x2_word_r, dmp_x2_half_r} ),
  .wr_data_r                  (dmp_x2_data_r                  ),
  .rd_data1                   (dmp_x2_rd_data1                ),
  .cwb_ecc_data1              (cwb_ecc_data1                  ),
  .cwb_ecc_data1_mask         (cwb_ecc_data1_mask             ),
  .rd_data0                   (dmp_x2_rd_data0                ),
  .cwb_ecc_data0              (cwb_ecc_data0                  ),
  .cwb_ecc_data0_mask         (cwb_ecc_data0_mask             )
);




//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Writing into the LSQ
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : dmp_lsq_write_PROC

  dmp_lsq_write      = dmp_x2_valid_r
                     & x2_pass
                     & (dmp_x2_load_r | dmp_x2_store_qual) 
                     & (~db_exception)                          // Debug LD/ST with exception is a NOP
                     & (  (dmp_x2_target_r == `DMP_TARGET_ICCM)
                        | (dmp_x2_target_r == `DMP_TARGET_MEM)
                        | (dmp_x2_target_r == `DMP_TARGET_PER)
                        | (dmp_x2_target_r == `DMP_TARGET_MMIO)
                        | (dmp_x2_target_r == `DMP_TARGET_NVM));
  dmp_lsq_reg_id     = dmp_x2_dst_id_r;
  dmp_lsq_read       = dmp_x2_load_r;
  dmp_lsq_store      = dmp_x2_store_r;
  dmp_lsq_sex        = dmp_x2_sex_r;
  dmp_lsq_target     = dmp_x2_target_r;
  dmp_lsq_size       = {dmp_x2_word_r, dmp_x2_half_r};
  dmp_lsq_addr       = dmp_x2_addr_r;
  dmp_lsq_data       = dmp_x2_st_data;
  dmp_lsq_amo        = dmp_x2_amo_r;
  dmp_lsq_amo_ctl    = dmp_x2_amo_ctl_r;
  dmp_lsq_addr1      = dmp_x2_addr1_r;
  dmp_lsq_unaligned  = dmp_x2_bank_cross_r;
  dmp_lsq_privileged = priv_level != `PRIV_U;
  dmp_lsq_buff       = dmp_x2_buff;
end

// Increase the CWB priority when:
// - CWB is full and we need to commit one DCCM write 
//   and there is no x2_hazard_stall 
// - We need two entries and the CWB is full or CWB has a single entry
//   and there is no x2_hazard_stall
//
assign cwb_prio    = (  cwb_full & dmp_x2_store_r
                      & (~dmp_x2_hazard_stall_r | (dmp_x2_hazard_stall_r & dmp_x2_cwb_wr_two_r))
                     )
                   | (  cwb_one_empty & dmp_x2_cwb_wr_two_r & dmp_x2_valid_r
                      & ~(dmp_x2_hazard_stall_r)
                     )
                   ;

wire core_arb_even_freeze;
wire core_arb_odd_freeze;
assign core_arb_even_freeze = 1'b0
                            | dmp_x2_dccm_even_freeze_r
                            | scrubbing_even_in_progress_r
                            ;
assign core_arb_odd_freeze = 1'b0
                            | dmp_x2_dccm_odd_freeze_r
                            | scrubbing_odd_in_progress_r
                            ;  
wire dmi_scrub_allowed;
assign dmi_scrub_allowed = ~(dmp_x2_valid_r & dmp_x2_store_r & dmp_x2_target_dccm) & cwb_empty;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// PMP check in DMP
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
wire    mmwp;
wire    mml;
wire    lock;
wire    ld;
wire    st;
wire    res;
reg     pmp_viol_ld;
reg     pmp_viol_st;
assign mmwp = dpmp_perm[5];
assign mml  = dpmp_perm[4];
assign lock = dpmp_perm[3];
assign ld   = dpmp_perm[0];
assign st   = dpmp_perm[1];
assign res  = dpmp_perm[1] & (~dpmp_perm[0]);


always @*
begin : pmp_dmp_PROC
    if (cross_region)   // always fail if cross region
    begin
            pmp_viol_ld = dmp_x2_load_r 
                        & (~dmp_x2_amo_r)
                        ;
            pmp_viol_st = dmp_x2_store_r;
    end
    else
    if (~dpmp_hit) //No match region
        if ((priv_level == `PRIV_M) && (~mmwp))
        begin
            pmp_viol_ld = 1'b0;
            pmp_viol_st = 1'b0;
        end
        else
        begin
            pmp_viol_ld = dmp_x2_load_r 
                        & (~dmp_x2_amo_r)
                        ;
            pmp_viol_st = dmp_x2_store_r;
        end
    else
    begin
        if (~mml) //No MML
        begin
            if (res)
            begin
                pmp_viol_ld = dmp_x2_load_r
                            && (~dmp_x2_amo_r)
                            ;
                pmp_viol_st = dmp_x2_store_r 
                            || (dmp_x2_amo_r)
                            ;
            end
            else if ((~lock) && (priv_level == `PRIV_M))
            begin
                pmp_viol_ld = 1'b0;
                pmp_viol_st = 1'b0;
            end
            else
            begin
                pmp_viol_ld = dmp_x2_load_r && (~ld)
                            && (~dmp_x2_amo_r)
                            ;
                pmp_viol_st = (dmp_x2_store_r && (~st))
                            || (dmp_x2_amo_r && (~ld))
                            ;
            end
        end
        else  //MML
        begin
           if (priv_level == `PRIV_M)
               case (dpmp_perm[3:0]) //LXWR
                   4'b0000,
                   4'b0100,
                   4'b0001,
                   4'b0101,
                   4'b0011,
                   4'b0111,
                   4'b1000,
                   4'b1100,
                   4'b1010:
                    begin
                        pmp_viol_ld = dmp_x2_load_r
                                    & (~dmp_x2_amo_r)
                                    ;                        
                        pmp_viol_st = dmp_x2_store_r;
                    end
                   4'b1110,
                   4'b1001,
                   4'b1101,
                   4'b1111:
                    begin
                        pmp_viol_ld = 1'b0;
                        pmp_viol_st = dmp_x2_store_r;
                    end
                   default:
                    begin
                        pmp_viol_ld = 1'b0;
                        pmp_viol_st = 1'b0;
                    end
               endcase
            else
               case (dpmp_perm[3:0])
                   4'b0000,
                   4'b0100,
                   4'b1000,
                   4'b1100,
                   4'b1010,
                   4'b1110,
                   4'b1001,
                   4'b1101,
                   4'b1011:
                    begin
                        pmp_viol_ld = dmp_x2_load_r
                                    & (~dmp_x2_amo_r)
                                    ;                        
                        pmp_viol_st = dmp_x2_store_r;
                    end
                   4'b0010,
                   4'b0001,
                   4'b0101,
                   4'b1111:
                    begin
                        pmp_viol_ld = 1'b0;
                        pmp_viol_st = dmp_x2_store_r;
                    end
                   default:
                    begin
                        pmp_viol_ld = 1'b0;
                        pmp_viol_st = 1'b0;
                    end
               endcase
        end
    end
end



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// DMP exceptions
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

wire dmp_x1_iccm_hole1;
wire dmp_x1_target1_iccm;
wire dmp_x1_iccm_cross_target;

assign dmp_x1_iccm_hole1   = (dmp_x1_addr1 > iccm_physical_limit);
assign dmp_x1_target1_iccm = (dmp_x1_addr1[`ICCM0_REGN_ADDR_RANGE] == iccm_base[`ICCM0_REGN_RANGE])
                           & (~dmp_x1_iccm_hole1) & (~csr_iccm_off);

assign dmp_x1_iccm_cross_target = ((dmp_x1_target == `DMP_TARGET_ICCM) ^ dmp_x1_target1_iccm) & dmp_x1_bank_cross;

wire dmp_x1_dccm_hole1;
wire dmp_x1_target1_dccm;
wire dmp_x1_dccm_cross_target;

assign dmp_x1_dccm_hole1   = (dmp_x1_addr1 > dccm_physical_limit);
assign dmp_x1_target1_dccm = (dmp_x1_addr1[`DCCM_REGN_ADDR_RANGE] == dccm_base[`DCCM_REGN_RANGE])
                           & (~dmp_x1_dccm_hole1) & (~csr_dccm_off)
                           & (~dmp_x1_target1_iccm)
                           ;

assign dmp_x1_dccm_cross_target = (dmp_x1_target_dccm ^ dmp_x1_target1_dccm) & dmp_x1_bank_cross; 

wire dmp_x1_target1_per;
wire dmp_x1_per_cross_target;

assign dmp_x1_target1_per  = (  (dmp_x1_addr1[`PER_BASE_RANGE] >= csr_per0_base_r)
                              & (dmp_x1_addr1[`PER_BASE_RANGE] <= csr_per0_limit )
                             )
                           & (~dmp_x1_target1_iccm)
                           & (~dmp_x1_target1_dccm)
                           ;
assign dmp_x1_per_cross_target = ((dmp_x1_target == `DMP_TARGET_PER ) ^ dmp_x1_target1_per) & dmp_x1_bank_cross;

wire dmp_x1_target1_mmio;
wire dmp_x1_mmio_cross_target;

assign dmp_x1_target1_mmio = 
                           (dmp_x1_addr1[31:20] == core_mmio_base_r)
                           & (~dmp_x1_target1_iccm)
                           & (~dmp_x1_target1_dccm)
                           & (~dmp_x1_target1_per)
                           ;

assign dmp_x1_mmio_cross_target = ((dmp_x1_target == `DMP_TARGET_MMIO) ^ dmp_x1_target1_mmio) & dmp_x1_bank_cross;


assign dmp_x1_cross_target = 1'b0
                           | dmp_x1_dccm_cross_target
                           | dmp_x1_iccm_cross_target
                           | dmp_x1_per_cross_target
                           | dmp_x1_mmio_cross_target
                           ;


always @*
begin : mem_attr_PROC
  mem_attr  = dpma_attr;
end

assign mem_attr_viol_ld = (  (mem_attr[3:0] == 4'b1111) & dmp_x2_load_r
                           & (~dmp_x2_amo_r)
                          )
                        | (~mem_attr[4] & dmp_x2_valid_r & dmp_x2_lr_r)
                        ;

assign mem_attr_viol_st = ((mem_attr[3:0] == 4'b1111) & dmp_x2_store_r)
                        | (~mem_attr[4] & dmp_x2_valid_r & dmp_x2_sc_r)
                        | (~mem_attr[5] & dmp_x2_valid_r & dmp_x2_amo_r)
                        ;

assign dmp_x2_strict_order = mem_attr[3:0] == 4'b0001;


assign dmp_x2_ld_acc_fault = mem_attr_viol_ld
                           | pmp_viol_ld
                           ;

assign dmp_x2_st_acc_fault = mem_attr_viol_st
                           | pmp_viol_st
                           | (  dmp_x2_valid_r & dmp_x2_amo_r           // Fault specific to AHB5/APB interface
                              & (  1'b0
                                 | (dmp_x2_target_r == `DMP_TARGET_MEM)
                                 | (dmp_x2_target_per)
                                )                                          
                             )
                           ;

reg dmp_x2_addr_misaligned;
reg dmp_x2_mmio_misaligned;
always @*
begin : dmp_excp_PROC
  // Advertise DMP exception
  //
  dmp_exception_sync = {`DMP_EXCP_WIDTH{1'b0}};
  dmp_exception_async = 2'b0;

  // Address misalignment (in case the core does not support unaligned LD/ST)
  //
  dmp_x2_addr_misaligned                 = (dmp_x2_half_r & dmp_x2_addr_2_to_0_r[0])
                                         | (dmp_x2_word_r & (dmp_x2_addr_2_to_0_r[1:0] != 2'b00));

  // Only aligned accesses to MMIO are supported
  dmp_x2_mmio_misaligned                 = dmp_x2_addr_misaligned
                                         & (dmp_x2_target_r == `DMP_TARGET_MMIO);

  dmp_exception_sync[`DMP_EXCP_LD_MISALIGNED] = dmp_x2_valid_r
                                         & (  1'b0
                                            | (dmp_x2_addr_misaligned & dmp_x2_lr_r)
                                            | (  dmp_x2_load_r
                                               & (~dmp_x2_amo_r)
                                               & (  1'b0
                                                  | dmp_x2_mmio_misaligned
                                                 ))
                                           );

  dmp_exception_sync[`DMP_EXCP_ST_MISALIGNED] = dmp_x2_valid_r
                                         & (  1'b0
                                            | ( dmp_x2_addr_misaligned & (dmp_x2_amo_r | dmp_x2_sc_r))
                                            | (  dmp_x2_store_r
                                               & (  1'b0
                                                  | dmp_x2_mmio_misaligned
                                                 ))    
                                           );

  dmp_exception_sync[`DMP_EXCP_LD_PMP_FAULT]  = dmp_x2_ld_acc_fault;

  dmp_exception_sync[`DMP_EXCP_ST_PMP_FAULT]  = dmp_x2_st_acc_fault;

  dmp_exception_sync[`DMP_EXCP_ECC]           = 1'b0
                                              | dmp_x2_dccm_ecc_db_err
                                              ;
  dmp_exception_sync[`DMP_EXCP_ABREAK]        = 1'b0
                                              | dmp_addr_trig_trap
                                               ;
  dmp_exception_sync[`DMP_EXCP_LD_SP_MULT_MEM] = 1'b0
                                               | (dmp_x2_load_r & dmp_x2_cross_target_r) 
                                               ;
  
  dmp_exception_sync[`DMP_EXCP_ST_SP_MULT_MEM] = 1'b0
                                               | (dmp_x2_store_r & dmp_x2_cross_target_r)
                                               ;

  dmp_exception_sync[`DMP_EXCP_ST_ACC_FAULT]   = 1'b0
                                               ;

  dmp_exception_async[`DMP_EXCP_BREAK]         = 1'b0
                                               | dmp_ld_data_trig_trap_r
                                               | dmp_st_data_trig_trap_r
                                               ;
  
  dmp_exception_async[`DMP_EXCP_BUS]           = lsq_bus_err;
end

assign dmp_x2_clear_lf  = dmp_x2_pass && (   (   dmp_x2_lpa_match && dmp_x2_store_r 
                                              && (~dmp_x2_sc_r)
                                             )
                                          || (dmp_x2_sc_r && x3_lock_flag_r[0])                                       
                                         );
assign dmp_x2_lpa_match =  (|x3_lock_flag_r) 
                        && (   (dmp_x2_addr_r[31:3] == x3_lpa_r[31:3])
                            || ((dmp_x2_addr1_r[31:3] == x3_lpa_r[31:3]) && dmp_x2_bank_cross_r)
                           );  
assign dmp_x2_set_lf    =  dmp_x2_pass &&  dmp_x2_lr_r
                        && (   x3_lock_flag_r == 2'b00                  // No valid reservation
                            || x3_lock_flag_r == 2'b01                  // Reservation set by the core
                            || x3_lock_counter_r == `DMP_TTL_WIDTH'd0); // Reservation set by DMI and timed out

assign dmp_x2_sc_go     = x3_lock_flag_r[0] & dmp_x2_sc_lpa_match_r; 
assign dmp_x2_sc_rb_req = dmp_x2_sc_r & dmp_x2_valid_r & ~(dmp_x2_sc_go);
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Exclusive reservation
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : excl_lock_nxt_PROC

  // If both core and DMI set the reservation then the core gets the priority
  x3_lpa_cg0       = dmp_x2_set_lf | dmi_set_lf;
  x3_lpa_nxt       = dmp_x2_set_lf ? {dmp_x2_addr_r[31:3], 3'd0} : {x2_dmi_addr_r[31:3], 3'd0};

  lf_clear         =  dmp_x2_clear_lf | dmi_clear_lf | trap_clear_lf;

  x3_lf_cg0        = x3_lpa_cg0 | lf_clear;

  set_lock_counter = 1'b0;
  dmi_id_cg0       = 1'b0;

  // lock_flag_r[0] -- Core, lock_flag_r[1] -- DMI
  //
  if (lf_clear)
  begin
    x3_lock_flag_nxt = 2'b00;
  end
  else
  begin
// spyglass disable_block DisallowCaseZ-ML
// SMD: Disallow casez statements
// SJ:  casez is intentional for priority 
    casez ({dmp_x2_set_lf, dmi_set_lf})
    2'b1?:  
    begin
    x3_lock_flag_nxt = 2'b01;
    set_lock_counter = (~x3_lock_flag_r[0]); // No valid reservation from the core 
    end
    2'b01:
    begin  
    x3_lock_flag_nxt = 2'b10;
    set_lock_counter = ~(x3_lock_flag_r[1] & (x3_lock_dmi_id_r == x2_dmi_id_r)); // No valid reservation from the DMI
    dmi_id_cg0       = 1'b1;
    end
    default:x3_lock_flag_nxt = x3_lock_flag_r;
    endcase
// spyglass enable_block DisallowCaseZ-ML
  end
end

always @*
begin : sc_lpa_match_nxt_PROC
  dmp_x2_sc_lpa_match_nxt = dmp_x1_sc & (dmp_x1_addr[31:3] == x3_lpa_r[31:3]);
end

rl_dmp_dccm u_rl_dmp_dccm (
  .x2_req                      ({dmp_x2_dccm_req_odd, dmp_x2_dccm_req_even}), 
  .x2_addr_even                (dmp_x2_addr_even[`DCCM_ADR_RANGE]),  
  .x2_addr_odd                 (dmp_x2_addr_odd[`DCCM_ADR_RANGE] ),           
  .x2_ack                      (dmp_x2_dccm_ack   ),                          

  .x1_req                      ({dmp_x1_dccm_req_odd, dmp_x1_dccm_req_even}), 
  .x1_addr_even                (dmp_x1_addr_even[`DCCM_ADR_RANGE]),    
  .x1_addr_odd                 (dmp_x1_addr_odd[`DCCM_ADR_RANGE] ),           
  .x1_ack                      (dmp_x1_dccm_ack   ),                          

  .cwb_req                     (cwb_req           ),                          
  .cwb_prio                    (cwb_prio          ),                          
  .cwb_mask                    (cwb_mask          ),                          
  .cwb_data_even               (cwb_data          ),                                                 
  .cwb_addr_even               (cwb_addr          ),   
  .cwb_data_odd                (cwb_data          ),   
  .cwb_addr_odd                (cwb_addr          ),                   
  .cwb_ack                     (cwb_ack           ),                          

  .dmi_hp_req                  (dmi_hp_req             ),
  .dmi_req                     (dmi_req                ),
  .dmi_read                    (dmi_read               ),
  .dmi_excl                    (dmi_excl               ),
  .dmi_id                      (dmi_id                 ), 
  .dmi_addr                    (dmi_addr               ),
  .dmi_ack                     (dmi_ack                ),

  .dmi_set_lf                  (dmi_set_lf             ),
  .dmi_clear_lf                (dmi_clear_lf           ),
  .x2_dmi_addr_r               (x2_dmi_addr_r          ),
  .x2_dmi_id_r                 (x2_dmi_id_r            ),
  .dmi_rmw                     (dmi_rmw                ),
  .dmi_scrub_r                 (dmi_scrub_r            ),

  .dmi_wr_data                 (dmi_wr_data            ),
  .dmi_wr_mask                 (dmi_wr_mask            ),
  .dmi_wr_done                 (dmi_wr_done            ),

  .dmi_rd_data                 (dmi_rd_data            ),
  .dmi_rd_valid                (dmi_rd_valid           ),
  .pipe_lost_to_dmi            (pipe_lost_to_dmi       ),
  .dmi_rd_err                  (dmi_rd_err             ),
  .dmi_sb_err                  (dmi_sb_err             ),
  .dmi_scrub_allowed           (dmi_scrub_allowed      ),
  .dmi_scrub_reset             (dmi_scrub_reset        ),  
  .dmi_arb_freeze              (dmi_arb_freeze         ),

  .core_arb_odd_freeze         (core_arb_odd_freeze    ),
  .core_arb_even_freeze        (core_arb_even_freeze   ),

  .x3_lpa_r                    (x3_lpa_r               ),
  .x3_lock_flag_r              (x3_lock_flag_r         ),
  .x3_lock_dmi_id_r            (x3_lock_dmi_id_r       ),
  .x3_lock_counter_r           (x3_lock_counter_r      ),  

  .clk_dccm_even               (dccm_even_clk     ),
  .dccm_din_even               (dccm_din_even     ),
  .dccm_addr_even              (dccm_addr_even    ),
  .dccm_cs_even                (dccm_cs_even      ),
  .dccm_we_even                (dccm_we_even      ),
  .dccm_wem_even               (dccm_wem_even     ),
  .dccm_dout_even              (dccm_dout_even    ),
  .clk_dccm_odd                (dccm_odd_clk      ),
  .dccm_din_odd                (dccm_din_odd      ),
  .dccm_addr_odd               (dccm_addr_odd     ),
  .dccm_cs_odd                 (dccm_cs_odd       ),
  .dccm_we_odd                 (dccm_we_odd       ),
  .dccm_wem_odd                (dccm_wem_odd      ),
  .dccm_dout_odd               (dccm_dout_odd     ),

  .dccm_ecc_enable             (dccm_ecc_enable   ),
  .csr_dccm_rwecc              (csr_dccm_rwecc    ),
  .dmp_x2_addr_r               (dmp_x2_addr_r     ),
  .dmp_x2_valid_r              (dmp_x2_valid_r    ),
  .dmp_x2_addr1_r              (dmp_x2_addr1_r    ),
  .dmp_x2_bank_cross_r         (dmp_x2_bank_cross_r),
  
  .dccm_ecc_sb_error_even      (dccm_ecc_sb_error_even),
  .dccm_ecc_db_error_even      (dccm_ecc_db_error_even),
  .dccm_ecc_db_err_even_cnt    (dccm_ecc_db_err_even_cnt   ),  
  .dccm_ecc_addr_err_even_cnt  (dccm_ecc_addr_err_even_cnt ),
  .dccm_ecc_address_even       (dccm_ecc_address_even      ),
  .dccm_ecc_syndrome_even      (dccm_ecc_syndrome_even     ),  
  .x2_dmi_sb_error_even        (x2_dmi_sb_error_even       ),
  .dccm_ecc_addr_error_even    (dccm_ecc_addr_error_even),  
  
  .dccm_ecc_sb_error_odd       (dccm_ecc_sb_error_odd ),
  .dccm_ecc_db_error_odd       (dccm_ecc_db_error_odd ),

  .dccm_ecc_db_err_odd_cnt     (dccm_ecc_db_err_odd_cnt    ),
  .dccm_ecc_addr_err_odd_cnt   (dccm_ecc_addr_err_odd_cnt  ),
  .dccm_ecc_address_odd        (dccm_ecc_address_odd       ),
  .dccm_ecc_syndrome_odd       (dccm_ecc_syndrome_odd      ),
  .x2_dmi_sb_error_odd         (x2_dmi_sb_error_odd        ),
  .dccm_ecc_addr_error_odd     (dccm_ecc_addr_error_odd),

  .dccm_ecc_even_out           (dccm_ecc_even_out     ),
  .dccm_dout_even_correct      (dccm_dout_even_correct),
  .dccm_ecc_odd_out            (dccm_ecc_odd_out      ),  
  .dccm_dout_odd_correct       (dccm_dout_odd_correct ),

  .arcv_mecc_diag_ecc          (arcv_mecc_diag_ecc    ),


  .rst_a                       (rst_a             ),     
  .clk                         (clk               )   
);

rl_dmp_dccm_ibp_wrapper u_rl_dmp_dccm_ibp_wrapper (
  .dmi_dccm_cmd_valid       (dmi_dccm_cmd_valid     ),
  .dmi_dccm_prio            (dmi_dccm_prio          ),
  .dmi_dccm_cmd_read        (dmi_dccm_cmd_read      ),
  .dmi_dccm_cmd_addr        (dmi_dccm_cmd_addr      ),
  .dmi_dccm_cmd_excl        (dmi_dccm_cmd_excl      ),
  .dmi_dccm_cmd_id          (dmi_dccm_cmd_id        ),
  .dmi_dccm_cmd_accept      (dmi_dccm_cmd_accept    ),

  .dmi_dccm_wr_valid        (dmi_dccm_wr_valid      ),
  .dmi_dccm_wr_last         (dmi_dccm_wr_last       ),
  .dmi_dccm_wr_mask         (dmi_dccm_wr_mask       ),
  .dmi_dccm_wr_data         (dmi_dccm_wr_data       ),
  .dmi_dccm_wr_accept       (dmi_dccm_wr_accept     ),

  .dmi_dccm_rd_valid        (dmi_dccm_rd_valid      ),
  .dmi_dccm_rd_err          (dmi_dccm_rd_err        ),
  .dmi_dccm_rd_excl_ok      (dmi_dccm_rd_excl_ok    ),
  .dmi_dccm_rd_data         (dmi_dccm_rd_data       ),
  .dmi_dccm_rd_last         (dmi_dccm_rd_last       ),
  .dmi_dccm_rd_accept       (dmi_dccm_rd_accept     ),

  .dmi_dccm_wr_done         (dmi_dccm_wr_done       ),
  .dmi_dccm_wr_excl_okay    (dmi_dccm_wr_excl_okay  ),
  .dmi_dccm_wr_err          (dmi_dccm_wr_err        ),
  .dmi_dccm_wr_resp_accept  (dmi_dccm_wr_resp_accept),

  .x3_lpa_r                 (x3_lpa_r               ),
  .x3_lock_flag_r           (x3_lock_flag_r         ),
  .x3_lock_dmi_id_r         (x3_lock_dmi_id_r       ),

  .x2_dmi_addr_r            (x2_dmi_addr_r          ),
  .x2_dmi_id_r              (x2_dmi_id_r            ),

  .dmi_hp_req               (dmi_hp_req             ),
  .dmi_req                  (dmi_req                ),
  .dmi_req_early            (dmi_req_early          ),
  .dmi_read                 (dmi_read               ),
  .dmi_excl                 (dmi_excl               ),
  .dmi_id                   (dmi_id                 ),
  .dmi_addr                 (dmi_addr               ),
  .dmi_ack                  (dmi_ack                ),

  .dmi_wr_data              (dmi_wr_data            ),
  .dmi_wr_mask              (dmi_wr_mask            ),
  .dmi_wr_done              (dmi_wr_done            ),

  .dmi_rd_data              (dmi_rd_data            ),
  .dmi_rd_valid             (dmi_rd_valid           ),
  .pipe_lost_to_dmi         (pipe_lost_to_dmi       ),
  .dmi_rd_err               (dmi_rd_err             ),
  .dmi_sb_err               (dmi_sb_err             ),
  .dccm_base                (dccm_base              ),

  .dmi_rmw                  (dmi_rmw                ),
  .dmi_scrub_r              (dmi_scrub_r            ),
  .dmi_scrub_reset          (dmi_scrub_reset        ),
  .clk                      (clk                    ),
  .rst_a                    (rst_a                  )
);

rl_dmp_store_aligner u_rl_dmp_store_aligner (
  .data_in          (dmp_x2_data_r),
  .ctl_byte         (dmp_x2_byte_r),
  .ctl_half         (dmp_x2_half_r),
  .addr_in          (dmp_x2_addr_2_to_0_r[1:0]),
  .data_out         (dmp_x2_st_data)

);

rl_dmp_cwb u_rl_dmp_cwb (
  .clk                       (clk),
  .rst_a                     (rst_a),

  .dmp_cwb_write             (dmp_cwb_write ),
  .dmp_cwb_target            (dmp_cwb_target),
  .dmp_cwb_addr              (dmp_cwb_addr  ),
  .dmp_cwb_amo               (dmp_cwb_amo   ),
  .dmp_cwb_write1            (dmp_cwb_write1 ),
  .dmp_cwb_addr1             (dmp_cwb_addr1  ),

  .dmp_cwb_data1             (dmp_cwb_data1    ),
  .dmp_cwb_mask1             (dmp_cwb_mask1    ),

  .dmp_x2_addr1_r             (dmp_x2_addr1_r),
  .dmp_x2_bank_cross_r        (dmp_x2_bank_cross_r),
  .dmp_cwb_data              (dmp_cwb_data    ),
  .dmp_cwb_mask              (dmp_cwb_mask    ),
 
  .dmp_x2_load_r             (dmp_x2_load_r),
  .dmp_x2_size_r             ({dmp_x2_word_r, dmp_x2_half_r}),
  .dmp_x2_addr_r             (dmp_x2_addr_r),
  .cwb_x2_bypass_even        (cwb_x2_bypass_even),
  .cwb_x2_bypass_odd         (cwb_x2_bypass_odd),
  .cwb_x2_bypass_replay      (cwb_x2_bypass_replay),
  .cwb_x2_bypass_data_even   (cwb_x2_bypass_data_even),
  .cwb_x2_bypass_data_odd    (cwb_x2_bypass_data_odd),

  
  .cwb_req                   (cwb_req     ),
  .cwb_ack                   (cwb_ack     ),
  .cwb_addr                  (cwb_addr    ),
  .cwb_data                  (cwb_data    ),
  .cwb_mask                  (cwb_mask    ),
  .dmp_x2_rmw_r              (dmp_x2_rmw_r), 
  .cwb_has_amo               (cwb_has_amo  ),
  .cwb_full                  (cwb_full     ),
  .cwb_one_empty             (cwb_one_empty),
  .cwb_empty                 (cwb_empty    )

);

rl_dmp_lsq u_rl_dmp_lsq (
  .dmp_lsq_write          (dmp_lsq_write           ),
  .dmp_lsq_reg_id         (dmp_lsq_reg_id          ),
  .dmp_lsq_read           (dmp_lsq_read            ),
  .dmp_lsq_store          (dmp_lsq_store           ),  
  .dmp_x2_strict_order    (dmp_x2_strict_order     ),
  .dmp_lsq_sex            (dmp_lsq_sex             ),
  .dmp_lsq_privileged     (dmp_lsq_privileged      ),
  .dmp_lsq_buff           (dmp_lsq_buff            ),
  .dmp_lsq_target         (dmp_lsq_target          ),
  .dmp_lsq_size           (dmp_lsq_size            ),
  .dmp_lsq_addr           (dmp_lsq_addr            ), 
  .dmp_lsq_data           (dmp_lsq_data            ),
  .dmp_lsq_amo            (dmp_lsq_amo             ),
  .dmp_lsq_amo_ctl        (dmp_lsq_amo_ctl         ),
  .dmp_lsq_addr1          (dmp_lsq_addr1           ), 
  .dmp_lsq_unaligned      (dmp_lsq_unaligned       ),
  .lsq0_dst_valid      (dmp_lsq0_dst_valid   ),
  .lsq0_dst_id         (dmp_lsq0_dst_id      ),
  .lsq1_dst_valid      (dmp_lsq1_dst_valid   ),
  .lsq1_dst_id         (dmp_lsq1_dst_id      ),

  .lsq_rb_req_even        (lsq_rb_req_even         ),
  .lsq_rb_req_odd         (lsq_rb_req_odd          ),
  .lsq_dst_id             (lsq_dst_id              ),
  .lsq_rb_err             (lsq_rb_err              ),
  .lsq_rb_data_even       (lsq_rb_data_even        ),
  .lsq_rb_data_odd        (lsq_rb_data_odd         ),
  .lsq_rb_size            (lsq_rb_size             ),
  .lsq_rb_addr_2_to_0  (lsq_rb_addr_2_to_0   ),
  .lsq_rb_sex             (lsq_rb_sex              ),

  .dmp_lsq_rb_ack         (1'b1), // @@@

  .lsq_mem_cmd_valid      (lsq_mem_cmd_valid       ),
  .lsq_mem_cmd_cache      (lsq_mem_cmd_cache       ),
  .lsq_mem_cmd_burst_size (lsq_mem_cmd_burst_size  ),
  .lsq_mem_cmd_read       (lsq_mem_cmd_read        ),
  .lsq_mem_cmd_aux        (lsq_mem_cmd_aux         ),
  .lsq_mem_cmd_accept     (lsq_mem_cmd_accept      ),
  .lsq_mem_cmd_addr       (lsq_mem_cmd_addr        ),
  .lsq_mem_cmd_excl       (lsq_mem_cmd_excl        ),
  .lsq_mem_cmd_atomic     (lsq_mem_cmd_atomic      ),
  .lsq_mem_cmd_data_size  (lsq_mem_cmd_data_size   ),
  .lsq_mem_cmd_prot       (lsq_mem_cmd_prot        ),

  .lsq_mem_wr_valid       (lsq_mem_wr_valid        ),
  .lsq_mem_wr_last        (lsq_mem_wr_last         ),
  .lsq_mem_wr_accept      (lsq_mem_wr_accept       ),
  .lsq_mem_wr_mask        (lsq_mem_wr_mask         ),
  .lsq_mem_wr_data        (lsq_mem_wr_data         ),

  .lsq_mem_rd_valid       (lsq_mem_rd_valid        ),
  .lsq_mem_rd_err         (lsq_mem_rd_err          ),
  .lsq_mem_rd_excl_ok     (lsq_mem_rd_excl_ok      ),
  .lsq_mem_rd_last        (lsq_mem_rd_last         ),
  .lsq_mem_rd_accept      (lsq_mem_rd_accept       ),
  .lsq_mem_rd_data        (lsq_mem_rd_data         ),

  .lsq_mem_wr_done        (lsq_mem_wr_done         ),
  .lsq_mem_wr_excl_okay   (lsq_mem_wr_excl_okay    ),
  .lsq_mem_wr_err         (lsq_mem_wr_err          ),
  .lsq_mem_wr_resp_accept (lsq_mem_wr_resp_accept  ),

  .lsq_per_cmd_valid       (lsq_per_cmd_valid      ),
  .lsq_per_cmd_cache       (lsq_per_cmd_cache      ),
  .lsq_per_cmd_burst_size  (lsq_per_cmd_burst_size ),
  .lsq_per_cmd_read        (lsq_per_cmd_read       ),
  .lsq_per_cmd_aux         (lsq_per_cmd_aux        ),
  .lsq_per_cmd_accept      (lsq_per_cmd_accept     ),
  .lsq_per_cmd_addr        (lsq_per_cmd_addr       ),
  .lsq_per_cmd_excl        (lsq_per_cmd_excl       ),
  .lsq_per_cmd_atomic      (lsq_per_cmd_atomic     ),
  .lsq_per_cmd_data_size   (lsq_per_cmd_data_size  ),
  .lsq_per_cmd_prot        (lsq_per_cmd_prot       ),

  .lsq_per_wr_valid        (lsq_per_wr_valid       ),
  .lsq_per_wr_last         (lsq_per_wr_last        ),
  .lsq_per_wr_accept       (lsq_per_wr_accept      ),
  .lsq_per_wr_mask         (lsq_per_wr_mask        ),
  .lsq_per_wr_data         (lsq_per_wr_data        ),

  .lsq_per_rd_valid        (lsq_per_rd_valid       ),
  .lsq_per_rd_err          (lsq_per_rd_err         ),
  .lsq_per_rd_excl_ok      (lsq_per_rd_excl_ok     ),
  .lsq_per_rd_last         (lsq_per_rd_last        ),
  .lsq_per_rd_accept       (lsq_per_rd_accept      ),
  .lsq_per_rd_data         (lsq_per_rd_data        ),

  .lsq_per_wr_done         (lsq_per_wr_done        ),
  .lsq_per_wr_excl_okay    (lsq_per_wr_excl_okay   ),
  .lsq_per_wr_err          (lsq_per_wr_err         ),
  .lsq_per_wr_resp_accept  (lsq_per_wr_resp_accept ),

  .lsq_iccm_cmd_valid      (lsq_iccm_cmd_valid     ),
  .lsq_iccm_cmd_cache      (lsq_iccm_cmd_cache     ),
  .lsq_iccm_cmd_burst_size (lsq_iccm_cmd_burst_size),
  .lsq_iccm_cmd_read       (lsq_iccm_cmd_read      ),
  .lsq_iccm_cmd_aux        (lsq_iccm_cmd_aux       ),
  .lsq_iccm_cmd_accept     (lsq_iccm_cmd_accept    ),
  .lsq_iccm_cmd_addr       (lsq_iccm_cmd_addr      ),
  .lsq_iccm_cmd_excl       (lsq_iccm_cmd_excl      ),
  .lsq_iccm_cmd_atomic     (lsq_iccm_cmd_atomic    ),
  .lsq_iccm_cmd_data_size  (lsq_iccm_cmd_data_size ),
  .lsq_iccm_cmd_prot       (lsq_iccm_cmd_prot      ),

  .lsq_iccm_wr_valid       (lsq_iccm_wr_valid      ),
  .lsq_iccm_wr_last        (lsq_iccm_wr_last       ),
  .lsq_iccm_wr_accept      (lsq_iccm_wr_accept     ),
  .lsq_iccm_wr_mask        (lsq_iccm_wr_mask       ),
  .lsq_iccm_wr_data        (lsq_iccm_wr_data       ),

  .lsq_iccm_rd_valid       (lsq_iccm_rd_valid      ),
  .lsq_iccm_rd_err         (lsq_iccm_rd_err        ),
  .lsq_iccm_rd_excl_ok     (lsq_iccm_rd_excl_ok    ),
  .lsq_iccm_rd_last        (lsq_iccm_rd_last       ),
  .lsq_iccm_rd_accept      (lsq_iccm_rd_accept     ),
  .lsq_iccm_rd_data        (lsq_iccm_rd_data       ),

  .lsq_iccm_wr_done        (lsq_iccm_wr_done       ),
  .lsq_iccm_wr_excl_okay   (lsq_iccm_wr_excl_okay  ),
  .lsq_iccm_wr_err         (lsq_iccm_wr_err        ),
  .lsq_iccm_wr_resp_accept (lsq_iccm_wr_resp_accept),

  .lsq_mmio_cmd_valid      (lsq_mmio_cmd_valid     ),
  .lsq_mmio_cmd_cache      (lsq_mmio_cmd_cache     ),
  .lsq_mmio_cmd_burst_size (lsq_mmio_cmd_burst_size),
  .lsq_mmio_cmd_read       (lsq_mmio_cmd_read      ),
  .lsq_mmio_cmd_aux        (lsq_mmio_cmd_aux       ),
  .lsq_mmio_cmd_accept     (lsq_mmio_cmd_accept    ),
  .lsq_mmio_cmd_addr       (lsq_mmio_cmd_addr      ),
  .lsq_mmio_cmd_excl       (lsq_mmio_cmd_excl      ),
  .lsq_mmio_cmd_atomic     (lsq_mmio_cmd_atomic    ),
  .lsq_mmio_cmd_data_size  (lsq_mmio_cmd_data_size ),
  .lsq_mmio_cmd_prot       (lsq_mmio_cmd_prot      ),

  .lsq_mmio_wr_valid       (lsq_mmio_wr_valid      ),
  .lsq_mmio_wr_last        (lsq_mmio_wr_last       ),
  .lsq_mmio_wr_accept      (lsq_mmio_wr_accept     ),
  .lsq_mmio_wr_mask        (lsq_mmio_wr_mask       ),
  .lsq_mmio_wr_data        (lsq_mmio_wr_data       ),

  .lsq_mmio_rd_valid       (lsq_mmio_rd_valid      ),
  .lsq_mmio_rd_err         (lsq_mmio_rd_err        ),
  .lsq_mmio_rd_excl_ok     (lsq_mmio_rd_excl_ok    ),
  .lsq_mmio_rd_last        (lsq_mmio_rd_last       ),
  .lsq_mmio_rd_accept      (lsq_mmio_rd_accept     ),
  .lsq_mmio_rd_data        (lsq_mmio_rd_data       ),

  .lsq_mmio_wr_done        (lsq_mmio_wr_done       ),
  .lsq_mmio_wr_excl_okay   (lsq_mmio_wr_excl_okay  ),
  .lsq_mmio_wr_err         (lsq_mmio_wr_err        ),
  .lsq_mmio_wr_resp_accept (lsq_mmio_wr_resp_accept),


  .lsq_empty               (lsq_empty              ),
  .lsq_full                (lsq_full               ),
  .lsq_bus_err             (lsq_bus_err            ),
  .lsq_wr_allowed          (lsq_wr_allowed         ),
  .lsq_has_amo             (lsq_has_amo            ),
  .lsq_target_uncached     (dmp_uncached_busy      ),
  .lsq_target_per          (dmp_per_busy           ),
  .lsq_st_pending          (lsq_st_pending         ),

  .clk                     (clk                    ),
  .rst_a                   (rst_a                  )
);
rl_dmp_load_aligner u0_rl_dmp_load_aligner (
  .data_in          (dmp_x2_data_even),
  .data1_in         (dmp_x2_data_odd),
  .size_in          (dmp_x2_size),
  .ctl_sex          (dmp_x2_sex),
  .addr_in          (dmp_x2_addr_2_to_0),

  .data_out         (dmp_aln_data)
);

rl_dmp_csr u_rl_dmp_csr (
  .clk                  (clk              ),
  .rst_a                (rst_a            ),

  .csr_arcv_per0_base_r (csr_per0_base_r  ),
  .csr_arcv_per0_limit  (csr_per0_limit   ),
  .dccm_ecc_enable      (dccm_ecc_enable  ),
  .csr_dccm_rwecc       (csr_dccm_rwecc   ),
  .csr_dccm_base        (dccm_base        ),
  .csr_dccm_off         (csr_dccm_off     ),
  
  .priv_level_r         (priv_level_r     ),

  .csr_sel_ctl          (csr_sel_ctl      ),
  .csr_sel_addr         (csr_sel_addr     ),
  .csr_rdata            (csr_rdata        ),
  .csr_illegal          (csr_illegal      ),
  .csr_unimpl           (csr_unimpl       ),
  .csr_serial_sr        (csr_serial_sr    ),
  .csr_strict_sr        (csr_strict_sr    ),
  .csr_write            (csr_write        ),
  .csr_waddr            (csr_waddr        ),
  .csr_wdata            (csr_wdata        ) 
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// RV_A_OPTION - DCCM Atomics                                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin
  dmp_x2_amo_result_valid_cg0 =  (dmp_x2_amo_r && dmp_x2_target_dccm)
                              ||  x3_flush_r;
  dmp_x2_amo_mem_data_nxt     = dmp_x2_amo_mem_data_r;
  dmp_x2_amo_result_valid_nxt = 1'b0;

  if (dmp_x2_amo_stall & (~dmp_x2_hazard_stall_r))
  begin
    dmp_x2_amo_mem_data_nxt = dmp_x2_even ? dccm_dout_even[`DCCM_DATA_RANGE] : dccm_dout_odd[`DCCM_DATA_RANGE];
    dmp_x2_amo_result_valid_nxt = 1'b1;
  end
end

rl_dmp_amo u_rl_dmp_amo (
  .amo_ctl         (dmp_x2_amo_ctl_r),
  .amo_mem_data    (dmp_x2_amo_mem_data_r),
  .amo_x_data      (dmp_x2_data_r),
  .amo_result      (dmp_x2_amo_result)
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Final data mux
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_x2_data_PROC
  // Deliver the DMP data
  //
  if (dmp_x2_mva_r & dmp_x2_valid_r & (~dmp_x2_mva_stall_r))
    dmp_x2_data = dmp_x2_data_r;
  else
  if (dmp_x2_amo_result_valid_r)
    dmp_x2_data = dmp_x2_amo_mem_data_r;
  else
  if (dmp_x2_sc_r & dmp_x2_valid_r)
    dmp_x2_data = dmp_x2_sc_go ? 'b0 : 'b1;
  else
    dmp_x2_data = dmp_aln_data;
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Replay conditions
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_replay_PROC
  // All replay conditions
  //
  dmp_x2_replay = (  x2_valid_r
                   & cwb_x2_bypass_replay)
                   | dmp_x2_ecc_replay
                ;
end

reg dmp_idle_nxt;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Idle  condition
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_idle_PROC
  // The DMP is idle when all outstanding LD/ST instructions have completed
  //
  dmp_idle_nxt = (~dmp_x2_valid_r) & lsq_empty
                                   & cwb_empty
               & ((x3_lock_flag_r == 2'b00) | (x3_lock_counter_r == `DMP_TTL_WIDTH'd0))
               ;
end

/////////////////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : dmp_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmp_x2_valid_r   <= 1'b0;
    dmp_x2_dst_id_r  <= 5'd0;
    dmp_x2_load_r    <= 1'b0;
    dmp_x2_store_r   <= 1'b0;
    dmp_x2_no_mva_r  <= 1'b0;
    dmp_x2_amo_r     <= 1'b0;
    dmp_x2_lr_r      <= 1'b0;
    dmp_x2_sc_r      <= 1'b0;
    dmp_x2_rmw_r     <= 1'b0;
    
    dmp_x2_rb_req_r  <= 1'b0;
    dmp_x2_grad_r    <= 1'b0;
    dmp_x2_mva_r     <= 1'b0;
  end
  else
  begin

    if (dmp_x2_ctl_cg0 == 1'b1)
    begin
      dmp_x2_valid_r   <= dmp_x2_valid_nxt;
      dmp_x2_no_mva_r  <= dmp_x2_no_mva_nxt;
      dmp_x2_dst_id_r  <= dmp_x2_dst_id_nxt;
      dmp_x2_load_r    <= dmp_x1_load;
      dmp_x2_store_r   <= dmp_x1_store;
      dmp_x2_rmw_r     <= dmp_x1_rmw;
      dmp_x2_grad_r    <= dmp_x2_grad_nxt;
      dmp_x2_mva_r     <= dmp_x1_mva;
      dmp_x2_amo_r     <= dmp_x1_amo;
      dmp_x2_lr_r      <= dmp_x1_lr;
      dmp_x2_sc_r      <= dmp_x1_sc;
    end

    if (dmp_x2_rb_req_cg0 == 1'b1)
    begin
      dmp_x2_rb_req_r <= dmp_x2_rb_req_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : trigger_regs_PROC
  if (rst_a == 1'b1)
  begin
      dmp_st_data_trig_trap_r   <= 1'b0;
      dmp_ld_data_trig_trap_r   <= 1'b0;
  end
  else
  begin
      dmp_st_data_trig_trap_r   <= dmp_x2_pass & dmp_st_data_trig_trap;
      dmp_ld_data_trig_trap_r   <= dmp_ld_data_trig_trap;
  end
end

always @(posedge clk or posedge rst_a)
begin : dmp_x2_data_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmp_x2_sex_r            <= 1'b0;
    dmp_x2_byte_r           <= 1'b0;
    dmp_x2_half_r           <= 1'b0;
    dmp_x2_word_r           <= 1'b0;

    dmp_x2_even_r           <= 1'b0;
    dmp_x2_addr_2_to_0_r <= {2+1{1'b0}};
    dmp_x2_target_r         <= 3'b000;
    dmp_x2_ccm_hole_r       <= 1'b0;
    dmp_x2_data_r           <= {`DATA_SIZE{1'b0}};
    dmp_x2_addr_r           <= {`ADDR_SIZE{1'b0}};
    dmp_x2_amo_ctl_r        <= {`DMP_CTL_AMO_SIZE{1'b0}};
    dmp_x2_sc_lpa_match_r   <= 1'b0;
    dmp_x2_addr1_r          <= {`ADDR_SIZE{1'b0}};
    dmp_x2_bank_cross_r     <= 1'b0;
    dmp_x2_cross_target_r   <= 1'b0;
  end
  else
  begin
    if (dmp_x2_data_cg0 == 1'b1)
    begin
      dmp_x2_sex_r            <= dmp_x1_sex;
      dmp_x2_byte_r           <= dmp_x1_byte;
      dmp_x2_half_r           <= dmp_x1_half;
      dmp_x2_word_r           <= dmp_x1_word;

      dmp_x2_even_r           <= (dmp_x1_addr[2] == 1'b0);
      dmp_x2_addr_2_to_0_r <= dmp_x1_addr[2:0];
      dmp_x2_target_r         <= dmp_x1_target;
      dmp_x2_ccm_hole_r       <= dmp_x1_ccm_hole;
      dmp_x2_data_r           <= dmp_x2_data_nxt;
      dmp_x2_addr_r           <= dmp_x1_addr;
      dmp_x2_amo_ctl_r        <= dmp_x1_amo_ctl;
      dmp_x2_sc_lpa_match_r   <= dmp_x2_sc_lpa_match_nxt;
      dmp_x2_addr1_r          <= dmp_x1_addr1;
      dmp_x2_bank_cross_r     <= dmp_x1_bank_cross;
      dmp_x2_cross_target_r   <= dmp_x1_cross_target;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmp_x2_cwb_status_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmp_x2_cwb_wr_one_r  <= 1'b0;
    dmp_x2_cwb_wr_two_r  <= 1'b0;
  end
  else
  begin
    if (dmp_x2_cwb_cg0 == 1'b1)
    begin
      dmp_x2_cwb_wr_one_r  <= dmp_x1_cwb_wr_one;
      dmp_x2_cwb_wr_two_r  <= dmp_x1_cwb_wr_two;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : scrubbing_even_reg_PROC
  if (rst_a == 1'b1)
  begin
    scrubbing_even_in_progress_r <= 1'b0;
  end
  else
  begin
    if (scrubbing_even_set == 1'b1)
    begin
      scrubbing_even_in_progress_r <= 1'b1;
    end
    else if (scrubbing_even_reset == 1'b1)
    begin
      scrubbing_even_in_progress_r <= 1'b0;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : scrubbing_odd_reg_PROC
  if (rst_a == 1'b1)
  begin
    scrubbing_odd_in_progress_r  <= 1'b0;
  end
  else
  begin
    if (scrubbing_odd_set == 1'b1)
    begin
      scrubbing_odd_in_progress_r <= 1'b1;
    end
    else if (scrubbing_odd_reset == 1'b1)
    begin
      scrubbing_odd_in_progress_r <= 1'b0;
    end
  end
end
always @(posedge clk or posedge rst_a)
begin : dmp_x2_amo_mem_r_PROC
  if (rst_a == 1'b1)
  begin
    dmp_x2_amo_mem_data_r     <= {`DATA_SIZE{1'b0}};
    dmp_x2_amo_result_valid_r <= 1'b0;
  end
  else
  begin
    if (dmp_x2_amo_result_valid_cg0 == 1'b1)
    begin
      dmp_x2_amo_mem_data_r     <= dmp_x2_amo_mem_data_nxt;
      dmp_x2_amo_result_valid_r <= dmp_x2_amo_result_valid_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmp_x2_dccm_evenodd_r_PROC
  if (rst_a == 1'b1)
  begin
    dmp_x2_dccm_even_freeze_r <= 1'b0;
    dmp_x2_dccm_odd_freeze_r  <= 1'b0;
  end
  else
  begin
    if (x1_pass && dmp_x1_amo)
    begin
      dmp_x2_dccm_even_freeze_r <= dmp_x1_dccm_req_even;
      dmp_x2_dccm_odd_freeze_r  <= dmp_x1_dccm_req_odd;
    end
    else if (!dccm_amo_in_progress)
    begin
      dmp_x2_dccm_even_freeze_r <= 1'b0;
      dmp_x2_dccm_odd_freeze_r  <= 1'b0;
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : dmp_lsq_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmp_lsq_rb_ack_r  <= 1'b0;
    dmp_lsq_rb_even_r <= 1'b0;
  end
  else
  begin
    if (lsq_empty == 1'b0)
    begin
      dmp_lsq_rb_ack_r  <= lsq_rb_req_even | lsq_rb_req_odd;
      dmp_lsq_rb_even_r <= lsq_rb_req_even;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmp_x2_haz_reg_PROC
  if (rst_a == 1'b1)
  begin
    dmp_x2_hazard_stall_r  <= 1'b0;
  end
  else
  begin
    if (dmp_x2_hazard_stall_cg0 == 1'b1)
    begin
      dmp_x2_hazard_stall_r  <= dmp_x2_hazard_stall_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin: dmp_x2_mva_stall_reg_PROC
  if (rst_a == 1'b1)
  begin
    dmp_x2_mva_stall_r <= 1'b0;
  end
  else
  begin
    if (dmp_x2_mva_stall_cg0 == 1'b1)
    begin
      dmp_x2_mva_stall_r <= dmp_x2_mva_stall_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmp_idle_reg_PROC
  if (rst_a == 1'b1)
  begin
    dmp_idle_r  <= 1'b0;
  end
  else
  begin
    dmp_idle_r <= dmp_idle_nxt;
  end
end


always @(posedge clk or posedge rst_a)
begin : exclusive_regs_PROC
  if (rst_a == 1'b1)
  begin
    x3_lpa_r          <= {`ADDR_SIZE{1'b0}};
    x3_lock_flag_r    <= 2'b0;
    x3_lock_counter_r <= `DMP_TTL_WIDTH'd0;
    x3_lock_dmi_id_r  <= 4'h0;
  end
  else
  begin
    if (x3_lpa_cg0 == 1'b1)
    begin
      x3_lpa_r <= x3_lpa_nxt;
    end

    if (x3_lf_cg0 == 1'b1)
    begin
      x3_lock_flag_r <= x3_lock_flag_nxt;
    end

    if (set_lock_counter == 1'b1)
    begin
      x3_lock_counter_r <= `DMP_TTL_WIDTH'd`DMP_TTL;
    end
    else
    begin
      if (|x3_lock_counter_r)
      begin
        x3_lock_counter_r <= (x3_lock_counter_r - 1'b1);
      end
    end
    if (dmi_id_cg0 == 1'b1)
    begin
      x3_lock_dmi_id_r <= x2_dmi_id_r;
    end
  end
end
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Output assignments
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

assign dmp_x1_stall         = 1'b0
                           || dmp_x1_amo_stall
                           ;
assign dmp_x2_grad          = dmp_x2_grad_r
                            & (~dmp_x2_sc_r | dmp_x2_sc_go) // SC with an early fail shouldn't graduate 
                            ;

assign dmp_retire_req       = dmp_x2_retire_req;
assign dmp_retire_dst_id    = lsq_dst_id;

assign dmp_rb_req_r         = dmp_x2_rb_req_r 
                            || dmp_x2_amo_result_valid_r
                            || dmp_x2_sc_rb_req
                            ;
assign dmp_rb_dst_id        = dmp_x2_dst_id;

// RAS outputs
// Record SB err only on creating a scrubbing entry in CWB or RB (for DMI)
assign dccm_ecc_sb_err_even_cnt     = (dmp_x2_scrub_sb_err_even & (~cwb_ovf)) 
                                    | (dmi_rd_valid & x2_dmi_sb_error_even)
                                    ;
// Record SB err only on creating a scrubbing entry in CWB or RB (for DMI)
assign dccm_ecc_sb_err_odd_cnt      = (dmp_x2_scrub_sb_err_odd  & (~cwb_ovf))
                                    | (dmi_rd_valid & x2_dmi_sb_error_odd)
                                    ;
assign dccm_ecc_scrub_err           = {(dmp_x2_scrub_sb_err_odd  & (~cwb_ovf)), (dmp_x2_scrub_sb_err_even & (~cwb_ovf))};

assign dccm_ecc_wr    = dmp_x2_load_r & dmp_x2_pass & dmp_x2_target_dccm & csr_dccm_rwecc; 
assign dccm_ecc_excpn = dmp_x2_dccm_ecc_db_err;
assign dccm_ecc_out   = (  (dmp_x2_load_r & (~dmp_x2_addr_r[2]) & csr_dccm_rwecc) 
                         | (  dmp_x2_dccm_ecc_db_err_even 
                            | dccm_ecc_addr_error_even
                           )
                        )
                      ? (dccm_ecc_even_out) : (dccm_ecc_odd_out);


// LD/ST replays triggered by DMP
assign dmp_hpm_dmpreplay = dmp_x2_replay;

// Counts the number of cycles a LD/ST instruction stalls in X2 because of LSQ full
assign dmp_hpm_bdmplsq   = dmp_x2_lsq_stall;

// Counts the number of cycles a LD/ST instruction stalls in X2 because of CWB full
assign dmp_hpm_bdmpcwb   = dmp_x2_cwb_stall & (~dmp_x2_hazard_stall_r);


assign dmp_st_pending    = lsq_st_pending
                         | (~cwb_empty)
                         ;

endmodule // rl_dmp

