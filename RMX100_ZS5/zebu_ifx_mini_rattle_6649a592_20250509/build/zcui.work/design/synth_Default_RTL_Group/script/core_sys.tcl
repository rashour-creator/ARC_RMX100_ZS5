-comp_unit { 
  -top {
    -lib default
    -primary core_sys
    -secondary ""
    -result_file edif/core_sys/core_sys.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary core_sys
    -secondary ""
    -ver scm
    -input_file src/core_sys.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary dw_dbp_stubs
    -secondary ""
    -ver scm
    -input_file src/dw_dbp_stubs.scm
    -unit scm
  } 
}\
