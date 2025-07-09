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
//  The module hierarchy, at and below this module, is:
//
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions
//
`include "defines.v"
`include "ifu_defines.v"
`include "mpy_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_ifu_align (
  ////////// Input data from F1 /////////////////////////////////////////////
  //
  input [1:0]                    ic_f1_data_out_valid,    // Select IC
  input [31:0]                   ic_f1_data0,             // 4-byte fetch block0
  input [1:0]                    ic_f1_data_err,          // valid bits
  input                          ic_f1_bus_err,             // Bus Error for Un-Cached/Cached access fetch


  input [1:0]                    iccm0_f1_data_out_valid,  // Select ICCM0
  input [31:0]                   iccm0_f1_data0,           // 4-byte fetch block0
  input [1:0]                    iccm0_f1_data_err,        // valid bits


  ////////// PMP interface ////////////////////////////////////////////////
  //
  input                          ipmp_hit0,                // PMP hit
  input  [5:0]                   ipmp_perm0,              // {L, X, W, R}
  input  [1:0]                   priv_level,
  output reg                     al_pmp_viol,
  output reg [`IFU_ADDR_RANGE]   pmp_viol_addr,
  input  [`IFU_ADDR_RANGE]       ifu_pmp_addr0,

  ////////// PMA interface ////////////////////////////////////////////////
  //
  input  [3:0]                   ipma_attr0,              // {L, X, W, R}
  output reg                     al_pma_viol,

  input                          f1_offset,
  input [`IFU_ADDR_RANGE]        f1_addr0,               // fetch block0 address
      // 2-Byte Offset in the FA0 Fetch Block

  ////////// Instruction issue interface //////////////////////////////////
  //
  output reg                     al_issue,          // IFU issues instruction
  output [`PC_RANGE]             al_pc,             // I-stage PC
  output reg [2:0]               al_size,           // 010-16 bit inst, 100-32 bit inst
  output reg [4:0]               al_pd_addr0,       // reg0 addr from pre-decoder
  output reg [4:0]               al_pd_addr1,       // reg1 addr from pre-decoder
  output reg [`INST_RANGE]       al_inst,           // acutal instruction word
  output [1:0]                   al_fusion,         // fusion info
  output reg                     al_bus_err,        // IBP Bus Error
  output reg                     al_ecc_err,
  output reg [`FU_1H_RANGE]      al_pd_fu,          // function unit active 1-hot

  input                          x1_holdup,         // RA stage holds-up
  input                          uop_busy,
  input                          db_active,

  ////////// Fetch restart //////////////////////////////////////////////////
  //
  input                          ifu_restart,
  input [`PC_RANGE]              ifu_target,        //

  ////////// Branch interface interface  ///////////////////////////////////////
  //
  input                          br_req_ifu,
  input [`PC_RANGE]              br_restart_pc,     // BR target

  output reg [`PC_RANGE]         fch_pc_nxt,      // Next pc to be fetched
  output reg                     fch_same_pc,     // Next pc to be fetched
  output                         iq_full,            // IQ is full

  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                // clock signal
  input                          rst_a               // reset signal
);

