// Library safety-1.1.999999999
`include "rv_safety_config.in"
`include "rv_safety_exported_defines.v"
`include "exported_defines.v"

//#header rtl/rv_safety_defines.vpp :SYNTH,SIM,LOGIC





//#source rtl/ls_input_delay.svpp       :SYNTH,SIM,LOGIC
//#source rtl/ls_compare_unit.vpp       :SYNTH,SIM,LOGIC
//#source rtl/ls_multi_bit_comparator.svpp       :SYNTH,SIM,LOGIC
//#source rtl/ls_cdc_reset_sync.vpp       :SYNTH,SIM,LOGIC
//#source rtl/ls_cdc_sync.vpp       :SYNTH,SIM,LOGIC
//#source rtl/multi_bit_syncP.vpp       :SYNTH,SIM,LOGIC
//#source rtl/single_bit_syncP.vpp       :SYNTH,SIM,LOGIC
//#source rtl/ls_error_register.vpp       :SYNTH,SIM,LOGIC
//#source rtl/simple_parity.vpp       :SYNTH,SIM,LOGIC

//#source rtl/ls_register.vpp       :SYNTH,SIM,LOGIC
//#source rtl/ls_boot_counter.vpp       :SYNTH,SIM,LOGIC

// Needed by the sync modules.
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm21_atv.vpp    :CPU,SYNTH,SIM,LOGIC
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm21.vpp        :CPU,SYNTH,SIM,LOGIC
// Called by bcm21:
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm99_3.vpp      :CPU,SYNTH,SIM,LOGIC
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm99_4.vpp      :CPU,SYNTH,SIM,LOGIC
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm99.vpp        :CPU,SYNTH,SIM,LOGIC
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm99_n.vpp        :CPU,SYNTH,SIM,LOGIC
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm23_atv.vpp    :CPU,SYNTH,SIM,LOGIC
//#source component:ARC_COMN.BCM:rtl/DWbb_bcm95.vpp        :CPU,SYNTH,SIM,LOGIC

//#source rtl/cpu_top_safety_controller.svpp       :SYNTH,SIM,LOGIC
//#source rtl/err_inj_ctrl.svpp       :SYNTH,SIM,LOGIC
//#source rtl/ls_sfty_mnt_diag_ctrl.svpp       :SYNTH,SIM,LOGIC

//#source rtl/safety_iso_sync.svpp       :SYNTH,SIM,LOGIC

// These defines are used by pass2.
// This cannot be done using the usual means because 
// when we run constraints, it will try to parse cpu_top, which isn't there.
// Emit this module even if the CPU doesn't want replication, because
// the safety monitor needs the defines.
//#source rtl/cpu_ls_defines.vpp       :SYNTH,SIM,LOGIC

