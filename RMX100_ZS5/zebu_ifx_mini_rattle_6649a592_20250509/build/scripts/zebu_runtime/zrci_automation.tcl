
# Global variables
variable ref_clk      zebu_top.zebuclk_ref_clk
variable jtag_transactor_clk zebu_top.zebuclk_jtag_clk 
variable reset_a      zebu_top.rst_a
variable runtime_path "defined_at_start_emulation"
variable mem_rtl_path "defined_at_start_emulation"
variable word_size    128
variable base_addr    0000

# Auxiliary methods
proc start_emulation {path} {
    variable ref_clk
    variable runtime_path
    variable mem_rtl_path

    set runtime_path $path
    config default_clock posedge "timestamp"
    zemi3 -enable
    if {[info exist ::env(ZEBU_CUSTOM_TB)]} {
      testbench -load $::env(ZEBU_CUSTOM_TB)
    } else {
      testbench -load $runtime_path/TB.so
    }
    start_zebu -designFeatures $runtime_path/designFeatures
    set mem_rtl_path [lindex [memory] [lsearch [memory] *u_alb_mss_mem_ram.mem_r]]
}

# Add basic support of Verilog literal formats,
# e.g. [format %vb 6] -> 'b110, and [fromat %8vh 255] -> 8'hff
proc format {fmt args} {
    regsub -all {%(\d*)v([obd])} $fmt {\1'\2%\2} fmt
    regsub -all {%(\d*)vh}       $fmt {\1'h%x}   fmt
    # WORKAROUND:
    # lookbehind is not supported by Tcl re (only lookahead),
    # so use second regsub to revert substitution for %% case
    regsub -all {%(\d*)'([obd])%\2} $fmt {%%\1v\2} fmt
    regsub -all {%(\d*)'h%x}        $fmt {%%\1vh}  fmt

    ::format $fmt {*}$args
}
proc get_val_format_pair {val} {
    switch -regexp -matchvar match -- $val {
        {(?ix)^\s*(?:0x|\d*'h)([_0-9a-f]+)\s*$} {set format hexa}
        {(?ix)^\s*(?:0|\d*'o) ([_0-7]+)   \s*$} {set format oct}
        {(?ix)^\s*(?:0b|\d*'b)([_01]+)    \s*$} {set format bin}
        {(?ix)^\s*(?:\d*'d)?  ([_0-9]+)   \s*$} {set format dec}
    }
    set val [string map {_ ""} [lindex $match 1]]

    return [list $val $format]
}


proc force_sig {args} {
    puts ">>> Info: force_sig begin:"
    foreach {sig val} $args {
        lassign [get_val_format_pair $val] val format
        force $sig $val -freeze -radix $format
    }
    puts ">>> Info: force_sig end"
}
proc release_sig {args} {
    foreach sig $args {
        release $sig
    }
}

proc read_sig {args} {
    set vals [list]
    foreach sig $args {
        lappend vals 0x[get $sig -radix hexa]
    }
    return $vals
}
proc write_sig {args} {
    foreach {sig val} $args {
        lassign [get_val_format_pair $val] val format
        force $sig $val -radix $format -deposit
    }
}

proc waves_start {{out_dir ""} {value_set ""}} {
    variable FWC_unnamed_cnt

    if ![llength $out_dir] {
        set out_dir [file normalize "./fwc_dump_[incr FWC_unnamed_cnt].ztdb"]
        puts ">>>Warning: ZTDB name is not given, use '$out_dir' as default"
    }
    if ![llength $value_set] {
        foreach v [get value_sets] {lappend value_set [lindex $v 1]}
        puts ">>>Warning: FWC value set is not specified, so use all of them, namely {$value_set}"
    }
    if [file exists $out_dir] {file delete -force $out_dir}
    #set fid [dump -file $out_dir -qiwc]
    #foreach vs $value_set { dump -add_value_set $vs -fid $fid }
    #dump -interval 10s -fid $fid
    #dump -enable -fid $fid

    set fid [dump -file $out_dir -awc  -sampling "timestamp"]

    # Dump + Size Slice
    dump -fid $fid -add_value_set FULL_DUT_DUMP
    dump -fid $fid -add_value_set FULL_DUT_DUMP_PORTS
    dump -fid $fid -interval 5000MB
    dump -fid $fid -enable
}

proc waves_stop {}  {
    dump -disable
    dump -flush
    dump -close
}

proc run_clk_forever {clk} {
    run -clock $clk
}

proc stop_clk {clk} {
    run -disable $clk
}

proc run_all_clk_forever {} {
    run
}

proc stop_all_clk {} {
    run -disable all
}

variable trig_done 0
proc trig_callback {} {
    #puts ">>> Trigger reached: cycle [run 0]"
    variable trig_done 1
}

proc set_trig {trig expr} {
    variable trig_done 0

    stop_all_clk
    #puts ">>> Setting trigger: cycle [run 0]"
    stop -expression $expr $trig
    stop -enable $trig -action trig_callback
    stop -config stop_on_notify on
    run_all_clk_forever
}

proc get_clk_count {clk} {
    #lindex [lindex [get -cycles primary_clocks] 0] 1
    run 0 
}

proc wait_for {cond args} {
    variable ref_clk
    variable trig_done

    # set up options
    set timeout -1; # basically an infinite timeout
    while {$cond in {-timeout}} {
        set args [lassign $args [string range $cond 1 end] cond]
    }

    set start_cycle [get_clk_count $ref_clk]

    puts ">>> wait_for: start_cycle=$start_cycle, timeout=$timeout, args=$args"
    switch -glob -- $cond {
        -cyc* {
            #run $args -clock $ref_clk
            run $args
        }
        -trig* {
            lassign $args trig expr
            set_trig $trig $expr
        }
        -while {

        }
        -change {
            set val [uplevel $args]
        }
    }

    switch -glob -- $cond -cyc* - -trig* {
# TODO: transalate from zRun to zRci
#         while { [ZEBU_Clock_getStatus $clk]=="running" } {
#             after 100
#             if {($timeout > 0) && (([get_clk_count] - $start_cycle) > $timeout)} {
#                 puts ">>>Warning: timeout reached"
#                 return -code break timeout
#             }
#             update; # let event handlers (e.g. GUI, IO) chance to work!
#         }
    } -while {
        #while {[uplevel $args] && ([incr timeout -1])} {run 1 -clock $ref_clk}
        while {[uplevel $args] && ([incr timeout -1])} {run 1}
    } -change {
        while {([set next_val [uplevel $args]] == $val) && ([incr timeout -1])} {
           #run 1 -clock $ref_clk
           run 1
        }
    }

    switch -glob -- $cond -trig* {
      lassign $args trig expr
      vwait trig_done ;# wait for trigger reached
      stop_all_clk    ;# stop closk and dsable trigger
      stop -disable $trig
    }

    set end_cycle [get_clk_count $ref_clk]
    if !$timeout {
        puts ">>> Warning: timeout reached ($timeout)"
        return -code break timeout
    }
    switch -glob -- $cond {
        -cyc* {if {$end_cycle - $start_cycle != $args} {
            puts ">>> Warning: stopped before reaching target cycle"
            return -code break target_cycle_not_reached
        }}
    }

    return $end_cycle
}

proc word_addr {byte_addr} {
    variable word_size

    set word_addr [expr $byte_addr / ($word_size / 8)]
    if {int($word_addr) != $word_addr} {
        error "cannot convert byte-address $byte_addr to ${word_size}-bit word address -- it must be aligned!"
    }
    return $word_addr
}

proc load_mem {mem args} {
    variable runtime_path
    variable word_size
    variable base_addr

    if {$mem == ""} {
      puts ">>> Error: Backdoor load not supported for memory: '$mem'"
      exit 1
    }

    foreach {type content} $args {
        lassign $content file start_addr end_addr offset
        if ![llength $start_addr] {set start_addr 0}

        set bytes_hex [exec mktemp /tmp/elf2hex.XXXX.hex]
        set words_hex [string map {.hex .cde} $bytes_hex]
        switch -- $type {
            -elf {
                exec elf2hex -n$word_size -V -Q $file -o $bytes_hex
                exec $runtime_path/change_hex_word_width.py $word_size $word_size $base_addr $bytes_hex > $words_hex
                memory -load $mem -file $words_hex -radix hexa
            }
            -hex {
                memory -load $mem -file $file -radix hexa -start [word_addr $start_addr]
            }
            -bin {
                exec xxd -ps -c 1 $file > $bytes_hex
                exec $runtime_path/change_hex_word_width.py 8 $word_size $base_addr $bytes_hex > $words_hex
                memory -load $mem -file $words_hex -radix hexa -start [word_addr $start_addr]
            }
            default {
                error "Unknown content type \"$type\", cannot load \"$content\" to memory $mem"
            }
        }
        file delete $bytes_hex $words_hex
    }
}

proc store_mem {mem args} {
    variable runtime_path
    variable word_size

    if {$mem == ""} {
      puts ">>> Error: Backdoor store not supported for memory: '$mem'"
      exit 1
    }

    foreach {type content} $args {
        lassign $content file start_addr size
        switch -- $type {
            -hex {
                memory -store $mem -file ../$file -radix hexa -start [word_addr $start_addr] -end [word_addr [expr $start_addr+$size-1]]
                exec $runtime_path/zebu_dump_to_hex.py $word_size 8 $size $file > $file.hex
            }
            default {
                error "Unknown content type \"$type\", cannot store \"$content\" from memory $mem"
            }
        }
    }
}

# Helper functions for MDB
variable mdb_pid 0
variable mdb_ch
variable mdb_done 0

# Monitor a job "pid" every "period_ms" and execute "action" when killed.
# If elapsed monitoring time bigger than "timeout_ms", kill job and print error
proc pid_watchdog {pid {action {}} {timeout_ms inf} {period_ms 500}} {
    global pid_watchdog_id
    global pid_watchdog_time

    # Cancel previous call if exists
    stop_pid_watchdog $pid
    # If an action is defined
    if [llength $action] {
        # Increase timer for this job
        incr pid_watchdog_time($pid) $period_ms
        # Check if job still running
        if {![file exist /proc/$pid]} {
            # If not, execute action (in caller scope)
            uplevel $action
        } else {
            # Otherwise check if timeout excedeed then kill job and perform action
            if {$pid_watchdog_time($pid) > $timeout_ms} {
                puts ">>> Error: the timeout of ${timeout_ms}ms was reached for process $pid, killing it"
                exec kill -9 $pid
                uplevel $action
            }
        }
        # Wait "period_ms" and call itself again
        set pid_watchdog_id($pid) [after $period_ms [list pid_watchdog $pid $action $timeout_ms $period_ms]]
    }
}

proc stop_pid_watchdog {pid} {
    global pid_watchdog_id
    if {[info exist   pid_watchdog_id($pid)]} {
        after cancel $pid_watchdog_id($pid)
        unset         pid_watchdog_id($pid)
    }
}

# Start "mdb_cmd" in the background and set stdout
# If "timeout_ms" set, kill mdb after timer expires
proc start_mdb {mdb_cmd {timeout_ms inf}} {
    variable mdb_pid
    variable mdb_ch
    variable mdb_done
    # Open a RW pipe for mdb
    if {[catch {set mdb_pid [pid [set mdb_ch [open |$mdb_cmd RDWR]]]} ]} {
        error ">>> Error: failed to launch mdb"
    } else {
        puts ">>> Info: mdb launched successfully, PID is $mdb_pid"
        set mdb_done 0

        # Set a watchdog in the process to detect unexpected termination and an optional timeout
        pid_watchdog $mdb_pid {
            puts ">>> Error: mdb process $mdb_pid unexpectedly terminated! Terminating zRun."
            catch {close $mdb_ch}
            #exit 1
            set mdb_done 1
        } $timeout_ms

        # Define event to perform when new line is avaialble in the stdout pipe
        fileevent  $mdb_ch readable [subst -nocommands {
            if {[eof $mdb_ch]} {
                # Flag end of the process
                set mdb_done 1
            } else {
                if {[gets $mdb_ch line] > -1} {
                    puts "mdb: [set line]"
                }
            }
        }]
    }
}

# Excute optional "args" instruction and block until mdb finishes
# Return mdb exit code
proc wait_mdb {args} {
    set mdb_code 0
    variable mdb_ch
    variable mdb_pid
    variable mdb_done
    uplevel $args
    vwait mdb_done
    stop_pid_watchdog $mdb_pid
    puts ">>> Info: mdb terminated"
    if { [catch {close $mdb_ch} result options] } {
        puts ">>> Error: $result"
        set mdb_code [lindex [dict get $options -errorcode] 2]
    }
    set mdb_ch {}
    return $mdb_code
}

# Execute MDB command (simpler way)
# try {
#     set results [exec >@stdout {*}$mdb_cmd]
#     set status 0
# } trap CHILDSTATUS {results options} {
#     puts "Error catched: $results"
#     set status [lindex [dict get $options -errorcode] 2]
# }
# exit $status
