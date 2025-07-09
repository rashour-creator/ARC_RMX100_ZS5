// Library ARCv5EM-3.5.999999999


/*
 *************************************** MODULE INFO ***************************************************
 * Data bits: `DATA_BITS
 * Address bits: 8 (Address protection is enabled)
 * Fault coverage: The code can detect up to two bit errors and simultaneously corrects single bit errors.
 * (Address errors are reported seperately) 
 * All-zero and all-one protection is enabled. These faults will be detected as two-bit errors.
 * Required minimum ECC bits: 7 
 ********************************************************************************************************
 */

module ic_tag_ecc_decoder(
// Module input and output ports
      input enable
    , input [20:0] data_in
    , output [5:0] syndrome
    , input [7:0] address
    , input [6 :0] ecc_in
    , output [6 :0] ecc_out
    , output [20:0] data_out
    , output single_err
    , output double_err
    , output addr_err
);

`include "ic_tag_ecc_func.v"

wire overall_parity;
wire overall_parity_and_enable;
wire   unknown_err, db_err, sb_err;

assign single_err = sb_err;
assign double_err = unknown_err || db_err;

assign overall_parity_and_enable = overall_parity & enable;


assign {overall_parity, syndrome} = 
    ic_tag_ecc_dec_a(
      data_in
    , address
    , ecc_in
    );

assign {
      unknown_err
    , db_err
    , sb_err
    , addr_err
    } = ic_tag_ecc_dec_b(
      enable
    , syndrome
    , overall_parity
    , overall_parity_and_enable
    );

assign data_out = ic_tag_ecc_dec_c(
      overall_parity_and_enable
    , syndrome
    , data_in
    );

assign ecc_out = ic_tag_ecc_dec_d(
      overall_parity_and_enable
    , syndrome
    , ecc_in
    );
endmodule
