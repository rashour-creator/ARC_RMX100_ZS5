// Library ARCv5EM-3.5.999999999
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
`include "ifu_defines.v"
`include "dmp_defines.v"
`include "csr_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_debug (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                // clock signal
  input                          rst_a,              // reset signal

  input                          safety_iso_enb_synch_r,
  output [1:0]                   dr_safety_iso_err,

  ////////// Inputs from the Debug Target (CPU) ////////////////////////////
  //
  input                          cpu_db_ack,         // CPU acked debug request
  input       [`DATA_RANGE]      cpu_rdata,          // data returned by CPU
  input                          cpu_rd_err,
  input                          cpu_invalid_inst,   // illegal inst -> gfailure
  input                          cpu_db_done,        // debug instruction completed


  ////////// IBP debug interface //////////////////////////////////////////
  // Command channel
  input  						 dbg_ibp_cmd_valid,  // valid command
  input  						 dbg_ibp_cmd_read,   // read high, write low
  input       [`DBG_ADDR_RANGE]  dbg_ibp_cmd_addr,   // 
  output reg     				 dbg_ibp_cmd_accept, // 
  input  			[3:0]  	     dbg_ibp_cmd_space,  // type of access

  // read channel
  output               	         dbg_ibp_rd_valid,   // valid read
  input  				         dbg_ibp_rd_accept,  // rd output accepted by DM
  output      	   		         dbg_ibp_rd_err,     //
  output      [`DBG_DATA_RANGE]  dbg_ibp_rd_data,    // rd output

  // write channel
  input  						 dbg_ibp_wr_valid,   //
  output reg    			     dbg_ibp_wr_accept,  //
  input       [`DBG_DATA_RANGE]  dbg_ibp_wr_data,    // 
  input       [3:0] 	         dbg_ibp_wr_mask,    //
  output      					 dbg_ibp_wr_done,    //
  output      					 dbg_ibp_wr_err,     //
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                  dbg_ibp_wr_resp_accept,
  // spyglass enable_block W240
  
  ////////// Outputs to the Debug target (CPU) /////////////////////////////
  //
  output  reg                   db_request,          // request to issue |db_inst|
  output  reg                   db_valid,            // valid |db_inst| being issued
// @@@
// spyglass disable_block Ac_glitch02
// SMD: Clock domain crossing may be subject to glitches
// SJ: CDC accross is handled
  output  reg                   db_active,           // active |db_inst| in pipeline
// spyglass enable_block Ac_glitch02
  output  reg [`INST_RANGE]     db_inst,             // the debug instruction
  output      [`INST_RANGE]     db_limm,             // limm for debug instruction
  output      [`DATA_RANGE]     db_data,             // data for db_inst
  output [`DB_OP_RANGE]         db_op_1h,            // 0: reg file, 1: CSR, 2: memory
  output [4:0]                  db_reg_addr,         // register to be read
  input                         db_restart,          // what is this?


  //////////  clock control block //////////////////////////////////////////
  //
  output  reg                   db_clock_enable_nxt, // Clock needs to be enabled
  input                         ar_clock_enable_r    // Clock is enabled
);  

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Parameter definitions in the Debug module:                              //
//  There are three sets of local parameter definitions to guide the        //
//  behavior of the debug module, and one set of state definitions for the  //
//  debug instruction issue state machine.                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// Debug command codes
//
localparam DB_MEM_WR    = 4'h0;
localparam DB_CORE_WR   = 4'h1;
localparam DB_AUX_WR    = 4'h2;
localparam DB_RST_CMD   = 4'h3;
localparam DB_MEM_RD    = 4'h4;
localparam DB_CORE_RD   = 4'h5;
localparam DB_AUX_RD    = 4'h6;
//
// Combinations of debug command sub-fields indicating operation groups
//
localparam DB_MEM_OP    = 2'b00;    // match against db_cmd_r[1:0]
localparam DB_MEM_READ  = 3'b100;   // match against db_cmd_r[2:0]
localparam DB_MEM_WRITE = 3'b000;   // match against db_cmd_r[2:0]

// Addresses on the BVCI debug bus
//
localparam DB_SPACE     = 24'hffff00;
localparam DB_STAT      = 8'h00;
localparam DB_CMD       = 8'h04;
localparam DB_ADDR      = 8'h08;
localparam DB_DATA      = 8'h0c;


localparam  ACC_MEM   = 4'h0;
localparam	ACC_CSR   = 4'h1;
localparam	ACC_GPR   = 4'h2;
localparam	ACC_FPR   = 4'h3;
localparam	ACC_NSINT = 4'h4;
localparam	ACC_ICSR  = 4'h5;
localparam	ACC_AUX   = 4'hf;

// ===========================================================================
// Pseudo-debug instructions issued by the debug unit to the CPU
// ===========================================================================
// Command    Instruction       Instruction Encoding              Hex Pattern
// ---------------------------------------------------------------------------
// DB_MEM_RD   LW    limm,(limm) 00000000000000000010000000000011 00002003
// DB_MEM_WR   SW    limm,(limm) 00000000000000000010000000100011 00002023
// DB_AUX_RD   CSRRS X0,X0,C     cccccccccccc00000010000001110011 00002073 +C
// DB_AUX_WR   CSRRW X0,limm,C   cccccccccccc00000001000001110011 00001073 +C
// DB_CORE_RD  ORI   X0,Xn,0     000000000000nnnnn110000000010011 00006013 +N
// DB_CORE_WR  ORI   Xn,X0,limm  00000000000000000110nnnnn0010011 00006013 +N
//
// Notes:
//   1. Memory addresses for load and store operations are provided by db_addr
//   2. Store data is provided by db_data, via the non-architectural LIMM
//      operand value 
//   3. CSR write data is provided by db_data, via the non-architectural LIMM
//      operand value 
//   4. Register write data is provided by db_data, via the non-architectural LIMM
//      operand value 
//   5. The CSR register selected by CSR read/write operations is inserted
//      into db_inst[31:20].
// ===========================================================================
//
// Debug instruction encodings
//
localparam INST_NOP       = 32'h00000013;
localparam INST_MEM_RD32  = 32'h00002003;
localparam INST_MEM_WR32  = 32'h00002023;
localparam INST_MEM_RD64  = 32'h00003003;   // RV64I only
localparam INST_MEM_WR64  = 32'h00003023;   // RV64I only
localparam INST_AUX_RD    = 32'h00002073;
localparam INST_AUX_WR    = 32'h00001073;
localparam INST_CORE_RD   = 32'h00004013;
localparam INST_CORE_WR   = 32'h00004013;
localparam INST_MEM_RD32_B   = 32'h00004003;
localparam INST_MEM_RD32_HW  = 32'h00005003;
localparam INST_MEM_WR32_B   = 32'h00000023;
localparam INST_MEM_WR32_HW  = 32'h00001023;

// States of the debug instruction issue and execution FSM
//
localparam DB_FSM_IDLE    = 3'd0;
localparam DB_FSM_AIM     = 3'd1;
localparam DB_FSM_FIRE    = 3'd2;
localparam DB_FSM_LIMM    = 3'd3;
localparam DB_FSM_RELOAD  = 3'd4;
localparam DB_FSM_END     = 3'd5;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Registered state                                                       //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
reg   [3:0]                 db_cmd_r;         // Debug Command Register
reg   [`ADDR_RANGE]         db_addr_r;        // Debug Address Register
reg   [`DATA_RANGE]         db_data_r;        // Debug Data Register
reg                         db_ready_r;       // 0=>executing; 1=>ready
reg                         db_failed_r;      // 1=>op.failed; 0=>op.ok
reg                         db_failed_sticky;      // 1=>op.failed; 0=>op.ok
reg                         reset_done_r;     // global reset deasserted
// @@@
// spyglass disable_block Ac_glitch02
// SMD: Clock domain crossing may be subject to glitches
// SJ: CDC accross is handled
reg   [2:0]                 db_fsm_r;         // execution FSM state var.
// spyglass enable_block Ac_glitch02
reg                         db_any_err;       // 1 if any debug error set



reg   [3:0]                 dbg_cmd_r;
reg   [`DATA_RANGE]         dbg_addr_r;
reg   [`DATA_RANGE]         dbg_data_r;
reg                         dbg_ibp_wr_valid_r;
reg                         dbg_ibp_cmd_valid_r;
reg                         dbg_ibp_cmd_read_r;
reg   [3:0]                 dbg_ibp_wr_mask_r;
reg   [`DATA_RANGE]         dbg_ibp_rd_data_r;
reg                         dbg_done_r;
reg                         dbg_done_delay_r;
reg   [`DATA_RANGE]         dbg_addr_nxt;
reg   [`DATA_RANGE]         dbg_data_nxt;
wire  [`DATA_RANGE]         dbg_addr_plus_stp;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Local reg and wire signals                                             //
//                                                                        //
////////////////////////////////////////////////////////////////////////////


reg                         db_addr_incr;     // Incr.debug register
wire  [`DATA_RANGE]         db_addr_plus_stp; // Debug addr reg + 4 or + 1
wire                        unused_cout;      // Unused carry out of incr op

