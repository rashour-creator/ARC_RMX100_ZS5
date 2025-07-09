// Library ARCv2MSS-2.1.999999999










//
// Common Verilog/VPP header files
//
//#header vpp/new_fabric/alb_mss_fab_defines.vpp                 :ARCv2MSS

//
// Check the configuration validity
//
//#constraint vpp/new_fabric/alb_mss_fab_constraints.vpp         :CONSTRAINT

//
// Verilog/VPP source files and modules for Fab
//

//#source vpp/new_fabric/alb_mss_fab.vpp                           :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_ibp_lat.vpp                   :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_bus_lat.vpp                   :ARCv2MSS,SYNTH,SIM,LOGIC


//#source vpp/new_fabric/alb_mss_fab_axi2ibp_rrobin.vpp            :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_fab_axi2ibp_rrobin                     :ARCv2MSS
//#source vpp/new_fabric/alb_mss_fab_slv_axi_buffer.vpp            :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_fab_slv_axi_buffer                     :ARCv2MSS
//#source vpp/new_fabric/alb_mss_fab_axi2ibp.vpp                   :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_fab_axi2ibp                            :ARCv2MSS



//#source vpp/new_fabric/alb_mss_fab_ahbl2ibp.vpp                  :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_fab_ahbl2ibp                           :ARCv2MSS




//#source vpp/new_fabric/alb_mss_fab_ibp2axi_rg.vpp                :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_ibp2axi.vpp                   :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_mst_axi_buffer.vpp            :ARCv2MSS,SYNTH,SIM,LOGIC

//#source vpp/new_fabric/alb_mss_fab_ibp2ahbl_sel.vpp              :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_ibp2ahbl.vpp                  :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_single2ahbl.vpp               :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_single2sparse.vpp             :ARCv2MSS,SYNTH,SIM,LOGIC

//#source vpp/new_fabric/alb_mss_fab_ibp2apb.vpp                   :ARCv2MSS,SYNTH,SIM,LOGIC

//#source vpp/new_fabric/alb_mss_fab_ibp2single.vpp                :ARCv2MSS,SYNTH,SIM,LOGIC

//#source vpp/new_fabric/alb_mss_fab_fifo.vpp       :ARCv2MSS,SYNTH,SIM,MACRO

//#source vpp/new_fabric/alb_mss_fab_bypbuf.vpp     :ARCv2MSS,SYNTH,SIM,LOGIC



//#source vpp/new_fabric/alb_mss_fab_ibp2pack.vpp                  :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_pack2ibp.vpp                  :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/alb_mss_fab_ibp_buffer.vpp                :ARCv2MSS,SYNTH,SIM,LOGIC


//
// Verilog/VPP source files and modules for bus_switch
//
//#header vpp/new_fabric/bus_switch/alb_mss_bus_switch_defines.vpp            :ARCv2MSS
//#source vpp/new_fabric/bus_switch/alb_mss_bus_switch.vpp                    :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/bus_switch/alb_mss_bus_switch_default_slv.vpp        :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibp2pack.vpp                  :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibp2pack                           :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_pack2ibp.vpp                  :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_pack2ibp                           :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibpx2ibpy.vpp                 :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibpx2ibpy                          :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibp2single.vpp                :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibp2single                         :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibp2ibps.vpp                  :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibp2ibps                           :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibpw2ibpn.vpp                 :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibpw2ibpn                          :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibpn2ibpw.vpp                 :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibpn2ibpw                          :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_fifo.vpp                      :ARCv2MSS,SYNTH,SIM,MACRO
//#module alb_mss_bus_switch_fifo                               :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_bypbuf.vpp                    :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_bypbuf                             :ARCv2MSS




//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibp_cwbind.vpp                :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibp_cwbind                         :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibp_split.vpp                 :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibp_split                          :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_slv_ibp_buffer.vpp            :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_slv_ibp_buffer                     :ARCv2MSS



//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_rrobin.vpp                    :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_rrobin                             :ARCv2MSS


//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_mst_ibp_buffer.vpp            :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_mst_ibp_buffer                     :ARCv2MSS
//#source vpp/new_fabric/bus_switch/common/alb_mss_bus_switch_ibp_compr.vpp                 :ARCv2MSS,SYNTH,SIM,LOGIC
//#module alb_mss_bus_switch_ibp_compr                          :ARCv2MSS


//#source vpp/new_fabric/bus_switch/alb_mss_bus_switch_dw32_slv.vpp           :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/bus_switch/alb_mss_bus_switch_dw512_slv.vpp          :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/bus_switch/alb_mss_bus_switch_ibp_dw64_mst.vpp       :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/bus_switch/alb_mss_bus_switch_ibp_dw32_mst.vpp       :ARCv2MSS,SYNTH,SIM,LOGIC
//#source vpp/new_fabric/bus_switch/alb_mss_bus_switch_ibp_dw128_mst.vpp      :ARCv2MSS,SYNTH,SIM,LOGIC





//#vpp vpp/new_fabric/alb_mss_fab_system_memmap.h : ARCv2MSS,PARMS : {output}!User/alb_mss_fab_system_memmap.h!
//#vpp vpp/new_fabric/alb_mss_fab_system_memmap.s : ARCv2MSS,PARMS : {output}!User/alb_mss_fab_system_memmap.s!


//#vpp constraints/sdc.vpp      :PARMS,CLEARTEXT : {output}!constraints/archipelago.sdc!



