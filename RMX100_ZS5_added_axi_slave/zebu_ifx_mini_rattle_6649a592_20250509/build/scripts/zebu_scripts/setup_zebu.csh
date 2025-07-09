# Get script path
set script_path = `ls -l /proc/$$/fd | grep -oE '/.*setup_zebu.*'`
echo "Sourcing: $script_path"

# Get siteid
setenv SITEID `/usr/local/bin/siteid | xargs`

# Global modules
if ( "$SITEID" == "de02") then
  module use -a /tmp
endif
module unload gmake zebu zebu_vs vcsmx vcs verdi mwdt gcc
if ( "$SITEID" == "us01") then
source /u/product/patches/ZEBU/VCS2021.09.2.ZEBU.B4/03082024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240803_Full64/zebu_env.csh
#source /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/zebu_env.csh
module load lsf/us01_sgdw
else
if ( "$SITEID" == "eudc") then
source /remote/eudcsgnfs00039/arc_fpga/lianghao/B4/zebu/S-2021.09-2-TZ-20240507_Full64/zebu_env.csh
module load lsf/eudc_sgall
endif
endif
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
if ( "$SITEID" == "us01") then
  setenv LD_LIBRARY_PATH /depot/qsc/QSCR/GCC/lib\:$LD_LIBRARY_PATH\:$ZEBU_IP_ROOT/lib
  setenv ZEBU_SYSTEM_DIR /slowfs/us01dwt2p863/zebu/zebu_config/us01arcssv-zs4-2u/
  # include server specific settings: REMOTE_ZEBU_HOST, ZEBU_PHYSICAL_LOCATION, etc..
  set file=/fpgafarm/etc/zebu.csh
  if ( -f $file ) then
      source $file
  else
      echo "cannot find $file at `uname -n`"
      echo "the default zebu parameters will be used"    
  endif  
else
if ( "$SITEID" == "eudc") then
  setenv LD_LIBRARY_PATH /depot/qsc/QSCR/GCC/lib\:$LD_LIBRARY_PATH\:$ZEBU_IP_ROOT/lib
  #setenv ZEBU_SYSTEM_DIR /opt/zs5_1U_2024_12_08/
  # include server specific settings: REMOTE_ZEBU_HOST, ZEBU_PHYSICAL_LOCATION, etc..
  set file=/fpgafarm/etc/zebu.csh
  if ( -f $file ) then
      source $file
  else
      echo "cannot find $file at `uname -n`"
      echo "the default zebu parameters will be used"    
  endif  
else
if ( "$SITEID" == "de02") then
  setenv LD_LIBRARY_PATH /depot/qsc/QSCR/GCC/lib\:$LD_LIBRARY_PATH\:$ZEBU_IP_ROOT/lib
  setenv ZEBU_SYSTEM_DIR /slowfs/de02dwt2p113/zebu/zebu_config/de02arcssv-zs3/
  if (`uname -n` != "de02arcssv-zs3-01") then
    setenv REMOTE_ZEBU_HOST de02arcssv-zs3-01
    setenv REMOTE_ZEBU_SETUP $script_path:r.sh
  endif
else
  echo "ZeBu machine in US01, EUDC and DE02 only"
  exit 1
endif
endif
endif
# ZeBu defines
setenv SUBMITCMDSH 'bsub -app bnormal -K -R "select[os_version=CS7.0]" -R "span[hosts=1]" -n 4 -R "rusage[mem=60G]" -M 60G'
#setenv SUBMITCMDSH "qrsh -noshell -now no -verbose -cwd -V -P bnormal -b y -l os_version=CS7.0,h_vmem=80G -pe mt 4"
setenv ZEBU_ACTIVATE_EMU_QUEUE TRUE ;# enable queue for multiple user
setenv VIVADO_ENABLE_MULTITHREADING 6 ;# speed up synthesis
setenv ZEBU_ENABLE_DDR_DMA true ;# speed up fpga loading -> 2020.03-1
setenv ZEBU_SERIALIZED_ZFPGATIMING_BACK_ANNOTATION 1 ;# report inter FPGA delays -> 2020.03-SP1

# zSimzilla defines
setenv ZEBU_SIMZILLA_VIRTUAL_SLICING 1 ;# speed up ZTDB expansion with zSimzilla -> 2018.09-SP1-2
setenv SNPS_RHINODB_INTERNAL_DV2ZXF_ENABLE 1 ;# limit scope of zSimzilla to dumpvars -> 2018.09-SP1-2
setenv ZEBU_DEBUG_USE_AUTO_ZXF 1 ;# limit scope of zSimzilla to dumpvars -> 2018.09-SP1-2
setenv ZEBU_ENABLE_NEW_ZTDB_RB 1 ;# faster Simzilla -> 2020.03-SP1
setenv ZEBU_DEBUG_DYN_GRAPH_LOADING 1 ;# enable zSimzilla for Interactive Waveform Expansion -> 2020.03-1
setenv ZEBU_DEBUG_USE_SIMZILLA 1 ;# enable zSimzilla for Interactive Waveform Expansion -> 2020.03-1
setenv ZEBU_DEBUG_USE_DFS 1 ;# enable zSimzilla for Interactive Waveform Expansion -> 2020.03-1
#setenv ZEBU_DEBUG_ZWD_PLUS_R 1 ;# enable new zwd format -> 2020.03-SP1


