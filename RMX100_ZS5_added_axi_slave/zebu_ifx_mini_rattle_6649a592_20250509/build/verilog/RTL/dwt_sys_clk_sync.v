// Library ARC_Soc_Trace-1.0.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2013 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Description:
//
// This is the section of the JTAG port that runs on the core
// clock.
//
//======================= Inputs to this block =======================--
//
// clk  The ungated CPU clock, always running
//
// rst_a         The core reset signal
//
// do_bvci_cycle  From debug_port, and synchronous to jtag_tck. Any edge
//              signals a request for a BVCI transaction
//
// bvci_addr_r  From debug_port, synchronous to jtag_tck. The variable
//              portion of the BVCI address
//
// bvci_cmd_r   From debug_port, synchronous to jtag_tck. The BVCI command
//
//====================== Output from this block ======================--
//
// dbg_address  The BVCI address to the core's debug port
//
// dbg_cmd      The BVCI command to the core's debug port
//
// dbg_cmdval   The BVCI command-valid signal.
//
//====================================================================--
`include "dw_dbp_defines.v"

module dwt_sys_clk_sync(
  input                 clk,
  input                 rst_a,
  input                 do_bvci_cycle,
  input                 do_transf,
  input        [32:0]   stg_addr,
  input        [32:0]   stg_data,
  input        [4:0]    stg_cmd,
  input        [32:0]   stg_select_in,
  output reg   [6:0]    transf_status,
  output                transf_status_oksend_sync_tck,
  input  [31:0]         bvci_daddr_r,      // direct bvci access addresss
  input                 bvci_daddr_r_val,  //direct bvci access addresss valid
  input [`DWT_V_DTI_ABITS-1:0] btx_addr_r,     // btx access addresss
  input                        btx_op_r_val,   // btx access addresss valid
  input                 bvci_daddr_btxop_r_val,   // btx access addresss valid
  output                dbg_daddrval,
  input                 dbg_rspval,
  input  [31:0]         dbg_rdata,
  output reg            dbg_rspval_toggle_sync_tck,
  output reg [31:0]     dbg_rdata_sync_tck,

  input      [5:2]      bvci_addr_r,
  input      [1:0]      bvci_cmd_r,
  input                 jtag_trst_n,
  input                 jtag_tck,
  input                 tckRiseEn,

  input      [31:0]     dbg_wdata_tck,
  output     [31:0]     dbg_wdata,

  output     [31:0]     dbg_address,
  output     [1:0]      dbg_cmd,
  output                dbg_cmdval
);

localparam TRANSF_IDLE      = 3'b000;
localparam TRANSF_DOADD     = 3'b001;
localparam TRANSF_DOWDAT    = 3'b010;
localparam TRANSF_DORDAT    = 3'b011;
localparam TRANSF_DOCMD     = 3'b100;
localparam TRANSF_DOEXE     = 3'b101;
localparam TRANSF_POLLSTAT  = 3'b110;
localparam BUSREG_DBADDR    = 32'h0000_0008;
localparam BUSREG_DBDATA    = 32'h0000_000C;
localparam BUSREG_DBCMD     = 32'h0000_0004;
localparam BUSREG_DBSTAT    = 32'h0000_0000;

localparam BVCICMDRD = 2'b01;
localparam BVCICMDWR = 2'b10;

reg stg_addr_pending;
reg stg_data_pending;
reg stg_cmd_pending;
reg stg_select_in_pending;
reg do_transf_qtre_prio;
reg do_transf_qtre;
reg do_bvci_cycle_qtre;
reg do_bvci_cycle_qtre_prio;
wire do_bvci_cycle_qtre_pulse;
reg [31:0] dbg_wdata_qtre;
reg [2:0] transf_fsm_ns;
reg transf_busy_ns;
reg [31:0] transf_busaddr_ns;
reg [31:0] transf_busdata_ns;
reg [1:0]  transf_buscmd_ns;

reg [2:0]  transf_fsm;
reg [31:0] transf_busaddr;
reg [31:0] transf_busdata;
reg [1:0]  transf_buscmd;
reg transf_busy;
reg push_start;
reg push_start_ns;

