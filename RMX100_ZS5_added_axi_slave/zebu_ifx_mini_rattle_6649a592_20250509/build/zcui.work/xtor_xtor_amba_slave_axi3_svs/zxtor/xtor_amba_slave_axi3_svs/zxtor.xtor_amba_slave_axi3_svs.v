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
module ZebuClockDetectFront_57(stable, posReady, in_p);
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
module ZebuClockDetectFront_58(stable, posReady, in_p);
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
module ZebuClockDetectFront_59(stable, posReady, in_p);
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
module ZebuClockDetectFront_60(stable, posReady, in_p);
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
module ZebuClockDetectFront_61(stable, posReady, in_n);
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
module ZebuClockDetectFront_62(stable, posReady, in_p);
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
module ZebuClockDetectFront_63(stable, posReady, in_n);
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
module ZebuClockDetectFront_64(stable, posReady, in_p);
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
module ZebuClockDetectFront_65(stable, posReady, in_n);
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
module ZebuClockDetectFront_66(stable, posReady, in_p);
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
module ZebuClockDetectFront_67(stable, posReady, in_n);
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
module ZebuClockDetectFront_68(stable, posReady, in_p);
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
module ZebuClockDetectFront_69(stable, posReady, in_n);
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
module ZebuClockDetectFront_70(stable, posReady, in_p);
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
module ZebuClockDetectFront_71(stable, posReady, in_n);
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
module ZebuClockDetectFront_72(stable, posReady, in_p);
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
module ZebuClockDetectFront_73(stable, posReady, in_p);
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
module ZebuClockDetectFront_74(stable, posReady, in_p);
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
module ZebuClockDetectFront_75(stable, posReady, in_p);
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
module ZebuClockDetectFront_76(stable, posReady, in_p);
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
module ZebuClockDetectFront_77(stable, posReady, in_p);
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
module ZebuClockDetectFront_78(stable, posReady, in_n);
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
module ZebuClockDetectFront_79(stable, posReady, in_p);
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
module ZebuClockDetectFront_80(stable, posReady, in_p);
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
module ZebuClockDetectFront_81(stable, posReady, in_p);
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
module ZebuClockDetectFront_82(stable, posReady, in_p);
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
module ZebuClockDetectFront_83(stable, posReady, in_p);
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
module ZebuClockDetectFront_84(stable, posReady, in_p);
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
module ZebuClockDetectFront_85(stable, posReady, in_p);
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

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_86(stable, posReady, in_p);
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
module ZebuClockDetectFront_87(stable, posReady, in_p);
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
module ZebuClockDetectFront_88(stable, posReady, in_p);
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
module ZebuClockDetectFront_89(stable, posReady, in_p);
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
module ZebuClockDetectFront_90(stable, posReady, in_p);
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
module ZebuClockDetectFront_91(stable, posReady, in_p);
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
module ZebuClockDetectFront_92(stable, posReady, in_n);
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
module ZebuClockDetectFront_93(stable, posReady, in_p);
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
module ZebuClockDetectFront_94(stable, posReady, in_p);
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
module ZebuClockDetectFront_95(stable, posReady, in_p);
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
module ZebuClockDetectFront_96(stable, posReady, in_p);
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
module ZebuClockDetectFront_97(stable, posReady, in_p);
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
