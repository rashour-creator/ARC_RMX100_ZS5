-comp_unit { 
  -top {
    -lib default
    -primary alb_mss_perfctrl
    -secondary ""
    -result_file edif/alb_mss_perfctrl/alb_mss_perfctrl.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary alb_mss_perfctrl
    -secondary ""
    -ver scm
    -input_file src/alb_mss_perfctrl.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary ls_cdc_sync_0000
    -secondary ""
    -result_file edif/ls_cdc_sync_0000/ls_cdc_sync_0000.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary ls_cdc_sync_0000
    -secondary ""
    -ver scm
    -input_file src/ls_cdc_sync_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_ibp_compr_0000
    -secondary ""
    -result_file edif/mss_bus_switch_ibp_compr_0000/mss_bus_switch_ibp_compr_0000.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_ibp_compr_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp_compr_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_ibp_split_0000_0000
    -secondary ""
    -result_file edif/mss_bus_switch_ibp_split_0000_0000/mss_bus_switch_ibp_split_0000_0000.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_ibp_split_0000_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp_split_0000_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary rl_bitscan_16b
    -secondary ""
    -result_file edif/rl_bitscan_16b/rl_bitscan_16b.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_bitscan_16b
    -secondary ""
    -ver scm
    -input_file src/rl_bitscan_16b.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary zz_Encrypt_5
    -secondary ""
    -result_file edif/zz_Encrypt_5/zz_Encrypt_5.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary zz_Encrypt_5
    -secondary ""
    -ver scm
    -input_file src/zz_Encrypt_5.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary zz_Encrypt_4
    -secondary ""
    -ver scm
    -input_file src/zz_Encrypt_4.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary zz_Encrypt_3
    -secondary ""
    -ver scm
    -input_file src/zz_Encrypt_3.scm
    -unit scm
  } 
}\