wire push_done;
wire trans_serviced;
reg transf_status_stall;
reg transf_status_we;
reg transf_status_oksend_ns;
reg transf_status_oksend;
reg transf_status_oksend_sync;
wire transf_status_oksend_sync_pre;
reg transf_status_oksend_sync_pre_d2;


reg  [5:2]         i_bvci_addr_qtre;
reg  [1:0]         i_bvci_cmd_qtre;
wire [31:0]        dbg_wdata_ns;

reg  [`DWT_V_DTI_ABITS-1:0] i_btx_addr_qtre;
reg                i_btx_op_qtre_val;
reg   [31:0]       i_bvci_daddr_qtre;
reg                i_bvci_daddr_qtre_val;
reg                i_bvci_daddr_btxop_qtre_val;
reg                i_bvci_daddr_btxop_qtre_val_prio;
wire               i_bvci_daddr_btxop_qtre_val_pulse;
wire               i_dbg_rspval_toggle_sync_tck;
  
//  This process implements a very restricted BVCI initiator. It is
//  designed only to connect to the BVCI target in the ARC v2EM debug
//  port, which responds in a single cycle and has cmdack tied true. It
//  gets a command via the do_bvci_cycle signal, which is generated on
//  the JTAG clock. That signal gets double-synchronized, and the leading
//  edge of the result is put out as cmdval.
//
//  Nota bene: We need to be able to generate BVCI cycles on consecutive
//  cycles of the JTAG clock. In order to do this without logic asynchronous
//  to that clock, the signal do_bvci_cycle is edge-signaling rather than
//  level-signaling. That is, *any* edge will cause a BVCI cycle to be
//  initiated.

// spyglass disable_block Ac_conv01
// SMD: synchronizers (0,2) converge on combinational gate (ar clk en)
// SJ:  do_bvci_cycle, dbg_wakeup_tck events separated in time
//
// Instantiate CDC synchronizer wrappers so that the synthesis flow can 
// replace it with the proper synchronizer cell of the target library.
//
// spyglass disable_block W391 
reg         dbg_rspval_toggle;
wire        dbg_rspval_sync;
wire        dbg_rspval_toggle_sync_tck_pre;
reg         dbg_rspval_toggle_sync_tck_pre_d2;

  always @(posedge clk or posedge rst_a)
  begin : db_rspval_r_PROC
    if (rst_a == 1'b1)
      begin
        dbg_rspval_toggle <= 1'b0;
      end
    else
      begin
        if (dbg_rspval && ((transf_fsm == TRANSF_IDLE) || (transf_fsm == TRANSF_DORDAT))) begin
          dbg_rspval_toggle <= ~dbg_rspval_toggle;
        end
      end
  end
// spyglass enable_block W391
// spyglass enable_block Ac_conv01 
// spyglass disable_block CDC_UNSYNC_NOSCHEME Ac_unsync02 Ar_resetcross01
// SMD: Enable Criteria not satisfied, no valid qualifier, Unsynchronized reset crossing
// SJ:  programming model allows data to settle before use. dbg_rdata resets on POR
  always @(posedge jtag_tck or negedge jtag_trst_n)
  begin : dbg_rdata_rspval_PROC
    if (jtag_trst_n == 1'b0)
      begin
        dbg_rdata_sync_tck <= 32'b0;
        transf_status_oksend_sync_pre_d2 <=1'b0;
        dbg_rspval_toggle_sync_tck_pre_d2 <=1'b0;
        dbg_rspval_toggle_sync_tck <=1'b0;
      end
    else
      begin
        dbg_rspval_toggle_sync_tck <= i_dbg_rspval_toggle_sync_tck;
        dbg_rdata_sync_tck <= i_dbg_rspval_toggle_sync_tck ? dbg_rdata : dbg_rdata_sync_tck;
        transf_status_oksend_sync_pre_d2 <= transf_status_oksend_sync_pre;
        dbg_rspval_toggle_sync_tck_pre_d2 <= dbg_rspval_toggle_sync_tck_pre;
      end
  end
// spyglass enable_block CDC_UNSYNC_NOSCHEME Ac_unsync02 Ar_resetcross01

assign transf_status_oksend_sync_tck = transf_status_oksend_sync_pre ^ transf_status_oksend_sync_pre_d2;
assign i_dbg_rspval_toggle_sync_tck = dbg_rspval_toggle_sync_tck_pre ^ dbg_rspval_toggle_sync_tck_pre_d2;
dw_dbp_cdc_sync #(.SYNC_FF_LEVELS(`DBP_SYNC_FF_LEVELS)
              ) u_cdc_sync_transf_status_oksend_sync_tck (
                                   .clk   (jtag_tck),
                                   .rst_a (~jtag_trst_n), 
                                   .din   (transf_status_oksend),
                                   .dout  (transf_status_oksend_sync_pre)
                                  );   

