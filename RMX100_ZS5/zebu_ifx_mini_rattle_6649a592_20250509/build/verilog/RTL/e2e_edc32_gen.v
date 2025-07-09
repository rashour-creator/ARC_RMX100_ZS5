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



/*
 *************************************** MODULE INFO ***************************************************
 * Data bits: 32
 * Address bits: 0 (Address protection is enabled)
 * Fault coverage: The code can detect up to two bit errors.
 * All-zero and all-one protection is enabled. These faults will be detected.
 * Required minimum EDC bits: 6
 ********************************************************************************************************
 */


module e2e_edc32_gen(
// Module input and output ports
      input [31:0] data_in
    , output [5:0] edc_code
);

`include "e2e_edc32_func.v"

assign edc_code = e2e_edc32_enc(
             data_in
           );
endmodule
