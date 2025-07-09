// Library ARCv2MSS-2.1.999999999
`include "alb_mss_bus_switch_defines.v"
module alb_mss_bus_switch (
  // master side

  input                                   ahb_hbs_ibp_cmd_valid,
  output                                  ahb_hbs_ibp_cmd_accept,
  input                                   ahb_hbs_ibp_cmd_read,
  input   [42                -1:0]       ahb_hbs_ibp_cmd_addr,
  input                                   ahb_hbs_ibp_cmd_wrap,
  input   [3-1:0]       ahb_hbs_ibp_cmd_data_size,
  input   [4-1:0]       ahb_hbs_ibp_cmd_burst_size,
  input   [2-1:0]       ahb_hbs_ibp_cmd_prot,
  input   [4-1:0]       ahb_hbs_ibp_cmd_cache,
  input                                   ahb_hbs_ibp_cmd_lock,
  input                                   ahb_hbs_ibp_cmd_excl,

  output                                  ahb_hbs_ibp_rd_valid,
  output                                  ahb_hbs_ibp_rd_excl_ok,
  input                                   ahb_hbs_ibp_rd_accept,
  output                                  ahb_hbs_ibp_err_rd,
  output  [32               -1:0]        ahb_hbs_ibp_rd_data,
  output                                  ahb_hbs_ibp_rd_last,

  input                                   ahb_hbs_ibp_wr_valid,
  output                                  ahb_hbs_ibp_wr_accept,
  input   [32               -1:0]        ahb_hbs_ibp_wr_data,
  input   [(32         /8)  -1:0]        ahb_hbs_ibp_wr_mask,
  input                                   ahb_hbs_ibp_wr_last,

  output                                  ahb_hbs_ibp_wr_done,
  output                                  ahb_hbs_ibp_wr_excl_done,
  output                                  ahb_hbs_ibp_err_wr,
  input                                   ahb_hbs_ibp_wr_resp_accept,


  input                                   dbu_per_ahb_hbs_ibp_cmd_valid,
  output                                  dbu_per_ahb_hbs_ibp_cmd_accept,
  input                                   dbu_per_ahb_hbs_ibp_cmd_read,
  input   [42                -1:0]       dbu_per_ahb_hbs_ibp_cmd_addr,
  input                                   dbu_per_ahb_hbs_ibp_cmd_wrap,
  input   [3-1:0]       dbu_per_ahb_hbs_ibp_cmd_data_size,
  input   [4-1:0]       dbu_per_ahb_hbs_ibp_cmd_burst_size,
  input   [2-1:0]       dbu_per_ahb_hbs_ibp_cmd_prot,
  input   [4-1:0]       dbu_per_ahb_hbs_ibp_cmd_cache,
  input                                   dbu_per_ahb_hbs_ibp_cmd_lock,
  input                                   dbu_per_ahb_hbs_ibp_cmd_excl,

  output                                  dbu_per_ahb_hbs_ibp_rd_valid,
  output                                  dbu_per_ahb_hbs_ibp_rd_excl_ok,
  input                                   dbu_per_ahb_hbs_ibp_rd_accept,
  output                                  dbu_per_ahb_hbs_ibp_err_rd,
  output  [32               -1:0]        dbu_per_ahb_hbs_ibp_rd_data,
  output                                  dbu_per_ahb_hbs_ibp_rd_last,

  input                                   dbu_per_ahb_hbs_ibp_wr_valid,
  output                                  dbu_per_ahb_hbs_ibp_wr_accept,
  input   [32               -1:0]        dbu_per_ahb_hbs_ibp_wr_data,
  input   [(32         /8)  -1:0]        dbu_per_ahb_hbs_ibp_wr_mask,
  input                                   dbu_per_ahb_hbs_ibp_wr_last,

  output                                  dbu_per_ahb_hbs_ibp_wr_done,
  output                                  dbu_per_ahb_hbs_ibp_wr_excl_done,
  output                                  dbu_per_ahb_hbs_ibp_err_wr,
  input                                   dbu_per_ahb_hbs_ibp_wr_resp_accept,


  input                                   bri_bs_ibp_cmd_valid,
  output                                  bri_bs_ibp_cmd_accept,
  input                                   bri_bs_ibp_cmd_read,
  input   [42                -1:0]       bri_bs_ibp_cmd_addr,
  input                                   bri_bs_ibp_cmd_wrap,
  input   [3-1:0]       bri_bs_ibp_cmd_data_size,
  input   [4-1:0]       bri_bs_ibp_cmd_burst_size,
  input   [2-1:0]       bri_bs_ibp_cmd_prot,
  input   [4-1:0]       bri_bs_ibp_cmd_cache,
  input                                   bri_bs_ibp_cmd_lock,
  input                                   bri_bs_ibp_cmd_excl,

  output                                  bri_bs_ibp_rd_valid,
  output                                  bri_bs_ibp_rd_excl_ok,
  input                                   bri_bs_ibp_rd_accept,
  output                                  bri_bs_ibp_err_rd,
  output  [32               -1:0]        bri_bs_ibp_rd_data,
  output                                  bri_bs_ibp_rd_last,

  input                                   bri_bs_ibp_wr_valid,
  output                                  bri_bs_ibp_wr_accept,
  input   [32               -1:0]        bri_bs_ibp_wr_data,
  input   [(32         /8)  -1:0]        bri_bs_ibp_wr_mask,
  input                                   bri_bs_ibp_wr_last,

  output                                  bri_bs_ibp_wr_done,
  output                                  bri_bs_ibp_wr_excl_done,
  output                                  bri_bs_ibp_err_wr,
  input                                   bri_bs_ibp_wr_resp_accept,


  input                                   xtor_axi_bs_ibp_cmd_valid,
  output                                  xtor_axi_bs_ibp_cmd_accept,
  input                                   xtor_axi_bs_ibp_cmd_read,
  input   [42                -1:0]       xtor_axi_bs_ibp_cmd_addr,
  input                                   xtor_axi_bs_ibp_cmd_wrap,
  input   [3-1:0]       xtor_axi_bs_ibp_cmd_data_size,
  input   [4-1:0]       xtor_axi_bs_ibp_cmd_burst_size,
  input   [2-1:0]       xtor_axi_bs_ibp_cmd_prot,
  input   [4-1:0]       xtor_axi_bs_ibp_cmd_cache,
  input                                   xtor_axi_bs_ibp_cmd_lock,
  input                                   xtor_axi_bs_ibp_cmd_excl,

  output                                  xtor_axi_bs_ibp_rd_valid,
  output                                  xtor_axi_bs_ibp_rd_excl_ok,
  input                                   xtor_axi_bs_ibp_rd_accept,
  output                                  xtor_axi_bs_ibp_err_rd,
  output  [512               -1:0]        xtor_axi_bs_ibp_rd_data,
  output                                  xtor_axi_bs_ibp_rd_last,

  input                                   xtor_axi_bs_ibp_wr_valid,
  output                                  xtor_axi_bs_ibp_wr_accept,
  input   [512               -1:0]        xtor_axi_bs_ibp_wr_data,
  input   [(512         /8)  -1:0]        xtor_axi_bs_ibp_wr_mask,
  input                                   xtor_axi_bs_ibp_wr_last,

  output                                  xtor_axi_bs_ibp_wr_done,
  output                                  xtor_axi_bs_ibp_wr_excl_done,
  output                                  xtor_axi_bs_ibp_err_wr,
  input                                   xtor_axi_bs_ibp_wr_resp_accept,

  // slave side


  output                                  iccm_ahb_hbs_ibp_cmd_valid,
  input                                   iccm_ahb_hbs_ibp_cmd_accept,
  output                                  iccm_ahb_hbs_ibp_cmd_read,
  output  [42                -1:0]       iccm_ahb_hbs_ibp_cmd_addr,
  output                                  iccm_ahb_hbs_ibp_cmd_wrap,
  output  [3-1:0]       iccm_ahb_hbs_ibp_cmd_data_size,
  output  [4-1:0]       iccm_ahb_hbs_ibp_cmd_burst_size,
  output  [2-1:0]       iccm_ahb_hbs_ibp_cmd_prot,
  output  [4-1:0]       iccm_ahb_hbs_ibp_cmd_cache,
  output                                  iccm_ahb_hbs_ibp_cmd_lock,
  output                                  iccm_ahb_hbs_ibp_cmd_excl,

  input                                   iccm_ahb_hbs_ibp_rd_valid,
  input                                   iccm_ahb_hbs_ibp_rd_excl_ok,
  output                                  iccm_ahb_hbs_ibp_rd_accept,
  input                                   iccm_ahb_hbs_ibp_err_rd,
  input   [32               -1:0]        iccm_ahb_hbs_ibp_rd_data,
  input                                   iccm_ahb_hbs_ibp_rd_last,

  output                                  iccm_ahb_hbs_ibp_wr_valid,
  input                                   iccm_ahb_hbs_ibp_wr_accept,
  output  [32               -1:0]        iccm_ahb_hbs_ibp_wr_data,
  output  [(32         /8)  -1:0]        iccm_ahb_hbs_ibp_wr_mask,
  output                                  iccm_ahb_hbs_ibp_wr_last,

  input                                   iccm_ahb_hbs_ibp_wr_done,
  input                                   iccm_ahb_hbs_ibp_wr_excl_done,
  input                                   iccm_ahb_hbs_ibp_err_wr,
  output                                  iccm_ahb_hbs_ibp_wr_resp_accept,
output [1-1:0] iccm_ahb_hbs_ibp_cmd_region,



  output                                  dccm_ahb_hbs_ibp_cmd_valid,
  input                                   dccm_ahb_hbs_ibp_cmd_accept,
  output                                  dccm_ahb_hbs_ibp_cmd_read,
  output  [42                -1:0]       dccm_ahb_hbs_ibp_cmd_addr,
  output                                  dccm_ahb_hbs_ibp_cmd_wrap,
  output  [3-1:0]       dccm_ahb_hbs_ibp_cmd_data_size,
  output  [4-1:0]       dccm_ahb_hbs_ibp_cmd_burst_size,
  output  [2-1:0]       dccm_ahb_hbs_ibp_cmd_prot,
  output  [4-1:0]       dccm_ahb_hbs_ibp_cmd_cache,
  output                                  dccm_ahb_hbs_ibp_cmd_lock,
  output                                  dccm_ahb_hbs_ibp_cmd_excl,

  input                                   dccm_ahb_hbs_ibp_rd_valid,
  input                                   dccm_ahb_hbs_ibp_rd_excl_ok,
  output                                  dccm_ahb_hbs_ibp_rd_accept,
  input                                   dccm_ahb_hbs_ibp_err_rd,
  input   [32               -1:0]        dccm_ahb_hbs_ibp_rd_data,
  input                                   dccm_ahb_hbs_ibp_rd_last,

  output                                  dccm_ahb_hbs_ibp_wr_valid,
  input                                   dccm_ahb_hbs_ibp_wr_accept,
  output  [32               -1:0]        dccm_ahb_hbs_ibp_wr_data,
  output  [(32         /8)  -1:0]        dccm_ahb_hbs_ibp_wr_mask,
  output                                  dccm_ahb_hbs_ibp_wr_last,

  input                                   dccm_ahb_hbs_ibp_wr_done,
  input                                   dccm_ahb_hbs_ibp_wr_excl_done,
  input                                   dccm_ahb_hbs_ibp_err_wr,
  output                                  dccm_ahb_hbs_ibp_wr_resp_accept,
output [1-1:0] dccm_ahb_hbs_ibp_cmd_region,



  output                                  mmio_ahb_hbs_ibp_cmd_valid,
  input                                   mmio_ahb_hbs_ibp_cmd_accept,
  output                                  mmio_ahb_hbs_ibp_cmd_read,
  output  [42                -1:0]       mmio_ahb_hbs_ibp_cmd_addr,
  output                                  mmio_ahb_hbs_ibp_cmd_wrap,
  output  [3-1:0]       mmio_ahb_hbs_ibp_cmd_data_size,
  output  [4-1:0]       mmio_ahb_hbs_ibp_cmd_burst_size,
  output  [2-1:0]       mmio_ahb_hbs_ibp_cmd_prot,
  output  [4-1:0]       mmio_ahb_hbs_ibp_cmd_cache,
  output                                  mmio_ahb_hbs_ibp_cmd_lock,
  output                                  mmio_ahb_hbs_ibp_cmd_excl,

  input                                   mmio_ahb_hbs_ibp_rd_valid,
  input                                   mmio_ahb_hbs_ibp_rd_excl_ok,
  output                                  mmio_ahb_hbs_ibp_rd_accept,
  input                                   mmio_ahb_hbs_ibp_err_rd,
  input   [32               -1:0]        mmio_ahb_hbs_ibp_rd_data,
  input                                   mmio_ahb_hbs_ibp_rd_last,

  output                                  mmio_ahb_hbs_ibp_wr_valid,
  input                                   mmio_ahb_hbs_ibp_wr_accept,
  output  [32               -1:0]        mmio_ahb_hbs_ibp_wr_data,
  output  [(32         /8)  -1:0]        mmio_ahb_hbs_ibp_wr_mask,
  output                                  mmio_ahb_hbs_ibp_wr_last,

  input                                   mmio_ahb_hbs_ibp_wr_done,
  input                                   mmio_ahb_hbs_ibp_wr_excl_done,
  input                                   mmio_ahb_hbs_ibp_err_wr,
  output                                  mmio_ahb_hbs_ibp_wr_resp_accept,
output [1-1:0] mmio_ahb_hbs_ibp_cmd_region,



  output                                  mss_clkctrl_bs_ibp_cmd_valid,
  input                                   mss_clkctrl_bs_ibp_cmd_accept,
  output                                  mss_clkctrl_bs_ibp_cmd_read,
  output  [42                -1:0]       mss_clkctrl_bs_ibp_cmd_addr,
  output                                  mss_clkctrl_bs_ibp_cmd_wrap,
  output  [3-1:0]       mss_clkctrl_bs_ibp_cmd_data_size,
  output  [4-1:0]       mss_clkctrl_bs_ibp_cmd_burst_size,
  output  [2-1:0]       mss_clkctrl_bs_ibp_cmd_prot,
  output  [4-1:0]       mss_clkctrl_bs_ibp_cmd_cache,
  output                                  mss_clkctrl_bs_ibp_cmd_lock,
  output                                  mss_clkctrl_bs_ibp_cmd_excl,

  input                                   mss_clkctrl_bs_ibp_rd_valid,
  input                                   mss_clkctrl_bs_ibp_rd_excl_ok,
  output                                  mss_clkctrl_bs_ibp_rd_accept,
  input                                   mss_clkctrl_bs_ibp_err_rd,
  input   [32               -1:0]        mss_clkctrl_bs_ibp_rd_data,
  input                                   mss_clkctrl_bs_ibp_rd_last,

  output                                  mss_clkctrl_bs_ibp_wr_valid,
  input                                   mss_clkctrl_bs_ibp_wr_accept,
  output  [32               -1:0]        mss_clkctrl_bs_ibp_wr_data,
  output  [(32         /8)  -1:0]        mss_clkctrl_bs_ibp_wr_mask,
  output                                  mss_clkctrl_bs_ibp_wr_last,

  input                                   mss_clkctrl_bs_ibp_wr_done,
  input                                   mss_clkctrl_bs_ibp_wr_excl_done,
  input                                   mss_clkctrl_bs_ibp_err_wr,
  output                                  mss_clkctrl_bs_ibp_wr_resp_accept,
output [1-1:0] mss_clkctrl_bs_ibp_cmd_region,



  output                                  mss_perfctrl_bs_ibp_cmd_valid,
  input                                   mss_perfctrl_bs_ibp_cmd_accept,
  output                                  mss_perfctrl_bs_ibp_cmd_read,
  output  [42                -1:0]       mss_perfctrl_bs_ibp_cmd_addr,
  output                                  mss_perfctrl_bs_ibp_cmd_wrap,
  output  [3-1:0]       mss_perfctrl_bs_ibp_cmd_data_size,
  output  [4-1:0]       mss_perfctrl_bs_ibp_cmd_burst_size,
  output  [2-1:0]       mss_perfctrl_bs_ibp_cmd_prot,
  output  [4-1:0]       mss_perfctrl_bs_ibp_cmd_cache,
  output                                  mss_perfctrl_bs_ibp_cmd_lock,
  output                                  mss_perfctrl_bs_ibp_cmd_excl,

  input                                   mss_perfctrl_bs_ibp_rd_valid,
  input                                   mss_perfctrl_bs_ibp_rd_excl_ok,
  output                                  mss_perfctrl_bs_ibp_rd_accept,
  input                                   mss_perfctrl_bs_ibp_err_rd,
  input   [32               -1:0]        mss_perfctrl_bs_ibp_rd_data,
  input                                   mss_perfctrl_bs_ibp_rd_last,

  output                                  mss_perfctrl_bs_ibp_wr_valid,
  input                                   mss_perfctrl_bs_ibp_wr_accept,
  output  [32               -1:0]        mss_perfctrl_bs_ibp_wr_data,
  output  [(32         /8)  -1:0]        mss_perfctrl_bs_ibp_wr_mask,
  output                                  mss_perfctrl_bs_ibp_wr_last,

  input                                   mss_perfctrl_bs_ibp_wr_done,
  input                                   mss_perfctrl_bs_ibp_wr_excl_done,
  input                                   mss_perfctrl_bs_ibp_err_wr,
  output                                  mss_perfctrl_bs_ibp_wr_resp_accept,
output [1-1:0] mss_perfctrl_bs_ibp_cmd_region,



  output                                  mss_mem_bs_ibp_cmd_valid,
  input                                   mss_mem_bs_ibp_cmd_accept,
  output                                  mss_mem_bs_ibp_cmd_read,
  output  [42                -1:0]       mss_mem_bs_ibp_cmd_addr,
  output                                  mss_mem_bs_ibp_cmd_wrap,
  output  [3-1:0]       mss_mem_bs_ibp_cmd_data_size,
  output  [4-1:0]       mss_mem_bs_ibp_cmd_burst_size,
  output  [2-1:0]       mss_mem_bs_ibp_cmd_prot,
  output  [4-1:0]       mss_mem_bs_ibp_cmd_cache,
  output                                  mss_mem_bs_ibp_cmd_lock,
  output                                  mss_mem_bs_ibp_cmd_excl,

  input                                   mss_mem_bs_ibp_rd_valid,
  input                                   mss_mem_bs_ibp_rd_excl_ok,
  output                                  mss_mem_bs_ibp_rd_accept,
  input                                   mss_mem_bs_ibp_err_rd,
  input   [128               -1:0]        mss_mem_bs_ibp_rd_data,
  input                                   mss_mem_bs_ibp_rd_last,

  output                                  mss_mem_bs_ibp_wr_valid,
  input                                   mss_mem_bs_ibp_wr_accept,
  output  [128               -1:0]        mss_mem_bs_ibp_wr_data,
  output  [(128         /8)  -1:0]        mss_mem_bs_ibp_wr_mask,
  output                                  mss_mem_bs_ibp_wr_last,

  input                                   mss_mem_bs_ibp_wr_done,
  input                                   mss_mem_bs_ibp_wr_excl_done,
  input                                   mss_mem_bs_ibp_err_wr,
  output                                  mss_mem_bs_ibp_wr_resp_accept,
output [1-1:0] mss_mem_bs_ibp_cmd_region,

  // clock and reset
  input                                   clk,
  input                                   rst_a
);



// Internal wires and regs

wire [6 : 0] ahb_hbs_ibp_cmd_rgon;



 wire [1-1:0] in_0_out_0_ibp_cmd_chnl_valid;
 wire [1-1:0] in_0_out_0_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_0_out_0_ibp_cmd_chnl;

 wire [1-1:0] in_0_out_0_ibp_wd_chnl_valid;
 wire [1-1:0] in_0_out_0_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_0_out_0_ibp_wd_chnl;

 wire [1-1:0] in_0_out_0_ibp_rd_chnl_accept;
 wire [1-1:0] in_0_out_0_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_0_out_0_ibp_rd_chnl;

 wire [1-1:0] in_0_out_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_0_out_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_0_out_0_ibp_wrsp_chnl;





 wire [1-1:0] in_0_out_1_ibp_cmd_chnl_valid;
 wire [1-1:0] in_0_out_1_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_0_out_1_ibp_cmd_chnl;

 wire [1-1:0] in_0_out_1_ibp_wd_chnl_valid;
 wire [1-1:0] in_0_out_1_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_0_out_1_ibp_wd_chnl;

 wire [1-1:0] in_0_out_1_ibp_rd_chnl_accept;
 wire [1-1:0] in_0_out_1_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_0_out_1_ibp_rd_chnl;

 wire [1-1:0] in_0_out_1_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_0_out_1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_0_out_1_ibp_wrsp_chnl;





 wire [1-1:0] in_0_out_2_ibp_cmd_chnl_valid;
 wire [1-1:0] in_0_out_2_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_0_out_2_ibp_cmd_chnl;

 wire [1-1:0] in_0_out_2_ibp_wd_chnl_valid;
 wire [1-1:0] in_0_out_2_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_0_out_2_ibp_wd_chnl;

 wire [1-1:0] in_0_out_2_ibp_rd_chnl_accept;
 wire [1-1:0] in_0_out_2_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_0_out_2_ibp_rd_chnl;

 wire [1-1:0] in_0_out_2_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_0_out_2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_0_out_2_ibp_wrsp_chnl;





 wire [1-1:0] in_0_out_3_ibp_cmd_chnl_valid;
 wire [1-1:0] in_0_out_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_0_out_3_ibp_cmd_chnl;

 wire [1-1:0] in_0_out_3_ibp_wd_chnl_valid;
 wire [1-1:0] in_0_out_3_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_0_out_3_ibp_wd_chnl;

 wire [1-1:0] in_0_out_3_ibp_rd_chnl_accept;
 wire [1-1:0] in_0_out_3_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_0_out_3_ibp_rd_chnl;

 wire [1-1:0] in_0_out_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_0_out_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_0_out_3_ibp_wrsp_chnl;





 wire [1-1:0] in_0_out_4_ibp_cmd_chnl_valid;
 wire [1-1:0] in_0_out_4_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_0_out_4_ibp_cmd_chnl;

 wire [1-1:0] in_0_out_4_ibp_wd_chnl_valid;
 wire [1-1:0] in_0_out_4_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_0_out_4_ibp_wd_chnl;

 wire [1-1:0] in_0_out_4_ibp_rd_chnl_accept;
 wire [1-1:0] in_0_out_4_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_0_out_4_ibp_rd_chnl;

 wire [1-1:0] in_0_out_4_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_0_out_4_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_0_out_4_ibp_wrsp_chnl;





 wire [1-1:0] in_0_out_5_ibp_cmd_chnl_valid;
 wire [1-1:0] in_0_out_5_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_0_out_5_ibp_cmd_chnl;

 wire [1-1:0] in_0_out_5_ibp_wd_chnl_valid;
 wire [1-1:0] in_0_out_5_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_0_out_5_ibp_wd_chnl;

 wire [1-1:0] in_0_out_5_ibp_rd_chnl_accept;
 wire [1-1:0] in_0_out_5_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_0_out_5_ibp_rd_chnl;

 wire [1-1:0] in_0_out_5_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_0_out_5_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_0_out_5_ibp_wrsp_chnl;





 wire [1-1:0] in_0_out_6_ibp_cmd_chnl_valid;
 wire [1-1:0] in_0_out_6_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_0_out_6_ibp_cmd_chnl;

 wire [1-1:0] in_0_out_6_ibp_wd_chnl_valid;
 wire [1-1:0] in_0_out_6_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_0_out_6_ibp_wd_chnl;

 wire [1-1:0] in_0_out_6_ibp_rd_chnl_accept;
 wire [1-1:0] in_0_out_6_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_0_out_6_ibp_rd_chnl;

 wire [1-1:0] in_0_out_6_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_0_out_6_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_0_out_6_ibp_wrsp_chnl;



wire [6 : 0] dbu_per_ahb_hbs_ibp_cmd_rgon;



 wire [1-1:0] in_1_out_0_ibp_cmd_chnl_valid;
 wire [1-1:0] in_1_out_0_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_1_out_0_ibp_cmd_chnl;

 wire [1-1:0] in_1_out_0_ibp_wd_chnl_valid;
 wire [1-1:0] in_1_out_0_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_1_out_0_ibp_wd_chnl;

 wire [1-1:0] in_1_out_0_ibp_rd_chnl_accept;
 wire [1-1:0] in_1_out_0_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_1_out_0_ibp_rd_chnl;

 wire [1-1:0] in_1_out_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_1_out_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_1_out_0_ibp_wrsp_chnl;





 wire [1-1:0] in_1_out_1_ibp_cmd_chnl_valid;
 wire [1-1:0] in_1_out_1_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_1_out_1_ibp_cmd_chnl;

 wire [1-1:0] in_1_out_1_ibp_wd_chnl_valid;
 wire [1-1:0] in_1_out_1_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_1_out_1_ibp_wd_chnl;

 wire [1-1:0] in_1_out_1_ibp_rd_chnl_accept;
 wire [1-1:0] in_1_out_1_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_1_out_1_ibp_rd_chnl;

 wire [1-1:0] in_1_out_1_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_1_out_1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_1_out_1_ibp_wrsp_chnl;





 wire [1-1:0] in_1_out_2_ibp_cmd_chnl_valid;
 wire [1-1:0] in_1_out_2_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_1_out_2_ibp_cmd_chnl;

 wire [1-1:0] in_1_out_2_ibp_wd_chnl_valid;
 wire [1-1:0] in_1_out_2_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_1_out_2_ibp_wd_chnl;

 wire [1-1:0] in_1_out_2_ibp_rd_chnl_accept;
 wire [1-1:0] in_1_out_2_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_1_out_2_ibp_rd_chnl;

 wire [1-1:0] in_1_out_2_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_1_out_2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_1_out_2_ibp_wrsp_chnl;





 wire [1-1:0] in_1_out_3_ibp_cmd_chnl_valid;
 wire [1-1:0] in_1_out_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_1_out_3_ibp_cmd_chnl;

 wire [1-1:0] in_1_out_3_ibp_wd_chnl_valid;
 wire [1-1:0] in_1_out_3_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_1_out_3_ibp_wd_chnl;

 wire [1-1:0] in_1_out_3_ibp_rd_chnl_accept;
 wire [1-1:0] in_1_out_3_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_1_out_3_ibp_rd_chnl;

 wire [1-1:0] in_1_out_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_1_out_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_1_out_3_ibp_wrsp_chnl;





 wire [1-1:0] in_1_out_4_ibp_cmd_chnl_valid;
 wire [1-1:0] in_1_out_4_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_1_out_4_ibp_cmd_chnl;

 wire [1-1:0] in_1_out_4_ibp_wd_chnl_valid;
 wire [1-1:0] in_1_out_4_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_1_out_4_ibp_wd_chnl;

 wire [1-1:0] in_1_out_4_ibp_rd_chnl_accept;
 wire [1-1:0] in_1_out_4_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_1_out_4_ibp_rd_chnl;

 wire [1-1:0] in_1_out_4_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_1_out_4_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_1_out_4_ibp_wrsp_chnl;





 wire [1-1:0] in_1_out_5_ibp_cmd_chnl_valid;
 wire [1-1:0] in_1_out_5_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_1_out_5_ibp_cmd_chnl;

 wire [1-1:0] in_1_out_5_ibp_wd_chnl_valid;
 wire [1-1:0] in_1_out_5_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_1_out_5_ibp_wd_chnl;

 wire [1-1:0] in_1_out_5_ibp_rd_chnl_accept;
 wire [1-1:0] in_1_out_5_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_1_out_5_ibp_rd_chnl;

 wire [1-1:0] in_1_out_5_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_1_out_5_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_1_out_5_ibp_wrsp_chnl;





 wire [1-1:0] in_1_out_6_ibp_cmd_chnl_valid;
 wire [1-1:0] in_1_out_6_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_1_out_6_ibp_cmd_chnl;

 wire [1-1:0] in_1_out_6_ibp_wd_chnl_valid;
 wire [1-1:0] in_1_out_6_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_1_out_6_ibp_wd_chnl;

 wire [1-1:0] in_1_out_6_ibp_rd_chnl_accept;
 wire [1-1:0] in_1_out_6_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_1_out_6_ibp_rd_chnl;

 wire [1-1:0] in_1_out_6_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_1_out_6_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_1_out_6_ibp_wrsp_chnl;



wire [6 : 0] bri_bs_ibp_cmd_rgon;



 wire [1-1:0] in_2_out_0_ibp_cmd_chnl_valid;
 wire [1-1:0] in_2_out_0_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_2_out_0_ibp_cmd_chnl;

 wire [1-1:0] in_2_out_0_ibp_wd_chnl_valid;
 wire [1-1:0] in_2_out_0_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_2_out_0_ibp_wd_chnl;

 wire [1-1:0] in_2_out_0_ibp_rd_chnl_accept;
 wire [1-1:0] in_2_out_0_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_2_out_0_ibp_rd_chnl;

 wire [1-1:0] in_2_out_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_2_out_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_2_out_0_ibp_wrsp_chnl;





 wire [1-1:0] in_2_out_1_ibp_cmd_chnl_valid;
 wire [1-1:0] in_2_out_1_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_2_out_1_ibp_cmd_chnl;

 wire [1-1:0] in_2_out_1_ibp_wd_chnl_valid;
 wire [1-1:0] in_2_out_1_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_2_out_1_ibp_wd_chnl;

 wire [1-1:0] in_2_out_1_ibp_rd_chnl_accept;
 wire [1-1:0] in_2_out_1_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_2_out_1_ibp_rd_chnl;

 wire [1-1:0] in_2_out_1_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_2_out_1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_2_out_1_ibp_wrsp_chnl;





 wire [1-1:0] in_2_out_2_ibp_cmd_chnl_valid;
 wire [1-1:0] in_2_out_2_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_2_out_2_ibp_cmd_chnl;

 wire [1-1:0] in_2_out_2_ibp_wd_chnl_valid;
 wire [1-1:0] in_2_out_2_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_2_out_2_ibp_wd_chnl;

 wire [1-1:0] in_2_out_2_ibp_rd_chnl_accept;
 wire [1-1:0] in_2_out_2_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_2_out_2_ibp_rd_chnl;

 wire [1-1:0] in_2_out_2_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_2_out_2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_2_out_2_ibp_wrsp_chnl;





 wire [1-1:0] in_2_out_3_ibp_cmd_chnl_valid;
 wire [1-1:0] in_2_out_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_2_out_3_ibp_cmd_chnl;

 wire [1-1:0] in_2_out_3_ibp_wd_chnl_valid;
 wire [1-1:0] in_2_out_3_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_2_out_3_ibp_wd_chnl;

 wire [1-1:0] in_2_out_3_ibp_rd_chnl_accept;
 wire [1-1:0] in_2_out_3_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_2_out_3_ibp_rd_chnl;

 wire [1-1:0] in_2_out_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_2_out_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_2_out_3_ibp_wrsp_chnl;





 wire [1-1:0] in_2_out_4_ibp_cmd_chnl_valid;
 wire [1-1:0] in_2_out_4_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_2_out_4_ibp_cmd_chnl;

 wire [1-1:0] in_2_out_4_ibp_wd_chnl_valid;
 wire [1-1:0] in_2_out_4_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_2_out_4_ibp_wd_chnl;

 wire [1-1:0] in_2_out_4_ibp_rd_chnl_accept;
 wire [1-1:0] in_2_out_4_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_2_out_4_ibp_rd_chnl;

 wire [1-1:0] in_2_out_4_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_2_out_4_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_2_out_4_ibp_wrsp_chnl;





 wire [1-1:0] in_2_out_5_ibp_cmd_chnl_valid;
 wire [1-1:0] in_2_out_5_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_2_out_5_ibp_cmd_chnl;

 wire [1-1:0] in_2_out_5_ibp_wd_chnl_valid;
 wire [1-1:0] in_2_out_5_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_2_out_5_ibp_wd_chnl;

 wire [1-1:0] in_2_out_5_ibp_rd_chnl_accept;
 wire [1-1:0] in_2_out_5_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_2_out_5_ibp_rd_chnl;

 wire [1-1:0] in_2_out_5_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_2_out_5_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_2_out_5_ibp_wrsp_chnl;





 wire [1-1:0] in_2_out_6_ibp_cmd_chnl_valid;
 wire [1-1:0] in_2_out_6_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_2_out_6_ibp_cmd_chnl;

 wire [1-1:0] in_2_out_6_ibp_wd_chnl_valid;
 wire [1-1:0] in_2_out_6_ibp_wd_chnl_accept;
 wire [37 * 1 -1:0] in_2_out_6_ibp_wd_chnl;

 wire [1-1:0] in_2_out_6_ibp_rd_chnl_accept;
 wire [1-1:0] in_2_out_6_ibp_rd_chnl_valid;
 wire [35 * 1 -1:0] in_2_out_6_ibp_rd_chnl;

 wire [1-1:0] in_2_out_6_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_2_out_6_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_2_out_6_ibp_wrsp_chnl;



wire [6 : 0] xtor_axi_bs_ibp_cmd_rgon;



 wire [1-1:0] in_3_out_0_ibp_cmd_chnl_valid;
 wire [1-1:0] in_3_out_0_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_3_out_0_ibp_cmd_chnl;

 wire [1-1:0] in_3_out_0_ibp_wd_chnl_valid;
 wire [1-1:0] in_3_out_0_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] in_3_out_0_ibp_wd_chnl;

 wire [1-1:0] in_3_out_0_ibp_rd_chnl_accept;
 wire [1-1:0] in_3_out_0_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] in_3_out_0_ibp_rd_chnl;

 wire [1-1:0] in_3_out_0_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_3_out_0_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_3_out_0_ibp_wrsp_chnl;





 wire [1-1:0] in_3_out_1_ibp_cmd_chnl_valid;
 wire [1-1:0] in_3_out_1_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_3_out_1_ibp_cmd_chnl;

 wire [1-1:0] in_3_out_1_ibp_wd_chnl_valid;
 wire [1-1:0] in_3_out_1_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] in_3_out_1_ibp_wd_chnl;

 wire [1-1:0] in_3_out_1_ibp_rd_chnl_accept;
 wire [1-1:0] in_3_out_1_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] in_3_out_1_ibp_rd_chnl;

 wire [1-1:0] in_3_out_1_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_3_out_1_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_3_out_1_ibp_wrsp_chnl;





 wire [1-1:0] in_3_out_2_ibp_cmd_chnl_valid;
 wire [1-1:0] in_3_out_2_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_3_out_2_ibp_cmd_chnl;

 wire [1-1:0] in_3_out_2_ibp_wd_chnl_valid;
 wire [1-1:0] in_3_out_2_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] in_3_out_2_ibp_wd_chnl;

 wire [1-1:0] in_3_out_2_ibp_rd_chnl_accept;
 wire [1-1:0] in_3_out_2_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] in_3_out_2_ibp_rd_chnl;

 wire [1-1:0] in_3_out_2_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_3_out_2_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_3_out_2_ibp_wrsp_chnl;





 wire [1-1:0] in_3_out_3_ibp_cmd_chnl_valid;
 wire [1-1:0] in_3_out_3_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_3_out_3_ibp_cmd_chnl;

 wire [1-1:0] in_3_out_3_ibp_wd_chnl_valid;
 wire [1-1:0] in_3_out_3_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] in_3_out_3_ibp_wd_chnl;

 wire [1-1:0] in_3_out_3_ibp_rd_chnl_accept;
 wire [1-1:0] in_3_out_3_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] in_3_out_3_ibp_rd_chnl;

 wire [1-1:0] in_3_out_3_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_3_out_3_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_3_out_3_ibp_wrsp_chnl;





 wire [1-1:0] in_3_out_4_ibp_cmd_chnl_valid;
 wire [1-1:0] in_3_out_4_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_3_out_4_ibp_cmd_chnl;

 wire [1-1:0] in_3_out_4_ibp_wd_chnl_valid;
 wire [1-1:0] in_3_out_4_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] in_3_out_4_ibp_wd_chnl;

 wire [1-1:0] in_3_out_4_ibp_rd_chnl_accept;
 wire [1-1:0] in_3_out_4_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] in_3_out_4_ibp_rd_chnl;

 wire [1-1:0] in_3_out_4_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_3_out_4_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_3_out_4_ibp_wrsp_chnl;





 wire [1-1:0] in_3_out_5_ibp_cmd_chnl_valid;
 wire [1-1:0] in_3_out_5_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_3_out_5_ibp_cmd_chnl;

 wire [1-1:0] in_3_out_5_ibp_wd_chnl_valid;
 wire [1-1:0] in_3_out_5_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] in_3_out_5_ibp_wd_chnl;

 wire [1-1:0] in_3_out_5_ibp_rd_chnl_accept;
 wire [1-1:0] in_3_out_5_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] in_3_out_5_ibp_rd_chnl;

 wire [1-1:0] in_3_out_5_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_3_out_5_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_3_out_5_ibp_wrsp_chnl;





 wire [1-1:0] in_3_out_6_ibp_cmd_chnl_valid;
 wire [1-1:0] in_3_out_6_ibp_cmd_chnl_accept;
 wire [59 * 1 -1:0] in_3_out_6_ibp_cmd_chnl;

 wire [1-1:0] in_3_out_6_ibp_wd_chnl_valid;
 wire [1-1:0] in_3_out_6_ibp_wd_chnl_accept;
 wire [577 * 1 -1:0] in_3_out_6_ibp_wd_chnl;

 wire [1-1:0] in_3_out_6_ibp_rd_chnl_accept;
 wire [1-1:0] in_3_out_6_ibp_rd_chnl_valid;
 wire [515 * 1 -1:0] in_3_out_6_ibp_rd_chnl;

 wire [1-1:0] in_3_out_6_ibp_wrsp_chnl_valid;
 wire [1-1:0] in_3_out_6_ibp_wrsp_chnl_accept;
 wire [3 * 1 -1:0] in_3_out_6_ibp_wrsp_chnl;



//
// Instantiation for each master port
//
mss_bus_switch_dw32_slv u_mss_bs_slv_0 (





























    .dw32_in_ibp_cmd_rgon (ahb_hbs_ibp_cmd_rgon),

  .dw32_in_ibp_cmd_valid             (ahb_hbs_ibp_cmd_valid),
  .dw32_in_ibp_cmd_accept            (ahb_hbs_ibp_cmd_accept),
  .dw32_in_ibp_cmd_read              (ahb_hbs_ibp_cmd_read),
  .dw32_in_ibp_cmd_addr              (ahb_hbs_ibp_cmd_addr),
  .dw32_in_ibp_cmd_wrap              (ahb_hbs_ibp_cmd_wrap),
  .dw32_in_ibp_cmd_data_size         (ahb_hbs_ibp_cmd_data_size),
  .dw32_in_ibp_cmd_burst_size        (ahb_hbs_ibp_cmd_burst_size),
  .dw32_in_ibp_cmd_prot              (ahb_hbs_ibp_cmd_prot),
  .dw32_in_ibp_cmd_cache             (ahb_hbs_ibp_cmd_cache),
  .dw32_in_ibp_cmd_lock              (ahb_hbs_ibp_cmd_lock),
  .dw32_in_ibp_cmd_excl              (ahb_hbs_ibp_cmd_excl),

  .dw32_in_ibp_rd_valid              (ahb_hbs_ibp_rd_valid),
  .dw32_in_ibp_rd_excl_ok            (ahb_hbs_ibp_rd_excl_ok),
  .dw32_in_ibp_rd_accept             (ahb_hbs_ibp_rd_accept),
  .dw32_in_ibp_err_rd                (ahb_hbs_ibp_err_rd),
  .dw32_in_ibp_rd_data               (ahb_hbs_ibp_rd_data),
  .dw32_in_ibp_rd_last               (ahb_hbs_ibp_rd_last),

  .dw32_in_ibp_wr_valid              (ahb_hbs_ibp_wr_valid),
  .dw32_in_ibp_wr_accept             (ahb_hbs_ibp_wr_accept),
  .dw32_in_ibp_wr_data               (ahb_hbs_ibp_wr_data),
  .dw32_in_ibp_wr_mask               (ahb_hbs_ibp_wr_mask),
  .dw32_in_ibp_wr_last               (ahb_hbs_ibp_wr_last),

  .dw32_in_ibp_wr_done               (ahb_hbs_ibp_wr_done),
  .dw32_in_ibp_wr_excl_done          (ahb_hbs_ibp_wr_excl_done),
  .dw32_in_ibp_err_wr                (ahb_hbs_ibp_err_wr),
  .dw32_in_ibp_wr_resp_accept        (ahb_hbs_ibp_wr_resp_accept),




    .dw32_out_0_ibp_cmd_chnl_valid  (in_0_out_0_ibp_cmd_chnl_valid),
    .dw32_out_0_ibp_cmd_chnl_accept (in_0_out_0_ibp_cmd_chnl_accept),
    .dw32_out_0_ibp_cmd_chnl        (in_0_out_0_ibp_cmd_chnl),

    .dw32_out_0_ibp_rd_chnl_valid   (in_0_out_0_ibp_rd_chnl_valid),
    .dw32_out_0_ibp_rd_chnl_accept  (in_0_out_0_ibp_rd_chnl_accept),
    .dw32_out_0_ibp_rd_chnl         (in_0_out_0_ibp_rd_chnl),

    .dw32_out_0_ibp_wd_chnl_valid   (in_0_out_0_ibp_wd_chnl_valid),
    .dw32_out_0_ibp_wd_chnl_accept  (in_0_out_0_ibp_wd_chnl_accept),
    .dw32_out_0_ibp_wd_chnl         (in_0_out_0_ibp_wd_chnl),

    .dw32_out_0_ibp_wrsp_chnl_valid (in_0_out_0_ibp_wrsp_chnl_valid),
    .dw32_out_0_ibp_wrsp_chnl_accept(in_0_out_0_ibp_wrsp_chnl_accept),
    .dw32_out_0_ibp_wrsp_chnl       (in_0_out_0_ibp_wrsp_chnl),





    .dw32_out_1_ibp_cmd_chnl_valid  (in_0_out_1_ibp_cmd_chnl_valid),
    .dw32_out_1_ibp_cmd_chnl_accept (in_0_out_1_ibp_cmd_chnl_accept),
    .dw32_out_1_ibp_cmd_chnl        (in_0_out_1_ibp_cmd_chnl),

    .dw32_out_1_ibp_rd_chnl_valid   (in_0_out_1_ibp_rd_chnl_valid),
    .dw32_out_1_ibp_rd_chnl_accept  (in_0_out_1_ibp_rd_chnl_accept),
    .dw32_out_1_ibp_rd_chnl         (in_0_out_1_ibp_rd_chnl),

    .dw32_out_1_ibp_wd_chnl_valid   (in_0_out_1_ibp_wd_chnl_valid),
    .dw32_out_1_ibp_wd_chnl_accept  (in_0_out_1_ibp_wd_chnl_accept),
    .dw32_out_1_ibp_wd_chnl         (in_0_out_1_ibp_wd_chnl),

    .dw32_out_1_ibp_wrsp_chnl_valid (in_0_out_1_ibp_wrsp_chnl_valid),
    .dw32_out_1_ibp_wrsp_chnl_accept(in_0_out_1_ibp_wrsp_chnl_accept),
    .dw32_out_1_ibp_wrsp_chnl       (in_0_out_1_ibp_wrsp_chnl),





    .dw32_out_2_ibp_cmd_chnl_valid  (in_0_out_2_ibp_cmd_chnl_valid),
    .dw32_out_2_ibp_cmd_chnl_accept (in_0_out_2_ibp_cmd_chnl_accept),
    .dw32_out_2_ibp_cmd_chnl        (in_0_out_2_ibp_cmd_chnl),

    .dw32_out_2_ibp_rd_chnl_valid   (in_0_out_2_ibp_rd_chnl_valid),
    .dw32_out_2_ibp_rd_chnl_accept  (in_0_out_2_ibp_rd_chnl_accept),
    .dw32_out_2_ibp_rd_chnl         (in_0_out_2_ibp_rd_chnl),

    .dw32_out_2_ibp_wd_chnl_valid   (in_0_out_2_ibp_wd_chnl_valid),
    .dw32_out_2_ibp_wd_chnl_accept  (in_0_out_2_ibp_wd_chnl_accept),
    .dw32_out_2_ibp_wd_chnl         (in_0_out_2_ibp_wd_chnl),

    .dw32_out_2_ibp_wrsp_chnl_valid (in_0_out_2_ibp_wrsp_chnl_valid),
    .dw32_out_2_ibp_wrsp_chnl_accept(in_0_out_2_ibp_wrsp_chnl_accept),
    .dw32_out_2_ibp_wrsp_chnl       (in_0_out_2_ibp_wrsp_chnl),





    .dw32_out_3_ibp_cmd_chnl_valid  (in_0_out_3_ibp_cmd_chnl_valid),
    .dw32_out_3_ibp_cmd_chnl_accept (in_0_out_3_ibp_cmd_chnl_accept),
    .dw32_out_3_ibp_cmd_chnl        (in_0_out_3_ibp_cmd_chnl),

    .dw32_out_3_ibp_rd_chnl_valid   (in_0_out_3_ibp_rd_chnl_valid),
    .dw32_out_3_ibp_rd_chnl_accept  (in_0_out_3_ibp_rd_chnl_accept),
    .dw32_out_3_ibp_rd_chnl         (in_0_out_3_ibp_rd_chnl),

    .dw32_out_3_ibp_wd_chnl_valid   (in_0_out_3_ibp_wd_chnl_valid),
    .dw32_out_3_ibp_wd_chnl_accept  (in_0_out_3_ibp_wd_chnl_accept),
    .dw32_out_3_ibp_wd_chnl         (in_0_out_3_ibp_wd_chnl),

    .dw32_out_3_ibp_wrsp_chnl_valid (in_0_out_3_ibp_wrsp_chnl_valid),
    .dw32_out_3_ibp_wrsp_chnl_accept(in_0_out_3_ibp_wrsp_chnl_accept),
    .dw32_out_3_ibp_wrsp_chnl       (in_0_out_3_ibp_wrsp_chnl),





    .dw32_out_4_ibp_cmd_chnl_valid  (in_0_out_4_ibp_cmd_chnl_valid),
    .dw32_out_4_ibp_cmd_chnl_accept (in_0_out_4_ibp_cmd_chnl_accept),
    .dw32_out_4_ibp_cmd_chnl        (in_0_out_4_ibp_cmd_chnl),

    .dw32_out_4_ibp_rd_chnl_valid   (in_0_out_4_ibp_rd_chnl_valid),
    .dw32_out_4_ibp_rd_chnl_accept  (in_0_out_4_ibp_rd_chnl_accept),
    .dw32_out_4_ibp_rd_chnl         (in_0_out_4_ibp_rd_chnl),

    .dw32_out_4_ibp_wd_chnl_valid   (in_0_out_4_ibp_wd_chnl_valid),
    .dw32_out_4_ibp_wd_chnl_accept  (in_0_out_4_ibp_wd_chnl_accept),
    .dw32_out_4_ibp_wd_chnl         (in_0_out_4_ibp_wd_chnl),

    .dw32_out_4_ibp_wrsp_chnl_valid (in_0_out_4_ibp_wrsp_chnl_valid),
    .dw32_out_4_ibp_wrsp_chnl_accept(in_0_out_4_ibp_wrsp_chnl_accept),
    .dw32_out_4_ibp_wrsp_chnl       (in_0_out_4_ibp_wrsp_chnl),





    .dw32_out_5_ibp_cmd_chnl_valid  (in_0_out_5_ibp_cmd_chnl_valid),
    .dw32_out_5_ibp_cmd_chnl_accept (in_0_out_5_ibp_cmd_chnl_accept),
    .dw32_out_5_ibp_cmd_chnl        (in_0_out_5_ibp_cmd_chnl),

    .dw32_out_5_ibp_rd_chnl_valid   (in_0_out_5_ibp_rd_chnl_valid),
    .dw32_out_5_ibp_rd_chnl_accept  (in_0_out_5_ibp_rd_chnl_accept),
    .dw32_out_5_ibp_rd_chnl         (in_0_out_5_ibp_rd_chnl),

    .dw32_out_5_ibp_wd_chnl_valid   (in_0_out_5_ibp_wd_chnl_valid),
    .dw32_out_5_ibp_wd_chnl_accept  (in_0_out_5_ibp_wd_chnl_accept),
    .dw32_out_5_ibp_wd_chnl         (in_0_out_5_ibp_wd_chnl),

    .dw32_out_5_ibp_wrsp_chnl_valid (in_0_out_5_ibp_wrsp_chnl_valid),
    .dw32_out_5_ibp_wrsp_chnl_accept(in_0_out_5_ibp_wrsp_chnl_accept),
    .dw32_out_5_ibp_wrsp_chnl       (in_0_out_5_ibp_wrsp_chnl),





    .dw32_out_6_ibp_cmd_chnl_valid  (in_0_out_6_ibp_cmd_chnl_valid),
    .dw32_out_6_ibp_cmd_chnl_accept (in_0_out_6_ibp_cmd_chnl_accept),
    .dw32_out_6_ibp_cmd_chnl        (in_0_out_6_ibp_cmd_chnl),

    .dw32_out_6_ibp_rd_chnl_valid   (in_0_out_6_ibp_rd_chnl_valid),
    .dw32_out_6_ibp_rd_chnl_accept  (in_0_out_6_ibp_rd_chnl_accept),
    .dw32_out_6_ibp_rd_chnl         (in_0_out_6_ibp_rd_chnl),

    .dw32_out_6_ibp_wd_chnl_valid   (in_0_out_6_ibp_wd_chnl_valid),
    .dw32_out_6_ibp_wd_chnl_accept  (in_0_out_6_ibp_wd_chnl_accept),
    .dw32_out_6_ibp_wd_chnl         (in_0_out_6_ibp_wd_chnl),

    .dw32_out_6_ibp_wrsp_chnl_valid (in_0_out_6_ibp_wrsp_chnl_valid),
    .dw32_out_6_ibp_wrsp_chnl_accept(in_0_out_6_ibp_wrsp_chnl_accept),
    .dw32_out_6_ibp_wrsp_chnl       (in_0_out_6_ibp_wrsp_chnl),



.clk         (clk),
.sync_rst_r  (rst_a),
.async_rst   (rst_a),
.rst_a       (rst_a)
);
mss_bus_switch_dw32_slv u_mss_bs_slv_1 (





























    .dw32_in_ibp_cmd_rgon (dbu_per_ahb_hbs_ibp_cmd_rgon),

  .dw32_in_ibp_cmd_valid             (dbu_per_ahb_hbs_ibp_cmd_valid),
  .dw32_in_ibp_cmd_accept            (dbu_per_ahb_hbs_ibp_cmd_accept),
  .dw32_in_ibp_cmd_read              (dbu_per_ahb_hbs_ibp_cmd_read),
  .dw32_in_ibp_cmd_addr              (dbu_per_ahb_hbs_ibp_cmd_addr),
  .dw32_in_ibp_cmd_wrap              (dbu_per_ahb_hbs_ibp_cmd_wrap),
  .dw32_in_ibp_cmd_data_size         (dbu_per_ahb_hbs_ibp_cmd_data_size),
  .dw32_in_ibp_cmd_burst_size        (dbu_per_ahb_hbs_ibp_cmd_burst_size),
  .dw32_in_ibp_cmd_prot              (dbu_per_ahb_hbs_ibp_cmd_prot),
  .dw32_in_ibp_cmd_cache             (dbu_per_ahb_hbs_ibp_cmd_cache),
  .dw32_in_ibp_cmd_lock              (dbu_per_ahb_hbs_ibp_cmd_lock),
  .dw32_in_ibp_cmd_excl              (dbu_per_ahb_hbs_ibp_cmd_excl),

  .dw32_in_ibp_rd_valid              (dbu_per_ahb_hbs_ibp_rd_valid),
  .dw32_in_ibp_rd_excl_ok            (dbu_per_ahb_hbs_ibp_rd_excl_ok),
  .dw32_in_ibp_rd_accept             (dbu_per_ahb_hbs_ibp_rd_accept),
  .dw32_in_ibp_err_rd                (dbu_per_ahb_hbs_ibp_err_rd),
  .dw32_in_ibp_rd_data               (dbu_per_ahb_hbs_ibp_rd_data),
  .dw32_in_ibp_rd_last               (dbu_per_ahb_hbs_ibp_rd_last),

  .dw32_in_ibp_wr_valid              (dbu_per_ahb_hbs_ibp_wr_valid),
  .dw32_in_ibp_wr_accept             (dbu_per_ahb_hbs_ibp_wr_accept),
  .dw32_in_ibp_wr_data               (dbu_per_ahb_hbs_ibp_wr_data),
  .dw32_in_ibp_wr_mask               (dbu_per_ahb_hbs_ibp_wr_mask),
  .dw32_in_ibp_wr_last               (dbu_per_ahb_hbs_ibp_wr_last),

  .dw32_in_ibp_wr_done               (dbu_per_ahb_hbs_ibp_wr_done),
  .dw32_in_ibp_wr_excl_done          (dbu_per_ahb_hbs_ibp_wr_excl_done),
  .dw32_in_ibp_err_wr                (dbu_per_ahb_hbs_ibp_err_wr),
  .dw32_in_ibp_wr_resp_accept        (dbu_per_ahb_hbs_ibp_wr_resp_accept),




    .dw32_out_0_ibp_cmd_chnl_valid  (in_1_out_0_ibp_cmd_chnl_valid),
    .dw32_out_0_ibp_cmd_chnl_accept (in_1_out_0_ibp_cmd_chnl_accept),
    .dw32_out_0_ibp_cmd_chnl        (in_1_out_0_ibp_cmd_chnl),

    .dw32_out_0_ibp_rd_chnl_valid   (in_1_out_0_ibp_rd_chnl_valid),
    .dw32_out_0_ibp_rd_chnl_accept  (in_1_out_0_ibp_rd_chnl_accept),
    .dw32_out_0_ibp_rd_chnl         (in_1_out_0_ibp_rd_chnl),

    .dw32_out_0_ibp_wd_chnl_valid   (in_1_out_0_ibp_wd_chnl_valid),
    .dw32_out_0_ibp_wd_chnl_accept  (in_1_out_0_ibp_wd_chnl_accept),
    .dw32_out_0_ibp_wd_chnl         (in_1_out_0_ibp_wd_chnl),

    .dw32_out_0_ibp_wrsp_chnl_valid (in_1_out_0_ibp_wrsp_chnl_valid),
    .dw32_out_0_ibp_wrsp_chnl_accept(in_1_out_0_ibp_wrsp_chnl_accept),
    .dw32_out_0_ibp_wrsp_chnl       (in_1_out_0_ibp_wrsp_chnl),





    .dw32_out_1_ibp_cmd_chnl_valid  (in_1_out_1_ibp_cmd_chnl_valid),
    .dw32_out_1_ibp_cmd_chnl_accept (in_1_out_1_ibp_cmd_chnl_accept),
    .dw32_out_1_ibp_cmd_chnl        (in_1_out_1_ibp_cmd_chnl),

    .dw32_out_1_ibp_rd_chnl_valid   (in_1_out_1_ibp_rd_chnl_valid),
    .dw32_out_1_ibp_rd_chnl_accept  (in_1_out_1_ibp_rd_chnl_accept),
    .dw32_out_1_ibp_rd_chnl         (in_1_out_1_ibp_rd_chnl),

    .dw32_out_1_ibp_wd_chnl_valid   (in_1_out_1_ibp_wd_chnl_valid),
    .dw32_out_1_ibp_wd_chnl_accept  (in_1_out_1_ibp_wd_chnl_accept),
    .dw32_out_1_ibp_wd_chnl         (in_1_out_1_ibp_wd_chnl),

    .dw32_out_1_ibp_wrsp_chnl_valid (in_1_out_1_ibp_wrsp_chnl_valid),
    .dw32_out_1_ibp_wrsp_chnl_accept(in_1_out_1_ibp_wrsp_chnl_accept),
    .dw32_out_1_ibp_wrsp_chnl       (in_1_out_1_ibp_wrsp_chnl),





    .dw32_out_2_ibp_cmd_chnl_valid  (in_1_out_2_ibp_cmd_chnl_valid),
    .dw32_out_2_ibp_cmd_chnl_accept (in_1_out_2_ibp_cmd_chnl_accept),
    .dw32_out_2_ibp_cmd_chnl        (in_1_out_2_ibp_cmd_chnl),

    .dw32_out_2_ibp_rd_chnl_valid   (in_1_out_2_ibp_rd_chnl_valid),
    .dw32_out_2_ibp_rd_chnl_accept  (in_1_out_2_ibp_rd_chnl_accept),
    .dw32_out_2_ibp_rd_chnl         (in_1_out_2_ibp_rd_chnl),

    .dw32_out_2_ibp_wd_chnl_valid   (in_1_out_2_ibp_wd_chnl_valid),
    .dw32_out_2_ibp_wd_chnl_accept  (in_1_out_2_ibp_wd_chnl_accept),
    .dw32_out_2_ibp_wd_chnl         (in_1_out_2_ibp_wd_chnl),

    .dw32_out_2_ibp_wrsp_chnl_valid (in_1_out_2_ibp_wrsp_chnl_valid),
    .dw32_out_2_ibp_wrsp_chnl_accept(in_1_out_2_ibp_wrsp_chnl_accept),
    .dw32_out_2_ibp_wrsp_chnl       (in_1_out_2_ibp_wrsp_chnl),





    .dw32_out_3_ibp_cmd_chnl_valid  (in_1_out_3_ibp_cmd_chnl_valid),
    .dw32_out_3_ibp_cmd_chnl_accept (in_1_out_3_ibp_cmd_chnl_accept),
    .dw32_out_3_ibp_cmd_chnl        (in_1_out_3_ibp_cmd_chnl),

    .dw32_out_3_ibp_rd_chnl_valid   (in_1_out_3_ibp_rd_chnl_valid),
    .dw32_out_3_ibp_rd_chnl_accept  (in_1_out_3_ibp_rd_chnl_accept),
    .dw32_out_3_ibp_rd_chnl         (in_1_out_3_ibp_rd_chnl),

    .dw32_out_3_ibp_wd_chnl_valid   (in_1_out_3_ibp_wd_chnl_valid),
    .dw32_out_3_ibp_wd_chnl_accept  (in_1_out_3_ibp_wd_chnl_accept),
    .dw32_out_3_ibp_wd_chnl         (in_1_out_3_ibp_wd_chnl),

    .dw32_out_3_ibp_wrsp_chnl_valid (in_1_out_3_ibp_wrsp_chnl_valid),
    .dw32_out_3_ibp_wrsp_chnl_accept(in_1_out_3_ibp_wrsp_chnl_accept),
    .dw32_out_3_ibp_wrsp_chnl       (in_1_out_3_ibp_wrsp_chnl),





    .dw32_out_4_ibp_cmd_chnl_valid  (in_1_out_4_ibp_cmd_chnl_valid),
    .dw32_out_4_ibp_cmd_chnl_accept (in_1_out_4_ibp_cmd_chnl_accept),
    .dw32_out_4_ibp_cmd_chnl        (in_1_out_4_ibp_cmd_chnl),

    .dw32_out_4_ibp_rd_chnl_valid   (in_1_out_4_ibp_rd_chnl_valid),
    .dw32_out_4_ibp_rd_chnl_accept  (in_1_out_4_ibp_rd_chnl_accept),
    .dw32_out_4_ibp_rd_chnl         (in_1_out_4_ibp_rd_chnl),

    .dw32_out_4_ibp_wd_chnl_valid   (in_1_out_4_ibp_wd_chnl_valid),
    .dw32_out_4_ibp_wd_chnl_accept  (in_1_out_4_ibp_wd_chnl_accept),
    .dw32_out_4_ibp_wd_chnl         (in_1_out_4_ibp_wd_chnl),

    .dw32_out_4_ibp_wrsp_chnl_valid (in_1_out_4_ibp_wrsp_chnl_valid),
    .dw32_out_4_ibp_wrsp_chnl_accept(in_1_out_4_ibp_wrsp_chnl_accept),
    .dw32_out_4_ibp_wrsp_chnl       (in_1_out_4_ibp_wrsp_chnl),





    .dw32_out_5_ibp_cmd_chnl_valid  (in_1_out_5_ibp_cmd_chnl_valid),
    .dw32_out_5_ibp_cmd_chnl_accept (in_1_out_5_ibp_cmd_chnl_accept),
    .dw32_out_5_ibp_cmd_chnl        (in_1_out_5_ibp_cmd_chnl),

    .dw32_out_5_ibp_rd_chnl_valid   (in_1_out_5_ibp_rd_chnl_valid),
    .dw32_out_5_ibp_rd_chnl_accept  (in_1_out_5_ibp_rd_chnl_accept),
    .dw32_out_5_ibp_rd_chnl         (in_1_out_5_ibp_rd_chnl),

    .dw32_out_5_ibp_wd_chnl_valid   (in_1_out_5_ibp_wd_chnl_valid),
    .dw32_out_5_ibp_wd_chnl_accept  (in_1_out_5_ibp_wd_chnl_accept),
    .dw32_out_5_ibp_wd_chnl         (in_1_out_5_ibp_wd_chnl),

    .dw32_out_5_ibp_wrsp_chnl_valid (in_1_out_5_ibp_wrsp_chnl_valid),
    .dw32_out_5_ibp_wrsp_chnl_accept(in_1_out_5_ibp_wrsp_chnl_accept),
    .dw32_out_5_ibp_wrsp_chnl       (in_1_out_5_ibp_wrsp_chnl),





    .dw32_out_6_ibp_cmd_chnl_valid  (in_1_out_6_ibp_cmd_chnl_valid),
    .dw32_out_6_ibp_cmd_chnl_accept (in_1_out_6_ibp_cmd_chnl_accept),
    .dw32_out_6_ibp_cmd_chnl        (in_1_out_6_ibp_cmd_chnl),

    .dw32_out_6_ibp_rd_chnl_valid   (in_1_out_6_ibp_rd_chnl_valid),
    .dw32_out_6_ibp_rd_chnl_accept  (in_1_out_6_ibp_rd_chnl_accept),
    .dw32_out_6_ibp_rd_chnl         (in_1_out_6_ibp_rd_chnl),

    .dw32_out_6_ibp_wd_chnl_valid   (in_1_out_6_ibp_wd_chnl_valid),
    .dw32_out_6_ibp_wd_chnl_accept  (in_1_out_6_ibp_wd_chnl_accept),
    .dw32_out_6_ibp_wd_chnl         (in_1_out_6_ibp_wd_chnl),

    .dw32_out_6_ibp_wrsp_chnl_valid (in_1_out_6_ibp_wrsp_chnl_valid),
    .dw32_out_6_ibp_wrsp_chnl_accept(in_1_out_6_ibp_wrsp_chnl_accept),
    .dw32_out_6_ibp_wrsp_chnl       (in_1_out_6_ibp_wrsp_chnl),



.clk         (clk),
.sync_rst_r  (rst_a),
.async_rst   (rst_a),
.rst_a       (rst_a)
);
mss_bus_switch_dw32_slv u_mss_bs_slv_2 (





























    .dw32_in_ibp_cmd_rgon (bri_bs_ibp_cmd_rgon),

  .dw32_in_ibp_cmd_valid             (bri_bs_ibp_cmd_valid),
  .dw32_in_ibp_cmd_accept            (bri_bs_ibp_cmd_accept),
  .dw32_in_ibp_cmd_read              (bri_bs_ibp_cmd_read),
  .dw32_in_ibp_cmd_addr              (bri_bs_ibp_cmd_addr),
  .dw32_in_ibp_cmd_wrap              (bri_bs_ibp_cmd_wrap),
  .dw32_in_ibp_cmd_data_size         (bri_bs_ibp_cmd_data_size),
  .dw32_in_ibp_cmd_burst_size        (bri_bs_ibp_cmd_burst_size),
  .dw32_in_ibp_cmd_prot              (bri_bs_ibp_cmd_prot),
  .dw32_in_ibp_cmd_cache             (bri_bs_ibp_cmd_cache),
  .dw32_in_ibp_cmd_lock              (bri_bs_ibp_cmd_lock),
  .dw32_in_ibp_cmd_excl              (bri_bs_ibp_cmd_excl),

  .dw32_in_ibp_rd_valid              (bri_bs_ibp_rd_valid),
  .dw32_in_ibp_rd_excl_ok            (bri_bs_ibp_rd_excl_ok),
  .dw32_in_ibp_rd_accept             (bri_bs_ibp_rd_accept),
  .dw32_in_ibp_err_rd                (bri_bs_ibp_err_rd),
  .dw32_in_ibp_rd_data               (bri_bs_ibp_rd_data),
  .dw32_in_ibp_rd_last               (bri_bs_ibp_rd_last),

  .dw32_in_ibp_wr_valid              (bri_bs_ibp_wr_valid),
  .dw32_in_ibp_wr_accept             (bri_bs_ibp_wr_accept),
  .dw32_in_ibp_wr_data               (bri_bs_ibp_wr_data),
  .dw32_in_ibp_wr_mask               (bri_bs_ibp_wr_mask),
  .dw32_in_ibp_wr_last               (bri_bs_ibp_wr_last),

  .dw32_in_ibp_wr_done               (bri_bs_ibp_wr_done),
  .dw32_in_ibp_wr_excl_done          (bri_bs_ibp_wr_excl_done),
  .dw32_in_ibp_err_wr                (bri_bs_ibp_err_wr),
  .dw32_in_ibp_wr_resp_accept        (bri_bs_ibp_wr_resp_accept),




    .dw32_out_0_ibp_cmd_chnl_valid  (in_2_out_0_ibp_cmd_chnl_valid),
    .dw32_out_0_ibp_cmd_chnl_accept (in_2_out_0_ibp_cmd_chnl_accept),
    .dw32_out_0_ibp_cmd_chnl        (in_2_out_0_ibp_cmd_chnl),

    .dw32_out_0_ibp_rd_chnl_valid   (in_2_out_0_ibp_rd_chnl_valid),
    .dw32_out_0_ibp_rd_chnl_accept  (in_2_out_0_ibp_rd_chnl_accept),
    .dw32_out_0_ibp_rd_chnl         (in_2_out_0_ibp_rd_chnl),

    .dw32_out_0_ibp_wd_chnl_valid   (in_2_out_0_ibp_wd_chnl_valid),
    .dw32_out_0_ibp_wd_chnl_accept  (in_2_out_0_ibp_wd_chnl_accept),
    .dw32_out_0_ibp_wd_chnl         (in_2_out_0_ibp_wd_chnl),

    .dw32_out_0_ibp_wrsp_chnl_valid (in_2_out_0_ibp_wrsp_chnl_valid),
    .dw32_out_0_ibp_wrsp_chnl_accept(in_2_out_0_ibp_wrsp_chnl_accept),
    .dw32_out_0_ibp_wrsp_chnl       (in_2_out_0_ibp_wrsp_chnl),





    .dw32_out_1_ibp_cmd_chnl_valid  (in_2_out_1_ibp_cmd_chnl_valid),
    .dw32_out_1_ibp_cmd_chnl_accept (in_2_out_1_ibp_cmd_chnl_accept),
    .dw32_out_1_ibp_cmd_chnl        (in_2_out_1_ibp_cmd_chnl),

    .dw32_out_1_ibp_rd_chnl_valid   (in_2_out_1_ibp_rd_chnl_valid),
    .dw32_out_1_ibp_rd_chnl_accept  (in_2_out_1_ibp_rd_chnl_accept),
    .dw32_out_1_ibp_rd_chnl         (in_2_out_1_ibp_rd_chnl),

    .dw32_out_1_ibp_wd_chnl_valid   (in_2_out_1_ibp_wd_chnl_valid),
    .dw32_out_1_ibp_wd_chnl_accept  (in_2_out_1_ibp_wd_chnl_accept),
    .dw32_out_1_ibp_wd_chnl         (in_2_out_1_ibp_wd_chnl),

    .dw32_out_1_ibp_wrsp_chnl_valid (in_2_out_1_ibp_wrsp_chnl_valid),
    .dw32_out_1_ibp_wrsp_chnl_accept(in_2_out_1_ibp_wrsp_chnl_accept),
    .dw32_out_1_ibp_wrsp_chnl       (in_2_out_1_ibp_wrsp_chnl),





    .dw32_out_2_ibp_cmd_chnl_valid  (in_2_out_2_ibp_cmd_chnl_valid),
    .dw32_out_2_ibp_cmd_chnl_accept (in_2_out_2_ibp_cmd_chnl_accept),
    .dw32_out_2_ibp_cmd_chnl        (in_2_out_2_ibp_cmd_chnl),

    .dw32_out_2_ibp_rd_chnl_valid   (in_2_out_2_ibp_rd_chnl_valid),
    .dw32_out_2_ibp_rd_chnl_accept  (in_2_out_2_ibp_rd_chnl_accept),
    .dw32_out_2_ibp_rd_chnl         (in_2_out_2_ibp_rd_chnl),

    .dw32_out_2_ibp_wd_chnl_valid   (in_2_out_2_ibp_wd_chnl_valid),
    .dw32_out_2_ibp_wd_chnl_accept  (in_2_out_2_ibp_wd_chnl_accept),
    .dw32_out_2_ibp_wd_chnl         (in_2_out_2_ibp_wd_chnl),

    .dw32_out_2_ibp_wrsp_chnl_valid (in_2_out_2_ibp_wrsp_chnl_valid),
    .dw32_out_2_ibp_wrsp_chnl_accept(in_2_out_2_ibp_wrsp_chnl_accept),
    .dw32_out_2_ibp_wrsp_chnl       (in_2_out_2_ibp_wrsp_chnl),





    .dw32_out_3_ibp_cmd_chnl_valid  (in_2_out_3_ibp_cmd_chnl_valid),
    .dw32_out_3_ibp_cmd_chnl_accept (in_2_out_3_ibp_cmd_chnl_accept),
    .dw32_out_3_ibp_cmd_chnl        (in_2_out_3_ibp_cmd_chnl),

    .dw32_out_3_ibp_rd_chnl_valid   (in_2_out_3_ibp_rd_chnl_valid),
    .dw32_out_3_ibp_rd_chnl_accept  (in_2_out_3_ibp_rd_chnl_accept),
    .dw32_out_3_ibp_rd_chnl         (in_2_out_3_ibp_rd_chnl),

    .dw32_out_3_ibp_wd_chnl_valid   (in_2_out_3_ibp_wd_chnl_valid),
    .dw32_out_3_ibp_wd_chnl_accept  (in_2_out_3_ibp_wd_chnl_accept),
    .dw32_out_3_ibp_wd_chnl         (in_2_out_3_ibp_wd_chnl),

    .dw32_out_3_ibp_wrsp_chnl_valid (in_2_out_3_ibp_wrsp_chnl_valid),
    .dw32_out_3_ibp_wrsp_chnl_accept(in_2_out_3_ibp_wrsp_chnl_accept),
    .dw32_out_3_ibp_wrsp_chnl       (in_2_out_3_ibp_wrsp_chnl),





    .dw32_out_4_ibp_cmd_chnl_valid  (in_2_out_4_ibp_cmd_chnl_valid),
    .dw32_out_4_ibp_cmd_chnl_accept (in_2_out_4_ibp_cmd_chnl_accept),
    .dw32_out_4_ibp_cmd_chnl        (in_2_out_4_ibp_cmd_chnl),

    .dw32_out_4_ibp_rd_chnl_valid   (in_2_out_4_ibp_rd_chnl_valid),
    .dw32_out_4_ibp_rd_chnl_accept  (in_2_out_4_ibp_rd_chnl_accept),
    .dw32_out_4_ibp_rd_chnl         (in_2_out_4_ibp_rd_chnl),

    .dw32_out_4_ibp_wd_chnl_valid   (in_2_out_4_ibp_wd_chnl_valid),
    .dw32_out_4_ibp_wd_chnl_accept  (in_2_out_4_ibp_wd_chnl_accept),
    .dw32_out_4_ibp_wd_chnl         (in_2_out_4_ibp_wd_chnl),

    .dw32_out_4_ibp_wrsp_chnl_valid (in_2_out_4_ibp_wrsp_chnl_valid),
    .dw32_out_4_ibp_wrsp_chnl_accept(in_2_out_4_ibp_wrsp_chnl_accept),
    .dw32_out_4_ibp_wrsp_chnl       (in_2_out_4_ibp_wrsp_chnl),





    .dw32_out_5_ibp_cmd_chnl_valid  (in_2_out_5_ibp_cmd_chnl_valid),
    .dw32_out_5_ibp_cmd_chnl_accept (in_2_out_5_ibp_cmd_chnl_accept),
    .dw32_out_5_ibp_cmd_chnl        (in_2_out_5_ibp_cmd_chnl),

    .dw32_out_5_ibp_rd_chnl_valid   (in_2_out_5_ibp_rd_chnl_valid),
    .dw32_out_5_ibp_rd_chnl_accept  (in_2_out_5_ibp_rd_chnl_accept),
    .dw32_out_5_ibp_rd_chnl         (in_2_out_5_ibp_rd_chnl),

    .dw32_out_5_ibp_wd_chnl_valid   (in_2_out_5_ibp_wd_chnl_valid),
    .dw32_out_5_ibp_wd_chnl_accept  (in_2_out_5_ibp_wd_chnl_accept),
    .dw32_out_5_ibp_wd_chnl         (in_2_out_5_ibp_wd_chnl),

    .dw32_out_5_ibp_wrsp_chnl_valid (in_2_out_5_ibp_wrsp_chnl_valid),
    .dw32_out_5_ibp_wrsp_chnl_accept(in_2_out_5_ibp_wrsp_chnl_accept),
    .dw32_out_5_ibp_wrsp_chnl       (in_2_out_5_ibp_wrsp_chnl),





    .dw32_out_6_ibp_cmd_chnl_valid  (in_2_out_6_ibp_cmd_chnl_valid),
    .dw32_out_6_ibp_cmd_chnl_accept (in_2_out_6_ibp_cmd_chnl_accept),
    .dw32_out_6_ibp_cmd_chnl        (in_2_out_6_ibp_cmd_chnl),

    .dw32_out_6_ibp_rd_chnl_valid   (in_2_out_6_ibp_rd_chnl_valid),
    .dw32_out_6_ibp_rd_chnl_accept  (in_2_out_6_ibp_rd_chnl_accept),
    .dw32_out_6_ibp_rd_chnl         (in_2_out_6_ibp_rd_chnl),

    .dw32_out_6_ibp_wd_chnl_valid   (in_2_out_6_ibp_wd_chnl_valid),
    .dw32_out_6_ibp_wd_chnl_accept  (in_2_out_6_ibp_wd_chnl_accept),
    .dw32_out_6_ibp_wd_chnl         (in_2_out_6_ibp_wd_chnl),

    .dw32_out_6_ibp_wrsp_chnl_valid (in_2_out_6_ibp_wrsp_chnl_valid),
    .dw32_out_6_ibp_wrsp_chnl_accept(in_2_out_6_ibp_wrsp_chnl_accept),
    .dw32_out_6_ibp_wrsp_chnl       (in_2_out_6_ibp_wrsp_chnl),



.clk         (clk),
.sync_rst_r  (rst_a),
.async_rst   (rst_a),
.rst_a       (rst_a)
);
mss_bus_switch_dw512_slv u_mss_bs_slv_3 (





























    .dw512_in_ibp_cmd_rgon (xtor_axi_bs_ibp_cmd_rgon),

  .dw512_in_ibp_cmd_valid             (xtor_axi_bs_ibp_cmd_valid),
  .dw512_in_ibp_cmd_accept            (xtor_axi_bs_ibp_cmd_accept),
  .dw512_in_ibp_cmd_read              (xtor_axi_bs_ibp_cmd_read),
  .dw512_in_ibp_cmd_addr              (xtor_axi_bs_ibp_cmd_addr),
  .dw512_in_ibp_cmd_wrap              (xtor_axi_bs_ibp_cmd_wrap),
  .dw512_in_ibp_cmd_data_size         (xtor_axi_bs_ibp_cmd_data_size),
  .dw512_in_ibp_cmd_burst_size        (xtor_axi_bs_ibp_cmd_burst_size),
  .dw512_in_ibp_cmd_prot              (xtor_axi_bs_ibp_cmd_prot),
  .dw512_in_ibp_cmd_cache             (xtor_axi_bs_ibp_cmd_cache),
  .dw512_in_ibp_cmd_lock              (xtor_axi_bs_ibp_cmd_lock),
  .dw512_in_ibp_cmd_excl              (xtor_axi_bs_ibp_cmd_excl),

  .dw512_in_ibp_rd_valid              (xtor_axi_bs_ibp_rd_valid),
  .dw512_in_ibp_rd_excl_ok            (xtor_axi_bs_ibp_rd_excl_ok),
  .dw512_in_ibp_rd_accept             (xtor_axi_bs_ibp_rd_accept),
  .dw512_in_ibp_err_rd                (xtor_axi_bs_ibp_err_rd),
  .dw512_in_ibp_rd_data               (xtor_axi_bs_ibp_rd_data),
  .dw512_in_ibp_rd_last               (xtor_axi_bs_ibp_rd_last),

  .dw512_in_ibp_wr_valid              (xtor_axi_bs_ibp_wr_valid),
  .dw512_in_ibp_wr_accept             (xtor_axi_bs_ibp_wr_accept),
  .dw512_in_ibp_wr_data               (xtor_axi_bs_ibp_wr_data),
  .dw512_in_ibp_wr_mask               (xtor_axi_bs_ibp_wr_mask),
  .dw512_in_ibp_wr_last               (xtor_axi_bs_ibp_wr_last),

  .dw512_in_ibp_wr_done               (xtor_axi_bs_ibp_wr_done),
  .dw512_in_ibp_wr_excl_done          (xtor_axi_bs_ibp_wr_excl_done),
  .dw512_in_ibp_err_wr                (xtor_axi_bs_ibp_err_wr),
  .dw512_in_ibp_wr_resp_accept        (xtor_axi_bs_ibp_wr_resp_accept),




    .dw512_out_0_ibp_cmd_chnl_valid  (in_3_out_0_ibp_cmd_chnl_valid),
    .dw512_out_0_ibp_cmd_chnl_accept (in_3_out_0_ibp_cmd_chnl_accept),
    .dw512_out_0_ibp_cmd_chnl        (in_3_out_0_ibp_cmd_chnl),

    .dw512_out_0_ibp_rd_chnl_valid   (in_3_out_0_ibp_rd_chnl_valid),
    .dw512_out_0_ibp_rd_chnl_accept  (in_3_out_0_ibp_rd_chnl_accept),
    .dw512_out_0_ibp_rd_chnl         (in_3_out_0_ibp_rd_chnl),

    .dw512_out_0_ibp_wd_chnl_valid   (in_3_out_0_ibp_wd_chnl_valid),
    .dw512_out_0_ibp_wd_chnl_accept  (in_3_out_0_ibp_wd_chnl_accept),
    .dw512_out_0_ibp_wd_chnl         (in_3_out_0_ibp_wd_chnl),

    .dw512_out_0_ibp_wrsp_chnl_valid (in_3_out_0_ibp_wrsp_chnl_valid),
    .dw512_out_0_ibp_wrsp_chnl_accept(in_3_out_0_ibp_wrsp_chnl_accept),
    .dw512_out_0_ibp_wrsp_chnl       (in_3_out_0_ibp_wrsp_chnl),





    .dw512_out_1_ibp_cmd_chnl_valid  (in_3_out_1_ibp_cmd_chnl_valid),
    .dw512_out_1_ibp_cmd_chnl_accept (in_3_out_1_ibp_cmd_chnl_accept),
    .dw512_out_1_ibp_cmd_chnl        (in_3_out_1_ibp_cmd_chnl),

    .dw512_out_1_ibp_rd_chnl_valid   (in_3_out_1_ibp_rd_chnl_valid),
    .dw512_out_1_ibp_rd_chnl_accept  (in_3_out_1_ibp_rd_chnl_accept),
    .dw512_out_1_ibp_rd_chnl         (in_3_out_1_ibp_rd_chnl),

    .dw512_out_1_ibp_wd_chnl_valid   (in_3_out_1_ibp_wd_chnl_valid),
    .dw512_out_1_ibp_wd_chnl_accept  (in_3_out_1_ibp_wd_chnl_accept),
    .dw512_out_1_ibp_wd_chnl         (in_3_out_1_ibp_wd_chnl),

    .dw512_out_1_ibp_wrsp_chnl_valid (in_3_out_1_ibp_wrsp_chnl_valid),
    .dw512_out_1_ibp_wrsp_chnl_accept(in_3_out_1_ibp_wrsp_chnl_accept),
    .dw512_out_1_ibp_wrsp_chnl       (in_3_out_1_ibp_wrsp_chnl),





    .dw512_out_2_ibp_cmd_chnl_valid  (in_3_out_2_ibp_cmd_chnl_valid),
    .dw512_out_2_ibp_cmd_chnl_accept (in_3_out_2_ibp_cmd_chnl_accept),
    .dw512_out_2_ibp_cmd_chnl        (in_3_out_2_ibp_cmd_chnl),

    .dw512_out_2_ibp_rd_chnl_valid   (in_3_out_2_ibp_rd_chnl_valid),
    .dw512_out_2_ibp_rd_chnl_accept  (in_3_out_2_ibp_rd_chnl_accept),
    .dw512_out_2_ibp_rd_chnl         (in_3_out_2_ibp_rd_chnl),

    .dw512_out_2_ibp_wd_chnl_valid   (in_3_out_2_ibp_wd_chnl_valid),
    .dw512_out_2_ibp_wd_chnl_accept  (in_3_out_2_ibp_wd_chnl_accept),
    .dw512_out_2_ibp_wd_chnl         (in_3_out_2_ibp_wd_chnl),

    .dw512_out_2_ibp_wrsp_chnl_valid (in_3_out_2_ibp_wrsp_chnl_valid),
    .dw512_out_2_ibp_wrsp_chnl_accept(in_3_out_2_ibp_wrsp_chnl_accept),
    .dw512_out_2_ibp_wrsp_chnl       (in_3_out_2_ibp_wrsp_chnl),





    .dw512_out_3_ibp_cmd_chnl_valid  (in_3_out_3_ibp_cmd_chnl_valid),
    .dw512_out_3_ibp_cmd_chnl_accept (in_3_out_3_ibp_cmd_chnl_accept),
    .dw512_out_3_ibp_cmd_chnl        (in_3_out_3_ibp_cmd_chnl),

    .dw512_out_3_ibp_rd_chnl_valid   (in_3_out_3_ibp_rd_chnl_valid),
    .dw512_out_3_ibp_rd_chnl_accept  (in_3_out_3_ibp_rd_chnl_accept),
    .dw512_out_3_ibp_rd_chnl         (in_3_out_3_ibp_rd_chnl),

    .dw512_out_3_ibp_wd_chnl_valid   (in_3_out_3_ibp_wd_chnl_valid),
    .dw512_out_3_ibp_wd_chnl_accept  (in_3_out_3_ibp_wd_chnl_accept),
    .dw512_out_3_ibp_wd_chnl         (in_3_out_3_ibp_wd_chnl),

    .dw512_out_3_ibp_wrsp_chnl_valid (in_3_out_3_ibp_wrsp_chnl_valid),
    .dw512_out_3_ibp_wrsp_chnl_accept(in_3_out_3_ibp_wrsp_chnl_accept),
    .dw512_out_3_ibp_wrsp_chnl       (in_3_out_3_ibp_wrsp_chnl),





    .dw512_out_4_ibp_cmd_chnl_valid  (in_3_out_4_ibp_cmd_chnl_valid),
    .dw512_out_4_ibp_cmd_chnl_accept (in_3_out_4_ibp_cmd_chnl_accept),
    .dw512_out_4_ibp_cmd_chnl        (in_3_out_4_ibp_cmd_chnl),

    .dw512_out_4_ibp_rd_chnl_valid   (in_3_out_4_ibp_rd_chnl_valid),
    .dw512_out_4_ibp_rd_chnl_accept  (in_3_out_4_ibp_rd_chnl_accept),
    .dw512_out_4_ibp_rd_chnl         (in_3_out_4_ibp_rd_chnl),

    .dw512_out_4_ibp_wd_chnl_valid   (in_3_out_4_ibp_wd_chnl_valid),
    .dw512_out_4_ibp_wd_chnl_accept  (in_3_out_4_ibp_wd_chnl_accept),
    .dw512_out_4_ibp_wd_chnl         (in_3_out_4_ibp_wd_chnl),

    .dw512_out_4_ibp_wrsp_chnl_valid (in_3_out_4_ibp_wrsp_chnl_valid),
    .dw512_out_4_ibp_wrsp_chnl_accept(in_3_out_4_ibp_wrsp_chnl_accept),
    .dw512_out_4_ibp_wrsp_chnl       (in_3_out_4_ibp_wrsp_chnl),





    .dw512_out_5_ibp_cmd_chnl_valid  (in_3_out_5_ibp_cmd_chnl_valid),
    .dw512_out_5_ibp_cmd_chnl_accept (in_3_out_5_ibp_cmd_chnl_accept),
    .dw512_out_5_ibp_cmd_chnl        (in_3_out_5_ibp_cmd_chnl),

    .dw512_out_5_ibp_rd_chnl_valid   (in_3_out_5_ibp_rd_chnl_valid),
    .dw512_out_5_ibp_rd_chnl_accept  (in_3_out_5_ibp_rd_chnl_accept),
    .dw512_out_5_ibp_rd_chnl         (in_3_out_5_ibp_rd_chnl),

    .dw512_out_5_ibp_wd_chnl_valid   (in_3_out_5_ibp_wd_chnl_valid),
    .dw512_out_5_ibp_wd_chnl_accept  (in_3_out_5_ibp_wd_chnl_accept),
    .dw512_out_5_ibp_wd_chnl         (in_3_out_5_ibp_wd_chnl),

    .dw512_out_5_ibp_wrsp_chnl_valid (in_3_out_5_ibp_wrsp_chnl_valid),
    .dw512_out_5_ibp_wrsp_chnl_accept(in_3_out_5_ibp_wrsp_chnl_accept),
    .dw512_out_5_ibp_wrsp_chnl       (in_3_out_5_ibp_wrsp_chnl),





    .dw512_out_6_ibp_cmd_chnl_valid  (in_3_out_6_ibp_cmd_chnl_valid),
    .dw512_out_6_ibp_cmd_chnl_accept (in_3_out_6_ibp_cmd_chnl_accept),
    .dw512_out_6_ibp_cmd_chnl        (in_3_out_6_ibp_cmd_chnl),

    .dw512_out_6_ibp_rd_chnl_valid   (in_3_out_6_ibp_rd_chnl_valid),
    .dw512_out_6_ibp_rd_chnl_accept  (in_3_out_6_ibp_rd_chnl_accept),
    .dw512_out_6_ibp_rd_chnl         (in_3_out_6_ibp_rd_chnl),

    .dw512_out_6_ibp_wd_chnl_valid   (in_3_out_6_ibp_wd_chnl_valid),
    .dw512_out_6_ibp_wd_chnl_accept  (in_3_out_6_ibp_wd_chnl_accept),
    .dw512_out_6_ibp_wd_chnl         (in_3_out_6_ibp_wd_chnl),

    .dw512_out_6_ibp_wrsp_chnl_valid (in_3_out_6_ibp_wrsp_chnl_valid),
    .dw512_out_6_ibp_wrsp_chnl_accept(in_3_out_6_ibp_wrsp_chnl_accept),
    .dw512_out_6_ibp_wrsp_chnl       (in_3_out_6_ibp_wrsp_chnl),



.clk         (clk),
.sync_rst_r  (rst_a),
.async_rst   (rst_a),
.rst_a       (rst_a)
);

//
// Instantiation for each slave port
//
mss_bus_switch_ibp_dw32_mst u_mss_bs_mst_0 (



    .ibp_dw32_in_0_ibp_cmd_chnl_valid  (in_0_out_0_ibp_cmd_chnl_valid),
    .ibp_dw32_in_0_ibp_cmd_chnl_accept (in_0_out_0_ibp_cmd_chnl_accept),
    .ibp_dw32_in_0_ibp_cmd_chnl        (in_0_out_0_ibp_cmd_chnl),

    .ibp_dw32_in_0_ibp_rd_chnl_valid   (in_0_out_0_ibp_rd_chnl_valid),
    .ibp_dw32_in_0_ibp_rd_chnl_accept  (in_0_out_0_ibp_rd_chnl_accept),
    .ibp_dw32_in_0_ibp_rd_chnl         (in_0_out_0_ibp_rd_chnl),

    .ibp_dw32_in_0_ibp_wd_chnl_valid   (in_0_out_0_ibp_wd_chnl_valid),
    .ibp_dw32_in_0_ibp_wd_chnl_accept  (in_0_out_0_ibp_wd_chnl_accept),
    .ibp_dw32_in_0_ibp_wd_chnl         (in_0_out_0_ibp_wd_chnl),

    .ibp_dw32_in_0_ibp_wrsp_chnl_valid (in_0_out_0_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_0_ibp_wrsp_chnl_accept(in_0_out_0_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_0_ibp_wrsp_chnl       (in_0_out_0_ibp_wrsp_chnl),





    .ibp_dw32_in_1_ibp_cmd_chnl_valid  (in_1_out_0_ibp_cmd_chnl_valid),
    .ibp_dw32_in_1_ibp_cmd_chnl_accept (in_1_out_0_ibp_cmd_chnl_accept),
    .ibp_dw32_in_1_ibp_cmd_chnl        (in_1_out_0_ibp_cmd_chnl),

    .ibp_dw32_in_1_ibp_rd_chnl_valid   (in_1_out_0_ibp_rd_chnl_valid),
    .ibp_dw32_in_1_ibp_rd_chnl_accept  (in_1_out_0_ibp_rd_chnl_accept),
    .ibp_dw32_in_1_ibp_rd_chnl         (in_1_out_0_ibp_rd_chnl),

    .ibp_dw32_in_1_ibp_wd_chnl_valid   (in_1_out_0_ibp_wd_chnl_valid),
    .ibp_dw32_in_1_ibp_wd_chnl_accept  (in_1_out_0_ibp_wd_chnl_accept),
    .ibp_dw32_in_1_ibp_wd_chnl         (in_1_out_0_ibp_wd_chnl),

    .ibp_dw32_in_1_ibp_wrsp_chnl_valid (in_1_out_0_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_1_ibp_wrsp_chnl_accept(in_1_out_0_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_1_ibp_wrsp_chnl       (in_1_out_0_ibp_wrsp_chnl),





    .ibp_dw32_in_2_ibp_cmd_chnl_valid  (in_2_out_0_ibp_cmd_chnl_valid),
    .ibp_dw32_in_2_ibp_cmd_chnl_accept (in_2_out_0_ibp_cmd_chnl_accept),
    .ibp_dw32_in_2_ibp_cmd_chnl        (in_2_out_0_ibp_cmd_chnl),

    .ibp_dw32_in_2_ibp_rd_chnl_valid   (in_2_out_0_ibp_rd_chnl_valid),
    .ibp_dw32_in_2_ibp_rd_chnl_accept  (in_2_out_0_ibp_rd_chnl_accept),
    .ibp_dw32_in_2_ibp_rd_chnl         (in_2_out_0_ibp_rd_chnl),

    .ibp_dw32_in_2_ibp_wd_chnl_valid   (in_2_out_0_ibp_wd_chnl_valid),
    .ibp_dw32_in_2_ibp_wd_chnl_accept  (in_2_out_0_ibp_wd_chnl_accept),
    .ibp_dw32_in_2_ibp_wd_chnl         (in_2_out_0_ibp_wd_chnl),

    .ibp_dw32_in_2_ibp_wrsp_chnl_valid (in_2_out_0_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_2_ibp_wrsp_chnl_accept(in_2_out_0_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_2_ibp_wrsp_chnl       (in_2_out_0_ibp_wrsp_chnl),





    .ibp_dw32_in_3_ibp_cmd_chnl_valid  (in_3_out_0_ibp_cmd_chnl_valid),
    .ibp_dw32_in_3_ibp_cmd_chnl_accept (in_3_out_0_ibp_cmd_chnl_accept),
    .ibp_dw32_in_3_ibp_cmd_chnl        (in_3_out_0_ibp_cmd_chnl),

    .ibp_dw32_in_3_ibp_rd_chnl_valid   (in_3_out_0_ibp_rd_chnl_valid),
    .ibp_dw32_in_3_ibp_rd_chnl_accept  (in_3_out_0_ibp_rd_chnl_accept),
    .ibp_dw32_in_3_ibp_rd_chnl         (in_3_out_0_ibp_rd_chnl),

    .ibp_dw32_in_3_ibp_wd_chnl_valid   (in_3_out_0_ibp_wd_chnl_valid),
    .ibp_dw32_in_3_ibp_wd_chnl_accept  (in_3_out_0_ibp_wd_chnl_accept),
    .ibp_dw32_in_3_ibp_wd_chnl         (in_3_out_0_ibp_wd_chnl),

    .ibp_dw32_in_3_ibp_wrsp_chnl_valid (in_3_out_0_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_3_ibp_wrsp_chnl_accept(in_3_out_0_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_3_ibp_wrsp_chnl       (in_3_out_0_ibp_wrsp_chnl),



  .ibp_dw32_out_ibp_cmd_valid             (iccm_ahb_hbs_ibp_cmd_valid),
  .ibp_dw32_out_ibp_cmd_accept            (iccm_ahb_hbs_ibp_cmd_accept),
  .ibp_dw32_out_ibp_cmd_read              (iccm_ahb_hbs_ibp_cmd_read),
  .ibp_dw32_out_ibp_cmd_addr              (iccm_ahb_hbs_ibp_cmd_addr),
  .ibp_dw32_out_ibp_cmd_wrap              (iccm_ahb_hbs_ibp_cmd_wrap),
  .ibp_dw32_out_ibp_cmd_data_size         (iccm_ahb_hbs_ibp_cmd_data_size),
  .ibp_dw32_out_ibp_cmd_burst_size        (iccm_ahb_hbs_ibp_cmd_burst_size),
  .ibp_dw32_out_ibp_cmd_prot              (iccm_ahb_hbs_ibp_cmd_prot),
  .ibp_dw32_out_ibp_cmd_cache             (iccm_ahb_hbs_ibp_cmd_cache),
  .ibp_dw32_out_ibp_cmd_lock              (iccm_ahb_hbs_ibp_cmd_lock),
  .ibp_dw32_out_ibp_cmd_excl              (iccm_ahb_hbs_ibp_cmd_excl),

  .ibp_dw32_out_ibp_rd_valid              (iccm_ahb_hbs_ibp_rd_valid),
  .ibp_dw32_out_ibp_rd_excl_ok            (iccm_ahb_hbs_ibp_rd_excl_ok),
  .ibp_dw32_out_ibp_rd_accept             (iccm_ahb_hbs_ibp_rd_accept),
  .ibp_dw32_out_ibp_err_rd                (iccm_ahb_hbs_ibp_err_rd),
  .ibp_dw32_out_ibp_rd_data               (iccm_ahb_hbs_ibp_rd_data),
  .ibp_dw32_out_ibp_rd_last               (iccm_ahb_hbs_ibp_rd_last),

  .ibp_dw32_out_ibp_wr_valid              (iccm_ahb_hbs_ibp_wr_valid),
  .ibp_dw32_out_ibp_wr_accept             (iccm_ahb_hbs_ibp_wr_accept),
  .ibp_dw32_out_ibp_wr_data               (iccm_ahb_hbs_ibp_wr_data),
  .ibp_dw32_out_ibp_wr_mask               (iccm_ahb_hbs_ibp_wr_mask),
  .ibp_dw32_out_ibp_wr_last               (iccm_ahb_hbs_ibp_wr_last),

  .ibp_dw32_out_ibp_wr_done               (iccm_ahb_hbs_ibp_wr_done),
  .ibp_dw32_out_ibp_wr_excl_done          (iccm_ahb_hbs_ibp_wr_excl_done),
  .ibp_dw32_out_ibp_err_wr                (iccm_ahb_hbs_ibp_err_wr),
  .ibp_dw32_out_ibp_wr_resp_accept        (iccm_ahb_hbs_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);
mss_bus_switch_ibp_dw32_mst u_mss_bs_mst_1 (



    .ibp_dw32_in_0_ibp_cmd_chnl_valid  (in_0_out_1_ibp_cmd_chnl_valid),
    .ibp_dw32_in_0_ibp_cmd_chnl_accept (in_0_out_1_ibp_cmd_chnl_accept),
    .ibp_dw32_in_0_ibp_cmd_chnl        (in_0_out_1_ibp_cmd_chnl),

    .ibp_dw32_in_0_ibp_rd_chnl_valid   (in_0_out_1_ibp_rd_chnl_valid),
    .ibp_dw32_in_0_ibp_rd_chnl_accept  (in_0_out_1_ibp_rd_chnl_accept),
    .ibp_dw32_in_0_ibp_rd_chnl         (in_0_out_1_ibp_rd_chnl),

    .ibp_dw32_in_0_ibp_wd_chnl_valid   (in_0_out_1_ibp_wd_chnl_valid),
    .ibp_dw32_in_0_ibp_wd_chnl_accept  (in_0_out_1_ibp_wd_chnl_accept),
    .ibp_dw32_in_0_ibp_wd_chnl         (in_0_out_1_ibp_wd_chnl),

    .ibp_dw32_in_0_ibp_wrsp_chnl_valid (in_0_out_1_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_0_ibp_wrsp_chnl_accept(in_0_out_1_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_0_ibp_wrsp_chnl       (in_0_out_1_ibp_wrsp_chnl),





    .ibp_dw32_in_1_ibp_cmd_chnl_valid  (in_1_out_1_ibp_cmd_chnl_valid),
    .ibp_dw32_in_1_ibp_cmd_chnl_accept (in_1_out_1_ibp_cmd_chnl_accept),
    .ibp_dw32_in_1_ibp_cmd_chnl        (in_1_out_1_ibp_cmd_chnl),

    .ibp_dw32_in_1_ibp_rd_chnl_valid   (in_1_out_1_ibp_rd_chnl_valid),
    .ibp_dw32_in_1_ibp_rd_chnl_accept  (in_1_out_1_ibp_rd_chnl_accept),
    .ibp_dw32_in_1_ibp_rd_chnl         (in_1_out_1_ibp_rd_chnl),

    .ibp_dw32_in_1_ibp_wd_chnl_valid   (in_1_out_1_ibp_wd_chnl_valid),
    .ibp_dw32_in_1_ibp_wd_chnl_accept  (in_1_out_1_ibp_wd_chnl_accept),
    .ibp_dw32_in_1_ibp_wd_chnl         (in_1_out_1_ibp_wd_chnl),

    .ibp_dw32_in_1_ibp_wrsp_chnl_valid (in_1_out_1_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_1_ibp_wrsp_chnl_accept(in_1_out_1_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_1_ibp_wrsp_chnl       (in_1_out_1_ibp_wrsp_chnl),





    .ibp_dw32_in_2_ibp_cmd_chnl_valid  (in_2_out_1_ibp_cmd_chnl_valid),
    .ibp_dw32_in_2_ibp_cmd_chnl_accept (in_2_out_1_ibp_cmd_chnl_accept),
    .ibp_dw32_in_2_ibp_cmd_chnl        (in_2_out_1_ibp_cmd_chnl),

    .ibp_dw32_in_2_ibp_rd_chnl_valid   (in_2_out_1_ibp_rd_chnl_valid),
    .ibp_dw32_in_2_ibp_rd_chnl_accept  (in_2_out_1_ibp_rd_chnl_accept),
    .ibp_dw32_in_2_ibp_rd_chnl         (in_2_out_1_ibp_rd_chnl),

    .ibp_dw32_in_2_ibp_wd_chnl_valid   (in_2_out_1_ibp_wd_chnl_valid),
    .ibp_dw32_in_2_ibp_wd_chnl_accept  (in_2_out_1_ibp_wd_chnl_accept),
    .ibp_dw32_in_2_ibp_wd_chnl         (in_2_out_1_ibp_wd_chnl),

    .ibp_dw32_in_2_ibp_wrsp_chnl_valid (in_2_out_1_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_2_ibp_wrsp_chnl_accept(in_2_out_1_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_2_ibp_wrsp_chnl       (in_2_out_1_ibp_wrsp_chnl),





    .ibp_dw32_in_3_ibp_cmd_chnl_valid  (in_3_out_1_ibp_cmd_chnl_valid),
    .ibp_dw32_in_3_ibp_cmd_chnl_accept (in_3_out_1_ibp_cmd_chnl_accept),
    .ibp_dw32_in_3_ibp_cmd_chnl        (in_3_out_1_ibp_cmd_chnl),

    .ibp_dw32_in_3_ibp_rd_chnl_valid   (in_3_out_1_ibp_rd_chnl_valid),
    .ibp_dw32_in_3_ibp_rd_chnl_accept  (in_3_out_1_ibp_rd_chnl_accept),
    .ibp_dw32_in_3_ibp_rd_chnl         (in_3_out_1_ibp_rd_chnl),

    .ibp_dw32_in_3_ibp_wd_chnl_valid   (in_3_out_1_ibp_wd_chnl_valid),
    .ibp_dw32_in_3_ibp_wd_chnl_accept  (in_3_out_1_ibp_wd_chnl_accept),
    .ibp_dw32_in_3_ibp_wd_chnl         (in_3_out_1_ibp_wd_chnl),

    .ibp_dw32_in_3_ibp_wrsp_chnl_valid (in_3_out_1_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_3_ibp_wrsp_chnl_accept(in_3_out_1_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_3_ibp_wrsp_chnl       (in_3_out_1_ibp_wrsp_chnl),



  .ibp_dw32_out_ibp_cmd_valid             (dccm_ahb_hbs_ibp_cmd_valid),
  .ibp_dw32_out_ibp_cmd_accept            (dccm_ahb_hbs_ibp_cmd_accept),
  .ibp_dw32_out_ibp_cmd_read              (dccm_ahb_hbs_ibp_cmd_read),
  .ibp_dw32_out_ibp_cmd_addr              (dccm_ahb_hbs_ibp_cmd_addr),
  .ibp_dw32_out_ibp_cmd_wrap              (dccm_ahb_hbs_ibp_cmd_wrap),
  .ibp_dw32_out_ibp_cmd_data_size         (dccm_ahb_hbs_ibp_cmd_data_size),
  .ibp_dw32_out_ibp_cmd_burst_size        (dccm_ahb_hbs_ibp_cmd_burst_size),
  .ibp_dw32_out_ibp_cmd_prot              (dccm_ahb_hbs_ibp_cmd_prot),
  .ibp_dw32_out_ibp_cmd_cache             (dccm_ahb_hbs_ibp_cmd_cache),
  .ibp_dw32_out_ibp_cmd_lock              (dccm_ahb_hbs_ibp_cmd_lock),
  .ibp_dw32_out_ibp_cmd_excl              (dccm_ahb_hbs_ibp_cmd_excl),

  .ibp_dw32_out_ibp_rd_valid              (dccm_ahb_hbs_ibp_rd_valid),
  .ibp_dw32_out_ibp_rd_excl_ok            (dccm_ahb_hbs_ibp_rd_excl_ok),
  .ibp_dw32_out_ibp_rd_accept             (dccm_ahb_hbs_ibp_rd_accept),
  .ibp_dw32_out_ibp_err_rd                (dccm_ahb_hbs_ibp_err_rd),
  .ibp_dw32_out_ibp_rd_data               (dccm_ahb_hbs_ibp_rd_data),
  .ibp_dw32_out_ibp_rd_last               (dccm_ahb_hbs_ibp_rd_last),

  .ibp_dw32_out_ibp_wr_valid              (dccm_ahb_hbs_ibp_wr_valid),
  .ibp_dw32_out_ibp_wr_accept             (dccm_ahb_hbs_ibp_wr_accept),
  .ibp_dw32_out_ibp_wr_data               (dccm_ahb_hbs_ibp_wr_data),
  .ibp_dw32_out_ibp_wr_mask               (dccm_ahb_hbs_ibp_wr_mask),
  .ibp_dw32_out_ibp_wr_last               (dccm_ahb_hbs_ibp_wr_last),

  .ibp_dw32_out_ibp_wr_done               (dccm_ahb_hbs_ibp_wr_done),
  .ibp_dw32_out_ibp_wr_excl_done          (dccm_ahb_hbs_ibp_wr_excl_done),
  .ibp_dw32_out_ibp_err_wr                (dccm_ahb_hbs_ibp_err_wr),
  .ibp_dw32_out_ibp_wr_resp_accept        (dccm_ahb_hbs_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);
mss_bus_switch_ibp_dw32_mst u_mss_bs_mst_2 (



    .ibp_dw32_in_0_ibp_cmd_chnl_valid  (in_0_out_2_ibp_cmd_chnl_valid),
    .ibp_dw32_in_0_ibp_cmd_chnl_accept (in_0_out_2_ibp_cmd_chnl_accept),
    .ibp_dw32_in_0_ibp_cmd_chnl        (in_0_out_2_ibp_cmd_chnl),

    .ibp_dw32_in_0_ibp_rd_chnl_valid   (in_0_out_2_ibp_rd_chnl_valid),
    .ibp_dw32_in_0_ibp_rd_chnl_accept  (in_0_out_2_ibp_rd_chnl_accept),
    .ibp_dw32_in_0_ibp_rd_chnl         (in_0_out_2_ibp_rd_chnl),

    .ibp_dw32_in_0_ibp_wd_chnl_valid   (in_0_out_2_ibp_wd_chnl_valid),
    .ibp_dw32_in_0_ibp_wd_chnl_accept  (in_0_out_2_ibp_wd_chnl_accept),
    .ibp_dw32_in_0_ibp_wd_chnl         (in_0_out_2_ibp_wd_chnl),

    .ibp_dw32_in_0_ibp_wrsp_chnl_valid (in_0_out_2_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_0_ibp_wrsp_chnl_accept(in_0_out_2_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_0_ibp_wrsp_chnl       (in_0_out_2_ibp_wrsp_chnl),





    .ibp_dw32_in_1_ibp_cmd_chnl_valid  (in_1_out_2_ibp_cmd_chnl_valid),
    .ibp_dw32_in_1_ibp_cmd_chnl_accept (in_1_out_2_ibp_cmd_chnl_accept),
    .ibp_dw32_in_1_ibp_cmd_chnl        (in_1_out_2_ibp_cmd_chnl),

    .ibp_dw32_in_1_ibp_rd_chnl_valid   (in_1_out_2_ibp_rd_chnl_valid),
    .ibp_dw32_in_1_ibp_rd_chnl_accept  (in_1_out_2_ibp_rd_chnl_accept),
    .ibp_dw32_in_1_ibp_rd_chnl         (in_1_out_2_ibp_rd_chnl),

    .ibp_dw32_in_1_ibp_wd_chnl_valid   (in_1_out_2_ibp_wd_chnl_valid),
    .ibp_dw32_in_1_ibp_wd_chnl_accept  (in_1_out_2_ibp_wd_chnl_accept),
    .ibp_dw32_in_1_ibp_wd_chnl         (in_1_out_2_ibp_wd_chnl),

    .ibp_dw32_in_1_ibp_wrsp_chnl_valid (in_1_out_2_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_1_ibp_wrsp_chnl_accept(in_1_out_2_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_1_ibp_wrsp_chnl       (in_1_out_2_ibp_wrsp_chnl),





    .ibp_dw32_in_2_ibp_cmd_chnl_valid  (in_2_out_2_ibp_cmd_chnl_valid),
    .ibp_dw32_in_2_ibp_cmd_chnl_accept (in_2_out_2_ibp_cmd_chnl_accept),
    .ibp_dw32_in_2_ibp_cmd_chnl        (in_2_out_2_ibp_cmd_chnl),

    .ibp_dw32_in_2_ibp_rd_chnl_valid   (in_2_out_2_ibp_rd_chnl_valid),
    .ibp_dw32_in_2_ibp_rd_chnl_accept  (in_2_out_2_ibp_rd_chnl_accept),
    .ibp_dw32_in_2_ibp_rd_chnl         (in_2_out_2_ibp_rd_chnl),

    .ibp_dw32_in_2_ibp_wd_chnl_valid   (in_2_out_2_ibp_wd_chnl_valid),
    .ibp_dw32_in_2_ibp_wd_chnl_accept  (in_2_out_2_ibp_wd_chnl_accept),
    .ibp_dw32_in_2_ibp_wd_chnl         (in_2_out_2_ibp_wd_chnl),

    .ibp_dw32_in_2_ibp_wrsp_chnl_valid (in_2_out_2_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_2_ibp_wrsp_chnl_accept(in_2_out_2_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_2_ibp_wrsp_chnl       (in_2_out_2_ibp_wrsp_chnl),





    .ibp_dw32_in_3_ibp_cmd_chnl_valid  (in_3_out_2_ibp_cmd_chnl_valid),
    .ibp_dw32_in_3_ibp_cmd_chnl_accept (in_3_out_2_ibp_cmd_chnl_accept),
    .ibp_dw32_in_3_ibp_cmd_chnl        (in_3_out_2_ibp_cmd_chnl),

    .ibp_dw32_in_3_ibp_rd_chnl_valid   (in_3_out_2_ibp_rd_chnl_valid),
    .ibp_dw32_in_3_ibp_rd_chnl_accept  (in_3_out_2_ibp_rd_chnl_accept),
    .ibp_dw32_in_3_ibp_rd_chnl         (in_3_out_2_ibp_rd_chnl),

    .ibp_dw32_in_3_ibp_wd_chnl_valid   (in_3_out_2_ibp_wd_chnl_valid),
    .ibp_dw32_in_3_ibp_wd_chnl_accept  (in_3_out_2_ibp_wd_chnl_accept),
    .ibp_dw32_in_3_ibp_wd_chnl         (in_3_out_2_ibp_wd_chnl),

    .ibp_dw32_in_3_ibp_wrsp_chnl_valid (in_3_out_2_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_3_ibp_wrsp_chnl_accept(in_3_out_2_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_3_ibp_wrsp_chnl       (in_3_out_2_ibp_wrsp_chnl),



  .ibp_dw32_out_ibp_cmd_valid             (mmio_ahb_hbs_ibp_cmd_valid),
  .ibp_dw32_out_ibp_cmd_accept            (mmio_ahb_hbs_ibp_cmd_accept),
  .ibp_dw32_out_ibp_cmd_read              (mmio_ahb_hbs_ibp_cmd_read),
  .ibp_dw32_out_ibp_cmd_addr              (mmio_ahb_hbs_ibp_cmd_addr),
  .ibp_dw32_out_ibp_cmd_wrap              (mmio_ahb_hbs_ibp_cmd_wrap),
  .ibp_dw32_out_ibp_cmd_data_size         (mmio_ahb_hbs_ibp_cmd_data_size),
  .ibp_dw32_out_ibp_cmd_burst_size        (mmio_ahb_hbs_ibp_cmd_burst_size),
  .ibp_dw32_out_ibp_cmd_prot              (mmio_ahb_hbs_ibp_cmd_prot),
  .ibp_dw32_out_ibp_cmd_cache             (mmio_ahb_hbs_ibp_cmd_cache),
  .ibp_dw32_out_ibp_cmd_lock              (mmio_ahb_hbs_ibp_cmd_lock),
  .ibp_dw32_out_ibp_cmd_excl              (mmio_ahb_hbs_ibp_cmd_excl),

  .ibp_dw32_out_ibp_rd_valid              (mmio_ahb_hbs_ibp_rd_valid),
  .ibp_dw32_out_ibp_rd_excl_ok            (mmio_ahb_hbs_ibp_rd_excl_ok),
  .ibp_dw32_out_ibp_rd_accept             (mmio_ahb_hbs_ibp_rd_accept),
  .ibp_dw32_out_ibp_err_rd                (mmio_ahb_hbs_ibp_err_rd),
  .ibp_dw32_out_ibp_rd_data               (mmio_ahb_hbs_ibp_rd_data),
  .ibp_dw32_out_ibp_rd_last               (mmio_ahb_hbs_ibp_rd_last),

  .ibp_dw32_out_ibp_wr_valid              (mmio_ahb_hbs_ibp_wr_valid),
  .ibp_dw32_out_ibp_wr_accept             (mmio_ahb_hbs_ibp_wr_accept),
  .ibp_dw32_out_ibp_wr_data               (mmio_ahb_hbs_ibp_wr_data),
  .ibp_dw32_out_ibp_wr_mask               (mmio_ahb_hbs_ibp_wr_mask),
  .ibp_dw32_out_ibp_wr_last               (mmio_ahb_hbs_ibp_wr_last),

  .ibp_dw32_out_ibp_wr_done               (mmio_ahb_hbs_ibp_wr_done),
  .ibp_dw32_out_ibp_wr_excl_done          (mmio_ahb_hbs_ibp_wr_excl_done),
  .ibp_dw32_out_ibp_err_wr                (mmio_ahb_hbs_ibp_err_wr),
  .ibp_dw32_out_ibp_wr_resp_accept        (mmio_ahb_hbs_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);
mss_bus_switch_ibp_dw32_mst u_mss_bs_mst_3 (



    .ibp_dw32_in_0_ibp_cmd_chnl_valid  (in_0_out_3_ibp_cmd_chnl_valid),
    .ibp_dw32_in_0_ibp_cmd_chnl_accept (in_0_out_3_ibp_cmd_chnl_accept),
    .ibp_dw32_in_0_ibp_cmd_chnl        (in_0_out_3_ibp_cmd_chnl),

    .ibp_dw32_in_0_ibp_rd_chnl_valid   (in_0_out_3_ibp_rd_chnl_valid),
    .ibp_dw32_in_0_ibp_rd_chnl_accept  (in_0_out_3_ibp_rd_chnl_accept),
    .ibp_dw32_in_0_ibp_rd_chnl         (in_0_out_3_ibp_rd_chnl),

    .ibp_dw32_in_0_ibp_wd_chnl_valid   (in_0_out_3_ibp_wd_chnl_valid),
    .ibp_dw32_in_0_ibp_wd_chnl_accept  (in_0_out_3_ibp_wd_chnl_accept),
    .ibp_dw32_in_0_ibp_wd_chnl         (in_0_out_3_ibp_wd_chnl),

    .ibp_dw32_in_0_ibp_wrsp_chnl_valid (in_0_out_3_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_0_ibp_wrsp_chnl_accept(in_0_out_3_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_0_ibp_wrsp_chnl       (in_0_out_3_ibp_wrsp_chnl),





    .ibp_dw32_in_1_ibp_cmd_chnl_valid  (in_1_out_3_ibp_cmd_chnl_valid),
    .ibp_dw32_in_1_ibp_cmd_chnl_accept (in_1_out_3_ibp_cmd_chnl_accept),
    .ibp_dw32_in_1_ibp_cmd_chnl        (in_1_out_3_ibp_cmd_chnl),

    .ibp_dw32_in_1_ibp_rd_chnl_valid   (in_1_out_3_ibp_rd_chnl_valid),
    .ibp_dw32_in_1_ibp_rd_chnl_accept  (in_1_out_3_ibp_rd_chnl_accept),
    .ibp_dw32_in_1_ibp_rd_chnl         (in_1_out_3_ibp_rd_chnl),

    .ibp_dw32_in_1_ibp_wd_chnl_valid   (in_1_out_3_ibp_wd_chnl_valid),
    .ibp_dw32_in_1_ibp_wd_chnl_accept  (in_1_out_3_ibp_wd_chnl_accept),
    .ibp_dw32_in_1_ibp_wd_chnl         (in_1_out_3_ibp_wd_chnl),

    .ibp_dw32_in_1_ibp_wrsp_chnl_valid (in_1_out_3_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_1_ibp_wrsp_chnl_accept(in_1_out_3_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_1_ibp_wrsp_chnl       (in_1_out_3_ibp_wrsp_chnl),





    .ibp_dw32_in_2_ibp_cmd_chnl_valid  (in_2_out_3_ibp_cmd_chnl_valid),
    .ibp_dw32_in_2_ibp_cmd_chnl_accept (in_2_out_3_ibp_cmd_chnl_accept),
    .ibp_dw32_in_2_ibp_cmd_chnl        (in_2_out_3_ibp_cmd_chnl),

    .ibp_dw32_in_2_ibp_rd_chnl_valid   (in_2_out_3_ibp_rd_chnl_valid),
    .ibp_dw32_in_2_ibp_rd_chnl_accept  (in_2_out_3_ibp_rd_chnl_accept),
    .ibp_dw32_in_2_ibp_rd_chnl         (in_2_out_3_ibp_rd_chnl),

    .ibp_dw32_in_2_ibp_wd_chnl_valid   (in_2_out_3_ibp_wd_chnl_valid),
    .ibp_dw32_in_2_ibp_wd_chnl_accept  (in_2_out_3_ibp_wd_chnl_accept),
    .ibp_dw32_in_2_ibp_wd_chnl         (in_2_out_3_ibp_wd_chnl),

    .ibp_dw32_in_2_ibp_wrsp_chnl_valid (in_2_out_3_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_2_ibp_wrsp_chnl_accept(in_2_out_3_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_2_ibp_wrsp_chnl       (in_2_out_3_ibp_wrsp_chnl),





    .ibp_dw32_in_3_ibp_cmd_chnl_valid  (in_3_out_3_ibp_cmd_chnl_valid),
    .ibp_dw32_in_3_ibp_cmd_chnl_accept (in_3_out_3_ibp_cmd_chnl_accept),
    .ibp_dw32_in_3_ibp_cmd_chnl        (in_3_out_3_ibp_cmd_chnl),

    .ibp_dw32_in_3_ibp_rd_chnl_valid   (in_3_out_3_ibp_rd_chnl_valid),
    .ibp_dw32_in_3_ibp_rd_chnl_accept  (in_3_out_3_ibp_rd_chnl_accept),
    .ibp_dw32_in_3_ibp_rd_chnl         (in_3_out_3_ibp_rd_chnl),

    .ibp_dw32_in_3_ibp_wd_chnl_valid   (in_3_out_3_ibp_wd_chnl_valid),
    .ibp_dw32_in_3_ibp_wd_chnl_accept  (in_3_out_3_ibp_wd_chnl_accept),
    .ibp_dw32_in_3_ibp_wd_chnl         (in_3_out_3_ibp_wd_chnl),

    .ibp_dw32_in_3_ibp_wrsp_chnl_valid (in_3_out_3_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_3_ibp_wrsp_chnl_accept(in_3_out_3_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_3_ibp_wrsp_chnl       (in_3_out_3_ibp_wrsp_chnl),



  .ibp_dw32_out_ibp_cmd_valid             (mss_clkctrl_bs_ibp_cmd_valid),
  .ibp_dw32_out_ibp_cmd_accept            (mss_clkctrl_bs_ibp_cmd_accept),
  .ibp_dw32_out_ibp_cmd_read              (mss_clkctrl_bs_ibp_cmd_read),
  .ibp_dw32_out_ibp_cmd_addr              (mss_clkctrl_bs_ibp_cmd_addr),
  .ibp_dw32_out_ibp_cmd_wrap              (mss_clkctrl_bs_ibp_cmd_wrap),
  .ibp_dw32_out_ibp_cmd_data_size         (mss_clkctrl_bs_ibp_cmd_data_size),
  .ibp_dw32_out_ibp_cmd_burst_size        (mss_clkctrl_bs_ibp_cmd_burst_size),
  .ibp_dw32_out_ibp_cmd_prot              (mss_clkctrl_bs_ibp_cmd_prot),
  .ibp_dw32_out_ibp_cmd_cache             (mss_clkctrl_bs_ibp_cmd_cache),
  .ibp_dw32_out_ibp_cmd_lock              (mss_clkctrl_bs_ibp_cmd_lock),
  .ibp_dw32_out_ibp_cmd_excl              (mss_clkctrl_bs_ibp_cmd_excl),

  .ibp_dw32_out_ibp_rd_valid              (mss_clkctrl_bs_ibp_rd_valid),
  .ibp_dw32_out_ibp_rd_excl_ok            (mss_clkctrl_bs_ibp_rd_excl_ok),
  .ibp_dw32_out_ibp_rd_accept             (mss_clkctrl_bs_ibp_rd_accept),
  .ibp_dw32_out_ibp_err_rd                (mss_clkctrl_bs_ibp_err_rd),
  .ibp_dw32_out_ibp_rd_data               (mss_clkctrl_bs_ibp_rd_data),
  .ibp_dw32_out_ibp_rd_last               (mss_clkctrl_bs_ibp_rd_last),

  .ibp_dw32_out_ibp_wr_valid              (mss_clkctrl_bs_ibp_wr_valid),
  .ibp_dw32_out_ibp_wr_accept             (mss_clkctrl_bs_ibp_wr_accept),
  .ibp_dw32_out_ibp_wr_data               (mss_clkctrl_bs_ibp_wr_data),
  .ibp_dw32_out_ibp_wr_mask               (mss_clkctrl_bs_ibp_wr_mask),
  .ibp_dw32_out_ibp_wr_last               (mss_clkctrl_bs_ibp_wr_last),

  .ibp_dw32_out_ibp_wr_done               (mss_clkctrl_bs_ibp_wr_done),
  .ibp_dw32_out_ibp_wr_excl_done          (mss_clkctrl_bs_ibp_wr_excl_done),
  .ibp_dw32_out_ibp_err_wr                (mss_clkctrl_bs_ibp_err_wr),
  .ibp_dw32_out_ibp_wr_resp_accept        (mss_clkctrl_bs_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);
mss_bus_switch_ibp_dw32_mst u_mss_bs_mst_4 (



    .ibp_dw32_in_0_ibp_cmd_chnl_valid  (in_0_out_4_ibp_cmd_chnl_valid),
    .ibp_dw32_in_0_ibp_cmd_chnl_accept (in_0_out_4_ibp_cmd_chnl_accept),
    .ibp_dw32_in_0_ibp_cmd_chnl        (in_0_out_4_ibp_cmd_chnl),

    .ibp_dw32_in_0_ibp_rd_chnl_valid   (in_0_out_4_ibp_rd_chnl_valid),
    .ibp_dw32_in_0_ibp_rd_chnl_accept  (in_0_out_4_ibp_rd_chnl_accept),
    .ibp_dw32_in_0_ibp_rd_chnl         (in_0_out_4_ibp_rd_chnl),

    .ibp_dw32_in_0_ibp_wd_chnl_valid   (in_0_out_4_ibp_wd_chnl_valid),
    .ibp_dw32_in_0_ibp_wd_chnl_accept  (in_0_out_4_ibp_wd_chnl_accept),
    .ibp_dw32_in_0_ibp_wd_chnl         (in_0_out_4_ibp_wd_chnl),

    .ibp_dw32_in_0_ibp_wrsp_chnl_valid (in_0_out_4_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_0_ibp_wrsp_chnl_accept(in_0_out_4_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_0_ibp_wrsp_chnl       (in_0_out_4_ibp_wrsp_chnl),





    .ibp_dw32_in_1_ibp_cmd_chnl_valid  (in_1_out_4_ibp_cmd_chnl_valid),
    .ibp_dw32_in_1_ibp_cmd_chnl_accept (in_1_out_4_ibp_cmd_chnl_accept),
    .ibp_dw32_in_1_ibp_cmd_chnl        (in_1_out_4_ibp_cmd_chnl),

    .ibp_dw32_in_1_ibp_rd_chnl_valid   (in_1_out_4_ibp_rd_chnl_valid),
    .ibp_dw32_in_1_ibp_rd_chnl_accept  (in_1_out_4_ibp_rd_chnl_accept),
    .ibp_dw32_in_1_ibp_rd_chnl         (in_1_out_4_ibp_rd_chnl),

    .ibp_dw32_in_1_ibp_wd_chnl_valid   (in_1_out_4_ibp_wd_chnl_valid),
    .ibp_dw32_in_1_ibp_wd_chnl_accept  (in_1_out_4_ibp_wd_chnl_accept),
    .ibp_dw32_in_1_ibp_wd_chnl         (in_1_out_4_ibp_wd_chnl),

    .ibp_dw32_in_1_ibp_wrsp_chnl_valid (in_1_out_4_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_1_ibp_wrsp_chnl_accept(in_1_out_4_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_1_ibp_wrsp_chnl       (in_1_out_4_ibp_wrsp_chnl),





    .ibp_dw32_in_2_ibp_cmd_chnl_valid  (in_2_out_4_ibp_cmd_chnl_valid),
    .ibp_dw32_in_2_ibp_cmd_chnl_accept (in_2_out_4_ibp_cmd_chnl_accept),
    .ibp_dw32_in_2_ibp_cmd_chnl        (in_2_out_4_ibp_cmd_chnl),

    .ibp_dw32_in_2_ibp_rd_chnl_valid   (in_2_out_4_ibp_rd_chnl_valid),
    .ibp_dw32_in_2_ibp_rd_chnl_accept  (in_2_out_4_ibp_rd_chnl_accept),
    .ibp_dw32_in_2_ibp_rd_chnl         (in_2_out_4_ibp_rd_chnl),

    .ibp_dw32_in_2_ibp_wd_chnl_valid   (in_2_out_4_ibp_wd_chnl_valid),
    .ibp_dw32_in_2_ibp_wd_chnl_accept  (in_2_out_4_ibp_wd_chnl_accept),
    .ibp_dw32_in_2_ibp_wd_chnl         (in_2_out_4_ibp_wd_chnl),

    .ibp_dw32_in_2_ibp_wrsp_chnl_valid (in_2_out_4_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_2_ibp_wrsp_chnl_accept(in_2_out_4_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_2_ibp_wrsp_chnl       (in_2_out_4_ibp_wrsp_chnl),





    .ibp_dw32_in_3_ibp_cmd_chnl_valid  (in_3_out_4_ibp_cmd_chnl_valid),
    .ibp_dw32_in_3_ibp_cmd_chnl_accept (in_3_out_4_ibp_cmd_chnl_accept),
    .ibp_dw32_in_3_ibp_cmd_chnl        (in_3_out_4_ibp_cmd_chnl),

    .ibp_dw32_in_3_ibp_rd_chnl_valid   (in_3_out_4_ibp_rd_chnl_valid),
    .ibp_dw32_in_3_ibp_rd_chnl_accept  (in_3_out_4_ibp_rd_chnl_accept),
    .ibp_dw32_in_3_ibp_rd_chnl         (in_3_out_4_ibp_rd_chnl),

    .ibp_dw32_in_3_ibp_wd_chnl_valid   (in_3_out_4_ibp_wd_chnl_valid),
    .ibp_dw32_in_3_ibp_wd_chnl_accept  (in_3_out_4_ibp_wd_chnl_accept),
    .ibp_dw32_in_3_ibp_wd_chnl         (in_3_out_4_ibp_wd_chnl),

    .ibp_dw32_in_3_ibp_wrsp_chnl_valid (in_3_out_4_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_3_ibp_wrsp_chnl_accept(in_3_out_4_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_3_ibp_wrsp_chnl       (in_3_out_4_ibp_wrsp_chnl),



  .ibp_dw32_out_ibp_cmd_valid             (mss_perfctrl_bs_ibp_cmd_valid),
  .ibp_dw32_out_ibp_cmd_accept            (mss_perfctrl_bs_ibp_cmd_accept),
  .ibp_dw32_out_ibp_cmd_read              (mss_perfctrl_bs_ibp_cmd_read),
  .ibp_dw32_out_ibp_cmd_addr              (mss_perfctrl_bs_ibp_cmd_addr),
  .ibp_dw32_out_ibp_cmd_wrap              (mss_perfctrl_bs_ibp_cmd_wrap),
  .ibp_dw32_out_ibp_cmd_data_size         (mss_perfctrl_bs_ibp_cmd_data_size),
  .ibp_dw32_out_ibp_cmd_burst_size        (mss_perfctrl_bs_ibp_cmd_burst_size),
  .ibp_dw32_out_ibp_cmd_prot              (mss_perfctrl_bs_ibp_cmd_prot),
  .ibp_dw32_out_ibp_cmd_cache             (mss_perfctrl_bs_ibp_cmd_cache),
  .ibp_dw32_out_ibp_cmd_lock              (mss_perfctrl_bs_ibp_cmd_lock),
  .ibp_dw32_out_ibp_cmd_excl              (mss_perfctrl_bs_ibp_cmd_excl),

  .ibp_dw32_out_ibp_rd_valid              (mss_perfctrl_bs_ibp_rd_valid),
  .ibp_dw32_out_ibp_rd_excl_ok            (mss_perfctrl_bs_ibp_rd_excl_ok),
  .ibp_dw32_out_ibp_rd_accept             (mss_perfctrl_bs_ibp_rd_accept),
  .ibp_dw32_out_ibp_err_rd                (mss_perfctrl_bs_ibp_err_rd),
  .ibp_dw32_out_ibp_rd_data               (mss_perfctrl_bs_ibp_rd_data),
  .ibp_dw32_out_ibp_rd_last               (mss_perfctrl_bs_ibp_rd_last),

  .ibp_dw32_out_ibp_wr_valid              (mss_perfctrl_bs_ibp_wr_valid),
  .ibp_dw32_out_ibp_wr_accept             (mss_perfctrl_bs_ibp_wr_accept),
  .ibp_dw32_out_ibp_wr_data               (mss_perfctrl_bs_ibp_wr_data),
  .ibp_dw32_out_ibp_wr_mask               (mss_perfctrl_bs_ibp_wr_mask),
  .ibp_dw32_out_ibp_wr_last               (mss_perfctrl_bs_ibp_wr_last),

  .ibp_dw32_out_ibp_wr_done               (mss_perfctrl_bs_ibp_wr_done),
  .ibp_dw32_out_ibp_wr_excl_done          (mss_perfctrl_bs_ibp_wr_excl_done),
  .ibp_dw32_out_ibp_err_wr                (mss_perfctrl_bs_ibp_err_wr),
  .ibp_dw32_out_ibp_wr_resp_accept        (mss_perfctrl_bs_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);
mss_bus_switch_ibp_dw128_mst u_mss_bs_mst_5 (



    .ibp_dw128_in_0_ibp_cmd_chnl_valid  (in_0_out_5_ibp_cmd_chnl_valid),
    .ibp_dw128_in_0_ibp_cmd_chnl_accept (in_0_out_5_ibp_cmd_chnl_accept),
    .ibp_dw128_in_0_ibp_cmd_chnl        (in_0_out_5_ibp_cmd_chnl),

    .ibp_dw128_in_0_ibp_rd_chnl_valid   (in_0_out_5_ibp_rd_chnl_valid),
    .ibp_dw128_in_0_ibp_rd_chnl_accept  (in_0_out_5_ibp_rd_chnl_accept),
    .ibp_dw128_in_0_ibp_rd_chnl         (in_0_out_5_ibp_rd_chnl),

    .ibp_dw128_in_0_ibp_wd_chnl_valid   (in_0_out_5_ibp_wd_chnl_valid),
    .ibp_dw128_in_0_ibp_wd_chnl_accept  (in_0_out_5_ibp_wd_chnl_accept),
    .ibp_dw128_in_0_ibp_wd_chnl         (in_0_out_5_ibp_wd_chnl),

    .ibp_dw128_in_0_ibp_wrsp_chnl_valid (in_0_out_5_ibp_wrsp_chnl_valid),
    .ibp_dw128_in_0_ibp_wrsp_chnl_accept(in_0_out_5_ibp_wrsp_chnl_accept),
    .ibp_dw128_in_0_ibp_wrsp_chnl       (in_0_out_5_ibp_wrsp_chnl),





    .ibp_dw128_in_1_ibp_cmd_chnl_valid  (in_1_out_5_ibp_cmd_chnl_valid),
    .ibp_dw128_in_1_ibp_cmd_chnl_accept (in_1_out_5_ibp_cmd_chnl_accept),
    .ibp_dw128_in_1_ibp_cmd_chnl        (in_1_out_5_ibp_cmd_chnl),

    .ibp_dw128_in_1_ibp_rd_chnl_valid   (in_1_out_5_ibp_rd_chnl_valid),
    .ibp_dw128_in_1_ibp_rd_chnl_accept  (in_1_out_5_ibp_rd_chnl_accept),
    .ibp_dw128_in_1_ibp_rd_chnl         (in_1_out_5_ibp_rd_chnl),

    .ibp_dw128_in_1_ibp_wd_chnl_valid   (in_1_out_5_ibp_wd_chnl_valid),
    .ibp_dw128_in_1_ibp_wd_chnl_accept  (in_1_out_5_ibp_wd_chnl_accept),
    .ibp_dw128_in_1_ibp_wd_chnl         (in_1_out_5_ibp_wd_chnl),

    .ibp_dw128_in_1_ibp_wrsp_chnl_valid (in_1_out_5_ibp_wrsp_chnl_valid),
    .ibp_dw128_in_1_ibp_wrsp_chnl_accept(in_1_out_5_ibp_wrsp_chnl_accept),
    .ibp_dw128_in_1_ibp_wrsp_chnl       (in_1_out_5_ibp_wrsp_chnl),





    .ibp_dw128_in_2_ibp_cmd_chnl_valid  (in_2_out_5_ibp_cmd_chnl_valid),
    .ibp_dw128_in_2_ibp_cmd_chnl_accept (in_2_out_5_ibp_cmd_chnl_accept),
    .ibp_dw128_in_2_ibp_cmd_chnl        (in_2_out_5_ibp_cmd_chnl),

    .ibp_dw128_in_2_ibp_rd_chnl_valid   (in_2_out_5_ibp_rd_chnl_valid),
    .ibp_dw128_in_2_ibp_rd_chnl_accept  (in_2_out_5_ibp_rd_chnl_accept),
    .ibp_dw128_in_2_ibp_rd_chnl         (in_2_out_5_ibp_rd_chnl),

    .ibp_dw128_in_2_ibp_wd_chnl_valid   (in_2_out_5_ibp_wd_chnl_valid),
    .ibp_dw128_in_2_ibp_wd_chnl_accept  (in_2_out_5_ibp_wd_chnl_accept),
    .ibp_dw128_in_2_ibp_wd_chnl         (in_2_out_5_ibp_wd_chnl),

    .ibp_dw128_in_2_ibp_wrsp_chnl_valid (in_2_out_5_ibp_wrsp_chnl_valid),
    .ibp_dw128_in_2_ibp_wrsp_chnl_accept(in_2_out_5_ibp_wrsp_chnl_accept),
    .ibp_dw128_in_2_ibp_wrsp_chnl       (in_2_out_5_ibp_wrsp_chnl),





    .ibp_dw128_in_3_ibp_cmd_chnl_valid  (in_3_out_5_ibp_cmd_chnl_valid),
    .ibp_dw128_in_3_ibp_cmd_chnl_accept (in_3_out_5_ibp_cmd_chnl_accept),
    .ibp_dw128_in_3_ibp_cmd_chnl        (in_3_out_5_ibp_cmd_chnl),

    .ibp_dw128_in_3_ibp_rd_chnl_valid   (in_3_out_5_ibp_rd_chnl_valid),
    .ibp_dw128_in_3_ibp_rd_chnl_accept  (in_3_out_5_ibp_rd_chnl_accept),
    .ibp_dw128_in_3_ibp_rd_chnl         (in_3_out_5_ibp_rd_chnl),

    .ibp_dw128_in_3_ibp_wd_chnl_valid   (in_3_out_5_ibp_wd_chnl_valid),
    .ibp_dw128_in_3_ibp_wd_chnl_accept  (in_3_out_5_ibp_wd_chnl_accept),
    .ibp_dw128_in_3_ibp_wd_chnl         (in_3_out_5_ibp_wd_chnl),

    .ibp_dw128_in_3_ibp_wrsp_chnl_valid (in_3_out_5_ibp_wrsp_chnl_valid),
    .ibp_dw128_in_3_ibp_wrsp_chnl_accept(in_3_out_5_ibp_wrsp_chnl_accept),
    .ibp_dw128_in_3_ibp_wrsp_chnl       (in_3_out_5_ibp_wrsp_chnl),



  .ibp_dw128_out_ibp_cmd_valid             (mss_mem_bs_ibp_cmd_valid),
  .ibp_dw128_out_ibp_cmd_accept            (mss_mem_bs_ibp_cmd_accept),
  .ibp_dw128_out_ibp_cmd_read              (mss_mem_bs_ibp_cmd_read),
  .ibp_dw128_out_ibp_cmd_addr              (mss_mem_bs_ibp_cmd_addr),
  .ibp_dw128_out_ibp_cmd_wrap              (mss_mem_bs_ibp_cmd_wrap),
  .ibp_dw128_out_ibp_cmd_data_size         (mss_mem_bs_ibp_cmd_data_size),
  .ibp_dw128_out_ibp_cmd_burst_size        (mss_mem_bs_ibp_cmd_burst_size),
  .ibp_dw128_out_ibp_cmd_prot              (mss_mem_bs_ibp_cmd_prot),
  .ibp_dw128_out_ibp_cmd_cache             (mss_mem_bs_ibp_cmd_cache),
  .ibp_dw128_out_ibp_cmd_lock              (mss_mem_bs_ibp_cmd_lock),
  .ibp_dw128_out_ibp_cmd_excl              (mss_mem_bs_ibp_cmd_excl),

  .ibp_dw128_out_ibp_rd_valid              (mss_mem_bs_ibp_rd_valid),
  .ibp_dw128_out_ibp_rd_excl_ok            (mss_mem_bs_ibp_rd_excl_ok),
  .ibp_dw128_out_ibp_rd_accept             (mss_mem_bs_ibp_rd_accept),
  .ibp_dw128_out_ibp_err_rd                (mss_mem_bs_ibp_err_rd),
  .ibp_dw128_out_ibp_rd_data               (mss_mem_bs_ibp_rd_data),
  .ibp_dw128_out_ibp_rd_last               (mss_mem_bs_ibp_rd_last),

  .ibp_dw128_out_ibp_wr_valid              (mss_mem_bs_ibp_wr_valid),
  .ibp_dw128_out_ibp_wr_accept             (mss_mem_bs_ibp_wr_accept),
  .ibp_dw128_out_ibp_wr_data               (mss_mem_bs_ibp_wr_data),
  .ibp_dw128_out_ibp_wr_mask               (mss_mem_bs_ibp_wr_mask),
  .ibp_dw128_out_ibp_wr_last               (mss_mem_bs_ibp_wr_last),

  .ibp_dw128_out_ibp_wr_done               (mss_mem_bs_ibp_wr_done),
  .ibp_dw128_out_ibp_wr_excl_done          (mss_mem_bs_ibp_wr_excl_done),
  .ibp_dw128_out_ibp_err_wr                (mss_mem_bs_ibp_err_wr),
  .ibp_dw128_out_ibp_wr_resp_accept        (mss_mem_bs_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);

//
// default slave
//

  wire                                  bus_switch_def_slv_ibp_cmd_valid;
  wire                                  bus_switch_def_slv_ibp_cmd_accept;
  wire                                  bus_switch_def_slv_ibp_cmd_read;
  wire  [42                -1:0]       bus_switch_def_slv_ibp_cmd_addr;
  wire                                  bus_switch_def_slv_ibp_cmd_wrap;
  wire  [3-1:0]       bus_switch_def_slv_ibp_cmd_data_size;
  wire  [4-1:0]       bus_switch_def_slv_ibp_cmd_burst_size;
  wire  [2-1:0]       bus_switch_def_slv_ibp_cmd_prot;
  wire  [4-1:0]       bus_switch_def_slv_ibp_cmd_cache;
  wire                                  bus_switch_def_slv_ibp_cmd_lock;
  wire                                  bus_switch_def_slv_ibp_cmd_excl;

  wire                                  bus_switch_def_slv_ibp_rd_valid;
  wire                                  bus_switch_def_slv_ibp_rd_excl_ok;
  wire                                  bus_switch_def_slv_ibp_rd_accept;
  wire                                  bus_switch_def_slv_ibp_err_rd;
  wire  [32               -1:0]        bus_switch_def_slv_ibp_rd_data;
  wire                                  bus_switch_def_slv_ibp_rd_last;

  wire                                  bus_switch_def_slv_ibp_wr_valid;
  wire                                  bus_switch_def_slv_ibp_wr_accept;
  wire  [32               -1:0]        bus_switch_def_slv_ibp_wr_data;
  wire  [(32         /8)  -1:0]        bus_switch_def_slv_ibp_wr_mask;
  wire                                  bus_switch_def_slv_ibp_wr_last;

  wire                                  bus_switch_def_slv_ibp_wr_done;
  wire                                  bus_switch_def_slv_ibp_wr_excl_done;
  wire                                  bus_switch_def_slv_ibp_err_wr;
  wire                                  bus_switch_def_slv_ibp_wr_resp_accept;


mss_bus_switch_ibp_dw32_mst u_mss_bs_mst_6 (



    .ibp_dw32_in_0_ibp_cmd_chnl_valid  (in_0_out_6_ibp_cmd_chnl_valid),
    .ibp_dw32_in_0_ibp_cmd_chnl_accept (in_0_out_6_ibp_cmd_chnl_accept),
    .ibp_dw32_in_0_ibp_cmd_chnl        (in_0_out_6_ibp_cmd_chnl),

    .ibp_dw32_in_0_ibp_rd_chnl_valid   (in_0_out_6_ibp_rd_chnl_valid),
    .ibp_dw32_in_0_ibp_rd_chnl_accept  (in_0_out_6_ibp_rd_chnl_accept),
    .ibp_dw32_in_0_ibp_rd_chnl         (in_0_out_6_ibp_rd_chnl),

    .ibp_dw32_in_0_ibp_wd_chnl_valid   (in_0_out_6_ibp_wd_chnl_valid),
    .ibp_dw32_in_0_ibp_wd_chnl_accept  (in_0_out_6_ibp_wd_chnl_accept),
    .ibp_dw32_in_0_ibp_wd_chnl         (in_0_out_6_ibp_wd_chnl),

    .ibp_dw32_in_0_ibp_wrsp_chnl_valid (in_0_out_6_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_0_ibp_wrsp_chnl_accept(in_0_out_6_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_0_ibp_wrsp_chnl       (in_0_out_6_ibp_wrsp_chnl),





    .ibp_dw32_in_1_ibp_cmd_chnl_valid  (in_1_out_6_ibp_cmd_chnl_valid),
    .ibp_dw32_in_1_ibp_cmd_chnl_accept (in_1_out_6_ibp_cmd_chnl_accept),
    .ibp_dw32_in_1_ibp_cmd_chnl        (in_1_out_6_ibp_cmd_chnl),

    .ibp_dw32_in_1_ibp_rd_chnl_valid   (in_1_out_6_ibp_rd_chnl_valid),
    .ibp_dw32_in_1_ibp_rd_chnl_accept  (in_1_out_6_ibp_rd_chnl_accept),
    .ibp_dw32_in_1_ibp_rd_chnl         (in_1_out_6_ibp_rd_chnl),

    .ibp_dw32_in_1_ibp_wd_chnl_valid   (in_1_out_6_ibp_wd_chnl_valid),
    .ibp_dw32_in_1_ibp_wd_chnl_accept  (in_1_out_6_ibp_wd_chnl_accept),
    .ibp_dw32_in_1_ibp_wd_chnl         (in_1_out_6_ibp_wd_chnl),

    .ibp_dw32_in_1_ibp_wrsp_chnl_valid (in_1_out_6_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_1_ibp_wrsp_chnl_accept(in_1_out_6_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_1_ibp_wrsp_chnl       (in_1_out_6_ibp_wrsp_chnl),





    .ibp_dw32_in_2_ibp_cmd_chnl_valid  (in_2_out_6_ibp_cmd_chnl_valid),
    .ibp_dw32_in_2_ibp_cmd_chnl_accept (in_2_out_6_ibp_cmd_chnl_accept),
    .ibp_dw32_in_2_ibp_cmd_chnl        (in_2_out_6_ibp_cmd_chnl),

    .ibp_dw32_in_2_ibp_rd_chnl_valid   (in_2_out_6_ibp_rd_chnl_valid),
    .ibp_dw32_in_2_ibp_rd_chnl_accept  (in_2_out_6_ibp_rd_chnl_accept),
    .ibp_dw32_in_2_ibp_rd_chnl         (in_2_out_6_ibp_rd_chnl),

    .ibp_dw32_in_2_ibp_wd_chnl_valid   (in_2_out_6_ibp_wd_chnl_valid),
    .ibp_dw32_in_2_ibp_wd_chnl_accept  (in_2_out_6_ibp_wd_chnl_accept),
    .ibp_dw32_in_2_ibp_wd_chnl         (in_2_out_6_ibp_wd_chnl),

    .ibp_dw32_in_2_ibp_wrsp_chnl_valid (in_2_out_6_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_2_ibp_wrsp_chnl_accept(in_2_out_6_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_2_ibp_wrsp_chnl       (in_2_out_6_ibp_wrsp_chnl),





    .ibp_dw32_in_3_ibp_cmd_chnl_valid  (in_3_out_6_ibp_cmd_chnl_valid),
    .ibp_dw32_in_3_ibp_cmd_chnl_accept (in_3_out_6_ibp_cmd_chnl_accept),
    .ibp_dw32_in_3_ibp_cmd_chnl        (in_3_out_6_ibp_cmd_chnl),

    .ibp_dw32_in_3_ibp_rd_chnl_valid   (in_3_out_6_ibp_rd_chnl_valid),
    .ibp_dw32_in_3_ibp_rd_chnl_accept  (in_3_out_6_ibp_rd_chnl_accept),
    .ibp_dw32_in_3_ibp_rd_chnl         (in_3_out_6_ibp_rd_chnl),

    .ibp_dw32_in_3_ibp_wd_chnl_valid   (in_3_out_6_ibp_wd_chnl_valid),
    .ibp_dw32_in_3_ibp_wd_chnl_accept  (in_3_out_6_ibp_wd_chnl_accept),
    .ibp_dw32_in_3_ibp_wd_chnl         (in_3_out_6_ibp_wd_chnl),

    .ibp_dw32_in_3_ibp_wrsp_chnl_valid (in_3_out_6_ibp_wrsp_chnl_valid),
    .ibp_dw32_in_3_ibp_wrsp_chnl_accept(in_3_out_6_ibp_wrsp_chnl_accept),
    .ibp_dw32_in_3_ibp_wrsp_chnl       (in_3_out_6_ibp_wrsp_chnl),



  .ibp_dw32_out_ibp_cmd_valid             (bus_switch_def_slv_ibp_cmd_valid),
  .ibp_dw32_out_ibp_cmd_accept            (bus_switch_def_slv_ibp_cmd_accept),
  .ibp_dw32_out_ibp_cmd_read              (bus_switch_def_slv_ibp_cmd_read),
  .ibp_dw32_out_ibp_cmd_addr              (bus_switch_def_slv_ibp_cmd_addr),
  .ibp_dw32_out_ibp_cmd_wrap              (bus_switch_def_slv_ibp_cmd_wrap),
  .ibp_dw32_out_ibp_cmd_data_size         (bus_switch_def_slv_ibp_cmd_data_size),
  .ibp_dw32_out_ibp_cmd_burst_size        (bus_switch_def_slv_ibp_cmd_burst_size),
  .ibp_dw32_out_ibp_cmd_prot              (bus_switch_def_slv_ibp_cmd_prot),
  .ibp_dw32_out_ibp_cmd_cache             (bus_switch_def_slv_ibp_cmd_cache),
  .ibp_dw32_out_ibp_cmd_lock              (bus_switch_def_slv_ibp_cmd_lock),
  .ibp_dw32_out_ibp_cmd_excl              (bus_switch_def_slv_ibp_cmd_excl),

  .ibp_dw32_out_ibp_rd_valid              (bus_switch_def_slv_ibp_rd_valid),
  .ibp_dw32_out_ibp_rd_excl_ok            (bus_switch_def_slv_ibp_rd_excl_ok),
  .ibp_dw32_out_ibp_rd_accept             (bus_switch_def_slv_ibp_rd_accept),
  .ibp_dw32_out_ibp_err_rd                (bus_switch_def_slv_ibp_err_rd),
  .ibp_dw32_out_ibp_rd_data               (bus_switch_def_slv_ibp_rd_data),
  .ibp_dw32_out_ibp_rd_last               (bus_switch_def_slv_ibp_rd_last),

  .ibp_dw32_out_ibp_wr_valid              (bus_switch_def_slv_ibp_wr_valid),
  .ibp_dw32_out_ibp_wr_accept             (bus_switch_def_slv_ibp_wr_accept),
  .ibp_dw32_out_ibp_wr_data               (bus_switch_def_slv_ibp_wr_data),
  .ibp_dw32_out_ibp_wr_mask               (bus_switch_def_slv_ibp_wr_mask),
  .ibp_dw32_out_ibp_wr_last               (bus_switch_def_slv_ibp_wr_last),

  .ibp_dw32_out_ibp_wr_done               (bus_switch_def_slv_ibp_wr_done),
  .ibp_dw32_out_ibp_wr_excl_done          (bus_switch_def_slv_ibp_wr_excl_done),
  .ibp_dw32_out_ibp_err_wr                (bus_switch_def_slv_ibp_err_wr),
  .ibp_dw32_out_ibp_wr_resp_accept        (bus_switch_def_slv_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);


mss_bus_switch_default_slv #(42, 32, `BUS_SWITCH_SLV_HOLE_RESP_ERR) u_default_slv(

  .bus_switch_def_slv_ibp_cmd_valid             (bus_switch_def_slv_ibp_cmd_valid),
  .bus_switch_def_slv_ibp_cmd_accept            (bus_switch_def_slv_ibp_cmd_accept),
  .bus_switch_def_slv_ibp_cmd_read              (bus_switch_def_slv_ibp_cmd_read),
  .bus_switch_def_slv_ibp_cmd_addr              (bus_switch_def_slv_ibp_cmd_addr),
  .bus_switch_def_slv_ibp_cmd_wrap              (bus_switch_def_slv_ibp_cmd_wrap),
  .bus_switch_def_slv_ibp_cmd_data_size         (bus_switch_def_slv_ibp_cmd_data_size),
  .bus_switch_def_slv_ibp_cmd_burst_size        (bus_switch_def_slv_ibp_cmd_burst_size),
  .bus_switch_def_slv_ibp_cmd_prot              (bus_switch_def_slv_ibp_cmd_prot),
  .bus_switch_def_slv_ibp_cmd_cache             (bus_switch_def_slv_ibp_cmd_cache),
  .bus_switch_def_slv_ibp_cmd_lock              (bus_switch_def_slv_ibp_cmd_lock),
  .bus_switch_def_slv_ibp_cmd_excl              (bus_switch_def_slv_ibp_cmd_excl),

  .bus_switch_def_slv_ibp_rd_valid              (bus_switch_def_slv_ibp_rd_valid),
  .bus_switch_def_slv_ibp_rd_excl_ok            (bus_switch_def_slv_ibp_rd_excl_ok),
  .bus_switch_def_slv_ibp_rd_accept             (bus_switch_def_slv_ibp_rd_accept),
  .bus_switch_def_slv_ibp_err_rd                (bus_switch_def_slv_ibp_err_rd),
  .bus_switch_def_slv_ibp_rd_data               (bus_switch_def_slv_ibp_rd_data),
  .bus_switch_def_slv_ibp_rd_last               (bus_switch_def_slv_ibp_rd_last),

  .bus_switch_def_slv_ibp_wr_valid              (bus_switch_def_slv_ibp_wr_valid),
  .bus_switch_def_slv_ibp_wr_accept             (bus_switch_def_slv_ibp_wr_accept),
  .bus_switch_def_slv_ibp_wr_data               (bus_switch_def_slv_ibp_wr_data),
  .bus_switch_def_slv_ibp_wr_mask               (bus_switch_def_slv_ibp_wr_mask),
  .bus_switch_def_slv_ibp_wr_last               (bus_switch_def_slv_ibp_wr_last),

  .bus_switch_def_slv_ibp_wr_done               (bus_switch_def_slv_ibp_wr_done),
  .bus_switch_def_slv_ibp_wr_excl_done          (bus_switch_def_slv_ibp_wr_excl_done),
  .bus_switch_def_slv_ibp_err_wr                (bus_switch_def_slv_ibp_err_wr),
  .bus_switch_def_slv_ibp_wr_resp_accept        (bus_switch_def_slv_ibp_wr_resp_accept),
.clk         (clk),
.rst_a       (rst_a)
);






