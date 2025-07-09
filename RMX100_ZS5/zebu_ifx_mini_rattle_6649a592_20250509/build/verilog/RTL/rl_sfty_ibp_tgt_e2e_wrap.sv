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
// @f:sfty_ibp_tgt_e2e_wrap
//
// Description:
// @p
//   ibp target port e2e wrapper file.
// @e
//
// ===========================================================================
`include "rv_safety_defines.v"













`define def_dr_illegal_chk(name) \
  (~(^name))

`define def_dr_err_chk(name) \
  ((name != 2'b01)? 1'b1: 1'b0)

`define def_dr_en_chk(name) \
  ((name == 2'b10)? 1'b1: 1'b0)

`define def_smi_inj(id) \
  (((dr_sfty_smi_diag_mode == 2'b10) && sfty_smi_valid_mask[id]) ? sfty_smi_error_mask[id] : 1'b0)














`include "const.def"


module rl_sfty_ibp_tgt_e2e_wrap #(
    parameter  PTY = 1,// 0: even, 1: odd
    parameter  SECDED = 0,// 0: DED, 1: SECDED
    parameter  ECC_GNT = 0, // ECC ganulairty type: 0: 32b, 1: 64b 
    parameter  DW = 128,// Data width
    parameter  AW = 32, // Address width
    parameter  BSW = 4,// Burst size width
    parameter  IDW = 1, // ID witdh
    parameter  ID_PRE = 0, // ID signal 0: not present 1: present
    parameter  EXCL_PRE = 1, // exclusive signals 0: not present 1: present
    parameter  SPC_PRE = 1, //space signal 0: not present 1: present
    parameter  RESP_PRE = 0, //rd_resp signal 0: not present 1: present
    parameter  RD_ONLY = 1, //RD only 1: Read Only 0: Read Write
    localparam MW = DW/8 + ((DW%8>0) ? 1 : 0),// Write Mask width
    localparam CW = ((ECC_GNT)? ((SECDED)? 8: 7) : ((SECDED)? 7: 6)), // ecc check bit size per granularity unit
    localparam EN = ((ECC_GNT)? (DW/64) : (DW/32)), // number of ecc for one data
    localparam EW = DW/8,                          // data parity check bit size
    localparam APW  = AW/8 + ((AW%8>0) ? 1 : 0), // Address parity width
    localparam IDPW = IDW/8 + ((IDW%8>0) ? 1 : 0), // ID parity width,
    localparam MPW  = MW/8 + ((MW%8>0) ? 1 : 0) // Write Mask parity width
    )
(
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"  
// IBP bus target interface
    input  logic                cmd_valid,
    input  logic  [IDW-1:0]     cmd_id,       // optional
    input  logic  [3:0]         cmd_cache, 
    input  logic  [BSW-1:0]     cmd_burst_size,              
    input  logic                cmd_read,                
    input  logic                cmd_wrap,                
    input  logic                cmd_accept,              
    input  logic  [AW-1:0]      cmd_addr,                          
    input  logic                cmd_excl,      // optional
    input  logic  [2:0]         cmd_space,     // optional
    input  logic  [5:0]         cmd_atomic,
    input  logic  [2:0]         cmd_data_size,              
    input  logic  [1:0]         cmd_prot,                

    input  logic                wr_valid,    
    input  logic                wr_last,    
    input  logic                wr_accept,   
    input  logic  [MW-1:0]      wr_mask,    
    input  logic  [DW-1:0]      wr_data,    
    
    input  logic                rd_valid,                
    input  logic  [IDW-1:0]     rd_id,       // optional         
    input  logic                rd_err,                
    input  logic                rd_excl_ok,  // optional
    input  logic                rd_last,                 
    input  logic                rd_accept,
    input   logic [3:0]         rd_resp,     // optional
    input  logic  [DW-1:0]      rd_data,     
    
    input  logic                wr_done,
    input  logic  [IDW-1:0]     wr_id,       // optional         
    input  logic                wr_excl_okay,
    input  logic                wr_err,
    input  logic                wr_resp_accept,
// IBP e2e protection interface
    input  logic                cmd_valid_pty,
    output logic                cmd_accept_pty,              
    input  logic  [IDPW-1:0]    cmd_id_pty,
    input  logic  [APW-1:0]     cmd_addr_pty,                          
    input  logic  [3:0]         cmd_ctrl_pty,

    input  logic                wr_valid_pty,    
    output logic                wr_accept_pty,   
    input  logic                wr_last_pty,    
    input  logic  [MPW-1:0]     wr_mask_pty,    
    input  logic  [EW-1:0]      wr_data_pty,
    
    output logic                rd_valid_pty,                
    input  logic                rd_accept_pty,               
    output logic  [IDPW-1:0]    rd_id_pty,                
    output logic                rd_ctrl_pty,                
    output logic  [EW-1:0]      rd_data_pty,     
    
    output logic                wr_done_pty,
    output logic  [IDPW-1:0]    wr_id_pty,                
    output logic                wr_ctrl_pty,
    input  logic                wr_resp_accept_pty,
    input  logic  [1:0]         dr_sfty_e2e_diag_mode,
    output logic [1:0]          dr_sfty_e2e_diag_inj_end,
    output logic [1:0]          dr_sfty_e2e_mask_pty_err,
    output logic [1:0]          dr_e2e_check_error_sticky,
    input                       clear_latent_fault,
// spyglass enable_block W240

// msic
    output logic                tgt_e2e_err,
    input  logic                clk,
    input  logic                rst
);

localparam E2E_WIDTH = 25;
logic [E2E_WIDTH-1:0]    error_mask_e2e;
logic [E2E_WIDTH-1:0]    valid_mask_e2e;
//Part3: Safety Monitor Diagnostic Error Injection Control 
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded but driven output terminal of an instance detected
// SJ: the behaviour is intentional, only msb has loading 
ls_sfty_mnt_diag_ctrl  #(
       .SMI_WIDTH        (E2E_WIDTH)
) u_rl_sfty_e2e_diag_ctrl(
  .dr_sfty_smi_diag_mode        (dr_sfty_e2e_diag_mode),     
  .sfty_smi_error_mask          (error_mask_e2e),  
  .sfty_smi_valid_mask          (valid_mask_e2e),  
  .dr_sfty_smi_diag_inj_end     (dr_sfty_e2e_diag_inj_end),
  .dr_sfty_smi_mask_pty_err     (dr_sfty_e2e_mask_pty_err),
  .clk                          (clk),
  .rst                          (rst)
); 
// spyglass enable_block UnloadedOutTerm-ML

