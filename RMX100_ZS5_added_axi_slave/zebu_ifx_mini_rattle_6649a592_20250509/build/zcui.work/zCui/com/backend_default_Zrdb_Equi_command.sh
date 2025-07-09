# zEquiGenerator -l backend_default_Zrdb_Equi.log -i tools/zDB/zTopBuild_equi.edf.gz
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_Zrdb_Equi'
export ZCUI_TASK_CLASS='Zrdb_Equi'
export ZCUI_PROFILER_CRC='1e1afb89'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
zSendMsg -msg "start:${HOSTNAME}"
zEquiGenerator -l backend_default_Zrdb_Equi.log -i tools/zDB/zTopBuild_equi.edf.gz
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
