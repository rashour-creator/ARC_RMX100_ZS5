// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2014 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2014, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// ####### ######   #####     #             #####  ######     #    #     #
// #       #     # #     #   # #           #     # #     #   # #   ##   ##
// #       #     # #        #   #          #       #     #  #   #  # # # #
// #####   ######  #  #### #     #          #####  ######  #     # #  #  #
// #       #       #     # #######               # #   #   ####### #     #
// #       #       #     # #     #         #     # #    #  #     # #     #
// #       #        #####  #     # #######  #####  #     # #     # #     #
//
// ===========================================================================
//
// Description:
//
//  This file implements a behavioural model of RAM memory, for
//  use in FPGA synthesis.
//
//
// ===========================================================================

`ifdef FPGA_INFER_MEMORIES

// Verilog simulator timescale definition for all modules
//

module alb_mss_fpga_sram
#(parameter MEM_SIZE   = 512,
  parameter DATA_WIDTH = 32,
  parameter ADDR_MSB   = 31,
  parameter ADDR_LSB   = 0,
  parameter WR_SIZE    = 8,
  parameter SYNC_OUT   = 1'b1,
  parameter PIPELINED  = 1'b0,
  parameter RAM_STL  = "")
(
  input                           clk,      // clock input
  input   [DATA_WIDTH -1:0]       din,      // write data input
  input   [ADDR_MSB:ADDR_LSB]     addr,     // address for read or write
  input                           regen,    // register enable
  input                           rden,     // memory read enable
  input  [DATA_WIDTH/WR_SIZE-1:0] wren,     // write enables
  output [DATA_WIDTH -1:0]        dout      // read data output
);

// This part is for FPGA memory modelling

// Memories should be inferred automatically
`ifdef TTVTOC
    reg [DATA_WIDTH-1:0] mem_r[0:MEM_SIZE-1];
`else
    (*syn_ramstyle = RAM_STL *) reg [DATA_WIDTH-1:0] mem_r[0:MEM_SIZE-1];
    //reg [DATA_WIDTH-1:0] mem_r[0:MEM_SIZE-1] /* syn_ramstyle = RAM_STL */;
`endif
    reg  [ADDR_MSB:ADDR_LSB] addr_r;
    reg  [DATA_WIDTH-1:0]    dout1;
    wire [DATA_WIDTH-1:0]    dout2;
    reg  [DATA_WIDTH-1:0]    dout3;

    always @(posedge clk)
    begin
      if (rden)
        addr_r <= addr;
      if (rden && SYNC_OUT)
        dout1 <= mem_r[addr];
      if (regen && PIPELINED)
        dout3 <= dout2;
    end

    genvar i;
    generate
    for (i = 0; i < DATA_WIDTH/WR_SIZE; i = i+1)
      begin :memblock
       always @(posedge clk)
        begin
         if (wren[i])
           mem_r[addr][WR_SIZE*i+:WR_SIZE] <= din[WR_SIZE*i+:WR_SIZE];
         end
        end
    endgenerate

 assign dout2 = SYNC_OUT ? dout1 : mem_r[addr_r];
 assign dout = PIPELINED ? dout3 : dout2;

endmodule

`endif
