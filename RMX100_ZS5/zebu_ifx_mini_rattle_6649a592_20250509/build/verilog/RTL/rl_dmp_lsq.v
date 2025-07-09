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

// Set simulation timescale
//
`include "const.def"
module rl_dmp_lsq (
  ////////// DMP pipeline interface /////////////////////////////////////////////
  //
  input                      dmp_lsq_write,         // Write into the LSQ
  input [4:0]                dmp_lsq_reg_id,        // LD destination register
  input                      dmp_lsq_read,          // LD instruction 
  input                      dmp_lsq_sex,           // Sign extension for LD
  input                      dmp_lsq_privileged,    // Mode of access is M or S
  input                      dmp_lsq_buff,          // Bufferability attribute
  input [`DMP_TARGET_RANGE]  dmp_lsq_target,        // Memory target (ICCM, MEM, PER)
  input [1:0]                dmp_lsq_size,          // Type of LD/ST, 00-Byte, 01-Half-word, 10-Word
  input [`ADDR_RANGE]        dmp_lsq_addr,          // Address 
  input [`DATA_RANGE]        dmp_lsq_data,          // ST data
  input                      dmp_lsq_store,         // ST instruction   
  input                      dmp_x2_strict_order,   // Ordering constraint
  input                      dmp_lsq_amo,           // Atomic flag
  input [`DMP_CTL_AMO_RANGE] dmp_lsq_amo_ctl,       // Atomic op-code
  input [`ADDR_RANGE]        dmp_lsq_addr1,         // Address1 
  input                      dmp_lsq_unaligned,     // Word-crossing
  ////////// LSQ scoreboarding /////////////////////////////////////////////
  //
  output                     lsq0_dst_valid,      // load destination
  output [4:0]               lsq0_dst_id,         // destination register - used for scoreboarding

  output                     lsq1_dst_valid,      // load destination
  output [4:0]               lsq1_dst_id,         // destination register - used for scoreboarding


  ////////// LSQ (LD) retirement interface ////////////////////////////////////
  //
  output reg                 lsq_rb_req_even,        // LSQ load req
  output reg                 lsq_rb_req_odd,         // LSQ load req
  output reg [4:0]           lsq_dst_id,             // LSQ load destination register
  output reg                 lsq_rb_err,             // LSQ bus error
  output reg [`DATA_RANGE]   lsq_rb_data_even,
  output reg [`DATA_RANGE]   lsq_rb_data_odd,
  output reg [1:0]           lsq_rb_size,            // Type of LD (B, HW, W)
  output reg [2:0]          lsq_rb_addr_2_to_0,     // addr
  output reg                 lsq_rb_sex,             // sign extension
// spyglass disable_block W240
// SMD: Signal declared but not used
// SJ:  LSQ requests for RB always have high priority
  input                      dmp_lsq_rb_ack,         // ack
