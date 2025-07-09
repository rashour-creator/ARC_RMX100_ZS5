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

module rl_wtree_comp312(
  input        x1,
  input        x2,
  input        x3,
  input        ci1,
  output       s,
  output       c,
  output       co1
);

wire t0;

assign {co1, t0} = x1 + x2  + x3;
assign {  c,  s} = t0 + ci1;

endmodule
