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

module rl_dmp_cwb (
  ////////// General input signals /////////////////////////////////////////////
  //
  input                           clk,                     // clock signal
  input                           rst_a,                   // reset signal

  ////////// Writes into the buffer /////////////////////////////////////////////
  //
  input                           dmp_cwb_write,
  // spyglass disable_block W240
  // SMD: Input declared but not read
  // SJ : Reserved for future use
  input                           dmp_cwb_target,         // 0: DCCM, 1: D$
  // spyglass enable_block W240
  input [`ADDR_RANGE]             dmp_cwb_addr,
  input [`DATA_RANGE]             dmp_cwb_data,
  input [3:0]                     dmp_cwb_mask,
  input                           dmp_cwb_amo,
  input                           dmp_cwb_write1,
  input [`ADDR_RANGE]             dmp_cwb_addr1,
  input [`DATA_RANGE]             dmp_cwb_data1,
  input [3:0]                     dmp_cwb_mask1,


  ////////// Conflict detection: memory disambiguation ////////////////////////
  //
  input                           dmp_x2_load_r,           // LD in X2
  input [1:0]                     dmp_x2_size_r,           // Byte (00), Half-word (01), Word (10)
  input [`ADDR_RANGE]             dmp_x2_addr_r,           // LD address
  input                           dmp_x2_rmw_r,            // ST in X2 requires read 
  input [`ADDR_RANGE]             dmp_x2_addr1_r,          // LD address1
  input                           dmp_x2_bank_cross_r,     // LD crosses banks
  output reg                      cwb_x2_bypass_even,      // FWD even
  output reg                      cwb_x2_bypass_odd,       // FWD odd
  output reg                      cwb_x2_bypass_replay,    // Replay LD
  output reg [`DATA_RANGE]        cwb_x2_bypass_data_even, // FWD data
  output reg [`DATA_RANGE]        cwb_x2_bypass_data_odd,  // FWD data

  ////////// Interface with DCCM / D$ ///////////////////////////////////////////
  //
  output reg [1:0]                cwb_req,
  input [1:0]                     cwb_ack,
  output reg  [`DCCM_ADR_RANGE]   cwb_addr,
  output reg  [`DATA_RANGE]       cwb_data,
  output reg  [3:0]               cwb_mask,

  ////////// Status /////////////////////////////////////////////////////////////
  //
  output                          cwb_has_amo,
  output                          cwb_full,
  output                          cwb_one_empty,
  output                          cwb_empty

);


// Local declarations
//

reg                    cwb_write_ctl_cg0;
reg [`CWB_RANGE]       cwb_write_data_cg0;

reg                    cwb_target;

// 2-entry cache/ccm write buffer
//
reg                    cwb_wr_ptr_cg0;
reg                    cwb_wr_ptr_r;
reg                    cwb_wr_ptr_nxt;
reg                    cwb_rd_ptr_cg0;
reg                    cwb_rd_ptr_r;
reg                    cwb_rd_ptr_nxt;
reg [`CWB_RANGE]       cwb_valid_r;
reg [`CWB_RANGE]       cwb_target_r;
reg [`CWB_RANGE]       cwb_idx_r;        // 0: even; 1: odd
reg [`CWB_RANGE]       cwb_amo_r;        // 0: even; 1: odd
reg [`ADDR_RANGE]      cwb_addr_r[`CWB_RANGE];
reg [`DATA_RANGE]      cwb_data_r[`CWB_RANGE];
reg [3:0]              cwb_mask_r[`CWB_RANGE];

