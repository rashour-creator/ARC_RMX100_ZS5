//----------------------------------------------------------------------------
//
// Copyright (C) 2016 Synopsys, Inc. All rights reserved.
//
// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
module rascal_pipemon(
    input clk /* verilator public_flat */
    );

reg [3:0] enabled = 4'b0011; // Enable debug instrs(0); - (0); Suppress transcript (1); enable statistics gathering (1).

// passing arguments by parameters, or NCSim will report errors.
localparam options =  320 | (1<<6) | (1 << 24) | (1<<9) | (1<<11) ;
localparam constant_prefix = "";

initial 
$pipemon_arcv2(
    clk,
    enabled,
   "board.icore_chip.icore_sys.iarchipelago.icpu_top_safety_controller.u_main_rl_cpu_top.u_rl_core",
    options,    	// options
    "",  // unique name prefix provided for pipemon trace purposes.
    // This is a placeholder.  We currently do not use it: bit 8 of
    // options is not set.
    "rascal_pdisp_signals.txt",
    
    "trace.txt"
    );
endmodule
