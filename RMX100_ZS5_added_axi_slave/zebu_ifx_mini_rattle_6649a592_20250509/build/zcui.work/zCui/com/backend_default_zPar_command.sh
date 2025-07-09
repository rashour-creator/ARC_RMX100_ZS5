# zPar zPar_zCui.tcl
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_zPar'
export ZCUI_TASK_CLASS='zPar'
export ZCUI_PROFILER_CRC='ab7d638f'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
unset ZEBU_INTER_FPGA_CLK_ON
zSendMsg -msg "start:${HOSTNAME}"
zPar zPar_zCui.tcl
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