// spyglass enable_block W240
  ////////// LSQ IBP mem interface ////////////////////////////////////////////////
  //
  output reg                 lsq_mem_cmd_valid,
  output reg [3:0]           lsq_mem_cmd_cache,
  output reg                 lsq_mem_cmd_burst_size,
  output reg                 lsq_mem_cmd_read,
  output reg                 lsq_mem_cmd_aux,
  input                      lsq_mem_cmd_accept,
  output reg [`ADDR_RANGE]   lsq_mem_cmd_addr,
  output reg                 lsq_mem_cmd_excl,
  output reg [5:0]           lsq_mem_cmd_atomic,
  output reg [2:0]           lsq_mem_cmd_data_size,
  output reg [1:0]           lsq_mem_cmd_prot,

  output reg                 lsq_mem_wr_valid,
  output reg                 lsq_mem_wr_last,
  input                      lsq_mem_wr_accept,
  output reg [3:0]           lsq_mem_wr_mask,
  output reg [31:0]          lsq_mem_wr_data,

  input                      lsq_mem_rd_valid,
  input                      lsq_mem_rd_err,
  input                      lsq_mem_rd_excl_ok,
  input                      lsq_mem_rd_last,
  output reg                 lsq_mem_rd_accept,
  input  [31:0]              lsq_mem_rd_data,

  input                      lsq_mem_wr_done,
  input                      lsq_mem_wr_excl_okay,
  input                      lsq_mem_wr_err,
  output reg                 lsq_mem_wr_resp_accept,

  ////////// LSQ IBP per interface ////////////////////////////////////////////////
  //
  output reg                 lsq_per_cmd_valid,
  output reg [3:0]           lsq_per_cmd_cache,
  output reg                 lsq_per_cmd_burst_size,
  output reg                 lsq_per_cmd_read,
  output reg                 lsq_per_cmd_aux,
  input                      lsq_per_cmd_accept,
  output reg [`ADDR_RANGE]   lsq_per_cmd_addr,
  output reg                 lsq_per_cmd_excl,
  output reg [5:0]           lsq_per_cmd_atomic,
  output reg [2:0]           lsq_per_cmd_data_size,
  output reg [1:0]           lsq_per_cmd_prot,

  output reg                 lsq_per_wr_valid,
  output reg                 lsq_per_wr_last,
  input                      lsq_per_wr_accept,
  output reg [3:0]           lsq_per_wr_mask,
  output reg [31:0]          lsq_per_wr_data,

  input                      lsq_per_rd_valid,
  input                      lsq_per_rd_err,
  input                      lsq_per_rd_excl_ok,
  input                      lsq_per_rd_last,
  output reg                 lsq_per_rd_accept,
  input  [31:0]              lsq_per_rd_data,

  input                      lsq_per_wr_done,
  input                      lsq_per_wr_excl_okay,
  input                      lsq_per_wr_err,
  output reg                 lsq_per_wr_resp_accept,

  ////////// LSQ IBP iccm interface ////////////////////////////////////////////////
  //
  output reg                 lsq_iccm_cmd_valid,
  output reg [3:0]           lsq_iccm_cmd_cache,
  output reg                 lsq_iccm_cmd_burst_size,
  output reg                 lsq_iccm_cmd_read,
  output reg                 lsq_iccm_cmd_aux,
  input                      lsq_iccm_cmd_accept,
  output reg [`ADDR_RANGE]   lsq_iccm_cmd_addr,
  output reg                 lsq_iccm_cmd_excl,
  output reg [5:0]           lsq_iccm_cmd_atomic,
  output reg [2:0]           lsq_iccm_cmd_data_size,
  output reg [1:0]           lsq_iccm_cmd_prot,

  output reg                 lsq_iccm_wr_valid,
  output reg                 lsq_iccm_wr_last,
  input                      lsq_iccm_wr_accept,
  output reg [3:0]           lsq_iccm_wr_mask,
  output reg [31:0]          lsq_iccm_wr_data,

  input                      lsq_iccm_rd_valid,
  input                      lsq_iccm_rd_err,
  input                      lsq_iccm_rd_excl_ok,
  input                      lsq_iccm_rd_last,
  output reg                 lsq_iccm_rd_accept,
  input  [31:0]              lsq_iccm_rd_data,

  input                      lsq_iccm_wr_done,
  input                      lsq_iccm_wr_excl_okay,
  input                      lsq_iccm_wr_err,
  output reg                 lsq_iccm_wr_resp_accept,

  ////////// LSQ IBP mmio interface ////////////////////////////////////////////////
  //
  output reg                 lsq_mmio_cmd_valid,
  output reg [3:0]           lsq_mmio_cmd_cache,
  output reg                 lsq_mmio_cmd_burst_size,
  output reg                 lsq_mmio_cmd_read,
  output reg                 lsq_mmio_cmd_aux,
  input                      lsq_mmio_cmd_accept,
  output reg [`ADDR_RANGE]   lsq_mmio_cmd_addr,
  output reg                 lsq_mmio_cmd_excl,
  output reg [5:0]           lsq_mmio_cmd_atomic,
  output reg [2:0]           lsq_mmio_cmd_data_size,
  output reg [1:0]           lsq_mmio_cmd_prot,

  output reg                 lsq_mmio_wr_valid,
  output reg                 lsq_mmio_wr_last,
  input                      lsq_mmio_wr_accept,
  output reg [3:0]           lsq_mmio_wr_mask,
  output reg [31:0]          lsq_mmio_wr_data,

  input                      lsq_mmio_rd_valid,
  input                      lsq_mmio_rd_err,
  input                      lsq_mmio_rd_excl_ok,
  input                      lsq_mmio_rd_last,
  output reg                 lsq_mmio_rd_accept,
  input  [31:0]              lsq_mmio_rd_data,

  input                      lsq_mmio_wr_done,
  input                      lsq_mmio_wr_excl_okay,
  input                      lsq_mmio_wr_err,
  output reg                 lsq_mmio_wr_resp_accept,


  ////////// LSQ Status ///////////////////////////////////////////////////////
  //
  output                     lsq_empty,
  output                     lsq_full,
  output                     lsq_bus_err,
  output                     lsq_wr_allowed,
  output                     lsq_has_amo,
  output                     lsq_target_uncached,
  output                     lsq_target_per,
  output                     lsq_st_pending,

  ////////// General input signals /////////////////////////////////////////////
  //
  input                      clk,                   // clock signal
  input                      rst_a                  // reset signal

);

