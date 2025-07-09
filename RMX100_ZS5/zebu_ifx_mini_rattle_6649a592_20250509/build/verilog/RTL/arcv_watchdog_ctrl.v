// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Description:
// @p
//  
//  
// @e
//
//  
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions 
//
`include "defines.v"
`include "csr_defines.v"
`include "rv_safety_exported_defines.v"


// Set simulation timescale
//
`include "const.def"


module arcv_watchdog_ctrl (

  ////////// Internal input signals /////////////////////////////////////////
  //
  input                           db_active,     // Host debug op in progress
  input                           sys_halt_r,    // halted status of CPU(s)

  ////////// Interrupt interface /////////////////////////////////////////
  //
  output reg                      irq_wdt,

  ////////// Watchdog external signals ///////////////////////////////////
  //
  output                          reg_wr_en0,
  input                           wdt_clk_enable_sync, // Bit0 of wdt clock synced to core clock
  output                          wdt_feedback_bit,    // Bit1 of core clock feedback to wdt clock
  output reg                      wdt_reset0,      // Reset timeout signal from clk

  ////////// Watchdog CSR controll signals ///////////////////////////////////
  //
  input  [`DATA_RANGE]            csr_wr_data,
  output [`WDT_CTRL_RANGE]        wdt_control0_r,
  output [31:0]         wdt_period0_r,
  output [31:0]         wdt_period_cnt0_r,
  output [31:0]         wdt_lthresh0_r,
  output [31:0]         wdt_uthresh0_r,
  output reg                      i_enable_regs_in,

  output reg                      wdt_en_control_r,
  output reg                      wdt_en_period_r,
  output reg                      wdt_en_lthresh_r,
  output reg                      wdt_en_uthresh_r,
  output reg                      wdt_en_index_r,
  output reg                      wdt_en_passwd_r,

  output                          mst_passwd_match,
  output                          valid_wr,

  input                           csr_password_wen,
  input                           csr_ctrl_wen,
  input                           csr_period_wen,
  input                           csr_index_wen,
  input                           csr_lthresh_wen,
  input                           csr_uthresh_wen,
  input                           csr_passwd_pw0_wen,
  input                           csr_passwd_rst0_wen,
  input                           csr_ctrl0_wen,
  input                           csr_period0_wen,
  input                           csr_lthresh0_wen,
  input                           csr_uthresh0_wen,

  output [1:0]                    wdt_index_r,
  output [`WATCHDOG_NUM-1:0]      wdt_index_sel,

  ////////// General input signals /////////////////////////////////////////
  //
  input                           clk,
  input                           ungated_clk,
  input                           rst_a
);

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Signal/Register Declerations                                           //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

reg  [1:0]                wdt_index_in;

//reg                       i_enable_regs_in;
reg                       i_enable_regs_r;

// The register/wires for the  watchdog counters
// Watchdog timer 0
reg   [`WDT_PW_RANGE]   wdt_passwd_pw0_in;
wire  [`WDT_PW_RANGE]   wdt_passwd_pw0_r;

reg   [31:0]            wdt_period0_in;
reg   [31:0]            wdt_period_cnt0_in;
wire  [31:0]            wdt_period_cnt0_nxt;
wire                              wdt_count0_step;
reg   [`WDT_CTRL_RANGE] wdt_control0_in;
reg                     wd_timeout0;
//This counter has additional threshold registers to support window function
reg   [31:0]            wdt_lthresh0_in;
reg   [31:0]            wdt_uthresh0_in;
reg                     wdt_win_err0_r;
reg                     wdt_win_good0_r;
reg                     wdt_reg_wr_en_0_r;
wire                    wdt_reg_wr_en_0_set;
wire                    wdt_win_config_0_valid;
reg                     wdt_bit0_r;
reg                     wdt_bit0_ungated_r;
reg                     wdt_bit1_ungated_r;
wire                    wdt_enable_pos;
wire                    wdt_count_cg;
wire                    wdt_enable_ungated_pos;



wire [3:0]                passwd_match;
wire [`WATCHDOG_NUM-1:0]  passwd_mismatch;

reg                       wdt_ext_event0_1_r;  //External Event Sync

reg                       wdt_reset0_vec_r;
reg                       wdt_int0_timeout_r;
    
wire                      wdt_set_timeout0_a;

reg                       wdt_reset0_p1_r;


reg   [`WATCHDOG_NUM-1:0] wdt_set_timeout;
reg   [`WATCHDOG_NUM-1:0] wdt_set_timeout_r;

reg   [`WATCHDOG_NUM-1:0] wdt_rst_timeout_r;


assign valid_wr = 
                 (!sys_halt_r & !db_active)
                 ;

// spyglass disable_block AutomaticFuncTask-ML
// SMD: Functions/tasks inside modules and interfaces are not declared as automatic
// SJ: Design intentional
function automatic [`WATCHDOG_NUM-1:0] onehot;
input [1:0]    index;
begin: onehot_func
reg   [`WATCHDOG_NUM-1:0]  i_mask;
integer i;
             i_mask = `WATCHDOG_NUM'b0;	     
             for (i=0; i<`WATCHDOG_NUM; i=i+1)
	          if (i==index) i_mask[i] = 1'b1;
             onehot = i_mask;
