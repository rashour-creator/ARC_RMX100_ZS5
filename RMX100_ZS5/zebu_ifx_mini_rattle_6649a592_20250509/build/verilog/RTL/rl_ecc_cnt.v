// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright 2015-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//
// ===========================================================================
//
// @f:rl_ecc_cnt
//
// Description:
// @p
//   This module implements the syndrome registers for ecc errors for diagnostics.
// @e
//
// ===========================================================================

`include "defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"
`include "ras_defines.v"

module rl_ecc_cnt (

   output  [31:0]                               aux_rdata,
   input                                        aux_ren,
   input   [`ADDR_SIZE-1:0]                     cmd_addr_r,
   input                                        wr_data_zero,
   input                                        aux_wen,

   output                                       sfty_mem_adr_err,
   output                                       sfty_mem_dbe_err,
   output                                       sfty_mem_sbe_err,
   output                                       sfty_mem_sbe_overflow,
   output                                       high_prio_ras,

   input                                        iccm0_ecc_addr_err,
   input                                        iccm0_ecc_sb_err,
   input                                        iccm0_ecc_db_err,
   input  [`ICCM0_ECC_MSB-1:0]                  iccm0_ecc_syndrome,
   input  [`ICCM0_ADR_RANGE]                    iccm0_ecc_addr,


   input                                        dccm_even_ecc_addr_err,
   input                                        dccm_even_ecc_sb_err,
   input                                        dccm_even_ecc_db_err,
   input  [`DCCM_ECC_MSB-1:0]                   dccm_even_ecc_syndrome,
   input  [`DCCM_ADR_RANGE]                     dccm_even_ecc_addr,
   input                                        dccm_odd_ecc_addr_err,
   input                                        dccm_odd_ecc_sb_err,
   input                                        dccm_odd_ecc_db_err,
   input  [`DCCM_ECC_MSB-1:0]                   dccm_odd_ecc_syndrome,
   input  [`DCCM_ADR_RANGE]                     dccm_odd_ecc_addr,
   input  [`DCCM_BANKS-1:0]                     dccm_ecc_scrub_err, // scrub SB err [0] - even bank, [1] - odd bank
   input                                        x2_pass,

   input                                        ic_tag_ecc_addr_err,
   input                                        ic_tag_ecc_sb_err,
   input                                        ic_tag_ecc_db_err,
   input  [`IC_TAG_ECC_MSB-1:`IC_TAG_ECC_LSB]   ic_tag_ecc_syndrome,
   input  [`IC_IDX_RANGE]                       ic_tag_ecc_addr,

   input                                        ic_data_ecc_addr_err,
   input                                        ic_data_ecc_sb_err,
   input                                        ic_data_ecc_db_err,
   input  [`IC_DATA_ECC_MSB-1:`IC_DATA_ECC_LSB] ic_data_ecc_syndrome,
   input  [`IC_DATA_ADR_RANGE]                  ic_data_ecc_addr,

   input                                        clk,
   input                                        rst_a

);

reg   [`DATA_RANGE]           mmio_sfty_iccm_sbe_adr_synd0_r      ;
reg   [`DATA_RANGE]           mmio_sfty_iccm_sbe_adr_synd0_nxt    ;
wire                          mmio_sfty_iccm_sbe_adr_synd0_ren    ;
reg   [`DATA_RANGE]           mmio_sfty_dccm_sbe_adr_synd0_r      ;
reg   [`DATA_RANGE]           mmio_sfty_dccm_sbe_adr_synd0_nxt    ;
wire                          mmio_sfty_dccm_sbe_adr_synd0_ren    ;
reg   [`DATA_RANGE]           mmio_sfty_ic_tag_sbe_adr_synd0_r    ;
reg   [`DATA_RANGE]           mmio_sfty_ic_data_sbe_adr_synd0_r   ;
reg   [`DATA_RANGE]           mmio_sfty_ic_tag_sbe_adr_synd0_nxt  ;
reg   [`DATA_RANGE]           mmio_sfty_ic_data_sbe_adr_synd0_nxt ;
reg   [`DATA_RANGE]           mmio_sfty_iccm_dbe_adr_synd_r          ;
reg   [`DATA_RANGE]           mmio_sfty_iccm_abe_adr_synd_r          ;
reg   [`DATA_RANGE]           mmio_sfty_iccm_abe_adr_synd_nxt        ;
wire                          mmio_sfty_iccm_abe_adr_synd_ren        ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_iccm_sbe_cnt_r               ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_iccm_sbe_cnt_nxt             ;
reg                           iccm_mem_sbe_overflow                  ;
reg   [`DATA_RANGE]           mmio_sfty_iccm_dbe_adr_synd_nxt        ;
wire                          mmio_sfty_iccm_dbe_adr_synd_ren        ;
reg   [`DATA_RANGE]           mmio_sfty_dccm_dbe_adr_synd_r          ;
reg   [`DATA_RANGE]           mmio_sfty_dccm_dbe_adr_synd_nxt        ;
reg   [`DATA_RANGE]           mmio_sfty_dccm_abe_adr_synd_nxt        ;
reg   [`DATA_RANGE]           mmio_sfty_dccm_abe_adr_synd_r          ;
wire                          mmio_sfty_dccm_dbe_adr_synd_ren        ;
wire                          mmio_sfty_dccm_abe_adr_synd_ren        ;
reg                           dccm_mem_sbe_overflow                  ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_dccm_sbe_cnt_r               ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_dccm_sbe_cnt_nxt             ;

