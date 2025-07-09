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
// @f:ls_input_delay
//
// Description:
// @p
//  Delay stage implementation - parity generated and checked. Parity Error output.
// @e
//
//  This .vpp source file must be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o halt.vpp
//
// ===========================================================================

//  W527 off - allows if statements without an else

// Configuration-dependent macro definitions
//

// Set simulation timescale
//
`include "const.def"

module ls_input_delay #(
    parameter SIZE = 4,
    parameter CHUNK = 16,
    parameter DELAY = 0,
    parameter RST_VALUE = 0
    ) (
// spyglass disable_block W240
// SMD: clk, rst, en declared but not read
// SJ: the behaviour is intentional When DELAY eq 0
// spyglas disable_block Ac_conv04
// SMD: Checks all the control-bus clock domain crossings that do not follow gray encoding
// SJ: This block is not a synchrnoizer. This blocks delays the inputs to the
// shadow core by two clock cycles for a Dual Core Locksetp Implementation
// spyglass disable_block Clock_delay01
// SMD: Reports flip-flop pairs whose data path delta delay is less than the
//difference in their clock path delta delays
// SJ: This is an intended change 
    ////////// General input signals ///////////////////////////////////////////
    //
    input [SIZE-1:0]       d_in,
    input 	           clk,
    input 	           rst,
    input	           en,
    ////// Outputs /////////////////////////////////////////////

    output     [SIZE-1:0]  q_out
    );

    generate // {
    if (DELAY == 0) begin:DELAY_eq_0// {
        assign q_out = d_in;
    end
    else begin:DELAY_gt_0// } {
        localparam REMND = SIZE % CHUNK;
        localparam CHUNKS = SIZE/CHUNK + (REMND != 0)*1;
        localparam LAST = CHUNKS-1;
        `ifndef SYNTHESIS
        function automatic int stats();
            $display("There are %2d chunks with %2d remaining DS=%2d", CHUNKS,REMND, SIZE);
            return 0;
            endfunction
        `endif
        `define delay_no_par(chunksize,index) \
    	    ls_input_delay_without_parity #(.REG_WIDTH(chunksize),.DELAY(DELAY),.RST_VALUE(RST_VALUE)) u_chunk ( \
    		.clk        (clk), \
    		.rst        (rst), \
    		.d_in       (d_in [index*CHUNK +: chunksize]), \
    		.en	    (en), \
    		.q_out      (q_out[index*CHUNK +: chunksize]) \
    		); 
        `define delay_par(chunksize,index) \
    	    ls_input_delay_with_parity #(.REG_WIDTH(chunksize),.DELAY(DELAY),.RST_VALUE(RST_VALUE)) u_chunk ( \
    		.parity_error(totalpar[index]), \
    		.clk        (clk), \
    		.rst        (rst), \
    		.en	    (en), \
    		.d_in       (d_in [index*CHUNK +: chunksize]), \
    		.q_out      (q_out[index*CHUNK +: chunksize]) \
    		); 
    
            
        `define chunks(macro) \
    	for (genvar i = 0; i < SIZE/CHUNK; i++) begin: chunk \
    	    `macro(CHUNK,  i) \
    	    end \
    	if (REMND > 0) begin: remainder \
    	    `macro(REMND, LAST) \
    	    end
    
        if(1) begin:generate_replaced_if //{
            `ifndef SYNTHESIS
            wire show = stats();
            `endif
            `chunks(delay_no_par)	// Pass in the macro to be used.
        end //}
        `undef delay_no_par
        `undef delay_par
        `undef chunks
    end // }
    endgenerate // }

// spyglass enable_block W240
    endmodule 



