// Library ARC_Soc_Trace-1.0.999999999
`include "dw_dbp_defines.v"
module dw_dbp_stubs (
	input            jtag_rtck ,



  output                  dbg_apb_dbgen,
  output                  dbg_apb_niden,

//  output                  dbg_apb_presetn,
//  output reg              dbg_apb_pclk,

  input clk
  );

parameter clock_period = 50.000;


assign dbg_apb_dbgen=1'b1;
assign dbg_apb_niden=1'b1;


//assign dmi_clk_en_req = 1'b0;
// APB stub code



endmodule
