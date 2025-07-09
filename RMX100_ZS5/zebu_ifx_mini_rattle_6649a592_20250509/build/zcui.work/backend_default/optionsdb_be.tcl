#written by BackendEntry
set_data_type optionsdb
set_log_file zOptionsDb.log
set_optionsdb_file utf_generatefiles/optionsdb_config.tcl
set_design_directory {../design}
add_dut_group ../design/synth_Default_RTL_Group zebu_top
set_top zebu_top