dw_dbp_cdc_sync #(.SYNC_FF_LEVELS(`DBP_SYNC_FF_LEVELS)
              ) u_cdc_sync_rspval_sync_tck (
                                   .clk   (jtag_tck),
                                   .rst_a (~jtag_trst_n), 
                                   .din   (dbg_rspval_toggle),
                                   .dout  (dbg_rspval_toggle_sync_tck_pre)
                                  );   
// This capturing of the address and command on the negative edge is done
// to guarantee that if the edges of the JTAG clock and core clock
// happen to align, the BVCI interface won't see the command and data
// from the wrong cycle. The reason this works is somewhat subtle.
// Because do_bvci_cycle and the address/command combo are being captured
// on different clock edges, they cannot go metastable at the same time.
// If this stage goes metastable, because address, command, and
// do_bvci_cycle are changing when the core clock is falling, then this
// stage will be invalid, but the capture of do_bvci_cycle will happen
// half a cycle later and will be valid. Call this negative edge t0. Then
// do_bvci_cycle will be captured cleanly at t0.5, and cmdval will be
// true from t1.5-t2.5. The output of these flops is metastable, so it
// may be wrong when it's captured by the next rank above at t0.5. But
// the fact that we require the JTAG clock to be no faster than 1/2 the
// core clock speed means that it won't change again until t2, and will
// be captured cleanly at t1. This in turn means that the second rank of
// flops above will present clean data to the BVCI interface from
// t1.5-t2.5, at the same time as cmdval. For a more thorough analysis, see
// the ARCv2HS JTAG Port Implementation Reference.
//.

// This violation of the normal standard, which specifies that all the
// outputs from a module must be latched, is done to eliminate the extra
// cycle required on a transaction across the BVCI bus. This seems
// a compelling reason to add one level of gating to this path. It is
// read in synchronous circuitry on the other side of the interface.
//
// Note: Edge-detect the request.
//

