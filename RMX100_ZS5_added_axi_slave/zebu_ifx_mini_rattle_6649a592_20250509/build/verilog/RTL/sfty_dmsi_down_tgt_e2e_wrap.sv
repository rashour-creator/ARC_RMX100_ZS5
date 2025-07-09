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
// @f:sfty_dmsi_down_tgt_e2e_wrap
//
// Description:
// @p
//   dmsi interface target port e2e wrapper file.
// @e
//
// ===========================================================================
`include "defines.v"
`include "rv_safety_exported_defines.v"

// Set simulation timescale
//
`include "const.def"









module sfty_dmsi_down_tgt_e2e_wrap #(
    parameter  SECOND_CHK = 0, // Redundant Check 0: disable 1: enable
    parameter  PTY = 1,// 0: even, 1: odd
    parameter  SECDED = 0,// 0: DED, 1: SECDED
    parameter  ECC_GNT = 0, // ECC ganulairty type: 0: 32b, 1: 64b 
    parameter  DW = 32,// Data width
	parameter  CDW = 1,//dmsi_credit width
    localparam CW = ((ECC_GNT)? ((SECDED)? 8: 7) : ((SECDED)? 7: 6)) // ecc check bit size per granularity unit
  )
(
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Do not care the warning of "declared but not read"  
// DMSI interface target interface
    input  logic                              dmsi_down_valid,
    input  logic [`CNTXT_IDX_RANGE]           dmsi_down_context,
    input  logic [`EIID_IDX_RANGE]            dmsi_down_eiid,
    input  logic                              dmsi_down_domain,
	input  logic                              dmsi_down_rdy,

	input  logic                              dmsi_down_valid_chk,
	input  logic [CW-1:0]                     dmsi_down_data_edc,

	output logic                              dmsi_down_rdy_chk,
// spyglass enable_block W240
// msic
    output logic                              ini_e2e_err,
    input  logic                              clk,
    input  logic                              rst_a
);

// dmsi_down_rdy_chk
    if (PTY)
    begin: dmsi_down_rdy_odd_pty_enc
      odd_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_dmsi_down_rdy_pty_enc ( 
      .data_in    (dmsi_down_rdy), 
      .parity_out (dmsi_down_rdy_chk)
      ); 
    end //dmsi_down_rdy_odd_pty_enc
    else
    begin: dmsi_down_rdy_even_pty_enc
      even_pty_enc #( 
      .DATA_SIZE (1) 
      ) u_dmsi_down_rdy_pty_enc ( 
      .data_in    (dmsi_down_rdy), 
      .parity_out (dmsi_down_rdy_chk)
      );
    end //dmsi_down_rdy_even_pty_enc


// dmsi_down_valid check
logic dmsi_down_valid_pty_err;

    if (PTY)
    begin: dmsi_down_valid_odd_pty_dec
      odd_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_dmsi_down_validpty_dec_wrap ( 
      .data_in    (dmsi_down_valid), 
      .parity_in  (dmsi_down_valid_chk), 
      .parity_err (dmsi_down_valid_pty_err) 
      ); 
    end //dmsi_down_valid_odd_pty_dec
    else
    begin: dmsi_down_valid_even_pty_dec
      even_pty_dec_wrap #( 
      .DATA_SIZE (1), 
      .SECOND_CHK  (SECOND_CHK)
      ) u_dmsi_down_validpty_dec_wrap ( 
      .data_in    (dmsi_down_valid), 
      .parity_in  (dmsi_down_valid_chk), 
      .parity_err (dmsi_down_valid_pty_err) 
      );
    end //dmsi_down_valid_even_pty_dec

// dmsi payload check
logic [31:0] dmsi_payload;
logic [13:0] dmsi_hart_field;
logic [5:0]  dmsi_context_field;
logic        dmsi_domain_field;
logic [10:0] dmsi_eiid_field;
logic        dmsi_payload_err;

assign dmsi_hart_field = 14'b0;
assign dmsi_context_field = {5'b0, dmsi_down_context};
assign dmsi_domain_field = dmsi_down_domain;
assign dmsi_eiid_field = {5'b0, dmsi_down_eiid};
assign dmsi_payload = {dmsi_hart_field, dmsi_context_field, dmsi_domain_field, dmsi_eiid_field};

      for (genvar i = 0; i < DW/32; i++)
      begin: dmsi_payload_32b_qual_loop    
        if (SECDED)
        begin: dmsi_payload_32b_qual_ecc
          e2e_ecc32_1stg_qual_cac_wrap#( 
          .SECOND_CHK     (SECOND_CHK) 
          ) u_dmsi_payload_ecc_qual_dec_wrap( 
          .data_in      (dmsi_payload[i*32+:32]), 
          .ecc_code_in  (dmsi_down_data_edc[i*CW+:CW]),
          .data_out     (),
          .ecc_code_out (),
          .qual         (dmsi_down_valid),
          .sb_err       (),
          .db_err       (dmsi_payload_err)
          ); 
        end //dmsi_payload_32b_qual_ecc
        else
        begin: dmsi_payload_32b_qual_edc
         e2e_edc32_1stg_qual_chk_wrap #( 
          .SECOND_CHK     (SECOND_CHK) 
          ) u_dmsi_payload_edc_qual_dec_wrap( 
          .data_in      (dmsi_payload[i*32+:32]), 
          .edc_in       (dmsi_down_data_edc[i*CW+:CW]),
          .qual         (dmsi_down_valid),
          .err          (dmsi_payload_err)
          );
        end //dmsi_payload_32b_qual_edc
      end //dmsi_payload_32b_qual_loop 


// Error aggregation
logic [1:0] aggr_e2e_err_in;
assign aggr_e2e_err_in = {dmsi_down_valid_pty_err, dmsi_payload_err};

    sr_err_aggr #( 
    .SIZE      	(2), 
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
