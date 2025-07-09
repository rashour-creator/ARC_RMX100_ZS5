// Library ARC_Soc_Trace-1.0.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
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
// source synchronizer
// ===========================================================================
//
// Description:
//
// Source Synchronizer for a clock-domain crossing input/output signal (async input/output).
// The number synchronizing FF levels is controlled by SYNC_FF_LEVELS.
//
// Note: This is a behavioral block that may be replaced by the RDF flow before
// synthesis. The replacement block intantiates the propoer synchronizer cell
// of the synthesis library
//
// ===========================================================================

`include "arcv_dm_defines.v"
// Set simulation timescale
//
`include "const.def"
module dm_src_sync_tx 
  #(
  parameter SYNC_FF_LEVELS = `DM_SYNC_FF_LEVELS,    // SYNC_FF_LEVELS >= 2
  parameter SYNC_FF_WIDTH  = `DM_SYNC_FF_WIDTH
  )

  (
  input   clk,         // target (receiving) clock domain clk
  input   rst_a,

  input   tx_req,      //tx in   
  output  rx_ack_stx,      //rx out   
  output  tx_reqi,     //tx out
  input   rx_acki,     //rx in

  input     [SYNC_FF_WIDTH-1:0] sync_data_i,
  output reg[SYNC_FF_WIDTH-1:0] sync_data_o
);
  reg  [SYNC_FF_LEVELS:0]         din_sync_r ;    
  reg                               din_ack_r ;    
  reg                               tx_req_r ;    
  reg                               tx_req_r2 ;    
  wire                              tx_req_p;
  wire                              tx_req_p_d;
  always @(posedge rx_acki or posedge rst_a)
    begin : rx_ack_ssync_PROC
      if (rst_a == 1'b1)
        begin
           din_ack_r <= {1'b0};
        end
      else
        begin
           din_ack_r <= ~din_ack_r;
        end
    end    
  always @(posedge clk or posedge rst_a)
    begin : tx_req_r_PROC
      if (rst_a == 1'b1)
        begin
           tx_req_r <= {1'b0};
           tx_req_r2 <= {1'b0};
        end
      else
        begin
           tx_req_r <= tx_req;
           tx_req_r2 <= tx_req_r;
        end
    end  //tx_req_r_PROC      
assign tx_req_p   = !tx_req_r  && tx_req;
assign tx_req_p_d = !tx_req_r2 && tx_req_r;

  always @(posedge clk or posedge rst_a)
    begin : rx_ack_sync_PROC
      if (rst_a == 1'b1)
        begin
           din_sync_r <= {(SYNC_FF_LEVELS+1){1'b0}};
        end
      else
        begin
           din_sync_r <= {din_sync_r[SYNC_FF_LEVELS-1:0], din_ack_r };
        end
    end

  assign rx_ack_stx = din_sync_r[SYNC_FF_LEVELS] ^ din_sync_r[SYNC_FF_LEVELS-1];
// spyglass disable_block Ac_glitch04
// SMD: destination can glitch
// SJ:  static 
always @(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    sync_data_o <= {SYNC_FF_WIDTH{1'b0}};
  end
  else
  begin
// spyglass disable_block Ac_unsync01
// SMD: Unsynchronized Crossing
// SJ:  static    
// spyglass enable_block Ac_unsync01
// spyglass disable_block Ac_unsync02 Ac_conv01
// SMD: Unsynchronized Crossing
// SJ:  static enable
// spyglass disable_block Ac_glitch03
// SMD: destination can glitch
// SJ: tx_req is synced   
    if (tx_req_p) begin
      sync_data_o <= sync_data_i;
// spyglass enable_block Ac_glitch03
// spyglass enable_block Ac_unsync02 Ac_conv01  
    end  
  end
end
// spyglass enable_block Ac_glitch04     


dm_ssync_clkgate u_clkgate
(
.clk_in         (!clk),
.clock_enable_r (tx_req_p_d),
.clk_out        (tx_reqi)
);

endmodule // cdc_sync
