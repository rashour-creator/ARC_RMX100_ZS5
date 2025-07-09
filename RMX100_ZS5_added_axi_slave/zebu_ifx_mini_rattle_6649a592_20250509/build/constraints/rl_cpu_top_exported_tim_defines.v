// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//----------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Variable definitions
//------------------------------------------------------------------------------















// ------------------------------------------------------------------------------
//  Safety   2-wire   Prop-policy
//      0     0        yes   		(i.e jtag_tck needed in core and top SDC)
//      0     1        no     		(i.e jtag_tck only needed in core  SDC)
//      1     0        top-only    	(i.e jtag_tck only needed in top  SDC)
//      1     1        -          	(i.e jtag_tck provided in archipelago SDC via the 2-wire jtag tim defines)

// ------------------------------------------------------------------------------
// Clocks
// ------------------------------------------------------------------------------

//     `let watchdog_period =  1000/`WATCHDOG_CLK_FREQ;     
//`let REF_CLOCKPERIOD_CLK2 = FLOOR(1000/`WATCHDOG_CLK_FREQ);






//`define ARCV5EM_CLK_NUMBER            2


`define ARCV5EM_CLK_MODULE            rl_cpu_top
`define ARCV5EM_CLK0_NAME             clk
`define ARCV5EM_CLK0_PERIOD           50.000
`define ARCV5EM_CLK0_SKEW             0.200
`define ARCV5EM_CLK0_HOLDMARGIN       0.050
`define ARCV5EM_CLK0_TRANSITION       0.1
`define ARCV5EM_CLK0_PORT_NAME        clk
`define ARCV5EM_CLK0_DOMAIN           main



#For virtual clock, no  clock  port needs to  be defined. Only period. Waveform is optional.Domain option can be use to get async effect in set_clock_groups
`define ARCV5EM_CLK1_NAME	          vir_async_clk
`define ARCV5EM_CLK1_PERIOD	        50.000
`define ARCV5EM_CLK1_VIRTUAL         yes
`define ARCV5EM_CLK1_DOMAIN	        vir_async_clk

//`define ARCV5EM_CLK1_WAVEFORM        0 25.000

`define ARCV5EM_CLK2_NAME             ref_clk
`define ARCV5EM_CLK2_PERIOD           50.000
`define ARCV5EM_CLK2_SKEW             0.200
`define ARCV5EM_CLK2_HOLDMARGIN       0.050
`define ARCV5EM_CLK2_TRANSITION       0.1
`define ARCV5EM_CLK2_PORT_NAME        ref_clk
`define ARCV5EM_CLK2_DOMAIN           ref_clk

`define ARCV5EM_CLK3_NAME             wdt_clk
`define ARCV5EM_CLK3_PERIOD           50.000
`define ARCV5EM_CLK3_SKEW             0.200
`define ARCV5EM_CLK3_HOLDMARGIN       0.050
`define ARCV5EM_CLK3_TRANSITION       0.1
`define ARCV5EM_CLK3_PORT_NAME        wdt_clk
`define ARCV5EM_CLK3_DOMAIN           wdt_clk


`define ARCV5EM_CLK_NUMBER            4



// ------------------------------------------------------------------------------
// Generated Clocks
// ------------------------------------------------------------------------------
////////////////////////////     not needed  -  clock gate is for power saving only

//`let  num_gclk = 0

//`if (`HAS_ICCM0 == 1) // {
//`let skew =0.200
//`let hold_margin = 0.050


//`define ARCV5EM_GCLK_MODULE           cpu_safety_controller

//`define ARCV5EM_GCLK::`num_gclk::_NAME	     iccm0_even_clk_g
//`define ARCV5EM_GCLK::`num_gclk::_EDGES	     1 2 3 
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_CLK      clk
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_PORT     clk
//`define ARCV5EM_GCLK::`num_gclk::_PIN_NAME	     *u_clkgate_iccm_even/clk_gate0/Q
//`define ARCV5EM_GCLK::`num_gclk::_SKEW	 `skew
//`define ARCV5EM_GCLK::`num_gclk::_HOLDMARGIN  `hold_margin 

