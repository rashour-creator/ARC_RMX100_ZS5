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


module iprio_arb_4to1 (

  ////////// General input signals /////////////////////////////////////////////
  //
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio0,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio1,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio2,                
  input [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                    in_prio3,                
  ///////// output
  output reg [1:0]                   out_idx,   
  output reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0]                   out_prio  


 );

// the lower prio, the higher priority
// if prio is same, lower index has high priority
// 0 is not active irq

reg irq0_ge_irq1;
reg irq0_ge_irq2;
reg irq0_ge_irq3;
reg irq1_ge_irq2;
reg irq1_ge_irq3;
reg irq2_ge_irq3;



always @*
begin

 irq0_ge_irq1 = 1'b0;
 irq0_ge_irq2 = 1'b0; 
 irq0_ge_irq3 = 1'b0;
 irq1_ge_irq2 = 1'b0;
 irq1_ge_irq3 = 1'b0;
 irq2_ge_irq3 = 1'b0;

irq0_ge_irq1 = (~(in_prio0 > in_prio1));
irq0_ge_irq2 = ~(in_prio0 > in_prio2);
irq0_ge_irq3 = ~(in_prio0 > in_prio3);
irq1_ge_irq2 = ~(in_prio1 > in_prio2);
irq1_ge_irq3 = ~(in_prio1 > in_prio3);
irq2_ge_irq3 = ~(in_prio2 > in_prio3);
end


always @*
begin
out_idx = 0;
out_prio = 0;
// check piro0
  if (irq0_ge_irq1 & irq0_ge_irq2 & irq0_ge_irq3) begin
  out_idx = 2'd0;
  out_prio = in_prio0;
  end
// check piro1
  if (irq1_ge_irq2 & irq1_ge_irq3 & ~irq0_ge_irq1) begin
  out_idx = 2'd1;
  out_prio = in_prio1;
  end
// check piro2
  if (irq2_ge_irq3 & ~irq0_ge_irq2 & ~irq1_ge_irq2) begin
  out_idx = 2'd2;
  out_prio = in_prio2;
  end
// check piro3
  if (~irq0_ge_irq3 & ~irq1_ge_irq3 & ~irq2_ge_irq3) begin
  out_idx = 2'd3;
  out_prio = in_prio3;
  end

end



endmodule
