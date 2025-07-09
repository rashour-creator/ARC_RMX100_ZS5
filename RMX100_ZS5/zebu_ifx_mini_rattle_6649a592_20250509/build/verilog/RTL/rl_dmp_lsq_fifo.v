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
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_dmp_lsq_fifo (
  ////////// FIFO write interface /////////////////////////////////////////////
  //
  input                           dmp_lsq_write,          // Write into the LSQ
  input [4:0]                     dmp_lsq_reg_id,         // Destination register
  input                           dmp_lsq_read,           // LD instruction
  input                           dmp_lsq_sex,            // Sign extension for LD
  input                           dmp_lsq_privileged,     // Mode of access is M or S
  input                           dmp_lsq_buff,           // Bufferability attribute
  input [`DMP_TARGET_RANGE]       dmp_lsq_target,         // Memory target (ICCM, MEM, PER)
  input [1:0]                     dmp_lsq_size,           // Type of LD/ST (B, HW, W), 00-Byte, 01-Half-word, 10-Word
  input [`ADDR_RANGE]             dmp_lsq_addr,           // Address
  input [`DATA_RANGE]             dmp_lsq_data,           // ST data
  input                           dmp_lsq_store,          // ST instruction  
  input                           dmp_x2_strict_order,    // Ordering constraint
  input [`IBP_CTL_AMO_RANGE]      dmp_lsq_atomic,         // IBP atomic field
  input                           dmp_lsq_excl,           // IBP excl field
  input [`ADDR_RANGE]             dmp_lsq_addr1,          // Address1
  input                           dmp_lsq_unaligned,      // Word-crossing

  ////////// LSQ scoreboarding /////////////////////////////////////////////
  //
  output                          lsq0_dst_valid,      // load destination
  output [4:0]                    lsq0_dst_id,         // destination register - used for scoreboarding
  output                          lsq1_dst_valid,      // load destination
  output [4:0]                    lsq1_dst_id,         // destination register - used for scoreboarding

  ////////// Top of the cmd FIFO ////////////////////////////////////
  //
  output reg                      lsq_fifo_cmd_valid,
  output reg                      lsq_fifo_cmd_read,
  output reg [`ADDR_RANGE]        lsq_fifo_cmd_addr,
  output reg [1:0]                lsq_fifo_cmd_size,
  output reg                      lsq_fifo_cmd_privileged,
  output reg                      lsq_fifo_cmd_buff,      // bit[0] of cmd_cache IBP attribute

  output reg [`DMP_TARGET_RANGE]  lsq_fifo_cmd_target,
  output reg                      lsq_fifo_cmd_amo,
  output reg [`IBP_CTL_AMO_RANGE] lsq_fifo_cmd_atop,
  output reg                      lsq_fifo_cmd_excl,
  output reg                      lsq_fifo_cmd_unaligned,

  output reg                      lsq_cmd_allowed,


  ////////// Top of the wr data FIFO ////////////////////////////////////
  //
  output reg [`DATA_RANGE]        lsq_fifo_wr_data,
  output reg [3:0]                lsq_fifo_wr_mask,
  output reg [3:0]                lsq_fifo_wr_mask1,

  ////////// Top of the rd data FIFO ////////////////////////////////////
  //
  output reg                      lsq_fifo_rd_sex,
  output reg [4:0]                lsq_fifo_rd_reg_id,
  output reg [1:0]                lsq_fifo_rd_size,
  output reg [2:0]                lsq_fifo_rd_addr_2_to_0,
  output reg                      lsq_fifo_rd_err,

  output reg [`DATA_RANGE]        lsq_fifo_rd_data_even,
  output reg [`DATA_RANGE]        lsq_fifo_rd_data_odd,
  output reg                      lsq_fifo_rd_unaligned,  // Top of the LSQ handling first part of unaligned transfer
  output reg                      lsq_fifo_sc,

  ////////// Memory target in the LSQ ////////////////////////////////////
  //
  output [`DMP_TARGET_RANGE]      lsq_fifo_target,

  ////////// FIFO IBP interface ////////////////////////////////////
  //
  input                           lsq_cmd_pop,           // Advance command read pointer
  input                           lsq_cmd_to_fifo,       // Push an entry into LD/ST FIFO
  input [`DMP_TARGET_RANGE]       lsq_cmd_target_r,      // IBP memory target
  input                           lsq_rd_valid,          // IBP
  input                           lsq_rd_last,           // IBP
  input                           lsq_rd_err,            // IBP
  input [`DATA_RANGE]             lsq_rd_data,           // IBP
  input                           lsq_rd_excl_ok,

  input                           lsq_wr_excl_okay,
  input                           lsq_wr_done,
  input                           lsq_wr_err,

  ////////// LSQ Status ///////////////////////////////////////////////////////
  //
  output                          lsq_empty,
  output                          lsq_full,
  output                          lsq_bus_err,
  output reg                      lsq_wr_pop,
  output                          lsq_has_amo,
  output                          lsq_target_uncached,
  output                          lsq_target_per,
  output                          lsq_st_pending,

  ////////// General input signals /////////////////////////////////////////////
  //
  input                           clk,                   // clock signal
  input                           rst_a                  // reset signal

);

