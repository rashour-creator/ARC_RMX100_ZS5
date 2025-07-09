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



module rl_dmp_dccm (
  ////////// DMP interface /////////////////////////////////////////////
  //
  input [1:0]                    x2_req,                  // only read
  input [`DCCM_ADR_RANGE]        x2_addr_even,
  input [`DCCM_ADR_RANGE]        x2_addr_odd,
  output [1:0]                   x2_ack,
  input [`ADDR_RANGE]            dmp_x2_addr_r,
  input                          dmp_x2_valid_r,
  input [`ADDR_RANGE]            dmp_x2_addr1_r,
  input                          dmp_x2_bank_cross_r,
  input [1:0]                    x1_req,                  // only read
  input [`DCCM_ADR_RANGE]        x1_addr_even,
  input [`DCCM_ADR_RANGE]        x1_addr_odd,
  output [1:0]                   x1_ack,

  input [1:0]                    cwb_req,                 // only write
  input                          cwb_prio,                // used to raise cwb priority
  input [3:0]                    cwb_mask,
  input [`DATA_RANGE]            cwb_data_even,  
  input [`DCCM_ADR_RANGE]        cwb_addr_even,
  input [`DATA_RANGE]            cwb_data_odd,    
  input [`DCCM_ADR_RANGE]        cwb_addr_odd,
  output [1:0]                   cwb_ack,


  //////////// Interface with DMP //////////////////////////////////////////
  //
  input [1:0]                      dccm_ecc_enable,         // from DCCM CTL CSR
  input                            csr_dccm_rwecc,
  output                           dccm_ecc_sb_error_even,
  output                           dccm_ecc_db_error_even,  
  output                           dccm_ecc_db_err_even_cnt,
  output [`DCCM_ADR_RANGE]         dccm_ecc_address_even,
  output [`DCCM_ECC_MSB-1:0]       dccm_ecc_syndrome_even,
  output                           dccm_ecc_addr_err_even_cnt,
  output                           x2_dmi_sb_error_even,
  output                           dccm_ecc_addr_error_even,

  output                           dccm_ecc_sb_error_odd,
  output                           dccm_ecc_db_error_odd,
  output                           dccm_ecc_db_err_odd_cnt,  
  output [`DCCM_ADR_RANGE]         dccm_ecc_address_odd,  
  output [`DCCM_ECC_MSB-1:0]       dccm_ecc_syndrome_odd,
  output                           dccm_ecc_addr_err_odd_cnt,
  output                           x2_dmi_sb_error_odd,
  output                           dccm_ecc_addr_error_odd,

  output [`DCCM_ECC_RANGE]         dccm_ecc_even_out,
  output [`DCCM_DATA_RANGE]        dccm_dout_even_correct,
  output [`DCCM_ECC_RANGE]         dccm_ecc_odd_out,
  output [`DCCM_DATA_RANGE]        dccm_dout_odd_correct,
  input [7:0]                      arcv_mecc_diag_ecc,

  output [1:0]                     dmi_arb_freeze,

  ////////// Interface to the DMI interface /////////////////////////////////
  //
  input  [`ADDR_RANGE]             x3_lpa_r,
  input  [1:0]                     x3_lock_flag_r,
  input  [3:0]                     x3_lock_dmi_id_r,
  input  [`DMP_TTL_RANGE]          x3_lock_counter_r,
  input [31:2]                     x2_dmi_addr_r,
  input [3:0]                      x2_dmi_id_r,  
  output reg                       dmi_scrub_r,
  input  [1:0]                     dmi_hp_req,
  input  [1:0]                     dmi_req,
  input                            dmi_read,
  input                            dmi_excl,
  input  [3:0]                     dmi_id,
  input  [31:2]                    dmi_addr,
  output reg [1:0]                 dmi_ack,

  output reg                       dmi_set_lf,
  output reg                       dmi_clear_lf,
  input                           dmi_rmw,
  input  [31:0]                   dmi_wr_data,
  input  [3:0]                    dmi_wr_mask,
  output reg                      dmi_wr_done,

  output reg [31:0]               dmi_rd_data,
  output reg                      dmi_rd_valid,
  output                          pipe_lost_to_dmi,
  output reg                      dmi_rd_err,
  output reg                      dmi_sb_err,

  input                           dmi_scrub_allowed,
  output reg                      dmi_scrub_reset,  

  input                           core_arb_odd_freeze,
  input                           core_arb_even_freeze,

  ////////// SRAM interface ////////////////////////////////////////////////
  //
  output                         clk_dccm_even,
  output reg [`DCCM_DRAM_RANGE]  dccm_din_even,
  output reg [`DCCM_ADR_RANGE]   dccm_addr_even,
  output reg                     dccm_cs_even,
  output reg                     dccm_we_even,
  output reg [`DCCM_MASK_RANGE]  dccm_wem_even,
  input [`DCCM_DRAM_RANGE]       dccm_dout_even,
  output                         clk_dccm_odd,
  output reg [`DCCM_DRAM_RANGE]  dccm_din_odd,
  output reg [`DCCM_ADR_RANGE]   dccm_addr_odd,
  output reg                     dccm_cs_odd,
  output reg                     dccm_we_odd,
  output reg [`DCCM_MASK_RANGE]  dccm_wem_odd,
  input [`DCCM_DRAM_RANGE]       dccm_dout_odd,


  ////////// General input signals /////////////////////////////////////////////
  //
  input                          rst_a,                  // reset signal
  input                          clk                    // clock signal

);

