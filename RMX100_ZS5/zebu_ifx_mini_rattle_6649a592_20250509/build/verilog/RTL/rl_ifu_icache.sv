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

// Set simulation timescale
//
`include "const.def"

module rl_ifu_icache (
  ////////// Interface with the Fetch Target Buffer (F0) ////////////////////////
  //
  input                             fa0_req,                   // Fetch request from FTB
  input      [`IFU_ADDR_RANGE]      fa0_addr,                  // Fetch block addr (4 byte aligned)

  input                             fetch_iccm_hole,           // Uncached Access to ICCM0 Hole
  input                             f1_mem_target_mispred,

  ////////// F1 stage interface //////////////////////////////////////////////////
  //
  output reg [1:0]                  ic_f1_id_out_valid_r,      // Inform ID ctrl (data valid)
  
  output reg [`IC_DATA_RANGE]       ic_f1_data0,               // 32-bit data for addr0
  output reg [1:0]                  ic_f1_data_valid,          // IC data is valid {bank1, bank0}
  output reg [1:0]                  ic_f1_data_err,            // IC error for {addr1, addr0}
  input      [1:0]                  ic_f1_data_fwd,            // Critical Word Data Forwarded to Align stage
  output reg                        ic_f1_bus_err,             // Bus Error for Un-Cached/Cached access fetch
  input                             fch_same_pc,

  /////////// I-CACHE CMO/CBO /////////////////////
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

  input                             arcv_icache_op_init,       // Initiate Cache Maintenance Operation
  input     [`ARCV_MC_CTL_RANGE]    arcv_mcache_ctl,           // I-Cache CSR Control
  input     [`ARCV_MC_OP_RANGE]     arcv_mcache_op,            // I-Cache CSR Op Type
  input     [`ARCV_MC_ADDR_RANGE]   arcv_mcache_addr,          // I-Cache CSR Op Address
  input     [`ARCV_MC_LN_RANGE]     arcv_mcache_lines,         // I-Cache Op Number of Lines
  input     [`DATA_RANGE]           arcv_mcache_data,          // I-Cache Op Data to be written 

  output                            arcv_icache_op_done,            // I-Cache Operation Complete
  output    [`DATA_RANGE]           arcv_icache_data,               // I-Cache TAG/DATA 
  output                            arcv_icache_op_in_progress,

  ////////// FENCEI I$ Invalidate interface ///////////////////////////
  //
  input                             spc_fence_i_inv_req,   // Invalidate request to IFU
  output                            spc_fence_i_inv_ack,   // Acknowledgement that Invalidation is complete

  ////////// IC status ///////////////////////////////////////////////////////////
  //
  output reg                        ic_idle,                   // IC is idle
  output reg                        ic_idle_ack, 

  input                             ftb_idle,                  // FTB is pushed to IDLE no more fetching 

  output reg                        hpm_bicmstall,
  output                            hpm_icm,

  input  [7:0]                      arcv_mecc_diag_ecc,
  ////////// IC exception ///////////////////////////////////////////////////////////
  output                            ic_tag_ecc_wr,
  output                            ic_tag_ecc_excpn,
  output     [`IC_TAG_ECC_RANGE]    ic_tag_ecc_out,
  output                            ic_data_ecc_wr,
  output                            ic_data_ecc_excpn,
  output     [`IC_DATA_ECC_RANGE]   ic_data_ecc_out,

  ////////// SRAM IC TAG interface /////////////////////////////////////////////////////
  //
  output                            ic_tag_mem_clk,
  output     [`IC_TAG_SET_RANGE]    ic_tag_mem_din,
  output reg [`IC_IDX_RANGE]        ic_tag_mem_addr,
  output reg                        ic_tag_mem_cs,
  output reg                        ic_tag_mem_we,
  output     [`IC_TAG_SET_RANGE]    ic_tag_mem_wem,
  input      [`IC_TAG_SET_RANGE]    ic_tag_mem_dout,

  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  //
  output                            ic_data_mem_clk,
  output     [`IC_DATA_SET_RANGE]   ic_data_mem_din,
  output reg [`IC_DATA_ADR_RANGE]   ic_data_mem_addr,
  output reg                        ic_data_mem_cs,
  output reg                        ic_data_mem_we,
  output     [`IC_DATA_SET_RANGE]   ic_data_mem_wem,
  input      [`IC_DATA_SET_RANGE]   ic_data_mem_dout,

  ////////// IC Refill Interface /////////////////////////////////////////////////
  //
  output                            ifu_cmd_valid, 
  output     [3:0]                  ifu_cmd_cache, 
  output     [`IC_WRD_RANGE]        ifu_cmd_burst_size,                
  output                            ifu_cmd_read,                
  output                            ifu_cmd_aux,                
  input                             ifu_cmd_accept,              
  output     [`ADDR_RANGE]          ifu_cmd_addr,                       
  output                            ifu_cmd_excl,
  output                            ifu_cmd_wrap,
  output     [5:0]                  ifu_cmd_atomic,
  output     [2:0]                  ifu_cmd_data_size,                
  output     [1:0]                  ifu_cmd_prot,                

  input                             ifu_rd_valid,              
  input                             ifu_rd_err,              
  // spyglass disable_block W240
  // SMD: An input has been declared but is not read
  // SJ: Part of the ibp protocol, not needed to be used in the current implementation
  input                             ifu_rd_excl_ok,
  // spyglass enable_block W240
  input                             ifu_rd_last,               
  output                            ifu_rd_accept,             
  input  [31:0]                     ifu_rd_data,     



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

  output reg                                    rf_reset_done_r,
  output                                        ifu_fch_vec,

  ////////// General input signals ///////////////////////////////////////////////
  //
  input [1:0]                       priv_level,                // User Mode/Machine Mode
  input                             fch_restart,               // Pipeline Restart
  input                             fch_restart_vec,           // Pipeline Restart
  input                             br_req_ifu,                // Branch
  input                             clk,                       // clock signal
  input                             rst_init_disable_r,        // Disabe initialization upon reset
  input                             sr_dbg_cache_rst_disable,
  input                             rst_a                      // reset signal

);

// -------------------------------------------------
// Local Declaration
//

wire [`IFU_ADDR_RANGE] fa1_addr;      // Next Fetch block addr (4 byte aligned) for uncached transfer
wire                ic_op_inv_all;
wire                ic_op_adr_inv;
wire                ic_op_adr_lock;
wire                ic_op_adr_unlock;
wire                ic_op_idx_inv;
wire                ic_op_idx_rd_tag;
wire                ic_op_idx_rd_data;
wire                ic_op_idx_wr_tag;
wire                ic_op_idx_wr_data;
wire                ic_op_prefetch;
wire [`DATA_RANGE]  ic_icmo_adr;
wire [`DATA_RANGE]  ic_op_wr_data;
wire [`DATA_RANGE]  ic_op_rd_data;
wire                continue_unc_transfer;





//
wire                        fch_same_pc_nxt;
reg                         fch_same_pc_r;
reg                         fa0_req_r;
reg   [`IFU_ADDR_RANGE]     fa0_addr_r;
wire                        fa_valid_next;
reg                         fa_valid_r;

reg   [`IC_DRAM_RANGE]      ic_data_hit_q; 
wire  [`IC_WAY_RANGE]       ic_way_sel_hot;   // I-cache way selection
reg   [`IC_DATA_RANGE]      ic_data_din_q;  

reg   [`IC_TRAM_DATA_RANGE] ic_tag_din_q;   

reg   [`IC_IDX_RANGE]       ic_tag_addr;    // Address to tag RAM
reg                         cmd_issued_r;

wire                        rf_it_read;
wire                        rf_req_it;
wire                        rf_it_cs;
wire  [`IC_IDX_RANGE]       rf_it_addr;
wire                        rf_it_valid;
wire                        rf_it_lock;
wire  [`IC_TAG_TAG_RANGE]   rf_it_tag;
wire  [`IC_TRAM_DATA_RANGE] ic_ctl_tag;
wire  [`DATA_RANGE]         ic_ctl_data;
wire                        ic_ctl_tag_sel_w0;
wire                        ic_ctl_tag_sel_w1;
wire                        ic_ctl_data_sel_w0;
wire                        ic_ctl_data_sel_w1;

wire                        rf_req_id;
wire                        rf_id_read;
wire                        rf_id_cs;
wire  [`IC_DATA_ADR_RANGE]  rf_id_addr;
wire  [`IC_DATA_RANGE]      rf_id_data;
wire  [`IC_WAY_RANGE]       rf_way_hot;
wire                        rf_done;    // registered rf_done signal
wire                        rf_op_done; // Unregistered rf_done signal
wire                        rf_err;
wire                        kill_ic_op_r;
wire  [`IC_WAY_RANGE]       ic_it_lock_way_hot;
wire  [`IC_WAY_RANGE]       ic_ctl_lock_way_hot;
wire  [`IC_WAY_RANGE]       ic_it_way_hot;
wire  [`IC_WAY_RANGE]       ic_ctl_way_hot;
wire  [`IC_WAY_RANGE]       ic_hit_way_hot_qual;

wire  [`IC_WAY_RANGE]       ic_candidates_way_hot;

reg                         ic_inst_done_r;
reg                         ic_way0_enable_next;
reg                         ic_way0_enable;
reg                         ic_active0;
reg                         ic_way1_enable_next;
reg                         ic_way1_enable;
reg                         ic_active1;

wire                        ic_init;

reg                         ic_rf_req;
reg   [`IC_WAY_RANGE]       ic_rf_way_hot;
reg   [`IC_WAY_RANGE]       ic_rf_way_hot_r;
reg                         ic_rf_unc;
reg                         ic_rf_unc_r;
reg   [`IFU_ADDR_RANGE]     ic_rf_addr;
reg   [`IFU_ADDR_RANGE]     ic_rf_addr_r;
reg   [`IFU_ADDR_RANGE]     ic_rf_addr_next;
wire                        ic_rf_kill;

reg   [2:0]                 ic_state;
reg   [2:0]                 ic_state_next;
reg                         ic_prev_state_is_unc;
wire                        ignore_ic_data;

reg                         ic_ctl_unc_next;
reg                         ic_mem_err_next;
reg                         ic_mem_err;
reg                         ic_unc_wait_timeout;
reg                         ic_unc_wait_timeout_r;
reg                         ifu_cmd_wrap_r;


// -- Way replacement counter for pseudo-random replacement
//    (rotated bit pattern on completion of servicing a cache miss)
reg                         ic_victim_way_enb;
reg   [`IC_WAY_RANGE]       ic_victim_way_hot;
reg   [`IC_WAY_RANGE]       ic_victim_way_hot_next;


reg   [`IC_WAY_RANGE]       ic_replacement_way_hot;

reg   [`IC_WAYS-1:0]        saved_hit_way_hot_r;
reg   [`IC_WAYS-1:0]        saved_hit_way_hot_nxt;
reg                         same_block;
reg                         fa1_is_in_same_ic_block;

reg                         ic_hands_off_tag;
reg   [`IC_WAYS-1:0]        ic_hands_off_data;
wire  [`IC_WAY_RANGE]       ic_it_valid_way_hot;   // ICACHE WAY is valid
wire  [`IC_WAY_RANGE]       ic_it_locked_ways;

wire  [`IC_WAY_RANGE]       ic_ctl_valid_way_hot;   // ICACHE WAY is valid
wire  [`IC_WAY_RANGE]       ic_ctl_locked_ways;
wire  [`IC_WAY_RANGE]       ic_ctl_way_hot_enb;

