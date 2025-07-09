
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
// @f:arcv_timer_synch
//
// Description:
// @p
//   timer clock crossing module.
// @e
//
// ===========================================================================
`include "defines.v"
`include "const.def"

module arcv_timer_synch
  #(
  parameter RST_TMR_CDC        = 0    
  )
 (
  output  tm_clk_enable_sync,
  input   ref_clk,
 input                     clk,
 input                     test_mode,
 input                     rst
 );

//Reset Sychronizer in ref_clk domain
logic sync_tm_rst_n;
logic rst_tm_synch_r;
ls_cdc_sync #(
	.TMR_CDC(RST_TMR_CDC)) u_tm_rst_cdc_sync
(
.clk   (ref_clk),
.rst_a (rst    ),
.din   (1'b1   ),
.dout  (sync_tm_rst_n)
);
//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived as BCM is used for reset synch, test_mode overwrite is already added
//spyglass disable_block W402b
//SMD: Reset is gated or internally generated
//SJ : test_mode overwrite is already added for gating
assign rst_tm_synch_r = test_mode
                 ? rst
                 : ~sync_tm_rst_n
                 ;
//spyglass enable_block W402b
//spyglass enable_block TA_09                                 

// spyglass disable_block Ar_glitch01 
// SMD: Report glitch in reset paths
// SJ: if TMR is enabled, the tripple synchronized reset signal will go through majority vote. 
// But it doesn't matters if the de-assertion of reset is one cycle ealier or later,this warning can be ignored.
// Glitch can be ignored
// spyglass disable_block Reset_check07 INTEGRITY_RESET_GLITCH
// SMD: Clear pin of sequential element is driven by combinational logic
// SJ: designed on purpose when TMR is enabled. 
//T-Flop
logic tm_clk_enable_r, tm_clk_enable_nxt;
always_ff @( posedge ref_clk or posedge rst_tm_synch_r )
begin: T_Flop_PROC
  if(rst_tm_synch_r) 
    tm_clk_enable_r <= 1'b0;
  else              
    tm_clk_enable_r <= tm_clk_enable_nxt;
end
// spyglass enable_block Reset_check07 INTEGRITY_RESET_GLITCH
// spyglass enable_block Ar_glitch01 

assign tm_clk_enable_nxt = ~tm_clk_enable_r;

//CDC from ref_clk domain to clk domain
ls_cdc_sync u_tm_clk_enable_cdc_sync	(
     .clk   (clk),
     .rst_a (rst),
     .din   (tm_clk_enable_r),
     .dout  (tm_clk_enable_sync)
     );

endmodule
