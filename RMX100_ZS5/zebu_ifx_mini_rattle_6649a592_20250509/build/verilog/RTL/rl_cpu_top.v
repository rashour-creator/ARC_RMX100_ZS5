// Library ARCv5EM-3.5.999999999

`include "defines.v"

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
`include "ifu_defines.v"
`include "dmp_defines.v"
`include "clint_defines.v"
`include "mpy_defines.v"
`include "rv_safety_exported_defines.v"
// Set simulation timescale
//
`include "const.def"

module rl_cpu_top (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                       clk,                // clock signal
  input                       tm_clk_enable_sync, // Bit0 of timer ref clock synced to core clock
  input                       rst_synch_r,              // Global Synchronized async reset signal
  input                       rst_cpu_req_synch_r,      // Synchronous hard reset request signal
  output                      rst_cpu_ack,             // reset acknowledge signal
  output                      cpu_rst_gated,           // Generated reset signal
  output                      cpu_clk_gated,           // Generated clock signal
// spyglass disable_block W240
// SMD: Inputs declared but not read.
// SJ : After MMIO condition finalized this will be removed
  input                       test_mode,          // test mode for DfT
  input                       LBIST_EN,

  ////////// External Halt Request Interface /////////////////////////////////
  //
  input                       dm2arc_halt_req_synch_r,  // sync Req to Halt core
  input                       dm2arc_run_req_synch_r,   // sync Req to unHalt core
  output                      arc2dm_halt_ack,    // Core has Halted cleanly
  output                      arc2dm_run_ack,     // Core has unHalted
  input                       dm2arc_hartreset_synch_r,
  input                       dm2arc_hartreset2_synch_r,
  input                       ndmreset_synch_r,
  input                       dm2arc_havereset_ack_synch_r,
  input                       dm2arc_halt_on_reset_synch_r,
  output reg                  arc2dm_havereset_a,

  ////////// Relax privilege for debug access ////////////////////////////////
  //
  input                       dm2arc_relaxedpriv_synch_r, // relax privilege for debug access


  ////////// Interface to the Debug module (BVCI target) /////////////////////
  //
  output                      hart_unavailable,
//  output                      dbg_tf_r,

//  output                      debug_reset,        // Reset from debug host



  ////////// AHB5 initiator ////////////////////////////////////////////////
  //
  output                      ahb_hmastlock,
  output                      ahb_hexcl,
  output [3:0]                ahb_hmaster,
  output [`AUSER_RANGE]       ahb_hauser,
  output                      ahb_hwrite,
  output [`ADDR_RANGE]        ahb_haddr,
  output [1:0]                ahb_htrans,
  output [2:0]                ahb_hsize,
  output [2:0]                ahb_hburst,
  output [3:0]                ahb_hwstrb,
  output [6:0]                ahb_hprot,
  output                      ahb_hnonsec,
  input                       ahb_hready,
  input                       ahb_hresp,
  input                       ahb_hexokay,
  input [`DATA_RANGE]         ahb_hrdata,
  output [`DATA_RANGE]        ahb_hwdata,

 ///////// AHB5 bus protection signals /////////////////////////////////////
 //
  output [`AUSER_PTY_RANGE]   ahb_hauserchk,
  output [3:0]                ahb_haddrchk,
  output                      ahb_htranschk,
  output                      ahb_hctrlchk1,      // Parity of ahb_hburst, ahb_hmastlock, ahb_hwrite, ahb_hsize, ahb_hnonsec
  output                      ahb_hctrlchk2,      // Parity of ahb_hexcl, ahb_hmaster
  output                      ahb_hprotchk,
  output                      ahb_hwstrbchk,
  input                       ahb_hreadychk,
  input                       ahb_hrespchk,       // Parity of ahb_hresp, ahb_hexokay
  input  [3:0]                ahb_hrdatachk,
  output [3:0]                ahb_hwdatachk,

  output                      ahb_fatal_err,

  ///////// PER AHB5 initiator ////////////////////////////////////////
  output                        dbu_per_ahb_hmastlock,
  output                        dbu_per_ahb_hexcl,
  output [3:0]                  dbu_per_ahb_hmaster,
  output [`AUSER_RANGE]         dbu_per_ahb_hauser,
  output                        dbu_per_ahb_hwrite,
  output [`ADDR_RANGE]          dbu_per_ahb_haddr,
  output [1:0]                  dbu_per_ahb_htrans,
  output [2:0]                  dbu_per_ahb_hsize,
  output [2:0]                  dbu_per_ahb_hburst,
  output [3:0]                  dbu_per_ahb_hwstrb,
  output [6:0]                  dbu_per_ahb_hprot,
  output                        dbu_per_ahb_hnonsec,
  input                         dbu_per_ahb_hready,
  input                         dbu_per_ahb_hresp,
  input                         dbu_per_ahb_hexokay,
  input [`DATA_RANGE]           dbu_per_ahb_hrdata,
  output [`DATA_RANGE]          dbu_per_ahb_hwdata,
 ///////// PER AHB5 bus protection signals /////////////////////////////////////
 //	
  output [`AUSER_PTY_RANGE]     dbu_per_ahb_hauserchk,
  output [3:0]                  dbu_per_ahb_haddrchk,
  output                        dbu_per_ahb_htranschk,
  output                        dbu_per_ahb_hctrlchk1,      // Parity of dbu_per_ahb_hburst, dbu_per_ahb_hmastlock, dbu_per_ahb_hwrite, dbu_per_ahb_hsize, dbu_per_ahb_hnonsec
  output                        dbu_per_ahb_hctrlchk2,      // Parity of dbu_per_ahb_hexcl, dbu_per_ahb_hmaster
  output                        dbu_per_ahb_hprotchk,
  output                        dbu_per_ahb_hwstrbchk,
  input                         dbu_per_ahb_hreadychk,
  input                         dbu_per_ahb_hrespchk,       // Parity of dbu_per_ahb_hresp, dbu_per_ahb_hexokay
  input  [3:0]                  dbu_per_ahb_hrdatachk,
  output [3:0]                  dbu_per_ahb_hwdatachk,

  output                        dbu_per_ahb_fatal_err,


  ///////// ICCM0/ICCM1 DMI AHB5 initiator /////////////////////////////////
  input                         iccm_ahb_prio,
  input                         iccm_ahb_hmastlock,
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
  output                        iccm_ahb_hreadyout,
 ///////// ICCM0/ICCM1 DMI AHB5 bus protection signals /////////////////////////////////////
 //	

  input  [3:0]                  iccm_ahb_haddrchk,
  input                         iccm_ahb_htranschk,
  input                         iccm_ahb_hctrlchk1,         // Parity of iccm_ahb_hburst, iccm_ahb_hmastlock, iccm_ahb_hwrite, iccm_ahb_hsize, iccm_ahb_hnonsec
  input                         iccm_ahb_hctrlchk2,         // Parity of iccm_ahb_hexcl, iccm_ahb_hmaster
  input                         iccm_ahb_hwstrbchk,
  input                         iccm_ahb_hprotchk,
  input                         iccm_ahb_hreadychk,
  output                        iccm_ahb_hrespchk,          // Parity of iccm_ahb_hresp, iccm_ahb_hexokay
  output                        iccm_ahb_hreadyoutchk,
  input                         iccm_ahb_hselchk,
  output [3:0]                  iccm_ahb_hrdatachk,
  input  [3:0]                  iccm_ahb_hwdatachk,
  output                        iccm_ahb_fatal_err,

  ///////// DCCM DMI AHB5 initiator ////////////////////////////////////////
  input                         dccm_ahb_prio,
  input                         dccm_ahb_hmastlock,
  input                         dccm_ahb_hexcl,
  input  [3:0]                  dccm_ahb_hmaster,

  input  [`DCCM_DMI_NUM-1:0]    dccm_ahb_hsel,
  input  [1:0]                  dccm_ahb_htrans,
  input                         dccm_ahb_hwrite,
  input  [`ADDR_RANGE]          dccm_ahb_haddr,
  input  [2:0]                  dccm_ahb_hsize,
  input  [3:0]                  dccm_ahb_hwstrb,
  input                         dccm_ahb_hnonsec,
  input  [2:0]                  dccm_ahb_hburst,
  input  [6:0]                  dccm_ahb_hprot,
  input  [`DCCM_DMI_DATA_RANGE] dccm_ahb_hwdata,
  input                         dccm_ahb_hready,
  output [`DCCM_DMI_DATA_RANGE] dccm_ahb_hrdata,
  output                        dccm_ahb_hresp,
  output                        dccm_ahb_hexokay,
  output                        dccm_ahb_hreadyout,
 ///////// DCCM DMI AHB5 bus protection signals /////////////////////////////////////
 //

  input  [3:0]                  dccm_ahb_haddrchk,
  input                         dccm_ahb_htranschk,
  input                         dccm_ahb_hctrlchk1,         // Parity of dccm_ahb_hburst, dccm_ahb_hmastlock, dccm_ahb_hwrite, dccm_ahb_hsize, dccm_ahb_hnonsec
  input                         dccm_ahb_hctrlchk2,         // Parity of dccm_ahb_hexcl, dccm_ahb_hmaster
  input                         dccm_ahb_hwstrbchk,
  input                         dccm_ahb_hprotchk,
  input                         dccm_ahb_hreadychk,
  output                        dccm_ahb_hrespchk,          // Parity of dccm_ahb_hresp, dccm_ahb_hexokay
  output                        dccm_ahb_hreadyoutchk,
  input                         dccm_ahb_hselchk,
  output [3:0]                  dccm_ahb_hrdatachk,
  input  [3:0]                  dccm_ahb_hwdatachk,
  output                        dccm_ahb_fatal_err,

  ///////// MMIO AHB5 target interface ////////////////////////////////////////
  input                         mmio_ahb_prio,
  input                         mmio_ahb_hmastlock,
  input                         mmio_ahb_hexcl,
  input  [3:0]                  mmio_ahb_hmaster,

  input                         mmio_ahb_hsel,
  input  [1:0]                  mmio_ahb_htrans,
  input                         mmio_ahb_hwrite,
  input  [`ADDR_RANGE]          mmio_ahb_haddr,
  input  [2:0]                  mmio_ahb_hsize,
  input  [3:0]                  mmio_ahb_hwstrb,
  input                         mmio_ahb_hnonsec,
  input  [2:0]                  mmio_ahb_hburst,
  input  [6:0]                  mmio_ahb_hprot,
  input  [`DATA_RANGE]          mmio_ahb_hwdata,
  input                         mmio_ahb_hready,
  output [`DATA_RANGE]          mmio_ahb_hrdata,
  output                        mmio_ahb_hresp,
  output                        mmio_ahb_hexokay,
  output                        mmio_ahb_hreadyout,
 ///////// MMIO AHB5 target bus protection signals ////////////////////////////
 //	

  input  [3:0]                  mmio_ahb_haddrchk,
  input                         mmio_ahb_htranschk,
  input                         mmio_ahb_hctrlchk1,         // Parity of mmio_ahb_hburst, mmio_ahb_hmastlock, mmio_ahb_hwrite, mmio_ahb_hsize, mmio_ahb_hnonsec
  input                         mmio_ahb_hctrlchk2,         // Parity of mmio_ahb_hexcl, mmio_ahb_hmaster
  input                         mmio_ahb_hwstrbchk,
  input                         mmio_ahb_hprotchk,
  input                         mmio_ahb_hreadychk,
  output                        mmio_ahb_hrespchk,          // Parity of mmio_ahb_hresp, mmio_ahb_hexokay
  output                        mmio_ahb_hreadyoutchk,
  input                         mmio_ahb_hselchk,
  output [3:0]                  mmio_ahb_hrdatachk,
  input  [3:0]                  mmio_ahb_hwdatachk,
  output                        mmio_ahb_fatal_err,

 ///////// External MMIO base input ////////////////////////////////////////////////
 //
  input [11:0]                  mmio_base_in,          // Input pins defining MMIO base[31:20]

 ///////// Reset PC ////////////////////////////////////////////////////////////////
 //
 input  [21:0]                  reset_pc_in,           // Input pins  defining RESET_PC[31:10]

 ///////// Resumable NMI ///////////////////////////////////////////////////////////
 //
 input                          rnmi_synch_r,

  output  esrams_iccm0_clk,
  output [`ICCM0_DRAM_RANGE] esrams_iccm0_din,
  output [`ICCM0_ADR_RANGE] esrams_iccm0_addr,
  output  esrams_iccm0_cs,
  output  esrams_iccm0_we,
  output [`ICCM_MASK_RANGE] esrams_iccm0_wem,
  input  [`ICCM0_DRAM_RANGE] esrams_iccm0_dout,


  output  esrams_dccm_even_clk,
  output [`DCCM_DRAM_RANGE] esrams_dccm_din_even,
  output [`DCCM_ADR_RANGE] esrams_dccm_addr_even,
  output  esrams_dccm_cs_even,
  output  esrams_dccm_we_even,
  output [`DCCM_MASK_RANGE] esrams_dccm_wem_even,
  input  [`DCCM_DRAM_RANGE] esrams_dccm_dout_even,
  output  esrams_dccm_odd_clk,
  output [`DCCM_DRAM_RANGE] esrams_dccm_din_odd,
  output [`DCCM_ADR_RANGE] esrams_dccm_addr_odd,
  output  esrams_dccm_cs_odd,
  output  esrams_dccm_we_odd,
  output [`DCCM_MASK_RANGE] esrams_dccm_wem_odd,
  input  [`DCCM_DRAM_RANGE] esrams_dccm_dout_odd,
  ////////// SRAM IC TAG interface ////////////////////////////////////////////////
  output  esrams_ic_tag_mem_clk,
  output [`IC_TAG_SET_RANGE] esrams_ic_tag_mem_din,
  output [`IC_IDX_RANGE] esrams_ic_tag_mem_addr,
  output  esrams_ic_tag_mem_cs,
  output  esrams_ic_tag_mem_we,
  output [`IC_TAG_SET_RANGE] esrams_ic_tag_mem_wem,
  input  [`IC_TAG_SET_RANGE] esrams_ic_tag_mem_dout,
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  output  esrams_ic_data_mem_clk,
  output [`IC_DATA_SET_RANGE] esrams_ic_data_mem_din,
  output [`IC_DATA_ADR_RANGE] esrams_ic_data_mem_addr,
  output  esrams_ic_data_mem_cs,
  output  esrams_ic_data_mem_we,
  output [`IC_DATA_SET_RANGE] esrams_ic_data_mem_wem,
  input  [`IC_DATA_SET_RANGE] esrams_ic_data_mem_dout,

  output  esrams_clk,
  output  esrams_ls,
  input  [1:0]               ext_trig_output_accept,
  input  [15:0]              ext_trig_in,
  output [1:0]               ext_trig_output_valid,
  output                     high_prio_ras,

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
  output [1:0]                   dr_secure_trig_iso_err,
  output                         sfty_mem_sbe_err,
  output                         sfty_mem_dbe_err,
  output                         sfty_mem_adr_err,
  output                         sfty_mem_sbe_overflow,
  //
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
  ////////// Watchdog external interface /////////////////////////////////////
  output                      wdt_reset0,
  output                      reg_wr_en0,
  input                       wdt_clk_enable_sync,    // Bit0 of wdt clock synced to core clock
  output                      wdt_feedback_bit,       // Bit1 of core clock feedback to wdt clock

  ////////// DMSI IF Signals ////////////////////////////////////////////////
  //
  input                                dmsi_valid,
  input   [`CNTXT_IDX_RANGE]           dmsi_context,
  input   [`EIID_IDX_RANGE]            dmsi_eiid,
  input                                dmsi_domain,
  output                               dmsi_rdy,
  input                                dmsi_valid_chk,
  input   [5:0]                        dmsi_data_edc,
  output                               dmsi_rdy_chk,

  output                               sfty_dmsi_tgt_e2e_err,
