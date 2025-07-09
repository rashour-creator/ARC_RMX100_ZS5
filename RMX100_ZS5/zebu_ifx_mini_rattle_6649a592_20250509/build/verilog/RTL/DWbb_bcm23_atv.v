// Library safety-1.1.999999999
////////////////////////////////////////////////////////////////////////////////
//
//                  (C) COPYRIGHT 2017 - 2020 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
//  The entire notice above must be reproduced on all authorized copies.
//
// Filename    : DWbb_bcm23_atv.v
// Revision    : $Id: $
// Author      : Doug Lee      March 9, 2017
// Description : DWbb_bcm23_atv.v Verilog module for DWbb
//
// DesignWare IP ID: 8d461b15
//
////////////////////////////////////////////////////////////////////////////////
module DWbb_bcm23_atv (
             clk_s, 
             rst_s_n, 
             event_s, 
             ack_s,
             busy_s,

             clk_d, 
             rst_d_n, 
             event_d
             );

 parameter REG_EVENT    = 1;    // RANGE 0 to 1
 parameter REG_ACK      = 1;    // RANGE 0 to 1
 parameter ACK_DELAY    = 1;    // RANGE 0 to 1
 parameter F_SYNC_TYPE  = 2;    // RANGE 0 to 4
 parameter R_SYNC_TYPE  = 2;    // RANGE 0 to 4
 parameter VERIF_EN     = 1;    // RANGE 0 to 4
 parameter PULSE_MODE   = 0;    // RANGE 0 to 3
 parameter SVA_TYPE     = 0;
 parameter TMR_CDC      = 0;

 localparam F_SYNC_TYPE_P8 = F_SYNC_TYPE + 8;
 localparam R_SYNC_TYPE_P8 = R_SYNC_TYPE + 8;
 localparam TMR_CDC_CC = (TMR_CDC == 0) ? TMR_CDC : 2;
 localparam CC_WIDTH = (TMR_CDC == 0) ? 1 : 3;
 localparam ACK_DELAY_INT = (TMR_CDC == 0) ? ACK_DELAY : 1;
 localparam TST_MODE_INT = 0;
 localparam SYNC_ATV_WIDTH = 1;
 
input  clk_s;                   // clock input for source domain
input  rst_s_n;                 // active low async. reset in clk_s domain
input  event_s;                 // event pulseack input (active high event)
output ack_s;                   // event pulseack output (active high event)
output busy_s;                  // event pulseack output (active high event)

input  clk_d;                   // clock input for destination domain
input  rst_d_n;                 // active low async. reset in clk_d domain
output event_d;                 // event pulseack output (active high event)

wire [CC_WIDTH-1:0]  tgl_s_event_cc;
wire [CC_WIDTH-1:0]  tgl_d_event_cc;
wire   tgl_s_event_q;
wire [CC_WIDTH-1:0]  tgl_s_evnt_nfb_cdc;
wire   tgl_s_ack_x;

wire   tgl_s_event_x;
wire   tgl_d_event_d;

wire   tgl_s_ack_d;
wire   tgl_s_ack_q;
wire   nxt_busy_state;
wire   busy_state;
wire   tgl_d_event_dx;    // event seen via edge detect (before registered)
wire   tgl_d_event_q;     // registered version of event seen


`ifndef SYNTHESIS
`ifndef DWC_DISABLE_CDC_METHOD_REPORTING
  initial begin
    if ((F_SYNC_TYPE > 0)&&(F_SYNC_TYPE < 8))
       $display("Information: *** Instance %m module is using the <Toggle Type Event Sychronizer with busy and acknowledge (3)> Clock Domain Crossing Method ***");
  end

`endif
`endif

