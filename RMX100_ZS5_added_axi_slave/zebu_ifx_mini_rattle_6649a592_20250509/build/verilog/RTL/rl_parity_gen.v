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
//  AHB Parity generation Register Implementation
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o rl_parity_gen.vpp
//
// ===========================================================================

//  W527 off - allows if statements without an else

// Configuration-dependent macro definitions
//

module rl_parity_gen 
#(
parameter DATA_WIDTH=32,
parameter PARITY_ODD=1
 ) 
(   
    input [DATA_WIDTH-1:0]       din,
    output 	       	             q_parity        //Parity Out
  );

   reg 			   d_parity;
   integer 		   i;

generate
  if (PARITY_ODD == 0)
  begin
    assign q_parity = d_parity;
  end
  else
  begin
    assign q_parity = ~d_parity;
  end
endgenerate

// spyglass disable_block W164a
// SMD: LHS is less than RHS
// SJ:  Intended as per the design. No possible loss of data
generate
    if (DATA_WIDTH == 1)
    begin     
      always @*
      begin : ahb_parity_gen_PROC
             d_parity = din;
      end
    end    
    else if (DATA_WIDTH == 2)
    begin 
      always @*
      begin : ahb_parity_gen_PROC
        d_parity = din[0] ^ din[1];
      end
    end
    else
    begin    
      always @*
      begin : ahb_parity_gen_PROC
        d_parity  = din[1] ^ din[0];             
        for (i=2;i<DATA_WIDTH;i=i+1)
           d_parity = d_parity ^ din[i]; 
      end
    end
endgenerate

// spyglass enable_block W164a

endmodule //rl_parity_gen