// spyglass enable_block W240

  ////////// IBP debug interface //////////////////////////////////////////
  // Command channel
  input  						       dbg_ibp_cmd_valid,  // valid command
  input  						       dbg_ibp_cmd_read,   // read high, write low
  input       [`DBG_ADDR_RANGE]        dbg_ibp_cmd_addr,   //
  output      					       dbg_ibp_cmd_accept, //
  input  			[3:0]  		       dbg_ibp_cmd_space,  // type of access

  // read channel
  output      					       dbg_ibp_rd_valid,   // valid read
  input  						       dbg_ibp_rd_accept,  // rd output accepted by DM
  output      					       dbg_ibp_rd_err,     //
  output      [`DBG_DATA_RANGE]        dbg_ibp_rd_data,    // rd output

  // write channel
  input  						       dbg_ibp_wr_valid,   //
  output      					       dbg_ibp_wr_accept,  //
  input       [`DBG_DATA_RANGE]        dbg_ibp_wr_data,    //
  input       [3:0] 	               dbg_ibp_wr_mask,    //
  output      					       dbg_ibp_wr_done,    //
  output      					       dbg_ibp_wr_err,     //
  input                                dbg_ibp_wr_resp_accept,

  //////////  World Guard  Interface  /////////////////////////////////////////
  //
  input   [`WID_RANGE]           wid_rlwid,
  input   [63:0]                 wid_rwiddeleg,

  //////////  Soft  Reset  Interface  /////////////////////////////////////////
  //
  input                       soft_reset_prepare_synch_r,
  input                       soft_reset_req_synch_r,
  output                      soft_reset_ready,  // core is ready
  output                      soft_reset_ack,    // soft reset acknowledge signal
  output reg                  cpu_in_reset_state,


  input                      rst_init_disable_synch_r,

  // clock counter output to DCLS
  output  [1:0]                    iccm0_gclk_cnt,
  output  [1:0]                    dccm_even_gclk_cnt,
  output  [1:0]                    dccm_odd_gclk_cnt,
  output  [1:0]                    ic_tag_mem_gclk_cnt,
  output  [1:0]                    ic_data_mem_gclk_cnt,
  output     [1:0]                     gclk_cnt,

  // Backdoor CCM identification.
  input   [7:0]              arcnum /* verilator public_flat */,


  ////////// Machine Halt / Sleep Status//////////////////////////////////////
  //
  output                      sys_halt_r /* verilator public_flat */,
  output                      sys_sleep_r,
  output                      critical_error,
  output  [`EXT_SMODE_RANGE]  sys_sleep_mode_r


);

wire    ls;
assign  ls = 1'b0;


// localparam bit ls = 1'b0; //@@ make it synthesizable
// Wires
//
wire    [1:0]   priv_level_r;
wire  iccm0_clk;
wire [`ICCM0_DRAM_RANGE] iccm0_din;
wire [`ICCM0_ADR_RANGE] iccm0_addr;
wire  iccm0_cs;
wire  iccm0_we;
wire [`ICCM_MASK_RANGE] iccm0_wem;
wire [`ICCM0_DRAM_RANGE] iccm0_dout;

assign esrams_iccm0_clk = iccm0_clk;
assign esrams_iccm0_din = iccm0_din;
assign esrams_iccm0_addr = iccm0_addr;
assign esrams_iccm0_cs = iccm0_cs;
assign esrams_iccm0_we = iccm0_we;
assign esrams_iccm0_wem = iccm0_wem;
assign iccm0_dout = esrams_iccm0_dout;



wire  dccm_even_clk;
wire [`DCCM_DRAM_RANGE] dccm_din_even;
wire [`DCCM_ADR_RANGE] dccm_addr_even;
wire  dccm_cs_even;
wire  dccm_we_even;
wire [`DCCM_MASK_RANGE] dccm_wem_even;
wire [`DCCM_DRAM_RANGE] dccm_dout_even;
wire  dccm_odd_clk;
wire [`DCCM_DRAM_RANGE] dccm_din_odd;
wire [`DCCM_ADR_RANGE] dccm_addr_odd;
wire  dccm_cs_odd;
wire  dccm_we_odd;
wire [`DCCM_MASK_RANGE] dccm_wem_odd;
wire [`DCCM_DRAM_RANGE] dccm_dout_odd;

assign esrams_dccm_even_clk = dccm_even_clk;
assign esrams_dccm_din_even = dccm_din_even;
assign esrams_dccm_addr_even = dccm_addr_even;
assign esrams_dccm_cs_even = dccm_cs_even;
assign esrams_dccm_we_even = dccm_we_even;
assign esrams_dccm_wem_even = dccm_wem_even;
assign dccm_dout_even = esrams_dccm_dout_even;
assign esrams_dccm_odd_clk = dccm_odd_clk;
assign esrams_dccm_din_odd = dccm_din_odd;
assign esrams_dccm_addr_odd = dccm_addr_odd;
assign esrams_dccm_cs_odd = dccm_cs_odd;
assign esrams_dccm_we_odd = dccm_we_odd;
assign esrams_dccm_wem_odd = dccm_wem_odd;
assign dccm_dout_odd = esrams_dccm_dout_odd;

  ////////// SRAM IC TAG interface ////////////////////////////////////////////////
wire  ic_tag_mem_clk;
wire [`IC_TAG_SET_RANGE] ic_tag_mem_din;
wire [`IC_IDX_RANGE] ic_tag_mem_addr;
wire  ic_tag_mem_cs;
wire  ic_tag_mem_we;
wire [`IC_TAG_SET_RANGE] ic_tag_mem_wem;
wire [`IC_TAG_SET_RANGE] ic_tag_mem_dout;
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
wire  ic_data_mem_clk;
wire [`IC_DATA_SET_RANGE] ic_data_mem_din;
wire [`IC_DATA_ADR_RANGE] ic_data_mem_addr;
wire  ic_data_mem_cs;
wire  ic_data_mem_we;
wire [`IC_DATA_SET_RANGE] ic_data_mem_wem;
wire [`IC_DATA_SET_RANGE] ic_data_mem_dout;
  ////////// SRAM IC TAG interface ////////////////////////////////////////////////
assign esrams_ic_tag_mem_clk = ic_tag_mem_clk;
assign esrams_ic_tag_mem_din = ic_tag_mem_din;
assign esrams_ic_tag_mem_addr = ic_tag_mem_addr;
assign esrams_ic_tag_mem_cs = ic_tag_mem_cs;
assign esrams_ic_tag_mem_we = ic_tag_mem_we;
assign esrams_ic_tag_mem_wem = ic_tag_mem_wem;
assign ic_tag_mem_dout = esrams_ic_tag_mem_dout;
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
assign esrams_ic_data_mem_clk = ic_data_mem_clk;
assign esrams_ic_data_mem_din = ic_data_mem_din;
assign esrams_ic_data_mem_addr = ic_data_mem_addr;
assign esrams_ic_data_mem_cs = ic_data_mem_cs;
assign esrams_ic_data_mem_we = ic_data_mem_we;
assign esrams_ic_data_mem_wem = ic_data_mem_wem;
assign ic_data_mem_dout = esrams_ic_data_mem_dout;


assign esrams_clk = clk;
assign esrams_ls = ls;

wire                          ibp_mmio_cmd_valid;
wire  [3:0]                   ibp_mmio_cmd_cache;
wire                          ibp_mmio_cmd_burst_size;
wire                          ibp_mmio_cmd_read;
wire                          ibp_mmio_cmd_aux;
wire                          ibp_mmio_cmd_accept;
wire  [`ADDR_RANGE]           ibp_mmio_cmd_addr;
wire                          ibp_mmio_cmd_excl;
wire  [5:0]                   ibp_mmio_cmd_atomic;
wire  [2:0]                   ibp_mmio_cmd_data_size;
wire  [1:0]                   ibp_mmio_cmd_prot;

