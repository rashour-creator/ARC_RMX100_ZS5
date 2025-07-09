cmn::option fe_hcsrc /slowfs/us01dwslow023/fpga/lianghao/zebu_install/ZEBU/VCS2021.09.2.ZEBU.B4/07052024/INSTALL/ZEBU/zebu/S-2021.09-2-TZ-20240507_Full64/etc/vhs/hcsrc.zcui
cmn::option fe_hcsrc /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/global_utf.hcsrc 
cmn::option fe_hcsrc /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/new_global_utf_config.hcsrc 
cmn::option fe_hcsrc "/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/design/synth_Default_RTL_Group/dut.hcsrc"
cmn::option fe_hcsrc hcsrc.iba
cmn::option phase synthesis 
fs::simple_compile \
-technology vtx8 \
-mode block_based \
-version NewMixedFlow \
\
-zNetgen_new "../zfepp_Default_RTL_Group.tcl"  \
-forest_tops {} \