reg   [1:0]                  dccm_hard_err_cnt_r;
reg   [1:0]                  dccm_hard_err_cnt_nxt;
reg                          dccm_hard_err_cg0;
reg   [1:0]                  dccm_scrub_err_r;
reg   [1:0]                  dccm_scrub_err_nxt;
reg   [`DATA_RANGE]           mmio_sfty_ic_tag_dbe_adr_synd_r        ;
reg   [`DATA_RANGE]           mmio_sfty_ic_data_dbe_adr_synd_r       ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_ic_tag_sbe_cnt_r             ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_ic_tag_sbe_cnt_nxt           ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_ic_data_sbe_cnt_r            ;
reg   [`RAS_SBE_COUNT_RANGE]  mmio_sfty_ic_data_sbe_cnt_nxt          ;

reg   [`DATA_RANGE]           mmio_sfty_ic_tag_dbe_adr_synd_nxt      ;
reg   [`DATA_RANGE]           mmio_sfty_ic_tag_abe_adr_synd_nxt      ;
reg   [`DATA_RANGE]           mmio_sfty_ic_tag_abe_adr_synd_r        ;
reg   [`DATA_RANGE]           mmio_sfty_ic_data_abe_adr_synd_nxt     ;
reg   [`DATA_RANGE]           mmio_sfty_ic_data_abe_adr_synd_r       ;
reg   [`DATA_RANGE]           mmio_sfty_ic_data_dbe_adr_synd_nxt     ;
wire                          mmio_sfty_ic_tag_sbe_adr_synd0_ren  ;
wire                          mmio_sfty_ic_data_sbe_adr_synd0_ren ;
wire                          mmio_sfty_ic_tag_dbe_adr_synd_ren      ;
wire                          mmio_sfty_ic_tag_abe_adr_synd_ren      ;
wire                          mmio_sfty_ic_data_dbe_adr_synd_ren     ;
wire                          mmio_sfty_ic_data_abe_adr_synd_ren     ;
reg                           ic_tag_mem_sbe_overflow                ;
reg                           ic_data_mem_sbe_overflow               ;
reg                           mmio_sfty_high_prio_ras_r              ;
reg                           mmio_sfty_high_prio_ras_nxt            ;

reg   [`DATA_RANGE]           aux_rdata_nxt                          ;
reg   [`DATA_RANGE]           aux_rdata_r                            ;


assign   mmio_sfty_iccm_sbe_adr_synd0_ren    = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_ICCM_SBE_ADR_SYND0    );
assign   mmio_sfty_dccm_sbe_adr_synd0_ren    = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_DCCM_SBE_ADR_SYND0    );
assign   mmio_sfty_ic_tag_sbe_adr_synd0_ren  = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_IC_TAG_SBE_ADR_SYND0  );
assign   mmio_sfty_ic_data_sbe_adr_synd0_ren = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_IC_DATA_SBE_ADR_SYND0 );
assign   mmio_sfty_dccm_dbe_adr_synd_ren        = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_DCCM_DBE_ADR_SYND      );
assign   mmio_sfty_dccm_abe_adr_synd_ren        = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_DCCM_ABE_ADR_SYND      );
assign   mmio_sfty_ic_tag_dbe_adr_synd_ren      = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_IC_TAG_DBE_ADR_SYND    );
assign   mmio_sfty_ic_tag_abe_adr_synd_ren      = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_IC_TAG_ABE_ADR_SYND    );
assign   mmio_sfty_ic_data_dbe_adr_synd_ren     = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_IC_DATA_DBE_ADR_SYND   );
assign   mmio_sfty_ic_data_abe_adr_synd_ren     = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_IC_DATA_ABE_ADR_SYND   );

assign   mmio_sfty_iccm_dbe_adr_synd_ren        = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_ICCM_DBE_ADR_SYND      );
assign   mmio_sfty_iccm_abe_adr_synd_ren        = aux_ren & (cmd_addr_r[8:0] == `MMIO_SFTY_ICCM_ABE_ADR_SYND      );


always @*
begin
   mmio_sfty_iccm_dbe_adr_synd_nxt  = mmio_sfty_iccm_dbe_adr_synd_r;

   if( mmio_sfty_iccm_dbe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_iccm_dbe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_iccm_dbe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & iccm0_ecc_db_err )
   begin
      mmio_sfty_iccm_dbe_adr_synd_nxt = {1'b1,iccm0_ecc_syndrome,7'b0,iccm0_ecc_addr[`ICCM0_ADR_RANGE]};
   end
end

always @*
begin
   mmio_sfty_iccm_abe_adr_synd_nxt  = mmio_sfty_iccm_abe_adr_synd_r;

   if( mmio_sfty_iccm_abe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_iccm_abe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_iccm_abe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & iccm0_ecc_addr_err )
   begin
      mmio_sfty_iccm_abe_adr_synd_nxt = {1'b1,iccm0_ecc_syndrome,7'b0,iccm0_ecc_addr[`ICCM0_ADR_RANGE]};
   end
end

wire [`SBE_ADDR_DEPTH-1:0] mmio_sfty_iccm_sbe_adr_synd_vld;
wire                       mmio_sfty_iccm_sbe_adr_match;
assign mmio_sfty_iccm_sbe_adr_match = 1'b0
   | (mmio_sfty_iccm_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL] & 
      (mmio_sfty_iccm_sbe_adr_synd0_r[16:0] == iccm0_ecc_addr[`ICCM0_ADR_RANGE]));

assign mmio_sfty_iccm_sbe_adr_synd_vld = {
   (mmio_sfty_iccm_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL]) };
always @*
begin
   iccm_mem_sbe_overflow = 1'b0;
   mmio_sfty_iccm_sbe_adr_synd0_nxt = mmio_sfty_iccm_sbe_adr_synd0_r;

   if( mmio_sfty_iccm_sbe_adr_synd0_ren == 1'b1 )
   begin
      mmio_sfty_iccm_sbe_adr_synd0_nxt = `DATA_SIZE'b0;
   end
   if( iccm0_ecc_sb_err  & (~mmio_sfty_iccm_sbe_adr_match) )
   begin
      casez ( mmio_sfty_iccm_sbe_adr_synd_vld )
         1'b0 :   begin
                     mmio_sfty_iccm_sbe_adr_synd0_nxt = {1'b1,iccm0_ecc_syndrome,7'b0,iccm0_ecc_addr[`ICCM0_ADR_RANGE]};
                  end
         default : iccm_mem_sbe_overflow = 1'b1;
      endcase
   end
end



always @*
begin
   mmio_sfty_dccm_dbe_adr_synd_nxt  = mmio_sfty_dccm_dbe_adr_synd_r;

   if( mmio_sfty_dccm_dbe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_dccm_dbe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_dccm_dbe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & dccm_even_ecc_db_err )
   begin
      mmio_sfty_dccm_dbe_adr_synd_nxt = {1'b1,dccm_even_ecc_syndrome,6'b0,dccm_even_ecc_addr[`DCCM_ADR_RANGE],1'b0};
   end
   else if( (mmio_sfty_dccm_dbe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & dccm_odd_ecc_db_err )
   begin
      mmio_sfty_dccm_dbe_adr_synd_nxt = {1'b1,dccm_odd_ecc_syndrome,6'b0,dccm_odd_ecc_addr[`DCCM_ADR_RANGE],1'b1};
   end
end

always @*
begin
   mmio_sfty_dccm_abe_adr_synd_nxt  = mmio_sfty_dccm_abe_adr_synd_r;

   if( mmio_sfty_dccm_abe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_dccm_abe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_dccm_abe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & dccm_even_ecc_addr_err )
   begin
      mmio_sfty_dccm_abe_adr_synd_nxt = {1'b1,dccm_even_ecc_syndrome,6'b0,dccm_even_ecc_addr[`DCCM_ADR_RANGE],1'b0};
   end
   else if( (mmio_sfty_dccm_abe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & dccm_odd_ecc_addr_err )
   begin
      mmio_sfty_dccm_abe_adr_synd_nxt = {1'b1,dccm_odd_ecc_syndrome,6'b0,dccm_odd_ecc_addr[`DCCM_ADR_RANGE],1'b1};
   end
end

wire [`SBE_ADDR_DEPTH-1:0] mmio_sfty_dccm_sbe_adr_synd_vld;
wire                       mmio_sfty_dccm_sbe_even_adr_match;
wire                       mmio_sfty_dccm_sbe_odd_adr_match;
assign mmio_sfty_dccm_sbe_adr_synd_vld = {
   mmio_sfty_dccm_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL] };
assign mmio_sfty_dccm_sbe_odd_adr_match = 1'b0
   | (mmio_sfty_dccm_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL] & mmio_sfty_dccm_sbe_adr_synd0_r[0] & (mmio_sfty_dccm_sbe_adr_synd0_r[17:1] != dccm_odd_ecc_addr[`DCCM_ADR_RANGE]));

assign mmio_sfty_dccm_sbe_even_adr_match = 1'b0
   | (mmio_sfty_dccm_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL] & (~mmio_sfty_dccm_sbe_adr_synd0_r[0]) & (mmio_sfty_dccm_sbe_adr_synd0_r[17:1] == dccm_even_ecc_addr[`DCCM_ADR_RANGE]));

always @*
begin
   dccm_mem_sbe_overflow = 1'b0;
   mmio_sfty_dccm_sbe_adr_synd0_nxt = mmio_sfty_dccm_sbe_adr_synd0_r;

   if( mmio_sfty_dccm_sbe_adr_synd0_ren == 1'b1 )
   begin
      mmio_sfty_dccm_sbe_adr_synd0_nxt = `DATA_SIZE'b0;
   end
   if( dccm_even_ecc_sb_err & (~mmio_sfty_dccm_sbe_even_adr_match) & dccm_odd_ecc_sb_err & (~mmio_sfty_dccm_sbe_odd_adr_match) )
   begin
      casez ( mmio_sfty_dccm_sbe_adr_synd_vld )
         1'b0 :   begin
                     mmio_sfty_dccm_sbe_adr_synd0_nxt = {1'b1,dccm_even_ecc_syndrome,6'b0,dccm_even_ecc_addr[`DCCM_ADR_RANGE],1'b0};
                     dccm_mem_sbe_overflow = 1'b1;
                  end
         default : dccm_mem_sbe_overflow = 1'b1;
      endcase
   end
   else if( dccm_even_ecc_sb_err & (~mmio_sfty_dccm_sbe_even_adr_match) )
   begin
      casez ( mmio_sfty_dccm_sbe_adr_synd_vld )
         1'b0 :   begin
                     mmio_sfty_dccm_sbe_adr_synd0_nxt = {1'b1,dccm_even_ecc_syndrome,6'b0,dccm_even_ecc_addr[`DCCM_ADR_RANGE],1'b0};
                  end
         default : dccm_mem_sbe_overflow = 1'b1;
      endcase
   end
   else if( dccm_odd_ecc_sb_err & (~mmio_sfty_dccm_sbe_odd_adr_match) )
   begin
      casez ( mmio_sfty_dccm_sbe_adr_synd_vld )
         1'b0 :   begin
                     mmio_sfty_dccm_sbe_adr_synd0_nxt = {1'b1,dccm_odd_ecc_syndrome,6'b0,dccm_odd_ecc_addr[`DCCM_ADR_RANGE],1'b1};
                  end
         default : dccm_mem_sbe_overflow = 1'b1;
      endcase
   end
end

always @*
begin : dccm_hard_err_cnt_PROC
  dccm_hard_err_cg0     = (|dccm_hard_err_cnt_r)
                        | (|dccm_ecc_scrub_err)
                        ;
  dccm_hard_err_cnt_nxt = dccm_hard_err_cnt_r;
  dccm_scrub_err_nxt    = dccm_scrub_err_r;

  if (x2_pass)
  begin
    // Reset counter on commit of any instruction
    dccm_hard_err_cnt_nxt = 2'b00;
    dccm_scrub_err_nxt    = 2'b00;
  end
  else if (|(dccm_ecc_scrub_err) & ~dccm_hard_err_cnt_r[1])
  begin
    // Inc counter only if no overflow beyond count value '2'

    if (dccm_hard_err_cnt_r == 2'b00)
    begin
      dccm_hard_err_cnt_nxt = dccm_hard_err_cnt_r + 1'b1;
      dccm_scrub_err_nxt    = dccm_ecc_scrub_err;
    end
    else 
    begin
      dccm_scrub_err_nxt    = dccm_scrub_err_r | dccm_ecc_scrub_err;
      if (|(dccm_scrub_err_r & dccm_ecc_scrub_err))
      begin
        // Inc counter only if scrubbing the same bank as previous replay
        dccm_hard_err_cnt_nxt = dccm_hard_err_cnt_r + 1'b1;
      end
    end
  end
end

always @*
begin
   mmio_sfty_ic_tag_dbe_adr_synd_nxt = mmio_sfty_ic_tag_dbe_adr_synd_r;

   if( mmio_sfty_ic_tag_dbe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_ic_tag_dbe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_ic_tag_dbe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & ic_tag_ecc_db_err )
   begin
      mmio_sfty_ic_tag_dbe_adr_synd_nxt = {1'b1,1'b0,ic_tag_ecc_syndrome,16'b0,ic_tag_ecc_addr[`IC_IDX_RANGE]};
   end
end

always @*
begin
   mmio_sfty_ic_tag_abe_adr_synd_nxt  = mmio_sfty_ic_tag_abe_adr_synd_r;

   if( mmio_sfty_ic_tag_abe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_ic_tag_abe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_ic_tag_abe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & ic_tag_ecc_addr_err )
   begin
      mmio_sfty_ic_tag_abe_adr_synd_nxt = {1'b1,1'b0,ic_tag_ecc_syndrome,16'b0,ic_tag_ecc_addr[`IC_IDX_RANGE]};
   end
end


always @*
begin
   mmio_sfty_ic_data_dbe_adr_synd_nxt = mmio_sfty_ic_data_dbe_adr_synd_r;

   if( mmio_sfty_ic_data_dbe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_ic_data_dbe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_ic_data_dbe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & ic_data_ecc_db_err )
   begin
      mmio_sfty_ic_data_dbe_adr_synd_nxt = {1'b1,ic_data_ecc_syndrome,13'b0,ic_data_ecc_addr[`IC_DATA_ADR_RANGE]};
   end
end

always @*
begin
   mmio_sfty_ic_data_abe_adr_synd_nxt  = mmio_sfty_ic_data_abe_adr_synd_r;

   if( mmio_sfty_ic_data_abe_adr_synd_ren == 1'b1 )
   begin
      mmio_sfty_ic_data_abe_adr_synd_nxt = `DATA_SIZE'b0;
   end
   else if( (mmio_sfty_ic_data_abe_adr_synd_r[`RAS_ECC_ERR_CNT_VAL] == 1'b0) & ic_data_ecc_addr_err )
   begin
      mmio_sfty_ic_data_abe_adr_synd_nxt = {1'b1,ic_data_ecc_syndrome,13'b0,ic_data_ecc_addr[`IC_DATA_ADR_RANGE]};
   end
end

wire [`SBE_ADDR_DEPTH-1:0] mmio_sfty_ic_tag_sbe_adr_synd_vld;
wire                       mmio_sfty_ic_tag_sbe_adr_match;
assign mmio_sfty_ic_tag_sbe_adr_synd_vld = {
                                                mmio_sfty_ic_tag_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL]};
assign mmio_sfty_ic_tag_sbe_adr_match = 1'b0
   | (mmio_sfty_ic_tag_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL] & mmio_sfty_ic_tag_sbe_adr_synd0_r[7:0] == ic_tag_ecc_addr[`IC_IDX_RANGE]);


always @*
begin
   ic_tag_mem_sbe_overflow = 1'b0;
   mmio_sfty_ic_tag_sbe_adr_synd0_nxt = mmio_sfty_ic_tag_sbe_adr_synd0_r;

   if( mmio_sfty_ic_tag_sbe_adr_synd0_ren == 1'b1 )
   begin
      mmio_sfty_ic_tag_sbe_adr_synd0_nxt = `DATA_SIZE'b0;
   end
   if( ic_tag_ecc_sb_err & (~mmio_sfty_ic_tag_sbe_adr_match))
   begin
      casez ( mmio_sfty_ic_tag_sbe_adr_synd_vld )
         `SBE_ADDR_DEPTH'b0   : mmio_sfty_ic_tag_sbe_adr_synd0_nxt = {1'b1,1'b0,ic_tag_ecc_syndrome,16'b0,ic_tag_ecc_addr[`IC_IDX_RANGE]};
         default : ic_tag_mem_sbe_overflow = 1'b1;
      endcase
   end
end

wire [`SBE_ADDR_DEPTH-1:0] mmio_sfty_ic_data_sbe_adr_synd_vld;
wire                       mmio_sfty_ic_data_sbe_adr_match;
assign mmio_sfty_ic_data_sbe_adr_synd_vld = {
                                                mmio_sfty_ic_data_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL]};

assign mmio_sfty_ic_data_sbe_adr_match = 1'b0
   | (mmio_sfty_ic_data_sbe_adr_synd0_r[`RAS_ECC_ERR_CNT_VAL] & (mmio_sfty_ic_data_sbe_adr_synd0_r[10:0] == ic_data_ecc_addr[`IC_DATA_ADR_RANGE]));


always @*
begin
   ic_data_mem_sbe_overflow = 1'b0;
   mmio_sfty_ic_data_sbe_adr_synd0_nxt = mmio_sfty_ic_data_sbe_adr_synd0_r;

   if( mmio_sfty_ic_data_sbe_adr_synd0_ren == 1'b1 )
   begin
      mmio_sfty_ic_data_sbe_adr_synd0_nxt = `DATA_SIZE'b0;
   end
   if( ic_data_ecc_sb_err & (~mmio_sfty_ic_data_sbe_adr_match) )
   begin
      casez ( mmio_sfty_ic_data_sbe_adr_synd_vld )
         `SBE_ADDR_DEPTH'b0   : mmio_sfty_ic_data_sbe_adr_synd0_nxt = {1'b1,ic_data_ecc_syndrome,13'b0,ic_data_ecc_addr[`IC_DATA_ADR_RANGE]};
         default : ic_data_mem_sbe_overflow = 1'b1;
      endcase
   end
end


always @*
begin
   aux_rdata_nxt = aux_rdata_r;
   if ( aux_ren )
   begin
      case ( cmd_addr_r[8:0] )
         `MMIO_SFTY_SBE_CNT                  : aux_rdata_nxt = {16'h0,
                                                                  mmio_sfty_ic_data_sbe_cnt_r,
                                                                  mmio_sfty_ic_tag_sbe_cnt_r,
                                                                  mmio_sfty_dccm_sbe_cnt_r,
                                                                  mmio_sfty_iccm_sbe_cnt_r};
         `MMIO_SFTY_ICCM_SBE_ADR_SYND0      : aux_rdata_nxt = mmio_sfty_iccm_sbe_adr_synd0_r   ;
         `MMIO_SFTY_DCCM_SBE_ADR_SYND0      : aux_rdata_nxt = mmio_sfty_dccm_sbe_adr_synd0_r   ;
         `MMIO_SFTY_IC_TAG_SBE_ADR_SYND0    : aux_rdata_nxt = mmio_sfty_ic_tag_sbe_adr_synd0_r ;
         `MMIO_SFTY_IC_DATA_SBE_ADR_SYND0   : aux_rdata_nxt = mmio_sfty_ic_data_sbe_adr_synd0_r;
         `MMIO_SFTY_ICCM_DBE_ADR_SYND        : aux_rdata_nxt = mmio_sfty_iccm_dbe_adr_synd_r       ;
         `MMIO_SFTY_ICCM_ABE_ADR_SYND        : aux_rdata_nxt = mmio_sfty_iccm_abe_adr_synd_r       ;
         `MMIO_SFTY_DCCM_DBE_ADR_SYND        : aux_rdata_nxt = mmio_sfty_dccm_dbe_adr_synd_r       ;
         `MMIO_SFTY_DCCM_ABE_ADR_SYND        : aux_rdata_nxt = mmio_sfty_dccm_abe_adr_synd_r       ;
         `MMIO_SFTY_IC_TAG_DBE_ADR_SYND      : aux_rdata_nxt = mmio_sfty_ic_tag_dbe_adr_synd_r     ;
         `MMIO_SFTY_IC_TAG_ABE_ADR_SYND      : aux_rdata_nxt = mmio_sfty_ic_tag_abe_adr_synd_r     ;
         `MMIO_SFTY_IC_DATA_ABE_ADR_SYND     : aux_rdata_nxt = mmio_sfty_ic_data_abe_adr_synd_r    ;
         `MMIO_SFTY_IC_DATA_DBE_ADR_SYND     : aux_rdata_nxt = mmio_sfty_ic_data_dbe_adr_synd_r    ;
         `MMIO_SFTY_HIGH_PRIO_RAS            : aux_rdata_nxt = {31'h0,mmio_sfty_high_prio_ras_r}   ;
         default                             : aux_rdata_nxt = `DATA_SIZE'h0;
      endcase
   end
end

always @* 
begin
   mmio_sfty_high_prio_ras_nxt    = mmio_sfty_high_prio_ras_r;
   if( aux_wen & wr_data_zero & (cmd_addr_r[8:0] == `MMIO_SFTY_HIGH_PRIO_RAS) )
      mmio_sfty_high_prio_ras_nxt = 1'b0;
   else if (high_prio_ras)
      mmio_sfty_high_prio_ras_nxt = 1'b1;
end

always @* 
begin
   mmio_sfty_ic_tag_sbe_cnt_nxt   = mmio_sfty_ic_tag_sbe_cnt_r;
   if( aux_wen & wr_data_zero & (cmd_addr_r[8:0] == `MMIO_SFTY_SBE_CNT) )
      mmio_sfty_ic_tag_sbe_cnt_nxt = `RAS_SBE_COUNT_WIDTH'b0;
   else if (( ic_tag_ecc_sb_err )  & (mmio_sfty_ic_tag_sbe_cnt_r != 4'hF))
      mmio_sfty_ic_tag_sbe_cnt_nxt = mmio_sfty_ic_tag_sbe_cnt_r + 4'h1;
end
always @* 
begin
   mmio_sfty_ic_data_sbe_cnt_nxt   = mmio_sfty_ic_data_sbe_cnt_r;
   if( aux_wen & wr_data_zero & (cmd_addr_r[8:0] == `MMIO_SFTY_SBE_CNT) )
      mmio_sfty_ic_data_sbe_cnt_nxt = `RAS_SBE_COUNT_WIDTH'b0;
   else if (( ic_data_ecc_sb_err )  & (mmio_sfty_ic_data_sbe_cnt_r != 4'hF))
      mmio_sfty_ic_data_sbe_cnt_nxt = mmio_sfty_ic_data_sbe_cnt_r + 4'h1;
end

always @* 
begin
   mmio_sfty_iccm_sbe_cnt_nxt = mmio_sfty_iccm_sbe_cnt_r;
   if( aux_wen & wr_data_zero & (cmd_addr_r[8:0] == `MMIO_SFTY_SBE_CNT) )
      mmio_sfty_iccm_sbe_cnt_nxt = `RAS_SBE_COUNT_WIDTH'b0;
   else if (( iccm0_ecc_sb_err )  & (mmio_sfty_iccm_sbe_cnt_r != 4'hF))
      mmio_sfty_iccm_sbe_cnt_nxt = mmio_sfty_iccm_sbe_cnt_r + 4'h1;
end

always @* 
begin
   mmio_sfty_dccm_sbe_cnt_nxt = mmio_sfty_dccm_sbe_cnt_r;
   if( aux_wen & wr_data_zero & (cmd_addr_r[8:0] == `MMIO_SFTY_SBE_CNT) )
      mmio_sfty_dccm_sbe_cnt_nxt = `RAS_SBE_COUNT_WIDTH'b0;
   else if (( dccm_even_ecc_sb_err | dccm_odd_ecc_sb_err )  & (mmio_sfty_dccm_sbe_cnt_r != 4'hF))
      mmio_sfty_dccm_sbe_cnt_nxt = mmio_sfty_dccm_sbe_cnt_r + 4'h1;
end

always @(posedge clk or posedge rst_a)
begin: clocked_ff_PROC
   if (rst_a)
   begin
      mmio_sfty_iccm_sbe_adr_synd0_r   <= `DATA_SIZE'b0;
      mmio_sfty_dccm_sbe_adr_synd0_r   <= `DATA_SIZE'b0;
      mmio_sfty_ic_tag_sbe_adr_synd0_r <= `DATA_SIZE'b0;
      mmio_sfty_ic_data_sbe_adr_synd0_r<= `DATA_SIZE'b0;
      mmio_sfty_iccm_dbe_adr_synd_r       <= `DATA_SIZE'b0;
      mmio_sfty_iccm_abe_adr_synd_r       <= `DATA_SIZE'b0;
      mmio_sfty_iccm_sbe_cnt_r            <= `RAS_SBE_COUNT_WIDTH'b0;
      mmio_sfty_dccm_dbe_adr_synd_r       <= `DATA_SIZE'b0;
      mmio_sfty_dccm_abe_adr_synd_r       <= `DATA_SIZE'b0;
      mmio_sfty_dccm_sbe_cnt_r            <= `RAS_SBE_COUNT_WIDTH'b0;
      mmio_sfty_ic_tag_dbe_adr_synd_r     <= `DATA_SIZE'b0;
      mmio_sfty_ic_data_dbe_adr_synd_r    <= `DATA_SIZE'b0;
      mmio_sfty_ic_tag_abe_adr_synd_r     <= `DATA_SIZE'b0;
      mmio_sfty_ic_data_abe_adr_synd_r    <= `DATA_SIZE'b0;
      mmio_sfty_ic_tag_sbe_cnt_r          <= `RAS_SBE_COUNT_WIDTH'b0;
      mmio_sfty_ic_data_sbe_cnt_r         <= `RAS_SBE_COUNT_WIDTH'b0;
      mmio_sfty_high_prio_ras_r           <= 1'b0;
      aux_rdata_r                         <= `DATA_SIZE'b0;
   end
   else
   begin
      mmio_sfty_iccm_sbe_adr_synd0_r   <= mmio_sfty_iccm_sbe_adr_synd0_nxt    ;
      mmio_sfty_dccm_sbe_adr_synd0_r   <= mmio_sfty_dccm_sbe_adr_synd0_nxt    ;
      mmio_sfty_ic_tag_sbe_adr_synd0_r <= mmio_sfty_ic_tag_sbe_adr_synd0_nxt  ;
      mmio_sfty_ic_data_sbe_adr_synd0_r<= mmio_sfty_ic_data_sbe_adr_synd0_nxt ;
      mmio_sfty_iccm_dbe_adr_synd_r       <= mmio_sfty_iccm_dbe_adr_synd_nxt        ;
      mmio_sfty_iccm_abe_adr_synd_r       <= mmio_sfty_iccm_abe_adr_synd_nxt        ;
      mmio_sfty_iccm_sbe_cnt_r            <= mmio_sfty_iccm_sbe_cnt_nxt             ;
      mmio_sfty_dccm_dbe_adr_synd_r       <= mmio_sfty_dccm_dbe_adr_synd_nxt        ;
      mmio_sfty_dccm_abe_adr_synd_r       <= mmio_sfty_dccm_abe_adr_synd_nxt        ;
      mmio_sfty_dccm_sbe_cnt_r            <= mmio_sfty_dccm_sbe_cnt_nxt             ;
      mmio_sfty_ic_tag_dbe_adr_synd_r     <= mmio_sfty_ic_tag_dbe_adr_synd_nxt      ;
      mmio_sfty_ic_data_dbe_adr_synd_r    <= mmio_sfty_ic_data_dbe_adr_synd_nxt     ;
      mmio_sfty_ic_tag_abe_adr_synd_r     <= mmio_sfty_ic_tag_abe_adr_synd_nxt      ;
      mmio_sfty_ic_data_abe_adr_synd_r    <= mmio_sfty_ic_data_abe_adr_synd_nxt     ;
      mmio_sfty_ic_tag_sbe_cnt_r          <= mmio_sfty_ic_tag_sbe_cnt_nxt           ;
      mmio_sfty_ic_data_sbe_cnt_r         <= mmio_sfty_ic_data_sbe_cnt_nxt          ;
      mmio_sfty_high_prio_ras_r           <= mmio_sfty_high_prio_ras_nxt            ;
      aux_rdata_r                         <= aux_rdata_nxt                          ;
   end
end

always @(posedge clk or posedge rst_a)
begin : dccm_hard_err_reg_PROC
  if (rst_a == 1'b1)
  begin
    dccm_hard_err_cnt_r <= 2'b00;
    dccm_scrub_err_r    <= 2'b00;
  end
  else 
  begin
    if (dccm_hard_err_cg0 == 1'b1)
    begin
      dccm_hard_err_cnt_r <= dccm_hard_err_cnt_nxt;
      dccm_scrub_err_r    <= dccm_scrub_err_nxt;
    end
  end
end

assign aux_rdata  =  aux_rdata_r;

assign sfty_mem_sbe_err       = 1'b0
                                 | iccm0_ecc_sb_err 
                                 | dccm_even_ecc_sb_err | dccm_odd_ecc_sb_err
                                 | ic_data_ecc_sb_err
                                 ;
assign sfty_mem_dbe_err       = 1'b0
                                 | iccm0_ecc_db_err
                                 | dccm_even_ecc_db_err | dccm_odd_ecc_db_err
                                 | ic_tag_ecc_sb_err | ic_tag_ecc_db_err | ic_data_ecc_db_err
                                 ;
assign sfty_mem_adr_err       = 1'b0
                                 | iccm0_ecc_addr_err 
                                 | dccm_even_ecc_addr_err | dccm_odd_ecc_addr_err
                                 | ic_tag_ecc_addr_err | ic_data_ecc_addr_err
                                 ;
assign sfty_mem_sbe_overflow  = 1'b0
                                 | iccm_mem_sbe_overflow
                                 | dccm_mem_sbe_overflow
                                 | ic_tag_mem_sbe_overflow | ic_data_mem_sbe_overflow
                                 ;

assign high_prio_ras = dccm_hard_err_cnt_r[1];


endmodule 

