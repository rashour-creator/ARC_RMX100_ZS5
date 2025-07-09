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
`include "alu_defines.v"
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_branch (
  ////////// Dispatch interface /////////////////////////////////////////////
  //
  // ... Instructions are dispatched to the ALU as well
  
  input                       x1_pass,                    // instruction dispatched to the BR FU
  input [`BR_CTL_RANGE]       x1_br_ctl,                  // Indicates the instructon to be executed in this FU
  input [`DATA_RANGE]         x1_src0_data,               // Source 0 
  input [`DATA_RANGE]         br_real_base,               // used for CM
  input                       x2_retain,                  // X2 stalled
  input [1:0]                 x1_fu_stall,
  input                       br_real_ready,
  input                       x1_inst_cg0,
  output reg                  br_x1_stall,
  output reg                  br_pc_fake,
  input                       x1_flush,
  input  [`IFU_EXCP_RANGE]    ifu_x1_excp,
  input [`PC_RANGE]           x1_pc,                      // PC at X1
  input [`DATA_RANGE]         x1_offset,                  // offset to compute BR target
  input [`BR_CMP_RANGE]       x1_comparison,              // For branch resolution [GEU,LTU,GTS,LTS,NE,EQ]

  
  output reg                  br_x1_taken,                // late signal        
  output reg [`PC_RANGE]      br_x1_restart_pc,           // IFU restart PC     
      
  output                      br_req_ifu,                 // BR requests change of ctl flow
  
  ////////// X2 stage interface /////////////////////////////////////////////
  //
  output                      br_x2_taken,                // BR changes ctl flow
  output reg [`PC_RANGE]      br_x2_target_r,             // BR target
  output reg                  jalt_done,

  input                       x2_valid_r,                 // X2 valid instruction from pipe ctrl
  input                       x2_pass,                    // X2 commit

  ////////// X3 stage interface /////////////////////////////////////////////
  //
  input                       x3_flush_r,                 // Pipeline has been flushed

  ////////// CSR interface /////////////////////////////////////////////////
  //
  input [`DATA_RANGE]         arcv_ujvt_r,
 
  ////////// General input signals /////////////////////////////////////////////
  //
  input                       clk,                        // clock signal
  input                       rst_a                       // reset signal

);

// Local declarations
//

reg                    br_x2_valid_r;    
reg                    br_x2_valid_nxt;  
reg                    br_x2_ctl_cg0;    
reg                    br_x2_data_cg0;

reg                    br_x2_rb_req_nxt; 
reg                    br_x2_rb_req_cg0; 
reg                    br_x2_taken_r;
reg  [1:0]             cm_fsm_r;
reg  [1:0]             cm_fsm_nxt;
reg                    br_pc_real;

wire                   br_x1_pass;       
wire                   br_x2_valid;      
wire                   br_x2_pass;       

wire [`DATA_RANGE]     br_pc_base;
wire [`DATA_RANGE]     br_pc_raw;

wire x1_stall;
assign x1_stall = | x1_fu_stall;


// Handy assignments
//
assign br_x1_pass   = x1_pass & (| x1_br_ctl);

assign br_x2_valid  = br_x2_valid_r & x2_valid_r;
assign br_x2_pass   = br_x2_valid & x2_pass;

// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width 
// SJ:  Intended as per the design. No possible loss of data
assign br_pc_base   = 
                        br_pc_fake ? {arcv_ujvt_r[31:6], 6'b0} : br_pc_real ? br_real_base : 
                                                                                            x1_br_ctl[`BR_CTL_JALR] ? x1_src0_data : {x1_pc, 1'b0};
assign br_pc_raw    = 
                    br_pc_fake ? (br_pc_base + {x1_offset[29:0], 2'b0}) : br_pc_real ? br_pc_base : 
                                                                                                (br_pc_base + x1_offset);
// spyglass enable_block W164a

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// X1 Branch resolution                                            
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : br_x1_resolution_PROC
  // Compute x1 
  //
  br_x1_taken                = 1'b0;
  br_x1_restart_pc           = br_pc_raw[`PC_RANGE];
  
  // X2 Clock-gates
  //
  br_x2_ctl_cg0  = br_x1_pass
                 | br_x2_valid_r
                 | x3_flush_r;
 
  br_x2_data_cg0 = br_x1_pass; 
  
  case (1'b1)
  x1_br_ctl[`BR_CTL_BEQ]:
  begin
    // Branch if equal
    //
    br_x1_taken = (x1_comparison[`EQ]);
  end
  
  x1_br_ctl[`BR_CTL_BNE]:
  begin
    // Branch if not equal
    //
    br_x1_taken = (x1_comparison[`NE]);
  end
  
  x1_br_ctl[`BR_CTL_BLTS]:
  begin
    // Branch if less than (signed)
    //
    br_x1_taken = (x1_comparison[`LTS]);
  end
  
  x1_br_ctl[`BR_CTL_BGES]:
  begin
    // Branch if greater than or equal (signed)
    //
    br_x1_taken = (x1_comparison[`GES]);
  end
  
  x1_br_ctl[`BR_CTL_BLTU]:
  begin
    // Branch if less than unsiged
    //
    br_x1_taken = (x1_comparison[`LTU]);
  end
  
  x1_br_ctl[`BR_CTL_BGEU]:
  begin
    // Branch if greater or equal unsigned
    //
    br_x1_taken = (x1_comparison[`GEU]);
  end
  
  x1_br_ctl[`BR_CTL_JALR],
  x1_br_ctl[`BR_CTL_JAL]
  ,
  br_pc_fake,
  br_pc_real
                :
  begin
    // All unconditional jumps
    //
    br_x1_taken = 1'b1;
  end
  
  
  default:
  begin
    br_x1_taken   = 1'b0;
  end
  endcase
end


// X2
//
always @*
begin : br_x2_PROC

  br_x2_valid_nxt = br_x1_pass;
end

//////////////////////////////////////////////////////////////////////////////////////////
// FSM for cm.jt
//
///////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE      = 2'b0;
localparam WAIT      = 2'b01;
localparam FIRST_BR  = 2'b10;
localparam SECOND_BR = 2'b11;


always @*
begin: cm_fsm_PROC
    cm_fsm_nxt = cm_fsm_r;
    br_pc_fake = 1'b0;
    br_pc_real = 1'b0;
    br_x1_stall = 1'b0;
    jalt_done   = 1'b0;
    case (cm_fsm_r)
        IDLE:
        begin
            if ((x1_br_ctl[`BR_CTL_JT] | x1_br_ctl[`BR_CTL_JALT]) & (!x1_flush) & (!(|ifu_x1_excp))) begin
            // what if JT/JALT is killed, or there is already excpn on the first fetch
                cm_fsm_nxt = WAIT;
                br_pc_fake = 1'b1;
                br_x1_stall = 1'b1;
            end
        end
        WAIT:
        // IFU is not able to support two consecutive br_req
        begin
            if (x1_flush)
                cm_fsm_nxt = IDLE;
            else begin
                cm_fsm_nxt = FIRST_BR;
                br_x1_stall = 1'b1;
            end
        end
        FIRST_BR:
        begin
            if (x1_flush)
                cm_fsm_nxt = IDLE;
            else if (br_real_ready) begin //real jump address ready
                if (!(x2_retain | x1_stall))         //what if x1/x2 is stalled other than BR
                cm_fsm_nxt = SECOND_BR;
                br_pc_real = 1'b1;
            end
            else
                br_x1_stall = 1'b1;
        end
        SECOND_BR:
        begin
            if (x1_inst_cg0)    // do not back to IDLE until next inst
            cm_fsm_nxt = IDLE;
            jalt_done  = 1'b1;
        end
        default:
        begin
            cm_fsm_nxt = cm_fsm_r;
            br_pc_fake = 1'b0;
            br_pc_real = 1'b0;
            br_x1_stall = 1'b0;
            jalt_done   = 1'b0;
        end
    endcase
end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
begin : br_x2_regs_PROC
  if (rst_a == 1'b1)
  begin
    br_x2_valid_r           <= 1'b0;
  end
  else
  begin
    if (br_x2_ctl_cg0 == 1'b1)
    begin
      br_x2_valid_r           <= br_x2_valid_nxt; 
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : br_x2_taken_regs_PROC
  if (rst_a == 1'b1)
  begin
    br_x2_taken_r           <= 1'b0;
    br_x2_target_r          <= {`PC_SIZE{1'b0}};
  end
  else
  begin
    if (br_x2_ctl_cg0 == 1'b1)
    begin
      br_x2_taken_r           <= br_x1_taken;
    end
    
    if (br_x2_data_cg0 == 1'b1)
    begin
      br_x2_target_r          <= br_x1_restart_pc;
    end
  end
end
always @(posedge clk or posedge rst_a)
begin : cm_fsm_regs_PROC
  if (rst_a == 1'b1)
  begin
      cm_fsm_r <= 2'b0;
  end
  else
  begin
      cm_fsm_r <= cm_fsm_nxt; 
  end
end

//////////////////////////////////////////////////////////////////////////////////////////
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////

assign br_req_ifu  = br_x1_taken   & (x1_pass
                                            | br_pc_fake
                                            );
assign br_x2_taken = br_x2_taken_r & br_x2_valid_r;

endmodule // rl_branch

