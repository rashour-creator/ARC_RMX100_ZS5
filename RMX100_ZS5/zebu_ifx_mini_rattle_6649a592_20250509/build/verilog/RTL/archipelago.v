// *SYNOPSYS CONFIDENTIAL*
// 
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file was automatically generated.
// Includes found in dependent files:
`include "defines.v"
`include "arcv_dm_defines.v"
`include "const.def"
`include "dw_dbp_defines.v"
`include "rv_safety_defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"

module archipelago(
    input  [1:0] safety_iso_enb          //  <   alb_mss_ext_stub
  , input  [1:0] dbg_unlock              //  <   alb_mss_ext_stub
  , input  arc_halt_req_a                //  <   io_pad_ring
  , input  arc_run_req_a                 //  <   io_pad_ring
  , input  test_mode                     //  <   io_pad_ring
  , input  clk                           //  <   alb_mss_clkctrl
  , input  rst_a                         //  <   io_pad_ring
  , input  jtag_tck                      //  <   io_pad_ring
  , input  jtag_trst_n                   //  <   io_pad_ring
  , input  jtag_tdi                      //  <   io_pad_ring
  , input  jtag_tms                      //  <   io_pad_ring
  , input  bri_awready                   //  <   alb_mss_fab
  , input  bri_wready                    //  <   alb_mss_fab
  , input  [3:0] bri_bid                 //  <   alb_mss_fab
  , input  [1:0] bri_bresp               //  <   alb_mss_fab
  , input  bri_bvalid                    //  <   alb_mss_fab
  , input  bri_arready                   //  <   alb_mss_fab
  , input  [3:0] bri_rid                 //  <   alb_mss_fab
  , input  [31:0] bri_rdata              //  <   alb_mss_fab
  , input  bri_rlast                     //  <   alb_mss_fab
  , input  bri_rvalid                    //  <   alb_mss_fab
  , input  [1:0] bri_rresp               //  <   alb_mss_fab
  , input  rst_cpu_req_a                 //  <   alb_mss_ext_stub
  , input  LBIST_EN                      //  <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  ahb_hready                    //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  ahb_hresp                     //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  ahb_hexokay                   //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] ahb_hrdata             //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  ahb_hreadychk                 //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  ahb_hrespchk                  //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] ahb_hrdatachk           //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dbu_per_ahb_hready            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dbu_per_ahb_hresp             //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dbu_per_ahb_hexokay           //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] dbu_per_ahb_hrdata     //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dbu_per_ahb_hreadychk         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dbu_per_ahb_hrespchk          //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] dbu_per_ahb_hrdatachk   //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , input  iccm_ahb_prio                 //  <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hmastlock            //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hexcl                //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] iccm_ahb_hmaster        //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [0:0] iccm_ahb_hsel           //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [1:0] iccm_ahb_htrans         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hwrite               //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] iccm_ahb_haddr         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [2:0] iccm_ahb_hsize          //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] iccm_ahb_hwstrb         //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [2:0] iccm_ahb_hburst         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [6:0] iccm_ahb_hprot          //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hnonsec              //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] iccm_ahb_hwdata        //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hready               //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] iccm_ahb_haddrchk       //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_htranschk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hctrlchk1            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hctrlchk2            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hwstrbchk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hprotchk             //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hreadychk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  iccm_ahb_hselchk              //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] iccm_ahb_hwdatachk      //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , input  dccm_ahb_prio                 //  <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hmastlock            //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hexcl                //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] dccm_ahb_hmaster        //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [0:0] dccm_ahb_hsel           //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [1:0] dccm_ahb_htrans         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hwrite               //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] dccm_ahb_haddr         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [2:0] dccm_ahb_hsize          //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] dccm_ahb_hwstrb         //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hnonsec              //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [2:0] dccm_ahb_hburst         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [6:0] dccm_ahb_hprot          //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] dccm_ahb_hwdata        //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hready               //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] dccm_ahb_haddrchk       //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_htranschk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hctrlchk1            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hctrlchk2            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hwstrbchk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hprotchk             //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hreadychk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  dccm_ahb_hselchk              //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] dccm_ahb_hwdatachk      //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , input  mmio_ahb_prio                 //  <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hmastlock            //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hexcl                //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] mmio_ahb_hmaster        //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hsel                 //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [1:0] mmio_ahb_htrans         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hwrite               //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] mmio_ahb_haddr         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [2:0] mmio_ahb_hsize          //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] mmio_ahb_hwstrb         //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hnonsec              //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [2:0] mmio_ahb_hburst         //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [6:0] mmio_ahb_hprot          //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [31:0] mmio_ahb_hwdata        //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hready               //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] mmio_ahb_haddrchk       //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_htranschk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hctrlchk1            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hctrlchk2            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hwstrbchk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hprotchk             //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hreadychk            //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  mmio_ahb_hselchk              //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , input  [3:0] mmio_ahb_hwdatachk      //  <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , input  [11:0] mmio_base_in           //  <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// SMD: direct connection from input port to output port
// SJ:  None-registered interface
  , input  [21:0] reset_pc_in            //  <   alb_mss_ext_stub
// spyglass enable_block Topology_02

  , input  rnmi_a                        //  <   alb_mss_ext_stub
  , input  [1:0] ext_trig_output_accept  //  <   alb_mss_ext_stub
  , input  [15:0] ext_trig_in            //  <   alb_mss_ext_stub
// spyglass disable_block Ac_glitch02
// SMD: Clock domain crossing may be subject to glitches
// SJ: CDC accross is handled
  , input  dmsi_valid                    //  <   alb_mss_ext_stub
// spyglass enable_block Ac_glitch02
  , input  [0:0] dmsi_context            //  <   alb_mss_ext_stub
  , input  [5:0] dmsi_eiid               //  <   alb_mss_ext_stub
  , input  dmsi_domain                   //  <   alb_mss_ext_stub
  , input  dmsi_valid_chk                //  <   alb_mss_ext_stub
  , input  [5:0] dmsi_data_edc           //  <   alb_mss_ext_stub
  , input  [4:0] wid_rlwid               //  <   alb_mss_ext_stub
  , input  [63:0] wid_rwiddeleg          //  <   alb_mss_ext_stub
  , input  soft_reset_prepare_a          //  <   alb_mss_ext_stub
  , input  soft_reset_req_a              //  <   alb_mss_ext_stub
  , input  rst_init_disable_a            //  <   alb_mss_ext_stub
  , input  [7:0] arcnum /* verilator public_flat */ //  <   io_pad_ring
  , input  ref_clk                       //  <   io_pad_ring
  , input  wdt_clk                       //  <   alb_mss_clkctrl
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [1:0] ahb_htrans              //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hwrite                    //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [31:0] ahb_haddr              //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [2:0] ahb_hsize               //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [2:0] ahb_hburst              //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [6:0] ahb_hprot               //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hnonsec                   //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hexcl                     //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] ahb_hmaster             //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [31:0] ahb_hwdata             //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] ahb_hwstrb              //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] ahb_haddrchk            //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_htranschk                 //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hctrlchk1                 //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hprotchk                  //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [1:0] dbu_per_ahb_htrans      //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hwrite            //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [31:0] dbu_per_ahb_haddr      //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [2:0] dbu_per_ahb_hsize       //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [2:0] dbu_per_ahb_hburst      //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [6:0] dbu_per_ahb_hprot       //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hnonsec           //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hexcl             //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] dbu_per_ahb_hmaster     //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [31:0] dbu_per_ahb_hwdata     //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] dbu_per_ahb_hwstrb      //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] dbu_per_ahb_haddrchk    //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_htranschk         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hctrlchk1         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hprotchk          //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , output [3:0] bri_arid                //    > alb_mss_fab
  , output bri_arvalid                   //    > alb_mss_fab
  , output [31:0] bri_araddr             //    > alb_mss_fab
  , output [1:0] bri_arburst             //    > alb_mss_fab
  , output [2:0] bri_arsize              //    > alb_mss_fab
  , output [3:0] bri_arlen               //    > alb_mss_fab
  , output [3:0] bri_arcache             //    > alb_mss_fab
  , output [2:0] bri_arprot              //    > alb_mss_fab
  , output bri_rready                    //    > alb_mss_fab
  , output [3:0] bri_awid                //    > alb_mss_fab
  , output bri_awvalid                   //    > alb_mss_fab
  , output [31:0] bri_awaddr             //    > alb_mss_fab
  , output [1:0] bri_awburst             //    > alb_mss_fab
  , output [2:0] bri_awsize              //    > alb_mss_fab
  , output [3:0] bri_awlen               //    > alb_mss_fab
  , output [3:0] bri_awcache             //    > alb_mss_fab
  , output [2:0] bri_awprot              //    > alb_mss_fab
  , output [3:0] bri_wid                 //    > alb_mss_fab
  , output bri_wvalid                    //    > alb_mss_fab
  , output [31:0] bri_wdata              //    > alb_mss_fab
  , output [3:0] bri_wstrb               //    > alb_mss_fab
  , output bri_wlast                     //    > alb_mss_fab
  , output bri_bready                    //    > alb_mss_fab
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [31:0] iccm_ahb_hrdata        //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output iccm_ahb_hresp                //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output iccm_ahb_hreadyout            //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [31:0] dccm_ahb_hrdata        //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dccm_ahb_hresp                //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dccm_ahb_hreadyout            //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [31:0] mmio_ahb_hrdata        //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output mmio_ahb_hresp                //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output mmio_ahb_hreadyout            //    > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output iccm_ahb_hexokay              //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , output iccm_ahb_fatal_err            //    > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output iccm_ahb_hrespchk             //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output iccm_ahb_hreadyoutchk         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] iccm_ahb_hrdatachk      //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dccm_ahb_hexokay              //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , output dccm_ahb_fatal_err            //    > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dccm_ahb_hrespchk             //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dccm_ahb_hreadyoutchk         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] dccm_ahb_hrdatachk      //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output mmio_ahb_hexokay              //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , output mmio_ahb_fatal_err            //    > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output mmio_ahb_hrespchk             //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output mmio_ahb_hreadyoutchk         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] mmio_ahb_hrdatachk      //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hmastlock         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [7:0] dbu_per_ahb_hauser      //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [0:0] dbu_per_ahb_hauserchk   //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hctrlchk2         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dbu_per_ahb_hwstrbchk         //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] dbu_per_ahb_hwdatachk   //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , output dbu_per_ahb_fatal_err         //    > alb_mss_ext_stub
  , output high_prio_ras                 //    > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hmastlock                 //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [7:0] ahb_hauser              //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [0:0] ahb_hauserchk           //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hctrlchk2                 //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output ahb_hwstrbchk                 //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [3:0] ahb_hwdatachk           //    > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , output ahb_fatal_err                 //    > alb_mss_ext_stub
  , output wdt_reset0                    //    > alb_mss_ext_stub
  , output wdt_reset_wdt_clk0            //    > alb_mss_ext_stub
  , output reg_wr_en0                    //    > alb_mss_ext_stub
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output critical_error                //    > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
  , output [1:0] ext_trig_output_valid   //    > alb_mss_ext_stub
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dmsi_rdy                      //    > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output dmsi_rdy_chk                  //    > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
  , output soft_reset_ready              //    > alb_mss_ext_stub
  , output soft_reset_ack                //    > alb_mss_ext_stub
  , output rst_cpu_ack                   //    > alb_mss_ext_stub
  , output cpu_in_reset_state            //    > alb_mss_ext_stub
  , output [1:0] safety_mem_dbe          //    > alb_mss_ext_stub
  , output [1:0] safety_mem_sbe          //    > alb_mss_ext_stub
  , output [1:0] safety_isol_change      //    > alb_mss_ext_stub
  , output [1:0] safety_error            //    > alb_mss_ext_stub
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [1:0] safety_enabled          //    > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
  , output jtag_rtck                     //    > dw_dbp_stubs
  , output arc_halt_ack                  //    > io_pad_ring
  , output arc_run_ack                   //    > io_pad_ring
  , output sys_halt_r                    //    > io_pad_ring
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output sys_sleep_r                   //    > io_pad_ring
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , output [2:0] sys_sleep_mode_r        //    > io_pad_ring
// spyglass enable_block RegInputOutput-ML
  , output jtag_tdo                      //    > io_pad_ring
  , output jtag_tdo_oe                   //    > io_pad_ring
  );

// Intermediate signals:
wire   i_rv_dmihardresetn;               // dw_dbp > arcv_dm_top -- dw_dbp.rv_dmihardresetn
wire   [31:2] i_dbg_apb_paddr;           // dw_dbp > arcv_dm_top -- dw_dbp.dbg_apb_paddr [31:2]
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
wire   i_dbg_apb_psel;                   // dw_dbp > arcv_dm_top -- dw_dbp.dbg_apb_psel
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
wire   i_dbg_apb_penable;                // dw_dbp > arcv_dm_top -- dw_dbp.dbg_apb_penable
// spyglass enable_block RegInputOutput-ML
wire   i_dbg_apb_pwrite;                 // dw_dbp > arcv_dm_top -- dw_dbp.dbg_apb_pwrite
wire   [31:0] i_dbg_apb_pwdata;          // dw_dbp > arcv_dm_top -- dw_dbp.dbg_apb_pwdata [31:0]
wire   i_dbg_ibp_cmd_accept;             // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.dbg_ibp_cmd_accept
wire   i_dbg_ibp_rd_valid;               // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.dbg_ibp_rd_valid
wire   i_dbg_ibp_rd_err;                 // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.dbg_ibp_rd_err
wire   [31:0] i_dbg_ibp_rd_data;         // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.dbg_ibp_rd_data [31:0]
wire   i_dbg_ibp_wr_accept;              // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.dbg_ibp_wr_accept
wire   i_dbg_ibp_wr_done;                // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.dbg_ibp_wr_done
wire   i_dbg_ibp_wr_err;                 // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.dbg_ibp_wr_err
wire   i_arc2dm_havereset_a;             // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.arc2dm_havereset_a
wire   i_arc2dm_run_ack;                 // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.arc2dm_run_ack
wire   i_arc2dm_halt_ack;                // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.arc2dm_halt_ack
wire   i_sys_halt_r;                     // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.sys_halt_r
wire   i_hart_unavailable;               // cpu_top_safety_controller > arcv_dm_top -- cpu_top_safety_controller.hart_unavailable
wire   i_dbg_apb_pready;                 // arcv_dm_top > dw_dbp -- arcv_dm_top.dbg_apb_pready
// spyglass disable_block CDC_UNSYNC_NOSCHEME
// SMD: direct connection from input port to output port
// SJ: We do have CDC constraints for all signals, but it shows an exception for bit 0
wire   [31:0] i_dbg_apb_prdata;          // arcv_dm_top > dw_dbp -- arcv_dm_top.dbg_apb_prdata [31:0]
// spyglass enable_block CDC_UNSYNC_NOSCHEME

wire   i_dbg_apb_pslverr;                // arcv_dm_top > dw_dbp -- arcv_dm_top.dbg_apb_pslverr
wire   i_dm2arc_halt_req_a;              // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dm2arc_halt_req_a
wire   i_dm2arc_run_req_a;               // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dm2arc_run_req_a
wire   i_dm2arc_hartreset_a;             // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dm2arc_hartreset_a
wire   i_dm2arc_hartreset2_a;            // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dm2arc_hartreset2_a
wire   i_ndmreset_a;                     // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.ndmreset_a
wire   i_dm2arc_havereset_ack_a;         // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dm2arc_havereset_ack_a
wire   i_dm2arc_halt_on_reset_a;         // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dm2arc_halt_on_reset_a
wire   i_dm2arc_relaxedpriv_a;           // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dm2arc_relaxedpriv_a
wire   i_safety_iso_enb_a;               // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.safety_iso_enb_a
wire   i_dbg_ibp_cmd_valid;              // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_cmd_valid
wire   i_dbg_ibp_cmd_read;               // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_cmd_read
wire   [`HMIBP_ADDR_W-1:0] i_dbg_ibp_cmd_addr; // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_cmd_addr [`HMIBP_ADDR_W-1:0]
wire   [3:0] i_dbg_ibp_cmd_space;        // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_cmd_space [3:0]
wire   i_dbg_ibp_rd_accept;              // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_rd_accept
wire   i_dbg_ibp_wr_valid;               // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_wr_valid
wire   [`HMIBP_DATA_W-1:0] i_dbg_ibp_wr_data; // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_wr_data [`HMIBP_DATA_W-1:0]
wire   [`HMIBP_DATA_W/8-1:0] i_dbg_ibp_wr_mask; // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_wr_mask [`HMIBP_DATA_W/8-1:0]
wire   i_dbg_ibp_wr_resp_accept;         // arcv_dm_top > cpu_top_safety_controller -- arcv_dm_top.dbg_ibp_wr_resp_accept
wire   [`ICCM0_DRAM_RANGE] i_esrams_iccm0_dout; // rl_srams_instances > cpu_top_safety_controller -- rl_srams_instances.rl_srams.esrams_iccm0_dout [`ICCM0_DRAM_RANGE]
wire   [`DCCM_DRAM_RANGE] i_esrams_dccm_dout_even; // rl_srams_instances > cpu_top_safety_controller -- rl_srams_instances.rl_srams.esrams_dccm_dout_even [`DCCM_DRAM_RANGE]
wire   [`DCCM_DRAM_RANGE] i_esrams_dccm_dout_odd; // rl_srams_instances > cpu_top_safety_controller -- rl_srams_instances.rl_srams.esrams_dccm_dout_odd [`DCCM_DRAM_RANGE]
wire   [`IC_TAG_SET_RANGE] i_esrams_ic_tag_mem_dout; // rl_srams_instances > cpu_top_safety_controller -- rl_srams_instances.rl_srams.esrams_ic_tag_mem_dout [`IC_TAG_SET_RANGE]
wire   [`IC_DATA_SET_RANGE] i_esrams_ic_data_mem_dout; // rl_srams_instances > cpu_top_safety_controller -- rl_srams_instances.rl_srams.esrams_ic_data_mem_dout [`IC_DATA_SET_RANGE]
wire   [1:0] i_dr_safety_comparator_enabled; // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.dr_safety_comparator_enabled [1:0]
wire   [`rv_lsc_err_stat_msb:0] i_lsc_err_stat_aux; // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.lsc_err_stat_aux [`rv_lsc_err_stat_msb:0]
wire   [1:0] i_dr_sfty_eic;              // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.dr_sfty_eic [1:0]
wire   i_sfty_ibp_mmio_cmd_accept;       // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_cmd_accept
wire   i_sfty_ibp_mmio_wr_accept;        // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_wr_accept
wire   i_sfty_ibp_mmio_rd_valid;         // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_valid
wire   i_sfty_ibp_mmio_rd_err;           // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_err
wire   i_sfty_ibp_mmio_rd_excl_ok;       // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_excl_ok
wire   i_sfty_ibp_mmio_rd_last;          // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_last
wire   [31:0] i_sfty_ibp_mmio_rd_data;   // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_data [31:0]
wire   i_sfty_ibp_mmio_wr_done;          // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_wr_done
wire   i_sfty_ibp_mmio_wr_excl_okay;     // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_wr_excl_okay
wire   i_sfty_ibp_mmio_wr_err;           // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_wr_err
wire   i_sfty_ibp_mmio_cmd_accept_pty;   // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_cmd_accept_pty
wire   i_sfty_ibp_mmio_wr_accept_pty;    // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_wr_accept_pty
wire   i_sfty_ibp_mmio_rd_valid_pty;     // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_valid_pty
wire   i_sfty_ibp_mmio_rd_ctrl_pty;      // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_ctrl_pty
wire   [3:0] i_sfty_ibp_mmio_rd_data_pty; // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_rd_data_pty [3:0]
wire   i_sfty_ibp_mmio_wr_done_pty;      // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_wr_done_pty
wire   i_sfty_ibp_mmio_wr_ctrl_pty;      // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.sfty_ibp_mmio_wr_ctrl_pty
wire   [1:0] i_cpu_dr_sfty_diag_mode_sc; // cpu_safety_monitor > cpu_top_safety_controller -- cpu_safety_monitor.cpu_dr_sfty_diag_mode_sc [1:0]
wire   [1:0] i_cpu_dr_mismatch_r;        // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_dr_mismatch_r [1:0]
wire   [1:0] i_cpu_dr_sfty_ctrl_parity_error; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_dr_sfty_ctrl_parity_error [1:0]
wire   [1:0] i_cpu_lsAsafety_comparator_enabled; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_lsAsafety_comparator_enabled [1:0]
wire   [1:0] i_cpu_lsBsafety_comparator_enabled; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_lsBsafety_comparator_enabled [1:0]
wire   i_cpu_lsAls_lock_reset;           // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_lsAls_lock_reset
wire   [1:0] i_cpu_dr_sfty_diag_inj_end; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_dr_sfty_diag_inj_end [1:0]
wire   [1:0] i_cpu_dr_mask_pty_err;      // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_dr_mask_pty_err [1:0]
wire   [15:0] i_lsc_diag_aux_r;          // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.lsc_diag_aux_r [15:0]
wire   i_sfty_nsi_r;                     // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_nsi_r
wire   [1:0] i_dr_lsc_stl_ctrl_aux_r;    // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.dr_lsc_stl_ctrl_aux_r [1:0]
wire   [1:0] i_dr_sfty_aux_parity_err_r; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.dr_sfty_aux_parity_err_r [1:0]
wire   [1:0] i_dr_bus_fatal_err;         // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.dr_bus_fatal_err [1:0]
wire   [1:0] i_dr_safety_iso_err;        // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.dr_safety_iso_err [1:0]
wire   [1:0] i_dr_secure_trig_iso_err;   // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.dr_secure_trig_iso_err [1:0]
wire   i_sfty_mem_sbe_err;               // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_mem_sbe_err
wire   i_sfty_mem_dbe_err;               // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_mem_dbe_err
wire   i_sfty_mem_adr_err;               // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_mem_adr_err
wire   i_sfty_mem_sbe_overflow;          // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_mem_sbe_overflow
wire   i_high_prio_ras;                  // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.high_prio_ras
wire   i_sfty_ibp_mmio_cmd_valid;        // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_valid
wire   [3:0] i_sfty_ibp_mmio_cmd_cache;  // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_cache [3:0]
wire   i_sfty_ibp_mmio_cmd_burst_size;   // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_burst_size
wire   i_sfty_ibp_mmio_cmd_read;         // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_read
wire   i_sfty_ibp_mmio_cmd_aux;          // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_aux
wire   [7:0] i_sfty_ibp_mmio_cmd_addr;   // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_addr [7:0]
wire   i_sfty_ibp_mmio_cmd_excl;         // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_excl
wire   [5:0] i_sfty_ibp_mmio_cmd_atomic; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_atomic [5:0]
wire   [2:0] i_sfty_ibp_mmio_cmd_data_size; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_data_size [2:0]
wire   [1:0] i_sfty_ibp_mmio_cmd_prot;   // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_prot [1:0]
wire   i_sfty_ibp_mmio_wr_valid;         // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_valid
wire   i_sfty_ibp_mmio_wr_last;          // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_last
wire   [3:0] i_sfty_ibp_mmio_wr_mask;    // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_mask [3:0]
wire   [31:0] i_sfty_ibp_mmio_wr_data;   // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_data [31:0]
wire   i_sfty_ibp_mmio_rd_accept;        // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_rd_accept
wire   i_sfty_ibp_mmio_wr_resp_accept;   // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_resp_accept
wire   i_sfty_ibp_mmio_cmd_valid_pty;    // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_valid_pty
wire   i_sfty_ibp_mmio_cmd_addr_pty;     // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_addr_pty
wire   [3:0] i_sfty_ibp_mmio_cmd_ctrl_pty; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_cmd_ctrl_pty [3:0]
wire   i_sfty_ibp_mmio_wr_valid_pty;     // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_valid_pty
wire   i_sfty_ibp_mmio_wr_last_pty;      // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_last_pty
wire   i_sfty_ibp_mmio_rd_accept_pty;    // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_rd_accept_pty
wire   i_sfty_ibp_mmio_wr_resp_accept_pty; // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_wr_resp_accept_pty
wire   i_sfty_ibp_mmio_ini_e2e_err;      // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_ibp_mmio_ini_e2e_err
wire   i_sfty_dmsi_tgt_e2e_err;          // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.sfty_dmsi_tgt_e2e_err
wire   i_wdt_reset0;                     // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.wdt_reset0
wire   i_cpu_clk_gated;                  // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_clk_gated
wire   i_cpu_rst_gated;                  // cpu_top_safety_controller > cpu_safety_monitor -- cpu_top_safety_controller.cpu_rst_gated
wire   i_esrams_iccm0_clk;               // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_iccm0_clk
wire   [39:0] i_esrams_iccm0_din;        // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_iccm0_din [39:0]
wire   [18:2] i_esrams_iccm0_addr;       // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_iccm0_addr [18:2]
wire   i_esrams_iccm0_cs;                // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_iccm0_cs
wire   i_esrams_iccm0_we;                // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_iccm0_we
wire   [4:0] i_esrams_iccm0_wem;         // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_iccm0_wem [4:0]
wire   i_esrams_dccm_even_clk;           // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_even_clk
wire   [39:0] i_esrams_dccm_din_even;    // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_din_even [39:0]
wire   [19:3] i_esrams_dccm_addr_even;   // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_addr_even [19:3]
wire   i_esrams_dccm_cs_even;            // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_cs_even
wire   i_esrams_dccm_we_even;            // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_we_even
wire   [4:0] i_esrams_dccm_wem_even;     // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_wem_even [4:0]
wire   i_esrams_dccm_odd_clk;            // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_odd_clk
wire   [39:0] i_esrams_dccm_din_odd;     // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_din_odd [39:0]
wire   [19:3] i_esrams_dccm_addr_odd;    // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_addr_odd [19:3]
wire   i_esrams_dccm_cs_odd;             // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_cs_odd
wire   i_esrams_dccm_we_odd;             // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_we_odd
wire   [4:0] i_esrams_dccm_wem_odd;      // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_dccm_wem_odd [4:0]
wire   i_esrams_ic_tag_mem_clk;          // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_tag_mem_clk
wire   [55:0] i_esrams_ic_tag_mem_din;   // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_tag_mem_din [55:0]
wire   [12:5] i_esrams_ic_tag_mem_addr;  // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_tag_mem_addr [12:5]
wire   i_esrams_ic_tag_mem_cs;           // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_tag_mem_cs
wire   i_esrams_ic_tag_mem_we;           // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_tag_mem_we
wire   [55:0] i_esrams_ic_tag_mem_wem;   // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_tag_mem_wem [55:0]
wire   i_esrams_ic_data_mem_clk;         // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_data_mem_clk
wire   [79:0] i_esrams_ic_data_mem_din;  // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_data_mem_din [79:0]
wire   [12:2] i_esrams_ic_data_mem_addr; // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_data_mem_addr [12:2]
wire   i_esrams_ic_data_mem_cs;          // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_data_mem_cs
wire   i_esrams_ic_data_mem_we;          // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_data_mem_we
wire   [79:0] i_esrams_ic_data_mem_wem;  // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ic_data_mem_wem [79:0]
wire   i_esrams_clk;                     // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_clk
wire   i_esrams_ls;                      // cpu_top_safety_controller > rl_srams_instances -- cpu_top_safety_controller.esrams_ls

