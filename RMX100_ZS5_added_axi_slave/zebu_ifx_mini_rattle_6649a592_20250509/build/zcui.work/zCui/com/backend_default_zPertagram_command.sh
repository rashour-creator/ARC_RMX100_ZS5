# zPython $ZEBU_ROOT/etc/ztime/ZeBu_perf_report.py -i graphs/db_ztime_out_paths.csv -o ztime_performance_report_pre_fpga.html
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_zPertagram'
export ZCUI_TASK_CLASS='zPertagram'
export ZCUI_PROFILER_CRC='ec144851'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
zSendMsg -msg "start:${HOSTNAME}"
zPython $ZEBU_ROOT/etc/ztime/ZeBu_perf_report.py -i graphs/db_ztime_out_paths.csv -o ztime_performance_report_pre_fpga.html
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
