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

module board(
    output en                            //    > outside-of-hierarchy
  );

// Intermediate signals:
wire   i_eclk;                           // clock_and_reset > core_chip -- clock_and_reset.eclk
wire   i_erst_n;                         // clock_and_reset > core_chip -- clock_and_reset.erst_n
wire   i_ejtag_tck;                      // rascal2jtag > core_chip -- rascal2jtag.ejtag_tck
wire   i_ejtag_trst_n;                   // rascal2jtag > core_chip -- rascal2jtag.ejtag_trst_n
wire   i_ejtag_tms;                      // rascal2jtag > core_chip -- rascal2jtag.ejtag_tms
wire   i_ejtag_tdi;                      // rascal2jtag > core_chip -- rascal2jtag.ejtag_tdi
wire   i_ejtag_tdo;                      // core_chip > rascal2jtag -- core_chip.io_pad_ring.ejtag_tdo
wire   i_sys_halt_r;                     // core_chip > rascal2jtag -- core_chip.core_sys.archipelago.cpu_top_safety_controller.sys_halt_r
wire   i_rst_a;                          // core_chip > rascal2jtag -- core_chip.io_pad_ring.rst_a
wire   i_clk;                            // core_chip > rascal_pipemon -- core_chip.core_sys.alb_mss_clkctrl.clk
wire   i_eclk2;                          // clock_and_reset > unconnected -- clock_and_reset.eclk2
wire   [31:0] i_cycle;                   // clock_and_reset > unconnected -- clock_and_reset.cycle [31:0]

// Instantiation of module core_chip
core_chip icore_chip(
    .eclk         (i_eclk)                         // <   clock_and_reset
  , .erst_n       (i_erst_n)                       // <   clock_and_reset
  , .ejtag_tck    (i_ejtag_tck)                    // <   rascal2jtag
  , .ejtag_trst_n (i_ejtag_trst_n)                 // <   rascal2jtag
  , .ejtag_tms    (i_ejtag_tms)                    // <   rascal2jtag
  , .ejtag_tdi    (i_ejtag_tdi)                    // <   rascal2jtag
  , .ejtag_tdo    (i_ejtag_tdo)                    //   > rascal2jtag
  , .sys_halt_r   (i_sys_halt_r)                   //   > rascal2jtag
  , .rst_a        (i_rst_a)                        //   > rascal2jtag
  , .clk          (i_clk)                          //   > rascal_pipemon
  , .en           (en)                             //   > outside-of-hierarchy
  );

// Instantiation of module clock_and_reset
clock_and_reset iclock_and_reset(
    .eclk      (i_eclk)                            //   > core_chip
  , .erst_n    (i_erst_n)                          //   > core_chip
  , .eclk2     ()                                  //   > unconnected i_eclk2
  , .cycle     ()                                  //   > unconnected i_cycle
  );

// Instantiation of module rascal2jtag
rascal2jtag irascal2jtag(
    .ejtag_tdo    (i_ejtag_tdo)                    // <   core_chip.io_pad_ring
  , .sys_halt_r   (i_sys_halt_r)                   // <   core_chip.core_sys.archipelago.cpu_top_safety_controller
  , .rst_a        (i_rst_a)                        // <   core_chip.io_pad_ring
  , .clk          (i_clk)                          // <   core_chip.core_sys.alb_mss_clkctrl
  , .ejtag_tck    (i_ejtag_tck)                    //   > core_chip
  , .ejtag_trst_n (i_ejtag_trst_n)                 //   > core_chip
  , .ejtag_tms    (i_ejtag_tms)                    //   > core_chip
  , .ejtag_tdi    (i_ejtag_tdi)                    //   > core_chip
  );

// Instantiation of module rascal_pipemon
rascal_pipemon irascal_pipemon(
    .clk       (i_clk)                             // <   core_chip.core_sys.alb_mss_clkctrl
  );
endmodule
