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
`include "rv_safety_exported_defines.v"


// Set simulation timescale
//
`include "const.def"


module arcv_watchdog (

  ////////// Internal input signals /////////////////////////////////////////
  //
  input                           db_active,     // Host debug op in progress
  input                           sys_halt_r,    // halted status of CPU(s)

  ////////// CSR access interface /////////////////////////////////////////
  //
  input [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input [11:0]                    csr_sel_addr,          // (X1) CSR address
  
  output [`DATA_RANGE]            csr_rdata,             // (X1) CSR read data
  output                          csr_illegal,           // (X1) illegal
  output                          csr_unimpl,            // (X1) Invalid CSR
  output                          csr_serial_sr,         // (X1) SR group flush pipe
  output                          csr_strict_sr,         // (X1) SR flush pipe
  
  input                           csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input [11:0]                    csr_waddr,             // (X2) CSR addr
  input [`DATA_RANGE]             csr_wdata,             // (X2) Write data

  input                           x2_pass,               // (X2) commit
  input [1:0]                     priv_level_r,
  output                          csr_raw_hazard,

  ////////// Interrupt interface /////////////////////////////////////////
  //
  output                          irq_wdt,

  ////////// Watchdog external signals ///////////////////////////////////
  //
  output                          reg_wr_en0,
  input                           wdt_clk_enable_sync, // Bit0 of wdt clock synced to core clock
  output                          wdt_feedback_bit,    // Bit1 of core clock feedback to wdt clock
  output                          wdt_reset0,      // Reset timeout signal from clk

  ////////// General input signals /////////////////////////////////////////
  //
  input                           clk,
  input                           ungated_clk,
  input                           rst_a

);

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Signal/Register Declerations                                           //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
wire [`WDT_CTRL_RANGE]         wdt_control0_r;
wire [31:0]          wdt_period0_r;
wire [31:0]          wdt_period_cnt0_r;
wire [31:0]          wdt_lthresh0_r;
wire [31:0]          wdt_uthresh0_r;
wire                           i_enable_regs_in;
wire                           wdt_en_control_r;
wire                           wdt_en_period_r;
wire                           wdt_en_lthresh_r;
wire                           wdt_en_uthresh_r;
wire                           wdt_en_index_r;
wire                           wdt_en_passwd_r;

wire                           mst_passwd_match;
wire                           valid_wr;

wire [`DATA_RANGE]             csr_wr_data;

wire                           csr_password_wen;
wire                           csr_ctrl_wen;
wire                           csr_period_wen;
wire                           csr_index_wen;
wire                           csr_lthresh_wen;
wire                           csr_uthresh_wen;
wire                           csr_passwd_pw0_wen;
wire                           csr_passwd_rst0_wen;
wire                           csr_ctrl0_wen;
wire                           csr_period0_wen;
wire                           csr_lthresh0_wen;
wire                           csr_uthresh0_wen;
wire [1:0]                     wdt_index_r;
wire [`WATCHDOG_NUM-1:0]       wdt_index_sel;



arcv_watchdog_csr u_arcv_watchdog_csr(

  ////////// CSR access interface /////////////////////////////////////////
  //
  .csr_sel_ctl                       (csr_sel_ctl),           // (X1) CSR slection (01 = read, 10 = write)
  .csr_sel_addr                      (csr_sel_addr),          // (X1) CSR address
  
  .csr_rdata                         (csr_rdata),             // (X1) CSR read data
  .csr_illegal                       (csr_illegal),           // (X1) illegal
  .csr_unimpl                        (csr_unimpl),            // (X1) Invalid CSR
  .csr_serial_sr                     (csr_serial_sr),         // (X1) SR group flush pipe
  .csr_strict_sr                     (csr_strict_sr),         // (X1) SR flush pipe
  
  .csr_write                         (csr_write),             // (X2) CSR operation (01 = read, 10 = write)
  .csr_waddr                         (csr_waddr),             // (X2) CSR addr
  .csr_wdata                         (csr_wdata),             // (X2) Write data

  .x2_pass                           (x2_pass),               // (X2) commit
  .priv_level_r                      (priv_level_r),
  .csr_raw_hazard                    (csr_raw_hazard),

  ////////// Control signals interface /////////////////////////////////////////
  //
  .wdt_control0_r              (wdt_control0_r),
  .wdt_period0_r               (wdt_period0_r),
  .wdt_period_cnt0_r           (wdt_period_cnt0_r),
  .wdt_lthresh0_r              (wdt_lthresh0_r),
  .wdt_uthresh0_r              (wdt_uthresh0_r),
  .i_enable_regs_in                  (i_enable_regs_in),
  .wdt_en_control_r                  (wdt_en_control_r),
  .wdt_en_period_r                   (wdt_en_period_r),
  .wdt_en_lthresh_r                  (wdt_en_lthresh_r),
  .wdt_en_uthresh_r                  (wdt_en_uthresh_r),
  .wdt_en_index_r                    (wdt_en_index_r),
  .wdt_en_passwd_r                   (wdt_en_passwd_r),

  .mst_passwd_match                  (mst_passwd_match),
  .valid_wr                          (valid_wr),
  .db_active                         (db_active),

  .csr_wr_data                       (csr_wr_data),
  .csr_password_wen                  (csr_password_wen),
  .csr_ctrl_wen                      (csr_ctrl_wen),
  .csr_period_wen                    (csr_period_wen),
  .csr_index_wen                     (csr_index_wen),
  .csr_lthresh_wen                   (csr_lthresh_wen),
  .csr_uthresh_wen                   (csr_uthresh_wen),
  .csr_passwd_pw0_wen          (csr_passwd_pw0_wen),
  .csr_passwd_rst0_wen         (csr_passwd_rst0_wen),
  .csr_ctrl0_wen               (csr_ctrl0_wen),
  .csr_period0_wen             (csr_period0_wen),
  .csr_lthresh0_wen            (csr_lthresh0_wen),
  .csr_uthresh0_wen            (csr_uthresh0_wen),
  .wdt_index_r                       (wdt_index_r),
  .wdt_index_sel                     (wdt_index_sel)

);

arcv_watchdog_ctrl u_arcv_watchdog_ctrl(

  .db_active                         (db_active),     // Host debug op in progress
  .sys_halt_r                        (sys_halt_r),    // halted status of CPU(s)

  ////////// Interrupt interface /////////////////////////////////////////
  //
  .irq_wdt                           (irq_wdt),

  ////////// Watchdog external signals ///////////////////////////////////
  //
  .reg_wr_en0                    (reg_wr_en0),
  .wdt_reset0                    (wdt_reset0),      // Reset timeout signal from clk
  .wdt_clk_enable_sync               (wdt_clk_enable_sync),
  .wdt_feedback_bit                  (wdt_feedback_bit),

  ////////// Control signals interface /////////////////////////////////////////
  //
  .csr_wr_data                       (csr_wr_data), 
  .wdt_control0_r              (wdt_control0_r),
  .wdt_period0_r               (wdt_period0_r),
  .wdt_period_cnt0_r           (wdt_period_cnt0_r),
  .wdt_lthresh0_r              (wdt_lthresh0_r),
  .wdt_uthresh0_r              (wdt_uthresh0_r),
  .i_enable_regs_in                  (i_enable_regs_in),
  .wdt_en_control_r                  (wdt_en_control_r),
  .wdt_en_period_r                   (wdt_en_period_r),
  .wdt_en_lthresh_r                  (wdt_en_lthresh_r),
  .wdt_en_uthresh_r                  (wdt_en_uthresh_r),
  .wdt_en_index_r                    (wdt_en_index_r),
  .wdt_en_passwd_r                   (wdt_en_passwd_r),

  .mst_passwd_match                  (mst_passwd_match),
  .valid_wr                          (valid_wr),

  .csr_password_wen                  (csr_password_wen),
  .csr_ctrl_wen                      (csr_ctrl_wen),
  .csr_period_wen                    (csr_period_wen),
  .csr_index_wen                     (csr_index_wen),
  .csr_lthresh_wen                   (csr_lthresh_wen),
  .csr_uthresh_wen                   (csr_uthresh_wen),
  .csr_passwd_pw0_wen          (csr_passwd_pw0_wen),
  .csr_passwd_rst0_wen         (csr_passwd_rst0_wen),
  .csr_ctrl0_wen               (csr_ctrl0_wen),
  .csr_period0_wen             (csr_period0_wen),
  .csr_lthresh0_wen            (csr_lthresh0_wen),
  .csr_uthresh0_wen            (csr_uthresh0_wen),
  .wdt_index_r                       (wdt_index_r),
  .wdt_index_sel                     (wdt_index_sel),
  ////////// General input signals /////////////////////////////////////////
  //
  .clk                               (clk),
  .ungated_clk                       (ungated_clk),          // ungated clock used for core clock stuck-at error feedback
  .rst_a                             (rst_a)

);

endmodule // arcv_watchdog
