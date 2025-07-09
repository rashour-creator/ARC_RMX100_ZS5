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
`include "alb_mss_dummy_slave_defines.v"
`include "alb_mss_perfctrl_defines.v"
`include "alb_mss_mem_defines.v"
`include "zebu_axi_xtor_defines.v"
`include "dw_dbp_defines.v"
`include "rv_safety_defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"

module core_sys(
    input  rst_a                         //  <   io_pad_ring
  , input  ref_clk                       //  <   io_pad_ring
  , input  arc_halt_req_a                //  <   io_pad_ring
  , input  arc_run_req_a                 //  <   io_pad_ring
  , input  test_mode                     //  <   io_pad_ring
  , input  jtag_tck                      //  <   io_pad_ring
  , input  jtag_trst_n                   //  <   io_pad_ring
  , input  jtag_tdi                      //  <   io_pad_ring
  , input  jtag_tms                      //  <   io_pad_ring
  , input  [7:0] arcnum /* verilator public_flat */ //  <   io_pad_ring
  , output clk                           //    > io_pad_ring
  , output arc_halt_ack                  //    > io_pad_ring
  , output arc_run_ack                   //    > io_pad_ring
  , output sys_halt_r                    //    > io_pad_ring
  , output sys_sleep_r                   //    > io_pad_ring
  , output [2:0] sys_sleep_mode_r        //    > io_pad_ring
  , output jtag_tdo                      //    > io_pad_ring
  , output jtag_tdo_oe                   //    > io_pad_ring
  );

