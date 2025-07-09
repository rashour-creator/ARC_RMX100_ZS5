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
`include "mpy_defines.v"
`include "alu_defines.v"
`include "csr_defines.v"
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"


`ifndef SYNTHESIS
`ifndef VERILATOR
`define SIMULATION
`endif
`endif

module rl_exu (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                    // clock signal
  input                          clk_gated,              // Gated clock signal
  input                          clk_mpy,

  input                          rst_a,                  // reset signal
`ifdef SIMULATION
  input [`DATA_RANGE]           mip_r,
  input [`DATA_RANGE]           mie_r,
`endif


 ///////// Reset PC ////////////////////////////////////////////////////////////////
 //
 input  [21:0]                  reset_pc_in,           // Input pins  defining RESET_PC[31:10]

  ////////// Resumable NMI //////////////////////////////////////////////////////
  //
  input                          rnmi_synch_r,

  ////////// ASYNC Halt-Run Interface /////////////////////////////////////
  //
  input                          dm2arc_halt_on_reset,
  input                          is_dm_rst,
  input                          gb_sys_run_req_r,
  input                          gb_sys_halt_req_r,
  output                         gb_sys_run_ack_r,
  output                         gb_sys_halt_ack_r,

  ////////// Clock control signals /////////////////////////////////////////////
  //
  output                         db_clock_enable_nxt,
  input                          ar_clock_enable_r,
  output                         mpy_x1_valid,
  output                         mpy_x2_valid,
  output                         mpy_x3_valid_r,
  ////////// Instruction Issue Interface /////////////////////////////////////
  //
  input                          ifu_issue,
  input [`PC_RANGE]              ifu_pc,
  input [2:0]                    ifu_size,
  input [4:0]                    ifu_pd_addr0,
  input [4:0]                    ifu_pd_addr1,
  input [31:0]                   ifu_inst,
  input [1:0]                    ifu_fusion,
  input [`IFU_EXCP_RANGE]        ifu_exception,

  output                         x1_holdup,
  output                         uop_busy,

  output                         spc_x2_clean,
  output                         spc_x2_flush,
  output                         spc_x2_inval,
  output                         spc_x2_zero,
  output                         spc_x2_prefetch,
  output [`DATA_RANGE]           spc_x2_data,
  input                          icmo_done,
  output                         halt_req_asserted,
  output                         kill_ic_op,
  output                         halt_fsm_in_rst,
  ////////// DMP Interface //////////////////////////////////////////////
  //
  output                         x1_pass,               // instruction dispatched to the DMP FU
  output [`DMP_CTL_RANGE]        x1_dmp_ctl,            // Indicates the instructon to be executed in this FU
  output                         x1_valid_r,            // X1 valid instruction from pipe control
  input                          lsq_empty,
  output [`DATA_RANGE]           x1_src0_data,          // source0 operand -- addr base
  output [`DATA_RANGE]           x1_src1_data,          // source1 operand -- store data
  output [`DATA_RANGE]           x1_src2_data,          // source2 operand -- addr offset
  output [4:0]                   x1_dst_id,             // destination register - used for scoreaboarding
  input                          dmp_x1_stall,

  ////////// Debug DMP access /////////////////////////////////////////////////
  //
  output [1:0]                   db_mem_op_1h,           // 0: read, 1: write
  output [`DATA_RANGE]           db_limm,                // Debug mem addr
  output [`DATA_RANGE]           db_data,                // Debug mem write data

  output                         x2_valid_r,
  output                         x2_pass,
  output                         x2_enable,
  input                          dmp_x2_stall,
  input                          dmp_x2_replay,
  input                          dmp_x2_mva_stall_r,
  input [`DATA_RANGE]            dmp_x2_data,
  input [`ADDR_RANGE]            dmp_x2_addr,
  input                          dmp_x2_load,
  input                          dmp_x2_grad,
  input [4:0]                    dmp_x2_dst_id_r,
  input                          dmp_x2_dst_id_valid,
  input                          dmp_x2_retire_req,
  input [4:0]                    dmp_x2_retire_dst_id,
  input                          dmp_rb_req_r,
  input                          dmp_rb_post_commit_r,
  input                          dmp_rb_retire_err_r,
  input [4:0]                    dmp_rb_dst_id,
  output                         rb_dmp_ack,
  input [`DMP_EXCP_RANGE]        dmp_exception_sync,
  input [1:0]                    dmp_exception_async,
  output                         trap_clear_lf,
  input                          dmp_lsq0_dst_valid,
  input [4:0]                    dmp_lsq0_dst_id,
  input                          dmp_lsq1_dst_valid,
  input [4:0]                    dmp_lsq1_dst_id,

  output                         x3_flush_r,

  ////////// Fetch restart Interface /////////////////////////////////////
  //
  output                         fch_restart,             // EXU requests IFU restart
  output                         fch_restart_vec,         //
  output [`PC_RANGE]             fch_target,              //
  output                         fch_stop_r,              // EXU requests IFU halt

  ////////// Branch Interface //////////////////////////////////////////////
  //
  output                         br_req_ifu,              // BR requests change of ctl flow
  output [`PC_RANGE]             br_restart_pc,           // BR target


  ////////// PMP interface /////////////////////////////////////////////
  //
  output [1:0]                   csr_pmp_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_pmp_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]            pmp_csr_rdata,        // (X1) CSR read data
  input                          pmp_csr_illegal,      // (X1) illegal
  input                          pmp_csr_unimpl,       // (X1) Invalid CSR
  input                          pmp_csr_serial_sr,    // (X1) SR group flush pipe
  input                          pmp_csr_strict_sr,    // (X1) SR flush pipe

  output                         csr_pmp_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_pmp_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]           csr_pmp_wdata,        // (X2) Write data

  input [`IFU_ADDR_RANGE]        pmp_viol_addr,

  output [`DATA_RANGE]           mstatus_r,
  output                         debug_mode,
  output                         mprven_r,
  output [5:0]                   mcause_r,
  output [1:0]                   priv_level_r,

  output [1:0]                   csr_trig_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_trig_sel_addr,     // (X1) CSR address

  input  [`DATA_RANGE]           trig_csr_rdata,        // (X1) CSR read data
  input                          trig_csr_illegal,      // (X1) illegal
  input                          trig_csr_unimpl,       // (X1) Invalid CSR
  input                          trig_csr_serial_sr,
  input                          trig_csr_strict_sr,

  output                         csr_trig_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_trig_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]           csr_trig_wdata,        // (X2) Write data
  output                         x1_inst_cg0,
  input                          ifu_inst_break,
  input                          x2_inst_trap,
  input                          x2_inst_break,
  input                          dmp_addr_trig_break,
  input                          dmp_ld_data_trig_break,
  input                          dmp_st_data_trig_break,
  input                          ext_trig_break,
  input                          ext_trig_trap,

  output [`PC_RANGE]             x2_pc,               // x2 pc
  output                         x2_inst_size,        // x2 inst size 1:16bit/0:32bit

  output [`INST_RANGE]           x2_inst,             // x2 inst

  ////////// PMA interface /////////////////////////////////////////////
  //
  output [1:0]                   csr_pma_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_pma_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]            pma_csr_rdata,        // (X1) CSR read data
  input                          pma_csr_illegal,      // (X1) illegal
  input                          pma_csr_unimpl,       // (X1) Invalid CSR
  input                          pma_csr_serial_sr,    // (X1) SR group flush pipe
  input                          pma_csr_strict_sr,    // (X1) SR flush pipe

  output                         csr_pma_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_pma_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]           csr_pma_wdata,        // (X2) Write data


  ////////// HPM interface /////////////////////////////////////////////
  //
  output [1:0]                   csr_hpm_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_hpm_sel_addr,          // (X1) CSR address
  
  input [`DATA_RANGE]            hpm_csr_rdata,             // (X1) CSR read data
  input                          hpm_csr_illegal,           // (X1) illegal
  input                          hpm_csr_unimpl,            // (X1) Invalid CSR
  input                          hpm_csr_serial_sr,         // (X1) SR group flush pipe
  input                          hpm_csr_strict_sr,         // (X1) SR flush pipe
  
  output                         csr_hpm_write,             // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_hpm_waddr,             // (X2) CSR addr
  output [`DATA_RANGE]           csr_hpm_wdata,             // (X2) Write data
  output                         csr_hpm_range,

  output [`CNT_CTRL_RANGE]       mcounteren_r,         // mcounteren CSR
  output [`CNT_CTRL_RANGE]       mcountinhibit_r,      // mcounterinhibit CSR
  output                         instret_ovf,
  output                         cycle_ovf,

  output                         hpm_bissue,
  output                         hpm_bifsync,
  output                         hpm_bdfsync,

  ////////// ICCM interface /////////////////////////////////////////////
  //
  output [1:0]                csr_iccm_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [7:0]                csr_iccm_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]         iccm_csr_rdata,        // (X1) CSR read data
  input                       iccm_csr_illegal,      // (X1) illegal
  input                       iccm_csr_unimpl,       // (X1) Invalid CSR
  input                       iccm_csr_serial_sr,    // (X1) SR group flush pipe
  input                       iccm_csr_strict_sr,    // (X1) SR flush pipe

  output                      csr_iccm_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [7:0]                csr_iccm_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]        csr_iccm_wdata,        // (X2) Write data

  ////////// DMP CSR interface /////////////////////////////////////////////
  //
  output [1:0]                csr_dmp_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [7:0]                csr_dmp_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]         dmp_csr_rdata,        // (X1) CSR read data
  input                       dmp_csr_illegal,      // (X1) illegal
  input                       dmp_csr_unimpl,       // (X1) Invalid CSR
  input                       dmp_csr_serial_sr,    // (X1) SR group flush pipe
  input                       dmp_csr_strict_sr,    // (X1) SR flush pipe

  output                      csr_dmp_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [7:0]                csr_dmp_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]        csr_dmp_wdata,        // (X2) Write data
  input                       dccm_ecc_excpn,
  input                       dccm_ecc_wr,
  input  [`DCCM_ECC_BITS-1:0] dccm_ecc_out,

  ////////// ICCM ECC exception ///////////////////////////////////////////////////////////
  input                       iccm_ecc_excpn,
  input                       iccm_dmp_ecc_err,
  input                       iccm_ecc_wr,
  input  [`ICCM0_ECC_RANGE]   iccm0_ecc_out,

  output [`ARCV_MC_CTL_RANGE]  arcv_mcache_ctl,
  output [`ARCV_MC_OP_RANGE]   arcv_mcache_op,
  output [`ARCV_MC_ADDR_RANGE] arcv_mcache_addr,
  output [`ARCV_MC_LN_RANGE]   arcv_mcache_lines,
  output [`DATA_RANGE]         arcv_mcache_data,
  output                       arcv_icache_op_init,

  input                        arcv_icache_op_done,
  input  [`DATA_RANGE]         arcv_icache_data,
  input                        arcv_icache_op_in_progress,
  input                             ic_tag_ecc_excpn,
  input                             ic_data_ecc_excpn,
  input                             ic_tag_ecc_wr  ,
  input     [`IC_TAG_ECC_RANGE]     ic_tag_ecc_out ,
  input                             ic_data_ecc_wr ,
  input     [`IC_DATA_ECC_RANGE]    ic_data_ecc_out,


  output [7:0]                arcv_mecc_diag_ecc,

  ////////// SAFETY interface /////////////////////////////////////////////
  //
  output [1:0]                   csr_sfty_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_sfty_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]            sfty_csr_rdata,        // (X1) CSR read data
  input                          sfty_csr_illegal,      // (X1) illegal
  input                          sfty_csr_unimpl,       // (X1) Invalid CSR
  input                          sfty_csr_serial_sr,    // (X1) SR group flush pipe
  input                          sfty_csr_strict_sr,    // (X1) SR flush pipe

  output                         csr_sfty_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_sfty_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]           csr_sfty_wdata,        // (X2) Write data
  input                          safety_iso_enb_synch_r,
  output [1:0]                   dr_safety_iso_err,

  ////////// WDT interface /////////////////////////////////////////////
  //
  output [1:0]                   csr_wdt_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_wdt_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]            wdt_csr_rdata,        // (X1) CSR read data
  input                          wdt_csr_illegal,      // (X1) illegal
  input                          wdt_csr_unimpl,       // (X1) Invalid CSR
  input                          wdt_csr_serial_sr,    // (X1) SR group flush pipe
  input                          wdt_csr_strict_sr,    // (X1) SR flush pipe

  output                         csr_wdt_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_wdt_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]           csr_wdt_wdata,        // (X2) Write data
  input                          wdt_csr_raw_hazard,


  output                         db_active,


  input [11:0]                   core_mmio_base_in,
  output [11:0]                  core_mmio_base_r,


  
  ////////// CLINT interface ////////////////////////////////////////////
  //
  output [1:0]                   csr_clint_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_clint_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]            clint_csr_rdata,        // (X1) CSR read data
  input                          clint_csr_illegal,      // (X1) illegal
  input                          clint_csr_unimpl,       // (X1) Invalid CSR
  input                          clint_csr_serial_sr,    // (X1) SR group flush pipe
  input                          clint_csr_strict_sr,    // (X1) SR flush pipe

  output                         csr_clint_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_clint_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]           csr_clint_wdata,        // (X2) Write data
  output                         csr_clint_ren_r,
  input  [7:0]                   mtopi_iid,
  input  [`DATA_RANGE]           mireg_clint,          //
  output                         mireg_clint_wen,
  output                         mtvec_mode,
  output                         trap_ack,

  input  [7:0]                   irq_id,
  input                          irq_trap,              // Inetrrupt in from CLINT

  output [`DATA_RANGE]           miselect_r,           //

  ////////// IBP debug interface //////////////////////////////////////////
  // Command channel
  input  						 dbg_ibp_cmd_valid,  // valid command
  input  						 dbg_ibp_cmd_read,   // read high, write low
  input       [`DBG_ADDR_RANGE]  dbg_ibp_cmd_addr,   //
  output      					 dbg_ibp_cmd_accept, //
  input  			[3:0]  		 dbg_ibp_cmd_space,  // type of access

  // read channel
  output      					 dbg_ibp_rd_valid,   // valid read
  input  						 dbg_ibp_rd_accept,  // rd output accepted by DM
  output      					 dbg_ibp_rd_err,     //
  output      [`DBG_DATA_RANGE]  dbg_ibp_rd_data,    // rd output

  // write channel
  input  						 dbg_ibp_wr_valid,   //
  output      					 dbg_ibp_wr_accept,  //
  input       [`DBG_DATA_RANGE]  dbg_ibp_wr_data,    //
  input       [3:0] 	         dbg_ibp_wr_mask,    //
  output      				     dbg_ibp_wr_done,    //
  output      			         dbg_ibp_wr_err,     //
  input                      dbg_ibp_wr_resp_accept,
  input                          relaxedpriv,
  output                         db_exception,

  //////////  Soft  Reset  Interface  /////////////////////////////////////////
  //
  input                        soft_reset_prepare,

  ///////////// AUX pipeline ctl interface ///////////////////////////////////
  //
  output                       sr_aux_write,               //  (x3) Aux reagion write
  output [`DATA_RANGE]         sr_aux_wdata,             //  (WA) Aux write data

  output                       sr_aux_ren,               //  (X3) Aux region select
  output [11:0]                sr_aux_raddr,             //  (X3) Aux region addr
  output                       sr_aux_wen,               //  (WA) Aux region select
  output [11:0]                sr_aux_waddr,             //  (WA) Aux write addr

  input [`DATA_RANGE]          sr_aux_rdata,               //  (X3) LR read data
  input                        sr_aux_illegal,             //  (X3) SR/LR illegal
  output [`PC_RANGE]           sr_ar_pc_r,
  output [`DATA_RANGE]         sr_mstatus,
  output                       sr_db_active,


  ////////// FENCEI I$ Invalidate interface ///////////////////////////
  //
  output                       spc_fence_i_inv_req,   // Invalidate request to IFU
  input                        spc_fence_i_inv_ack,   // Acknowledgement that Invalidation is complete

  ////////// WID interface ////////////////////////////////////////////
  //
  output [`WID_RANGE]          wid,
  input  [63:0]                wid_rwiddeleg,
  input  [`WID_RANGE]          wid_rlwid, 

  /////////  Idle inputs from Different Modules ///////////////////////////
  input                          biu_idle_r,
  input                          dmp_idle_r,
  input                          ifu_idle_r,

  input   [63:0]                 mtime_r,
  input   [7:0]                  arcnum /* verilator public_flat */,


  ////////  HPM interface  /////////////////////////////////////////////////
  output                         csr_x1_read,
  output                         csr_x1_write,
  output                         csr_x2_pass,
  output                         csr_x2_wen,
  output                         trap_x2_valid,
  output                         take_int,
  output                         debug_mode_r,
  output                         spc_x2_wfi,
  output                         spc_x2_ecall,
  output [`BR_CTL_RANGE]         x1_br_ctl,
  output                         br_x2_taken_r,
  output                         irq_enable,
  output                         x1_stall,
  output                         spc_x2_stall,
  output                         trap_return,
  output                         halt_restart_r,
  output                         x1_raw_hazard,
  output                         x1_waw_hazard,
  output [`CSR_CTL_RANGE]        x1_csr_ctl,

  output                         csr_flush_r,
  output                         alu_x2_stall,
  output                         mpy_x3_stall,
  output                         soft_reset_x2_stall,
  output                         cp_flush, 
  output                         uop_busy_del,

  output                         mpy_busy,
  output                         core_rf_busy,
  output                         exu_busy,


  ////////// Machine Halt / Sleep Status//////////////////////////////////////
  //
  output                         sys_halt_r,
  output                         critical_error,
  output                         sys_sleep_r,
  output  [`EXT_SMODE_RANGE]     sys_sleep_mode_r

);

// Wires
//



wire                     x1_enable;
wire                     db_valid;
wire                     db_request;
wire                     csr_illegal;
wire                     halt_stop_r;
wire                     x2_replay;
wire                     x3_valid_r;
wire                     mdt_r;

wire [4:0]               x1_rd_addr0;
wire [4:0]               x1_rd_addr1;
wire [`DATA_RANGE]       rf_src0_data;
wire [`DATA_RANGE]       rf_src1_data;

wire                     rb_rf_write0;
wire [4:0]               rb_rf_addr0;
wire [`DATA_RANGE]       rb_rf_wdata0;

