`include "defines.v"
`include "const.def"
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
// @f:safety_controller
//
// Description:
// @p
//   This is the safety controller for rl_cpu_top.v.
// @e
//
// ===========================================================================


`include "rv_safety_defines.v"
`include "defines.v"




























module cpu_top_safety_controller
    (
    // This controller is a proxy for rl_cpu_top.v.  Declare the module's ports:
    input           clk,
    input           rst_a,
    input           rst_cpu_req_a,
    output           rst_cpu_ack,
    output           cpu_rst_gated,
    output           cpu_clk_gated,
    input           test_mode,
    input           LBIST_EN,
    input           dm2arc_halt_req_a,
    input           dm2arc_run_req_a,
    output           arc2dm_halt_ack,
    output           arc2dm_run_ack,
    input           dm2arc_hartreset_a,
    input           dm2arc_hartreset2_a,
    input           ndmreset_a,
    input           dm2arc_havereset_ack_a,
    input           dm2arc_halt_on_reset_a,
    output           arc2dm_havereset_a,
    input           dm2arc_relaxedpriv_a,
    output           hart_unavailable,
    output           ahb_hmastlock,
    output           ahb_hexcl,
    output  [3:0]    ahb_hmaster,               // 4 [3:0]               
    output  [7:0]    ahb_hauser,               // 8 [`AUSER_RANGE]      
    output           ahb_hwrite,
    output  [31:0]   ahb_haddr,               // 32 [`ADDR_RANGE]       
    output  [1:0]    ahb_htrans,               // 2 [1:0]               
    output  [2:0]    ahb_hsize,               // 3 [2:0]               
    output  [2:0]    ahb_hburst,               // 3 [2:0]               
    output  [3:0]    ahb_hwstrb,               // 4 [3:0]               
    output  [6:0]    ahb_hprot,               // 7 [6:0]               
    output           ahb_hnonsec,
    input           ahb_hready,
    input           ahb_hresp,
    input           ahb_hexokay,
    input  [31:0]   ahb_hrdata,               // 32 [`DATA_RANGE]       
    output  [31:0]   ahb_hwdata,               // 32 [`DATA_RANGE]       
    output  [0:0]    ahb_hauserchk,
    output  [3:0]    ahb_haddrchk,               // 4 [3:0]               
    output           ahb_htranschk,
    output           ahb_hctrlchk1,
    output           ahb_hctrlchk2,
    output           ahb_hprotchk,
    output           ahb_hwstrbchk,
    input           ahb_hreadychk,
    input           ahb_hrespchk,
    input  [3:0]    ahb_hrdatachk,               // 4 [3:0]               
    output  [3:0]    ahb_hwdatachk,               // 4 [3:0]               
    output           ahb_fatal_err,
    output           dbu_per_ahb_hmastlock,
    output           dbu_per_ahb_hexcl,
    output  [3:0]    dbu_per_ahb_hmaster,               // 4 [3:0]               
    output  [7:0]    dbu_per_ahb_hauser,               // 8 [`AUSER_RANGE]      
    output           dbu_per_ahb_hwrite,
    output  [31:0]   dbu_per_ahb_haddr,               // 32 [`ADDR_RANGE]       
    output  [1:0]    dbu_per_ahb_htrans,               // 2 [1:0]               
    output  [2:0]    dbu_per_ahb_hsize,               // 3 [2:0]               
    output  [2:0]    dbu_per_ahb_hburst,               // 3 [2:0]               
    output  [3:0]    dbu_per_ahb_hwstrb,               // 4 [3:0]               
    output  [6:0]    dbu_per_ahb_hprot,               // 7 [6:0]               
    output           dbu_per_ahb_hnonsec,
    input           dbu_per_ahb_hready,
    input           dbu_per_ahb_hresp,
    input           dbu_per_ahb_hexokay,
    input  [31:0]   dbu_per_ahb_hrdata,               // 32 [`DATA_RANGE]       
    output  [31:0]   dbu_per_ahb_hwdata,               // 32 [`DATA_RANGE]       
    output  [0:0]    dbu_per_ahb_hauserchk,
    output  [3:0]    dbu_per_ahb_haddrchk,               // 4 [3:0]               
    output           dbu_per_ahb_htranschk,
    output           dbu_per_ahb_hctrlchk1,
    output           dbu_per_ahb_hctrlchk2,
    output           dbu_per_ahb_hprotchk,
    output           dbu_per_ahb_hwstrbchk,
    input           dbu_per_ahb_hreadychk,
    input           dbu_per_ahb_hrespchk,
    input  [3:0]    dbu_per_ahb_hrdatachk,               // 4 [3:0]               
    output  [3:0]    dbu_per_ahb_hwdatachk,               // 4 [3:0]               
    output           dbu_per_ahb_fatal_err,
    input           iccm_ahb_prio,
    input           iccm_ahb_hmastlock,
    input           iccm_ahb_hexcl,
    input  [3:0]    iccm_ahb_hmaster,               // 4 [3:0]               
    input  [0:0]    iccm_ahb_hsel,
    input  [1:0]    iccm_ahb_htrans,               // 2 [1:0]               
    input           iccm_ahb_hwrite,
    input  [31:0]   iccm_ahb_haddr,               // 32 [`ADDR_RANGE]       
    input  [2:0]    iccm_ahb_hsize,               // 3 [2:0]               
    input  [3:0]    iccm_ahb_hwstrb,               // 4 [3:0]               
    input  [2:0]    iccm_ahb_hburst,               // 3 [2:0]               
    input  [6:0]    iccm_ahb_hprot,               // 7 [6:0]               
    input           iccm_ahb_hnonsec,
    input  [31:0]   iccm_ahb_hwdata,               // 32 [`ICCM_DMI_DATA_RANGE]
    input           iccm_ahb_hready,
    output  [31:0]   iccm_ahb_hrdata,               // 32 [`ICCM_DMI_DATA_RANGE]
    output           iccm_ahb_hresp,
    output           iccm_ahb_hexokay,
    output           iccm_ahb_hreadyout,
    input  [3:0]    iccm_ahb_haddrchk,               // 4 [3:0]               
    input           iccm_ahb_htranschk,
    input           iccm_ahb_hctrlchk1,
    input           iccm_ahb_hctrlchk2,
    input           iccm_ahb_hwstrbchk,
    input           iccm_ahb_hprotchk,
    input           iccm_ahb_hreadychk,
    output           iccm_ahb_hrespchk,
    output           iccm_ahb_hreadyoutchk,
    input           iccm_ahb_hselchk,
    output  [3:0]    iccm_ahb_hrdatachk,               // 4 [3:0]               
    input  [3:0]    iccm_ahb_hwdatachk,               // 4 [3:0]               
    output           iccm_ahb_fatal_err,
    input           dccm_ahb_prio,
    input           dccm_ahb_hmastlock,
    input           dccm_ahb_hexcl,
    input  [3:0]    dccm_ahb_hmaster,               // 4 [3:0]               
    input  [0:0]    dccm_ahb_hsel,
    input  [1:0]    dccm_ahb_htrans,               // 2 [1:0]               
    input           dccm_ahb_hwrite,
    input  [31:0]   dccm_ahb_haddr,               // 32 [`ADDR_RANGE]       
    input  [2:0]    dccm_ahb_hsize,               // 3 [2:0]               
    input  [3:0]    dccm_ahb_hwstrb,               // 4 [3:0]               
    input           dccm_ahb_hnonsec,
    input  [2:0]    dccm_ahb_hburst,               // 3 [2:0]               
    input  [6:0]    dccm_ahb_hprot,               // 7 [6:0]               
    input  [31:0]   dccm_ahb_hwdata,               // 32 [`DCCM_DMI_DATA_RANGE]
    input           dccm_ahb_hready,
    output  [31:0]   dccm_ahb_hrdata,               // 32 [`DCCM_DMI_DATA_RANGE]
    output           dccm_ahb_hresp,
    output           dccm_ahb_hexokay,
    output           dccm_ahb_hreadyout,
    input  [3:0]    dccm_ahb_haddrchk,               // 4 [3:0]               
    input           dccm_ahb_htranschk,
    input           dccm_ahb_hctrlchk1,
    input           dccm_ahb_hctrlchk2,
    input           dccm_ahb_hwstrbchk,
    input           dccm_ahb_hprotchk,
    input           dccm_ahb_hreadychk,
    output           dccm_ahb_hrespchk,
    output           dccm_ahb_hreadyoutchk,
    input           dccm_ahb_hselchk,
    output  [3:0]    dccm_ahb_hrdatachk,               // 4 [3:0]               
    input  [3:0]    dccm_ahb_hwdatachk,               // 4 [3:0]               
    output           dccm_ahb_fatal_err,
    input           mmio_ahb_prio,
    input           mmio_ahb_hmastlock,
    input           mmio_ahb_hexcl,
    input  [3:0]    mmio_ahb_hmaster,               // 4 [3:0]               
    input           mmio_ahb_hsel,
    input  [1:0]    mmio_ahb_htrans,               // 2 [1:0]               
    input           mmio_ahb_hwrite,
    input  [31:0]   mmio_ahb_haddr,               // 32 [`ADDR_RANGE]       
    input  [2:0]    mmio_ahb_hsize,               // 3 [2:0]               
    input  [3:0]    mmio_ahb_hwstrb,               // 4 [3:0]               
    input           mmio_ahb_hnonsec,
    input  [2:0]    mmio_ahb_hburst,               // 3 [2:0]               
    input  [6:0]    mmio_ahb_hprot,               // 7 [6:0]               
    input  [31:0]   mmio_ahb_hwdata,               // 32 [`DATA_RANGE]       
    input           mmio_ahb_hready,
    output  [31:0]   mmio_ahb_hrdata,               // 32 [`DATA_RANGE]       
    output           mmio_ahb_hresp,
    output           mmio_ahb_hexokay,
    output           mmio_ahb_hreadyout,
    input  [3:0]    mmio_ahb_haddrchk,               // 4 [3:0]               
    input           mmio_ahb_htranschk,
    input           mmio_ahb_hctrlchk1,
    input           mmio_ahb_hctrlchk2,
    input           mmio_ahb_hwstrbchk,
    input           mmio_ahb_hprotchk,
    input           mmio_ahb_hreadychk,
    output           mmio_ahb_hrespchk,
    output           mmio_ahb_hreadyoutchk,
    input           mmio_ahb_hselchk,
    output  [3:0]    mmio_ahb_hrdatachk,               // 4 [3:0]               
    input  [3:0]    mmio_ahb_hwdatachk,               // 4 [3:0]               
    output           mmio_ahb_fatal_err,
    input  [11:0]   mmio_base_in,               // 12 [11:0]              
    input  [21:0]   reset_pc_in,               // 22 [21:0]              
    input           rnmi_a,
    output           esrams_iccm0_clk,
    output  [39:0]   esrams_iccm0_din,               // 40 [`ICCM0_DRAM_RANGE] 
    output  [18:2]   esrams_iccm0_addr,               // 17 [`ICCM0_ADR_RANGE]  
    output           esrams_iccm0_cs,
    output           esrams_iccm0_we,
    output  [4:0]    esrams_iccm0_wem,               // 5 [`ICCM_MASK_RANGE]  
    input  [39:0]   esrams_iccm0_dout,               // 40 [`ICCM0_DRAM_RANGE] 
    output           esrams_dccm_even_clk,
    output  [39:0]   esrams_dccm_din_even,               // 40 [`DCCM_DRAM_RANGE]  
    output  [19:3]   esrams_dccm_addr_even,               // 17 [`DCCM_ADR_RANGE]   
    output           esrams_dccm_cs_even,
    output           esrams_dccm_we_even,
    output  [4:0]    esrams_dccm_wem_even,               // 5 [`DCCM_MASK_RANGE]  
    input  [39:0]   esrams_dccm_dout_even,               // 40 [`DCCM_DRAM_RANGE]  
    output           esrams_dccm_odd_clk,
    output  [39:0]   esrams_dccm_din_odd,               // 40 [`DCCM_DRAM_RANGE]  
    output  [19:3]   esrams_dccm_addr_odd,               // 17 [`DCCM_ADR_RANGE]   
    output           esrams_dccm_cs_odd,
    output           esrams_dccm_we_odd,
    output  [4:0]    esrams_dccm_wem_odd,               // 5 [`DCCM_MASK_RANGE]  
    input  [39:0]   esrams_dccm_dout_odd,               // 40 [`DCCM_DRAM_RANGE]  
    output           esrams_ic_tag_mem_clk,
    output  [55:0]   esrams_ic_tag_mem_din,               // 56 [`IC_TAG_SET_RANGE] 
    output  [12:5]   esrams_ic_tag_mem_addr,               // 8 [`IC_IDX_RANGE]     
    output           esrams_ic_tag_mem_cs,
    output           esrams_ic_tag_mem_we,
    output  [55:0]   esrams_ic_tag_mem_wem,               // 56 [`IC_TAG_SET_RANGE] 
    input  [55:0]   esrams_ic_tag_mem_dout,               // 56 [`IC_TAG_SET_RANGE] 
    output           esrams_ic_data_mem_clk,
    output  [79:0]   esrams_ic_data_mem_din,               // 80 [`IC_DATA_SET_RANGE]
    output  [12:2]   esrams_ic_data_mem_addr,               // 11 [`IC_DATA_ADR_RANGE]
    output           esrams_ic_data_mem_cs,
    output           esrams_ic_data_mem_we,
    output  [79:0]   esrams_ic_data_mem_wem,               // 80 [`IC_DATA_SET_RANGE]
    input  [79:0]   esrams_ic_data_mem_dout,               // 80 [`IC_DATA_SET_RANGE]
    output           esrams_clk,
    output           esrams_ls,
    input  [1:0]    ext_trig_output_accept,               // 2 [1:0]               
    input  [15:0]   ext_trig_in,               // 16 [15:0]              
    output  [1:0]    ext_trig_output_valid,               // 2 [1:0]               
    output           high_prio_ras,
    output  [15:0]   lsc_diag_aux_r,               // 16 [`RV_LSC_DIAG_RANGE]
    output  [1:0]    dr_lsc_stl_ctrl_aux_r,               // 2 [1:0]               
    output  [1:0]    dr_sfty_aux_parity_err_r,               // 2 [1:0]               
    output  [1:0]    dr_bus_fatal_err,               // 2 [1:0]               
    input  [1:0]    dr_safety_comparator_enabled,               // 2 [1:0]               
    input           safety_iso_enb_a,
    output           sfty_nsi_r,
    input  [13:0]   lsc_err_stat_aux,               // 14 [`RV_LSC_ERR_STAT_RANGE]
    input  [1:0]    dr_sfty_eic,               // 2 [1:0]               
    output  [1:0]    dr_safety_iso_err,               // 2 [1:0]               
    output  [1:0]    dr_secure_trig_iso_err,               // 2 [1:0]               
    output           sfty_mem_sbe_err,
    output           sfty_mem_dbe_err,
    output           sfty_mem_adr_err,
    output           sfty_mem_sbe_overflow,
    output           sfty_ibp_mmio_cmd_valid,
    output  [3:0]    sfty_ibp_mmio_cmd_cache,               // 4 [3:0]               
    output           sfty_ibp_mmio_cmd_burst_size,
    output           sfty_ibp_mmio_cmd_read,
    output           sfty_ibp_mmio_cmd_aux,
    input           sfty_ibp_mmio_cmd_accept,
    output  [7:0]    sfty_ibp_mmio_cmd_addr,               // 8 [7:0]               
    output           sfty_ibp_mmio_cmd_excl,
    output  [5:0]    sfty_ibp_mmio_cmd_atomic,               // 6 [5:0]               
    output  [2:0]    sfty_ibp_mmio_cmd_data_size,               // 3 [2:0]               
    output  [1:0]    sfty_ibp_mmio_cmd_prot,               // 2 [1:0]               
    output           sfty_ibp_mmio_wr_valid,
    output           sfty_ibp_mmio_wr_last,
    input           sfty_ibp_mmio_wr_accept,
    output  [3:0]    sfty_ibp_mmio_wr_mask,               // 4 [3:0]               
    output  [31:0]   sfty_ibp_mmio_wr_data,               // 32 [31:0]              
    input           sfty_ibp_mmio_rd_valid,
    input           sfty_ibp_mmio_rd_err,
    input           sfty_ibp_mmio_rd_excl_ok,
    input           sfty_ibp_mmio_rd_last,
    output           sfty_ibp_mmio_rd_accept,
    input  [31:0]   sfty_ibp_mmio_rd_data,               // 32 [31:0]              
    input           sfty_ibp_mmio_wr_done,
    input           sfty_ibp_mmio_wr_excl_okay,
    input           sfty_ibp_mmio_wr_err,
    output           sfty_ibp_mmio_wr_resp_accept,
    output           sfty_ibp_mmio_cmd_valid_pty,
    input           sfty_ibp_mmio_cmd_accept_pty,
    output           sfty_ibp_mmio_cmd_addr_pty,
    output  [3:0]    sfty_ibp_mmio_cmd_ctrl_pty,               // 4 [3:0]               
    output           sfty_ibp_mmio_wr_valid_pty,
    input           sfty_ibp_mmio_wr_accept_pty,
    output           sfty_ibp_mmio_wr_last_pty,
    input           sfty_ibp_mmio_rd_valid_pty,
    output           sfty_ibp_mmio_rd_accept_pty,
    input           sfty_ibp_mmio_rd_ctrl_pty,
    input  [3:0]    sfty_ibp_mmio_rd_data_pty,               // 4 [3:0]               
    input           sfty_ibp_mmio_wr_done_pty,
    input           sfty_ibp_mmio_wr_ctrl_pty,
    output           sfty_ibp_mmio_wr_resp_accept_pty,
    output           sfty_ibp_mmio_ini_e2e_err,
    output           wdt_reset0,
    output           reg_wr_en0,
    input           dmsi_valid,
    input  [0:0]    dmsi_context,
    input  [5:0]    dmsi_eiid,               // 6 [`EIID_IDX_RANGE]   
    input           dmsi_domain,
    output           dmsi_rdy,
    input           dmsi_valid_chk,
    input  [5:0]    dmsi_data_edc,               // 6 [5:0]               
    output           dmsi_rdy_chk,
    output           sfty_dmsi_tgt_e2e_err,
    input           dbg_ibp_cmd_valid,
    input           dbg_ibp_cmd_read,
    input  [31:0]   dbg_ibp_cmd_addr,               // 32 [`DBG_ADDR_RANGE]   
    output           dbg_ibp_cmd_accept,
    input  [3:0]    dbg_ibp_cmd_space,               // 4 [3:0]               
    output           dbg_ibp_rd_valid,
    input           dbg_ibp_rd_accept,
    output           dbg_ibp_rd_err,
    output  [31:0]   dbg_ibp_rd_data,               // 32 [`DBG_DATA_RANGE]   
    input           dbg_ibp_wr_valid,
    output           dbg_ibp_wr_accept,
    input  [31:0]   dbg_ibp_wr_data,               // 32 [`DBG_DATA_RANGE]   
    input  [3:0]    dbg_ibp_wr_mask,               // 4 [3:0]               
    output           dbg_ibp_wr_done,
    output           dbg_ibp_wr_err,
    input           dbg_ibp_wr_resp_accept,
    input  [4:0]    wid_rlwid,               // 5 [`WID_RANGE]        
    input  [63:0]   wid_rwiddeleg,               // 64 [63:0]              
    input           soft_reset_prepare_a,
    input           soft_reset_req_a,
    output           soft_reset_ready,
    output           soft_reset_ack,
    output           cpu_in_reset_state,
    input           rst_init_disable_a,
    input  [7:0]    arcnum,               // 8 [7:0]               
    output           sys_halt_r,
    output           sys_sleep_r,
    output           critical_error,
    output  [2:0]    sys_sleep_mode_r,               // 3 [`EXT_SMODE_RANGE]  




    output [1:0]  cpu_dr_sfty_diag_inj_end,
    output [1:0]  cpu_dr_mask_pty_err,
    input  [1:0]  cpu_dr_sfty_diag_mode_sc,
  input   ref_clk,
  input   wdt_clk,
  output  wdt_reset_wdt_clk0,

    // Fixed ports for cpu_




    output [1:0]      cpu_lsAsafety_comparator_enabled,
    output [1:0]      cpu_lsBsafety_comparator_enabled,
    output            cpu_lsAls_lock_reset,
    output [1:0]      cpu_dr_sfty_ctrl_parity_error,
    output [1:0]      cpu_dr_mismatch_r
    );





  wire halt_asserted, cpu_clk_gate_enable;


wire safety_shadow_clk;

  wire safety_comp_clk;
  assign safety_comp_clk = cpu_clk_gated;







wire [1:0] mismatch_r;
assign cpu_dr_mismatch_r = mismatch_r;

