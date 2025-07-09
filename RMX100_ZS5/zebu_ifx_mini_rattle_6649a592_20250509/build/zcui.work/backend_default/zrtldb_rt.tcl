#written by BackendEntry
set_data_type runtime
set_log_file zRTLDB_rt.log
set_design_directory {../design}
add_dut_group ../design/synth_Default_RTL_Group zebu_top
set_top zebu_top
