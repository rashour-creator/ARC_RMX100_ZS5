// Library ARCv5EM-3.5.999999999
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
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
// synchronizer
// ===========================================================================
//
// Description:
//
// Synchronizer wrap for a clock-domain crossing input signal (async input).
// The number synchronizing FF levels is controlled by `SYNC_FF_LEVELS.
//
//
// ===========================================================================

`include "defines.v"

// Simulation timestep information
//
`include "const.def"

module cdc_synch_wrap
  #(
  parameter WIDTH          = 1,    
  parameter F_SYNC_TYPE    = 2,   // SYNC_FF_LEVELS >= 2
  parameter VERIF_EN       = 0,
  parameter SVA_TYPE       = 0,
  parameter TMR_CDC        = 0    
  )
  (
  input   clk,         // target (receiving) clock domain clk
  input   din,         // single bit wide input
  input   rst,
  
  output  parity_error,
  output  dout
);

  single_bit_syncP u_cdc_sync
  (
     .clk   (clk),
     .rst   (rst),
     .din   (din),
     .dout  (dout),
     .parity_error  (parity_error)
  );

endmodule // cdc_sync
