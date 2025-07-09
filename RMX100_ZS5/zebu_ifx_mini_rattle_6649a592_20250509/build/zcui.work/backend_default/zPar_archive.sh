#!/bin/sh

debug_zcb=0
debug_zopt=0
RhinoDB=0
while echo $1 | grep -q ^-; do
    if [[ $1 == "-debug_zcb" ]] ; then
        debug_zcb=1
        shift
    elif [[ $1 == "-debug_zopt" ]] ; then
        debug_zopt=1
        shift
    elif [[ $1 == "-RhinoDB" ]] ; then
        RhinoDB=1
        shift
    else
        eval $( echo $1 | sed 's/^-//' )=$2
        shift
        shift
    fi
done
if [[ $debug_zcb -eq 1 ]] ; then
    echo "Data for zCoreBuild debugging will also be copied."
fi
if [[ "$work" != "" ]] ; then
    work="${work}/"
    mkdir ${work}
else
    work="./"
fi

if [[ ! -w "$work" ]] ; then
    echo "$work is not writable ,"
    echo "Please execute "
    echo "    zPar_archive.sh -work dir_name"
    exit
fi

\rm -rf ${work}zpar_archive_dir
\mkdir -p ${work}zpar_archive_dir/orig_zPar_logs
\cp -f zPar_zCui.tcl ${work}zpar_archive_dir
\cp -f zTime_zcui.tcl ${work}zpar_archive_dir
\cp -f zTime_fpga_zcui.tcl ${work}zpar_archive_dir
\cp -f zPar_target_conf.tcl ${work}zpar_archive_dir
\cp -f zPar.log ${work}zpar_archive_dir/orig_zPar_logs
if [[ -e "zTime.log" ]]
then
    \cp -f zTime.log ${work}zpar_archive_dir/orig_zPar_logs
fi
targetfiles=" gridjob_profiling_parameters.tcl /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/zpar/zPar_from_zCui.tcl zPar_cmds.tcl work.Part_0/zPar_cmds.tcl incremental_compile.tcl /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/zpar/zPar_script.tcl zPar_target_conf.tcl zPar_design_conf.tcl work.Part_0/zPar_design_conf.tcl work.Part_0/zPar_core_conf.tcl ../utf_generatefiles/zPar_config.tcl ../utf_generatefiles/new_zPar_config.tcl /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/ztime/common_eval_params.tcl /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/ztime/v8_eval_params.tcl /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/ztime/zs5_config.tcl ../utf_generatefiles/zTime_config.tcl ../utf_generatefiles/new_zTime_config.tcl "
targetfiles+=$(grep -o -E "/slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/.*\b" zPar_target_conf.tcl | tr '\n' ' ')
# If enabled, retrieve files needed for relaunching zCoreBuild.
if [[ $debug_zcb -eq 1 ]] ; then
    for core in ${work}work* ; do
        core=$(echo $core | sed "s|$work||g")
        \mkdir -p ${work}zpar_archive_dir/$core
        \cp -f ${work}$core/zCoreBuild_ztb.tcl ${work}zpar_archive_dir/$core
        for f in $(grep -o -E "\.\./.*\b" ${work}$core/zCoreBuild_ztb.tcl | tr '\n' ' ') ; do
            targetfiles+="$core/$f "
        done
    done
fi

##-------Correcting fileNames inside scripts
for target in $targetfiles
do
    target_fullname=`readlink -f $target`
    if [[ $target_fullname != "" ]] ; then
        \cp -L --parents $target_fullname ${work}zpar_archive_dir
        \chmod -R +rwx ${work}zpar_archive_dir
    else
        echo "[Warning] $target is missing"
    fi
done

for target in $targetfiles
do
    for file in $(grep -lR $target ${work}zpar_archive_dir)
    do
        sed -e "s|\([{ \"]\)$target|\1zpar_archive_dir/`readlink -f $target`|ig" $file  > ${work}tmpFile.archive.tmp
        \mv -f ${work}tmpFile.archive.tmp $file;
    done
    if [[ $debug_zcb -eq 1 ]] ; then
        if [[ $target =~ work.* ]] ; then
            core=$(echo $target | grep -o "work[^/]*")
            if [[ -d ${work}zpar_archive_dir/$core ]] ; then
                original=$(echo $target | sed 's/work[^/]*\///g')
                for file in $(grep -lR $original ${work}zpar_archive_dir/$core) ; do
                    sed -e "s|\([{ \"]\)$original|\1../zpar_archive_dir/`readlink -f $target`|ig" $file > ${work}tmpFile.archive.tmp
                    \mv -f ${work}tmpFile.archive.tmp $file;
                done
            fi
        fi
    fi
done

tar hcvf ${work}zPar.tar \
 --exclude 'U*M*F*.edf.gz*' \
 --exclude 'design_fpga' \
 --exclude '*.zdb' \
 --exclude zPar.tgz \
 --exclude zPar_zCui.tcl \
 --exclude zTime_zcui.tcl \
 --exclude zTime_fpga_zcui.tcl \
 --exclude zPar_target_conf.tcl \
 --exclude 'mem_port_*.edf.gz*' \
 --exclude edif/'*_step*.gz*' \
 --exclude work*/edif/'*_step*.gz*'  \
