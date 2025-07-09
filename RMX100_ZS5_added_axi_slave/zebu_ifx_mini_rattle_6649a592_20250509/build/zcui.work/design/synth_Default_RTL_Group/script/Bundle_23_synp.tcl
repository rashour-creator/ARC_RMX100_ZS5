-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_ibpw2ibpn_0000
    -secondary ""
    -result_file edif/mss_bus_switch_ibpw2ibpn_0000/mss_bus_switch_ibpw2ibpn_0000.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_ibpw2ibpn_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibpw2ibpn_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary reset_fsm
    -secondary ""
    -result_file edif/reset_fsm/reset_fsm.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary reset_fsm
    -secondary ""
    -ver scm
    -input_file src/reset_fsm.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary xtor_amba_master_axi3_svs
    -secondary ""
    -result_file edif/xtor_amba_master_axi3_svs/xtor_amba_master_axi3_svs.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary xtor_amba_master_axi3_svs
    -secondary ""
    -ver scm
    -input_file src/xtor_amba_master_axi3_svs.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary zemi3OutPortArbiter_2_96_op
    -secondary ""
    -ver scm
    -input_file src/zemi3OutPortArbiter_2_96_op.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary zemi3OutPortArbiter_2_608_op
    -secondary ""
    -ver scm
    -input_file src/zemi3OutPortArbiter_2_608_op.scm
    -unit scm
  } 
}\
