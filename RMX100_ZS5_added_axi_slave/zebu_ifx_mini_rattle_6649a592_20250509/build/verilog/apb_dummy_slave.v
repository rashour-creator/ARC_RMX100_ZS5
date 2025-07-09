// Library ARCv2MSS-2.1.999999999
module apb_dummy_slave ( input              psel,
                         input              penable,
                         input              pwrite,
                         input [11:2]       paddr,
                         input [31:0]       pwdata,
                         input [3:0]        pwstrb,
                         output [31:0]      prdata,
                         output             pslverr,
                         output             pready,
                         input              pclk,
                         input              preset_n
                        );

// assign default values to the output signals
assign prdata = 0;
assign pslverr = 0;
assign pready = 0;

 endmodule
