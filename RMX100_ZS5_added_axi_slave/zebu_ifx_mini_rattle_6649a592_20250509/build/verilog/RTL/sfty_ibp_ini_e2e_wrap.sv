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
// @f:sfty_ibp_tgt_e2e_wrap
//
// Description:
// @p
//   ibp target port e2e wrapper file.
// @e
//
// ===========================================================================
`include "defines.v"
`include "rv_safety_exported_defines.v"






module sfty_ibp_ini_e2e_wrap #(
    parameter  SECOND_CHK = 0, // Redundant Check 0: disable 1: enable
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
    localparam EW = DW/8, // data prity width
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
    output logic                cmd_valid_pty,
    input  logic                cmd_accept_pty,              
    output logic  [IDPW-1:0]    cmd_id_pty,
    output logic  [APW-1:0]     cmd_addr_pty,                          
    output logic  [3:0]         cmd_ctrl_pty,

    output logic                wr_valid_pty,    
    input  logic                wr_accept_pty,   
    output logic                wr_last_pty,    
    output logic  [MPW-1:0]     wr_mask_pty,    
    output logic  [EW-1:0]      wr_data_pty,
    
    input  logic                rd_valid_pty,                
    output logic                rd_accept_pty,               
    input  logic  [IDPW-1:0]    rd_id_pty,                
    input  logic                rd_ctrl_pty,                
    input  logic  [EW-1:0]      rd_data_pty,     
    
    input  logic                wr_done_pty,
    input  logic  [IDPW-1:0]    wr_id_pty,                
    input  logic                wr_ctrl_pty,
    output logic                wr_resp_accept_pty,
// spyglass enable_block W240

// msic
    output logic                ini_e2e_err,
    input  logic                clk,
    input  logic                rst_a
);

// Commnad Channel:
logic  cmd_accept_pty_err;
logic  cmd_e2e_err;

    if (PTY)
    begin: cmd_valid_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_cmd_valid_pty_enc ( 
      .data_in    (cmd_valid), 
      .parity_out (cmd_valid_pty)
      ); 
    end //cmd_valid_odd_pty_enc
    else
    begin: cmd_valid_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_cmd_valid_pty_enc ( 
      .data_in    (cmd_valid), 
      .parity_out (cmd_valid_pty)
      );
    end //cmd_valid_even_pty_enc

    if (PTY)
    begin: cmd_accept_odd_pty_dec
      odd_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_cmd_acceptpty_dec_wrap ( 
      .data_in    (cmd_accept), 
      .parity_in  (cmd_accept_pty), 
      .parity_err (cmd_accept_pty_err) 
      ); 
    end //cmd_accept_odd_pty_dec
    else
    begin: cmd_accept_even_pty_dec
      even_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_cmd_acceptpty_dec_wrap ( 
      .data_in    (cmd_accept), 
      .parity_in  (cmd_accept_pty), 
      .parity_err (cmd_accept_pty_err) 
      );
    end //cmd_accept_even_pty_dec
if(ID_PRE)
begin: cmd_id_pre
    if (PTY)
    begin: cmd_id_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (IDW) 
      ) u_cmd_id_pty_enc ( 
      .data_in    (cmd_id), 
      .parity_out (cmd_id_pty)
      ); 
    end //cmd_id_odd_pty_enc
    else
    begin: cmd_id_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (IDW) 
      ) u_cmd_id_pty_enc ( 
      .data_in    (cmd_id), 
      .parity_out (cmd_id_pty)
      );
    end //cmd_id_even_pty_enc

end
else
begin: cmd_id_n_pre
  assign cmd_id_pty = 1'b0;
end
for (genvar i = 0; i < AW/8 + ((AW%8>0) ? 1 : 0); i++)
begin: cmd_addrpty_enc_loop
    localparam PTY_ENC_DW = ((AW - i*8)>8) ? 8 : (AW - i*8);
    if (PTY)
    begin: cmd_addr_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (PTY_ENC_DW) 
      ) u_cmd_addrpty_enc ( 
      .data_in    (cmd_addr[i*8+:PTY_ENC_DW]), 
      .parity_out (cmd_addr_pty[i]) 
      ); 
    end //cmd_addr_odd_pty_enc
    else
    begin: cmd_addr_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (PTY_ENC_DW) 
      ) u_cmd_addrpty_enc ( 
      .data_in    (cmd_addr[i*8+:PTY_ENC_DW]), 
      .parity_out  (cmd_addr_pty[i]) 
      );
    end //cmd_addr_even_pty_enc