// Commnad Channel:
logic  cmd_valid_pty_err;
logic  cmd_id_pty_err;
logic [APW-1:0] cmd_addr_pty_err;
logic cmd_ctrl0_pty_err;
logic cmd_ctrl1_pty_err;
logic cmd_ctrl2_pty_err;
logic cmd_ctrl3_pty_err;
logic [APW+6-1:0] cmd_e2e_err_in;
logic cmd_e2e_err;


    if (PTY)
    begin: cmd_valid_odd_pty_dec
      odd_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_cmd_validpty_dec_wrap ( 
      .data_in    (cmd_valid), 
      .parity_in  (cmd_valid_pty), 
      .diag_inj   (error_mask_e2e[0]), 
      .parity_err (cmd_valid_pty_err) 
      ); 
    end //cmd_valid_odd_pty_dec
    else
    begin: cmd_valid_even_pty_dec
      even_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_cmd_validpty_dec_wrap ( 
      .data_in    (cmd_valid), 
      .parity_in  (cmd_valid_pty), 
      .diag_inj   (error_mask_e2e[0]), 
      .parity_err (cmd_valid_pty_err) 
      );
    end //cmd_valid_even_pty_dec

    if (PTY)
    begin: cmd_accept_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_cmd_accept_pty_enc ( 
      .data_in    (cmd_accept), 
      .parity_out (cmd_accept_pty)
      ); 
    end //cmd_accept_odd_pty_enc
    else
    begin: cmd_accept_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_cmd_accept_pty_enc ( 
      .data_in    (cmd_accept), 
      .parity_out (cmd_accept_pty)
      );
    end //cmd_accept_even_pty_enc

