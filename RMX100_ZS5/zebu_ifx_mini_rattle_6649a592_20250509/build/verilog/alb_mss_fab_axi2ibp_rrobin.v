// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2013 Synopsys, Inc. All rights reserved.
//
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
// ===========================================================================
//
// Description:
//  The rrobin module implements the round-robin arbitration
//
// ===========================================================================


// Set simulation timescale
//
`include "const.def"

module alb_mss_fab_axi2ibp_rrobin
#(parameter ARB_NUM = 4)
(
  output[ARB_NUM-1:0] grt_vector,  // Grant vector, one hot bits
  input [ARB_NUM-1:0] req_vector,  // Request vector
  input               arb_taken,   // completed this arbitration
  input               clk,
  input               rst_a
);


reg [ARB_NUM-1:0] gnt_r;
reg [ARB_NUM-1:0] gnt_d;

  // assignments
  assign grt_vector = gnt_d & req_vector;

  // Store grant to keep track of round-robin scheme
  // outputs: gnt_r
  always @(posedge clk or posedge rst_a)
    begin : state_proc
      if (rst_a) begin
        gnt_r  <= 0;
      end
      else if (arb_taken) begin
        gnt_r <= gnt_d;
      end
    end

  // determine priority
  always @*
    begin : prio_proc
      reg f;
      integer i,j;
      reg [2*ARB_NUM-1:0] pr;
      reg [ARB_NUM*ARB_NUM-1:0] result;
      // prepare priority vector
      f = 1'b0;
      for (i = 0; i < ARB_NUM; i = i + 1) begin
        pr[2*i+1]  = req_vector[i];
        pr[2*i+0]  = f;
        f = f | gnt_r[i];
      end
      // search for highest priority
      for (i = 0; i < ARB_NUM; i = i + 1) begin
        result[i*ARB_NUM+i] = 1'b1;
        for (j = i + 1; j < ARB_NUM; j = j + 1) begin
          result[i*ARB_NUM+j] = (pr[2*i+:2] >= pr[2*j+:2]);
          result[j*ARB_NUM+i] = !result[i*ARB_NUM+j];
        end
        gnt_d[i] = &result[i*ARB_NUM+:ARB_NUM];
      end
    end

endmodule // alb_mss_fab_rrobin
