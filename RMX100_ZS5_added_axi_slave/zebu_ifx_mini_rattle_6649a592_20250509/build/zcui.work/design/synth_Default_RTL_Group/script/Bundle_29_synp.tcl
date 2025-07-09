-comp_unit { 
  -top {
    -lib default
    -primary alb_mss_fab_axi2ibp_rrobin
    -secondary ""
    -result_file edif/alb_mss_fab_axi2ibp_rrobin/alb_mss_fab_axi2ibp_rrobin.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary alb_mss_fab_axi2ibp_rrobin
    -secondary ""
    -ver scm
    -input_file src/alb_mss_fab_axi2ibp_rrobin.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_dw512_slv
    -secondary ""
    -result_file edif/mss_bus_switch_dw512_slv/mss_bus_switch_dw512_slv.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_dw512_slv
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_dw512_slv.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibp2pack_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp2pack_0000.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibpx2ibpy_0000_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibpx2ibpy_0000_0000.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibp_cwbind_0000_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp_cwbind_0000_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary rl_decoder
    -secondary ""
    -result_file edif/rl_decoder/rl_decoder.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_decoder
    -secondary ""
    -ver scm
    -input_file src/rl_decoder.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary rl_hpm
    -secondary ""
    -result_file edif/rl_hpm/rl_hpm.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_hpm
    -secondary ""
    -ver scm
    -input_file src/rl_hpm.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary sr_err_aggr_0000_0000
    -secondary ""
    -result_file edif/sr_err_aggr_0000_0000/sr_err_aggr_0000_0000.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary sr_err_aggr_0000_0000
    -secondary ""
    -ver scm
    -input_file src/sr_err_aggr_0000_0000.scm
    -unit scm
  } 
}\
