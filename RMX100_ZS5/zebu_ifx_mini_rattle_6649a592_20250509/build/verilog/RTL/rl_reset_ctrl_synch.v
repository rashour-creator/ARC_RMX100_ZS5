// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2024 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2014, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
// ===========================================================================
//
// Description: 
//  
//  The reset_ctrl synch module implements synchronizers for reset ctrl inputs.
//
//  This file is indented with 2 space characters per tab.
//
// ===========================================================================

// Set simulation timescale
//
`include "defines.v"
`include "const.def"

module rl_reset_ctrl_synch
  #(
  parameter RST_TMR_CDC        = 0    
  )
(
  output  soft_reset_req_synch_r,
  output  soft_reset_prepare_synch_r,
  output  ndmreset_synch_r,
  output  dm2arc_hartreset_synch_r,
  output  dm2arc_hartreset2_synch_r,
  output  dm2arc_havereset_ack_synch_r,
  output  dm2arc_halt_on_reset_synch_r,
  output  rst_init_disable_synch_r,
  output  rst_cpu_req_synch_r,
  output  rst_synch_r,
  input   soft_reset_req_a,
  input   soft_reset_prepare_a,
  input   ndmreset_a,
  input   dm2arc_hartreset_a,
  input   dm2arc_hartreset2_a,
  input   dm2arc_havereset_ack_a,
  input   dm2arc_halt_on_reset_a,
  input   rst_init_disable_a,
  input   rst_cpu_req_a,
  input   rst_a,
  input   test_mode,
  input   LBIST_EN,
  input       clk          // clock input for this reset domain
);
////////////////////////////////////////////////////////////////////////////
//                                                              //
// Instantiate the reset synchronizer for rst_a                 //
//                                                              //
////////////////////////////////////////////////////////////////////////////

wire synch_rst_n;   // synchronized active-low reset output of sync module
wire synch_rst;     // synchronously de-asserted active-high top-level reset
ls_cdc_sync #(
	.TMR_CDC(RST_TMR_CDC)) u_rst_cdc_sync
(
  .clk        (clk          ),
  .rst_a      (rst_a        ),
  .din        (1'b1         ),
  .dout       (synch_rst_n  )
);


//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived as BCM is used for reset synch, test_mode overwrite is already added
assign rst_synch_r = LBIST_EN | test_mode
                 ? rst_a
                 : ~synch_rst_n
                 ;
//spyglass enable_block TA_09                                 

////////////////////////////////////////////////////////////////////////////
//                                                              //
// Instantiate synchronizers for the asynchronous reset request inputs    //
//                                                              //
////////////////////////////////////////////////////////////////////////////

//Synchronizers

//Add Synchronizer for rst_cpu_req_a
cdc_synch_wrap u_cdc_synch_rst_cpu_req (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (rst_cpu_req_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (rst_cpu_req_synch_r )
);

//Add Synchronizer for soft_reset_req_a
cdc_synch_wrap u_cdc_synch_soft_reset_req (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (soft_reset_req_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (soft_reset_req_synch_r )
);

//Add Synchronizer for soft_reset_prepare_a
cdc_synch_wrap u_cdc_synch_soft_reset_prepare (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (soft_reset_prepare_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (soft_reset_prepare_synch_r )
);

//Add Synchronizer for dm2arc_hartreset_a
cdc_synch_wrap u_cdc_synch_dm2arc_hartreset (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (dm2arc_hartreset_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (dm2arc_hartreset_synch_r )
);

//Add Synchronizer for dm2arc_hartreset2_a
cdc_synch_wrap u_cdc_synch_dm2arc_hartreset2 (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (dm2arc_hartreset2_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (dm2arc_hartreset2_synch_r )
);

//Add Synchronizer for ndmreset_a
cdc_synch_wrap u_cdc_synch_ndmreset (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (ndmreset_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (ndmreset_synch_r )
);

//Add Synchronizer for dm2arc_havereset_ack_a
cdc_synch_wrap u_cdc_synch_dm2arc_havereset_ack (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (dm2arc_havereset_ack_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (dm2arc_havereset_ack_synch_r )
);

//Add Synchronizer for dm2arc_halt_on_reset_a
cdc_synch_wrap u_cdc_synch_dm2arc_halt_on_reset (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (dm2arc_halt_on_reset_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (dm2arc_halt_on_reset_synch_r )
);

//Add Synchronizer for rst_init_disable_a
cdc_synch_wrap u_cdc_synch_rst_init_disable (
  .clk        (clk          ), 
  .rst        (rst_synch_r          ),
  .din        (rst_init_disable_a       ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: reset request related signal synchronizer need glitch free nature of 3-stage windowes synchronize and leave error signal unconnected as safety monitor will be resetted
  .parity_error       (),
// spyglass enable_block UnloadedOutTerm-ML
  .dout       (rst_init_disable_synch_r )
);

endmodule
