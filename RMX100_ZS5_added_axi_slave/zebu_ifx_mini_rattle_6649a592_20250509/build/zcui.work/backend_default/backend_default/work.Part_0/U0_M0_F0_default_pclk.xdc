#xdc_addconst settings
set LOW_TIME  [expr (($DRIVER_CLK_PERIOD_EDGES - $DRIVER_CLK_NEGEDGE) * $MASTER_CLK_PERIOD /2)] 
set HIGH_TIME [expr ($DRIVER_CLK_PERIOD - $LOW_TIME)] 
#xdc_addconst false_path
#Fetch Mode: false paths on all pclk paths except negedge flops to posedge latches (fall_from -> fall_to)
set_false_path -setup -rise_from [get_clocks CLK_pclk*] -rise_to [get_clocks CLK_pclk*] 
set_false_path -setup -rise_from [get_clocks CLK_pclk*] -fall_to [get_clocks CLK_pclk*] 
set_false_path -setup -fall_from [get_clocks CLK_pclk*] -rise_to [get_clocks CLK_pclk*] 
