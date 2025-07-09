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
// synchronizer
// ===========================================================================
//
// Description:
//
// Multi Synchronizer for a clock-domain crossing input signal (async input).
// The number synchronizing FF levels is controlled by SYNC_FF_LEVELS.
// Works when inputs are dual rail - 01 and 10
// Correct Parity will always be 1. 0 is a bit-flip
//  This module only generates and checks parity
//
// Note: This is a behavioral block that may be replaced by the RDF flow before
// synthesis. The replacement block intantiates the propoer synchronizer cell
// of the synthesis library
//
// ===========================================================================
`include "const.def"

module multi_bit_syncP
  #(
  parameter WIDTH = 2, SYNC_FF_LEVELS = 2    // SYNC_FF_LEVELS >= 2
  )
  (
  input   		clk,         // target (receiving) clock domain clk
  input   		rst,

  input   [WIDTH-1:0] 	din,

  output  [WIDTH-1:0]	dout,
  output  		parity_error

);

wire [WIDTH-1:0] parity_error_tmp; 

generate
genvar j;
for (j=0; j<WIDTH; j=j+1)  begin : SYNC_Val
    single_bit_syncP u_sync_bits_j	(
     .clk   (clk),
     .rst   (rst),
     .din   (din[j]),
     .dout  (dout[j]),
     .parity_error  (parity_error_tmp[j])
     );  
    end
   endgenerate

assign parity_error = |parity_error_tmp;

endmodule // hsls_multi_bit_syncP




