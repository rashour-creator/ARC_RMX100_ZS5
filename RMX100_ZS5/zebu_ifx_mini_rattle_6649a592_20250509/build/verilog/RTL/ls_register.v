// Library safety-1.1.999999999
//----------------------------------------------------------------------------
//
// Copyright 2015-2024      Synopsys, Inc. All rights reserved.
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
// @f:ls_register
//
// Description:
// @p
//   Registers a signal and provides parity checking of the registered value.
// @e
//
// ===========================================================================


`include "const.def"
// spyglass disable_block Clock_delay01
// SMD: Reports flip-flop pairs whose data path delta delay is less than the
//difference in their clock path delta delays
// SJ: This is an intended change  
module ls_register #(
    parameter REG_WIDTH=4)
  (
   
    input      [REG_WIDTH-1:0] signal_in, 
    output reg [REG_WIDTH-1:0] signal_out_r,
    input                      enable,
    input 		     clk,
    input 		     rst

  );


// spyglass disable_block FlopEConst
// SMD: Reports permanently disabled or enabled flip-flop enable pins 
// SJ: this is intented behaviour where the enable is 1
always @(posedge clk or posedge rst)
  begin
     if (rst == 1'b1)
       signal_out_r <= 0;
     else
     begin
       if (enable)
         signal_out_r <= signal_in;
     end
  end
endmodule
// spyglass enable_block FlopEConst
// spyglass enable_block Clock_delay01
