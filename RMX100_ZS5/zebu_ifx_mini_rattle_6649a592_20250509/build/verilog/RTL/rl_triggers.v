// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
`include "defines.v"

//
// Copyright 2010-2015 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// Certain materials incorporated herein are copyright (C) 2010 - 2011, The
// University Court of the University of Edinburgh. All Rights Reserved.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
// #######  ######    ###    #####     #####   #######  ######    ######
//    #     #     #    #    #         #        #        #     #  #   
//    #     #     #    #   #         #         #        #     #  #
//    #     ######     #   #   ####  #   ####  #######  ######    ######
//    #     #    #     #   #      #  #      #  #        #    #          #
//    #     #     #    #    #    ##   #    ##  #        #     #         #
//    #     #     #   ###    #### #    #### #  #######  #     #  #######
//
// ===========================================================================
//
// Description:
//
//
//  This .vpp source file may be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o actionpoints.vpp
//
// ==========================================================================

// Configuration-dependent macro definitions
//

`include "defines.v"
`include "csr_defines.v"
`include "const.def"

module rl_triggers (
  ////////// General input signals /////////////////////////////////////////
  //
  input                          clk,              // clock
  input                          rst_a,            // asynchronous reset

  ////////// Interface for SR instructions to write aux regs ///////////////
  input [1:0]                    csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input [11:0]                   csr_sel_addr,          // (X1) CSR address
  output     [`DATA_RANGE]       csr_rdata,             // (X1) CSR read data
  output                         csr_illegal,           // (X1) illegal
  output                         csr_unimpl,            // (X1) Invalid CSR
  output                         csr_serial_sr,
  output                         csr_strict_sr,
  input                          csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input [11:0]                   csr_waddr,             // (X2) CSR addr
  input [`DATA_RANGE]            csr_wdata,             // (X2) Write data
  input [1:0]                    priv_level_r,
  
  input                          x2_pass,               // (X2) commit
  input                          x2_valid_r,            // (X2) inst valid

  ////////// Debug interface
  input                          db_active,

  ////////// Instruction monitor interface
  input [`PC_RANGE]              x2_pc,
  input [`INST_RANGE]            x2_inst,
  input                          x2_inst_size,

  ////////// DMP monitor interface
  input [`ADDR_RANGE]            dmp_x2_addr_r,
  input [1:0]                    lsq_rb_size,
  input                          dmp_x2_word_r,
  input                          dmp_x2_half_r,
  input                          dmp_x2_load_r,
  input                          dmp_x2_valid,
  input                          dmp_x2_rb_req,
  input [`DATA_RANGE]            dmp_x2_data_r,
  input [`DATA_RANGE]            dmp_x2_data,

  ////////// External trigger interface
  output [1:0]                   ext_trig_output_valid,
  input  [1:0]                   ext_trig_output_accept,
  input  [15:0]                  ext_trig_in,


  input                          secure_trig_iso_en,
  output [1:0]                   dr_secure_trig_iso_err,

  ////////// Triggers output signals ///////////////////////////////////
  //
  output                         ifu_trig_trap,
  output                         ifu_trig_break,                         
  output                         x2_inst_trap,
  output                         x2_inst_break,
  output                         dmp_addr_trig_trap,
  output                         dmp_addr_trig_break,
  output reg                     ext_trig_trap_r,
  output reg                     ext_trig_break_r,
  output                         dmp_ld_data_trig_trap,
  output                         dmp_ld_data_trig_break,
  output                         dmp_st_data_trig_trap,
  output                         dmp_st_data_trig_break
); 

reg  [`DATA_RANGE]   tselect_r;
reg                  csr_tselect_cg0;
wire                 ext_hit_0;
wire                 ext_hit_1;
wire                 ext_trig_0;
wire                 ext_trig_1;
wire                 ext_trig_output_accept_0;
wire                 ext_trig_output_accept_1;
reg                  ext_trig_output_valid_0;
reg                  ext_trig_output_valid_1;

wire                 i_ifu_trig_break;
wire                 i_ifu_trig_trap;
wire                 i_dmp_addr_trig_trap;
wire                 i_dmp_addr_trig_break;
wire                 i_dmp_ld_data_trig_trap;
wire                 i_dmp_ld_data_trig_break;
wire                 i_dmp_st_data_trig_trap;
wire                 i_dmp_st_data_trig_break;
wire                 i_ext_trig_break;
wire                 i_ext_trig_trap;
wire                 ext_trig_break;
wire                 ext_trig_trap;
reg                  i_csr_illegal;
reg  [`DATA_RANGE]   i_csr_rdata;
reg                  i_csr_unimpl;
reg                  i_csr_serial;
reg                  i_csr_strict;


reg  [`DATA_RANGE]   tdata10_r;
reg  [`DATA_RANGE]   tdata20_nxt;
reg  [1:0]           trig0_inst_match;
reg  [1:0]           trig0_dmp_addr_match;
reg  [1:0]           trig0_dmp_ld_data_match;
reg  [1:0]           trig0_dmp_st_data_match;
wire [1:0]           pre_hit0;
wire [1:0]           post_hit0;
reg  [1:0]           inst_hit0;
reg  [1:0]           dmp_addr_hit0;
reg  [1:0]           dmp_ld_data_hit0;
reg  [1:0]           dmp_st_data_hit0;
wire                 ext_hit0;
wire [1:0]           fire0;
reg  [1:0]           inst_fire0;
reg  [1:0]           dmp_addr_fire0;
reg  [1:0]           dmp_ld_data_fire0;
reg  [1:0]           dmp_st_data_fire0;
wire [3:0]           tdata10_type;
wire                 tdata10_dmode;
wire                 tdata10_uncer;
wire                 tdata10_vs;
wire                 tdata10_vu;
wire                 tdata10_sel;
wire [15:0]          tdata10_sel_ext;
wire [5:0]           tdata10_act;
wire                 tdata10_tim;
wire [3:0]           tdata10_size;
wire [3:0]           tdata10_action;
wire                 tdata10_chain;
wire [3:0]           tdata10_match;
wire                 tdata10_m;
wire                 tdata10_uncer_en;
wire                 tdata10_s;
wire                 tdata10_u;
wire                 tdata10_ex;
wire                 tdata10_ld;
wire                 tdata10_ld_only;
wire                 tdata10_st;
reg                  csr_tdata10_cg0;
reg                  csr_tdata20_cg0;
reg  [`DATA_RANGE]   tdata20_r;
wire [`DATA_RANGE]   mask0;
wire                 priv_match0;
reg                  inst_match0;
reg                  dmp_addr_match0;
reg                  dmp_st_data_match0;
reg                  dmp_ld_data_match0;

reg  [`DATA_RANGE]   tdata11_r;
reg  [`DATA_RANGE]   tdata21_nxt;
reg  [1:0]           trig1_inst_match;
reg  [1:0]           trig1_dmp_addr_match;
reg  [1:0]           trig1_dmp_ld_data_match;
reg  [1:0]           trig1_dmp_st_data_match;
wire [1:0]           pre_hit1;
wire [1:0]           post_hit1;
reg  [1:0]           inst_hit1;
reg  [1:0]           dmp_addr_hit1;
reg  [1:0]           dmp_ld_data_hit1;
reg  [1:0]           dmp_st_data_hit1;
wire                 ext_hit1;
wire [1:0]           fire1;
reg  [1:0]           inst_fire1;
reg  [1:0]           dmp_addr_fire1;
reg  [1:0]           dmp_ld_data_fire1;
reg  [1:0]           dmp_st_data_fire1;
wire [3:0]           tdata11_type;
wire                 tdata11_dmode;
wire                 tdata11_uncer;
wire                 tdata11_vs;
wire                 tdata11_vu;
wire                 tdata11_sel;
wire [15:0]          tdata11_sel_ext;
wire [5:0]           tdata11_act;
wire                 tdata11_tim;
wire [3:0]           tdata11_size;
wire [3:0]           tdata11_action;
wire                 tdata11_chain;
wire [3:0]           tdata11_match;
wire                 tdata11_m;
wire                 tdata11_uncer_en;
wire                 tdata11_s;
wire                 tdata11_u;
wire                 tdata11_ex;
wire                 tdata11_ld;
wire                 tdata11_ld_only;
wire                 tdata11_st;
reg                  csr_tdata11_cg0;
reg                  csr_tdata21_cg0;
reg  [`DATA_RANGE]   tdata21_r;
wire [`DATA_RANGE]   mask1;
wire                 priv_match1;
reg                  inst_match1;
reg                  dmp_addr_match1;
reg                  dmp_st_data_match1;
reg                  dmp_ld_data_match1;

reg  [`DATA_RANGE]   tdata12_r;
reg  [`DATA_RANGE]   tdata22_nxt;
reg  [1:0]           trig2_inst_match;
reg  [1:0]           trig2_dmp_addr_match;
reg  [1:0]           trig2_dmp_ld_data_match;
reg  [1:0]           trig2_dmp_st_data_match;
wire [1:0]           pre_hit2;
wire [1:0]           post_hit2;
reg  [1:0]           inst_hit2;
reg  [1:0]           dmp_addr_hit2;
reg  [1:0]           dmp_ld_data_hit2;
reg  [1:0]           dmp_st_data_hit2;
wire                 ext_hit2;
wire [1:0]           fire2;
reg  [1:0]           inst_fire2;
reg  [1:0]           dmp_addr_fire2;
reg  [1:0]           dmp_ld_data_fire2;
reg  [1:0]           dmp_st_data_fire2;
wire [3:0]           tdata12_type;
wire                 tdata12_dmode;
wire                 tdata12_uncer;
wire                 tdata12_vs;
wire                 tdata12_vu;
wire                 tdata12_sel;
wire [15:0]          tdata12_sel_ext;
wire [5:0]           tdata12_act;
wire                 tdata12_tim;
wire [3:0]           tdata12_size;
wire [3:0]           tdata12_action;
wire                 tdata12_chain;
wire [3:0]           tdata12_match;
wire                 tdata12_m;
wire                 tdata12_uncer_en;
wire                 tdata12_s;
wire                 tdata12_u;
wire                 tdata12_ex;
wire                 tdata12_ld;
wire                 tdata12_ld_only;
wire                 tdata12_st;
reg                  csr_tdata12_cg0;
reg                  csr_tdata22_cg0;
reg  [`DATA_RANGE]   tdata22_r;
wire [`DATA_RANGE]   mask2;
wire                 priv_match2;
reg                  inst_match2;
reg                  dmp_addr_match2;
reg                  dmp_st_data_match2;
reg                  dmp_ld_data_match2;

reg  [`DATA_RANGE]   tdata13_r;
reg  [`DATA_RANGE]   tdata23_nxt;
reg  [1:0]           trig3_inst_match;
reg  [1:0]           trig3_dmp_addr_match;
reg  [1:0]           trig3_dmp_ld_data_match;
reg  [1:0]           trig3_dmp_st_data_match;
wire [1:0]           pre_hit3;
wire [1:0]           post_hit3;
reg  [1:0]           inst_hit3;
reg  [1:0]           dmp_addr_hit3;
reg  [1:0]           dmp_ld_data_hit3;
reg  [1:0]           dmp_st_data_hit3;
wire                 ext_hit3;
wire [1:0]           fire3;
reg  [1:0]           inst_fire3;
reg  [1:0]           dmp_addr_fire3;
reg  [1:0]           dmp_ld_data_fire3;
reg  [1:0]           dmp_st_data_fire3;
wire [3:0]           tdata13_type;
wire                 tdata13_dmode;
wire                 tdata13_uncer;
wire                 tdata13_vs;
wire                 tdata13_vu;
wire                 tdata13_sel;
wire [15:0]          tdata13_sel_ext;
wire [5:0]           tdata13_act;
wire                 tdata13_tim;
wire [3:0]           tdata13_size;
wire [3:0]           tdata13_action;
wire                 tdata13_chain;
wire [3:0]           tdata13_match;
wire                 tdata13_m;
wire                 tdata13_uncer_en;
wire                 tdata13_s;
wire                 tdata13_u;
wire                 tdata13_ex;
wire                 tdata13_ld;
wire                 tdata13_ld_only;
wire                 tdata13_st;
reg                  csr_tdata13_cg0;
reg                  csr_tdata23_cg0;
reg  [`DATA_RANGE]   tdata23_r;
wire [`DATA_RANGE]   mask3;
wire                 priv_match3;
reg                  inst_match3;
reg                  dmp_addr_match3;
reg                  dmp_st_data_match3;
reg                  dmp_ld_data_match3;

wire [`DATA_RANGE]  inst_data;
wire [`ADDR_RANGE]  inst_addr;
wire                inst_size;
wire [`DATA_RANGE]  ld_data;
wire [`DATA_RANGE]  st_data;
wire                dmp_byte;
wire                dmp_x2_byte;
wire                dmp_half;
wire                dmp_word;
wire [`ADDR_RANGE]  dmp_addr;
wire                trap_hit;
wire                break_hit;


`define MASKMAX6 8
`define MM6_MAX `MASKMAX6-1
wire [`MM6_MAX:0] maskmax6;
assign maskmax6 = {1'b0,{`MM6_MAX{1'b1}}};

