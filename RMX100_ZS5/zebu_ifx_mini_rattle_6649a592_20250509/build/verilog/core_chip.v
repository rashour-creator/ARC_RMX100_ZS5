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
`include "alb_mss_fab_defines.v"
`include "alb_mss_clkctrl_defines.v"
`include "alb_mss_perfctrl_defines.v"
`include "alb_mss_mem_defines.v"
`include "zebu_axi_xtor_defines.v"
`include "dw_dbp_defines.v"
`include "rv_safety_defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"

module core_chip(
    input  eclk                          //  <   clock_and_reset
  , input  erst_n                        //  <   clock_and_reset
  , input  ejtag_tck                     //  <   rascal2jtag
  , input  ejtag_trst_n                  //  <   rascal2jtag
  , input  ejtag_tms                     //  <   rascal2jtag
  , input  ejtag_tdi                     //  <   rascal2jtag
  , output ejtag_tdo                     //    > rascal2jtag
  , output sys_halt_r                    //    > rascal2jtag
  , output rst_a                         //    > rascal2jtag
  , output clk                           //    > rascal_pipemon
  , output en                            //    > outside-of-hierarchy
  );

// Intermediate signals:
wire   i_clk;                            // core_sys > io_pad_ring -- core_sys.alb_mss_clkctrl.clk
wire   i_arc_halt_ack;                   // core_sys > io_pad_ring -- core_sys.archipelago.arcv_dm_top.arc_halt_ack
wire   i_arc_run_ack;                    // core_sys > io_pad_ring -- core_sys.archipelago.arcv_dm_top.arc_run_ack
wire   i_sys_halt_r;                     // core_sys > io_pad_ring -- core_sys.archipelago.cpu_top_safety_controller.sys_halt_r
wire   i_sys_sleep_r;                    // core_sys > io_pad_ring -- core_sys.archipelago.cpu_top_safety_controller.sys_sleep_r
wire   [2:0] i_sys_sleep_mode_r;         // core_sys > io_pad_ring -- core_sys.archipelago.cpu_top_safety_controller.sys_sleep_mode_r [2:0]
wire   i_jtag_tdo;                       // core_sys > io_pad_ring -- core_sys.archipelago.dw_dbp.jtag_tdo
wire   i_jtag_tdo_oe;                    // core_sys > io_pad_ring -- core_sys.archipelago.dw_dbp.jtag_tdo_oe
wire   i_rst_a;                          // io_pad_ring > core_sys -- io_pad_ring.rst_a
wire   i_ref_clk;                        // io_pad_ring > core_sys -- io_pad_ring.ref_clk
wire   i_arc_halt_req_a;                 // io_pad_ring > core_sys -- io_pad_ring.arc_halt_req_a
wire   i_arc_run_req_a;                  // io_pad_ring > core_sys -- io_pad_ring.arc_run_req_a
wire   i_test_mode;                      // io_pad_ring > core_sys -- io_pad_ring.test_mode
wire   i_jtag_tck;                       // io_pad_ring > core_sys -- io_pad_ring.jtag_tck
wire   i_jtag_trst_n;                    // io_pad_ring > core_sys -- io_pad_ring.jtag_trst_n
wire   i_jtag_tdi;                       // io_pad_ring > core_sys -- io_pad_ring.jtag_tdi
wire   i_jtag_tms;                       // io_pad_ring > core_sys -- io_pad_ring.jtag_tms
wire   [7:0] i_arcnum;                   // io_pad_ring > core_sys -- io_pad_ring.arcnum [7:0]
wire   i_orst_n;                         // io_pad_ring > unconnected -- io_pad_ring.orst_n
wire   i_arc_wake_evt_a;                 // io_pad_ring > unconnected -- io_pad_ring.arc_wake_evt_a
wire   i_ref_clk2;                       // io_pad_ring > unconnected -- io_pad_ring.ref_clk2

// Instantiation of module io_pad_ring
io_pad_ring iio_pad_ring(
    .eclk             (eclk)                       // <   clock_and_reset
  , .erst_n           (erst_n)                     // <   clock_and_reset
  , .clk              (i_clk)                      // <   core_sys.alb_mss_clkctrl
  , .arc_halt_ack     (i_arc_halt_ack)             // <   core_sys.archipelago.arcv_dm_top
  , .arc_run_ack      (i_arc_run_ack)              // <   core_sys.archipelago.arcv_dm_top
  , .sys_halt_r       (i_sys_halt_r)               // <   core_sys.archipelago.cpu_top_safety_controller
  , .sys_sleep_r      (i_sys_sleep_r)              // <   core_sys.archipelago.cpu_top_safety_controller
  , .sys_sleep_mode_r (i_sys_sleep_mode_r)         // <   core_sys.archipelago.cpu_top_safety_controller
  , .ejtag_tck        (ejtag_tck)                  // <   rascal2jtag
  , .ejtag_trst_n     (ejtag_trst_n)               // <   rascal2jtag
  , .ejtag_tms        (ejtag_tms)                  // <   rascal2jtag
  , .ejtag_tdi        (ejtag_tdi)                  // <   rascal2jtag
  , .jtag_tdo         (i_jtag_tdo)                 // <   core_sys.archipelago.dw_dbp
  , .jtag_tdo_oe      (i_jtag_tdo_oe)              // <   core_sys.archipelago.dw_dbp
  , .rst_a            (i_rst_a)                    //   > core_sys
  , .ref_clk          (i_ref_clk)                  //   > core_sys
  , .arc_halt_req_a   (i_arc_halt_req_a)           //   > core_sys
  , .arc_run_req_a    (i_arc_run_req_a)            //   > core_sys
  , .test_mode        (i_test_mode)                //   > core_sys
  , .jtag_tck         (i_jtag_tck)                 //   > core_sys
  , .jtag_trst_n      (i_jtag_trst_n)              //   > core_sys
  , .jtag_tdi         (i_jtag_tdi)                 //   > core_sys
  , .jtag_tms         (i_jtag_tms)                 //   > core_sys
  , .arcnum           (i_arcnum)                   //   > core_sys
  , .orst_n           ()                           //   > unconnected i_orst_n
  , .arc_wake_evt_a   ()                           //   > unconnected i_arc_wake_evt_a
  , .ref_clk2         ()                           //   > unconnected i_ref_clk2
  , .ejtag_tdo        (ejtag_tdo)                  //   > rascal2jtag
  , .en               (en)                         //   > outside-of-hierarchy
  );

// Instantiation of module core_sys
core_sys icore_sys(
    .rst_a            (i_rst_a)                    // <   io_pad_ring
  , .ref_clk          (i_ref_clk)                  // <   io_pad_ring
  , .arc_halt_req_a   (i_arc_halt_req_a)           // <   io_pad_ring
  , .arc_run_req_a    (i_arc_run_req_a)            // <   io_pad_ring
  , .test_mode        (i_test_mode)                // <   io_pad_ring
  , .jtag_tck         (i_jtag_tck)                 // <   io_pad_ring
  , .jtag_trst_n      (i_jtag_trst_n)              // <   io_pad_ring
  , .jtag_tdi         (i_jtag_tdi)                 // <   io_pad_ring
  , .jtag_tms         (i_jtag_tms)                 // <   io_pad_ring
  , .arcnum           (i_arcnum)                   // <   io_pad_ring
  , .clk              (i_clk)                      //   > io_pad_ring
  , .arc_halt_ack     (i_arc_halt_ack)             //   > io_pad_ring
  , .arc_run_ack      (i_arc_run_ack)              //   > io_pad_ring
  , .sys_halt_r       (i_sys_halt_r)               //   > io_pad_ring
  , .sys_sleep_r      (i_sys_sleep_r)              //   > io_pad_ring
  , .sys_sleep_mode_r (i_sys_sleep_mode_r)         //   > io_pad_ring
  , .jtag_tdo         (i_jtag_tdo)                 //   > io_pad_ring
  , .jtag_tdo_oe      (i_jtag_tdo_oe)              //   > io_pad_ring
  );

// Output drives
assign rst_a = i_rst_a;
assign clk = i_clk;
assign sys_halt_r = i_sys_halt_r;
endmodule
