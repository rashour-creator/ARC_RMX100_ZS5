`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_add_zview(in);
/* eve no_synthvout */
	input	[63:0]		in;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_reqsig_clock_driverclock(o);
/* eve no_synthvout */
	output			o;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_stop_driver_clock_2(in);
/* eve no_synthvout */
	input			in;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_8(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_mcp_fake_edge_detector(in, out);
/* eve no_synthvout */
	input			in;
	output			out;

	reg			out;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_9(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_10(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_11(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_12(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_13(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_14(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_15(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_16(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_17(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_18(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_19(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_20(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_21(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_22(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_23(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_24(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_25(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_26(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_27(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_28(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_29(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_30(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_31(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_32(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_33(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_34(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_dpi_mcp_fake_edge_detector_2(in, out);
/* eve no_synthvout */
	input			in;
	output			out;

	reg			out;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_35(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_36(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_37(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_mem_sco(inGuardExpr, outGuardExpr, inSampleCond, outSampleCond);
/* eve no_synthvout */
	input			inGuardExpr;
	output			outGuardExpr;
	input			inSampleCond;
	output			outSampleCond;

	reg			outGuardExpr;
	reg			outSampleCond;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_38(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_39(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_40(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_41(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_42(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_43(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_44(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_45(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_46(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_47(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_48(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_49(stable, posReady, in_n);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_n;

	reg			in_n_0;
	reg			in_n_1;
	wire			in_n_change;

	assign in_n_change = ((!in_n) && in_n_0);
	assign posReady = in_n_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_n				(in_n), 
		.out				(in_n_1));

	always @(posedge stable) in_n_0 <= in_n_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_50(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_51(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_52(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_53(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_54(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_55(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_56(stable, posReady, in_p);
/* eve no_synthvout */
	input			stable;
	output			posReady;
	input			in_p;

	reg			in_p_0;
	reg			in_p_1;
	wire			in_p_change;

	assign in_p_change = (in_p && (!in_p_0));
	assign posReady = in_p_change;


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_front_ed_clk_edge_P_1_U_1 zebu_bb_front_ed_clk_edge(
		.in_p				(in_p), 
		.out				(in_p_1));

	always @(posedge stable) in_p_0 <= in_p_1;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_sample_4_1(clk, signal, signal_sample);
/* eve no_synthvout */
	input			clk;
	input	[3:0]		signal;
	input	[3:0]		signal_sample;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_1_1(clk, signal);
/* eve no_synthvout */
	input			clk;
	input			signal;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_sample_1_1(clk, signal, signal_sample);
/* eve no_synthvout */
	input			clk;
	input			signal;
	input			signal_sample;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_sample_64_1(clk, signal, signal_sample);
/* eve no_synthvout */
	input			clk;
	input	[63:0]		signal;
	input	[63:0]		signal_sample;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_front_ed_clk_edge_P_1_U_1(in_p, in_n, in_c, in_u, out);
/* eve no_synthvout */
	input			in_p;
	input			in_n;
	input			in_c;
	input			in_u;
	output			out;

	reg			in_p;
	reg			in_n;
	reg			in_c;
	reg			in_u;
	reg			out;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_edge_detector(in, inDis, out);
/* eve no_synthvout */
	input			in;
	input			inDis;
	output			out;

	reg			out;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_async_reset_cond(in, out);
/* eve no_synthvout */
	input			in;
	output			out;

	reg			out;
endmodule
