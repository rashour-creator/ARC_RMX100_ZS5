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

module rl_dmp_amo (
  input  [`DMP_CTL_AMO_RANGE]  amo_ctl,      // Indicates the instructon to be executed in this FU
  input         [`DATA_RANGE]  amo_mem_data, // source0 operand  -- MEM[X[rs1]]
  input         [`DATA_RANGE]  amo_x_data,   // source1 operand  -- X[rs2]
  output reg    [`DATA_RANGE]  amo_result    // result           -- X[rd]
);

// Local declarations
//

  wire  slt_test;
  wire  ult_test;

  wire  amo_ctl_amoadd;
  wire  amo_ctl_amoxor;
  wire  amo_ctl_amoand;
  wire  amo_ctl_amoor;
  wire  amo_ctl_amomin;
  wire  amo_ctl_amomax;
  wire  amo_ctl_amominu;
  wire  amo_ctl_amomaxu;

  assign slt_test = ( $signed(amo_x_data) < $signed(amo_mem_data) );
  assign ult_test = (         amo_x_data  <         amo_mem_data  );

  assign amo_ctl_amoadd  = amo_ctl[`DMP_CTL_AMOADD];
  assign amo_ctl_amoxor  = amo_ctl[`DMP_CTL_AMOXOR];
  assign amo_ctl_amoand  = amo_ctl[`DMP_CTL_AMOAND];
  assign amo_ctl_amoor   = amo_ctl[`DMP_CTL_AMOOR];
  assign amo_ctl_amomin  = amo_ctl[`DMP_CTL_AMOMIN];
  assign amo_ctl_amominu = amo_ctl[`DMP_CTL_AMOMINU];
  assign amo_ctl_amomax  = amo_ctl[`DMP_CTL_AMOMAX];
  assign amo_ctl_amomaxu = amo_ctl[`DMP_CTL_AMOMAXU];

  always @*
  begin : dmp_amo_PROC
    case (1'b1)
  // spyglass disable_block W164a
  // SMD: LHS width is less than RHS
  // SJ: Result LHS has a bit less than RHS. Addition carry is not needed.    
      amo_ctl_amoadd  : amo_result = amo_x_data + amo_mem_data;
  // spyglass enable_block W164a      
      amo_ctl_amoxor  : amo_result = amo_x_data ^ amo_mem_data;
      amo_ctl_amoand  : amo_result = amo_x_data & amo_mem_data;
      amo_ctl_amoor   : amo_result = amo_x_data | amo_mem_data;
      amo_ctl_amomin  : amo_result = slt_test ? amo_x_data   : amo_mem_data;
      amo_ctl_amominu : amo_result = ult_test ? amo_x_data   : amo_mem_data;
      amo_ctl_amomax  : amo_result = slt_test ? amo_mem_data : amo_x_data;
      amo_ctl_amomaxu : amo_result = ult_test ? amo_mem_data : amo_x_data;
      default         : amo_result = amo_x_data;
    endcase
  end

endmodule // rl_dmp_amo