assign ahb_hbs_ibp_cmd_rgon =
                                0 ? (1 << `BUS_SWITCH_SLV_NUM) :
                                addr_in_rgn(262144, 262271, ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 0) :
                                addr_in_rgn(262400, 262655, ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 1) :
                                addr_in_rgn(262656, 262911, ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 2) :
                                addr_in_rgn(786432, 786432, ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 3) :
                                addr_in_rgn(786434, 786435, ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 4) :
                                addr_in_rgn(0, 1048575, ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 5) :
                                (1 << `BUS_SWITCH_SLV_NUM);


assign dbu_per_ahb_hbs_ibp_cmd_rgon =
                                0 ? (1 << `BUS_SWITCH_SLV_NUM) :
                                addr_in_rgn(262144, 262271, dbu_per_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 0) :
                                addr_in_rgn(262400, 262655, dbu_per_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 1) :
                                addr_in_rgn(262656, 262911, dbu_per_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 2) :
                                addr_in_rgn(786432, 786432, dbu_per_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 3) :
                                addr_in_rgn(786434, 786435, dbu_per_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 4) :
                                addr_in_rgn(0, 1048575, dbu_per_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 5) :
                                (1 << `BUS_SWITCH_SLV_NUM);


assign bri_bs_ibp_cmd_rgon =
                                0 ? (1 << `BUS_SWITCH_SLV_NUM) :
                                addr_in_rgn(262144, 262271, bri_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 0) :
                                addr_in_rgn(262400, 262655, bri_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 1) :
                                addr_in_rgn(262656, 262911, bri_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 2) :
                                addr_in_rgn(786432, 786432, bri_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 3) :
                                addr_in_rgn(786434, 786435, bri_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 4) :
                                addr_in_rgn(0, 1048575, bri_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 5) :
                                (1 << `BUS_SWITCH_SLV_NUM);


