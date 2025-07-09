// Library ARC_Soc_Trace-1.0.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protecteder copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Description:
// ===========================================================================
//
// Configuration-dependent macro definitions 
//
`include "defines.v"
`include "arcv_dm_defines.v"
// Set simulation timescale
//
`include "const.def"

module arcv_dm_top (

  ////////// DMI to DTM interface //////////////////////////////////////////
  // -- command
  // -- data
  // -- response
  //////////// Debug APB IF ///////////////
  input                      rv_dmihardresetn,
  input  [31:2]              dbg_apb_paddr,
  input                      dbg_apb_psel,
  input                      dbg_apb_penable,
  input                      dbg_apb_pwrite,
  input  [31:0]              dbg_apb_pwdata,
  output                     dbg_apb_pready,
  output [31:0]              dbg_apb_prdata,
  output                     dbg_apb_pslverr,

  ////////// IBP DM Initiator to HART interface //////////////////////////////////////////
  ////////// IBP debug interface //////////////////////////////////////////
  // Command channel
  output                     dbg_ibp_cmd_valid,      // valid command
  output                     dbg_ibp_cmd_read,       // read high, write low
  output  [`HMIBP_ADDR_W-1:0]dbg_ibp_cmd_addr,       // 
  input                      dbg_ibp_cmd_accept,     // 
  output  [3:0]              dbg_ibp_cmd_space,      // type of access

  // Read channel
  input                      dbg_ibp_rd_valid,       // valid read
  output                     dbg_ibp_rd_accept,      // rd input accepted by DM
  input                      dbg_ibp_rd_err,         //
  input [`HMIBP_DATA_W-1:0]  dbg_ibp_rd_data,        // rd input

  // Write channel
  output                     dbg_ibp_wr_valid,       //
  input                      dbg_ibp_wr_accept,      //
  output  [`HMIBP_DATA_W-1:0]dbg_ibp_wr_data,        // 
  output  [`HMIBP_DATA_W/8-1:0]dbg_ibp_wr_mask,        //

  //Write resp channel          
  input                      dbg_ibp_wr_done,        //
  output                     dbg_ibp_wr_resp_accept, //
  input                      dbg_ibp_wr_err,         //

  // -- command
  // -- data
  // -- response
  ////////// IBP DM Responder to HART interface //////////////////////////////////////////
  // -- command
  // -- data
  // -- response
  ////////// SBA Initiator interface //////////////////////////////////////////
  // -- 
  // -- 
  // -- 
  input   [1:0]              safety_iso_enb,          //
  output                     safety_iso_enb_a,        //
  output  [1:0]              safety_isol_change,      //
//Authentication module
  input   [1:0]              dbg_unlock,              //

 

  output                     dm2arc_halt_on_reset_a,// Async Req to dm
  input                      arc_halt_req_a,        // Async Req to dm
  input                      arc_run_req_a,         // Async Req to dm
  output                     arc_halt_ack,          // Core has Halted cleanly
  output                     arc_run_ack,           // Core has unHalted
  output                     dm2arc_hartreset_a,    // Core reset
  output                     dm2arc_hartreset2_a,   // Core custom0 reset
  output                     dm2arc_run_req_a,      // Async Req to Halt core
  output                     dm2arc_halt_req_a,     // Async Req to unHalt core
  output                     dm2arc_havereset_ack_a,// reset ack core2dm
  output                     dm2arc_relaxedpriv_a,  // reset ack core2dm
  input                      arc2dm_havereset_a,    // reset ack core2dm
  input                      arc2dm_run_ack,        // Core has Halted cleanly
  input                      arc2dm_halt_ack,       // Core has unHalted
  input                      sys_halt_r,            // Core is in halt state
  input                      hart_unavailable,            // Core is unavailable
  output                     ndmreset_a,                  // Core reset

  ////////// General input signals /////////////////////////////////////////////
  //
  input                      test_mode,                   // test_mode
  input                      clk,                         // clock signal
  input                      rst_a                        // reset signal
);  

  wire                      dbg_apb_pclk;
  wire                      dbg_apb_presetn;
  wire                      dbg_apb_presetn_early;
  assign                    dbg_apb_pclk = clk;
  assign                    dbg_apb_presetn_early = 1'b1;
  assign                    dbg_apb_presetn = rv_dmihardresetn;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Parameter definitions in the Debug module:                              //
//  There are three sets of local parameter definitions to guide the        //
//  behavior of the debug module, and one set of state definitions for the  //
//  debug instruction issue state machine.                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
wire dm_clk_ug;
wire dm_clk_cg;
wire dmc_active_o;

wire                       dbg_apb_psel_dm_i;      
wire                       dbg_apb_penable_dm_i;
wire [31:2]                dbg_apb_paddr_dm_i;
wire [31:0]                dbg_apb_pwdata_dm_i;
      





wire                       rst_a_sync;
wire                       rst_a_s;
wire                       dbg_apb_presetn_sync;
wire                       dbg_apb_presetn_s;  
wire                       dbg_apb_presetn_early_sync;

dm_cgm u_dm_cgm (
.clk               (clk),
.rst_a             (rst_a_s),
.dm_clken          (dmc_active_o & (safety_iso_enb_a ==1'b0)),
.clk_ug            (dm_clk_ug),
.clk_cg            (dm_clk_cg)
);

dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_rst_cdc_s_sync_r_s (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a),
                                   .din   (1'b1),
                                   .dout  (rst_a_sync)
                                  );   

dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_presetdbg_cdc_s (
                                   .clk   (dbg_apb_pclk),
                                   .rst_a (~dbg_apb_presetn),
                                   .din   (1'b1),
                                   .dout  (dbg_apb_presetn_sync)
                                  );       

// spyglass disable_block TA_09 
// SMD: The primary input reset signal is controlled by the test state machine and will typically receive a non-asserting value in the ATPG patterns.
// SJ:  acceptable loss of coverage  
assign rst_a_s = test_mode ? rst_a : !rst_a_sync; 

assign dbg_apb_presetn_s = test_mode ? dbg_apb_presetn : dbg_apb_presetn_sync;   
// spyglass enable_block TA_09    

dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_presetn_early_s (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (dbg_apb_presetn_early),
                                   .dout  (dbg_apb_presetn_early_sync)
                                  );       

wire [1-1:0]  arc2dm_run_ack_sync_r;
wire [1-1:0]  arc2dm_halt_ack_sync_r;
wire [1-1:0]  arc2dm_hart_unavailable_r;
wire [1-1:0]  arc2dm_havereset_sync_r;
wire                       arc_halt_req_sync_r;
wire                       arc_run_req_sync_r;
wire                       sys_halt_r3;

dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_dm_arc2dm_run_sync (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (arc2dm_run_ack),
                                   .dout  (arc2dm_run_ack_sync_r[0])
                                  );
dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_dm_arc2dm_unavailable_sync (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (hart_unavailable),
                                   .dout  (arc2dm_hart_unavailable_r[0])
                                  ); 
dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_dm_arc2dm_halt_sync (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (arc2dm_halt_ack),
                                   .dout  (arc2dm_halt_ack_sync_r[0])
                                  );
dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_dm_sys_halt_r (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (sys_halt_r),
                                   .dout  (sys_halt_r3)
                                  );  
 dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_dm_havereset_ack_sync (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (arc2dm_havereset_a),
                                   .dout  (arc2dm_havereset_sync_r[0])
                                  );  
 dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_dm_arc_halt_req_sync (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (arc_halt_req_a),
                                   .dout  (arc_halt_req_sync_r)
                                  );  
 dm_cdc_sync #(.SYNC_FF_LEVELS(`DM_SYNC_FF_LEVELS)
              ) u_dm_arc_run_req_sync (
                                   .clk   (dm_clk_ug),
                                   .rst_a (rst_a_s),
                                   .din   (arc_run_req_a),
                                   .dout  (arc_run_req_sync_r)
                                  );  
                                    

