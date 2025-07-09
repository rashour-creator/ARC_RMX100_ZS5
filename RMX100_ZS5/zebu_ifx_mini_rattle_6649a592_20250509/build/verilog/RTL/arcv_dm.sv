// Copyright (C) 2012-2013 Synopsys, Inc. All rights reserved.
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
//   arcv_dm
//
// ===========================================================================
//
// Description:
//  Contains the programming registers of producers
//  can support 1,2 or 4 core configurations
//  
//
//  This .vpp source file must be pre-processed with the Verilog
//  Pre-Processor (VPP) to produce the equivalent .v file using a command
//  such as:
//
//   vpp +q +o arcv_dm.svpp
//
// ===========================================================================

`include "arcv_dm_defines.v"   ///////
// Set simulation timescale
//
`include "const.def"

//  input from apb?
//  dmi (m) <-> dm(s)
module arcv_dm #(
  parameter      NrHarts       = `NrHarts,
  parameter      DataCount     = `DataCount,
  parameter      ProgBufSize   = `ProgBufSize
) ( 
//sys if
  input                   dm_clk,          //DM gated clock 
  input                   dm_clk_ug,       //DM ungated clock 
  input                   rst_a,           //Active High Reset  
  output                  dmc_active_o,  
  input                   safety_iso_enb,  
//jtag IF (apb) 
  input                   pclkdbg,         // dmi clock
  input                   presetdbgn,      // dmi reset active low
  input                   presetdbgn_early, // dmi cg active low
  input                   psel_dm,         // device select
  input                   penable_dm,      // 2nd & subsequence cycle of APB transfer
  input  [`APB_ADDR_W-1:2]paddr_dm,        // debug apb address
  input                   pwrite_dm,       // write access, active high
  input  [31:0]           pwdata_dm,       // write data
  output                  pready_dm,
  output [31:0]           prdata_dm,       // read data  
  output                  pslverr_dm,      //

//IBP IF for hmst(M)
//1 cmd
  output                      hmst_cmd_valid_o,
  input                       hmst_cmd_accept_i,
  output                      hmst_cmd_read_o,
  output  [`HMIBP_ADDR_W-1:0] hmst_cmd_addr_o,
  output  [3:0]               hmst_cmd_space_o,  
//2 r data ch
  input                       hmst_rd_valid_i,
  output                      hmst_rd_accept_o,
  input[`HMIBP_DATA_W-1:0]    hmst_rd_data_i,
  input                       hmst_rd_err_i,

//3 w data ch
  output                      hmst_wr_valid_o,
  input                       hmst_wr_accept_i,
  output [`HMIBP_DATA_W-1:0]  hmst_wr_data_o,
  output [`HMIBP_DATA_W/8-1:0]hmst_wr_mask_o,
//4 w resp ch
  input                       hmst_wr_done_i,
  input                       hmst_wr_err_i,
  output                      hmst_wr_resp_accept_o,
//Authentication module
  input   [1:0]           dbg_unlock_i,              //[i]

//hart IF
//SOC hart/resume IF
  input                   arc_halt_req,           //[i]
  input                   arc_run_req,            //[i]
  output reg              arc_halt_ack,             //[o]
  output reg              arc_run_ack,              //[o]         
  output reg              halt_on_reset_o,              //[o]         
  output                  dm_havereset_ack_o,              //[o]         
  output                  dm_relaxedpriv_o,              //[o]         

//hart IF
  input         hart_halted_i,      //halted
  input         hart_unavailable_i,  // e.g.: powered down from each core
  input         hart_resumeack_i,      //resume ack
  input         arc_havereset_i,      //reset ack core2dm 

  output reg                  hart_reset_o, // Core reset
  output reg                  hart_reset2_o, // Core custom0 reset
  output                      hart_haltreq_o,     //halt req,   
  output reg                  hart_resumereq_o,  //resume req,
  input                       sys_halt_r,      //hart is halted
  output                  hart_ndm_rst    
  );                                                      
//para for addr.
reg  [NrHarts-1:0] hart_haltreq;
reg  [NrHarts-1:0] hart_resumereq;
reg  [NrHarts-1:0] dm_havereset_ack;
reg  [NrHarts-1:0] dm_relaxedpriv;

