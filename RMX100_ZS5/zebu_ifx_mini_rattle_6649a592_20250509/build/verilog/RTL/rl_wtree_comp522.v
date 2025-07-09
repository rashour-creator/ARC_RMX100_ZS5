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
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------

module rl_wtree_comp522(
  input        x1,
  input        x2,
  input        x3,
  input        x4,
  input        x5,
  input        ci1,
  input        ci2,
  output       s,
  output       c,
  output       co1,
  output       co2
);

wire t0;
wire t1;

assign {co1, t0} = x1 + x2 + x3;
assign {co2, t1} = x4 + x5 + ci1;
assign {  c,  s} = t0 + t1 + ci2;

endmodule
