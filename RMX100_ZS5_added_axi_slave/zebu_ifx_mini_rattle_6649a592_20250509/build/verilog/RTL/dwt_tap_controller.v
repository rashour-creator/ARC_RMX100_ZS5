// Library ARC_Soc_Trace-1.0.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2013 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// Description:
//
// The Test Access Port (TAP) Controller is the master control module of
// the JTAG port. It has been designed according to the IEEE 1149.1 JTAG
// specification and allows the host device to communicate with all
// internal JTAG registers and initiate transaction protocols to the
// ARCv2HS CPU and its memory system. 
//
//======================= Inputs to this block =======================--
//
// jtag_tms             JTAG Test Mode Select. Controls state transitions
//                      in the TAP controller. From TMS at I/O pad ring
//
// jtag_tck             JTAG clock, from TCK at I/O pad ring
//
// jtag_trst_n  JTAG reset. Synchronized version of TRST*
//
//====================== Output from this block ======================--
//
// select_r             Signals whether access is to IR or DR
//
// jtag_tdo_zen_n       Enable for TDO at I/O pad ring
//
// test_logic_reset     TAP controller state decodes
//                      run_test_idle
//                      capture_dr
//                      shift_dr
//                      update_dr
//                      capture_ir
//                      shift_ir
//                      update_ir
//
// test_logic_reset_nxt TAP controller next state decodes
//                      run_test_idle_nxt
//                      select_dr_scan_nxt
//                      capture_dr_nxt
//                      update_dr_nxt
//
//====================================================================--
//
// leda W389 off
// LMD: Multiple clocks in the module
// LJ:  Two clocks used (jtag_tck and jtag_tck_inv); using inverted clock for
//      negedge clocking of shift reg/TDO output.
// spyglass disable_block W391
// SMD: Uses both edges of clock
// SJ:  Two clocks used (jtag_tck and jtag_tck_inv); using inverted clock for
//      negedge clocking of shift reg/TDO output.

module dwt_tap_controller(
  //  The controller interface signals
  //
  input           jtag_tck,
  input           jtag_tck_inv,
  input           jtag_trst_n,
  input           jtag_tms,
  output          select_r,
  output reg      jtag_tdo_zen_n,

  //  State control signals
  //
  output reg      test_logic_reset,
  output          run_test_idle,
  output          shift_ir,
  output          update_ir,
  output          shift_dr,
  output          capture_dr,
  output          capture_ir,
  output          update_dr,
  output          test_logic_reset_nxt,
  output          run_test_idle_nxt,
  output          select_dr_scan_nxt,
  output          capture_dr_nxt,
  output          update_dr_nxt
);
  
//  TAP Controller State Codes
//
//  The following enumerated types define all 16 states of the TAP
//  controller.  These states are used to communicate with the debug
//  port, a module that is responsible for communicating with the ARC and
//  local memory.
parameter  S_TEST_LOGIC_RESET   =   4'd0;  // TAP controller reset state
parameter  S_RUN_TEST_IDLE      =   4'd1;  // the transaction trigger state
parameter  S_SELECT_DR_SCAN     =   4'd2;  // select register type
parameter  S_CAPTURE_DR         =   4'd3;  // load selected register into shift reg
parameter  S_SHIFT_DR           =   4'd4;  // clock the data shift cell
parameter  S_EXIT1_DR           =   4'd5;  // exit state 1 for DR scan
parameter  S_PAUSE_DR           =   4'd6;  // pause state for data register
parameter  S_EXIT2_DR           =   4'd7;  // exit state 2 for DR scan
parameter  S_UPDATE_DR          =   4'd8;  // update state for the selected DR
parameter  S_SELECT_IR_SCAN     =   4'd9;  // select register type
parameter  S_CAPTURE_IR         =   4'd10; // load instruction data in shift cell
parameter  S_SHIFT_IR           =   4'd11; // clock the instruction shift cell
parameter  S_EXIT1_IR           =   4'd12; // exit state 1 for IR scan
parameter  S_PAUSE_IR           =   4'd13; // pause state for IR scan
parameter  S_EXIT2_IR           =   4'd14; // exit state 2 for IR scan
parameter  S_UPDATE_IR          =   4'd15; // update state for the IR

