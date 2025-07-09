 
# Define constants
set script_dir [file dirname [lindex [split $argv " }"] [lsearch -all [split $argv] *zrci_xtor_mdb*]]]

set clk_ratio 5

# Parse input arguments
set proj_path ""
if {[info exist ::env(PROJ_PATH)]} {
    set proj_path $::env(PROJ_PATH)
} else {
    puts ">>> Error: Project path not defined, exiting"
    exit 1
}

if {[info exist ::env(CMD)]} {
    set cmd [string trim $::env(CMD)]
    set elf [string range $cmd 0 [expr {[string first " " "$cmd "]}]]
    puts ">>> Info: running $elf"
} else {
    puts ">>> Error: Env CMD not defined, exiting"
    exit 1
}

if {[info exist ::env(CORES)]} {
    set cores $::env(CORES)
} else {
    puts ">>> Warning: Env CORES not defined, setting to 1"
    set cores 1
}

set bdl 0
if {[info exist ::env(BDL)]} {
    set bdl $::env(BDL)
}
set load_list ""
if {[info exist ::env(LOAD)]} {
    set load_list $::env(LOAD)
}
if {[info exist ::env(TRIAL)]} {
    set trial $::env(TRIAL)
}
if {[string trim $load_list] != ""} {
    if {[file exist $load_list]} {
        set bdl 1
        puts ">>> Info: Using load list $load_list"
    } else {
        puts ">>> Error: Load file $load_list can not be found"
        exit 1
    }
}
set start ""
if {[info exist ::env(START)]} {
    set start "-startup=$::env(START)"
}
set gui 0
if {[info exist ::env(GUI)]} {
    set gui $::env(GUI)
}
set dump_waves 0
if {[info exist ::env(WAVES)]} {
    set dump_waves $::env(WAVES)
}
set dump_power 0
if {[info exist ::env(PWR)]} {
    set dump_power $::env(PWR)
}
set skip_win 0
if {[info exist ::env(SKIP)]} {
    set skip_win $::env(SKIP)
}
set mdb_xargs ""
if {[info exist ::env(XARGS)]} {
    set mdb_xargs $::env(XARGS)
}
set ztdb_path "./fwc.ztdb"
if {[info exist ::env(ZTDB)] && [string trim $::env(ZTDB)] != ""} {
    set ztdb_path $::env(ZTDB)
}
set ztdb_path [file normalize $ztdb_path]

# Load auxiliary functions and variables
source $script_dir/zrci_automation.tcl


# Start emulation
start_emulation $script_dir $proj_path

# Compose MDB command to run
puts ">>> Info: MDB command to run"
if {$cores == 1} {
    set mdb_cmd "mdb -off=cr_for_more $start $mdb_xargs " ;# -on=verify_download to check binary
    if {$bdl == 1} {append mdb_cmd "-prop=download=2 "}
    append mdb_cmd "-zebu -prop=zebu_cpuclk_tck_ratio=$clk_ratio -prop=zebu_timeout=1500000000 "
    if {$gui == 1} {append mdb_cmd "-gui -OK -nogoifmain "} {append mdb_cmd "-cl -run -on=echo_to_stdout "}
    append mdb_cmd "$cmd 2>@1" ;# redirect stderr to stdout so it is printed in console
} else {
    set setnames {}
    for {set i 1} {$i <= $cores} {incr i} {
        set mdb_cmd "mdb -pset=$i -psetname=core$i -off=cr_for_more -on=verify_download -nogoifmain $mdb_xargs "
        if {$i != 1} {append mdb_cmd "-off=hostlink "}
        if {$bdl == 1 || $i != 1} {append mdb_cmd "-prop=download=2 "}
        append mdb_cmd "-zebu -prop=zebu_cpuclk_tck_ratio=$clk_ratio -prop=zebu_timeout=150000 $cmd "
        puts "$mdb_cmd"
        exec >&@stdout {*}$mdb_cmd
        lappend setnames core$i
    }
    set mdb_cmd "mdb -multifiles=[join $setnames ","] -initiallog=mdb.log $start "
    if {$gui == 1} {append mdb_cmd "-gui -OK "} {append mdb_cmd "-cl -run -on=echo_to_stdout "}
 append mdb_cmd " 2>@1" ;# redirect stderr to stdout so it is printed in console
}
puts "$mdb_cmd"