if(ID_PRE)
begin: cmd_id_pre
    if (PTY)
    begin: cmd_id_odd_pty_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (IDW), 
      .SECOND_CHK  (1)
      ) u_cmd_idpty_qual_dec_wrap ( 
      .data_in    (cmd_id), 
      .parity_in  (cmd_id_pty), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[1]), 
      .parity_err (cmd_id_pty_err) 
      ); 
    end //cmd_id_odd_pty_qual_dec
    else
    begin: cmd_id_even_pty_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (IDW), 
      .SECOND_CHK  (1)
      ) u_cmd_idpty_qual_dec_wrap ( 
      .data_in    (cmd_id), 
      .parity_in  (cmd_id_pty), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[1]), 
      .parity_err (cmd_id_pty_err) 
      );
    end //cmd_id_even_pty_qual_dec
end
else
begin: cmd_id_n_pre
  assign cmd_id_pty_err = 1'b0 
                        ^ error_mask_e2e[1]
                        ;
end

for (genvar i = 0; i < AW/8 + ((AW%8>0) ? 1 : 0); i++)
begin: cmd_addrpty_qual_dec_loop
    localparam PTY_DEC_DW = ((AW - i*8)>8) ? 8 : (AW - i*8);
    if (PTY)
    begin: cmd_addr_odd_pty_qual_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (1)
      ) u_cmd_addrpty_qual_dec_wrap ( 
      .data_in    (cmd_addr[i*8+:PTY_DEC_DW]), 
      .parity_in  (cmd_addr_pty[i]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[2+i]), 
      .parity_err (cmd_addr_pty_err[i]) 
      ); 
    end //cmd_addr_odd_pty_qual_dec
    else
    begin: cmd_addr_even_pty_qual_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (1)
      ) u_cmd_addrpty_qual_dec_wrap ( 
      .data_in    (cmd_addr[i*8+:PTY_DEC_DW]), 
      .parity_in  (cmd_addr_pty[i]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[2+i]), 
      .parity_err (cmd_addr_pty_err[i]) 
      );
    end //cmd_addr_even_pty_qual_dec
end //cmd_addrpty_qual_dec_loop

localparam cmd_addr_loop = AW/8;

if (EXCL_PRE)
begin: cmd_excl_pre  
  logic [7:0] cmd_ctrl0_tmp;
  assign cmd_ctrl0_tmp = {cmd_read, cmd_wrap, cmd_data_size, cmd_excl, cmd_prot};
    if (PTY)
    begin: cmd_ctrl0_odd_pty_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (8), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl0pty_qual_dec_wrap ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_in  (cmd_ctrl_pty[0]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[2 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl0_pty_err) 
      ); 
    end //cmd_ctrl0_odd_pty_qual_dec
    else
    begin: cmd_ctrl0_even_pty_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (8), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl0pty_qual_dec_wrap ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_in  (cmd_ctrl_pty[0]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[2 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl0_pty_err) 
      );
    end //cmd_ctrl0_even_pty_qual_dec
end
else
begin: cmd_excl_n_pre 
  logic [6:0] cmd_ctrl0_tmp;
  assign cmd_ctrl0_tmp = {cmd_read, cmd_wrap, cmd_data_size, cmd_prot};
    if (PTY)
    begin: cmd_ctrl0_odd_pty_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (7), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl0pty_qual_dec_wrap ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_in  (cmd_ctrl_pty[0]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[2 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl0_pty_err) 
      ); 
    end //cmd_ctrl0_odd_pty_qual_dec
    else
    begin: cmd_ctrl0_even_pty_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (7), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl0pty_qual_dec_wrap ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_in  (cmd_ctrl_pty[0]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[2 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl0_pty_err) 
      );
    end //cmd_ctrl0_even_pty_qual_dec
