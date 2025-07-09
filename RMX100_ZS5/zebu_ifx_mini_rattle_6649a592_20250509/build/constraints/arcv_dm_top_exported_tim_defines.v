// Library ARC_Soc_Trace-1.0.999999999
`include "arcv_dm_defines.v"



// ------------------------------------------------------------------------------
// Clocks
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// Generated Clocks
// ------------------------------------------------------------------------------
////////////////////////////     not needed  -  clock gate is for power saving only



// ----------------------------------------------------------------------------
// Input delay
//--------------------
`define ARCV_DM_TOP_IP_MODULE     arcv_dm_top



`define ARCV_DM_TOP_IP0_INPUT     dbg_unlock*
`define ARCV_DM_TOP_IP0_CLK       clk
`define ARCV_DM_TOP_IP0_DELAY     0.25
`define ARCV_DM_TOP_IP0_PCT_DELAY yes
`define ARCV_DM_TOP_IP0_ADD_DELAY no



`define ARCV_DM_TOP_IP_NUMBER     1

`define ARCV_DM_TOP_ASYNC_IP_MODULE     arcv_dm_top
`define ARCV_DM_TOP_ASYNC_IP0_PROP      top_only
`define ARCV_DM_TOP_ASYNC_IP0_INPUT     *arc_halt_req_a
`define ARCV_DM_TOP_ASYNC_IP0_CLK       vir_async_clk
`define ARCV_DM_TOP_ASYNC_IP0_ASYNC     yes
`define ARCV_DM_TOP_ASYNC_IP0_DELAY     0.25
`define ARCV_DM_TOP_ASYNC_IP0_PCT_DELAY yes
`define ARCV_DM_TOP_ASYNC_IP0_ADD_DELAY no

`define ARCV_DM_TOP_ASYNC_IP1_PROP      top_only
`define ARCV_DM_TOP_ASYNC_IP1_INPUT     *arc_run_req_a
`define ARCV_DM_TOP_ASYNC_IP1_CLK       vir_async_clk
`define ARCV_DM_TOP_ASYNC_IP1_ASYNC     yes
`define ARCV_DM_TOP_ASYNC_IP1_DELAY     0.25
`define ARCV_DM_TOP_ASYNC_IP1_PCT_DELAY yes
`define ARCV_DM_TOP_ASYNC_IP1_ADD_DELAY no


`define ARCV_DM_TOP_ASYNC_IP2_PROP      top_only
`define ARCV_DM_TOP_ASYNC_IP2_INPUT     safety_iso_enb[0]
`define ARCV_DM_TOP_ASYNC_IP2_CLK       vir_async_clk
`define ARCV_DM_TOP_ASYNC_IP2_ASYNC     yes
`define ARCV_DM_TOP_ASYNC_IP2_DELAY     0.25
`define ARCV_DM_TOP_ASYNC_IP2_PCT_DELAY yes
`define ARCV_DM_TOP_ASYNC_IP2_ADD_DELAY no

`define ARCV_DM_TOP_ASYNC_IP3_PROP      top_only
`define ARCV_DM_TOP_ASYNC_IP3_INPUT     safety_iso_enb[1]
`define ARCV_DM_TOP_ASYNC_IP3_CLK       vir_async_clk
`define ARCV_DM_TOP_ASYNC_IP3_ASYNC     yes
`define ARCV_DM_TOP_ASYNC_IP3_DELAY     0.25
`define ARCV_DM_TOP_ASYNC_IP3_PCT_DELAY yes
`define ARCV_DM_TOP_ASYNC_IP3_ADD_DELAY no

`define ARCV_DM_TOP_ASYNC_IP_NUMBER     4


// ----------------------------------------------------------------------------
// Output delay
//--------------------
`define ARCV_DM_TOP_OP_MODULE     arcv_dm_top



`define ARCV_DM_TOP_OP0_OUTPUT    safety_isol_change*
`define ARCV_DM_TOP_OP0_CLK       clk
`define ARCV_DM_TOP_OP0_DELAY     0.25

              
`define ARCV_DM_TOP_OP_NUMBER     1




// ----------------------------------------------------------------------------
// False path
//-------------------------------------------------------

`define ARCV_DM_TOP_RST_FP_MODULE       arcv_dm_top

`define ARCV_DM_TOP_RST_FP0_PROP        yes
`define ARCV_DM_TOP_RST_FP0_FROM_PORT   rst_a
`define ARCV_DM_TOP_RST_FP0_THROUGH     *u_rst_cdc_s_sync_r_s*U_SAMPLE_META*sample_meta*

`define ARCV_DM_TOP_RST_FP1_PROP        yes
`define ARCV_DM_TOP_RST_FP1_FROM_PORT   rst_a
`define ARCV_DM_TOP_RST_FP1_THROUGH     *u_presetdbg_cdc_s*U_SAMPLE_META*sample_meta*

`define ARCV_DM_TOP_RST_FP_NUMBER 2

`define ARCV_DM_TOP_FP_MODULE       arcv_dm_top
`define ARCV_DM_TOP_FP0_FROM_PORT   *arc_halt_req_a
`define ARCV_DM_TOP_FP1_FROM_PORT   *arc_run_req_a
`define ARCV_DM_TOP_FP2_REMARK      # safety_iso_enb[0] is an async input signal, will be CDC synchronized before use 
`define ARCV_DM_TOP_FP2_FROM_PORT   safety_iso_enb[0]
`define ARCV_DM_TOP_FP3_REMARK      # safety_iso_enb[1] is an async input signal, will be CDC synchronized before use 
`define ARCV_DM_TOP_FP3_FROM_PORT   safety_iso_enb[1]
`define ARCV_DM_TOP_FP4_TO_CELL   *u_safety_iso_enb_pclk_s_sync*U_SAMPLE_META*sample_meta*
`define ARCV_DM_TOP_FP5_THROUGH   *arc2dm_halt_ack
`define ARCV_DM_TOP_FP6_THROUGH   *arc2dm_run_ack
`define ARCV_DM_TOP_FP7_THROUGH   *arc2dm_havereset_a
`define ARCV_DM_TOP_FP8_THROUGH   *hart_unavailable
`define ARCV_DM_TOP_FP9_THROUGH   *sys_halt_r
`define ARCV_DM_TOP_FP10_THROUGH   ndmreset_a
`define ARCV_DM_TOP_FP11_THROUGH   *dm2arc_halt_on_reset_a


`define ARCV_DM_TOP_FP_NUMBER 12

// ----------------------------------------------------------------------------
// Case analysis
// -----------------------------------------------------------------------------
`define ARCV_DM_TOP_CA_PREFIX   
`define ARCV_DM_TOP_CA_MODULE   arcv_dm_top
`define ARCV_DM_TOP_CA0_PORT    test_mode
`define ARCV_DM_TOP_CA0_VALUE   0
`define ARCV_DM_TOP_CA_NUMBER   1
