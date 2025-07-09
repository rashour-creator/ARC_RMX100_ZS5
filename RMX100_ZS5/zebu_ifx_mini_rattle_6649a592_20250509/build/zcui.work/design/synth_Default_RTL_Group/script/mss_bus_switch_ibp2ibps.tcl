-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_ibp2ibps
    -secondary ""
    -result_file edif/mss_bus_switch_ibp2ibps/mss_bus_switch_ibp2ibps.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_ibp2ibps
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp2ibps.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_pack2ibp
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_pack2ibp.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibp2pack_0001
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp2pack_0001.scm
    -unit scm
  } 
}\
