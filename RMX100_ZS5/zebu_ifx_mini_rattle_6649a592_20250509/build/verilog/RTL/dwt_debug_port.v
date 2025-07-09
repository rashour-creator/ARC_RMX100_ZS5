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
// Description:
//
// The JTAG Debug Port is the module that contains all the
// internal JTAG registers and performs the actual communication
// between the ARCv2HS and the host. Refer to the JTAG section in
// the ARC interface manual for an explanation on how to
// communicate with the complete module. In this revision, the
// debug port does not contain the address, data, command, or
// status registers.  These physically reside on the other side
// of a BVCI interface, and are read by the debug port during the
// Capture-DR state and written during the Update-DR state. A
// command is initiated during the Run-Test/Idle state by writing
// a do-command address over the BVCI interface, and the
// registers are reset during the Test-Logic-Reset state by
// writing a reset address.
//
//======================= Inputs to this block =======================--
//
// jtag_trst_n          The internal version of TRST*, conditioned to be
//                      asynchronously applied and synchronously released
//
// jtag_tck             The JTAG clock
//
// jtag_tdi             JTAG Test Data In, input to the data and instruction
//                      shift registers
//
// test_logic_reset     TAP controller state decodes
//                      run_test_idle
//                      capture_ir
//                      shift_ir
//                      update_ir
//                      capture_dr
//                      shift_dr
//
// select_r             Selects instruction or data shift register for TDO
//
// test_logic_reset_nxt TAP controller next state decodes
//                      run_test_idle_nxt
//                      select_dr_scan_nxt
//                      capture_dr_nxt
//                      update_dr_nxt
//
// dbg_rdata            Read data from the BVCI debug port
//
//====================== Output from this block ======================--
//
// bvci_addr_r          Variable part of BVCI address, to be synchronized with
//                      clk_main
//
// bvci_cmd_r           BVCI command, to be synchronized with clk_main
//
// dbg_be               BVCI Byte Enables. All bytes always enabled
//
// dbg_eop              BVCI End Of Packet. Always true; we only do one-word
//                      transfers
//
// dbg_rspack           BVCI Response Acknowledge. Always true.
//
// dbg_wdata            BVCI Write Data. Only changed on entry to Update-DR, do
//                      doesn't need to be synchronized
//
// do_bvci_cycle        Request to perform a transaction on the BVCI debug
//                      interface. Edge-signaling.
//
// jtag_tdo_r           JTAG Test Data Out. Output from shift registers
//
//====================================================================--
//
// leda W389 off
// LMD: Multiple clocks in the module
// LJ:  Two clocks used (jtag_tck and jtag_tck_inv); using inverted clock for
//      negedge clocking of shift reg/TDO output.
// spyglass disable_block W193
// SMD: empty statements
// SJ:  empty default statements kept and empty statements cause no problems
// spyglass disable_block W391
// SMD: Uses both edges of clock
// SJ:  Two clocks used (jtag_tck and jtag_tck_inv); using inverted clock for
//      negedge clocking of shift reg/TDO output.

// Configuration-dependent macro definitions
//
`include "dw_dbp_defines.v"

module dwt_debug_port(
// leda NTL_STR61 off
// LMD: Do not use clk/enable signals as data inputs
// LJ:  Locally inverted/muxed clock used for negedge FFs and test mode
  input                       jtag_tck,
  input                       jtag_tck_inv,
// leda NTL_STR61 on
  input                       jtag_trst_n,
  input                       jtag_tdi,
  output reg                  jtag_tdo_r,

  input        [31:0]         dbg_rdata_sync_tck,  // Read data
  input                       dbg_rspval_toggle_sync_tck,

  input                       test_logic_reset,
  input                       run_test_idle,
  input                       shift_ir,
  input                       update_dr,
  input                       update_ir,
  input                       shift_dr,
  input                       capture_dr,
  input                       capture_ir,

  input                       select_r,

  input                       test_logic_reset_nxt,
  input                       run_test_idle_nxt,
  input                       select_dr_scan_nxt,
  input                       capture_dr_nxt,
  input                       update_dr_nxt,

  output                      do_bvci_cycle,
  output                      do_transf,
  output reg   [32:0]         stg_addr,
  output reg   [32:0]         stg_data,
  output reg   [4:0]          stg_cmd,
  output reg   [32:0]         stg_select_in,
  input        [6:0]          transf_status,
  input                       transf_status_oksend_sync_tck,

  output reg   [31:0]         bvci_daddr_r,      // direct bvci access addresss
  output reg                  bvci_daddr_r_val,  //direct bvci access addresss valid

  output reg   [`DWT_V_DTI_ABITS-1:0] btx_addr_r,     // btx access addresss
  output reg                          btx_op_r_val,   // btx access addresss valid
  output reg                  bvci_daddr_btxop_r_val,  // toggle: da or btx access valid

  output reg   [5:2]          bvci_addr_r,    // Longword address, variable part
  output       [3:0]          dbg_be,         // Byte enables
  output       [1:0]          bvci_cmd,       // Command
  output                      dbg_eop,        // End-of-packet
  output                      dbg_rspack,     // Response acknowledge
  output       [31:0]         dbg_wdata       // Write data
);