reg   [`DATA_RANGE]         db_addr_nxt;      // Debug Address next value
reg   [`DATA_RANGE]         db_data_nxt;      // Debug Data next value
reg   [3:0]                 db_cmd_nxt;       // Debug Command next value
reg                         db_ready_nxt;     // Next value for db_ready_r
reg                         db_failed_nxt;    // Next value for db_failed_r
reg   [2:0]                 db_fsm_nxt;       // next FSM state value

reg                         db_addr_enb;      // enable Debug Address write
reg                         db_data_enb;      // enable Debug Data write
reg                         db_cmd_enb;       // enable Debug Command write
reg                         db_ready_enb;     // enable for db_ready_r
reg                         db_failed_enb;    // enable for db_failed_r

reg                         reset_db;         // 1=>apply reset command
reg                         db_space_sel;     // 1 if address match
reg                         db_addr_match;    // 1 if no address match

reg                         bvci_read;        // 1 if BVCI cmd == read
reg                         bvci_write;       // 1 if BVCI cmd == write

reg                         read_status32;    // internal read of status32
reg                         is_internal_op;   // any internal op is decoded
wire                        read_csr_status32;
wire                        read_csr_3e;
wire                        write_csr_3e;
reg [1:0]                   dbg_ibp_safety_err;

reg                         do_command;       // DB_EXEC was written
reg                         do_execute;       // execute debug insn when ready
reg                         do_internal;      // perform an internal operation