//`let num_gclk = `num_gclk + 1 
//
//`define ARCV5EM_GCLK::`num_gclk::_NAME	       iccm0_odd_clk_g
//`define ARCV5EM_GCLK::`num_gclk::_EDGES	       1 2 3
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_CLK      clk
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_PORT     clk
//`define ARCV5EM_GCLK::`num_gclk::_PIN_NAME        *u_clkgate_iccm_odd/clk_gate0/Q
//`define ARCV5EM_GCLK::`num_gclk::_SKEW	   `skew
//`define ARCV5EM_GCLK::`num_gclk::_HOLDMARGIN  `hold_margin 
//
//`let num_gclk = `num_gclk + 1 
//
//`endif		// }
//
//
//`if (`HAS_DCCM == 1) // {
//`let skew =0.200
//`let hold_margin = 0.050
//
//
//`define ARCV5EM_GCLK_MODULE	   cpu_safety_controller
//
//
//`define ARCV5EM_GCLK::`num_gclk::_NAME	       dccm_even_clk_g
//`define ARCV5EM_GCLK::`num_gclk::_EDGES	       1 2 3 
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_CLK      clk
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_PORT     clk
//`define ARCV5EM_GCLK::`num_gclk::_PIN_NAME        *u_clkgate_dccm_even/clk_gate0/Q
//`define ARCV5EM_GCLK::`num_gclk::_SKEW	   `skew
//`define ARCV5EM_GCLK::`num_gclk::_HOLDMARGIN  `hold_margin 
//
//`let num_gclk = `num_gclk + 1 
//
//`define ARCV5EM_GCLK::`num_gclk::_NAME	       dccm_odd_clk_g
//`define ARCV5EM_GCLK::`num_gclk::_EDGES	       1 2 3
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_CLK      clk
//`define ARCV5EM_GCLK::`num_gclk::_MASTER_PORT     clk
//`define ARCV5EM_GCLK::`num_gclk::_PIN_NAME        *u_clkgate_dccm_odd/clk_gate0/Q
//`define ARCV5EM_GCLK::`num_gclk::_SKEW	   `skew
//`define ARCV5EM_GCLK::`num_gclk::_HOLDMARGIN  `hold_margin 

//`let num_gclk = `num_gclk + 1 

//`endif                // }
//`define ARCV5EM_GCLK_NUMBER  `num_gclk

////////////////////////////////////////////////////////////////////


`define ARCV5EM_IP_MODULE     rl_cpu_top
`define ARCV5EM_IP0_INPUT     *
`define ARCV5EM_IP0_CLK       clk
`define ARCV5EM_IP0_DELAY     0.25
`define ARCV5EM_IP0_PCT_DELAY yes
`define ARCV5EM_IP0_ADD_DELAY no
`define ARCV5EM_IP_NUMBER     1

`define ARCV5EM_PM_IP_NUMBER  1     

`define ARCV5EM_PM_IP_PREFIX     
`define ARCV5EM_PM_IP0_PROP      yes
`define ARCV5EM_PM_IP0_INPUT     test_mode
`define ARCV5EM_PM_IP0_REMOVE    test_mode
`define ARCV5EM_PM_IP0_CLK       clk
`define ARCV5EM_PM_IP0_DELAY     0.25
`define ARCV5EM_PM_IP0_PCT_DELAY yes
`define ARCV5EM_PM_IP0_ADD_DELAY no