generate
  if ((REG_ACK == 0) && (PULSE_MODE == 0)) begin : GEN_RA_EQ_0_PM_EQ_0
     wire [2:0] next_tmr_reg_s;
     wire [2:0] tmr_reg_s;
     
     assign next_tmr_reg_s = {tgl_s_event_x, nxt_busy_state, tgl_s_ack_d};
     
     DWbb_bcm95 #(TMR_CDC, 3, 0)
                        U_TMR_S
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (next_tmr_reg_s),
                         .d_out(tmr_reg_s));

     assign {tgl_s_event_q, busy_state, tgl_s_ack_q} = tmr_reg_s; 
     assign ack_s = tgl_s_ack_x;

     assign tgl_s_event_x = tgl_s_event_q   ^ (event_s && (! busy_state));


     DWbb_bcm95 #(TMR_CDC_CC, 1, 0)
                        U_TMR_S_CC
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (tgl_s_event_x),
                         .d_out(tgl_s_evnt_nfb_cdc));

  end  // of GEN_RA_EQ_0_PM_EQ_0

  if ((REG_ACK == 0) && (PULSE_MODE > 0)) begin : GEN_RA_EQ_0_PM_NE_0
     wire [3:0] next_tmr_reg_s;
     wire [3:0] tmr_reg_s;
     
     wire event_s_cap;

     assign next_tmr_reg_s = {tgl_s_event_x, nxt_busy_state, tgl_s_ack_d, event_s};
     
     DWbb_bcm95 #(TMR_CDC, 4, 0)
                        U_TMR_S
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (next_tmr_reg_s),
                         .d_out(tmr_reg_s));

     assign {tgl_s_event_q, busy_state, tgl_s_ack_q, event_s_cap} = tmr_reg_s; 
     assign ack_s = tgl_s_ack_x;
    
     if (PULSE_MODE == 1) begin : GEN_PLSMD1
      assign tgl_s_event_x = tgl_s_event_q   ^ (! busy_state &(event_s & (! event_s_cap)));
     end
    
     if (PULSE_MODE == 2) begin : GEN_PLSMD2
      assign tgl_s_event_x = tgl_s_event_q  ^ (! busy_state &(event_s_cap & (!event_s)));
     end
    
     if (PULSE_MODE >= 3) begin : GEN_PLSMD3
      assign tgl_s_event_x = tgl_s_event_q ^ (! busy_state & (event_s ^ event_s_cap));
     end


     DWbb_bcm95 #(TMR_CDC_CC, 1, 0)
                        U_TMR_S_CC
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (tgl_s_event_x),
                         .d_out(tgl_s_evnt_nfb_cdc));

  end  // of GEN_RA_EQ_0_PM_NE_0


  if ((REG_ACK == 1) && (PULSE_MODE == 0)) begin : GEN_RA_NE_0_PM_EQ_0
     wire [3:0] next_tmr_reg_s;
     wire [3:0] tmr_reg_s;
     
     wire srcdom_ack;

     assign next_tmr_reg_s = {tgl_s_event_x, nxt_busy_state, tgl_s_ack_x, tgl_s_ack_d};
     
     DWbb_bcm95 #(TMR_CDC, 4, 0)
                        U_TMR_S
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (next_tmr_reg_s),
                         .d_out(tmr_reg_s));

     assign {tgl_s_event_q, busy_state, srcdom_ack, tgl_s_ack_q} = tmr_reg_s; 
     assign ack_s = srcdom_ack;
    

     assign tgl_s_event_x = tgl_s_event_q   ^ (event_s && (! busy_state));

     DWbb_bcm95 #(TMR_CDC_CC, 1, 0)
                        U_TMR_S_CC
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (tgl_s_event_x),
                         .d_out(tgl_s_evnt_nfb_cdc));

  end  // of GEN_RA_NE_0_PM_EQ_0

  if ((REG_ACK == 1) && (PULSE_MODE > 0)) begin : GEN_RA_NE_0_PM_NE_0
     wire [4:0] next_tmr_reg_s;
     wire [4:0] tmr_reg_s;
     
     wire event_s_cap;
     wire srcdom_ack;

     assign next_tmr_reg_s = {tgl_s_event_x, nxt_busy_state, tgl_s_ack_x, tgl_s_ack_d, event_s};
     
     DWbb_bcm95 #(TMR_CDC, 5, 0)
                        U_TMR_S
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (next_tmr_reg_s),
                         .d_out(tmr_reg_s));

     assign {tgl_s_event_q, busy_state, srcdom_ack, tgl_s_ack_q, event_s_cap} = tmr_reg_s; 
     assign ack_s = srcdom_ack;
    
     if (PULSE_MODE == 1) begin : GEN_PLSMD1
      assign tgl_s_event_x = tgl_s_event_q   ^ (! busy_state &(event_s & (! event_s_cap)));
     end
    
     if (PULSE_MODE == 2) begin : GEN_PLSMD2
      assign tgl_s_event_x = tgl_s_event_q  ^ (! busy_state &(event_s_cap & (!event_s)));
     end
    
     if (PULSE_MODE >= 3) begin : GEN_PLSMD3
      assign tgl_s_event_x = tgl_s_event_q ^ (! busy_state & (event_s ^ event_s_cap));
     end

     DWbb_bcm95 #(TMR_CDC_CC, 1, 0)
                        U_TMR_S_CC
                        (.clk(clk_s),
                         .rst_n(rst_s_n),
                         .d_in (tgl_s_event_x),
                         .d_out(tgl_s_evnt_nfb_cdc));

  end  // of GEN_RA_NE_0_PM_NE_0
