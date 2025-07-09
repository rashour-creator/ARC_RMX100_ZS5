# \rm -rf xcui_Bundle_29.sdb && zFe compile_hdr.tcl script/Bundle_29_synp.tcl -log Bundle_29.log -zlog 1
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='design_Default_RTL_GroupBundle_29_Synthesis'
export ZCUI_TASK_CLASS='_Synthesis'
export ZCUI_PROFILER_CRC='19717648'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
zSendMsg -msg "start:${HOSTNAME}"
\rm -rf xcui_Bundle_29.sdb && zFe compile_hdr.tcl script/Bundle_29_synp.tcl -log Bundle_29.log -zlog 1
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
