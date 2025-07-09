#VCS_ZEBU_PROBE_FORCE_NEWFW zTopBuild commands - begin
probe_signals -rtlname { {zebu_top.rst_a} }
#VCS_ZEBU_PROBE_FORCE_NEWFW zTopBuild commands - end
source /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/HWTop_port_probes.tcl
source /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/ztb_rtl_clock_config.tcl
source /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/zcov_protect.tcl
source /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/uc_xtor.tcl
source /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/ztb_config.tcl
source /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/cclock_map.tcl
encrypted_commands_tcl /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/uc_nodve_ztb.tcl
zinject -rtlname {zebu_top.zebu_disable}
zinject -rtlname {zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.zebu_disable}
