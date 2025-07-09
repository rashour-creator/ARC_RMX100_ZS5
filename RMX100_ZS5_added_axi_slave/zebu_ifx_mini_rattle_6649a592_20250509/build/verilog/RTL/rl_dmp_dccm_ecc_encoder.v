// Library ARCv5EM-3.5.999999999


/*
 *************************************** MODULE INFO ***************************************************
 * Data bits: `DATA_BITS
 * Address bits: `ADDR_BITS (Address protection is enabled)
 * Fault coverage: The code can detect up to two bit errors and simultaneously corrects single bit errors.
 * (Address errors are reported seperately) 
 * All-zero and all-one protection is enabled. These faults will be detected as two-bit errors.
 * Required minimum ECC bits: 8 
 ********************************************************************************************************
 */

module rl_dmp_dccm_ecc_encoder(
// Module input and output ports
      input [31:0] data_in
    , input [16:0] address
    , output [7 :0] ecc
);

`include "rl_dmp_dccm_ecc_func.v"

assign ecc = rl_dmp_dccm_ecc_enc(
             data_in
           , address
           );
endmodule
