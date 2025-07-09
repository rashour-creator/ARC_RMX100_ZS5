// *SYNOPSYS CONFIDENTIAL*
// 
// This is an unpublished, proprietary work of Synopsys, Inc., and is fully 
// protected under copyright and trade secret laws.  You may not view, use, 
// disclose, copy, or distribute this file or any information contained herein 
// except pursuant to a valid written license from Synopsys.


// This file was automatically generated.
// Includes found in dependent files:
`include "defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"
`include "const.def"

module rl_srams_instances(
    input  esrams_iccm0_clk              //  <   cpu_top_safety_controller
  , input  [`ICCM0_DRAM_RANGE] esrams_iccm0_din //  <   cpu_top_safety_controller
  , input  [`ICCM0_ADR_RANGE] esrams_iccm0_addr //  <   cpu_top_safety_controller
  , input  esrams_iccm0_cs               //  <   cpu_top_safety_controller
  , input  esrams_iccm0_we               //  <   cpu_top_safety_controller
  , input  [`ICCM_MASK_RANGE] esrams_iccm0_wem //  <   cpu_top_safety_controller
  , input  esrams_dccm_even_clk          //  <   cpu_top_safety_controller
  , input  [`DCCM_DRAM_RANGE] esrams_dccm_din_even //  <   cpu_top_safety_controller
  , input  [`DCCM_ADR_RANGE] esrams_dccm_addr_even //  <   cpu_top_safety_controller
  , input  esrams_dccm_cs_even           //  <   cpu_top_safety_controller
  , input  esrams_dccm_we_even           //  <   cpu_top_safety_controller
  , input  [`DCCM_MASK_RANGE] esrams_dccm_wem_even //  <   cpu_top_safety_controller
  , input  esrams_dccm_odd_clk           //  <   cpu_top_safety_controller
  , input  [`DCCM_DRAM_RANGE] esrams_dccm_din_odd //  <   cpu_top_safety_controller
  , input  [`DCCM_ADR_RANGE] esrams_dccm_addr_odd //  <   cpu_top_safety_controller
  , input  esrams_dccm_cs_odd            //  <   cpu_top_safety_controller
  , input  esrams_dccm_we_odd            //  <   cpu_top_safety_controller
  , input  [`DCCM_MASK_RANGE] esrams_dccm_wem_odd //  <   cpu_top_safety_controller
  , input  esrams_ic_tag_mem_clk         //  <   cpu_top_safety_controller
  , input  [`IC_TAG_SET_RANGE] esrams_ic_tag_mem_din //  <   cpu_top_safety_controller
  , input  [`IC_IDX_RANGE] esrams_ic_tag_mem_addr //  <   cpu_top_safety_controller
  , input  esrams_ic_tag_mem_cs          //  <   cpu_top_safety_controller
  , input  esrams_ic_tag_mem_we          //  <   cpu_top_safety_controller
  , input  [`IC_TAG_SET_RANGE] esrams_ic_tag_mem_wem //  <   cpu_top_safety_controller
  , input  esrams_ic_data_mem_clk        //  <   cpu_top_safety_controller
  , input  [`IC_DATA_SET_RANGE] esrams_ic_data_mem_din //  <   cpu_top_safety_controller
  , input  [`IC_DATA_ADR_RANGE] esrams_ic_data_mem_addr //  <   cpu_top_safety_controller
  , input  esrams_ic_data_mem_cs         //  <   cpu_top_safety_controller
  , input  esrams_ic_data_mem_we         //  <   cpu_top_safety_controller
  , input  [`IC_DATA_SET_RANGE] esrams_ic_data_mem_wem //  <   cpu_top_safety_controller
  , input  test_mode                     //  <   io_pad_ring
  , input  esrams_clk                    //  <   cpu_top_safety_controller
  , input  esrams_ls                     //  <   cpu_top_safety_controller
  , output [`ICCM0_DRAM_RANGE] esrams_iccm0_dout //    > cpu_top_safety_controller
  , output [`DCCM_DRAM_RANGE] esrams_dccm_dout_even //    > cpu_top_safety_controller
  , output [`DCCM_DRAM_RANGE] esrams_dccm_dout_odd //    > cpu_top_safety_controller
  , output [`IC_TAG_SET_RANGE] esrams_ic_tag_mem_dout //    > cpu_top_safety_controller
  , output [`IC_DATA_SET_RANGE] esrams_ic_data_mem_dout //    > cpu_top_safety_controller
  );

