// Library ARCv2MSS-2.1.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2012 Synopsys, Inc. All rights reserved.
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
//   alb_mss_clkctrl_ratio_calc: clock ratio calculation
//
// ===========================================================================
//
// Description:
//  Verilog module defining a clock controller
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +o alb_mss_clkctrl_ratio_calc.vpp
//
// ==========================================================================

module alb_mss_clkctrl_ratio_calc (
    input [7:0]   ratio_in_A,
    input [7:0]   ratio_in_B,
    input         ratio_req,
    output [7:0]  ratio_result,
    output        ratio_ack,
    output        ratio_err,
    input         clk,
    input         rst_a

);


wire [7:0] ratio_big, ratio_small;
wire       big_flag;

assign big_flag    = (ratio_in_A > ratio_in_B) ? 1'b1 : 1'b0;
assign ratio_big   = big_flag ? ratio_in_A : ratio_in_B;
assign ratio_small = big_flag ? ratio_in_B : ratio_in_A;

parameter IDLE = 3'b000;
parameter CALC = 3'b001;
parameter ACK = 3'b011;

reg [2:0] sta_cur, sta_nxt;
reg load_cnt, incr_cnt, ack_en;
wire update_cnt,ratio_equal, ratio_error;
reg [7:0] ratio_big_reg, ratio_small_reg,  ratio_cnt;
reg [8:0] ratio_incr_reg;
wire [7:0] ratio_cnt_nxt;
wire [8:0] ratio_incr_reg_nxt;

reg [7:0] result_reg;
reg error_reg,ack_reg;

always @(posedge clk or posedge rst_a)
begin : clk_r_calcu_sta_PROC
    if(rst_a == 1'b1)
        sta_cur <= 3'b0;
    else
        sta_cur <= sta_nxt;
end

always @*
begin : clk_r_calcu_fsm_PROC
    sta_nxt      = sta_cur;
    load_cnt     = 0;
    incr_cnt     = 0;
    ack_en       = 0;
    case(sta_cur)
        IDLE:
            if(ratio_req == 1'b1)
            begin
                sta_nxt = CALC;
                load_cnt = 1'b1;
            end

        CALC:
        begin
            if(ratio_equal | ratio_error)
            begin
                sta_nxt = ACK;
                ack_en = 1'b1;
            end
            else
                incr_cnt = 1'b1;
        end
        ACK:
        begin
//            ack_en = 1'b1;
            sta_nxt = IDLE;
        end
    endcase
end

assign update_cnt = load_cnt | incr_cnt;
assign ratio_cnt_nxt = load_cnt ? 1 :
                       incr_cnt ? (ratio_cnt + 1) : ratio_cnt;
assign ratio_incr_reg_nxt = load_cnt ? {1'b0,ratio_small} :
                            incr_cnt ? (ratio_incr_reg + {1'b0,ratio_small_reg}) : ratio_incr_reg;

assign ratio_equal = (ratio_incr_reg == {1'b0,ratio_big_reg});
assign ratio_error = (ratio_incr_reg > {1'b0,ratio_big_reg}) | (ratio_big_reg == 0) | (ratio_small_reg == 0);

always @(posedge clk or posedge rst_a)
begin : clk_r_cnt_PROC
    if(rst_a == 1'b1)
    begin
        ratio_cnt <= 4'b0;
        ratio_small_reg <= 4'b0;
        ratio_big_reg <= 4'b0;
        ratio_incr_reg <= 4'b0;
    end
    else
    begin
        if(load_cnt == 1'b1)
        begin
            ratio_big_reg <= ratio_big;
            ratio_small_reg <= ratio_small;
        end
        if(update_cnt == 1'b1)
        begin
            ratio_incr_reg <= ratio_incr_reg_nxt;
            ratio_cnt <= ratio_cnt_nxt;
        end
    end
end

always @(posedge clk or posedge rst_a)
begin : output_reg_PROC
    if(rst_a == 1'b1)
    begin
        result_reg <= 4'b0;
        error_reg <= 1'b0;
        ack_reg <= 1'b0;
    end
    else
    begin
        if(ack_en == 1'b1)
        begin
           if (big_flag)
            result_reg <= 8'h1;
           else
            result_reg <= ratio_cnt;
            error_reg <= ratio_error;
        end
        ack_reg <= ack_en;
    end
end

assign ratio_result = result_reg;
assign ratio_err = error_reg;
assign ratio_ack = ack_reg;

endmodule