reg [`CWB_RANGE]       cwb_valid_nxt;
reg                    cwb_wr1_ptr;

reg                    cwb_target0_nxt;
reg                    cwb_idx0_nxt;    // 0: even; 1: odd
reg [`ADDR_RANGE]      cwb_addr0_nxt;
reg [`DATA_RANGE]      cwb_data0_nxt;
reg [3:0]              cwb_mask0_nxt;  
reg                    cwb_target1_nxt;
reg                    cwb_idx1_nxt;    // 0: even; 1: odd
reg [`ADDR_RANGE]      cwb_addr1_nxt;
reg [`DATA_RANGE]      cwb_data1_nxt;
reg [3:0]              cwb_mask1_nxt;  
wire                   cwb_read;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Writing into cwb
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : cwb_write_PROC
  // Value to be written
  //
  case (cwb_wr_ptr_r)
  1'b0:
  begin
    cwb_target0_nxt     = dmp_cwb_target;
    cwb_idx0_nxt        = dmp_cwb_addr[2];
    cwb_addr0_nxt       = dmp_cwb_addr;
    cwb_data0_nxt       = dmp_cwb_data;
    cwb_mask0_nxt       = dmp_cwb_mask;

    cwb_target1_nxt     = dmp_cwb_target;
    cwb_idx1_nxt        = dmp_cwb_addr1[2];
    cwb_addr1_nxt       = dmp_cwb_addr1;
    cwb_data1_nxt       = dmp_cwb_data1;
    cwb_mask1_nxt       = dmp_cwb_mask1;
  end
  default:
  begin
    cwb_target0_nxt     = dmp_cwb_target;
    cwb_idx0_nxt        = dmp_cwb_addr1[2];
    cwb_addr0_nxt       = dmp_cwb_addr1;
    cwb_data0_nxt       = dmp_cwb_data1;
    cwb_mask0_nxt       = dmp_cwb_mask1;

    cwb_target1_nxt     = dmp_cwb_target;
    cwb_idx1_nxt        = dmp_cwb_addr[2];
    cwb_addr1_nxt       = dmp_cwb_addr;
    cwb_data1_nxt       = dmp_cwb_data;
    cwb_mask1_nxt       = dmp_cwb_mask;
  end
  endcase
end


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Write pointer
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : cwb_wr_ptr_nxt_PROC
  // Advance the write pointer on every write
  //
  cwb_wr_ptr_cg0 = dmp_cwb_write;
  cwb_wr_ptr_nxt = cwb_wr_ptr_r;

  if (   dmp_cwb_write
      & (~dmp_cwb_write1)
     )
    cwb_wr_ptr_nxt = !cwb_wr_ptr_r;
end

always @*
begin : cwb_wr1_ptr_PROC
  // Toggle pointer
  //
  cwb_wr1_ptr = !cwb_wr_ptr_r;
end
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Clock-gates
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : cwb_wr_cg0_PROC
  // Only toggle the entry being written
  //
  cwb_write_data_cg0[0] = (dmp_cwb_write  & (cwb_wr_ptr_r == 1'b0))
                         | (dmp_cwb_write1)
                         ;
  cwb_write_data_cg0[1] = (dmp_cwb_write  & (cwb_wr_ptr_r == 1'b1))
                         | (dmp_cwb_write1)
                         ;
end

assign cwb_read = (| cwb_valid_r) & (cwb_ack == cwb_req);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Read pointer
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : cwb_rd_ptr_nxt_PROC
  // Advance the read pointer on every read
  //
  cwb_rd_ptr_cg0 = | cwb_valid_r;
  cwb_rd_ptr_nxt = cwb_rd_ptr_r;

  if (cwb_read)
    cwb_rd_ptr_nxt = !cwb_rd_ptr_r;
end



always @*
begin : cwb_valid_PROC
  // Value to be written
  //
  cwb_write_ctl_cg0 = dmp_cwb_write | (| cwb_valid_r);
  cwb_valid_nxt     = cwb_valid_r;
  case ({dmp_cwb_write, dmp_cwb_write1, cwb_read})
  3'b1_0_0:  cwb_valid_nxt[cwb_wr_ptr_r] = 1'b1;
  3'b1_1_0,3'b1_1_1:
  begin
             cwb_valid_nxt[cwb_wr_ptr_r] = 1'b1;
             cwb_valid_nxt[cwb_wr1_ptr]  = 1'b1;
  end
  3'b0_0_1:  cwb_valid_nxt[cwb_rd_ptr_r] = 1'b0;
  3'b1_0_1:
  begin
          if (!cwb_full)
          begin  
            cwb_valid_nxt[cwb_wr_ptr_r] = 1'b1;
            cwb_valid_nxt[cwb_rd_ptr_r] = 1'b0;
          end
  end
  default: cwb_valid_nxt                 = cwb_valid_r;
  endcase
end


reg [3:0]         load0_mask;
reg [3:0]         load1_mask;
reg               load_idx;
reg [3:0]         load_mask_even;
reg [3:0]         load_mask_odd;
reg [3:0]         mask_combined_even[`CWB_RANGE];
reg [3:0]         mask_combined_odd[`CWB_RANGE];
reg [`CWB_RANGE]  addr_match_31_to_2;
reg [`CWB_RANGE]  addr1_match_31_to_2;
reg [`CWB_RANGE]  conflict_even;
reg [`CWB_RANGE]  conflict_odd;
reg [`CWB_RANGE]  bypass_even;
reg [`CWB_RANGE]  bypass_odd;
reg [`CWB_RANGE]  replay_even;
reg [`CWB_RANGE]  replay_odd;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Conflict detection: memory disambiguation
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : cwb_conflict_PROC
  // The load mask indicates the bytes touched by a LD in X2 on a given 32-bit bank
  //
  load0_mask = 4'b0000;
  load1_mask = 4'b0000;

  load_idx   = dmp_x2_addr_r[2];

  case (dmp_x2_size_r)
  2'b00:
  begin
    // Load byte
    //
    load0_mask[0] = (dmp_x2_addr_r[1:0] == 2'b00);
    load0_mask[1] = (dmp_x2_addr_r[1:0] == 2'b01);
    load0_mask[2] = (dmp_x2_addr_r[1:0] == 2'b10);
    load0_mask[3] = (dmp_x2_addr_r[1:0] == 2'b11);
  end
  2'b01:
  begin
    // Load half
    //
    case (dmp_x2_addr_r[1:0])
    2'b00:   load0_mask = 4'b0011;
    2'b01:   load0_mask = 4'b0110; // unaligned, but within the same 32-bit memory bank
    2'b10:   load0_mask = 4'b1100;
    default:
    begin
             load0_mask = 4'b1000;
             load1_mask = 4'b0001; //  unaligned crossing 32-bit memory banks
    end
    endcase
  end

  default:
  begin
    // Load word
    //  
    case (dmp_x2_addr_r[1:0])
    2'b00:  load0_mask =  4'b1111;
    2'b01:
    begin  
            load0_mask = 4'b1110;  // unaligned
            load1_mask = 4'b0001;  // unaligned
    end
    2'b10:
    begin
            load0_mask = 4'b1100;  // unaligned
            load1_mask = 4'b0011;  // unaligned
    end
    default:
    begin
            load0_mask = 4'b1000;  // unaligned
            load1_mask = 4'b0111;  // unaligned
    end
    endcase
  end
  endcase

  // Derive a load mask per bank
  //
  load_mask_even = load_idx ? load1_mask : load0_mask;
  load_mask_odd  = load_idx ? load0_mask : load1_mask;

  // We can only forward data at a bank granularity (32-bit). Therefore we need to ensure
  // all bytes touched by the load are in the cwb.
  //
  mask_combined_even[0] = load_mask_even & cwb_mask_r[0];
  mask_combined_odd[0 ] = load_mask_odd  & cwb_mask_r[0];
  
  // Check if we have an address match 
  //
  addr_match_31_to_2[0] = (dmp_x2_addr_r[31:2] == cwb_addr_r[0][31:2]);
  addr1_match_31_to_2[0]= (dmp_x2_addr1_r[31:2] == cwb_addr_r[0][31:2]) & dmp_x2_bank_cross_r;
  conflict_even[0]      = (dmp_x2_load_r
                         | dmp_x2_rmw_r
                           )
                         & cwb_valid_r[0]
                         & (  addr_match_31_to_2[0]
                            | addr1_match_31_to_2[0]
                           )
                         & (cwb_idx_r[0] == 1'b0)
                         & (| mask_combined_even[0]);
  
  conflict_odd[0]       = (dmp_x2_load_r
                         | dmp_x2_rmw_r
                           )
                         & cwb_valid_r[0]
                         & (  addr_match_31_to_2[0]
                            | addr1_match_31_to_2[0]
                           )
                         & (cwb_idx_r[0] == 1'b1)
                         & (| mask_combined_odd[0]);

  mask_combined_even[1] = load_mask_even & cwb_mask_r[1];
  mask_combined_odd[1 ] = load_mask_odd  & cwb_mask_r[1];
  
  // Check if we have an address match 
  //
  addr_match_31_to_2[1] = (dmp_x2_addr_r[31:2] == cwb_addr_r[1][31:2]);
  addr1_match_31_to_2[1]= (dmp_x2_addr1_r[31:2] == cwb_addr_r[1][31:2]) & dmp_x2_bank_cross_r;
  conflict_even[1]      = (dmp_x2_load_r
                         | dmp_x2_rmw_r
                           )
                         & cwb_valid_r[1]
                         & (  addr_match_31_to_2[1]
                            | addr1_match_31_to_2[1]
                           )
                         & (cwb_idx_r[1] == 1'b0)
                         & (| mask_combined_even[1]);
  
  conflict_odd[1]       = (dmp_x2_load_r
                         | dmp_x2_rmw_r
                           )
                         & cwb_valid_r[1]
                         & (  addr_match_31_to_2[1]
                            | addr1_match_31_to_2[1]
                           )
                         & (cwb_idx_r[1] == 1'b1)
                         & (| mask_combined_odd[1]);


  // Putting it all together
  //
  bypass_even[0]     = conflict_even[0]
                      & (mask_combined_even[0] == load_mask_even);

  bypass_odd[0]      = conflict_odd[0]
                      & (mask_combined_odd[0]  == load_mask_odd);

  bypass_even[1]     = conflict_even[1]
                      & (mask_combined_even[1] == load_mask_even);

  bypass_odd[1]      = conflict_odd[1]
                      & (mask_combined_odd[1]  == load_mask_odd);



  replay_even[0]      = conflict_even[0]
                       & (mask_combined_even[0] != load_mask_even);

  replay_odd[0]       = conflict_odd[0]
                       & (mask_combined_odd[0]  != load_mask_odd);

  replay_even[1]      = conflict_even[1]
                       & (mask_combined_even[1] != load_mask_even);

  replay_odd[1]       = conflict_odd[1]
                       & (mask_combined_odd[1]  != load_mask_odd);


  // Summary
  //
  cwb_x2_bypass_even   = (| bypass_even);

  cwb_x2_bypass_odd    = (| bypass_odd);


  // Bypass at 32-bit granularity only. 
  // Moreover, if there there is a conflict on more than one
  // CWB entry, we also replay
  //
  cwb_x2_bypass_replay = (| replay_even)
                       | (| replay_odd)
                       | (& bypass_even)
                       | (& bypass_odd)
                       ;

  // Present the FWD data
  //
  cwb_x2_bypass_data_even   = bypass_even[0] ? cwb_data_r[0] :cwb_data_r[1];
  cwb_x2_bypass_data_odd    = bypass_odd[0]  ? cwb_data_r[0] :cwb_data_r[1];
end


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  CWB outputs
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : cwb_out_PROC
  cwb_req[0] = cwb_valid_r[cwb_rd_ptr_r] & (cwb_idx_r[cwb_rd_ptr_r] == 1'b0);
  cwb_req[1] = cwb_valid_r[cwb_rd_ptr_r] & (cwb_idx_r[cwb_rd_ptr_r] == 1'b1);

  cwb_addr   = cwb_addr_r[cwb_rd_ptr_r][`DCCM_ADR_RANGE];
  cwb_data   = cwb_data_r[cwb_rd_ptr_r];
  cwb_mask   = cwb_mask_r[cwb_rd_ptr_r];
  cwb_target = cwb_target_r[cwb_rd_ptr_r];
