//
// Copyright (C) 2010-2016 Synopsys, Inc. All rights reserved.
//
// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//

// `include "const.def" // can't say this due to a bug in awk hiergen.
`timescale 1 ns / 10 ps // from const.def.

module clock_and_reset (
  
  
    output     eclk /* verilator clocker */,
    output     eclk2 /* verilator clocker */,
    output reg erst_n /* verilator public_flat */,
    output reg [31:0] cycle
    );

parameter clock_period = 50;
parameter clock2_period = 25;

reg local_clk /* verilator public_flat */;
reg local_clk2 /* verilator public_flat */;

`ifndef VERILATOR  // {
initial
begin
   local_clk = 0;
   erst_n = 0;
   #( 0.25 * clock_period );
   erst_n = 1;
   #( 0.25 * clock_period );
   erst_n = 0;
   #(6 * clock_period)
   erst_n = 1;
end

always
begin
  //$display ("toggling clock...\n");
  #(clock_period/2.0)    local_clk = ~local_clk;
end

initial
begin
   local_clk2 = 1;
   forever
     #(clock2_period/2.0)   local_clk2 = ~local_clk2;
end
   assign eclk = local_clk;
   assign eclk2 = local_clk2;
`else  // } {
// ==================== Verilator Clock/Reset Generation ====================
localparam clock_period_ps = longint'(clock_period * 1000);
localparam clock2_period_ps = longint'(clock2_period * 1000);
chandle rst_handle;
chandle clk_handle;
chandle clk2_handle;
import "DPI-C" context function chandle dpi_get_handle(
    input string signal_name
);

import "DPI-C" function void dpi_timed_assign(
    input chandle signal_handle,
    input bit new_value,
    input longint evt_time
);

import "DPI-C" function longint dpi_delayed_assign(
    input chandle signal_handle,
    input bit new_value,
    input longint evt_time
);

import "DPI-C" function void dpi_xcam_poll();

reg local_erst_n /* verilator public_flat */;

always @(posedge local_erst_n or negedge local_erst_n)
begin
   erst_n <= local_erst_n;  
end

initial
begin
   clk_handle = dpi_get_handle("local_clk");
   local_clk = 0;
   dpi_timed_assign(clk_handle, ~local_clk, (clock_period_ps/2));
   rst_handle = dpi_get_handle("local_erst_n");
   local_erst_n = 0;
   dpi_timed_assign(rst_handle, 1, (clock_period_ps/4));
   dpi_timed_assign(rst_handle, 0, (clock_period_ps/2));
   dpi_timed_assign(rst_handle, 1, ((6 * clock_period_ps) + (clock_period_ps/2)));
   clk2_handle = dpi_get_handle("local_clk2");
   local_clk2 = 0;
   dpi_timed_assign(clk2_handle, ~local_clk2, (clock2_period_ps/2));
end

always @(posedge local_clk or negedge local_clk)
begin
  //$display ("toggling clock...\n");
   dpi_delayed_assign(clk_handle, ~local_clk, (clock_period_ps/2));
end

always @(posedge local_clk2 or negedge local_clk2)
begin
  //$display ("toggling clock2...\n");
   dpi_delayed_assign(clk2_handle, ~local_clk2, (clock2_period_ps/2));
end

always @(posedge local_clk)
begin
   dpi_xcam_poll();
end

   assign eclk = local_clk;
   assign eclk2 = local_clk2;
`endif  // }




// This cycle counter needs to be present in ARC_xCAM Verilator builds
// or erst_n is not scheduled properly!!
//
// Keep track of the number of cycles
//
always @(posedge local_clk or negedge erst_n) begin
    if (!erst_n) begin
        cycle <= 0;
        end
    else begin
        cycle <= cycle + 1;
        //$display ("cycle is %d\n", cycle); 
        end
    end

endmodule 