wire                     rb_rf_write1;
wire [4:0]               rb_rf_addr1;
wire [`DATA_RANGE]       rb_rf_wdata1;

wire                     mstatus_tw;

wire [`DATA_RANGE]       arcv_ujvt_r;
wire [4:0]               x1_dst1_id;
wire                     br_x1_stall;
wire                     br_pc_fake;
wire [`DATA_RANGE]       br_real_base;
wire                     br_real_ready;
wire                     jalt_done;
wire                     x2_uop_valid_r;
wire                     x1_flush;
wire [`ALU_CTL_RANGE]    x1_alu_ctl;
wire [`MPY_CTL_RANGE]    x1_mpy_ctl;
wire [`UOP_CTL_RANGE]    x1_uop_ctl;
wire [`SPC_CTL_RANGE]    x1_spc_ctl;

wire [`PC_RANGE]         x1_pc;
wire [`INST_RANGE]       x1_inst;
wire                     x1_inst_size;
wire [`PC_RANGE]         x1_link_addr;
wire [`BR_CMP_RANGE]     x1_comparison;

wire [`IFU_EXCP_RANGE]   x1_ifu_exception;
wire [`IFU_ADDR_RANGE]   x1_pmp_addr_r;
wire                     illegal_inst;

wire                     x2_flush;
wire                     x2_retain;
wire                     fatal_err;
wire                     fatal_err_dbg;
wire                     shadow_decoder; // for pipemon bypass
wire                     ato_vec_jmp;

wire                     alu_x2_dst_id_valid;
wire [4:0]               alu_x2_dst_id_r;
wire                     csr_raw_hazard;

wire                     vec_mode;
wire [`DATA_RANGE]       sp_u;
wire                     sp_u_recover;
wire [`DATA_RANGE]       mtsp_r;
wire                     rnmi_enable;

wire                     x1_inst_break_r;
wire [2:0]               halt_cond;
wire                     pipe_blocks_trap;
wire                     cp_flush_no_excp_t;

wire                     mpy_x2_dst_id_valid;
wire [4:0]               mpy_x2_dst_id_r;
wire                     mpy_x1_ready;
wire                     mpy_rb_req_r;
wire [`DATA_RANGE]       mpy_x3_data;
wire                     mpy_x3_dst_id_valid;
wire [4:0]               mpy_x3_dst_id_r;
wire                     rb_mpy_ack;

