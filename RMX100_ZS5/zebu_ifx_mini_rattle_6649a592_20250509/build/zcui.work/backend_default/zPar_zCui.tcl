# written by zCui:PreParScriptBuilder 
# ----------------------------
source gridjob_profiling_parameters.tcl
source $env(ZEBU_ROOT)/etc/zpar/zPar_from_zCui.tcl
set zcui_main "true"
source {zPar_cmds.tcl}
set zpar_extra_cmds {../utf_generatefiles/zPar_config.tcl}
System routingEffort medium
System generate_sdf_request
System scTdmCompileFlow false
System timingCstFile {../utf_generatefiles/zTime_config.tcl}
source {incremental_compile.tcl}
# DO NOT ADD ANY COMMAND AFTER THIS LINE
source $env(ZEBU_ROOT)/etc/zpar/zPar_script.tcl
