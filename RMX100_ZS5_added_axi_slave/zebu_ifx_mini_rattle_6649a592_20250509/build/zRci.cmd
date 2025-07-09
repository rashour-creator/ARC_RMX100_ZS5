#!/bin/bash -i 
  set -e              
  cd /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build             
  export GUI=0     
  export BDL=0     
  export PWR=0     
  export SKIP=0   
  export WAVES=0 
  export CMD='PSET 1 = performance_test_arr_8.out'   
  export XARGS='--postconnect "command source init_mem.cmd"'
  zRci --zebu-work /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zebu.work /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/scripts/zebu_runtime/zrci_xtor_lldb.tcl |& tee zRun.log
