-comp_unit { 
  -top {
    -lib default
    -primary alb_mss_mem
    -secondary ""
    -result_file edif/alb_mss_mem/alb_mss_mem.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary alb_mss_mem
    -secondary ""
    -ver scm
    -input_file src/alb_mss_mem.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary alb_mss_mem_ibp2pack
    -secondary ""
    -ver scm
    -input_file src/alb_mss_mem_ibp2pack.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary alb_mss_mem_ibp_split_0000
    -secondary ""
    -ver scm
    -input_file src/alb_mss_mem_ibp_split_0000.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary alb_mss_mem_pack2ibp
    -secondary ""
    -ver scm
    -input_file src/alb_mss_mem_pack2ibp.scm
    -unit scm
  } 
}\
