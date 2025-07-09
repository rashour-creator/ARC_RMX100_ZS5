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
// Description:
// @p
//  
//  
// @e
//
//  
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions 
//
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_simple_fifo 
  #(
    parameter DEPTH = 4,  // Fifo depth
    parameter DEPL2 = 2,  // Log2 depth
    parameter D_W   = 2   // Data width
   )
   (
  
  ////////// General input signals ///////////////////////////////////////////
  //
  input                  clk,                 // clock
  input                  rst_a,               // reset
  
  ////////// FIFO inputs ////////////////////////////////////////////////////
  //
  input  wire            push,                // push new FIFO element
  input  wire [D_W-1:0]  data_in,             // new FIFO element
  input  wire            pop,                 // pop head FIFO element
  
  ////////// FIFO output ////////////////////////////////////////////////////
  //
  output wire [D_W-1:0]  head                 // head FIFO element
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Declarations for the FIFO data elements and validity flip-flops          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

reg [DEPTH-1:0]       valid_r;         

reg [D_W-1:0]         data_r[DEPTH-1:0];

reg [DEPL2-1:0]       wr_ptr_r;  
reg [DEPL2-1:0]       rd_ptr_r;                  

//////////////////////////////////////////////////////////////////////////////
// Asynchronous processes
// 
//////////////////////////////////////////////////////////////////////////////
assign head = data_r[rd_ptr_r] & {D_W{valid_r[rd_ptr_r]}};

//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
// 
//////////////////////////////////////////////////////////////////////////////
// leda FM_1_7 off
// LMD: Signal assigned more than once in a single flow of control
// LJ:  Conflict covered by assertions
//
// leda NTL_RST03 off
// LMD: All registers must be asynchronously set or reset Range:0-51
// LJ:  Synthesis will take care
//
// leda B_3200 off
// LMD: Unequal length LHS and RHS in assignment LHS
// LJ:  One bit incrementor
//
// leda W484 off
// LMD: Possible loss of carry/borrow in addition/subtraction LHS
// LJ: Pointer arithmetic: incremented value will not overflow
//
// spyglass disable_block STARC-2.3.4.3
// SMD: Has neither asynchronous set nor asynchronous reset
// SJ:  Datapath items not reset
always @(posedge clk or posedge rst_a)
begin : wq_bfifo_ctl_regs_PROC
  if (rst_a == 1'b1)
  begin
    valid_r     <= {DEPTH{1'b0}};
    wr_ptr_r    <= {DEPL2{1'b0}};
    rd_ptr_r    <= {DEPL2{1'b0}};
  end
  else
  begin
// spyglass disable_block Ac_unsync02 Ac_glitch04 Ac_conv02 Ac_conv01
// SMD: Can glitch
// SJ:  source is fifo_data which is validated on fifo_valid
    if (push == 1'b1)
    begin
      valid_r[wr_ptr_r] <= 1'b1;
      wr_ptr_r          <= wr_ptr_r + 1'b1;
    end
    
    if (pop == 1'b1)
    begin
      valid_r[rd_ptr_r] <= 1'b0;
      rd_ptr_r          <= rd_ptr_r + 1'b1;
    end
// spyglass enable_block Ac_unsync02 Ac_glitch04 Ac_conv02 Ac_conv01
  end
end

// spyglass disable_block ResetFlop-ML
// SMD: Has no set or reset
// SJ:  Datapath items not reset
always @(posedge clk)
begin: wq_bfifo_data_regs_PROC
  if (push == 1'b1)
  begin
    data_r[wr_ptr_r] <= data_in;
  end
end
// spyglass enable_block ResetFlop-ML

// leda W484 on
// leda B_3200 on
// leda NTL_RST03 on
// leda FM_1_7 on
// spyglass enable_block STARC-2.3.4.3

endmodule // rl_simple_fifo


