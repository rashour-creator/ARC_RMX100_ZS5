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

module rl_pma (

  ////////// IFU PMA interface //////////////////////////////////////////////
  //
  input [`IFU_ADDR_RANGE]         ifu_addr0,             // IFU address0 
  input [2:0]                     f1_mem_target,
  input                           fetch_iccm_hole,
  
  output reg [3:0]                ipma_attr0,            // memory attributes vector (Attr)
  
  ////////// DMP PMA interface ////////////////////////////////////////////
  //
  input [`ADDR_RANGE]             dmp_addr,              // DMP address
  input [`DMP_TARGET_RANGE]       dmp_x2_target_r,
  input                           dmp_x2_ccm_hole_r,
  
  output reg [5:0]                dpma_attr,             // memory attributes vector (AMO, LR/SC, Attr)
  
  ////////// CSR interface ///////////////////////////////////////////////
  //
  input [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input [11:0]                    csr_sel_addr,          // (X1) CSR address
  input [1:0]                     priv_level_r,          // CSR priv check
  
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
reg [7:0]                 pma_cfg0_r;
reg [7:0]                 pma_cfg1_r;
reg [7:0]                 pma_cfg2_r;
reg [7:0]                 pma_cfg3_r;
reg [7:0]                 pma_cfg4_r;
reg [7:0]                 pma_cfg5_r;


wire [7:0]                pma_cfg6_r;
wire [7:0]                pma_cfg7_r;


reg [`ADDR_RANGE]         pma_addr0_r;
reg [`ADDR_RANGE]         pma_addr1_r;
reg [`ADDR_RANGE]         pma_addr2_r;
reg [`ADDR_RANGE]         pma_addr3_r;
reg [`ADDR_RANGE]         pma_addr4_r;
reg [`ADDR_RANGE]         pma_addr5_r;
wire [`ADDR_RANGE]         pma_addr0_mask;
wire [`ADDR_RANGE]         pma_addr0_mask_temp;
wire [`ADDR_RANGE]         pma_addr1_mask;
wire [`ADDR_RANGE]         pma_addr1_mask_temp;
wire [`ADDR_RANGE]         pma_addr2_mask;
wire [`ADDR_RANGE]         pma_addr2_mask_temp;
wire [`ADDR_RANGE]         pma_addr3_mask;
wire [`ADDR_RANGE]         pma_addr3_mask_temp;
wire [`ADDR_RANGE]         pma_addr4_mask;
wire [`ADDR_RANGE]         pma_addr4_mask_temp;
wire [`ADDR_RANGE]         pma_addr5_mask;
wire [`ADDR_RANGE]         pma_addr5_mask_temp;

// Clock-gates
//
reg [7:0]                 csr_cfg_cg0;
reg [`PMA_ENTRIES_RANGE]  csr_addr_cg0;


wire                      csr_sel_write;

// The PMA CSRs live in this module
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
    // PMA unit got selected
    //
    case (csr_sel_addr)
    `PMA_CFG0:
    begin
      csr_rdata      = {pma_cfg3_r, pma_cfg2_r, pma_cfg1_r, pma_cfg0_r};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    `PMA_CFG1:
    begin
      csr_rdata      = {pma_cfg7_r, pma_cfg6_r, pma_cfg5_r, pma_cfg4_r};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2008, val: 511, name: "PMA_ADDR0" }
    `PMA_ADDR0:
    begin
      csr_rdata      = {pma_addr0_r[31:9], 9'h1ff};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2009, val: 511, name: "PMA_ADDR1" }
    `PMA_ADDR1:
    begin
      csr_rdata      = {pma_addr1_r[31:9], 9'h1ff};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2010, val: 511, name: "PMA_ADDR2" }
    `PMA_ADDR2:
    begin
      csr_rdata      = {pma_addr2_r[31:9], 9'h1ff};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2011, val: 511, name: "PMA_ADDR3" }
    `PMA_ADDR3:
    begin
      csr_rdata      = {pma_addr3_r[31:9], 9'h1ff};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2012, val: 511, name: "PMA_ADDR4" }
    `PMA_ADDR4:
    begin
      csr_rdata      = {pma_addr4_r[31:9], 9'h1ff};          
      csr_illegal    = (priv_level_r != `PRIV_M);    
      csr_unimpl     = 1'b0;    
      csr_serial_sr  = csr_sel_write;
      csr_strict_sr  = 1'b0;
    end
    
//!BCR { num: 2013, val: 511, name: "PMA_ADDR5" }
    `PMA_ADDR5:
    begin
      csr_rdata      = {pma_addr5_r[31:9], 9'h1ff};          
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
  csr_cfg_cg0   = 8'b0;
  csr_addr_cg0  = {`PMA_ENTRIES{1'b0}};    
  
  case (csr_waddr)
  `PMA_CFG0:
  begin
    csr_cfg_cg0[0] = csr_write & x2_pass;
    csr_cfg_cg0[1] = csr_write & x2_pass;
    csr_cfg_cg0[2] = csr_write & x2_pass;
    csr_cfg_cg0[3] = csr_write & x2_pass;
  end
  `PMA_CFG1:
  begin
    csr_cfg_cg0[4] = csr_write & x2_pass;
    csr_cfg_cg0[5] = csr_write & x2_pass;
    csr_cfg_cg0[6] = csr_write & x2_pass;
    csr_cfg_cg0[7] = csr_write & x2_pass;
  end
    
    
  `PMA_ADDR0:
  begin
    csr_addr_cg0[0] = csr_write & x2_pass;
  end
  
  `PMA_ADDR1:
  begin
    csr_addr_cg0[1] = csr_write & x2_pass;
  end
  
  `PMA_ADDR2:
  begin
    csr_addr_cg0[2] = csr_write & x2_pass;
  end
  
  `PMA_ADDR3:
  begin
    csr_addr_cg0[3] = csr_write & x2_pass;
  end
  
  `PMA_ADDR4:
  begin
    csr_addr_cg0[4] = csr_write & x2_pass;
  end
  
  `PMA_ADDR5:
  begin
    csr_addr_cg0[5] = csr_write & x2_pass;
  end
  


  default:
  begin
    csr_cfg_cg0   = 8'b0;
    csr_addr_cg0  = {`PMA_ENTRIES{1'b0}};
  end
  endcase
end


wire [`PMA_ENTRIES_RANGE] pma_ifu_hit0;
wire [`PMA_ENTRIES_RANGE] pma_dmp_hit;

wire [1:0]                pma_addr_mode0;
assign pma_addr_mode0 = (|pma_cfg0_r[3:0]) ? 2'b11 : 2'b0;

rl_pma_hit # (
  .PMP_LEN       (20)
  ) u0_pma_hit0  (
   .addr          (ifu_addr0[31:12]), 
   
   .pmp_addr      (pma_addr0_r[29:10]),  
   .pmp_addr_mask (pma_addr0_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode0),
   
   .pmp_hit       (pma_ifu_hit0[0])
);


rl_pma_hit  # (
  .PMP_LEN       (20)
  ) u0_pma_hit2 (
   .addr          (dmp_addr[31:12]), 
   
   .pmp_addr      (pma_addr0_r[29:10]),
   .pmp_addr_mask (pma_addr0_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode0),
   
   .pmp_hit       (pma_dmp_hit[0])
);

wire [1:0]                pma_addr_mode1;
assign pma_addr_mode1 = (|pma_cfg1_r[3:0]) ? 2'b11 : 2'b0;

rl_pma_hit # (
  .PMP_LEN       (20)
  ) u1_pma_hit0  (
   .addr          (ifu_addr0[31:12]), 
   
   .pmp_addr      (pma_addr1_r[29:10]),  
   .pmp_addr_mask (pma_addr1_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode1),
   
   .pmp_hit       (pma_ifu_hit0[1])
);


rl_pma_hit  # (
  .PMP_LEN       (20)
  ) u1_pma_hit2 (
   .addr          (dmp_addr[31:12]), 
   
   .pmp_addr      (pma_addr1_r[29:10]),
   .pmp_addr_mask (pma_addr1_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode1),
   
   .pmp_hit       (pma_dmp_hit[1])
);

wire [1:0]                pma_addr_mode2;
assign pma_addr_mode2 = (|pma_cfg2_r[3:0]) ? 2'b11 : 2'b0;

rl_pma_hit # (
  .PMP_LEN       (20)
  ) u2_pma_hit0  (
   .addr          (ifu_addr0[31:12]), 
   
   .pmp_addr      (pma_addr2_r[29:10]),  
   .pmp_addr_mask (pma_addr2_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode2),
   
   .pmp_hit       (pma_ifu_hit0[2])
);


rl_pma_hit  # (
  .PMP_LEN       (20)
  ) u2_pma_hit2 (
   .addr          (dmp_addr[31:12]), 
   
   .pmp_addr      (pma_addr2_r[29:10]),
   .pmp_addr_mask (pma_addr2_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode2),
   
   .pmp_hit       (pma_dmp_hit[2])
);

wire [1:0]                pma_addr_mode3;
assign pma_addr_mode3 = (|pma_cfg3_r[3:0]) ? 2'b11 : 2'b0;

rl_pma_hit # (
  .PMP_LEN       (20)
  ) u3_pma_hit0  (
   .addr          (ifu_addr0[31:12]), 
   
   .pmp_addr      (pma_addr3_r[29:10]),  
   .pmp_addr_mask (pma_addr3_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode3),
   
   .pmp_hit       (pma_ifu_hit0[3])
);


rl_pma_hit  # (
  .PMP_LEN       (20)
  ) u3_pma_hit2 (
   .addr          (dmp_addr[31:12]), 
   
   .pmp_addr      (pma_addr3_r[29:10]),
   .pmp_addr_mask (pma_addr3_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode3),
   
   .pmp_hit       (pma_dmp_hit[3])
);

wire [1:0]                pma_addr_mode4;
assign pma_addr_mode4 = (|pma_cfg4_r[3:0]) ? 2'b11 : 2'b0;

rl_pma_hit # (
  .PMP_LEN       (20)
  ) u4_pma_hit0  (
   .addr          (ifu_addr0[31:12]), 
   
   .pmp_addr      (pma_addr4_r[29:10]),  
   .pmp_addr_mask (pma_addr4_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode4),
   
   .pmp_hit       (pma_ifu_hit0[4])
);


rl_pma_hit  # (
  .PMP_LEN       (20)
  ) u4_pma_hit2 (
   .addr          (dmp_addr[31:12]), 
   
   .pmp_addr      (pma_addr4_r[29:10]),
   .pmp_addr_mask (pma_addr4_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode4),
   
   .pmp_hit       (pma_dmp_hit[4])
);

wire [1:0]                pma_addr_mode5;
assign pma_addr_mode5 = (|pma_cfg5_r[3:0]) ? 2'b11 : 2'b0;

rl_pma_hit # (
  .PMP_LEN       (20)
  ) u5_pma_hit0  (
   .addr          (ifu_addr0[31:12]), 
   
   .pmp_addr      (pma_addr5_r[29:10]),  
   .pmp_addr_mask (pma_addr5_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode5),
   
   .pmp_hit       (pma_ifu_hit0[5])
);


rl_pma_hit  # (
  .PMP_LEN       (20)
  ) u5_pma_hit2 (
   .addr          (dmp_addr[31:12]), 
   
   .pmp_addr      (pma_addr5_r[29:10]),
   .pmp_addr_mask (pma_addr5_mask[29:10]),
   .pmp_addr_mode (pma_addr_mode5),
   
   .pmp_hit       (pma_dmp_hit[5])
);



wire [5:0] pma_perm_entry0;

assign pma_perm_entry0  = {pma_cfg0_r[7:6],  pma_cfg0_r[3:0]}; 
assign pma_addr0_mask_temp = ~({pma_addr0_r[31:9], 9'h1ff} + 32'b1) ^ {pma_addr0_r[31:9], 9'h1ff};
assign pma_addr0_mask = (pma_addr0_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pma_addr0_mask_temp;
wire [5:0] pma_perm_entry1;

assign pma_perm_entry1  = {pma_cfg1_r[7:6],  pma_cfg1_r[3:0]}; 
assign pma_addr1_mask_temp = ~({pma_addr1_r[31:9], 9'h1ff} + 32'b1) ^ {pma_addr1_r[31:9], 9'h1ff};
assign pma_addr1_mask = (pma_addr1_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pma_addr1_mask_temp;
wire [5:0] pma_perm_entry2;

assign pma_perm_entry2  = {pma_cfg2_r[7:6],  pma_cfg2_r[3:0]}; 
assign pma_addr2_mask_temp = ~({pma_addr2_r[31:9], 9'h1ff} + 32'b1) ^ {pma_addr2_r[31:9], 9'h1ff};
assign pma_addr2_mask = (pma_addr2_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pma_addr2_mask_temp;
wire [5:0] pma_perm_entry3;

assign pma_perm_entry3  = {pma_cfg3_r[7:6],  pma_cfg3_r[3:0]}; 
assign pma_addr3_mask_temp = ~({pma_addr3_r[31:9], 9'h1ff} + 32'b1) ^ {pma_addr3_r[31:9], 9'h1ff};
assign pma_addr3_mask = (pma_addr3_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pma_addr3_mask_temp;
wire [5:0] pma_perm_entry4;

assign pma_perm_entry4  = {pma_cfg4_r[7:6],  pma_cfg4_r[3:0]}; 
assign pma_addr4_mask_temp = ~({pma_addr4_r[31:9], 9'h1ff} + 32'b1) ^ {pma_addr4_r[31:9], 9'h1ff};
assign pma_addr4_mask = (pma_addr4_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pma_addr4_mask_temp;
wire [5:0] pma_perm_entry5;

assign pma_perm_entry5  = {pma_cfg5_r[7:6],  pma_cfg5_r[3:0]}; 
assign pma_addr5_mask_temp = ~({pma_addr5_r[31:9], 9'h1ff} + 32'b1) ^ {pma_addr5_r[31:9], 9'h1ff};
assign pma_addr5_mask = (pma_addr5_r[29:0] == 30'h3fffffff) ? 32'hc0000000 : pma_addr5_mask_temp;

// Priority encoders 
//

always @*
begin : pma_ifu_hit_priority_PROC
  // Default values
  //
  ipma_attr0 = 4'b0;

  if (f1_mem_target == 3'b001) begin
      ipma_attr0 = 4'b0100;
  end
  else
  case (1'b1)
  pma_ifu_hit0[0]:
  begin
    if (fetch_iccm_hole)
    ipma_attr0 = ((&pma_perm_entry0[3:0]) | (pma_perm_entry0[3:0] == 4'b0100)) ? pma_perm_entry0[3:0] : 4'b0011;
    else
    ipma_attr0 = pma_perm_entry0[3:0];
  end

  pma_ifu_hit0[1]:
  begin
    if (fetch_iccm_hole)
    ipma_attr0 = ((&pma_perm_entry1[3:0]) | (pma_perm_entry1[3:0] == 4'b0100)) ? pma_perm_entry1[3:0] : 4'b0011;
    else
    ipma_attr0 = pma_perm_entry1[3:0];
  end

  pma_ifu_hit0[2]:
  begin
    if (fetch_iccm_hole)
    ipma_attr0 = ((&pma_perm_entry2[3:0]) | (pma_perm_entry2[3:0] == 4'b0100)) ? pma_perm_entry2[3:0] : 4'b0011;
    else
    ipma_attr0 = pma_perm_entry2[3:0];
  end

  pma_ifu_hit0[3]:
  begin
    if (fetch_iccm_hole)
    ipma_attr0 = ((&pma_perm_entry3[3:0]) | (pma_perm_entry3[3:0] == 4'b0100)) ? pma_perm_entry3[3:0] : 4'b0011;
    else
    ipma_attr0 = pma_perm_entry3[3:0];
  end

  pma_ifu_hit0[4]:
  begin
    if (fetch_iccm_hole)
    ipma_attr0 = ((&pma_perm_entry4[3:0]) | (pma_perm_entry4[3:0] == 4'b0100)) ? pma_perm_entry4[3:0] : 4'b0011;
    else
    ipma_attr0 = pma_perm_entry4[3:0];
  end

  pma_ifu_hit0[5]:
  begin
    if (fetch_iccm_hole)
    ipma_attr0 = ((&pma_perm_entry5[3:0]) | (pma_perm_entry5[3:0] == 4'b0100)) ? pma_perm_entry5[3:0] : 4'b0011;
    else
    ipma_attr0 = pma_perm_entry5[3:0];
  end

  default:
  begin
    ipma_attr0 = fetch_iccm_hole ? 4'b0011 : 4'b0100;
  end
  endcase
  
end


always @*
begin : pma_dmp_hit_priority_PROC
  // Default values
  //
  dpma_attr  = 6'b0;
  if ((dmp_x2_target_r == `DMP_TARGET_ICCM) || (dmp_x2_target_r == `DMP_TARGET_DCCM)) begin
      dpma_attr = 6'b110100;
  end
  else if (dmp_x2_target_r == `DMP_TARGET_MMIO) begin
      dpma_attr = 6'b000001;
  end
  else if (dmp_x2_target_r == `DMP_TARGET_NVM) begin
      dpma_attr = 6'b000011;
  end
  else
  case (1'b1)
  pma_dmp_hit[0]:
  begin
      if (dmp_x2_target_r == `DMP_TARGET_PER)
        dpma_attr  = ((pma_perm_entry0[3:0] == 4'b0001)| (pma_perm_entry0[3:0] == 4'b0010)) ? pma_perm_entry0 : 6'b000001;
      else if (dmp_x2_ccm_hole_r)  // MEM Target
        dpma_attr  = ((&pma_perm_entry0[3:0]) | (pma_perm_entry0[3:0] == 4'b0100)| (pma_perm_entry0[3:0] == 4'b0011)) ? pma_perm_entry0 : 6'b000011;
      else
        dpma_attr  = pma_perm_entry0;
  end

  pma_dmp_hit[1]:
  begin
      if (dmp_x2_target_r == `DMP_TARGET_PER)
        dpma_attr  = ((pma_perm_entry1[3:0] == 4'b0001)| (pma_perm_entry1[3:0] == 4'b0010)) ? pma_perm_entry1 : 6'b000001;
      else if (dmp_x2_ccm_hole_r)  // MEM Target
        dpma_attr  = ((&pma_perm_entry1[3:0]) | (pma_perm_entry1[3:0] == 4'b0100)| (pma_perm_entry1[3:0] == 4'b0011)) ? pma_perm_entry1 : 6'b000011;
      else
        dpma_attr  = pma_perm_entry1;
  end

  pma_dmp_hit[2]:
  begin
      if (dmp_x2_target_r == `DMP_TARGET_PER)
        dpma_attr  = ((pma_perm_entry2[3:0] == 4'b0001)| (pma_perm_entry2[3:0] == 4'b0010)) ? pma_perm_entry2 : 6'b000001;
      else if (dmp_x2_ccm_hole_r)  // MEM Target
        dpma_attr  = ((&pma_perm_entry2[3:0]) | (pma_perm_entry2[3:0] == 4'b0100)| (pma_perm_entry2[3:0] == 4'b0011)) ? pma_perm_entry2 : 6'b000011;
      else
        dpma_attr  = pma_perm_entry2;
  end

  pma_dmp_hit[3]:
  begin
      if (dmp_x2_target_r == `DMP_TARGET_PER)
        dpma_attr  = ((pma_perm_entry3[3:0] == 4'b0001)| (pma_perm_entry3[3:0] == 4'b0010)) ? pma_perm_entry3 : 6'b000001;
      else if (dmp_x2_ccm_hole_r)  // MEM Target
        dpma_attr  = ((&pma_perm_entry3[3:0]) | (pma_perm_entry3[3:0] == 4'b0100)| (pma_perm_entry3[3:0] == 4'b0011)) ? pma_perm_entry3 : 6'b000011;
      else
        dpma_attr  = pma_perm_entry3;
  end

  pma_dmp_hit[4]:
  begin
      if (dmp_x2_target_r == `DMP_TARGET_PER)
        dpma_attr  = ((pma_perm_entry4[3:0] == 4'b0001)| (pma_perm_entry4[3:0] == 4'b0010)) ? pma_perm_entry4 : 6'b000001;
      else if (dmp_x2_ccm_hole_r)  // MEM Target
        dpma_attr  = ((&pma_perm_entry4[3:0]) | (pma_perm_entry4[3:0] == 4'b0100)| (pma_perm_entry4[3:0] == 4'b0011)) ? pma_perm_entry4 : 6'b000011;
      else
        dpma_attr  = pma_perm_entry4;
  end

  pma_dmp_hit[5]:
  begin
      if (dmp_x2_target_r == `DMP_TARGET_PER)
        dpma_attr  = ((pma_perm_entry5[3:0] == 4'b0001)| (pma_perm_entry5[3:0] == 4'b0010)) ? pma_perm_entry5 : 6'b000001;
      else if (dmp_x2_ccm_hole_r)  // MEM Target
        dpma_attr  = ((&pma_perm_entry5[3:0]) | (pma_perm_entry5[3:0] == 4'b0100)| (pma_perm_entry5[3:0] == 4'b0011)) ? pma_perm_entry5 : 6'b000011;
      else
        dpma_attr  = pma_perm_entry5;
  end

  default:
  begin
    dpma_attr  = (dmp_x2_target_r == `DMP_TARGET_PER) ? 6'b000001 : ((dmp_x2_ccm_hole_r) ? 6'b000011 : 6'b110100);  
  end
  endcase
end


//////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : pma_cfg0_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_cfg0_r   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[0] == 1'b1)
    begin
      pma_cfg0_r <= csr_wdata[7:0];
    end
  
  end
end

always @(posedge clk or posedge rst_a)
begin : pma_cfg1_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_cfg1_r   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[1] == 1'b1)
    begin
      pma_cfg1_r <= csr_wdata[15:8];
    end
  
  end
end

always @(posedge clk or posedge rst_a)
begin : pma_cfg2_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_cfg2_r   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[2] == 1'b1)
    begin
      pma_cfg2_r <= csr_wdata[23:16];
    end
  
  end
end

always @(posedge clk or posedge rst_a)
begin : pma_cfg3_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_cfg3_r   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[3] == 1'b1)
    begin
      pma_cfg3_r <= csr_wdata[31:24];
    end
  
  end
end

always @(posedge clk or posedge rst_a)
begin : pma_cfg4_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_cfg4_r   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[4] == 1'b1)
    begin
      pma_cfg4_r <= csr_wdata[7:0];
    end
  
  end
end

always @(posedge clk or posedge rst_a)
begin : pma_cfg5_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_cfg5_r   <= 8'b0;
  end
  else
  begin
    if (csr_cfg_cg0[5] == 1'b1)
    begin
      pma_cfg5_r <= csr_wdata[15:8];
    end
  
  end
end



assign pma_cfg6_r = 8'b0;
assign pma_cfg7_r = 8'b0;


always @(posedge clk or posedge rst_a)
begin : pma_addr0_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_addr0_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[0] == 1'b1)
    begin
      pma_addr0_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : pma_addr1_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_addr1_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[1] == 1'b1)
    begin
      pma_addr1_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : pma_addr2_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_addr2_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[2] == 1'b1)
    begin
      pma_addr2_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : pma_addr3_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_addr3_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[3] == 1'b1)
    begin
      pma_addr3_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : pma_addr4_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_addr4_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[4] == 1'b1)
    begin
      pma_addr4_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : pma_addr5_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    pma_addr5_r      <= {`ADDR_SIZE{1'b0}};
  end
  else
  begin
    if (csr_addr_cg0[5] == 1'b1)
    begin
      pma_addr5_r      <= {2'b0, csr_wdata[29:0]};
    end
  end
end




endmodule // rl_pma

