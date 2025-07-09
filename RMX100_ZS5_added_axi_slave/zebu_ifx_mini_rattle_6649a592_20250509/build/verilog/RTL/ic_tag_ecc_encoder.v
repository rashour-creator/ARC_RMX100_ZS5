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

module ic_tag_ecc_encoder(
// Module input and output ports
      input [20:0] data_in
    , input [7:0] address
    , output [6 :0] ecc
);

`include "ic_tag_ecc_func.v"

assign ecc = ic_tag_ecc_enc(
             data_in
           , address
           );
endmodule
