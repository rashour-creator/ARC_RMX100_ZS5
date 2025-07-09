// Library ARC_Soc_Trace-1.0.999999999
//----------------------------------------------------------------------------
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
// Synchronizer for a clock-domain crossing input signal (async input).
// The number synchronizing FF levels is controlled by SYNC_FF_LEVELS.
//
// Note: This is a behavioral block that may be replaced by the RDF flow before
// synthesis. The replacement block intantiates the propoer synchronizer cell
// of the synthesis library
//
// ===========================================================================

`include "arcv_dm_defines.v"
// Set simulation timescale
//
`include "const.def"
module dm_cdc_sync 
  #(
  parameter SYNC_FF_LEVELS = `DM_SYNC_FF_LEVELS    // SYNC_FF_LEVELS >= 2
  )
  (
  input   clk,         // target (receiving) clock domain clk
  input   rst_a,

  input   din,         // single bit wide input

  output  dout
);


  DWbb_bcm21_atv #(.WIDTH(1), .F_SYNC_TYPE(SYNC_FF_LEVELS), .VERIF_EN(`DM_SYNC_VERIF_EN), .SVA_TYPE(`DM_SYNC_SVA_TYPE),
                  .TMR_CDC(`DM_SYNC_TMR_CDC)) u_sync_wrp ( 
          .rst_d_n        (~rst_a), 
          .data_s         ({(`DM_SYNC_TMR_CDC*2+1){din}}),
          .clk_d          (clk), 
          .data_d         (dout)      );
endmodule // cdc_sync
