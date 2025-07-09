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

module rl_mmio_ahb2ibp (
// spyglass disable_block RegInputOutput-ML 
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  ////////// IBP interface ////////////////////////////////////////////////
  //
  output                    ibp_cmd_prio,

  output reg                ibp_cmd_valid, 
  output [3:0]              ibp_cmd_cache, 
  output                    ibp_cmd_burst_size,                 
  output reg                ibp_cmd_read,                
  input                     ibp_cmd_accept,              
  output [`ADDR_RANGE]      ibp_cmd_addr,                             
  output                    ibp_cmd_excl,
  output [2:0]              ibp_cmd_data_size,                
  output [1:0]              ibp_cmd_prot,                

  output reg                ibp_wr_valid,    
  output reg                ibp_wr_last,    
  input                     ibp_wr_accept,   
  output reg [3:0]          ibp_wr_mask,    
  output [31:0]             ibp_wr_data,    
  
  input                     ibp_rd_valid,                
  input                     ibp_rd_err,                
  input                     ibp_rd_excl_ok,
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                     ibp_rd_last,  
// spyglass enable_block W240
  output reg                ibp_rd_accept,               
  input [31:0]              ibp_rd_data,     
  
  input                     ibp_wr_done,
  input                     ibp_wr_excl_okay,
  input                     ibp_wr_err,
  output reg                ibp_wr_resp_accept,

  ////////// AHB initiator ////////////////////////////////////////////////
  //
  input                     ahb_prio,

  input                     ahb_hlock,
  input                     ahb_hexcl,
// spyglass disable_block W240
// SMD: Input declared but not read.
// SJ : Reserved for future use
  input [3:0]               ahb_hmaster,
// spyglass enable_block W240
  input                     ahb_hsel,
  input                     ahb_hwrite,
  input [`ADDR_RANGE]       ahb_haddr,
  input [1:0]               ahb_htrans,
  input [2:0]               ahb_hsize,
  input [3:0]               ahb_hwstrb,
  input [2:0]               ahb_hburst,
  input [6:0]               ahb_hprot,
// spyglass disable_block W240
// SMD: Input declared but not read.
// SJ : Reserved for future use
  input                     ahb_hnonsec,
// spyglass enable_block W240
  input                     ahb_hready,
  output reg                ahb_hready_resp,
  output                    ahb_hresp,
  output reg                ahb_hexokay,
  output [`DATA_RANGE]      ahb_hrdata,
  input  [`DATA_RANGE]      ahb_hwdata,

 ///////// AHB bus protection signals /////////////////////////////////////
 //
  input [`ADDR_PTY_RANGE]   ahb_haddrchk,
  input                     ahb_htranschk,
  input                     ahb_hctrlchk1,      // Parity of ahb_hburst, ahb_hlock, ahb_hwrite, ahb_hsize
  input                     ahb_hctrlchk2,      // Parity of ahb_hexcl, ahb_hmaster
  input                     ahb_hreadychk,
  input                     ahb_hwstrbchk,
  input                     ahb_hprotchk,
  output                    ahb_hrespchk,       // Parity of ahb_hresp, ahb_hexokay
  output                    ahb_hready_respchk,
  input                     ahb_hselchk,
  output [`DATA_PTY_RANGE]  ahb_hrdatachk,
  input  [`DATA_PTY_RANGE]  ahb_hwdatachk,

  output                    ahb_fatal_err,

  ///////// BIU idle signals ///////////////////////////////////////////////////
  //
  output                    biu_mmio_dmi_idle,

  ////////// General input signals /////////////////////////////////////////////
  //
  output                    dmi_clock_enable_nxt,
  input                     dmi_clock_enable,

  input                     clk,                   // clock signal
  input                     rst_a                  // reset signal

);


///////////////////////////////////////////////////////////////////////////////
// This is an adapter that converts AHB to IBP. The AHB I/O may be 
// registerd or not-registered, depending on a configuration option
//
//////////////////////////////////////////////////////////////////////////////////
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
localparam STATE_DEFAULT  = 4'b0000; // IDLE state
localparam STATE_WDEFAULT = 4'b0001; // Wait for bus clock before IDLE state
localparam STATE_RCOMMAND = 4'b0010; // Read commmand, wait for clock and command accept
localparam STATE_DATA     = 4'b0011; // Wait for clock and read data, merge write data
localparam STATE_WCOMMAND = 4'b0100; // Write commmand, wait for command accept
localparam STATE_WCMDWAIT = 4'b0101; // Write command, wait for write command accept
localparam STATE_WWAIT    = 4'b0110; // Write data, wait for write data accept
localparam STATE_WDONE    = 4'b0111; // Write commmand, wait for write data done
localparam STATE_WERR     = 4'b1000; // Wait for bus clock before ERR state
localparam STATE_ERR1     = 4'b1001; // First cycle of error response
localparam STATE_ERR2     = 4'b1010; // Second cycle of error response

reg         ibp_cmd_en;                // enable ibp cmd phase registers

reg [3:0]   prio_cnt_r;                // priority counter
reg [3:0]   prio_cnt_nxt;
reg [3:0]   prio_cnt_next;
reg         prio_cnt_en;
wire        prio_set;

reg [3:0]   biu_cmd_state_r;
reg [3:0]   biu_cmd_state_nxt;

reg [2:0]   ibp_size_r;                // AHB size registered
reg         ibp_write_r;               // AHB write registered
reg         ibp_sel_r;                 // AHB sel registered 
reg [`ADDR_RANGE] ibp_addr_r;          // AHB addr registered 
reg         ibp_data_en;               // Data register enable
reg [`DATA_RANGE] ibp_data_r;          // Data registered
reg         ibp_excl_r;                // AHB hexcl registered
reg [3:0]   ibp_wstrb_r;               // AHB hwstrb registered
reg [2:0]   ibp_burst_r;               // AHB hburst registered
reg [1:0]   ibp_prot_r;                // AHB hprot registered
reg [3:0]   ibp_cache_r;               // AHB hprot registered

reg [2:0]   ibp_size_nxt;                // AHB size registered
reg         ibp_write_nxt;               // AHB write registered
reg         ibp_sel_nxt;                 // AHB sel registered 
reg [`ADDR_RANGE] ibp_addr_nxt;          // AHB addr registered 
reg [`DATA_RANGE] ibp_data_nxt;          // Data registered
reg         ibp_excl_nxt;                // AHB hexcl registered
reg [3:0]   ibp_wstrb_nxt;               // AHB hwstrb registered
reg [2:0]   ibp_burst_nxt;               // AHB hburst registered
reg [1:0]   ibp_prot_nxt;                // AHB hprot registered
reg [3:0]   ibp_cache_nxt;               // AHB hprot registered

wire        biu_trans_err;
reg         biu_hexokay_r;
reg         biu_hexokay_nxt;

reg [3:0]   data_lane_mask;

wire ahb_clk_en = 1'b1;                  //Reserved for AHB clock ratio

assign biu_mmio_dmi_idle = (biu_cmd_state_r == STATE_DEFAULT) & (!ahb_hsel | (ahb_htrans == AHB_IDLE));

/////////////////////////////////////////////////////////////////////////////
//
// Parity signals declarations
//
/////////////////////////////////////////////////////////////////////////////
wire [8:0] ahb_hctrl1_in;
wire [4:0] ahb_hctrl2_in;
wire [1:0] ahb_hresp_in;

wire [`ADDR_PTY_RANGE] ahb_haddr_pty_err;
wire                   ahb_htrans_pty_err;
wire                   ahb_hctrl1_pty_err;
wire                   ahb_hctrl2_pty_err;
wire                   ahb_hready_pty_err;
wire                   ahb_hwstrb_pty_err;
wire                   ahb_hprot_pty_err;
wire                   ahb_hsel_pty_err;
wire [`DATA_PTY_RANGE] ahb_hwdata_pty_err;

reg       datachk_en_nxt;
reg       datachk_en_r;

///////////////////////////////////////////////////////////////////
//BIU transfer error logic
//1. Exclusive Transfer must be a single beat transfer
//2. Exclusive Transfer must be indicated as burst type SINGLE or burst type INCR
//3. Exclusive Transfer must not include a BUSY transfer
//4. If bus protection presents, burst write transfer size must be same as data bus size
///////////////////////////////////////////////////////////////////

assign biu_trans_err =  ahb_hexcl
                      | ahb_hlock
                      | (ahb_hburst != 3'b0)
					  | (ahb_hsize != 3'b010)
					  ;

///////////////////////////////////////////////////////////////////
//IBP/AHB Output
///////////////////////////////////////////////////////////////////
assign ahb_hresp         = (biu_cmd_state_r == STATE_ERR1) | (biu_cmd_state_r == STATE_ERR2);
assign ahb_hrdata        = ahb_hresp ? `DATA_SIZE'h0 : ibp_data_r;
assign ibp_cmd_addr      = ibp_addr_r;
assign ibp_wr_data       = ibp_data_r;
assign ibp_cmd_data_size = ibp_size_r;
assign dmi_clock_enable_nxt  = (biu_cmd_state_nxt != STATE_DEFAULT) | ibp_rd_valid;

assign ibp_cmd_cache     = ibp_cache_r;
assign ibp_cmd_burst_size = 1'b0;
assign ibp_cmd_excl      = ibp_excl_r;
assign ibp_cmd_prot      = ibp_prot_r;

///////////////////////////////////////////////////////////////////
//Partial logic, considering ECC code should be write, implement
//read-modify-write when partial write
///////////////////////////////////////////////////////////////////
always @*
begin : data_lane_mask_PROC

  data_lane_mask = 4'b0000; 

  case (ibp_size_r)
  3'b000:
  begin
    case (ibp_addr_r[1:0])
	2'b00:
    begin
    data_lane_mask = 4'b0001;   
    end
	2'b01:
    begin
    data_lane_mask = 4'b0010; 
    end
    2'b10:
    begin
    data_lane_mask = 4'b0100;  
    end
    default:
    begin
    data_lane_mask = 4'b1000;    
    end
    endcase
  end
  3'b001:
  begin
   case (ibp_addr_r[1])
   1'b0:
    begin
    data_lane_mask = 4'b0011;    
    end
    default:
    begin
    data_lane_mask = 4'b1100;            
    end
    endcase
  end
  default:
  begin
    data_lane_mask = 4'b1111;
  end
  endcase
 
end
///////////////////////////////////////////////////////////////////
//FSM
///////////////////////////////////////////////////////////////////
always @*
  begin: biu_cmd_state_fsm_PROC
    biu_cmd_state_nxt       = biu_cmd_state_r;
	ibp_cmd_valid           = 1'b0;
	ibp_cmd_read            = 1'b0;
	ibp_cmd_en              = 1'b0;
	ibp_data_en             = 1'b0;
	ibp_wr_valid            = 1'b0;
	ibp_wr_mask             = 4'b0;
	ibp_wr_last             = 1'b0;
	ibp_rd_accept           = 1'b0;
	ibp_wr_resp_accept      = 1'b0;
	ahb_hready_resp         = 1'b0;
	ahb_hexokay             = 1'b0;
	biu_hexokay_nxt         = biu_hexokay_r;
	datachk_en_nxt          = datachk_en_r;
    case(biu_cmd_state_r)
	  STATE_WERR: 
	  begin
        // wait for bus clock enable before issueing error response
		if (ahb_clk_en)
		  biu_cmd_state_nxt = STATE_ERR1;
	  end // STATE_WERR
	  STATE_ERR1: 
	  begin
        // first bus cycle of error response
		if (ahb_clk_en)
		  biu_cmd_state_nxt = STATE_ERR2;
	  end // STATE_ERR1
	  STATE_ERR2: 
	  begin
		// last bus cycle of error response
        ahb_hready_resp = 1'b1;
		datachk_en_nxt = 1'b0;
		// back-to-back transfer
		if (ahb_clk_en)
		begin
          if (ahb_hsel && (ahb_htrans != AHB_IDLE) && (ahb_htrans != AHB_BUSY) && ahb_hready)
		  begin
            if (biu_trans_err)
			begin
              if (ahb_clk_en)
			    biu_cmd_state_nxt = STATE_ERR1;
		      else
			    biu_cmd_state_nxt = STATE_WERR;			  
			end
			else
			begin
            ibp_cmd_en = 1'b1;
			datachk_en_nxt  = 1'b1;
			if (ahb_hwrite)
			  biu_cmd_state_nxt = STATE_DATA;
		    else
			  biu_cmd_state_nxt = STATE_RCOMMAND;
            end
		  end
		  else
		  begin
            biu_cmd_state_nxt = STATE_DEFAULT;
		  end
		end
	  end // STATE_ERR2
	  STATE_DATA:
	  begin
        // Wait for read/write data
        if (ibp_write_r && ahb_clk_en)
		begin
		ibp_data_en = 1'b1;
        biu_cmd_state_nxt = STATE_WCOMMAND;
		end
		else if (!ibp_write_r && ibp_rd_valid)
		begin
          ibp_data_en = 1'b1;
		  ibp_rd_accept = 1'b1;
		  if (ibp_rd_err)
		  begin
            if (ahb_clk_en)
			  biu_cmd_state_nxt = STATE_ERR1;
		    else
			  biu_cmd_state_nxt = STATE_WERR;
		  end
		  else
		  begin
            if (ahb_clk_en)
			begin
			  biu_hexokay_nxt   = ibp_rd_excl_ok;
			  biu_cmd_state_nxt = STATE_DEFAULT;
			end
		    else
			begin
			  biu_cmd_state_nxt = STATE_WDEFAULT;
			end
		  end
		end
	  end // STATE_DATA
      STATE_WCOMMAND:
	  begin
        if (dmi_clock_enable)
		begin
          ibp_cmd_valid = 1'b1;
          ibp_wr_valid  = 1'b1;
		  ibp_wr_mask   = ibp_wstrb_r & data_lane_mask; 
          ibp_wr_last   = 1'b1;
		    if (ibp_cmd_accept && ibp_wr_accept)
		    begin
		      ibp_wr_resp_accept = 1'b1;
		      biu_cmd_state_nxt = STATE_WDONE;
		    end
		    else if (ibp_cmd_accept && !ibp_wr_accept)
		    begin
		      biu_cmd_state_nxt = STATE_WWAIT;
		    end
		    else if (!ibp_cmd_accept && ibp_wr_accept)
		    begin
			  ibp_wr_resp_accept = 1'b1;
		      biu_cmd_state_nxt = STATE_WCMDWAIT;
		    end
		end
	  end // STATE_WCOMMAND
	  STATE_WCMDWAIT:
	  begin
        if (dmi_clock_enable)
		begin
          ibp_cmd_valid = 1'b1;
		  if (ibp_cmd_accept)
		  begin
            biu_cmd_state_nxt = STATE_WDONE;
		  end
		end
	  end // STATE_WCMDWAIT
	  STATE_WWAIT:
	  begin
        if (dmi_clock_enable)
		begin
          ibp_wr_valid = 1'b1;
		  ibp_wr_mask  = ibp_wstrb_r & data_lane_mask;
		  ibp_wr_last  = 1'b1;
		  if (ibp_wr_accept)
		  begin
		    ibp_wr_resp_accept = 1'b1;
            biu_cmd_state_nxt = STATE_WDONE;
		  end
		end
	  end // STATE_WWAIT
	  STATE_WDONE:
	  begin
        if (dmi_clock_enable)
		begin
		  ibp_wr_resp_accept = 1'b1;
          if (ibp_wr_done)
		  begin
			if (ibp_wr_err)
			begin
              if (ahb_clk_en)
			    biu_cmd_state_nxt = STATE_ERR1;
		      else
			    biu_cmd_state_nxt = STATE_WERR;
		    end
			else
			begin
            if (ahb_clk_en)
			begin
			  biu_hexokay_nxt   = ibp_wr_excl_okay;
			  biu_cmd_state_nxt = STATE_DEFAULT;
			end
		    else
			begin
			  biu_cmd_state_nxt = STATE_WDEFAULT;
			end
		    end
		  end
        end 
	  end // STATE_WDONE
	  STATE_RCOMMAND:
	  begin
        ibp_cmd_read = 1'b1;
        if (dmi_clock_enable)
		begin
          ibp_cmd_valid = 1'b1;
		  if (ibp_cmd_accept)
            biu_cmd_state_nxt = STATE_DATA;
		end
	  end // STATE_RCOMMAND
	  STATE_WDEFAULT:
	  begin
        if (ahb_clk_en)
		  biu_cmd_state_nxt = STATE_DEFAULT;
	  end // STATE_WDEFAULT
	  default: // STATE_DEFAULT
	  begin
	    // AHB is IDLE, no pending transaction or acknowledge write
		ahb_hready_resp = 1'b1;
		datachk_en_nxt = 1'b1;
		ahb_hexokay     = biu_hexokay_r;
		biu_hexokay_nxt = 1'b0;
		if (ahb_clk_en)
		begin
          if (ahb_hsel && (ahb_htrans != AHB_IDLE) && (ahb_htrans != AHB_BUSY) && ahb_hready)
		  begin
            if (biu_trans_err)
			begin
              if (ahb_clk_en)
			    biu_cmd_state_nxt = STATE_ERR1;
		      else
			    biu_cmd_state_nxt = STATE_WERR;			  
			end
			else
			begin
			datachk_en_nxt  = 1'b1;
            ibp_cmd_en = 1'b1;
			if (ahb_hwrite)
			  biu_cmd_state_nxt = STATE_DATA;
		    else
			  biu_cmd_state_nxt = STATE_RCOMMAND;
            end
		  end
		  else
		  begin
            biu_cmd_state_nxt = STATE_DEFAULT;
		  end
		end
	  end // STATE_DEFAULT
    endcase
  end

// priority counter next state
assign prio_set     = &prio_cnt_r;
assign ibp_cmd_prio = prio_set;

always @*
  begin : prio_cnt_nxt_PROC
    prio_cnt_en  = 1'b0;
	prio_cnt_nxt = 4'h0;
	if (biu_cmd_state_r == STATE_DEFAULT)
	begin
      if (biu_cmd_state_nxt != STATE_DEFAULT)
	  begin
        prio_cnt_en = 1'b1;
		if (ahb_prio)
		  prio_cnt_nxt = 4'hf;
	  end
	end
	else if (!prio_set)
	begin
      prio_cnt_en = 1'b1;
	  if (ahb_prio && ahb_clk_en)
        prio_cnt_nxt = 4'hf;
	  else
		prio_cnt_nxt = prio_cnt_r + 4'b1;
	end
  end

// internal command signals next state

always @*
  begin : i_cmd_nxt_PROC
    ibp_size_nxt       = ibp_size_r;
	ibp_write_nxt      = ibp_write_r;
	ibp_addr_nxt       = ibp_addr_r;
	ibp_sel_nxt        = ibp_sel_r;
	prio_cnt_next      = prio_cnt_r;
	ibp_data_nxt       = ibp_data_r;
	ibp_excl_nxt       = ibp_excl_r;
	ibp_wstrb_nxt      = ibp_wstrb_r;
	ibp_burst_nxt      = ibp_burst_r;
	ibp_prot_nxt       = ibp_prot_r;
	ibp_cache_nxt      = ibp_cache_r;
	if (ibp_cmd_en)
	begin
	  ibp_size_nxt       = ahb_hsize;
	  ibp_write_nxt      = ahb_hwrite;
	  ibp_addr_nxt       = ahb_haddr;
	  ibp_sel_nxt        = ahb_hsel;
	  ibp_excl_nxt       = ahb_hexcl;
      ibp_burst_nxt      = ahb_hburst;
      ibp_prot_nxt       = {~ahb_hprot[0], ahb_hprot[1]};
	  ibp_cache_nxt      = {ahb_hwrite & ahb_hprot[5], ~ahb_hwrite & ahb_hprot[5], |ahb_hprot[6:3], ahb_hprot[2]};
	end
	if (prio_cnt_en)
	begin
      prio_cnt_next      = prio_cnt_nxt;
	end
	if (ibp_data_en)
	begin
      if (ibp_write_r)
	  begin
	    ibp_wstrb_nxt    = ahb_hwstrb;
	    ibp_data_nxt     = ahb_hwdata;
	  end
	  else
	  begin
        ibp_data_nxt      = ibp_rd_data;
	  end
	end	  	
  end

//////////////////////////////////////////////////////////////////////
//Sync regsiters
//////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
  begin : i_cmd_r_PROC
    if (rst_a)
	begin
      ibp_size_r         <= 3'b0;
	  ibp_write_r        <= 1'b0;
	  ibp_addr_r         <= `ADDR_SIZE'h0;
	  ibp_sel_r          <= 1'b0;
	  ibp_data_r         <= `DATA_SIZE'h0;
	  ibp_excl_r         <= 1'b0;
	  ibp_wstrb_r        <= 4'h0;
	  ibp_burst_r        <= 4'h0;
	  ibp_prot_r         <= 2'b0;
	  ibp_cache_r        <= 4'h0;
	  prio_cnt_r         <= 4'h0;
	  biu_hexokay_r      <= 1'b0;
      datachk_en_r     <= 1'b0;
	end
	else
	begin
      ibp_size_r         <= ibp_size_nxt;
	  ibp_write_r        <= ibp_write_nxt;
	  ibp_addr_r         <= ibp_addr_nxt;
	  ibp_sel_r          <= ibp_sel_nxt;
	  ibp_data_r         <= ibp_data_nxt;
	  ibp_excl_r         <= ibp_excl_nxt;
	  ibp_wstrb_r        <= ibp_wstrb_nxt;
	  ibp_burst_r        <= ibp_burst_nxt;
	  ibp_prot_r         <= ibp_prot_nxt;
	  ibp_cache_r        <= ibp_cache_nxt;
	  prio_cnt_r         <= prio_cnt_next;
      biu_hexokay_r      <= biu_hexokay_nxt;
      datachk_en_r       <= datachk_en_nxt;
	end
  end

always @(posedge clk or posedge rst_a)
  begin : biu_cmd_state_r_PROC
    if (rst_a)
	begin
      biu_cmd_state_r     <= STATE_DEFAULT;
	end
	else
	begin
      biu_cmd_state_r     <= biu_cmd_state_nxt;
	end
  end

/////////////////////////////////////////////////////////////////////////////////////////
//
// Parity generation and check
//
/////////////////////////////////////////////////////////////////////////////////////////
assign ahb_hresp_in = {ahb_hresp, ahb_hexokay};

rl_parity_gen
#(
.DATA_WIDTH (2),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hresp_parity (
  .din                   (ahb_hresp_in),
  .q_parity              (ahb_hrespchk)
);

rl_parity_gen
#(
.DATA_WIDTH (1),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hready_resp_parity (
  .din                   (ahb_hready_resp),
  .q_parity              (ahb_hready_respchk)
);

rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity0 (
  .din                   (ahb_hrdata[7:0]),
  .q_parity              (ahb_hrdatachk[0])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity1 (
  .din                   (ahb_hrdata[15:8]),
  .q_parity              (ahb_hrdatachk[1])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity2 (
  .din                   (ahb_hrdata[23:16]),
  .q_parity              (ahb_hrdatachk[2])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity3 (
  .din                   (ahb_hrdata[31:24]),
  .q_parity              (ahb_hrdatachk[3])
);

rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_haddr_parity0 (
  .din                   (ahb_haddr[7:0]),
  .din_parity            (ahb_haddrchk[0]),
  .enable                (1'b1),

  .parity_err            (ahb_haddr_pty_err[0])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_haddr_parity1 (
  .din                   (ahb_haddr[15:8]),
  .din_parity            (ahb_haddrchk[1]),
  .enable                (1'b1),

  .parity_err            (ahb_haddr_pty_err[1])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_haddr_parity2 (
  .din                   (ahb_haddr[23:16]),
  .din_parity            (ahb_haddrchk[2]),
  .enable                (1'b1),

  .parity_err            (ahb_haddr_pty_err[2])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_haddr_parity3 (
  .din                   (ahb_haddr[31:24]),
  .din_parity            (ahb_haddrchk[3]),
  .enable                (1'b1),

  .parity_err            (ahb_haddr_pty_err[3])
);


rl_parity_chk
#(
.DATA_WIDTH (2),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_htrans_parity (
  .din                   (ahb_htrans),
  .din_parity            (ahb_htranschk),
  .enable                (1'b1),

  .parity_err            (ahb_htrans_pty_err)
);

assign ahb_hctrl1_in = {ahb_hburst, ahb_hlock, ahb_hwrite, ahb_hsize, ahb_hnonsec};
wire hctrlchk_en = (ahb_htrans != AHB_IDLE);

rl_parity_chk
#(
.DATA_WIDTH (9),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hctrl1_parity (
  .din                   (ahb_hctrl1_in),
  .din_parity            (ahb_hctrlchk1),
  .enable                (hctrlchk_en),

  .parity_err            (ahb_hctrl1_pty_err)
);

assign ahb_hctrl2_in = {ahb_hexcl, ahb_hmaster};

rl_parity_chk
#(
.DATA_WIDTH (5),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hctrl2_parity (
  .din                   (ahb_hctrl2_in),
  .din_parity            (ahb_hctrlchk2),
  .enable                (hctrlchk_en),

  .parity_err            (ahb_hctrl2_pty_err)
);

rl_parity_chk
#(
.DATA_WIDTH (1),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hready_parity (
  .din                   (ahb_hready),
  .din_parity            (ahb_hreadychk),
  .enable                (1'b1),

  .parity_err            (ahb_hready_pty_err)
);

wire hwdatachk_en = datachk_en_r & ibp_write_r;

rl_parity_chk
#(
.DATA_WIDTH (4),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwstrb_parity (
  .din                   (ahb_hwstrb),
  .din_parity            (ahb_hwstrbchk),
  .enable                (hwdatachk_en),

  .parity_err            (ahb_hwstrb_pty_err)
);

rl_parity_chk
#(
.DATA_WIDTH (7),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hprot_parity (
  .din                   (ahb_hprot),
  .din_parity            (ahb_hprotchk),
  .enable                (hctrlchk_en),

  .parity_err            (ahb_hprot_pty_err)
);

rl_parity_chk
#(
.DATA_WIDTH (1),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hsel_parity (
  .din                   (ahb_hsel),
  .din_parity            (ahb_hselchk),
  .enable                (1'b1),

  .parity_err            (ahb_hsel_pty_err)
);

rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity0 (
  .din                   (ahb_hwdata[7:0]),
  .din_parity            (ahb_hwdatachk[0]),
  .enable                (hwdatachk_en),

  .parity_err            (ahb_hwdata_pty_err[0])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity1 (
  .din                   (ahb_hwdata[15:8]),
  .din_parity            (ahb_hwdatachk[1]),
  .enable                (hwdatachk_en),

  .parity_err            (ahb_hwdata_pty_err[1])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity2 (
  .din                   (ahb_hwdata[23:16]),
  .din_parity            (ahb_hwdatachk[2]),
  .enable                (hwdatachk_en),

  .parity_err            (ahb_hwdata_pty_err[2])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity3 (
  .din                   (ahb_hwdata[31:24]),
  .din_parity            (ahb_hwdatachk[3]),
  .enable                (hwdatachk_en),

  .parity_err            (ahb_hwdata_pty_err[3])
);

assign ahb_fatal_err =   (|ahb_haddr_pty_err)
                       | ahb_htrans_pty_err
					   | ahb_hctrl1_pty_err
					   | ahb_hctrl2_pty_err
					   | ahb_hready_pty_err
					   | ahb_hwstrb_pty_err
					   | ahb_hprot_pty_err
					   | ahb_hsel_pty_err
					   | (|ahb_hwdata_pty_err)
					   ;

// spyglass enable_block RegInputOutput-ML
endmodule // rl_mmio_ahb2ibp
// spyglass enable_block Topology_02