assign xtor_axi_bs_ibp_cmd_rgon =
                                0 ? (1 << `BUS_SWITCH_SLV_NUM) :
                                addr_in_rgn(262144, 262271, xtor_axi_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 0) :
                                addr_in_rgn(262400, 262655, xtor_axi_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 1) :
                                addr_in_rgn(262656, 262911, xtor_axi_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 2) :
                                addr_in_rgn(786432, 786432, xtor_axi_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 3) :
                                addr_in_rgn(786434, 786435, xtor_axi_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 4) :
                                addr_in_rgn(0, 1048575, xtor_axi_bs_ibp_cmd_addr[`BUS_SWITCH_ADDR_RANGE]) ? (1 << 5) :
                                (1 << `BUS_SWITCH_SLV_NUM);


function addr_in_rgn;
input [19 : 0] low_addr, up_addr, addr;
    if((addr >= low_addr) & (addr <= up_addr))
        addr_in_rgn = 1;
    else
        addr_in_rgn = 0;
endfunction
// 4KB aligned





    assign iccm_ahb_hbs_ibp_cmd_region =
                                      ((iccm_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_SLV_RGN_MATCH_RANGE] &  base_size_mask(19)) ==
                                      ((262144) & base_size_mask(19)) ) ? 0 :
                                      0;



    assign dccm_ahb_hbs_ibp_cmd_region =
                                      ((dccm_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_SLV_RGN_MATCH_RANGE] &  base_size_mask(20)) ==
                                      ((262400) & base_size_mask(20)) ) ? 0 :
                                      0;



    assign mmio_ahb_hbs_ibp_cmd_region =
                                      ((mmio_ahb_hbs_ibp_cmd_addr[`BUS_SWITCH_SLV_RGN_MATCH_RANGE] &  base_size_mask(20)) ==
                                      ((262656) & base_size_mask(20)) ) ? 0 :
                                      0;



    assign mss_clkctrl_bs_ibp_cmd_region =
                                      ((mss_clkctrl_bs_ibp_cmd_addr[`BUS_SWITCH_SLV_RGN_MATCH_RANGE] &  base_size_mask(12)) ==
                                      ((786432) & base_size_mask(12)) ) ? 0 :
                                      0;



    assign mss_perfctrl_bs_ibp_cmd_region =
                                      ((mss_perfctrl_bs_ibp_cmd_addr[`BUS_SWITCH_SLV_RGN_MATCH_RANGE] &  base_size_mask(13)) ==
                                      ((786434) & base_size_mask(13)) ) ? 0 :
                                      0;



    assign mss_mem_bs_ibp_cmd_region =
                                      ((mss_mem_bs_ibp_cmd_addr[`BUS_SWITCH_SLV_RGN_MATCH_RANGE] &  base_size_mask(32)) ==
                                      ((0) & base_size_mask(32)) ) ? 0 :
                                      0;



function [`BUS_SWITCH_SLV_RGN_BASE_RANGE] base_size_mask;
input [`BUS_SWITCH_SLV_RGN_SIZE_RANGE] base_size;
begin
    case (base_size -12)
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd0: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd0;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd1: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd1;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd2: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd3;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd3: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd7;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd4: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd15;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd5: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd31;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd6: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd63;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd7: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd127;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd8: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd255;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd9: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd511;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd10: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd1023;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd11: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd2047;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd12: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd4095;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd13: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd8191;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd14: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd16383;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd15: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd32767;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd16: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd65535;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd17: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd131071;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd18: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd262143;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd19: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd524287;
    `BUS_SWITCH_SLV_RGN_SIZE_BITS'd20: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd1048575;
    default: base_size_mask = ~`BUS_SWITCH_SLV_RGN_BASE_BITS'd1048575;
    endcase
end
endfunction

endmodule
