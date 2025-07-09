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

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_98(stable, posReady, in_p);
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
module ZebuClockDetectFront_99(stable, posReady, in_n);
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
module ZebuClockDetectFront_100(stable, posReady, in_p);
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
module ZebuClockDetectFront_101(stable, posReady, in_p);
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
module ZebuClockDetectFront_102(stable, posReady, in_p);
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
module ZebuClockDetectFront_103(stable, posReady, in_p);
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
module ZebuClockDetectFront_104(stable, posReady, in_p);
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
module ZebuClockDetectFront_105(stable, posReady, in_p);
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
module ZebuClockDetectFront_106(stable, posReady, in_p);
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
module ZebuClockDetectFront_107(stable, posReady, in_p);
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
module zebu_bb_sample_clk_uncond_sample_5_1(clk, signal, signal_sample);
/* eve no_synthvout */
	input			clk;
	input	[4:0]		signal;
	input	[4:0]		signal_sample;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_sample_12_1(clk, signal, signal_sample);
/* eve no_synthvout */
	input			clk;
	input	[11:0]		signal;
	input	[11:0]		signal_sample;
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
module zebu_bb_sample_clk_uncond_7_1(clk, signal);
/* eve no_synthvout */
	input			clk;
	input	[6:0]		signal;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_32_1(clk, signal);
/* eve no_synthvout */
	input			clk;
	input	[31:0]		signal;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_64_1(clk, signal);
/* eve no_synthvout */
	input			clk;
	input	[63:0]		signal;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_66_1(clk, signal);
/* eve no_synthvout */
	input			clk;
	input	[65:0]		signal;
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
module zebu_bb_stop_driver_clock_2(in);
/* eve no_synthvout */
	input			in;
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
module zebu_bb_mcp_fake_edge_detector(in, out);
/* eve no_synthvout */
	input			in;
	output			out;

	reg			out;
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

(* syn_noprune = 1 *) 
module zebu_bb_async_reset_cond(in, out);
/* eve no_synthvout */
	input			in;
	output			out;

	reg			out;
endmodule
