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

`include "clint_defines.v"
`include "defines.v"

module iprio_arb (

  ////////// General input signals /////////////////////////////////////////////
  //
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio0,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio1,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio2,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio3,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio4,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio5,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio6,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio7,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio8,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio9,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio10,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio11,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio12,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio13,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio14,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio15,                
  ///////// output
  output [3:0]                   out_idx,   
  output [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                   out_prio  


 );


// the lower prio, the higher priority
// if prio is same, lower index has high priority
// 0 is not active irq


  wire [1:0]                   l2_out_idx0;   
  wire [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                   l2_out_prio0;   
  wire [1:0]                   l2_out_idx1;   
  wire [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                   l2_out_prio1;   
  wire [1:0]                   l2_out_idx2;   
  wire [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                   l2_out_prio2;   
  wire [1:0]                   l2_out_idx3;   
  wire [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                   l2_out_prio3;   
  wire [1:0]                   l3_out_idx;   
  wire [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                   l3_out_prio;   

// level 1

iprio_arb_4to1 u1_0_iprio_arb_4to1(
 .in_prio0      (in_prio0),
 .in_prio1      (in_prio1),
 .in_prio2      (in_prio2),
 .in_prio3      (in_prio3),
 .out_idx      (l2_out_idx0),
 .out_prio     (l2_out_prio0)

);

iprio_arb_4to1 u1_1_iprio_arb_4to1(
 .in_prio0      (in_prio4),
 .in_prio1      (in_prio5),
 .in_prio2      (in_prio6),
 .in_prio3      (in_prio7),
 .out_idx      (l2_out_idx1),
 .out_prio     (l2_out_prio1)

);

iprio_arb_4to1 u1_2_iprio_arb_4to1(
 .in_prio0      (in_prio8),
 .in_prio1      (in_prio9),
 .in_prio2      (in_prio10),
 .in_prio3      (in_prio11),
 .out_idx      (l2_out_idx2),
 .out_prio     (l2_out_prio2)

);

iprio_arb_4to1 u1_3_iprio_arb_4to1(
 .in_prio0      (in_prio12),
 .in_prio1      (in_prio13),
 .in_prio2      (in_prio14),
 .in_prio3      (in_prio15),
 .out_idx      (l2_out_idx3),
 .out_prio     (l2_out_prio3)

);

// level 3
iprio_arb_4to1 u3_iprio_arb_4to1(
 .in_prio0      (l2_out_prio0),
 .in_prio1      (l2_out_prio1),
 .in_prio2      (l2_out_prio2),
 .in_prio3      (l2_out_prio3),
 .out_idx      (l3_out_idx),
 .out_prio     (l3_out_prio)

);

reg [1:0] l2_out_idx;


always @*
begin
case (l3_out_idx)
2'b00: l2_out_idx = l2_out_idx0;
2'b01: l2_out_idx = l2_out_idx1;
2'b10: l2_out_idx = l2_out_idx2;
2'b11: l2_out_idx = l2_out_idx3;
endcase

end


assign out_prio = l3_out_prio;

assign out_idx = {l3_out_idx,l2_out_idx};

endmodule
