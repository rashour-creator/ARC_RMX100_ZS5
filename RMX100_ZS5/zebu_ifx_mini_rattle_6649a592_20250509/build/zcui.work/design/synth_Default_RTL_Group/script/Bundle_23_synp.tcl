-comp_unit { 
  -top {
    -lib default
    -primary ZebuClockDetectFront_17
    -secondary ""
    -result_file edif/ZebuClockDetectFront_17/ZebuClockDetectFront_17.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary ZebuClockDetectFront_17
    -secondary ""
    -ver scm
    -input_file src/ZebuClockDetectFront_17.scm
    -unit scm
  } 
}\
-comp_unit { 
  -top {
    -lib default
    -primary mss_bus_switch_fifo_0001_0001
    -secondary ""
    -result_file edif/mss_bus_switch_fifo_0001_0001/mss_bus_switch_fifo_0001_0001.edf.gz
    -unit scm
  } 
  -dep {
    -kind top
    -lib default
    -primary mss_bus_switch_fifo_0001_0001
    -secondary ""
    -ver scm
    -input_file src/mss_bus_switch_fifo_0001_0001.scm
    -unit scm
  } 
}\
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
