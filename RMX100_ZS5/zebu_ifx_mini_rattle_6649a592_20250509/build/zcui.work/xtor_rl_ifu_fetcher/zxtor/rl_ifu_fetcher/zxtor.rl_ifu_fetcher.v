
`timescale 1 ns / 10 ps

/* Source file "/remote/us01sgnfs00727/arc_fpga/moyanz/Ratter3/template/dw_dbp/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/RTL/rl_ifu_fetcher.sv", line 33 */
`timescale 1 ns / 10 ps

(* SIMON_CSA_PROTECT = 1 *) 
module rl_ifu_fetcher(fa0_req, fa0_addr, fa_offset, f0_id, f0_id_valid, ftb_idle, f1_addr0_r, f1_offset_r, f0_pred_target, f1_mem_target, f1_mem_target_r, ifu_pmp_addr0, ifu_pma_addr0, ftb_top_id, br_req_ifu, br_restart_pc, fch_pc_nxt, fch_restart, fch_target, fch_stop_r, ifu_idle_r, ftb_serializing, ftb_ic_going_idle, ic_idle, iccm_idle, f1_mem_target_mispred_r, halt_fsm_in_rst, clk, rst_a);
	parameter		cclock		= "";
	parameter		zemi3_reserved_edge_enable
						= "";
	parameter		zemi3_reserved_debug
						= "";

	wire			uclock;
	wire			ureset;
	wire			zemi3_asyncStopClock;
	wire			zemi3_readyForClock;
	wire			posReady;
	wire			sclk_change;
	wire			posReady_0;
	wire			sclk_change_0;
	wire			posReady_1;
	wire			sclk_change_1;
	wire			posReady_2;
	wire			sclk_change_2;
	wire			posReady_3;
	wire			sclk_change_3;
	wire			posReady_4;
	wire			sclk_change_4;
	wire			posReady_5;
	wire			sclk_change_5;
	wire			posReady_6;
	wire			sclk_change_6;
	wire			rst_a_No_FB;
	output			fa0_req;
	reg			fa0_req;
	output	[31:2]		fa0_addr;
	reg	[31:2]		fa0_addr;
	output			fa_offset;
	reg			fa_offset;
	output	[1:0]		f0_id;
	reg	[1:0]		f0_id;
	output			f0_id_valid;
	reg			f0_id_valid;
	output			ftb_idle;
	reg			ftb_idle;
	output	[31:2]		f1_addr0_r;
	reg	[31:2]		f1_addr0_r;
	output			f1_offset_r;
	reg			f1_offset_r;
	output	[3:0]		f0_pred_target;
	input	[3:0]		f1_mem_target;
	output	[3:0]		f1_mem_target_r;
	reg	[3:0]		f1_mem_target_r;
	output	[31:2]		ifu_pmp_addr0;
	output	[31:2]		ifu_pma_addr0;
	output	[1:0]		ftb_top_id;
	input			br_req_ifu;
	input	[31:1]		br_restart_pc;
	input	[31:1]		fch_pc_nxt;
	input			fch_restart;
	input	[31:1]		fch_target;
	input			fch_stop_r;
	output			ifu_idle_r;
	reg			ifu_idle_r;
	output			ftb_serializing;
	reg			ftb_serializing;
	output			ftb_ic_going_idle;
	reg			ftb_ic_going_idle;
	input			ic_idle;
	input			iccm_idle;
	output			f1_mem_target_mispred_r;
	reg			f1_mem_target_mispred_r;
	input			halt_fsm_in_rst;
	input			clk;

	(* Zemi3AsyncResetNode, Zemi3AsyncResetNode, Zemi3AsyncResetNode, Zemi3AsyncResetNode *) 
	input			rst_a;
	reg	[1:0]		ftb_valid_r;

	reg			ftb_offset_r[1:0];
	reg	[31:2]		ftb_fa0_r[1:0];
	reg	[1:0]		ftb_valid_nxt;
	reg	[1:0]		ftb_fa0_valid_nxt;
	reg	[1:0]		ftb_wr_ptr_1h_r;
	reg	[1:0]		ftb_wr_ptr_1h_nxt;
	reg	[1:0]		ftb_rd_ptr_1h_r;
	reg	[1:0]		ftb_rd_ptr_1h_nxt;
	reg			ftb_rd_ptr_cg0;
	reg	[1:0]		ftb_insert_ptr;
	wire			ftb_rd_ptr;
	reg	[1:0]		ftb_rd_ptr_1h_p1;
	reg			f1_addr0_cg0;
	reg			f1_offset_nxt;
	reg	[3:0]		f1_mem_target_nxt;
	reg	[31:2]		f1_addr0_nxt;
	reg			fa_seq;
	reg			ftb_write;
	reg			ftb_write_fast;
	reg			ftb_read;
	reg			ftb_bypass;
	reg			ftb_write_valid_cg0;
	reg			ifu_idle_nxt;
	reg	[1:0]		ifu_idle_state_r;
	reg	[1:0]		ifu_idle_state_nxt;
	reg			f0_pred_targt_cg0;
	reg	[3:0]		f0_pred_target_r;
	reg	[3:0]		f0_pred_target_nxt;
	reg	[3:0]		f1_pred_target_r;
	reg			f1_mem_target_misp;
	reg			f1_pred_target_cg0;
	wire			ftb_full;
	wire			ifu_all_idle;
	wire			restart;
	localparam		IFU_STATE_DEFAULT
						= 2'b0;
	localparam		IFU_STATE_WAIT_IDLE
						= 2'b1;
	localparam		IFU_STATE_IDLE	= 2'b10;

	assign restart = fch_restart;
	assign ifu_all_idle = ((1'b1 & ic_idle) & iccm_idle);
	assign ftb_top_id = {{1 {1'b0}}, 1'b1};
	assign f0_pred_target = f0_pred_target_r;
	assign ifu_pmp_addr0 = f1_addr0_r;
	assign ifu_pma_addr0 = f1_addr0_r;
	assign zemi3_readyForClock = (~zemi3_asyncStopClock);
	assign zemi3_asyncStopClock = 1'b0;


	(* zemi3_internal_instance = 1 *) 
	rtlClockControl rtl_clock_syn_clock_control(
		.ureset				(ureset), 
		.readyForCclock			(1'b1));

	(* zemi3_internal_instance = 1 *) 
	zebu_reqsig_clock_driverclock z_dc(
		.o				(uclock));

	(* zemi3_internal_instance = 1 *) 
	rtlClockControl rtl_clock_dpi_clock_control(
		.readyForCclock			(zemi3_readyForClock));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_0 zebu_clk_detector_front(
		.stable				(uclock), 
		.posReady			(posReady), 
		.in_p				(clk));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed(
		.in				(posReady), 
		.out				(sclk_change), 
		.inDis				(posReady));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_1 zebu_clk_detector_front_0(
		.stable				(uclock), 
		.posReady			(posReady_0), 
		.in_p				(rst_a));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed_0(
		.in				(posReady_0), 
		.out				(sclk_change_0), 
		.inDis				(posReady_0));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_2 zebu_clk_detector_front_1(
		.stable				(uclock), 
		.posReady			(posReady_1), 
		.in_p				(clk));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed_1(
		.in				(posReady_1), 
		.out				(sclk_change_1), 
		.inDis				(posReady_1));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_3 zebu_clk_detector_front_2(
		.stable				(uclock), 
		.posReady			(posReady_2), 
		.in_p				(rst_a));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed_2(
		.in				(posReady_2), 
		.out				(sclk_change_2), 
		.inDis				(posReady_2));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_4 zebu_clk_detector_front_3(
		.stable				(uclock), 
		.posReady			(posReady_3), 
		.in_p				(clk));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed_3(
		.in				(posReady_3), 
		.out				(sclk_change_3), 
		.inDis				(posReady_3));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_5 zebu_clk_detector_front_4(
		.stable				(uclock), 
		.posReady			(posReady_4), 
		.in_p				(rst_a));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed_4(
		.in				(posReady_4), 
		.out				(sclk_change_4), 
		.inDis				(posReady_4));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_6 zebu_clk_detector_front_5(
		.stable				(uclock), 
		.posReady			(posReady_5), 
		.in_p				(clk));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed_5(
		.in				(posReady_5), 
		.out				(sclk_change_5), 
		.inDis				(posReady_5));

	(* zemi3_internal_instance = 1 *) 
	ZebuClockDetectFront_7 zebu_clk_detector_front_6(
		.stable				(uclock), 
		.posReady			(posReady_6), 
		.in_p				(rst_a));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_edge_detector z_ed_6(
		.in				(posReady_6), 
		.out				(sclk_change_6), 
		.inDis				(posReady_6));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_async_reset_cond zebu_bb_async_reset_cond(
		.in				(rst_a), 
		.out				(rst_a_No_FB));

	always @(*) begin : ftb_byp_PROC
	  fa0_req = 1'b0;
	  fa0_addr = f1_addr0_r;
	  fa_offset = 1'b0;
	  fa_seq = 1'b0;
	  f0_id = {{1 {1'b0}}, 1'b1};
	  f0_id_valid = 1'b1;
	  if (restart) begin
	    fa0_req = (~fch_stop_r);
	    fa0_addr = fch_target[31:2];
	    fa_offset = fch_target[1];
	    f0_id = {{1 {1'b0}}, 1'b1};
	    f0_id_valid = (~fch_stop_r);
	  end
	  else if (br_req_ifu) begin
	    fa0_req = 1'b1;
	    fa0_addr = br_restart_pc[31:2];
	    fa_offset = br_restart_pc[1];
	    fa_seq = (~br_req_ifu);
	    f0_id = {{1 {1'b0}}, 1'b1};
	    f0_id_valid = 1'b1;
	  end
	  else
	    begin
	      fa0_req = ((~fch_stop_r) & (~halt_fsm_in_rst));
	      fa0_addr = fch_pc_nxt[31:2];
	      fa_offset = fch_pc_nxt[1];
	      f0_id = {{1 {1'b0}}, 1'b1};
	      f0_id_valid = ((~fch_stop_r) & (~halt_fsm_in_rst));
	    end
	end
	always @(*) begin : ftb_mem_target_PROC
	  f0_pred_targt_cg0 = 1'b0;
	  f0_pred_target_nxt = f0_pred_target_r;
	  f1_pred_target_cg0 = fa0_req;
	  f1_mem_target_misp = (f1_pred_target_r != f1_mem_target);
	  if (f1_mem_target_misp) begin
	    f0_pred_targt_cg0 = 1'b1;
	    f0_pred_target_nxt = f1_mem_target;
	  end
	end
	always @(*) begin : ftb_idle_fsm_PROC
	  ftb_idle = ifu_idle_r;
	  ftb_serializing = 1'b0;
	  ftb_ic_going_idle = 1'b0;
	  ifu_idle_nxt = ifu_idle_r;
	  ifu_idle_state_nxt = ifu_idle_state_r;
	  case (ifu_idle_state_r)
	    IFU_STATE_DEFAULT: begin
	      if (fch_restart & fch_stop_r) begin
		ifu_idle_state_nxt = IFU_STATE_WAIT_IDLE;
	      end
	    end
	    IFU_STATE_WAIT_IDLE: begin
	      ftb_idle = 1'b1;
	      if (fch_restart & (~fch_stop_r)) begin
		ifu_idle_state_nxt = IFU_STATE_DEFAULT;
	      end
	      else
		begin
		  if (ifu_all_idle == 1'b1) begin
		    ifu_idle_nxt = 1'b1;
		    ftb_ic_going_idle = 1'b1;
		    ifu_idle_state_nxt = IFU_STATE_IDLE;
		  end
		end
	    end
	    default: begin
	      ftb_idle = 1'b1;
	      ifu_idle_nxt = ifu_all_idle;
	      if (fch_restart & (~fch_stop_r)) begin
		ifu_idle_nxt = 1'b0;
		ifu_idle_state_nxt = IFU_STATE_DEFAULT;
	      end
	    end
	  endcase
	end
	always @(*) begin : f1_addr_PROC
	  f1_addr0_cg0 = fa0_req;
	  f1_addr0_nxt = fa0_addr;
	  f1_offset_nxt = fa_offset;
	  f1_mem_target_nxt = f1_mem_target;
	end
	initial begin
	end

	(* zemi3_no_SCO_reason = "File: /remote/us01sgnfs00727/arc_fpga/moyanz/Ratter3/template/dw_dbp/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/RTL/rl_ifu_fetcher.sv Line: 403 Reason: XTOR FM FLOW" *) 
	always @(posedge uclock or posedge ureset) if (ureset) begin
	end
	else
	  begin
	    if (sclk_change || sclk_change_0) begin
	      begin
		begin : f1_addr_regs_PROC_0
		  if ((rst_a_No_FB ==(* Zemi3AsyncResetCond *)  1'b1) || (rst_a ==(* Zemi3AsyncResetCond *)  1'b1)) begin
		    f1_addr0_r <= {30 {1'b0}};
		    f1_offset_r <= 1'b0;
		    f1_mem_target_r <= 4'b0;
		  end
		  else
		    begin
		      if (f1_addr0_cg0 == 1'b1) begin
			f1_addr0_r <= f1_addr0_nxt;
			f1_offset_r <= f1_offset_nxt;
			f1_mem_target_r <= f1_mem_target_nxt;
		      end
		    end
		end
	      end
	    end
	  end
	initial begin
	end

	(* zemi3_no_SCO_reason = "File: /remote/us01sgnfs00727/arc_fpga/moyanz/Ratter3/template/dw_dbp/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/RTL/rl_ifu_fetcher.sv Line: 424 Reason: XTOR FM FLOW" *) 
	always @(posedge uclock or posedge ureset) if (ureset) begin
	end
	else
	  begin
	    if (sclk_change_1 || sclk_change_2) begin
	      begin
		begin : ftb_idle_regs_PROC_0
		  if ((rst_a_No_FB ==(* Zemi3AsyncResetCond *)  1'b1) || (rst_a ==(* Zemi3AsyncResetCond *)  1'b1)) begin
		    ifu_idle_state_r <= IFU_STATE_IDLE;
		    ifu_idle_r <= 1'b0;
		  end
		  else
		    begin
		      ifu_idle_state_r <= ifu_idle_state_nxt;
		      ifu_idle_r <= ifu_idle_nxt;
		    end
		end
	      end
	    end
	  end
	initial begin
	end

	(* zemi3_no_SCO_reason = "File: /remote/us01sgnfs00727/arc_fpga/moyanz/Ratter3/template/dw_dbp/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/RTL/rl_ifu_fetcher.sv Line: 438 Reason: XTOR FM FLOW" *) 
	always @(posedge uclock or posedge ureset) if (ureset) begin
	end
	else
	  begin
	    if (sclk_change_3 || sclk_change_4) begin
	      begin
		begin : f1_pred_target_regs_PROC_0
		  if ((rst_a_No_FB ==(* Zemi3AsyncResetCond *)  1'b1) || (rst_a ==(* Zemi3AsyncResetCond *)  1'b1)) begin
		    f0_pred_target_r <= 4'b1;
		    f1_pred_target_r <= 4'b1;
		  end
		  else
		    begin
		      if (f1_pred_target_cg0 == 1'b1) begin
			f0_pred_target_r <= f0_pred_target_nxt;
		      end
		      if (f1_pred_target_cg0 == 1'b1) begin
			f1_pred_target_r <= f0_pred_target_r;
		      end
		    end
		end
	      end
	    end
	  end
	initial begin
	end

	(* zemi3_no_SCO_reason = "File: /remote/us01sgnfs00727/arc_fpga/moyanz/Ratter3/template/dw_dbp/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/RTL/rl_ifu_fetcher.sv Line: 459 Reason: XTOR FM FLOW" *) 
	always @(posedge uclock or posedge ureset) if (ureset) begin
	end
	else
	  begin
	    if (sclk_change_5 || sclk_change_6) begin
	      begin
		begin
		  if ((rst_a_No_FB ==(* Zemi3AsyncResetCond *)  1'b1) || (rst_a ==(* Zemi3AsyncResetCond *)  1'b1)) begin
		    f1_mem_target_mispred_r <= 1'b0;
		  end
		  else
		    begin
		      f1_mem_target_mispred_r <= f1_mem_target_misp;
		    end
		end
	      end
	    end
	  end
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
module ZebuClockDetectFront_0(stable, posReady, in_p);
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

(* syn_noprune = 1, zebu_zemi3_no_inline = 1 *) 
module ZebuClockDetectFront_1(stable, posReady, in_p);
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
module ZebuClockDetectFront_2(stable, posReady, in_p);
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
module ZebuClockDetectFront_3(stable, posReady, in_p);
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
module ZebuClockDetectFront_4(stable, posReady, in_p);
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
module ZebuClockDetectFront_5(stable, posReady, in_p);
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
module ZebuClockDetectFront_6(stable, posReady, in_p);
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
module ZebuClockDetectFront_7(stable, posReady, in_p);
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
module zebu_bb_async_reset_cond(in, out);
/* eve no_synthvout */
	input			in;
	output			out;

	reg			out;
endmodule
