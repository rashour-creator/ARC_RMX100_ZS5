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
//     This module implements the logic used to manage the safety CSR 
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
`include "csr_defines.v"
`include "ifu_defines.v"
`include "rv_safety_exported_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_sfty_csr (

  ////////// SAFETY interface ///////////////////////////////////////////////
  //
  output reg [`RV_LSC_DIAG_RANGE] lsc_diag_aux_r,
  output [1:0]                    safety_comparator_enable,
  output reg [1:0]                dr_lsc_stl_ctrl_aux_r,
  output                          lsc_shd_ctrl_aux_r,
  output reg [1:0]                dr_sfty_aux_parity_err_r,
  input [1:0]                     dr_safety_comparator_enabled,
  input                           safety_iso_enb_synch_r,
  output reg                      sfty_nsi_r,
  input [`RV_LSC_ERR_STAT_RANGE]  lsc_err_stat_aux,
  input [1:0]                     dr_sfty_eic,

  ////////// CSR interface ///////////////////////////////////////////////
  //
  input [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input [11:0]                    csr_sel_addr,          // (X1) CSR address
  
  output reg [`DATA_RANGE]        csr_rdata,             // (X1) CSR read data
  output reg                      csr_illegal,           // (X1) illegal
  output reg                      csr_unimpl,            // (X1) Invalid CSR
  output reg                      csr_serial_sr,         // (X1) SR group flush pipe
  output reg                      csr_strict_sr,         // (X1) SR flush pipe
  
  input                           csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input [11:0]                    csr_waddr,             // (X2) CSR addr
  input [`DATA_RANGE]             csr_wdata,             // (X2) Write data
  
  input                           x2_pass,               // (X2) commit
  input [1:0]                     priv_level_r,          // Machine state
  
  ////////// General input signals //////////////////////////////////////////
  //
  input                           clk,                   // clock signal
  input                           rst_a                  // reset signal
);

// Local Declarations
//
reg [1:0]         lsc_passwd_aux_r;
reg [1:0]         lsc_ctrl_aux_r;
wire [31:0]       lsc_diag_aux_readback;

// Clock-gates
//
reg                       csr_passwd_cg;
reg                       csr_passwd_clr;
reg                       csr_ctrl_cg;
reg                       csr_diag_cg;
reg                       csr_stl_ctrl_cg;
reg                       csr_shd_ctrl_cg;

wire                      csr_sel_write;

// The PMP CSRs live in this module
//

localparam MSFTY_PASSWD       = 8'hF0;
localparam MSFTY_CTRL         = 8'hF1;
localparam MSFTY_DIAG         = 8'hF2;
localparam MSFTY_STL_CTRL     = 8'hF3;
localparam MSFTY_SHADOW_CTRL  = 8'hF4;
localparam MSFTY_ERROR_STATUS = 8'hF8;

assign csr_sel_write = csr_sel_ctl[1];


//////////////////////////////////////////////////////////////////////////////
// Reads
//
//////////////////////////////////////////////////////////////////////////////
wire priv_viol;
wire pswd_viol;
wire pswd_priv_viol;
assign priv_viol = priv_level_r != `PRIV_M;
assign pswd_viol = (csr_sel_write ?(((lsc_passwd_aux_r == 2'b10) & (!csr_passwd_clr)) ? 1'b0 : 1'b1) : 1'b0);
assign pswd_priv_viol = priv_viol || pswd_viol;
always @*
begin : csr_read_PROC

  csr_rdata     = {`DATA_SIZE{1'b0}};             
  csr_illegal   = 1'b0;    
  csr_unimpl    = 1'b1;    
  csr_serial_sr = 1'b0; 
  csr_strict_sr = 1'b0;

  if (csr_sel_ctl != 2'b00)
  begin
    // SAFETY unit got selected
    //
    case (csr_sel_addr)
//!BCR { num: 2032, val: 1, name: "MSFTY_PASSWD" }
    `CSR_MSFTY_PASSWD:
    begin
      csr_rdata      = {30'h0,lsc_passwd_aux_r};          
      csr_illegal    = priv_viol;    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2033, val: 1431655765, name: "MSFTY_CTRL" }
    `CSR_MSFTY_CTRL:
    begin
	  csr_rdata      = {2'b01,
                        2'b01, 
                        24'h555555, 
                        dr_safety_comparator_enabled, 
                        lsc_ctrl_aux_r
                       };
	  csr_illegal 	 = pswd_priv_viol;
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = 1'b0;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2034, val: 1431655765, name: "MSFTY_DIAG" }
    `CSR_MSFTY_DIAG:
    begin
      csr_rdata      = lsc_diag_aux_readback;          
	  csr_illegal 	 = pswd_priv_viol;
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = 1'b0;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2035, val: 1, name: "MSFTY_STL_CTRL" }
    `CSR_MSFTY_STL_CTRL:
    begin
      csr_rdata      = {30'h0,dr_lsc_stl_ctrl_aux_r};          
	  csr_illegal 	 = priv_viol;
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = 1'b0;
      csr_strict_sr  = 1'b0;
    end
    
    `CSR_MSFTY_SHADOW_CTRL:
    begin
      csr_rdata      = {31'h0,lsc_shd_ctrl_aux_r};          
	  csr_illegal 	 = pswd_priv_viol;
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = 1'b0;
      csr_strict_sr  = 1'b0;
    end
    
    `CSR_MSFTY_ERROR_STATUS:
    begin
      csr_rdata      = {18'h0,lsc_err_stat_aux};
	  csr_illegal 	 = priv_viol || csr_sel_write;
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = 1'b0;
      csr_strict_sr  = 1'b0;
    end
    
    default:
    begin
      csr_rdata     = {`DATA_SIZE{1'b0}};             
      csr_illegal   = 1'b0;    
      csr_unimpl    = 1'b1;    
      csr_serial_sr = 1'b0; 
      csr_strict_sr = 1'b0;
    end
    endcase
  end
end

//////////////////////////////////////////////////////////////////////////////
// Writes
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_write_PROC
  // Default values
  //
  csr_passwd_cg    = 1'b0;
  csr_passwd_clr   = 1'b0;
  csr_ctrl_cg      = 1'b0;
  csr_diag_cg      = 1'b0;
  csr_stl_ctrl_cg  = 1'b0;
  csr_shd_ctrl_cg  = 1'b0;
  
  if(csr_write & x2_pass)
  begin
    case (csr_waddr)
    `CSR_MSFTY_PASSWD:
    begin
      csr_passwd_cg = 1'b1;
    end
    
    `CSR_MSFTY_CTRL:
    begin
      csr_ctrl_cg    = (lsc_passwd_aux_r == 2'b10)? 1'b1: 1'b0;
      csr_passwd_clr = 1'b1;
    end
    
    `CSR_MSFTY_DIAG:
    begin
      csr_diag_cg    = (lsc_passwd_aux_r == 2'b10)? 1'b1: 1'b0;
      csr_passwd_clr = 1'b1;
    end
    
    `CSR_MSFTY_STL_CTRL:
    begin
      csr_stl_ctrl_cg = 1'b1;
    end
    
    `CSR_MSFTY_SHADOW_CTRL:
    begin
      csr_shd_ctrl_cg = ((lsc_passwd_aux_r == 2'b10) && (dr_safety_comparator_enabled == 2'b01))? 1'b1: 1'b0;
      csr_passwd_clr = 1'b1;
    end
      
    default:
    begin
      csr_passwd_cg   = 1'b0;
      csr_passwd_clr  = 1'b0;
      csr_ctrl_cg     = 1'b0;
      csr_diag_cg     = 1'b0;
      csr_stl_ctrl_cg = 1'b0;
      csr_shd_ctrl_cg = 1'b0;
    end
    endcase
  end
end



//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : lsc_passwd_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsc_passwd_aux_r   <= 2'b01;
  end
  else
  begin
    if (csr_passwd_cg == 1'b1)
    begin
      lsc_passwd_aux_r <= csr_wdata[1:0];
    end
    else if(csr_passwd_clr == 1'b1)
    begin
      lsc_passwd_aux_r <= 2'b01;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : lsc_ctrl_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsc_ctrl_aux_r   <= 2'b01;
  end
  else
  begin
    if (csr_ctrl_cg == 1'b1)
    begin
      lsc_ctrl_aux_r <= csr_wdata[1:0];
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : lsc_diag_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsc_diag_aux_r   <= {`RV_LSC_DIAG_WR_PAIR{2'b01}};
  end
  else
  begin
    if (csr_diag_cg == 1'b1)
    begin
      lsc_diag_aux_r <= {csr_wdata[31:30],
						 csr_wdata[`rv_lsc_diag_clf],
						 csr_wdata[`rv_lsc_diag_cei],
					     csr_wdata[`rv_lsc_diag_wei],	       
	                     csr_wdata[`rv_lsc_diag_e2e],
					     csr_wdata[`rv_lsc_diag_smi],
					     csr_wdata[`rv_lsc_diag_mei],
	                     csr_wdata[`rv_lsc_diag_lock_reset]};
    end
	else
    begin
	  lsc_diag_aux_r[`rv_diag_lock_reset_impl]  <= 2'b01;
	  lsc_diag_aux_r[`rv_diag_clf_impl]         <= 2'b01;
    end
  end
end

assign lsc_diag_aux_readback = {
                   lsc_diag_aux_r[`rv_diag_mode_enable_impl],
                   dr_sfty_eic,
                   lsc_diag_aux_r[`rv_diag_clf_impl],
				  {`rv_lsc_diag_reserved_msb{2'b01}},
				   lsc_diag_aux_r[`rv_diag_cei_error_impl],
               	   lsc_diag_aux_r[`rv_diag_wei_error_impl],
				   lsc_diag_aux_r[`rv_diag_e2e_error_impl],
				   lsc_diag_aux_r[`rv_diag_smi_error_impl],
				   lsc_diag_aux_r[`rv_diag_mei_error_impl],
				   lsc_diag_aux_r[`rv_diag_lock_reset_impl]	
				  };

always @(posedge clk or posedge rst_a)
begin : lsc_stl_ctrl_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    dr_lsc_stl_ctrl_aux_r   <= 2'b01;
  end
  else
  begin
    if (csr_stl_ctrl_cg == 1'b1)
    begin
      dr_lsc_stl_ctrl_aux_r <= csr_wdata[1:0];
    end
  end
end

reg [2:0] shdw_ckg_en_tmr_r;
always @(posedge clk or posedge rst_a)
begin : shdw_ckg_en_tmr_regs_PROC
  if (rst_a == 1'b1)
  begin
    shdw_ckg_en_tmr_r <= {3{1'b0}};
  end
  else
  begin
    if (csr_shd_ctrl_cg == 1'b1)
    begin
      shdw_ckg_en_tmr_r <= {3{csr_wdata[0]}};
    end
  end
end

DWbb_bcm00_maj #(
    .WIDTH   (1)
  ) 
u_shdw_ckg_en_tmr (
    .a   (shdw_ckg_en_tmr_r[0]),                                     
    .b   (shdw_ckg_en_tmr_r[1]),
    .c   (shdw_ckg_en_tmr_r[2]), 
    .z   (lsc_shd_ctrl_aux_r)
  );

  assign safety_comparator_enable = lsc_ctrl_aux_r[1:0];
// It's a parity error if the xor is not 1
  wire lsc_ctrl_aux_parity_error, lsc_diag_aux_parity_error, lsc_passwd_aux_parity_error, lsc_stl_aux_parity_error;
  assign lsc_ctrl_aux_parity_error  = (^(lsc_ctrl_aux_r[1:0])) ? 1'b0 : 1'b1;

  assign lsc_diag_aux_parity_error = 1'b0
                                   | ((^(lsc_diag_aux_r[`rv_diag_mode_enable_impl])) ? 1'b0 : 1'b1)
                                   | ((^(lsc_diag_aux_r[`rv_diag_clf_impl])) ? 1'b0 : 1'b1)
                                   | ((^(lsc_diag_aux_r[`rv_diag_cei_error_impl])) ? 1'b0 : 1'b1)
                                   | ((^(lsc_diag_aux_r[`rv_diag_wei_error_impl])) ? 1'b0 : 1'b1)
                                   | ((^(lsc_diag_aux_r[`rv_diag_e2e_error_impl])) ? 1'b0 : 1'b1)
                                   | ((^(lsc_diag_aux_r[`rv_diag_smi_error_impl])) ? 1'b0 : 1'b1)
                                   | ((^(lsc_diag_aux_r[`rv_diag_mei_error_impl])) ? 1'b0 : 1'b1)
                                   | ((^(lsc_diag_aux_r[`rv_diag_lock_reset_impl])) ? 1'b0 : 1'b1)
                                   ;
//PASSWD Parity
   assign lsc_passwd_aux_parity_error = ~(^lsc_passwd_aux_r);
   
   assign lsc_stl_aux_parity_error = ~(^dr_lsc_stl_ctrl_aux_r);
//
   wire sfty_aux_parity_err;
   assign sfty_aux_parity_err = 1'b0
                                  | lsc_ctrl_aux_parity_error
                                  | lsc_stl_aux_parity_error
				                  | lsc_diag_aux_parity_error
				                  | lsc_passwd_aux_parity_error
				    ;

always @(posedge clk or posedge rst_a)
begin : dr_sfty_aux_parity_err_r_PROC
  if (rst_a == 1'b1)
  begin
    dr_sfty_aux_parity_err_r  <= 2'b01;
  end
  else
  begin
    dr_sfty_aux_parity_err_r <= {sfty_aux_parity_err, ~sfty_aux_parity_err};		     
  end
end

always @(posedge clk or posedge rst_a)
begin : sfty_nsi_r_PROC
  if (rst_a == 1'b1)
  begin
    sfty_nsi_r  <= 1'b0;
  end
  else
  begin
    sfty_nsi_r <= safety_iso_enb_synch_r;	     
  end
end
endmodule // rl_sfty_csr