module ls_input_delay_with_parity #(
    parameter REG_WIDTH=4,
    parameter DELAY = 0,
    parameter RST_VALUE = 0
    ) (
  ////////// General input signals ///////////////////////////////////////////
  //
    input [REG_WIDTH-1:0]  d_in,
    input 		   clk,
    input 		   rst,
    input		   en,
  ////// Outputs /////////////////////////////////////////////

    output 		   parity_error,
    output reg [REG_WIDTH-1:0] q_out
    );


    localparam ON_RESET = (RST_VALUE==0)?  1'b0 : 1'b1;

    wire d_parity       = ^d_in;
    wire recomp_parity  = ^q_out;
    
    generate // {
    if (DELAY == 1) begin:DELAY_eq_1 // {
        always_ff @(posedge clk or posedge rst) begin: stage1_PROC
            if (rst == 1'b1)
              q_out <= {REG_WIDTH{ON_RESET}};
            else
              if (en) 
                q_out <= d_in;
            end
    end 
    else begin:DELAY_gt_1// }{ // Must be 2.  0 is handled in caller.
      reg [REG_WIDTH-1:0]  q_out_1;
      reg 	         q_par;
      reg	 		 q_par_1;
      always_ff @(posedge clk or posedge rst) begin : stage2_PROC
            if (rst == 1'b1)
              begin
                 q_out_1 <=  {REG_WIDTH{ON_RESET}};
                 q_out   <=  {REG_WIDTH{ON_RESET}};
                 q_par_1 <= ^{REG_WIDTH{ON_RESET}};
                 q_par   <= ^{REG_WIDTH{ON_RESET}};
              end
            else
              begin
                 q_out   <= q_out_1;
                 q_par   <= q_par_1;
                 if (en) begin
          	   q_out_1 <= d_in;
          	   q_par_1 <= d_parity;
          	   end
              end
      end
      assign parity_error = en ? q_par ^ recomp_parity : 0;
    end // }
    endgenerate // }
endmodule


module ls_input_delay_without_parity #(
    parameter REG_WIDTH=4,
    parameter DELAY = 0,
    parameter RST_VALUE = 0
    ) (
  ////////// General input signals ///////////////////////////////////////////
  //
    input [REG_WIDTH-1:0]  d_in,
    input 		   clk,
    input 		   rst,
    input		   en,
  ////// Outputs /////////////////////////////////////////////

    output reg [REG_WIDTH-1:0] q_out
    );

    localparam ON_RESET = (RST_VALUE==0)?  1'b0 : 1'b1;
    generate // {
// spyglass disable_block INTEGRITY_RESET_GLITCH
// SMD: reset pin is driven by combinational logic
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so it's intended combinational logic on reset pins and it will not have glitch issue which is proved through vcspyglass formal engine.
    if (DELAY == 1) begin:DELAY_eq_1 // {
      always_ff @(posedge clk or posedge rst) begin: stage1_PROC
          if (rst == 1'b1)
            q_out <= {REG_WIDTH{ON_RESET}};
          else
// spyglass disable_block FlopEConst
// SMD: Enable pin is tied to 1
// SJ:  In some configurations this enables is always high
            if (en) 
              q_out <= d_in;
// spyglass enable_block FlopEConst  
          end
      end
    else begin:DELAY_gt_1// }{ // Must be 2.  0 is handled in caller.
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets that are synchronized more than once in the same clock domain
// SJ: Intended as reset for shadow instance is being delayed, 2 cycle delay is treated as a second reset synchronizer
      reg [REG_WIDTH-1:0]  q_out_1;
      always_ff @(posedge clk or posedge rst) begin : stage2_PROC
            if (rst == 1'b1)
              begin
                 q_out_1 <= {REG_WIDTH{ON_RESET}};
                 q_out   <= {REG_WIDTH{ON_RESET}};
              end
            else
              begin
// spyglass disable_block FlopEConst
// SMD: Enable pin is tied to 1
// SJ:  In some configurations this enables is always high
                 if (en) 
          	 q_out_1 <= d_in;
// spyglass enable_block FlopEConst  
                 q_out   <= q_out_1;
              end
      end
// spyglass enable_block Reset_sync04
    end // }
// spyglass enable_block INTEGRITY_RESET_GLITCH
    endgenerate // }
// spyglas enable_block Ac_conv04
// spyglass enable_block Clock_delay01
endmodule

