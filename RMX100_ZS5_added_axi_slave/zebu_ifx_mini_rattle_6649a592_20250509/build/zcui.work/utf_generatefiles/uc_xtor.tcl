xtor -name clockDelayPort_0000 -type ZCEI 
xtor -name rl_ifu_fetcher -type ZEMI3 
xtor -name xtor_amba_master_axi3_svs -type ZEMI3 
xtor -name xtor_amba_slave_axi3_svs -type ZEMI3 
xtor -name xtor_t32Jtag_svs -type ZEMI3 
xtor -name zebu_time_capture -type ZEMI3 
xtor_install_file -append {/global/apps/zebu_vs_2023.03-SP1//drivers}
