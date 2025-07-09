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








module e2e_edc32_1stg_qual_di_chk_wrap
#( parameter SECOND_CHK = 0 )
(
// Module input and output ports
      input [31:0]         data_in
    , input                           qual
    , input                           diag_inj
    , input [5:0]          edc_in
    , output                err
);

generate
  if(SECOND_CHK==0) begin: SECOND_CHK_0
    wire         err_tmp;
    e2e_edc32_1stg_chk u_e2e_edc32_1stg_chk (
      .data_in          (data_in),
      .edc_in                   (edc_in),
      .err            (err_tmp)
    );
    assign err = (qual|diag_inj) ? (err_tmp ^ diag_inj) : 1'b0;
  end else begin: SECOND_CHK_1
    wire         err_main,err_shdw;
    
    e2e_edc32_1stg_chk u_main_e2e_edc32_1stg_chk (
      .data_in          (data_in),
      .edc_in           (edc_in),
      .err              (err_main)
    );
    
    e2e_edc32_1stg_chk u_shadow_e2e_edc32_1stg_chk (
      .data_in          (data_in),
      .edc_in           (edc_in),
      .err              (err_shdw)
    );
    

   
   wire [1:0]         dr_mismatch;
    multi_bit_comparator #(
      .SIZE(2)
    ) u_comparator (
      .x({
          1'b0,
          err_main
         }),
      .y({
          1'b1,
          ~err_shdw
         }),
      .e11(dr_mismatch[0]), /* output */
      .e22(dr_mismatch[1])  /* output */
    );
    assign err = (qual|diag_inj) ? (err_main || ~(^dr_mismatch ^ diag_inj)) : 1'b0;
  end
endgenerate
endmodule