// Instantiation esrams_rl_srams of module rl_srams
rl_srams iesrams_rl_srams(
    .iccm0_clk               (esrams_iccm0_clk)    // <   cpu_top_safety_controller
  , .iccm0_din               (esrams_iccm0_din)    // <   cpu_top_safety_controller
  , .iccm0_addr              (esrams_iccm0_addr)   // <   cpu_top_safety_controller
  , .iccm0_cs                (esrams_iccm0_cs)     // <   cpu_top_safety_controller
  , .iccm0_we                (esrams_iccm0_we)     // <   cpu_top_safety_controller
  , .iccm0_wem               (esrams_iccm0_wem)    // <   cpu_top_safety_controller
  , .dccm_even_clk           (esrams_dccm_even_clk) // <   cpu_top_safety_controller
  , .dccm_din_even           (esrams_dccm_din_even) // <   cpu_top_safety_controller
  , .dccm_addr_even          (esrams_dccm_addr_even) // <   cpu_top_safety_controller
  , .dccm_cs_even            (esrams_dccm_cs_even) // <   cpu_top_safety_controller
  , .dccm_we_even            (esrams_dccm_we_even) // <   cpu_top_safety_controller
  , .dccm_wem_even           (esrams_dccm_wem_even) // <   cpu_top_safety_controller
  , .dccm_odd_clk            (esrams_dccm_odd_clk) // <   cpu_top_safety_controller
  , .dccm_din_odd            (esrams_dccm_din_odd) // <   cpu_top_safety_controller
  , .dccm_addr_odd           (esrams_dccm_addr_odd) // <   cpu_top_safety_controller
  , .dccm_cs_odd             (esrams_dccm_cs_odd)  // <   cpu_top_safety_controller
  , .dccm_we_odd             (esrams_dccm_we_odd)  // <   cpu_top_safety_controller
  , .dccm_wem_odd            (esrams_dccm_wem_odd) // <   cpu_top_safety_controller
  , .ic_tag_mem_clk          (esrams_ic_tag_mem_clk) // <   cpu_top_safety_controller
  , .ic_tag_mem_din          (esrams_ic_tag_mem_din) // <   cpu_top_safety_controller
  , .ic_tag_mem_addr         (esrams_ic_tag_mem_addr) // <   cpu_top_safety_controller
  , .ic_tag_mem_cs           (esrams_ic_tag_mem_cs) // <   cpu_top_safety_controller
  , .ic_tag_mem_we           (esrams_ic_tag_mem_we) // <   cpu_top_safety_controller
  , .ic_tag_mem_wem          (esrams_ic_tag_mem_wem) // <   cpu_top_safety_controller
  , .ic_data_mem_clk         (esrams_ic_data_mem_clk) // <   cpu_top_safety_controller
  , .ic_data_mem_din         (esrams_ic_data_mem_din) // <   cpu_top_safety_controller
  , .ic_data_mem_addr        (esrams_ic_data_mem_addr) // <   cpu_top_safety_controller
  , .ic_data_mem_cs          (esrams_ic_data_mem_cs) // <   cpu_top_safety_controller
  , .ic_data_mem_we          (esrams_ic_data_mem_we) // <   cpu_top_safety_controller
  , .ic_data_mem_wem         (esrams_ic_data_mem_wem) // <   cpu_top_safety_controller
  , .test_mode               (test_mode)           // <   io_pad_ring
  , .clk                     (esrams_clk)          // <   cpu_top_safety_controller
  , .ls                      (esrams_ls)           // <   cpu_top_safety_controller
  , .iccm0_dout              (esrams_iccm0_dout)   //   > cpu_top_safety_controller
  , .dccm_dout_even          (esrams_dccm_dout_even) //   > cpu_top_safety_controller
  , .dccm_dout_odd           (esrams_dccm_dout_odd) //   > cpu_top_safety_controller
  , .ic_tag_mem_dout         (esrams_ic_tag_mem_dout) //   > cpu_top_safety_controller
  , .ic_data_mem_dout        (esrams_ic_data_mem_dout) //   > cpu_top_safety_controller
  );
endmodule
