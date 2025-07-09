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

// Set simulation timescale
//
`include "const.def"


module arcv_timer (
  ////////// Internal signals /////////////////////////////////////////
  //
  input                          tm_clk_enable_sync,     // Synchronized bit0 from ref_clk domain
  output reg [63:0]              mtime_r,
  ////////// IBP interface signals ////////////////////////////////////
  //
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"
  input                          ibp_cmd_valid, 
  input  [3:0]                   ibp_cmd_cache, 
  input                          ibp_cmd_burst_size,                 
  input                          ibp_cmd_read,                
  input                          ibp_cmd_aux,                
  output                         ibp_cmd_accept,              
  input  [`ADDR_RANGE]           ibp_cmd_addr,                             
  input                          ibp_cmd_excl,
  input  [5:0]                   ibp_cmd_atomic,
  input  [2:0]                   ibp_cmd_data_size,                
  input  [1:0]                   ibp_cmd_prot,                

  input                          ibp_wr_valid,    
  input                          ibp_wr_last,    
  output                         ibp_wr_accept,   
  input  [3:0]                   ibp_wr_mask,    
  input  [`DATA_RANGE]           ibp_wr_data,    
  
  output                         ibp_rd_valid,                
  output                         ibp_rd_err,                
  output                         ibp_rd_excl_ok,
  output                         ibp_rd_last,                 
  input                          ibp_rd_accept,               
  output [`DATA_RANGE]           ibp_rd_data,     
  
  output                         ibp_wr_done,
  output                         ibp_wr_excl_okay,
  output                         ibp_wr_err,
  input                          ibp_wr_resp_accept,
// spyglass enable_block W240  
  ////////// Interrupts ////////////////////////////////////
  //
  output                         mtip_0,
  output                         msip_0,
  output reg                     time_ovf,
  output reg                     time_ovf_flag,
  ////////// General input signals /////////////////////////////////////////
  //
  input                          clk,                   // core clock signal
  input                          rst_a                  // reset signal
  
);

localparam     S_IDLE    = 5'h1;  //00001 - Idle state             
localparam     S_WR_ACT  = 5'h2;  //00010 - WR Active state
localparam     S_WR_RSP  = 5'h4;  //00100 - WR Mst Response state
localparam     S_RD_EN   = 5'h8;  //01000 - RD Enable state
localparam     S_RD_ACP  = 5'h10; //10000 - RD Mst Accept state

// Signal/Register Declerations
reg rd_err_nxt;    
reg rd_err_r;
reg rd_valid_r;    
reg rd_valid_nxt;
reg [4:0] mmio_stat_nxt;    
reg [4:0] mmio_stat_r;
reg cmd_accept_r;  
reg cmd_accept_nxt;
reg [`ADDR_SIZE-1:0] cmd_addr_r;    
reg [`ADDR_SIZE-1:0] cmd_addr_nxt;
reg aux_ren;
reg aux_wen;
reg wr_err_nxt;    
reg wr_err_r;
reg wr_done_r;     
reg wr_done_nxt;
reg wr_accept_nxt; 
reg wr_accept_r; 
reg [`DATA_RANGE] aux_rdata_nxt; 
reg [`DATA_RANGE] aux_rdata_r;
wire cmd_err;
reg cmd_err_r;

reg msip_r;
reg msip_nxt;

reg [63:0] mtime_cmp_r;
reg [63:0] mtime_cmp_nxt;
reg [63:0] mtime_nxt;

wire       mtip_set;
wire       mtip_clr;
reg        mtip_cg;

reg        mtip_nxt;
reg        mtip_r;

reg msip_cg;
reg mtime_cmp_cg;
reg mtime_cg;

reg tm_bit0_r;
wire tm_enable_neg;
wire tm_enable_edge;


// IBP write I/F
assign ibp_cmd_accept = cmd_accept_r;

assign ibp_rd_valid   = rd_valid_r; 
assign ibp_rd_err     = rd_err_r && rd_valid_r;
assign ibp_rd_last    = rd_valid_r;
assign ibp_rd_data    = aux_rdata_r;

assign ibp_wr_accept  = wr_accept_r;
assign ibp_wr_done    = wr_done_r;
assign ibp_wr_err     = wr_err_r;

