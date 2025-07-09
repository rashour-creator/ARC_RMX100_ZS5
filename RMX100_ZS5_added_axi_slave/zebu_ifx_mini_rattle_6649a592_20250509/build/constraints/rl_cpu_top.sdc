# Library ARCv5EM-3.5.999999999
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
#`let cp_pfx = JS("(system_child[0].component.copy_prefix == null) ? '' : system_child[0].component.copy_prefix ")


# ----------------------------------------------------------------------
# Clocks
# ----------------------------------------------------------------------

     
   
   
 

   

create_clock -name clk -period 50.000 [get_ports clk]  
set_drive 0 clk

set_clock_uncertainty -setup 0.200 clk
set_clock_uncertainty -hold  0.050 clk
set_clock_uncertainty -setup [expr 0.05 * [get_attr [get_clocks clk] period]] -rise_from clk -fall_to clk
set_clock_uncertainty -setup [expr 0.05 * [get_attr [get_clocks clk] period]] -fall_from clk -rise_to clk
set_clock_transition 0.1 clk
set_dont_touch_network clk

     
   
   
 

   

create_clock -name vir_async_clk -period 50.000   

     
   
   
 

   

create_clock -name ref_clk -period 50.000 [get_ports ref_clk]  
set_drive 0 ref_clk

set_clock_uncertainty -setup 0.200 ref_clk
set_clock_uncertainty -hold  0.050 ref_clk
set_clock_uncertainty -setup [expr 0.05 * [get_attr [get_clocks ref_clk] period]] -rise_from ref_clk -fall_to ref_clk
set_clock_uncertainty -setup [expr 0.05 * [get_attr [get_clocks ref_clk] period]] -fall_from ref_clk -rise_to ref_clk
set_clock_transition 0.1 ref_clk
set_dont_touch_network ref_clk

     
   
   
 

   

create_clock -name wdt_clk -period 50.000 [get_ports wdt_clk]  
set_drive 0 wdt_clk

set_clock_uncertainty -setup 0.200 wdt_clk
set_clock_uncertainty -hold  0.050 wdt_clk
set_clock_uncertainty -setup [expr 0.05 * [get_attr [get_clocks wdt_clk] period]] -rise_from wdt_clk -fall_to wdt_clk
set_clock_uncertainty -setup [expr 0.05 * [get_attr [get_clocks wdt_clk] period]] -fall_from wdt_clk -rise_to wdt_clk
set_clock_transition 0.1 wdt_clk
set_dont_touch_network wdt_clk

# ----------------------------------------------------------------------
# Generated Clocks
# ----------------------------------------------------------------------





set_clock_groups  -asynchronous  -group { clk } -group { vir_async_clk } -group { ref_clk } -group { wdt_clk }


#------------------------------------------------------------------------------
# Input Constraints
#------------------------------------------------------------------------------


      

   
   
   
set_input_delay [expr 0.25 * [get_attr [get_clocks clk] period]] -clock [get_clocks clk] [get_ports * -filter {@port_direction == in}] 



      

   
   
   

remove_input_delay -clock [get_clocks clk] [get_ports test_mode -filter {@port_direction == in}]


      

   
   
   

remove_input_delay -clock [get_clocks clk] [get_ports LBIST_EN -filter {@port_direction == in}]


      

   
   
   

remove_input_delay -clock [get_clocks clk] [get_ports arcnum* -filter {@port_direction == in}]


      

      

      

      

      

      
remove_input_delay [get_ports [get_object_name [get_clocks *]]]

set_input_transition 0.1 [remove_from_collection [get_ports * -filter {@port_direction == in}] [get_ports [get_object_name [get_clocks * -filter {@is_generated == false}]]]]

#------------------------------------------------------------------------------
# Output Constraints
#------------------------------------------------------------------------------


      


set_output_delay [expr 0.25 * [get_attr [get_clocks clk] period]] -clock [get_clocks clk] [get_ports * -filter {@port_direction == out}] 

      


#------------------------------------------------------------------------------
# Max Delay Paths
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# False Paths
#------------------------------------------------------------------------------


      
  


   
   
set_false_path -from [get_ports rst_cpu_req_a -filter {@port_direction == in}]  

      
  


   
   
set_false_path -from [get_ports soft_reset_prepare_a -filter {@port_direction == in}]  

      
  


   
   
set_false_path -from [get_ports soft_reset_req_a -filter {@port_direction == in}]  

      
  


   
   
set_false_path -from [get_ports rst_init_disable_a -filter {@port_direction == in}]  

      
  


   
   
set_false_path -from [get_ports rnmi_a -filter {@port_direction == in}]  



#------------------------------------------------------------------------------
# Multi-through False Paths when XY is configured
# false path from DCCM/XCCM/YCCM memory outputs to CCM inputs because LD/ST cannot use XY as address arguments, raises exception
# false path from DCCM/XCCM/YCCM memory outputs to branch/jump instruction target because Jcc,Bcc cannot use XY as target, raises exception
# false path from DCCM/XCCM/YCCM memory outputs to MODIF instruction, raises exception if XY is used as source
#------------------------------------------------------------------------------






# -----------------------------------------------------------------------------
# Multicycle paths
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Case analysis
# -----------------------------------------------------------------------------

set_case_analysis 0 [get_ports test_mode]
set_case_analysis 0 [get_ports *LBIST_EN]
set_case_analysis 0 [get_ports arcnum*]
