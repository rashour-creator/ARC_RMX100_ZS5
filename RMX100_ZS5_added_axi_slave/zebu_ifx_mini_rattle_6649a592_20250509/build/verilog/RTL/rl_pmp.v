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
`include "csr_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_pmp (

  ////////// IFU PMP interface //////////////////////////////////////////////
  //
  input [`IFU_ADDR_RANGE]         ifu_addr0,             // IFU address0 
  
  output reg                      ipmp_hit0,             // hit on PMP 
  output reg [3:0]                ipmp_perm0,            // permission attributes vector (L, R, W, X)
  
  ////////// DMP PMP interface ////////////////////////////////////////////
  //
  input [`ADDR_RANGE]             dmp_addr,              // DMP address
  input                           cross_word,
  input [`ADDR_RANGE]             dmp_addr1,
  output reg                      cross_region,
  
  output reg                      dpmp_hit,              // hit on PMP 
  output reg [3:0]                dpmp_perm,             // permission attributes vector
  
  ////////// CSR interface ///////////////////////////////////////////////
  //
  input [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input [11:0]                    csr_sel_addr,          // (X1) CSR address
  input [1:0]                     priv_level_r,
  
  output reg [`DATA_RANGE]        csr_rdata,             // (X1) CSR read data
  output reg                      csr_illegal,           // (X1) illegal
  output reg                      csr_unimpl,            // (X1) Invalid CSR
  output reg                      csr_serial_sr,         // (X1) SR group flush pipe
  output reg                      csr_strict_sr,         // (X1) SR flush pipe
  
  input                           csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input [11:0]                    csr_waddr,             // (X2) CSR addr
  input [`DATA_RANGE]             csr_wdata,             // (X2) Write data
  
  input                           x2_pass,               // (X2) commit

  ////////// PMP Wrapper Interface //////////////////////////////////////////
  //
  input                           csr_cfg_ecg0,          // Lock overide from ePMP
  output                          any_lock,
  
  ////////// General input signals //////////////////////////////////////////
  //
  input                           clk,                   // clock signal
  input                           rst_a                  // reset signal
);

// Local Declarations
//
reg  [7:0]                pmp_cfg0_r_tmp;
wire [7:0]                pmp_cfg0_r;
reg  [7:0]                pmp_cfg1_r_tmp;
wire [7:0]                pmp_cfg1_r;
reg  [7:0]                pmp_cfg2_r_tmp;
wire [7:0]                pmp_cfg2_r;
reg  [7:0]                pmp_cfg3_r_tmp;
wire [7:0]                pmp_cfg3_r;
reg  [7:0]                pmp_cfg4_r_tmp;
wire [7:0]                pmp_cfg4_r;
reg  [7:0]                pmp_cfg5_r_tmp;
wire [7:0]                pmp_cfg5_r;
reg  [7:0]                pmp_cfg6_r_tmp;
wire [7:0]                pmp_cfg6_r;
reg  [7:0]                pmp_cfg7_r_tmp;
wire [7:0]                pmp_cfg7_r;
reg  [7:0]                pmp_cfg8_r_tmp;
wire [7:0]                pmp_cfg8_r;
reg  [7:0]                pmp_cfg9_r_tmp;
wire [7:0]                pmp_cfg9_r;
reg  [7:0]                pmp_cfg10_r_tmp;
wire [7:0]                pmp_cfg10_r;
reg  [7:0]                pmp_cfg11_r_tmp;
wire [7:0]                pmp_cfg11_r;
reg  [7:0]                pmp_cfg12_r_tmp;
wire [7:0]                pmp_cfg12_r;
reg  [7:0]                pmp_cfg13_r_tmp;
wire [7:0]                pmp_cfg13_r;
reg  [7:0]                pmp_cfg14_r_tmp;
wire [7:0]                pmp_cfg14_r;
reg  [7:0]                pmp_cfg15_r_tmp;
wire [7:0]                pmp_cfg15_r;
reg [`ADDR_RANGE]         pmp_addr0_r;
reg [`ADDR_RANGE]         pmp_addr1_r;
reg [`ADDR_RANGE]         pmp_addr2_r;
reg [`ADDR_RANGE]         pmp_addr3_r;
reg [`ADDR_RANGE]         pmp_addr4_r;
reg [`ADDR_RANGE]         pmp_addr5_r;
reg [`ADDR_RANGE]         pmp_addr6_r;
reg [`ADDR_RANGE]         pmp_addr7_r;
reg [`ADDR_RANGE]         pmp_addr8_r;
reg [`ADDR_RANGE]         pmp_addr9_r;
reg [`ADDR_RANGE]         pmp_addr10_r;
reg [`ADDR_RANGE]         pmp_addr11_r;
reg [`ADDR_RANGE]         pmp_addr12_r;
reg [`ADDR_RANGE]         pmp_addr13_r;
reg [`ADDR_RANGE]         pmp_addr14_r;
reg [`ADDR_RANGE]         pmp_addr15_r;
wire [`ADDR_RANGE]        pmp_addr0_mask;
wire [`ADDR_RANGE]        pmp_addr0_last;
wire [`ADDR_RANGE]        pmp_addr0_mask_temp;
wire [`ADDR_RANGE]        pmp_addr1_mask;
wire [`ADDR_RANGE]        pmp_addr1_last;
wire [`ADDR_RANGE]        pmp_addr1_mask_temp;
wire [`ADDR_RANGE]        pmp_addr2_mask;
wire [`ADDR_RANGE]        pmp_addr2_last;
wire [`ADDR_RANGE]        pmp_addr2_mask_temp;
wire [`ADDR_RANGE]        pmp_addr3_mask;
wire [`ADDR_RANGE]        pmp_addr3_last;
wire [`ADDR_RANGE]        pmp_addr3_mask_temp;
wire [`ADDR_RANGE]        pmp_addr4_mask;
wire [`ADDR_RANGE]        pmp_addr4_last;
wire [`ADDR_RANGE]        pmp_addr4_mask_temp;
wire [`ADDR_RANGE]        pmp_addr5_mask;
wire [`ADDR_RANGE]        pmp_addr5_last;
wire [`ADDR_RANGE]        pmp_addr5_mask_temp;
wire [`ADDR_RANGE]        pmp_addr6_mask;
wire [`ADDR_RANGE]        pmp_addr6_last;
wire [`ADDR_RANGE]        pmp_addr6_mask_temp;
wire [`ADDR_RANGE]        pmp_addr7_mask;
wire [`ADDR_RANGE]        pmp_addr7_last;
wire [`ADDR_RANGE]        pmp_addr7_mask_temp;
wire [`ADDR_RANGE]        pmp_addr8_mask;
wire [`ADDR_RANGE]        pmp_addr8_last;
wire [`ADDR_RANGE]        pmp_addr8_mask_temp;
wire [`ADDR_RANGE]        pmp_addr9_mask;
wire [`ADDR_RANGE]        pmp_addr9_last;
wire [`ADDR_RANGE]        pmp_addr9_mask_temp;
wire [`ADDR_RANGE]        pmp_addr10_mask;
wire [`ADDR_RANGE]        pmp_addr10_last;
wire [`ADDR_RANGE]        pmp_addr10_mask_temp;
wire [`ADDR_RANGE]        pmp_addr11_mask;
wire [`ADDR_RANGE]        pmp_addr11_last;
wire [`ADDR_RANGE]        pmp_addr11_mask_temp;
wire [`ADDR_RANGE]        pmp_addr12_mask;
wire [`ADDR_RANGE]        pmp_addr12_last;
wire [`ADDR_RANGE]        pmp_addr12_mask_temp;
wire [`ADDR_RANGE]        pmp_addr13_mask;
wire [`ADDR_RANGE]        pmp_addr13_last;
wire [`ADDR_RANGE]        pmp_addr13_mask_temp;
wire [`ADDR_RANGE]        pmp_addr14_mask;
wire [`ADDR_RANGE]        pmp_addr14_last;
wire [`ADDR_RANGE]        pmp_addr14_mask_temp;
wire [`ADDR_RANGE]        pmp_addr15_mask;
wire [`ADDR_RANGE]        pmp_addr15_last;
wire [`ADDR_RANGE]        pmp_addr15_mask_temp;
reg [`DATA_RANGE]         msec_cfg_hi_r;
reg [`DATA_RANGE]         msec_cfg_lo_r;

