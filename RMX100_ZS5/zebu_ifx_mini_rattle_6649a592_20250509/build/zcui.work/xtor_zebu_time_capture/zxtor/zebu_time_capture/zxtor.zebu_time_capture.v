`timescale 1 ns / 10 ps

/* Source file "/remote/sdgregrsnapshot2/NB/linux64_VCS2021.09.2.ZEBU.B4.1/radify-src/unizfe/verilog/zebu_time_capture.sv", line 4 */
`timescale 1 ns / 10 ps

(* ignore_time_scale = 1, zebu_model = 1, zebu_lp_internal_node = 1, zemi3_SCO_kicked_in = "File: /remote/sdgregrsnapshot2/NB/linux64_VCS2021.09.2.ZEBU.B4.1/radify-src/unizfe/verilog/zebu_time_capture.sv Line: 4" *) 
module zebu_time_capture(zebu_zcei_composite_clk);
	parameter		cclock		= "";
	parameter		zemi3_reserved_edge_enable
						= "";
	parameter		zemi3_reserved_debug
						= "";

	wire			zebu_sendtime_hw_tx_ready_0;
	wire			zebu_sendtime_sw_rx_ready_0;
	wire	[4095:0]	zebu_sendtime_msg_out_0;
	wire			zebu_sendtime_flush;
	wire			uclock;
	wire			ureset;
	wire	[2:0]		zemiStatus;
	reg	[2:0]		zemiControl;
	wire			user_b2b;
	reg			zemi3_anyExportActive;
	wire			b2b_readyForClock;
	wire			zemi_control_sw_tx_ready;
	reg			zemi_control_hw_rx_ready;
	wire	[5:0]		zemi_control_msg_in;
	wire			zemi_control_rx_complete_;
	reg			zemi_status_hw_tx_ready;
	wire			zemi_status_sw_rx_ready;
	wire	[2:0]		zemi_status_msg_out;
	wire			zemi_status_tx_complete_;
	wire	[2:0]		zemi_control_mask;
	wire	[2:0]		zemi_control_value;
	reg	[19:0]		AutoFlushCount;
	wire			zemi3_asyncStopClock;
	wire			zemi3_readyForClock;

	(* Zemi3UseCurrentValue, zebu_protected = 1 *) 
	reg	[63:0]		ts_cur_time;
	reg			test_expr_0;
	wire			zemi3_internalEvent;
	wire			zemi3_anySampledOrInternalEvent;
	reg	[1:0]		imp_state_net_4;

	(* transactor_cclock_port = "zebu_zcei_composite_clk" *) 
	input			zebu_zcei_composite_clk;

	(* transactor_cclock_port = "zebu_zcei_composite_clk" *) 
	reg			zebu_zcei_composite_clk_0;
	reg			time_capture_enable;
	reg			time_capture_enable_0;
	wire	[(24 - 1):0]	global_delay;
	reg	[23:0]		global_delay_0;
	reg	[(64 - 1):0]	composite_cycle;
	reg	[63:0]		composite_cycle_0;

	(* Zemi3UseCurrentValue = 1 *) 
	wire	[(64 - 1):0]	composite_cycle_tmp;
	reg	[1:0]		imp_state_net;
	reg	[1:0]		imp_state_net_0;
	wire			fNeedEval;
	wire			zebu_zcei_composite_clk_change;
	wire			zebu_zcei_composite_clk_change_0;
	wire			zebu_zcei_composite_clk_change_1;
	reg			zebu_sendtime_readyForClock;
	reg			zebu_sendtime_hw_tx_ready;

	(* Zemi3UseCurrentValue *) 
	wire			zebu_sendtime_sw_rx_ready;
	wire	[23:0]		zebu_sendtime_msg_out;
	wire			zebu_sendtime_tx_complete_;
	reg	[23:0]		zebu_sendtime_arg_gd_i_;

	(* internal_runtime_debug_access = 1, zebu_protected = 1 *) 
	reg	[63:0]		zebu_sendtime_tx_wait_counter;

	(* internal_runtime_debug_access = 1, zebu_protected = 1 *) 
	reg	[63:0]		zebu_sendtime_tx_wait_counter_0;
	reg			composite_clock_enable;
	reg			composite_clock_enable_0;
	reg			composite_clock_enable_1;
	reg			init_enable;
	reg			zevent_readyForClock;
	reg	[1:0]		imp_state_net_1;
	reg	[1:0]		imp_state_net_2;
	wire			composite_clock_enable_change;
	reg			zemi3_anySampledOrInternalEvent_0;
	reg			zevent_readyForClock_0;
	reg			zebu_control_exportActive;
	wire			zebu_control_sw_tx_ready;
	reg			zebu_control_hw_rx_ready;
	wire	[1:0]		zebu_control_msg_in;
	wire			zebu_control_rx_complete_;
	reg			zebu_control_hw_tx_ready;
	wire			zebu_control_sw_rx_ready;
	wire	[127:0]		zebu_control_msg_out;
	wire			zebu_control_tx_complete_;

	(* internal_runtime_debug_access = 1, zebu_protected = 1 *) 
	reg	[63:0]		zebu_control_tx_wait_counter;
	bit			zebu_control_arg_operation;
	wire			zebu_control_arg_operation_i_;
	bit			zebu_control_arg_en;
	wire			zebu_control_arg_en_i_;
	bit	[63:0]		zebu_control_arg_gd;
	reg	[63:0]		zebu_control_arg_gd_o_;
	bit	[63:0]		zebu_control_arg_gc;
	reg	[63:0]		zebu_control_arg_gc_o_;
	bit			zebu_control_operation;
	bit			zebu_control_en;
	bit	[63:0]		zebu_control_gd;
	bit	[63:0]		zebu_control_gc;
	reg			test_expr;
	reg	[1:0]		imp_state_net_3;

	assign composite_cycle_tmp = composite_cycle;
	assign zebu_control_rx_complete_ = (zebu_control_sw_tx_ready & zebu_control_hw_rx_ready);
	assign zebu_control_tx_complete_ = (zebu_control_hw_tx_ready & zebu_control_sw_rx_ready);
	assign zebu_control_arg_operation_i_ = zebu_control_msg_in[0];
	assign zebu_control_arg_en_i_ = zebu_control_msg_in[1];
	assign zebu_control_msg_out[63:0] = zebu_control_arg_gd_o_;
	assign zebu_control_msg_out[127:64] = zebu_control_arg_gc_o_;
	assign zebu_sendtime_tx_complete_ = (zebu_sendtime_hw_tx_ready & zebu_sendtime_sw_rx_ready);
	assign zebu_sendtime_msg_out[23:0] = zebu_sendtime_arg_gd_i_;
	assign zemiStatus[0] = zebu_control_exportActive;
	assign zemiStatus[1] = 1'b0;
	assign zemiStatus[2] = 1'b0;
	assign zebu_sendtime_flush = zemiControl[2];
	assign user_b2b = zemiControl[1];
	assign zemi3_anyExportActive = zemiStatus[0];
	assign b2b_readyForClock = ((~user_b2b) | zemi3_anyExportActive);
	assign zemi_control_rx_complete_ = (zemi_control_sw_tx_ready & zemi_control_hw_rx_ready);
	assign zemi_status_tx_complete_ = (zemi_status_hw_tx_ready & zemi_status_sw_rx_ready);
	assign zemi_status_msg_out = zemiStatus;
	assign zemi_control_mask = zemi_control_msg_in[5:3];
	assign zemi_control_value = zemi_control_msg_in[2:0];
	assign eVe_protect_sel = zebu_control_msg_in[0];
	assign eVe_protect_sel_0 = zemi_control_msg_in[0];
	assign zemi3_readyForClock = (~zemi3_asyncStopClock);
	assign zebu_zcei_composite_clk_change = (zebu_zcei_composite_clk && (!zebu_zcei_composite_clk_0));
	assign zebu_zcei_composite_clk_change_0 = ((!zebu_zcei_composite_clk) && zebu_zcei_composite_clk_0);
	assign zebu_zcei_composite_clk_change_1 = (zebu_zcei_composite_clk_change || zebu_zcei_composite_clk_change_0);
	assign fNeedEval = ((imp_state_net_0[1] == 1'b1) || ((imp_state_net_0[0] == 1'b1) && zebu_zcei_composite_clk_change_1));
	assign composite_clock_enable_change = (composite_clock_enable != composite_clock_enable_0);
	assign zemi3_internalEvent = (((imp_state_net[1] || (zebu_control_rx_complete_ && imp_state_net_3[0])) || imp_state_net_3[1]) || imp_state_net_4[1]);
	assign zemi3_anySampledOrInternalEvent = zemi3_internalEvent;
	assign zemi3_asyncStopClock = ((init_enable || imp_state_net_1[1]) || zemi3_internalEvent);


	(* zemi3_internal_instance = 1 *) 
	zebu_bb_add_zview z_protect_add_zview(
		.in				(zebu_control_tx_wait_counter));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_add_zview z_protect_add_zview_0(
		.in				(zebu_sendtime_tx_wait_counter));

	(* zemi3_internal_instance = 1 *) 
	zemi3OutPortBuffer_169_4096_24 zebu_sendtime_portbuffer(
		.flush				(zebu_sendtime_flush), 
		.transmitReady			(zebu_sendtime_hw_tx_ready), 
		.receiveReady			(zebu_sendtime_sw_rx_ready), 
		.message0			(zebu_sendtime_msg_out), 
		.hw_tx_ready			(zebu_sendtime_hw_tx_ready_0), 
		.sw_rx_ready			(zebu_sendtime_sw_rx_ready_0), 
		.msg_out			(zebu_sendtime_msg_out_0));

	(* zemi3_internal_instance = 1 *) 
	rtlClockControl rtl_clock_b2b_clock_control(
		.ureset				(ureset), 
		.readyForCclock			(b2b_readyForClock));

	(* zemi3_internal_instance = 1 *) 
	zebu_reqsig_clock_driverclock z_dc(
		.o				(uclock));

	(* zemi3_internal_instance = 1 *) 
	zceiMessageInPort_2 #(.Pwidth(2)) zebu_control_in_port(
		.transmitReady			(zebu_control_sw_tx_ready), 
		.receiveReady			(zebu_control_hw_rx_ready), 
		.message			(zebu_control_msg_in));

	(* zemi3_internal_instance = 1 *) 
	zceiMessageOutPort_128 #(.Pwidth(128)) zebu_control_out_port(
		.transmitReady			(zebu_control_hw_tx_ready), 
		.receiveReady			(zebu_control_sw_rx_ready), 
		.message			(zebu_control_msg_out));

	(* zemi3_internal_instance = 1 *) 
	zceiMessageOutPort_4096 #(.Pwidth(4096)) zebu_sendtime_out_port(
		.transmitReady			(zebu_sendtime_hw_tx_ready_0), 
		.receiveReady			(zebu_sendtime_sw_rx_ready_0), 
		.message			(zebu_sendtime_msg_out_0));

	(* zemi3_internal_instance = 1 *) 
	zceiMessageInPort_6 #(.Pwidth(6)) zemi_control_in_port(
		.transmitReady			(zemi_control_sw_tx_ready), 
		.receiveReady			(zemi_control_hw_rx_ready), 
		.message			(zemi_control_msg_in));

	(* zemi3_internal_instance = 1 *) 
	zceiMessageOutPort_3 #(.Pwidth(3)) zemi_status_out_port(
		.transmitReady			(zemi_status_hw_tx_ready), 
		.receiveReady			(zemi_status_sw_rx_ready), 
		.message			(zemi_status_msg_out));

	(* zemi3_internal_instance = 1 *) 
	rtlClockControl rtl_clock_syn_clock_control(
		.readyForCclock			(1'b1));

	(* zemi3_internal_instance = 1 *) 
	rtlClockControl rtl_clock_dpi_clock_control(
		.readyForCclock			(zemi3_readyForClock));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_ts_cur_time z_protect_time(
		.ts_time			(ts_cur_time));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_sample_2_1 z_sample_clock_uncond(
		.clk				(uclock), 
		.signal				(imp_state_net), 
		.signal_sample			(imp_state_net_0));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_sample_2_1 z_sample_clock_uncond_0(
		.clk				(uclock), 
		.signal				(imp_state_net_1), 
		.signal_sample			(imp_state_net_2));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_64_1 z_sample_clock_uncond_1(
		.clk				(uclock), 
		.signal				(composite_cycle));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_1_1 z_sample_clock_uncond_2(
		.clk				(uclock), 
		.signal				(zebu_sendtime_readyForClock));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_1_1 z_sample_clock_uncond_3(
		.clk				(uclock), 
		.signal				(zebu_sendtime_hw_tx_ready));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_sample_64_1 z_sample_clock_uncond_4(
		.clk				(uclock), 
		.signal				(zebu_sendtime_tx_wait_counter), 
		.signal_sample			(zebu_sendtime_tx_wait_counter_0));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_24_1 z_sample_clock_uncond_5(
		.clk				(uclock), 
		.signal				(zebu_sendtime_arg_gd_i_[23:0]));

	(* zemi3_internal_instance = 1 *) 
	zebu_bb_sample_clk_uncond_1_1 z_sample_clock_uncond_6(
		.clk				(uclock), 
		.signal				(zevent_readyForClock_0));
	zebu_bb_gdelay zebu_bb_gdelay(global_delay);
	`ifdef ZEMI_INLINED

	task zebu_control;
	input bit		operation;
	input bit		en;
	output bit
		[(64 - 1):0]	gd;
	output bit
		[(64 - 1):0]	gc;
	endtask
	export "DPI-C"  task zebu_control;
	`endif // ZEMI_INLINED
	`ifdef ZEMI_INLINED
	`endif // ZEMI_INLINED

	initial begin
	  composite_cycle <= 0;
	end
	initial begin
	  zevent_readyForClock <= 1'b1;
	end
	initial begin
	  zevent_readyForClock_0 <= 1'b1;
	end
	initial begin
	  zebu_sendtime_readyForClock <= 1'b1;
	  zebu_sendtime_hw_tx_ready <= 1'b0;
	  zebu_sendtime_arg_gd_i_ = 24'b0;
	  zebu_sendtime_tx_wait_counter <= 64'b0;
	end
	initial begin
	  zebu_control_hw_rx_ready <= 1'b1;
	  zebu_control_hw_tx_ready <= 1'b0;
	  zebu_control_tx_wait_counter <= 64'b0;
	  zebu_control_exportActive <= 1'b0;
	end
	initial begin
	  zemiControl <= 3'b0;
	  zemi_control_hw_rx_ready <= 1'b1;
	  zemi_status_hw_tx_ready <= 1'b0;
	end
	initial begin
	  AutoFlushCount <= 1048575;
	end
	initial begin
	end

	(* zemi3_no_SCO_reason = "File: zebu_time_capture_guts.sv Line: 46 Reason: no sampled event found" *) 
	always @(posedge uclock or posedge ureset) if (ureset) begin
	  begin
	    begin : imp_state_scope
	      begin
		begin
		  init_enable = 1'b1;
		  begin
		    if (composite_clock_enable == 1'b0) begin
		      zevent_readyForClock <= 1'b0;
		      begin
			disable imp_state_scope;
		      end
		    end
		  end
		  init_enable = 1'b0;
		end
	      end
	    end
	  end
	end
	else
	  begin
	    if (init_enable && (!zemi3_anySampledOrInternalEvent)) begin : imp_state_scope_0
	      begin
		zevent_readyForClock <= 1'b1;
		if (composite_clock_enable == 1'b0) begin
		  zevent_readyForClock <= 1'b0;
		  begin
		    disable imp_state_scope_0;
		  end
		end
		init_enable = 1'b0;
	      end
	    end
	  end
	initial begin
	  begin
	    imp_state_net <= 2'b1;
	  end
	end
	always @(*) if (ureset) begin
	end
	else
	  begin
	    begin
	      zebu_sendtime_hw_tx_ready <= 1'b0;
	    end
	    if (fNeedEval) begin
	      case (1'b1)// synopsys parallel_case full_case
		imp_state_net_0[0]: begin
		  begin : imp_state_scope_1
		    begin
		      begin
			if (time_capture_enable_0) begin
			  zebu_sendtime_readyForClock <= 1'b0;
			  zebu_sendtime_hw_tx_ready <= 1'b0;
			  if (!zebu_sendtime_sw_rx_ready) begin
			    zebu_sendtime_tx_wait_counter <= (zebu_sendtime_tx_wait_counter_0 + 1);
			    begin
			      imp_state_net <= 2'b10;
			      disable imp_state_scope_1;
			    end
			  end
			  zebu_sendtime_arg_gd_i_[23:0] = global_delay_0;
			  zebu_sendtime_hw_tx_ready <= 1'b1;
			  zebu_sendtime_readyForClock <= 1'b1;
			end
			composite_cycle <= (composite_cycle_0 + 1);
		      end
		      begin
			imp_state_net <= 2'b1;
			disable imp_state_scope_1;
		      end
		    end
		  end
		end
		imp_state_net_0[1]: begin
		  begin : imp_state_scope_2
		    begin
		      if (!zebu_sendtime_sw_rx_ready) begin
			zebu_sendtime_tx_wait_counter <= (zebu_sendtime_tx_wait_counter_0 + 1);
			begin
			  imp_state_net <= 2'b10;
			  disable imp_state_scope_2;
			end
		      end
		      zebu_sendtime_arg_gd_i_[23:0] = global_delay_0;
		      zebu_sendtime_hw_tx_ready <= 1'b1;
		      zebu_sendtime_readyForClock <= 1'b1;
		      composite_cycle <= (composite_cycle_0 + 1);
		      begin
			imp_state_net <= 2'b1;
			disable imp_state_scope_2;
		      end
		    end
		  end
		end
	      endcase
	    end
	  end
	initial begin
	  begin
	    imp_state_net_1 <= 2'b1;
	  end
	end
	always @(*) if (ureset) begin
	end
	else
	  begin
	    begin
	    end
	    case (1'b1)// synopsys parallel_case full_case
	      imp_state_net_2[0]: begin
		if (composite_clock_enable_change) begin : imp_state_scope_3
		  begin
		    begin
		      if (composite_clock_enable == 1'b0) begin
			zevent_readyForClock_0 <= 1'b0;
			begin
			  imp_state_net_1 <= 2'b10;
			  disable imp_state_scope_3;
			end
		      end
		    end
		    begin
		      imp_state_net_1 <= 2'b1;
		      disable imp_state_scope_3;
		    end
		  end
		end
	      end
	      imp_state_net_2[1]: begin
		if (!zemi3_anySampledOrInternalEvent_0) begin : imp_state_scope_4
		  begin
		    zevent_readyForClock_0 <= 1'b1;
		    if (composite_clock_enable_1 == 1'b0) begin
		      zevent_readyForClock_0 <= 1'b0;
		      begin
			imp_state_net_1 <= 2'b10;
			disable imp_state_scope_4;
		      end
		    end
		    begin
		      imp_state_net_1 <= 2'b1;
		      disable imp_state_scope_4;
		    end
		  end
		end
	      end
	    endcase
	  end
	initial begin
	  begin
	    imp_state_net_3 <= 2'b1;
	  end
	end

	(* zemi3_no_SCO_reason = "File: zebu_time_capture_guts.sv Line: 58 Reason: no sampled event found, and no sampled event found" *) 
	always @(posedge uclock or posedge ureset) if (ureset) begin
	end
	else
	  begin
	    begin
	    end
	    case (1'b1)// synopsys parallel_case full_case
	      imp_state_net_3[0]: begin
		if (zebu_control_rx_complete_) begin : imp_state_scope_5
		  begin
		    begin
		      zebu_control_hw_rx_ready <= 1'b0;
		      zebu_control_exportActive <= 1'b1;
		      zebu_control_arg_operation = zebu_control_arg_operation_i_;
		      zebu_control_arg_en = zebu_control_arg_en_i_;
		      begin
			zebu_control_operation = zebu_control_arg_operation;
			zebu_control_en = zebu_control_arg_en;
			begin : zebu_control_body1
			  if (zebu_control_operation == 1'b0) begin
			    composite_clock_enable = zebu_control_en;
			    zebu_control_gd = ts_cur_time;
			    zebu_control_gc = composite_cycle_tmp;
			  end
			  else
			    begin
			      time_capture_enable = zebu_control_en;
			      zebu_control_gd = ts_cur_time;
			      zebu_control_gc = composite_cycle_tmp;
			    end
			end
			zebu_control_arg_gd = zebu_control_gd;
			zebu_control_arg_gc = zebu_control_gc;
		      end
		      zebu_control_arg_gd_o_[63:0] = zebu_control_arg_gd;
		      zebu_control_arg_gc_o_[63:0] = zebu_control_arg_gc;
		      zebu_control_exportActive <= 1'b0;
		      zebu_control_hw_tx_ready <= 1'b1;
		      begin
			test_expr = 1'b1;
			begin
			  zebu_control_tx_wait_counter <= (zebu_control_tx_wait_counter + 1);
			  begin
			    imp_state_net_3 <= 2'b10;
			    disable imp_state_scope_5;
			  end
			end
		      end
		    end
		  end
		end
	      end
	      imp_state_net_3[1]: begin
		begin : imp_state_scope_6
		  begin
		    test_expr = (!zebu_control_tx_complete_);
		    if (test_expr) begin
		      zebu_control_tx_wait_counter <= (zebu_control_tx_wait_counter + 1);
		      begin
			imp_state_net_3 <= 2'b10;
			disable imp_state_scope_6;
		      end
		    end
		    zebu_control_hw_tx_ready <= 1'b0;
		    zebu_control_hw_rx_ready <= 1'b1;
		    begin
		      imp_state_net_3 <= 2'b1;
		      disable imp_state_scope_6;
		    end
		  end
		end
	      end
	    endcase
	  end
	initial begin
	  begin
	    imp_state_net_4 <= 2'b1;
	  end
	end

	(* zemi3_no_SCO_reason = "File: /remote/sdgregrsnapshot2/NB/linux64_VCS2021.09.2.ZEBU.B4.1/radify-src/unizfe/verilog/zebu_time_capture.sv Line: 4 Reason: no sampled event found", zemi3_no_SCO_reason = "File:  Line: 0 Reason: no sampled event found" *) 
	always @(posedge uclock or posedge ureset) if (ureset) begin
	end
	else
	  begin
	    begin
	    end
	    case (1'b1)// synopsys parallel_case full_case
	      imp_state_net_4[0]: begin
		begin : imp_state_scope_7
		  begin
		    if (zemi_control_rx_complete_) begin
		      zemi_control_hw_rx_ready <= 1'b0;
		      zemiControl <= ((zemiControl & (~zemi_control_mask)) | (zemi_control_value & zemi_control_mask));
		      zemi_status_hw_tx_ready <= 1'b1;
		      begin
			test_expr_0 = 1'b1;
			begin
			  begin
			    imp_state_net_4 <= 2'b10;
			    disable imp_state_scope_7;
			  end
			end
		      end
		    end
		    begin
		      imp_state_net_4 <= 2'b1;
		      disable imp_state_scope_7;
		    end
		  end
		end
	      end
	      imp_state_net_4[1]: begin
		begin : imp_state_scope_8
		  begin
		    test_expr_0 = (!zemi_status_tx_complete_);
		    if (test_expr_0) begin
		      begin
			imp_state_net_4 <= 2'b10;
			disable imp_state_scope_8;
		      end
		    end
		    zemi_status_hw_tx_ready <= 1'b0;
		    zemi_control_hw_rx_ready <= 1'b1;
		    begin
		      imp_state_net_4 <= 2'b1;
		      disable imp_state_scope_8;
		    end
		  end
		end
	      end
	    endcase
	    begin
	      begin
		begin
		  if (zemiControl[2]) begin
		    AutoFlushCount <= 1048575;
		    zemiControl[2] <= 1'b0;
		  end
		  else if (AutoFlushCount == 0) begin
		    zemiControl[2] <= 1'b1;
		  end
		  else begin
		    AutoFlushCount <= (AutoFlushCount - 1);
		  end
		end
	      end
	    end
	  end
	always @(posedge uclock) begin
	  imp_state_net_0 <= imp_state_net;
	end
	always @(posedge uclock) begin
	  imp_state_net_2 <= imp_state_net_1;
	end
	always @(posedge uclock) if (ureset || (!zemi3_anySampledOrInternalEvent)) begin
	  global_delay_0 <= global_delay;
	  composite_cycle_0 <= composite_cycle;
	end
	always @(posedge uclock) begin
	  zemi3_anySampledOrInternalEvent_0 <= zemi3_anySampledOrInternalEvent;
	  zebu_zcei_composite_clk_0 <= zebu_zcei_composite_clk;
	  composite_clock_enable_0 <= composite_clock_enable;
	  time_capture_enable_0 <= time_capture_enable;
	  zebu_sendtime_tx_wait_counter_0 <= zebu_sendtime_tx_wait_counter;
	  composite_clock_enable_1 <= composite_clock_enable;
	end
endmodule
`timescale 1 ns / 10 ps

/* Source file "/remote/sdgregrsnapshot2/NB/linux64_VCS2021.09.2.ZEBU.B4.1/radify-src/unizfe/verilog/zebu_bb_gdelay.v", line 2 */
`timescale 1 ns / 10 ps

(* zebu_model = 1 *) 
module zebu_bb_gdelay(out);
	output	[23:0]		out;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps
module zemi3OutPortBuffer_169_4096_24(flush, transmitReady, receiveReady, message0, hw_tx_ready, sw_rx_ready, msg_out);
/* eve no_synthvout */
	input			flush;
	input			transmitReady;
	output			receiveReady;
	input	[23:0]		message0;
	output			hw_tx_ready;
	input			sw_rx_ready;
	output	[4095:0]	msg_out;

	wire			tx_complete;
	wire			shared_tx_complete;
	reg			do_flush;
	reg	[31:0]		count;
	wire			uclock;
	wire			ureset;

	reg	[23:0]		msg_array[168:0];

	assign hw_tx_ready = ((count == 169) | do_flush);
	assign receiveReady = (!hw_tx_ready);
	assign tx_complete = (hw_tx_ready & sw_rx_ready);
	assign shared_tx_complete = (transmitReady & receiveReady);
	assign msg_out[23:0] = msg_array[0];
	assign msg_out[47:24] = msg_array[1];
	assign msg_out[71:48] = msg_array[2];
	assign msg_out[95:72] = msg_array[3];
	assign msg_out[119:96] = msg_array[4];
	assign msg_out[143:120] = msg_array[5];
	assign msg_out[167:144] = msg_array[6];
	assign msg_out[191:168] = msg_array[7];
	assign msg_out[215:192] = msg_array[8];
	assign msg_out[239:216] = msg_array[9];
	assign msg_out[263:240] = msg_array[10];
	assign msg_out[287:264] = msg_array[11];
	assign msg_out[311:288] = msg_array[12];
	assign msg_out[335:312] = msg_array[13];
	assign msg_out[359:336] = msg_array[14];
	assign msg_out[383:360] = msg_array[15];
	assign msg_out[407:384] = msg_array[16];
	assign msg_out[431:408] = msg_array[17];
	assign msg_out[455:432] = msg_array[18];
	assign msg_out[479:456] = msg_array[19];
	assign msg_out[503:480] = msg_array[20];
	assign msg_out[527:504] = msg_array[21];
	assign msg_out[551:528] = msg_array[22];
	assign msg_out[575:552] = msg_array[23];
	assign msg_out[599:576] = msg_array[24];
	assign msg_out[623:600] = msg_array[25];
	assign msg_out[647:624] = msg_array[26];
	assign msg_out[671:648] = msg_array[27];
	assign msg_out[695:672] = msg_array[28];
	assign msg_out[719:696] = msg_array[29];
	assign msg_out[743:720] = msg_array[30];
	assign msg_out[767:744] = msg_array[31];
	assign msg_out[791:768] = msg_array[32];
	assign msg_out[815:792] = msg_array[33];
	assign msg_out[839:816] = msg_array[34];
	assign msg_out[863:840] = msg_array[35];
	assign msg_out[887:864] = msg_array[36];
	assign msg_out[911:888] = msg_array[37];
	assign msg_out[935:912] = msg_array[38];
	assign msg_out[959:936] = msg_array[39];
	assign msg_out[983:960] = msg_array[40];
	assign msg_out[1007:984] = msg_array[41];
	assign msg_out[1031:1008] = msg_array[42];
	assign msg_out[1055:1032] = msg_array[43];
	assign msg_out[1079:1056] = msg_array[44];
	assign msg_out[1103:1080] = msg_array[45];
	assign msg_out[1127:1104] = msg_array[46];
	assign msg_out[1151:1128] = msg_array[47];
	assign msg_out[1175:1152] = msg_array[48];
	assign msg_out[1199:1176] = msg_array[49];
	assign msg_out[1223:1200] = msg_array[50];
	assign msg_out[1247:1224] = msg_array[51];
	assign msg_out[1271:1248] = msg_array[52];
	assign msg_out[1295:1272] = msg_array[53];
	assign msg_out[1319:1296] = msg_array[54];
	assign msg_out[1343:1320] = msg_array[55];
	assign msg_out[1367:1344] = msg_array[56];
	assign msg_out[1391:1368] = msg_array[57];
	assign msg_out[1415:1392] = msg_array[58];
	assign msg_out[1439:1416] = msg_array[59];
	assign msg_out[1463:1440] = msg_array[60];
	assign msg_out[1487:1464] = msg_array[61];
	assign msg_out[1511:1488] = msg_array[62];
	assign msg_out[1535:1512] = msg_array[63];
	assign msg_out[1559:1536] = msg_array[64];
	assign msg_out[1583:1560] = msg_array[65];
	assign msg_out[1607:1584] = msg_array[66];
	assign msg_out[1631:1608] = msg_array[67];
	assign msg_out[1655:1632] = msg_array[68];
	assign msg_out[1679:1656] = msg_array[69];
	assign msg_out[1703:1680] = msg_array[70];
	assign msg_out[1727:1704] = msg_array[71];
	assign msg_out[1751:1728] = msg_array[72];
	assign msg_out[1775:1752] = msg_array[73];
	assign msg_out[1799:1776] = msg_array[74];
	assign msg_out[1823:1800] = msg_array[75];
	assign msg_out[1847:1824] = msg_array[76];
	assign msg_out[1871:1848] = msg_array[77];
	assign msg_out[1895:1872] = msg_array[78];
	assign msg_out[1919:1896] = msg_array[79];
	assign msg_out[1943:1920] = msg_array[80];
	assign msg_out[1967:1944] = msg_array[81];
	assign msg_out[1991:1968] = msg_array[82];
	assign msg_out[2015:1992] = msg_array[83];
	assign msg_out[2039:2016] = msg_array[84];
	assign msg_out[2063:2040] = msg_array[85];
	assign msg_out[2087:2064] = msg_array[86];
	assign msg_out[2111:2088] = msg_array[87];
	assign msg_out[2135:2112] = msg_array[88];
	assign msg_out[2159:2136] = msg_array[89];
	assign msg_out[2183:2160] = msg_array[90];
	assign msg_out[2207:2184] = msg_array[91];
	assign msg_out[2231:2208] = msg_array[92];
	assign msg_out[2255:2232] = msg_array[93];
	assign msg_out[2279:2256] = msg_array[94];
	assign msg_out[2303:2280] = msg_array[95];
	assign msg_out[2327:2304] = msg_array[96];
	assign msg_out[2351:2328] = msg_array[97];
	assign msg_out[2375:2352] = msg_array[98];
	assign msg_out[2399:2376] = msg_array[99];
	assign msg_out[2423:2400] = msg_array[100];
	assign msg_out[2447:2424] = msg_array[101];
	assign msg_out[2471:2448] = msg_array[102];
	assign msg_out[2495:2472] = msg_array[103];
	assign msg_out[2519:2496] = msg_array[104];
	assign msg_out[2543:2520] = msg_array[105];
	assign msg_out[2567:2544] = msg_array[106];
	assign msg_out[2591:2568] = msg_array[107];
	assign msg_out[2615:2592] = msg_array[108];
	assign msg_out[2639:2616] = msg_array[109];
	assign msg_out[2663:2640] = msg_array[110];
	assign msg_out[2687:2664] = msg_array[111];
	assign msg_out[2711:2688] = msg_array[112];
	assign msg_out[2735:2712] = msg_array[113];
	assign msg_out[2759:2736] = msg_array[114];
	assign msg_out[2783:2760] = msg_array[115];
	assign msg_out[2807:2784] = msg_array[116];
	assign msg_out[2831:2808] = msg_array[117];
	assign msg_out[2855:2832] = msg_array[118];
	assign msg_out[2879:2856] = msg_array[119];
	assign msg_out[2903:2880] = msg_array[120];
	assign msg_out[2927:2904] = msg_array[121];
	assign msg_out[2951:2928] = msg_array[122];
	assign msg_out[2975:2952] = msg_array[123];
	assign msg_out[2999:2976] = msg_array[124];
	assign msg_out[3023:3000] = msg_array[125];
	assign msg_out[3047:3024] = msg_array[126];
	assign msg_out[3071:3048] = msg_array[127];
	assign msg_out[3095:3072] = msg_array[128];
	assign msg_out[3119:3096] = msg_array[129];
	assign msg_out[3143:3120] = msg_array[130];
	assign msg_out[3167:3144] = msg_array[131];
	assign msg_out[3191:3168] = msg_array[132];
	assign msg_out[3215:3192] = msg_array[133];
	assign msg_out[3239:3216] = msg_array[134];
	assign msg_out[3263:3240] = msg_array[135];
	assign msg_out[3287:3264] = msg_array[136];
	assign msg_out[3311:3288] = msg_array[137];
	assign msg_out[3335:3312] = msg_array[138];
	assign msg_out[3359:3336] = msg_array[139];
	assign msg_out[3383:3360] = msg_array[140];
	assign msg_out[3407:3384] = msg_array[141];
	assign msg_out[3431:3408] = msg_array[142];
	assign msg_out[3455:3432] = msg_array[143];
	assign msg_out[3479:3456] = msg_array[144];
	assign msg_out[3503:3480] = msg_array[145];
	assign msg_out[3527:3504] = msg_array[146];
	assign msg_out[3551:3528] = msg_array[147];
	assign msg_out[3575:3552] = msg_array[148];
	assign msg_out[3599:3576] = msg_array[149];
	assign msg_out[3623:3600] = msg_array[150];
	assign msg_out[3647:3624] = msg_array[151];
	assign msg_out[3671:3648] = msg_array[152];
	assign msg_out[3695:3672] = msg_array[153];
	assign msg_out[3719:3696] = msg_array[154];
	assign msg_out[3743:3720] = msg_array[155];
	assign msg_out[3767:3744] = msg_array[156];
	assign msg_out[3791:3768] = msg_array[157];
	assign msg_out[3815:3792] = msg_array[158];
	assign msg_out[3839:3816] = msg_array[159];
	assign msg_out[3863:3840] = msg_array[160];
	assign msg_out[3887:3864] = msg_array[161];
	assign msg_out[3911:3888] = msg_array[162];
	assign msg_out[3935:3912] = msg_array[163];
	assign msg_out[3959:3936] = msg_array[164];
	assign msg_out[3983:3960] = msg_array[165];
	assign msg_out[4007:3984] = msg_array[166];
	assign msg_out[4031:4008] = msg_array[167];
	assign msg_out[4055:4032] = msg_array[168];
	assign msg_out[4063:4056] = 0;
	assign msg_out[4095:4064] = count;


	(* zemi3_internal_instance = 1 *) 
	rtlClockControl rtl_clock_syn_clock_control(
		.ureset				(ureset), 
		.readyForCclock			(1'b1));

	(* zemi3_internal_instance = 1 *) 
	zebu_reqsig_clock_driverclock z_dc(
		.o				(uclock));

	always @(posedge uclock or posedge ureset) if (ureset) begin
	  count <= 0;
	  do_flush <= 1'b0;
	end
	else
	  begin
	    if (flush) begin
	      do_flush <= 1'b1;
	    end
	    if (shared_tx_complete) begin
	      count <= (count + 1);
	      msg_array[count] <= message0;
	    end
	    if (tx_complete) begin
	      count <= 0;
	      do_flush <= 1'b0;
	    end
	  end
endmodule
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
module zebu_bb_ts_cur_time(ts_time);
/* eve no_synthvout */
	output	[63:0]		ts_time;
endmodule
`timescale 1 ns / 10 ps

/* Source file "", line 0 */
`timescale 1 ns / 10 ps

(* syn_noprune = 1 *) 
module zebu_bb_sample_clk_uncond_sample_2_1(clk, signal, signal_sample);
/* eve no_synthvout */
	input			clk;
	input	[1:0]		signal;
	input	[1:0]		signal_sample;
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
module zebu_bb_sample_clk_uncond_1_1(clk, signal);
/* eve no_synthvout */
	input			clk;
	input			signal;
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
module zebu_bb_sample_clk_uncond_24_1(clk, signal);
/* eve no_synthvout */
	input			clk;
	input	[23:0]		signal;
endmodule