// Intermediate signals:
wire   [1:0] i_ahb_htrans;               // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_htrans [1:0]
wire   i_ahb_hwrite;                     // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_hwrite
wire   [31:0] i_ahb_haddr;               // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_haddr [31:0]
wire   [2:0] i_ahb_hsize;                // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_hsize [2:0]
wire   [2:0] i_ahb_hburst;               // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_hburst [2:0]
wire   [6:0] i_ahb_hprot;                // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_hprot [6:0]
wire   i_ahb_hnonsec;                    // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_hnonsec
wire   i_ahb_hexcl;                      // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hexcl
wire   [3:0] i_ahb_hmaster;              // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hmaster [3:0]
wire   [31:0] i_ahb_hwdata;              // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_hwdata [31:0]
wire   [3:0] i_ahb_hwstrb;               // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.ahb_hwstrb [3:0]
wire   [3:0] i_ahb_haddrchk;             // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_haddrchk [3:0]
wire   i_ahb_htranschk;                  // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_htranschk
wire   i_ahb_hctrlchk1;                  // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hctrlchk1
wire   i_ahb_hprotchk;                   // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hprotchk
wire   [1:0] i_dbu_per_ahb_htrans;       // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_htrans [1:0]
wire   i_dbu_per_ahb_hwrite;             // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hwrite
wire   [31:0] i_dbu_per_ahb_haddr;       // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_haddr [31:0]
wire   [2:0] i_dbu_per_ahb_hsize;        // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hsize [2:0]
wire   [2:0] i_dbu_per_ahb_hburst;       // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hburst [2:0]
wire   [6:0] i_dbu_per_ahb_hprot;        // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hprot [6:0]
wire   i_dbu_per_ahb_hnonsec;            // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hnonsec
wire   i_dbu_per_ahb_hexcl;              // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hexcl
wire   [3:0] i_dbu_per_ahb_hmaster;      // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hmaster [3:0]
wire   [31:0] i_dbu_per_ahb_hwdata;      // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hwdata [31:0]
wire   [3:0] i_dbu_per_ahb_hwstrb;       // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hwstrb [3:0]
wire   [3:0] i_dbu_per_ahb_haddrchk;     // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_haddrchk [3:0]
wire   i_dbu_per_ahb_htranschk;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_htranschk
wire   i_dbu_per_ahb_hctrlchk1;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hctrlchk1
wire   i_dbu_per_ahb_hprotchk;           // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hprotchk
wire   [3:0] i_bri_arid;                 // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_arid [3:0]
wire   i_bri_arvalid;                    // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_arvalid
wire   [31:0] i_bri_araddr;              // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_araddr [31:0]
wire   [1:0] i_bri_arburst;              // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_arburst [1:0]
wire   [2:0] i_bri_arsize;               // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_arsize [2:0]
wire   [3:0] i_bri_arlen;                // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_arlen [3:0]
wire   [3:0] i_bri_arcache;              // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_arcache [3:0]
wire   [2:0] i_bri_arprot;               // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_arprot [2:0]
wire   i_bri_rready;                     // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_rready
wire   [3:0] i_bri_awid;                 // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awid [3:0]
wire   i_bri_awvalid;                    // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awvalid
wire   [31:0] i_bri_awaddr;              // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awaddr [31:0]
wire   [1:0] i_bri_awburst;              // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awburst [1:0]
wire   [2:0] i_bri_awsize;               // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awsize [2:0]
wire   [3:0] i_bri_awlen;                // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awlen [3:0]
wire   [3:0] i_bri_awcache;              // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awcache [3:0]
wire   [2:0] i_bri_awprot;               // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_awprot [2:0]
wire   [3:0] i_bri_wid;                  // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_wid [3:0]
wire   i_bri_wvalid;                     // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_wvalid
wire   [31:0] i_bri_wdata;               // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_wdata [31:0]
wire   [3:0] i_bri_wstrb;                // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_wstrb [3:0]
wire   i_bri_wlast;                      // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_wlast
wire   i_bri_bready;                     // archipelago > alb_mss_fab -- archipelago.dw_dbp.bri_bready
wire   [`AXI_ID_WIDTH-1:0] i_xtor_axi_arid; // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_arid [`AXI_ID_WIDTH-1:0]
wire   i_xtor_axi_arvalid;               // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_arvalid
wire   [`AXI_ADDR_WIDTH-1:0] i_xtor_axi_araddr; // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_araddr [`AXI_ADDR_WIDTH-1:0]
wire   [1:0] i_xtor_axi_arburst;         // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_arburst [1:0]
wire   [2:0] i_xtor_axi_arsize;          // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_arsize [2:0]
wire   [`AXI_BLEN_WIDTH-1:0] i_xtor_axi_arlen; // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_arlen [`AXI_BLEN_WIDTH-1:0]
wire   [3:0] i_xtor_axi_arcache;         // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_arcache [3:0]
wire   [2:0] i_xtor_axi_arprot;          // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_arprot [2:0]
wire   i_xtor_axi_rready;                // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_rready
wire   [`AXI_ID_WIDTH-1:0] i_xtor_axi_awid; // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awid [`AXI_ID_WIDTH-1:0]
wire   i_xtor_axi_awvalid;               // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awvalid
wire   [`AXI_ADDR_WIDTH-1:0] i_xtor_axi_awaddr; // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awaddr [`AXI_ADDR_WIDTH-1:0]
wire   [1:0] i_xtor_axi_awburst;         // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awburst [1:0]
wire   [2:0] i_xtor_axi_awsize;          // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awsize [2:0]
wire   [3:0] i_xtor_axi_awlen;           // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awlen [3:0]
wire   [3:0] i_xtor_axi_awcache;         // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awcache [3:0]
wire   [2:0] i_xtor_axi_awprot;          // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_awprot [2:0]
wire   [3:0] i_xtor_axi_wid;             // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_wid [3:0]
wire   i_xtor_axi_wvalid;                // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_wvalid
wire   [`AXI_DATA_WIDTH-1:0] i_xtor_axi_wdata; // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_wdata [`AXI_DATA_WIDTH-1:0]
wire   [`AXI_DATA_WIDTH/8-1:0] i_xtor_axi_wstrb; // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_wstrb [`AXI_DATA_WIDTH/8-1:0]
wire   i_xtor_axi_wlast;                 // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_wlast
wire   i_xtor_axi_bready;                // zebu_axi_xtor > alb_mss_fab -- zebu_axi_xtor.xtor_axi_bready
wire   [31:0] i_iccm_ahb_hrdata;         // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.iccm_ahb_hrdata [31:0]
wire   i_iccm_ahb_hresp;                 // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.iccm_ahb_hresp
wire   i_iccm_ahb_hreadyout;             // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.iccm_ahb_hreadyout
wire   [31:0] i_dccm_ahb_hrdata;         // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dccm_ahb_hrdata [31:0]
wire   i_dccm_ahb_hresp;                 // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dccm_ahb_hresp
wire   i_dccm_ahb_hreadyout;             // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.dccm_ahb_hreadyout
wire   [31:0] i_mmio_ahb_hrdata;         // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.mmio_ahb_hrdata [31:0]
wire   i_mmio_ahb_hresp;                 // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.mmio_ahb_hresp
wire   i_mmio_ahb_hreadyout;             // archipelago > alb_mss_fab -- archipelago.cpu_top_safety_controller.mmio_ahb_hreadyout
wire   [31:0] i_mss_clkctrl_rdata;       // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_clkctrl_rdata [31:0]
wire   i_mss_clkctrl_slverr;             // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_clkctrl_slverr
wire   i_mss_clkctrl_ready;              // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_clkctrl_ready
wire   [31:0] i_dslv1_rdata;             // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv1_rdata [31:0]
wire   i_dslv1_slverr;                   // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv1_slverr
wire   i_dslv1_ready;                    // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv1_ready
wire   i_dslv2_arready;                  // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_arready
wire   [16-1:0] i_dslv2_rid;             // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_rid [16-1:0]
wire   i_dslv2_rvalid;                   // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_rvalid
wire   [64-1:0] i_dslv2_rdata;           // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_rdata [64-1:0]
wire   [1:0] i_dslv2_rresp;              // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_rresp [1:0]
wire   i_dslv2_rlast;                    // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_rlast
wire   i_dslv2_awready;                  // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_awready
wire   i_dslv2_wready;                   // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_wready
wire   [16-1:0] i_dslv2_bid;             // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_bid [16-1:0]
wire   i_dslv2_bvalid;                   // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_bvalid
wire   [1:0] i_dslv2_bresp;              // alb_mss_dummy_slave > alb_mss_fab -- alb_mss_dummy_slave.dslv2_bresp [1:0]
wire   [31:0] i_mss_perfctrl_rdata;      // alb_mss_perfctrl > alb_mss_fab -- alb_mss_perfctrl.mss_perfctrl_rdata [31:0]
wire   i_mss_perfctrl_slverr;            // alb_mss_perfctrl > alb_mss_fab -- alb_mss_perfctrl.mss_perfctrl_slverr
wire   i_mss_perfctrl_ready;             // alb_mss_perfctrl > alb_mss_fab -- alb_mss_perfctrl.mss_perfctrl_ready
wire   i_mss_mem_cmd_accept;             // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_cmd_accept
wire   i_mss_mem_rd_valid;               // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_rd_valid
wire   i_mss_mem_rd_excl_ok;             // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_rd_excl_ok
wire   [128-1:0] i_mss_mem_rd_data;      // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_rd_data [128-1:0]
wire   i_mss_mem_err_rd;                 // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_err_rd
wire   i_mss_mem_rd_last;                // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_rd_last
wire   i_mss_mem_wr_accept;              // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_wr_accept
wire   i_mss_mem_wr_done;                // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_wr_done
wire   i_mss_mem_wr_excl_done;           // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_wr_excl_done
wire   i_mss_mem_err_wr;                 // alb_mss_mem > alb_mss_fab -- alb_mss_mem.mss_mem_err_wr
wire   [4*12-1:0] i_mss_fab_cfg_lat_w;   // alb_mss_perfctrl > alb_mss_fab -- alb_mss_perfctrl.mss_fab_cfg_lat_w [4*12-1:0]
wire   [4*12-1:0] i_mss_fab_cfg_lat_r;   // alb_mss_perfctrl > alb_mss_fab -- alb_mss_perfctrl.mss_fab_cfg_lat_r [4*12-1:0]
wire   [4*10-1:0] i_mss_fab_cfg_wr_bw;   // alb_mss_perfctrl > alb_mss_fab -- alb_mss_perfctrl.mss_fab_cfg_wr_bw [4*10-1:0]
wire   [4*10-1:0] i_mss_fab_cfg_rd_bw;   // alb_mss_perfctrl > alb_mss_fab -- alb_mss_perfctrl.mss_fab_cfg_rd_bw [4*10-1:0]
wire   i_clk;                            // alb_mss_clkctrl > archipelago -- alb_mss_clkctrl.clk
wire   i_mss_clk;                        // alb_mss_clkctrl > zebu_axi_xtor -- alb_mss_clkctrl.mss_clk
wire   i_iccm_ahb_clk_en;                // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.iccm_ahb_clk_en
wire   i_dccm_ahb_clk_en;                // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.dccm_ahb_clk_en
wire   i_mmio_ahb_clk_en;                // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mmio_ahb_clk_en
wire   i_mss_fab_mst0_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_mst0_clk_en
wire   i_mss_fab_mst1_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_mst1_clk_en
wire   i_mss_fab_mst2_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_mst2_clk_en
wire   i_mss_fab_mst3_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_mst3_clk_en
wire   i_mss_fab_slv0_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv0_clk_en
wire   i_mss_fab_slv1_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv1_clk_en
wire   i_mss_fab_slv2_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv2_clk_en
wire   i_mss_fab_slv3_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv3_clk_en
wire   i_mss_fab_slv4_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv4_clk_en
wire   i_mss_fab_slv5_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv5_clk_en
wire   i_mss_fab_slv6_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv6_clk_en
wire   i_mss_fab_slv7_clk_en;            // alb_mss_clkctrl > alb_mss_fab -- alb_mss_clkctrl.mss_fab_slv7_clk_en
wire   i_rst_b;                          // alb_mss_clkctrl > alb_mss_mem -- alb_mss_clkctrl.rst_b
wire   [1-1:0] i_mss_clkctrl_sel;        // alb_mss_fab > alb_mss_clkctrl -- alb_mss_fab.mss_clkctrl_sel [1-1:0]
wire   i_mss_clkctrl_enable;             // alb_mss_fab > alb_mss_clkctrl -- alb_mss_fab.mss_clkctrl_enable
wire   i_mss_clkctrl_write;              // alb_mss_fab > alb_mss_clkctrl -- alb_mss_fab.mss_clkctrl_write
wire   [12-1:2] i_mss_clkctrl_addr;      // alb_mss_fab > alb_mss_clkctrl -- alb_mss_fab.mss_clkctrl_addr [12-1:2]
wire   [31:0] i_mss_clkctrl_wdata;       // alb_mss_fab > alb_mss_clkctrl -- alb_mss_fab.mss_clkctrl_wdata [31:0]
wire   [3:0] i_mss_clkctrl_wstrb;        // alb_mss_fab > alb_mss_clkctrl -- alb_mss_fab.mss_clkctrl_wstrb [3:0]
wire   [1-1:0] i_dslv1_sel;              // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv1_sel [1-1:0]
wire   i_dslv1_enable;                   // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv1_enable
wire   i_dslv1_write;                    // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv1_write
wire   [12-1:2] i_dslv1_addr;            // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv1_addr [12-1:2]
wire   [31:0] i_dslv1_wdata;             // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv1_wdata [31:0]
wire   [3:0] i_dslv1_wstrb;              // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv1_wstrb [3:0]
wire   i_dslv2_arvalid;                  // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_arvalid
wire   [24-1:0] i_dslv2_araddr;          // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_araddr [24-1:0]
wire   [1:0] i_dslv2_arburst;            // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_arburst [1:0]
wire   [2:0] i_dslv2_arsize;             // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_arsize [2:0]
wire   [3:0] i_dslv2_arlen;              // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_arlen [3:0]
wire   [16-1:0] i_dslv2_arid;            // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_arid [16-1:0]
wire   i_dslv2_rready;                   // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_rready
wire   i_dslv2_awvalid;                  // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_awvalid
wire   [24-1:0] i_dslv2_awaddr;          // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_awaddr [24-1:0]
wire   [1:0] i_dslv2_awburst;            // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_awburst [1:0]
wire   [2:0] i_dslv2_awsize;             // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_awsize [2:0]
wire   [3:0] i_dslv2_awlen;              // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_awlen [3:0]
wire   [16-1:0] i_dslv2_awid;            // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_awid [16-1:0]
wire   i_dslv2_wvalid;                   // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_wvalid
wire   [64-1:0] i_dslv2_wdata;           // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_wdata [64-1:0]
wire   [64/8-1:0] i_dslv2_wstrb;         // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_wstrb [64/8-1:0]
wire   i_dslv2_wlast;                    // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_wlast
wire   i_dslv2_bready;                   // alb_mss_fab > alb_mss_dummy_slave -- alb_mss_fab.dslv2_bready
wire   [1-1:0] i_mss_perfctrl_sel;       // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_perfctrl_sel [1-1:0]
wire   i_mss_perfctrl_enable;            // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_perfctrl_enable
wire   i_mss_perfctrl_write;             // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_perfctrl_write
wire   [13-1:2] i_mss_perfctrl_addr;     // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_perfctrl_addr [13-1:2]
wire   [31:0] i_mss_perfctrl_wdata;      // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_perfctrl_wdata [31:0]
wire   [3:0] i_mss_perfctrl_wstrb;       // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_perfctrl_wstrb [3:0]
wire   [4-1:0] i_mss_fab_perf_awf;       // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_awf [4-1:0]
wire   [4-1:0] i_mss_fab_perf_arf;       // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_arf [4-1:0]
wire   [4-1:0] i_mss_fab_perf_aw;        // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_aw [4-1:0]
wire   [4-1:0] i_mss_fab_perf_ar;        // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_ar [4-1:0]
wire   [4-1:0] i_mss_fab_perf_w;         // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_w [4-1:0]
wire   [4-1:0] i_mss_fab_perf_wl;        // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_wl [4-1:0]
wire   [4-1:0] i_mss_fab_perf_r;         // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_r [4-1:0]
wire   [4-1:0] i_mss_fab_perf_rl;        // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_rl [4-1:0]
wire   [4-1:0] i_mss_fab_perf_b;         // alb_mss_fab > alb_mss_perfctrl -- alb_mss_fab.mss_fab_perf_b [4-1:0]
wire   i_mss_mem_cmd_valid;              // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_valid
wire   i_mss_mem_cmd_read;               // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_read
wire   [32-1:0] i_mss_mem_cmd_addr;      // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_addr [32-1:0]
wire   i_mss_mem_cmd_wrap;               // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_wrap
wire   [2:0] i_mss_mem_cmd_data_size;    // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_data_size [2:0]
wire   [3:0] i_mss_mem_cmd_burst_size;   // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_burst_size [3:0]
wire   i_mss_mem_cmd_lock;               // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_lock
wire   i_mss_mem_cmd_excl;               // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_excl
wire   [1:0] i_mss_mem_cmd_prot;         // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_prot [1:0]
wire   [3:0] i_mss_mem_cmd_cache;        // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_cache [3:0]
wire   [6-1:0] i_mss_mem_cmd_id;         // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_id [6-1:0]
wire   [4-1:0] i_mss_mem_cmd_user;       // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_user [4-1:0]
wire   [1-1:0] i_mss_mem_cmd_region;     // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_cmd_region [1-1:0]
wire   i_mss_mem_rd_accept;              // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_rd_accept
wire   i_mss_mem_wr_valid;               // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_wr_valid
wire   [128-1:0] i_mss_mem_wr_data;      // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_wr_data [128-1:0]
wire   [128/8-1:0] i_mss_mem_wr_mask;    // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_wr_mask [128/8-1:0]
wire   i_mss_mem_wr_last;                // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_wr_last
wire   i_mss_mem_wr_resp_accept;         // alb_mss_fab > alb_mss_mem -- alb_mss_fab.mss_mem_wr_resp_accept
wire   i_xtor_axi_awready;               // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_awready
wire   i_xtor_axi_wready;                // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_wready
wire   [4-1:0] i_xtor_axi_bid;           // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_bid [4-1:0]
wire   [1:0] i_xtor_axi_bresp;           // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_bresp [1:0]
wire   i_xtor_axi_bvalid;                // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_bvalid
wire   i_xtor_axi_arready;               // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_arready
wire   [4-1:0] i_xtor_axi_rid;           // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_rid [4-1:0]
wire   [512-1:0] i_xtor_axi_rdata;       // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_rdata [512-1:0]
wire   [1:0] i_xtor_axi_rresp;           // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_rresp [1:0]
wire   i_xtor_axi_rlast;                 // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_rlast
wire   i_xtor_axi_rvalid;                // alb_mss_fab > zebu_axi_xtor -- alb_mss_fab.xtor_axi_rvalid
wire   i_bri_awready;                    // alb_mss_fab > archipelago -- alb_mss_fab.bri_awready
wire   i_bri_wready;                     // alb_mss_fab > archipelago -- alb_mss_fab.bri_wready
wire   [4-1:0] i_bri_bid;                // alb_mss_fab > archipelago -- alb_mss_fab.bri_bid [4-1:0]
wire   [1:0] i_bri_bresp;                // alb_mss_fab > archipelago -- alb_mss_fab.bri_bresp [1:0]
wire   i_bri_bvalid;                     // alb_mss_fab > archipelago -- alb_mss_fab.bri_bvalid
wire   i_bri_arready;                    // alb_mss_fab > archipelago -- alb_mss_fab.bri_arready
wire   [4-1:0] i_bri_rid;                // alb_mss_fab > archipelago -- alb_mss_fab.bri_rid [4-1:0]
wire   [32-1:0] i_bri_rdata;             // alb_mss_fab > archipelago -- alb_mss_fab.bri_rdata [32-1:0]
wire   i_bri_rlast;                      // alb_mss_fab > archipelago -- alb_mss_fab.bri_rlast
wire   i_bri_rvalid;                     // alb_mss_fab > archipelago -- alb_mss_fab.bri_rvalid
wire   [1:0] i_bri_rresp;                // alb_mss_fab > archipelago -- alb_mss_fab.bri_rresp [1:0]
wire   i_ahb_hready;                     // alb_mss_fab > archipelago -- alb_mss_fab.ahb_hready
wire   i_ahb_hresp;                      // alb_mss_fab > archipelago -- alb_mss_fab.ahb_hresp
wire   i_ahb_hexokay;                    // alb_mss_fab > archipelago -- alb_mss_fab.ahb_hexokay
wire   [32-1:0] i_ahb_hrdata;            // alb_mss_fab > archipelago -- alb_mss_fab.ahb_hrdata [31:0]
wire   i_ahb_hreadychk;                  // alb_mss_fab > archipelago -- alb_mss_fab.ahb_hreadychk
wire   i_ahb_hrespchk;                   // alb_mss_fab > archipelago -- alb_mss_fab.ahb_hrespchk
wire   [3:0] i_ahb_hrdatachk;            // alb_mss_fab > archipelago -- alb_mss_fab.ahb_hrdatachk [3:0]
wire   i_dbu_per_ahb_hready;             // alb_mss_fab > archipelago -- alb_mss_fab.dbu_per_ahb_hready
wire   i_dbu_per_ahb_hresp;              // alb_mss_fab > archipelago -- alb_mss_fab.dbu_per_ahb_hresp
wire   i_dbu_per_ahb_hexokay;            // alb_mss_fab > archipelago -- alb_mss_fab.dbu_per_ahb_hexokay
wire   [32-1:0] i_dbu_per_ahb_hrdata;    // alb_mss_fab > archipelago -- alb_mss_fab.dbu_per_ahb_hrdata [31:0]
wire   i_dbu_per_ahb_hreadychk;          // alb_mss_fab > archipelago -- alb_mss_fab.dbu_per_ahb_hreadychk
wire   i_dbu_per_ahb_hrespchk;           // alb_mss_fab > archipelago -- alb_mss_fab.dbu_per_ahb_hrespchk
wire   [3:0] i_dbu_per_ahb_hrdatachk;    // alb_mss_fab > archipelago -- alb_mss_fab.dbu_per_ahb_hrdatachk [3:0]
wire   [1-1:0] i_iccm_ahb_hsel;          // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hsel [0:0]
wire   [1:0] i_iccm_ahb_htrans;          // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_htrans [1:0]
wire   i_iccm_ahb_hwrite;                // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hwrite
wire   [32-1:0] i_iccm_ahb_haddr;        // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_haddr [31:0]
wire   [2:0] i_iccm_ahb_hsize;           // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hsize [2:0]
wire   [2:0] i_iccm_ahb_hburst;          // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hburst [2:0]
wire   [32-1:0] i_iccm_ahb_hwdata;       // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hwdata [31:0]
wire   i_iccm_ahb_hready;                // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hready
wire   [4-1:0] i_iccm_ahb_haddrchk;      // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_haddrchk [3:0]
wire   i_iccm_ahb_htranschk;             // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_htranschk
wire   i_iccm_ahb_hctrlchk1;             // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hctrlchk1
wire   i_iccm_ahb_hctrlchk2;             // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hctrlchk2
wire   i_iccm_ahb_hwstrbchk;             // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hwstrbchk
wire   i_iccm_ahb_hprotchk;              // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hprotchk
wire   i_iccm_ahb_hreadychk;             // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hreadychk
wire   [3:0] i_iccm_ahb_hwdatachk;       // alb_mss_fab > archipelago -- alb_mss_fab.iccm_ahb_hwdatachk [3:0]
wire   [1-1:0] i_dccm_ahb_hsel;          // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hsel [0:0]
wire   [1:0] i_dccm_ahb_htrans;          // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_htrans [1:0]
wire   i_dccm_ahb_hwrite;                // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hwrite
wire   [32-1:0] i_dccm_ahb_haddr;        // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_haddr [31:0]
wire   [2:0] i_dccm_ahb_hsize;           // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hsize [2:0]
wire   [2:0] i_dccm_ahb_hburst;          // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hburst [2:0]
wire   [32-1:0] i_dccm_ahb_hwdata;       // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hwdata [31:0]
wire   i_dccm_ahb_hready;                // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hready
wire   [4-1:0] i_dccm_ahb_haddrchk;      // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_haddrchk [3:0]
wire   i_dccm_ahb_htranschk;             // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_htranschk
wire   i_dccm_ahb_hctrlchk1;             // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hctrlchk1
wire   i_dccm_ahb_hctrlchk2;             // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hctrlchk2
wire   i_dccm_ahb_hwstrbchk;             // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hwstrbchk
wire   i_dccm_ahb_hprotchk;              // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hprotchk
wire   i_dccm_ahb_hreadychk;             // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hreadychk
wire   [3:0] i_dccm_ahb_hwdatachk;       // alb_mss_fab > archipelago -- alb_mss_fab.dccm_ahb_hwdatachk [3:0]
wire   [1-1:0] i_mmio_ahb_hsel;          // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hsel [0:0]
wire   [1:0] i_mmio_ahb_htrans;          // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_htrans [1:0]
wire   i_mmio_ahb_hwrite;                // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hwrite
wire   [32-1:0] i_mmio_ahb_haddr;        // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_haddr [31:0]
wire   [2:0] i_mmio_ahb_hsize;           // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hsize [2:0]
wire   [2:0] i_mmio_ahb_hburst;          // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hburst [2:0]
wire   [32-1:0] i_mmio_ahb_hwdata;       // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hwdata [31:0]
wire   i_mmio_ahb_hready;                // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hready
wire   [4-1:0] i_mmio_ahb_haddrchk;      // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_haddrchk [3:0]
wire   i_mmio_ahb_htranschk;             // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_htranschk
wire   i_mmio_ahb_hctrlchk1;             // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hctrlchk1
wire   i_mmio_ahb_hctrlchk2;             // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hctrlchk2
wire   i_mmio_ahb_hwstrbchk;             // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hwstrbchk
wire   i_mmio_ahb_hprotchk;              // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hprotchk
wire   i_mmio_ahb_hreadychk;             // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hreadychk
wire   [3:0] i_mmio_ahb_hwdatachk;       // alb_mss_fab > archipelago -- alb_mss_fab.mmio_ahb_hwdatachk [3:0]
wire   [1-1:0] i_dslv2_arregion;         // alb_mss_fab > unconnected -- alb_mss_fab.dslv2_arregion [1-1:0]
wire   [1-1:0] i_dslv2_awregion;         // alb_mss_fab > unconnected -- alb_mss_fab.dslv2_awregion [1-1:0]
wire   [16-1:0] i_dslv2_wid;             // alb_mss_fab > unconnected -- alb_mss_fab.dslv2_wid [16-1:0]
wire   i_iccm_ahb_hexokay;               // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.iccm_ahb_hexokay
wire   i_iccm_ahb_fatal_err;             // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.iccm_ahb_fatal_err
wire   i_iccm_ahb_hrespchk;              // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.iccm_ahb_hrespchk
wire   i_iccm_ahb_hreadyoutchk;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.iccm_ahb_hreadyoutchk
wire   [3:0] i_iccm_ahb_hrdatachk;       // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.iccm_ahb_hrdatachk [3:0]
wire   i_dccm_ahb_hexokay;               // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dccm_ahb_hexokay
wire   i_dccm_ahb_fatal_err;             // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dccm_ahb_fatal_err
wire   i_dccm_ahb_hrespchk;              // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dccm_ahb_hrespchk
wire   i_dccm_ahb_hreadyoutchk;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dccm_ahb_hreadyoutchk
wire   [3:0] i_dccm_ahb_hrdatachk;       // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dccm_ahb_hrdatachk [3:0]
wire   i_mmio_ahb_hexokay;               // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.mmio_ahb_hexokay
wire   i_mmio_ahb_fatal_err;             // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.mmio_ahb_fatal_err
wire   i_mmio_ahb_hrespchk;              // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.mmio_ahb_hrespchk
wire   i_mmio_ahb_hreadyoutchk;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.mmio_ahb_hreadyoutchk
wire   [3:0] i_mmio_ahb_hrdatachk;       // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.mmio_ahb_hrdatachk [3:0]
wire   i_dbu_per_ahb_hmastlock;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hmastlock
wire   [7:0] i_dbu_per_ahb_hauser;       // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hauser [7:0]
wire   [0:0] i_dbu_per_ahb_hauserchk;    // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hauserchk [0:0]
wire   i_dbu_per_ahb_hctrlchk2;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hctrlchk2
wire   i_dbu_per_ahb_hwstrbchk;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hwstrbchk
wire   [3:0] i_dbu_per_ahb_hwdatachk;    // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_hwdatachk [3:0]
wire   i_dbu_per_ahb_fatal_err;          // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dbu_per_ahb_fatal_err
wire   i_high_prio_ras;                  // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.high_prio_ras
wire   i_ahb_hmastlock;                  // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hmastlock
wire   [7:0] i_ahb_hauser;               // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hauser [7:0]
wire   [0:0] i_ahb_hauserchk;            // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hauserchk [0:0]
wire   i_ahb_hctrlchk2;                  // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hctrlchk2
wire   i_ahb_hwstrbchk;                  // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hwstrbchk
wire   [3:0] i_ahb_hwdatachk;            // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_hwdatachk [3:0]
wire   i_ahb_fatal_err;                  // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ahb_fatal_err
wire   i_wdt_reset0;                     // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.wdt_reset0
wire   i_wdt_reset_wdt_clk0;             // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.wdt_reset_wdt_clk0
wire   i_reg_wr_en0;                     // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.reg_wr_en0
wire   i_critical_error;                 // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.critical_error
wire   [1:0] i_ext_trig_output_valid;    // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.ext_trig_output_valid [1:0]
wire   i_dmsi_rdy;                       // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dmsi_rdy
wire   i_dmsi_rdy_chk;                   // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.dmsi_rdy_chk
wire   i_soft_reset_ready;               // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.soft_reset_ready
wire   i_soft_reset_ack;                 // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.soft_reset_ack
wire   i_rst_cpu_ack;                    // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.rst_cpu_ack
wire   i_cpu_in_reset_state;             // archipelago > alb_mss_ext_stub -- archipelago.cpu_top_safety_controller.cpu_in_reset_state
wire   [1:0] i_safety_mem_dbe;           // archipelago > alb_mss_ext_stub -- archipelago.cpu_safety_monitor.safety_mem_dbe [1:0]
wire   [1:0] i_safety_mem_sbe;           // archipelago > alb_mss_ext_stub -- archipelago.cpu_safety_monitor.safety_mem_sbe [1:0]
wire   [1:0] i_safety_isol_change;       // archipelago > alb_mss_ext_stub -- archipelago.arcv_dm_top.safety_isol_change [1:0]
wire   [1:0] i_safety_error;             // archipelago > alb_mss_ext_stub -- archipelago.cpu_safety_monitor.safety_error [1:0]
wire   [1:0] i_safety_enabled;           // archipelago > alb_mss_ext_stub -- archipelago.cpu_safety_monitor.safety_enabled [1:0]
wire   [1:0] i_safety_iso_enb;           // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.safety_iso_enb [1:0]
wire   [1:0] i_dbg_unlock;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dbg_unlock [1:0]
wire   i_rst_cpu_req_a;                  // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.rst_cpu_req_a
wire   i_LBIST_EN;                       // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.LBIST_EN
wire   i_iccm_ahb_prio;                  // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_prio
wire   i_iccm_ahb_hmastlock;             // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_hmastlock
wire   i_iccm_ahb_hexcl;                 // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_hexcl
wire   [3:0] i_iccm_ahb_hmaster;         // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_hmaster [3:0]
wire   [3:0] i_iccm_ahb_hwstrb;          // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_hwstrb [3:0]
wire   [6:0] i_iccm_ahb_hprot;           // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_hprot [6:0]
wire   i_iccm_ahb_hnonsec;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_hnonsec
wire   i_iccm_ahb_hselchk;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.iccm_ahb_hselchk
wire   i_dccm_ahb_prio;                  // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_prio
wire   i_dccm_ahb_hmastlock;             // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_hmastlock
wire   i_dccm_ahb_hexcl;                 // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_hexcl
wire   [3:0] i_dccm_ahb_hmaster;         // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_hmaster [3:0]
wire   [3:0] i_dccm_ahb_hwstrb;          // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_hwstrb [3:0]
wire   i_dccm_ahb_hnonsec;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_hnonsec
wire   [6:0] i_dccm_ahb_hprot;           // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_hprot [6:0]
wire   i_dccm_ahb_hselchk;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dccm_ahb_hselchk
wire   i_mmio_ahb_prio;                  // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_prio
wire   i_mmio_ahb_hmastlock;             // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_hmastlock
wire   i_mmio_ahb_hexcl;                 // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_hexcl
wire   [3:0] i_mmio_ahb_hmaster;         // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_hmaster [3:0]
wire   [3:0] i_mmio_ahb_hwstrb;          // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_hwstrb [3:0]
wire   i_mmio_ahb_hnonsec;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_hnonsec
wire   [6:0] i_mmio_ahb_hprot;           // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_hprot [6:0]
wire   i_mmio_ahb_hselchk;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_ahb_hselchk
wire   [11:0] i_mmio_base_in;            // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.mmio_base_in [11:0]
wire   [21:0] i_reset_pc_in;             // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.reset_pc_in [21:0]
wire   i_rnmi_a;                         // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.rnmi_a
wire   [1:0] i_ext_trig_output_accept;   // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.ext_trig_output_accept [1:0]
wire   [15:0] i_ext_trig_in;             // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.ext_trig_in [15:0]
wire   i_dmsi_valid;                     // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dmsi_valid
wire   [0:0] i_dmsi_context;             // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dmsi_context [0:0]
wire   [5:0] i_dmsi_eiid;                // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dmsi_eiid [5:0]
wire   i_dmsi_domain;                    // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dmsi_domain
wire   i_dmsi_valid_chk;                 // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dmsi_valid_chk
wire   [5:0] i_dmsi_data_edc;            // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.dmsi_data_edc [5:0]
wire   [4:0] i_wid_rlwid;                // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.wid_rlwid [4:0]
wire   [63:0] i_wid_rwiddeleg;           // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.wid_rwiddeleg [63:0]
wire   i_soft_reset_prepare_a;           // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.soft_reset_prepare_a
wire   i_soft_reset_req_a;               // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.soft_reset_req_a
wire   i_rst_init_disable_a;             // alb_mss_ext_stub > archipelago -- alb_mss_ext_stub.rst_init_disable_a
wire   i_dbg_apb_presetn_early;          // alb_mss_ext_stub > unconnected -- alb_mss_ext_stub.dbg_apb_presetn_early
wire   i_alb_mss_ext_stub_dummy;         // alb_mss_ext_stub > unconnected -- alb_mss_ext_stub.alb_mss_ext_stub_dummy
wire   i_wdt_clk;                        // alb_mss_clkctrl > archipelago -- alb_mss_clkctrl.wdt_clk
wire   i_mss_clkctrl_dummy;              // alb_mss_clkctrl > unconnected -- alb_mss_clkctrl.mss_clkctrl_dummy
wire   [1-1:0] i_mss_mem_perf_awf;       // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_awf [1-1:0]
wire   [1-1:0] i_mss_mem_perf_arf;       // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_arf [1-1:0]
wire   [1-1:0] i_mss_mem_perf_aw;        // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_aw [1-1:0]
wire   [1-1:0] i_mss_mem_perf_ar;        // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_ar [1-1:0]
wire   [1-1:0] i_mss_mem_perf_w;         // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_w [1-1:0]
wire   [1-1:0] i_mss_mem_perf_wl;        // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_wl [1-1:0]
wire   [1-1:0] i_mss_mem_perf_r;         // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_r [1-1:0]
wire   [1-1:0] i_mss_mem_perf_rl;        // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_rl [1-1:0]
wire   [1-1:0] i_mss_mem_perf_b;         // alb_mss_mem > alb_mss_perfctrl -- alb_mss_mem.mss_mem_perf_b [1-1:0]
wire   [1*10-1:0] i_mss_mem_cfg_lat_w;   // alb_mss_perfctrl > alb_mss_mem -- alb_mss_perfctrl.mss_mem_cfg_lat_w [1*10-1:0]
wire   [1*10-1:0] i_mss_mem_cfg_lat_r;   // alb_mss_perfctrl > alb_mss_mem -- alb_mss_perfctrl.mss_mem_cfg_lat_r [1*10-1:0]
wire   i_mss_perfctrl_dummy;             // alb_mss_perfctrl > unconnected -- alb_mss_perfctrl.mss_perfctrl_dummy
wire   i_mss_mem_dummy;                  // alb_mss_mem > unconnected -- alb_mss_mem.mss_mem_dummy
wire   [1:0] i_xtor_axi_awlock;          // zebu_axi_xtor > unconnected -- zebu_axi_xtor.xtor_axi_awlock [1:0]
wire   [1:0] i_xtor_axi_arlock;          // zebu_axi_xtor > unconnected -- zebu_axi_xtor.xtor_axi_arlock [1:0]
wire   i_jtag_rtck;                      // archipelago > dw_dbp_stubs -- archipelago.dw_dbp.jtag_rtck
wire   i_dbg_apb_dbgen;                  // dw_dbp_stubs > unconnected -- dw_dbp_stubs.dbg_apb_dbgen
wire   i_dbg_apb_niden;                  // dw_dbp_stubs > unconnected -- dw_dbp_stubs.dbg_apb_niden

