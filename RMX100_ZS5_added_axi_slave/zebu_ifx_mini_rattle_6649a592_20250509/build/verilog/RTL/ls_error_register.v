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
// @f:ls_error_register
//
// Description:
// @p
//   Compute the error bit and the mismatch result.
// @e
//
// ===========================================================================

//  W527 off - allows if statements without an else

// Configuration-dependent macro definitions
//
`include "rv_safety_defines.v"
`include "const.def"




module ls_error_register #(parameter DELAY = 0)(
// spyglass disable_block W240
// SMD: shadow_clk declared but not read
// SJ: the behaviour is intentional When DELAY eq 0
// spyglass disable_block Ac_coherency06
// SMD: Reports signals that are synchronized multiple times in the same clock domain
// SJ: The inputs coming to this block are passed through the input delay
// logic and not a synchronizer. Hence this can be waived

   input  error_bit,
    ////////// Fixed output signals  ///////////////////////////////////////////
    output reg  [1:0]  mismatch_r,        // Error indicator to host
    output             ls_enabled,     //Lockstep Enabled
    output reg         ls_enabled_d, //Lockstep Enabled - Delayed

    ////////// Fixed  input signals ///////////////////////////////////////////
    input [1:0]        ls_ctrl_enable, //LS enable bits fromm main & shadow.
    input              main_clk,
    input              shadow_clk,
    input              ls_lock_reset,   // from main core to reset lock
    input [1:0]        diag_mode,
    input diag_mask_last,
    input diag_mask_first,
    input              rst
    );

reg        lse_parity_error;
reg        lsed_parity_error;
wire       error_result_parity_error;
wire       delayed_lock_reset_dr1_pe, delayed_lock_reset_dr2_pe;
wire       delayed_lock_reset_parity_error;
wire [1:0] ls_lock_reset_dr;
wire [1:0] delayed_lock_reset_dr;
wire       delayed_lock_reset;
wire       delayed_lock_reset1, delayed_lock_reset2;
wire       diag_mode_en    = diag_mode == 2'b10;
wire       diag_mode_valid = diag_mode_en && diag_mask_last;


wire local_parity_error;

assign local_parity_error = lsed_parity_error
    | lse_parity_error
    | error_result_parity_error
    | delayed_lock_reset_parity_error
    ;

wire parity_error = local_parity_error;


wire update_errors;
assign update_errors = 
    ls_lock_reset |
    ~ls_enabled ;

wire error_result_nxt = update_errors ? 0 : error_bit|parity_error;

//Decode the ls_ctrl bits from the cores for LS Enable
reg [1:0]  ls_enable_next; //From SAFETY_CTRL bits
reg [1:0]  ls_enable_r;
reg        ls_enable;
wire [1:0] ls_enabled_d_r;

generate
if (DELAY == 0) begin:DELAY_eq_0
  assign ls_enabled_d_r = ls_enable_r;
end
else begin:DELAY_gt_0
  ls_input_delay_without_parity #( .REG_WIDTH(2),.DELAY(DELAY) ) u_ls_enabled_dly (
      .d_in        (ls_enable_r),
      .clk         (shadow_clk),
      .rst         (rst),
      .q_out       (ls_enabled_d_r),
      .en		 (1'b1)
      );
  end