wire                     csr_x2_dst_id_valid;
wire [4:0]               csr_x2_dst_id_r;

wire                     spc_x2_ebreak;
wire                     spc_x2_hbreak;
wire                     irq_wakeup;
wire                     break_excpn;
wire                     break_halt;





wire                     br_x1_taken;
wire  [`PC_RANGE]        br_x1_restart_pc;
wire  [`PC_RANGE]        br_x1_restart_pc_successor;

wire [`PC_RANGE]         br_x2_target_r;

wire                     alu_x2_rb_req_r;
wire [`DATA_RANGE]       alu_x2_data;
wire                     rb_alu_ack;

wire                     dmp_x2_rb_req_r;
wire                     dmp_x2_rb_post_commit_r;

wire                     csr_x2_rb_req_r;
wire [`DATA_RANGE]       csr_x2_data;
wire                     csr_x2_dbg_rd_err;
wire                     rb_csr_ack;



wire                     csr_x2_write_pc;
wire [`DATA_RANGE]       csr_x2_wdata;

wire [`INST_RANGE]       db_inst;
wire                     db_op_read;
wire [`DB_OP_RANGE]      db_op_1h;
wire [4:0]               db_reg_addr;
wire [`PC_RANGE]         ar_pc_r;
wire [`DATA_RANGE]       dpc_r;

wire                     cpu_db_ack;
wire [`DATA_RANGE]       cpu_rdata;
wire                     cpu_rd_err;
wire                     cpu_invalid_inst;
wire                     cpu_ra_r;
wire [`WORD_RANGE]       cpu_aux_status32_r;
wire                     cpu_sys_halt_r;
wire                     cpu_db_done;


// only for pipemon
wire [`DATA_RANGE]       mstatus_nxt;
wire [`DATA_RANGE]       mnstatus_r;
wire [`DATA_RANGE]       mncause_r;
wire                     csr_x2_mret;
wire                     csr_x2_mnret;
//


wire [`PC_RANGE]         csr_trap_base;
wire [`ADDR_RANGE]       csr_trap_epc;
wire                     cp_take_int_exc;
wire [`DATA_RANGE]       cp_cause;

wire                     fencei_restart;
wire                     icmo_restart;
wire                     cp_flush_no_excp;
wire                     uop_commit;
wire                     uop_valid;
wire                     uop_busy_ato;

assign core_rf_busy = (alu_x2_rb_req_r & (~rb_alu_ack))
                    | (mpy_rb_req_r & (~rb_mpy_ack))
                    | (dmp_rb_req_r & (~rb_dmp_ack))
                    | (csr_x2_rb_req_r & (~rb_csr_ack))
                    ;

wire [`DATA_RANGE]       trap_x2_cause;
wire [`DATA_RANGE]       trap_x2_data;


wire                     cycle_delay;

wire                  single_step;
wire                  step_blocks_irq;
wire                  stepie;

wire                  debug_mode_tmp;

wire                  precise_x2_excpn    ; 
wire                  imprecise_x2_excpn  ; 
wire                  iesb_barrier        ; 
wire                  iesb_replay         ; 
wire                  iesb_x2_holdup      ; 
wire                  csr_trap_ret        ;
wire                  iesb_block_int      ;
wire                  iesb_block_excpn    ;


wire [1:0]          arcv_mesb_ctrl;

//////////////////////////////////////////////////////////////////////////////
//
// Module instantiation
//
//////////////////////////////////////////////////////////////////////////////

rl_regfile u_rl_regfile (
  .clk                       (clk_gated),
  .rst_a                     (rst_a),
  .sp_u                      (sp_u      ),
  .sp_u_recover              (sp_u_recover),
  .mtsp_r                    (mtsp_r      ),

  .rf_rd_addr0               (x1_rd_addr0),
  .rf_rd_data0               (rf_src0_data),

  .rf_rd_addr1               (x1_rd_addr1),
  .rf_rd_data1               (rf_src1_data),


  .rf_write0                 (rb_rf_write0),
  .rf_wr_addr0               (rb_rf_addr0),
  .rf_wr_data0               (rb_rf_wdata0),

  .rf_write1                 (rb_rf_write1),
  .rf_wr_addr1               (rb_rf_addr1),
  .rf_wr_data1               (rb_rf_wdata1)
);

