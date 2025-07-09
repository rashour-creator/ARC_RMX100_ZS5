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
// reset synchronizer
// ===========================================================================
//
// Description:
//
// Synchronizer for reset
//
// Note: This is a behavioral block that may be replaced by the RDF flow before
// synthesis. The replacement block intantiates the propoer synchronizer cell
// of the synthesis library
//
// ===========================================================================
`include "const.def"
module ls_cdc_reset_sync 
  #(
  parameter F_SYNC_TYPE    = 2,   // SYNC_FF_LEVELS >= 2
  parameter VERIF_EN       = 0,
  parameter SVA_TYPE       = 0,
  parameter TMR_CDC        = 0,
  parameter RESET_HIGH     = 1
  )
  (
  input   clk,         // target (receiving) clock domain clk
  input   rst_a,
  input	  test_mode,

  output  dout
);
   

wire sync_dout;
wire din = 1'b1;

DWbb_bcm21_atv #(
	.WIDTH(1), 
	.F_SYNC_TYPE(F_SYNC_TYPE), 
	.VERIF_EN(VERIF_EN), 
	.SVA_TYPE(SVA_TYPE), 
	.TMR_CDC(TMR_CDC)) u_core_cdc_sync ( 
    .rst_d_n        (~rst_a), 
    .data_s         ({(TMR_CDC*2+1){din}}), 
    .clk_d          (clk), 
    .data_d         (sync_dout)
    );

assign dout = test_mode ? rst_a : (RESET_HIGH ? ~sync_dout : sync_dout);

endmodule // cdc_sync