end //cmd_addrpty_enc_loop

if (EXCL_PRE)
begin: cmd_excl_pre  
  logic [7:0] cmd_ctrl0_tmp;
  assign cmd_ctrl0_tmp = {cmd_read, cmd_wrap, cmd_data_size, cmd_excl, cmd_prot};
    if (PTY)
    begin: cmd_ctrl0_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (8) 
      ) u_cmd_ctrl0_pty_enc ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_out (cmd_ctrl_pty[0])
      ); 
    end //cmd_ctrl0_odd_pty_enc
    else
    begin: cmd_ctrl0_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (8) 
      ) u_cmd_ctrl0_pty_enc ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_out (cmd_ctrl_pty[0])
      );
    end //cmd_ctrl0_even_pty_enc

end
else
begin: cmd_excl_n_pre 
  logic [6:0] cmd_ctrl0_tmp;
  assign cmd_ctrl0_tmp = {cmd_read, cmd_wrap, cmd_data_size, cmd_prot};
    if (PTY)
    begin: cmd_ctrl0_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (7) 
      ) u_cmd_ctrl0_pty_enc ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_out (cmd_ctrl_pty[0])
      ); 
    end //cmd_ctrl0_odd_pty_enc
    else
    begin: cmd_ctrl0_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (7) 
      ) u_cmd_ctrl0_pty_enc ( 
      .data_in    (cmd_ctrl0_tmp), 
      .parity_out (cmd_ctrl_pty[0])
      );
    end //cmd_ctrl0_even_pty_enc

end
    if (PTY)
    begin: cmd_ctrl1_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (BSW) 
      ) u_cmd_ctrl1_pty_enc ( 
      .data_in    (cmd_burst_size), 
      .parity_out (cmd_ctrl_pty[1])
      ); 
    end //cmd_ctrl1_odd_pty_enc
    else
    begin: cmd_ctrl1_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (BSW) 
      ) u_cmd_ctrl1_pty_enc ( 
      .data_in    (cmd_burst_size), 
      .parity_out (cmd_ctrl_pty[1])
      );
    end //cmd_ctrl1_even_pty_enc

    if (PTY)
    begin: cmd_ctrl2_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (4) 
      ) u_cmd_ctrl2_pty_enc ( 
      .data_in    (cmd_cache), 
      .parity_out (cmd_ctrl_pty[2])
      ); 
    end //cmd_ctrl2_odd_pty_enc
    else
    begin: cmd_ctrl2_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (4) 
      ) u_cmd_ctrl2_pty_enc ( 
      .data_in    (cmd_cache), 
      .parity_out (cmd_ctrl_pty[2])
      );
    end //cmd_ctrl2_even_pty_enc

if(SPC_PRE)
begin: cmd_space_pre
    if (PTY)
    begin: cmd_ctrl3_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (3) 
      ) u_cmd_ctrl3_pty_enc ( 
      .data_in    (cmd_space), 
      .parity_out (cmd_ctrl_pty[3])
      ); 
    end //cmd_ctrl3_odd_pty_enc
    else
    begin: cmd_ctrl3_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (3) 
      ) u_cmd_ctrl3_pty_enc ( 
      .data_in    (cmd_space), 
      .parity_out (cmd_ctrl_pty[3])
      );
    end //cmd_ctrl3_even_pty_enc

end
else
begin: cmd_space_n_pre
  assign cmd_ctrl_pty[3] = 1'b0;
end