///////////////////////////////////////////////////////////////////////////////
// This module hides the latency of the memory subsystem by queing (uncached) LD/ST
// without blocking the pipeline.Command and data transfers are decoupled, allowing
// for multiple outstanding transactions.
// The bus transactions are initiated in programming order
// The completion of a bus transaction for different memory targets can happen out-of-order.
//
// Unaligned transactions:
//
//
// Memory disambiguation:
//
//
//////////////////////////////////////////////////////////////////////////////////



wire                          lsq_fifo_cmd_valid;
wire                          lsq_fifo_cmd_read;
wire [`ADDR_RANGE]            lsq_fifo_cmd_addr;
wire [1:0]                    lsq_fifo_cmd_size;
wire                          lsq_fifo_cmd_privileged;
wire                          lsq_fifo_cmd_buff;
wire [`DMP_TARGET_RANGE]      lsq_fifo_cmd_target;
wire                          lsq_cmd_allowed;
reg [`IBP_CTL_AMO_RANGE]      dmp_lsq_atomic;
reg                           dmp_lsq_excl;
reg                           dmp_lsq_amoadd;
reg                           dmp_lsq_amoand;
reg                           dmp_lsq_amoor;
reg                           dmp_lsq_amoxor;
reg                           dmp_lsq_amomin;
reg                           dmp_lsq_amomax;
reg                           dmp_lsq_amominu;
reg                           dmp_lsq_amomaxu;
wire                          lsq_fifo_cmd_amo;
wire [`IBP_CTL_AMO_RANGE]     lsq_fifo_cmd_atop;
wire                          lsq_fifo_cmd_excl;
wire                          lsq_fifo_sc;
wire                          lsq_fifo_cmd_unaligned;
wire [3:0]                    lsq_fifo_wr_mask1;
wire                          lsq_fifo_rd_unaligned;
wire [`ADDR_RANGE]            lsq_fifo_wr_data;
wire [3:0]                    lsq_fifo_wr_mask;
wire                          lsq_cmd_pop;
wire                          lsq_cmd_to_fifo;
wire [`DMP_TARGET_RANGE]      lsq_cmd_target_r;

wire                          lsq_cmd_valid;
wire [1:0]                    lsq_cmd_data_size;
wire                          lsq_cmd_read;
wire [`ADDR_RANGE]            lsq_cmd_addr;
wire [`IBP_CTL_AMO_RANGE]     lsq_cmd_atomic;
wire                          lsq_cmd_excl;


wire                          lsq_fifo_rd_sex;
wire [4:0]                    lsq_fifo_rd_reg_id;
wire [1:0]                    lsq_fifo_rd_size;
wire [2:0]                    lsq_fifo_rd_addr_2_to_0;
wire                          lsq_fifo_rd_err;
wire [`DATA_RANGE]            lsq_fifo_rd_data;
wire [`DATA_RANGE]            lsq_fifo_rd_data_even;
wire [`DATA_RANGE]            lsq_fifo_rd_data_odd;

wire [`DMP_TARGET_RANGE]      lsq_fifo_target;

reg                           lsq_cmd_accept;
reg                           lsq_wr_accept;

wire                          lsq_wr_valid;
wire [`ADDR_RANGE]            lsq_wr_data;
wire [3:0]                    lsq_wr_mask;

reg                           lsq_rd_valid;
reg                           lsq_rd_err;
reg                           lsq_rd_excl_ok;
reg                           lsq_rd_last;
reg  [`DATA_RANGE]            lsq_rd_data;

reg                           lsq_wr_done;
reg                           lsq_wr_excl_okay;
reg                           lsq_wr_err;