wire                          ibp_mmio_wr_valid;
wire                          ibp_mmio_wr_last;
wire                          ibp_mmio_wr_accept;
wire  [3:0]                   ibp_mmio_wr_mask;
wire  [31:0]                  ibp_mmio_wr_data;

wire                          ibp_mmio_rd_valid;
wire                          ibp_mmio_rd_err;
wire                          ibp_mmio_rd_excl_ok;
wire                          ibp_mmio_rd_last;
wire                          ibp_mmio_rd_accept;
wire  [31:0]                  ibp_mmio_rd_data;

wire                          ibp_mmio_wr_done;
wire                          ibp_mmio_wr_excl_okay;
wire                          ibp_mmio_wr_err;
wire                          ibp_mmio_wr_resp_accept;
wire  [63:0]                  mtime_r;
wire  [1:0]                   csr_clint_sel_ctl;      // (X1) CSR slection (01 = read, 10 = write)
wire  [11:0]                  csr_clint_sel_addr;     // (X1) CSR address

wire  [`DATA_RANGE]           clint_csr_rdata;        // (X1) CSR read data
wire                          clint_csr_illegal;      // (X1) illegal
wire                          clint_csr_unimpl;       // (X1) Invalid CSR
wire                          clint_csr_serial_sr;    // (X1) SR group flush pipe
wire                          clint_csr_strict_sr;    // (X1) SR flush pipe

wire                          csr_clint_write;        // (X2) CSR operation (01 = read, 10 = write)
wire  [11:0]                  csr_clint_waddr;        // (X2) CSR addr
wire  [`DATA_RANGE]           csr_clint_wdata;        // (X2) Write data
wire                          csr_ren_r;
wire  [7:0]                   mtopi_iid;
wire                          mtvec_mode;
wire                          trap_ack;

