#!/bin/sh

function usage()
{
    echo ""
    echo "performance_archive.sh [-ac][-fpga][-report_html][-report_log][-ztime] [-suffix <archive_name_suffix> ] [-directory <directory_name> ]"
   echo ""
   echo "Consolidation files:"
   echo "1/ subsystems_phy_zcorebuild"
   echo "Corresponds to the exact netlist statistics (no estimaters) at the input of zCoreBuild. "
   echo "So no clock manipulation and no fast waveform capture ip cost."
   echo " "
   echo "2/ subsystems_AC_zcorebuild"
   echo "The statistics used for the partitioning. So after all logic optimization. "
   echo "Includes estimators for all the clock "
   echo "manipulation. Also addition weighting (REG and LUT) to account for Xilinx routing "
   echo "constraints and external memory controllers (ZRM). "
   echo " "
   echo "3/ subsystems_fpga_zcorebuild"
   echo "The output of zCoreBuild. Exact values for all clock manipulations but no weighting for "
   echo "Xilinx routing constraints, FWCs logic and external memory controllers."
   echo " "
   echo "4/ subsystems_pre_ise_zcorebuild"
   echo "The output of zNetgen just before the ISE. The most accurate in terms of real resource "
   echo "requirements but no weighting."
   echo " "
   echo "In addition there is also csv generated just before zTopBuild partitioning here:"
   echo "                zebu.work/tools/zTopBuild/csv/subsystems_ordered_by_norm"
}



function conso_csv()
{
    if which csv_util ; then 
        echo "ok"; 
        csv_util -in `find  work.*/tools/AC -name subsystems_ordered_by_norm_AC.csv`         -out subsystems_AC_zcorebuild_conso.csv
        csv_util -in `find  work.*/tools/zCoreBuild -name subsystems_ordered_by_norm.csv` -out subsystems_phy_zcorebuild_conso.csv
        csv_util -rename_top zebu_top 2 -in `find  work.*/tools/zCoreBuild -name "subsystems_ordered_by_norm_*_FPGA_ZCB.csv" ` -out subsystems_fpga_zcorebuild_conso.csv
        csv_util -rename_top zebu_top 3 -in `find  U*/M*/F*.Original  -name "subsystems_ordered_by_norm_design_ZN.csv" ` -out subsystems_pre_ise_conso.csv
    else 
        echo "*** " ; 
        echo "*** Cannot find csv_util utility, skipping conso-csv" ; 
        echo "*** " ; 
    fi
}

p_ac=0
p_ac=0
p_ac=0
p_ztime=0
p_ztime=0
p_report_html=0
p_report_html=0
p_report_log=0
p_report_log=0
p_fpga=0

do_suffix=0
suffix=""


do_directory=0
directory=""



for i in $*; do
   if [ $do_suffix == 1 ] ; then
       suffix=$i;
       do_suffix=0;
      continue;
   fi

   if [ $do_directory == 1 ] ; then
       directory=$i;
       do_directory=0;
      continue;
   fi

    if [ "$i" == "-help" ] ; then
             echo ""
             usage;
             exit 0;
    elif [ "$i" == "-ac" ] ; then
        p_ac=1
    elif [ "$i" == "-ac" ] ; then
        p_ac=1
    elif [ "$i" == "-ac" ] ; then
        p_ac=1
    elif [ "$i" == "-ztime" ] ; then
        p_ztime=1
    elif [ "$i" == "-ztime" ] ; then
        p_ztime=1
    elif [ "$i" == "-report_html" ] ; then
        p_report_html=1
    elif [ "$i" == "-report_html" ] ; then
        p_report_html=1
    elif [ "$i" == "-report_log" ] ; then
        p_report_log=1
    elif [ "$i" == "-report_log" ] ; then
        p_report_log=1
    elif [ "$i" == "-fpga" ] ; then
        p_fpga=1
    elif [ "$i" == "-suffix" ] ; then
        do_suffix=1;
    elif [ "$i" == "-directory" ] ; then
        do_directory=1;
    else
        echo ""
        echo "ERROR : unrecognized parameter : $i" ;
        echo ""
        usage;
        exit -1;
    fi
done;

