# zPostFrontend optionsdb_be.tcl
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_OptionsDbProc'
export ZCUI_TASK_CLASS='OptionsDbProc'
export ZCUI_PROFILER_CRC='f1c8c2f4'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
zSendMsg -msg "start:${HOSTNAME}"
zPostFrontend optionsdb_be.tcl
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
