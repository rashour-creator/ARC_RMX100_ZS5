
//----------------------------------------------------------------------------
//
// Copyright 2015-2024 Synopsys, Inc. All rights reserved.
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
// @f:rl_sfty_mnt_reg_agent
//
// Description:
// @p
//   Module handles safety monitor memory map register access.
// @e
//
// ===========================================================================

`include "defines.v"
`include   "rv_safety_defines.v"
`include "const.def"


module rl_sfty_mnt_reg_agent(
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"  
    input                sfty_ibp_mmio_cmd_valid, 
    input  [3:0]         sfty_ibp_mmio_cmd_cache, 
    input                sfty_ibp_mmio_cmd_burst_size,              
    input                sfty_ibp_mmio_cmd_read,                
    input                sfty_ibp_mmio_cmd_aux,                
    output               sfty_ibp_mmio_cmd_accept,              
    input  [7:0]         sfty_ibp_mmio_cmd_addr,                          
    input                sfty_ibp_mmio_cmd_excl,
    input  [5:0]         sfty_ibp_mmio_cmd_atomic,
    input  [2:0]         sfty_ibp_mmio_cmd_data_size,               
    input  [1:0]         sfty_ibp_mmio_cmd_prot,                

    input                sfty_ibp_mmio_wr_valid,    
    input                sfty_ibp_mmio_wr_last,    
    output               sfty_ibp_mmio_wr_accept,   
    input  [3:0]         sfty_ibp_mmio_wr_mask,    
    input  [31:0]        sfty_ibp_mmio_wr_data,    
    
    output               sfty_ibp_mmio_rd_valid,                
    output               sfty_ibp_mmio_rd_err,                
    output               sfty_ibp_mmio_rd_excl_ok,
    output               sfty_ibp_mmio_rd_last,                 
    input                sfty_ibp_mmio_rd_accept,               
    output  [31:0]       sfty_ibp_mmio_rd_data,     
    
    output               sfty_ibp_mmio_wr_done,
    output               sfty_ibp_mmio_wr_excl_okay,
    output               sfty_ibp_mmio_wr_err,
    input                sfty_ibp_mmio_wr_resp_accept,

// IBP e2e protection interface
    input                sfty_ibp_mmio_cmd_valid_pty,
    output               sfty_ibp_mmio_cmd_accept_pty,              
    input                sfty_ibp_mmio_cmd_addr_pty,                        
    input  [3:0]         sfty_ibp_mmio_cmd_ctrl_pty,

    input                sfty_ibp_mmio_wr_valid_pty,    
    output               sfty_ibp_mmio_wr_accept_pty,   
    input                sfty_ibp_mmio_wr_last_pty,    
    
    output               sfty_ibp_mmio_rd_valid_pty,                
    input                sfty_ibp_mmio_rd_accept_pty,               
    output               sfty_ibp_mmio_rd_ctrl_pty,                
    output [3:0]         sfty_ibp_mmio_rd_data_pty,     
    
    output               sfty_ibp_mmio_wr_done_pty,
    output               sfty_ibp_mmio_wr_ctrl_pty,
    input                sfty_ibp_mmio_wr_resp_accept_pty,
    input  logic [1:0]   dr_sfty_e2e_diag_mode,
    output logic [1:0]   dr_sfty_e2e_diag_inj_end,
    output logic [1:0]   dr_sfty_e2e_mask_pty_err,
    output logic [1:0]   dr_e2e_check_error_sticky,
    input                clear_latent_fault,

    input  [`rv_lsc_err_stat_msb:0] lsc_err_stat_aux,
    input  [`rv_lsc_latt_err_stat_msb:0]  lsc_latt_err_stat_aux,
    input                sfty_nsi_r,
    output [1:0]         dr_sfty_mmio_fsm_pe,
    output               sfty_ibp_mmio_tgt_e2e_err,

    input clk,
    input rst
// spyglass enable_block W240
    );


assign sfty_ibp_mmio_rd_excl_ok   = 1'b0;
assign sfty_ibp_mmio_wr_excl_okay = 1'b0;
localparam     S_IDLE    = 5'h1;  //00001 - Idle state             
localparam     S_WR_ACT  = 5'h2;  //00010 - WR Active state
localparam     S_WR_RSP  = 5'h4;  //00100 - WR Mst Response state
localparam     S_RD_EN   = 5'h8;  //01000 - RD Enable state
localparam     S_RD_ACP  = 5'h10; //10000 - RD Mst Accept state


// ----------------------------------------------------------
//  AUX state machine
// ----------------------------------------------------------
logic                                    rd_err_nxt,    rd_err_r;
logic                                    rd_valid_r,    rd_valid_nxt;
logic                              [4:0] sfty_mmio_stat_nxt,    sfty_mmio_stat_r;
logic                                    cmd_accept_r,  cmd_accept_nxt;
logic                              [7:0] cmd_addr_r,    cmd_addr_nxt;
logic                                    aux_ren;
logic                                    aux_wen;
logic                                    wr_err_nxt,    wr_err_r;
logic                                    wr_done_r,     wr_done_nxt;
logic                                    wr_accept_nxt, wr_accept_r; 
logic                             [31:0] aux_rdata_nxt, aux_rdata_r;
logic                                    cmd_err;
logic                                    cmd_err_r;
logic                                    sfty_mmio_fsm_pe_r, sfty_mmio_fsm_pe_nxt;
// IBP write I/F
assign sfty_ibp_mmio_cmd_accept = cmd_accept_r;

assign sfty_ibp_mmio_rd_valid   = rd_valid_r; 
assign sfty_ibp_mmio_rd_err     = rd_err_r && rd_valid_r;
assign sfty_ibp_mmio_rd_last    = rd_valid_r;
assign sfty_ibp_mmio_rd_data    = aux_rdata_r;

assign sfty_ibp_mmio_wr_accept  = wr_accept_r;
assign sfty_ibp_mmio_wr_done    = wr_done_r;
assign sfty_ibp_mmio_wr_err     = wr_err_r;
// Illegal access protocol
assign cmd_err = (sfty_ibp_mmio_cmd_valid & sfty_ibp_mmio_cmd_accept) ?
                 ((|sfty_ibp_mmio_cmd_burst_size) |                  // more than one beat
                  (sfty_ibp_mmio_cmd_data_size > 3'b10))       // support Byte/Halfword/Word
                 : cmd_err_r;

always_comb
begin : sfty_mmio_fsm_PROC
  sfty_mmio_stat_nxt        = sfty_mmio_stat_r;
  sfty_mmio_fsm_pe_nxt  = sfty_mmio_fsm_pe_r;
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
  case (sfty_mmio_stat_r)
    S_IDLE : 
    begin                     
      sfty_mmio_fsm_pe_nxt  = 1'b0;
      if (sfty_ibp_mmio_cmd_valid & ~sfty_ibp_mmio_cmd_read)
      begin 
        cmd_accept_nxt = 1'b0;
        cmd_addr_nxt   = sfty_ibp_mmio_cmd_addr;
        wr_accept_nxt  = 1'b1;
        sfty_mmio_stat_nxt     = S_WR_ACT; 
      end
      else if (sfty_ibp_mmio_cmd_valid & sfty_ibp_mmio_cmd_read)
      begin 
        cmd_accept_nxt = 1'b0;
        cmd_addr_nxt   = sfty_ibp_mmio_cmd_addr;
        sfty_mmio_stat_nxt     = S_RD_EN;
      end
    end

    S_WR_ACT : 
    begin
      sfty_mmio_fsm_pe_nxt  = 1'b0;
      if (sfty_ibp_mmio_wr_valid) 
      begin
      //Just ignore
        wr_err_nxt        = cmd_err;
        aux_wen           = 1'b1;
        wr_accept_nxt     = 1'b0;
        wr_done_nxt       = 1'b1;
        sfty_mmio_stat_nxt        = S_WR_RSP;
      end
    end

    S_WR_RSP : 
    begin
      sfty_mmio_fsm_pe_nxt  = 1'b0;
      cmd_accept_nxt = 1'b1;
      wr_done_nxt    = 1'b0;
      wr_err_nxt     = 1'b0; 
      sfty_mmio_stat_nxt     = S_IDLE; 
    end

    S_RD_EN : 
    begin
      sfty_mmio_fsm_pe_nxt  = 1'b0;
      aux_ren         = 1'b1;
      rd_valid_nxt    = 1'b1;
      rd_err_nxt      = cmd_err;
      sfty_mmio_stat_nxt      = S_RD_ACP; 
    end

    S_RD_ACP : 
    begin
      sfty_mmio_fsm_pe_nxt  = 1'b0;
      aux_ren          = 1'b0;
      rd_valid_nxt     = 1'b1;
      if (sfty_ibp_mmio_rd_accept) 
      begin
        cmd_accept_nxt = 1'b1;
        aux_ren        = 1'b0; 
        rd_valid_nxt   = 1'b0;
        rd_err_nxt     = 1'b0;
        sfty_mmio_stat_nxt     = S_IDLE; 
      end
    end

    default :
    begin
      sfty_mmio_stat_nxt = sfty_mmio_stat_r;
      //One-Hot FSM Default Error state
      sfty_mmio_fsm_pe_nxt  = 1'b1;
    end
  endcase
end


// ----------------------------------------------------------
//  AUX PROXY REG READ process
// ----------------------------------------------------------
always_comb
begin : pxy_rd_PROC
  aux_rdata_nxt     = aux_rdata_r;

  // Read address decode
  if (aux_ren)
  begin
    case (cmd_addr_r[3:2])
      2'h0      : aux_rdata_nxt = {18'b0, lsc_err_stat_aux};
      2'h1      : aux_rdata_nxt = {27'b0, lsc_latt_err_stat_aux};
      2'h2      : aux_rdata_nxt = {29'b0, sfty_nsi_r, 2'b0};
      default    : aux_rdata_nxt = 'h0;
    endcase
  end
end

always_ff @(posedge clk or posedge rst)
begin: clocked_ff_PROC
  if (rst)
  begin
    sfty_mmio_stat_r    <= S_IDLE;

    cmd_accept_r    <= 1'b1;
    cmd_addr_r      <= 8'b0;
    cmd_err_r       <= 1'b0;

    wr_err_r        <= 1'b0;
    wr_done_r       <= 1'b0;
    wr_accept_r     <= 1'b0;

    rd_valid_r      <= 1'b0;
    rd_err_r        <= 1'b0;

    aux_rdata_r     <= 32'd0;
    sfty_mmio_fsm_pe_r  <= 1'b0;

  end
  else
  begin
    sfty_mmio_stat_r    <= sfty_mmio_stat_nxt;

    cmd_accept_r    <= cmd_accept_nxt;
    cmd_addr_r      <= cmd_addr_nxt;
    cmd_err_r       <= cmd_err;

    wr_err_r        <= wr_err_nxt;
    wr_done_r       <= wr_done_nxt;
    wr_accept_r     <= wr_accept_nxt;

    rd_valid_r      <= rd_valid_nxt;
    rd_err_r        <= rd_err_nxt;
    aux_rdata_r     <= aux_rdata_nxt;
    sfty_mmio_fsm_pe_r  <= sfty_mmio_fsm_pe_nxt;
  end
end

assign dr_sfty_mmio_fsm_pe = sfty_mmio_fsm_pe_r ? 2'b10 : 2'b01;


rl_sfty_ibp_tgt_e2e_wrap #(
    .DW        (32),// Data width
    .BSW       (1), // Burst size width
    .AW        (8), // Address size width(Only LSB 8 bits used)
    .SPC_PRE   (0)  // space signal 0: not present 1: present
    )
u_rl_sfty_ibp_mmio_tgt_e2e(
// IBP bus target interface
    .cmd_valid      (sfty_ibp_mmio_cmd_valid      ),
    .cmd_id         (1'b0                         ), // optional
    .cmd_cache      (sfty_ibp_mmio_cmd_cache      ), 
    .cmd_burst_size (sfty_ibp_mmio_cmd_burst_size ),              
    .cmd_read       (sfty_ibp_mmio_cmd_read       ),             
    .cmd_wrap       (1'b0                         ),              
    .cmd_accept     (sfty_ibp_mmio_cmd_accept     ),              
    .cmd_addr       (sfty_ibp_mmio_cmd_addr       ),              
    .cmd_excl       (sfty_ibp_mmio_cmd_excl       ), // optional
    .cmd_space      (3'b0                         ), // optional
    .cmd_atomic     (sfty_ibp_mmio_cmd_atomic),
    .cmd_data_size  (sfty_ibp_mmio_cmd_data_size  ),              
    .cmd_prot       (sfty_ibp_mmio_cmd_prot       ),                

    .wr_valid       (sfty_ibp_mmio_wr_valid ),    
    .wr_last        (sfty_ibp_mmio_wr_last  ),    
    .wr_accept      (sfty_ibp_mmio_wr_accept),   
    .wr_mask        (sfty_ibp_mmio_wr_mask  ),    
    .wr_data        (sfty_ibp_mmio_wr_data  ),    
    
    .rd_valid       (sfty_ibp_mmio_rd_valid  ),                
    .rd_id          (1'b0                    ),  // optional     
    .rd_err         (sfty_ibp_mmio_rd_err    ),                
    .rd_excl_ok     (sfty_ibp_mmio_rd_excl_ok),  // optional
    .rd_last        (sfty_ibp_mmio_rd_last   ),                 
    .rd_accept      (sfty_ibp_mmio_rd_accept ),
    .rd_resp        (4'b0                    ),  // optional
    .rd_data        (sfty_ibp_mmio_rd_data   ),     
    
    .wr_done        (sfty_ibp_mmio_wr_done       ),
    .wr_id          (1'b0                         ),   // optional 
    .wr_excl_okay   (sfty_ibp_mmio_wr_excl_okay  ),
    .wr_err         (sfty_ibp_mmio_wr_err        ),
    .wr_resp_accept (sfty_ibp_mmio_wr_resp_accept),
// IBP e2e protection interface
    .cmd_valid_pty  (sfty_ibp_mmio_cmd_valid_pty ),
    .cmd_accept_pty (sfty_ibp_mmio_cmd_accept_pty),              
    .cmd_id_pty     (1'b0                        ),
    .cmd_addr_pty   (sfty_ibp_mmio_cmd_addr_pty  ),             
    .cmd_ctrl_pty   (sfty_ibp_mmio_cmd_ctrl_pty  ),
    
    .wr_valid_pty   (sfty_ibp_mmio_wr_valid_pty  ),    
    .wr_accept_pty  (sfty_ibp_mmio_wr_accept_pty ),   
    .wr_last_pty    (sfty_ibp_mmio_wr_last_pty   ),    
    .wr_mask_pty    (1'b0                        ),    
    .wr_data_pty    (4'b0                        ),
    
    .rd_valid_pty   (sfty_ibp_mmio_rd_valid_pty  ),                
    .rd_accept_pty  (sfty_ibp_mmio_rd_accept_pty ),               
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ : ID is not used in this configuration 
    .rd_id_pty      (                            ),              
// spyglass enable_block UnloadedOutTerm-ML
    .rd_ctrl_pty    (sfty_ibp_mmio_rd_ctrl_pty   ),              
    .rd_data_pty    (sfty_ibp_mmio_rd_data_pty   ),
    
    .wr_done_pty    (sfty_ibp_mmio_wr_done_pty   ),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ : ID is not used in this configuration 
    .wr_id_pty      (                            ),               
// spyglass enable_block UnloadedOutTerm-ML
    .wr_ctrl_pty    (sfty_ibp_mmio_wr_ctrl_pty   ),
    .wr_resp_accept_pty(sfty_ibp_mmio_wr_resp_accept_pty),

// msic
    .tgt_e2e_err    (sfty_ibp_mmio_tgt_e2e_err    ),
    .dr_sfty_e2e_diag_mode        (dr_sfty_e2e_diag_mode),
    .dr_sfty_e2e_diag_inj_end     (dr_sfty_e2e_diag_inj_end),
    .dr_sfty_e2e_mask_pty_err     (dr_sfty_e2e_mask_pty_err),
    .dr_e2e_check_error_sticky    (dr_e2e_check_error_sticky),
    .clear_latent_fault           (clear_latent_fault),
    .clk            (clk                          ),
    .rst            (rst                          )
);
endmodule