////////////////////////////////////////////////////////////////////////////
//
//
//        F0      |      F1        |
//                |                |
//                |                |
//       FTB      |    Mem acc     |   IQ
//                | (align, issue) |
//                |                |
//                |                |
//
////////////////////////////////////////////////////////////////////////////
// F0 - F1
reg [1:0]           al_f1_data_valid;
reg [31:0]          al_f1_data0;
reg [1:0]           al_f1_valid;
reg [1:0]           al_f1_data_err;
reg                 al_f1_bus_err;
wire [`FU_1H_RANGE] al_pd_fu_tmp;
wire [4:0]          al_pd_src0;
wire [4:0]          al_pd_src1;
wire                al_pd_src0_valid;
wire                al_pd_src1_valid;
wire                al_pd_is_16bit;
reg [`IQ_Q_RANGE]   info0;
reg [`IQ_Q_RANGE]   al_f2_info0;
reg [`IQ_Q_RANGE]   info1;
reg [`IQ_Q_RANGE]   al_f2_info1;
reg [`IQ_Q_RANGE]   info2;
reg [`IQ_Q_RANGE]   al_f2_info2;
reg [3:0]           info_valid;
reg [31:0]          pd0_data_in; 
wire                al_pd0_is_16bit;
reg [31:0]          pd1_data_in; 
wire                al_pd1_is_16bit;
reg [31:0]          pd2_data_in; 
wire                al_pd2_is_16bit;
reg                 info0_is_16bit;
reg [2:0]           i0_offset;
reg                 al_pc_cg0;
reg [`PC_RANGE]     al_pc_nxt;
reg [`PC_RANGE]     al_pc_r;
reg                 use_spill_inst;
reg                 use_spill_inst_nxt;
reg                 spill_valid_cg0;
reg                 spill_data_cg0;
reg                 spill_valid_r; 
reg [15:0]          spill_data_r;
reg                 spill_ecc_err_r;
reg                 spill_bus_err_r;
reg                 spill_valid_nxt; 
reg [15:0]          spill_data_nxt;
reg                 spill_ecc_err_nxt;
reg                 spill_bus_err_nxt;
reg                 spill_set;

wire                set;
wire                spill_and_data_valid;
wire                al_restart;

wire     pma_viol0;
reg      pma_viol_r;

assign pma_viol0 = (ipma_attr0 == 4'b1111); // @@@ Invalid or device non-ide will trigger fetch violation
wire    mmwp0;
wire    mml0;
wire    lock0;
wire    exu0;
wire    res0;
reg     pmp_viol_r;
reg     pmp_viol0;
reg [`IFU_ADDR_RANGE]   ifu_pmp_addr_r;

//////////////////////////////////////////////////////////////////////////////
//
// Incoming data mux
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : al_f1_mux_PROC
  // Select data to be aligned
  //
  al_f1_data0 = 32'd0
              | ({32{iccm0_f1_data_out_valid[0]}} & iccm0_f1_data0)
              | ({32{ic_f1_data_out_valid[0]}} & ic_f1_data0)
              ;

  // Valid...
  //
  al_f1_data_valid = 2'b00
                   | iccm0_f1_data_out_valid
                   | ic_f1_data_out_valid
                   ;

  al_f1_data_err = 2'b00
                   | iccm0_f1_data_err
                   | ic_f1_data_err
                   ;

  al_f1_bus_err  = 1'b0  
                   | ic_f1_bus_err
                   ;
end


//////////////////////////////////////////////////////////////////////////////
// Predecoder Input 
//////////////////////////////////////////////////////////////////////////////
always@*
begin: pd_data_ip_PROC
  pd0_data_in = {al_f1_data0[15:0], spill_data_r[15:0]};
  pd1_data_in = al_f1_data0; 
  pd2_data_in = {16'b0, al_f1_data0[31:16]};
end

//////////////////////////////////////////////////////////////////////////////
//
// Module instantiation
//
//////////////////////////////////////////////////////////////////////////////

assign al_pd0_is_16bit = ~(&pd0_data_in[1:0]);
assign al_pd1_is_16bit = ~(&pd1_data_in[1:0]);
assign al_pd2_is_16bit = ~(&pd2_data_in[1:0]);
rl_predecoder u_rl_predecoder (
  .inst             (al_inst),

  .pd_is_16bit      (al_pd_is_16bit),
  .pd_rf_src0       (al_pd_src0),
  //spyglass disable_block UnloadedOutTerm-ML
  //SMD: Unloaded but driven output terminal of an instance detected 
  //SJ : unused outputs in this configuration
  .pd_rf_src0_valid (al_pd_src0_valid),
  .pd_rf_src1       (al_pd_src1),
  .pd_rf_src1_valid (al_pd_src1_valid),
  //spyglass enable_block UnloadedOutTerm-ML
  .pd_fu            (al_pd_fu_tmp)

);

assign al_restart = ifu_restart | br_req_ifu;

//////////////////////////////////////////////////////////////////////////////
//                                                                          
// Sequential alignment process
// 
// We find out the starting offset of each instruction in a sequence fashion
//                                                                           
//////////////////////////////////////////////////////////////////////////////
//   +-----------------------------------   +-----------------------------------    -----------------    
//   |        I4       |      I3        |   |      I2         |       I1       |    |    0 (spill)  |   
//   +-----------+-------+-------+-------   +-----------+-------+-------+-------    -+-------+-------   

always @*
begin : i0_offset_PROC
  // The offset of inst0 depends on the spill state. The offset in the expression below takes care of jump
  // targets in the middle of fetch block0. See diagram above to understand why we are adding 1'b1
  //
  i0_offset = spill_valid_r ? 3'b000 : ({2'b00, f1_offset} + 1'b1);
