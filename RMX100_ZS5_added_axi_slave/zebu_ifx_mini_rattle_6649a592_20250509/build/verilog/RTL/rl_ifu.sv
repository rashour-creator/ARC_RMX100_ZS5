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
//         rl_ifu
//            |
//            +--
//            |
//            +--
//            |
//            +--
//            |
//            +--
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

module rl_ifu (
  /////////// Instruction Issue Interface //////////////////////////////////////
  //
  output                            ifu_issue,               // IFU issues instruction
  output [`PC_RANGE]                ifu_pc,
  output [2:0]                      ifu_size,
  output [4:0]                      ifu_pd_addr0,
  output [4:0]                      ifu_pd_addr1,
  output [31:0]                     ifu_inst,                // acutal instruction word
  output [1:0]                      ifu_fusion,              // fusion info
  output [`FU_1H_RANGE]             ifu_pd_fu,
  input                             db_active,
  input                             x1_holdup,               // X1 stage holds-up
  output                            hpm_bicmstall,
  output                            hpm_icm,

  input                             uop_busy,

  ////////// Fetch-Restart Interface /////////////////////////////////////////
  //
  input                             fch_restart,             // EXU requests IFU restart
  input                             fch_restart_vec,         //
  input [`PC_RANGE]                 fch_target,              //
  input                             fch_stop_r,              // EXU requests IFU halt

  ////////// Branch Interface //////////////////////////////////////////////
  //
  input                             br_req_ifu,              // BR requests change of ctl flow
  input [`PC_RANGE]                 br_restart_pc,           // BR target

  output                                        ic_tag_ecc_addr_err,
  output                                        ic_tag_ecc_sb_err,
  output                                        ic_tag_ecc_db_err,
  output  [`IC_TAG_ECC_MSB-1:`IC_TAG_ECC_LSB]   ic_tag_ecc_syndrome,
  output  [`IC_IDX_RANGE]                       ic_tag_ecc_addr,

  output                                        ic_data_ecc_addr_err,
  output                                        ic_data_ecc_sb_err,
  output                                        ic_data_ecc_db_err,
  output  [`IC_DATA_ECC_MSB-1:`IC_DATA_ECC_LSB] ic_data_ecc_syndrome,
  output  [`IC_DATA_ADR_RANGE]                  ic_data_ecc_addr,
  input                              arcv_icache_op_init,     // Initiate Cache Maintenance Operation
  input  [`ARCV_MC_CTL_RANGE]        arcv_mcache_ctl,         // I-Cache CSR Control
  input  [`ARCV_MC_OP_RANGE]         arcv_mcache_op,          // I-Cache CSR Op Type
  input  [`ARCV_MC_ADDR_RANGE]       arcv_mcache_addr,        // I-Cache CSR Op Address
  input  [`ARCV_MC_LN_RANGE]         arcv_mcache_lines,       // I-Cache Op Number of Lines
  input  [`DATA_RANGE]               arcv_mcache_data,        // I-Cache Op Data to be written 

  output                             arcv_icache_op_done,     // I-Cache Operation Complete
  output [`DATA_RANGE]               arcv_icache_data,        // I-Cache TAG/DATA 
  output                             arcv_icache_op_in_progress,
  output                             ic_tag_ecc_excpn,
  output                             ic_data_ecc_excpn,
  output                             ic_tag_ecc_wr  ,
  output     [`IC_TAG_ECC_RANGE]     ic_tag_ecc_out ,
  output                             ic_data_ecc_wr ,
  output     [`IC_DATA_ECC_RANGE]    ic_data_ecc_out,
  ////////// PMP interface ////////////////////////////////////////////////
  //
  output [`IFU_ADDR_RANGE]          ifu_pmp_addr0,           // fetch addr0 to PMP: F1
  output [`IFU_ADDR_RANGE]          pmp_viol_addr,           // used for mtval update

  input                             ipmp_hit0,                // PMP hit
  input [5:0]                       ipmp_perm0,              // {L, X, W, R}

  input [1:0]                       priv_level,

  ////////// IFU FU interface ////////////////////////////////////////////////
  //
  input                             spc_x2_clean,
  input                             spc_x2_flush,
  input                             spc_x2_inval,
  input                             spc_x2_zero,
  input                             spc_x2_prefetch,
  input [`DATA_RANGE]               spc_x2_data,
  output                            icmo_done,
  input                             halt_req_asserted,
  input                             kill_ic_op,
  input                             halt_fsm_in_rst,
  ////////// PMA interface ////////////////////////////////////////////////
  //
  output [`IFU_ADDR_RANGE]          ifu_pma_addr0,           // fetch addr0 to PMP: F1
  output [2:0]                      f1_mem_target,
  output                            fetch_iccm_hole,

  input [3:0]                       ipma_attr0,              // {L, X, W, R}

  output reg [`IFU_EXCP_RANGE]      ifu_exception,
  
  ////////// IBP interface //////////////////////////////////////////////////////
  //
  output                            ifu_cmd_valid,
  output [3:0]                      ifu_cmd_cache,
  output [`IC_WRD_RANGE]            ifu_cmd_burst_size,
  output                            ifu_cmd_read,
  output                            ifu_cmd_aux,
  input                             ifu_cmd_accept,
  output [`ADDR_RANGE]              ifu_cmd_addr,
  output                            ifu_cmd_excl,
  output                            ifu_cmd_wrap,
  output [5:0]                      ifu_cmd_atomic,
  output [2:0]                      ifu_cmd_data_size,
  output [1:0]                      ifu_cmd_prot,

  input                             ifu_rd_valid,
  input                             ifu_rd_err,
  input                             ifu_rd_excl_ok,
  input                             ifu_rd_last,
  output                            ifu_rd_accept,
  input  [31:0]                     ifu_rd_data,
  output                            ifu_fch_vec,

  input  [7:0]                      arcv_mecc_diag_ecc,

  input                             trap_clear_iccm_resv,

  ////////// ICCM ECC exception ///////////////////////////////////////////////////////////
  output                            iccm_ecc_excpn,
  output                            iccm_dmp_ecc_err,
  output                            iccm_ecc_wr,
  output    [`ICCM0_ECC_RANGE]      iccm0_ecc_out,
  output                            iccm0_ecc_addr_err,
  output                            iccm0_ecc_sb_err,
  output                            iccm0_ecc_db_err,
  output [`ICCM0_ECC_MSB-1:0]       iccm0_ecc_syndrome,
  output [`ICCM0_ADR_RANGE]         iccm0_ecc_addr,

  ////////// CSR interface ///////////////////////////////////////////////
  //
  input  [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input  [7:0]                     csr_sel_addr,          // (X1) CSR address

  output [`DATA_RANGE]             csr_rdata,             // (X1) CSR read data
  output                           csr_illegal,           // (X1) illegal
  output                           csr_unimpl,            // (X1) Invalid CSR
  output                           csr_serial_sr,         // (X1) SR group flush pipe
  output                           csr_strict_sr,         // (X1) SR flush pipe

  input                            csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input  [7:0]                     csr_waddr,             // (X2) CSR addr
  input  [`DATA_RANGE]             csr_wdata,             // (X2) Write data

  output [11:0]                    iccm0_base,
  output                           iccm0_disable,

  ////////// DMP IBP interface //////////////////////////////////////////////
  //
  input                             lsq_iccm_cmd_valid,
  input  [3:0]                      lsq_iccm_cmd_cache,
  input                             lsq_iccm_cmd_burst_size,
  input                             lsq_iccm_cmd_read,
  input                             lsq_iccm_cmd_aux,
  output                            lsq_iccm_cmd_accept,
  input  [`ADDR_RANGE]              lsq_iccm_cmd_addr,
  input                             lsq_iccm_cmd_excl,
  input  [5:0]                      lsq_iccm_cmd_atomic,
  input  [2:0]                      lsq_iccm_cmd_data_size,
  input  [1:0]                      lsq_iccm_cmd_prot,

  input                             lsq_iccm_wr_valid,
  input                             lsq_iccm_wr_last,
  output                            lsq_iccm_wr_accept,
  input  [3:0]                      lsq_iccm_wr_mask,
  input  [31:0]                     lsq_iccm_wr_data,

  output                            lsq_iccm_rd_valid,
  output                            lsq_iccm_rd_err,
  output                            lsq_iccm_rd_excl_ok,
  output                            lsq_iccm_rd_last,
  input                             lsq_iccm_rd_accept,
  output  [31:0]                    lsq_iccm_rd_data,

  output                            lsq_iccm_wr_done,
  output                            lsq_iccm_wr_excl_okay,
  output                            lsq_iccm_wr_err,
  input                             lsq_iccm_wr_resp_accept,

  ////////// DMI IBP interface //////////////////////////////////////////////
  //
  input                                 dmi_iccm_cmd_valid,
  input                                 dmi_iccm_cmd_prio,
  input  [3:0]                          dmi_iccm_cmd_cache,
  input                                 dmi_iccm_cmd_burst_size,
  input                                 dmi_iccm_cmd_read,
  input  [`ADDR_RANGE]                  dmi_iccm_cmd_addr,
  input                                 dmi_iccm_cmd_excl,
  input  [3:0]                          dmi_iccm_cmd_id,
  input  [2:0]                          dmi_iccm_cmd_data_size,
  input  [1:0]                          dmi_iccm_cmd_prot,
  output                                dmi_iccm_cmd_accept,

  input                                 dmi_iccm_wr_valid,
  input                                 dmi_iccm_wr_last,
  input  [`ICCM_DMI_DATA_WIDTH/8-1:0]   dmi_iccm_wr_mask,
  input  [`ICCM_DMI_DATA_RANGE]         dmi_iccm_wr_data,
  output                                dmi_iccm_wr_accept,

  output                                dmi_iccm_rd_valid,
  output                                dmi_iccm_rd_err,
  output                                dmi_iccm_rd_excl_ok,
  output  [`ICCM_DMI_DATA_RANGE]        dmi_iccm_rd_data,
  output                                dmi_iccm_rd_last,
  input                                 dmi_iccm_rd_accept,

  output                                dmi_iccm_wr_done,
  output                                dmi_iccm_wr_excl_okay,
  output                                dmi_iccm_wr_err,
  input                                 dmi_iccm_wr_resp_accept,
  ////////// Breakpoint ////////////////////////////////////////////////////
  //
  input                                 ifu_trig_trap,

  ////////// SRAM interface ////////////////////////////////////////////////
  //
  output  iccm0_clk,
  output [`ICCM0_DRAM_RANGE] iccm0_din,
  output [`ICCM0_ADR_RANGE] iccm0_addr,
  output  iccm0_cs,
  output  iccm0_we,
  output [`ICCM_MASK_RANGE] iccm0_wem,
  input  [`ICCM0_DRAM_RANGE] iccm0_dout,

  ////////// SRAM IC TAG interface ////////////////////////////////////////////////
  output  ic_tag_mem_clk,
  output [`IC_TAG_SET_RANGE] ic_tag_mem_din,
  output [`IC_IDX_RANGE] ic_tag_mem_addr,
  output  ic_tag_mem_cs,
  output  ic_tag_mem_we,
  output [`IC_TAG_SET_RANGE] ic_tag_mem_wem,
  input  [`IC_TAG_SET_RANGE] ic_tag_mem_dout,
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  output  ic_data_mem_clk,
  output [`IC_DATA_SET_RANGE] ic_data_mem_din,
  output [`IC_DATA_ADR_RANGE] ic_data_mem_addr,
  output  ic_data_mem_cs,
  output  ic_data_mem_we,
  output [`IC_DATA_SET_RANGE] ic_data_mem_wem,
  input  [`IC_DATA_SET_RANGE] ic_data_mem_dout,

  ////////// FENCEI I$ Invalidate interface ///////////////////////////
  //
  input                             spc_fence_i_inv_req,   // Invalidate request to IFU
  output                            spc_fence_i_inv_ack,   // Acknowledgement that Invalidation is complete

  ////////// IFU status ////////////////////////////////////////////////
  //
  output                            ifu_idle_r,            // IFU is idle
  output                            ic_idle_ack,

  ////////// General input signals /////////////////////////////////////////////
  //
  input                             clk,                   // clock signal
//  input                             ar_clock_enable_r,     // clock is enabled
  input                             rst_init_disable_r,    // Disabe initialization upon reset
  input                             sr_dbg_cache_rst_disable,
  input                             rst_a                  // reset signal
);


// Wires
//
wire                         fa0_req;
wire  [`IFU_ADDR_RANGE]      fa0_addr;
// @@ Temp Stub
wire                         fa1_req;
wire  [`IFU_ADDR_RANGE]      fa1_addr;
//
wire                         fa_offset;

wire  [`FTB_DEPTH_RANGE]     f0_id;
wire                         f0_id_valid;
wire  [`FTB_DEPTH_RANGE]     f1_id;
//wire                         f1_id_valid_partial;
wire                         f1_id_invalidate;

wire                         f1_offset;
wire [`IFU_ADDR_RANGE]       f1_addr0;               // fetch block0 address
wire [3:0]        f0_pred_target;
wire [3:0]        f1_mem_target_r;
wire [2:0]                   f1_mem_target_i;

wire                         f1_mem_target_mispred;

wire                         ftb_idle;
wire                         ftb_serializing;
wire                         ftb_ic_going_idle;

wire                         ifu_bus_err;
wire                         iccm_fa0_ready;
wire                         iccm_fa1_ready;
wire                         iccm_idle;
wire [1:0]                   iccm0_f1_id_out_valid_r;
wire [1:0]                   iccm0_f1_data_out_valid;

wire [31:0]                  iccm0_f1_data0;
wire [1:0]                   iccm0_f1_data_err;
wire                         iccm0_fa0_req;
wire                         iccm0_fa_req;

wire                         ic_idle;
wire [1:0]                   ic_f1_id_out_valid_r;
wire [1:0]                   ic_f1_data_out_valid;
wire                         ic_f1_bus_err;

wire [31:0]                  ic_f1_data0;
wire [31:0]                  ic_f1_data1;
wire [1:0]                   ic_f1_data_valid;
wire [1:0]                   ic_f1_data_err;
wire                         ic_fa0_req;
wire                         ic_fa1_req;
wire [1:0]                   ic_f1_data_fwd;
wire                         ic_fa_req;
wire                         ic_init_done;
wire                         ifu_init_done;


wire [`FTB_DEPTH_RANGE]      ftb_top_id;

//wire                         iq_write_partial;
wire                         iq_full;

wire                         fetch_iccm;
wire                         fetch_iccm_hole_i;
wire                         fa_is_in_iccm_region;

wire                         al_pmp_viol;
wire                         pmp_viol0;

wire                         al_pma_viol;

wire [`PC_RANGE]             fch_pc_nxt;
wire                         fch_same_pc;


wire                         fa_in_diff_region;
wire                         fa1_in_iccm_hole;
wire                         fa0_or_fa1_in_iccm;
wire                         fa0_in_iccm;
wire                         fa1_in_iccm;
wire                         fa0_cross_iccm_range;

wire f1_mem_ccm_hole;


wire                         ifu_ecc_err;



assign ifu_init_done = 1'b1 
                        & ic_init_done
                        ;



assign fa0_in_iccm         = (fa0_addr[31:20] == iccm0_base);
assign fetch_iccm_hole_i   = iccm0_disable ? 1'b0: ((fa0_addr[`ICCM0_ADR_HOLE_RANGE] != `ICCM0_ADR_HOLE_WIDTH'b0) & (fa0_in_iccm));
assign fetch_iccm      = iccm0_disable ? 1'b0 : fa0_in_iccm & ~fetch_iccm_hole_i;
assign iccm0_fa0_req   = fa0_req & fetch_iccm & ifu_init_done;
assign iccm0_fa_req    = iccm0_disable ? 1'b0 : (fa0_req & f0_pred_target[0] & ifu_init_done);
assign ic_fa0_req      = fa0_req & ~fetch_iccm & ifu_init_done;
assign f1_mem_ccm_hole = iccm0_fa0_req ? 1'b0: fetch_iccm_hole_i;
assign ic_fa_req       = (fa0_req & f0_pred_target[2] & ifu_init_done);
assign f1_mem_target_i  = iccm0_fa0_req ? 3'b001: 3'b100;



