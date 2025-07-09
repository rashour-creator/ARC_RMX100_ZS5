# Load auxiliary functions and start simulation
set script_dir [file dirname [lindex [split $argv " }"] [lsearch -all [split $argv] *zrci_cct_mdb*]]]
source $script_dir/zrci_automation.tcl
start_emulation $script_dir

# Parse input arguments
if {[info exist ::env(CCT_PATHS)]} {
    set binaries [string trim $::env(CCT_PATHS)]
    puts ">>> Info: found [llength $binaries] CCTs to execute"
} else {
    puts ">>> Error: env CCT_PATHS not defined, exiting"
    exit 1
}

# Iterate over all binaries
set clk_ratio 4
foreach cct $binaries {

    # Find files
    set cores [expr [llength $cct] - 1]
    set cmd   [lindex $cct 0]
    set bin   [lindex $cct 1]

    # Backdoor load binary into main memory
    if {$::env(BDL) == 1 && $cores == 1 } {load_mem $mem_rtl_path -elf $bin}

    # Reset system and start clocks
    puts ">>> Info: applying reset"
    stop_all_clk
    force_sig $reset_a 0; wait_for -cycles 20
    force_sig $reset_a 1; run_all_clk_forever

    # Compose MDB command to run
    puts ">>> Info: Running MDB"
    if {$cores == 1} {
        set    mdb_cmd "mdb -off=icnts -noprofile -notrace -off=cr_for_more -on=verify_download -on=hostlink "
        append mdb_cmd "-zebu -prop=zebu_cpuclk_tck_ratio=$clk_ratio -prop=zebu_timeout=50000 "
        if {$::env(GUI) != 1} {append mdb_cmd "-cl -startup=$cmd "} {append mdb_cmd "-gui -OK "}
        if {$::env(BDL) == 1} {append mdb_cmd "-prop=download=2 "}
        append mdb_cmd "$bin"
    } else {
        set setnames {}
        for {set i 1} {$i <= $cores} {incr i} {
            set    mdb_cmd "mdb -pset=$i -psetname=core$i -off=icnts -noprofile -notrace -off=cr_for_more -on=verify_download "
            append mdb_cmd "-zebu -prop=zebu_cpuclk_tck_ratio=$clk_ratio -prop=zebu_timeout=50000 -nogoifmain "
            if {$i == 1} {append mdb_cmd "-on=hostlink "} else {append mdb_cmd "-off=hostlink "}
            append mdb_cmd "[lindex $cct $i]"
            puts "$mdb_cmd"
            exec >&@stdout {*}$mdb_cmd
            lappend setnames core$i
        }
        set mdb_cmd "mdb -multifiles=[join $setnames ","] -initiallog=mdb.log "
        if {$::env(GUI) != 1} {append mdb_cmd "-cl -startup=$cmd "} {append mdb_cmd "-gui -OK "}
    }
    puts "$mdb_cmd"

    # Execute MDB command
    start_mdb [append mdb_cmd " 2>@1"] 60000 ;# redirect stderr to sdout, 60s timeout
    wait_mdb
}

exit 0
