# make FX=F00 LABEL=Original MONITORING=YES BACKENDNAME="/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/backend_default" PARAMETER_FILE="/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/fpga_parff_strategies.xcui" FPGA_LOCAL_DISK_COMP=NO FPGA_LOCAL_DISK_COMP_DIR=""
export VIVADO_ENABLE_SINGLE_MACHINE_MPF='0'
export VIVADO_ENABLE_MULTI_MACHINE_MPF='0'
export ZCUI_FPGA_DIR='F00.Original'
export ZCUI_FRACTAL_FLOW='0'
export ZCUI_ENABLE_MESSAGE_SYSTEM='0'
export ZEBU_COMPILATION_OBJECTIVE='PERFORMANCE'
export ZCUI_FPGA_FEATURE_TAGS='PDM|multistage|Vtx8'
export ZEBU_SDF_ANALYSIS='1'
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_U0_M0_F00_Original'
export ZCUI_TASK_CLASS='IsePar'
export ZCUI_PROFILER_CRC='9c41987b'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof'
zSendMsg -msg "start:${HOSTNAME}"
make FX=F00 LABEL=Original MONITORING=YES BACKENDNAME="/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/backend_default" PARAMETER_FILE="/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/fpga_parff_strategies.xcui" FPGA_LOCAL_DISK_COMP=NO FPGA_LOCAL_DISK_COMP_DIR=""
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
