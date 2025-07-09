`define HAS_ACTIONPOINTS 0
`define HAS_VEC_UNIT 0
`define NUM_WRITEBACKS 2
`define AON_PD1_SPLIT 0
`define RATTLER 1
`define HAS_SAFETY 1
`define HAS_APEX              0
`define HAS_EXTENSION         0
`define HAS_WDT         1
`define HAS_CLINT       1
`define SMALL_INTERRUPT 0
`define WATCHDOG_CLK         1
`define POWER_DOMAINS   0
`define MEM_BUS_OPTION 0
`define MEM_BUS_NUM    1
`define PER0_BUS_OPTION 0
`define SYNC_LEGACY_IMPL 0
`define SYNC_FF_LEVELS   2
`define SYNC_CDC_LEVELS  2
`define SYNC_VERIF_EN    0
`define SYNC_SVA_TYPE    0
`define SYNC_TMR_CDC     0
`define HAS_IFQUEUE 0
`define HAS_DMP_MEMORY 1
`define HAS_DCACHE     0
`define SEC_MODES_OPTION 1
`define IS_ARCV5EM		1
`define DBG_WIDTH           32
`define DBG_BE_RANGE        3:0
`define DBG_DATA_RANGE      31:0
`define DBG_ADDR_RANGE      31:0
`define DBG_CMD_RANGE       1:0
`define DBG_PLEN_WIDTH      6
`define DBG_PLEN_MSB        5
`define DBG_PLEN_RANGE      7:0
`define MST0_PREF       ahb_h
`define MST0_SUPPORT_RATIO   0
`define MST0_CLK_NAME   clk
`define MST0_PROT       ahb5
`define MST0_DATA_WIDTH 32
`define MST0_ID_WIDTH   4
`define MST0_RW         rw
`define MST0_EXCL       1
`define MST0_LOCK       0
`define MST0_BUS_PARITY 3
`define MST1_PREF       dbu_per_ahb_h
`define MST1_SUPPORT_RATIO   0
`define MST1_CLK_NAME   clk
`define MST1_PROT       ahb5
`define MST1_DATA_WIDTH 32
`define MST1_ID_WIDTH   4
`define MST1_RW         rw
`define MST1_EXCL       1
`define MST1_LOCK       0
`define MST1_BUS_PARITY 3
`define NUM_MST 2
`define HAS_ICCM0            1
`define HAS_ICCM1            0
`define ICCM0_DMI            1
`define ICCM1_DMI            0
`define HAS_DCCM             1
`define DCCM_DMI             1
`define DMI_BURST_OPTION 0
`define DMI_PORTS 3
`define NUM_SLV 3
`define SLV0_NUM_REG         1
`define SLV0_REG0_APER_WIDTH 19
`define SLV0_ADDR_WIDTH      32
`define SLV0_DATA_WIDTH      32
`define SLV0_RESP            1
`define SLV0_REG_W           1
`define SLV0_SUPPORT_RATIO   1
`define SLV0_CLK_NAME        clk
`define SLV0_BUS_PARITY     3
`define SLV0_BUS_ECC_PROT  32
`define SLV0_CLK_EN          iccm_ahb_clk_en 
`define SLV0_PREF            iccm_ahb_h
`define SLV0_PREF_MSS        iccm_
`define SLV0_PROT            ahb
`define SLV1_NUM_REG         1
`define SLV1_REG0_APER_WIDTH 20
`define SLV1_ADDR_WIDTH      32
`define SLV1_DATA_WIDTH      32
`define SLV1_RESP            1
`define SLV1_REG_W           1
`define SLV1_SUPPORT_RATIO   1
`define SLV1_CLK_NAME        clk
`define SLV1_BUS_PARITY     3
`define SLV1_BUS_ECC_PROT  32
`define SLV1_CLK_EN          dccm_ahb_clk_en 
`define SLV1_PREF            dccm_ahb_h
`define SLV1_PREF_MSS        dccm_
`define SLV1_PROT            ahb
`define SLV2_NUM_REG         1
`define SLV2_REG0_APER_WIDTH 20
`define SLV2_ADDR_WIDTH      32
`define SLV2_DATA_WIDTH      32
`define SLV2_RESP            1
`define SLV2_REG_W           1
`define SLV2_SUPPORT_RATIO   1
`define SLV2_CLK_NAME        clk
`define SLV2_BUS_PARITY     3
`define SLV2_BUS_ECC_PROT  32
`define SLV2_CLK_EN          mmio_ahb_clk_en 
`define SLV2_PREF            mmio_ahb_h
`define SLV2_PREF_MSS        mmio_
`define SLV2_PROT            ahb
`define MSS_CLK_NUM          2
`define MSS_CLK0_NAME        clk 
`define MSS_CLK0_DEF_DIV2REF  1
`define MSS_CLK0_EN_NUM      3 
`define MSS_CLK0_EN0_NAME    iccm_ahb_clk_en
`define MSS_CLK0_EN0_OBJ     mss_clk 
`define MSS_CLK0_EN0_RULE    none
`define MSS_CLK0_EN1_NAME    dccm_ahb_clk_en
`define MSS_CLK0_EN1_OBJ     mss_clk 
`define MSS_CLK0_EN1_RULE    none
`define MSS_CLK0_EN2_NAME    mmio_ahb_clk_en
`define MSS_CLK0_EN2_OBJ     mss_clk 
`define MSS_CLK0_EN2_RULE    none
`define MSS_CLK1_NAME        wdt_clk
`define MSS_CLK1_DEF_DIV2REF  1
`define INTVBASE_PRESET      0
`define ADDR_WIDTH 32
`define ENDIAN little
`define HAS_ICACHE           1
`define HAS_ICCM             1
`define HAS_DCACHE           0
`define HAS_DMP_MEMORY       1
`define HAS_DCCM             1
`define CLOCK_GATING 0
`define DB_IBP_IF            1
`define PDM_HAS_FG         0
`define PWR_GRP0_PD1_NUM 2
`define PWR_GRP0_PD1_SFX0
`define PWR_GRP0_PD1_SFX1 _mem
`define NEED_LOAD_UPF     0 
`define IS_CLUSTER_TOP    0
`define CLUSTER_PREF      
`define INST_NAME         rl_cpu_top  // MSS needs update
`define UPF_FN0           rl_cpu_top
`define UPF_FN1           rl_cpu_top_supply_nets
`define NEED_MSS_DVFS     0 
`define HAS_XY            0
`define HAS_BS            0
`define HAS_DSP           0
`define RGF_IMPL          0
`define HAS_SMART         0
`define SMART_IMPLEMENTATION 0
`define RGF_RAM_MACRO     0
`define CC_PD1_FG         0
`define CORE_HAS_SAFETY   1
`define HAS_TRIGGERS    1
`define SRAMS_IN_CPU_TOP   0
`define SYNC_LEGACY_IMPL   0
`define SYNC_CDC_LEVELS    2 
`define SYNC_TMR_CDC       0    
`define SYNC_VERIF_EN      0   
`define SYNC_SVA_TYPE      0   
`define SYNC_FF_LEVELS     2
`define TIE_SIGNALS_0_NAME  iccm_ahb_prio
`define TIE_SIGNALS_0_RANGE 
`define TIE_SIGNALS_1_NAME  iccm_ahb_hmastlock
`define TIE_SIGNALS_1_RANGE 
`define TIE_SIGNALS_2_NAME  iccm_ahb_hexcl
`define TIE_SIGNALS_2_RANGE 
`define TIE_SIGNALS_3_NAME  iccm_ahb_hmaster
`define TIE_SIGNALS_3_RANGE [3:0]
`define TIE_SIGNALS_4_NAME  iccm_ahb_hwstrb
`define TIE_SIGNALS_4_RANGE [3:0]
`define TIE_SIGNALS_4_VALUE 4'b1111
`define TIE_SIGNALS_5_NAME  iccm_ahb_hprot
`define TIE_SIGNALS_5_RANGE [6:0]
`define TIE_SIGNALS_6_NAME  iccm_ahb_hnonsec
`define TIE_SIGNALS_6_RANGE 
`define TIE_SIGNALS_7_NAME  iccm_ahb_hselchk
`define TIE_SIGNALS_7_RANGE 
`define TIE_SIGNALS_8_NAME  dccm_ahb_prio
`define TIE_SIGNALS_8_RANGE 
`define TIE_SIGNALS_9_NAME  dccm_ahb_hmastlock
`define TIE_SIGNALS_9_RANGE 
`define TIE_SIGNALS_10_NAME  dccm_ahb_hexcl
`define TIE_SIGNALS_10_RANGE 
`define TIE_SIGNALS_11_NAME  dccm_ahb_hmaster
`define TIE_SIGNALS_11_RANGE [3:0]
`define TIE_SIGNALS_12_NAME  dccm_ahb_hwstrb
`define TIE_SIGNALS_12_RANGE [3:0]
`define TIE_SIGNALS_12_VALUE 4'b1111
`define TIE_SIGNALS_13_NAME  dccm_ahb_hprot
`define TIE_SIGNALS_13_RANGE [6:0]
`define TIE_SIGNALS_14_NAME  dccm_ahb_hnonsec
`define TIE_SIGNALS_14_RANGE 
`define TIE_SIGNALS_15_NAME  dccm_ahb_hselchk
`define TIE_SIGNALS_15_RANGE 
`define TIE_SIGNALS_16_NAME  mmio_ahb_prio
`define TIE_SIGNALS_16_RANGE 
`define TIE_SIGNALS_17_NAME  mmio_ahb_hmastlock
`define TIE_SIGNALS_17_RANGE 
`define TIE_SIGNALS_18_NAME  mmio_ahb_hexcl
`define TIE_SIGNALS_18_RANGE 
`define TIE_SIGNALS_19_NAME  mmio_ahb_hmaster
`define TIE_SIGNALS_19_RANGE [3:0]
`define TIE_SIGNALS_20_NAME  mmio_ahb_hwstrb
`define TIE_SIGNALS_20_RANGE [3:0]
`define TIE_SIGNALS_20_VALUE 4'b1111
`define TIE_SIGNALS_21_NAME  mmio_ahb_hprot
`define TIE_SIGNALS_21_RANGE [6:0]
`define TIE_SIGNALS_22_NAME  mmio_ahb_hnonsec
`define TIE_SIGNALS_22_RANGE 
`define TIE_SIGNALS_23_NAME  mmio_ahb_hselchk
`define TIE_SIGNALS_23_RANGE 
`define TIE_SIGNALS_24_NAME  mmio_base_in
`define TIE_SIGNALS_24_RANGE [11:0]
`define TIE_SIGNALS_24_VALUE 3584
`define TIE_SIGNALS_25_NAME  reset_pc_in
`define TIE_SIGNALS_25_RANGE [21:0]
`define TIE_SIGNALS_25_VALUE 0
`define TIE_SIGNALS_26_NAME  LBIST_EN
`define TIE_SIGNALS_26_RANGE 
`define TIE_SIGNALS_27_NAME  rst_cpu_req_a
`define TIE_SIGNALS_27_RANGE 
`define TIE_SIGNALS_28_NAME  dmsi_valid
`define TIE_SIGNALS_28_RANGE 
`define TIE_SIGNALS_29_NAME  dmsi_valid_chk
`define TIE_SIGNALS_29_RANGE 
`define TIE_SIGNALS_29_VALUE 1
`define TIE_SIGNALS_30_NAME  dmsi_data_edc
`define TIE_SIGNALS_30_RANGE [5:0]
`define TIE_SIGNALS_31_NAME  dmsi_context
`define TIE_SIGNALS_31_RANGE [0:0]
`define TIE_SIGNALS_32_NAME  dmsi_eiid
`define TIE_SIGNALS_32_RANGE [5:0]
`define TIE_SIGNALS_33_NAME  dmsi_domain
`define TIE_SIGNALS_33_RANGE 
`define TIE_SIGNALS_34_NAME  ext_trig_output_accept
`define TIE_SIGNALS_34_RANGE [1:0]
`define TIE_SIGNALS_35_NAME  ext_trig_in
`define TIE_SIGNALS_35_RANGE [15:0]
`define TIE_SIGNALS_36_NAME  rst_init_disable_a
`define TIE_SIGNALS_36_RANGE 
`define TIE_SIGNALS_37_NAME  rnmi_a
`define TIE_SIGNALS_37_RANGE 
`define TIE_SIGNALS_38_NAME  wid_rlwid
`define TIE_SIGNALS_38_RANGE [4:0]
`define TIE_SIGNALS_39_NAME  wid_rwiddeleg
`define TIE_SIGNALS_39_RANGE [63:0]
`define TIE_SIGNALS_40_NAME  soft_reset_prepare_a
`define TIE_SIGNALS_40_RANGE 
`define TIE_SIGNALS_41_NAME  soft_reset_req_a
`define TIE_SIGNALS_41_RANGE 
`define TIE_SIGNALS 42
`define STUB_SIGNALS_0_NAME  iccm_ahb_hexokay
`define STUB_SIGNALS_0_RANGE 
`define STUB_SIGNALS_1_NAME  iccm_ahb_fatal_err
`define STUB_SIGNALS_1_RANGE 
`define STUB_SIGNALS_2_NAME  iccm_ahb_hrespchk
`define STUB_SIGNALS_2_RANGE 
`define STUB_SIGNALS_3_NAME  iccm_ahb_hreadyoutchk
`define STUB_SIGNALS_3_RANGE 
`define STUB_SIGNALS_4_NAME  iccm_ahb_hrdatachk
`define STUB_SIGNALS_4_RANGE [3:0]
`define STUB_SIGNALS_5_NAME  dccm_ahb_hexokay
`define STUB_SIGNALS_5_RANGE 
`define STUB_SIGNALS_6_NAME  dccm_ahb_fatal_err
`define STUB_SIGNALS_6_RANGE 
`define STUB_SIGNALS_7_NAME  dccm_ahb_hrespchk
`define STUB_SIGNALS_7_RANGE 
`define STUB_SIGNALS_8_NAME  dccm_ahb_hreadyoutchk
`define STUB_SIGNALS_8_RANGE 
`define STUB_SIGNALS_9_NAME  dccm_ahb_hrdatachk
`define STUB_SIGNALS_9_RANGE [3:0]
`define STUB_SIGNALS_10_NAME  mmio_ahb_hexokay
`define STUB_SIGNALS_10_RANGE 
`define STUB_SIGNALS_11_NAME  mmio_ahb_fatal_err
`define STUB_SIGNALS_11_RANGE 
`define STUB_SIGNALS_12_NAME  mmio_ahb_hrespchk
`define STUB_SIGNALS_12_RANGE 
`define STUB_SIGNALS_13_NAME  mmio_ahb_hreadyoutchk
`define STUB_SIGNALS_13_RANGE 
`define STUB_SIGNALS_14_NAME  mmio_ahb_hrdatachk
`define STUB_SIGNALS_14_RANGE [3:0]
`define STUB_SIGNALS_15_NAME  dbu_per_ahb_hexcl
`define STUB_SIGNALS_15_RANGE 
`define STUB_SIGNALS_16_NAME  dbu_per_ahb_hmastlock
`define STUB_SIGNALS_16_RANGE 
`define STUB_SIGNALS_17_NAME  dbu_per_ahb_hmaster
`define STUB_SIGNALS_17_RANGE [3:0]
`define STUB_SIGNALS_18_NAME  dbu_per_ahb_hauser
`define STUB_SIGNALS_18_RANGE [7:0]
`define STUB_SIGNALS_19_NAME  dbu_per_ahb_hauserchk
`define STUB_SIGNALS_19_RANGE 
`define STUB_SIGNALS_20_NAME  dbu_per_ahb_haddrchk
`define STUB_SIGNALS_20_RANGE [3:0]
`define STUB_SIGNALS_21_NAME  dbu_per_ahb_htranschk
`define STUB_SIGNALS_21_RANGE 
`define STUB_SIGNALS_22_NAME  dbu_per_ahb_hctrlchk1
`define STUB_SIGNALS_22_RANGE 
`define STUB_SIGNALS_23_NAME  dbu_per_ahb_hctrlchk2
`define STUB_SIGNALS_23_RANGE 
`define STUB_SIGNALS_24_NAME  dbu_per_ahb_hwstrbchk
`define STUB_SIGNALS_24_RANGE 
`define STUB_SIGNALS_25_NAME  dbu_per_ahb_hprotchk
`define STUB_SIGNALS_25_RANGE 
`define STUB_SIGNALS_26_NAME  dbu_per_ahb_hwdatachk
`define STUB_SIGNALS_26_RANGE [3:0]
`define STUB_SIGNALS_27_NAME  dbu_per_ahb_fatal_err
`define STUB_SIGNALS_27_RANGE 
`define STUB_SIGNALS_28_NAME  high_prio_ras
`define STUB_SIGNALS_28_RANGE 
`define STUB_SIGNALS_29_NAME  ahb_hexcl
`define STUB_SIGNALS_29_RANGE 
`define STUB_SIGNALS_30_NAME  ahb_hmastlock
`define STUB_SIGNALS_30_RANGE 
`define STUB_SIGNALS_31_NAME  ahb_hmaster
`define STUB_SIGNALS_31_RANGE [3:0]
`define STUB_SIGNALS_32_NAME  ahb_hauser
`define STUB_SIGNALS_32_RANGE [7:0]
`define STUB_SIGNALS_33_NAME  ahb_hauserchk
`define STUB_SIGNALS_33_RANGE 
`define STUB_SIGNALS_34_NAME  ahb_haddrchk
`define STUB_SIGNALS_34_RANGE [3:0]
`define STUB_SIGNALS_35_NAME  ahb_htranschk
`define STUB_SIGNALS_35_RANGE 
`define STUB_SIGNALS_36_NAME  ahb_hctrlchk1
`define STUB_SIGNALS_36_RANGE 
`define STUB_SIGNALS_37_NAME  ahb_hctrlchk2
`define STUB_SIGNALS_37_RANGE 
`define STUB_SIGNALS_38_NAME  ahb_hwstrbchk
`define STUB_SIGNALS_38_RANGE 
`define STUB_SIGNALS_39_NAME  ahb_hprotchk
`define STUB_SIGNALS_39_RANGE 
`define STUB_SIGNALS_40_NAME  ahb_hwdatachk
`define STUB_SIGNALS_40_RANGE [3:0]
`define STUB_SIGNALS_41_NAME  ahb_fatal_err
`define STUB_SIGNALS_41_RANGE 
`define STUB_SIGNALS_42_NAME  wdt_reset0
`define STUB_SIGNALS_42_RANGE 
`define STUB_SIGNALS_43_NAME  wdt_reset_wdt_clk0
`define STUB_SIGNALS_43_RANGE 
`define STUB_SIGNALS_44_NAME  reg_wr_en0
`define STUB_SIGNALS_44_RANGE 
`define STUB_SIGNALS_45_NAME  critical_error
`define STUB_SIGNALS_45_RANGE 
`define STUB_SIGNALS_46_NAME  ext_trig_output_valid
`define STUB_SIGNALS_46_RANGE [1:0]
`define STUB_SIGNALS_47_NAME  dmsi_rdy
`define STUB_SIGNALS_47_RANGE 
`define STUB_SIGNALS_48_NAME  dmsi_rdy_chk
`define STUB_SIGNALS_48_RANGE 
`define STUB_SIGNALS_49_NAME  soft_reset_ready
`define STUB_SIGNALS_49_RANGE 
`define STUB_SIGNALS_50_NAME  soft_reset_ack
`define STUB_SIGNALS_50_RANGE 
`define STUB_SIGNALS_51_NAME  rst_cpu_ack
`define STUB_SIGNALS_51_RANGE 
`define STUB_SIGNALS_52_NAME  cpu_in_reset_state
`define STUB_SIGNALS_52_RANGE 
`define STUB_SIGNALS_53_NAME  safety_mem_dbe
`define STUB_SIGNALS_53_RANGE [1:0]
`define STUB_SIGNALS_54_NAME  safety_mem_sbe
`define STUB_SIGNALS_54_RANGE [1:0]
`define STUB_SIGNALS 55
`define AHB_WSTRB_OPTION 1
