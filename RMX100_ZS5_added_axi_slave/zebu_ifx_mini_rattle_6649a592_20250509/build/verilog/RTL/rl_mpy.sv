//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Description:
// @p
//
//
// @e
//
//
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions
//
`include "defines.v"
`include "mpy_defines.v"
`include "alu_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_mpy (
  ////////// Dispatch interface /////////////////////////////////////////////
  //
  input                      x1_pass,               // instruction dispatched to the MPY FU
  input [`MPY_CTL_RANGE]     x1_mpy_ctl,            // Indicates the instructon to be executed in this FU
  input [`DATA_RANGE]        x1_src0_data,          // source0 operand
  input [`DATA_RANGE]        x1_src1_data,          // source1 operand
  input [4:0]                x1_dst_id,             // destination register - used for scoreaboarding

  output                     mpy_x1_ready,          // MPY ready for new instruction

  ////////// X2 stage interface /////////////////////////////////////////////
  //
  input                      x2_valid_r,            // X2 valid instruction from pipe ctrl
  input                      x2_pass,               // X2 instruction passed to X3 (commit)
  input                      x2_flush,              // Pipeline flush
  input                      x2_retain,             // Pipeline retain
  output                     mpy_x2_dst_id_valid,   // MPY X2 valid destination
  output reg [4:0]           mpy_x2_dst_id_r,       // MPY X2 destination register - used for scoreaboarding

  ////////// X3 stage interface /////////////////////////////////////////////
  //
  output [`DATA_RANGE]       mpy_x3_data,           // MPY X3 result available for bypass
  output reg [4:0]           mpy_x3_dst_id_r,       // MPY X3 destination register - used for scoreaboarding
  output                     mpy_x3_dst_id_valid,   // MPY X3 valid destination
  output reg                 mpy_x3_rb_req_r,       // MPY requests result bus to write to register file
  input                      x3_mpy_rb_ack,         // results bus granted MPY access (write port)

  output                     mpy_x3_stall,          // MPY X3 stall
  output                     mp3_mpy_busy_r,


  ////////// MPY clock gating signals output ///////////////////////////////////
  //
  output                    mpy_x1_valid,
  output                    mpy_x2_valid,
  output reg                mpy_x3_valid_r,

  ////////// General input signals /////////////////////////////////////////////
  //
  input                      clk,                   // clock signal
  input                      rst_a                  // reset signal
);



// Local declarations and assignments mpy_x1_*
//
wire mpy_x1_src0_signed;
assign mpy_x1_src0_signed = 1'b0
                          | x1_mpy_ctl[`MPY_CTL_MUL]
                          | x1_mpy_ctl[`MPY_CTL_MULH]
                          | x1_mpy_ctl[`MPY_CTL_MULHSU]
                          | x1_mpy_ctl[`MPY_CTL_DIV]
                          | x1_mpy_ctl[`MPY_CTL_REM]
                          ;

wire mpy_x1_src1_signed;
assign mpy_x1_src1_signed = 1'b0
                          | x1_mpy_ctl[`MPY_CTL_MUL]
                          | x1_mpy_ctl[`MPY_CTL_MULH]
                          | x1_mpy_ctl[`MPY_CTL_DIV]
                          | x1_mpy_ctl[`MPY_CTL_REM]
                          ;