end

    if (PTY)
    begin: cmd_ctrl1_odd_pty_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (BSW), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl1pty_qual_dec_wrap ( 
      .data_in    (cmd_burst_size), 
      .parity_in  (cmd_ctrl_pty[1]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[3 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl1_pty_err) 
      ); 
    end //cmd_ctrl1_odd_pty_qual_dec
    else
    begin: cmd_ctrl1_even_pty_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (BSW), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl1pty_qual_dec_wrap ( 
      .data_in    (cmd_burst_size), 
      .parity_in  (cmd_ctrl_pty[1]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[3 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl1_pty_err) 
      );
    end //cmd_ctrl1_even_pty_qual_dec

    if (PTY)
    begin: cmd_ctrl2_odd_pty_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (4), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl2pty_qual_dec_wrap ( 
      .data_in    (cmd_cache), 
      .parity_in  (cmd_ctrl_pty[2]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[4 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl2_pty_err) 
      ); 
    end //cmd_ctrl2_odd_pty_qual_dec
    else
    begin: cmd_ctrl2_even_pty_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (4), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl2pty_qual_dec_wrap ( 
      .data_in    (cmd_cache), 
      .parity_in  (cmd_ctrl_pty[2]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[4 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl2_pty_err) 
      );
    end //cmd_ctrl2_even_pty_qual_dec

if(SPC_PRE)
begin: cmd_space_pre
    if (PTY)
    begin: cmd_ctrl3_odd_pty_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (3), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl3pty_qual_dec_wrap ( 
      .data_in    (cmd_space), 
      .parity_in  (cmd_ctrl_pty[3]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[5 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl3_pty_err) 
      ); 
    end //cmd_ctrl3_odd_pty_qual_dec
    else
    begin: cmd_ctrl3_even_pty_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (3), 
      .SECOND_CHK  (1)
      ) u_cmd_ctrl3pty_qual_dec_wrap ( 
      .data_in    (cmd_space), 
      .parity_in  (cmd_ctrl_pty[3]), 
      .qual       (cmd_valid), 
      .diag_inj   (error_mask_e2e[5 + cmd_addr_loop]), 
      .parity_err (cmd_ctrl3_pty_err) 
      );
    end //cmd_ctrl3_even_pty_qual_dec
end
else
begin: cmd_space_n_pre
  assign cmd_ctrl3_pty_err = 1'b0
                        ^ error_mask_e2e[5+cmd_addr_loop]
                         ;
end

assign cmd_e2e_err_in = {cmd_valid_pty_err,
                         cmd_id_pty_err,
                         cmd_addr_pty_err,
                         cmd_ctrl0_pty_err,
                         cmd_ctrl1_pty_err,
                         cmd_ctrl2_pty_err,
                         cmd_ctrl3_pty_err};
    sr_err_aggr #( 
    .SIZE      	(APW+6), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_cmd_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst), 
    .err_in	    (cmd_e2e_err_in),
    .err_out	(cmd_e2e_err) 
    );

// Write Channel:
logic wr_valid_pty_err;    
logic wr_last_pty_err;    
logic [MPW-1:0] wr_mask_pty_err;    
logic [EW-1:0] wr_data_pty_err;
logic [(EW+MPW+2)-1:0] wr_e2e_err_in;
logic wr_e2e_err;
    if (PTY)
    begin: wr_valid_odd_pty_dec
      odd_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_wr_validpty_dec_wrap ( 
      .data_in    (wr_valid), 
      .parity_in  (wr_valid_pty), 
      .diag_inj   (error_mask_e2e[6 + cmd_addr_loop]), 
      .parity_err (wr_valid_pty_err) 
      ); 
    end //wr_valid_odd_pty_dec
    else
    begin: wr_valid_even_pty_dec
      even_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_wr_validpty_dec_wrap ( 
      .data_in    (wr_valid), 
      .parity_in  (wr_valid_pty), 
      .diag_inj   (error_mask_e2e[6 + cmd_addr_loop]), 
      .parity_err (wr_valid_pty_err) 
      );
    end //wr_valid_even_pty_dec
    if (PTY)
    begin: wr_accept_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_accept_pty_enc ( 
      .data_in    (wr_accept), 
      .parity_out (wr_accept_pty)
      ); 
    end //wr_accept_odd_pty_enc
    else
    begin: wr_accept_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_accept_pty_enc ( 
      .data_in    (wr_accept), 
      .parity_out (wr_accept_pty)
      );
    end //wr_accept_even_pty_enc

    if (PTY)
    begin: wr_last_odd_pty_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_wr_lastpty_qual_dec_wrap ( 
      .data_in    (wr_last), 
      .parity_in  (wr_last_pty), 
      .qual       (wr_valid), 
      .diag_inj   (error_mask_e2e[7 + cmd_addr_loop]), 
      .parity_err (wr_last_pty_err) 
      ); 
    end //wr_last_odd_pty_qual_dec
    else
    begin: wr_last_even_pty_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_wr_lastpty_qual_dec_wrap ( 
      .data_in    (wr_last), 
      .parity_in  (wr_last_pty), 
      .qual       (wr_valid), 
      .diag_inj   (error_mask_e2e[7 + cmd_addr_loop]), 
      .parity_err (wr_last_pty_err) 
      );
    end //wr_last_even_pty_qual_dec
if(RD_ONLY == 0)
begin: rd_wr_dec
for (genvar i = 0; i < MW/8 + ((MW%8>0) ? 1 : 0); i++)
begin: wr_maskpty_qual_dec_loop
    localparam PTY_DEC_DW = ((MW - i*8)>8) ? 8 : (MW - i*8);
    if (PTY)
    begin: wr_mask_odd_pty_qual_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (1)
      ) u_wr_maskpty_qual_dec_wrap ( 
      .data_in    (wr_mask[i*8+:PTY_DEC_DW]), 
      .parity_in  (wr_mask_pty[i]), 
      .qual       (wr_valid), 
      .diag_inj   (error_mask_e2e[8 + cmd_addr_loop+i]), 
      .parity_err (wr_mask_pty_err[i]) 
      ); 
    end //wr_mask_odd_pty_qual_dec
    else
    begin: wr_mask_even_pty_qual_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (1)
      ) u_wr_maskpty_qual_dec_wrap ( 
      .data_in    (wr_mask[i*8+:PTY_DEC_DW]), 
      .parity_in  (wr_mask_pty[i]), 
      .qual       (wr_valid), 
      .diag_inj   (error_mask_e2e[8 + cmd_addr_loop+i]), 
      .parity_err (wr_mask_pty_err[i]) 
      );
    end //wr_mask_even_pty_qual_dec
