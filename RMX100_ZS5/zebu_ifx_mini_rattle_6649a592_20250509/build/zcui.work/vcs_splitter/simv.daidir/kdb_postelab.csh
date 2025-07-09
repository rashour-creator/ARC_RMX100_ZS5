#!/bin/csh -f

if ( `pwd` != "/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build" ) then
  echo "Warning: Working directory is changed."
  echo "Executing the postelab script in the same working directory is recommended."
  echo "    Previous path: /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build"
  echo "    Current path: `pwd`"
  echo ""
endif

cd /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build
/bin/sh -f /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/vcs_splitter/simv.daidir/.elabcomCmd

set ELABCOM_STATUS=0;
set CONTENT=`cat /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/vcs_splitter/simv.daidir/.elabcomReport`;
if ( `echo ${CONTENT} | grep -w "Success" ` != 0 ) then
    set VERDI_SUM_MSG="Verdi KDB elaboration done and the database successfully generated"
else if ( `echo ${CONTENT} | grep -w "Fail" ` != 0 ) then
    set VERDI_SUM_MSG="Verdi KDB elaboration done and the database not generated"
else
    set VERDI_SUM_MSG="Verdi KDB elaboration is skipped because design is not changed"
    set ELABCOM_STATUS=1;
endif
echo -n ${VERDI_SUM_MSG}
set ELABCOM_LOG=/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/vcs_splitter/simv.daidir/elabcomLog/compiler.log
if ( ${ELABCOM_STATUS} == 0 && -e ${ELABCOM_LOG} ) then
    set elabErrWarn=`grep "error.*warning" ${ELABCOM_LOG} | sed "s/[\t ][\t ]*/ /g" | sed "s/Total //g"`
    if ( "${elabErrWarn}" == "" ) then
        echo "."
    else
        echo ": ${elabErrWarn}"
    endif
    if ( `grep "[[:space:]]0 error" ${ELABCOM_LOG}` == "" ) then
        echo "Please look at this Verdi elaboration log file for details: ${ELABCOM_LOG}"
    endif
endif
set ELABCOM_CRASH_TAG=/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/vcs_splitter/simv.daidir/.elabcom_crash_tag
if (-e ${ELABCOM_CRASH_TAG}) then
    echo "elabcom process is not finished successfully"
    exit 50;
endif
