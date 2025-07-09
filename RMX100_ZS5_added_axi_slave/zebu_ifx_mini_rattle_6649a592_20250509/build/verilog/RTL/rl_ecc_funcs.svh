
///////////////////////////////////////////////////////////

/*


ECC computations.

Place the ECC computations (add_ecc_xxx) here so that they can
be used both by RTL and the backdoor CCMs.

Backdoor CCMs don't store the ECC; it's stripped on the way in
and added on the way out (so there can never be an error).


*/
///////////////////////////////////////////////////////////

localparam ADR_AND_DATA_BITS = 58;

`include "ifu_defines.v"

`include "iccm_ecc_func.v"


function automatic [31:0] strip_ecc_from_iccm0_data(
    input  [39:0]  data
    );
    return data[31:0];
    endfunction

function automatic [39:0] add_ecc_to_iccm0_data(
    input [`ICCM0_ADR_RANGE] address,
    input  [31:0]  data
    );
    localparam pad = ADR_AND_DATA_BITS - `ICCM0_ADR_WIDTH - `ICCM0_DATA_WIDTH;
    // $display("iccm0 pad is %1d adrw %1d dw %1d",pad,`ICCM0_ADR_WIDTH,`ICCM0_DATA_WIDTH);
    return { iccm_ecc_enc(.data_in(data),.address(address)), data };
    endfunction


`include "dmp_defines.v"

`include "rl_dmp_dccm_ecc_func.v"


function automatic [31:0] strip_ecc_from_dccm_data(
    input  [39:0]  data
    );
    return data[31:0];
    endfunction

function automatic [39:0] add_ecc_to_dccm_data(
    input [`DCCM_ADR_RANGE] address,
    input  [31:0]  data
    );
    localparam pad = ADR_AND_DATA_BITS - `DCCM_ADR_WIDTH - `DCCM_DATA_WIDTH;
    // $display("dccm pad is %1d adrw %1d dw %1d",pad,`DCCM_ADR_WIDTH,`DCCM_DATA_WIDTH);
    return { rl_dmp_dccm_ecc_enc(.data_in(data),.address(address)), data };
    endfunction



localparam EDC_DA_0 = 58'b1101010101010101010101010101010110101010101010110101011011;
localparam EDC_DA_1 = 58'b0110011001100110011001100110011011001100110011011001101101;
localparam EDC_DA_2 = 58'b0111100001111000011110000111100011110000111100011110001110;
localparam EDC_DA_3 = 58'b0111111110000000011111111000000011111111000000011111110000;
localparam EDC_DA_4 = 58'b0111111111111111100000000000000011111111111111100000000000;
localparam EDC_DA_5 = 58'b0111111111111111111111111111111100000000000000000000000000;
localparam EDC_DA_6 = 58'b1000000000000000000000000000000000000000000000000000000000;

localparam EDC_D_0 = 32'b10101011010101010101010101011011;
localparam EDC_D_1 = 32'b11001101100110011001101001101101;
localparam EDC_D_2 = 32'b11110001111000011110001110001110;
localparam EDC_D_3 = 32'b00000001111111100000001111110000;
localparam EDC_D_4 = 32'b00000001111111111111110000000000;
localparam EDC_D_5 = 32'b11111110000000000000000000000000;

function automatic [6:0] ecc_gen32 (
    input       [31:0]        data     // 32-bit data in
    );

    // SECDED with 01 detection.

    ////////////////////////////////////////////////////////////////////////////////
    // ECC Code Logic
    ////////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////////
    // Generate ECC code
    //
    reg [5:0]  edc_tmp;
    reg        overall_parity;

    // To generate EDC bits, pick particular word bits by using masks, then XOR them
    edc_tmp[0] = ^(data & EDC_D_0);
    edc_tmp[1] = ^(data & EDC_D_1);
    edc_tmp[2] = ^(data & EDC_D_2);
    edc_tmp[3] = ^(data & EDC_D_3);
    edc_tmp[4] = ^(data & EDC_D_4);
    edc_tmp[5] = ^(data & EDC_D_5);

    // Overall parity is the XOR of encoded word and generated EDC bits
    overall_parity = ^{data,edc_tmp};

    // Invert last two parity bits for all-zero and all-one protection
    return {overall_parity, ~edc_tmp[5 ], ~edc_tmp[4 ], edc_tmp[3 :0]};

    endfunction

