#!/bin/csh -fx 

vlogan -syn_dw+dump_dir=zebu_dw -l zcui_comp.log \
  /global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v  \
  /global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv \
  -full64 -sverilog +v2k -kdb -timescale=1ns/10ps -debug_access+all -debug_region+cell+encrypt -skip_translate_body +define+SYNTHESIS +define+FPGA_INFER_MEMORIES +define+NO_2CYC_CHECKER +define+NO_3CYC_CHECKER +incdir+/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog +incdir+/remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/RTL -f /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/compile_manifest  -f /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/RTL/compile_manifest     -assert svaext  /remote/sdgedt/tools/reem/ZebuS5_oiginal/zebu_ifx_mini_rattle_6649a592_20250509/build/verilog/zebu_top.v 

vcs -j8 -full64 -kdb -top zebu_top -l zcui_elab.log \
   -xzebu -xzebu_flow=zebu_scm -hw_top=zebu_top \
  -syn_dw+dump_dir=zebu_dw -timescale=1ns/10ps -debug_access+all 
