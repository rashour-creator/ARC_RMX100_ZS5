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
module dm_src_sync_rx 
  #(
  parameter SYNC_FF_LEVELS = `DM_SYNC_FF_LEVELS,    // SYNC_FF_LEVELS >= 2
  parameter SYNC_FF_WIDTH  = `DM_SYNC_FF_WIDTH     // SYNC_FF_WIDTH >= 1
  )
  (
  input   clk,         // target (receiving) clock domain clk
  input   rst_a,

  input   tx_reqi,     //tx out
  output  rx_acki,     //rx in

  output reg tx_req_srx,      //tx in   
  input   rx_accept,      //rx out   


  input  [SYNC_FF_WIDTH-1:0] sync_data_i,
  output [SYNC_FF_WIDTH-1:0] sync_data_o
);


  reg [SYNC_FF_LEVELS:0]  din_sync_r;
  reg [SYNC_FF_WIDTH-1:0] sync_data_r;
  reg                     din_txreq_r ;    
  reg                     rx_accept_r ;    
  wire                    rx_accept_p; 

  always @(posedge tx_reqi or posedge rst_a)
    begin : rx_datao_sync_PROC
      if (rst_a == 1'b1)
        begin
           sync_data_r <= {SYNC_FF_WIDTH{1'b0}}; //ack to deassert tx_req
           din_txreq_r <= {1'b0};
        end
      else
        begin
           sync_data_r <= sync_data_i; //ack to deassert tx_req
           din_txreq_r <= ~din_txreq_r;     
        end
    end 
  always @(posedge clk or posedge rst_a)
    begin : rx_accept_r_PROC
      if (rst_a == 1'b1)
        begin
           rx_accept_r <= {1'b0};
        end
      else
        begin
           rx_accept_r <= rx_accept;
        end
    end  //tx_req_r_PROC      
assign rx_accept_p = !rx_accept_r && rx_accept;  

  assign sync_data_o = tx_req_srx? sync_data_r : {SYNC_FF_WIDTH{1'b0}}; 
  always @(posedge clk or posedge rst_a)
    begin : tx_reqi_sync_PROC
      if (rst_a == 1'b1)
        begin
           din_sync_r <= {(SYNC_FF_LEVELS+1){1'b0}};
           tx_req_srx <= 1'b0;

        end
      else
        begin
// spyglass disable_block STARC05-1.4.3.4
// SMD: using source sync circuit on receive side.
// SJ:  ClkSigToNonClkPin               
           din_sync_r <= {din_sync_r[SYNC_FF_LEVELS-1:0], din_txreq_r  };
// spyglass enable_block STARC05-1.4.3.4              
           if (din_sync_r[SYNC_FF_LEVELS] ^ din_sync_r[SYNC_FF_LEVELS-1] )  //req posedge
             tx_req_srx <= 1'b1;
           else if(rx_accept)   
             tx_req_srx <= 1'b0;
        end
    end

     dm_ssync_clkgate u_clkgate(.clk_in         (!clk),
                                .clock_enable_r (rx_accept_p),
                                .clk_out        (rx_acki));    
endmodule // cdc_sync
