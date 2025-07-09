//----------------------------------------------------------------------------
//
// Copyright 2010-2018 Synopsys, Inc. All rights reserved.
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
// @f:multi_bit_comparator
//
// Description:
// @p
//   Totally Self Checking Comparator (TSC). Inputs have to be complements of each
//  other. Outputs are dual rail - 01 or 10 indicate a match.
//  One of the inputs has to be inverted to check for equality!!
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o halt.vpp
//
// ===========================================================================

`include "const.def"
module multi_bit_comparator #( parameter SIZE=2)
    // Valid values for SIZE are: 2, 4, 8, 16, 32, 64 ...
    (
    ////////// General input signals ///////////////////////////////////////////
    //
    input [SIZE-1:0] x,
    input [SIZE-1:0] y,

    ////// Outputs /////////////////////////////////////////////
      
    output wire e11, // LSB of dual-rail
    output wire e22 // MSB of dual-rail 01 = "OK".
    );

    wire [SIZE-2:0] LSB;
    wire [SIZE-2:0] MSB;
    //always @(x) $display("%m: x=",x);
    //always @(y) $display("%m: y=",y);
    localparam trace = 0;
    typedef logic [1:0] dual;

// spyglass disable_block Ac_conv02
// SMD: Synchronizers converge on combinational logic
// SJ: Convergence of errors aggregation
// spyglass disable_block Ac_conv01
// SMD: convergence of multiple synchronizers
// SJ: Error aggregation

    function automatic dual f_2bit(int ix,  input dual X, input dual Y);
    f_2bit = { (X[0]&Y[1])|(Y[0]&X[1]), (X[0]&X[1])|(Y[0]&Y[1]) };
`ifndef SYNTHESIS // {
    if (trace) $display("f2bit ix=%1d (X=%2b,Y=%2b)=%2b SIZE=%1d time %1d %m",
     ix, X,Y,f_2bit,SIZE,$time," input x=%1x y=%1x",x,y);
`endif //}
    endfunction

    localparam HALF = SIZE/2;
    generate
    for (genvar j=0; j < HALF; j++) //This will build the stage for the inputs
    begin: inner_TSC
    assign {MSB[j], LSB[j]} = f_2bit(j, x[j*2 +: 2], y[j*2 +: 2]);
    end
      
    // Outputs from StagLSB will be checked in the next stages
    for (genvar k = HALF; k < SIZE-1; k++) 
    // This will build the remaining parts of the tree
    begin: checker_2nd_stage
    assign {MSB[k], LSB[k]} = f_2bit(k,
        {MSB[2*(k-HALF)], MSB[2*(k-HALF) +1]},
        {LSB[2*(k-HALF)], LSB[2*(k-HALF) +1]});
    end
    endgenerate

    assign {e22,e11} = {MSB[SIZE-2],LSB[SIZE-2]};
`ifndef SYNTHESIS // {
    always @* begin
        if (trace) begin
     $display("e11 %1b e22 %1b %m",e11,e22);
     for (int i = 0; i < SIZE-1; i++)
     $display("LSB[%1d]=%1d MSB[%1d]=%1d",i,LSB[i],i,MSB[i]);
        end
    end
`endif //}
// spyglass enable_block Ac_conv02
// spyglass enable_block Ac_conv01

    endmodule
