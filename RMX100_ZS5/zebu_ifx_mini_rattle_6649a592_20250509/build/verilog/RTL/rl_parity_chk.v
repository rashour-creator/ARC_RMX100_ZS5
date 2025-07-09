// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
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
// @f:rl_parity_gen
//
// Description:
// @p
//  AHB Parity checker Implementation
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o rl_parity_chk.vpp
//
// ===========================================================================

//  W527 off - allows if statements without an else

// Configuration-dependent macro definitions
//

module rl_parity_chk 
#(
parameter DATA_WIDTH=32,
parameter PARITY_ODD=1
 ) 
(
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ : Intended as per the design
//
    input [DATA_WIDTH-1:0]       din,
    input                        din_parity,
	input                        enable,

    output   		             parity_err         //Parity Out
  );

   reg 			   parity_chk ;
   wire            parity_err_temp;
   integer 		   i;
   		
// spyglass disable_block W164a
// SMD: LHS is less than RHS
// SJ:  Intended as per the design. No possible loss of data
generate
  if (DATA_WIDTH == 1) //Generate parity
  begin
    always @*
	begin : ahb_parity_chk_PROC
      parity_chk   = din;
	end
  end
  else if (DATA_WIDTH == 2)
  begin
    always @*
	begin : ahb_parity_chk_PROC
      parity_chk   = din[1] ^ din[0];
	end
  end
  else
  begin
    always @*
	begin : ahb_parity_chk_PROC
      parity_chk  = din[1] ^ din[0];  
       for (i=2;i<DATA_WIDTH;i=i+1)
         parity_chk  = parity_chk ^ din[i]; 
	end
  end
endgenerate

generate
  if (PARITY_ODD == 0)
  begin
    assign parity_err_temp = (parity_chk  != din_parity) ? 1'b1 : 1'b0;
  end
  else
  begin
    assign parity_err_temp = (parity_chk  == din_parity) ? 1'b1 : 1'b0;
  end
endgenerate

assign parity_err = parity_err_temp & enable;
// spyglass enable_block W164a
// spyglass enable_block RegInputOutput-ML
endmodule //rl_parity_chk

