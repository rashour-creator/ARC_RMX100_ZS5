#written by FrontEndBackEndLink
set is_mip_flow false
set backend_default_dir ./
set hydra_from_default true
set ipname {zebu_top}
source gridjob_profiling_parameters.tcl
source $env(ZEBU_ROOT)/etc/ztopbuild/zTopBuild_from_zcui.tcl
#netlist inputs
source {edifListScript.tcl}
append_href_file {../design/synth_Default_RTL_Group/zconnectnew.be.script}
set_top {zebu_top}
set_prepare_netlist_file {../utf_generatefiles/zTopBuild_netlist_config.tcl}
#environnement inputs
source {/remote/sdgzebu_system_dir/CONFIG/ZSE/zs5_4s.zs_0170/config/zse_configuration.tcl}
#clustering inputs
cluster set -max_fill_lut6 20
cluster set -max_fill_type safe -dsp 40 -bram 50 -uram 30 -ramlut 25 -reg 15 -lut 40 -fwc_ip 80 -fwc_bit 15 -qiwc_bit 50
cluster set -max_fill_type standard -dsp 60 -bram 60 -uram 40 -ramlut 25 -reg 22 -lut 50 -fwc_ip 80 -fwc_bit 30 -qiwc_bit 60
cluster set -max_fill_type aggressive -dsp 90 -bram 90 -uram 60 -ramlut 30 -reg 30 -lut 55 -fwc_ip 80 -fwc_bit 35 -qiwc_bit 70
cluster set -mode=customized
cluster auto
cluster set -max_fill_default standard
cluster set -max_fill_dsp 60
cluster set -max_fill_bram 60
cluster set -max_fill_uram 40
cluster set -max_fill_ramlut 25
cluster set -max_fill_reg 22
cluster set -max_fill_lut 50
cluster set -max_fill_fwc_ip 80
cluster set -max_fill_fwc_bit 30
cluster set -max_fill_qiwc_bit 60
DOP_enable_adaptative_filling_rate true
# clock handling inputs
set_clock_handling_clock_counter false
set_clock_handling_fetch_mode true
set_clock_handling_skew_offset true
set_clock_handling_skew_offset_mode synchronous
set_clock_handling_localize_clock_core true
set_clock_handling_localize_clock true
set_clock_handling_glitch_mode {filter_glitches}
set_clock_localization_mode
# debugging inputs
set_manipulate_bram_for_sw_rw false
set_dyn_probe_top true
# clock declaration
# SystemVerilog assertion inputs
enable zrm_use_16_value_latency
#UC mode
config_uc_mode {uc_no_zfe}
#Offline debugger
zoffline_debug -enable yes -probe_outputs yes
#Accessibility
#RTL DB
rtlDB -path RTLDB
update_bufg_info
set perfFlowCommand [list]
#Additional Command File
source {../utf_generatefiles/zTopBuild_config.tcl}
foreach cmd $perfFlowCommand {
    puts "perf flow command: $cmd"
    eval $cmd
}
source {incremental_compile.tcl}
