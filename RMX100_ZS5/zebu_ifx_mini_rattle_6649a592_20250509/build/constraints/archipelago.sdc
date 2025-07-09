# Library ARCv2MSS-2.1.999999999
#----------------------------------------------------------------------------
#
# Copyright (C) 2010-2014 Synopsys, Inc. All rights reserved.
#
# SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
# work of Synopsys, Inc., and is fully protected under copyright and
# trade secret laws. You may not view, use, disclose, copy, or distribute
# this file or any information contained herein except pursuant to a
# valid written license from Synopsys, Inc.
#----------------------------------------------------------------------------















# ----------------------------------------------------------------------
# Clocks
# ----------------------------------------------------------------------



     
	


create_clock -name clk -period 50.000 [get_ports clk]   
set_drive 0 clk 

set period_of_clk [get_attr [get_clocks clk] period]

set_clock_uncertainty -setup 0.200 clk
set_clock_uncertainty -hold  0.050 clk
set_clock_uncertainty -setup [expr 0.05 * ${period_of_clk}] -rise_from clk -fall_to clk
set_clock_uncertainty -setup [expr 0.05 * ${period_of_clk}] -fall_from clk -rise_to clk
set_clock_transition 0.1 clk
#set_dont_touch_network only needed for  Cadence tools
if {[info exists synopsys_program_name] && (($synopsys_program_name == "fc_shell") || ($synopsys_program_name == "rtl_shell") || ($synopsys_program_name == "dc_shell"))} {

}  else {
set_dont_touch_network clk
}



     
	


create_clock -name vir_async_clk -period 50.000  
set period_of_vir_async_clk [get_attr [get_clocks vir_async_clk] period]



     
	


create_clock -name ref_clk -period 50.000 [get_ports ref_clk]   
set_drive 0 ref_clk 

set period_of_ref_clk [get_attr [get_clocks ref_clk] period]

set_clock_uncertainty -setup 0.200 ref_clk
set_clock_uncertainty -hold  0.050 ref_clk
set_clock_uncertainty -setup [expr 0.05 * ${period_of_ref_clk}] -rise_from ref_clk -fall_to ref_clk
set_clock_uncertainty -setup [expr 0.05 * ${period_of_ref_clk}] -fall_from ref_clk -rise_to ref_clk
set_clock_transition 0.1 ref_clk
#set_dont_touch_network only needed for  Cadence tools
if {[info exists synopsys_program_name] && (($synopsys_program_name == "fc_shell") || ($synopsys_program_name == "rtl_shell") || ($synopsys_program_name == "dc_shell"))} {

}  else {
set_dont_touch_network ref_clk
}



     
	


create_clock -name wdt_clk -period 50.000 [get_ports wdt_clk]   
set_drive 0 wdt_clk 

set period_of_wdt_clk [get_attr [get_clocks wdt_clk] period]

set_clock_uncertainty -setup 0.200 wdt_clk
set_clock_uncertainty -hold  0.050 wdt_clk
set_clock_uncertainty -setup [expr 0.05 * ${period_of_wdt_clk}] -rise_from wdt_clk -fall_to wdt_clk
set_clock_uncertainty -setup [expr 0.05 * ${period_of_wdt_clk}] -fall_from wdt_clk -rise_to wdt_clk
set_clock_transition 0.1 wdt_clk
#set_dont_touch_network only needed for  Cadence tools
if {[info exists synopsys_program_name] && (($synopsys_program_name == "fc_shell") || ($synopsys_program_name == "rtl_shell") || ($synopsys_program_name == "dc_shell"))} {

}  else {
set_dont_touch_network wdt_clk
}



     
	


create_clock -name jtag_tck -period 100.000 [get_ports jtag_tck]   
set_drive 0 jtag_tck 

set period_of_jtag_tck [get_attr [get_clocks jtag_tck] period]

set_clock_uncertainty -setup 0.200 jtag_tck
set_clock_uncertainty -hold  0.050 jtag_tck
set_clock_uncertainty -setup [expr 0.05 * ${period_of_jtag_tck}] -rise_from jtag_tck -fall_to jtag_tck
set_clock_uncertainty -setup [expr 0.05 * ${period_of_jtag_tck}] -fall_from jtag_tck -rise_to jtag_tck
set_clock_transition 0.1 jtag_tck
#set_dont_touch_network only needed for  Cadence tools
if {[info exists synopsys_program_name] && (($synopsys_program_name == "fc_shell") || ($synopsys_program_name == "rtl_shell") || ($synopsys_program_name == "dc_shell"))} {

}  else {
set_dont_touch_network jtag_tck
}


# ----------------------------------------------------------------------
# Generated Clocks
# We recommend replacing  architectural  clock gating  modules in the  RTL by  a wrapper (with  same  port names) containing a technology specific  ICG cell before  running  synthesis
# In that case, if the  ICG instance is called ck_gate0, all you need to  possibly modify in the incoming  SDC is the name of the output pin  (Q)  of the ICG cell


