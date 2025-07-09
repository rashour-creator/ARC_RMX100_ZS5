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
//  Parity ptotection decoder wrapper.
//  It instantiates both ain and shadow copy of the decoder for latent check purpose.
//
// ===========================================================================

`include "const.def"


module even_pty_di_dec_wrap
  #(
    parameter SECOND_CHK = 0,
    parameter DATA_SIZE = 32
    )
    (

     input  [DATA_SIZE-1:0]     data_in,
     input                      parity_in,
     input                      diag_inj,
     output               parity_err
    );

generate
  if(SECOND_CHK==0) begin: SECOND_CHK_0
    wire         parity_err_tmp;
    even_pty_dec #(
        .DATA_SIZE    (DATA_SIZE)
    ) u_even_pty_dec (
      .data_in      (data_in),
      .parity_in    (parity_in),
      .parity_err   (parity_err_tmp)
    );
    assign parity_err = parity_err_tmp ^ diag_inj;
  end else begin: SECOND_CHK_1
    wire        parity_err_main,parity_err_shdw;
    
    even_pty_dec #(
        .DATA_SIZE    (DATA_SIZE)
    ) u_main_even_pty_dec (
      .data_in      (data_in),
      .parity_in    (parity_in),
      .parity_err   (parity_err_main)
    );
    
    even_pty_dec #(
      .DATA_SIZE    (DATA_SIZE)
    ) u_shadow_even_pty_dec (
      .data_in      (data_in),
      .parity_in    (parity_in),
      .parity_err   (parity_err_shdw)
    );

    wire [1:0]         mismatch;
    multi_bit_comparator #(
      .SIZE(2)
    ) u_main_shdw_comparator (
      .x({1'b0,parity_err_main}),
      .y({1'b1,~parity_err_shdw}),
      .e11(mismatch[0]), /* output */
      .e22(mismatch[1])  /* output */
    );
    
    assign parity_err = parity_err_main || ~(^mismatch ^ diag_inj);

  end
endgenerate
endmodule