function automatic [7:0] ecca_gen32 (
    input       [ADR_AND_DATA_BITS-1:0]        data     // 26 bit address + 32-bit data 
    );

    ////////////////////////////////////////////////////////////////////////////////
    // ECC Code Logic
    ////////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////////
    // Generate ECC code
    //


    reg [57:0]             word;
    reg [7-1:0]  edc_tmp;
    reg                    overall_parity;

    // Word to encode.  Address goes to the bottom.
    word = {data[31:0],data[57:32]};  // Put address at the bottom.

    // To generate EDC bits, pick particular word bits by using masks, then XOR them
    edc_tmp[0] = ^(word & EDC_DA_0);
    edc_tmp[1] = ^(word & EDC_DA_1);
    edc_tmp[2] = ^(word & EDC_DA_2);
    edc_tmp[3] = ^(word & EDC_DA_3);
    edc_tmp[4] = ^(word & EDC_DA_4);
    edc_tmp[5] = ^(word & EDC_DA_5);
    edc_tmp[6] = ^(word & EDC_DA_6);

    // Overall parity is the XOR of encoded word and generated EDC bits
    overall_parity = ^{word,edc_tmp};

    // Invert last two parity bits for all-zero and all-one protection
    return {overall_parity, ~edc_tmp[6 ], ~edc_tmp[5 ], edc_tmp[4 :0]};

    endfunction

////////////////////////////////////////////////////////////////////
// EDC error detection functions
////////////////////////////////////////////////////////////////////




function automatic void ecc_detect_DA (
    ////////// General input signals ///////////////////////////////////////////
    //
    input [57:0]    data_in,     // 57+1 data in
    input [7:0]ecc_code_in,        // ECC code in

    ///////// Global/System state /////////////////////////////////////////////

    // Single bit error if syndrome != 0 and parity is 1.
    // Double bit if syndrome != 0 and parity is 0.
    output                 i_parity,
    output [6:0]syndrome
    );
reg [6:0]  calc_edc;
reg [6:0]  edc_in_tmp;
reg [57:0]      word_in;


// The word which EDC will be calculated again
//word_in = {data_in,addr_in};
word_in = {data_in[31:0],data_in[57:32]};


// Because the encoder inverts last two EDC bits before storing them, 
// invert them back before comparing with generated EDC.
edc_in_tmp = {~ecc_code_in[6 ], ~ecc_code_in[5 ], ecc_code_in[4 :0]};

// Pick particular word bits by using masks, then XOR them
calc_edc[0] = ^(word_in & EDC_DA_0);
calc_edc[1] = ^(word_in & EDC_DA_1);
calc_edc[2] = ^(word_in & EDC_DA_2);
calc_edc[3] = ^(word_in & EDC_DA_3);
calc_edc[4] = ^(word_in & EDC_DA_4);
calc_edc[5] = ^(word_in & EDC_DA_5);
calc_edc[6] = ^(word_in & EDC_DA_6);

// Calculate syndrome by comparing received and calculated EDC bits
syndrome = edc_in_tmp ^ calc_edc;

// Overall parity check should be zero for no error and even number of bit error cases
i_parity = ^{word_in, ecc_code_in};

endfunction

function automatic void ecc_detect_D (
    ////////// General input signals ///////////////////////////////////////////
    //
    input [31:0]    data_in,     // 31+1 data in
    input [6:0]ecc_code_in,        // ECC code in

    ///////// Global/System state /////////////////////////////////////////////

    // Single bit error if syndrome != 0 and parity is 1.
    // Double bit if syndrome != 0 and parity is 0.
    output                 i_parity,
    output [5:0]syndrome
    );
reg [5:0]  calc_edc;
reg [5:0]  edc_in_tmp;
reg [31:0]      word_in;


word_in = data_in;

// Because the encoder inverts last two EDC bits before storing them, 
// invert them back before comparing with generated EDC.
edc_in_tmp = {~ecc_code_in[5 ], ~ecc_code_in[4 ], ecc_code_in[3 :0]};

