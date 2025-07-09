// Library ARCv5EM-3.5.999999999

`include "defines.v"

//----------------------------------------------------------------------------
//
// Copyright (C) 2020-2022 Synopsys, Inc. All rights reserved.
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

// Configuration-dependent macro definitions
//
`include "defines.v"
`include "mpy_defines.v"
`include "ifu_defines.v"

//----------------------------------------------------------------------------
//
//
//
//
// ===========================================================================
//
// Description:
//   Support for RASCAL pipe monitor (simulation only).
/*

Module rtl_pipemon supports RASCAL pipemon.  It provides to pipemon five kinds
of information:

- instruction(s) executed at the commit point
- the address of issued loads
- the address and, optionally, the data of issued stores
- the register/register pair and data of any writebacks.
- the flags zncv

pipemon inspects rtl_pipemon for internally declared signals that provide the
above information.  Those signals need not be output from rtl_pipemon.

The pipemon module is recogized if it contains the signal

    wire [31:0]             pipemon_config;      // configuration register
    reg [3:0]               zncv;
(We may change zncv to status32 in the near future.)

pipemon_config fields:
    7:0    -- 6 for 64-bit cores, and 4 for 32-bit cores.
    8      -- if 1, a vector vdsp bundle signal is present in the instruction interface.
    11:9   -- size of floating-point registers in powers of 2.
              Valid values are >= 2.  Typical: 2, 3
              A value of < 2 means there are no floating-point registers.
    12     -- instr(ix>_uop bit is included in the instruction interface.
    Remainder of the fields are 0.

The quantity of each kind of information may be different in different
instantiations of rtl_pipemon.   The quantity is identified by these four signals:

    wire [1:0]              num_instrs;           // Up to 3.
    wire [1:0]              num_stores;           // Up to 3.
    wire [1:0]              num_loads;            // Up to 3.
    wire [2:0]              num_writebacks;       // Up to 7.
    // looks at num_fpwritebacks only if pipemon_config
    // declares a valid size for the floating-point registers.
    wire [2:0]              num_fpwritebacks;     // Up to 7.
(You can increase the range to support larger values.  RASCAL loads the
signal value as a 32-bit quantity.)

The range 1:0 above is just an example; RASCAL pipemon will read these
signals as 32 bit quantities.

Instructions
------------

For each instruction, RASCAL pipemon expects these signals to be declared:

    reg                instr<ix>_valid;        // instr is valid.
    reg                instr<ix>_is_16_bit;    // Instr is 16-bit
    reg [31:0]         instr<ix>_inst;         // Instruction.  If 16-bit, it's in the upper half.
    reg                instr<ix>_limm_valid;   // limm valid for this instruction
    reg [31:0]         instr<ix>_limm;         // limm value
    reg [`PMON_PC_RANGE] instr<ix>_pc;         // PC of this instruction
    reg                instr<ix>_pipe;         // Pipe index 0, 1, ... N-1.
    reg                instr<ix>_debug;        // Debug instr
    reg                instr<ix>_uop;          // UOP instr. (if bit 12 of config)
    reg [`BUNDLE_RANGE] instr<ix>_vdsp;        // Only if bit 8 of pipemon_config.

where <ix> is the index: 0, 1, 2... of the instruction.  Dual-issue HS
cores use indexes 0 and 1; single-issue cores use just index 0.
However, RASCAL pipemon is capable of displaying any number of pipes.

An instruction is valid only if instr<ix>_valid is true.
If more than one instruction is valid, the execution order of the instructions
must be the same as the indices.  E.g. for dual-issue, index 0 designates
the first executed instruction, and 1 the second.  RASCAL pipemon uses
the instruction pipe value to show which pipe the instruction executed from.

If an instruction is valid, debug is false, and the vdsp signal is present,
the vdsp bundle is checked for a valid bundle (one of certain major opcodes).
If so, RASCAL pipemon disassembles the bundle; otherwise it disassembles the inst.

Writebacks
------------
For each writeback, RASCAL pipemon expects these signals to be declared:

    reg                wb<ix>_valid;           // wb is valid.
    reg [2:0]          wb<ix>_size;            // power of 2: 2^wb<ix>size = 1/2/4/8/16.
    reg [`DATA_RANGE]  wb<ix>_data_lo;
    reg [`DATA_RANGE]  wb<ix>_data_hi;
    reg [5:0]          wb<ix>_reg;

A writeback is valid only if wb<ix>_valid is true.
RASCAL pipemon prints the register wb<ix>_reg and its associated data_lo value.
If the size is greater than that of a single register, RASCAL pipemon assumes
the writeback is a register pair, and prints wb<ix>_reg+1 and the data_hi value.
The size of a register is determined from the pipemon_config value.

A writeback print looks like:
         w1: r4  <- 01020304 r5  <- 01020307
This happens to be a register pair r4/r5 on writeback 1.

For each FPU register writeback, RASCAL pipemon expects these signals to be declared:

    reg [1:0]          fpwb<ix>_valid;           // wb is valid.
    reg [2:0]          fpwb<ix>_size;            // power of 2: 2^wb<ix>size = 1/2/4/8/16.
    reg [`DATA_RANGE]  fpwb<ix>_data_lo;
    reg [`DATA_RANGE]  fpwb<ix>_data_hi;
    reg [5:0]          fpwb<ix>_reg;

A result for an FPU register is valid only if wb<ix>_valid is non-zero.
RASCAL pipemon prints the register wb<ix>_reg and its associated data_lo value.
If the size is greater than that of a single FPU register, RASCAL pipemon assumes
the writeback is a register pair, and prints wb<ix>_reg+1 and the data_hi value.
The size of a register is determined from the pipemon_config value.

The result is written to the register file if bit 0 of _valid is true.
If bit 0 is 0 but bit 1 is 1, the writeback was squashed.

A writeback print looks like:
         w1: f4  <- 01020304 f5  <- 01020307
This happens to be a register pair f4/f5 on writeback 1.

The size of an FPU register is specified in pipemon_config.

Loads
------------
For each load, RASCAL pipemon expects these signals to be declared:

    reg                load<ix>_valid;        // load inst.
    reg [2:0]          load<ix>_size;         // load size, power of 2.
    reg [`ADDR_RANGE]  load<ix>_addr;         // load addr.

A load is valid only if load<ix>_valid is true.
RASCAL pipemon prints the address of the load, but not the result, as it
is unavailable.  The size of the load may be printed by RASCAL pipemon.

A load print looks like:
        ld [1000]

Stores
------------
For each store, RASCAL pipemon expects these signals to be declared:

    reg                store<ix>_valid;        // store inst.
    reg [2:0]          store<ix>_size;         // store size, power of 2.
    reg [`DATA_RANGE]  store<ix>_data_lo;      // store data.
    reg [`DATA_RANGE]  store<ix>_data_hi;      // store data.
    reg                store<ix>_data_valid;   // store data valid at time of commit.
    reg [`ADDR_RANGE]  store<ix>_addr;         // store addr.

A store is valid only if store<ix>_valid is true.
RASCAL pipemon prints the address of the store, and may print its size.
    reg                store<ix>_data_valid;   // store data valid at time of commit.
The data is printed if avalable.

A store print looks like:
    st 1020307 -> [1004]
or, if data is unavailable, like this:
    st ____ -> [1004]


Synthesis issues
----------------
rtl_pipemon is designed so that if SYNTHESIS is defined, it disappears.

Presently, it is operational for HS 32-bit only if RTL_PIPEMON is defined
when compiling the RTL.  After final testing it will be enabled by default.
It is always operational for HS 64-bit.

*/