end
endfunction
// spyglass enable_block AutomaticFuncTask-ML

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// All the register instantiations are in this section                    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

arcv_wd_parity #(.WD_REG_WIDTH(`WDT_PW_SIZE), .WD_REG_DEFAULT(`WDT_PW_SIZE'hAA)) u_wd_passwd0(
                        .d_in (wdt_passwd_pw0_in),
                        .clk  (clk),
                        .rst  (rst_a),
                        .q_out (wdt_passwd_pw0_r)
  );

// Update the password when write access is granted
//
always @*
begin : wdt_passwd_pw0_PROC

        wdt_passwd_pw0_in = wdt_passwd_pw0_r;
     
        if (csr_passwd_pw0_wen)
            wdt_passwd_pw0_in = csr_wr_data[`WDT_PASSWD_PW];
		else if (csr_passwd_rst0_wen)
            wdt_passwd_pw0_in = `WDT_PW_SIZE'hAA;
end


  
// Watchdog control register for timer 0  (may include parity checking)
//
arcv_wd_parity #(.WD_REG_WIDTH(6), .WD_REG_DEFAULT(6'b0)) u_wd_ctrl0(
                         .d_in (wdt_control0_in),
                         .clk  (clk),
                         .rst  (rst_a),
                         .q_out (wdt_control0_r)
);


// Watchdog period counter register for timer 0  (may include parity checking)
//
arcv_wd_parity #(.WD_REG_WIDTH(32), .WD_REG_DEFAULT(32'b0)) u_wd_period_count0(
                         .d_in (wdt_period_cnt0_in),
                         .clk  (clk),
                         .rst  (rst_a),
                         .q_out (wdt_period_cnt0_r)
);


// Watchdog period register for timer 0  (may include parity checking)
//
arcv_wd_parity #(.WD_REG_WIDTH(32), .WD_REG_DEFAULT(32'b0)) u_wd_period0(
                         .d_in (wdt_period0_in),
                         .clk  (clk),
                         .rst  (rst_a),
                         .q_out (wdt_period0_r)
);

// Watchdog lower threshold register for timer 0  (may include parity checking)
//
arcv_wd_parity #(.WD_REG_WIDTH(32), .WD_REG_DEFAULT(32'b0)) u_wd_lthresh0(
                         .d_in (wdt_lthresh0_in),
                         .clk  (clk),
                         .rst  (rst_a),
                         .q_out (wdt_lthresh0_r)
);


