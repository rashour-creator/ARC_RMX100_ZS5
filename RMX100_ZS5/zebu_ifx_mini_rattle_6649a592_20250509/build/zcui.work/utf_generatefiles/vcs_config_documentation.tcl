#Original command:
#	synthesis {-use_vfs false}
#internal command:
vcs_uc_synth_opts {-use_vfs f}

#Original command:
#	synthesis {-wls_option -checkSumForAllScm}
#internal command:
vcs_uc_synth_opts {-wls_option -checkSumForAllScm}

#Original command:
#	optimization {-auto_inline_limit 50}
#internal command:
vcs_optimization {-auto_inline_limit 50 -celldefine t}

#Original command:
#	probe_signals {-rtlname zebu_top.rst_a}
#internal command:
vcs_probe_signals {-rtlname zebu_top.rst_a}

#Original command:
#	xtors {-add_xtor_path /global/apps/zebu_vs_2023.03-SP1//drivers}
#internal command:
vcs_pre_elab_xtors {-add_xtor_path /global/apps/zebu_vs_2023.03-SP1//drivers}

#Original command:
#	optimization -keep_registers
#internal command:
vcs_optimization {-opt_level normal}

#Original command:
#	optimization {-auto_inline_limit 30}
#internal command:
vcs_optimization {-auto_inline_limit 30 -celldefine t}

#Original command:
#	optimization {-number_of_threads 8}
#internal command:
vcs_optimization {-number_of_threads 8}

#Original command:
#	dpi_synthesis {-enable all}
#internal command:
vcs_dpi_synthesis {-enable all}

