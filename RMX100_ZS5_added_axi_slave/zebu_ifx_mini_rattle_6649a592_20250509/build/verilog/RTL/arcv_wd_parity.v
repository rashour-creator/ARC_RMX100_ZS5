// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright 2010-2017 Synopsys, Inc. All rights reserved.
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
// @f:wd_parity
//
// Description:
// @p
//  Watchdog Parity Register Implementation
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o halt.vpp
//
// ===========================================================================

//  W527 off - allows if statements without an else

// Configuration-dependent macro definitions
//
`include "defines.v"
`include "const.def"


module arcv_wd_parity 
#(parameter WD_REG_WIDTH=32,
  parameter WD_REG_DEFAULT=32'b0
 ) 
(
// spyglass disable_block FlopDataConstant MaxFanout
// spyglass disable_block SelfAssignment-ML
// spyglass disable_block NoExprInPort-ML UnUsedFlopOutput-ML
// spyglass disable_block Clock_info03a
// spyglass disable_block Ac_conv01
// spyglass disable_block Reset_sync02
// spyglass disable_block STARC05-1.3.1.3
// SMD: Do not use asynchronous reset/preset signals as non-reset/preset or synchronous reset/preset signals
// SJ: Reset sync dff is driving both parity checking and wdt async reset
//
////////// General input signals ///////////////////////////////////////////
    input [WD_REG_WIDTH-1:0] d_in,
    input                    clk,
    input                    rst,
  ////// Outputs /////////////////////////////////////////////

    output reg [WD_REG_WIDTH-1:0] q_out
  );




always @(posedge clk or posedge rst)
begin : wd_reg_PROC
  if (rst == 1'b1)
  begin
    q_out <= WD_REG_DEFAULT;
  end
  else
  begin
                q_out <= d_in;

  end
end


// spyglass enable_block NoExprInPort-ML UnUsedFlopOutput-ML
// spyglass enable_block FlopDataConstant MaxFanout
// spyglass enable_block SelfAssignment-ML
// spyglass enable_block Clock_info03a
// spyglass enable_block Ac_conv01
// spyglass enable_block Reset_sync02
// spyglass enable_block STARC05-1.3.1.3

endmodule //arcv_wd_parity

