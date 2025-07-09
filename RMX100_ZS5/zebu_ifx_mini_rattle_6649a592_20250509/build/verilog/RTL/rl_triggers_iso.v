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
//    #      #####   #######  ###  #######  #     #  ######   #     #  #######
//   # #    #     #     #      #   #     #  ##    #  #     #  ##    #     #
//  #   #   #           #      #   #     #  # #   #  #     #  # #   #     #
// #     #  #           #      #   #     #  #  #  #  ######   #  #  #     #
// #######  #           #      #   #     #  #   # #  #        #   # #     #
// #     #  #     #     #      #   #     #  #    ##  #        #    ##     #
// #     #   #####      #     ###  #######  #     #  #        #     #     #
//
// ===========================================================================
//
// Description:
//
//  This module implements the configurable Actionpoints unit of the
//  ARCv2EM CPU.
//
//  This .vpp source file may be pre-processed with the Verilog Pre-Processor
//  (VPP) to produce the equivalent .v file using a command such as:
//
//   vpp +q +o actionpoints.vpp
//
// ==========================================================================

// Configuration-dependent macro definitions
//

`include "const.def"

module rl_triggers_iso (
  ////////// General input signals /////////////////////////////////////////
  input       [`DATA_RANGE]   i_csr_rdata, 
  input                       i_csr_illegal, 
  input                       i_csr_unimpl, 
  input                       i_csr_serial, 
  input                       i_csr_strict,
  input                       i_ifu_trig_break,
  input                       i_dmp_addr_trig_break,
  input                       i_dmp_ld_data_trig_break,
  input                       i_dmp_st_data_trig_break,
  input                       i_ifu_trig_trap,
  input                       i_dmp_addr_trig_trap,
  input                       i_dmp_ld_data_trig_trap,
  input                       i_dmp_st_data_trig_trap,
  input                       i_ext_trig_trap,
  input                       i_ext_trig_break,
  output reg  [`DATA_RANGE]   o_csr_rdata, 
  output reg                  o_csr_illegal, 
  output reg                  o_csr_unimpl, 
  output reg                  o_csr_serial, 
  output reg                  o_csr_strict, 
  output reg                  o_ifu_trig_break,
  output reg                  o_dmp_addr_trig_break,
  output reg                  o_dmp_ld_data_trig_break,
  output reg                  o_dmp_st_data_trig_break,
  output reg                  o_ifu_trig_trap,
  output reg                  o_dmp_addr_trig_trap,
  output reg                  o_dmp_ld_data_trig_trap,
  output reg                  o_dmp_st_data_trig_trap,
  output reg                  o_ext_trig_trap,
  output reg                  o_ext_trig_break,
  output     [1:0]            aps_iso_err,
  input                       aux_ap_iso_en_r    

);




wire   ap_iso_dis;
assign ap_iso_dis       = (!aux_ap_iso_en_r);

wire  ap_output_all0;
wire  ap_output_any1;

assign ap_output_any1   = (|{o_csr_rdata  ,
                             o_csr_illegal  ,
                             (!o_csr_unimpl),
                             o_csr_serial,
                             o_csr_strict,
                             o_ifu_trig_break,
                             o_dmp_addr_trig_break,
                             o_dmp_ld_data_trig_break,
                             o_dmp_st_data_trig_break,
                             o_ifu_trig_trap,
                             o_dmp_addr_trig_trap,
                             o_ext_trig_trap,
                             o_ext_trig_break,
                             o_dmp_ld_data_trig_trap,
                             o_dmp_st_data_trig_trap});
assign ap_output_all0   = !(|{o_csr_rdata  ,
                             o_csr_illegal  ,
                             (!o_csr_unimpl),
                             o_csr_serial,
                             o_csr_strict,
                             o_ifu_trig_break,
                             o_dmp_addr_trig_break,
                             o_dmp_ld_data_trig_break,
                             o_dmp_st_data_trig_break,
                             o_ext_trig_trap,
                             o_ext_trig_break,
                             o_ifu_trig_trap,
                             o_dmp_addr_trig_trap,
                             o_dmp_ld_data_trig_trap,
                             o_dmp_st_data_trig_trap});

assign aps_iso_err = ap_iso_dis ? 2'b01 : {ap_output_any1, ap_output_all0};

always @*
begin: isolation_PROC
   if( ap_iso_dis )
   begin
    o_csr_rdata              = i_csr_rdata;
    o_csr_illegal            = i_csr_illegal;
    o_csr_unimpl             = i_csr_unimpl;
    o_csr_serial             = i_csr_serial;
    o_csr_strict             = i_csr_strict;
    o_ifu_trig_break         = i_ifu_trig_break;
    o_dmp_addr_trig_break    = i_dmp_addr_trig_break;
    o_dmp_ld_data_trig_break = i_dmp_ld_data_trig_break;
    o_dmp_st_data_trig_break = i_dmp_st_data_trig_break;
    o_ifu_trig_trap          = i_ifu_trig_trap;
    o_dmp_addr_trig_trap     = i_dmp_addr_trig_trap;
    o_ext_trig_break         = i_ext_trig_break;
    o_ext_trig_trap          = i_ext_trig_trap;
    o_dmp_ld_data_trig_trap  = i_dmp_ld_data_trig_trap;
    o_dmp_st_data_trig_trap  = i_dmp_st_data_trig_trap;
   end
   else
   begin
    o_csr_rdata              = `DATA_SIZE'b0;
    o_csr_illegal            = 1'b0;
    o_csr_unimpl             = 1'b1;
    o_csr_serial             = 1'b0;
    o_csr_strict             = 1'b0;
    o_ifu_trig_break         = 1'b0;
    o_dmp_addr_trig_break    = 1'b0;
    o_dmp_ld_data_trig_break = 1'b0;
    o_dmp_st_data_trig_break = 1'b0;
    o_ext_trig_break         = 1'b0;
    o_ext_trig_trap          = 1'b0;
    o_ifu_trig_trap          = 1'b0;
    o_dmp_addr_trig_trap     = 1'b0;
    o_dmp_ld_data_trig_trap  = 1'b0;
    o_dmp_st_data_trig_trap  = 1'b0;
   end
end

endmodule