// Local declarations
//
reg [`DMP_LSQ_RANGE]      lsq_valid_r;
reg [`DMP_LSQ_RANGE]      lsq_read_r;                  // 1: read, 0: write
reg [`DMP_LSQ_RANGE]      lsq_completed_r;             // transaction completed
reg [`DMP_LSQ_RANGE]      lsq_bus_err_r;               // transaction completed with a bus error
reg [`ADDR_RANGE]         lsq_addr_r[`DMP_LSQ_RANGE];
reg [`DATA_RANGE]         lsq_data_r[`DMP_LSQ_RANGE];
reg [1:0]                 lsq_size_r[`DMP_LSQ_RANGE];
reg [`DMP_LSQ_RANGE]      lsq_sex_r;
reg [`DMP_LSQ_RANGE]      lsq_privileged_r;
reg [`DMP_LSQ_RANGE]      lsq_buff_r;
reg [`DMP_LSQ_RANGE]      lsq_cmd_out_r;
reg [4:0]                 lsq_reg_id_r[`DMP_LSQ_RANGE];
reg [`DMP_TARGET_RANGE]   lsq_target_r[`DMP_LSQ_RANGE];
reg [`DMP_LSQ_RANGE]      lsq_dep_r[`DMP_LSQ_RANGE];
reg [`DMP_LSQ_RANGE]      lsq_hazard_dep_r[`DMP_LSQ_RANGE];
reg                       lsq_unaligned_r[`DMP_LSQ_RANGE];
reg                       lsq_word_cross_r[`DMP_LSQ_RANGE];
reg                       lsq_idx_r[`DMP_LSQ_RANGE];
reg [`DMP_LSQ_RANGE]      lsq_atomic_r;
reg [`IBP_CTL_AMO_RANGE]  lsq_atop_r[`DMP_LSQ_RANGE];
reg [`DMP_LSQ_RANGE]      lsq_excl_r;

reg [`DMP_LSQ_RANGE]      lsq_valid_nxt;
reg                       lsq_read_nxt;
reg                       lsq_completed_nxt;
reg [`DMP_LSQ_RANGE]      lsq_bus_err_cg0;
reg [`DMP_LSQ_RANGE]      lsq_bus_err_nxt;
reg [`ADDR_RANGE]         lsq_addr_nxt;
reg [`DATA_RANGE]         lsq_data_nxt;
reg [1:0]                 lsq_size_nxt;
reg                       lsq_sex_nxt;
reg                       lsq_privileged_nxt;
reg                       lsq_buff_nxt;
reg                       lsq_cmd_out_cg0;
reg [`DMP_LSQ_RANGE]      lsq_cmd_out_nxt;
reg [`DMP_TARGET_RANGE]   lsq_target_nxt;
reg [`DMP_LSQ_RANGE]      lsq_dep_nxt;
reg [`DMP_LSQ_RANGE]      lsq_hazard_dep_nxt;
reg                       lsq_unaligned_nxt;
reg                       lsq_idx_nxt;
reg [`IBP_CTL_AMO_RANGE]  lsq_atomic_nxt;
reg                       lsq_excl_nxt;
reg                       lsq_fifo_atop;
reg                       lsq_sc_cg0;
reg                       lsq_sc_success_r;
reg [`DMP_LSQ_RANGE]      lsq_update_atop_cg0;
reg                       lsq_fifo_lr;
reg                       lsq_valid_cg0;
reg [`DMP_LSQ_RANGE]      lsq_write_global_cg0;
reg [`DMP_LSQ_RANGE]      lsq_write_data_cg0;
reg [`DMP_LSQ_RANGE]      lsq_write_reg_id_cg0;
reg [`DMP_LSQ_RANGE]      lsq_update_cg0;
reg [`DMP_LSQ_RANGE]      lsq_update_rd_data_cg0;

reg [`DMP_LSQ_RANGE]      lsq_ld_completed;
reg [`DMP_LSQ_RANGE]      lsq_st_completed;

// Pointers
//
reg                       lsq_cmd_wr_ptr_cg0;
reg [`DMP_LSQ_PTR_RANGE]  lsq_cmd_wr_ptr_r;   // Entry to write a new LD/ST transaction
reg [`DMP_LSQ_PTR_RANGE]  lsq_cmd_wr_ptr_nxt;

reg                       lsq_cmd_rd_ptr_cg0;
reg [`DMP_LSQ_PTR_RANGE]  lsq_cmd_rd_ptr_r;
reg [`DMP_LSQ_PTR_RANGE]  lsq_cmd_rd_ptr_nxt;

wire [`DMP_LSQ_PTR_RANGE] lsq_ld_ptr;   // Points to top LD transaction
wire [`DMP_LSQ_PTR_RANGE] lsq_st_ptr;   // Points to top ST transaction
reg [`DMP_LSQ_RANGE]      lsq_unaligned_update_cg0;
reg                       lsq_fifo_wr_unaligned;

reg                       lsq_data_even_cg0;
reg                       lsq_data_odd_cg0;
reg [`DATA_RANGE]         lsq_ld_data_even_r;
reg [`DATA_RANGE]         lsq_ld_data_odd_r;

reg                       lsq_ld_rd_ptr_cg0;
reg [`DMP_LSQ_PTR_RANGE]  lsq_ld_rd_ptr_r;
reg [`DMP_LSQ_PTR_RANGE]  lsq_ld_rd_ptr_nxt;

