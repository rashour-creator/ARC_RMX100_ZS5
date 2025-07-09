// Library ARCv2MSS-2.1.999999999
// Clock control registers
`define MSS_CLKCTRL_CFG_CTRL_ADDR             0xc0000000
// clock divider registers
`define MSS_CLKCTRL_CLK_DIV_ADDR       0xc0000004
`define MSS_CLKCTRL_WDT_CLK_DIV_ADDR       0xc0000008
`define MSS_CLKCTRL_MSS_CLK_DIV_ADDR       0xc000000c
// clock enable ratio and status registers
// iccm_ahb_clk_en: clk <-> mss_clk; design rule: none (clk freq vs. mss_clk freq)
`define MSS_CLKCTRL_ICCM_AHB_CLK_EN_RATIO_ADDR     0xc0000010
`define MSS_CLKCTRL_ICCM_AHB_CLK_EN_STAT_ADDR      0xc0000014
// dccm_ahb_clk_en: clk <-> mss_clk; design rule: none (clk freq vs. mss_clk freq)
`define MSS_CLKCTRL_DCCM_AHB_CLK_EN_RATIO_ADDR     0xc0000018
`define MSS_CLKCTRL_DCCM_AHB_CLK_EN_STAT_ADDR      0xc000001c
// mmio_ahb_clk_en: clk <-> mss_clk; design rule: none (clk freq vs. mss_clk freq)
`define MSS_CLKCTRL_MMIO_AHB_CLK_EN_RATIO_ADDR     0xc0000020
`define MSS_CLKCTRL_MMIO_AHB_CLK_EN_STAT_ADDR      0xc0000024
// mss_fab_mst0_clk_en: mss_clk <-> clk; design rule: none (mss_clk freq vs. clk freq)
`define MSS_CLKCTRL_MSS_FAB_MST0_CLK_EN_RATIO_ADDR     0xc0000028
`define MSS_CLKCTRL_MSS_FAB_MST0_CLK_EN_STAT_ADDR      0xc000002c
// mss_fab_mst1_clk_en: mss_clk <-> clk; design rule: none (mss_clk freq vs. clk freq)
`define MSS_CLKCTRL_MSS_FAB_MST1_CLK_EN_RATIO_ADDR     0xc0000030
`define MSS_CLKCTRL_MSS_FAB_MST1_CLK_EN_STAT_ADDR      0xc0000034
// mss_fab_mst2_clk_en: mss_clk <-> clk; design rule: none (mss_clk freq vs. clk freq)
`define MSS_CLKCTRL_MSS_FAB_MST2_CLK_EN_RATIO_ADDR     0xc0000038
`define MSS_CLKCTRL_MSS_FAB_MST2_CLK_EN_STAT_ADDR      0xc000003c
// mss_fab_mst3_clk_en: mss_clk <-> mss_clk; design rule: none (mss_clk freq vs. mss_clk freq)
`define MSS_CLKCTRL_MSS_FAB_MST3_CLK_EN_RATIO_ADDR     0xc0000040
`define MSS_CLKCTRL_MSS_FAB_MST3_CLK_EN_STAT_ADDR      0xc0000044
// mss_fab_slv0_clk_en: mss_clk <-> clk; design rule: none (mss_clk freq vs. clk freq)
`define MSS_CLKCTRL_MSS_FAB_SLV0_CLK_EN_RATIO_ADDR     0xc0000048
`define MSS_CLKCTRL_MSS_FAB_SLV0_CLK_EN_STAT_ADDR      0xc000004c
// mss_fab_slv1_clk_en: mss_clk <-> clk; design rule: none (mss_clk freq vs. clk freq)
`define MSS_CLKCTRL_MSS_FAB_SLV1_CLK_EN_RATIO_ADDR     0xc0000050
`define MSS_CLKCTRL_MSS_FAB_SLV1_CLK_EN_STAT_ADDR      0xc0000054
// mss_fab_slv2_clk_en: mss_clk <-> clk; design rule: none (mss_clk freq vs. clk freq)
`define MSS_CLKCTRL_MSS_FAB_SLV2_CLK_EN_RATIO_ADDR     0xc0000058
`define MSS_CLKCTRL_MSS_FAB_SLV2_CLK_EN_STAT_ADDR      0xc000005c
// mss_fab_slv3_clk_en: mss_clk <-> mss_clk; design rule: none (mss_clk freq vs. mss_clk freq)
`define MSS_CLKCTRL_MSS_FAB_SLV3_CLK_EN_RATIO_ADDR     0xc0000060
`define MSS_CLKCTRL_MSS_FAB_SLV3_CLK_EN_STAT_ADDR      0xc0000064
// mss_fab_slv4_clk_en: mss_clk <-> mss_clk; design rule: none (mss_clk freq vs. mss_clk freq)
`define MSS_CLKCTRL_MSS_FAB_SLV4_CLK_EN_RATIO_ADDR     0xc0000068
`define MSS_CLKCTRL_MSS_FAB_SLV4_CLK_EN_STAT_ADDR      0xc000006c
// mss_fab_slv5_clk_en: mss_clk <-> mss_clk; design rule: none (mss_clk freq vs. mss_clk freq)
`define MSS_CLKCTRL_MSS_FAB_SLV5_CLK_EN_RATIO_ADDR     0xc0000070
`define MSS_CLKCTRL_MSS_FAB_SLV5_CLK_EN_STAT_ADDR      0xc0000074
`define MSS_CLKCTRL_NMI_COUNTER              0xc0000078
