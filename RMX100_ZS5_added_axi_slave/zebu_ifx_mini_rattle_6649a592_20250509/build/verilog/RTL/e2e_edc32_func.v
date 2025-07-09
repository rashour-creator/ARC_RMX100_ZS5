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




// This function returns the check bits
function automatic [5:0] e2e_edc32_enc;
    input [31:0] data_in;
    // The word which ECC will be calculated
    reg [31:0] word_in;
    // Hold generated EDC bits
    reg [5:0] edc_tmp;
    reg [5:0] edc;
begin

    // Word to encode
    word_in = data_in;

    // To generate EDC bits, pick particular word bits by using masks, then XOR them
    edc_tmp[0] = ^(word_in & 32'b10101010101010101010110101011011);
    edc_tmp[1] = ^(word_in & 32'b11001101001100110011011001101101);
    edc_tmp[2] = ^(word_in & 32'b11110001110000111100011110001110);
    edc_tmp[3] = ^(word_in & 32'b00000001111111000000011111110000);
    edc_tmp[4] = ^(word_in & 32'b00000001111111111111100000000000);
    edc_tmp[5] = ^(word_in & 32'b11111110000000000000000000000000);


    // Invert last parity bit if all-zero and all-one protection is enabled
    edc = {~edc_tmp[5 ], edc_tmp[4 :0]};
    e2e_edc32_enc = edc;
end
endfunction


// This function returns the syndrome
function automatic [5:0] e2e_edc32_dec_a;
    input [31:0] data_in;
    input [5:0] edc_in;
    // XOR of received and re-calculated EDC
    reg  [5:0] syndrome;
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

    // Since the encoder inverts last EDC bit before storing it, invert it back before comparing with generated EDC
    edc_in_tmp = {~edc_in[5 ], edc_in[4 :0]};

    // Pick particular word bits by using masks, then XOR them
    // Masks to select bits to be XORed
    calc_edc[0] = ^(word_in & 32'b10101010101010101010110101011011);
    calc_edc[1] = ^(word_in & 32'b11001101001100110011011001101101);
    calc_edc[2] = ^(word_in & 32'b11110001110000111100011110001110);
    calc_edc[3] = ^(word_in & 32'b00000001111111000000011111110000);
    calc_edc[4] = ^(word_in & 32'b00000001111111111111100000000000);
    calc_edc[5] = ^(word_in & 32'b11111110000000000000000000000000);

    // Calculate syndrome by comparing received and calculated EDC bits
    syndrome = edc_in_tmp ^ calc_edc;

    e2e_edc32_dec_a = syndrome;
// spyglass enable_block RegInputOutput-ML
end
endfunction


// This function returns the err;
function automatic [0:0] e2e_edc32_dec_b;
    input enable;
    input [5:0] syndrome;
    reg err;

    // OR ed version of the syndrome
    reg  is_syndrome_non_zero;

begin
    // Check if the syndrome is non zero
    is_syndrome_non_zero = |syndrome;

    // Error is detected when syndrome is non-zero
    err = is_syndrome_non_zero & enable;
    e2e_edc32_dec_b = err;
end
endfunction


// This function returns the corrected data;
function automatic [31:0] e2e_edc32_dec_c;
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
        (15) :        data_out[10] = ~data_in[10];
        (17) :        data_out[11] = ~data_in[11];
        (18) :        data_out[12] = ~data_in[12];
        (19) :        data_out[13] = ~data_in[13];
        (20) :        data_out[14] = ~data_in[14];
        (21) :        data_out[15] = ~data_in[15];
        (22) :        data_out[16] = ~data_in[16];
        (23) :        data_out[17] = ~data_in[17];
        (24) :        data_out[18] = ~data_in[18];
        (25) :        data_out[19] = ~data_in[19];
        (26) :        data_out[20] = ~data_in[20];
        (27) :        data_out[21] = ~data_in[21];
        (28) :        data_out[22] = ~data_in[22];
        (29) :        data_out[23] = ~data_in[23];
        (30) :        data_out[24] = ~data_in[24];
        (33) :        data_out[25] = ~data_in[25];
        (34) :        data_out[26] = ~data_in[26];
        (35) :        data_out[27] = ~data_in[27];
        (36) :        data_out[28] = ~data_in[28];
        (37) :        data_out[29] = ~data_in[29];
        (38) :        data_out[30] = ~data_in[30];
        (39) :        data_out[31] = ~data_in[31];
        endcase
    end
    e2e_edc32_dec_c = data_out;
end
endfunction


// This function returns the corrected ecc code;
function automatic [6 :0] e2e_edc32_dec_d;
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
        (0 ) :        ecc_out[5] = ~ecc_in[5];
        endcase
    end
    e2e_edc32_dec_d = ecc_out;
end
endfunction

