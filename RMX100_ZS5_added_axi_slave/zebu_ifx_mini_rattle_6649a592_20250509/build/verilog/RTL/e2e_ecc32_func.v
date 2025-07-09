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
 * Fault coverage: The code can detect up to two bit errors and simultaneously corrects single bit errors.
 * All-zero and all-one protection is enabled. These faults will be detected as two-bit errors.
 * Required minimum ECC bits: 7 
 ********************************************************************************************************
 */




// This function returns the check bits
function automatic [6:0] e2e_ecc32_enc;
    input [31:0] data_in;
    // The word which ECC will be calculated
    reg [31:0] word_in;
    // Hold generated EDC bits
    reg [5:0] edc_tmp;
    // Overall parity for Hammming SECDED code
    reg overall_parity;
    reg [6 :0] ecc;
begin

    // Word to encode
    word_in = data_in;

    // To generate EDC bits, pick particular word bits by using masks, then XOR them
    edc_tmp[0] = ^(word_in & 32'b10101011010101010101010101011011);
    edc_tmp[1] = ^(word_in & 32'b11001101100110011001101001101101);
    edc_tmp[2] = ^(word_in & 32'b11110001111000011110001110001110);
    edc_tmp[3] = ^(word_in & 32'b00000001111111100000001111110000);
    edc_tmp[4] = ^(word_in & 32'b00000001111111111111110000000000);
    edc_tmp[5] = ^(word_in & 32'b11111110000000000000000000000000);

    // Overall parity is the XOR of encoded word and generated EDC bits
    overall_parity = (^word_in) ^ (^edc_tmp);

    // Invert last two parity bits if all-zero and all-one protection is enabled
    ecc = {overall_parity, ~edc_tmp[5 ], ~edc_tmp[4 ], edc_tmp[3 :0]};
    e2e_ecc32_enc = ecc;
end
endfunction


// This function returns the {overall_parity, syndrome}
function automatic [6:0] e2e_ecc32_dec_a;
    input [31:0] data_in;
    input [6 :0] ecc_in;
    // XOR of received and re-calculated EDC
    reg  [5:0] syndrome;
    reg overall_parity;
    // The word which ECC will be calculated
    reg  [31:0] word_in;
    // Decoder re-calculates the EDC from the received data
    reg  [5:0] calc_edc;
    // Temporary signal to hold received EDC
    reg  [5:0] edc_in_tmp;

begin
// spyglass disable_block RegInputOutput-ML
// SMD: Module output and input port should be registered
// SJ: Intended behavior - EDC/PTY are checked at the top 
    // The word which EDC will be calculated again
    word_in = data_in;

    // Since the encoder inverts last two EDC bits before storing them, invert them back before comparing with generated EDC
    edc_in_tmp = {~ecc_in[5 ], ~ecc_in[4 ], ecc_in[3 :0]};

    // Pick particular word bits by using masks, then XOR them
    // Masks to select bits to be XORed
    calc_edc[0] = ^(word_in & 32'b10101011010101010101010101011011);
    calc_edc[1] = ^(word_in & 32'b11001101100110011001101001101101);
    calc_edc[2] = ^(word_in & 32'b11110001111000011110001110001110);
    calc_edc[3] = ^(word_in & 32'b00000001111111100000001111110000);
    calc_edc[4] = ^(word_in & 32'b00000001111111111111110000000000);
    calc_edc[5] = ^(word_in & 32'b11111110000000000000000000000000);

    // Calculate syndrome by comparing received and calculated EDC bits
    syndrome = edc_in_tmp ^ calc_edc;

    // Overall parity check should be zero for no error and even number of bit error cases
    overall_parity = ^{word_in, ecc_in};
    e2e_ecc32_dec_a = {overall_parity, syndrome};
// spyglass enable_block RegInputOutput-ML
end
endfunction


// This function returns the {unknown_err, double_err, single_err};
function automatic [2:0] e2e_ecc32_dec_b;
    input enable;
    input [5:0] syndrome;
    input overall_parity;
    // We pass this to simplify some of the expressions in error signal generation logic
    input overall_parity_and_enable;
    reg single_err;
    reg double_err;
    reg unknown_err;

    // OR ed version of the syndrome
    reg  is_syndrome_non_zero;
    // Does the syndrome is used by the coding scheme?
    reg  is_unused_syndrome;

begin
    // Check if the syndrome is non zero
    is_syndrome_non_zero = |syndrome;


// Checks if the syndrome is unused syndrome
    is_unused_syndrome = (syndrome == 15) | (syndrome == 40) | (syndrome == 41) | (syndrome == 42) | (syndrome == 43) | (syndrome == 44) | 
    (syndrome == 45) | (syndrome == 46) | (syndrome == 47) | (syndrome == 48) | (syndrome == 49) | (syndrome == 50) | 
    (syndrome == 51) | (syndrome == 52) | (syndrome == 53) | (syndrome == 54) | (syndrome == 55) | (syndrome == 56) | 
    (syndrome == 57) | (syndrome == 58) | (syndrome == 59) | (syndrome == 60) | (syndrome == 61) | (syndrome == 62) | 
    (syndrome == 63);

    // If overall parity check fails and syndrome is used, then we flag a single bit error
    // Note that this also covers the case when syndrome is zero, and the overall parity fails
    single_err = ~is_unused_syndrome & overall_parity_and_enable;

    // Assert double error if syndrome is non-zero and overall parity overall parity does not match
    double_err = is_syndrome_non_zero & ~overall_parity & enable;

    // If the syndrome is not used and overally parity fails, this is a detected multi odd bit error
    unknown_err = is_unused_syndrome & overall_parity_and_enable;

    e2e_ecc32_dec_b = {unknown_err, double_err, single_err};
end
endfunction


// This function returns the corrected data;
function automatic [31:0] e2e_ecc32_dec_c;
    input overall_parity_and_enable;
    input [5:0] syndrome;
    input [31:0] data_in;
    reg [31:0] data_out;
begin

    // Map error syndrome to faulty data bit location and correct it

    data_out = data_in;

    // Do correction only if it is a single bit error and module is enabled
    if (overall_parity_and_enable) begin
        case(syndrome)
        (3 ) :        data_out[0] = ~data_in[0];
        (5 ) :        data_out[1] = ~data_in[1];
        (6 ) :        data_out[2] = ~data_in[2];
        (7 ) :        data_out[3] = ~data_in[3];
        (9 ) :        data_out[4] = ~data_in[4];
        (10) :        data_out[5] = ~data_in[5];
        (11) :        data_out[6] = ~data_in[6];
        (12) :        data_out[7] = ~data_in[7];
        (13) :        data_out[8] = ~data_in[8];
        (14) :        data_out[9] = ~data_in[9];
        (17) :        data_out[10] = ~data_in[10];
        (18) :        data_out[11] = ~data_in[11];
        (19) :        data_out[12] = ~data_in[12];
        (20) :        data_out[13] = ~data_in[13];
        (21) :        data_out[14] = ~data_in[14];
        (22) :        data_out[15] = ~data_in[15];
        (23) :        data_out[16] = ~data_in[16];
        (24) :        data_out[17] = ~data_in[17];
        (25) :        data_out[18] = ~data_in[18];
        (26) :        data_out[19] = ~data_in[19];
        (27) :        data_out[20] = ~data_in[20];
        (28) :        data_out[21] = ~data_in[21];
        (29) :        data_out[22] = ~data_in[22];
        (30) :        data_out[23] = ~data_in[23];
        (31) :        data_out[24] = ~data_in[24];
        (33) :        data_out[25] = ~data_in[25];
        (34) :        data_out[26] = ~data_in[26];
        (35) :        data_out[27] = ~data_in[27];
        (36) :        data_out[28] = ~data_in[28];
        (37) :        data_out[29] = ~data_in[29];
        (38) :        data_out[30] = ~data_in[30];
        (39) :        data_out[31] = ~data_in[31];
        endcase
    end
    e2e_ecc32_dec_c = data_out;
end
endfunction


// This function returns the corrected ecc code;
function automatic [6 :0] e2e_ecc32_dec_d;
    input overall_parity_and_enable;
    input [5:0] syndrome;
    input [6 :0] ecc_in;
    reg [6 :0] ecc_out;
begin
    // Map error syndrome to faulty data bit location and correct it

    ecc_out  = ecc_in;
    
    // Do correction only if it is a single bit error and module is enabled
    if (overall_parity_and_enable) begin
        case(syndrome)
        (1 ) :        ecc_out[0] = ~ecc_in[0];
        (2 ) :        ecc_out[1] = ~ecc_in[1];
        (4 ) :        ecc_out[2] = ~ecc_in[2];
        (8 ) :        ecc_out[3] = ~ecc_in[3];
        (16) :        ecc_out[4] = ~ecc_in[4];
        (32) :        ecc_out[5] = ~ecc_in[5];
        (0 ) :        ecc_out[6] = ~ecc_in[6];
        endcase
    end
    e2e_ecc32_dec_d = ecc_out;
end
endfunction

