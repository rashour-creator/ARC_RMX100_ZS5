// Library ARC_Soc_Trace-1.0.999999999
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
//
// Copyright (C) 2013 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
// #####   ######   ####   ######   #####           ####    #####  #####   #
// #    #  #       #       #          #            #    #     #    #    #  #
// #    #  #####    ####   #####      #            #          #    #    #  #
// #####   #            #  #          #            #          #    #####   #
// #   #   #       #    #  #          #            #    #     #    #   #   #
// #    #  ######   ####   ######     #   #######   ####      #    #    #  ######
// ===========================================================================
//
// Description:
//  The dwt_reset_ctrl module provides synchronous deassertion of the
//  asynchronous reset input. This is to ensure that the global asyn reset
//  meets the reset revovery time of the FFs to avoid metastability.
//  The reset output is fully asynchronous in test mode as the FFs are bypassed
//
// ===========================================================================

// leda NTL_RST06 off
// LMD: Avoid internally generated resets
// LJ: We do need to synchronize the rst_a

// spyglass disable_block Reset_sync02
// SMD: rst_a (clk) used to reset rst_n (rtt_clk)
// SJ: clk & rtt_clk are the same clock, just with separate inputs to allow top level independent gating

// spyglass disable_block Reset_sync04 W402b
// SMD: Asynchronous reset signal 'rst_a' is synchronized at least twice
// SJ:  We do need to synchronize the rst_a

// spyglass disable_block Reset_check07
// SMD: Clear pin of sequential element 'rst_n' is driven by combinational logic
// SJ:  Converting active high rst_a to active low rst_n

// spyglass disable_block Ar_glitch01
// SMD: Signal u_rtt_rst_cdc_sync_r.din_sync_r[1] driving 'clear' pin of element 'archipelago.irtt.rtt_on_chip_mem_base[0]' has glitch
// SJ:  test_mode is static during functional mode and will not glitch reset

// spyglass disable_block Topology_03
// MD: We do need to synchronize the rst_a

module dwt_reset_ctrl
 #(
 // Positive active reset synchronizer
     parameter POS_ACTIVE_RST = 1,
  parameter INV_INPUT = 0         
  )
 (
// spyglass disable_block FlopDataConstant LogicDepth MergeFlops-ML
input  clk,            // clock
input  rst_a,          // External reset
output rst,            // reset
input  test_mode       // test mode to bypass FFs
);

wire rst_in;
wire rst_out;
wire rst_test;

assign rst_in = INV_INPUT ^ (POS_ACTIVE_RST ? rst_a : ~rst_a);
assign rst_s = POS_ACTIVE_RST ? ~rst_out : rst_out;
assign rst_test = INV_INPUT  ? ~rst_a : rst_a;

//////////////////////////////////////////////////////////////////
// Synchronizing flip-flops (with async clear function)
wire rst_n;        // active low reset output of 2nd sync FF
dw_dbp_cdc_sync u_rtt_rst_cdc_sync_r (
                                   .clk   (clk),
                                   .rst_a (rst_in),
                                   .din   (1'b1),
                                   .dout  (rst_out)
                                  );
assign rst = test_mode ? rst_test : rst_s;

endmodule
// spyglass enable_block FlopDataConstant LogicDepth MergeFlops-ML
// leda NTL_RST06 on    

// spyglass enable_block Reset_sync02
// spyglass enable_block Reset_sync04 W402b
// spyglass enable_block Reset_check07
// spyglass enable_block Ar_glitch01
// spyglass enable_block Topology_03
