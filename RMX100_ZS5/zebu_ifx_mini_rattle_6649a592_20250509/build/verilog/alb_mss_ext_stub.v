// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
//
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2012, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//   alb_mss_ext_stub: External stub unit for driving unused inputs to 0
//
// ===========================================================================
//
// Description:
//  Verilog module stubbing the external signals on the board:
//  - interrupts
//  - other signals: bist, action points
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +o alb_mss_ext_stub.vpp
//
// ==========================================================================








module alb_mss_ext_stub(
// tie unused inputs
    output  iccm_ahb_prio,
    output  iccm_ahb_hmastlock,
    output  iccm_ahb_hexcl,
    output [3:0] iccm_ahb_hmaster,
    output [3:0] iccm_ahb_hwstrb,
    output [6:0] iccm_ahb_hprot,
    output  iccm_ahb_hnonsec,
    output  iccm_ahb_hselchk,
    output  dccm_ahb_prio,
    output  dccm_ahb_hmastlock,
    output  dccm_ahb_hexcl,
    output [3:0] dccm_ahb_hmaster,
    output [3:0] dccm_ahb_hwstrb,
    output [6:0] dccm_ahb_hprot,
    output  dccm_ahb_hnonsec,
    output  dccm_ahb_hselchk,
    output  mmio_ahb_prio,
    output  mmio_ahb_hmastlock,
    output  mmio_ahb_hexcl,
    output [3:0] mmio_ahb_hmaster,
    output [3:0] mmio_ahb_hwstrb,
    output [6:0] mmio_ahb_hprot,
    output  mmio_ahb_hnonsec,
    output  mmio_ahb_hselchk,
    output [11:0] mmio_base_in,
    output [21:0] reset_pc_in,
    output  LBIST_EN,
    output  rst_cpu_req_a,
    output  dmsi_valid,
    output  dmsi_valid_chk,
    output [5:0] dmsi_data_edc,
    output [0:0] dmsi_context,
    output [5:0] dmsi_eiid,
    output  dmsi_domain,
    output [1:0] ext_trig_output_accept,
    output [15:0] ext_trig_in,
    output  rst_init_disable_a,
    output  rnmi_a,
    output [4:0] wid_rlwid,
    output [63:0] wid_rwiddeleg,
    output  soft_reset_prepare_a,
    output  soft_reset_req_a,
    output  dbg_apb_presetn_early,
    output [1:0] dbg_unlock,
    output [1:0] safety_iso_enb,
// tie unused ioc port inputs
// stub unused ioc port outputs
// stub outputs
    input       iccm_ahb_hexokay,
    input       iccm_ahb_fatal_err,
    input       iccm_ahb_hrespchk,
    input       iccm_ahb_hreadyoutchk,
    input      [3:0] iccm_ahb_hrdatachk,
    input       dccm_ahb_hexokay,
    input       dccm_ahb_fatal_err,
    input       dccm_ahb_hrespchk,
    input       dccm_ahb_hreadyoutchk,
    input      [3:0] dccm_ahb_hrdatachk,
    input       mmio_ahb_hexokay,
    input       mmio_ahb_fatal_err,
    input       mmio_ahb_hrespchk,
    input       mmio_ahb_hreadyoutchk,
    input      [3:0] mmio_ahb_hrdatachk,
    input       dbu_per_ahb_hexcl,
    input       dbu_per_ahb_hmastlock,
    input      [3:0] dbu_per_ahb_hmaster,
    input      [7:0] dbu_per_ahb_hauser,
    input       dbu_per_ahb_hauserchk,
    input      [3:0] dbu_per_ahb_haddrchk,
    input       dbu_per_ahb_htranschk,
    input       dbu_per_ahb_hctrlchk1,
    input       dbu_per_ahb_hctrlchk2,
    input       dbu_per_ahb_hwstrbchk,
    input       dbu_per_ahb_hprotchk,
    input      [3:0] dbu_per_ahb_hwdatachk,
    input       dbu_per_ahb_fatal_err,
    input       high_prio_ras,
    input       ahb_hexcl,
    input       ahb_hmastlock,
    input      [3:0] ahb_hmaster,
    input      [7:0] ahb_hauser,
    input       ahb_hauserchk,
    input      [3:0] ahb_haddrchk,
    input       ahb_htranschk,
    input       ahb_hctrlchk1,
    input       ahb_hctrlchk2,
    input       ahb_hwstrbchk,
    input       ahb_hprotchk,
    input      [3:0] ahb_hwdatachk,
    input       ahb_fatal_err,
    input       wdt_reset0,
    input       wdt_reset_wdt_clk0,
    input       reg_wr_en0,
    input       critical_error,
    input      [1:0] ext_trig_output_valid,
    input       dmsi_rdy,
    input       dmsi_rdy_chk,
    input       soft_reset_ready,
    input       soft_reset_ack,
    input       rst_cpu_ack,
    input       cpu_in_reset_state,
    input      [1:0] safety_mem_dbe,
    input      [1:0] safety_mem_sbe,
    input      [1:0] safety_isol_change,
    input      [1:0] safety_error,
    input      [1:0] safety_enabled,

// hsk inputs outputs


    input       mss_clk,
    input       rst_a,
    output      alb_mss_ext_stub_dummy // dummy output for verilog syntax
);

assign alb_mss_ext_stub_dummy = 1'b0;


// tie unused inputs
assign iccm_ahb_prio = 0;
assign iccm_ahb_hmastlock = 0;
assign iccm_ahb_hexcl = 0;
assign iccm_ahb_hmaster = 0;
assign iccm_ahb_hwstrb = 4'b1111;
assign iccm_ahb_hprot = 0;
assign iccm_ahb_hnonsec = 0;
assign iccm_ahb_hselchk = 0;
assign dccm_ahb_prio = 0;
assign dccm_ahb_hmastlock = 0;
assign dccm_ahb_hexcl = 0;
assign dccm_ahb_hmaster = 0;
assign dccm_ahb_hwstrb = 4'b1111;
assign dccm_ahb_hprot = 0;
assign dccm_ahb_hnonsec = 0;
assign dccm_ahb_hselchk = 0;
assign mmio_ahb_prio = 0;
assign mmio_ahb_hmastlock = 0;
assign mmio_ahb_hexcl = 0;
assign mmio_ahb_hmaster = 0;
assign mmio_ahb_hwstrb = 4'b1111;
assign mmio_ahb_hprot = 0;
assign mmio_ahb_hnonsec = 0;
assign mmio_ahb_hselchk = 0;
assign mmio_base_in = 3584;
assign reset_pc_in = 0;
assign LBIST_EN = 0;
assign rst_cpu_req_a = 0;
assign dmsi_valid = 0;
assign dmsi_valid_chk = 1;
assign dmsi_data_edc = 0;
assign dmsi_context = 0;
assign dmsi_eiid = 0;
assign dmsi_domain = 0;
assign ext_trig_output_accept = 0;
assign ext_trig_in = 0;
assign rst_init_disable_a = 0;
assign rnmi_a = 0;
assign wid_rlwid = 0;
assign wid_rwiddeleg = 0;
assign soft_reset_prepare_a = 0;
assign soft_reset_req_a = 0;
assign dbg_apb_presetn_early = 1;
assign dbg_unlock = 2'b01;
assign safety_iso_enb = 2'b01;

// tie unused common inputs

// tie unused ioc port inputs






endmodule // alb_mss_ext_stub
