# Define constants
set script_dir [file dirname [lindex [split $argv " }"] [lsearch -all [split $argv] *zrci_xtor_mdb*]]]
set clk_ratio 5

# Parse input arguments
if {[info exist ::env(CMD)]} {
    set cmds [split [string trim $::env(CMD)] ";"]
    foreach c $cmds { 
        lappend pset [lindex $c 1]
        lappend elfs [lindex $c 3]
        lappend args [lrange $c 4 end]
        puts ">>> Info: running pset [lindex $c 1] = [lindex $c 3] [lrange $c 4 end]"
    }
} else {
    puts ">>> Error: Env CMD not defined, exiting"
    exit 1
}

set bdl 0
if {[info exist ::env(BDL)]} {
    set bdl $::env(BDL)
}
set load_list ""
if {[info exist ::env(LOAD)]} {
    set load_list $::env(LOAD)
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
set store_list ""
if {[info exist ::env(STORE)]} {
    set store_list $::env(STORE)
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
start_emulation $script_dir

# Compose MDB command to run
puts ">>> Info: MDB command to run"
set setnames {}
for {set i 0} {$i < [llength $pset]} {incr i} {
    lappend setnames pset[string map {, and : to} [lindex $pset $i]]
    set mdb_cmd "mdb -pset=[lindex $pset $i] -psetname=[lindex $setnames $i] -off=cr_for_more -nogoifmain $mdb_xargs "  ;# -on=verify_download to check binary
    if {$bdl == 1} {append mdb_cmd "-prop=download=2 "} {append mdb_cmd "-on=verify_download "}
    append mdb_cmd "-zebu -prop=zebu_cpuclk_tck_ratio=$clk_ratio -prop=retry_jtag=1000 -prop=zebu_timeout=9600000 [lindex $elfs $i] [lindex $args $i]"
    puts "$mdb_cmd"
    exec >&@stdout {*}$mdb_cmd
}
set mdb_cmd "mdb -multifiles=[join $setnames ","] -initiallog=mdb.log $start "
if {$gui == 1} {append mdb_cmd "-gui -OK 2>@1"} {append mdb_cmd "-cl -run -on=echo_to_stdout 2>@1"}
puts "$mdb_cmd"

# Backdoor load binary into main memory
if {$bdl == 1} {
    foreach elf $elfs {
        load_mem $mem_rtl_path -elf $elf
        puts ">>> Info: loading $elf into external memory"
    }
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
    waves_start $ztdb_path FULL_DUT_DUMP
}

# Set hybrid safety mode
#force_sig zebu_top.core_chip_dut.i_ext_personality_mode 0;

# Reset system and start clocks
puts ">>> Info: applying reset"
force_sig $reset_a 1; wait_for -cycles 20
force_sig $reset_a 0; run_all_clk_forever

# Pre set trigger for power dumping before starting mdb
if {$dump_power == 1} {
    set_trig zebu_top.trigger_power "zebu_top.switch_toggle_r == 1'b1"
}
run 20000000
run_all_clk_forever
# Execute MDB command
if {[catch {

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
      waves_start $ztdb_path FULL_DUT_DUMP

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

    # Backdoor dump data to file
    if {[file exist $store_list]} {
        set store_list_fd [open $store_list]
        foreach {addr size file} [read $store_list_fd] {
            puts ">>> Info: storing to $file from the memory at address $addr, amount $size"
            store_mem $mem_rtl_path -hex [list $file $addr $size]
        }
        close $store_list_fd
    }

    # Exit with mdb exit code
    exit $mdb_code

# Try to catch other possible error and handle them properly
} err]} {
    puts ">>> Error: $err occured at $::errorInfo"
    if {$mdb_pid} {
        catch {wait_mdb {puts $mdb_ch exit}}
    }
    exit 1
}


