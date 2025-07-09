# /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/bin/vcs_cmd_wrapper.sh /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/vcs_splitter /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui_vcs_cmd.csh
export ZEBU_VCS_CONFIG_FILE='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/vcs_splitter/vcs_splitter_config_file'
export SNPS_UTF_ENFORCE_ENABLED_COMMAND='set_perf_flow:ztopbuild'
export SNPS_VCS_INTERNAL_UTF_TRAN_MODE='1'
export SNPS_ZEBU_ADDITIONAL_DEFAULT_COMMANDS='/slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/utf/default_commands.utf'
export SNPS_ZEBU_TARGET_CAPABILITIES='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/target_capabilities.utf'
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='vcs_splitter_VCS_Task_Builder'
export ZCUI_TASK_CLASS='VCS_Task_Builder'
export ZCUI_PROFILER_CRC='31148fa5'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
zSendMsg -msg "start:${HOSTNAME}"
/slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/bin/vcs_cmd_wrapper.sh /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/vcs_splitter /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui_vcs_cmd.csh
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
