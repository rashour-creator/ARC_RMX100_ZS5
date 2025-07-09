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
// @f: safety_iso_sync
//
// Description:
// @p
//   safety isolation synch module for safety isolation synchronization and change detection.
// @e
//
// ===========================================================================
`include "defines.v"
`include "const.def"

module safety_iso_sync(
    input  [1:0] safety_iso_enb,
    output       safety_iso_enb_sync,
    output [1:0] safety_isol_change,
    input clk,
    input rst
    );

//Safety Isolation
logic [2:0] cntr_r;
logic safety_iso_enb_0_sync; //Synchronized bit 0
logic safety_iso_enb_1_sync; //Synchronized bit 1

ls_cdc_sync u_safety_iso_enb_0_cdc_sync	(
     .clk   (clk),
     .rst_a (rst),
     .din   (safety_iso_enb[0]),
     .dout  (safety_iso_enb_0_sync)
     );

ls_cdc_sync u_safety_iso_enb_1_cdc_sync	(
     .clk   (clk),
     .rst_a (rst),
     .din   (safety_iso_enb[1]),
     .dout  (safety_iso_enb_1_sync)
     );

logic safety_iso_enb_tmp; //Convert to single bit; 
// spyglass disable_block Ac_conv02
// SMD: Checks combinational convergence of same-domain signals synchronized in the same destination domain
// SJ: safety_iso_enb is static signal, change of these signals will hold for a long while
// SJ: Unstable sampling of dual rail signal 2'b00 and 2'b11 will be treated as default safety isolation enabled state
// SJ: 2'b10: safety isolation enabled 
// SJ: 2'b01: safety isolation disabled
// SJ: 2'b00, 2'b11: safety isolation enabled
assign safety_iso_enb_tmp = (cntr_r > 3'b011)? (safety_iso_enb_1_sync) || ~(safety_iso_enb_0_sync) : 1'b0;
// spyglass enable_block Ac_conv02

always_ff@(posedge clk or posedge rst)
begin : counter_PROC
  if(rst == 1'b1)
    begin    
 	   cntr_r <= 3'b0;
    end
  else
    begin  
       if (cntr_r != 3'b111)  
	   cntr_r <= cntr_r + 3'b1;
    end    
end

logic         safety_iso_enb_chg;
logic [1:0]   dr_safety_isol_change_nxt;
logic [1:0]   dr_safety_isol_change_r;
logic         safety_iso_enb_r, safety_iso_enb_dly_r;
assign safety_iso_enb_chg        = safety_iso_enb_r != safety_iso_enb_dly_r;
assign dr_safety_isol_change_nxt = (safety_iso_enb_chg && (cntr_r > 3'b110)) ? 2'b10 : 2'b01;

always_ff@(posedge clk or posedge rst)
begin : safety_isol_change_r_PROC
  if(rst == 1'b1)
    begin    
 	   dr_safety_isol_change_r <= 2'b01;
    end
  else
    begin  
	   dr_safety_isol_change_r <= dr_safety_isol_change_nxt;
    end    
end

assign safety_isol_change = dr_safety_isol_change_r;

always_ff @(posedge clk or posedge rst)
begin : safety_iso_enb_reg_PROC
  if (rst == 1'b1)
  begin
  	safety_iso_enb_r     <= 1'b0; 
  	safety_iso_enb_dly_r <= 1'b0; 
  end
  else
  begin
  	safety_iso_enb_r     <= safety_iso_enb_tmp;
  	safety_iso_enb_dly_r <= safety_iso_enb_r;
  end
end 

assign safety_iso_enb_sync = safety_iso_enb_r;


endmodule

