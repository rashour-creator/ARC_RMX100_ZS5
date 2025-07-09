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
 * Fault coverage: The code can detect up to two bit errors.
 * All-zero and all-one protection is enabled. These faults will be detected.
 * Required minimum EDC bits: 6
 ********************************************************************************************************
 */



module e2e_edc32_1stg_chk(
// Module input and output ports
      input [31:0] data_in
    , input [5:0] edc_in
    , output  err
);

`include "e2e_edc32_1stg_func.v"

wire enable, enable_r;
//Dont really need enable signal functionality in BUS ECC, so just tie them to high.
assign enable = 1'b1;
assign enable_r = 1'b1;
wire [5:0] syndrome;
  
assign syndrome = 
    e2e_edc32_1stg_dec_a(
      data_in
    , edc_in
    );
// spyglass disable_block Ac_conv01
// SMD: signals from the same domain that are synchronized in the same destination domain and converge after any number of sequential elements
// SJ: data coming from those synchronizers doesn't have any dependencys and no data coherence issues, this warning can be ignored.
assign {
      err
    } = e2e_edc32_1stg_dec_b(
      enable
    , syndrome
    );
// spyglass enable_block Ac_conv01
endmodule
