set f [open ./verilog/zebu_triggers.v w]


set aux_read  [search -limit 1 -scope zebu_top *u_alb_bc_regs.aux_bcr_ren_r ]
set aux_addr  [search -limit 1 -scope zebu_top *u_alb_bc_regs.aux_bcr_raddr_r ]
set db_active [search -limit 1 -scope zebu_top *u_alb_debug.db_active ]
if { [llength $db_active] == 0 } { set db_active [search -limit 1 -scope zebu_top u_alb_exec_ctrl.db_active ] }
if { [llength $db_active] == 0 } { set db_active [search -limit 1 -scope zebu_top db_active ] }
if { [llength $aux_read] && [llength $aux_addr] && [llength $db_active] } {
  puts $f "wire        aux_bcr_ren_r   = [lindex $aux_read 0];"
  puts $f "wire \[11:0\] aux_bcr_raddr_r = [lindex $aux_addr 0]\[11:0\];"
  puts $f "wire        db_active       = [lindex $db_active 0];"
  puts $f "wire        switch_toggle   = (aux_bcr_ren_r == 1'b1) && (aux_bcr_raddr_r == 12'h60) && (db_active == 1'b0);"
  puts $f "reg         switch_toggle_r = 0;"
  puts $f "always @ (posedge switch_toggle) switch_toggle_r <= ~switch_toggle_r;"
  puts $f "zceiTrigger #(.TRIGGER_INPUT_WIDTH(1)) trigger_power(.trigger_input(switch_toggle_r));"
  puts $f ""
}

set ar_pc_r    [search -limit 1 -scope zebu_top ar_pc_r]
set sys_halt_r [search -limit 1 -scope zebu_top sys_halt_r]
if { [llength $ar_pc_r] && [llength $sys_halt_r] } {
  puts $f "wire \[31:0\] core0_ar_pc     = \{[lindex $ar_pc_r 0], 1'b0\};"
  puts $f "wire        sys_halt        = [lindex $sys_halt_r 0];"
  puts $f "wire \[31:0\] core0_pc        = core0_ar_pc | \{32\{sys_halt\}\};"
  puts $f "zceiTrigger #(.TRIGGER_INPUT_WIDTH(32)) trigger_pc(.trigger_input(core0_pc));"
  puts $f ""
}

set aux_ecr  [search -limit 1 -scope zebu_top u_alb_aux_regs.ar_aux_ecr_r]
set aux_eret [search -limit 1 -scope zebu_top u_alb_aux_regs.ar_aux_eret_r]
set aux_efa  [search -limit 1 -scope zebu_top u_alb_aux_regs.ar_aux_efa_r]
if { [llength $aux_ecr] && [llength $aux_eret] && [llength $aux_efa] } {
  puts $f "wire \[31:0\] core0_ecr  = [lindex $aux_ecr 0];"
  puts $f "wire \[31:0\] core0_eret = [lindex $aux_eret 0];"
  puts $f "wire \[31:0\] core0_efa  = [lindex $aux_efa 0];"
  puts $f "zceiTrigger #(.TRIGGER_INPUT_WIDTH(96)) trigger_ecr(.trigger_input({core0_ecr, core0_eret, core0_efa}));"
  puts $f ""
}


close $f
exit
