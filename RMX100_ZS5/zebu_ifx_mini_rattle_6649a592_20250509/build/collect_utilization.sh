#!/bin/bash -e

#######################
# Usage     : bash collect_utilization.sh $PATH
# Version   : 1.0
#######################

### Path/para define ###
TARGET_PATH=`realpath ${1}`
RPT_NAME="usage_report"
FREQ_FILE=${TARGET_PATH}/scripts/zebu_runtime/designFeatures
PRJ_FILE=${TARGET_PATH}/scripts/zebu_scripts/project.utf
if [ -d "${TARGET_PATH}/backend_default" ]; then
    echo "This is a compressed project."
    MAX_FREQ_FILE=${TARGET_PATH}/backend_default/zTime_fpga.log
    BLD_LOG=${TARGET_PATH}/backend_default/zTopBuild.log
    BIT_PATH=${TARGET_PATH}/backend_default/
elif [ -d "${TARGET_PATH}/zcui.work" ]; then
    echo "This is a uncompressed project."
    MAX_FREQ_FILE=${TARGET_PATH}/zcui.work/zebu.work/zTime_fpga.log
    BLD_LOG=${TARGET_PATH}/zcui.work/zebu.work/zTopBuild.log
    BIT_PATH=${TARGET_PATH}/zcui.work/backend_default/
else
    echo "Please check your given path! Exit now."
    exit
fi
### End of path/para define ###

### Target acquisition ###
DRIVER_CLK=`grep -w '$driverClk.Frequency' ${FREQ_FILE} | grep -v '#'`
MAX_DRIVER_CLK=`grep -w '$driverClk.Frequency' ${MAX_FREQ_FILE} | cut -d ':' -f2`
LUT_FILLING_RATE=`grep -w 'cluster_constraint' ${PRJ_FILE} | grep -v '#'`
DSP_FILLING_RATE=`grep -w 'clustering' ${PRJ_FILE} | grep -v '#'`
USAGE=`grep -w "logic_optimization" ${BLD_LOG} | grep lut | cut -d ":" -f3 | sed "s/^[ ]*/\n\t/g" | sed "s/ /\n\t/g"`
cd ${BIT_PATH}
FPGA_COUNT=`find -name "*.bit" | wc -l`
### End of target acquisition ###

### Enter project path
cd ${TARGET_PATH}

### Report writing ###
echo "Project path is ${TARGET_PATH}" |& tee ${RPT_NAME}
echo "Actual driver clock is ${DRIVER_CLK}" |& tee -a ${RPT_NAME}
echo "Max driver clock is ${MAX_DRIVER_CLK}" |& tee -a ${RPT_NAME}
echo "LUT filling rate is ${LUT_FILLING_RATE}" |& tee -a ${RPT_NAME}
echo "DSP filling rate is ${DSP_FILLING_RATE}" |& tee -a ${RPT_NAME}
echo "Usage: ${USAGE}" |& tee -a ${RPT_NAME}
echo "${FPGA_COUNT} FPGAs have been used." |& tee -a ${RPT_NAME}
### End of report writing ###

echo -e "\nAcquisition is Done, you can check the report at ${TARGET_PATH}/${RPT_NAME}"