endgenerate


    always @* begin: ls_enabled_d_PROC
        // Compute ls_enabled_d and lsed_parity_error 
	ls_enabled_d = 1'b0;
	lsed_parity_error = 1'b0;
        case (ls_enabled_d_r)
	 `SAFETY_LOW_N: begin
	    ls_enabled_d = 1'b0;
	    lsed_parity_error = 1'b0;
	    end
	 `SAFETY_HIGH_N: begin
	    ls_enabled_d = 1'b1;
	    lsed_parity_error = 1'b0;
	    end
	 default: begin
	    ls_enabled_d = 1'b0;
	    lsed_parity_error = 1'b1;
	    end
        endcase
      end
    always @* begin: ls_enable_PROC
        // Compute ls_enable and lse_parity_error 
	ls_enable = 1'b0;
	lse_parity_error = 1'b0;
        case (ls_enable_r)
	 `SAFETY_LOW_N: begin
	    ls_enable = 1'b0;
	    lse_parity_error = 1'b0;
	    end
	 `SAFETY_HIGH_N: begin
	    ls_enable = 1'b1;
	    lse_parity_error = 1'b0;
	    end
	 default: begin
	    ls_enable = 1'b0;
	    lse_parity_error = 1'b1;
	    end
        endcase
      end



    always @* begin: ls_ctrl_decode_PROC
        ls_enable_next = ls_enable_r;
        case (ls_ctrl_enable)
          // The two bits are one from each core's ls_ctrl_enable signal.
          2'b00: ls_enable_next = `SAFETY_LOW_N; //Disable
          2'b01: ls_enable_next = `SAFETY_LOW_N; //Disable
          2'b10: ls_enable_next = `SAFETY_LOW_N; //Disable
          // 11 means both cores have lockstep enabled in the control register.
          2'b11: ls_enable_next = `SAFETY_HIGH_N; //Cores Sync'd - Enable
          endcase
       end // block: ls_ctrl_decode_PROC

    always @(posedge main_clk or posedge rst) begin: ls_ctrl_PROC
        if (rst == 1'b1)
          ls_enable_r <= `SAFETY_LOW_N;
        else
          ls_enable_r <= ls_enable_next;
        end //block: ls_ctrl_PROC



    // Drive output.
    assign ls_enabled = ls_enable;

    // Compute mismatch.

    reg [1:0] mismatch;
    reg [1:0] mismatch_r_n;

    wire error_result, error_result_nok, error_result_nxt_nok;

    assign error_result_nok     = error_result == 0 ? 1'b0 : 1'b1;
    assign error_result_nxt_nok = error_result_nxt == 0 ? 1'b0 : 1'b1;

    localparam NO_ERROR = 2'b01;
    localparam MISMATCH_ERROR = 2'b10;
    localparam NO_ERROR_N = 2'b00;
    localparam MISMATCH_ERROR_N = 2'b11;

    always @* begin : mismatch_PROC // [
    if (diag_mode_valid) begin
	if ((diag_mask_first || mismatch_r_n == MISMATCH_ERROR_N) && error_result_nxt_nok)
            mismatch = MISMATCH_ERROR_N;
        else
            mismatch = NO_ERROR_N;
        end 
    else if (diag_mode_en)
	mismatch = mismatch_r_n;
    else
    if (ls_enabled_d && !delayed_lock_reset)
        begin // not in: dual core, debug + halt AND LS Enabled
	    if (error_result_nok || error_result_nxt_nok)
		mismatch = MISMATCH_ERROR_N;
	    else
		mismatch = NO_ERROR_N;
        end
    else
    if (delayed_lock_reset || ls_lock_reset)
	mismatch = NO_ERROR_N;
    else if (local_parity_error == 1'b0) //parity error in local blocks
	mismatch = mismatch_r_n;
    else
	mismatch = MISMATCH_ERROR_N;
    end // block: mismatch_PROC // ]

    //Hold the error state until lock reset
    wire error_mx_hld;
    assign error_mx_hld = ls_lock_reset | delayed_lock_reset ? 1'b0 : error_result_nok;
    
    reg error_result_mxd;

    always @* begin: error_reg_PROC
	// Deliver the error_register result or lock it to the old value
	// if lock occurs.
        if (error_mx_hld)
	    // Locked; retain old value (lock the error register).
	    error_result_mxd = error_result;
        else
	    error_result_mxd = error_result_nxt;
      end

    wire error_result_override;

    assign error_result_override = ls_lock_reset ? 1'b0 : error_result_mxd;
    simple_parity #(.DATA_WIDTH(1)) u_error_rslt (
	.din  (error_result_override),
	.clk  (main_clk),
	.rst  (rst),
	.dout (error_result),
	.parity_err(error_result_parity_error)
	);



    always @(posedge main_clk or posedge rst) begin: reg_PROC
	// Output assignment.
        if (rst == 1'b1)
            mismatch_r_n <= NO_ERROR_N; //that's 00
        else
            mismatch_r_n <= mismatch;
	end //block: reg_PROC


    always  @* begin: flip_mismatch_PROC
	mismatch_r = {mismatch_r_n[1],~mismatch_r_n[0]};
	end

    // Lock the pipeline when the mask indicates an error
    // Bit flips in the em_mismatch will lock the pipe
    // error lock - 01 is normal (no lock)
    // Lock Reset from Core
    // The core can reset the lock - usefull when running the debugger
    // The lock reset signal will be delayed to flush out the reset instructions
    // from comparrison by LS since only one core will issue the reset from
    // the aux register.

    // Convert to dual rail to protect flop

    assign ls_lock_reset_dr = ls_lock_reset ? 2'b10 : 2'b01;

    wire [1:0] delayed_lock_reset_dr1;
    wire [1:0] delayed_lock_reset_dr2;

simple_parity  #(.DATA_WIDTH(2)) u_ls_reset_delay1 (
    .din  (ls_lock_reset_dr),
    .clk  (main_clk),
    .rst  (rst),
    .dout (delayed_lock_reset_dr1),
    .parity_err(delayed_lock_reset_dr1_pe)
    );

simple_parity  #(.DATA_WIDTH(2)) u_ls_reset_delay2 (
    .din  (delayed_lock_reset_dr1),
    .clk  (main_clk),
    .rst  (rst),
    .dout (delayed_lock_reset_dr2),
    .parity_err(delayed_lock_reset_dr2_pe)
    );


assign delayed_lock_reset1 = delayed_lock_reset_dr1 == 2'b10 ? 1'b1 : 1'b0;
assign delayed_lock_reset2 = delayed_lock_reset_dr2 == 2'b10 ? 1'b1 : 1'b0;
assign delayed_lock_reset  = delayed_lock_reset1 | delayed_lock_reset2
                            | diag_mode_valid
                           ;
assign delayed_lock_reset_parity_error = delayed_lock_reset_dr1_pe | delayed_lock_reset_dr2_pe;
// spyglass enable_block W240
// spyglass enable_block Ac_coherency06

endmodule

// PECSV 
//These are verilog-mode pragmas to aid autoinstantiation of modules
// Local Variables:
// verilog-library-directories:(".")
// verilog-library-extensions:(".v" ".vpp" ".h")
// End:
