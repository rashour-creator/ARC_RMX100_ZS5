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

module rl_ibp2ahb (
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ:  None-registered interface, potential combination loop should be taken care when integration
  input  [`WID_RANGE]       cmd_wid,
  ////////// IFU  interface /////////////////////////////////////////////////
  //
  input                     ifu_mem_cmd_valid, 
  input [3:0]               ifu_mem_cmd_cache, 
  input [`IC_WRD_RANGE]     ifu_mem_cmd_burst_size,  
  input                     ifu_mem_cmd_read,                
  input                     ifu_mem_cmd_aux,                
  output reg                ifu_mem_cmd_accept,              
  input [`ADDR_RANGE]       ifu_mem_cmd_addr,                             
  input                     ifu_mem_cmd_wrap,
  input                     ifu_mem_cmd_excl,
  input [5:0]               ifu_mem_cmd_atomic,
  input [2:0]               ifu_mem_cmd_data_size,                
  input [1:0]               ifu_mem_cmd_prot,                
  input                     ifu_fch_vec,

  output                    ifu_mem_rd_valid,                
  output                    ifu_mem_rd_err,                
  output reg                ifu_mem_rd_excl_ok,
  output                    ifu_mem_rd_last,                 
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                     ifu_mem_rd_accept,  
// spyglass enable_block W240
  output     [31:0]         ifu_mem_rd_data,     
  ////////// LSQ IBP mem interface ////////////////////////////////////////////////
  //
  input                     lsq_mem_cmd_valid, 
  input [3:0]               lsq_mem_cmd_cache, 
  input                     lsq_mem_cmd_burst_size,                 
  input                     lsq_mem_cmd_read,                
  input                     lsq_mem_cmd_aux,                
  output reg                lsq_mem_cmd_accept,              
  input [`ADDR_RANGE]       lsq_mem_cmd_addr,                             
  input                     lsq_mem_cmd_excl,
  input [5:0]               lsq_mem_cmd_atomic,
  input [2:0]               lsq_mem_cmd_data_size,                
  input [1:0]               lsq_mem_cmd_prot,                

  input                     lsq_mem_wr_valid,    
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                     lsq_mem_wr_last,  
// spyglass enable_block W240
  output reg                lsq_mem_wr_accept,   
  input [3:0]               lsq_mem_wr_mask,    
  input [31:0]              lsq_mem_wr_data,    
  
  output reg                lsq_mem_rd_valid,                
  output reg                lsq_mem_rd_err,                
  output reg                lsq_mem_rd_excl_ok,
  output reg                lsq_mem_rd_last,                 
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                     lsq_mem_rd_accept,
// spyglass enable_block W240
  output reg  [31:0]        lsq_mem_rd_data,     
  
  output                    lsq_mem_wr_done,
  output                    lsq_mem_wr_excl_okay,
  output                    lsq_mem_wr_err,
  input                     lsq_mem_wr_resp_accept,


  ////////// AHB5 initiator ////////////////////////////////////////////////
  //
  output reg                ahb_hlock,
  output reg                ahb_hexcl,
  output reg [3:0]          ahb_hmaster,
  output reg [`AUSER_RANGE] ahb_hauser,

  output reg                ahb_hwrite,
  output reg [`ADDR_RANGE]  ahb_haddr,
  output reg [1:0]          ahb_htrans,
  output reg [2:0]          ahb_hsize,
  output reg [2:0]          ahb_hburst,
  output reg [3:0]          ahb_hwstrb,
  output reg [6:0]          ahb_hprot,
  output reg                ahb_hnonsec,
  input                     ahb_hready,
  input                     ahb_hresp,
  input                     ahb_hexokay,
  input  [`DATA_RANGE]      ahb_hrdata,
  output reg [`DATA_RANGE]  ahb_hwdata,

 ///////// AHB5 bus protection signals /////////////////////////////////////
 //
  output [`AUSER_PTY_RANGE] ahb_hauserchk,
  output [`ADDR_PTY_RANGE]  ahb_haddrchk,
  output                    ahb_htranschk,
  output                    ahb_hctrlchk1,      // Parity of ahb_hburst, ahb_hlock, ahb_hwrite, ahb_hsize, ahb_hnonsec
  output                    ahb_hctrlchk2,      // Parity of ahb_hexcl, ahb_hmaster
  output                    ahb_hprotchk,
  output                    ahb_hwstrbchk,
  input                     ahb_hreadychk,
  input                     ahb_hrespchk,       // Parity of ahb_hresp, ahb_hexokay
  input  [`DATA_PTY_RANGE]  ahb_hrdatachk,
  output [`DATA_PTY_RANGE]  ahb_hwdatachk,

  output                    ahb_fatal_err,

  ///////// BIU idle signals ///////////////////////////////////////////////////
  //
  output                    biu_cbu_idle,
  
  ////////// General input signals /////////////////////////////////////////////
  //
  input                     clk,                   // clock signal
  input                     rst_a                  // reset signal

);


// HTRANS[1:0]

localparam AHB_IDLE         =  2'b00;
localparam AHB_BUSY         =  2'b01;
localparam AHB_NONSEQ       =  2'b10;
localparam AHB_SEQ          =  2'b11;

// HSIZE[2:0]

localparam AHB_BYTE         =  3'b000;
localparam AHB_HALF_WORD    =  3'b001;
localparam AHB_WORD         =  3'b010;

// HBURST[2:0]

localparam AHB_SINGLE       =  3'b000;
localparam AHB_INCR         =  3'b001;
localparam AHB_WRAP4        =  3'b010;
localparam AHB_INCR4        =  3'b011;
localparam AHB_WRAP8        =  3'b100;
localparam AHB_INCR8        =  3'b101;
localparam AHB_WRAP16       =  3'b110;
localparam AHB_INCR16       =  3'b111;

// HPROT[3:0]

localparam AHB_INSTR_FETCH  = 1'b0;
localparam AHB_DATA_FETCH   = 1'b1;


// HRESP[1:0]

localparam AHB_OKAY         = 2'b00;
localparam AHB_ERROR        = 2'b01;
localparam AHB_RETRY        = 2'b10;
localparam AHB_SPLIT        = 2'b11;

localparam AHB_LITE_OKAY    = 1'b0;
localparam AHB_LITE_ERROR   = 1'b1;




///////////////////////////////////////////////////////////////////////////////
// This is an adapter that converts IBP to AHB5. The AHB5 I/O may be 
// registerd or not-registered, depending on a configuration option
//
//////////////////////////////////////////////////////////////////////////////////

reg                    ibp_cmd_valid; 
reg [3:0]              ibp_cmd_cache; 
reg [`IC_WRD_RANGE]    ibp_cmd_burst_size;  
reg                    ibp_cmd_read;                
reg                    ibp_cmd_aux;                
reg                    ibp_cmd_accept;              
reg [`ADDR_RANGE]      ibp_cmd_addr;   
wire [`ADDR_RANGE]      ibp_cmd_addr_aligned; 
reg                    ibp_cmd_excl;
reg [5:0]              ibp_cmd_atomic;
reg [2:0]              ibp_cmd_data_size;                
reg [1:0]              ibp_cmd_prot;                
reg                    ibp_cmd_wrap;
reg [`WID_RANGE]       ibp_cmd_wid;
reg                    ibp_cmd_fch_vec;

reg                    ibp_wr_valid;    
reg                    ibp_wr_last;    
reg                    ibp_wr_accept;   
reg [3:0]              ibp_wr_mask;    
reg [31:0]             ibp_wr_data;    

reg                    ibp_rd_valid;                
reg                    ibp_rd_err;                
reg                    ibp_rd_excl_ok;
reg                    ibp_rd_last;                 
reg                    ibp_rd_accept;               
reg  [31:0]            ibp_rd_data;     

reg                    ibp_wr_resp_accept;

reg  [2:0]             ahb_hburst_w;

reg                    ibp_wr_done;
reg                    ibp_wr_done_r;
reg                    ibp_wr_done_set;
reg                    ibp_wr_done_clr;
wire                   ibp_wr_done_nxt;

reg                    ibp_wr_err;
reg                    ibp_wr_err_r;
reg                    ibp_wr_err_set;
reg                    ibp_wr_err_clr;
wire                   ibp_wr_err_nxt;

reg                    ibp_wr_excl_okay;
reg                    ibp_wr_excl_okay_r;
reg                    ibp_wr_excl_okay_set;
reg                    ibp_wr_excl_okay_clr;
wire                   ibp_wr_excl_okay_nxt;


/////////////////////////////////////////////////////////////////////////////
//
// Parity signals declarations
//
/////////////////////////////////////////////////////////////////////////////
wire [8:0] ahb_hctrl1;
wire [4:0] ahb_hctrl2;
wire [1:0] ahb_hresp_in;
wire       ahb_hready_pty_err;
wire       ahb_hresp_pty_err;
wire [`DATA_PTY_RANGE] ahb_hrdata_pty_err;

/////////////////////////////////////////////////////////////////////////////
// Miscellaneous Logics
//
//
/////////////////////////////////////////////////////////////////////////////
reg [9:0] inc;
reg [9:0] msk;
wire [9:0] ibp_cmd_addr_lo;
wire [9:0] biu_cmd_addr_lo;
reg [`ADDR_RANGE] biu_cmd_addr_r;
wire ibp_cmd_addr_1kb;
wire biu_cmd_addr_1kb;
wire [`ADDR_RANGE] biu_cmd_addr_last;
wire is_1kb_cross;

assign ibp_cmd_addr_aligned = (ibp_cmd_addr >> ibp_cmd_data_size) << ibp_cmd_data_size;

  // Next addr calculate
  //
  // spyglass disable_block W164a
  // SMD: LHS is less than RHS        
  // SJ:  Intended as per the design. No possible loss of data
assign biu_cmd_addr_lo = (biu_cmd_addr_r[9:0] & (~msk)) | ((biu_cmd_addr_r[9:0] + inc) & msk);
assign ibp_cmd_addr_lo = (ibp_cmd_addr_aligned[9:0] & (~msk)) | ((ibp_cmd_addr_aligned[9:0] + inc) & msk);
  // spyglass enable_block W164a
assign biu_cmd_addr_1kb = (inc == 10'd1) & (biu_cmd_addr_r[9:0] == 10'h3ff)
                          | (inc == 10'd2) & (biu_cmd_addr_r[9:0] == 10'h3fe)
						  | (inc == 10'd4) & (biu_cmd_addr_r[9:0] == 10'h3fc)
						  ;
assign ibp_cmd_addr_1kb = (inc == 10'd1) & (ibp_cmd_addr_aligned[9:0] == 10'h3ff)
                          | (inc == 10'd2) & (ibp_cmd_addr_aligned[9:0] == 10'h3fe)
						  | (inc == 10'd4) & (ibp_cmd_addr_aligned[9:0] == 10'h3fc)
						  ;
  // spyglass disable_block W164a
  // SMD: LHS is less than RHS        
  // SJ:  Intended as per the design. No possible loss of data
assign biu_cmd_addr_last = ibp_cmd_addr_aligned + (ibp_cmd_burst_size << ibp_cmd_data_size);
  // spyglass enable_block W164a
assign is_1kb_cross = |((ibp_cmd_addr_aligned[`ADDR_MSB:10] ^ biu_cmd_addr_last[`ADDR_MSB:10]));

always @*
begin : hburst_comb_PROC
  case (ibp_cmd_burst_size)
   3'd0:   ahb_hburst_w = AHB_SINGLE;
   3'd3:   ahb_hburst_w = ibp_cmd_wrap ? AHB_WRAP4 : (is_1kb_cross ? AHB_INCR : AHB_INCR4);
   3'd7:   ahb_hburst_w = ibp_cmd_wrap ? AHB_WRAP8 : (is_1kb_cross ? AHB_INCR : AHB_INCR8);
      default : ahb_hburst_w = AHB_INCR;
  endcase
end

always @*
begin : burst_addr_msk_PROC
  msk = 10'h0;
  case ({ahb_hburst, ahb_hsize})
    {AHB_WRAP4,  AHB_BYTE} :     msk[5:0] = 6'b000011;
    {AHB_WRAP8,  AHB_BYTE} :     msk[5:0] = 6'b000111;
    {AHB_WRAP16, AHB_BYTE} :     msk[5:0] = 6'b001111;
    {AHB_WRAP4,  AHB_HALF_WORD}: msk[5:0] = 6'b000111;
    {AHB_WRAP8,  AHB_HALF_WORD}: msk[5:0] = 6'b001111;
    {AHB_WRAP16, AHB_HALF_WORD}: msk[5:0] = 6'b011111;
    {AHB_WRAP4,  AHB_WORD} :     msk[5:0] = 6'b001111;
    {AHB_WRAP8,  AHB_WORD} :     msk[5:0] = 6'b011111;
    {AHB_WRAP16, AHB_WORD} :     msk[5:0] = 6'b111111;
    default:                     msk      = 10'h3ff;
  endcase

  case (ahb_hsize)
    AHB_BYTE:                    inc = 10'd1;
    AHB_HALF_WORD:               inc = 10'd2;
    AHB_WORD:                    inc = 10'd4;
    default:                     inc = 10'd4;
  endcase
end




reg                 arb_cmd_id;
reg                 arb_cmd_id_r;
reg                 arb_cmd_id_nxt;

reg [1:0]           arb_cmd_state_r;
reg [1:0]           arb_cmd_state_nxt;

reg                 arb_cmd_cg0;          
reg [`ADDR_RANGE]   arb_cmd_addr_r;      
reg                 arb_cmd_wrap_r;
reg                 arb_cmd_read_r;      
reg [2:0]           arb_cmd_data_size_r; 
reg [1:0]           arb_cmd_prot_r;  
reg [3:0]           arb_cmd_cache_r;
reg [`IC_WRD_RANGE]    arb_cmd_burst_size_r; 
reg [`IC_WRD_RANGE]    arb_cmd_burst_size_nxt; 

reg [`WID_RANGE]    arb_cmd_wid_r;
reg [`WID_RANGE]    arb_cmd_wid_nxt;

reg                 arb_cmd_fch_vec_r;
reg                 arb_cmd_fch_vec_nxt;

reg [`ADDR_RANGE]   arb_cmd_addr_nxt;      
reg                 arb_cmd_wrap_nxt;
reg                 arb_cmd_read_nxt;      
reg [2:0]           arb_cmd_data_size_nxt; 
reg [1:0]           arb_cmd_prot_nxt;  
reg [3:0]           arb_cmd_cache_nxt;

reg                 arb_wr_cg0;
reg [3:0]           arb_wr_mask_r;
reg [3:0]           arb_wr_mask_nxt;

reg                 arb_cmd_excl_r;
reg                 arb_cmd_excl_nxt;
 
//////////////////////////////////////////////////////////////////////////////////////////
//
//   C O M M A N D   A R B I T R A T I O N - simple
//
//////////////////////////////////////////////////////////////////////////////////////////

localparam BIU_IFU = 1'b0;
localparam BIU_LSQ = 1'b1;

localparam ARB_CMD_DEFAULT = 2'b00;
localparam ARB_CMD_WDATA   = 2'b01;
localparam ARB_CMD_BURST   = 2'b10;
localparam ARB_CMD_WAIT    = 2'b11;

always @*
begin : cmd_arb_PROC
  // Default values
  //
  arb_cmd_id           = BIU_LSQ;
  
  ibp_cmd_valid        = 1'b0;
  ibp_cmd_cache        = 4'b0000;
  ibp_cmd_burst_size   = 3'b0;
  ibp_cmd_read         = lsq_mem_cmd_read;         
  ibp_cmd_aux          = 1'b0;            
  ibp_cmd_addr         = lsq_mem_cmd_addr;
  ibp_cmd_wid          = cmd_wid;
  ibp_cmd_fch_vec      = 1'b0;
  ibp_cmd_wrap         = 1'b0;
  ibp_cmd_excl         = 1'b0;
  ibp_cmd_atomic       = 6'b0;
  ibp_cmd_data_size    = 3'b000;
  ibp_cmd_prot         = 2'b00;      
  ibp_wr_valid         = lsq_mem_wr_valid;
  ibp_wr_mask          = lsq_mem_wr_mask;
  
  if (lsq_mem_cmd_valid)
  begin
    ibp_cmd_valid      = 1'b1;
	ibp_cmd_cache      = lsq_mem_cmd_cache;
    ibp_cmd_burst_size = {2'b0, lsq_mem_cmd_burst_size};
    ibp_cmd_read       = lsq_mem_cmd_read;  
    ibp_cmd_aux        = lsq_mem_cmd_aux;     
    ibp_cmd_addr       = lsq_mem_cmd_addr;
	ibp_cmd_wrap       = 1'b0;
    ibp_cmd_excl       = lsq_mem_cmd_excl;
    ibp_cmd_atomic     = lsq_mem_cmd_atomic;
    ibp_cmd_data_size  = lsq_mem_cmd_data_size;
    ibp_cmd_prot       = lsq_mem_cmd_prot;
    
    arb_cmd_id         = BIU_LSQ;
  end
  else if (ifu_mem_cmd_valid)
  begin
    ibp_cmd_valid      = 1'b1;
	ibp_cmd_cache      = ifu_mem_cmd_cache;
    ibp_cmd_burst_size = ifu_mem_cmd_burst_size;
    ibp_cmd_read       = ifu_mem_cmd_read;  
    ibp_cmd_aux        = ifu_mem_cmd_aux;     
    ibp_cmd_addr       = ifu_mem_cmd_addr;
	ibp_cmd_wrap       = ifu_mem_cmd_wrap;
    ibp_cmd_excl       = ifu_mem_cmd_excl;
    ibp_cmd_atomic     = ifu_mem_cmd_atomic;
    ibp_cmd_data_size  = ifu_mem_cmd_data_size;
    ibp_cmd_prot       = ifu_mem_cmd_prot;
    ibp_cmd_fch_vec    = ifu_fch_vec;
   
    arb_cmd_id         = BIU_IFU;
  end
  arb_cmd_cg0            = 1'b1;
  arb_wr_cg0             = 1'b1;
  arb_cmd_cache_nxt      = ibp_cmd_cache;
  arb_cmd_addr_nxt       = ibp_cmd_addr_aligned;
  arb_cmd_wid_nxt        = ibp_cmd_wid;
  arb_cmd_fch_vec_nxt    = ibp_cmd_fch_vec;
  arb_cmd_wrap_nxt       = ibp_cmd_wrap;
  arb_cmd_burst_size_nxt = ibp_cmd_burst_size;
  arb_cmd_read_nxt       = ibp_cmd_read;
  arb_cmd_data_size_nxt  = ibp_cmd_data_size;
  arb_cmd_prot_nxt       = ibp_cmd_prot;
  arb_wr_mask_nxt        = ibp_wr_mask;
  arb_cmd_excl_nxt       = ibp_cmd_excl;
  arb_cmd_id_nxt         = arb_cmd_id_r;
  
  arb_cmd_state_nxt      = arb_cmd_state_r;
  
  case (arb_cmd_state_r)
  ARB_CMD_DEFAULT:
  begin
     arb_cmd_cg0        = ibp_cmd_valid;
	 arb_wr_cg0         = ibp_cmd_valid & ibp_wr_valid;
     
    if (ibp_cmd_valid)
    begin
      arb_cmd_id_nxt   = arb_cmd_id;
      if ((ibp_wr_valid == 1'b0) && (ibp_cmd_read == 1'b0))
	  begin
        arb_cmd_state_nxt  = ARB_CMD_WDATA;
	  end
	  else
	  begin
        if (ahb_hready == 1'b0)
        begin
          arb_cmd_state_nxt  = ARB_CMD_WAIT;
        end
        else
        begin
          if (ibp_cmd_burst_size != 3'b0)
          begin
            arb_cmd_state_nxt  = ARB_CMD_BURST;
          end
        end
	  end
    end
  end

  ARB_CMD_WDATA:
  begin
    arb_wr_cg0                 = ibp_wr_valid;

    arb_cmd_id                 = arb_cmd_id_r;
	arb_cmd_burst_size_nxt     = arb_cmd_burst_size_r;
    arb_cmd_cache_nxt          = arb_cmd_cache_r;
	arb_cmd_wid_nxt            = arb_cmd_wid_r;
    arb_cmd_fch_vec_nxt        = arb_cmd_fch_vec_r;
    arb_cmd_addr_nxt           = arb_cmd_addr_r;
	arb_cmd_wrap_nxt           = arb_cmd_wrap_r;
    arb_cmd_read_nxt           = arb_cmd_read_r;
    arb_cmd_data_size_nxt      = arb_cmd_data_size_r;
    arb_cmd_prot_nxt           = arb_cmd_prot_r;
    arb_wr_mask_nxt            = arb_wr_mask_r;
    arb_cmd_excl_nxt           = arb_cmd_excl_r;
    
    ibp_cmd_valid        = 1'b1;
    ibp_cmd_cache        = arb_cmd_cache_r;
    ibp_cmd_burst_size   = arb_cmd_burst_size_r;
    ibp_cmd_read         = arb_cmd_read_r;
    ibp_cmd_aux          = 1'b0; 
	ibp_cmd_wid          = arb_cmd_wid_r;
	ibp_cmd_fch_vec      = arb_cmd_fch_vec_r;
    ibp_cmd_addr         = arb_cmd_addr_r;
	ibp_cmd_wrap         = arb_cmd_wrap_r;
    ibp_cmd_excl         = arb_cmd_excl_r;
    ibp_cmd_atomic       = 6'b0;
    ibp_cmd_data_size    = arb_cmd_data_size_r;
    ibp_cmd_prot         = arb_cmd_prot_r;
	ibp_wr_mask          = arb_wr_mask_r;

    if (ibp_wr_valid && !ahb_hready)
	begin
      arb_cmd_state_nxt  = ARB_CMD_WAIT;
	end
    else if (ibp_wr_valid && ahb_hready)
    begin
      if (ibp_cmd_burst_size != 3'b0)
      begin
        arb_cmd_state_nxt  = ARB_CMD_BURST;
      end
      else
      begin
        arb_cmd_state_nxt  = ARB_CMD_DEFAULT;
      end
    end
  end
  
  ARB_CMD_BURST:
  begin
    arb_cmd_id                 = arb_cmd_id_r;
	arb_cmd_burst_size_nxt     = arb_cmd_burst_size_r;
	arb_cmd_cache_nxt          = arb_cmd_cache_r;
    arb_cmd_addr_nxt           = arb_cmd_addr_r;
	arb_cmd_wid_nxt            = arb_cmd_wid_r;
    arb_cmd_fch_vec_nxt        = arb_cmd_fch_vec_r;
	arb_cmd_wrap_nxt           = arb_cmd_wrap_r;
    arb_cmd_read_nxt           = arb_cmd_read_r;
    arb_cmd_data_size_nxt      = arb_cmd_data_size_r;
    arb_cmd_prot_nxt           = arb_cmd_prot_r;
    arb_wr_mask_nxt            = arb_wr_mask_r;
    arb_cmd_excl_nxt           = arb_cmd_excl_r;
    
    if (ahb_hready)
    begin
      arb_cmd_burst_size_nxt   = arb_cmd_burst_size_r - 1'b1;
      
      if (arb_cmd_burst_size_r == 3'b1)
      begin
        arb_cmd_state_nxt  = ARB_CMD_DEFAULT;
      end
    end
  end
  
  default: // ARB_CMD_WAIT
  begin
    arb_cmd_id                 = arb_cmd_id_r;
	arb_cmd_burst_size_nxt     = arb_cmd_burst_size_r;
    arb_cmd_cache_nxt          = arb_cmd_cache_r;
    arb_cmd_addr_nxt           = arb_cmd_addr_r;
	arb_cmd_wid_nxt            = arb_cmd_wid_r;
    arb_cmd_fch_vec_nxt        = arb_cmd_fch_vec_r;
	arb_cmd_wrap_nxt           = arb_cmd_wrap_r;
    arb_cmd_read_nxt           = arb_cmd_read_r;
    arb_cmd_data_size_nxt      = arb_cmd_data_size_r;
    arb_cmd_prot_nxt           = arb_cmd_prot_r;
    arb_wr_mask_nxt            = arb_wr_mask_r;
    arb_cmd_excl_nxt           = arb_cmd_excl_r;
    
    ibp_cmd_valid        = 1'b1;
    ibp_cmd_cache        = arb_cmd_cache_r;
    ibp_cmd_burst_size   = arb_cmd_burst_size_r;
    ibp_cmd_read         = arb_cmd_read_r;
    ibp_cmd_aux          = 1'b0;       
    ibp_cmd_addr         = arb_cmd_addr_r;
	ibp_cmd_wid          = arb_cmd_wid_r;
	ibp_cmd_fch_vec      = arb_cmd_fch_vec_r;
	ibp_cmd_wrap         = arb_cmd_wrap_r;
    ibp_cmd_excl         = arb_cmd_excl_r;
    ibp_cmd_atomic       = 6'b0;
    ibp_cmd_data_size    = arb_cmd_data_size_r;
    ibp_cmd_prot         = arb_cmd_prot_r;
	ibp_wr_mask          = arb_wr_mask_r;
    
    if (ahb_hready)
    begin
      if (ibp_cmd_burst_size != 3'b0)
      begin
        arb_cmd_state_nxt  = ARB_CMD_BURST;
      end
      else
      begin
        arb_cmd_state_nxt  = ARB_CMD_DEFAULT;
      end
    end
  end
  endcase
  
end

reg               biu_cmd_burst_count_cg0;

reg               biu_cmd_read_r;
reg [6:0]         biu_cmd_prot_r;
reg [3:0]         biu_wr_mask_r;
reg [2:0]         biu_cmd_burst_r;
reg [2:0]         biu_cmd_data_size_r;
reg               biu_cmd_excl_r;
reg [`DATA_RANGE] biu_wr_data_r;

