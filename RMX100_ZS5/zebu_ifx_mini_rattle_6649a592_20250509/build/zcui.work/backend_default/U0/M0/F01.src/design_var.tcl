#  SYNOPSYS EMULATION and VERIFICATION (c) - 2002-2014
# -----------------------------------------------------
#            Variables for fpga compilation            

set znetgen_mode zpar
set top_name design
lappend edif_list wrapper.edf.gz
lappend edif_list fpga.edf.gz
set fpga_part xcvu19p-fsva3824-1-e
set fpga_family V8
set post_process vivado
set zpar_fw_macro zs5_xcvup_12c_19_v2
set zpar_fpga_name F01
set zpar_rbip_fw_macro zs5_hw_rbip.edf.gz
set zpar_fpga_index 1
set zpar_module_index 0
set zpar_unit_index 0
# using zdb FPGA & dev indexes:
set zpar_mudb_zdb_fpga 7
set zpar_mudb_zdb_dev  30

set zpar_zxtor_filename zs5_hw_zXtor.edf.gz
set zpar_smartzice_filename zs5_hw_smartzice.edf.gz
set zpar_zice_filename zs5_hw_ice.edf.gz
set zpar_zclkmem_filename zs5_hw_zrm.edf.gz
set zpar_zclkmem_freq 15000
set zpar_comp_real_hier {U0_M0_F1.U0_M0_F1_core}
set target_multi_die no
set zpar_target_orionpp 0
set ZEBU_VIVADO_CONSTRAINTS true
set ZEBU_VIVADO_CONSTRAINTS_OPTIONS " -mergeLimit 10000 -dataPathOnly"
set fetch_mode true
set fetch_mode_pclk_opt true
set die_build_flow default
set die_build_opts { -dapFlow rdp -pdmFlow budgetPDM -sktFwLib zs5_hw_zPar.edf.gz}
set cluster_split_args { -dapEngine rdp -coreDirectory work.Part_0/ -mdtmxSGMode physical -timingAnalysis false}
set zpar_fwc_ip_cmd {fwc  zcg_compositeClock -optimize area -version gen2 -sampling_frequency 50000 -unit 0 -module 0 -fpga F1  -fwfile zs5_hw_zPar.edf.gz -forceTopName zebu_top -originalDesignPath U0_M0_F1.U0_M0_F1_core -sabrefwfile undefined_fx_pas_lib.edf.gz }
set zpar_fwc_ip_zplug {zplug zplwc_ip}
set zpar_fwc_ip_report "true"

# Set variables for zNetgen from zPar.
set timing_analyze_args {TRISTATE_PATH ZFILTER_ENABLE_PATH ZFILTER_ASYNC_SET_RESET_PATH ZFILTER_FETCH_FEEDBACK }
set sdf_mode true
set enable_sdf_memory_model true
set zopt post_routing_basic
set zpar_filter_data_relocation true
set real_top_name zebu_top
set skipNtgProcess false

set complexity_predictor_bin 3
set is_complex_fpga false