// Pick particular word bits by using masks, then XOR them
calc_edc[0] = ^(word_in & EDC_D_0);
calc_edc[1] = ^(word_in & EDC_D_1);
calc_edc[2] = ^(word_in & EDC_D_2);
calc_edc[3] = ^(word_in & EDC_D_3);
calc_edc[4] = ^(word_in & EDC_D_4);
calc_edc[5] = ^(word_in & EDC_D_5);

// Calculate syndrome by comparing received and calculated EDC bits
syndrome = edc_in_tmp ^ calc_edc;

// Overall parity check should be zero for no error and even number of bit error cases
i_parity = ^{word_in, ecc_code_in};

endfunction

////////////////////////////////////////////////////////////////////
// Correction functions
////////////////////////////////////////////////////////////////////


function automatic void ecc_correct_D (
    ////////// General input signals ///////////////////////////////////////////
    //
    input [31:0]    data_in,     // 31+1 data in
    input [6:0]ecc_code_in,        // ECC code in
    input                  i_parity,
    input [5:0]syndrome,           // 32-bit data in
    input                  ecc_disable,        // ECC disable

    ///////// Global/System state /////////////////////////////////////////////
    //
    output                 sb_error,          // single bit error detected
    output                 db_error,          // double bit error detected
    output reg [31:0]      data_out           // corrected data
    );
reg                    is_unused_syndrome;
// Overall parity check should be zero for no error and even number of bit error cases
reg                    overall_parity = i_parity;
// spyglass disable_block W123
reg                    is_addr_syndrome;
// spyglass enable_block W123
// Check if the syndrome is non zero
reg                    is_syndrome_non_zero = |syndrome;

data_out = data_in[31:0];	// Correction occurs on data_out


// Checks if the syndrome is unused syndrome
is_unused_syndrome = (syndrome[5] & (syndrome[4] | syndrome[3]))
		    | (~(|syndrome[5:4]) & (&syndrome[3:0]))
		    | (&data_in[31:0] & (&ecc_code_in));

// If overall parity check fails and syndrome is used, then we flag a single bit error
// Note that this also covers the case when syndrome is zero, and the overall parity fails
sb_error = ~is_unused_syndrome & overall_parity & (~ecc_disable);

// Assert double error if syndrome is non-zero and overall parity overall parity does not match
db_error = (~ecc_disable)
	 & (  (is_syndrome_non_zero & ~overall_parity) 
	    | (overall_parity & is_unused_syndrome));


// Do correction only if it is a single bit error and module is enabled
if (sb_error) begin
      // Map error syndrome to faulty data bit location and correct it
      case(syndrome)
      6'd3  :        data_out[0] = ~data_in[0];
      6'd5  :        data_out[1] = ~data_in[1];
      6'd6  :        data_out[2] = ~data_in[2];
      6'd7  :        data_out[3] = ~data_in[3];
      6'd9  :        data_out[4] = ~data_in[4];
      6'd10 :        data_out[5] = ~data_in[5];
      6'd11 :        data_out[6] = ~data_in[6];
      6'd12 :        data_out[7] = ~data_in[7];
      6'd13 :        data_out[8] = ~data_in[8];
      6'd14 :        data_out[9] = ~data_in[9];
      6'd17 :        data_out[10] = ~data_in[10];
      6'd18 :        data_out[11] = ~data_in[11];
      6'd19 :        data_out[12] = ~data_in[12];
      6'd20 :        data_out[13] = ~data_in[13];
      6'd21 :        data_out[14] = ~data_in[14];
      6'd22 :        data_out[15] = ~data_in[15];
      6'd23 :        data_out[16] = ~data_in[16];
      6'd24 :        data_out[17] = ~data_in[17];
      6'd25 :        data_out[18] = ~data_in[18];
      6'd26 :        data_out[19] = ~data_in[19];
      6'd27 :        data_out[20] = ~data_in[20];
      6'd28 :        data_out[21] = ~data_in[21];
      6'd29 :        data_out[22] = ~data_in[22];
      6'd30 :        data_out[23] = ~data_in[23];
      6'd31 :        data_out[24] = ~data_in[24];
      6'd33 :        data_out[25] = ~data_in[25];
      6'd34 :        data_out[26] = ~data_in[26];
      6'd35 :        data_out[27] = ~data_in[27];
      6'd36 :        data_out[28] = ~data_in[28];
      6'd37 :        data_out[29] = ~data_in[29];
      6'd38 :        data_out[30] = ~data_in[30];
      6'd39 :        data_out[31] = ~data_in[31];
      endcase
      end

