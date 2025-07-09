# make FX=F01 LABEL=Original MONITORING=YES BACKENDNAME="/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/backend_default" PARAMETER_FILE="/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/fpga_parff_strategies.xcui" FPGA_LOCAL_DISK_COMP=NO FPGA_LOCAL_DISK_COMP_DIR=""
export VIVADO_ENABLE_SINGLE_MACHINE_MPF='0'
export VIVADO_ENABLE_MULTI_MACHINE_MPF='0'
export ZCUI_FPGA_DIR='F01.Original'
export ZCUI_FRACTAL_FLOW='0'
export ZCUI_ENABLE_MESSAGE_SYSTEM='0'
export ZEBU_COMPILATION_OBJECTIVE='PERFORMANCE'
export ZCUI_FPGA_FEATURE_TAGS='PDM|multistage|Vtx8'
export ZEBU_SDF_ANALYSIS='1'
export ZCUI_WORK_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work'
export ZCUI_TASK_NAME='backend_default_U0_M0_F01_Original'
export ZCUI_TASK_CLASS='IsePar'
export ZCUI_PROFILER_CRC='37102501'
export ZCUI_PROFILER_DIR='/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_14_18_51_33/prof'
zSendMsg -msg "start:${HOSTNAME}"
make FX=F01 LABEL=Original MONITORING=YES BACKENDNAME="/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/backend_default" PARAMETER_FILE="/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/fpga_parff_strategies.xcui" FPGA_LOCAL_DISK_COMP=NO FPGA_LOCAL_DISK_COMP_DIR=""
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