//////////////////////////////////////////////////////////////////////////////
//
// Module instantiation
//
//////////////////////////////////////////////////////////////////////////////

rl_ifu_fetcher u_rl_ifu_fetcher (
  .*,
  .f1_addr0_r              (f1_addr0),
  .f1_offset_r             (f1_offset),
  .f1_mem_target           ({f1_mem_ccm_hole, f1_mem_target_i}),
  .f1_mem_target_r         (f1_mem_target_r),
  .f1_mem_target_mispred_r (f1_mem_target_mispred  ),
  .rst_a                   (rst_a                  )

);

rl_ifu_id_ctrl u_rl_ifu_id_ctrl (
  .*,

  .f1_mem_target_r         (f1_mem_target_r[2:0]),
  .ic_f1_data_in_valid       (ic_f1_id_out_valid_r),
  .iccm0_f1_data_in_valid    (iccm0_f1_id_out_valid_r),

   // spyglass disable_block UnloadedOutTerm-ML
   // SMD: Unloaded but driven output terminal of an instance detected
   // SJ : Reserved for future use 
  .f1_id_data_out_valid      (),
  .f1_id_on_top              (),
   // spyglass enable_block UnloadedOutTerm-ML
  .f1_id_r                   (f1_id),
  .rst_a                     (rst_a)

);

