# \rm -rf xcui_Bundle_18.sdb && zFe compile_hdr.tcl script/Bundle_18_synp.tcl -log Bundle_18.log -zlog 1
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='design_Default_RTL_GroupBundle_18_Synthesis'
export ZCUI_TASK_CLASS='_Synthesis'
export ZCUI_PROFILER_CRC='9abbcff2'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
\rm -rf xcui_Bundle_18.sdb && zFe compile_hdr.tcl script/Bundle_18_synp.tcl -log Bundle_18.log -zlog 1
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