// spyglass disable_block Ac_conv04
// SMD: multiple bits of source bus i_tap_state_r not sync'd to dest bus db_cmd_r
// SJ:  CDC accross pseudo-bvci interface handled by protocol/clk ratio

// State Machine signal declarations
reg [3:0] i_tap_state_r;        // TAP controller state signal

// The test_logic_reset state ia registered to avoid the glitch that can
// result if we just decode it from i_tap_state_r
// spyglass disable_block Ac_coherency06
// SMD: signals that are synchronized multiple times in the same clock domain
// SJ:  CDC accross pseudo-bvci interface handled by protocol/clk ratio


always @(posedge jtag_tck or negedge jtag_trst_n)
begin : TEST_LOGIC_RESET_PROC
  if (jtag_trst_n == 1'b0)
    test_logic_reset  <= 1'b1;
  else
    test_logic_reset  <= test_logic_reset_nxt;
end

// spyglass enable_block Ac_coherency06
// Now handle the FSM itself
// spyglass disable_block STARC05-2.11.3.1
// SMD: Sequential and combination logic for FSM in same always block
// SJ:  Functionally works 
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : THE_TAP_CONTROLLER_PROC
        //  The Asynchronous Reset
        //
        if (jtag_trst_n == 1'b0)
                i_tap_state_r <= S_TEST_LOGIC_RESET;

        else
        case (i_tap_state_r)
        //  The Test-Logic-Reset State
        //
        //  The Test Logic Reset state is used to initialize all internal
        //  registers and external signals to inactive contents and logic levels
        //  respectively. This state is the only state steady for when TMS is
        //  HIGH. This means that you can be guaranteed to enter this state by
        //  driving TMS high and applying the minimum of five clock pulse on
        //  TCK. If TMS is zero on the rising edge of TCK the the RUN- TEST/IDLE
        //  state is entered.  evaluate TMS only on TCK
        S_TEST_LOGIC_RESET :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_RUN_TEST_IDLE;
        else
                i_tap_state_r <= S_TEST_LOGIC_RESET;

        //  The Run-Test/Idle State
        //
        //  The Run-Test/Idle state is used to place the JTAG module in an idle
        //  state or run an internal or external test. Providing that the
        //  Command register is set to a valid protocol value a transaction is
        //  triggered by entering this state.
        S_RUN_TEST_IDLE :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_RUN_TEST_IDLE;
        else
                i_tap_state_r <= S_SELECT_DR_SCAN;

        //  >>>>>>>>>>>>>>>>>>>>> DATA REGISTER STATE STRUCTURE <<<<<<<<<<<<<<<<
        //
        //  The Select-DR-Scan State
        //
        //  The Select-DR-State is used as gateway to access the selected data
        //  register.  This state has no other purpose.
        S_SELECT_DR_SCAN :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_CAPTURE_DR;
        else
                i_tap_state_r <= S_SELECT_IR_SCAN;

        //  The Capture-DR State
        //
        //  The Capture-DR state is used to capture the selected data
        //  register(selected by the value present in the Instruction Register)
        //  into the shift chain. The data is captured only when the state
        //  exited.
        S_CAPTURE_DR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_SHIFT_DR;
        else
                i_tap_state_r <= S_EXIT1_DR;

        //  The Shift-DR State
        //
        //  The Shift-DR state is a steady state for when TMS is low and is used
        //  to serially load in and out data to and from registers using the TDI
        //  and TDO signals. Data is sampled always on the rising edge of TCK.
        //  The data shifted out is placed on TDO at its falling edge.
        S_SHIFT_DR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_SHIFT_DR;
        else
                i_tap_state_r <= S_EXIT1_DR;

        //  The Exit1-DR State
        //
        //  The Exit1-DR state is entered when the selected data register has
        //  been accessed or the shift process must be suspended for number of
        //  TCK clock cycles (assuming a continuing frequency on TCK).
        S_EXIT1_DR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_PAUSE_DR;
        else
                i_tap_state_r <= S_UPDATE_DR;

        //  The Pause-DR State
        //
        //  The Pause-DR state is a steady state for when TMS is low and is
        //  entered when data cannot be supplied on TDI or received at TDO
        //  before next rising/falling edge of TCK. This state is general used
        //  for a when TCK is applied as a continuous frequency.
        S_PAUSE_DR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_PAUSE_DR;
        else
                i_tap_state_r <= S_EXIT2_DR;

        //  The Exit2-DR State
        //
        //  The Exit2-DR state is entered always from the PAUSE_DR state and can
        //  be used to re-enter the shifting phase or continue on to update the
        //  selected data register.
        S_EXIT2_DR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_SHIFT_DR;
        else
                i_tap_state_r <= S_UPDATE_DR;

        //  The Update-DR State
        //
        //  The Update-DR state is used to update the target register with the
        //  shifted in contents. The selected data register is updated on the
        //  falling edge of TCK as this state is entered.
        S_UPDATE_DR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_RUN_TEST_IDLE;
        else
                i_tap_state_r <= S_SELECT_DR_SCAN;

        //  >>>>>>>>>>>>>>>>>>>>> INSTRUCTION REGISTER STATE STRUCTURE <<<<<<<<<
        //
        //  The Select-IR-Scan State
        //
        //  The Select-IR-State is used as gateway to access the instruction
        //  register. This state has no other purpose.
        S_SELECT_IR_SCAN :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_CAPTURE_IR;
        else
                i_tap_state_r <= S_TEST_LOGIC_RESET;

        //  The Capture-IR State
        //
        //  The Capture-IR state is used to capture the instruction into its own
        //  shift chain.  The data is captured only when the state exited.
        S_CAPTURE_IR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_SHIFT_IR;
        else
                i_tap_state_r <= S_EXIT1_IR;

        //  The Shift-IR State
        //
        //  The Shift-IR state is a steady state for when TMS is low and is used
        //  to serially load in and out data to and from the instruction
        //  register using the TDI and TDO signals. Data is sampled always on
        //  the rising edge of TCK. The data shifted out is placed on TDO at its
        //  falling edge.
        S_SHIFT_IR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_SHIFT_IR;
        else
                i_tap_state_r <= S_EXIT1_IR;

        //  The Exit1-IR State
        //
        //  The Exit1-IR state is entered when the instruction register has been
        //  accessed or the shift process must be suspended for number of TCK
        //  clock cycles (assuming a continuing frequency on TCK).
        S_EXIT1_IR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_PAUSE_IR;
        else
                i_tap_state_r <= S_UPDATE_IR;

        //  The Pause-IR State
        //
        //  The Pause-IR state is a steady state for when TMS is low and is
        //  entered when data cannot be supplied on TDI or received at TDO
        //  before next rising/falling edge of TCK. This state is general used
        //  for a when TCK is applied as a continuous frequency.
        S_PAUSE_IR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_PAUSE_IR;
        else
                i_tap_state_r <= S_EXIT2_IR;

        //  The Exit2-IR State
        //
        //  The Exit2-DR state is entered always from the PAUSE_DR state and can
        //  be used to re-enter the shifting phase or continue on to update the
        //  instruction register.
        S_EXIT2_IR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_SHIFT_IR;
        else
                i_tap_state_r <= S_UPDATE_IR;

        //  The Update-IR State
        //
        //  The Update-DR state is used to update the instruction register with
        //  the shifted in contents. The instruction register is updated on the
        //  falling edge of TCK when this state is entered.
        S_UPDATE_IR :
        if (jtag_tms == 1'b0)
                i_tap_state_r <= S_RUN_TEST_IDLE;
        else
                i_tap_state_r <= S_SELECT_DR_SCAN;

        default :
        i_tap_state_r <= S_TEST_LOGIC_RESET;
        endcase
end
// spyglass enable_block Ac_conv04
// spyglass enable_block STARC05-2.11.3.1

//  The following logic is used to generate an enable signal that is wired
//  to a tri-state buffer, this enables the TDO output to go high
//  impedence when a JTAG register is not being accessed.  This signal is
//  active low enabled, hence the TDO pin should be 'Z' when it is '0'.
//  In accordance with the JTAG spec, the pin is enabled or disabled on
//  the falling edge of TCK.
//
// leda S_2C_R off
// LMD: Use rising edge flipflop
// LJ:  Using locally inverted clock (jtag_trst_n) for negedge except test mode
// leda B_1205 off
// LMD: The clock signal is not coming directly from a port of the current unit
// LJ:  Using locally inverted clock (jtag_trst_n) for negedge except test mode
//
always @(posedge jtag_tck_inv or negedge jtag_trst_n)
begin : JTAG_TDO_ZEN_N_PROC
        if (jtag_trst_n == 1'b0)
                jtag_tdo_zen_n <= 1'b0; //  Disable output on reset

        else
        if ((i_tap_state_r == S_SHIFT_IR) || (i_tap_state_r == S_SHIFT_DR))
                jtag_tdo_zen_n <= 1'b1; //  Enable during Shift-DR and Shift-IR
        else
                jtag_tdo_zen_n <= 1'b0; //  Disable otherwise
end
//
// leda S_2C_R on
// leda B_1205 on

//  The following two concurrent statements are used to generate a high
//  when the update_ir or update_dr state is entered. These signals are
//  the used as enables into d-type flip flops for updating the selected
//  data or instruction register on the falling edge of the jtag clock.
//
//  combinational logic
assign update_ir = ( i_tap_state_r == S_UPDATE_IR );
assign update_dr = ( i_tap_state_r == S_UPDATE_DR );

//  The select_r signal is used to control a mux that selects between the
//  internal data registers or the instruction register for the TDO output.
assign select_r = ( i_tap_state_r == S_CAPTURE_IR ) ||
                        ( i_tap_state_r == S_SHIFT_IR ) ||
                        ( i_tap_state_r == S_EXIT1_IR ) ||
                        ( i_tap_state_r == S_PAUSE_IR ) ||
                        ( i_tap_state_r == S_EXIT2_IR ) ||
                        ( i_tap_state_r == S_UPDATE_IR ) ? 1'b1 :
                        ( i_tap_state_r == S_CAPTURE_DR ) ||
                        ( i_tap_state_r == S_SHIFT_DR ) ||
                        ( i_tap_state_r == S_EXIT1_DR ) ||
                        ( i_tap_state_r == S_PAUSE_DR ) ||
                        ( i_tap_state_r == S_EXIT2_DR ) ||
                        ( i_tap_state_r == S_UPDATE_DR ) ? 1'b0 :
                        1'b0;

//  The following concurrent statements are state control signal that are
//  driven when the selected state has been entered. These signals are
//  used to capture data register contents into shift cells, reset
//  internal state machines, clock the shift cells and initiate
//  communication transactions.
//
//  combinatorial logic
assign capture_dr       = ( i_tap_state_r == S_CAPTURE_DR );
assign capture_ir       = ( i_tap_state_r == S_CAPTURE_IR );
assign run_test_idle    = ( i_tap_state_r == S_RUN_TEST_IDLE );
assign shift_ir         = ( i_tap_state_r == S_SHIFT_IR );
assign shift_dr         = ( i_tap_state_r == S_SHIFT_DR );

//  These signals are generated one JTAG clock earlier than the
//  equivalent states
assign run_test_idle_nxt = (( i_tap_state_r == S_TEST_LOGIC_RESET ) ||
                            ( i_tap_state_r == S_RUN_TEST_IDLE )   ||
                            ( i_tap_state_r == S_UPDATE_DR )       ||
                            ( i_tap_state_r == S_UPDATE_IR )) &&
                            ( jtag_tms == 1'b0 );

assign capture_dr_nxt   = ( i_tap_state_r == S_SELECT_DR_SCAN ) &&
                          ( jtag_tms == 1'b0 );

assign update_dr_nxt    = (( i_tap_state_r == S_EXIT1_DR )     ||
                           ( i_tap_state_r == S_EXIT2_DR )) &&
                           ( jtag_tms != 1'b0 );

assign test_logic_reset_nxt = (( i_tap_state_r == S_TEST_LOGIC_RESET ) ||
                               ( i_tap_state_r == S_SELECT_IR_SCAN )) &&
                               ( jtag_tms != 1'b0 );

assign select_dr_scan_nxt    = (( i_tap_state_r == S_RUN_TEST_IDLE )        ||
                                ( i_tap_state_r == S_UPDATE_DR )       ||
                                ( i_tap_state_r == S_UPDATE_IR )) &&
                                ( jtag_tms != 1'b0 );

// leda W389 on
// spyglass enable_block W391

endmodule // module dwt_tap_controller
