/*
 * Copyright (C) 2021-2023 Synopsys, Inc. All rights reserved.
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


`include "const.def"

/*
 *************************************** MODULE INFO ***************************************************
 * Data bits: 32
 * Address bits: 0 (Address protection is enabled)
 * Fault coverage: The code can detect up to two bit errors and simultaneously corrects single bit errors.
 * All-zero and all-one protection is enabled. These faults will be detected as two-bit errors.
 * Required minimum ECC bits: 7 
 ********************************************************************************************************
 */



module e2e_ecc32_1stg_shdw_cac(
// Module input and output ports
      input [31:0] data_in
    , input [6 :0] ecc_code_in
    , output  sb_err
    , output  db_err
);

`include "e2e_ecc32_1stg_func.v"

wire enable;
//Dont really need enable signal functionality in BUS ECC, so just tie them to high.
assign enable = 1'b1;
wire overall_parity;
wire [5:0] syndrome;
wire overall_parity_and_enable;
wire   unknown_err, double_err, single_err;
  
assign sb_err = single_err;
assign db_err = unknown_err || double_err;

assign overall_parity_and_enable = overall_parity & enable;

assign {overall_parity, syndrome} = 
    e2e_ecc32_1stg_dec_a(
      data_in
    , ecc_code_in
    );

assign {
      unknown_err
    , double_err
    , single_err
    } = e2e_ecc32_1stg_dec_b(
      enable
    , syndrome
    , overall_parity
    , overall_parity_and_enable
    );

endmodule