// Temporary wires for the two instances of rl_cpu_top
wire          lsAclk;
wire          lsAtm_clk_enable_sync;
wire          lsArst_synch_r;
wire          lsArst_cpu_req_synch_r;
wire          lsArst_cpu_ack;
wire          lsAcpu_rst_gated;
wire          lsAcpu_clk_gated;
wire          lsAtest_mode;
wire          lsALBIST_EN;
wire          lsAdm2arc_halt_req_synch_r;
wire          lsAdm2arc_run_req_synch_r;
wire          lsAarc2dm_halt_ack;
wire          lsAarc2dm_run_ack;
wire          lsAdm2arc_hartreset_synch_r;
wire          lsAdm2arc_hartreset2_synch_r;
wire          lsAndmreset_synch_r;
wire          lsAdm2arc_havereset_ack_synch_r;
wire          lsAdm2arc_halt_on_reset_synch_r;
wire          lsAarc2dm_havereset_a;
wire          lsAdm2arc_relaxedpriv_synch_r;
wire          lsAhart_unavailable;
wire          lsAahb_hmastlock;
wire          lsAahb_hexcl;
wire [3:0]    lsAahb_hmaster;
wire [7:0]    lsAahb_hauser;
wire          lsAahb_hwrite;
wire [31:0]   lsAahb_haddr;
wire [1:0]    lsAahb_htrans;
wire [2:0]    lsAahb_hsize;
wire [2:0]    lsAahb_hburst;
wire [3:0]    lsAahb_hwstrb;
wire [6:0]    lsAahb_hprot;
wire          lsAahb_hnonsec;
wire          lsAahb_hready;
wire          lsAahb_hresp;
wire          lsAahb_hexokay;
wire [31:0]   lsAahb_hrdata;
wire [31:0]   lsAahb_hwdata;
wire [0:0]    lsAahb_hauserchk;
wire [3:0]    lsAahb_haddrchk;
wire          lsAahb_htranschk;
wire          lsAahb_hctrlchk1;
wire          lsAahb_hctrlchk2;
wire          lsAahb_hprotchk;
wire          lsAahb_hwstrbchk;
wire          lsAahb_hreadychk;
wire          lsAahb_hrespchk;
wire [3:0]    lsAahb_hrdatachk;
wire [3:0]    lsAahb_hwdatachk;
wire          lsAahb_fatal_err;
wire          lsAdbu_per_ahb_hmastlock;
wire          lsAdbu_per_ahb_hexcl;
wire [3:0]    lsAdbu_per_ahb_hmaster;
wire [7:0]    lsAdbu_per_ahb_hauser;
wire          lsAdbu_per_ahb_hwrite;
wire [31:0]   lsAdbu_per_ahb_haddr;
wire [1:0]    lsAdbu_per_ahb_htrans;
wire [2:0]    lsAdbu_per_ahb_hsize;
wire [2:0]    lsAdbu_per_ahb_hburst;
wire [3:0]    lsAdbu_per_ahb_hwstrb;
wire [6:0]    lsAdbu_per_ahb_hprot;
wire          lsAdbu_per_ahb_hnonsec;
wire          lsAdbu_per_ahb_hready;
wire          lsAdbu_per_ahb_hresp;
wire          lsAdbu_per_ahb_hexokay;
wire [31:0]   lsAdbu_per_ahb_hrdata;
wire [31:0]   lsAdbu_per_ahb_hwdata;
wire [0:0]    lsAdbu_per_ahb_hauserchk;
wire [3:0]    lsAdbu_per_ahb_haddrchk;
wire          lsAdbu_per_ahb_htranschk;
wire          lsAdbu_per_ahb_hctrlchk1;
wire          lsAdbu_per_ahb_hctrlchk2;
wire          lsAdbu_per_ahb_hprotchk;
wire          lsAdbu_per_ahb_hwstrbchk;
wire          lsAdbu_per_ahb_hreadychk;
wire          lsAdbu_per_ahb_hrespchk;
wire [3:0]    lsAdbu_per_ahb_hrdatachk;
wire [3:0]    lsAdbu_per_ahb_hwdatachk;
wire          lsAdbu_per_ahb_fatal_err;
wire          lsAiccm_ahb_prio;
wire          lsAiccm_ahb_hmastlock;
wire          lsAiccm_ahb_hexcl;
wire [3:0]    lsAiccm_ahb_hmaster;
wire [0:0]    lsAiccm_ahb_hsel;
wire [1:0]    lsAiccm_ahb_htrans;
wire          lsAiccm_ahb_hwrite;
wire [31:0]   lsAiccm_ahb_haddr;
wire [2:0]    lsAiccm_ahb_hsize;
wire [3:0]    lsAiccm_ahb_hwstrb;
wire [2:0]    lsAiccm_ahb_hburst;
wire [6:0]    lsAiccm_ahb_hprot;
wire          lsAiccm_ahb_hnonsec;
wire [31:0]   lsAiccm_ahb_hwdata;
wire          lsAiccm_ahb_hready;
wire [31:0]   lsAiccm_ahb_hrdata;
wire          lsAiccm_ahb_hresp;
wire          lsAiccm_ahb_hexokay;
wire          lsAiccm_ahb_hreadyout;
wire [3:0]    lsAiccm_ahb_haddrchk;
wire          lsAiccm_ahb_htranschk;
wire          lsAiccm_ahb_hctrlchk1;
wire          lsAiccm_ahb_hctrlchk2;
wire          lsAiccm_ahb_hwstrbchk;
wire          lsAiccm_ahb_hprotchk;
wire          lsAiccm_ahb_hreadychk;
wire          lsAiccm_ahb_hrespchk;
wire          lsAiccm_ahb_hreadyoutchk;
wire          lsAiccm_ahb_hselchk;
wire [3:0]    lsAiccm_ahb_hrdatachk;
wire [3:0]    lsAiccm_ahb_hwdatachk;
wire          lsAiccm_ahb_fatal_err;
wire          lsAdccm_ahb_prio;
wire          lsAdccm_ahb_hmastlock;
wire          lsAdccm_ahb_hexcl;
wire [3:0]    lsAdccm_ahb_hmaster;
wire [0:0]    lsAdccm_ahb_hsel;
wire [1:0]    lsAdccm_ahb_htrans;
wire          lsAdccm_ahb_hwrite;
wire [31:0]   lsAdccm_ahb_haddr;
wire [2:0]    lsAdccm_ahb_hsize;
wire [3:0]    lsAdccm_ahb_hwstrb;
wire          lsAdccm_ahb_hnonsec;
wire [2:0]    lsAdccm_ahb_hburst;
wire [6:0]    lsAdccm_ahb_hprot;
wire [31:0]   lsAdccm_ahb_hwdata;
wire          lsAdccm_ahb_hready;
wire [31:0]   lsAdccm_ahb_hrdata;
wire          lsAdccm_ahb_hresp;
wire          lsAdccm_ahb_hexokay;
wire          lsAdccm_ahb_hreadyout;
wire [3:0]    lsAdccm_ahb_haddrchk;
wire          lsAdccm_ahb_htranschk;
wire          lsAdccm_ahb_hctrlchk1;
wire          lsAdccm_ahb_hctrlchk2;
wire          lsAdccm_ahb_hwstrbchk;
wire          lsAdccm_ahb_hprotchk;
wire          lsAdccm_ahb_hreadychk;
wire          lsAdccm_ahb_hrespchk;
wire          lsAdccm_ahb_hreadyoutchk;
wire          lsAdccm_ahb_hselchk;
wire [3:0]    lsAdccm_ahb_hrdatachk;
wire [3:0]    lsAdccm_ahb_hwdatachk;
wire          lsAdccm_ahb_fatal_err;
wire          lsAmmio_ahb_prio;
wire          lsAmmio_ahb_hmastlock;
wire          lsAmmio_ahb_hexcl;
wire [3:0]    lsAmmio_ahb_hmaster;
wire          lsAmmio_ahb_hsel;
wire [1:0]    lsAmmio_ahb_htrans;
wire          lsAmmio_ahb_hwrite;
wire [31:0]   lsAmmio_ahb_haddr;
wire [2:0]    lsAmmio_ahb_hsize;
wire [3:0]    lsAmmio_ahb_hwstrb;
wire          lsAmmio_ahb_hnonsec;
wire [2:0]    lsAmmio_ahb_hburst;
wire [6:0]    lsAmmio_ahb_hprot;
wire [31:0]   lsAmmio_ahb_hwdata;
wire          lsAmmio_ahb_hready;
wire [31:0]   lsAmmio_ahb_hrdata;
wire          lsAmmio_ahb_hresp;
wire          lsAmmio_ahb_hexokay;
wire          lsAmmio_ahb_hreadyout;
wire [3:0]    lsAmmio_ahb_haddrchk;
wire          lsAmmio_ahb_htranschk;
wire          lsAmmio_ahb_hctrlchk1;
wire          lsAmmio_ahb_hctrlchk2;
wire          lsAmmio_ahb_hwstrbchk;
wire          lsAmmio_ahb_hprotchk;
wire          lsAmmio_ahb_hreadychk;
wire          lsAmmio_ahb_hrespchk;
wire          lsAmmio_ahb_hreadyoutchk;
wire          lsAmmio_ahb_hselchk;
wire [3:0]    lsAmmio_ahb_hrdatachk;
wire [3:0]    lsAmmio_ahb_hwdatachk;
wire          lsAmmio_ahb_fatal_err;
wire [11:0]   lsAmmio_base_in;
wire [21:0]   lsAreset_pc_in;
wire          lsArnmi_synch_r;
wire          lsAesrams_iccm0_clk;
wire [39:0]   lsAesrams_iccm0_din;
wire [18:2]   lsAesrams_iccm0_addr;
wire          lsAesrams_iccm0_cs;
wire          lsAesrams_iccm0_we;
wire [4:0]    lsAesrams_iccm0_wem;
wire [39:0]   lsAesrams_iccm0_dout;
wire          lsAesrams_dccm_even_clk;
wire [39:0]   lsAesrams_dccm_din_even;
wire [19:3]   lsAesrams_dccm_addr_even;
wire          lsAesrams_dccm_cs_even;
wire          lsAesrams_dccm_we_even;
wire [4:0]    lsAesrams_dccm_wem_even;
wire [39:0]   lsAesrams_dccm_dout_even;
wire          lsAesrams_dccm_odd_clk;
wire [39:0]   lsAesrams_dccm_din_odd;
wire [19:3]   lsAesrams_dccm_addr_odd;
wire          lsAesrams_dccm_cs_odd;
wire          lsAesrams_dccm_we_odd;
wire [4:0]    lsAesrams_dccm_wem_odd;
wire [39:0]   lsAesrams_dccm_dout_odd;
wire          lsAesrams_ic_tag_mem_clk;
wire [55:0]   lsAesrams_ic_tag_mem_din;
wire [12:5]   lsAesrams_ic_tag_mem_addr;
wire          lsAesrams_ic_tag_mem_cs;
wire          lsAesrams_ic_tag_mem_we;
wire [55:0]   lsAesrams_ic_tag_mem_wem;
wire [55:0]   lsAesrams_ic_tag_mem_dout;
wire          lsAesrams_ic_data_mem_clk;
wire [79:0]   lsAesrams_ic_data_mem_din;
wire [12:2]   lsAesrams_ic_data_mem_addr;
wire          lsAesrams_ic_data_mem_cs;
wire          lsAesrams_ic_data_mem_we;
wire [79:0]   lsAesrams_ic_data_mem_wem;
wire [79:0]   lsAesrams_ic_data_mem_dout;
wire          lsAesrams_clk;
wire          lsAesrams_ls;
wire [1:0]    lsAext_trig_output_accept;
wire [15:0]   lsAext_trig_in;
wire [1:0]    lsAext_trig_output_valid;
wire          lsAhigh_prio_ras;
wire [1:0]    lsAsafety_comparator_enable;
wire [15:0]   lsAlsc_diag_aux_r;
wire [1:0]    lsAdr_lsc_stl_ctrl_aux_r;
wire          lsAlsc_shd_ctrl_aux_r;
wire [1:0]    lsAdr_sfty_aux_parity_err_r;
wire [1:0]    lsAdr_bus_fatal_err;
wire [1:0]    lsAdr_safety_comparator_enabled;
wire          lsAsafety_iso_enb_synch_r;
wire          lsAsfty_nsi_r;
wire [13:0]   lsAlsc_err_stat_aux;
wire [1:0]    lsAdr_sfty_eic;
wire [1:0]    lsAdr_safety_iso_err;
wire [1:0]    lsAdr_secure_trig_iso_err;
wire          lsAsfty_mem_sbe_err;
wire          lsAsfty_mem_dbe_err;
wire          lsAsfty_mem_adr_err;
wire          lsAsfty_mem_sbe_overflow;
wire          lsAsfty_ibp_mmio_cmd_valid;
wire [3:0]    lsAsfty_ibp_mmio_cmd_cache;
wire          lsAsfty_ibp_mmio_cmd_burst_size;
wire          lsAsfty_ibp_mmio_cmd_read;
wire          lsAsfty_ibp_mmio_cmd_aux;
wire          lsAsfty_ibp_mmio_cmd_accept;
wire [7:0]    lsAsfty_ibp_mmio_cmd_addr;
wire          lsAsfty_ibp_mmio_cmd_excl;
wire [5:0]    lsAsfty_ibp_mmio_cmd_atomic;
wire [2:0]    lsAsfty_ibp_mmio_cmd_data_size;
wire [1:0]    lsAsfty_ibp_mmio_cmd_prot;
wire          lsAsfty_ibp_mmio_wr_valid;
wire          lsAsfty_ibp_mmio_wr_last;
wire          lsAsfty_ibp_mmio_wr_accept;
wire [3:0]    lsAsfty_ibp_mmio_wr_mask;
wire [31:0]   lsAsfty_ibp_mmio_wr_data;
wire          lsAsfty_ibp_mmio_rd_valid;
wire          lsAsfty_ibp_mmio_rd_err;
wire          lsAsfty_ibp_mmio_rd_excl_ok;
wire          lsAsfty_ibp_mmio_rd_last;
wire          lsAsfty_ibp_mmio_rd_accept;
wire [31:0]   lsAsfty_ibp_mmio_rd_data;
wire          lsAsfty_ibp_mmio_wr_done;
wire          lsAsfty_ibp_mmio_wr_excl_okay;
wire          lsAsfty_ibp_mmio_wr_err;
wire          lsAsfty_ibp_mmio_wr_resp_accept;
wire          lsAsfty_ibp_mmio_cmd_valid_pty;
wire          lsAsfty_ibp_mmio_cmd_accept_pty;
wire          lsAsfty_ibp_mmio_cmd_addr_pty;
wire [3:0]    lsAsfty_ibp_mmio_cmd_ctrl_pty;
wire          lsAsfty_ibp_mmio_wr_valid_pty;
wire          lsAsfty_ibp_mmio_wr_accept_pty;
wire          lsAsfty_ibp_mmio_wr_last_pty;
wire          lsAsfty_ibp_mmio_rd_valid_pty;
wire          lsAsfty_ibp_mmio_rd_accept_pty;
wire          lsAsfty_ibp_mmio_rd_ctrl_pty;
wire [3:0]    lsAsfty_ibp_mmio_rd_data_pty;
wire          lsAsfty_ibp_mmio_wr_done_pty;
wire          lsAsfty_ibp_mmio_wr_ctrl_pty;
wire          lsAsfty_ibp_mmio_wr_resp_accept_pty;
wire          lsAsfty_ibp_mmio_ini_e2e_err;
wire          lsAwdt_reset0;
wire          lsAreg_wr_en0;
wire          lsAwdt_clk_enable_sync;
wire          lsAwdt_feedback_bit;
wire          lsAdmsi_valid;
wire [0:0]    lsAdmsi_context;
wire [5:0]    lsAdmsi_eiid;
wire          lsAdmsi_domain;
wire          lsAdmsi_rdy;
wire          lsAdmsi_valid_chk;
wire [5:0]    lsAdmsi_data_edc;
wire          lsAdmsi_rdy_chk;
wire          lsAsfty_dmsi_tgt_e2e_err;
wire          lsAdbg_ibp_cmd_valid;
wire          lsAdbg_ibp_cmd_read;
wire [31:0]   lsAdbg_ibp_cmd_addr;
wire          lsAdbg_ibp_cmd_accept;
wire [3:0]    lsAdbg_ibp_cmd_space;
wire          lsAdbg_ibp_rd_valid;
wire          lsAdbg_ibp_rd_accept;
wire          lsAdbg_ibp_rd_err;
wire [31:0]   lsAdbg_ibp_rd_data;
wire          lsAdbg_ibp_wr_valid;
wire          lsAdbg_ibp_wr_accept;
wire [31:0]   lsAdbg_ibp_wr_data;
wire [3:0]    lsAdbg_ibp_wr_mask;
wire          lsAdbg_ibp_wr_done;
wire          lsAdbg_ibp_wr_err;
wire          lsAdbg_ibp_wr_resp_accept;
wire [4:0]    lsAwid_rlwid;
wire [63:0]   lsAwid_rwiddeleg;
wire          lsAsoft_reset_prepare_synch_r;
wire          lsAsoft_reset_req_synch_r;
wire          lsAsoft_reset_ready;
wire          lsAsoft_reset_ack;
wire          lsAcpu_in_reset_state;
wire          lsArst_init_disable_synch_r;
wire [1:0]    lsAiccm0_gclk_cnt;
wire [1:0]    lsAdccm_even_gclk_cnt;
wire [1:0]    lsAdccm_odd_gclk_cnt;
wire [1:0]    lsAic_tag_mem_gclk_cnt;
wire [1:0]    lsAic_data_mem_gclk_cnt;
wire [1:0]    lsAgclk_cnt;
wire [7:0]    lsAarcnum;
wire          lsAsys_halt_r;
wire          lsAsys_sleep_r;
wire          lsAcritical_error;
wire [2:0]    lsAsys_sleep_mode_r;
wire          lsBclk;
wire          lsBtm_clk_enable_sync;
wire          lsBrst_synch_r;
wire          lsBrst_cpu_req_synch_r;
wire          lsBrst_cpu_ack;
wire          lsBcpu_rst_gated;
wire          lsBcpu_clk_gated;
wire          lsBtest_mode;
wire          lsBLBIST_EN;
wire          lsBdm2arc_halt_req_synch_r;
wire          lsBdm2arc_run_req_synch_r;
wire          lsBarc2dm_halt_ack;
wire          lsBarc2dm_run_ack;
wire          lsBdm2arc_hartreset_synch_r;
wire          lsBdm2arc_hartreset2_synch_r;
wire          lsBndmreset_synch_r;
wire          lsBdm2arc_havereset_ack_synch_r;
wire          lsBdm2arc_halt_on_reset_synch_r;
wire          lsBarc2dm_havereset_a;
wire          lsBdm2arc_relaxedpriv_synch_r;
wire          lsBhart_unavailable;
wire          lsBahb_hmastlock;
wire          lsBahb_hexcl;
wire [3:0]    lsBahb_hmaster;
wire [7:0]    lsBahb_hauser;
wire          lsBahb_hwrite;
wire [31:0]   lsBahb_haddr;
wire [1:0]    lsBahb_htrans;
wire [2:0]    lsBahb_hsize;
wire [2:0]    lsBahb_hburst;
wire [3:0]    lsBahb_hwstrb;
wire [6:0]    lsBahb_hprot;
wire          lsBahb_hnonsec;
wire          lsBahb_hready;
wire          lsBahb_hresp;
wire          lsBahb_hexokay;
wire [31:0]   lsBahb_hrdata;
wire [31:0]   lsBahb_hwdata;
wire [0:0]    lsBahb_hauserchk;
wire [3:0]    lsBahb_haddrchk;
wire          lsBahb_htranschk;
wire          lsBahb_hctrlchk1;
wire          lsBahb_hctrlchk2;
wire          lsBahb_hprotchk;
wire          lsBahb_hwstrbchk;
wire          lsBahb_hreadychk;
wire          lsBahb_hrespchk;
wire [3:0]    lsBahb_hrdatachk;
wire [3:0]    lsBahb_hwdatachk;
wire          lsBahb_fatal_err;
wire          lsBdbu_per_ahb_hmastlock;
wire          lsBdbu_per_ahb_hexcl;
wire [3:0]    lsBdbu_per_ahb_hmaster;
wire [7:0]    lsBdbu_per_ahb_hauser;
wire          lsBdbu_per_ahb_hwrite;
wire [31:0]   lsBdbu_per_ahb_haddr;
wire [1:0]    lsBdbu_per_ahb_htrans;
wire [2:0]    lsBdbu_per_ahb_hsize;
wire [2:0]    lsBdbu_per_ahb_hburst;
wire [3:0]    lsBdbu_per_ahb_hwstrb;
wire [6:0]    lsBdbu_per_ahb_hprot;
wire          lsBdbu_per_ahb_hnonsec;
wire          lsBdbu_per_ahb_hready;
wire          lsBdbu_per_ahb_hresp;
wire          lsBdbu_per_ahb_hexokay;
wire [31:0]   lsBdbu_per_ahb_hrdata;
wire [31:0]   lsBdbu_per_ahb_hwdata;
wire [0:0]    lsBdbu_per_ahb_hauserchk;
wire [3:0]    lsBdbu_per_ahb_haddrchk;
wire          lsBdbu_per_ahb_htranschk;
wire          lsBdbu_per_ahb_hctrlchk1;
wire          lsBdbu_per_ahb_hctrlchk2;
wire          lsBdbu_per_ahb_hprotchk;
wire          lsBdbu_per_ahb_hwstrbchk;
wire          lsBdbu_per_ahb_hreadychk;
wire          lsBdbu_per_ahb_hrespchk;
wire [3:0]    lsBdbu_per_ahb_hrdatachk;
wire [3:0]    lsBdbu_per_ahb_hwdatachk;
wire          lsBdbu_per_ahb_fatal_err;
wire          lsBiccm_ahb_prio;
wire          lsBiccm_ahb_hmastlock;
wire          lsBiccm_ahb_hexcl;
wire [3:0]    lsBiccm_ahb_hmaster;
wire [0:0]    lsBiccm_ahb_hsel;
wire [1:0]    lsBiccm_ahb_htrans;
wire          lsBiccm_ahb_hwrite;
wire [31:0]   lsBiccm_ahb_haddr;
wire [2:0]    lsBiccm_ahb_hsize;
wire [3:0]    lsBiccm_ahb_hwstrb;
wire [2:0]    lsBiccm_ahb_hburst;
wire [6:0]    lsBiccm_ahb_hprot;
wire          lsBiccm_ahb_hnonsec;
wire [31:0]   lsBiccm_ahb_hwdata;
wire          lsBiccm_ahb_hready;
wire [31:0]   lsBiccm_ahb_hrdata;
wire          lsBiccm_ahb_hresp;
wire          lsBiccm_ahb_hexokay;
wire          lsBiccm_ahb_hreadyout;
wire [3:0]    lsBiccm_ahb_haddrchk;
wire          lsBiccm_ahb_htranschk;
wire          lsBiccm_ahb_hctrlchk1;
wire          lsBiccm_ahb_hctrlchk2;
wire          lsBiccm_ahb_hwstrbchk;
wire          lsBiccm_ahb_hprotchk;
wire          lsBiccm_ahb_hreadychk;
wire          lsBiccm_ahb_hrespchk;
wire          lsBiccm_ahb_hreadyoutchk;
wire          lsBiccm_ahb_hselchk;
wire [3:0]    lsBiccm_ahb_hrdatachk;
wire [3:0]    lsBiccm_ahb_hwdatachk;
wire          lsBiccm_ahb_fatal_err;
wire          lsBdccm_ahb_prio;
wire          lsBdccm_ahb_hmastlock;
wire          lsBdccm_ahb_hexcl;
wire [3:0]    lsBdccm_ahb_hmaster;
wire [0:0]    lsBdccm_ahb_hsel;
wire [1:0]    lsBdccm_ahb_htrans;
wire          lsBdccm_ahb_hwrite;
wire [31:0]   lsBdccm_ahb_haddr;
wire [2:0]    lsBdccm_ahb_hsize;
wire [3:0]    lsBdccm_ahb_hwstrb;
wire          lsBdccm_ahb_hnonsec;
wire [2:0]    lsBdccm_ahb_hburst;
wire [6:0]    lsBdccm_ahb_hprot;
wire [31:0]   lsBdccm_ahb_hwdata;
wire          lsBdccm_ahb_hready;
wire [31:0]   lsBdccm_ahb_hrdata;
wire          lsBdccm_ahb_hresp;
wire          lsBdccm_ahb_hexokay;
wire          lsBdccm_ahb_hreadyout;
wire [3:0]    lsBdccm_ahb_haddrchk;
wire          lsBdccm_ahb_htranschk;
wire          lsBdccm_ahb_hctrlchk1;
wire          lsBdccm_ahb_hctrlchk2;
wire          lsBdccm_ahb_hwstrbchk;
wire          lsBdccm_ahb_hprotchk;
wire          lsBdccm_ahb_hreadychk;
wire          lsBdccm_ahb_hrespchk;
wire          lsBdccm_ahb_hreadyoutchk;
wire          lsBdccm_ahb_hselchk;
wire [3:0]    lsBdccm_ahb_hrdatachk;
wire [3:0]    lsBdccm_ahb_hwdatachk;
wire          lsBdccm_ahb_fatal_err;
wire          lsBmmio_ahb_prio;
wire          lsBmmio_ahb_hmastlock;
wire          lsBmmio_ahb_hexcl;
wire [3:0]    lsBmmio_ahb_hmaster;
wire          lsBmmio_ahb_hsel;
wire [1:0]    lsBmmio_ahb_htrans;
wire          lsBmmio_ahb_hwrite;
wire [31:0]   lsBmmio_ahb_haddr;
wire [2:0]    lsBmmio_ahb_hsize;
wire [3:0]    lsBmmio_ahb_hwstrb;
wire          lsBmmio_ahb_hnonsec;
wire [2:0]    lsBmmio_ahb_hburst;
wire [6:0]    lsBmmio_ahb_hprot;
wire [31:0]   lsBmmio_ahb_hwdata;
wire          lsBmmio_ahb_hready;
wire [31:0]   lsBmmio_ahb_hrdata;
wire          lsBmmio_ahb_hresp;
wire          lsBmmio_ahb_hexokay;
wire          lsBmmio_ahb_hreadyout;
wire [3:0]    lsBmmio_ahb_haddrchk;
wire          lsBmmio_ahb_htranschk;
wire          lsBmmio_ahb_hctrlchk1;
wire          lsBmmio_ahb_hctrlchk2;
wire          lsBmmio_ahb_hwstrbchk;
wire          lsBmmio_ahb_hprotchk;
wire          lsBmmio_ahb_hreadychk;
wire          lsBmmio_ahb_hrespchk;
wire          lsBmmio_ahb_hreadyoutchk;
wire          lsBmmio_ahb_hselchk;
wire [3:0]    lsBmmio_ahb_hrdatachk;
wire [3:0]    lsBmmio_ahb_hwdatachk;
wire          lsBmmio_ahb_fatal_err;
wire [11:0]   lsBmmio_base_in;
wire [21:0]   lsBreset_pc_in;
wire          lsBrnmi_synch_r;
wire          lsBesrams_iccm0_clk;
wire [39:0]   lsBesrams_iccm0_din;
wire [18:2]   lsBesrams_iccm0_addr;
wire          lsBesrams_iccm0_cs;
wire          lsBesrams_iccm0_we;
wire [4:0]    lsBesrams_iccm0_wem;
wire [39:0]   lsBesrams_iccm0_dout;
wire          lsBesrams_dccm_even_clk;
wire [39:0]   lsBesrams_dccm_din_even;
wire [19:3]   lsBesrams_dccm_addr_even;
wire          lsBesrams_dccm_cs_even;
wire          lsBesrams_dccm_we_even;
wire [4:0]    lsBesrams_dccm_wem_even;
wire [39:0]   lsBesrams_dccm_dout_even;
wire          lsBesrams_dccm_odd_clk;
wire [39:0]   lsBesrams_dccm_din_odd;
wire [19:3]   lsBesrams_dccm_addr_odd;
wire          lsBesrams_dccm_cs_odd;
wire          lsBesrams_dccm_we_odd;
wire [4:0]    lsBesrams_dccm_wem_odd;
wire [39:0]   lsBesrams_dccm_dout_odd;
wire          lsBesrams_ic_tag_mem_clk;
wire [55:0]   lsBesrams_ic_tag_mem_din;
wire [12:5]   lsBesrams_ic_tag_mem_addr;
wire          lsBesrams_ic_tag_mem_cs;
wire          lsBesrams_ic_tag_mem_we;
wire [55:0]   lsBesrams_ic_tag_mem_wem;
wire [55:0]   lsBesrams_ic_tag_mem_dout;
wire          lsBesrams_ic_data_mem_clk;
wire [79:0]   lsBesrams_ic_data_mem_din;
wire [12:2]   lsBesrams_ic_data_mem_addr;
wire          lsBesrams_ic_data_mem_cs;
wire          lsBesrams_ic_data_mem_we;
wire [79:0]   lsBesrams_ic_data_mem_wem;
wire [79:0]   lsBesrams_ic_data_mem_dout;
wire          lsBesrams_clk;
wire          lsBesrams_ls;
wire [1:0]    lsBext_trig_output_accept;
wire [15:0]   lsBext_trig_in;
wire [1:0]    lsBext_trig_output_valid;
wire          lsBhigh_prio_ras;
wire [1:0]    lsBsafety_comparator_enable;
wire [15:0]   lsBlsc_diag_aux_r;
wire [1:0]    lsBdr_lsc_stl_ctrl_aux_r;
wire          lsBlsc_shd_ctrl_aux_r;
wire [1:0]    lsBdr_sfty_aux_parity_err_r;
wire [1:0]    lsBdr_bus_fatal_err;
wire [1:0]    lsBdr_safety_comparator_enabled;
wire          lsBsafety_iso_enb_synch_r;
wire          lsBsfty_nsi_r;
wire [13:0]   lsBlsc_err_stat_aux;
wire [1:0]    lsBdr_sfty_eic;
wire [1:0]    lsBdr_safety_iso_err;
wire [1:0]    lsBdr_secure_trig_iso_err;
wire          lsBsfty_mem_sbe_err;
wire          lsBsfty_mem_dbe_err;
wire          lsBsfty_mem_adr_err;
wire          lsBsfty_mem_sbe_overflow;
wire          lsBsfty_ibp_mmio_cmd_valid;
wire [3:0]    lsBsfty_ibp_mmio_cmd_cache;
wire          lsBsfty_ibp_mmio_cmd_burst_size;
wire          lsBsfty_ibp_mmio_cmd_read;
wire          lsBsfty_ibp_mmio_cmd_aux;
wire          lsBsfty_ibp_mmio_cmd_accept;
wire [7:0]    lsBsfty_ibp_mmio_cmd_addr;
wire          lsBsfty_ibp_mmio_cmd_excl;
wire [5:0]    lsBsfty_ibp_mmio_cmd_atomic;
wire [2:0]    lsBsfty_ibp_mmio_cmd_data_size;
wire [1:0]    lsBsfty_ibp_mmio_cmd_prot;
wire          lsBsfty_ibp_mmio_wr_valid;
wire          lsBsfty_ibp_mmio_wr_last;
wire          lsBsfty_ibp_mmio_wr_accept;
wire [3:0]    lsBsfty_ibp_mmio_wr_mask;
wire [31:0]   lsBsfty_ibp_mmio_wr_data;
wire          lsBsfty_ibp_mmio_rd_valid;
wire          lsBsfty_ibp_mmio_rd_err;
wire          lsBsfty_ibp_mmio_rd_excl_ok;
wire          lsBsfty_ibp_mmio_rd_last;
wire          lsBsfty_ibp_mmio_rd_accept;
wire [31:0]   lsBsfty_ibp_mmio_rd_data;
wire          lsBsfty_ibp_mmio_wr_done;
wire          lsBsfty_ibp_mmio_wr_excl_okay;
wire          lsBsfty_ibp_mmio_wr_err;
wire          lsBsfty_ibp_mmio_wr_resp_accept;
wire          lsBsfty_ibp_mmio_cmd_valid_pty;
wire          lsBsfty_ibp_mmio_cmd_accept_pty;
wire          lsBsfty_ibp_mmio_cmd_addr_pty;
wire [3:0]    lsBsfty_ibp_mmio_cmd_ctrl_pty;
wire          lsBsfty_ibp_mmio_wr_valid_pty;
wire          lsBsfty_ibp_mmio_wr_accept_pty;
wire          lsBsfty_ibp_mmio_wr_last_pty;
wire          lsBsfty_ibp_mmio_rd_valid_pty;
wire          lsBsfty_ibp_mmio_rd_accept_pty;
wire          lsBsfty_ibp_mmio_rd_ctrl_pty;
wire [3:0]    lsBsfty_ibp_mmio_rd_data_pty;
wire          lsBsfty_ibp_mmio_wr_done_pty;
wire          lsBsfty_ibp_mmio_wr_ctrl_pty;
wire          lsBsfty_ibp_mmio_wr_resp_accept_pty;
wire          lsBsfty_ibp_mmio_ini_e2e_err;
wire          lsBwdt_reset0;
wire          lsBreg_wr_en0;
wire          lsBwdt_clk_enable_sync;
wire          lsBwdt_feedback_bit;
wire          lsBdmsi_valid;
wire [0:0]    lsBdmsi_context;
wire [5:0]    lsBdmsi_eiid;
wire          lsBdmsi_domain;
wire          lsBdmsi_rdy;
wire          lsBdmsi_valid_chk;
wire [5:0]    lsBdmsi_data_edc;
wire          lsBdmsi_rdy_chk;
wire          lsBsfty_dmsi_tgt_e2e_err;
wire          lsBdbg_ibp_cmd_valid;
wire          lsBdbg_ibp_cmd_read;
wire [31:0]   lsBdbg_ibp_cmd_addr;
wire          lsBdbg_ibp_cmd_accept;
wire [3:0]    lsBdbg_ibp_cmd_space;
wire          lsBdbg_ibp_rd_valid;
wire          lsBdbg_ibp_rd_accept;
wire          lsBdbg_ibp_rd_err;
wire [31:0]   lsBdbg_ibp_rd_data;
wire          lsBdbg_ibp_wr_valid;
wire          lsBdbg_ibp_wr_accept;
wire [31:0]   lsBdbg_ibp_wr_data;
wire [3:0]    lsBdbg_ibp_wr_mask;
wire          lsBdbg_ibp_wr_done;
wire          lsBdbg_ibp_wr_err;
wire          lsBdbg_ibp_wr_resp_accept;
wire [4:0]    lsBwid_rlwid;
wire [63:0]   lsBwid_rwiddeleg;
wire          lsBsoft_reset_prepare_synch_r;
wire          lsBsoft_reset_req_synch_r;
wire          lsBsoft_reset_ready;
wire          lsBsoft_reset_ack;
wire          lsBcpu_in_reset_state;
wire          lsBrst_init_disable_synch_r;
wire [1:0]    lsBiccm0_gclk_cnt;
wire [1:0]    lsBdccm_even_gclk_cnt;
wire [1:0]    lsBdccm_odd_gclk_cnt;
wire [1:0]    lsBic_tag_mem_gclk_cnt;
wire [1:0]    lsBic_data_mem_gclk_cnt;
wire [1:0]    lsBgclk_cnt;
wire [7:0]    lsBarcnum;
wire          lsBsys_halt_r;
wire          lsBsys_sleep_r;
wire          lsBcritical_error;
wire [2:0]    lsBsys_sleep_mode_r;

  wire	cpu_synch_top_parity_error_r;
  wire	soft_reset_req_synch_r;
  wire	soft_reset_prepare_synch_r;
  wire	ndmreset_synch_r;
  wire	dm2arc_hartreset_synch_r;
  wire	dm2arc_hartreset2_synch_r;
  wire	dm2arc_havereset_ack_synch_r;
  wire	dm2arc_halt_on_reset_synch_r;
  wire	rst_init_disable_synch_r;
  wire	rst_cpu_req_synch_r;
  wire	rst_synch_r;
  wire	tm_clk_enable_sync;
  wire	wdt_feedback_bit;
  wire	wdt_clk_enable_sync;
  wire	dm2arc_halt_req_synch_r;
  wire	dm2arc_run_req_synch_r;
  wire	dm2arc_relaxedpriv_synch_r;
  wire	safety_iso_enb_synch_r;
  wire	rnmi_synch_r;
  rl_cpu_synch_wrap u_rl_cpu_synch_wrap (
  .cpu_synch_top_parity_error_r	(cpu_synch_top_parity_error_r),
  .soft_reset_req_synch_r	(soft_reset_req_synch_r),
  .soft_reset_prepare_synch_r	(soft_reset_prepare_synch_r),
  .ndmreset_synch_r	(ndmreset_synch_r),
  .dm2arc_hartreset_synch_r	(dm2arc_hartreset_synch_r),
  .dm2arc_hartreset2_synch_r	(dm2arc_hartreset2_synch_r),
  .dm2arc_havereset_ack_synch_r	(dm2arc_havereset_ack_synch_r),
  .dm2arc_halt_on_reset_synch_r	(dm2arc_halt_on_reset_synch_r),
  .rst_init_disable_synch_r	(rst_init_disable_synch_r),
  .rst_cpu_req_synch_r	(rst_cpu_req_synch_r),
  .rst_synch_r	(rst_synch_r),
  .tm_clk_enable_sync	(tm_clk_enable_sync),
  .wdt_feedback_bit	(wdt_feedback_bit),
  .wdt_clk_enable_sync	(wdt_clk_enable_sync),
  .dm2arc_halt_req_synch_r	(dm2arc_halt_req_synch_r),
  .dm2arc_run_req_synch_r	(dm2arc_run_req_synch_r),
  .dm2arc_relaxedpriv_synch_r	(dm2arc_relaxedpriv_synch_r),
  .safety_iso_enb_synch_r	(safety_iso_enb_synch_r),
  .rnmi_synch_r	(rnmi_synch_r),
  .ref_clk	(ref_clk),
  .wdt_clk	(wdt_clk),
  .wdt_reset_wdt_clk0	(wdt_reset_wdt_clk0),
  .soft_reset_req_a	(soft_reset_req_a),
  .soft_reset_prepare_a	(soft_reset_prepare_a),
  .ndmreset_a	(ndmreset_a),
  .dm2arc_hartreset_a	(dm2arc_hartreset_a),
  .dm2arc_hartreset2_a	(dm2arc_hartreset2_a),
  .dm2arc_havereset_ack_a	(dm2arc_havereset_ack_a),
  .dm2arc_halt_on_reset_a	(dm2arc_halt_on_reset_a),
  .rst_init_disable_a	(rst_init_disable_a),
  .rst_cpu_req_a	(rst_cpu_req_a),
  .rst_a	(rst_a),
  .test_mode	(test_mode),
  .LBIST_EN	(LBIST_EN),
  .dm2arc_halt_req_a	(dm2arc_halt_req_a),
  .dm2arc_run_req_a	(dm2arc_run_req_a),
  .dm2arc_relaxedpriv_a	(dm2arc_relaxedpriv_a),
  .safety_iso_enb_a	(safety_iso_enb_a),
  .rnmi_a	(rnmi_a),

        .cpu_clk_gated         (cpu_clk_gated          ), // gated clock from reset ctrl
        .cpu_rst_gated         (cpu_rst_gated          ), // aggregated reset from reset ctrl
        .clk         (clk          ) // clock input for this reset domain
        );

  //Send to CPU
  assign lsAclk           = clk;


