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

module rl_bitscan_16b(
  input   [14:0]              din,
  output  [3:0]               dout,
  output                      no_hit
);


wire                        hi_no_hit;
wire                        lo_no_hit;
wire    [2:0]               hi_dout;
wire    [2:0]               lo_dout;

rl_bitscan_8b u_rl_bitscan_8b_hi(
  .din     (din[14:8] ),
  .dout    (hi_dout   ),
  .no_hit  (hi_no_hit )
);

rl_bitscan_8b u_rl_bitscan_8b_lo(
  .din     (din[6:0]  ),
  .dout    (lo_dout   ),
  .no_hit  (lo_no_hit )
);

assign dout[3]    = hi_no_hit & (~din[7]);
assign dout[2:0]  = ((lo_dout | {3{din[7]}}) & {3{ hi_no_hit}})
                  | (hi_dout                 & {3{(~hi_no_hit)}})
                  ;
assign no_hit     = hi_no_hit & lo_no_hit & (~din[7]);

endmodule
