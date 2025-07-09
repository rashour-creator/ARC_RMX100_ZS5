// Library ARC_Soc_Trace-1.0.999999999
`include "dw_dbp_defines.v"
`include "defines.v"



`define DW_DBP_MODULE                   dw_dbp
`define DW_DBP_CLK_MODULE               dw_dbp
`define DW_DBP_GCLK_MODULE              dw_dbp
`define DW_DBP_IP_MODULE                dw_dbp
`define DW_DBP_PM_IP_MODULE             dw_dbp
`define DW_DBP_OP_MODULE                dw_dbp
`define DW_DBP_RST_IP_MODULE            dw_dbp
`define DW_DBP_RST_FP_MODULE            dw_dbp
`define DW_DBP_FP_MODULE                dw_dbp
`define DW_DBP_ASYNC_IP_MODULE          dw_dbp
`define DW_DBP_CLKSYNC_MAXDELAY_MODULE  dw_dbp


 `define DW_DBP_CLK0_NAME        jtag_tck
 `define DW_DBP_CLK0_PERIOD      100.000
 `define DW_DBP_CLK0_SKEW        0.200
 `define DW_DBP_CLK0_HOLDMARGIN  0.050
 `define DW_DBP_CLK0_TRANSITION  0.1
 `define DW_DBP_CLK0_PORT_NAME   jtag_tck
 `define DW_DBP_CLK0_DOMAIN      jtag

 `define DW_DBP_IP0_PROP      top_only    
 `define DW_DBP_IP0_INPUT     jtag_*
 `define DW_DBP_IP0_CLK       jtag_tck
 `define DW_DBP_IP0_DELAY     0.25
 `define DW_DBP_IP0_PCT_DELAY yes
 `define DW_DBP_IP0_ADD_DELAY no

 `define DW_DBP_OP0_PROP      top_only
 `define DW_DBP_OP0_OUTPUT    *jtag_tdo*
 `define DW_DBP_OP0_CLK       jtag_tck
 `define DW_DBP_OP0_DELAY     0.25
 `define DW_DBP_OP0_PCT_DELAY yes
 `define DW_DBP_OP0_ADD_DELAY no

 `define DW_DBP_OP1_PROP      top_only
 `define DW_DBP_OP1_OUTPUT    *jtag_rtck*
 `define DW_DBP_OP1_CLK       clk
 `define DW_DBP_OP1_DELAY     0.25
 `define DW_DBP_OP1_PCT_DELAY yes
 `define DW_DBP_OP1_ADD_DELAY no

 `define DW_DBP_CLKSYNC_MAXDELAY_NUMBER       1
 `define DW_DBP_CLKSYNC_MAXDELAY0_FROM_CELL    *u_jtag_port/u_alb_debug_port/i_do_bvci_cycle_r_reg
 `define DW_DBP_CLKSYNC_MAXDELAY0_TO_CELL      *u_jtag_port/u_alb_sys_clk_sync/u_cdc_sync_*/sample_meta*

 `define DW_DBP_CLKSYNC_MAXDELAY0_VALUE      [expr 0.4*50.000]
 `define DW_DBP_CLKSYNC_MINDELAY0_VALUE      [expr 0.200]



 `define DW_DBP_RST_FP0_PROP        yes
 `define DW_DBP_RST_FP0_FROM_PORT   rst_a
 `define DW_DBP_RST_FP0_THROUGH     *reset_ctrl*U_SAMPLE_META*sample_meta*


  


`define DW_DBP_IP_NUMBER            1
`define DW_DBP_PM_IP_NUMBER         0
`define DW_DBP_OP_NUMBER            2
`define DW_DBP_CLK_NUMBER           1
`define DW_DBP_GCLK_NUMBER          0
`define DW_DBP_RST_IP_NUMBER        0
`define DW_DBP_RST_FP_NUMBER        1
`define DW_DBP_FP_NUMBER            0
`define DW_DBP_ASYNC_IP_NUMBER      0

// ----------------------------------------------------------------------------
// Case analysis
// -----------------------------------------------------------------------------
`define DW_DBP_CA_PREFIX   
`define DW_DBP_CA_MODULE   DW_DBP
`define DW_DBP_CA0_PORT    test_mode
`define DW_DBP_CA0_VALUE   0
`define DW_DBP_CA_NUMBER   1