end //wr_maskpty_qual_dec_loop

  localparam wr_mask_loop = MPW + cmd_addr_loop;

for (genvar i = 0; i < DW/8 + ((DW%8>0) ? 1 : 0); i++)
begin: wr_datapty_qual_dec_loop
    localparam PTY_DEC_DW = ((DW - i*8)>8) ? 8 : (DW - i*8);
    if (PTY)
    begin: wr_data_odd_pty_qual_dec
      odd_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (1)
      ) u_wr_datapty_qual_dec_wrap ( 
      .data_in    (wr_data[i*8+:PTY_DEC_DW]), 
      .parity_in  (wr_data_pty[i]), 
      .qual       (wr_valid), 
      .diag_inj   (error_mask_e2e[8 + wr_mask_loop+i]), 
      .parity_err (wr_data_pty_err[i]) 
      ); 
    end //wr_data_odd_pty_qual_dec
    else
    begin: wr_data_even_pty_qual_dec
      even_pty_qual_di_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (1)
      ) u_wr_datapty_qual_dec_wrap ( 
      .data_in    (wr_data[i*8+:PTY_DEC_DW]), 
      .parity_in  (wr_data_pty[i]), 
      .qual       (wr_valid), 
      .diag_inj   (error_mask_e2e[8 + wr_mask_loop+i]), 
      .parity_err (wr_data_pty_err[i]) 
      );
    end //wr_data_even_pty_qual_dec