// Clock-gates
//
reg [`PMP_ENTRIES_RANGE]  csr_cfg_cg0;
reg [`PMP_ENTRIES_RANGE]  csr_addr_cg0;

reg                       csr_sec_hi_cg0;
reg                       csr_sec_lo_cg0;

wire                      csr_sel_write;

// The PMP CSRs live in this module
//


assign csr_sel_write = csr_sel_ctl[1];

//////////////////////////////////////////////////////////////////////////////
// Reads
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_read_PROC

  csr_rdata     = {`DATA_SIZE{1'b0}};             
  csr_illegal   = 1'b0;    
  csr_unimpl    = 1'b1;    
  csr_serial_sr = 1'b0; 
  csr_strict_sr = 1'b0;

  if (csr_sel_ctl != 2'b00)
  begin
    // PMP unit got selected
    //
    case (csr_sel_addr)
    `PMP_CFG0:
    begin
      csr_rdata      = {pmp_cfg3_r, pmp_cfg2_r, pmp_cfg1_r, pmp_cfg0_r};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_CFG1:
    begin
      csr_rdata      = {pmp_cfg7_r, pmp_cfg6_r, pmp_cfg5_r, pmp_cfg4_r};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_CFG2:
    begin
      csr_rdata      = {pmp_cfg11_r, pmp_cfg10_r, pmp_cfg9_r, pmp_cfg8_r};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_CFG3:
    begin
      csr_rdata      = {pmp_cfg15_r, pmp_cfg14_r, pmp_cfg13_r, pmp_cfg12_r};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR0:
    begin
      csr_rdata      = pmp_cfg0_r[4:3] == 2'b10 ? pmp_addr0_r : (pmp_cfg0_r[4] ? 
			{pmp_addr0_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr0_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR1:
    begin
      csr_rdata      = pmp_cfg1_r[4:3] == 2'b10 ? pmp_addr1_r : (pmp_cfg1_r[4] ? 
			{pmp_addr1_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr1_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR2:
    begin
      csr_rdata      = pmp_cfg2_r[4:3] == 2'b10 ? pmp_addr2_r : (pmp_cfg2_r[4] ? 
			{pmp_addr2_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr2_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR3:
    begin
      csr_rdata      = pmp_cfg3_r[4:3] == 2'b10 ? pmp_addr3_r : (pmp_cfg3_r[4] ? 
			{pmp_addr3_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr3_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR4:
    begin
      csr_rdata      = pmp_cfg4_r[4:3] == 2'b10 ? pmp_addr4_r : (pmp_cfg4_r[4] ? 
			{pmp_addr4_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr4_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR5:
    begin
      csr_rdata      = pmp_cfg5_r[4:3] == 2'b10 ? pmp_addr5_r : (pmp_cfg5_r[4] ? 
			{pmp_addr5_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr5_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR6:
    begin
      csr_rdata      = pmp_cfg6_r[4:3] == 2'b10 ? pmp_addr6_r : (pmp_cfg6_r[4] ? 
			{pmp_addr6_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr6_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR7:
    begin
      csr_rdata      = pmp_cfg7_r[4:3] == 2'b10 ? pmp_addr7_r : (pmp_cfg7_r[4] ? 
			{pmp_addr7_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr7_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR8:
    begin
      csr_rdata      = pmp_cfg8_r[4:3] == 2'b10 ? pmp_addr8_r : (pmp_cfg8_r[4] ? 
			{pmp_addr8_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr8_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR9:
    begin
      csr_rdata      = pmp_cfg9_r[4:3] == 2'b10 ? pmp_addr9_r : (pmp_cfg9_r[4] ? 
			{pmp_addr9_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr9_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR10:
    begin
      csr_rdata      = pmp_cfg10_r[4:3] == 2'b10 ? pmp_addr10_r : (pmp_cfg10_r[4] ? 
			{pmp_addr10_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr10_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR11:
    begin
      csr_rdata      = pmp_cfg11_r[4:3] == 2'b10 ? pmp_addr11_r : (pmp_cfg11_r[4] ? 
			{pmp_addr11_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr11_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR12:
    begin
      csr_rdata      = pmp_cfg12_r[4:3] == 2'b10 ? pmp_addr12_r : (pmp_cfg12_r[4] ? 
			{pmp_addr12_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr12_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR13:
    begin
      csr_rdata      = pmp_cfg13_r[4:3] == 2'b10 ? pmp_addr13_r : (pmp_cfg13_r[4] ? 
			{pmp_addr13_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr13_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR14:
    begin
      csr_rdata      = pmp_cfg14_r[4:3] == 2'b10 ? pmp_addr14_r : (pmp_cfg14_r[4] ? 
			{pmp_addr14_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr14_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
    `PMP_ADDR15:
    begin
      csr_rdata      = pmp_cfg15_r[4:3] == 2'b10 ? pmp_addr15_r : (pmp_cfg15_r[4] ? 
			{pmp_addr15_r[31:2], 2'b11}
	      
	      		:
			{pmp_addr15_r[31:3], 3'b0}
            )
	      ;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
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
  csr_cfg_cg0   = {`PMP_ENTRIES{1'b0}};
  csr_addr_cg0  = {`PMP_ENTRIES{1'b0}};    
  csr_sec_hi_cg0 = 1'b0;
  csr_sec_lo_cg0 = 1'b0;
  
  case (csr_waddr)
  `PMP_CFG0:
  begin
    csr_cfg_cg0[0] = csr_write & x2_pass & (!pmp_cfg0_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[1] = csr_write & x2_pass & (!pmp_cfg1_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[2] = csr_write & x2_pass & (!pmp_cfg2_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[3] = csr_write & x2_pass & (!pmp_cfg3_r[7] | csr_cfg_ecg0);
  end
    
  `PMP_CFG1:
  begin
    csr_cfg_cg0[4] = csr_write & x2_pass & (!pmp_cfg4_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[5] = csr_write & x2_pass & (!pmp_cfg5_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[6] = csr_write & x2_pass & (!pmp_cfg6_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[7] = csr_write & x2_pass & (!pmp_cfg7_r[7] | csr_cfg_ecg0);
  end
    
  `PMP_CFG2:
  begin
    csr_cfg_cg0[8] = csr_write & x2_pass & (!pmp_cfg8_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[9] = csr_write & x2_pass & (!pmp_cfg9_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[10] = csr_write & x2_pass & (!pmp_cfg10_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[11] = csr_write & x2_pass & (!pmp_cfg11_r[7] | csr_cfg_ecg0);
  end
    
  `PMP_CFG3:
  begin
    csr_cfg_cg0[12] = csr_write & x2_pass & (!pmp_cfg12_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[13] = csr_write & x2_pass & (!pmp_cfg13_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[14] = csr_write & x2_pass & (!pmp_cfg14_r[7] | csr_cfg_ecg0);
    csr_cfg_cg0[15] = csr_write & x2_pass & (!pmp_cfg15_r[7] | csr_cfg_ecg0);
  end
    
  `PMP_ADDR0:
  begin
    csr_addr_cg0[0] = csr_write & x2_pass & (!(pmp_cfg0_r[7] | (pmp_cfg1_r[7] & (pmp_cfg1_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR1:
  begin
    csr_addr_cg0[1] = csr_write & x2_pass & (!(pmp_cfg1_r[7] | (pmp_cfg2_r[7] & (pmp_cfg2_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR2:
  begin
    csr_addr_cg0[2] = csr_write & x2_pass & (!(pmp_cfg2_r[7] | (pmp_cfg3_r[7] & (pmp_cfg3_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR3:
  begin
    csr_addr_cg0[3] = csr_write & x2_pass & (!(pmp_cfg3_r[7] | (pmp_cfg4_r[7] & (pmp_cfg4_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR4:
  begin
    csr_addr_cg0[4] = csr_write & x2_pass & (!(pmp_cfg4_r[7] | (pmp_cfg5_r[7] & (pmp_cfg5_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR5:
  begin
    csr_addr_cg0[5] = csr_write & x2_pass & (!(pmp_cfg5_r[7] | (pmp_cfg6_r[7] & (pmp_cfg6_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR6:
  begin
    csr_addr_cg0[6] = csr_write & x2_pass & (!(pmp_cfg6_r[7] | (pmp_cfg7_r[7] & (pmp_cfg7_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR7:
  begin
    csr_addr_cg0[7] = csr_write & x2_pass & (!(pmp_cfg7_r[7] | (pmp_cfg8_r[7] & (pmp_cfg8_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR8:
  begin
    csr_addr_cg0[8] = csr_write & x2_pass & (!(pmp_cfg8_r[7] | (pmp_cfg9_r[7] & (pmp_cfg9_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR9:
  begin
    csr_addr_cg0[9] = csr_write & x2_pass & (!(pmp_cfg9_r[7] | (pmp_cfg10_r[7] & (pmp_cfg10_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR10:
  begin
    csr_addr_cg0[10] = csr_write & x2_pass & (!(pmp_cfg10_r[7] | (pmp_cfg11_r[7] & (pmp_cfg11_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR11:
  begin
    csr_addr_cg0[11] = csr_write & x2_pass & (!(pmp_cfg11_r[7] | (pmp_cfg12_r[7] & (pmp_cfg12_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR12:
  begin
    csr_addr_cg0[12] = csr_write & x2_pass & (!(pmp_cfg12_r[7] | (pmp_cfg13_r[7] & (pmp_cfg13_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR13:
  begin
    csr_addr_cg0[13] = csr_write & x2_pass & (!(pmp_cfg13_r[7] | (pmp_cfg14_r[7] & (pmp_cfg14_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR14:
  begin
    csr_addr_cg0[14] = csr_write & x2_pass & (!(pmp_cfg14_r[7] | (pmp_cfg15_r[7] & (pmp_cfg15_r[4:3] == 2'b01) )) | csr_cfg_ecg0);
  end
  
  `PMP_ADDR15:
  begin
    csr_addr_cg0[15] = csr_write & x2_pass & (!pmp_cfg15_r[7] | csr_cfg_ecg0);
  end


  default:
  begin
    csr_cfg_cg0   = {`PMP_ENTRIES{1'b0}};
    csr_addr_cg0  = {`PMP_ENTRIES{1'b0}};
  end
  endcase
end



// Helpers
//
wire [1:0] pmp_addr_mode_entry0;

assign pmp_addr_mode_entry0  = (pmp_cfg0_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg0_r[4:3];
assign pmp_addr0_mask_temp = ~({pmp_addr0_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr0_r[31:2], 2'b11};
assign pmp_addr0_last = ({pmp_addr0_r[31:2], 2'b11} + 32'b1) | {pmp_addr0_r[31:2], 2'b11};
assign pmp_addr0_mask = (pmp_addr0_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr0_mask_temp;


wire [1:0] pmp_addr_mode_entry1;

assign pmp_addr_mode_entry1  = (pmp_cfg1_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg1_r[4:3];
assign pmp_addr1_mask_temp = ~({pmp_addr1_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr1_r[31:2], 2'b11};
assign pmp_addr1_last = ({pmp_addr1_r[31:2], 2'b11} + 32'b1) | {pmp_addr1_r[31:2], 2'b11};
assign pmp_addr1_mask = (pmp_addr1_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr1_mask_temp;


wire [1:0] pmp_addr_mode_entry2;

assign pmp_addr_mode_entry2  = (pmp_cfg2_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg2_r[4:3];
assign pmp_addr2_mask_temp = ~({pmp_addr2_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr2_r[31:2], 2'b11};
assign pmp_addr2_last = ({pmp_addr2_r[31:2], 2'b11} + 32'b1) | {pmp_addr2_r[31:2], 2'b11};
assign pmp_addr2_mask = (pmp_addr2_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr2_mask_temp;


wire [1:0] pmp_addr_mode_entry3;

assign pmp_addr_mode_entry3  = (pmp_cfg3_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg3_r[4:3];
assign pmp_addr3_mask_temp = ~({pmp_addr3_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr3_r[31:2], 2'b11};
assign pmp_addr3_last = ({pmp_addr3_r[31:2], 2'b11} + 32'b1) | {pmp_addr3_r[31:2], 2'b11};
assign pmp_addr3_mask = (pmp_addr3_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr3_mask_temp;


wire [1:0] pmp_addr_mode_entry4;

assign pmp_addr_mode_entry4  = (pmp_cfg4_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg4_r[4:3];
assign pmp_addr4_mask_temp = ~({pmp_addr4_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr4_r[31:2], 2'b11};
assign pmp_addr4_last = ({pmp_addr4_r[31:2], 2'b11} + 32'b1) | {pmp_addr4_r[31:2], 2'b11};
assign pmp_addr4_mask = (pmp_addr4_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr4_mask_temp;


wire [1:0] pmp_addr_mode_entry5;

assign pmp_addr_mode_entry5  = (pmp_cfg5_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg5_r[4:3];
assign pmp_addr5_mask_temp = ~({pmp_addr5_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr5_r[31:2], 2'b11};
assign pmp_addr5_last = ({pmp_addr5_r[31:2], 2'b11} + 32'b1) | {pmp_addr5_r[31:2], 2'b11};
assign pmp_addr5_mask = (pmp_addr5_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr5_mask_temp;


wire [1:0] pmp_addr_mode_entry6;

assign pmp_addr_mode_entry6  = (pmp_cfg6_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg6_r[4:3];
assign pmp_addr6_mask_temp = ~({pmp_addr6_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr6_r[31:2], 2'b11};
assign pmp_addr6_last = ({pmp_addr6_r[31:2], 2'b11} + 32'b1) | {pmp_addr6_r[31:2], 2'b11};
assign pmp_addr6_mask = (pmp_addr6_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr6_mask_temp;


wire [1:0] pmp_addr_mode_entry7;

assign pmp_addr_mode_entry7  = (pmp_cfg7_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg7_r[4:3];
assign pmp_addr7_mask_temp = ~({pmp_addr7_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr7_r[31:2], 2'b11};
assign pmp_addr7_last = ({pmp_addr7_r[31:2], 2'b11} + 32'b1) | {pmp_addr7_r[31:2], 2'b11};
assign pmp_addr7_mask = (pmp_addr7_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr7_mask_temp;


wire [1:0] pmp_addr_mode_entry8;

assign pmp_addr_mode_entry8  = (pmp_cfg8_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg8_r[4:3];
assign pmp_addr8_mask_temp = ~({pmp_addr8_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr8_r[31:2], 2'b11};
assign pmp_addr8_last = ({pmp_addr8_r[31:2], 2'b11} + 32'b1) | {pmp_addr8_r[31:2], 2'b11};
assign pmp_addr8_mask = (pmp_addr8_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr8_mask_temp;


wire [1:0] pmp_addr_mode_entry9;

assign pmp_addr_mode_entry9  = (pmp_cfg9_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg9_r[4:3];
assign pmp_addr9_mask_temp = ~({pmp_addr9_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr9_r[31:2], 2'b11};
assign pmp_addr9_last = ({pmp_addr9_r[31:2], 2'b11} + 32'b1) | {pmp_addr9_r[31:2], 2'b11};
assign pmp_addr9_mask = (pmp_addr9_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr9_mask_temp;


wire [1:0] pmp_addr_mode_entry10;

assign pmp_addr_mode_entry10  = (pmp_cfg10_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg10_r[4:3];
assign pmp_addr10_mask_temp = ~({pmp_addr10_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr10_r[31:2], 2'b11};
assign pmp_addr10_last = ({pmp_addr10_r[31:2], 2'b11} + 32'b1) | {pmp_addr10_r[31:2], 2'b11};
assign pmp_addr10_mask = (pmp_addr10_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr10_mask_temp;


wire [1:0] pmp_addr_mode_entry11;

assign pmp_addr_mode_entry11  = (pmp_cfg11_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg11_r[4:3];
assign pmp_addr11_mask_temp = ~({pmp_addr11_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr11_r[31:2], 2'b11};
assign pmp_addr11_last = ({pmp_addr11_r[31:2], 2'b11} + 32'b1) | {pmp_addr11_r[31:2], 2'b11};
assign pmp_addr11_mask = (pmp_addr11_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr11_mask_temp;


wire [1:0] pmp_addr_mode_entry12;

assign pmp_addr_mode_entry12  = (pmp_cfg12_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg12_r[4:3];
assign pmp_addr12_mask_temp = ~({pmp_addr12_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr12_r[31:2], 2'b11};
assign pmp_addr12_last = ({pmp_addr12_r[31:2], 2'b11} + 32'b1) | {pmp_addr12_r[31:2], 2'b11};
assign pmp_addr12_mask = (pmp_addr12_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr12_mask_temp;


wire [1:0] pmp_addr_mode_entry13;

assign pmp_addr_mode_entry13  = (pmp_cfg13_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg13_r[4:3];
assign pmp_addr13_mask_temp = ~({pmp_addr13_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr13_r[31:2], 2'b11};
assign pmp_addr13_last = ({pmp_addr13_r[31:2], 2'b11} + 32'b1) | {pmp_addr13_r[31:2], 2'b11};
assign pmp_addr13_mask = (pmp_addr13_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr13_mask_temp;


wire [1:0] pmp_addr_mode_entry14;

assign pmp_addr_mode_entry14  = (pmp_cfg14_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg14_r[4:3];
assign pmp_addr14_mask_temp = ~({pmp_addr14_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr14_r[31:2], 2'b11};
assign pmp_addr14_last = ({pmp_addr14_r[31:2], 2'b11} + 32'b1) | {pmp_addr14_r[31:2], 2'b11};
assign pmp_addr14_mask = (pmp_addr14_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr14_mask_temp;


wire [1:0] pmp_addr_mode_entry15;

assign pmp_addr_mode_entry15  = (pmp_cfg15_r[4:3] == 2'b10) ? 2'b0 : pmp_cfg15_r[4:3];
assign pmp_addr15_mask_temp = ~({pmp_addr15_r[31:2], 2'b11} + 32'b1) ^ {pmp_addr15_r[31:2], 2'b11};
assign pmp_addr15_last = ({pmp_addr15_r[31:2], 2'b11} + 32'b1) | {pmp_addr15_r[31:2], 2'b11};
assign pmp_addr15_mask = (pmp_addr15_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pmp_addr15_mask_temp;



assign any_lock = 1'b0
                  | pmp_cfg0_r[7]
                  | pmp_cfg1_r[7]
                  | pmp_cfg2_r[7]
                  | pmp_cfg3_r[7]
                  | pmp_cfg4_r[7]
                  | pmp_cfg5_r[7]
                  | pmp_cfg6_r[7]
                  | pmp_cfg7_r[7]
                  | pmp_cfg8_r[7]
                  | pmp_cfg9_r[7]
                  | pmp_cfg10_r[7]
                  | pmp_cfg11_r[7]
                  | pmp_cfg12_r[7]
                  | pmp_cfg13_r[7]
                  | pmp_cfg14_r[7]
                  | pmp_cfg15_r[7]
                    ;

reg     cross_region0;
reg     cross_region1;
reg     cross_region2;
reg     cross_region3;
reg     cross_region4;
reg     cross_region5;
reg     cross_region6;
reg     cross_region7;
reg     cross_region8;
reg     cross_region9;
reg     cross_region10;
reg     cross_region11;
reg     cross_region12;
reg     cross_region13;
reg     cross_region14;
reg     cross_region15;

always @*
begin: cross_region0_PROC
    case (pmp_addr_mode_entry0)
        2'b01:
        begin
            cross_region0 = (dmp_addr1[31:2] == {pmp_addr0_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region0 = (dmp_addr[31:2] == pmp_addr0_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region0 = (dmp_addr[31:2] == pmp_addr0_last[29:0]) & cross_word;
        end
        default: cross_region0 = 1'b0;
    endcase
end
always @*
begin: cross_region1_PROC
    case (pmp_addr_mode_entry1)
        2'b01:
        begin
            cross_region1 = (dmp_addr1[31:2] == {pmp_addr1_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region1 = (dmp_addr[31:2] == pmp_addr1_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region1 = (dmp_addr[31:2] == pmp_addr1_last[29:0]) & cross_word;
        end
        default: cross_region1 = 1'b0;
    endcase
end
always @*
begin: cross_region2_PROC
    case (pmp_addr_mode_entry2)
        2'b01:
        begin
            cross_region2 = (dmp_addr1[31:2] == {pmp_addr2_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region2 = (dmp_addr[31:2] == pmp_addr2_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region2 = (dmp_addr[31:2] == pmp_addr2_last[29:0]) & cross_word;
        end
        default: cross_region2 = 1'b0;
    endcase
end
always @*
begin: cross_region3_PROC
    case (pmp_addr_mode_entry3)
        2'b01:
        begin
            cross_region3 = (dmp_addr1[31:2] == {pmp_addr3_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region3 = (dmp_addr[31:2] == pmp_addr3_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region3 = (dmp_addr[31:2] == pmp_addr3_last[29:0]) & cross_word;
        end
        default: cross_region3 = 1'b0;
    endcase
end
always @*
begin: cross_region4_PROC
    case (pmp_addr_mode_entry4)
        2'b01:
        begin
            cross_region4 = (dmp_addr1[31:2] == {pmp_addr4_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region4 = (dmp_addr[31:2] == pmp_addr4_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region4 = (dmp_addr[31:2] == pmp_addr4_last[29:0]) & cross_word;
        end
        default: cross_region4 = 1'b0;
    endcase
end
always @*
begin: cross_region5_PROC
    case (pmp_addr_mode_entry5)
        2'b01:
        begin
            cross_region5 = (dmp_addr1[31:2] == {pmp_addr5_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region5 = (dmp_addr[31:2] == pmp_addr5_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region5 = (dmp_addr[31:2] == pmp_addr5_last[29:0]) & cross_word;
        end
        default: cross_region5 = 1'b0;
    endcase
end
always @*
begin: cross_region6_PROC
    case (pmp_addr_mode_entry6)
        2'b01:
        begin
            cross_region6 = (dmp_addr1[31:2] == {pmp_addr6_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region6 = (dmp_addr[31:2] == pmp_addr6_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region6 = (dmp_addr[31:2] == pmp_addr6_last[29:0]) & cross_word;
        end
        default: cross_region6 = 1'b0;
    endcase
end
always @*
begin: cross_region7_PROC
    case (pmp_addr_mode_entry7)
        2'b01:
        begin
            cross_region7 = (dmp_addr1[31:2] == {pmp_addr7_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region7 = (dmp_addr[31:2] == pmp_addr7_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region7 = (dmp_addr[31:2] == pmp_addr7_last[29:0]) & cross_word;
        end
        default: cross_region7 = 1'b0;
    endcase
end
always @*
begin: cross_region8_PROC
    case (pmp_addr_mode_entry8)
        2'b01:
        begin
            cross_region8 = (dmp_addr1[31:2] == {pmp_addr8_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region8 = (dmp_addr[31:2] == pmp_addr8_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region8 = (dmp_addr[31:2] == pmp_addr8_last[29:0]) & cross_word;
        end
        default: cross_region8 = 1'b0;
    endcase
end
always @*
begin: cross_region9_PROC
    case (pmp_addr_mode_entry9)
        2'b01:
        begin
            cross_region9 = (dmp_addr1[31:2] == {pmp_addr9_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region9 = (dmp_addr[31:2] == pmp_addr9_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region9 = (dmp_addr[31:2] == pmp_addr9_last[29:0]) & cross_word;
        end
        default: cross_region9 = 1'b0;
    endcase
end
always @*
begin: cross_region10_PROC
    case (pmp_addr_mode_entry10)
        2'b01:
        begin
            cross_region10 = (dmp_addr1[31:2] == {pmp_addr10_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region10 = (dmp_addr[31:2] == pmp_addr10_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region10 = (dmp_addr[31:2] == pmp_addr10_last[29:0]) & cross_word;
        end
        default: cross_region10 = 1'b0;
    endcase
end
always @*
begin: cross_region11_PROC
    case (pmp_addr_mode_entry11)
        2'b01:
        begin
            cross_region11 = (dmp_addr1[31:2] == {pmp_addr11_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region11 = (dmp_addr[31:2] == pmp_addr11_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region11 = (dmp_addr[31:2] == pmp_addr11_last[29:0]) & cross_word;
        end
        default: cross_region11 = 1'b0;
    endcase
end
always @*
begin: cross_region12_PROC
    case (pmp_addr_mode_entry12)
        2'b01:
        begin
            cross_region12 = (dmp_addr1[31:2] == {pmp_addr12_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region12 = (dmp_addr[31:2] == pmp_addr12_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region12 = (dmp_addr[31:2] == pmp_addr12_last[29:0]) & cross_word;
        end
        default: cross_region12 = 1'b0;
    endcase
end
always @*
begin: cross_region13_PROC
    case (pmp_addr_mode_entry13)
        2'b01:
        begin
            cross_region13 = (dmp_addr1[31:2] == {pmp_addr13_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region13 = (dmp_addr[31:2] == pmp_addr13_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region13 = (dmp_addr[31:2] == pmp_addr13_last[29:0]) & cross_word;
        end
        default: cross_region13 = 1'b0;
    endcase
end
always @*
begin: cross_region14_PROC
    case (pmp_addr_mode_entry14)
        2'b01:
        begin
            cross_region14 = (dmp_addr1[31:2] == {pmp_addr14_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region14 = (dmp_addr[31:2] == pmp_addr14_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region14 = (dmp_addr[31:2] == pmp_addr14_last[29:0]) & cross_word;
        end
        default: cross_region14 = 1'b0;
    endcase
end
always @*
begin: cross_region15_PROC
    case (pmp_addr_mode_entry15)
        2'b01:
        begin
            cross_region15 = (dmp_addr1[31:2] == {pmp_addr15_r[29:3], 3'b0}) & cross_word;
        end
        2'b10:
        begin
            cross_region15 = (dmp_addr[31:2] == pmp_addr15_r[29:0]) & cross_word;
        end
        2'b11:
        begin
            cross_region15 = (dmp_addr[31:2] == pmp_addr15_last[29:0]) & cross_word;
        end
        default: cross_region15 = 1'b0;
    endcase
end


wire [`PMP_ENTRIES_RANGE] pmp_ifu_hit0;
wire [`PMP_ENTRIES_RANGE] pmp_dmp_hit;

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u0_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr0_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev ({`COMP_WIDTH{1'b0}}),
   .pmp_addr_mask (pmp_addr0_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry0),
   
   .pmp_hit       (pmp_ifu_hit0[0])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u0_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr0_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev ({`COMP_WIDTH{1'b0}}),
   .pmp_addr_mask (pmp_addr0_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry0),
   
   .pmp_hit       (pmp_dmp_hit[0])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u1_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr1_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr0_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr1_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry1),
   
   .pmp_hit       (pmp_ifu_hit0[1])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u1_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr1_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr0_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr1_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry1),
   
   .pmp_hit       (pmp_dmp_hit[1])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u2_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr2_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr1_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr2_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry2),
   
   .pmp_hit       (pmp_ifu_hit0[2])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u2_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr2_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr1_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr2_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry2),
   
   .pmp_hit       (pmp_dmp_hit[2])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u3_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr3_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr2_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr3_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry3),
   
   .pmp_hit       (pmp_ifu_hit0[3])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u3_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr3_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr2_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr3_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry3),
   
   .pmp_hit       (pmp_dmp_hit[3])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u4_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr4_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr3_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr4_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry4),
   
   .pmp_hit       (pmp_ifu_hit0[4])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u4_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr4_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr3_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr4_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry4),
   
   .pmp_hit       (pmp_dmp_hit[4])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u5_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr5_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr4_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr5_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry5),
   
   .pmp_hit       (pmp_ifu_hit0[5])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u5_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr5_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr4_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr5_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry5),
   
   .pmp_hit       (pmp_dmp_hit[5])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u6_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr6_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr5_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr6_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry6),
   
   .pmp_hit       (pmp_ifu_hit0[6])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u6_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr6_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr5_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr6_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry6),
   
   .pmp_hit       (pmp_dmp_hit[6])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u7_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr7_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr6_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr7_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry7),
   
   .pmp_hit       (pmp_ifu_hit0[7])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u7_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr7_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr6_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr7_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry7),
   
   .pmp_hit       (pmp_dmp_hit[7])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u8_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr8_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr7_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr8_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry8),
   
   .pmp_hit       (pmp_ifu_hit0[8])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u8_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr8_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr7_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr8_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry8),
   
   .pmp_hit       (pmp_dmp_hit[8])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u9_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr9_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr8_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr9_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry9),
   
   .pmp_hit       (pmp_ifu_hit0[9])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u9_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr9_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr8_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr9_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry9),
   
   .pmp_hit       (pmp_dmp_hit[9])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u10_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr10_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr9_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr10_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry10),
   
   .pmp_hit       (pmp_ifu_hit0[10])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u10_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr10_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr9_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr10_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry10),
   
   .pmp_hit       (pmp_dmp_hit[10])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u11_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr11_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr10_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr11_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry11),
   
   .pmp_hit       (pmp_ifu_hit0[11])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u11_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr11_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr10_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr11_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry11),
   
   .pmp_hit       (pmp_dmp_hit[11])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u12_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr12_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr11_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr12_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry12),
   
   .pmp_hit       (pmp_ifu_hit0[12])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u12_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr12_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr11_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr12_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry12),
   
   .pmp_hit       (pmp_dmp_hit[12])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u13_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr13_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr12_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr13_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry13),
   
   .pmp_hit       (pmp_ifu_hit0[13])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u13_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr13_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr12_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr13_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry13),
   
   .pmp_hit       (pmp_dmp_hit[13])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u14_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr14_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr13_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr14_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry14),
   
   .pmp_hit       (pmp_ifu_hit0[14])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u14_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr14_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr13_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr14_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry14),
   
   .pmp_hit       (pmp_dmp_hit[14])
);

rl_pmp_hit # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u15_pmp_hit0  (
   .addr          (ifu_addr0[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr15_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),  
   .pmp_addr_prev (pmp_addr14_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr15_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry15),
   
   .pmp_hit       (pmp_ifu_hit0[15])
);


rl_pmp_hit  # (
  .PMP_LEN       (`COMP_WIDTH)
  ) u15_pmp_hit2 (
   .addr          (dmp_addr[`IN_ADDR_MSB:`IN_ADDR_LSB]), 
   
   .pmp_addr      (pmp_addr15_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_prev (pmp_addr14_r[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mask (pmp_addr15_mask[`REG_ADDR_MSB:`REG_ADDR_LSB]),
   .pmp_addr_mode (pmp_addr_mode_entry15),
   
   .pmp_hit       (pmp_dmp_hit[15])
);



wire [3:0] pmp_perm_entry0;

assign pmp_perm_entry0  = {pmp_cfg0_r[7],  pmp_cfg0_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry1;

assign pmp_perm_entry1  = {pmp_cfg1_r[7],  pmp_cfg1_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry2;

assign pmp_perm_entry2  = {pmp_cfg2_r[7],  pmp_cfg2_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry3;

assign pmp_perm_entry3  = {pmp_cfg3_r[7],  pmp_cfg3_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry4;

assign pmp_perm_entry4  = {pmp_cfg4_r[7],  pmp_cfg4_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry5;

assign pmp_perm_entry5  = {pmp_cfg5_r[7],  pmp_cfg5_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry6;

assign pmp_perm_entry6  = {pmp_cfg6_r[7],  pmp_cfg6_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry7;

assign pmp_perm_entry7  = {pmp_cfg7_r[7],  pmp_cfg7_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry8;

assign pmp_perm_entry8  = {pmp_cfg8_r[7],  pmp_cfg8_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry9;

assign pmp_perm_entry9  = {pmp_cfg9_r[7],  pmp_cfg9_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry10;

assign pmp_perm_entry10  = {pmp_cfg10_r[7],  pmp_cfg10_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry11;

assign pmp_perm_entry11  = {pmp_cfg11_r[7],  pmp_cfg11_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry12;

assign pmp_perm_entry12  = {pmp_cfg12_r[7],  pmp_cfg12_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry13;

assign pmp_perm_entry13  = {pmp_cfg13_r[7],  pmp_cfg13_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry14;

assign pmp_perm_entry14  = {pmp_cfg14_r[7],  pmp_cfg14_r[2:0]};    // {L, X, W, R} 
wire [3:0] pmp_perm_entry15;

assign pmp_perm_entry15  = {pmp_cfg15_r[7],  pmp_cfg15_r[2:0]};    // {L, X, W, R} 

// Priority encoders 
//

always @*
begin : pmp_ifu_hit_priority_PROC
  // Default values
  //
  ipmp_hit0  = 1'b0;
  ipmp_perm0 = 4'b0;            // permission attributes vector (L, R, W, X)
  
  case (1'b1)
  pmp_ifu_hit0[0]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry0;
  end

  pmp_ifu_hit0[1]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry1;
  end

  pmp_ifu_hit0[2]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry2;
  end

  pmp_ifu_hit0[3]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry3;
  end

  pmp_ifu_hit0[4]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry4;
  end

  pmp_ifu_hit0[5]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry5;
  end

  pmp_ifu_hit0[6]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry6;
  end

  pmp_ifu_hit0[7]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry7;
  end

  pmp_ifu_hit0[8]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry8;
  end

  pmp_ifu_hit0[9]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry9;
  end

  pmp_ifu_hit0[10]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry10;
  end

  pmp_ifu_hit0[11]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry11;
  end

  pmp_ifu_hit0[12]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry12;
  end

  pmp_ifu_hit0[13]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry13;
  end

  pmp_ifu_hit0[14]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry14;
  end

  pmp_ifu_hit0[15]:
  begin
    ipmp_hit0  = 1'b1;
    ipmp_perm0 = pmp_perm_entry15;
  end

  default:
  begin
    ipmp_hit0  = 1'b0;
    ipmp_perm0 = 4'b0;  
  end
  endcase
  
end


always @*
begin : pmp_dmp_hit_priority_PROC
  // Default values
  //
  dpmp_hit     = 1'b0;
  dpmp_perm    = 4'b0; 
  cross_region = 1'b0;
  
  case (1'b1)
  pmp_dmp_hit[0]:
  begin
    cross_region = cross_region0;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry0;
  end

  pmp_dmp_hit[1]:
  begin
    cross_region = cross_region1;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry1;
  end

  pmp_dmp_hit[2]:
  begin
    cross_region = cross_region2;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry2;
  end

  pmp_dmp_hit[3]:
  begin
    cross_region = cross_region3;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry3;
  end

  pmp_dmp_hit[4]:
  begin
    cross_region = cross_region4;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry4;
  end

  pmp_dmp_hit[5]:
  begin
    cross_region = cross_region5;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry5;
  end

  pmp_dmp_hit[6]:
  begin
    cross_region = cross_region6;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry6;
  end

  pmp_dmp_hit[7]:
  begin
    cross_region = cross_region7;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry7;
  end

  pmp_dmp_hit[8]:
  begin
    cross_region = cross_region8;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry8;
  end

  pmp_dmp_hit[9]:
  begin
    cross_region = cross_region9;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry9;
  end

  pmp_dmp_hit[10]:
  begin
    cross_region = cross_region10;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry10;
  end

  pmp_dmp_hit[11]:
  begin
    cross_region = cross_region11;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry11;
  end

  pmp_dmp_hit[12]:
  begin
    cross_region = cross_region12;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry12;
  end

  pmp_dmp_hit[13]:
  begin
    cross_region = cross_region13;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry13;
  end

  pmp_dmp_hit[14]:
  begin
    cross_region = cross_region14;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry14;
  end

  pmp_dmp_hit[15]:
  begin
    cross_region = cross_region15;
    dpmp_hit     = 1'b1;
    dpmp_perm    = pmp_perm_entry15;
  end

  default:
  begin
    dpmp_hit     = 1'b0;
    dpmp_perm    = 4'b0;  
    cross_region = 1'b0;
  end
  endcase
end


//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : pmp_cfg0_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg0_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[0] == 1'b1)
    begin
      pmp_cfg0_r_tmp <= csr_wdata[7:0];
    end
  
  end
end

assign pmp_cfg0_r = {pmp_cfg0_r_tmp[7], 2'b0, pmp_cfg0_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg1_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg1_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[1] == 1'b1)
    begin
      pmp_cfg1_r_tmp <= csr_wdata[15:8];
    end
  
  end
end

assign pmp_cfg1_r = {pmp_cfg1_r_tmp[7], 2'b0, pmp_cfg1_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg2_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg2_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[2] == 1'b1)
    begin
      pmp_cfg2_r_tmp <= csr_wdata[23:16];
    end
  
  end
end

assign pmp_cfg2_r = {pmp_cfg2_r_tmp[7], 2'b0, pmp_cfg2_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg3_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg3_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[3] == 1'b1)
    begin
      pmp_cfg3_r_tmp <= csr_wdata[31:24];
    end
  
  end
end

assign pmp_cfg3_r = {pmp_cfg3_r_tmp[7], 2'b0, pmp_cfg3_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg4_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg4_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[4] == 1'b1)
    begin
      pmp_cfg4_r_tmp <= csr_wdata[7:0];
    end
  
  end
end

assign pmp_cfg4_r = {pmp_cfg4_r_tmp[7], 2'b0, pmp_cfg4_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg5_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg5_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[5] == 1'b1)
    begin
      pmp_cfg5_r_tmp <= csr_wdata[15:8];
    end
  
  end
end

assign pmp_cfg5_r = {pmp_cfg5_r_tmp[7], 2'b0, pmp_cfg5_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg6_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg6_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[6] == 1'b1)
    begin
      pmp_cfg6_r_tmp <= csr_wdata[23:16];
    end
  
  end
end

assign pmp_cfg6_r = {pmp_cfg6_r_tmp[7], 2'b0, pmp_cfg6_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg7_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg7_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[7] == 1'b1)
    begin
      pmp_cfg7_r_tmp <= csr_wdata[31:24];
    end
  
  end
end

assign pmp_cfg7_r = {pmp_cfg7_r_tmp[7], 2'b0, pmp_cfg7_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg8_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg8_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[8] == 1'b1)
    begin
      pmp_cfg8_r_tmp <= csr_wdata[7:0];
    end
  
  end
end

assign pmp_cfg8_r = {pmp_cfg8_r_tmp[7], 2'b0, pmp_cfg8_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg9_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg9_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[9] == 1'b1)
    begin
      pmp_cfg9_r_tmp <= csr_wdata[15:8];
    end
  
  end
end

assign pmp_cfg9_r = {pmp_cfg9_r_tmp[7], 2'b0, pmp_cfg9_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg10_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg10_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[10] == 1'b1)
    begin
      pmp_cfg10_r_tmp <= csr_wdata[23:16];
    end
  
  end
end

assign pmp_cfg10_r = {pmp_cfg10_r_tmp[7], 2'b0, pmp_cfg10_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg11_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg11_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[11] == 1'b1)
    begin
      pmp_cfg11_r_tmp <= csr_wdata[31:24];
    end
  
  end
end

assign pmp_cfg11_r = {pmp_cfg11_r_tmp[7], 2'b0, pmp_cfg11_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg12_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg12_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[12] == 1'b1)
    begin
      pmp_cfg12_r_tmp <= csr_wdata[7:0];
    end
  
  end
end

assign pmp_cfg12_r = {pmp_cfg12_r_tmp[7], 2'b0, pmp_cfg12_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg13_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg13_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[13] == 1'b1)
    begin
      pmp_cfg13_r_tmp <= csr_wdata[15:8];
    end
  
  end
end

assign pmp_cfg13_r = {pmp_cfg13_r_tmp[7], 2'b0, pmp_cfg13_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg14_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg14_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[14] == 1'b1)
    begin
      pmp_cfg14_r_tmp <= csr_wdata[23:16];
    end
  
  end
end

assign pmp_cfg14_r = {pmp_cfg14_r_tmp[7], 2'b0, pmp_cfg14_r_tmp[4:0]};

always @(posedge clk or posedge rst_a)
begin : pmp_cfg15_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_cfg15_r_tmp   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[15] == 1'b1)
    begin
      pmp_cfg15_r_tmp <= csr_wdata[31:24];
    end
  
  end
end

assign pmp_cfg15_r = {pmp_cfg15_r_tmp[7], 2'b0, pmp_cfg15_r_tmp[4:0]};


always @(posedge clk or posedge rst_a)
begin : pmp_addr0_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr0_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[0] == 1'b1)
    begin
      pmp_addr0_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr1_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr1_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[1] == 1'b1)
    begin
      pmp_addr1_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr2_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr2_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[2] == 1'b1)
    begin
      pmp_addr2_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr3_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr3_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[3] == 1'b1)
    begin
      pmp_addr3_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr4_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr4_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[4] == 1'b1)
    begin
      pmp_addr4_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr5_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr5_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[5] == 1'b1)
    begin
      pmp_addr5_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr6_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr6_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[6] == 1'b1)
    begin
      pmp_addr6_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr7_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr7_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[7] == 1'b1)
    begin
      pmp_addr7_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr8_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr8_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[8] == 1'b1)
    begin
      pmp_addr8_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr9_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr9_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[9] == 1'b1)
    begin
      pmp_addr9_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr10_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr10_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[10] == 1'b1)
    begin
      pmp_addr10_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr11_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr11_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[11] == 1'b1)
    begin
      pmp_addr11_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr12_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr12_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[12] == 1'b1)
    begin
      pmp_addr12_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr13_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr13_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[13] == 1'b1)
    begin
      pmp_addr13_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr14_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr14_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[14] == 1'b1)
    begin
      pmp_addr14_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : pmp_addr15_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pmp_addr15_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[15] == 1'b1)
    begin
      pmp_addr15_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end


endmodule // rl_pmp