wire ls_enabled, ls_enabled_d;

wire lsAls_ctrl_enable;  // INPUT FROM CORE
wire lsBls_ctrl_enable;  // INPUT FROM CORE
assign lsAls_ctrl_enable = (lsAsafety_comparator_enable == 2'b10) ? 1'b1 : 1'b0;       // INPUT FROM CORE
assign lsBls_ctrl_enable = (lsBsafety_comparator_enable == 2'b10) ? 1'b1 : 1'b0;       // INPUT FROM CORE


wire lsAls_enabled;          // OUTPUT TO CORE
wire lsBls_enabled;          // OUTPUT TO CORE
reg   lock_reset_nxt;

   always_comb
     begin: lock_reset_cpu_PROC
        if (lsAlsc_diag_aux_r[1:0] == 2'b10)
          lock_reset_nxt = 1'b1;
        else
          lock_reset_nxt = 1'b0;
     end

  wire ls_lock_reset = lock_reset_nxt;   //From Master Core

assign lsAls_enabled = ls_enabled;
assign lsBls_enabled = ls_enabled_d;

  // Fixed output registers.
  assign cpu_lsAls_lock_reset = ls_lock_reset;
  assign cpu_lsAsafety_comparator_enabled = (cpu_clk_gate_enable) ? {ls_enabled,~ls_enabled}   : 2'b01;
  assign cpu_lsBsafety_comparator_enabled = (cpu_clk_gate_enable) ? {ls_enabled_d, ~ls_enabled_d}  : 2'b01;

// The two bits are passed into the error module.
  //
  // Lockstep enables will automatically disable when either core is in halt
  //
  assign halt_asserted       = lsAsys_halt_r | lsBsys_halt_r;
  assign cpu_clk_gate_enable =  ~(halt_asserted);
  wire [1:0] ls_ctrl_enable = (halt_asserted) ? 2'b00 :{ lsAls_ctrl_enable , lsBls_ctrl_enable };



/////////////////////////////////////////////////////////////////////
// Synchronize async inputs from the outside.
/////////////////////////////////////////////////////////////////////

//

// Join all the parity errors.  It becomes zero if there were none.
wire cpu_sync_parity_error;
assign cpu_sync_parity_error = 1'b0;

/////////////////////////////////////////////////////////////////////
// Connect the signals of the main core to the outside world.
/////////////////////////////////////////////////////////////////////
assign lsAtm_clk_enable_sync =    tm_clk_enable_sync;
assign lsArst_synch_r =    rst_synch_r;
assign lsArst_cpu_req_synch_r =    rst_cpu_req_synch_r;
assign    rst_cpu_ack = lsArst_cpu_ack;
assign    cpu_rst_gated = lsAcpu_rst_gated;
assign    cpu_clk_gated = lsAcpu_clk_gated;
assign lsAtest_mode =    test_mode;
assign lsALBIST_EN =    LBIST_EN;
assign lsAdm2arc_halt_req_synch_r =    dm2arc_halt_req_synch_r;
assign lsAdm2arc_run_req_synch_r =    dm2arc_run_req_synch_r;
assign    arc2dm_halt_ack = lsAarc2dm_halt_ack;
assign    arc2dm_run_ack = lsAarc2dm_run_ack;
assign lsAdm2arc_hartreset_synch_r =    dm2arc_hartreset_synch_r;
assign lsAdm2arc_hartreset2_synch_r =    dm2arc_hartreset2_synch_r;
assign lsAndmreset_synch_r =    ndmreset_synch_r;
assign lsAdm2arc_havereset_ack_synch_r =    dm2arc_havereset_ack_synch_r;
assign lsAdm2arc_halt_on_reset_synch_r =    dm2arc_halt_on_reset_synch_r;
assign    arc2dm_havereset_a = lsAarc2dm_havereset_a;
assign lsAdm2arc_relaxedpriv_synch_r =    dm2arc_relaxedpriv_synch_r;
assign    hart_unavailable = lsAhart_unavailable;
assign    ahb_hmastlock = lsAahb_hmastlock;
assign    ahb_hexcl = lsAahb_hexcl;
assign    ahb_hmaster = lsAahb_hmaster;
assign    ahb_hauser = lsAahb_hauser;
assign    ahb_hwrite = lsAahb_hwrite;
assign    ahb_haddr = lsAahb_haddr;
assign    ahb_htrans = lsAahb_htrans;
assign    ahb_hsize = lsAahb_hsize;
assign    ahb_hburst = lsAahb_hburst;
assign    ahb_hwstrb = lsAahb_hwstrb;
assign    ahb_hprot = lsAahb_hprot;
assign    ahb_hnonsec = lsAahb_hnonsec;
assign lsAahb_hready =    ahb_hready;
assign lsAahb_hresp =    ahb_hresp;
assign lsAahb_hexokay =    ahb_hexokay;
assign lsAahb_hrdata =    ahb_hrdata;
assign    ahb_hwdata = lsAahb_hwdata;
assign    ahb_hauserchk = lsAahb_hauserchk;
assign    ahb_haddrchk = lsAahb_haddrchk;
assign    ahb_htranschk = lsAahb_htranschk;
assign    ahb_hctrlchk1 = lsAahb_hctrlchk1;
assign    ahb_hctrlchk2 = lsAahb_hctrlchk2;
assign    ahb_hprotchk = lsAahb_hprotchk;
assign    ahb_hwstrbchk = lsAahb_hwstrbchk;
assign lsAahb_hreadychk =    ahb_hreadychk;
assign lsAahb_hrespchk =    ahb_hrespchk;
assign lsAahb_hrdatachk =    ahb_hrdatachk;
assign    ahb_hwdatachk = lsAahb_hwdatachk;
assign    ahb_fatal_err = lsAahb_fatal_err;
assign    dbu_per_ahb_hmastlock = lsAdbu_per_ahb_hmastlock;
assign    dbu_per_ahb_hexcl = lsAdbu_per_ahb_hexcl;
assign    dbu_per_ahb_hmaster = lsAdbu_per_ahb_hmaster;
assign    dbu_per_ahb_hauser = lsAdbu_per_ahb_hauser;
assign    dbu_per_ahb_hwrite = lsAdbu_per_ahb_hwrite;
assign    dbu_per_ahb_haddr = lsAdbu_per_ahb_haddr;
assign    dbu_per_ahb_htrans = lsAdbu_per_ahb_htrans;
assign    dbu_per_ahb_hsize = lsAdbu_per_ahb_hsize;
assign    dbu_per_ahb_hburst = lsAdbu_per_ahb_hburst;
assign    dbu_per_ahb_hwstrb = lsAdbu_per_ahb_hwstrb;
assign    dbu_per_ahb_hprot = lsAdbu_per_ahb_hprot;
assign    dbu_per_ahb_hnonsec = lsAdbu_per_ahb_hnonsec;
assign lsAdbu_per_ahb_hready =    dbu_per_ahb_hready;
assign lsAdbu_per_ahb_hresp =    dbu_per_ahb_hresp;
assign lsAdbu_per_ahb_hexokay =    dbu_per_ahb_hexokay;
assign lsAdbu_per_ahb_hrdata =    dbu_per_ahb_hrdata;
assign    dbu_per_ahb_hwdata = lsAdbu_per_ahb_hwdata;
assign    dbu_per_ahb_hauserchk = lsAdbu_per_ahb_hauserchk;
assign    dbu_per_ahb_haddrchk = lsAdbu_per_ahb_haddrchk;
assign    dbu_per_ahb_htranschk = lsAdbu_per_ahb_htranschk;
assign    dbu_per_ahb_hctrlchk1 = lsAdbu_per_ahb_hctrlchk1;
assign    dbu_per_ahb_hctrlchk2 = lsAdbu_per_ahb_hctrlchk2;
assign    dbu_per_ahb_hprotchk = lsAdbu_per_ahb_hprotchk;
assign    dbu_per_ahb_hwstrbchk = lsAdbu_per_ahb_hwstrbchk;
assign lsAdbu_per_ahb_hreadychk =    dbu_per_ahb_hreadychk;
assign lsAdbu_per_ahb_hrespchk =    dbu_per_ahb_hrespchk;
assign lsAdbu_per_ahb_hrdatachk =    dbu_per_ahb_hrdatachk;
assign    dbu_per_ahb_hwdatachk = lsAdbu_per_ahb_hwdatachk;
assign    dbu_per_ahb_fatal_err = lsAdbu_per_ahb_fatal_err;
assign lsAiccm_ahb_prio =    iccm_ahb_prio;
assign lsAiccm_ahb_hmastlock =    iccm_ahb_hmastlock;
assign lsAiccm_ahb_hexcl =    iccm_ahb_hexcl;
assign lsAiccm_ahb_hmaster =    iccm_ahb_hmaster;
assign lsAiccm_ahb_hsel =    iccm_ahb_hsel;
assign lsAiccm_ahb_htrans =    iccm_ahb_htrans;
assign lsAiccm_ahb_hwrite =    iccm_ahb_hwrite;
assign lsAiccm_ahb_haddr =    iccm_ahb_haddr;
assign lsAiccm_ahb_hsize =    iccm_ahb_hsize;
assign lsAiccm_ahb_hwstrb =    iccm_ahb_hwstrb;
assign lsAiccm_ahb_hburst =    iccm_ahb_hburst;
assign lsAiccm_ahb_hprot =    iccm_ahb_hprot;
assign lsAiccm_ahb_hnonsec =    iccm_ahb_hnonsec;
assign lsAiccm_ahb_hwdata =    iccm_ahb_hwdata;
assign lsAiccm_ahb_hready =    iccm_ahb_hready;
assign    iccm_ahb_hrdata = lsAiccm_ahb_hrdata;
assign    iccm_ahb_hresp = lsAiccm_ahb_hresp;
assign    iccm_ahb_hexokay = lsAiccm_ahb_hexokay;
assign    iccm_ahb_hreadyout = lsAiccm_ahb_hreadyout;
assign lsAiccm_ahb_haddrchk =    iccm_ahb_haddrchk;
assign lsAiccm_ahb_htranschk =    iccm_ahb_htranschk;
assign lsAiccm_ahb_hctrlchk1 =    iccm_ahb_hctrlchk1;
assign lsAiccm_ahb_hctrlchk2 =    iccm_ahb_hctrlchk2;
assign lsAiccm_ahb_hwstrbchk =    iccm_ahb_hwstrbchk;
assign lsAiccm_ahb_hprotchk =    iccm_ahb_hprotchk;
assign lsAiccm_ahb_hreadychk =    iccm_ahb_hreadychk;
assign    iccm_ahb_hrespchk = lsAiccm_ahb_hrespchk;
assign    iccm_ahb_hreadyoutchk = lsAiccm_ahb_hreadyoutchk;
assign lsAiccm_ahb_hselchk =    iccm_ahb_hselchk;
assign    iccm_ahb_hrdatachk = lsAiccm_ahb_hrdatachk;
assign lsAiccm_ahb_hwdatachk =    iccm_ahb_hwdatachk;
assign    iccm_ahb_fatal_err = lsAiccm_ahb_fatal_err;
assign lsAdccm_ahb_prio =    dccm_ahb_prio;
assign lsAdccm_ahb_hmastlock =    dccm_ahb_hmastlock;
assign lsAdccm_ahb_hexcl =    dccm_ahb_hexcl;
assign lsAdccm_ahb_hmaster =    dccm_ahb_hmaster;
assign lsAdccm_ahb_hsel =    dccm_ahb_hsel;
assign lsAdccm_ahb_htrans =    dccm_ahb_htrans;
assign lsAdccm_ahb_hwrite =    dccm_ahb_hwrite;
assign lsAdccm_ahb_haddr =    dccm_ahb_haddr;
assign lsAdccm_ahb_hsize =    dccm_ahb_hsize;
assign lsAdccm_ahb_hwstrb =    dccm_ahb_hwstrb;
assign lsAdccm_ahb_hnonsec =    dccm_ahb_hnonsec;
assign lsAdccm_ahb_hburst =    dccm_ahb_hburst;
assign lsAdccm_ahb_hprot =    dccm_ahb_hprot;
assign lsAdccm_ahb_hwdata =    dccm_ahb_hwdata;
assign lsAdccm_ahb_hready =    dccm_ahb_hready;
assign    dccm_ahb_hrdata = lsAdccm_ahb_hrdata;
assign    dccm_ahb_hresp = lsAdccm_ahb_hresp;
assign    dccm_ahb_hexokay = lsAdccm_ahb_hexokay;
assign    dccm_ahb_hreadyout = lsAdccm_ahb_hreadyout;
assign lsAdccm_ahb_haddrchk =    dccm_ahb_haddrchk;
assign lsAdccm_ahb_htranschk =    dccm_ahb_htranschk;
assign lsAdccm_ahb_hctrlchk1 =    dccm_ahb_hctrlchk1;
assign lsAdccm_ahb_hctrlchk2 =    dccm_ahb_hctrlchk2;
assign lsAdccm_ahb_hwstrbchk =    dccm_ahb_hwstrbchk;
assign lsAdccm_ahb_hprotchk =    dccm_ahb_hprotchk;
assign lsAdccm_ahb_hreadychk =    dccm_ahb_hreadychk;
assign    dccm_ahb_hrespchk = lsAdccm_ahb_hrespchk;
assign    dccm_ahb_hreadyoutchk = lsAdccm_ahb_hreadyoutchk;
assign lsAdccm_ahb_hselchk =    dccm_ahb_hselchk;
assign    dccm_ahb_hrdatachk = lsAdccm_ahb_hrdatachk;
assign lsAdccm_ahb_hwdatachk =    dccm_ahb_hwdatachk;
assign    dccm_ahb_fatal_err = lsAdccm_ahb_fatal_err;
assign lsAmmio_ahb_prio =    mmio_ahb_prio;
assign lsAmmio_ahb_hmastlock =    mmio_ahb_hmastlock;
assign lsAmmio_ahb_hexcl =    mmio_ahb_hexcl;
assign lsAmmio_ahb_hmaster =    mmio_ahb_hmaster;
assign lsAmmio_ahb_hsel =    mmio_ahb_hsel;
assign lsAmmio_ahb_htrans =    mmio_ahb_htrans;
assign lsAmmio_ahb_hwrite =    mmio_ahb_hwrite;
assign lsAmmio_ahb_haddr =    mmio_ahb_haddr;
assign lsAmmio_ahb_hsize =    mmio_ahb_hsize;
assign lsAmmio_ahb_hwstrb =    mmio_ahb_hwstrb;
assign lsAmmio_ahb_hnonsec =    mmio_ahb_hnonsec;
assign lsAmmio_ahb_hburst =    mmio_ahb_hburst;
assign lsAmmio_ahb_hprot =    mmio_ahb_hprot;
assign lsAmmio_ahb_hwdata =    mmio_ahb_hwdata;
assign lsAmmio_ahb_hready =    mmio_ahb_hready;
assign    mmio_ahb_hrdata = lsAmmio_ahb_hrdata;
assign    mmio_ahb_hresp = lsAmmio_ahb_hresp;
assign    mmio_ahb_hexokay = lsAmmio_ahb_hexokay;
assign    mmio_ahb_hreadyout = lsAmmio_ahb_hreadyout;
assign lsAmmio_ahb_haddrchk =    mmio_ahb_haddrchk;
assign lsAmmio_ahb_htranschk =    mmio_ahb_htranschk;
assign lsAmmio_ahb_hctrlchk1 =    mmio_ahb_hctrlchk1;
assign lsAmmio_ahb_hctrlchk2 =    mmio_ahb_hctrlchk2;
assign lsAmmio_ahb_hwstrbchk =    mmio_ahb_hwstrbchk;
assign lsAmmio_ahb_hprotchk =    mmio_ahb_hprotchk;
assign lsAmmio_ahb_hreadychk =    mmio_ahb_hreadychk;
assign    mmio_ahb_hrespchk = lsAmmio_ahb_hrespchk;
assign    mmio_ahb_hreadyoutchk = lsAmmio_ahb_hreadyoutchk;
assign lsAmmio_ahb_hselchk =    mmio_ahb_hselchk;
assign    mmio_ahb_hrdatachk = lsAmmio_ahb_hrdatachk;
assign lsAmmio_ahb_hwdatachk =    mmio_ahb_hwdatachk;
assign    mmio_ahb_fatal_err = lsAmmio_ahb_fatal_err;
assign lsAmmio_base_in =    mmio_base_in;
assign lsAreset_pc_in =    reset_pc_in;
assign lsArnmi_synch_r =    rnmi_synch_r;
assign    esrams_iccm0_clk = lsAesrams_iccm0_clk;
assign    esrams_iccm0_din = lsAesrams_iccm0_din;
assign    esrams_iccm0_addr = lsAesrams_iccm0_addr;
assign    esrams_iccm0_cs = lsAesrams_iccm0_cs;
assign    esrams_iccm0_we = lsAesrams_iccm0_we;
assign    esrams_iccm0_wem = lsAesrams_iccm0_wem;
assign lsAesrams_iccm0_dout =    esrams_iccm0_dout;
assign    esrams_dccm_even_clk = lsAesrams_dccm_even_clk;
assign    esrams_dccm_din_even = lsAesrams_dccm_din_even;
assign    esrams_dccm_addr_even = lsAesrams_dccm_addr_even;
assign    esrams_dccm_cs_even = lsAesrams_dccm_cs_even;
assign    esrams_dccm_we_even = lsAesrams_dccm_we_even;
assign    esrams_dccm_wem_even = lsAesrams_dccm_wem_even;
assign lsAesrams_dccm_dout_even =    esrams_dccm_dout_even;
assign    esrams_dccm_odd_clk = lsAesrams_dccm_odd_clk;
assign    esrams_dccm_din_odd = lsAesrams_dccm_din_odd;
assign    esrams_dccm_addr_odd = lsAesrams_dccm_addr_odd;
assign    esrams_dccm_cs_odd = lsAesrams_dccm_cs_odd;
assign    esrams_dccm_we_odd = lsAesrams_dccm_we_odd;
assign    esrams_dccm_wem_odd = lsAesrams_dccm_wem_odd;
assign lsAesrams_dccm_dout_odd =    esrams_dccm_dout_odd;
assign    esrams_ic_tag_mem_clk = lsAesrams_ic_tag_mem_clk;
assign    esrams_ic_tag_mem_din = lsAesrams_ic_tag_mem_din;
assign    esrams_ic_tag_mem_addr = lsAesrams_ic_tag_mem_addr;
assign    esrams_ic_tag_mem_cs = lsAesrams_ic_tag_mem_cs;
assign    esrams_ic_tag_mem_we = lsAesrams_ic_tag_mem_we;
assign    esrams_ic_tag_mem_wem = lsAesrams_ic_tag_mem_wem;
assign lsAesrams_ic_tag_mem_dout =    esrams_ic_tag_mem_dout;
assign    esrams_ic_data_mem_clk = lsAesrams_ic_data_mem_clk;
assign    esrams_ic_data_mem_din = lsAesrams_ic_data_mem_din;
assign    esrams_ic_data_mem_addr = lsAesrams_ic_data_mem_addr;
assign    esrams_ic_data_mem_cs = lsAesrams_ic_data_mem_cs;
assign    esrams_ic_data_mem_we = lsAesrams_ic_data_mem_we;
assign    esrams_ic_data_mem_wem = lsAesrams_ic_data_mem_wem;
assign lsAesrams_ic_data_mem_dout =    esrams_ic_data_mem_dout;
assign    esrams_clk = lsAesrams_clk;
assign    esrams_ls = lsAesrams_ls;
assign lsAext_trig_output_accept =    ext_trig_output_accept;
assign lsAext_trig_in =    ext_trig_in;
assign    ext_trig_output_valid = lsAext_trig_output_valid;
assign    high_prio_ras = lsAhigh_prio_ras;
assign    lsc_diag_aux_r = lsAlsc_diag_aux_r;
assign    dr_lsc_stl_ctrl_aux_r = lsAdr_lsc_stl_ctrl_aux_r;
assign    dr_sfty_aux_parity_err_r = lsAdr_sfty_aux_parity_err_r;
assign    dr_bus_fatal_err = lsAdr_bus_fatal_err;
assign lsAdr_safety_comparator_enabled =    dr_safety_comparator_enabled;
assign lsAsafety_iso_enb_synch_r =    safety_iso_enb_synch_r;
assign    sfty_nsi_r = lsAsfty_nsi_r;
assign lsAlsc_err_stat_aux =    lsc_err_stat_aux;
assign lsAdr_sfty_eic =    dr_sfty_eic;
assign    dr_safety_iso_err = lsAdr_safety_iso_err;
assign    dr_secure_trig_iso_err = lsAdr_secure_trig_iso_err;
assign    sfty_mem_sbe_err = lsAsfty_mem_sbe_err;
assign    sfty_mem_dbe_err = lsAsfty_mem_dbe_err;
assign    sfty_mem_adr_err = lsAsfty_mem_adr_err;
assign    sfty_mem_sbe_overflow = lsAsfty_mem_sbe_overflow;
assign    sfty_ibp_mmio_cmd_valid = lsAsfty_ibp_mmio_cmd_valid;
assign    sfty_ibp_mmio_cmd_cache = lsAsfty_ibp_mmio_cmd_cache;
assign    sfty_ibp_mmio_cmd_burst_size = lsAsfty_ibp_mmio_cmd_burst_size;
assign    sfty_ibp_mmio_cmd_read = lsAsfty_ibp_mmio_cmd_read;
assign    sfty_ibp_mmio_cmd_aux = lsAsfty_ibp_mmio_cmd_aux;
assign lsAsfty_ibp_mmio_cmd_accept =    sfty_ibp_mmio_cmd_accept;
assign    sfty_ibp_mmio_cmd_addr = lsAsfty_ibp_mmio_cmd_addr;
assign    sfty_ibp_mmio_cmd_excl = lsAsfty_ibp_mmio_cmd_excl;
assign    sfty_ibp_mmio_cmd_atomic = lsAsfty_ibp_mmio_cmd_atomic;
assign    sfty_ibp_mmio_cmd_data_size = lsAsfty_ibp_mmio_cmd_data_size;
assign    sfty_ibp_mmio_cmd_prot = lsAsfty_ibp_mmio_cmd_prot;
assign    sfty_ibp_mmio_wr_valid = lsAsfty_ibp_mmio_wr_valid;
assign    sfty_ibp_mmio_wr_last = lsAsfty_ibp_mmio_wr_last;
assign lsAsfty_ibp_mmio_wr_accept =    sfty_ibp_mmio_wr_accept;
assign    sfty_ibp_mmio_wr_mask = lsAsfty_ibp_mmio_wr_mask;
assign    sfty_ibp_mmio_wr_data = lsAsfty_ibp_mmio_wr_data;
assign lsAsfty_ibp_mmio_rd_valid =    sfty_ibp_mmio_rd_valid;
assign lsAsfty_ibp_mmio_rd_err =    sfty_ibp_mmio_rd_err;
assign lsAsfty_ibp_mmio_rd_excl_ok =    sfty_ibp_mmio_rd_excl_ok;
assign lsAsfty_ibp_mmio_rd_last =    sfty_ibp_mmio_rd_last;
assign    sfty_ibp_mmio_rd_accept = lsAsfty_ibp_mmio_rd_accept;
assign lsAsfty_ibp_mmio_rd_data =    sfty_ibp_mmio_rd_data;
assign lsAsfty_ibp_mmio_wr_done =    sfty_ibp_mmio_wr_done;
assign lsAsfty_ibp_mmio_wr_excl_okay =    sfty_ibp_mmio_wr_excl_okay;
assign lsAsfty_ibp_mmio_wr_err =    sfty_ibp_mmio_wr_err;
assign    sfty_ibp_mmio_wr_resp_accept = lsAsfty_ibp_mmio_wr_resp_accept;
assign    sfty_ibp_mmio_cmd_valid_pty = lsAsfty_ibp_mmio_cmd_valid_pty;
assign lsAsfty_ibp_mmio_cmd_accept_pty =    sfty_ibp_mmio_cmd_accept_pty;
assign    sfty_ibp_mmio_cmd_addr_pty = lsAsfty_ibp_mmio_cmd_addr_pty;
assign    sfty_ibp_mmio_cmd_ctrl_pty = lsAsfty_ibp_mmio_cmd_ctrl_pty;
assign    sfty_ibp_mmio_wr_valid_pty = lsAsfty_ibp_mmio_wr_valid_pty;
assign lsAsfty_ibp_mmio_wr_accept_pty =    sfty_ibp_mmio_wr_accept_pty;
assign    sfty_ibp_mmio_wr_last_pty = lsAsfty_ibp_mmio_wr_last_pty;
assign lsAsfty_ibp_mmio_rd_valid_pty =    sfty_ibp_mmio_rd_valid_pty;
assign    sfty_ibp_mmio_rd_accept_pty = lsAsfty_ibp_mmio_rd_accept_pty;
assign lsAsfty_ibp_mmio_rd_ctrl_pty =    sfty_ibp_mmio_rd_ctrl_pty;
assign lsAsfty_ibp_mmio_rd_data_pty =    sfty_ibp_mmio_rd_data_pty;
assign lsAsfty_ibp_mmio_wr_done_pty =    sfty_ibp_mmio_wr_done_pty;
assign lsAsfty_ibp_mmio_wr_ctrl_pty =    sfty_ibp_mmio_wr_ctrl_pty;
assign    sfty_ibp_mmio_wr_resp_accept_pty = lsAsfty_ibp_mmio_wr_resp_accept_pty;
assign    sfty_ibp_mmio_ini_e2e_err = lsAsfty_ibp_mmio_ini_e2e_err;
assign    wdt_reset0 = lsAwdt_reset0;
assign    reg_wr_en0 = lsAreg_wr_en0;
assign lsAwdt_clk_enable_sync =    wdt_clk_enable_sync;
assign    wdt_feedback_bit = lsAwdt_feedback_bit;
assign lsAdmsi_valid =    dmsi_valid;
assign lsAdmsi_context =    dmsi_context;
assign lsAdmsi_eiid =    dmsi_eiid;
assign lsAdmsi_domain =    dmsi_domain;
assign    dmsi_rdy = lsAdmsi_rdy;
assign lsAdmsi_valid_chk =    dmsi_valid_chk;
assign lsAdmsi_data_edc =    dmsi_data_edc;
assign    dmsi_rdy_chk = lsAdmsi_rdy_chk;
assign    sfty_dmsi_tgt_e2e_err = lsAsfty_dmsi_tgt_e2e_err;
assign lsAdbg_ibp_cmd_valid =    dbg_ibp_cmd_valid;
assign lsAdbg_ibp_cmd_read =    dbg_ibp_cmd_read;
assign lsAdbg_ibp_cmd_addr =    dbg_ibp_cmd_addr;
assign    dbg_ibp_cmd_accept = lsAdbg_ibp_cmd_accept;
assign lsAdbg_ibp_cmd_space =    dbg_ibp_cmd_space;
assign    dbg_ibp_rd_valid = lsAdbg_ibp_rd_valid;
assign lsAdbg_ibp_rd_accept =    dbg_ibp_rd_accept;
assign    dbg_ibp_rd_err = lsAdbg_ibp_rd_err;
assign    dbg_ibp_rd_data = lsAdbg_ibp_rd_data;
assign lsAdbg_ibp_wr_valid =    dbg_ibp_wr_valid;
assign    dbg_ibp_wr_accept = lsAdbg_ibp_wr_accept;
assign lsAdbg_ibp_wr_data =    dbg_ibp_wr_data;
assign lsAdbg_ibp_wr_mask =    dbg_ibp_wr_mask;
assign    dbg_ibp_wr_done = lsAdbg_ibp_wr_done;
assign    dbg_ibp_wr_err = lsAdbg_ibp_wr_err;
assign lsAdbg_ibp_wr_resp_accept =    dbg_ibp_wr_resp_accept;
assign lsAwid_rlwid =    wid_rlwid;
assign lsAwid_rwiddeleg =    wid_rwiddeleg;
assign lsAsoft_reset_prepare_synch_r =    soft_reset_prepare_synch_r;
assign lsAsoft_reset_req_synch_r =    soft_reset_req_synch_r;
assign    soft_reset_ready = lsAsoft_reset_ready;
assign    soft_reset_ack = lsAsoft_reset_ack;
assign    cpu_in_reset_state = lsAcpu_in_reset_state;
assign lsArst_init_disable_synch_r =    rst_init_disable_synch_r;
assign lsAarcnum =    arcnum;
assign    sys_halt_r = lsAsys_halt_r;
assign    sys_sleep_r = lsAsys_sleep_r;
assign    critical_error = lsAcritical_error;
assign    sys_sleep_mode_r = lsAsys_sleep_mode_r;



/////////////////////////////////////////////////////////////////////
// These are the aggregation keys that determine how signals are
// combined for comparison in error_register.
/////////////////////////////////////////////////////////////////////
// ahb
// arc2dm
// dbu
// dccm
// dmsi
// dr
// esrams
// ext
// gclk
// ic
// iccm
// iccm0
// lsc
// mmio
// safety
// sfty
// sys
// wdt

// spyglass disable_block UnloadedOutTerm-ML
// SMD: valid_mask_sc[70:1] (Connected to floating net 'valid_mask_sc')) of module 'err_inj_ctrl'
// SJ: the behaviour is intentional, only lsb & msb has loading 
localparam NUM_COMPARATORS = 34;
logic [NUM_COMPARATORS*2-1:0] error_mask_sc, valid_mask_sc;

err_inj_ctrl #(
    .NUM_COMPARATORS (NUM_COMPARATORS)
) u_err_inj_ctrl ( 
    .error_mask_sc		(error_mask_sc),
    .valid_mask_sc		(valid_mask_sc),
    .dr_sfty_diag_mode_sc  	(cpu_dr_sfty_diag_mode_sc),
    .dr_sfty_diag_inj_end	(cpu_dr_sfty_diag_inj_end),
    .dr_mask_pty_err		(cpu_dr_mask_pty_err),
    .clk	(cpu_clk_gated),
    .rst	(cpu_rst_gated)
    );
// spyglass enable_block UnloadedOutTerm-ML

////////////////////////////////////////////////////////////////////
// Compare outputs of the two modules.
/////////////////////////////////////////////////////////////////////
//
// Compare signals from the main module.
//

// Key: ahb.
wire [1:0] err_agg_ahb_0;
wire [28:0] lsAagg_ahb_0;
wire [28:0] lsBagg_ahb_0;
assign lsAagg_ahb_0 = {
    lsAahb_fatal_err             // 1    28:28
  , lsAahb_hauserchk             // 1    27:27
  , lsAahb_hctrlchk1             // 1    26:26
  , lsAahb_hctrlchk2             // 1    25:25
  , lsAahb_hexcl                 // 1    24:24
  , lsAahb_hmastlock             // 1    23:23
  , lsAahb_hnonsec               // 1    22:22
  , lsAahb_hprotchk              // 1    21:21
  , lsAahb_htranschk             // 1    20:20
  , lsAahb_hwrite                // 1    19:19
  , lsAahb_hwstrbchk             // 1    18:18
  , lsAcpu_in_reset_state        // 1    17:17
  , lsAcritical_error            // 1    16:16
  , lsAhart_unavailable          // 1    15:15
  , lsAhigh_prio_ras             // 1    14:14
  , lsAreg_wr_en0                // 1    13:13
  , lsAsoft_reset_ready          // 1    12:12
  , lsAahb_htrans                // 2    11:10
  , lsAahb_hburst                // 3    9:7
  , lsAahb_hsize                 // 3    6:4
  , lsAahb_haddrchk              // 4    3:0
    };
assign lsBagg_ahb_0 = {
    lsBahb_fatal_err             // 1    28:28
  , lsBahb_hauserchk             // 1    27:27
  , lsBahb_hctrlchk1             // 1    26:26
  , lsBahb_hctrlchk2             // 1    25:25
  , lsBahb_hexcl                 // 1    24:24
  , lsBahb_hmastlock             // 1    23:23
  , lsBahb_hnonsec               // 1    22:22
  , lsBahb_hprotchk              // 1    21:21
  , lsBahb_htranschk             // 1    20:20
  , lsBahb_hwrite                // 1    19:19
  , lsBahb_hwstrbchk             // 1    18:18
  , lsBcpu_in_reset_state        // 1    17:17
  , lsBcritical_error            // 1    16:16
  , lsBhart_unavailable          // 1    15:15
  , lsBhigh_prio_ras             // 1    14:14
  , lsBreg_wr_en0                // 1    13:13
  , lsBsoft_reset_ready          // 1    12:12
  , lsBahb_htrans                // 2    11:10
  , lsBahb_hburst                // 3    9:7
  , lsBahb_hsize                 // 3    6:4
  , lsBahb_haddrchk              // 4    3:0
    };



// VERIF,agg_ahb_0,29


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_ahb_0)),
    .DELAY(0)
) u_compare_agg_ahb_0 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_ahb_0),
    .shadow_interface   (lsBagg_ahb_0),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[1:0]),
    .error_bits         (err_agg_ahb_0)
    );

