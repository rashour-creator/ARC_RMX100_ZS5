// Library ARCv5EM-3.5.999999999

`include "defines.v"
`include "alu_defines.v"

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
//         rl_core
//            |
//            +--
//            |
//            +--
//            |
//            +--
//            |
//            +--
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions
//
`include "defines.v"
`include "ifu_defines.v"
`include "csr_defines.v"
`include "dmp_defines.v"
`include "mpy_defines.v"
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"



`ifndef SYNTHESIS
`ifndef VERILATOR
`define SIMULATION
`endif
`endif

module rl_core (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                    // clock signal
  input                          clk_gated,              // Gated clock signal
  input                          clk_mpy,
  input                          rst_init_disable_r,     // Disabe initialization upon reset

  input                          rst_a,                  // reset signal
  input                          rst_hard,               // hard reset signal
  input                          is_soft_reset,          // soft reset indication signal
  input                          cpu_in_reset_state,     // cpu in reset signal
 ///////// Reset PC ////////////////////////////////////////////////////////////////
 //
 input  [21:0]                  reset_pc_in,           // Input pins  defining RESET_PC[31:10]
`ifdef SIMULATION
  input [`DATA_RANGE]           mip_r,
  input [`DATA_RANGE]           mie_r,
`endif


  ////////// Resumable NMI //////////////////////////////////////////////////////
  //
  input                          rnmi_synch_r,



  ////////// ASYNC Halt-Run Interface /////////////////////////////////////////////
  //
  input                          dm2arc_halt_on_reset,
  input                          is_dm_rst,
  input                          gb_sys_run_req_r,
  input                          gb_sys_halt_req_r,
  output                         gb_sys_run_ack_r,
  output                         gb_sys_halt_ack_r,

  ////////// Clock control signals /////////////////////////////////////////////
  //
  output                         dmp_idle_r,
  output                         ifu_idle_r,
  input                          ar_clock_enable_r,
  output                         iccm_dmi_clock_enable_nxt,
  output                         dccm_dmi_clock_enable_nxt,
  output                         mmio_dmi_clock_enable_nxt,
  output                         db_clock_enable_nxt,
  output                         ic_idle_ack,
  output                         ifu_issue,
  output [`FU_1H_RANGE]          ifu_pd_fu,
  output                         mpy_x1_valid,
  output                         mpy_x2_valid,
  output                         mpy_x3_valid_r,


  ////////// SRAM interface ////////////////////////////////////////////////
  //
  output  iccm0_clk,
  output [`ICCM0_DRAM_RANGE] iccm0_din,
  output [`ICCM0_ADR_RANGE] iccm0_addr,
  output  iccm0_cs,
  output  iccm0_we,
  output [`ICCM_MASK_RANGE] iccm0_wem,
  input  [`ICCM0_DRAM_RANGE] iccm0_dout,


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

  ////////// SRAM interface ////////////////////////////////////////////////
  //
  ////////// SRAM IC TAG interface ////////////////////////////////////////////////
  output  ic_tag_mem_clk,
  output [`IC_TAG_SET_RANGE] ic_tag_mem_din,
  output [`IC_IDX_RANGE] ic_tag_mem_addr,
  output  ic_tag_mem_cs,
  output  ic_tag_mem_we,
  output [`IC_TAG_SET_RANGE] ic_tag_mem_wem,
  input  [`IC_TAG_SET_RANGE] ic_tag_mem_dout,
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  output  ic_data_mem_clk,
  output [`IC_DATA_SET_RANGE] ic_data_mem_din,
  output [`IC_DATA_ADR_RANGE] ic_data_mem_addr,
  output  ic_data_mem_cs,
  output  ic_data_mem_we,
  output [`IC_DATA_SET_RANGE] ic_data_mem_wem,
  input  [`IC_DATA_SET_RANGE] ic_data_mem_dout,


  output                         x2_pass,

// Place holder for trigger
  input [1:0]                    ext_trig_accept,
  input [15:0]                   ext_trig_in,
  output [1:0]                   ext_trig_valid,

  ////////// CLINT interface ////////////////////////////////////////////
  //
  output [1:0]                   csr_clint_sel_ctl,      // (X1) CSR slection (01 = read, 10 = write)
  output [11:0]                  csr_clint_sel_addr,     // (X1) CSR address

  input [`DATA_RANGE]            clint_csr_rdata,        // (X1) CSR read data
  input                          clint_csr_illegal,      // (X1) illegal
  input                          clint_csr_unimpl,       // (X1) Invalid CSR
  input                          clint_csr_serial_sr,    // (X1) SR group flush pipe
  input                          clint_csr_strict_sr,    // (X1) SR flush pipe
  output                         csr_clint_ren_r,

  output                         csr_clint_write,        // (X2) CSR operation (01 = read, 10 = write)
  output [11:0]                  csr_clint_waddr,        // (X2) CSR addr
  output [`DATA_RANGE]           csr_clint_wdata,        // (X2) Write data
  input  [7:0]                   mtopi_iid,
  input  [`DATA_RANGE]           mireg_clint,
  output                         mireg_clint_wen,
  output                         mtvec_mode,
  output                         trap_ack,

  input  [7:0]                   irq_id,
  input                          irq_trap,              // Interrupt in from CLINT

  output [`DATA_RANGE]           miselect_r,           //
  output                         ibp_mmio_cmd_valid,
  output  [3:0]                  ibp_mmio_cmd_cache,
  output                         ibp_mmio_cmd_burst_size,
  output                         ibp_mmio_cmd_read,
  output                         ibp_mmio_cmd_aux,
  input                          ibp_mmio_cmd_accept,
  output  [`ADDR_RANGE]          ibp_mmio_cmd_addr,
  output                         ibp_mmio_cmd_excl,
  output  [5:0]                  ibp_mmio_cmd_atomic,
  output  [2:0]                  ibp_mmio_cmd_data_size,
  output  [1:0]                  ibp_mmio_cmd_prot,

  output                         ibp_mmio_wr_valid,
  output                         ibp_mmio_wr_last,
  input                          ibp_mmio_wr_accept,
  output  [3:0]                  ibp_mmio_wr_mask,
  output  [31:0]                 ibp_mmio_wr_data,

  input                          ibp_mmio_rd_valid,
  input                          ibp_mmio_rd_err,
  input                          ibp_mmio_rd_excl_ok,
  input                          ibp_mmio_rd_last,
  output                         ibp_mmio_rd_accept,
  input  [31:0]                  ibp_mmio_rd_data,

  input                          ibp_mmio_wr_done,
  input                          ibp_mmio_wr_excl_okay,
  input                          ibp_mmio_wr_err,
  output                         ibp_mmio_wr_resp_accept,


  output [1:0]                   priv_level_r,
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


  output                         high_prio_ras,

  output                         sfty_ibp_mmio_cmd_valid,
  output  [3:0]                  sfty_ibp_mmio_cmd_cache,
  output                         sfty_ibp_mmio_cmd_burst_size,
  output                         sfty_ibp_mmio_cmd_read,
  output                         sfty_ibp_mmio_cmd_aux,
  input                          sfty_ibp_mmio_cmd_accept,
  output  [7:0]                  sfty_ibp_mmio_cmd_addr,
  output                         sfty_ibp_mmio_cmd_excl,
  output  [5:0]                  sfty_ibp_mmio_cmd_atomic,
  output  [2:0]                  sfty_ibp_mmio_cmd_data_size,
  output  [1:0]                  sfty_ibp_mmio_cmd_prot,

  output                         sfty_ibp_mmio_wr_valid,
  output                         sfty_ibp_mmio_wr_last,
  input                          sfty_ibp_mmio_wr_accept,
  output  [3:0]                  sfty_ibp_mmio_wr_mask,
  output  [31:0]                 sfty_ibp_mmio_wr_data,

  input                          sfty_ibp_mmio_rd_valid,
  input                          sfty_ibp_mmio_rd_err,
  input                          sfty_ibp_mmio_rd_excl_ok,
  input                          sfty_ibp_mmio_rd_last,
  output                         sfty_ibp_mmio_rd_accept,
  input  [31:0]                  sfty_ibp_mmio_rd_data,

  input                          sfty_ibp_mmio_wr_done,
  input                          sfty_ibp_mmio_wr_excl_okay,
  input                          sfty_ibp_mmio_wr_err,
  output                         sfty_ibp_mmio_wr_resp_accept,

  output                         sfty_mem_sbe_err,
  output                         sfty_mem_dbe_err,
  output                         sfty_mem_adr_err,
  output                         sfty_mem_sbe_overflow,
// IBP e2e protection interface
  output                         sfty_ibp_mmio_cmd_valid_pty,
  input                          sfty_ibp_mmio_cmd_accept_pty,
  output                         sfty_ibp_mmio_cmd_addr_pty,
  output [3:0]                   sfty_ibp_mmio_cmd_ctrl_pty,

  output                         sfty_ibp_mmio_wr_valid_pty,
  input                          sfty_ibp_mmio_wr_accept_pty,
  output                         sfty_ibp_mmio_wr_last_pty,

  input                          sfty_ibp_mmio_rd_valid_pty,
  output                         sfty_ibp_mmio_rd_accept_pty,
  input                          sfty_ibp_mmio_rd_ctrl_pty,
  input  [3:0]                   sfty_ibp_mmio_rd_data_pty,

  input                          sfty_ibp_mmio_wr_done_pty,
  input                          sfty_ibp_mmio_wr_ctrl_pty,
  output                         sfty_ibp_mmio_wr_resp_accept_pty,
  output                         sfty_ibp_mmio_ini_e2e_err,
  output [1:0]                   dr_secure_trig_iso_err,
  ////////// AHB5 initiator ////////////////////////////////////////////////
  //
  output                         ahb_hlock,
  output                         ahb_hexcl,
  output [3:0]                   ahb_hmaster,
  output [`AUSER_RANGE]          ahb_hauser,
  output                         ahb_hwrite,
  output [`ADDR_RANGE]           ahb_haddr,
  output [1:0]                   ahb_htrans,
  output [2:0]                   ahb_hsize,
  output [2:0]                   ahb_hburst,
  output [3:0]                   ahb_hwstrb,
  output [6:0]                   ahb_hprot,
  output                         ahb_hnonsec,
  input                          ahb_hready,
  input                          ahb_hresp,
  input                          ahb_hexokay,
  input [`DATA_RANGE]            ahb_hrdata,
  output [`DATA_RANGE]           ahb_hwdata,

 ///////// AHB5 bus protection signals /////////////////////////////////////
 //
  output [`AUSER_PTY_RANGE]      ahb_hauserchk,
  output [3:0]                   ahb_haddrchk,
  output                         ahb_htranschk,
  output                         ahb_hctrlchk1,      // Parity of ahb_hburst, ahb_hlock, ahb_hwrite, ahb_hsize
  output                         ahb_hctrlchk2,      // Parity of ahb_hexcl, ahb_hmaster
  output                         ahb_hprotchk,
  output                         ahb_hwstrbchk,
  input                          ahb_hreadychk,
  input                          ahb_hrespchk,       // Parity of ahb_hresp, ahb_hexokay
  input  [3:0]                   ahb_hrdatachk,
  output [3:0]                   ahb_hwdatachk,

  output reg                     ahb_fatal_err,

  ///////// PER AHB5 initiator ////////////////////////////////////////
  output                         dbu_per_ahb_hlock,
  output                         dbu_per_ahb_hexcl,
  output [3:0]                   dbu_per_ahb_hmaster,
  output                         dbu_per_ahb_hwrite,
  output [`AUSER_RANGE]          dbu_per_ahb_hauser,
  output [`ADDR_RANGE]           dbu_per_ahb_haddr,
  output [1:0]                   dbu_per_ahb_htrans,
  output [2:0]                   dbu_per_ahb_hsize,
  output [2:0]                   dbu_per_ahb_hburst,
  output [3:0]                   dbu_per_ahb_hwstrb,
  output [6:0]                   dbu_per_ahb_hprot,
  output                         dbu_per_ahb_hnonsec,
  input                          dbu_per_ahb_hready,
  input                          dbu_per_ahb_hresp,
  input                          dbu_per_ahb_hexokay,
  input [`DATA_RANGE]            dbu_per_ahb_hrdata,
  output [`DATA_RANGE]           dbu_per_ahb_hwdata,
 ///////// PER AHB5 bus protection signals /////////////////////////////////////
 //
  output [`AUSER_PTY_RANGE]      dbu_per_ahb_hauserchk,
  output [3:0]                   dbu_per_ahb_haddrchk,
  output                         dbu_per_ahb_htranschk,
  output                         dbu_per_ahb_hctrlchk1,      // Parity of dbu_per_ahb_hburst, dbu_per_ahb_hlock, dbu_per_ahb_hwrite, dbu_per_ahb_hsize
  output                         dbu_per_ahb_hctrlchk2,
  output                         dbu_per_ahb_hprotchk,
  output                         dbu_per_ahb_hwstrbchk,
  input                          dbu_per_ahb_hreadychk,
  input                          dbu_per_ahb_hrespchk,
  input  [3:0]                   dbu_per_ahb_hrdatachk,
  output [3:0]                   dbu_per_ahb_hwdatachk,

  output reg                     dbu_per_ahb_fatal_err,


  ///////// ICCM0/ICCM1 DMI AHB5 initiator /////////////////////////////////
  input                         iccm_ahb_prio,
  input                         iccm_ahb_hlock,
  input                         iccm_ahb_hexcl,
  input  [3:0]                  iccm_ahb_hmaster,

  input  [`ICCM_DMI_NUM-1:0]    iccm_ahb_hsel,
  input  [1:0]                  iccm_ahb_htrans,
  input                         iccm_ahb_hwrite,
  input  [`ADDR_RANGE]          iccm_ahb_haddr,
  input  [2:0]                  iccm_ahb_hsize,
  input  [3:0]                  iccm_ahb_hwstrb,
  input  [2:0]                  iccm_ahb_hburst,
  input  [6:0]                  iccm_ahb_hprot,
  input                         iccm_ahb_hnonsec,
  input  [`ICCM_DMI_DATA_RANGE] iccm_ahb_hwdata,
  input                         iccm_ahb_hready,
  output [`ICCM_DMI_DATA_RANGE] iccm_ahb_hrdata,
  output                        iccm_ahb_hresp,
  output                        iccm_ahb_hexokay,
  output                        iccm_ahb_hready_resp,
 ///////// ICCM0/ICCM1 DMI AHB5 bus protection signals /////////////////////////////////////
 //
  input  [3:0]                  iccm_ahb_haddrchk,
  input                         iccm_ahb_htranschk,
  input                         iccm_ahb_hctrlchk1,
  input                         iccm_ahb_hctrlchk2,
  input                         iccm_ahb_hwstrbchk,
  input                         iccm_ahb_hprotchk,
  input                         iccm_ahb_hreadychk,
  output                        iccm_ahb_hrespchk,
  output                        iccm_ahb_hready_respchk,
  input                         iccm_ahb_hselchk,
  output [3:0]                  iccm_ahb_hrdatachk,
  input  [3:0]                  iccm_ahb_hwdatachk,
  output reg                    iccm_ahb_fatal_err,

  ///////// DCCM DMI AHB5 initiator ////////////////////////////////////////
  input                         dccm_ahb_prio,
  input                         dccm_ahb_hlock,
  input                         dccm_ahb_hexcl,
  input  [3:0]                  dccm_ahb_hmaster,

  input  [`DCCM_DMI_NUM-1:0]    dccm_ahb_hsel,
  input  [1:0]                  dccm_ahb_htrans,
  input                         dccm_ahb_hwrite,
  input  [`ADDR_RANGE]          dccm_ahb_haddr,
  input  [2:0]                  dccm_ahb_hsize,
  input  [3:0]                  dccm_ahb_hwstrb,
  input  [2:0]                  dccm_ahb_hburst,
  input  [6:0]                  dccm_ahb_hprot,
  input                         dccm_ahb_hnonsec,
  input  [`DCCM_DMI_DATA_RANGE] dccm_ahb_hwdata,
  input                         dccm_ahb_hready,
  output [`DCCM_DMI_DATA_RANGE] dccm_ahb_hrdata,
  output                        dccm_ahb_hresp,
  output                        dccm_ahb_hexokay,
  output                        dccm_ahb_hready_resp,
 ///////// DCCM DMI AHB5 bus protection signals /////////////////////////////////////
 //
  input  [3:0]                  dccm_ahb_haddrchk,
  input                         dccm_ahb_htranschk,
  input                         dccm_ahb_hctrlchk1,
  input                         dccm_ahb_hctrlchk2,
  input                         dccm_ahb_hwstrbchk,
  input                         dccm_ahb_hprotchk,
  input                         dccm_ahb_hreadychk,
  output                        dccm_ahb_hrespchk,
  output                        dccm_ahb_hready_respchk,
  input                         dccm_ahb_hselchk,
  output [3:0]                  dccm_ahb_hrdatachk,
  input  [3:0]                  dccm_ahb_hwdatachk,
  output reg                    dccm_ahb_fatal_err,

  ///////// MMIO DMI AHB5 initiator ////////////////////////////////////////
  input                         mmio_ahb_prio,
  input                         mmio_ahb_hlock,
  input                         mmio_ahb_hexcl,
  input  [3:0]                  mmio_ahb_hmaster,

  input                         mmio_ahb_hsel,
  input  [1:0]                  mmio_ahb_htrans,
  input                         mmio_ahb_hwrite,
  input  [`ADDR_RANGE]          mmio_ahb_haddr,
  input  [2:0]                  mmio_ahb_hsize,
  input  [3:0]                  mmio_ahb_hwstrb,
  input  [2:0]                  mmio_ahb_hburst,
  input  [6:0]                  mmio_ahb_hprot,
  input                         mmio_ahb_hnonsec,
  input  [`DATA_RANGE]          mmio_ahb_hwdata,
  input                         mmio_ahb_hready,
  output [`DATA_RANGE]          mmio_ahb_hrdata,
  output                        mmio_ahb_hresp,
  output                        mmio_ahb_hexokay,
  output                        mmio_ahb_hready_resp,
 ///////// MMIO DMI AHB5 bus protection signals /////////////////////////////////////
 //
  input  [3:0]                  mmio_ahb_haddrchk,
  input                         mmio_ahb_htranschk,
  input                         mmio_ahb_hctrlchk1,
  input                         mmio_ahb_hctrlchk2,
  input                         mmio_ahb_hwstrbchk,
  input                         mmio_ahb_hprotchk,
  input                         mmio_ahb_hreadychk,
  output                        mmio_ahb_hrespchk,
  output                        mmio_ahb_hready_respchk,
  input                         mmio_ahb_hselchk,
  output [3:0]                  mmio_ahb_hrdatachk,
  input  [3:0]                  mmio_ahb_hwdatachk,
  output reg                    mmio_ahb_fatal_err,
  input  [11:0]                 core_mmio_base_in,

  ////////// SAFETY initiator ////////////////////////////////////////////////
  output [1:0]                   safety_comparator_enable,
  output [`RV_LSC_DIAG_RANGE]    lsc_diag_aux_r,
  output [1:0]                   dr_lsc_stl_ctrl_aux_r,
  output                         lsc_shd_ctrl_aux_r,
  output [1:0]                   dr_sfty_aux_parity_err_r,
  output [1:0]                   dr_bus_fatal_err,
  input [1:0]                    dr_safety_comparator_enabled,
  input                          safety_iso_enb_synch_r,
  output                         sfty_nsi_r,
  input [`RV_LSC_ERR_STAT_RANGE] lsc_err_stat_aux,
  input [1:0]                    dr_sfty_eic,
  output [1:0]                   dr_safety_iso_err,
  //

  ////////// IBP debug interface //////////////////////////////////////////
  // Command channel
  input  					     dbg_ibp_cmd_valid,  // valid command
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
  output      					 dbg_ibp_wr_done,    //
  output      					 dbg_ibp_wr_err,     //
  input                  dbg_ibp_wr_resp_accept,
  input                          relaxedpriv,
  
  //////////  World Guard  Interface  /////////////////////////////////////////
  //
  input   [`WID_RANGE]           wid_rlwid,
  input   [63:0]                 wid_rwiddeleg,

  //////////  Soft  Reset  Interface  /////////////////////////////////////////
  //
  input                          soft_reset_prepare,
  output                         soft_reset_ready,

  input   [63:0]                 mtime_r,
  input   [7:0]                  arcnum /* verilator public_flat */,

  output                      pct_unit_enable,
  input                       clk_hpm,       // clk   for PCT
  output                      hpm_int_overflow_rising,
  output                      hpm_int_overflow_r,
  input                       time_ovf,

  ////////// Machine Halt / Sleep Status//////////////////////////////////////
  //
  output                         sys_halt_r /* verilator public_flat */,
  output                         sys_sleep_r,
  output                         critical_error,
  output  [`EXT_SMODE_RANGE]     sys_sleep_mode_r
);


// Wires
//


wire                             dmp_x2_mva_stall_r;
wire [7:0]                       arcv_mecc_diag_ecc;
wire                             trap_clear_lf;
wire                             debug_mode;
wire                             db_exception;
wire                             mprven_r;
wire                                         ic_tag_ecc_addr_err;
wire                                         ic_tag_ecc_sb_err;
wire                                         ic_tag_ecc_db_err;
wire   [`IC_TAG_ECC_MSB-1:`IC_TAG_ECC_LSB]   ic_tag_ecc_syndrome;
wire   [`IC_IDX_RANGE]                       ic_tag_ecc_addr;
wire                                         ic_data_ecc_addr_err;
wire                                         ic_data_ecc_sb_err;
wire                                         ic_data_ecc_db_err;
wire   [`IC_DATA_ECC_MSB-1:`IC_DATA_ECC_LSB] ic_data_ecc_syndrome;
wire   [`IC_DATA_ADR_RANGE]                  ic_data_ecc_addr;
wire                                        iccm0_ecc_addr_err;
wire                                        iccm0_ecc_sb_err;
wire                                        iccm0_ecc_db_err;
wire  [`ICCM0_ECC_MSB-1:0]                  iccm0_ecc_syndrome;
wire  [`ICCM0_ADR_RANGE]                    iccm0_ecc_addr;

wire                                        dccm_even_ecc_addr_err;
wire                                        dccm_even_ecc_sb_err;
wire                                        dccm_even_ecc_db_err;
wire  [`DCCM_ECC_MSB-1:0]                   dccm_even_ecc_syndrome;
wire  [`DCCM_ADR_RANGE]                     dccm_even_ecc_addr;
wire                                        dccm_odd_ecc_addr_err;
wire                                        dccm_odd_ecc_sb_err;
wire                                        dccm_odd_ecc_db_err;
wire  [`DCCM_ECC_MSB-1:0]                   dccm_odd_ecc_syndrome;
wire  [`DCCM_ADR_RANGE]                     dccm_odd_ecc_addr;

wire  [`DCCM_BANKS-1:0]                     dccm_ecc_scrub_err;

wire                       iccm_ecc_excpn;
wire                       iccm_dmp_ecc_err;
wire                       iccm_ecc_wr;
wire  [`ICCM0_ECC_RANGE]   iccm0_ecc_out;

wire                       dccm_ecc_excpn;
wire                       dccm_ecc_wr;
wire  [`DCCM_ECC_RANGE]    dccm_ecc_out;

wire [`PC_RANGE]              ifu_pc;
wire [2:0]                    ifu_size;
wire [4:0]                    ifu_pd_addr0;
wire [4:0]                    ifu_pd_addr1;
wire [31:0]                   ifu_inst;
wire [1:0]                    ifu_fusion;
wire [`IFU_EXCP_RANGE]        ifu_exception;

wire                          x1_holdup;

wire                          spc_x2_clean;
wire                          spc_x2_flush;
wire                          spc_x2_inval;
wire                          spc_x2_zero;
wire                          spc_x2_prefetch;
wire [`DATA_RANGE]            spc_x2_data;
wire                          icmo_done;
wire                          halt_req_asserted;
wire                          kill_ic_op;
wire                          halt_fsm_in_rst;
wire                          uop_busy;

wire                          fch_restart;
wire                          fch_restart_vec;
wire [`PC_RANGE]              fch_target;
wire                          fch_stop_r;

wire                          br_req_ifu;
wire [`PC_RANGE]              br_restart_pc;

wire                          x1_pass;
wire [`DMP_CTL_RANGE]         x1_dmp_ctl;
wire                          x1_valid_r;
wire [`DATA_RANGE]            x1_src0_data;
wire [`DATA_RANGE]            x1_src1_data;
wire [`DATA_RANGE]            x1_src2_data;
wire [4:0]                    x1_dst_id;
wire                          dmp_x1_stall;
wire                          lsq_empty;
wire                          dmp_x2_stall;
wire                          dmp_x2_replay;
wire                          x2_valid_r;

wire                          x2_enable;

wire [`DATA_RANGE]            dmp_x2_data;
wire [`DATA_RANGE]            dmp_x2_data_r;
wire [`ADDR_RANGE]            dmp_x2_addr_r;
wire                          dmp_x2_load_r;
wire                          dmp_x2_grad;
wire [4:0]                    dmp_x2_dst_id_r;
wire                          dmp_x2_dst_id_valid;
wire                          dmp_retire_req;
wire [4:0]                    dmp_retire_dst_id;
wire                          dmp_rb_req_r;
wire                          dmp_rb_post_commit;
wire                          dmp_rb_retire_err;
wire [4:0]                    dmp_rb_dst_id;
wire                          rb_dmp_ack;
wire [`DMP_EXCP_RANGE]        dmp_exception_sync;
wire [1:0]                    dmp_exception_async;

wire                          dmp_lsq0_dst_valid;
wire [4:0]                    dmp_lsq0_dst_id;
wire                          dmp_lsq1_dst_valid;
wire [4:0]                    dmp_lsq1_dst_id;

wire                          x3_flush_r;

wire [`WID_RANGE]             wid;
wire                          instret_ovf;
wire                          cycle_ovf;

wire                          lsq_iccm_cmd_valid;
wire  [3:0]                   lsq_iccm_cmd_cache;
wire                          lsq_iccm_cmd_burst_size;
wire                          lsq_iccm_cmd_read;
wire                          lsq_iccm_cmd_aux;
wire                          lsq_iccm_cmd_accept;
wire  [`ADDR_RANGE]           lsq_iccm_cmd_addr;
wire                          lsq_iccm_cmd_excl;
wire  [5:0]                   lsq_iccm_cmd_atomic;
wire  [2:0]                   lsq_iccm_cmd_data_size;
wire  [1:0]                   lsq_iccm_cmd_prot;

wire                          lsq_iccm_wr_valid;
wire                          lsq_iccm_wr_last;
wire                          lsq_iccm_wr_accept;
wire  [3:0]                   lsq_iccm_wr_mask;
wire  [31:0]                  lsq_iccm_wr_data;

wire                          lsq_iccm_rd_valid;
wire                          lsq_iccm_rd_err;
wire                          lsq_iccm_rd_excl_ok;
wire                          lsq_iccm_rd_last;
wire                          lsq_iccm_rd_accept;
wire  [31:0]                  lsq_iccm_rd_data;

wire                          lsq_iccm_wr_done;
wire                          lsq_iccm_wr_excl_okay;
wire                          lsq_iccm_wr_err;
wire                          lsq_iccm_wr_resp_accept;
 wire                                 dmi_iccm_cmd_valid;
 wire                                 dmi_iccm_cmd_prio;
 wire  [3:0]                          dmi_iccm_cmd_cache;
 wire                                 dmi_iccm_cmd_burst_size;
 wire                                 dmi_iccm_cmd_read;
 wire  [`ADDR_RANGE]                  dmi_iccm_cmd_addr;
 wire                                 dmi_iccm_cmd_excl;
 wire  [3:0]                          dmi_iccm_cmd_id;
 wire  [2:0]                          dmi_iccm_cmd_data_size;
 wire  [1:0]                          dmi_iccm_cmd_prot;
 wire                                 dmi_iccm_cmd_accept;

 wire                                 dmi_iccm_wr_valid;
 wire                                 dmi_iccm_wr_last;
 wire  [`ICCM_DMI_DATA_WIDTH/8-1:0]   dmi_iccm_wr_mask;
 wire  [`ICCM_DMI_DATA_RANGE]         dmi_iccm_wr_data;
 wire                                 dmi_iccm_wr_accept;

 wire                                 dmi_iccm_rd_valid;
 wire                                 dmi_iccm_rd_err;
 wire                                 dmi_iccm_rd_excl_ok;
 wire  [`ICCM_DMI_DATA_RANGE]         dmi_iccm_rd_data;
 wire                                 dmi_iccm_rd_last;
 wire                                 dmi_iccm_rd_accept;

 wire                                 dmi_iccm_wr_done;
 wire                                 dmi_iccm_wr_excl_okay;
 wire                                 dmi_iccm_wr_err;
 wire                                 dmi_iccm_wr_resp_accept;


wire                         ifu_fch_vec;

wire                         ifu_cmd_valid;
wire [3:0]                   ifu_cmd_cache;
wire [`IC_WRD_RANGE]         ifu_cmd_burst_size;
wire                         ifu_cmd_read;
wire                         ifu_cmd_aux;
wire                         ifu_cmd_accept;
wire [`ADDR_RANGE]           ifu_cmd_addr;
wire                         ifu_cmd_excl;
wire                         ifu_cmd_wrap;
wire [5:0]                   ifu_cmd_atomic;
wire [2:0]                   ifu_cmd_data_size;
wire [1:0]                   ifu_cmd_prot;

wire                         ifu_rd_valid;
wire                         ifu_rd_err;
wire                         ifu_rd_excl_ok;
wire                         ifu_rd_last;
wire                         ifu_rd_accept;
wire  [31:0]                 ifu_rd_data;

wire                         lsq_mem_cmd_valid;
wire  [3:0]                  lsq_mem_cmd_cache;
wire                         lsq_mem_cmd_burst_size;
wire                         lsq_mem_cmd_read;
wire                         lsq_mem_cmd_aux;
wire                         lsq_mem_cmd_accept;
wire  [`ADDR_RANGE]          lsq_mem_cmd_addr;
wire                         lsq_mem_cmd_excl;
wire  [5:0]                  lsq_mem_cmd_atomic;
wire  [2:0]                  lsq_mem_cmd_data_size;
wire  [1:0]                  lsq_mem_cmd_prot;

wire                         lsq_mem_wr_valid;
wire                         lsq_mem_wr_last;
wire                         lsq_mem_wr_accept;
wire  [3:0]                  lsq_mem_wr_mask;
wire  [31:0]                 lsq_mem_wr_data;

wire                         lsq_mem_rd_valid;
wire                         lsq_mem_rd_err;
wire                         lsq_mem_rd_excl_ok;
wire                         lsq_mem_rd_last;
wire                         lsq_mem_rd_accept;
wire  [31:0]                 lsq_mem_rd_data;

wire                         lsq_mem_wr_done;
wire                         lsq_mem_wr_excl_okay;
wire                         lsq_mem_wr_err;
wire                         lsq_mem_wr_resp_accept;


wire                         lsq_per_cmd_valid;
wire [3:0]                   lsq_per_cmd_cache;
wire                         lsq_per_cmd_burst_size;
wire                         lsq_per_cmd_read;
wire                         lsq_per_cmd_aux;
wire                         lsq_per_cmd_accept;
wire [`ADDR_RANGE]           lsq_per_cmd_addr;
wire                         lsq_per_cmd_excl;
wire [5:0]                   lsq_per_cmd_atomic;
wire [2:0]                   lsq_per_cmd_data_size;
wire [1:0]                   lsq_per_cmd_prot;

wire                         lsq_per_wr_valid;
wire                         lsq_per_wr_last;
wire                         lsq_per_wr_accept;
wire [3:0]                   lsq_per_wr_mask;
wire [31:0]                  lsq_per_wr_data;

wire                         lsq_per_rd_valid;
wire                         lsq_per_rd_err;
wire                         lsq_per_rd_excl_ok;
wire                         lsq_per_rd_last;
wire                         lsq_per_rd_accept;
wire [31:0]                  lsq_per_rd_data;

wire                         lsq_per_wr_done;
wire                         lsq_per_wr_excl_okay;
wire                         lsq_per_wr_err;
wire                         lsq_per_wr_resp_accept;

wire                              dmi_dccm_cmd_valid;
wire  [3:0]                       dmi_dccm_cmd_cache;
wire                              dmi_dccm_cmd_burst_size;
wire                              dmi_dccm_cmd_prio;
wire                              dmi_dccm_cmd_read;
wire  [`ADDR_RANGE]               dmi_dccm_cmd_addr;
wire                              dmi_dccm_cmd_excl;
wire  [3:0]                       dmi_dccm_cmd_id;
wire  [2:0]                       dmi_dccm_cmd_data_size;
wire  [1:0]                       dmi_dccm_cmd_prot;
wire                              dmi_dccm_cmd_accept;

wire                              dmi_dccm_wr_valid;
wire                              dmi_dccm_wr_last;
wire  [`DCCM_MEM_MASK_WIDTH-1:0]  dmi_dccm_wr_mask;
wire  [`DCCM_DMI_DATA_RANGE]      dmi_dccm_wr_data;
wire                              dmi_dccm_wr_accept;

wire                              dmi_dccm_rd_valid;
wire                              dmi_dccm_rd_err;
wire                              dmi_dccm_rd_excl_ok;
wire  [`DCCM_DMI_DATA_RANGE]      dmi_dccm_rd_data;
wire                              dmi_dccm_rd_last;
wire                              dmi_dccm_rd_accept;

wire                              dmi_dccm_wr_done;
wire                              dmi_dccm_wr_excl_okay;
wire                              dmi_dccm_wr_err;
wire                              dmi_dccm_wr_resp_accept;

wire                              dmi_mmio_cmd_valid;
wire  [3:0]                       dmi_mmio_cmd_cache;
wire                              dmi_mmio_cmd_burst_size;
wire                              dmi_mmio_cmd_prio;
wire                              dmi_mmio_cmd_read;
wire  [`ADDR_RANGE]               dmi_mmio_cmd_addr;
wire                              dmi_mmio_cmd_excl;
wire  [2:0]                       dmi_mmio_cmd_data_size;
wire  [1:0]                       dmi_mmio_cmd_prot;
wire                              dmi_mmio_cmd_accept;

wire                              dmi_mmio_wr_valid;
wire                              dmi_mmio_wr_last;
wire  [3:0]                       dmi_mmio_wr_mask;
wire  [`DATA_RANGE]               dmi_mmio_wr_data;
wire                              dmi_mmio_wr_accept;

wire                              dmi_mmio_rd_valid;
wire                              dmi_mmio_rd_err;
wire                              dmi_mmio_rd_excl_ok;
wire  [`DATA_RANGE]               dmi_mmio_rd_data;
wire                              dmi_mmio_rd_last;
wire                              dmi_mmio_rd_accept;

wire                              dmi_mmio_wr_done;
wire                              dmi_mmio_wr_excl_okay;
wire                              dmi_mmio_wr_err;
wire                              dmi_mmio_wr_resp_accept;


wire                         lsq_mmio_cmd_valid;
wire  [3:0]                  lsq_mmio_cmd_cache;
wire                         lsq_mmio_cmd_burst_size;
wire                         lsq_mmio_cmd_read;
wire                         lsq_mmio_cmd_aux;
wire                         lsq_mmio_cmd_accept;
wire  [`ADDR_RANGE]          lsq_mmio_cmd_addr;
wire                         lsq_mmio_cmd_excl;
wire  [5:0]                  lsq_mmio_cmd_atomic;
wire  [2:0]                  lsq_mmio_cmd_data_size;
wire  [1:0]                  lsq_mmio_cmd_prot;

wire                         lsq_mmio_wr_valid;
wire                         lsq_mmio_wr_last;
wire                         lsq_mmio_wr_accept;
wire  [3:0]                  lsq_mmio_wr_mask;
wire  [`DATA_RANGE]          lsq_mmio_wr_data;

wire                         lsq_mmio_rd_valid;
wire                         lsq_mmio_rd_err;
wire                         lsq_mmio_rd_excl_ok;
wire                         lsq_mmio_rd_last;
wire                         lsq_mmio_rd_accept;
wire  [`DATA_RANGE]          lsq_mmio_rd_data;

wire                         lsq_mmio_wr_done;
wire                         lsq_mmio_wr_excl_okay;
wire                         lsq_mmio_wr_err;
wire                         lsq_mmio_wr_resp_accept;


wire                         biu_idle;
wire                         biu_cbu_idle;
wire                         biu_dbu_per_idle;
wire                         biu_iccm_dmi_idle;
wire                         biu_dccm_dmi_idle;
wire                         biu_mmio_idle;
wire                         biu_mmio_dmi_idle;

wire [`DATA_RANGE]           trig_csr_rdata;
wire                         trig_csr_illegal;
wire                         trig_csr_unimpl;
wire                         trig_csr_serial_sr;
wire                         trig_csr_strict_sr;

wire [1:0]                   csr_trig_sel_ctl;
wire [11:0]                  csr_trig_sel_addr;

wire                         csr_trig_write;
wire [11:0]                  csr_trig_waddr;
wire [`DATA_RANGE]           csr_trig_wdata;
wire                         ifu_inst_break;
wire                         ifu_inst_trap;
wire                         x2_inst_break;
wire                         x2_inst_trap;

wire                         x1_inst_cg0;
wire [`PC_RANGE]             x2_pc;
wire                         x2_inst_size;

wire                         dmp_addr_trig_trap;
wire                         dmp_addr_trig_break;
wire                         dmp_ld_data_trig_trap;
wire                         dmp_ld_data_trig_break;
wire                         dmp_st_data_trig_trap;
wire                         dmp_st_data_trig_break;
wire                         ext_trig_trap;
wire                         ext_trig_break;

wire                         dmp_x2_valid;
wire [1:0]                   lsq_rb_size;
wire                         dmp_x2_word_r;
wire                         dmp_x2_half_r;


wire [`INST_RANGE]           x2_inst;

wire [`DATA_RANGE]           mstatus_r;
wire [5:0]                   mcause_r;
wire                         sr_aux_write;
wire [`DATA_RANGE]           sr_aux_wdata;             //  (WA) Aux write data

wire                         sr_aux_ren;               //  (X3) Aux region select
wire [11:0]                  sr_aux_raddr;             //  (X3) Aux region addr
wire                         sr_aux_wen;               //  (WA) Aux region select
wire [11:0]                  sr_aux_waddr;             //  (WA) Aux write addr

wire [`DATA_RANGE]           sr_aux_rdata;               //  (X3) LR read data
wire                         sr_aux_illegal;             //  (X3) SR/LR illegal

////////// wire signals (core state) ///////////////////////////////////////
//
wire [`PC_RANGE]             sr_ar_pc;
wire [`DATA_RANGE]           sr_mstatus;
wire                         sr_db_active;
wire [23:0]                  sr_core_state;           // core state to be saved
wire                         mpy_busy;
wire                         core_rf_busy;
wire                         exu_busy;


wire [`DATA_RANGE]           pmp_csr_rdata;
wire                         pmp_csr_illegal;
wire                         pmp_csr_unimpl;
wire                         pmp_csr_serial_sr;
wire                         pmp_csr_strict_sr;

wire [1:0]                   csr_pmp_sel_ctl;
wire [11:0]                  csr_pmp_sel_addr;

wire                         csr_pmp_write;
wire [11:0]                  csr_pmp_waddr;
wire [`DATA_RANGE]           csr_pmp_wdata;



wire [`IFU_ADDR_RANGE]       ifu_pmp_addr0;
wire [`IFU_ADDR_RANGE]       pmp_viol_addr;

wire                         ipmp_hit0;
wire [5:0]                   ipmp_perm0;

wire                         dpmp_hit;
wire [5:0]                   dpmp_perm;

wire [`ADDR_RANGE]           dmp_x2_addr1_r;
wire                         dmp_x2_bank_cross_r;
wire                         cross_region;

wire [`DATA_RANGE]           pma_csr_rdata;
wire                         pma_csr_illegal;
wire                         pma_csr_unimpl;
wire                         pma_csr_serial_sr;
wire                         pma_csr_strict_sr;

wire [1:0]                   csr_pma_sel_ctl;
wire [11:0]                  csr_pma_sel_addr;

wire                         csr_pma_write;
wire [11:0]                  csr_pma_waddr;
wire [`DATA_RANGE]           csr_pma_wdata;


wire [`IFU_ADDR_RANGE]       ifu_pma_addr0;
wire [2:0]                   f1_mem_target;
wire                         fetch_iccm_hole;

wire [3:0]                   ipma_attr0;

wire [5:0]                   dpma_attr;
wire [`DMP_TARGET_RANGE]     dmp_x2_target_r;
wire                         dmp_x2_ccm_hole_r;

wire [`DATA_RANGE]           sfty_csr_rdata;
wire                         sfty_csr_illegal;
wire                         sfty_csr_unimpl;
wire                         sfty_csr_serial_sr;
wire                         sfty_csr_strict_sr;

wire [1:0]                   csr_sfty_sel_ctl;
wire [11:0]                  csr_sfty_sel_addr;

wire                         csr_sfty_write;
wire [11:0]                  csr_sfty_waddr;
wire [`DATA_RANGE]           csr_sfty_wdata;

wire [`DATA_RANGE]           hpm_csr_rdata;
wire                         hpm_csr_illegal;
wire                         hpm_csr_unimpl;
wire                         hpm_csr_serial_sr;
wire                         hpm_csr_strict_sr;

wire [1:0]                   csr_hpm_sel_ctl;
wire [11:0]                  csr_hpm_sel_addr;

wire                         csr_hpm_write;
wire [11:0]                  csr_hpm_waddr;
wire [`DATA_RANGE]           csr_hpm_wdata;
wire                         csr_hpm_range;

//ISA
wire                         csr_x1_read;
wire                         csr_x1_write;
wire                         csr_x2_pass;
wire                         csr_x2_wen;
wire                         x1_raw_hazard;
wire                         x1_waw_hazard;
wire                         csr_flush_r;
wire                         alu_x2_stall;
wire                         mpy_x3_stall;
wire                         soft_reset_x2_stall;
wire                         cp_flush;
wire                         uop_busy_del;

wire                         db_active_r;

wire [`CSR_CTL_RANGE]        x1_csr_ctl;

wire                         hpm_bissue;
wire                         hpm_bicmstall;
wire                         hpm_bifsync;
wire                         hpm_bdfsync;
wire                         hpm_icm;

//IFU
wire                         arcv_macache_op_r;

//EXU
wire                         trap_x2_valid;
wire                         take_int;
wire                         debug_mode_r;
wire                         spc_x2_wfi;          
wire                         spc_x2_ecall;  
wire [`BR_CTL_RANGE]         x1_br_ctl;
wire                         br_x2_taken_r;
wire                         irq_enable;    
wire                         x1_stall;
wire                         spc_x2_stall;
wire                         trap_return;
wire                         halt_restart_r;

wire [`CNT_CTRL_RANGE]       mcounteren_r;         
wire [`CNT_CTRL_RANGE]       mcountinhibit_r;   


wire [`DATA_RANGE]           iccm_csr_rdata;
wire                         iccm_csr_illegal;
wire                         iccm_csr_unimpl;
wire                         iccm_csr_serial_sr;
wire                         iccm_csr_strict_sr;

wire [1:0]                   csr_iccm_sel_ctl;
wire [7:0]                   csr_iccm_sel_addr;

wire                         csr_iccm_write;
wire [7:0]                   csr_iccm_waddr;
wire [`DATA_RANGE]           csr_iccm_wdata;

wire [11:0]                  iccm0_base;
wire                         iccm0_disable;

wire [`DATA_RANGE]           dmp_csr_rdata;
wire                         dmp_csr_illegal;
wire                         dmp_csr_unimpl;
wire                         dmp_csr_serial_sr;
wire                         dmp_csr_strict_sr;

wire [1:0]                   csr_dmp_sel_ctl;
wire [7:0]                   csr_dmp_sel_addr;

wire                         csr_dmp_write;
wire [7:0]                   csr_dmp_waddr;
wire [`DATA_RANGE]           csr_dmp_wdata;


wire [`ARCV_MC_CTL_RANGE]    arcv_mcache_ctl;
wire [`ARCV_MC_OP_RANGE]     arcv_mcache_op;
wire [`ARCV_MC_ADDR_RANGE]   arcv_mcache_addr;
wire [`ARCV_MC_LN_RANGE]     arcv_mcache_lines;
wire [`DATA_RANGE]           arcv_mcache_data;
wire                         arcv_icache_op_init;

wire                         arcv_icache_op_done;
wire [`DATA_RANGE]           arcv_icache_data;
wire                         arcv_icache_op_in_progress;
wire                         ic_tag_ecc_excpn;
wire                         ic_data_ecc_excpn;
wire                         ic_tag_ecc_wr  ;
wire  [`IC_TAG_ECC_RANGE]    ic_tag_ecc_out ;
wire                         ic_data_ecc_wr ;
wire  [`IC_DATA_ECC_RANGE]   ic_data_ecc_out;


wire                         dmp_hpm_dmpreplay;
wire                         dmp_hpm_bdmplsq;
wire                         dmp_hpm_bdmpcwb;

wire                         dmp_x2_store_r;
wire                         dmp_x2_lr_r;
wire                         dmp_x2_sc_r;
wire                         dmp_x2_amo_r;

wire [1:0]                   db_mem_op_1h;
wire [`DATA_RANGE]           db_addr;
wire [`DATA_RANGE]           db_wdata;

wire                         spc_fence_i_inv_req;   // Invalidate request to IFU
wire                         spc_fence_i_inv_ack;   // Acknowledgement that Invalidation is complete

wire                         ras_ibp_mmio_cmd_valid;
wire  [3:0]                  ras_ibp_mmio_cmd_cache;
wire                         ras_ibp_mmio_cmd_burst_size;
wire                         ras_ibp_mmio_cmd_read;
wire                         ras_ibp_mmio_cmd_aux;
wire                         ras_ibp_mmio_cmd_accept;
wire  [`ADDR_RANGE]          ras_ibp_mmio_cmd_addr;
wire                         ras_ibp_mmio_cmd_excl;
wire  [5:0]                  ras_ibp_mmio_cmd_atomic;
wire  [2:0]                  ras_ibp_mmio_cmd_data_size;
wire  [1:0]                  ras_ibp_mmio_cmd_prot;
wire                         ras_ibp_mmio_wr_valid;
wire                         ras_ibp_mmio_wr_last;
wire                         ras_ibp_mmio_wr_accept;
wire  [3:0]                  ras_ibp_mmio_wr_mask;
wire  [31:0]                 ras_ibp_mmio_wr_data;
wire                         ras_ibp_mmio_rd_valid;
wire                         ras_ibp_mmio_rd_err;
wire                         ras_ibp_mmio_rd_excl_ok;
wire                         ras_ibp_mmio_rd_last;
wire                         ras_ibp_mmio_rd_accept;
wire [31:0]                  ras_ibp_mmio_rd_data;
wire                         ras_ibp_mmio_wr_done;
wire                         ras_ibp_mmio_wr_excl_okay;
wire                         ras_ibp_mmio_wr_err;
wire                         ras_ibp_mmio_wr_resp_accept;


wire [11:0]                  core_mmio_base_r;
wire                         sr_dbg_cache_rst_disable;     // Disabe initialization upon reset
wire                         dmp_uncached_busy;
wire                         dmp_per_busy;
wire                         dmp_st_pending;
  ////////// BIU bus error aggregator ////////////////////////////////////////////////
  //
wire biu_fatal_err_comb;
wire ahb_fatal_err_comb;
wire dbu_per_ahb_fatal_err_comb;
wire iccm_ahb_fatal_err_comb;
wire dccm_ahb_fatal_err_comb;
wire mmio_ahb_fatal_err_comb;

assign biu_fatal_err_comb         = 1'b0
	                              | ahb_fatal_err_comb
                                  | dbu_per_ahb_fatal_err_comb
                                  | iccm_ahb_fatal_err_comb
                                  | dccm_ahb_fatal_err_comb
                                  | mmio_ahb_fatal_err_comb
                                  ;
assign dr_bus_fatal_err = biu_fatal_err_comb ? 2'b10 : 2'b01;

  ////////// BIU bus error sync ////////////////////////////////////////////////
  //
always@(posedge clk_gated or posedge rst_a)
begin: ahb_fatal_err_reg_PROC
  if (rst_a == 1'b1)
  begin
    ahb_fatal_err <= 1'b0;
  end
  else
  begin
    ahb_fatal_err <= ahb_fatal_err_comb;
  end
end
always@(posedge clk_gated or posedge rst_a)
begin: dbu_per_ahb_fatal_err_reg_PROC
  if (rst_a == 1'b1)
  begin
    dbu_per_ahb_fatal_err <= 1'b0;
  end
  else
  begin
    dbu_per_ahb_fatal_err <= dbu_per_ahb_fatal_err_comb;
  end
end
always@(posedge clk_gated or posedge rst_a)
begin: iccm_ahb_fatal_err_reg_PROC
  if (rst_a == 1'b1)
  begin
    iccm_ahb_fatal_err <= 1'b0;
  end
  else
  begin
    iccm_ahb_fatal_err <= iccm_ahb_fatal_err_comb;
  end
end
always@(posedge clk_gated or posedge rst_a)
begin: dccm_ahb_fatal_err_reg_PROC
  if (rst_a == 1'b1)
  begin
    dccm_ahb_fatal_err <= 1'b0;
  end
  else
  begin
    dccm_ahb_fatal_err <= dccm_ahb_fatal_err_comb;
  end
end
always@(posedge clk_gated or posedge rst_a)
begin: mmio_ahb_fatal_err_reg_PROC
  if (rst_a == 1'b1)
  begin
    mmio_ahb_fatal_err <= 1'b0;
  end
  else
  begin
    mmio_ahb_fatal_err <= mmio_ahb_fatal_err_comb;
  end
end


//////////////////////////////////////////////////////////////////////////////
//
// Module instantiation
//
//////////////////////////////////////////////////////////////////////////////

rl_hpm          u_rl_hpm (
  //IFU
  .arcv_mcache_op          (arcv_mcache_op        ),        
  //ISA
  .csr_x1_read             (csr_x1_read           ),
  .csr_x1_write            (csr_x1_write          ),
  .csr_x2_pass             (csr_x2_pass           ),
  .csr_x2_wen              (csr_x2_wen            ),
  .x2_inst                 (x2_inst               ),
  .spc_x2_wfi              (spc_x2_wfi            ),
  .spc_x2_ecall            (spc_x2_ecall          ),
  .x2_valid_r              (x2_valid_r            ),
  .x1_pass                 (x1_pass               ),
  .x1_br_ctl               (x1_br_ctl             ),
  .br_x2_taken_r           (br_x2_taken_r         ),
  .irq_enable              (irq_enable            ),
  .ar_clock_enable_r       (ar_clock_enable_r     ),
  .uop_busy_del            (uop_busy_del          ),
  .db_active_r             (db_active             ),

  .x1_csr_ctl              (x1_csr_ctl            ),

  .hpm_bissue              (hpm_bissue            ),
  .hpm_bicmstall           (hpm_bicmstall         ),
  .hpm_bifsync             (hpm_bifsync           ),
  .hpm_bdfsync             (hpm_bdfsync           ),
  .hpm_icm                 (hpm_icm               ),

  //EXU
  .x1_stall                (x1_stall              ),
  .spc_x2_stall            (spc_x2_stall          ),
  .trap_return             (trap_return           ),
  .halt_restart_r          (halt_restart_r        ),
  .x1_raw_hazard           (x1_raw_hazard         ),
  .x1_waw_hazard           (x1_waw_hazard         ),
  .x1_valid_r              (x1_valid_r            ),
  .csr_flush_r             (csr_flush_r           ),
  .alu_x2_stall            (alu_x2_stall          ),
  .mpy_x3_stall            (mpy_x3_stall          ),
  .soft_reset_x2_stall     (soft_reset_x2_stall   ),
  .cp_flush                (cp_flush              ),

  .debug_mode              (debug_mode            ),
  .trap_x2_valid           (trap_x2_valid         ),
  .take_int                (take_int              ),
  .debug_mode_r            (debug_mode_r          ),
  .sys_halt_r              (sys_halt_r            ),
  .dmp_x2_load_r           (dmp_x2_load_r         ),
  .dmp_x2_store_r          (dmp_x2_store_r        ),
  .dmp_x2_lr_r             (dmp_x2_lr_r           ),
  .dmp_x2_sc_r             (dmp_x2_sc_r           ),
  .dmp_x2_amo_r            (dmp_x2_amo_r          ),

  //DMP
  .dmp_x1_stall            (dmp_x1_stall          ),
  .dmp_x2_stall            (dmp_x2_stall          ),
  .hpm_dmpreplay           (dmp_hpm_dmpreplay     ),
  .hpm_bdmpcwb             (dmp_hpm_bdmpcwb       ),
  .hpm_bdmplsq             (dmp_hpm_bdmplsq       ),

  .hpm_int_overflow_r      (hpm_int_overflow_r    ),
  .instret_ovf             (instret_ovf           ),
  .cycle_ovf               (cycle_ovf             ),
  .time_ovf                (time_ovf              ),

  .mcountinhibit_r         (mcountinhibit_r),
  .mcounteren_r            (mcounteren_r),

  .csr_sel_ctl             (csr_hpm_sel_ctl),
  .csr_sel_addr            (csr_hpm_sel_addr),
  
  .csr_rdata               (hpm_csr_rdata),            
  .csr_illegal             (hpm_csr_illegal),          
  .csr_unimpl              (hpm_csr_unimpl),           
  .csr_serial_sr           (hpm_csr_serial_sr),        
  .csr_strict_sr           (hpm_csr_strict_sr),        
  
  .csr_write               (csr_hpm_write),              
  .csr_waddr               (csr_hpm_waddr),             
  .csr_wdata               (csr_hpm_wdata),            
  .csr_hpm_range           (csr_hpm_range),
  
  .x2_pass                 (x2_pass),              
  .priv_level_r            (priv_level_r),
  .pct_unit_enable         (pct_unit_enable),
  .clk                     (clk_hpm),
  .hpm_int_overflow_rising (hpm_int_overflow_rising),
  .rst_a                   (rst_a)

); // rl_hpm

rl_ifu u_rl_ifu (
  .ifu_issue               (ifu_issue           ),
  .ifu_pc                  (ifu_pc              ),
  .ifu_size                (ifu_size            ),
  .ifu_pd_addr0            (ifu_pd_addr0        ),
  .ifu_pd_addr1            (ifu_pd_addr1        ),
  .ifu_inst                (ifu_inst            ),
  .ifu_fusion              (ifu_fusion          ),
  .ifu_pd_fu               (ifu_pd_fu           ),
  .db_active               (db_active           ),
  .x1_holdup               (x1_holdup           ),
  .hpm_bicmstall           (hpm_bicmstall       ),
  .hpm_icm                 (hpm_icm             ),
  .uop_busy                (uop_busy            ),
  .ifu_trig_trap           (ifu_inst_trap      ),

  .spc_x2_clean            (spc_x2_clean        ),
  .spc_x2_flush            (spc_x2_flush        ),
  .spc_x2_inval            (spc_x2_inval        ),
  .spc_x2_zero             (spc_x2_zero         ),
  .spc_x2_prefetch         (spc_x2_prefetch     ),
  .spc_x2_data             (spc_x2_data         ),
  .icmo_done               (icmo_done           ),
  .halt_req_asserted       (halt_req_asserted   ),
  .kill_ic_op              (kill_ic_op          ),
  .halt_fsm_in_rst         (halt_fsm_in_rst     ),

  .fch_restart             (fch_restart         ),
  .fch_restart_vec         (fch_restart_vec     ),
  .fch_target              (fch_target          ),
  .fch_stop_r              (fch_stop_r          ),

  .br_req_ifu              (br_req_ifu             ),
  .br_restart_pc           (br_restart_pc          ),

  .spc_fence_i_inv_req     (spc_fence_i_inv_req  ),
  .spc_fence_i_inv_ack     (spc_fence_i_inv_ack  ),

  .arcv_mecc_diag_ecc      (arcv_mecc_diag_ecc   ),
  .trap_clear_iccm_resv    (trap_clear_lf        ),
  .iccm_ecc_excpn          (iccm_ecc_excpn       ),
  .iccm_dmp_ecc_err        (iccm_dmp_ecc_err     ),
  .iccm_ecc_wr             (iccm_ecc_wr          ),
  .iccm0_ecc_out           (iccm0_ecc_out        ),
  .arcv_mcache_ctl         (arcv_mcache_ctl      ),
  .arcv_mcache_op          (arcv_mcache_op       ),
  .arcv_mcache_addr        (arcv_mcache_addr     ),
  .arcv_mcache_lines       (arcv_mcache_lines    ),
  .arcv_mcache_data        (arcv_mcache_data     ),
  .arcv_icache_op_init     (arcv_icache_op_init  ),

  .arcv_icache_op_done     (arcv_icache_op_done  ),
  .arcv_icache_data        (arcv_icache_data     ),
  .arcv_icache_op_in_progress (arcv_icache_op_in_progress),
  .ic_tag_ecc_excpn        (ic_tag_ecc_excpn     ),
  .ic_data_ecc_excpn       (ic_data_ecc_excpn    ),
  .ic_tag_ecc_wr           (ic_tag_ecc_wr        ),
  .ic_tag_ecc_out          (ic_tag_ecc_out       ),
  .ic_data_ecc_wr          (ic_data_ecc_wr       ),
  .ic_data_ecc_out         (ic_data_ecc_out      ),
  .ifu_pmp_addr0           (ifu_pmp_addr0       ),
  .pmp_viol_addr           (pmp_viol_addr       ),
  
  .ipmp_hit0               (ipmp_hit0           ),
  .ipmp_perm0              (ipmp_perm0          ),
  .priv_level              (priv_level_r        ),
  
  .ifu_pma_addr0           (ifu_pma_addr0       ),
  .f1_mem_target           (f1_mem_target       ),
  .fetch_iccm_hole         (fetch_iccm_hole     ),

  .ipma_attr0              (ipma_attr0          ),
  .ifu_exception           (ifu_exception       ),

  .ifu_fch_vec              (ifu_fch_vec           ),
  .ifu_cmd_valid           (ifu_cmd_valid       ),
  .ifu_cmd_cache           (ifu_cmd_cache       ),
  .ifu_cmd_burst_size      (ifu_cmd_burst_size  ),
  .ifu_cmd_read            (ifu_cmd_read        ),
  .ifu_cmd_aux             (ifu_cmd_aux         ),
  .ifu_cmd_accept          (ifu_cmd_accept      ),
  .ifu_cmd_addr            (ifu_cmd_addr        ),
  .ifu_cmd_excl            (ifu_cmd_excl        ),
  .ifu_cmd_wrap            (ifu_cmd_wrap        ),
  .ifu_cmd_atomic          (ifu_cmd_atomic      ),
  .ifu_cmd_data_size       (ifu_cmd_data_size   ),
  .ifu_cmd_prot            (ifu_cmd_prot        ),

  .ifu_rd_valid            (ifu_rd_valid        ),
  .ifu_rd_err              (ifu_rd_err          ),
  .ifu_rd_excl_ok          (ifu_rd_excl_ok      ),
  .ifu_rd_last             (ifu_rd_last         ),
  .ifu_rd_accept           (ifu_rd_accept       ),
  .ifu_rd_data             (ifu_rd_data         ),

   .ic_tag_ecc_addr_err     ( ic_tag_ecc_addr_err     ),
   .ic_tag_ecc_sb_err       ( ic_tag_ecc_sb_err       ),
   .ic_tag_ecc_db_err       ( ic_tag_ecc_db_err       ),
   .ic_tag_ecc_syndrome     ( ic_tag_ecc_syndrome     ),
   .ic_tag_ecc_addr         ( ic_tag_ecc_addr         ),

   .ic_data_ecc_addr_err    ( ic_data_ecc_addr_err    ),
   .ic_data_ecc_sb_err      ( ic_data_ecc_sb_err      ),
   .ic_data_ecc_db_err      ( ic_data_ecc_db_err      ),
   .ic_data_ecc_syndrome    ( ic_data_ecc_syndrome    ),
   .ic_data_ecc_addr        ( ic_data_ecc_addr        ),


  .iccm0_ecc_addr_err (iccm0_ecc_addr_err),
  .iccm0_ecc_sb_err   (iccm0_ecc_sb_err  ),
  .iccm0_ecc_db_err   (iccm0_ecc_db_err  ),
  .iccm0_ecc_syndrome (iccm0_ecc_syndrome),
  .iccm0_ecc_addr     (iccm0_ecc_addr    ),
  .csr_sel_ctl             (csr_iccm_sel_ctl),
  .csr_sel_addr            (csr_iccm_sel_addr),

  .csr_rdata               (iccm_csr_rdata),
  .csr_illegal             (iccm_csr_illegal),
  .csr_unimpl              (iccm_csr_unimpl),
  .csr_serial_sr           (iccm_csr_serial_sr),
  .csr_strict_sr           (iccm_csr_strict_sr),

  .csr_write               (csr_iccm_write),
  .csr_waddr               (csr_iccm_waddr),
  .csr_wdata               (csr_iccm_wdata),

  .iccm0_base              (iccm0_base),
  .iccm0_disable           (iccm0_disable),

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

 .dmi_iccm_cmd_valid       (dmi_iccm_cmd_valid     ),
 .dmi_iccm_cmd_prio        (dmi_iccm_cmd_prio      ),
 .dmi_iccm_cmd_cache       (dmi_iccm_cmd_cache     ),
 .dmi_iccm_cmd_burst_size  (dmi_iccm_cmd_burst_size),
 .dmi_iccm_cmd_read        (dmi_iccm_cmd_read      ),
 .dmi_iccm_cmd_addr        (dmi_iccm_cmd_addr      ),
 .dmi_iccm_cmd_excl        (dmi_iccm_cmd_excl      ),
 .dmi_iccm_cmd_id          (dmi_iccm_cmd_id        ),
 .dmi_iccm_cmd_data_size   (dmi_iccm_cmd_data_size ),
 .dmi_iccm_cmd_prot        (dmi_iccm_cmd_prot      ),
 .dmi_iccm_cmd_accept      (dmi_iccm_cmd_accept    ),

 .dmi_iccm_wr_valid        (dmi_iccm_wr_valid      ),
 .dmi_iccm_wr_last         (dmi_iccm_wr_last       ),
 .dmi_iccm_wr_mask         (dmi_iccm_wr_mask       ),
 .dmi_iccm_wr_data         (dmi_iccm_wr_data       ),
 .dmi_iccm_wr_accept       (dmi_iccm_wr_accept     ),

 .dmi_iccm_rd_valid        (dmi_iccm_rd_valid      ),
 .dmi_iccm_rd_err          (dmi_iccm_rd_err        ),
 .dmi_iccm_rd_excl_ok      (dmi_iccm_rd_excl_ok    ),
 .dmi_iccm_rd_data         (dmi_iccm_rd_data       ),
 .dmi_iccm_rd_last         (dmi_iccm_rd_last       ),
 .dmi_iccm_rd_accept       (dmi_iccm_rd_accept     ),

 .dmi_iccm_wr_done         (dmi_iccm_wr_done       ),
 .dmi_iccm_wr_excl_okay    (dmi_iccm_wr_excl_okay  ),
 .dmi_iccm_wr_err          (dmi_iccm_wr_err        ),
 .dmi_iccm_wr_resp_accept  (dmi_iccm_wr_resp_accept),

  .iccm0_clk          (iccm0_clk      ),
  .iccm0_din          (iccm0_din      ),
  .iccm0_addr         (iccm0_addr     ),
  .iccm0_cs           (iccm0_cs       ),
  .iccm0_we           (iccm0_we       ),
  .iccm0_wem          (iccm0_wem      ),
  .iccm0_dout         (iccm0_dout     ),

  ////////// SRAM IC TAG interface ////////////////////////////////////////////////
  .ic_tag_mem_clk	(ic_tag_mem_clk),
  .ic_tag_mem_din	(ic_tag_mem_din),
  .ic_tag_mem_addr	(ic_tag_mem_addr),
  .ic_tag_mem_cs	(ic_tag_mem_cs),
  .ic_tag_mem_we	(ic_tag_mem_we),
  .ic_tag_mem_wem	(ic_tag_mem_wem),
  .ic_tag_mem_dout	(ic_tag_mem_dout),
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  .ic_data_mem_clk	(ic_data_mem_clk),
  .ic_data_mem_din	(ic_data_mem_din),
  .ic_data_mem_addr	(ic_data_mem_addr),
  .ic_data_mem_cs	(ic_data_mem_cs),
  .ic_data_mem_we	(ic_data_mem_we),
  .ic_data_mem_wem	(ic_data_mem_wem),
  .ic_data_mem_dout	(ic_data_mem_dout),

  .ifu_idle_r              (ifu_idle_r          ),
  .ic_idle_ack             (ic_idle_ack         ),


  .clk                     (clk_gated           ),
//  .ar_clock_enable_r       (ar_clock_enable_r   ),
  .rst_init_disable_r      (rst_init_disable_r  ),
  .sr_dbg_cache_rst_disable(sr_dbg_cache_rst_disable),
  .rst_a                   (rst_a               )
);

rl_exu u_rl_exu (
  .clk                     (clk                    ),
  .clk_gated               (clk_gated              ),
`ifdef SIMULATION
  .mip_r                   (mip_r),
  .mie_r                   (mie_r),
`endif
  .core_mmio_base_in       (core_mmio_base_in      ),
  .core_mmio_base_r        (core_mmio_base_r       ),
  .clk_mpy                 (clk_mpy                ),
  .rst_a                   (rst_a                  ),


  .reset_pc_in             (reset_pc_in           ),
  .wid_rwiddeleg           (wid_rwiddeleg         ),
  .wid_rlwid               (wid_rlwid             ),
  .wid                     (wid                   ),

  .rnmi_synch_r            (rnmi_synch_r          ),
  .miselect_r              (miselect_r            ),
  .mireg_clint             (mireg_clint           ),
  .mireg_clint_wen         (mireg_clint_wen       ),

  .safety_iso_enb_synch_r  (safety_iso_enb_synch_r),
  .dr_safety_iso_err       (dr_safety_iso_err     ),

  .gb_sys_run_req_r        (gb_sys_run_req_r       ),
  .gb_sys_halt_req_r       (gb_sys_halt_req_r      ),
  .gb_sys_run_ack_r        (gb_sys_run_ack_r       ),
  .gb_sys_halt_ack_r       (gb_sys_halt_ack_r      ),

  .db_clock_enable_nxt     (db_clock_enable_nxt    ),
  .ar_clock_enable_r       (ar_clock_enable_r   ),
  .mpy_x1_valid            (mpy_x1_valid           ),
  .mpy_x2_valid            (mpy_x2_valid           ),
  .mpy_x3_valid_r          (mpy_x3_valid_r         ),

  .ifu_issue               (ifu_issue              ),
  .ifu_pc                  (ifu_pc                 ),
  .ifu_size                (ifu_size               ),
  .ifu_pd_addr0            (ifu_pd_addr0           ),
  .ifu_pd_addr1            (ifu_pd_addr1           ),
  .ifu_inst                (ifu_inst               ),
  .ifu_fusion              (ifu_fusion             ),
  .ifu_exception           (ifu_exception          ),

  .spc_x2_clean            (spc_x2_clean           ),
  .spc_x2_flush            (spc_x2_flush           ),
  .spc_x2_inval            (spc_x2_inval           ),
  .spc_x2_zero             (spc_x2_zero            ),
  .spc_x2_prefetch         (spc_x2_prefetch        ),
  .spc_x2_data             (spc_x2_data            ),
  .icmo_done               (icmo_done              ),
  .halt_req_asserted       (halt_req_asserted      ),
  .kill_ic_op              (kill_ic_op             ),
  .halt_fsm_in_rst         (halt_fsm_in_rst        ),

  .x1_holdup               (x1_holdup              ),
  .uop_busy                (uop_busy               ),

  .x1_pass                 (x1_pass                ),
  .x1_dmp_ctl              (x1_dmp_ctl             ),
  .x1_valid_r              (x1_valid_r             ),
  .lsq_empty               (lsq_empty              ),
  .x1_src0_data            (x1_src0_data           ),
  .x1_src1_data            (x1_src1_data           ),
  .x1_src2_data            (x1_src2_data           ),
  .x1_dst_id               (x1_dst_id              ),
  .dmp_x1_stall            (dmp_x1_stall           ),

  .db_mem_op_1h            (db_mem_op_1h           ),
  .db_limm                 (db_addr                ),
  .db_data                 (db_wdata               ),

  .x2_valid_r              (x2_valid_r             ),
  .x2_pass                 (x2_pass                ),
  .x2_enable               (x2_enable              ),
  .dmp_x2_stall            (dmp_x2_stall           ),
  .dmp_x2_replay           (dmp_x2_replay          ),

  .dmp_x2_mva_stall_r      (dmp_x2_mva_stall_r     ),
  .dmp_x2_data             (dmp_x2_data            ),
  .dmp_x2_addr             (dmp_x2_addr_r          ),
  .dmp_x2_load             (dmp_x2_load_r          ),
  .dmp_x2_grad             (dmp_x2_grad            ),
  .dmp_x2_dst_id_r         (dmp_x2_dst_id_r        ),
  .dmp_x2_dst_id_valid     (dmp_x2_dst_id_valid    ),
  .dmp_x2_retire_req       (dmp_retire_req         ),
  .dmp_x2_retire_dst_id    (dmp_retire_dst_id      ),
  .dmp_rb_req_r            (dmp_rb_req_r           ),
  .dmp_rb_post_commit_r    (dmp_rb_post_commit     ),
  .dmp_rb_retire_err_r     (dmp_rb_retire_err      ),
  .dmp_rb_dst_id           (dmp_rb_dst_id          ),
  .rb_dmp_ack              (rb_dmp_ack             ),
  .dmp_exception_sync      (dmp_exception_sync     ),
  .dmp_exception_async     (dmp_exception_async    ),
  .trap_clear_lf           (trap_clear_lf          ),

  .dmp_lsq0_dst_valid  (dmp_lsq0_dst_valid   ),
  .dmp_lsq0_dst_id     (dmp_lsq0_dst_id      ),
  .dmp_lsq1_dst_valid  (dmp_lsq1_dst_valid   ),
  .dmp_lsq1_dst_id     (dmp_lsq1_dst_id      ),

  .x3_flush_r              (x3_flush_r             ),

  .fch_restart             (fch_restart            ),
  .fch_restart_vec         (fch_restart_vec        ),
  .fch_target              (fch_target             ),
  .fch_stop_r              (fch_stop_r             ),

  .br_req_ifu              (br_req_ifu             ),
  .br_restart_pc           (br_restart_pc          ),

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
  .ifu_inst_break           (ifu_inst_break          ),
  .x2_inst_trap             (x2_inst_trap            ),
  .x2_inst_break            (x2_inst_break           ),
  .x1_inst_cg0              (x1_inst_cg0             ),
  .dmp_addr_trig_break      (dmp_addr_trig_break     ),
  .dmp_ld_data_trig_break   (dmp_ld_data_trig_break  ),
  .dmp_st_data_trig_break   (dmp_st_data_trig_break  ),
  .ext_trig_break           (ext_trig_break          ),
  .ext_trig_trap            (ext_trig_trap           ),
  .x2_pc                    (x2_pc                   ),
  .x2_inst_size             (x2_inst_size            ),
  .x2_inst                  (x2_inst                 ),


  .csr_pmp_sel_ctl         (csr_pmp_sel_ctl        ),
  .csr_pmp_sel_addr        (csr_pmp_sel_addr       ),

  .pmp_csr_rdata           (pmp_csr_rdata          ),
  .pmp_csr_illegal         (pmp_csr_illegal        ),
  .pmp_csr_unimpl          (pmp_csr_unimpl         ),
  .pmp_csr_serial_sr       (pmp_csr_serial_sr      ),
  .pmp_csr_strict_sr       (pmp_csr_strict_sr      ),

  .csr_pmp_write           (csr_pmp_write          ),
  .csr_pmp_waddr           (csr_pmp_waddr          ),
  .csr_pmp_wdata           (csr_pmp_wdata          ),
  .pmp_viol_addr           (pmp_viol_addr          ),
  .mstatus_r               (mstatus_r              ),
  .mcause_r                (mcause_r               ),
  .soft_reset_prepare      (soft_reset_prepare     ),
  .priv_level_r            (priv_level_r           ),

  .csr_pma_sel_ctl         (csr_pma_sel_ctl        ),
  .csr_pma_sel_addr        (csr_pma_sel_addr       ),

  .pma_csr_rdata           (pma_csr_rdata          ),
  .pma_csr_illegal         (pma_csr_illegal        ),
  .pma_csr_unimpl          (pma_csr_unimpl         ),
  .pma_csr_serial_sr       (pma_csr_serial_sr      ),
  .pma_csr_strict_sr       (pma_csr_strict_sr      ),

  .csr_pma_write           (csr_pma_write          ),
  .csr_pma_waddr           (csr_pma_waddr          ),
  .csr_pma_wdata           (csr_pma_wdata          ),

  .csr_hpm_sel_ctl        (csr_hpm_sel_ctl        ),
  .csr_hpm_sel_addr       (csr_hpm_sel_addr       ),

  .hpm_csr_rdata          (hpm_csr_rdata          ),
  .hpm_csr_illegal        (hpm_csr_illegal        ),
  .hpm_csr_unimpl         (hpm_csr_unimpl         ),
  .hpm_csr_serial_sr      (hpm_csr_serial_sr      ),
  .hpm_csr_strict_sr      (hpm_csr_strict_sr      ),

  .csr_hpm_write          (csr_hpm_write          ),
  .csr_hpm_waddr          (csr_hpm_waddr          ),
  .csr_hpm_wdata          (csr_hpm_wdata          ),
  .csr_hpm_range          (csr_hpm_range          ),

  .mcounteren_r            (mcounteren_r          ),
  .mcountinhibit_r         (mcountinhibit_r       ),
  .instret_ovf             (instret_ovf           ),
  .cycle_ovf               (cycle_ovf             ),
  .hpm_bissue              (hpm_bissue            ),
  .hpm_bifsync             (hpm_bifsync           ),
  .hpm_bdfsync             (hpm_bdfsync           ),

  .csr_iccm_sel_ctl        (csr_iccm_sel_ctl        ),
  .csr_iccm_sel_addr       (csr_iccm_sel_addr       ),

  .iccm_csr_rdata          (iccm_csr_rdata          ),
  .iccm_csr_illegal        (iccm_csr_illegal        ),
  .iccm_csr_unimpl         (iccm_csr_unimpl         ),
  .iccm_csr_serial_sr      (iccm_csr_serial_sr      ),
  .iccm_csr_strict_sr      (iccm_csr_strict_sr      ),

  .csr_iccm_write          (csr_iccm_write          ),
  .csr_iccm_waddr          (csr_iccm_waddr          ),
  .csr_iccm_wdata          (csr_iccm_wdata          ),
  .csr_dmp_sel_ctl        (csr_dmp_sel_ctl        ),
  .csr_dmp_sel_addr       (csr_dmp_sel_addr       ),

  .dmp_csr_rdata          (dmp_csr_rdata          ),
  .dmp_csr_illegal        (dmp_csr_illegal        ),
  .dmp_csr_unimpl         (dmp_csr_unimpl         ),
  .dmp_csr_serial_sr      (dmp_csr_serial_sr      ),
  .dmp_csr_strict_sr      (dmp_csr_strict_sr      ),

  .csr_dmp_write          (csr_dmp_write          ),
  .csr_dmp_waddr          (csr_dmp_waddr          ),
  .csr_dmp_wdata          (csr_dmp_wdata          ),
  .dccm_ecc_excpn          (dccm_ecc_excpn        ),
  .dccm_ecc_wr             (dccm_ecc_wr           ),
  .dccm_ecc_out            (dccm_ecc_out          ),

  .iccm_ecc_excpn          (iccm_ecc_excpn          ),
  .iccm_dmp_ecc_err        (iccm_dmp_ecc_err        ),
  .iccm_ecc_wr             (iccm_ecc_wr             ),
  .iccm0_ecc_out           (iccm0_ecc_out           ),
  .csr_sfty_sel_ctl        (csr_sfty_sel_ctl       ),
  .csr_sfty_sel_addr       (csr_sfty_sel_addr      ),

  .sfty_csr_rdata          (sfty_csr_rdata         ),
  .sfty_csr_illegal        (sfty_csr_illegal       ),
  .sfty_csr_unimpl         (sfty_csr_unimpl        ),
  .sfty_csr_serial_sr      (sfty_csr_serial_sr     ),
  .sfty_csr_strict_sr      (sfty_csr_strict_sr     ),

  .csr_sfty_write          (csr_sfty_write         ),
  .csr_sfty_waddr          (csr_sfty_waddr         ),
  .csr_sfty_wdata          (csr_sfty_wdata         ),

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

  .db_active                 (db_active         ),


  .arcv_mcache_ctl         (arcv_mcache_ctl        ),
  .arcv_mcache_op          (arcv_mcache_op         ),
  .arcv_mcache_addr        (arcv_mcache_addr       ),
  .arcv_mcache_lines       (arcv_mcache_lines      ),
  .arcv_mcache_data        (arcv_mcache_data       ),
  .arcv_icache_op_init     (arcv_icache_op_init    ),

  .arcv_icache_op_done     (arcv_icache_op_done    ),
  .arcv_icache_data        (arcv_icache_data       ),
  .arcv_icache_op_in_progress (arcv_icache_op_in_progress),
  .ic_tag_ecc_excpn        (ic_tag_ecc_excpn       ),
  .ic_data_ecc_excpn       (ic_data_ecc_excpn      ),
  .ic_tag_ecc_wr           (ic_tag_ecc_wr          ),
  .ic_tag_ecc_out          (ic_tag_ecc_out         ),
  .ic_data_ecc_wr          (ic_data_ecc_wr         ),
  .ic_data_ecc_out         (ic_data_ecc_out        ),
  .arcv_mecc_diag_ecc      (arcv_mecc_diag_ecc     ),


  .csr_clint_sel_ctl        (csr_clint_sel_ctl     ),
  .csr_clint_sel_addr       (csr_clint_sel_addr    ),

  .clint_csr_rdata          (clint_csr_rdata       ),
  .clint_csr_illegal        (clint_csr_illegal     ),
  .clint_csr_unimpl         (clint_csr_unimpl      ),
  .clint_csr_serial_sr      (clint_csr_serial_sr   ),
  .clint_csr_strict_sr      (clint_csr_strict_sr   ),

  .csr_clint_write          (csr_clint_write       ),
  .csr_clint_waddr          (csr_clint_waddr       ),
  .csr_clint_wdata          (csr_clint_wdata       ),
  .csr_clint_ren_r          (csr_clint_ren_r       ),
  .mtopi_iid                (mtopi_iid             ),
  .mtvec_mode               (mtvec_mode            ),
  .trap_ack                 (trap_ack              ),

  .irq_id                   (irq_id                ),

  .irq_trap                 (irq_trap              ),

  .dbg_ibp_cmd_valid       (dbg_ibp_cmd_valid),
  .dbg_ibp_cmd_read        (dbg_ibp_cmd_read),
  .dbg_ibp_cmd_addr        (dbg_ibp_cmd_addr),
  .dbg_ibp_cmd_accept      (dbg_ibp_cmd_accept),
  .dbg_ibp_cmd_space       (dbg_ibp_cmd_space),
  .dbg_ibp_rd_valid        (dbg_ibp_rd_valid),
  .dbg_ibp_rd_accept       (dbg_ibp_rd_accept),
  .dbg_ibp_rd_err          (dbg_ibp_rd_err),
  .dbg_ibp_rd_data         (dbg_ibp_rd_data),
  .dbg_ibp_wr_valid        (dbg_ibp_wr_valid),
  .dbg_ibp_wr_accept       (dbg_ibp_wr_accept),
  .dbg_ibp_wr_data         (dbg_ibp_wr_data),
  .dbg_ibp_wr_mask         (dbg_ibp_wr_mask),
  .dbg_ibp_wr_done         (dbg_ibp_wr_done),
  .dbg_ibp_wr_err          (dbg_ibp_wr_err),
  .dbg_ibp_wr_resp_accept  (dbg_ibp_wr_resp_accept),
  .relaxedpriv             (relaxedpriv),
  .mprven_r                (mprven_r),

  .sr_aux_write            (sr_aux_write),
  .sr_aux_wdata            (sr_aux_wdata),
  .sr_aux_ren              (sr_aux_ren),
  .sr_aux_raddr            (sr_aux_raddr),
  .sr_aux_wen              (sr_aux_wen),
  .sr_aux_waddr            (sr_aux_waddr),
  .sr_aux_rdata            (sr_aux_rdata),
  .sr_aux_illegal          (sr_aux_illegal),
  .sr_ar_pc_r              (sr_ar_pc),
  .sr_mstatus              (sr_mstatus),
  .sr_db_active            (sr_db_active),

  .spc_fence_i_inv_req     (spc_fence_i_inv_req    ),
  .spc_fence_i_inv_ack     (spc_fence_i_inv_ack    ),

  .mtime_r                 (mtime_r                ),
  .arcnum                  (arcnum                 ),
  .debug_mode              (debug_mode             ),
  .db_exception            (db_exception           ),


  .dm2arc_halt_on_reset    (dm2arc_halt_on_reset   ),
  .is_dm_rst               (is_dm_rst              ),
  .sys_halt_r              (sys_halt_r             ),
  .sys_sleep_r             (sys_sleep_r            ),
  .critical_error          (critical_error         ),
  .sys_sleep_mode_r        (sys_sleep_mode_r       ),
  .csr_x1_read             (csr_x1_read            ),
  .csr_x1_write            (csr_x1_write           ),
  .csr_x2_pass             (csr_x2_pass            ),
  .csr_x2_wen              (csr_x2_wen             ),
  .trap_x2_valid           (trap_x2_valid          ),
  .take_int                (take_int               ),
  .debug_mode_r            (debug_mode_r           ),
  .spc_x2_wfi              (spc_x2_wfi             ),
  .spc_x2_ecall            (spc_x2_ecall           ),
  .x1_br_ctl               (x1_br_ctl              ),
  .br_x2_taken_r           (br_x2_taken_r          ),
  .irq_enable              (irq_enable             ),
  .x1_stall                (x1_stall               ),
  .spc_x2_stall            (spc_x2_stall           ),
  .trap_return             (trap_return            ),
  .halt_restart_r          (halt_restart_r         ),
  .x1_raw_hazard           (x1_raw_hazard          ),
  .x1_waw_hazard           (x1_waw_hazard          ),
  .x1_csr_ctl              (x1_csr_ctl             ),

  .csr_flush_r             (csr_flush_r            ),
  .alu_x2_stall            (alu_x2_stall           ),
  .mpy_x3_stall            (mpy_x3_stall           ),
  .soft_reset_x2_stall     (soft_reset_x2_stall    ),
  .cp_flush                (cp_flush               ),
  .uop_busy_del            (uop_busy_del           ),
  .mpy_busy                (mpy_busy               ),
  .exu_busy                (exu_busy               ),
  .core_rf_busy            (core_rf_busy           ),
  .ifu_idle_r              (ifu_idle_r             ),
  .dmp_idle_r              (dmp_idle_r             ),
  .biu_idle_r              (biu_idle               )

);


rl_dmp u_rl_dmp (
  .x1_pass                 (x1_pass             ),
  .x1_dmp_ctl              (x1_dmp_ctl          ),
  .x1_valid_r              (x1_valid_r          ),
  .lsq_empty               (lsq_empty           ),
  .x1_src0_data            (x1_src0_data        ),
  .x1_src1_data            (x1_src1_data        ),
  .x1_src2_data            (x1_src2_data        ),
  .x1_dst_id               (x1_dst_id           ),
  .dmp_x1_stall            (dmp_x1_stall        ),

  .db_mem_op_1h            (db_mem_op_1h        ),
  .db_addr                 (db_addr             ),
  .db_wdata                (db_wdata            ),
  .db_exception            (db_exception        ),

  .x2_valid_r              (x2_valid_r          ),
  .x2_pass                 (x2_pass             ),
  .x2_enable               (x2_enable           ),
  .dmp_x2_data             (dmp_x2_data         ),
  .dmp_x2_data_r           (dmp_x2_data_r       ),
  .dmp_x2_addr_r           (dmp_x2_addr_r       ),
  .dmp_x2_load_r           (dmp_x2_load_r       ),
  .dmp_x2_grad             (dmp_x2_grad         ),
  .dmp_x2_dst_id_r         (dmp_x2_dst_id_r     ),
  .dmp_x2_dst_id_valid     (dmp_x2_dst_id_valid ),

  .dmp_retire_req          (dmp_retire_req      ),
  .dmp_retire_dst_id       (dmp_retire_dst_id   ),

  .dmp_rb_req_r            (dmp_rb_req_r        ),
  .dmp_rb_post_commit      (dmp_rb_post_commit  ),
  .dmp_rb_retire_err       (dmp_rb_retire_err   ),
  .dmp_rb_dst_id           (dmp_rb_dst_id       ),
  .x2_dmp_rb_ack           (rb_dmp_ack          ),

  .dmp_x2_stall            (dmp_x2_stall        ),
  .dmp_x2_replay           (dmp_x2_replay       ),

  .priv_level_r            (priv_level_r        ),
  .mstatus_r               (mstatus_r           ),
  .debug_mode              (debug_mode          ),
  .mprven_r                (mprven_r            ),
  .dmp_x2_mva_stall_r      (dmp_x2_mva_stall_r  ),
  .dmp_x2_no_mva           (dmp_x2_valid        ),
  .dmp_addr_trig_trap      (dmp_addr_trig_trap  ),
  .dmp_st_data_trig_trap   (dmp_st_data_trig_trap),
  .dmp_ld_data_trig_trap   (dmp_ld_data_trig_trap),
  .lsq_rb_size             (lsq_rb_size         ),
  .dmp_x2_word_r           (dmp_x2_word_r       ),
  .dmp_x2_half_r           (dmp_x2_half_r       ),
  .dpmp_hit                (dpmp_hit            ),
  .dpmp_perm               (dpmp_perm           ),
  .dmp_x2_addr1_r          (dmp_x2_addr1_r      ),
  .dmp_x2_bank_cross_r     (dmp_x2_bank_cross_r ),
  .cross_region            (cross_region        ),

  .dpma_attr               (dpma_attr           ),
  .dmp_x2_target_r         (dmp_x2_target_r     ),
  .dmp_x2_ccm_hole_r       (dmp_x2_ccm_hole_r   ),


  .dmp_exception_sync      (dmp_exception_sync  ),
  .dmp_exception_async     (dmp_exception_async ),
  .trap_clear_lf           (trap_clear_lf       ),

  .x3_flush_r              (x3_flush_r          ),

  .dmp_lsq0_dst_valid  (dmp_lsq0_dst_valid),
  .dmp_lsq0_dst_id     (dmp_lsq0_dst_id   ),
  .dmp_lsq1_dst_valid  (dmp_lsq1_dst_valid),
  .dmp_lsq1_dst_id     (dmp_lsq1_dst_id   ),

  .dccm_even_clk           (dccm_even_clk       ),
  .dccm_din_even           (dccm_din_even       ),
  .dccm_addr_even          (dccm_addr_even      ),
  .dccm_cs_even            (dccm_cs_even        ),
  .dccm_we_even            (dccm_we_even        ),
  .dccm_wem_even           (dccm_wem_even       ),
  .dccm_dout_even          (dccm_dout_even      ),

  .dccm_odd_clk            (dccm_odd_clk        ),
  .dccm_din_odd            (dccm_din_odd        ),
  .dccm_addr_odd           (dccm_addr_odd       ),
  .dccm_cs_odd             (dccm_cs_odd         ),
  .dccm_we_odd             (dccm_we_odd         ),
  .dccm_wem_odd            (dccm_wem_odd        ),
  .dccm_dout_odd           (dccm_dout_odd       ),
  .csr_sel_ctl             (csr_dmp_sel_ctl     ),
  .csr_sel_addr            (csr_dmp_sel_addr    ),

  .csr_rdata               (dmp_csr_rdata       ),
  .csr_illegal             (dmp_csr_illegal     ),
  .csr_unimpl              (dmp_csr_unimpl      ),
  .csr_serial_sr           (dmp_csr_serial_sr   ),
  .csr_strict_sr           (dmp_csr_strict_sr   ),

  .csr_write               (csr_dmp_write       ),
  .csr_waddr               (csr_dmp_waddr       ),
  .csr_wdata               (csr_dmp_wdata       ),

  .dmi_dccm_cmd_valid       (dmi_dccm_cmd_valid     ),
  .dmi_dccm_prio            (dmi_dccm_cmd_prio      ),
  .dmi_dccm_cmd_read        (dmi_dccm_cmd_read      ),
  .dmi_dccm_cmd_addr        (dmi_dccm_cmd_addr      ),
  .dmi_dccm_cmd_excl        (dmi_dccm_cmd_excl      ),
  .dmi_dccm_cmd_id          (dmi_dccm_cmd_id        ), // @@@
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

  .iccm_base               (iccm0_base             ),
  .csr_iccm_off            (iccm0_disable          ),

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

  .lsq_mem_cmd_valid       (lsq_mem_cmd_valid       ),
  .lsq_mem_cmd_cache       (lsq_mem_cmd_cache       ),
  .lsq_mem_cmd_burst_size  (lsq_mem_cmd_burst_size  ),
  .lsq_mem_cmd_read        (lsq_mem_cmd_read        ),
  .lsq_mem_cmd_aux         (lsq_mem_cmd_aux         ),
  .lsq_mem_cmd_accept      (lsq_mem_cmd_accept      ),
  .lsq_mem_cmd_addr        (lsq_mem_cmd_addr        ),
  .lsq_mem_cmd_excl        (lsq_mem_cmd_excl        ),
  .lsq_mem_cmd_atomic      (lsq_mem_cmd_atomic      ),
  .lsq_mem_cmd_data_size   (lsq_mem_cmd_data_size   ),
  .lsq_mem_cmd_prot        (lsq_mem_cmd_prot        ),

  .lsq_mem_wr_valid        (lsq_mem_wr_valid        ),
  .lsq_mem_wr_last         (lsq_mem_wr_last         ),
  .lsq_mem_wr_accept       (lsq_mem_wr_accept       ),
  .lsq_mem_wr_mask         (lsq_mem_wr_mask         ),
  .lsq_mem_wr_data         (lsq_mem_wr_data         ),

  .lsq_mem_rd_valid        (lsq_mem_rd_valid        ),
  .lsq_mem_rd_err          (lsq_mem_rd_err          ),
  .lsq_mem_rd_excl_ok      (lsq_mem_rd_excl_ok      ),
  .lsq_mem_rd_last         (lsq_mem_rd_last         ),
  .lsq_mem_rd_accept       (lsq_mem_rd_accept       ),
  .lsq_mem_rd_data         (lsq_mem_rd_data         ),

  .lsq_mem_wr_done         (lsq_mem_wr_done         ),
  .lsq_mem_wr_excl_okay    (lsq_mem_wr_excl_okay    ),
  .lsq_mem_wr_err          (lsq_mem_wr_err          ),
  .lsq_mem_wr_resp_accept  (lsq_mem_wr_resp_accept  ),

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

  .core_mmio_base_r        (core_mmio_base_r       ),


  .dccm_ecc_sb_err_even_cnt    (dccm_even_ecc_sb_err  ),
  .dccm_ecc_db_err_even_cnt    (dccm_even_ecc_db_err  ),
  .dccm_ecc_syndrome_even      (dccm_even_ecc_syndrome),
  .dccm_ecc_address_even       (dccm_even_ecc_addr    ),
  .dccm_ecc_addr_err_even_cnt  (dccm_even_ecc_addr_err),
  .dccm_ecc_sb_err_odd_cnt     (dccm_odd_ecc_sb_err   ),
  .dccm_ecc_db_err_odd_cnt     (dccm_odd_ecc_db_err   ),
  .dccm_ecc_syndrome_odd       (dccm_odd_ecc_syndrome ),
  .dccm_ecc_address_odd        (dccm_odd_ecc_addr     ),
  .dccm_ecc_addr_err_odd_cnt   (dccm_odd_ecc_addr_err ),
  .dccm_ecc_scrub_err          (dccm_ecc_scrub_err    ),

  .arcv_mecc_diag_ecc      (arcv_mecc_diag_ecc      ),
  .dccm_ecc_excpn          (dccm_ecc_excpn          ),
  .dccm_ecc_wr             (dccm_ecc_wr             ),
  .dccm_ecc_out            (dccm_ecc_out            ),

  .dmp_hpm_dmpreplay       (dmp_hpm_dmpreplay       ),
  .dmp_hpm_bdmplsq         (dmp_hpm_bdmplsq         ),
  .dmp_hpm_bdmpcwb         (dmp_hpm_bdmpcwb         ),

  .dmp_x2_store_r          (dmp_x2_store_r          ),
  .dmp_x2_lr_r             (dmp_x2_lr_r             ),
  .dmp_x2_sc_r             (dmp_x2_sc_r             ),
  .dmp_x2_amo_r            (dmp_x2_amo_r            ),

  .dmp_idle_r              (dmp_idle_r              ),
  .dmp_uncached_busy       (dmp_uncached_busy       ),
  .dmp_per_busy            (dmp_per_busy            ),
  .dmp_st_pending          (dmp_st_pending          ),

  .clk                     (clk_gated               ),
  .rst_a                   (rst_a                   )
);

rl_epmp u_rl_epmp (
  .ifu_addr0               (ifu_pmp_addr0),

  .ipmp_hit0               (ipmp_hit0  ),
  .ipmp_perm0              (ipmp_perm0),

  .dmp_addr                (dmp_x2_addr_r),
  .dmp_addr1               (dmp_x2_addr1_r),
  .cross_word              (dmp_x2_bank_cross_r),
  .cross_region            (cross_region),
  .dpmp_hit                (dpmp_hit),
  .dpmp_perm               (dpmp_perm),

  .csr_sel_ctl             (csr_pmp_sel_ctl),
  .csr_sel_addr            (csr_pmp_sel_addr),
  .priv_level_r            (priv_level_r),

  .csr_rdata               (pmp_csr_rdata),
  .csr_illegal             (pmp_csr_illegal),
  .csr_unimpl              (pmp_csr_unimpl),
  .csr_serial_sr           (pmp_csr_serial_sr),
  .csr_strict_sr           (pmp_csr_strict_sr),

  .csr_write               (csr_pmp_write),
  .csr_waddr               (csr_pmp_waddr),
  .csr_wdata               (csr_pmp_wdata),

  .x2_pass                 (x2_pass),


  .clk                     (clk_gated),
  .rst_a                   (rst_a)
);

rl_pma u_rl_pma (
  .ifu_addr0               (ifu_pma_addr0),
  .f1_mem_target           (f1_mem_target),
  .fetch_iccm_hole         (fetch_iccm_hole),

  .ipma_attr0              (ipma_attr0),

  .dmp_addr                (dmp_x2_addr_r),

  .dpma_attr               (dpma_attr),
  .dmp_x2_target_r         (dmp_x2_target_r),
  .dmp_x2_ccm_hole_r       (dmp_x2_ccm_hole_r),

  .csr_sel_ctl             (csr_pma_sel_ctl),
  .csr_sel_addr            (csr_pma_sel_addr),
  .priv_level_r            (priv_level_r),

  .csr_rdata               (pma_csr_rdata),
  .csr_illegal             (pma_csr_illegal),
  .csr_unimpl              (pma_csr_unimpl),
  .csr_serial_sr           (pma_csr_serial_sr),
  .csr_strict_sr           (pma_csr_strict_sr),

  .csr_write               (csr_pma_write),
  .csr_waddr               (csr_pma_waddr),
  .csr_wdata               (csr_pma_wdata),

  .x2_pass                 (x2_pass),


  .clk                     (clk_gated),
  .rst_a                   (rst_a)
);

rl_triggers u_rl_triggers (
  .clk                     (clk_gated),
  .rst_a                   (rst_a),

  .csr_sel_ctl             (csr_trig_sel_ctl),
  .csr_sel_addr            (csr_trig_sel_addr),

  .csr_rdata               (trig_csr_rdata),
  .csr_illegal             (trig_csr_illegal),
  .csr_unimpl              (trig_csr_unimpl),
  .csr_serial_sr           (trig_csr_serial_sr),
  .csr_strict_sr           (trig_csr_strict_sr),
  .csr_write               (csr_trig_write),
  .csr_waddr               (csr_trig_waddr),
  .csr_wdata               (csr_trig_wdata),
  .priv_level_r            (priv_level_r),

  .x2_pc                  (x2_pc),
  .x2_inst                (x2_inst),
  .x2_inst_size           (x2_inst_size),

  .dmp_x2_addr_r           (dmp_x2_addr_r),
  .dmp_x2_data_r           (dmp_x2_data_r),
  .dmp_x2_data             (dmp_x2_data),
  .dmp_x2_load_r           (dmp_x2_load_r),
  .dmp_x2_word_r           (dmp_x2_word_r),
  .dmp_x2_half_r           (dmp_x2_half_r),
  .lsq_rb_size             (lsq_rb_size),
  .dmp_x2_valid            (dmp_x2_valid),
  .dmp_x2_rb_req           (dmp_rb_req_r),

  .x2_pass                 (x2_pass),
  .x2_valid_r              (x2_valid_r),
  .db_active               (db_active),

  .ext_trig_output_valid   (ext_trig_valid),
  .ext_trig_in             (ext_trig_in),
  .ext_trig_output_accept  (ext_trig_accept),


  .secure_trig_iso_en      (safety_iso_enb_synch_r),
  .dr_secure_trig_iso_err  (dr_secure_trig_iso_err),

  .ifu_trig_trap           (ifu_inst_break),
  .ifu_trig_break          (ifu_inst_trap),
  .x2_inst_break           (x2_inst_break),
  .x2_inst_trap            (x2_inst_trap),
  .dmp_addr_trig_trap      (dmp_addr_trig_trap),
  .dmp_addr_trig_break     (dmp_addr_trig_break),
  .ext_trig_trap_r         (ext_trig_trap),
  .ext_trig_break_r        (ext_trig_break),
  .dmp_ld_data_trig_trap   (dmp_ld_data_trig_trap),
  .dmp_ld_data_trig_break  (dmp_ld_data_trig_break),
  .dmp_st_data_trig_trap   (dmp_st_data_trig_trap),
  .dmp_st_data_trig_break  (dmp_st_data_trig_break)
);

wire [`ADDR_RANGE] sfty_ibp_mmio_cmd_addr_tmp;
assign sfty_ibp_mmio_cmd_addr = sfty_ibp_mmio_cmd_addr_tmp[7:0];

rl_sfty_csr u_rl_sfty_csr (
  .lsc_diag_aux_r           (lsc_diag_aux_r),
  .dr_lsc_stl_ctrl_aux_r    (dr_lsc_stl_ctrl_aux_r),
  .lsc_shd_ctrl_aux_r       (lsc_shd_ctrl_aux_r),
  .dr_sfty_aux_parity_err_r (dr_sfty_aux_parity_err_r),
  .safety_comparator_enable (safety_comparator_enable),
  .dr_safety_comparator_enabled(dr_safety_comparator_enabled),
  .safety_iso_enb_synch_r   (safety_iso_enb_synch_r),
  .sfty_nsi_r               (sfty_nsi_r),
  .lsc_err_stat_aux         (lsc_err_stat_aux),
  .dr_sfty_eic              (dr_sfty_eic),
  .csr_sel_ctl              (csr_sfty_sel_ctl),
  .csr_sel_addr             (csr_sfty_sel_addr),

  .csr_rdata                (sfty_csr_rdata),
  .csr_illegal              (sfty_csr_illegal),
  .csr_unimpl               (sfty_csr_unimpl),
  .csr_serial_sr            (sfty_csr_serial_sr),
  .csr_strict_sr            (sfty_csr_strict_sr),

  .csr_write                (csr_sfty_write),
  .csr_waddr                (csr_sfty_waddr),
  .csr_wdata                (csr_sfty_wdata),

  .x2_pass                  (x2_pass),
  .priv_level_r             (priv_level_r  ),

  .clk                      (clk_gated),
  .rst_a                    (rst_a)
);

sfty_ibp_ini_e2e_wrap #(
    .DW        (32),// Data width
    .BSW       (1), // Burst size width
    .AW        (8), // Address size width(Only LSB 8 bits used)
    .SPC_PRE   (0)  // space signal 0: not present 1: present
    )
u_sfty_ibp_mmio_ini_e2e(
// IBP bus target interface
    .cmd_valid      (sfty_ibp_mmio_cmd_valid      ),
    .cmd_id         (1'b0                         ), // optional
    .cmd_cache      (sfty_ibp_mmio_cmd_cache      ),
    .cmd_burst_size (sfty_ibp_mmio_cmd_burst_size ),
    .cmd_read       (sfty_ibp_mmio_cmd_read       ),
    .cmd_wrap       (1'b0                         ),
    .cmd_accept     (sfty_ibp_mmio_cmd_accept     ),
    .cmd_addr       (sfty_ibp_mmio_cmd_addr       ),
    .cmd_excl       (sfty_ibp_mmio_cmd_excl       ), // optional
    .cmd_space      (3'b0                         ), // optional
    .cmd_atomic     (sfty_ibp_mmio_cmd_atomic     ),
    .cmd_data_size  (sfty_ibp_mmio_cmd_data_size  ),
    .cmd_prot       (sfty_ibp_mmio_cmd_prot       ),

    .wr_valid       (sfty_ibp_mmio_wr_valid ),
    .wr_last        (sfty_ibp_mmio_wr_last  ),
    .wr_accept      (sfty_ibp_mmio_wr_accept),
    .wr_mask        (sfty_ibp_mmio_wr_mask  ),
    .wr_data        (sfty_ibp_mmio_wr_data  ),

    .rd_valid       (sfty_ibp_mmio_rd_valid  ),
    .rd_id          (1'b0                    ),  // optional
    .rd_err         (sfty_ibp_mmio_rd_err    ),
    .rd_excl_ok     (sfty_ibp_mmio_rd_excl_ok),  // optional
    .rd_last        (sfty_ibp_mmio_rd_last   ),
    .rd_accept      (sfty_ibp_mmio_rd_accept ),
    .rd_resp        (4'b0                    ),  // optional
    .rd_data        (sfty_ibp_mmio_rd_data   ),

    .wr_done        (sfty_ibp_mmio_wr_done       ),
    .wr_id          (1'b0                         ),   // optional
    .wr_excl_okay   (sfty_ibp_mmio_wr_excl_okay  ),
    .wr_err         (sfty_ibp_mmio_wr_err        ),
    .wr_resp_accept (sfty_ibp_mmio_wr_resp_accept),
// IBP e2e protection interface
    .cmd_valid_pty  (sfty_ibp_mmio_cmd_valid_pty ),
    .cmd_accept_pty (sfty_ibp_mmio_cmd_accept_pty),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ : ID is not used in this configuration
    .cmd_id_pty     (                            ),
// spyglass enable_block UnloadedOutTerm-ML
    .cmd_addr_pty   (sfty_ibp_mmio_cmd_addr_pty  ),
    .cmd_ctrl_pty   (sfty_ibp_mmio_cmd_ctrl_pty  ),

    .wr_valid_pty   (sfty_ibp_mmio_wr_valid_pty  ),
    .wr_accept_pty  (sfty_ibp_mmio_wr_accept_pty ),
    .wr_last_pty    (sfty_ibp_mmio_wr_last_pty   ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ : write mask and data is not used as it's read only bus
    .wr_mask_pty    (                            ),
    .wr_data_pty    (                            ),
// spyglass enable_block UnloadedOutTerm-ML

    .rd_valid_pty   (sfty_ibp_mmio_rd_valid_pty  ),
    .rd_accept_pty  (sfty_ibp_mmio_rd_accept_pty ),
    .rd_id_pty      (1'b0                        ),
    .rd_ctrl_pty    (sfty_ibp_mmio_rd_ctrl_pty   ),
    .rd_data_pty    (sfty_ibp_mmio_rd_data_pty   ),

    .wr_done_pty    (sfty_ibp_mmio_wr_done_pty   ),
    .wr_id_pty      (1'b0                        ),
    .wr_ctrl_pty    (sfty_ibp_mmio_wr_ctrl_pty   ),
    .wr_resp_accept_pty(sfty_ibp_mmio_wr_resp_accept_pty),

// msic
    .ini_e2e_err    (sfty_ibp_mmio_ini_e2e_err   ),
    .clk            (clk                         ),
    .rst_a          (rst_a                       )
);

rl_ibp2mmio u_rl_ibp2mmio (
  /////////////////// LSQ Memory-maped CSR IBP target interface /////////////////////
  //
  .lsq_ibp_cmd_valid            (lsq_mmio_cmd_valid),
  .lsq_ibp_cmd_cache            (lsq_mmio_cmd_cache),
  .lsq_ibp_cmd_burst_size       (lsq_mmio_cmd_burst_size),
  .lsq_ibp_cmd_read             (lsq_mmio_cmd_read),
  .lsq_ibp_cmd_aux              (lsq_mmio_cmd_aux),
  .lsq_ibp_cmd_accept           (lsq_mmio_cmd_accept),
  .lsq_ibp_cmd_addr             (lsq_mmio_cmd_addr),
  .lsq_ibp_cmd_excl             (lsq_mmio_cmd_excl),
  .lsq_ibp_cmd_atomic           (lsq_mmio_cmd_atomic),
  .lsq_ibp_cmd_data_size        (lsq_mmio_cmd_data_size),
  .lsq_ibp_cmd_prot             (lsq_mmio_cmd_prot),

  .lsq_ibp_wr_valid             (lsq_mmio_wr_valid),
  .lsq_ibp_wr_last              (lsq_mmio_wr_last),
  .lsq_ibp_wr_accept            (lsq_mmio_wr_accept),
  .lsq_ibp_wr_mask              (lsq_mmio_wr_mask),
  .lsq_ibp_wr_data              (lsq_mmio_wr_data),

  .lsq_ibp_rd_valid             (lsq_mmio_rd_valid),
  .lsq_ibp_rd_err               (lsq_mmio_rd_err),
  .lsq_ibp_rd_excl_ok           (lsq_mmio_rd_excl_ok),
  .lsq_ibp_rd_last              (lsq_mmio_rd_last),
  .lsq_ibp_rd_accept            (lsq_mmio_rd_accept),
  .lsq_ibp_rd_data              (lsq_mmio_rd_data),

  .lsq_ibp_wr_done              (lsq_mmio_wr_done),
  .lsq_ibp_wr_excl_okay         (lsq_mmio_wr_excl_okay),
  .lsq_ibp_wr_err               (lsq_mmio_wr_err),
  .lsq_ibp_wr_resp_accept       (lsq_mmio_wr_resp_accept),

  /////////////////// External Memory-maped CSR IBP target interface //////////////////
  //
  .dmi_ibp_cmd_prio             (dmi_mmio_cmd_prio),

  .dmi_ibp_cmd_valid            (dmi_mmio_cmd_valid),
  .dmi_ibp_cmd_cache            (dmi_mmio_cmd_cache),
  .dmi_ibp_cmd_burst_size       (dmi_mmio_cmd_burst_size),
  .dmi_ibp_cmd_read             (dmi_mmio_cmd_read),
  .dmi_ibp_cmd_aux              (1'b0),
  .dmi_ibp_cmd_accept           (dmi_mmio_cmd_accept),
  .dmi_ibp_cmd_addr             (dmi_mmio_cmd_addr),
  .dmi_ibp_cmd_excl             (dmi_mmio_cmd_excl),
  .dmi_ibp_cmd_atomic           (6'b0),
  .dmi_ibp_cmd_data_size        (dmi_mmio_cmd_data_size),
  .dmi_ibp_cmd_prot             (dmi_mmio_cmd_prot),

  .dmi_ibp_wr_valid             (dmi_mmio_wr_valid),
  .dmi_ibp_wr_last              (dmi_mmio_wr_last),
  .dmi_ibp_wr_accept            (dmi_mmio_wr_accept),
  .dmi_ibp_wr_mask              (dmi_mmio_wr_mask),
  .dmi_ibp_wr_data              (dmi_mmio_wr_data),

  .dmi_ibp_rd_valid             (dmi_mmio_rd_valid),
  .dmi_ibp_rd_err               (dmi_mmio_rd_err),
  .dmi_ibp_rd_excl_ok           (dmi_mmio_rd_excl_ok),
  .dmi_ibp_rd_last              (dmi_mmio_rd_last),
  .dmi_ibp_rd_accept            (dmi_mmio_rd_accept),
  .dmi_ibp_rd_data              (dmi_mmio_rd_data),

  .dmi_ibp_wr_done              (dmi_mmio_wr_done),
  .dmi_ibp_wr_excl_okay         (dmi_mmio_wr_excl_okay),
  .dmi_ibp_wr_err               (dmi_mmio_wr_err),
  .dmi_ibp_wr_resp_accept       (dmi_mmio_wr_resp_accept),

  /////////////////// Distributed Memory-maped CSR IBP initiator interface //////////////
  //
  // Timer, software interrupt MMIO register
  .mmio0_cmd_valid           (ibp_mmio_cmd_valid),
  .mmio0_cmd_cache           (ibp_mmio_cmd_cache),
  .mmio0_cmd_burst_size      (ibp_mmio_cmd_burst_size),
  .mmio0_cmd_read            (ibp_mmio_cmd_read),
  .mmio0_cmd_aux             (ibp_mmio_cmd_aux),
  .mmio0_cmd_accept          (ibp_mmio_cmd_accept),
  .mmio0_cmd_addr            (ibp_mmio_cmd_addr),
  .mmio0_cmd_excl            (ibp_mmio_cmd_excl),
  .mmio0_cmd_atomic          (ibp_mmio_cmd_atomic),
  .mmio0_cmd_data_size       (ibp_mmio_cmd_data_size),
  .mmio0_cmd_prot            (ibp_mmio_cmd_prot),

  .mmio0_wr_valid            (ibp_mmio_wr_valid),
  .mmio0_wr_last             (ibp_mmio_wr_last),
  .mmio0_wr_accept           (ibp_mmio_wr_accept),
  .mmio0_wr_mask             (ibp_mmio_wr_mask),
  .mmio0_wr_data             (ibp_mmio_wr_data),

  .mmio0_rd_valid            (ibp_mmio_rd_valid),
  .mmio0_rd_err              (ibp_mmio_rd_err),
  .mmio0_rd_excl_ok          (ibp_mmio_rd_excl_ok),
  .mmio0_rd_last             (ibp_mmio_rd_last),
  .mmio0_rd_accept           (ibp_mmio_rd_accept),
  .mmio0_rd_data             (ibp_mmio_rd_data),

  .mmio0_wr_done             (ibp_mmio_wr_done),
  .mmio0_wr_excl_okay        (ibp_mmio_wr_excl_okay),
  .mmio0_wr_err              (ibp_mmio_wr_err),
  .mmio0_wr_resp_accept      (ibp_mmio_wr_resp_accept),

  // Safety MMIO register inside safety monitor
  .mmio1_cmd_valid           (sfty_ibp_mmio_cmd_valid),
  .mmio1_cmd_cache           (sfty_ibp_mmio_cmd_cache),
  .mmio1_cmd_burst_size      (sfty_ibp_mmio_cmd_burst_size),
  .mmio1_cmd_read            (sfty_ibp_mmio_cmd_read),
  .mmio1_cmd_aux             (sfty_ibp_mmio_cmd_aux),
  .mmio1_cmd_accept          (sfty_ibp_mmio_cmd_accept),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ : Only address LSB are used in this configuration
  .mmio1_cmd_addr            (sfty_ibp_mmio_cmd_addr_tmp),
// spyglass enable_block UnloadedOutTerm-ML
  .mmio1_cmd_excl            (sfty_ibp_mmio_cmd_excl),
  .mmio1_cmd_atomic          (sfty_ibp_mmio_cmd_atomic),
  .mmio1_cmd_data_size       (sfty_ibp_mmio_cmd_data_size),
  .mmio1_cmd_prot            (sfty_ibp_mmio_cmd_prot),

  .mmio1_wr_valid            (sfty_ibp_mmio_wr_valid),
  .mmio1_wr_last             (sfty_ibp_mmio_wr_last),
  .mmio1_wr_accept           (sfty_ibp_mmio_wr_accept),
  .mmio1_wr_mask             (sfty_ibp_mmio_wr_mask),
  .mmio1_wr_data             (sfty_ibp_mmio_wr_data),

  .mmio1_rd_valid            (sfty_ibp_mmio_rd_valid),
  .mmio1_rd_err              (sfty_ibp_mmio_rd_err),
  .mmio1_rd_excl_ok          (sfty_ibp_mmio_rd_excl_ok),
  .mmio1_rd_last             (sfty_ibp_mmio_rd_last),
  .mmio1_rd_accept           (sfty_ibp_mmio_rd_accept),
  .mmio1_rd_data             (sfty_ibp_mmio_rd_data),

  .mmio1_wr_done             (sfty_ibp_mmio_wr_done),
  .mmio1_wr_excl_okay        (sfty_ibp_mmio_wr_excl_okay),
  .mmio1_wr_err              (sfty_ibp_mmio_wr_err),
  .mmio1_wr_resp_accept      (sfty_ibp_mmio_wr_resp_accept),


  .mmio2_cmd_valid           (ras_ibp_mmio_cmd_valid),
  .mmio2_cmd_cache           (ras_ibp_mmio_cmd_cache),
  .mmio2_cmd_burst_size      (ras_ibp_mmio_cmd_burst_size),
  .mmio2_cmd_read            (ras_ibp_mmio_cmd_read),
  .mmio2_cmd_aux             (ras_ibp_mmio_cmd_aux),
  .mmio2_cmd_accept          (ras_ibp_mmio_cmd_accept),
  .mmio2_cmd_addr            (ras_ibp_mmio_cmd_addr),
  .mmio2_cmd_excl            (ras_ibp_mmio_cmd_excl),
  .mmio2_cmd_atomic          (ras_ibp_mmio_cmd_atomic),
  .mmio2_cmd_data_size       (ras_ibp_mmio_cmd_data_size),
  .mmio2_cmd_prot            (ras_ibp_mmio_cmd_prot),

  .mmio2_wr_valid            (ras_ibp_mmio_wr_valid),
  .mmio2_wr_last             (ras_ibp_mmio_wr_last),
  .mmio2_wr_accept           (ras_ibp_mmio_wr_accept),
  .mmio2_wr_mask             (ras_ibp_mmio_wr_mask),
  .mmio2_wr_data             (ras_ibp_mmio_wr_data),

  .mmio2_rd_valid            (ras_ibp_mmio_rd_valid),
  .mmio2_rd_err              (ras_ibp_mmio_rd_err),
  .mmio2_rd_excl_ok          (ras_ibp_mmio_rd_excl_ok),
  .mmio2_rd_last             (ras_ibp_mmio_rd_last),
  .mmio2_rd_accept           (ras_ibp_mmio_rd_accept),
  .mmio2_rd_data             (ras_ibp_mmio_rd_data),

  .mmio2_wr_done             (ras_ibp_mmio_wr_done),
  .mmio2_wr_excl_okay        (ras_ibp_mmio_wr_excl_okay),
  .mmio2_wr_err              (ras_ibp_mmio_wr_err),
  .mmio2_wr_resp_accept      (ras_ibp_mmio_wr_resp_accept),


  ////////// General input signals /////////////////////////////////////////////
  //
  .biu_mmio_idle             (biu_mmio_idle),
  .clk                       (clk_gated),                 // clock signal
  .rst_a                     (rst_a)                  // reset signal
);

rl_ras_top u_rl_ras_top (
    .ibp_mmio_cmd_valid      ( ras_ibp_mmio_cmd_valid      ),
    .ibp_mmio_cmd_cache      ( ras_ibp_mmio_cmd_cache      ),
    .ibp_mmio_cmd_burst_size ( ras_ibp_mmio_cmd_burst_size ),
    .ibp_mmio_cmd_read       ( ras_ibp_mmio_cmd_read       ),
    .ibp_mmio_cmd_aux        ( ras_ibp_mmio_cmd_aux        ),
    .ibp_mmio_cmd_accept     ( ras_ibp_mmio_cmd_accept     ),
    .ibp_mmio_cmd_addr       ( ras_ibp_mmio_cmd_addr       ),
    .ibp_mmio_cmd_excl       ( ras_ibp_mmio_cmd_excl       ),
    .ibp_mmio_cmd_atomic     ( ras_ibp_mmio_cmd_atomic     ),
    .ibp_mmio_cmd_data_size  ( ras_ibp_mmio_cmd_data_size  ),
    .ibp_mmio_cmd_prot       ( ras_ibp_mmio_cmd_prot       ),
    .ibp_mmio_wr_valid       ( ras_ibp_mmio_wr_valid       ),
    .ibp_mmio_wr_last        ( ras_ibp_mmio_wr_last        ),
    .ibp_mmio_wr_accept      ( ras_ibp_mmio_wr_accept      ),
    .ibp_mmio_wr_mask        ( ras_ibp_mmio_wr_mask        ),
    .ibp_mmio_wr_data        ( ras_ibp_mmio_wr_data        ),
    .ibp_mmio_rd_valid       ( ras_ibp_mmio_rd_valid       ),
    .ibp_mmio_rd_err         ( ras_ibp_mmio_rd_err         ),
    .ibp_mmio_rd_excl_ok     ( ras_ibp_mmio_rd_excl_ok     ),
    .ibp_mmio_rd_last        ( ras_ibp_mmio_rd_last        ),
    .ibp_mmio_rd_accept      ( ras_ibp_mmio_rd_accept      ),
    .ibp_mmio_rd_data        ( ras_ibp_mmio_rd_data        ),
    .ibp_mmio_wr_done        ( ras_ibp_mmio_wr_done        ),
    .ibp_mmio_wr_excl_okay   ( ras_ibp_mmio_wr_excl_okay   ),
    .ibp_mmio_wr_err         ( ras_ibp_mmio_wr_err         ),
    .ibp_mmio_wr_resp_accept ( ras_ibp_mmio_wr_resp_accept ),

    .high_prio_ras           ( high_prio_ras               ),
    .sfty_mem_adr_err        ( sfty_mem_adr_err            ),
    .sfty_mem_dbe_err        ( sfty_mem_dbe_err            ),
    .sfty_mem_sbe_err        ( sfty_mem_sbe_err            ),
    .sfty_mem_sbe_overflow   ( sfty_mem_sbe_overflow       ),

   .iccm0_ecc_addr_err ( iccm0_ecc_addr_err ),
   .iccm0_ecc_sb_err   ( iccm0_ecc_sb_err   ),
   .iccm0_ecc_db_err   ( iccm0_ecc_db_err   ),
   .iccm0_ecc_syndrome ( iccm0_ecc_syndrome ),
   .iccm0_ecc_addr     ( iccm0_ecc_addr     ),

   .dccm_even_ecc_addr_err  ( dccm_even_ecc_addr_err  ),
   .dccm_even_ecc_sb_err    ( dccm_even_ecc_sb_err    ),
   .dccm_even_ecc_db_err    ( dccm_even_ecc_db_err    ),
   .dccm_even_ecc_syndrome  ( dccm_even_ecc_syndrome  ),
   .dccm_even_ecc_addr      ( dccm_even_ecc_addr      ),
   .dccm_odd_ecc_addr_err   ( dccm_odd_ecc_addr_err   ),
   .dccm_odd_ecc_sb_err     ( dccm_odd_ecc_sb_err     ),
   .dccm_odd_ecc_db_err     ( dccm_odd_ecc_db_err     ),
   .dccm_odd_ecc_syndrome   ( dccm_odd_ecc_syndrome   ),
   .dccm_odd_ecc_addr       ( dccm_odd_ecc_addr       ),

   .dccm_ecc_scrub_err      (dccm_ecc_scrub_err       ),
   .x2_pass                 (x2_pass                  ),   

   .ic_tag_ecc_addr_err     ( ic_tag_ecc_addr_err     ),
   .ic_tag_ecc_sb_err       ( ic_tag_ecc_sb_err       ),
   .ic_tag_ecc_db_err       ( ic_tag_ecc_db_err       ),
   .ic_tag_ecc_syndrome     ( ic_tag_ecc_syndrome     ),
   .ic_tag_ecc_addr         ( ic_tag_ecc_addr         ),

   .ic_data_ecc_addr_err    ( ic_data_ecc_addr_err    ),
   .ic_data_ecc_sb_err      ( ic_data_ecc_sb_err      ),
   .ic_data_ecc_db_err      ( ic_data_ecc_db_err      ),
   .ic_data_ecc_syndrome    ( ic_data_ecc_syndrome    ),
   .ic_data_ecc_addr        ( ic_data_ecc_addr        ),

    .clk                     ( clk                     ),
    .rst_a                   ( rst_a                   )
);


rl_ibp2ahb  u_rl_ibp2ahb (
  .cmd_wid                  (wid               ),
  .ifu_mem_cmd_valid        (ifu_cmd_valid         ),
  .ifu_mem_cmd_cache        (ifu_cmd_cache         ),
  .ifu_mem_cmd_burst_size   (ifu_cmd_burst_size    ),
  .ifu_mem_cmd_read         (ifu_cmd_read          ),
  .ifu_mem_cmd_aux          (ifu_cmd_aux           ),
  .ifu_mem_cmd_accept       (ifu_cmd_accept        ),
  .ifu_mem_cmd_addr         (ifu_cmd_addr          ),
  .ifu_mem_cmd_wrap         (ifu_cmd_wrap          ),
  .ifu_mem_cmd_excl         (ifu_cmd_excl          ),
  .ifu_mem_cmd_atomic       (ifu_cmd_atomic        ),
  .ifu_mem_cmd_data_size    (ifu_cmd_data_size     ),
  .ifu_mem_cmd_prot         (ifu_cmd_prot          ),
  .ifu_fch_vec              (ifu_fch_vec           ),

  .ifu_mem_rd_valid         (ifu_rd_valid          ),
  .ifu_mem_rd_err           (ifu_rd_err            ),
  .ifu_mem_rd_excl_ok       (ifu_rd_excl_ok        ),
  .ifu_mem_rd_last          (ifu_rd_last           ),
  .ifu_mem_rd_accept        (ifu_rd_accept         ),
  .ifu_mem_rd_data          (ifu_rd_data           ),

  .lsq_mem_cmd_valid        (lsq_mem_cmd_valid     ),
  .lsq_mem_cmd_cache        (lsq_mem_cmd_cache     ),
  .lsq_mem_cmd_burst_size   (lsq_mem_cmd_burst_size),
  .lsq_mem_cmd_read         (lsq_mem_cmd_read      ),
  .lsq_mem_cmd_aux          (lsq_mem_cmd_aux       ),
  .lsq_mem_cmd_accept       (lsq_mem_cmd_accept    ),
  .lsq_mem_cmd_addr         (lsq_mem_cmd_addr      ),
  .lsq_mem_cmd_excl         (lsq_mem_cmd_excl      ),
  .lsq_mem_cmd_atomic       (lsq_mem_cmd_atomic    ),
  .lsq_mem_cmd_data_size    (lsq_mem_cmd_data_size ),
  .lsq_mem_cmd_prot         (lsq_mem_cmd_prot      ),

  .lsq_mem_wr_valid         (lsq_mem_wr_valid      ),
  .lsq_mem_wr_last          (lsq_mem_wr_last       ),
  .lsq_mem_wr_accept        (lsq_mem_wr_accept     ),
  .lsq_mem_wr_mask          (lsq_mem_wr_mask       ),
  .lsq_mem_wr_data          (lsq_mem_wr_data       ),

  .lsq_mem_rd_valid         (lsq_mem_rd_valid      ),
  .lsq_mem_rd_err           (lsq_mem_rd_err        ),
  .lsq_mem_rd_excl_ok       (lsq_mem_rd_excl_ok    ),
  .lsq_mem_rd_last          (lsq_mem_rd_last       ),
  .lsq_mem_rd_accept        (lsq_mem_rd_accept     ),
  .lsq_mem_rd_data          (lsq_mem_rd_data       ),

  .lsq_mem_wr_done          (lsq_mem_wr_done       ),
  .lsq_mem_wr_excl_okay     (lsq_mem_wr_excl_okay  ),
  .lsq_mem_wr_err           (lsq_mem_wr_err        ),
  .lsq_mem_wr_resp_accept   (lsq_mem_wr_resp_accept),


  .ahb_hlock               (ahb_hlock  ),
  .ahb_hexcl               (ahb_hexcl  ),
  .ahb_hmaster             (ahb_hmaster),
  .ahb_hauser              (ahb_hauser ),

  .ahb_hwrite              (ahb_hwrite ),
  .ahb_haddr               (ahb_haddr  ),
  .ahb_htrans              (ahb_htrans ),
  .ahb_hsize               (ahb_hsize  ),
  .ahb_hburst              (ahb_hburst ),
  .ahb_hwstrb              (ahb_hwstrb ),
  .ahb_hprot               (ahb_hprot  ),
  .ahb_hnonsec             (ahb_hnonsec),
  .ahb_hready              (ahb_hready ),
  .ahb_hresp               (ahb_hresp  ),
  .ahb_hexokay             (ahb_hexokay),
  .ahb_hrdata              (ahb_hrdata ),
  .ahb_hwdata              (ahb_hwdata ),

  .ahb_hauserchk           (ahb_hauserchk),
  .ahb_haddrchk            (ahb_haddrchk),
  .ahb_htranschk           (ahb_htranschk),
  .ahb_hctrlchk1           (ahb_hctrlchk1),
  .ahb_hctrlchk2           (ahb_hctrlchk2),
  .ahb_hprotchk            (ahb_hprotchk),
  .ahb_hwstrbchk           (ahb_hwstrbchk),
  .ahb_hreadychk           (ahb_hreadychk),
  .ahb_hrespchk            (ahb_hrespchk),
  .ahb_hrdatachk           (ahb_hrdatachk),
  .ahb_hwdatachk           (ahb_hwdatachk),

  .ahb_fatal_err           (ahb_fatal_err_comb),
  .biu_cbu_idle            (biu_cbu_idle ),
  .clk                     (clk_gated    ),
  .rst_a                   (rst_a      )
);

rl_per_ibp2ahb  u_rl_per_ibp2ahb (
  .cmd_wid                  (wid               ),
  .lsq_per_cmd_valid        (lsq_per_cmd_valid     ),
  .lsq_per_cmd_cache        (lsq_per_cmd_cache     ),
  .lsq_per_cmd_burst_size   (lsq_per_cmd_burst_size),
  .lsq_per_cmd_read         (lsq_per_cmd_read      ),
  .lsq_per_cmd_aux          (lsq_per_cmd_aux       ),
  .lsq_per_cmd_accept       (lsq_per_cmd_accept    ),
  .lsq_per_cmd_addr         (lsq_per_cmd_addr      ),
  .lsq_per_cmd_excl         (lsq_per_cmd_excl      ),
  .lsq_per_cmd_atomic       (lsq_per_cmd_atomic    ),
  .lsq_per_cmd_data_size    (lsq_per_cmd_data_size ),
  .lsq_per_cmd_prot         (lsq_per_cmd_prot      ),

  .lsq_per_wr_valid         (lsq_per_wr_valid      ),
  .lsq_per_wr_last          (lsq_per_wr_last       ),
  .lsq_per_wr_accept        (lsq_per_wr_accept     ),
  .lsq_per_wr_mask          (lsq_per_wr_mask       ),
  .lsq_per_wr_data          (lsq_per_wr_data       ),

  .lsq_per_rd_valid         (lsq_per_rd_valid      ),
  .lsq_per_rd_err           (lsq_per_rd_err        ),
  .lsq_per_rd_excl_ok       (lsq_per_rd_excl_ok    ),
  .lsq_per_rd_last          (lsq_per_rd_last       ),
  .lsq_per_rd_accept        (lsq_per_rd_accept     ),
  .lsq_per_rd_data          (lsq_per_rd_data       ),

  .lsq_per_wr_done          (lsq_per_wr_done       ),
  .lsq_per_wr_excl_okay     (lsq_per_wr_excl_okay  ),
  .lsq_per_wr_err           (lsq_per_wr_err        ),
  .lsq_per_wr_resp_accept   (lsq_per_wr_resp_accept),

  .dbu_per_ahb_hlock        (dbu_per_ahb_hlock  ),
  .dbu_per_ahb_hexcl        (dbu_per_ahb_hexcl  ),
  .dbu_per_ahb_hmaster      (dbu_per_ahb_hmaster),
  .dbu_per_ahb_hauser       (dbu_per_ahb_hauser),

  .dbu_per_ahb_hwrite       (dbu_per_ahb_hwrite ),
  .dbu_per_ahb_haddr        (dbu_per_ahb_haddr  ),
  .dbu_per_ahb_htrans       (dbu_per_ahb_htrans ),
  .dbu_per_ahb_hsize        (dbu_per_ahb_hsize  ),
  .dbu_per_ahb_hburst       (dbu_per_ahb_hburst ),
  .dbu_per_ahb_hwstrb       (dbu_per_ahb_hwstrb ),
  .dbu_per_ahb_hprot        (dbu_per_ahb_hprot  ),
  .dbu_per_ahb_hnonsec      (dbu_per_ahb_hnonsec),
  .dbu_per_ahb_hready       (dbu_per_ahb_hready ),
  .dbu_per_ahb_hresp        (dbu_per_ahb_hresp  ),
  .dbu_per_ahb_hexokay      (dbu_per_ahb_hexokay),
  .dbu_per_ahb_hrdata       (dbu_per_ahb_hrdata ),
  .dbu_per_ahb_hwdata       (dbu_per_ahb_hwdata ),

  .dbu_per_ahb_hauserchk    (dbu_per_ahb_hauserchk),
  .dbu_per_ahb_haddrchk     (dbu_per_ahb_haddrchk),
  .dbu_per_ahb_htranschk    (dbu_per_ahb_htranschk),
  .dbu_per_ahb_hctrlchk1    (dbu_per_ahb_hctrlchk1),
  .dbu_per_ahb_hctrlchk2    (dbu_per_ahb_hctrlchk2),
  .dbu_per_ahb_hprotchk     (dbu_per_ahb_hprotchk),
  .dbu_per_ahb_hwstrbchk    (dbu_per_ahb_hwstrbchk),
  .dbu_per_ahb_hreadychk    (dbu_per_ahb_hreadychk),
  .dbu_per_ahb_hrespchk     (dbu_per_ahb_hrespchk),
  .dbu_per_ahb_hrdatachk    (dbu_per_ahb_hrdatachk),
  .dbu_per_ahb_hwdatachk    (dbu_per_ahb_hwdatachk),

  .dbu_per_ahb_fatal_err    (dbu_per_ahb_fatal_err_comb),

  .biu_dbu_per_idle         (biu_dbu_per_idle     ),
  .clk                      (clk_gated  ),
  .rst_a                    (rst_a      )

);


rl_ahb2ibp
#(
  .ARB_IN_BIU         (1)
 )
u_rl_iccm_ahb2ibp
(

  .ibp_cmd_prio             (dmi_iccm_cmd_prio),

  .ibp_cmd_valid            (dmi_iccm_cmd_valid     ),
  .ibp_cmd_cache            (dmi_iccm_cmd_cache     ),
  .ibp_cmd_burst_size       (dmi_iccm_cmd_burst_size),
  .ibp_cmd_read             (dmi_iccm_cmd_read      ),
  .ibp_cmd_accept           (dmi_iccm_cmd_accept    ),
  .ibp_cmd_addr             (dmi_iccm_cmd_addr      ),
  .ibp_cmd_excl             (dmi_iccm_cmd_excl      ),
  .ibp_cmd_id               (dmi_iccm_cmd_id        ),
  .ibp_cmd_data_size        (dmi_iccm_cmd_data_size ),
  .ibp_cmd_prot             (dmi_iccm_cmd_prot      ),

  .ibp_wr_valid             (dmi_iccm_wr_valid      ),
  .ibp_wr_last              (dmi_iccm_wr_last       ),
  .ibp_wr_accept            (dmi_iccm_wr_accept     ),
  .ibp_wr_mask              (dmi_iccm_wr_mask       ),
  .ibp_wr_data              (dmi_iccm_wr_data       ),

  .ibp_rd_valid             (dmi_iccm_rd_valid      ),
  .ibp_rd_err               (dmi_iccm_rd_err        ),
  .ibp_rd_excl_ok           (dmi_iccm_rd_excl_ok    ),
  .ibp_rd_last              (dmi_iccm_rd_last       ),
  .ibp_rd_accept            (dmi_iccm_rd_accept     ),
  .ibp_rd_data              (dmi_iccm_rd_data       ),

  .ibp_wr_done              (dmi_iccm_wr_done       ),
  .ibp_wr_excl_okay         (dmi_iccm_wr_excl_okay  ),
  .ibp_wr_err               (dmi_iccm_wr_err        ),
  .ibp_wr_resp_accept       (dmi_iccm_wr_resp_accept),
  ///////// ICCM0/ICCM1 DMI AHB5 initiator /////////////////////////////////
  .ahb_prio                 (iccm_ahb_prio),
  .ahb_hlock                (iccm_ahb_hlock),
  .ahb_hexcl                (iccm_ahb_hexcl),
  .ahb_hmaster              (iccm_ahb_hmaster),

  .ahb_hsel                 (iccm_ahb_hsel),
  .ahb_htrans               (iccm_ahb_htrans),
  .ahb_hwrite               (iccm_ahb_hwrite),
  .ahb_haddr                (iccm_ahb_haddr),
  .ahb_hsize                (iccm_ahb_hsize),
  .ahb_hwstrb               (iccm_ahb_hwstrb),
  .ahb_hburst               (iccm_ahb_hburst),
  .ahb_hprot                (iccm_ahb_hprot),
  .ahb_hnonsec              (iccm_ahb_hnonsec),
  .ahb_hwdata               (iccm_ahb_hwdata),
  .ahb_hready               (iccm_ahb_hready),
  .ahb_hrdata               (iccm_ahb_hrdata),
  .ahb_hresp                (iccm_ahb_hresp),
  .ahb_hexokay              (iccm_ahb_hexokay),
  .ahb_hready_resp          (iccm_ahb_hready_resp),
 ///////// ICCM0/ICCM1 DMI AHB5 bus protection signals /////////////////////////////////////
 //

  .ahb_haddrchk             (iccm_ahb_haddrchk),
  .ahb_htranschk            (iccm_ahb_htranschk),
  .ahb_hctrlchk1            (iccm_ahb_hctrlchk1),
  .ahb_hctrlchk2            (iccm_ahb_hctrlchk2),
  .ahb_hwstrbchk            (iccm_ahb_hwstrbchk),
  .ahb_hprotchk             (iccm_ahb_hprotchk),
  .ahb_hreadychk            (iccm_ahb_hreadychk),
  .ahb_hrespchk             (iccm_ahb_hrespchk),
  .ahb_hready_respchk       (iccm_ahb_hready_respchk),
  .ahb_hselchk              (iccm_ahb_hselchk),
  .ahb_hrdatachk            (iccm_ahb_hrdatachk),
  .ahb_hwdatachk            (iccm_ahb_hwdatachk),
  .ahb_fatal_err            (iccm_ahb_fatal_err_comb),
  .dmi_clock_enable_nxt     (iccm_dmi_clock_enable_nxt),
  .dmi_clock_enable         (ar_clock_enable_r),
  .biu_dmi_idle             (biu_iccm_dmi_idle),
  .clk                      (clk              ),
  .rst_a                    (rst_a      )
);

rl_ahb2ibp
#(
  .ARB_IN_BIU         (0)
 )
u_rl_dccm_ahb2ibp
(

  .ibp_cmd_prio             (dmi_dccm_cmd_prio      ),

  .ibp_cmd_valid            (dmi_dccm_cmd_valid     ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded output terminal
// SJ: Highest bit not useful
  .ibp_cmd_cache            (dmi_dccm_cmd_cache     ), // @@@
  .ibp_cmd_burst_size       (dmi_dccm_cmd_burst_size), // @@@
  .ibp_cmd_read             (dmi_dccm_cmd_read      ),
  .ibp_cmd_accept           (dmi_dccm_cmd_accept    ),
  .ibp_cmd_addr             (dmi_dccm_cmd_addr      ),
  .ibp_cmd_excl             (dmi_dccm_cmd_excl      ),
  .ibp_cmd_id               (dmi_dccm_cmd_id        ),
  .ibp_cmd_data_size        (dmi_dccm_cmd_data_size ),   // @@@
  .ibp_cmd_prot             (dmi_dccm_cmd_prot      ), // @@@
// spyglass enable_block UnloadedOutTerm-ML

  .ibp_wr_valid             (dmi_dccm_wr_valid      ),
  .ibp_wr_last              (dmi_dccm_wr_last       ),
  .ibp_wr_accept            (dmi_dccm_wr_accept     ),
  .ibp_wr_mask              (dmi_dccm_wr_mask       ),
  .ibp_wr_data              (dmi_dccm_wr_data       ),

  .ibp_rd_valid             (dmi_dccm_rd_valid      ),
  .ibp_rd_err               (dmi_dccm_rd_err        ),
  .ibp_rd_excl_ok           (dmi_dccm_rd_excl_ok    ),
  .ibp_rd_last              (dmi_dccm_rd_last       ),
  .ibp_rd_accept            (dmi_dccm_rd_accept     ),
  .ibp_rd_data              (dmi_dccm_rd_data       ),

  .ibp_wr_done              (dmi_dccm_wr_done       ),
  .ibp_wr_excl_okay         (dmi_dccm_wr_excl_okay  ),
  .ibp_wr_err               (dmi_dccm_wr_err        ),
  .ibp_wr_resp_accept       (dmi_dccm_wr_resp_accept),
  ///////// DCCM DMI AHB5 initiator /////////////////////////////////
  .ahb_prio                 (dccm_ahb_prio),
  .ahb_hlock                (dccm_ahb_hlock),
  .ahb_hexcl                (dccm_ahb_hexcl),
  .ahb_hmaster              (dccm_ahb_hmaster),

  .ahb_hsel                 (dccm_ahb_hsel),
  .ahb_htrans               (dccm_ahb_htrans),
  .ahb_hwrite               (dccm_ahb_hwrite),
  .ahb_haddr                (dccm_ahb_haddr),
  .ahb_hsize                (dccm_ahb_hsize),
  .ahb_hwstrb               (dccm_ahb_hwstrb),
  .ahb_hburst               (dccm_ahb_hburst),
  .ahb_hprot                (dccm_ahb_hprot),
  .ahb_hnonsec              (dccm_ahb_hnonsec),
  .ahb_hwdata               (dccm_ahb_hwdata),
  .ahb_hready               (dccm_ahb_hready),
  .ahb_hrdata               (dccm_ahb_hrdata),
  .ahb_hresp                (dccm_ahb_hresp),
  .ahb_hexokay              (dccm_ahb_hexokay),
  .ahb_hready_resp          (dccm_ahb_hready_resp),
 ///////// DCCM DMI AHB5 bus protection signals /////////////////////////////////////
 //	

  .ahb_haddrchk             (dccm_ahb_haddrchk),
  .ahb_htranschk            (dccm_ahb_htranschk),
  .ahb_hctrlchk1            (dccm_ahb_hctrlchk1),
  .ahb_hctrlchk2            (dccm_ahb_hctrlchk2),
  .ahb_hwstrbchk            (dccm_ahb_hwstrbchk),
  .ahb_hprotchk             (dccm_ahb_hprotchk),
  .ahb_hreadychk            (dccm_ahb_hreadychk),
  .ahb_hrespchk             (dccm_ahb_hrespchk),
  .ahb_hready_respchk       (dccm_ahb_hready_respchk),
  .ahb_hselchk              (dccm_ahb_hselchk),
  .ahb_hrdatachk            (dccm_ahb_hrdatachk),
  .ahb_hwdatachk            (dccm_ahb_hwdatachk),
  .ahb_fatal_err            (dccm_ahb_fatal_err_comb),
  .dmi_clock_enable_nxt     (dccm_dmi_clock_enable_nxt),
  .dmi_clock_enable         (ar_clock_enable_r),
  .biu_dmi_idle             (biu_dccm_dmi_idle),
  .clk                      (clk              ),
  .rst_a                    (rst_a      )
);

rl_mmio_ahb2ibp u_rl_mmio_ahb2ibp (

  .ibp_cmd_prio             (dmi_mmio_cmd_prio      ),

  .ibp_cmd_valid            (dmi_mmio_cmd_valid     ),
  .ibp_cmd_cache            (dmi_mmio_cmd_cache     ),
  .ibp_cmd_burst_size       (dmi_mmio_cmd_burst_size),
  .ibp_cmd_read             (dmi_mmio_cmd_read      ),
  .ibp_cmd_accept           (dmi_mmio_cmd_accept    ),
  .ibp_cmd_addr             (dmi_mmio_cmd_addr      ),
  .ibp_cmd_excl             (dmi_mmio_cmd_excl      ),
  .ibp_cmd_data_size        (dmi_mmio_cmd_data_size ),
  .ibp_cmd_prot             (dmi_mmio_cmd_prot      ),

  .ibp_wr_valid             (dmi_mmio_wr_valid      ),
  .ibp_wr_last              (dmi_mmio_wr_last       ),
  .ibp_wr_accept            (dmi_mmio_wr_accept     ),
  .ibp_wr_mask              (dmi_mmio_wr_mask       ),
  .ibp_wr_data              (dmi_mmio_wr_data       ),

  .ibp_rd_valid             (dmi_mmio_rd_valid      ),
  .ibp_rd_err               (dmi_mmio_rd_err        ),
  .ibp_rd_excl_ok           (dmi_mmio_rd_excl_ok    ),
  .ibp_rd_last              (dmi_mmio_rd_last       ),
  .ibp_rd_accept            (dmi_mmio_rd_accept     ),
  .ibp_rd_data              (dmi_mmio_rd_data       ),

  .ibp_wr_done              (dmi_mmio_wr_done       ),
  .ibp_wr_excl_okay         (dmi_mmio_wr_excl_okay  ),
  .ibp_wr_err               (dmi_mmio_wr_err        ),
  .ibp_wr_resp_accept       (dmi_mmio_wr_resp_accept),
  ///////// MMIO DMI AHB5 initiator /////////////////////////////////
  .ahb_prio                 (mmio_ahb_prio),
  .ahb_hlock                (mmio_ahb_hlock),
  .ahb_hexcl                (mmio_ahb_hexcl),
  .ahb_hmaster              (mmio_ahb_hmaster),

  .ahb_hsel                 (mmio_ahb_hsel),
  .ahb_htrans               (mmio_ahb_htrans),
  .ahb_hwrite               (mmio_ahb_hwrite),
  .ahb_haddr                (mmio_ahb_haddr),
  .ahb_hsize                (mmio_ahb_hsize),
  .ahb_hwstrb               (mmio_ahb_hwstrb),
  .ahb_hburst               (mmio_ahb_hburst),
  .ahb_hprot                (mmio_ahb_hprot),
  .ahb_hnonsec              (mmio_ahb_hnonsec),
  .ahb_hwdata               (mmio_ahb_hwdata),
  .ahb_hready               (mmio_ahb_hready),
  .ahb_hrdata               (mmio_ahb_hrdata),
  .ahb_hresp                (mmio_ahb_hresp),
  .ahb_hexokay              (mmio_ahb_hexokay),
  .ahb_hready_resp          (mmio_ahb_hready_resp),
 ///////// MMIO DMI AHB5 bus protection signals /////////////////////////////////////
 //	

  .ahb_haddrchk             (mmio_ahb_haddrchk),
  .ahb_htranschk            (mmio_ahb_htranschk),
  .ahb_hctrlchk1            (mmio_ahb_hctrlchk1),
  .ahb_hctrlchk2            (mmio_ahb_hctrlchk2),
  .ahb_hwstrbchk            (mmio_ahb_hwstrbchk),
  .ahb_hprotchk             (mmio_ahb_hprotchk),
  .ahb_hreadychk            (mmio_ahb_hreadychk),
  .ahb_hrespchk             (mmio_ahb_hrespchk),
  .ahb_hready_respchk       (mmio_ahb_hready_respchk),
  .ahb_hselchk              (mmio_ahb_hselchk),
  .ahb_hrdatachk            (mmio_ahb_hrdatachk),
  .ahb_hwdatachk            (mmio_ahb_hwdatachk),
  .ahb_fatal_err            (mmio_ahb_fatal_err_comb),
  .dmi_clock_enable_nxt     (mmio_dmi_clock_enable_nxt),
  .dmi_clock_enable         (ar_clock_enable_r),
  .biu_mmio_dmi_idle        (biu_mmio_dmi_idle),
  .clk                      (clk              ),
  .rst_a                    (rst_a      )
);

assign biu_idle = 1'b1
                  & biu_cbu_idle
                  & biu_dbu_per_idle
                  & biu_iccm_dmi_idle
                  & biu_dccm_dmi_idle
	              & biu_mmio_idle
                  & biu_mmio_dmi_idle
                  ;


assign sr_core_state[23]    = 1'b0;
assign sr_core_state[22:17] = mcause_r;
assign sr_core_state[16]    = 1'b0;
assign sr_core_state[15:14] = priv_level_r;
assign sr_core_state[13]    = dmp_st_pending;
assign sr_core_state[12]    = 1'b0;
assign sr_core_state[11]    = core_rf_busy;
assign sr_core_state[10]    = exu_busy;
assign sr_core_state[9]     = 1'b0;
assign sr_core_state[8]     = mpy_busy;
assign sr_core_state[7]     = 1'b0;
assign sr_core_state[6:5]   = 2'b0;
assign sr_core_state[4]     = dmp_per_busy;
assign sr_core_state[3]     = 1'b0;
assign sr_core_state[2]     = dmp_uncached_busy;
assign sr_core_state[1]     = (~ifu_idle_r);
assign sr_core_state[0]     = 1'b0;

rl_soft_reset_aux u_rl_soft_reset_aux(
  .aux_write                      (sr_aux_write),
  .aux_wdata                      (sr_aux_wdata),
  .aux_ren                        (sr_aux_ren),
  .aux_raddr                      (sr_aux_raddr),
  .aux_wen                        (sr_aux_wen),
  .aux_waddr                      (sr_aux_waddr),
  .aux_rdata                      (sr_aux_rdata),
  .aux_illegal                    (sr_aux_illegal),
  .sr_dbg_cache_rst_disable       (sr_dbg_cache_rst_disable),
  .biu_idle                       (biu_idle),
  .soft_reset_prepare             (soft_reset_prepare),
  .soft_reset_ready_r             (soft_reset_ready),
  .is_soft_reset                  (is_soft_reset         ),
  .cpu_in_reset_state             (cpu_in_reset_state    ),
  .ar_pc_r                        (sr_ar_pc),
  .mstatus                        (sr_mstatus),
  .db_active_r                    (sr_db_active),
  .core_state                     (sr_core_state),
  .clk                            (clk),
  .rst_a                          (rst_hard)
);



endmodule // rl_core