//////////////////////////////////////////////////////////////////////////////
// Reads
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : csr_read_PROC

  i_csr_rdata     = {`DATA_SIZE{1'b0}};             
  i_csr_illegal   = 1'b0;    
  i_csr_unimpl    = 1'b1;    
  i_csr_serial    = 1'b0;
  i_csr_strict    = 1'b0;

  if (csr_sel_ctl != 2'b00)
  begin
    // Trigger got selected
    //
    case (csr_sel_addr)
    `CSR_TSELECT:
    begin
      i_csr_rdata      = tselect_r;          
      i_csr_illegal    = (priv_level_r != `PRIV_M);    
      i_csr_unimpl     = 1'b0;    
      i_csr_strict     = csr_sel_ctl[1];    // trigger select info needs to be updated
    end
    
//!BCR { num: 1953, val: 4026531840, name: "TDATA1" }
    `CSR_TDATA1:
    begin
      case (tselect_r)
        32'h0:  i_csr_rdata = tdata10_r;
        32'h1:  i_csr_rdata = tdata11_r;
        32'h2:  i_csr_rdata = tdata12_r;
        32'h3:  i_csr_rdata = tdata13_r;
        default: i_csr_rdata = 32'h0;
      endcase
      i_csr_illegal    = (priv_level_r != `PRIV_M);    
      i_csr_unimpl     = 1'b0;    
      i_csr_strict     = csr_sel_ctl[1];
    end
    
    
    `CSR_TDATA2:
    begin
      case (tselect_r)
        32'h0:  i_csr_rdata = tdata20_r;
        32'h1:  i_csr_rdata = tdata21_r;
        32'h2:  i_csr_rdata = tdata22_r;
        32'h3:  i_csr_rdata = tdata23_r;
        default: i_csr_rdata = 32'h0;
      endcase
      i_csr_illegal    = (priv_level_r != `PRIV_M);    
      i_csr_unimpl     = 1'b0;    
      i_csr_strict     = csr_sel_ctl[1];
    end

//!BCR { num: 1956, val: 16810176, name: "TINFO" }
    `CSR_TINFO:
    // triggers only support type = 6(mcontrol6) or 15(disabled)
    begin
      case (tselect_r)
        32'h0:  i_csr_rdata = {8'd1, 8'b0, 16'h80c0};
        32'h1:  i_csr_rdata = {8'd1, 8'b0, 16'h80c0};
        32'h2:  i_csr_rdata = {8'd1, 8'b0, 16'h80c0};
        32'h3:  i_csr_rdata = {8'd1, 8'b0, 16'h80c0};
        default: i_csr_rdata = 32'h0;
      endcase
      i_csr_illegal    = (priv_level_r != `PRIV_M) || csr_sel_ctl[1];    
      i_csr_unimpl     = 1'b0;    
    end
    
    default:
    begin
      i_csr_rdata     = {`DATA_SIZE{1'b0}};             
      i_csr_illegal   = 1'b0;    
      i_csr_unimpl    = 1'b1;    
      i_csr_serial    = 1'b0;
      i_csr_strict    = 1'b0;
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
  csr_tselect_cg0   = 1'b0;
  csr_tdata10_cg0  = 1'b0;
  csr_tdata20_cg0  = 1'b0;
  csr_tdata11_cg0  = 1'b0;
  csr_tdata21_cg0  = 1'b0;
  csr_tdata12_cg0  = 1'b0;
  csr_tdata22_cg0  = 1'b0;
  csr_tdata13_cg0  = 1'b0;
  csr_tdata23_cg0  = 1'b0;
  
  case (csr_waddr)
  `CSR_TSELECT:
  begin
    csr_tselect_cg0 = csr_write & x2_pass;
  end
    
  `CSR_TDATA1:
  begin
    case (tselect_r)
        32'h0: csr_tdata10_cg0 = csr_write & x2_pass & (db_active | (!tdata10_dmode));
        32'h1: csr_tdata11_cg0 = csr_write & x2_pass & (db_active | (!tdata11_dmode));
        32'h2: csr_tdata12_cg0 = csr_write & x2_pass & (db_active | (!tdata12_dmode));
        32'h3: csr_tdata13_cg0 = csr_write & x2_pass & (db_active | (!tdata13_dmode));
    default: begin
        csr_tdata10_cg0 = 1'b0; 
        csr_tdata11_cg0 = 1'b0; 
        csr_tdata12_cg0 = 1'b0; 
        csr_tdata13_cg0 = 1'b0; 
    end
    endcase
  end

  `CSR_TDATA2:
  begin
    case (tselect_r)
        32'h0: csr_tdata20_cg0 = csr_write & x2_pass & (db_active | (!tdata10_dmode));
        32'h1: csr_tdata21_cg0 = csr_write & x2_pass & (db_active | (!tdata11_dmode));
        32'h2: csr_tdata22_cg0 = csr_write & x2_pass & (db_active | (!tdata12_dmode));
        32'h3: csr_tdata23_cg0 = csr_write & x2_pass & (db_active | (!tdata13_dmode));
    default: begin
        csr_tdata20_cg0 = 1'b0; 
        csr_tdata21_cg0 = 1'b0; 
        csr_tdata22_cg0 = 1'b0; 
        csr_tdata23_cg0 = 1'b0; 
    end
    endcase
  end

  default:
  begin
    csr_tselect_cg0     = 1'b0;
    csr_tdata10_cg0  = 1'b0;
    csr_tdata20_cg0  = 1'b0;
    csr_tdata11_cg0  = 1'b0;
    csr_tdata21_cg0  = 1'b0;
    csr_tdata12_cg0  = 1'b0;
    csr_tdata22_cg0  = 1'b0;
    csr_tdata13_cg0  = 1'b0;
    csr_tdata23_cg0  = 1'b0;
  end
  endcase
end

always @(posedge clk or posedge rst_a)
begin : tselect_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tselect_r   <= 32'b0;
  end
  else
    if (csr_tselect_cg0 == 1'b1)
    begin
      tselect_r <= (csr_wdata > 32'd3) ? 32'd3 : csr_wdata;
    end
end

wire dmode_nxt0;
wire csr_tdata10_lock;
wire [3:0]  action_nxt0;
assign dmode_nxt0 = db_active ? csr_wdata[27] : tdata10_r[27];
assign action_nxt0 = (!tdata10_dmode && (csr_wdata[15:12] == 4'h1)) ? 4'b0 : csr_wdata[15:12];
assign csr_tdata10_lock = (csr_wdata[31:28] == 4'h6) || (csr_wdata[31:28] == 4'h7);

always @(posedge clk or posedge rst_a)
begin : tdata10_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata10_r      <= 32'hf0000000;
  end
  else if (csr_tdata10_cg0 == 1'b1)
    begin
        if (!csr_tdata10_lock)
            tdata10_r <= 32'hf0000000;
        else
      tdata10_r    <= {csr_wdata[31:28], dmode_nxt0, 1'b0, (tdata10_r[25] & (csr_wdata[25] | csr_wdata[22])), 2'b0, (tdata10_r[22] & (csr_wdata[22] | csr_wdata[25])), csr_wdata[21], 2'b0, csr_wdata[18:16], action_nxt0, csr_wdata[11:6], 2'b0, csr_wdata[3:0]};
    end
  else if (| fire0)
    begin
      tdata10_r    <= {tdata10_r[31:26], fire0[1], tdata10_r[24:23], fire0[0], tdata10_r[21:0]};
    end
end

always @*
begin : tdata20_nxt_PROC
  tdata20_nxt = csr_wdata;
  if (tdata10_match == 4'b1)
  begin
    if (csr_wdata[`MM6_MAX:0] > maskmax6) 
      tdata20_nxt[`MM6_MAX] = 1'b0;
  end
end

always @(posedge clk or posedge rst_a)
begin : tdata20_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata20_r      <= {`DATA_SIZE{1'b0}};
  end
  else
    if (csr_tdata20_cg0 == 1'b1)
    begin
      tdata20_r    <= tdata20_nxt;
    end
end


wire dmode_nxt1;
wire csr_tdata11_lock;
wire [3:0]  action_nxt1;
assign dmode_nxt1 = db_active ? csr_wdata[27] : tdata11_r[27];
assign action_nxt1 = (!tdata11_dmode && (csr_wdata[15:12] == 4'h1)) ? 4'b0 : csr_wdata[15:12];
assign csr_tdata11_lock = (csr_wdata[31:28] == 4'h6) || (csr_wdata[31:28] == 4'h7);

always @(posedge clk or posedge rst_a)
begin : tdata11_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata11_r      <= 32'hf0000000;
  end
  else if (csr_tdata11_cg0 == 1'b1)
    begin
        if (!csr_tdata11_lock)
            tdata11_r <= 32'hf0000000;
        else
      tdata11_r    <= {csr_wdata[31:28], dmode_nxt1, 1'b0, (tdata11_r[25] & (csr_wdata[25] | csr_wdata[22])), 2'b0, (tdata11_r[22] & (csr_wdata[22] | csr_wdata[25])), csr_wdata[21], 2'b0, csr_wdata[18:16], action_nxt1, csr_wdata[11:6], 2'b0, csr_wdata[3:0]};
    end
  else if (| fire1)
    begin
      tdata11_r    <= {tdata11_r[31:26], fire1[1], tdata11_r[24:23], fire1[0], tdata11_r[21:0]};
    end
end

always @*
begin : tdata21_nxt_PROC
  tdata21_nxt = csr_wdata;
  if (tdata11_match == 4'b1)
  begin
    if (csr_wdata[`MM6_MAX:0] > maskmax6) 
      tdata21_nxt[`MM6_MAX] = 1'b0;
  end
end

always @(posedge clk or posedge rst_a)
begin : tdata21_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata21_r      <= {`DATA_SIZE{1'b0}};
  end
  else
    if (csr_tdata21_cg0 == 1'b1)
    begin
      tdata21_r    <= tdata21_nxt;
    end
end


wire dmode_nxt2;
wire csr_tdata12_lock;
wire [3:0]  action_nxt2;
assign dmode_nxt2 = db_active ? csr_wdata[27] : tdata12_r[27];
assign action_nxt2 = (!tdata12_dmode && (csr_wdata[15:12] == 4'h1)) ? 4'b0 : csr_wdata[15:12];
assign csr_tdata12_lock = (csr_wdata[31:28] == 4'h6) || (csr_wdata[31:28] == 4'h7);

always @(posedge clk or posedge rst_a)
begin : tdata12_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata12_r      <= 32'hf0000000;
  end
  else if (csr_tdata12_cg0 == 1'b1)
    begin
        if (!csr_tdata12_lock)
            tdata12_r <= 32'hf0000000;
        else
      tdata12_r    <= {csr_wdata[31:28], dmode_nxt2, 1'b0, (tdata12_r[25] & (csr_wdata[25] | csr_wdata[22])), 2'b0, (tdata12_r[22] & (csr_wdata[22] | csr_wdata[25])), csr_wdata[21], 2'b0, csr_wdata[18:16], action_nxt2, csr_wdata[11:6], 2'b0, csr_wdata[3:0]};
    end
  else if (| fire2)
    begin
      tdata12_r    <= {tdata12_r[31:26], fire2[1], tdata12_r[24:23], fire2[0], tdata12_r[21:0]};
    end
end

always @*
begin : tdata22_nxt_PROC
  tdata22_nxt = csr_wdata;
  if (tdata12_match == 4'b1)
  begin
    if (csr_wdata[`MM6_MAX:0] > maskmax6) 
      tdata22_nxt[`MM6_MAX] = 1'b0;
  end
end

always @(posedge clk or posedge rst_a)
begin : tdata22_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata22_r      <= {`DATA_SIZE{1'b0}};
  end
  else
    if (csr_tdata22_cg0 == 1'b1)
    begin
      tdata22_r    <= tdata22_nxt;
    end
end


wire dmode_nxt3;
wire csr_tdata13_lock;
wire [3:0]  action_nxt3;
assign dmode_nxt3 = db_active ? csr_wdata[27] : tdata13_r[27];
assign action_nxt3 = (!tdata13_dmode && (csr_wdata[15:12] == 4'h1)) ? 4'b0 : csr_wdata[15:12];
assign csr_tdata13_lock = (csr_wdata[31:28] == 4'h6) || (csr_wdata[31:28] == 4'h7);

always @(posedge clk or posedge rst_a)
begin : tdata13_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata13_r      <= 32'hf0000000;
  end
  else if (csr_tdata13_cg0 == 1'b1)
    begin
        if (!csr_tdata13_lock)
            tdata13_r <= 32'hf0000000;
        else
      tdata13_r    <= {csr_wdata[31:28], dmode_nxt3, 1'b0, (tdata13_r[25] & (csr_wdata[25] | csr_wdata[22])), 2'b0, (tdata13_r[22] & (csr_wdata[22] | csr_wdata[25])), csr_wdata[21], 2'b0, csr_wdata[18:16], action_nxt3, csr_wdata[11:6], 2'b0, csr_wdata[3:0]};
    end
  else if (| fire3)
    begin
      tdata13_r    <= {tdata13_r[31:26], fire3[1], tdata13_r[24:23], fire3[0], tdata13_r[21:0]};
    end
end

always @*
begin : tdata23_nxt_PROC
  tdata23_nxt = csr_wdata;
  if (tdata13_match == 4'b1)
  begin
    if (csr_wdata[`MM6_MAX:0] > maskmax6) 
      tdata23_nxt[`MM6_MAX] = 1'b0;
  end
end

always @(posedge clk or posedge rst_a)
begin : tdata23_csr_regs_PROC
  if (rst_a == 1'b1)
  begin
    tdata23_r      <= {`DATA_SIZE{1'b0}};
  end
  else
    if (csr_tdata23_cg0 == 1'b1)
    begin
      tdata23_r    <= tdata23_nxt;
    end
end



// Reg field assignments
//

assign tdata10_type     = tdata10_r[31:28];
assign tdata10_dmode    = tdata10_r[27];
assign tdata10_uncer    = tdata10_r[26];
assign tdata10_vs       = tdata10_r[24];
assign tdata10_vu       = tdata10_r[23];
assign tdata10_sel      = tdata10_r[21];
assign tdata10_tim      = tdata10_r[20];
assign tdata10_size     = tdata10_r[19:16];
assign tdata10_action   = tdata10_r[15:12];
assign tdata10_act      = tdata10_r[5:0];
assign tdata10_sel_ext  = tdata10_r[21:6];
assign tdata10_chain    = tdata10_r[11];
assign tdata10_match    = tdata10_r[10:7];
assign tdata10_m        = tdata10_r[6];
assign tdata10_uncer_en = tdata10_r[5];
assign tdata10_s        = tdata10_r[4];
assign tdata10_u        = tdata10_r[3];
assign tdata10_ex       = tdata10_r[2];
assign tdata10_st       = tdata10_r[1] && (!dmp_x2_load_r);
assign tdata10_ld       = tdata10_r[0] && dmp_x2_load_r;
assign tdata10_ld_only  = tdata10_r[0];

// Priv level detection
//
assign priv_match0        = ((priv_level_r == `PRIV_M) & tdata10_m) | ((priv_level_r == `PRIV_U) & tdata10_u);

// Match detection
//
assign mask0 = ~(tdata20_r + 32'b1) ^ tdata20_r;
//assign napot_hit0 = (~| (comp_value ^ tdata2`i_r) & mask0);


always @*
begin: inst_match0_PROC
    inst_match0        = 1'b0;
    dmp_addr_match0    = 1'b0;
    dmp_st_data_match0 = 1'b0;
    dmp_ld_data_match0 = 1'b0;

    if (tdata10_sel)         // data compare
    case (tdata10_match)
        4'd0, 4'd8:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = ((inst_data == tdata20_r) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_st_data_match0 = ((st_data == tdata20_r) ^ tdata10_match[3]) & tdata10_st;
                        dmp_ld_data_match0 = ((ld_data == tdata20_r) ^ tdata10_match[3]) & tdata10_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = ((st_data == tdata20_r) ^ tdata10_match[3]) & tdata10_st & dmp_x2_byte;
                        dmp_ld_data_match0 = ((ld_data == tdata20_r) ^ tdata10_match[3]) & tdata10_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = ((inst_data == tdata20_r) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_st_data_match0 = ((st_data == tdata20_r) ^ tdata10_match[3]) & tdata10_st & dmp_x2_half_r;
                        dmp_ld_data_match0 = ((ld_data == tdata20_r) ^ tdata10_match[3]) & tdata10_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match0 = ((inst_data == tdata20_r) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_st_data_match0 = ((st_data == tdata20_r) ^ tdata10_match[3]) & tdata10_st & dmp_x2_word_r;
                        dmp_ld_data_match0 = ((ld_data == tdata20_r) ^ tdata10_match[3]) & tdata10_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = 1'b0;
                        dmp_ld_data_match0 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = ((~| ((inst_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_st_data_match0 = ((~| ((st_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_st;
                        dmp_ld_data_match0 = ((~| ((ld_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = ((~| ((st_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_st & dmp_x2_byte;
                        dmp_ld_data_match0 = ((~| ((ld_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = ((~| ((inst_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_st_data_match0 = ((~| ((st_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_st & dmp_x2_half_r;
                        dmp_ld_data_match0 = ((~| ((ld_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match0 = ((~| ((inst_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_st_data_match0 = ((~| ((st_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_st & dmp_x2_word_r;
                        dmp_ld_data_match0 = ((~| ((ld_data ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = 1'b0;
                        dmp_ld_data_match0 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (inst_data >= tdata20_r) & tdata10_ex;
                        dmp_st_data_match0 = (st_data >= tdata20_r) & tdata10_st;
                        dmp_ld_data_match0 = (ld_data >= tdata20_r) & tdata10_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = (st_data >= tdata20_r) & tdata10_st & dmp_x2_byte;
                        dmp_ld_data_match0 = (ld_data >= tdata20_r) & tdata10_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (inst_data >= tdata20_r) & tdata10_ex & inst_size;
                        dmp_st_data_match0 = (st_data >= tdata20_r) & tdata10_st & dmp_x2_half_r;
                        dmp_ld_data_match0 = (ld_data >= tdata20_r) & tdata10_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match0 = (inst_data >= tdata20_r) & tdata10_ex & (!inst_size);
                        dmp_st_data_match0 = (st_data >= tdata20_r) & tdata10_st & dmp_x2_word_r;
                        dmp_ld_data_match0 = (ld_data >= tdata20_r) & tdata10_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = 1'b0;
                        dmp_ld_data_match0 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (inst_data < tdata20_r) & tdata10_ex;
                        dmp_st_data_match0 = (st_data < tdata20_r) & tdata10_st;
                        dmp_ld_data_match0 = (ld_data < tdata20_r) & tdata10_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = (st_data < tdata20_r) & tdata10_st & dmp_x2_byte;
                        dmp_ld_data_match0 = (ld_data < tdata20_r) & tdata10_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (inst_data < tdata20_r) & tdata10_ex & inst_size;
                        dmp_st_data_match0 = (st_data < tdata20_r) & tdata10_st & dmp_x2_half_r;
                        dmp_ld_data_match0 = (ld_data < tdata20_r) & tdata10_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match0 = (inst_data < tdata20_r) & tdata10_ex & (!inst_size);
                        dmp_st_data_match0 = (st_data < tdata20_r) & tdata10_st & dmp_x2_word_r;
                        dmp_ld_data_match0 = (ld_data < tdata20_r) & tdata10_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = 1'b0;
                        dmp_ld_data_match0 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (((inst_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_st_data_match0 = (((st_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st;
                        dmp_ld_data_match0 = (((ld_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = (((st_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st & dmp_x2_byte;
                        dmp_ld_data_match0 = (((ld_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (((inst_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_st_data_match0 = (((st_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st & dmp_x2_half_r;
                        dmp_ld_data_match0 = (((ld_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match0 = (((inst_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_st_data_match0 = (((st_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st & dmp_x2_word_r;
                        dmp_ld_data_match0 = (((ld_data[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = 1'b0;
                        dmp_ld_data_match0 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (((inst_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_st_data_match0 = (((st_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st;
                        dmp_ld_data_match0 = (((ld_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = (((st_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st & dmp_x2_byte;
                        dmp_ld_data_match0 = (((ld_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (((inst_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_st_data_match0 = (((st_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st & dmp_x2_half_r;
                        dmp_ld_data_match0 = (((ld_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match0 = (((inst_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_st_data_match0 = (((st_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_st & dmp_x2_word_r;
                        dmp_ld_data_match0 = (((ld_data[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_st_data_match0 = 1'b0;
                        dmp_ld_data_match0 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match0 = 1'b0;
                dmp_st_data_match0 = 1'b0;
                dmp_ld_data_match0 = 1'b0;
            end
    endcase
    else                            // address compare
    case (tdata10_match)
        4'd0, 4'd8:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = ((inst_addr == tdata20_r) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_addr_match0 = ((dmp_addr == tdata20_r) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld);
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = ((dmp_addr == tdata20_r) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = ((inst_addr == tdata20_r) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_addr_match0 = ((dmp_addr == tdata20_r) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match0 = ((inst_addr == tdata20_r) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_addr_match0 = ((dmp_addr == tdata20_r) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = ((~| ((inst_addr ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_addr_match0 = ((~| ((dmp_addr ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld);
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = ((~| ((dmp_addr ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = ((~| ((inst_addr ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_addr_match0 = ((~| ((dmp_addr ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match0 = ((~| ((inst_addr ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_addr_match0 = ((~| ((dmp_addr ^ tdata20_r) & mask0)) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (inst_addr >= tdata20_r) & tdata10_ex;
                        dmp_addr_match0 = (dmp_addr >= tdata20_r) & (tdata10_st | tdata10_ld);
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = (dmp_addr >= tdata20_r) & (tdata10_st | tdata10_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (inst_addr >= tdata20_r) & tdata10_ex & inst_size;
                        dmp_addr_match0 = (dmp_addr >= tdata20_r) & (tdata10_st | tdata10_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match0 = (inst_addr >= tdata20_r) & tdata10_ex & (!inst_size);
                        dmp_addr_match0 = (dmp_addr >= tdata20_r) & (tdata10_st | tdata10_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (inst_addr < tdata20_r) & tdata10_ex;
                        dmp_addr_match0 = (dmp_addr < tdata20_r) & (tdata10_st | tdata10_ld);
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = (dmp_addr < tdata20_r) & (tdata10_st | tdata10_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (inst_addr < tdata20_r) & tdata10_ex & inst_size;
                        dmp_addr_match0 = (dmp_addr < tdata20_r) & (tdata10_st | tdata10_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match0 = (inst_addr < tdata20_r) & tdata10_ex & (!inst_size);
                        dmp_addr_match0 = (dmp_addr < tdata20_r) & (tdata10_st | tdata10_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (((inst_addr[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_addr_match0 = (((dmp_addr[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld);
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = (((dmp_addr[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (((inst_addr[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_addr_match0 = (((dmp_addr[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match0 = (((inst_addr[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_addr_match0 = (((dmp_addr[15:0] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata10_size)
                4'd0: 
                    begin
                        inst_match0 = (((inst_addr[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex;
                        dmp_addr_match0 = (((dmp_addr[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld);
                    end
                4'd1: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = (((dmp_addr[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match0 = (((inst_addr[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & inst_size;
                        dmp_addr_match0 = (((dmp_addr[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match0 = (((inst_addr[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & tdata10_ex & (!inst_size);
                        dmp_addr_match0 = (((dmp_addr[31:16] & tdata20_r[31:16]) == tdata20_r[15:0]) ^ tdata10_match[3]) & (tdata10_st | tdata10_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match0 = 1'b0;
                        dmp_addr_match0 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match0 = 1'b0;
                dmp_addr_match0 = 1'b0;
            end
    endcase
end


// collect current trigger's match result
always @*
begin: match_result_collect0_PROC
   trig0_inst_match        = {1'b0, inst_match0 & priv_match0 & (tdata10_type == 4'h6) & x2_valid_r}; // always before commit
   trig0_dmp_addr_match    = {1'b0, dmp_addr_match0 & priv_match0 & (tdata10_type == 4'd6) & dmp_x2_valid}; // always before commit
   trig0_dmp_st_data_match = {dmp_st_data_match0 & priv_match0 & (tdata10_type == 4'd6) & dmp_x2_valid, 1'b0}; // always post commit
   trig0_dmp_ld_data_match = {dmp_ld_data_match0 & priv_match0 & (tdata10_type == 4'd6) & dmp_x2_rb_req, 1'b0}; // always post commit
end


// Gate hit by the previous trigger's chain and hit
always @*
begin: hit0_PROC
   inst_hit0        = trig0_inst_match; 
   dmp_addr_hit0    = trig0_dmp_addr_match;
   dmp_st_data_hit0 = trig0_dmp_st_data_match;
   dmp_ld_data_hit0 = trig0_dmp_ld_data_match;
end

assign pre_hit0 = inst_hit0 | dmp_addr_hit0;
assign post_hit0 = dmp_st_data_hit0 | dmp_ld_data_hit0;
assign ext_hit0 = (tdata10_r[31:28] == 4'h7) && (| (ext_trig_in & tdata10_sel_ext));

//fire result & bypass ld_data_match 
always @*
begin: fire0_PROC
    inst_fire0         = tdata10_chain ? 2'b00 : inst_hit0;
    dmp_addr_fire0     = tdata10_chain ? 2'b00 : dmp_addr_hit0;
    dmp_st_data_fire0  = tdata10_chain ? 2'b00 : dmp_st_data_hit0;
    dmp_ld_data_fire0  = trig0_dmp_ld_data_match;
end

assign fire0 = inst_fire0 | dmp_addr_fire0 | dmp_st_data_fire0 | dmp_ld_data_fire0;



assign tdata11_type     = tdata11_r[31:28];
assign tdata11_dmode    = tdata11_r[27];
assign tdata11_uncer    = tdata11_r[26];
assign tdata11_vs       = tdata11_r[24];
assign tdata11_vu       = tdata11_r[23];
assign tdata11_sel      = tdata11_r[21];
assign tdata11_tim      = tdata11_r[20];
assign tdata11_size     = tdata11_r[19:16];
assign tdata11_action   = tdata11_r[15:12];
assign tdata11_act      = tdata11_r[5:0];
assign tdata11_sel_ext  = tdata11_r[21:6];
assign tdata11_chain    = tdata11_r[11];
assign tdata11_match    = tdata11_r[10:7];
assign tdata11_m        = tdata11_r[6];
assign tdata11_uncer_en = tdata11_r[5];
assign tdata11_s        = tdata11_r[4];
assign tdata11_u        = tdata11_r[3];
assign tdata11_ex       = tdata11_r[2];
assign tdata11_st       = tdata11_r[1] && (!dmp_x2_load_r);
assign tdata11_ld       = tdata11_r[0] && dmp_x2_load_r;
assign tdata11_ld_only  = tdata11_r[0];

// Priv level detection
//
assign priv_match1        = ((priv_level_r == `PRIV_M) & tdata11_m) | ((priv_level_r == `PRIV_U) & tdata11_u);

// Match detection
//
assign mask1 = ~(tdata21_r + 32'b1) ^ tdata21_r;
//assign napot_hit1 = (~| (comp_value ^ tdata2`i_r) & mask1);


always @*
begin: inst_match1_PROC
    inst_match1        = 1'b0;
    dmp_addr_match1    = 1'b0;
    dmp_st_data_match1 = 1'b0;
    dmp_ld_data_match1 = 1'b0;

    if (tdata11_sel)         // data compare
    case (tdata11_match)
        4'd0, 4'd8:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = ((inst_data == tdata21_r) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_st_data_match1 = ((st_data == tdata21_r) ^ tdata11_match[3]) & tdata11_st;
                        dmp_ld_data_match1 = ((ld_data == tdata21_r) ^ tdata11_match[3]) & tdata11_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = ((st_data == tdata21_r) ^ tdata11_match[3]) & tdata11_st & dmp_x2_byte;
                        dmp_ld_data_match1 = ((ld_data == tdata21_r) ^ tdata11_match[3]) & tdata11_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = ((inst_data == tdata21_r) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_st_data_match1 = ((st_data == tdata21_r) ^ tdata11_match[3]) & tdata11_st & dmp_x2_half_r;
                        dmp_ld_data_match1 = ((ld_data == tdata21_r) ^ tdata11_match[3]) & tdata11_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match1 = ((inst_data == tdata21_r) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_st_data_match1 = ((st_data == tdata21_r) ^ tdata11_match[3]) & tdata11_st & dmp_x2_word_r;
                        dmp_ld_data_match1 = ((ld_data == tdata21_r) ^ tdata11_match[3]) & tdata11_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = 1'b0;
                        dmp_ld_data_match1 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = ((~| ((inst_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_st_data_match1 = ((~| ((st_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_st;
                        dmp_ld_data_match1 = ((~| ((ld_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = ((~| ((st_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_st & dmp_x2_byte;
                        dmp_ld_data_match1 = ((~| ((ld_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = ((~| ((inst_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_st_data_match1 = ((~| ((st_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_st & dmp_x2_half_r;
                        dmp_ld_data_match1 = ((~| ((ld_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match1 = ((~| ((inst_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_st_data_match1 = ((~| ((st_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_st & dmp_x2_word_r;
                        dmp_ld_data_match1 = ((~| ((ld_data ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = 1'b0;
                        dmp_ld_data_match1 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (inst_data >= tdata21_r) & tdata11_ex;
                        dmp_st_data_match1 = (st_data >= tdata21_r) & tdata11_st;
                        dmp_ld_data_match1 = (ld_data >= tdata21_r) & tdata11_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = (st_data >= tdata21_r) & tdata11_st & dmp_x2_byte;
                        dmp_ld_data_match1 = (ld_data >= tdata21_r) & tdata11_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (inst_data >= tdata21_r) & tdata11_ex & inst_size;
                        dmp_st_data_match1 = (st_data >= tdata21_r) & tdata11_st & dmp_x2_half_r;
                        dmp_ld_data_match1 = (ld_data >= tdata21_r) & tdata11_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match1 = (inst_data >= tdata21_r) & tdata11_ex & (!inst_size);
                        dmp_st_data_match1 = (st_data >= tdata21_r) & tdata11_st & dmp_x2_word_r;
                        dmp_ld_data_match1 = (ld_data >= tdata21_r) & tdata11_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = 1'b0;
                        dmp_ld_data_match1 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (inst_data < tdata21_r) & tdata11_ex;
                        dmp_st_data_match1 = (st_data < tdata21_r) & tdata11_st;
                        dmp_ld_data_match1 = (ld_data < tdata21_r) & tdata11_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = (st_data < tdata21_r) & tdata11_st & dmp_x2_byte;
                        dmp_ld_data_match1 = (ld_data < tdata21_r) & tdata11_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (inst_data < tdata21_r) & tdata11_ex & inst_size;
                        dmp_st_data_match1 = (st_data < tdata21_r) & tdata11_st & dmp_x2_half_r;
                        dmp_ld_data_match1 = (ld_data < tdata21_r) & tdata11_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match1 = (inst_data < tdata21_r) & tdata11_ex & (!inst_size);
                        dmp_st_data_match1 = (st_data < tdata21_r) & tdata11_st & dmp_x2_word_r;
                        dmp_ld_data_match1 = (ld_data < tdata21_r) & tdata11_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = 1'b0;
                        dmp_ld_data_match1 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (((inst_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_st_data_match1 = (((st_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st;
                        dmp_ld_data_match1 = (((ld_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = (((st_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st & dmp_x2_byte;
                        dmp_ld_data_match1 = (((ld_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (((inst_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_st_data_match1 = (((st_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st & dmp_x2_half_r;
                        dmp_ld_data_match1 = (((ld_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match1 = (((inst_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_st_data_match1 = (((st_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st & dmp_x2_word_r;
                        dmp_ld_data_match1 = (((ld_data[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = 1'b0;
                        dmp_ld_data_match1 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (((inst_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_st_data_match1 = (((st_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st;
                        dmp_ld_data_match1 = (((ld_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = (((st_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st & dmp_x2_byte;
                        dmp_ld_data_match1 = (((ld_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (((inst_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_st_data_match1 = (((st_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st & dmp_x2_half_r;
                        dmp_ld_data_match1 = (((ld_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match1 = (((inst_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_st_data_match1 = (((st_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_st & dmp_x2_word_r;
                        dmp_ld_data_match1 = (((ld_data[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_st_data_match1 = 1'b0;
                        dmp_ld_data_match1 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match1 = 1'b0;
                dmp_st_data_match1 = 1'b0;
                dmp_ld_data_match1 = 1'b0;
            end
    endcase
    else                            // address compare
    case (tdata11_match)
        4'd0, 4'd8:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = ((inst_addr == tdata21_r) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_addr_match1 = ((dmp_addr == tdata21_r) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld);
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = ((dmp_addr == tdata21_r) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = ((inst_addr == tdata21_r) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_addr_match1 = ((dmp_addr == tdata21_r) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match1 = ((inst_addr == tdata21_r) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_addr_match1 = ((dmp_addr == tdata21_r) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = ((~| ((inst_addr ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_addr_match1 = ((~| ((dmp_addr ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld);
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = ((~| ((dmp_addr ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = ((~| ((inst_addr ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_addr_match1 = ((~| ((dmp_addr ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match1 = ((~| ((inst_addr ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_addr_match1 = ((~| ((dmp_addr ^ tdata21_r) & mask1)) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (inst_addr >= tdata21_r) & tdata11_ex;
                        dmp_addr_match1 = (dmp_addr >= tdata21_r) & (tdata11_st | tdata11_ld);
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = (dmp_addr >= tdata21_r) & (tdata11_st | tdata11_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (inst_addr >= tdata21_r) & tdata11_ex & inst_size;
                        dmp_addr_match1 = (dmp_addr >= tdata21_r) & (tdata11_st | tdata11_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match1 = (inst_addr >= tdata21_r) & tdata11_ex & (!inst_size);
                        dmp_addr_match1 = (dmp_addr >= tdata21_r) & (tdata11_st | tdata11_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (inst_addr < tdata21_r) & tdata11_ex;
                        dmp_addr_match1 = (dmp_addr < tdata21_r) & (tdata11_st | tdata11_ld);
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = (dmp_addr < tdata21_r) & (tdata11_st | tdata11_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (inst_addr < tdata21_r) & tdata11_ex & inst_size;
                        dmp_addr_match1 = (dmp_addr < tdata21_r) & (tdata11_st | tdata11_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match1 = (inst_addr < tdata21_r) & tdata11_ex & (!inst_size);
                        dmp_addr_match1 = (dmp_addr < tdata21_r) & (tdata11_st | tdata11_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (((inst_addr[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_addr_match1 = (((dmp_addr[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld);
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = (((dmp_addr[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (((inst_addr[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_addr_match1 = (((dmp_addr[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match1 = (((inst_addr[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_addr_match1 = (((dmp_addr[15:0] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata11_size)
                4'd0: 
                    begin
                        inst_match1 = (((inst_addr[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex;
                        dmp_addr_match1 = (((dmp_addr[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld);
                    end
                4'd1: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = (((dmp_addr[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match1 = (((inst_addr[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & inst_size;
                        dmp_addr_match1 = (((dmp_addr[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match1 = (((inst_addr[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & tdata11_ex & (!inst_size);
                        dmp_addr_match1 = (((dmp_addr[31:16] & tdata21_r[31:16]) == tdata21_r[15:0]) ^ tdata11_match[3]) & (tdata11_st | tdata11_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match1 = 1'b0;
                        dmp_addr_match1 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match1 = 1'b0;
                dmp_addr_match1 = 1'b0;
            end
    endcase
end


// collect current trigger's match result
always @*
begin: match_result_collect1_PROC
   trig1_inst_match        = {1'b0, inst_match1 & priv_match1 & (tdata11_type == 4'h6) & x2_valid_r}; // always before commit
   trig1_dmp_addr_match    = {1'b0, dmp_addr_match1 & priv_match1 & (tdata11_type == 4'd6) & dmp_x2_valid}; // always before commit
   trig1_dmp_st_data_match = {dmp_st_data_match1 & priv_match1 & (tdata11_type == 4'd6) & dmp_x2_valid, 1'b0}; // always post commit
   trig1_dmp_ld_data_match = {dmp_ld_data_match1 & priv_match1 & (tdata11_type == 4'd6) & dmp_x2_rb_req, 1'b0}; // always post commit
end


// Gate hit by the previous trigger's chain and hit
always @*
begin: hit1_PROC
   inst_hit1        = (tdata10_chain & (pre_hit0 == 2'b00)) ? 2'b00 : trig1_inst_match       ;
   dmp_addr_hit1    = (tdata10_chain & (pre_hit0 == 2'b00)) ? 2'b00 : trig1_dmp_addr_match   ;
   dmp_st_data_hit1 = (tdata10_chain & (post_hit0 == 2'b00)) ? 2'b00 : trig1_dmp_st_data_match;
   dmp_ld_data_hit1 = (tdata10_chain & (post_hit0 == 2'b00)) ? 2'b00 : trig1_dmp_ld_data_match; 
end

assign pre_hit1 = inst_hit1 | dmp_addr_hit1;
assign post_hit1 = dmp_st_data_hit1 | dmp_ld_data_hit1;
assign ext_hit1 = (tdata11_r[31:28] == 4'h7) && (| (ext_trig_in & tdata11_sel_ext));

//fire result & bypass ld_data_match 
always @*
begin: fire1_PROC
    inst_fire1         = tdata11_chain ? 2'b00 : inst_hit1;
    dmp_addr_fire1     = tdata11_chain ? 2'b00 : dmp_addr_hit1;
    dmp_st_data_fire1  = tdata11_chain ? 2'b00 : dmp_st_data_hit1;
    dmp_ld_data_fire1  = trig1_dmp_ld_data_match;
end

assign fire1 = inst_fire1 | dmp_addr_fire1 | dmp_st_data_fire1 | dmp_ld_data_fire1;



assign tdata12_type     = tdata12_r[31:28];
assign tdata12_dmode    = tdata12_r[27];
assign tdata12_uncer    = tdata12_r[26];
assign tdata12_vs       = tdata12_r[24];
assign tdata12_vu       = tdata12_r[23];
assign tdata12_sel      = tdata12_r[21];
assign tdata12_tim      = tdata12_r[20];
assign tdata12_size     = tdata12_r[19:16];
assign tdata12_action   = tdata12_r[15:12];
assign tdata12_act      = tdata12_r[5:0];
assign tdata12_sel_ext  = tdata12_r[21:6];
assign tdata12_chain    = tdata12_r[11];
assign tdata12_match    = tdata12_r[10:7];
assign tdata12_m        = tdata12_r[6];
assign tdata12_uncer_en = tdata12_r[5];
assign tdata12_s        = tdata12_r[4];
assign tdata12_u        = tdata12_r[3];
assign tdata12_ex       = tdata12_r[2];
assign tdata12_st       = tdata12_r[1] && (!dmp_x2_load_r);
assign tdata12_ld       = tdata12_r[0] && dmp_x2_load_r;
assign tdata12_ld_only  = tdata12_r[0];

// Priv level detection
//
assign priv_match2        = ((priv_level_r == `PRIV_M) & tdata12_m) | ((priv_level_r == `PRIV_U) & tdata12_u);

// Match detection
//
assign mask2 = ~(tdata22_r + 32'b1) ^ tdata22_r;
//assign napot_hit2 = (~| (comp_value ^ tdata2`i_r) & mask2);


always @*
begin: inst_match2_PROC
    inst_match2        = 1'b0;
    dmp_addr_match2    = 1'b0;
    dmp_st_data_match2 = 1'b0;
    dmp_ld_data_match2 = 1'b0;

    if (tdata12_sel)         // data compare
    case (tdata12_match)
        4'd0, 4'd8:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = ((inst_data == tdata22_r) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_st_data_match2 = ((st_data == tdata22_r) ^ tdata12_match[3]) & tdata12_st;
                        dmp_ld_data_match2 = ((ld_data == tdata22_r) ^ tdata12_match[3]) & tdata12_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = ((st_data == tdata22_r) ^ tdata12_match[3]) & tdata12_st & dmp_x2_byte;
                        dmp_ld_data_match2 = ((ld_data == tdata22_r) ^ tdata12_match[3]) & tdata12_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = ((inst_data == tdata22_r) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_st_data_match2 = ((st_data == tdata22_r) ^ tdata12_match[3]) & tdata12_st & dmp_x2_half_r;
                        dmp_ld_data_match2 = ((ld_data == tdata22_r) ^ tdata12_match[3]) & tdata12_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match2 = ((inst_data == tdata22_r) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_st_data_match2 = ((st_data == tdata22_r) ^ tdata12_match[3]) & tdata12_st & dmp_x2_word_r;
                        dmp_ld_data_match2 = ((ld_data == tdata22_r) ^ tdata12_match[3]) & tdata12_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = 1'b0;
                        dmp_ld_data_match2 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = ((~| ((inst_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_st_data_match2 = ((~| ((st_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_st;
                        dmp_ld_data_match2 = ((~| ((ld_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = ((~| ((st_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_st & dmp_x2_byte;
                        dmp_ld_data_match2 = ((~| ((ld_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = ((~| ((inst_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_st_data_match2 = ((~| ((st_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_st & dmp_x2_half_r;
                        dmp_ld_data_match2 = ((~| ((ld_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match2 = ((~| ((inst_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_st_data_match2 = ((~| ((st_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_st & dmp_x2_word_r;
                        dmp_ld_data_match2 = ((~| ((ld_data ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = 1'b0;
                        dmp_ld_data_match2 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (inst_data >= tdata22_r) & tdata12_ex;
                        dmp_st_data_match2 = (st_data >= tdata22_r) & tdata12_st;
                        dmp_ld_data_match2 = (ld_data >= tdata22_r) & tdata12_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = (st_data >= tdata22_r) & tdata12_st & dmp_x2_byte;
                        dmp_ld_data_match2 = (ld_data >= tdata22_r) & tdata12_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (inst_data >= tdata22_r) & tdata12_ex & inst_size;
                        dmp_st_data_match2 = (st_data >= tdata22_r) & tdata12_st & dmp_x2_half_r;
                        dmp_ld_data_match2 = (ld_data >= tdata22_r) & tdata12_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match2 = (inst_data >= tdata22_r) & tdata12_ex & (!inst_size);
                        dmp_st_data_match2 = (st_data >= tdata22_r) & tdata12_st & dmp_x2_word_r;
                        dmp_ld_data_match2 = (ld_data >= tdata22_r) & tdata12_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = 1'b0;
                        dmp_ld_data_match2 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (inst_data < tdata22_r) & tdata12_ex;
                        dmp_st_data_match2 = (st_data < tdata22_r) & tdata12_st;
                        dmp_ld_data_match2 = (ld_data < tdata22_r) & tdata12_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = (st_data < tdata22_r) & tdata12_st & dmp_x2_byte;
                        dmp_ld_data_match2 = (ld_data < tdata22_r) & tdata12_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (inst_data < tdata22_r) & tdata12_ex & inst_size;
                        dmp_st_data_match2 = (st_data < tdata22_r) & tdata12_st & dmp_x2_half_r;
                        dmp_ld_data_match2 = (ld_data < tdata22_r) & tdata12_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match2 = (inst_data < tdata22_r) & tdata12_ex & (!inst_size);
                        dmp_st_data_match2 = (st_data < tdata22_r) & tdata12_st & dmp_x2_word_r;
                        dmp_ld_data_match2 = (ld_data < tdata22_r) & tdata12_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = 1'b0;
                        dmp_ld_data_match2 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (((inst_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_st_data_match2 = (((st_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st;
                        dmp_ld_data_match2 = (((ld_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = (((st_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st & dmp_x2_byte;
                        dmp_ld_data_match2 = (((ld_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (((inst_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_st_data_match2 = (((st_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st & dmp_x2_half_r;
                        dmp_ld_data_match2 = (((ld_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match2 = (((inst_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_st_data_match2 = (((st_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st & dmp_x2_word_r;
                        dmp_ld_data_match2 = (((ld_data[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = 1'b0;
                        dmp_ld_data_match2 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (((inst_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_st_data_match2 = (((st_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st;
                        dmp_ld_data_match2 = (((ld_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = (((st_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st & dmp_x2_byte;
                        dmp_ld_data_match2 = (((ld_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (((inst_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_st_data_match2 = (((st_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st & dmp_x2_half_r;
                        dmp_ld_data_match2 = (((ld_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match2 = (((inst_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_st_data_match2 = (((st_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_st & dmp_x2_word_r;
                        dmp_ld_data_match2 = (((ld_data[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_st_data_match2 = 1'b0;
                        dmp_ld_data_match2 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match2 = 1'b0;
                dmp_st_data_match2 = 1'b0;
                dmp_ld_data_match2 = 1'b0;
            end
    endcase
    else                            // address compare
    case (tdata12_match)
        4'd0, 4'd8:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = ((inst_addr == tdata22_r) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_addr_match2 = ((dmp_addr == tdata22_r) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld);
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = ((dmp_addr == tdata22_r) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = ((inst_addr == tdata22_r) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_addr_match2 = ((dmp_addr == tdata22_r) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match2 = ((inst_addr == tdata22_r) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_addr_match2 = ((dmp_addr == tdata22_r) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = ((~| ((inst_addr ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_addr_match2 = ((~| ((dmp_addr ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld);
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = ((~| ((dmp_addr ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = ((~| ((inst_addr ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_addr_match2 = ((~| ((dmp_addr ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match2 = ((~| ((inst_addr ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_addr_match2 = ((~| ((dmp_addr ^ tdata22_r) & mask2)) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (inst_addr >= tdata22_r) & tdata12_ex;
                        dmp_addr_match2 = (dmp_addr >= tdata22_r) & (tdata12_st | tdata12_ld);
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = (dmp_addr >= tdata22_r) & (tdata12_st | tdata12_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (inst_addr >= tdata22_r) & tdata12_ex & inst_size;
                        dmp_addr_match2 = (dmp_addr >= tdata22_r) & (tdata12_st | tdata12_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match2 = (inst_addr >= tdata22_r) & tdata12_ex & (!inst_size);
                        dmp_addr_match2 = (dmp_addr >= tdata22_r) & (tdata12_st | tdata12_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (inst_addr < tdata22_r) & tdata12_ex;
                        dmp_addr_match2 = (dmp_addr < tdata22_r) & (tdata12_st | tdata12_ld);
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = (dmp_addr < tdata22_r) & (tdata12_st | tdata12_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (inst_addr < tdata22_r) & tdata12_ex & inst_size;
                        dmp_addr_match2 = (dmp_addr < tdata22_r) & (tdata12_st | tdata12_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match2 = (inst_addr < tdata22_r) & tdata12_ex & (!inst_size);
                        dmp_addr_match2 = (dmp_addr < tdata22_r) & (tdata12_st | tdata12_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (((inst_addr[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_addr_match2 = (((dmp_addr[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld);
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = (((dmp_addr[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (((inst_addr[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_addr_match2 = (((dmp_addr[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match2 = (((inst_addr[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_addr_match2 = (((dmp_addr[15:0] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata12_size)
                4'd0: 
                    begin
                        inst_match2 = (((inst_addr[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex;
                        dmp_addr_match2 = (((dmp_addr[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld);
                    end
                4'd1: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = (((dmp_addr[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match2 = (((inst_addr[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & inst_size;
                        dmp_addr_match2 = (((dmp_addr[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match2 = (((inst_addr[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & tdata12_ex & (!inst_size);
                        dmp_addr_match2 = (((dmp_addr[31:16] & tdata22_r[31:16]) == tdata22_r[15:0]) ^ tdata12_match[3]) & (tdata12_st | tdata12_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match2 = 1'b0;
                        dmp_addr_match2 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match2 = 1'b0;
                dmp_addr_match2 = 1'b0;
            end
    endcase
end


// collect current trigger's match result
always @*
begin: match_result_collect2_PROC
   trig2_inst_match        = {1'b0, inst_match2 & priv_match2 & (tdata12_type == 4'h6) & x2_valid_r}; // always before commit
   trig2_dmp_addr_match    = {1'b0, dmp_addr_match2 & priv_match2 & (tdata12_type == 4'd6) & dmp_x2_valid}; // always before commit
   trig2_dmp_st_data_match = {dmp_st_data_match2 & priv_match2 & (tdata12_type == 4'd6) & dmp_x2_valid, 1'b0}; // always post commit
   trig2_dmp_ld_data_match = {dmp_ld_data_match2 & priv_match2 & (tdata12_type == 4'd6) & dmp_x2_rb_req, 1'b0}; // always post commit
end


// Gate hit by the previous trigger's chain and hit
always @*
begin: hit2_PROC
   inst_hit2        = (tdata11_chain & (pre_hit1 == 2'b00)) ? 2'b00 : trig2_inst_match       ;
   dmp_addr_hit2    = (tdata11_chain & (pre_hit1 == 2'b00)) ? 2'b00 : trig2_dmp_addr_match   ;
   dmp_st_data_hit2 = (tdata11_chain & (post_hit1 == 2'b00)) ? 2'b00 : trig2_dmp_st_data_match;
   dmp_ld_data_hit2 = (tdata11_chain & (post_hit1 == 2'b00)) ? 2'b00 : trig2_dmp_ld_data_match; 
end

assign pre_hit2 = inst_hit2 | dmp_addr_hit2;
assign post_hit2 = dmp_st_data_hit2 | dmp_ld_data_hit2;
assign ext_hit2 = (tdata12_r[31:28] == 4'h7) && (| (ext_trig_in & tdata12_sel_ext));

//fire result & bypass ld_data_match 
always @*
begin: fire2_PROC
    inst_fire2         = tdata12_chain ? 2'b00 : inst_hit2;
    dmp_addr_fire2     = tdata12_chain ? 2'b00 : dmp_addr_hit2;
    dmp_st_data_fire2  = tdata12_chain ? 2'b00 : dmp_st_data_hit2;
    dmp_ld_data_fire2  = trig2_dmp_ld_data_match;
end

assign fire2 = inst_fire2 | dmp_addr_fire2 | dmp_st_data_fire2 | dmp_ld_data_fire2;



assign tdata13_type     = tdata13_r[31:28];
assign tdata13_dmode    = tdata13_r[27];
assign tdata13_uncer    = tdata13_r[26];
assign tdata13_vs       = tdata13_r[24];
assign tdata13_vu       = tdata13_r[23];
assign tdata13_sel      = tdata13_r[21];
assign tdata13_tim      = tdata13_r[20];
assign tdata13_size     = tdata13_r[19:16];
assign tdata13_action   = tdata13_r[15:12];
assign tdata13_act      = tdata13_r[5:0];
assign tdata13_sel_ext  = tdata13_r[21:6];
assign tdata13_chain    = tdata13_r[11];
assign tdata13_match    = tdata13_r[10:7];
assign tdata13_m        = tdata13_r[6];
assign tdata13_uncer_en = tdata13_r[5];
assign tdata13_s        = tdata13_r[4];
assign tdata13_u        = tdata13_r[3];
assign tdata13_ex       = tdata13_r[2];
assign tdata13_st       = tdata13_r[1] && (!dmp_x2_load_r);
assign tdata13_ld       = tdata13_r[0] && dmp_x2_load_r;
assign tdata13_ld_only  = tdata13_r[0];

// Priv level detection
//
assign priv_match3        = ((priv_level_r == `PRIV_M) & tdata13_m) | ((priv_level_r == `PRIV_U) & tdata13_u);

// Match detection
//
assign mask3 = ~(tdata23_r + 32'b1) ^ tdata23_r;
//assign napot_hit3 = (~| (comp_value ^ tdata2`i_r) & mask3);


always @*
begin: inst_match3_PROC
    inst_match3        = 1'b0;
    dmp_addr_match3    = 1'b0;
    dmp_st_data_match3 = 1'b0;
    dmp_ld_data_match3 = 1'b0;

    if (tdata13_sel)         // data compare
    case (tdata13_match)
        4'd0, 4'd8:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = ((inst_data == tdata23_r) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_st_data_match3 = ((st_data == tdata23_r) ^ tdata13_match[3]) & tdata13_st;
                        dmp_ld_data_match3 = ((ld_data == tdata23_r) ^ tdata13_match[3]) & tdata13_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = ((st_data == tdata23_r) ^ tdata13_match[3]) & tdata13_st & dmp_x2_byte;
                        dmp_ld_data_match3 = ((ld_data == tdata23_r) ^ tdata13_match[3]) & tdata13_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = ((inst_data == tdata23_r) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_st_data_match3 = ((st_data == tdata23_r) ^ tdata13_match[3]) & tdata13_st & dmp_x2_half_r;
                        dmp_ld_data_match3 = ((ld_data == tdata23_r) ^ tdata13_match[3]) & tdata13_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match3 = ((inst_data == tdata23_r) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_st_data_match3 = ((st_data == tdata23_r) ^ tdata13_match[3]) & tdata13_st & dmp_x2_word_r;
                        dmp_ld_data_match3 = ((ld_data == tdata23_r) ^ tdata13_match[3]) & tdata13_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = 1'b0;
                        dmp_ld_data_match3 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = ((~| ((inst_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_st_data_match3 = ((~| ((st_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_st;
                        dmp_ld_data_match3 = ((~| ((ld_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = ((~| ((st_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_st & dmp_x2_byte;
                        dmp_ld_data_match3 = ((~| ((ld_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = ((~| ((inst_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_st_data_match3 = ((~| ((st_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_st & dmp_x2_half_r;
                        dmp_ld_data_match3 = ((~| ((ld_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match3 = ((~| ((inst_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_st_data_match3 = ((~| ((st_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_st & dmp_x2_word_r;
                        dmp_ld_data_match3 = ((~| ((ld_data ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = 1'b0;
                        dmp_ld_data_match3 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (inst_data >= tdata23_r) & tdata13_ex;
                        dmp_st_data_match3 = (st_data >= tdata23_r) & tdata13_st;
                        dmp_ld_data_match3 = (ld_data >= tdata23_r) & tdata13_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = (st_data >= tdata23_r) & tdata13_st & dmp_x2_byte;
                        dmp_ld_data_match3 = (ld_data >= tdata23_r) & tdata13_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (inst_data >= tdata23_r) & tdata13_ex & inst_size;
                        dmp_st_data_match3 = (st_data >= tdata23_r) & tdata13_st & dmp_x2_half_r;
                        dmp_ld_data_match3 = (ld_data >= tdata23_r) & tdata13_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match3 = (inst_data >= tdata23_r) & tdata13_ex & (!inst_size);
                        dmp_st_data_match3 = (st_data >= tdata23_r) & tdata13_st & dmp_x2_word_r;
                        dmp_ld_data_match3 = (ld_data >= tdata23_r) & tdata13_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = 1'b0;
                        dmp_ld_data_match3 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (inst_data < tdata23_r) & tdata13_ex;
                        dmp_st_data_match3 = (st_data < tdata23_r) & tdata13_st;
                        dmp_ld_data_match3 = (ld_data < tdata23_r) & tdata13_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = (st_data < tdata23_r) & tdata13_st & dmp_x2_byte;
                        dmp_ld_data_match3 = (ld_data < tdata23_r) & tdata13_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (inst_data < tdata23_r) & tdata13_ex & inst_size;
                        dmp_st_data_match3 = (st_data < tdata23_r) & tdata13_st & dmp_x2_half_r;
                        dmp_ld_data_match3 = (ld_data < tdata23_r) & tdata13_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match3 = (inst_data < tdata23_r) & tdata13_ex & (!inst_size);
                        dmp_st_data_match3 = (st_data < tdata23_r) & tdata13_st & dmp_x2_word_r;
                        dmp_ld_data_match3 = (ld_data < tdata23_r) & tdata13_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = 1'b0;
                        dmp_ld_data_match3 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (((inst_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_st_data_match3 = (((st_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st;
                        dmp_ld_data_match3 = (((ld_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = (((st_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st & dmp_x2_byte;
                        dmp_ld_data_match3 = (((ld_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (((inst_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_st_data_match3 = (((st_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st & dmp_x2_half_r;
                        dmp_ld_data_match3 = (((ld_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match3 = (((inst_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_st_data_match3 = (((st_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st & dmp_x2_word_r;
                        dmp_ld_data_match3 = (((ld_data[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = 1'b0;
                        dmp_ld_data_match3 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (((inst_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_st_data_match3 = (((st_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st;
                        dmp_ld_data_match3 = (((ld_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only;
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = (((st_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st & dmp_x2_byte;
                        dmp_ld_data_match3 = (((ld_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only & dmp_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (((inst_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_st_data_match3 = (((st_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st & dmp_x2_half_r;
                        dmp_ld_data_match3 = (((ld_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only & dmp_half;
                    end
                4'd3: 
                    begin
                        inst_match3 = (((inst_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_st_data_match3 = (((st_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_st & dmp_x2_word_r;
                        dmp_ld_data_match3 = (((ld_data[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ld_only & dmp_word;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_st_data_match3 = 1'b0;
                        dmp_ld_data_match3 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match3 = 1'b0;
                dmp_st_data_match3 = 1'b0;
                dmp_ld_data_match3 = 1'b0;
            end
    endcase
    else                            // address compare
    case (tdata13_match)
        4'd0, 4'd8:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = ((inst_addr == tdata23_r) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_addr_match3 = ((dmp_addr == tdata23_r) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld);
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = ((dmp_addr == tdata23_r) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = ((inst_addr == tdata23_r) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_addr_match3 = ((dmp_addr == tdata23_r) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match3 = ((inst_addr == tdata23_r) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_addr_match3 = ((dmp_addr == tdata23_r) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = 1'b0;
                    end
            endcase
        end
        4'd1, 4'd9:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = ((~| ((inst_addr ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_addr_match3 = ((~| ((dmp_addr ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld);
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = ((~| ((dmp_addr ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = ((~| ((inst_addr ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_addr_match3 = ((~| ((dmp_addr ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match3 = ((~| ((inst_addr ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_addr_match3 = ((~| ((dmp_addr ^ tdata23_r) & mask3)) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = 1'b0;
                    end
            endcase
        end
        4'd2:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (inst_addr >= tdata23_r) & tdata13_ex;
                        dmp_addr_match3 = (dmp_addr >= tdata23_r) & (tdata13_st | tdata13_ld);
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = (dmp_addr >= tdata23_r) & (tdata13_st | tdata13_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (inst_addr >= tdata23_r) & tdata13_ex & inst_size;
                        dmp_addr_match3 = (dmp_addr >= tdata23_r) & (tdata13_st | tdata13_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match3 = (inst_addr >= tdata23_r) & tdata13_ex & (!inst_size);
                        dmp_addr_match3 = (dmp_addr >= tdata23_r) & (tdata13_st | tdata13_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = 1'b0;
                    end
            endcase
        end
        4'd3:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (inst_addr < tdata23_r) & tdata13_ex;
                        dmp_addr_match3 = (dmp_addr < tdata23_r) & (tdata13_st | tdata13_ld);
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = (dmp_addr < tdata23_r) & (tdata13_st | tdata13_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (inst_addr < tdata23_r) & tdata13_ex & inst_size;
                        dmp_addr_match3 = (dmp_addr < tdata23_r) & (tdata13_st | tdata13_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match3 = (inst_addr < tdata23_r) & tdata13_ex & (!inst_size);
                        dmp_addr_match3 = (dmp_addr < tdata23_r) & (tdata13_st | tdata13_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = 1'b0;
                    end
            endcase
        end
        4'd4, 4'd12:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (((inst_addr[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_addr_match3 = (((dmp_addr[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld);
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = (((dmp_addr[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (((inst_addr[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_addr_match3 = (((dmp_addr[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match3 = (((inst_addr[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_addr_match3 = (((dmp_addr[15:0] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = 1'b0;
                    end
            endcase
        end
        4'd5, 4'd13:
        begin
            case (tdata13_size)
                4'd0: 
                    begin
                        inst_match3 = (((inst_addr[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex;
                        dmp_addr_match3 = (((dmp_addr[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld);
                    end
                4'd1: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = (((dmp_addr[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_byte;
                    end
                4'd2: 
                    begin
                        inst_match3 = (((inst_addr[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & inst_size;
                        dmp_addr_match3 = (((dmp_addr[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_half_r;
                    end
                4'd3: 
                    begin
                        inst_match3 = (((inst_addr[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & tdata13_ex & (!inst_size);
                        dmp_addr_match3 = (((dmp_addr[31:16] & tdata23_r[31:16]) == tdata23_r[15:0]) ^ tdata13_match[3]) & (tdata13_st | tdata13_ld) & dmp_x2_word_r;
                    end
                default: 
                    begin
                        inst_match3 = 1'b0;
                        dmp_addr_match3 = 1'b0;
                    end
            endcase
        end
        default: 
            begin
                inst_match3 = 1'b0;
                dmp_addr_match3 = 1'b0;
            end
    endcase
end


// collect current trigger's match result
always @*
begin: match_result_collect3_PROC
   trig3_inst_match        = {1'b0, inst_match3 & priv_match3 & (tdata13_type == 4'h6) & x2_valid_r}; // always before commit
   trig3_dmp_addr_match    = {1'b0, dmp_addr_match3 & priv_match3 & (tdata13_type == 4'd6) & dmp_x2_valid}; // always before commit
   trig3_dmp_st_data_match = {dmp_st_data_match3 & priv_match3 & (tdata13_type == 4'd6) & dmp_x2_valid, 1'b0}; // always post commit
   trig3_dmp_ld_data_match = {dmp_ld_data_match3 & priv_match3 & (tdata13_type == 4'd6) & dmp_x2_rb_req, 1'b0}; // always post commit
end


// Gate hit by the previous trigger's chain and hit
always @*
begin: hit3_PROC
   inst_hit3        = (tdata12_chain & (pre_hit2 == 2'b00)) ? 2'b00 : trig3_inst_match       ;
   dmp_addr_hit3    = (tdata12_chain & (pre_hit2 == 2'b00)) ? 2'b00 : trig3_dmp_addr_match   ;
   dmp_st_data_hit3 = (tdata12_chain & (post_hit2 == 2'b00)) ? 2'b00 : trig3_dmp_st_data_match;
   dmp_ld_data_hit3 = (tdata12_chain & (post_hit2 == 2'b00)) ? 2'b00 : trig3_dmp_ld_data_match; 
end

assign pre_hit3 = inst_hit3 | dmp_addr_hit3;
assign post_hit3 = dmp_st_data_hit3 | dmp_ld_data_hit3;
assign ext_hit3 = (tdata13_r[31:28] == 4'h7) && (| (ext_trig_in & tdata13_sel_ext));

//fire result & bypass ld_data_match 
always @*
begin: fire3_PROC
    inst_fire3         = tdata13_chain ? 2'b00 : inst_hit3;
    dmp_addr_fire3     = tdata13_chain ? 2'b00 : dmp_addr_hit3;
    dmp_st_data_fire3  = tdata13_chain ? 2'b00 : dmp_st_data_hit3;
    dmp_ld_data_fire3  = trig3_dmp_ld_data_match;
end

assign fire3 = inst_fire3 | dmp_addr_fire3 | dmp_st_data_fire3 | dmp_ld_data_fire3;



// Compare value generation
//
assign inst_data = x2_inst;
assign inst_addr = {x2_pc, 1'b0};
assign inst_size = x2_inst_size;
assign ld_data   = dmp_x2_data;
assign st_data   = dmp_x2_data_r;
assign dmp_addr  = dmp_x2_addr_r;
assign dmp_byte  = (lsq_rb_size == 2'b0);
assign dmp_half  = (lsq_rb_size == 2'b01);
assign dmp_word  = (lsq_rb_size == 2'b10);
assign dmp_x2_byte = (!dmp_x2_word_r) & (!dmp_x2_half_r);


// Final actions
//
assign i_ifu_trig_trap = 1'b0
                | ((| inst_fire0) & (tdata10_action == 4'h0))
                | ((| inst_fire1) & (tdata11_action == 4'h0))
                | ((| inst_fire2) & (tdata12_action == 4'h0))
                | ((| inst_fire3) & (tdata13_action == 4'h0))
                ;
assign i_ifu_trig_break = 1'b0
                | ((| inst_fire0) & (tdata10_action == 4'h1))
                | ((| inst_fire1) & (tdata11_action == 4'h1))
                | ((| inst_fire2) & (tdata12_action == 4'h1))
                | ((| inst_fire3) & (tdata13_action == 4'h1))
                ;

assign i_dmp_addr_trig_trap = 1'b0
                | ((| dmp_addr_fire0) & (tdata10_action == 4'h0))
                | ((| dmp_addr_fire1) & (tdata11_action == 4'h0))
                | ((| dmp_addr_fire2) & (tdata12_action == 4'h0))
                | ((| dmp_addr_fire3) & (tdata13_action == 4'h0))
                ;
assign i_dmp_addr_trig_break = 1'b0
                | ((| dmp_addr_fire0) & (tdata10_action == 4'h1))
                | ((| dmp_addr_fire1) & (tdata11_action == 4'h1))
                | ((| dmp_addr_fire2) & (tdata12_action == 4'h1))
                | ((| dmp_addr_fire3) & (tdata13_action == 4'h1))
                ;

assign i_dmp_st_data_trig_trap = 1'b0
                | ((| dmp_st_data_fire0) & (tdata10_action == 4'h0))
                | ((| dmp_st_data_fire1) & (tdata11_action == 4'h0))
                | ((| dmp_st_data_fire2) & (tdata12_action == 4'h0))
                | ((| dmp_st_data_fire3) & (tdata13_action == 4'h0))
                ;
assign i_dmp_st_data_trig_break = 1'b0
                | ((| dmp_st_data_fire0) & (tdata10_action == 4'h1))
                | ((| dmp_st_data_fire1) & (tdata11_action == 4'h1))
                | ((| dmp_st_data_fire2) & (tdata12_action == 4'h1))
                | ((| dmp_st_data_fire3) & (tdata13_action == 4'h1))
                ;

assign i_dmp_ld_data_trig_trap = 1'b0
                | ((| dmp_ld_data_fire0) & (tdata10_action == 4'h0))
                | ((| dmp_ld_data_fire1) & (tdata11_action == 4'h0))
                | ((| dmp_ld_data_fire2) & (tdata12_action == 4'h0))
                | ((| dmp_ld_data_fire3) & (tdata13_action == 4'h0))
                ;
assign i_dmp_ld_data_trig_break = 1'b0
                | ((| dmp_ld_data_fire0) & (tdata10_action == 4'h1))
                | ((| dmp_ld_data_fire1) & (tdata11_action == 4'h1))
                | ((| dmp_ld_data_fire2) & (tdata12_action == 4'h1))
                | ((| dmp_ld_data_fire3) & (tdata13_action == 4'h1))
                ;

assign i_ext_trig_trap = 1'b0
                | (ext_hit0 & (tdata10_action == 4'h0))
                | (ext_hit1 & (tdata11_action == 4'h0))
                | (ext_hit2 & (tdata12_action == 4'h0))
                | (ext_hit3 & (tdata13_action == 4'h0))
                ;
assign i_ext_trig_break = 1'b0
                | (ext_hit0 & (tdata10_action == 4'h1))
                | (ext_hit1 & (tdata11_action == 4'h1))
                | (ext_hit2 & (tdata12_action == 4'h1))
                | (ext_hit3 & (tdata13_action == 4'h1))
                ;

assign ext_trig_0 = 1'b0 
                | (((| dmp_st_data_fire0 & x2_pass) | (| dmp_ld_data_fire0) | ext_hit0 | (| dmp_addr_fire0 & x2_pass) | (| inst_fire0)) & (tdata10_action == 4'h8))
                | (((| dmp_st_data_fire1 & x2_pass) | (| dmp_ld_data_fire1) | ext_hit1 | (| dmp_addr_fire1 & x2_pass) | (| inst_fire1)) & (tdata11_action == 4'h8))
                | (((| dmp_st_data_fire2 & x2_pass) | (| dmp_ld_data_fire2) | ext_hit2 | (| dmp_addr_fire2 & x2_pass) | (| inst_fire2)) & (tdata12_action == 4'h8))
                | (((| dmp_st_data_fire3 & x2_pass) | (| dmp_ld_data_fire3) | ext_hit3 | (| dmp_addr_fire3 & x2_pass) | (| inst_fire3)) & (tdata13_action == 4'h8))
                ;

assign ext_trig_1 = 1'b0 
                | (((| dmp_st_data_fire0 & x2_pass) | (| dmp_ld_data_fire0) | ext_hit0 | (| dmp_addr_fire0 & x2_pass) | (| inst_fire0)) & (tdata10_action == 4'h9))
                | (((| dmp_st_data_fire1 & x2_pass) | (| dmp_ld_data_fire1) | ext_hit1 | (| dmp_addr_fire1 & x2_pass) | (| inst_fire1)) & (tdata11_action == 4'h9))
                | (((| dmp_st_data_fire2 & x2_pass) | (| dmp_ld_data_fire2) | ext_hit2 | (| dmp_addr_fire2 & x2_pass) | (| inst_fire2)) & (tdata12_action == 4'h9))
                | (((| dmp_st_data_fire3 & x2_pass) | (| dmp_ld_data_fire3) | ext_hit3 | (| dmp_addr_fire3 & x2_pass) | (| inst_fire3)) & (tdata13_action == 4'h9))
                ;


assign ext_trig_output_valid = {ext_trig_output_valid_1, ext_trig_output_valid_0};
assign ext_trig_output_accept_0 = ext_trig_output_accept[0];
assign ext_trig_output_accept_1 = ext_trig_output_accept[1];

// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ : Intended as per the design
always @ (posedge clk or posedge rst_a)
begin: ext_trig_reg_0_PROC
    if (rst_a == 1'b1)
        ext_trig_output_valid_0 <= 1'b0;
    else if (ext_trig_output_accept_0)
        ext_trig_output_valid_0 <= 1'b0;
    else if (ext_trig_0)
        ext_trig_output_valid_0 <= 1'b1;
end

always @ (posedge clk or posedge rst_a)
begin: ext_trig_reg_1_PROC
    if (rst_a == 1'b1)
        ext_trig_output_valid_1 <= 1'b0;
    else if (ext_trig_output_accept_1)
        ext_trig_output_valid_1 <= 1'b0;
    else if (ext_trig_1)
        ext_trig_output_valid_1 <= 1'b1;
end
// spyglass enable_block RegInputOutput-ML

// For in2reg timing
always @ (posedge clk or posedge rst_a)
begin: ext_trig_flop_PROC
    if (rst_a == 1'b1) begin
        ext_trig_break_r <= 1'b0;
        ext_trig_trap_r  <= 1'b0;
    end
    else begin
        ext_trig_break_r <= ext_trig_break;
        ext_trig_trap_r  <= ext_trig_trap;
    end
end


rl_triggers_iso u_rl_triggers_iso(
  .i_csr_rdata                  ( i_csr_rdata                ), 
  .i_csr_illegal                ( i_csr_illegal              ),
  .i_csr_unimpl                 ( i_csr_unimpl               ),
  .i_csr_serial                 ( i_csr_serial               ),
  .i_csr_strict                 ( i_csr_strict               ),
  .i_ifu_trig_break             ( i_ifu_trig_break           ), 
  .i_ifu_trig_trap              ( i_ifu_trig_trap            ),
  .i_dmp_addr_trig_break        ( i_dmp_addr_trig_break      ), 
  .i_dmp_addr_trig_trap         ( i_dmp_addr_trig_trap       ), 
  .i_dmp_ld_data_trig_break     ( i_dmp_ld_data_trig_break   ), 
  .i_dmp_ld_data_trig_trap      ( i_dmp_ld_data_trig_trap    ), 
  .i_ext_trig_break             ( i_ext_trig_break           ), 
  .i_ext_trig_trap              ( i_ext_trig_trap            ), 
  .i_dmp_st_data_trig_break     ( i_dmp_st_data_trig_break   ), 
  .i_dmp_st_data_trig_trap      ( i_dmp_st_data_trig_trap    ), 
  .o_csr_rdata                  ( csr_rdata                  ), 
  .o_csr_illegal                ( csr_illegal                ),
  .o_csr_unimpl                 ( csr_unimpl                 ),
  .o_ifu_trig_break             ( x2_inst_break             ), 
  .o_ifu_trig_trap              ( x2_inst_trap              ),
  .o_csr_serial                 ( csr_serial_sr              ),
  .o_csr_strict                 ( csr_strict_sr              ),
  .o_dmp_addr_trig_break        ( dmp_addr_trig_break        ), 
  .o_dmp_addr_trig_trap         ( dmp_addr_trig_trap         ), 
  .o_ext_trig_break             ( ext_trig_break             ), 
  .o_ext_trig_trap              ( ext_trig_trap              ), 
  .o_dmp_ld_data_trig_break     ( dmp_ld_data_trig_break     ), 
  .o_dmp_ld_data_trig_trap      ( dmp_ld_data_trig_trap      ), 
  .o_dmp_st_data_trig_break     ( dmp_st_data_trig_break     ), 
  .o_dmp_st_data_trig_trap      ( dmp_st_data_trig_trap      ),
  .aps_iso_err                  ( dr_secure_trig_iso_err     ),
  .aux_ap_iso_en_r              ( secure_trig_iso_en         )
);


/////////////////////////////
// @@@ TODO:
// enable ifu stage inst/pc match for none-chained triggers
assign ifu_trig_trap = 1'b0;
assign ifu_trig_break = 1'b0;
/////////////////////////////
endmodule