// Instantiation of module arcv_dm_top
arcv_dm_top iarcv_dm_top(
    .rv_dmihardresetn       (i_rv_dmihardresetn)   // <   dw_dbp
  , .dbg_apb_paddr          (i_dbg_apb_paddr)      // <   dw_dbp
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbg_apb_psel           (i_dbg_apb_psel)       // <   dw_dbp
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbg_apb_penable        (i_dbg_apb_penable)    // <   dw_dbp
// spyglass enable_block RegInputOutput-ML
  , .dbg_apb_pwrite         (i_dbg_apb_pwrite)     // <   dw_dbp
  , .dbg_apb_pwdata         (i_dbg_apb_pwdata)     // <   dw_dbp
  , .dbg_ibp_cmd_accept     (i_dbg_ibp_cmd_accept) // <   cpu_top_safety_controller
  , .dbg_ibp_rd_valid       (i_dbg_ibp_rd_valid)   // <   cpu_top_safety_controller
  , .dbg_ibp_rd_err         (i_dbg_ibp_rd_err)     // <   cpu_top_safety_controller
  , .dbg_ibp_rd_data        (i_dbg_ibp_rd_data)    // <   cpu_top_safety_controller
  , .dbg_ibp_wr_accept      (i_dbg_ibp_wr_accept)  // <   cpu_top_safety_controller
  , .dbg_ibp_wr_done        (i_dbg_ibp_wr_done)    // <   cpu_top_safety_controller
  , .dbg_ibp_wr_err         (i_dbg_ibp_wr_err)     // <   cpu_top_safety_controller
  , .safety_iso_enb         (safety_iso_enb)       // <   alb_mss_ext_stub
  , .dbg_unlock             (dbg_unlock)           // <   alb_mss_ext_stub
  , .arc_halt_req_a         (arc_halt_req_a)       // <   io_pad_ring
  , .arc_run_req_a          (arc_run_req_a)        // <   io_pad_ring
  , .arc2dm_havereset_a     (i_arc2dm_havereset_a) // <   cpu_top_safety_controller
  , .arc2dm_run_ack         (i_arc2dm_run_ack)     // <   cpu_top_safety_controller
  , .arc2dm_halt_ack        (i_arc2dm_halt_ack)    // <   cpu_top_safety_controller
  , .sys_halt_r             (i_sys_halt_r)         // <   cpu_top_safety_controller
  , .hart_unavailable       (i_hart_unavailable)   // <   cpu_top_safety_controller
  , .test_mode              (test_mode)            // <   io_pad_ring
  , .clk                    (clk)                  // <   alb_mss_clkctrl
  , .rst_a                  (rst_a)                // <   io_pad_ring
  , .dbg_apb_pready         (i_dbg_apb_pready)     //   > dw_dbp
// spyglass disable_block CDC_UNSYNC_NOSCHEME
// SMD: direct connection from input port to output port
// SJ: We do have CDC constraints for all signals, but it shows an exception for bit 0
  , .dbg_apb_prdata         (i_dbg_apb_prdata)     //   > dw_dbp
// spyglass enable_block CDC_UNSYNC_NOSCHEME

  , .dbg_apb_pslverr        (i_dbg_apb_pslverr)    //   > dw_dbp
  , .dm2arc_halt_req_a      (i_dm2arc_halt_req_a)  //   > cpu_top_safety_controller
  , .dm2arc_run_req_a       (i_dm2arc_run_req_a)   //   > cpu_top_safety_controller
  , .dm2arc_hartreset_a     (i_dm2arc_hartreset_a) //   > cpu_top_safety_controller
  , .dm2arc_hartreset2_a    (i_dm2arc_hartreset2_a) //   > cpu_top_safety_controller
  , .ndmreset_a             (i_ndmreset_a)         //   > cpu_top_safety_controller
  , .dm2arc_havereset_ack_a (i_dm2arc_havereset_ack_a) //   > cpu_top_safety_controller
  , .dm2arc_halt_on_reset_a (i_dm2arc_halt_on_reset_a) //   > cpu_top_safety_controller
  , .dm2arc_relaxedpriv_a   (i_dm2arc_relaxedpriv_a) //   > cpu_top_safety_controller
  , .safety_iso_enb_a       (i_safety_iso_enb_a)   //   > cpu_top_safety_controller
  , .dbg_ibp_cmd_valid      (i_dbg_ibp_cmd_valid)  //   > cpu_top_safety_controller
  , .dbg_ibp_cmd_read       (i_dbg_ibp_cmd_read)   //   > cpu_top_safety_controller
  , .dbg_ibp_cmd_addr       (i_dbg_ibp_cmd_addr)   //   > cpu_top_safety_controller
  , .dbg_ibp_cmd_space      (i_dbg_ibp_cmd_space)  //   > cpu_top_safety_controller
  , .dbg_ibp_rd_accept      (i_dbg_ibp_rd_accept)  //   > cpu_top_safety_controller
  , .dbg_ibp_wr_valid       (i_dbg_ibp_wr_valid)   //   > cpu_top_safety_controller
  , .dbg_ibp_wr_data        (i_dbg_ibp_wr_data)    //   > cpu_top_safety_controller
  , .dbg_ibp_wr_mask        (i_dbg_ibp_wr_mask)    //   > cpu_top_safety_controller
  , .dbg_ibp_wr_resp_accept (i_dbg_ibp_wr_resp_accept) //   > cpu_top_safety_controller
  , .safety_isol_change     (safety_isol_change)   //   > alb_mss_ext_stub
  , .arc_halt_ack           (arc_halt_ack)         //   > io_pad_ring
  , .arc_run_ack            (arc_run_ack)          //   > io_pad_ring
  );