// Key: ahb.
wire [1:0] err_agg_ahb_1;
wire [26:0] lsAagg_ahb_1;
wire [26:0] lsBagg_ahb_1;
assign lsAagg_ahb_1 = {
    lsAahb_hmaster               // 4    26:23
  , lsAahb_hwdatachk             // 4    22:19
  , lsAahb_hwstrb                // 4    18:15
  , lsAahb_hprot                 // 7    14:8
  , lsAahb_hauser                // 8    7:0
    };
assign lsBagg_ahb_1 = {
    lsBahb_hmaster               // 4    26:23
  , lsBahb_hwdatachk             // 4    22:19
  , lsBahb_hwstrb                // 4    18:15
  , lsBahb_hprot                 // 7    14:8
  , lsBahb_hauser                // 8    7:0
    };



// VERIF,agg_ahb_1,27


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_ahb_1)),
    .DELAY(0)
) u_compare_agg_ahb_1 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_ahb_1),
    .shadow_interface   (lsBagg_ahb_1),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[3:2]),
    .error_bits         (err_agg_ahb_1)
    );

// Key: ahb.
wire [1:0] err_ahb_haddr;



// VERIF,ahb_haddr,32


ls_compare_unit #(
    .REG_WIDTH($bits(lsAahb_haddr)),
    .DELAY(0)
) u_compare_ahb_haddr (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAahb_haddr),
    .shadow_interface   (lsBahb_haddr),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[5:4]),
    .error_bits         (err_ahb_haddr)
    );

// Key: arc2dm.
wire [1:0] err_agg_arc2dm;
wire [2:0] lsAagg_arc2dm;
wire [2:0] lsBagg_arc2dm;
assign lsAagg_arc2dm = {
    lsAarc2dm_halt_ack           // 1    2:2
  , lsAarc2dm_havereset_a        // 1    1:1
  , lsAarc2dm_run_ack            // 1    0:0
    };
assign lsBagg_arc2dm = {
    lsBarc2dm_halt_ack           // 1    2:2
  , lsBarc2dm_havereset_a        // 1    1:1
  , lsBarc2dm_run_ack            // 1    0:0
    };



// VERIF,agg_arc2dm,3


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_arc2dm)),
    .DELAY(0)
) u_compare_agg_arc2dm (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_arc2dm),
    .shadow_interface   (lsBagg_arc2dm),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[7:6]),
    .error_bits         (err_agg_arc2dm)
    );

// Key: dbu.
wire [1:0] err_agg_dbu_0;
wire [30:0] lsAagg_dbu_0;
wire [30:0] lsBagg_dbu_0;
assign lsAagg_dbu_0 = {
    lsAdbu_per_ahb_fatal_err     // 1    30:30
  , lsAdbu_per_ahb_hauserchk     // 1    29:29
  , lsAdbu_per_ahb_hctrlchk1     // 1    28:28
  , lsAdbu_per_ahb_hctrlchk2     // 1    27:27
  , lsAdbu_per_ahb_hexcl         // 1    26:26
  , lsAdbu_per_ahb_hmastlock     // 1    25:25
  , lsAdbu_per_ahb_hnonsec       // 1    24:24
  , lsAdbu_per_ahb_hprotchk      // 1    23:23
  , lsAdbu_per_ahb_htranschk     // 1    22:22
  , lsAdbu_per_ahb_hwrite        // 1    21:21
  , lsAdbu_per_ahb_hwstrbchk     // 1    20:20
  , lsAdbu_per_ahb_htrans        // 2    19:18
  , lsAdbu_per_ahb_hburst        // 3    17:15
  , lsAdbu_per_ahb_hsize         // 3    14:12
  , lsAdbu_per_ahb_haddrchk      // 4    11:8
  , lsAdbu_per_ahb_hmaster       // 4    7:4
  , lsAdbu_per_ahb_hwdatachk     // 4    3:0
    };
assign lsBagg_dbu_0 = {
    lsBdbu_per_ahb_fatal_err     // 1    30:30
  , lsBdbu_per_ahb_hauserchk     // 1    29:29
  , lsBdbu_per_ahb_hctrlchk1     // 1    28:28
  , lsBdbu_per_ahb_hctrlchk2     // 1    27:27
  , lsBdbu_per_ahb_hexcl         // 1    26:26
  , lsBdbu_per_ahb_hmastlock     // 1    25:25
  , lsBdbu_per_ahb_hnonsec       // 1    24:24
  , lsBdbu_per_ahb_hprotchk      // 1    23:23
  , lsBdbu_per_ahb_htranschk     // 1    22:22
  , lsBdbu_per_ahb_hwrite        // 1    21:21
  , lsBdbu_per_ahb_hwstrbchk     // 1    20:20
  , lsBdbu_per_ahb_htrans        // 2    19:18
  , lsBdbu_per_ahb_hburst        // 3    17:15
  , lsBdbu_per_ahb_hsize         // 3    14:12
  , lsBdbu_per_ahb_haddrchk      // 4    11:8
  , lsBdbu_per_ahb_hmaster       // 4    7:4
  , lsBdbu_per_ahb_hwdatachk     // 4    3:0
    };



// VERIF,agg_dbu_0,31


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_dbu_0)),
    .DELAY(0)
) u_compare_agg_dbu_0 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_dbu_0),
    .shadow_interface   (lsBagg_dbu_0),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[9:8]),
    .error_bits         (err_agg_dbu_0)
    );

// Key: dbu.
wire [1:0] err_agg_dbu_1;
wire [18:0] lsAagg_dbu_1;
wire [18:0] lsBagg_dbu_1;
assign lsAagg_dbu_1 = {
    lsAdbu_per_ahb_hwstrb        // 4    18:15
  , lsAdbu_per_ahb_hprot         // 7    14:8
  , lsAdbu_per_ahb_hauser        // 8    7:0
    };
assign lsBagg_dbu_1 = {
    lsBdbu_per_ahb_hwstrb        // 4    18:15
  , lsBdbu_per_ahb_hprot         // 7    14:8
  , lsBdbu_per_ahb_hauser        // 8    7:0
    };



// VERIF,agg_dbu_1,19


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_dbu_1)),
    .DELAY(0)
) u_compare_agg_dbu_1 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_dbu_1),
    .shadow_interface   (lsBagg_dbu_1),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[11:10]),
    .error_bits         (err_agg_dbu_1)
    );

// Key: dbu.
wire [1:0] err_dbu_per_ahb_haddr;



// VERIF,dbu_per_ahb_haddr,32


ls_compare_unit #(
    .REG_WIDTH($bits(lsAdbu_per_ahb_haddr)),
    .DELAY(0)
) u_compare_dbu_per_ahb_haddr (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAdbu_per_ahb_haddr),
    .shadow_interface   (lsBdbu_per_ahb_haddr),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[13:12]),
    .error_bits         (err_dbu_per_ahb_haddr)
    );

// Key: dccm.
wire [1:0] err_agg_dccm;
wire [13:0] lsAagg_dccm;
wire [13:0] lsBagg_dccm;
assign lsAagg_dccm = {
    lsAdccm_ahb_fatal_err        // 1    13:13
  , lsAdccm_ahb_hexokay          // 1    12:12
  , lsAdccm_ahb_hreadyout        // 1    11:11
  , lsAdccm_ahb_hreadyoutchk     // 1    10:10
  , lsAdccm_ahb_hresp            // 1    9:9
  , lsAdccm_ahb_hrespchk         // 1    8:8
  , lsAdccm_even_gclk_cnt        // 2    7:6
  , lsAdccm_odd_gclk_cnt         // 2    5:4
  , lsAdccm_ahb_hrdatachk        // 4    3:0
    };
assign lsBagg_dccm = {
    lsBdccm_ahb_fatal_err        // 1    13:13
  , lsBdccm_ahb_hexokay          // 1    12:12
  , lsBdccm_ahb_hreadyout        // 1    11:11
  , lsBdccm_ahb_hreadyoutchk     // 1    10:10
  , lsBdccm_ahb_hresp            // 1    9:9
  , lsBdccm_ahb_hrespchk         // 1    8:8
  , lsBdccm_even_gclk_cnt        // 2    7:6
  , lsBdccm_odd_gclk_cnt         // 2    5:4
  , lsBdccm_ahb_hrdatachk        // 4    3:0
    };



// VERIF,agg_dccm,14


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_dccm)),
    .DELAY(0)
) u_compare_agg_dccm (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_dccm),
    .shadow_interface   (lsBagg_dccm),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[15:14]),
    .error_bits         (err_agg_dccm)
    );

// Key: dmsi.
wire [1:0] err_agg_dmsi;
wire [1:0] lsAagg_dmsi;
wire [1:0] lsBagg_dmsi;
assign lsAagg_dmsi = {
    lsAdmsi_rdy                  // 1    1:1
  , lsAdmsi_rdy_chk              // 1    0:0
    };
assign lsBagg_dmsi = {
    lsBdmsi_rdy                  // 1    1:1
  , lsBdmsi_rdy_chk              // 1    0:0
    };



// VERIF,agg_dmsi,2


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_dmsi)),
    .DELAY(0)
) u_compare_agg_dmsi (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_dmsi),
    .shadow_interface   (lsBagg_dmsi),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[17:16]),
    .error_bits         (err_agg_dmsi)
    );

// Key: dr.
wire [1:0] err_agg_dr;
wire [9:0] lsAagg_dr;
wire [9:0] lsBagg_dr;
assign lsAagg_dr = {
    lsAdr_bus_fatal_err          // 2    9:8
  , lsAdr_lsc_stl_ctrl_aux_r     // 2    7:6
  , lsAdr_safety_iso_err         // 2    5:4
  , lsAdr_secure_trig_iso_err    // 2    3:2
  , lsAdr_sfty_aux_parity_err_r  // 2    1:0
    };
assign lsBagg_dr = {
    lsBdr_bus_fatal_err          // 2    9:8
  , lsBdr_lsc_stl_ctrl_aux_r     // 2    7:6
  , lsBdr_safety_iso_err         // 2    5:4
  , lsBdr_secure_trig_iso_err    // 2    3:2
  , lsBdr_sfty_aux_parity_err_r  // 2    1:0
    };



// VERIF,agg_dr,10


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_dr)),
    .DELAY(0)
) u_compare_agg_dr (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_dr),
    .shadow_interface   (lsBagg_dr),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[19:18]),
    .error_bits         (err_agg_dr)
    );

// Key: esrams.
wire [1:0] err_agg_esrams_0;
wire [24:0] lsAagg_esrams_0;
wire [24:0] lsBagg_esrams_0;
assign lsAagg_esrams_0 = {
    lsAesrams_dccm_cs_even       // 1    24:24
  , lsAesrams_dccm_cs_odd        // 1    23:23
  , lsAesrams_dccm_we_even       // 1    22:22
  , lsAesrams_dccm_we_odd        // 1    21:21
  , lsAesrams_ic_data_mem_cs     // 1    20:20
  , lsAesrams_ic_data_mem_we     // 1    19:19
  , lsAesrams_ic_tag_mem_cs      // 1    18:18
  , lsAesrams_ic_tag_mem_we      // 1    17:17
  , lsAesrams_iccm0_cs           // 1    16:16
  , lsAesrams_iccm0_we           // 1    15:15
  , lsAesrams_dccm_wem_even      // 5    14:10
  , lsAesrams_dccm_wem_odd       // 5    9:5
  , lsAesrams_iccm0_wem          // 5    4:0
    };
assign lsBagg_esrams_0 = {
    lsBesrams_dccm_cs_even       // 1    24:24
  , lsBesrams_dccm_cs_odd        // 1    23:23
  , lsBesrams_dccm_we_even       // 1    22:22
  , lsBesrams_dccm_we_odd        // 1    21:21
  , lsBesrams_ic_data_mem_cs     // 1    20:20
  , lsBesrams_ic_data_mem_we     // 1    19:19
  , lsBesrams_ic_tag_mem_cs      // 1    18:18
  , lsBesrams_ic_tag_mem_we      // 1    17:17
  , lsBesrams_iccm0_cs           // 1    16:16
  , lsBesrams_iccm0_we           // 1    15:15
  , lsBesrams_dccm_wem_even      // 5    14:10
  , lsBesrams_dccm_wem_odd       // 5    9:5
  , lsBesrams_iccm0_wem          // 5    4:0
    };



// VERIF,agg_esrams_0,25


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_esrams_0)),
    .DELAY(0)
) u_compare_agg_esrams_0 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_esrams_0),
    .shadow_interface   (lsBagg_esrams_0),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[21:20]),
    .error_bits         (err_agg_esrams_0)
    );