wire                        ic_ctl_cache;
wire                        ic_ctl_op;
reg                         ic_ctl_cache_r;
reg                         fa_refill_r;
wire                        rf_reset_done;

wire                        ic_disabled;
wire                        ic_disabled_r;
wire                        ic_hit;           // I-cache hit
wire                        ic_hit_p;
reg                         ic_ecc_hit_r;           // I-cache hit
reg                         ic_f1_data_valid_r;
wire                        ic_ecc_hit;           // I-cache hit
wire                        ic_ecc_hit_p;
wire [`IC_WAY_RANGE]        ic_ecc_hit_way_hot;   // I-cache hit way
wire  [`IC_WAY_RANGE]       ic_ecc_hit_way_hot_qual;
wire [`IC_WAY_RANGE]        ic_ctl_hit_way_hot;   // I-cache hit way
wire [`IC_WAY_RANGE]        ic_hit_way_hot;   // I-cache hit way
reg  [`IC_DRAM_RANGE]       ic_data_hit;

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Auxiliary registers, next state, select and write enable signals       //
//                                                                        //
//lWith a few exceptions, all auxiliary registers are dealt with in a     //
// regular form. For each aux reg, there are a number of flip-flops       //
// to hold the required bits, a next state wire or reg signal that has    //
// the updating value, a select signal decoded from the 12-bit base aux   //
// address on a pending SR op, and a write enable signal that allows      //
// the update to the register content.                                    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

wire                          rf_ic_cache_instr_done;

wire                          ic_ctl_ivic;
wire                          ic_ctl_ivil;
wire                          ic_ctl_lil;
wire                          ic_ctl_ulil;
wire                          ic_ctl_idx_ivil;
wire                          ic_ctl_idx_rd_tag;
wire                          ic_ctl_idx_rd_data;
wire                          ic_ctl_idx_wr_tag;
wire                          ic_ctl_idx_wr_data;
wire                          ic_ctl_prefetch;
wire                          ic_csr_op_init; // M-Cache Initiated Op is started by I-Cache module

wire    [5:0]                 aux_ic_ctrl_r;
reg                           aux_ic_ctrl_31_r;     // bit 31 of IC_CTRL aux reg

wire                          aux_ic_ctrl_wen;
wire                          aux_ic_ivic_wen;
wire                          aux_ic_ivil_wen;
wire                          aux_ic_lil_wen;
wire                          aux_ic_ivic_sel;
wire                          aux_ic_ivil_sel;
wire                          aux_ic_lil_sel;

wire                          ic_ctl_read_cache;
wire                          ic_ctl_write_tag;
wire                          ic_ctl_write_data;

reg                           aux_ic_ram_addr_wen;
reg                           aux_ic_tag_wen;
reg                           aux_ic_data_wen;

wire    [31:0]                aux_ic_ram_addr_r;
wire    [`IC_TAG_TAG_RANGE]   aux_ic_tag_tag_r;
reg     [`IC_IDX_RANGE]       aux_ic_tag_index_r;
wire                          aux_ic_tag_lock_r;
wire                          aux_ic_tag_valid_r;
wire   [`IC_DRAM_RANGE]       aux_ic_data_r;
reg                           ic_pc_sel_nxt;
reg                           ic_pc_sel_r;
reg                           ic_rf_done;
wire                          ic_rf_ack;
reg                           ic_ctl_cache_inst;

wire    [`DATA_RANGE]         aux_ic_endr_nxt;
reg     [`DATA_RANGE]         aux_ic_endr_r;
reg                           aux_ic_ivir_wen;
reg                           aux_ic_endr_wen;
reg                           aux_ic_ivir_sel;
reg                           aux_ic_endr_sel;

reg                           valid_saved;
wire                          maybe_ic_restart;
reg                           ic_busy;
wire                          fa_ic_rf_req;
reg                           ic_rf_in_progress_nxt;
reg                           ic_rf_in_progress_r;
wire                          dis_ic_rf_ic_on_fch_br_req;
wire                          dis_ic_rf_ic_on_fch_br_req_misp;
reg                           ic_ctl_unc;
reg                           fch_br_restart_in_ic_rf_nxt;
reg                           fch_br_restart_in_ic_rf_r;

reg                           fch_br_restart_misp_in_ic_rf_nxt;
reg                           fch_br_restart_misp_in_ic_rf_r;
reg                           fch_br_restart_misp_nxt;
reg                           fch_br_restart_misp_r;
// Critical Word First
reg                           cwf_nxt;
reg                           cwf_r;
reg  [31:0]                   cwf_data_nxt;
reg  [31:0]                   cwf_data_r;
reg                           cwf_valid_nxt;
reg                           cwf_valid_r;
wire                          ignore_cwf;
reg                           ignore_cwf_r;

 reg     ic_way_enable0;
 reg     ic_way_enable1;

reg [`IC_DATA_RANGE]         ic_f1_data0_nxt;               // 32-bit data for addr0
reg                          ic_f1_data_valid_nxt;          // IC data is valid {bank1, bank0}
reg                          ic_f1_data_err_nxt;            // IC error for {addr1, addr0}
reg                          ic_f1_data_err_r;            // IC error for {addr1, addr0}
reg                          ic_f1_id_out_valid_nxt;        // IC data is valid {bank1, bank0}


  wire                            ic_tag_cs_odd_set;
  wire                            ic_tag_wen;
  wire                            ic_data_wen;
  wire     [`IC_WAY_RANGE]        ic_data_wem_even_set;

  wire     [`IC_TRAM_RANGE]       ic_tag_din_w0;
  wire     [`IC_TRAM_RANGE]       ic_tag_dout_w0;
  wire                            ic_tag_mem_wem_w0;
  wire     [`IC_TRAM_RANGE]       ic_tag_din_w1;
  wire     [`IC_TRAM_RANGE]       ic_tag_dout_w1;
  wire                            ic_tag_mem_wem_w1;

  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  //
  wire                            ic_data_mem_wem_w0;
  wire     [`IC_DRAM_RANGE]       ic_data_dout_w0;
  ////////// SRAM IC DATA interface ////////////////////////////////////////////
  //
  wire                            ic_data_mem_wem_w1;
  wire     [`IC_DRAM_RANGE]       ic_data_dout_w1;
  reg                             ibp_bus_err_r;
  reg                             ibp_bus_err_nxt;
  wire                            spc_op_in_prg;
  reg                             ifu_cmd_prot_r;
  wire                            rf_cmd_accept_r;
  wire                            rf_rd_accept;
  reg                             ifu_rd_accept_wait;
  wire     [`ADDR_RANGE]          rf_cmd_address;
  wire     [`ADDR_RANGE]          rf_cmd_addr_r;
  wire                            cwf_fa_match;
  reg                             ignore_refill_r;
  reg                             ignore_refill_nxt;
  reg                             fch_restart_vec_r;

  wire                            ic_ecc_fa0_err;


reg                           ic_tag_cs_r                   ;
reg                           ic_data_cs_r                  ;
reg                           ic_data_ecc_fa0_err           ;
wire [`IC_DATA_ECC_RANGE]     ic_ecc_data_din0              ;
wire [`IC_DATA_ECC_RANGE]     ic_ecc_data_din0_tmp          ;
wire [`IC_TAG_ECC_RANGE]      ic_ecc_tag_din                ;
wire [`IC_TAG_ECC_RANGE]      ic_ecc_tag_din_tmp            ;
wire                          ic_tag_addr_even_cg           ;
wire                          ic_tag_addr_cg                ;
wire                          ic_data_addr_cg               ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_tag_sb_p            ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_tag_db_p            ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_data_sb_p           ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_data_db_p           ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_data_sb_p_tmp       ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_data_db_p_tmp       ;
wire                          ic_ecc_en                     ;
wire                          ic_ecc_db_excpn_en            ;
wire                          ic_ecc_dbsb_excpn_en          ;
wire                          ic_data_vld_sel               ;
wire [`IC_WAYS-1 : 0]         ic_ecc_sb_err_tmp             ;
wire [`IC_WAYS-1 : 0]         ic_ecc_db_err_tmp             ;
wire [`IC_WAYS-1 : 0]         ic_data_ecc_sb_err_rd         ;
wire [`IC_WAYS-1 : 0]         ic_data_ecc_db_err_rd         ;
wire [`IC_WAYS-1 : 0]         ic_data_ecc_adr_err_rd        ;
wire [`IC_WAYS-1 : 0]         ic_data_ecc_sb_err_tmp        ;
wire [`IC_WAYS-1 : 0]         ic_data_ecc_db_err_tmp        ;
wire [`IC_WAYS-1 : 0]         ic_data_ecc_adr_err_tmp       ;
wire                          ic_tag_err                    ;
wire [`IC_WAYS-1 : 0]         ic_tag_err_ways               ;
wire [`IC_WAYS-1 : 0]         ic_data_err                   ;
wire [`IC_WAYS-1 : 0]         ic_tag_ecc_sb_err_tmp         ;
wire [`IC_WAYS-1 : 0]         ic_tag_ecc_db_err_tmp         ;
wire [`IC_WAYS-1 : 0]         ic_tag_ecc_adr_err_tmp        ;

reg  [`IC_DATA_ADR_RANGE]     ic_data_addr_r                ;
wire [`IC_DATA_ADR_RANGE]     ic_data_addr_nxt              ;
reg  [`IC_IDX_RANGE]          ic_tag_addr_nxt               ;
reg  [`IC_IDX_RANGE]          ic_tag_addr_r                 ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_data_addr_p         ;
wire [`IC_WAYS-1 : 0]         fa_ic_ecc_tag_addr_p          ;

wire [`IC_TRAM_DATA_RANGE]    ic_fetch_tag_correct0        ; // unused
wire [`IC_TAG_SYNDROME_RANGE] fa_ic_tag_syndrome0          ;
wire [`IC_TAG_SYNDROME_RANGE] fa_ic_tag_syndrome_tmp0      ;
wire [`IC_TAG_ECC_RANGE]      ic_tag_ecc_out0              ;
wire [`IC_SYNDROME_RANGE]     ic_data_syndrome_p_tmp0      ;
wire [`IC_DATA_ECC_RANGE]     ic_data_ecc_out0             ;
reg  [`IC_SYNDROME_RANGE]     ic_data_syndrome_p0          ;
wire [`IC_TRAM_DATA_RANGE]    ic_fetch_tag_correct1        ; // unused
wire [`IC_TAG_SYNDROME_RANGE] fa_ic_tag_syndrome1          ;
wire [`IC_TAG_SYNDROME_RANGE] fa_ic_tag_syndrome_tmp1      ;
wire [`IC_TAG_ECC_RANGE]      ic_tag_ecc_out1              ;
wire [`IC_SYNDROME_RANGE]     ic_data_syndrome_p_tmp1      ;
wire [`IC_DATA_ECC_RANGE]     ic_data_ecc_out1             ;
reg  [`IC_SYNDROME_RANGE]     ic_data_syndrome_p1          ;
reg   [`IC_DATA_ADR_RANGE]    ic_data_ecc_addr_t            ;
reg                           ic_data_addr_sel              ;
wire  [`IC_IDX_RANGE]         ic_tag_ecc_wr_addr            ;
wire  [`IC_DATA_ADR_RANGE]    ic_data_ecc_wr_addr           ;
wire  [10:0]            rf_data_counter               ;
wire  [`IC_IDX_RANGE]         rf_ic_counter                 ;

