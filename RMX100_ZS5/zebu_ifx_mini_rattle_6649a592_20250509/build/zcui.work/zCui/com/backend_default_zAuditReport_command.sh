# $ZEBU_ROOT/bin/zAudit -z .. --zebu_work backend_default report
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_zAuditReport'
export ZCUI_TASK_CLASS='zAuditReport'
export ZCUI_PROFILER_CRC='fc356012'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
$ZEBU_ROOT/bin/zAudit -z .. --zebu_work backend_default report
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
