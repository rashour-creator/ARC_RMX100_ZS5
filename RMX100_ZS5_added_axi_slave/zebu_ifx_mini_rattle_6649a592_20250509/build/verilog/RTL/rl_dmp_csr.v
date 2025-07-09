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
//  This module implements the DCCM, peripheral0 CSR registers
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
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_dmp_csr (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                            clk,                   // clock signal
  input                            rst_a,                  // reset signal

  //////////// Interface with DMP ////////////////////////////////////////// 
  //
  output reg  [`PER_BASE_RANGE]    csr_arcv_per0_base_r,
  output      [`PER_BASE_RANGE]    csr_arcv_per0_limit,
  output [1:0]                     dccm_ecc_enable,
  output                           csr_dccm_rwecc,
  output [11:0]                    csr_dccm_base,
  output                           csr_dccm_off,

  ////////// CSR interface ///////////////////////////////////////////////
  //
  input [1:0]                      priv_level_r,          // Privilege mode

  input  [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input  [7:0]                     csr_sel_addr,          // (X1) CSR address
  
  output reg [`DATA_RANGE]         csr_rdata,             // (X1) CSR read data
  output reg                       csr_illegal,           // (X1) illegal
  output reg                       csr_unimpl,            // (X1) Invalid CSR
  output reg                       csr_serial_sr,         // (X1) SR group flush pipe
  output reg                       csr_strict_sr,         // (X1) SR flush pipe
  
  input                            csr_write,             // (X2) CSR operation (0 = read, 1 = write)
  input  [7:0]                     csr_waddr,             // (X2) CSR addr
  input  [`DATA_RANGE]             csr_wdata              // (X2) Write data
);

// Local declarations
//
reg        csr_mdccm_wen;
reg [15:0] csr_mdccm_ctl_nxt;
reg [15:0] csr_mdccm_ctl_r;

`define mdccm_DCCM_BASE 15:4
`define mdccm_DISABLE   3
`define mdccm_RWECC     2
`define mdccm_ECCEN     1:0

reg                      csr_per0_base_wen; 
reg                      csr_per0_size_wen; 
reg  [`PER_SIZE_RANGE]   csr_arcv_per0_size_r;
reg  [`PER_SIZE_RANGE]   csr_arcv_per0_size_nxt;
reg  [`PER_BASE_RANGE]   csr_arcv_per0_base_nxt;



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
//!BCR { num: 1986, val: 2147483649, name: "MDCCM_CTL" }
    `CSR_MDCCM_CTL:
    begin
      csr_rdata                        = {csr_mdccm_ctl_r[`mdccm_DCCM_BASE],        // DCCM_base
                                          16'd0,                                    // Reserved bits
                                          csr_mdccm_ctl_r[`mdccm_DISABLE],          // DCCM_disable
                                          csr_mdccm_ctl_r[`mdccm_RWECC],
                                          csr_mdccm_ctl_r[`mdccm_ECCEN]};          
      csr_serial_sr                    = csr_sel_ctl[1];  
      csr_illegal                      = priv_level_r != `PRIV_M;
      csr_unimpl                       = 1'b0;    
    end
//!BCR { num: 1990, val: 4026531840, name: "ARCV_PER0_BASE" }
    `CSR_ARCV_PER0_BASE:
    begin
      csr_rdata                        = {csr_arcv_per0_base_r,                    // PER0_BASE
                                          20'd0                                   // Reserved bits
                                         };
      csr_serial_sr                    = csr_sel_ctl[1];
      csr_illegal                      = priv_level_r != `PRIV_M;      
      csr_unimpl                       = 1'b0;
    end 
//!BCR { num: 1991, val: 1, name: "ARCV_PER0_SIZE" }
    `CSR_ARCV_PER0_SIZE:
    begin
      csr_rdata                        = {20'd0,                                   // Reserved bits
                                          csr_arcv_per0_size_r                    // PER0_SIZE                                                                          
                                         };
      csr_serial_sr                    = csr_sel_ctl[1];
      csr_illegal                      = priv_level_r != `PRIV_M;      
      csr_unimpl                       = 1'b0;
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
  csr_mdccm_wen     = 1'b0;
  csr_per0_base_wen = 1'b0;
  csr_per0_size_wen = 1'b0;
  if (csr_write)
  begin
    case ({4'b0111, csr_waddr})
    `CSR_MDCCM_CTL:
    begin
      csr_mdccm_wen = 1'b1;
    end
    `CSR_ARCV_PER0_BASE:
    begin
      csr_per0_base_wen = 1'b1;
    end
    `CSR_ARCV_PER0_SIZE:
    begin
      csr_per0_size_wen = 1'b1;
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
begin : csr_mdccm_ctl_nxt_PROC 
  csr_mdccm_ctl_nxt = {csr_wdata[`ADDR_MSB:`ADDR_MSB-11],
                       csr_wdata[`mdccm_DISABLE],
                       csr_wdata[`mdccm_RWECC],
                       csr_wdata[`mdccm_ECCEN]
                      };
end


always @*
begin : csr_arcv_per0_nxt_PROC 
  csr_arcv_per0_base_nxt = csr_wdata[`PER_BASE_RANGE];

  csr_arcv_per0_size_nxt = csr_wdata[`PER_SIZE_RANGE];
end                      

//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
//!BCR { num: 1986, val: 2147483649, name: "MDCCM_CTL" }
always @(posedge clk or posedge rst_a)
begin : csr_mdccm_ctl_reg_PROC
  if (rst_a == 1'b1)
  begin
    csr_mdccm_ctl_r   <= {12'd`DCCM_BASE, 1'b0, 1'b0, 2'b01}; //Reset value
  end
  else
  begin
    if (csr_mdccm_wen == 1'b1)
    begin
      csr_mdccm_ctl_r <= csr_mdccm_ctl_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_arcv_per0_reg_PROC
  if (rst_a == 1'b1)
  begin
    csr_arcv_per0_base_r <= `PER_BASE_BITS'd`PER0_BASE;   // Reset value
    csr_arcv_per0_size_r <= `PER_BASE_BITS'd`PER0_SIZE;  // Reset value
  end
  else
  begin
    if (csr_per0_base_wen == 1'b1)
    begin
      csr_arcv_per0_base_r <= csr_arcv_per0_base_nxt;
    end

    if (csr_per0_size_wen == 1'b1)
    begin
      csr_arcv_per0_size_r <= csr_arcv_per0_size_nxt;
    end
  end
end
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Output assignments
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
assign csr_dccm_base   = csr_mdccm_ctl_r[`mdccm_DCCM_BASE];
assign csr_dccm_off    = csr_mdccm_ctl_r[`mdccm_DISABLE];
assign dccm_ecc_enable = csr_mdccm_ctl_r[`mdccm_ECCEN];
assign csr_dccm_rwecc  = csr_mdccm_ctl_r[`mdccm_RWECC];

assign csr_arcv_per0_limit = csr_arcv_per0_base_r + csr_arcv_per0_size_r - `PER_BASE_BITS'd1;
endmodule //rl_dmp_csr


