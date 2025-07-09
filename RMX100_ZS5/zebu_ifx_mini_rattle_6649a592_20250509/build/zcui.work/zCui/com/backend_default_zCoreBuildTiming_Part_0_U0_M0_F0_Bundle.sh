exec > /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/./zCui/log/backend_default_zCoreBuildTiming_Part_0_U0_M0_F0.log
exec 2>&1
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_zCoreBuildTiming_Part_0_U0_M0_F0'
export ZCUI_TASK_CLASS='zCoreBuildTiming'
export ZCUI_PROFILER_CRC='c4e4b60d'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
export ZCUI_MESSAGES_CONFIG='task=backend_default_zCoreBuildTiming_Part_0_U0_M0_F0|pid=1069029|index=0|tcphost=us01odcvde23280.internal.synopsys.com|tcpport=5201|retry=10|delay=500|blocking=1|nmap=0'
zTiNa -zebuwork ../.. timing_analysis.tcl
exitcode=$?
echo "Bundle script command exit code is '${exitcode}'"
exit ${exitcode}

