// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2018 Synopsys, Inc. All rights reserved.
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

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  The following five signals are used to control operations in the        //
//  h64_bitscan module.                                                     //
//                                                                          //
//  Instruction   norm_op  byte_size  long_size                             //
//  -------------------------------------------                             //
//     CTZ           1         0         0
//     CTZ           1         1         0
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

module rl_bitscan (
  input   [`DATA_RANGE]       src2_val,         // single input operand
  input                       norm_op,          // any of CLZ, CTZ
  input                       byte_size,        // 1 => clz, 0 => ctz

  output  [`RV_BITSCAN_RANGE] bitscan_result    // bitscan output 
);


//////////////////////////////////////////////////////////////////////////////
// Local signal declaration                                                 //
//////////////////////////////////////////////////////////////////////////////

reg     [`DATA_RANGE]       clz_src;
reg     [`DATA_RANGE]       ctz_src;
reg     [`DATA_RANGE]       lzd_src;

always @*
begin : lzd_src_PROC

  ctz_src   = {
    src2_val[0],  src2_val[1],  src2_val[2],  src2_val[3],
    src2_val[4],  src2_val[5],  src2_val[6],  src2_val[7],
    src2_val[8],  src2_val[9],  src2_val[10], src2_val[11],
    src2_val[12], src2_val[13], src2_val[14], src2_val[15],
    src2_val[16], src2_val[17], src2_val[18], src2_val[19],
    src2_val[20], src2_val[21], src2_val[22], src2_val[23],
    src2_val[24], src2_val[25], src2_val[26], src2_val[27],
    src2_val[28], src2_val[29], src2_val[30], src2_val[31]
  };

  //==========================================================================
  clz_src  = src2_val;
  casez ({norm_op, byte_size})
    2'b10: lzd_src = ctz_src;
    2'b11: lzd_src = clz_src;
    default:  lzd_src =  {`DATA_SIZE{1'b0}};
  endcase

end // lzd_src_PROC

//////////////////////////////////////////////////////////////////////////////
// Leading Zero Detection (LZD) circuit using alb_bitscan_32b modules       //
//////////////////////////////////////////////////////////////////////////////

reg  [`RV_BITSCAN_RANGE]  lzd_result;
wire                      hi_no_hit;
wire                      lo_no_hit;
wire    [3:0]             hi_dout;
wire    [3:0]             lo_dout;

rl_bitscan_16b u_rl_bitscan_16b_hi(
  .din     (lzd_src[31:17]),
  .dout    (hi_dout       ),
  .no_hit  (hi_no_hit     )
);

rl_bitscan_16b u_rl_bitscan_16b_lo(
  .din     (lzd_src[15:1]),
  .dout    (lo_dout      ),
  .no_hit  (lo_no_hit    )
);

always @*
begin : lzd_result_PROC 
  casez ({hi_no_hit, lzd_src[16], lo_no_hit, lzd_src[0]})
    4'b0???:lzd_result = {2'b00, hi_dout}; //0..14
    4'b11??:lzd_result = {2'b00, 4'b1111}; //15
    4'b100?:lzd_result = {2'b01, lo_dout}; //16..30
    4'b1011:lzd_result = {2'b01, 4'b1111}; //31
    4'b1010:lzd_result = {2'b10, 4'b0000}; //32
    default:lzd_result = 6'b00_0000;
  endcase
end // lzd_result_PROC

assign bitscan_result   = lzd_result;

endmodule