wire dbg_mem_rd = (dbg_cmd_r == ACC_MEM) & dbg_ibp_cmd_read_r;
wire dbg_mem_wr = (dbg_cmd_r == ACC_MEM) & !dbg_ibp_cmd_read_r;
wire dbg_gpr_rd = (dbg_cmd_r == ACC_GPR) & dbg_ibp_cmd_read_r;
wire dbg_gpr_wr = (dbg_cmd_r == ACC_GPR) & !dbg_ibp_cmd_read_r; 
wire dbg_aux_rd = (dbg_cmd_r == ACC_AUX) & dbg_ibp_cmd_read_r;
wire dbg_aux_wr = (dbg_cmd_r == ACC_AUX) & !dbg_ibp_cmd_read_r;
wire dbg_csr_rd = (dbg_cmd_r == ACC_CSR) & dbg_ibp_cmd_read_r;
wire dbg_csr_wr = (dbg_cmd_r == ACC_CSR) & !dbg_ibp_cmd_read_r; 

wire dbg_mem_op = dbg_cmd_r == ACC_MEM;
wire dbg_rd_op  = dbg_ibp_cmd_read_r;
wire dbg_wr_op  = !dbg_ibp_cmd_read_r;




// Compute db_addr_r + 1 (regs), or + 4 (mem) , for incrementing addresses
//
assign { unused_cout, dbg_addr_plus_stp} = dbg_addr_r +
          (dbg_mem_op ? (0 ? 8 : 4) : 1);


