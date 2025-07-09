-comp_unit { 
  -top {
    -lib default
    -primary alb_mss_dummy_slave
    -secondary ""
    -result_file edif/alb_mss_dummy_slave/alb_mss_dummy_slave.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary alb_mss_dummy_slave
    -secondary ""
    -ver scm
    -input_file src/alb_mss_dummy_slave.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary apb_dummy_slave
    -secondary ""
    -ver scm
    -input_file src/apb_dummy_slave.scm
    -unit scm
  } 
}\