end //wr_datapty_qual_dec_loop

end
else
begin: rd_only_dec
  assign wr_mask_pty_err = 'b0;
  assign wr_data_pty_err = 'b0;
end

localparam wr_data_loop = RD_ONLY ? cmd_addr_loop: EW + MPW + cmd_addr_loop;

assign wr_e2e_err_in = {wr_valid_pty_err,
                        wr_last_pty_err,
                        wr_mask_pty_err,
                        wr_data_pty_err
                        };
    sr_err_aggr #( 
    .SIZE      	((EW+MPW+2)), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_wr_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst), 
    .err_in	    (wr_e2e_err_in),
    .err_out	(wr_e2e_err) 
    );

// Read Channel:    
logic  rd_accept_pty_err;
logic  rd_e2e_err;

    if (PTY)
    begin: rd_valid_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_rd_valid_pty_enc ( 
      .data_in    (rd_valid), 
      .parity_out (rd_valid_pty)
      ); 
    end //rd_valid_odd_pty_enc
    else
    begin: rd_valid_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_rd_valid_pty_enc ( 
      .data_in    (rd_valid), 
      .parity_out (rd_valid_pty)
      );
    end //rd_valid_even_pty_enc

    if (PTY)
    begin: rd_accept_odd_pty_dec
      odd_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_rd_acceptpty_dec_wrap ( 
      .data_in    (rd_accept), 
      .parity_in  (rd_accept_pty), 
      .diag_inj   (error_mask_e2e[8 + wr_data_loop]), 
      .parity_err (rd_accept_pty_err) 
      ); 
    end //rd_accept_odd_pty_dec
    else
    begin: rd_accept_even_pty_dec
      even_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_rd_acceptpty_dec_wrap ( 
      .data_in    (rd_accept), 
      .parity_in  (rd_accept_pty), 
      .diag_inj   (error_mask_e2e[8 + wr_data_loop]), 
      .parity_err (rd_accept_pty_err) 
      );
    end //rd_accept_even_pty_dec
if (ID_PRE)
begin: rd_id_pre
    if (PTY)
    begin: rd_id_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (IDW) 
      ) u_rd_id_pty_enc ( 
      .data_in    (rd_id), 
      .parity_out (rd_id_pty)
      ); 
    end //rd_id_odd_pty_enc
    else
    begin: rd_id_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (IDW) 
      ) u_rd_id_pty_enc ( 
      .data_in    (rd_id), 
      .parity_out (rd_id_pty)
      );
    end //rd_id_even_pty_enc

end
else
begin: rd_id_n_pre
  assign rd_id_pty = 1'b0;
end

if (EXCL_PRE)
begin: rd_excl_ok_pre
  if (RESP_PRE)
  begin: rd_resp_pre
    logic [5:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_excl_ok,rd_err,rd_last,rd_resp};
    if (PTY)
    begin: rd_ctrl_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (6) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      ); 
    end //rd_ctrl_odd_pty_enc
    else
    begin: rd_ctrl_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (6) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      );
    end //rd_ctrl_even_pty_enc

  end
  else
  begin: rd_resp_n_pre
    logic [2:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_excl_ok,rd_err,rd_last};
    if (PTY)
    begin: rd_ctrl_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (3) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      ); 
    end //rd_ctrl_odd_pty_enc
    else
    begin: rd_ctrl_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (3) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      );
    end //rd_ctrl_even_pty_enc

  end
