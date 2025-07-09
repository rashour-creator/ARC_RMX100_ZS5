
`include "const.def"

module err_inj_ctrl #(
    parameter NUM_COMPARATORS = 4,
    localparam MASK_SIZE = NUM_COMPARATORS*2,
    localparam MASK_MSB = MASK_SIZE-1,
    localparam ENABLE_SC = 1	//@@@What's this?
    )
    (
//spyglass disable_block Ar_glitch01
//SMD: Glitch in reset paths
//SJ: The signal driving the mux of the reset pin is static and hence the
//reset will not be toggled dynamically for a glitch to occur
    input                     clk,
    input                     rst,
    input [1:0]               dr_sfty_diag_mode_sc,
    output [MASK_MSB:0]       error_mask_sc,
    output [MASK_MSB:0]       valid_mask_sc,
    output [1:0]              dr_sfty_diag_inj_end,
    output [1:0]              dr_mask_pty_err
    ); 

localparam COUNT_BITS = $clog2(MASK_MSB+1);
localparam AT_END = MASK_SIZE-1;

reg [AT_END:0]   count, count_nxt;
localparam COUNT_ZEROS = {COUNT_BITS{1'b0}};

// States.
localparam [1:0] Q_IDLE       = 2'b01,
                 Q_COUNT_NUM  = 2'b10;
//current state and next state variables             
reg          [1:0] state_r, state_nxt;

wire               diag_enb;
reg                inj_end;
reg [MASK_MSB:0]   err_mask;
reg [MASK_MSB:0]   inj_mask;
reg                mask_pty_error;


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
    end // block: count_sync_PROC
`ifndef SYNTHESIS
always_comb
  $display("!dr_sfty_diag_mode_sc= %1b",dr_sfty_diag_mode_sc);
`endif

localparam MASK_ZEROS = {MASK_SIZE{1'b0}};
localparam MASK_ONES  = {MASK_SIZE{1'b1}};
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
    mask_pty_error      = 1'b0;
    if (diag_enb) begin
	mask_pty_error     = (^err_mask) ? 1'b0 : 1'b1;
	end 
end

/////////////////////////////////////////////////////////////////////////////////////////////////
//@@@Let's have an explanation somewhere about enable_sc vs not.
generate
if (ENABLE_SC) begin: PROC_ENABLE_SC
    wire diag_mode_sc;
    assign error_mask_sc = (dr_sfty_diag_mode_sc == 2'b10) ? err_mask : MASK_ZEROS;
    assign valid_mask_sc = (dr_sfty_diag_mode_sc == 2'b10) ? inj_mask : MASK_ZEROS;
    assign diag_mode_sc = !(^dr_sfty_diag_mode_sc);
    assign diag_enb = (dr_sfty_diag_mode_sc == 2'b10);
    //-----------------------------------------------------------
    //                   Parity error check for generated mask
    //-----------------------------------------------------------
    assign dr_mask_pty_err  = mask_pty_error | diag_mode_sc ? 2'b10 : 2'b01;
    end
else begin: PROC_DISABLE_SC
    assign diag_enb = 1'b0;
    assign dr_mask_pty_err  = mask_pty_error ? 2'b10 : 2'b01;
    end
endgenerate

assign dr_sfty_diag_inj_end = (inj_end == 1'b1) ? 2'b10 : 2'b01;

//spyglass enable_block Ar_glitch01

endmodule