//
// ===========================================================================

// Include definitions for the microcode constants, including both ARC
// base-case and any User extension instructions which may be defined.
//

// Set simulation timescale
//
`include "const.def"


`define PMON_PC_RANGE 31:0



`ifdef RTL_PIPEMON  // {
`ifdef SYNTHESIS // {
`undef RTL_PIPEMON
`endif // }
`endif // }




module rtl_pipemon (
  ////////// Clock and reset //////////////////////////////////////////
  //
  input                     clk,
  input                     rst_a,

  ////////// Debug interface ////////////////////////////////////////////////////////
  //
  input                     db_active,           // Debugger inserted instruction

  ////////// Interface with X1 //////////////////////////////////////////////////////
  //
  input                     x1_valid_r,
  input                     x1_pass,
  input                     x1_is_16bit_r,
  input [`INST_RANGE]       x1_inst_r,
  input [`PMON_PC_RANGE]    x1_pc,
  input                     shadow_decoder,

  input                     x1_load,
  input                     x1_store,
  input [1:0]               x1_size,
  input [`ADDR_RANGE]       x1_mem_addr,
  input [`ADDR_RANGE]       x1_mem_data,

  ////////// Interface with X2 //////////////////////////////////////////////////////
  //
  input                     x2_valid_r,
  input                     x2_pass,
  input                     trap_valid,
  input                     rnmi_synch_r,

  ////////// Trap status ////////////////////////////////////////////////////////////
  //
  input [`DATA_RANGE]       mstatus_nxt,
  input [`DATA_RANGE]       mnstatus_r,
  input [`DATA_RANGE]       mncause_r,
  input                     csr_x2_mret,
  input                     csr_x2_mnret,
  input [`DATA_RANGE]       trap_x2_cause,
  input [`DATA_RANGE]       trap_x2_data,
  input [`DATA_RANGE]       mip_r,
  input [`DATA_RANGE]       mie_r,
  input [`DATA_RANGE]       mtsp_r,
  input [`ADDR_RANGE]       mepc_r,
  input                     trap_ack,
  input                     rnmi_enable,
  input                     mdt_r,
  input [7:0]               irq_id,

  ////////// Register-file write-backs  //////////////////////////////////////////////
  //
  //====================== Channel 0 ======================================
  //
  input                     rb_rf_write0,
  input [`RGF_ADDR_RANGE]   rb_rf_addr0,
  input [`DATA_RANGE]       rb_rf_wdata0,

  //====================== Channel 1 ======================================
  //
  input                     rb_rf_write1,
  input [`RGF_ADDR_RANGE]   rb_rf_addr1,
  input [`DATA_RANGE]       rb_rf_wdata1,

  ////////// ARChitectural PC //////////////////////////////////////////////////////
  //
  input [`PMON_PC_RANGE]    ar_pc_r
);
// Vector unit
localparam has_vec = 0;


////////// Output interface to PIPEMON - INST ////////////////////////////////////

wire [31:0]           pipemon_config /* verilator public_flat */;      // configuration register

wire [1:0]            num_instrs /* verilator public_flat */;

reg                   instr0_valid /* verilator public_flat */;        // instr is valid.
reg                   instr0_is_16_bit /* verilator public_flat */;    // Instr is 16-bit
reg [31:0]            instr0_inst /* verilator public_flat */;         // Instruction.  If 16-bit, it's in the upper half.
reg                   instr0_limm_valid /* verilator public_flat */;   // limm valid for this instruction
reg [31:0]            instr0_limm /* verilator public_flat */;         // limm value
reg [`PMON_PC_RANGE]  instr0_pc /* verilator public_flat */;           // PC of this instruction, without bottom bit.
reg                   instr0_pipe /* verilator public_flat */;         // Pipe index 0, 1, ... N-1.  Adjust [0:0] when 3 pipes
reg                   instr0_debug /* verilator public_flat */;        // Debug instr
reg                   instr0_uop /* verilator public_flat */;          // UOP instr