// Local declarations
//
reg        x2_ack_even;
reg        x1_ack_even;
reg        cwb_ack_even;

reg        x2_ack_odd;
reg        x1_ack_odd;
reg        cwb_ack_odd;

reg        dccm_even_cg0;
reg        dccm_odd_cg0;

reg [`DATA_RANGE]   dccm_din_even_prel;
reg [`DATA_RANGE]   dccm_din_odd_prel;
reg [3:0]           dccm_wem_even_prel;
reg [3:0]           dccm_wem_odd_prel;

reg        ibp_ack_even;
reg        ibp_ack_odd;

reg        dmi_ack_even_r;
reg        dmi_ack_even_nxt;

wire       dmi_freeze_even_cg0;
wire       dmi_freeze_odd_cg0;
reg        dmi_arb_even_freeze_r;
reg        dmi_arb_odd_freeze_r;

reg        dmi_scrub_set;
wire [1:0] cwb_hp_req;

wire [`DCCM_ECC_RANGE]    dccm_even_din_ecc;
wire [`DCCM_ECC_RANGE]    dccm_even_din_ecc_prel;
wire [`DCCM_ECC_RANGE]    dccm_odd_din_ecc;
wire [`DCCM_ECC_RANGE]    dccm_odd_din_ecc_prel;

wire [`DCCM_ECC_MSB-1:0]  dccm_even_syndrome;
wire [`DCCM_ECC_MSB-1:0]  dccm_odd_syndrome;

reg                       dmp_dccm_ack_even_nxt;
reg                       dmp_dccm_ack_odd_nxt;
reg                       dmp_dccm_ack_even_r;
reg                       dmp_dccm_ack_odd_r;

wire                      dmp_ecc_valid_even;
wire                      dmp_ecc_valid_odd;

wire                      db_error_even;
wire                      db_error_odd;
wire                      addr_error_even;
wire                      addr_error_odd;
wire                      x2_dmi_db_error_even;
wire                      x2_dmi_db_error_odd;
wire                      x2_dmi_addr_error_even;
wire                      x2_dmi_addr_error_odd;
wire                      x2_dmi_sb_error;
wire                      x2_dmi_db_error;