assign cmd_e2e_err  = {cmd_accept_pty_err};
// Write Channel:
logic  wr_accept_pty_err;    
logic  wr_e2e_err;
    if (PTY)
    begin: wr_valid_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_valid_pty_enc ( 
      .data_in    (wr_valid), 
      .parity_out (wr_valid_pty)
      ); 
    end //wr_valid_odd_pty_enc
    else
    begin: wr_valid_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_valid_pty_enc ( 
      .data_in    (wr_valid), 
      .parity_out (wr_valid_pty)
      );
    end //wr_valid_even_pty_enc

    if (PTY)
    begin: wr_accept_odd_pty_dec
      odd_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_acceptpty_dec_wrap ( 
      .data_in    (wr_accept), 
      .parity_in  (wr_accept_pty), 
      .parity_err (wr_accept_pty_err) 
      ); 
    end //wr_accept_odd_pty_dec
    else
    begin: wr_accept_even_pty_dec
      even_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_acceptpty_dec_wrap ( 
      .data_in    (wr_accept), 
      .parity_in  (wr_accept_pty), 
      .parity_err (wr_accept_pty_err) 
      );
    end //wr_accept_even_pty_dec
    if (PTY)
    begin: wr_last_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_last_pty_enc ( 
      .data_in    (wr_last), 
      .parity_out (wr_last_pty)
      ); 
    end //wr_last_odd_pty_enc
    else
    begin: wr_last_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_last_pty_enc ( 
      .data_in    (wr_last), 
      .parity_out (wr_last_pty)
      );
    end //wr_last_even_pty_enc

if(RD_ONLY == 0)
begin: rd_wr_enc
    if (PTY)
    begin: wr_mask_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (MW) 
      ) u_wr_mask_pty_enc ( 
      .data_in    (wr_mask), 
      .parity_out (wr_mask_pty)
      ); 
    end //wr_mask_odd_pty_enc
    else
    begin: wr_mask_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (MW) 
      ) u_wr_mask_pty_enc ( 
      .data_in    (wr_mask), 
      .parity_out (wr_mask_pty)
      );
    end //wr_mask_even_pty_enc

for (genvar i = 0; i < DW/8 + ((DW%8>0) ? 1 : 0); i++)
begin: wr_datapty_enc_loop
    localparam PTY_ENC_DW = ((DW - i*8)>8) ? 8 : (DW - i*8);
    if (PTY)
    begin: wr_data_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (PTY_ENC_DW) 
      ) u_wr_datapty_enc ( 
      .data_in    (wr_data[i*8+:PTY_ENC_DW]), 
      .parity_out (wr_data_pty[i]) 
      ); 
    end //wr_data_odd_pty_enc
    else
    begin: wr_data_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (PTY_ENC_DW) 
      ) u_wr_datapty_enc ( 
      .data_in    (wr_data[i*8+:PTY_ENC_DW]), 
      .parity_out  (wr_data_pty[i]) 
      );
    end //wr_data_even_pty_enc
end //wr_datapty_enc_loop

end
else
begin: rd_only_enc
  assign wr_mask_pty = 'b0;
  assign wr_data_pty = 'b0;
end
assign wr_e2e_err  = {wr_accept_pty_err};
// Read Channel:    
logic  rd_valid_pty_err;
logic  rd_id_pty_err;
logic  rd_ctrl_pty_err;
logic [EW-1:0] rd_data_pty_err;
logic [(EW+3)-1:0] rd_e2e_err_in;
logic  rd_e2e_err;

    if (PTY)
    begin: rd_valid_odd_pty_dec
      odd_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_validpty_dec_wrap ( 
      .data_in    (rd_valid), 
      .parity_in  (rd_valid_pty), 
      .parity_err (rd_valid_pty_err) 
      ); 
    end //rd_valid_odd_pty_dec
    else
    begin: rd_valid_even_pty_dec
      even_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_validpty_dec_wrap ( 
      .data_in    (rd_valid), 
      .parity_in  (rd_valid_pty), 
      .parity_err (rd_valid_pty_err) 
      );
    end //rd_valid_even_pty_dec
    if (PTY)
    begin: rd_accept_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_rd_accept_pty_enc ( 
      .data_in    (rd_accept), 
      .parity_out (rd_accept_pty)
      ); 
    end //rd_accept_odd_pty_enc
    else
    begin: rd_accept_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_rd_accept_pty_enc ( 
      .data_in    (rd_accept), 
      .parity_out (rd_accept_pty)
      );
    end //rd_accept_even_pty_enc

if (ID_PRE)
begin: rd_id_pre
    if (PTY)
    begin: rd_id_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (IDW), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_idpty_qual_dec_wrap ( 
      .data_in    (rd_id), 
      .parity_in  (rd_id_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_id_pty_err) 
      ); 
    end //rd_id_odd_pty_qual_dec
    else
    begin: rd_id_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (IDW), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_idpty_qual_dec_wrap ( 
      .data_in    (rd_id), 
      .parity_in  (rd_id_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_id_pty_err) 
      );
    end //rd_id_even_pty_qual_dec