//DM Registers 0                  
localparam  ADDR_ABS_DATA0    =   ( 7'h4 ); //04
localparam  ADDR_ABS_DATA1    =   ( 7'h5 ); //05                
localparam  ADDR_ABS_DATA2    =   ( 7'h6 ); //06                
localparam  ADDR_ABS_DATA3    =   ( 7'h7 ); //07                

//DM Registers 1
localparam  ADDR_DM_CTRL          =    ( 7'h10 ); //10
localparam  hart_num              =    ( NrHarts -1 ); //10
localparam  ADDR_DM_STATUS        =    ( 7'h11);  //11
localparam  ADDR_HART_INFO        =    ( 7'h12 ); //12
localparam  ADDR_HART_SUMRY1      =    ( 7'h13);  //13
localparam  ADDR_HART_WIDW_SEL    =    ( 7'h14 ); //14
localparam  ADDR_HART_WIDW        =    ( 7'h15);  //15
localparam  ADDR_ABS_CTRL_STATUS  =    ( 7'h16 ); //16
localparam  ADDR_ABS_COMM         =    ( 7'h17);  //17
localparam  ADDR_ABS_AUTO         =    ( 7'h18);  //18
localparam  ADDR_NEXTDM           =    ( 7'h1d);  //1D

 //DM Registers 2
localparam  ADDR_PROG_BUF0    =  ( 7'h20 ); //20
localparam  ADDR_PROG_BUF1    =  ( 7'h21);  //21
localparam  ADDR_PROG_BUF2    =  ( 7'h22);  //22
localparam  ADDR_PROG_BUF3    =  ( 7'h23);  //23
localparam  ADDR_PROG_BUF4    =  ( 7'h24);  //24
localparam  ADDR_PROG_BUF5    =  ( 7'h25);  //25
localparam  ADDR_PROG_BUF6    =  ( 7'h26);  //26
localparam  ADDR_PROG_BUF7    =  ( 7'h27);  //27

//DM Registers 3
localparam ADDR_AUTH_DATA     = ( 7'h30 ); //30
localparam ADDR_CUSTOM0        = ( 7'h70 ); //70

localparam HART_RESET    = 3'b000;  //0 4 5 6 7 4 running first
localparam HART_RUNNING  = 3'b100;  //0 6 7 4 5 6 stop first
localparam HART_STOPING  = 3'b101;  //normal loop = 45674567
localparam HART_STOP     = 3'b110;
localparam HART_RESUMING = 3'b111;

localparam DM_ABS_RESET = 3'b000;
localparam DM_ABS_IDLE  = 3'b100;
localparam DM_ABS_RUNN  = 3'b101;
localparam DM_ABS_EBUSY = 3'b110;
localparam DM_ABS_EWAIT = 3'b111;
localparam DM_ABSAUTO_WIDTH = `DataCount;

localparam DMC_HALTREQ_BIT   = 31;
localparam DMC_RESUMEREQ_BIT = 30;
localparam DMC_RESET_BIT = 29;
localparam DMC_ACKHAVERESET_BIT = 28;
localparam DMC_HASEL_BIT     = 26;
localparam DMC_SETRESETHALTREQ     = 3;
localparam DMC_CLRRESETHALTREQ     = 2;
  
  reg [31:0]                 prdata_dm_reg;
  reg                        apb_cmd_white_list;
//------------------------------------------------------------
   wire                 dm_bnk_en;
   wire                 dm_bnk_en_read;
   wire                 dm_bnk_en_write; 
wire safety_iso_enb_pclk_s;

//Authentication module
  reg   [1:0]           dbg_unlock_i_r;    //[i]

always_ff@(posedge dm_clk_ug or posedge rst_a) begin: dbg_unlock_i_r_reg_PROC
  if(rst_a) begin
      dbg_unlock_i_r <=  2'b0; 
  end
  else begin
      dbg_unlock_i_r <=  dbg_unlock_i; 
  end
end // dbg_unlock_i_r_reg_PROC 

//abs_data 0x0
   reg  [`DATA_W-1:0]    abs_data_r0;         //reg 0x04+0     
   reg  [`DATA_W-1:0]    abs_data_r1;         //reg 0x04+1     
//------------------------------------------------------------
//DM Registers component 0x10
   reg  [`DATA_W-1:0]    dm_ctrl;             //0x10       
   reg  [`DATA_W-1:0]    dm_status;           //0x11       
   wire [`DATA_W-1:0]    dm_hart_info;        //0x12
   reg  [`DATA_W-1:0]    dm_hart_widwsel;     //0x14       
   reg  [`DATA_W-1:0]    dm_hart_widw;        //0x15       
   reg  [`DATA_W-1:0]    dm_abs_ctrl_status;  //0x16       
   reg  [`DATA_W-1:0]    dm_abs_command;      //0x17       
   reg  [DM_ABSAUTO_WIDTH-1:0] dm_abs_auto;   //0x18  

   reg  [NrHarts-1:0]   dm_custom0;        //0x70

  wire                  block_abc_cond;
  wire                  block_abc_cond_unlock;   

  wire                  dm_write;
  wire                  dm_read;
  wire  [6:0]           dm_addr;

  wire  [19:0]          hartsel_o;
  wire                  allnonexist;
  wire                  anynonexist;
  wire                  allhavereset_n;
  wire                  anyhavereset_n;
  reg   [NrHarts-1:0]   hart_resumeack_r;
  wire                  allresumeack_n;
  wire                  anyresumeack_n;
//MHA
  wire [NrHarts-1:0]    hart_sel;
  wire [NrHarts-1:0]    hart_sel_single;
//MHAend
//------------------------------------------------------------
//abs abc sm   
//------------------------------------------------------------
  reg                   soc_run_req_queue0;
  reg                   soc_halt_req_queue0;
  reg [NrHarts-1:0]     halt_req_dm_soc;
  reg [NrHarts-1:0]     run_req_dm_soc;
  wire [NrHarts-1:0]    halt_req_dm;
  wire [NrHarts-1:0]    run_req_dm;
  wire                  req_fromdm ;
  wire                  abs_transfer_posedge;
  wire                  err_eq0;  
  wire                  err_eq0_n;  
//------------------------------------------------------------
//DM Registers component 0x10
  wire                  dmc_haltreq; 
  wire                  dmc_resumereq; 
  wire                  dmc_hartreset; 
  wire                  dmc_ackhavereset; 
  wire                  dmc_ackunavail; 
  wire                  dmc_hasel; 
  wire  [9:0]           dmc_hartsello; 
  wire  [9:0]           dmc_hartselhi; 
  wire                  dmc_setkeepalive;
  wire                  dmc_clrkeepalive;
  wire                  dmc_setresethartreq; 
  wire                  dmc_clrresethartreq; 
  wire                  dmc_ndmreset;   
//  wire                  dmc_active_n;   
//DM Registers component 0x11
  wire  [6:0]           dmst_zero2;   
  wire                  dmst_ndmresetpending;   
  wire                  dmst_stickyunavail;   
  wire                  dmst_impebreak;   
  wire  [1:0]           dmst_zero1;   
  wire                  dmst_allhavereset;   
  wire                  dmst_anyhavereset;   
  wire                  dmst_allresumeack;   
  wire                  dmst_anyresumeack;   
  wire                  dmst_allnonexistent;   
  wire                  dmst_anynonexistent;   
  wire                  dmst_allunavail;   
  wire                  dmst_anyunavail;   
  wire                  dmst_allrunning;   
  wire                  dmst_anyrunning;   
  wire                  dmst_allhalted;   
  wire                  dmst_anyhalted;   
  wire                  dmst_authenticated;   
  wire                  dmst_authbusy;   
  wire                  dmst_hasresethaltreq;   
  wire                  dmst_confstrptrvalid;   
  wire  [3:0]           dmst_version;  
//DM Registers component 0x12
  wire  [7:0]           hinfo_hart_zero1;
  wire  [3:0]           hinfo_nscratch;
  wire  [2:0]           hinfo_hart_zero0;
  wire                  hinfo_dataaccess;
  wire  [3:0]           hinfo_datasize;
  wire  [11:0]          hinfo_dataaddr;
//DM Registers component 0x14
  wire  [31:15]         hawindowsel_zero;
  wire  [14:0]          hawindowsel;
//DM Registers component 0x15  dm_hart_widw
//DM Registers component 0x16
  wire  [31:29]         dmr_reg_zero3;
  wire  [4:0]           dmr_progbufsize;
  wire  [23:13]         dmr_reg_zero2;
  wire                  dmr_busy;
  wire                  dmr_relaxedpriv;
  wire  [2:0]           dmr_cmderr;
  wire  [7:4]           dmr_reg_zero1;
  wire  [3:0]           dmr_datacount;

//DM Registers component 0x17 w
  wire  [7:0]           cmdtype;          //cmd type for w/r
//DM Registers component 0x17 r
  wire                  abs_cmd_zero0; 
  wire  [2:0]           aarsize; 
  wire                  aarpostincrement; 
  wire                  postexec;
  wire                  transfer; 
  wire                  abs_cmd_write; 
  wire  [15:0]          regno;
  wire  [15:0]          regno_n;
//DM Registers component 0x18 r/w
  wire  [DM_ABSAUTO_WIDTH-1:0] auto_exdata;
  
//------------------------------------------------------------
//dm_auth_data;
//DM Registers component 0x38 sys bus ctrl status

//------------------------------------------------------------
//hart ctrl sm  
//------------------------------------------------------------  
  reg  [2:0]              hc_state_q;
  reg  [2:0]              hc_state_n;
  wire                    hart_stop;
  wire                    hart_run2stop;
  wire                    hart_running;
  wire                    hart_stop2run;
//  wire                    halt_on_reset_ctrl;
  wire [`HMIBP_DATA_W-1:0]abc_hmst_rdata_i;
  reg                     hart_resumereq_selected;
  reg                     hart_haltreq_selected;
  reg                     ackhavereset_selected;
  wire [`HMIBP_DATA_W-1:0]abc_hmst_rdata_n;
  reg                     dmst_ndmrst;
  wire                    anyhart_stop;
  wire                    allhart_stop;
  wire                    anyhart_running;
  wire                    allhart_running;

//------------------------------------------------------------
//dm_abs/abc sm   
//------------------------------------------------------------
  reg  [2:0]              abs_state_q;
  reg  [2:0]              abs_state_n;  
  reg  [2:0]              abs_sm_err_n;  
  wire                    addr_irq;    
  wire                    abs_irq;    
  wire                    abc_fire;    
  reg                     accreg;
  reg                     accmem;
  wire [7:0]              cmdtype_n;
  reg                     unsupported_command;
  wire                    align_addr;
  wire                    aarsize_valid;
  wire [2:0]              aarsize_n;
// aarsize = component 0x17 [22:20]
  wire[3:0]                            abc_addr_incr ; //incr_encoder
  reg                                  addr_carry;
  wire[`HMIBP_ADDR_W-1:0]              abc_hmst_addr_i; //mux addr to hmst
  wire[`HMIBP_ADDR_W-1:0]              abc_mem_addr_i; //mux data to hmst
  wire[32-1:0]                         abc_hmst_wdata_i;        //mux data to hmst
//------------------------------------------------------------
//dm_IBP IF

//mst
  wire                    hmst_read_fire;
  wire                    hmst_write_fire;
  wire                    dmr_busy_n;
  wire                    bus_err;
  wire                    bus_addrerr;
  wire                    arc_havereset_n;

//------------------------------------------------------------
// i/o retiming reg
//------------------------------------------------------------
reg [`APB_ADDR_W-1:2]     paddr_dm_r;
reg                       pwrite_dm_r;
reg [31:0]                pwdata_dm_r;
reg [`APB_ADDR_W-1:2]     i_paddr_r;
reg                       psel_dm_r;   
wire                      psel_dm_r_qual;
reg                       penable_dm_r;
reg                       i_pwrite_r;
reg [31:0]                i_pwdata_r;
reg                       o_pready_r;
reg                       o_pslverr_r;   

wire                      dm_addr_inrange;
wire                      abs_transfer_fire;    
wire                      wr_mst_transfer;
wire                      rd_mst_transfer;
wire                      abc_mst_transfer;
wire [5:0]                hartsel0_clipped;
assign hartsel0_clipped = (i_pwdata_r[16 +: 6] > hart_num) ? hart_num : i_pwdata_r[16 +: 6];

 // 0x10 havereset ack from core 
wire                      allunavail;
wire                      anyunavail;
//------------------------------------------------------------
wire                      apb_touch_0x10;
wire                      apb_touch_0x11;
wire                      apb_touch_0x16;
wire                      apb_touch_0x17;
wire                      apb_touch_0x18;
wire                      apb_touch_0x30;
assign apb_touch_0x10 = (dm_addr == ADDR_DM_CTRL) ;
assign apb_touch_0x11 = (dm_addr == ADDR_DM_STATUS) ;
assign apb_touch_0x16 = (dm_addr == ADDR_ABS_CTRL_STATUS) ;
assign apb_touch_0x17 = (dm_addr == ADDR_ABS_COMM) ;
assign apb_touch_0x18 = (dm_addr == ADDR_ABS_AUTO) ;
assign apb_touch_0x30 = (dm_addr == ADDR_AUTH_DATA) ; 

// 0x18 abs auto 0x18 logic 
wire  apb_touch_0x04;
assign apb_touch_0x04 = (dm_addr == ADDR_ABS_DATA0) ;
wire  apb_touch_0x05;
assign apb_touch_0x05 = (dm_addr == ADDR_ABS_DATA1) ;
wire  [DM_ABSAUTO_WIDTH-1:0]abc_auto_group;
wire  abc_auto_fire;
//------------------------------------------------------------

reg apb_xfer_t; // toggle indicator for apb xfer
wire apb_xfer_t_2dm_s;
reg apb_xfer_t_2dm_s_r;
wire apb_xfer_pulse;
reg apb_xfer_pulse_r;

always_ff@(posedge pclkdbg or negedge presetdbgn) begin: apb_xfer_t_reg_PROC
  if(!presetdbgn) begin
    apb_xfer_t   <=  1'b0;
  end
  else if (psel_dm_r_qual && !penable_dm_r)
  begin
    apb_xfer_t   <=   ~apb_xfer_t;
  end
end // apb_xfer_t_reg_PROC


dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_apb_xfer2dmclk_sync (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a),
                                   .din   (apb_xfer_t),
                                   .dout  (apb_xfer_t_2dm_s)
                                  );

dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_safety_iso_enb_pclk_s_sync (
                                   .clk   (pclkdbg),
                                   .rst_a (~presetdbgn),
                                   .din   (safety_iso_enb),
                                   .dout  (safety_iso_enb_pclk_s)
                                  );



always_ff@(posedge dm_clk_ug or posedge rst_a) begin : apb_xfer_t_2dm_s_r_reg_PROC
  if(rst_a) begin
    apb_xfer_t_2dm_s_r <=  1'b0;
    apb_xfer_pulse_r   <=  1'b0;
  end
  else begin
    apb_xfer_t_2dm_s_r <=  apb_xfer_t_2dm_s;
    apb_xfer_pulse_r   <=  apb_xfer_pulse;
  end
end // apb_xfer_t_2dm_s_r_reg_PROC 

assign apb_xfer_pulse  = apb_xfer_t_2dm_s ^ apb_xfer_t_2dm_s_r;

assign dm_addr_inrange = (paddr_dm_r[`APB_ADDR_W-1:9] == {20'h0,3'b0}); 

// spyglass disable_block Ar_resetcross01
// SMD: aresetcross
// SJ: sync by reset sync module on arcv_dm_top    
always_ff@(posedge pclkdbg or negedge presetdbgn) begin: i_apb_psel_penable_reg_PROC
  if(!presetdbgn) begin
    penable_dm_r       <=  1'b0;
    psel_dm_r          <=  1'b0;
  end
  else if(safety_iso_enb_pclk_s == 1'b1)begin
    penable_dm_r       <=   1'b0;
    psel_dm_r          <=   1'b0;
  end  
  else begin    
    penable_dm_r       <=   penable_dm;
    psel_dm_r          <=   psel_dm;
  end
end // i_apb_psel_penable_reg_PROC

always_ff@(posedge pclkdbg or negedge presetdbgn) begin: i_apb_ctrl_reg_PROC
  if(!presetdbgn) begin
    paddr_dm_r         <=  {`APB_ADDR_W-2{1'b0}};
    pwrite_dm_r        <=  1'b0;
    pwdata_dm_r        <=  32'b0;
  end
  else
   if(safety_iso_enb_pclk_s == 1'b0)
  begin    
    paddr_dm_r         <=   paddr_dm;
    pwrite_dm_r        <=   pwrite_dm;
    pwdata_dm_r        <=   pwdata_dm;
  end  
end // i_apb_ctrl_reg_PROC  
// spyglass enable_block Ar_resetcross01
assign  psel_dm_r_qual = psel_dm_r && dm_addr_inrange;
// spyglass disable_block Ar_resetcross01
// SMD: aresetcross
// SJ:  data is gated by early signal   
// spyglass disable_block CDC_UNSYNC_NOSCHEME
// SMD: aresetcross
// SJ:  data is gated by early signal   
// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_COMB
// SMD: aresetcross
// SJ:  data is gated by early signal    
always_ff@(posedge dm_clk_ug or posedge rst_a) begin: i_apb_data_reg_PROC
  if(rst_a)  begin
    i_paddr_r          <=  {`APB_ADDR_W-2{1'b0}};  // from apb addr
    i_pwrite_r         <=  1'b0;
    i_pwdata_r         <=  32'b0;
  end
  else if(presetdbgn_early && apb_xfer_pulse) begin
    i_paddr_r          <=  paddr_dm_r;
    i_pwrite_r         <=  pwrite_dm_r;     
    i_pwdata_r         <=  pwdata_dm_r;    
  end
end // i_apb_data_reg_PROC 
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_COMB
// spyglass enable_block CDC_UNSYNC_NOSCHEME

always_ff@(posedge pclkdbg or negedge presetdbgn) begin: o_apb_err_reg_PROC
  if(!presetdbgn)  begin
    o_pslverr_r <=  1'b0;
  end
  else if(safety_iso_enb_pclk_s == 1'b1)begin
    o_pslverr_r <=   1'b1;
  end  
  else begin  //{
    if (apb_xfer_pulse_r) begin  // {
      o_pslverr_r <=  ~apb_cmd_white_list;  
    end  //}
    else begin  // {
      if (psel_dm_r && ~dm_addr_inrange) begin  // {
        o_pslverr_r <=   1'b1;  
      end  //}
      else begin
         o_pslverr_r <=  1'b0; 
      end   
    end     //}
  end     //}
end // o_apb_data_reg_PROC   

always_ff@(posedge pclkdbg or negedge presetdbgn) begin: o_apb_rdy_ctrl_reg_PROC
  if(!presetdbgn) begin
    o_pready_r <=  1'b1;
  end
  else if(safety_iso_enb_pclk_s == 1'b1)begin
    o_pready_r <=  1'b1;
  end  
  else begin  // {
    if (psel_dm && ~penable_dm)   // 
      o_pready_r <=  1'b0;  
    else if(apb_xfer_pulse_r)   // 
        o_pready_r <=  1'b1;
    else if(psel_dm_r && ~dm_addr_inrange)   // 
        o_pready_r <=  1'b1;
  end  //}
end // o_apb_rdy_ctrl_reg_PROC      
// spyglass enable_block Ar_resetcross01

//------------------------------------------------------------
//DM reset assignment.    
//------------------------------------------------------------ 
assign hart_ndm_rst = dmc_ndmreset;

always_comb begin : ndmrst_PROC
     dmst_ndmrst =1'b0;                          //0 and in progress
     if(dmc_ndmreset ) begin    //not reset or not reset yet
         dmst_ndmrst =1'b1;                          //dmc_ndmreset-ing.
     end else if(dmst_allhavereset)begin  
         dmst_ndmrst =1'b0;                          //0 and in progress
     end    
end // ndmrst_PROC   

//------------------------------------------------------------
//DM Registers component 0x1x   dm ctrl    
//------------------------------------------------------------
assign {dmc_haltreq,        //dmc 0x10   
        dmc_resumereq,      
        dmc_hartreset,      
        dmc_ackhavereset,   
        dmc_ackunavail,     
        dmc_hasel,          
        dmc_hartsello,      
        dmc_hartselhi,      
        dmc_setkeepalive,   
        dmc_clrkeepalive,   
        dmc_setresethartreq,
        dmc_clrresethartreq,
        dmc_ndmreset,       
        dmc_active_o            } = dm_ctrl;       
assign {dmst_zero2,                           //dmst 0x11 
        dmst_ndmresetpending,       
        dmst_stickyunavail,                        // opt !-e
        dmst_impebreak,         
        dmst_zero1,              
        dmst_allhavereset,      
        dmst_anyhavereset,      
        dmst_allresumeack,      
        dmst_anyresumeack,      
        dmst_allnonexistent,    
        dmst_anynonexistent,    
        dmst_allunavail,        
        dmst_anyunavail,        
        dmst_allrunning,        
        dmst_anyrunning,        
        dmst_allhalted,         
        dmst_anyhalted,         
        dmst_authenticated,     
        dmst_authbusy,          
        dmst_hasresethaltreq,   
        dmst_confstrptrvalid,   
        dmst_version           } = dm_status; 

assign {hinfo_hart_zero1,       //hinfo 0x12  
        hinfo_nscratch,     
        hinfo_hart_zero0,   
        hinfo_dataaccess,   
        hinfo_datasize,     
        hinfo_dataaddr    } = dm_hart_info;          

assign {hawindowsel_zero,       //hwind_sel 0x14 
        hawindowsel       } = dm_hart_widwsel;     // hart arr mask     

assign {dmr_reg_zero3,          //hinfo 0x16  
        dmr_progbufsize, 
        dmr_reg_zero2,   
        dmr_busy,        
        dmr_relaxedpriv, 
        dmr_cmderr,      
        dmr_reg_zero1,   
        dmr_datacount     } = dm_abs_ctrl_status;          
assign {cmdtype,         //hinfo 0x17  
        abs_cmd_zero0,   
        aarsize,         
        aarpostincrement,
        postexec,        
        transfer,        
        abs_cmd_write,   
        regno            } = dm_abs_command;          
assign  auto_exdata        = dm_abs_auto; //0x18
        
//------------------------------------------------------------
//DM Registers component 0x20 prog buf    
//------------------------------------------------------------

 // dmi  
assign dm_write  = i_pwrite_r; 
assign dm_read   = ~i_pwrite_r;
assign dm_bnk_en = apb_xfer_pulse_r & (i_paddr_r[`APB_ADDR_W-1:9] == {23'h0}); 
assign dm_bnk_en_read = (dm_bnk_en && dm_read);   
assign dm_bnk_en_write= (dm_bnk_en && dm_write);   
assign abc_auto_fire  = apb_xfer_pulse_r & ( (|abc_auto_group) & ((transfer & accreg) | accmem));   //0x18  accreg look transfer
assign dm_addr   = i_paddr_r[2 +:7]; 
assign pready_dm = o_pready_r;
assign prdata_dm = prdata_dm_reg; //from DMR

assign abs_transfer_fire = dm_bnk_en_write & (apb_touch_0x17 & dmc_active_o);
assign abs_transfer_posedge = abs_transfer_fire &( (i_pwdata_r[17] & accreg) | accmem | unsupported_command); //0x17

// abs auto 0x18 logic
assign abc_auto_group =  auto_exdata & {  
                        apb_touch_0x05,
                        apb_touch_0x04}  ;

//set cyc to execute
assign pslverr_dm = o_pslverr_r;

//for output assignment
  assign hart_resumereq_o=hart_stop2run? run_req_dm_soc[0] : 1'b0;
  assign hart_haltreq_o  =hart_run2stop? halt_req_dm_soc[0]: 1'b0;
  assign dm_havereset_ack_o= dm_havereset_ack[0];
  assign dm_relaxedpriv_o= dm_relaxedpriv[0];

assign  hart_sel[0] = hart_sel_single[0];  
assign  hart_sel_single[0] = 1'b1;
assign  arc_havereset_n = arc_havereset_i ;
 // 0x10 havereset ack from core
assign  allhavereset_n = arc_havereset_n  ;
assign  anyhavereset_n = arc_havereset_n   ; //!sel->0,
assign  allresumeack_n = hart_resumeack_r  ; //!sel->1, sel-> see reset
assign  anyresumeack_n = hart_resumeack_r  ; //!sel->0,
assign  allunavail =  hart_unavailable_i ;
assign  anyunavail =  hart_unavailable_i ;
assign  allnonexist = 1'b0; //if sel<= harts -> exist
assign  anynonexist = 1'b0;
  // output multiplexer
  always_comb 
  begin : p_RL_halt_resume_out_PROC
      hart_resumereq[0] = hart_resumereq_selected;
      hart_haltreq[0]   = hart_haltreq_selected;
      dm_havereset_ack = ackhavereset_selected;
      dm_relaxedpriv   = dmr_relaxedpriv ;
  end // p_RL_halt_resume_out_PROC 


wire windsel;
assign windsel = (hawindowsel==0) && dm_hart_widw[0];
  always_ff @ (posedge dm_clk_ug or posedge rst_a) begin : DM_RESET_reg_PROC //{
    if (rst_a) begin    //{ hard reset    
       hart_reset_o <= 1'b0;
       hart_reset2_o <= 1'b0;
    end  //} end of reset 
    else if (!dmc_active_o) begin   //{ sw reset   
       hart_reset_o <= hart_reset_o;           //keep
       hart_reset2_o <= hart_reset_o;          //keep
    end  //} end of sw reset 
    else begin       //{                    
        if(dm_bnk_en_write && apb_touch_0x10 ) begin  //{
              hart_reset_o  <= i_pwdata_r[DMC_RESET_BIT] & ~dm_custom0[0] ;   //reset selectd
              hart_reset2_o <= i_pwdata_r[DMC_RESET_BIT] &  dm_custom0[0] ;   //reset selectd
        end //} end of Write 0x10    
    end   //} 
  end  //} DM_RESET_reg_PROC

always_comb  begin : DM_APB_CMD_WHITE_LIST_PROC
      case (paddr_dm_r[2 +: 7]) 
          ADDR_ABS_DATA0,                        //04+0 
          ADDR_ABS_DATA1,                        //04+1 
          //DM Registers 2x 
          ADDR_DM_CTRL,                          //10
          ADDR_HART_WIDW_SEL,                    //14
          ADDR_HART_WIDW,                        //15
          ADDR_ABS_CTRL_STATUS,                  //16 
          ADDR_ABS_COMM, 
          ADDR_ABS_AUTO,
       //DM Registers 3x                                  
          ADDR_AUTH_DATA,                        //30    
          ADDR_CUSTOM0  : apb_cmd_white_list = 1;  //70
          ADDR_NEXTDM,
          ADDR_DM_STATUS,
          ADDR_HART_INFO: apb_cmd_white_list = ~pwrite_dm_r;
          default       : apb_cmd_white_list = 0;
      endcase
end // end of DM_APB_CMD_WHITE_LIST_PROC 
 
//--------sel_logic ---------------------------------------------------- 
//add DM_ACTIVE UG
always_ff @ (posedge dm_clk_ug or posedge rst_a) begin : DM_UG_REG_PROC 
  if (rst_a) begin    //resetresetreset I1   
       dm_ctrl             <= {1'b0 , //     dmc_haltreq,        //dmc 0x10 lo=1  
                               1'b0 , //     dmc_resumereq,      
                               1'b0 , //     dmc_hartreset,      
                               1'b0 , //     dmc_ackhavereset,   
                               1'b0 , //     dmc_ackunavail, !support     
                               1'b0 , //     dmc_hasel,          
                               10'b0 , //     dmc_hartsello,      
                               10'b0 , //     dmc_hartselhi,      
                               1'b0 , //     dmc_setkeepalive,   
                               1'b0 , //     dmc_clrkeepalive,   
                               1'b0 , //     dmc_setresethartreq,
                               1'b0 , //     dmc_clrresethartreq,
                               1'b0 , //     dmc_ndmreset,
                               1'b0 };  //     dmc_active_o  
  end // end of reset  
  else if (!dmc_active_o) begin   //{ !activeactive II2
         if (dm_bnk_en_write && apb_touch_0x10) begin  //{
             dm_ctrl         <= {1'b0 , //     dmc_haltreq,        //dmc 0x10 lo=1  
                                 1'b0 , //     dmc_resumereq,      
                                 1'b0 , //     dmc_hartreset,      
                                 1'b0 , //     dmc_ackhavereset,   
                                 1'b0 , //     dmc_ackunavail, !support     
                                 1'b0 , //     dmc_hasel,          
                                 10'b0 , //     dmc_hartsello,      
                                 10'b0 , //     dmc_hartselhi,      
                                 1'b0 , //     dmc_setkeepalive,   
                                 1'b0 , //     dmc_clrkeepalive,   
                                 1'b0 , //     dmc_setresethartreq,
                                 1'b0 , //     dmc_clrresethartreq,
                                 1'b0 , //     dmc_ndmreset,       
                                 i_pwdata_r[0] };                      
         end   //}
    end  //}
  else
  if (dbg_unlock_i_r == 2'b01)
  begin  //{
  //Register writewritewrite4 IV4    
    if (dm_bnk_en_write) begin  //{
       if(apb_touch_0x10) begin  //{
                                dm_ctrl[31]     <= i_pwdata_r[31];  //haltreq warz
                                dm_ctrl[29]     <= i_pwdata_r[29];  //hartreset warz
                                dm_ctrl[27]     <= 1'b0;  //ackunavail w1
                                dm_ctrl[26:6]   <= {1'b0, 9'b0, 1'b0, 10'b0};  //single core point to 0 only.
                                dm_ctrl[1]      <=  i_pwdata_r[1];   //10           
                                dm_ctrl[0]      <=  i_pwdata_r[0];   //10    

  // halt on reset logic.
       end  //}
    end  //}
  end  //}
  else begin //VII7 only dmstatus R [7:6] + [3:0] + dm_active R/W + arthen data R/W
        if (dm_bnk_en_write) begin  //W
          if(apb_touch_0x10) begin
             dm_ctrl[0]    <= i_pwdata_r[0] ; 
          end
        end
  end        
end //end DM_UG_REG_PROC 

// spyglass disable_block Ac_conv01
// SMD: u_presetn_early_s and u_dm_arc_halt_req_sync synchronizers converge on flop hart_haltreq_selected
// SJ:  events are orthogonal   

always_ff @ (posedge dm_clk or posedge rst_a) begin : DM_HARTREQ_W1_REG_PROC 
  if (rst_a) begin    
    hart_haltreq_selected   <= 1'b0;
  end  // end of reset 
//!dmc1 => dmc reset
  else if (!dmc_active_o) begin   //!activeactive II2
    hart_haltreq_selected   <= 1'b0;
  end  
  else if (dm_bnk_en_write && apb_touch_0x10)begin 
    // haltreq w part // w1
      if(i_pwdata_r[DMC_HALTREQ_BIT])
       hart_haltreq_selected   <= hart_run2stop; //halt req if SM=run
      else begin //w0
       hart_haltreq_selected   <= 1'b0 ;
      end
  end // end of 0x10 write 
  else begin
     if (hart_halted_i)    hart_haltreq_selected     <= 1'b0;
  end // end !0x10 write
end // DM_HARTREQ_W1_REG_PROC


always_ff @ (posedge dm_clk or posedge rst_a) begin : DM_RESUME_HVRST_W1_REG_PROC 
  if (rst_a) begin    //resetresetreset I1
    hart_resumereq_selected <= 1'b0;
    ackhavereset_selected   <= 1'b0;
    halt_on_reset_o         <= 1'b0;
  end  // end of reset 
//!dmc1 => dmc reset
  else if (!dmc_active_o) begin   //!activeactive II2
    hart_resumereq_selected <= 1'b0;
    ackhavereset_selected   <= 1'b0;
    halt_on_reset_o         <= 1'b0;
  end  
  else if (dm_bnk_en_write && apb_touch_0x10 && (dbg_unlock_i_r == 2'b01) )begin 
      if(i_pwdata_r[DMC_RESUMEREQ_BIT])
        hart_resumereq_selected <= hart_stop2run & ~i_pwdata_r[DMC_HALTREQ_BIT]; //w1
      if(i_pwdata_r[DMC_ACKHAVERESET_BIT])
        ackhavereset_selected   <= 1'b1; //w1
      if( ~i_pwdata_r[DMC_CLRRESETHALTREQ] ) begin   //!clr & set -> set 
          if ( i_pwdata_r[DMC_SETRESETHALTREQ] )
             halt_on_reset_o         <= 1'b1; //01 clr,set->set, other -> clr
      end else begin
             halt_on_reset_o         <= 1'b0; //01 clr,set->set, other -> clr
      end  
  end // end of 0x10 write 
  else begin
     if (~arc_havereset_i) ackhavereset_selected     <= 1'b0;             
     if (hart_resumeack_i) hart_resumereq_selected   <= 1'b0;
  end // end !0x10 write
end // DM_RESUME_HVRST_W1_REG_PROC
// spyglass enable_block Ac_conv01


//add DM_ACTIVE UG    
//casecasecase
//-apb access =  --------------------------------------------------------- 
//always begin  DM_REG_reg_PROC
//     if (I1 rst_a)
//else if (dbg_unlock_i == 2'b01)
//{
//       if (II2 !dmc_active_o)    
//  else if (III3 abc_mst_transfer)
//  else if (IV4 apb_en)
//           if (sba access)
//           else 
//              if (apb write) update dm_sys_bus_cs
//              else if (read) update dm_sys_bus_cs
//           if (IV41 dm_write == 1'b1)  
//           else if (IV42 dm_read == 1'b1)   
//  else    (V5 !apb access) //!apb if  access for non access face.
//           sba access (no apb)
//}
//else{ if w VII7
//      else r  }  //VII7 the DM state is not reset or cleared automatically.
//-apb access =  ---------------------------------------------------------  
// end of DM_REG_reg_PROC always
// spyglass disable_block Ac_conv01
// SMD: u_presetn_early_s and synchronizers converge on safety_iso_enb0/1
// SJ:  events are orthogonal   
always_ff @ (posedge dm_clk or posedge rst_a) begin : DM_REG_reg_PROC 
  if (rst_a) begin    //resetresetreset I1
     //DM Registers 1x       
//       dm_hart_info        <= 32'h00 ;      //12  //hard wire  
       dm_hart_widwsel     <= 32'h00 ;      //14 
       dm_hart_widw        <= 32'h00 ;      //15 
//----------------------------------------------------abscs 0x16 
       dm_abs_ctrl_status  <=  {3'b0,    //dmr_reg_zero3,            //0x16
                                5'd`ProgBufSize,    //dmr_progbufsize, 
                                11'b0,    //dmr_reg_zero2,   
                                1'b0,    //dmr_busy,        
                                1'b0,    //dmr_relaxedpriv, 
                                3'b0,    //dmr_cmderr,      
                                4'b0,    //dmr_reg_zero1,   
                                4'd`DataCount };  //dmr_datacount    

     //16{0,progsize,0,busy(from hart ctrl),relaxedpriv, cmderr(from hart ctrl) 0 datacount} 
       dm_abs_command      <= 32'b00;         
       dm_abs_auto         <= {DM_ABSAUTO_WIDTH{1'b0}};         
     //DM Registers 2x    
     
       abs_data_r0        <= 32'h00 ;   //04+0
       abs_data_r1        <= 32'h00 ;   //04+1
       addr_carry          <= 1'b0;

     //DM Registers 3x          //3x

        dm_custom0         <= {NrHarts{1'b0}} ;    //70    
//------dm abs------------------------------------------------------
        prdata_dm_reg      <= 32'h00 ;            
  
  end  // end of reset 

//!dmc1 => dmc reset
  else if (dbg_unlock_i_r == 2'b01)begin
    if (!dmc_active_o) begin   //!activeactive II2
         dm_hart_widwsel     <= 32'h00 ;      //14 
         dm_hart_widw        <= 32'h00 ;      //15 
  //----------------------------------------------------abscs 0x16 
         dm_abs_ctrl_status  <=  {3'b0,    //dmr_reg_zero3,            //0x16
                                  5'd`ProgBufSize,    //dmr_progbufsize, 
                                  11'b0,    //dmr_reg_zero2,   
                                  1'b0,    //dmr_busy,        
                                  1'b0,    //dmr_relaxedpriv, 
                                  3'b0,    //dmr_cmderr,      
                                  4'b0,    //dmr_reg_zero1,   
                                  4'd`DataCount };  //dmr_datacount           
         dm_abs_command      <=  {8'b0,  //cmdtype,          ;      //0x17 
                                  1'd0,  //abs_cmd_zero0,   
                                  3'b0, //aarsize,         
                                  1'b0,  //aarpostincrement,
                                  1'b0,  //postexec,        
                                  1'b0,  //transfer,        
                                  1'b0,  //abs_cmd_write,   
                                  16'd0};   //regno                               
         dm_abs_auto         <= {DM_ABSAUTO_WIDTH{1'b0}}; // auto_exdata //0x18                                      
  //DM Registers 2x 
         abs_data_r0        <=  32'b0;                   
         abs_data_r1        <=  32'b0;                   
         prdata_dm_reg       <=  32'h0 ;            
  
    end  
  //!dmc => dmc reset
  //--------------IBP HMST IF > APB IF III3 abc_mst_transfer-------------------------------
    else if (abc_mst_transfer) begin    //0x17  ack to give success 
  //------------------------------------------------------------
         if (abc_mst_transfer) begin
           if(rd_mst_transfer & err_eq0_n) begin                 //0x17  abc read
                                        abs_data_r0  <= abc_hmst_rdata_n[31:0]; //[1]burst [0]w 
           end    
  // core write > dm read abs_data_r0    
  //------------------------------------------------------------
  // update data registers for finished ABC operation   
           if(aarpostincrement & err_eq0_n) begin  //w/r successful addr++ aarpostincrement                                                                                                                                                                                                                                                                                                                                          
               if(accreg)dm_abs_command[15:0] <= dm_abs_command[15:0] + 16'd1;  //reg
               else begin                                                       //mem
                 {addr_carry,             abs_data_r1} <= abc_hmst_addr_i[31:0] + {28'b0, abc_addr_incr};      //arsize=210
               end    
           end
  //------------------------------------------------------------
         // abstractcs               
           dm_abs_ctrl_status[12]   <= |dmr_busy_n;    //dmr_busy,  
           
           if(dmr_cmderr == 3'b0)
           dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    

         end   // end of abc_mst_transfer 

// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: safety_iso_enb[1:0] dbg_apb_presetn_early Source signals from same domain converge after synchronization
// SJ:  events are orthogonal   
         if(dm_bnk_en_read)begin
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ
            case (dm_addr) 
                  ADDR_DM_CTRL       : begin prdata_dm_reg <= {2'b0,dm_ctrl[29],2'b0,
                                                               1'b0, 9'b0, 1'b0, 10'b0, //hasel    for DS, W1 read 0
                                                               2'b0,2'b0,dm_ctrl[1:0]};    //10
                                       end                
                ADDR_DM_STATUS       : prdata_dm_reg <= dm_status          ;    //11
                ADDR_HART_INFO       : prdata_dm_reg <= dm_hart_info     ;    //12 hard wired
  //            ADDR_HART_WIDW_SEL   : prdata_dm_reg <= dm_hart_widwsel    ;    //14
  //            ADDR_HART_WIDW       : prdata_dm_reg <= dm_hart_widw       ;    //15
                ADDR_ABS_CTRL_STATUS : begin
                                         prdata_dm_reg[31:11] <= {dm_abs_ctrl_status[31:13],
                                                                 |dmr_busy_n,dm_abs_ctrl_status[11]};
                                         prdata_dm_reg[10:8]  <= (dmr_cmderr == 3'b0)? abs_sm_err_n : dm_abs_ctrl_status[10:8];                
                                         prdata_dm_reg[7:0]   <= dm_abs_ctrl_status[7:0] ;    //16
                                       end           
                ADDR_ABS_COMM        : prdata_dm_reg <= 32'b0       ;      //17 WAnyReadZero
                ADDR_ABS_AUTO        : prdata_dm_reg <= {{32-DM_ABSAUTO_WIDTH{1'b0}},dm_abs_auto} ;
                           default     prdata_dm_reg <= 32'h0 ;            
            endcase    
         end // end of dm_bnk_en_read             
  // update DM registers for ABC updating  
  // update data registers for finished ABC operation   
    end  // end of III 
  //Register  IV4 apb_en   
    else if (dm_bnk_en) begin
       if(dm_write) begin              //IV41 apb_write 
          case (dm_addr)            //abc_write
     //DM Registers 0       
             ADDR_ABS_DATA0      :begin                         //04+0 
                                      if(!dmr_busy) begin
                                          abs_data_r0  <= i_pwdata_r;
                                      end 
                                      if (!dmr_busy) begin 
                                          dm_abs_ctrl_status[12]   <=  |dmr_busy_n;   
                                      end
                                      if(dmr_cmderr == 3'b0) begin
                                          dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    
                                      end    
                                  end 
             ADDR_ABS_DATA1      :begin                         //04+1 
                                      if(!dmr_busy) begin
                                          abs_data_r1  <= i_pwdata_r;
                                      end 
                                      if (!dmr_busy) begin 
                                          dm_abs_ctrl_status[12]   <=  |dmr_busy_n;   
                                      end
                                      if(dmr_cmderr == 3'b0) begin
                                          dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    
                                      end    
                                  end 
     //DM Registers 1x       
     //        ADDR_DM_STATUS      : ;//dm_status         <= i_pwdata_r;   //11 RO
     //        ADDR_HART_INFO      : ;//dm_hart_info      <= hart_info_i; //12 RO
             ADDR_HART_WIDW_SEL  : dm_hart_widwsel<= 32'h00 ;   //14  RL no core sel
             ADDR_HART_WIDW      : dm_hart_widw   <= 32'h00 ;   //15
             ADDR_ABS_CTRL_STATUS: begin                       //16 
                                      if(!dmr_busy)begin
                                         dm_abs_ctrl_status[10:8] <= dmr_cmderr & ~i_pwdata_r[10:8]; //w1clear
                                         dm_abs_ctrl_status[11]   <= i_pwdata_r[11];
                                      end 
                                      else begin  //busy
                                         if(dmr_cmderr == 3'b0) begin
                                         dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    
                                         end
                                      end   
                                   end   
             ADDR_ABS_COMM       : begin
                                     if(dmr_cmderr == 3'b0) begin
                                         dm_abs_command           <= i_pwdata_r;   //17 w if cmderr=0 
                                         dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    
                                     end
                                     if (!dmr_busy) begin 
                                         dm_abs_ctrl_status[12]   <= |dmr_busy_n;  
                                     end
                                   end  
     
             ADDR_ABS_AUTO       : begin
                                     if (!dmr_busy) begin 
                                         dm_abs_auto      <= i_pwdata_r[0 +: DM_ABSAUTO_WIDTH];                                       
                                     end  
                                     else begin  //busy
                                        if(dmr_cmderr == 3'b0) begin
                                        dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    
                                        end
                                     end                                      
                                   end
     //DM Registers 2x 
     //DM Registers 3x                                                            //3x
   
             ADDR_CUSTOM0        : dm_custom0        <= i_pwdata_r[0 +: NrHarts];   //70
                       default   : prdata_dm_reg     <= 32'h0 ;            
           endcase
       end //end of IV41 write 
     //READ IV42 dm_read  start
       else if (dm_read) begin 
           case (dm_addr)
     //DM Registers 0       
               ADDR_ABS_DATA0       : begin                                          //04+0    
                                           if (!dmr_busy) begin// (from hart ctrl)
                                                   prdata_dm_reg <= abs_data_r0 ;
                                           end
                                           if (!dmr_busy) begin 
                                               dm_abs_ctrl_status[12]   <= |dmr_busy_n;  
                                           end
                                           if(dmr_cmderr == 3'b0)
                                           dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    
                                      end
               ADDR_ABS_DATA1       : begin                                          //04+1    
                                           if (!dmr_busy) begin// (from hart ctrl)
                                                   prdata_dm_reg <= abs_data_r1 ;
                                           end
                                           if (!dmr_busy) begin 
                                               dm_abs_ctrl_status[12]   <= |dmr_busy_n;  
                                           end
                                           if(dmr_cmderr == 3'b0)
                                           dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;    
                                      end
     //DM Registers 1x       
               ADDR_DM_CTRL         :  begin prdata_dm_reg <= {2'b0,dm_ctrl[29],2'b0,
                                                          1'b0, 9'b0, 1'b0, 10'b0, //hasel    for DS, W1 read 0
                                                          2'b0,2'b0,dm_ctrl[1:0]};    //10
                                       end   
   
               ADDR_DM_STATUS       :   prdata_dm_reg <= dm_status          ;    //11
               ADDR_HART_INFO       :   prdata_dm_reg <= dm_hart_info     ;    //12 hard wired
   //            ADDR_HART_WIDW_SEL   :   prdata_dm_reg <= dm_hart_widwsel    ;    //14
   //            ADDR_HART_WIDW       :   prdata_dm_reg <= dm_hart_widw       ;    //15
               ADDR_ABS_CTRL_STATUS :  begin
                                        prdata_dm_reg[31:11] <= {dm_abs_ctrl_status[31:13],
                                                                |dmr_busy_n,dm_abs_ctrl_status[11]};
                                        prdata_dm_reg[10:8]  <= (dmr_cmderr == 3'b0)? abs_sm_err_n : dm_abs_ctrl_status[10:8];                
                                        prdata_dm_reg[7:0]   <= dm_abs_ctrl_status[7:0] ;    //16
   
                                        dm_abs_ctrl_status[12]   <= |dmr_busy_n;    //dmr_busy,  
                                        if(dmr_cmderr == 3'b0)
                                        dm_abs_ctrl_status[10:8] <= abs_sm_err_n;    //dmr_cmderr,     from sm  ;  
                                       end                   
               ADDR_ABS_COMM        :   prdata_dm_reg <= 32'b0       ;      //17 WAnyReadZero
               ADDR_ABS_AUTO        :   prdata_dm_reg <= {{32-DM_ABSAUTO_WIDTH{1'b0}},dm_abs_auto} ;
     //DM Registers 2x  
               ADDR_NEXTDM       :   prdata_dm_reg <= 32'b0            ;  //1D
     //DM Registers 3x                                   
             ADDR_CUSTOM0        :           prdata_dm_reg  <= {{32-hart_num{1'b0}},dm_custom0};   //70
                         default :           prdata_dm_reg  <= 32'h0;
          endcase 
       end //end of read   EOF  IV42 dm_read
    end  //EOF IV4 apb_en   
    else begin //!apb if  access for non access face. V5
  
    end // end of (VI5 !apb access)   
  end   //end of (dbg_unlock_i == 2'b01)
  else begin //VII7 only dmstatus R [7:6] + [3:0] + dm_active R/W + arthen data R/W
    if (!dmc_active_o) begin   
         dm_hart_widwsel     <= 32'h00 ;      //14 
         dm_hart_widw        <= 32'h00 ;      //15 
  //----------------------------------------------------abscs 0x16 
         dm_abs_ctrl_status  <=  {3'b0,    //dmr_reg_zero3,            //0x16
                                  5'd`ProgBufSize,    //dmr_progbufsize, 
                                  11'b0,    //dmr_reg_zero2,   
                                  1'b0,    //dmr_busy,        
                                  1'b0,    //dmr_relaxedpriv, 
                                  3'b0,    //dmr_cmderr,      
                                  4'b0,    //dmr_reg_zero1,   
                                  4'd`DataCount };  //dmr_datacount           
         dm_abs_command      <=  {8'b0,  //cmdtype,          ;      //0x17 
                                  1'd0,  //abs_cmd_zero0,   
                                  3'b0, //aarsize,         
                                  1'b0,  //aarpostincrement,
                                  1'b0,  //postexec,        
                                  1'b0,  //transfer,        
                                  1'b0,  //abs_cmd_write,   
                                  16'd0};   //regno                               
         dm_abs_auto         <= {DM_ABSAUTO_WIDTH{1'b0}}; // auto_exdata //0x18                                      
  //DM Registers 2x 
         abs_data_r0         <=  32'b0;                   
         abs_data_r1         <=  32'b0;                   
         prdata_dm_reg       <=  32'h0 ;            
  
  //!dmactive => dmc reset 
    end    
    else begin  //dmactive  
          if (dm_bnk_en_write) begin  //W
          end //end of write 
       //------------------------------------------------------------
          else if (dm_bnk_en_read) begin   //R
               case (dm_addr)
                //DM Registers 1x       
                 ADDR_DM_CTRL   :   prdata_dm_reg <= {31'b0, //read active only
                                                      dm_ctrl[0]};    //10
                 ADDR_DM_STATUS :   prdata_dm_reg <= {7'b0,
                                                      2'b0, 
                                                      dm_status[22],
                                                      14'b0,
                                                      dm_status[7:6],//authenticated, busy
                                                      dm_status[5:4], // W1 read 0
                                                      dm_status[3:0]};  //11
               //DM Registers 3x                                                       //3x
                    default     :   prdata_dm_reg <= 32'b0;
               endcase 
          end //end of read                    
    end // dmactive         
  end        // end of VII7
end  // end of DM_REG_reg_PROC always
// spyglass enable_block Ac_conv01



       //halt req,   from dmcreg 
always_ff @ (posedge dm_clk_ug or posedge rst_a) begin : DM_HALT_ACK_reg_PROC 
  if (rst_a) begin    //hard reset    
     arc_halt_ack <= 1'b0;
  end  // end of reset 
  else begin 
       if(hart_run2stop & arc_halt_req) begin   //run & gv halt req ack.    
       arc_halt_ack <= hart_halted_i;           
       end else if(~arc_halt_req)begin
       arc_halt_ack <= 1'b0;           
       end    
  end  // end of sw reset 
end // DM_HALT_ACK_reg_PROC   
       
always_ff @ (posedge dm_clk_ug or posedge rst_a) begin : DM_RUN_ACK_reg_PROC 
  if (rst_a) begin    //hard reset    
     arc_run_ack <= 1'b0;
  end  // end of reset 
  else begin
       if (hart_stop2run & arc_run_req) begin   //stop & gv run req ack.   
         arc_run_ack <= hart_resumeack_i;  
       end else if(~arc_run_req)begin 
         arc_run_ack <=  1'b0 ;  
       end  
  end  
end // DM_RUN_ACK_reg_PROC     

always_ff @ (posedge dm_clk or posedge rst_a) begin : DM_STATUS_reg_PROC 
  if (rst_a) begin    //resetresetreset I1
       dm_status           <= {7'b0,     // dmst_zero2,          //0x11      
                               1'b0,     // dmst_ndmresetpending,    
                               1'b0,     // dmst_stickyunavail,      
                               1'b0,     // dmst_impebreak,          
                               2'b0,     // dmst_zero1,              
                               1'b0,     // dmst_allhavereset,       
                               1'b0,     // dmst_anyhavereset,       
                               1'b0,     // dmst_allresumeack,       
                               1'b0,     // dmst_anyresumeack,       
                               1'b0,     // dmst_allnonexistent,     
                               1'b0,     // dmst_anynonexistent,     
                               1'b0,     // dmst_allunavail,         
                               1'b0,     // dmst_anyunavail,         
                               1'b0,     // dmst_allrunning,         
                               1'b0,     // dmst_anyrunning,         
                               1'b0,    // dmst_allhalted,          
                               1'b0,    // dmst_anyhalted,          
                               1'b0,    // dmst_authenticated,          
                               1'b0,     // dmst_authbusy,           
                               1'b1,     // dmst_hasresethaltreq,    
                               1'b0,     // dmst_confstrptrvalid,    
                               4'd3  };    // dmst_version           }; 
         hart_resumeack_r  <= {NrHarts{1'b0}};
  end  // end of reset 
  else if (!dmc_active_o) begin   //!activeactive II2
       dm_status           <= {7'b0,             // dmst_zero2,          //0x11      
                               1'b0,             // dmst_ndmresetpending,    
                               1'b0,             // dmst_stickyunavail,      
                               1'b0,             // dmst_impebreak,          
                               2'b0,             // dmst_zero1,              
                               1'b0,             // dmst_allhavereset,       
                               1'b0,             // dmst_anyhavereset,       
                               1'b0,             // dmst_allresumeack,       
                               1'b0,             // dmst_anyresumeack,       
                               1'b0,             // dmst_allnonexistent,     
                               1'b0,             // dmst_anynonexistent,     
                               1'b0,             // dmst_allunavail,         
                               1'b0,             // dmst_anyunavail,         
                               1'b0,             // dmst_allrunning,         
                               1'b0,             // dmst_anyrunning,         
                               1'b0,             // dmst_allhalted,          
                               1'b0,             // dmst_anyhalted,          
                               1'b0,             // dmst_authenticated,          
                               1'b0,             // dmst_authbusy,           
                               1'b1,             // dmst_hasresethaltreq,    
                               1'b0,             // dmst_confstrptrvalid,    
                               4'd3  };          // dmst_version           };  
         hart_resumeack_r  <= {NrHarts{1'b0}};
    end
  else
  if (dbg_unlock_i_r == 2'b01)
  begin
         // dmstatus
         dm_status[31:20]   <= {7'b0,                    // dmst 0x11         dmst_zero2,
                                dmst_ndmrst,             // dmst_ndmresetpending,
                                1'b0,                    // dmst_stickyunavail,
                                1'b0,                    // dmst_impebreak,
                                2'b0};                   // dmst_zero1,
         dm_status[19:18]   <= {allhavereset_n,          // dmst_allhavereset,
                                anyhavereset_n};         // dmst_anyhavereset,
         dm_status[17:16]   <={ allresumeack_n,          // dmst_allresumeack,
                                anyresumeack_n};         // dmst_anyresumeack,
         dm_status[15:12]   <={ allnonexist,             // dmst_allnonexistent,
                                anynonexist,             // dmst_anynonexistent,
                                allunavail,              // dmst_allunavail,
                                anyunavail};             // dmst_anyunavail,

         dm_status[11:10]   <={ allhart_running,         // dmst_allrunning,
                                anyhart_running};        // dmst_anyrunning,
         dm_status[9:8]     <={ allhart_stop,            // dmst_allhalted,
                                anyhart_stop};           // dmst_anyhalted,
         dm_status[7:6]     <={ block_abc_cond_unlock,   // dmst_authenticated,
                                1'b0};                   // dmst_authbusy,
         dm_status[5:0]     <={ dm_status[5],            // dmst_hasresethaltreq, support halt-on-reset sequence
                                dm_status[4],            // dmst_confstrptrvalid, !sup
                                dm_status[3:0]};         // dmst_version
         if (dm_bnk_en_write && apb_touch_0x10) begin                       

// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: arc_halt_req_a arc_run_req_a dbg_apb_presetn_early Source signals from same domain converge after synchronization
// SJ:  events are orthogonal   
// spyglass disable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
// SMD: arc_halt_req_a arc_run_req_a dbg_apb_presetn_early Source signals from same domain converge after synchronization
// SJ:  events are orthogonal   
             if(i_pwdata_r[30] & hart_stop2run )begin      //w resumereq clear
              hart_resumeack_r[0]  <= 1'b0;
             end
// spyglass enable_block CDC_COHERENCY_ASYNCSRCS_RECONV_SEQ
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ

         end else begin                      //collect resume ack
              if ( hart_resumeack_i )
                hart_resumeack_r <= 1'b1 ;
         end
    end    
end // DM_STATUS_reg_PROC   


//abc transaction.
assign wr_mst_transfer = hmst_wr_resp_accept_o & hmst_wr_done_i;
assign rd_mst_transfer = hmst_rd_accept_o      & hmst_rd_valid_i;
assign abc_mst_transfer= wr_mst_transfer       | rd_mst_transfer; 

assign abc_addr_incr = (aarsize ==3'd3)? 4'd8 :
                       (aarsize ==3'd2)? 4'd4 : 
                       (aarsize ==3'd1)? 4'd2 : 4'd1; 
//------------------------------------------------------------
//hart ctrl sm  
//------------------------------------------------------------   
assign dm_hart_info  =  {8'b0,     // hinfo_hart_zero1,       //hinfo 0x12  
                         4'b1,     // hinfo_nscratch,         // debug doc.
                         3'b0,     // hinfo_hart_zero0,   
                         1'b0,     // hinfo_dataaccess,   
                         4'b1,     // hinfo_datasize,     
                         12'h7b3 };// hinfo_dataaddr    

assign hartsel_o     = {dmc_hartselhi, dmc_hartsello};

assign allhart_stop  = hart_stop2run & hart_sel[0] 

        && ((hart_stop2run & hart_sel[0]) | ~hart_sel[0] )
                           ;

assign anyhart_stop  = hart_stop2run & hart_sel[0] 

        || (hart_sel[0] & hart_stop2run)
                           ;
// spyglass disable_block Ac_conv01
// SMD: u_presetn_early_s and u_dm_arc_halt_req_sync synchronizers converge on flop hart_haltreq_selected
// SJ:  events are orthogonal  
assign allhart_running  = hart_run2stop & hart_sel[0]

           && ((hart_run2stop & hart_sel[0]) | ~hart_sel[0] )
                           ;   

assign anyhart_running  = hart_run2stop & hart_sel[0]

           || (hart_sel[0]& hart_run2stop)
                           ;   
// spyglass enable_block Ac_conv01  

assign hart_stop     = (hc_state_q == HART_STOP);  
assign hart_run2stop = hart_running | (hc_state_q == HART_STOPING);  
assign hart_running  = (hc_state_q == HART_RUNNING);   
assign hart_stop2run = hart_stop    |(hc_state_q == HART_RESUMING);   

// spyglass disable_block Ac_conv01
// SMD: u_presetn_early_s and u_dm_arc_halt_req_sync synchronizers converge on flop hart_haltreq_selected
// SJ:  events are orthogonal
always_comb
begin : p_hart_ctrl_sm_PROC
  hc_state_n            = hc_state_q;
  unique case (hc_state_q)
    HART_RESET    : begin
                      if(halt_on_reset_o ||sys_halt_r)begin  //setreq & ack -> halted
                        hc_state_n = HART_STOP;
                      end else                                       
                        hc_state_n = HART_RUNNING;
                    end

    HART_RUNNING  : begin   //4
                      if (halt_req_dm_soc     ) begin
                        hc_state_n = HART_STOPING;
                      end  
                      else if (sys_halt_r    ) begin
                        hc_state_n = HART_STOP;
                      end       
                    end  

    HART_STOPING  : begin  //5
                      if(halt_req_dm_soc)begin
                          if(hart_halted_i     ) begin    
// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: safety_iso_enb[1:0] clk Source signals from same domain converge after synchronization
// SJ:  events are orthogonal   
                        hc_state_n = HART_STOP;
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ
                          end 
                      end  
                      else if (sys_halt_r    ) begin
                        hc_state_n = HART_STOP;
                      end       
                    end

    HART_STOP     : begin  //6
                      if (run_req_dm_soc     ) begin
                        hc_state_n = HART_RESUMING;
                      end
                      else if (!sys_halt_r    ) begin
                        hc_state_n = HART_RUNNING;
                      end       
                    end

    HART_RESUMING : begin //7
                      if(run_req_dm_soc)begin
                          if(hart_resumeack_i     ) begin 
                        hc_state_n = HART_RUNNING;
                          end 
                      end  
                      else if (!sys_halt_r    ) begin
                        hc_state_n = HART_RUNNING;
                      end       
                    end
    default       : hc_state_n = HART_RESET ;
  endcase
// spyglass enable_block Ac_conv01  
end //p_hart_ctrl_sm_PROC

// ROM starts at the HaltAddress of the core e.g.: it immediately jumps to
// spyglass disable_block RDC_CORRUPT_OBSERVED
// SMD:need a sync synchronizer on sys_halt from core 
// SJ:     
always_ff @(posedge dm_clk_ug or posedge rst_a) begin : hart_control_reg_PROC   //cuz need update when !dm
  if (rst_a) begin
    hc_state_q         <= HART_RESET;
  end else begin
    hc_state_q         <= hc_state_n ;   
  end
end // hart_control_reg_PROC 
// spyglass enable_block RDC_CORRUPT_OBSERVED

//------------------------------------------------------------
//abs/abc sm   
//------------------------------------------------------------
//---DM/ soc req arb--------------------------------
assign req_fromdm = dmc_active_o & (!safety_iso_enb) ;
assign halt_req_dm[0] = hart_haltreq[0]   || soc_halt_req_queue0;  
assign run_req_dm[0]  = hart_resumereq[0] || soc_run_req_queue0 ;
//                                                  dm req     |      soc req         : soc req
assign halt_req_dm_soc[0] = req_fromdm ? (halt_req_dm[0] || arc_halt_req) : arc_halt_req ;
assign run_req_dm_soc[0]  = req_fromdm ? (run_req_dm[0]  || arc_run_req ) : arc_run_req  ;
always_ff @(posedge dm_clk_ug or posedge rst_a) begin : HART_RUN_REQ_QUEUE_reg_PROC  //queue soc run, dequeue when SM = running
  if (rst_a) begin
    soc_run_req_queue0     <= 1'b0;
  end else if(dmc_active_o)begin
      if((hart_run2stop) & hart_haltreq[0] & arc_run_req)// line 9
         soc_run_req_queue0 <= 1'b1 ;
      else if ((hart_run2stop) & !hart_haltreq[0])    // line 8
         soc_run_req_queue0 <= 1'b0 ;
  end
end // HART_RUN_REQ_QUEUE_PROC   

always_ff @(posedge dm_clk_ug or posedge rst_a) begin : HART_HALT_REQ_QUEUE_reg_PROC        //queue soc req, dequeue when SM = STOP
  if (rst_a) begin
    soc_halt_req_queue0    <= 1'b0;
  end else if(dmc_active_o) begin
      if( hart_stop2run &  hart_resumereq[0] & arc_halt_req)// line 2 
         soc_halt_req_queue0 <= 1'b1 ;
      else if (hart_stop2run & !hart_resumereq[0])  // line 4
         soc_halt_req_queue0 <= 1'b0 ;
  end      
end // HART_HALT_REQ_QUEUE_reg_PROC  
                    
//---DM/ soc req arb end--------------------------------
 

//---DM abs function start--------------------------------
assign err_eq0      = (dm_abs_ctrl_status[10:8] == 3'b0) ;  //w1c & size=64 in RL
assign err_eq0_n    = (abs_sm_err_n == 3'b0) || (abs_sm_err_n == 3'b1);  //w1c & size=64 in RL
assign addr_irq     = dm_bnk_en & ( ( (dm_write == 1'b1) & (apb_touch_0x16 | apb_touch_0x17 | apb_touch_0x18) )|
                                    ( (apb_touch_0x04 | apb_touch_0x05)      //32       
                                                  ));
assign abs_irq      = (dm_abs_ctrl_status[12] == 1'b1) & (addr_irq); //busy+irq
assign abc_fire     = (abs_transfer_posedge | abc_auto_fire );
// spyglass disable_block Ac_conv01
// SMD: u_presetn_early_s and u_dm_arc_halt_req_sync synchronizers converge on flop hart_haltreq_selected
// SJ:  events are orthogonal
always_comb 
begin : STATE_CTRL_ERROR_GEN_PROC  // issue command by transf 0x17
        abs_state_n = DM_ABS_IDLE;
        abs_sm_err_n = dmr_cmderr;
   case (abs_state_q)
    DM_ABS_RESET:   begin        //0
                       if(dmc_active_o) 
                         abs_state_n = DM_ABS_IDLE;
                       else
                         abs_state_n = DM_ABS_RESET;  
                    end

    DM_ABS_IDLE:   begin         //4
                     if (|(hmst_read_fire | hmst_write_fire)) begin //from 0x17 command issue 
                             abs_state_n = DM_ABS_RUNN;
                     end else begin
                       abs_state_n = DM_ABS_IDLE;
                       if(abc_fire)begin      //block fire and send errr.
                          if (unsupported_command)begin 
                            abs_sm_err_n = 3'd2;  
                          end else if(!aarsize_valid || !align_addr)begin   
                            abs_sm_err_n = 3'd5;  // 32 bus access size err
                          end else if(|bus_addrerr)begin   
                            abs_sm_err_n = 3'd3;  // 32 abc address out of range
                          end else if( |(hart_sel & hart_unavailable_i) )begin   
                            abs_sm_err_n = 3'd4;  // 32 abc access with unavailable
                          end
                       end
                     end  
                   end  

    DM_ABS_RUNN:   begin         //5
                     if(abs_irq)begin // got irq  err!!!!
                        abs_sm_err_n = 3'b1;
                        if(abc_mst_transfer) begin
                         abs_state_n = DM_ABS_EWAIT;
                        end else begin
                         abs_state_n = DM_ABS_EBUSY;                 //6     
                        end                             
                     end else if(abc_mst_transfer) begin
                        if( (!err_eq0) | (|bus_err) ) begin
                         abs_state_n = DM_ABS_EWAIT;
                        end else begin
                         abs_state_n = DM_ABS_IDLE;
                        end  

                        if( (|bus_err) ) begin 
                          if( accreg ) begin 
                             abs_sm_err_n = 3'd3;    //3'd3=reg !exist by spec
                          end else begin  //accmem
                             abs_sm_err_n = 3'd5;    //3'd5=mem PMP/PMA err or from ECC err violations.
                          end
                        end

                     end else begin
                       abs_state_n = DM_ABS_RUNN;
                     end
                   end       

    DM_ABS_EBUSY:  begin        //6
                        abs_sm_err_n = 3'h1;
                      if (abc_mst_transfer) begin  //compelete
                        abs_state_n  = DM_ABS_EWAIT;
                      end else begin
                        abs_state_n  = DM_ABS_EBUSY;
                      end
                   end

    DM_ABS_EWAIT:  begin        //7
                     if(err_eq0) begin      // TBD check the condition.
                       abs_state_n = DM_ABS_IDLE;
                     end else begin
                       abs_sm_err_n = 3'h1;
                       abs_state_n = DM_ABS_EWAIT;
                     end
                   end
    default     : abs_state_n = DM_ABS_RESET;
  endcase
end // STATE_CTRL_ERROR_GEN_PROC 
// spyglass enable_block Ac_conv01

always_ff @(posedge dm_clk or posedge rst_a) begin : ABC_STATE_reg_PROC
  if (rst_a) begin
    abs_state_q     <= DM_ABS_RESET;
  end else begin
    abs_state_q     <= abs_state_n & {3{dmc_active_o}} ;
  end
end // ABC_STATE_reg_PROC
      
assign cmdtype_n = (dm_bnk_en_write && apb_touch_0x17&&!dmr_busy)? i_pwdata_r[31:24]:cmdtype;      
always_comb
  begin : p_abc_cmd_type_PROC
      // this abstract command is currently unsupported
      accreg = 1'h0;
      accmem = 1'h0;        
      unsupported_command = 1'b0;  
      case (cmdtype_n)  
           8'h0: accreg = 1'b1; //Access Register Command
           8'h2: accmem = 1'b1; //Access Register Command
        default: unsupported_command = 1'b1;
      endcase 
  end   // p_abc_cmd_type_PROC    

//sysbuf 
//------------------------------------------------------------
//abc reg/mem control module  
//------------------------------------------------------------    

assign block_abc_cond_unlock = (dbg_unlock_i_r == 2'b01);

assign aarsize_n = (dm_bnk_en_write && apb_touch_0x17&&!dmr_busy)? i_pwdata_r[22:20]:aarsize ;  //0x17-new or 0x18-reg  
wire  [1:0] align_addr_mem;
assign align_addr_mem = (dm_bnk_en_write && apb_touch_0x05&&!dmr_busy) ? i_pwdata_r[1:0] : abs_data_r1[1:0];
assign align_addr    = accreg ? 1'b1 : 
                                (aarsize_n == 3'd2) ? ~|align_addr_mem[1:0] :
                                (aarsize_n == 3'd1) ? ~align_addr_mem[0]    : (aarsize_n == 3'd0);    
assign aarsize_valid = accreg ? (aarsize_n == 3'd2) :
                                (aarsize_n[2] == 1'b0) && (aarsize_n != 3'd3); //mem-012    

assign block_abc_cond = (dmr_cmderr == 3'b0) & block_abc_cond_unlock & align_addr & (~bus_addrerr) & aarsize_valid;
assign hmst_read_fire  =          (abs_transfer_posedge & !i_pwdata_r[16] | abc_auto_fire & !abs_cmd_write) & hart_sel_single[0]  & block_abc_cond & (~hart_unavailable_i); 
assign hmst_write_fire =          (abs_transfer_posedge &  i_pwdata_r[16] | abc_auto_fire &  abs_cmd_write) & hart_sel_single[0]  & block_abc_cond & (~hart_unavailable_i);

assign regno_n = (dm_bnk_en_write && apb_touch_0x17&&!dmr_busy)? i_pwdata_r[15:0] : regno;      // new value to adddr
assign abc_hmst_addr_i = {16'b0,regno_n}     &  {32{accreg}} |  // access regno 
                         abc_mem_addr_i;// &  {32{accmem}} ; 
assign abc_mem_addr_i  = accmem ? (  ( dm_bnk_en_write&&apb_touch_0x05&&!dmr_busy )? i_pwdata_r : 
                                                                                     abs_data_r1 ) : 
                                                                                         32'h0;   //only acc mem have value.
assign abc_hmst_wdata_i=( dm_bnk_en_write&&apb_touch_0x04&&!dmr_busy )? i_pwdata_r : abs_data_r0;
    assign abc_hmst_rdata_n = abc_hmst_rdata_i & {`HMIBP_DATA_W{hmst_rd_valid_i}}
    ;

dm_hmst #(
.HMIBP_ADDR_W   (`HMIBP_ADDR_W ),
.HMIBP_DATA_W   (`HMIBP_DATA_W ) 
) u_dm_hmst(
.dm_clk             (dm_clk),
.rst_a              (rst_a),
.dmactive_i         (dmc_active_o),

.hmstaddress_i      (abc_hmst_addr_i),
.hmstdata_i         (abc_hmst_wdata_i),     //abc DM to mst
.hmstdata_read_fire (hmst_read_fire),
.hmstdata_write_fire(hmst_write_fire),
.hmst_busy          (dmr_busy_n),
.hmsterr_o          (bus_err),
.hmstaddr_err_o     (bus_addrerr),
.hmstdata_o         (abc_hmst_rdata_i),     //abc to DM 
.cmdtype_i          (cmdtype_n),
.aarsize_i          (aarsize_n),

//1 cmd  
.cmd_valid_o        (hmst_cmd_valid_o),
.cmd_accept_i       (hmst_cmd_accept_i),
.cmd_read_o         (hmst_cmd_read_o),
.cmd_addr_o         (hmst_cmd_addr_o),
.cmd_space_o        (hmst_cmd_space_o),
//2 r data ch 
.rd_valid_i         (hmst_rd_valid_i),
.rd_accept_o        (hmst_rd_accept_o),
.rd_data_i          (hmst_rd_data_i),
.rd_err_i           (hmst_rd_err_i),
//3 w data ch  
.wr_valid_o         (hmst_wr_valid_o),
.wr_accept_i        (hmst_wr_accept_i),
.wr_data_o          (hmst_wr_data_o),
.wr_mask_o          (hmst_wr_mask_o),
//4 w resp ch       
.wr_done_i          (hmst_wr_done_i),
.wr_err_i           (hmst_wr_err_i),
.wr_resp_accept_o   (hmst_wr_resp_accept_o)
); 





endmodule //endof arctvt_dm