assign ic_data_ecc_wr_addr = ic_init                               ? rf_data_counter :
                             (ic_ctl_idx_wr_data & (~fa_refill_r)) ? ic_icmo_adr[`IC_DATA_ADR_RANGE]:
                             (ic_ctl_cache_inst)                   ? {ic_icmo_adr[`IC_SET_IDX_RANGE],
                                                                      rf_data_counter[`IC_WRD_WIDTH-1:0]}:
                                                                     {ic_rf_addr_r[`IC_SET_IDX_RANGE],
                                                                      rf_data_counter[`IC_WRD_WIDTH-1:0]};
// ECC encoder instance for I$ data memory
ic_data_ecc_encoder u_ic_data_ecc_encoder (
                    .data_in        (ic_data_din_q       ),
                    .address        (ic_data_ecc_wr_addr ),
                    .ecc            (ic_ecc_data_din0_tmp)
                );
assign  ic_ecc_data_din0 = arcv_mcache_ctl[`IC_ECC_RW] ? arcv_mecc_diag_ecc[`IC_SYNDROME_WIDTH:0] : ic_ecc_data_din0_tmp;



assign ic_tag_addr_cg   = 1'b0
                        | ((ic_tag_mem_cs) & (~ic_tag_mem_we))
                        ;

assign ic_data_addr_cg  = 1'b0
                        | ((ic_data_mem_cs) & (~ic_data_mem_we))
                        ;

assign ic_tag_addr_nxt      = ic_tag_addr_cg ? ic_tag_addr : ic_tag_addr_r ;
assign ic_data_addr_nxt     = ic_data_addr_cg ? ic_data_mem_addr : ic_data_addr_r    ;

always@(posedge clk or posedge rst_a)
begin: icache_addr_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_tag_addr_r      <= `IC_IDX_WIDTH'b0;
    ic_data_addr_r     <= `IC_DATA_ADR_WIDTH'b0;
  end
  else 
  begin
    ic_tag_addr_r      <= ic_tag_addr_nxt; 
    ic_data_addr_r     <= ic_data_addr_nxt; 
  end
end

assign ic_tag_ecc_wr_addr = ( (|ic_ecc_sb_err_tmp) | (|ic_ecc_db_err_tmp) ) ? fa0_addr_r[`IC_IDX_RANGE] :
                            ic_init           ? rf_ic_counter :
                            ic_ctl_cache_inst ? ic_icmo_adr[`IC_IDX_RANGE] :
                                                ic_rf_addr_r[`IC_IDX_RANGE];
// ECC encoder instance for I$ tag memory
ic_tag_ecc_encoder u_ic_tag_encoder (
   .data_in      (ic_tag_din_q),
   .address      (ic_tag_ecc_wr_addr),
   .ecc          (ic_ecc_tag_din_tmp)
);
assign  ic_ecc_tag_din = arcv_mcache_ctl[`IC_ECC_RW] ? arcv_mecc_diag_ecc[`IC_TAG_SYNDROME_WIDTH:0] : ic_ecc_tag_din_tmp;

