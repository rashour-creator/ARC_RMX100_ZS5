// Library ARCv2MSS-2.1.999999999

module bvci_dummy_slave
                       #(
                        parameter aw = 12,
                        parameter dw = 32
                        )
                        ( input              cmdval,
                          output             cmdack,
                          input  [1:0]       cmd,
                          input  [aw-1:0]    address,
                          input              wrap,
                          input  [7:0]       plen,
                          input  [dw-1:0]    wdata,
                          input  [dw/8-1:0]  be,
                          input              eop,
                          output             rspval,
                          input              rspack,
                          output [dw-1:0]    rdata,
                          output             rerr,
                          output             reop,
                          input              clock,
                          input              resetn
                         );

// assign default values to the output signals
assign cmdack = 0;
assign rspval = 0;
assign rdata = 0;
assign rerr = 0;
assign reop = 0;

 endmodule
