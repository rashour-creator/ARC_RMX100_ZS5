# zPython --use-local 1 ${ZEBU_ROOT}/etc/scripts/fpga_multi_bin_wrapper.py . 6 1 1
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_FpgaMultiBinPredictor'
export ZCUI_TASK_CLASS='FpgaMultiBinPredictor'
export ZCUI_PROFILER_CRC='36a49a79'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
zSendMsg -msg "start:${HOSTNAME}"
zPython --use-local 1 ${ZEBU_ROOT}/etc/scripts/fpga_multi_bin_wrapper.py . 6 1 1
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