wire mpy_x1_res_hi;
assign mpy_x1_res_hi = 1'b0
                     | x1_mpy_ctl[`MPY_CTL_MULH]
                     | x1_mpy_ctl[`MPY_CTL_MULHSU]
                     | x1_mpy_ctl[`MPY_CTL_MULHU]
                     ;

wire mpy_x1_div;
wire mpy_x1_rem;
assign mpy_x1_div = 1'b0
                  | x1_mpy_ctl[`MPY_CTL_DIV]
                  | x1_mpy_ctl[`MPY_CTL_DIVU]
                  | x1_mpy_ctl[`MPY_CTL_REM]
                  | x1_mpy_ctl[`MPY_CTL_REMU]
                  ;

assign mpy_x1_rem = 1'b0
                  | x1_mpy_ctl[`MPY_CTL_REM]
                  | x1_mpy_ctl[`MPY_CTL_REMU]
                  ;


assign mpy_x1_valid = (| x1_mpy_ctl);

wire mpy_x1_pass;
assign mpy_x1_pass = x1_pass & mpy_x1_valid;

// Local declarations and assignments mpy_x2_*
//
reg mpy_x2_valid_r;
assign mpy_x2_valid = mpy_x2_valid_r & x2_valid_r;

assign mpy_x2_dst_id_valid = (mpy_x2_valid   & (| mpy_x2_dst_id_r))
                           |  (mp3_mpy_busy_r & (| mpy_x2_dst_id_r))
                           ;

wire mpy_x2_pass;
assign mpy_x2_pass = mpy_x2_valid & x2_pass;

reg mpy_x2_src0_signed_r;
reg mpy_x2_src1_signed_r;
reg mpy_x2_res_hi_r;
reg mpy_x2_div_r;
reg mpy_x2_rem_r;

// Clock-gates X2
//
reg mpy_x2_ctl_cg0;
assign mpy_x2_ctl_cg0 = mpy_x1_pass | (mpy_x2_valid_r && (~mpy_x3_stall) && (x2_flush || !x2_retain));

reg mpy_x2_data_cg0;
assign mpy_x2_data_cg0 = mpy_x1_pass;

// Local declarations and assignments mpy_x3_*
//
reg mpy_x3_stall_w;
assign mpy_x3_stall_w = mpy_x3_rb_req_r & ~x3_mpy_rb_ack;

assign mpy_x3_stall = mpy_x2_valid_r & mpy_x3_stall_w;

assign mpy_x3_dst_id_valid =  mpy_x3_valid_r & |mpy_x3_dst_id_r
                           &  (~mp3_mpy_busy_r)
                           ;

reg mpy_x3_res_hi_r;

// Clock-gates X3
//
reg mpy_x3_ctl_cg0;
assign mpy_x3_ctl_cg0 =  mpy_x2_pass
                      | ( mpy_x3_valid_r &
                         ~mp3_mpy_busy_r &
                         ~mpy_x3_stall_w);

reg mpy_x3_data_cg0;
assign mpy_x3_data_cg0 = mpy_x2_pass
                       | mp3_mpy_busy_r
                       ;

//////////////////////////////////////////////////////////////////////////////////////////
//
// Code for the actual MPY functional unit
//
//
//////////////////////////////////////////////////////////////////////////////////////////

// Definition of top-level multiplier states
//
localparam MPY_PHASE_BITS  = 3;
localparam MPY_PHASE_MSB   = (MPY_PHASE_BITS-1);
`define    MPY_PHASE_RANGE   MPY_PHASE_MSB:0
localparam MPY_PHASE_0     = 3'b000;
localparam MPY_PHASE_3     = 3'b011;
localparam MPY_PHASE_7     = 3'b111;

// Definition of the four kinds of multiply operator
//
localparam MPY_NOP         = 3'b000;
localparam MPY_MPYLO       = 3'b001;
localparam MPY_MPYHI       = 3'b010;
localparam MPY_MPYW        = 3'b011;
localparam NON_MPY_RANGE   = 2;
localparam MPY_DIV         = 3'b100;
localparam MPY_REM         = 3'b110;

// Definitions for the multiplier pipeline state machine
//
localparam MPY_STATE_BITS  = 3;
localparam MPY_STATE_MSB   = (MPY_STATE_BITS-1);
`define    MPY_STATE_RANGE   MPY_STATE_MSB:0
localparam IDLE_STATE      = 3'b000;
localparam MPY_INIT_STATE  = 3'b001;
localparam MPY_REPT_STATE  = 3'b010;
localparam DIV_INIT_STATE  = 3'b100;
localparam DIV_REPT_STATE  = 3'b101;
localparam RESULT_STATE    = 3'b110;
localparam CHAINING_STATE  = 3'b111;

`define    MPYHI_OPT         0 //@@@ Enable later

//////////////////////////////////////////////////////////////////////////////
// Pipeline registers, state variable, and next values for each of them.    //
//                                                                          //
//  Name prefix convention for multiplier pipeline registers:               //
//                                                                          //
//  mp1_*  signals prior to the input of the multiplier pipeline, aligned   //
//         with the X1 stage of the main CPU pipeline                       //
//                                                                          //
//  mp2_*  all registers at the input of the  multiplier pipeline, and all  //
//         signals derived within that pipeline stage, aligned with the     //
//         X2 stage of the main CPU pipeline.                               //
//                                                                          //
//  mp3_*  signal names for values normally returned from the 3rd stage     //
//         of a pipelined multiplier unit.                                  //
//                                                                          //
// This implementation of the multiplier pipeline is optimized for minimum  //
// gate count, and therefore has a single pipeline stage.                   //
// All registers are effectively positioned at the boundary between the     //
// Execute stage and the Commit stage (stages 2 and 3 of the main pipeline).//
//                                                                          //
// In the first cycle of a multi-cycle operation, the mp2_* registers       //
// contain a new operation that has yet to commit. At this point, asserting //
// ca_abort_evt will kill the operation. In the second and subsequent       //
// cycles, the multi-cycle operation is committed and will therefore be     //
// unaffected by ca_abort_evt.                                              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// Second source input register (multiplicand or divisor)
//
reg   [`MPY_RANGE]         mp2_src2_r;
reg   [`MPY_RANGE]         mp2_src2_nxt;

// Multiplier state-machine pipeline registers
//
reg   [`MPY_STATE_RANGE]    mp2_state_r;
reg   [`MPY_STATE_RANGE]    mp2_state_nxt;

// General instruction control bits
//
reg                         mp2_flag_wen_r;
reg                         mp2_signed_op_r;

reg   [`RGF_ADDR_RANGE]     mp2_rf_wa0_r;
reg                         mp2_rf_wenb0_r;

// Multiplier instruction control bits
//
reg   [`MPY_KIND_RANGE]     mp2_op_kind_r;
reg   [`MPY_KIND_RANGE]     mp2_op_kind_nxt;

reg                         mp2_mpy16_r;
reg                         mp2_mpy16_nxt;
reg                         extend_mcnd;

// Multiplier phase register, counts from 0 to 7
//
reg   [`MPY_PHASE_RANGE]    mp2_phase_r;
reg   [`MPY_PHASE_RANGE]    mp2_phase_nxt;

// Sign of first source operand for division logic
//
reg                         mp2_sign1_r;
reg                         mp2_sign1_nxt;

// Divide and remainder mask register, indicates shifting boundary
// between dividend and quotient in the result accumulator register
//
reg   [31:0]                mp2_mask_r;
reg   [31:0]                mp2_mask_nxt;

reg                         mp2_div_zero_r; // 1 => div/rem and 0 divisor
reg                         mp2_overflow_r; // src1 = 0x80000000 and src2 = -1

// Result / accumulator register also contains source operand 1
//
reg   [65:0]                mp2_result_r;
wire  [64:0]                mp3_result_r;

// Result bus request when the result is available
//
reg                         mpy_req_rb_nxt;

///////////////////////////////////////////////////////////////////////////////
// Internal signal declarations                                              //
///////////////////////////////////////////////////////////////////////////////

// 37-bit Carry and Sum outputs from the 32x4 combinational multiplier
//
wire  [36:0]                mp2_pcarry;     // 36-bit partial sum
wire  [36:0]                mp2_psum;       // 36-bit partial carry

// Register enable signals at input stage:
//
reg                         mp2_state_en;   // Enable FSM registers
reg                         mp2_data_en;    // Enable input data registers
reg                         mp2_inst_en;    // Enable incoming instruction

reg                         mp2_active_mpy; // 1 iff mpy operation is active
reg                         mp2_active_div; // 1 iff div/rem operation active
reg                         mp2_mpy_busy_r; // MPY/DIV operation status
wire                        mp2_mpy_busy_nxt;

// Signals for detecting overflow of the lower product
//
reg                         hi_zero;
reg                         hi_ones;

// Signal to determine what size and range of product is required
//
reg                         mp1_do_high;
reg   [`MPY_KIND_RANGE]     mp1_op_kind;

// Signals to detect insignificance of upper 16-bit half of the multiplier
// and the multiplicand.
//
reg                         mcnd_16bit;     // Multiplicand is a 16-bit value
reg                         mpyr_16bit;     // Multiplier is a 16-bit value

// Signals to indicate pre-commit and post-commit phases of any multi-cycle
// multiply or divide operation within this module.
//
reg                         phase_0;        // First phase of MPY operation
reg                         phase_3;        // Fourth phase of MPY operation
reg                         final_3;        // Final phase, impliees 16x16 MPY
reg                         phase_7;        // Final phase, implied 32x32 MPY
reg                         slice_7;        // Compute last 32x4 partial product

reg                         x1_valid_mpy;   // Next MPY operation is valid
reg                         x1_pass_mpy;    // Valid MPY operation ready
reg                         x1_valid_div;   // Next DIV operation is valid
reg                         x1_pass_div;    // Valid DIV operation ready
reg                         x1_pass_op;     // Accept new mpy_pipe operation
// leda NTL_CON12 off
reg   [`DATA_RANGE]         mp1_src1;       // Power-gated source operand 1
reg   [`DATA_RANGE]         mp1_src2;       // Power-gated source operand 2
  // leda NTL_CON12 on

reg                         ra0_is_mp2;
reg                         ra1_is_mp2;
reg                         wa0_is_mp2;
reg                         wa1_is_mp2;

reg                         raw_hazard;
reg                         waw_hazard;
reg                         busy_hazard;

reg                         mp2_valid_mpy;
reg                         mp2_start_mpy;
reg   [36:0]                add_src1;       // src1 of carry-propagate adder
reg   [36:0]                add_src2;       // src2 of carry-propagate adder
reg   [37:0]                adder_sum;      // 38-bit sum/difference
reg   [65:0]                mpy_acc_nxt;    // Next MPY accumulator value

// Signals for controlling iterative div/rem operations, and other internal
// signals within the div/rem datapath
//
reg                         div_init;       // 1 => initial cycle of DIV/REM
reg                         div_tini_r;     // 1 => final cycle of DIV/REM
reg                         div_tini_nxt;

reg                         sign_1;         // 2's complement sign of src1
reg                         sign_2;         // 2's complement sign of src2
reg                         qbit;           // next quotient bit
reg                         sxor;           // XOR of div/rem opd signs
reg                         sub_op;         // Perform subtract operation

// Datapath signals for the DIV/REM/DIVU/REMU implementation
//
reg   [31:0]                div_src1;       // src1 of add/sub operation
reg   [31:0]                div_src2;       // src2 of add/sub operation
reg                         sum_ltz;        // 1 => (adder_sum < 0)
reg   [64:0]                div_acc_nxt;    // Next DIV/REM accumulator value
reg                         dvs_zero;       // Trailing zero on divisor
reg                         sz_dvs;         // adder_sum == 0 and dvs_zero == 1

// Signals to implement flow of control between the multiply-pipe and the
// main pipeline.
//
reg                         mp2_active_op;  // 1 => unit is not idle
reg                         mp2_holdup;     // 1 => stall upstream stages

reg mpy_x2_signed;
assign mpy_x2_signed = mpy_x2_src0_signed_r | mpy_x2_src1_signed_r;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Instantiate the 32x4 Wallace-tree multiply-accumulate module             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

rl_wtree_32x4 u_wtree_32x4 (
  .a             (mp2_src2_r[32:0]   ), // 32-bit multiplicand
  .b             (mp2_result_r[3:0]  ), // 4-bit multiplier slice
  .acc           (mp2_result_r[65:32]), // 33 bits of accumulator slice
  .signed_op     (mpy_x2_signed      ), // 0 => unsigned, 1 => signed
  .slice_0       (phase_0            ), // 1 => first of eight 'slices'
  .slice_7       (slice_7            ), // l => last of eight 'slices'
  .enb           (mp2_active_mpy     ), // 1 enables, 0 disables inputs
  .psum          (mp2_psum           ), // output sum bits
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: Highest Carry bit is useless in calculation
  .pcarry        (mp2_pcarry         )  // output carry bits
// spyglass enable_block UnloadedOutTerm-ML
);


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Finite state machine for this multi-cycle multiplier module              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

reg               x2_holds_mp2;       // x2_holdup stalls mp2 progress
reg               mp2_new_op;         // mpy_pipe can accept new operation
reg               mp2_end_op;         // mpy_pipe completes previous operation
reg               mp2_new_data;       // mpy_pipe computes new data this cycle
reg               mp2_rf_wait;        // waiting for result to be accepted

wire mpy_x3_rb_ack_comb;
assign mpy_x3_rb_ack_comb = x3_mpy_rb_ack | !(|mpy_x3_dst_id_r);

always @*
begin : mpy_fsm_PROC

  mp2_state_nxt   = IDLE_STATE;

  x2_holds_mp2    = 1'b0;        // asserted when FSM is in any pre-commit state
  mp2_new_op      = 1'b0;        // asserted to trigger mp2_inst_en
  mp2_end_op      = 1'b0;        // asserted to trigger mp2_inst_en
  mp2_new_data    = 1'b0;        // asserted to trigger mp2_data_en
  mp2_rf_wait     = 1'b0;        // asserted when result is not accepted this cycle
  mp2_start_mpy   = 1'b0;        // asserted when a valid MPY is starting
  mp2_valid_mpy   = 1'b0;        // asserted when a valid MPY is underway
  mpy_req_rb_nxt  = 1'b0;        // asserted when result is ready for retirement

  x1_valid_mpy    = mpy_x1_valid & (mpy_x1_div == 1'b0);
  x1_pass_mpy     = x1_valid_mpy & x1_pass;
  x1_valid_div    = mpy_x1_div;
  x1_pass_div     = x1_valid_div & x1_pass;

  //leda W71 off
  case (mp2_state_r)
  IDLE_STATE:
  begin
    x2_holds_mp2 = 1'b1;
    if (x1_pass_mpy == 1'b1)
    begin
      mp2_state_nxt = MPY_INIT_STATE;
      mp2_new_op    = 1'b1;
      mp2_new_data  = 1'b1;
      mp2_start_mpy = 1'b1;
    end
    else if (x1_pass_div == 1'b1)
    begin
      mp2_state_nxt = DIV_INIT_STATE;
      mp2_new_op    = 1'b1;
      mp2_new_data  = 1'b1;
    end
  end

  MPY_INIT_STATE:
  begin
    x2_holds_mp2  = 1'b1;
    mp2_new_data  = 1'b1;
    mp2_valid_mpy = 1'b1;
    if (x2_flush == 1'b1)
    begin
      mp2_state_nxt = IDLE_STATE;
      mp2_end_op    = 1'b1;
    end
    else
      mp2_state_nxt = MPY_REPT_STATE;
  end

  MPY_REPT_STATE:
  begin
    mp2_new_data  = 1'b1;
    mp2_valid_mpy = 1'b1;
    if (slice_7 == 1'b1)
    begin
      mpy_req_rb_nxt = 1'b1;
      mp2_state_nxt  = RESULT_STATE;
    end
    else
      mp2_state_nxt  = MPY_REPT_STATE;
  end

  DIV_INIT_STATE:
  begin
    x2_holds_mp2  = 1'b1;
    mp2_new_data  = 1'b1;
    if (x2_flush == 1'b1)         // div_by_zero exception will assert ca_abort_evt
    begin
      mp2_state_nxt = IDLE_STATE;
      mp2_end_op    = 1'b1;
    end
    else
      mp2_state_nxt = DIV_REPT_STATE;
  end

  DIV_REPT_STATE:
  begin
    mp2_new_data  = 1'b1;
    if (div_tini_r == 1'b1)
    begin
      mpy_req_rb_nxt = 1'b1;
      mp2_state_nxt  = RESULT_STATE;
    end
    else
      mp2_state_nxt = DIV_REPT_STATE;
  end

  RESULT_STATE:
  begin
// spyglass disable_block DisallowCaseZ-ML
// SMD: Do not use casez constructs in the design
// SJ : Intended as per the design
    casez ({   mpy_x3_rb_ack_comb
              ,x1_pass_mpy
              ,x1_pass_div
           })
// spyglass enable_block DisallowCaseZ-ML
    3'b0??:
      mp2_state_nxt = RESULT_STATE;

    3'b11?:
    begin
      mp2_state_nxt = MPY_INIT_STATE;
      mp2_new_op    = 1'b1;
      mp2_new_data  = 1'b1;
      mp2_start_mpy = 1'b1;
      end

    3'b101:
    begin
      mp2_state_nxt = DIV_INIT_STATE;
      mp2_new_op    = 1'b1;
      mp2_new_data  = 1'b1;
      end


    3'b100:
    begin
      mp2_state_nxt = IDLE_STATE;
      mp2_end_op    = 1'b1;
    end
    endcase

      mp2_rf_wait = ~mpy_x3_rb_ack_comb;
    end


  endcase
  //leda W71 on

  // All mp2 input registers are held constant if the ca_holdup signal is
  // asserted and the current mp2 operation is pre-commit (x2_holds_mp2 == 1),
  // and the pipeline is not being flushed (ca_abort_evt == 1),
  // or if there is an outstanding result to be written back to the
  // register file (mp2_rf_wait == 1).
  //
  mp2_holdup      = ((mpy_x2_valid & ~x2_pass) & x2_holds_mp2 & ~x2_flush) | mp2_rf_wait;

  mp2_state_en    = (~mp2_holdup | x2_flush) & (mp2_state_nxt != mp2_state_r);
  mp2_inst_en     = (~mp2_holdup) & (mp2_new_op | mp2_end_op);
  mp2_data_en     = (~mp2_holdup) & mp2_new_data;

  mp2_active_op   = (mp2_state_r != IDLE_STATE);
  mp2_active_mpy  = (  (mp2_state_r == MPY_INIT_STATE)
                      |(mp2_state_r == MPY_REPT_STATE));
  mp2_active_div  = (  (mp2_state_r == DIV_INIT_STATE)
                      |(mp2_state_r == DIV_REPT_STATE));

end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational process defining the control signals for mpy_pipe          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : mpy_ctrl_PROC

  //////////////////////////////////////////////////////////////////////////
  // div_init is asserted when a new div/rem operation is arriving at the
  // mp2 (commit) stage.
  //
  div_init    = x1_valid_div & (~mp2_active_div);


  x1_pass_op  = x1_pass_mpy
              | x1_pass_div
              ;



  //////////////////////////////////////////////////////////////////////////
  // phase_0 and phase_7 decode the start and end phases of a 32x32 multiply
  // operation. When performing a 16x16 multiply operation, indicated by
  // mp2_mpy16_r == 1, the final phase is phase_3.
  //
  phase_0     = (mp2_phase_r == MPY_PHASE_0);
  phase_3     = (mp2_phase_r == MPY_PHASE_3);
  phase_7     = (mp2_phase_r == MPY_PHASE_7);
  final_3     = (phase_3 & mp2_mpy16_r);
  slice_7     = phase_7 | final_3;

end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational process defining the datapath at mp1 (Execute stage)       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : mp1_data_PROC

  //////////////////////////////////////////////////////////////////////////
  // Gate the input values with the da_mpy_op or da_div_op microcode bits
  // before deriving any further combinational signals from the data.
  // This is to prevent unwanted transitions in the combinational logic
  // in the mp1 input data selection logic, to minimize dynamic power.
  // This logic also swaps around the inputs for mpy operations, to increase
  // the probability of reducing the number of cycles for short multiplier
  // operands.
  //
  // leda NTL_CON12 off
  mp1_src1  = {`DATA_SIZE{x1_valid_mpy}} & x1_src0_data
            | {`DATA_SIZE{x1_valid_div}} & x1_src0_data;

  mp1_src2  = {`DATA_SIZE{x1_valid_mpy}} & x1_src1_data
            | {`DATA_SIZE{x1_valid_div}} & x1_src1_data;
  // leda NTL_CON12 on


  //////////////////////////////////////////////////////////////////////////
  // The 32-bit mp2_mask_r register keeps track of the dividend bits in
  // the quotient register that have not yet been shifted out of the
  // most-significant end of that register. Any zero bit in mp2_mask_r
  // indicates a bit position in mp2_result_r[31:0] that still contains
  // a bit from the dividend that was loaded during initialization.
  // Hence, during initialization, mp2_mask_nxt is cleared, and on all
  // other cycles it is set to ((mp2_mask_r << 1) | 1).
  //
  mp2_mask_nxt  = mp2_active_div & (mp2_mask_r != 32'hffffffff)
                ? {mp2_mask_r[30:0], 1'b1}
                : 32'd0;

  //////////////////////////////////////////////////////////////////////////
  // div_tini_r is asserted after the main 32-cycle iterative division loop,
  // to indicate that the final correction cycle is in progress. During
  // this cycle the quotient value is incremented (if signs of divisor
  // and dividend were different), and the remainder value is right-shifted
  // by one bit (to counteract the final shift).
  //
  div_tini_nxt  = mp2_active_div & (mp2_mask_r == 32'hffffffff);

  // leda W484 off
  mp2_phase_nxt = mp2_valid_mpy
                ? mp2_phase_r + 1
                : MPY_PHASE_0;
  // leda W484 on

  //////////////////////////////////////////////////////////////////////////
  //  Upper 16-bit half of the multiplier operand is compared with zero
  //  (for unsigned MPY) and the sign bit (for signed MPY).
  //  This is used to short-cut the state machine, to avoid computing the
  //  upper four 32x4 sub-products if the multiplier can be represented
  //  as a 16-bit value.
  //
  //  The multiplier is effectively a 16-bit value if:
  //
  //    (a). We are performing a signed mpy and (src1[30:15] == {16{src1[31]}}
  //  or
  //    (b). We are performing an unsigned mpy and (src1[31:16] == 0)
  //
  //  The same principle applies to the multiplicand.
  //
  mpyr_16bit = ( mpy_x1_src0_signed   & (mp1_src1[30:15] == {16{mp1_src1[31]}}))
             | ((~mpy_x1_src0_signed) & (mp1_src1[31:16] == 16'd0))
             ;

  mcnd_16bit = ( mpy_x1_src1_signed   & (mp1_src2[30:15] == {16{mp1_src2[31]}}))
             | ((~mpy_x1_src1_signed) & (mp1_src2[31:16] == 16'd0))
             ;

  //////////////////////////////////////////////////////////////////////////
  // Logic to determine if the incoming mpy operation is either 16x16y32,
  // or 32x16y16.
  //
  // The operation is explicitly 16x16y32 when mp1_op_kind == MPY_MPYW
  // (i.e. MPYW or MPYUW instructions). It is implicitly 16x16y32 if it is
  // possible to determine that both the multiplier and the multiplicand
  // are representable as a 16-bit values, and if an overflow flag is not
  // required, and if the upper 32-bit result is not needed (MPY, MPYU).
  //
  // An operation is implicitly 32x16y32 if the multiplier is representable
  // as a 16-bit value, but the multiplicand cannot. In this case we can
  // still reduce the number of phases to 4, but we must not perform any
  // sign/zero extension on the multiplicand.
  //
  // The extend_mcnd signal is asserted when both multiplier and multiplicand
  // are 16-bit effective values and the operation is convertible into a
  // 16x16y32 operation.
  //
  // The mpy_mpy16_nxt signal is asserted when the multiplier is a 16-bit
  // effective value and the operation is convertible into an Nx16y32
  // operation, where N may be 16 or 32, depending on mcnd_16bit.
  //
  mp2_mpy16_nxt = 1'b0  // (mp1_op_kind == MPY_MPYW)   MPYW or MPYUW
                | (   x1_valid_mpy            // or any other type of MPY
                    & (~mpy_x1_res_hi)        //   and don't need upper bits
                    & mpyr_16bit              //   and multiplier is 16-bit
                  )                           //   (including multiplier 0)
                ;

  extend_mcnd   = 1'b0 // (mp1_op_kind == MPY_MPYW) MPYW or MPYUW
                | (   x1_valid_mpy            // or any other type of MPY
                    & (~mpy_x1_res_hi)        //   and don't need upper bits
                    & mcnd_16bit              //   and multiplicand is 16-bit
                    & mpyr_16bit              //   and multiplier is 16-bit
                  )                           //   (including 0 values)
                ;

  //////////////////////////////////////////////////////////////////////////
  // Logic to determine if the incoming mpy operation is 16x16y32, either
  // explicitly or implicitly.
  //
  // The operation is explicitly 16x16y32 when mp1_op_kind == MPY_MPYW
  // (i.e. MPYW or MPYUW instructions). It is implicitly 16x16y32 if it is
  // possible to determine that both the multiplier and the multiplicand
  // are representable as a 16-bit values, and if an overflow flag is not
  // required, and if the upper 32-bit result is not needed (MPY, MPYU).
  //

  //////////////////////////////////////////////////////////////////////////
  // Logic to determine the kind of operator being performed.
  //
  //  The mp2_op_kind_nxt[2:0] field encodes one of the operators from the
  //  set:
  //    {  MPY_NOP (000), MPY_MPYLO (001), MPY_MPYHI (010), MPY_MPYW (011) }
  //    {  MPY_DIV (100), MPY_NOP (101),   MPY_REM (110),   MPY_NOP (111) }
  //
  //  The most-significant bit of mp2_op_kind_nxt is given by da_valid_div,
  //  which is always 0 when da_valid_mpy is 1.
  //
  //  The logic here determines the type of the next mp2 operator, based
  //  on the type of operator presented to it from the Execute stage and
  //  whether it can be converted to a simpler 16x16y32 operation.
  //
  //  1. If there is no valid incoming operation, then the kind is set
  //     to MPY_NOP (000).
  //
  //  2. If the next operation is an MPYLO that can be convered to MPYW,
  //     or an equivalent Nx16y32 operation, where N maybe 16 or 32,
  //     then the kind is set to MPY_MPYW (011).
  //
  //  3. Otherwise, the next operation is set to mp1_op_kind.
  //
  //  If the Commit stage, which is aligned with mp2, is unable to accept
  //  the next instruction (indicated by ca_enable == 0), then the next
  //  mp2_op_kind must be set to MPY_NOP, which is all-zeros.
  //  Hence, mp2_op_kind_nxt is gated with da_pass_op, which includes
  //  ca_enable, before it is registered in the mp2 pipeline registers.
  //


  //////////////////////////////////////////////////////////////////////////
  // Logic to select the next multiplicand input register value.
  // This is extended from position 15 to position 31, with sign or zero
  // bits according to da_signed_op, if the next operation is MPY_MPYW.
  // Otherwise, the full 32-bit value is assigned to the multiplicand.
  //
  mp2_src2_nxt    = { (  extend_mcnd
                        ? {17{(mp1_src2[15] & mpy_x1_src1_signed)}}
                        : {(mp1_src2[31] & mpy_x1_src1_signed),mp1_src2[31:16]}
                      ),
                      mp1_src2[15:0]
                    };


  mp2_sign1_nxt = mpy_x1_src0_signed & x1_src0_data[31];  // needed for signed div/rem

end


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational block defining the second-stage data-path logic (mp2)      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : mp2_data_PROC

  //////////////////////////////////////////////////////////////////////////
  // sign_1 and sign_2 are asserted when performing signed division
  // (i.e. DIV or REM, but not DIVU or REMU) and the corresponding
  // source operand is negative.
  //
  sign_1      = mp2_sign1_r;                       // zero for unsigned ops
  sign_2      = mp2_src2_r[31] & mpy_x2_signed;  // zero for unsigned ops

  //////////////////////////////////////////////////////////////////////////
  // sxor is asserted whenever the sign bits of the two division operands
  // are different.
  //
  sxor        = (sign_1 != sign_2);

  //////////////////////////////////////////////////////////////////////////
  // sub_op is asserted whenever the division operand sign bits are the
  // same, and the divider is in the main iterative loop.
  //
  sub_op      = (sign_1 == sign_2) & (~div_tini_r);

  //////////////////////////////////////////////////////////////////////////
  // div/rem src1 for the adder comes from the quotient register
  // (mp2_result_r[31:0]) in the final cycle (in order to increment the
  // quotient), or from the remainder register (mp2_result_r[31:0] at all
  // other times.
  //
  div_src1    = (div_tini_r == 1'b1)
              ? mp2_result_r[31:0]
              : mp2_result_r[63:32];

  //////////////////////////////////////////////////////////////////////////
  // div/rem src2 for the adder comes from the dividend register (mp2_src2_r)
  // except when in the final cycle, when the src2 operand is the sxor value.
  //
  div_src2    = (div_tini_r == 1'b1)
              ? {31'd0, sxor}
              : mp2_src2_r[31:0];

  //////////////////////////////////////////////////////////////////////////
  // add_src1 and add_src2 are muxed from the either the outputs of the
  // 32x4 Wallace tree (mp2_psum, mp2_pcarry) or the two source operands
  // for the add/sub operation required by the current div/rem operation.
  //
  add_src1    = (mp2_active_mpy == 1'b1)
              ? mp2_psum
              : { 5'b00000, div_src1};

  add_src2    = (mp2_active_mpy == 1'b1)
              ? {mp2_pcarry[35:0], 1'b0}
              : { 5'b00000, (div_src2 ^ {32{sub_op}})};

  //////////////////////////////////////////////////////////////////////////
  // add the two values together, with optional carry-in when performing
  // subtract operations during iterative division.
  //
  adder_sum   = add_src1 + add_src2 + (sub_op & mp2_active_div);

  //////////////////////////////////////////////////////////////////////////
  // sum_ltz  is asserted if the adder_sum value is < 0.
  //
  sum_ltz     = mpy_x2_signed ? adder_sum[31] : (~adder_sum[32]);

  //////////////////////////////////////////////////////////////////////////
  // dvs_zero is asserted when the least-significant bits of the
  // dividend that have not yet been shifted out of the quotient register
  // are all zero.
  //
  dvs_zero    = (mp2_result_r[31:0] & (~mp2_mask_r)) == 32'd0;

  //////////////////////////////////////////////////////////////////////////
  // sz_dvs is asserted when the adder_sum is zero and dvs_zero is set to 1.
  //
  sz_dvs      = (adder_sum[31:0] == 32'd0) & dvs_zero;

  //////////////////////////////////////////////////////////////////////////
  // qbit represents the next quotient bit to be shifted into the
  // lsb of the quotient register (mp3_result_r[31:0]).
  //
  qbit        = (sum_ltz    &   sign_2                )
              | (sz_dvs     &   sign_2    &   sign_1  )
              | ((~sum_ltz) & (~sign_2)   & (~sign_1) )
              | ((~sum_ltz) & (~sz_dvs)   & (~sign_2) );

  //////////////////////////////////////////////////////////////////////////
  // The next value for the 65-bit division accumulator will be one of
  // the following;
  //
  // a). On the initialization cycle (div_init == 1), or when the
  //     divide unit is idle.
  //
  //     { {33{sign_1}}, mp2_src1_r }
  //
  //     The sign_ext signal is asserted when performing a signed operation
  //     and the dividend is negative. This extends the dividend from the
  //     lower 32 bits of the divide accumulator into the upper 32 bits also.
  //
  // b). When performing the add/sum operation (sign of rem will not change)
  //
  //     { adder_sum[31:0], mp2_result_r[31:0], qbit }
  //
  // c). When non-performing the add/sum operation (restoration of rem)
  //
  //     { mp2_result_r[63:0], qbit }
  //
  // d). On the termination cycle (div_tini == 1)
  //
  //     { 1'b0, mp2_result_r[64:33], adder_sum[31:0] }
  //

// spyglass disable_block DisallowCaseZ-ML
// SMD: Do not use casez constructs in the design
// SJ : Intended as per the design
  casez ({div_tini_r, div_init, (sxor ^ qbit)})
// spyglass enable_block DisallowCaseZ-ML
  3'b1??: div_acc_nxt = { 1'b0, mp2_result_r[64:33], adder_sum[31:0] };
  3'b01?: div_acc_nxt = { {33{mp2_sign1_nxt}}, mp1_src1[31:0] };
  3'b001: div_acc_nxt = { adder_sum[31:0], mp2_result_r[31:0], qbit };
  3'b000: div_acc_nxt = { mp2_result_r[63:0], qbit };
  endcase

  //////////////////////////////////////////////////////////////////////////
  // Select the next result accumulator input when performing a
  // multiplication operation. There are two choices in this case:
  //
  //  (a). Clear the upper 33 bits and set the lower 32 bits to be
  //       the multiplier (from da_src1).
  //
  //  (b). Concatenate the 37-bit adder output with the existing multiplier
  //       value from the lower 32 bits of the accumulator, and shift it
  //       to the right by 4 positions. This places adder_sum[36:0] in
  //       mp2_result_r[64:28] and shifts any previously-computed sum
  //       and unused multiplier bits down by 4 bits.
  //
  //  (c). Concatenate the 37-bit adder output with the most recent 12 bits
  //       of accumulated result in mp2_result_r[31:20], and shift down
  //       by 20 bits while sign-extending from bit 19 of the adder output.
  //       This case covers a curtailed 4-phase operation on 32x16 operands.
  //

// spyglass disable_block W164b
// SMD: Identifies assignments in which the LHS width is less than the RHS width
// SJ:  Intended as per the design. No possible loss of data
  mpy_acc_nxt  =
      (mp2_inst_en == 1)
    ? { 33'd0, mp1_src1}                            // case (a)
    : (  (phase_3 & mp2_mpy16_r)
        ? { {33{adder_sum[19] & mpy_x2_signed}},  // case (c)
            adder_sum[19:0],
            mp2_result_r[31:20]
          }
        : { adder_sum, mp2_result_r[31:4] }         // case (b)
      )
    ;
// spyglass enable_block W164b

  //////////////////////////////////////////////////////////////////////////
  // Detect when upper 32 bits of result are all ones or all zeros, as this
  // is useful in later detecting overflow.
  //
  hi_zero = (mp2_result_r[63:32] == `DATA_SIZE'd0);
  hi_ones = (mp2_result_r[63:32] == `DATA_SIZE'hffffffff);

end

// status of the multiplication/division operation
//
assign mp2_mpy_busy_nxt = (mp2_state_nxt != IDLE_STATE) &
                          (mp2_state_nxt != RESULT_STATE);
assign mp3_mpy_busy_r   = mp2_mpy_busy_r;

// Result of the multiplication/division operation at MP3
//
assign mp3_result_r = mp2_overflow_r ? (mpy_x2_rem_r & mpy_x2_src0_signed_r ? {32'h80000000, 33'b0}                     : {33'b0, 32'h80000000}) :
                      mp2_div_zero_r ? (mpy_x2_rem_r                        ? {32'hffffffff, mp2_result_r[64:32]}       : {mp2_result_r[64:32], 32'hffffffff}) :
                                       (mpy_x2_rem_r                        ? {mp2_result_r[31:0], mp2_result_r[64:32]} : mp2_result_r[64:0]);

//////////////////////////////////////////////////////////////////////////////
// Sequential block to define the multiplier FSM state variable             //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
    mp2_state_r <= IDLE_STATE;
  else if (mp2_state_en == 1'b1)
    mp2_state_r <= mp2_state_nxt;
end

//////////////////////////////////////////////////////////////////////////////
// Sequential block for the mp2-stage instruction, control and input data   //
//////////////////////////////////////////////////////////////////////////////

reg mpy_x1_signed;
assign mpy_x1_signed = mpy_x1_src0_signed | mpy_x1_src1_signed;

always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    mp2_mpy16_r     <= 1'b0;
    mp2_src2_r      <= 33'd0;
    mp2_sign1_r     <= 1'b0;
    mp2_div_zero_r  <= 1'b0;
    mp2_overflow_r  <= 1'b0;
  end
  else if (mp2_inst_en == 1'b1)
  begin
    mp2_mpy16_r     <= mp2_mpy16_nxt      & x1_pass_op;
    mp2_src2_r      <= mp2_src2_nxt;
    mp2_sign1_r     <= mp2_sign1_nxt;
    mp2_div_zero_r  <= div_init & (mp1_src2 == 32'd0);
    mp2_overflow_r  <= div_init
                     & mpy_x1_signed
                     & (mp1_src1 == 32'h80000000)
                     & (mp1_src2 == 32'hffffffff);
  end
end

//////////////////////////////////////////////////////////////////////////////
// Sequential blocks for mp2-stage accumulator and phase information        //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    mp2_result_r    <= 66'd0;
    mp2_phase_r     <= MPY_PHASE_0;
    mp2_mask_r      <= 32'd0;
    div_tini_r      <= 1'b0;
	mp2_mpy_busy_r  <= 1'b0;
  end
  else if (mp2_data_en == 1'b1)
  begin
    mp2_result_r    <= (mp2_start_mpy | mp2_valid_mpy)
                     ? mpy_acc_nxt
                     : {1'b0, div_acc_nxt};

    mp2_phase_r     <= mp2_phase_nxt;
    mp2_mask_r      <= mp2_mask_nxt;
    div_tini_r      <= div_tini_nxt;
	mp2_mpy_busy_r  <= mp2_mpy_busy_nxt;
  end
end



`undef MPY_PHASE_RANGE
`undef MPY_STATE_RANGE

`undef MPYHI_OPT

//////////////////////////////////////////////////////////////////////////////////////////
//
// Request the result bus when a mpy instruction is in X2 - Hold the request until we
// get the ack
//
//////////////////////////////////////////////////////////////////////////////////////////
reg mpy_x3_rb_req_nxt;
assign mpy_x3_rb_req_nxt =  1'b0
                         | (mpy_req_rb_nxt & |mpy_x2_dst_id_r)
                         | (mpy_x3_rb_req_r & ~x3_mpy_rb_ack);


// Clock-gate RB
//
reg mpy_x3_rb_req_cg0;
assign mpy_x3_rb_req_cg0 = 1'b0
                         | mpy_req_rb_nxt
                         | mpy_x3_rb_req_r
                        ;

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : mpy_x2_regs_PROC
  if (rst_a)
  begin
    mpy_x2_valid_r   <= 1'b0;
    mpy_x2_dst_id_r  <= 5'd0;
    mpy_x2_src0_signed_r  <= 1'b0;
    mpy_x2_src1_signed_r  <= 1'b0;
    mpy_x2_res_hi_r       <= 1'b0;
    mpy_x2_div_r     <= 1'b0;
    mpy_x2_rem_r     <= 1'b0;
  end
  else
  begin
    if (mpy_x2_ctl_cg0)
    begin
      mpy_x2_valid_r <= x1_pass & mpy_x1_valid;
      mpy_x2_div_r   <= x1_pass & mpy_x1_div;
    end

    if (mpy_x2_data_cg0)
    begin
      mpy_x2_dst_id_r      <= x1_dst_id;
      mpy_x2_src0_signed_r <= mpy_x1_src0_signed;
      mpy_x2_src1_signed_r <= mpy_x1_src1_signed;
      mpy_x2_res_hi_r      <= mpy_x1_res_hi;
      mpy_x2_rem_r         <= mpy_x1_rem;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : mpy_x3_regs_PROC
  if (rst_a)
  begin
    mpy_x3_valid_r  <= 1'b0;
    mpy_x3_res_hi_r <= 1'b0;
    mpy_x3_dst_id_r <= 5'd0;
  end
  else
  begin
    if (mpy_x3_ctl_cg0)
      mpy_x3_valid_r <= x2_pass & mpy_x2_valid;

    if (mpy_x3_data_cg0)
    begin
      mpy_x3_dst_id_r <= mpy_x2_dst_id_r;
      mpy_x3_res_hi_r <= mpy_x2_res_hi_r;
    end

  end
end

always @(posedge clk or posedge rst_a)
begin : mpy_x3_rb_regs_PROC
  if (rst_a)
  begin
    mpy_x3_rb_req_r   <= 1'b0;
  end
  else
  begin
    if (mpy_x3_rb_req_cg0)
    begin
      mpy_x3_rb_req_r   <= mpy_x3_rb_req_nxt;
    end
  end
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Output assignments
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
assign mpy_x1_ready = 1'b1
                    & (~mp3_mpy_busy_r)
                    & (~mpy_x3_stall_w);

assign mpy_x3_data = mpy_x3_res_hi_r
                   ? mp3_result_r[`DATA_SIZE +: `DATA_SIZE]
                   : mp3_result_r[         0 +: `DATA_SIZE];


endmodule // rl_mpy