// Instantiation of module dw_dbp
dw_dbp idw_dbp(
    .clk              (clk)                        // <   alb_mss_clkctrl
  , .test_mode        (test_mode)                  // <   io_pad_ring
  , .jtag_tck         (jtag_tck)                   // <   io_pad_ring
  , .jtag_trst_n      (jtag_trst_n)                // <   io_pad_ring
  , .jtag_tdi         (jtag_tdi)                   // <   io_pad_ring
  , .jtag_tms         (jtag_tms)                   // <   io_pad_ring
  , .dbg_apb_pready   (i_dbg_apb_pready)           // <   arcv_dm_top
// spyglass disable_block CDC_UNSYNC_NOSCHEME
// SMD: direct connection from input port to output port
// SJ: We do have CDC constraints for all signals, but it shows an exception for bit 0
  , .dbg_apb_prdata   (i_dbg_apb_prdata)           // <   arcv_dm_top
// spyglass enable_block CDC_UNSYNC_NOSCHEME

  , .dbg_apb_pslverr  (i_dbg_apb_pslverr)          // <   arcv_dm_top
  , .bri_awready      (bri_awready)                // <   alb_mss_fab
  , .bri_wready       (bri_wready)                 // <   alb_mss_fab
  , .bri_bid          (bri_bid)                    // <   alb_mss_fab
  , .bri_bresp        (bri_bresp)                  // <   alb_mss_fab
  , .bri_bvalid       (bri_bvalid)                 // <   alb_mss_fab
  , .bri_arready      (bri_arready)                // <   alb_mss_fab
  , .bri_rid          (bri_rid)                    // <   alb_mss_fab
  , .bri_rdata        (bri_rdata)                  // <   alb_mss_fab
  , .bri_rlast        (bri_rlast)                  // <   alb_mss_fab
  , .bri_rvalid       (bri_rvalid)                 // <   alb_mss_fab
  , .bri_rresp        (bri_rresp)                  // <   alb_mss_fab
  , .rst_a            (rst_a)                      // <   io_pad_ring
  , .rv_dmihardresetn (i_rv_dmihardresetn)         //   > arcv_dm_top
  , .dbg_apb_paddr    (i_dbg_apb_paddr)            //   > arcv_dm_top
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbg_apb_psel     (i_dbg_apb_psel)             //   > arcv_dm_top
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbg_apb_penable  (i_dbg_apb_penable)          //   > arcv_dm_top
// spyglass enable_block RegInputOutput-ML
  , .dbg_apb_pwrite   (i_dbg_apb_pwrite)           //   > arcv_dm_top
  , .dbg_apb_pwdata   (i_dbg_apb_pwdata)           //   > arcv_dm_top
  , .bri_arid         (bri_arid)                   //   > alb_mss_fab
  , .bri_arvalid      (bri_arvalid)                //   > alb_mss_fab
  , .bri_araddr       (bri_araddr)                 //   > alb_mss_fab
  , .bri_arburst      (bri_arburst)                //   > alb_mss_fab
  , .bri_arsize       (bri_arsize)                 //   > alb_mss_fab
  , .bri_arlen        (bri_arlen)                  //   > alb_mss_fab
  , .bri_arcache      (bri_arcache)                //   > alb_mss_fab
  , .bri_arprot       (bri_arprot)                 //   > alb_mss_fab
  , .bri_rready       (bri_rready)                 //   > alb_mss_fab
  , .bri_awid         (bri_awid)                   //   > alb_mss_fab
  , .bri_awvalid      (bri_awvalid)                //   > alb_mss_fab
  , .bri_awaddr       (bri_awaddr)                 //   > alb_mss_fab
  , .bri_awburst      (bri_awburst)                //   > alb_mss_fab
  , .bri_awsize       (bri_awsize)                 //   > alb_mss_fab
  , .bri_awlen        (bri_awlen)                  //   > alb_mss_fab
  , .bri_awcache      (bri_awcache)                //   > alb_mss_fab
  , .bri_awprot       (bri_awprot)                 //   > alb_mss_fab
  , .bri_wid          (bri_wid)                    //   > alb_mss_fab
  , .bri_wvalid       (bri_wvalid)                 //   > alb_mss_fab
  , .bri_wdata        (bri_wdata)                  //   > alb_mss_fab
  , .bri_wstrb        (bri_wstrb)                  //   > alb_mss_fab
  , .bri_wlast        (bri_wlast)                  //   > alb_mss_fab
  , .bri_bready       (bri_bready)                 //   > alb_mss_fab
  , .jtag_rtck        (jtag_rtck)                  //   > dw_dbp_stubs
  , .jtag_tdo         (jtag_tdo)                   //   > io_pad_ring
  , .jtag_tdo_oe      (jtag_tdo_oe)                //   > io_pad_ring
  );