reg [`WID_RANGE]  biu_cmd_wid_r;
reg [`WID_RANGE]  biu_cmd_wid_nxt;
reg               biu_cmd_fch_vec_r;
reg               biu_cmd_fch_vec_nxt;
reg [`ADDR_RANGE] biu_cmd_addr_nxt; 
reg               biu_cmd_read_nxt;
reg [6:0]         biu_cmd_prot_nxt;
reg [3:0]         biu_wr_mask_nxt;
reg [2:0]         biu_cmd_burst_nxt;
reg [2:0]         biu_cmd_data_size_nxt;
reg               biu_cmd_excl_nxt;
reg [`DATA_RANGE] biu_wr_data_nxt;
reg               biu_wr_data_cg;

reg [`IC_WRD_RANGE]    biu_cmd_burst_count_r; 
reg [`IC_WRD_RANGE]    biu_cmd_burst_count_nxt; 

reg               biu_cmd_id;

reg               biu_cmd_cg0;
reg               biu_wr_cg0;
reg [2:0]         biu_cmd_state_r;       
reg [2:0]         biu_cmd_state_nxt;       

///////////////////////////////////////////////////////////////////////////////
// 
// Design: the arbiter selects the IBP command to be initiated. The FSM converts
// the command to AHB5
//
//////////////////////////////////////////////////////////////////////////////////

localparam BIU_CMD_DEFAULT   = 3'b000;
localparam BIU_CMD_WDATA     = 3'b001;
localparam BIU_CMD_BURST     = 3'b010;
localparam BIU_CMD_BURST_1KB = 3'b011;
localparam BIU_CMD_WAIT      = 3'b100;

