# tracean3.py --top-delay=5 --syn-details=5 --pr-summary-by-time=5 --hhmm --local-time=detect --show-memory --fix-graph --cpu-time /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work |tee zCui/log/profiled_compilations_ZTopBuildAnalyzer.log
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_Intermediate_Profiling_Results_Analyzer_ZTopBuildAnalyzer'
export ZCUI_TASK_CLASS='Intermediate_Profiling_Results_Analyzer'
export ZCUI_PROFILER_CRC='4ddac787'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
tracean3.py --top-delay=5 --syn-details=5 --pr-summary-by-time=5 --hhmm --local-time=detect --show-memory --fix-graph --cpu-time /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work |tee zCui/log/profiled_compilations_ZTopBuildAnalyzer.log
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