wire                          x2_pass;

wire                          irq_trap;              // Inetrrupt in from CLINT
wire  [7:0]                   irq_id;
wire                          msip_0;
wire [`DATA_RANGE]            mireg_clint;
wire                          mireg_clint_wen;

// @@@ Glue logic temporary added for RMX CSR interface
wire  [11:0]                  csr_irq_raddr; // A is from 1 to 11
wire  [`DATA_RANGE]           irq_csr_rdata;   // CSR read data
wire  [11:0]                  csr_irq_waddr; // A is from 1 to 11
wire                          csr_irq_wr;    // CSR write request

assign csr_irq_raddr = csr_clint_sel_addr;
assign clint_csr_rdata = irq_csr_rdata;
assign clint_csr_serial_sr = 1'b0;
assign clint_csr_strict_sr = 1'b0;
assign csr_irq_waddr = csr_clint_waddr;
assign csr_irq_wr = csr_clint_write & x2_pass;

wire                          db_clock_enable_nxt;
wire                          is_soft_reset;
wire                          mtip_0;
wire [`DATA_RANGE]            miselect_r;

wire  [1:0]                   csr_wdt_sel_ctl;      // (X1) CSR slection (01 = read, 10 = write)
wire  [11:0]                  csr_wdt_sel_addr;     // (X1) CSR address

wire  [`DATA_RANGE]           wdt_csr_rdata;        // (X1) CSR read data
wire                          wdt_csr_illegal;      // (X1) illegal
wire                          wdt_csr_unimpl;       // (X1) Invalid CSR
wire                          wdt_csr_serial_sr;    // (X1) SR group flush pipe
wire                          wdt_csr_strict_sr;    // (X1) SR flush pipe

wire                          csr_wdt_write;        // (X2) CSR operation (01 = read, 10 = write)
wire  [11:0]                  csr_wdt_waddr;        // (X2) CSR addr
wire  [`DATA_RANGE]           csr_wdt_wdata;        // (X2) Write data
wire                          wdt_csr_raw_hazard;

wire                          db_active;

wire                          irq_wdt;


wire                          time_ovf;
wire                          time_ovf_flag;


wire                          soft_reset_prepare;
wire                          rnmi_req;
wire                          dm2arc_halt_req;
wire                          dm2arc_run_req;
wire                          dm2arc_havereset_ack;
wire                          dm2arc_halt_on_reset;
wire                          rst_init_disable;

wire                          dmp_idle_r;
wire                          ifu_idle_r;
wire                          ar_clock_enable_r;
wire                          iccm_dmi_clock_enable_nxt;
wire                          dccm_dmi_clock_enable_nxt;
wire                          mmio_dmi_clock_enable_nxt;
wire                          ic_idle_ack;
wire                          ifu_issue;
wire  [`FU_1H_RANGE]          ifu_pd_fu;
wire                          mpy_x1_valid;
wire                          mpy_x2_valid;
wire                          mpy_x3_valid_r;
wire                          clk_wdt;
wire                          clk_gated;
wire                          clk_mpy;

wire                        pct_unit_enable;
wire                        clk_hpm;       // clk   for PCT
wire                        hpm_int_overflow_rising;
wire                        hpm_int_overflow_r;