// Drive the outputs. The fixed parts of the address are added here.
//
assign dbg_cmdval = push_start || do_bvci_cycle_qtre_pulse; 
assign dbg_cmd    = push_start ? transf_buscmd : i_bvci_cmd_qtre;
assign dbg_wdata  = push_start ? transf_busdata : dbg_wdata_qtre;
// spyglass disable_block Ac_conv02
// debug address range is 0xffff0000-0xffff001c
assign dbg_address  = push_start ? transf_busaddr :
                      i_bvci_daddr_qtre_val ? i_bvci_daddr_qtre :
                      i_btx_op_qtre_val ? {{(32-`DWT_V_DTI_ABITS-2){1'b0}},i_btx_addr_qtre, 2'b00} : 
                      { 26'h3FFFC00, i_bvci_addr_qtre, 2'b00 };
// spyglass enable_block Ac_conv02

// spyglass disable_block Ar_resetcross01
// SMD: Unsynchronized reset crossing
// SJ:  programming model allows data to settle before use.
always @(posedge clk or posedge rst_a)
begin : QUAL_TCKRISEEN_PROC
  if (rst_a == 1'b1) begin
    do_transf_qtre       <= 1'b0;
    stg_addr_pending     <= 1'b0;
    stg_data_pending     <= 1'b0;
    stg_cmd_pending      <= 1'b0;
  end
  else if (transf_busy) begin
      case (transf_fsm)
        TRANSF_DOADD  : stg_addr_pending  <= 1'b0;
        TRANSF_DOWDAT : stg_data_pending  <= 1'b0;
        TRANSF_DOCMD  : stg_cmd_pending   <= 1'b0;
        default:
         begin end
      endcase
  end
  else if (tckRiseEn) begin
    do_transf_qtre      <= do_transf;
    stg_addr_pending    <= stg_addr[32];
    stg_data_pending    <= stg_data[32];
    stg_cmd_pending     <= stg_cmd[4];
  end
end

wire dobvci_serviced;
assign dobvci_serviced =1'b1;  // dbg_rspval;
always @(posedge clk or posedge rst_a)
begin : TCKPOSEDGE_SAMP_PROC
  if (rst_a == 1'b1) begin
    i_bvci_addr_qtre      <= 4'b0;
    i_bvci_cmd_qtre       <= 2'b0;
    i_bvci_daddr_qtre     <= 32'b0;
    i_bvci_daddr_qtre_val <= 1'b0;
    i_btx_addr_qtre       <= {`DWT_V_DTI_ABITS{1'b0}};
    i_btx_op_qtre_val     <= 1'b0;
    do_bvci_cycle_qtre    <= 1'b0;
    dbg_wdata_qtre        <= 32'b0;
    stg_select_in_pending <= 1'b0;
    i_bvci_daddr_btxop_qtre_val <= 1'b0;
  end
  else if (tckRiseEn) begin
    i_bvci_addr_qtre      <= bvci_addr_r;
    i_bvci_cmd_qtre       <= bvci_cmd_r;
    i_bvci_daddr_qtre     <= bvci_daddr_r;
    i_bvci_daddr_qtre_val <= bvci_daddr_r_val;
    i_bvci_daddr_btxop_qtre_val <= bvci_daddr_btxop_r_val;
    i_btx_addr_qtre       <= btx_addr_r;
    i_btx_op_qtre_val     <= btx_op_r_val;
    do_bvci_cycle_qtre    <= do_bvci_cycle;
    dbg_wdata_qtre        <= dbg_wdata_tck;
    stg_select_in_pending <= stg_select_in[32];
  end
end
// spyglass enable_block Ar_resetcross01

assign do_bvci_cycle_qtre_pulse = do_bvci_cycle_qtre ^ do_bvci_cycle_qtre_prio;
assign i_bvci_daddr_btxop_qtre_val_pulse = i_bvci_daddr_btxop_qtre_val ^ i_bvci_daddr_btxop_qtre_val_prio;
assign dbg_daddrval = i_bvci_daddr_btxop_qtre_val_pulse;

assign do_transf_qtre_pulse = do_transf_qtre ^ do_transf_qtre_prio;
assign push_done = dbg_rspval;
assign trans_serviced = (transf_fsm == TRANSF_IDLE) && (transf_fsm_ns != TRANSF_IDLE);

always @*
begin
transf_fsm_ns = transf_fsm;
transf_busy_ns = transf_busy;
transf_busaddr_ns = transf_busaddr;
transf_busdata_ns = transf_busdata;
transf_buscmd_ns  = transf_buscmd;
push_start_ns = push_start;
transf_status_we = 1'b0;
transf_status_stall = 1'b0;
transf_status_oksend_ns = transf_status_oksend;

  case (transf_fsm)
    TRANSF_IDLE: begin
                   if (do_transf_qtre_pulse) begin  //{ transfer req detected, push db_addr
                     transf_status_stall = 1'b1;
                     if (stg_addr_pending) begin
                       transf_fsm_ns = TRANSF_DOADD;
                       transf_busy_ns = 1'b1;
                       transf_busaddr_ns = BUSREG_DBADDR;
                       transf_busdata_ns = stg_addr[0+:32];
                       transf_buscmd_ns  = BVCICMDWR;
                     end
                     else if (stg_data_pending) begin
                       transf_fsm_ns = TRANSF_DOWDAT;
                       transf_busy_ns = 1'b1;
                       transf_busaddr_ns = BUSREG_DBDATA;
                       transf_busdata_ns = stg_data[0+:32];
                       transf_buscmd_ns  = BVCICMDWR;
                       transf_buscmd_ns  = BVCICMDWR;
                     end
                     else if (stg_cmd_pending) begin
                       transf_fsm_ns = TRANSF_DOCMD;
                       transf_busy_ns = 1'b1;
                       transf_busaddr_ns = BUSREG_DBCMD;
                       transf_busdata_ns = stg_addr[0+:4];
                       transf_buscmd_ns  = BVCICMDWR;
                     end
                     else if(stg_cmd[0+:4] == `DWT_CMD_NOP) begin
                       transf_fsm_ns = TRANSF_DORDAT;
                       transf_busy_ns = 1'b1; 
                       transf_busaddr_ns = BUSREG_DBDATA;
                       transf_busdata_ns = 32'b0;
                       transf_buscmd_ns  = BVCICMDRD;
                     end
                     else begin
                       transf_fsm_ns = TRANSF_DOEXE;
                       transf_busy_ns = 1'b1;
                       transf_busaddr_ns = BUSREG_DBSTAT;
                       transf_busdata_ns = 32'b0;
                       transf_buscmd_ns  = BVCICMDWR;
                     end
                     push_start_ns = 1'b1;
                   end  //}
                   else begin  //waiting for transfer req
                     transf_fsm_ns = TRANSF_IDLE;
                     transf_busy_ns = 1'b0;
                     transf_busaddr_ns = 32'h0000_0000;
                     transf_busdata_ns = 32'h0000_0000;
                     transf_buscmd_ns  = 2'b0;
                     push_start_ns = 1'b0;
                   end
                 end
    TRANSF_DOADD: begin  // wait for db_addr push done, then push db_data if transfer is a write req
                    if (push_done) begin  //{ db_addr push done
                      if (~stg_cmd[2]) begin  // push db_data for write transaction
                        transf_fsm_ns = TRANSF_DOWDAT;
                        transf_busy_ns = 1'b1; 
                        transf_busaddr_ns = BUSREG_DBDATA;
                        transf_busdata_ns = stg_data[0+:32];
                        transf_buscmd_ns  = BVCICMDWR;
                        push_start_ns = 1'b1;
                      end
                      else begin
                        transf_fsm_ns = TRANSF_DOCMD;
                        transf_busy_ns = 1'b1; 
                        transf_busaddr_ns = BUSREG_DBCMD;
                        transf_busdata_ns = {28'b0,stg_cmd[0+:4]};
                        transf_buscmd_ns  = BVCICMDWR;
                        push_start_ns = 1'b1;
                      end
                    end  //}{
                    else begin  //{ wait for db_addr to complete
                        push_start_ns = 1'b0;
                    end  //}
                  end  //}
    TRANSF_DOWDAT: begin  // wait for db_data push done, then push db_cmd
                     if (push_done) begin  //{ db_data push done, now push db_cmd
                       transf_fsm_ns = TRANSF_DOCMD;
                       transf_busy_ns = 1'b1; 
                       transf_busaddr_ns = BUSREG_DBCMD;
                       transf_busdata_ns = {28'b0,stg_cmd[0+:4]};
                       transf_buscmd_ns  = BVCICMDWR;
                       push_start_ns = 1'b1;
                     end  //}{
                     else begin  //{ wait for push db_data to complete
                        push_start_ns = 1'b0;
                     end  //}
                   end
    TRANSF_DOCMD: begin  // wait for db_cmd push done, then push db_exec
                     if (push_done) begin  //{ db_cmd push done, now push db_exec with anything
                       transf_fsm_ns = TRANSF_DOEXE;
                       transf_busy_ns = 1'b1; 
                       transf_busaddr_ns = BUSREG_DBSTAT;
                       transf_busdata_ns = 32'b0;
                       transf_buscmd_ns  = BVCICMDWR;
                       push_start_ns = 1'b1;
                     end  //}{
                     else begin  //{ wait for prev push to complete
                        push_start_ns = 1'b0;
                     end  //}
                   end
    TRANSF_DOEXE: begin  // wait for db_exec push done, then poll DB_STATUS
                     if (push_done) begin  //{ db_cmd push done, now push db_exec with anything
                       transf_fsm_ns = TRANSF_POLLSTAT;
                       transf_busy_ns = 1'b1; 
                       transf_busaddr_ns = BUSREG_DBSTAT;
                       transf_busdata_ns = 32'b0;
                       transf_buscmd_ns  = BVCICMDRD;
                       push_start_ns = 1'b1;
                     end  //}{
                     else begin  //{ wait for push db_exec to complete
                        push_start_ns = 1'b0;
                     end  //}
                   end
    TRANSF_POLLSTAT: begin  // wait for db_status[RD==1], then push read of db_data
                     if (push_done) begin  //{ db_exec push done
                       if (!(dbg_rdata[2] && ~(dbg_rdata[0]))) begin  // check STATUS[RD] and repeat if needed
                         transf_fsm_ns = TRANSF_POLLSTAT;
                         transf_busy_ns = 1'b1; 
                         transf_busaddr_ns = BUSREG_DBSTAT;
                         transf_busdata_ns = 32'b0;
                         transf_buscmd_ns  = BVCICMDRD;
                         push_start_ns = 1'b1;
                       end
                       else begin
                         transf_status_we = 1'b1;
                         if (~stg_cmd[2]) begin  // done with transaction, return STATUS to dwdbp
                           transf_status_oksend_ns = ~transf_status_oksend;
                           transf_fsm_ns = TRANSF_IDLE;
                           transf_busy_ns = 1'b0; 
                           push_start_ns = 1'b0;
                         end
                         else begin
                           transf_fsm_ns = TRANSF_DORDAT;
                           transf_busy_ns = 1'b1; 
                           transf_busaddr_ns = BUSREG_DBDATA;
                           transf_busdata_ns = 32'b0;
                           transf_buscmd_ns  = BVCICMDRD;
                           push_start_ns = 1'b1;
                         end
                       end
                     end  //}{
                     else begin  //{ wait for push db_status to complete
                        push_start_ns = 1'b0;
                     end  //}
                   end
    TRANSF_DORDAT: begin
                     if (push_done) begin  //{
                       transf_status_oksend_ns = ~transf_status_oksend;
                       transf_fsm_ns = TRANSF_IDLE;
                       transf_busy_ns = 1'b0; 
                       push_start_ns = 1'b0;
                     end  //}{
                     else begin  //{ wait for push db_data to complete
                        push_start_ns = 1'b0;
                     end  //}
                   end
    default: transf_fsm_ns = transf_fsm;
  endcase
end

// spyglass disable_block CDC_UNSYNC_NOSCHEME Ac_unsync01 Ac_unsync02 Ar_resetcross01 Ac_glitch04
// SMD: Enable Criteria not satisfied, no valid qualifier, Unsynchronized reset crossing, Reconvergence without enable condition
// SJ:  programming model allows data to settle before use. Transfer from static values with one operation type at a time no glitch
always @(posedge clk or posedge rst_a)
begin : transf_PROC
  if (rst_a == 1'b1) begin
    transf_fsm <= TRANSF_IDLE;
    transf_busaddr <= 32'b0;
    transf_busdata <= 32'b0;
    transf_buscmd <= 2'b0;
    transf_status <= 7'b0;
    transf_busy <= 1'b0;
    push_start <= 1'b0;
    do_transf_qtre_prio  <= 1'b0;
    do_bvci_cycle_qtre_prio <= 1'b0;
    transf_status_oksend <= 1'b0;
    i_bvci_daddr_btxop_qtre_val_prio <= 1'b0;
  end
  else begin
    transf_busy <= transf_busy_ns;
    transf_fsm <= transf_fsm_ns;
    transf_busaddr <= transf_busaddr_ns;
    transf_busdata <= transf_busdata_ns;
    transf_buscmd  <= transf_buscmd_ns;
    push_start     <= push_start_ns;
    transf_status_oksend <= transf_status_oksend_ns;
    if (dobvci_serviced) i_bvci_daddr_btxop_qtre_val_prio <= i_bvci_daddr_btxop_qtre_val;
    if (dobvci_serviced) do_bvci_cycle_qtre_prio <= do_bvci_cycle_qtre;
    if (trans_serviced) do_transf_qtre_prio <= do_transf_qtre;
    if (transf_status_we) transf_status <= dbg_rdata[6:0];        //save, send if db_read not required
  end
end
// spyglass enable_block CDC_UNSYNC_NOSCHEME Ac_unsync01 Ac_unsync02 Ar_resetcross01 Ac_glitch04

endmodule // module sys_clk_sync