endfunction

function automatic void ecc_correct_DA (
    ////////// General input signals ///////////////////////////////////////////
    //
    input [57:0]    data_in,     // 57+1 data in
    input [7:0]ecc_code_in,        // ECC code in
    input                  i_parity,
    input [6:0]syndrome,           // 32-bit data in
    input                  ecc_disable,        // ECC disable

    ///////// Global/System state /////////////////////////////////////////////
    //
    output                 sb_error,          // single bit error detected
    output                 db_error,          // double bit error detected
    output reg [31:0]      data_out           // corrected data
    );
reg                    is_unused_syndrome;
// Overall parity check should be zero for no error and even number of bit error cases
reg                    overall_parity = i_parity;
// spyglass disable_block W123
reg                    is_addr_syndrome;
// spyglass enable_block W123
// Check if the syndrome is non zero
reg                    is_syndrome_non_zero = |syndrome;

data_out = data_in[31:0];	// Correction occurs on data_out


// Checks if the syndrome is assigned to an address bit
is_addr_syndrome = ((syndrome[6:3] == 4'b0001) & (|syndrome[2:0]))
                 | ((syndrome[6:4] == 3'b001 ) & (|syndrome[3:0]));       

// Checks if the syndrome is unused syndrome
is_unused_syndrome = (&syndrome[6:5]) 
                   | (&data_in[31:0] & (&ecc_code_in));

// If overall parity check fails and syndrome is used but not an address syndrome, then we flag single bit error
// Note that this also covers the case when syndrome is zero, and the overall parity fails
sb_error = ~is_addr_syndrome & (~is_unused_syndrome) & overall_parity & (~ecc_disable);

// Assert double error if syndrome is non-zero and overall parity overall parity does not match
db_error = (~ecc_disable)
         & (  (~overall_parity & is_syndrome_non_zero)
            | (overall_parity & (is_addr_syndrome | is_unused_syndrome)));


if (sb_error) begin
    case(syndrome)
    7'd33 : data_out[0] = ~data_in[0];
    7'd34 : data_out[1] = ~data_in[1];
    7'd35 : data_out[2] = ~data_in[2];
    7'd36 : data_out[3] = ~data_in[3];
    7'd37 : data_out[4] = ~data_in[4];
    7'd38 : data_out[5] = ~data_in[5];
    7'd39 : data_out[6] = ~data_in[6];
    7'd40 : data_out[7] = ~data_in[7];
    7'd41 : data_out[8] = ~data_in[8];
    7'd42 : data_out[9] = ~data_in[9];
    7'd43 : data_out[10] = ~data_in[10];
    7'd44 : data_out[11] = ~data_in[11];
    7'd45 : data_out[12] = ~data_in[12];
    7'd46 : data_out[13] = ~data_in[13];
    7'd47 : data_out[14] = ~data_in[14];
    7'd48 : data_out[15] = ~data_in[15];
    7'd49 : data_out[16] = ~data_in[16];
    7'd50 : data_out[17] = ~data_in[17];
    7'd51 : data_out[18] = ~data_in[18];
    7'd52 : data_out[19] = ~data_in[19];
    7'd53 : data_out[20] = ~data_in[20];
    7'd54 : data_out[21] = ~data_in[21];
    7'd55 : data_out[22] = ~data_in[22];
    7'd56 : data_out[23] = ~data_in[23];
    7'd57 : data_out[24] = ~data_in[24];
    7'd58 : data_out[25] = ~data_in[25];
    7'd59 : data_out[26] = ~data_in[26];
    7'd60 : data_out[27] = ~data_in[27];
    7'd61 : data_out[28] = ~data_in[28];
    7'd62 : data_out[29] = ~data_in[29];
    7'd63 : data_out[30] = ~data_in[30];
    7'd65 : data_out[31] = ~data_in[31];
    endcase
    end

endfunction