# Backdoor load binary into main memory
if {$bdl == 1} {
    load_mem $mem_rtl_path -elf $elf
    puts ">>> Info: loading $elf into external memory"
    if {[file exist $load_list]} {
        set load_list_fd [open $load_list]
        foreach {addr file} [read $load_list_fd] {
            set file [file join [file dirname $load_list] $file]
            puts ">>> Info: loading $file in the memory at address $addr..."
            load_mem $mem_rtl_path -bin [list $file $addr]
        }
        close $load_list_fd
    }
}

# Capture waves on full application
if {$dump_waves == 1} {
    puts ">>> Info: start dumping waves"
    #waves_start $ztdb_path FULL_DUT_DUMP
 waves_start $ztdb_path FWC_DUMP
}

# Set hybrid safety mode
#force_sig zebu_top.core_chip_dut.i_ext_personality_mode 0;

# Reset system and start clocks
puts ">>> Info: applying reset"
force_sig $reset_a 0; wait_for -cycles 20
force_sig $reset_a 1; run_all_clk_forever

# Pre set trigger for power dumping before starting mdb
if {$dump_power == 1} {
    set_trig zebu_top.trigger_power "zebu_top.switch_toggle_r == 1'b1"
}

# Execute MDB command
if {[catch {
    set start_cycles [expr {[string range [get zebu_top.ref_clk_cnt -radix dec] 4 end] + 0}]
    #puts ">> in tcl before enterong ref_clk_cnt = $start_cycles"
    # Start MDB in background
    start_mdb $mdb_cmd

    # Capture waves on power window
    if {$dump_power == 1} {
      # Skip first triggers if needed
      while {$skip_win > 0} {
        wait_for -trig zebu_top.trigger_power "zebu_top.switch_toggle_r == 1'b1"
        wait_for -trig zebu_top.trigger_power "zebu_top.switch_toggle_r == 1'b0"
        incr skip_win -1
      }
      wait_for -trig zebu_top.trigger_power "zebu_top.switch_toggle_r == 1'b1"
      #wait_for -trig zebu_top.trigger_pc "zebu_top.core0_pc == 32'h$::env(START_PC)"
      puts ">>> Info: power-start trigger reached"
      #waves_start $ztdb_path FULL_DUT_DUMP
   waves_start $ztdb_path FWC_DUMP

      wait_for -trig zebu_top.trigger_power "zebu_top.switch_toggle_r == 1'b0"
      #wait_for -trig zebu_top.trigger_pc "zebu_top.core0_pc == 32'h$::env(STOP_PC)"
      waves_stop
      puts ">>> Info: power-stop trigger reached, let the application to finish"
      run_all_clk_forever
    }
    
   
    # Wait mdb completion and capture exit code
    set mdb_code [wait_mdb]
    # Stop wave dumping
    if {$dump_waves == 1} {
      waves_stop
      puts ">>> Info: stop dumping waves"
    }
   # set end_cycles [expr {[string range [get zebu_top.ref_clk_cnt -radix dec] 4 end] + 0}]
   # puts ">> in tcl before exiting ref_clk_cnt = $end_cycles"
    
    #set net_cycles [expr { $end_cycles - $start_cycles }]
    #puts ">> in tcl before exiting net_cycles = $net_cycles"
    #set fileID [open "/remote/sdgedt/tools/mina_gendi/temp_zebu_on_fabric/zebu-on-fabric/cycles.txt" "a"]  ;# Open the file for writing (create or overwrite)
   # puts $fileID "$net_cycles"  ;# Write to the file
   # close $fileID
   
    exit $mdb_code

 #Try to catch other possible error and handle them properly
} err]} {
    puts ">>> Error: $err occured at $::errorInfo"
    if {$mdb_pid} {
        catch {wait_mdb {puts $mdb_ch exit}}
    }
    exit 1
}


 
