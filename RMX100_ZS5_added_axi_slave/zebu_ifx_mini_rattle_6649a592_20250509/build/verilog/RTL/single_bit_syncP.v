// Library safety-1.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2015-2024 Synopsys, Inc. All rights reserved.
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
// Safety Synchronizer
// ===========================================================================
//
// Description:
//
// 2-bit Synchronizer for a clock-domain crossing input signal (async input).
// A cycle extender is used to generate a mux select 
// Single bits are converted to 2-bits (in,in); Output is a sync'd version of (in).
// This module only checks parity
// Latency is 3 cycles
// Safety Analysis:
// Any bit flips in the synchronizer of extender stage do not affect the output
// since the held value will be recirculated unless the output of the synchronizer
// matches the extender
// The recirculate stage is protected by parity
//
// Note: This is a behavioral block that may be replaced by the RDF flow before
// synthesis. The replacement block intantiates the propoer synchronizer cell
// of the synthesis library
//
// ===========================================================================

`include "rv_safety_defines.v"
`include "const.def"


module single_bit_syncP
  (
  input   		clk,         // target (receiving) clock domain clk
  input   		rst,

  input   	 	din,

  output  		dout,
  output reg  		parity_error
  );

   reg 			 dout_parity_chk;
   reg 			 extend_dout;		

   wire [1:0] 		 mx_sel;
   reg [1:0] 		 mx_in;
   reg [1:0] 		 mx_out_r;
   wire                  stage_dout;
   
   localparam SFTY_SYNC_CDC_FF_LEVELS_IRQ = (`SFTY_SYNC_CDC_FF_LEVELS>2) ? `SFTY_SYNC_CDC_FF_LEVELS-1 : `SFTY_SYNC_CDC_FF_LEVELS;
   ls_cdc_sync #(
     .WIDTH(1), 
     .F_SYNC_TYPE(SFTY_SYNC_CDC_FF_LEVELS_IRQ), 
     .VERIF_EN(`SFTY_DW_CDC_VERIF_EN), 
     .SVA_TYPE(`SFTY_DW_CDC_SVA_TYPE), 
     .TMR_CDC(`SFTY_SYNC_TMR_CDC)
   ) u_cdc_sync_bits(
     .clk   (clk),
     .rst_a (rst),
     .din   (din),
     .dout  (stage_dout)
   );  

  //Extender Stage 
  always @(posedge clk or posedge rst)
     begin: sync_extend_PROC
	if (rst == 1'b1)
	  extend_dout <= 1'b0;
	else
	  extend_dout <= stage_dout;
     end

   assign mx_sel = {extend_dout, stage_dout};   

   always @*
     begin
     case (mx_sel)
       2'b00:
	 mx_in = 2'b00;
       2'b01: //Safe
	 mx_in = mx_out_r;
       2'b10: //Safe
	 mx_in = mx_out_r;
       2'b11: 
	 mx_in = 2'b11;
       endcase
     end // always @ *

// spyglass disable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH
// SMD: reset pin is driven by combinational logic
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so it's intended combinational logic on reset pins and it will not have glitch issue which is proved through vcspyglass formal engine.  
  //Recirculation Stage
   always @(posedge clk or posedge rst)
     begin: recirculate_PROC
	if (rst == 1'b1)
	  mx_out_r <= 2'b00;
	else
	  mx_out_r <= mx_in;
     end
// spyglass enable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH

   assign dout = mx_in[0];

   always @*
     begin : parity_2_PROC
	dout_parity_chk  = mx_out_r[1] ^ mx_out_r[0];             
	parity_error = (dout_parity_chk != 1'b0) ? 1'b1 : 1'b0; 
     end


endmodule // safety_async_input_syncP




