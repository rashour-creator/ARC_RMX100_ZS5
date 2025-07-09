set_fpga_family v8 vu19p
automatic_selection -ramlut_to_bram {11}
automatic_selection -ramlut -max_blocs {34480}
automatic_selection -bram -max_blocs {540}
automatic_selection -uram -max_blocs {80}
set_max_sys_freq clk_100