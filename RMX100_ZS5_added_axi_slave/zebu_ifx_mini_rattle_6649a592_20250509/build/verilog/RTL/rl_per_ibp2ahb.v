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
`include "ifu_defines.v"
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

// spyglass disable_block Topology_02
// SMD: direct connection from input port to output port
// SJ:  None-registered interface, potential combination loop should be taken care when integration

module rl_per_ibp2ahb (
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  input  [`WID_RANGE]       cmd_wid,
  ////////// LSQ IBP per interface ////////////////////////////////////////////////
  //
  input                     lsq_per_cmd_valid, 
  input [3:0]               lsq_per_cmd_cache, 
  input                     lsq_per_cmd_burst_size,                 
  input                     lsq_per_cmd_read,                
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                     lsq_per_cmd_aux,  
// spyglass enable_block W240
  output reg                lsq_per_cmd_accept,              
  input [`ADDR_RANGE]       lsq_per_cmd_addr,                             
  input                     lsq_per_cmd_excl,
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input [5:0]               lsq_per_cmd_atomic,
// spyglass enable_block W240
  input [2:0]               lsq_per_cmd_data_size,                
  input [1:0]               lsq_per_cmd_prot,                

  input                     lsq_per_wr_valid,    
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                     lsq_per_wr_last, 
// spyglass enable_block W240
  output reg                lsq_per_wr_accept,   
  input [3:0]               lsq_per_wr_mask,    
  input [31:0]              lsq_per_wr_data,    
  
  output reg                lsq_per_rd_valid,                
  output reg                lsq_per_rd_err,                
  output reg                lsq_per_rd_excl_ok,
  output reg                lsq_per_rd_last,                 
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                     lsq_per_rd_accept, 
// spyglass enable_block W240
  output reg  [31:0]        lsq_per_rd_data,     
  
  output                    lsq_per_wr_done,
  output                    lsq_per_wr_excl_okay,
  output                    lsq_per_wr_err,
  input                     lsq_per_wr_resp_accept,

  ////////// AHB5 initiator ////////////////////////////////////////////////
  //
  output reg                dbu_per_ahb_hlock,
  output reg                dbu_per_ahb_hexcl,
  output reg [3:0]          dbu_per_ahb_hmaster,

  output reg [`AUSER_RANGE] dbu_per_ahb_hauser,
  output reg                dbu_per_ahb_hwrite,
  output reg [`ADDR_RANGE]  dbu_per_ahb_haddr,
  output reg [1:0]          dbu_per_ahb_htrans,
  output reg [2:0]          dbu_per_ahb_hsize,
  output reg [2:0]          dbu_per_ahb_hburst,
  output reg [3:0]          dbu_per_ahb_hwstrb,
  output reg [6:0]          dbu_per_ahb_hprot,
  output reg                dbu_per_ahb_hnonsec,
  input                     dbu_per_ahb_hready,
  input                     dbu_per_ahb_hresp,
  input                     dbu_per_ahb_hexokay,
  input  [`DATA_RANGE]      dbu_per_ahb_hrdata,
  output reg [`DATA_RANGE]  dbu_per_ahb_hwdata,

 ///////// AHB5 bus protection signals /////////////////////////////////////
 //
  output [`AUSER_PTY_RANGE] dbu_per_ahb_hauserchk,
  output [`ADDR_PTY_RANGE]  dbu_per_ahb_haddrchk,
  output                    dbu_per_ahb_htranschk,
  output                    dbu_per_ahb_hctrlchk1,      // Parity of dbu_per_ahb_hburst, dbu_per_ahb_hlock, dbu_per_ahb_hwrite, dbu_per_ahb_hsize
  output                    dbu_per_ahb_hctrlchk2,      // Parity of dbu_per_ahb_hexcl, dbu_per_ahb_hmaster
  output                    dbu_per_ahb_hprotchk,
  output                    dbu_per_ahb_hwstrbchk,
  input                     dbu_per_ahb_hreadychk,
  input                     dbu_per_ahb_hrespchk,       // Parity of dbu_per_ahb_hresp, dbu_per_ahb_hexokay
  input  [`DATA_PTY_RANGE]  dbu_per_ahb_hrdatachk,
  output [`DATA_PTY_RANGE]  dbu_per_ahb_hwdatachk,

  output                    dbu_per_ahb_fatal_err,
 
  ///////// BIU idle signals ////////////////////////////////////////////////////
  //
  output                    biu_dbu_per_idle,

  ////////// General input signals /////////////////////////////////////////////
  //
  input                     clk,                   // clock signal
  input                     rst_a                  // reset signal

);

///////////////////////////////////////////////////////////////////////////////
// This is an adapter that converts IBP to AHB-Lite. The AHB-Lite I/O may be 
// registerd or not-registered, depending on a configuration option
//
//////////////////////////////////////////////////////////////////////////////////
localparam BIU_CMD_DEFAULT = 2'b00;
localparam BIU_CMD_WDATA   = 2'b01;
localparam BIU_CMD_BURST   = 2'b10;
localparam BIU_CMD_WAIT    = 2'b11;

localparam BIU_RESP_ADDR_PHASE          = 2'b00;
localparam BIU_RESP_DATA_PHASE          = 2'b01;
localparam BIU_RESP_MULTIPLE_DATA_PHASE = 2'b10;
localparam BIU_RESP_ERROR               = 2'b11;

localparam AHB_SINGLE = 3'b000;   
localparam AHB_INCR   = 3'b001;
localparam AHB_WRAP4  = 3'b010;
localparam AHB_INCR4  = 3'b011;
localparam AHB_WRAP8  = 3'b100;
localparam AHB_INCR8  = 3'b101;
localparam AHB_WRAP16 = 3'b110;
localparam AHB_INCR16 = 3'b111;
localparam AHB_IDLE         =  2'b00;
localparam AHB_BUSY         =  2'b01;
localparam AHB_NONSEQ       =  2'b10;
localparam AHB_SEQ          =  2'b11;
localparam AHB_BYTE         =  3'b000;
localparam AHB_HALF_WORD    =  3'b001;
localparam AHB_WORD         =  3'b010;
localparam AHB_LITE_OKAY    = 1'b0;
localparam AHB_LITE_ERROR   = 1'b1;

reg               biu_cmd_burst_count_cg0;

reg [`ADDR_RANGE] biu_cmd_addr_r; 
reg               biu_cmd_read_r;
reg [6:0]         biu_cmd_prot_r;
reg [2:0]         biu_cmd_data_size_r;
reg [2:0]         biu_cmd_burst_r;
reg [3:0]         biu_cmd_wstrb_r;
reg               biu_cmd_excl_r;
reg [`DATA_RANGE] biu_wr_data_r;

reg [`ADDR_RANGE] biu_cmd_addr_nxt; 
reg               biu_cmd_read_nxt;
reg [6:0]         biu_cmd_prot_nxt;
reg [2:0]         biu_cmd_data_size_nxt;
reg [2:0]         biu_cmd_burst_nxt;
reg [3:0]         biu_cmd_wstrb_nxt;
reg               biu_cmd_excl_nxt;
reg [`DATA_RANGE] biu_wr_data_nxt;
reg               biu_wr_data_cg;

reg [`WID_RANGE]  biu_cmd_wid_r;
reg [`WID_RANGE]  biu_cmd_wid_nxt;

reg               biu_cmd_burst_count_r;
reg               biu_cmd_burst_count_nxt;

reg               biu_cmd_cg0;
reg [1:0]         biu_cmd_state_r;       
reg [1:0]         biu_cmd_state_nxt;

reg               biu_resp_cg0;
reg [1:0]         biu_resp_state_r;
reg [1:0]         biu_resp_state_nxt;

reg               biu_pending_rd_r;
reg               biu_pending_rd_nxt;
reg               biu_pending_wr_r;
reg               biu_pending_wr_nxt;

reg               lsq_per_wr_done_w;
reg               lsq_per_wr_done_r;
reg               lsq_per_wr_done_set;
reg               lsq_per_wr_done_clr;
wire              lsq_per_wr_done_nxt;

reg               lsq_per_wr_err_w;
reg               lsq_per_wr_err_r;
reg               lsq_per_wr_err_set;
reg               lsq_per_wr_err_clr;
wire              lsq_per_wr_err_nxt;

reg               lsq_per_wr_excl_okay_w;
reg               lsq_per_wr_excl_okay_r;
reg               lsq_per_wr_excl_okay_set;
reg               lsq_per_wr_excl_okay_clr;
wire              lsq_per_wr_excl_okay_nxt;

reg  [2:0]        ahb_hburst_w;
reg  [2:0]        ahb_hsize_w;

assign            biu_dbu_per_idle = (biu_cmd_state_r == BIU_CMD_DEFAULT) & (biu_resp_state_r == BIU_RESP_ADDR_PHASE) & !lsq_per_cmd_valid & !lsq_per_wr_done;

/////////////////////////////////////////////////////////////////////////////
//
// Parity signals declarations
//
/////////////////////////////////////////////////////////////////////////////
wire [8:0] dbu_per_ahb_hctrl1;
wire [4:0] dbu_per_ahb_hctrl2;
wire [1:0] dbu_per_ahb_hresp_in;
wire       dbu_per_ahb_hready_pty_err;
wire       dbu_per_ahb_hresp_pty_err;
wire [`DATA_PTY_RANGE] dbu_per_ahb_hrdata_pty_err;