reg                   instr1_valid /* verilator public_flat */;        // instr is valid.
reg                   instr1_is_16_bit /* verilator public_flat */;    // Instr is 16-bit
reg [31:0]            instr1_inst /* verilator public_flat */;         // Instruction.  If 16-bit, it's in the upper half.
reg                   instr1_limm_valid /* verilator public_flat */;   // limm valid for this instruction
reg [31:0]            instr1_limm /* verilator public_flat */;         // limm value
reg [`PMON_PC_RANGE]  instr1_pc /* verilator public_flat */;           // PC of this instruction, without bottom bit.
reg                   instr1_pipe /* verilator public_flat */;         // Pipe index 0, 1, ... N-1.  Adjust [0:0] when 3 pipes
reg                   instr1_debug /* verilator public_flat */;        // Debug instr
reg                   instr1_uop /* verilator public_flat */;          // UOP instr

reg [3:0]             zncv /* verilator public_flat */;                // ZNCV flags {Z, N, C, V}

////////// Output interface to PIPEMON - LD/ST ////////////////////////////////////

wire [1:0]            num_loads /* verilator public_flat */;

reg                   load0_valid /* verilator public_flat */;        // load inst.
reg [2:0]             load0_size /* verilator public_flat */;         // load size, power of 2.
reg [`ADDR_RANGE]     load0_addr /* verilator public_flat */;         // load addr.

