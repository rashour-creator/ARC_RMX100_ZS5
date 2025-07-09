// Library safety-1.1.999999999
////////////////////////////////////////////////////////////////////////////////
//
//                  (C) COPYRIGHT 2015 - 2020 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
//  The entire notice above must be reproduced on all authorized copies.
//
// Filename    : DWbb_bcm99.v
// Revision    : $Id: $
// Author      : Liming SU    06/19/15
// Description : DWbb_bcm99.v Verilog module for DWbb
//
// DesignWare IP ID: bc6934e8
//
////////////////////////////////////////////////////////////////////////////////
// spyglass disable_block INTEGRITY_RESET_ASYNC_AND_SYNC_USAGE
// SMD: sync and async reset used
// SJ: dw_dbp is reused ip with configurable reset
// spyglass disable_block Ar_glitch01
// SMD: Signal driving clear pin of the flop has glitch
// SJ: source is coming from the recirculation stage of the synchronizer, this warning can be ignored.
// spyglass disable_block Clock_check04 W391
// SMD: Flags usage of both posedge and negedge of the clock in the design.
// SJ: Intentially used in the design to generate the divided version of nexus clocks with odd number ratios
module DWbb_bcm99 (
  clk_d,
  rst_d_n,
  data_s,
  data_d
);

parameter ACCURATE_MISSAMPLING = 0; // RANGE 0 to 1

input  clk_d;      // clock input from destination domain
input  rst_d_n;    // active low asynchronous reset from destination domain
input  data_s;     // data to be synchronized from source domain
output data_d;     // data synchronized to destination domain