wire [`ADDR_RANGE] ibp_cmd_addr_aligned = (lsq_per_cmd_addr >> lsq_per_cmd_data_size) << lsq_per_cmd_data_size;

always @*
begin : hburst_comb_PROC
  case (lsq_per_cmd_burst_size)
   1'd0:   ahb_hburst_w = AHB_SINGLE;
      default : ahb_hburst_w = AHB_INCR;
  endcase
end

always @*
begin : hsize_comb_PROC
  case (dbu_per_ahb_hsize)
   3'b000: ahb_hsize_w = 3'd1;
   3'b001: ahb_hsize_w = 3'd2;
   3'b010: ahb_hsize_w = 3'd4;
   default: ahb_hsize_w = 3'd4;
  endcase
end

///////////////////////////////////////////////////////////////////
//Command FSM
///////////////////////////////////////////////////////////////////
always @*
begin : biu_cmd_fsm_PROC
  // Default values
  //
  lsq_per_cmd_accept       = 1'b0;
  
  // AHB5 address and control
  //
  dbu_per_ahb_htrans           = AHB_IDLE;
  dbu_per_ahb_hwrite           = 1'b0;
  dbu_per_ahb_haddr            = {`ADDR_SIZE{1'b0}};
  dbu_per_ahb_hsize            = AHB_WORD;  
  dbu_per_ahb_hburst           = AHB_SINGLE;   
  dbu_per_ahb_hprot            = 7'h0;
  dbu_per_ahb_hnonsec          = 1'b1;
  dbu_per_ahb_hlock            = 1'b0;
  dbu_per_ahb_hexcl            = 1'b0;
  dbu_per_ahb_hmaster          = 4'h0;
  dbu_per_ahb_hexcl            = 1'b0;
  dbu_per_ahb_hauser           = `AUSER_BITS'b0;
  
  
  biu_cmd_burst_count_cg0  = 1'b1;
  biu_cmd_burst_count_nxt  = biu_cmd_burst_count_r;
  
  biu_cmd_addr_nxt         = biu_cmd_addr_r;
  biu_cmd_read_nxt         = biu_cmd_read_r;
  biu_cmd_prot_nxt         = biu_cmd_prot_r;
  biu_cmd_data_size_nxt    = biu_cmd_data_size_r;
  biu_cmd_burst_nxt        = biu_cmd_burst_r;
  biu_cmd_wstrb_nxt        = biu_cmd_wstrb_r;
  biu_cmd_excl_nxt         = biu_cmd_excl_r;
  biu_cmd_wid_nxt          = biu_cmd_wid_r;
  
  biu_cmd_cg0              = 1'b1;
  biu_cmd_state_nxt        = biu_cmd_state_r;
  
  case (biu_cmd_state_r)
  BIU_CMD_DEFAULT:
  begin
    biu_cmd_cg0            = lsq_per_cmd_valid;

    if (lsq_per_cmd_valid)
    begin
	  biu_cmd_wid_nxt          = cmd_wid;
	  if ((lsq_per_wr_valid == 1'b0) && (lsq_per_cmd_read == 1'b0))
      begin
        biu_cmd_state_nxt       = BIU_CMD_WDATA;
	  end
	  else
	  begin
        lsq_per_cmd_accept       = dbu_per_ahb_hready;
        
        // Drive AHB signnals
        //
        dbu_per_ahb_htrans               = AHB_NONSEQ;
	    dbu_per_ahb_hwrite               = (~lsq_per_cmd_read);
        dbu_per_ahb_haddr                = ibp_cmd_addr_aligned;
        dbu_per_ahb_hsize                = lsq_per_cmd_data_size;
        dbu_per_ahb_hburst               = ahb_hburst_w;
        dbu_per_ahb_hprot                = {3'h0,|lsq_per_cmd_cache[3:2]&lsq_per_cmd_cache[1],lsq_per_cmd_cache[0],lsq_per_cmd_prot[0],~lsq_per_cmd_prot[1]};
	    dbu_per_ahb_hexcl                = lsq_per_cmd_excl; 
		dbu_per_ahb_hauser[`AUSER_WID_RANGE] = cmd_wid;

        if (dbu_per_ahb_hready == 1'b0)
        begin
          // IBP command not accepted
          //
          biu_cmd_state_nxt       = BIU_CMD_WAIT;
        end
        else if (|lsq_per_cmd_burst_size)
        begin
          biu_cmd_burst_count_cg0  = 1'b1;
          biu_cmd_state_nxt        = BIU_CMD_BURST;
        end
	  end
	  if (lsq_per_cmd_accept)
	  begin
        biu_cmd_burst_count_nxt  = lsq_per_cmd_burst_size;
// spyglass disable_block W164a
// SMD: LHS is less than RHS         
// SJ:  Intended as per the design. No possible loss of data
        biu_cmd_addr_nxt         = ibp_cmd_addr_aligned + ahb_hsize_w;
// spyglass enable_block W164a
        biu_cmd_read_nxt         = lsq_per_cmd_read;
        biu_cmd_prot_nxt         = {3'h0,|lsq_per_cmd_cache[3:2]&lsq_per_cmd_cache[1],lsq_per_cmd_cache[0],lsq_per_cmd_prot[0],~lsq_per_cmd_prot[1]};
	    biu_cmd_data_size_nxt    = lsq_per_cmd_data_size;
	    biu_cmd_burst_nxt        = ahb_hburst_w;
	    biu_cmd_excl_nxt         = lsq_per_cmd_excl;

        if (lsq_per_wr_valid)
	    begin
          biu_cmd_wstrb_nxt        = lsq_per_cmd_read ? 4'h0: lsq_per_wr_mask;
//		  biu_wr_data_nxt          = lsq_per_wr_data;
	    end
      end
    end
  end

  BIU_CMD_WDATA:
  begin
    if (lsq_per_wr_valid)
	begin
      lsq_per_cmd_accept       = dbu_per_ahb_hready;
      
      // Drive AHB signnals
      //
      dbu_per_ahb_htrans               = AHB_NONSEQ;
	  dbu_per_ahb_hwrite               = (~lsq_per_cmd_read);
      dbu_per_ahb_haddr                = ibp_cmd_addr_aligned;
      dbu_per_ahb_hsize                = lsq_per_cmd_data_size;
      dbu_per_ahb_hburst               = ahb_hburst_w;
      dbu_per_ahb_hprot                = {3'h0,|lsq_per_cmd_cache[3:2]&lsq_per_cmd_cache[1],lsq_per_cmd_cache[0],lsq_per_cmd_prot[0],~lsq_per_cmd_prot[1]};
	  dbu_per_ahb_hexcl                = lsq_per_cmd_excl;
		dbu_per_ahb_hauser[`AUSER_WID_RANGE] = biu_cmd_wid_r;

	  if (lsq_per_cmd_accept)
	  begin
        biu_cmd_burst_count_nxt  = lsq_per_cmd_burst_size;
// spyglass disable_block W164a
// SMD: LHS is less than RHS
// SJ:  Intended as per the design. No possible loss of data
        biu_cmd_addr_nxt         = ibp_cmd_addr_aligned + ahb_hsize_w;
// spyglass enable_block W164a
        biu_cmd_read_nxt         = lsq_per_cmd_read;
        biu_cmd_prot_nxt         = {3'h0,|lsq_per_cmd_cache[3:2]&lsq_per_cmd_cache[1],lsq_per_cmd_cache[0],lsq_per_cmd_prot[0],~lsq_per_cmd_prot[1]};
	    biu_cmd_data_size_nxt    = lsq_per_cmd_data_size;
	    biu_cmd_burst_nxt        = ahb_hburst_w;
	    biu_cmd_excl_nxt         = lsq_per_cmd_excl;

        biu_cmd_wstrb_nxt        = lsq_per_cmd_read ? 4'h0: lsq_per_wr_mask;
//		biu_wr_data_nxt          = lsq_per_wr_data;
      end

      if (dbu_per_ahb_hready == 1'b0)
      begin
        // IBP command not accepted
        //
        biu_cmd_state_nxt       = BIU_CMD_WAIT;
      end
      else if (|lsq_per_cmd_burst_size)
      begin
        biu_cmd_burst_count_cg0  = 1'b1;
        biu_cmd_state_nxt        = BIU_CMD_BURST;
      end
	  else
	  begin
        biu_cmd_state_nxt        = BIU_CMD_DEFAULT;
	  end
	end
  end
  
  BIU_CMD_WAIT:
  begin
    lsq_per_cmd_accept       = dbu_per_ahb_hready;
    
    // Drive AHB signnals
    //
    dbu_per_ahb_htrans               = AHB_NONSEQ;
	dbu_per_ahb_hwrite               = (~lsq_per_cmd_read);
    dbu_per_ahb_haddr                = ibp_cmd_addr_aligned;
    dbu_per_ahb_hsize                = lsq_per_cmd_data_size;
    dbu_per_ahb_hburst               = ahb_hburst_w;
    dbu_per_ahb_hprot                = {3'h0,|lsq_per_cmd_cache[3:2]&lsq_per_cmd_cache[1],lsq_per_cmd_cache[0],lsq_per_cmd_prot[0],~lsq_per_cmd_prot[1]};
	dbu_per_ahb_hexcl                = lsq_per_cmd_excl;
		dbu_per_ahb_hauser[`AUSER_WID_RANGE] = biu_cmd_wid_r;
    
	if (lsq_per_cmd_accept)
	begin
      biu_cmd_burst_count_nxt  = lsq_per_cmd_burst_size;
// spyglass disable_block W164a
// SMD: LHS is less than RHS
// SJ:  Intended as per the design. No possible loss of data
      biu_cmd_addr_nxt         = ibp_cmd_addr_aligned + ahb_hsize_w;
// spyglass enable_block W164a
      biu_cmd_read_nxt         = lsq_per_cmd_read;
      biu_cmd_prot_nxt         = dbu_per_ahb_hprot;
	  biu_cmd_data_size_nxt    = lsq_per_cmd_data_size;
	  biu_cmd_burst_nxt        = ahb_hburst_w;
      biu_cmd_wstrb_nxt        = lsq_per_cmd_read ? 4'h0: lsq_per_wr_mask;
	  biu_cmd_excl_nxt         = lsq_per_cmd_excl;
//	  biu_wr_data_nxt          = lsq_per_wr_data;
	end
    
    if (dbu_per_ahb_hready == 1'b1)
    begin
      lsq_per_cmd_accept = 1'b1;
      
      if (|lsq_per_cmd_burst_size)
      begin
        biu_cmd_burst_count_cg0 = 1'b1;
        biu_cmd_state_nxt       = BIU_CMD_BURST;
      end
      else
      begin
        biu_cmd_state_nxt       = BIU_CMD_DEFAULT;
      end
    end
  end
  
  default: // BIU_CMD_BURST
  begin
    biu_cmd_burst_count_cg0 = dbu_per_ahb_hready;
    biu_cmd_burst_count_nxt = biu_cmd_burst_count_r - 1'b1;
// spyglass disable_block W164a
// SMD: LHS is less than RHS
// SJ:  Intended as per the design. No possible loss of data
    biu_cmd_addr_nxt        = biu_cmd_addr_r + ahb_hsize_w;
// spyglass enable_block W164a

//	biu_cmd_wstrb_nxt       = biu_cmd_read_r ? 4'h0: lsq_per_wr_mask;
//    biu_wr_data_nxt         = lsq_per_wr_data;
    
    // Drive AHB signnals
    //
    dbu_per_ahb_htrans              = AHB_SEQ;
	dbu_per_ahb_hwrite              = (~biu_cmd_read_r);
    dbu_per_ahb_haddr               = biu_cmd_addr_r;
    dbu_per_ahb_hsize               = biu_cmd_data_size_r;
    dbu_per_ahb_hburst              = biu_cmd_burst_r;
    dbu_per_ahb_hprot               = biu_cmd_prot_r;
	dbu_per_ahb_hexcl               = biu_cmd_excl_r;
	dbu_per_ahb_hauser[`AUSER_WID_RANGE] = biu_cmd_wid_r;
    
    if ((biu_cmd_burst_count_r == 1'd1) & dbu_per_ahb_hready)
    begin
      biu_cmd_state_nxt = BIU_CMD_DEFAULT;
    end
  end
  endcase
end

always @*
begin: biu_resp_fsm_PROC
  // Default values
  //
  lsq_per_rd_valid       = 1'b0;
  lsq_per_rd_last        = 1'b0;
  lsq_per_rd_err         = 1'b0;
  lsq_per_rd_excl_ok     = 1'b0;
  lsq_per_rd_data        = dbu_per_ahb_hrdata;

  lsq_per_wr_accept      = 1'b0;
  lsq_per_wr_done_w      = 1'b0;
  lsq_per_wr_done_set    = 1'b0;
  lsq_per_wr_done_clr    = lsq_per_wr_resp_accept & lsq_per_wr_done_r;
  lsq_per_wr_err_w       = 1'b0;
  lsq_per_wr_err_set     = 1'b0;
  lsq_per_wr_err_clr     = lsq_per_wr_resp_accept & lsq_per_wr_err_r; 
  lsq_per_wr_excl_okay_w   = 1'b0;
  lsq_per_wr_excl_okay_set = 1'b0;
  lsq_per_wr_excl_okay_clr = lsq_per_wr_resp_accept & lsq_per_wr_excl_okay_r;

  dbu_per_ahb_hwstrb     = 4'h0;
  dbu_per_ahb_hwdata     = biu_wr_data_r;
  biu_wr_data_nxt        = biu_wr_data_r;
  biu_wr_data_cg         = 1'b0;  
  
  biu_pending_rd_nxt = biu_pending_rd_r;
  biu_pending_wr_nxt = biu_pending_wr_r;
  
  biu_resp_cg0       = 1'b1;
  biu_resp_state_nxt = biu_resp_state_r;
  
  case (biu_resp_state_r)
  BIU_RESP_ADDR_PHASE:
  begin
    biu_resp_cg0      = (dbu_per_ahb_htrans != AHB_IDLE);
    
    if (  (dbu_per_ahb_htrans != AHB_IDLE)
        & dbu_per_ahb_hready)
    begin 
      biu_pending_rd_nxt = !dbu_per_ahb_hwrite;
      biu_pending_wr_nxt = dbu_per_ahb_hwrite;

	  biu_wr_data_nxt    = lsq_per_wr_data; 
      biu_wr_data_cg     = dbu_per_ahb_hwrite;

	  lsq_per_wr_accept  = dbu_per_ahb_hwrite;
      
      if (| dbu_per_ahb_hburst)
      begin
        biu_resp_state_nxt = BIU_RESP_MULTIPLE_DATA_PHASE;
      end  
      else
      begin
        biu_resp_state_nxt = BIU_RESP_DATA_PHASE;
      end  
    end
  end
  
  BIU_RESP_DATA_PHASE:
  begin
    if (biu_pending_wr_r)
    begin
      dbu_per_ahb_hwstrb    = biu_cmd_wstrb_r;
	end

    if (dbu_per_ahb_hresp == AHB_LITE_OKAY)
    begin
      // Provide IBP response
      //
      if (dbu_per_ahb_hready)
      begin
        lsq_per_rd_valid    = biu_pending_rd_r;
        lsq_per_rd_last     = biu_pending_rd_r;
		lsq_per_rd_excl_ok  = biu_pending_rd_r & dbu_per_ahb_hexokay;

        lsq_per_wr_excl_okay_w   = biu_pending_wr_r & dbu_per_ahb_hexokay;
        lsq_per_wr_excl_okay_set = biu_pending_wr_r & dbu_per_ahb_hexokay & !lsq_per_wr_resp_accept;
		lsq_per_wr_done_w   = biu_pending_wr_r;
        lsq_per_wr_done_set = biu_pending_wr_r & !lsq_per_wr_resp_accept;
        
        if (dbu_per_ahb_htrans != AHB_IDLE)
        begin
          // Back-to-back transfers - address phase
          //
          biu_pending_rd_nxt = !dbu_per_ahb_hwrite;
          biu_pending_wr_nxt = dbu_per_ahb_hwrite;

	      biu_wr_data_nxt    = lsq_per_wr_data; 
          biu_wr_data_cg     = dbu_per_ahb_hwrite;

	      lsq_per_wr_accept  = dbu_per_ahb_hwrite;

          biu_resp_state_nxt = (| dbu_per_ahb_hburst) ? BIU_RESP_MULTIPLE_DATA_PHASE : BIU_RESP_DATA_PHASE;
        end
        else
        begin
          biu_resp_state_nxt = BIU_RESP_ADDR_PHASE;
        end
      end
    end
    else
    begin
      // Error response
      //
      if (dbu_per_ahb_hresp == AHB_LITE_ERROR)
      begin
        biu_resp_state_nxt = BIU_RESP_ERROR;
      end
    end
  end
  
  BIU_RESP_MULTIPLE_DATA_PHASE: 
  begin
    if (biu_pending_wr_r)
    begin
      dbu_per_ahb_hwstrb    = biu_cmd_wstrb_r;
	end
	
      // Provide IBP response
      //
      if (dbu_per_ahb_hready)
      begin
        lsq_per_rd_valid    = biu_pending_rd_r;
		lsq_per_rd_err      = biu_pending_rd_r & (dbu_per_ahb_hresp == AHB_LITE_ERROR);

	    biu_wr_data_nxt    = lsq_per_wr_data; 
        biu_wr_data_cg     = biu_pending_wr_r;

	    lsq_per_wr_accept  = biu_pending_wr_r;
        
        if (biu_cmd_burst_count_r == 1'd1)
        begin
          biu_resp_state_nxt = BIU_RESP_DATA_PHASE;
        end
      end
  end
  
  default: // BIU_RESP_ERROR:
  begin
    if (biu_pending_rd_r)
	begin
      lsq_per_rd_err        = 1'b1;
	  lsq_per_rd_last       = 1'b1;
	  lsq_per_rd_valid      = 1'b1;
    end
	else
	begin
	  dbu_per_ahb_hwstrb    = biu_cmd_wstrb_r;
	  lsq_per_wr_done_w     = 1'b1;
      lsq_per_wr_done_set   = !lsq_per_wr_resp_accept;
	  lsq_per_wr_err_w      = 1'b1;
      lsq_per_wr_err_set    = !lsq_per_wr_resp_accept;
	end

    if (  (dbu_per_ahb_htrans != AHB_IDLE)
        & dbu_per_ahb_hready)
    begin 
      biu_pending_rd_nxt = !dbu_per_ahb_hwrite;
      biu_pending_wr_nxt = dbu_per_ahb_hwrite;

	  biu_wr_data_nxt    = lsq_per_wr_data; 
      biu_wr_data_cg     = dbu_per_ahb_hwrite;

	  lsq_per_wr_accept  = dbu_per_ahb_hwrite;
      
      if (| dbu_per_ahb_hburst)
      begin
        biu_resp_state_nxt = BIU_RESP_MULTIPLE_DATA_PHASE;
      end  
      else
      begin
        biu_resp_state_nxt = BIU_RESP_DATA_PHASE;
      end  
    end
	else
	begin
      biu_resp_state_nxt    = BIU_RESP_ADDR_PHASE;
	end

  end
  endcase
end

/////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
/////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : biu_cmd_regs_PROC
  if (rst_a == 1'b1)
  begin
    biu_cmd_state_r       <= BIU_CMD_DEFAULT;
    biu_cmd_burst_count_r <= 1'b0;
    biu_cmd_addr_r        <= {`ADDR_SIZE{1'b0}};    
    biu_cmd_read_r        <= 1'b0;
    biu_cmd_prot_r        <= 7'h0;
	biu_cmd_data_size_r   <= 3'b100;
	biu_cmd_burst_r       <= AHB_SINGLE;
	biu_cmd_wstrb_r       <= 4'h0;
	biu_cmd_excl_r        <= 1'b0;
	biu_cmd_wid_r         <= `WID_BITS'b0;
  end
  else
  begin
    if (biu_cmd_cg0 == 1'b1)
    begin
      biu_cmd_state_r       <= biu_cmd_state_nxt;
    end
    
    if (biu_cmd_burst_count_cg0 == 1'b1)
    begin
      biu_cmd_burst_count_r <= biu_cmd_burst_count_nxt;
      biu_cmd_addr_r        <= biu_cmd_addr_nxt; 
      biu_cmd_read_r        <= biu_cmd_read_nxt; 
      biu_cmd_prot_r        <= biu_cmd_prot_nxt; 
	  biu_cmd_data_size_r   <= biu_cmd_data_size_nxt;
      biu_cmd_burst_r       <= biu_cmd_burst_nxt;
	  biu_cmd_wstrb_r       <= biu_cmd_wstrb_nxt;
	  biu_cmd_excl_r        <= biu_cmd_excl_nxt;
	  biu_cmd_wid_r         <= biu_cmd_wid_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : biu_wr_data_regs_PROC
  if (rst_a == 1'b1)
  begin
    biu_wr_data_r         <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (biu_wr_data_cg == 1'b1)
	begin
      biu_wr_data_r         <= biu_wr_data_nxt;
	end
  end
end

always @(posedge clk or posedge rst_a)
begin : biu_resp_regs_PROC
  if (rst_a == 1'b1)
  begin
    biu_resp_state_r <= BIU_RESP_ADDR_PHASE;
    biu_pending_rd_r <= 1'b0;
	biu_pending_wr_r <= 1'b0;
  end
  else
  begin
    if (biu_resp_cg0 == 1'b1)
    begin
      biu_resp_state_r <= biu_resp_state_nxt; 
      biu_pending_rd_r <= biu_pending_rd_nxt; 
	  biu_pending_wr_r <= biu_pending_wr_nxt; 
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : wr_done_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_per_wr_done_r <= 1'b0;
  end
  else
  begin
    lsq_per_wr_done_r <= lsq_per_wr_done_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : wr_err_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_per_wr_err_r <= 1'b0;
  end
  else
  begin
    lsq_per_wr_err_r <= lsq_per_wr_err_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : wr_excl_okay_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_per_wr_excl_okay_r <= 1'b0;
  end
  else
  begin
    lsq_per_wr_excl_okay_r <= lsq_per_wr_excl_okay_nxt;
  end
end

assign lsq_per_wr_done_nxt = lsq_per_wr_done_set ? 1'b1 : (lsq_per_wr_done_clr ? 1'b0 : lsq_per_wr_done_r);
assign lsq_per_wr_err_nxt  = lsq_per_wr_err_set ? 1'b1 : (lsq_per_wr_err_clr ? 1'b0 : lsq_per_wr_err_r);
assign lsq_per_wr_excl_okay_nxt = lsq_per_wr_excl_okay_set ? 1'b1 : (lsq_per_wr_excl_okay_clr ? 1'b0 : lsq_per_wr_excl_okay_r);

assign lsq_per_wr_done = lsq_per_wr_done_r | lsq_per_wr_done_w;
assign lsq_per_wr_err  = lsq_per_wr_err_r | lsq_per_wr_err_w;
assign lsq_per_wr_excl_okay = lsq_per_wr_excl_okay_r | lsq_per_wr_excl_okay_w;

/////////////////////////////////////////////////////////////////////////////////////////
//
// Parity generation and check
//
/////////////////////////////////////////////////////////////////////////////////////////
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_haddr_parity0 (
  .din                   (dbu_per_ahb_haddr[7:0]),
  .q_parity              (dbu_per_ahb_haddrchk[0])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_haddr_parity1 (
  .din                   (dbu_per_ahb_haddr[15:8]),
  .q_parity              (dbu_per_ahb_haddrchk[1])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_haddr_parity2 (
  .din                   (dbu_per_ahb_haddr[23:16]),
  .q_parity              (dbu_per_ahb_haddrchk[2])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_haddr_parity3 (
  .din                   (dbu_per_ahb_haddr[31:24]),
  .q_parity              (dbu_per_ahb_haddrchk[3])
);

rl_parity_gen
#(
.DATA_WIDTH (`AUSER_BITS),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hauser_parity (
  .din                   (dbu_per_ahb_hauser),
  .q_parity              (dbu_per_ahb_hauserchk)
);

rl_parity_gen
#(
.DATA_WIDTH (2),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_htrans_parity (
  .din                   (dbu_per_ahb_htrans),
  .q_parity              (dbu_per_ahb_htranschk)
);

assign dbu_per_ahb_hctrl1 = {dbu_per_ahb_hburst, dbu_per_ahb_hlock, dbu_per_ahb_hwrite, dbu_per_ahb_hsize, dbu_per_ahb_hnonsec};

rl_parity_gen
#(
.DATA_WIDTH (9),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hctrl1_parity (
  .din                   (dbu_per_ahb_hctrl1),
  .q_parity              (dbu_per_ahb_hctrlchk1)
);

assign dbu_per_ahb_hctrl2 = {dbu_per_ahb_hexcl, dbu_per_ahb_hmaster};

rl_parity_gen
#(
.DATA_WIDTH (5),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hctrl2_parity (
  .din                   (dbu_per_ahb_hctrl2),
  .q_parity              (dbu_per_ahb_hctrlchk2)
);

rl_parity_gen
#(
.DATA_WIDTH (7),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hprot_parity (
  .din                   (dbu_per_ahb_hprot),
  .q_parity              (dbu_per_ahb_hprotchk)
);

rl_parity_gen
#(
.DATA_WIDTH (4),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hwstrb_parity (
  .din                   (dbu_per_ahb_hwstrb),
  .q_parity              (dbu_per_ahb_hwstrbchk)
);

rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hwdata_parity0 (
  .din                   (dbu_per_ahb_hwdata[7:0]),
  .q_parity              (dbu_per_ahb_hwdatachk[0])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hwdata_parity1 (
  .din                   (dbu_per_ahb_hwdata[15:8]),
  .q_parity              (dbu_per_ahb_hwdatachk[1])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hwdata_parity2 (
  .din                   (dbu_per_ahb_hwdata[23:16]),
  .q_parity              (dbu_per_ahb_hwdatachk[2])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hwdata_parity3 (
  .din                   (dbu_per_ahb_hwdata[31:24]),
  .q_parity              (dbu_per_ahb_hwdatachk[3])
);

rl_parity_chk
#(
.DATA_WIDTH (1),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hready_parity (
  .din                   (dbu_per_ahb_hready),
  .din_parity            (dbu_per_ahb_hreadychk),
  .enable                (1'b1),

  .parity_err            (dbu_per_ahb_hready_pty_err)
);

assign dbu_per_ahb_hresp_in = {dbu_per_ahb_hresp, dbu_per_ahb_hexokay};
wire datachk_en = (biu_resp_state_r != BIU_RESP_ADDR_PHASE);

rl_parity_chk
#(
.DATA_WIDTH (2),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hresp_parity (
  .din                   (dbu_per_ahb_hresp_in),
  .din_parity            (dbu_per_ahb_hrespchk),
  .enable                (datachk_en),

  .parity_err            (dbu_per_ahb_hresp_pty_err)
);

wire hrdatachk_en = biu_pending_rd_r & datachk_en & dbu_per_ahb_hready;

rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hrdata_parity0 (
  .din                   (dbu_per_ahb_hrdata[7:0]),
  .din_parity            (dbu_per_ahb_hrdatachk[0]),
  .enable                (hrdatachk_en),

  .parity_err            (dbu_per_ahb_hrdata_pty_err[0])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hrdata_parity1 (
  .din                   (dbu_per_ahb_hrdata[15:8]),
  .din_parity            (dbu_per_ahb_hrdatachk[1]),
  .enable                (hrdatachk_en),

  .parity_err            (dbu_per_ahb_hrdata_pty_err[1])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hrdata_parity2 (
  .din                   (dbu_per_ahb_hrdata[23:16]),
  .din_parity            (dbu_per_ahb_hrdatachk[2]),
  .enable                (hrdatachk_en),

  .parity_err            (dbu_per_ahb_hrdata_pty_err[2])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_dbu_per_ahb_hrdata_parity3 (
  .din                   (dbu_per_ahb_hrdata[31:24]),
  .din_parity            (dbu_per_ahb_hrdatachk[3]),
  .enable                (hrdatachk_en),

  .parity_err            (dbu_per_ahb_hrdata_pty_err[3])
);

assign dbu_per_ahb_fatal_err = dbu_per_ahb_hready_pty_err | dbu_per_ahb_hresp_pty_err | (|dbu_per_ahb_hrdata_pty_err);
// spyglass enable_block RegInputOutput-ML
endmodule // rl_per_ibp2ahb
// spyglass enable_block Topology_02