reg                       lsq_global_rd_ptr_cg0;
reg [`DMP_LSQ_PTR_RANGE]  lsq_global_rd_ptr_r;
reg [`DMP_LSQ_PTR_RANGE]  lsq_global_rd_ptr_nxt;
reg                       lsq_global_pop;
reg                       lsq_trans_pend;



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Writing into the LSQ
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_write_PROC
  // Value to be written
  //
  lsq_read_nxt        = dmp_lsq_read;
  lsq_addr_nxt        = dmp_lsq_addr;
  lsq_data_nxt        = (dmp_lsq_atomic[2:0] == 3'b001) ? ~dmp_lsq_data : dmp_lsq_data;
  lsq_size_nxt        = dmp_lsq_size;
  lsq_sex_nxt         = dmp_lsq_sex;
  lsq_privileged_nxt  = dmp_lsq_privileged;
  lsq_buff_nxt        = dmp_lsq_buff & (~dmp_lsq_read);
  lsq_target_nxt      = dmp_lsq_target;
  lsq_unaligned_nxt   = dmp_lsq_unaligned;
  lsq_idx_nxt         = dmp_lsq_addr[2];
  lsq_atomic_nxt      = dmp_lsq_atomic;
  lsq_excl_nxt        = dmp_lsq_excl;
  // Write upon completion
  //
  lsq_completed_nxt   = 1'b0;
  lsq_dep_nxt         = {`DMP_LSQ_DEPTH{~dmp_lsq_read}} 
                      & lsq_valid_r; 
  if (lsq_global_pop == 1'b1)
  begin
    lsq_dep_nxt[lsq_global_rd_ptr_r] = 1'b0; 
  end  
end

//////////////////////////////////////////////////////////////////////////////
// Set-up an X2 RAW/WAR hazard
//
//////////////////////////////////////////////////////////////////////////////

  reg [`ADDR_RANGE]    lsq_addr1[`DMP_LSQ_RANGE];
  reg [`DMP_LSQ_RANGE] dmp_x2_lsq_match_entries;
  reg [`DMP_LSQ_RANGE] dmp_x2_raw_hazard_entries;
  reg [`DMP_LSQ_RANGE] dmp_x2_war_hazard_entries;
  reg                  lsq0_addr00_match;
  reg                  lsq0_addr01_match;
  reg                  lsq0_addr10_match;
  reg                  lsq1_addr00_match;
  reg                  lsq1_addr01_match;
  reg                  lsq1_addr10_match;
  always @*
  begin : hazard_dependency_PROC
  
    lsq_addr1[0]        = {lsq_addr_r[0][31:2] + {{`ADDR_SIZE-3{1'b0}},1'b1}, 2'b00};
  
    lsq0_addr00_match = (dmp_lsq_addr[19:2] == lsq_addr_r[0][19:2])
                         & (dmp_lsq_addr[31:28] == lsq_addr_r[0][31:28]);

    lsq0_addr01_match = (dmp_lsq_addr[19:2] == lsq_addr1[0][19:2])
                         & (dmp_lsq_addr[31:28] == lsq_addr1[0][31:28])    
                         & lsq_word_cross_r[0];
  
    lsq0_addr10_match = (dmp_lsq_addr1[19:2] == lsq_addr_r[0][19:2])
                         & (dmp_lsq_addr1[31:28] == lsq_addr_r[0][31:28])
                         & dmp_lsq_unaligned;
  
    lsq_addr1[1]        = {lsq_addr_r[1][31:2] + {{`ADDR_SIZE-3{1'b0}},1'b1}, 2'b00};
  
    lsq1_addr00_match = (dmp_lsq_addr[19:2] == lsq_addr_r[1][19:2])
                         & (dmp_lsq_addr[31:28] == lsq_addr_r[1][31:28]);

    lsq1_addr01_match = (dmp_lsq_addr[19:2] == lsq_addr1[1][19:2])
                         & (dmp_lsq_addr[31:28] == lsq_addr1[1][31:28])    
                         & lsq_word_cross_r[1];
  
    lsq1_addr10_match = (dmp_lsq_addr1[19:2] == lsq_addr_r[1][19:2])
                         & (dmp_lsq_addr1[31:28] == lsq_addr_r[1][31:28])
                         & dmp_lsq_unaligned;
  
    dmp_x2_lsq_match_entries[0] = lsq0_addr00_match
                                 | lsq0_addr01_match
                                 | lsq0_addr10_match
                                 ;
  
    dmp_x2_lsq_match_entries[1] = lsq1_addr00_match
                                 | lsq1_addr01_match
                                 | lsq1_addr10_match
                                 ;
  
  
    dmp_x2_raw_hazard_entries    = (  dmp_x2_lsq_match_entries
                                    | {`DMP_LSQ_ENTRIES{dmp_x2_strict_order}})
                                 & {`DMP_LSQ_ENTRIES{dmp_lsq_read}}
                                 & lsq_valid_r & (~lsq_read_r) & (~lsq_completed_r);
  
    dmp_x2_war_hazard_entries    = (  dmp_x2_lsq_match_entries
                                    | {`DMP_LSQ_ENTRIES{dmp_x2_strict_order}})
                                 & {`DMP_LSQ_ENTRIES{dmp_lsq_store}}
                                 & lsq_valid_r & lsq_read_r & (~lsq_completed_r);
  
    lsq_hazard_dep_nxt           = dmp_x2_raw_hazard_entries
                                 | dmp_x2_war_hazard_entries;
    
    if (|lsq_ld_completed)
    begin
      lsq_hazard_dep_nxt[lsq_ld_ptr] = 1'b0;
    end
  
    if ((|lsq_st_completed) | lsq_wr_pop)
    begin
      lsq_hazard_dep_nxt[lsq_st_ptr] = 1'b0;
    end
  end
  
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Command write pointer
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_cmd_wr_ptr_nxt_PROC
  // Advance the write pointer on every write
  //
  lsq_cmd_wr_ptr_cg0 = dmp_lsq_write;
  lsq_cmd_rd_ptr_cg0 = lsq_cmd_pop;

  lsq_cmd_wr_ptr_nxt = lsq_cmd_wr_ptr_r;
  lsq_cmd_rd_ptr_nxt = lsq_cmd_rd_ptr_r;

  case ({dmp_lsq_write, lsq_cmd_pop})
  2'b10:  lsq_cmd_wr_ptr_nxt = lsq_cmd_wr_ptr_r + 1'b1;
  2'b01:  lsq_cmd_rd_ptr_nxt = lsq_cmd_rd_ptr_r + 1'b1;
  2'b11:
  begin
    // Advance both wr and rd pointers
    //
          lsq_cmd_wr_ptr_nxt = lsq_cmd_wr_ptr_r + 1'b1;
          lsq_cmd_rd_ptr_nxt = lsq_cmd_rd_ptr_r + 1'b1;
  end
  default:
  begin
          lsq_cmd_wr_ptr_nxt = lsq_cmd_wr_ptr_r;
          lsq_cmd_rd_ptr_nxt = lsq_cmd_rd_ptr_r;
  end
  endcase
end




//////////////////////////////////////////////////////////////////////////////
// Mark IBP commands that are sent out on the bus
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin
  lsq_cmd_out_cg0 = lsq_cmd_pop | lsq_global_pop;
  lsq_cmd_out_nxt = lsq_cmd_out_r;

  if (lsq_cmd_pop)
  begin
    // IBP command is sent out 
    lsq_cmd_out_nxt[lsq_cmd_rd_ptr_r] = 1'b1;
  end

  if (lsq_global_pop)
  begin
    // Reset when LSQ entry is popped
    lsq_cmd_out_nxt[lsq_global_rd_ptr_r] = 1'b0;
  end
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Top of the command FIFO
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_cmd_top_PROC
  // Present the top of the LSQ (command)
  //
  lsq_fifo_cmd_valid      = lsq_valid_r[lsq_cmd_rd_ptr_r] & (~lsq_cmd_out_r[lsq_cmd_rd_ptr_r])
                          & ~(|lsq_hazard_dep_r[lsq_cmd_rd_ptr_r])
                          ;
  lsq_fifo_cmd_read       = lsq_read_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_addr       = lsq_addr_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_size       = lsq_size_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_target     = lsq_target_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_privileged = lsq_privileged_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_buff       = lsq_buff_r[lsq_cmd_rd_ptr_r]; 
  lsq_fifo_cmd_unaligned  = lsq_unaligned_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_atop      = lsq_atop_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_amo       = lsq_atomic_r[lsq_cmd_rd_ptr_r];
  lsq_fifo_cmd_excl      = lsq_excl_r[lsq_cmd_rd_ptr_r];

  // All outstanding IBP transactions initiated by the LSQ need to have the same memory target. A LSQ transaction with a new target
  // shall not be initiated on the IBP interface until all previous IBP transactions with a different memory target are completed.
  //
     
     lsq_trans_pend          = |(lsq_cmd_out_r & (~lsq_completed_r));

     lsq_cmd_allowed         = ~lsq_trans_pend
                             |  (lsq_trans_pend & (lsq_fifo_cmd_target == lsq_cmd_target_r));
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Top of the write data FIFO
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_wr_data_top_PROC
  // Present the top of the LSQ (wr data)
  //

  lsq_fifo_wr_data      = lsq_data_r[lsq_cmd_rd_ptr_r];

  lsq_fifo_wr_mask      = 4'b0000;
  lsq_fifo_wr_mask1     = 4'b0000;

  lsq_fifo_wr_unaligned = lsq_unaligned_r[lsq_st_ptr];

  case (lsq_fifo_cmd_size)
  2'b00: // byte
  begin
    lsq_fifo_wr_mask[0] = lsq_fifo_cmd_addr[1:0] == 2'b00;
    lsq_fifo_wr_mask[1] = lsq_fifo_cmd_addr[1:0] == 2'b01;
    lsq_fifo_wr_mask[2] = lsq_fifo_cmd_addr[1:0] == 2'b10;
    lsq_fifo_wr_mask[3] = lsq_fifo_cmd_addr[1:0] == 2'b11;
  end

  2'b01: // half-word
  begin
    case (lsq_fifo_cmd_addr[1:0])
    2'b00:  lsq_fifo_wr_mask[1:0] = 2'b11;
    2'b10:  lsq_fifo_wr_mask[3:2] = 2'b11;
    2'b01:  lsq_fifo_wr_mask[2:1] = 2'b11;
    default: // 2'b11
    begin
      lsq_fifo_wr_mask[3]         = 1'b1;
      lsq_fifo_wr_mask1[0]        = 1'b1;
    end
    endcase
  end

  2'b10: // word
  begin
    case (lsq_fifo_cmd_addr[1:0])
    2'b01:
    begin
      lsq_fifo_wr_mask[3:1] = 3'b111;
      lsq_fifo_wr_mask1[0]  = 1'b1;
    end
    2'b10:
    begin
      lsq_fifo_wr_mask[3:2] = 2'b11;
      lsq_fifo_wr_mask1[1:0]= 2'b11;
    end
    2'b11:
    begin
      lsq_fifo_wr_mask[3]    = 1'b1;
      lsq_fifo_wr_mask1[2:0] = 3'b111;
    end
    default:
    begin
      lsq_fifo_wr_mask       = 4'b1111;
      lsq_fifo_wr_mask1      = 4'b0000;
    end
    endcase
  end
  default:
  begin
    lsq_fifo_wr_mask      = 4'b0000;
    lsq_fifo_wr_mask1     = 4'b0000;
  end
  endcase
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Top of the read data data FIFO
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : lsq_rd_top_PROC
  // Present the top of the LSQ (rd)
  //
  lsq_fifo_rd_sex         = lsq_sex_r[lsq_ld_rd_ptr_r];
  lsq_fifo_rd_size        = lsq_size_r[lsq_ld_rd_ptr_r];
  lsq_fifo_rd_addr_2_to_0 = lsq_addr_r[lsq_ld_rd_ptr_r][2:0];
  lsq_fifo_rd_reg_id      = lsq_reg_id_r[lsq_ld_rd_ptr_r];
  lsq_fifo_rd_err         = lsq_bus_err_r[lsq_ld_rd_ptr_r] & lsq_read_r[lsq_ld_rd_ptr_r];
  if (lsq_excl_r[lsq_ld_rd_ptr_r] & ~lsq_read_r[lsq_ld_rd_ptr_r])
  begin
    lsq_fifo_rd_data_even   = {31'd0, ~lsq_sc_success_r};
    lsq_fifo_rd_data_odd    = {31'd0, ~lsq_sc_success_r};
  end
  else
  begin
    lsq_fifo_rd_data_even   = lsq_ld_data_even_r;
    lsq_fifo_rd_data_odd    = lsq_ld_data_odd_r;
  end
end


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Clock-gates
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_wr_cg0_PROC
  // Only toggle the entry being written
  //
  lsq_write_global_cg0[0] = dmp_lsq_write
                           & (lsq_cmd_wr_ptr_r == `DMP_LSQ_PTR_SIZE'd0)
                           ;
  lsq_write_global_cg0[1] = dmp_lsq_write
                           & (lsq_cmd_wr_ptr_r == `DMP_LSQ_PTR_SIZE'd1)
                           ;

  // The write field only needs to be written on behalf of ST instructions
  //
  lsq_write_data_cg0[0]   = dmp_lsq_write 
                           & (  ~dmp_lsq_read
                              | dmp_lsq_atomic[5]               
                             ) 
                           & (lsq_cmd_wr_ptr_r == `DMP_LSQ_PTR_SIZE'd0)
                           ;
  lsq_write_data_cg0[1]   = dmp_lsq_write 
                           & (  ~dmp_lsq_read
                              | dmp_lsq_atomic[5]               
                             ) 
                           & (lsq_cmd_wr_ptr_r == `DMP_LSQ_PTR_SIZE'd1)
                           ;

  // The reg id field only needs to be written on behalf of LD instructions
  //
  lsq_write_reg_id_cg0[0]   = dmp_lsq_write 
                             & (  dmp_lsq_read 
                                | dmp_lsq_excl
                               )
                             & (lsq_cmd_wr_ptr_r == `DMP_LSQ_PTR_SIZE'd0)
                             ;
  lsq_write_reg_id_cg0[1]   = dmp_lsq_write 
                             & (  dmp_lsq_read 
                                | dmp_lsq_excl
                               )
                             & (lsq_cmd_wr_ptr_r == `DMP_LSQ_PTR_SIZE'd1)
                             ;

end

//////////////////////////////////////////////////////////////////////////////
// @ FIFO that keep track of ordering of RD and WR transactions
//
//////////////////////////////////////////////////////////////////////////////

reg lsq_ld_ptr_push;
reg lsq_ld_ptr_pop;

reg lsq_st_ptr_push;
reg lsq_st_ptr_pop;

always @*
begin : lsq_data_ptr_PROC
  // These FIFOs keep track of RD and WR transactions separetely. Note RD and WR transactions may complete
  // out-of-order.
  // The LD fifo is pushed when a RD transaction is initiated on the IBP bus. It is popped when the RD transaction
  // completes.
  // For unaligned LD, the LD FIFO is pushed only once when the first RD transaction is initiated
  lsq_ld_ptr_push = lsq_fifo_cmd_valid
                  & lsq_fifo_cmd_read
                  & lsq_cmd_to_fifo;

  lsq_ld_ptr_pop  = lsq_rd_valid
                  & lsq_rd_last
                  & (~lsq_fifo_rd_unaligned) // Wait until the second transaction to pop it
                  ;

  // The WR fifo is pushed when a WR transaction is initiated on the IBP bus. It is popped when the WR transaction
  // completes.
  //
  // For unaligned ST, the WR FIFO is pushed only once when the first WR transaction is initiated
  lsq_st_ptr_push = lsq_fifo_cmd_valid
                  & (  ~lsq_fifo_cmd_read 
                     | lsq_fifo_cmd_amo
                    )
                  & lsq_cmd_to_fifo;

  lsq_st_ptr_pop  = lsq_wr_done
                  & (~lsq_fifo_wr_unaligned) // Wait until the second transaction to pop it
                  ;
end

rl_simple_fifo #(
    .DEPTH  (2 ),
    .DEPL2  (1 ),
    .D_W    (1 )
   )
  u_rl_ld_fifo (
  .clk       (clk),
  .rst_a     (rst_a),

  .push      (lsq_ld_ptr_push),
  .data_in   (lsq_cmd_rd_ptr_r),
  .pop       (lsq_ld_ptr_pop),
  .head      (lsq_ld_ptr)
);

rl_simple_fifo #(
    .DEPTH  (2 ),
    .DEPL2  (1 ),
    .D_W    (1 )
   )
  u_rl_st_fifo (
  .clk       (clk),
  .rst_a     (rst_a),

  .push      (lsq_st_ptr_push),
  .data_in   (lsq_cmd_rd_ptr_r),
  .pop       (lsq_st_ptr_pop),
  .head      (lsq_st_ptr)
);


reg [`DMP_LSQ_RANGE]      lsq_ld_bus_err;
reg [`DMP_LSQ_RANGE]      lsq_st_bus_err;

wire lsq_has_atomic;

assign lsq_has_atomic = |(lsq_valid_r & lsq_atomic_r);


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Marking transactions completed
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_complete_PROC
  // Mark transactions completed upon a rd_valid or wr_done
  //
  lsq_ld_completed[0] =  lsq_rd_valid & lsq_rd_last
                       & (lsq_ld_ptr == `DMP_LSQ_PTR_SIZE'd0)
                       & (~lsq_unaligned_r[0])
                       ;

// Set complete_r for a store transaction in following cases:
// (1) A dependency on other LSQ entries or
// (2) An atomic or exclusive transaction or
// (3) Store retires with a bus error

  lsq_st_completed[0] =  lsq_wr_done 
                       & (lsq_st_ptr == `DMP_LSQ_PTR_SIZE'd0)
                       &  (~lsq_unaligned_r[0])
                       & (   lsq_wr_err | lsq_bus_err_r[0]         // (3)
                          | (|lsq_dep_r[0])                        // (1)
                          | lsq_excl_r[0] | lsq_atomic_r[0]       // (2)
                         )
                       ;

  lsq_ld_completed[1] =  lsq_rd_valid & lsq_rd_last
                       & (lsq_ld_ptr == `DMP_LSQ_PTR_SIZE'd1)
                       & (~lsq_unaligned_r[1])
                       ;

// Set complete_r for a store transaction in following cases:
// (1) A dependency on other LSQ entries or
// (2) An atomic or exclusive transaction or
// (3) Store retires with a bus error

  lsq_st_completed[1] =  lsq_wr_done 
                       & (lsq_st_ptr == `DMP_LSQ_PTR_SIZE'd1)
                       &  (~lsq_unaligned_r[1])
                       & (   lsq_wr_err | lsq_bus_err_r[1]         // (3)
                          | (|lsq_dep_r[1])                        // (1)
                          | lsq_excl_r[1] | lsq_atomic_r[1]       // (2)
                         )
                       ;


  lsq_fifo_rd_unaligned  = lsq_unaligned_r[lsq_ld_ptr];
  lsq_fifo_sc            = lsq_excl_r[lsq_st_ptr];
  lsq_fifo_lr            = lsq_excl_r[lsq_ld_ptr];
  lsq_sc_cg0             = lsq_wr_done & lsq_fifo_sc;
  lsq_fifo_atop          = lsq_atop_r[lsq_st_ptr][5] | lsq_atop_r[lsq_ld_ptr][5];
  // Check for bus errors
  //
  lsq_ld_bus_err[0]     = (  lsq_ld_completed[0]   
                            & (  lsq_rd_err
                               | (~lsq_rd_excl_ok & lsq_fifo_lr)
                              )
                           )
                         | (lsq_unaligned_r[0] & lsq_rd_valid & lsq_rd_err) //First load error
                         ;
  lsq_st_bus_err[0]     = (lsq_st_completed[0] & lsq_wr_err)
                         | (lsq_unaligned_r[0] & lsq_wr_done  & lsq_wr_err) //First store error
                         ;
  lsq_bus_err_cg0[0]    = (  lsq_rd_valid 
                            & (  lsq_rd_err
                               | (~lsq_rd_excl_ok & lsq_fifo_lr)
                              )
                            & (lsq_ld_ptr == `DMP_LSQ_PTR_SIZE'd0)
                           )
                         | (  lsq_wr_done  & lsq_wr_err 
                            & (lsq_st_ptr == `DMP_LSQ_PTR_SIZE'd0)
                           )
                         ;
  lsq_ld_bus_err[1]     = (  lsq_ld_completed[1]   
                            & (  lsq_rd_err
                               | (~lsq_rd_excl_ok & lsq_fifo_lr)
                              )
                           )
                         | (lsq_unaligned_r[1] & lsq_rd_valid & lsq_rd_err) //First load error
                         ;
  lsq_st_bus_err[1]     = (lsq_st_completed[1] & lsq_wr_err)
                         | (lsq_unaligned_r[1] & lsq_wr_done  & lsq_wr_err) //First store error
                         ;
  lsq_bus_err_cg0[1]    = (  lsq_rd_valid 
                            & (  lsq_rd_err
                               | (~lsq_rd_excl_ok & lsq_fifo_lr)
                              )
                            & (lsq_ld_ptr == `DMP_LSQ_PTR_SIZE'd1)
                           )
                         | (  lsq_wr_done  & lsq_wr_err 
                            & (lsq_st_ptr == `DMP_LSQ_PTR_SIZE'd1)
                           )
                         ;

  lsq_update_cg0         = (lsq_ld_completed  | lsq_st_completed)
                         & (  ~lsq_atomic_r
                            | (lsq_atomic_r & ({`DMP_LSQ_DEPTH{~lsq_fifo_atop}} | (lsq_ld_completed & lsq_st_completed)))
                           )
                         ;
  lsq_update_atop_cg0    = (lsq_ld_completed | lsq_st_completed) & lsq_atomic_r;
  lsq_bus_err_nxt        = lsq_ld_bus_err    | lsq_st_bus_err;

  lsq_update_rd_data_cg0 = lsq_ld_completed
                         & (~lsq_atomic_r)
                         ;

  lsq_unaligned_update_cg0[0] = (lsq_rd_valid & lsq_rd_last
                                    & (lsq_ld_ptr == `DMP_LSQ_PTR_SIZE'd0)
                                    & lsq_unaligned_r[0])
                               | (lsq_wr_done 
                                    & (lsq_st_ptr == `DMP_LSQ_PTR_SIZE'd0)
                                    & lsq_unaligned_r[0])
                               ;

  lsq_unaligned_update_cg0[1] = (lsq_rd_valid & lsq_rd_last
                                    & (lsq_ld_ptr == `DMP_LSQ_PTR_SIZE'd1)
                                    & lsq_unaligned_r[1])
                               | (lsq_wr_done 
                                    & (lsq_st_ptr == `DMP_LSQ_PTR_SIZE'd1)
                                    & lsq_unaligned_r[1])
                               ;

  
  lsq_data_even_cg0           = lsq_rd_valid & (~lsq_idx_r[lsq_ld_ptr]);
  lsq_data_odd_cg0            = lsq_rd_valid & (lsq_idx_r[lsq_ld_ptr] );
  //lsq_rb_req_allowed     = lsq_rd_valid & lsq_rd_last & ((~lsq_unaligned_r[lsq_ld_ptr]) | (~lsq_ld_first_data));

end

always @*
begin : lsq_wr_pop_PROC
  lsq_wr_pop  = lsq_wr_done & ~(lsq_wr_err | lsq_bus_err_r[lsq_st_ptr])
              & (~(|lsq_dep_r[lsq_st_ptr]))
              & (~lsq_unaligned_r[lsq_st_ptr])
              & ~(lsq_excl_r[lsq_st_ptr] | lsq_atomic_r[lsq_st_ptr])
              ;
end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Global read pointer -- keeping it as FIFO structure
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_global_rd_wr_ptr_PROC
  lsq_global_rd_ptr_cg0 = (| lsq_completed_r)
                        | lsq_wr_pop;
  lsq_global_rd_ptr_nxt = lsq_global_rd_ptr_r;

  // We pop an entry when we are completely done with it
  //
  lsq_global_pop        = 1'b0;

  if (  (  (lsq_valid_r[lsq_global_rd_ptr_r]     == 1'b1)
         & (lsq_completed_r[lsq_global_rd_ptr_r] == 1'b1))
      | (lsq_wr_pop == 1'b1))
  begin
    lsq_global_rd_ptr_nxt = lsq_global_rd_ptr_r + 1'b1;
    lsq_global_pop        = 1'b1; // @@@ assumes LD retirements are never held back
  end

end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Load read pointer
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
reg [`DMP_LSQ_RANGE]      lsq_completed;
always @*
begin : lsq_ld_rd_ptr_PROC

  // The lsq_ld_rd_ptr_r points to the LD instruction presenting its result to the DMP
  //
  lsq_ld_rd_ptr_cg0     = (lsq_rd_valid
                        & (~lsq_fifo_rd_unaligned)
                          )
                        | (lsq_wr_done & lsq_fifo_sc)  
                        ;
  lsq_completed         = lsq_ld_completed
                        | (lsq_st_completed & {`DMP_LSQ_DEPTH{lsq_fifo_sc}})
                        ;
  case (1'b1)
  lsq_completed[0]:    lsq_ld_rd_ptr_nxt     = `DMP_LSQ_PTR_SIZE'd0;
  default:              lsq_ld_rd_ptr_nxt     = `DMP_LSQ_PTR_SIZE'd1;
  endcase

end
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Valid bits
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : lsq_valid_nxt_PROC

  // Default values
  //
  lsq_valid_cg0       = dmp_lsq_write | lsq_global_pop;
  lsq_valid_nxt       = lsq_valid_r;

  case ({dmp_lsq_write, lsq_global_pop})
  2'b10:
  begin
    lsq_valid_nxt[lsq_cmd_wr_ptr_r]    = 1'b1;
  end

  2'b01:
  begin
    lsq_valid_nxt[lsq_global_rd_ptr_r] = 1'b0;
  end

  2'b11:
  begin
    if (!lsq_full)
    begin
      lsq_valid_nxt[lsq_cmd_wr_ptr_r]    = 1'b1;
      lsq_valid_nxt[lsq_global_rd_ptr_r] = 1'b0;
    end
  end

  default:
  begin
    lsq_valid_nxt = lsq_valid_r;
  end
  endcase
end

/////////////////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : lsq_valid_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_valid_r      <= {`DMP_LSQ_ENTRIES{1'b0}};
  end
  else
  begin
    if (lsq_valid_cg0 == 1'b1)
    begin
      lsq_valid_r <= lsq_valid_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : lsq_ptrs_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_cmd_wr_ptr_r    <= {`DMP_LSQ_PTR_SIZE{1'b0}};
    lsq_cmd_rd_ptr_r    <= {`DMP_LSQ_PTR_SIZE{1'b0}};
    lsq_global_rd_ptr_r <= {`DMP_LSQ_PTR_SIZE{1'b0}};
    lsq_ld_rd_ptr_r     <= {`DMP_LSQ_PTR_SIZE{1'b0}};
  end
  else
  begin
    if (lsq_cmd_wr_ptr_cg0)
    begin
      lsq_cmd_wr_ptr_r     <= lsq_cmd_wr_ptr_nxt;
    end

    if (lsq_cmd_rd_ptr_cg0)
    begin
      lsq_cmd_rd_ptr_r     <= lsq_cmd_rd_ptr_nxt;
    end

    if (lsq_global_rd_ptr_cg0)
    begin
      lsq_global_rd_ptr_r <= lsq_global_rd_ptr_nxt;
    end

    if (lsq_ld_rd_ptr_cg0)
    begin
      lsq_ld_rd_ptr_r     <= lsq_ld_rd_ptr_nxt;
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : lsq_out_reg_PROC
  if (rst_a == 1'b1)
  begin
    lsq_cmd_out_r <= `DMP_LSQ_DEPTH'd0;
  end
  else
  begin
    if (lsq_cmd_out_cg0 == 1'b1)
    begin
      lsq_cmd_out_r <= lsq_cmd_out_nxt;
    end
  end
end

// spyglass disable_block STARC05-2.2.3.3

// spyglass disable_block W552
// SMD: Signal is driven inside more than one sequential block
// SJ:  This is a vector with different bits driven by different clock-gate enables

always @(posedge clk or posedge rst_a)
begin : lsq_data0_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_read_r[0]        <= 1'b0;
    lsq_completed_r[0]   <= 1'b0;
    lsq_bus_err_r[0]     <= 1'b0;
    lsq_addr_r[0]        <= {`ADDR_SIZE{1'b0}};
    lsq_data_r[0]        <= {`DATA_SIZE{1'b0}};
    lsq_size_r[0]        <= 2'b00;
    lsq_sex_r[0]         <= 1'b0;
    lsq_privileged_r[0]  <= 1'b0;
    lsq_buff_r[0]        <= 1'b0;
    lsq_reg_id_r[0]      <= 5'b0000;
    lsq_target_r[0]      <= {3{1'b0}};
    lsq_unaligned_r[0]   <= 1'b0;
    lsq_word_cross_r[0]  <= 1'b0;
    lsq_idx_r[0]         <= 1'b0;
    lsq_atomic_r[0]      <= 1'b0;
    lsq_atop_r[0]        <= 6'b0;
    lsq_excl_r[0]        <= 1'b0;
  end
  else
  begin
    if (lsq_write_global_cg0[0] == 1'b1)
    begin
      lsq_read_r[0]       <= lsq_read_nxt;
      lsq_completed_r[0]  <= 1'b0;
      lsq_bus_err_r[0]    <= 1'b0;
      lsq_addr_r[0]       <= lsq_addr_nxt;
      lsq_size_r[0]       <= lsq_size_nxt;
      lsq_sex_r[0]        <= lsq_sex_nxt;
      lsq_privileged_r[0] <= lsq_privileged_nxt;
      lsq_buff_r[0]       <= lsq_buff_nxt;
      lsq_target_r[0]     <= lsq_target_nxt;
      lsq_unaligned_r[0]  <= lsq_unaligned_nxt;
      lsq_word_cross_r[0] <= lsq_unaligned_nxt;
      lsq_idx_r[0]        <= lsq_idx_nxt;
      lsq_atomic_r[0]    <= lsq_atomic_nxt[5];
      lsq_atop_r[0]      <= lsq_atomic_nxt;
      lsq_excl_r[0]      <= lsq_excl_nxt;
    end
    if (lsq_update_atop_cg0[0] == 1'b1)
    begin
      lsq_atop_r[0]      <= 6'd0;
    end
    if (lsq_write_reg_id_cg0[0] == 1'b1)
    begin
      lsq_reg_id_r[0]   <= dmp_lsq_reg_id;
    end

    if (lsq_write_data_cg0[0] == 1'b1)
    begin
      lsq_data_r[0]      <= lsq_data_nxt; // ST data
    end

    if (lsq_update_cg0[0] == 1'b1)
    begin
      lsq_completed_r[0] <= 1'b1;
    end

    if (lsq_bus_err_cg0[0] == 1'b1)
    begin
      lsq_bus_err_r[0]   <= lsq_bus_err_nxt[0];
    end

    if (lsq_unaligned_update_cg0[0] == 1'b1)
    begin
      lsq_unaligned_r[0] <= 1'b0;
      lsq_idx_r[0]       <= !lsq_idx_r[0];
    end

    if (lsq_update_rd_data_cg0[0] == 1'b1)
    begin
      lsq_data_r[0]     <= lsq_rd_data;  // LD data
    end

  end
end
always @(posedge clk or posedge rst_a)
begin : lsq_data1_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_read_r[1]        <= 1'b0;
    lsq_completed_r[1]   <= 1'b0;
    lsq_bus_err_r[1]     <= 1'b0;
    lsq_addr_r[1]        <= {`ADDR_SIZE{1'b0}};
    lsq_data_r[1]        <= {`DATA_SIZE{1'b0}};
    lsq_size_r[1]        <= 2'b00;
    lsq_sex_r[1]         <= 1'b0;
    lsq_privileged_r[1]  <= 1'b0;
    lsq_buff_r[1]        <= 1'b0;
    lsq_reg_id_r[1]      <= 5'b0000;
    lsq_target_r[1]      <= {3{1'b0}};
    lsq_unaligned_r[1]   <= 1'b0;
    lsq_word_cross_r[1]  <= 1'b0;
    lsq_idx_r[1]         <= 1'b0;
    lsq_atomic_r[1]      <= 1'b0;
    lsq_atop_r[1]        <= 6'b0;
    lsq_excl_r[1]        <= 1'b0;
  end
  else
  begin
    if (lsq_write_global_cg0[1] == 1'b1)
    begin
      lsq_read_r[1]       <= lsq_read_nxt;
      lsq_completed_r[1]  <= 1'b0;
      lsq_bus_err_r[1]    <= 1'b0;
      lsq_addr_r[1]       <= lsq_addr_nxt;
      lsq_size_r[1]       <= lsq_size_nxt;
      lsq_sex_r[1]        <= lsq_sex_nxt;
      lsq_privileged_r[1] <= lsq_privileged_nxt;
      lsq_buff_r[1]       <= lsq_buff_nxt;
      lsq_target_r[1]     <= lsq_target_nxt;
      lsq_unaligned_r[1]  <= lsq_unaligned_nxt;
      lsq_word_cross_r[1] <= lsq_unaligned_nxt;
      lsq_idx_r[1]        <= lsq_idx_nxt;
      lsq_atomic_r[1]    <= lsq_atomic_nxt[5];
      lsq_atop_r[1]      <= lsq_atomic_nxt;
      lsq_excl_r[1]      <= lsq_excl_nxt;
    end
    if (lsq_update_atop_cg0[1] == 1'b1)
    begin
      lsq_atop_r[1]      <= 6'd0;
    end
    if (lsq_write_reg_id_cg0[1] == 1'b1)
    begin
      lsq_reg_id_r[1]   <= dmp_lsq_reg_id;
    end

    if (lsq_write_data_cg0[1] == 1'b1)
    begin
      lsq_data_r[1]      <= lsq_data_nxt; // ST data
    end

    if (lsq_update_cg0[1] == 1'b1)
    begin
      lsq_completed_r[1] <= 1'b1;
    end

    if (lsq_bus_err_cg0[1] == 1'b1)
    begin
      lsq_bus_err_r[1]   <= lsq_bus_err_nxt[1];
    end

    if (lsq_unaligned_update_cg0[1] == 1'b1)
    begin
      lsq_unaligned_r[1] <= 1'b0;
      lsq_idx_r[1]       <= !lsq_idx_r[1];
    end

    if (lsq_update_rd_data_cg0[1] == 1'b1)
    begin
      lsq_data_r[1]     <= lsq_rd_data;  // LD data
    end

  end
end
// spyglass enable_block STARC05-2.2.3.3
// spyglass enable_block W552

always @(posedge clk or posedge rst_a)
begin : lsq_dep0_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_dep_r[0] <= `DMP_LSQ_DEPTH'd0;
  end
  else
  begin
    if (lsq_write_global_cg0[0] == 1'b1)
    begin
      lsq_dep_r[0] <= lsq_dep_nxt;
    end

    else if (lsq_global_pop == 1'b1)
    begin
      lsq_dep_r[0][lsq_global_rd_ptr_r] <= 1'b0;
    end
  end
end
always @(posedge clk or posedge rst_a)
begin : lsq_dep1_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_dep_r[1] <= `DMP_LSQ_DEPTH'd0;
  end
  else
  begin
    if (lsq_write_global_cg0[1] == 1'b1)
    begin
      lsq_dep_r[1] <= lsq_dep_nxt;
    end

    else if (lsq_global_pop == 1'b1)
    begin
      lsq_dep_r[1][lsq_global_rd_ptr_r] <= 1'b0;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : lsq_hazard_dep0_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_hazard_dep_r[0] <= `DMP_LSQ_DEPTH'd0;
  end
  else
  begin
    if (lsq_write_global_cg0[0] == 1'b1)
    begin
      lsq_hazard_dep_r[0] <= lsq_hazard_dep_nxt;
    end

    if (lsq_valid_r[0] & (|lsq_ld_completed))
    begin
      lsq_hazard_dep_r[0][lsq_ld_ptr] <= 1'b0;
    end

    if (lsq_valid_r[0] & ((|lsq_st_completed) | lsq_wr_pop))
    begin
      lsq_hazard_dep_r[0][lsq_st_ptr] <= 1'b0;
    end
  end
end
always @(posedge clk or posedge rst_a)
begin : lsq_hazard_dep1_regs_PROC
  if (rst_a == 1'b1)
  begin
    lsq_hazard_dep_r[1] <= `DMP_LSQ_DEPTH'd0;
  end
  else
  begin
    if (lsq_write_global_cg0[1] == 1'b1)
    begin
      lsq_hazard_dep_r[1] <= lsq_hazard_dep_nxt;
    end

    if (lsq_valid_r[1] & (|lsq_ld_completed))
    begin
      lsq_hazard_dep_r[1][lsq_ld_ptr] <= 1'b0;
    end

    if (lsq_valid_r[1] & ((|lsq_st_completed) | lsq_wr_pop))
    begin
      lsq_hazard_dep_r[1][lsq_st_ptr] <= 1'b0;
    end
  end
end


always @(posedge clk or posedge rst_a)
begin : lsq_first_rd_data_PROC
  if (rst_a == 1'b1)
  begin
    lsq_ld_data_even_r <= {`DATA_SIZE{1'b0}};
    lsq_ld_data_odd_r  <= {`DATA_SIZE{1'b0}};
  end
  else
  begin
    if (lsq_data_even_cg0 == 1'b1)
    begin
      lsq_ld_data_even_r <= lsq_rd_data;
    end

    if (lsq_data_odd_cg0 == 1'b1)
    begin
      lsq_ld_data_odd_r  <= lsq_rd_data;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : lsq_sc_success_reg_PROC
  if (rst_a == 1'b1)
  begin
    lsq_sc_success_r <= 1'b0;
  end
  else
  begin
    if (lsq_sc_cg0 == 1'b1)
    begin
      lsq_sc_success_r <= lsq_wr_excl_okay;
    end
  end
end
/////////////////////////////////////////////////////////////////////////////////////////
//
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////
assign lsq0_dst_valid = lsq_valid_r[0] & (|lsq_reg_id_r[0]) & (  lsq_read_r[0]
                                              | lsq_excl_r[0]
                                             );
assign lsq0_dst_id    = lsq_reg_id_r[0];

assign lsq1_dst_valid = lsq_valid_r[1] & (|lsq_reg_id_r[1]) & (  lsq_read_r[1]
                                              | lsq_excl_r[1]
                                             );
assign lsq1_dst_id    = lsq_reg_id_r[1];


assign lsq_empty         = (lsq_valid_r ==  {`DMP_LSQ_ENTRIES{1'b0}});
assign lsq_full          = (lsq_valid_r ==  {`DMP_LSQ_ENTRIES{1'b1}});

assign lsq_bus_err       = lsq_valid_r[lsq_global_rd_ptr_r] & lsq_bus_err_r[lsq_global_rd_ptr_r] & lsq_completed_r[lsq_global_rd_ptr_r];

assign lsq_fifo_target   = lsq_cmd_target_r;
assign lsq_has_amo       = |(lsq_valid_r & (lsq_atomic_r | lsq_excl_r));

assign lsq_target_uncached = 1'b0 
                           | (  lsq_valid_r[0]
                              & (  1'b0
                                 | (lsq_target_r[0] == `DMP_TARGET_MEM)
                                )
                             )
                           | (  lsq_valid_r[1]
                              & (  1'b0
                                 | (lsq_target_r[1] == `DMP_TARGET_MEM)
                                )
                             )
                          ;

assign lsq_target_per     = 1'b0
                          | (  lsq_valid_r[0]
                             & (lsq_target_r[0] == `DMP_TARGET_PER)
                            )
                          | (  lsq_valid_r[1]
                             & (lsq_target_r[1] == `DMP_TARGET_PER)
                            )
                          ;

assign lsq_st_pending     =  |(lsq_valid_r & (~lsq_read_r));


endmodule // rl_dmp_lsq_fifo