# ----------------------------------------------------------------------









  set_clock_groups  -asynchronous  -group { clk } -group { vir_async_clk } -group { ref_clk } -group { wdt_clk } -group { jtag_tck }
#------------------------------------------------------------------------------
# Input Constraints
#------------------------------------------------------------------------------



  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports *  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_clk}] -clock [get_clocks clk] [get_ports * -filter {@port_direction == in}] 

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports * -filter {@port_direction == in}] }



  remove_input_delay -clock [get_clocks clk] [get_ports test_mode -filter {@port_direction == in}]
 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports test_mode -filter {@port_direction == in}] }



  remove_input_delay -clock [get_clocks clk] [get_ports LBIST_EN -filter {@port_direction == in}]
 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports LBIST_EN -filter {@port_direction == in}] }



  remove_input_delay -clock [get_clocks clk] [get_ports arcnum* -filter {@port_direction == in}]
 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports arcnum* -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports rst_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports rst_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports rst_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports rst_cpu_req_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports rst_cpu_req_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports rst_cpu_req_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports soft_reset_prepare_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports soft_reset_prepare_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports soft_reset_prepare_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports soft_reset_req_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports soft_reset_req_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports soft_reset_req_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports rst_init_disable_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports rst_init_disable_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports rst_init_disable_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports rnmi_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports rnmi_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports rnmi_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports dbg_unlock*  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_clk}] -clock [get_clocks clk] [get_ports dbg_unlock* -filter {@port_direction == in}] 

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports dbg_unlock* -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports *arc_halt_req_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports *arc_halt_req_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports *arc_halt_req_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports *arc_run_req_a  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports *arc_run_req_a  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports *arc_run_req_a -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports safety_iso_enb[0]  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports safety_iso_enb[0]  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports safety_iso_enb[0] -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports safety_iso_enb[1]  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_vir_async_clk}] -clock [get_clocks vir_async_clk] [get_ports safety_iso_enb[1]  -filter {@port_direction == in}]

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports safety_iso_enb[1] -filter {@port_direction == in}] }


  foreach_in_collection clkname [get_clocks -quiet *] {remove_input_delay  -clock $clkname [get_ports jtag_*  -filter {@port_direction == in}]}
  set_input_delay [expr 0.25 * ${period_of_jtag_tck}] -clock [get_clocks jtag_tck] [get_ports jtag_* -filter {@port_direction == in}] 

 
#If the  configuration you have  built does not have generated  clocks, then this constraint is superflous and an  error referring to non-existent *_gclk can be ignored
#foreach_in_collection gclkname [get_clocks -quiet *_gclk] { remove_input_delay  -clock $gclkname [get_ports jtag_* -filter {@port_direction == in}] }
remove_input_delay [get_ports [get_object_name [get_clocks * -filter {@is_generated == false && @full_name !~ *vir_async_clk}]]]



set_input_transition 0.1 [remove_from_collection [get_ports * -filter {@port_direction == in}] [get_ports [get_object_name [get_clocks * -filter {@is_generated == false}]]]]

#------------------------------------------------------------------------------
# Output Constraints
#------------------------------------------------------------------------------

foreach_in_collection clkname [get_clocks -quiet *] {remove_output_delay  -clock $clkname [get_ports *  -filter {@port_direction == out}]}
set_output_delay [expr 0.25 * ${period_of_clk}] -clock [get_clocks clk] [get_ports * -filter {@port_direction == out}] 
foreach_in_collection clkname [get_clocks -quiet *] {remove_output_delay  -clock $clkname [get_ports wdt_reset_wdt_clk0  -filter {@port_direction == out}]}
set_output_delay [expr 0.25 * ${period_of_wdt_clk}] -clock [get_clocks wdt_clk] [get_ports wdt_reset_wdt_clk0 -filter {@port_direction == out}] 
foreach_in_collection clkname [get_clocks -quiet *] {remove_output_delay  -clock $clkname [get_ports safety_isol_change*  -filter {@port_direction == out}]}
set_output_delay [expr 0.25 * ${period_of_clk}] -clock [get_clocks clk] [get_ports safety_isol_change* -filter {@port_direction == out}] 
foreach_in_collection clkname [get_clocks -quiet *] {remove_output_delay  -clock $clkname [get_ports *jtag_tdo*  -filter {@port_direction == out}]}
set_output_delay [expr 0.25 * ${period_of_jtag_tck}] -clock [get_clocks jtag_tck] [get_ports *jtag_tdo* -filter {@port_direction == out}] 
foreach_in_collection clkname [get_clocks -quiet *] {remove_output_delay  -clock $clkname [get_ports *jtag_rtck*  -filter {@port_direction == out}]}
set_output_delay [expr 0.25 * ${period_of_clk}] -clock [get_clocks clk] [get_ports *jtag_rtck* -filter {@port_direction == out}] 