`define ARCV5EM_LB_IP_NUMBER  1     

`define ARCV5EM_LB_IP_PREFIX     
`define ARCV5EM_LB_IP0_PROP      yes
`define ARCV5EM_LB_IP0_INPUT     LBIST_EN
`define ARCV5EM_LB_IP0_REMOVE    LBIST_EN
`define ARCV5EM_LB_IP0_CLK       clk
`define ARCV5EM_LB_IP0_DELAY     0.25
`define ARCV5EM_LB_IP0_PCT_DELAY yes
`define ARCV5EM_LB_IP0_ADD_DELAY no


`define ARCV5EM_AN_IP_NUMBER  1     

`define ARCV5EM_AN_IP_PREFIX     
`define ARCV5EM_AN_IP0_PROP      yes
`define ARCV5EM_AN_IP0_INPUT     arcnum*
`define ARCV5EM_AN_IP0_REMOVE    arcnum*
`define ARCV5EM_AN_IP0_CLK       clk
`define ARCV5EM_AN_IP0_DELAY     0.25
`define ARCV5EM_AN_IP0_PCT_DELAY yes
`define ARCV5EM_AN_IP0_ADD_DELAY no


`define ARCV5EM_ASYNC_IP_MODULE       rl_cpu_top

//`define ARCV5EM_ASYNC_IP0_PROP      top_only
//`define ARCV5EM_ASYNC_IP0_INPUT	  arc_*req_a
//`define ARCV5EM_ASYNC_IP0_CLK	   vir_async_clk
//`define ARCV5EM_ASYNC_IP0_ASYNC	  yes
//`define ARCV5EM_ASYNC_IP0_DELAY	  0.25
//`define ARCV5EM_ASYNC_IP0_PCT_DELAY yes
//`define ARCV5EM_ASYNC_IP0_ADD_DELAY no
//`let num_async_inputs = 0 + 1

`define ARCV5EM_ASYNC_IP0_PROP      top_only
`define ARCV5EM_ASYNC_IP0_INPUT	  rst_a
`define ARCV5EM_ASYNC_IP0_CLK	   vir_async_clk
`define ARCV5EM_ASYNC_IP0_ASYNC	  yes
`define ARCV5EM_ASYNC_IP0_DELAY	  0.25
`define ARCV5EM_ASYNC_IP0_PCT_DELAY yes
`define ARCV5EM_ASYNC_IP0_ADD_DELAY no

`define ARCV5EM_ASYNC_IP1_PROP      top_only
`define ARCV5EM_ASYNC_IP1_INPUT	  rst_cpu_req_a
`define ARCV5EM_ASYNC_IP1_CLK	   vir_async_clk
`define ARCV5EM_ASYNC_IP1_ASYNC	  yes
`define ARCV5EM_ASYNC_IP1_DELAY	  0.25
`define ARCV5EM_ASYNC_IP1_PCT_DELAY yes
`define ARCV5EM_ASYNC_IP1_ADD_DELAY no

`define ARCV5EM_ASYNC_IP2_PROP      top_only
`define ARCV5EM_ASYNC_IP2_INPUT	  soft_reset_prepare_a
`define ARCV5EM_ASYNC_IP2_CLK	   vir_async_clk
`define ARCV5EM_ASYNC_IP2_ASYNC	  yes
`define ARCV5EM_ASYNC_IP2_DELAY	  0.25
`define ARCV5EM_ASYNC_IP2_PCT_DELAY yes
`define ARCV5EM_ASYNC_IP2_ADD_DELAY no

`define ARCV5EM_ASYNC_IP3_PROP      top_only
`define ARCV5EM_ASYNC_IP3_INPUT	  soft_reset_req_a
`define ARCV5EM_ASYNC_IP3_CLK	   vir_async_clk
`define ARCV5EM_ASYNC_IP3_ASYNC	  yes
`define ARCV5EM_ASYNC_IP3_DELAY	  0.25
`define ARCV5EM_ASYNC_IP3_PCT_DELAY yes
`define ARCV5EM_ASYNC_IP3_ADD_DELAY no

