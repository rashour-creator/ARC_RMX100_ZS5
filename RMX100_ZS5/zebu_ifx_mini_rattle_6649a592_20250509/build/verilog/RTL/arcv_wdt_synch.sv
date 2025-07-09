
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
// @f:arcv_wdt_synch
//
// Description:
// @p
//   watchdog clock crossing and feedback check module.
// @e
//
// ===========================================================================

`include "defines.v"
`include "const.def"


module arcv_wdt_synch
  #(
  parameter RST_TMR_CDC        = 0    
  )
 (
  input   wdt_feedback_bit,
  output  wdt_clk_enable_sync,
  input   wdt_clk,
  output  wdt_reset_wdt_clk0,
 input                     clk,
 input                     test_mode,
 input                     rst
 );

//Reset Sychronizer in wdt_clk domain
logic                    sync_wdt_rst_n;
logic                    rst_wdt_synch_r;

ls_cdc_sync #(
	.TMR_CDC(RST_TMR_CDC)) u_wdt_rst_cdc_sync
(
.clk   (wdt_clk),
.rst_a (rst    ),
.din   (1'b1   ),
.dout  (sync_wdt_rst_n)
);
//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived as BCM is used for reset synch, test_mode overwrite is already added
//spyglass disable_block W402b
//SMD: Reset is gated or internally generated
//SJ : test_mode overwrite is already added for gating
assign rst_wdt_synch_r = test_mode
                 ? rst
                 : ~sync_wdt_rst_n
                 ;
//spyglass enable_block W402b
//spyglass enable_block TA_09                                 

// spyglass disable_block Ar_glitch01 
// SMD: Report glitch in reset paths
// SJ: if TMR is enabled, the tripple synchronized reset signal will go through majority vote. 
// But it doesn't matters if the de-assertion of reset is one cycle ealier or later,this warning can be ignored.
// Glitch can be ignored
//T-Flop
logic wdt_clk_enable_r, wdt_clk_enable_nxt;
always_ff @( posedge wdt_clk or posedge rst_wdt_synch_r)
begin: T_Flop_PROC
  if(rst_wdt_synch_r) 
    wdt_clk_enable_r <= 1'b0;
  else              
    wdt_clk_enable_r <= wdt_clk_enable_nxt;
end
// spyglass enable_block Ar_glitch01 

assign wdt_clk_enable_nxt = ~wdt_clk_enable_r;

//CDC from wdt_clk domain to clk domain
ls_cdc_sync u_wdt_clk_enable_cdc_sync	(
     .clk   (clk),
     .rst_a (rst),
     .din   (wdt_clk_enable_r),
     .dout  (wdt_clk_enable_sync)
     );

//CDC from clk domain to wdt_clk domain
logic     wdt_feedback_bit_sync, wdt_feedback_bit_sync_r;
logic     wdt_feedback_bit_edge;
ls_cdc_sync u_wdt_feedback_bit_sync	(
     .clk   (wdt_clk),
     .rst_a (rst_wdt_synch_r),
     .din   (wdt_feedback_bit),
     .dout  (wdt_feedback_bit_sync)
     );


//Edge detection
always_ff@(posedge wdt_clk or posedge rst_wdt_synch_r)
begin : delay_feedback_PROC
  if(rst_wdt_synch_r == 1'b1)
    begin    
 	   wdt_feedback_bit_sync_r <= 1'b0;
    end
  else
    begin  
	   wdt_feedback_bit_sync_r <= wdt_feedback_bit_sync;
    end    
end
assign wdt_feedback_bit_edge = wdt_feedback_bit_sync ^ wdt_feedback_bit_sync_r;

//Counter
logic [3:0] cntr_r, cntr_nxt;

assign cntr_nxt = wdt_feedback_bit_edge ? 4'b0 : ((cntr_r == 4'b1111)? cntr_r: (cntr_r + 4'b1));

// spyglass disable_block Ac_conv02
// SMD: Reports same-domain signals that are synchronized in the same destination domain and converge before sequential elements.
// If the path of synchronizers confirms that synchronizers cannot functionally control the converging net at the same time, waive the violation.
// SJ: The paths of pmode_sync and wdt_feedback_bit_sync synchronized signals do not converge at the same time in the cntr_r logic, so waiving this violation.
always_ff@(posedge wdt_clk or posedge rst_wdt_synch_r)
begin : counter_PROC
  if(rst_wdt_synch_r == 1'b1)
    begin    
 	   cntr_r <= 4'b0;
    end
  else
    begin  
	   cntr_r <= cntr_nxt;
    end    
end
// spyglass enable_block Ac_conv02

//Timeoutcheck
logic core_clock_dead_nxt, core_clock_dead_r;
assign core_clock_dead_nxt = cntr_r == 4'b1111;

// spyglass disable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH
// SMD: reset pin is driven by combinational logic
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so it's intended combinational logic on reset pins and it will not have glitch issue.  
always_ff @( posedge wdt_clk or posedge rst_wdt_synch_r )
begin: core_clock_dead_PROC
  if(rst_wdt_synch_r) begin
    core_clock_dead_r <= 1'b0;
  end
  else begin              
    core_clock_dead_r <= core_clock_dead_nxt;
  end
end
// spyglass enable_block INTEGRITY_ASYNCRESET_COMBO_MUX INTEGRITY_RESET_GLITCH

assign wdt_reset_wdt_clk0 = core_clock_dead_r;

endmodule