endgenerate


  assign tgl_s_event_cc = tgl_s_evnt_nfb_cdc;

  DWbb_bcm21_atv #(SYNC_ATV_WIDTH, F_SYNC_TYPE_P8, VERIF_EN, 1, TMR_CDC) U_DW_SYNC_F(
        .clk_d(clk_d),
        .rst_d_n(rst_d_n),
        .data_s(tgl_s_event_cc),
        .data_d(tgl_d_event_d) );


  DWbb_bcm21_atv #(SYNC_ATV_WIDTH, R_SYNC_TYPE_P8, VERIF_EN, 1, TMR_CDC) U_DW_SYNC_R(
        .clk_d(clk_s),
        .rst_d_n(rst_s_n),
        .data_s(tgl_d_event_cc),
        .data_d(tgl_s_ack_d) );

  assign tgl_d_event_dx = tgl_d_event_d ^ tgl_d_event_q;
  //assign tgl_s_event_x  = tgl_s_event_q ^ (event_s & ! busy_s);
  assign tgl_s_ack_x    = tgl_s_ack_d   ^ tgl_s_ack_q;
// spyglass disable_block Ac_conv01
// SMD: Reports signals from the same domain that are synchronized in the same destination domain and converge after any number of sequential elements
// SJ: Intended. watchdog error signal converges at nxt_busy_state  
  assign nxt_busy_state = tgl_s_event_x ^ tgl_s_ack_d;
// spyglass enable_block Ac_conv01



