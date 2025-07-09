-comp_unit { 
  -top {
    -lib default
    -primary rl_sfty_csr
    -secondary ""
    -result_file edif/rl_sfty_csr/rl_sfty_csr.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_sfty_csr
    -secondary ""
    -ver scm
    -input_file src/rl_sfty_csr.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary DWbb_bcm00_maj
    -secondary ""
    -ver scm
    -input_file src/DWbb_bcm00_maj.scm
    -unit scm
  } 
}\