archive_log="performance_archive.log"
file_list="performance_archive_file_list.txt"
archive_name="performance_archive.tgz"
if [ "$suffix" != "" ] ; then
archive_log="performance_archive"_$suffix.log
file_list="performance_archive_"$suffix"_file_list.txt";
archive_name="performance_archive_"$suffix.tgz;
fi
if [ "$directory" != "" ] ; then
archive_name=$directory"/performance_archive.tgz"
fi
if [ "$directory" != "" ]  && [ "$suffix" != "" ] ; then
archive_name=$directory"/performance_archive_"$suffix.tgz;
fi
echo $0 > $archive_log
echo "Conso. CSV..."
conso_csv >> $archive_log ;
echo "Starting archiving..."
if [ -e $file_list ]; then
    rm $file_list
fi
echo $file_list >> $file_list
echo zTopBuild.log | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report.log | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Detection_.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Summary_pr.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Multiple_i.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Summary.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Multi_inst.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Modules_wi.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_ZMem_resou.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Clock_repo.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Netlist_sp.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_report_log_large_sections.dir/*_Inter_part.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_AC_defcoremap.tcl | sed -e "s/\s/\n/g" >> $file_list
echo zTopBuild_AC_defmapfpga.tcl | sed -e "s/\s/\n/g" >> $file_list
echo subsystems_*.csv | sed -e "s/\s/\n/g" >> $file_list
echo tools/AC/csv/subsystems_*.csv | sed -e "s/\s/\n/g" >> $file_list
echo tools/zTopBuild/csv/subsystems_*.csv | sed -e "s/\s/\n/g" >> $file_list
echo tools/zTopClustering/zTopClustering_trace.gz | sed -e "s/\s/\n/g" >> $file_list
echo ztime_* | sed -e "s/\s/\n/g" >> $file_list
echo zPar.log | sed -e "s/\s/\n/g" >> $file_list
echo zTime.log | sed -e "s/\s/\n/g" >> $file_list
echo zTime_fpga.log | sed -e "s/\s/\n/g" >> $file_list
echo ztime_* | sed -e "s/\s/\n/g" >> $file_list
echo zTime.html | sed -e "s/\s/\n/g" >> $file_list
echo zTime_fpga.html | sed -e "s/\s/\n/g" >> $file_list
echo performance_archive.log | sed -e "s/\s/\n/g" >> $file_list
echo tools/zMetrics | sed -e "s/\s/\n/g" >> $file_list
echo zPar_stats | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild.log | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report.log | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_AC_defmapping.tcl | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*Detection_*.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*Multi_inst*.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*Modules_wi*.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_Instances_*.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*Modules_wi.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_SEC_2_17_Detection_.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_SEC_3_1_1_Splitted_n.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_Generated_.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_Summary_po.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_Defmaps_li.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_ZMEM_insta.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_ZMem_resou.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/zCoreBuild_report_log_large_sections.dir/*_BUFG_analy.log.gz | sed -e "s/\s/\n/g" >> $file_list
echo work.*/tools/AC/csv/subsystem_ac_estimate.csv | sed -e "s/\s/\n/g" >> $file_list
echo work.*/tools/AC/csv/subsystems_*.csv | sed -e "s/\s/\n/g" >> $file_list
echo work.*/tools/zCoreBuild/csv/subsystems_*.csv | sed -e "s/\s/\n/g" >> $file_list
echo work.*/tools/zCoreClustering/zCoreClustering_trace.gz | sed -e "s/\s/\n/g" >> $file_list
echo U*/M*/F*.Original/csv/subsystems_*.csv | sed -e "s/\s/\n/g" >> $file_list
echo work.*/tools/zMetrics | sed -e "s/\s/\n/g" >> $file_list

if [ $p_ac == 1 ] ; then
echo ztb_tg_remapped.edf.gz | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_ac == 1 ] ; then
echo zTopBuild_AC_*  | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_ac == 1 ] ; then
echo work.*/zCoreBuild_AC_interco.txt  | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_ztime == 1 ] ; then
echo tools/zTime | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_ztime == 1 ] ; then
echo work*/tools/zTime  | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_report_html == 1 ] ; then
echo zTopBuild_report.html | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_report_html == 1 ] ; then
echo zTopBuild_report_html_large_sections.dir | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_report_log == 1 ] ; then
echo zTopBuild_report.log | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_report_log == 1 ] ; then
echo zTopBuild_report_log_large_sections.dir | sed -e "s/\s/\n/g" >> $file_list
fi

if [ $p_fpga == 1 ] ; then
echo U*/M*/F*/compilation.log  | sed -e "s/\s/\n/g" >> $file_list
fi


tar zcf $archive_name  --files-from $file_list  &> $archive_log


echo ""


echo "Archive file name : $archive_name"


echo ""