//safety_enb_iso              
  //////////// Debug APB IF ///////////////  
  wire                     dbg_apb_pready_dm_o;              
  wire [31:0]              dbg_apb_prdata_dm_o;              
  wire                     dbg_apb_pslverr_dm_o;             
  ////////// IBP debug interface //////////////////////////////////////////
  // Command channel
  wire                     dbg_ibp_cmd_valid_dm_o;  // valid command
  wire                     dbg_ibp_cmd_read_dm_o;   // read high_dm_o; write low
  wire [`HMIBP_ADDR_W-1:0]   dbg_ibp_cmd_addr_dm_o;   //  
  wire [3:0]               dbg_ibp_cmd_space_dm_o;  // type of access
  wire                     dbg_ibp_cmd_accept_dm_i; // type of access

  // Read channel
  wire                     dbg_ibp_rd_accept_dm_o;  // rd input accepted by DM
  wire                     dbg_ibp_rd_valid_dm_i;   // rd input accepted by DM
  wire                     dbg_ibp_rd_err_dm_i;     // rd input accepted by DM
  wire [`HMIBP_DATA_W-1:0]   dbg_ibp_rd_data_dm_i;    //       
  // Write channel
  wire                     dbg_ibp_wr_valid_dm_o; 
  wire                     dbg_ibp_wr_accept_dm_i;
  wire [`HMIBP_DATA_W-1:0] dbg_ibp_wr_data_dm_o;  
  wire [`HMIBP_DATA_W/8-1:0]dbg_ibp_wr_mask_dm_o;  
  // Write resp channel
  wire                     dbg_ibp_wr_done_dm_i;  
  wire                     dbg_ibp_wr_err_dm_i;   
  wire                     dbg_ibp_wr_resp_accept_dm_o;   


  //sfty_i/o              
    // Command channel
    wire                   dbg_ibp_cmd_valid_sfty_o;  // valid command
    // Read channel
    wire                   dbg_ibp_rd_accept_sfty_o;  // rd input accepted by DM
    // Write channel
    wire                   dbg_ibp_wr_valid_sfty_o;   //