end
else
begin: rd_id_n_pre
  assign rd_id_pty_err = 1'b0;
end

if (EXCL_PRE)
begin: rd_excl_ok_pre
  if (RESP_PRE)
  begin: rd_resp_pre
    logic [5:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_excl_ok,rd_err,rd_last,rd_resp};
    if (PTY)
    begin: rd_ctrl_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (6), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      ); 
    end //rd_ctrl_odd_pty_qual_dec
    else
    begin: rd_ctrl_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (6), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      );
    end //rd_ctrl_even_pty_qual_dec
  end
  else
  begin: rd_resp_n_pre
    logic [2:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_excl_ok,rd_err,rd_last};
    if (PTY)
    begin: rd_ctrl_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (3), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      ); 
    end //rd_ctrl_odd_pty_qual_dec
    else
    begin: rd_ctrl_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (3), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      );
    end //rd_ctrl_even_pty_qual_dec
  end
end
else
begin: rd_excl_ok_n_pre
  if (RESP_PRE)
  begin: rd_resp_pre
    logic [4:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_err,rd_last,rd_resp};
    if (PTY)
    begin: rd_ctrl_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (5), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      ); 
    end //rd_ctrl_odd_pty_qual_dec
    else
    begin: rd_ctrl_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (5), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      );
    end //rd_ctrl_even_pty_qual_dec
  end
  else
  begin: rd_resp_n_pre
    logic [1:0] rd_ctrl_tmp;
    assign rd_ctrl_tmp = {rd_err,rd_last};
    if (PTY)
    begin: rd_ctrl_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (2), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      ); 
    end //rd_ctrl_odd_pty_qual_dec
    else
    begin: rd_ctrl_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (2), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_ctrlpty_qual_dec_wrap ( 
      .data_in    (rd_ctrl_tmp), 
      .parity_in  (rd_ctrl_pty), 
      .qual       (rd_valid), 
      .parity_err (rd_ctrl_pty_err) 
      );
    end //rd_ctrl_even_pty_qual_dec
  end
end
for (genvar i = 0; i < DW/8 + ((DW%8>0) ? 1 : 0); i++)
begin: rd_datapty_qual_dec_loop
    localparam PTY_DEC_DW = ((DW - i*8)>8) ? 8 : (DW - i*8);
    if (PTY)
    begin: rd_data_odd_pty_qual_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_datapty_qual_dec_wrap ( 
      .data_in    (rd_data[i*8+:PTY_DEC_DW]), 
      .parity_in  (rd_data_pty[i]), 
      .qual       (rd_valid), 
      .parity_err (rd_data_pty_err[i]) 
      ); 
    end //rd_data_odd_pty_qual_dec
    else
    begin: rd_data_even_pty_qual_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (PTY_DEC_DW), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_rd_datapty_qual_dec_wrap ( 
      .data_in    (rd_data[i*8+:PTY_DEC_DW]), 
      .parity_in  (rd_data_pty[i]), 
      .qual       (rd_valid), 
      .parity_err (rd_data_pty_err[i]) 
      );
    end //rd_data_even_pty_qual_dec
end //rd_datapty_qual_dec_loop

assign rd_e2e_err_in = {rd_valid_pty_err,
                         rd_id_pty_err,
                         rd_ctrl_pty_err,
                         rd_data_pty_err};
    sr_err_aggr #( 
    .SIZE      	(EW+3), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_rd_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst_a), 
    .err_in   	(rd_e2e_err_in),
    .err_out	(rd_e2e_err) 
    );



// Write Resp Channel:    
logic wr_done_pty_err;
logic wr_id_pty_err;
logic wr_ctrl_pty_err;
logic [2:0] wr_resp_e2e_err_in;
logic wr_resp_e2e_err;

    if (PTY)
    begin: wr_done_odd_pty_dec
      odd_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_donepty_dec_wrap ( 
      .data_in    (wr_done), 
      .parity_in  (wr_done_pty), 
      .parity_err (wr_done_pty_err) 
      ); 
    end //wr_done_odd_pty_dec
    else
    begin: wr_done_even_pty_dec
      even_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_donepty_dec_wrap ( 
      .data_in    (wr_done), 
      .parity_in  (wr_done_pty), 
      .parity_err (wr_done_pty_err) 
      );
    end //wr_done_even_pty_dec
