-comp_unit { 
  -top {
    -lib default
    -primary alb_mss_fab_bypbuf_0000_0001
    -secondary ""
    -result_file edif/alb_mss_fab_bypbuf_0000_0001/alb_mss_fab_bypbuf_0000_0001.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary alb_mss_fab_bypbuf_0000_0001
    -secondary ""
    -ver scm
    -input_file src/alb_mss_fab_bypbuf_0000_0001.scm
    -unit scm
  } 
}\
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
    -primary rl_cpu_top
    -secondary ""
    -result_file edif/rl_cpu_top/rl_cpu_top.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_cpu_top
    -secondary ""
    -ver scm
    -input_file src/rl_cpu_top.scm
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
    -primary zz_Encrypt_3
    -secondary ""
    -ver scm
    -input_file src/zz_Encrypt_3.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary zz_Encrypt_2
    -secondary ""
    -ver scm
    -input_file src/zz_Encrypt_2.scm
    -unit scm
  } 
}\
