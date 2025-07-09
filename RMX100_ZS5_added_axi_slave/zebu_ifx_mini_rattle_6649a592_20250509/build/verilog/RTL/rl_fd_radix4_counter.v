// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2023, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// Description:
//
// FAST DIVIDER SUPPORT MODULE.
// down counter for radix 4 steps
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a
//  command line such as:
//
//   vpp +q +o rl_fd_radix4_counter.vpp
//
// ===========================================================================
//

module rl_fd_radix4_counter (

input              clk,       // Clock input
input              rst_a,     // Asynchronous reset input
input              start,     // load input, start counting down if not hold
input              hold,      // freeze counter
input    [5:0]     init_ct,   // 16 steps max
output             done       // terminal count - reached zero

);

reg      [5:0]     count;
reg      [5:0]     count_next;

always @* 
begin : regasyn_PROC
     count_next = count;                  // reset
  if (start)
     count_next = init_ct;                // load
  else
  if (!hold && !done)
     count_next = count-6'b1;             // count down
end

// Counter flops and count logic
// leda W484 off
always @ (posedge clk or posedge rst_a)
begin : reg_PROC
  if (rst_a == 1'b1)
     count <= 6'b0;                      // reset
  else
     count <= count_next;                // load
end
// leda W484 on

assign done = (count == 6'h1) ? 1'b1 : 1'b0;   // terminal count

endmodule   // fd_radix4_counter