//////////////////////////////////////////////////////////////////////////////
//
// Module instantiation
//
//////////////////////////////////////////////////////////////////////////////


  // Dummy for now until these are gone.
  wire                          dbg_cmdval=0;            // cmdval from JTAG
  wire                          dbg_cmdack;            // BVCI cmd acknowledge
  wire       [`DBG_ADDR_RANGE]  dbg_address=0;           // address from JTAG
  wire       [`DBG_BE_RANGE]    dbg_be=0;                // be| from JTAG
  wire       [`DBG_CMD_RANGE]   dbg_cmd=0;               // cmd from JTAG
  wire       [`DBG_DATA_RANGE]  dbg_wdata=0;             // wdata from JTAG
  // -- response
  wire                          dbg_rspack=0;            // rspack from JTAG
  wire                         dbg_rspval;            // BVCI response valid
  wire     [`DBG_DATA_RANGE]   dbg_rdata;             // 32-bit BVCI data to host
  wire                         dbg_reop;              // BVCI response EOP
  wire                         dbg_rerr;              // BVCI response error

rl_clock_ctrl u_rl_clock_ctrl (
  ////////// State of the core ///////////////////////////////////////////////
  //
  .sys_sleep_r                      (sys_sleep_r),         // sleeping (arch_sleep_r)
  .sys_sleep_mode_r                 (sys_sleep_mode_r),         // sleep mode
  .sys_halt_r                       (sys_halt_r),         // halted
  .arc_halt_req                     (dm2arc_halt_req),         // synchr halt req
  .arc_halt_ack                     (arc2dm_halt_ack),         // synchr halt ack
  .arc_run_req                      (dm2arc_run_req),         // synchr run req
  .arc_run_ack                      (arc2dm_run_ack),         // synchr run ack
  .dmp_idle_r                       (dmp_idle_r),
  .ifu_idle_r                       (ifu_idle_r),
  .rnmi_req                         (rnmi_req),
    ////////// arch clk enable signal //////////////////////////////////////////
    //
  .ar_clock_enable_r                (ar_clock_enable_r),
    ////////// DMI enable signal ///////////////////////////////////////////////
    //
  .iccm_dmi_clock_enable_nxt        (iccm_dmi_clock_enable_nxt),
  .dccm_dmi_clock_enable_nxt        (dccm_dmi_clock_enable_nxt),
  .mmio_dmi_clock_enable_nxt        (mmio_dmi_clock_enable_nxt),
    ////////// Debug enable signal /////////////////////////////////////////////
    //
  .db_clock_enable_nxt              (db_clock_enable_nxt),
    ////////// Cache busy signals //////////////////////////////////////////////
    //
  .ic_idle_ack                      (ic_idle_ack),
    ////////// IRQ preemption signal to wake up a sleeping core ///////////////
    //
  .irq_trap                         (irq_trap),
  .ifu_pd_fu                        (ifu_pd_fu),
  .ifu_issue                        (ifu_issue),
  .mpy_x1_valid                     (mpy_x1_valid),
  .mpy_x2_valid                     (mpy_x2_valid),
  .mpy_x3_pending                   (mpy_x3_valid_r),

    ///////// Outputs of the architectural clock gates /////////////////////////
    //
  .clk_wdt                          (clk_wdt),
  .pct_unit_enable                  (pct_unit_enable),
  .clk_hpm                          (clk_hpm),
  .hpm_int_overflow_rising          (hpm_int_overflow_rising),
  .time_ovf_flag                    (time_ovf_flag),                   
  .clk_gated                        (clk_gated),
  .clk_mpy                          (clk_mpy),

    ////////// General input signals ///////////////////////////////////////////
    //
  .clk                              (cpu_clk_gated),               // Ungated clock

  .iccm0_clk	(iccm0_clk),
  .iccm0_gclk_cnt                   (iccm0_gclk_cnt),


  .dccm_even_clk	(dccm_even_clk),
  .dccm_odd_clk	(dccm_odd_clk),
  .dccm_even_gclk_cnt               (dccm_even_gclk_cnt),
  .dccm_odd_gclk_cnt                (dccm_odd_gclk_cnt),

  .ic_tag_mem_clk	(ic_tag_mem_clk),
  .ic_data_mem_clk	(ic_data_mem_clk),
  .ic_tag_mem_gclk_cnt              (ic_tag_mem_gclk_cnt),
  .ic_data_mem_gclk_cnt             (ic_data_mem_gclk_cnt),

  .gclk_cnt                         (gclk_cnt),
  .rst_a                            (cpu_rst_gated)              // Synchronized async reset
);

//reset ctrl
wire cpu_rst_hard;
wire is_dm_rst;
// spyglass disable_block W402b
// SMD: Asynchronous set/reset signal is not an input to the module
// SJ : Intended to internally generate asynchronous set/reset signals
rl_reset_ctrl_wrap u_rl_reset_ctrl_wrap (
  .clk                 (clk                ),       // clock input for this reset domain
  .rst_synch_r         (rst_synch_r        ),       // Global synchronized async reset input
  .test_mode           (test_mode          ),
  .LBIST_EN            (LBIST_EN           ),
  .rst_cpu_req_synch_r (rst_cpu_req_synch_r),       // external cpu hard reset request
  .soft_reset_req_synch_r    (soft_reset_req_synch_r    ),   // external soft reset request
  .soft_reset_prepare_synch_r(soft_reset_prepare_synch_r),   // external soft reset prepare
  .dm2arc_hartreset_synch_r  (dm2arc_hartreset_synch_r  ),   // DM2ARC hard hart reset
  .dm2arc_hartreset2_synch_r (dm2arc_hartreset2_synch_r ),   // DM2ARC soft hart reset
  .ndmreset_synch_r          (ndmreset_synch_r          ),   // DM2ARC ndm reset

  .rst_cpu_ack              (rst_cpu_ack              ),    // external cpu hard reset acknowledge
  .is_dm_rst_r              (is_dm_rst                ),
  .soft_reset_ack           (soft_reset_ack           ),    // external soft reset acknowledge
  .is_soft_reset            (is_soft_reset            ),    // indicate soft reset to soft_reset_aux
  .cpu_clk_gated            (cpu_clk_gated            ),    // output clock for controlled reset domain
  .cpu_rst_hard             (cpu_rst_hard             ),    // output hard reset
  .cpu_rst_gated            (cpu_rst_gated            )     // output reset controlled reset domain
);
// spyglass enable_block W402b

`ifndef SYNTHESIS
`ifndef VERILATOR
`define SIMULATION
`endif
`endif

`ifdef SIMULATION
wire    [`DATA_RANGE]   mip_r;
wire    [`DATA_RANGE]   mie_r;
`endif

rl_core u_rl_core (
  .clk                     (cpu_clk_gated         ),
  .clk_gated               (clk_gated             ),
  .clk_mpy                 (clk_mpy               ),
  .rst_init_disable_r      (rst_init_disable      ),     // @@@

  .soft_reset_prepare      (soft_reset_prepare    ),
  .soft_reset_ready        (soft_reset_ready      ),
  .is_soft_reset           (is_soft_reset         ),
  .cpu_in_reset_state      (cpu_in_reset_state    ),
  .rst_a                   (cpu_rst_gated         ), 
  .rst_hard                (cpu_rst_hard          ),                  
  .priv_level_r            (priv_level_r          ),
  .reset_pc_in             (reset_pc_in           ),
`ifdef SIMULATION
  .mip_r                   (mip_r),
  .mie_r                   (mie_r),
`endif


  .rnmi_synch_r            (rnmi_req              ),
  .gb_sys_halt_req_r       (dm2arc_halt_req       ),
  .gb_sys_run_req_r        (dm2arc_run_req        ),
  .gb_sys_halt_ack_r       (arc2dm_halt_ack       ),
  .gb_sys_run_ack_r        (arc2dm_run_ack        ),
  .relaxedpriv             (dm2arc_relaxedpriv_synch_r  ),
  .miselect_r              (miselect_r            ),
  .mireg_clint             (mireg_clint           ),
  .mireg_clint_wen         (mireg_clint_wen       ),

  .dmp_idle_r              (dmp_idle_r            ),
  .ifu_idle_r              (ifu_idle_r            ),
  .ar_clock_enable_r       (ar_clock_enable_r     ),
  .iccm_dmi_clock_enable_nxt (iccm_dmi_clock_enable_nxt),
  .dccm_dmi_clock_enable_nxt (dccm_dmi_clock_enable_nxt),
  .mmio_dmi_clock_enable_nxt (mmio_dmi_clock_enable_nxt),
  .db_clock_enable_nxt     (db_clock_enable_nxt   ),
  .ic_idle_ack             (ic_idle_ack           ),
  .ifu_issue               (ifu_issue             ),
  .ifu_pd_fu               (ifu_pd_fu             ),
  .mpy_x1_valid            (mpy_x1_valid           ),
  .mpy_x2_valid            (mpy_x2_valid           ),
  .mpy_x3_valid_r          (mpy_x3_valid_r         ),

  .iccm0_clk	(iccm0_clk),
  .iccm0_din	(iccm0_din),
  .iccm0_addr	(iccm0_addr),
  .iccm0_cs	(iccm0_cs),
  .iccm0_we	(iccm0_we),
  .iccm0_wem	(iccm0_wem),
  .iccm0_dout	(iccm0_dout),



  .dccm_even_clk	(dccm_even_clk),
  .dccm_din_even	(dccm_din_even),
  .dccm_addr_even	(dccm_addr_even),
  .dccm_cs_even	(dccm_cs_even),
  .dccm_we_even	(dccm_we_even),
  .dccm_wem_even	(dccm_wem_even),
  .dccm_dout_even	(dccm_dout_even),
  .dccm_odd_clk	(dccm_odd_clk),
  .dccm_din_odd	(dccm_din_odd),
  .dccm_addr_odd	(dccm_addr_odd),
  .dccm_cs_odd	(dccm_cs_odd),
  .dccm_we_odd	(dccm_we_odd),
  .dccm_wem_odd	(dccm_wem_odd),
  .dccm_dout_odd	(dccm_dout_odd),

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

  .x2_pass                 (x2_pass                ),
  .ext_trig_valid          (ext_trig_output_valid  ),
  .ext_trig_in             (ext_trig_in            ),
  .ext_trig_accept         (ext_trig_output_accept ),


  .ibp_mmio_cmd_valid      (ibp_mmio_cmd_valid     ),
  .ibp_mmio_cmd_cache      (ibp_mmio_cmd_cache     ),
  .ibp_mmio_cmd_burst_size (ibp_mmio_cmd_burst_size),
  .ibp_mmio_cmd_read       (ibp_mmio_cmd_read      ),
  .ibp_mmio_cmd_aux        (ibp_mmio_cmd_aux       ),
  .ibp_mmio_cmd_accept     (ibp_mmio_cmd_accept    ),
  .ibp_mmio_cmd_addr       (ibp_mmio_cmd_addr      ),
  .ibp_mmio_cmd_excl       (ibp_mmio_cmd_excl      ),
  .ibp_mmio_cmd_atomic     (ibp_mmio_cmd_atomic    ),
  .ibp_mmio_cmd_data_size  (ibp_mmio_cmd_data_size ),
  .ibp_mmio_cmd_prot       (ibp_mmio_cmd_prot      ),

  .ibp_mmio_wr_valid       (ibp_mmio_wr_valid      ),
  .ibp_mmio_wr_last        (ibp_mmio_wr_last       ),
  .ibp_mmio_wr_accept      (ibp_mmio_wr_accept     ),
  .ibp_mmio_wr_mask        (ibp_mmio_wr_mask       ),
  .ibp_mmio_wr_data        (ibp_mmio_wr_data       ),

  .ibp_mmio_rd_valid       (ibp_mmio_rd_valid      ),
  .ibp_mmio_rd_err         (ibp_mmio_rd_err        ),
  .ibp_mmio_rd_excl_ok     (ibp_mmio_rd_excl_ok    ),
  .ibp_mmio_rd_last        (ibp_mmio_rd_last       ),
  .ibp_mmio_rd_accept      (ibp_mmio_rd_accept     ),
  .ibp_mmio_rd_data        (ibp_mmio_rd_data       ),

  .ibp_mmio_wr_done        (ibp_mmio_wr_done       ),
  .ibp_mmio_wr_excl_okay   (ibp_mmio_wr_excl_okay  ),
  .ibp_mmio_wr_err         (ibp_mmio_wr_err        ),
  .ibp_mmio_wr_resp_accept (ibp_mmio_wr_resp_accept),
  .csr_clint_sel_ctl       (csr_clint_sel_ctl      ),
  .csr_clint_sel_addr      (csr_clint_sel_addr     ),

  .clint_csr_rdata         (clint_csr_rdata        ),
  .clint_csr_illegal       (clint_csr_illegal      ),
  .clint_csr_unimpl        (clint_csr_unimpl       ),
  .clint_csr_serial_sr     (clint_csr_serial_sr    ),
  .clint_csr_strict_sr     (clint_csr_strict_sr    ),

  .csr_clint_write         (csr_clint_write        ),
  .csr_clint_waddr         (csr_clint_waddr        ),
  .csr_clint_wdata         (csr_clint_wdata        ),
  .csr_clint_ren_r         (csr_ren_r              ),
  .mtopi_iid               (mtopi_iid              ),
  .mtvec_mode              (mtvec_mode             ),
  .trap_ack                (trap_ack               ),

  .irq_trap                (irq_trap               ),
  .irq_id                  (irq_id                 ),

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



  .high_prio_ras             (high_prio_ras    ),

  .dr_safety_iso_err            (dr_safety_iso_err),
  .sfty_ibp_mmio_cmd_valid      (sfty_ibp_mmio_cmd_valid     ),
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
  .sfty_ibp_mmio_ini_e2e_err    (sfty_ibp_mmio_ini_e2e_err   ),
  .sfty_mem_adr_err             (sfty_mem_adr_err            ),
  .sfty_mem_dbe_err             (sfty_mem_dbe_err            ),
  .sfty_mem_sbe_err             (sfty_mem_sbe_err            ),
  .sfty_mem_sbe_overflow        (sfty_mem_sbe_overflow       ),

  .ahb_hlock               (ahb_hmastlock        ),
  .ahb_hexcl               (ahb_hexcl            ),
  .ahb_hmaster             (ahb_hmaster          ),
  .ahb_hauser              (ahb_hauser           ),
  .ahb_hwrite              (ahb_hwrite           ),
  .ahb_haddr               (ahb_haddr            ),
  .ahb_htrans              (ahb_htrans           ),
  .ahb_hsize               (ahb_hsize            ),
  .ahb_hburst              (ahb_hburst           ),
  .ahb_hwstrb              (ahb_hwstrb           ),
  .ahb_hprot               (ahb_hprot            ),
  .ahb_hnonsec             (ahb_hnonsec          ),
  .ahb_hready              (ahb_hready           ),
  .ahb_hresp               (ahb_hresp            ),
  .ahb_hexokay             (ahb_hexokay          ),
  .ahb_hrdata              (ahb_hrdata           ),
  .ahb_hwdata              (ahb_hwdata           ),

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

  .ahb_fatal_err           (ahb_fatal_err),

  .dbu_per_ahb_hlock        (dbu_per_ahb_hmastlock),
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

  .dbu_per_ahb_fatal_err    (dbu_per_ahb_fatal_err),


  ///////// ICCM0/ICCM1 DMI AHB5 initiator /////////////////////////////////
  .iccm_ahb_prio            (iccm_ahb_prio),
  .iccm_ahb_hlock           (iccm_ahb_hmastlock),
  .iccm_ahb_hexcl           (iccm_ahb_hexcl),
  .iccm_ahb_hmaster         (iccm_ahb_hmaster),

  .iccm_ahb_hsel            (iccm_ahb_hsel),
  .iccm_ahb_htrans          (iccm_ahb_htrans),
  .iccm_ahb_hwrite          (iccm_ahb_hwrite),
  .iccm_ahb_haddr           (iccm_ahb_haddr),
  .iccm_ahb_hsize           (iccm_ahb_hsize),
  .iccm_ahb_hwstrb          (iccm_ahb_hwstrb),
  .iccm_ahb_hburst          (iccm_ahb_hburst),
  .iccm_ahb_hprot           (iccm_ahb_hprot),
  .iccm_ahb_hnonsec         (iccm_ahb_hnonsec),
  .iccm_ahb_hwdata          (iccm_ahb_hwdata),
  .iccm_ahb_hready          (iccm_ahb_hready),
  .iccm_ahb_hrdata          (iccm_ahb_hrdata),
  .iccm_ahb_hresp           (iccm_ahb_hresp),
  .iccm_ahb_hexokay         (iccm_ahb_hexokay),
  .iccm_ahb_hready_resp     (iccm_ahb_hreadyout),
 ///////// ICCM0/ICCM1 DMI AHB5 bus protection signals /////////////////////////////////////
 //	

  .iccm_ahb_haddrchk        (iccm_ahb_haddrchk),
  .iccm_ahb_htranschk       (iccm_ahb_htranschk),
  .iccm_ahb_hctrlchk1       (iccm_ahb_hctrlchk1),
  .iccm_ahb_hctrlchk2       (iccm_ahb_hctrlchk2),
  .iccm_ahb_hwstrbchk       (iccm_ahb_hwstrbchk),
  .iccm_ahb_hprotchk        (iccm_ahb_hprotchk),
  .iccm_ahb_hreadychk       (iccm_ahb_hreadychk),
  .iccm_ahb_hrespchk        (iccm_ahb_hrespchk),
  .iccm_ahb_hready_respchk  (iccm_ahb_hreadyoutchk),
  .iccm_ahb_hselchk         (iccm_ahb_hselchk),
  .iccm_ahb_hrdatachk       (iccm_ahb_hrdatachk),
  .iccm_ahb_hwdatachk       (iccm_ahb_hwdatachk),
  .iccm_ahb_fatal_err       (iccm_ahb_fatal_err),

  ///////// DCCM DMI AHB5 initiator /////////////////////////////////
  .dccm_ahb_prio            (dccm_ahb_prio),
  .dccm_ahb_hlock           (dccm_ahb_hmastlock),
  .dccm_ahb_hexcl           (dccm_ahb_hexcl),
  .dccm_ahb_hmaster         (dccm_ahb_hmaster),

  .dccm_ahb_hsel            (dccm_ahb_hsel),
  .dccm_ahb_htrans          (dccm_ahb_htrans),
  .dccm_ahb_hwrite          (dccm_ahb_hwrite),
  .dccm_ahb_haddr           (dccm_ahb_haddr),
  .dccm_ahb_hsize           (dccm_ahb_hsize),
  .dccm_ahb_hwstrb          (dccm_ahb_hwstrb),
  .dccm_ahb_hburst          (dccm_ahb_hburst),
  .dccm_ahb_hprot           (dccm_ahb_hprot),
  .dccm_ahb_hnonsec         (dccm_ahb_hnonsec),
  .dccm_ahb_hwdata          (dccm_ahb_hwdata),
  .dccm_ahb_hready          (dccm_ahb_hready),
  .dccm_ahb_hrdata          (dccm_ahb_hrdata),
  .dccm_ahb_hresp           (dccm_ahb_hresp),
  .dccm_ahb_hexokay         (dccm_ahb_hexokay),
  .dccm_ahb_hready_resp     (dccm_ahb_hreadyout),
 ///////// DCCM DMI AHB5 bus protection signals /////////////////////////////////////
 //	

  .dccm_ahb_haddrchk        (dccm_ahb_haddrchk),
  .dccm_ahb_htranschk       (dccm_ahb_htranschk),
  .dccm_ahb_hctrlchk1       (dccm_ahb_hctrlchk1),
  .dccm_ahb_hctrlchk2       (dccm_ahb_hctrlchk2),
  .dccm_ahb_hwstrbchk       (dccm_ahb_hwstrbchk),
  .dccm_ahb_hprotchk        (dccm_ahb_hprotchk),
  .dccm_ahb_hreadychk       (dccm_ahb_hreadychk),
  .dccm_ahb_hrespchk        (dccm_ahb_hrespchk),
  .dccm_ahb_hready_respchk  (dccm_ahb_hreadyoutchk),
  .dccm_ahb_hselchk         (dccm_ahb_hselchk),
  .dccm_ahb_hrdatachk       (dccm_ahb_hrdatachk),
  .dccm_ahb_hwdatachk       (dccm_ahb_hwdatachk),
  .dccm_ahb_fatal_err       (dccm_ahb_fatal_err),

  ///////// MMIO DMI AHB5 initiator /////////////////////////////////
  .mmio_ahb_prio            (mmio_ahb_prio),
  .mmio_ahb_hlock           (mmio_ahb_hmastlock),
  .mmio_ahb_hexcl           (mmio_ahb_hexcl),
  .mmio_ahb_hmaster         (mmio_ahb_hmaster),

  .mmio_ahb_hsel            (mmio_ahb_hsel),
  .mmio_ahb_htrans          (mmio_ahb_htrans),
  .mmio_ahb_hwrite          (mmio_ahb_hwrite),
  .mmio_ahb_haddr           (mmio_ahb_haddr),
  .mmio_ahb_hsize           (mmio_ahb_hsize),
  .mmio_ahb_hwstrb          (mmio_ahb_hwstrb),
  .mmio_ahb_hburst          (mmio_ahb_hburst),
  .mmio_ahb_hprot           (mmio_ahb_hprot),
  .mmio_ahb_hnonsec         (mmio_ahb_hnonsec),
  .mmio_ahb_hwdata          (mmio_ahb_hwdata),
  .mmio_ahb_hready          (mmio_ahb_hready),
  .mmio_ahb_hrdata          (mmio_ahb_hrdata),
  .mmio_ahb_hresp           (mmio_ahb_hresp),
  .mmio_ahb_hexokay         (mmio_ahb_hexokay),
  .mmio_ahb_hready_resp     (mmio_ahb_hreadyout),
 ///////// MMIO DMI AHB5 bus protection signals /////////////////////////////////////
 //	

  .mmio_ahb_haddrchk        (mmio_ahb_haddrchk),
  .mmio_ahb_htranschk       (mmio_ahb_htranschk),
  .mmio_ahb_hctrlchk1       (mmio_ahb_hctrlchk1),
  .mmio_ahb_hctrlchk2       (mmio_ahb_hctrlchk2),
  .mmio_ahb_hwstrbchk       (mmio_ahb_hwstrbchk),
  .mmio_ahb_hprotchk        (mmio_ahb_hprotchk),
  .mmio_ahb_hreadychk       (mmio_ahb_hreadychk),
  .mmio_ahb_hrespchk        (mmio_ahb_hrespchk),
  .mmio_ahb_hready_respchk  (mmio_ahb_hreadyoutchk),
  .mmio_ahb_hselchk         (mmio_ahb_hselchk),
  .mmio_ahb_hrdatachk       (mmio_ahb_hrdatachk),
  .mmio_ahb_hwdatachk       (mmio_ahb_hwdatachk),
  .mmio_ahb_fatal_err       (mmio_ahb_fatal_err),
  .core_mmio_base_in        (mmio_base_in),

  .lsc_diag_aux_r           (lsc_diag_aux_r           ),
  .dr_lsc_stl_ctrl_aux_r    (dr_lsc_stl_ctrl_aux_r    ),
  .lsc_shd_ctrl_aux_r       (lsc_shd_ctrl_aux_r       ),
  .dr_sfty_aux_parity_err_r (dr_sfty_aux_parity_err_r ),
  .dr_bus_fatal_err         (dr_bus_fatal_err         ),
  .safety_comparator_enable (safety_comparator_enable ),
  .dr_safety_comparator_enabled(dr_safety_comparator_enabled),
  .safety_iso_enb_synch_r   (safety_iso_enb_synch_r   ),
  .sfty_nsi_r               (sfty_nsi_r   ),
  .lsc_err_stat_aux         (lsc_err_stat_aux         ),
  .dr_sfty_eic              (dr_sfty_eic              ),
  .dr_secure_trig_iso_err   (dr_secure_trig_iso_err   ),
  .wid_rwiddeleg            (wid_rwiddeleg         ),
  .wid_rlwid                (wid_rlwid             ),
  .dbg_ibp_cmd_valid        (dbg_ibp_cmd_valid),
  .dbg_ibp_cmd_read         (dbg_ibp_cmd_read),
  .dbg_ibp_cmd_addr         (dbg_ibp_cmd_addr),
  .dbg_ibp_cmd_accept       (dbg_ibp_cmd_accept),
  .dbg_ibp_cmd_space        (dbg_ibp_cmd_space),
  .dbg_ibp_rd_valid         (dbg_ibp_rd_valid),
  .dbg_ibp_rd_accept        (dbg_ibp_rd_accept),
  .dbg_ibp_rd_err           (dbg_ibp_rd_err),
  .dbg_ibp_rd_data          (dbg_ibp_rd_data),
  .dbg_ibp_wr_valid         (dbg_ibp_wr_valid),
  .dbg_ibp_wr_accept        (dbg_ibp_wr_accept),
  .dbg_ibp_wr_data          (dbg_ibp_wr_data),
  .dbg_ibp_wr_mask          (dbg_ibp_wr_mask),
  .dbg_ibp_wr_done          (dbg_ibp_wr_done),
  .dbg_ibp_wr_err           (dbg_ibp_wr_err),
  .dbg_ibp_wr_resp_accept   (dbg_ibp_wr_resp_accept),
  .dm2arc_halt_on_reset    (dm2arc_halt_on_reset ),
  .is_dm_rst               (is_dm_rst            ),

  .mtime_r                 (mtime_r              ),
  .arcnum                  (arcnum               ),
  .pct_unit_enable         (pct_unit_enable      ),
  .clk_hpm                 (clk_hpm              ),
  .hpm_int_overflow_rising (hpm_int_overflow_rising),
  .hpm_int_overflow_r      (hpm_int_overflow_r   ),
  .time_ovf                (time_ovf             ),
  .critical_error          (critical_error       ),
  .sys_halt_r              (sys_halt_r           ),           
  .sys_sleep_r             (sys_sleep_r          ),           
  .sys_sleep_mode_r        (sys_sleep_mode_r     ) 
  
);


sfty_dmsi_down_tgt_e2e_wrap #(
    .DW        (32) // Data width
    )