end
else
begin: rd_excl_ok_n_pre
  if (RESP_PRE)
  begin: rd_resp_pre
    logic [4:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_err,rd_last,rd_resp};
    if (PTY)
    begin: rd_ctrl_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (5) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      ); 
    end //rd_ctrl_odd_pty_enc
    else
    begin: rd_ctrl_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (5) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      );
    end //rd_ctrl_even_pty_enc

  end
  else
  begin: rd_resp_n_pre
    logic [1:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_err,rd_last};
    if (PTY)
    begin: rd_ctrl_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (2) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      ); 
    end //rd_ctrl_odd_pty_enc
    else
    begin: rd_ctrl_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (2) 
      ) u_rd_ctrl_pty_enc ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_out (rd_ctrl_pty)
      );
    end //rd_ctrl_even_pty_enc

  end
end
for (genvar i = 0; i < DW/8 + ((DW%8>0) ? 1 : 0); i++)
begin: rd_datapty_enc_loop
    localparam PTY_ENC_DW = ((DW - i*8)>8) ? 8 : (DW - i*8);
    if (PTY)
    begin: rd_data_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (PTY_ENC_DW) 
      ) u_rd_datapty_enc ( 
      .data_in    (rd_data[i*8+:PTY_ENC_DW]), 
      .parity_out (rd_data_pty[i]) 
      ); 
    end //rd_data_odd_pty_enc
    else
    begin: rd_data_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (PTY_ENC_DW) 
      ) u_rd_datapty_enc ( 
      .data_in    (rd_data[i*8+:PTY_ENC_DW]), 
      .parity_out  (rd_data_pty[i]) 
      );
    end //rd_data_even_pty_enc
end //rd_datapty_enc_loop

    sr_err_aggr #( 
    .SIZE      	(1), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_rd_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst), 
    .err_in	    (rd_accept_pty_err),
    .err_out	(rd_e2e_err) 
    );


// Write Resp Channel:    
logic  wr_resp_accept_pty_err;
logic  wr_resp_e2e_err;

    if (PTY)
    begin: wr_done_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_done_pty_enc ( 
      .data_in    (wr_done), 
      .parity_out (wr_done_pty)
      ); 
    end //wr_done_odd_pty_enc
    else
    begin: wr_done_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_done_pty_enc ( 
      .data_in    (wr_done), 
      .parity_out (wr_done_pty)
      );
    end //wr_done_even_pty_enc

if(ID_PRE)
begin: wr_id_pre
    if (PTY)
    begin: wr_id_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (IDW) 
      ) u_wr_id_pty_enc ( 
      .data_in    (wr_id), 
      .parity_out (wr_id_pty)
      ); 
    end //wr_id_odd_pty_enc
    else
    begin: wr_id_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (IDW) 
      ) u_wr_id_pty_enc ( 
      .data_in    (wr_id), 
      .parity_out (wr_id_pty)
      );
    end //wr_id_even_pty_enc

end
else
begin: wr_id_n_pre
  assign wr_id_pty = 1'b0;
end

if (EXCL_PRE)
begin: wr_excl_ok_pre
    logic [1:0] wr_ctrl_tmp;
    assign wr_ctrl_tmp = {wr_excl_okay,wr_err};
    if (PTY)
    begin: wr_ctrl_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (2) 
      ) u_wr_ctrl_pty_enc ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_out (wr_ctrl_pty)
      ); 
    end //wr_ctrl_odd_pty_enc
    else
    begin: wr_ctrl_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (2) 
      ) u_wr_ctrl_pty_enc ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_out (wr_ctrl_pty)
      );
    end //wr_ctrl_even_pty_enc

end
else
begin: wr_excl_ok_n_pre
    logic wr_ctrl_tmp;
    assign wr_ctrl_tmp = wr_err;
    if (PTY)
    begin: wr_ctrl_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_ctrl_pty_enc ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_out (wr_ctrl_pty)
      ); 
    end //wr_ctrl_odd_pty_enc
    else
    begin: wr_ctrl_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_ctrl_pty_enc ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_out (wr_ctrl_pty)
      );
    end //wr_ctrl_even_pty_enc