`ifdef SYNTHESIS
//######################### NOTE ABOUT TECHNOLOGY CELL MAPPING ############################
// Replace code between "DOUBLE FF SYNCHRONIZER BEGIN" and "DOUBLE FF SYNCHRONIZER END"
// with one of the following two options of customized register cell(s):
//   Option 1: One instance of a 2-FF cell
//     Macro cell must have an instance name of "sample_meta".
//
//     Example: (TECH_SYNC_2FF is example name of a synchronizer macro cell found in a technology library)
//         TECH_SYNC_2FF sample_meta ( .D(data_s), .CP(clk_d), .RSTN(rst_d_n), .Q(data_d) );
//     
//   Option 2: Two instances of single-FF cells connected serially 
//     The first stage synchronizer cell must have an instance name of "sample_meta".
//     The second stage synchronizer cell must have an instance name of "sample_syncl".
//
//     Example: (in GTECH)
//         wire n9;
//         GTECH_FD2 sample_meta ( .D(data_s), .CP(clk_d), .CD(rst_d_n), .Q(n9) );
//         GTECH_FD2 sample_syncl ( .D(n9), .CP(clk_d), .CD(rst_d_n), .Q(data_d) );
//
//####################### END NOTE ABOUT TECHNOLOGY CELL MAPPING ##########################
// DOUBLE FF SYNCHRONIZER BEGIN
  reg sample_meta;
  reg sample_syncl;
  always @(posedge clk_d or negedge rst_d_n) begin : a1000_PROC
// spyglass disable_block STARC05-1.3.1.3
// SMD: Do not use asynchronous reset/preset signals as non-reset/preset or synchronous reset/preset signals
// SJ: Core may use sync'd reset as data signal
// spyglass disable_block Reset_check07 INTEGRITY_RESET_GLITCH
// SMD: Reports asynchronous reset pins driven by a combinational logic or a mux
// SJ: Combinational logic is caused by NMI reset and this is
// spyglass disable_block Reset_sync02
// SMD: ResetInDomain
// SJ: No issues, designed on purpose 
    if (!rst_d_n) begin
// spyglass enable_block Reset_sync02
// spyglass enable_block Reset_check07

      sample_meta <= 1'b0;
      sample_syncl <= 1'b0;
    end else begin
// spyglass disable_block Reset_check04 Clock_check10 STARC05-1.4.3.4
// SMD: Reset/Clock signals that are used asynchronously as well as synchronously for different flip-flops
// SJ:  Resets/Clocks are used as data in the synchronizer & not as synchronous resets
// spyglass disable_block Reset_sync04 
// SMD: Asynchronous resets that are synchronized more than once in the same clock domain
// SJ: Spyglass recognizes every multi-flop synchronizer as a reset synchronizer, hence any design with a reset that feeds more than one synchronizer gets reported as violating this rule. This rule is waivered temporarily.
// spyglass disable_block Ar_converge02
// SMD: reset signal converges on reset and data pins
// SJ:  Path from mcip rst req to edc aggregate is safe
// spyglass disable_block Ac_glitch03 CDC_GLITCH_CTRL
// SMD: Flop can glitch due to domain crossing
// SJ:  No issues, designed on purpose
// spyglass disable_block Ac_cdc01a
// SMD: Fast clock to slow clock crossing
// SJ:  No issues, handled by design
// spyglass disable_block Ac_unsync01 SETUP_ASYNCRESET_UNUSED
// SMD: Combination logic used between crossing
// SJ:  Intended dual rail signal converting before synchronization
      sample_meta <= data_s;
// spyglass enable_block Ac_unsync01 SETUP_ASYNCRESET_UNUSED
// spyglass enable_block Ac_cdc01a
// spyglass enable_block Reset_sync04
// spyglass enable_block Reset_check04 Clock_check10 STARC05-1.4.3.4
// spyglass enable_block Ar_converge02
// spyglass enable_block Ac_glitch03 CDC_GLITCH_CTRL
// spyglass disable_block W402b
// SMD: Asynchronous set/reset signal is not an input to the module
// SJ: This module is expected to generate reset for its parent module
// spyglass disable_block Ar_resetcross01
// SMD: unsync reset crossing
// SJ:  crossing from cc is safe, causes no issues
// spyglass disable_block Ac_glitch01  INTEGRITY_ASYNCRESET_COMBO_MUX
// SMD: Flop can glitch due to domain crossing
// SJ:  No issues, designed on purpose
// spyglass disable_block Ar_asyncdeassert01 Ar_unsync01 Reset_sync02
// SMD: Reset signal is asynchronously de-asserted relative to clock signal
// SJ:  No issues, designed on purpose
      sample_syncl <= sample_meta;
// spyglass enable_block Ar_asyncdeassert01 Ar_unsync01 Reset_sync02
// spyglass enable_block Ac_glitch01 INTEGRITY_ASYNCRESET_COMBO_MUX
// spyglass enable_block W402b
// spyglass enable_block Ar_resetcross01
// spyglass enable_block STARC05-1.3.1.3
    end
  end
// spyglass enable_block INTEGRITY_RESET_GLITCH
  assign data_d = sample_syncl;
// DOUBLE FF SYNCHRONIZER END
`else
  `ifndef DW_MODEL_MISSAMPLES
//#####################################################################################
// NOTE: This section is for zero-time delay functional simulation
//#####################################################################################
  reg sample_meta;
  reg sample_syncl;
  always @(posedge clk_d or negedge rst_d_n) begin : a1001_PROC
    if (!rst_d_n) begin
      sample_meta <= 1'b0;
      sample_syncl <= 1'b0;
    end else begin
// spyglass disable_block Reset_check04
// SMD: Reset signals that are used asynchronously as well as synchronously for different flip-flops
// SJ:  Resets are used as data in the synchronizer & not as synchronous resets
// spyglass disable_block Reset_sync04 
// SMD: Asynchronous resets that are synchronized more than once in the same clock domain
// SJ: Spyglass recognizes every multi-flop synchronizer as a reset synchronizer, hence any design with a reset that feeds more than one synchronizer gets reported as violating this rule. This rule is waivered temporarily.
      sample_meta <= data_s;
// spyglass enable_block Reset_sync04
// spyglass enable_block Reset_check04
      sample_syncl <= sample_meta;
    end
  end
  assign data_d = sample_syncl;
  `else
  localparam WIDTH = 1;


  `ifdef DW_MODEL_MISSAMPLES


// { START Latency Accurate modeling
  initial begin : set_setup_hold_delay_PROC
    `ifndef DW_HOLD_MUX_DELAY
      `define DW_HOLD_MUX_DELAY  1
      if (ACCURATE_MISSAMPLING == 1)
        $display("Information: %m: *** Warning: `DW_HOLD_MUX_DELAY is not defined so it is being set to: %0d ***", `DW_HOLD_MUX_DELAY);
    `endif

    `ifndef DW_SETUP_MUX_DELAY
      `define DW_SETUP_MUX_DELAY  1
      if (ACCURATE_MISSAMPLING == 1)
        $display("Information: %m: *** Warning: `DW_SETUP_MUX_DELAY is not defined so it is being set to: %0d ***", `DW_SETUP_MUX_DELAY);
    `endif
  end // set_setup_hold_delay_PROC


  reg [WIDTH-1:0] setup_mux_ctrl, hold_mux_ctrl;
  initial setup_mux_ctrl = {WIDTH{1'b0}};
  initial hold_mux_ctrl  = {WIDTH{1'b0}};
  
  wire [WIDTH-1:0] data_s_q;
  reg clk_d_q;
  initial clk_d_q = 1'b0;
  reg [WIDTH-1:0] setup_mux_out, d_muxout;
  reg [WIDTH-1:0] d_ff1, d_ff2;
  integer i,j,k;
  
  
  //Delay the destination clock
  always @ (posedge clk_d)
  #`DW_HOLD_MUX_DELAY clk_d_q = 1'b1;

  always @ (negedge clk_d)
  #`DW_HOLD_MUX_DELAY clk_d_q = 1'b0;
  
  //Delay the source data
  assign #`DW_SETUP_MUX_DELAY data_s_q = (!rst_d_n) ? {WIDTH{1'b0}}:data_s;

  //setup_mux_ctrl controls the data entering the flip flop 
  always @ (data_s or data_s_q or setup_mux_ctrl) begin
    for (i=0;i<=WIDTH-1;i=i+1) begin
      if (setup_mux_ctrl[i])
        setup_mux_out[i] = data_s_q[i];
      else
        setup_mux_out[i] = data_s;
    end
  end

  always @ (posedge clk_d_q or negedge rst_d_n) begin
    if (rst_d_n == 1'b0)
      d_ff2 <= {WIDTH{1'b0}};
    else
      d_ff2 <= setup_mux_out;
  end

  always @ (posedge clk_d or negedge rst_d_n) begin
    if (rst_d_n == 1'b0) begin
      d_ff1          <= {WIDTH{1'b0}};
      setup_mux_ctrl <= {WIDTH{1'b0}};
      hold_mux_ctrl  <= {WIDTH{1'b0}};
    end
    else begin
      d_ff1          <= setup_mux_out;
    `ifdef DWC_BCM_SV
      setup_mux_ctrl <= $urandom;  //randomize mux_ctrl
      hold_mux_ctrl  <= $urandom;  //randomize mux_ctrl
    `else
      setup_mux_ctrl <= $random;  //randomize mux_ctrl
      hold_mux_ctrl  <= $random;  //randomize mux_ctrl
    `endif
    end
  end


//hold_mux_ctrl decides the clock triggering the flip-flop
always @(hold_mux_ctrl or d_ff2 or d_ff1) begin
      for (k=0;k<=WIDTH-1;k=k+1) begin
        if (hold_mux_ctrl[k])
          d_muxout[k] = d_ff2[k];
        else
          d_muxout[k] = d_ff1[k];
      end
end
// END Latency Accurate modeling }


 //Assertions
`ifdef DWC_BCM_SNPS_ASSERT_ON
`ifndef SYNTHESIS
generate if (ACCURATE_MISSAMPLING==1) begin : GEN_ASSERT_FST2_VE5
  sequence p_num_d_chng;
  @ (posedge clk_d) 1'b1 ##0 (data_s != d_ff1); //Number of times input data changed
  endsequence
  
  sequence p_num_d_chng_hmux1;
  @ (posedge clk_d) 1'b1 ##0 ((data_s != d_ff1) && (|(hold_mux_ctrl & (data_s ^ d_ff1)))); //Number of times hold_mux_ctrl was asserted when the input data changed
  endsequence
  
  sequence p_num_d_chng_smux1;
  @ (posedge clk_d) 1'b1 ##0 ((data_s != d_ff1) && (|(setup_mux_ctrl & (data_s ^ d_ff1)))); //Number of times setup_mux_ctrl was asserted when the input data changed
  endsequence
  
  sequence p_hold_vio;
  reg [WIDTH-1:0]temp_var, temp_var1;
  @ (posedge clk_d) (((data_s != d_ff1) && (|(hold_mux_ctrl & (data_s ^ d_ff1)))), temp_var = data_s, temp_var1 =(hold_mux_ctrl & (data_s ^ d_ff1))) ##1 ((data_d & temp_var1) == (temp_var & temp_var1));
          //Number of times output data was advanced due to hold violation
  endsequence
  
  sequence p_setup_vio;
  reg [WIDTH-1:0]temp_var, temp_var1;
  @ (posedge clk_d) (((data_s != d_ff1) && (|(setup_mux_ctrl & (data_s ^ d_ff1)))), temp_var = data_s, temp_var1 =(setup_mux_ctrl & (data_s ^ d_ff1))) ##2 ((data_d & temp_var1) != (temp_var & temp_var1));
          //Number of times output data was delayed due to setup violation
  endsequence

  cp_num_d_chng           : cover property  (p_num_d_chng);    
  cp_num_d_chng_hld_mux1  : cover property  (p_num_d_chng_hmux1);
  cp_num_d_chng_set_mux1  : cover property  (p_num_d_chng_smux1);
  cp_hold_vio             : cover property  (p_hold_vio);
  cp_setup_vio            : cover property  (p_setup_vio);        
 end
endgenerate
`endif // SYNTHESIS
`endif // DWC_BCM_SNPS_ASSERT_ON

  `endif

  generate if (ACCURATE_MISSAMPLING == 1) begin : GEN_DATA_PRE_AM_EQ_1
    reg sample_meta;
    reg sample_syncl;
    always @(posedge clk_d or negedge rst_d_n) begin : a1002_PROC
      if (!rst_d_n) begin
        sample_meta  <= 1'b0;
        sample_syncl <= 1'b0;
      end else begin
        sample_meta  <= d_muxout;
        sample_syncl <= sample_meta;
      end
    end
    assign data_d = sample_syncl;
  end else begin : GEN_DATA_PRE_AM_EQ_0
    reg sample_meta;
    reg sample_syncl;
    always @(posedge clk_d or negedge rst_d_n) begin : a1003_PROC
      if (!rst_d_n) begin
        sample_meta  <= 1'b0;
        sample_syncl <= 1'b0;
      end else begin
// spyglass disable_block Reset_check04
// SMD: Reset signals that are used asynchronously as well as synchronously for different flip-flops
// SJ:  Resets are used as data in the synchronizer & not as synchronous resets
// spyglass disable_block Reset_sync04 
// SMD: Asynchronous resets that are synchronized more than once in the same clock domain
// SJ: Spyglass recognizes every multi-flop synchronizer as a reset synchronizer, hence any design with a reset that feeds more than one synchronizer gets reported as violating this rule. This rule is waivered temporarily.
        sample_meta  <= data_s;
// spyglass enable_block Reset_sync04
// spyglass enable_block Reset_check04
        sample_syncl <= sample_meta;
      end
    end
    assign data_d = sample_syncl;
  end endgenerate
  `endif
`endif

endmodule
// spyglass enable_block Clock_check04 W391
// spyglass enable_block Ar_glitch01
// spyglass enable_block INTEGRITY_RESET_ASYNC_AND_SYNC_USAGE
