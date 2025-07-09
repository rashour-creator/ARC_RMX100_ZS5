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

module rl_epmp (

  ////////// IFU PMP interface //////////////////////////////////////////////
  //
  input [`IFU_ADDR_RANGE]         ifu_addr0,             // IFU address0 
  
  output                          ipmp_hit0,             // hit on PMP 
  output [5:0]                    ipmp_perm0,            // permission attributes vector (L, R, W, X)
  
  ////////// DMP PMP interface ////////////////////////////////////////////
  //
  input [`ADDR_RANGE]             dmp_addr,              // DMP address
  input                           cross_word,
  input [`ADDR_RANGE]             dmp_addr1,
  output                          cross_region,
  
  output                          dpmp_hit,              // hit on PMP 
  output [5:0]                    dpmp_perm,             // permission attributes vector
  
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
  
  ////////// General input signals //////////////////////////////////////////
  //
  input                           clk,                   // clock signal
  input                           rst_a                  // reset signal
);

// Local Declarations
//

wire    [3:0]             ipmp_perm0_i;
wire    [3:0]             dpmp_perm_i;
wire    [`DATA_RANGE]     csr_rdata_i;
wire                      csr_illegal_i;
wire                      csr_unimpl_i;
wire                      csr_serial_sr_i;
wire                      csr_strict_sr_i;
wire                      csr_cfg_ecg0;
reg [`DATA_RANGE]         msec_cfg_lo_r;

// Clock-gates
//


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

    `MSEC_CFG_HI:
    begin
      csr_rdata      = 32'b0;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = 1'b0;
      csr_strict_sr  = 1'b0;
    end

    `MSEC_CFG_LO:
    begin
      csr_rdata      = msec_cfg_lo_r;          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = 1'b0;
      csr_strict_sr  = csr_sel_write;
    end
    default:
    begin
      csr_rdata     = csr_rdata_i;             
      csr_illegal   = csr_illegal_i;
      csr_unimpl    = csr_unimpl_i;
      csr_serial_sr = csr_serial_sr_i; 
      csr_strict_sr = csr_strict_sr_i;
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
  csr_sec_lo_cg0 = 1'b0;
  
  case (csr_waddr)

  `MSEC_CFG_LO:
  begin
    csr_sec_lo_cg0 = csr_write & x2_pass;
  end

  default:
  begin
    csr_sec_lo_cg0 = 1'b0;
  end
  endcase
end






//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
wire        any_lock;
wire [2:0]  msec_cfg_lo_nxt;
assign      msec_cfg_lo_nxt = {((~csr_wdata[2]) ? 1'b0 : ((~any_lock) | msec_cfg_lo_r[2])), (csr_wdata[1:0] | msec_cfg_lo_r[1:0])};


always @(posedge clk or posedge rst_a)
begin : pmp_sec_lo_regs_PROC
  if (rst_a == 1'b1)
  begin
    msec_cfg_lo_r   <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (csr_sec_lo_cg0 == 1'b1)
    begin
      msec_cfg_lo_r <= {29'b0, msec_cfg_lo_nxt};
    end
  
  end
end

rl_pmp u_rl_pmp (
    .ifu_addr0      (ifu_addr0),              
    .ipmp_hit0      (ipmp_hit0),             
    .ipmp_perm0     (ipmp_perm0_i),           
    .cross_word     (cross_word),
    .dmp_addr1      (dmp_addr1),
    .cross_region   (cross_region),
    .dmp_addr       (dmp_addr),             
    .dpmp_hit       (dpmp_hit),              
    .dpmp_perm      (dpmp_perm_i),             
    .csr_sel_ctl    (csr_sel_ctl),           
    .csr_sel_addr   (csr_sel_addr),        
    .priv_level_r   (priv_level_r),
    .csr_rdata      (csr_rdata_i),           
    .csr_illegal    (csr_illegal_i),        
    .csr_unimpl     (csr_unimpl_i),        
    .csr_serial_sr  (csr_serial_sr_i),    
    .csr_strict_sr  (csr_strict_sr_i),   
    .csr_write      (csr_write),      
    .csr_waddr      (csr_waddr),            
    .csr_wdata      (csr_wdata),            
    .x2_pass        (x2_pass),             
    .csr_cfg_ecg0   (csr_cfg_ecg0),       
    .any_lock       (any_lock),
    .clk            (clk),           
    .rst_a          (rst_a)

);

assign  csr_cfg_ecg0 = msec_cfg_lo_r[2];

//Output assignments
//
assign  ipmp_perm0 = {msec_cfg_lo_r[1:0], ipmp_perm0_i};
assign  dpmp_perm = {msec_cfg_lo_r[1:0], dpmp_perm_i};


endmodule // rl_epmp