wire [1:0]            num_stores /* verilator public_flat */;

reg                   store0_valid /* verilator public_flat */;        // store inst.
reg [2:0]             store0_size /* verilator public_flat */;         // store size, power of 2.
reg [`DATA_RANGE]     store0_data_lo /* verilator public_flat */;      // store data.
reg [`DATA_RANGE]     store0_data_hi /* verilator public_flat */;      // store data.
reg                   store0_data_valid /* verilator public_flat */;   // store data valid at time of commit.
reg [`ADDR_RANGE]     store0_addr /* verilator public_flat */;         // store addr.

////////// Output interface to PIPEMON - Register writebacks ////////////////////////

wire [2:0]            num_writebacks /* verilator public_flat */;       // Total number of write-back ports

reg                   wb0_valid /* verilator public_flat */;           // wb is valid.
reg [2:0]             wb0_size /* verilator public_flat */;            // power of 2: 2^size = 1/2/4/8/16.
reg [`DATA_RANGE]     wb0_data_lo /* verilator public_flat */;
reg [`DATA_RANGE]     wb0_data_hi /* verilator public_flat */;
reg [5:0]             wb0_reg /* verilator public_flat */;
reg                   wb1_valid /* verilator public_flat */;           // wb is valid.
reg [2:0]             wb1_size /* verilator public_flat */;            // power of 2: 2^size = 1/2/4/8/16.
reg [`DATA_RANGE]     wb1_data_lo /* verilator public_flat */;
reg [`DATA_RANGE]     wb1_data_hi /* verilator public_flat */;
reg [5:0]             wb1_reg /* verilator public_flat */;
reg                   wb2_valid /* verilator public_flat */;           // wb is valid.
reg [2:0]             wb2_size /* verilator public_flat */;            // power of 2: 2^size = 1/2/4/8/16.
reg [`DATA_RANGE]     wb2_data_lo /* verilator public_flat */;
reg [`DATA_RANGE]     wb2_data_hi /* verilator public_flat */;
reg [5:0]             wb2_reg /* verilator public_flat */;

////////// Output interface to PIPEMON - Exception status ///////////////////////////
reg                   excpn_valid /* verilator public_flat */;
reg [`DATA_RANGE]     excpn_mcause /* verilator public_flat */;
reg [`DATA_RANGE]     excpn_mtval /* verilator public_flat */;
reg [`DATA_RANGE]     excpn_mstatus /* verilator public_flat */;


// END OF INTERFACE
/////////////////////////////////////////////////////////////////////////////////////

reg                     x2_is_16bit_r;
reg [`INST_RANGE]       x2_inst_r;
reg [`PMON_PC_RANGE]    x2_pc_r;

reg                     x2_load_r;
reg                     x2_store_r;
reg [1:0]               x2_size_r;
reg [`ADDR_RANGE]       x2_mem_addr_r;
reg [`ADDR_RANGE]       x2_mem_data_r;

reg                     wa_is_16bit_r;
reg [`INST_RANGE]       wa_inst_r;
reg [`PMON_PC_RANGE]    wa_pc_r;

reg                     wa_valid_r;

reg                     wa_rf_write0;
reg [`RGF_ADDR_RANGE]   wa_rf_addr0;
reg [`DATA_RANGE]       wa_rf_wdata0;

reg                     wa_rf_write1;
reg [`RGF_ADDR_RANGE]   wa_rf_addr1;
reg [`DATA_RANGE]       wa_rf_wdata1;