assign ibp_rd_excl_ok = 1'b0;
assign ibp_wr_excl_okay = 1'b0;
// Illegal access protocol
assign cmd_err = (ibp_cmd_valid & ibp_cmd_accept) ?
                 ((|ibp_cmd_burst_size) |                  // more than one beat
                  (ibp_cmd_data_size != 3'b10))             // support only Word
                 : cmd_err_r;

assign tm_enable_neg = ~tm_clk_enable_sync & tm_bit0_r;
assign tm_enable_edge = tm_clk_enable_sync ^ tm_bit0_r;
assign msip_0  = msip_r;
assign mtip_set = (| mtime_cmp_r) && (mtime_r >= mtime_cmp_r);
assign mtip_clr = mtip_cg && (mtime_nxt < mtime_cmp_nxt);

assign mtip_0  = mtip_r;

always @*
begin : mtip_nxt_PROC
  mtip_nxt = mtip_r;
  if (mtip_clr)
	mtip_nxt = 1'b0;
  else if (mtip_set)
	mtip_nxt = 1'b1;
end

// FSM
always @*
begin : mmio_fsm_PROC
  mmio_stat_nxt     = mmio_stat_r;
  cmd_accept_nxt    = cmd_accept_r;
  cmd_addr_nxt      = cmd_addr_r;

  aux_wen           = 1'b0;
  wr_done_nxt       = wr_done_r;
  wr_err_nxt        = wr_err_r; 
  wr_accept_nxt     = wr_accept_r;
  aux_ren           = 1'b0;
  rd_valid_nxt      = 1'b0;
  rd_err_nxt        = 1'b0;
  //                  
  case (mmio_stat_r)
    S_IDLE : 
    begin                     
      if (ibp_cmd_valid & ~ibp_cmd_read)
      begin 
        cmd_accept_nxt = 1'b0;
        cmd_addr_nxt   = ibp_cmd_addr;
        wr_accept_nxt  = 1'b1;
        mmio_stat_nxt  = S_WR_ACT; 
      end
      else if (ibp_cmd_valid & ibp_cmd_read)
      begin 
        cmd_accept_nxt = 1'b0;
        cmd_addr_nxt   = ibp_cmd_addr;
        mmio_stat_nxt  = S_RD_EN;
      end
    end

    S_WR_ACT : 
    begin
      if (ibp_wr_valid) 
      begin
        wr_err_nxt        = cmd_err;
        aux_wen           = 1'b1;
        wr_accept_nxt     = 1'b0;
        wr_done_nxt       = 1'b1;
        mmio_stat_nxt     = S_WR_RSP;
      end
    end

    S_WR_RSP : 
    begin
      cmd_accept_nxt = 1'b1;
      wr_done_nxt    = 1'b0;
      wr_err_nxt     = 1'b0; 
      mmio_stat_nxt  = S_IDLE; 
    end

    S_RD_EN : 
    begin
      aux_ren         = 1'b1;
      rd_valid_nxt    = 1'b1;
      rd_err_nxt      = cmd_err;
      mmio_stat_nxt   = S_RD_ACP; 
    end

    S_RD_ACP : 
    begin
      aux_ren          = 1'b1;    // keep rd en till mst rd accept
      rd_valid_nxt     = 1'b1;
      if (ibp_rd_accept) 
      begin
        cmd_accept_nxt = 1'b1;
        aux_ren        = 1'b0; 
        rd_valid_nxt   = 1'b0;
        rd_err_nxt     = 1'b0;
        mmio_stat_nxt     = S_IDLE; 
      end
    end

    default :
    begin
      mmio_stat_nxt = mmio_stat_r;
    end
  endcase
end

// ----------------------------------------------------------
//  CSR READ process
// ----------------------------------------------------------
always @*
begin : csr_rd_PROC
  aux_rdata_nxt     = aux_rdata_r;
  // Read address decode
  if (aux_ren)
  begin
    case (cmd_addr_r[15:0])
      `RTIA_MSWI_BASE_ADDR:      aux_rdata_nxt = {31'b0, msip_r};
      `RTIA_MTIMECMP_BASE_ADDR:  aux_rdata_nxt = mtime_cmp_r[31:0];
      `RTIA_MTIMECMPH_BASE_ADDR: aux_rdata_nxt = mtime_cmp_r[63:32];
      `RTIA_MTIME_BASE_ADDR:     aux_rdata_nxt = mtime_r[31:0];
      `RTIA_MTIMEH_BASE_ADDR:    aux_rdata_nxt = mtime_r[63:32];  
      default :                  aux_rdata_nxt = `DATA_SIZE'h0;
    endcase
  end
end

// ----------------------------------------------------------
//  CSR WRITE process
// ----------------------------------------------------------
always @*
begin : csr_wr_PROC
  msip_cg       = 1'b0;
  msip_nxt      = msip_r;
  
  mtime_cmp_cg  = 1'b0;
  mtime_cmp_nxt = mtime_cmp_r;

  mtime_cg      = tm_enable_edge;

  mtip_cg       = 1'b0;
  {time_ovf_flag, mtime_nxt}     = {((mtime_r >> 1) + tm_enable_neg), tm_clk_enable_sync}; 

  // Write address decode
  if (aux_wen)
  begin
    case (cmd_addr_r[15:0])
      `RTIA_MSWI_BASE_ADDR:
       begin
         msip_cg     = 1'b1;
         msip_nxt    = ibp_wr_data[0];
       end

      `RTIA_MTIMECMP_BASE_ADDR:
       begin
         mtime_cmp_cg          = 1'b1;
		 mtip_cg               = 1'b1;
         mtime_cmp_nxt[31:0]   = ibp_wr_data;
       end
      
      `RTIA_MTIMECMPH_BASE_ADDR:
       begin
         mtime_cmp_cg          = 1'b1;
		 mtip_cg               = 1'b1;
         mtime_cmp_nxt[63:32]  = ibp_wr_data;
       end
      
      `RTIA_MTIME_BASE_ADDR:
       begin
         mtime_cg           = 1'b1;
		 mtip_cg            = 1'b1;
         mtime_nxt[31:0]    = ibp_wr_data;
       end
     
      `RTIA_MTIMEH_BASE_ADDR:
       begin
	     mtime_cg           = 1'b1;
		 mtip_cg            = 1'b1;
	     mtime_nxt[63:32]   = ibp_wr_data;     
       end
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue. Added 20240201 for lint.
      default: ; // return a bus error?
// spyglass enable_block W193
    endcase
  end
end

//Synchronizaiton process
always @(posedge clk or posedge rst_a)
begin: fsm_reg_PROC
  if (rst_a)
  begin
    mmio_stat_r    <= S_IDLE;

    cmd_accept_r    <= 1'b1;
    cmd_addr_r      <= `ADDR_SIZE'h0;
    cmd_err_r       <= 1'b0;

    wr_err_r        <= 1'b0;
    wr_done_r       <= 1'b0;
    wr_accept_r     <= 1'b0;

    rd_valid_r      <= 1'b0;
    rd_err_r        <= 1'b0;

    aux_rdata_r     <= `DATA_SIZE'h0;

  end
  else
  begin
    mmio_stat_r     <= mmio_stat_nxt;

    cmd_accept_r    <= cmd_accept_nxt;
    cmd_addr_r      <= cmd_addr_nxt;
    cmd_err_r       <= cmd_err;

    wr_err_r        <= wr_err_nxt;
    wr_done_r       <= wr_done_nxt;
    wr_accept_r     <= wr_accept_nxt;

    rd_valid_r      <= rd_valid_nxt;
    rd_err_r        <= rd_err_nxt;
    aux_rdata_r     <= aux_rdata_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin: msip_r_PROC
  if (rst_a)
  begin
    msip_r          <= 1'b0;
  end
  else if (msip_cg)
  begin
    msip_r          <= msip_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin: mtip_r_PROC
  if (rst_a)
  begin
    mtip_r          <= 1'b0;
  end
  else
  begin
    mtip_r          <= mtip_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin: mtime_cmp_r_PROC
  if (rst_a)
  begin
    mtime_cmp_r          <= 64'h0;
  end
  else if (mtime_cmp_cg)
  begin
    mtime_cmp_r          <= mtime_cmp_nxt;
  end
end

// spyglass disable_block INTEGRITY_RESET_GLITCH
// SMD: Clear pin of sequential element is driven by combinational logic
// SJ:  Intended to merge all reset sources
always @(posedge clk or posedge rst_a)
begin: mtime_r_PROC
  if (rst_a)
  begin
    mtime_r          <= 64'h0;
  end
  else if (mtime_cg)
  begin
    mtime_r          <= mtime_nxt;
  end
end
// spyglass enable_block INTEGRITY_RESET_GLITCH

always @(posedge clk or posedge rst_a)
begin: mtime_ovf_PROC
  if (rst_a)
  begin
    time_ovf          <= 1'b0;
  end
  else if (tm_enable_edge)
  begin
    time_ovf          <= time_ovf_flag;
  end
end

always @(posedge clk or posedge rst_a)
begin: tm_bit0_r_PROC
  if (rst_a)
  begin
    tm_bit0_r          <= 1'b0;
  end
  else
  begin
    tm_bit0_r          <= tm_clk_enable_sync;
  end
end



endmodule // arcv_timer
