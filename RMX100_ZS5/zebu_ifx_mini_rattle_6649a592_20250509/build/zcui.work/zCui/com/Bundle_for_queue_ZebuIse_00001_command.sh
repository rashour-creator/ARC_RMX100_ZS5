# zCuiBundle --bucket ZebuIse --profdir '/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof' --release-timeout 30 --query-dt 1
zSendMsg -msg "start:${HOSTNAME}"
zCuiBundle --bucket ZebuIse --profdir '/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zCui/backup/multibackend_25_5_13_18_25_38/prof' --release-timeout 30 --query-dt 1
exitcode=$?
echo "command exit code is '${exitcode}'"
zSendMsg -msg "end:$exitcode"
exit ${exitcode}
