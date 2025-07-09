// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2013 Synopsys, Inc. All rights reserved.
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
//
//  ####            #       ###
//  #   #     #     #      #   #
//  #   #           #      #
//  #   #    ##    ####    #       ####    ####   # ###
//  ####      #     #       ###   #    #       #  ##   #
//  #   #     #     #          #  #        #####  #    #
//  #   #     #     #          #  #       #    #  #    #
//  #   #     #     #  #   #   #  #    #  #   ##  #    #
//  ####    #####    ##     ###    ####    ### #  #    #
//
// ===========================================================================
//
// Description:
//
//  The bitscan module is used to find the first 1 or 0 bit in the
//  source operand.
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"

// Global constants and timescales
//
`include "const.def"

module rl_bitscan_4b(
  input   [2:0]               din,
  output reg [1:0]            dout,
  output                      no_hit
);


always @*
begin : bitscan_4b_PROC
  casez ({din[0],din[1],din[2]})
    3'b??1: dout = 2'd0;
    3'b?10: dout = 2'd1;
    3'b100: dout = 2'd2;
    3'b000: dout = 2'd3;
    //default: dout = 2'd0; // DC complains about this if left uncommented
  endcase
end // always

assign no_hit = (din == 3'd0);

endmodule