end

/////////////////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : cwb_regs_PROC
  if (rst_a == 1'b1)
  begin
    cwb_valid_r    <= {`CWB_ENTRIES{1'b0}};
  end
  else
  begin
    if (cwb_write_ctl_cg0 == 1'b1)
    begin
      cwb_valid_r   <= cwb_valid_nxt;
    end

  end
end

// spyglass disable_block W552
// SMD: Signal is driven inside more than one sequential block
// SJ:  This is a vector with different bits driven by different clock-gate enables
always @(posedge clk or posedge rst_a)
begin : cwb_data0_regs_PROC
  if (rst_a == 1'b1)
  begin
    cwb_addr_r[0]   <= {`ADDR_SIZE{1'b0}};
    cwb_data_r[0]   <= {`DATA_SIZE{1'b0}};
    cwb_mask_r[0]   <= 4'b0000;
    cwb_target_r[0] <= 1'b0;
    cwb_idx_r[0]    <= 1'b0;
    cwb_amo_r[0]    <= 1'b0;
  end
  else
  begin
    if (cwb_write_data_cg0[0] == 1'b1)
    begin
    cwb_amo_r[0]      <= dmp_cwb_amo;
      cwb_addr_r[0]   <= cwb_addr0_nxt;
      cwb_data_r[0]   <= cwb_data0_nxt;
      cwb_mask_r[0]   <= cwb_mask0_nxt;
      cwb_target_r[0] <= cwb_target0_nxt;
      cwb_idx_r[0]    <= cwb_idx0_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : cwb_data1_regs_PROC
  if (rst_a == 1'b1)
  begin
    cwb_addr_r[1]   <= {`ADDR_SIZE{1'b0}};
    cwb_data_r[1]   <= {`DATA_SIZE{1'b0}};
    cwb_mask_r[1]   <= 4'b0000;
    cwb_target_r[1] <= 1'b0;
    cwb_idx_r[1]    <= 1'b0;
    cwb_amo_r[1]    <= 1'b0;
  end
  else
  begin
    if (cwb_write_data_cg0[1] == 1'b1)
    begin
    cwb_amo_r[1]      <= dmp_cwb_amo;
      cwb_addr_r[1]   <= cwb_addr1_nxt;
      cwb_data_r[1]   <= cwb_data1_nxt;
      cwb_mask_r[1]   <= cwb_mask1_nxt;
      cwb_target_r[1] <= cwb_target1_nxt;
      cwb_idx_r[1]    <= cwb_idx1_nxt;
    end
  end
end

// spyglass enable_block W552

always @(posedge clk or posedge rst_a)
begin : cwb_ptrs_reg_PROC
  if (rst_a == 1'b1)
  begin
    cwb_wr_ptr_r    <= 1'b0;
    cwb_rd_ptr_r    <= 1'b0;
  end
  else
  begin

    if (cwb_wr_ptr_cg0 == 1'b1)
    begin
      cwb_wr_ptr_r   <= cwb_wr_ptr_nxt;
    end

    if (cwb_rd_ptr_cg0 == 1'b1)
    begin
      cwb_rd_ptr_r   <= cwb_rd_ptr_nxt;
    end
  end
end
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Output assignments
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

assign cwb_full      = cwb_valid_r == {`CWB_ENTRIES{1'b1}};
assign cwb_empty     = cwb_valid_r == {`CWB_ENTRIES{1'b0}};
assign cwb_one_empty = (~(&cwb_valid_r) & (|cwb_valid_r));
assign cwb_has_amo = |(cwb_valid_r & cwb_amo_r);

endmodule // rl_dmp_cwb