u_sfty_dmsi_down_tgt_e2e(

  .dmsi_down_valid           (dmsi_valid),
  .dmsi_down_context         (dmsi_context),
  .dmsi_down_eiid            (dmsi_eiid),
  .dmsi_down_domain          (dmsi_domain),
  .dmsi_down_rdy             (dmsi_rdy),

  .dmsi_down_valid_chk       (dmsi_valid_chk),
  .dmsi_down_data_edc        (dmsi_data_edc),

  .dmsi_down_rdy_chk         (dmsi_rdy_chk),

  .ini_e2e_err               (sfty_dmsi_tgt_e2e_err),
  .clk                       (cpu_clk_gated),
  .rst_a                     (cpu_rst_gated)

);



arcv_imsic_clint u_arcv_imsic_clint (

`ifdef SIMULATION
  .mip_r                   (mip_r),
  .mie_r                   (mie_r),
`endif

  ///////// control interface
  .irq_trap                (irq_trap),
  .irq_id                  (irq_id),
  .mtopi_iid_int           (mtopi_iid),
  ////////// DMSI interface

  .dmsi_valid              (dmsi_valid),
  .dmsi_context            (dmsi_context),
  .dmsi_eiid               (dmsi_eiid),
  .dmsi_domain             (dmsi_domain),
  .dmsi_rdy                (dmsi_rdy),

  ///////// CSR interface
  .csr_raddr_r             (csr_irq_raddr),
  .csr_clint_sel_ctl       (csr_clint_sel_ctl),
  .csr_irq_unimpl          (clint_csr_unimpl),
  .csr_illegal             (clint_csr_illegal),
  .csr_rdata               (irq_csr_rdata),
  .csr_waddr_r             (csr_irq_waddr),
  .csr_wen_r               (csr_irq_wr),
  .csr_ren_r               (csr_ren_r),
  .csr_wdata_r             (csr_clint_wdata),
  .priv_level              (priv_level_r),
  .miselect_r              (miselect_r  ),
  .mireg_wen               (mireg_clint_wen),
  .mireg_int               (mireg_clint ),

  .mtvec_mode              (mtvec_mode),
  .trap_ack                (trap_ack),
  // major irq
  .high_prio_ras           (1'b0),
  .db_evt                  (1'b0),
  .mtip_0                  (mtip_0),
  .msip_0                  (msip_0),
  .irq_wdt                 (irq_wdt),
  .cnt_overflow            (hpm_int_overflow_r),
  .low_prio_ras            (1'b0),

  .clk                     (cpu_clk_gated),         
  .rst_a                   (cpu_rst_gated)

);


arcv_timer u_arcv_timer(
  ////////// Internal signals /////////////////////////////////////////
  //
  .tm_clk_enable_sync      (tm_clk_enable_sync),
  .mtime_r                 (mtime_r           ),
  ////////// IBP interface signals ////////////////////////////////////
  //
  .ibp_cmd_valid           (ibp_mmio_cmd_valid     ),
  .ibp_cmd_cache           (ibp_mmio_cmd_cache     ),
  .ibp_cmd_burst_size      (ibp_mmio_cmd_burst_size),
  .ibp_cmd_read            (ibp_mmio_cmd_read      ),
  .ibp_cmd_aux             (ibp_mmio_cmd_aux       ),
  .ibp_cmd_accept          (ibp_mmio_cmd_accept    ),
  .ibp_cmd_addr            (ibp_mmio_cmd_addr      ),
  .ibp_cmd_excl            (ibp_mmio_cmd_excl      ),
  .ibp_cmd_atomic          (ibp_mmio_cmd_atomic    ),
  .ibp_cmd_data_size       (ibp_mmio_cmd_data_size ),
  .ibp_cmd_prot            (ibp_mmio_cmd_prot      ),

  .ibp_wr_valid            (ibp_mmio_wr_valid      ),
  .ibp_wr_last             (ibp_mmio_wr_last       ),
  .ibp_wr_accept           (ibp_mmio_wr_accept     ),
  .ibp_wr_mask             (ibp_mmio_wr_mask       ),
  .ibp_wr_data             (ibp_mmio_wr_data       ),

  .ibp_rd_valid            (ibp_mmio_rd_valid      ),
  .ibp_rd_err              (ibp_mmio_rd_err        ),
  .ibp_rd_excl_ok          (ibp_mmio_rd_excl_ok    ),
  .ibp_rd_last             (ibp_mmio_rd_last       ),
  .ibp_rd_accept           (ibp_mmio_rd_accept     ),
  .ibp_rd_data             (ibp_mmio_rd_data       ),

  .ibp_wr_done             (ibp_mmio_wr_done       ),
  .ibp_wr_excl_okay        (ibp_mmio_wr_excl_okay  ),
  .ibp_wr_err              (ibp_mmio_wr_err        ),
  .ibp_wr_resp_accept      (ibp_mmio_wr_resp_accept),
  ////////// Interrupts ////////////////////////////////////
  //
  .mtip_0                  (mtip_0),
  .msip_0                  (msip_0),
  .time_ovf                (time_ovf),
  .time_ovf_flag           (time_ovf_flag),
  ////////// General input signals /////////////////////////////////////////
  //
  .clk                     (cpu_clk_gated),
  .rst_a                   (cpu_rst_gated)

);

arcv_watchdog u_arcv_watchdog(

  .db_active                      (db_active),     // Host debug op in progress
  .sys_halt_r                     (sys_halt_r),    // halted status of CPU(s)
  ////////// CSR access interface /////////////////////////////////////////
  //
  .csr_sel_ctl                    (csr_wdt_sel_ctl),           // (X1) CSR slection (01 = read, 10 = write)
  .csr_sel_addr                   (csr_wdt_sel_addr),          // (X1) CSR address

  .csr_rdata                      (wdt_csr_rdata),             // (X1) CSR read data
  .csr_illegal                    (wdt_csr_illegal),           // (X1) illegal
  .csr_unimpl                     (wdt_csr_unimpl),            // (X1) Invalid CSR
  .csr_serial_sr                  (wdt_csr_serial_sr),         // (X1) SR group flush pipe
  .csr_strict_sr                  (wdt_csr_strict_sr),         // (X1) SR flush pipe

  .csr_write                      (csr_wdt_write),             // (X2) CSR operation (01 = read, 10 = write)
  .csr_waddr                      (csr_wdt_waddr),             // (X2) CSR addr
  .csr_wdata                      (csr_wdt_wdata),             // (X2) Write data

  .x2_pass                        (x2_pass),               // (X2) commit
  .priv_level_r                   (priv_level_r),
  .csr_raw_hazard                 (wdt_csr_raw_hazard),

  ////////// Interrupt interface /////////////////////////////////////////
  //
  .irq_wdt                        (irq_wdt),

  ////////// Watchdog external signals ///////////////////////////////////
  //
  .reg_wr_en0                 (reg_wr_en0),
  .wdt_reset0                 (wdt_reset0),      // Reset timeout signal from clk
  .wdt_clk_enable_sync            (wdt_clk_enable_sync),
  .wdt_feedback_bit               (wdt_feedback_bit),

  ////////// General input signals /////////////////////////////////////////
  //
  .clk                            (clk_wdt),
  .ungated_clk                    (cpu_clk_gated),          // ungated clock used for core clock stuck-at error feedback
  .rst_a                          (cpu_rst_gated)

);



assign dm2arc_halt_req  = dm2arc_halt_req_synch_r;
assign dm2arc_run_req   = dm2arc_run_req_synch_r;
assign dm2arc_havereset_ack = dm2arc_havereset_ack_synch_r;
assign dm2arc_halt_on_reset = dm2arc_halt_on_reset_synch_r;
assign rnmi_req         = rnmi_synch_r;
assign rst_init_disable = rst_init_disable_synch_r;

assign soft_reset_prepare = soft_reset_prepare_synch_r;


//////////////////////////////////////////////////////////////////////////////
//
// Temporary stubs @@@
//
//////////////////////////////////////////////////////////////////////////////





// spyglass disable_block W402b INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH
// SMD: Asynchronous set/reset signal is not an input to the module
// SJ : Intended to internally generate asynchronous set/reset signals
always@(posedge cpu_clk_gated or posedge cpu_rst_gated)
begin
  if (cpu_rst_gated == 1'b1)
  begin
    arc2dm_havereset_a <= 1'b1;
  end
  else
  begin
    if (dm2arc_havereset_ack == 1'b1)
    begin
      arc2dm_havereset_a <= 1'b0;
    end
  end
end
// spyglass enable_block W402b INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH

always@(posedge cpu_clk_gated or posedge cpu_rst_gated)
begin
  if (cpu_rst_gated == 1'b1)
  begin
    cpu_in_reset_state <= 1'b1;
  end
  else
  begin
    cpu_in_reset_state <= 1'b0;
  end
end

assign hart_unavailable = 1'b0; // @@@

endmodule // rl_cpu_top



