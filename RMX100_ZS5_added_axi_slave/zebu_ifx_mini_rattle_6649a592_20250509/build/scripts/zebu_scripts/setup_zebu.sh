# Get script path
script_path=`readlink -f $BASH_SOURCE`

# Get siteid
SITEID=`/usr/local/bin/siteid | xargs`

# Global modules
source /global/etc/modules.sh
if [ "$SITEID" == "de02" ]; then
  module use -a /tmp
fi
module unload gmake zebu zebu_vs vcsmx vcs verdi mwdt gcc
if [ "$SITEID" == "us01" ]; then
source /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/zebu_env.sh
elif [ "$SITEID" == "eudc" ]; then
source /remote/eudcsgnfs00039/arc_fpga/lianghao/B4/zebu/S-2021.09-2-TZ-20240507_Full64/zebu_env.sh 
fi
module rm   zebu_vs ;# default zebu_vs/2020.12 not supported
module load zebu_vs/2023.03-SP1
module load gmake/3.82
module load mwdt
module load architect
module load syn/2020.09-SP5-1
module load pt/2020.09-SP5-1
module load fc/2020.09-SP6
module load spyglass
module load grd/dw
module load python/3.6.3
module load gcc/9.2.0 ;#(or higher) for TB compilation


# ZeBu paths
if [ "$SITEID" == "us01" ]; then
  export LD_LIBRARY_PATH=/depot/qsc/QSCR/GCC/lib:${LD_LIBRARY_PATH}:${ZEBU_IP_ROOT}/lib
  export ZEBU_SYSTEM_DIR=/remote/vginterfaces1/zebu_system_dir/CONFIG.TD/ZSE/zs5_4s.zs_0170
  # include server specific settings: REMOTE_ZEBU_HOST, ZEBU_PHYSICAL_LOCATION, etc..
  file=/fpgafarm/etc/zebu.sh
  if [[ -f "$file" ]]; then
      source $file
  else
      echo "cannot find $file at `uname -n`"
      echo "the default zebu parameters will be used"
  fi
elif [ "$SITEID" == "eudc" ]; then
  export LD_LIBRARY_PATH=/depot/qsc/QSCR/GCC/lib:$LD_LIBRARY_PATH\:$ZEBU_IP_ROOT/lib
  #setenv ZEBU_SYSTEM_DIR /opt/zs5_1U_2024_12_08/
  # include server specific settings: REMOTE_ZEBU_HOST, ZEBU_PHYSICAL_LOCATION, etc..
  file=/fpgafarm/etc/zebu.sh
  if [[ -f "$file" ]]; then
      source $file
  else
      echo "cannot find $file at `uname -n`"
      echo "the default zebu parameters will be used"    
  fi
elif [ "$SITEID" == "de02" ]; then
  export LD_LIBRARY_PATH=/depot/qsc/QSCR/GCC/lib\:$LD_LIBRARY_PATH\:$ZEBU_IP_ROOT/lib
  export ZEBU_SYSTEM_DIR=/slowfs/de02dwt2p113/zebu/zebu_config/de02arcssv-zs3/
  export REMOTE_ZEBU_HOST=de02arcssv-zs3-01
  export REMOTE_ZEBU_SETUP=$script_path
else
  echo "ZeBu machine in US01, EUDC and DE02 only"
  exit 1
fi

# ZeBu defines
export SUBMITCMDSH="bsub -Is -app comp_zebucae -Jd zebu_compile"
#export SUBMITCMDSH="bsub -app bnormal -K -R "select[os_version=CS7.0]" -R "span[hosts=1]" -n 4 -R "rusage[mem=60G]" -M 60G"
export ZEBU_ACTIVATE_EMU_QUEUE=TRUE ;# enable queue for multiple user
export VIVADO_ENABLE_MULTITHREADING=6 ;# speed up synthesis
export ZEBU_ENABLE_DDR_DMA=true ;# speed up fpga loading -> 2020.03-1
export ZEBU_SERIALIZED_ZFPGATIMING_BACK_ANNOTATION=1 ;# report inter FPGA delays -> 2020.03-SP1

# zSimzilla defines
export ZEBU_SIMZILLA_VIRTUAL_SLICING=1 ;# speed up ZTDB expansion with zSimzilla -> 2018.09-SP1-2
export SNPS_RHINODB_INTERNAL_DV2ZXF_ENABLE=1 ;# limit scope of zSimzilla to dumpvars -> 2018.09-SP1-2
export ZEBU_DEBUG_USE_AUTO_ZXF=1 ;# limit scope of zSimzilla to dumpvars -> 2018.09-SP1-2
export ZEBU_ENABLE_NEW_ZTDB_RB=1 ;# faster Simzilla -> 2020.03-SP1
export ZEBU_DEBUG_DYN_GRAPH_LOADING=1 ;# enable zSimzilla for Interactive Waveform Expansion -> 2020.03-1
export ZEBU_DEBUG_USE_SIMZILLA=1 ;# enable zSimzilla for Interactive Waveform Expansion -> 2020.03-1
export ZEBU_DEBUG_USE_DFS=1 ;# enable zSimzilla for Interactive Waveform Expansion -> 2020.03-1
#export ZEBU_DEBUG_ZWD_PLUS_R=1 ;# enable new zwd format -> 2020.03-SP1
