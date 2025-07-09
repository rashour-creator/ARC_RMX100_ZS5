// Library ARCv2MSS-2.1.999999999

//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2014 Synopsys, Inc. All rights reserved.
//
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2012, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//      ######     #    ######   ####
//      #          #    #       #    #
//      #####      #    #####   #    #
//      #          #    #       #    #
//      #          #    #       #    #
//      #          #    #        ####
//
// ===========================================================================
//
// Description:
//  Verilog module for general FIFO
//
// ===========================================================================

// Set simulation timescale
//
`include "const.def"

module mss_bus_switch_bypbuf # (
  parameter BUF_DEPTH = 8,
  parameter BUF_WIDTH = 32
) (
  input                  i_valid,
  output                 i_ready,
  input  [BUF_WIDTH-1:0] i_data,
  output                 o_valid,
  input                  o_ready,
  output [BUF_WIDTH-1:0] o_data,

  input                   clk,
  input                   rst_a
);


wire                 fifo_i_valid;
wire                 fifo_i_ready;
wire [BUF_WIDTH-1:0] fifo_i_data;
wire                 fifo_o_valid;
wire                 fifo_o_ready;
wire [BUF_WIDTH-1:0] fifo_o_data;

mss_bus_switch_fifo # (
     .FIFO_DEPTH(BUF_DEPTH),
     .FIFO_WIDTH(BUF_WIDTH),
     .IN_OUT_MWHILE (0),
     .O_SUPPORT_RTIO(0),
     .I_SUPPORT_RTIO(0)
) u_mss_bus_switch_fifo(
  .i_clk_en  (1'b1  ),
  .o_clk_en  (1'b1  ),
  .i_valid   (fifo_i_valid),
  .i_ready   (fifo_i_ready),
  .i_data    (fifo_i_data),
  .o_valid   (fifo_o_valid),
  .o_ready   (fifo_o_ready),
  .o_data    (fifo_o_data),
// leda B_1011 off
// leda WV951025 off
// LMD: Port is not completely connected
// LJ: unused in this instantiation
  .i_occp    (),
  .o_occp    (),
// leda B_1011 on
// leda WV951025 on
  .clk       (clk  ),
  .rst_a     (rst_a)
);
generate //{

  if(BUF_DEPTH == 0) begin: fifo_dep_eq_0//{

assign i_ready = fifo_i_ready;
assign fifo_i_valid = i_valid;
assign fifo_i_data  = i_data;

assign fifo_o_ready = o_ready;
assign o_valid = fifo_o_valid;
assign o_data = fifo_o_data;

  end
  else begin: fifo_dep_gt_1

assign i_ready = fifo_i_ready;

// When fifo is empty, and o_ready is high, then it bypass the fifo
wire byp_fifo = (~fifo_o_valid) & i_valid & o_ready ;
assign fifo_i_valid = i_valid & (~byp_fifo);
assign fifo_i_data  = i_data;
assign fifo_o_ready = o_ready;
assign o_valid = fifo_o_valid | i_valid;
assign o_data = fifo_o_valid ? fifo_o_data : i_data;

  end

endgenerate //}


endmodule // mss_bus_switch_bypbuf