wire    ecc_sb_err_even;
wire    ecc_db_err_even;
wire    ecc_addr_err_even;
wire    ecc_sb_err_odd;
wire    ecc_db_err_odd;
wire    ecc_addr_err_odd;
wire        dmi_ack_cg0;
wire        dmi_arb_even_freeze;
wire        dmi_arb_odd_freeze;
reg                           x1_dmi_valid;
reg                           x2_dmi_cg0;
reg                           x2_dmi_valid_nxt;
reg                           x2_dmi_wr_nxt;
reg                           x2_dmi_valid_r;
reg                           x2_dmi_wr_r;
reg                           x2_dmi_excl_nxt;
reg                           x2_dmi_excl_r;

reg [`DCCM_ADR_RANGE]         dccm_ecc_addr_even;
reg [`DCCM_ADR_RANGE]         dccm_ecc_addr_odd;

// Helpers
//
assign dmi_ack_cg0          = (|dmi_ack);
assign dmi_arb_even_freeze  = dmi_arb_even_freeze_r
                            | (dmi_ack_even_r & dmi_scrub_r)
                            ;
assign dmi_arb_odd_freeze   = dmi_arb_odd_freeze_r
                            | (~dmi_ack_even_r & dmi_scrub_r)
                            ;
assign cwb_hp_req = {2{cwb_prio}} & cwb_req;

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Arbiter
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : arb_even_PROC
  // Default values
  //
  x2_ack_even  = 1'b0;
  x1_ack_even  = 1'b0;
  cwb_ack_even = 1'b0;
  ibp_ack_even = 1'b0;

  if (   (dmi_hp_req[0] || dmi_arb_even_freeze)
      && !core_arb_even_freeze
     )
    ibp_ack_even = dmi_req[0];
  else
  if (cwb_hp_req[0])
    cwb_ack_even = 1'b1;
  else if (x2_req[0])
    x2_ack_even  = 1'b1;
  else if (x1_req[0])
    x1_ack_even  = 1'b1;
  else if (cwb_req[0])
    cwb_ack_even = 1'b1;
  else
    ibp_ack_even = dmi_req[0]
                && !core_arb_even_freeze
                   ;
end

always @*
begin : arb_odd_PROC
  // Default values
  //
  x2_ack_odd  = 1'b0;
  x1_ack_odd  = 1'b0;
  cwb_ack_odd = 1'b0;
  ibp_ack_odd = 1'b0;

  if (   (dmi_hp_req[1] || dmi_arb_odd_freeze)
      && !core_arb_odd_freeze
      )
    ibp_ack_odd = dmi_req[1];
  else
  if (cwb_hp_req[1])
    cwb_ack_odd = 1'b1;
  else if (x2_req[1])
    x2_ack_odd  = 1'b1;
  else if (x1_req[1])
    x1_ack_odd  = 1'b1;
  else if (cwb_req[1])
    cwb_ack_odd = 1'b1;
  else
    ibp_ack_odd = dmi_req[1]
                && !core_arb_odd_freeze
                   ;

