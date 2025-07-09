// Library safety-1.1.999999999
//----------------------------------------------------------------------------
//
// Copyright 2015-2024 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//
// ===========================================================================
//
// @f:ls_compare_unit
//
// Description:
// @p
//   This block instantiates to delay stage and the TSC comparators. Parity checking
//   if selected is also done in this module.
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o halt.vpp
//
// ===========================================================================

//  W527 off - allows if statements without an else

// Configuration-dependent macro definitions
//
`include "rv_safety_defines.v"
`include "const.def"

module ls_compare_unit #(
// spyglass disable_block W240
// SMD: clk, rst declared but not read
// SJ: the behaviour is intentional When DELAY eq 0
    parameter REG_WIDTH=4,
    parameter MAX_COMPARE_SIZE=256,	// Constrain depth MUST BE POWER OF 2.
    //PAD VALUE is pads the comparator to valid sizes
    parameter ID = 0,
    parameter DELAY = 0) 
    (
    ////////// General input signals ///////////////////////////////////////////

    input [REG_WIDTH-1:0]   main_interface, // may be delayed, below.
    input [REG_WIDTH-1:0]   shadow_interface,

    input           clk,
    input           rst,

    input [1:0]                 error_injection_valid,
    input [1:0]                 safety_diag_inject_sc,

    ////// Outputs /////////////////////////////////////////////

    output [1:0]        error_bits	// A dual-rail signal.  01 = OK.
    );
    localparam PAD_VALUE = (1<<$clog2(REG_WIDTH)) - REG_WIDTH;
    localparam PADDED_WIDTH = REG_WIDTH+PAD_VALUE;


    localparam ZERO = 1'b0, ONE = ~ZERO;
    wire [PADDED_WIDTH-1:0] shadow_input;
    assign shadow_input = {shadow_interface,{PAD_VALUE{ZERO}}};

    wire [PADDED_WIDTH-1:0] main_input;

    generate // {
    if (DELAY != 0) begin:DELAY_gt_0 // {
        wire [REG_WIDTH-1:0] main_interface_delayed;
        ls_input_delay #(.SIZE(REG_WIDTH), .DELAY(DELAY)) u_delay (
            .rst                (rst),
            .clk                (clk),
            .d_in               (main_interface),
            .en                 (1'b1),
            .q_out              (main_interface_delayed)
            );
        assign main_input = {~main_interface_delayed,{PAD_VALUE{ONE}}};
    end
    else begin:DELAY_eq_0 // } {
        assign main_input = {~main_interface,{PAD_VALUE{ONE}}};
    end //}

    wire         LSB, MSB;	// MSB:LSB of dual-rail signal.

    localparam BLOCKS = PADDED_WIDTH/MAX_COMPARE_SIZE;
    if (BLOCKS <= 1) begin : single_compare
        ls_multi_bit_comparator #(.SIZE(PADDED_WIDTH)) u_ls_tsc (
            // Outputs
            .LSB   (LSB),
            .MSB   (MSB),
            // Inputs. Because 01 is preferred OK, shadow was padded with 0 and main with 1
            .MSBv  (shadow_input),
            .LSBv  (main_input)
            ); //delayed main
        end
    else begin : multiple_compares
        wire [BLOCKS-1:0] ebits;
	genvar bx;
	for (bx = 0; bx < BLOCKS; bx = bx + 1) begin : compare_block
	  wire LSBa, LSBb;
	  ls_multi_bit_comparator #(.SIZE(MAX_COMPARE_SIZE)) u_ls_tsc (
	      // Outputs
	      .LSB   (LSBa),
	      .MSB   (LSBb),
	      // Inputs
	      .MSBv     (shadow_input[bx*MAX_COMPARE_SIZE +: MAX_COMPARE_SIZE]),
	      .LSBv     (main_input  [bx*MAX_COMPARE_SIZE +: MAX_COMPARE_SIZE])
	      ); //delayed main
	  // Turn each dual rail into a single bit.
	  assign ebits[bx] = ~(LSBa^LSBb);	// SHDB 0 if valid dual rail.
	end
	// Ask if all the dual rails were valid.  Return dual-rail OK or not.
	assign {MSB,LSB} = ebits == 0 ? 2'b10 /*OK*/ : 2'b00 /*BAD*/;
    end
    endgenerate

    wire [1:0]     diag_mode = {{2{safety_diag_inject_sc == 2'b10}} & error_injection_valid};
    wire           MSB_ei    = diag_mode[0] ^ MSB;
    wire           LSB_ei    = diag_mode[1] ^ LSB;
    assign error_bits = {LSB_ei, MSB_ei};
`ifdef TEST_ERROR_BITS
    always @* if (rst == 0 && error_bits != 0) 
	$display("Error bits %1d at time %1d at %s",error_bits,$time,$sformatf("%m"));
`endif

// spyglass enable_block W240
endmodule //ls_compare_unit

//These are verilog-mode pragmas to aid autoinstantiation of modules
// Local Variables:
// verilog-library-directories:(".")
// verilog-library-extensions:(".v" ".vpp" ".h")
// End:
