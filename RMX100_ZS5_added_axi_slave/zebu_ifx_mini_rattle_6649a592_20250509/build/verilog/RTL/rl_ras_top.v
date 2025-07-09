// Library ARCv5EM-3.5.999999999

`include "defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"

module rl_ras_top (
    input                                       ibp_mmio_cmd_valid,
    input  [3:0]                                ibp_mmio_cmd_cache,
    input                                       ibp_mmio_cmd_burst_size,
    input                                       ibp_mmio_cmd_read,
    input                                       ibp_mmio_cmd_aux,
    output                                      ibp_mmio_cmd_accept,
    input  [`ADDR_RANGE]                        ibp_mmio_cmd_addr,
    input                                       ibp_mmio_cmd_excl,
    input  [5:0]                                ibp_mmio_cmd_atomic,
    input  [2:0]                                ibp_mmio_cmd_data_size,
    input  [1:0]                                ibp_mmio_cmd_prot,

    input                                       ibp_mmio_wr_valid,
    input                                       ibp_mmio_wr_last,
    output                                      ibp_mmio_wr_accept,
    input  [3:0]                                ibp_mmio_wr_mask,
    input  [31:0]                               ibp_mmio_wr_data,
    
    output                                      ibp_mmio_rd_valid,
    output                                      ibp_mmio_rd_err,
    output                                      ibp_mmio_rd_excl_ok,
    output                                      ibp_mmio_rd_last,
    input                                       ibp_mmio_rd_accept,
    output  [31:0]                              ibp_mmio_rd_data,
    
    output                                      ibp_mmio_wr_done,
    output                                      ibp_mmio_wr_excl_okay,
    output                                      ibp_mmio_wr_err,
    input                                       ibp_mmio_wr_resp_accept,

    output                                      sfty_mem_adr_err,
    output                                      sfty_mem_dbe_err,
    output                                      sfty_mem_sbe_err,
    output                                      sfty_mem_sbe_overflow,

    output                                      high_prio_ras,

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

    input                     clk,
    input                     rst_a

);

wire  [31:0]            aux_rdata_r ;
wire                    aux_ren     ;
wire  [`ADDR_SIZE-1:0]  cmd_addr_r  ;
wire                    aux_wen     ;
wire                    wr_data_zero;

rl_ibp_target_wrapper u_rl_ibp_target_wrapper (
    .ibp_mmio_cmd_valid      ( ibp_mmio_cmd_valid      ),
    .ibp_mmio_cmd_cache      ( ibp_mmio_cmd_cache      ),
    .ibp_mmio_cmd_burst_size ( ibp_mmio_cmd_burst_size ),
    .ibp_mmio_cmd_read       ( ibp_mmio_cmd_read       ),
    .ibp_mmio_cmd_aux        ( ibp_mmio_cmd_aux        ),
    .ibp_mmio_cmd_accept     ( ibp_mmio_cmd_accept     ),
    .ibp_mmio_cmd_addr       ( ibp_mmio_cmd_addr       ),
    .ibp_mmio_cmd_excl       ( ibp_mmio_cmd_excl       ),
    .ibp_mmio_cmd_atomic     ( ibp_mmio_cmd_atomic     ),
    .ibp_mmio_cmd_data_size  ( ibp_mmio_cmd_data_size  ),
    .ibp_mmio_cmd_prot       ( ibp_mmio_cmd_prot       ),
    .ibp_mmio_wr_valid       ( ibp_mmio_wr_valid       ),
    .ibp_mmio_wr_last        ( ibp_mmio_wr_last        ),
    .ibp_mmio_wr_accept      ( ibp_mmio_wr_accept      ),
    .ibp_mmio_wr_mask        ( ibp_mmio_wr_mask        ),
    .ibp_mmio_wr_data        ( ibp_mmio_wr_data        ),
    .ibp_mmio_rd_valid       ( ibp_mmio_rd_valid       ),
    .ibp_mmio_rd_err         ( ibp_mmio_rd_err         ),
    .ibp_mmio_rd_excl_ok     ( ibp_mmio_rd_excl_ok     ),
    .ibp_mmio_rd_last        ( ibp_mmio_rd_last        ),
    .ibp_mmio_rd_accept      ( ibp_mmio_rd_accept      ),
    .ibp_mmio_rd_data        ( ibp_mmio_rd_data        ),
    .ibp_mmio_wr_done        ( ibp_mmio_wr_done        ),
    .ibp_mmio_wr_excl_okay   ( ibp_mmio_wr_excl_okay   ),
    .ibp_mmio_wr_err         ( ibp_mmio_wr_err         ),
    .ibp_mmio_wr_resp_accept ( ibp_mmio_wr_resp_accept ),
    .aux_rdata_r             ( aux_rdata_r             ),
    .aux_ren                 ( aux_ren                 ),
    .cmd_addr_r              ( cmd_addr_r              ),
    .aux_wen                 ( aux_wen                 ),
    .wr_data_zero            ( wr_data_zero            ),
    .clk                     ( clk                     ),
    .rst_a                   ( rst_a                   ) 
);

rl_ecc_cnt u_rl_ecc_cnt (

   .aux_rdata               ( aux_rdata_r             ),
   .aux_ren                 ( aux_ren                 ),
   .aux_wen                 ( aux_wen                 ),
   .wr_data_zero            ( wr_data_zero            ),
   .cmd_addr_r              ( cmd_addr_r              ),
   .sfty_mem_adr_err        ( sfty_mem_adr_err        ),
   .sfty_mem_dbe_err        ( sfty_mem_dbe_err        ),
   .sfty_mem_sbe_err        ( sfty_mem_sbe_err        ),
   .sfty_mem_sbe_overflow   ( sfty_mem_sbe_overflow   ),

   .high_prio_ras           ( high_prio_ras           ),
   .iccm0_ecc_addr_err ( iccm0_ecc_addr_err ),
   .iccm0_ecc_sb_err   ( iccm0_ecc_sb_err   ),
   .iccm0_ecc_db_err   ( iccm0_ecc_db_err   ),
   .iccm0_ecc_syndrome ( iccm0_ecc_syndrome ),
   .iccm0_ecc_addr     ( iccm0_ecc_addr     ),


   .dccm_even_ecc_addr_err  ( dccm_even_ecc_addr_err  ),
   .dccm_even_ecc_sb_err    ( dccm_even_ecc_sb_err    ),
   .dccm_even_ecc_db_err    ( dccm_even_ecc_db_err    ),
   .dccm_even_ecc_syndrome  ( dccm_even_ecc_syndrome  ),
   .dccm_even_ecc_addr      ( dccm_even_ecc_addr      ),

   .dccm_odd_ecc_addr_err   ( dccm_odd_ecc_addr_err   ),
   .dccm_odd_ecc_sb_err     ( dccm_odd_ecc_sb_err     ),
   .dccm_odd_ecc_db_err     ( dccm_odd_ecc_db_err     ),
   .dccm_odd_ecc_syndrome   ( dccm_odd_ecc_syndrome   ),
   .dccm_odd_ecc_addr       ( dccm_odd_ecc_addr       ),

   .dccm_ecc_scrub_err      (dccm_ecc_scrub_err       ),
   .x2_pass                 (x2_pass                  ),

   .ic_tag_ecc_addr_err     ( ic_tag_ecc_addr_err     ),
   .ic_tag_ecc_sb_err       ( ic_tag_ecc_sb_err       ),
   .ic_tag_ecc_db_err       ( ic_tag_ecc_db_err       ),
   .ic_tag_ecc_syndrome     ( ic_tag_ecc_syndrome     ),
   .ic_tag_ecc_addr         ( ic_tag_ecc_addr         ),

   .ic_data_ecc_addr_err    ( ic_data_ecc_addr_err    ),
   .ic_data_ecc_sb_err      ( ic_data_ecc_sb_err      ),
   .ic_data_ecc_db_err      ( ic_data_ecc_db_err      ),
   .ic_data_ecc_syndrome    ( ic_data_ecc_syndrome    ),
   .ic_data_ecc_addr        ( ic_data_ecc_addr        ),

   .clk                     ( clk                     ),
   .rst_a                   ( rst_a                   ) 
 );

endmodule
