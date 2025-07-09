-comp_unit { 
  -top {
    -lib default
    -primary alb_mss_mem_ibp_excl_0000
    -secondary ""
    -result_file edif/alb_mss_mem_ibp_excl_0000/alb_mss_mem_ibp_excl_0000.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary alb_mss_mem_ibp_excl_0000
    -secondary ""
    -ver scm
    -input_file src/alb_mss_mem_ibp_excl_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_ibp_dw128_mst
    -secondary ""
    -result_file edif/mss_bus_switch_ibp_dw128_mst/mss_bus_switch_ibp_dw128_mst.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_ibp_dw128_mst
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp_dw128_mst.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_pack2ibp_0002
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_pack2ibp_0002.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary rl_reset_ctrl
    -secondary ""
    -result_file edif/rl_reset_ctrl/rl_reset_ctrl.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_reset_ctrl
    -secondary ""
    -ver scm
    -input_file src/rl_reset_ctrl.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary xtor_amba_slave_axi3_svs
    -secondary ""
    -result_file edif/xtor_amba_slave_axi3_svs/xtor_amba_slave_axi3_svs.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary xtor_amba_slave_axi3_svs
    -secondary ""
    -ver scm
    -input_file src/xtor_amba_slave_axi3_svs.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary zemi3OutPortArbiter_2_160_op
    -secondary ""
    -ver scm
    -input_file src/zemi3OutPortArbiter_2_160_op.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary zemi3OutPortBuffer_169_4096_24
    -secondary ""
    -result_file edif/zemi3OutPortBuffer_169_4096_24/zemi3OutPortBuffer_169_4096_24.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary zemi3OutPortBuffer_169_4096_24
    -secondary ""
    -ver scm
    -input_file src/zemi3OutPortBuffer_169_4096_24.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary zz_Encrypt_8
    -secondary ""
    -result_file edif/zz_Encrypt_8/zz_Encrypt_8.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary zz_Encrypt_8
    -secondary ""
    -ver scm
    -input_file src/zz_Encrypt_8.scm
    -unit scm
  } 
}\
