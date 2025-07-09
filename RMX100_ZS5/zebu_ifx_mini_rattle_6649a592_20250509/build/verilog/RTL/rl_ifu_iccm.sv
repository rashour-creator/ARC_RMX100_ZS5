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
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_ifu_iccm (
  ////////// Interface with the Fetch Target Buffer (F0) ////////////////////////
  //
  input                             fa0_req,                  // Fetch request from FTB
  input [`IFU_ADDR_RANGE]           fa0_addr,                 // Fetch block addr (4 byte aligned)

  input                             db_active,

  output                            iccm0_fa0_ready,          // ICCM0 can consume fa0 request

  ////////// F1 stage interface //////////////////////////////////////////////////
  //
  
  output reg [1:0]                  iccm0_f1_id_out_valid_r,  // Inform ID ctrl (data valid)
  
  output     [`ICCM_DATA_RANGE]     iccm0_f1_data0,           // 32-bit data for addr0
  output     [1:0]                  iccm0_f1_data_err,        // ICCM0 error for {addr1, addr0}

  ////////// ICCM status //////////////////////////////////////////////////////
  //
  output                            iccm_idle,                // ICCM is idle
  ////////// ICCM ECC exception ///////////////////////////////////////////////////////////
  input  [7:0]                      arcv_mecc_diag_ecc,
  output                            iccm_ecc_excpn,
  output                            iccm_dmp_ecc_err,
  output                            iccm_ecc_wr,
  output    [`ICCM0_ECC_RANGE]      iccm0_ecc_out,

  //////////// CSR interface ///////////////////////////////////////////////
  //
  input  [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input  [7:0]                     csr_sel_addr,          // (X1) CSR address
  input  [1:0]                     priv_level,
  
  output [`DATA_RANGE]             csr_rdata,             // (X1) CSR read data
  output                           csr_illegal,           // (X1) illegal
  output                           csr_unimpl,            // (X1) Invalid CSR
  output                           csr_serial_sr,         // (X1) SR group flush pipe
  output                           csr_strict_sr,         // (X1) SR flush pipe
  
  input                            csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input  [7:0]                     csr_waddr,             // (X2) CSR addr
  input  [`DATA_RANGE]             csr_wdata,             // (X2) Write data

  //////////// Interface with DMP ////////////////////////////////////////// 
  //
  output [11:0]                    csr_iccm0_base,
  output                           csr_iccm0_disable,
  
  ////////// DMP IBP interface //////////////////////////////////////////////
  //
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                             lsq_iccm_cmd_valid, 
  input  [3:0]                      lsq_iccm_cmd_cache, 
  input                             lsq_iccm_cmd_burst_size,           
  input                             lsq_iccm_cmd_read,                
  input                             lsq_iccm_cmd_aux,                
  input                             lsq_iccm_cmd_excl,
  input  [5:0]                      lsq_iccm_cmd_atomic,
  input  [2:0]                      lsq_iccm_cmd_data_size,            
  input  [1:0]                      lsq_iccm_cmd_prot,                
  // spyglass enable_block W240
  output reg                        lsq_iccm_cmd_accept,              
  input  [`ADDR_RANGE]              lsq_iccm_cmd_addr,                  

  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                             lsq_iccm_wr_valid,    
  input                             lsq_iccm_wr_last,    
  output                            lsq_iccm_wr_accept,   
  // spyglass enable_block W240
  input  [3:0]                      lsq_iccm_wr_mask,    
  input  [31:0]                     lsq_iccm_wr_data,    
  
  output reg                        lsq_iccm_rd_valid,                
  output                            lsq_iccm_rd_err,                
  output                            lsq_iccm_rd_excl_ok,
  output                            lsq_iccm_rd_last,                 
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                             lsq_iccm_rd_accept,               
  // spyglass enable_block W240
  output reg [31:0]                 lsq_iccm_rd_data,     
  
  output                            lsq_iccm_wr_done,
  output                            lsq_iccm_wr_excl_okay,
  output                            lsq_iccm_wr_err,
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                             lsq_iccm_wr_resp_accept,
  // spyglass enable_block W240

  ////////// DMI IBP interface //////////////////////////////////////////////
  //
  input                                 dmi_iccm_cmd_valid,
  input                                 dmi_iccm_cmd_prio,
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input  [3:0]                          dmi_iccm_cmd_cache,
  input                                 dmi_iccm_cmd_burst_size,
  input                                 dmi_iccm_cmd_excl,
  input  [3:0]                          dmi_iccm_cmd_id,
  input  [2:0]                          dmi_iccm_cmd_data_size,
  input  [1:0]                          dmi_iccm_cmd_prot,
  // spyglass enable_block W240
  input                                 dmi_iccm_cmd_read,
  input  [`ADDR_RANGE]                  dmi_iccm_cmd_addr,
  output reg                            dmi_iccm_cmd_accept,

  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                                 dmi_iccm_wr_valid,
  input                                 dmi_iccm_wr_last,
  // spyglass enable_block W240
  input  [`ICCM_DMI_DATA_WIDTH/8-1:0]   dmi_iccm_wr_mask,
  input  [`ICCM_DMI_DATA_RANGE]         dmi_iccm_wr_data,
  output reg                            dmi_iccm_wr_accept,

  output reg                            dmi_iccm_rd_valid,
  output                                dmi_iccm_rd_err,
  output                                dmi_iccm_rd_excl_ok,
  output reg [`ICCM_DMI_DATA_RANGE]     dmi_iccm_rd_data,
  output                                dmi_iccm_rd_last,
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                                 dmi_iccm_rd_accept,
  // spyglass enable_block W240

  output                                dmi_iccm_wr_done,
  output                                dmi_iccm_wr_excl_okay,
  output                                dmi_iccm_wr_err,
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                                 dmi_iccm_wr_resp_accept,
  // spyglass enable_block W240


  ////////// SRAM  interface ////////////////////////////////////////////
  //
  output                            clk_iccm0,
  output     [`ICCM0_DRAM_RANGE]    iccm0_din,  
  output reg [`ICCM0_ADR_RANGE]     iccm0_addr, 
  output reg                        iccm0_cs,
  output reg                        iccm0_we,
  output     [`ICCM_MASK_RANGE]     iccm0_wem,
  input  [`ICCM0_DRAM_RANGE]        iccm0_dout,

  output                            iccm0_ecc_addr_err,
  output                            iccm0_ecc_sb_err,
  output                            iccm0_ecc_db_err,
  output [`ICCM0_ECC_MSB-1:0]       iccm0_ecc_syndrome,
  output [`ICCM0_ADR_RANGE]         iccm0_ecc_addr,

  input                             trap_clear_iccm_resv,
  
  ////////// General input signals /////////////////////////////////////////////
  //
  input                             clk,                       // clock signal
  input                             rst_a                      // reset signal
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

// Local Declarations
//
reg  [`ICCM0_DATA_RANGE]      iccm0_din_q  ;
reg  [`ICCM_DATA_MASK_RANGE]  iccm0_wem_q  ;
reg                           iccm0_ecc_wem;
wire [`miccm_ECCEN]           csr_iccm0_eccen   ;
wire                          csr_iccm0_rwecc   ;
wire                          extend_dmi_resp;

wire                        core_failed_attempt;
wire                        dmi_failed_attempt;
reg                         iccm0_arb_prio_is_dmi_nxt; 
wire                        iccm0_arb_prio_is_core_r; 
reg                         iccm0_arb_prio_is_dmi_r; 
reg [4:0]                   arb_prio_counter;
reg                         arb_prio_counter_incr;
reg                         reset_arb_prio_counter;
reg                         chk_arb_prio_req;
reg                         dmi_f1_wr_err_r;
reg                         dmi_f1_wr_err_nxt;

reg [`ICCM0_ADR_RANGE]      iccm0_f1_data_addr_r;

reg                         iccm0_f1_cs_r;

reg                         iccm_f1_valid_r;
reg                         iccm_f1_valid_nxt;
reg                         lsq_iccm_rd_valid_r;
reg [`ICCM0_ADR_RANGE]      iccm0_wr_addr;
reg                         dmp_f1_wr_err_r;
reg                         dmp_f1_wr_err_nxt;
reg                         iccm_dmp_wr_err_r;
wire                        iccm_dmp_ecc_excpn;
reg   [`ICCM0_DATA_RANGE]   iccm0_dout_correct_r;
reg   [`ICCM0_DATA_RANGE]   iccm0_dout_correct_nxt;
reg                         iccm0_cs_r;
wire                        iccm0_addr_cg;

reg [1:0]                   iccm0_f1_id_out_valid_nxt;

reg                         iccm0_cg0;

reg                         dmp_req;
reg [`IFU_ADDR_RANGE]       dmp_addr;

reg                         dmp_f1_cg0;
reg                         dmp_f1_rd_valid_r;            
reg                         dmp_f1_rd_excl_okay_r;
reg                         dmp_f1_wr_excl_okay_r;
reg [`ADDR_RANGE]           dmp_f1_cmd_addr_r; 

reg                         dmp_f1_rd_valid_nxt;            
reg                         dmp_f1_wr_accept_r;            
reg                         dmp_f1_wr_accept_nxt;            
reg                         dmp_f2_wr_done_r;            
reg                         dmp_f2_wr_done_nxt;            

wire                dmi_excl_dummy_wr;
reg                 dummy_dmi_iccm_wr_done;
wire                dmi_excl_addr_match;
wire                dmi_excl_id_match;

reg  [`IFU_ADDR_RANGE]      dmi_addr;
reg                         dmi_req;
reg                         dmi_hreq;
reg [`ADDR_RANGE]           dmi_f1_cmd_addr_r; 
reg [3:0]                   dmi_f1_cmd_id_r; 
reg [5:0]                   dmi_iccm_cmd_atomic_r;
reg                         dmi_f1_cg0;
reg                         dmi_f1_rd_valid_r;            
reg                         dmi_iccm_rd_valid_r;
reg                         dmi_f1_rd_excl_okay_r;
reg                         dmi_f1_wr_excl_okay_r;
reg                         dmi_f1_rd_valid_nxt;                       
reg                         dmi_f1_wr_done_r;            
reg                         dmi_f1_wr_done_nxt;  


wire [`DATA_RANGE]   ifu_amo_mem_data;
wire                        dmp_cmd_atomic;
reg                         dmp_f1_cmd_atomic_r;
reg                         dmp_f1_cmd_atomic_r_r;
reg [31:0]                  dmp_f1_cmd_atomic_data;
wire [`DMP_CTL_AMO_RANGE]   ifu_amo_ctl;
reg  [`DATA_RANGE]          ifu_amo_mem_data_r;
wire [`DATA_RANGE]          ifu_amo_x_data;
wire [`DATA_RANGE]          ifu_amo_result;
reg                         dmp_excl_wr_nxt;
reg                         dmp_excl_rd_nxt;
reg                         dmi_excl_rd_nxt;
reg [3:0]                   dmi_excl_id_nxt;
reg [3:0]                   dmi_excl_id_r;
reg [33:0]                  iccm0_excl_resv_r;
reg [33:0]                  iccm0_excl_resv_nxt;
reg                         set_timer;
reg [`IFU_TTL_RANGE]        ttl_r; 

reg [`ICCM0_DATA_RANGE]       lsq_iccm_wr_data_merged;
reg                           iccm_dmp_rmw_r;
reg                           iccm_dmp_rmw_r_r;

reg [`ICCM0_DATA_RANGE]       dmi_iccm_wr_data_merged;
reg                           iccm_dmi_rmw_r;
reg                           iccm_dmi_rmw_r_r;
reg                           iccm_dmi_wr_err_r;




wire                                 stop_timer;
wire                                 ttl_timeout;



wire                          iccm_dmi_rd_err;
wire                          iccm_dmi_ecc_err;
////////////////////////////////////////////////////////////////////////////
// Local variables related to ecc logic
////////////////////////////////////////////////////////////////////////////

wire  [`ICCM0_ECC_RANGE]      iccm_ecc_din;
wire  [`ICCM0_ECC_RANGE]      iccm_ecc_din_tmp;
reg   [`ICCM0_ADR_RANGE]      iccm0_addr_r;
reg   [`ICCM0_ADR_RANGE]      iccm0_addr_r_r;
wire                          iccm_ecc_en;
wire  [`ICCM0_ADR_RANGE]      iccm0_addr_nxt;    // Address ICCM Memory
wire                          iccm_ecc_db_err;
wire                          iccm_ecc_scrub_en;
wire  [`ICCM0_ECC_MSB-1:0]    fa_iccm_syndrome;
wire  [`ICCM0_DATA_RANGE]     iccm0_dout_correct;
wire  [`ICCM0_ECC_RANGE]      iccm0_ecc_out_int;
reg                           iccm_ecc_scrub_en_r;

wire                          fa_iccm0_ecc_sb_p;
wire                          fa_iccm0_ecc_db_p;
wire                          fa_iccm0_ecc_addr_p;

assign iccm_ecc_en = ((csr_iccm0_eccen == `IC_EN_EXCPN_DB) | (csr_iccm0_eccen == `IC_EN_EXCPN_SB_DB));
 
// ECC encoder instance for ICCM memory
iccm_ecc_encoder u_iccm_ecc_encoder (
                    .data_in        (iccm0_din_q),
                    .address        (iccm0_wr_addr),
                    .ecc            (iccm_ecc_din_tmp)
                );
assign iccm_ecc_din = csr_iccm0_rwecc ? arcv_mecc_diag_ecc[`ICCM0_ECC_RANGE] : iccm_ecc_din_tmp;

assign iccm0_addr_nxt  = ( iccm0_addr_cg == 1'b1 ) ? iccm0_addr
                                                             : iccm0_addr_r;
assign iccm_ecc_scrub_en_nxt = (iccm0_cs & iccm0_we & (iccm0_addr == iccm0_addr_r)) ? 1'b0 : iccm_ecc_scrub_en;

always@(posedge clk or posedge rst_a)
begin: iccm0_addr_reg_PROC
  if (rst_a == 1'b1)
  begin
    iccm0_addr_r         <= `ICCM0_ADR_WIDTH'b0;
    iccm0_addr_r_r       <= `ICCM0_ADR_WIDTH'b0;
    iccm_ecc_scrub_en_r  <= 1'b0;
  end
  else 
  begin
    iccm0_addr_r         <= iccm0_addr_nxt; 
    iccm0_addr_r_r       <= iccm0_addr_r; 
    iccm_ecc_scrub_en_r  <= iccm_ecc_scrub_en_nxt;
  end
end


// ECC decoder instance for ICCM memory
iccm_ecc_decoder u_iccm_ecc_decoder (
   .enable              (iccm_ecc_en                              ), // 
   .data_in             (iccm0_dout[`ICCM0_DATA_RANGE]       ),
   .address             (iccm0_addr_r                        ),
   .addr_err            (fa_iccm0_ecc_addr_p                 ),
   .syndrome            (fa_iccm_syndrome                    ),  // TBD
   .ecc_in              (iccm0_dout[`ICCM0_DATA_ECC_RANGE]   ),
   .data_out            (iccm0_dout_correct                  ),
   .ecc_out             (iccm0_ecc_out_int                   ),
   .single_err          (fa_iccm0_ecc_sb_p                   ),
   .double_err          (fa_iccm0_ecc_db_p                   )
);


wire     no_db_access;
assign   no_db_access = (~(db_active & dmp_f1_rd_valid_r));
assign   iccm0_ecc_addr_err = iccm0_cs_r & fa_iccm0_ecc_addr_p & no_db_access;
assign   iccm0_ecc_sb_err   = iccm0_cs_r & fa_iccm0_ecc_sb_p & no_db_access;
assign   iccm0_ecc_db_err   = iccm0_cs_r & fa_iccm0_ecc_db_p & no_db_access;
assign   iccm0_ecc_syndrome = fa_iccm_syndrome;
assign   iccm0_ecc_addr     = iccm0_addr_r;
assign iccm_ecc_db_err  = iccm0_cs_r &
                               ((iccm_ecc_en &
                                 (( fa_iccm0_ecc_db_p | fa_iccm0_ecc_addr_p ) )) |
                                ((csr_iccm0_eccen == `IC_EN_EXCPN_SB_DB) & fa_iccm0_ecc_sb_p));
assign iccm_ecc_scrub_en = (iccm0_cs_r & fa_iccm0_ecc_sb_p) & iccm_ecc_en;

assign iccm_dmi_ecc_err  = iccm_ecc_db_err & (dmi_f1_rd_valid_r) ;
assign iccm_dmi_rd_err        = iccm_dmi_ecc_err ;



assign dmp_cmd_atomic = ((lsq_iccm_cmd_atomic[5:3] == 3'b100) | (lsq_iccm_cmd_atomic[5:0] == 6'b110000));
  
assign iccm0_dout_correct_nxt = iccm0_cs_r ? iccm0_dout_correct : iccm0_dout_correct_r;
assign iccm0_addr_cg   = iccm0_cs & (~iccm0_we);
always @(posedge clk or posedge rst_a )
begin : mem_dout_reg_PROC
  if( rst_a ) 
  begin
    iccm0_dout_correct_r <= `ICCM0_DATA_WIDTH'h0;
    iccm0_cs_r           <= 1'b0;
  end
  else
  begin
    iccm0_dout_correct_r <= iccm0_dout_correct_nxt;
    iccm0_cs_r           <= iccm0_addr_cg;
  end
end


always @(posedge clk or posedge rst_a )
begin : dmp_rmw_reg_PROC
   if( rst_a ) 
   begin
     iccm_dmp_rmw_r            <= 1'b0;
     iccm_dmp_rmw_r_r          <= 1'b0;
     iccm_dmi_rmw_r            <= 1'b0;
     iccm_dmi_rmw_r_r          <= 1'b0;
     iccm_dmi_wr_err_r         <= 1'b0;
     dmi_f1_wr_err_r           <= 1'b0;
     iccm_dmp_wr_err_r         <= 1'b0;
     dmp_f1_cmd_atomic_r       <= 1'b0;
     dmp_f1_cmd_atomic_r_r     <= 1'b0;
   end
   else
   begin
      iccm_dmp_wr_err_r   <= iccm_dmp_rmw_r & iccm_dmp_ecc_err;
      iccm_dmp_rmw_r      <= lsq_iccm_cmd_valid & dmp_f1_rd_valid_nxt & (~lsq_iccm_cmd_read) & ((~(&lsq_iccm_wr_mask)) | dmp_cmd_atomic);
      dmp_f1_cmd_atomic_r <= lsq_iccm_cmd_valid & dmp_f1_rd_valid_nxt & ((~lsq_iccm_cmd_read) & dmp_cmd_atomic);
      dmp_f1_cmd_atomic_r_r <= dmp_f1_cmd_atomic_r;
      iccm_dmp_rmw_r_r    <= iccm_dmp_rmw_r;
      iccm_dmi_rmw_r      <= dmi_iccm_cmd_valid & ((~dmi_iccm_cmd_read) & (~(&dmi_iccm_wr_mask)) & dmi_f1_rd_valid_nxt);
      iccm_dmi_rmw_r_r    <= iccm_dmi_rmw_r;
      iccm_dmi_wr_err_r   <= iccm_dmi_rmw_r & (iccm_dmi_rd_err);
      dmi_f1_wr_err_r     <= dmi_f1_wr_err_nxt;
   end
end
//////////////////////////////////////////////////////////////////////////////
//
// DMP access to ICCM
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmp_iccm_f0_PROC
  // Derive iccm_tag F0 address 
  //
  dmp_addr = lsq_iccm_cmd_addr[`IFU_ADDR_RANGE];
  dmp_req  = (lsq_iccm_cmd_valid | dmp_f1_cmd_atomic_r | dmp_f1_cmd_atomic_r_r | iccm_dmp_rmw_r_r | iccm_dmp_rmw_r)
             ;

lsq_iccm_wr_data_merged[31:24] = dmp_f1_cmd_atomic_r_r ? dmp_f1_cmd_atomic_data[31:24] : (lsq_iccm_wr_mask[3] ? lsq_iccm_wr_data[31:24] : iccm0_dout_correct_r[31:24]);
lsq_iccm_wr_data_merged[23:16] = dmp_f1_cmd_atomic_r_r ? dmp_f1_cmd_atomic_data[23:16] : (lsq_iccm_wr_mask[2] ? lsq_iccm_wr_data[23:16] : iccm0_dout_correct_r[23:16]);
lsq_iccm_wr_data_merged[15: 8] = dmp_f1_cmd_atomic_r_r ? dmp_f1_cmd_atomic_data[15: 8] : (lsq_iccm_wr_mask[1] ? lsq_iccm_wr_data[15: 8] : iccm0_dout_correct_r[15: 8]);
lsq_iccm_wr_data_merged[ 7: 0] = dmp_f1_cmd_atomic_r_r ? dmp_f1_cmd_atomic_data[ 7: 0] : (lsq_iccm_wr_mask[0] ? lsq_iccm_wr_data[ 7: 0] : iccm0_dout_correct_r[ 7: 0]);


end
  
//////////////////////////////////////////////////////////////////////////////
//
// DMI access to ICCM
//
//////////////////////////////////////////////////////////////////////////////
always @*
begin : dmi_iccm_f0_PROC
  //
  dmi_addr = dmi_iccm_cmd_addr[`IFU_ADDR_RANGE];
  
  dmi_req  = (dmi_iccm_cmd_valid & (~dmi_excl_dummy_wr) & (~extend_dmi_resp) & ((~lsq_iccm_cmd_valid)
                 | (iccm_dmi_rmw_r | iccm_dmi_rmw_r_r)))
              ;

  dmi_hreq = dmi_iccm_cmd_valid & (dmi_iccm_cmd_prio | iccm0_arb_prio_is_dmi_r) & (~extend_dmi_resp) & (~dmi_excl_dummy_wr);

  dmi_iccm_wr_data_merged[31:24] = (dmi_iccm_wr_mask[3] ? dmi_iccm_wr_data[31:24] : iccm0_dout_correct_r[31:24]);
  dmi_iccm_wr_data_merged[23:16] = (dmi_iccm_wr_mask[2] ? dmi_iccm_wr_data[23:16] : iccm0_dout_correct_r[23:16]);
  dmi_iccm_wr_data_merged[15: 8] = (dmi_iccm_wr_mask[1] ? dmi_iccm_wr_data[15: 8] : iccm0_dout_correct_r[15: 8]);
  dmi_iccm_wr_data_merged[ 7: 0] = (dmi_iccm_wr_mask[0] ? dmi_iccm_wr_data[ 7: 0] : iccm0_dout_correct_r[ 7: 0]);

end

////////////////////////////////////////////////////////////////////////////////////////////
// Mux to access ICCM memories - F0
//
////////////////////////////////////////////////////////////////////////////////////////////
always @*
begin : iccm_arbiter_PROC
  // Default values
  //
  iccm0_cg0                 = 1'b0;
  iccm0_cs                  = 1'b0;
  iccm0_we                  = 1'b0;
  iccm0_wem_q               = {`ICCM_DATA_MASK_WIDTH{1'b0}};
  iccm0_ecc_wem             = 1'b0;
  iccm0_din_q               = {`ICCM_DATA_WIDTH{1'b0}};
  iccm0_addr                = iccm0_f1_data_addr_r;           // power optimization - do not toggle
  iccm0_f1_id_out_valid_nxt = {1'b0, fa0_req};
  
  iccm_f1_valid_nxt         = 1'b0;
  dmp_f1_wr_err_nxt         = 1'b0;
  dmp_f1_cg0                = dmp_req | dmp_f1_rd_valid_r | dmp_f1_wr_accept_r | dmp_f2_wr_done_r;
  dmp_f1_rd_valid_nxt       = 1'b0;
  dmp_f1_wr_accept_nxt      = 1'b0;
  
  lsq_iccm_cmd_accept       = 1'b0;
  dmp_excl_wr_nxt           = 1'b0;
  dmp_excl_rd_nxt           = 1'b0;

  chk_arb_prio_req          = 1'b0;

  dmi_f1_cg0                = dmi_req | dmi_hreq | dmi_f1_rd_valid_r | dmi_f1_wr_done_r;
  dmi_f1_rd_valid_nxt       = 1'b0;
  dmi_f1_wr_done_nxt        = 1'b0;
  dmi_iccm_cmd_accept       = 1'b0;
  dmi_iccm_wr_accept        = 1'b0;
  if (dmi_excl_dummy_wr == 1'b1)
  begin
    dmi_iccm_cmd_accept     = 1'b1;
    dmi_iccm_wr_accept      = 1'b1;
  end
  dmi_excl_rd_nxt           = 1'b0;

  dmi_f1_wr_err_nxt         = 1'b0;
  if( iccm_ecc_scrub_en_r )
  begin
    iccm0_cg0                 = 1'b1;
    iccm0_cs                  = 1'b1;
    iccm0_we                  = 1'b1;
    iccm0_addr                = iccm0_addr_r_r[`ICCM0_ADR_RANGE];    
    iccm0_din_q               = iccm0_dout_correct_r;
    iccm0_wem_q               = 4'hF;
    iccm0_ecc_wem             = 1'b1;
    iccm0_f1_id_out_valid_nxt = 2'b00 ;
    chk_arb_prio_req          = 1'b1;
    if ((dmi_req) & iccm_dmi_rmw_r_r )
    begin
      iccm0_din_q             = dmi_iccm_wr_data_merged;
      dmi_iccm_cmd_accept     = 1'b1;
      dmi_iccm_wr_accept      = 1'b1;
      dmi_f1_wr_err_nxt       = iccm_dmi_wr_err_r;
      dmi_f1_wr_done_nxt      = 1'b1;
      dmi_f1_rd_valid_nxt     = 1'b0;
    end
    else
    if ((dmp_req) & iccm_dmp_rmw_r_r )
    begin
      iccm0_din_q             = lsq_iccm_wr_data_merged;
      lsq_iccm_cmd_accept     = ~dmp_f1_cmd_atomic_r_r; 
      dmp_f1_wr_accept_nxt    = 1'b1;
      dmp_f1_rd_valid_nxt     = 1'b0;
      dmp_f1_wr_err_nxt       = iccm_dmp_wr_err_r;
    end
  end
  else
  if ((dmi_req) & iccm_dmi_rmw_r_r )
  begin
    iccm0_cg0                 = (~iccm_dmi_wr_err_r);
    iccm0_cs                  = (~iccm_dmi_wr_err_r);
    iccm0_we                  = (~iccm_dmi_wr_err_r);
    iccm0_addr                = iccm0_addr_r_r[`ICCM0_ADR_RANGE];    
    iccm0_din_q               = dmi_iccm_wr_data_merged;
    iccm0_wem_q               = dmi_iccm_wr_mask;
    iccm0_ecc_wem             = 1'b1;
    dmi_iccm_cmd_accept       = 1'b1;
    dmi_iccm_wr_accept        = 1'b1;
    dmi_f1_wr_err_nxt         = iccm_dmi_wr_err_r;
    dmi_f1_wr_done_nxt        = 1'b1;
    dmi_f1_rd_valid_nxt       = 1'b0;
    iccm0_f1_id_out_valid_nxt = 2'b00 ;
    chk_arb_prio_req          = 1'b1;
  end
  else
  if ((dmp_req) & iccm_dmp_rmw_r_r )
  begin
    iccm0_cg0                 = (~iccm_dmp_wr_err_r);
    iccm0_cs                  = (~iccm_dmp_wr_err_r);
    iccm0_we                  = (~iccm_dmp_wr_err_r);
    iccm0_addr                = dmp_addr[`ICCM0_ADR_RANGE];    
    iccm0_din_q               = lsq_iccm_wr_data_merged;
    iccm0_wem_q               = lsq_iccm_wr_mask;
    iccm0_ecc_wem             = 1'b1;
    lsq_iccm_cmd_accept       = ~dmp_f1_cmd_atomic_r_r; 
    dmp_f1_wr_accept_nxt      = 1'b1;
    dmp_f1_rd_valid_nxt       = 1'b0;
    dmp_f1_wr_err_nxt         = iccm_dmp_wr_err_r;
    iccm0_f1_id_out_valid_nxt = 2'b00 ;
    chk_arb_prio_req          = 1'b1;
  end
  else
  if (dmi_hreq  & (~iccm_dmi_rmw_r) )
  begin
    iccm0_cg0                 = 1'b1;
    iccm0_cs                  = 1'b1;
    iccm0_we                  = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask));
    iccm0_addr                = dmi_addr[`ICCM0_ADR_RANGE];    
    iccm0_din_q               = dmi_iccm_wr_data;
    iccm0_wem_q               = dmi_iccm_wr_mask;
    iccm0_ecc_wem             = 1'b1;
    dmi_iccm_cmd_accept       = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask)) | dmi_iccm_cmd_read;
    dmi_iccm_wr_accept        = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask));
    dmi_excl_rd_nxt           = (dmi_iccm_cmd_read) & (dmi_iccm_cmd_excl); 

    dmi_f1_rd_valid_nxt       = dmi_iccm_cmd_read | ((~dmi_iccm_cmd_read) & (~(&dmi_iccm_wr_mask)));
    dmi_f1_wr_done_nxt        = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask));  
    iccm0_f1_id_out_valid_nxt = 2'b00 ;  
    chk_arb_prio_req          = 1'b1;
  end
  else
  if (dmp_req  & (~iccm_dmp_rmw_r) )
  begin
    if (lsq_iccm_cmd_excl & (~lsq_iccm_cmd_read) & (~iccm0_excl_resv_r[0])) 
    begin
      iccm0_cg0               = 1'b0;
      iccm0_cs                = 1'b0;
    end
    else
    begin
      iccm0_cg0               = 1'b1;
      iccm0_cs                = 1'b1;
    end
    iccm0_we                  = ((~lsq_iccm_cmd_read) & (&lsq_iccm_wr_mask) & (~dmp_cmd_atomic));
    iccm0_addr                = dmp_addr[`ICCM0_ADR_RANGE];    
    iccm0_din_q               = lsq_iccm_wr_data;
    iccm0_wem_q               = lsq_iccm_wr_mask;
    iccm0_ecc_wem             = 1'b1;

    lsq_iccm_cmd_accept       = ((~lsq_iccm_cmd_read) & ((&lsq_iccm_wr_mask) | dmp_cmd_atomic)) | lsq_iccm_cmd_read;
    dmp_f1_rd_valid_nxt       = lsq_iccm_cmd_read
                                | ((~lsq_iccm_cmd_read) &
                                   (
                                   (~(&lsq_iccm_wr_mask))
                                   | (dmp_cmd_atomic)
                                   )
                                  )
                                 ;

    dmp_f1_wr_accept_nxt      = ((~lsq_iccm_cmd_read) & (&lsq_iccm_wr_mask) & (~dmp_cmd_atomic));
    dmp_excl_wr_nxt           = (((~lsq_iccm_cmd_read) & (&lsq_iccm_wr_mask) & (~dmp_cmd_atomic)) & (lsq_iccm_cmd_excl)); 
    dmp_excl_rd_nxt           = (lsq_iccm_cmd_read & (lsq_iccm_cmd_excl)); 
    iccm0_f1_id_out_valid_nxt = 2'b00 ;
    chk_arb_prio_req          = 1'b1;
  end
  else if (fa0_req)
  begin
    iccm0_cg0                 = fa0_req;
    iccm0_cs                  = fa0_req;
    iccm_f1_valid_nxt         = 1'b1;
    iccm0_addr                = fa0_addr[`ICCM0_ADR_RANGE];       
    chk_arb_prio_req          = 1'b0;
  end
  else if (dmi_req  & (~iccm_dmi_rmw_r) )
  begin
    iccm0_cg0                 = 1'b1;
    iccm0_cs                  = 1'b1;
    iccm0_we                  = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask));
    iccm0_addr                = dmi_addr[`ICCM0_ADR_RANGE];    
    iccm0_din_q               = dmi_iccm_wr_data;
    iccm0_wem_q               = dmi_iccm_wr_mask;
    iccm0_ecc_wem             = 1'b1;
    dmi_iccm_cmd_accept       = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask)) | dmi_iccm_cmd_read;
    dmi_iccm_wr_accept        = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask));
    dmi_excl_rd_nxt           = (dmi_iccm_cmd_read) & (dmi_iccm_cmd_excl); 

    dmi_f1_rd_valid_nxt       = dmi_iccm_cmd_read | ((~dmi_iccm_cmd_read) & (~(&dmi_iccm_wr_mask)));
    dmi_f1_wr_done_nxt        = ((~dmi_iccm_cmd_read) & (&dmi_iccm_wr_mask));  
    chk_arb_prio_req          = 1'b1;
  end
end

always @*
begin
  iccm0_wr_addr = `ICCM0_ADR_WIDTH'b0;
  if( iccm_ecc_scrub_en_r )
  begin
    iccm0_wr_addr              = iccm0_addr_r_r[`ICCM0_ADR_RANGE];    
  end
  else if ((dmi_req) & iccm_dmi_rmw_r_r )
  begin
    iccm0_wr_addr              = iccm0_addr_r_r[`ICCM0_ADR_RANGE];    
  end
  else if ((dmp_req) & iccm_dmp_rmw_r_r )
  begin
    iccm0_wr_addr              = dmp_addr[`ICCM0_ADR_RANGE];    
  end
  else if (dmi_hreq  & (~iccm_dmi_rmw_r) )
  begin
    iccm0_wr_addr              = dmi_addr[`ICCM0_ADR_RANGE];    
  end
  else if (dmp_req  & (~iccm_dmp_rmw_r) )
  begin
    iccm0_wr_addr              = dmp_addr[`ICCM0_ADR_RANGE];    
  end
  else if (dmi_req  & (~iccm_dmi_rmw_r) )
  begin
    iccm0_wr_addr              = dmi_addr[`ICCM0_ADR_RANGE];    
  end
end


//////////////////////////////////////////////////////////////////////////////
//                                                                          
// Module instantiation
//                                                                           
//////////////////////////////////////////////////////////////////////////////
//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived. clock gate will be replaced with cg cell that will have scan points 
clkgate u_clkgate_iccm (
  .clk_in            (clk),
  .clock_enable_r    (iccm0_cg0),
  .clk_out           (clk_iccm0)

);

//spyglass enable_block TA_09                                 

rl_ifu_iccm_csr u_rl_ifu_iccm_csr (
  .*,
  .csr_iccm0_base       (csr_iccm0_base   )
);


///////////////////////////////////////////////////////////////////////////////
//  data selection 
//
///////////////////////////////////////////////////////////////////////////////
assign  iccm0_f1_data0 = iccm0_dout_correct[`ICCM_DATA_RANGE];
assign  iccm0_f1_data_err   = {1'b0, iccm_ecc_excpn};

///////////////////////////////////////////////////////////////////////////////
// DMP read data
///////////////////////////////////////////////////////////////////////////////
always @*
begin: iccm_dmp_mux_PROC
  // Provide IBP data
  //
  lsq_iccm_rd_valid = lsq_iccm_rd_valid_r;
  lsq_iccm_rd_data  =  iccm0_dout_correct[`ICCM_DATA_RANGE] ;
end

reg                            extend_dmi_resp_r;
reg                            dmi_iccm_rd_err_r;
reg                            dmi_iccm_rd_excl_ok_r;
reg [`ICCM_DMI_DATA_RANGE]     dmi_iccm_rd_data_r;
always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    extend_dmi_resp_r <= 1'b0;
  end
  else
  begin
    extend_dmi_resp_r <= extend_dmi_resp; 
  end
end
// spyglass disable_block STARC-2.3.4.3
// SMD: A flip-flop should have an asynchronous set or an asynchronous reset
// SJ : All following data flops are validated by extend_dmi_resp_r
always@(posedge clk)
begin
  dmi_iccm_rd_data_r    <= dmi_iccm_rd_data;
  dmi_iccm_rd_excl_ok_r <= dmi_iccm_rd_excl_ok;
  dmi_iccm_rd_err_r     <= dmi_iccm_rd_err;
end
// spyglass enable_block STARC-2.3.4.3
///////////////////////////////////////////////////////////////////////////////
//  DMI read data
///////////////////////////////////////////////////////////////////////////////
always @*
begin: iccm_dmi_mux_PROC
  // Provide IBP data
  //
  dmi_iccm_rd_valid = extend_dmi_resp_r ? 1'b1: dmi_iccm_rd_valid_r;
  dmi_iccm_rd_data  = extend_dmi_resp_r ? dmi_iccm_rd_data_r: iccm0_dout_correct[`ICCM_DATA_RANGE] ;
end
///////////////////////////////////////////////////////////////////////////////
//                                                                          
// Synchronous processes
//                                                                           
//////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : iccm_f1_regs_PROC
  if (rst_a == 1'b1)
  begin
    iccm_f1_valid_r            <= 1'b0;
    iccm0_f1_id_out_valid_r    <= 2'b00;

    iccm0_f1_data_addr_r  <= {`ICCM0_ADR_WIDTH{1'b0}};
      
    iccm0_f1_cs_r         <= 1'b0;
    
  end
  else
  begin
    iccm_f1_valid_r       <= iccm_f1_valid_nxt;
    iccm0_f1_id_out_valid_r    <= iccm0_f1_id_out_valid_nxt;

    if (fa0_req == 1'b1)
    begin
      iccm0_f1_data_addr_r  <= fa0_addr[`ICCM0_ADR_RANGE];
      
      iccm0_f1_cs_r         <= iccm0_cs & (~iccm0_we); 
      
    end
  end
end

always @(posedge clk or posedge rst_a)
begin : iccm_dmp_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmp_f1_rd_valid_r  <= 1'b0;
    dmp_f1_wr_accept_r <= 1'b0;
    dmp_f2_wr_done_r   <= 1'b0;
    lsq_iccm_rd_valid_r  <= 1'b0;
    dmp_f1_wr_err_r    <= 1'b0;
    dmp_f1_rd_excl_okay_r <= 1'b0; 
    dmp_f1_wr_excl_okay_r <= 1'b0;
  end
  else
  begin
    if (dmp_f1_cg0 == 1'b1)
    begin
      dmp_f1_rd_valid_r  <= dmp_f1_rd_valid_nxt;
      dmp_f1_wr_accept_r <= dmp_f1_wr_accept_nxt;
      lsq_iccm_rd_valid_r<= dmp_f1_rd_valid_nxt & 
                            (
                            (lsq_iccm_cmd_read)
                            | (~lsq_iccm_cmd_read & dmp_cmd_atomic)
                            );
      dmp_f1_wr_err_r    <= dmp_f1_wr_err_nxt;
      if (dmp_excl_rd_nxt == 1'b1)
        begin
          dmp_f1_rd_excl_okay_r <= lsq_iccm_cmd_excl; 
        end
      else
        begin
          dmp_f1_rd_excl_okay_r <= 1'b0; 
        end
      if (dmp_excl_wr_nxt == 1'b1)
        begin
          dmp_f1_wr_excl_okay_r <= (iccm0_excl_resv_r[0] & (iccm0_excl_resv_r[33:5] == lsq_iccm_cmd_addr[31:3]));
        end
      else
        begin
          dmp_f1_wr_excl_okay_r <= 1'b0;
        end
    end
    dmp_f2_wr_done_r     <= dmp_f1_wr_accept_r;
  end
end

always @(posedge clk or posedge rst_a)
begin : iccm_dmi_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmi_f1_rd_valid_r  <= 1'b0;
    dmi_iccm_rd_valid_r<= 1'b0;
    dmi_f1_wr_done_r   <= 1'b0;
    dmi_f1_rd_excl_okay_r <= 1'b0;
    dmi_f1_wr_excl_okay_r <= 1'b0;
  end
  else
  begin
    if (dmi_f1_cg0 == 1'b1)
    begin
      dmi_f1_rd_valid_r  <= dmi_f1_rd_valid_nxt;
      dmi_iccm_rd_valid_r<= dmi_f1_rd_valid_nxt & (dmi_iccm_cmd_read
                            );
      dmi_f1_wr_done_r   <= dmi_f1_wr_done_nxt;
      if (dmi_excl_rd_nxt == 1'b1)
        begin
          dmi_f1_rd_excl_okay_r <= dmi_iccm_cmd_excl;
        end
      else
        begin
          dmi_f1_rd_excl_okay_r <= 1'b0; 
        end
      if (dmi_f1_wr_done_nxt)
        begin
          dmi_f1_wr_excl_okay_r <= (iccm0_excl_resv_r[1] & dmi_iccm_cmd_excl & (dmi_excl_id_r == dmi_iccm_cmd_id) & (iccm0_excl_resv_r[33:2] == dmi_iccm_cmd_addr));
        end
      else
        begin
          dmi_f1_wr_excl_okay_r <= 1'b0; 
        end
    end
  end
end

//////////////////////////////////////////////////////////////////////////////////////////
// Output assignments
//
///////////////////////////////////////////////////////////////////////////////////////////

assign iccm_idle       = (~(fa0_req | dmp_req)) 
                          & stop_timer
                          ; 
assign iccm0_fa0_ready = 1'b1; // @@@

assign iccm0_din  = {iccm_ecc_din,iccm0_din_q};
assign iccm0_wem  = {iccm0_ecc_wem,iccm0_wem_q};
assign lsq_iccm_rd_err = iccm_dmp_ecc_err &
                         ((lsq_iccm_rd_valid)
                          | (~lsq_iccm_cmd_read & lsq_iccm_rd_valid & dmp_f1_cmd_atomic_r)
                         );
assign lsq_iccm_wr_err = dmp_f1_wr_err_r;     

assign lsq_iccm_wr_accept  = dmp_f1_wr_accept_nxt;
assign lsq_iccm_rd_excl_ok = dmp_f1_rd_excl_okay_r; 
assign lsq_iccm_rd_last    = 1'b1;                       

assign lsq_iccm_wr_done      = dmp_f1_wr_accept_r;
//assign lsq_iccm_wr_excl_okay = 1'b0;     
assign lsq_iccm_wr_excl_okay = dmp_f1_wr_accept_r & dmp_f1_wr_excl_okay_r; 

assign dmi_iccm_wr_err       = dmi_f1_wr_err_r;
assign dmi_iccm_wr_done       = dmi_f1_wr_done_r | dummy_dmi_iccm_wr_done;
assign dmi_iccm_wr_excl_okay  = dmi_f1_wr_excl_okay_r;
assign dmi_iccm_rd_excl_ok    = extend_dmi_resp_r ? dmi_iccm_rd_excl_ok_r : (dmi_f1_rd_excl_okay_r & (~iccm_dmi_rd_err)); 
assign dmi_iccm_rd_err        = extend_dmi_resp_r ? dmi_iccm_rd_err_r : (dmi_iccm_rd_valid & iccm_dmi_rd_err);
assign dmi_iccm_rd_last       = dmi_iccm_rd_valid;
assign extend_dmi_resp        = (dmi_iccm_rd_valid & (~dmi_iccm_rd_accept));

assign iccm_ecc_excpn = iccm_ecc_db_err & iccm_f1_valid_r;

assign iccm_dmp_ecc_excpn = iccm_ecc_db_err & (dmp_f1_rd_valid_r);
assign iccm_dmp_ecc_err        = iccm_dmp_ecc_excpn ;

assign iccm_ecc_wr = dmp_f1_rd_valid_r & csr_iccm0_rwecc;

assign iccm0_ecc_out = (iccm_ecc_excpn | iccm_dmp_ecc_excpn | (csr_iccm0_rwecc & dmp_f1_rd_valid_r))   ? iccm0_ecc_out_int : `ICCM0_ECC_WIDTH'b0;

assign stop_timer = (ttl_r == `IFU_TTL_WIDTH'd0);
assign ttl_timeout = stop_timer;
always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    ttl_r <= `IFU_TTL_WIDTH'b0;
  end
  else
  begin
    if (set_timer == 1'b1)
    begin
      ttl_r <= `IFU_TTL_WIDTH'd48;
    end
    else if (stop_timer == 1'b0)
    begin
      ttl_r <= ttl_r - `IFU_TTL_WIDTH'd1;
      if (~|(iccm0_excl_resv_r[1:0]))
      begin
        ttl_r <= `IFU_TTL_WIDTH'b0; 
      end
    end
  end
end

always@(posedge clk or posedge rst_a)
begin: dmp_f1_cmd_addr_r_PROC 
  if (rst_a == 1'b1)
  begin
    dmp_f1_cmd_addr_r <= 32'b0;
  end
  else
  begin
    dmp_f1_cmd_addr_r <= lsq_iccm_cmd_addr;
  end
end

always@(posedge clk or posedge rst_a)
begin: dmi_f1_cmd_addr_r_PROC 
  if (rst_a == 1'b1)
  begin
    dmi_f1_cmd_addr_r <= 32'b0;
    dmi_f1_cmd_id_r   <= 4'b0;
  end
  else
  begin
    if (dmi_iccm_cmd_valid & dmi_iccm_cmd_accept)
    begin
      dmi_f1_cmd_addr_r <= dmi_iccm_cmd_addr;
      dmi_f1_cmd_id_r   <= dmi_iccm_cmd_id;
    end
  end
end


always@(posedge clk or posedge rst_a)
begin: iccm0_excl_resv_reg_PROC
  if (rst_a == 1'b1)
  begin
    iccm0_excl_resv_r <= 34'b0; 
    dmi_excl_id_r     <= 4'b0;
  end
  else
  begin
    iccm0_excl_resv_r <= iccm0_excl_resv_nxt;
    dmi_excl_id_r     <= dmi_excl_id_nxt; 
  end
end

always@*
begin: iccm0_excl_resv_PROC
  iccm0_excl_resv_nxt = iccm0_excl_resv_r;
  dmi_excl_id_nxt     = dmi_excl_id_r;
  set_timer           = 1'b0;
  case(iccm0_excl_resv_r[1:0])
  2'b00:
  begin
    if ((dmp_f1_rd_excl_okay_r) & (~iccm_dmp_ecc_err))
    begin
      iccm0_excl_resv_nxt[1:0]  = 2'b01;
      iccm0_excl_resv_nxt[33:2] = dmp_f1_cmd_addr_r;
      set_timer                 = 1'b1;
    end
    else if ((dmi_f1_rd_excl_okay_r) & (~iccm_dmi_rd_err))
    begin
      iccm0_excl_resv_nxt[1:0]  = 2'b10;
      iccm0_excl_resv_nxt[33:2] = dmi_f1_cmd_addr_r; 
      dmi_excl_id_nxt           = dmi_f1_cmd_id_r;
      set_timer                 = 1'b1;
    end
  end
  2'b01:
  begin
    if (trap_clear_iccm_resv)
      begin
        iccm0_excl_resv_nxt[0] = 1'b0;
      end
    else if (dmp_excl_wr_nxt)
      begin
        iccm0_excl_resv_nxt[0] = 1'b0;
      end
    else if ((((iccm0_cs == 1'b1) & (iccm0_we == 1'b1) & (iccm0_addr[`ICCM0_ADR_MSB:3] == iccm0_excl_resv_r[20:5])))
             & (dmp_f1_wr_accept_nxt
                | dmi_f1_wr_done_nxt
               )
            )
      begin
        iccm0_excl_resv_nxt[0] = 1'b0;
      end
    else if ((dmi_f1_rd_excl_okay_r) & (ttl_timeout) & (~iccm_dmi_rd_err))
      begin
        iccm0_excl_resv_nxt[0]    = 1'b0;
        iccm0_excl_resv_nxt[1]    = 1'b1;
        iccm0_excl_resv_nxt[33:2] = dmi_f1_cmd_addr_r; 
        dmi_excl_id_nxt           = dmi_f1_cmd_id_r;
        set_timer                 = 1'b1;
      end
    else if ((dmp_f1_rd_excl_okay_r) & (~iccm_dmp_ecc_err))
      begin
        iccm0_excl_resv_nxt[0]    = 1'b1;
        iccm0_excl_resv_nxt[1]    = 1'b0;
        iccm0_excl_resv_nxt[33:2] = dmp_f1_cmd_addr_r;
      end
    else if (lsq_iccm_cmd_valid & (~lsq_iccm_cmd_read) & lsq_iccm_cmd_excl & (lsq_iccm_cmd_addr[`ICCM0_ADR_MSB:3] != iccm0_excl_resv_r[20:5]))
      begin
        iccm0_excl_resv_nxt[0]    = 1'b0;
        iccm0_excl_resv_nxt[1]    = 1'b0;
      end
  end
  2'b10:
  begin
    if (trap_clear_iccm_resv)
      begin
        iccm0_excl_resv_nxt[1] = 1'b0;
      end
    else if (dmi_f1_wr_done_nxt & dmi_iccm_cmd_excl)
      begin
        iccm0_excl_resv_nxt[1] = 1'b0;
      end
    else if ((((iccm0_cs == 1'b1) & (iccm0_we == 1'b1) & (iccm0_addr[`ICCM0_ADR_MSB:3] == iccm0_excl_resv_r[20:5])))
            & (dmi_f1_wr_done_nxt
               | dmp_f1_wr_accept_nxt 
              )
            )
      begin
        iccm0_excl_resv_nxt[1] = 1'b0;
      end
    else if ((dmi_f1_rd_excl_okay_r) & (~iccm_dmi_rd_err))
    begin
      if (ttl_timeout)
        begin
          iccm0_excl_resv_nxt[33:2] = dmi_f1_cmd_addr_r; 
          dmi_excl_id_nxt           = dmi_f1_cmd_id_r;
          set_timer                 = 1'b1;
        end
      else if (dmi_excl_id_r == dmi_iccm_cmd_id)
        begin
          iccm0_excl_resv_nxt[33:2] = dmi_f1_cmd_addr_r; 
        end
    end
    else if ((dmp_f1_rd_excl_okay_r) & (ttl_timeout) & (~iccm_dmp_ecc_err))
      begin
        iccm0_excl_resv_nxt[0]    = 1'b1;
        iccm0_excl_resv_nxt[1]    = 1'b0;
        iccm0_excl_resv_nxt[33:2] = dmp_f1_cmd_addr_r; 
        set_timer                 = 1'b1;
      end
    else if (dmi_iccm_cmd_valid & (~dmi_iccm_cmd_read) & dmi_iccm_cmd_excl & ((~dmi_excl_addr_match) | (~dmi_excl_id_match)))
      begin
        iccm0_excl_resv_nxt[1]    = 1'b0;
      end
  end
  default:
  begin
  end
  endcase
end

assign ifu_amo_mem_data = iccm0_dout_correct_r ; 

reg [5:0] dmp_iccm_cmd_atomic_r;
always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    dmp_iccm_cmd_atomic_r <= 6'b0;
  end
  else
  begin
    if (lsq_iccm_cmd_valid & dmp_f1_rd_valid_nxt & ((~lsq_iccm_cmd_read) & dmp_cmd_atomic))
    begin
      dmp_iccm_cmd_atomic_r <= lsq_iccm_cmd_atomic; 
    end
  end
end


assign ifu_amo_x_data   = ifu_amo_ctl[`DMP_CTL_AMOAND] ? (~lsq_iccm_wr_data) : lsq_iccm_wr_data; 
assign ifu_amo_ctl[`DMP_CTL_AMOADD]  = (dmp_iccm_cmd_atomic_r == 6'b100000); 
assign ifu_amo_ctl[`DMP_CTL_AMOXOR]  = (dmp_iccm_cmd_atomic_r == 6'b100010); 
assign ifu_amo_ctl[`DMP_CTL_AMOAND]  = (dmp_iccm_cmd_atomic_r == 6'b100001); 
assign ifu_amo_ctl[`DMP_CTL_AMOOR]   = (dmp_iccm_cmd_atomic_r == 6'b100011); 
assign ifu_amo_ctl[`DMP_CTL_AMOMIN]  = (dmp_iccm_cmd_atomic_r == 6'b100101); 
assign ifu_amo_ctl[`DMP_CTL_AMOMINU] = (dmp_iccm_cmd_atomic_r == 6'b100111); 
assign ifu_amo_ctl[`DMP_CTL_AMOMAX]  = (dmp_iccm_cmd_atomic_r == 6'b100100); 
assign ifu_amo_ctl[`DMP_CTL_AMOMAXU] = (dmp_iccm_cmd_atomic_r == 6'b100110); 
assign ifu_amo_ctl[`DMP_CTL_LOCK]    = 1'b0; 
rl_dmp_amo u_rl_ifu_amo
(
 .amo_ctl      (ifu_amo_ctl),
 .amo_mem_data (ifu_amo_mem_data),
 .amo_x_data   (ifu_amo_x_data),
 .amo_result   (ifu_amo_result)
);
assign dmp_f1_cmd_atomic_data = ifu_amo_result;
assign dmi_excl_addr_match = (iccm0_excl_resv_r[33:2] == dmi_iccm_cmd_addr);
assign dmi_excl_id_match   = (dmi_iccm_cmd_id == dmi_excl_id_r);
assign dmi_excl_dummy_wr = ((~iccm0_excl_resv_r[1])
                            | (iccm0_excl_resv_r[1] & (ttl_timeout ? (~dmi_excl_addr_match) : (~dmi_excl_id_match)))
                           )
                           & dmi_iccm_cmd_valid & (~dmi_iccm_cmd_read) & dmi_iccm_cmd_excl; 

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    dummy_dmi_iccm_wr_done      <= 1'b0;
  end
  else
  begin
    dummy_dmi_iccm_wr_done      <= 1'b0;
    if (dummy_dmi_iccm_wr_done & (~dmi_iccm_wr_resp_accept))
    begin
      dummy_dmi_iccm_wr_done      <= 1'b1;
    end
    else if (dmi_excl_dummy_wr)
    begin
      dummy_dmi_iccm_wr_done      <= 1'b1;
    end
  end
end                           



assign iccm0_arb_prio_is_core_r = ~iccm0_arb_prio_is_dmi_r;
assign core_failed_attempt  = (fa0_req & (~iccm_f1_valid_nxt)) | (lsq_iccm_cmd_valid & (~(lsq_iccm_cmd_accept | dmp_f1_rd_valid_nxt
                               | iccm_dmp_rmw_r
                              )));
assign dmi_failed_attempt   = dmi_iccm_cmd_valid & (~(dmi_iccm_cmd_accept | dmi_f1_rd_valid_nxt
                               | iccm_dmi_rmw_r
                              ));
always@*
begin
  arb_prio_counter_incr      = 1'b0; 
  iccm0_arb_prio_is_dmi_nxt  = iccm0_arb_prio_is_dmi_r; 
  reset_arb_prio_counter     = 1'b0;
  if (chk_arb_prio_req)
  begin
    if (iccm0_arb_prio_is_dmi_r)
    begin
      iccm0_arb_prio_is_dmi_nxt  = iccm0_arb_prio_is_dmi_r; 
      if (core_failed_attempt)
      begin
        iccm0_arb_prio_is_dmi_nxt  = 1'b1;
        if (~(&arb_prio_counter[3:0]))
        begin
          arb_prio_counter_incr = 1'b1; 
        end
        else
        begin
          iccm0_arb_prio_is_dmi_nxt  = 1'b0;
          reset_arb_prio_counter     = 1'b1;
        end
      end
    end
    else if (iccm0_arb_prio_is_core_r)
    begin
      iccm0_arb_prio_is_dmi_nxt  = iccm0_arb_prio_is_dmi_r; 
      if (dmi_failed_attempt)
      begin
        iccm0_arb_prio_is_dmi_nxt  = 1'b0;
        if (~(&arb_prio_counter[3:0]))
        begin
          arb_prio_counter_incr = 1'b1; 
        end
        else
        begin
          iccm0_arb_prio_is_dmi_nxt  = 1'b1;
          reset_arb_prio_counter     = 1'b1;
        end
      end
    end
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    iccm0_arb_prio_is_dmi_r  <= 1'b0;
    arb_prio_counter         <= 5'b0;
  end
  else
  begin
    iccm0_arb_prio_is_dmi_r  <= iccm0_arb_prio_is_dmi_nxt; 
    if (reset_arb_prio_counter)
    begin
      arb_prio_counter <= 5'b0_0000;
    end
    else if (arb_prio_counter_incr)
    begin
      arb_prio_counter <= arb_prio_counter + 5'b0_0001;
    end
  end
end




endmodule // rl_ifu_iccm