wire iccm0_fa0_ready;
wire iccm0_fa1_ready;
rl_ifu_iccm  u_rl_ifu_iccm (
  .*,
  .fa0_req                    (iccm0_fa_req           ),
  .clk_iccm0                  (iccm0_clk              ),
  .csr_iccm0_base             (iccm0_base             ),
  .csr_iccm0_disable          (iccm0_disable          ),
  .rst_a                      (rst_a                  )
);

rl_ifu_icache u_rl_ifu_icache (
   .*,

  .fa0_req                    (ic_fa_req              ),
  .fetch_iccm_hole            (f0_pred_target[3]      ),
  .rf_reset_done_r            (ic_init_done           ),
  .rst_a                      (rst_a                  )

);



rl_ifu_align u_rl_ifu_align (
   .*,
  .al_issue                  (ifu_issue              ),
  .al_pc                     (ifu_pc                 ),
  .al_size                   (ifu_size               ),
  .al_pd_addr0               (ifu_pd_addr0           ),
  .al_pd_addr1               (ifu_pd_addr1           ),
  .al_inst                   (ifu_inst               ),
  .al_ecc_err                (ifu_ecc_err            ),
  .al_fusion                 (ifu_fusion             ),
  .al_pd_fu                  (ifu_pd_fu              ),
  .al_bus_err                (ifu_bus_err            ),

  .ifu_restart               (fch_restart            ),
  .ifu_target                (fch_target             ),
  .rst_a                     (rst_a                  )
);

//////////////////////////////////////////////////////////////////////////////
//
// IFU exceptions
//
//////////////////////////////////////////////////////////////////////////////


always @*
begin : ifu_excp_PROC
  // IFU exceptions
  //
  ifu_exception = {`IFU_EXCP_WIDTH{1'b0}};
  
  ifu_exception[`IFU_EXCP_PMP_FAULT] = 1'b0
                                | al_pmp_viol
                                | al_pma_viol
                                ;  

  ifu_exception[`IFU_EXCP_ECC] = 1'b0
                            | ifu_ecc_err
                           ;


  ifu_exception[`IFU_EXCP_BREAK] = 1'b0
                            | ifu_trig_trap
                            ;

  ifu_exception[`IFU_EXCP_BUS]   = 1'b0
                            | ifu_bus_err
                            ;
end


assign fetch_iccm_hole = f1_mem_target_r[3];
assign f1_mem_target   = f1_mem_target_r[2:0];

endmodule // rl_ifu