zPar* \
work*/zPar* \
edif \
work*/edif \
work*/U*_M*_F*/*.db \
work*/U*_M*_F*/*.zti \
work*/U*_M*_F*/*.loc \
zPar_stats \
U*/M*/F*/design.clkloop \
U*/M*/IF/design.clkloop \
U*/M*/*/timing_path_extra.rpt \
U*/M*/*/fpga_timing.zti \
U*/M*/*/zFpgaTiming.zti \
U*/M*/*/*.bindata \
U*/M*/*/global_time.edf.gz \
U*/M*/*/zTime_clock_domain.cds \
clkLoopMap.lst \
ztime*.html \
zTime*.html \
all_cabling.tcl \
connector_xrefs.tcl \
zPar_archive.txt \
options.db \
\
work*/tools/zTime/* \
zTime* \
ztime* \
/slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/sys/ZS5/edifs/zs5_vup_12c_19_v2.edf.gz \
edif/zebu_top.edf.gz \
ztb_tg_remapped.edf.gz \


TOOLS_PATH="./"
if [[ -f "tools.tgz" ]]; then
    TOOLS_PATH="${work}zpar_archive_dir/"
    tar zxvf tools.tgz -C ${work}zpar_archive_dir \
    tools/zPar \
    tools/zMetrics \
    tools/zRTB_FE/dut_io_zpar.edf.gz \
    tools/zRTB_FE/zRTB_FE_mrtb.zti \
    tools/zRTB_FE/global_rtb_time.edf.gz \
    tools/zTopBuild/hub.config \
    tools/zTopBuild/mgt.graph \
    tools/zTopBuild/hub2fpga \
    tools/zTopBuild/SpeedAdapter.xref \
    tools/zTime/ \
    tools/zDB/zTopBuild_equi.edf.gz
fi

tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zPar
tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zMetrics
tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zRTB_FE/dut_io_zpar.edf.gz
tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zRTB_FE/zRTB_FE_mrtb.zti
tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zRTB_FE/global_rtb_time.edf.gz

if [[ -f "${TOOLS_PATH}tools/zTopBuild/hub.config" ]]; then
    tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zTopBuild/hub.config
fi

if [[ -f "${TOOLS_PATH}tools/zTopBuild/mgt.graph" ]]; then
    tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zTopBuild/mgt.graph
fi

if [[ -f "${TOOLS_PATH}tools/zTopBuild/hub2fpga" ]]; then
    tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zTopBuild/hub2fpga
fi

if [[ -f "${TOOLS_PATH}tools/zTopBuild/SpeedAdapter.xref" ]]; then
    tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zTopBuild/SpeedAdapter.xref
fi
tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/zTime/

if [[ $debug_zopt -eq 1 ]] ; then
    tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar tools/to_zNetgen/
fi
if [[ $RhinoDB -eq 1 ]] ; then
    tar --update --directory=${TOOLS_PATH} --file=${work}zPar.tar  tools/zDB/zTopBuild_equi.edf.gz
fi
if [[ "$TOOLS_PATH" == "${work}zpar_archive_dir/" ]]; then
    \rm -rf ${TOOLS_PATH}/tools
fi
tar --update --directory=${work} --file=${work}zPar.tar zpar_archive_dir

tar --update --directory=${work}zpar_archive_dir --file=${work}zPar.tar zPar_zCui.tcl
tar --update --directory=${work}zpar_archive_dir --file=${work}zPar.tar zTime_zcui.tcl
tar --update --directory=${work}zpar_archive_dir --file=${work}zPar.tar zTime_fpga_zcui.tcl
tar --update --directory=${work}zpar_archive_dir --file=${work}zPar.tar zPar_target_conf.tcl

if [[ $debug_zcb -eq 1 ]] ; then
    for core in ${work}work* ; do
        tar --update --directory=${work}zpar_archive_dir --file=${work}zPar.tar $core/zCoreBuild_ztb.tcl
    done
fi

if [[ $debug_zopt -eq 1 ]] ; then
    tar hrvf ${work}zPar.tar \
    work*/tools/to_zNetgen/* \
    work*/edif/U*M*F*edf.gz

    tar rvf ${work}zPar.tar U*/M*/F*.src/*
fi
if [[ $RhinoDB -eq 1 ]] ; then
    tar hrvf ${work}zPar.tar \
    RTLDB/RhinoDb
    if [[ -d HydraDB/eid2names.bin && -d HydraDB/eid2label.bin && -d hierview.edf.gz ]]; then
        tar hrvf ${work}zPar.tar \
        HydraDB/eid2names.bin \
        HydraDB/eid2label.bin \
        hierview.edf.gz
    fi
    if [[ -d HydraDB/eid2master.bin ]]; then
        tar hrvf ${work}zPar.tar \
        HydraDB/eid2master.bin
    fi
    if [[ -d HydraDB/beEid2hierPath.bin ]]; then
        tar hrvf ${work}zPar.tar \
        HydraDB/beEid2hierPath.bin
    fi
fi

if [[ -f $ZEBU_ROOT/bin/zMuDbArchiver ]] ; then
    zpar_work_dir=`pwd`
    cd ${work}
    mkdir MuDb_temp
    $ZEBU_ROOT/bin/zMuDbArchiver --zebu-work ${zpar_work_dir} --output MuDb_temp --zPar
    cd MuDb_temp
    tar hrvf ../zPar.tar MuDb
    cd ${zpar_work_dir}
else
    tar hrvf ${work}zPar.tar \
    MuDb
fi

gzip ${work}zPar.tar
mv ${work}zPar.tar.gz ${work}zPar.tgz
\rm -rf ${work}zpar_archive_dir
\rm -rf ${work}MuDb_temp
echo "zPar archive is generated successfully at ${work}zPar.tgz"
