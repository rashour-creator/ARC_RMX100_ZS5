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








module e2e_ecc32_1stg_qual_cac_wrap
#( parameter SECOND_CHK = 0 )
(
// Module input and output ports
      input [31:0]         data_in
    , input                           qual
    , input [6 :0] ecc_code_in
    , output [31:0]        data_out
    , output [6 :0] ecc_code_out
    , output                sb_err
    , output                db_err
);

generate
  if(SECOND_CHK==0) begin: SECOND_CHK_0
    wire         sb_err_tmp, db_err_tmp;
    e2e_ecc32_1stg_cac u_e2e_ecc32_1stg_cac (
      .data_in          (data_in),
      .ecc_code_in      (ecc_code_in),
      .ecc_code_out     (ecc_code_out),
      .data_out         (data_out),
      .sb_err         (sb_err_tmp),
      .db_err         (db_err_tmp)
    );
    assign sb_err = qual ? sb_err_tmp : 1'b0;
      assign db_err = qual ? db_err_tmp : 1'b0;
  end else begin: SECOND_CHK_1
    wire         sb_err_main,sb_err_shdw,
                      db_err_main,db_err_shdw;
    
    e2e_ecc32_1stg_cac u_main_e2e_ecc32_1stg_cac (
      .data_in          (data_in),
      .ecc_code_in      (ecc_code_in),
      .ecc_code_out     (ecc_code_out),
      .data_out         (data_out),
      .sb_err         (sb_err_main),
      .db_err         (db_err_main)
    );
    
    e2e_ecc32_1stg_shdw_cac u_shadow_e2e_ecc32_1stg_shdw_cac (
      .data_in          (data_in),
      .ecc_code_in      (ecc_code_in),
      .sb_err         (sb_err_shdw),
      .db_err         (db_err_shdw)
    );
    

   
   wire [1:0]         dr_mismatch;
    multi_bit_comparator #(
      .SIZE(2)
    ) u_comparator (
      .x({
          sb_err_main,
          db_err_main
         }),
      .y({
          ~sb_err_shdw,
          ~db_err_shdw
         }),
      .e11(dr_mismatch[0]), /* output */
      .e22(dr_mismatch[1])  /* output */
    );
    assign sb_err = qual ? sb_err_main : 1'b0;
    assign db_err = qual ? (db_err_main || ~(^dr_mismatch)) : 1'b0;
  end
endgenerate
endmodule
