ZCUI_set ArchitectureFile {/remote/sdgzebu_system_dir/CONFIG/ZSE/zs5_4s.zs_0170/config/zse_configuration.tcl}
ZCUI_set EnableHydra t
ZCUI_set TopDebugFlag t
ZCUI_set MemoryIOAccessibilityFlag t
ZCUI_set VcsVerdiFlow true
ZCUI_set enableZSimzilla t
ZCUI_set enableZSimzillaDistributed f
ZCUI_set SwaveFlow f
ZCUI_set GeneratorType CPP
ZCUI_set UseFpgaMultiLaunch t
ZCUI_set UseParffMultiStage t
ZCUI_set EnablePDM Direct
ZCUI_add -jobQueue {DEFAULT_QUEUE} {bsub -Is -app comp_zebucae -Jd zebu_compile} {} {100}
ZCUI_add -jobQueue {Zebu} {bsub -Is -app comp_zebucae -Jd zebu_compile} {kill -9 %p} {100}
ZCUI_add -jobQueue {ZebuIse} {bsub -Is -app comp_zebucae -Jd zebu_compile} {kill -9 %p} {100}
ZCUI_add -jobQueue {ZebuSynthesis} {bsub -Is -app comp_zebucae -Jd zebu_compile} {kill -9 %p} {100}
ZCUI_add -jobQueue {ZebuHeavy} {bsub -Is -app comp_zebucae -Jd zebu_compile} {kill -9 %p} {100}
ZCUI_add -jobQueue {ZebuSuperHeavy} {bsub -Is -app comp_zebucae -Jd zebu_compile} {kill -9 %p} {100}
ZCUI_set ZMemLatencyFlag f
ZCUI_set DiskAccesOptimizerMethod 5
ZCUI_set ExistPRetryDelay 1000
ZCUI_set MaximumNumberOfExistPRetry 120
ZCUI_set WlsFlow t
ZCUI_set PreFpgaTimingModel ConstantsBased
ZCUI_set VivadoSkewTime f
ZCUI_set VivadoFilterTime f
ZCUI_set SDFTimingAnalysis t
ZCUI_set ZFpgaTimingCommandFilename /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/zFpgaTiming_config.tcl
ZCUI_set VcsCommand {/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui_vcs_cmd.csh}
ZCUI_set ZparRoutingEffortMode Medium