end
    if (PTY)
    begin: wr_resp_accept_odd_pty_dec
      odd_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_wr_resp_acceptpty_dec_wrap ( 
      .data_in    (wr_resp_accept), 
      .parity_in  (wr_resp_accept_pty), 
      .diag_inj   (error_mask_e2e[9 + wr_data_loop]), 
      .parity_err (wr_resp_accept_pty_err) 
      ); 
    end //wr_resp_accept_odd_pty_dec
    else
    begin: wr_resp_accept_even_pty_dec
      even_pty_di_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (1)
      ) u_wr_resp_acceptpty_dec_wrap ( 
      .data_in    (wr_resp_accept), 
      .parity_in  (wr_resp_accept_pty), 
      .diag_inj   (error_mask_e2e[9 + wr_data_loop]), 
      .parity_err (wr_resp_accept_pty_err) 
      );
    end //wr_resp_accept_even_pty_dec
    sr_err_aggr #( 
    .SIZE      	(1), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_wr_resp_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst), 
    .err_in	    (wr_resp_accept_pty_err),
    .err_out	(wr_resp_e2e_err) 
    );


// Error aggregation
logic [3:0] aggr_e2e_err_in;
logic e2e_err;
assign aggr_e2e_err_in = {cmd_e2e_err,
                          wr_e2e_err,
                          rd_e2e_err,
                          wr_resp_e2e_err};
    sr_err_aggr #( 
    .SIZE      	(4), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst), 
    .err_in	    (aggr_e2e_err_in),
    .err_out	(e2e_err) 
    );


logic clear_latent_fault_r;
logic diag_mode_valid;
logic diag_mode_valid_dly_r, diag_mode_valid_dly_2nd_r;
logic [1:0] dr_tgt_e2e_check_error;
assign diag_mode_valid  = `def_dr_en_chk(dr_sfty_e2e_diag_mode) && valid_mask_e2e[9 + wr_data_loop]; 
assign dr_tgt_e2e_check_error  =  (diag_mode_valid_dly_2nd_r) ? (e2e_err ? 2'b01 : 2'b10) : 2'b01;
logic tgt_e2e_check_error_tmp;
logic [1:0] dr_tgt_e2e_check_error_sticky, tgt_e2e_check_error_r, tgt_e2e_check_error_nxt;

assign tgt_e2e_check_error_tmp     = (dr_tgt_e2e_check_error != 2'b01)? 1'b1 : 1'b0;
assign tgt_e2e_check_error_nxt = (dr_tgt_e2e_check_error_sticky == 2'b01)? {tgt_e2e_check_error_tmp, tgt_e2e_check_error_tmp} : tgt_e2e_check_error_r;

always_ff @(posedge clk or posedge rst)
begin: tgt_e2e_check_error_r_PROC
  if(rst == 1) begin
    tgt_e2e_check_error_r <= 2'b00;
  end
  else if(clear_latent_fault_r) begin
    tgt_e2e_check_error_r <= 2'b00;
  end
  else begin
    tgt_e2e_check_error_r <= {tgt_e2e_check_error_nxt[1], tgt_e2e_check_error_nxt[0]};
  end
end

always_comb
begin: dr_tgt_e2e_check_error_sticky_PROC
  dr_tgt_e2e_check_error_sticky = {tgt_e2e_check_error_r[1],~tgt_e2e_check_error_r[0]};
end
assign dr_e2e_check_error_sticky = dr_tgt_e2e_check_error_sticky;

always_ff @( posedge clk or posedge rst )
begin: diag_mode_valid_r_PROC
  if( rst) begin
    diag_mode_valid_dly_r     <= 1'b0;
    diag_mode_valid_dly_2nd_r <= 1'b0;
    clear_latent_fault_r      <= 1'b0;
  end
  else begin              
    diag_mode_valid_dly_r     <= diag_mode_valid;
    diag_mode_valid_dly_2nd_r <= diag_mode_valid_dly_r;
    clear_latent_fault_r      <= clear_latent_fault;
  end
end

assign tgt_e2e_err = e2e_err & ~`def_dr_en_chk(dr_sfty_e2e_diag_mode);


endmodule
