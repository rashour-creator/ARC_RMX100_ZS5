# EMULATION and VERIFICATION ENGINEERING (c) - 2003-2008
# ------------------------------------------------------
# Set variables for zPar

set zpar_timing_args "-zTime_mode"
set zpar_extra_cmds "zPar_extra_cmds.tcl"


# Commands for zPar

fwc zcg_compositeClock -version gen2 -optimize area -fpgas {U0_M0_F0 U0_M0_F1}
System enableDelayEstimation
# Commands for zPar from zCoreBuild.

timing -analyze {TRISTATE_PATH ZFILTER_ENABLE_PATH ZFILTER_ASYNC_SET_RESET_PATH ZFILTER_FETCH_FEEDBACK }
System enableSDFMemoryModel true
