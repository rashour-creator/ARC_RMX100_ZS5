# -----------------------------------------------------------------------------
# CONFIDENTIAL AND PROPRIETARY INFORMATION
# Copyright 2002-2005 ARC International (Unpublished)
# All Rights Reserved.
#
# This document, material and/or software contains confidential
# and proprietary information of ARC International and is
# protected by copyright, trade secret and other state, federal,
# and international laws, and may be embodied in patents issued
# or pending.  Its receipt or possession does not convey any
# rights to use, reproduce, disclose its contents, or to
# manufacture, or sell anything it may describe.  Reverse
# engineering is prohibited, and reproduction, disclosure or use
# without specific written authorization of ARC International is
# strictly forbidden.  ARC and the ARC logotype are trademarks of
# ARC International.
# 
# ARC Product:  @@PRODUCT_NAME@@ v@@VERSION_NUMBER@@
# File version: $Revision$
# ARC Chip ID:  0
#
# Description:
#
# -----------------------------------------------------------------------------
#
#	File:		options.tcl
#
#	Purpose:	Options file for the ARC600 RDF Program
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Synthesis Configuration Variables
# -----------------------------------------------------------------------------

# Real Time Trace unit present
set arc_rtt 0 

# Set true if sync resets are selected
set arc_sync_resets false 

# The memory protocol
set arc_mem_protocol bvci


# ------------------------------------------------------------------------------
# Synthesis control
# ------------------------------------------------------------------------------

# The name of the elaborated top level
set arc_top_level_design_name           "core_chip" 

# Name of main synthesis level of the design      

set arc_synthesis_top                  "archipelago" 

# Name of the top level arcitecture     
set arc_top_level_architecture          "str"
    
# Control levels of detail observed                             
set arc_use_verbose_mode                1
                                      
# Number of dedicated scan chains used
set arc_number_of_scan_chains  4

# Default max fanout                              
set arc_max_fanout                      32                                    


# ---------------------------------------------------------------------------------
# Design specific
# ---------------------------------------------------------------------------------

# Clock period for main clock
set arc_local_clock_period              50.000 

# Clock period for main clock
set arc_jtag_clock_period               100.000 

# Clock period for external system clock                                 
set arc_system_clock_period             [expr $arc_local_clock_period * 1]

# Clock uncertainty	
set arc_clock_skew  0.2

set arc_sys_clock_hold_margin  0.05

# Default maximum edge rate should not exceed 1/4 clk frq also see vendor req.
set arc_max_transition                  [expr $arc_local_clock_period / 4.0]     

# Clock uncertainty for system clock, since system and cpu clocks are 
# synchronous, the skew figure is the same
set arc_sys_clock_skew  $arc_clock_skew
 
# RTT clock same as main clock                                  
set arc_rtt_clock_period                $arc_local_clock_period
 
# The maximum frequency at which Write strobe signals can occur              
set arc_wrstr_strobe_period             $arc_local_clock_period
 
# Clock edge rate at each sequential element              


# -----------------------------------------------------------------------------
# Library setup
# -----------------------------------------------------------------------------

# Ram library file name              
set arc_ram_libraries  "arc_rams.db" 

# Other synthesis paths         
set arc_synthesis_library_path  "./lib . verilog "

# -----------------------------------------------------------------------------
# PrimeTime Design Specific Configuration Variables
# -----------------------------------------------------------------------------

                                    

#--------------------------------------------------------------------------------
# End of file
#--------------------------------------------------------------------------------