// Map dmp_lsq_amo_ctl (1-hot) to dmp_lsq_atomic (IBP)
always @*
begin : dmp_lsq_atomic_PROC
  dmp_lsq_atomic = 6'b0;

  dmp_lsq_excl    = dmp_lsq_amo_ctl[`DMP_CTL_LOCK];
  dmp_lsq_amoadd  = dmp_lsq_amo_ctl[`DMP_CTL_AMOADD];
  dmp_lsq_amoand  = dmp_lsq_amo_ctl[`DMP_CTL_AMOAND];
  dmp_lsq_amoor   = dmp_lsq_amo_ctl[`DMP_CTL_AMOOR];
  dmp_lsq_amoxor  = dmp_lsq_amo_ctl[`DMP_CTL_AMOXOR];
  dmp_lsq_amomin  = dmp_lsq_amo_ctl[`DMP_CTL_AMOMIN];
  dmp_lsq_amomax  = dmp_lsq_amo_ctl[`DMP_CTL_AMOMAX];
  dmp_lsq_amominu = dmp_lsq_amo_ctl[`DMP_CTL_AMOMINU];
  dmp_lsq_amomaxu = dmp_lsq_amo_ctl[`DMP_CTL_AMOMAXU];

  if (dmp_lsq_amo)
  begin
    case (1'b1)
      dmp_lsq_amoadd  : dmp_lsq_atomic = 6'b100000; // ADD
      dmp_lsq_amoand  : dmp_lsq_atomic = 6'b100001; // AND
      dmp_lsq_amoor   : dmp_lsq_atomic = 6'b100011; // OR
      dmp_lsq_amoxor  : dmp_lsq_atomic = 6'b100010; // XOR
      dmp_lsq_amomin  : dmp_lsq_atomic = 6'b100101; // MIN
      dmp_lsq_amomax  : dmp_lsq_atomic = 6'b100100; // MAX
      dmp_lsq_amominu : dmp_lsq_atomic = 6'b100111; // MINU
      dmp_lsq_amomaxu : dmp_lsq_atomic = 6'b100110; // MAXU
      default         : dmp_lsq_atomic = 6'b110000; // SWAP
    endcase
  end
end

rl_dmp_lsq_cmd_port u_rl_dmp_lsq_cmd_port (
  .clk                   (clk                ),
  .rst_a                 (rst_a              ),

  .lsq_fifo_cmd_valid    (lsq_fifo_cmd_valid ),
  .lsq_fifo_cmd_size     (lsq_fifo_cmd_size  ),
  .lsq_fifo_cmd_read     (lsq_fifo_cmd_read  ),
  .lsq_fifo_cmd_addr     (lsq_fifo_cmd_addr  ),
  .lsq_fifo_cmd_target   (lsq_fifo_cmd_target),
  .lsq_fifo_cmd_amo      (lsq_fifo_cmd_amo   ),
  .lsq_fifo_cmd_atop     (lsq_fifo_cmd_atop  ),
  .lsq_fifo_cmd_excl     (lsq_fifo_cmd_excl),
  .lsq_fifo_cmd_unaligned (lsq_fifo_cmd_unaligned),
  .lsq_fifo_wr_mask1      (lsq_fifo_wr_mask1     ),

  .lsq_fifo_wr_data      (lsq_fifo_wr_data   ),
  .lsq_fifo_wr_mask      (lsq_fifo_wr_mask   ),

  .lsq_cmd_allowed       (lsq_cmd_allowed    ),
  .lsq_cmd_pop           (lsq_cmd_pop        ),
  .lsq_cmd_to_fifo       (lsq_cmd_to_fifo    ),
  .lsq_cmd_target_r      (lsq_cmd_target_r   ),

  .lsq_cmd_valid         (lsq_cmd_valid      ),
  .lsq_cmd_data_size     (lsq_cmd_data_size  ),
  .lsq_cmd_read          (lsq_cmd_read       ),
  .lsq_cmd_addr          (lsq_cmd_addr       ),
  .lsq_cmd_atomic        (lsq_cmd_atomic     ),
  .lsq_cmd_excl          (lsq_cmd_excl       ),
  .lsq_cmd_accept        (lsq_cmd_accept     ),

  .lsq_wr_valid          (lsq_wr_valid       ),
  .lsq_wr_accept         (lsq_wr_accept      ),
  .lsq_wr_data           (lsq_wr_data        ),
  .lsq_wr_mask           (lsq_wr_mask        )
);

///////////////////////////////////////////////////////////////////////////////
// IBP command/write data
//
//////////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_ibp_cmd_PROC
  // Drive the IBP command / Write data phase
  //
  lsq_iccm_cmd_valid        = 1'b0;
  lsq_iccm_cmd_cache        = 4'b0000;
  lsq_iccm_cmd_burst_size   = 1'b0;
  lsq_iccm_cmd_read         = 1'b1;
  lsq_iccm_cmd_aux          = 1'b0;
  lsq_iccm_cmd_addr         = 32'd0;
  lsq_iccm_cmd_excl         = 1'b0;
  lsq_iccm_cmd_atomic       = 6'b0;
  lsq_iccm_cmd_data_size    = 3'd0;
  lsq_iccm_cmd_prot         = 2'b00;

  lsq_iccm_wr_valid         = 1'b0;
  lsq_iccm_wr_data          = 32'd0;
  lsq_iccm_wr_mask          = 4'b0000;
  lsq_iccm_wr_last          = 1'b0;

  lsq_iccm_rd_accept        = 1'b1;
  lsq_iccm_wr_resp_accept   = 1'b1;

  lsq_mem_cmd_valid         = 1'b0;
  lsq_mem_cmd_cache         = 4'b0000;
  lsq_mem_cmd_burst_size    = 1'b0;
  lsq_mem_cmd_read          = 1'b1;
  lsq_mem_cmd_aux           = 1'b0;
  lsq_mem_cmd_addr          = 32'd0;
  lsq_mem_cmd_excl          = 1'b0;
  lsq_mem_cmd_atomic        = 6'b0;
  lsq_mem_cmd_data_size     = 3'd0;
  lsq_mem_cmd_prot          = 2'b00;

  lsq_mem_wr_valid          = 1'b0;
  lsq_mem_wr_data           = 32'd0;
  lsq_mem_wr_mask           = 4'b0000;
  lsq_mem_wr_last           = 1'b0;

  lsq_mem_rd_accept         = 1'b1;
  lsq_mem_wr_resp_accept    = 1'b1;

  lsq_per_cmd_valid         = 1'b0;
  lsq_per_cmd_cache         = 4'b0000;
  lsq_per_cmd_burst_size    = 1'b0;
  lsq_per_cmd_read          = 1'b1;
  lsq_per_cmd_aux           = 1'b0;
  lsq_per_cmd_addr          = 32'd0;
  lsq_per_cmd_excl          = 1'b0;
  lsq_per_cmd_atomic        = 6'b0;
  lsq_per_cmd_data_size     = 3'd0;
  lsq_per_cmd_prot          = 2'b00;

  lsq_per_wr_valid          = 1'b0;
  lsq_per_wr_data           = 32'd0;
  lsq_per_wr_mask           = 4'b0000;
  lsq_per_wr_last           = 1'b0;

  lsq_per_rd_accept         = 1'b1;
  lsq_per_wr_resp_accept    = 1'b1;

  lsq_mmio_cmd_valid        = 1'b0;
  lsq_mmio_cmd_cache        = 4'b0000;
  lsq_mmio_cmd_burst_size   = 1'b0;
  lsq_mmio_cmd_read         = 1'b1;
  lsq_mmio_cmd_aux          = 1'b0;
  lsq_mmio_cmd_addr         = 32'd0;
  lsq_mmio_cmd_excl         = 1'b0;
  lsq_mmio_cmd_atomic       = 6'b0;
  lsq_mmio_cmd_data_size    = 3'd0;
  lsq_mmio_cmd_prot         = 2'b00;

  lsq_mmio_wr_valid         = 1'b0;
  lsq_mmio_wr_data          = 32'd0;
  lsq_mmio_wr_mask          = 4'b0000;
  lsq_mmio_wr_last          = 1'b0;

  lsq_mmio_rd_accept        = 1'b1;
  lsq_mmio_wr_resp_accept   = 1'b1;


  case (lsq_fifo_cmd_target)
  3'd`DMP_TARGET_ICCM:
  begin
    lsq_iccm_cmd_valid        = lsq_cmd_valid;
    lsq_iccm_cmd_addr         = lsq_cmd_addr;
    lsq_iccm_cmd_read         = lsq_cmd_read;
    lsq_iccm_cmd_data_size    = {1'b0,lsq_cmd_data_size};
    lsq_iccm_cmd_prot         = {1'b0,lsq_fifo_cmd_privileged};
    lsq_iccm_cmd_cache        = {3'b000,lsq_fifo_cmd_buff};
    lsq_iccm_cmd_atomic       = lsq_cmd_atomic;
    lsq_iccm_cmd_excl         = lsq_cmd_excl;

    lsq_iccm_wr_valid         = lsq_wr_valid;
    lsq_iccm_wr_data          = lsq_wr_data;
    lsq_iccm_wr_mask          = lsq_wr_mask;
    lsq_iccm_wr_last          = 1'b1;
  end
  3'd`DMP_TARGET_PER:
  begin
    lsq_per_cmd_valid         = lsq_cmd_valid;
    lsq_per_cmd_addr          = lsq_cmd_addr;
    lsq_per_cmd_read          = lsq_cmd_read;
    lsq_per_cmd_data_size     = {1'b0,lsq_cmd_data_size};
    lsq_per_cmd_prot          = {1'b0,lsq_fifo_cmd_privileged};
    lsq_per_cmd_cache         = {3'b000,lsq_fifo_cmd_buff};
    lsq_per_cmd_atomic        = lsq_cmd_atomic;
    lsq_per_cmd_excl          = lsq_cmd_excl;

    lsq_per_wr_valid          = lsq_wr_valid;
    lsq_per_wr_data           = lsq_wr_data;
    lsq_per_wr_mask           = lsq_wr_mask;
    lsq_per_wr_last           = 1'b1;
  end

  3'd`DMP_TARGET_MMIO:
  begin
    lsq_mmio_cmd_valid        = lsq_cmd_valid;
    lsq_mmio_cmd_addr         = lsq_cmd_addr;
    lsq_mmio_cmd_read         = lsq_cmd_read;
    lsq_mmio_cmd_data_size    = {1'b0,lsq_cmd_data_size};
    lsq_mmio_cmd_prot         = {1'b0,lsq_fifo_cmd_privileged};
    lsq_mmio_cmd_cache        = {3'b000,lsq_fifo_cmd_buff};
    lsq_mmio_cmd_atomic       = lsq_cmd_atomic;
    lsq_mmio_cmd_excl         = lsq_cmd_excl;

    lsq_mmio_wr_valid         = lsq_wr_valid;
    lsq_mmio_wr_data          = lsq_wr_data;
    lsq_mmio_wr_mask          = lsq_wr_mask;
    lsq_mmio_wr_last          = 1'b1;
  end
  default:
  begin
    lsq_mem_cmd_valid         = lsq_cmd_valid;
    lsq_mem_cmd_addr          = lsq_cmd_addr;
    lsq_mem_cmd_read          = lsq_cmd_read;
    lsq_mem_cmd_data_size     = {1'b0,lsq_cmd_data_size};
    lsq_mem_cmd_prot          = {1'b0,lsq_fifo_cmd_privileged};
    lsq_mem_cmd_cache         = {3'b000,lsq_fifo_cmd_buff};
    lsq_mem_cmd_atomic        = lsq_cmd_atomic;
    lsq_mem_cmd_excl          = lsq_cmd_excl;

    lsq_mem_wr_valid          = lsq_wr_valid;
    lsq_mem_wr_data           = lsq_wr_data;
    lsq_mem_wr_mask           = lsq_wr_mask;
    lsq_mem_wr_last           = 1'b1;
  end
  endcase
end


///////////////////////////////////////////////////////////////////////////////
// IBP response
//
//////////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_ibp_resp_PROC

  // Command response
  //
  lsq_cmd_accept         = 1'b0;
  lsq_wr_accept          = 1'b0;

  // Read response
  //
  lsq_rd_valid           = 1'b0;
  lsq_rd_err             = 1'b0;
  lsq_rd_excl_ok         = 1'b0;
  lsq_rd_last            = 1'b0;
  lsq_rd_data            = 32'd0;

  // Write response
  //
  lsq_wr_done            = 1'b0;
  lsq_wr_excl_okay       = 1'b0;
  lsq_wr_err             = 1'b0;

  case (lsq_fifo_cmd_target)
  3'd`DMP_TARGET_ICCM:
  begin
    lsq_cmd_accept    = lsq_iccm_cmd_accept;
    lsq_wr_accept     = lsq_iccm_wr_accept;
  end
  3'd`DMP_TARGET_PER:
  begin
    lsq_cmd_accept    = lsq_per_cmd_accept;
    lsq_wr_accept     = lsq_per_wr_accept;
  end
  3'd`DMP_TARGET_MMIO:
  begin
    lsq_cmd_accept    = lsq_mmio_cmd_accept;
    lsq_wr_accept     = lsq_mmio_wr_accept;
  end
  default:
  begin
    lsq_cmd_accept    = lsq_mem_cmd_accept;
    lsq_wr_accept     = lsq_mem_wr_accept;
  end
  endcase


  case (lsq_fifo_target)
  3'd`DMP_TARGET_ICCM:
  begin
    lsq_rd_valid      = lsq_iccm_rd_valid;
    lsq_rd_last       = lsq_iccm_rd_last;
    lsq_rd_err        = lsq_iccm_rd_err;
    lsq_rd_excl_ok    = lsq_iccm_rd_excl_ok;
    lsq_rd_data       = lsq_iccm_rd_data;

    lsq_wr_done       = lsq_iccm_wr_done;
    lsq_wr_excl_okay  = lsq_iccm_wr_excl_okay;
    lsq_wr_err        = lsq_iccm_wr_err;
  end
  3'd`DMP_TARGET_PER:
  begin
    lsq_rd_valid      = lsq_per_rd_valid;
    lsq_rd_last       = lsq_per_rd_last;
    lsq_rd_err        = lsq_per_rd_err;
    lsq_rd_excl_ok    = lsq_per_rd_excl_ok;
    lsq_rd_data       = lsq_per_rd_data;

    lsq_wr_done       = lsq_per_wr_done;
    lsq_wr_excl_okay  = lsq_per_wr_excl_okay;
    lsq_wr_err        = lsq_per_wr_err;
  end
  3'd`DMP_TARGET_MMIO:
  begin
    lsq_rd_valid      = lsq_mmio_rd_valid;
    lsq_rd_last       = lsq_mmio_rd_last;
    lsq_rd_err        = lsq_mmio_rd_err;
    lsq_rd_excl_ok    = lsq_mmio_rd_excl_ok;
    lsq_rd_data       = lsq_mmio_rd_data;

    lsq_wr_done       = lsq_mmio_wr_done;
    lsq_wr_excl_okay  = lsq_mmio_wr_excl_okay;
    lsq_wr_err        = lsq_mmio_wr_err;
  end
  default:
  begin
    lsq_rd_valid      = lsq_mem_rd_valid;
    lsq_rd_last       = lsq_mem_rd_last;
    lsq_rd_err        = lsq_mem_rd_err;
    lsq_rd_excl_ok    = lsq_mem_rd_excl_ok;
    lsq_rd_data       = lsq_mem_rd_data;

    lsq_wr_done       = lsq_mem_wr_done;
    lsq_wr_excl_okay  = lsq_mem_wr_excl_okay;
    lsq_wr_err        = lsq_mem_wr_err;
  end
  endcase
end



///////////////////////////////////////////////////////////////////////////////
// Requesting DMP result bus
//
//////////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_rb_PROC
  // Default values
  //
  lsq_rb_req_even    = (lsq_rd_valid & lsq_rd_last & (lsq_fifo_rd_addr_2_to_0[2] == 1'b0)     // IBP
                     & (~lsq_fifo_rd_unaligned)
                       )
                     | (lsq_wr_done & lsq_fifo_sc)
                       ;
  lsq_rb_req_odd     = (lsq_rd_valid & lsq_rd_last & (lsq_fifo_rd_addr_2_to_0[2] == 1'b1)     // IBP
                     & (~lsq_fifo_rd_unaligned)
                       )
                     | (lsq_wr_done & lsq_fifo_sc)
                       ;
  
  lsq_rb_err         = lsq_fifo_rd_err;
  lsq_rb_data_even   = lsq_fifo_rd_data_even;
  lsq_rb_data_odd    = lsq_fifo_rd_data_odd;
  lsq_rb_size        = lsq_fifo_rd_size;
  lsq_dst_id         = lsq_fifo_rd_reg_id;
  lsq_rb_addr_2_to_0 = lsq_fifo_rd_addr_2_to_0[2:0];
  lsq_rb_sex         = lsq_fifo_rd_sex;
end


///////////////////////////////////////////////////////////////////////////////
// Module instantiation
//
//////////////////////////////////////////////////////////////////////////////////

rl_dmp_lsq_fifo  u_rl_dmp_lsq_fifo (
  .dmp_lsq_write               (dmp_lsq_write          ),
  .dmp_lsq_reg_id              (dmp_lsq_reg_id         ),
  .dmp_lsq_read                (dmp_lsq_read           ),
  .dmp_x2_strict_order         (dmp_x2_strict_order    ), 
  .dmp_lsq_store               (dmp_lsq_store          ),  
  .dmp_lsq_sex                 (dmp_lsq_sex            ),
  .dmp_lsq_privileged          (dmp_lsq_privileged     ),
  .dmp_lsq_buff                (dmp_lsq_buff           ),
  .dmp_lsq_target              (dmp_lsq_target         ),
  .dmp_lsq_size                (dmp_lsq_size           ),
  .dmp_lsq_addr                (dmp_lsq_addr           ), 
  .dmp_lsq_data                (dmp_lsq_data           ), 
  .dmp_lsq_atomic              (dmp_lsq_atomic         ),
  .dmp_lsq_excl                (dmp_lsq_excl           ),
  .dmp_lsq_addr1               (dmp_lsq_addr1          ), 
  .dmp_lsq_unaligned           (dmp_lsq_unaligned      ),
  .lsq0_dst_valid           (lsq0_dst_valid      ),
  .lsq0_dst_id              (lsq0_dst_id         ),

  .lsq1_dst_valid           (lsq1_dst_valid      ),
  .lsq1_dst_id              (lsq1_dst_id         ),


  .lsq_fifo_cmd_valid          (lsq_fifo_cmd_valid     ),
  .lsq_fifo_cmd_read           (lsq_fifo_cmd_read      ),
  .lsq_fifo_cmd_addr           (lsq_fifo_cmd_addr      ),
  .lsq_fifo_cmd_size           (lsq_fifo_cmd_size      ),
  .lsq_fifo_cmd_privileged     (lsq_fifo_cmd_privileged),
  .lsq_fifo_cmd_buff           (lsq_fifo_cmd_buff      ),
  .lsq_fifo_cmd_target         (lsq_fifo_cmd_target    ),
  .lsq_fifo_cmd_amo            (lsq_fifo_cmd_amo       ),
  .lsq_fifo_cmd_atop           (lsq_fifo_cmd_atop      ),
  .lsq_fifo_cmd_excl           (lsq_fifo_cmd_excl      ),
  .lsq_fifo_cmd_unaligned      (lsq_fifo_cmd_unaligned ),

  .lsq_fifo_wr_mask1           (lsq_fifo_wr_mask1      ),

  .lsq_fifo_wr_data            (lsq_fifo_wr_data       ),
  .lsq_fifo_wr_mask            (lsq_fifo_wr_mask       ),

  .lsq_cmd_allowed             (lsq_cmd_allowed        ),

  .lsq_fifo_rd_sex             (lsq_fifo_rd_sex        ),
  .lsq_fifo_rd_reg_id          (lsq_fifo_rd_reg_id     ),
  .lsq_fifo_rd_size            (lsq_fifo_rd_size       ),
  .lsq_fifo_rd_addr_2_to_0     (lsq_fifo_rd_addr_2_to_0),
  .lsq_fifo_rd_err             (lsq_fifo_rd_err        ),
  .lsq_fifo_rd_data_even       (lsq_fifo_rd_data_even  ),
  .lsq_fifo_rd_data_odd        (lsq_fifo_rd_data_odd   ),
  .lsq_fifo_rd_unaligned       (lsq_fifo_rd_unaligned  ),
  .lsq_fifo_sc                 (lsq_fifo_sc            ),
  .lsq_fifo_target             (lsq_fifo_target        ),
  .lsq_cmd_pop                 (lsq_cmd_pop            ),
  .lsq_cmd_to_fifo             (lsq_cmd_to_fifo        ),
  .lsq_cmd_target_r            (lsq_cmd_target_r       ),

  .lsq_rd_valid                (lsq_rd_valid           ),
  .lsq_rd_last                 (lsq_rd_last            ),
  .lsq_rd_err                  (lsq_rd_err             ),
  .lsq_rd_data                 (lsq_rd_data            ),
  .lsq_rd_excl_ok              (lsq_rd_excl_ok         ),

  .lsq_wr_excl_okay            (lsq_wr_excl_okay       ),
  .lsq_wr_done                 (lsq_wr_done            ),
  .lsq_wr_err                  (lsq_wr_err             ),

  .lsq_empty                   (lsq_empty              ),
  .lsq_full                    (lsq_full               ),
  .lsq_wr_pop                  (lsq_wr_allowed         ),
  .lsq_bus_err                 (lsq_bus_err            ),
  .lsq_has_amo                 (lsq_has_amo            ),
  .lsq_target_uncached         (lsq_target_uncached    ),
  .lsq_target_per              (lsq_target_per         ),  
  .lsq_st_pending              (lsq_st_pending         ),

  .clk                         (clk                    ),
  .rst_a                       (rst_a                  )


);

endmodule // rl_dmp_lsq

