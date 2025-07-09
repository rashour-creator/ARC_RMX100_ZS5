// Library ARCv2MSS-2.1.999999999
module ahb_dummy_slave
                      #(
                          parameter        aw = 12,
                          parameter        dw = 32
                       )
                       (  input             hsel,
                          input  [1:0]      htrans,
                          input             hwrite,
                          input  [aw-1:0]   haddr,
                          input  [2:0]      hsize,
                          input  [2:0]      hburst,
                          input  [dw-1:0]   hwdata,
                          output [dw-1:0]   hrdata,
                          output            hresp,
                          output            hreadyout,
                          input             hready,
                          input             hclk,
                          input             hreset_n //async reset, low valid
                         );

// assign default values to the output signals
assign hrdata = 0;
assign hresp = 0;
assign hreadyout = 0;

 endmodule
