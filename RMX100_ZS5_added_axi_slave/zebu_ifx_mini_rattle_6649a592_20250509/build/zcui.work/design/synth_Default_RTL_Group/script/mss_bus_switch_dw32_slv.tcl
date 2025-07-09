-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_dw32_slv
    -secondary ""
    -result_file edif/mss_bus_switch_dw32_slv/mss_bus_switch_dw32_slv.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_dw32_slv
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_dw32_slv.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibp2pack
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp2pack.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibpx2ibpy_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibpx2ibpy_0000.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibp_cwbind_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp_cwbind_0000.scm
    -unit scm
  } 
}\
