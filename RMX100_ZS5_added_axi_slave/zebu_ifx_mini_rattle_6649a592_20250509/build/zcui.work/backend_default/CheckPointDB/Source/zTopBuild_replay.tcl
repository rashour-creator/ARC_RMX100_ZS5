data_localization -core_strategy {NO} -fpga_strategy {NO}
vectorize -enable {yes}
wire_resolution_defaults -conflict {wand} -tristate {pullup} -undriven {0}
set_config -relocate=yes
set_tranif -optimize_false_path {yes} -simplify_tranif_sccs {no} -multidriver_logic_sharing {0} -dominant_driver_optimization {no}
winding_path {optimize_laces} -mode=manual -depth=1 -max_cut=1
winding_path_zcore {optimize_laces} -mode=manual -depth=1 -max_cut=1
zoffline_debug -enable {no}
set_dump_var -filename {dumpvars.db}
loop {report} -limit {10000} -async -explore_clock_tree
cluster {set} -lut_weighting_default { 1 0  2 1 3 1 4 1 5 1 6 1 }
config_upf -use_rtlname {yes} -hier_sep {/} -firmware_lib {zse_hw_zTop.edf.gz}
dump_memory -merged -report_details {stability}
cluster {accept_overflow} -lut=5 -reg=5 -dsp=0 -bram=5 -qiwc_bit=5 -uram {5} -fwc_ip=5
cluster {set} -max_fill_fwc_ip {80}
cluster {set} -max_fill_sabre_pi_bit {100}
cluster {set} -max_fill_sabre_ff_bit {50}
set_force_assign -value_1_on_vector {warning}
set_dpi_simplification -enable {yes}
read_edif {../design/fs_macros.edf}
read_edif {../design/synth_Default_RTL_Group/edif/DWbb_bcm21_0000/DWbb_bcm21_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/DWbb_bcm21_atv_0000/DWbb_bcm21_atv_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/DWbb_bcm21_atv_0001/DWbb_bcm21_atv_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/DWbb_bcm99/DWbb_bcm99.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_0/ZebuClockDetectFront_0.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_1/ZebuClockDetectFront_1.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_10/ZebuClockDetectFront_10.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_100/ZebuClockDetectFront_100.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_101/ZebuClockDetectFront_101.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_102/ZebuClockDetectFront_102.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_103/ZebuClockDetectFront_103.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_104/ZebuClockDetectFront_104.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_105/ZebuClockDetectFront_105.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_106/ZebuClockDetectFront_106.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_107/ZebuClockDetectFront_107.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_11/ZebuClockDetectFront_11.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_12/ZebuClockDetectFront_12.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_13/ZebuClockDetectFront_13.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_14/ZebuClockDetectFront_14.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_15/ZebuClockDetectFront_15.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_16/ZebuClockDetectFront_16.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_17/ZebuClockDetectFront_17.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_18/ZebuClockDetectFront_18.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_19/ZebuClockDetectFront_19.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_2/ZebuClockDetectFront_2.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_20/ZebuClockDetectFront_20.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_21/ZebuClockDetectFront_21.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_22/ZebuClockDetectFront_22.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_23/ZebuClockDetectFront_23.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_24/ZebuClockDetectFront_24.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_25/ZebuClockDetectFront_25.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_26/ZebuClockDetectFront_26.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_27/ZebuClockDetectFront_27.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_28/ZebuClockDetectFront_28.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_29/ZebuClockDetectFront_29.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_3/ZebuClockDetectFront_3.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_30/ZebuClockDetectFront_30.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_31/ZebuClockDetectFront_31.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_32/ZebuClockDetectFront_32.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_33/ZebuClockDetectFront_33.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_34/ZebuClockDetectFront_34.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_35/ZebuClockDetectFront_35.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_36/ZebuClockDetectFront_36.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_37/ZebuClockDetectFront_37.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_38/ZebuClockDetectFront_38.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_39/ZebuClockDetectFront_39.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_4/ZebuClockDetectFront_4.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_40/ZebuClockDetectFront_40.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_41/ZebuClockDetectFront_41.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_42/ZebuClockDetectFront_42.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_43/ZebuClockDetectFront_43.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_44/ZebuClockDetectFront_44.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_45/ZebuClockDetectFront_45.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_46/ZebuClockDetectFront_46.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_47/ZebuClockDetectFront_47.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_48/ZebuClockDetectFront_48.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_49/ZebuClockDetectFront_49.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_5/ZebuClockDetectFront_5.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_50/ZebuClockDetectFront_50.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_51/ZebuClockDetectFront_51.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_52/ZebuClockDetectFront_52.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_53/ZebuClockDetectFront_53.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_54/ZebuClockDetectFront_54.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_55/ZebuClockDetectFront_55.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_56/ZebuClockDetectFront_56.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_57/ZebuClockDetectFront_57.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_58/ZebuClockDetectFront_58.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_59/ZebuClockDetectFront_59.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_6/ZebuClockDetectFront_6.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_60/ZebuClockDetectFront_60.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_61/ZebuClockDetectFront_61.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_62/ZebuClockDetectFront_62.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_63/ZebuClockDetectFront_63.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_64/ZebuClockDetectFront_64.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_65/ZebuClockDetectFront_65.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_66/ZebuClockDetectFront_66.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_67/ZebuClockDetectFront_67.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_68/ZebuClockDetectFront_68.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_69/ZebuClockDetectFront_69.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_7/ZebuClockDetectFront_7.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_70/ZebuClockDetectFront_70.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_71/ZebuClockDetectFront_71.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_72/ZebuClockDetectFront_72.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_73/ZebuClockDetectFront_73.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_74/ZebuClockDetectFront_74.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_75/ZebuClockDetectFront_75.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_76/ZebuClockDetectFront_76.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_77/ZebuClockDetectFront_77.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_78/ZebuClockDetectFront_78.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_79/ZebuClockDetectFront_79.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_8/ZebuClockDetectFront_8.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_80/ZebuClockDetectFront_80.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_81/ZebuClockDetectFront_81.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_82/ZebuClockDetectFront_82.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_83/ZebuClockDetectFront_83.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_84/ZebuClockDetectFront_84.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_85/ZebuClockDetectFront_85.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_86/ZebuClockDetectFront_86.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_87/ZebuClockDetectFront_87.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_88/ZebuClockDetectFront_88.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_89/ZebuClockDetectFront_89.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_9/ZebuClockDetectFront_9.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_90/ZebuClockDetectFront_90.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_91/ZebuClockDetectFront_91.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_92/ZebuClockDetectFront_92.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_93/ZebuClockDetectFront_93.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_94/ZebuClockDetectFront_94.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_95/ZebuClockDetectFront_95.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_96/ZebuClockDetectFront_96.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_97/ZebuClockDetectFront_97.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_98/ZebuClockDetectFront_98.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ZebuClockDetectFront_99/ZebuClockDetectFront_99.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_bus_switch/alb_mss_bus_switch.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_clkctrl/alb_mss_clkctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_clkctrl_clken_gen/alb_mss_clkctrl_clken_gen.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_clkctrl_clkgate/alb_mss_clkctrl_clkgate.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_clkctrl_clkgen/alb_mss_clkctrl_clkgen.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_clkctrl_ratio_calc/alb_mss_clkctrl_ratio_calc.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_dummy_slave/alb_mss_dummy_slave.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_ext_stub/alb_mss_ext_stub.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab/alb_mss_fab.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ahbl2ibp_0000/alb_mss_fab_ahbl2ibp_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_axi2ibp_0000/alb_mss_fab_axi2ibp_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_axi2ibp_0001/alb_mss_fab_axi2ibp_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_axi2ibp_rrobin/alb_mss_fab_axi2ibp_rrobin.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_bus_lat_0000/alb_mss_fab_bus_lat_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_bus_lat_0000_0000/alb_mss_fab_bus_lat_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_bypbuf_0000/alb_mss_fab_bypbuf_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_bypbuf_0000_0000/alb_mss_fab_bypbuf_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_bypbuf_0000_0001/alb_mss_fab_bypbuf_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_bypbuf_0000_0002/alb_mss_fab_bypbuf_0000_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000/alb_mss_fab_fifo_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0000/alb_mss_fab_fifo_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0001/alb_mss_fab_fifo_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0002/alb_mss_fab_fifo_0000_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0003/alb_mss_fab_fifo_0000_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0004/alb_mss_fab_fifo_0000_0004.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0005/alb_mss_fab_fifo_0000_0005.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0006/alb_mss_fab_fifo_0000_0006.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0007/alb_mss_fab_fifo_0000_0007.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0008/alb_mss_fab_fifo_0000_0008.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0009/alb_mss_fab_fifo_0000_0009.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_000A/alb_mss_fab_fifo_0000_000A.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_000B/alb_mss_fab_fifo_0000_000B.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_000C/alb_mss_fab_fifo_0000_000C.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_000D/alb_mss_fab_fifo_0000_000D.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_000E/alb_mss_fab_fifo_0000_000E.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_000F/alb_mss_fab_fifo_0000_000F.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0010/alb_mss_fab_fifo_0000_0010.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0011/alb_mss_fab_fifo_0000_0011.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0012/alb_mss_fab_fifo_0000_0012.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0013/alb_mss_fab_fifo_0000_0013.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0014/alb_mss_fab_fifo_0000_0014.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0015/alb_mss_fab_fifo_0000_0015.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0016/alb_mss_fab_fifo_0000_0016.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0000_0017/alb_mss_fab_fifo_0000_0017.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0002/alb_mss_fab_fifo_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0002_0000/alb_mss_fab_fifo_0002_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0002_0001/alb_mss_fab_fifo_0002_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0003/alb_mss_fab_fifo_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0003_0000/alb_mss_fab_fifo_0003_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0003_0001/alb_mss_fab_fifo_0003_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0004/alb_mss_fab_fifo_0004.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0004_0000/alb_mss_fab_fifo_0004_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0005/alb_mss_fab_fifo_0005.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0005_0000/alb_mss_fab_fifo_0005_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0006/alb_mss_fab_fifo_0006.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0006_0000/alb_mss_fab_fifo_0006_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0006_0001/alb_mss_fab_fifo_0006_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0007/alb_mss_fab_fifo_0007.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0008/alb_mss_fab_fifo_0008.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_0009/alb_mss_fab_fifo_0009.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_000A/alb_mss_fab_fifo_000A.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_fifo_000A_0000/alb_mss_fab_fifo_000A_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2ahbl/alb_mss_fab_ibp2ahbl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2ahbl_sel/alb_mss_fab_ibp2ahbl_sel.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2apb/alb_mss_fab_ibp2apb.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2apb_0000/alb_mss_fab_ibp2apb_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2axi/alb_mss_fab_ibp2axi.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2axi_rg/alb_mss_fab_ibp2axi_rg.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2single_0000/alb_mss_fab_ibp2single_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2single_0000_0000/alb_mss_fab_ibp2single_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp2single_0000_0001/alb_mss_fab_ibp2single_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000/alb_mss_fab_ibp_buffer_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0000/alb_mss_fab_ibp_buffer_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0001/alb_mss_fab_ibp_buffer_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0002/alb_mss_fab_ibp_buffer_0000_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0003/alb_mss_fab_ibp_buffer_0000_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0004/alb_mss_fab_ibp_buffer_0000_0004.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0005/alb_mss_fab_ibp_buffer_0000_0005.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0006/alb_mss_fab_ibp_buffer_0000_0006.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0007/alb_mss_fab_ibp_buffer_0000_0007.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0008/alb_mss_fab_ibp_buffer_0000_0008.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_0009/alb_mss_fab_ibp_buffer_0000_0009.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_buffer_0000_000A/alb_mss_fab_ibp_buffer_0000_000A.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_lat/alb_mss_fab_ibp_lat.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_ibp_lat_0000/alb_mss_fab_ibp_lat_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_mst_axi_buffer/alb_mss_fab_mst_axi_buffer.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_single2ahbl/alb_mss_fab_single2ahbl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_single2sparse_0000/alb_mss_fab_single2sparse_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_slv_axi_buffer/alb_mss_fab_slv_axi_buffer.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fab_slv_axi_buffer_0000/alb_mss_fab_slv_axi_buffer_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_fpga_sram_0000/alb_mss_fpga_sram_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem/alb_mss_mem.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_bypbuf_0000/alb_mss_mem_bypbuf_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_bypbuf_0000_0000/alb_mss_mem_bypbuf_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_bypbuf_0000_0001/alb_mss_mem_bypbuf_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_bypbuf_0000_0002/alb_mss_mem_bypbuf_0000_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_bypbuf_0000_0003/alb_mss_mem_bypbuf_0000_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_bypbuf_0000_0004/alb_mss_mem_bypbuf_0000_0004.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_clkgate/alb_mss_mem_clkgate.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_ctrl/alb_mss_mem_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0000/alb_mss_mem_fifo_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0000_0000/alb_mss_mem_fifo_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0000_0001/alb_mss_mem_fifo_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0000_0002/alb_mss_mem_fifo_0000_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0000_0003/alb_mss_mem_fifo_0000_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0001/alb_mss_mem_fifo_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0002/alb_mss_mem_fifo_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0003/alb_mss_mem_fifo_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_fifo_0003_0000/alb_mss_mem_fifo_0003_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_ibp2single_0000/alb_mss_mem_ibp2single_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_ibp_buf/alb_mss_mem_ibp_buf.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_ibp_bypbuf_0000/alb_mss_mem_ibp_bypbuf_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_ibp_cwbind_0000/alb_mss_mem_ibp_cwbind_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_ibp_excl_0000/alb_mss_mem_ibp_excl_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_ibp_lat/alb_mss_mem_ibp_lat.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_lat_0000/alb_mss_mem_lat_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_mem_model/alb_mss_mem_model.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/alb_mss_perfctrl/alb_mss_perfctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/apb_master_ap0/apb_master_ap0.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/archipelago/archipelago.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_dm/arcv_dm.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_dm_top/arcv_dm_top.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_imsic_clint/arcv_imsic_clint.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_timer/arcv_timer.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_timer_synch/arcv_timer_synch.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_watchdog/arcv_watchdog.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_watchdog_csr/arcv_watchdog_csr.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_watchdog_ctrl/arcv_watchdog_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_wd_parity/arcv_wd_parity.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_wd_parity_0000/arcv_wd_parity_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_wd_parity_0001/arcv_wd_parity_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_wd_parity_0002/arcv_wd_parity_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/arcv_wdt_synch/arcv_wdt_synch.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/axi_dummy_slave/axi_dummy_slave.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/bvci_to_axi/bvci_to_axi.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/cdc_synch_wrap/cdc_synch_wrap.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/clkgate/clkgate.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/clockDelayPort_0000/clockDelayPort_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/core_chip/core_chip.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/core_sys/core_sys.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/cpu_safety_monitor/cpu_safety_monitor.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/cpu_top_safety_controller/cpu_top_safety_controller.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dccm_ram/dccm_ram.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dm_cdc_sync/dm_cdc_sync.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dm_cgm/dm_cgm.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dm_clock_gate/dm_clock_gate.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dm_hmst/dm_hmst.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dw_dbp/dw_dbp.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dw_dbp_cdc_sync/dw_dbp_cdc_sync.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dwt_debug_port/dwt_debug_port.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dwt_jtag_port/dwt_jtag_port.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dwt_reset_ctrl/dwt_reset_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dwt_reset_ctrl_0000/dwt_reset_ctrl_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dwt_sys_clk_sync/dwt_sys_clk_sync.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/dwt_tap_controller/dwt_tap_controller.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/e2e_edc32_1stg_chk/e2e_edc32_1stg_chk.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/e2e_edc32_1stg_qual_chk_wrap_0000/e2e_edc32_1stg_qual_chk_wrap_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/err_inj_ctrl_0000/err_inj_ctrl_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/fpga_sram_0000/fpga_sram_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/fpga_sram_0001/fpga_sram_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/fpga_sram_0002/fpga_sram_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/fpga_sram_0002_0000/fpga_sram_0002_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ic_data_ecc_decoder/ic_data_ecc_decoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ic_data_ecc_encoder/ic_data_ecc_encoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ic_data_ram/ic_data_ram.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ic_tag_ecc_decoder/ic_tag_ecc_decoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ic_tag_ecc_encoder/ic_tag_ecc_encoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ic_tag_ram/ic_tag_ram.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/iccm0_ram/iccm0_ram.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/iccm_ecc_decoder/iccm_ecc_decoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/iccm_ecc_encoder/iccm_ecc_encoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/io_pad_ring/io_pad_ring.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/iprio_arb/iprio_arb.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/iprio_arb_4to1/iprio_arb_4to1.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_cdc_sync/ls_cdc_sync.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_cdc_sync_0000/ls_cdc_sync_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_0000/ls_compare_unit_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_0001/ls_compare_unit_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_0002/ls_compare_unit_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_0004/ls_compare_unit_0004.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_0005/ls_compare_unit_0005.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_0009/ls_compare_unit_0009.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_000A/ls_compare_unit_000A.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_000B/ls_compare_unit_000B.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_000C/ls_compare_unit_000C.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_compare_unit_000D/ls_compare_unit_000D.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_error_register_0000/ls_error_register_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_multi_bit_comparator_0000/ls_multi_bit_comparator_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_multi_bit_comparator_0004/ls_multi_bit_comparator_0004.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_multi_bit_comparator_0005/ls_multi_bit_comparator_0005.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_sfty_mnt_diag_ctrl/ls_sfty_mnt_diag_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/ls_sfty_mnt_diag_ctrl_0000/ls_sfty_mnt_diag_ctrl_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_default_slv_0000/mss_bus_switch_default_slv_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_dw32_slv/mss_bus_switch_dw32_slv.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_dw512_slv/mss_bus_switch_dw512_slv.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_fifo_0001/mss_bus_switch_fifo_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_fifo_0001_0000/mss_bus_switch_fifo_0001_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_fifo_0001_0001/mss_bus_switch_fifo_0001_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_fifo_0001_0002/mss_bus_switch_fifo_0001_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_fifo_0001_0003/mss_bus_switch_fifo_0001_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_fifo_0001_0004/mss_bus_switch_fifo_0001_0004.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp2ibps/mss_bus_switch_ibp2ibps.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp2ibps_0000/mss_bus_switch_ibp2ibps_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp2ibps_0001/mss_bus_switch_ibp2ibps_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp2single_0000/mss_bus_switch_ibp2single_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp2single_0000_0000/mss_bus_switch_ibp2single_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp2single_0000_0001/mss_bus_switch_ibp2single_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_compr_0000/mss_bus_switch_ibp_compr_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_compr_0000_0000/mss_bus_switch_ibp_compr_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_compr_0000_0001/mss_bus_switch_ibp_compr_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_dw128_mst/mss_bus_switch_ibp_dw128_mst.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_dw32_mst/mss_bus_switch_ibp_dw32_mst.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_dw64_mst/mss_bus_switch_ibp_dw64_mst.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_split_0000/mss_bus_switch_ibp_split_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibp_split_0000_0000/mss_bus_switch_ibp_split_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpn2ibpw_0000/mss_bus_switch_ibpn2ibpw_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpn2ibpw_0001/mss_bus_switch_ibpn2ibpw_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpw2ibpn_0000/mss_bus_switch_ibpw2ibpn_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpw2ibpn_0001/mss_bus_switch_ibpw2ibpn_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpw2ibpn_0002/mss_bus_switch_ibpw2ibpn_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpx2ibpy_0001/mss_bus_switch_ibpx2ibpy_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpx2ibpy_0001_0000/mss_bus_switch_ibpx2ibpy_0001_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpx2ibpy_0001_0001/mss_bus_switch_ibpx2ibpy_0001_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpx2ibpy_0002/mss_bus_switch_ibpx2ibpy_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_ibpx2ibpy_0002_0000/mss_bus_switch_ibpx2ibpy_0002_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_mst_ibp_buffer_0000/mss_bus_switch_mst_ibp_buffer_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_mst_ibp_buffer_0000_0000/mss_bus_switch_mst_ibp_buffer_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_mst_ibp_buffer_0000_0001/mss_bus_switch_mst_ibp_buffer_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_rrobin/mss_bus_switch_rrobin.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_slv_ibp_buffer_0000/mss_bus_switch_slv_ibp_buffer_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_slv_ibp_buffer_0000_0000/mss_bus_switch_slv_ibp_buffer_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_slv_ibp_buffer_0001/mss_bus_switch_slv_ibp_buffer_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/mss_bus_switch_slv_ibp_buffer_0001_0000/mss_bus_switch_slv_ibp_buffer_0001_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/reset_fsm/reset_fsm.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/reset_handshake/reset_handshake.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_adder_0000/rl_adder_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ahb2ibp_0000/rl_ahb2ibp_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ahb2ibp_0001/rl_ahb2ibp_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_alu/rl_alu.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_alu_data_path/rl_alu_data_path.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_bitscan/rl_bitscan.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_bitscan_16b/rl_bitscan_16b.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_bitscan_32b/rl_bitscan_32b.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_bitscan_4b/rl_bitscan_4b.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_bitscan_8b/rl_bitscan_8b.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_branch/rl_branch.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_bypass/rl_bypass.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_byte_unit/rl_byte_unit.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_clock_ctrl/rl_clock_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_complete/rl_complete.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_core/rl_core.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_cpu_misc_synch/rl_cpu_misc_synch.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_cpu_synch_wrap/rl_cpu_synch_wrap.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_cpu_top/rl_cpu_top.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_csr/rl_csr.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_debug/rl_debug.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_decoder/rl_decoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dispatch/rl_dispatch.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp/rl_dmp.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_amo/rl_dmp_amo.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_csr/rl_dmp_csr.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_cwb/rl_dmp_cwb.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_dccm/rl_dmp_dccm.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_dccm_ecc_decoder/rl_dmp_dccm_ecc_decoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_dccm_ecc_encoder/rl_dmp_dccm_ecc_encoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_dccm_ibp_wrapper/rl_dmp_dccm_ibp_wrapper.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_ecc_store_aligner/rl_dmp_ecc_store_aligner.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_load_aligner/rl_dmp_load_aligner.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_lsq/rl_dmp_lsq.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_lsq_cmd_port/rl_dmp_lsq_cmd_port.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_lsq_fifo/rl_dmp_lsq_fifo.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_dmp_store_aligner/rl_dmp_store_aligner.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ecc_cnt/rl_ecc_cnt.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_epmp/rl_epmp.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_exu/rl_exu.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_halt_mgr/rl_halt_mgr.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_hpm/rl_hpm.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ibp2ahb/rl_ibp2ahb.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ibp2mmio/rl_ibp2mmio.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ibp_target_wrapper/rl_ibp_target_wrapper.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_iesb/rl_iesb.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu/rl_ifu.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_align/rl_ifu_align.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_fetcher/rl_ifu_fetcher.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_icache/rl_ifu_icache.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_icache_ctl/rl_ifu_icache_ctl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_icache_rf/rl_ifu_icache_rf.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_iccm/rl_ifu_iccm.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_iccm_csr/rl_ifu_iccm_csr.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ifu_id_ctrl/rl_ifu_id_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_maskgen/rl_maskgen.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_mmio_ahb2ibp/rl_mmio_ahb2ibp.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_mpy/rl_mpy.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_chk_0000/rl_parity_chk_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_chk_0001/rl_parity_chk_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_chk_0002/rl_parity_chk_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_chk_0002_0000/rl_parity_chk_0002_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_chk_0002_0001/rl_parity_chk_0002_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_chk_0002_0002/rl_parity_chk_0002_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_chk_0002_0003/rl_parity_chk_0002_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_gen_0000/rl_parity_gen_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_gen_0000_0000/rl_parity_gen_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_gen_0000_0001/rl_parity_gen_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_gen_0000_0002/rl_parity_gen_0000_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_gen_0000_0003/rl_parity_gen_0000_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_gen_0001/rl_parity_gen_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_parity_gen_0002/rl_parity_gen_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_per_ibp2ahb/rl_per_ibp2ahb.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_pipe_ctrl/rl_pipe_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_pma/rl_pma.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_pma_hit/rl_pma_hit.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_pmp/rl_pmp.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_pmp_hit/rl_pmp_hit.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_predecoder/rl_predecoder.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_ras_top/rl_ras_top.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_regfile/rl_regfile.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_reset_ctrl/rl_reset_ctrl.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_reset_ctrl_synch/rl_reset_ctrl_synch.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_reset_ctrl_wrap/rl_reset_ctrl_wrap.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_result_bus/rl_result_bus.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_sfty_csr/rl_sfty_csr.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_sfty_ibp_tgt_e2e_wrap_0000/rl_sfty_ibp_tgt_e2e_wrap_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_sfty_mnt_err_aggr/rl_sfty_mnt_err_aggr.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_sfty_mnt_reg_agent/rl_sfty_mnt_reg_agent.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_shifter_0000/rl_shifter_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_simple_fifo/rl_simple_fifo.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_soft_reset_aux/rl_soft_reset_aux.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_special/rl_special.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_srams/rl_srams.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_trap/rl_trap.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_triggers/rl_triggers.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_triggers_iso/rl_triggers_iso.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_uop_seq/rl_uop_seq.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/rl_wtree_32x4/rl_wtree_32x4.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/safety_iso_sync/safety_iso_sync.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/sfty_dmsi_down_tgt_e2e_wrap_0000/sfty_dmsi_down_tgt_e2e_wrap_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/sfty_ibp_ini_e2e_wrap_0000/sfty_ibp_ini_e2e_wrap_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/simple_parity/simple_parity.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/simple_parity_0000/simple_parity_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/single_bit_syncP/single_bit_syncP.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/sr_err_aggr_0000/sr_err_aggr_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/sr_err_aggr_0000_0000/sr_err_aggr_0000_0000.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/sr_err_aggr_0000_0001/sr_err_aggr_0000_0001.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/sr_err_aggr_0000_0002/sr_err_aggr_0000_0002.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/sr_err_aggr_0000_0003/sr_err_aggr_0000_0003.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/xtor_amba_master_axi3_svs/xtor_amba_master_axi3_svs.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/xtor_amba_slave_axi3_svs/xtor_amba_slave_axi3_svs.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/xtor_t32Jtag_svs/xtor_t32Jtag_svs.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zebu_axi_xtor/zebu_axi_xtor.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zebu_time_capture/zebu_time_capture.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zebu_top/zebu_top.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zebu_ts_orion_tick_clk_mod/zebu_ts_orion_tick_clk_mod.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zemi3OutPortBuffer_169_4096_24/zemi3OutPortBuffer_169_4096_24.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_1/zz_Encrypt_1.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_12/zz_Encrypt_12.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_2/zz_Encrypt_2.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_5/zz_Encrypt_5.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_6/zz_Encrypt_6.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_7/zz_Encrypt_7.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_8/zz_Encrypt_8.edf.gz}
read_edif {../design/synth_Default_RTL_Group/edif/zz_Encrypt_9/zz_Encrypt_9.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_alb_mss_fpga_sram_0000_zMem/alb_mss_fpga_sram_0000_ZMEM_mem_r.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_alb_mss_mem_lat_0000_zMem/alb_mss_mem_lat_0000_ZMEM_i_bdel_mem.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_alb_mss_mem_lat_0000_zMem/alb_mss_mem_lat_0000_ZMEM_i_rdel_mem.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_fpga_sram_0000_zMem/fpga_sram_0000_ZMEM_mem_r.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_fpga_sram_0001_zMem/fpga_sram_0001_ZMEM_mem_r.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_fpga_sram_0002_0000_zMem/fpga_sram_0002_0000_ZMEM_mem_r.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_fpga_sram_0002_zMem/fpga_sram_0002_ZMEM_mem_r.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_zz_Encrypt_2_zMem/zz_Encrypt_2_ZMEM_0.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_zz_Encrypt_5_zMem/zz_Encrypt_5_ZMEM_0.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_zz_Encrypt_6_zMem/zz_Encrypt_6_ZMEM_0.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_zz_Encrypt_7_zMem/zz_Encrypt_7_ZMEM_0.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_zz_Encrypt_8_zMem/zz_Encrypt_8_ZMEM_0.edf.gz}
read_edif {../design/synth_Default_RTL_Group/zmem/Memory_zz_Encrypt_9_zMem/zz_Encrypt_9_ZMEM_0.edf.gz}
set_top {zebu_top}
edit_netlist {../utf_generatefiles/zTopBuild_netlist_config.tcl}
cluster {set} -max_fill_lut6 {20}
cluster {set} -max_fill_type {safe} -dsp {40} -bram {50} -uram {30} -ramlut {25} -reg {15} -lut {40} -fwc_ip {80} -fwc_bit {15} -qiwc_bit {50}
cluster {set} -max_fill_type {standard} -dsp {60} -bram {60} -uram {40} -ramlut {25} -reg {22} -lut {50} -fwc_ip {80} -fwc_bit {30} -qiwc_bit {60}
cluster {set} -max_fill_type {aggressive} -dsp {90} -bram {90} -uram {60} -ramlut {30} -reg {30} -lut {55} -fwc_ip {80} -fwc_bit {35} -qiwc_bit {70}
cluster {set} -mode=customized
cluster {auto}
cluster {set} -max_fill_default {standard}
cluster {set} -max_fill_dsp {60}
cluster {set} -max_fill_bram {60}
cluster {set} -max_fill_uram {40}
cluster {set} -max_fill_ramlut {25}
cluster {set} -max_fill_reg {22}
cluster {set} -max_fill_lut {50}
cluster {set} -max_fill_fwc_ip {80}
cluster {set} -max_fill_fwc_bit {30}
cluster {set} -max_fill_qiwc_bit {60}
zcorebuild_command {*} { cluster enable -accept_changes_on_user_max_fill_constraints }
clock_handling {algorithm=filter_glitches_synchronous} -detect_clock_glitches=no -retiming=no -FGS_fetch_mode=yes
clock_localization -core_strategy=AUTO -fpga_strategy=AUTO
disable {manipulate_bram_for_sw_rw}
enable {zrm_use_16_value_latency}
set_synthesis_uc_mode {uc_no_zfe}
zoffline_debug -enable {yes} -probe_outputs {yes}
rtlDB -path {RTLDB}
probe_signals -rtlname { {zebu_top.rst_a} }
rtl_clock_mode -enable -debug -auto_tolerance -max_ginc_size {24} -replicate_fpga
enable {group_clock_delay_mode}
enable {group_clock_delay_with_time_distrib_mode}
enable {clock_delay_stop_rlc}
xtor -name {clockDelayPort_0000} -type {ZCEI}
xtor -name {rl_ifu_fetcher} -type {ZEMI3}
xtor -name {xtor_amba_master_axi3_svs} -type {ZEMI3}
xtor -name {xtor_amba_slave_axi3_svs} -type {ZEMI3}
xtor -name {xtor_t32Jtag_svs} -type {ZEMI3}
xtor -name {zebu_time_capture} -type {ZEMI3}
xtor_install_file -append {/global/apps/zebu_vs_2023.03-SP1//drivers}
enable {uc_no_dve_flow}
enable {zemi3_fm_optimization}
enable {zemi3_fm_mcp}
enable {zemi3_fm_hydra}
encrypted_commands_tcl {/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/utf_generatefiles/uc_nodve_ztb.tcl}
zinject -rtlname {zebu_top.zebu_disable}
zinject -rtlname {zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.zebu_disable}
zinject -rtlname {zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.zebu_disable}
zsva -trace_success {no} -trace_busy {no} -trace_start {no} -trace_end {no} -trace_failure {yes}
disable {ztime_uses_rtl_names}
enable {advanced_incremental_mode}
set_hydra -enable {yes}
set_perf_flow {flow1} -tag {begin_2021.09}
enable {replicate_zprd_disable}
zcorebuild_command {*} {enable replicate_zprd_disable}
partitioning {auto} -xdraware_opt_placement
enable {ac_annotate_prob_routes}
zcorebuild_command {*} {partitioning auto  -xdraware} -tag {perf_flow_command}
clock_localization -core_strategy=AUTO -fpga_strategy=AUTO -extend_clock_cone=yes -check_paths_to_preserve {yes}
data_localization -inter_unit_paths -level {unit} -core_strategy {AUTO} -fpga_strategy {AUTO} -tristates
clock_config -share_clock_bus {true}
zrm_partitioning
set_perf_flow {flow1} -tag {end_2021.09}
zforce -mode {dynamic} -object_not_found {fatal} -rtlname {{zebu_top.rst_a}} -sync_enable
zforce -mode {dynamic} -object_not_found {warning} -rtlname {{zebu_top.core_chip_dut.i_ext_personality_mode}} -sync_enable
zforce -mode {dynamic} -object_not_found {warning} -rtlname {{zebu_top.core_chip_dut.icore_sys.i_ext_personality_mode}} -sync_enable
run_manager -number_of_instances {3}
cluster_constraint_adv {set_max_fill} -lut {30}
cluster {set} -max_fill_lut {30}
default_reg_init {0}
set_fast_waveform_capture -relocate {yes}
dump_stats -logic_optimization
enable {zrm_performance_mode}
compile_objective {Performance} -tag {begin}
zcorebuild_command {*} {timing_model -ml_delay}
vivado_constraints -mode=soft -paths=inter
compile_objective {Performance} -tag {end}
set_logic_opt -drop_optimizable_waveform_capture {yes}
xtor_disable -instance {zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i} -rtlname {zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.zebu_disable}
xtor_disable -instance {zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor} -rtlname {zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.zebu_disable}
xtor_disable -instance {zebu_top.i_t32Jtag_driver} -rtlname {zebu_top.zebu_disable}
create_attribute -instance {zebu_top.trigger_pc} -attr_name {RTLNAME_OF_trigger_input_0} -attr_value {zebu_top.core0_pc} -rtlname
create_attribute -module {zebu_time_capture} -attr_name {active_postrun} -attr_value {true} -rtlname