always @*
begin : db_next_PROC

  // Detect the reset command in DB_CMD
  //
  reset_db       = 1'b0; 

  dbg_data_nxt   = reset_db
                 ? `DBG_DATA_WIDTH'd0
                 : cpu_rdata;

  db_failed_nxt  = cpu_invalid_inst | cpu_rd_err;
  db_ready_nxt   = (db_fsm_r == DB_FSM_IDLE);
  db_failed_enb  = ((db_fsm_r == DB_FSM_RELOAD) & cpu_db_done);
  db_data_enb    = ((db_fsm_r == DB_FSM_RELOAD) & cpu_db_done);

  // Set default values
  //
  do_execute     = 1'b0
                  | ( dbg_ibp_cmd_valid_r                            // valid cmd signal seen
                    & ((dbg_ibp_wr_valid_r & dbg_wr_op) | dbg_rd_op) // wr_valid signal seen for write op or not needed for read op
                    & db_ready_nxt                               // debug FSM in idle state ready to execute debug op
                    & (~reset_db))
                 ;

// spyglass disable_block CDC_COHERENCY_RECONV_SEQ CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals
  dbg_ibp_cmd_accept = dbg_ibp_cmd_valid
                       & (db_ready_nxt | read_csr_status32 | read_csr_3e | write_csr_3e) // CSR Status32 and reg 3E Read is internal op
                       & ar_clock_enable_r
                       & reset_done_r
                       ;
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ

  dbg_ibp_wr_accept  = dbg_ibp_wr_valid
                       & (db_ready_nxt | write_csr_3e) // Write to register 3E is internal op
                       & ar_clock_enable_r
                       & reset_done_r
                       ;

end

reg   [`INST_RANGE]  rd_reg_opd_ibp;
reg   [`INST_RANGE]  rs1_reg_opd_ibp;
reg   [`INST_RANGE]  csr_opd_ibp;
reg   [`INST_RANGE]  instr_ibp;

always @*
begin : dbg_ibp_inst_PROC

  // Encode the register operand from db_addr_r[5:0] according to the
  // rd and rs1 field syntax, as used by the ORI instruction.
  // For GPR access
  rd_reg_opd_ibp  = { 20'd0, dbg_addr_r[4:0],  7'd0 };
  rs1_reg_opd_ibp = { 12'd0, dbg_addr_r[4:0], 15'd0 };

  // Reg address comes starting at 0x0 so depending on type of reg
  // access we need to pad appropriately
  // Place the CSR address in csr_opd
  //
  csr_opd_ibp   = {dbg_addr_r[11:0], 20'd0 };

//  fpr_opd_ibp   = {7'h81, dbg_ibp_cmd_addr[4:0], 20'd0 };

//  nsint_opd_ibp  = {dbg_ibp_cmd_addr[11:0], 20'd0 };
  // Select the required instruction 
  //
  case ( dbg_cmd_r )
    ACC_MEM:      
              begin
                if (dbg_ibp_cmd_read_r)
                begin
                  instr_ibp = INST_MEM_RD32;
                  casez (dbg_addr_r[1:0])
                  2'b01: instr_ibp   = INST_MEM_RD32_B;
                  2'b11: instr_ibp   = INST_MEM_RD32_B;
                  2'b10: instr_ibp   = INST_MEM_RD32_HW;
                  2'b00: instr_ibp   = INST_MEM_RD32; 
                  // spyglass disable_block W193
                  // SMD: empty statement
                  // SJ:  empty defaults kept
                  default: ;
                  // spyglass enable_block W193
                  endcase
                end
                else
                begin
                  instr_ibp = INST_MEM_WR32;
                  casez (dbg_ibp_wr_mask_r)
                  4'b1zzz: instr_ibp = INST_MEM_WR32;
                  4'b0z1z: instr_ibp = INST_MEM_WR32_HW;
                  4'b0z01: instr_ibp = INST_MEM_WR32_B;
                  // spyglass disable_block W193
                  // SMD: empty statement
                  // SJ:  empty defaults kept
                  default: ;
                  // spyglass enable_block W193
                  endcase
                end
              end
    ACC_CSR:
              begin
                if (dbg_ibp_cmd_read_r)
                  instr_ibp = INST_AUX_RD  | csr_opd_ibp;
                else
                  instr_ibp = INST_AUX_WR  | csr_opd_ibp;
              end
    ACC_GPR:
              begin
                if (dbg_ibp_cmd_read_r)
                  instr_ibp = INST_CORE_RD | rs1_reg_opd_ibp;
                else
                  instr_ibp = INST_CORE_WR | rd_reg_opd_ibp;
              end
    ACC_AUX:
              begin
                if (dbg_ibp_cmd_read_r)
                  instr_ibp = INST_AUX_RD  | csr_opd_ibp;
                else
                  instr_ibp = INST_AUX_WR  | csr_opd_ibp;
              end
    default:      instr_ibp = INST_NOP;
  endcase
end


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous process to define the debug execution FSM, which issues   //
// debug instructions into the processor pipeline.                        //
//                                                                        //
// There are five states in this FSM. The reset state is DB_FSM_IDLE.     //
//                                                                        //
//  DB_FSM_IDLE   : In this state the instruction-issue FSM for the debug //
//                  unit is idle. The CPU is free to fetch and execute    //
//                  its own instructions according to normal operation.   //
//                  It remains in this state until the do_execute signal  //
//                  is asserted, when it moves into the  DB_FSM_AIM state //
//                                                                        //
//  DB_FSM_AIM    : In this state the db_request signal is asserted, and  //
//                  this causes the CPU to respond by flushing the        //
//                  pipeline. The state-machine detects this by           //
//                  monitoring the cpu_db_ack signal. When asserted, it   
//                  moves into the DB_FSM_FIRE state to issue the debug   //
//                  instruction.                                          //
//                                                                        //
//  DB_FSM_FIRE   : In this state the db_valid and the db_active  signals
//                   are asserted. The db_valid signal    
//                  tells the Fetch stage to accept db_inst as the next   //
//                  instruction to be issued. The  The db_active   
//                  signal indicates to all pipeline stages that any      //
//                  valid instruction they see must be treated as a debug //
//                  instruction.                                          //
//                                                                        //
//  DB_FSM_LIMM   : In this state the db_valid, the db_active, signals are 
//                  asserted, and the LIMM operand  
//                  for the debug instruction is output on the db_inst    //
//                  signals.                                              //
//                  The pipeline will accept db_inst as the LIMM data     //
//                  for the debug instruction during this cycle.          //
//                                                                        //
//  DB_FSM_RELOAD : In this state the db_active  signal    
//                  continue to be asserted, thereby keeping the pipeline //
//                  free of other instructions until the debug            //
//                  instruction is finished.                              //
//                  The FSM remains in this state until the wa_commit_dbg //
//                  signal is asserted, indicating that the current debug //
//                  instruction is in the final (writeback) stage.        //
//                  On exit from this state, the db_data_r register is    //
//                  updated with either wa_rf_wdata0 or wa_rf_wdata1,     //
//                  depending on the type of instruction (load vs mov/lr) //
//                  and the FSM moves to the DB_FSM_END state.            //
//                  When performing a Store instruction, to write to      //
//                  memory, the db_data value must be forced onto the     //
//                  store_opd wires in the operands module. This is       //
//                  achieved by asserting db_sel_limm1. A similar thing   //
//                  happens for SR instructions, to write to aux          //
//                  registers, in which case the db_sel_limm0 signals is  //
//                  asserted to force db_data into opd1_early and thence  //
//                  to opd_1 (in the operands module).                    //
//                                                                        //
//  DB_FSM_END    : In this state the db_active signal remains asserted,  //
//                  to prevent unwanted state updates in the writeback    //
//                  stage, and the db_request signal is asserted for one  //
//                  cycle to restart the pipeline from the correct PC.    //
//                  The db_fetch signal is de-asserted to allow the Fetch //
//                  stage to begin fetching on the next cycle from the    //
//                  restart PC address.                                   //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

reg   [`INST_RANGE]  issue_word;

