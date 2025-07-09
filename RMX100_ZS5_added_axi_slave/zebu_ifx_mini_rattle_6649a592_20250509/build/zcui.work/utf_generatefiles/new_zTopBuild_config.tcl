# target 
disable ztime_uses_rtl_names
enable advanced_incremental_mode
set_hydra -enable yes
set_perf_flow_patch 2021.09
set_perf_flow_patch_list {2020.03-LCA 2020.03-SP1-1-LCA 2021.09 2021.09-LCA}
set_perf_flow_internal flow1
zforce -mode {dynamic} -object_not_found {fatal} -rtlname {{zebu_top.rst_a}} -sync_enable
zforce -mode {dynamic} -object_not_found {warning} -rtlname {{zebu_top.core_chip_dut.i_ext_personality_mode}} -sync_enable
zforce -mode {dynamic} -object_not_found {warning} -rtlname {{zebu_top.core_chip_dut.icore_sys.i_ext_personality_mode}} -sync_enable
run_manager -number_of_instances 3
cluster_constraint_adv set_max_fill -lut 30
default_reg_init 0 

set_fast_waveform_capture -relocate yes
dump_stats -logic_optimization
enable zrm_performance_mode
compile_objective_internal  Performance
set_logic_opt -drop_optimizable_waveform_capture yes
