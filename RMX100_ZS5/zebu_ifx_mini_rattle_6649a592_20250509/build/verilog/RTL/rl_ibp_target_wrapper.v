// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright 2015-2023 Synopsys, Inc. All rights reserved.
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
//
// ===========================================================================
//
// @f:rl_ibp_target_wrapper
//
// Description:
// @p
//   This is a wrapper module for the ibp target.
// @e
//
// ===========================================================================
//
// Configuration-dependent macro definitions 
//
`include "defines.v"

module rl_ibp_target_wrapper (
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"  
    input                     ibp_mmio_cmd_valid, 
    input  [3:0]              ibp_mmio_cmd_cache, 
    input                     ibp_mmio_cmd_burst_size,              
    input                     ibp_mmio_cmd_read,                
    input                     ibp_mmio_cmd_aux,                
    output                    ibp_mmio_cmd_accept,              
    input  [`ADDR_RANGE]      ibp_mmio_cmd_addr,                          
    input                     ibp_mmio_cmd_excl,
    input  [5:0]              ibp_mmio_cmd_atomic,
    input  [2:0]              ibp_mmio_cmd_data_size,               
    input  [1:0]              ibp_mmio_cmd_prot,                

    input                     ibp_mmio_wr_valid,    
    input                     ibp_mmio_wr_last,    
    output                    ibp_mmio_wr_accept,   
    input  [3:0]              ibp_mmio_wr_mask,    
    input  [31:0]             ibp_mmio_wr_data,    
    
    output                    ibp_mmio_rd_valid,                
    output                    ibp_mmio_rd_err,                
    output                    ibp_mmio_rd_excl_ok,
    output                    ibp_mmio_rd_last,                 
    input                     ibp_mmio_rd_accept,               
    output  [31:0]            ibp_mmio_rd_data,     
    
    output                    ibp_mmio_wr_done,
    output                    ibp_mmio_wr_excl_okay,
    output                    ibp_mmio_wr_err,
    input                     ibp_mmio_wr_resp_accept,

    input   [31:0]            aux_rdata_r,
    output  reg               aux_ren,
    output  reg [`ADDR_SIZE-1:0]  cmd_addr_r,
    output  reg               wr_data_zero,
    output  reg               aux_wen,
 

    input                clk,
    input                rst_a
// spyglass enable_block W240
    );


assign ibp_mmio_rd_excl_ok   = 1'b0;
assign ibp_mmio_wr_excl_okay = 1'b0;
localparam     S_IDLE    = 5'h1;  //00001 - Idle state             
localparam     S_WR_ACT  = 5'h2;  //00010 - WR Active state
localparam     S_WR_RSP  = 5'h4;  //00100 - WR Mst Response state
localparam     S_RD_EN   = 5'h8;  //01000 - RD Enable state
localparam     S_RD_ACP  = 5'h10; //10000 - RD Mst Accept state


// ----------------------------------------------------------
//  AUX state machine
// ----------------------------------------------------------
reg                                    rd_err_nxt,    rd_err_r;
reg                                    rd_valid_r,    rd_valid_nxt;
reg                              [4:0] mmio_stat_nxt,    mmio_stat_r;
reg                                    cmd_accept_r,  cmd_accept_nxt;
reg                   [`ADDR_SIZE-1:0] cmd_addr_nxt;
reg                                    wr_err_nxt,    wr_err_r;
reg                                    wr_done_r,     wr_done_nxt;
reg                                    wr_accept_nxt, wr_accept_r; 
wire                                   cmd_err;
reg                                    cmd_err_r;
// IBP write I/F
assign ibp_mmio_cmd_accept = cmd_accept_r;

assign ibp_mmio_rd_valid   = rd_valid_r; 
assign ibp_mmio_rd_err     = rd_err_r && rd_valid_r;
assign ibp_mmio_rd_last    = rd_valid_r;
assign ibp_mmio_rd_data    = aux_rdata_r;

assign ibp_mmio_wr_accept  = wr_accept_r;
assign ibp_mmio_wr_done    = wr_done_r;
assign ibp_mmio_wr_err     = wr_err_r;
// Illegal access protocol
assign cmd_err = (ibp_mmio_cmd_valid & ibp_mmio_cmd_accept) ?
                 ((|ibp_mmio_cmd_burst_size) |                  // more than one beat
                  (ibp_mmio_cmd_data_size > 3'b10))       // support Byte/Halfword/Word
                 : cmd_err_r;

always @*
begin : mmio_fsm_PROC
  mmio_stat_nxt        = mmio_stat_r;
  cmd_accept_nxt    = cmd_accept_r;
  cmd_addr_nxt      = cmd_addr_r;

  aux_wen           = 1'b0;
  wr_data_zero      = 1'b0;
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
      if (ibp_mmio_cmd_valid & ~ibp_mmio_cmd_read)
      begin 
        cmd_accept_nxt = 1'b0;
        cmd_addr_nxt   = ibp_mmio_cmd_addr;
        wr_accept_nxt  = 1'b1;
        mmio_stat_nxt     = S_WR_ACT; 
      end
      else if (ibp_mmio_cmd_valid & ibp_mmio_cmd_read)
      begin 
        cmd_accept_nxt = 1'b0;
        cmd_addr_nxt   = ibp_mmio_cmd_addr;
        mmio_stat_nxt     = S_RD_EN;
      end
    end

    S_WR_ACT : 
    begin
      if (ibp_mmio_wr_valid) 
      begin
      //Just ignore
        wr_err_nxt        = cmd_err;
        aux_wen           = 1'b1;
        wr_accept_nxt     = 1'b0;
        wr_done_nxt       = 1'b1;
        wr_data_zero      = (~(|ibp_mmio_wr_data)) & (&ibp_mmio_wr_mask);
        mmio_stat_nxt        = S_WR_RSP;
      end
    end

    S_WR_RSP : 
    begin
      cmd_accept_nxt = 1'b1;
      wr_done_nxt    = 1'b0;
      wr_err_nxt     = 1'b0; 
      mmio_stat_nxt     = S_IDLE; 
    end

    S_RD_EN : 
    begin
      aux_ren         = 1'b1;
      rd_valid_nxt    = 1'b1;
      rd_err_nxt      = cmd_err;
      mmio_stat_nxt      = S_RD_ACP; 
    end

    S_RD_ACP : 
    begin
      aux_ren          = 1'b1;    // keep rd en till mst rd accept
      rd_valid_nxt     = 1'b1;
      if (ibp_mmio_rd_accept) 
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


always @(posedge clk or posedge rst_a)
begin: clocked_ff_PROC
  if (rst_a)
  begin
    mmio_stat_r    <= S_IDLE;

    cmd_accept_r    <= 1'b1;
    cmd_addr_r      <= `ADDR_SIZE'b0;
    cmd_err_r       <= 1'b0;

    wr_err_r        <= 1'b0;
    wr_done_r       <= 1'b0;
    wr_accept_r     <= 1'b0;

    rd_valid_r      <= 1'b0;
    rd_err_r        <= 1'b0;

  end
  else
  begin
    mmio_stat_r    <= mmio_stat_nxt;

    cmd_accept_r    <= cmd_accept_nxt;
    cmd_addr_r      <= cmd_addr_nxt;
    cmd_err_r       <= cmd_err;

    wr_err_r        <= wr_err_nxt;
    wr_done_r       <= wr_done_nxt;
    wr_accept_r     <= wr_accept_nxt;

    rd_valid_r      <= rd_valid_nxt;
    rd_err_r        <= rd_err_nxt;
  end
end

endmodule