always @*
begin : db_fsm_PROC

  issue_word   = instr_ibp;
  db_addr_incr = 1'b0;
  db_active    = 1'b0;
  db_request   = 1'b0;
  db_valid     = 1'b0;
  
  db_fsm_nxt   = db_fsm_r;    // remain in current state by default

  case ( db_fsm_r )
    DB_FSM_IDLE:
    begin
      if (  do_execute == 1'b1
          )
      begin
        db_fsm_nxt = DB_FSM_AIM;
      end          
    end

    DB_FSM_AIM:
    begin
      db_request = 1'b1;  // request a pipeline flush prior to debug insn
      
      if (cpu_db_ack == 1'b1)
        db_fsm_nxt = DB_FSM_FIRE;
    end

    DB_FSM_FIRE:
    begin
      db_valid   = 1'b1;  // validate debug inst and limm to Fetch stage
      db_active  = 1'b1;  // inform pipeline that debug is active
      db_fsm_nxt = DB_FSM_LIMM;
    end

    DB_FSM_LIMM:
    begin
      // Select db_data_r or db_addr_r as LIMM value to be issued
      // for current debug instruction, depending on the command.
      // All commands except DB_CORE_WR use db_addr_r as their LIMM
      // value. DB_CORE_WR uses db_data_r as the LIMM value.
      //
      db_active  = 1'b1;  // inform pipeline that debug is active
      db_fsm_nxt = DB_FSM_RELOAD;
    end

    DB_FSM_RELOAD:
    begin
      db_active    = 1'b1;  // inform pipeline that debug is active

      if (cpu_db_done == 1'b1) // hlt_debug_evt @@@
        db_fsm_nxt = DB_FSM_END;
      else if (db_restart == 1'b1)
        db_fsm_nxt = DB_FSM_FIRE;

        // Process db_next_PROC detects wa_commit in this state and uses
        // it to enable the update of db_data_r with the result value.
    end

    DB_FSM_END:
    begin
      db_addr_incr = 1'b1;  // increment addr for all ops
      db_active    = 1'b1;
      db_fsm_nxt   = DB_FSM_IDLE;
    end
    default:
      db_fsm_nxt   = db_fsm_r;    // remain in current state by default

  endcase

  // Assign db_inst to be the middle-endian version of issue_word
  //
  db_inst = issue_word;
end


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Aynchronous processes to define clock enable output                    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
always @*
begin : clock_enable_PROC
  db_clock_enable_nxt = dbg_ibp_cmd_valid
                      | (db_fsm_r != DB_FSM_IDLE)
                      | dbg_ibp_cmd_valid_r
                      ;
end

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Synchronous processes to define each of the Debug registers            //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

// -- the debug command register DB_CMD


always @(posedge clk or posedge rst_a)
begin : db_failed_PROC
  if (rst_a == 1'b1)
    db_failed_r  <=  1'b0;
  else if (db_fsm_r == DB_FSM_IDLE)
    db_failed_r  <= 1'b0;
  else if (db_failed_enb == 1'b1)
    db_failed_r  <=  db_failed_nxt;
end



always @(posedge clk or posedge rst_a)
begin : reset_done_PROC
  if (rst_a == 1'b1)
    reset_done_r  <=  1'b0;
  else
    reset_done_r  <=  1'b1;
end

// -- the debug execution state variable

always @(posedge clk or posedge rst_a)
begin : db_state_PROC
  if (rst_a == 1'b1)
    begin
    db_fsm_r      <=  3'd0;
    end
  else
    begin
    db_fsm_r      <=  db_fsm_nxt;
    end
end


// register dbg_ibp_cmd_space
always @(posedge clk or posedge rst_a)
begin : dbg_cmd_ibp_PROC
  if (rst_a == 1'b1)
    dbg_cmd_r  <=  DB_RST_CMD;
  else if (dbg_ibp_cmd_valid)
    dbg_cmd_r  <=  dbg_ibp_cmd_space;
end

// register dbg_ibp_cmd_addr
always @(posedge clk or posedge rst_a)
begin : dbg_addr_ibp_PROC
  if (rst_a == 1'b1)
  begin
    dbg_addr_r  <=  `DATA_SIZE'd0;
  end
  else
  begin
    if (dbg_ibp_cmd_valid)
    begin
      dbg_addr_r  <=  dbg_ibp_cmd_addr;
    end
    else if (db_addr_incr)
    begin
      dbg_addr_r  <= dbg_addr_plus_stp;
    end
  end
end

// dbg_data_r is for wr data for inst to core
// spyglass disable_block Ac_conv01
// SMD: Reports signals from the same domain that are synchronized in the same destination domain and converge after any number of sequential elements
// SJ:  Async signals are defined on virtual clocks (not the same clock). Intended
always @(posedge clk or posedge rst_a)
begin : dbg_data_ibp_PROC
  if (rst_a == 1'b1)
    dbg_data_r  <=  `DATA_SIZE'd0;
  else if (dbg_ibp_wr_valid & db_ready_nxt)
    dbg_data_r  <=  { ({8{dbg_ibp_wr_mask[3]}} & dbg_ibp_wr_data[31:24]),
                      ({8{dbg_ibp_wr_mask[2]}} & dbg_ibp_wr_data[23:16]),
                      ({8{dbg_ibp_wr_mask[1]}} & dbg_ibp_wr_data[15:8]),
                      ({8{dbg_ibp_wr_mask[0]}} & dbg_ibp_wr_data[7:0])
                    };
end
// spyglass enable_block Ac_conv01

// register dbg_ibp_wr_valid
// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals  
always @(posedge clk or posedge rst_a)
begin : dbg_ibp_wr_valid_ibp_PROC
  if (rst_a == 1'b1)
    dbg_ibp_wr_valid_r <=  1'b0;
  else if (read_csr_status32 | read_csr_3e | write_csr_3e)
    dbg_ibp_wr_valid_r <=  1'b0;
  else if ((dbg_ibp_wr_valid & db_ready_nxt) | (db_fsm_r == DB_FSM_END))
    dbg_ibp_wr_valid_r <=  dbg_ibp_wr_valid;
end
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ


always @(posedge clk or posedge rst_a)
begin : dbg_ibp_wr_mask_ibp_PROC
  if (rst_a == 1'b1)
    dbg_ibp_wr_mask_r <=  4'b1111;
  else if (read_csr_status32 | read_csr_3e | write_csr_3e)
    dbg_ibp_wr_mask_r <=  4'b1111;
  else if ((dbg_ibp_cmd_valid & db_ready_nxt) | (db_fsm_r == DB_FSM_END))
    dbg_ibp_wr_mask_r <=  dbg_ibp_wr_mask;
end

// register dbg_ibp_cmd_valid
always @(posedge clk or posedge rst_a)
begin : dbg_ibp_cmd_valid_ibp_PROC
  if (rst_a == 1'b1)
    dbg_ibp_cmd_valid_r <=  1'b0;
  else if (read_csr_status32 | read_csr_3e | write_csr_3e)
    dbg_ibp_cmd_valid_r <=  1'b0;
  else if ((dbg_ibp_cmd_valid & db_ready_nxt) | (db_fsm_r == DB_FSM_END))
    dbg_ibp_cmd_valid_r <=  dbg_ibp_cmd_valid;
end

// register dbg_ibp_cmd_read
always @(posedge clk or posedge rst_a)
begin : dbg_ibp_cmd_read_ibp_PROC
  if (rst_a == 1'b1)
    dbg_ibp_cmd_read_r  <=  1'b0;
  else if (read_csr_status32 | read_csr_3e | write_csr_3e)
    dbg_ibp_cmd_read_r <=  1'b0;
  else if (dbg_ibp_cmd_valid & db_ready_nxt)
    dbg_ibp_cmd_read_r  <=  dbg_ibp_cmd_read;
end

// assignment for dbg_ibp_rd_data
always @(posedge clk or posedge rst_a)
begin : dbg_ibp_rd_data_ibp_PROC
  if (rst_a == 1'b1)
    dbg_ibp_rd_data_r  <=  `DATA_SIZE'd0;
  else if (db_data_enb == 1'b1)
    dbg_ibp_rd_data_r  <=  dbg_data_nxt;
end

always @(posedge clk or posedge rst_a)
begin : dbg_done_PROC
  if (rst_a == 1'b1)
    dbg_done_r  <=  1'b0;
  else if ((db_fsm_r == DB_FSM_RELOAD) || (db_fsm_r == DB_FSM_END))
    dbg_done_r  <=  cpu_db_done;
end

always @(posedge clk or posedge rst_a)
begin : dbg_done_delay_PROC
  if (rst_a == 1'b1)
    dbg_done_delay_r  <=  1'b0;
  else if (((dbg_ibp_cmd_read_r & dbg_ibp_rd_valid & dbg_ibp_rd_accept)) | ((~dbg_ibp_cmd_read_r & dbg_ibp_wr_done)))
    dbg_done_delay_r  <=  1'b0;
  else if ((db_fsm_r == DB_FSM_END) || (db_fsm_r == DB_FSM_IDLE))
    dbg_done_delay_r  <=  dbg_done_r;
end

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Output assignments                                                     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////


assign db_limm     = dbg_addr_r; 

assign db_data     = dbg_data_r;
//ibp outputs
assign dbg_ibp_rd_valid  = safety_iso_enb_synch_r ? 1'b0: ((dbg_done_delay_r & dbg_rd_op & (db_fsm_r == DB_FSM_IDLE))
                           | read_csr_status32 | read_csr_3e)
                           ;

assign dbg_ibp_wr_done   = (dbg_done_delay_r & dbg_wr_op & (db_fsm_r == DB_FSM_IDLE))
                           | write_csr_3e
                           ;

assign dbg_ibp_wr_err    = db_failed_r & dbg_wr_op;

assign dbg_ibp_rd_err    = db_failed_r & dbg_rd_op;

assign dbg_ibp_rd_data   = read_csr_status32 ? 32'b0: 
                                               (read_csr_3e ? 32'b0: dbg_ibp_rd_data_r);
                                               

assign read_csr_status32 = dbg_ibp_cmd_valid & (dbg_ibp_cmd_addr[11:0] == `CSR_STATUS32) &
                           dbg_ibp_cmd_read & 
                           ((dbg_ibp_cmd_space == ACC_CSR) | (dbg_ibp_cmd_space == ACC_AUX))
                           ;

// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ CDC_COHERENCY_RECONV_SEQ
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals
assign read_csr_3e       = dbg_ibp_cmd_valid & (dbg_ibp_cmd_addr[11:0] == 12'h03E) &
                           dbg_ibp_cmd_read & 
                           ((dbg_ibp_cmd_space == ACC_GPR) | (dbg_ibp_cmd_space == ACC_AUX))
                           ;
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ CDC_COHERENCY_RECONV_SEQ
assign write_csr_3e      = dbg_ibp_cmd_valid & (dbg_ibp_cmd_addr[11:0] == 12'h03E) &
                           ~dbg_ibp_cmd_read & 
                           ((dbg_ibp_cmd_space == ACC_GPR) | (dbg_ibp_cmd_space == ACC_AUX))
                           ;




assign db_reg_addr = db_inst[19:15];
assign db_op_1h[`DB_OP_REG_RD] = db_active & dbg_gpr_rd; //(db_cmd_r == DB_CORE_RD);
assign db_op_1h[`DB_OP_REG_WR] = db_active & dbg_gpr_wr; //(db_cmd_r == DB_CORE_WR);
assign db_op_1h[`DB_OP_CSR_RD] = db_active & (dbg_csr_rd | dbg_aux_rd); //(db_cmd_r == DB_AUX_RD);
assign db_op_1h[`DB_OP_CSR_WR] = db_active & (dbg_csr_wr | dbg_aux_wr); //(db_cmd_r == DB_AUX_WR);
assign db_op_1h[`DB_OP_MEM_RD] = db_active & dbg_mem_rd; //(db_cmd_r == DB_MEM_RD);
assign db_op_1h[`DB_OP_MEM_WR] = db_active & dbg_mem_wr; //(db_cmd_r == DB_MEM_WR);


// SMD: aresetcross
// SJ:  dm_rst_a asserts with rst_a
always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    dbg_ibp_safety_err <= 2'b01;
  end
  else
  begin
    if (dbg_ibp_cmd_valid == 1'b1)
    begin
      dbg_ibp_safety_err <= 2'b10;
    end
    else
    begin
      dbg_ibp_safety_err <= 2'b01;
    end
  end
end

assign dr_safety_iso_err  = (safety_iso_enb_synch_r == 1'b1) ? dbg_ibp_safety_err: 2'b01;



endmodule // rl_debug