end
// spyglass disable_block W553
// SMD: Different bits of a bus are driven in different combinational blocks
// SJ:  spill_set and info_valid are defined as bus and each bit of the bus is ised in different block. Intended as per the design
always @*
begin : i0_out_mux_PROC
  // Default values
  //
  spill_set                    = 1'b0;
  info0[`PMP_VIOL]             = 1'b0;  // naming convention. `// See ifu_defines of rmx_500 branch
  info0[`IFU_BUS_ERR]          = ic_f1_bus_err;
  info0[`IFU_ECC_ERR]          = al_f1_data_err[0];
  use_spill_inst_nxt           = 1'b0;
  info0[`IFU_FA_STR_ERR]       = 1'b0; 
    
  case (i0_offset)
  3'd0:
  begin
    info_valid[0]              = al_f1_data_valid[0]; // spill_data is always 32 bit instruction | al_pd0_is_16bit;
    info0_is_16bit             = al_pd0_is_16bit;     
    info0[`IQ_INST_RANGE]      = pd0_data_in; 
    info0[`PMP_VIOL]           = al_pd0_is_16bit ? pmp_viol_r : (pmp_viol0 | pmp_viol_r);
    info0[`PMP_ADDR_RANGE]     = pmp_viol_r ? ifu_pmp_addr_r : ifu_pmp_addr0;
    info0[`PMA_VIOL]           = al_pd0_is_16bit ? pma_viol_r : (pma_viol0 | pma_viol_r);
    info0[`IFU_ECC_ERR]        = al_f1_data_err[0] | spill_ecc_err_r;
    info0[`IFU_BUS_ERR]        = ic_f1_bus_err | spill_bus_err_r;
    spill_set                  = al_f1_data_valid[0] & (~al_pd2_is_16bit);
    use_spill_inst_nxt         = al_f1_data_valid[0] & (al_pd2_is_16bit);
  end
  
  3'd1:
  begin
    info_valid[0]              = al_f1_data_valid[0];         
    info0_is_16bit             = al_pd1_is_16bit;     
    info0[`IQ_INST_RANGE]      = pd1_data_in; 
    info0[`PMP_VIOL]           = pmp_viol0;
    info0[`PMP_ADDR_RANGE]     = ifu_pmp_addr0;
    info0[`PMA_VIOL]           = pma_viol0;
    spill_set                  = al_f1_data_valid[0] & (~al_pd2_is_16bit) & (al_pd1_is_16bit) & (~use_spill_inst);
    use_spill_inst_nxt         = (al_f1_data_valid[0] & al_pd1_is_16bit & al_pd2_is_16bit);
  end
  
  default: // 3'd2
  begin
    //info_valid[0]              = al_f1_data_valid[1] | al_pd2_is_16bit;
    info_valid[0]              = al_f1_data_valid[1] | (al_pd2_is_16bit & al_f1_data_valid[0]);
    info0_is_16bit             = al_pd2_is_16bit;     
    info0[`IQ_INST_RANGE]      = pd2_data_in; 
    info0[`PMP_VIOL]           = pmp_viol0;
    info0[`PMP_ADDR_RANGE]     = ifu_pmp_addr0;
    info0[`PMA_VIOL]           = pma_viol0;
    spill_set                  = al_f1_data_valid[0] & (~al_pd2_is_16bit) & (~al_f1_data_valid[1]);
  end

  endcase
end

// spyglass enable_block W553

assign set                  = spill_set;
assign spill_and_data_valid = spill_valid_r & al_pd0_is_16bit;

always @*
begin : spill_state_PROC
  // Default values
  //
  spill_data_nxt       = al_f1_data0[31:16];
  spill_ecc_err_nxt    = al_f1_data_err[0];
  spill_bus_err_nxt    = al_f1_bus_err;
  spill_valid_nxt      = al_restart ? 1'b0 : set;
  spill_valid_cg0      = (al_restart | ((spill_valid_r | set) & (al_f1_data_valid[0] == 1'b1) & (~x1_holdup) & (~uop_busy)));
  spill_data_cg0       = (set | use_spill_inst_nxt) & (~x1_holdup) & (~uop_busy);
end




//////////////////////////////////////////////////////////////////////////////////////////
// Computation of IQ restart (fetch block PC)
//
///////////////////////////////////////////////////////////////////////////////////////////

// spyglass disable_block W164a
// SMD: Identifies assignments in which the LHS width is less than the RHS width 
// SJ:  Intended as per the design. no loss of data.
wire al_f1_data_is_partial;
assign al_f1_data_is_partial = (al_f1_data_valid == 2'b01);
always @*
begin : iq_partial_PROC
  // Default values
  //
  fch_pc_nxt  = (use_spill_inst | x1_holdup | uop_busy | (al_f1_data_valid != 2'b01)) ? {f1_addr0, f1_offset} : {f1_addr0, 1'b0} + 2; // [31:1]
  fch_same_pc = (use_spill_inst | x1_holdup | uop_busy | (al_f1_data_valid != 2'b01)) ? 1'b1 : 1'b0; 
end
// spyglass enable_block W164a

//////////////////////////////////////////////////////////////////////////////
//
// PMP Fetch check
//
//////////////////////////////////////////////////////////////////////////////

assign mmwp0 = ipmp_perm0[5];
assign mml0  = ipmp_perm0[4];
assign lock0 = ipmp_perm0[3];
assign exu0  = ipmp_perm0[2];

assign res0  = ipmp_perm0[1] & (~ipmp_perm0[0]);


always @*
begin : pmp_fetch0_PROC
   if (~ipmp_hit0)  //No match region
   begin
       if ((priv_level == `PRIV_M) && (~mmwp0) && (~mml0))
           pmp_viol0 = 1'b0;
       else
           pmp_viol0 = 1'b1;
   end
   else             //region hit
   begin
       if (~mml0)   //No MML
       begin
           if ((~res0) && (((~lock0) && (priv_level == `PRIV_M)) || exu0))
               pmp_viol0 = 1'b0;
           else
               pmp_viol0 = 1'b1;
       end
       else         //MML set
       begin
           if (priv_level == `PRIV_M)
  // spyglass disable_block DisallowCaseZ-ML
  // SMD: Do not use casez constructs in the design
  // SJ : Intended as per the design
               casez (ipmp_perm0[3:0]) //LXWR
                   4'b0???: pmp_viol0 = 1'b1;
                   4'b1000: pmp_viol0 = 1'b1;
                   4'b1001: pmp_viol0 = 1'b1;
                   4'b1011: pmp_viol0 = 1'b1;
                   4'b1111: pmp_viol0 = 1'b1;
                   default: pmp_viol0 = 1'b0;
               endcase
  // spyglass enable_block DisallowCaseZ-ML
            else
               case (ipmp_perm0[3:0])
                   4'b0100,
                   4'b0101,
                   4'b0111,
                   4'b1010,
                   4'b1110: pmp_viol0 = 1'b0;
                   default: pmp_viol0 = 1'b1;
               endcase
        end
    end

end



//////////////////////////////////////////////////////////////////////////////
//
// Issuing of instructions
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : al_issue_PROC
  // Instructions are issued from F2 of from the IQ
  //
  /*
   *   @@@ This code is assuming no change of control flow prediction
   */

  al_size      = al_pd_is_16bit ? 3'b010: 3'b100;
  al_pd_addr0  = al_pd_src0;
  al_pd_addr1  = al_pd_src1;
  al_pd_fu     = al_pd_fu_tmp;
  if( use_spill_inst )
  begin
    al_issue    = (~db_active)
                            & (~uop_busy)
                            & (~ifu_restart)
                            ; 
    al_inst     = {16'h0,spill_data_r}; 
    al_pmp_viol = 1'b0;
    pmp_viol_addr = 'h0;
    al_pma_viol = 1'b0;
    al_bus_err  = 1'b0;
    al_ecc_err  = spill_ecc_err_r; 
  end
  else
  begin
    al_issue    = info_valid[0]
                            & (~uop_busy)
                            & (~ifu_restart)
                            & (~db_active);
    al_inst     = info0[`IQ_INST_RANGE]; 
    al_pmp_viol = info0[`PMP_VIOL];
    pmp_viol_addr = info0[`PMP_ADDR_RANGE];
    al_pma_viol = info0[`PMA_VIOL];
    al_bus_err  = info0[`IFU_BUS_ERR];
    al_ecc_err  = info0[`IFU_ECC_ERR];
  end
end

//////////////////////////////////////////////////////////////////////////////
//
// PC computation
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : al_pc_nxt_PROC
  // Compute the next value of the I-stage PC
  //
  al_pc_cg0 = 1'b0;

  al_pc_nxt = al_pc_r;

  // Priority mux
  //
  if (ifu_restart)
  begin
    al_pc_cg0 = 1'b1;
    al_pc_nxt = ifu_target;
  end
  else if (br_req_ifu)
  begin
    al_pc_cg0 = 1'b1;
    al_pc_nxt = br_restart_pc;
  end
  else
  begin
    // Sequential fetch
    //
    al_pc_cg0 = al_issue & (~x1_holdup) & (~uop_busy);
    // spyglass disable_block W164a
    //SMD: Possible arithmetic overflow: LHS width should be greater than RHS width
    //SJ: 32-bit PC, carry ignored
    al_pc_nxt = al_pc_r + al_size[2:1];
    // spyglass enable_block W164a
  end

end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin :al_pc_regs_PROC
  if (rst_a == 1'b1)
  begin
    al_pc_r <= {`PC_SIZE{1'b0}};
  end
  else
  begin
    if (al_pc_cg0 == 1'b1)
    begin
      al_pc_r <= al_pc_nxt;
    end
  end
end

//////////////////////////////////////////////////////////////////////////////////////////
// Synchronous processes
//
///////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : spill_regs_PROC
  if (rst_a == 1'b1)
  begin
    spill_valid_r          <= 1'b0;
    spill_data_r           <= {16{1'b0}};
    use_spill_inst         <= 1'b0;
    spill_bus_err_r        <= 1'b0;
    spill_ecc_err_r        <= 1'b0;
    pmp_viol_r             <= 1'b0;
    ifu_pmp_addr_r         <= `IFU_ADDR_BITS'h0;
    pma_viol_r             <= 1'b0;
  end
  else
  begin
    if (((~x1_holdup) & (~uop_busy)) | al_restart)
    begin
      use_spill_inst          <= (use_spill_inst | al_restart)? 1'b0 : use_spill_inst_nxt;
    end
    if (spill_valid_cg0 == 1'b1)
    begin
      spill_valid_r        <= spill_valid_nxt;
    end
    
    if (spill_data_cg0 == 1'b1)
    begin
      spill_data_r         <= spill_data_nxt;      
      spill_ecc_err_r      <= spill_ecc_err_nxt;
      spill_bus_err_r      <= spill_bus_err_nxt;
      pmp_viol_r           <= pmp_viol0;
      ifu_pmp_addr_r       <= ifu_pmp_addr0;
      pma_viol_r           <= pma_viol0;
    end
  end
end



//////////////////////////////////////////////////////////////////////////////////////////
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////

assign al_pc     = al_pc_r;
assign al_fusion = 2'b00; // @@@
assign iq_full   = 1'b0;


endmodule // rl_ifu_align