// Key: esrams.
wire [1:0] err_agg_esrams_1;
wire [18:0] lsAagg_esrams_1;
wire [18:0] lsBagg_esrams_1;
assign lsAagg_esrams_1 = {
    lsAesrams_ic_tag_mem_addr    // 8    18:11
  , lsAesrams_ic_data_mem_addr   // 11    10:0
    };
assign lsBagg_esrams_1 = {
    lsBesrams_ic_tag_mem_addr    // 8    18:11
  , lsBesrams_ic_data_mem_addr   // 11    10:0
    };



// VERIF,agg_esrams_1,19


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_esrams_1)),
    .DELAY(0)
) u_compare_agg_esrams_1 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_esrams_1),
    .shadow_interface   (lsBagg_esrams_1),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[23:22]),
    .error_bits         (err_agg_esrams_1)
    );

// Key: esrams.
wire [1:0] err_agg_esrams_2;
wire [16:0] lsAagg_esrams_2;
wire [16:0] lsBagg_esrams_2;
assign lsAagg_esrams_2 = {
    lsAesrams_dccm_addr_even     // 17    16:0
    };
assign lsBagg_esrams_2 = {
    lsBesrams_dccm_addr_even     // 17    16:0
    };



// VERIF,agg_esrams_2,17


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_esrams_2)),
    .DELAY(0)
) u_compare_agg_esrams_2 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_esrams_2),
    .shadow_interface   (lsBagg_esrams_2),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[25:24]),
    .error_bits         (err_agg_esrams_2)
    );

// Key: esrams.
wire [1:0] err_agg_esrams_3;
wire [16:0] lsAagg_esrams_3;
wire [16:0] lsBagg_esrams_3;
assign lsAagg_esrams_3 = {
    lsAesrams_dccm_addr_odd      // 17    16:0
    };
assign lsBagg_esrams_3 = {
    lsBesrams_dccm_addr_odd      // 17    16:0
    };



// VERIF,agg_esrams_3,17


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_esrams_3)),
    .DELAY(0)
) u_compare_agg_esrams_3 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_esrams_3),
    .shadow_interface   (lsBagg_esrams_3),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[27:26]),
    .error_bits         (err_agg_esrams_3)
    );

// Key: esrams.
wire [1:0] err_agg_esrams_4;
wire [16:0] lsAagg_esrams_4;
wire [16:0] lsBagg_esrams_4;
assign lsAagg_esrams_4 = {
    lsAesrams_iccm0_addr         // 17    16:0
    };
assign lsBagg_esrams_4 = {
    lsBesrams_iccm0_addr         // 17    16:0
    };



// VERIF,agg_esrams_4,17


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_esrams_4)),
    .DELAY(0)
) u_compare_agg_esrams_4 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_esrams_4),
    .shadow_interface   (lsBagg_esrams_4),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[29:28]),
    .error_bits         (err_agg_esrams_4)
    );

// Key: esrams.
wire [1:0] err_esrams_dccm_din_even;



// VERIF,esrams_dccm_din_even,40


ls_compare_unit #(
    .REG_WIDTH($bits(lsAesrams_dccm_din_even)),
    .DELAY(0)
) u_compare_esrams_dccm_din_even (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAesrams_dccm_din_even),
    .shadow_interface   (lsBesrams_dccm_din_even),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[31:30]),
    .error_bits         (err_esrams_dccm_din_even)
    );

// Key: esrams.
wire [1:0] err_esrams_dccm_din_odd;



// VERIF,esrams_dccm_din_odd,40


ls_compare_unit #(
    .REG_WIDTH($bits(lsAesrams_dccm_din_odd)),
    .DELAY(0)
) u_compare_esrams_dccm_din_odd (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAesrams_dccm_din_odd),
    .shadow_interface   (lsBesrams_dccm_din_odd),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[33:32]),
    .error_bits         (err_esrams_dccm_din_odd)
    );

// Key: esrams.
wire [1:0] err_esrams_iccm0_din;



// VERIF,esrams_iccm0_din,40


ls_compare_unit #(
    .REG_WIDTH($bits(lsAesrams_iccm0_din)),
    .DELAY(0)
) u_compare_esrams_iccm0_din (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAesrams_iccm0_din),
    .shadow_interface   (lsBesrams_iccm0_din),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[35:34]),
    .error_bits         (err_esrams_iccm0_din)
    );

// Key: esrams.
wire [1:0] err_esrams_ic_tag_mem_din;



// VERIF,esrams_ic_tag_mem_din,56


ls_compare_unit #(
    .REG_WIDTH($bits(lsAesrams_ic_tag_mem_din)),
    .DELAY(0)
) u_compare_esrams_ic_tag_mem_din (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAesrams_ic_tag_mem_din),
    .shadow_interface   (lsBesrams_ic_tag_mem_din),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[37:36]),
    .error_bits         (err_esrams_ic_tag_mem_din)
    );

// Key: esrams.
wire [1:0] err_esrams_ic_tag_mem_wem;



// VERIF,esrams_ic_tag_mem_wem,56


ls_compare_unit #(
    .REG_WIDTH($bits(lsAesrams_ic_tag_mem_wem)),
    .DELAY(0)
) u_compare_esrams_ic_tag_mem_wem (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAesrams_ic_tag_mem_wem),
    .shadow_interface   (lsBesrams_ic_tag_mem_wem),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[39:38]),
    .error_bits         (err_esrams_ic_tag_mem_wem)
    );

// Key: esrams.
wire [1:0] err_esrams_ic_data_mem_din;



// VERIF,esrams_ic_data_mem_din,80


ls_compare_unit #(
    .REG_WIDTH($bits(lsAesrams_ic_data_mem_din)),
    .DELAY(0)
) u_compare_esrams_ic_data_mem_din (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAesrams_ic_data_mem_din),
    .shadow_interface   (lsBesrams_ic_data_mem_din),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[41:40]),
    .error_bits         (err_esrams_ic_data_mem_din)
    );

// Key: esrams.
wire [1:0] err_esrams_ic_data_mem_wem;



// VERIF,esrams_ic_data_mem_wem,80


ls_compare_unit #(
    .REG_WIDTH($bits(lsAesrams_ic_data_mem_wem)),
    .DELAY(0)
) u_compare_esrams_ic_data_mem_wem (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAesrams_ic_data_mem_wem),
    .shadow_interface   (lsBesrams_ic_data_mem_wem),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[43:42]),
    .error_bits         (err_esrams_ic_data_mem_wem)
    );

// Key: ext.
wire [1:0] err_agg_ext;
wire [1:0] lsAagg_ext;
wire [1:0] lsBagg_ext;
assign lsAagg_ext = {
    lsAext_trig_output_valid     // 2    1:0
    };
assign lsBagg_ext = {
    lsBext_trig_output_valid     // 2    1:0
    };



// VERIF,agg_ext,2


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_ext)),
    .DELAY(0)
) u_compare_agg_ext (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_ext),
    .shadow_interface   (lsBagg_ext),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[45:44]),
    .error_bits         (err_agg_ext)
    );

// Key: gclk.
wire [1:0] err_agg_gclk;
wire [1:0] lsAagg_gclk;
wire [1:0] lsBagg_gclk;
assign lsAagg_gclk = {
    lsAgclk_cnt                  // 2    1:0
    };
assign lsBagg_gclk = {
    lsBgclk_cnt                  // 2    1:0
    };



// VERIF,agg_gclk,2


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_gclk)),
    .DELAY(0)
) u_compare_agg_gclk (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_gclk),
    .shadow_interface   (lsBagg_gclk),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[47:46]),
    .error_bits         (err_agg_gclk)
    );

// Key: ic.
wire [1:0] err_agg_ic;
wire [3:0] lsAagg_ic;
wire [3:0] lsBagg_ic;
assign lsAagg_ic = {
    lsAic_data_mem_gclk_cnt      // 2    3:2
  , lsAic_tag_mem_gclk_cnt       // 2    1:0
    };
assign lsBagg_ic = {
    lsBic_data_mem_gclk_cnt      // 2    3:2
  , lsBic_tag_mem_gclk_cnt       // 2    1:0
    };



// VERIF,agg_ic,4


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_ic)),
    .DELAY(0)
) u_compare_agg_ic (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_ic),
    .shadow_interface   (lsBagg_ic),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[49:48]),
    .error_bits         (err_agg_ic)
    );

// Key: iccm.
wire [1:0] err_agg_iccm;
wire [9:0] lsAagg_iccm;
wire [9:0] lsBagg_iccm;
assign lsAagg_iccm = {
    lsAiccm_ahb_fatal_err        // 1    9:9
  , lsAiccm_ahb_hexokay          // 1    8:8
  , lsAiccm_ahb_hreadyout        // 1    7:7
  , lsAiccm_ahb_hreadyoutchk     // 1    6:6
  , lsAiccm_ahb_hresp            // 1    5:5
  , lsAiccm_ahb_hrespchk         // 1    4:4
  , lsAiccm_ahb_hrdatachk        // 4    3:0
    };
assign lsBagg_iccm = {
    lsBiccm_ahb_fatal_err        // 1    9:9
  , lsBiccm_ahb_hexokay          // 1    8:8
  , lsBiccm_ahb_hreadyout        // 1    7:7
  , lsBiccm_ahb_hreadyoutchk     // 1    6:6
  , lsBiccm_ahb_hresp            // 1    5:5
  , lsBiccm_ahb_hrespchk         // 1    4:4
  , lsBiccm_ahb_hrdatachk        // 4    3:0
    };



// VERIF,agg_iccm,10


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_iccm)),
    .DELAY(0)
) u_compare_agg_iccm (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_iccm),
    .shadow_interface   (lsBagg_iccm),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[51:50]),
    .error_bits         (err_agg_iccm)
    );

// Key: iccm0.
wire [1:0] err_agg_iccm0;
wire [1:0] lsAagg_iccm0;
wire [1:0] lsBagg_iccm0;
assign lsAagg_iccm0 = {
    lsAiccm0_gclk_cnt            // 2    1:0
    };
assign lsBagg_iccm0 = {
    lsBiccm0_gclk_cnt            // 2    1:0
    };



// VERIF,agg_iccm0,2


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_iccm0)),
    .DELAY(0)
) u_compare_agg_iccm0 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_iccm0),
    .shadow_interface   (lsBagg_iccm0),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[53:52]),
    .error_bits         (err_agg_iccm0)
    );

// Key: lsc.
wire [1:0] err_agg_lsc;
wire [16:0] lsAagg_lsc;
wire [16:0] lsBagg_lsc;
assign lsAagg_lsc = {
    lsAlsc_shd_ctrl_aux_r        // 1    16:16
  , lsAlsc_diag_aux_r            // 16    15:0
    };
assign lsBagg_lsc = {
    lsBlsc_shd_ctrl_aux_r        // 1    16:16
  , lsBlsc_diag_aux_r            // 16    15:0
    };



// VERIF,agg_lsc,17


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_lsc)),
    .DELAY(0)
) u_compare_agg_lsc (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_lsc),
    .shadow_interface   (lsBagg_lsc),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[55:54]),
    .error_bits         (err_agg_lsc)
    );

// Key: mmio.
wire [1:0] err_agg_mmio;
wire [9:0] lsAagg_mmio;
wire [9:0] lsBagg_mmio;
assign lsAagg_mmio = {
    lsAmmio_ahb_fatal_err        // 1    9:9
  , lsAmmio_ahb_hexokay          // 1    8:8
  , lsAmmio_ahb_hreadyout        // 1    7:7
  , lsAmmio_ahb_hreadyoutchk     // 1    6:6
  , lsAmmio_ahb_hresp            // 1    5:5
  , lsAmmio_ahb_hrespchk         // 1    4:4
  , lsAmmio_ahb_hrdatachk        // 4    3:0
    };
assign lsBagg_mmio = {
    lsBmmio_ahb_fatal_err        // 1    9:9
  , lsBmmio_ahb_hexokay          // 1    8:8
  , lsBmmio_ahb_hreadyout        // 1    7:7
  , lsBmmio_ahb_hreadyoutchk     // 1    6:6
  , lsBmmio_ahb_hresp            // 1    5:5
  , lsBmmio_ahb_hrespchk         // 1    4:4
  , lsBmmio_ahb_hrdatachk        // 4    3:0
    };



// VERIF,agg_mmio,10


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_mmio)),
    .DELAY(0)
) u_compare_agg_mmio (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_mmio),
    .shadow_interface   (lsBagg_mmio),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[57:56]),
    .error_bits         (err_agg_mmio)
    );

// Key: safety.
wire [1:0] err_agg_safety;
wire [1:0] lsAagg_safety;
wire [1:0] lsBagg_safety;
assign lsAagg_safety = {
    lsAsafety_comparator_enable  // 2    1:0
    };
assign lsBagg_safety = {
    lsBsafety_comparator_enable  // 2    1:0
    };



// VERIF,agg_safety,2


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_safety)),
    .DELAY(0)
) u_compare_agg_safety (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_safety),
    .shadow_interface   (lsBagg_safety),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[59:58]),
    .error_bits         (err_agg_safety)
    );

// Key: sfty.
wire [1:0] err_agg_sfty_0;
wire [30:0] lsAagg_sfty_0;
wire [30:0] lsBagg_sfty_0;
assign lsAagg_sfty_0 = {
    lsAsfty_dmsi_tgt_e2e_err     // 1    30:30
  , lsAsfty_ibp_mmio_cmd_addr_pty // 1    29:29
  , lsAsfty_ibp_mmio_cmd_aux     // 1    28:28
  , lsAsfty_ibp_mmio_cmd_burst_size // 1    27:27
  , lsAsfty_ibp_mmio_cmd_excl    // 1    26:26
  , lsAsfty_ibp_mmio_cmd_read    // 1    25:25
  , lsAsfty_ibp_mmio_cmd_valid   // 1    24:24
  , lsAsfty_ibp_mmio_cmd_valid_pty // 1    23:23
  , lsAsfty_ibp_mmio_ini_e2e_err // 1    22:22
  , lsAsfty_ibp_mmio_rd_accept   // 1    21:21
  , lsAsfty_ibp_mmio_rd_accept_pty // 1    20:20
  , lsAsfty_ibp_mmio_wr_last     // 1    19:19
  , lsAsfty_ibp_mmio_wr_last_pty // 1    18:18
  , lsAsfty_ibp_mmio_wr_resp_accept // 1    17:17
  , lsAsfty_ibp_mmio_wr_resp_accept_pty // 1    16:16
  , lsAsfty_ibp_mmio_wr_valid    // 1    15:15
  , lsAsfty_ibp_mmio_wr_valid_pty // 1    14:14
  , lsAsfty_mem_adr_err          // 1    13:13
  , lsAsfty_mem_dbe_err          // 1    12:12
  , lsAsfty_mem_sbe_err          // 1    11:11
  , lsAsfty_mem_sbe_overflow     // 1    10:10
  , lsAsfty_nsi_r                // 1    9:9
  , lsAsfty_ibp_mmio_cmd_prot    // 2    8:7
  , lsAsfty_ibp_mmio_cmd_data_size // 3    6:4
  , lsAsfty_ibp_mmio_cmd_cache   // 4    3:0
    };
assign lsBagg_sfty_0 = {
    lsBsfty_dmsi_tgt_e2e_err     // 1    30:30
  , lsBsfty_ibp_mmio_cmd_addr_pty // 1    29:29
  , lsBsfty_ibp_mmio_cmd_aux     // 1    28:28
  , lsBsfty_ibp_mmio_cmd_burst_size // 1    27:27
  , lsBsfty_ibp_mmio_cmd_excl    // 1    26:26
  , lsBsfty_ibp_mmio_cmd_read    // 1    25:25
  , lsBsfty_ibp_mmio_cmd_valid   // 1    24:24
  , lsBsfty_ibp_mmio_cmd_valid_pty // 1    23:23
  , lsBsfty_ibp_mmio_ini_e2e_err // 1    22:22
  , lsBsfty_ibp_mmio_rd_accept   // 1    21:21
  , lsBsfty_ibp_mmio_rd_accept_pty // 1    20:20
  , lsBsfty_ibp_mmio_wr_last     // 1    19:19
  , lsBsfty_ibp_mmio_wr_last_pty // 1    18:18
  , lsBsfty_ibp_mmio_wr_resp_accept // 1    17:17
  , lsBsfty_ibp_mmio_wr_resp_accept_pty // 1    16:16
  , lsBsfty_ibp_mmio_wr_valid    // 1    15:15
  , lsBsfty_ibp_mmio_wr_valid_pty // 1    14:14
  , lsBsfty_mem_adr_err          // 1    13:13
  , lsBsfty_mem_dbe_err          // 1    12:12
  , lsBsfty_mem_sbe_err          // 1    11:11
  , lsBsfty_mem_sbe_overflow     // 1    10:10
  , lsBsfty_nsi_r                // 1    9:9
  , lsBsfty_ibp_mmio_cmd_prot    // 2    8:7
  , lsBsfty_ibp_mmio_cmd_data_size // 3    6:4
  , lsBsfty_ibp_mmio_cmd_cache   // 4    3:0
    };



// VERIF,agg_sfty_0,31


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_sfty_0)),
    .DELAY(0)
) u_compare_agg_sfty_0 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_sfty_0),
    .shadow_interface   (lsBagg_sfty_0),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[61:60]),
    .error_bits         (err_agg_sfty_0)
    );

// Key: sfty.
wire [1:0] err_agg_sfty_1;
wire [9:0] lsAagg_sfty_1;
wire [9:0] lsBagg_sfty_1;
assign lsAagg_sfty_1 = {
    lsAsfty_ibp_mmio_cmd_ctrl_pty // 4    9:6
  , lsAsfty_ibp_mmio_cmd_atomic  // 6    5:0
    };
assign lsBagg_sfty_1 = {
    lsBsfty_ibp_mmio_cmd_ctrl_pty // 4    9:6
  , lsBsfty_ibp_mmio_cmd_atomic  // 6    5:0
    };



// VERIF,agg_sfty_1,10


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_sfty_1)),
    .DELAY(0)
) u_compare_agg_sfty_1 (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_sfty_1),
    .shadow_interface   (lsBagg_sfty_1),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[63:62]),
    .error_bits         (err_agg_sfty_1)
    );

// Key: sys.
wire [1:0] err_agg_sys;
wire [4:0] lsAagg_sys;
wire [4:0] lsBagg_sys;
assign lsAagg_sys = {
    lsAsys_halt_r                // 1    4:4
  , lsAsys_sleep_r               // 1    3:3
  , lsAsys_sleep_mode_r          // 3    2:0
    };
assign lsBagg_sys = {
    lsBsys_halt_r                // 1    4:4
  , lsBsys_sleep_r               // 1    3:3
  , lsBsys_sleep_mode_r          // 3    2:0
    };



// VERIF,agg_sys,5


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_sys)),
    .DELAY(0)
) u_compare_agg_sys (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_sys),
    .shadow_interface   (lsBagg_sys),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[65:64]),
    .error_bits         (err_agg_sys)
    );

// Key: wdt.
wire [1:0] err_agg_wdt;
wire [1:0] lsAagg_wdt;
wire [1:0] lsBagg_wdt;
assign lsAagg_wdt = {
    lsAwdt_feedback_bit          // 1    1:1
  , lsAwdt_reset0                // 1    0:0
    };
assign lsBagg_wdt = {
    lsBwdt_feedback_bit          // 1    1:1
  , lsBwdt_reset0                // 1    0:0
    };



// VERIF,agg_wdt,2


ls_compare_unit #(
    .REG_WIDTH($bits(lsAagg_wdt)),
    .DELAY(0)
) u_compare_agg_wdt (
    .clk                (cpu_clk_gated),
    .rst                (cpu_rst_gated),
    .main_interface     (lsAagg_wdt),
    .shadow_interface   (lsBagg_wdt),
    .safety_diag_inject_sc  (cpu_dr_sfty_diag_mode_sc),
    .error_injection_valid  (error_mask_sc[67:66]),
    .error_bits         (err_agg_wdt)
    );

/////////////////////////////////////////////////////////////////////
// Collect error and parity results per section.
// error_X is 1 if an error occurred in section X.
// parity_error_X is 1 if a parity error occurred in section X.
/////////////////////////////////////////////////////////////////////

// Comparison result for group ahb .
wire error_bit_ahb = ~ (
      (^err_agg_ahb_0)
    & (^err_agg_ahb_1)
    & (^err_ahb_haddr)
    );

// Comparison result for group arc2dm .
wire error_bit_arc2dm = ~ (
      (^err_agg_arc2dm)
    );

// Comparison result for group dbu .
wire error_bit_dbu = ~ (
      (^err_agg_dbu_0)
    & (^err_agg_dbu_1)
    & (^err_dbu_per_ahb_haddr)
    );

// Comparison result for group dccm .
wire error_bit_dccm = ~ (
      (^err_agg_dccm)
    );

// Comparison result for group dmsi .
wire error_bit_dmsi = ~ (
      (^err_agg_dmsi)
    );

// Comparison result for group dr .
wire error_bit_dr = ~ (
      (^err_agg_dr)
    );

// Comparison result for group esrams .
wire error_bit_esrams = ~ (
      (^err_agg_esrams_0)
    & (^err_agg_esrams_1)
    & (^err_agg_esrams_2)
    & (^err_agg_esrams_3)
    & (^err_agg_esrams_4)
    & (^err_esrams_dccm_din_even)
    & (^err_esrams_dccm_din_odd)
    & (^err_esrams_iccm0_din)
    & (^err_esrams_ic_tag_mem_din)
    & (^err_esrams_ic_tag_mem_wem)
    & (^err_esrams_ic_data_mem_din)
    & (^err_esrams_ic_data_mem_wem)
    );

// Comparison result for group ext .
wire error_bit_ext = ~ (
      (^err_agg_ext)
    );

// Comparison result for group gclk .
wire error_bit_gclk = ~ (
      (^err_agg_gclk)
    );

// Comparison result for group ic .
wire error_bit_ic = ~ (
      (^err_agg_ic)
    );

// Comparison result for group iccm .
wire error_bit_iccm = ~ (
      (^err_agg_iccm)
    );

// Comparison result for group iccm0 .
wire error_bit_iccm0 = ~ (
      (^err_agg_iccm0)
    );

// Comparison result for group lsc .
wire error_bit_lsc = ~ (
      (^err_agg_lsc)
    );

// Comparison result for group mmio .
wire error_bit_mmio = ~ (
      (^err_agg_mmio)
    );

// Comparison result for group safety .
wire error_bit_safety = ~ (
      (^err_agg_safety)
    );

// Comparison result for group sfty .
wire error_bit_sfty = ~ (
      (^err_agg_sfty_0)
    & (^err_agg_sfty_1)
    );

// Comparison result for group sys .
wire error_bit_sys = ~ (
      (^err_agg_sys)
    );

// Comparison result for group wdt .
wire error_bit_wdt = ~ (
      (^err_agg_wdt)
    );
