# zPython $ZEBU_ROOT/etc/ztime/ZeBu_perf_report.py -i graphs/db_fpga_ztime_out_paths_fpga.csv -o ztime_performance_report_post_fpga.html
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_zPertagram_postFPGA'
export ZCUI_TASK_CLASS='zPertagram'
export ZCUI_PROFILER_CRC='e82bfcc8'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
zPython $ZEBU_ROOT/etc/ztime/ZeBu_perf_report.py -i graphs/db_fpga_ztime_out_paths_fpga.csv -o ztime_performance_report_post_fpga.html
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
