

/*
 * Copyright (C) 2024 Synopsys, Inc. All rights reserved.
 *
 * SYNOPSYS CONFIDENTIAL - This is an unpublished, confidential, and
 * proprietary work of Synopsys, Inc., and may be subject to patent,
 * copyright, trade secret, and other legal or contractual protection.
 * This work may be used only pursuant to the terms and conditions of a
 * written license agreement with Synopsys, Inc. All other use, reproduction,
 * distribution, or disclosure of this work is strictly prohibited.
 *
 * The entire notice above must be reproduced on all authorized copies.
 */
`include "const.def"

module sr_err_aggr #(
    parameter USE_TSC    = 0, // 0: used normal OR gate 1: use TSC
    parameter SIZE       = 4, // total input width in bits
    parameter IBUF_EN    = 0, // error input flopped
    parameter OBUF_EN    = 1,
    parameter OBUF_DEPTH = 2,
    localparam INT_BUF_DEPTH = (OBUF_DEPTH >0) ? OBUF_DEPTH : 1//Minimum depth is 1.
)(
// spyglass disable_block W240
//SMD:Unread input
//SJ :Ignore packed signal
    input                 clk,
    input                 rst,
// spyglass enable_block W240
    input [SIZE-1:0]      err_in, //multi-bit input error signal
    output                err_out
);

`define SR_ERR_REG(CLK,RST,DEPTH) \
  reg [DEPTH-1:0]     err_r; \
  if(DEPTH<2) begin : single_stage_buffer \
    always_ff@ (posedge CLK or posedge RST) begin: err_reg_proc \
      if(RST) begin \
          err_r <= 1'b0; \
      end \
      else \
      begin \
          err_r <= err_out_temp; \
      end  \
    end \
  end \
  else \
  begin : multi_stage_buffer \
    always_ff@ (posedge CLK or posedge RST) begin : err_reg_proc \
      if(RST) begin \
          err_r <= {DEPTH{1'b0}}; \
      end \
      else \
      begin \
          err_r <= {err_r[DEPTH-2:0],err_out_temp}; \
      end \
    end \
  end \

generate
      localparam PAD_SIZE = (SIZE==1)? 1 : ((1<<$clog2(SIZE)) - SIZE);
      localparam PADDED_WIDTH = SIZE+PAD_SIZE;
      
      
      logic [SIZE-1:0]      err_in_r;
      logic                 err_out_temp; 
      
      if(IBUF_EN==0) begin : no_in_buf
        assign err_in_r = err_in;
      end : no_in_buf
      else begin : input_buf
        always_ff@ (posedge clk or posedge rst) begin : ibuf_reg_proc 
          if(rst) begin
             err_in_r <= {(SIZE){1'b0}};
          end
          else
          begin
             err_in_r <= err_in;
          end
        end
      end : input_buf
      
      if (USE_TSC == 0) begin: no_tsc
        assign err_out_temp = |err_in_r;
      end
      else
      begin: tsc
        logic [1:0] aggr_err_out;
        multi_bit_comparator #(
        .SIZE(SIZE)
        ) u_aggr_err(
          .x(err_in_r),
          .y({SIZE{1'b1}}),
          .e11(aggr_err_out[0]),
          .e22(aggr_err_out[1])
        );
        assign err_out_temp = ~(^aggr_err_out);      
      end

      if(OBUF_EN==0) begin : no_out_buf
        assign err_out = err_out_temp;
      end : no_out_buf
      else
      begin : output_buf
        `SR_ERR_REG(clk,rst,INT_BUF_DEPTH)
        assign err_out = err_r[INT_BUF_DEPTH-1];
      end : output_buf
endgenerate
endmodule: sr_err_aggr