end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  SRAM drivers
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dccm_even_PROC
  // Default values
  //
  dccm_even_cg0      = 1'b0;
  
  dccm_cs_even       = 1'b0;
  dccm_we_even       = 1'b0;
  dccm_wem_even_prel = cwb_mask;
  dccm_addr_even     = cwb_addr_even;
  
  case (1'b1)
  ibp_ack_even:
  begin
    dccm_even_cg0       = 1'b1;
    dccm_cs_even        = 1'b1;
    dccm_addr_even      = dmi_addr[`DCCM_ADR_RANGE];
    dccm_we_even        = (~dmi_read);
    dccm_wem_even_prel  = dmi_wr_mask; 
  end

  x2_ack_even:
  begin
    dccm_even_cg0  = 1'b1;
    dccm_cs_even   = 1'b1;
    dccm_addr_even = x2_addr_even;
  end

  x1_ack_even:
  begin
    dccm_even_cg0  = 1'b1;
    dccm_cs_even   = 1'b1;
    dccm_addr_even = x1_addr_even;
  end

  cwb_ack_even:
  begin
    dccm_even_cg0       = 1'b1;
    dccm_cs_even        = 1'b1;
    dccm_addr_even      = cwb_addr_even;
    dccm_we_even        = 1'b1;
    dccm_wem_even_prel  = cwb_mask;
  end
// spyglass disable_block W193
// SMD: empty statement
// SJ:  default values are covered but empty default kept
  default:;
  endcase
// spyglass enable_block W193
end

always @*
begin : dccm_odd_PROC
  // Default values
  //
  dccm_odd_cg0        = 1'b0;
  
  dccm_cs_odd         = 1'b0;
  dccm_we_odd         = 1'b0;
  dccm_wem_odd_prel   = cwb_mask;
  dccm_addr_odd       = cwb_addr_odd;
  
  case (1'b1)
  ibp_ack_odd:
  begin
    dccm_odd_cg0       = 1'b1;
    dccm_cs_odd        = 1'b1;
    dccm_addr_odd      = dmi_addr[`DCCM_ADR_RANGE];
    dccm_we_odd        = (~dmi_read);
    dccm_wem_odd_prel  = dmi_wr_mask; 
  end

  x2_ack_odd:
  begin
    dccm_odd_cg0  = 1'b1;
    dccm_cs_odd   = 1'b1;
    dccm_addr_odd = x2_addr_odd;
  end

  x1_ack_odd:
  begin
    dccm_odd_cg0  = 1'b1;
    dccm_cs_odd   = 1'b1;
    dccm_addr_odd = x1_addr_odd;
  end

  cwb_ack_odd:
  begin
    dccm_odd_cg0       = 1'b1;
    dccm_cs_odd        = 1'b1;
    dccm_addr_odd      = cwb_addr_odd;
    dccm_we_odd        = 1'b1;
    dccm_wem_odd_prel  = cwb_mask;
  end 
// spyglass disable_block W193
// SMD: empty statement
// SJ:  default values are covered but empty default kept
  default:;
  endcase
// spyglass enable_block W193
end

always @*
begin: dccm_even_driver_PROC
  dccm_din_even_prel = cwb_data_even;
  dccm_ecc_addr_even = cwb_addr_even;
  if (   (dmi_hp_req[0] || dmi_arb_even_freeze) && dmi_req[0]
      && !core_arb_even_freeze
     )
  begin
    dccm_din_even_prel = dmi_wr_data;
    dccm_ecc_addr_even = dmi_addr[`DCCM_ADR_RANGE];
  end
  else if (cwb_req[0])
  begin
      dccm_din_even_prel = cwb_data_even;
      dccm_ecc_addr_even = cwb_addr_even;
  end
  else if (dmi_req[0])
  begin
      dccm_din_even_prel = dmi_wr_data;
      dccm_ecc_addr_even = dmi_addr[`DCCM_ADR_RANGE];
  end
end

  always @*
  begin: dccm_odd_driver_PROC
    dccm_din_odd_prel = cwb_data_odd;
    dccm_ecc_addr_odd = cwb_addr_odd;
    if (   (dmi_hp_req[1] || dmi_arb_odd_freeze) && dmi_req[1]
        && !core_arb_odd_freeze
       )
    begin
      dccm_din_odd_prel = dmi_wr_data;
      dccm_ecc_addr_odd = dmi_addr[`DCCM_ADR_RANGE];
    end
    else if (cwb_req[1])
    begin
        dccm_din_odd_prel = cwb_data_odd;
        dccm_ecc_addr_odd = cwb_addr_odd;
    end
    else if (dmi_req[1])
    begin
        dccm_din_odd_prel = dmi_wr_data;
        dccm_ecc_addr_odd = dmi_addr[`DCCM_ADR_RANGE];
    end
  end

always @*
begin : DCCM_even_din_wem_PROC
  dccm_din_even = {dccm_even_din_ecc,dccm_din_even_prel};
  dccm_wem_even = {|dccm_wem_even_prel,dccm_wem_even_prel};
end

always @*
begin : DCCM_odd_din_wem_PROC
  dccm_din_odd = {dccm_odd_din_ecc,dccm_din_odd_prel};
  dccm_wem_odd = {|dccm_wem_odd_prel,dccm_wem_odd_prel};
end

// ECC encoder instance for DCCM even RAM
rl_dmp_dccm_ecc_encoder u_rl_dmp_dccm_ecc_encoder_even (
  .data_in        (dccm_din_even_prel     ),
  .address        (dccm_ecc_addr_even     ),
  .ecc            (dccm_even_din_ecc_prel )
);

// ECC encoder instance for DCCM odd RAM
rl_dmp_dccm_ecc_encoder u_rl_dmp_dccm_ecc_encoder_odd (
  .data_in        (dccm_din_odd_prel    ),
  .address        (dccm_ecc_addr_odd    ),
  .ecc            (dccm_odd_din_ecc_prel)
);

assign dccm_even_din_ecc = (  csr_dccm_rwecc
                           ) ? arcv_mecc_diag_ecc[`DCCM_ECC_RANGE] : dccm_even_din_ecc_prel;
assign dccm_odd_din_ecc  = (  csr_dccm_rwecc
                           ) ? arcv_mecc_diag_ecc[`DCCM_ECC_RANGE] : dccm_odd_din_ecc_prel;


wire [`DCCM_ADR_RANGE]    addr_even;
wire [`DCCM_ADR_RANGE]    addr_odd;
assign    addr_even = (x2_dmi_valid_r & dmi_ack_even_r)
                    ? (x2_dmi_addr_r[`DCCM_ADR_RANGE])
                    : ( (dmp_x2_bank_cross_r) 
                       ? dmp_x2_addr1_r[`DCCM_ADR_RANGE] : dmp_x2_addr_r[`DCCM_ADR_RANGE]);
assign    addr_odd  = (x2_dmi_valid_r & ~dmi_ack_even_r) 
                    ? x2_dmi_addr_r[`DCCM_ADR_RANGE] : dmp_x2_addr_r[`DCCM_ADR_RANGE];

assign dmp_ecc_valid_even = dmp_x2_valid_r & dmp_dccm_ack_even_r;

assign dmp_ecc_valid_odd = dmp_x2_valid_r & dmp_dccm_ack_odd_r;

// ECC decoder instance for DCCM even RAM
rl_dmp_dccm_ecc_decoder u_rl_dmp_dccm_ecc_decoder_even (
   .enable              (|dccm_ecc_enable                    ),  
   .data_in             (dccm_dout_even[`DCCM_DATA_RANGE]    ),
   .address             (addr_even                           ),
   .addr_err            (ecc_addr_err_even                   ),
   .syndrome            (dccm_even_syndrome                  ),
   .ecc_in              (dccm_dout_even[`DCCM_DATA_ECC_RANGE]),
   .data_out            (dccm_dout_even_correct              ),
   .ecc_out             (dccm_ecc_even_out                   ),
   .single_err          (ecc_sb_err_even                     ),
   .double_err          (ecc_db_err_even                     )
);

// ECC decoder instance for DCCM odd RAM
rl_dmp_dccm_ecc_decoder u_rl_dmp_dccm_ecc_decoder_odd (
   .enable              (|dccm_ecc_enable                    ), 
   .data_in             (dccm_dout_odd[`DCCM_DATA_RANGE]     ),
   .address             (addr_odd                            ),
   .addr_err            (ecc_addr_err_odd                    ),
   .syndrome            (dccm_odd_syndrome                   ),
   .ecc_in              (dccm_dout_odd[`DCCM_DATA_ECC_RANGE] ),
   .data_out            (dccm_dout_odd_correct               ),
   .ecc_out             (dccm_ecc_odd_out                    ),
   .single_err          (ecc_sb_err_odd                      ),
   .double_err          (ecc_db_err_odd                      )
);

assign dccm_ecc_sb_error_even = dmp_ecc_valid_even & ecc_sb_err_even; 

assign db_error_even          = ecc_db_err_even; 
assign addr_error_even        = ecc_addr_err_even;
assign dccm_ecc_db_error_even = (dmp_ecc_valid_even & db_error_even); 
assign dccm_ecc_addr_error_even = (dmp_ecc_valid_even & addr_error_even);

assign dccm_ecc_sb_error_odd  = dmp_ecc_valid_odd & ecc_sb_err_odd;

assign db_error_odd           = ecc_db_err_odd; 
assign addr_error_odd         = ecc_addr_err_odd;

assign dccm_ecc_db_error_odd  = (dmp_ecc_valid_odd  & db_error_odd);
assign dccm_ecc_addr_error_odd  = (dmp_ecc_valid_odd  & addr_error_odd);

assign x2_dmi_sb_error_even = x2_dmi_valid_r                                   
                            & (dmi_ack_even_r & ecc_sb_err_even);

assign x2_dmi_db_error_even = x2_dmi_valid_r & dmi_ack_even_r & db_error_even;

assign x2_dmi_addr_error_even = x2_dmi_valid_r & dmi_ack_even_r & addr_error_even;


assign x2_dmi_sb_error_odd  = x2_dmi_valid_r
                            & (~dmi_ack_even_r & ecc_sb_err_odd);

assign x2_dmi_db_error_odd  = x2_dmi_valid_r & (~dmi_ack_even_r) & db_error_odd;

assign x2_dmi_addr_error_odd  = x2_dmi_valid_r & (~dmi_ack_even_r) & addr_error_odd;


assign x2_dmi_db_error = (  x2_dmi_valid_r & dmi_ack_even_r & (ecc_sb_err_even & dccm_ecc_enable == 2'b10) 
                          | x2_dmi_db_error_even
                          | x2_dmi_addr_error_even
                         )
                       | (  x2_dmi_valid_r & ~dmi_ack_even_r & (ecc_sb_err_odd & dccm_ecc_enable == 2'b10)
                          | x2_dmi_db_error_odd
                          | x2_dmi_addr_error_odd
                         )
                         ;                          

assign x2_dmi_sb_error =  (~x2_dmi_wr_r) & (  x2_dmi_sb_error_even 
                                            | x2_dmi_sb_error_odd
                                           );

always @*
begin : dccm_ack_nxt_PROC
  dmp_dccm_ack_even_nxt = x1_ack_even | x2_ack_even;
  dmp_dccm_ack_odd_nxt  = x1_ack_odd  | x2_ack_odd;
end

//////////////////////////////////////////////////////////////////////////////
//
// Module instantiation -- clkgates for the DCCM memories
//
//////////////////////////////////////////////////////////////////////////////
//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived. clock gate will be replaced with cg cell that will have scan points 
clkgate u_clkgate_dccm_even (
  .clk_in            (clk),
  .clock_enable_r    (dccm_even_cg0),
  .clk_out           (clk_dccm_even)

);

clkgate u_clkgate_dccm_odd (
  .clk_in            (clk),
  .clock_enable_r    (dccm_odd_cg0),
  .clk_out           (clk_dccm_odd)

);
//spyglass enable_block TA_09                                 

always @*
begin : dccm_dmi_PROC
  dmi_ack               = {ibp_ack_odd, ibp_ack_even};
  dmi_ack_even_nxt      = ibp_ack_even;
end

//////////////////////////////////////////////////////////////////////////////
//
// DMI
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmi_cg0_PROC
  // X1 DMI valid is simply the request from the IBP wrapper
  //
  x1_dmi_valid     = (|dmi_req);

  // Next values
  //
  x2_dmi_cg0       = x1_dmi_valid | x2_dmi_valid_r;
  x2_dmi_valid_nxt = x1_dmi_valid & (|dmi_ack);
  x2_dmi_wr_nxt    = (~dmi_read);
  x2_dmi_excl_nxt  = dmi_excl;
end

always @*
begin : dmi_excl_PROC
  // An exlusive DMI read always requests to set the reservation in X2 only if there is no
  // DB error in case of an ECC config. 
  dmi_set_lf          = x2_dmi_valid_r & (~x2_dmi_wr_r) & x2_dmi_excl_r
                      & (  (x3_lock_flag_r == 2'b00)                               // No valid reservation
                         | (x3_lock_flag_r[1] & (x3_lock_dmi_id_r == x2_dmi_id_r))   // Valid DMI reservation from the same initiator
                         | (x3_lock_counter_r == `DMP_TTL_WIDTH'd0)                // Valid reservation from core or other DMI initiator but timed out
                        ) 
                      & (~x2_dmi_db_error)
                      ;

  // 1. A DMI exclusive write requests to reset the reservation in X1 on receiving an ack only if the excl 
  //    write is from the same initiator that had a valid reservation or
  // 2. A DMI write requests to reset the reservation if there is a match with the LPA and the lock flag is
  //    set.
  dmi_clear_lf        = ((|dmi_ack) & (~dmi_read))
                      & (  (  (dmi_excl & x3_lock_flag_r[1] & (x3_lock_dmi_id_r == dmi_id))    // (1) 
                            | (~dmi_excl & (x3_lpa_r[31:3] == dmi_addr[31:3]) & (|x3_lock_flag_r)))  // (2)
                         & (~dmi_scrub_r) // A scrubbing write doesn't clear reservation
                        );
end

//////////////////////////////////////////////////////////////////////////////
//
// Asynchronous process to provide DMI data to the IBP wrapper
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmi_rdwr_data_PROC
  // DMI read data
  //
  // 1. No read response for DMI and core arb freeze cross
  // 2. No read response for a DMI SB err except: 
  //    DMI scrubbing is allowed or 
  //    DMI scrub is in-progress or  
  //    SB err on partial write 
  dmi_rd_valid  =  x2_dmi_valid_r & (~x2_dmi_wr_r)
                & ~(dmi_arb_even_freeze_r & core_arb_even_freeze)        // (1)
                & ~(dmi_arb_odd_freeze_r  & core_arb_odd_freeze )        // 
                & ( (~x2_dmi_sb_error | dmi_scrub_allowed | dmi_scrub_r) // (2)
                  | (dmi_arb_even_freeze_r | dmi_arb_odd_freeze_r))      // 
                ;

  dmi_rd_err    =  dmi_rd_valid 
                &  x2_dmi_db_error;
  dmi_sb_err    = x2_dmi_sb_error;

  dmi_rd_data  =  (|dccm_ecc_enable) ? (dmi_ack_even_r ? dccm_dout_even_correct[`DCCM_DATA_RANGE] : dccm_dout_odd_correct[`DCCM_DATA_RANGE]) 
                                     : (dmi_ack_even_r ? dccm_dout_even[`DCCM_DATA_RANGE] : dccm_dout_odd[`DCCM_DATA_RANGE]);

  // DMI write completion
  //
  dmi_wr_done  = x2_dmi_valid_r & x2_dmi_wr_r
               & (~dmi_scrub_r)   // No write_done for scrubbing write
               ;
end

assign  dmi_freeze_even_cg0 = ibp_ack_even;
assign  dmi_freeze_odd_cg0  = ibp_ack_odd;

always @*
begin : dmi_scrub_cg0_PROC
  // Set dmi_scrub for SB errs detected only on DMI reads
  dmi_scrub_set   = x2_dmi_sb_error & ~(dmi_arb_even_freeze_r | dmi_arb_odd_freeze_r);
  // Reset dmi_scrub after scrubbing write is completed
  dmi_scrub_reset = dmi_scrub_r
                  & (x2_dmi_valid_r & ~x2_dmi_sb_error);
end


///////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : dccm_dmi_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmi_ack_even_r     <= 1'b0;
  end
  else
  begin
    if (dmi_ack_cg0 == 1'b1)
    begin
      dmi_ack_even_r     <= dmi_ack_even_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmi_ids_regs_PROC
  if (rst_a == 1'b1)
  begin
    x2_dmi_valid_r  <= 1'b0;
    x2_dmi_wr_r     <= 1'b0;
    x2_dmi_excl_r   <= 1'b0;
  end
  else
  begin
    if (x2_dmi_cg0)
    begin
      x2_dmi_valid_r  <= x2_dmi_valid_nxt;
      x2_dmi_wr_r     <= x2_dmi_wr_nxt;
      x2_dmi_excl_r   <= x2_dmi_excl_nxt;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmi_freeze_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmi_arb_even_freeze_r <= 1'b0;
    dmi_arb_odd_freeze_r  <= 1'b0;
  end
  else
  begin
    if (dmi_freeze_even_cg0 == 1'b1)
    begin
      dmi_arb_even_freeze_r <= dmi_rmw;
    end
    if (dmi_freeze_odd_cg0 == 1'b1)
    begin
      dmi_arb_odd_freeze_r  <= dmi_rmw;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : dmi_scrub_reg_PROC
  if (rst_a == 1'b1)
  begin
    dmi_scrub_r <= 1'b0;
  end
  else
  begin
    if (dmi_scrub_set == 1'b1)
    begin
      dmi_scrub_r <= 1'b1;
    end
    else if (dmi_scrub_reset == 1'b1)
    begin
      dmi_scrub_r <= 1'b0;
    end
  end
end

always @(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    dmp_dccm_ack_even_r <= 1'b0;
    dmp_dccm_ack_odd_r  <= 1'b0; 
  end
  else
  begin
    dmp_dccm_ack_even_r <= dmp_dccm_ack_even_nxt;
    dmp_dccm_ack_odd_r  <= dmp_dccm_ack_odd_nxt;
  end
end
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Output assignments
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

assign x2_ack  = {x2_ack_odd,  x2_ack_even};
assign x1_ack  = {x1_ack_odd,  x1_ack_even};
assign cwb_ack = {cwb_ack_odd, cwb_ack_even};

assign dmi_arb_freeze   = {dmi_arb_odd_freeze, dmi_arb_even_freeze};
assign pipe_lost_to_dmi = |(dmi_hp_req & (x2_req | x1_req | cwb_req)); 

// RAS outputs
assign dccm_ecc_db_err_even_cnt     = dccm_ecc_db_error_even 
                                    | (x2_dmi_db_error_even & ~x2_dmi_wr_r)
                                    ;

assign dccm_ecc_addr_err_even_cnt   = dccm_ecc_addr_error_even
                                    | (x2_dmi_addr_error_even & ~x2_dmi_wr_r)
                                    ;

assign dccm_ecc_syndrome_even       = dccm_even_syndrome;
assign dccm_ecc_address_even        = addr_even;


assign dccm_ecc_db_err_odd_cnt      = dccm_ecc_db_error_odd
                                    | (x2_dmi_db_error_odd & ~x2_dmi_wr_r)
                                    ;
assign dccm_ecc_addr_err_odd_cnt    = dccm_ecc_addr_error_odd
                                    | (x2_dmi_addr_error_odd & ~x2_dmi_wr_r)
                                    ;                                    

assign dccm_ecc_syndrome_odd        = dccm_odd_syndrome;
assign dccm_ecc_address_odd         = addr_odd;



endmodule // rl_dmp_dccm