reg [`JTAG_STATUS_MSB : 0] stg_status;
reg i_do_transf_r;
assign do_transf = i_do_transf_r;
reg [31:0] local_dbreg;
reg        local_dstatusreg;
reg [31:0] local_ddatareg;
reg [2:0]  local_dcmdreg;
reg  [`DWT_VSREG_SIZE-1:0]  v_shift_register_r;       // ARC V shift reg (used by DRs)
reg  [`DWT_VSREG_SIZE-1:0]  v_shift_register_r_msk;   // ARC V shift reg (used by DRs)
reg   [1:0]  btx_op_r;
reg  [31:0]  btx_data_r;
wire btx_execute;
wire btx_execute_wr;
wire btx_execute_rd;
assign btx_execute_wr = v_shift_register_r[0+:2] == `DWT_BTX_OP_WR;
assign btx_execute_rd = v_shift_register_r[0+:2] == `DWT_BTX_OP_RD;
assign btx_execute = btx_execute_wr || btx_execute_rd;
reg  rv_dmireset;
reg  dbg_btxcmd_busy;
reg  local_btxstatusreg;
reg [31:0] local_btxdatareg;
reg [1:0]  local_btxopreg;
reg  rv_dtmhardreset;
reg  [1:0] dmiop_result_sticky;
wire [1:0] cap_dmiop_result_sticky_ns;
wire current_dmi_errflag;
assign current_dmi_errflag = 1'b0;

reg  [1:0]  bvci_dcmd_r;
reg  [31:0] bvci_ddata_r;
reg  [1:0]  bvci_cmd_r;     // Command
reg  dbg_dcmd_busy;

//  Signal used to communicate with the BVCI cycle initiator.
reg             i_do_bvci_cycle_r;

//  The following signals are generated from D-type-flops with enables
//  and are used to hold the data register contents. The registers are
//  commonly referred to as shadow latches (IEEE Std 1149.1).
reg     [`DWT_SREG_SIZE-1:0]  shift_register_r;       // the shift reg (used by DRs)
reg     [4:0]   ir_latch_r;     // the instruction register
reg     [4:0]   ir_sreg_r;      // shift register for IR
reg             bypass_reg_r;   // bypass reg, a one bit reg
wire dmi_execute;
wire dmi_execute_wr;
wire dmi_execute_rd;
assign dmi_execute_wr = shift_register_r[0+:2] == `DWT_BTX_OP_WR;
assign dmi_execute_rd = shift_register_r[0+:2] == `DWT_BTX_OP_RD;
assign dmi_execute = dmi_execute_wr || dmi_execute_rd;

//  The following signals are used to connect to the TDO output. The TDO
//  output can be connected to two source outputs, the data registers or
//  the instruction register.
wire            tdo_src_dr;     // DRs muxed to TDO
wire            tdo_src_ir;     // IR muxed to TDO

