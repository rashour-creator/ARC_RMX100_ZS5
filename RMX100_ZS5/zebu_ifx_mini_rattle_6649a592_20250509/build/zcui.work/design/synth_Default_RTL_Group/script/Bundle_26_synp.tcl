-comp_unit { 
  -top {
    -lib default
    -primary alb_mss_fab_fifo_0004
    -secondary ""
    -result_file edif/alb_mss_fab_fifo_0004/alb_mss_fab_fifo_0004.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary alb_mss_fab_fifo_0004
    -secondary ""
    -ver scm
    -input_file src/alb_mss_fab_fifo_0004.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary arcv_dm
    -secondary ""
    -result_file edif/arcv_dm/arcv_dm.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary arcv_dm
    -secondary ""
    -ver scm
    -input_file src/arcv_dm.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary err_inj_ctrl_0000
    -secondary ""
    -result_file edif/err_inj_ctrl_0000/err_inj_ctrl_0000.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary err_inj_ctrl_0000
    -secondary ""
    -ver scm
    -input_file src/err_inj_ctrl_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_ibp_dw32_mst
    -secondary ""
    -result_file edif/mss_bus_switch_ibp_dw32_mst/mss_bus_switch_ibp_dw32_mst.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_ibp_dw32_mst
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibp_dw32_mst.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_ibpx2ibpy_0000_0001
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_ibpx2ibpy_0000_0001.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary mss_bus_switch_pack2ibp_0000
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_pack2ibp_0000.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary rl_csr
    -secondary ""
    -result_file edif/rl_csr/rl_csr.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_csr
    -secondary ""
    -ver scm
    -input_file src/rl_csr.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary rl_soft_reset_aux
    -secondary ""
    -result_file edif/rl_soft_reset_aux/rl_soft_reset_aux.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_soft_reset_aux
    -secondary ""
    -ver scm
    -input_file src/rl_soft_reset_aux.scm
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