/////////////////////////////////////////////////////////////////////
// CSV entries for documentation purposes.
/////////////////////////////////////////////////////////////////////
// CSV,==========================
//CSV ,total number of compared bits,,,,783
//CSV ,0,agg_ahb_0,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11:10,9:7,6:4,3:0,
//CSV ,,,ahb_fatal_err,ahb_hauserchk,ahb_hctrlchk1,ahb_hctrlchk2,ahb_hexcl,ahb_hmastlock,ahb_hnonsec,ahb_hprotchk,ahb_htranschk,ahb_hwrite,ahb_hwstrbchk,cpu_in_reset_state,critical_error,hart_unavailable,high_prio_ras,reg_wr_en0,soft_reset_ready,ahb_htrans,ahb_hburst,ahb_hsize,ahb_haddrchk,
//CSV ,1,agg_ahb_1,26:23,22:19,18:15,14:8,7:0,
//CSV ,,,ahb_hmaster,ahb_hwdatachk,ahb_hwstrb,ahb_hprot,ahb_hauser,
//CSV ,2,ahb_haddr,31:0,
//CSV ,,,ahb_haddr,
//CSV ,3,agg_arc2dm,2,1,0,
//CSV ,,,arc2dm_halt_ack,arc2dm_havereset_a,arc2dm_run_ack,
//CSV ,4,agg_dbu_0,30,29,28,27,26,25,24,23,22,21,20,19:18,17:15,14:12,11:8,7:4,3:0,
//CSV ,,,dbu_per_ahb_fatal_err,dbu_per_ahb_hauserchk,dbu_per_ahb_hctrlchk1,dbu_per_ahb_hctrlchk2,dbu_per_ahb_hexcl,dbu_per_ahb_hmastlock,dbu_per_ahb_hnonsec,dbu_per_ahb_hprotchk,dbu_per_ahb_htranschk,dbu_per_ahb_hwrite,dbu_per_ahb_hwstrbchk,dbu_per_ahb_htrans,dbu_per_ahb_hburst,dbu_per_ahb_hsize,dbu_per_ahb_haddrchk,dbu_per_ahb_hmaster,dbu_per_ahb_hwdatachk,
//CSV ,5,agg_dbu_1,18:15,14:8,7:0,
//CSV ,,,dbu_per_ahb_hwstrb,dbu_per_ahb_hprot,dbu_per_ahb_hauser,
//CSV ,6,dbu_per_ahb_haddr,31:0,
//CSV ,,,dbu_per_ahb_haddr,
//CSV ,7,agg_dccm,13,12,11,10,9,8,7:6,5:4,3:0,
//CSV ,,,dccm_ahb_fatal_err,dccm_ahb_hexokay,dccm_ahb_hreadyout,dccm_ahb_hreadyoutchk,dccm_ahb_hresp,dccm_ahb_hrespchk,dccm_even_gclk_cnt,dccm_odd_gclk_cnt,dccm_ahb_hrdatachk,
//CSV ,8,agg_dmsi,1,0,
//CSV ,,,dmsi_rdy,dmsi_rdy_chk,
//CSV ,9,agg_dr,9:8,7:6,5:4,3:2,1:0,
//CSV ,,,dr_bus_fatal_err,dr_lsc_stl_ctrl_aux_r,dr_safety_iso_err,dr_secure_trig_iso_err,dr_sfty_aux_parity_err_r,
//CSV ,10,agg_esrams_0,24,23,22,21,20,19,18,17,16,15,14:10,9:5,4:0,
//CSV ,,,esrams_dccm_cs_even,esrams_dccm_cs_odd,esrams_dccm_we_even,esrams_dccm_we_odd,esrams_ic_data_mem_cs,esrams_ic_data_mem_we,esrams_ic_tag_mem_cs,esrams_ic_tag_mem_we,esrams_iccm0_cs,esrams_iccm0_we,esrams_dccm_wem_even,esrams_dccm_wem_odd,esrams_iccm0_wem,
//CSV ,11,agg_esrams_1,18:11,10:0,
//CSV ,,,esrams_ic_tag_mem_addr,esrams_ic_data_mem_addr,
//CSV ,12,agg_esrams_2,16:0,
//CSV ,,,esrams_dccm_addr_even,
//CSV ,13,agg_esrams_3,16:0,
//CSV ,,,esrams_dccm_addr_odd,
//CSV ,14,agg_esrams_4,16:0,
//CSV ,,,esrams_iccm0_addr,
//CSV ,15,esrams_dccm_din_even_0,31:0,
//CSV ,,,esrams_dccm_din_even[31:0],
//CSV ,16,esrams_dccm_din_even_1,7:0,
//CSV ,,,esrams_dccm_din_even[39:32],
//CSV ,17,esrams_dccm_din_odd_0,31:0,
//CSV ,,,esrams_dccm_din_odd[31:0],
//CSV ,18,esrams_dccm_din_odd_1,7:0,
//CSV ,,,esrams_dccm_din_odd[39:32],
//CSV ,19,esrams_iccm0_din_0,31:0,
//CSV ,,,esrams_iccm0_din[31:0],
//CSV ,20,esrams_iccm0_din_1,7:0,
//CSV ,,,esrams_iccm0_din[39:32],
//CSV ,21,esrams_ic_tag_mem_din_0,31:0,
//CSV ,,,esrams_ic_tag_mem_din[31:0],
//CSV ,22,esrams_ic_tag_mem_din_1,23:0,
//CSV ,,,esrams_ic_tag_mem_din[55:32],
//CSV ,23,esrams_ic_tag_mem_wem_0,31:0,
//CSV ,,,esrams_ic_tag_mem_wem[31:0],
//CSV ,24,esrams_ic_tag_mem_wem_1,23:0,
//CSV ,,,esrams_ic_tag_mem_wem[55:32],
//CSV ,25,esrams_ic_data_mem_din_0,31:0,
//CSV ,,,esrams_ic_data_mem_din[31:0],
//CSV ,26,esrams_ic_data_mem_din_1,31:0,
//CSV ,,,esrams_ic_data_mem_din[63:32],
//CSV ,27,esrams_ic_data_mem_din_2,15:0,
//CSV ,,,esrams_ic_data_mem_din[79:64],
//CSV ,28,esrams_ic_data_mem_wem_0,31:0,
//CSV ,,,esrams_ic_data_mem_wem[31:0],
//CSV ,29,esrams_ic_data_mem_wem_1,31:0,
//CSV ,,,esrams_ic_data_mem_wem[63:32],
//CSV ,30,esrams_ic_data_mem_wem_2,15:0,
//CSV ,,,esrams_ic_data_mem_wem[79:64],
//CSV ,31,agg_ext,1:0,
//CSV ,,,ext_trig_output_valid,
//CSV ,32,agg_gclk,1:0,
//CSV ,,,gclk_cnt,
//CSV ,33,agg_ic,3:2,1:0,
//CSV ,,,ic_data_mem_gclk_cnt,ic_tag_mem_gclk_cnt,
//CSV ,34,agg_iccm,9,8,7,6,5,4,3:0,
//CSV ,,,iccm_ahb_fatal_err,iccm_ahb_hexokay,iccm_ahb_hreadyout,iccm_ahb_hreadyoutchk,iccm_ahb_hresp,iccm_ahb_hrespchk,iccm_ahb_hrdatachk,
//CSV ,35,agg_iccm0,1:0,
//CSV ,,,iccm0_gclk_cnt,
//CSV ,36,agg_lsc,16,15:0,
//CSV ,,,lsc_shd_ctrl_aux_r,lsc_diag_aux_r,
//CSV ,37,agg_mmio,9,8,7,6,5,4,3:0,
//CSV ,,,mmio_ahb_fatal_err,mmio_ahb_hexokay,mmio_ahb_hreadyout,mmio_ahb_hreadyoutchk,mmio_ahb_hresp,mmio_ahb_hrespchk,mmio_ahb_hrdatachk,
//CSV ,38,agg_safety,1:0,
//CSV ,,,safety_comparator_enable,
//CSV ,39,agg_sfty_0,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8:7,6:4,3:0,
//CSV ,,,sfty_dmsi_tgt_e2e_err,sfty_ibp_mmio_cmd_addr_pty,sfty_ibp_mmio_cmd_aux,sfty_ibp_mmio_cmd_burst_size,sfty_ibp_mmio_cmd_excl,sfty_ibp_mmio_cmd_read,sfty_ibp_mmio_cmd_valid,sfty_ibp_mmio_cmd_valid_pty,sfty_ibp_mmio_ini_e2e_err,sfty_ibp_mmio_rd_accept,sfty_ibp_mmio_rd_accept_pty,sfty_ibp_mmio_wr_last,sfty_ibp_mmio_wr_last_pty,sfty_ibp_mmio_wr_resp_accept,sfty_ibp_mmio_wr_resp_accept_pty,sfty_ibp_mmio_wr_valid,sfty_ibp_mmio_wr_valid_pty,sfty_mem_adr_err,sfty_mem_dbe_err,sfty_mem_sbe_err,sfty_mem_sbe_overflow,sfty_nsi_r,sfty_ibp_mmio_cmd_prot,sfty_ibp_mmio_cmd_data_size,sfty_ibp_mmio_cmd_cache,
//CSV ,40,agg_sfty_1,9:6,5:0,
//CSV ,,,sfty_ibp_mmio_cmd_ctrl_pty,sfty_ibp_mmio_cmd_atomic,
//CSV ,41,agg_sys,4,3,2:0,
//CSV ,,,sys_halt_r,sys_sleep_r,sys_sleep_mode_r,
//CSV ,42,agg_wdt,1,0,
//CSV ,,,wdt_feedback_bit,wdt_reset0,





/////////////////////////////////////////////////////////////////////
// Compute a single error bit from the individual comparator error bits
/////////////////////////////////////////////////////////////////////

// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
// SMD: Sequential convergence found
// SJ:  The convergence sources are independent to each other without logical dependency
wire error_union = error_bit_ahb| error_bit_arc2dm| error_bit_dbu| error_bit_dccm| error_bit_dmsi| error_bit_dr| error_bit_esrams| error_bit_ext| error_bit_gclk| error_bit_ic| error_bit_iccm| error_bit_iccm0| error_bit_lsc| error_bit_mmio| error_bit_safety| error_bit_sfty| error_bit_sys| error_bit_wdt;
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ

ls_error_register #(
    .DELAY (0)
) u_error_register (
    .error_bit (error_union),

    // Fixed signal outputs
    .mismatch_r      (mismatch_r),
    .ls_enabled     (ls_enabled),
    .ls_enabled_d (ls_enabled_d),

    // Fixed signal inputs
    .ls_ctrl_enable (ls_ctrl_enable),
    .ls_lock_reset  (ls_lock_reset),
    .main_clk       (cpu_clk_gated),
    .shadow_clk     (cpu_clk_gated),
    .diag_mode      (cpu_dr_sfty_diag_mode_sc),
    .diag_mask_first      (valid_mask_sc[0]),
    .diag_mask_last      (valid_mask_sc[$bits(valid_mask_sc)-1]),
    .rst            (cpu_rst_gated)
    );


/////////////////////////////////////////////////////////////////////
// Connections to the second core, delayed.
/////////////////////////////////////////////////////////////////////

  assign safety_shadow_clk = cpu_clk_gated;







wire gated_lsAclk;
clkgate u_clkgate_shadow_gate_clk (
  .clk_in            (lsAclk),
  .clock_enable_r    (~lsAlsc_shd_ctrl_aux_r),
  .clk_out           (gated_lsAclk)
);
  assign lsBclk =  gated_lsAclk;
  assign lsBtm_clk_enable_sync = lsAtm_clk_enable_sync;
  assign lsBrst_synch_r = lsArst_synch_r;
  assign lsBrst_cpu_req_synch_r = lsArst_cpu_req_synch_r;
  assign lsBtest_mode = lsAtest_mode;
  assign lsBLBIST_EN = lsALBIST_EN;
  assign lsBdm2arc_halt_req_synch_r = lsAdm2arc_halt_req_synch_r;
  assign lsBdm2arc_run_req_synch_r = lsAdm2arc_run_req_synch_r;
  assign lsBdm2arc_hartreset_synch_r = lsAdm2arc_hartreset_synch_r;
  assign lsBdm2arc_hartreset2_synch_r = lsAdm2arc_hartreset2_synch_r;
  assign lsBndmreset_synch_r = lsAndmreset_synch_r;
  assign lsBdm2arc_havereset_ack_synch_r = lsAdm2arc_havereset_ack_synch_r;
  assign lsBdm2arc_halt_on_reset_synch_r = lsAdm2arc_halt_on_reset_synch_r;
  assign lsBdm2arc_relaxedpriv_synch_r = lsAdm2arc_relaxedpriv_synch_r;
  assign lsBahb_hready = lsAahb_hready;
  assign lsBahb_hresp = lsAahb_hresp;
  assign lsBahb_hexokay = lsAahb_hexokay;
  assign lsBahb_hrdata = lsAahb_hrdata;
  assign lsBahb_hreadychk = lsAahb_hreadychk;
  assign lsBahb_hrespchk = lsAahb_hrespchk;
  assign lsBahb_hrdatachk = lsAahb_hrdatachk;
  assign lsBdbu_per_ahb_hready = lsAdbu_per_ahb_hready;
  assign lsBdbu_per_ahb_hresp = lsAdbu_per_ahb_hresp;
  assign lsBdbu_per_ahb_hexokay = lsAdbu_per_ahb_hexokay;
  assign lsBdbu_per_ahb_hrdata = lsAdbu_per_ahb_hrdata;
  assign lsBdbu_per_ahb_hreadychk = lsAdbu_per_ahb_hreadychk;
  assign lsBdbu_per_ahb_hrespchk = lsAdbu_per_ahb_hrespchk;
  assign lsBdbu_per_ahb_hrdatachk = lsAdbu_per_ahb_hrdatachk;
  assign lsBiccm_ahb_prio = lsAiccm_ahb_prio;
  assign lsBiccm_ahb_hmastlock = lsAiccm_ahb_hmastlock;
  assign lsBiccm_ahb_hexcl = lsAiccm_ahb_hexcl;
  assign lsBiccm_ahb_hmaster = lsAiccm_ahb_hmaster;
  assign lsBiccm_ahb_hsel = lsAiccm_ahb_hsel;
  assign lsBiccm_ahb_htrans = lsAiccm_ahb_htrans;
  assign lsBiccm_ahb_hwrite = lsAiccm_ahb_hwrite;
  assign lsBiccm_ahb_haddr = lsAiccm_ahb_haddr;
  assign lsBiccm_ahb_hsize = lsAiccm_ahb_hsize;
  assign lsBiccm_ahb_hwstrb = lsAiccm_ahb_hwstrb;
  assign lsBiccm_ahb_hburst = lsAiccm_ahb_hburst;
  assign lsBiccm_ahb_hprot = lsAiccm_ahb_hprot;
  assign lsBiccm_ahb_hnonsec = lsAiccm_ahb_hnonsec;
  assign lsBiccm_ahb_hwdata = lsAiccm_ahb_hwdata;
  assign lsBiccm_ahb_hready = lsAiccm_ahb_hready;
  assign lsBiccm_ahb_haddrchk = lsAiccm_ahb_haddrchk;
  assign lsBiccm_ahb_htranschk = lsAiccm_ahb_htranschk;
  assign lsBiccm_ahb_hctrlchk1 = lsAiccm_ahb_hctrlchk1;
  assign lsBiccm_ahb_hctrlchk2 = lsAiccm_ahb_hctrlchk2;
  assign lsBiccm_ahb_hwstrbchk = lsAiccm_ahb_hwstrbchk;
  assign lsBiccm_ahb_hprotchk = lsAiccm_ahb_hprotchk;
  assign lsBiccm_ahb_hreadychk = lsAiccm_ahb_hreadychk;
  assign lsBiccm_ahb_hselchk = lsAiccm_ahb_hselchk;
  assign lsBiccm_ahb_hwdatachk = lsAiccm_ahb_hwdatachk;
  assign lsBdccm_ahb_prio = lsAdccm_ahb_prio;
  assign lsBdccm_ahb_hmastlock = lsAdccm_ahb_hmastlock;
  assign lsBdccm_ahb_hexcl = lsAdccm_ahb_hexcl;
  assign lsBdccm_ahb_hmaster = lsAdccm_ahb_hmaster;
  assign lsBdccm_ahb_hsel = lsAdccm_ahb_hsel;
  assign lsBdccm_ahb_htrans = lsAdccm_ahb_htrans;
  assign lsBdccm_ahb_hwrite = lsAdccm_ahb_hwrite;
  assign lsBdccm_ahb_haddr = lsAdccm_ahb_haddr;
  assign lsBdccm_ahb_hsize = lsAdccm_ahb_hsize;
  assign lsBdccm_ahb_hwstrb = lsAdccm_ahb_hwstrb;
  assign lsBdccm_ahb_hnonsec = lsAdccm_ahb_hnonsec;
  assign lsBdccm_ahb_hburst = lsAdccm_ahb_hburst;
  assign lsBdccm_ahb_hprot = lsAdccm_ahb_hprot;
  assign lsBdccm_ahb_hwdata = lsAdccm_ahb_hwdata;
  assign lsBdccm_ahb_hready = lsAdccm_ahb_hready;
  assign lsBdccm_ahb_haddrchk = lsAdccm_ahb_haddrchk;
  assign lsBdccm_ahb_htranschk = lsAdccm_ahb_htranschk;
  assign lsBdccm_ahb_hctrlchk1 = lsAdccm_ahb_hctrlchk1;
  assign lsBdccm_ahb_hctrlchk2 = lsAdccm_ahb_hctrlchk2;
  assign lsBdccm_ahb_hwstrbchk = lsAdccm_ahb_hwstrbchk;
  assign lsBdccm_ahb_hprotchk = lsAdccm_ahb_hprotchk;
  assign lsBdccm_ahb_hreadychk = lsAdccm_ahb_hreadychk;
  assign lsBdccm_ahb_hselchk = lsAdccm_ahb_hselchk;
  assign lsBdccm_ahb_hwdatachk = lsAdccm_ahb_hwdatachk;
  assign lsBmmio_ahb_prio = lsAmmio_ahb_prio;
  assign lsBmmio_ahb_hmastlock = lsAmmio_ahb_hmastlock;
  assign lsBmmio_ahb_hexcl = lsAmmio_ahb_hexcl;
  assign lsBmmio_ahb_hmaster = lsAmmio_ahb_hmaster;
  assign lsBmmio_ahb_hsel = lsAmmio_ahb_hsel;
  assign lsBmmio_ahb_htrans = lsAmmio_ahb_htrans;
  assign lsBmmio_ahb_hwrite = lsAmmio_ahb_hwrite;
  assign lsBmmio_ahb_haddr = lsAmmio_ahb_haddr;
  assign lsBmmio_ahb_hsize = lsAmmio_ahb_hsize;
  assign lsBmmio_ahb_hwstrb = lsAmmio_ahb_hwstrb;
  assign lsBmmio_ahb_hnonsec = lsAmmio_ahb_hnonsec;
  assign lsBmmio_ahb_hburst = lsAmmio_ahb_hburst;
  assign lsBmmio_ahb_hprot = lsAmmio_ahb_hprot;
  assign lsBmmio_ahb_hwdata = lsAmmio_ahb_hwdata;
  assign lsBmmio_ahb_hready = lsAmmio_ahb_hready;
  assign lsBmmio_ahb_haddrchk = lsAmmio_ahb_haddrchk;
  assign lsBmmio_ahb_htranschk = lsAmmio_ahb_htranschk;
  assign lsBmmio_ahb_hctrlchk1 = lsAmmio_ahb_hctrlchk1;
  assign lsBmmio_ahb_hctrlchk2 = lsAmmio_ahb_hctrlchk2;
  assign lsBmmio_ahb_hwstrbchk = lsAmmio_ahb_hwstrbchk;
  assign lsBmmio_ahb_hprotchk = lsAmmio_ahb_hprotchk;
  assign lsBmmio_ahb_hreadychk = lsAmmio_ahb_hreadychk;
  assign lsBmmio_ahb_hselchk = lsAmmio_ahb_hselchk;
  assign lsBmmio_ahb_hwdatachk = lsAmmio_ahb_hwdatachk;
  assign lsBmmio_base_in = lsAmmio_base_in;
  assign lsBreset_pc_in = lsAreset_pc_in;
  assign lsBrnmi_synch_r = lsArnmi_synch_r;
  assign lsBesrams_iccm0_dout = lsAesrams_iccm0_dout;
  assign lsBesrams_dccm_dout_even = lsAesrams_dccm_dout_even;
  assign lsBesrams_dccm_dout_odd = lsAesrams_dccm_dout_odd;
  assign lsBesrams_ic_tag_mem_dout = lsAesrams_ic_tag_mem_dout;
  assign lsBesrams_ic_data_mem_dout = lsAesrams_ic_data_mem_dout;
  assign lsBext_trig_output_accept = lsAext_trig_output_accept;
  assign lsBext_trig_in = lsAext_trig_in;
  assign lsBdr_safety_comparator_enabled = lsAdr_safety_comparator_enabled;
  assign lsBsafety_iso_enb_synch_r = lsAsafety_iso_enb_synch_r;
  assign lsBlsc_err_stat_aux = lsAlsc_err_stat_aux;
  assign lsBdr_sfty_eic = lsAdr_sfty_eic;
  assign lsBsfty_ibp_mmio_cmd_accept = lsAsfty_ibp_mmio_cmd_accept;
  assign lsBsfty_ibp_mmio_wr_accept = lsAsfty_ibp_mmio_wr_accept;
  assign lsBsfty_ibp_mmio_rd_valid = lsAsfty_ibp_mmio_rd_valid;
  assign lsBsfty_ibp_mmio_rd_err = lsAsfty_ibp_mmio_rd_err;
  assign lsBsfty_ibp_mmio_rd_excl_ok = lsAsfty_ibp_mmio_rd_excl_ok;
  assign lsBsfty_ibp_mmio_rd_last = lsAsfty_ibp_mmio_rd_last;
  assign lsBsfty_ibp_mmio_rd_data = lsAsfty_ibp_mmio_rd_data;
  assign lsBsfty_ibp_mmio_wr_done = lsAsfty_ibp_mmio_wr_done;
  assign lsBsfty_ibp_mmio_wr_excl_okay = lsAsfty_ibp_mmio_wr_excl_okay;
  assign lsBsfty_ibp_mmio_wr_err = lsAsfty_ibp_mmio_wr_err;
  assign lsBsfty_ibp_mmio_cmd_accept_pty = lsAsfty_ibp_mmio_cmd_accept_pty;
  assign lsBsfty_ibp_mmio_wr_accept_pty = lsAsfty_ibp_mmio_wr_accept_pty;
  assign lsBsfty_ibp_mmio_rd_valid_pty = lsAsfty_ibp_mmio_rd_valid_pty;
  assign lsBsfty_ibp_mmio_rd_ctrl_pty = lsAsfty_ibp_mmio_rd_ctrl_pty;
  assign lsBsfty_ibp_mmio_rd_data_pty = lsAsfty_ibp_mmio_rd_data_pty;
  assign lsBsfty_ibp_mmio_wr_done_pty = lsAsfty_ibp_mmio_wr_done_pty;
  assign lsBsfty_ibp_mmio_wr_ctrl_pty = lsAsfty_ibp_mmio_wr_ctrl_pty;
  assign lsBwdt_clk_enable_sync = lsAwdt_clk_enable_sync;
  assign lsBdmsi_valid = lsAdmsi_valid;
  assign lsBdmsi_context = lsAdmsi_context;
  assign lsBdmsi_eiid = lsAdmsi_eiid;
  assign lsBdmsi_domain = lsAdmsi_domain;
  assign lsBdmsi_valid_chk = lsAdmsi_valid_chk;
  assign lsBdmsi_data_edc = lsAdmsi_data_edc;
  assign lsBdbg_ibp_cmd_valid = lsAdbg_ibp_cmd_valid;
  assign lsBdbg_ibp_cmd_read = lsAdbg_ibp_cmd_read;
  assign lsBdbg_ibp_cmd_addr = lsAdbg_ibp_cmd_addr;
  assign lsBdbg_ibp_cmd_space = lsAdbg_ibp_cmd_space;
  assign lsBdbg_ibp_rd_accept = lsAdbg_ibp_rd_accept;
  assign lsBdbg_ibp_wr_valid = lsAdbg_ibp_wr_valid;
  assign lsBdbg_ibp_wr_data = lsAdbg_ibp_wr_data;
  assign lsBdbg_ibp_wr_mask = lsAdbg_ibp_wr_mask;
  assign lsBdbg_ibp_wr_resp_accept = lsAdbg_ibp_wr_resp_accept;
  assign lsBwid_rlwid = lsAwid_rlwid;
  assign lsBwid_rwiddeleg = lsAwid_rwiddeleg;
  assign lsBsoft_reset_prepare_synch_r = lsAsoft_reset_prepare_synch_r;
  assign lsBsoft_reset_req_synch_r = lsAsoft_reset_req_synch_r;
  assign lsBrst_init_disable_synch_r = lsArst_init_disable_synch_r;
  assign lsBarcnum = lsAarcnum;


// END Drive shadow signals.

