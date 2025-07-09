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
// @f:ls_multi_bit_comparator
//
// Description:
// @p
//   Totally Self Checking Comparator (TSC). Inputs have to be complements of each
//  other. Outputs are dual rail - 01 or 10 indicate a match.
//  One of the inputs has to be inverted to check for equality!!
// @e
//
//  This .svpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o halt.svpp
//
// ===========================================================================

//  W527 off - allows if statements without an else

// Configuration-dependent macro definitions
//
`include "const.def"

module ls_multi_bit_comparator #( 
    parameter SIZE=2	// Size may be any power N >=1 of 2.
    )
    (
    ////////// General input signals ///////////////////////////////////////////
    //
    input [SIZE-1:0] MSBv,	// Vector of MSBs
    input [SIZE-1:0] LSBv,	// Vector of LSBs

    ////// Outputs /////////////////////////////////////////////
      
    output wire LSB,	// LSB of dual-rail
    output wire MSB	// MSB of dual-rail	01 = "OK".  10 is NOT intended to be OK.
    );

    wire [SIZE-2:0] LSBc;	// LSB computed
    wire [SIZE-2:0] MSBc;	// MSB computed
    //always @(MSBv) $display("%m: MSBv=",MSBv);
    //always @(LSBv) $display("%m: LSBv=",LSBv);
    localparam trace = 0;
    typedef logic [1:0] pair;	// Two MSBs or two LSBs, not a dual-rail signal
    typedef logic [1:0] dual;	// A dual-rail signal
   
    function automatic dual f_2bit(int ix,  input pair X, input pair Y);
    	// Input are pairs; output is a dual.
	f_2bit = { (X[0]&Y[1])|(Y[0]&X[1]), (X[0]&X[1])|(Y[0]&Y[1]) };
	`ifndef SYNTHESIS
	if (trace) $display("f2bit ix=%1d (X=%2b,Y=%2b)=%2b SIZE=%1d time %1d %m",
		ix, X,Y,f_2bit,SIZE,$time," input MSBv=%1x LSBv=%1x",MSBv,LSBv);
	`endif
	endfunction

    localparam HALF = SIZE/2;
    generate
    for (genvar j=0; j < HALF; j++) //This will build the stage for the inputs
	begin: inner_TSC
	assign {MSBc[j], LSBc[j]} = f_2bit(j, MSBv[j*2 +: 2], LSBv[j*2 +: 2]);
	end
      
    // Outputs from Stage1 will be checked in the next stages
    for (genvar k = HALF; k < SIZE-1; k++) 
	// This will build the remaining parts of the tree
	begin: checker_2nd_stage
	assign {MSBc[k], LSBc[k]} = f_2bit(k,
	    {MSBc[2*(k-HALF)], MSBc[2*(k-HALF) +1]},
	    {LSBc[2*(k-HALF)], LSBc[2*(k-HALF) +1]});
	end
    endgenerate

    assign {MSB,LSB} = {MSBc[SIZE-2],LSBc[SIZE-2]};
    `ifndef SYNTHESIS
    always_comb
    begin: display_PROC
        if (trace) begin
	    $display("LSB %1b MSB %1b %m",LSB,MSB);
	    for (int i = 0; i < SIZE-1; i++)
		$display("LSBc[%1d]=%1d MSBc[%1d]=%1d",i,LSBc[i],i,MSBc[i]);
	    end
	end
    `endif
    endmodule