assign ic_ecc_db_excpn_en   = (arcv_mcache_ctl[`IC_ECC_CTL_RANGE] == `IC_EN_EXCPN_DB);
assign ic_ecc_dbsb_excpn_en = (arcv_mcache_ctl[`IC_ECC_CTL_RANGE] == `IC_EN_EXCPN_SB_DB);
assign ic_ecc_en =  ic_ecc_db_excpn_en | ic_ecc_dbsb_excpn_en;

// ECC decoder instances for I$ tag memory
ic_tag_ecc_decoder u_ic_tag_ecc_decoder0 (
   .enable              (ic_ecc_en                           ),
   .data_in             (ic_tag_dout_w0[`IC_TRAM_DATA_RANGE]),
   .address             (ic_tag_addr_r                       ),
   .addr_err            (fa_ic_ecc_tag_addr_p[0]            ),
   .syndrome            (fa_ic_tag_syndrome_tmp0            ),
   .ecc_in              (ic_tag_dout_w0[`IC_TAG_ECC_RANGE]  ),
   // spyglass disable_block UnloadedOutTerm-ML
   // SMD: Unloaded but driven output terminal of an instance detected
   // SJ : Unused, just a placeholder
   .data_out            (ic_fetch_tag_correct0              ),
   // spyglass enable_block UnloadedOutTerm-ML
   .ecc_out             (ic_tag_ecc_out0                    ),
   .single_err          (fa_ic_ecc_tag_sb_p[0]              ),
   .double_err          (fa_ic_ecc_tag_db_p[0]              )
);
ic_tag_ecc_decoder u_ic_tag_ecc_decoder1 (
   .enable              (ic_ecc_en                           ),
   .data_in             (ic_tag_dout_w1[`IC_TRAM_DATA_RANGE]),
   .address             (ic_tag_addr_r                       ),
   .addr_err            (fa_ic_ecc_tag_addr_p[1]            ),
   .syndrome            (fa_ic_tag_syndrome_tmp1            ),
   .ecc_in              (ic_tag_dout_w1[`IC_TAG_ECC_RANGE]  ),
   // spyglass disable_block UnloadedOutTerm-ML
   // SMD: Unloaded but driven output terminal of an instance detected
   // SJ : Unused, just a placeholder
   .data_out            (ic_fetch_tag_correct1              ),
   // spyglass enable_block UnloadedOutTerm-ML
   .ecc_out             (ic_tag_ecc_out1                    ),
   .single_err          (fa_ic_ecc_tag_sb_p[1]              ),
   .double_err          (fa_ic_ecc_tag_db_p[1]              )
);


ic_data_ecc_decoder u_ic_data_ecc_decoder0 (
   .enable              (ic_ecc_en                           ),
   .data_in             (ic_data_dout_w0[`IC_DATA_RANGE]    ),
   .syndrome            (ic_data_syndrome_p_tmp0            ),
   .address             (ic_data_addr_r                      ),
   .addr_err            (fa_ic_ecc_data_addr_p[0]           ),
   .ecc_in              (ic_data_dout_w0[`IC_DATA_ECC_RANGE]),
   // spyglass disable_block UnloadedOutTerm-ML
   // SMD: Unloaded but driven output terminal of an instance detected
   // SJ : Unused, just a placeholder
   .data_out            (                                        ),
   // spyglass enable_block UnloadedOutTerm-ML
   .ecc_out             (ic_data_ecc_out0                       ),
   .single_err          (fa_ic_ecc_data_sb_p_tmp[0]             ),
   .double_err          (fa_ic_ecc_data_db_p_tmp[0]             )
);


ic_data_ecc_decoder u_ic_data_ecc_decoder1 (
   .enable              (ic_ecc_en                           ),
   .data_in             (ic_data_dout_w1[`IC_DATA_RANGE]    ),
   .syndrome            (ic_data_syndrome_p_tmp1            ),
   .address             (ic_data_addr_r                      ),
   .addr_err            (fa_ic_ecc_data_addr_p[1]           ),
   .ecc_in              (ic_data_dout_w1[`IC_DATA_ECC_RANGE]),
   // spyglass disable_block UnloadedOutTerm-ML
   // SMD: Unloaded but driven output terminal of an instance detected
   // SJ : Unused, just a placeholder
   .data_out            (                                        ),
   // spyglass enable_block UnloadedOutTerm-ML
   .ecc_out             (ic_data_ecc_out1                       ),
   .single_err          (fa_ic_ecc_data_sb_p_tmp[1]             ),
   .double_err          (fa_ic_ecc_data_db_p_tmp[1]             )
);


// Register chip select of the memory as a validating signals for the ecc errors.
always@(posedge clk or posedge rst_a)
begin: icache_data_cs_reg_PROC
  if (rst_a == 1'b1)
  begin
    ic_tag_cs_r      <= 1'b0;
    ic_data_cs_r     <= 1'b0;
  end
  else
  begin
    ic_tag_cs_r      <= ic_tag_addr_cg; 
    ic_data_cs_r     <= ic_data_addr_cg;
  end
end

assign ic_ecc_sb_err_tmp = ic_tag_ecc_sb_err_tmp | ic_data_ecc_sb_err_tmp ;

assign ic_ecc_db_err_tmp = ic_tag_ecc_db_err_tmp | ic_data_ecc_db_err_tmp 
                           | ic_tag_ecc_adr_err_tmp
                           | ic_data_ecc_adr_err_tmp
                           ;

assign ic_tag_ecc_sb_err_tmp = (({`IC_WAYS{ic_tag_cs_r}} & fa_ic_ecc_tag_sb_p)) ;
assign ic_tag_ecc_db_err_tmp = ({`IC_WAYS{ic_tag_cs_r}} & fa_ic_ecc_tag_db_p);
assign ic_tag_ecc_adr_err_tmp = ({`IC_WAYS{ic_tag_cs_r}} & fa_ic_ecc_tag_addr_p);
assign fa_ic_tag_syndrome0 = ({`IC_TAG_SYNDROME_WIDTH{ic_tag_cs_r}} & (fa_ic_tag_syndrome_tmp0));
assign fa_ic_tag_syndrome1 = ({`IC_TAG_SYNDROME_WIDTH{ic_tag_cs_r}} & (fa_ic_tag_syndrome_tmp1));

assign ic_data_vld_sel        = 1'b1;
assign ic_data_ecc_sb_err_rd  = {`IC_WAYS{ic_data_cs_r}} & fa_ic_ecc_data_sb_p_tmp & {`IC_WAYS{ic_data_vld_sel}};
assign ic_data_ecc_db_err_rd  = {`IC_WAYS{ic_data_cs_r}} & fa_ic_ecc_data_db_p_tmp;
assign ic_data_ecc_adr_err_rd  = {`IC_WAYS{ic_data_cs_r}} & fa_ic_ecc_data_addr_p;
assign ic_data_ecc_sb_err_tmp = ic_data_ecc_sb_err_rd & ic_ecc_hit_way_hot_qual;
assign ic_data_ecc_db_err_tmp = ic_data_ecc_db_err_rd & ic_ecc_hit_way_hot_qual;
assign ic_data_ecc_adr_err_tmp = ic_data_ecc_adr_err_rd & ic_ecc_hit_way_hot_qual;

assign ic_tag_err_ways = ( {`IC_WAYS{ic_ecc_en}} & ((ic_tag_ecc_sb_err_tmp | ic_tag_ecc_db_err_tmp
                               | ic_tag_ecc_adr_err_tmp
                               ) & (~ic_hit_way_hot_qual)));
assign ic_tag_err = |ic_tag_err_ways;

assign ic_data_err = (({`IC_WAYS{ic_ecc_dbsb_excpn_en}} & ic_data_ecc_sb_err_tmp) | ({`IC_WAYS{ic_ecc_en}} & (ic_data_ecc_db_err_tmp
                               | ic_data_ecc_adr_err_tmp)));
always@*
begin
  ic_data_ecc_fa0_err   = (|ic_data_err);
  ic_data_syndrome_p0 = ({`IC_SYNDROME_WIDTH{ic_data_cs_r}} & (ic_data_syndrome_p_tmp0));
  ic_data_syndrome_p1 = ({`IC_SYNDROME_WIDTH{ic_data_cs_r}} & (ic_data_syndrome_p_tmp1));
  ic_data_addr_sel      = |ic_data_err ? 1'b1 : 1'b0;
  ic_data_ecc_addr_t    = ic_data_addr_r; 
end

assign ic_ecc_fa0_err = ic_data_ecc_fa0_err | ic_tag_err;


////////////////////////////////////////////////////////////////////////////
always@*
  begin
    ic_f1_data0_nxt        = ic_data_hit_q[`DATA_RANGE]; 
    ic_f1_data_err_nxt     = 1'b0; 
    ic_f1_data_valid_nxt   = 1'b0; 
    ic_f1_id_out_valid_nxt = 1'b0;
    ic_f1_bus_err          = 1'b0;
    hpm_bicmstall          = 1'b0;
    if (fa0_req_r == 1'b0)
      begin
        ic_f1_data_valid_nxt   = 1'b0;
        ic_f1_id_out_valid_nxt = 1'b0;
      end
    else if ((ic_ctl_unc) & ((ic_state == 3'b100) | (ic_state == 3'b101)) & cwf_valid_r)
      begin
        if (fch_br_restart_misp_in_ic_rf_r == 1'b0)
          begin
            ic_f1_data_valid_nxt   = 1'b1;
            ic_f1_id_out_valid_nxt = 1'b1;
            ic_f1_data0_nxt        = cwf_data_r;
            ic_f1_bus_err          = ibp_bus_err_r;
          end
      end
    else if ((~ic_ctl_unc) & (ic_rf_in_progress_r))
      begin
        hpm_bicmstall          = 1'b1;
        ic_f1_data_valid_nxt   = 1'b0;
        ic_f1_id_out_valid_nxt = 1'b0;
        ic_f1_bus_err          = ibp_bus_err_r;
        if ((cwf_valid_r == 1'b1) & (ignore_cwf_r == 1'b1) & (~fch_br_restart_misp_in_ic_rf_r))
          begin
            hpm_bicmstall          = 1'b0;
            ic_f1_data_valid_nxt   = 1'b1;
            ic_f1_id_out_valid_nxt = 1'b1;
            ic_f1_data0_nxt        = cwf_data_r;
          end
      end
    else if ((ic_hit == 1'b1) | (ic_ecc_hit == 1'b1) | ic_ecc_fa0_err)
      begin
        ic_f1_data_valid_nxt   = 1'b1;
        ic_f1_id_out_valid_nxt = 1'b1;
        ic_f1_data_err_nxt     = ic_ecc_fa0_err; 
      end
  end

always@*
  begin
    ic_f1_data0          = ic_f1_data0_nxt; 
    ic_f1_data_valid     = {1'b0, ic_f1_data_valid_nxt}; 
    ic_f1_data_err[0]    = ic_f1_data_err_nxt | ic_f1_data_err_r;
    ic_f1_data_err[1]    = 1'b0; 
    ic_f1_id_out_valid_r = {1'b0, ic_f1_id_out_valid_nxt}; 
  end


////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// Asynchronous logic for selecting aux register values for LR and SR     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Victim way selection logic                                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always@(posedge clk or posedge rst_a)
  begin: ftb_reg_PROC 
    if (rst_a == 1'b1)
      begin
        fa0_req_r  <= 1'b0;
        fa0_addr_r <= `IFU_ADDR_BITS'b0; 
        fch_restart_vec_r <= 1'b0;
        ic_f1_data_err_r   <= 1'b0;
        ic_ecc_hit_r       <= 1'b0;
        ic_f1_data_valid_r <= 1'b0;
      end
    else
      begin
        fa0_req_r  <= fa0_req & (~ic_ctl_cache); 
        fch_restart_vec_r <= fch_restart_vec;
        ic_f1_data_err_r <= ic_f1_data_err_nxt;
        if (fa0_req == 1'b1)
          begin
            fa0_addr_r <= fa0_addr; 
          end
        if ((ic_f1_data_fwd[0]) | fch_restart | br_req_ifu 
            | f1_mem_target_mispred
            )
          begin
            ic_ecc_hit_r       <= 1'b0;
          end
        else if ((ic_hit == 1'b0) & (ic_disabled == 1'b0) & ((|ic_ecc_sb_err_tmp) | (|ic_ecc_db_err_tmp)) & (~ic_f1_data_fwd[0]))
          begin
            ic_ecc_hit_r       <= 1'b1;
            ic_f1_data_valid_r <= ic_f1_data_valid[0];
          end
      end
  end

assign ic_it_locked_ways     =  ic_it_valid_way_hot
                              & ic_it_lock_way_hot;

reg ic_read_r;
always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    ic_read_r <= 1'b0;
  end
  else
  begin
    ic_read_r <= ic_tag_mem_cs ? (~ic_tag_mem_we) : ic_read_r;
  end
end

assign ignore_ic_data = ((ic_prev_state_is_unc) & (~ic_disabled)) | ic_disabled | (~fa0_req_r); 

assign ic_candidates_way_hot = ~(ic_it_valid_way_hot);


always @*
begin : victim_way_PROC
  ic_victim_way_hot_next = {ic_victim_way_hot[`IC_WAY_MSB-1:0],
                            ic_victim_way_hot[`IC_WAY_MSB]};
end
assign ic_it_valid_way_hot[0] = ignore_ic_data ? 1'b0 : (ic_tag_dout_w0[`IC_TAG_VALID_BIT] & ic_read_r);
assign ic_it_lock_way_hot[0]  = ignore_ic_data ? 1'b0 : (ic_tag_dout_w0[`IC_TAG_LOCK_BIT]  & ic_read_r);
assign ic_it_valid_way_hot[1] = ignore_ic_data ? 1'b0 : (ic_tag_dout_w1[`IC_TAG_VALID_BIT] & ic_read_r);
assign ic_it_lock_way_hot[1]  = ignore_ic_data ? 1'b0 : (ic_tag_dout_w1[`IC_TAG_LOCK_BIT]  & ic_read_r);

assign ic_it_way_hot[0]       = (ic_tag_dout_w0[`IC_TAG_TAG_RANGE] == fa0_addr_r[`IC_TAG_RANGE]);
assign ic_it_way_hot[1]       = (ic_tag_dout_w1[`IC_TAG_TAG_RANGE] == fa0_addr_r[`IC_TAG_RANGE]);

wire ecc_err_fwd_w0;
wire ecc_err_fwd_w1;
assign ecc_err_fwd_w0 = (ic_ecc_db_err_tmp[0] | ic_tag_ecc_sb_err_tmp[0]);
assign ic_ecc_hit_way_hot[0]  = (ic_it_valid_way_hot[0] & ic_it_way_hot[0]);
assign ic_hit_way_hot[0]      = (ic_it_valid_way_hot[0] & ic_it_way_hot[0]
                                   & (~ic_ecc_sb_err_tmp[0]) & (~ic_ecc_db_err_tmp[0])
                                 );
assign ecc_err_fwd_w1 = (ic_ecc_db_err_tmp[1] | ic_tag_ecc_sb_err_tmp[1]);
assign ic_ecc_hit_way_hot[1]  = (ic_it_valid_way_hot[1] & ic_it_way_hot[1]);
assign ic_hit_way_hot[1]      = (ic_it_valid_way_hot[1] & ic_it_way_hot[1]
                                   & (~ic_ecc_sb_err_tmp[1]) & (~ic_ecc_db_err_tmp[1])
                                 );

assign ic_way_sel_hot[0]      = ic_hit_way_hot[0];
assign ic_way_sel_hot[1]      = ic_hit_way_hot[1];

assign ic_hit_way_hot_qual[0]     = (ic_hit_way_hot[0] & ic_way_enable0);
assign ic_ecc_hit_way_hot_qual[0] = (ic_ecc_hit_way_hot[0] & ic_way_enable0);
assign ic_hit_way_hot_qual[1]     = (ic_hit_way_hot[1] & ic_way_enable1);
assign ic_ecc_hit_way_hot_qual[1] = (ic_ecc_hit_way_hot[1] & ic_way_enable1);

assign ic_hit_p                = (| ic_hit_way_hot_qual);
wire [`IC_WAY_RANGE] ic_ecc_hit_fwd;
assign ic_ecc_hit_fwd[0] = (ic_ecc_hit_way_hot_qual[0] & ecc_err_fwd_w0);  
assign ic_ecc_hit_fwd[1] = (ic_ecc_hit_way_hot_qual[1] & ecc_err_fwd_w1);  
assign ic_ecc_hit_p            = (| ic_ecc_hit_fwd);
assign ic_hit                  = ((ic_hit_p) & (ic_state == 3'b000) & (ic_read_r) & (~ic_ctl_op)); // Check icache_hit only in case IC is not refilling
assign ic_ecc_hit              = ((ic_ecc_hit_p) & (ic_state == 3'b000) & (ic_read_r) & (~ic_ctl_op)); // Check icache_hit only in case IC is not refilling

assign ic_ctl_valid_way_hot[0] = ic_tag_dout_w0[`IC_TAG_VALID_BIT];
assign ic_ctl_valid_way_hot[1] = ic_tag_dout_w1[`IC_TAG_VALID_BIT];
assign ic_ctl_lock_way_hot[0]  = ic_tag_dout_w0[`IC_TAG_LOCK_BIT];
assign ic_ctl_lock_way_hot[1]  = ic_tag_dout_w1[`IC_TAG_LOCK_BIT];

assign ic_ctl_way_hot[0]       = (ic_tag_dout_w0[`IC_TAG_TAG_RANGE] == ic_icmo_adr[`IC_TAG_RANGE]);
assign ic_ctl_way_hot[1]       = (ic_tag_dout_w1[`IC_TAG_TAG_RANGE] == ic_icmo_adr[`IC_TAG_RANGE]);
assign ic_ctl_tag_sel_w0  = ~ic_icmo_adr[`IC_WAY_CACHE_MSB];
assign ic_ctl_tag_sel_w1  = ic_icmo_adr[`IC_WAY_CACHE_MSB];

assign ic_ctl_data_sel_w0   = ~ic_icmo_adr[`IC_WAY_CACHE_MSB];
assign ic_ctl_data_sel_w1   = ic_icmo_adr[`IC_WAY_CACHE_MSB];

assign ic_ctl_tag = `IC_TRAM_DATA_SIZE'b0
                    |({`IC_TRAM_DATA_SIZE{ic_ctl_tag_sel_w0}} & ic_tag_dout_w0[`IC_TRAM_DATA_RANGE])
                    |({`IC_TRAM_DATA_SIZE{ic_ctl_tag_sel_w1}} & ic_tag_dout_w1[`IC_TRAM_DATA_RANGE])
                    ;

assign ic_ctl_data = `IC_DATA_SIZE'b0
                     |({`IC_DATA_SIZE{ic_ctl_data_sel_w0}} & ic_data_dout_w0[`IC_DATA_RANGE])
                     |({`IC_DATA_SIZE{ic_ctl_data_sel_w1}} & ic_data_dout_w1[`IC_DATA_RANGE])
                     ;

assign ic_ctl_hit_way_hot[0]   = (ic_ctl_valid_way_hot[0] & ic_ctl_way_hot[0]);
assign ic_ctl_hit_way_hot[1]   = (ic_ctl_valid_way_hot[1] & ic_ctl_way_hot[1]);

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational logic to select the victim way to evict.                   //
//                                                                          //
// There are two prioritized rules for selecting the victim way:            //
//                                                                          //
//  1. If any Way at the selected index is not Valid, then choose the       //
//     lowest numbered invalid Way as the next replacement Way.             //
//  2. If all Ways at the selected index are Valid, then choose a victim    //
//     way using the pseudo-random ic_victim_way_hot variable.              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived as logic uses direct output of I-Cache Memory 
always @*
  begin : replacement_way_PROC
    // For a set-associative data cache the replacement way is chosen
    // to be any way that is not currently occupied, or if all ways are
    // occupied, then we select the way that is given by the pseudo-random
    // ic_victim_way_hot register
    if (| ic_it_locked_ways)
      begin
         ic_replacement_way_hot[0] = (~ic_it_locked_ways[0])
                                      ;
         ic_replacement_way_hot[1] = (~ic_it_locked_ways[1])
                                      & ic_it_locked_ways[0]
                                      ;
      end
    else if (| ic_candidates_way_hot)
      begin
         // There is at least one invalid way
         ic_replacement_way_hot[0] = ic_candidates_way_hot[0]
                                      ;
         ic_replacement_way_hot[1] = ic_candidates_way_hot[1]
                                      & !ic_candidates_way_hot[0]
                                      ;
      end
    else
      begin
        // chose the pseudo-random victim way as the replacement way
        ic_replacement_way_hot = ic_victim_way_hot_next;
      end
  end

//spyglass enable_block TA_09                                 

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Combinational logic to detect accesses to the same cache block as the    //
// previous hit, for power saving, optimized for medium speed.              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @*
begin : pwr_opt_PROC
  // We are guaranteed to be fetching the next word from within the same
  // I-cache block if 'same_block' is asserted. The equation yields true
  // provide all of the following six conditions are met:
  //
  //  1. The last word fetched was not the last one in the cache block
  //  2. There is no pending I-cache restart (which could be non-sequential)
  //  3. There is no possibility of an imposed restart from the pipeline
  //     front-end logic.
  //
  // There may be cases where these 3 conditions are not met, but where the
  // same cache block is actually accessed. However, these will be few in
  // number, so these 3 conditions capture the common behaviour and the
  // equation is designed to be 'conservative' and hence safe.

  same_block              = ((fa0_addr_r[4:2] != {3{1'b1}}) 
                            & (ic_busy == 1'b0)
                            & (~(fch_restart | br_req_ifu
                                 | f1_mem_target_mispred
                                )
                              & (~ic_ctl_cache_r)));
                            //& ~maybe_ic_restart;


  saved_hit_way_hot_nxt   = (fa_valid_r)
                            ? ic_hit_way_hot 
                            : saved_hit_way_hot_r;

  valid_saved             = |saved_hit_way_hot_nxt;

  ic_hands_off_tag        = same_block & valid_saved;

  ic_hands_off_data[0]  = same_block
                           & valid_saved
                           & ~saved_hit_way_hot_nxt[0];
  ic_hands_off_data[1]  = same_block
                           & valid_saved
                           & ~saved_hit_way_hot_nxt[1];
end

wire fa_pc_keep;
assign fa_valid_next = fa0_req;
reg ic_tag_lock_val;
always @*
  begin : ic_mux_PROC
    ic_tag_din_q = {rf_it_tag, rf_it_lock, rf_it_valid};
    ic_tag_addr  = rf_it_addr;

    ic_active0    = 1'b0;
    ic_active1    = 1'b0;
    if( (|ic_ecc_sb_err_tmp) | (|ic_ecc_db_err_tmp) )
    begin
      ic_tag_mem_cs  = 1'b1;
      ic_tag_mem_we  = 1'b1;
      ic_tag_mem_addr= fa0_addr_r[`IC_IDX_RANGE];
      ic_tag_din_q   = `IC_TRAM_DATA_SIZE'b0;
    end
    else
    if (rf_req_it)
    begin
      // refill unit has the highest priority
      ic_tag_mem_addr= rf_it_addr;
      ic_tag_addr    = rf_it_addr;
      ic_tag_mem_we  = !rf_it_read;
      if ((ic_ctl_ivic) | (ic_init))
      begin
        ic_tag_mem_cs  = 1'b1;
      end
      else if (ic_ctl_cache == 1'b1)
      begin
        ic_tag_mem_cs  = rf_it_cs;
      end
      else
      begin
        ic_tag_mem_cs  = rf_reset_done_r ? (rf_it_cs & (|rf_way_hot)) : 1'b1;
      end
    end
    else
    begin
      // give the tags to the fetch unit
      ic_tag_mem_addr= fa0_addr[`IC_IDX_RANGE];
      if (ic_ctl_cache == 1'b1)
      begin
        ic_tag_mem_addr= ic_icmo_adr[`IC_IDX_RANGE];
        ic_tag_addr    = rf_it_addr;
      end
      else
      begin
        ic_tag_mem_addr= fa0_addr[`IC_IDX_RANGE];
        ic_tag_addr    = fa0_addr[`IC_IDX_RANGE];
      end
      ic_tag_mem_cs   = (((((fa_valid_next | (fa_valid_next & rf_done & (~ic_idle))) & (~ic_disabled)))
                         & !ic_hands_off_tag)
                        | (ic_ctl_idx_rd_tag | ic_ctl_lil | ic_ctl_ulil | ic_ctl_prefetch)
                        );

      ic_tag_mem_we  = 1'b0;
      ic_active0    =  fa0_req;
      ic_active1    =  fa0_req;
    end
  end


always @*
  begin : data_access_PROC
    ic_data_din_q    = rf_id_data[31:0];
    if (rf_req_id)
      begin
        // refill unit has the highest priority
        ic_data_mem_addr = rf_id_addr;
        ic_data_mem_cs   = rf_reset_done_r ? (rf_id_cs & (|rf_way_hot)) : 1'b1;
        ic_data_mem_we   = !rf_id_read;
      end
    else
      begin
        // give idata to the fetch unit
        ic_data_mem_addr   = fa0_addr[`IC_DATA_ADR_RANGE];
        ic_data_mem_cs     = (((fa_valid_next | (rf_done & (~ic_idle) & fa_valid_next))
                              & (~ic_disabled) & (!(&ic_hands_off_data))) 
                             | ic_ctl_write_data
                             )
                             ;
        ic_data_mem_we     = 1'b0;
      end
  end

assign ic_tag_din_w0 = {ic_ecc_tag_din,ic_tag_din_q};
assign ic_tag_din_w1 = {ic_ecc_tag_din,ic_tag_din_q};
assign ic_tag_mem_wem_w0 = ic_tag_mem_cs & rf_way_hot[0];
assign ic_tag_mem_wem_w1 = ic_tag_mem_cs & rf_way_hot[1];
assign ic_tag_mem_wem[`IC_TRAM_W0_RANGE]   =
                                              (ic_ecc_sb_err_tmp[0] | ic_ecc_db_err_tmp[0]) ? {`IC_TRAM_SIZE{ic_ecc_sb_err_tmp[0] | ic_ecc_db_err_tmp[0]}} :
                                              {`IC_TRAM_SIZE{ic_tag_mem_wem_w0}}; 
assign ic_tag_mem_wem[`IC_TRAM_W1_RANGE]   = 
                                              (ic_ecc_sb_err_tmp[1] | ic_ecc_db_err_tmp[1]) ? {`IC_TRAM_SIZE{ic_ecc_sb_err_tmp[1] | ic_ecc_db_err_tmp[1]}} :
                                              {`IC_TRAM_SIZE{ic_tag_mem_wem_w1}}; 

assign ic_data_mem_wem_w0 = ic_data_mem_cs & rf_way_hot[0]; 
assign ic_data_mem_wem_w1 = ic_data_mem_cs & rf_way_hot[1]; 
assign ic_data_mem_wem[`IC_DATA_SET_W0_RANGE] = {`IC_DRAM_SIZE{ic_data_mem_wem_w0}};
assign ic_data_mem_wem[`IC_DATA_SET_W1_RANGE] = {`IC_DRAM_SIZE{ic_data_mem_wem_w1}};

wire     [`IC_DATA_SET_W0_RANGE]   ic_data_din_q0_name;
wire     [`IC_DATA_SET_W0_RANGE]   ic_data_din_q1_name;
assign ic_data_din_q0_name = {ic_ecc_data_din0,ic_data_din_q};
assign ic_data_din_q1_name = {ic_ecc_data_din0,ic_data_din_q};

//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived. clock gate will be replaced with cg cell that will have scan points 
clkgate u_cg_ic_tag_mem
  (
   .clk_in         (clk),
   .clock_enable_r (ic_tag_mem_cs),
   .clk_out        (ic_tag_mem_clk)
  );

clkgate u_cg_ic_data_mem
  (
   .clk_in         (clk),
   .clock_enable_r (ic_data_mem_cs),
   .clk_out        (ic_data_mem_clk)
  );

//spyglass enable_block TA_09                                 

/////////////////////////////////////////////////////////////
// Little FSM to kick-off the refill unit
//

always@(posedge clk or posedge rst_a)
  begin
    if (rst_a == 1'b1)
      begin
        ic_rf_in_progress_r <= 1'b0;
      end
    else
      begin
        ic_rf_in_progress_r <= ic_rf_in_progress_nxt; 
      end
  end

assign fa1_addr = fa0_addr + 2'b01;
parameter IC_STATE_IDLE         = 3'b000;
parameter IC_STATE_WAIT_ACCEPT  = 3'b001;
parameter IC_STATE_WAIT_DATA    = 3'b010;
parameter IC_STATE_CACHE_INST   = 3'b011;
parameter IC_STATE_WAIT_DATA_ACCEPT = 3'b100;
parameter IC_STATE_WAIT_UNC_DATA= 3'b101;

always @*
begin : ic_state_PROC
  ic_rf_req         = 1'b0;
  ic_rf_unc         = ic_disabled
                     | (ic_read_r & (ic_it_lock_way_hot == {`IC_WAYS{1'b1}}) & (~(ic_hit))) // all locked
                     | fetch_iccm_hole
                      ;
  if (ic_ecc_fa0_err)
  begin
    ic_rf_addr        = fa0_addr_r;
  end
  else
  begin
    ic_rf_addr        = fa0_req_r ? fa0_addr_r: `IFU_ADDR_BITS'b0;
  end
  ic_rf_addr_next   = fa0_addr_r;
  ifu_rd_accept_wait= 1'b0;
  ic_rf_way_hot     = ic_rf_way_hot_r;

  ic_victim_way_enb = 1'b0;

  ic_idle           = ~(arcv_icache_op_init | spc_op_in_prg); 

  ic_rf_done        = 1'b1;

  ic_idle_ack       = 1'b1;
  ic_ctl_cache_inst = 1'b0;
  ic_pc_sel_nxt     = ic_pc_sel_r;

  ic_ctl_unc_next   = ic_ctl_unc;
  ic_mem_err_next   = ic_mem_err & (~ic_rf_kill);

  ic_state_next     = ic_state;
  ic_rf_in_progress_nxt = 1'b0;
  ic_unc_wait_timeout   = 1'b0;

  case (ic_state)
  IC_STATE_IDLE:
  begin
    ic_idle_ack         = !(  aux_ic_ivic_sel
                            | aux_ic_ivil_sel
                            | aux_ic_lil_sel);
    ic_ctl_cache_inst   = ic_ctl_cache;
    ic_rf_way_hot       = ic_replacement_way_hot;

    if (spc_fence_i_inv_req)
      begin
        ic_idle            = 1'b0;
        ic_idle_ack        = 1'b0;
        ic_state_next      = ic_state;
      end
    else if (ic_ctl_op)
      begin
        ic_idle            = 1'b0;
        ic_idle_ack        = 1'b0;
        // Tell the refill unit to go off and execute the cache instruction
        //
        ic_state_next      = IC_STATE_CACHE_INST;
        ic_pc_sel_nxt      = 1'b1;
        ic_rf_addr         = ic_icmo_adr[`IFU_ADDR_RANGE]; 
        ic_ctl_unc_next    = 1'b0;
      end
    else if (fa_ic_rf_req)
      begin
         // Fetch unit initiated a refill

        ic_idle           = 1'b0;
        ic_rf_req         = 1'b1;
        ic_rf_done        = 1'b0;
        ic_victim_way_enb = 1'b1;
        ic_ctl_unc_next   = ic_disabled
                          | (& ic_it_lock_way_hot) // all ways locked
                          | fetch_iccm_hole
                          ;
        ic_mem_err_next   = 1'b0;
        ic_rf_in_progress_nxt = 1'b1;
        
        if (ic_rf_ack)
          begin
            if (ic_rf_unc == 1'b1)
              begin
                ic_state_next     = IC_STATE_WAIT_UNC_DATA;
              end
            else
              begin
                ic_state_next     = IC_STATE_WAIT_DATA;
              end
          end
        else
          begin
            ic_state_next     = IC_STATE_WAIT_ACCEPT;
          end
      end
  end

  IC_STATE_WAIT_ACCEPT:
  begin
    // Keep request high until we see an ack. This is particularly importatant
    // when we have an ahb_lite memory interface as the interface may be busy
    // serving the LS unit and therefore is not accepting fetch requests.
    // The missing pc is guaranteed to be stabled.
    ic_idle           = 1'b0;
    ic_rf_req         = 1'b1;
    ic_rf_done        = 1'b0;
    ic_ctl_unc_next   = ic_ctl_unc;
    ic_rf_addr        = ic_rf_addr_r[`IFU_ADDR_RANGE];
    ic_rf_in_progress_nxt = 1'b1;
    if (ic_rf_ack)
      begin
        if (ic_rf_unc_r == 1'b1)
          begin
            ic_state_next     = IC_STATE_WAIT_UNC_DATA;
          end
        else
          begin
            ic_state_next     = IC_STATE_WAIT_DATA;
          end
      end
  end

  IC_STATE_WAIT_DATA:
  begin
    ic_idle           = 1'b0;
    ic_rf_done        = 1'b0;
    ic_rf_addr        = ic_rf_addr_r[`IFU_ADDR_RANGE];
    ic_ctl_unc_next   = ic_ctl_unc;
    ic_rf_in_progress_nxt = 1'b1;
    if (rf_done)
      begin
        ic_busy          = 1'b0;
        ic_rf_done       = 1'b1;
        ic_mem_err_next  = rf_err & (~ic_rf_kill);
        ic_ctl_unc_next  = 1'b0;
        ic_state_next    = IC_STATE_IDLE;
        ic_rf_in_progress_nxt = 1'b0;
      end
  end

  IC_STATE_WAIT_UNC_DATA:
  begin
    ic_idle            = 1'b0;
    ic_rf_done         = 1'b0;
    ic_rf_addr         = ic_rf_addr_r[`IFU_ADDR_RANGE];
    ic_ctl_unc_next    = ic_ctl_unc;
    ifu_rd_accept_wait = (cwf_valid_r & ifu_rd_valid & (~ic_f1_data_fwd[0]));
    ic_rf_addr       = fa1_addr; 
    ic_rf_addr_next  = fa1_addr;
    ic_ctl_unc_next  = ic_ctl_unc;
    ic_rf_unc        = ic_disabled
                       | fetch_iccm_hole
                       ;
    if (((ftb_idle == 1'b1)
        | ic_ctl_op
        | (~fa0_req)
        | (~ic_ctl_unc | ~ic_rf_unc)) &
        (~ic_rf_in_progress_r | (ifu_rd_valid & ifu_rd_last))) // if existing request in progress do not go to idle else  
    begin
      ic_state_next         = IC_STATE_IDLE;
      ic_rf_done            = 1'b0;
      ic_idle               = 1'b0;
      ic_rf_in_progress_nxt = 1'b0;
      ic_rf_req             = 1'b0; 
      ifu_rd_accept_wait    = 1'b0; 
    end
    // ifu_rd_valid  -- Read Data for the previous transfer is available
    // and
    //     ~cwf_valid         -- Init New Transfer
    //     ic_f1_data_fwd[0]  -- i.e. cwf_valid is available so new data can sit in cwf Init New Transfer
    //                           de-assert ifu_rd_accept
    else if (ic_rf_in_progress_r)
    begin
      // No cwf_valid and New Read Data
      if (~cwf_valid_r & ifu_rd_valid)
      begin
        ic_rf_req             = 1'b1; 
        ic_rf_in_progress_nxt = 1'b1; 
        // FA0 | FA1
        ic_rf_addr            = fa1_addr; 
        ic_rf_addr_next       = fa1_addr; 
        ic_idle               = 1'b0;
        if (fch_br_restart_misp_in_ic_rf_r | fch_br_restart_misp_r)
        begin
          ic_rf_req             = 1'b1; 
          ic_rf_in_progress_nxt = 1'b1; 
          ic_rf_addr            = fa0_addr; 
          ic_rf_addr_next       = fa0_addr; 
          if (~continue_unc_transfer)
          begin
            ic_rf_req             = 1'b0; 
            ic_state_next         = IC_STATE_IDLE;
            ic_rf_in_progress_nxt = 1'b0; 
          end
        end
      end
      // Old CWF or New Read Data or noth
      else if ((ic_f1_data_fwd[0]) & (ifu_rd_valid | (cwf_valid_r & (~cmd_issued_r))))
      begin
        ic_rf_req             = 1'b1; 
        ic_rf_in_progress_nxt = 1'b1; 
        if (ifu_rd_last)
        begin
          ic_rf_addr            = fa1_addr;
          ic_rf_addr_next       = fa1_addr;
          if (fch_br_restart_misp_in_ic_rf_r | fch_br_restart_misp_r)
          begin
            ic_rf_addr            = fa0_addr;
            ic_rf_addr_next       = fa0_addr;
          end
        end
        else
        begin
          ic_rf_addr            = fa0_addr;
          ic_rf_addr_next       = fa0_addr;
        end
        ic_idle               = 1'b0;
        if (~continue_unc_transfer)
        begin
          ic_rf_req             = 1'b0; 
          ic_state_next         = IC_STATE_IDLE;
          ic_rf_in_progress_nxt = 1'b0; 
        end
      end
      else
      begin
      // cwf_valid no accept from al stage
        ic_rf_req             = 1'b0; 
        ic_rf_in_progress_nxt = 1'b1; 
        ic_unc_wait_timeout   = 1'b1;
        ic_rf_addr            = rf_cmd_addr_r[`IFU_ADDR_RANGE];
        ic_rf_addr_next       = rf_cmd_addr_r[`IFU_ADDR_RANGE];
        ic_idle               = 1'b0;
        if (cwf_valid_r & ~cmd_issued_r)
        begin
          if (fch_br_restart_misp_in_ic_rf_r | fch_br_restart_misp_r)
            begin
              ic_rf_in_progress_nxt = 1'b0; 
              ic_state_next         = IC_STATE_IDLE;
              if ((~ic_ctl_op | ic_ctl_unc | ic_rf_unc | ~spc_fence_i_inv_req) & (fa0_req))
              begin
                ic_rf_req             = 1'b1; 
                ic_rf_in_progress_nxt = 1'b1; 
                ic_rf_addr            = fa0_addr; 
                ic_rf_addr_next       = fa0_addr; 
              end
            end
          else if (ic_f1_data_fwd[0])
            begin
              if (~ic_ctl_op | ic_ctl_unc | ic_rf_unc | ~spc_fence_i_inv_req)
              begin
                ic_rf_req             = 1'b1; 
                ic_rf_in_progress_nxt = 1'b1; 
                ic_rf_addr            = fa1_addr; 
                ic_rf_addr_next       = fa1_addr; 
              end
            end
        end
      end
    end
    else if (~ic_rf_in_progress_r)
    begin
      if (ic_ctl_op | (~ic_ctl_unc) | (~ic_rf_unc) | spc_fence_i_inv_req| (~fa0_req))
      begin
        ic_rf_req             = 1'b0; 
        ic_rf_in_progress_nxt = 1'b0; 
        ic_state_next         = IC_STATE_IDLE;
      end
      else if (fa0_req)
      begin
        ic_rf_req             = 1'b1; 
        ic_rf_in_progress_nxt = 1'b1; 
        ic_rf_addr            = fa0_addr;
        ic_rf_addr_next       = fa0_addr;
      end
    end
  end

  IC_STATE_WAIT_DATA_ACCEPT:
  begin
    ic_idle           = 1'b0;
    ic_rf_done        = 1'b0;
    ic_ctl_unc_next   = ic_ctl_unc;
    ic_rf_in_progress_nxt = 1'b1;
    ic_unc_wait_timeout = ~ic_unc_wait_timeout_r;
    if ((ic_f1_data_fwd[0] == 1'b1) | (fch_br_restart_misp_in_ic_rf_r == 1'b1)
        |(ftb_idle == 1'b1) | (ic_unc_wait_timeout_r == 1'b1))
    begin
      ic_idle          = ~(arcv_icache_op_init | spc_op_in_prg); 
      ic_state_next    = IC_STATE_IDLE;
      ic_rf_in_progress_nxt = 1'b0;
    end
  end

  IC_STATE_CACHE_INST:
  begin
    ic_idle           = 1'b0;
    ic_rf_done        = 1'b0;
    ic_idle_ack       = 1'b0;
    ic_ctl_cache_inst = 1'b1;
    ic_rf_addr        = ic_icmo_adr[`IFU_ADDR_RANGE]; 
    if ((rf_ic_cache_instr_done) | (rf_reset_done & ~rf_reset_done_r))
      begin
        ic_idle          = ~(arcv_icache_op_init | spc_op_in_prg); 
        ic_rf_done       = 1'b1;
        ic_state_next    = IC_STATE_IDLE;
        ic_pc_sel_nxt    = 1'b0;
      end
  end

// spyglass disable_block W193
// SMD: Empty statement
// SJ : Default is covered
  default:
    ;
  endcase
// spyglass enable_block W193

// spyglass disable_block W415a
// SMD: Signal may be multiply assigned (beside initialization) in the same scope
// SJ : Intended to check the state of IC 
  ic_busy      = 
               ((ic_state != IC_STATE_IDLE)
               )
               | ic_ctl_ivic
               | ic_ctl_ivil
               | ic_ctl_lil
               | ic_ctl_ulil
               | ic_ctl_idx_ivil
               | ic_ctl_idx_rd_tag
               | ic_ctl_idx_rd_data
               | ic_ctl_idx_wr_tag
               | ic_ctl_idx_wr_data
               | spc_op_in_prg
               ;
// spyglass enable_block W415a
end
assign ignore_cwf = (fa0_addr == ifu_cmd_addr[`IFU_ADDR_RANGE]);
always @(posedge clk or posedge rst_a)
  begin : ic_state_update_PROC
    if (rst_a == 1'b1)
      begin
        ic_state        <= IC_STATE_CACHE_INST;
        ic_ctl_unc      <= 1'b0;
        ic_mem_err      <= 1'b0;
        ic_pc_sel_r     <= 1'b0;
        ic_rf_addr_r    <= `IFU_ADDR_BITS'b0;
        ic_rf_unc_r     <= 1'b0;
        ic_unc_wait_timeout_r <= 1'b0;
        ic_rf_way_hot_r <= `IC_WAYS'b0; 
        ic_prev_state_is_unc  <= 1'b0;
        ignore_cwf_r    <= 1'b0;
      end
    else
      begin
        ic_state        <= ic_state_next;
        ic_mem_err      <= ic_mem_err_next;
        ic_pc_sel_r     <= ic_pc_sel_nxt;
        ic_unc_wait_timeout_r <= ic_unc_wait_timeout; 
        ic_prev_state_is_unc  <= ic_state[2]; 
        if (ic_state == IC_STATE_IDLE)
          begin
            ic_ctl_unc      <= ic_ctl_unc_next;
          end
        else if (ic_state == IC_STATE_WAIT_UNC_DATA)
          begin
            ic_ctl_unc      <= ic_rf_unc;
          end
        if (ic_state == IC_STATE_IDLE)
          begin
            ic_rf_addr_r    <= ic_rf_addr; 
            ic_rf_unc_r     <= ic_rf_unc; 
            ic_rf_way_hot_r <= ic_rf_way_hot; 
          end
        ignore_cwf_r    <= ignore_cwf; 
      end
  end

//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived as ic_data_syndrome uses direct output of I-Cache Memory 
always @*
begin : ic_hit_sel_PROC

  ic_data_hit_q = `IC_DRAM_SIZE'h0
                  | (ic_data_dout_w0 & {`IC_DRAM_SIZE{ic_ecc_hit_way_hot[0]}})
                  | (ic_data_dout_w1 & {`IC_DRAM_SIZE{ic_ecc_hit_way_hot[1]}})
                  ;
end
//spyglass enable_block TA_09                                 


rl_ifu_icache_rf u_rl_ifu_icache_rf (
  .*,
  .spc_fence_i_inv_ack_r         (spc_fence_i_inv_ack     ),
  .ic_rf_ivic                    (ic_ctl_ivic             ),
  .ic_rf_ivil                    (ic_ctl_ivil             ),
  .ic_rf_lil                     (ic_ctl_lil              ),
  .ic_rf_ulil                    (ic_ctl_ulil             ),
  .ic_rf_idx_ivil                (ic_ctl_idx_ivil         ),
  .ic_rf_idx_rd_tag              (ic_ctl_idx_rd_tag       ),
  .ic_rf_idx_rd_data             (ic_ctl_idx_rd_data      ),
  .ic_rf_idx_wr_tag              (ic_ctl_idx_wr_tag       ),
  .ic_rf_idx_wr_data             (ic_ctl_idx_wr_data      ),
  .ic_rf_prefetch                (ic_ctl_prefetch         ),
  .ic_rf_wr_data                 (ic_op_wr_data           ),
  .ic_rf_unc                     (ic_ctl_unc_next         ),
  .rf_done                       (rf_op_done              ),             
  .rf_done_r                     (rf_done                 ),             
  
  .rf_cmd_address                (ifu_cmd_addr      ),      
  .rf_rd_data                    (ifu_rd_data       ),
  .rf_cmd_valid                  (ifu_cmd_valid     ), 
  .rf_cmd_accept                 (ifu_cmd_accept    ),       
  .rf_cmd_burst_size             (ifu_cmd_burst_size),   
  .rf_cmd_cache                  (ifu_cmd_cache     ),
  .rf_rd_valid                   (ifu_rd_valid      ),         
  .rf_rd_err                     (ifu_rd_err        ),         
  .rf_rd_last                    (ifu_rd_last       ),          
  .rf_rd_accept                  (rf_rd_accept            )
);


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Synchronous blocks defining I-cache input pipeline registers             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

 reg     ic_way_enable_next0;
 reg     ic_way_enable_next1;

always @*
  begin : way_enable_async_PROC
        ic_way_enable_next0 = ic_way_enable0;
        ic_way_enable_next1 = ic_way_enable1;
      if (  fa0_req
          | fch_restart)
        begin
          ic_way_enable_next0 = ic_active0;
          ic_way_enable_next1 = ic_active1;
        end
  end

always @(posedge clk or posedge rst_a)
  begin : way_enable_PROC
    if (rst_a == 1'b1)
      begin
          ic_way_enable0 <= 1'b0;
          ic_way_enable1 <= 1'b0;
      end
    else
      begin
        ic_way_enable0 <= ic_way_enable_next0;
        ic_way_enable1 <= ic_way_enable_next1;
      end
  end

always @(posedge clk or posedge rst_a)
  begin : saved_hit_way_PROC
    if (rst_a == 1'b1)
      begin : save_hit_way_hot_PROC
        saved_hit_way_hot_r <= `IC_WAYS'd0;
      end
    else
      begin
        if (ic_busy)
          begin
            saved_hit_way_hot_r <=  `IC_WAYS'd0;
          end
        else
          begin
            saved_hit_way_hot_r <=  saved_hit_way_hot_nxt;
          end
      end
  end

always @(posedge clk or posedge rst_a)
  begin : ic_inst_valid_buf_PROC
    if (rst_a == 1'b1)
      begin
        ic_inst_done_r <= 1'b0;
      end
    else
      begin
        if (rf_ic_cache_instr_done)
          begin
            ic_inst_done_r <= 1'b1;
          end
        else if (fa_valid_next)
          begin
            ic_inst_done_r <= 1'b0;
          end
      end
  end

always @(posedge clk or posedge rst_a)
  begin : fa_valid_buf_PROC
    if (rst_a == 1'b1)
      begin
        fa_valid_r <= 1'b0;
      end
    else
      begin
        fa_valid_r <= fa_valid_next;
      end
  end

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// Victim way register for pseudo-random replacement                        //
// -- Implemented as a rotating register with IC_WAYS bits,                 //
// -- initialised to 1 and gets rotated when a way is replaced.             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst_a)
  begin : ic_victim_way_hot_PROC
    if (rst_a == 1'b1)
      begin
        ic_victim_way_hot <= `IC_WAYS'd1;
      end
    else
      begin
        if (ic_victim_way_enb)
          begin
            ic_victim_way_hot <= ic_victim_way_hot_next;
          end
      end
  end


assign ic_ctl_op = ( ic_ctl_ivic
                    | ic_ctl_ivil
                    | ic_ctl_lil
                    | ic_ctl_ulil
                    | ic_ctl_idx_ivil
                    | ic_ctl_idx_rd_tag
                    | ic_ctl_idx_rd_data
                    | ic_ctl_idx_wr_tag
                    | ic_ctl_idx_wr_data
                    | ic_ctl_prefetch
                   ); 


assign ic_ctl_cache = ( ic_ctl_ivic
                      | ic_ctl_ivil
                      | ic_ctl_lil
                      | ic_ctl_ulil
                      | ic_ctl_idx_ivil
                      | ic_ctl_idx_rd_tag
                      | ic_ctl_idx_rd_data
                      | ic_ctl_idx_wr_tag
                      | ic_ctl_idx_wr_data
                      | ic_ctl_prefetch
                      ) & ~fa_refill_r;

always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    ic_ctl_cache_r <= 1'b0;
  end
  else
  begin
    ic_ctl_cache_r <= ic_ctl_cache; 
  end
end



always@(posedge clk or posedge rst_a)
begin
  if (rst_a == 1'b1)
  begin
    fa_refill_r <= 1'b0; 
  end
  else
  begin
    fa_refill_r <= 1'b0; 
    if ((ic_ctl_cache == 1'b0) & (fa_ic_rf_req == 1'b1))
    begin
      fa_refill_r <= 1'b1; 
    end
  end
end

wire ic_miss_refill;

assign dis_ic_rf_ic_on_fch_br_req_misp = ((ic_state == 3'b000) & (fch_restart | br_req_ifu 
                                            | f1_mem_target_mispred
                                            )); 
assign ic_miss_refill    = (((|ic_ecc_hit_way_hot_qual) | ic_ecc_fa0_err) ? (ic_f1_data_fwd[0] & (~ic_hit)) : 1'b1);
assign fa_ic_rf_req      = (fa0_req_r & ((ic_miss_refill & rf_reset_done_r & (ic_read_r)) | ic_rf_unc_r) & (~(dis_ic_rf_ic_on_fch_br_req_misp))) | ic_rf_in_progress_r;

rl_ifu_icache_ctl u_rl_ifu_icache_ctl(
  .*,
  .icmo_op_done               (icmo_done),
  .ic_ctl_data                (ic_ctl_data)
);

always@(posedge clk or posedge rst_a)
begin: rf_reset_done_reg_PROC
  if (rst_a == 1'b1)
  begin
    rf_reset_done_r <= 1'b0;
  end
  else
  begin
    rf_reset_done_r <= rf_reset_done; 
  end
end

always@*
begin
  cwf_nxt = cwf_r; 
  if (((ifu_rd_valid == 1'b1) & (cwf_r == 1'b1)) | (fch_br_restart_misp_in_ic_rf_nxt == 1'b1) | (ic_ctl_cache == 1'b1))
  begin
    cwf_nxt = 1'b0;
  end
  else if ((ifu_cmd_valid == 1'b1) & (ifu_cmd_accept == 1'b1))
  begin
    cwf_nxt = 1'b1;
  end
end

always@*
begin
  cwf_data_nxt = cwf_data_r;
  if (cwf_valid_r & (ic_f1_data_fwd[0] == 1'b1) & (ic_rf_unc) & ifu_rd_valid)
  begin
    if (ic_ctl_unc)
    begin
      cwf_data_nxt = (ifu_rd_accept & fa0_req_r) ? ifu_rd_data : cwf_data_r;
    end
    else
    begin
      cwf_data_nxt = ifu_rd_data;
    end
  end
  else if ((cwf_r == 1'b1) & (ifu_rd_valid)
          )
  begin
    if (ic_ctl_unc)
    begin
      cwf_data_nxt = ifu_rd_accept ? ifu_rd_data : cwf_data_r;
    end
    else
    begin
      cwf_data_nxt = ifu_rd_data;
    end
  end
  else if (~cwf_valid_r & (ic_state == 3'b101) & ifu_rd_last & ifu_rd_accept & (~fch_br_restart_misp_in_ic_rf_r))
  begin
    cwf_data_nxt = ifu_rd_data;
  end
end

always@*
begin
  cwf_valid_nxt   = cwf_valid_r;
  ibp_bus_err_nxt = ibp_bus_err_r;
  if (cwf_valid_r)
    begin
      if ((ic_f1_data_fwd[0] == 1'b1) & (ic_rf_unc) & (ifu_rd_valid))
      begin
        cwf_valid_nxt = 1'b1;
        if (fch_br_restart_misp_in_ic_rf_r == 1'b1)
        begin
          // if there is a fetch restart or branch restart in current cycle dont register incoming uncached data
          cwf_valid_nxt = 1'b0;
        end
      end
      else if ((((ic_f1_data_fwd[0] == 1'b1) & fa0_req_r) | (fch_br_restart_misp_in_ic_rf_r == 1'b1))
          | (ic_ctl_cache == 1'b1) | (ic_state_next == 3'b000) | (ic_state == 3'b011))
      begin
        cwf_valid_nxt = 1'b0;
      end
    end
  else if ((cwf_r == 1'b1) & (ifu_rd_valid == 1'b1)
          )
  begin
    cwf_valid_nxt   = 1'b1;
    ibp_bus_err_nxt = ifu_rd_err; 
    if (fch_br_restart_misp_in_ic_rf_r == 1'b1)
    begin
      cwf_valid_nxt   = 1'b0;
      ibp_bus_err_nxt = ifu_rd_err; 
    end
  end
  else if (ifu_rd_last & ifu_rd_accept & (ic_state == 3'b101) & (~fch_br_restart_misp_in_ic_rf_r))
  begin
    cwf_valid_nxt   = 1'b1;
    ibp_bus_err_nxt = ifu_rd_err; 
  end
  else if (ic_state == 3'b000)
  begin
    ibp_bus_err_nxt = 1'b0; 
  end
end

always@(posedge clk or posedge rst_a)
begin: cwf_reg_PROC
  if (rst_a == 1'b1)
  begin
    cwf_r         <= 1'b0;
    cwf_data_r    <= 32'b0;
    cwf_valid_r   <= 1'b0; 
    ibp_bus_err_r <= 1'b0;
  end
  else
  begin
    cwf_r         <= cwf_nxt;
    cwf_data_r    <= cwf_data_nxt; 
    cwf_valid_r   <= cwf_valid_nxt; 
    ibp_bus_err_r <= ibp_bus_err_nxt; 
  end
end

assign ifu_rd_accept = ic_rf_unc ? (~ifu_rd_accept_wait) : rf_rd_accept;
assign cwf_fa_match  = (fa0_addr == rf_cmd_addr_r[`IFU_ADDR_RANGE]);

always@*
begin
  fch_br_restart_misp_nxt = 1'b0;
  if (fch_restart | br_req_ifu
      | f1_mem_target_mispred
     )
  begin
    fch_br_restart_misp_nxt = 1'b1;
  end
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    fch_br_restart_misp_r <= 1'b0;
  end
  else
  begin
    fch_br_restart_misp_r <= fch_br_restart_misp_nxt; 
  end
end



always@*
begin: fch_br_restart_misp_in_ic_rf_nxt_PROC
  if (fa_ic_rf_req == 1'b0)
  begin
    fch_br_restart_misp_in_ic_rf_nxt = 1'b0;
  end
  else
  begin
    fch_br_restart_misp_in_ic_rf_nxt = fch_br_restart_misp_in_ic_rf_r; 
    if ((fa_ic_rf_req == 1'b0) | (ic_state_next == 3'b000))
    begin
      fch_br_restart_misp_in_ic_rf_nxt = 1'b0; 
    end
    else if ((ic_state_next == 3'b101) & ifu_rd_valid & ifu_rd_accept)
    begin
      fch_br_restart_misp_in_ic_rf_nxt = 1'b0; 
      if ((fch_restart == 1'b1) | (br_req_ifu == 1'b1)
          | (f1_mem_target_mispred == 1'b1)
          | fch_same_pc_nxt
         )
      begin
        fch_br_restart_misp_in_ic_rf_nxt = 1'b1; 
      end
    end
    else if ((fch_restart == 1'b1) | (br_req_ifu == 1'b1)
                | (f1_mem_target_mispred == 1'b1)
                | fch_same_pc_nxt
                )
    begin
      fch_br_restart_misp_in_ic_rf_nxt = 1'b1; 
    end
  end
end

always@(posedge clk or posedge rst_a)
begin: fch_br_restart_misp_in_ic_rf_reg_PROC
  if (rst_a == 1'b1)
  begin
    fch_br_restart_misp_in_ic_rf_r <= 1'b0;
  end
  else
  begin
    fch_br_restart_misp_in_ic_rf_r <= fch_br_restart_misp_in_ic_rf_nxt; 
  end
end



assign ic_ctl_ivic         = ic_op_inv_all;
assign ic_ctl_ivil         = ic_op_adr_inv;
assign ic_ctl_lil          = ic_op_adr_lock;
assign ic_ctl_ulil         = ic_op_adr_unlock;
assign ic_ctl_idx_ivil     = ic_op_idx_inv;
assign ic_ctl_idx_rd_tag   = ic_op_idx_rd_tag;
assign ic_ctl_idx_rd_data  = ic_op_idx_rd_data;
assign ic_ctl_idx_wr_tag   = ic_op_idx_wr_tag;
assign ic_ctl_idx_wr_data  = ic_op_idx_wr_data;
assign ic_ctl_prefetch     = ic_op_prefetch;


//////////////////////////////////////////////////////////////
// I-Cache RAM Output Assignment
//////////////////////////////////////////////////////////////
assign   ic_tag_mem_din      = {ic_tag_din_w1, ic_tag_din_w0}; 
assign   ic_tag_dout_w0      = ic_tag_mem_dout[`IC_TRAM_W0_RANGE];
assign   ic_tag_dout_w1      = ic_tag_mem_dout[`IC_TRAM_W1_RANGE];
assign   ic_data_mem_din     = {ic_data_din_q0_name, ic_data_din_q0_name}; 
assign   ic_data_dout_w0     = ic_data_mem_dout[`IC_DATA_SET_W0_RANGE];
assign   ic_data_dout_w1     = ic_data_mem_dout[`IC_DATA_SET_W1_RANGE];



wire   ic_unc_update_prot;
assign ic_unc_update_prot   = ((ic_state == 3'b101) & ifu_rd_last);
assign ifu_cmd_prot[0]      = ((ic_state == 3'b000) | (ic_unc_update_prot)) ? (priv_level != `PRIV_U) : ifu_cmd_prot_r;
assign ifu_cmd_prot[1]      = 1'b1; 
assign ifu_cmd_wrap         = (ic_state == 3'b000) ? (ic_ctl_unc_next ? 1'b0 : 1'b1) : ifu_cmd_wrap_r; 
always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    ifu_cmd_prot_r <= 1'b0;
    ifu_cmd_wrap_r <= 1'b0;
  end
  else
  begin
    ifu_cmd_prot_r <= ifu_cmd_prot[0]; 
    ifu_cmd_wrap_r <= ifu_cmd_wrap; 
  end
end



always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    cmd_issued_r <= 1'b0;
  end
  else
  begin
    casez ({ifu_cmd_valid, ifu_cmd_accept, ifu_rd_last})
    3'b110:
    begin
      cmd_issued_r <= 1'b1;
    end
    3'b111:
    begin
      cmd_issued_r <= ifu_rd_accept; 
    end
    3'b101:
    begin
      cmd_issued_r <= ifu_rd_accept;
    end
    3'b100:
    begin
      cmd_issued_r <= cmd_issued_r; 
    end
    3'b011:
    begin
      cmd_issued_r <= 1'b0;
    end
    3'b010:
    begin
      cmd_issued_r <= cmd_issued_r; 
    end
    3'b001:
    begin
      cmd_issued_r <= (~ifu_rd_accept); 
    end
    3'b000:
    begin
      cmd_issued_r <= cmd_issued_r; 
    end
    default:
    begin
    end
    endcase
  end
end

assign continue_unc_transfer = ((ic_state == 3'b101)
                                & (
                                     (~ic_ctl_op)
                                     & (ic_rf_unc)
                                     & (~spc_fence_i_inv_req)
                                  )
                                );

//////////////////////////////////////////////////////////////
// Temporary assignment
//////////////////////////////////////////////////////////////
assign ic_rf_kill        = 1'b0;
assign ic_ctl_write_tag  = 1'b0;
assign ic_ctl_write_data = 1'b0;
assign ifu_cmd_atomic    = 6'b0; 
assign ifu_cmd_aux       = 1'b0; 
assign ifu_cmd_excl      = 1'b0;

assign aux_ic_ctrl_wen  = 1'b0;
assign aux_ic_ivic_wen  = 1'b0;
assign aux_ic_ivil_wen  = 1'b0;
assign aux_ic_lil_wen   = 1'b0;
assign aux_ic_ivic_sel  = 1'b0;
assign aux_ic_ivil_sel  = 1'b0;
assign aux_ic_lil_sel   = 1'b0;
assign aux_ic_ctrl_r    = 6'b0;
assign aux_ic_ram_addr_r= 32'b0;
assign aux_ic_data_r    = `IC_DRAM_SIZE'b0; 
assign aux_ic_tag_tag_r = `IC_TAG_BITS'b0; 
assign aux_ic_tag_lock_r= 1'b0;
assign aux_ic_tag_valid_r=1'b0;
//////////////////////////////////////////////////////////////
assign ifu_cmd_read      = 1'b1;
assign ifu_cmd_data_size = 3'b010;
wire     ic_data_ecc_db_excpn;
wire     ic_data_ecc_sb_excpn;

wire  [`IC_IDX_RANGE]                       ic_tag_ecc_addr_t;
assign   ic_tag_ecc_addr_err  = (|(ic_tag_ecc_adr_err_tmp));
assign   ic_data_ecc_addr_err = (|(ic_data_ecc_adr_err_rd));
assign   ic_tag_ecc_sb_err  = (|(ic_tag_ecc_sb_err_tmp));
assign   ic_tag_ecc_db_err  = (|(ic_tag_ecc_db_err_tmp));
assign   ic_tag_ecc_addr_t  = ic_tag_addr_r;
assign   ic_tag_ecc_addr    = ic_tag_ecc_addr_t;
//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived as ic_tag_syndrome uses direct output of I-Cache Memory 
assign   ic_tag_ecc_syndrome = 
                                 (ic_tag_ecc_sb_err_tmp[0] | ic_tag_ecc_db_err_tmp[0]
                                  | ic_tag_ecc_adr_err_tmp[0]
                                 ) ? fa_ic_tag_syndrome0 :
                                 fa_ic_tag_syndrome1
                                 ;
//spyglass enable_block TA_09                                 
assign   ic_data_ecc_addr   = ic_data_ecc_addr_t;
assign   ic_data_ecc_sb_err = (|ic_data_ecc_sb_err_rd);
assign   ic_data_ecc_db_err = (|(ic_data_ecc_db_err_rd));
//spyglass disable_block TA_09
//SMD: Reports cause of uncontrollability or unobservability and estimates the number of nets whose controllability/ observability is impacted
//SJ : Can be waived as ic_data_syndrome uses direct output of I-Cache Memory 
assign   ic_data_ecc_syndrome =
                                 (ic_data_ecc_sb_err_rd[0] | ic_data_ecc_db_err_rd[0]
                                  | ic_data_ecc_adr_err_rd[0]
                                 ) ? ic_data_syndrome_p0 :
                                 ic_data_syndrome_p1
                                 ;
//spyglass enable_block TA_09                                 

assign ic_data_ecc_db_excpn = (|(ic_data_ecc_db_err_tmp
                                 | ic_data_ecc_adr_err_tmp));
assign ic_data_ecc_sb_excpn = (|(ic_data_ecc_sb_err_tmp));

assign ic_tag_ecc_excpn =  ic_tag_err;
assign ic_data_ecc_excpn =  |(ic_data_err);
assign   ic_tag_ecc_out = {`IC_TAG_ECC_WIDTH{1'b0}}
                                 | ({`IC_TAG_ECC_WIDTH{ic_ctl_tag_sel_w0}} & ic_tag_ecc_out0)
                                 | ({`IC_TAG_ECC_WIDTH{ic_ctl_tag_sel_w1}} & ic_tag_ecc_out1)
                                 ;
assign   ic_tag_ecc_wr  = ic_ctl_idx_rd_tag & ( 1'b0
                                                | ic_ctl_tag_sel_w0
                                                | ic_ctl_tag_sel_w1
                                              );
assign   ic_data_ecc_wr = ic_ctl_idx_rd_data & ( 1'b0
                                                | ic_ctl_data_sel_w0
                                                | ic_ctl_data_sel_w1
                                               );
assign   ic_data_ecc_out = {`IC_DATA_ECC_WIDTH{1'b0}}
                     |({`IC_DATA_ECC_WIDTH{ic_ctl_data_sel_w0}} & ic_data_ecc_out0)
                     |({`IC_DATA_ECC_WIDTH{ic_ctl_data_sel_w1}} & ic_data_ecc_out1)
                     ;




assign fch_same_pc_nxt = ((ic_state == IC_STATE_WAIT_UNC_DATA) & fch_same_pc & ic_f1_data_valid & ic_f1_data_fwd[0]);

always@(posedge clk or posedge rst_a)
begin
  if (rst_a)
  begin
    fch_same_pc_r <= 1'b0;
  end
  else
  begin
    fch_same_pc_r <= fch_same_pc_nxt; 
  end
end

assign hpm_icm  = (~ic_disabled) & ic_rf_req & ic_rf_ack;

assign ifu_fch_vec = fch_restart_vec_r;

endmodule // rl_ifu_icache
