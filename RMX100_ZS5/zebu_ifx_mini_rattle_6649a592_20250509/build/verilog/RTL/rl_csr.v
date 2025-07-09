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
`include "dmp_defines.v"
`include "mpy_defines.v"
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"


module rl_csr (
  ////////// Dispatch interface /////////////////////////////////////////////
  //
  input                      x1_valid_r,            // Valid instruction in X1
  input                      x1_pass,               // instruction dispatched to the CSR FU
  input [`CSR_CTL_RANGE]     x1_csr_ctl,            // Indicates the instructon to be executed in this FU
  input [`DATA_RANGE]        x1_src0_data,          // source0 operand  -- data
  input [11:0]               x1_src1_data,          // source1 operand  -- address
  input [4:0]                x1_dst_id,             // destination register - used for scoreaboarding
  output reg [`DATA_RANGE]   arcv_ujvt_r,
  input                      x2_uop_valid_r,
  
  output reg                 csr_illegal,           //  (X1) SR/LR illegal -> to trap module
  output reg                 csr_flush_r,           //  (X3) flush pipe on behalf of CSR write -> to complete module
  output                     csr_raw_hazard,        //  (X1) RAW hazard for CSR

  ////////// Debug access /////////////////////////////////////////////////
  //
  input                      db_active,             // Debug
  input                      db_write,              // Debug writing to a CSR
  input [`DATA_RANGE]        db_wdata,              // Debug write data
  output reg [`DATA_RANGE]   dpc_r,
  output                     break_excpn,           // EBREAK should excpn
  output                     break_halt,            // EBREAK should halt
  output                     fatal_err_dbg,         // Fatal error enter debug
  output                     mprven_r,
  
  ////////// X2 stage interface /////////////////////////////////////////////
  //
  input                      x2_valid_r,            // X2 valid instruction from pipe ctrl
  input                      x2_pass,               // X2 commit
 
  output  [`DATA_RANGE]      csr_x2_data,           // CSR X2 result available for bypass
  output                     csr_x2_dbg_rd_err,     // CSR X2 Read Error for Debug
  output reg [4:0]           csr_x2_dst_id_r,       // CSR X2 destination register - used for scoreaboarding
  output                     csr_x2_dst_id_valid,   // CSR X2 valid destination 
  output reg                 csr_x2_rb_req_r,       // CSR requests result bus to write to register file
  input                      x2_csr_rb_ack,         // results bus granted CSR access (write port)
  
  output reg                 csr_x2_write_pc,       // Debug write to PC
  output reg [`DATA_RANGE]   csr_x2_wdata,          // Value to be written to PC
  
  ////////// PMP interface /////////////////////////////////////////////
  //
  output reg [1:0]            csr_pmp_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [11:0]           csr_pmp_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         pmp_csr_rdata,        // (X1) CSR read data
  input                       pmp_csr_illegal,      // (X1) illegal
  input                       pmp_csr_unimpl,       // (X1) Invalid CSR
  input                       pmp_csr_serial_sr,    // (X1) SR group flush pipe
  input                       pmp_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_pmp_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [11:0]          csr_pmp_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_pmp_wdata,        // (X2) Write data

  output reg [1:0]            csr_trig_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [11:0]           csr_trig_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         trig_csr_rdata,        // (X1) CSR read data
  input                       trig_csr_illegal,      // (X1) illegal
  input                       trig_csr_unimpl,       // (X1) Invalid CSR
  input                       trig_csr_serial_sr,
  input                       trig_csr_strict_sr,
  
  output reg                  csr_trig_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [11:0]          csr_trig_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_trig_wdata,        // (X2) Write data
  input       [2:0]           halt_cond,

  ////////// PMA interface /////////////////////////////////////////////
  //
  output reg [1:0]            csr_pma_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [11:0]           csr_pma_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         pma_csr_rdata,        // (X1) CSR read data
  input                       pma_csr_illegal,      // (X1) illegal
  input                       pma_csr_unimpl,       // (X1) Invalid CSR
  input                       pma_csr_serial_sr,    // (X1) SR group flush pipe
  input                       pma_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_pma_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [11:0]          csr_pma_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_pma_wdata,        // (X2) Write data

  ////////// iCSR interface /////////////////////////////////////////////
  //
  output reg [`DATA_RANGE]    miselect_r,           //
  input      [`DATA_RANGE]    mireg_clint,          //
  output reg                  mireg_clint_wen,

  ////////// HPM interface /////////////////////////////////////////////
  //
  output reg [1:0]            csr_hpm_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [11:0]           csr_hpm_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         hpm_csr_rdata,        // (X1) CSR read data
  input                       hpm_csr_illegal,      // (X1) illegal
  input                       hpm_csr_unimpl,       // (X1) Invalid CSR
  input                       hpm_csr_serial_sr,    // (X1) SR group flush pipe
  input                       hpm_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_hpm_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [11:0]          csr_hpm_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_hpm_wdata,        // (X2) Write data
  output reg                  csr_hpm_range,


  ////////// ICCM interface /////////////////////////////////////////////
  //
  output reg [1:0]            csr_iccm_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [7:0]            csr_iccm_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         iccm_csr_rdata,        // (X1) CSR read data
  input                       iccm_csr_illegal,      // (X1) illegal
  input                       iccm_csr_unimpl,       // (X1) Invalid CSR
  input                       iccm_csr_serial_sr,    // (X1) SR group flush pipe
  input                       iccm_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_iccm_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [7:0]           csr_iccm_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_iccm_wdata,        // (X2) Write data

  ////////// ICCM ECC exception ///////////////////////////////////////////////////////////
  input                       iccm_ecc_excpn,
  input                       iccm_dmp_ecc_err,
  input                       iccm_ecc_wr,
  input  [`ICCM0_ECC_RANGE]   iccm0_ecc_out,

  ////////// DMP CSR interface /////////////////////////////////////////////
  //
  output reg [1:0]            csr_dmp_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [7:0]            csr_dmp_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         dmp_csr_rdata,        // (X1) CSR read data
  input                       dmp_csr_illegal,      // (X1) illegal
  input                       dmp_csr_unimpl,       // (X1) Invalid CSR
  input                       dmp_csr_serial_sr,    // (X1) SR group flush pipe
  input                       dmp_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_dmp_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [7:0]           csr_dmp_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_dmp_wdata,        // (X2) Write data
  input                       dccm_ecc_excpn,
  input                       dccm_ecc_wr,
  input  [`DCCM_ECC_BITS-1:0] dccm_ecc_out,

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

  output [1:0]                arcv_mesb_ctrl,

  ////////// SAFETY interface /////////////////////////////////////////////
  //
  output reg [1:0]            csr_sfty_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [11:0]           csr_sfty_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         sfty_csr_rdata,        // (X1) CSR read data
  input                       sfty_csr_illegal,      // (X1) illegal
  input                       sfty_csr_unimpl,       // (X1) Invalid CSR
  input                       sfty_csr_serial_sr,    // (X1) SR group flush pipe
  input                       sfty_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_sfty_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [11:0]          csr_sfty_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_sfty_wdata,        // (X2) Write data


  ////////// X3 stage interface /////////////////////////////////////////////
  //
  input                      x3_valid_r,            // X3: instruction committed previous cycle
  input                      x3_flush_r,            // Pipeline has been flushed
  
  ////////// Machine state /////////////////////////////////////////////////////
  //
  input [`DATA_RANGE]        ar_pc_r,               // architectural PC

  output reg [1:0]           priv_level_r,
  output reg [`DATA_RANGE]   mstatus_r,
  output reg                 mdt_r,                 // MDT for double trap mstatush[10]
  output reg [`DATA_RANGE]   mstatus_nxt,           
  output reg [`DATA_RANGE]   mnstatus_r,
  output reg [`DATA_RANGE]   mncause_r,
  output                     csr_x2_mret,
  output                     csr_x2_mnret,
  output     [5:0]           mcause_o,
  input      [`DATA_RANGE]   sr_aux_rdata,
  input                      sr_aux_illegal,
  
  ////////// Halt Manager //////////////////////////////////////////////
  //
  input                      debug_mode,
  
  ////////// Traps /////////////////////////////////////////////////////
  //
  output                     irq_enable,            // Interrupt enable in MSTATUS
  
  output reg                 debug_mode_r,
  output reg [`PC_RANGE]     csr_trap_base,         // exception/interrupt vector
  output reg [`ADDR_RANGE]   csr_trap_epc,          // CSR EPC
  output                     trap_return,
  output                     rnmi_enable,
  output                     csr_trap_ret,
  input                      trap_valid,            // Valid interrupt/exception
  input [`DATA_RANGE]        trap_cause,            // Cause of exception or interrupt 
  input [`DATA_RANGE]        trap_data,             // Auxiliary exception data for mtval

  output reg [1:0]            csr_clint_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [11:0]           csr_clint_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         clint_csr_rdata,        // (X1) CSR read data
  input                       clint_csr_illegal,      // (X1) illegal
  input                       clint_csr_unimpl,       // (X1) Invalid CSR
  input                       clint_csr_serial_sr,    // (X1) SR group flush pipe
  input                       clint_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_clint_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [11:0]          csr_clint_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_clint_wdata,        // (X2) Write data
  output reg                  csr_clint_ren_r,
  output                      mtvec_mode,
  input [`DATA_RANGE]         sp_u,
  output reg                  sp_u_recover,
  output reg [`DATA_RANGE]    mtsp_r,
  output                      vec_mode,
 
  ////////// Watchdog interface /////////////////////////////////////////////
  //
  output reg [1:0]            csr_wdt_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output reg [11:0]           csr_wdt_sel_addr,     // (X1) CSR address
  
  input [`DATA_RANGE]         wdt_csr_rdata,        // (X1) CSR read data
  input                       wdt_csr_illegal,      // (X1) illegal
  input                       wdt_csr_unimpl,       // (X1) Invalid CSR
  input                       wdt_csr_serial_sr,    // (X1) SR group flush pipe
  input                       wdt_csr_strict_sr,    // (X1) SR flush pipe
  
  output reg                  csr_wdt_write,        // (X2) CSR operation (01 = read, 10 = write)
  output reg  [11:0]          csr_wdt_waddr,        // (X2) CSR addr
  output reg  [`DATA_RANGE]   csr_wdt_wdata,        // (X2) Write data
  input                       wdt_csr_raw_hazard,


  output reg [`CNT_CTRL_RANGE]  mcounteren_r,         // mcounteren CSR
  output reg [`CNT_CTRL_RANGE]  mcountinhibit_r,      // mcounterinhibit CSR
  output reg                    instret_ovf,
  output reg                    cycle_ovf,

  input  [`WID_RANGE]         wid_rlwid,
  input  [63:0]               wid_rwiddeleg,
  output [`WID_RANGE]         wid,

  input [11:0]                core_mmio_base_in,
  output reg [11:0]           core_mmio_base_r,
  input                       cycle_delay,
  input   [21:0]              reset_pc_in,
  input                       rnmi_synch_r,
  input   [63:0]              mtime_r,
  input   [7:0]               arcnum /* verilator public_flat */,
  output                      single_step,
  input                       step_blocks_irq,
  output                      stepie,
  output                      csr_x1_read,
  output                      csr_x1_write,
  output                      csr_x2_pass,
  output                      csr_x2_wen,

  //
  input                       clk,                   // clock signal
  input                       rst_a                  // reset signal

);

// Local declarations
//
wire [11:0]           csr_x1_addr;
wire [`DATA_RANGE]    csr_x1_data;

wire                  csr_is_bcr;

reg [`DATA_RANGE]     csr_rdata;
reg                   csr_stall;

reg                   csr_x2_valid_r;
reg                   csr_x2_valid_nxt;
reg                   csr_x2_dst_id_valid_r;
reg [4:0]             csr_x2_dst_id_nxt;
reg                   csr_x2_ctl_cg0;
reg                   csr_x2_data_cg0;
reg                   csr_x2_addr_cg0;
reg [11:0]            csr_x2_addr_r;
reg [`DATA_RANGE]     csr_x2_data_r;
reg                   csr_x2_dbg_rd_err_r;
reg [`CSR_CTL_RANGE]  csr_x2_ctl_r;
reg [`DATA_RANGE]     csr_status32_nxt;

reg [`DATA_RANGE]     x2_src0_data_r;

reg                   csr_x2_rb_req_nxt;
reg                   csr_x2_rb_req_cg0;

reg                   csr_trap_ret_cg0;
reg                   csr_trap_ret_nxt;
reg                   csr_trap_ret_r;

reg                   rnmi_ret_cg0;
reg                   rnmi_ret_nxt;
reg                   rnmi_ret_r;

reg                   csr_unimpl;
reg                   csr_serial_sr;
reg                   csr_strict_sr;

wire                  csr_x1_dst_id_valid;
wire                  csr_x1_pass;
wire                  csr_x2_valid;


// Track priv level
//
reg [1:0]             priv_level_nxt;
reg                   priv_level_cg0;

// CSRs
//
reg [`DATA_RANGE]     mcause_r;

reg [`DATA_RANGE]     mtvec_r;
reg [`DATA_RANGE]     mtvec_nxt;
reg                   mtvec_cg0;

reg [`WID_RANGE]      mlwid_r;
reg [`WID_RANGE]      mlwid_nxt;
reg [`WID_RANGE]      wid_rlwid_r;
reg [63:0]            wid_rwiddeleg_r;
wire [63:0]           wid_xwiddeleg_rev;
wire [`WID_RANGE]     wid_rwiddeleg_lst_lgl_val;

reg                   mlwid_cg0;

reg                   miselect_cg0;
reg [`DATA_RANGE]     miselect_nxt;
reg                   mireg_cg0;
wire [`DATA_RANGE]    mireg_rd_r;

reg                   uiselect_cg0;
reg [`DATA_RANGE]     uiselect_nxt;
reg                   uireg_cg0;
wire [`DATA_RANGE]    uireg_rd_r;

reg                   mdt_nxt;
reg                   mdt_cg0;
reg                   mdt_sw_nxt;
reg                   mdt_sw_cg0;
reg [`DCSR_RANGE]     dcsr_r;
reg [`DCSR_RANGE]     dcsr_nxt;
reg                   dcsr_cg0;
reg [`DATA_RANGE]     dpc_nxt;
reg                   dpc_cg0;

reg                   csr_clint_mireg;

reg [`DATA_RANGE]     icsr_addr_nxt;
reg                   icsr_addr_cg0;
reg [`DATA_RANGE]     icsr_wdata_nxt;
reg                   icsr_wen_cg0;

reg [`DATA_RANGE]     mscratch_r;
reg [`DATA_RANGE]     mscratch_nxt;
reg                   mscratch_cg0;

reg [`DATA_RANGE]     mnscratch_r;
reg [`DATA_RANGE]     mnscratch_nxt;
reg                   mnscratch_cg0;

reg [`DATA_RANGE]     menvcfg_r;
reg [`DATA_RANGE]     menvcfg_nxt;
reg                   menvcfg_cg0;

reg [1:0]             arcv_mesb_ctrl_r;
reg [1:0]             arcv_mesb_ctrl_nxt;
reg                   arcv_mesb_ctrl_cg0;

reg [`DATA_RANGE]     mstatus_sw_nxt;
reg                   mstatus_sw_cg0;
reg                   mstatus_cg0;

reg [`DATA_RANGE]     mcause_nxt;
reg [`DATA_RANGE]     mcause_sw_nxt;
reg                   mcause_sw_cg0;
reg                   mcause_cg0;

reg [`DATA_RANGE]     mepc_r;
reg [`DATA_RANGE]     mepc_nxt;
reg [`DATA_RANGE]     mepc_sw_nxt;
reg                   mepc_sw_cg0;
reg                   mepc_cg0;

reg [`DATA_RANGE]     mnstatus_nxt;
reg [`DATA_RANGE]     mnstatus_sw_nxt;
reg                   mnstatus_sw_cg0;
reg                   mnstatus_cg0;

reg [`DATA_RANGE]     mncause_nxt;
reg [`DATA_RANGE]     mncause_sw_nxt;
reg                   mncause_sw_cg0;
reg                   mncause_cg0;

reg [`DATA_RANGE]     mnepc_r;
reg [`DATA_RANGE]     mnepc_nxt;
reg [`DATA_RANGE]     mnepc_sw_nxt;
reg                   mnepc_sw_cg0;
reg                   mnepc_cg0;

reg [`DATA_RANGE]     mtval_r;
reg [`DATA_RANGE]     mtval_nxt;
reg [`DATA_RANGE]     mtval_sw_nxt;
reg                   mtval_sw_cg0;
reg                   mtval_cg0;

reg [`DATA_RANGE]     mtsp_nxt;
reg [`DATA_RANGE]     mtsp_sw_nxt;
reg                   mtsp_sw_cg0;
reg                   mtsp_cg0;

reg [1:0]             arcv_dbg_ctrl_r;
reg [1:0]             arcv_dbg_ctrl_nxt;
reg                   arcv_dbg_ctrl_cg0;

reg                   arcv_mecc_diagnostic_cg0;
reg [7:0]             arcv_mecc_diagnostic_sw_nxt;
reg [13:0]            arcv_mecc_diagnostic_nxt;
reg [13:0]            arcv_mecc_diagnostic_r;
reg [`ARCV_MC_CTL_RANGE] arcv_mcache_ctl_r;
reg [`ARCV_MC_CTL_RANGE] arcv_mcache_ctl_nxt;
reg                      arcv_mcache_ctl_cg0;

reg [`ARCV_MC_OP_RANGE] arcv_mcache_op_r;
reg [`ARCV_MC_OP_RANGE] arcv_mcache_op_nxt;
reg [`ARCV_MC_OP_RANGE] arcv_mcache_op_next;
reg                     arcv_mcache_op_cg0;
reg                     arcv_mcache_op_en;

reg [`ARCV_MC_ADDR_RANGE] arcv_mcache_addr_r;
reg [`ARCV_MC_ADDR_RANGE] arcv_mcache_addr_nxt;
reg                       arcv_mcache_addr_cg0;

reg [`ARCV_MC_LN_RANGE] arcv_mcache_lines_r;
reg [`ARCV_MC_LN_RANGE] arcv_mcache_lines_nxt;
reg                     arcv_mcache_lines_cg0;

reg [`DATA_RANGE]       arcv_mcache_data_r;
reg [`DATA_RANGE]       arcv_mcache_data_nxt;
reg                     arcv_mcache_data_cg0;

reg                     arcv_icache_op_init_r;
reg                     arcv_icache_op_init_nxt;



//==========================================================================//
// mcounteren                                                               //
//==========================================================================//
//
reg                   mcounteren_cg0;       // CSR inst will write

//==========================================================================//
// mcountinhibit                                                            //
//==========================================================================//
//
reg                   mcountinhibit_cg0;    // CSR inst will write

//==========================================================================//
// mcycle, mcycleh                                                          //
//==========================================================================//
//
reg [63:0]            mcycle_r;             // mcycle CSR
reg [63:0]            mcycle_inc;           // incremented mcycle_r
reg [63:0]            mcycle_nxt;           // next mcycle_r value
reg                   mcycle_g0_cg0;        // update mcycle_r[9:0]
reg                   mcycle_g1_cg0;        // update mcycle_r[31:10]
reg                   mcycle_g2_cg0;        // update mcycle_r[63:32]
reg                   mcycle_cg0;           // CSR inst writes
reg                   mcycleh_cg0;          // CSR inst writes
reg                   cyc_ovf_flag;

//==========================================================================//
// minstret, minstreth                                                      //
//==========================================================================//
//
reg [63:0]            minstret_r;           // minstret CSR
reg [63:0]            minstret_inc;         // incremented minstret_r
reg [63:0]            minstret_nxt;         // next minstret_r value
reg                   minstret_g0_cg0;      // update mcycle_r[9:0]
reg                   minstret_g1_cg0;      // update mcycle_r[31:10]
reg                   minstret_g2_cg0;      // update mcycle_r[63:32]
reg                   minstret_cg0;         // CSR inst will write
reg                   minstreth_cg0;         // CSR inst will write
reg                   ins_ovf_flag;

//==========================================================================//
// JVT                                                                      //
//==========================================================================//
//
reg [`DATA_RANGE]     arcv_ujvt_nxt;
reg                   arcv_ujvt_cg0;
wire [`DATA_RANGE]    arcv_iccm_build;
assign arcv_iccm_build = {20'b0,4'd8,8'd1};
wire [`DATA_RANGE]       arcv_icache_build;
assign arcv_icache_build = {9'd0,1'd0,1'b0,1'd0,4'd1,4'd3,4'd1,8'd1}; 

wire  [`DATA_RANGE] mstatush;
assign mstatush = 32'b0;
reg  [`DATA_RANGE] mxstate_r;
wire               resethaltreq;
//@@@
// Raised when core debug csr is not accessed through debugger
reg                core_debug_csr_illegal;
assign single_step   = dcsr_r[`DCSR_STEP_BIT]; 
assign stepie        = dcsr_r[`DCSR_STEPIE_BIT];
assign resethaltreq  = 1'b0;
// @@@

// Handy assignments
//
assign csr_x1_pass          = x1_pass       & (| x1_csr_ctl);
assign csr_x1_dst_id_valid  = (| x1_dst_id) & x1_csr_ctl[`CSR_CTL_READ];

assign csr_x1_read          =  x1_csr_ctl[`CSR_CTL_READ]
                            |  x1_csr_ctl[`CSR_CTL_SET]    // rmw
                            |  x1_csr_ctl[`CSR_CTL_CLEAR]  // rmw
                            ;
                            
assign csr_x1_write         = x1_csr_ctl[`CSR_CTL_WRITE] 
                            | x1_csr_ctl[`CSR_CTL_SET] 
                            | x1_csr_ctl[`CSR_CTL_CLEAR]
                            ;
assign csr_x1_addr          = x1_src1_data;
assign csr_x1_data          = x1_src0_data;

assign csr_x2_valid         = csr_x2_valid_r & x2_valid_r;
assign csr_x2_pass          = csr_x2_valid   & x2_pass;
assign csr_x2_dst_id_valid  = csr_x2_valid   & csr_x2_dst_id_valid_r;
assign csr_x2_mret          = csr_x2_valid   & csr_x2_ctl_r[`CSR_CTL_MRET];
assign csr_x2_mnret         = csr_x2_valid   & csr_x2_ctl_r[`CSR_CTL_MNRET];

assign csr_is_bcr           = (x1_src1_data >= 32'hFC0) & (x1_src1_data < 32'hFF0);
assign csr_raw_hazard       = (((csr_x1_addr == csr_x2_addr_r) | ((csr_x1_addr == `CSR_MIREG) && (csr_x2_addr_r == `CSR_MISELECT))) && csr_x2_wen)
                            | wdt_csr_raw_hazard
                            ;

assign mireg_rd_r              = 32'h0
                            | mireg_clint
                            ;


// X2
//
always @*
begin : csr_x2_PROC
  // Clock-gate
  //
  csr_x2_ctl_cg0    = csr_x1_pass | csr_x2_valid_r;  // @@@ power optimization
  csr_x2_data_cg0   = csr_x1_pass;
  csr_x2_addr_cg0   = csr_x1_pass & (| x1_csr_ctl);
                 
  csr_x2_valid_nxt  = csr_x1_pass;
  csr_x2_dst_id_nxt = x1_dst_id & {5{x1_csr_ctl[`CSR_CTL_READ]}};
end


// Result bus
//
always @*
begin : csr_rb_PROC
  // Clock-gate
  //
  csr_x2_rb_req_cg0 = (| x1_csr_ctl)
                    | csr_x2_rb_req_r
                    | x3_flush_r
                    ;

  
  // Request the result bus when a csr instruction is in X2 - Hold the request until we get the ack
  //
  csr_x2_rb_req_nxt = (csr_x1_pass      & csr_x1_dst_id_valid)
                    | ((csr_x2_rb_req_r & (~x2_csr_rb_ack)) & (~x3_flush_r));


end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// CSR ranges                                                         
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
// PMP  range; 0x3a0 - 0x3ef
//
reg       csr_pmp_range;
reg       csr_pmp_x2_write_r;
always @*
begin : csr_pmp_range_PROC
  // Inform PMP it needs to handle a CSR access
  //
  csr_pmp_range = (((csr_x1_addr >= 12'h3A0) && (csr_x1_addr <= 12'h3CF)) || (csr_x1_addr == 12'h747) || (csr_x1_addr == 12'h757));
  
  // The PMP CSRs are selected when there is a valid X1 CSR instruction in the PMP CSR range
  //
  csr_pmp_sel_ctl[0] = csr_x1_read  & csr_pmp_range;
  csr_pmp_sel_ctl[1] = csr_x1_write & csr_pmp_range;
  
  csr_pmp_sel_addr   = csr_x1_addr;
end

reg       csr_trig_range;
reg       csr_trig_x2_write_r;
always @*
begin : csr_trig_range_PROC
  // Inform PMP it needs to handle a CSR access
  //
  csr_trig_range = ((csr_x1_addr >= 12'h7A0) && (csr_x1_addr <= 12'h7A4)) ;
  
  // The PMP CSRs are selected when there is a valid X1 CSR instruction in the PMP CSR range
  //
  csr_trig_sel_ctl[0] = csr_x1_read  & csr_trig_range;
  csr_trig_sel_ctl[1] = csr_x1_write & csr_trig_range;
  
  csr_trig_sel_addr   = csr_x1_addr;
end

// PMA  range; 0x3a0 - 0x3ef @@@
//
reg       csr_pma_range;
reg       csr_pma_x2_write_r;
always @*
begin : csr_pma_range_PROC
  // Inform PMA it needs to handle a CSR access
  //
  csr_pma_range = (((csr_x1_addr >= 12'h7D8) && (csr_x1_addr <= 12'h7DF)) || (csr_x1_addr == 12'h7CE) || (csr_x1_addr == 12'h7CF));
  
  // The PMA CSRs are selected when there is a valid X1 CSR instruction in the PMA CSR range
  //
  csr_pma_sel_ctl[0] = csr_x1_read  & csr_pma_range;
  csr_pma_sel_ctl[1] = csr_x1_write & csr_pma_range;
  
  csr_pma_sel_addr   = csr_x1_addr;
end


// ICCM  range; 0x7C0
//
reg       csr_iccm_range;
reg       csr_iccm_x2_write_r;
always @*
begin : csr_iccm_range_PROC
  // Inform ICCM it needs to handle a CSR access
  //
  csr_iccm_range = (csr_x1_addr == 12'h7C0);
  
  // The PMP CSRs are selected when there is a valid X1 CSR instruction in the ICCM CSR range
  //
  csr_iccm_sel_ctl[0] = csr_x1_read  & csr_iccm_range;
  csr_iccm_sel_ctl[1] = csr_x1_write & csr_iccm_range;
  
  csr_iccm_sel_addr   = csr_x1_addr[7:0];
end

// DCCM      range; 0x7C2
// PER0_BASE range; 0x7C6
// PER0_SIZE range; 0x7C7
reg       csr_dmp_range;
reg       csr_dmp_x2_write_r;
always @*
begin : csr_dmp_range_PROC
  // Inform DMP it needs to handle a CSR access
  //
  csr_dmp_range = 1'b0
                | (csr_x1_addr == 12'h7C2)
                | (csr_x1_addr == 12'h7C6) | (csr_x1_addr == 12'h7C7)
                ;
  
  // The DMP CSRs are selected when there is a valid X1 CSR instruction in the DMP CSR range
  //
  csr_dmp_sel_ctl[0] = csr_x1_read  & csr_dmp_range;
  csr_dmp_sel_ctl[1] = csr_x1_write & csr_dmp_range;
  
  csr_dmp_sel_addr   = csr_x1_addr[7:0];
end

// SAFETY  range 1 RW; 0x7F0 - 0x7F7
// SAFETY  range 2 RO; 0xFF8 - 0xFFB
reg       csr_sfty_range1;
reg       csr_sfty_range2;
reg       csr_sfty_range;
reg       csr_sfty_x2_write_r;
always @*
begin : csr_sfty_range_PROC
  // Inform SAFETY it needs to handle a CSR access
  //
  csr_sfty_range1 = (csr_x1_addr >= 12'h7F0) && (csr_x1_addr <= 12'h7F7);
  csr_sfty_range2 = (csr_x1_addr >= 12'hFF8) && (csr_x1_addr <= 12'hFFB);
  csr_sfty_range = csr_sfty_range1 || csr_sfty_range2;
  
  // The SAFETY CSRs are selected when there is a valid X1 CSR instruction in the SAFETY CSR range
  //
  csr_sfty_sel_ctl[0] = csr_x1_read  & csr_sfty_range;
  csr_sfty_sel_ctl[1] = csr_x1_write & csr_sfty_range;
  
  csr_sfty_sel_addr   = csr_x1_addr;
end


// WDT CSR  range : 0x7D0, 0x7D1, 0x7D3 ~ 0x7D6, 0xFFC, 0xFC0
reg       csr_wdt_range;
reg       csr_wdt_x2_write_r;
always @*
begin : csr_wdt_range_PROC
  // Inform WDT it needs to handle a CSR access
  //
  csr_wdt_range = (csr_x1_addr == 12'h7D0) || (csr_x1_addr == 12'h7D1) || ((csr_x1_addr >= 12'h7D3) && (csr_x1_addr <= 12'h7D6)) || (csr_x1_addr == 12'hFFC) || (csr_x1_addr == 12'hFC0);
  
  // The WDT CSRs are selected when there is a valid X1 CSR instruction in the WDT CSR range
  //
  csr_wdt_sel_ctl[0] = csr_x1_read  & csr_wdt_range;
  csr_wdt_sel_ctl[1] = csr_x1_write & csr_wdt_range;
  
  csr_wdt_sel_addr   = csr_x1_addr[11:0];
end


// HPM CSR  range : 0x106 0x306 0x320 0x323 ~ 0x33F, 0xB00, 0xB02, 0xB03 ~ 0xB1F, 0xB80, 0xB82, 0xB83 ~ 0xB9F, 0xC00, 0xC02,  0xC03 ~ 0xC1F, 0xC80, 0xC82, 0xC83 ~ 0xC9F, 0x7D7, 0x7E8, 0x7E9, 0xFC3, 0xFF4 ~ 0xFF7 
reg       csr_hpm_x2_write_r;
always @*
begin : csr_hpm_range_PROC
  // Inform HPM it needs to handle a CSR access
  //
  csr_hpm_range = (csr_x1_addr == 12'h106) || (csr_x1_addr == 12'h306) || (csr_x1_addr == 12'h320) || ((csr_x1_addr >= 12'h323) && (csr_x1_addr <= 12'h33F)) || (csr_x1_addr == 12'hB00) || (csr_x1_addr == 12'hB02) || ((csr_x1_addr >= 12'hB03) && (csr_x1_addr <= 12'hB1F)) || (csr_x1_addr == 12'hB80) || (csr_x1_addr == 12'hB82) || ((csr_x1_addr >= 12'hB83) && (csr_x1_addr <= 12'hB9F)) || (csr_x1_addr == 12'hC00) || (csr_x1_addr == 12'hC02) || ((csr_x1_addr >= 12'hC03) && (csr_x1_addr <= 12'hC1F)) || (csr_x1_addr == 12'hC80) || (csr_x1_addr == 12'hC82) || ((csr_x1_addr >= 12'hC83) && (csr_x1_addr <= 12'hC9F)) || (csr_x1_addr == 12'h7D7) || (csr_x1_addr == 12'h7E8) || (csr_x1_addr == 12'h7E9) || (csr_x1_addr == 12'hFC3) || ((csr_x1_addr >= 12'hFF4) && (csr_x1_addr <= 12'hFF7));
  
  // The HPM CSRs are selected when there is a valid X1 CSR instruction in the HPM CSR range
  //
  csr_hpm_sel_ctl[0] = csr_x1_read  & csr_hpm_range;
  csr_hpm_sel_ctl[1] = csr_x1_write & csr_hpm_range;
  
  csr_hpm_sel_addr   = csr_x1_addr[11:0];
end

// CLINT CSR RANGE
// 0x303, 0x304, 0x308, 0x309, 0x313, 0x314, 0x318, 0x319, 0x344, 0x350, 0x351, 0x354, 0x35C, 0x7FF, 0xFB0
reg       csr_clint_range;
reg       icsr_clint_range;
reg       csr_clint_x2_write_r;
always @*
begin : csr_clint_range_PROC
  // Inform CLINT it needs to handle a CSR access
  //
  csr_clint_range = 1'b0
                  | (csr_x1_addr == `CSR_MIDELEG)
				  | (csr_x1_addr == `CSR_MIE)
				  | (csr_x1_addr == `CSR_MVIEN)
				  | (csr_x1_addr == `CSR_MVIP)
				  | (csr_x1_addr == `CSR_MIDELEGH)
				  | (csr_x1_addr == `CSR_MIEH)
				  | (csr_x1_addr == `CSR_MVIENH)
				  | (csr_x1_addr == `CSR_MVIPH)
				  | (csr_x1_addr == `CSR_MIP)
				  | (csr_x1_addr == `CSR_MIPH)
				  | (csr_x1_addr == `CSR_MTOPEI)
				  | (csr_x1_addr == `CSR_MTSP)
				  | (csr_x1_addr == `CSR_MTOPI)
				  ;

  icsr_clint_range = 1'b0
                   | ((miselect_r > 32'h2F) && (miselect_r < 32'h40))
                   | ((miselect_r > 32'h6F) && (miselect_r < 32'h82))
                   | ((miselect_r > 32'hBF) && (miselect_r < 32'hC2))
                   ;
  
  // The CLINT CSRs are selected when there is a valid X1 CSR instruction in the CLINT CSR range
  //
  csr_clint_sel_ctl[0] = csr_x1_read  & csr_clint_range;
  csr_clint_sel_ctl[1] = csr_x1_write & csr_clint_range;
  
  csr_clint_sel_addr   = csr_x1_addr[11:0];
end


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// CSR X1 Read mux                                                             
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

reg [`DATA_RANGE]  core_csr_rdata;
reg                core_csr_unimpl;
reg                core_csr_illegal;
reg                core_csr_serial_sr;
reg                core_csr_strict_sr;

always @*
begin : csr_read_mux_PROC
  core_csr_rdata     = `DATA_SIZE'd0;
  core_csr_unimpl    = 1'b0;
  core_csr_illegal   = 1'b0;
  core_csr_serial_sr = 1'b0;
  core_csr_strict_sr = 1'b0;
  csr_stall          = 1'b0;

  if (| x1_csr_ctl[3:0]) // (csr_x1_read == 1'b1)
  begin
    case (csr_x1_addr)
    
    
    // Machine Mode CSRs
    //

    `CSR_MSTATUS:  
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mstatus_r;       
    end

//!BCR { num: 784, val: 1024, name: "MSTATUSH" }
    `CSR_MSTATUSH:  
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = {21'b0, mdt_r, 10'b0};       
    end

    `CSR_MNSTATUS:  
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = {mnstatus_r[31:1], rnmi_synch_r};       
    end

    `CSR_MLWID:  
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = {27'b0, mlwid_r};       
    end

    `CSR_MWIDDELEG:  
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = 32'h0;       
    end

    
//!BCR { num: 769, val: 1083183365, name: "MISA" }
    `CSR_MISA:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = {2'b01, 6'b0, 1'b`HAS_CLINT, 4'b0010, 1'b`RV_S_OPTION, 5'b0, 1'b`RV_M_OPTION, 7'b0001000, 1'b`RV_E_OPTION, 1'b0, 1'b`RV_C_OPTION, 1'b0, 1'b`RV_A_OPTION};       
    end

    `CSR_MISELECT:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = miselect_r;       
    end

    `CSR_MIREG:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M
                       ;
      core_csr_unimpl  = 1'b1
                       & (~icsr_clint_range)
                       ;
      core_csr_rdata   = mireg_rd_r;       
    end

              
    `CSR_MTVEC:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mtvec_r;       
    end
    
    `CSR_MSCRATCH:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mscratch_r;       
    end    
    
    `CSR_MEPC:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mepc_r;        
    end
    
    `CSR_MCAUSE:          
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mcause_r;      
    end

    `CSR_MNSCRATCH:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mnscratch_r;       
    end    
    
    `CSR_MNEPC:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mnepc_r;        
    end
    
    `CSR_MNCAUSE:          
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mncause_r;
    end
    
    `CSR_MTVAL:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mtval_r;       
    end

    `CSR_MTVAL2:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = 32'h0;       
    end

    `CSR_MTINST:           
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = 32'h0;       
    end
    
    `CSR_MVENDORID:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
    end
//!BCR { num: 3858, val: 2147484673, name: "MARCHID" }
    `CSR_MARCHID:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata   = 32'd2147484673; 
    end
//!BCR { num: 3859, val: 65792, name: "MIMPID" }
    `CSR_MIMPID:      
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata   = 65792; 
    end
//!BCR { num: 3860, val: 0, name: "MHARTID" }
    `CSR_MHARTID:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata   = {24'b0, arcnum};
    end
//!BCR { num: 3861, val: 0, name: "MCONFIGPTR" }
    `CSR_MCONFIGPTR:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata   = 32'h0;
    end
    `CSR_MTSP:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = mtsp_r; 
    end
    `CSR_MENVCFG:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = menvcfg_r;       
    end
    `CSR_MENVCFGH:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = 32'h0;       
    end
    `CSR_MCOUNTEREN: 
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata[`CNT_CTRL_RANGE] = mcounteren_r;
    end
    `CSR_MCOUNTINHIBIT: 
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata[`CNT_CTRL_RANGE] = mcountinhibit_r;
    end
    
    `CSR_MCYCLE: 
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M);
      core_csr_rdata = mcycle_r[`DATA_RANGE];
    end
    `CSR_MCYCLEH:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M);
      core_csr_rdata = mcycle_r[63:32];
    end

    `CSR_CYCLE: 
    begin
      core_csr_illegal = ((priv_level_r != `PRIV_M) & (~mcounteren_r[0])) | csr_x1_write;
      core_csr_rdata = mcycle_r[`DATA_RANGE];
    end
    `CSR_CYCLEH:
    begin
      core_csr_illegal = ((priv_level_r != `PRIV_M) & (~mcounteren_r[0])) | csr_x1_write;
      core_csr_rdata = mcycle_r[63:32];
    end

    `CSR_TIME: 
// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals
    begin
      core_csr_illegal = ((priv_level_r != `PRIV_M) & (~mcounteren_r[1])) | csr_x1_write;
      core_csr_rdata = mtime_r[`DATA_RANGE];
    end
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
    `CSR_TIMEH:
    begin
      core_csr_illegal = ((priv_level_r != `PRIV_M) & (~mcounteren_r[1])) | csr_x1_write;
      core_csr_rdata = mtime_r[63:32];
    end

    `CSR_MINSTRET: 
    begin 
      core_csr_illegal = (priv_level_r != `PRIV_M);
      core_csr_rdata = minstret_r[`DATA_RANGE];
    end
    `CSR_MINSTRETH:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M);
      core_csr_rdata = minstret_r[63:32];
    end

    `CSR_INSTRET: 
    begin 
      core_csr_illegal = ((priv_level_r != `PRIV_M) & (~mcounteren_r[2])) | csr_x1_write;
      core_csr_rdata = minstret_r[`DATA_RANGE];
    end
    `CSR_INSTRETH:
    begin
      core_csr_illegal = ((priv_level_r != `PRIV_M) & (~mcounteren_r[2])) | csr_x1_write;
      core_csr_rdata = minstret_r[63:32];
    end

   `CSR_MECC_DIAG:
   begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata    = {18'b0,arcv_mecc_diagnostic_r};
   end

   `CSR_ARCV_MESB_CTRL:
   begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata    = {30'b0,arcv_mesb_ctrl_r};
   end


//!BCR { num: 1992, val: 3, name: "MCACHE_CTL" }
    `CSR_MCACHE_CTL:
    begin
      core_csr_illegal    = priv_level_r != `PRIV_M;
      core_csr_rdata[4:0] = arcv_mcache_ctl_r[4:0];
      core_csr_serial_sr  = 1'b0;
      core_csr_strict_sr  = csr_x1_write;
    end

    `CSR_MCACHE_OP:
    begin
      core_csr_illegal   = priv_level_r != `PRIV_M;
      core_csr_rdata     = {1'b0, arcv_mcache_op_r[24], 6'b0, arcv_mcache_op_r[23:0]};
      core_csr_serial_sr = 1'b0;
      core_csr_strict_sr = csr_x1_write;
    end
   
    `CSR_MCACHE_ADDR:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata     = {arcv_mcache_addr_r, 2'b0};
    end

    `CSR_MCACHE_LINES:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata   = {`ARCV_MC_LN_RESV'b0, arcv_mcache_lines_r};
    end

    `CSR_MCACHE_DATA:
    begin
      core_csr_illegal = priv_level_r != `PRIV_M;
      core_csr_rdata     = arcv_mcache_data_r;
    end
    
//!BCR { num: 4049, val: 78081, name: "ARCV_ICACHE_BUILD" }
    `BCR_ARCV_IC_BCR:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata      = arcv_icache_build;
    end




//!BCR { num: 4050, val: 2049, name: "ARCV_ICCM_BUILD" }
    `BCR_ARCV_ICCM_BCR:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata      = arcv_iccm_build;
    end
    `CSR_UJVT:
    begin
        core_csr_rdata     = arcv_ujvt_r;
    end


// BCR starts
//!BCR { num: 4043, val: 1, name: "ARCV_BCR_BUILD" }
    `BCR_ARCV_BCR: 
    begin
        core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
        core_csr_rdata = {24'b0, 8'b1};
    end

//!BCR { num: 4038, val: 1140850689, name: "ARCV_MSFTY_BUILD" }
    `BCR_ARCV_SFTY_BCR: 
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {
                                         1'h0                                       , // 31 Unused          
                                         1'b`HW_ERROR_INJECTION                     , // 30
                                         1'b0                                       , // 29 Unused
                                         3'd`SBE_ADDR_DEPTH                         , // 28:26        
                                         6'h0                                       , // 25:20 Unused          
                                         2'd`CPU_SAFETY                             , // 19:18        
                                         9'h0                                       , // 17:9 Unused          
                                         1'h0                                       , // 8    Unused
                                         8'h1                                 // 7:0          
                                         };           
    end

//!BCR { num: 4044, val: 659457, name: "ARCV_PMP_BUILD" }
    `BCR_ARCV_PMP_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {12'd0, 3'd5, 1'd`HAS_S_MODE, 8'd`PMP_ENTRIES, 8'd1};
    end
//!BCR { num: 4046, val: 1537, name: "ARCV_PMA_BUILD" }
    `BCR_ARCV_PMA_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {16'h0, 8'd`PMA_ENTRIES, 8'd1};
    end

//!BCR { num: 4059, val: 2147491841, name: "ARCV_SEC_BUILD" }
    `BCR_ARCV_SEC_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {1'b`WID_MODE, 7'b0, 8'd0, 8'd`WID_NUM, 8'd1};
    end

//!BCR { num: 4042, val: 3758161921, name: "ARCV_TIMER_BUILD" }
    `BCR_ARCV_TIMER_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {core_mmio_base_r, 8'h10, 3'b0, 1'b`RTIA_SSTC, 8'd1};
    end


//!BCR { num: 4052, val: 268435731, name: "ARCV_CLINT_BUILD" }
    `BCR_ARCV_CLINT_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {4'd1, 19'd0, 1'b1, 2'b0, 2'd1, 1'b`RTIA_SSWI, 1'b`RTIA_SSTC, 1'b`RTIA_SNVI, 1'b`RTIA_STSP};
    end
//!BCR { num: 4053, val: 268500993, name: "ARCV_IMSIC_BUILD" }
    `BCR_ARCV_IMSIC_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {4'd1, 7'd0, 1'b`SMALL_INTERRUPT, 4'd1, 4'b0, 4'b0, 4'b0, 4'd1};
    end

//!BCR { num: 4057, val: 513, name: "ARCV_TRIGGERS_BUILD" }
    `BCR_ARCV_TRIGGERS_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {20'd0, 4'd2, 8'd1};
    end

//!BCR { num: 4033, val: 3584, name: "ARCV_MMIO_BUILD" }
    `BCR_ARCV_MMIO_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {20'h0, core_mmio_base_r};
    end

//!BCR { num: 4062, val: 53746657, name: "ARCV_ISA_OPTS_BUILD" }
    `BCR_ARCV_ISA_OPTS_BUILD:
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {6'd0,
                          1'b`LD_ST_UNALIGNED, //Unaligned load/store
						  1'b`RV_ZCSR_OPTION, //Zicsr
						  1'b0, //Zic64rs
                          1'b0, //Ziccamoa
                          1'b1, //Zicbop
                          1'b1, //Zicbom
						  1'b0, //Zhinx
						  1'b`RV_C_OPTION, //Zca
                          1'b0, //Zk
                          1'b0, //Zfh
                          1'b0, //Zfa
                          1'b`RV_D_OPTION, //Zdinx
                          1'b`RV_F_OPTION, //Zfinx
                          1'b`RV_ZICOND_OPTION, //Zicond
                          1'b`RV_ZBS_OPTION, //Zbs
                          1'b0, //Zbc
                          1'b`RV_ZBB_OPTION, //Zbb
                          1'b`RV_ZBA_OPTION, //Zba
                          1'b`RV_C_OPTION, //Zcmt
                          1'b`RV_C_OPTION, //Zcmp
                          1'b`RV_C_OPTION, //Zcb
                          5'b1 //RMX baseline
        };
    end

    `BCR_ARCV_DCCM_BUILD:
    begin
      core_csr_rdata   = {
                       12'd0,         // reserved
                       3'd1,          // cycles
                       5'd0,          // reserved
                       4'd9, // size
                       8'd1           // version
                         };
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
    end
//!BCR { num: 4048, val: 133377, name: "ARCV_DCCM_BUILD" }


    

    `BCR_ARCV_DMP_PER_BUILD: 
    begin
      core_csr_rdata    = {
                        12'd0,           // reserved
                        12'd`PER0_SIZE,  // size
                        8'd1             // version
                          };
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
    end
//!BCR { num: 4061, val: 257, name: "ARCV_DMP_PER_BUILD" }



//!BCR { num: 4064, val: 800257, name: "ARCV_RAS_BUILD" }
    `BCR_ARCV_RAS_BCR: 
    begin
      core_csr_illegal = (priv_level_r != `PRIV_M) | csr_x1_write;
      core_csr_rdata = {12'b0, 1'b1 , 2'd2 , 3'b0 , 1'b1 , 2'd2 , 1'b1 , 2'd2 , 8'b1};
    end

    `CSR_DCSR:
    begin
      core_csr_unimpl = ~debug_mode_r;
      core_csr_rdata = {4'h4, 8'b0, dcsr_r[`DCSR_CETRIG_BIT], 1'b0, 1'b0, 1'b0, dcsr_r[`DCSR_EBM_BIT], 1'b0, 1'b0, dcsr_r[`DCSR_EBU_BIT], dcsr_r[`DCSR_STEPIE_BIT], 1'b0, 1'b0, dcsr_r[`DCSR_CAUSE_RANGE], 1'b0, dcsr_r[`DCSR_MPRVEN_BIT], rnmi_synch_r, dcsr_r[`DCSR_STEP_BIT], dcsr_r[`DCSR_PRV_RANGE]};
    end

    `CSR_DPC:
    begin
      core_csr_unimpl = ~debug_mode_r;
      core_csr_rdata = dpc_r;
    end

    `CSR_ARCV_DBG_CTRL:
    begin
      core_csr_unimpl = ~debug_mode_r;
      core_csr_rdata = {30'b0, arcv_dbg_ctrl_r[1:0]};
    end
    `CSR_ARCV_SR_EPC, `CSR_ARCV_SR_MSTATUS, `CSR_ARCV_SR_MSTATUSH, `CSR_ARCV_SR_XSTATE:
    begin
      core_csr_illegal = sr_aux_illegal;
      core_csr_rdata = sr_aux_rdata;
    end

    default:
    begin
        core_csr_unimpl  = (~csr_is_bcr);
        core_csr_illegal = (csr_x1_write | (priv_level_r != `PRIV_M)) & csr_is_bcr;   // BCR region is read-only, even this address is not used
    end
    endcase
  end
end

// spyglass disable_block Ac_conv01
// SMD: Checks combinational convergence of same-domain signals synchronized in the same destination domain
// SJ: Reset/NMI are independent, both of them will impact soft reset register and reflect in sr_saved_*, that's intended
always @*
begin : csr_read_PROC
  // OR mux

  csr_rdata = core_csr_rdata
            | pmp_csr_rdata
            | trig_csr_rdata
            | pma_csr_rdata
            | sfty_csr_rdata
            | wdt_csr_rdata
            | hpm_csr_rdata
            | clint_csr_rdata
            | iccm_csr_rdata
            | dmp_csr_rdata
            ;

  csr_serial_sr = core_csr_serial_sr
                | pmp_csr_serial_sr
                | pma_csr_serial_sr
                | sfty_csr_serial_sr
                | wdt_csr_serial_sr
            | hpm_csr_serial_sr
                | clint_csr_serial_sr
                | trig_csr_serial_sr
                | iccm_csr_serial_sr
                | dmp_csr_serial_sr
                ;

  csr_strict_sr = core_csr_strict_sr
                | pmp_csr_strict_sr
                | pma_csr_strict_sr
                | sfty_csr_strict_sr
                | wdt_csr_strict_sr
            | hpm_csr_strict_sr
                | clint_csr_strict_sr
                | trig_csr_strict_sr
                | iccm_csr_strict_sr
                | dmp_csr_strict_sr
                ;

  csr_unimpl = core_csr_unimpl
              & pmp_csr_unimpl
              & trig_csr_unimpl
              & pma_csr_unimpl
              & sfty_csr_unimpl
            & wdt_csr_unimpl
            & hpm_csr_unimpl
            & clint_csr_unimpl
              & iccm_csr_unimpl
              & dmp_csr_unimpl
              ;


  csr_illegal = (csr_unimpl
              | core_csr_illegal
              | pmp_csr_illegal
              | trig_csr_illegal
              | pma_csr_illegal
              | sfty_csr_illegal
              | wdt_csr_illegal
            | hpm_csr_illegal
              | clint_csr_illegal
              | iccm_csr_illegal
              | dmp_csr_illegal
              ) & (~debug_mode_r)
              ;
end
// spyglass enable_block Ac_conv01

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Mux read/write data                                                     
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_wdata_PROC
  if (csr_x2_ctl_r[`CSR_CTL_SET])
    csr_x2_wdata =  csr_x2_data_r   | x2_src0_data_r;
  else if (csr_x2_ctl_r[`CSR_CTL_CLEAR])
    csr_x2_wdata = csr_x2_data_r & (~x2_src0_data_r);
  else
    csr_x2_wdata = 
                    db_write ? db_wdata : 
                                        x2_src0_data_r;
end


assign csr_x2_wen = csr_x2_ctl_r[`CSR_CTL_WRITE] 
                  | csr_x2_ctl_r[`CSR_CTL_SET] 
                  | csr_x2_ctl_r[`CSR_CTL_CLEAR];

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// CSR Write mux                                                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_write_PROC
  // Default statements
  //
  csr_x2_write_pc   = 1'b0;
  
  
  mcounteren_cg0    = 1'b0;
  mcountinhibit_cg0 = 1'b0;

  mcycle_cg0        = 1'b0;
  mcycleh_cg0       = 1'b0;
  minstret_cg0      = 1'b0;
  minstreth_cg0     = 1'b0;
  
  mtvec_cg0         = 1'b0;
  mtvec_nxt         = mtvec_r;
  mlwid_cg0         = 1'b0;
  mlwid_nxt         = mlwid_r;

  mscratch_cg0      = 1'b0;
  mscratch_nxt      = mscratch_r;

  menvcfg_cg0       = 1'b0;
  menvcfg_nxt       = menvcfg_r;

  miselect_cg0      = 1'b0;
  miselect_nxt      = miselect_r;

  mireg_cg0         = 1'b0;
  mireg_clint_wen   = 1'b0;

  
  mstatus_sw_cg0    = 1'b0;
  mstatus_sw_nxt    = mstatus_r;

  mdt_sw_cg0        = 1'b0;
  mdt_sw_nxt        = mdt_r;
  
  mcause_sw_cg0     = 1'b0;
  mcause_sw_nxt     = mcause_r;

  mnscratch_cg0     = 1'b0;
  mnscratch_nxt     = mnscratch_r;
  
  mnstatus_sw_cg0   = 1'b0;
  mnstatus_sw_nxt   = mnstatus_r;
  
  mncause_sw_cg0    = 1'b0;
  mncause_sw_nxt    = mncause_r;
  
  mtval_sw_cg0      = 1'b0;
  mtval_sw_nxt      = mtval_r;
  mtsp_sw_cg0       = 1'b0;
  mtsp_sw_nxt       = mtsp_r;
  
  mepc_sw_cg0       = 1'b0;
  mepc_sw_nxt       = mepc_r;
  mnepc_sw_cg0      = 1'b0;
  mnepc_sw_nxt      = mnepc_r;

  arcv_mecc_diagnostic_cg0       = 1'b0;
  arcv_mecc_diagnostic_sw_nxt    = arcv_mecc_diagnostic_r[7:0];
  arcv_mesb_ctrl_cg0      = 1'b0;
  arcv_mesb_ctrl_nxt      = arcv_mesb_ctrl_r;
  arcv_mcache_ctl_cg0     = 1'b0;
  arcv_mcache_ctl_nxt     = arcv_mcache_ctl_r;   
  arcv_mcache_op_cg0      = 1'b0;
  arcv_mcache_op_nxt      = arcv_mcache_op_r;    
  arcv_mcache_addr_cg0    = 1'b0;
  arcv_mcache_addr_nxt    = arcv_mcache_addr_r;  
  arcv_mcache_lines_cg0   = 1'b0;
  arcv_mcache_lines_nxt   = arcv_mcache_lines_r; 
  arcv_mcache_data_cg0    = 1'b0;
  arcv_mcache_data_nxt    = arcv_mcache_data_r;  
  arcv_icache_op_init_nxt = arcv_icache_op_init_r;


  arcv_ujvt_cg0         = 1'b0;
  arcv_ujvt_nxt         = arcv_ujvt_r;
  arcv_dbg_ctrl_cg0     = 1'b0;
  arcv_dbg_ctrl_nxt     = 2'b0;
  
  
  if (csr_x2_wen == 1'b1)
  begin
    case (csr_x2_addr_r)
    
   
    `CSR_MSTATUS:
    begin
      mstatus_sw_cg0 = x2_pass;
      mstatus_sw_nxt = {10'b0, csr_x2_wdata[`TW], 3'b0, csr_x2_wdata[`MPRV], 4'b0, csr_x2_wdata[`MPP_RANGE], 3'b0, csr_x2_wdata[`MPIE], 3'b0, 
                        (mdt_r ? (mstatus_r[`MIE] & csr_x2_wdata[`MIE]) : csr_x2_wdata[`MIE])
                        , 3'b0};
      
      // Take care of the bits not implemented 
      // @@@@ 
      // @@@ exc/int when a CSR write to mstatus is in the X2(commit) stage
      
    end

    `CSR_MSTATUSH:
    begin
      mdt_sw_cg0 = x2_pass;
      mdt_sw_nxt = csr_x2_wdata[10];
    end

    `CSR_MNSTATUS:
    begin
      mnstatus_sw_cg0 = x2_pass;
      mnstatus_sw_nxt = {19'b0, csr_x2_wdata[12:11], 7'b0, (csr_x2_wdata[3] | mnstatus_r[3]), 2'b0, mnstatus_r[0]};
    end
         
    `CSR_MTVEC:
    begin
      mtvec_cg0 = x2_pass;
      if (csr_x2_wdata[1])
      begin
        mtvec_nxt = {csr_x2_wdata[`ADDR_MSB:2], 2'b11};
      end
      else
      begin
        mtvec_nxt = csr_x2_wdata;
      end
    end
    `CSR_MLWID:
    begin
      mlwid_cg0 = x2_pass;
      mlwid_nxt = csr_x2_wdata[`WID_RANGE];
    end

   `CSR_MSCRATCH:
    begin
      mscratch_cg0 = x2_pass;
      mscratch_nxt = csr_x2_wdata;
    end
    
    `CSR_MISELECT:
    begin
      miselect_cg0       = x2_pass;
      miselect_nxt       = csr_x2_wdata;
    end
         
    `CSR_MIREG:
    begin
      mireg_clint_wen = x2_pass && icsr_clint_range;
      mireg_cg0 = x2_pass;
    end

    
    `CSR_MEPC:
    begin
      mepc_sw_cg0 = x2_pass;
      mepc_sw_nxt = csr_x2_wdata;
    end       
    
    `CSR_MCAUSE:
    begin
      mcause_sw_cg0 = x2_pass;
      mcause_sw_nxt = (csr_x2_wdata > 5'd30) ? mcause_r : csr_x2_wdata;
    end      

    `CSR_MNSCRATCH:
    begin
      mnscratch_cg0 = x2_pass;
      mnscratch_nxt = csr_x2_wdata;
    end
    
    `CSR_MNEPC:
    begin
      mnepc_sw_cg0 = x2_pass;
      mnepc_sw_nxt[`PC_RANGE] = csr_x2_wdata[`PC_RANGE];
    end       
    
    `CSR_MNCAUSE:
    begin
      mncause_sw_cg0 = x2_pass;
      mncause_sw_nxt = csr_x2_wdata;
    end
    
    `CSR_MTVAL:
    begin
      mtval_sw_cg0  = x2_pass;
      mtval_sw_nxt  = csr_x2_wdata;
    end

    `CSR_MTSP:
    begin
        mtsp_sw_cg0 = x2_pass;
        mtsp_sw_nxt = csr_x2_wdata;
    end
    
         
    `CSR_MCOUNTEREN:      mcounteren_cg0    = x2_pass;   
    `CSR_MCOUNTINHIBIT:   mcountinhibit_cg0 = x2_pass;
    `CSR_MENVCFG:
    begin
      menvcfg_cg0                = x2_pass;
      menvcfg_nxt                = {23'b0, csr_x2_wdata[8], 1'b0, csr_x2_wdata[6:4], 3'b0, csr_x2_wdata[0]};
    end
    
    `CSR_MCYCLE:          mcycle_cg0  = x2_pass;    
    `CSR_MCYCLEH:         mcycleh_cg0 = x2_pass; 
    `CSR_MINSTRET:        minstret_cg0  = x2_pass;
    `CSR_MINSTRETH:       minstreth_cg0 = x2_pass; 

    `CSR_MECC_DIAG:
    begin
      arcv_mecc_diagnostic_cg0         = x2_pass;
      arcv_mecc_diagnostic_sw_nxt[7:0] = csr_x2_wdata[7:0];
    end

    `CSR_ARCV_MESB_CTRL:
    begin
      arcv_mesb_ctrl_cg0               = x2_pass;
      arcv_mesb_ctrl_nxt               = csr_x2_wdata[1:0];
    end

    `CSR_MCACHE_CTL:
    begin
      arcv_mcache_ctl_cg0      = x2_pass;
      arcv_mcache_ctl_nxt[4:0] = {csr_x2_wdata[4:3],(csr_x2_wdata[2]&(~csr_x2_wdata[1])), ((~csr_x2_wdata[2])&(csr_x2_wdata[1])),csr_x2_wdata[0]};
    end
    `CSR_MCACHE_OP:
    begin
      arcv_mcache_op_cg0         = x2_pass;
      arcv_mcache_op_nxt[23:0]   = csr_x2_wdata[23:0];
      // I-Cache Operation when csr_x2_wdata <= 9
      arcv_icache_op_init_nxt    = x2_pass 
                                 & (   (csr_x2_wdata[23:4] == 20'b0)
                                     & ((csr_x2_wdata[3] == 1'b1) 
                                        ? (csr_x2_wdata[2:1] == 2'b00) 
                                        : (csr_x2_wdata[2:0] != 3'b000))); 
    end
    `CSR_MCACHE_ADDR:
    begin
      arcv_mcache_addr_cg0    = x2_pass;
      arcv_mcache_addr_nxt    = csr_x2_wdata[31:2];
    end
    `CSR_MCACHE_LINES:
    begin
      arcv_mcache_lines_cg0    = x2_pass;
      arcv_mcache_lines_nxt    = (csr_x2_wdata[`ARCV_MC_LN_RANGE] > `ARCV_MC_MAX_LINES) ? `ARCV_MC_MAX_LINES : csr_x2_wdata[`ARCV_MC_LN_RANGE];
    end
    `CSR_MCACHE_DATA:
    begin
      arcv_mcache_data_cg0    = x2_pass;
      arcv_mcache_data_nxt    = csr_x2_wdata;
    end
    `CSR_UJVT:
    begin
        arcv_ujvt_cg0 = x2_pass;
        arcv_ujvt_nxt = csr_x2_wdata;
    end
    `CSR_ARCV_DBG_CTRL:
    begin
      if (db_active == 1'b1)
      begin
        arcv_dbg_ctrl_cg0 = x2_pass; 
        arcv_dbg_ctrl_nxt = csr_x2_wdata[1:0]; 
      end
    end
    `CSR_DCSR:
    begin
      if (debug_mode == 1'b0)
      begin
        core_debug_csr_illegal = 1'b1;
      end
    end
    `CSR_DPC:
    begin
      if (debug_mode == 1'b0)
      begin
        core_debug_csr_illegal = 1'b1;
      end
      else
      begin
        csr_x2_write_pc = 1'b1;
      end
    end
    
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue.
    default: ;
// spyglass enable_block W193 
    endcase
  end
  
end

reg csr_x1_serial_valid;

reg csr_x2_strict_sr_r;
reg csr_x2_serial_sr_r;

reg csr_flush_cg0;
reg csr_flush_nxt;

//////////////////////////////////////////////////////////////////////////////////////////
//  Write serialization
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_flush_PROC
  // There are two types of serialization: normal and strict
  // Back to back normal serialization only flushes the pipeline once, whereas a strict serialization
  // always flush the pipeline upon commit of the CSR write instruction
  //
  csr_flush_cg0       = csr_x2_pass | csr_flush_r;
  
  // Please note csr_serial_sr is a X1 stage signal. A serial SR in X2 will not flush
  // the pipe if followed by a serial SR in X1
  //
  csr_x1_serial_valid = x1_valid_r & csr_serial_sr;
  
  csr_flush_nxt       = (csr_x2_strict_sr_r  & csr_x2_pass)                          // strict serialization commit
                      | (csr_x2_serial_sr_r  & (~csr_x1_serial_valid) & csr_x2_pass) // last normal serialization
                      ;
end



always @*
begin : csr_pmp_write_PROC
  csr_pmp_write = csr_pmp_x2_write_r;
  csr_pmp_waddr = {12{csr_pmp_x2_write_r}}         & csr_x2_addr_r;
  csr_pmp_wdata = {`DATA_SIZE{csr_pmp_x2_write_r}} & csr_x2_wdata;
end

always @*
begin : csr_trig_write_PROC
  csr_trig_write = csr_trig_x2_write_r;
  csr_trig_waddr = {12{csr_trig_x2_write_r}}         & csr_x2_addr_r;
  csr_trig_wdata = {`DATA_SIZE{csr_trig_x2_write_r}} & csr_x2_wdata;
end

always @*
begin : csr_pma_write_PROC
  csr_pma_write = csr_pma_x2_write_r;
  csr_pma_waddr = {12{csr_pma_x2_write_r}}         & csr_x2_addr_r;
  csr_pma_wdata = {`DATA_SIZE{csr_pma_x2_write_r}} & csr_x2_wdata;
end



always @*
begin : csr_iccm_write_PROC
  csr_iccm_write = csr_iccm_x2_write_r;
  csr_iccm_waddr = {8{csr_iccm_x2_write_r}}          & csr_x2_addr_r[7:0];
  csr_iccm_wdata = {`DATA_SIZE{csr_iccm_x2_write_r}} & csr_x2_wdata;
end

always @*
begin : csr_dmp_write_PROC
  csr_dmp_write = csr_dmp_x2_write_r;
  csr_dmp_waddr = {8{csr_dmp_x2_write_r}}          & csr_x2_addr_r[7:0];
  csr_dmp_wdata = {`DATA_SIZE{csr_dmp_x2_write_r}} & csr_x2_wdata;
end

always @*
begin : csr_sfty_write_PROC
  csr_sfty_write = csr_sfty_x2_write_r;
  csr_sfty_waddr = {12{csr_sfty_x2_write_r}}         & csr_x2_addr_r;
  csr_sfty_wdata = {`DATA_SIZE{csr_sfty_x2_write_r}} & csr_x2_wdata;
end


always @*
begin : csr_wdt_write_PROC
  csr_wdt_write = csr_wdt_x2_write_r;
  csr_wdt_waddr = {12{csr_wdt_x2_write_r}}         & csr_x2_addr_r[11:0];
  csr_wdt_wdata = {`DATA_SIZE{csr_wdt_x2_write_r}} & csr_x2_wdata;
end


always @*
begin : csr_clint_write_PROC
  csr_clint_write = csr_clint_x2_write_r;
  csr_clint_waddr = {12{csr_clint_x2_write_r}}          & csr_x2_addr_r[11:0];
  csr_clint_wdata = {`DATA_SIZE{(csr_clint_x2_write_r | mireg_clint_wen)}} & csr_x2_wdata;
end

always @*
begin : csr_hpm_write_PROC
  csr_hpm_write = csr_hpm_x2_write_r;
  csr_hpm_waddr = {12{csr_hpm_x2_write_r}}         & csr_x2_addr_r[11:0];
  csr_hpm_wdata = {`DATA_SIZE{csr_hpm_x2_write_r}} & csr_x2_wdata;
end


//////////////////////////////////////////////////////////////////////////////////////////
// Commpute counters next values
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : mcycle_inst_nxt_PROC
  // Default values
  //
  mcycle_nxt   = mcycle_r;
  minstret_nxt = minstret_r;
  
  {cyc_ovf_flag, mcycle_inc} = mcycle_r   + 64'd1;
  {ins_ovf_flag, minstret_inc} = minstret_r + (x3_valid_r & (~db_active)
                              & (~x2_uop_valid_r)       // push/pop should be counted as only one inst
  );
  
  case (1'b1)
  csr_x2_ctl_r[`CSR_CTL_SET]:
  begin
    if (mcycle_cg0)
	begin
      mcycle_nxt[31:0]    = csr_x2_data_r | csr_x2_wdata;
	end
	else
	begin
      mcycle_nxt[31:0]    = mcycle_inc[31:0];
	end

	if (mcycleh_cg0)
	begin
      mcycle_nxt[63:32]   = csr_x2_data_r | csr_x2_wdata;
	end
	else
	begin
      mcycle_nxt[63:32]   = mcycle_inc[63:32];
	end
    
	if (minstret_cg0)
	begin
      minstret_nxt[31:0]  = csr_x2_data_r | csr_x2_wdata;
	end
	else
	begin
      minstret_nxt[31:0]  = minstret_inc[31:0];
	end

	if (minstreth_cg0)
	begin
      minstret_nxt[63:32] = csr_x2_data_r | csr_x2_wdata;
	end
	else
	begin
      minstret_nxt[63:32] = minstret_inc[63:32];
	end
  end
  
  csr_x2_ctl_r[`CSR_CTL_CLEAR]:
  begin
    if (mcycle_cg0)
	begin
      mcycle_nxt[31:0]    = csr_x2_data_r & (~csr_x2_wdata);
	end
	else
	begin
      mcycle_nxt[31:0]    = mcycle_inc[31:0];
	end

	if (mcycleh_cg0)
	begin
      mcycle_nxt[63:32]   = csr_x2_data_r & (~csr_x2_wdata);
	end
	else
	begin
      mcycle_nxt[63:32]   = mcycle_inc[63:32];
	end
    
	if (minstret_cg0)
	begin
      minstret_nxt[31:0]  = csr_x2_data_r & (~csr_x2_wdata);
	end
	else
	begin
      minstret_nxt[31:0]  = minstret_inc[31:0];
	end

	if (minstreth_cg0)
	begin
      minstret_nxt[63:32] = csr_x2_data_r & (~csr_x2_wdata);
	end
	else
	begin
      minstret_nxt[63:32] = minstret_inc[63:32];
	end
  end
  
  csr_x2_ctl_r[`CSR_CTL_WRITE]:
  begin
    if (mcycle_cg0)
	begin
      mcycle_nxt[31:0]    = csr_x2_wdata;
	end
	else
	begin
      mcycle_nxt[31:0]    = mcycle_inc[31:0];
	end

	if (mcycleh_cg0)
	begin
      mcycle_nxt[63:32]   = csr_x2_wdata;
	end
	else
	begin
      mcycle_nxt[63:32]   = mcycle_inc[63:32];
	end
    
	if (minstret_cg0)
	begin
      minstret_nxt[31:0]  = csr_x2_wdata;
	end
	else
	begin
      minstret_nxt[31:0]  = minstret_inc[31:0];
	end

	if (minstreth_cg0)
	begin
      minstret_nxt[63:32] = csr_x2_wdata;
	end
	else
	begin
      minstret_nxt[63:32] = minstret_inc[63:32];
	end
  end
  
  default:
  begin
    mcycle_nxt          = mcycle_inc;
    minstret_nxt        = minstret_inc;
  end
  endcase
end

//////////////////////////////////////////////////////////////////////////////////////////
// Commpute clock-gates
//
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : mcycle_inst_cg0_PROC
  //========================================================================
  // mcycle_g0_cg0 is asserted whenever the lower 10 bits of mcycle are
  // written, either by incrementing it on each cycle when counting is not
  // inhibited by the mcountinhibit_r[0] bit being set to 1, or when
  // writing to the mcycle register with a CSR instruction (mcycle_cg0 == 1).
  //

  mcycle_g0_cg0   = mcycle_cg0
                  | (mcountinhibit_r[0] == 1'b0);
 
  //========================================================================
  // mcycle_g1_cg0 is asserted whenever bits [31:10] of mcycle are
  // written, either by incrementing it if mcycle[10] would toggle and
  // counting is not inhibited, or when writing to the mcycle register.
  //
  mcycle_g1_cg0   = mcycle_cg0
                  | (   (mcountinhibit_r[0] == 1'b0)
                      & (mcycle_inc[10] != mcycle_r[10])
                    )
                  ;

  //========================================================================
  // mcycle_g2_cg0 is asserted whenever bits [63:32] of mcycle are written,
  // either by incrementing it if mcycle[32] would toggle and counting is
  // not inhibited, or when writing to the mcycle register.
  //
  mcycle_g2_cg0   = mcycleh_cg0
                  | (   (mcountinhibit_r[0] == 1'b0)
                      & (mcycle_inc[32] != mcycle_r[32])
                    )
                  ;
                  
                  
  //========================================================================
  // minstret_g0_cg0 is asserted whenever the lower 10 bits of minstret are
  // written, either by incrementing it on each cycle when counting is not
  // inhibited by the mcountinhibit_r[2] bit being set to 1, or when
  // writing to the minstret register with a CSR instruction (minstret_cg0 == 1).
  //
  minstret_g0_cg0 = minstret_cg0
                  | (mcountinhibit_r[2] == 1'b0)
                  ;
                  
  //========================================================================
  // minstret_g1_cg0 is asserted whenever bits [31:10] of minstret are
  // written, either by incrementing it if minstret[10] would toggle and
  // counting is not inhibited, or when writing to the minstret register.
  //
  minstret_g1_cg0 = minstret_cg0
                  | (   (mcountinhibit_r[2] == 1'b0)
                      & (minstret_inc[10] != minstret_r[10])
                    )
                  ;
  //========================================================================
  // minstret_g2_cg0 is asserted whenever bits [63:32] of minstret are written,
  // either by incrementing it if minstret[32] would toggle and counting is
  // not inhibited, or when writing to the minstret register.
  //
  minstret_g2_cg0 = minstreth_cg0
                  | (   (mcountinhibit_r[2] == 1'b0)
                      & (minstret_inc[32] != minstret_r[32])
                    )
                  ;
end


//////////////////////////////////////////////////////////////////////////////////////////
// Interrupts:
// 
///////////////////////////////////////////////////////////////////////////////////////////

assign irq_enable = mstatus_r[`MIE] & mnstatus_r[`MIE] & (!step_blocks_irq);
assign rnmi_enable = mnstatus_r[`MIE] & (!step_blocks_irq);

//////////////////////////////////////////////////////////////////////////////////////////
// Exception management
// 
///////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_exc_control_PROC

  // Update CSRs on exception/interrupt entry
  //
  priv_level_nxt = priv_level_r;
  priv_level_cg0 = 1'b0;
  

  // Default value of mstatus_nxt is what the software could be writng with a CSR instruction
  //
  mstatus_cg0    = mstatus_sw_cg0;
  mstatus_nxt    = mstatus_sw_nxt;  

  mdt_cg0        = mdt_sw_cg0;
  mdt_nxt        = mdt_sw_nxt;

  mcause_cg0     = mcause_sw_cg0;
  mcause_nxt     = mcause_sw_nxt;  

  mnstatus_cg0   = mnstatus_sw_cg0;
  mnstatus_nxt   = mnstatus_sw_nxt;  

  mncause_cg0    = mncause_sw_cg0;
  mncause_nxt    = mncause_sw_nxt;
  
  mtval_cg0      = mtval_sw_cg0;
  mtval_nxt      = mtval_sw_nxt;
  mtsp_cg0       = mtsp_sw_cg0;
  mtsp_nxt       = mtsp_sw_nxt;
  sp_u_recover   = 1'b0;
  
  mepc_cg0       = mepc_sw_cg0;
  mepc_nxt       = mepc_sw_nxt;  

  mnepc_cg0      = mnepc_sw_cg0;
  mnepc_nxt      = mnepc_sw_nxt;

  // Dealing with trap returns
  //
  csr_trap_ret_cg0       = csr_x2_mret | csr_trap_ret_r;
  csr_trap_ret_nxt       = csr_x2_mret & x2_pass;

  rnmi_ret_cg0           = csr_x2_mnret | rnmi_ret_r;
  rnmi_ret_nxt           = csr_x2_mnret & x2_pass;

  if (debug_mode_r ^ debug_mode)
  begin
    priv_level_cg0           = 1'b1;    
    priv_level_nxt           = debug_mode ? `PRIV_D : dcsr_r[`DCSR_PRV_RANGE]; 
    mstatus_cg0              = 1'b1;
    mstatus_nxt[`MPRV]       = (debug_mode_r & (dcsr_r[`DCSR_PRV_RANGE] == `PRIV_U)) ? 1'b0 : mstatus_r[`MPRV];
  end
  else if (   trap_valid
      // & (debug_mode_r == 1'b0)
     )
  begin
    priv_level_cg0           = 1'b1;    
    priv_level_nxt           = `PRIV_M; 
    mnstatus_nxt             = mnstatus_r;      // block sw_nxt value when trap_valid
    mstatus_nxt              = mstatus_r;

    // stsp
    if (priv_level_r == `PRIV_U)
    begin
        mtsp_cg0             = menvcfg_r[8];
        sp_u_recover         = menvcfg_r[8];
        mtsp_nxt             = sp_u;
    end

  if ((rnmi_synch_r & rnmi_enable)
                                | mdt_r
      )   //RNMI or non-fatal double trap 
  begin
    // Update fileds of mstatus
    //
    mnstatus_cg0              = 1'b1;
    mnstatus_nxt[`MIE]        = 1'b0;
    mnstatus_nxt[`MPP_RANGE]  = priv_level_r; 
    // Update cause
    //
    mncause_cg0               = 1'b1;
    mncause_nxt               = trap_cause;

    // update epc
    //
    if (!rnmi_ret_r)
    begin
        mnepc_cg0             = 1'b1;
        mnepc_nxt             = csr_trap_ret_r ? mepc_r : ar_pc_r;  // tricky case that mnepc should borrow value from mepc
    end

  end
  else 
  begin
    // Update fileds of mstatus
    //
    mstatus_cg0              = 1'b1;
    mstatus_nxt[`MIE]        = 1'b0;
    mstatus_nxt[`MPIE]       = mstatus_r[`MIE];
    mstatus_nxt[`MPP_RANGE]  = priv_level_r; 
    // update mdt
    mdt_cg0                   = 1'b1;
    mdt_nxt                   = 1'b1;

    // Update cause
    //
    mcause_cg0               = 1'b1;
    mcause_nxt               = trap_cause;
    
    // update epc
    //
    if (!csr_trap_ret_r) 
    begin  //nopp trap, no need to update epc
      mepc_cg0               = 1'b1;
      mepc_nxt               = rnmi_ret_r ? mnepc_r : ar_pc_r;  // tricky case that mepc should borrow value from mnepc
    end
    
    // update mtval
    //
    mtval_cg0                = 1'b1;
    mtval_nxt                = trap_data;
    end
  end
  else 
  begin
    // Update CSRs on exception return
    //
    if (csr_x2_mret)
    begin
      priv_level_cg0           = x2_pass;    
      priv_level_nxt           = mstatus_r[`MPP_RANGE]; 
      if (mstatus_r[`MPP_RANGE] == `PRIV_U)
      begin
      sp_u_recover             = menvcfg_r[8] & x2_pass;
      mtsp_cg0                 = menvcfg_r[8] & x2_pass;
      mtsp_nxt                 = sp_u;
      end
    // update mdt
      mdt_cg0                  = x2_pass;
      mdt_nxt                  = 1'b0;
      
      // Update fileds of mstatus
      //
      mstatus_cg0              = x2_pass;
      mstatus_nxt[`MIE]        = mstatus_r[`MPIE];
      mstatus_nxt[`MPIE]       = 1'b1;
      mstatus_nxt[`MPP_RANGE]  = `PRIV_U;
      mstatus_nxt[`MPRV]       = (mstatus_r[`MPP_RANGE] == `PRIV_U) ? 1'b0 : mstatus_r[`MPRV];
    end

    if (csr_x2_mnret)
    begin
      priv_level_cg0           = x2_pass;    
      priv_level_nxt           = mnstatus_r[`MPP_RANGE]; 

    // update mdt
      if (mnstatus_r[`MPP_RANGE] == `PRIV_U)
      begin
      mdt_cg0                  = x2_pass;
      mdt_nxt                  = 1'b0;
      end
      
    // stsp
      if (mnstatus_r[`MPP_RANGE] == `PRIV_U)
      begin
      sp_u_recover             = menvcfg_r[8] & x2_pass;
      mtsp_cg0                 = menvcfg_r[8] & x2_pass;
      mtsp_nxt                 = sp_u;
      end
      
      // Update fileds of mnstatus
      //
      mnstatus_cg0             = x2_pass;
      mnstatus_nxt[`MIE]       = 1'b1;
    end

    // clear MIE when MDT is 1
    //
    if (mdt_sw_cg0 & mdt_sw_nxt)
    begin
        mstatus_nxt[`MIE]      = 1'b0;
        mstatus_cg0            = 1'b1;
    end
  end
end



//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
// SMD: Sequential convergence found
// SJ:  The convergence sources are independent to each other without logical dependency

always @(posedge clk or posedge rst_a)
begin : csr_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_x2_valid_r        <= 1'b0;
    csr_x2_ctl_r          <= {`CSR_CTL_WIDTH{1'b0}}; 
    csr_x2_dst_id_r       <= 5'd0;
    csr_x2_dst_id_valid_r <= 1'b0;    
    csr_x2_data_r         <= {`DATA_SIZE{1'b0}}; 
    csr_x2_dbg_rd_err_r   <= 1'b0;
    csr_x2_addr_r         <= {12{1'b0}}; 
    csr_x2_serial_sr_r    <= 1'b0;    
    csr_x2_strict_sr_r    <= 1'b0;    
    
    csr_x2_rb_req_r       <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_x2_valid_r        <= csr_x2_valid_nxt; 
      csr_x2_dst_id_valid_r <= csr_x1_dst_id_valid;    
      csr_x2_ctl_r          <= {`CSR_CTL_WIDTH{x1_pass}} & x1_csr_ctl;
      csr_x2_serial_sr_r    <= csr_serial_sr;   
      csr_x2_strict_sr_r    <= csr_strict_sr; 
    end 
    csr_x2_dbg_rd_err_r<= 1'b0; 
    if (csr_x2_data_cg0 == 1'b1)
    begin
      csr_x2_dst_id_r    <= csr_x2_dst_id_nxt;
      csr_x2_data_r      <= csr_rdata;
      csr_x2_dbg_rd_err_r<= csr_unimpl;
    end
    
    if (csr_x2_addr_cg0 == 1'b1)
    begin
      csr_x2_addr_r   <= csr_x1_addr;
    end
    
    if (csr_x2_rb_req_cg0 == 1'b1)
    begin
      csr_x2_rb_req_r <= csr_x2_rb_req_nxt;
    end
  end
end

// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ

always @(posedge clk or posedge rst_a)
begin : csr_trap_ret_reg_PROC
  if (rst_a == 1'b1)
  begin
    csr_trap_ret_r <= 1'b0;
    csr_flush_r    <= 1'b0;
  end
  else
  begin
    if (csr_trap_ret_cg0 == 1'b1)
    begin
      csr_trap_ret_r <= csr_trap_ret_nxt;
    end
    if (csr_flush_cg0 == 1'b1)
    begin
      csr_flush_r    <= csr_flush_nxt;
    end
  end

end

always @(posedge clk or posedge rst_a)
begin : rnmi_ret_reg_PROC
  if (rst_a == 1'b1)
  begin
    rnmi_ret_r <= 1'b0;
  end
  else
  begin
    if (rnmi_ret_cg0 == 1'b1)
    begin
      rnmi_ret_r <= rnmi_ret_nxt;
    end
    
  end

end

always @(posedge clk or posedge rst_a)
begin : csr_pmp_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_pmp_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_pmp_x2_write_r <= x1_pass & csr_pmp_sel_ctl[1];
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_trig_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_trig_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_trig_x2_write_r <= x1_pass & csr_trig_sel_ctl[1];
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_pma_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_pma_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_pma_x2_write_r <= x1_pass & csr_pma_sel_ctl[1];
    end
  end
end



always @(posedge clk or posedge rst_a)
begin : csr_iccm_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_iccm_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_iccm_x2_write_r <= x1_pass & csr_iccm_sel_ctl[1];
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : priv_level_regs_PROC
  if (rst_a == 1'b1)
  begin
    priv_level_r <=  `PRIV_M; 
  end
  else
  begin
    if (priv_level_cg0 == 1'b1)
    begin
      priv_level_r <= priv_level_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_dmp_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_dmp_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_dmp_x2_write_r <= x1_pass & csr_dmp_sel_ctl[1];
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_sfty_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_sfty_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_sfty_x2_write_r <= x1_pass & csr_sfty_sel_ctl[1];
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : csr_wdt_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_wdt_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_wdt_x2_write_r <= x1_pass & csr_wdt_sel_ctl[1];
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : csr_hpm_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_hpm_x2_write_r <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_hpm_x2_write_r <= x1_pass & csr_hpm_sel_ctl[1];
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_clint_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    csr_clint_x2_write_r <= 1'b0;
    csr_clint_ren_r      <= 1'b0;
  end
  else
  begin
    if (csr_x2_ctl_cg0 == 1'b1)
    begin
      csr_clint_x2_write_r <= x1_pass & csr_clint_sel_ctl[1];
      csr_clint_ren_r      <= x1_pass & csr_clint_sel_ctl[0];
    end
  end
end

// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals
always @(posedge clk or posedge rst_a)
begin : x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    x2_src0_data_r <=  {`DATA_SIZE{1'b0}}; 
  end
  else
  begin
    if (csr_x2_data_cg0 == 1'b1)
    begin
      x2_src0_data_r <= 
                        (x1_csr_ctl[`CSR_CTL_BYP] ? clint_csr_rdata : x1_src0_data)
                        ;
    end
  end
end
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ



always @(posedge clk or posedge rst_a)
begin : csr_ctrl_regs_PROC
  if (rst_a == 1'b1)
  begin
    mcountinhibit_r   <= `CNT_CTRL_BITS'd0;
    mcounteren_r      <= `CNT_CTRL_BITS'd0;
  end
  else
  begin
    if (mcountinhibit_cg0 == 1'b1)
      mcountinhibit_r <= {csr_x2_wdata[`CNT_CTRL_MSB:2], 1'b0, csr_x2_wdata[0]};

    if (mcounteren_cg0 == 1'b1)
      mcounteren_r    <= csr_x2_wdata[`CNT_CTRL_RANGE];
  end
end
always @(posedge clk or posedge rst_a)
begin : csr_pct_regs_PROC
  if (rst_a == 1'b1)
  begin
    mcycle_r     <= 64'd0;
    minstret_r   <= 64'd0;
  end
  else
  begin
    
    if (mcycle_g0_cg0 == 1'b1)
      mcycle_r[9:0]   <= mcycle_nxt[9:0];
    if (mcycle_g1_cg0 == 1'b1)
      mcycle_r[31:10] <= mcycle_nxt[31:10];
    if (mcycle_g2_cg0 == 1'b1)
      mcycle_r[63:32] <= mcycle_nxt[63:32];

    if (minstret_g0_cg0 == 1'b1)
      minstret_r[9:0]   <= minstret_nxt[9:0];
    if (minstret_g1_cg0 == 1'b1)
      minstret_r[31:10] <= minstret_nxt[31:10];
    if (minstret_g2_cg0 == 1'b1)
      minstret_r[63:32] <= minstret_nxt[63:32];

  end
end
always @(posedge clk or posedge rst_a)
begin : count_ovf_PROC
  if (rst_a == 1'b1)
  begin
    cycle_ovf     <= 1'b0;
    instret_ovf   <= 1'b0;
  end
  else
  begin
    if (mcountinhibit_r[0] == 1'b0)
      cycle_ovf   <= cyc_ovf_flag;

    if (mcountinhibit_r[2] == 1'b0)
      instret_ovf <= ins_ovf_flag;
  end
end


always @(posedge clk or posedge rst_a)
begin : csr_jvt_regs_PROC
  if (rst_a == 1'b1)
  begin
    arcv_ujvt_r      <= `DATA_WIDTH'd0;
  end
  else
  begin
    if (arcv_ujvt_cg0 == 1'b1)
    arcv_ujvt_r      <= arcv_ujvt_nxt;
  end
end


always @(posedge clk or posedge rst_a)
begin : miselect_regs_PROC
  if (rst_a == 1'b1)
  begin
    miselect_r  <= `DATA_WIDTH'b0;
  end
  else
  begin
    if (miselect_cg0 == 1'b1)
    miselect_r  <= miselect_nxt;
  end
end


always @(posedge clk or posedge rst_a)
begin : csr_mtvec_reg_PROC
  if (rst_a == 1'b1)
    mtvec_r <= {`PC_SIZE'd`CORE_RESET_PC, 1'b0};
  else
  if (cycle_delay)
      mtvec_r <= {reset_pc_in, 10'b0};
  else
    if (mtvec_cg0 == 1'b1)
    begin
      mtvec_r <= mtvec_nxt;
    end
end
always @(posedge clk or posedge rst_a)
begin : csr_mlwid_reg_PROC
  if (rst_a == 1'b1)
  begin
    mlwid_r <= {`WID_BITS{1'b0}};
  end
  else if (mlwid_cg0 == 1'b1)
    begin
      mlwid_r <= mlwid_nxt;
    end
end

always @(posedge clk or posedge rst_a)
begin : csr_mstatus_reg_PROC
  if (rst_a == 1'b1)
  begin
    mstatus_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mstatus_cg0 == 1'b1)
    begin
      mstatus_r <= mstatus_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_mdt_reg_PROC
  if (rst_a == 1'b1)
  begin
    mdt_r   <= 1'b1;
  end
  else
  begin
    if (mdt_cg0 == 1'b1)
    begin
      mdt_r <= mdt_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_mnstatus_reg_PROC
  if (rst_a == 1'b1)
  begin
    mnstatus_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mnstatus_cg0 == 1'b1)
    begin
      mnstatus_r <= mnstatus_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_ncause_reg_PROC
  if (rst_a == 1'b1)
  begin
    mncause_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mncause_cg0 == 1'b1)
    begin
      mncause_r <= mncause_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_cause_reg_PROC
  if (rst_a == 1'b1)
  begin
    mcause_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mcause_cg0 == 1'b1)
    begin
      mcause_r <= mcause_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_mtval_reg_PROC
  if (rst_a == 1'b1)
  begin
    mtval_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mtval_cg0 == 1'b1)
    begin
      mtval_r <= mtval_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_mtsp_reg_PROC
  if (rst_a == 1'b1)
  begin
    mtsp_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mtsp_cg0 == 1'b1)
    begin
      mtsp_r <= mtsp_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_epc_reg_PROC
  if (rst_a == 1'b1)
  begin
    mepc_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mepc_cg0 == 1'b1)
    begin
      mepc_r <= mepc_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_mscratch_reg_PROC
  if (rst_a == 1'b1)
  begin
    mscratch_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mscratch_cg0 == 1'b1)
    begin
      mscratch_r <= mscratch_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_nepc_reg_PROC
  if (rst_a == 1'b1)
  begin
    mnepc_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mnepc_cg0 == 1'b1)
    begin
      mnepc_r <= mnepc_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_mnscratch_reg_PROC
  if (rst_a == 1'b1)
  begin
    mnscratch_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (mnscratch_cg0 == 1'b1)
    begin
      mnscratch_r <= mnscratch_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_menvcfg_reg_PROC
  if (rst_a == 1'b1)
  begin
    menvcfg_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (menvcfg_cg0 == 1'b1)
    begin
      menvcfg_r <= menvcfg_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_mesb_ctrl_reg_PROC
  if (rst_a == 1'b1)
  begin
    arcv_mesb_ctrl_r <= 2'b00;
  end
  else
  begin
    if (arcv_mesb_ctrl_cg0 == 1'b1)
    begin
      arcv_mesb_ctrl_r  <= arcv_mesb_ctrl_nxt;
    end
  end
end

always@*
begin : arcv_mecc_diag_nxt_PROC
   arcv_mecc_diagnostic_nxt = arcv_mecc_diagnostic_r;

   if( arcv_mecc_diagnostic_cg0 == 1'b1 )
      arcv_mecc_diagnostic_nxt[7:0] = arcv_mecc_diagnostic_sw_nxt;
   else if(ic_tag_ecc_excpn | ic_tag_ecc_wr)
      arcv_mecc_diagnostic_nxt[6:0] = ic_tag_ecc_out;
   else if(ic_data_ecc_excpn | ic_data_ecc_wr)
      arcv_mecc_diagnostic_nxt[7:0] = ic_data_ecc_out;
   else if(iccm_ecc_excpn | iccm_dmp_ecc_err | iccm_ecc_wr)
      arcv_mecc_diagnostic_nxt[7:0] = iccm0_ecc_out;
   if(dccm_ecc_excpn | dccm_ecc_wr)
      arcv_mecc_diagnostic_nxt[7:0] = dccm_ecc_out;

   if(ic_tag_ecc_excpn)
      arcv_mecc_diagnostic_nxt[13:8] = 6'b000011;
   else if(ic_data_ecc_excpn)
      arcv_mecc_diagnostic_nxt[13:8] = 6'b000101;
   else
   if(iccm_ecc_excpn)
      arcv_mecc_diagnostic_nxt[13:8] = 6'b000001;
   else if(iccm_dmp_ecc_err)
      arcv_mecc_diagnostic_nxt[13:8] = 6'b100000;
   else
   if(dccm_ecc_excpn)
      arcv_mecc_diagnostic_nxt[13:8] = 6'b100111;
end

always @(posedge clk or posedge rst_a)
begin : csr_mecc_diag_reg_PROC
  if (rst_a == 1'b1)
  begin
    arcv_mecc_diagnostic_r <= 14'b0;
  end
  else
  begin
    arcv_mecc_diagnostic_r <= arcv_mecc_diagnostic_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : dcsr_reg_PROC 
  if (rst_a == 1'b1)
  begin
    dcsr_r <= {1'b0, //CETRIG, for double trap, dcsr[19]
               1'b0, //EBREAKM
               1'b0, //EBREAKU
               1'b0, //STEPIE
               3'b0, //CAUSE
               1'b0, //MPRVEN
               1'b0, //STEP
               2'b11 //PRV
               };
  end
  else
  begin
    if (dcsr_cg0 == 1'b1)
    begin
      dcsr_r <= dcsr_nxt;
    end
  end
end

// @@@
//

always @*
begin: dcsr_tbd_PROC
    dcsr_cg0 = 1'b0;
    dcsr_nxt = dcsr_r; 
    if (~debug_mode_r & debug_mode)
    begin
      dcsr_cg0                    = 1'b1;
      dcsr_nxt[`DCSR_PRV_RANGE]   = priv_level_r; 
      dcsr_nxt[`DCSR_CAUSE_RANGE] = halt_cond; 
    end
    else if ((csr_x2_addr_r == `CSR_DCSR) & csr_x2_wen)
    begin
      if (debug_mode_r == 1'b1)
      begin
        dcsr_cg0                   = 1'b1;
        dcsr_nxt[`DCSR_STEP_BIT]   = db_wdata[2]; 
        dcsr_nxt[`DCSR_STEPIE_BIT] = db_wdata[11];
        dcsr_nxt[`DCSR_MPRVEN_BIT] = db_wdata[4];
        dcsr_nxt[`DCSR_EBM_BIT]    = db_wdata[15];
        dcsr_nxt[`DCSR_EBU_BIT]    = db_wdata[12];
        dcsr_nxt[`DCSR_CETRIG_BIT] = db_wdata[19];
        if (db_wdata[0] != db_wdata[1])
        begin
          dcsr_nxt[`DCSR_PRV_RANGE] = 2'b11;
        end
        else
        begin
          dcsr_nxt[`DCSR_PRV_RANGE] = db_wdata[1:0]; 
        end
      end
      else
      begin
      end
    end
end


always @(posedge clk or posedge rst_a)
begin : arcv_mcache_ctl_reg_PROC 
  if (rst_a == 1'b1)
  begin
    arcv_mcache_ctl_r <= {`ARCV_MC_CTL_WIDTH'b11};
  end
  else
  begin
    if (arcv_mcache_ctl_cg0 == 1'b1)
    begin
      arcv_mcache_ctl_r <= arcv_mcache_ctl_nxt;
    end
  end
end

//always@*
//begin: arcv_mcache_op_next_PROC
//  arcv_mcache_op_en   = 1'b0;
//  arcv_mcache_op_next = arcv_mcache_op_r; 
//  if (arcv_icache_op_in_progress == 1'b1)
//  begin
//    arcv_mcache_op_en       = 1'b1;
//    arcv_mcache_op_next[24] = 1'b1; 
//  end
//  else if (arcv_mcache_op_cg0 == 1'b1)
//  begin
//    arcv_mcache_op_en   = 1'b1;
//    arcv_mcache_op_next = arcv_mcache_op_nxt; 
//  end
//end

always @(posedge clk or posedge rst_a)
begin : arcv_mcache_op_reg_PROC 
  if (rst_a == 1'b1)
  begin
    arcv_mcache_op_r      <= {`ARCV_MC_OP_WDT{1'b0}};
    arcv_icache_op_init_r <= 1'b0;
  end
  else
  begin
    if (arcv_icache_op_done == 1'b1)
    begin
      arcv_mcache_op_r[24]  <= 1'b0; 
      arcv_icache_op_init_r <= 1'b0;
    end
    else if (arcv_icache_op_in_progress == 1'b1)
    begin
      arcv_mcache_op_r[24]  <= arcv_icache_op_in_progress; 
    end
    else if (arcv_mcache_op_cg0 == 1'b1)
    begin
      arcv_mcache_op_r[23:0]<= arcv_mcache_op_nxt[23:0];
      arcv_icache_op_init_r <= arcv_icache_op_init_nxt;
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : arcv_mcache_addr_reg_PROC 
  if (rst_a == 1'b1)
  begin
    arcv_mcache_addr_r <= {`ARCV_MC_ADDR_WIDTH{1'b0}};
  end
  else
  begin
    if (arcv_mcache_addr_cg0 == 1'b1)
    begin
      arcv_mcache_addr_r <= arcv_mcache_addr_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : arcv_mcache_lines_reg_PROC 
  if (rst_a == 1'b1)
  begin
    arcv_mcache_lines_r <= {`ARCV_MC_LN_WDT{1'b0}};
  end
  else
  begin
    if (arcv_mcache_lines_cg0 == 1'b1)
    begin
      arcv_mcache_lines_r <= arcv_mcache_lines_nxt;
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : arcv_mcache_data_reg_PROC 
  if (rst_a == 1'b1)
  begin
    arcv_mcache_data_r <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if ((arcv_icache_op_done == 1'b1) & ((arcv_mcache_op[3:0] == `I_IDX_READ_TAG) | (arcv_mcache_op[3:0] == `I_IDX_READ_DATA)))
    begin
      arcv_mcache_data_r <= arcv_icache_data;
    end
    else if (arcv_mcache_data_cg0 == 1'b1)
    begin
      arcv_mcache_data_r <= arcv_mcache_data_nxt;
    end
  end
end

assign arcv_mcache_ctl     = arcv_mcache_ctl_r;
assign arcv_mcache_op      = arcv_mcache_op_r;
assign arcv_mcache_addr    = arcv_mcache_addr_r;
assign arcv_mcache_lines   = arcv_mcache_lines_r;
assign arcv_mcache_data    = arcv_mcache_data_r;
assign arcv_icache_op_init = arcv_icache_op_init_r;


always @(posedge clk or posedge rst_a)
begin : core_mmio_base_reg_PROC 
  if (rst_a == 1'b1)
  begin
    core_mmio_base_r <= 12'd`CORE_MMIO_BASE;
  end
  else
  begin
    if (cycle_delay == 1'b1)
    begin
      core_mmio_base_r <= core_mmio_base_in;
    end
  end
end

reg  [21:0]  reset_pc_in_r;
always @(posedge clk or posedge rst_a)
begin : reset_pc_reg_PROC 
  if (rst_a == 1'b1)
  begin
    reset_pc_in_r <= 22'd0;
  end
  else
    if (cycle_delay == 1'b1)
    begin
      reset_pc_in_r <= reset_pc_in;
    end
end

// Trap base
//

always @*
begin: trap_base_PROC
   if ((rnmi_synch_r & rnmi_enable)
                                    | mdt_r    // non-fatal dbl trap shares the same base as RNMI interrupt
        )
        csr_trap_base = {reset_pc_in_r, 9'd0} + `PC_SIZE'h80;
  else
        csr_trap_base = {mtvec_r[31:2], 1'b0};
end

// Trap epc
//
always @*
begin: trap_epc_PROC
   if (rnmi_ret_r)
        csr_trap_epc = mnepc_r;
   else
        csr_trap_epc = mepc_r;
end

//////////////////////////////////////////////////////////////////////////////////////////
// Debug CSR 
//
///////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst_a)
begin: arcv_dbg_ctrl_reg_PROC
  if (rst_a == 1'b1)
  begin
    arcv_dbg_ctrl_r <= 2'b0;
  end
  else
  begin
    if (arcv_dbg_ctrl_cg0 == 1'b1)
    begin
      arcv_dbg_ctrl_r <= arcv_dbg_ctrl_nxt; 
    end
  end
end

//////////////////////////////////////////////////////////////////////////////////////////
// Debug Mode Condition 
//
///////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk or posedge rst_a)
begin : debug_mode_r_PROC
  if (rst_a == 1'b1)
  begin
    debug_mode_r <= 1'b1;
  end
  else
  begin
    debug_mode_r <= debug_mode; 
  end
end
always@*
begin
  dpc_nxt = dpc_r;
  if (debug_mode)
  begin
    if (~debug_mode_r)
    begin
      dpc_nxt = ar_pc_r;
    end
    else if ((csr_x2_addr_r == `CSR_DPC) & csr_x2_wen)
    begin
      dpc_nxt = csr_x2_wdata; 
    end
  end
  else if ((csr_x2_addr_r == `CSR_DPC) & csr_x2_wen & db_active)
  begin
    dpc_nxt = csr_x2_wdata; 
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    dpc_r <= `DATA_WIDTH'b0;
  end
  else
  begin
    dpc_r <= dpc_nxt; 
  end
end
//////////////////////////////////////////////////////////////////////////////////////////
// WID Value 
//
///////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk or posedge rst_a)
begin: wid_input_sample_PROC
  if (rst_a == 1'b1)
  begin
    wid_rlwid_r <= `WID_BITS'b0;
  end
  else
  begin
    if ((priv_level_cg0 && (priv_level_nxt == `PRIV_M)) || (cycle_delay))
    begin
      wid_rlwid_r <= wid_rlwid; 
    end
  end
end

always@(posedge clk or posedge rst_a)
begin: widdelg_input_sample_PROC
  if (rst_a == 1'b1)
  begin
    wid_rwiddeleg_r <= 64'b0;
  end
  else
  begin
    if ((priv_level_cg0 && (priv_level_nxt == `PRIV_M)) || (cycle_delay))
    begin
      wid_rwiddeleg_r <= wid_rwiddeleg; 
    end
  end
end

// bit reversal for leading one detection (lod) from LSB
assign wid_xwiddeleg_rev[0] = wid_rwiddeleg_r[63-0];
assign wid_xwiddeleg_rev[1] = wid_rwiddeleg_r[63-1];
assign wid_xwiddeleg_rev[2] = wid_rwiddeleg_r[63-2];
assign wid_xwiddeleg_rev[3] = wid_rwiddeleg_r[63-3];
assign wid_xwiddeleg_rev[4] = wid_rwiddeleg_r[63-4];
assign wid_xwiddeleg_rev[5] = wid_rwiddeleg_r[63-5];
assign wid_xwiddeleg_rev[6] = wid_rwiddeleg_r[63-6];
assign wid_xwiddeleg_rev[7] = wid_rwiddeleg_r[63-7];
assign wid_xwiddeleg_rev[8] = wid_rwiddeleg_r[63-8];
assign wid_xwiddeleg_rev[9] = wid_rwiddeleg_r[63-9];
assign wid_xwiddeleg_rev[10] = wid_rwiddeleg_r[63-10];
assign wid_xwiddeleg_rev[11] = wid_rwiddeleg_r[63-11];
assign wid_xwiddeleg_rev[12] = wid_rwiddeleg_r[63-12];
assign wid_xwiddeleg_rev[13] = wid_rwiddeleg_r[63-13];
assign wid_xwiddeleg_rev[14] = wid_rwiddeleg_r[63-14];
assign wid_xwiddeleg_rev[15] = wid_rwiddeleg_r[63-15];
assign wid_xwiddeleg_rev[16] = wid_rwiddeleg_r[63-16];
assign wid_xwiddeleg_rev[17] = wid_rwiddeleg_r[63-17];
assign wid_xwiddeleg_rev[18] = wid_rwiddeleg_r[63-18];
assign wid_xwiddeleg_rev[19] = wid_rwiddeleg_r[63-19];
assign wid_xwiddeleg_rev[20] = wid_rwiddeleg_r[63-20];
assign wid_xwiddeleg_rev[21] = wid_rwiddeleg_r[63-21];
assign wid_xwiddeleg_rev[22] = wid_rwiddeleg_r[63-22];
assign wid_xwiddeleg_rev[23] = wid_rwiddeleg_r[63-23];
assign wid_xwiddeleg_rev[24] = wid_rwiddeleg_r[63-24];
assign wid_xwiddeleg_rev[25] = wid_rwiddeleg_r[63-25];
assign wid_xwiddeleg_rev[26] = wid_rwiddeleg_r[63-26];
assign wid_xwiddeleg_rev[27] = wid_rwiddeleg_r[63-27];
assign wid_xwiddeleg_rev[28] = wid_rwiddeleg_r[63-28];
assign wid_xwiddeleg_rev[29] = wid_rwiddeleg_r[63-29];
assign wid_xwiddeleg_rev[30] = wid_rwiddeleg_r[63-30];
assign wid_xwiddeleg_rev[31] = wid_rwiddeleg_r[63-31];
assign wid_xwiddeleg_rev[32] = wid_rwiddeleg_r[63-32];
assign wid_xwiddeleg_rev[33] = wid_rwiddeleg_r[63-33];
assign wid_xwiddeleg_rev[34] = wid_rwiddeleg_r[63-34];
assign wid_xwiddeleg_rev[35] = wid_rwiddeleg_r[63-35];
assign wid_xwiddeleg_rev[36] = wid_rwiddeleg_r[63-36];
assign wid_xwiddeleg_rev[37] = wid_rwiddeleg_r[63-37];
assign wid_xwiddeleg_rev[38] = wid_rwiddeleg_r[63-38];
assign wid_xwiddeleg_rev[39] = wid_rwiddeleg_r[63-39];
assign wid_xwiddeleg_rev[40] = wid_rwiddeleg_r[63-40];
assign wid_xwiddeleg_rev[41] = wid_rwiddeleg_r[63-41];
assign wid_xwiddeleg_rev[42] = wid_rwiddeleg_r[63-42];
assign wid_xwiddeleg_rev[43] = wid_rwiddeleg_r[63-43];
assign wid_xwiddeleg_rev[44] = wid_rwiddeleg_r[63-44];
assign wid_xwiddeleg_rev[45] = wid_rwiddeleg_r[63-45];
assign wid_xwiddeleg_rev[46] = wid_rwiddeleg_r[63-46];
assign wid_xwiddeleg_rev[47] = wid_rwiddeleg_r[63-47];
assign wid_xwiddeleg_rev[48] = wid_rwiddeleg_r[63-48];
assign wid_xwiddeleg_rev[49] = wid_rwiddeleg_r[63-49];
assign wid_xwiddeleg_rev[50] = wid_rwiddeleg_r[63-50];
assign wid_xwiddeleg_rev[51] = wid_rwiddeleg_r[63-51];
assign wid_xwiddeleg_rev[52] = wid_rwiddeleg_r[63-52];
assign wid_xwiddeleg_rev[53] = wid_rwiddeleg_r[63-53];
assign wid_xwiddeleg_rev[54] = wid_rwiddeleg_r[63-54];
assign wid_xwiddeleg_rev[55] = wid_rwiddeleg_r[63-55];
assign wid_xwiddeleg_rev[56] = wid_rwiddeleg_r[63-56];
assign wid_xwiddeleg_rev[57] = wid_rwiddeleg_r[63-57];
assign wid_xwiddeleg_rev[58] = wid_rwiddeleg_r[63-58];
assign wid_xwiddeleg_rev[59] = wid_rwiddeleg_r[63-59];
assign wid_xwiddeleg_rev[60] = wid_rwiddeleg_r[63-60];
assign wid_xwiddeleg_rev[61] = wid_rwiddeleg_r[63-61];
assign wid_xwiddeleg_rev[62] = wid_rwiddeleg_r[63-62];
assign wid_xwiddeleg_rev[63] = wid_rwiddeleg_r[63-63];


// leading one detection


wire                       hi_no_hit;
wire                       lo_no_hit;
wire    [4:0]  hi_dout;
wire    [4:0]  lo_dout;
reg     [5:0]       lod_result;

wire    [`WID_RANGE]       mlwid_fin;

rl_bitscan_32b u_rl_bitscan_hi(
  .din  (wid_xwiddeleg_rev[63:33]),
  .dout (hi_dout),
  .no_hit (hi_no_hit)
);

rl_bitscan_32b u_rl_bitscan_lo(
  .din  (wid_xwiddeleg_rev[31:1]),
  .dout (lo_dout),
  .no_hit (lo_no_hit)
);

always @*
begin
  casez ({hi_no_hit, wid_xwiddeleg_rev[32], lo_no_hit, wid_xwiddeleg_rev[0]})
    4'b0???:lod_result = {1'b0,  hi_dout}; //0..30
    4'b11??:lod_result = {1'b0, {5{1'b1}}}; //31
    4'b100?:lod_result = {1'b1,  lo_dout}; //32..62
    4'b1011:lod_result = {1'b1, {5{1'b1}}}; //63
    //4'b1010:lod_result = {2'b10, {5{1'b0}}}; //32
    default:lod_result = 6'b00_0000;
  endcase
end // lod_result_PROC

assign wid_rwiddeleg_lst_lgl_val = lod_result[`WID_RANGE];

assign mlwid_fin = (wid_rwiddeleg_r == 0) ? wid_rlwid_r : wid_rwiddeleg_r[mlwid_r]? mlwid_r : wid_rwiddeleg_lst_lgl_val;

assign wid = (priv_level_r == `PRIV_M) ? wid_rlwid_r : mlwid_fin;


//////////////////////////////////////////////////////////////////////////////////////////
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////

assign csr_x2_dbg_rd_err = csr_x2_dbg_rd_err_r;
assign csr_x2_data       = csr_x2_data_r;
assign trap_return       = csr_trap_ret_r | rnmi_ret_r;
assign csr_trap_ret      = (csr_x2_mret & (priv_level_r != mstatus_r[`MPP_RANGE])) | (csr_x2_mnret & (priv_level_r != mnstatus_r[`MPP_RANGE]));
assign break_excpn       = ((!dcsr_r[`DCSR_EBM_BIT]) & (priv_level_r == `PRIV_M)) | ((!dcsr_r[`DCSR_EBU_BIT]) & (priv_level_r == `PRIV_U));
// @@@ Temp Stub
assign fatal_err_dbg     = dcsr_r[`DCSR_CETRIG_BIT];
//assign break_excpn     = 1'b0; 
assign break_halt        = ((dcsr_r[`DCSR_EBM_BIT]) & (priv_level_r == `PRIV_M)) | ((dcsr_r[`DCSR_EBU_BIT]) & (priv_level_r == `PRIV_U));
//assign break_halt      = (priv_level_r == `PRIV_M) | (priv_level_r == `PRIV_U);

assign mprven_r        = dcsr_r[`DCSR_MPRVEN_BIT];
assign mcause_o        = mcause_r[5:0];

assign arcv_mecc_diag_ecc = arcv_mecc_diagnostic_r[7:0];
assign arcv_mesb_ctrl     = arcv_mesb_ctrl_r;
assign mtvec_mode      = mtvec_r[1];
assign vec_mode        = mtvec_r[0];




endmodule // rl_csr
