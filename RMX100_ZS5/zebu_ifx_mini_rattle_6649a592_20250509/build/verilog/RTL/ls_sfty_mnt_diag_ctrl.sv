
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
// @f:ls_sfty_mnt_diag_ctrl
//
// Description:
// @p
//   safety monitor diagnostic control module for safety monitor hardware error injection.
// @e
//
// ===========================================================================
`include "const.def"

module ls_sfty_mnt_diag_ctrl #(
    parameter SMI_WIDTH = 20
    )
    (
    input                     clk,
    input                     rst,
    input [1:0]               dr_sfty_smi_diag_mode,
    output [SMI_WIDTH-1:0]    sfty_smi_error_mask,
    output [SMI_WIDTH-1:0]    sfty_smi_valid_mask,
    output [1:0]              dr_sfty_smi_diag_inj_end,
    output [1:0]              dr_sfty_smi_mask_pty_err
    ); 

localparam AT_END = SMI_WIDTH-1;

logic [AT_END:0]   count, count_nxt;
localparam COUNT_ZEROS = {SMI_WIDTH{1'b0}};

// States.
localparam [1:0] Q_IDLE       = 2'b01,
                 Q_COUNT_NUM  = 2'b10;
//current state and next state variables             
logic          [1:0] state_r, state_nxt;

logic               diag_enb;
logic                inj_end;
logic [AT_END:0]   err_mask;
logic [AT_END:0]   inj_mask;
logic                sfty_smi_mask_pty_error;


localparam TRACE = 1;
// spyglass disable_block LINT_FSM_WITHOUT_EXIT_STATE
// SMD : State COUNT_NUM is without exit state in FSM
// SJ : Design feature. count_num state is exited on reset. required to stay in COUNT_NUM state till the reset is asserted.
always_comb
begin: counter_async_PROC
    state_nxt    = state_r;
    count_nxt    = count+1; 
    inj_end      = diag_enb && (count == AT_END);

     case (state_r)
	Q_IDLE: begin
            if (diag_enb)            
		state_nxt     =  Q_COUNT_NUM;
            else begin  
		state_nxt     =  Q_IDLE;
		count_nxt     =  COUNT_ZEROS;
		end
            end
	Q_COUNT_NUM: begin
	   if (!diag_enb) begin   
	       state_nxt       = Q_COUNT_NUM;
	       count_nxt       = COUNT_ZEROS;
	       end    
            else if (inj_end)  begin    
	       count_nxt     = AT_END;
	       end
         end
      default: begin
	   state_nxt     = Q_IDLE;
	   end
     endcase 
    end
    
//spyglass enable_block LINT_FSM_WITHOUT_EXIT_STATE

// spyglass disable_block Ar_glitch01
// SMD: Signal driving clear pin of the flop has glitch
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so if TMR is enabled will not have glitch issue , this warning can be ignored.  
// spyglass disable_block Reset_check07
// SMD: Reports asynchronous reset pins driven by a combinational logic or a mux
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so it's intended combinational logic on reset pins and it will not have glitch issue.  
// spyglass disable_block Ar_glitch03
// SMD: Advanced version of Ar_glitch01 to detect glitch in reset paths
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so enabling of the TMR will not cause glitch issue , this warning can be ignored. 
always_ff @(posedge clk or posedge rst) begin: counter_sync_PROC
    if (rst == 1'b1) begin   
	state_r      <= Q_IDLE; 
	count        <= COUNT_ZEROS;
	end      
    else if (diag_enb)    begin    
	state_r      <= state_nxt; 
	count        <= count_nxt;
`ifndef SYNTHESIS
    // Strange that modelsim doesn't print these.
    if (TRACE) if (count != count_nxt) begin
	$display("state %1d count %1d mask %1b",state_r,count,err_mask);
	end
`endif
	end
    else begin
	state_r      <= Q_IDLE;
	count        <= COUNT_ZEROS;
	end
    end // block: counter_sync_PROC
// spyglass enable_block Ar_glitch03
// spyglass enable_block Reset_check07
// spyglass enable_block Ar_glitch01
`ifndef SYNTHESIS
always_comb $display("!sfty_smi_diag_mode= %1b",dr_sfty_smi_diag_mode);
`endif

localparam MASK_ZEROS = {SMI_WIDTH{1'b0}};
localparam MASK_ONES  = {SMI_WIDTH{1'b1}};
localparam MASK_ONE   = {{AT_END{1'b0}},1'b1};

always_comb
begin: err_mask_PROC
    err_mask          = MASK_ZEROS;
    inj_mask          = MASK_ZEROS;
    if (diag_enb) begin
	err_mask         = MASK_ONE  << count;
	inj_mask         = MASK_ONES << count;
	end 
end

always_comb
begin: pty_err_PROC
    sfty_smi_mask_pty_error      = 1'b0;
    if (diag_enb) begin
	sfty_smi_mask_pty_error     = (^err_mask) ? 1'b0 : 1'b1;
	end 
end

/////////////////////////////////////////////////////////////////////////////////////////////////
logic diag_mode_sc;
assign sfty_smi_error_mask = (dr_sfty_smi_diag_mode == 2'b10) ? err_mask : MASK_ZEROS;
assign sfty_smi_valid_mask = (dr_sfty_smi_diag_mode == 2'b10) ? inj_mask : MASK_ZEROS;
assign diag_mode_sc = !(^dr_sfty_smi_diag_mode);
assign diag_enb = (dr_sfty_smi_diag_mode == 2'b10);
//-----------------------------------------------------------
//                   Parity error check for generated mask
//-----------------------------------------------------------
assign dr_sfty_smi_mask_pty_err  = sfty_smi_mask_pty_error | diag_mode_sc ? 2'b10 : 2'b01;

assign dr_sfty_smi_diag_inj_end = (inj_end == 1'b1) ? 2'b10 : 2'b01;


endmodule