arcv_dm   #(.NrHarts       (1),
            .DataCount     (1),
            .ProgBufSize   (0)
            ) u_arcvt_dm (                           
  //sys if
  .dm_clk       (dm_clk_cg),          // clock gated main clock
  .dm_clk_ug    (dm_clk_ug),          // ungated main clock
  .rst_a        (rst_a_s),            // Reset
  .dmc_active_o (dmc_active_o),       // dmactive
  .safety_iso_enb(safety_iso_enb_a),  //for safety req mux 
  //jtag IF (apb)
  .pclkdbg          (dbg_apb_pclk),               // dmi clk
  .presetdbgn       (dbg_apb_presetn_s),          // dmi reset, active low
  .presetdbgn_early (dbg_apb_presetn_early_sync), // dmi reset cg, active low
  .psel_dm          (dbg_apb_psel_dm_i),          // device select
  .penable_dm       (dbg_apb_penable_dm_i),       // 2nd & subsequence cycle of APB transfer
  .paddr_dm         (dbg_apb_paddr_dm_i),         // debug apb address
  .pwrite_dm        (dbg_apb_pwrite),             // write access(), active high
  .pwdata_dm        (dbg_apb_pwdata_dm_i),        // write data
  .pready_dm        (dbg_apb_pready_dm_o),
  .prdata_dm        (dbg_apb_prdata_dm_o),        // read data
  .pslverr_dm       (dbg_apb_pslverr_dm_o),       // TBD come from hart ctrl.

//IBP IF for hmst(M)
//1 cmd
  .hmst_cmd_valid_o     (dbg_ibp_cmd_valid_dm_o),
  .hmst_cmd_accept_i    (dbg_ibp_cmd_accept_dm_i),
  .hmst_cmd_read_o      (dbg_ibp_cmd_read_dm_o),
  .hmst_cmd_addr_o      (dbg_ibp_cmd_addr_dm_o),
  .hmst_cmd_space_o     (dbg_ibp_cmd_space_dm_o),
//2 r data ch
  .hmst_rd_valid_i      (dbg_ibp_rd_valid_dm_i),
  .hmst_rd_accept_o     (dbg_ibp_rd_accept_dm_o),
  .hmst_rd_data_i       (dbg_ibp_rd_data_dm_i),
  .hmst_rd_err_i        (dbg_ibp_rd_err_dm_i),
//3 w data ch
  .hmst_wr_valid_o      (dbg_ibp_wr_valid_dm_o),
  .hmst_wr_accept_i     (dbg_ibp_wr_accept_dm_i),
  .hmst_wr_data_o       (dbg_ibp_wr_data_dm_o),
  .hmst_wr_mask_o       (dbg_ibp_wr_mask_dm_o),
//4 w resp ch
  .hmst_wr_done_i       (dbg_ibp_wr_done_dm_i),
  .hmst_wr_err_i        (dbg_ibp_wr_err_dm_i),
  .hmst_wr_resp_accept_o(dbg_ibp_wr_resp_accept_dm_o),


  //Authentication module
  .dbg_unlock_i             (dbg_unlock),

//hart status
  .hart_halted_i            (arc2dm_halt_ack_sync_r),      // halted
  .hart_unavailable_i       (arc2dm_hart_unavailable_r),     // e.g.: powered down from each core
  .hart_resumeack_i         (arc2dm_run_ack_sync_r),    // resume ack
  .arc_havereset_i          (arc2dm_havereset_sync_r),    //hvreset core2dm 
//SOC hart/resume IF
  .halt_on_reset_o    (dm2arc_halt_on_reset_a), //[o]
  .arc_halt_req       (arc_halt_req_sync_r),         //[i]
  .arc_run_req        (arc_run_req_sync_r),          //[i]
  .arc_halt_ack       (arc_halt_ack),           //[o]
  .arc_run_ack        (arc_run_ack),            //[o]
  .hart_reset_o       (dm2arc_hartreset_a),     //reset core N-bits
  .hart_reset2_o      (dm2arc_hartreset2_a),     //reset custom0 N-bits
  .hart_haltreq_o     (dm2arc_halt_req_a),      //halt req(),   from dmcreg
  .hart_resumereq_o   (dm2arc_run_req_a),       //resume req(), from dmcreg
  .dm_havereset_ack_o (dm2arc_havereset_ack_a),    //reset ack dm2core 
  .dm_relaxedpriv_o   (dm2arc_relaxedpriv_a),    //reset ack dm2core 
  .sys_halt_r         (sys_halt_r3),             //sys_halt_r sync
  .hart_ndm_rst(ndmreset_a)              //resume clr(), after resume
);