/////////////////////////////////////////////////////////////////////
// Main module for rl_cpu_top
/////////////////////////////////////////////////////////////////////
rl_cpu_top u_main_rl_cpu_top(
    .clk      (lsAclk)
  , .tm_clk_enable_sync      (lsAtm_clk_enable_sync)
  , .rst_synch_r      (lsArst_synch_r)
  , .rst_cpu_req_synch_r      (lsArst_cpu_req_synch_r)
  , .rst_cpu_ack      (lsArst_cpu_ack)
  , .cpu_rst_gated      (lsAcpu_rst_gated)
  , .cpu_clk_gated      (lsAcpu_clk_gated)
  , .test_mode      (lsAtest_mode)
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ: No need to register testmode signal LBIST_EN
  , .LBIST_EN      (lsALBIST_EN)
// spyglass enable_block RegInputOutput-ML
  , .dm2arc_halt_req_synch_r      (lsAdm2arc_halt_req_synch_r)
  , .dm2arc_run_req_synch_r      (lsAdm2arc_run_req_synch_r)
  , .arc2dm_halt_ack      (lsAarc2dm_halt_ack)
  , .arc2dm_run_ack      (lsAarc2dm_run_ack)
  , .dm2arc_hartreset_synch_r      (lsAdm2arc_hartreset_synch_r)
  , .dm2arc_hartreset2_synch_r      (lsAdm2arc_hartreset2_synch_r)
  , .ndmreset_synch_r      (lsAndmreset_synch_r)
  , .dm2arc_havereset_ack_synch_r      (lsAdm2arc_havereset_ack_synch_r)
  , .dm2arc_halt_on_reset_synch_r      (lsAdm2arc_halt_on_reset_synch_r)
  , .arc2dm_havereset_a      (lsAarc2dm_havereset_a)
  , .dm2arc_relaxedpriv_synch_r      (lsAdm2arc_relaxedpriv_synch_r)
  , .hart_unavailable      (lsAhart_unavailable)
  , .ahb_hmastlock      (lsAahb_hmastlock)
  , .ahb_hexcl      (lsAahb_hexcl)
  , .ahb_hmaster      (lsAahb_hmaster)
  , .ahb_hauser      (lsAahb_hauser)
  , .ahb_hwrite      (lsAahb_hwrite)
  , .ahb_haddr      (lsAahb_haddr)
  , .ahb_htrans      (lsAahb_htrans)
  , .ahb_hsize      (lsAahb_hsize)
  , .ahb_hburst      (lsAahb_hburst)
  , .ahb_hwstrb      (lsAahb_hwstrb)
  , .ahb_hprot      (lsAahb_hprot)
  , .ahb_hnonsec      (lsAahb_hnonsec)
  , .ahb_hready      (lsAahb_hready)
  , .ahb_hresp      (lsAahb_hresp)
  , .ahb_hexokay      (lsAahb_hexokay)
  , .ahb_hrdata      (lsAahb_hrdata)
  , .ahb_hwdata      (lsAahb_hwdata)
  , .ahb_hauserchk      (lsAahb_hauserchk)
  , .ahb_haddrchk      (lsAahb_haddrchk)
  , .ahb_htranschk      (lsAahb_htranschk)
  , .ahb_hctrlchk1      (lsAahb_hctrlchk1)
  , .ahb_hctrlchk2      (lsAahb_hctrlchk2)
  , .ahb_hprotchk      (lsAahb_hprotchk)
  , .ahb_hwstrbchk      (lsAahb_hwstrbchk)
  , .ahb_hreadychk      (lsAahb_hreadychk)
  , .ahb_hrespchk      (lsAahb_hrespchk)
  , .ahb_hrdatachk      (lsAahb_hrdatachk)
  , .ahb_hwdatachk      (lsAahb_hwdatachk)
  , .ahb_fatal_err      (lsAahb_fatal_err)
  , .dbu_per_ahb_hmastlock      (lsAdbu_per_ahb_hmastlock)
  , .dbu_per_ahb_hexcl      (lsAdbu_per_ahb_hexcl)
  , .dbu_per_ahb_hmaster      (lsAdbu_per_ahb_hmaster)
  , .dbu_per_ahb_hauser      (lsAdbu_per_ahb_hauser)
  , .dbu_per_ahb_hwrite      (lsAdbu_per_ahb_hwrite)
  , .dbu_per_ahb_haddr      (lsAdbu_per_ahb_haddr)
  , .dbu_per_ahb_htrans      (lsAdbu_per_ahb_htrans)
  , .dbu_per_ahb_hsize      (lsAdbu_per_ahb_hsize)
  , .dbu_per_ahb_hburst      (lsAdbu_per_ahb_hburst)
  , .dbu_per_ahb_hwstrb      (lsAdbu_per_ahb_hwstrb)
  , .dbu_per_ahb_hprot      (lsAdbu_per_ahb_hprot)
  , .dbu_per_ahb_hnonsec      (lsAdbu_per_ahb_hnonsec)
  , .dbu_per_ahb_hready      (lsAdbu_per_ahb_hready)
  , .dbu_per_ahb_hresp      (lsAdbu_per_ahb_hresp)
  , .dbu_per_ahb_hexokay      (lsAdbu_per_ahb_hexokay)
  , .dbu_per_ahb_hrdata      (lsAdbu_per_ahb_hrdata)
  , .dbu_per_ahb_hwdata      (lsAdbu_per_ahb_hwdata)
  , .dbu_per_ahb_hauserchk      (lsAdbu_per_ahb_hauserchk)
  , .dbu_per_ahb_haddrchk      (lsAdbu_per_ahb_haddrchk)
  , .dbu_per_ahb_htranschk      (lsAdbu_per_ahb_htranschk)
  , .dbu_per_ahb_hctrlchk1      (lsAdbu_per_ahb_hctrlchk1)
  , .dbu_per_ahb_hctrlchk2      (lsAdbu_per_ahb_hctrlchk2)
  , .dbu_per_ahb_hprotchk      (lsAdbu_per_ahb_hprotchk)
  , .dbu_per_ahb_hwstrbchk      (lsAdbu_per_ahb_hwstrbchk)
  , .dbu_per_ahb_hreadychk      (lsAdbu_per_ahb_hreadychk)
  , .dbu_per_ahb_hrespchk      (lsAdbu_per_ahb_hrespchk)
  , .dbu_per_ahb_hrdatachk      (lsAdbu_per_ahb_hrdatachk)
  , .dbu_per_ahb_hwdatachk      (lsAdbu_per_ahb_hwdatachk)
  , .dbu_per_ahb_fatal_err      (lsAdbu_per_ahb_fatal_err)
  , .iccm_ahb_prio      (lsAiccm_ahb_prio)
  , .iccm_ahb_hmastlock      (lsAiccm_ahb_hmastlock)
  , .iccm_ahb_hexcl      (lsAiccm_ahb_hexcl)
  , .iccm_ahb_hmaster      (lsAiccm_ahb_hmaster)
  , .iccm_ahb_hsel      (lsAiccm_ahb_hsel)
  , .iccm_ahb_htrans      (lsAiccm_ahb_htrans)
  , .iccm_ahb_hwrite      (lsAiccm_ahb_hwrite)
  , .iccm_ahb_haddr      (lsAiccm_ahb_haddr)
  , .iccm_ahb_hsize      (lsAiccm_ahb_hsize)
  , .iccm_ahb_hwstrb      (lsAiccm_ahb_hwstrb)
  , .iccm_ahb_hburst      (lsAiccm_ahb_hburst)
  , .iccm_ahb_hprot      (lsAiccm_ahb_hprot)
  , .iccm_ahb_hnonsec      (lsAiccm_ahb_hnonsec)
  , .iccm_ahb_hwdata      (lsAiccm_ahb_hwdata)
  , .iccm_ahb_hready      (lsAiccm_ahb_hready)
  , .iccm_ahb_hrdata      (lsAiccm_ahb_hrdata)
  , .iccm_ahb_hresp      (lsAiccm_ahb_hresp)
  , .iccm_ahb_hexokay      (lsAiccm_ahb_hexokay)
  , .iccm_ahb_hreadyout      (lsAiccm_ahb_hreadyout)
  , .iccm_ahb_haddrchk      (lsAiccm_ahb_haddrchk)
  , .iccm_ahb_htranschk      (lsAiccm_ahb_htranschk)
  , .iccm_ahb_hctrlchk1      (lsAiccm_ahb_hctrlchk1)
  , .iccm_ahb_hctrlchk2      (lsAiccm_ahb_hctrlchk2)
  , .iccm_ahb_hwstrbchk      (lsAiccm_ahb_hwstrbchk)
  , .iccm_ahb_hprotchk      (lsAiccm_ahb_hprotchk)
  , .iccm_ahb_hreadychk      (lsAiccm_ahb_hreadychk)
  , .iccm_ahb_hrespchk      (lsAiccm_ahb_hrespchk)
  , .iccm_ahb_hreadyoutchk      (lsAiccm_ahb_hreadyoutchk)
  , .iccm_ahb_hselchk      (lsAiccm_ahb_hselchk)
  , .iccm_ahb_hrdatachk      (lsAiccm_ahb_hrdatachk)
  , .iccm_ahb_hwdatachk      (lsAiccm_ahb_hwdatachk)
  , .iccm_ahb_fatal_err      (lsAiccm_ahb_fatal_err)
  , .dccm_ahb_prio      (lsAdccm_ahb_prio)
  , .dccm_ahb_hmastlock      (lsAdccm_ahb_hmastlock)
  , .dccm_ahb_hexcl      (lsAdccm_ahb_hexcl)
  , .dccm_ahb_hmaster      (lsAdccm_ahb_hmaster)
  , .dccm_ahb_hsel      (lsAdccm_ahb_hsel)
  , .dccm_ahb_htrans      (lsAdccm_ahb_htrans)
  , .dccm_ahb_hwrite      (lsAdccm_ahb_hwrite)
  , .dccm_ahb_haddr      (lsAdccm_ahb_haddr)
  , .dccm_ahb_hsize      (lsAdccm_ahb_hsize)
  , .dccm_ahb_hwstrb      (lsAdccm_ahb_hwstrb)
  , .dccm_ahb_hnonsec      (lsAdccm_ahb_hnonsec)
  , .dccm_ahb_hburst      (lsAdccm_ahb_hburst)
  , .dccm_ahb_hprot      (lsAdccm_ahb_hprot)
  , .dccm_ahb_hwdata      (lsAdccm_ahb_hwdata)
  , .dccm_ahb_hready      (lsAdccm_ahb_hready)
  , .dccm_ahb_hrdata      (lsAdccm_ahb_hrdata)
  , .dccm_ahb_hresp      (lsAdccm_ahb_hresp)
  , .dccm_ahb_hexokay      (lsAdccm_ahb_hexokay)
  , .dccm_ahb_hreadyout      (lsAdccm_ahb_hreadyout)
  , .dccm_ahb_haddrchk      (lsAdccm_ahb_haddrchk)
  , .dccm_ahb_htranschk      (lsAdccm_ahb_htranschk)
  , .dccm_ahb_hctrlchk1      (lsAdccm_ahb_hctrlchk1)
  , .dccm_ahb_hctrlchk2      (lsAdccm_ahb_hctrlchk2)
  , .dccm_ahb_hwstrbchk      (lsAdccm_ahb_hwstrbchk)
  , .dccm_ahb_hprotchk      (lsAdccm_ahb_hprotchk)
  , .dccm_ahb_hreadychk      (lsAdccm_ahb_hreadychk)
  , .dccm_ahb_hrespchk      (lsAdccm_ahb_hrespchk)
  , .dccm_ahb_hreadyoutchk      (lsAdccm_ahb_hreadyoutchk)
  , .dccm_ahb_hselchk      (lsAdccm_ahb_hselchk)
  , .dccm_ahb_hrdatachk      (lsAdccm_ahb_hrdatachk)
  , .dccm_ahb_hwdatachk      (lsAdccm_ahb_hwdatachk)
  , .dccm_ahb_fatal_err      (lsAdccm_ahb_fatal_err)
  , .mmio_ahb_prio      (lsAmmio_ahb_prio)
  , .mmio_ahb_hmastlock      (lsAmmio_ahb_hmastlock)
  , .mmio_ahb_hexcl      (lsAmmio_ahb_hexcl)
  , .mmio_ahb_hmaster      (lsAmmio_ahb_hmaster)
  , .mmio_ahb_hsel      (lsAmmio_ahb_hsel)
  , .mmio_ahb_htrans      (lsAmmio_ahb_htrans)
  , .mmio_ahb_hwrite      (lsAmmio_ahb_hwrite)
  , .mmio_ahb_haddr      (lsAmmio_ahb_haddr)
  , .mmio_ahb_hsize      (lsAmmio_ahb_hsize)
  , .mmio_ahb_hwstrb      (lsAmmio_ahb_hwstrb)
  , .mmio_ahb_hnonsec      (lsAmmio_ahb_hnonsec)
  , .mmio_ahb_hburst      (lsAmmio_ahb_hburst)
  , .mmio_ahb_hprot      (lsAmmio_ahb_hprot)
  , .mmio_ahb_hwdata      (lsAmmio_ahb_hwdata)
  , .mmio_ahb_hready      (lsAmmio_ahb_hready)
  , .mmio_ahb_hrdata      (lsAmmio_ahb_hrdata)
  , .mmio_ahb_hresp      (lsAmmio_ahb_hresp)
  , .mmio_ahb_hexokay      (lsAmmio_ahb_hexokay)
  , .mmio_ahb_hreadyout      (lsAmmio_ahb_hreadyout)
  , .mmio_ahb_haddrchk      (lsAmmio_ahb_haddrchk)
  , .mmio_ahb_htranschk      (lsAmmio_ahb_htranschk)
  , .mmio_ahb_hctrlchk1      (lsAmmio_ahb_hctrlchk1)
  , .mmio_ahb_hctrlchk2      (lsAmmio_ahb_hctrlchk2)
  , .mmio_ahb_hwstrbchk      (lsAmmio_ahb_hwstrbchk)
  , .mmio_ahb_hprotchk      (lsAmmio_ahb_hprotchk)
  , .mmio_ahb_hreadychk      (lsAmmio_ahb_hreadychk)
  , .mmio_ahb_hrespchk      (lsAmmio_ahb_hrespchk)
  , .mmio_ahb_hreadyoutchk      (lsAmmio_ahb_hreadyoutchk)
  , .mmio_ahb_hselchk      (lsAmmio_ahb_hselchk)
  , .mmio_ahb_hrdatachk      (lsAmmio_ahb_hrdatachk)
  , .mmio_ahb_hwdatachk      (lsAmmio_ahb_hwdatachk)
  , .mmio_ahb_fatal_err      (lsAmmio_ahb_fatal_err)
  , .mmio_base_in      (lsAmmio_base_in)
  , .reset_pc_in      (lsAreset_pc_in)
  , .rnmi_synch_r      (lsArnmi_synch_r)
  , .esrams_iccm0_clk      (lsAesrams_iccm0_clk)
  , .esrams_iccm0_din      (lsAesrams_iccm0_din)
  , .esrams_iccm0_addr      (lsAesrams_iccm0_addr)
  , .esrams_iccm0_cs      (lsAesrams_iccm0_cs)
  , .esrams_iccm0_we      (lsAesrams_iccm0_we)
  , .esrams_iccm0_wem      (lsAesrams_iccm0_wem)
  , .esrams_iccm0_dout      (lsAesrams_iccm0_dout)
  , .esrams_dccm_even_clk      (lsAesrams_dccm_even_clk)
  , .esrams_dccm_din_even      (lsAesrams_dccm_din_even)
  , .esrams_dccm_addr_even      (lsAesrams_dccm_addr_even)
  , .esrams_dccm_cs_even      (lsAesrams_dccm_cs_even)
  , .esrams_dccm_we_even      (lsAesrams_dccm_we_even)
  , .esrams_dccm_wem_even      (lsAesrams_dccm_wem_even)
  , .esrams_dccm_dout_even      (lsAesrams_dccm_dout_even)
  , .esrams_dccm_odd_clk      (lsAesrams_dccm_odd_clk)
  , .esrams_dccm_din_odd      (lsAesrams_dccm_din_odd)
  , .esrams_dccm_addr_odd      (lsAesrams_dccm_addr_odd)
  , .esrams_dccm_cs_odd      (lsAesrams_dccm_cs_odd)
  , .esrams_dccm_we_odd      (lsAesrams_dccm_we_odd)
  , .esrams_dccm_wem_odd      (lsAesrams_dccm_wem_odd)
  , .esrams_dccm_dout_odd      (lsAesrams_dccm_dout_odd)
  , .esrams_ic_tag_mem_clk      (lsAesrams_ic_tag_mem_clk)
  , .esrams_ic_tag_mem_din      (lsAesrams_ic_tag_mem_din)
  , .esrams_ic_tag_mem_addr      (lsAesrams_ic_tag_mem_addr)
  , .esrams_ic_tag_mem_cs      (lsAesrams_ic_tag_mem_cs)
  , .esrams_ic_tag_mem_we      (lsAesrams_ic_tag_mem_we)
  , .esrams_ic_tag_mem_wem      (lsAesrams_ic_tag_mem_wem)
  , .esrams_ic_tag_mem_dout      (lsAesrams_ic_tag_mem_dout)
  , .esrams_ic_data_mem_clk      (lsAesrams_ic_data_mem_clk)
  , .esrams_ic_data_mem_din      (lsAesrams_ic_data_mem_din)
  , .esrams_ic_data_mem_addr      (lsAesrams_ic_data_mem_addr)
  , .esrams_ic_data_mem_cs      (lsAesrams_ic_data_mem_cs)
  , .esrams_ic_data_mem_we      (lsAesrams_ic_data_mem_we)
  , .esrams_ic_data_mem_wem      (lsAesrams_ic_data_mem_wem)
  , .esrams_ic_data_mem_dout      (lsAesrams_ic_data_mem_dout)
  , .esrams_clk      (lsAesrams_clk)
  , .esrams_ls      (lsAesrams_ls)
  , .ext_trig_output_accept      (lsAext_trig_output_accept)
  , .ext_trig_in      (lsAext_trig_in)
  , .ext_trig_output_valid      (lsAext_trig_output_valid)
  , .high_prio_ras      (lsAhigh_prio_ras)
  , .safety_comparator_enable      (lsAsafety_comparator_enable)
  , .lsc_diag_aux_r      (lsAlsc_diag_aux_r)
  , .dr_lsc_stl_ctrl_aux_r      (lsAdr_lsc_stl_ctrl_aux_r)
  , .lsc_shd_ctrl_aux_r      (lsAlsc_shd_ctrl_aux_r)
  , .dr_sfty_aux_parity_err_r      (lsAdr_sfty_aux_parity_err_r)
  , .dr_bus_fatal_err      (lsAdr_bus_fatal_err)
  , .dr_safety_comparator_enabled      (lsAdr_safety_comparator_enabled)
  , .safety_iso_enb_synch_r      (lsAsafety_iso_enb_synch_r)
  , .sfty_nsi_r      (lsAsfty_nsi_r)
  , .lsc_err_stat_aux      (lsAlsc_err_stat_aux)
  , .dr_sfty_eic      (lsAdr_sfty_eic)
  , .dr_safety_iso_err      (lsAdr_safety_iso_err)
  , .dr_secure_trig_iso_err      (lsAdr_secure_trig_iso_err)
  , .sfty_mem_sbe_err      (lsAsfty_mem_sbe_err)
  , .sfty_mem_dbe_err      (lsAsfty_mem_dbe_err)
  , .sfty_mem_adr_err      (lsAsfty_mem_adr_err)
  , .sfty_mem_sbe_overflow      (lsAsfty_mem_sbe_overflow)
  , .sfty_ibp_mmio_cmd_valid      (lsAsfty_ibp_mmio_cmd_valid)
  , .sfty_ibp_mmio_cmd_cache      (lsAsfty_ibp_mmio_cmd_cache)
  , .sfty_ibp_mmio_cmd_burst_size      (lsAsfty_ibp_mmio_cmd_burst_size)
  , .sfty_ibp_mmio_cmd_read      (lsAsfty_ibp_mmio_cmd_read)
  , .sfty_ibp_mmio_cmd_aux      (lsAsfty_ibp_mmio_cmd_aux)
  , .sfty_ibp_mmio_cmd_accept      (lsAsfty_ibp_mmio_cmd_accept)
  , .sfty_ibp_mmio_cmd_addr      (lsAsfty_ibp_mmio_cmd_addr)
  , .sfty_ibp_mmio_cmd_excl      (lsAsfty_ibp_mmio_cmd_excl)
  , .sfty_ibp_mmio_cmd_atomic      (lsAsfty_ibp_mmio_cmd_atomic)
  , .sfty_ibp_mmio_cmd_data_size      (lsAsfty_ibp_mmio_cmd_data_size)
  , .sfty_ibp_mmio_cmd_prot      (lsAsfty_ibp_mmio_cmd_prot)
  , .sfty_ibp_mmio_wr_valid      (lsAsfty_ibp_mmio_wr_valid)
  , .sfty_ibp_mmio_wr_last      (lsAsfty_ibp_mmio_wr_last)
  , .sfty_ibp_mmio_wr_accept      (lsAsfty_ibp_mmio_wr_accept)
  , .sfty_ibp_mmio_wr_mask      (lsAsfty_ibp_mmio_wr_mask)
  , .sfty_ibp_mmio_wr_data      (lsAsfty_ibp_mmio_wr_data)
  , .sfty_ibp_mmio_rd_valid      (lsAsfty_ibp_mmio_rd_valid)
  , .sfty_ibp_mmio_rd_err      (lsAsfty_ibp_mmio_rd_err)
  , .sfty_ibp_mmio_rd_excl_ok      (lsAsfty_ibp_mmio_rd_excl_ok)
  , .sfty_ibp_mmio_rd_last      (lsAsfty_ibp_mmio_rd_last)
  , .sfty_ibp_mmio_rd_accept      (lsAsfty_ibp_mmio_rd_accept)
  , .sfty_ibp_mmio_rd_data      (lsAsfty_ibp_mmio_rd_data)
  , .sfty_ibp_mmio_wr_done      (lsAsfty_ibp_mmio_wr_done)
  , .sfty_ibp_mmio_wr_excl_okay      (lsAsfty_ibp_mmio_wr_excl_okay)
  , .sfty_ibp_mmio_wr_err      (lsAsfty_ibp_mmio_wr_err)
  , .sfty_ibp_mmio_wr_resp_accept      (lsAsfty_ibp_mmio_wr_resp_accept)
  , .sfty_ibp_mmio_cmd_valid_pty      (lsAsfty_ibp_mmio_cmd_valid_pty)
  , .sfty_ibp_mmio_cmd_accept_pty      (lsAsfty_ibp_mmio_cmd_accept_pty)
  , .sfty_ibp_mmio_cmd_addr_pty      (lsAsfty_ibp_mmio_cmd_addr_pty)
  , .sfty_ibp_mmio_cmd_ctrl_pty      (lsAsfty_ibp_mmio_cmd_ctrl_pty)
  , .sfty_ibp_mmio_wr_valid_pty      (lsAsfty_ibp_mmio_wr_valid_pty)
  , .sfty_ibp_mmio_wr_accept_pty      (lsAsfty_ibp_mmio_wr_accept_pty)
  , .sfty_ibp_mmio_wr_last_pty      (lsAsfty_ibp_mmio_wr_last_pty)
  , .sfty_ibp_mmio_rd_valid_pty      (lsAsfty_ibp_mmio_rd_valid_pty)
  , .sfty_ibp_mmio_rd_accept_pty      (lsAsfty_ibp_mmio_rd_accept_pty)
  , .sfty_ibp_mmio_rd_ctrl_pty      (lsAsfty_ibp_mmio_rd_ctrl_pty)
  , .sfty_ibp_mmio_rd_data_pty      (lsAsfty_ibp_mmio_rd_data_pty)
  , .sfty_ibp_mmio_wr_done_pty      (lsAsfty_ibp_mmio_wr_done_pty)
  , .sfty_ibp_mmio_wr_ctrl_pty      (lsAsfty_ibp_mmio_wr_ctrl_pty)
  , .sfty_ibp_mmio_wr_resp_accept_pty      (lsAsfty_ibp_mmio_wr_resp_accept_pty)
  , .sfty_ibp_mmio_ini_e2e_err      (lsAsfty_ibp_mmio_ini_e2e_err)
  , .wdt_reset0      (lsAwdt_reset0)
  , .reg_wr_en0      (lsAreg_wr_en0)
  , .wdt_clk_enable_sync      (lsAwdt_clk_enable_sync)
  , .wdt_feedback_bit      (lsAwdt_feedback_bit)
  , .dmsi_valid      (lsAdmsi_valid)
  , .dmsi_context      (lsAdmsi_context)
  , .dmsi_eiid      (lsAdmsi_eiid)
  , .dmsi_domain      (lsAdmsi_domain)
  , .dmsi_rdy      (lsAdmsi_rdy)
  , .dmsi_valid_chk      (lsAdmsi_valid_chk)
  , .dmsi_data_edc      (lsAdmsi_data_edc)
  , .dmsi_rdy_chk      (lsAdmsi_rdy_chk)
  , .sfty_dmsi_tgt_e2e_err      (lsAsfty_dmsi_tgt_e2e_err)
  , .dbg_ibp_cmd_valid      (lsAdbg_ibp_cmd_valid)
  , .dbg_ibp_cmd_read      (lsAdbg_ibp_cmd_read)
  , .dbg_ibp_cmd_addr      (lsAdbg_ibp_cmd_addr)
  , .dbg_ibp_cmd_accept      (lsAdbg_ibp_cmd_accept)
  , .dbg_ibp_cmd_space      (lsAdbg_ibp_cmd_space)
  , .dbg_ibp_rd_valid      (lsAdbg_ibp_rd_valid)
  , .dbg_ibp_rd_accept      (lsAdbg_ibp_rd_accept)
  , .dbg_ibp_rd_err      (lsAdbg_ibp_rd_err)
  , .dbg_ibp_rd_data      (lsAdbg_ibp_rd_data)
  , .dbg_ibp_wr_valid      (lsAdbg_ibp_wr_valid)
  , .dbg_ibp_wr_accept      (lsAdbg_ibp_wr_accept)
  , .dbg_ibp_wr_data      (lsAdbg_ibp_wr_data)
  , .dbg_ibp_wr_mask      (lsAdbg_ibp_wr_mask)
  , .dbg_ibp_wr_done      (lsAdbg_ibp_wr_done)
  , .dbg_ibp_wr_err      (lsAdbg_ibp_wr_err)
  , .dbg_ibp_wr_resp_accept      (lsAdbg_ibp_wr_resp_accept)
  , .wid_rlwid      (lsAwid_rlwid)
  , .wid_rwiddeleg      (lsAwid_rwiddeleg)
  , .soft_reset_prepare_synch_r      (lsAsoft_reset_prepare_synch_r)
  , .soft_reset_req_synch_r      (lsAsoft_reset_req_synch_r)
  , .soft_reset_ready      (lsAsoft_reset_ready)
  , .soft_reset_ack      (lsAsoft_reset_ack)
  , .cpu_in_reset_state      (lsAcpu_in_reset_state)
  , .rst_init_disable_synch_r      (lsArst_init_disable_synch_r)
  , .iccm0_gclk_cnt      (lsAiccm0_gclk_cnt)
  , .dccm_even_gclk_cnt      (lsAdccm_even_gclk_cnt)
  , .dccm_odd_gclk_cnt      (lsAdccm_odd_gclk_cnt)
  , .ic_tag_mem_gclk_cnt      (lsAic_tag_mem_gclk_cnt)
  , .ic_data_mem_gclk_cnt      (lsAic_data_mem_gclk_cnt)
  , .gclk_cnt      (lsAgclk_cnt)
  , .arcnum      (lsAarcnum)
  , .sys_halt_r      (lsAsys_halt_r)
  , .sys_sleep_r      (lsAsys_sleep_r)
  , .critical_error      (lsAcritical_error)
  , .sys_sleep_mode_r      (lsAsys_sleep_mode_r)
    );