reg                     wa_load_r;
reg                     wa_store_r;
reg [1:0]               wa_size_r;
reg [`ADDR_RANGE]       wa_mem_addr_r;
reg [`ADDR_RANGE]       wa_mem_data_r;
reg                     shadow_decoder_r;

always @ (posedge clk)
    shadow_decoder_r <= shadow_decoder;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Move instructions down the pipe
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin

  if (x1_pass & (!shadow_decoder))
  begin
    x2_is_16bit_r <= x1_is_16bit_r;
    x2_inst_r     <= x1_inst_r;
    x2_pc_r       <= x1_pc;

    x2_load_r     <= x1_load;
    x2_store_r    <= x1_store;
    x2_size_r     <= x1_size;
    x2_mem_addr_r <= x1_mem_addr;
    x2_mem_data_r <= x1_mem_data;
  end

  if ((x2_pass | trap_valid) & (!shadow_decoder_r))
  begin
    wa_is_16bit_r <= x2_is_16bit_r;
    wa_inst_r     <= x2_inst_r;
    wa_pc_r       <= x2_pc_r;

    wa_size_r     <= x2_size_r;
    wa_mem_addr_r <= x2_mem_addr_r;
    wa_mem_data_r <= x2_mem_data_r;
  end

  wa_valid_r      <= (x2_pass | trap_valid) & (!shadow_decoder_r);
  wa_load_r       <= x2_pass & x2_load_r;
  wa_store_r      <= x2_pass & x2_store_r;

  wa_rf_write0    <= rb_rf_write0;
  wa_rf_addr0     <= rb_rf_addr0;
  wa_rf_wdata0    <= rb_rf_wdata0;

  wa_rf_write1    <= rb_rf_write1;
  wa_rf_addr1     <= rb_rf_addr1;
  wa_rf_wdata1    <= rb_rf_wdata1;
end

////////////////////////////////////////////////////////////////////////////////
// Instructions
//
////////////////////////////////////////////////////////////////////////////////
assign pipemon_config =
      32'd7 	// core version.
    | has_vec   // vdsp bundle present
    //| 1536      // FPU register configuration
    | 4096	// uop field in instr interface
    | 0;

assign num_instrs     = 2'd1;
assign num_loads      = 2'd1;
assign num_stores     = 2'd1;
assign num_writebacks = 2;

always @*
begin
  // Instruction
  //
  instr0_valid        = wa_valid_r;
  instr0_is_16_bit    = wa_is_16bit_r;
  instr0_inst         = wa_inst_r;
  instr0_limm_valid   = 1'b0;
  instr0_limm         = 32'd0;
  instr0_pc           =  wa_pc_r;
  instr0_pipe         = 1'b0;
  instr0_debug        = db_active;
  instr0_uop          = 1'b0;

  // LD/ST
  //
  load0_valid         = wa_load_r;
  load0_size          = wa_size_r;
  load0_addr          = wa_mem_addr_r;

  store0_valid        = wa_store_r;
  store0_size         = wa_size_r;
  store0_data_lo      = wa_mem_data_r;
  store0_data_valid   = 1'b1;
  store0_addr         = wa_mem_addr_r;

  // Register write-back
  //
  wb0_reg             = wa_rf_addr0;
  wb0_valid           = wa_rf_write0 && wb0_reg != 0;
  wb0_data_lo         = wa_rf_wdata0;
  wb0_data_hi         = 32'd0;
  wb0_size            = 2;  // 2**2 = 4 bytes

  wb1_reg             = wa_rf_addr1;
  wb1_valid           = wa_rf_write1 && wb1_reg != 0;
  wb1_data_lo         = wa_rf_wdata1;
  wb1_data_hi         = 32'd0;
  wb1_size            = 2;  // 2**2 = 4 bytes
end

////////////////////////////////////////////////////////////////////////////////
// Exception
//
////////////////////////////////////////////////////////////////////////////////

always @(posedge clk)
begin
  excpn_valid <= trap_valid;

  if (trap_valid)
    begin
      excpn_mstatus <= mstatus_nxt;
      if (!((rnmi_synch_r & rnmi_enable) | mdt_r))
      begin
      excpn_mcause  <= trap_x2_cause;
	    excpn_mtval   <= trap_x2_data;
      end
	end
end

endmodule