always @*
begin : biu_cmd_fsm_PROC
  // Default values
  //
  ibp_cmd_accept           = 1'b0;
  
  // AHB5 address and control
  //
  ahb_htrans               = AHB_IDLE;
  ahb_hwrite               = 1'b0;
  ahb_haddr                = {`ADDR_SIZE{1'b0}};
  ahb_hsize                = AHB_WORD;  
  ahb_hburst               = AHB_SINGLE;   
  ahb_hprot                = 7'h00; // @@@
  ahb_hnonsec              = 1'b1;
  ahb_hlock                = 1'b0;
  ahb_hauser               = `AUSER_BITS'b0;

  ahb_hexcl                = 1'b0;
  ahb_hmaster              = 4'h0;
  
  
  biu_cmd_burst_count_cg0  = 1'b1;
  biu_cmd_burst_count_nxt  = biu_cmd_burst_count_r;

  biu_cmd_wid_nxt          = biu_cmd_wid_r;
  biu_cmd_fch_vec_nxt      = biu_cmd_fch_vec_r;
  
  biu_cmd_addr_nxt         = biu_cmd_addr_r;
  biu_cmd_read_nxt         = biu_cmd_read_r;
  biu_cmd_prot_nxt         = biu_cmd_prot_r;
  biu_wr_mask_nxt          = biu_wr_mask_r;
  biu_cmd_burst_nxt        = biu_cmd_burst_r;
  biu_cmd_data_size_nxt    = biu_cmd_data_size_r;
  biu_cmd_excl_nxt         = biu_cmd_excl_r;
  
  biu_cmd_cg0              = 1'b1;
  biu_wr_cg0               = 1'b1;
  biu_cmd_id               = arb_cmd_id;
  biu_cmd_state_nxt        = biu_cmd_state_r;

  
  case (biu_cmd_state_r)
  BIU_CMD_DEFAULT:
  begin
    biu_cmd_cg0            = ibp_cmd_valid;
	biu_wr_cg0             = ibp_cmd_valid & ibp_wr_valid;

    if (ibp_cmd_valid)
    begin
	  biu_cmd_wid_nxt          = ibp_cmd_wid;
	  if ((ibp_wr_valid == 1'b0) && (ibp_cmd_read == 1'b0))
	  begin
        biu_cmd_state_nxt      = BIU_CMD_WDATA;
	  end
	  else
	  begin
        ibp_cmd_accept           = ahb_hready;
        
        // Drive AHB signnals
        //
        ahb_htrans               = AHB_NONSEQ;
        ahb_hwrite               = (~ibp_cmd_read);
        ahb_haddr                = ibp_cmd_addr_aligned;
        ahb_hsize                = ibp_cmd_data_size;
        ahb_hburst               = ahb_hburst_w;
        ahb_hprot                = {3'h0,|ibp_cmd_cache[3:2]&ibp_cmd_cache[1],ibp_cmd_cache[0],ibp_cmd_prot[0],~ibp_cmd_prot[1]};  
	    ahb_hexcl                = ibp_cmd_excl;
		ahb_hauser[`AUSER_WID_RANGE] = ibp_cmd_wid;
		ahb_hauser[`AUSER_FCH_VEC_RANGE] = ibp_cmd_fch_vec;

		if (ahb_hready == 1'b0)
        begin
          // IBP command not accepted
          //
          biu_cmd_state_nxt       = BIU_CMD_WAIT;
        end
        else if (| ibp_cmd_burst_size)
        begin
          biu_cmd_burst_count_cg0  = 1'b1;
		  if (ibp_cmd_addr_1kb && ahb_hburst_w[0]) // about to cross 1KB boundary and it's incrementing burst
            biu_cmd_state_nxt        = BIU_CMD_BURST_1KB;
		  else
			biu_cmd_state_nxt        = BIU_CMD_BURST;
        end
	  end
	  if (ibp_cmd_accept)
	  begin
        biu_cmd_burst_count_nxt  = ibp_cmd_burst_size;
        if (ibp_cmd_addr_1kb && ahb_hburst_w[0])
  // spyglass disable_block W164a
  // SMD: LHS is less than RHS        
  // SJ:  Intended as per the design. No possible loss of data

          biu_cmd_addr_nxt         = {(ibp_cmd_addr_aligned[`ADDR_MSB:10] + 1), ibp_cmd_addr_lo};
  // spyglass enable_block W164a		
		else
		  biu_cmd_addr_nxt         = {ibp_cmd_addr_aligned[`ADDR_MSB:10], ibp_cmd_addr_lo};

        biu_cmd_read_nxt         = ibp_cmd_read;
        biu_cmd_prot_nxt         = {3'h0,|ibp_cmd_cache[3:2]&ibp_cmd_cache[1],ibp_cmd_cache[0],ibp_cmd_prot[0],~ibp_cmd_prot[1]};
	    biu_cmd_burst_nxt        = ahb_hburst_w;
	    biu_cmd_data_size_nxt    = ibp_cmd_data_size;
	    biu_cmd_excl_nxt         = ibp_cmd_excl;
        biu_cmd_fch_vec_nxt      = ibp_cmd_fch_vec;

	    if (ibp_wr_valid)
	    begin
          biu_wr_mask_nxt          = ibp_cmd_read ? 4'h0: ibp_wr_mask;
	    end
      end
	end
  end

  BIU_CMD_WDATA:
  begin
    if (ibp_wr_valid)
    begin
      ibp_cmd_accept           = ahb_hready;
      
      // Drive AHB signnals
      //
      ahb_htrans               = AHB_NONSEQ;
      ahb_hwrite               = (~ibp_cmd_read);
      ahb_haddr                = ibp_cmd_addr_aligned;
      ahb_hsize                = ibp_cmd_data_size;
      ahb_hburst               = ahb_hburst_w;
      ahb_hprot                = {3'h0,|ibp_cmd_cache[3:2]&ibp_cmd_cache[1],ibp_cmd_cache[0],ibp_cmd_prot[0],~ibp_cmd_prot[1]};  
	  ahb_hexcl                = ibp_cmd_excl;
		ahb_hauser[`AUSER_WID_RANGE] = biu_cmd_wid_r;
		ahb_hauser[`AUSER_FCH_VEC_RANGE] = ibp_cmd_fch_vec;

	  biu_wr_cg0               = 1'b1;

	  if (ibp_cmd_accept)
	  begin
        biu_cmd_burst_count_nxt  = ibp_cmd_burst_size;
        if (ibp_cmd_addr_1kb && ahb_hburst_w[0])
  // spyglass disable_block W164a
  // SMD: LHS is less than RHS        
  // SJ:  Intended as per the design. No possible loss of data

          biu_cmd_addr_nxt         = {(ibp_cmd_addr_aligned[`ADDR_MSB:10] + 1), ibp_cmd_addr_lo};
  // spyglass enable_block W164a		
		else        
          biu_cmd_addr_nxt         = {ibp_cmd_addr_aligned[`ADDR_MSB:10], ibp_cmd_addr_lo};
        
		biu_cmd_read_nxt         = ibp_cmd_read;
        biu_cmd_prot_nxt         = {3'h0,|ibp_cmd_cache[3:2]&ibp_cmd_cache[1],ibp_cmd_cache[0],ibp_cmd_prot[0],~ibp_cmd_prot[1]};
	    biu_cmd_burst_nxt        = ahb_hburst_w;
	    biu_cmd_data_size_nxt    = ibp_cmd_data_size;
	    biu_cmd_excl_nxt         = ibp_cmd_excl;
        biu_cmd_fch_vec_nxt      = ibp_cmd_fch_vec;

        biu_wr_mask_nxt          = ibp_cmd_read ? 4'h0: ibp_wr_mask;
      end

	  if (ahb_hready == 1'b0)
      begin
        // IBP command not accepted
        //
        biu_cmd_state_nxt       = BIU_CMD_WAIT;
      end
      else if (| ibp_cmd_burst_size)
      begin
        biu_cmd_burst_count_cg0  = 1'b1;
		if (ibp_cmd_addr_1kb && ahb_hburst_w[0]) // about to cross 1KB boundary and it's incrementing burst
          biu_cmd_state_nxt        = BIU_CMD_BURST_1KB;
		else
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
    ibp_cmd_accept           = ahb_hready;
    
    // Drive AHB signnals
    //
    ahb_htrans               = AHB_NONSEQ;
    ahb_hwrite               = (~ibp_cmd_read);
    ahb_haddr                = ibp_cmd_addr_aligned;
    ahb_hsize                = ibp_cmd_data_size;
    ahb_hburst               = ahb_hburst_w;
    ahb_hprot                = {3'h0,|ibp_cmd_cache[3:2]&ibp_cmd_cache[1],ibp_cmd_cache[0],ibp_cmd_prot[0],~ibp_cmd_prot[1]}; 
	ahb_hexcl                = ibp_cmd_excl;
		ahb_hauser[`AUSER_WID_RANGE] = biu_cmd_wid_r;
		ahb_hauser[`AUSER_FCH_VEC_RANGE] = ibp_cmd_fch_vec;
     
	if (ibp_cmd_accept)
	begin
      biu_cmd_burst_count_nxt  = ibp_cmd_burst_size;
        if (ibp_cmd_addr_1kb && ahb_hburst_w[0])
  // spyglass disable_block W164a
  // SMD: LHS is less than RHS        
  // SJ:  Intended as per the design. No possible loss of data

          biu_cmd_addr_nxt         = {(ibp_cmd_addr_aligned[`ADDR_MSB:10] + 1), ibp_cmd_addr_lo};
  // spyglass enable_block W164a		
		else        
          biu_cmd_addr_nxt         = {ibp_cmd_addr_aligned[`ADDR_MSB:10], ibp_cmd_addr_lo};

      biu_cmd_addr_nxt         = {ibp_cmd_addr_aligned[`ADDR_MSB:10], ibp_cmd_addr_lo};
      biu_cmd_read_nxt         = ibp_cmd_read;
      biu_cmd_prot_nxt         = ahb_hprot;
	  biu_wr_mask_nxt          = ibp_cmd_read ? 4'h0: ibp_wr_mask;
	  biu_cmd_burst_nxt        = ahb_hburst_w;
	  biu_cmd_data_size_nxt    = ibp_cmd_data_size;
	  biu_cmd_excl_nxt         = ibp_cmd_excl;
      biu_cmd_fch_vec_nxt      = ibp_cmd_fch_vec;
	end

    
    if (ahb_hready == 1'b1)
    begin
      ibp_cmd_accept = 1'b1;
      
      if (| ibp_cmd_burst_size)
      begin
        biu_cmd_burst_count_cg0 = 1'b1;
		if (ibp_cmd_addr_1kb && ahb_hburst_w[0]) // about to cross 1KB boundary and it's incrementing burst
          biu_cmd_state_nxt        = BIU_CMD_BURST_1KB;
		else
          biu_cmd_state_nxt       = BIU_CMD_BURST;
      end
      else
      begin
        biu_cmd_state_nxt       = BIU_CMD_DEFAULT;
      end
    end
  end

  BIU_CMD_BURST_1KB:
  begin
    biu_cmd_burst_count_cg0 = ahb_hready;
    biu_cmd_burst_count_nxt = biu_cmd_burst_count_r - 1'b1;
    
    biu_cmd_addr_nxt        = {biu_cmd_addr_r[`ADDR_MSB:10], biu_cmd_addr_lo}; 
    // Drive AHB signnals
    //
    ahb_htrans              = AHB_NONSEQ;
    ahb_hwrite              = (~biu_cmd_read_r);
    ahb_haddr               = biu_cmd_addr_r;
    ahb_hsize               = biu_cmd_data_size_r;
    ahb_hburst              = biu_cmd_burst_r;
    ahb_hprot               = biu_cmd_prot_r;
	ahb_hexcl               = biu_cmd_excl_r;
	ahb_hauser[`AUSER_WID_RANGE] = biu_cmd_wid_r;
    ahb_hauser[`AUSER_FCH_VEC_RANGE] = biu_cmd_fch_vec_r;
    
    if (  (biu_cmd_burst_count_r == 3'b1)
        && ahb_hready)
    begin
      biu_cmd_state_nxt = BIU_CMD_DEFAULT;
    end
	else if ((biu_cmd_burst_count_r != 3'b1) && ahb_hready)
	begin
	  biu_cmd_state_nxt = BIU_CMD_BURST;
	end
  end

  BIU_CMD_BURST:
  begin
    biu_cmd_burst_count_cg0 = ahb_hready;
    biu_cmd_burst_count_nxt = biu_cmd_burst_count_r - 1'b1;

	if (biu_cmd_addr_1kb && biu_cmd_burst_r[0]) // about to cross 1KB boundary and it's incrementing burst
  // spyglass disable_block W164a
  // SMD: LHS is less than RHS        
  // SJ:  Intended as per the design. No possible loss of data
      biu_cmd_addr_nxt        = {(biu_cmd_addr_r[`ADDR_MSB:10] + 1), biu_cmd_addr_lo};
  // spyglass enable_block W164a
	else
	  biu_cmd_addr_nxt        = {biu_cmd_addr_r[`ADDR_MSB:10], biu_cmd_addr_lo};
//    biu_wr_mask_nxt         = biu_cmd_read_r ? 4'h0: ibp_wr_mask;
    // Drive AHB signnals
    //
    ahb_htrans              = AHB_SEQ;
    ahb_hwrite              = (~biu_cmd_read_r);
    ahb_haddr               = biu_cmd_addr_r;
    ahb_hsize               = biu_cmd_data_size_r;
    ahb_hburst              = biu_cmd_burst_r;
    ahb_hprot               = biu_cmd_prot_r;
	ahb_hexcl               = biu_cmd_excl_r;
	ahb_hauser[`AUSER_WID_RANGE] = biu_cmd_wid_r;
    ahb_hauser[`AUSER_FCH_VEC_RANGE] = biu_cmd_fch_vec_r;
    
    if (  (biu_cmd_burst_count_r == 3'b1)
        & ahb_hready)
    begin
      biu_cmd_state_nxt = BIU_CMD_DEFAULT;
    end
	else if ((biu_cmd_burst_count_r != 3'b1)
        && ahb_hready
		&& biu_cmd_addr_1kb
		&& biu_cmd_burst_r[0])
	begin
      biu_cmd_state_nxt = BIU_CMD_BURST_1KB;
	end
  end
  endcase
end

reg        biu_resp_cg0;
reg [1:0]  biu_resp_state_r;
reg [1:0]  biu_resp_state_nxt;

reg        biu_resp_id_r;
reg        biu_pending_rd_r;
reg        biu_pending_wr_r;

reg        biu_resp_id_cg0;
reg        biu_resp_id_nxt;
reg        biu_pending_rd_nxt;
reg        biu_pending_wr_nxt;

///////////////////////////////////////////////////////////////////////////////
// 
// Response FSM
// 
//////////////////////////////////////////////////////////////////////////////////

localparam BIU_RESP_ADDR_PHASE          = 2'b00;
localparam BIU_RESP_DATA_PHASE          = 2'b01;
localparam BIU_RESP_MULTIPLE_DATA_PHASE = 2'b10;
localparam BIU_RESP_ERROR               = 2'b11;


always @*
begin: biu_resp_fsm_PROC
  // Default values
  //
  ibp_rd_valid       = 1'b0;
  ibp_rd_last        = 1'b0;
  ibp_rd_err         = 1'b0;
  ibp_rd_excl_ok     = 1'b0;
  
  ibp_wr_accept      = 1'b0;
  ibp_wr_done        = 1'b0;
  ibp_wr_done_set    = 1'b0;
  ibp_wr_done_clr    = lsq_mem_wr_resp_accept & ibp_wr_done_r;
  ibp_wr_err         = 1'b0;
  ibp_wr_err_set     = 1'b0;
  ibp_wr_err_clr     = lsq_mem_wr_resp_accept & ibp_wr_err_r; 
  ibp_wr_excl_okay     = 1'b0;
  ibp_wr_excl_okay_set = 1'b0;
  ibp_wr_excl_okay_clr = lsq_mem_wr_resp_accept & ibp_wr_excl_okay_r;

  ahb_hwstrb         = 4'h0;
  ahb_hwdata         = biu_wr_data_r;
  biu_wr_data_nxt    = biu_wr_data_r;
  biu_wr_data_cg     = 1'b0;

  biu_resp_id_cg0    = 1'b0;
  biu_resp_id_nxt    = biu_resp_id_r;
  biu_pending_rd_nxt = biu_pending_rd_r;
  biu_pending_wr_nxt = biu_pending_wr_r;
  
  biu_resp_cg0       = 1'b1;
  biu_resp_state_nxt = biu_resp_state_r;
  
  case (biu_resp_state_r)
  BIU_RESP_ADDR_PHASE:
  begin
    biu_resp_cg0      = (ahb_htrans != AHB_IDLE);
    
    if (  (ahb_htrans != AHB_IDLE)
        & ahb_hready)
    begin
      biu_resp_id_cg0    = 1'b1;
      biu_resp_id_nxt    = biu_cmd_id;
      
      biu_pending_rd_nxt = !ahb_hwrite;
      biu_pending_wr_nxt =  ahb_hwrite;

	  biu_wr_data_nxt    = lsq_mem_wr_data; 
      biu_wr_data_cg     = ahb_hwrite;

	  ibp_wr_accept      = ahb_hwrite;
      
      if (| ahb_hburst)
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
      ahb_hwstrb       =  biu_wr_mask_r;
//	  ahb_hwdata       =  biu_wr_data_r;
	end
	
    if (ahb_hresp == AHB_LITE_OKAY)
    begin
      // Provide IBP response
      //
      if (ahb_hready)
      begin
        ibp_rd_valid    = biu_pending_rd_r;
        ibp_rd_last     = biu_pending_rd_r;
		ibp_rd_excl_ok  = biu_pending_rd_r & ahb_hexokay;
        
		ibp_wr_excl_okay     = biu_pending_wr_r & ahb_hexokay;
        ibp_wr_excl_okay_set = biu_pending_wr_r & ahb_hexokay & !lsq_mem_wr_resp_accept;
		ibp_wr_done     = biu_pending_wr_r;
        ibp_wr_done_set = biu_pending_wr_r & !lsq_mem_wr_resp_accept;
        
        if (ahb_htrans != AHB_IDLE)
        begin
          // Back-to-back transfers - address phase
          //
          biu_resp_id_cg0    = 1'b1;
          biu_resp_id_nxt    = biu_cmd_id;

          biu_pending_rd_nxt = !ahb_hwrite;
          biu_pending_wr_nxt =  ahb_hwrite;

	      biu_wr_data_nxt    = lsq_mem_wr_data; 
          biu_wr_data_cg     = ahb_hwrite;

	      ibp_wr_accept      = ahb_hwrite;

          biu_resp_state_nxt = (| ahb_hburst) ? BIU_RESP_MULTIPLE_DATA_PHASE : BIU_RESP_DATA_PHASE;
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
      if (ahb_hresp == AHB_LITE_ERROR)
      begin
        biu_resp_state_nxt = BIU_RESP_ERROR;
      end
    end
  end
  
  BIU_RESP_MULTIPLE_DATA_PHASE: 
  begin
    if (biu_pending_wr_r)
	begin
      ahb_hwstrb       =  biu_wr_mask_r;
//	  ahb_hwdata       =  biu_wr_data_r;
	end
	
      // Provide IBP response
      //
      if (ahb_hready)
      begin
        ibp_rd_valid    = biu_pending_rd_r;
		ibp_rd_err      = biu_pending_rd_r & (ahb_hresp == AHB_LITE_ERROR);

	    biu_wr_data_nxt    = lsq_mem_wr_data; 
        biu_wr_data_cg     = biu_pending_wr_r;

	    ibp_wr_accept      = biu_pending_wr_r;
        
        if (biu_cmd_burst_count_r == 3'b001)
        begin
          biu_resp_state_nxt = BIU_RESP_DATA_PHASE;
        end
      end
  end
  
  default: // BIU_RESP_ERROR:
  begin
    if (biu_pending_rd_r)
	begin
      ibp_rd_err        = 1'b1;
	  ibp_rd_last       = 1'b1;
	  ibp_rd_valid      = 1'b1;
    end
	else
	begin
	  ahb_hwstrb        =  biu_wr_mask_r;
	  ibp_wr_done       = 1'b1;
      ibp_wr_done_set   = !lsq_mem_wr_resp_accept;
	  ibp_wr_err        = 1'b1;
      ibp_wr_err_set    = !lsq_mem_wr_resp_accept;
	end 

    if (  (ahb_htrans != AHB_IDLE)
        & ahb_hready)
    begin
      biu_resp_id_cg0    = 1'b1;
      biu_resp_id_nxt    = biu_cmd_id;
      
      biu_pending_rd_nxt = !ahb_hwrite;
      biu_pending_wr_nxt =  ahb_hwrite;

	  biu_wr_data_nxt    = lsq_mem_wr_data; 
      biu_wr_data_cg     = ahb_hwrite;

	  ibp_wr_accept      = ahb_hwrite;
      
      if (| ahb_hburst)
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

///////////////////////////////////////////////////////////////////////////////
// 
// Demux
// 
//////////////////////////////////////////////////////////////////////////////////

// Registered value for IFU uncahced single read, ifu_rd_accept will be potentially low in such case
reg ifu_ibp_rd_pending_nxt;
reg ifu_ibp_rd_valid_nxt;
reg ifu_ibp_rd_last_nxt;
reg ifu_ibp_rd_err_nxt;
reg [31:0] ifu_ibp_rd_data_nxt;

reg ifu_ibp_rd_pending_r;
reg ifu_ibp_rd_valid_r;
reg ifu_ibp_rd_last_r;
reg ifu_ibp_rd_err_r;
reg [31:0] ifu_ibp_rd_data_r;

reg ifu_mem_rd_valid_w;
reg ifu_mem_rd_last_w;
reg ifu_mem_rd_err_w;
reg [31:0] ifu_mem_rd_data_w;

always @*
begin : ifu_rd_extend_PROC
  ifu_ibp_rd_pending_nxt = ifu_ibp_rd_pending_r;
  ifu_ibp_rd_valid_nxt   = ifu_ibp_rd_valid_r;
  ifu_ibp_rd_last_nxt    = ifu_ibp_rd_last_r;
  ifu_ibp_rd_err_nxt     = ifu_ibp_rd_err_r;
  ifu_ibp_rd_data_nxt    = ifu_ibp_rd_data_r;

  if (ifu_mem_rd_valid_w && !ifu_mem_rd_accept)
  begin
    ifu_ibp_rd_pending_nxt = 1'b1;
    ifu_ibp_rd_valid_nxt   = ifu_mem_rd_valid_w;
    ifu_ibp_rd_last_nxt    = ifu_mem_rd_last_w;
    ifu_ibp_rd_err_nxt     = ifu_mem_rd_err_w;
    ifu_ibp_rd_data_nxt    = ifu_mem_rd_data_w;
  end
  else if (ifu_mem_rd_accept)
  begin
    ifu_ibp_rd_pending_nxt = 1'b0;
    ifu_ibp_rd_valid_nxt   = 1'b0;
    ifu_ibp_rd_last_nxt    = 1'b0;
    ifu_ibp_rd_err_nxt     = 1'b0;
    ifu_ibp_rd_data_nxt    = 32'h0;
  end
end

always @*
begin : biu_resp_demux_PROC
  // Command response
  //
  ifu_mem_cmd_accept   = 1'b0;              
  lsq_mem_cmd_accept   = 1'b0;             
  
  // Read response
  //
  ifu_mem_rd_valid_w     = 1'b0; 
  ifu_mem_rd_last_w      = 1'b0;
  ifu_mem_rd_err_w       = 1'b0;
  ifu_mem_rd_excl_ok     = 1'b0;
  ifu_mem_rd_data_w      = ahb_hrdata;
  
  lsq_mem_rd_valid     = 1'b0;            
  lsq_mem_rd_last      = 1'b0;
  lsq_mem_rd_err       = 1'b0;           
  lsq_mem_rd_excl_ok   = 1'b0;
  lsq_mem_rd_data      = ahb_hrdata;  
  
  
  // Write data phase
  //  
  lsq_mem_wr_accept    = ibp_wr_accept;
  
  // Write response phase
  //  
  
  case (arb_cmd_id)
  BIU_IFU:  ifu_mem_cmd_accept = ibp_cmd_accept;
  BIU_LSQ:  lsq_mem_cmd_accept = ibp_cmd_accept;
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue
  default:; 
// spyglass enable_block W193
  endcase
  
  case (biu_resp_id_r)
  BIU_IFU:
  begin
    ifu_mem_rd_valid_w = ibp_rd_valid;
	ifu_mem_rd_last_w  = ibp_rd_last;
    ifu_mem_rd_err_w   = ibp_rd_err;
	ifu_mem_rd_excl_ok = ibp_rd_excl_ok;
  end
  BIU_LSQ: 
  begin
    lsq_mem_rd_valid  = ibp_rd_valid;
	lsq_mem_rd_last   = ibp_rd_last;
    lsq_mem_rd_err    = ibp_rd_err;
	lsq_mem_rd_excl_ok = ibp_rd_excl_ok;
  end  
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue
  default: ;
// spyglass enable_block W193
  endcase

end

assign ibp_wr_done_nxt = ibp_wr_done_set ? 1'b1 : (ibp_wr_done_clr ? 1'b0 : ibp_wr_done_r);
assign ibp_wr_err_nxt  = ibp_wr_err_set ? 1'b1 : (ibp_wr_err_clr ? 1'b0 : ibp_wr_err_r);
assign ibp_wr_excl_okay_nxt = ibp_wr_excl_okay_set ? 1'b1 : (ibp_wr_excl_okay_clr ? 1'b0 : ibp_wr_excl_okay_r);

assign lsq_mem_wr_done   = ibp_wr_done | ibp_wr_done_r;
assign lsq_mem_wr_err    = ibp_wr_err | ibp_wr_err_r;
assign lsq_mem_wr_excl_okay = ibp_wr_excl_okay | ibp_wr_excl_okay_r;

assign ifu_mem_rd_valid   = ifu_ibp_rd_pending_r ? ifu_ibp_rd_valid_r : ifu_mem_rd_valid_w;
assign ifu_mem_rd_last    = ifu_ibp_rd_pending_r ? ifu_ibp_rd_last_r : ifu_mem_rd_last_w;
assign ifu_mem_rd_err     = ifu_ibp_rd_pending_r ? ifu_ibp_rd_err_r : ifu_mem_rd_err_w;
assign ifu_mem_rd_data    = ifu_ibp_rd_pending_r ? ifu_ibp_rd_data_r : ifu_mem_rd_data_w;

assign biu_cbu_idle = (biu_cmd_state_r == BIU_CMD_DEFAULT) & (biu_resp_state_r == BIU_RESP_ADDR_PHASE) & !ibp_cmd_valid & !ibp_wr_done_r & !ibp_wr_done;
/////////////////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : arb_regs_PROC
  if (rst_a == 1'b1)
  begin
    arb_cmd_state_r      <= ARB_CMD_DEFAULT;
    arb_cmd_id_r         <= BIU_IFU;
    arb_cmd_addr_r       <= {`ADDR_SIZE{1'b0}};    
	arb_cmd_wrap_r       <= 1'b0;
    arb_cmd_burst_size_r <= 3'b0;
    arb_cmd_read_r       <= 1'b0;    
    arb_cmd_data_size_r  <= 3'b000; 
    arb_cmd_prot_r       <= 2'b00;   
	arb_cmd_cache_r      <= 4'h0;
	arb_cmd_excl_r       <= 1'b0;
	arb_cmd_wid_r        <= `WID_BITS'b0;
    arb_cmd_fch_vec_r    <= 1'b0;
  end
  else
  begin
    if (arb_cmd_cg0 == 1'b1)
    begin
      arb_cmd_state_r      <= arb_cmd_state_nxt;
      arb_cmd_id_r         <= arb_cmd_id_nxt;
      arb_cmd_addr_r       <= arb_cmd_addr_nxt;  
	  arb_cmd_wrap_r       <= arb_cmd_wrap_nxt;
      arb_cmd_burst_size_r <= arb_cmd_burst_size_nxt;
      arb_cmd_read_r       <= arb_cmd_read_nxt;          
      arb_cmd_data_size_r  <= arb_cmd_data_size_nxt;  
      arb_cmd_prot_r       <= arb_cmd_prot_nxt; 
	  arb_cmd_cache_r      <= arb_cmd_cache_nxt;
	  arb_cmd_excl_r       <= arb_cmd_excl_nxt;
	  arb_cmd_wid_r        <= arb_cmd_wid_nxt;
      arb_cmd_fch_vec_r    <= arb_cmd_fch_vec_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : arb_wr_regs_PROC
  if (rst_a == 1'b1)
  begin
    arb_wr_mask_r         <= 4'h0;
  end
  else
  begin
    if (arb_wr_cg0 == 1'b1)
	begin
    arb_wr_mask_r         <= arb_wr_mask_nxt;
	end
  end
end

always @(posedge clk or posedge rst_a)
begin : biu_cmd_regs_PROC
  if (rst_a == 1'b1)
  begin
    biu_cmd_state_r       <= BIU_CMD_DEFAULT;
    biu_cmd_burst_count_r <= 3'b000;
    biu_cmd_addr_r        <= {`ADDR_SIZE{1'b0}};    
    biu_cmd_read_r        <= 1'b0;
    biu_cmd_prot_r        <= 7'h0;
	biu_wr_mask_r         <= 4'h0;
	biu_cmd_burst_r       <= 3'h0;
	biu_cmd_data_size_r   <= 3'h0;
	biu_cmd_excl_r        <= 1'b0;
	biu_cmd_wid_r         <= `WID_BITS'b0;
    biu_cmd_fch_vec_r     <= 1'b0;
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
	  biu_wr_mask_r         <= biu_wr_mask_nxt;
	  biu_cmd_burst_r       <= biu_cmd_burst_nxt;
	  biu_cmd_data_size_r   <= biu_cmd_data_size_nxt;
	  biu_cmd_excl_r        <= biu_cmd_excl_nxt;
	  biu_cmd_wid_r         <= biu_cmd_wid_nxt;
      biu_cmd_fch_vec_r     <= biu_cmd_fch_vec_nxt;
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
    biu_resp_id_r    <= 1'b0;
  end
  else
  begin
    if (biu_resp_cg0 == 1'b1)
    begin
      biu_resp_state_r <= biu_resp_state_nxt; 
      biu_pending_rd_r <= biu_pending_rd_nxt; 
      biu_pending_wr_r <= biu_pending_wr_nxt; 
    end
    
    if (biu_resp_id_cg0 == 1'b1)
    begin
      biu_resp_id_r    <= biu_resp_id_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : ibp_wr_done_PROC
  if (rst_a == 1'b1)
  begin
    ibp_wr_done_r <= 1'b0;
  end
  else
  begin
    ibp_wr_done_r <= ibp_wr_done_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : ibp_wr_err_PROC
  if (rst_a == 1'b1)
  begin
    ibp_wr_err_r <= 1'b0;
  end
  else
  begin
    ibp_wr_err_r <= ibp_wr_err_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : ibp_wr_excl_okay_PROC
  if (rst_a == 1'b1)
  begin
    ibp_wr_excl_okay_r <= 1'b0;
  end
  else
  begin
    ibp_wr_excl_okay_r <= ibp_wr_excl_okay_nxt;
  end
end

// Registered value for IFU uncahced single read, ifu_rd_accept will be potentially low in such case
always @(posedge clk or posedge rst_a)
begin : ifu_rd_pending_reg_PROC
  if (rst_a == 1'b1)
  begin
    ifu_ibp_rd_pending_r  <= 1'b0;
	ifu_ibp_rd_valid_r    <= 1'b0;
	ifu_ibp_rd_last_r     <= 1'b0;
	ifu_ibp_rd_err_r      <= 1'b0;
	ifu_ibp_rd_data_r     <= 32'h0;
  end
  else
  begin
    ifu_ibp_rd_pending_r  <= ifu_ibp_rd_pending_nxt;
	ifu_ibp_rd_valid_r    <= ifu_ibp_rd_valid_nxt;
	ifu_ibp_rd_last_r     <= ifu_ibp_rd_last_nxt; 
	ifu_ibp_rd_err_r      <= ifu_ibp_rd_err_nxt;  
	ifu_ibp_rd_data_r     <= ifu_ibp_rd_data_nxt;
  end
end

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
u_ahb_haddr_parity0 (
  .din                   (ahb_haddr[7:0]),
  .q_parity              (ahb_haddrchk[0])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_haddr_parity1 (
  .din                   (ahb_haddr[15:8]),
  .q_parity              (ahb_haddrchk[1])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_haddr_parity2 (
  .din                   (ahb_haddr[23:16]),
  .q_parity              (ahb_haddrchk[2])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_haddr_parity3 (
  .din                   (ahb_haddr[31:24]),
  .q_parity              (ahb_haddrchk[3])
);

rl_parity_gen
#(
.DATA_WIDTH (`AUSER_BITS),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hauser_parity (
  .din                   (ahb_hauser),
  .q_parity              (ahb_hauserchk)
);


rl_parity_gen
#(
.DATA_WIDTH (2),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_htrans_parity (
  .din                   (ahb_htrans),
  .q_parity              (ahb_htranschk)
);

assign ahb_hctrl1 = {ahb_hburst, ahb_hlock, ahb_hwrite, ahb_hsize, ahb_hnonsec};

rl_parity_gen
#(
.DATA_WIDTH (9),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hctrl1_parity (
  .din                   (ahb_hctrl1),
  .q_parity              (ahb_hctrlchk1)
);

assign ahb_hctrl2 = {ahb_hexcl, ahb_hmaster};

rl_parity_gen
#(
.DATA_WIDTH (5),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hctrl2_parity (
  .din                   (ahb_hctrl2),
  .q_parity              (ahb_hctrlchk2)
);

rl_parity_gen
#(
.DATA_WIDTH (7),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hprot_parity (
  .din                   (ahb_hprot),
  .q_parity              (ahb_hprotchk)
);

rl_parity_gen
#(
.DATA_WIDTH (4),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwstrb_parity (
  .din                   (ahb_hwstrb),
  .q_parity              (ahb_hwstrbchk)
);

rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity0 (
  .din                   (ahb_hwdata[7:0]),
  .q_parity              (ahb_hwdatachk[0])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity1 (
  .din                   (ahb_hwdata[15:8]),
  .q_parity              (ahb_hwdatachk[1])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity2 (
  .din                   (ahb_hwdata[23:16]),
  .q_parity              (ahb_hwdatachk[2])
);
rl_parity_gen
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hwdata_parity3 (
  .din                   (ahb_hwdata[31:24]),
  .q_parity              (ahb_hwdatachk[3])
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

assign ahb_hresp_in = {ahb_hresp, ahb_hexokay};
wire datachk_en = (biu_resp_state_r != BIU_RESP_ADDR_PHASE);

rl_parity_chk
#(
.DATA_WIDTH (2),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hresp_parity (
  .din                   (ahb_hresp_in),
  .din_parity            (ahb_hrespchk),
  .enable                (datachk_en),

  .parity_err            (ahb_hresp_pty_err)
);

wire hrdatachk_en = biu_pending_rd_r & datachk_en & ahb_hready;

rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity0 (
  .din                   (ahb_hrdata[7:0]),
  .din_parity            (ahb_hrdatachk[0]),
  .enable                (hrdatachk_en),

  .parity_err            (ahb_hrdata_pty_err[0])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity1 (
  .din                   (ahb_hrdata[15:8]),
  .din_parity            (ahb_hrdatachk[1]),
  .enable                (hrdatachk_en),

  .parity_err            (ahb_hrdata_pty_err[1])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity2 (
  .din                   (ahb_hrdata[23:16]),
  .din_parity            (ahb_hrdatachk[2]),
  .enable                (hrdatachk_en),

  .parity_err            (ahb_hrdata_pty_err[2])
);
rl_parity_chk
#(
.DATA_WIDTH (8),
.PARITY_ODD (`BUS_ECC_PARITY_OPTION)
)
u_ahb_hrdata_parity3 (
  .din                   (ahb_hrdata[31:24]),
  .din_parity            (ahb_hrdatachk[3]),
  .enable                (hrdatachk_en),

  .parity_err            (ahb_hrdata_pty_err[3])
);

assign ahb_fatal_err = ahb_hready_pty_err | ahb_hresp_pty_err | (|ahb_hrdata_pty_err);
// spyglass enable_block RegInputOutput-ML
endmodule // rl_ibp2ahb
// spyglass enable_block Topology_02