/////////////////////////////////////////////////////////////////////
// Shadow module for rl_cpu_top
/////////////////////////////////////////////////////////////////////
rl_cpu_top u_shadow_rl_cpu_top(
    .clk      (lsBclk)
  , .tm_clk_enable_sync      (lsBtm_clk_enable_sync)
  , .rst_synch_r      (lsBrst_synch_r)
  , .rst_cpu_req_synch_r      (lsBrst_cpu_req_synch_r)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .rst_cpu_ack      (lsBrst_cpu_ack)
// spyglass enable_block UnloadedOutTerm-ML
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .cpu_rst_gated      (lsBcpu_rst_gated)
// spyglass enable_block UnloadedOutTerm-ML
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .cpu_clk_gated      (lsBcpu_clk_gated)
// spyglass enable_block UnloadedOutTerm-ML
  , .test_mode      (lsBtest_mode)
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ: No need to register testmode signal LBIST_EN
  , .LBIST_EN      (lsBLBIST_EN)
// spyglass enable_block RegInputOutput-ML
  , .dm2arc_halt_req_synch_r      (lsBdm2arc_halt_req_synch_r)
  , .dm2arc_run_req_synch_r      (lsBdm2arc_run_req_synch_r)
  , .arc2dm_halt_ack      (lsBarc2dm_halt_ack)
  , .arc2dm_run_ack      (lsBarc2dm_run_ack)
  , .dm2arc_hartreset_synch_r      (lsBdm2arc_hartreset_synch_r)
  , .dm2arc_hartreset2_synch_r      (lsBdm2arc_hartreset2_synch_r)
  , .ndmreset_synch_r      (lsBndmreset_synch_r)
  , .dm2arc_havereset_ack_synch_r      (lsBdm2arc_havereset_ack_synch_r)
  , .dm2arc_halt_on_reset_synch_r      (lsBdm2arc_halt_on_reset_synch_r)
  , .arc2dm_havereset_a      (lsBarc2dm_havereset_a)
  , .dm2arc_relaxedpriv_synch_r      (lsBdm2arc_relaxedpriv_synch_r)
  , .hart_unavailable      (lsBhart_unavailable)
  , .ahb_hmastlock      (lsBahb_hmastlock)
  , .ahb_hexcl      (lsBahb_hexcl)
  , .ahb_hmaster      (lsBahb_hmaster)
  , .ahb_hauser      (lsBahb_hauser)
  , .ahb_hwrite      (lsBahb_hwrite)
  , .ahb_haddr      (lsBahb_haddr)
  , .ahb_htrans      (lsBahb_htrans)
  , .ahb_hsize      (lsBahb_hsize)
  , .ahb_hburst      (lsBahb_hburst)
  , .ahb_hwstrb      (lsBahb_hwstrb)
  , .ahb_hprot      (lsBahb_hprot)
  , .ahb_hnonsec      (lsBahb_hnonsec)
  , .ahb_hready      (lsBahb_hready)
  , .ahb_hresp      (lsBahb_hresp)
  , .ahb_hexokay      (lsBahb_hexokay)
  , .ahb_hrdata      (lsBahb_hrdata)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .ahb_hwdata      (lsBahb_hwdata)
// spyglass enable_block UnloadedOutTerm-ML
  , .ahb_hauserchk      (lsBahb_hauserchk)
  , .ahb_haddrchk      (lsBahb_haddrchk)
  , .ahb_htranschk      (lsBahb_htranschk)
  , .ahb_hctrlchk1      (lsBahb_hctrlchk1)
  , .ahb_hctrlchk2      (lsBahb_hctrlchk2)
  , .ahb_hprotchk      (lsBahb_hprotchk)
  , .ahb_hwstrbchk      (lsBahb_hwstrbchk)
  , .ahb_hreadychk      (lsBahb_hreadychk)
  , .ahb_hrespchk      (lsBahb_hrespchk)
  , .ahb_hrdatachk      (lsBahb_hrdatachk)
  , .ahb_hwdatachk      (lsBahb_hwdatachk)
  , .ahb_fatal_err      (lsBahb_fatal_err)
  , .dbu_per_ahb_hmastlock      (lsBdbu_per_ahb_hmastlock)
  , .dbu_per_ahb_hexcl      (lsBdbu_per_ahb_hexcl)
  , .dbu_per_ahb_hmaster      (lsBdbu_per_ahb_hmaster)
  , .dbu_per_ahb_hauser      (lsBdbu_per_ahb_hauser)
  , .dbu_per_ahb_hwrite      (lsBdbu_per_ahb_hwrite)
  , .dbu_per_ahb_haddr      (lsBdbu_per_ahb_haddr)
  , .dbu_per_ahb_htrans      (lsBdbu_per_ahb_htrans)
  , .dbu_per_ahb_hsize      (lsBdbu_per_ahb_hsize)
  , .dbu_per_ahb_hburst      (lsBdbu_per_ahb_hburst)
  , .dbu_per_ahb_hwstrb      (lsBdbu_per_ahb_hwstrb)
  , .dbu_per_ahb_hprot      (lsBdbu_per_ahb_hprot)
  , .dbu_per_ahb_hnonsec      (lsBdbu_per_ahb_hnonsec)
  , .dbu_per_ahb_hready      (lsBdbu_per_ahb_hready)
  , .dbu_per_ahb_hresp      (lsBdbu_per_ahb_hresp)
  , .dbu_per_ahb_hexokay      (lsBdbu_per_ahb_hexokay)
  , .dbu_per_ahb_hrdata      (lsBdbu_per_ahb_hrdata)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbu_per_ahb_hwdata      (lsBdbu_per_ahb_hwdata)
// spyglass enable_block UnloadedOutTerm-ML
  , .dbu_per_ahb_hauserchk      (lsBdbu_per_ahb_hauserchk)
  , .dbu_per_ahb_haddrchk      (lsBdbu_per_ahb_haddrchk)
  , .dbu_per_ahb_htranschk      (lsBdbu_per_ahb_htranschk)
  , .dbu_per_ahb_hctrlchk1      (lsBdbu_per_ahb_hctrlchk1)
  , .dbu_per_ahb_hctrlchk2      (lsBdbu_per_ahb_hctrlchk2)
  , .dbu_per_ahb_hprotchk      (lsBdbu_per_ahb_hprotchk)
  , .dbu_per_ahb_hwstrbchk      (lsBdbu_per_ahb_hwstrbchk)
  , .dbu_per_ahb_hreadychk      (lsBdbu_per_ahb_hreadychk)
  , .dbu_per_ahb_hrespchk      (lsBdbu_per_ahb_hrespchk)
  , .dbu_per_ahb_hrdatachk      (lsBdbu_per_ahb_hrdatachk)
  , .dbu_per_ahb_hwdatachk      (lsBdbu_per_ahb_hwdatachk)
  , .dbu_per_ahb_fatal_err      (lsBdbu_per_ahb_fatal_err)
  , .iccm_ahb_prio      (lsBiccm_ahb_prio)
  , .iccm_ahb_hmastlock      (lsBiccm_ahb_hmastlock)
  , .iccm_ahb_hexcl      (lsBiccm_ahb_hexcl)
  , .iccm_ahb_hmaster      (lsBiccm_ahb_hmaster)
  , .iccm_ahb_hsel      (lsBiccm_ahb_hsel)
  , .iccm_ahb_htrans      (lsBiccm_ahb_htrans)
  , .iccm_ahb_hwrite      (lsBiccm_ahb_hwrite)
  , .iccm_ahb_haddr      (lsBiccm_ahb_haddr)
  , .iccm_ahb_hsize      (lsBiccm_ahb_hsize)
  , .iccm_ahb_hwstrb      (lsBiccm_ahb_hwstrb)
  , .iccm_ahb_hburst      (lsBiccm_ahb_hburst)
  , .iccm_ahb_hprot      (lsBiccm_ahb_hprot)
  , .iccm_ahb_hnonsec      (lsBiccm_ahb_hnonsec)
  , .iccm_ahb_hwdata      (lsBiccm_ahb_hwdata)
  , .iccm_ahb_hready      (lsBiccm_ahb_hready)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .iccm_ahb_hrdata      (lsBiccm_ahb_hrdata)
// spyglass enable_block UnloadedOutTerm-ML
  , .iccm_ahb_hresp      (lsBiccm_ahb_hresp)
  , .iccm_ahb_hexokay      (lsBiccm_ahb_hexokay)
  , .iccm_ahb_hreadyout      (lsBiccm_ahb_hreadyout)
  , .iccm_ahb_haddrchk      (lsBiccm_ahb_haddrchk)
  , .iccm_ahb_htranschk      (lsBiccm_ahb_htranschk)
  , .iccm_ahb_hctrlchk1      (lsBiccm_ahb_hctrlchk1)
  , .iccm_ahb_hctrlchk2      (lsBiccm_ahb_hctrlchk2)
  , .iccm_ahb_hwstrbchk      (lsBiccm_ahb_hwstrbchk)
  , .iccm_ahb_hprotchk      (lsBiccm_ahb_hprotchk)
  , .iccm_ahb_hreadychk      (lsBiccm_ahb_hreadychk)
  , .iccm_ahb_hrespchk      (lsBiccm_ahb_hrespchk)
  , .iccm_ahb_hreadyoutchk      (lsBiccm_ahb_hreadyoutchk)
  , .iccm_ahb_hselchk      (lsBiccm_ahb_hselchk)
  , .iccm_ahb_hrdatachk      (lsBiccm_ahb_hrdatachk)
  , .iccm_ahb_hwdatachk      (lsBiccm_ahb_hwdatachk)
  , .iccm_ahb_fatal_err      (lsBiccm_ahb_fatal_err)
  , .dccm_ahb_prio      (lsBdccm_ahb_prio)
  , .dccm_ahb_hmastlock      (lsBdccm_ahb_hmastlock)
  , .dccm_ahb_hexcl      (lsBdccm_ahb_hexcl)
  , .dccm_ahb_hmaster      (lsBdccm_ahb_hmaster)
  , .dccm_ahb_hsel      (lsBdccm_ahb_hsel)
  , .dccm_ahb_htrans      (lsBdccm_ahb_htrans)
  , .dccm_ahb_hwrite      (lsBdccm_ahb_hwrite)
  , .dccm_ahb_haddr      (lsBdccm_ahb_haddr)
  , .dccm_ahb_hsize      (lsBdccm_ahb_hsize)
  , .dccm_ahb_hwstrb      (lsBdccm_ahb_hwstrb)
  , .dccm_ahb_hnonsec      (lsBdccm_ahb_hnonsec)
  , .dccm_ahb_hburst      (lsBdccm_ahb_hburst)
  , .dccm_ahb_hprot      (lsBdccm_ahb_hprot)
  , .dccm_ahb_hwdata      (lsBdccm_ahb_hwdata)
  , .dccm_ahb_hready      (lsBdccm_ahb_hready)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dccm_ahb_hrdata      (lsBdccm_ahb_hrdata)
// spyglass enable_block UnloadedOutTerm-ML
  , .dccm_ahb_hresp      (lsBdccm_ahb_hresp)
  , .dccm_ahb_hexokay      (lsBdccm_ahb_hexokay)
  , .dccm_ahb_hreadyout      (lsBdccm_ahb_hreadyout)
  , .dccm_ahb_haddrchk      (lsBdccm_ahb_haddrchk)
  , .dccm_ahb_htranschk      (lsBdccm_ahb_htranschk)
  , .dccm_ahb_hctrlchk1      (lsBdccm_ahb_hctrlchk1)
  , .dccm_ahb_hctrlchk2      (lsBdccm_ahb_hctrlchk2)
  , .dccm_ahb_hwstrbchk      (lsBdccm_ahb_hwstrbchk)
  , .dccm_ahb_hprotchk      (lsBdccm_ahb_hprotchk)
  , .dccm_ahb_hreadychk      (lsBdccm_ahb_hreadychk)
  , .dccm_ahb_hrespchk      (lsBdccm_ahb_hrespchk)
  , .dccm_ahb_hreadyoutchk      (lsBdccm_ahb_hreadyoutchk)
  , .dccm_ahb_hselchk      (lsBdccm_ahb_hselchk)
  , .dccm_ahb_hrdatachk      (lsBdccm_ahb_hrdatachk)
  , .dccm_ahb_hwdatachk      (lsBdccm_ahb_hwdatachk)
  , .dccm_ahb_fatal_err      (lsBdccm_ahb_fatal_err)
  , .mmio_ahb_prio      (lsBmmio_ahb_prio)
  , .mmio_ahb_hmastlock      (lsBmmio_ahb_hmastlock)
  , .mmio_ahb_hexcl      (lsBmmio_ahb_hexcl)
  , .mmio_ahb_hmaster      (lsBmmio_ahb_hmaster)
  , .mmio_ahb_hsel      (lsBmmio_ahb_hsel)
  , .mmio_ahb_htrans      (lsBmmio_ahb_htrans)
  , .mmio_ahb_hwrite      (lsBmmio_ahb_hwrite)
  , .mmio_ahb_haddr      (lsBmmio_ahb_haddr)
  , .mmio_ahb_hsize      (lsBmmio_ahb_hsize)
  , .mmio_ahb_hwstrb      (lsBmmio_ahb_hwstrb)
  , .mmio_ahb_hnonsec      (lsBmmio_ahb_hnonsec)
  , .mmio_ahb_hburst      (lsBmmio_ahb_hburst)
  , .mmio_ahb_hprot      (lsBmmio_ahb_hprot)
  , .mmio_ahb_hwdata      (lsBmmio_ahb_hwdata)
  , .mmio_ahb_hready      (lsBmmio_ahb_hready)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .mmio_ahb_hrdata      (lsBmmio_ahb_hrdata)
// spyglass enable_block UnloadedOutTerm-ML
  , .mmio_ahb_hresp      (lsBmmio_ahb_hresp)
  , .mmio_ahb_hexokay      (lsBmmio_ahb_hexokay)
  , .mmio_ahb_hreadyout      (lsBmmio_ahb_hreadyout)
  , .mmio_ahb_haddrchk      (lsBmmio_ahb_haddrchk)
  , .mmio_ahb_htranschk      (lsBmmio_ahb_htranschk)
  , .mmio_ahb_hctrlchk1      (lsBmmio_ahb_hctrlchk1)
  , .mmio_ahb_hctrlchk2      (lsBmmio_ahb_hctrlchk2)
  , .mmio_ahb_hwstrbchk      (lsBmmio_ahb_hwstrbchk)
  , .mmio_ahb_hprotchk      (lsBmmio_ahb_hprotchk)
  , .mmio_ahb_hreadychk      (lsBmmio_ahb_hreadychk)
  , .mmio_ahb_hrespchk      (lsBmmio_ahb_hrespchk)
  , .mmio_ahb_hreadyoutchk      (lsBmmio_ahb_hreadyoutchk)
  , .mmio_ahb_hselchk      (lsBmmio_ahb_hselchk)
  , .mmio_ahb_hrdatachk      (lsBmmio_ahb_hrdatachk)
  , .mmio_ahb_hwdatachk      (lsBmmio_ahb_hwdatachk)
  , .mmio_ahb_fatal_err      (lsBmmio_ahb_fatal_err)
  , .mmio_base_in      (lsBmmio_base_in)
  , .reset_pc_in      (lsBreset_pc_in)
  , .rnmi_synch_r      (lsBrnmi_synch_r)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .esrams_iccm0_clk      (lsBesrams_iccm0_clk)
// spyglass enable_block UnloadedOutTerm-ML
  , .esrams_iccm0_din      (lsBesrams_iccm0_din)
  , .esrams_iccm0_addr      (lsBesrams_iccm0_addr)
  , .esrams_iccm0_cs      (lsBesrams_iccm0_cs)
  , .esrams_iccm0_we      (lsBesrams_iccm0_we)
  , .esrams_iccm0_wem      (lsBesrams_iccm0_wem)
  , .esrams_iccm0_dout      (lsBesrams_iccm0_dout)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .esrams_dccm_even_clk      (lsBesrams_dccm_even_clk)
// spyglass enable_block UnloadedOutTerm-ML
  , .esrams_dccm_din_even      (lsBesrams_dccm_din_even)
  , .esrams_dccm_addr_even      (lsBesrams_dccm_addr_even)
  , .esrams_dccm_cs_even      (lsBesrams_dccm_cs_even)
  , .esrams_dccm_we_even      (lsBesrams_dccm_we_even)
  , .esrams_dccm_wem_even      (lsBesrams_dccm_wem_even)
  , .esrams_dccm_dout_even      (lsBesrams_dccm_dout_even)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .esrams_dccm_odd_clk      (lsBesrams_dccm_odd_clk)
// spyglass enable_block UnloadedOutTerm-ML
  , .esrams_dccm_din_odd      (lsBesrams_dccm_din_odd)
  , .esrams_dccm_addr_odd      (lsBesrams_dccm_addr_odd)
  , .esrams_dccm_cs_odd      (lsBesrams_dccm_cs_odd)
  , .esrams_dccm_we_odd      (lsBesrams_dccm_we_odd)
  , .esrams_dccm_wem_odd      (lsBesrams_dccm_wem_odd)
  , .esrams_dccm_dout_odd      (lsBesrams_dccm_dout_odd)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .esrams_ic_tag_mem_clk      (lsBesrams_ic_tag_mem_clk)
// spyglass enable_block UnloadedOutTerm-ML
  , .esrams_ic_tag_mem_din      (lsBesrams_ic_tag_mem_din)
  , .esrams_ic_tag_mem_addr      (lsBesrams_ic_tag_mem_addr)
  , .esrams_ic_tag_mem_cs      (lsBesrams_ic_tag_mem_cs)
  , .esrams_ic_tag_mem_we      (lsBesrams_ic_tag_mem_we)
  , .esrams_ic_tag_mem_wem      (lsBesrams_ic_tag_mem_wem)
  , .esrams_ic_tag_mem_dout      (lsBesrams_ic_tag_mem_dout)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .esrams_ic_data_mem_clk      (lsBesrams_ic_data_mem_clk)
// spyglass enable_block UnloadedOutTerm-ML
  , .esrams_ic_data_mem_din      (lsBesrams_ic_data_mem_din)
  , .esrams_ic_data_mem_addr      (lsBesrams_ic_data_mem_addr)
  , .esrams_ic_data_mem_cs      (lsBesrams_ic_data_mem_cs)
  , .esrams_ic_data_mem_we      (lsBesrams_ic_data_mem_we)
  , .esrams_ic_data_mem_wem      (lsBesrams_ic_data_mem_wem)
  , .esrams_ic_data_mem_dout      (lsBesrams_ic_data_mem_dout)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .esrams_clk      (lsBesrams_clk)
// spyglass enable_block UnloadedOutTerm-ML
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .esrams_ls      (lsBesrams_ls)
// spyglass enable_block UnloadedOutTerm-ML
  , .ext_trig_output_accept      (lsBext_trig_output_accept)
  , .ext_trig_in      (lsBext_trig_in)
  , .ext_trig_output_valid      (lsBext_trig_output_valid)
  , .high_prio_ras      (lsBhigh_prio_ras)
  , .safety_comparator_enable      (lsBsafety_comparator_enable)
  , .lsc_diag_aux_r      (lsBlsc_diag_aux_r)
  , .dr_lsc_stl_ctrl_aux_r      (lsBdr_lsc_stl_ctrl_aux_r)
  , .lsc_shd_ctrl_aux_r      (lsBlsc_shd_ctrl_aux_r)
  , .dr_sfty_aux_parity_err_r      (lsBdr_sfty_aux_parity_err_r)
  , .dr_bus_fatal_err      (lsBdr_bus_fatal_err)
  , .dr_safety_comparator_enabled      (lsBdr_safety_comparator_enabled)
  , .safety_iso_enb_synch_r      (lsBsafety_iso_enb_synch_r)
  , .sfty_nsi_r      (lsBsfty_nsi_r)
  , .lsc_err_stat_aux      (lsBlsc_err_stat_aux)
  , .dr_sfty_eic      (lsBdr_sfty_eic)
  , .dr_safety_iso_err      (lsBdr_safety_iso_err)
  , .dr_secure_trig_iso_err      (lsBdr_secure_trig_iso_err)
  , .sfty_mem_sbe_err      (lsBsfty_mem_sbe_err)
  , .sfty_mem_dbe_err      (lsBsfty_mem_dbe_err)
  , .sfty_mem_adr_err      (lsBsfty_mem_adr_err)
  , .sfty_mem_sbe_overflow      (lsBsfty_mem_sbe_overflow)
  , .sfty_ibp_mmio_cmd_valid      (lsBsfty_ibp_mmio_cmd_valid)
  , .sfty_ibp_mmio_cmd_cache      (lsBsfty_ibp_mmio_cmd_cache)
  , .sfty_ibp_mmio_cmd_burst_size      (lsBsfty_ibp_mmio_cmd_burst_size)
  , .sfty_ibp_mmio_cmd_read      (lsBsfty_ibp_mmio_cmd_read)
  , .sfty_ibp_mmio_cmd_aux      (lsBsfty_ibp_mmio_cmd_aux)
  , .sfty_ibp_mmio_cmd_accept      (lsBsfty_ibp_mmio_cmd_accept)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .sfty_ibp_mmio_cmd_addr      (lsBsfty_ibp_mmio_cmd_addr)
// spyglass enable_block UnloadedOutTerm-ML
  , .sfty_ibp_mmio_cmd_excl      (lsBsfty_ibp_mmio_cmd_excl)
  , .sfty_ibp_mmio_cmd_atomic      (lsBsfty_ibp_mmio_cmd_atomic)
  , .sfty_ibp_mmio_cmd_data_size      (lsBsfty_ibp_mmio_cmd_data_size)
  , .sfty_ibp_mmio_cmd_prot      (lsBsfty_ibp_mmio_cmd_prot)
  , .sfty_ibp_mmio_wr_valid      (lsBsfty_ibp_mmio_wr_valid)
  , .sfty_ibp_mmio_wr_last      (lsBsfty_ibp_mmio_wr_last)
  , .sfty_ibp_mmio_wr_accept      (lsBsfty_ibp_mmio_wr_accept)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .sfty_ibp_mmio_wr_mask      (lsBsfty_ibp_mmio_wr_mask)
// spyglass enable_block UnloadedOutTerm-ML
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .sfty_ibp_mmio_wr_data      (lsBsfty_ibp_mmio_wr_data)
// spyglass enable_block UnloadedOutTerm-ML
  , .sfty_ibp_mmio_rd_valid      (lsBsfty_ibp_mmio_rd_valid)
  , .sfty_ibp_mmio_rd_err      (lsBsfty_ibp_mmio_rd_err)
  , .sfty_ibp_mmio_rd_excl_ok      (lsBsfty_ibp_mmio_rd_excl_ok)
  , .sfty_ibp_mmio_rd_last      (lsBsfty_ibp_mmio_rd_last)
  , .sfty_ibp_mmio_rd_accept      (lsBsfty_ibp_mmio_rd_accept)
  , .sfty_ibp_mmio_rd_data      (lsBsfty_ibp_mmio_rd_data)
  , .sfty_ibp_mmio_wr_done      (lsBsfty_ibp_mmio_wr_done)
  , .sfty_ibp_mmio_wr_excl_okay      (lsBsfty_ibp_mmio_wr_excl_okay)
  , .sfty_ibp_mmio_wr_err      (lsBsfty_ibp_mmio_wr_err)
  , .sfty_ibp_mmio_wr_resp_accept      (lsBsfty_ibp_mmio_wr_resp_accept)
  , .sfty_ibp_mmio_cmd_valid_pty      (lsBsfty_ibp_mmio_cmd_valid_pty)
  , .sfty_ibp_mmio_cmd_accept_pty      (lsBsfty_ibp_mmio_cmd_accept_pty)
  , .sfty_ibp_mmio_cmd_addr_pty      (lsBsfty_ibp_mmio_cmd_addr_pty)
  , .sfty_ibp_mmio_cmd_ctrl_pty      (lsBsfty_ibp_mmio_cmd_ctrl_pty)
  , .sfty_ibp_mmio_wr_valid_pty      (lsBsfty_ibp_mmio_wr_valid_pty)
  , .sfty_ibp_mmio_wr_accept_pty      (lsBsfty_ibp_mmio_wr_accept_pty)
  , .sfty_ibp_mmio_wr_last_pty      (lsBsfty_ibp_mmio_wr_last_pty)
  , .sfty_ibp_mmio_rd_valid_pty      (lsBsfty_ibp_mmio_rd_valid_pty)
  , .sfty_ibp_mmio_rd_accept_pty      (lsBsfty_ibp_mmio_rd_accept_pty)
  , .sfty_ibp_mmio_rd_ctrl_pty      (lsBsfty_ibp_mmio_rd_ctrl_pty)
  , .sfty_ibp_mmio_rd_data_pty      (lsBsfty_ibp_mmio_rd_data_pty)
  , .sfty_ibp_mmio_wr_done_pty      (lsBsfty_ibp_mmio_wr_done_pty)
  , .sfty_ibp_mmio_wr_ctrl_pty      (lsBsfty_ibp_mmio_wr_ctrl_pty)
  , .sfty_ibp_mmio_wr_resp_accept_pty      (lsBsfty_ibp_mmio_wr_resp_accept_pty)
  , .sfty_ibp_mmio_ini_e2e_err      (lsBsfty_ibp_mmio_ini_e2e_err)
  , .wdt_reset0      (lsBwdt_reset0)
  , .reg_wr_en0      (lsBreg_wr_en0)
  , .wdt_clk_enable_sync      (lsBwdt_clk_enable_sync)
  , .wdt_feedback_bit      (lsBwdt_feedback_bit)
  , .dmsi_valid      (lsBdmsi_valid)
  , .dmsi_context      (lsBdmsi_context)
  , .dmsi_eiid      (lsBdmsi_eiid)
  , .dmsi_domain      (lsBdmsi_domain)
  , .dmsi_rdy      (lsBdmsi_rdy)
  , .dmsi_valid_chk      (lsBdmsi_valid_chk)
  , .dmsi_data_edc      (lsBdmsi_data_edc)
  , .dmsi_rdy_chk      (lsBdmsi_rdy_chk)
  , .sfty_dmsi_tgt_e2e_err      (lsBsfty_dmsi_tgt_e2e_err)
  , .dbg_ibp_cmd_valid      (lsBdbg_ibp_cmd_valid)
  , .dbg_ibp_cmd_read      (lsBdbg_ibp_cmd_read)
  , .dbg_ibp_cmd_addr      (lsBdbg_ibp_cmd_addr)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbg_ibp_cmd_accept      (lsBdbg_ibp_cmd_accept)
// spyglass enable_block UnloadedOutTerm-ML
  , .dbg_ibp_cmd_space      (lsBdbg_ibp_cmd_space)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbg_ibp_rd_valid      (lsBdbg_ibp_rd_valid)
// spyglass enable_block UnloadedOutTerm-ML
  , .dbg_ibp_rd_accept      (lsBdbg_ibp_rd_accept)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbg_ibp_rd_err      (lsBdbg_ibp_rd_err)
// spyglass enable_block UnloadedOutTerm-ML
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbg_ibp_rd_data      (lsBdbg_ibp_rd_data)
// spyglass enable_block UnloadedOutTerm-ML
  , .dbg_ibp_wr_valid      (lsBdbg_ibp_wr_valid)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbg_ibp_wr_accept      (lsBdbg_ibp_wr_accept)
// spyglass enable_block UnloadedOutTerm-ML
  , .dbg_ibp_wr_data      (lsBdbg_ibp_wr_data)
  , .dbg_ibp_wr_mask      (lsBdbg_ibp_wr_mask)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbg_ibp_wr_done      (lsBdbg_ibp_wr_done)
// spyglass enable_block UnloadedOutTerm-ML
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .dbg_ibp_wr_err      (lsBdbg_ibp_wr_err)
// spyglass enable_block UnloadedOutTerm-ML
  , .dbg_ibp_wr_resp_accept      (lsBdbg_ibp_wr_resp_accept)
  , .wid_rlwid      (lsBwid_rlwid)
  , .wid_rwiddeleg      (lsBwid_rwiddeleg)
  , .soft_reset_prepare_synch_r      (lsBsoft_reset_prepare_synch_r)
  , .soft_reset_req_synch_r      (lsBsoft_reset_req_synch_r)
  , .soft_reset_ready      (lsBsoft_reset_ready)
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, shadow signal will not be loaded if it's exclude from comparison
  , .soft_reset_ack      (lsBsoft_reset_ack)
// spyglass enable_block UnloadedOutTerm-ML
  , .cpu_in_reset_state      (lsBcpu_in_reset_state)
  , .rst_init_disable_synch_r      (lsBrst_init_disable_synch_r)
  , .iccm0_gclk_cnt      (lsBiccm0_gclk_cnt)
  , .dccm_even_gclk_cnt      (lsBdccm_even_gclk_cnt)
  , .dccm_odd_gclk_cnt      (lsBdccm_odd_gclk_cnt)
  , .ic_tag_mem_gclk_cnt      (lsBic_tag_mem_gclk_cnt)
  , .ic_data_mem_gclk_cnt      (lsBic_data_mem_gclk_cnt)
  , .gclk_cnt      (lsBgclk_cnt)
  , .arcnum      (lsBarcnum)
  , .sys_halt_r      (lsBsys_halt_r)
  , .sys_sleep_r      (lsBsys_sleep_r)
  , .critical_error      (lsBcritical_error)
  , .sys_sleep_mode_r      (lsBsys_sleep_mode_r)
    );
assign cpu_dr_sfty_ctrl_parity_error = (cpu_sync_parity_error 
                             | cpu_synch_top_parity_error_r
                             )? 2'b10 : 2'b01;

endmodule
// PECSV 


