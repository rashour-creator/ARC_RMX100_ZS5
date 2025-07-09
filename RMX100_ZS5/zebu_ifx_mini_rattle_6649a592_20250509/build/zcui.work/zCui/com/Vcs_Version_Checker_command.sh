# checkVcsVersion.sh
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='Vcs_Version_Checker'
export ZCUI_TASK_CLASS='Vcs_Version_Checker'
export ZCUI_PROFILER_CRC='14aec18e'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
checkVcsVersion.sh
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
