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



module e2e_ecc32_1stg_cac(
// Module input and output ports
      input [31:0] data_in
    , input [6 :0] ecc_code_in
    , output [6 :0] ecc_code_out
    , output [31:0] data_out
    , output  sb_err
    , output  db_err
);

`include "e2e_ecc32_1stg_func.v"

wire enable, enable_r;
//Dont really need enable signal functionality in BUS ECC, so just tie them to high.
assign enable = 1'b1;
assign enable_r = 1'b1;
wire overall_parity, overall_parity_r;
wire [5:0] syndrome, syndrome_r;
wire overall_parity_and_enable, overall_parity_and_enable_r;
wire   unknown_err, double_err, single_err;
wire [31:0] data_in_r;
wire [6 :0] ecc_code_in_r;
wire [6:0] syndrome_pack;
wire [6:0] syndrome_pack_r;

assign syndrome_pack_r = syndrome_pack;
assign data_in_r = data_in;
assign ecc_code_in_r = ecc_code_in;

assign sb_err = single_err;
assign db_err = unknown_err || double_err;

assign overall_parity_and_enable = overall_parity & enable;
assign overall_parity_and_enable_r = overall_parity_r & enable_r;

assign syndrome_pack = {overall_parity, syndrome};
assign {overall_parity_r, syndrome_r} = syndrome_pack_r;

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

assign data_out = e2e_ecc32_1stg_dec_c(
      overall_parity_and_enable_r
    , syndrome_r
    , data_in_r
    );

assign ecc_code_out = e2e_ecc32_1stg_dec_d(
      overall_parity_and_enable_r
    , syndrome_r
    , ecc_code_in_r
    );
endmodule