generate
  if ((REG_EVENT == 0) && (ACK_DELAY_INT == 0)) begin : GEN_RE_EQ_0_AD_EQ_0
     DWbb_bcm95 #(TMR_CDC, 1, 0)
                        U_TMR_D
                        (.clk(clk_d),
                         .rst_n(rst_d_n),
                         .d_in (tgl_d_event_d),
                         .d_out(tgl_d_event_q));

     assign tgl_d_event_cc = tgl_d_event_d;
     assign event_d       = tgl_d_event_dx;
  end  // of GEN_RE_EQ_0_AD_EQ_0

  if ((REG_EVENT == 1) && (ACK_DELAY_INT == 0)) begin : GEN_RE_EQ_1_AD_EQ_0
     wire [1:0] next_tmr_reg_d;
     wire [1:0] tmr_reg_d;
     wire    tgl_d_event_qx;      // xor of dest dom data and registered version

     assign next_tmr_reg_d = {tgl_d_event_d, tgl_d_event_dx};

     DWbb_bcm95 #(TMR_CDC, 2, 0)
                        U_TMR_D
                        (.clk(clk_d),
                         .rst_n(rst_d_n),
                         .d_in (next_tmr_reg_d),
                         .d_out(tmr_reg_d));

     assign {tgl_d_event_q, tgl_d_event_qx} = tmr_reg_d;
     assign event_d       = tgl_d_event_qx;

     assign tgl_d_event_cc = tgl_d_event_d;
  end  // of GEN_RE_EQ_1_AD_EQ_0

  if ((REG_EVENT == 0) && (ACK_DELAY_INT == 1)) begin : GEN_RE_EQ_0_AD_EQ_1
     wire next_tmr_reg_d;
     wire tmr_reg_d;
     wire [CC_WIDTH-1:0] tgl_d_event_nfb_cdc;

     assign next_tmr_reg_d = tgl_d_event_d;

     DWbb_bcm95 #(TMR_CDC, 1, 0)
                        U_TMR_D
                        (.clk(clk_d),
                         .rst_n(rst_d_n),
                         .d_in (next_tmr_reg_d),
                         .d_out(tmr_reg_d));

      assign tgl_d_event_q = tmr_reg_d;
      assign event_d       = tgl_d_event_dx;

     DWbb_bcm95 #(TMR_CDC_CC, 1, 0)
                        U_TMR_D_CC
                        (.clk(clk_d),
                         .rst_n(rst_d_n),
                         .d_in (tgl_d_event_d),
                         .d_out(tgl_d_event_nfb_cdc));

    assign tgl_d_event_cc = tgl_d_event_nfb_cdc;

  end  // of GEN_RE_EQ_0_AD_EQ_1

  if ((REG_EVENT == 1) && (ACK_DELAY_INT == 1)) begin : GEN_RE_EQ_1_AD_EQ_1
     wire [1:0] next_tmr_reg_d;
     wire [1:0] tmr_reg_d;
     wire [CC_WIDTH-1:0] tgl_d_event_nfb_cdc;
     wire tgl_d_event_qx;         // xor of dest dom data and registered version

     assign next_tmr_reg_d = {tgl_d_event_d, tgl_d_event_dx};

     DWbb_bcm95 #(TMR_CDC, 2, 0)
                        U_TMR_D
                        (.clk(clk_d),
                         .rst_n(rst_d_n),
                         .d_in (next_tmr_reg_d),
                         .d_out(tmr_reg_d));

      assign {tgl_d_event_q, tgl_d_event_qx} = tmr_reg_d;

      assign event_d       = tgl_d_event_qx;

     DWbb_bcm95 #(TMR_CDC_CC, 1, 0)
                        U_TMR_D_CC
                        (.clk(clk_d),
                         .rst_n(rst_d_n),
                         .d_in (tgl_d_event_d),
                         .d_out(tgl_d_event_nfb_cdc));

    assign tgl_d_event_cc = tgl_d_event_nfb_cdc;

  end  // of GEN_RE_EQ_1_AD_EQ_1
endgenerate


  assign busy_s = busy_state;

`ifdef DWC_BCM_SNPS_ASSERT_ON
`ifndef SYNTHESIS

  DWbb_sva03 #(F_SYNC_TYPE&7,  PULSE_MODE) P_PULSEACK_SYNC_HS (.*);

  generate if (SVA_TYPE == 1) begin : GEN_SVATP_EQ_1
    DWbb_sva02 #(
      .F_SYNC_TYPE    (F_SYNC_TYPE&7),
      .PULSE_MODE     (PULSE_MODE   )
    ) P_PULSE_SYNC_HS (
        .clk_s        (clk_s        )
      , .rst_s_n      (rst_s_n      )
      , .rst_d_n      (rst_d_n      )
      , .event_s      (event_s      )
      , .event_d      (event_d      )
    );
  end endgenerate

  generate if ((F_SYNC_TYPE==0) || (R_SYNC_TYPE==0)) begin : GEN_SINGLE_CLOCK_CANDIDATE
    DWbb_sva07 #(F_SYNC_TYPE, R_SYNC_TYPE) P_CDC_CLKCOH (.*);
  end endgenerate

`endif // SYNTHESIS
`endif // DWC_BCM_SNPS_ASSERT_ON

endmodule