`define ARCV5EM_ASYNC_IP4_PROP      top_only
`define ARCV5EM_ASYNC_IP4_INPUT	  rst_init_disable_a
`define ARCV5EM_ASYNC_IP4_CLK	   vir_async_clk
`define ARCV5EM_ASYNC_IP4_ASYNC	  yes
`define ARCV5EM_ASYNC_IP4_DELAY	  0.25
`define ARCV5EM_ASYNC_IP4_PCT_DELAY yes
`define ARCV5EM_ASYNC_IP4_ADD_DELAY no


`define ARCV5EM_ASYNC_IP5_PROP      top_only
`define ARCV5EM_ASYNC_IP5_INPUT	  rnmi_a
`define ARCV5EM_ASYNC_IP5_CLK	   vir_async_clk
`define ARCV5EM_ASYNC_IP5_ASYNC	  yes
`define ARCV5EM_ASYNC_IP5_DELAY	  0.25
`define ARCV5EM_ASYNC_IP5_PCT_DELAY yes
`define ARCV5EM_ASYNC_IP5_ADD_DELAY no



`define ARCV5EM_ASYNC_IP_NUMBER 6 


// ----------------------------------------------------------------------------
// Output delay
//--------------------
`define ARCV5EM_OP_NUMBER    1
`define ARCV5EM_OP_PREFIX     
`define ARCV5EM_OP_MODULE     rl_cpu_top
`define ARCV5EM_OP0_OUTPUT    *
`define ARCV5EM_OP0_CLK       clk
`define ARCV5EM_OP0_DELAY     0.25


`define WDT_OP_NUMBER         1
`define WDT_OP0_PROP          top_only
`define WDT_OP0_OUTPUT        wdt_reset_wdt_clk0
`define WDT_OP0_CLK           wdt_clk
`define WDT_OP0_DELAY         0.25
`define WDT_OP0_PCT_DELAY     yes
`define WDT_OP0_ADD_DELAY     no

// ----------------------------------------------------------------------------
// False path
//-------------------------------------------------------
`define ARCV5EM_RST_FP_PREFIX

`define ARCV5EM_RST_FP_MODULE       cpu_top_safety_controller

`define ARCV5EM_RST_FP_NUMBER 0


`define ARCV5EM_FP0_FROM_PORT   rst_cpu_req_a
`define ARCV5EM_FP0_REMARK   # Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint
//`define ARCV5EM_FP1_FROM_PORT   arc_halt_req_a
//`let fp_num = 1 + 1
//`define ARCV5EM_FP1_FROM_PORT   arc_run_req_a
//`let fp_num = 1 + 1
`define ARCV5EM_FP1_FROM_PORT   soft_reset_prepare_a
`define ARCV5EM_FP1_REMARK   # Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint

`define ARCV5EM_FP2_FROM_PORT   soft_reset_req_a
`define ARCV5EM_FP2_REMARK   # Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint

`define ARCV5EM_FP3_FROM_PORT   rst_init_disable_a
`define ARCV5EM_FP3_REMARK   # Explanation :  Quasi-static signal. This input will be tied off before reset to a certain value and hence be a constant start-point. 

`define ARCV5EM_FP4_FROM_PORT   rnmi_a
`define ARCV5EM_FP4_REMARK   # Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint



`define ARCV5EM_FP_NUMBER 5

// ----------------------------------------------------------------------------
// Case analysis
// -----------------------------------------------------------------------------
`define ARCV5EM_CA_PREFIX   
`define ARCV5EM_CA_MODULE   rl_cpu_top
`define ARCV5EM_CA0_PORT    test_mode
`define ARCV5EM_CA0_VALUE   0
`define ARCV5EM_CA1_PORT    *LBIST_EN
`define ARCV5EM_CA1_VALUE   0
`define ARCV5EM_CA2_PORT    arcnum*
`define ARCV5EM_CA2_VALUE   0
`define ARCV5EM_CA_NUMBER   3


