// Library safety-1.1.999999999
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
// @f:simple_parity
//
// Description:
// @p
//  Simple Parity Register Implementation
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o halt.vpp
//
// ===========================================================================

//  W527 off - allows if statements without an else

`include "const.def"


module simple_parity #(parameter DATA_WIDTH=32, RESET_PAR = 1'b0, RESET_VAL = 32'b0) (
    input [DATA_WIDTH-1:0] din,
    input                clk,
    input                rst,
    ////// Outputs 
    output                parity_err , //Additional bit for error output
    output reg [DATA_WIDTH-1:0] dout
    );

    localparam parity_init = RESET_PAR;

    wire din_parity; 
    reg  din_parity_r;
    wire dout_parity;
    assign din_parity   = ^din; 
    assign dout_parity  = ^dout;
    assign parity_err   = dout_parity != din_parity_r ? 1'b1 : 1'b0; 
		 
    always @(posedge clk or posedge rst) begin : reg_PROC
	if (rst == 1'b1) begin
	    din_parity_r <= parity_init;
	    dout         <= RESET_VAL;
	    end
	else begin
	    din_parity_r <= din_parity;
	    dout         <= din;
	    end  
	end 
endmodule //parity

