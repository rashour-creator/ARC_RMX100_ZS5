# zFpgaTiming ${ZEBU_ROOT}/etc/zfpgatiming/zFpgaTiming.tcl
export SNPS_ZCUI_BACKENDDIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/backend_default'
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_U0_M0_F00_zFpgaTiming'
export ZCUI_TASK_CLASS='zFpgaTiming'
export ZCUI_PROFILER_CRC='dbe10638'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
zFpgaTiming ${ZEBU_ROOT}/etc/zfpgatiming/zFpgaTiming.tcl &> /dev/null
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