#------------------------------------------------------------------------------
# Max Delay Paths
#------------------------------------------------------------------------------

set_max_delay -ignore_clock_latency  [expr 0.4*50.000] -from [get_cells -hier * -filter {@is_sequential==true && @is_hierarchical==false && @full_name=~*idw_dbp/*u_jtag_port/u_alb_debug_port/i_do_bvci_cycle_r_reg}]  -to [get_cells -hier * -filter {@is_sequential==true && @is_hierarchical==false && @full_name=~*idw_dbp/*u_jtag_port/u_alb_sys_clk_sync/u_cdc_sync_*/sample_meta*}]
set_min_delay -ignore_clock_latency  [expr 0.200] -from [get_cells -hier * -filter {@is_sequential==true && @is_hierarchical==false && @full_name=~*idw_dbp/*u_jtag_port/u_alb_debug_port/i_do_bvci_cycle_r_reg}]  -to [get_cells -hier * -filter {@is_sequential==true && @is_hierarchical==false && @full_name=~*idw_dbp/*u_jtag_port/u_alb_sys_clk_sync/u_cdc_sync_*/sample_meta*}]



#------------------------------------------------------------------------------
# False Paths
#------------------------------------------------------------------------------

	


	
	
	


	
	
	 
# Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint
set_false_path -from [get_ports rst_cpu_req_a -filter {@port_direction == in}]  
	 
# Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint
set_false_path -from [get_ports soft_reset_prepare_a -filter {@port_direction == in}]  
	 
# Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint
set_false_path -from [get_ports soft_reset_req_a -filter {@port_direction == in}]  
	 
# Explanation :  Quasi-static signal. This input will be tied off before reset to a certain value and hence be a constant start-point.
set_false_path -from [get_ports rst_init_disable_a -filter {@port_direction == in}]  
	 
# Explanation :  Asynchronous input;  but constraining input delay to vir_async_clk is sufficient constraint due to clk and vir_async_clk defined as asynchronous; TCM  tool prefers not to have this redundant FP constraint
set_false_path -from [get_ports rnmi_a -filter {@port_direction == in}]  
	 
set_false_path -from [get_ports rst_a -filter {@port_direction == in}] -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*u_rst_cdc_s_sync_r_s*U_SAMPLE_META*sample_meta*}] 
	 
set_false_path -from [get_ports rst_a -filter {@port_direction == in}] -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*u_presetdbg_cdc_s*U_SAMPLE_META*sample_meta*}] 
	 
set_false_path -from [get_ports *arc_halt_req_a -filter {@port_direction == in}]  
	 
set_false_path -from [get_ports *arc_run_req_a -filter {@port_direction == in}]  
	 
# safety_iso_enb[0] is an async input signal, will be CDC synchronized before use
set_false_path -from [get_ports safety_iso_enb[0] -filter {@port_direction == in}]  
	 
# safety_iso_enb[1] is an async input signal, will be CDC synchronized before use
set_false_path -from [get_ports safety_iso_enb[1] -filter {@port_direction == in}]  
	 
set_false_path   -to [get_cells -hier * -filter {@is_sequential==true && @is_hierarchical==false && @full_name=~*iarcv_dm_top/*u_safety_iso_enb_pclk_s_sync*U_SAMPLE_META*sample_meta*}]
	 
set_false_path  -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*arc2dm_halt_ack}] 
	 
set_false_path  -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*arc2dm_run_ack}] 
	 
set_false_path  -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*arc2dm_havereset_a}] 
	 
set_false_path  -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*hart_unavailable}] 
	 
set_false_path  -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*sys_halt_r}] 
	 
set_false_path  -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/ndmreset_a}] 
	 
set_false_path  -through [get_pins -hier * -filter {@full_name=~*iarcv_dm_top/*dm2arc_halt_on_reset_a}] 
	 
set_false_path -from [get_ports rst_a -filter {@port_direction == in}] -through [get_pins -hier * -filter {@full_name=~*idw_dbp/*reset_ctrl*U_SAMPLE_META*sample_meta*}] 


#------------------------------------------------------------------------------
# False Paths  - multi-through
#------------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Multicycle paths
# -----------------------------------------------------------------------------




#--------------

# -----------------------------------------------------------------------------
# Source synchronous data_check
# -----------------------------------------------------------------------------

#------------------------------------  data check



# -----------------------------------------------------------------------------
# Case analysis
# -----------------------------------------------------------------------------

set_case_analysis 0 [get_ports test_mode]
set_case_analysis 0 [get_ports *LBIST_EN]
set_case_analysis 0 [get_ports arcnum*]
set_case_analysis 0 [get_ports *test_mode]
set_case_analysis 0 [get_ports *test_mode]

# -----------------------------------------------------------------------------
# Ideal network
# -----------------------------------------------------------------------------