// Watchdog upper threshold register for timer 0  (may includes parity checking)
//
arcv_wd_parity #(.WD_REG_WIDTH(32), .WD_REG_DEFAULT(32'b0)) u_wd_uthresh0(
                         .d_in (wdt_uthresh0_in),
                         .clk  (clk),
                         .rst  (rst_a),
                         .q_out (wdt_uthresh0_r)   
);


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Register Input Logic                                                   //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin : WDT_registers_PROC       


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Timeout signal                                                         //
//                                                                        //
////////////////////////////////////////////////////////////////////////////
      if (wdt_control0_r[`WDT_CTRL_WINEN]) 
          wd_timeout0 = (wdt_win_err0_r || 
                             (!wdt_win_good0_r && (wdt_period_cnt0_r == wdt_lthresh0_r))) &&
                             (wdt_control0_r[`WDT_CTRL_ENB]) && !(wdt_control0_r[`WDT_CTRL_FLAG]);
      else
          wd_timeout0 = (wdt_period_cnt0_r == 0) && 
                              (wdt_control0_r[`WDT_CTRL_ENB]) && !(wdt_control0_r[`WDT_CTRL_FLAG]);

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Watchdog Module control register - wdt_en_control0_r[4:0]              //
//                                                                        //
//  Bit 0   - Enable                                                      //
//  Bit 1-2 - Trigger - Interrupt, Reset                                  //
//  Bit 3   - T - the timeout flag                                        //
//  Bit 4   - WIN_EN - enable for window function                         //
//  Bit 5   - NH - when enable, WDT counts only when processor is not halt//
//                                                                        //
////////////////////////////////////////////////////////////////////////////

  // Set default for control register
  //
  wdt_control0_in = wdt_control0_r;

  // Set the flag in the register if there is a counter timeout 
  //   
  if ((wd_timeout0==1'b1) || passwd_mismatch[0])
      wdt_control0_in[`WDT_CTRL_FLAG] = 1'b1;
         
  // This is the normal write functionality for the register
  //

  if (csr_passwd_rst0_wen)
  begin
      wdt_control0_in = `WDT_CTRL_SIZE'h0;
  end
  else if (csr_ctrl0_wen)           
  begin
      wdt_control0_in = csr_wr_data[`WDT_CTRL_RANGE]; 
      if ((wd_timeout0==1'b1) || passwd_mismatch[0])
      begin
      wdt_control0_in[`WDT_CTRL_FLAG] = (csr_wr_data[`WDT_CTRL_FLAG])?
                                              1'b1 :
					                          1'b0;
      end
      else
      begin
      wdt_control0_in[`WDT_CTRL_FLAG] = (csr_wr_data[`WDT_CTRL_FLAG])?
                                              wdt_control0_r[`WDT_CTRL_FLAG] :
					                          1'b0;
      end
  end     

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Period Register                                                        //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

  // Set default value for period register
  //
  wdt_period0_in = wdt_period0_r;
  
  // This is normal write functional for the register
  //
  if (csr_passwd_rst0_wen )
	wdt_period0_in  = 32'h0;
  else if (csr_period0_wen)
    wdt_period0_in  = csr_wr_data[`WDT_CNT_RANGE0];  

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Counter Register                                                       //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

