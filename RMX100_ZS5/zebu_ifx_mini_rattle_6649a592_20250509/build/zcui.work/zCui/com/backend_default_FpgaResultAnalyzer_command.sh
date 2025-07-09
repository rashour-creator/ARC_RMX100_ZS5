# $ZEBU_ROOT/bin/postFpgaAnalyzer ZS5
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_FpgaResultAnalyzer'
export ZCUI_TASK_CLASS='FpgaResultAnalyzer'
export ZCUI_PROFILER_CRC='fadf27a1'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
$ZEBU_ROOT/bin/postFpgaAnalyzer ZS5
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
