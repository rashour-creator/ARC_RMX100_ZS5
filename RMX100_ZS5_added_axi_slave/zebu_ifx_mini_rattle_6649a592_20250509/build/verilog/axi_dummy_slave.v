// Library ARCv2MSS-2.1.999999999
module axi_dummy_slave
                      #(
                         parameter         aw = 12,
                         parameter         dw = 32,
                         parameter         idw = 16
                       )
                       ( input             arvalid,
                         output            arready,
                         input  [aw-1:0]   araddr,
                         input  [1:0]      arburst,
                         input  [2:0]      arsize,
                         input  [idw-1:0]  arid,
                         input  [3:0]      arlen,
                         output            rvalid,
                         input             rready,
                         output [idw-1:0]  rid,
                         output [dw-1:0]   rdata,
                         output [1:0]      rresp,
                         output            rlast,
                         input             awvalid,
                         output            awready,
                         input  [aw-1:0]   awaddr,
                         input  [1:0]      awburst,
                         input  [2:0]      awsize,
                         input  [3:0]      awlen,
                         input  [idw-1:0]  awid,
                         input             wvalid,
                         output            wready,
                         input [dw-1:0]    wdata,
                         input [dw/8-1:0]  wstrb,
                         input             wlast,
                         output            bvalid,
                         input             bready,
                         output [idw-1:0]  bid,
                         output [1:0]      bresp,
                         input             aclk,
                         input             areset_n
                       );

parameter BLEN_WIDTH = 4;
parameter AXI_INTERLEAVE_DEPTH = 8; 
parameter XTOR_DEBUG_WIDTH_SLAVE = 32;

wire [idw-1:0] wid;
wire [2:0] awprot;
wire [1:0] awlock;
wire [3:0] awcache;
wire [2:0] arprot;
wire [1:0] arlock;
wire [3:0] arcache;
wire [XTOR_DEBUG_WIDTH_SLAVE-1:0] xtor_info_slave;

xtor_amba_slave_axi3_svs  #(  .DATA_WIDTH (dw),
                        .ADDR_WIDTH (aw), 
                        .ID_WIDTH   (idw), 
                        .WSTRB_WIDTH(dw/8),
                        .BLEN_WIDTH (BLEN_WIDTH),
                        .AXI_INTERLEAVE_DEPTH(AXI_INTERLEAVE_DEPTH),
                        .XTOR_DEBUG_WIDTH(XTOR_DEBUG_WIDTH_SLAVE)
						) 
                                   
                                   slave_xtor (

                                  .ACLK(aclk),
                                  .ARESETn(areset_n),
                                  .WDATA(wdata),  
                                  .WSTRB(wstrb), 
                                  .WLAST(wlast), 
                                  .WVALID(wvalid), 
                                  .WID(wid), 
                                  .WREADY(wready), 
                                  .AWADDR(awaddr), 
                                  .AWID(awid), 
                                  .AWLEN(awlen), 
                                  .AWSIZE(awsize), 
                                  .AWPROT(awprot), 
                                  .AWBURST(awburst), 
                                  .AWLOCK(awlock), 
                                  .AWCACHE(awcache), 
                                  .AWVALID(awvalid), 
                                  .AWREADY(awready), 
                                  .BID(bid), 
                                  .BRESP(bresp), 
                                  .BVALID(bvalid), 
                                  .BREADY(bready), 
                                  .ARADDR(araddr), 
                                  .ARID(arid), 
                                  .ARLEN(arlen), 
                                  .ARSIZE(arsize), 
                                  .ARPROT(arprot), 
                                  .ARBURST(arburst), 
                                  .ARLOCK(arlock), 
                                  .ARCACHE(arcache), 
                                  .ARVALID(arvalid), 
                                  .ARREADY(arready), 
                                  .RDATA(rdata), 
                                  .RID(rid), 
                                  .RRESP(rresp), 
                                  .RLAST(rlast), 
                                  .RVALID(rvalid), 
                                  .RREADY(rready),
                                  .xtor_info_port(xtor_info_slave)
                              );

 endmodule