rl_dispatch u_rl_dispatch (
  .clk                       (clk_gated          ),
  .rst_a                     (rst_a              ),

  .ifu_issue                 (ifu_issue          ),
  .ifu_pc                    (ifu_pc             ),
  .ifu_size                  (ifu_size           ),
  .ifu_pd_addr0              (ifu_pd_addr0       ),
  .ifu_pd_addr1              (ifu_pd_addr1       ),
  .ifu_inst                  (ifu_inst           ),
  .ifu_fusion                (ifu_fusion         ),
  .ifu_exception             (ifu_exception      ),

  .illegal_inst              (illegal_inst       ),
  .csr_raw_hazard            (csr_raw_hazard     ),
  .mstatus_tw                (mstatus_tw         ),
  .priv_level_r              (priv_level_r       ),
  .ifu_inst_break            (ifu_inst_break     ),
  .x1_inst_break_r           (x1_inst_break_r    ),
  .trap_valid                (trap_x2_valid      ),
  .mtvec_mode                (mtvec_mode         ),
  .rnmi_synch_r              (rnmi_synch_r       ),
  .mdt_r                     (mdt_r              ),
  .x2_pass                   (x2_pass            ),
  .cp_flush                  (cp_flush           ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded output terminal
// SJ: Used for pipemon
  .shadow_decoder            (shadow_decoder     ),
// spyglass enable_block UnloadedOutTerm-ML
  .ato_vec_jmp               (ato_vec_jmp        ),
  .uop_busy                  (uop_busy           ),
  .uop_busy_del              (uop_busy_del       ),
  .uop_busy_ato              (uop_busy_ato       ),
  .uop_commit                (uop_commit         ),
  .uop_valid                 (uop_valid          ),
  .x1_holdup                 (x1_holdup          ),
  .fch_restart               (fch_restart        ),

  .x1_valid_r                (x1_valid_r         ),
  .x1_pass                   (x1_pass            ),
  .x1_inst_cg0               (x1_inst_cg0        ),
  .br_x1_stall               (br_x1_stall        ),
  .br_pc_fake                (br_pc_fake         ),
  .x1_enable                 (x1_enable          ),

  .db_active                 (db_active          ),
  .db_valid                  (db_valid           ),
  .db_inst                   (db_inst            ),
  .db_limm                   (db_limm            ),
  .db_reg_addr               (db_reg_addr        ),

  .x1_rd_addr0               (x1_rd_addr0        ),
  .x1_rd_addr1               (x1_rd_addr1        ),

  .rf_src0_data              (rf_src0_data       ),
  .rf_src1_data              (rf_src1_data       ),

  .x1_fu_alu_ctl             (x1_alu_ctl         ),
  .x1_fu_uop_ctl             (x1_uop_ctl         ),
  .x1_fu_br_ctl              (x1_br_ctl          ),
  .x1_fu_mpy_ctl             (x1_mpy_ctl         ),
  .x1_fu_dmp_ctl             (x1_dmp_ctl         ),
  .x1_fu_csr_ctl             (x1_csr_ctl         ),
  .x1_fu_spc_ctl             (x1_spc_ctl         ),

  .x1_src0_data              (x1_src0_data       ),
  .x1_src1_data              (x1_src1_data       ),
  .x1_src2_data              (x1_src2_data       ),
  .x1_raw_hazard             (x1_raw_hazard      ),
  .x1_waw_hazard             (x1_waw_hazard      ),

  .x1_pc                     (x1_pc              ),
  .x1_link_addr              (x1_link_addr       ),
  .x1_inst                   (x1_inst            ),
  .x1_inst_size              (x1_inst_size       ),

  .x1_dst_id                 (x1_dst_id          ),
  .x1_dst1_id                (x1_dst1_id         ),
  .br_real_base              (br_real_base       ),
  .br_real_ready             (br_real_ready      ),

  .x1_ifu_exception          (x1_ifu_exception   ),
  .x1_pmp_addr_r             (x1_pmp_addr_r      ),
  .pmp_viol_addr             (pmp_viol_addr      ),

  .alu_x2_dst_id_valid       (alu_x2_dst_id_valid),
  .alu_x2_dst_id_r           (alu_x2_dst_id_r    ),
  .alu_x2_data               (alu_x2_data        ),

  .mpy_x1_ready              (mpy_x1_ready       ),
  .mpy_x2_dst_id_valid       (mpy_x2_dst_id_valid),
  .mpy_x2_dst_id_r           (mpy_x2_dst_id_r    ),

  .dmp_x2_dst_id_valid       (dmp_x2_dst_id_valid),
  .dmp_x2_dst_id_r           (dmp_x2_dst_id_r    ),
  .dmp_x2_grad               (dmp_x2_grad        ),
  .dmp_x2_retire_req         (dmp_x2_retire_req  ),
  .dmp_x2_retire_dst_id      (dmp_x2_retire_dst_id),
  .dmp_x2_data               (dmp_x2_data        ),

  .dmp_lsq0_dst_valid     (dmp_lsq0_dst_valid),
  .dmp_lsq0_dst_id        (dmp_lsq0_dst_id   ),
  .dmp_lsq1_dst_valid     (dmp_lsq1_dst_valid),
  .dmp_lsq1_dst_id        (dmp_lsq1_dst_id   ),

  .csr_x2_dst_id_valid       (csr_x2_dst_id_valid),
  .csr_x2_dst_id_r           (csr_x2_dst_id_r    ),
  .csr_x2_data               (csr_x2_data        ),
  .csr_x2_dbg_rd_err         (csr_x2_dbg_rd_err  ),


  .mpy_x3_dst_id_valid       (mpy_x3_dst_id_valid),
  .mpy_x3_dst_id_r           (mpy_x3_dst_id_r    ),
  .mpy_x3_data               (mpy_x3_data        ),



  .cpu_rdata                 (cpu_rdata          ),
  .cpu_rd_err                (cpu_rd_err         ),

  .x1_stall                  (x1_stall           )

);

rl_alu u_rl_alu (
  .x1_pass                    (x1_pass            ),
  .x1_alu_ctl                 (x1_alu_ctl         ),
  .x1_dst1_id                 (x1_dst1_id         ),
  .dmp_x2_mva_stall_r         (dmp_x2_mva_stall_r ),
  .x1_src0_data               (x1_src0_data       ),
  .x1_src1_data               (x1_src1_data       ),
  .x1_src2_data               (x1_link_addr       ),
  .x1_dst_id                  (x1_dst_id          ),
  .alu_x1_comparison          (x1_comparison      ),

  .db_write                   (db_op_1h[`DB_OP_REG_WR]),
  .db_wdata                   (db_data                ),

  .x2_valid_r                 (x2_valid_r         ),
  .x2_pass                    (x2_pass            ),
  .alu_x2_data                (alu_x2_data        ),
  .alu_x2_dst_id_r            (alu_x2_dst_id_r    ),
  .alu_x2_dst_id_valid        (alu_x2_dst_id_valid),
  .alu_x2_rb_req_r            (alu_x2_rb_req_r    ),
  .x2_alu_rb_ack              (rb_alu_ack         ),

  .alu_x2_stall               (alu_x2_stall       ),

  .x3_flush_r                 (x3_flush_r         ),

  .clk                        (clk_gated          ),
  .rst_a                      (rst_a              )

);

rl_branch u_rl_branch (
  .x1_pass                    (x1_pass),
  .x1_inst_cg0                (x1_inst_cg0),
  .br_real_base               (br_real_base),
  .br_real_ready              (br_real_ready),
  .arcv_ujvt_r                (arcv_ujvt_r),
  .br_x1_stall                (br_x1_stall),
  .br_pc_fake                 (br_pc_fake),
  .x2_retain                  (x2_retain),
  .x1_fu_stall                ({x1_stall, dmp_x1_stall}),
  .x1_flush                   (x1_flush),
  .ifu_x1_excp                (x1_ifu_exception),
  .jalt_done                  (jalt_done),
  .x1_br_ctl                  (x1_br_ctl),
  .x1_src0_data               (x1_src0_data),
  .x1_pc                      (x1_pc),
  .x1_offset                  (x1_src2_data),
  .x1_comparison              (x1_comparison),

  .br_x1_taken                (br_x1_taken),
  .br_x1_restart_pc           (br_restart_pc),

  .br_req_ifu                 (br_req_ifu),

  .br_x2_taken                (br_x2_taken_r ),
  .br_x2_target_r             (br_x2_target_r),

  .x2_valid_r                 (x2_valid_r),
  .x2_pass                    (x2_pass),

  .x3_flush_r                 (x3_flush_r),

  .clk                        (clk_gated),
  .rst_a                      (rst_a)
);

rl_mpy u_rl_mpy (
  .x1_pass                    (x1_pass             ),
  .x1_mpy_ctl                 (x1_mpy_ctl          ),
  .x1_src0_data               (x1_src0_data        ),
  .x1_src1_data               (x1_src1_data        ),
  .x1_dst_id                  (x1_dst_id           ),
  .mpy_x1_ready               (mpy_x1_ready        ),

  .x2_valid_r                 (x2_valid_r          ),
  .x2_pass                    (x2_pass             ),
  .x2_flush                   (x2_flush            ),
  .x2_retain                  (x2_retain           ),
  .mpy_x2_dst_id_valid        (mpy_x2_dst_id_valid ),
  .mpy_x2_dst_id_r            (mpy_x2_dst_id_r     ),

  .mpy_x3_data                (mpy_x3_data         ),
  .mpy_x3_dst_id_r            (mpy_x3_dst_id_r     ),
  .mpy_x3_dst_id_valid        (mpy_x3_dst_id_valid ),
  .mpy_x3_rb_req_r            (mpy_rb_req_r        ),
  .x3_mpy_rb_ack              (rb_mpy_ack          ),

  .mpy_x3_stall               (mpy_x3_stall        ),
  .mp3_mpy_busy_r             (mpy_busy            ),


  .clk                        (clk_mpy             ),
  .mpy_x1_valid               (mpy_x1_valid        ),
  .mpy_x2_valid               (mpy_x2_valid        ),
  .mpy_x3_valid_r             (mpy_x3_valid_r      ),
  .rst_a                      (rst_a               )
);

rl_csr u_rl_csr (
  .x1_valid_r                 (x1_valid_r         ),
  .x1_pass                    (x1_pass            ),
  .x1_csr_ctl                 (x1_csr_ctl         ),
  .x1_src0_data               (x1_src0_data       ),
  .x1_src1_data               (x1_src1_data[11:0] ),
  .x1_dst_id                  (x1_dst_id          ),
  .csr_raw_hazard             (csr_raw_hazard     ),

  .csr_illegal                (csr_illegal        ),
  .csr_flush_r                (csr_flush_r        ),

  .db_active                  (db_active          ),
  .db_write                   (db_op_1h[`DB_OP_CSR_WR]),
  .db_wdata                   (db_data            ),
  .dpc_r                      (dpc_r              ),
  .miselect_r                 (miselect_r         ),
  .mireg_clint                (mireg_clint        ),
  .mireg_clint_wen            (mireg_clint_wen    ),
  .break_excpn                (break_excpn        ),
  .break_halt                 (break_halt         ),

  .x2_valid_r                 (x2_valid_r         ),
  .x2_pass                    (x2_pass            ),

  .debug_mode                 (debug_mode         ),
  .debug_mode_r               (debug_mode_r       ),
  .fatal_err_dbg              (fatal_err_dbg      ),
  .csr_x2_data                (csr_x2_data        ),
  .csr_x2_dbg_rd_err          (csr_x2_dbg_rd_err  ),
  .csr_x2_dst_id_r            (csr_x2_dst_id_r    ),
  .csr_x2_dst_id_valid        (csr_x2_dst_id_valid),
  .csr_x2_rb_req_r            (csr_x2_rb_req_r    ),
  .x2_csr_rb_ack              (rb_csr_ack         ),


  .csr_x2_write_pc            (csr_x2_write_pc    ),
  .csr_x2_wdata               (csr_x2_wdata       ),

  .arcv_ujvt_r                (arcv_ujvt_r        ),
  .x2_uop_valid_r             (x2_uop_valid_r     ),

  .csr_pmp_sel_ctl            (csr_pmp_sel_ctl    ),
  .csr_pmp_sel_addr           (csr_pmp_sel_addr   ),

  .pmp_csr_rdata              (pmp_csr_rdata      ),
  .pmp_csr_illegal            (pmp_csr_illegal    ),
  .pmp_csr_unimpl             (pmp_csr_unimpl     ),
  .pmp_csr_serial_sr          (pmp_csr_serial_sr  ),
  .pmp_csr_strict_sr          (pmp_csr_strict_sr  ),

  .csr_pmp_write              (csr_pmp_write      ),
  .csr_pmp_waddr              (csr_pmp_waddr      ),
  .csr_pmp_wdata              (csr_pmp_wdata      ),
  .mprven_r                   (mprven_r           ),
  .mstatus_r                  (mstatus_r          ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded output terminal
// SJ: Used for pipemon
  .mstatus_nxt                (mstatus_nxt        ),
  .mnstatus_r                 (mnstatus_r         ),
  .mncause_r                  (mncause_r          ),
  .csr_x2_mret                (csr_x2_mret        ),
  .csr_x2_mnret               (csr_x2_mnret       ),
// spyglass enable_block UnloadedOutTerm-ML
  .mdt_r                      (mdt_r              ),
  .mcause_o                   (mcause_r           ),
  .sr_aux_rdata               (sr_aux_rdata       ),
  .sr_aux_illegal             (sr_aux_illegal     ),
  .priv_level_r               (priv_level_r       ),

  .csr_trig_sel_ctl         (csr_trig_sel_ctl        ),
  .csr_trig_sel_addr        (csr_trig_sel_addr       ),

  .trig_csr_rdata           (trig_csr_rdata          ),
  .trig_csr_illegal         (trig_csr_illegal        ),
  .trig_csr_unimpl          (trig_csr_unimpl         ),
  .trig_csr_serial_sr       (trig_csr_serial_sr      ),
  .trig_csr_strict_sr       (trig_csr_strict_sr      ),

  .csr_trig_write           (csr_trig_write          ),
  .csr_trig_waddr           (csr_trig_waddr          ),
  .csr_trig_wdata           (csr_trig_wdata          ),
  .halt_cond                (halt_cond               ),

  .csr_pma_sel_ctl            (csr_pma_sel_ctl    ),
  .csr_pma_sel_addr           (csr_pma_sel_addr   ),

  .pma_csr_rdata              (pma_csr_rdata      ),
  .pma_csr_illegal            (pma_csr_illegal    ),
  .pma_csr_unimpl             (pma_csr_unimpl     ),
  .pma_csr_serial_sr          (pma_csr_serial_sr  ),
  .pma_csr_strict_sr          (pma_csr_strict_sr  ),

  .csr_pma_write              (csr_pma_write      ),
  .csr_pma_waddr              (csr_pma_waddr      ),
  .csr_pma_wdata              (csr_pma_wdata      ),

  .csr_hpm_sel_ctl            (csr_hpm_sel_ctl    ),
  .csr_hpm_sel_addr           (csr_hpm_sel_addr   ),

  .hpm_csr_rdata              (hpm_csr_rdata      ),
  .hpm_csr_illegal            (hpm_csr_illegal    ),
  .hpm_csr_unimpl             (hpm_csr_unimpl     ),
  .hpm_csr_serial_sr          (hpm_csr_serial_sr  ),
  .hpm_csr_strict_sr          (hpm_csr_strict_sr  ),

  .csr_hpm_write              (csr_hpm_write      ),
  .csr_hpm_waddr              (csr_hpm_waddr      ),
  .csr_hpm_wdata              (csr_hpm_wdata      ),
  .csr_hpm_range              (csr_hpm_range      ),
  .instret_ovf                (instret_ovf        ),
  .cycle_ovf                  (cycle_ovf          ),

  .csr_iccm_sel_ctl           (csr_iccm_sel_ctl    ),
  .csr_iccm_sel_addr          (csr_iccm_sel_addr   ),

  .iccm_csr_rdata             (iccm_csr_rdata      ),
  .iccm_csr_illegal           (iccm_csr_illegal    ),
  .iccm_csr_unimpl            (iccm_csr_unimpl     ),
  .iccm_csr_serial_sr         (iccm_csr_serial_sr  ),
  .iccm_csr_strict_sr         (iccm_csr_strict_sr  ),

  .csr_iccm_write             (csr_iccm_write      ),
  .csr_iccm_waddr             (csr_iccm_waddr      ),
  .csr_iccm_wdata             (csr_iccm_wdata      ),

  .csr_dmp_sel_ctl            (csr_dmp_sel_ctl    ),
  .csr_dmp_sel_addr           (csr_dmp_sel_addr   ),

  .dmp_csr_rdata              (dmp_csr_rdata      ),
  .dmp_csr_illegal            (dmp_csr_illegal    ),
  .dmp_csr_unimpl             (dmp_csr_unimpl     ),
  .dmp_csr_serial_sr          (dmp_csr_serial_sr  ),
  .dmp_csr_strict_sr          (dmp_csr_strict_sr  ),

  .csr_dmp_write              (csr_dmp_write      ),
  .csr_dmp_waddr              (csr_dmp_waddr      ),
  .csr_dmp_wdata              (csr_dmp_wdata      ),
  .dccm_ecc_excpn             (dccm_ecc_excpn      ),
  .dccm_ecc_wr                (dccm_ecc_wr         ),
  .dccm_ecc_out               (dccm_ecc_out        ),

  .iccm_ecc_excpn             (iccm_ecc_excpn      ),
  .iccm_dmp_ecc_err           (iccm_dmp_ecc_err    ),
  .iccm_ecc_wr                (iccm_ecc_wr         ),
  .iccm0_ecc_out              (iccm0_ecc_out       ),
  .arcv_mcache_ctl            (arcv_mcache_ctl      ),
  .arcv_mcache_op             (arcv_mcache_op       ),
  .arcv_mcache_addr           (arcv_mcache_addr     ),
  .arcv_mcache_lines          (arcv_mcache_lines    ),
  .arcv_mcache_data           (arcv_mcache_data     ),
  .arcv_icache_op_init        (arcv_icache_op_init  ),

  .arcv_icache_op_done        (arcv_icache_op_done  ),
  .arcv_icache_data           (arcv_icache_data),
  .arcv_icache_op_in_progress (arcv_icache_op_in_progress),
  .ic_tag_ecc_excpn           (ic_tag_ecc_excpn     ),
  .ic_data_ecc_excpn          (ic_data_ecc_excpn    ),
  .ic_tag_ecc_wr              (ic_tag_ecc_wr        ),
  .ic_tag_ecc_out             (ic_tag_ecc_out       ),
  .ic_data_ecc_wr             (ic_data_ecc_wr       ),
  .ic_data_ecc_out            (ic_data_ecc_out      ),


  .arcv_mesb_ctrl             (arcv_mesb_ctrl       ),

  .arcv_mecc_diag_ecc         (arcv_mecc_diag_ecc   ),
  .csr_sfty_sel_ctl           (csr_sfty_sel_ctl   ),
  .csr_sfty_sel_addr          (csr_sfty_sel_addr  ),

  .sfty_csr_rdata             (sfty_csr_rdata     ),
  .sfty_csr_illegal           (sfty_csr_illegal   ),
  .sfty_csr_unimpl            (sfty_csr_unimpl    ),
  .sfty_csr_serial_sr         (sfty_csr_serial_sr ),
  .sfty_csr_strict_sr         (sfty_csr_strict_sr ),

  .csr_sfty_write             (csr_sfty_write     ),
  .csr_sfty_waddr             (csr_sfty_waddr     ),
  .csr_sfty_wdata             (csr_sfty_wdata     ),


  .csr_wdt_sel_ctl           (csr_wdt_sel_ctl   ),
  .csr_wdt_sel_addr          (csr_wdt_sel_addr  ),

  .wdt_csr_rdata             (wdt_csr_rdata     ),
  .wdt_csr_illegal           (wdt_csr_illegal   ),
  .wdt_csr_unimpl            (wdt_csr_unimpl    ),
  .wdt_csr_serial_sr         (wdt_csr_serial_sr ),
  .wdt_csr_strict_sr         (wdt_csr_strict_sr ),

  .csr_wdt_write             (csr_wdt_write     ),
  .csr_wdt_waddr             (csr_wdt_waddr     ),
  .csr_wdt_wdata             (csr_wdt_wdata     ),
  .wdt_csr_raw_hazard        (wdt_csr_raw_hazard),

  .mcounteren_r              (mcounteren_r      ),
  .mcountinhibit_r           (mcountinhibit_r   ),

  .core_mmio_base_in         (core_mmio_base_in ),
  .core_mmio_base_r          (core_mmio_base_r  ),
  .cycle_delay               (cycle_delay       ),
  .x3_valid_r                 (x3_valid_r        ),
  .x3_flush_r                 (x3_flush_r        ),

  .ar_pc_r                    ({ar_pc_r, 1'b0}   ),

  .irq_enable                 (irq_enable         ),
  .vec_mode                   (vec_mode           ),

  .csr_clint_sel_ctl          (csr_clint_sel_ctl  ),
  .csr_clint_sel_addr         (csr_clint_sel_addr ),

  .clint_csr_rdata            (clint_csr_rdata    ),
  .clint_csr_illegal          (clint_csr_illegal  ),
  .clint_csr_unimpl           (clint_csr_unimpl   ),
  .clint_csr_serial_sr        (clint_csr_serial_sr),
  .clint_csr_strict_sr        (clint_csr_strict_sr),

  .csr_clint_write            (csr_clint_write    ),
  .csr_clint_waddr            (csr_clint_waddr    ),
  .csr_clint_wdata            (csr_clint_wdata    ),
  .csr_clint_ren_r            (csr_clint_ren_r    ),
  .mtvec_mode                 (mtvec_mode         ),
  .sp_u                       (sp_u               ),
  .sp_u_recover               (sp_u_recover       ),
  .mtsp_r                     (mtsp_r             ),
  .wid_rwiddeleg              (wid_rwiddeleg      ),
  .wid_rlwid                  (wid_rlwid          ),
  .wid                        (wid                ),

  .trap_return                (trap_return        ),
  .rnmi_enable                (rnmi_enable        ),
  .csr_trap_base              (csr_trap_base      ),
  .csr_trap_epc               (csr_trap_epc       ),
  .csr_trap_ret               (csr_trap_ret       ),

  .trap_valid                 (trap_x2_valid      ),
  .trap_cause                 (trap_x2_cause      ),
  .trap_data                  (trap_x2_data       ),

  .rnmi_synch_r               (rnmi_synch_r       ),
  .reset_pc_in                (reset_pc_in        ),

  .mtime_r                    (mtime_r            ),
  .arcnum                     (arcnum             ),
  .single_step                (single_step        ),
  .stepie                     (stepie             ),
  .step_blocks_irq            (step_blocks_irq    ),
  .csr_x1_read                (csr_x1_read        ),
  .csr_x1_write               (csr_x1_write       ),
  .csr_x2_pass                (csr_x2_pass        ),
  .csr_x2_wen                 (csr_x2_wen         ),

  .clk                        (clk_gated          ),
  .rst_a                      (rst_a              )
);

rl_special u_rl_special (
  .x1_pass                    (x1_pass            ),
  .x1_spc_ctl                 (x1_spc_ctl         ),
  .x1_src0_data               (x1_src0_data       ),
  .x1_src2_data               (x1_src2_data       ),

  .fch_restart                (fch_restart        ),

  .x2_valid_r                 (x2_valid_r         ),
  .break_excpn                (break_excpn        ),
  .break_halt                 (break_halt         ),

  .spc_x2_ebreak              (spc_x2_ebreak      ),
  .spc_x2_hbreak              (spc_x2_hbreak      ),
  .spc_x2_stall               (spc_x2_stall       ),
  .spc_x2_ecall               (spc_x2_ecall       ),
  .spc_x2_clean               (spc_x2_clean       ),
  .spc_x2_flush               (spc_x2_flush       ),
  .spc_x2_inval               (spc_x2_inval       ),
  .spc_x2_zero                (spc_x2_zero        ),
  .spc_x2_prefetch            (spc_x2_prefetch    ),
  .spc_x2_data                (spc_x2_data        ),
  .icmo_done                  (icmo_done          ),
  .kill_ic_op                 (kill_ic_op         ),
  .db_active                  (db_active),
  .spc_fence_i_inv_req        (spc_fence_i_inv_req),
  .spc_fence_i_inv_ack        (spc_fence_i_inv_ack),
  .spc_x2_wfi                 (spc_x2_wfi         ),
  .fencei_restart             (fencei_restart     ),
  .icmo_restart               (icmo_restart       ),

  .dmp_idle_r                 (dmp_idle_r         ),
  .hpm_bifsync                (hpm_bifsync        ),
  .hpm_bdfsync                (hpm_bdfsync        ),

  .clk                        (clk_gated          ),
  .rst_a                      (rst_a              )
);


rl_pipe_ctrl u_rl_pipe_ctrl (
  .clk                        (clk_gated  ),
  .rst_a                      (rst_a      ),

  .ifu_issue                  (ifu_issue  ),
  .db_valid                   (db_valid   ),
  .x1_holdup                  (x1_holdup  ),
  .uop_busy                   (uop_busy   ),
  .br_x1_stall                (br_x1_stall),
  .uop_valid                  (uop_valid  ),
  .x2_uop_valid_r             (x2_uop_valid_r),
  .x1_flush                   (x1_flush   ),
  .x1_valid_r                 (x1_valid_r ),
  .x1_pass                    (x1_pass    ),
  .x1_enable                  (x1_enable  ),
  .x1_br_taken                (br_x1_taken),
  .x1_fu_stall                ({x1_stall, dmp_x1_stall}),

  .iesb_x2_holdup             (iesb_x2_holdup),
  .x2_valid_r                 (x2_valid_r),
  .x2_pass                    (x2_pass),
  .x2_enable                  (x2_enable),
  .x2_flush                   (x2_flush ),
  .x2_retain                  (x2_retain),
  .x2_fu_stall                (
                               {soft_reset_x2_stall,
                                spc_x2_stall,
                                alu_x2_stall,
                                dmp_x2_stall}),

  .fencei_restart             (fencei_restart     ),
  .icmo_restart               (icmo_restart       ),
  .x3_valid_r                 (x3_valid_r),

  .x3_fu_stall                ({
                                mpy_x3_stall,
                                1'b0
                               }),
  .x3_flush_r                 (x3_flush_r),

  .cp_flush                   (cp_flush)
);

rl_result_bus u_rl_result_bus (
  .alu_rb_req_r               (alu_x2_rb_req_r),
  .alu_dst_id_r               (alu_x2_dst_id_r),
  .alu_data                   (alu_x2_data),
  .rb_alu_ack                 (rb_alu_ack),

  .mpy_rb_req_r               (mpy_rb_req_r),
  .mpy_dst_id_r               (mpy_x3_dst_id_r),
  .mpy_data                   (mpy_x3_data),
  .rb_mpy_ack                 (rb_mpy_ack),


  .dmp_rb_req_r               (dmp_rb_req_r),
  .dmp_rb_post_commit_r       (dmp_rb_post_commit_r),
  .dmp_rb_retire_err_r        (dmp_rb_retire_err_r ),
  .dmp_dst_id_r               (dmp_rb_dst_id),
  .dmp_data                   (dmp_x2_data),
  .rb_dmp_ack                 (rb_dmp_ack),

  .csr_rb_req_r               (csr_x2_rb_req_r),
  .csr_dst_id_r               (csr_x2_dst_id_r),
  .csr_data                   (csr_x2_data),
  .rb_csr_ack                 (rb_csr_ack),


  .x2_pass                    (x2_pass),

  .rb_rf_write0               (rb_rf_write0),
  .rb_rf_addr0                (rb_rf_addr0),
  .rb_rf_wdata0               (rb_rf_wdata0),

  .rb_rf_write1               (rb_rf_write1),
  .rb_rf_addr1                (rb_rf_addr1),
  .rb_rf_wdata1               (rb_rf_wdata1)
);

rl_debug u_rl_debug (
  .clk                        (clk),
  .rst_a                      (rst_a),

  .safety_iso_enb_synch_r     (safety_iso_enb_synch_r),
  .dr_safety_iso_err          (dr_safety_iso_err),

  .cpu_db_ack                 (cpu_db_ack),
  .cpu_rdata                  (cpu_rdata),
  .cpu_rd_err                 (cpu_rd_err),
  .cpu_invalid_inst           (cpu_invalid_inst),
  .cpu_db_done                (cpu_db_done),



  .db_request                 (db_request),
  .db_valid                   (db_valid),
  .db_active                  (db_active),
  .db_inst                    (db_inst),
  .db_limm                    (db_limm),
  .db_data                    (db_data),
  .db_op_1h                   (db_op_1h),
  .db_reg_addr                (db_reg_addr),
  .db_restart                 (1'b0), // @@@

  .db_clock_enable_nxt        (db_clock_enable_nxt),

  .dbg_ibp_cmd_valid          (dbg_ibp_cmd_valid),
  .dbg_ibp_cmd_read           (dbg_ibp_cmd_read),
  .dbg_ibp_cmd_addr           (dbg_ibp_cmd_addr),
  .dbg_ibp_cmd_accept         (dbg_ibp_cmd_accept),
  .dbg_ibp_cmd_space          (dbg_ibp_cmd_space),
  .dbg_ibp_rd_valid           (dbg_ibp_rd_valid),
  .dbg_ibp_rd_accept          (dbg_ibp_rd_accept),
  .dbg_ibp_rd_err             (dbg_ibp_rd_err),
  .dbg_ibp_rd_data            (dbg_ibp_rd_data),
  .dbg_ibp_wr_valid           (dbg_ibp_wr_valid),
  .dbg_ibp_wr_accept          (dbg_ibp_wr_accept),
  .dbg_ibp_wr_data            (dbg_ibp_wr_data),
  .dbg_ibp_wr_mask            (dbg_ibp_wr_mask),
  .dbg_ibp_wr_done            (dbg_ibp_wr_done),
  .dbg_ibp_wr_err             (dbg_ibp_wr_err),
  .dbg_ibp_wr_resp_accept     (dbg_ibp_wr_resp_accept),
  .ar_clock_enable_r          (ar_clock_enable_r)  // @@@
);



rl_halt_mgr u_rl_halt_mgr (
  .clk                        (clk_gated),
  .rst_a                      (rst_a),

  .db_request                 (db_request),
  .cpu_db_ack_r               (cpu_db_ack),


  .dm2arc_halt_on_reset       (dm2arc_halt_on_reset),
  .is_dm_rst                  (is_dm_rst),
  .gb_sys_run_req_r           (gb_sys_run_req_r),
  .gb_sys_halt_req_r          (gb_sys_halt_req_r),

  .gb_sys_run_ack_r           (gb_sys_run_ack_r),
  .gb_sys_halt_ack_r          (gb_sys_halt_ack_r),


  .debug_mode                 (debug_mode),
  .ato_vec_jmp                (ato_vec_jmp),
  .fatal_err_dbg              (fatal_err_dbg),
  .db_active                  (db_active),
  .single_step                (single_step),
  .halt_req_asserted_r        (halt_req_asserted),
  .halt_fsm_in_rst            (halt_fsm_in_rst),

  .commit                     (x2_pass),
  .ebreak                     (spc_x2_hbreak),
  .fatal_err                  (fatal_err),
  .x1_inst_break_r            (x1_inst_break_r),
  .x2_inst_break              (x2_inst_break),
  .dmp_addr_trig_break        (dmp_addr_trig_break),
  .dmp_ld_data_trig_break     (dmp_ld_data_trig_break),
  .dmp_st_data_trig_break     (dmp_st_data_trig_break),
  .ext_trig_break             (ext_trig_break),
  .x1_pass                    (x1_pass),
  .halt_cond_r                (halt_cond),
  .wfi                        (spc_x2_wfi),
  .irq_wakeup                 (irq_wakeup),

  .halt_restart_r             (halt_restart_r),
  .halt_stop_r                (halt_stop_r),
  .cpu_db_done                (cpu_db_done),


  .ifu_idle_r                 (ifu_idle_r),
  .dmp_idle_r                 (dmp_idle_r),
  .biu_idle_r                 (biu_idle_r),
  .spc_x2_stall               (spc_x2_stall),
  .mpy_busy                   (mpy_busy),
  .uop_busy_del               (uop_busy_del),
  .uop_busy_ato               (uop_busy_ato),
  .pipe_blocks_trap           (pipe_blocks_trap),
  .step_blocks_irq            (step_blocks_irq),
  .stepie                     (stepie),

  .gb_sys_halt_r              (sys_halt_r),
  .gb_sys_sleep_r             (sys_sleep_r)

);

rl_complete u_rl_complete (
  .clk                        (clk_gated           ),
  .rst_a                      (rst_a               ),

  .reset_pc_in                (reset_pc_in         ),
  .cycle_delay                (cycle_delay         ),
  .x1_pass                    (x1_pass             ),
  .x1_pc                      (x1_pc               ),
  .x1_inst                    (x1_inst             ),

  .x1_uop_commit              (uop_commit          ),
  .x1_uop_valid               (uop_valid           ),
  .x1_uop_ctl                 (x1_uop_ctl          ),

  .x2_valid_r                 (x2_valid_r          ),
  .x2_pass                    (x2_pass             ),
  .x2_replay                  (x2_replay           ),
  .x2_enable                  (x2_enable           ),
  .fencei_restart             (fencei_restart      ),
  .icmo_restart               (icmo_restart        ),
  .x1_inst_size               (x1_inst_size        ),

  .br_x2_taken_r              (br_x2_taken_r       ),
  .br_x2_target_r             (br_x2_target_r      ),

  .csr_x2_write_pc            (csr_x2_write_pc     ),
  .csr_x2_wdata               (csr_x2_wdata        ),

  .dmp_x2_load_r              (dmp_x2_load         ),
  .dmp_x2_grad_r              (dmp_x2_grad         ),
  .dmp_x2_retire_req          (dmp_x2_retire_req   ),

  .ebreak                     (spc_x2_hbreak        ),

  .halt_restart_r             (halt_restart_r      ),
  .halt_stop_r                (halt_stop_r         ),

  .fch_restart                (fch_restart         ),
  .fch_restart_vec            (fch_restart_vec     ),
  .fch_target                 (fch_target          ),
  .fch_stop_r                 (fch_stop_r          ),

  .db_active                  (db_active           ),
  .rb_rf_write1               (rb_rf_write1        ),
  .db_exception               (db_exception        ),
  .cpu_db_done                (cpu_db_done         ),

  .csr_flush_r                (csr_flush_r         ),

  .trap_valid                 (trap_x2_valid       ),
  .fatal_err                  (fatal_err           ),
  .irq_enable                 (irq_enable          ),
  .irq_id                     (irq_id              ),
  .int_valid                  (irq_trap            ),
  .vec_mode                   (vec_mode            ),
  .rnmi_synch_r               (rnmi_synch_r        ),
  .trap_base                  (csr_trap_base       ),

  .trap_return                (trap_return         ),
  .trap_epc                   (csr_trap_epc        ),

  .cp_flush                   (cp_flush            ),
  .cp_flush_no_excp           (cp_flush_no_excp    ),
  .x2_pc_r                    (x2_pc               ),
  .x2_inst_size_r             (x2_inst_size        ),
  .x2_inst_r                  (x2_inst             ),
  .ar_pc_r                    (ar_pc_r             )
);

assign debug_mode_tmp       = db_active | debug_mode_r;
assign x2_replay            = dmp_x2_replay | iesb_replay;

rl_iesb u_rl_iesb (
  .clk                     ( clk                     ), // clock signal
  .rst_a                   ( rst_a                   ), // reset signal
  .x2_valid_r              ( x2_valid_r              ),
  .arcv_mesb_ctrl          ( arcv_mesb_ctrl          ),
  .priv_level_r            ( priv_level_r            ),
  .precise_x2_excpn        ( precise_x2_excpn        ),
  .imprecise_x2_excpn      ( imprecise_x2_excpn      ),
  .take_int                ( take_int                ),
  .trap_return             ( csr_trap_ret            ),
  .dmp_empty               ( lsq_empty               ), // DMP queue empty
  .uop_valid               ( uop_valid               ),
  .uop_commit              ( uop_commit              ),
  .iesb_barrier            ( iesb_barrier            ), // Exception barrier
  .iesb_replay             ( iesb_replay             ), // Pipeline replay
  .iesb_block_excpn        ( iesb_block_excpn        ), // Pipeline stall
  .iesb_block_int          ( iesb_block_int          ), // Pipeline stall
  .iesb_x2_holdup          ( iesb_x2_holdup          )  // Pipeline stall
);


rl_trap u_rl_trap (
  .ifu_x1_excp                (x1_ifu_exception  ),
  .x2_inst_trap               (x2_inst_trap      ),
  .ext_trig_trap              (ext_trig_trap     ),
  .inst_x1_illegal            (illegal_inst      ),
  .csr_x1_illegal             (csr_illegal       ),
  .spc_x2_ecall               (spc_x2_ecall      ),
  .x1_pmp_addr_r              (x1_pmp_addr_r     ),

  .precise_x2_excpn           (precise_x2_excpn  ),
  .imprecise_x2_excpn         (imprecise_x2_excpn),
  .iesb_replay                (iesb_replay       ),
  .take_int                   (take_int          ),
  .dmp_x2_excp                (dmp_exception_sync),       
  .dmp_excp_async             (dmp_exception_async),
  .spc_x2_ebreak              (spc_x2_ebreak     ),
  .dmp_x2_addr                (dmp_x2_addr       ),

  .x1_pass                    (x1_pass           ),
  .x1_inst                    (x1_inst           ),
  .x1_pc                      (x1_pc             ),
  .x2_enable                  (x2_enable         ),
  .jalt_done                  (jalt_done         ),
  .x2_valid_r                 (x2_valid_r        ),
  .x2_flush                   (x2_flush          ),
  .i_cp_flush_no_excp         (cp_flush_no_excp  ),
  .iesb_barrier               (iesb_barrier      ),
  .priv_level_r               (priv_level_r      ),
  .mdt_r                      (mdt_r             ),
  .irq_enable                 (irq_enable        ),
  .irq_trap                   (irq_trap          ),
  .irq_id                     (mtopi_iid         ),
  .trap_ack                   (trap_ack          ),
  .rnmi_enable                (rnmi_enable       ),

  .trap_x2_valid              (trap_x2_valid     ),
  .trap_x2_cause              (trap_x2_cause     ),
  .trap_x2_data               (trap_x2_data      ),
  .irq_wakeup                 (irq_wakeup        ),
  .fatal_err                  (fatal_err         ),

  .debug_mode                 (debug_mode_tmp    ),
  .cpu_invalid_inst           (cpu_invalid_inst  ),
  .db_exception               (db_exception      ),
  .relaxedpriv                (relaxedpriv       ),

  .rnmi_synch_r               (rnmi_synch_r      ),
  .iesb_block_excpn           (iesb_block_excpn  ),
  .iesb_block_int             (iesb_block_int    ),
  .pipe_blocks_trap           (pipe_blocks_trap  ),
  .clk                        (clk_gated         ),
  .rst_a                      (rst_a             )

);



`ifdef SIMULATION

wire        x1_load     = x1_dmp_ctl[`DMP_CTL_LB]
                        | x1_dmp_ctl[`DMP_CTL_LBU]
                        | x1_dmp_ctl[`DMP_CTL_LH]
                        | x1_dmp_ctl[`DMP_CTL_LHU]
                        | x1_dmp_ctl[`DMP_CTL_LW]
                        ;

wire        x1_store    = x1_dmp_ctl[`DMP_CTL_SB]
                        | x1_dmp_ctl[`DMP_CTL_SH]
                        | x1_dmp_ctl[`DMP_CTL_SW]
                        ;

wire        x1_byte    = x1_dmp_ctl[`DMP_CTL_LB]
                       | x1_dmp_ctl[`DMP_CTL_LBU]
                       | x1_dmp_ctl[`DMP_CTL_SB]
                       ;

wire        x1_half    = x1_dmp_ctl[`DMP_CTL_LH]
                       | x1_dmp_ctl[`DMP_CTL_LHU]
                       | x1_dmp_ctl[`DMP_CTL_SH]
                       ;

wire        x1_word    = x1_dmp_ctl[`DMP_CTL_LW]
                       | x1_dmp_ctl[`DMP_CTL_SW]
                       ;

wire [1:0]  x1_size     = {x1_word, x1_half};

wire [31:0] x1_mem_addr = db_active
                        ? db_limm
                        : (x1_src0_data + x1_src2_data);
wire [31:0] x1_mem_data = db_active
                        ? db_data
                        : x1_src1_data;
wire        irq_ack     = irq_trap & irq_enable;

rtl_pipemon u_pipemon (
  .clk                        (clk_gated),
  .rst_a                      (rst_a),

  .db_active                  (db_active),
  .mip_r                      (mip_r),
  .mie_r                      (mie_r),
  .mtsp_r                     (mtsp_r),

  .shadow_decoder             (shadow_decoder),

  .x1_valid_r                 (x1_valid_r),
  .x1_pass                    (x1_pass),
  .x1_is_16bit_r              (1'b0),
  .x1_inst_r                  (x1_inst),
  .x1_pc                      ({x1_pc, 1'b0}),

  .x1_load                    (x1_load),
  .x1_store                   (x1_store),
  .x1_size                    (x1_size),
  .x1_mem_addr                (x1_mem_addr),
  .x1_mem_data                (x1_mem_data),

  .x2_valid_r                 (x2_valid_r),
  .x2_pass                    (x2_pass),
  .trap_valid                 (trap_x2_valid),
  .rnmi_synch_r               (rnmi_synch_r),
  .rnmi_enable                (rnmi_enable),
  .mdt_r                      (mdt_r),
  .mepc_r                     (csr_trap_epc),
  .trap_ack                   (irq_ack),
  .irq_id                     (irq_id),

  .mstatus_nxt                (mstatus_nxt),
  .mnstatus_r                 (mnstatus_r),
  .mncause_r                  (mncause_r),
  .csr_x2_mret                (csr_x2_mret),
  .csr_x2_mnret               (csr_x2_mnret),
  .trap_x2_cause              (trap_x2_cause),
  .trap_x2_data               (trap_x2_data),

  .rb_rf_write0               (rb_rf_write0),
  .rb_rf_addr0                (rb_rf_addr0 ),
  .rb_rf_wdata0               (rb_rf_wdata0),

  .rb_rf_write1               (rb_rf_write1),
  .rb_rf_addr1                (rb_rf_addr1 ),
  .rb_rf_wdata1               (rb_rf_wdata1),

  .ar_pc_r                    ({ar_pc_r, 1'b0})
);

`endif
assign trap_clear_lf  = trap_x2_valid;

reg sr_op_r; // Required to capture CSR RD/RX in x2 stage
wire sr_op;
assign sr_aux_write  = x1_csr_ctl[`CSR_CTL_WRITE]; 
assign sr_aux_raddr  = x1_src1_data[11:0];
assign sr_aux_waddr  = x1_src1_data[11:0];
assign sr_aux_wdata  = x1_src0_data;
assign sr_op         = (x1_src1_data[11:2] == 10'h3FC);
assign sr_aux_wen    = sr_op;
assign sr_aux_ren    = sr_op;
assign sr_ar_pc_r    = ar_pc_r;
assign sr_mstatus    = mstatus_r;
assign sr_db_active  = db_active;

assign mstatus_tw    = mstatus_r[`TW];
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ : Intended as per the design
assign soft_reset_x2_stall =  (x2_valid_r & soft_reset_prepare);
// spyglass enable_block RegInputOutput-ML

// spyglass disable_block INTEGRITY_RESET_GLITCH
// SMD: Clear pin of sequential element is driven by combinational logic
// SJ:  Intended to merge all reset sources
always@(posedge clk or posedge rst_a)
begin: soft_reset_op_reg_PROC
  if (rst_a == 1'b1)
  begin
    sr_op_r <= 1'b0;
  end
  else
  begin
    sr_op_r <= sr_op;
  end
end
// spyglass enable_block INTEGRITY_RESET_GLITCH




//////////////////////////////////////////////////////////////////////////////
//
// Temporary stubs @@@
//
//////////////////////////////////////////////////////////////////////////////

assign sys_sleep_mode_r = 3'b000;
assign critical_error   = fatal_err & (!fatal_err_dbg);

assign db_mem_op_1h     = {db_op_1h[`DB_OP_MEM_WR], db_op_1h[`DB_OP_MEM_RD]};
assign exu_busy         = ifu_issue || x1_valid_r || x2_valid_r;
// To count bubbles when execution unit is ready, but fetch unit does not have instructions available
assign hpm_bissue = x1_enable & (~ifu_issue);

endmodule // rl_regfile