// Instantiation of module cpu_top_safety_controller
cpu_top_safety_controller icpu_top_safety_controller(
    .clk                              (clk)        // <   alb_mss_clkctrl
  , .rst_a                            (rst_a)      // <   io_pad_ring
  , .rst_cpu_req_a                    (rst_cpu_req_a) // <   alb_mss_ext_stub
  , .test_mode                        (test_mode)  // <   io_pad_ring
  , .LBIST_EN                         (LBIST_EN)   // <   alb_mss_ext_stub
  , .dm2arc_halt_req_a                (i_dm2arc_halt_req_a) // <   arcv_dm_top
  , .dm2arc_run_req_a                 (i_dm2arc_run_req_a) // <   arcv_dm_top
  , .dm2arc_hartreset_a               (i_dm2arc_hartreset_a) // <   arcv_dm_top
  , .dm2arc_hartreset2_a              (i_dm2arc_hartreset2_a) // <   arcv_dm_top
  , .ndmreset_a                       (i_ndmreset_a) // <   arcv_dm_top
  , .dm2arc_havereset_ack_a           (i_dm2arc_havereset_ack_a) // <   arcv_dm_top
  , .dm2arc_halt_on_reset_a           (i_dm2arc_halt_on_reset_a) // <   arcv_dm_top
  , .dm2arc_relaxedpriv_a             (i_dm2arc_relaxedpriv_a) // <   arcv_dm_top
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hready                       (ahb_hready) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hresp                        (ahb_hresp)  // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hexokay                      (ahb_hexokay) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hrdata                       (ahb_hrdata) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hreadychk                    (ahb_hreadychk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hrespchk                     (ahb_hrespchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hrdatachk                    (ahb_hrdatachk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hready               (dbu_per_ahb_hready) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hresp                (dbu_per_ahb_hresp) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hexokay              (dbu_per_ahb_hexokay) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hrdata               (dbu_per_ahb_hrdata) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hreadychk            (dbu_per_ahb_hreadychk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hrespchk             (dbu_per_ahb_hrespchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hrdatachk            (dbu_per_ahb_hrdatachk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .iccm_ahb_prio                    (iccm_ahb_prio) // <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hmastlock               (iccm_ahb_hmastlock) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hexcl                   (iccm_ahb_hexcl) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hmaster                 (iccm_ahb_hmaster) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hsel                    (iccm_ahb_hsel) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_htrans                  (iccm_ahb_htrans) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hwrite                  (iccm_ahb_hwrite) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_haddr                   (iccm_ahb_haddr) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hsize                   (iccm_ahb_hsize) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hwstrb                  (iccm_ahb_hwstrb) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hburst                  (iccm_ahb_hburst) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hprot                   (iccm_ahb_hprot) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hnonsec                 (iccm_ahb_hnonsec) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hwdata                  (iccm_ahb_hwdata) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hready                  (iccm_ahb_hready) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_haddrchk                (iccm_ahb_haddrchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_htranschk               (iccm_ahb_htranschk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hctrlchk1               (iccm_ahb_hctrlchk1) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hctrlchk2               (iccm_ahb_hctrlchk2) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hwstrbchk               (iccm_ahb_hwstrbchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hprotchk                (iccm_ahb_hprotchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hreadychk               (iccm_ahb_hreadychk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hselchk                 (iccm_ahb_hselchk) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hwdatachk               (iccm_ahb_hwdatachk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .dccm_ahb_prio                    (dccm_ahb_prio) // <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hmastlock               (dccm_ahb_hmastlock) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hexcl                   (dccm_ahb_hexcl) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hmaster                 (dccm_ahb_hmaster) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hsel                    (dccm_ahb_hsel) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_htrans                  (dccm_ahb_htrans) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hwrite                  (dccm_ahb_hwrite) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_haddr                   (dccm_ahb_haddr) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hsize                   (dccm_ahb_hsize) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hwstrb                  (dccm_ahb_hwstrb) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hnonsec                 (dccm_ahb_hnonsec) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hburst                  (dccm_ahb_hburst) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hprot                   (dccm_ahb_hprot) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hwdata                  (dccm_ahb_hwdata) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hready                  (dccm_ahb_hready) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_haddrchk                (dccm_ahb_haddrchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_htranschk               (dccm_ahb_htranschk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hctrlchk1               (dccm_ahb_hctrlchk1) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hctrlchk2               (dccm_ahb_hctrlchk2) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hwstrbchk               (dccm_ahb_hwstrbchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hprotchk                (dccm_ahb_hprotchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hreadychk               (dccm_ahb_hreadychk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hselchk                 (dccm_ahb_hselchk) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hwdatachk               (dccm_ahb_hwdatachk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .mmio_ahb_prio                    (mmio_ahb_prio) // <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hmastlock               (mmio_ahb_hmastlock) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hexcl                   (mmio_ahb_hexcl) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hmaster                 (mmio_ahb_hmaster) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hsel                    (mmio_ahb_hsel) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_htrans                  (mmio_ahb_htrans) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hwrite                  (mmio_ahb_hwrite) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_haddr                   (mmio_ahb_haddr) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hsize                   (mmio_ahb_hsize) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hwstrb                  (mmio_ahb_hwstrb) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hnonsec                 (mmio_ahb_hnonsec) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hburst                  (mmio_ahb_hburst) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hprot                   (mmio_ahb_hprot) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hwdata                  (mmio_ahb_hwdata) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hready                  (mmio_ahb_hready) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_haddrchk                (mmio_ahb_haddrchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_htranschk               (mmio_ahb_htranschk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hctrlchk1               (mmio_ahb_hctrlchk1) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hctrlchk2               (mmio_ahb_hctrlchk2) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hwstrbchk               (mmio_ahb_hwstrbchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hprotchk                (mmio_ahb_hprotchk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hreadychk               (mmio_ahb_hreadychk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hselchk                 (mmio_ahb_hselchk) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hwdatachk               (mmio_ahb_hwdatachk) // <   alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .mmio_base_in                     (mmio_base_in) // <   alb_mss_ext_stub
// spyglass disable_block Topology_02
// SMD: direct connection from input port to output port
// SJ:  None-registered interface
  , .reset_pc_in                      (reset_pc_in) // <   alb_mss_ext_stub
// spyglass enable_block Topology_02

  , .rnmi_a                           (rnmi_a)     // <   alb_mss_ext_stub
  , .esrams_iccm0_dout                (i_esrams_iccm0_dout) // <   rl_srams_instances.rl_srams
  , .esrams_dccm_dout_even            (i_esrams_dccm_dout_even) // <   rl_srams_instances.rl_srams
  , .esrams_dccm_dout_odd             (i_esrams_dccm_dout_odd) // <   rl_srams_instances.rl_srams
  , .esrams_ic_tag_mem_dout           (i_esrams_ic_tag_mem_dout) // <   rl_srams_instances.rl_srams
  , .esrams_ic_data_mem_dout          (i_esrams_ic_data_mem_dout) // <   rl_srams_instances.rl_srams
  , .ext_trig_output_accept           (ext_trig_output_accept) // <   alb_mss_ext_stub
  , .ext_trig_in                      (ext_trig_in) // <   alb_mss_ext_stub
  , .dr_safety_comparator_enabled     (i_dr_safety_comparator_enabled) // <   cpu_safety_monitor
  , .safety_iso_enb_a                 (i_safety_iso_enb_a) // <   arcv_dm_top
  , .lsc_err_stat_aux                 (i_lsc_err_stat_aux) // <   cpu_safety_monitor
  , .dr_sfty_eic                      (i_dr_sfty_eic) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_accept         (i_sfty_ibp_mmio_cmd_accept) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_wr_accept          (i_sfty_ibp_mmio_wr_accept) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_valid           (i_sfty_ibp_mmio_rd_valid) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_err             (i_sfty_ibp_mmio_rd_err) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_excl_ok         (i_sfty_ibp_mmio_rd_excl_ok) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_last            (i_sfty_ibp_mmio_rd_last) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_data            (i_sfty_ibp_mmio_rd_data) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_wr_done            (i_sfty_ibp_mmio_wr_done) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_wr_excl_okay       (i_sfty_ibp_mmio_wr_excl_okay) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_wr_err             (i_sfty_ibp_mmio_wr_err) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_accept_pty     (i_sfty_ibp_mmio_cmd_accept_pty) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_wr_accept_pty      (i_sfty_ibp_mmio_wr_accept_pty) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_valid_pty       (i_sfty_ibp_mmio_rd_valid_pty) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_ctrl_pty        (i_sfty_ibp_mmio_rd_ctrl_pty) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_rd_data_pty        (i_sfty_ibp_mmio_rd_data_pty) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_wr_done_pty        (i_sfty_ibp_mmio_wr_done_pty) // <   cpu_safety_monitor
  , .sfty_ibp_mmio_wr_ctrl_pty        (i_sfty_ibp_mmio_wr_ctrl_pty) // <   cpu_safety_monitor
// spyglass disable_block Ac_glitch02
// SMD: Clock domain crossing may be subject to glitches
// SJ: CDC accross is handled
  , .dmsi_valid                       (dmsi_valid) // <   alb_mss_ext_stub
// spyglass enable_block Ac_glitch02
  , .dmsi_context                     (dmsi_context) // <   alb_mss_ext_stub
  , .dmsi_eiid                        (dmsi_eiid)  // <   alb_mss_ext_stub
  , .dmsi_domain                      (dmsi_domain) // <   alb_mss_ext_stub
  , .dmsi_valid_chk                   (dmsi_valid_chk) // <   alb_mss_ext_stub
  , .dmsi_data_edc                    (dmsi_data_edc) // <   alb_mss_ext_stub
  , .dbg_ibp_cmd_valid                (i_dbg_ibp_cmd_valid) // <   arcv_dm_top
  , .dbg_ibp_cmd_read                 (i_dbg_ibp_cmd_read) // <   arcv_dm_top
  , .dbg_ibp_cmd_addr                 (i_dbg_ibp_cmd_addr) // <   arcv_dm_top
  , .dbg_ibp_cmd_space                (i_dbg_ibp_cmd_space) // <   arcv_dm_top
  , .dbg_ibp_rd_accept                (i_dbg_ibp_rd_accept) // <   arcv_dm_top
  , .dbg_ibp_wr_valid                 (i_dbg_ibp_wr_valid) // <   arcv_dm_top
  , .dbg_ibp_wr_data                  (i_dbg_ibp_wr_data) // <   arcv_dm_top
  , .dbg_ibp_wr_mask                  (i_dbg_ibp_wr_mask) // <   arcv_dm_top
  , .dbg_ibp_wr_resp_accept           (i_dbg_ibp_wr_resp_accept) // <   arcv_dm_top
  , .wid_rlwid                        (wid_rlwid)  // <   alb_mss_ext_stub
  , .wid_rwiddeleg                    (wid_rwiddeleg) // <   alb_mss_ext_stub
  , .soft_reset_prepare_a             (soft_reset_prepare_a) // <   alb_mss_ext_stub
  , .soft_reset_req_a                 (soft_reset_req_a) // <   alb_mss_ext_stub
  , .rst_init_disable_a               (rst_init_disable_a) // <   alb_mss_ext_stub
  , .arcnum                           (arcnum)     // <   io_pad_ring
  , .cpu_dr_sfty_diag_mode_sc         (i_cpu_dr_sfty_diag_mode_sc) // <   cpu_safety_monitor
  , .ref_clk                          (ref_clk)    // <   io_pad_ring
  , .wdt_clk                          (wdt_clk)    // <   alb_mss_clkctrl
  , .dbg_ibp_cmd_accept               (i_dbg_ibp_cmd_accept) //   > arcv_dm_top
  , .dbg_ibp_rd_valid                 (i_dbg_ibp_rd_valid) //   > arcv_dm_top
  , .dbg_ibp_rd_err                   (i_dbg_ibp_rd_err) //   > arcv_dm_top
  , .dbg_ibp_rd_data                  (i_dbg_ibp_rd_data) //   > arcv_dm_top
  , .dbg_ibp_wr_accept                (i_dbg_ibp_wr_accept) //   > arcv_dm_top
  , .dbg_ibp_wr_done                  (i_dbg_ibp_wr_done) //   > arcv_dm_top
  , .dbg_ibp_wr_err                   (i_dbg_ibp_wr_err) //   > arcv_dm_top
  , .arc2dm_havereset_a               (i_arc2dm_havereset_a) //   > arcv_dm_top
  , .arc2dm_run_ack                   (i_arc2dm_run_ack) //   > arcv_dm_top
  , .arc2dm_halt_ack                  (i_arc2dm_halt_ack) //   > arcv_dm_top
  , .sys_halt_r                       (i_sys_halt_r) //   > arcv_dm_top
  , .hart_unavailable                 (i_hart_unavailable) //   > arcv_dm_top
  , .cpu_dr_mismatch_r                (i_cpu_dr_mismatch_r) //   > cpu_safety_monitor
  , .cpu_dr_sfty_ctrl_parity_error    (i_cpu_dr_sfty_ctrl_parity_error) //   > cpu_safety_monitor
  , .cpu_lsAsafety_comparator_enabled (i_cpu_lsAsafety_comparator_enabled) //   > cpu_safety_monitor
  , .cpu_lsBsafety_comparator_enabled (i_cpu_lsBsafety_comparator_enabled) //   > cpu_safety_monitor
  , .cpu_lsAls_lock_reset             (i_cpu_lsAls_lock_reset) //   > cpu_safety_monitor
  , .cpu_dr_sfty_diag_inj_end         (i_cpu_dr_sfty_diag_inj_end) //   > cpu_safety_monitor
  , .cpu_dr_mask_pty_err              (i_cpu_dr_mask_pty_err) //   > cpu_safety_monitor
  , .lsc_diag_aux_r                   (i_lsc_diag_aux_r) //   > cpu_safety_monitor
  , .sfty_nsi_r                       (i_sfty_nsi_r) //   > cpu_safety_monitor
  , .dr_lsc_stl_ctrl_aux_r            (i_dr_lsc_stl_ctrl_aux_r) //   > cpu_safety_monitor
  , .dr_sfty_aux_parity_err_r         (i_dr_sfty_aux_parity_err_r) //   > cpu_safety_monitor
  , .dr_bus_fatal_err                 (i_dr_bus_fatal_err) //   > cpu_safety_monitor
  , .dr_safety_iso_err                (i_dr_safety_iso_err) //   > cpu_safety_monitor
  , .dr_secure_trig_iso_err           (i_dr_secure_trig_iso_err) //   > cpu_safety_monitor
  , .sfty_mem_sbe_err                 (i_sfty_mem_sbe_err) //   > cpu_safety_monitor
  , .sfty_mem_dbe_err                 (i_sfty_mem_dbe_err) //   > cpu_safety_monitor
  , .sfty_mem_adr_err                 (i_sfty_mem_adr_err) //   > cpu_safety_monitor
  , .sfty_mem_sbe_overflow            (i_sfty_mem_sbe_overflow) //   > cpu_safety_monitor
  , .high_prio_ras                    (i_high_prio_ras) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_valid          (i_sfty_ibp_mmio_cmd_valid) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_cache          (i_sfty_ibp_mmio_cmd_cache) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_burst_size     (i_sfty_ibp_mmio_cmd_burst_size) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_read           (i_sfty_ibp_mmio_cmd_read) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_aux            (i_sfty_ibp_mmio_cmd_aux) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_addr           (i_sfty_ibp_mmio_cmd_addr) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_excl           (i_sfty_ibp_mmio_cmd_excl) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_atomic         (i_sfty_ibp_mmio_cmd_atomic) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_data_size      (i_sfty_ibp_mmio_cmd_data_size) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_prot           (i_sfty_ibp_mmio_cmd_prot) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_valid           (i_sfty_ibp_mmio_wr_valid) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_last            (i_sfty_ibp_mmio_wr_last) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_mask            (i_sfty_ibp_mmio_wr_mask) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_data            (i_sfty_ibp_mmio_wr_data) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_rd_accept          (i_sfty_ibp_mmio_rd_accept) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_resp_accept     (i_sfty_ibp_mmio_wr_resp_accept) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_valid_pty      (i_sfty_ibp_mmio_cmd_valid_pty) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_addr_pty       (i_sfty_ibp_mmio_cmd_addr_pty) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_cmd_ctrl_pty       (i_sfty_ibp_mmio_cmd_ctrl_pty) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_valid_pty       (i_sfty_ibp_mmio_wr_valid_pty) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_last_pty        (i_sfty_ibp_mmio_wr_last_pty) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_rd_accept_pty      (i_sfty_ibp_mmio_rd_accept_pty) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_wr_resp_accept_pty (i_sfty_ibp_mmio_wr_resp_accept_pty) //   > cpu_safety_monitor
  , .sfty_ibp_mmio_ini_e2e_err        (i_sfty_ibp_mmio_ini_e2e_err) //   > cpu_safety_monitor
  , .sfty_dmsi_tgt_e2e_err            (i_sfty_dmsi_tgt_e2e_err) //   > cpu_safety_monitor
  , .wdt_reset0                       (i_wdt_reset0) //   > cpu_safety_monitor
  , .cpu_clk_gated                    (i_cpu_clk_gated) //   > cpu_safety_monitor
  , .cpu_rst_gated                    (i_cpu_rst_gated) //   > cpu_safety_monitor
  , .esrams_iccm0_clk                 (i_esrams_iccm0_clk) //   > rl_srams_instances
  , .esrams_iccm0_din                 (i_esrams_iccm0_din) //   > rl_srams_instances
  , .esrams_iccm0_addr                (i_esrams_iccm0_addr) //   > rl_srams_instances
  , .esrams_iccm0_cs                  (i_esrams_iccm0_cs) //   > rl_srams_instances
  , .esrams_iccm0_we                  (i_esrams_iccm0_we) //   > rl_srams_instances
  , .esrams_iccm0_wem                 (i_esrams_iccm0_wem) //   > rl_srams_instances
  , .esrams_dccm_even_clk             (i_esrams_dccm_even_clk) //   > rl_srams_instances
  , .esrams_dccm_din_even             (i_esrams_dccm_din_even) //   > rl_srams_instances
  , .esrams_dccm_addr_even            (i_esrams_dccm_addr_even) //   > rl_srams_instances
  , .esrams_dccm_cs_even              (i_esrams_dccm_cs_even) //   > rl_srams_instances
  , .esrams_dccm_we_even              (i_esrams_dccm_we_even) //   > rl_srams_instances
  , .esrams_dccm_wem_even             (i_esrams_dccm_wem_even) //   > rl_srams_instances
  , .esrams_dccm_odd_clk              (i_esrams_dccm_odd_clk) //   > rl_srams_instances
  , .esrams_dccm_din_odd              (i_esrams_dccm_din_odd) //   > rl_srams_instances
  , .esrams_dccm_addr_odd             (i_esrams_dccm_addr_odd) //   > rl_srams_instances
  , .esrams_dccm_cs_odd               (i_esrams_dccm_cs_odd) //   > rl_srams_instances
  , .esrams_dccm_we_odd               (i_esrams_dccm_we_odd) //   > rl_srams_instances
  , .esrams_dccm_wem_odd              (i_esrams_dccm_wem_odd) //   > rl_srams_instances
  , .esrams_ic_tag_mem_clk            (i_esrams_ic_tag_mem_clk) //   > rl_srams_instances
  , .esrams_ic_tag_mem_din            (i_esrams_ic_tag_mem_din) //   > rl_srams_instances
  , .esrams_ic_tag_mem_addr           (i_esrams_ic_tag_mem_addr) //   > rl_srams_instances
  , .esrams_ic_tag_mem_cs             (i_esrams_ic_tag_mem_cs) //   > rl_srams_instances
  , .esrams_ic_tag_mem_we             (i_esrams_ic_tag_mem_we) //   > rl_srams_instances
  , .esrams_ic_tag_mem_wem            (i_esrams_ic_tag_mem_wem) //   > rl_srams_instances
  , .esrams_ic_data_mem_clk           (i_esrams_ic_data_mem_clk) //   > rl_srams_instances
  , .esrams_ic_data_mem_din           (i_esrams_ic_data_mem_din) //   > rl_srams_instances
  , .esrams_ic_data_mem_addr          (i_esrams_ic_data_mem_addr) //   > rl_srams_instances
  , .esrams_ic_data_mem_cs            (i_esrams_ic_data_mem_cs) //   > rl_srams_instances
  , .esrams_ic_data_mem_we            (i_esrams_ic_data_mem_we) //   > rl_srams_instances
  , .esrams_ic_data_mem_wem           (i_esrams_ic_data_mem_wem) //   > rl_srams_instances
  , .esrams_clk                       (i_esrams_clk) //   > rl_srams_instances
  , .esrams_ls                        (i_esrams_ls) //   > rl_srams_instances
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_htrans                       (ahb_htrans) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hwrite                       (ahb_hwrite) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_haddr                        (ahb_haddr)  //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hsize                        (ahb_hsize)  //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hburst                       (ahb_hburst) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hprot                        (ahb_hprot)  //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hnonsec                      (ahb_hnonsec) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hexcl                        (ahb_hexcl)  //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hmaster                      (ahb_hmaster) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hwdata                       (ahb_hwdata) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hwstrb                       (ahb_hwstrb) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_haddrchk                     (ahb_haddrchk) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_htranschk                    (ahb_htranschk) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hctrlchk1                    (ahb_hctrlchk1) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hprotchk                     (ahb_hprotchk) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_htrans               (dbu_per_ahb_htrans) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hwrite               (dbu_per_ahb_hwrite) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_haddr                (dbu_per_ahb_haddr) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hsize                (dbu_per_ahb_hsize) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hburst               (dbu_per_ahb_hburst) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hprot                (dbu_per_ahb_hprot) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hnonsec              (dbu_per_ahb_hnonsec) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hexcl                (dbu_per_ahb_hexcl) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hmaster              (dbu_per_ahb_hmaster) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hwdata               (dbu_per_ahb_hwdata) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hwstrb               (dbu_per_ahb_hwstrb) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_haddrchk             (dbu_per_ahb_haddrchk) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_htranschk            (dbu_per_ahb_htranschk) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hctrlchk1            (dbu_per_ahb_hctrlchk1) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hprotchk             (dbu_per_ahb_hprotchk) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hrdata                  (iccm_ahb_hrdata) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hresp                   (iccm_ahb_hresp) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hreadyout               (iccm_ahb_hreadyout) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hrdata                  (dccm_ahb_hrdata) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hresp                   (dccm_ahb_hresp) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hreadyout               (dccm_ahb_hreadyout) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hrdata                  (mmio_ahb_hrdata) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hresp                   (mmio_ahb_hresp) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hreadyout               (mmio_ahb_hreadyout) //   > alb_mss_fab
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hexokay                 (iccm_ahb_hexokay) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .iccm_ahb_fatal_err               (iccm_ahb_fatal_err) //   > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hrespchk                (iccm_ahb_hrespchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hreadyoutchk            (iccm_ahb_hreadyoutchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .iccm_ahb_hrdatachk               (iccm_ahb_hrdatachk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hexokay                 (dccm_ahb_hexokay) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .dccm_ahb_fatal_err               (dccm_ahb_fatal_err) //   > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hrespchk                (dccm_ahb_hrespchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hreadyoutchk            (dccm_ahb_hreadyoutchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dccm_ahb_hrdatachk               (dccm_ahb_hrdatachk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hexokay                 (mmio_ahb_hexokay) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .mmio_ahb_fatal_err               (mmio_ahb_fatal_err) //   > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hrespchk                (mmio_ahb_hrespchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hreadyoutchk            (mmio_ahb_hreadyoutchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .mmio_ahb_hrdatachk               (mmio_ahb_hrdatachk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hmastlock            (dbu_per_ahb_hmastlock) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hauser               (dbu_per_ahb_hauser) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hauserchk            (dbu_per_ahb_hauserchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hctrlchk2            (dbu_per_ahb_hctrlchk2) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hwstrbchk            (dbu_per_ahb_hwstrbchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dbu_per_ahb_hwdatachk            (dbu_per_ahb_hwdatachk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .dbu_per_ahb_fatal_err            (dbu_per_ahb_fatal_err) //   > alb_mss_ext_stub
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hmastlock                    (ahb_hmastlock) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hauser                       (ahb_hauser) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hauserchk                    (ahb_hauserchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hctrlchk2                    (ahb_hctrlchk2) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hwstrbchk                    (ahb_hwstrbchk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block Topology_02
// spyglass disable_block RegInputOutput-ML
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .ahb_hwdatachk                    (ahb_hwdatachk) //   > alb_mss_ext_stub
// spyglass enable_block Topology_02
// spyglass enable_block RegInputOutput-ML
  , .ahb_fatal_err                    (ahb_fatal_err) //   > alb_mss_ext_stub
  , .wdt_reset_wdt_clk0               (wdt_reset_wdt_clk0) //   > alb_mss_ext_stub
  , .reg_wr_en0                       (reg_wr_en0) //   > alb_mss_ext_stub
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .critical_error                   (critical_error) //   > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
  , .ext_trig_output_valid            (ext_trig_output_valid) //   > alb_mss_ext_stub
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dmsi_rdy                         (dmsi_rdy)   //   > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .dmsi_rdy_chk                     (dmsi_rdy_chk) //   > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
  , .soft_reset_ready                 (soft_reset_ready) //   > alb_mss_ext_stub
  , .soft_reset_ack                   (soft_reset_ack) //   > alb_mss_ext_stub
  , .rst_cpu_ack                      (rst_cpu_ack) //   > alb_mss_ext_stub
  , .cpu_in_reset_state               (cpu_in_reset_state) //   > alb_mss_ext_stub
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .sys_sleep_r                      (sys_sleep_r) //   > io_pad_ring
// spyglass enable_block RegInputOutput-ML
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .sys_sleep_mode_r                 (sys_sleep_mode_r) //   > io_pad_ring
// spyglass enable_block RegInputOutput-ML
  );

// Instantiation of module cpu_safety_monitor
cpu_safety_monitor icpu_safety_monitor(
    .cpu_dr_mismatch_r                (i_cpu_dr_mismatch_r) // <   cpu_top_safety_controller
  , .cpu_dr_sfty_ctrl_parity_error    (i_cpu_dr_sfty_ctrl_parity_error) // <   cpu_top_safety_controller
  , .cpu_lsAsafety_comparator_enabled (i_cpu_lsAsafety_comparator_enabled) // <   cpu_top_safety_controller
  , .cpu_lsBsafety_comparator_enabled (i_cpu_lsBsafety_comparator_enabled) // <   cpu_top_safety_controller
  , .cpu_lsAls_lock_reset             (i_cpu_lsAls_lock_reset) // <   cpu_top_safety_controller
  , .cpu_dr_sfty_diag_inj_end         (i_cpu_dr_sfty_diag_inj_end) // <   cpu_top_safety_controller
  , .cpu_dr_mask_pty_err              (i_cpu_dr_mask_pty_err) // <   cpu_top_safety_controller
  , .lsc_diag_aux_r                   (i_lsc_diag_aux_r) // <   cpu_top_safety_controller
  , .sfty_nsi_r                       (i_sfty_nsi_r) // <   cpu_top_safety_controller
  , .dr_lsc_stl_ctrl_aux_r            (i_dr_lsc_stl_ctrl_aux_r) // <   cpu_top_safety_controller
  , .dr_sfty_aux_parity_err_r         (i_dr_sfty_aux_parity_err_r) // <   cpu_top_safety_controller
  , .dr_bus_fatal_err                 (i_dr_bus_fatal_err) // <   cpu_top_safety_controller
  , .dr_safety_iso_err                (i_dr_safety_iso_err) // <   cpu_top_safety_controller
  , .dr_secure_trig_iso_err           (i_dr_secure_trig_iso_err) // <   cpu_top_safety_controller
  , .sfty_mem_sbe_err                 (i_sfty_mem_sbe_err) // <   cpu_top_safety_controller
  , .sfty_mem_dbe_err                 (i_sfty_mem_dbe_err) // <   cpu_top_safety_controller
  , .sfty_mem_adr_err                 (i_sfty_mem_adr_err) // <   cpu_top_safety_controller
  , .sfty_mem_sbe_overflow            (i_sfty_mem_sbe_overflow) // <   cpu_top_safety_controller
  , .high_prio_ras                    (i_high_prio_ras) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_valid          (i_sfty_ibp_mmio_cmd_valid) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_cache          (i_sfty_ibp_mmio_cmd_cache) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_burst_size     (i_sfty_ibp_mmio_cmd_burst_size) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_read           (i_sfty_ibp_mmio_cmd_read) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_aux            (i_sfty_ibp_mmio_cmd_aux) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_addr           (i_sfty_ibp_mmio_cmd_addr) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_excl           (i_sfty_ibp_mmio_cmd_excl) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_atomic         (i_sfty_ibp_mmio_cmd_atomic) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_data_size      (i_sfty_ibp_mmio_cmd_data_size) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_prot           (i_sfty_ibp_mmio_cmd_prot) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_valid           (i_sfty_ibp_mmio_wr_valid) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_last            (i_sfty_ibp_mmio_wr_last) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_mask            (i_sfty_ibp_mmio_wr_mask) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_data            (i_sfty_ibp_mmio_wr_data) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_accept          (i_sfty_ibp_mmio_rd_accept) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_resp_accept     (i_sfty_ibp_mmio_wr_resp_accept) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_valid_pty      (i_sfty_ibp_mmio_cmd_valid_pty) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_addr_pty       (i_sfty_ibp_mmio_cmd_addr_pty) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_ctrl_pty       (i_sfty_ibp_mmio_cmd_ctrl_pty) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_valid_pty       (i_sfty_ibp_mmio_wr_valid_pty) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_last_pty        (i_sfty_ibp_mmio_wr_last_pty) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_accept_pty      (i_sfty_ibp_mmio_rd_accept_pty) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_resp_accept_pty (i_sfty_ibp_mmio_wr_resp_accept_pty) // <   cpu_top_safety_controller
  , .sfty_ibp_mmio_ini_e2e_err        (i_sfty_ibp_mmio_ini_e2e_err) // <   cpu_top_safety_controller
  , .sfty_dmsi_tgt_e2e_err            (i_sfty_dmsi_tgt_e2e_err) // <   cpu_top_safety_controller
  , .wdt_reset0                       (i_wdt_reset0) // <   cpu_top_safety_controller
  , .test_mode                        (test_mode)  // <   io_pad_ring
  , .cpu_clk_gated                    (i_cpu_clk_gated) // <   cpu_top_safety_controller
  , .cpu_rst_gated                    (i_cpu_rst_gated) // <   cpu_top_safety_controller
  , .dr_safety_comparator_enabled     (i_dr_safety_comparator_enabled) //   > cpu_top_safety_controller
  , .lsc_err_stat_aux                 (i_lsc_err_stat_aux) //   > cpu_top_safety_controller
  , .dr_sfty_eic                      (i_dr_sfty_eic) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_accept         (i_sfty_ibp_mmio_cmd_accept) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_accept          (i_sfty_ibp_mmio_wr_accept) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_valid           (i_sfty_ibp_mmio_rd_valid) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_err             (i_sfty_ibp_mmio_rd_err) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_excl_ok         (i_sfty_ibp_mmio_rd_excl_ok) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_last            (i_sfty_ibp_mmio_rd_last) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_data            (i_sfty_ibp_mmio_rd_data) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_done            (i_sfty_ibp_mmio_wr_done) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_excl_okay       (i_sfty_ibp_mmio_wr_excl_okay) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_err             (i_sfty_ibp_mmio_wr_err) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_cmd_accept_pty     (i_sfty_ibp_mmio_cmd_accept_pty) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_accept_pty      (i_sfty_ibp_mmio_wr_accept_pty) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_valid_pty       (i_sfty_ibp_mmio_rd_valid_pty) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_ctrl_pty        (i_sfty_ibp_mmio_rd_ctrl_pty) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_rd_data_pty        (i_sfty_ibp_mmio_rd_data_pty) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_done_pty        (i_sfty_ibp_mmio_wr_done_pty) //   > cpu_top_safety_controller
  , .sfty_ibp_mmio_wr_ctrl_pty        (i_sfty_ibp_mmio_wr_ctrl_pty) //   > cpu_top_safety_controller
  , .cpu_dr_sfty_diag_mode_sc         (i_cpu_dr_sfty_diag_mode_sc) //   > cpu_top_safety_controller
  , .safety_mem_dbe                   (safety_mem_dbe) //   > alb_mss_ext_stub
  , .safety_mem_sbe                   (safety_mem_sbe) //   > alb_mss_ext_stub
  , .safety_error                     (safety_error) //   > alb_mss_ext_stub
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  , .safety_enabled                   (safety_enabled) //   > alb_mss_ext_stub
// spyglass enable_block RegInputOutput-ML
  );

// Back-substitution of module rl_srams_instances

// Instantiation esrams_rl_srams of module rl_srams
rl_srams iesrams_rl_srams(
    .iccm0_clk               (i_esrams_iccm0_clk)    // <   cpu_top_safety_controller
  , .iccm0_din               (i_esrams_iccm0_din)    // <   cpu_top_safety_controller
  , .iccm0_addr              (i_esrams_iccm0_addr)   // <   cpu_top_safety_controller
  , .iccm0_cs                (i_esrams_iccm0_cs)     // <   cpu_top_safety_controller
  , .iccm0_we                (i_esrams_iccm0_we)     // <   cpu_top_safety_controller
  , .iccm0_wem               (i_esrams_iccm0_wem)    // <   cpu_top_safety_controller
  , .dccm_even_clk           (i_esrams_dccm_even_clk) // <   cpu_top_safety_controller
  , .dccm_din_even           (i_esrams_dccm_din_even) // <   cpu_top_safety_controller
  , .dccm_addr_even          (i_esrams_dccm_addr_even) // <   cpu_top_safety_controller
  , .dccm_cs_even            (i_esrams_dccm_cs_even) // <   cpu_top_safety_controller
  , .dccm_we_even            (i_esrams_dccm_we_even) // <   cpu_top_safety_controller
  , .dccm_wem_even           (i_esrams_dccm_wem_even) // <   cpu_top_safety_controller
  , .dccm_odd_clk            (i_esrams_dccm_odd_clk) // <   cpu_top_safety_controller
  , .dccm_din_odd            (i_esrams_dccm_din_odd) // <   cpu_top_safety_controller
  , .dccm_addr_odd           (i_esrams_dccm_addr_odd) // <   cpu_top_safety_controller
  , .dccm_cs_odd             (i_esrams_dccm_cs_odd)  // <   cpu_top_safety_controller
  , .dccm_we_odd             (i_esrams_dccm_we_odd)  // <   cpu_top_safety_controller
  , .dccm_wem_odd            (i_esrams_dccm_wem_odd) // <   cpu_top_safety_controller
  , .ic_tag_mem_clk          (i_esrams_ic_tag_mem_clk) // <   cpu_top_safety_controller
  , .ic_tag_mem_din          (i_esrams_ic_tag_mem_din) // <   cpu_top_safety_controller
  , .ic_tag_mem_addr         (i_esrams_ic_tag_mem_addr) // <   cpu_top_safety_controller
  , .ic_tag_mem_cs           (i_esrams_ic_tag_mem_cs) // <   cpu_top_safety_controller
  , .ic_tag_mem_we           (i_esrams_ic_tag_mem_we) // <   cpu_top_safety_controller
  , .ic_tag_mem_wem          (i_esrams_ic_tag_mem_wem) // <   cpu_top_safety_controller
  , .ic_data_mem_clk         (i_esrams_ic_data_mem_clk) // <   cpu_top_safety_controller
  , .ic_data_mem_din         (i_esrams_ic_data_mem_din) // <   cpu_top_safety_controller
  , .ic_data_mem_addr        (i_esrams_ic_data_mem_addr) // <   cpu_top_safety_controller
  , .ic_data_mem_cs          (i_esrams_ic_data_mem_cs) // <   cpu_top_safety_controller
  , .ic_data_mem_we          (i_esrams_ic_data_mem_we) // <   cpu_top_safety_controller
  , .ic_data_mem_wem         (i_esrams_ic_data_mem_wem) // <   cpu_top_safety_controller
  , .test_mode               (test_mode)           // <   io_pad_ring
  , .clk                     (i_esrams_clk)          // <   cpu_top_safety_controller
  , .ls                      (i_esrams_ls)           // <   cpu_top_safety_controller
  , .iccm0_dout              (i_esrams_iccm0_dout)   //   > cpu_top_safety_controller
  , .dccm_dout_even          (i_esrams_dccm_dout_even) //   > cpu_top_safety_controller
  , .dccm_dout_odd           (i_esrams_dccm_dout_odd) //   > cpu_top_safety_controller
  , .ic_tag_mem_dout         (i_esrams_ic_tag_mem_dout) //   > cpu_top_safety_controller
  , .ic_data_mem_dout        (i_esrams_ic_data_mem_dout) //   > cpu_top_safety_controller
  );

// Output drives
assign sys_halt_r = i_sys_halt_r;
assign high_prio_ras = i_high_prio_ras;
assign wdt_reset0 = i_wdt_reset0;
endmodule