// Instantiation of module arcv_dm_top_stubs
arcv_dm_top_stubs iarcv_dm_top_stubs(
    .rst_a     (rst_a)                             // <   io_pad_ring
  );

// Instantiation of module alb_mss_fab
alb_mss_fab ialb_mss_fab(
    .ahb_htrans             (i_ahb_htrans)         // <   archipelago.cpu_top_safety_controller
  , .ahb_hwrite             (i_ahb_hwrite)         // <   archipelago.cpu_top_safety_controller
  , .ahb_haddr              (i_ahb_haddr)          // <   archipelago.cpu_top_safety_controller
  , .ahb_hsize              (i_ahb_hsize)          // <   archipelago.cpu_top_safety_controller
  , .ahb_hburst             (i_ahb_hburst)         // <   archipelago.cpu_top_safety_controller
  , .ahb_hprot              (i_ahb_hprot)          // <   archipelago.cpu_top_safety_controller
  , .ahb_hnonsec            (i_ahb_hnonsec)        // <   archipelago.cpu_top_safety_controller
  , .ahb_hexcl              (i_ahb_hexcl)          // <   archipelago.cpu_top_safety_controller
  , .ahb_hmaster            (i_ahb_hmaster)        // <   archipelago.cpu_top_safety_controller
  , .ahb_hwdata             (i_ahb_hwdata)         // <   archipelago.cpu_top_safety_controller
  , .ahb_hwstrb             (i_ahb_hwstrb)         // <   archipelago.cpu_top_safety_controller
  , .ahb_haddrchk           (i_ahb_haddrchk)       // <   archipelago.cpu_top_safety_controller
  , .ahb_htranschk          (i_ahb_htranschk)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hctrlchk1          (i_ahb_hctrlchk1)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hprotchk           (i_ahb_hprotchk)       // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_htrans     (i_dbu_per_ahb_htrans) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hwrite     (i_dbu_per_ahb_hwrite) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_haddr      (i_dbu_per_ahb_haddr)  // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hsize      (i_dbu_per_ahb_hsize)  // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hburst     (i_dbu_per_ahb_hburst) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hprot      (i_dbu_per_ahb_hprot)  // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hnonsec    (i_dbu_per_ahb_hnonsec) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hexcl      (i_dbu_per_ahb_hexcl)  // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hmaster    (i_dbu_per_ahb_hmaster) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hwdata     (i_dbu_per_ahb_hwdata) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hwstrb     (i_dbu_per_ahb_hwstrb) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_haddrchk   (i_dbu_per_ahb_haddrchk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_htranschk  (i_dbu_per_ahb_htranschk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hctrlchk1  (i_dbu_per_ahb_hctrlchk1) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hprotchk   (i_dbu_per_ahb_hprotchk) // <   archipelago.cpu_top_safety_controller
  , .bri_arid               (i_bri_arid)           // <   archipelago.dw_dbp
  , .bri_arvalid            (i_bri_arvalid)        // <   archipelago.dw_dbp
  , .bri_araddr             (i_bri_araddr)         // <   archipelago.dw_dbp
  , .bri_arburst            (i_bri_arburst)        // <   archipelago.dw_dbp
  , .bri_arsize             (i_bri_arsize)         // <   archipelago.dw_dbp
  , .bri_arlen              (i_bri_arlen)          // <   archipelago.dw_dbp
  , .bri_arcache            (i_bri_arcache)        // <   archipelago.dw_dbp
  , .bri_arprot             (i_bri_arprot)         // <   archipelago.dw_dbp
  , .bri_rready             (i_bri_rready)         // <   archipelago.dw_dbp
  , .bri_awid               (i_bri_awid)           // <   archipelago.dw_dbp
  , .bri_awvalid            (i_bri_awvalid)        // <   archipelago.dw_dbp
  , .bri_awaddr             (i_bri_awaddr)         // <   archipelago.dw_dbp
  , .bri_awburst            (i_bri_awburst)        // <   archipelago.dw_dbp
  , .bri_awsize             (i_bri_awsize)         // <   archipelago.dw_dbp
  , .bri_awlen              (i_bri_awlen)          // <   archipelago.dw_dbp
  , .bri_awcache            (i_bri_awcache)        // <   archipelago.dw_dbp
  , .bri_awprot             (i_bri_awprot)         // <   archipelago.dw_dbp
  , .bri_wid                (i_bri_wid)            // <   archipelago.dw_dbp
  , .bri_wvalid             (i_bri_wvalid)         // <   archipelago.dw_dbp
  , .bri_wdata              (i_bri_wdata)          // <   archipelago.dw_dbp
  , .bri_wstrb              (i_bri_wstrb)          // <   archipelago.dw_dbp
  , .bri_wlast              (i_bri_wlast)          // <   archipelago.dw_dbp
  , .bri_bready             (i_bri_bready)         // <   archipelago.dw_dbp
  , .xtor_axi_arid          (i_xtor_axi_arid)      // <   zebu_axi_xtor
  , .xtor_axi_arvalid       (i_xtor_axi_arvalid)   // <   zebu_axi_xtor
  , .xtor_axi_araddr        (i_xtor_axi_araddr)    // <   zebu_axi_xtor
  , .xtor_axi_arburst       (i_xtor_axi_arburst)   // <   zebu_axi_xtor
  , .xtor_axi_arsize        (i_xtor_axi_arsize)    // <   zebu_axi_xtor
  , .xtor_axi_arlen         (i_xtor_axi_arlen)     // <   zebu_axi_xtor
  , .xtor_axi_arcache       (i_xtor_axi_arcache)   // <   zebu_axi_xtor
  , .xtor_axi_arprot        (i_xtor_axi_arprot)    // <   zebu_axi_xtor
  , .xtor_axi_rready        (i_xtor_axi_rready)    // <   zebu_axi_xtor
  , .xtor_axi_awid          (i_xtor_axi_awid)      // <   zebu_axi_xtor
  , .xtor_axi_awvalid       (i_xtor_axi_awvalid)   // <   zebu_axi_xtor
  , .xtor_axi_awaddr        (i_xtor_axi_awaddr)    // <   zebu_axi_xtor
  , .xtor_axi_awburst       (i_xtor_axi_awburst)   // <   zebu_axi_xtor
  , .xtor_axi_awsize        (i_xtor_axi_awsize)    // <   zebu_axi_xtor
  , .xtor_axi_awlen         (i_xtor_axi_awlen)     // <   zebu_axi_xtor
  , .xtor_axi_awcache       (i_xtor_axi_awcache)   // <   zebu_axi_xtor
  , .xtor_axi_awprot        (i_xtor_axi_awprot)    // <   zebu_axi_xtor
  , .xtor_axi_wid           (i_xtor_axi_wid)       // <   zebu_axi_xtor
  , .xtor_axi_wvalid        (i_xtor_axi_wvalid)    // <   zebu_axi_xtor
  , .xtor_axi_wdata         (i_xtor_axi_wdata)     // <   zebu_axi_xtor
  , .xtor_axi_wstrb         (i_xtor_axi_wstrb)     // <   zebu_axi_xtor
  , .xtor_axi_wlast         (i_xtor_axi_wlast)     // <   zebu_axi_xtor
  , .xtor_axi_bready        (i_xtor_axi_bready)    // <   zebu_axi_xtor
  , .iccm_ahb_hrdata        (i_iccm_ahb_hrdata)    // <   archipelago.cpu_top_safety_controller
  , .iccm_ahb_hresp         (i_iccm_ahb_hresp)     // <   archipelago.cpu_top_safety_controller
  , .iccm_ahb_hreadyout     (i_iccm_ahb_hreadyout) // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_hrdata        (i_dccm_ahb_hrdata)    // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_hresp         (i_dccm_ahb_hresp)     // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_hreadyout     (i_dccm_ahb_hreadyout) // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_hrdata        (i_mmio_ahb_hrdata)    // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_hresp         (i_mmio_ahb_hresp)     // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_hreadyout     (i_mmio_ahb_hreadyout) // <   archipelago.cpu_top_safety_controller
  , .mss_clkctrl_rdata      (i_mss_clkctrl_rdata)  // <   alb_mss_clkctrl
  , .mss_clkctrl_slverr     (i_mss_clkctrl_slverr) // <   alb_mss_clkctrl
  , .mss_clkctrl_ready      (i_mss_clkctrl_ready)  // <   alb_mss_clkctrl
  , .dslv1_rdata            (i_dslv1_rdata)        // <   alb_mss_dummy_slave
  , .dslv1_slverr           (i_dslv1_slverr)       // <   alb_mss_dummy_slave
  , .dslv1_ready            (i_dslv1_ready)        // <   alb_mss_dummy_slave
  , .dslv2_arready          (i_dslv2_arready)      // <   alb_mss_dummy_slave
  , .dslv2_rid              (i_dslv2_rid)          // <   alb_mss_dummy_slave
  , .dslv2_rvalid           (i_dslv2_rvalid)       // <   alb_mss_dummy_slave
  , .dslv2_rdata            (i_dslv2_rdata)        // <   alb_mss_dummy_slave
  , .dslv2_rresp            (i_dslv2_rresp)        // <   alb_mss_dummy_slave
  , .dslv2_rlast            (i_dslv2_rlast)        // <   alb_mss_dummy_slave
  , .dslv2_awready          (i_dslv2_awready)      // <   alb_mss_dummy_slave
  , .dslv2_wready           (i_dslv2_wready)       // <   alb_mss_dummy_slave
  , .dslv2_bid              (i_dslv2_bid)          // <   alb_mss_dummy_slave
  , .dslv2_bvalid           (i_dslv2_bvalid)       // <   alb_mss_dummy_slave
  , .dslv2_bresp            (i_dslv2_bresp)        // <   alb_mss_dummy_slave
  , .mss_perfctrl_rdata     (i_mss_perfctrl_rdata) // <   alb_mss_perfctrl
  , .mss_perfctrl_slverr    (i_mss_perfctrl_slverr) // <   alb_mss_perfctrl
  , .mss_perfctrl_ready     (i_mss_perfctrl_ready) // <   alb_mss_perfctrl
  , .mss_mem_cmd_accept     (i_mss_mem_cmd_accept) // <   alb_mss_mem
  , .mss_mem_rd_valid       (i_mss_mem_rd_valid)   // <   alb_mss_mem
  , .mss_mem_rd_excl_ok     (i_mss_mem_rd_excl_ok) // <   alb_mss_mem
  , .mss_mem_rd_data        (i_mss_mem_rd_data)    // <   alb_mss_mem
  , .mss_mem_err_rd         (i_mss_mem_err_rd)     // <   alb_mss_mem
  , .mss_mem_rd_last        (i_mss_mem_rd_last)    // <   alb_mss_mem
  , .mss_mem_wr_accept      (i_mss_mem_wr_accept)  // <   alb_mss_mem
  , .mss_mem_wr_done        (i_mss_mem_wr_done)    // <   alb_mss_mem
  , .mss_mem_wr_excl_done   (i_mss_mem_wr_excl_done) // <   alb_mss_mem
  , .mss_mem_err_wr         (i_mss_mem_err_wr)     // <   alb_mss_mem
  , .mss_fab_cfg_lat_w      (i_mss_fab_cfg_lat_w)  // <   alb_mss_perfctrl
  , .mss_fab_cfg_lat_r      (i_mss_fab_cfg_lat_r)  // <   alb_mss_perfctrl
  , .mss_fab_cfg_wr_bw      (i_mss_fab_cfg_wr_bw)  // <   alb_mss_perfctrl
  , .mss_fab_cfg_rd_bw      (i_mss_fab_cfg_rd_bw)  // <   alb_mss_perfctrl
  , .clk                    (i_clk)                // <   alb_mss_clkctrl
  , .mss_clk                (i_mss_clk)            // <   alb_mss_clkctrl
  , .iccm_ahb_clk_en        (i_iccm_ahb_clk_en)    // <   alb_mss_clkctrl
  , .dccm_ahb_clk_en        (i_dccm_ahb_clk_en)    // <   alb_mss_clkctrl
  , .mmio_ahb_clk_en        (i_mmio_ahb_clk_en)    // <   alb_mss_clkctrl
  , .mss_fab_mst0_clk_en    (i_mss_fab_mst0_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_mst1_clk_en    (i_mss_fab_mst1_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_mst2_clk_en    (i_mss_fab_mst2_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_mst3_clk_en    (i_mss_fab_mst3_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv0_clk_en    (i_mss_fab_slv0_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv1_clk_en    (i_mss_fab_slv1_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv2_clk_en    (i_mss_fab_slv2_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv3_clk_en    (i_mss_fab_slv3_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv4_clk_en    (i_mss_fab_slv4_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv5_clk_en    (i_mss_fab_slv5_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv6_clk_en    (i_mss_fab_slv6_clk_en) // <   alb_mss_clkctrl
  , .mss_fab_slv7_clk_en    (i_mss_fab_slv7_clk_en) // <   alb_mss_clkctrl
  , .rst_b                  (i_rst_b)              // <   alb_mss_clkctrl
  , .mss_clkctrl_sel        (i_mss_clkctrl_sel)    //   > alb_mss_clkctrl
  , .mss_clkctrl_enable     (i_mss_clkctrl_enable) //   > alb_mss_clkctrl
  , .mss_clkctrl_write      (i_mss_clkctrl_write)  //   > alb_mss_clkctrl
  , .mss_clkctrl_addr       (i_mss_clkctrl_addr)   //   > alb_mss_clkctrl
  , .mss_clkctrl_wdata      (i_mss_clkctrl_wdata)  //   > alb_mss_clkctrl
  , .mss_clkctrl_wstrb      (i_mss_clkctrl_wstrb)  //   > alb_mss_clkctrl
  , .dslv1_sel              (i_dslv1_sel)          //   > alb_mss_dummy_slave
  , .dslv1_enable           (i_dslv1_enable)       //   > alb_mss_dummy_slave
  , .dslv1_write            (i_dslv1_write)        //   > alb_mss_dummy_slave
  , .dslv1_addr             (i_dslv1_addr)         //   > alb_mss_dummy_slave
  , .dslv1_wdata            (i_dslv1_wdata)        //   > alb_mss_dummy_slave
  , .dslv1_wstrb            (i_dslv1_wstrb)        //   > alb_mss_dummy_slave
  , .dslv2_arvalid          (i_dslv2_arvalid)      //   > alb_mss_dummy_slave
  , .dslv2_araddr           (i_dslv2_araddr)       //   > alb_mss_dummy_slave
  , .dslv2_arburst          (i_dslv2_arburst)      //   > alb_mss_dummy_slave
  , .dslv2_arsize           (i_dslv2_arsize)       //   > alb_mss_dummy_slave
  , .dslv2_arlen            (i_dslv2_arlen)        //   > alb_mss_dummy_slave
  , .dslv2_arid             (i_dslv2_arid)         //   > alb_mss_dummy_slave
  , .dslv2_rready           (i_dslv2_rready)       //   > alb_mss_dummy_slave
  , .dslv2_awvalid          (i_dslv2_awvalid)      //   > alb_mss_dummy_slave
  , .dslv2_awaddr           (i_dslv2_awaddr)       //   > alb_mss_dummy_slave
  , .dslv2_awburst          (i_dslv2_awburst)      //   > alb_mss_dummy_slave
  , .dslv2_awsize           (i_dslv2_awsize)       //   > alb_mss_dummy_slave
  , .dslv2_awlen            (i_dslv2_awlen)        //   > alb_mss_dummy_slave
  , .dslv2_awid             (i_dslv2_awid)         //   > alb_mss_dummy_slave
  , .dslv2_wvalid           (i_dslv2_wvalid)       //   > alb_mss_dummy_slave
  , .dslv2_wdata            (i_dslv2_wdata)        //   > alb_mss_dummy_slave
  , .dslv2_wstrb            (i_dslv2_wstrb)        //   > alb_mss_dummy_slave
  , .dslv2_wlast            (i_dslv2_wlast)        //   > alb_mss_dummy_slave
  , .dslv2_bready           (i_dslv2_bready)       //   > alb_mss_dummy_slave
  , .mss_perfctrl_sel       (i_mss_perfctrl_sel)   //   > alb_mss_perfctrl
  , .mss_perfctrl_enable    (i_mss_perfctrl_enable) //   > alb_mss_perfctrl
  , .mss_perfctrl_write     (i_mss_perfctrl_write) //   > alb_mss_perfctrl
  , .mss_perfctrl_addr      (i_mss_perfctrl_addr)  //   > alb_mss_perfctrl
  , .mss_perfctrl_wdata     (i_mss_perfctrl_wdata) //   > alb_mss_perfctrl
  , .mss_perfctrl_wstrb     (i_mss_perfctrl_wstrb) //   > alb_mss_perfctrl
  , .mss_fab_perf_awf       (i_mss_fab_perf_awf)   //   > alb_mss_perfctrl
  , .mss_fab_perf_arf       (i_mss_fab_perf_arf)   //   > alb_mss_perfctrl
  , .mss_fab_perf_aw        (i_mss_fab_perf_aw)    //   > alb_mss_perfctrl
  , .mss_fab_perf_ar        (i_mss_fab_perf_ar)    //   > alb_mss_perfctrl
  , .mss_fab_perf_w         (i_mss_fab_perf_w)     //   > alb_mss_perfctrl
  , .mss_fab_perf_wl        (i_mss_fab_perf_wl)    //   > alb_mss_perfctrl
  , .mss_fab_perf_r         (i_mss_fab_perf_r)     //   > alb_mss_perfctrl
  , .mss_fab_perf_rl        (i_mss_fab_perf_rl)    //   > alb_mss_perfctrl
  , .mss_fab_perf_b         (i_mss_fab_perf_b)     //   > alb_mss_perfctrl
  , .mss_mem_cmd_valid      (i_mss_mem_cmd_valid)  //   > alb_mss_mem
  , .mss_mem_cmd_read       (i_mss_mem_cmd_read)   //   > alb_mss_mem
  , .mss_mem_cmd_addr       (i_mss_mem_cmd_addr)   //   > alb_mss_mem
  , .mss_mem_cmd_wrap       (i_mss_mem_cmd_wrap)   //   > alb_mss_mem
  , .mss_mem_cmd_data_size  (i_mss_mem_cmd_data_size) //   > alb_mss_mem
  , .mss_mem_cmd_burst_size (i_mss_mem_cmd_burst_size) //   > alb_mss_mem
  , .mss_mem_cmd_lock       (i_mss_mem_cmd_lock)   //   > alb_mss_mem
  , .mss_mem_cmd_excl       (i_mss_mem_cmd_excl)   //   > alb_mss_mem
  , .mss_mem_cmd_prot       (i_mss_mem_cmd_prot)   //   > alb_mss_mem
  , .mss_mem_cmd_cache      (i_mss_mem_cmd_cache)  //   > alb_mss_mem
  , .mss_mem_cmd_id         (i_mss_mem_cmd_id)     //   > alb_mss_mem
  , .mss_mem_cmd_user       (i_mss_mem_cmd_user)   //   > alb_mss_mem
  , .mss_mem_cmd_region     (i_mss_mem_cmd_region) //   > alb_mss_mem
  , .mss_mem_rd_accept      (i_mss_mem_rd_accept)  //   > alb_mss_mem
  , .mss_mem_wr_valid       (i_mss_mem_wr_valid)   //   > alb_mss_mem
  , .mss_mem_wr_data        (i_mss_mem_wr_data)    //   > alb_mss_mem
  , .mss_mem_wr_mask        (i_mss_mem_wr_mask)    //   > alb_mss_mem
  , .mss_mem_wr_last        (i_mss_mem_wr_last)    //   > alb_mss_mem
  , .mss_mem_wr_resp_accept (i_mss_mem_wr_resp_accept) //   > alb_mss_mem
  , .xtor_axi_awready       (i_xtor_axi_awready)   //   > zebu_axi_xtor
  , .xtor_axi_wready        (i_xtor_axi_wready)    //   > zebu_axi_xtor
  , .xtor_axi_bid           (i_xtor_axi_bid)       //   > zebu_axi_xtor
  , .xtor_axi_bresp         (i_xtor_axi_bresp)     //   > zebu_axi_xtor
  , .xtor_axi_bvalid        (i_xtor_axi_bvalid)    //   > zebu_axi_xtor
  , .xtor_axi_arready       (i_xtor_axi_arready)   //   > zebu_axi_xtor
  , .xtor_axi_rid           (i_xtor_axi_rid)       //   > zebu_axi_xtor
  , .xtor_axi_rdata         (i_xtor_axi_rdata)     //   > zebu_axi_xtor
  , .xtor_axi_rresp         (i_xtor_axi_rresp)     //   > zebu_axi_xtor
  , .xtor_axi_rlast         (i_xtor_axi_rlast)     //   > zebu_axi_xtor
  , .xtor_axi_rvalid        (i_xtor_axi_rvalid)    //   > zebu_axi_xtor
  , .bri_awready            (i_bri_awready)        //   > archipelago
  , .bri_wready             (i_bri_wready)         //   > archipelago
  , .bri_bid                (i_bri_bid)            //   > archipelago
  , .bri_bresp              (i_bri_bresp)          //   > archipelago
  , .bri_bvalid             (i_bri_bvalid)         //   > archipelago
  , .bri_arready            (i_bri_arready)        //   > archipelago
  , .bri_rid                (i_bri_rid)            //   > archipelago
  , .bri_rdata              (i_bri_rdata)          //   > archipelago
  , .bri_rlast              (i_bri_rlast)          //   > archipelago
  , .bri_rvalid             (i_bri_rvalid)         //   > archipelago
  , .bri_rresp              (i_bri_rresp)          //   > archipelago
  , .ahb_hready             (i_ahb_hready)         //   > archipelago
  , .ahb_hresp              (i_ahb_hresp)          //   > archipelago
  , .ahb_hexokay            (i_ahb_hexokay)        //   > archipelago
  , .ahb_hrdata             (i_ahb_hrdata)         //   > archipelago
  , .ahb_hreadychk          (i_ahb_hreadychk)      //   > archipelago
  , .ahb_hrespchk           (i_ahb_hrespchk)       //   > archipelago
  , .ahb_hrdatachk          (i_ahb_hrdatachk)      //   > archipelago
  , .dbu_per_ahb_hready     (i_dbu_per_ahb_hready) //   > archipelago
  , .dbu_per_ahb_hresp      (i_dbu_per_ahb_hresp)  //   > archipelago
  , .dbu_per_ahb_hexokay    (i_dbu_per_ahb_hexokay) //   > archipelago
  , .dbu_per_ahb_hrdata     (i_dbu_per_ahb_hrdata) //   > archipelago
  , .dbu_per_ahb_hreadychk  (i_dbu_per_ahb_hreadychk) //   > archipelago
  , .dbu_per_ahb_hrespchk   (i_dbu_per_ahb_hrespchk) //   > archipelago
  , .dbu_per_ahb_hrdatachk  (i_dbu_per_ahb_hrdatachk) //   > archipelago
  , .iccm_ahb_hsel          (i_iccm_ahb_hsel)      //   > archipelago
  , .iccm_ahb_htrans        (i_iccm_ahb_htrans)    //   > archipelago
  , .iccm_ahb_hwrite        (i_iccm_ahb_hwrite)    //   > archipelago
  , .iccm_ahb_haddr         (i_iccm_ahb_haddr)     //   > archipelago
  , .iccm_ahb_hsize         (i_iccm_ahb_hsize)     //   > archipelago
  , .iccm_ahb_hburst        (i_iccm_ahb_hburst)    //   > archipelago
  , .iccm_ahb_hwdata        (i_iccm_ahb_hwdata)    //   > archipelago
  , .iccm_ahb_hready        (i_iccm_ahb_hready)    //   > archipelago
  , .iccm_ahb_haddrchk      (i_iccm_ahb_haddrchk)  //   > archipelago
  , .iccm_ahb_htranschk     (i_iccm_ahb_htranschk) //   > archipelago
  , .iccm_ahb_hctrlchk1     (i_iccm_ahb_hctrlchk1) //   > archipelago
  , .iccm_ahb_hctrlchk2     (i_iccm_ahb_hctrlchk2) //   > archipelago
  , .iccm_ahb_hwstrbchk     (i_iccm_ahb_hwstrbchk) //   > archipelago
  , .iccm_ahb_hprotchk      (i_iccm_ahb_hprotchk)  //   > archipelago
  , .iccm_ahb_hreadychk     (i_iccm_ahb_hreadychk) //   > archipelago
  , .iccm_ahb_hwdatachk     (i_iccm_ahb_hwdatachk) //   > archipelago
  , .dccm_ahb_hsel          (i_dccm_ahb_hsel)      //   > archipelago
  , .dccm_ahb_htrans        (i_dccm_ahb_htrans)    //   > archipelago
  , .dccm_ahb_hwrite        (i_dccm_ahb_hwrite)    //   > archipelago
  , .dccm_ahb_haddr         (i_dccm_ahb_haddr)     //   > archipelago
  , .dccm_ahb_hsize         (i_dccm_ahb_hsize)     //   > archipelago
  , .dccm_ahb_hburst        (i_dccm_ahb_hburst)    //   > archipelago
  , .dccm_ahb_hwdata        (i_dccm_ahb_hwdata)    //   > archipelago
  , .dccm_ahb_hready        (i_dccm_ahb_hready)    //   > archipelago
  , .dccm_ahb_haddrchk      (i_dccm_ahb_haddrchk)  //   > archipelago
  , .dccm_ahb_htranschk     (i_dccm_ahb_htranschk) //   > archipelago
  , .dccm_ahb_hctrlchk1     (i_dccm_ahb_hctrlchk1) //   > archipelago
  , .dccm_ahb_hctrlchk2     (i_dccm_ahb_hctrlchk2) //   > archipelago
  , .dccm_ahb_hwstrbchk     (i_dccm_ahb_hwstrbchk) //   > archipelago
  , .dccm_ahb_hprotchk      (i_dccm_ahb_hprotchk)  //   > archipelago
  , .dccm_ahb_hreadychk     (i_dccm_ahb_hreadychk) //   > archipelago
  , .dccm_ahb_hwdatachk     (i_dccm_ahb_hwdatachk) //   > archipelago
  , .mmio_ahb_hsel          (i_mmio_ahb_hsel)      //   > archipelago
  , .mmio_ahb_htrans        (i_mmio_ahb_htrans)    //   > archipelago
  , .mmio_ahb_hwrite        (i_mmio_ahb_hwrite)    //   > archipelago
  , .mmio_ahb_haddr         (i_mmio_ahb_haddr)     //   > archipelago
  , .mmio_ahb_hsize         (i_mmio_ahb_hsize)     //   > archipelago
  , .mmio_ahb_hburst        (i_mmio_ahb_hburst)    //   > archipelago
  , .mmio_ahb_hwdata        (i_mmio_ahb_hwdata)    //   > archipelago
  , .mmio_ahb_hready        (i_mmio_ahb_hready)    //   > archipelago
  , .mmio_ahb_haddrchk      (i_mmio_ahb_haddrchk)  //   > archipelago
  , .mmio_ahb_htranschk     (i_mmio_ahb_htranschk) //   > archipelago
  , .mmio_ahb_hctrlchk1     (i_mmio_ahb_hctrlchk1) //   > archipelago
  , .mmio_ahb_hctrlchk2     (i_mmio_ahb_hctrlchk2) //   > archipelago
  , .mmio_ahb_hwstrbchk     (i_mmio_ahb_hwstrbchk) //   > archipelago
  , .mmio_ahb_hprotchk      (i_mmio_ahb_hprotchk)  //   > archipelago
  , .mmio_ahb_hreadychk     (i_mmio_ahb_hreadychk) //   > archipelago
  , .mmio_ahb_hwdatachk     (i_mmio_ahb_hwdatachk) //   > archipelago
  , .dslv2_arregion         ()                     //   > unconnected i_dslv2_arregion
  , .dslv2_awregion         ()                     //   > unconnected i_dslv2_awregion
  , .dslv2_wid              ()                     //   > unconnected i_dslv2_wid
  );

// Instantiation of module alb_mss_ext_stub
alb_mss_ext_stub ialb_mss_ext_stub(
    .iccm_ahb_hexokay       (i_iccm_ahb_hexokay)   // <   archipelago.cpu_top_safety_controller
  , .iccm_ahb_fatal_err     (i_iccm_ahb_fatal_err) // <   archipelago.cpu_top_safety_controller
  , .iccm_ahb_hrespchk      (i_iccm_ahb_hrespchk)  // <   archipelago.cpu_top_safety_controller
  , .iccm_ahb_hreadyoutchk  (i_iccm_ahb_hreadyoutchk) // <   archipelago.cpu_top_safety_controller
  , .iccm_ahb_hrdatachk     (i_iccm_ahb_hrdatachk) // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_hexokay       (i_dccm_ahb_hexokay)   // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_fatal_err     (i_dccm_ahb_fatal_err) // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_hrespchk      (i_dccm_ahb_hrespchk)  // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_hreadyoutchk  (i_dccm_ahb_hreadyoutchk) // <   archipelago.cpu_top_safety_controller
  , .dccm_ahb_hrdatachk     (i_dccm_ahb_hrdatachk) // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_hexokay       (i_mmio_ahb_hexokay)   // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_fatal_err     (i_mmio_ahb_fatal_err) // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_hrespchk      (i_mmio_ahb_hrespchk)  // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_hreadyoutchk  (i_mmio_ahb_hreadyoutchk) // <   archipelago.cpu_top_safety_controller
  , .mmio_ahb_hrdatachk     (i_mmio_ahb_hrdatachk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hexcl      (i_dbu_per_ahb_hexcl)  // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hmastlock  (i_dbu_per_ahb_hmastlock) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hmaster    (i_dbu_per_ahb_hmaster) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hauser     (i_dbu_per_ahb_hauser) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hauserchk  (i_dbu_per_ahb_hauserchk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_haddrchk   (i_dbu_per_ahb_haddrchk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_htranschk  (i_dbu_per_ahb_htranschk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hctrlchk1  (i_dbu_per_ahb_hctrlchk1) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hctrlchk2  (i_dbu_per_ahb_hctrlchk2) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hwstrbchk  (i_dbu_per_ahb_hwstrbchk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hprotchk   (i_dbu_per_ahb_hprotchk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_hwdatachk  (i_dbu_per_ahb_hwdatachk) // <   archipelago.cpu_top_safety_controller
  , .dbu_per_ahb_fatal_err  (i_dbu_per_ahb_fatal_err) // <   archipelago.cpu_top_safety_controller
  , .high_prio_ras          (i_high_prio_ras)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hexcl              (i_ahb_hexcl)          // <   archipelago.cpu_top_safety_controller
  , .ahb_hmastlock          (i_ahb_hmastlock)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hmaster            (i_ahb_hmaster)        // <   archipelago.cpu_top_safety_controller
  , .ahb_hauser             (i_ahb_hauser)         // <   archipelago.cpu_top_safety_controller
  , .ahb_hauserchk          (i_ahb_hauserchk)      // <   archipelago.cpu_top_safety_controller
  , .ahb_haddrchk           (i_ahb_haddrchk)       // <   archipelago.cpu_top_safety_controller
  , .ahb_htranschk          (i_ahb_htranschk)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hctrlchk1          (i_ahb_hctrlchk1)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hctrlchk2          (i_ahb_hctrlchk2)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hwstrbchk          (i_ahb_hwstrbchk)      // <   archipelago.cpu_top_safety_controller
  , .ahb_hprotchk           (i_ahb_hprotchk)       // <   archipelago.cpu_top_safety_controller
  , .ahb_hwdatachk          (i_ahb_hwdatachk)      // <   archipelago.cpu_top_safety_controller
  , .ahb_fatal_err          (i_ahb_fatal_err)      // <   archipelago.cpu_top_safety_controller
  , .wdt_reset0             (i_wdt_reset0)         // <   archipelago.cpu_top_safety_controller
  , .wdt_reset_wdt_clk0     (i_wdt_reset_wdt_clk0) // <   archipelago.cpu_top_safety_controller
  , .reg_wr_en0             (i_reg_wr_en0)         // <   archipelago.cpu_top_safety_controller
  , .critical_error         (i_critical_error)     // <   archipelago.cpu_top_safety_controller
  , .ext_trig_output_valid  (i_ext_trig_output_valid) // <   archipelago.cpu_top_safety_controller
  , .dmsi_rdy               (i_dmsi_rdy)           // <   archipelago.cpu_top_safety_controller
  , .dmsi_rdy_chk           (i_dmsi_rdy_chk)       // <   archipelago.cpu_top_safety_controller
  , .soft_reset_ready       (i_soft_reset_ready)   // <   archipelago.cpu_top_safety_controller
  , .soft_reset_ack         (i_soft_reset_ack)     // <   archipelago.cpu_top_safety_controller
  , .rst_cpu_ack            (i_rst_cpu_ack)        // <   archipelago.cpu_top_safety_controller
  , .cpu_in_reset_state     (i_cpu_in_reset_state) // <   archipelago.cpu_top_safety_controller
  , .safety_mem_dbe         (i_safety_mem_dbe)     // <   archipelago.cpu_safety_monitor
  , .safety_mem_sbe         (i_safety_mem_sbe)     // <   archipelago.cpu_safety_monitor
  , .safety_isol_change     (i_safety_isol_change) // <   archipelago.arcv_dm_top
  , .safety_error           (i_safety_error)       // <   archipelago.cpu_safety_monitor
  , .safety_enabled         (i_safety_enabled)     // <   archipelago.cpu_safety_monitor
  , .mss_clk                (i_mss_clk)            // <   alb_mss_clkctrl
  , .rst_a                  (rst_a)                // <   io_pad_ring
  , .safety_iso_enb         (i_safety_iso_enb)     //   > archipelago
  , .dbg_unlock             (i_dbg_unlock)         //   > archipelago
  , .rst_cpu_req_a          (i_rst_cpu_req_a)      //   > archipelago
  , .LBIST_EN               (i_LBIST_EN)           //   > archipelago
  , .iccm_ahb_prio          (i_iccm_ahb_prio)      //   > archipelago
  , .iccm_ahb_hmastlock     (i_iccm_ahb_hmastlock) //   > archipelago
  , .iccm_ahb_hexcl         (i_iccm_ahb_hexcl)     //   > archipelago
  , .iccm_ahb_hmaster       (i_iccm_ahb_hmaster)   //   > archipelago
  , .iccm_ahb_hwstrb        (i_iccm_ahb_hwstrb)    //   > archipelago
  , .iccm_ahb_hprot         (i_iccm_ahb_hprot)     //   > archipelago
  , .iccm_ahb_hnonsec       (i_iccm_ahb_hnonsec)   //   > archipelago
  , .iccm_ahb_hselchk       (i_iccm_ahb_hselchk)   //   > archipelago
  , .dccm_ahb_prio          (i_dccm_ahb_prio)      //   > archipelago
  , .dccm_ahb_hmastlock     (i_dccm_ahb_hmastlock) //   > archipelago
  , .dccm_ahb_hexcl         (i_dccm_ahb_hexcl)     //   > archipelago
  , .dccm_ahb_hmaster       (i_dccm_ahb_hmaster)   //   > archipelago
  , .dccm_ahb_hwstrb        (i_dccm_ahb_hwstrb)    //   > archipelago
  , .dccm_ahb_hnonsec       (i_dccm_ahb_hnonsec)   //   > archipelago
  , .dccm_ahb_hprot         (i_dccm_ahb_hprot)     //   > archipelago
  , .dccm_ahb_hselchk       (i_dccm_ahb_hselchk)   //   > archipelago
  , .mmio_ahb_prio          (i_mmio_ahb_prio)      //   > archipelago
  , .mmio_ahb_hmastlock     (i_mmio_ahb_hmastlock) //   > archipelago
  , .mmio_ahb_hexcl         (i_mmio_ahb_hexcl)     //   > archipelago
  , .mmio_ahb_hmaster       (i_mmio_ahb_hmaster)   //   > archipelago
  , .mmio_ahb_hwstrb        (i_mmio_ahb_hwstrb)    //   > archipelago
  , .mmio_ahb_hnonsec       (i_mmio_ahb_hnonsec)   //   > archipelago
  , .mmio_ahb_hprot         (i_mmio_ahb_hprot)     //   > archipelago
  , .mmio_ahb_hselchk       (i_mmio_ahb_hselchk)   //   > archipelago
  , .mmio_base_in           (i_mmio_base_in)       //   > archipelago
  , .reset_pc_in            (i_reset_pc_in)        //   > archipelago
  , .rnmi_a                 (i_rnmi_a)             //   > archipelago
  , .ext_trig_output_accept (i_ext_trig_output_accept) //   > archipelago
  , .ext_trig_in            (i_ext_trig_in)        //   > archipelago
  , .dmsi_valid             (i_dmsi_valid)         //   > archipelago
  , .dmsi_context           (i_dmsi_context)       //   > archipelago
  , .dmsi_eiid              (i_dmsi_eiid)          //   > archipelago
  , .dmsi_domain            (i_dmsi_domain)        //   > archipelago
  , .dmsi_valid_chk         (i_dmsi_valid_chk)     //   > archipelago
  , .dmsi_data_edc          (i_dmsi_data_edc)      //   > archipelago
  , .wid_rlwid              (i_wid_rlwid)          //   > archipelago
  , .wid_rwiddeleg          (i_wid_rwiddeleg)      //   > archipelago
  , .soft_reset_prepare_a   (i_soft_reset_prepare_a) //   > archipelago
  , .soft_reset_req_a       (i_soft_reset_req_a)   //   > archipelago
  , .rst_init_disable_a     (i_rst_init_disable_a) //   > archipelago
  , .dbg_apb_presetn_early  ()                     //   > unconnected i_dbg_apb_presetn_early
  , .alb_mss_ext_stub_dummy ()                     //   > unconnected i_alb_mss_ext_stub_dummy
  );

// Instantiation of module alb_mss_clkctrl
alb_mss_clkctrl ialb_mss_clkctrl(
    .ref_clk             (ref_clk)                 // <   io_pad_ring
  , .rst_a               (rst_a)                   // <   io_pad_ring
  , .mss_clkctrl_sel     (i_mss_clkctrl_sel)       // <   alb_mss_fab
  , .mss_clkctrl_enable  (i_mss_clkctrl_enable)    // <   alb_mss_fab
  , .mss_clkctrl_write   (i_mss_clkctrl_write)     // <   alb_mss_fab
  , .mss_clkctrl_addr    (i_mss_clkctrl_addr)      // <   alb_mss_fab
  , .mss_clkctrl_wdata   (i_mss_clkctrl_wdata)     // <   alb_mss_fab
  , .mss_clkctrl_wstrb   (i_mss_clkctrl_wstrb)     // <   alb_mss_fab
  , .mss_clkctrl_rdata   (i_mss_clkctrl_rdata)     //   > alb_mss_fab
  , .mss_clkctrl_slverr  (i_mss_clkctrl_slverr)    //   > alb_mss_fab
  , .mss_clkctrl_ready   (i_mss_clkctrl_ready)     //   > alb_mss_fab
  , .clk                 (i_clk)                   //   > archipelago
  , .mss_clk             (i_mss_clk)               //   > zebu_axi_xtor
  , .iccm_ahb_clk_en     (i_iccm_ahb_clk_en)       //   > alb_mss_fab
  , .dccm_ahb_clk_en     (i_dccm_ahb_clk_en)       //   > alb_mss_fab
  , .mmio_ahb_clk_en     (i_mmio_ahb_clk_en)       //   > alb_mss_fab
  , .mss_fab_mst0_clk_en (i_mss_fab_mst0_clk_en)   //   > alb_mss_fab
  , .mss_fab_mst1_clk_en (i_mss_fab_mst1_clk_en)   //   > alb_mss_fab
  , .mss_fab_mst2_clk_en (i_mss_fab_mst2_clk_en)   //   > alb_mss_fab
  , .mss_fab_mst3_clk_en (i_mss_fab_mst3_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv0_clk_en (i_mss_fab_slv0_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv1_clk_en (i_mss_fab_slv1_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv2_clk_en (i_mss_fab_slv2_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv3_clk_en (i_mss_fab_slv3_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv4_clk_en (i_mss_fab_slv4_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv5_clk_en (i_mss_fab_slv5_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv6_clk_en (i_mss_fab_slv6_clk_en)   //   > alb_mss_fab
  , .mss_fab_slv7_clk_en (i_mss_fab_slv7_clk_en)   //   > alb_mss_fab
  , .rst_b               (i_rst_b)                 //   > alb_mss_mem
  , .wdt_clk             (i_wdt_clk)               //   > archipelago
  , .mss_clkctrl_dummy   ()                        //   > unconnected i_mss_clkctrl_dummy
  );

// Instantiation of module alb_mss_dummy_slave
alb_mss_dummy_slave ialb_mss_dummy_slave(
    .dslv1_sel     (i_dslv1_sel)                   // <   alb_mss_fab
  , .dslv1_enable  (i_dslv1_enable)                // <   alb_mss_fab
  , .dslv1_write   (i_dslv1_write)                 // <   alb_mss_fab
  , .dslv1_addr    (i_dslv1_addr)                  // <   alb_mss_fab
  , .dslv1_wdata   (i_dslv1_wdata)                 // <   alb_mss_fab
  , .dslv1_wstrb   (i_dslv1_wstrb)                 // <   alb_mss_fab
  , .dslv2_arvalid (i_dslv2_arvalid)               // <   alb_mss_fab
  , .dslv2_araddr  (i_dslv2_araddr)                // <   alb_mss_fab
  , .dslv2_arburst (i_dslv2_arburst)               // <   alb_mss_fab
  , .dslv2_arsize  (i_dslv2_arsize)                // <   alb_mss_fab
  , .dslv2_arlen   (i_dslv2_arlen)                 // <   alb_mss_fab
  , .dslv2_arid    (i_dslv2_arid)                  // <   alb_mss_fab
  , .dslv2_rready  (i_dslv2_rready)                // <   alb_mss_fab
  , .dslv2_awvalid (i_dslv2_awvalid)               // <   alb_mss_fab
  , .dslv2_awaddr  (i_dslv2_awaddr)                // <   alb_mss_fab
  , .dslv2_awburst (i_dslv2_awburst)               // <   alb_mss_fab
  , .dslv2_awsize  (i_dslv2_awsize)                // <   alb_mss_fab
  , .dslv2_awlen   (i_dslv2_awlen)                 // <   alb_mss_fab
  , .dslv2_awid    (i_dslv2_awid)                  // <   alb_mss_fab
  , .dslv2_wvalid  (i_dslv2_wvalid)                // <   alb_mss_fab
  , .dslv2_wdata   (i_dslv2_wdata)                 // <   alb_mss_fab
  , .dslv2_wstrb   (i_dslv2_wstrb)                 // <   alb_mss_fab
  , .dslv2_wlast   (i_dslv2_wlast)                 // <   alb_mss_fab
  , .dslv2_bready  (i_dslv2_bready)                // <   alb_mss_fab
  , .mss_clk       (i_mss_clk)                     // <   alb_mss_clkctrl
  , .rst_b         (i_rst_b)                       // <   alb_mss_clkctrl
  , .dslv1_rdata   (i_dslv1_rdata)                 //   > alb_mss_fab
  , .dslv1_slverr  (i_dslv1_slverr)                //   > alb_mss_fab
  , .dslv1_ready   (i_dslv1_ready)                 //   > alb_mss_fab
  , .dslv2_arready (i_dslv2_arready)               //   > alb_mss_fab
  , .dslv2_rid     (i_dslv2_rid)                   //   > alb_mss_fab
  , .dslv2_rvalid  (i_dslv2_rvalid)                //   > alb_mss_fab
  , .dslv2_rdata   (i_dslv2_rdata)                 //   > alb_mss_fab
  , .dslv2_rresp   (i_dslv2_rresp)                 //   > alb_mss_fab
  , .dslv2_rlast   (i_dslv2_rlast)                 //   > alb_mss_fab
  , .dslv2_awready (i_dslv2_awready)               //   > alb_mss_fab
  , .dslv2_wready  (i_dslv2_wready)                //   > alb_mss_fab
  , .dslv2_bid     (i_dslv2_bid)                   //   > alb_mss_fab
  , .dslv2_bvalid  (i_dslv2_bvalid)                //   > alb_mss_fab
  , .dslv2_bresp   (i_dslv2_bresp)                 //   > alb_mss_fab
  );

// Instantiation of module alb_mss_perfctrl
alb_mss_perfctrl ialb_mss_perfctrl(
    .mss_clk             (i_mss_clk)               // <   alb_mss_clkctrl
  , .rst_b               (i_rst_b)                 // <   alb_mss_clkctrl
  , .mss_perfctrl_sel    (i_mss_perfctrl_sel)      // <   alb_mss_fab
  , .mss_perfctrl_enable (i_mss_perfctrl_enable)   // <   alb_mss_fab
  , .mss_perfctrl_write  (i_mss_perfctrl_write)    // <   alb_mss_fab
  , .mss_perfctrl_addr   (i_mss_perfctrl_addr)     // <   alb_mss_fab
  , .mss_perfctrl_wdata  (i_mss_perfctrl_wdata)    // <   alb_mss_fab
  , .mss_perfctrl_wstrb  (i_mss_perfctrl_wstrb)    // <   alb_mss_fab
  , .mss_fab_perf_awf    (i_mss_fab_perf_awf)      // <   alb_mss_fab
  , .mss_fab_perf_arf    (i_mss_fab_perf_arf)      // <   alb_mss_fab
  , .mss_fab_perf_aw     (i_mss_fab_perf_aw)       // <   alb_mss_fab
  , .mss_fab_perf_ar     (i_mss_fab_perf_ar)       // <   alb_mss_fab
  , .mss_fab_perf_w      (i_mss_fab_perf_w)        // <   alb_mss_fab
  , .mss_fab_perf_wl     (i_mss_fab_perf_wl)       // <   alb_mss_fab
  , .mss_fab_perf_r      (i_mss_fab_perf_r)        // <   alb_mss_fab
  , .mss_fab_perf_rl     (i_mss_fab_perf_rl)       // <   alb_mss_fab
  , .mss_fab_perf_b      (i_mss_fab_perf_b)        // <   alb_mss_fab
  , .mss_mem_perf_awf    (i_mss_mem_perf_awf)      // <   alb_mss_mem
  , .mss_mem_perf_arf    (i_mss_mem_perf_arf)      // <   alb_mss_mem
  , .mss_mem_perf_aw     (i_mss_mem_perf_aw)       // <   alb_mss_mem
  , .mss_mem_perf_ar     (i_mss_mem_perf_ar)       // <   alb_mss_mem
  , .mss_mem_perf_w      (i_mss_mem_perf_w)        // <   alb_mss_mem
  , .mss_mem_perf_wl     (i_mss_mem_perf_wl)       // <   alb_mss_mem
  , .mss_mem_perf_r      (i_mss_mem_perf_r)        // <   alb_mss_mem
  , .mss_mem_perf_rl     (i_mss_mem_perf_rl)       // <   alb_mss_mem
  , .mss_mem_perf_b      (i_mss_mem_perf_b)        // <   alb_mss_mem
  , .mss_perfctrl_rdata  (i_mss_perfctrl_rdata)    //   > alb_mss_fab
  , .mss_perfctrl_slverr (i_mss_perfctrl_slverr)   //   > alb_mss_fab
  , .mss_perfctrl_ready  (i_mss_perfctrl_ready)    //   > alb_mss_fab
  , .mss_fab_cfg_lat_w   (i_mss_fab_cfg_lat_w)     //   > alb_mss_fab
  , .mss_fab_cfg_lat_r   (i_mss_fab_cfg_lat_r)     //   > alb_mss_fab
  , .mss_fab_cfg_wr_bw   (i_mss_fab_cfg_wr_bw)     //   > alb_mss_fab
  , .mss_fab_cfg_rd_bw   (i_mss_fab_cfg_rd_bw)     //   > alb_mss_fab
  , .mss_mem_cfg_lat_w   (i_mss_mem_cfg_lat_w)     //   > alb_mss_mem
  , .mss_mem_cfg_lat_r   (i_mss_mem_cfg_lat_r)     //   > alb_mss_mem
  , .mss_perfctrl_dummy  ()                        //   > unconnected i_mss_perfctrl_dummy
  );

// Instantiation of module alb_mss_mem
alb_mss_mem ialb_mss_mem(
    .mss_clk                (i_mss_clk)            // <   alb_mss_clkctrl
  , .rst_b                  (i_rst_b)              // <   alb_mss_clkctrl
  , .mss_mem_cmd_valid      (i_mss_mem_cmd_valid)  // <   alb_mss_fab
  , .mss_mem_cmd_read       (i_mss_mem_cmd_read)   // <   alb_mss_fab
  , .mss_mem_cmd_addr       (i_mss_mem_cmd_addr)   // <   alb_mss_fab
  , .mss_mem_cmd_wrap       (i_mss_mem_cmd_wrap)   // <   alb_mss_fab
  , .mss_mem_cmd_data_size  (i_mss_mem_cmd_data_size) // <   alb_mss_fab
  , .mss_mem_cmd_burst_size (i_mss_mem_cmd_burst_size) // <   alb_mss_fab
  , .mss_mem_cmd_lock       (i_mss_mem_cmd_lock)   // <   alb_mss_fab
  , .mss_mem_cmd_excl       (i_mss_mem_cmd_excl)   // <   alb_mss_fab
  , .mss_mem_cmd_prot       (i_mss_mem_cmd_prot)   // <   alb_mss_fab
  , .mss_mem_cmd_cache      (i_mss_mem_cmd_cache)  // <   alb_mss_fab
  , .mss_mem_cmd_id         (i_mss_mem_cmd_id)     // <   alb_mss_fab
  , .mss_mem_cmd_user       (i_mss_mem_cmd_user)   // <   alb_mss_fab
  , .mss_mem_cmd_region     (i_mss_mem_cmd_region) // <   alb_mss_fab
  , .mss_mem_rd_accept      (i_mss_mem_rd_accept)  // <   alb_mss_fab
  , .mss_mem_wr_valid       (i_mss_mem_wr_valid)   // <   alb_mss_fab
  , .mss_mem_wr_data        (i_mss_mem_wr_data)    // <   alb_mss_fab
  , .mss_mem_wr_mask        (i_mss_mem_wr_mask)    // <   alb_mss_fab
  , .mss_mem_wr_last        (i_mss_mem_wr_last)    // <   alb_mss_fab
  , .mss_mem_wr_resp_accept (i_mss_mem_wr_resp_accept) // <   alb_mss_fab
  , .mss_mem_cfg_lat_w      (i_mss_mem_cfg_lat_w)  // <   alb_mss_perfctrl
  , .mss_mem_cfg_lat_r      (i_mss_mem_cfg_lat_r)  // <   alb_mss_perfctrl
  , .mss_mem_cmd_accept     (i_mss_mem_cmd_accept) //   > alb_mss_fab
  , .mss_mem_rd_valid       (i_mss_mem_rd_valid)   //   > alb_mss_fab
  , .mss_mem_rd_excl_ok     (i_mss_mem_rd_excl_ok) //   > alb_mss_fab
  , .mss_mem_rd_data        (i_mss_mem_rd_data)    //   > alb_mss_fab
  , .mss_mem_err_rd         (i_mss_mem_err_rd)     //   > alb_mss_fab
  , .mss_mem_rd_last        (i_mss_mem_rd_last)    //   > alb_mss_fab
  , .mss_mem_wr_accept      (i_mss_mem_wr_accept)  //   > alb_mss_fab
  , .mss_mem_wr_done        (i_mss_mem_wr_done)    //   > alb_mss_fab
  , .mss_mem_wr_excl_done   (i_mss_mem_wr_excl_done) //   > alb_mss_fab
  , .mss_mem_err_wr         (i_mss_mem_err_wr)     //   > alb_mss_fab
  , .mss_mem_perf_awf       (i_mss_mem_perf_awf)   //   > alb_mss_perfctrl
  , .mss_mem_perf_arf       (i_mss_mem_perf_arf)   //   > alb_mss_perfctrl
  , .mss_mem_perf_aw        (i_mss_mem_perf_aw)    //   > alb_mss_perfctrl
  , .mss_mem_perf_ar        (i_mss_mem_perf_ar)    //   > alb_mss_perfctrl
  , .mss_mem_perf_w         (i_mss_mem_perf_w)     //   > alb_mss_perfctrl
  , .mss_mem_perf_wl        (i_mss_mem_perf_wl)    //   > alb_mss_perfctrl
  , .mss_mem_perf_r         (i_mss_mem_perf_r)     //   > alb_mss_perfctrl
  , .mss_mem_perf_rl        (i_mss_mem_perf_rl)    //   > alb_mss_perfctrl
  , .mss_mem_perf_b         (i_mss_mem_perf_b)     //   > alb_mss_perfctrl
  , .mss_mem_dummy          ()                     //   > unconnected i_mss_mem_dummy
  );

// Instantiation of module zebu_axi_xtor
zebu_axi_xtor izebu_axi_xtor(
    .mss_clk          (i_mss_clk)                  // <   alb_mss_clkctrl
  , .rst_a            (rst_a)                      // <   io_pad_ring
  , .xtor_axi_awready (i_xtor_axi_awready)         // <   alb_mss_fab
  , .xtor_axi_wready  (i_xtor_axi_wready)          // <   alb_mss_fab
  , .xtor_axi_bid     (i_xtor_axi_bid)             // <   alb_mss_fab
  , .xtor_axi_bresp   (i_xtor_axi_bresp)           // <   alb_mss_fab
  , .xtor_axi_bvalid  (i_xtor_axi_bvalid)          // <   alb_mss_fab
  , .xtor_axi_arready (i_xtor_axi_arready)         // <   alb_mss_fab
  , .xtor_axi_rid     (i_xtor_axi_rid)             // <   alb_mss_fab
  , .xtor_axi_rdata   (i_xtor_axi_rdata)           // <   alb_mss_fab
  , .xtor_axi_rresp   (i_xtor_axi_rresp)           // <   alb_mss_fab
  , .xtor_axi_rlast   (i_xtor_axi_rlast)           // <   alb_mss_fab
  , .xtor_axi_rvalid  (i_xtor_axi_rvalid)          // <   alb_mss_fab
  , .xtor_axi_arid    (i_xtor_axi_arid)            //   > alb_mss_fab
  , .xtor_axi_arvalid (i_xtor_axi_arvalid)         //   > alb_mss_fab
  , .xtor_axi_araddr  (i_xtor_axi_araddr)          //   > alb_mss_fab
  , .xtor_axi_arburst (i_xtor_axi_arburst)         //   > alb_mss_fab
  , .xtor_axi_arsize  (i_xtor_axi_arsize)          //   > alb_mss_fab
  , .xtor_axi_arlen   (i_xtor_axi_arlen)           //   > alb_mss_fab
  , .xtor_axi_arcache (i_xtor_axi_arcache)         //   > alb_mss_fab
  , .xtor_axi_arprot  (i_xtor_axi_arprot)          //   > alb_mss_fab
  , .xtor_axi_rready  (i_xtor_axi_rready)          //   > alb_mss_fab
  , .xtor_axi_awid    (i_xtor_axi_awid)            //   > alb_mss_fab
  , .xtor_axi_awvalid (i_xtor_axi_awvalid)         //   > alb_mss_fab
  , .xtor_axi_awaddr  (i_xtor_axi_awaddr)          //   > alb_mss_fab
  , .xtor_axi_awburst (i_xtor_axi_awburst)         //   > alb_mss_fab
  , .xtor_axi_awsize  (i_xtor_axi_awsize)          //   > alb_mss_fab
  , .xtor_axi_awlen   (i_xtor_axi_awlen)           //   > alb_mss_fab
  , .xtor_axi_awcache (i_xtor_axi_awcache)         //   > alb_mss_fab
  , .xtor_axi_awprot  (i_xtor_axi_awprot)          //   > alb_mss_fab
  , .xtor_axi_wid     (i_xtor_axi_wid)             //   > alb_mss_fab
  , .xtor_axi_wvalid  (i_xtor_axi_wvalid)          //   > alb_mss_fab
  , .xtor_axi_wdata   (i_xtor_axi_wdata)           //   > alb_mss_fab
  , .xtor_axi_wstrb   (i_xtor_axi_wstrb)           //   > alb_mss_fab
  , .xtor_axi_wlast   (i_xtor_axi_wlast)           //   > alb_mss_fab
  , .xtor_axi_bready  (i_xtor_axi_bready)          //   > alb_mss_fab
  , .xtor_axi_awlock  ()                           //   > unconnected i_xtor_axi_awlock
  , .xtor_axi_arlock  ()                           //   > unconnected i_xtor_axi_arlock
  );

// Instantiation of module dw_dbp_stubs
dw_dbp_stubs idw_dbp_stubs(
    .jtag_rtck     (i_jtag_rtck)                   // <   archipelago.dw_dbp
  , .clk           (i_clk)                         // <   alb_mss_clkctrl
  , .dbg_apb_dbgen ()                              //   > unconnected i_dbg_apb_dbgen
  , .dbg_apb_niden ()                              //   > unconnected i_dbg_apb_niden
  );

// Instantiation of module archipelago
archipelago iarchipelago(
    .safety_iso_enb         (i_safety_iso_enb)     // <   alb_mss_ext_stub
  , .dbg_unlock             (i_dbg_unlock)         // <   alb_mss_ext_stub
  , .arc_halt_req_a         (arc_halt_req_a)       // <   io_pad_ring
  , .arc_run_req_a          (arc_run_req_a)        // <   io_pad_ring
  , .test_mode              (test_mode)            // <   io_pad_ring
  , .clk                    (i_clk)                // <   alb_mss_clkctrl
  , .rst_a                  (rst_a)                // <   io_pad_ring
  , .jtag_tck               (jtag_tck)             // <   io_pad_ring
  , .jtag_trst_n            (jtag_trst_n)          // <   io_pad_ring
  , .jtag_tdi               (jtag_tdi)             // <   io_pad_ring
  , .jtag_tms               (jtag_tms)             // <   io_pad_ring
  , .bri_awready            (i_bri_awready)        // <   alb_mss_fab
  , .bri_wready             (i_bri_wready)         // <   alb_mss_fab
  , .bri_bid                (i_bri_bid)            // <   alb_mss_fab
  , .bri_bresp              (i_bri_bresp)          // <   alb_mss_fab
  , .bri_bvalid             (i_bri_bvalid)         // <   alb_mss_fab
  , .bri_arready            (i_bri_arready)        // <   alb_mss_fab
  , .bri_rid                (i_bri_rid)            // <   alb_mss_fab
  , .bri_rdata              (i_bri_rdata)          // <   alb_mss_fab
  , .bri_rlast              (i_bri_rlast)          // <   alb_mss_fab
  , .bri_rvalid             (i_bri_rvalid)         // <   alb_mss_fab
  , .bri_rresp              (i_bri_rresp)          // <   alb_mss_fab
  , .rst_cpu_req_a          (i_rst_cpu_req_a)      // <   alb_mss_ext_stub
  , .LBIST_EN               (i_LBIST_EN)           // <   alb_mss_ext_stub
  , .ahb_hready             (i_ahb_hready)         // <   alb_mss_fab
  , .ahb_hresp              (i_ahb_hresp)          // <   alb_mss_fab
  , .ahb_hexokay            (i_ahb_hexokay)        // <   alb_mss_fab
  , .ahb_hrdata             (i_ahb_hrdata)         // <   alb_mss_fab
  , .ahb_hreadychk          (i_ahb_hreadychk)      // <   alb_mss_fab
  , .ahb_hrespchk           (i_ahb_hrespchk)       // <   alb_mss_fab
  , .ahb_hrdatachk          (i_ahb_hrdatachk)      // <   alb_mss_fab
  , .dbu_per_ahb_hready     (i_dbu_per_ahb_hready) // <   alb_mss_fab
  , .dbu_per_ahb_hresp      (i_dbu_per_ahb_hresp)  // <   alb_mss_fab
  , .dbu_per_ahb_hexokay    (i_dbu_per_ahb_hexokay) // <   alb_mss_fab
  , .dbu_per_ahb_hrdata     (i_dbu_per_ahb_hrdata) // <   alb_mss_fab
  , .dbu_per_ahb_hreadychk  (i_dbu_per_ahb_hreadychk) // <   alb_mss_fab
  , .dbu_per_ahb_hrespchk   (i_dbu_per_ahb_hrespchk) // <   alb_mss_fab
  , .dbu_per_ahb_hrdatachk  (i_dbu_per_ahb_hrdatachk) // <   alb_mss_fab
  , .iccm_ahb_prio          (i_iccm_ahb_prio)      // <   alb_mss_ext_stub
  , .iccm_ahb_hmastlock     (i_iccm_ahb_hmastlock) // <   alb_mss_ext_stub
  , .iccm_ahb_hexcl         (i_iccm_ahb_hexcl)     // <   alb_mss_ext_stub
  , .iccm_ahb_hmaster       (i_iccm_ahb_hmaster)   // <   alb_mss_ext_stub
  , .iccm_ahb_hsel          (i_iccm_ahb_hsel)      // <   alb_mss_fab
  , .iccm_ahb_htrans        (i_iccm_ahb_htrans)    // <   alb_mss_fab
  , .iccm_ahb_hwrite        (i_iccm_ahb_hwrite)    // <   alb_mss_fab
  , .iccm_ahb_haddr         (i_iccm_ahb_haddr)     // <   alb_mss_fab
  , .iccm_ahb_hsize         (i_iccm_ahb_hsize)     // <   alb_mss_fab
  , .iccm_ahb_hwstrb        (i_iccm_ahb_hwstrb)    // <   alb_mss_ext_stub
  , .iccm_ahb_hburst        (i_iccm_ahb_hburst)    // <   alb_mss_fab
  , .iccm_ahb_hprot         (i_iccm_ahb_hprot)     // <   alb_mss_ext_stub
  , .iccm_ahb_hnonsec       (i_iccm_ahb_hnonsec)   // <   alb_mss_ext_stub
  , .iccm_ahb_hwdata        (i_iccm_ahb_hwdata)    // <   alb_mss_fab
  , .iccm_ahb_hready        (i_iccm_ahb_hready)    // <   alb_mss_fab
  , .iccm_ahb_haddrchk      (i_iccm_ahb_haddrchk)  // <   alb_mss_fab
  , .iccm_ahb_htranschk     (i_iccm_ahb_htranschk) // <   alb_mss_fab
  , .iccm_ahb_hctrlchk1     (i_iccm_ahb_hctrlchk1) // <   alb_mss_fab
  , .iccm_ahb_hctrlchk2     (i_iccm_ahb_hctrlchk2) // <   alb_mss_fab
  , .iccm_ahb_hwstrbchk     (i_iccm_ahb_hwstrbchk) // <   alb_mss_fab
  , .iccm_ahb_hprotchk      (i_iccm_ahb_hprotchk)  // <   alb_mss_fab
  , .iccm_ahb_hreadychk     (i_iccm_ahb_hreadychk) // <   alb_mss_fab
  , .iccm_ahb_hselchk       (i_iccm_ahb_hselchk)   // <   alb_mss_ext_stub
  , .iccm_ahb_hwdatachk     (i_iccm_ahb_hwdatachk) // <   alb_mss_fab
  , .dccm_ahb_prio          (i_dccm_ahb_prio)      // <   alb_mss_ext_stub
  , .dccm_ahb_hmastlock     (i_dccm_ahb_hmastlock) // <   alb_mss_ext_stub
  , .dccm_ahb_hexcl         (i_dccm_ahb_hexcl)     // <   alb_mss_ext_stub
  , .dccm_ahb_hmaster       (i_dccm_ahb_hmaster)   // <   alb_mss_ext_stub
  , .dccm_ahb_hsel          (i_dccm_ahb_hsel)      // <   alb_mss_fab
  , .dccm_ahb_htrans        (i_dccm_ahb_htrans)    // <   alb_mss_fab
  , .dccm_ahb_hwrite        (i_dccm_ahb_hwrite)    // <   alb_mss_fab
  , .dccm_ahb_haddr         (i_dccm_ahb_haddr)     // <   alb_mss_fab
  , .dccm_ahb_hsize         (i_dccm_ahb_hsize)     // <   alb_mss_fab
  , .dccm_ahb_hwstrb        (i_dccm_ahb_hwstrb)    // <   alb_mss_ext_stub
  , .dccm_ahb_hnonsec       (i_dccm_ahb_hnonsec)   // <   alb_mss_ext_stub
  , .dccm_ahb_hburst        (i_dccm_ahb_hburst)    // <   alb_mss_fab
  , .dccm_ahb_hprot         (i_dccm_ahb_hprot)     // <   alb_mss_ext_stub
  , .dccm_ahb_hwdata        (i_dccm_ahb_hwdata)    // <   alb_mss_fab
  , .dccm_ahb_hready        (i_dccm_ahb_hready)    // <   alb_mss_fab
  , .dccm_ahb_haddrchk      (i_dccm_ahb_haddrchk)  // <   alb_mss_fab
  , .dccm_ahb_htranschk     (i_dccm_ahb_htranschk) // <   alb_mss_fab
  , .dccm_ahb_hctrlchk1     (i_dccm_ahb_hctrlchk1) // <   alb_mss_fab
  , .dccm_ahb_hctrlchk2     (i_dccm_ahb_hctrlchk2) // <   alb_mss_fab
  , .dccm_ahb_hwstrbchk     (i_dccm_ahb_hwstrbchk) // <   alb_mss_fab
  , .dccm_ahb_hprotchk      (i_dccm_ahb_hprotchk)  // <   alb_mss_fab
  , .dccm_ahb_hreadychk     (i_dccm_ahb_hreadychk) // <   alb_mss_fab
  , .dccm_ahb_hselchk       (i_dccm_ahb_hselchk)   // <   alb_mss_ext_stub
  , .dccm_ahb_hwdatachk     (i_dccm_ahb_hwdatachk) // <   alb_mss_fab
  , .mmio_ahb_prio          (i_mmio_ahb_prio)      // <   alb_mss_ext_stub
  , .mmio_ahb_hmastlock     (i_mmio_ahb_hmastlock) // <   alb_mss_ext_stub
  , .mmio_ahb_hexcl         (i_mmio_ahb_hexcl)     // <   alb_mss_ext_stub
  , .mmio_ahb_hmaster       (i_mmio_ahb_hmaster)   // <   alb_mss_ext_stub
  , .mmio_ahb_hsel          (i_mmio_ahb_hsel)      // <   alb_mss_fab
  , .mmio_ahb_htrans        (i_mmio_ahb_htrans)    // <   alb_mss_fab
  , .mmio_ahb_hwrite        (i_mmio_ahb_hwrite)    // <   alb_mss_fab
  , .mmio_ahb_haddr         (i_mmio_ahb_haddr)     // <   alb_mss_fab
  , .mmio_ahb_hsize         (i_mmio_ahb_hsize)     // <   alb_mss_fab
  , .mmio_ahb_hwstrb        (i_mmio_ahb_hwstrb)    // <   alb_mss_ext_stub
  , .mmio_ahb_hnonsec       (i_mmio_ahb_hnonsec)   // <   alb_mss_ext_stub
  , .mmio_ahb_hburst        (i_mmio_ahb_hburst)    // <   alb_mss_fab
  , .mmio_ahb_hprot         (i_mmio_ahb_hprot)     // <   alb_mss_ext_stub
  , .mmio_ahb_hwdata        (i_mmio_ahb_hwdata)    // <   alb_mss_fab
  , .mmio_ahb_hready        (i_mmio_ahb_hready)    // <   alb_mss_fab
  , .mmio_ahb_haddrchk      (i_mmio_ahb_haddrchk)  // <   alb_mss_fab
  , .mmio_ahb_htranschk     (i_mmio_ahb_htranschk) // <   alb_mss_fab
  , .mmio_ahb_hctrlchk1     (i_mmio_ahb_hctrlchk1) // <   alb_mss_fab
  , .mmio_ahb_hctrlchk2     (i_mmio_ahb_hctrlchk2) // <   alb_mss_fab
  , .mmio_ahb_hwstrbchk     (i_mmio_ahb_hwstrbchk) // <   alb_mss_fab
  , .mmio_ahb_hprotchk      (i_mmio_ahb_hprotchk)  // <   alb_mss_fab
  , .mmio_ahb_hreadychk     (i_mmio_ahb_hreadychk) // <   alb_mss_fab
  , .mmio_ahb_hselchk       (i_mmio_ahb_hselchk)   // <   alb_mss_ext_stub
  , .mmio_ahb_hwdatachk     (i_mmio_ahb_hwdatachk) // <   alb_mss_fab
  , .mmio_base_in           (i_mmio_base_in)       // <   alb_mss_ext_stub
  , .reset_pc_in            (i_reset_pc_in)        // <   alb_mss_ext_stub
  , .rnmi_a                 (i_rnmi_a)             // <   alb_mss_ext_stub
  , .ext_trig_output_accept (i_ext_trig_output_accept) // <   alb_mss_ext_stub
  , .ext_trig_in            (i_ext_trig_in)        // <   alb_mss_ext_stub
  , .dmsi_valid             (i_dmsi_valid)         // <   alb_mss_ext_stub
  , .dmsi_context           (i_dmsi_context)       // <   alb_mss_ext_stub
  , .dmsi_eiid              (i_dmsi_eiid)          // <   alb_mss_ext_stub
  , .dmsi_domain            (i_dmsi_domain)        // <   alb_mss_ext_stub
  , .dmsi_valid_chk         (i_dmsi_valid_chk)     // <   alb_mss_ext_stub
  , .dmsi_data_edc          (i_dmsi_data_edc)      // <   alb_mss_ext_stub
  , .wid_rlwid              (i_wid_rlwid)          // <   alb_mss_ext_stub
  , .wid_rwiddeleg          (i_wid_rwiddeleg)      // <   alb_mss_ext_stub
  , .soft_reset_prepare_a   (i_soft_reset_prepare_a) // <   alb_mss_ext_stub
  , .soft_reset_req_a       (i_soft_reset_req_a)   // <   alb_mss_ext_stub
  , .rst_init_disable_a     (i_rst_init_disable_a) // <   alb_mss_ext_stub
  , .arcnum                 (arcnum)               // <   io_pad_ring
  , .ref_clk                (ref_clk)              // <   io_pad_ring
  , .wdt_clk                (i_wdt_clk)            // <   alb_mss_clkctrl
  , .ahb_htrans             (i_ahb_htrans)         //   > alb_mss_fab
  , .ahb_hwrite             (i_ahb_hwrite)         //   > alb_mss_fab
  , .ahb_haddr              (i_ahb_haddr)          //   > alb_mss_fab
  , .ahb_hsize              (i_ahb_hsize)          //   > alb_mss_fab
  , .ahb_hburst             (i_ahb_hburst)         //   > alb_mss_fab
  , .ahb_hprot              (i_ahb_hprot)          //   > alb_mss_fab
  , .ahb_hnonsec            (i_ahb_hnonsec)        //   > alb_mss_fab
  , .ahb_hexcl              (i_ahb_hexcl)          //   > alb_mss_ext_stub
  , .ahb_hmaster            (i_ahb_hmaster)        //   > alb_mss_ext_stub
  , .ahb_hwdata             (i_ahb_hwdata)         //   > alb_mss_fab
  , .ahb_hwstrb             (i_ahb_hwstrb)         //   > alb_mss_fab
  , .ahb_haddrchk           (i_ahb_haddrchk)       //   > alb_mss_ext_stub
  , .ahb_htranschk          (i_ahb_htranschk)      //   > alb_mss_ext_stub
  , .ahb_hctrlchk1          (i_ahb_hctrlchk1)      //   > alb_mss_ext_stub
  , .ahb_hprotchk           (i_ahb_hprotchk)       //   > alb_mss_ext_stub
  , .dbu_per_ahb_htrans     (i_dbu_per_ahb_htrans) //   > alb_mss_fab
  , .dbu_per_ahb_hwrite     (i_dbu_per_ahb_hwrite) //   > alb_mss_fab
  , .dbu_per_ahb_haddr      (i_dbu_per_ahb_haddr)  //   > alb_mss_fab
  , .dbu_per_ahb_hsize      (i_dbu_per_ahb_hsize)  //   > alb_mss_fab
  , .dbu_per_ahb_hburst     (i_dbu_per_ahb_hburst) //   > alb_mss_fab
  , .dbu_per_ahb_hprot      (i_dbu_per_ahb_hprot)  //   > alb_mss_fab
  , .dbu_per_ahb_hnonsec    (i_dbu_per_ahb_hnonsec) //   > alb_mss_fab
  , .dbu_per_ahb_hexcl      (i_dbu_per_ahb_hexcl)  //   > alb_mss_ext_stub
  , .dbu_per_ahb_hmaster    (i_dbu_per_ahb_hmaster) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hwdata     (i_dbu_per_ahb_hwdata) //   > alb_mss_fab
  , .dbu_per_ahb_hwstrb     (i_dbu_per_ahb_hwstrb) //   > alb_mss_fab
  , .dbu_per_ahb_haddrchk   (i_dbu_per_ahb_haddrchk) //   > alb_mss_ext_stub
  , .dbu_per_ahb_htranschk  (i_dbu_per_ahb_htranschk) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hctrlchk1  (i_dbu_per_ahb_hctrlchk1) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hprotchk   (i_dbu_per_ahb_hprotchk) //   > alb_mss_ext_stub
  , .bri_arid               (i_bri_arid)           //   > alb_mss_fab
  , .bri_arvalid            (i_bri_arvalid)        //   > alb_mss_fab
  , .bri_araddr             (i_bri_araddr)         //   > alb_mss_fab
  , .bri_arburst            (i_bri_arburst)        //   > alb_mss_fab
  , .bri_arsize             (i_bri_arsize)         //   > alb_mss_fab
  , .bri_arlen              (i_bri_arlen)          //   > alb_mss_fab
  , .bri_arcache            (i_bri_arcache)        //   > alb_mss_fab
  , .bri_arprot             (i_bri_arprot)         //   > alb_mss_fab
  , .bri_rready             (i_bri_rready)         //   > alb_mss_fab
  , .bri_awid               (i_bri_awid)           //   > alb_mss_fab
  , .bri_awvalid            (i_bri_awvalid)        //   > alb_mss_fab
  , .bri_awaddr             (i_bri_awaddr)         //   > alb_mss_fab
  , .bri_awburst            (i_bri_awburst)        //   > alb_mss_fab
  , .bri_awsize             (i_bri_awsize)         //   > alb_mss_fab
  , .bri_awlen              (i_bri_awlen)          //   > alb_mss_fab
  , .bri_awcache            (i_bri_awcache)        //   > alb_mss_fab
  , .bri_awprot             (i_bri_awprot)         //   > alb_mss_fab
  , .bri_wid                (i_bri_wid)            //   > alb_mss_fab
  , .bri_wvalid             (i_bri_wvalid)         //   > alb_mss_fab
  , .bri_wdata              (i_bri_wdata)          //   > alb_mss_fab
  , .bri_wstrb              (i_bri_wstrb)          //   > alb_mss_fab
  , .bri_wlast              (i_bri_wlast)          //   > alb_mss_fab
  , .bri_bready             (i_bri_bready)         //   > alb_mss_fab
  , .iccm_ahb_hrdata        (i_iccm_ahb_hrdata)    //   > alb_mss_fab
  , .iccm_ahb_hresp         (i_iccm_ahb_hresp)     //   > alb_mss_fab
  , .iccm_ahb_hreadyout     (i_iccm_ahb_hreadyout) //   > alb_mss_fab
  , .dccm_ahb_hrdata        (i_dccm_ahb_hrdata)    //   > alb_mss_fab
  , .dccm_ahb_hresp         (i_dccm_ahb_hresp)     //   > alb_mss_fab
  , .dccm_ahb_hreadyout     (i_dccm_ahb_hreadyout) //   > alb_mss_fab
  , .mmio_ahb_hrdata        (i_mmio_ahb_hrdata)    //   > alb_mss_fab
  , .mmio_ahb_hresp         (i_mmio_ahb_hresp)     //   > alb_mss_fab
  , .mmio_ahb_hreadyout     (i_mmio_ahb_hreadyout) //   > alb_mss_fab
  , .iccm_ahb_hexokay       (i_iccm_ahb_hexokay)   //   > alb_mss_ext_stub
  , .iccm_ahb_fatal_err     (i_iccm_ahb_fatal_err) //   > alb_mss_ext_stub
  , .iccm_ahb_hrespchk      (i_iccm_ahb_hrespchk)  //   > alb_mss_ext_stub
  , .iccm_ahb_hreadyoutchk  (i_iccm_ahb_hreadyoutchk) //   > alb_mss_ext_stub
  , .iccm_ahb_hrdatachk     (i_iccm_ahb_hrdatachk) //   > alb_mss_ext_stub
  , .dccm_ahb_hexokay       (i_dccm_ahb_hexokay)   //   > alb_mss_ext_stub
  , .dccm_ahb_fatal_err     (i_dccm_ahb_fatal_err) //   > alb_mss_ext_stub
  , .dccm_ahb_hrespchk      (i_dccm_ahb_hrespchk)  //   > alb_mss_ext_stub
  , .dccm_ahb_hreadyoutchk  (i_dccm_ahb_hreadyoutchk) //   > alb_mss_ext_stub
  , .dccm_ahb_hrdatachk     (i_dccm_ahb_hrdatachk) //   > alb_mss_ext_stub
  , .mmio_ahb_hexokay       (i_mmio_ahb_hexokay)   //   > alb_mss_ext_stub
  , .mmio_ahb_fatal_err     (i_mmio_ahb_fatal_err) //   > alb_mss_ext_stub
  , .mmio_ahb_hrespchk      (i_mmio_ahb_hrespchk)  //   > alb_mss_ext_stub
  , .mmio_ahb_hreadyoutchk  (i_mmio_ahb_hreadyoutchk) //   > alb_mss_ext_stub
  , .mmio_ahb_hrdatachk     (i_mmio_ahb_hrdatachk) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hmastlock  (i_dbu_per_ahb_hmastlock) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hauser     (i_dbu_per_ahb_hauser) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hauserchk  (i_dbu_per_ahb_hauserchk) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hctrlchk2  (i_dbu_per_ahb_hctrlchk2) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hwstrbchk  (i_dbu_per_ahb_hwstrbchk) //   > alb_mss_ext_stub
  , .dbu_per_ahb_hwdatachk  (i_dbu_per_ahb_hwdatachk) //   > alb_mss_ext_stub
  , .dbu_per_ahb_fatal_err  (i_dbu_per_ahb_fatal_err) //   > alb_mss_ext_stub
  , .high_prio_ras          (i_high_prio_ras)      //   > alb_mss_ext_stub
  , .ahb_hmastlock          (i_ahb_hmastlock)      //   > alb_mss_ext_stub
  , .ahb_hauser             (i_ahb_hauser)         //   > alb_mss_ext_stub
  , .ahb_hauserchk          (i_ahb_hauserchk)      //   > alb_mss_ext_stub
  , .ahb_hctrlchk2          (i_ahb_hctrlchk2)      //   > alb_mss_ext_stub
  , .ahb_hwstrbchk          (i_ahb_hwstrbchk)      //   > alb_mss_ext_stub
  , .ahb_hwdatachk          (i_ahb_hwdatachk)      //   > alb_mss_ext_stub
  , .ahb_fatal_err          (i_ahb_fatal_err)      //   > alb_mss_ext_stub
  , .wdt_reset0             (i_wdt_reset0)         //   > alb_mss_ext_stub
  , .wdt_reset_wdt_clk0     (i_wdt_reset_wdt_clk0) //   > alb_mss_ext_stub
  , .reg_wr_en0             (i_reg_wr_en0)         //   > alb_mss_ext_stub
  , .critical_error         (i_critical_error)     //   > alb_mss_ext_stub
  , .ext_trig_output_valid  (i_ext_trig_output_valid) //   > alb_mss_ext_stub
  , .dmsi_rdy               (i_dmsi_rdy)           //   > alb_mss_ext_stub
  , .dmsi_rdy_chk           (i_dmsi_rdy_chk)       //   > alb_mss_ext_stub
  , .soft_reset_ready       (i_soft_reset_ready)   //   > alb_mss_ext_stub
  , .soft_reset_ack         (i_soft_reset_ack)     //   > alb_mss_ext_stub
  , .rst_cpu_ack            (i_rst_cpu_ack)        //   > alb_mss_ext_stub
  , .cpu_in_reset_state     (i_cpu_in_reset_state) //   > alb_mss_ext_stub
  , .safety_mem_dbe         (i_safety_mem_dbe)     //   > alb_mss_ext_stub
  , .safety_mem_sbe         (i_safety_mem_sbe)     //   > alb_mss_ext_stub
  , .safety_isol_change     (i_safety_isol_change) //   > alb_mss_ext_stub
  , .safety_error           (i_safety_error)       //   > alb_mss_ext_stub
  , .safety_enabled         (i_safety_enabled)     //   > alb_mss_ext_stub
  , .jtag_rtck              (i_jtag_rtck)          //   > dw_dbp_stubs
  , .arc_halt_ack           (arc_halt_ack)         //   > io_pad_ring
  , .arc_run_ack            (arc_run_ack)          //   > io_pad_ring
  , .sys_halt_r             (sys_halt_r)           //   > io_pad_ring
  , .sys_sleep_r            (sys_sleep_r)          //   > io_pad_ring
  , .sys_sleep_mode_r       (sys_sleep_mode_r)     //   > io_pad_ring
  , .jtag_tdo               (jtag_tdo)             //   > io_pad_ring
  , .jtag_tdo_oe            (jtag_tdo_oe)          //   > io_pad_ring
  );

// Output drives
assign clk = i_clk;
endmodule
