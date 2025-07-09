// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2014 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2014, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
// @f:rl_hpm
//
// Description:
// @p
//     This module implements the logic used to manage the processing of
//   performance counters
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o rl_hpm.vpp
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"
`include "ifu_defines.v"
`include "alu_defines.v"
`include "dmp_defines.v"
`include "mpy_defines.v"
`include "hpm_defines.v"
`include "csr_defines.v"

// Set simulation timescale
//
`include "const.def"





`define hpm_build_counters  18:11
`define hpm_build_int       10
`define hpm_build_size      9:8
`define hpm_build_version   7:0
`define lsb                 0
`define HALF_WORD_RANGE     15:0

module rl_hpm (
  //IFU
  input [`ARCV_MC_OP_RANGE]   arcv_mcache_op      ,

  //ISA
  input                       csr_x1_read         ,
  input                       csr_x1_write        ,
  input                       csr_x2_pass         ,
  input                       csr_x2_wen          ,
  input [`INST_RANGE]         x2_inst             ,
  input                       spc_x2_wfi          ,
  input                       spc_x2_ecall        ,
  input                       x2_valid_r          ,
  input                       x1_pass             ,
  input [`BR_CTL_RANGE]       x1_br_ctl           ,
  input                       br_x2_taken_r       ,
  input                       irq_enable          ,
  input                       ar_clock_enable_r   ,
  input                       uop_busy_del        ,

  input                       db_active_r         ,


  input [`CSR_CTL_RANGE]      x1_csr_ctl          ,

  input                       hpm_bissue          ,
  input                       hpm_bicmstall       ,
  input                       hpm_bifsync         ,
  input                       hpm_bdfsync         ,
  input                       hpm_icm             ,

  //EXU
  input                       x1_stall            ,
  input                       spc_x2_stall        ,
  input                       trap_return         ,
  input                       halt_restart_r      ,
  input                       x1_raw_hazard       ,
  input                       x1_waw_hazard       ,
  input                       x1_valid_r          ,
  input                       csr_flush_r         ,
  input                       alu_x2_stall        ,
  input                       mpy_x3_stall        ,
  input                       soft_reset_x2_stall ,
  input                       cp_flush            ,

  input                       debug_mode          ,
  input                       trap_x2_valid       ,
  input                       take_int            ,
  input                       debug_mode_r        ,
  input                       sys_halt_r          ,
  input                       dmp_x2_load_r       ,
  input                       dmp_x2_store_r      ,
  input                       dmp_x2_lr_r         ,
  input                       dmp_x2_sc_r         ,
  input                       dmp_x2_amo_r        ,

  //DMP
  input                       dmp_x1_stall        ,
  input                       dmp_x2_stall        ,
  input                       hpm_dmpreplay       ,
  input                       hpm_bdmpcwb         ,
  input                       hpm_bdmplsq         ,

  output reg                  hpm_int_overflow_r  ,

  input [`CNT_CTRL_RANGE]     mcountinhibit_r, 
  input [`CNT_CTRL_RANGE]     mcounteren_r,
  input                       instret_ovf,
  input                       cycle_ovf,
  input                       time_ovf,


////////// CSR access interface /////////////////////////////////////////
  //
  input [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input [11:0]                    csr_sel_addr,          // (X1) CSR address
  
  output reg [`DATA_RANGE]        csr_rdata,             // (X1) CSR read data
  output reg                      csr_illegal,           // (X1) illegal
  output reg                      csr_unimpl,            // (X1) Invalid CSR
  output reg                      csr_serial_sr,         // (X1) SR group flush pipe
  output reg                      csr_strict_sr,         // (X1) SR flush pipe
  
  input                           csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input [11:0]                    csr_waddr,             // (X2) CSR addr
  input [`DATA_RANGE]             csr_wdata,             // (X2) Write data
  input                           csr_hpm_range,

  input                           x2_pass,               // (X2) commit
  input [1:0]                     priv_level_r,

//clock gating
  output                          pct_unit_enable,
  output                          hpm_int_overflow_rising,

//General input sinals
  
  input                           clk,
  input                           rst_a               

);

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Declare the payload signals.                                           //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

reg      p_i2byte;
reg      p_i2byte_r;
reg      p_i4byte;
reg      p_i4byte_r;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Declare the countable event signals.                                   //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

reg     i_never; // Cycles: False or 0 condition for use in metrics
reg     i_bstall; // Bubbles: includes bissue, bmemrw, bbranch, bexec, bsyncstall, btrap
reg     i_bissue; // Bubbles: includes bicmstall, bitlbmiss, bifustall
reg     i_bmemrw; // Bubbles: includes bdcmstall, bdtlbmiss, bdmp
reg     i_bexec; // Bubbles: includes bestruct, bdepstall
reg     i_bsyncstall; // Bubbles: includes bifsync, bbpstall, bdfsync, bdcflsh, bauxflsh
reg     i_btrap; // Bubbles: Caused by taking or returning from interrupts or exceptions, and when performing debug operations.
reg     i_bicmstall; // Bubbles: IC miss stall
reg     i_bdmp; // Bubbles: includes bdstrhaz, bdcpm, bdreplay
reg     i_bestruct; // Bubbles: includes bwpcflt, bgbstall, bfpbusy, buopstal, brgbank, bstrstall
reg     i_bdepstall; // Bubbles: includes badrld, bdcldrwd, bfstfpu, bximul, bxidiv, bflgstal, baccstal, bxdata
reg     i_bifsync; // Bubbles: Caused by operations that synchronize I-cache with main memory, such as an IFENCE.I instruction 
reg     i_bdfsync; // Bubbles: Bubbles caused by operations that enforce memory barriers, such as FENCE (RISC-V).
reg     i_bauxflsh; // Bubbles: Auxiliary Flush
reg     i_bfirqex; // Bubbles: Interrupt or Exception taken
reg     i_bdebug; // Bubbles: Bubbles in the normal execution of instructions due to the presence of debug operations in the pipeline.
reg     i_bdstrhaz; // Bubbles: includes bdcbc, bdclbuf, bdqstall, bdcstall
reg     i_bdreplay; // Bubbles: Caused by replaying memory instructions, because of reasons not covered in bdcmp or bdcmstall or bdtlbmiss.
reg     i_bdqstall; // Bubbles: includes bdmpwq, bdmplq
reg     i_bdcstall; // Bubbles: DMP stall
reg     i_bdmpcwb; // Bubbles: CWB stall because the CCM Write Buffer full.
reg     i_bdmplsq; // Bubbles: LSQ stall becasue of load store queue full
reg     i_icsr; // Instrs: 
reg     i_i2byte; // Instrs: 16-bit
reg     i_i4byte; // Instrs: 32-bit
reg     i_iwfi; // Instrs: 
reg     i_iecall; // Instrs: 
reg     i_ipropcmoic; // Instrs: Counts number of instructions that initiate Instruction Cache CMOs
reg     i_ialljmp; // Instrs: All Jump/Branch instructions
reg     i_ijmpc; // Instrs: Jump conditional taken
reg     i_ijmpu; // Instrs: Jump unconditional taken
reg     i_ijmptak; // Instrs: Jump taken
reg     i_icall; // Instrs: linked subroutine call
reg     i_icallret; // Instrs: 
reg     i_imemrd; // Instrs: Memory Read
reg     i_imemwr; // Instrs: Memory Write
reg     i_ilr; // Instrs: Auxiliary Register Read (LR)
reg     i_isc; // Instrs: 
reg     i_imematomic; // Instrs: TBD
reg     i_icm; // Event: Instruction cache miss
reg     i_dbgflush; // Event: Debugger transaction caused pipeline flush
reg     i_etaken; // Event: Exception taken
reg     i_qtaken; // Event: Interrupt taken
reg     i_dmpreplay; // Event: Total number of LD/ST replays (pipe flush) triggered by the DMP
reg     i_always; // Cycles: True or 1 condition for use in metric
reg     i_crun; // Cycles: CPU is running
reg     i_cruni; // Cycles: CPU is running with interrupts enabled

reg                           s_csr_rd_r             ;
reg                           s_csr_wr_r             ;
reg                           s_i2byte_r             ;
reg                           s_i4byte_r             ;
reg                           s_iwfi_r               ;
reg                           s_iecall_r             ;
reg                           s_ialljmp_r            ;
reg                           s_ijmpc_r              ;
reg                           s_ijmpu_r              ;
reg                           s_ijmptak_r            ;
reg                           s_icall_r              ;
reg                           s_icallret_r           ;
reg                           s_imemrd_r             ;
reg                           s_imemwr_r             ;
reg                           s_ilr_r                ;
reg                           s_isc_r                ;
reg                           s_imematomic_r         ;

reg                           s_dbgflush_r           ;           
reg                           s_etaken_r             ;
reg                           s_qtaken_r             ;

reg                           s_crun_r               ;
reg                           s_cruni_r              ;


reg                           s_bissue_r             ;
reg                           s_bicmstall_r          ;
reg                           s_bifsync_r            ;
reg                           s_bdfsync_r            ;
reg                           s_icm_r                ;

reg                           s_bstall_r             ;
reg                           s_btrap_r              ;
reg                           s_bestruct_r           ;
reg                           s_bdepstall_r          ;
reg                           s_bauxflsh_r           ;
reg                           s_bfirqex_r            ;
reg                           s_bdebug_r             ;      

//DMP
reg                           s_bdcstall_r           ;
reg                           s_dmpreplay_r          ;
reg                           s_bdmpcwb_r            ;
reg                           s_bdmplsq_r            ;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Declare the qualified signals for monitoring. These signals will be    //
// cleared by a downstream kill or stall signal if required.              //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

reg                           q_icsr              ;
reg                           q_i2byte            ;
reg                           q_i4byte            ;
reg                           q_iwfi              ;
reg                           q_iecall            ;
reg                           q_ialljmp           ;
reg                           q_ijmpc             ;
reg                           q_ijmpu             ;
reg                           q_ijmptak           ;
reg                           q_icall             ;
reg                           q_icallret          ;
reg                           q_ipropcmoic        ;
reg                           q_imemrd            ;
reg                           q_imemwr            ;
reg                           q_ilr               ;
reg                           q_isc               ;
reg                           q_imematomic        ;

reg                           q_dbgflush          ;
reg                           q_etaken            ;
reg                           q_qtaken            ;

reg                           q_crun              ;
reg                           q_cruni             ;


reg                           q_bissue            ;
reg                           q_bicmstall         ;
reg                           q_bifsync           ;
reg                           q_bdfsync           ;
reg                           q_icm               ;

reg                           q_bstall            ;
reg                           q_btrap             ;
reg                           q_bestruct          ;
reg                           q_bdepstall         ;
reg                           q_bauxflsh          ;
reg                           q_bfirqex           ;
reg                           q_bdebug            ;

//DMP
reg                           q_bdcstall          ;
reg                           q_dmpreplay         ;
reg                           q_bdmpcwb           ;
reg                           q_bdmplsq           ;

reg     [`PCT_EVENTS_RANGE]   all_events_r /* verilator public_flat */; // registered count events 

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Declare the CC_<> aux register fields                                  //
//                                                                        //
////////////////////////////////////////////////////////////////////////////


