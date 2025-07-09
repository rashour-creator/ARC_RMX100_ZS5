wire [31:0] core0_ar_pc     = {zebu_top.core_chip_dut.icore_sys.iarchipelago.icpu_top_safety_controller.u_main_rl_cpu_top.u_rl_core.u_rl_exu.ar_pc_r, 1'b0};
wire        sys_halt        = zebu_top.core_chip_dut.sys_halt_r;
wire [31:0] core0_pc        = core0_ar_pc | {32{sys_halt}};
zceiTrigger #(.TRIGGER_INPUT_WIDTH(32)) trigger_pc(.trigger_input(core0_pc));

