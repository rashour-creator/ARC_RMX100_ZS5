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
// Certain materials incorporated herein are copyright (C) 2010 - 2023, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//   ####   #       ####    ####   #    #         ####    #####  #####   #
//  #    #  #      #    #  #    #  #   #         #    #     #    #    #  #
//  #       #      #    #  #       ####          #          #    #    #  #
//  #       #      #    #  #       #  #          #          #    #####   #
//  #    #  #      #    #  #    #  #   #         #    #     #    #   #   #
//   ####   #####   ####    ####   #    # #####   ####      #    #    #  #####
//
// ===========================================================================
//
// @f:clock_ctrl
//
// Description:
// @p
//  The |clock_ctrl| module instantiates the architectural clock gates, which
//  gates off clocks as necessary, when in sleep/halt mode
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o clock_ctrl.vpp
//
// ===========================================================================

// Configuration-dependent macro definitions
//
`include "defines.v"
`include "csr_defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"
`include "mpy_defines.v"
`include "rv_safety_exported_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_clock_ctrl (
  ////////// State of the core ///////////////////////////////////////////////
  //
  input                       sys_sleep_r,        // sleeping (arch_sleep_r)
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input [`EXT_SMODE_RANGE]    sys_sleep_mode_r,   // sleep mode
// spyglass enable_block W240
  input                       sys_halt_r,         // halted
  input                       arc_halt_req,       // synchr halt req
  input                       arc_halt_ack,       // synchr halt ack
  input                       arc_run_req,        // synchr run req
  input                       arc_run_ack,        // synchr run ack

  input                       dmp_idle_r,
  input                       ifu_idle_r,
  input                       rnmi_req,
  ////////// arch clk enable signal //////////////////////////////////////////
  //
  output reg                  ar_clock_enable_r,
  ////////// DMI enable signal ///////////////////////////////////////////////
  //
  input                       iccm_dmi_clock_enable_nxt,
  input                       dccm_dmi_clock_enable_nxt,
  input                       mmio_dmi_clock_enable_nxt,
  ////////// Debug enable signal /////////////////////////////////////////////
  //
  input                       db_clock_enable_nxt,
  ////////// Cache busy signals //////////////////////////////////////////////
  //
  input                       ic_idle_ack,
  ////////// IRQ preemption signal (to wake up a sleeping core ///////////////
  //
  input                      irq_trap,
  ////////// L1 clock gating signals /////////////////////////////////////////
  //
  input  [`FU_1H_RANGE]       ifu_pd_fu,
  input                       ifu_issue,
  input                       mpy_x1_valid,
  input                       mpy_x2_valid, 
  input                       mpy_x3_pending,


  ///////// Outputs of the architectural clock gates /////////////////////////
  //
  output                      clk_wdt,
  input                       pct_unit_enable,
  output                      clk_hpm,
  input                       hpm_int_overflow_rising,
  input                       time_ovf_flag,
  output                      clk_gated,
  ////////// L1 gated clock output //////////////////////////////////////////
  //
  output                      clk_mpy,

  ////////// General input signals ///////////////////////////////////////////
  //
  input                       clk,               // Ungated clock

  input   iccm0_clk,
  output  reg [1:0]           iccm0_gclk_cnt,


  input   dccm_even_clk,
  input   dccm_odd_clk,
  output  reg [1:0]           dccm_even_gclk_cnt,
  output  reg [1:0]           dccm_odd_gclk_cnt,

  input   ic_tag_mem_clk,
  input   ic_data_mem_clk,
  output  reg [1:0]           ic_tag_mem_gclk_cnt,
  output  reg [1:0]           ic_data_mem_gclk_cnt,

  output  reg [1:0]           gclk_cnt,

  input                       rst_a              // Asynchronous reset
);

// Local Declarations

reg                     db_clock_enable_r;
reg                     ar_clock_enable_nxt;

reg                     ar_clock_enable_wdt_r;
reg                     ar_clock_enable_wdt_nxt;
reg                     pct_unit_enable_r;
reg                     ar_clock_enable_mpy_nxt;
reg                     ar_clock_enable_mpy_r;

// Module Definition

// Instantiate a clock gate wrapper so that the synthesis flow can replace it
// with the proper clkgate cell of the target library
//
clkgate u_clkgate0 (
  .clk_in            (clk),
  .clock_enable_r    (ar_clock_enable_r),
  .clk_out           (clk_gated)
);
// spyglass disable_block Ar_glitch01 
// SMD: Report glitch in reset paths
// SJ: if TMR is enabled, the tripple synchronized reset signal will go through majority vote. 
// But it doesn't matters if the de-assertion of reset is one cycle ealier or later,this warning can be ignored.
// Glitch can be ignored
// spyglass disable_block Reset_check07
// SMD: Reports asynchronous reset pins driven by a combinational logic or a mux
// SJ:  if TMR is enabled, the tripple synchronized reset signal will go through majority vote, this can be waived


