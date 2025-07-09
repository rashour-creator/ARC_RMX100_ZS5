`define SAFETY_DELAY         0
`define CLN_SAFETY_DELAY     `CLN_SAFETY_DELAY
`define MAX_AGG_BITS         32
`define REGISTER_COMPARANDS  0
`define SAFETY_MASTER        0	// No support yet for master.
`define INCORPORATE_MCIP        0	// Needed by DS's tim defines.
`define RV_SMALL_INTERRUPT     0
`define ALLOW_PERFORMANCE_MODE 0
`define APM 0
`define PERFORMANCE_MODE 0
`define HYBRID_MODE 0
`define CPU_SAFETY_HIERARCHY 0
`define SFTY_DCLS            1
`define SAFETY_BUS           0
`define STL_ENABLE           0
`define REG_EDC              0
`define CPU_SAFETY 0
`define DS_SAFETY        0
`define CLN_SAFETY       `CLN_PRESENT
`define EXPORT_CORE_SFTY_ALARM   0
`define RL_SAFETY        1 
`define APLIC_SAFETY        0
`define DN_SAFETY        0
`define HW_ERROR_INJECTION       1
`define REG_EDC                  0
`define SAFETY_PARITY            0
`define rv_lsc_diag_lock_reset          1:0
`define rv_lsc_diag_mei                 3:2
`define rv_lsc_diag_smi                 5:4
`define rv_lsc_diag_e2e                 7:6
`define rv_lsc_diag_wei                 9:8
`define rv_lsc_diag_cei	           11:10
`define rv_lsc_diag_ptoi	           13:12
`define rv_lsc_diag_bei	           15:14
`define rv_lsc_diag_tre	           17:16
`define rv_lsc_diag_clf	           27:26
`define rv_lsc_diag_end                 29:28
`define rv_lsc_diag_mode_enable         31:30
`define rv_lsc_diag_reserved_msb	          7
`define rv_diag_lock_reset_impl            1:0
`define rv_diag_mei_error_impl          3 :2 
`define rv_diag_smi_error_impl          5 :4 
`define rv_diag_e2e_error_impl          7 :6 
`define rv_diag_wei_error_impl          9 :8 
`define rv_diag_cei_error_impl          11 :10 
`define rv_diag_clf_impl                13 :12 
`define rv_cln_diag_mei_error_impl          3 :2 
`define rv_cln_diag_smi_error_impl          5 :4 
`define rv_cln_diag_e2e_error_impl          7 :6 
`define rv_cln_diag_wei_error_impl          9 :8 
`define rv_cln_diag_cei_error_impl          11 :10 
`define rv_cln_diag_ptoi_error_impl         13 :12 
`define rv_cln_diag_tre_error_impl          15 :14 
`define rv_cln_diag_clf_impl                17 :16 
`define rv_lsc_diag_bits     16
`define rv_lsc_diag_msb      15
`define RV_LSC_DIAG_RANGE 15:0
`define RV_LSC_DIAG_WR_PAIR 8
`define rv_diag_mode_enable_impl           15:14 
`define rv_lsc_err_stat_bits     14
`define rv_lsc_err_stat_msb   13
`define RV_LSC_ERR_STAT_RANGE 13:0
`define rv_lsc_latt_err_stat_bits     5
`define rv_lsc_latt_err_stat_msb      4
`define rv_cln_lsc_latt_err_stat_bits     6
`define rv_cln_lsc_latt_err_stat_msb      5
`define rv_lsc_err_stat_cm_impl       0
`define rv_lsc_err_stat_me_impl       1
`define rv_lsc_err_stat_mae_impl      2
`define rv_lsc_err_stat_wdp_impl      3
`define rv_lsc_err_stat_wdt_impl      4
`define rv_lsc_err_stat_e2e_impl      5
`define rv_lsc_err_stat_tre_impl      6
`define rv_lsc_err_stat_sme_impl      7
`define rv_lsc_err_stat_iso_impl      8
`define rv_lsc_err_stat_lf_impl       9
`define rv_lsc_err_stat_stl_impl      10
`define rv_lsc_err_stat_sbo_impl      11
`define rv_lsc_err_stat_be_impl       12
`define rv_lsc_err_stat_hpras_impl    13
`define rv_lsc_err_stat_pto_impl      14
`define rv_lsc_latt_err_stat_cef_impl 0
`define rv_lsc_latt_err_stat_e2ef_impl 1
`define rv_lsc_latt_err_stat_mef_impl 2
`define rv_lsc_latt_err_stat_smf_impl 3
`define rv_lsc_latt_err_stat_wdf_impl 4
`define rv_lsc_latt_err_stat_tref_impl 5
`define RV_SAFETY_ARCV2MSS 1
`define RV_SAFETY_STUB_SIGNALS_0_NAME  safety_error
`define RV_SAFETY_STUB_SIGNALS_0_RANGE [1:0]
`define RV_SAFETY_STUB_SIGNALS_1_NAME  safety_enabled
`define RV_SAFETY_STUB_SIGNALS_1_RANGE [1:0]
`define RV_SAFETY_TIE_SIGNALS_0_NAME  safety_iso_enb
`define RV_SAFETY_TIE_SIGNALS_0_RANGE [1:0]
`define RV_SAFETY_TIE_SIGNALS_0_VALUE 2'b01
`define RV_SAFETY_TIE_SIGNALS 1
`define RV_SAFETY_STUB_SIGNALS       2
`define RV_SAFETY_STUB_HSK_SIGNALS   0
`define RV_SAFETY_NUM_MST 0
`define RV_SAFETY_NUM_SLV 0
`define rv_cln_sfty_ctrl_base               12'h00
`define rv_cln_sfty_diag_base               12'h04
`define rv_cln_sfty_shdw_ctrl_base          12'h08
`define rv_cln_sfty_arc_pto_ctrl_base       12'h0C
`define rv_cln_sfty_dev_pto_ctrl_base       12'h10
`define rv_cln_dmsi_sfty_no_boot_0          12'h14
`define rv_cln_dmsi_sfty_no_boot_1          12'h14
`define rv_cln_sfty_err_stat_base           12'h20
`define rv_cln_sfty_ltnt_err_stat_base      12'h24
`define rv_cln_sfty_core_err_stat_base      12'h28
`define rv_cln_sfty_dev_pto_err_stat_base   12'h2C
`define rv_cln_sfty_core_hyb_stat_base      12'h30
`define rv_cln_sfty_core_pdm_stat_base      12'h34
`define rv_cln_dmsi_sfty_error_status       12'h38
`define rv_cln_dmsi_sfty_enabled_status     12'h3C
`define cln_lsc_err_stat_bits     15
`define cln_lsc_err_stat_msb      14
`define cln_lsc_err_stat_cm_impl       0
`define cln_lsc_err_stat_me_impl       1
`define cln_lsc_err_stat_mae_impl      2
`define cln_lsc_err_stat_wdp_impl      3
`define cln_lsc_err_stat_wdt_impl      4
`define cln_lsc_err_stat_e2e_impl      5
`define cln_lsc_err_stat_tre_impl      6
`define cln_lsc_err_stat_sme_impl      7
`define cln_lsc_err_stat_iso_impl      8
`define cln_lsc_err_stat_lf_impl       9
`define cln_lsc_err_stat_stl_impl      10
`define cln_lsc_err_stat_sbo_impl      11
`define cln_lsc_err_stat_be_impl       12
`define cln_lsc_err_stat_core_impl     13
`define cln_lsc_err_stat_pto_impl      14
`define cln_ibp_addr_range 39:0
`define MONITOR_PER_CONTROLLER 0
`define rv_cln_pto_tc          3:0
`define rv_cln_pto_ts          7:4
`define rv_cln_pto_arc_id      12:8
`define rv_cln_pto_dev_id      12:8