// no src sync.                                               //[i]
//[i]
   assign dbg_ibp_cmd_valid      = dbg_ibp_cmd_valid_sfty_o;     //>>
   assign dbg_ibp_rd_accept      = dbg_ibp_rd_accept_sfty_o;     //>>
   assign dbg_ibp_wr_valid       = dbg_ibp_wr_valid_sfty_o;      //>>
   // Command channel
   assign dbg_ibp_cmd_read       = dbg_ibp_cmd_read_dm_o;        //>>
   assign dbg_ibp_cmd_addr       = dbg_ibp_cmd_addr_dm_o;        //>>
   assign dbg_ibp_cmd_space      = dbg_ibp_cmd_space_dm_o;        //>>
   assign dbg_ibp_cmd_accept_dm_i= dbg_ibp_cmd_accept;           //<<
   // Read channel
   assign dbg_ibp_rd_err_dm_i    = dbg_ibp_rd_err;               //<<
   assign dbg_ibp_rd_data_dm_i   = dbg_ibp_rd_data;              //<<
   assign dbg_ibp_rd_valid_dm_i  = dbg_ibp_rd_valid;             //<<
   // Write channel
   assign dbg_ibp_wr_data        = dbg_ibp_wr_data_dm_o;         //>>
   assign dbg_ibp_wr_mask        = dbg_ibp_wr_mask_dm_o;         //>>
   assign dbg_ibp_wr_accept_dm_i = dbg_ibp_wr_accept;            //<<
   // Write resp channel
   assign dbg_ibp_wr_resp_accept = dbg_ibp_wr_resp_accept_dm_o;  //>>
   assign dbg_ibp_wr_done_dm_i   = dbg_ibp_wr_done;              //<<
   assign dbg_ibp_wr_err_dm_i    = dbg_ibp_wr_err;               //<<



safety_iso_sync u_safety_iso_sync(
  .safety_iso_enb      (safety_iso_enb), 
  .safety_iso_enb_sync (safety_iso_enb_a), 
  .safety_isol_change  (safety_isol_change), 
  .clk                 (dm_clk_ug), 
  .rst                 (rst_a_s) 
);
//safety_enb_iso              
  //////////// Debug APB IF ///////////////  
  assign             dbg_apb_pready  = dbg_apb_pready_dm_o;       
  assign             dbg_apb_prdata  = dbg_apb_prdata_dm_o;              
  assign             dbg_apb_pslverr = dbg_apb_pslverr_dm_o;      
  //iso input
  assign             dbg_apb_psel_dm_i    =  dbg_apb_psel    ;      
  assign             dbg_apb_penable_dm_i =  dbg_apb_penable ;   
  assign             dbg_apb_paddr_dm_i   =  dbg_apb_paddr    ;      
  assign             dbg_apb_pwdata_dm_i  =  dbg_apb_pwdata   ;      
  ////////// IBP debug interface //////////////////////////////////////////     face /////////////////
  // Command channel                                                                          
  assign             dbg_ibp_cmd_valid_sfty_o = (safety_iso_enb_a ==1'b0)? dbg_ibp_cmd_valid_dm_o : 1'b0 ;                             // valid command
  // Read channel                                                                                       
  assign             dbg_ibp_rd_accept_sfty_o = (safety_iso_enb_a ==1'b0)? dbg_ibp_rd_accept_dm_o : 1'b0 ;                             // rd input accepted by DM
  // Write channel                                                                                    
  assign             dbg_ibp_wr_valid_sfty_o  = (safety_iso_enb_a ==1'b0)? dbg_ibp_wr_valid_dm_o  : 1'b0 ;                             //

endmodule // rv_dm_top