always @(posedge iccm0_clk or posedge rst_a)
begin : iccm0_gclk_cnt_PROC
  if (rst_a == 1'b1)
  begin
    iccm0_gclk_cnt  <= 2'b0;
  end
  else
  begin
    iccm0_gclk_cnt  <= iccm0_gclk_cnt + 2'b1;
  end
end

always @(posedge dccm_even_clk or posedge rst_a)
begin : dccm_even_gclk_cnt_PROC
  if (rst_a == 1'b1)
  begin
    dccm_even_gclk_cnt  <= 2'b0;
  end
  else
  begin
    dccm_even_gclk_cnt  <= dccm_even_gclk_cnt + 2'b1;
  end
end
always @(posedge dccm_odd_clk or posedge rst_a)
begin : dccm_odd_gclk_cnt_PROC
  if (rst_a == 1'b1)
  begin
    dccm_odd_gclk_cnt  <= 2'b0;
  end
  else
  begin
    dccm_odd_gclk_cnt  <= dccm_odd_gclk_cnt + 2'b1;
  end
end

always @(posedge ic_tag_mem_clk or posedge rst_a)
begin : ic_tag_mem_gclk_cnt_PROC
  if (rst_a == 1'b1)
  begin
    ic_tag_mem_gclk_cnt  <= 2'b0;
  end
  else
  begin
    ic_tag_mem_gclk_cnt  <= ic_tag_mem_gclk_cnt + 2'b1;
  end
end

always @(posedge ic_data_mem_clk or posedge rst_a)
begin : ic_data_mem_gclk_cnt_PROC
  if (rst_a == 1'b1)
  begin
    ic_data_mem_gclk_cnt  <= 2'b0;
  end
  else
  begin
    ic_data_mem_gclk_cnt  <= ic_data_mem_gclk_cnt + 2'b1;
  end
end


always @(posedge clk_gated or posedge rst_a)
begin : gclk_cnt_PROC
  if (rst_a == 1'b1)
  begin
    gclk_cnt  <= 2'b0;
  end
  else
  begin
    gclk_cnt  <= gclk_cnt + 2'b1;
  end
end
// spyglass enable_block Reset_check07
// spyglass enable_block Ar_glitch01 

clkgate u_clkgate1 (
  .clk_in            (clk),
  .clock_enable_r    (ar_clock_enable_wdt_r),
  .clk_out           (clk_wdt)
);
 

clkgate u_clkgate_hpm (
  .clk_in            (clk),
  .clock_enable_r    (pct_unit_enable_r),
  .clk_out           (clk_hpm)
);

clkgate u_clkgate2 (
  .clk_in            (clk),
  .clock_enable_r    (ar_clock_enable_mpy_r),
  .clk_out           (clk_mpy)
);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Asynchronous process to determine next value for the architectural       //
// clock gate enable                                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : ar_clock_enable_nxt_comb_PROC
  if (sys_sleep_r | sys_halt_r)
    begin
    // The core is in a low power state (sleeping or halted). By default the
    // core clock will be disabled. However, the clock needs to be enabled
    // for the following events:
    //
    // 1. A fully-qualified and enabled interrupt request is asserted,
    //    guaranteeing that at least one asserted interrupt should be taken
    //    by the core. This event will bring the core out of a sleeping state.
    //
    // 2. A DMI transaction is to take place, requiring temporary enablement
    //    of the core clock.
    //
    // 3. A debug transaction is to take place, requiring temporary enablement
    //    of the core clock.
    //
    // 4. there is a pending DMP transaction, which remains active until there is
    //    no pending transaction request in DMP.
    //
    // 5. servicing a halt/run req/ack in sleep mode.
    //
    // 6. Wait ICACHE or DCACHE to back to IDLE state.
    //
    // 7. there is a pending IFU transaction.
// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ CDC_COHERENCY_RECONV_SEQ
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals

    ar_clock_enable_nxt = 1'b0 
	                    | rnmi_req
	                    | irq_trap                                           // 1
                        | iccm_dmi_clock_enable_nxt                          // 2
                        | dccm_dmi_clock_enable_nxt                          // 2
                        | mmio_dmi_clock_enable_nxt                          // 2
                        | (db_clock_enable_nxt | db_clock_enable_r)          // 3
                        | ~ic_idle_ack                                       // 6
                        | ~dmp_idle_r                                        // 4
						| ~ifu_idle_r                                        // 7
                        | arc_halt_req | arc_halt_ack                        // 5             
                        | arc_run_req   | arc_run_ack                        // 5
                        ;
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ CDC_COHERENCY_RECONV_SEQ
    end
  else
    begin
    // The core is running, and the clock must remain enabled.
    //
    ar_clock_enable_nxt = 1'b1;
    end
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Asynchronous process to determine next value for the architectural       //
// clock gate enable for the watchdog timers                                //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : ar_clock_enable_wdt_nxt_comb_PROC
  // The timers architectural clock enabled is only active when the cpu
  // is in SLEEP_MODE_0 or SLEP_MODE_2. It is disabled otherwise.
  //
  ar_clock_enable_wdt_nxt = ~(   sys_sleep_r
//                                & (  (sys_sleep_mode_r != `SLEEP_MODE_0)
//                                   & (sys_sleep_mode_r != `SLEEP_MODE_2) )
                                ); // @@@ maybe need to be combined with sleep mode?
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Asynchronous process to determine next value for the architectural       //
// clock gate enable for the Multiplier/DIV/REM module.                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : ar_clock_enable_mpy_nxt_comb_PROC
  ar_clock_enable_mpy_nxt = (~(sys_sleep_r | sys_halt_r) &
                            ((ifu_pd_fu[`FU_MPY_1H] && ifu_issue) 
                            | mpy_x1_valid  
                            | mpy_x2_valid
                            ))
                            | mpy_x3_pending
                            ;
end



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Synchronous processes to register the incoming debug enable              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// When the debug unit turns on the clock, it needs to remain one for
// at least two cycles. This is needed so that the clock is enabled while
// there are debug instructions moving through the pipeline
//

always @(posedge clk or posedge rst_a)
begin : db_clock_enable_r_PROC
  if (rst_a == 1'b1)
  begin 

    db_clock_enable_r  <= 1'b1;

  end
  else
  begin

    db_clock_enable_r  <= db_clock_enable_nxt;

  end
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Synchronous process to define the registered architectural clock enable  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// spyglass disable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH
// SMD: Asynchronous set/reset signal is not an input to the module
// SJ : Intended to internally generate asynchronous set/reset signals
always @(posedge clk or posedge rst_a)
begin : ar_clock_enable_r_PROC
  if (rst_a == 1'b1)
  begin

    ar_clock_enable_r  <= 1'b1;

  end
  else
  begin

    ar_clock_enable_r  <= ar_clock_enable_nxt;

  end
end
// spyglass enable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH

always @(posedge clk or posedge rst_a)
begin : ar_clock_enable_wdt_r_PROC
  if (rst_a == 1'b1)
  begin

    ar_clock_enable_wdt_r  <= 1'b1;

  end
  else
  begin

    ar_clock_enable_wdt_r  <= ar_clock_enable_wdt_nxt;

  end
end


reg time_ovf_flag_d;
reg clk_en_reg;
wire clk_en;

always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1) 
  begin
      time_ovf_flag_d <= 1'b0;
  end 
  else 
  begin
      time_ovf_flag_d <= time_ovf_flag;
  end
end

wire time_ovf_flag_rising = time_ovf_flag & ~time_ovf_flag_d;

// spyglass disable_block INTEGRITY_RESET_GLITCH
// SMD: Asynchronous set/reset signal is not an input to the module
// SJ : Intended to internally generate asynchronous set/reset signals
always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1) 
  begin
    clk_en_reg <= 1'b0;
  end
  else if (time_ovf_flag_rising)
  begin
    clk_en_reg <= 1'b1;
  end
  else if (hpm_int_overflow_rising)
  begin
    clk_en_reg <= 1'b0;
  end
  else
  begin
    clk_en_reg <= clk_en_reg;
  end
end
// spyglass enable_block INTEGRITY_RESET_GLITCH

assign clk_en = clk_en_reg | time_ovf_flag_rising;

// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ CDC_COHERENCY_ASYNCSRCS_RECONV_COMB
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals
always @(posedge clk or posedge rst_a)
begin : hpm_unit_clock_enable_reg_PROC
  if (rst_a == 1'b1)
  begin
    pct_unit_enable_r  <= 1'b1;
  end
  else if (clk_en)
  begin
    pct_unit_enable_r  <= 1'b1;
  end
  else
  begin
    pct_unit_enable_r  <= pct_unit_enable & ar_clock_enable_nxt;
  end
end
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ CDC_COHERENCY_ASYNCSRCS_RECONV_COMB

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Synchronous process to define the registered architectural clock enable  //
// for the multiplier/DIV/REM module.                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : ar_clock_enable_mpy_r_PROC
  if (rst_a == 1'b1)
  begin
    ar_clock_enable_mpy_r  <= 1'b1;
  end
  else
  begin
    ar_clock_enable_mpy_r  <= ar_clock_enable_mpy_nxt;
  end
end

endmodule // rl_clock_ctrl