//  The concurrent statement below is used to select the appropriate data
//  register output for the TDO signal. The signal inputs to this mux are
//  taken from the LSB of the shift register. Only one of LSB bits is
//  selected to the tdo_src_dr output dependent upon the value contained
//  in the instruction latch. The selected signal is then pass on into
//  the final mux, which determines what goes onto the TDO output pin.
//  As per the JTAG spec, all unused instructions select the bypass
//  register.
assign tdo_src_dr = ((ir_latch_r == `DWT_IR_STATUS) || (ir_latch_r == `DWT_IR_COMMAND) ||
                     (ir_latch_r == `DWT_IR_ADDRESS)|| (ir_latch_r == `DWT_IR_DATA) ||
                     (ir_latch_r == `DWT_IR_SELECT) ||
                     (ir_latch_r == `DWT_IR_RV_IDCODE) ||
                     (ir_latch_r == `DWT_IR_BTXCS)  || (ir_latch_r == `DWT_IR_BTX) ||
                     (ir_latch_r == `DWT_IR_RV_DTMCS) || (ir_latch_r == `DWT_IR_RV_DMI) || 
                     (ir_latch_r == `DWT_IR_DDATA)  || (ir_latch_r == `DWT_IR_DADDR) || (ir_latch_r == `DWT_IR_DSTATUS)) ? shift_register_r[0] :
                      bypass_reg_r;        // Covers ir_latch_r == `DWT_IR_BYPASS
                                           // and all other cases

//  the LSB of the instruction register is always selected for this source.
assign tdo_src_ir = ir_sreg_r[0];

//  The process statement below selects between the data or instruction
//  register to the main TDO output. The selection is made according to
//  the select_r signal that comes from the TAP controller. It indicates
//  what type of register is being accessed (if any). HIGH = instruction
//  register access, LOW = data register access. The TDO output always
//  changes on the falling edge of TCK.
//
// leda S_2C_R off
// LMD: Use rising edge flipflop
// LJ:  Using locally inverted clock (jtag_trst_n) for negedge except test mode
// leda B_1205 off
// LMD: The clock signal is not coming directly from a port of the current unit
// LJ:  Using locally inverted clock (jtag_trst_n) for negedge except test mode
// spyglass disable_block Reset_sync01 Reset_check07 Clock_check04
// SMD: Asynchronous reset signal that is not deasserted synchronously
// SJ:  jtag_trst_n must be synchronously deasserted
// SMD: Potential race between flop and it's clk
// SJ:  jtag_trst_n must be synchronously deasserted
// SMD: Recommended positive edge of clock not used
// SJ:  Using negedge of clock as required by IEEE spec
//
always @(posedge jtag_tck_inv or negedge jtag_trst_n)
begin : tdo_output_PROC
  if (jtag_trst_n == 1'b0)
    jtag_tdo_r <= 1'b0;

  else 
    if (test_logic_reset == 1'b1)
      jtag_tdo_r <= 1'b0;

    else if ((shift_dr == 1'b1) | (shift_ir == 1'b1))
      begin
        if (select_r == 1'b0)
          jtag_tdo_r <= tdo_src_dr;
        else
          jtag_tdo_r <= tdo_src_ir;
      end
end
//
// leda S_2C_R on
// leda B_1205 on
// spyglass enable_block Reset_sync01 Reset_check07 Clock_check04

//  The shift Data Register Cell
//
//  The shift data register is used to load and unload data from the
//  selected data register and serially shift data in from TDI and out
//  through TDO. Data is loaded into the shift cell when the capture_dr
//  state is entered and the instruction register contains a valid
//  instruction code.
//
// leda NTL_CLK05 off
// LMD: All asynchronous inputs to a clock system must be clocked twice.
// LJ:  dbg_rdata from bvci read port async but stable at sample

// leda B_1205 off
// LMD: The clock signal is not coming directly from a port of the current unit
// LJ:  Using locally inverted clock (jtag_trst_n) for posedge except test mode
// spyglass disable_block Clock_sync01 Clock_sync09 Ac_unsync02 Ac_conv04 Clock_check10 Ar_resetcross01
// SMD: unsynchronized clock domain crossings
// SJ:  CDC accross pseudo-bvci interface handled by protocol/clk ratio
// spyglass disable_block Ac_glitch03 Ac_glitch02
// SMD: crossing from source, may be subject to glitches 
// SJ:  crossings from clk to jtag_tck is acceptable as jtag_tck is slow compared to clk 
// spyglass disable_block Ac_glitch04
// SMD: Reconvergence without enable condition 
// SJ:  Reconvergence between jtag_tck_inv and jtag_tck is acceptable as they are in phase.
//      They are also inverted when test_mode=0 but logic was designed based on this 
//
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : dr_shift_reg_cell_PROC
  if (jtag_trst_n == 1'b0)
    shift_register_r <= { `DWT_SREG_SIZE { 1'b0 }};

  else 
    if ((test_logic_reset == 1'b1) || (rv_dtmhardreset))
      shift_register_r <= { `DWT_SREG_SIZE { 1'b0 }};

    else if (shift_dr == 1'b1)
      case (ir_latch_r)

        //  Command is 4 bits
        `DWT_IR_COMMAND :
        begin //  shift register one by one
            shift_register_r[0] <= shift_register_r[1];
            shift_register_r[1] <= shift_register_r[2];
            shift_register_r[2] <= shift_register_r[3];
          shift_register_r[`JTAG_CMD_MSB] <= jtag_tdi; // latch new data
        end

        // Status is 6 bits
        `DWT_IR_STATUS :
        begin //  shift register one by one
            shift_register_r[0] <= shift_register_r[1];
            shift_register_r[1] <= shift_register_r[2];
            shift_register_r[2] <= shift_register_r[3];
            shift_register_r[3] <= shift_register_r[4];
            shift_register_r[4] <= shift_register_r[5];
            shift_register_r[5] <= shift_register_r[6];
          shift_register_r[`JTAG_STATUS_MSB] <= jtag_tdi; // latch new data
        end

        // Direct Read Status is 4 bit
        `DWT_IR_DSTATUS :
        begin //  shift register one by one
            shift_register_r[0] <= shift_register_r[1];
            shift_register_r[1] <= shift_register_r[2];
            shift_register_r[2] <= shift_register_r[3];
          shift_register_r[`JTAG_DSTATUS_MSB] <= jtag_tdi; // latch new data
        end


        `DWT_IR_BTX :
        begin //  shift register one by one
          shift_register_r[0 +: 32+2] <= {jtag_tdi, shift_register_r[1 +:(32+2 - 1)]};
        end
        
        `DWT_IR_RV_DMI :
        begin //  shift register one by one
          shift_register_r[0 +: `DWT_SREG_SIZE] <= {jtag_tdi, shift_register_r[1 +:(`DWT_SREG_SIZE - 1)]};
        end
        default : //  All others are 32 bits
        begin //  shift register one by one
            shift_register_r[0] <= shift_register_r[1];
            shift_register_r[1] <= shift_register_r[2];
            shift_register_r[2] <= shift_register_r[3];
            shift_register_r[3] <= shift_register_r[4];
            shift_register_r[4] <= shift_register_r[5];
            shift_register_r[5] <= shift_register_r[6];
            shift_register_r[6] <= shift_register_r[7];
            shift_register_r[7] <= shift_register_r[8];
            shift_register_r[8] <= shift_register_r[9];
            shift_register_r[9] <= shift_register_r[10];
            shift_register_r[10] <= shift_register_r[11];
            shift_register_r[11] <= shift_register_r[12];
            shift_register_r[12] <= shift_register_r[13];
            shift_register_r[13] <= shift_register_r[14];
            shift_register_r[14] <= shift_register_r[15];
            shift_register_r[15] <= shift_register_r[16];
            shift_register_r[16] <= shift_register_r[17];
            shift_register_r[17] <= shift_register_r[18];
            shift_register_r[18] <= shift_register_r[19];
            shift_register_r[19] <= shift_register_r[20];
            shift_register_r[20] <= shift_register_r[21];
            shift_register_r[21] <= shift_register_r[22];
            shift_register_r[22] <= shift_register_r[23];
            shift_register_r[23] <= shift_register_r[24];
            shift_register_r[24] <= shift_register_r[25];
            shift_register_r[25] <= shift_register_r[26];
            shift_register_r[26] <= shift_register_r[27];
            shift_register_r[27] <= shift_register_r[28];
            shift_register_r[28] <= shift_register_r[29];
            shift_register_r[29] <= shift_register_r[30];
            shift_register_r[30] <= shift_register_r[31];
          shift_register_r[31] <= jtag_tdi; // latch new data
        end
    
      endcase

    else if (capture_dr == 1'b1)
      case (ir_latch_r)
        `DWT_IR_ADDRESS:
          shift_register_r[31:0] <= local_dbreg;

        `DWT_IR_DATA :
          shift_register_r[31:0] <= local_dbreg;

        `DWT_IR_SELECT :
          shift_register_r[31:0] <= local_dbreg;

        `DWT_IR_DDATA:
          shift_register_r[31:0] <= bvci_ddata_r;
    
        `DWT_IR_DADDR:
          shift_register_r[31:0] <= bvci_daddr_r;
    
        // Direct Read Status is 4 bit
        `DWT_IR_DSTATUS :
        begin
          shift_register_r[`JTAG_DSTATUS_MSB : 0] <= {local_dcmdreg,local_dstatusreg};
          shift_register_r[`DWT_SREG_MSB : `JTAG_DSTATUS_SIZE] <= { `DWT_SREG_SIZE - `JTAG_DSTATUS_SIZE { 1'b0 }}; // Zero upper bits
        end

        `DWT_IR_COMMAND :
        begin
          shift_register_r[`JTAG_CMD_MSB : 0] <=
            local_dbreg[`JTAG_CMD_MSB : 0];
          shift_register_r[`DWT_SREG_MSB : `JTAG_CMD_SIZE] <=
            { `DWT_SREG_SIZE - `JTAG_CMD_SIZE { 1'b0 }}; // Zero upper bits
        end
    
        `DWT_IR_STATUS :
        begin
          shift_register_r[`JTAG_STATUS_MSB : 0] <=
            local_dbreg[`JTAG_STATUS_MSB : 0];
          shift_register_r[`DWT_SREG_MSB : `JTAG_STATUS_SIZE] <=
            { `DWT_SREG_SIZE - `JTAG_STATUS_SIZE { 1'b0 }}; // Zero upper bits
        end
    
        // DTM Control and Status
        `DWT_IR_RV_DTMCS :
        begin //  shift register one by one
          shift_register_r[0 +: `JTAG_BTXCS_SIZE] <= {11'd0,
            3'b0,  //errinfo
            1'b0,  //dtmhardreset
            1'b0,  //dmireset
            `DWT_V_DTI_IDLE,  //idle
            dmiop_result_sticky,  //dmistat
            `DWT_V_ABITS_VECT, `DWT_DTMCS_VERSION}; // report alen
          shift_register_r[`DWT_SREG_MSB : `JTAG_BTXCS_SIZE] <=
            { `DWT_SREG_SIZE - `JTAG_BTXCS_SIZE { 1'b0 }}; // Zero upper bits
        end

        // Bus transfer Control and Status
        `DWT_IR_BTXCS :
        begin //  shift register one by one
          shift_register_r[0 +: `JTAG_BTXCS_SIZE] <= {11'd0,
            3'b0,  //errinfo
            1'b0,  //dtmhardreset
            1'b0,  //dmireset
            `DWT_V_DTI_IDLE,  //idle
            dmiop_result_sticky,  //dmistat
            `DWT_V_ABITS_VECT, `DWT_BTXCS_VERSION}; // report alen
          shift_register_r[`DWT_SREG_MSB : `JTAG_BTXCS_SIZE] <=
            { `DWT_SREG_SIZE - `JTAG_BTXCS_SIZE { 1'b0 }}; // Zero upper bits
        end

        // Bus transfer
        `DWT_IR_BTX:
        begin  //{
          if (dbg_btxcmd_busy || btx_op_r_val) begin  //{
            shift_register_r[0 +: 2]  <= local_btxstatusreg ? dmiop_result_sticky : local_btxopreg;
            if (local_btxopreg == `DWT_BTX_OP_RD) begin
             shift_register_r[2 +: 32] <= local_btxstatusreg ? dbg_rdata_sync_tck : local_btxdatareg;
            end
            shift_register_r[2+32 +: `DWT_V_DTI_ABITS ] <= btx_addr_r;
          end  //}
          else begin
             shift_register_r[0 +: 2]                   <= btx_op_r;
             shift_register_r[2 +: `DWT_V_DTI_ABITS]    <= btx_addr_r;
             shift_register_r[2+`DWT_V_DTI_ABITS +: 32] <= btx_data_r;
          end
        end  //}

        `DWT_IR_RV_DMI :
        begin  //{
          if (dbg_btxcmd_busy || btx_op_r_val) begin  //{
            shift_register_r[0 +: 2]  <= local_btxstatusreg ? dmiop_result_sticky : local_btxopreg;
            if (local_btxopreg == `DWT_BTX_OP_RD) begin
              shift_register_r[2 +: 32] <= local_btxstatusreg ? dbg_rdata_sync_tck : local_btxdatareg;
            end
            shift_register_r[2+32 +: `DWT_V_DTI_ABITS]  <= btx_addr_r;
          end  //}
          else begin
             shift_register_r[0 +: 2]  <= dmiop_result_sticky;
             shift_register_r[2 +: 32] <= btx_data_r;
          end
        end  //}
        `DWT_IR_RV_IDCODE :
          shift_register_r <= {`DWT_JTAG_VERSION, 16'h10,
                             `ARC_JEDEC_CODE, 1'b1}; //  load id register

        default :
          shift_register_r <= { `DWT_SREG_SIZE { 1'b0 }};

      endcase
end
//
// leda NTL_CLK05 on
// leda B_1205    on
// spyglass enable_block Clock_sync01 Clock_sync09 Ac_unsync02 Ac_conv04 Clock_check10 Ar_resetcross01
// spyglass enable_block Ac_glitch03 Ac_glitch02
// spyglass enable_block Ac_glitch04

//  The Shift Instruction Register Cell
//
//  The shift instruction register cell is used to shift the elements of the
//  instruction register.  The capture circuitry loads a 0001 pattern into the
//  instruction register every time the Capture-IR state is entered. This
//  allow the communicating device to detect faults along a 1149.1 bus.
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : IR_SHIFT_REG_CELL_PROC
  if (jtag_trst_n == 1'b0)
    ir_sreg_r <= 5'b0;

  else
    if (capture_ir == 1'b1)
      ir_sreg_r <= `DWT_IR_INIT; //  whenever we capture IR we must load a 01 into
                             //  the two LSBs. This aids in diagnosing
                             //  faults along the IEEE 1149.1-1990 bus

  else if (shift_ir == 1'b1)
  begin
    ir_sreg_r <= {jtag_tdi,ir_sreg_r[1 +:4]};       // latch new data in on TDI
  end
end

//  The following processes are used to load shifted data into instruction or
//  a selected data register. A D type flip flop with an enable is inferred
//  for all registers. The enable is asserted active on all data registers
//  only when the update_dr state is entered and the instruction latch
//  contains the selected data register code. The instruction register is
//  updated only when the update-ir state is entered. Note all registers are
//  updated on the falling edge of the TCK clock when in the update-ir/dr
//  state, except for the address, command, and data registers, which are
//  updated via a write over the BVCI interface.
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : BVCI_PROC
  if (jtag_trst_n == 1'b0)
  begin
    bvci_cmd_r  <= `BVCI_CMD_NOOP;
    bvci_addr_r <= `DWT_RESET_ADDR;
  end

  else //  Generate the BVCI address and command
    if (update_dr_nxt == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_SELECT : begin
          bvci_addr_r <= `DWT_SELECT_R_ADDR;
          bvci_cmd_r  <= `BVCI_CMD_WR;
          end
        default : begin
          bvci_addr_r <= `DWT_RESET_ADDR;
          bvci_cmd_r  <= `BVCI_CMD_NOOP;
          end
      endcase
    end

    else if (update_ir == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_STATUS : begin
          bvci_addr_r <= `DWT_STATUS_R_ADDR;
          bvci_cmd_r  <= `BVCI_CMD_RD;
          end
        default : begin
        end
      endcase
    end

    // The address must be presented for two clocks to allow the
    // returned read data to be synchronized before use, as it's
    // generated on the system clock.
    else if (capture_dr_nxt == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_SELECT : begin
          bvci_cmd_r  <= `BVCI_CMD_RD;
          bvci_addr_r <= `DWT_SELECT_R_ADDR;
          end
        default : begin
          bvci_cmd_r  <= `BVCI_CMD_NOOP;
          bvci_addr_r <= `DWT_RESET_ADDR;
          end
      endcase
    end
  
    else if ((test_logic_reset_nxt == 1'b1) || (rv_dtmhardreset))
    begin
      bvci_cmd_r  <= `BVCI_CMD_NOOP;
      bvci_addr_r <= `DWT_RESET_ADDR;
    end
  
    else
    begin
      bvci_cmd_r  <= `BVCI_CMD_NOOP;
    end
end

//  The v_shift Data Register Cell
//
//  The v_shift data register is used to load and unload data from the
//  selected data register and serially shift data in from TDI and out
//  through TDO. Data is loaded into the shift cell when the capture_dr
//  state is entered and the instruction register contains a valid
//  instruction code.
//
// leda NTL_CLK05 off
// LMD: All asynchronous inputs to a clock system must be clocked twice.
// LJ:  dbg_rdata from bvci read port async but stable at sample

// leda B_1205 off
// LMD: The clock signal is not coming directly from a port of the current unit
// LJ:  Using locally inverted clock (jtag_trst_n) for posedge except test mode
// spyglass disable_block Clock_sync01 Clock_sync09 Ac_unsync02 Ac_conv04 Clock_check10 Ar_resetcross01
// SMD: unsynchronized clock domain crossings
// SJ:  CDC accross pseudo-bvci interface handled by protocol/clk ratio
// spyglass disable_block Ac_glitch03 Ac_glitch02
// SMD: crossing from source, may be subject to glitches 
// SJ:  crossings from clk to jtag_tck is acceptable as jtag_tck is slow compared to clk 
// spyglass disable_block Ac_glitch04
// SMD: Reconvergence without enable condition 
// SJ:  Reconvergence between jtag_tck_inv and jtag_tck is acceptable as they are in phase.
//      They are also inverted when test_mode=0 but logic was designed based on this 
//
// spyglass disable_block Ac_coherency06
assign cap_dmiop_result_sticky_ns = (dmiop_result_sticky != `DWT_BTX_OP_RSP_PASS) ? dmiop_result_sticky :
                                    ~local_btxstatusreg ? `DWT_BTX_OP_RSP_BUSY :
                                    current_dmi_errflag ? `DWT_BTX_OP_RSP_FAIL : `DWT_BTX_OP_RSP_PASS;

always @(posedge jtag_tck or negedge jtag_trst_n)
begin : BTX_PROC
  if (jtag_trst_n == 1'b0)
  begin
    v_shift_register_r <= { `DWT_VSREG_SIZE { 1'b0 }};
    v_shift_register_r_msk <= {{ `DWT_VSREG_SIZE-1 { 1'b0 }},1'b1};
    btx_op_r     <= 2'b0;
    btx_op_r_val <= 1'b0;
    btx_addr_r   <= `DWT_V_DTI_ABITS'b0;
    btx_data_r   <= 32'b0;
    rv_dtmhardreset <= 1'b0;
    dmiop_result_sticky    <= `DWT_BTX_OP_RSP_PASS;
  end
    else if (shift_dr == 1'b1)
      case (ir_latch_r)
        `DWT_IR_BTX :
        begin //  shift register one by one
          v_shift_register_r_msk <= {v_shift_register_r_msk[0 +: `DWT_VSREG_SIZE-1], 1'b0};
          v_shift_register_r <= v_shift_register_r | ({`DWT_VSREG_SIZE{jtag_tdi}} & v_shift_register_r_msk); // latch new data
        end

        default : //  All others are 32 bits
        ;    
      endcase
    else if (capture_dr == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_BTX, `DWT_IR_RV_DMI:
        begin
            v_shift_register_r <= `DWT_VSREG_SIZE'b0;//dbg_rdata;
            btx_op_r_val <= 1'b0;
              //Do auto-increment addr here
            if (btx_op_r_val || dbg_btxcmd_busy) begin
              dmiop_result_sticky <= cap_dmiop_result_sticky_ns;
              if (dmiop_result_sticky == `DWT_BTX_OP_RSP_PASS) begin
                if (local_btxopreg == `DWT_BTX_OP_RD) begin
                  btx_data_r <= local_btxdatareg;
                end
            end
          end
        end
        default :
        begin
          v_shift_register_r <= { `DWT_VSREG_SIZE { 1'b0 }};
        end
      endcase
    end

    else if (update_dr_nxt == 1'b1)
    begin
      v_shift_register_r_msk <= {{ `DWT_VSREG_SIZE-1 { 1'b0 }},1'b1};
      case (ir_latch_r)
        `DWT_IR_BTX :  if (dmiop_result_sticky == `DWT_BTX_OP_RSP_PASS) begin
            if ((v_shift_register_r[0 +: 2] != 2'b00) && ((~dbg_rspval_toggle_sync_tck) && (btx_op_r_val || dbg_btxcmd_busy))) begin
              dmiop_result_sticky <= `DWT_BTX_OP_RSP_BUSY;
            end
            else begin
              btx_op_r   <= v_shift_register_r[0 +: 2];
              btx_op_r_val <= (v_shift_register_r[0 +: 2] != 2'b00);
              if ((v_shift_register_r[0+:2] == `DWT_BTX_OP_WR) || (v_shift_register_r[0+:2] == `DWT_BTX_OP_RD))
                btx_addr_r <= v_shift_register_r[2 +: `DWT_V_DTI_ABITS];
              if (v_shift_register_r[0+:2] == `DWT_BTX_OP_WR)
                btx_data_r <= v_shift_register_r[2+`DWT_V_DTI_ABITS +: 32];
            end
          end
        `DWT_IR_RV_DMI : if (dmiop_result_sticky == `DWT_BTX_OP_RSP_PASS) begin
            if ((shift_register_r[0 +: 2] != 2'b00) && ((~dbg_rspval_toggle_sync_tck) && (btx_op_r_val || dbg_btxcmd_busy))) begin
              dmiop_result_sticky <= `DWT_BTX_OP_RSP_BUSY;
            end
            else begin
              btx_op_r     <= shift_register_r[0 +: 2];
              btx_op_r_val <= (shift_register_r[0 +: 2] != 2'b00);
              btx_addr_r   <= shift_register_r[2+32 +: `DWT_V_DTI_ABITS];
              btx_data_r   <= shift_register_r[2 +: 32];
            end
          end
        default : begin
          btx_op_r_val <= 1'b0;
        end
      endcase
    end

    else if (update_dr == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_BTXCS, `DWT_IR_RV_DTMCS:
          begin
            if (shift_register_r[`DWT_V_DTMHARDRESET_LOC]) rv_dtmhardreset   <= 1'b1;
            if (shift_register_r[`DWT_V_DMIRESET_LOC]) dmiop_result_sticky   <= `DWT_BTX_OP_RSP_PASS;
          end
        default : begin
        end
      endcase
    end

    else if (run_test_idle_nxt == 1'b1)
    begin
        ;
    end
  
    else if ((test_logic_reset_nxt == 1'b1) || (rv_dtmhardreset))
    begin
      v_shift_register_r <= { `DWT_VSREG_SIZE { 1'b0 }};
      v_shift_register_r_msk <= {{ `DWT_VSREG_SIZE-1 { 1'b0 }},1'b1};
      btx_op_r    <= 2'b0;
      btx_op_r_val <= 1'b0;
      btx_addr_r  <= `DWT_V_DTI_ABITS'b0;
      btx_data_r  <= 32'b0;
      rv_dtmhardreset <= 1'b0;
      dmiop_result_sticky    <= `DWT_BTX_OP_RSP_PASS;
    end
end
// spyglass enable_block Ac_coherency06
// leda NTL_CLK05 on
// leda B_1205    on
// spyglass enable_block Clock_sync01 Clock_sync09 Ac_unsync02 Ac_conv04 Clock_check10 Ar_resetcross01
// spyglass enable_block Ac_glitch03 Ac_glitch02
// spyglass enable_block Ac_glitch04

always @(posedge jtag_tck or negedge jtag_trst_n)
begin : DIRECT_ADDR_DATA_PROC
  if (jtag_trst_n == 1'b0)
  begin
    bvci_daddr_r  <= 32'b0;
    bvci_ddata_r  <= 32'b0;
  end
  else
    if (capture_dr == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_DSTATUS : begin
            if (local_dstatusreg) begin
              bvci_daddr_r <= shift_register_r[`JTAG_DSTATUS_WIC] ? bvci_daddr_r + 32'h4 : bvci_daddr_r + 32'h1;
              bvci_ddata_r <= local_ddatareg;
            end
          end
        default : begin
        ;
        end
      endcase
    end

    else if (update_dr_nxt == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_DADDR : begin
           bvci_daddr_r <= shift_register_r[31:0];
         end
        `DWT_IR_DDATA : begin
           bvci_ddata_r <= shift_register_r[31:0];
         end
        default : begin
        ;
          end
      endcase
    end

    else if (run_test_idle_nxt == 1'b1)
    begin
        ;
    end
  
    else if ((test_logic_reset_nxt == 1'b1) || (rv_dtmhardreset))
    begin
          bvci_daddr_r  <= 32'b0;
          bvci_ddata_r  <= 32'b0;
    end
end

// spyglass disable_block Ac_coherency06
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : DCMD_DVAL_PROC
  if (jtag_trst_n == 1'b0)
  begin
    bvci_dcmd_r      <= 2'b0;
    bvci_daddr_r_val <= 1'b0;
  end

  else
    if (update_dr_nxt == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_DSTATUS : begin
          bvci_dcmd_r <= shift_register_r[2:1];
          bvci_daddr_r_val <= (shift_register_r[2:1] != 2'b00);
        end
        default : begin
          bvci_daddr_r_val <= 1'b0;
        end
      endcase
    end
    else if (capture_dr == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_DSTATUS : begin
           bvci_daddr_r_val <= 1'b0;
           end
        default : begin
        ;
        end
      endcase
    end
    else if ((test_logic_reset_nxt == 1'b1) || (rv_dtmhardreset))
      begin
        bvci_daddr_r_val <= 1'b0;
        bvci_dcmd_r <= 2'b10;
      end
end
// spyglass enable_block Ac_coherency06

always @(posedge jtag_tck or negedge jtag_trst_n)
begin : BVCI_DADDR_BTXOP_R_VALPROC
  if (jtag_trst_n == 1'b0)
  begin
    bvci_daddr_btxop_r_val <= 1'b0;
  end

  else
    if (update_dr_nxt == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_DSTATUS : begin
          bvci_daddr_btxop_r_val <= (shift_register_r[2:1] != 2'b00) ? ~bvci_daddr_btxop_r_val : bvci_daddr_btxop_r_val;
        end
        `DWT_IR_BTX : begin
            bvci_daddr_btxop_r_val <= (v_shift_register_r[0 +: 2] != 2'b00) ? ~bvci_daddr_btxop_r_val : bvci_daddr_btxop_r_val;
          end
        `DWT_IR_RV_DMI : begin
            bvci_daddr_btxop_r_val <= (shift_register_r[0 +: 2] != 2'b00) ? ~bvci_daddr_btxop_r_val : bvci_daddr_btxop_r_val;
          end
        default : begin
          ;
        end
      endcase
    end
end

always @(posedge jtag_tck or negedge jtag_trst_n)
begin : DCMDBTX_BUSY_PROC
  if (jtag_trst_n == 1'b0)
  begin
    dbg_dcmd_busy   <= 1'b0;
    dbg_btxcmd_busy   <= 1'b0;
  end
  else if (capture_dr == 1'b1)
    begin
      case (ir_latch_r)
        `DWT_IR_DSTATUS : begin //Sample and hold till
          dbg_dcmd_busy <= (~local_dstatusreg) && (bvci_daddr_r_val || dbg_dcmd_busy);
          end
        `DWT_IR_BTX, `DWT_IR_RV_DMI : begin //Sample and hold till
          dbg_btxcmd_busy <= (~local_btxstatusreg) && (btx_op_r_val || dbg_btxcmd_busy);
          end
        default : begin
        ;
        end
      endcase
    end
    else if ((test_logic_reset_nxt == 1'b1) || (rv_dtmhardreset))
  begin
      dbg_dcmd_busy <= 1'b0;
      dbg_btxcmd_busy <= 1'b0;
  end
end

assign dbg_wdata = {32{ ~test_logic_reset}} & (bvci_daddr_r_val ? bvci_ddata_r :
                                               btx_op_r_val     ? btx_data_r :
                                                                  shift_register_r[0 +: 32]);
assign bvci_cmd = bvci_daddr_r_val ? bvci_dcmd_r :
                  btx_op_r_val     ? btx_op_r :
                                     bvci_cmd_r;

//  These signals are fixed in this implementation
assign dbg_be     = 4'b1111; // We always write all the bytes
assign dbg_eop    = 1'b1;    // We only do one word
assign dbg_rspack = 1'b1;    // We always take the data in a cycle

//  This process manages the do_bvci_cycle flop, which is toggled to
//  request a BVCI cycle.
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : DO_BVCI_CMD_PROC
  if (jtag_trst_n == 1'b0) begin
    i_do_bvci_cycle_r <= 1'b0;
    stg_addr          <= 33'h0;
    stg_data          <= 33'h0;
    stg_cmd           <= 5'h0;
    stg_select_in     <= 33'h0;
    end
  else
    if (update_dr_nxt == 1'b1) // write addr, data or cmd
      case (ir_latch_r)
        `DWT_IR_ADDRESS:
          begin
            stg_addr <= {1'b1,shift_register_r[31:0]};
          end
        `DWT_IR_DATA:
          begin
            stg_data <= {1'b1,shift_register_r[31:0]};
          end
        `DWT_IR_COMMAND:
          begin
            stg_cmd <= {1'b1,shift_register_r[3:0]};
          end
        `DWT_IR_SELECT:
          begin
            stg_select_in <= {1'b0,shift_register_r[31:0]};
            i_do_bvci_cycle_r <= ~ i_do_bvci_cycle_r;
          end
        `DWT_IR_DSTATUS:
          if (shift_register_r[2:1] != 2'b00) i_do_bvci_cycle_r <= ~ i_do_bvci_cycle_r;
        `DWT_IR_BTX, `DWT_IR_RV_DMI :
          if (btx_execute || dmi_execute) i_do_bvci_cycle_r <= ~ i_do_bvci_cycle_r;
        default :
          ;
      endcase
    else if (transf_status_oksend_sync_tck) begin
            stg_addr[32] <= 1'b0;
            stg_data[32] <= 1'b0;
            stg_cmd[4]   <= 1'b0;
      end

end

// spyglass disable_block CDC_UNSYNC_NOSCHEME Ac_unsync01 Ac_unsync02 Ar_resetcross01
// SMD: Enable Criteria not satisfied, no valid qualifier
// SJ:  programming model allows data to settle before use.
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : STG_STATUS_PROC
  if (jtag_trst_n == 1'b0) begin
    stg_status        <= 7'h0;
  end
  else
    if (run_test_idle == 1'b1) begin //clear it
      stg_status   <= 7'b000_0001;
    end
    else if (transf_status_oksend_sync_tck) // sample and hold
    begin
      stg_status   <= transf_status[`JTAG_STATUS_MSB : 0];
    end

end

// spyglass disable_block Ac_conv01
// SMD: 2 synchronizers
// SJ:  FSM stages synchronized values of ok and status
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : SDS_LOCAL_PROC
  if (jtag_trst_n == 1'b0) begin
    local_dbreg     <= 32'b0;
    end
  else if (select_dr_scan_nxt == 1'b1)
    case (ir_latch_r)
      `DWT_IR_ADDRESS: local_dbreg[0+:32] <= stg_addr[0+:32];
      `DWT_IR_DATA   : local_dbreg[0+:32] <= dbg_rdata_sync_tck;
      `DWT_IR_COMMAND: local_dbreg[0+:4]  <= stg_cmd[`JTAG_CMD_MSB : 0];
      `DWT_IR_SELECT : local_dbreg[0+:32] <= dbg_rspval_toggle_sync_tck ? dbg_rdata_sync_tck : stg_select_in[0+:32];
      `DWT_IR_STATUS : local_dbreg[`JTAG_STATUS_MSB : 0] <= transf_status_oksend_sync_tck ? transf_status[`JTAG_STATUS_MSB : 0] : stg_status;
      default :
        ;
    endcase
end
// spyglass enable_block CDC_UNSYNC_NOSCHEME Ac_unsync01 Ac_unsync02 Ar_resetcross01 Ac_conv01

always @(posedge jtag_tck or negedge jtag_trst_n)
begin : SDS_DABTX_LOCAL_PROC
  if (jtag_trst_n == 1'b0) begin
    local_dstatusreg  <= 1'b0;
    local_ddatareg    <= 32'b0;
    local_dcmdreg     <= 3'b0;
    local_btxstatusreg  <= 1'b0;
    local_btxdatareg    <= 32'b0;
    local_btxopreg      <= 2'b0;
    end
  else begin
  if (dbg_rspval_toggle_sync_tck) begin
    if (dbg_dcmd_busy || bvci_daddr_r_val)
      begin
        local_dstatusreg <=  1'b1;
        local_ddatareg <= (local_dcmdreg[1:0] == 2'b01) ? dbg_rdata_sync_tck : bvci_ddata_r;
      end
    if (dbg_btxcmd_busy || btx_op_r_val)
      begin
        local_btxstatusreg <=  1'b1;
        local_btxdatareg <= (local_btxopreg[1:0] == `DWT_BTX_OP_RD) ? dbg_rdata_sync_tck : btx_data_r;
      end
  end
  else if (update_dr_nxt == 1'b1)
    case (ir_latch_r)
      `DWT_IR_DSTATUS :
        begin
          local_dcmdreg  <= dbg_dcmd_busy ? local_dcmdreg : shift_register_r[3:1];
          local_dstatusreg <= dbg_dcmd_busy ? local_dstatusreg : 1'b0;
        end
      `DWT_IR_BTX :
        begin
          local_btxopreg  <= dbg_btxcmd_busy ? local_btxopreg : v_shift_register_r[0 +: 2];
          local_btxstatusreg <= dbg_btxcmd_busy ? local_btxstatusreg : 1'b0;
        end
      `DWT_IR_RV_DMI :
        begin
          local_btxopreg  <= dbg_btxcmd_busy ? local_btxopreg : shift_register_r[0 +: 2];
          local_btxstatusreg <= dbg_btxcmd_busy ? local_btxstatusreg : 1'b0;
        end
      default :
        ;
    endcase
  end
end

always @(posedge jtag_tck or negedge jtag_trst_n)
begin : DO_TRANSF_PROC
  if (jtag_trst_n == 1'b0) begin
    i_do_transf_r     <= 1'b0;
    end
  else if ((run_test_idle_nxt == 1'b1) && (run_test_idle == 1'b0) && (stg_cmd[3:0] != `DWT_CMD_NOP))
    case (ir_latch_r)
      `DWT_IR_BYPASS, `DWT_IR_DADDR, `DWT_IR_DDATA, `DWT_IR_DSTATUS, `DWT_IR_SELECT,
      `DWT_IR_BTXCS, `DWT_IR_BTX,  `DWT_IR_RV_BYPASS, `DWT_IR_RV_DTMCS, `DWT_IR_RV_DMI, `DWT_IR_RV_IDCODE:
        ;
      default : begin
        i_do_transf_r <= ~i_do_transf_r;
      end
    endcase
end

assign do_bvci_cycle = i_do_bvci_cycle_r; //  Drive the output

//  Note that the instruction register, as required by the JTAG spec, updates
//  on the falling edge of JTAG clock.
//
// leda S_2C_R off
// LMD: Use rising edge flipflop
// LJ:  Using negedge of clock as required by IEEE spec
//
// spyglass disable_block Clock_check04
// SMD: Recommended positive edge of clock not used
// SJ:  Using negedge of clock as required by IEEE spec
always @(posedge jtag_tck_inv or negedge jtag_trst_n)
begin : THE_INSTRUCTION_REG_PROC
  if (jtag_trst_n == 1'b0)
    ir_latch_r <= `DWT_IR_RV_IDCODE;

  else
    if (test_logic_reset == 1'b1)
      ir_latch_r <= `DWT_IR_RV_IDCODE;

    else if (update_ir == 1'b1)
      ir_latch_r <= ir_sreg_r; //  update the instruction reg
end
//
// leda S_2C_R on
// spyglass enable_block Clock_check04

//  The following process defines the BYPASS register. The Bypass mode is set
//  when all ones have been written into instruction register or when the JTAG
//  port has be reset. The bypass register is set to zero on during
//  Capture-DR, and to TDI during Shift-DR, and is held in all other states,
//  as per the JTAG spec.
always @(posedge jtag_tck or negedge jtag_trst_n)
begin : BYPASS_BIT_PROC
  if (jtag_trst_n == 1'b0)
    bypass_reg_r <= 1'b0;

  else
    if (capture_dr == 1'b1)
      bypass_reg_r <= 1'b0;

    else if (shift_dr == 1'b1)
      bypass_reg_r <= jtag_tdi;
end


// leda W389 on
// spyglass enable_block W193
// spyglass enable_block W391

endmodule // module debug_port
