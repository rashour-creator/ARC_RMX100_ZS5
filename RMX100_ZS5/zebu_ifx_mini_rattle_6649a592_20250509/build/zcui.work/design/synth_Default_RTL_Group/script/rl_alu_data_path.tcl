-comp_unit { 
  -top {
    -lib default
    -primary rl_alu_data_path
    -secondary ""
    -result_file edif/rl_alu_data_path/rl_alu_data_path.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary rl_alu_data_path
    -secondary ""
    -ver scm
    -input_file src/rl_alu_data_path.scm
    -unit scm
  } 
  -dep {
    -kind middle
    -lib default
    -primary rl_logic_unit
    -secondary ""
    -ver scm
    -input_file src/rl_logic_unit.scm
    -unit scm
  } 
}\
