/*
 * Copyright (C) 2024 Synopsys, Inc. All rights reserved.
 *
 * SYNOPSYS CONFIDENTIAL - This is an unpublished, confidential, and
 * proprietary work of Synopsys, Inc., and may be subject to patent,
 * copyright, trade secret, and other legal or contractual protection.
 * This work may be used only pursuant to the terms and conditions of a
 * written license agreement with Synopsys, Inc. All other use, reproduction,
 * distribution, or disclosure of this work is strictly prohibited.
 *
 * The entire notice above must be reproduced on all authorized copies.
 */


// ===========================================================================
//
// Description:
//  Parity ptotection decoder
//
// ===========================================================================

`include "const.def"



module odd_pty_dec
  #(
    parameter DATA_SIZE = 32
    )
    (
     input   [DATA_SIZE-1:0]     data_in,
     input                       parity_in,
     output                      parity_err
    );

    wire        parity_err_tmp;

// spyglass disable_block RegInputOutput-ML
// SMD: Module output and input port should be registered
// SJ: Intended behavior - EDC/PTY are checked at the top 
assign parity_err_tmp =  ~(^{data_in,parity_in});
// spyglass enable_block RegInputOutput-ML

assign parity_err = parity_err_tmp;
endmodule


