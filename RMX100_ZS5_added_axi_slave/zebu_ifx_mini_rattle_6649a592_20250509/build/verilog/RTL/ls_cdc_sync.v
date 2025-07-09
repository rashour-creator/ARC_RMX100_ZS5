// Library safety-1.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2015-2024 Synopsys, Inc. All rights reserved.
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
`include "const.def"
module ls_cdc_sync 
  #(
  parameter WIDTH          = 1,    
  parameter F_SYNC_TYPE    = 2,   // SYNC_FF_LEVELS >= 2
  parameter VERIF_EN       = 0,
  parameter SVA_TYPE       = 0,
  parameter TMR_CDC        = 0    
  )
  (
  input   clk,         // target (receiving) clock domain clk
  input   rst_a,

  input   din,         // single bit wide input

  output  dout
);

DWbb_bcm21_atv #(
	.WIDTH(1), 
	.F_SYNC_TYPE(F_SYNC_TYPE), 
	.VERIF_EN(VERIF_EN), 
	.SVA_TYPE(SVA_TYPE), 
	.TMR_CDC(TMR_CDC)) u_core_cdc_sync ( 
    .rst_d_n        (~rst_a), 
    .data_s         ({(TMR_CDC*2+1){din}}), 
    .clk_d          (clk), 
    .data_d         (dout)
    );

endmodule // cdc_sync