//spyglass disable_block Ac_conv03
//SMD: Checks different-domain signals that are synchronized in the same destination domain and are converging. 
//SJ : Intended. wdt_period_cnt0_in converges 3 syncronizers; count enable from wdt clock domain; aux write impacted by NMI and Soft Reset, which are all independent
  // Set default for the counter register
  //
  wdt_period_cnt0_in = wdt_period_cnt0_r; 

  if (csr_passwd_rst0_wen)
      wdt_period_cnt0_in = 32'h0;

  else if (csr_period0_wen)
      wdt_period_cnt0_in = csr_wr_data[`WDT_CNT_RANGE0];       
              
  else if (csr_password_wen == 1'b1 && wdt_en_passwd_r && 
           wdt_control0_r[`WDT_CTRL_WINEN]==1'b0 &&
           wdt_index_sel[0]==1'b1 && csr_wr_data[`WDT_PASSWD_SE] == 1'b1)
           wdt_period_cnt0_in = wdt_period0_r;        
                             
  else if (wdt_control0_r[`WDT_CTRL_ENB] &&
           wdt_count_cg &&
           ((wdt_control0_r[`WDT_CTRL_NH]==1'b0) || (sys_halt_r == 1'b0 &&
           db_active == 1'b0)))
          wdt_period_cnt0_in   = ((wdt_period_cnt0_r != 0) || (~wdt_control0_r[`WDT_CTRL_WINEN])) ? wdt_period_cnt0_nxt : wdt_period0_r;
//spyglass enable_block Ac_conv03


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Threshold  Registers                                                   //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

  // Set default value for lower limit threshold register
  //

  wdt_lthresh0_in = wdt_lthresh0_r;
  
  if (csr_passwd_rst0_wen)
    wdt_lthresh0_in  = 32'h0;
  else if (csr_lthresh0_wen)
    wdt_lthresh0_in  = csr_wr_data[`WDT_CNT_RANGE0];

  // Set default value for upper limit threshold register
  //
  wdt_uthresh0_in = wdt_uthresh0_r;

  if (csr_passwd_rst0_wen)
    wdt_uthresh0_in  = 32'h0;
  else if (csr_uthresh0_wen)
    wdt_uthresh0_in  = csr_wr_data[`WDT_CNT_RANGE0];



end


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Counter value                                                          //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

assign wdt_enable_pos = ~wdt_bit0_r & wdt_clk_enable_sync;
assign wdt_count_cg = wdt_bit0_r ^ wdt_clk_enable_sync;
assign wdt_enable_ungated_pos = ~wdt_bit0_ungated_r & wdt_clk_enable_sync;
assign wdt_feedback_bit = wdt_bit1_ungated_r;
// spyglass disable_block W164a
// SMD: LHS is less than RHS         
// SJ:  Intended as per the design. No possible loss of data
assign wdt_count0_step = wdt_enable_pos & !wdt_period_cnt0_r[0];
assign wdt_period_cnt0_nxt = {((wdt_period_cnt0_r >> 1)  - wdt_count0_step), wdt_clk_enable_sync};
// spyglass enable_block W164a

always @(posedge clk or posedge rst_a)
begin : wdt_bit0_r_PROC
  if (rst_a==1'b1)
    wdt_bit0_r <= 1'b0;
  else
    wdt_bit0_r <= wdt_clk_enable_sync;
end

always @(posedge ungated_clk or posedge rst_a)
begin : wdt_bit0_ungated_r_PROC
  if (rst_a==1'b1)
    wdt_bit0_ungated_r <= 1'b0;
  else
    wdt_bit0_ungated_r <= wdt_clk_enable_sync;
end

always @(posedge ungated_clk or posedge rst_a)
begin : wdt_bit1_ungated_r_PROC
  if (rst_a==1'b1)
    wdt_bit1_ungated_r <= 1'b0;
  else if (wdt_enable_ungated_pos)
    wdt_bit1_ungated_r <= ~wdt_bit1_ungated_r;
end



////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Window                                                                 //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

// Assert window event signal
//
wire wdt_ext0_win_trig;
assign wdt_ext0_win_trig = wdt_ext_event0_1_r;
assign reg_wr_en0 = wdt_reg_wr_en_0_r;
assign wdt_win_config_0_valid = (wdt_period0_r >= wdt_lthresh0_r) & (wdt_uthresh0_r >= wdt_lthresh0_r);
assign wdt_reg_wr_en_0_set = (wdt_uthresh0_r <= wdt_period0_r) ? (wdt_period_cnt0_r == wdt_uthresh0_r) : (wdt_period_cnt0_r == wdt_period0_r);

always @(posedge clk or posedge rst_a)
begin : wdt0_win_event0_PROC
        if (rst_a==1'b1)
        begin
            wdt_win_err0_r    <= 1'b0;
            wdt_win_good0_r   <= 1'b0;
            wdt_reg_wr_en_0_r <= 1'b0;
        end
        else
        begin  
	    	    
            // Set the error flag for event outside window and second evend inside the window.
	    //
            wdt_win_err0_r <= (((wdt_uthresh0_r < wdt_period_cnt0_r) && wdt_ext0_win_trig)  ||
                               ((wdt_lthresh0_r > wdt_period_cnt0_r) && wdt_ext0_win_trig)) ||
                                (wdt_win_good0_r && (wdt_lthresh0_r <= wdt_period_cnt0_r) && 
                                 wdt_ext0_win_trig)  ? 1'b1 : 1'b0;
  
            // Set good flag, when trigger is between the two threshold limits
	    //
            if ((wdt_uthresh0_r >= wdt_period_cnt0_r) &&
                (wdt_lthresh0_r <= wdt_period_cnt0_r) && wdt_ext0_win_trig)
                 wdt_win_good0_r <= 1'b1; // Sets the good flag
		  
            else if ((wdt_period_cnt0_r == 32'h0) ||
                     (csr_period0_wen))
                     wdt_win_good0_r <= 1'b0; //Clears the flag

			// Set the valid window period for software event or external event
			//
			if (wdt_control0_r[`WDT_CTRL_WINEN]==1'b0)
              wdt_reg_wr_en_0_r <= 1'b0;
            else if (wd_timeout0 ||
                     (csr_period0_wen == 1'b1) ||
					 (wdt_period_cnt0_r == wdt_lthresh0_r))
              wdt_reg_wr_en_0_r <= 1'b0;
			else if (wdt_reg_wr_en_0_set && wdt_win_config_0_valid)
			  wdt_reg_wr_en_0_r <= 1'b1;
 
         end
	   
end


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// WDT_INDEX register                                                     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

arcv_wd_parity #(.WD_REG_WIDTH(2), .WD_REG_DEFAULT(2'b0)) u_wd_index_reg (
                  .d_in (wdt_index_in), 
                  .clk  (clk),
                  .rst  (rst_a),
                  .q_out (wdt_index_r)
);

// Update the index register when write access is granted
//
always @*
begin : wdt_index_PROC

        wdt_index_in = wdt_index_r;
    
        if (csr_index_wen)
            wdt_index_in = csr_wr_data[`WDT_PASSWD_TN];  
  
end

// enable correct register for the write
//
assign wdt_index_sel = onehot(wdt_index_r);

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Password register enable signals                                       //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : wd_enable_reg_PROC

      if (rst_a)
          i_enable_regs_r <= 1'b0;
      else
          i_enable_regs_r <= i_enable_regs_in;
end

wire csr_any_wen = csr_password_wen
                 | csr_ctrl_wen 
				 | csr_period_wen
				 | csr_lthresh_wen
				 | csr_uthresh_wen
				 ;

assign mst_passwd_match = (csr_wr_data[`WDT_PASSWD_MPW] == `WDT_PW_SIZE'hAA);
assign passwd_match[0] = (csr_wr_data[`WDT_PASSWD_TN] == 0) & (csr_wr_data[`WDT_PASSWD_PW] == wdt_passwd_pw0_r);
assign passwd_match[1] = (csr_wr_data[`WDT_PASSWD_TN] == 1) & (csr_wr_data[`WDT_PASSWD_PW] == `WDT_PW_SIZE'hAA);
assign passwd_match[2] = (csr_wr_data[`WDT_PASSWD_TN] == 2) & (csr_wr_data[`WDT_PASSWD_PW] == `WDT_PW_SIZE'hAA);
assign passwd_match[3] = (csr_wr_data[`WDT_PASSWD_TN] == 3) & (csr_wr_data[`WDT_PASSWD_PW] == `WDT_PW_SIZE'hAA);
assign passwd_mismatch[0] = ~wdt_en_passwd_r & csr_password_wen & (csr_wr_data[`WDT_PASSWD_TN] == 0) & ((mst_passwd_match & (csr_wr_data[`WDT_PASSWD_RST] == 1'b0) & !passwd_match[0]) | ~mst_passwd_match);

always @*
begin : wdt_enable_registers_PROC

  i_enable_regs_in = i_enable_regs_r;

  if ((i_enable_regs_r == 1'b1) && csr_any_wen)
    i_enable_regs_in = 1'b0;
  else if (csr_password_wen & (i_enable_regs_r == 1'b0) && mst_passwd_match && |passwd_match && (csr_wr_data[`WDT_PASSWD_RST] == 1'b0))
	i_enable_regs_in = 1'b1;

end

always @*
begin : wdt_regs_assign_PROC

      wdt_en_passwd_r  = i_enable_regs_r;
	  wdt_en_period_r  = i_enable_regs_r;
      wdt_en_control_r = i_enable_regs_r;
      wdt_en_lthresh_r = i_enable_regs_r;
      wdt_en_uthresh_r = i_enable_regs_r;
      wdt_en_index_r   = ~i_enable_regs_r & mst_passwd_match & |passwd_match;
	    
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Outputs to the IRQ unit                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : timer_int_out_PROC

  irq_wdt = 1'b0;

  irq_wdt = 
            wdt_int0_timeout_r |
                                 1'b0;
end

always @(posedge clk or posedge rst_a)
begin : sync_set_ecr_r_PROC

      if (rst_a)
          wdt_set_timeout_r <= 0;
      else
          wdt_set_timeout_r <= wdt_set_timeout;
end

assign wdt_set_timeout0_a = !wdt_set_timeout_r[0] & wdt_set_timeout[0];

//spyglass disable_block Ac_conv02
//SMD: Reports same-domain signals that are synchronized in the same destination domain and converge before sequential elements. 
//SJ : Intended. wdt_set_timeout converges 3 syncronizers.
always @*
begin : sync_set_ecr_PROC

          wdt_set_timeout = 0;
	  
          wdt_set_timeout[0] =  wdt_reset0_vec_r |
			          wdt_int0_timeout_r;	  
	  
end
//spyglass enable_block Ac_conv02

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Sync the ackowledgement and input signal                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : sync_PROC
  if (rst_a==1'b1)
  begin
  //Generate sync for additional ack signials

    wdt_ext_event0_1_r  <= 1'b0;  //Event Sync

  end
  else
  begin

    // Software/external reset for timer 0
    if (wdt_en_passwd_r && (csr_password_wen == 1'b1) && (csr_wr_data[`WDT_PASSWD_SE] == 1'b1) && (wdt_index_sel[0]==1) &&
        (wdt_control0_r[`WDT_CTRL_WINEN]==1'b1))     
    
        wdt_ext_event0_1_r  <= 1'b1;  //Windown event
     else  
        wdt_ext_event0_1_r <= 1'b0;  
    
 
  end
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Holds the timeout signals for the watchdog module                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
// SMD: Sequential convergence found
// SJ:  The convergence sources are independent to each other without logical dependency

always @(posedge clk or posedge rst_a)
begin : timeout0_PROC

  if (rst_a==1'b1)
  begin
    wdt_reset0_vec_r       <=  1'b0;
    wdt_int0_timeout_r     <=  1'b0;      
  end
  else
  begin
    
	if (csr_passwd_rst0_wen)
	begin
        wdt_reset0_vec_r       <= 1'b0;
        wdt_int0_timeout_r     <= 1'b0;
	end
    else if ((csr_ctrl0_wen==1'b1) && (wdt_en_control_r==1'b1))
    begin
        wdt_reset0_vec_r       <= (csr_wr_data[`WDT_CTRL_FLAG])? (((wd_timeout0==1'b1) || passwd_mismatch[0]) ? 1'b1 : wdt_reset0_vec_r): 1'b0;    
        wdt_int0_timeout_r     <= (csr_wr_data[`WDT_CTRL_FLAG])? (((wd_timeout0==1'b1) || passwd_mismatch[0]) ? 1'b1 : wdt_int0_timeout_r): 1'b0;
    end                     
    else
    begin
 
        // Assert a level interrupt
        if (((wd_timeout0==1'b1) || passwd_mismatch[0]) && (wdt_control0_r[`WDT_CTRL_EVENT]==2'b00)) //Set
            wdt_int0_timeout_r  <=  1'b1;  
   
        // Initiate a system reset  
        if (((wd_timeout0==1'b1) || passwd_mismatch[0]) && (wdt_control0_r[`WDT_CTRL_EVENT]==2'b01)) //Set
             wdt_reset0_vec_r  <=  1'b1;
	
    end
  end
end      
     
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Reset and external reset time out signal                                //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
// spyglass disable_block Reset_sync04
// SMD: Reports asynchronous resets that are synchronized more than once in the same clock domain
// SJ:  Intentionally added to check reset state used to forward cache init
always @(posedge clk or posedge rst_a)  
begin
  if (rst_a==1'b1)
  begin : wdt_timeout_sigs_PRCO
    wdt_reset0              <= 1'b0;
    wdt_reset0_p1_r       <= 1'b0;  
  end
  else
  begin
      wdt_reset0_p1_r <= 
                        wdt_reset0_vec_r  |   
                        1'b0;

// spyglass disable_block Ac_conv01
//SMD: Reports same-domain signals that are synchronized in the same destination domain and converge before sequential elements. 
//SJ : Intended. wdt_set_timeout converges 3 syncronizers.
                                 
//spyglass disable_block Ac_conv02
//SMD: Reports same-domain signals that are synchronized in the same destination domain and converge before sequential elements. 
//SJ : Intended. wdt_set_timeout converges 3 syncronizers.
      wdt_reset0 <= 1'b0  
                   | wdt_reset0_p1_r;         // timeout reset error  
//spyglass enable_block Ac_conv02
		  		   
  end
 
end
// spyglass enable_block Reset_sync04

// spyglass enable_block Ac_conv01
endmodule // arcv_watchdog_ctrl