if (ID_PRE)
begin: wr_id_pre
    if (PTY)
    begin: wr_id_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (IDW), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_idpty_qual_dec_wrap ( 
      .data_in    (wr_id), 
      .parity_in  (wr_id_pty), 
      .qual       (wr_done), 
      .parity_err (wr_id_pty_err) 
      ); 
    end //wr_id_odd_pty_qual_dec
    else
    begin: wr_id_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (IDW), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_idpty_qual_dec_wrap ( 
      .data_in    (wr_id), 
      .parity_in  (wr_id_pty), 
      .qual       (wr_done), 
      .parity_err (wr_id_pty_err) 
      );
    end //wr_id_even_pty_qual_dec
end
else
begin: wr_id_n_pre
 assign wr_id_pty_err = 1'b0;
end

if (EXCL_PRE)
begin: wr_excl_ok_pre
    logic [1:0] wr_ctrl_tmp;
    assign wr_ctrl_tmp = {wr_excl_okay,wr_err};
    if (PTY)
    begin: wr_ctrl_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (2), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_ctrlpty_qual_dec_wrap ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_in  (wr_ctrl_pty), 
      .qual       (wr_done), 
      .parity_err (wr_ctrl_pty_err) 
      ); 
    end //wr_ctrl_odd_pty_qual_dec
    else
    begin: wr_ctrl_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (2), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_ctrlpty_qual_dec_wrap ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_in  (wr_ctrl_pty), 
      .qual       (wr_done), 
      .parity_err (wr_ctrl_pty_err) 
      );
    end //wr_ctrl_even_pty_qual_dec
end
else
begin: wr_excl_ok_n_pre
    logic wr_ctrl_tmp;
    assign wr_ctrl_tmp = wr_err;
    if (PTY)
    begin: wr_ctrl_odd_pty_dec
      odd_pty_qual_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_ctrlpty_qual_dec_wrap ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_in  (wr_ctrl_pty), 
      .qual       (wr_done), 
      .parity_err (wr_ctrl_pty_err) 
      ); 
    end //wr_ctrl_odd_pty_qual_dec
    else
    begin: wr_ctrl_even_pty_dec
      even_pty_qual_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_wr_ctrlpty_qual_dec_wrap ( 
      .data_in    (wr_ctrl_tmp), 
      .parity_in  (wr_ctrl_pty), 
      .qual       (wr_done), 
      .parity_err (wr_ctrl_pty_err) 
      );
    end //wr_ctrl_even_pty_qual_dec
end
    if (PTY)
    begin: wr_resp_accept_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_resp_accept_pty_enc ( 
      .data_in    (wr_resp_accept), 
      .parity_out (wr_resp_accept_pty)
      ); 
    end //wr_resp_accept_odd_pty_enc
    else
    begin: wr_resp_accept_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_wr_resp_accept_pty_enc ( 
      .data_in    (wr_resp_accept), 
      .parity_out (wr_resp_accept_pty)
      );
    end //wr_resp_accept_even_pty_enc

assign wr_resp_e2e_err_in = {wr_done_pty_err,
                         wr_id_pty_err,
                         wr_ctrl_pty_err};
    sr_err_aggr #( 
    .SIZE      	(3), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_wr_resp_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst_a), 
    .err_in   	(wr_resp_e2e_err_in),
    .err_out	(wr_resp_e2e_err) 
    );


// Error aggregation
logic [3:0] aggr_e2e_err_in;
assign aggr_e2e_err_in = {cmd_e2e_err,
                          wr_e2e_err,
                          rd_e2e_err,
                          wr_resp_e2e_err};
    sr_err_aggr #( 
    .SIZE      	(4), 
    .IBUF_EN    (0), 
    .OBUF_EN    (1), 
    .OBUF_DEPTH (1) 
    ) u_ini_e2e_err_aggr(
    .clk		(clk), 
    .rst		(rst_a), 
    .err_in   	(aggr_e2e_err_in),
    .err_out	(ini_e2e_err) 
    );

endmodule
