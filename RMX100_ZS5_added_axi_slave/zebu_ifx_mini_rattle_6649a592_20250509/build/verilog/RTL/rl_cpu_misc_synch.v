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
//  The cpu misc synch module implements synchronizers for CPU async inputs.
//
//  This file is indented with 2 space characters per tab.
//
// ===========================================================================

// Set simulation timescale
//
`include "defines.v"
`include "const.def"

module rl_cpu_misc_synch (
  output  dm2arc_halt_req_synch_r,
  output  dm2arc_run_req_synch_r,
  output  dm2arc_relaxedpriv_synch_r,
  output  safety_iso_enb_synch_r,
  output  rnmi_synch_r,
  input   dm2arc_halt_req_a,
  input   dm2arc_run_req_a,
  input   dm2arc_relaxedpriv_a,
  input   safety_iso_enb_a,
  input   rnmi_a,
  output      cpu_misc_synch_parity_error,
  input       clk,
  input       rst
);


//Synchronizers

wire dm2arc_halt_req_pty_err;
//Add Synchronizer for dm2arc_halt_req_a
cdc_synch_wrap u_cdc_synch_dm2arc_halt_req (
  .clk        (clk          ), 
  .rst        (rst          ),
  .din        (dm2arc_halt_req_a       ),
  .parity_error       (dm2arc_halt_req_pty_err ),
  .dout       (dm2arc_halt_req_synch_r )
);

wire dm2arc_run_req_pty_err;
//Add Synchronizer for dm2arc_run_req_a
cdc_synch_wrap u_cdc_synch_dm2arc_run_req (
  .clk        (clk          ), 
  .rst        (rst          ),
  .din        (dm2arc_run_req_a       ),
  .parity_error       (dm2arc_run_req_pty_err ),
  .dout       (dm2arc_run_req_synch_r )
);

wire dm2arc_relaxedpriv_pty_err;
//Add Synchronizer for dm2arc_relaxedpriv_a
cdc_synch_wrap u_cdc_synch_dm2arc_relaxedpriv (
  .clk        (clk          ), 
  .rst        (rst          ),
  .din        (dm2arc_relaxedpriv_a       ),
  .parity_error       (dm2arc_relaxedpriv_pty_err ),
  .dout       (dm2arc_relaxedpriv_synch_r )
);

wire safety_iso_enb_pty_err;
//Add Synchronizer for safety_iso_enb_a
cdc_synch_wrap u_cdc_synch_safety_iso_enb (
  .clk        (clk          ), 
  .rst        (rst          ),
  .din        (safety_iso_enb_a       ),
  .parity_error       (safety_iso_enb_pty_err ),
  .dout       (safety_iso_enb_synch_r )
);

wire rnmi_pty_err;
//Add Synchronizer for rnmi_a
cdc_synch_wrap u_cdc_synch_rnmi (
  .clk        (clk          ), 
  .rst        (rst          ),
  .din        (rnmi_a       ),
  .parity_error       (rnmi_pty_err ),
  .dout       (rnmi_synch_r )
);



// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: Sequential convergence found
// SJ:  The convergence sources are independent to each other without logical dependency
assign cpu_misc_synch_parity_error = 1'b0  
                                     |dm2arc_halt_req_pty_err|dm2arc_run_req_pty_err|dm2arc_relaxedpriv_pty_err|safety_iso_enb_pty_err|rnmi_pty_err ; 
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ

endmodule
