
set f [open ./verilog/zebu_dumpvars.v w]

set archipelago [ search -limit 1 -scope zebu_top *.iarchipelago ]
set mem_cells   [ search          -scope zebu_top *.u_mem ]

puts $f "initial begin : FULL_DUT_DUMP"
puts $f "    (* qiwc, no_opt *) \$dumpvars(0, zebu_top);"
puts $f "end"

puts $f "initial begin : FULL_DUT_DUMP_PORTS"
puts $f "    (* fwc, no_opt *) \$dumpports([lindex $archipelago 0]);"
foreach mem $mem_cells {
  puts $f "    (* fwc, no_opt *) \$dumpports($mem);"
}
puts $f "end"

close $f
exit