reg [`QUAD_RANGE]    idx_name                     ; 



////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Declare PCT_COUNTL, PCT_COUNTH, PCT_SNAPL, PCT_SNAPH and PCT_CONFIG    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

reg                           count3_payload   ;
reg                           inc_count3         ;

reg                           count4_payload   ;
reg                           inc_count4         ;

reg                           count5_payload   ;
reg                           inc_count5         ;

reg                           count6_payload   ;
reg                           inc_count6         ;

reg                           count7_payload   ;
reg                           inc_count7         ;

reg                           count8_payload   ;
reg                           inc_count8         ;

reg                           count9_payload   ;
reg                           inc_count9         ;

reg                           count10_payload   ;
reg                           inc_count10         ;


reg [`WORD_RANGE]             int_active_nxt      ;

  reg [`WORD_RANGE]  mhpmevent3_r;
  reg                mhpmevent3_expl_wen;
  reg [`WORD_RANGE]  mhpmevent4_r;
  reg                mhpmevent4_expl_wen;
  reg [`WORD_RANGE]  mhpmevent5_r;
  reg                mhpmevent5_expl_wen;
  reg [`WORD_RANGE]  mhpmevent6_r;
  reg                mhpmevent6_expl_wen;
  reg [`WORD_RANGE]  mhpmevent7_r;
  reg                mhpmevent7_expl_wen;
  reg [`WORD_RANGE]  mhpmevent8_r;
  reg                mhpmevent8_expl_wen;
  reg [`WORD_RANGE]  mhpmevent9_r;
  reg                mhpmevent9_expl_wen;
  reg [`WORD_RANGE]  mhpmevent10_r;
  reg                mhpmevent10_expl_wen;

  wire [`WORD_RANGE]  mhpmevent11_r;
  wire [`WORD_RANGE]  mhpmevent12_r;
  wire [`WORD_RANGE]  mhpmevent13_r;
  wire [`WORD_RANGE]  mhpmevent14_r;
  wire [`WORD_RANGE]  mhpmevent15_r;
  wire [`WORD_RANGE]  mhpmevent16_r;
  wire [`WORD_RANGE]  mhpmevent17_r;
  wire [`WORD_RANGE]  mhpmevent18_r;
  wire [`WORD_RANGE]  mhpmevent19_r;
  wire [`WORD_RANGE]  mhpmevent20_r;
  wire [`WORD_RANGE]  mhpmevent21_r;
  wire [`WORD_RANGE]  mhpmevent22_r;
  wire [`WORD_RANGE]  mhpmevent23_r;
  wire [`WORD_RANGE]  mhpmevent24_r;
  wire [`WORD_RANGE]  mhpmevent25_r;
  wire [`WORD_RANGE]  mhpmevent26_r;
  wire [`WORD_RANGE]  mhpmevent27_r;
  wire [`WORD_RANGE]  mhpmevent28_r;
  wire [`WORD_RANGE]  mhpmevent29_r;
  wire [`WORD_RANGE]  mhpmevent30_r;
  wire [`WORD_RANGE]  mhpmevent31_r;

  reg [`WORD_RANGE]  csr_arcv_mhpmeventindex_r;
  reg                csr_arcv_mhpmeventindex_expl_wen;
  reg [`WORD_RANGE]  csr_arcv_mcounterinten_r;
  reg                csr_arcv_mcounterinten_expl_wen;
  reg [`WORD_RANGE]  csr_arcv_mcounterintact_r;
  reg                csr_arcv_mcounterintact_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter3_r;
  reg                mhpmcounter3_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter4_r;
  reg                mhpmcounter4_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter5_r;
  reg                mhpmcounter5_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter6_r;
  reg                mhpmcounter6_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter7_r;
  reg                mhpmcounter7_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter8_r;
  reg                mhpmcounter8_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter9_r;
  reg                mhpmcounter9_expl_wen;
  reg [`WORD_RANGE]  mhpmcounter10_r;
  reg                mhpmcounter10_expl_wen;
  reg [`WORD_RANGE]  csr_arcv_mhpmeventname0_r;
  reg [`WORD_RANGE]  csr_arcv_mhpmeventname1_r;
  reg [`WORD_RANGE]  csr_arcv_mhpmeventname2_r;
  reg [`WORD_RANGE]  csr_arcv_mhpmeventname3_r;
  reg [`WORD_RANGE]  hpmcounter3_r;
  reg [`WORD_RANGE]  hpmcounter4_r;
  reg [`WORD_RANGE]  hpmcounter5_r;
  reg [`WORD_RANGE]  hpmcounter6_r;
  reg [`WORD_RANGE]  hpmcounter7_r;
  reg [`WORD_RANGE]  hpmcounter8_r;
  reg [`WORD_RANGE]  hpmcounter9_r;
  reg [`WORD_RANGE]  hpmcounter10_r;

  reg [`WORD_RANGE]  mhpmcounter3h_r;
  reg [`WORD_RANGE]  mhpmcounter4h_r;
  reg [`WORD_RANGE]  mhpmcounter5h_r;
  reg [`WORD_RANGE]  mhpmcounter6h_r;
  reg [`WORD_RANGE]  mhpmcounter7h_r;
  reg [`WORD_RANGE]  mhpmcounter8h_r;
  reg [`WORD_RANGE]  mhpmcounter9h_r;
  reg [`WORD_RANGE]  mhpmcounter10h_r;
  reg                mhpmcounter3h_expl_wen;
  reg                mhpmcounter4h_expl_wen;
  reg                mhpmcounter5h_expl_wen;
  reg                mhpmcounter6h_expl_wen;
  reg                mhpmcounter7h_expl_wen;
  reg                mhpmcounter8h_expl_wen;
  reg                mhpmcounter9h_expl_wen;
  reg                mhpmcounter10h_expl_wen;

  reg [`WORD_RANGE]  hpmcounter3h_r;
  reg [`WORD_RANGE]  hpmcounter4h_r;
  reg [`WORD_RANGE]  hpmcounter5h_r;
  reg [`WORD_RANGE]  hpmcounter6h_r;
  reg [`WORD_RANGE]  hpmcounter7h_r;
  reg [`WORD_RANGE]  hpmcounter8h_r;
  reg [`WORD_RANGE]  hpmcounter9h_r;
  reg [`WORD_RANGE]  hpmcounter10h_r;

  wire [`WORD_RANGE]  mhpmcounter11_r;
  wire [`WORD_RANGE]  mhpmcounter11h_r;
  wire [`WORD_RANGE]  mhpmcounter12_r;
  wire [`WORD_RANGE]  mhpmcounter12h_r;
  wire [`WORD_RANGE]  mhpmcounter13_r;
  wire [`WORD_RANGE]  mhpmcounter13h_r;
  wire [`WORD_RANGE]  mhpmcounter14_r;
  wire [`WORD_RANGE]  mhpmcounter14h_r;
  wire [`WORD_RANGE]  mhpmcounter15_r;
  wire [`WORD_RANGE]  mhpmcounter15h_r;
  wire [`WORD_RANGE]  mhpmcounter16_r;
  wire [`WORD_RANGE]  mhpmcounter16h_r;
  wire [`WORD_RANGE]  mhpmcounter17_r;
  wire [`WORD_RANGE]  mhpmcounter17h_r;
  wire [`WORD_RANGE]  mhpmcounter18_r;
  wire [`WORD_RANGE]  mhpmcounter18h_r;
  wire [`WORD_RANGE]  mhpmcounter19_r;
  wire [`WORD_RANGE]  mhpmcounter19h_r;
  wire [`WORD_RANGE]  mhpmcounter20_r;
  wire [`WORD_RANGE]  mhpmcounter20h_r;
  wire [`WORD_RANGE]  mhpmcounter21_r;
  wire [`WORD_RANGE]  mhpmcounter21h_r;
  wire [`WORD_RANGE]  mhpmcounter22_r;
  wire [`WORD_RANGE]  mhpmcounter22h_r;
  wire [`WORD_RANGE]  mhpmcounter23_r;
  wire [`WORD_RANGE]  mhpmcounter23h_r;
  wire [`WORD_RANGE]  mhpmcounter24_r;
  wire [`WORD_RANGE]  mhpmcounter24h_r;
  wire [`WORD_RANGE]  mhpmcounter25_r;
  wire [`WORD_RANGE]  mhpmcounter25h_r;
  wire [`WORD_RANGE]  mhpmcounter26_r;
  wire [`WORD_RANGE]  mhpmcounter26h_r;
  wire [`WORD_RANGE]  mhpmcounter27_r;
  wire [`WORD_RANGE]  mhpmcounter27h_r;
  wire [`WORD_RANGE]  mhpmcounter28_r;
  wire [`WORD_RANGE]  mhpmcounter28h_r;
  wire [`WORD_RANGE]  mhpmcounter29_r;
  wire [`WORD_RANGE]  mhpmcounter29h_r;
  wire [`WORD_RANGE]  mhpmcounter30_r;
  wire [`WORD_RANGE]  mhpmcounter30h_r;
  wire [`WORD_RANGE]  mhpmcounter31_r;
  wire [`WORD_RANGE]  mhpmcounter31h_r;

  wire [`WORD_RANGE]  hpmcounter11_r;
  wire [`WORD_RANGE]  hpmcounter11h_r;
  wire [`WORD_RANGE]  hpmcounter12_r;
  wire [`WORD_RANGE]  hpmcounter12h_r;
  wire [`WORD_RANGE]  hpmcounter13_r;
  wire [`WORD_RANGE]  hpmcounter13h_r;
  wire [`WORD_RANGE]  hpmcounter14_r;
  wire [`WORD_RANGE]  hpmcounter14h_r;
  wire [`WORD_RANGE]  hpmcounter15_r;
  wire [`WORD_RANGE]  hpmcounter15h_r;
  wire [`WORD_RANGE]  hpmcounter16_r;
  wire [`WORD_RANGE]  hpmcounter16h_r;
  wire [`WORD_RANGE]  hpmcounter17_r;
  wire [`WORD_RANGE]  hpmcounter17h_r;
  wire [`WORD_RANGE]  hpmcounter18_r;
  wire [`WORD_RANGE]  hpmcounter18h_r;
  wire [`WORD_RANGE]  hpmcounter19_r;
  wire [`WORD_RANGE]  hpmcounter19h_r;
  wire [`WORD_RANGE]  hpmcounter20_r;
  wire [`WORD_RANGE]  hpmcounter20h_r;
  wire [`WORD_RANGE]  hpmcounter21_r;
  wire [`WORD_RANGE]  hpmcounter21h_r;
  wire [`WORD_RANGE]  hpmcounter22_r;
  wire [`WORD_RANGE]  hpmcounter22h_r;
  wire [`WORD_RANGE]  hpmcounter23_r;
  wire [`WORD_RANGE]  hpmcounter23h_r;
  wire [`WORD_RANGE]  hpmcounter24_r;
  wire [`WORD_RANGE]  hpmcounter24h_r;
  wire [`WORD_RANGE]  hpmcounter25_r;
  wire [`WORD_RANGE]  hpmcounter25h_r;
  wire [`WORD_RANGE]  hpmcounter26_r;
  wire [`WORD_RANGE]  hpmcounter26h_r;
  wire [`WORD_RANGE]  hpmcounter27_r;
  wire [`WORD_RANGE]  hpmcounter27h_r;
  wire [`WORD_RANGE]  hpmcounter28_r;
  wire [`WORD_RANGE]  hpmcounter28h_r;
  wire [`WORD_RANGE]  hpmcounter29_r;
  wire [`WORD_RANGE]  hpmcounter29h_r;
  wire [`WORD_RANGE]  hpmcounter30_r;
  wire [`WORD_RANGE]  hpmcounter30h_r;
  wire [`WORD_RANGE]  hpmcounter31_r;
  wire [`WORD_RANGE]  hpmcounter31h_r;

reg                  csr_illegal_hpm;
reg                  hpm_int_overflow_d;

//CSR explicit write enable process
//
always @*
begin : csr_write_enable_PROC
  mhpmevent3_expl_wen = 1'b0;  
  mhpmevent4_expl_wen = 1'b0;  
  mhpmevent5_expl_wen = 1'b0;  
  mhpmevent6_expl_wen = 1'b0;  
  mhpmevent7_expl_wen = 1'b0;  
  mhpmevent8_expl_wen = 1'b0;  
  mhpmevent9_expl_wen = 1'b0;  
  mhpmevent10_expl_wen = 1'b0;  
  csr_arcv_mhpmeventindex_expl_wen = 1'b0; 
  csr_arcv_mcounterinten_expl_wen  = 1'b0;
  csr_arcv_mcounterintact_expl_wen = 1'b0;
  mhpmcounter3_expl_wen = 1'b0;     
  mhpmcounter4_expl_wen = 1'b0;     
  mhpmcounter5_expl_wen = 1'b0;     
  mhpmcounter6_expl_wen = 1'b0;     
  mhpmcounter7_expl_wen = 1'b0;     
  mhpmcounter8_expl_wen = 1'b0;     
  mhpmcounter9_expl_wen = 1'b0;     
  mhpmcounter10_expl_wen = 1'b0;     
  mhpmcounter3h_expl_wen = 1'b0;     
  mhpmcounter4h_expl_wen = 1'b0;     
  mhpmcounter5h_expl_wen = 1'b0;     
  mhpmcounter6h_expl_wen = 1'b0;     
  mhpmcounter7h_expl_wen = 1'b0;     
  mhpmcounter8h_expl_wen = 1'b0;     
  mhpmcounter9h_expl_wen = 1'b0;     
  mhpmcounter10h_expl_wen = 1'b0;     
  if(csr_write)
  begin
    case(csr_waddr)
    `CSR_MHPMEVENT3:  mhpmevent3_expl_wen = x2_pass;     
    `CSR_MHPMEVENT4:  mhpmevent4_expl_wen = x2_pass;     
    `CSR_MHPMEVENT5:  mhpmevent5_expl_wen = x2_pass;     
    `CSR_MHPMEVENT6:  mhpmevent6_expl_wen = x2_pass;     
    `CSR_MHPMEVENT7:  mhpmevent7_expl_wen = x2_pass;     
    `CSR_MHPMEVENT8:  mhpmevent8_expl_wen = x2_pass;     
    `CSR_MHPMEVENT9:  mhpmevent9_expl_wen = x2_pass;     
    `CSR_MHPMEVENT10:  mhpmevent10_expl_wen = x2_pass;     
    `CSR_ARCV_MHPMEVENTINDEX : csr_arcv_mhpmeventindex_expl_wen = x2_pass; 
    `CSR_ARCV_MCOUNTERINTEN  : csr_arcv_mcounterinten_expl_wen  = x2_pass; 
    `CSR_ARCV_MCOUNTERINTACT : csr_arcv_mcounterintact_expl_wen = x2_pass; 
    `CSR_MHPMCOUNTER3:mhpmcounter3_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER4:mhpmcounter4_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER5:mhpmcounter5_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER6:mhpmcounter6_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER7:mhpmcounter7_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER8:mhpmcounter8_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER9:mhpmcounter9_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER10:mhpmcounter10_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER3H:mhpmcounter3h_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER4H:mhpmcounter4h_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER5H:mhpmcounter5h_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER6H:mhpmcounter6h_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER7H:mhpmcounter7h_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER8H:mhpmcounter8h_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER9H:mhpmcounter9h_expl_wen = x2_pass;     
    `CSR_MHPMCOUNTER10H:mhpmcounter10h_expl_wen = x2_pass;     
// spyglass disable_block W193 
// SMD: empty statements
// SJ:  empty default statements kept
    default: ;
// spyglass enable_block W193
    endcase
  end
end


//CSR read process
//
always @*
begin : csr_read_PROC
  csr_rdata      = {`WORD_SIZE{1'b0}};     
  csr_illegal    = 1'b0;            
  csr_unimpl     = 1'b1;      
  csr_serial_sr  = 1'b0;  
  csr_strict_sr  = 1'b0;

  csr_illegal = csr_illegal_hpm;

  if (csr_sel_ctl != 2'b00)
  begin
    case(csr_sel_addr)
    `CSR_MHPMEVENT3:
    begin
      csr_rdata    = mhpmevent3_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT4:
    begin
      csr_rdata    = mhpmevent4_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT5:
    begin
      csr_rdata    = mhpmevent5_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT6:
    begin
      csr_rdata    = mhpmevent6_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT7:
    begin
      csr_rdata    = mhpmevent7_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT8:
    begin
      csr_rdata    = mhpmevent8_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT9:
    begin
      csr_rdata    = mhpmevent9_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT10:
    begin
      csr_rdata    = mhpmevent10_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT11:
    begin
      csr_rdata    = mhpmevent11_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT12:
    begin
      csr_rdata    = mhpmevent12_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT13:
    begin
      csr_rdata    = mhpmevent13_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT14:
    begin
      csr_rdata    = mhpmevent14_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT15:
    begin
      csr_rdata    = mhpmevent15_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT16:
    begin
      csr_rdata    = mhpmevent16_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT17:
    begin
      csr_rdata    = mhpmevent17_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT18:
    begin
      csr_rdata    = mhpmevent18_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT19:
    begin
      csr_rdata    = mhpmevent19_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT20:
    begin
      csr_rdata    = mhpmevent20_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT21:
    begin
      csr_rdata    = mhpmevent21_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT22:
    begin
      csr_rdata    = mhpmevent22_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT23:
    begin
      csr_rdata    = mhpmevent23_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT24:
    begin
      csr_rdata    = mhpmevent24_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT25:
    begin
      csr_rdata    = mhpmevent25_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT26:
    begin
      csr_rdata    = mhpmevent26_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT27:
    begin
      csr_rdata    = mhpmevent27_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT28:
    begin
      csr_rdata    = mhpmevent28_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT29:
    begin
      csr_rdata    = mhpmevent29_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT30:
    begin
      csr_rdata    = mhpmevent30_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMEVENT31:
    begin
      csr_rdata    = mhpmevent31_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_ARCV_MHPMEVENTINDEX:
    begin
      csr_rdata    = csr_arcv_mhpmeventindex_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_ARCV_MCOUNTERINTEN:
    begin
      csr_rdata    = csr_arcv_mcounterinten_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_ARCV_MCOUNTERINTACT:
    begin
      csr_rdata    = csr_arcv_mcounterintact_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER3:
    begin
      csr_rdata    = mhpmcounter3_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER4:
    begin
      csr_rdata    = mhpmcounter4_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER5:
    begin
      csr_rdata    = mhpmcounter5_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER6:
    begin
      csr_rdata    = mhpmcounter6_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER7:
    begin
      csr_rdata    = mhpmcounter7_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER8:
    begin
      csr_rdata    = mhpmcounter8_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER9:
    begin
      csr_rdata    = mhpmcounter9_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER10:
    begin
      csr_rdata    = mhpmcounter10_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER11:
    begin
      csr_rdata    = mhpmcounter11_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER12:
    begin
      csr_rdata    = mhpmcounter12_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER13:
    begin
      csr_rdata    = mhpmcounter13_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER14:
    begin
      csr_rdata    = mhpmcounter14_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER15:
    begin
      csr_rdata    = mhpmcounter15_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER16:
    begin
      csr_rdata    = mhpmcounter16_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER17:
    begin
      csr_rdata    = mhpmcounter17_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER18:
    begin
      csr_rdata    = mhpmcounter18_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER19:
    begin
      csr_rdata    = mhpmcounter19_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER20:
    begin
      csr_rdata    = mhpmcounter20_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER21:
    begin
      csr_rdata    = mhpmcounter21_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER22:
    begin
      csr_rdata    = mhpmcounter22_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER23:
    begin
      csr_rdata    = mhpmcounter23_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER24:
    begin
      csr_rdata    = mhpmcounter24_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER25:
    begin
      csr_rdata    = mhpmcounter25_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER26:
    begin
      csr_rdata    = mhpmcounter26_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER27:
    begin
      csr_rdata    = mhpmcounter27_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER28:
    begin
      csr_rdata    = mhpmcounter28_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER29:
    begin
      csr_rdata    = mhpmcounter29_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER30:
    begin
      csr_rdata    = mhpmcounter30_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER31:
    begin
      csr_rdata    = mhpmcounter31_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER3H:
    begin
      csr_rdata    = mhpmcounter3h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER4H:
    begin
      csr_rdata    = mhpmcounter4h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER5H:
    begin
      csr_rdata    = mhpmcounter5h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER6H:
    begin
      csr_rdata    = mhpmcounter6h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER7H:
    begin
      csr_rdata    = mhpmcounter7h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER8H:
    begin
      csr_rdata    = mhpmcounter8h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER9H:
    begin
      csr_rdata    = mhpmcounter9h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER10H:
    begin
      csr_rdata    = mhpmcounter10h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER11H:
    begin
      csr_rdata    = mhpmcounter11h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER12H:
    begin
      csr_rdata    = mhpmcounter12h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER13H:
    begin
      csr_rdata    = mhpmcounter13h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER14H:
    begin
      csr_rdata    = mhpmcounter14h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER15H:
    begin
      csr_rdata    = mhpmcounter15h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER16H:
    begin
      csr_rdata    = mhpmcounter16h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER17H:
    begin
      csr_rdata    = mhpmcounter17h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER18H:
    begin
      csr_rdata    = mhpmcounter18h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER19H:
    begin
      csr_rdata    = mhpmcounter19h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER20H:
    begin
      csr_rdata    = mhpmcounter20h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER21H:
    begin
      csr_rdata    = mhpmcounter21h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER22H:
    begin
      csr_rdata    = mhpmcounter22h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER23H:
    begin
      csr_rdata    = mhpmcounter23h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER24H:
    begin
      csr_rdata    = mhpmcounter24h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER25H:
    begin
      csr_rdata    = mhpmcounter25h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER26H:
    begin
      csr_rdata    = mhpmcounter26h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER27H:
    begin
      csr_rdata    = mhpmcounter27h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER28H:
    begin
      csr_rdata    = mhpmcounter28h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER29H:
    begin
      csr_rdata    = mhpmcounter29h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER30H:
    begin
      csr_rdata    = mhpmcounter30h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_MHPMCOUNTER31H:
    begin
      csr_rdata    = mhpmcounter31h_r;
      csr_illegal  = (priv_level_r != `PRIV_M);
      csr_unimpl   = 1'b0;
    end
    `CSR_ARCV_MHPMEVENTNAME0:
    begin
      csr_rdata    = csr_arcv_mhpmeventname0_r;
      csr_illegal  = (priv_level_r != `PRIV_M) | csr_x1_write;
      csr_unimpl   = 1'b0;
    end
    `CSR_ARCV_MHPMEVENTNAME1:
    begin
      csr_rdata    = csr_arcv_mhpmeventname1_r;
      csr_illegal  = (priv_level_r != `PRIV_M) | csr_x1_write;
      csr_unimpl   = 1'b0;
    end
    `CSR_ARCV_MHPMEVENTNAME2:
    begin
      csr_rdata    = csr_arcv_mhpmeventname2_r;
      csr_illegal  = (priv_level_r != `PRIV_M) | csr_x1_write;
      csr_unimpl   = 1'b0;
    end
    `CSR_ARCV_MHPMEVENTNAME3:
    begin
      csr_rdata    = csr_arcv_mhpmeventname3_r;
      csr_illegal  = (priv_level_r != `PRIV_M) | csr_x1_write;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER3:
    begin
      csr_rdata    = hpmcounter3_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER4:
    begin
      csr_rdata    = hpmcounter4_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER5:
    begin
      csr_rdata    = hpmcounter5_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER6:
    begin
      csr_rdata    = hpmcounter6_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER7:
    begin
      csr_rdata    = hpmcounter7_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER8:
    begin
      csr_rdata    = hpmcounter8_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER9:
    begin
      csr_rdata    = hpmcounter9_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER10:
    begin
      csr_rdata    = hpmcounter10_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER11:
    begin
      csr_rdata    = hpmcounter11_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER12:
    begin
      csr_rdata    = hpmcounter12_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER13:
    begin
      csr_rdata    = hpmcounter13_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER14:
    begin
      csr_rdata    = hpmcounter14_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER15:
    begin
      csr_rdata    = hpmcounter15_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER16:
    begin
      csr_rdata    = hpmcounter16_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER17:
    begin
      csr_rdata    = hpmcounter17_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER18:
    begin
      csr_rdata    = hpmcounter18_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER19:
    begin
      csr_rdata    = hpmcounter19_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER20:
    begin
      csr_rdata    = hpmcounter20_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER21:
    begin
      csr_rdata    = hpmcounter21_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER22:
    begin
      csr_rdata    = hpmcounter22_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER23:
    begin
      csr_rdata    = hpmcounter23_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER24:
    begin
      csr_rdata    = hpmcounter24_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER25:
    begin
      csr_rdata    = hpmcounter25_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER26:
    begin
      csr_rdata    = hpmcounter26_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER27:
    begin
      csr_rdata    = hpmcounter27_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER28:
    begin
      csr_rdata    = hpmcounter28_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER29:
    begin
      csr_rdata    = hpmcounter29_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER30:
    begin
      csr_rdata    = hpmcounter30_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER31:
    begin
      csr_rdata    = hpmcounter31_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER3H:
    begin
      csr_rdata    = hpmcounter3h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER4H:
    begin
      csr_rdata    = hpmcounter4h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER5H:
    begin
      csr_rdata    = hpmcounter5h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER6H:
    begin
      csr_rdata    = hpmcounter6h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER7H:
    begin
      csr_rdata    = hpmcounter7h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER8H:
    begin
      csr_rdata    = hpmcounter8h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER9H:
    begin
      csr_rdata    = hpmcounter9h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER10H:
    begin
      csr_rdata    = hpmcounter10h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER11H:
    begin
      csr_rdata    = hpmcounter11h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER12H:
    begin
      csr_rdata    = hpmcounter12h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER13H:
    begin
      csr_rdata    = hpmcounter13h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER14H:
    begin
      csr_rdata    = hpmcounter14h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER15H:
    begin
      csr_rdata    = hpmcounter15h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER16H:
    begin
      csr_rdata    = hpmcounter16h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER17H:
    begin
      csr_rdata    = hpmcounter17h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER18H:
    begin
      csr_rdata    = hpmcounter18h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER19H:
    begin
      csr_rdata    = hpmcounter19h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER20H:
    begin
      csr_rdata    = hpmcounter20h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER21H:
    begin
      csr_rdata    = hpmcounter21h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER22H:
    begin
      csr_rdata    = hpmcounter22h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER23H:
    begin
      csr_rdata    = hpmcounter23h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER24H:
    begin
      csr_rdata    = hpmcounter24h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER25H:
    begin
      csr_rdata    = hpmcounter25h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER26H:
    begin
      csr_rdata    = hpmcounter26h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER27H:
    begin
      csr_rdata    = hpmcounter27h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER28H:
    begin
      csr_rdata    = hpmcounter28h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER29H:
    begin
      csr_rdata    = hpmcounter29h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER30H:
    begin
      csr_rdata    = hpmcounter30h_r;
      csr_unimpl   = 1'b0;
    end
    `CSR_HPMCOUNTER31H:
    begin
      csr_rdata    = hpmcounter31h_r;
      csr_unimpl   = 1'b0;
    end
//!BCR { num: 4035, val: 525825, name: "ARCV_HPM_BUILD" }
    `BCR_ARCV_HPM_BUILD:
    begin
      csr_rdata    = {8'd0,               //Reserved bits
                      8'd`HPM_COUNTERS,   //Number of counters
                      5'd0,               //Reserved bits
                      1'd`hpm_i,          //Interrupt
                      2'd`hpm_s,          //Counter size
                      8'd`hpm_ver};       //Version 
      csr_illegal  = (priv_level_r != `PRIV_M) | csr_x1_write;
      csr_unimpl   = 1'b0;
    end
// spyglass disable_block W193 
// SMD: empty statements
// SJ:  empty default statements kept
    default: ;
// spyglass enable_block W193
    endcase
  end
end


reg priv_mode_u;
reg priv_mode_s;
reg priv_mode_m;

//Find current privileg mode
//
always @*
begin : priv_mode_PROC

priv_mode_u = 1'b0;
priv_mode_s = 1'b0;
priv_mode_m = 1'b0;

case (priv_level_r)
  0 : priv_mode_u = 1'b1;
  1 : priv_mode_s = 1'b1;
  default : priv_mode_m = 1'b1;

endcase

end // priv_mode_PROC


wire hpmcounter3_illegal_access;
assign hpmcounter3_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[3]) | csr_x1_write;

wire hpmcounter3h_illegal_access;
assign hpmcounter3h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[3]) | csr_x1_write;

wire hpmcounter4_illegal_access;
assign hpmcounter4_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[4]) | csr_x1_write;

wire hpmcounter4h_illegal_access;
assign hpmcounter4h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[4]) | csr_x1_write;

wire hpmcounter5_illegal_access;
assign hpmcounter5_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[5]) | csr_x1_write;

wire hpmcounter5h_illegal_access;
assign hpmcounter5h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[5]) | csr_x1_write;

wire hpmcounter6_illegal_access;
assign hpmcounter6_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[6]) | csr_x1_write;

wire hpmcounter6h_illegal_access;
assign hpmcounter6h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[6]) | csr_x1_write;

wire hpmcounter7_illegal_access;
assign hpmcounter7_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[7]) | csr_x1_write;

wire hpmcounter7h_illegal_access;
assign hpmcounter7h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[7]) | csr_x1_write;

wire hpmcounter8_illegal_access;
assign hpmcounter8_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[8]) | csr_x1_write;

wire hpmcounter8h_illegal_access;
assign hpmcounter8h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[8]) | csr_x1_write;

wire hpmcounter9_illegal_access;
assign hpmcounter9_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[9]) | csr_x1_write;

wire hpmcounter9h_illegal_access;
assign hpmcounter9h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[9]) | csr_x1_write;

wire hpmcounter10_illegal_access;
assign hpmcounter10_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[10]) | csr_x1_write;

wire hpmcounter10h_illegal_access;
assign hpmcounter10h_illegal_access = ((priv_mode_u == 1'b1) && !mcounteren_r[10]) | csr_x1_write;


//Assert CSR illegal if no proper access privileg
always @*
begin : csr_read_illegal_PROC
  csr_illegal_hpm = 1'b0;
  if (csr_sel_ctl != 2'b00)
  begin
    case (csr_sel_addr)
    `CSR_HPMCOUNTER3 :  csr_illegal_hpm = hpmcounter3_illegal_access;
    `CSR_HPMCOUNTER4 :  csr_illegal_hpm = hpmcounter4_illegal_access;
    `CSR_HPMCOUNTER5 :  csr_illegal_hpm = hpmcounter5_illegal_access;
    `CSR_HPMCOUNTER6 :  csr_illegal_hpm = hpmcounter6_illegal_access;
    `CSR_HPMCOUNTER7 :  csr_illegal_hpm = hpmcounter7_illegal_access;
    `CSR_HPMCOUNTER8 :  csr_illegal_hpm = hpmcounter8_illegal_access;
    `CSR_HPMCOUNTER9 :  csr_illegal_hpm = hpmcounter9_illegal_access;
    `CSR_HPMCOUNTER10 :  csr_illegal_hpm = hpmcounter10_illegal_access;

    `CSR_HPMCOUNTER3H : csr_illegal_hpm = hpmcounter3h_illegal_access;
    `CSR_HPMCOUNTER4H : csr_illegal_hpm = hpmcounter4h_illegal_access;
    `CSR_HPMCOUNTER5H : csr_illegal_hpm = hpmcounter5h_illegal_access;
    `CSR_HPMCOUNTER6H : csr_illegal_hpm = hpmcounter6h_illegal_access;
    `CSR_HPMCOUNTER7H : csr_illegal_hpm = hpmcounter7h_illegal_access;
    `CSR_HPMCOUNTER8H : csr_illegal_hpm = hpmcounter8h_illegal_access;
    `CSR_HPMCOUNTER9H : csr_illegal_hpm = hpmcounter9h_illegal_access;
    `CSR_HPMCOUNTER10H : csr_illegal_hpm = hpmcounter10h_illegal_access;
    endcase
  end
end

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous logic for selecting countable condition names             //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin : mhpmeventname_read_PROC

  csr_arcv_mhpmeventname0_r = idx_name[`CC_NAME0_RANGE] ;
  csr_arcv_mhpmeventname1_r = idx_name[`CC_NAME1_RANGE] ;
  csr_arcv_mhpmeventname2_r = idx_name[`CC_NAME2_RANGE] ;
  csr_arcv_mhpmeventname3_r = idx_name[`CC_NAME3_RANGE] ;
end

assign mhpmevent11_r = 'd0;
assign mhpmevent12_r = 'd0;
assign mhpmevent13_r = 'd0;
assign mhpmevent14_r = 'd0;
assign mhpmevent15_r = 'd0;
assign mhpmevent16_r = 'd0;
assign mhpmevent17_r = 'd0;
assign mhpmevent18_r = 'd0;
assign mhpmevent19_r = 'd0;
assign mhpmevent20_r = 'd0;
assign mhpmevent21_r = 'd0;
assign mhpmevent22_r = 'd0;
assign mhpmevent23_r = 'd0;
assign mhpmevent24_r = 'd0;
assign mhpmevent25_r = 'd0;
assign mhpmevent26_r = 'd0;
assign mhpmevent27_r = 'd0;
assign mhpmevent28_r = 'd0;
assign mhpmevent29_r = 'd0;
assign mhpmevent30_r = 'd0;
assign mhpmevent31_r = 'd0;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous logic for selecting countable condition names             //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin : cc_name_PROC

  idx_name = 128'd0;
  
  case (csr_arcv_mhpmeventindex_r[`PCT_CONFIG_RANGE])
  `PCT_CONFIG_BITS'd0: idx_name = 127'h00000072_6576656e; // never                
  `PCT_CONFIG_BITS'd1: idx_name = 127'h00006c6c_61747362; // bstall                
  `PCT_CONFIG_BITS'd2: idx_name = 127'h00006575_73736962; // bissue                
  `PCT_CONFIG_BITS'd3: idx_name = 127'h00007772_6d656d62; // bmemrw                
  `PCT_CONFIG_BITS'd4: idx_name = 127'h00000063_65786562; // bexec                
  `PCT_CONFIG_BITS'd5: idx_name = 127'h61747363_6e797362; // bsyncstall                
  `PCT_CONFIG_BITS'd6: idx_name = 127'h00000070_61727462; // btrap                
  `PCT_CONFIG_BITS'd7: idx_name = 127'h6c617473_6d636962; // bicmstall                
  `PCT_CONFIG_BITS'd8: idx_name = 127'h00000000_706d6462; // bdmp                
  `PCT_CONFIG_BITS'd9: idx_name = 127'h74637572_74736562; // bestruct                
  `PCT_CONFIG_BITS'd10: idx_name = 127'h6c617473_70656462; // bdepstall                
  `PCT_CONFIG_BITS'd11: idx_name = 127'h00636e79_73666962; // bifsync                
  `PCT_CONFIG_BITS'd12: idx_name = 127'h00636e79_73666462; // bdfsync                
  `PCT_CONFIG_BITS'd13: idx_name = 127'h68736c66_78756162; // bauxflsh                
  `PCT_CONFIG_BITS'd14: idx_name = 127'h00786571_72696662; // bfirqex                
  `PCT_CONFIG_BITS'd15: idx_name = 127'h00006775_62656462; // bdebug                
  `PCT_CONFIG_BITS'd16: idx_name = 127'h7a616872_74736462; // bdstrhaz                
  `PCT_CONFIG_BITS'd17: idx_name = 127'h79616c70_65726462; // bdreplay                
  `PCT_CONFIG_BITS'd18: idx_name = 127'h6c6c6174_73716462; // bdqstall                
  `PCT_CONFIG_BITS'd19: idx_name = 127'h6c6c6174_73636462; // bdcstall                
  `PCT_CONFIG_BITS'd20: idx_name = 127'h00627763_706d6462; // bdmpcwb                
  `PCT_CONFIG_BITS'd21: idx_name = 127'h0071736c_706d6462; // bdmplsq                
  `PCT_CONFIG_BITS'd22: idx_name = 127'h00000000_72736369; // icsr                
  `PCT_CONFIG_BITS'd23: idx_name = 127'h00006574_79623269; // i2byte                
  `PCT_CONFIG_BITS'd24: idx_name = 127'h00006574_79623469; // i4byte                
  `PCT_CONFIG_BITS'd25: idx_name = 127'h00000000_69667769; // iwfi                
  `PCT_CONFIG_BITS'd26: idx_name = 127'h00006c6c_61636569; // iecall                
  `PCT_CONFIG_BITS'd27: idx_name = 127'h6f6d6370_6f727069; // ipropcmoic                
  `PCT_CONFIG_BITS'd28: idx_name = 127'h00706d6a_6c6c6169; // ialljmp                
  `PCT_CONFIG_BITS'd29: idx_name = 127'h00000063_706d6a69; // ijmpc                
  `PCT_CONFIG_BITS'd30: idx_name = 127'h00000075_706d6a69; // ijmpu                
  `PCT_CONFIG_BITS'd31: idx_name = 127'h006b6174_706d6a69; // ijmptak                
  `PCT_CONFIG_BITS'd32: idx_name = 127'h0000006c_6c616369; // icall                
  `PCT_CONFIG_BITS'd33: idx_name = 127'h7465726c_6c616369; // icallret                
  `PCT_CONFIG_BITS'd34: idx_name = 127'h00006472_6d656d69; // imemrd                
  `PCT_CONFIG_BITS'd35: idx_name = 127'h00007277_6d656d69; // imemwr                
  `PCT_CONFIG_BITS'd36: idx_name = 127'h00000000_00726c69; // ilr                
  `PCT_CONFIG_BITS'd37: idx_name = 127'h00000000_00637369; // isc                
  `PCT_CONFIG_BITS'd38: idx_name = 127'h6d6f7461_6d656d69; // imematomic                
  `PCT_CONFIG_BITS'd39: idx_name = 127'h00000000_006d6369; // icm                
  `PCT_CONFIG_BITS'd40: idx_name = 127'h6873756c_66676264; // dbgflush                
  `PCT_CONFIG_BITS'd41: idx_name = 127'h00006e65_6b617465; // etaken                
  `PCT_CONFIG_BITS'd42: idx_name = 127'h00006e65_6b617471; // qtaken                
  `PCT_CONFIG_BITS'd43: idx_name = 127'h616c7065_72706d64; // dmpreplay                
  `PCT_CONFIG_BITS'd44: idx_name = 127'h00007379_61776c61; // always                
  `PCT_CONFIG_BITS'd45: idx_name = 127'h00000000_6e757263; // crun                
  `PCT_CONFIG_BITS'd46: idx_name = 127'h00000069_6e757263; // cruni                
// spyglass disable_block W193 
// SMD: empty statements
// SJ:  empty default statements kept
  default: ;
// spyglass enable_block W193
  endcase
end

  reg mhpmcounter3_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter3_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter3_seg2_impl_wen;  // 63:32 bits of counter
  reg count3_seg2_wen;
  reg count3_seg0_wen;
  reg count3_seg1_wen;

  reg mhpmcounter4_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter4_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter4_seg2_impl_wen;  // 63:32 bits of counter
  reg count4_seg2_wen;
  reg count4_seg0_wen;
  reg count4_seg1_wen;

  reg mhpmcounter5_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter5_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter5_seg2_impl_wen;  // 63:32 bits of counter
  reg count5_seg2_wen;
  reg count5_seg0_wen;
  reg count5_seg1_wen;

  reg mhpmcounter6_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter6_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter6_seg2_impl_wen;  // 63:32 bits of counter
  reg count6_seg2_wen;
  reg count6_seg0_wen;
  reg count6_seg1_wen;

  reg mhpmcounter7_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter7_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter7_seg2_impl_wen;  // 63:32 bits of counter
  reg count7_seg2_wen;
  reg count7_seg0_wen;
  reg count7_seg1_wen;

  reg mhpmcounter8_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter8_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter8_seg2_impl_wen;  // 63:32 bits of counter
  reg count8_seg2_wen;
  reg count8_seg0_wen;
  reg count8_seg1_wen;

  reg mhpmcounter9_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter9_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter9_seg2_impl_wen;  // 63:32 bits of counter
  reg count9_seg2_wen;
  reg count9_seg0_wen;
  reg count9_seg1_wen;

  reg mhpmcounter10_seg0_impl_wen;  // 9:0   bits of counter
  reg mhpmcounter10_seg1_impl_wen;  // 31:10 bits of counter
  reg mhpmcounter10_seg2_impl_wen;  // 63:32 bits of counter
  reg count10_seg2_wen;
  reg count10_seg0_wen;
  reg count10_seg1_wen;


reg csr_arcv_mhpmeventindex_wen;

reg csr_arcv_mcounterintact_impl_wen;
reg [`DATA_SIZE-1:0] csr_arcv_mcounterintact_nxt;
reg csr_arcv_mcounterintact_wen;

reg [`DATA_SIZE-1:0] csr_arcv_mcounterinten_nxt;
reg csr_arcv_mcounterinten_wen;

// Counter-3 register declarations
reg [10:0]   count3_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count3_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count3_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count3_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count3_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count3_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow


// Counter-4 register declarations
reg [10:0]   count4_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count4_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count4_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count4_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count4_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count4_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow


// Counter-5 register declarations
reg [10:0]   count5_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count5_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count5_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count5_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count5_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count5_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow


// Counter-6 register declarations
reg [10:0]   count6_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count6_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count6_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count6_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count6_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count6_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow


// Counter-7 register declarations
reg [10:0]   count7_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count7_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count7_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count7_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count7_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count7_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow


// Counter-8 register declarations
reg [10:0]   count8_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count8_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count8_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count8_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count8_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count8_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow


// Counter-9 register declarations
reg [10:0]   count9_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count9_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count9_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count9_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count9_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count9_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow


// Counter-10 register declarations
reg [10:0]   count10_seg0_nxt ;  // 9:0   bits of counter
reg [32:10]  count10_seg1_nxt ;  // 31:10 bits of counter
reg [32:10]  count10_seg1_r ;    // 31:10 bits of counter, 32nd bit is overflow
  reg [63:32]  count10_seg2_nxt ;  // 63:32 bits of counter
  reg [63:32]  count10_seg2_r ;    // 63:32 bits of counter
reg [10:0]   count10_seg0_r ;    // 9:0   bits of counter, 10th bit is overflow




////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous logic to determine the counter and snapshot enables       //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin : pct_csr_wen_PROC

  count3_seg0_wen    = 1'b0;  
  count3_seg2_wen    = 1'b0;  
  count3_seg1_wen    = 1'b0;  

  count4_seg0_wen    = 1'b0;  
  count4_seg2_wen    = 1'b0;  
  count4_seg1_wen    = 1'b0;  

  count5_seg0_wen    = 1'b0;  
  count5_seg2_wen    = 1'b0;  
  count5_seg1_wen    = 1'b0;  

  count6_seg0_wen    = 1'b0;  
  count6_seg2_wen    = 1'b0;  
  count6_seg1_wen    = 1'b0;  

  count7_seg0_wen    = 1'b0;  
  count7_seg2_wen    = 1'b0;  
  count7_seg1_wen    = 1'b0;  

  count8_seg0_wen    = 1'b0;  
  count8_seg2_wen    = 1'b0;  
  count8_seg1_wen    = 1'b0;  

  count9_seg0_wen    = 1'b0;  
  count9_seg2_wen    = 1'b0;  
  count9_seg1_wen    = 1'b0;  

  count10_seg0_wen    = 1'b0;  
  count10_seg2_wen    = 1'b0;  
  count10_seg1_wen    = 1'b0;  


  count3_seg0_wen    = mhpmcounter3_expl_wen  | mhpmcounter3_seg0_impl_wen;
  count3_seg1_wen    = mhpmcounter3_expl_wen  | mhpmcounter3_seg1_impl_wen;
  count3_seg2_wen    = mhpmcounter3h_expl_wen | mhpmcounter3_seg2_impl_wen;
  count4_seg0_wen    = mhpmcounter4_expl_wen  | mhpmcounter4_seg0_impl_wen;
  count4_seg1_wen    = mhpmcounter4_expl_wen  | mhpmcounter4_seg1_impl_wen;
  count4_seg2_wen    = mhpmcounter4h_expl_wen | mhpmcounter4_seg2_impl_wen;
  count5_seg0_wen    = mhpmcounter5_expl_wen  | mhpmcounter5_seg0_impl_wen;
  count5_seg1_wen    = mhpmcounter5_expl_wen  | mhpmcounter5_seg1_impl_wen;
  count5_seg2_wen    = mhpmcounter5h_expl_wen | mhpmcounter5_seg2_impl_wen;
  count6_seg0_wen    = mhpmcounter6_expl_wen  | mhpmcounter6_seg0_impl_wen;
  count6_seg1_wen    = mhpmcounter6_expl_wen  | mhpmcounter6_seg1_impl_wen;
  count6_seg2_wen    = mhpmcounter6h_expl_wen | mhpmcounter6_seg2_impl_wen;
  count7_seg0_wen    = mhpmcounter7_expl_wen  | mhpmcounter7_seg0_impl_wen;
  count7_seg1_wen    = mhpmcounter7_expl_wen  | mhpmcounter7_seg1_impl_wen;
  count7_seg2_wen    = mhpmcounter7h_expl_wen | mhpmcounter7_seg2_impl_wen;
  count8_seg0_wen    = mhpmcounter8_expl_wen  | mhpmcounter8_seg0_impl_wen;
  count8_seg1_wen    = mhpmcounter8_expl_wen  | mhpmcounter8_seg1_impl_wen;
  count8_seg2_wen    = mhpmcounter8h_expl_wen | mhpmcounter8_seg2_impl_wen;
  count9_seg0_wen    = mhpmcounter9_expl_wen  | mhpmcounter9_seg0_impl_wen;
  count9_seg1_wen    = mhpmcounter9_expl_wen  | mhpmcounter9_seg1_impl_wen;
  count9_seg2_wen    = mhpmcounter9h_expl_wen | mhpmcounter9_seg2_impl_wen;
  count10_seg0_wen    = mhpmcounter10_expl_wen  | mhpmcounter10_seg0_impl_wen;
  count10_seg1_wen    = mhpmcounter10_expl_wen  | mhpmcounter10_seg1_impl_wen;
  count10_seg2_wen    = mhpmcounter10h_expl_wen | mhpmcounter10_seg2_impl_wen;

  csr_arcv_mhpmeventindex_wen = csr_arcv_mhpmeventindex_expl_wen;

  csr_arcv_mcounterinten_wen = csr_arcv_mcounterinten_expl_wen;
  csr_arcv_mcounterintact_wen = csr_arcv_mcounterintact_expl_wen | csr_arcv_mcounterintact_impl_wen;

end // pct_csr_wen_PROC


always @*
begin : pct_impl_wen_PROC

  csr_arcv_mcounterintact_impl_wen = (|int_active_nxt[`HPM_COUNTERS + 2:0]);

  mhpmcounter3_seg0_impl_wen = (~mcountinhibit_r[3]  & (inc_count3));
  mhpmcounter3_seg1_impl_wen = (count3_seg0_nxt[10]) & (mhpmcounter3_seg0_impl_wen);
  mhpmcounter3_seg2_impl_wen = (count3_seg1_nxt[32]) & (mhpmcounter3_seg0_impl_wen & mhpmcounter3_seg1_impl_wen );
  mhpmcounter4_seg0_impl_wen = (~mcountinhibit_r[4]  & (inc_count4));
  mhpmcounter4_seg1_impl_wen = (count4_seg0_nxt[10]) & (mhpmcounter4_seg0_impl_wen);
  mhpmcounter4_seg2_impl_wen = (count4_seg1_nxt[32]) & (mhpmcounter4_seg0_impl_wen & mhpmcounter4_seg1_impl_wen );
  mhpmcounter5_seg0_impl_wen = (~mcountinhibit_r[5]  & (inc_count5));
  mhpmcounter5_seg1_impl_wen = (count5_seg0_nxt[10]) & (mhpmcounter5_seg0_impl_wen);
  mhpmcounter5_seg2_impl_wen = (count5_seg1_nxt[32]) & (mhpmcounter5_seg0_impl_wen & mhpmcounter5_seg1_impl_wen );
  mhpmcounter6_seg0_impl_wen = (~mcountinhibit_r[6]  & (inc_count6));
  mhpmcounter6_seg1_impl_wen = (count6_seg0_nxt[10]) & (mhpmcounter6_seg0_impl_wen);
  mhpmcounter6_seg2_impl_wen = (count6_seg1_nxt[32]) & (mhpmcounter6_seg0_impl_wen & mhpmcounter6_seg1_impl_wen );
  mhpmcounter7_seg0_impl_wen = (~mcountinhibit_r[7]  & (inc_count7));
  mhpmcounter7_seg1_impl_wen = (count7_seg0_nxt[10]) & (mhpmcounter7_seg0_impl_wen);
  mhpmcounter7_seg2_impl_wen = (count7_seg1_nxt[32]) & (mhpmcounter7_seg0_impl_wen & mhpmcounter7_seg1_impl_wen );
  mhpmcounter8_seg0_impl_wen = (~mcountinhibit_r[8]  & (inc_count8));
  mhpmcounter8_seg1_impl_wen = (count8_seg0_nxt[10]) & (mhpmcounter8_seg0_impl_wen);
  mhpmcounter8_seg2_impl_wen = (count8_seg1_nxt[32]) & (mhpmcounter8_seg0_impl_wen & mhpmcounter8_seg1_impl_wen );
  mhpmcounter9_seg0_impl_wen = (~mcountinhibit_r[9]  & (inc_count9));
  mhpmcounter9_seg1_impl_wen = (count9_seg0_nxt[10]) & (mhpmcounter9_seg0_impl_wen);
  mhpmcounter9_seg2_impl_wen = (count9_seg1_nxt[32]) & (mhpmcounter9_seg0_impl_wen & mhpmcounter9_seg1_impl_wen );
  mhpmcounter10_seg0_impl_wen = (~mcountinhibit_r[10]  & (inc_count10));
  mhpmcounter10_seg1_impl_wen = (count10_seg0_nxt[10]) & (mhpmcounter10_seg0_impl_wen);
  mhpmcounter10_seg2_impl_wen = (count10_seg1_nxt[32]) & (mhpmcounter10_seg0_impl_wen & mhpmcounter10_seg1_impl_wen );

end // pct_impl_wen_PROC

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous logic to determine the next counter values                //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin : count_nxt_PROC

    if (mhpmcounter3_expl_wen == 1'b1)
      count3_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count3_seg0_r[10] == 1'b1)
      begin
        count3_seg0_nxt      = 11'd0 + count3_payload;
      end
      else
      begin
        count3_seg0_nxt      = count3_seg0_r + count3_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter3_expl_wen == 1'b1)
      count3_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count3_seg1_r[32] == 1'b1)
    begin
      count3_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count3_seg1_nxt        = count3_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter3h_expl_wen == 1'b1)
      count3_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count3_seg2_nxt          = count3_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter4_expl_wen == 1'b1)
      count4_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count4_seg0_r[10] == 1'b1)
      begin
        count4_seg0_nxt      = 11'd0 + count4_payload;
      end
      else
      begin
        count4_seg0_nxt      = count4_seg0_r + count4_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter4_expl_wen == 1'b1)
      count4_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count4_seg1_r[32] == 1'b1)
    begin
      count4_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count4_seg1_nxt        = count4_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter4h_expl_wen == 1'b1)
      count4_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count4_seg2_nxt          = count4_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter5_expl_wen == 1'b1)
      count5_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count5_seg0_r[10] == 1'b1)
      begin
        count5_seg0_nxt      = 11'd0 + count5_payload;
      end
      else
      begin
        count5_seg0_nxt      = count5_seg0_r + count5_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter5_expl_wen == 1'b1)
      count5_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count5_seg1_r[32] == 1'b1)
    begin
      count5_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count5_seg1_nxt        = count5_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter5h_expl_wen == 1'b1)
      count5_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count5_seg2_nxt          = count5_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter6_expl_wen == 1'b1)
      count6_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count6_seg0_r[10] == 1'b1)
      begin
        count6_seg0_nxt      = 11'd0 + count6_payload;
      end
      else
      begin
        count6_seg0_nxt      = count6_seg0_r + count6_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter6_expl_wen == 1'b1)
      count6_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count6_seg1_r[32] == 1'b1)
    begin
      count6_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count6_seg1_nxt        = count6_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter6h_expl_wen == 1'b1)
      count6_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count6_seg2_nxt          = count6_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter7_expl_wen == 1'b1)
      count7_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count7_seg0_r[10] == 1'b1)
      begin
        count7_seg0_nxt      = 11'd0 + count7_payload;
      end
      else
      begin
        count7_seg0_nxt      = count7_seg0_r + count7_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter7_expl_wen == 1'b1)
      count7_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count7_seg1_r[32] == 1'b1)
    begin
      count7_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count7_seg1_nxt        = count7_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter7h_expl_wen == 1'b1)
      count7_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count7_seg2_nxt          = count7_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter8_expl_wen == 1'b1)
      count8_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count8_seg0_r[10] == 1'b1)
      begin
        count8_seg0_nxt      = 11'd0 + count8_payload;
      end
      else
      begin
        count8_seg0_nxt      = count8_seg0_r + count8_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter8_expl_wen == 1'b1)
      count8_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count8_seg1_r[32] == 1'b1)
    begin
      count8_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count8_seg1_nxt        = count8_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter8h_expl_wen == 1'b1)
      count8_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count8_seg2_nxt          = count8_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter9_expl_wen == 1'b1)
      count9_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count9_seg0_r[10] == 1'b1)
      begin
        count9_seg0_nxt      = 11'd0 + count9_payload;
      end
      else
      begin
        count9_seg0_nxt      = count9_seg0_r + count9_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter9_expl_wen == 1'b1)
      count9_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count9_seg1_r[32] == 1'b1)
    begin
      count9_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count9_seg1_nxt        = count9_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter9h_expl_wen == 1'b1)
      count9_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count9_seg2_nxt          = count9_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter10_expl_wen == 1'b1)
      count10_seg0_nxt        = {1'b0,csr_wdata[9:0]};
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
      if (count10_seg0_r[10] == 1'b1)
      begin
        count10_seg0_nxt      = 11'd0 + count10_payload;
      end
      else
      begin
        count10_seg0_nxt      = count10_seg0_r + count10_payload;
      end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter10_expl_wen == 1'b1)
      count10_seg1_nxt   = {1'b0,csr_wdata[31:10]};
    else
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    if (count10_seg1_r[32] == 1'b1)
    begin
      count10_seg1_nxt        = 23'd0 + 1'b1;
    end
    else
    begin
      count10_seg1_nxt        = count10_seg1_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a

    if (mhpmcounter10h_expl_wen == 1'b1)
      count10_seg2_nxt        = csr_wdata;
    else 
// spyglass disable_block W484
// spyglass disable_block W164a
// SMD: Possible assignment overflow 
// SJ:  Count values wrap to zero is safe
    begin
    count10_seg2_nxt          = count10_seg2_r + 1'b1;
    end
// spyglass enable_block W484   
// spyglass enable_block W164a


 end

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Synchronous blocks defining PCT registers                              //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 3 
//
always @(posedge clk or posedge rst_a)
begin : pct_count3_seg0_PROC
  if (rst_a == 1'b1)
    count3_seg0_r <= 11'd0;
  else if (count3_seg0_wen)
    count3_seg0_r <= count3_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count3_seg1_PROC
  if (rst_a == 1'b1)
    count3_seg1_r <= 'd0;
  else if (count3_seg1_wen)
    count3_seg1_r <= count3_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count3_seg2_PROC
  if (rst_a == 1'b1)
    count3_seg2_r <= 'd0;
  else if (count3_seg2_wen)
    count3_seg2_r <= count3_seg2_nxt;

end
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 4 
//
always @(posedge clk or posedge rst_a)
begin : pct_count4_seg0_PROC
  if (rst_a == 1'b1)
    count4_seg0_r <= 11'd0;
  else if (count4_seg0_wen)
    count4_seg0_r <= count4_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count4_seg1_PROC
  if (rst_a == 1'b1)
    count4_seg1_r <= 'd0;
  else if (count4_seg1_wen)
    count4_seg1_r <= count4_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count4_seg2_PROC
  if (rst_a == 1'b1)
    count4_seg2_r <= 'd0;
  else if (count4_seg2_wen)
    count4_seg2_r <= count4_seg2_nxt;

end
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 5 
//
always @(posedge clk or posedge rst_a)
begin : pct_count5_seg0_PROC
  if (rst_a == 1'b1)
    count5_seg0_r <= 11'd0;
  else if (count5_seg0_wen)
    count5_seg0_r <= count5_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count5_seg1_PROC
  if (rst_a == 1'b1)
    count5_seg1_r <= 'd0;
  else if (count5_seg1_wen)
    count5_seg1_r <= count5_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count5_seg2_PROC
  if (rst_a == 1'b1)
    count5_seg2_r <= 'd0;
  else if (count5_seg2_wen)
    count5_seg2_r <= count5_seg2_nxt;

end
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 6 
//
always @(posedge clk or posedge rst_a)
begin : pct_count6_seg0_PROC
  if (rst_a == 1'b1)
    count6_seg0_r <= 11'd0;
  else if (count6_seg0_wen)
    count6_seg0_r <= count6_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count6_seg1_PROC
  if (rst_a == 1'b1)
    count6_seg1_r <= 'd0;
  else if (count6_seg1_wen)
    count6_seg1_r <= count6_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count6_seg2_PROC
  if (rst_a == 1'b1)
    count6_seg2_r <= 'd0;
  else if (count6_seg2_wen)
    count6_seg2_r <= count6_seg2_nxt;

end
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 7 
//
always @(posedge clk or posedge rst_a)
begin : pct_count7_seg0_PROC
  if (rst_a == 1'b1)
    count7_seg0_r <= 11'd0;
  else if (count7_seg0_wen)
    count7_seg0_r <= count7_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count7_seg1_PROC
  if (rst_a == 1'b1)
    count7_seg1_r <= 'd0;
  else if (count7_seg1_wen)
    count7_seg1_r <= count7_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count7_seg2_PROC
  if (rst_a == 1'b1)
    count7_seg2_r <= 'd0;
  else if (count7_seg2_wen)
    count7_seg2_r <= count7_seg2_nxt;

end
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 8 
//
always @(posedge clk or posedge rst_a)
begin : pct_count8_seg0_PROC
  if (rst_a == 1'b1)
    count8_seg0_r <= 11'd0;
  else if (count8_seg0_wen)
    count8_seg0_r <= count8_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count8_seg1_PROC
  if (rst_a == 1'b1)
    count8_seg1_r <= 'd0;
  else if (count8_seg1_wen)
    count8_seg1_r <= count8_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count8_seg2_PROC
  if (rst_a == 1'b1)
    count8_seg2_r <= 'd0;
  else if (count8_seg2_wen)
    count8_seg2_r <= count8_seg2_nxt;

end
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 9 
//
always @(posedge clk or posedge rst_a)
begin : pct_count9_seg0_PROC
  if (rst_a == 1'b1)
    count9_seg0_r <= 11'd0;
  else if (count9_seg0_wen)
    count9_seg0_r <= count9_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count9_seg1_PROC
  if (rst_a == 1'b1)
    count9_seg1_r <= 'd0;
  else if (count9_seg1_wen)
    count9_seg1_r <= count9_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count9_seg2_PROC
  if (rst_a == 1'b1)
    count9_seg2_r <= 'd0;
  else if (count9_seg2_wen)
    count9_seg2_r <= count9_seg2_nxt;

end
////////////////////////////////////////////////////////////////////////////
// Synchronous block for counter - 10 
//
always @(posedge clk or posedge rst_a)
begin : pct_count10_seg0_PROC
  if (rst_a == 1'b1)
    count10_seg0_r <= 11'd0;
  else if (count10_seg0_wen)
    count10_seg0_r <= count10_seg0_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count10_seg1_PROC
  if (rst_a == 1'b1)
    count10_seg1_r <= 'd0;
  else if (count10_seg1_wen)
    count10_seg1_r <= count10_seg1_nxt;

end

always @(posedge clk or posedge rst_a)
begin : pct_count10_seg2_PROC
  if (rst_a == 1'b1)
    count10_seg2_r <= 'd0;
  else if (count10_seg2_wen)
    count10_seg2_r <= count10_seg2_nxt;

end

// Connecting counters to mhpmcounter CSR signals  
//
always @*
begin : mhpmcounter_r_csr_porting_PROC

mhpmcounter3_r = {count3_seg1_r[31:10], count3_seg0_r[9:0]};
mhpmcounter4_r = {count4_seg1_r[31:10], count4_seg0_r[9:0]};
mhpmcounter5_r = {count5_seg1_r[31:10], count5_seg0_r[9:0]};
mhpmcounter6_r = {count6_seg1_r[31:10], count6_seg0_r[9:0]};
mhpmcounter7_r = {count7_seg1_r[31:10], count7_seg0_r[9:0]};
mhpmcounter8_r = {count8_seg1_r[31:10], count8_seg0_r[9:0]};
mhpmcounter9_r = {count9_seg1_r[31:10], count9_seg0_r[9:0]};
mhpmcounter10_r = {count10_seg1_r[31:10], count10_seg0_r[9:0]};

end

assign mhpmcounter11_r = 'd0;
assign mhpmcounter12_r = 'd0;
assign mhpmcounter13_r = 'd0;
assign mhpmcounter14_r = 'd0;
assign mhpmcounter15_r = 'd0;
assign mhpmcounter16_r = 'd0;
assign mhpmcounter17_r = 'd0;
assign mhpmcounter18_r = 'd0;
assign mhpmcounter19_r = 'd0;
assign mhpmcounter20_r = 'd0;
assign mhpmcounter21_r = 'd0;
assign mhpmcounter22_r = 'd0;
assign mhpmcounter23_r = 'd0;
assign mhpmcounter24_r = 'd0;
assign mhpmcounter25_r = 'd0;
assign mhpmcounter26_r = 'd0;
assign mhpmcounter27_r = 'd0;
assign mhpmcounter28_r = 'd0;
assign mhpmcounter29_r = 'd0;
assign mhpmcounter30_r = 'd0;
assign mhpmcounter31_r = 'd0;

// Connecting counters to hpmcounter CSR signals  
//
always @*
begin : hpmcounter_r_csr_porting_PROC

hpmcounter3_r = mhpmcounter3_r;
hpmcounter4_r = mhpmcounter4_r;
hpmcounter5_r = mhpmcounter5_r;
hpmcounter6_r = mhpmcounter6_r;
hpmcounter7_r = mhpmcounter7_r;
hpmcounter8_r = mhpmcounter8_r;
hpmcounter9_r = mhpmcounter9_r;
hpmcounter10_r = mhpmcounter10_r;

end

assign hpmcounter11_r = 'd0;
assign hpmcounter12_r = 'd0;
assign hpmcounter13_r = 'd0;
assign hpmcounter14_r = 'd0;
assign hpmcounter15_r = 'd0;
assign hpmcounter16_r = 'd0;
assign hpmcounter17_r = 'd0;
assign hpmcounter18_r = 'd0;
assign hpmcounter19_r = 'd0;
assign hpmcounter20_r = 'd0;
assign hpmcounter21_r = 'd0;
assign hpmcounter22_r = 'd0;
assign hpmcounter23_r = 'd0;
assign hpmcounter24_r = 'd0;
assign hpmcounter25_r = 'd0;
assign hpmcounter26_r = 'd0;
assign hpmcounter27_r = 'd0;
assign hpmcounter28_r = 'd0;
assign hpmcounter29_r = 'd0;
assign hpmcounter30_r = 'd0;
assign hpmcounter31_r = 'd0;

// Connecting counters to mhpmcounterh CSR signals  
//
always @*
begin : mhpmcounterh_r_csr_porting_PROC

mhpmcounter3h_r = count3_seg2_r;
mhpmcounter4h_r = count4_seg2_r;
mhpmcounter5h_r = count5_seg2_r;
mhpmcounter6h_r = count6_seg2_r;
mhpmcounter7h_r = count7_seg2_r;
mhpmcounter8h_r = count8_seg2_r;
mhpmcounter9h_r = count9_seg2_r;
mhpmcounter10h_r = count10_seg2_r;

end


assign mhpmcounter11h_r = 'd0;
assign mhpmcounter12h_r = 'd0;
assign mhpmcounter13h_r = 'd0;
assign mhpmcounter14h_r = 'd0;
assign mhpmcounter15h_r = 'd0;
assign mhpmcounter16h_r = 'd0;
assign mhpmcounter17h_r = 'd0;
assign mhpmcounter18h_r = 'd0;
assign mhpmcounter19h_r = 'd0;
assign mhpmcounter20h_r = 'd0;
assign mhpmcounter21h_r = 'd0;
assign mhpmcounter22h_r = 'd0;
assign mhpmcounter23h_r = 'd0;
assign mhpmcounter24h_r = 'd0;
assign mhpmcounter25h_r = 'd0;
assign mhpmcounter26h_r = 'd0;
assign mhpmcounter27h_r = 'd0;
assign mhpmcounter28h_r = 'd0;
assign mhpmcounter29h_r = 'd0;
assign mhpmcounter30h_r = 'd0;
assign mhpmcounter31h_r = 'd0;

// Connecting counters to hpmcounterh CSR signals  
//
always @*
begin : hpmcounterh_r_csr_porting_PROC

hpmcounter3h_r = mhpmcounter3h_r;
hpmcounter4h_r = mhpmcounter4h_r;
hpmcounter5h_r = mhpmcounter5h_r;
hpmcounter6h_r = mhpmcounter6h_r;
hpmcounter7h_r = mhpmcounter7h_r;
hpmcounter8h_r = mhpmcounter8h_r;
hpmcounter9h_r = mhpmcounter9h_r;
hpmcounter10h_r = mhpmcounter10h_r;

end

assign hpmcounter11h_r = 'd0;
assign hpmcounter12h_r = 'd0;
assign hpmcounter13h_r = 'd0;
assign hpmcounter14h_r = 'd0;
assign hpmcounter15h_r = 'd0;
assign hpmcounter16h_r = 'd0;
assign hpmcounter17h_r = 'd0;
assign hpmcounter18h_r = 'd0;
assign hpmcounter19h_r = 'd0;
assign hpmcounter20h_r = 'd0;
assign hpmcounter21h_r = 'd0;
assign hpmcounter22h_r = 'd0;
assign hpmcounter23h_r = 'd0;
assign hpmcounter24h_r = 'd0;
assign hpmcounter25h_r = 'd0;
assign hpmcounter26h_r = 'd0;
assign hpmcounter27h_r = 'd0;
assign hpmcounter28h_r = 'd0;
assign hpmcounter29h_r = 'd0;
assign hpmcounter30h_r = 'd0;
assign hpmcounter31h_r = 'd0;

// Synchronous block csr_arcv_mhpmeventindex_r
//
always @(posedge clk or posedge rst_a)
begin : csr_arcv_mhpmeventindex_PROC
  if (rst_a == 1'b1)
    csr_arcv_mhpmeventindex_r <= 32'd0;
  else if (csr_arcv_mhpmeventindex_wen == 1'b1)
    csr_arcv_mhpmeventindex_r <= csr_wdata;

end

// Synchronous block for mhpmevent3_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent3_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent3_r <= 32'd0;
  else if (mhpmevent3_expl_wen == 1'b1)
    mhpmevent3_r <= csr_wdata;
end

// Synchronous block for mhpmevent4_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent4_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent4_r <= 32'd0;
  else if (mhpmevent4_expl_wen == 1'b1)
    mhpmevent4_r <= csr_wdata;
end

// Synchronous block for mhpmevent5_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent5_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent5_r <= 32'd0;
  else if (mhpmevent5_expl_wen == 1'b1)
    mhpmevent5_r <= csr_wdata;
end

// Synchronous block for mhpmevent6_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent6_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent6_r <= 32'd0;
  else if (mhpmevent6_expl_wen == 1'b1)
    mhpmevent6_r <= csr_wdata;
end

// Synchronous block for mhpmevent7_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent7_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent7_r <= 32'd0;
  else if (mhpmevent7_expl_wen == 1'b1)
    mhpmevent7_r <= csr_wdata;
end

// Synchronous block for mhpmevent8_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent8_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent8_r <= 32'd0;
  else if (mhpmevent8_expl_wen == 1'b1)
    mhpmevent8_r <= csr_wdata;
end

// Synchronous block for mhpmevent9_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent9_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent9_r <= 32'd0;
  else if (mhpmevent9_expl_wen == 1'b1)
    mhpmevent9_r <= csr_wdata;
end

// Synchronous block for mhpmevent10_r
//
always @(posedge clk or posedge rst_a)
begin : mhpmevent10_r_wrie_PROC
  if (rst_a == 1'b1)
    mhpmevent10_r <= 32'd0;
  else if (mhpmevent10_expl_wen == 1'b1)
    mhpmevent10_r <= csr_wdata;
end


reg count3_overflow_dl;


wire count3_overflow = ((count3_seg2_r == {32{1'b0}}) && ((count3_seg1_r[32:10] == 23'h40_0000) && (count3_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count3_overflow_edge_PROC
  if(rst_a == 1'b1)
    count3_overflow_dl <= 1'b0;
  else
    count3_overflow_dl <= count3_overflow;
end
reg count4_overflow_dl;


wire count4_overflow = ((count4_seg2_r == {32{1'b0}}) && ((count4_seg1_r[32:10] == 23'h40_0000) && (count4_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count4_overflow_edge_PROC
  if(rst_a == 1'b1)
    count4_overflow_dl <= 1'b0;
  else
    count4_overflow_dl <= count4_overflow;
end
reg count5_overflow_dl;


wire count5_overflow = ((count5_seg2_r == {32{1'b0}}) && ((count5_seg1_r[32:10] == 23'h40_0000) && (count5_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count5_overflow_edge_PROC
  if(rst_a == 1'b1)
    count5_overflow_dl <= 1'b0;
  else
    count5_overflow_dl <= count5_overflow;
end
reg count6_overflow_dl;


wire count6_overflow = ((count6_seg2_r == {32{1'b0}}) && ((count6_seg1_r[32:10] == 23'h40_0000) && (count6_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count6_overflow_edge_PROC
  if(rst_a == 1'b1)
    count6_overflow_dl <= 1'b0;
  else
    count6_overflow_dl <= count6_overflow;
end
reg count7_overflow_dl;


wire count7_overflow = ((count7_seg2_r == {32{1'b0}}) && ((count7_seg1_r[32:10] == 23'h40_0000) && (count7_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count7_overflow_edge_PROC
  if(rst_a == 1'b1)
    count7_overflow_dl <= 1'b0;
  else
    count7_overflow_dl <= count7_overflow;
end
reg count8_overflow_dl;


wire count8_overflow = ((count8_seg2_r == {32{1'b0}}) && ((count8_seg1_r[32:10] == 23'h40_0000) && (count8_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count8_overflow_edge_PROC
  if(rst_a == 1'b1)
    count8_overflow_dl <= 1'b0;
  else
    count8_overflow_dl <= count8_overflow;
end
reg count9_overflow_dl;


wire count9_overflow = ((count9_seg2_r == {32{1'b0}}) && ((count9_seg1_r[32:10] == 23'h40_0000) && (count9_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count9_overflow_edge_PROC
  if(rst_a == 1'b1)
    count9_overflow_dl <= 1'b0;
  else
    count9_overflow_dl <= count9_overflow;
end
reg count10_overflow_dl;


wire count10_overflow = ((count10_seg2_r == {32{1'b0}}) && ((count10_seg1_r[32:10] == 23'h40_0000) && (count10_seg0_r[10:0] == 11'h400)));



//edge-triggered logic
always@(posedge clk or posedge rst_a)
begin : count10_overflow_edge_PROC
  if(rst_a == 1'b1)
    count10_overflow_dl <= 1'b0;
  else
    count10_overflow_dl <= count10_overflow;
end

always @*
begin : pct_int_active_nxt_PROC
    int_active_nxt     = 'd0;
    int_active_nxt[0]  = 1'b1 & csr_arcv_mcounterinten_r[0] & cycle_ovf;
    int_active_nxt[1]  = 1'b1 & csr_arcv_mcounterinten_r[1] & time_ovf;
    int_active_nxt[2]  = 1'b1 & csr_arcv_mcounterinten_r[2] & instret_ovf;
    int_active_nxt[3]  = 1'b1 & csr_arcv_mcounterinten_r[3] & ~count3_overflow_dl & count3_overflow;

    int_active_nxt[4]  = 1'b1 & csr_arcv_mcounterinten_r[4] & ~count4_overflow_dl & count4_overflow;

    int_active_nxt[5]  = 1'b1 & csr_arcv_mcounterinten_r[5] & ~count5_overflow_dl & count5_overflow;

    int_active_nxt[6]  = 1'b1 & csr_arcv_mcounterinten_r[6] & ~count6_overflow_dl & count6_overflow;

    int_active_nxt[7]  = 1'b1 & csr_arcv_mcounterinten_r[7] & ~count7_overflow_dl & count7_overflow;

    int_active_nxt[8]  = 1'b1 & csr_arcv_mcounterinten_r[8] & ~count8_overflow_dl & count8_overflow;

    int_active_nxt[9]  = 1'b1 & csr_arcv_mcounterinten_r[9] & ~count9_overflow_dl & count9_overflow;

    int_active_nxt[10]  = 1'b1 & csr_arcv_mcounterinten_r[10] & ~count10_overflow_dl & count10_overflow;

end

always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1) 
  begin
      hpm_int_overflow_d <= 1'b0;
  end 
  else 
  begin
      hpm_int_overflow_d <= hpm_int_overflow_r;
  end
end

assign hpm_int_overflow_rising = hpm_int_overflow_r & ~hpm_int_overflow_d;

always @(posedge clk or posedge rst_a) 
begin
  if (rst_a == 1'b1)
    hpm_int_overflow_r <= 1'b0;
  else if (ar_clock_enable_r == 1'b1)
    hpm_int_overflow_r <= |csr_arcv_mcounterintact_r[`HPM_COUNTERS + 2:0];

end

always @*
begin : pct_int_csr_nxt_PROC
      csr_arcv_mcounterinten_nxt =  csr_wdata ;

    if (csr_arcv_mcounterintact_expl_wen)
      csr_arcv_mcounterintact_nxt =  csr_wdata ;
    else
      csr_arcv_mcounterintact_nxt = (csr_arcv_mcounterintact_r | int_active_nxt) ;

end  //   pct_int_csr_nxt_PROC



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Synchronous blocks for interrupt related architectural state updates     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : pct_int_reg_PROC
  if (rst_a == 1'b1)
    begin
      csr_arcv_mcounterinten_r  <= 32'd0;
      csr_arcv_mcounterintact_r <= 32'd0;
    end
  else
    begin
      if (csr_arcv_mcounterintact_wen)
        csr_arcv_mcounterintact_r <= csr_arcv_mcounterintact_nxt;
      if (csr_arcv_mcounterinten_wen)
        csr_arcv_mcounterinten_r  <= csr_arcv_mcounterinten_nxt;
    end
end // pct_int_reg_PROC


wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent3;
assign mhpmevent3 = {mhpmevent3_r[31], mhpmevent3_r[`PCT_CC_IDX_RANGE]};

wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent4;
assign mhpmevent4 = {mhpmevent4_r[31], mhpmevent4_r[`PCT_CC_IDX_RANGE]};

wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent5;
assign mhpmevent5 = {mhpmevent5_r[31], mhpmevent5_r[`PCT_CC_IDX_RANGE]};

wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent6;
assign mhpmevent6 = {mhpmevent6_r[31], mhpmevent6_r[`PCT_CC_IDX_RANGE]};

wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent7;
assign mhpmevent7 = {mhpmevent7_r[31], mhpmevent7_r[`PCT_CC_IDX_RANGE]};

wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent8;
assign mhpmevent8 = {mhpmevent8_r[31], mhpmevent8_r[`PCT_CC_IDX_RANGE]};

wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent9;
assign mhpmevent9 = {mhpmevent9_r[31], mhpmevent9_r[`PCT_CC_IDX_RANGE]};

wire [`PCT_CC_IDX_FULL_RANGE] mhpmevent10;
assign mhpmevent10 = {mhpmevent10_r[31], mhpmevent10_r[`PCT_CC_IDX_RANGE]};



always @*
begin
    case (mhpmevent3)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count3 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count3 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count3 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count3 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count3 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count3 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count3 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count3 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count3 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count3 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count3 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count3 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count3 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count3 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count3 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count3 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count3 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count3 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count3 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count3 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count3 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count3 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count3 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count3 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count3 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count3 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count3 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count3 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count3 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count3 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count3 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count3 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count3 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count3 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count3 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count3 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count3 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count3 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count3 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count3 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count3 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count3 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count3 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count3 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count3 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count3 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count3 = all_events_r[46];
    default: inc_count3 = 1'b0;
    endcase
    
    case (mhpmevent4)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count4 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count4 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count4 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count4 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count4 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count4 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count4 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count4 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count4 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count4 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count4 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count4 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count4 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count4 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count4 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count4 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count4 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count4 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count4 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count4 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count4 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count4 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count4 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count4 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count4 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count4 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count4 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count4 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count4 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count4 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count4 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count4 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count4 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count4 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count4 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count4 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count4 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count4 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count4 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count4 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count4 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count4 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count4 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count4 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count4 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count4 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count4 = all_events_r[46];
    default: inc_count4 = 1'b0;
    endcase
    
    case (mhpmevent5)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count5 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count5 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count5 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count5 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count5 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count5 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count5 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count5 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count5 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count5 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count5 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count5 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count5 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count5 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count5 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count5 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count5 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count5 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count5 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count5 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count5 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count5 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count5 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count5 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count5 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count5 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count5 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count5 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count5 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count5 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count5 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count5 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count5 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count5 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count5 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count5 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count5 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count5 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count5 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count5 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count5 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count5 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count5 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count5 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count5 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count5 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count5 = all_events_r[46];
    default: inc_count5 = 1'b0;
    endcase
    
    case (mhpmevent6)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count6 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count6 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count6 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count6 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count6 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count6 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count6 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count6 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count6 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count6 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count6 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count6 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count6 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count6 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count6 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count6 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count6 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count6 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count6 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count6 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count6 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count6 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count6 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count6 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count6 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count6 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count6 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count6 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count6 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count6 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count6 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count6 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count6 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count6 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count6 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count6 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count6 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count6 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count6 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count6 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count6 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count6 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count6 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count6 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count6 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count6 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count6 = all_events_r[46];
    default: inc_count6 = 1'b0;
    endcase
    
    case (mhpmevent7)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count7 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count7 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count7 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count7 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count7 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count7 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count7 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count7 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count7 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count7 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count7 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count7 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count7 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count7 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count7 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count7 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count7 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count7 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count7 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count7 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count7 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count7 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count7 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count7 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count7 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count7 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count7 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count7 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count7 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count7 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count7 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count7 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count7 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count7 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count7 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count7 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count7 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count7 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count7 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count7 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count7 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count7 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count7 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count7 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count7 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count7 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count7 = all_events_r[46];
    default: inc_count7 = 1'b0;
    endcase
    
    case (mhpmevent8)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count8 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count8 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count8 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count8 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count8 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count8 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count8 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count8 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count8 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count8 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count8 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count8 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count8 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count8 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count8 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count8 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count8 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count8 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count8 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count8 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count8 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count8 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count8 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count8 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count8 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count8 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count8 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count8 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count8 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count8 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count8 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count8 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count8 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count8 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count8 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count8 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count8 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count8 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count8 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count8 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count8 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count8 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count8 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count8 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count8 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count8 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count8 = all_events_r[46];
    default: inc_count8 = 1'b0;
    endcase
    
    case (mhpmevent9)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count9 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count9 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count9 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count9 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count9 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count9 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count9 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count9 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count9 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count9 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count9 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count9 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count9 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count9 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count9 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count9 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count9 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count9 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count9 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count9 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count9 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count9 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count9 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count9 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count9 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count9 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count9 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count9 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count9 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count9 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count9 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count9 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count9 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count9 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count9 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count9 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count9 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count9 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count9 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count9 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count9 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count9 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count9 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count9 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count9 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count9 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count9 = all_events_r[46];
    default: inc_count9 = 1'b0;
    endcase
    
    case (mhpmevent10)
    `PCT_CC_IDX_FULL_BITS'h661,`PCT_CC_IDX_FULL_BITS'd0 : inc_count10 = all_events_r[0];
    `PCT_CC_IDX_FULL_BITS'h400,`PCT_CC_IDX_FULL_BITS'd1 : inc_count10 = all_events_r[1];
    `PCT_CC_IDX_FULL_BITS'h401,`PCT_CC_IDX_FULL_BITS'd2 : inc_count10 = all_events_r[2];
    `PCT_CC_IDX_FULL_BITS'h402,`PCT_CC_IDX_FULL_BITS'd3 : inc_count10 = all_events_r[3];
    `PCT_CC_IDX_FULL_BITS'h404,`PCT_CC_IDX_FULL_BITS'd4 : inc_count10 = all_events_r[4];
    `PCT_CC_IDX_FULL_BITS'h405,`PCT_CC_IDX_FULL_BITS'd5 : inc_count10 = all_events_r[5];
    `PCT_CC_IDX_FULL_BITS'h406,`PCT_CC_IDX_FULL_BITS'd6 : inc_count10 = all_events_r[6];
    `PCT_CC_IDX_FULL_BITS'h407,`PCT_CC_IDX_FULL_BITS'd7 : inc_count10 = all_events_r[7];
    `PCT_CC_IDX_FULL_BITS'h40C,`PCT_CC_IDX_FULL_BITS'd8 : inc_count10 = all_events_r[8];
    `PCT_CC_IDX_FULL_BITS'h410,`PCT_CC_IDX_FULL_BITS'd9 : inc_count10 = all_events_r[9];
    `PCT_CC_IDX_FULL_BITS'h411,`PCT_CC_IDX_FULL_BITS'd10 : inc_count10 = all_events_r[10];
    `PCT_CC_IDX_FULL_BITS'h412,`PCT_CC_IDX_FULL_BITS'd11 : inc_count10 = all_events_r[11];
    `PCT_CC_IDX_FULL_BITS'h414,`PCT_CC_IDX_FULL_BITS'd12 : inc_count10 = all_events_r[12];
    `PCT_CC_IDX_FULL_BITS'h416,`PCT_CC_IDX_FULL_BITS'd13 : inc_count10 = all_events_r[13];
    `PCT_CC_IDX_FULL_BITS'h417,`PCT_CC_IDX_FULL_BITS'd14 : inc_count10 = all_events_r[14];
    `PCT_CC_IDX_FULL_BITS'h418,`PCT_CC_IDX_FULL_BITS'd15 : inc_count10 = all_events_r[15];
    `PCT_CC_IDX_FULL_BITS'h41B,`PCT_CC_IDX_FULL_BITS'd16 : inc_count10 = all_events_r[16];
    `PCT_CC_IDX_FULL_BITS'h41D,`PCT_CC_IDX_FULL_BITS'd17 : inc_count10 = all_events_r[17];
    `PCT_CC_IDX_FULL_BITS'h42F,`PCT_CC_IDX_FULL_BITS'd18 : inc_count10 = all_events_r[18];
    `PCT_CC_IDX_FULL_BITS'h430,`PCT_CC_IDX_FULL_BITS'd19 : inc_count10 = all_events_r[19];
    `PCT_CC_IDX_FULL_BITS'h43A,`PCT_CC_IDX_FULL_BITS'd20 : inc_count10 = all_events_r[20];
    `PCT_CC_IDX_FULL_BITS'h43B,`PCT_CC_IDX_FULL_BITS'd21 : inc_count10 = all_events_r[21];
    `PCT_CC_IDX_FULL_BITS'h500,`PCT_CC_IDX_FULL_BITS'd22 : inc_count10 = all_events_r[22];
    `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23 : inc_count10 = all_events_r[23];
    `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24 : inc_count10 = all_events_r[24];
    `PCT_CC_IDX_FULL_BITS'h503,`PCT_CC_IDX_FULL_BITS'd25 : inc_count10 = all_events_r[25];
    `PCT_CC_IDX_FULL_BITS'h504,`PCT_CC_IDX_FULL_BITS'd26 : inc_count10 = all_events_r[26];
    `PCT_CC_IDX_FULL_BITS'h505,`PCT_CC_IDX_FULL_BITS'd27 : inc_count10 = all_events_r[27];
    `PCT_CC_IDX_FULL_BITS'h510,`PCT_CC_IDX_FULL_BITS'd28 : inc_count10 = all_events_r[28];
    `PCT_CC_IDX_FULL_BITS'h511,`PCT_CC_IDX_FULL_BITS'd29 : inc_count10 = all_events_r[29];
    `PCT_CC_IDX_FULL_BITS'h512,`PCT_CC_IDX_FULL_BITS'd30 : inc_count10 = all_events_r[30];
    `PCT_CC_IDX_FULL_BITS'h513,`PCT_CC_IDX_FULL_BITS'd31 : inc_count10 = all_events_r[31];
    `PCT_CC_IDX_FULL_BITS'h514,`PCT_CC_IDX_FULL_BITS'd32 : inc_count10 = all_events_r[32];
    `PCT_CC_IDX_FULL_BITS'h515,`PCT_CC_IDX_FULL_BITS'd33 : inc_count10 = all_events_r[33];
    `PCT_CC_IDX_FULL_BITS'h520,`PCT_CC_IDX_FULL_BITS'd34 : inc_count10 = all_events_r[34];
    `PCT_CC_IDX_FULL_BITS'h521,`PCT_CC_IDX_FULL_BITS'd35 : inc_count10 = all_events_r[35];
    `PCT_CC_IDX_FULL_BITS'h522,`PCT_CC_IDX_FULL_BITS'd36 : inc_count10 = all_events_r[36];
    `PCT_CC_IDX_FULL_BITS'h523,`PCT_CC_IDX_FULL_BITS'd37 : inc_count10 = all_events_r[37];
    `PCT_CC_IDX_FULL_BITS'h526,`PCT_CC_IDX_FULL_BITS'd38 : inc_count10 = all_events_r[38];
    `PCT_CC_IDX_FULL_BITS'h607,`PCT_CC_IDX_FULL_BITS'd39 : inc_count10 = all_events_r[39];
    `PCT_CC_IDX_FULL_BITS'h610,`PCT_CC_IDX_FULL_BITS'd40 : inc_count10 = all_events_r[40];
    `PCT_CC_IDX_FULL_BITS'h611,`PCT_CC_IDX_FULL_BITS'd41 : inc_count10 = all_events_r[41];
    `PCT_CC_IDX_FULL_BITS'h612,`PCT_CC_IDX_FULL_BITS'd42 : inc_count10 = all_events_r[42];
    `PCT_CC_IDX_FULL_BITS'h63B,`PCT_CC_IDX_FULL_BITS'd43 : inc_count10 = all_events_r[43];
    `PCT_CC_IDX_FULL_BITS'h660,`PCT_CC_IDX_FULL_BITS'd44 : inc_count10 = all_events_r[44];
    `PCT_CC_IDX_FULL_BITS'h662,`PCT_CC_IDX_FULL_BITS'd45 : inc_count10 = all_events_r[45];
    `PCT_CC_IDX_FULL_BITS'h663,`PCT_CC_IDX_FULL_BITS'd46 : inc_count10 = all_events_r[46];
    default: inc_count10 = 1'b0;
    endcase
    

       p_i2byte = 1'd0;
       p_i4byte = 1'd0;

//Below are dual pipe events. The event source can be in pipe-0, pipe-1
//
 p_i2byte = q_i2byte;
 p_i4byte = q_i4byte;


 case (mhpmevent3)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count3_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count3_payload = p_i4byte_r;
 default: count3_payload = 1'b1;
 endcase
 
 case (mhpmevent4)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count4_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count4_payload = p_i4byte_r;
 default: count4_payload = 1'b1;
 endcase
 
 case (mhpmevent5)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count5_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count5_payload = p_i4byte_r;
 default: count5_payload = 1'b1;
 endcase
 
 case (mhpmevent6)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count6_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count6_payload = p_i4byte_r;
 default: count6_payload = 1'b1;
 endcase
 
 case (mhpmevent7)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count7_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count7_payload = p_i4byte_r;
 default: count7_payload = 1'b1;
 endcase
 
 case (mhpmevent8)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count8_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count8_payload = p_i4byte_r;
 default: count8_payload = 1'b1;
 endcase
 
 case (mhpmevent9)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count9_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count9_payload = p_i4byte_r;
 default: count9_payload = 1'b1;
 endcase
 
 case (mhpmevent10)
 `PCT_CC_IDX_FULL_BITS'h501,`PCT_CC_IDX_FULL_BITS'd23: count10_payload = p_i2byte_r;
 `PCT_CC_IDX_FULL_BITS'h502,`PCT_CC_IDX_FULL_BITS'd24: count10_payload = p_i4byte_r;
 default: count10_payload = 1'b1;
 endcase
 


end

always @(posedge clk or posedge rst_a)
begin : payload_p_i2byte_reg_PROC
  if (rst_a)
    p_i2byte_r <= 'd0;
  else
    p_i2byte_r <= p_i2byte;
end

always @(posedge clk or posedge rst_a)
begin : payload_p_i4byte_reg_PROC
  if (rst_a)
    p_i4byte_r <= 'd0;
  else
    p_i4byte_r <= p_i4byte;
end





////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Synchronous blocks defining the input pipeline register, which serves  //
// to isolate the PCT block from the rest of the pipeline for timing.     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : pct_events_PROC
  if (rst_a == 1'b1)
    begin
    all_events_r[0]      <= 1'b0;
    all_events_r[1]      <= 1'b0;
    all_events_r[2]      <= 1'b0;
    all_events_r[3]      <= 1'b0;
    all_events_r[4]      <= 1'b0;
    all_events_r[5]      <= 1'b0;
    all_events_r[6]      <= 1'b0;
    all_events_r[7]      <= 1'b0;
    all_events_r[8]      <= 1'b0;
    all_events_r[9]      <= 1'b0;
    all_events_r[10]      <= 1'b0;
    all_events_r[11]      <= 1'b0;
    all_events_r[12]      <= 1'b0;
    all_events_r[13]      <= 1'b0;
    all_events_r[14]      <= 1'b0;
    all_events_r[15]      <= 1'b0;
    all_events_r[16]      <= 1'b0;
    all_events_r[17]      <= 1'b0;
    all_events_r[18]      <= 1'b0;
    all_events_r[19]      <= 1'b0;
    all_events_r[20]      <= 1'b0;
    all_events_r[21]      <= 1'b0;
    all_events_r[22]      <= 1'b0;
    all_events_r[23]      <= 1'b0;
    all_events_r[24]      <= 1'b0;
    all_events_r[25]      <= 1'b0;
    all_events_r[26]      <= 1'b0;
    all_events_r[27]      <= 1'b0;
    all_events_r[28]      <= 1'b0;
    all_events_r[29]      <= 1'b0;
    all_events_r[30]      <= 1'b0;
    all_events_r[31]      <= 1'b0;
    all_events_r[32]      <= 1'b0;
    all_events_r[33]      <= 1'b0;
    all_events_r[34]      <= 1'b0;
    all_events_r[35]      <= 1'b0;
    all_events_r[36]      <= 1'b0;
    all_events_r[37]      <= 1'b0;
    all_events_r[38]      <= 1'b0;
    all_events_r[39]      <= 1'b0;
    all_events_r[40]      <= 1'b0;
    all_events_r[41]      <= 1'b0;
    all_events_r[42]      <= 1'b0;
    all_events_r[43]      <= 1'b0;
    all_events_r[44]      <= 1'b0;
    all_events_r[45]      <= 1'b0;
    all_events_r[46]      <= 1'b0;
    end
  else
    begin
    all_events_r[0]      <= i_never;
    all_events_r[1]      <= i_bstall;
    all_events_r[2]      <= i_bissue;
    all_events_r[3]      <= i_bmemrw;
    all_events_r[4]      <= i_bexec;
    all_events_r[5]      <= i_bsyncstall;
    all_events_r[6]      <= i_btrap;
    all_events_r[7]      <= i_bicmstall;
    all_events_r[8]      <= i_bdmp;
    all_events_r[9]      <= i_bestruct;
    all_events_r[10]      <= i_bdepstall;
    all_events_r[11]      <= i_bifsync;
    all_events_r[12]      <= i_bdfsync;
    all_events_r[13]      <= i_bauxflsh;
    all_events_r[14]      <= i_bfirqex;
    all_events_r[15]      <= i_bdebug;
    all_events_r[16]      <= i_bdstrhaz;
    all_events_r[17]      <= i_bdreplay;
    all_events_r[18]      <= i_bdqstall;
    all_events_r[19]      <= i_bdcstall;
    all_events_r[20]      <= i_bdmpcwb;
    all_events_r[21]      <= i_bdmplsq;
    all_events_r[22]      <= i_icsr;
    all_events_r[23]      <= i_i2byte;
    all_events_r[24]      <= i_i4byte;
    all_events_r[25]      <= i_iwfi;
    all_events_r[26]      <= i_iecall;
    all_events_r[27]      <= i_ipropcmoic;
    all_events_r[28]      <= i_ialljmp;
    all_events_r[29]      <= i_ijmpc;
    all_events_r[30]      <= i_ijmpu;
    all_events_r[31]      <= i_ijmptak;
    all_events_r[32]      <= i_icall;
    all_events_r[33]      <= i_icallret;
    all_events_r[34]      <= i_imemrd;
    all_events_r[35]      <= i_imemwr;
    all_events_r[36]      <= i_ilr;
    all_events_r[37]      <= i_isc;
    all_events_r[38]      <= i_imematomic;
    all_events_r[39]      <= i_icm;
    all_events_r[40]      <= i_dbgflush;
    all_events_r[41]      <= i_etaken;
    all_events_r[42]      <= i_qtaken;
    all_events_r[43]      <= i_dmpreplay;
    all_events_r[44]      <= i_always;
    all_events_r[45]      <= i_crun;
    all_events_r[46]      <= i_cruni;
    end
end // pct_events_PROC

reg csr_x2_read;
reg ifu_wen;
reg [11:0] csr_sel_addr_latch;
reg [`BR_CTL_RANGE] x2_br_ctl;
reg x2_bdcstall_r;

always @(posedge clk or posedge rst_a)
begin : pct_x2_PROC
  if (rst_a == 1'b1)
  begin
    csr_x2_read            <= 1'b0;
    x2_bdcstall_r          <= 1'b0;
  end
  else
  begin
    csr_x2_read            <= csr_x1_read;
    x2_bdcstall_r          <= dmp_x1_stall;
  end
end // pct_x2_PROC

always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    csr_sel_addr_latch     <= 1'b0;
  end
  else 
  begin
    csr_sel_addr_latch     <= csr_sel_addr;
  end
end

always @(posedge clk or posedge rst_a)
begin  
  if (rst_a == 1'b1)
  begin
    ifu_wen                <= 1'b0;
  end
  else if(csr_sel_addr_latch == 12'h7c9)
  begin
    ifu_wen                <= csr_x2_wen;
  end
  else 
  begin
    ifu_wen                <= 1'b0;
  end
end // 

always @(posedge clk or posedge rst_a)
begin : x2_br_ctl_PROC
  if (rst_a == 1'b1)
  begin
    x2_br_ctl              <= 1'b0;
  end
  else 
  begin
    x2_br_ctl              <= x1_br_ctl & {`BR_CTL_WIDTH{x1_pass}};
  end
end


always @(posedge clk or posedge rst_a)
begin : pct_sync_PROC
  if (rst_a == 1'b1)
  begin

    s_csr_rd_r             <= 1'b0;
    s_csr_wr_r             <= 1'b0;
    s_i2byte_r             <= 1'b0;
    s_i4byte_r             <= 1'b0;
    s_iwfi_r               <= 1'b0;
    s_iecall_r             <= 1'b0;
    s_ialljmp_r            <= 1'b0;
    s_ijmpc_r              <= 1'b0;
    s_ijmpu_r              <= 1'b0;
    s_ijmptak_r            <= 1'b0;
    s_icall_r              <= 1'b0;
    s_icallret_r           <= 1'b0;
    s_imemrd_r             <= 1'b0;
    s_imemwr_r             <= 1'b0;
    s_ilr_r                <= 1'b0;
    s_isc_r                <= 1'b0;
    s_imematomic_r         <= 1'b0;

    s_dbgflush_r           <= 1'b0;
    s_etaken_r             <= 1'b0;
    s_qtaken_r             <= 1'b0;

    s_crun_r               <= 1'b0;
    s_cruni_r              <= 1'b0;


    s_bissue_r             <= 1'b0;
    s_bicmstall_r          <= 1'b0;
    s_bifsync_r            <= 1'b0;
    s_bdfsync_r            <= 1'b0;
    s_icm_r                <= 1'b0;

    s_bstall_r             <= 1'b0;
    s_btrap_r              <= 1'b0;
    s_bestruct_r           <= 1'b0;
    s_bdepstall_r          <= 1'b0;
    s_bauxflsh_r           <= 1'b0;
    s_bfirqex_r            <= 1'b0;
    s_bdebug_r             <= 1'b0;

    //DMP
    s_bdcstall_r           <= 1'b0;
    s_dmpreplay_r          <= 1'b0;
    s_bdmpcwb_r            <= 1'b0;
    s_bdmplsq_r            <= 1'b0;

  end
  else
  begin
    
    s_csr_rd_r             <= csr_x2_read && csr_x2_pass && ~db_active_r;
    s_csr_wr_r             <= csr_x2_wen  && csr_x2_pass && ~db_active_r;
    s_i2byte_r             <= (x2_inst[1:0] == 2'b00 || x2_inst[1:0] == 2'b01 || x2_inst[1:0] == 2'b10) && x2_pass;
    s_i4byte_r             <= (x2_inst[1:0] == 2'b11) && x2_pass;
    s_iwfi_r               <= spc_x2_wfi && x2_pass ;
    s_iecall_r             <= spc_x2_ecall && x2_valid_r;

    s_ialljmp_r            <= | x2_br_ctl;
    s_ijmpc_r              <= br_x2_taken_r && (x2_br_ctl[`BR_CTL_BEQ] | x2_br_ctl[`BR_CTL_BNE] | x2_br_ctl[`BR_CTL_BLTS] | x2_br_ctl [`BR_CTL_BGES] | x2_br_ctl [`BR_CTL_BLTU] | x2_br_ctl [`BR_CTL_BGEU] );
    s_ijmpu_r              <= br_x2_taken_r && (x2_br_ctl[`BR_CTL_JAL] | x2_br_ctl[`BR_CTL_JALR] | x2_br_ctl[`BR_CTL_JT] | x2_br_ctl[`BR_CTL_JALT]);
    s_ijmptak_r            <= br_x2_taken_r;
    s_icall_r              <= (x2_br_ctl[`BR_CTL_JAL] | x2_br_ctl[`BR_CTL_JALT]);
    s_icallret_r           <= x2_br_ctl[`BR_CTL_JALR];

    s_imemrd_r             <= dmp_x2_load_r && x2_pass && (~debug_mode) 
                              && (~uop_busy_del)
                              ;
    s_imemwr_r             <= dmp_x2_store_r && x2_pass && (~debug_mode)
                              && (~uop_busy_del)
                              ;
    s_ilr_r                <= dmp_x2_lr_r && x2_pass && (~debug_mode)
                              && (~uop_busy_del)
                              ;
    s_isc_r                <= dmp_x2_sc_r && x2_pass && (~debug_mode)
                              && (~uop_busy_del)
                              ;
    s_imematomic_r         <= dmp_x2_amo_r && x2_pass && (~debug_mode)
                              && (~uop_busy_del)
                              ;

    s_dbgflush_r           <= debug_mode && (~debug_mode_r);
    s_etaken_r             <= trap_x2_valid && (~take_int);
    s_qtaken_r             <= take_int;

    s_crun_r               <= ~sys_halt_r;
    s_cruni_r              <= ~sys_halt_r && irq_enable;


    s_bissue_r             <= hpm_bissue;
    s_bicmstall_r          <= hpm_bicmstall;
    s_bifsync_r            <= hpm_bifsync;
    s_bdfsync_r            <= hpm_bdfsync;
    s_icm_r                <= hpm_icm;

    s_bstall_r             <= x1_stall 
                              | dmp_x1_stall
                              | mpy_x3_stall 
                              | soft_reset_x2_stall 
                              | spc_x2_stall | alu_x2_stall | dmp_x2_stall | cp_flush ;
    s_btrap_r              <= trap_x2_valid | trap_return | halt_restart_r;
    s_bestruct_r           <= alu_x2_stall | dmp_x2_stall 
                              | mpy_x3_stall 
                              ;                
    s_bdepstall_r          <= (x1_raw_hazard | x1_waw_hazard)
                              & x1_valid_r
                              ;
    s_bauxflsh_r           <= csr_flush_r;
    s_bfirqex_r            <= trap_x2_valid | trap_return;
    s_bdebug_r             <= halt_restart_r;

    //DMP
    s_bdcstall_r           <= x2_bdcstall_r | dmp_x2_stall;
    s_dmpreplay_r          <= hpm_dmpreplay;
    s_bdmpcwb_r            <= hpm_bdmpcwb;
    s_bdmplsq_r            <= hpm_bdmplsq;

  end
end // pct_sync_PROC


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous logic for qualifying the input pipeline signals and       //
// generating the logic for each countable condition.                     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin : cond_qual_PROC
  q_icsr             = (s_csr_rd_r | s_csr_wr_r);
  q_iwfi             = s_iwfi_r;
  q_iecall           = s_iecall_r;
  q_i2byte           = s_i2byte_r;
  q_i4byte           = s_i4byte_r;
if((arcv_mcache_op[23:0] == 24'h00_0001 || arcv_mcache_op[23:0] == 24'h00_0002 || arcv_mcache_op[23:0] == 24'h00_0003 || arcv_mcache_op[23:0] == 24'h00_0004 || arcv_mcache_op[23:0] == 24'h00_0005) && ifu_wen)
begin
  q_ipropcmoic       = 1'b1;
end
else
begin
  q_ipropcmoic       = 1'b0;
end
  q_ialljmp          = s_ialljmp_r;
  q_ijmpc            = s_ijmpc_r;
  q_ijmpu            = s_ijmpu_r;
  q_ijmptak          = s_ijmptak_r;
  q_icall            = s_icall_r;
  q_icallret         = s_icallret_r;
  q_imemrd           = s_imemrd_r;
  q_imemwr           = s_imemwr_r;

  q_ilr              = s_ilr_r;
  q_isc              = s_isc_r;
  q_imematomic       = s_imematomic_r;

  q_dbgflush         = s_dbgflush_r;
  q_etaken           = s_etaken_r;
  q_qtaken           = s_qtaken_r;

  q_crun             = s_crun_r;
  q_cruni            = s_cruni_r;


  q_bissue           = s_bissue_r;
  q_bicmstall        = s_bicmstall_r;
  q_bifsync          = s_bifsync_r;
  q_bdfsync          = s_bdfsync_r;
  q_icm              = s_icm_r;

  q_bstall           = s_bstall_r;
  q_btrap            = s_btrap_r;
  q_bestruct         = s_bestruct_r;
  q_bdepstall        = s_bdepstall_r;
  q_bauxflsh         = s_bauxflsh_r;
  q_bfirqex          = s_bfirqex_r;
  q_bdebug           = s_bdebug_r;

  //DMP
  q_bdcstall         = s_bdcstall_r;
  q_dmpreplay        = s_dmpreplay_r;
  q_bdmpcwb          = s_bdmpcwb_r;
  q_bdmplsq          = s_bdmplsq_r;

end

always @*
begin : wca_PROC

  i_never            = 1'b0;
  i_bstall            = 1'b0;
  i_bissue            = 1'b0;
  i_bmemrw            = 1'b0;
  i_bexec            = 1'b0;
  i_bsyncstall            = 1'b0;
  i_btrap            = 1'b0;
  i_bicmstall            = 1'b0;
  i_bdmp            = 1'b0;
  i_bestruct            = 1'b0;
  i_bdepstall            = 1'b0;
  i_bifsync            = 1'b0;
  i_bdfsync            = 1'b0;
  i_bauxflsh            = 1'b0;
  i_bfirqex            = 1'b0;
  i_bdebug            = 1'b0;
  i_bdstrhaz            = 1'b0;
  i_bdreplay            = 1'b0;
  i_bdqstall            = 1'b0;
  i_bdcstall            = 1'b0;
  i_bdmpcwb            = 1'b0;
  i_bdmplsq            = 1'b0;
  i_icsr            = 1'b0;
  i_i2byte            = 1'b0;
  i_i4byte            = 1'b0;
  i_iwfi            = 1'b0;
  i_iecall            = 1'b0;
  i_ipropcmoic            = 1'b0;
  i_ialljmp            = 1'b0;
  i_ijmpc            = 1'b0;
  i_ijmpu            = 1'b0;
  i_ijmptak            = 1'b0;
  i_icall            = 1'b0;
  i_icallret            = 1'b0;
  i_imemrd            = 1'b0;
  i_imemwr            = 1'b0;
  i_ilr            = 1'b0;
  i_isc            = 1'b0;
  i_imematomic            = 1'b0;
  i_icm            = 1'b0;
  i_dbgflush            = 1'b0;
  i_etaken            = 1'b0;
  i_qtaken            = 1'b0;
  i_dmpreplay            = 1'b0;
  i_always            = 1'b0;
  i_crun            = 1'b0;
  i_cruni            = 1'b0;

//CYCLE
  i_never            = 1'b0          ;
  i_always           = 1'b1          ;
  i_crun             = q_crun        ;
  i_cruni            = q_cruni       ;

//ISA
  i_icsr             = q_icsr        ;
  i_i2byte           = q_i2byte      ;
  i_i4byte           = q_i4byte      ;
  i_iwfi             = q_iwfi        ;
  i_iecall           = q_iecall      ;
  i_ipropcmoic       = q_ipropcmoic  ;
  i_ialljmp          = q_ialljmp     ;
  i_ijmpc            = q_ijmpc       ;
  i_ijmpu            = q_ijmpu       ;
  i_ijmptak          = q_ijmptak     ;
  i_icall            = q_icall       ;
  i_icallret         = q_icallret    ;
  i_imemrd           = q_imemrd      ;
  i_imemwr           = q_imemwr      ;

  i_ilr              = q_ilr         ;
  i_isc              = q_isc         ;
  i_imematomic       = q_imematomic  ;

//EXU
  i_dbgflush         = q_dbgflush    ;
  i_etaken           = q_etaken      ;
  i_qtaken           = q_qtaken      ;


//Bubbles
  i_bstall           = q_bstall      ;
  i_bissue           = q_bissue      ;
  i_bicmstall        = q_bicmstall   ;

  i_bmemrw           = q_bdmpcwb  | q_bdmplsq | q_bdcstall | q_dmpreplay;
  i_bdmp             = q_bdmpcwb  | q_bdmplsq | q_bdcstall | q_dmpreplay;
  i_bdstrhaz         = q_bdmpcwb  | q_bdmplsq | q_bdcstall;  
  i_bdreplay         = q_dmpreplay   ;
  i_bdqstall         = q_bdmpcwb | q_bdmplsq;
  i_bdcstall         = q_bdcstall    ;
  i_bdmpcwb          = q_bdmpcwb     ;
  i_bdmplsq          = q_bdmplsq     ;

  i_bexec            = q_bestruct | q_bdepstall ;
  i_bestruct         = q_bestruct    ;
  i_bdepstall        = q_bdepstall   ;

  i_bsyncstall       = q_bifsync | q_bdfsync | q_bauxflsh;
  i_bifsync          = q_bifsync     ;
  i_bdfsync          = q_bdfsync     ;
  i_bauxflsh         = q_bauxflsh    ;

  i_btrap            = q_btrap       ;
  i_bfirqex          = q_bfirqex     ;
  i_bdebug           = q_bdebug      ;

//IFU
  i_icm              = q_icm         ;

//DMP
  i_dmpreplay        = q_dmpreplay   ;

end

assign pct_unit_enable = ((|x1_csr_ctl) & csr_hpm_range) 
                         | csr_arcv_mcounterintact_expl_wen 
                         | ~((&mcountinhibit_r[`CNT_CTRL_MSB:`lsb + 2]) & mcountinhibit_r[0]);

endmodule // module : rl_hpm

