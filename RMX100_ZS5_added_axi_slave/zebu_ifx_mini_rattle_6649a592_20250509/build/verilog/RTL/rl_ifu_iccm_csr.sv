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
//  This module implements the ICCM aux registers
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

// Set simulation timescale
//
`include "const.def"

module rl_ifu_iccm_csr (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                            clk,                   // clock signal
  input                            rst_a,                  // reset signal

  ////////// CSR interface ///////////////////////////////////////////////
  //
  input  [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input  [7:0]                     csr_sel_addr,          // (X1) CSR address
  input  [1:0]                     priv_level,
  
  output reg [`DATA_RANGE]         csr_rdata,             // (X1) CSR read data
  output reg                       csr_illegal,           // (X1) illegal
  output reg                       csr_unimpl,            // (X1) Invalid CSR
  output reg                       csr_serial_sr,         // (X1) SR group flush pipe
  output reg                       csr_strict_sr,         // (X1) SR flush pipe
  
  input                            csr_write,             // (X2) CSR operation (0 = read, 1 = write)
  input  [7:0]                     csr_waddr,             // (X2) CSR addr
  input  [`DATA_RANGE]             csr_wdata,             // (X2) Write data

  //////////// Interface with DMP ////////////////////////////////////////// 
  //
  output [`miccm_ECCEN]            csr_iccm0_eccen,
  output                           csr_iccm0_rwecc,
  output                           csr_iccm0_disable,
  output [`ICCM_BASE_RANGE]        csr_iccm0_base
);

// Local declarations
//
reg        csr_miccm_wen;
reg [15:0] csr_miccm_ctl_nxt;
reg [15:0] csr_miccm_ctl_r;


//////////////////////////////////////////////////////////////////////////////
// Reads
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_read_PROC
  csr_rdata      = {`DATA_SIZE{1'b0}};       
  csr_illegal    = 1'b0;            
  csr_unimpl     = 1'b1;      
  csr_serial_sr  = 1'b0;  
  csr_strict_sr  = 1'b0;
  
  if (|csr_sel_ctl)
  begin
    // 
    //
    case ({4'b0111, csr_sel_addr})
//!BCR { num: 1984, val: 1, name: "MICCM_CTL" }
    `CSR_MICCM_CTL:
    begin
      csr_rdata                        = {csr_miccm_ctl_r[`miccm_ICCM_BASE],        //ICCM_base
                                          16'd0,                                    //Reserved bits
                                          csr_miccm_ctl_r[`miccm_dis],
                                          csr_miccm_ctl_r[`miccm_RWECC],
                                          csr_miccm_ctl_r[`miccm_ECCEN]};          
      csr_serial_sr                    = csr_sel_ctl[1];  
      csr_unimpl                       = 1'b0;    
      csr_illegal                      = (priv_level != `PRIV_M);
    end
// spyglass disable_block W193
// SMD: empty statement
// SJ:  empty defaults kept
  default:;
  endcase
// spyglass enable_block W193

  end
end

//////////////////////////////////////////////////////////////////////////////
// Writes
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_write_PROC
  csr_miccm_wen =1'b0;

  if (csr_write)
  begin
    case ({4'b0111, csr_waddr})
    `CSR_MICCM_CTL:
    begin
      csr_miccm_wen = 1'b1;
    end
// spyglass disable_block W193
// SMD: empty statement
// SJ:  empty defaults kept
    default:;
    endcase
// spyglass enable_block W193
  end
end

always @*
begin : csr_miccm_ctl_nxt_PROC 
  csr_miccm_ctl_nxt = {csr_wdata[`ADDR_MSB:`ADDR_MSB-11],
                       csr_wdata[`miccm_dis],
                       csr_wdata[`miccm_RWECC],
                       csr_wdata[`miccm_ECCEN]
                      };
end

//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : csr_miccm_ctl_reg_PROC
  if (rst_a == 1'b1)
  begin
    csr_miccm_ctl_r   <= {12'd`ICCM0_BASE, 1'b0, 1'b0, 2'b01}; //Reset value
  end
  else
  begin
    if (csr_miccm_wen == 1'b1)
    begin
      csr_miccm_ctl_r <= csr_miccm_ctl_nxt;
    end
  end
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Output assignments
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
assign csr_iccm0_base    = csr_miccm_ctl_r[`miccm_ICCM_BASE];
assign csr_iccm0_eccen   = csr_miccm_ctl_r[`miccm_ECCEN];
assign csr_iccm0_rwecc   = csr_miccm_ctl_r[`miccm_RWECC];
assign csr_iccm0_disable = csr_miccm_ctl_r[`miccm_dis]; 

endmodule //rl_ifu_iccm_csr


