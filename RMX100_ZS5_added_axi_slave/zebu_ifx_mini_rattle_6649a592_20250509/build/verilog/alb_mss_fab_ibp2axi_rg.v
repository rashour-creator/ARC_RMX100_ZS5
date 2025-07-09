// Library ARCv2MSS-2.1.999999999
module alb_mss_fab_ibp2axi_rg #(
    parameter CHNL_FIFO_DEPTH = 2,
    parameter ID_W = 4,
    parameter RGON_W = 4,
    // ADDR_W indicate the width of address
        // It can be any value
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
        // It can be any value
    parameter DATA_W = 32,
    // OUT_CMD_CNT_W indicate the width of counter
        // how many read/write commands supported
    parameter OUT_CMD_NUM = 8,
    parameter OUT_CMD_CNT_W = 3
    )
  (
  // The "ibp_xxx" bus is the one IBP to be converted
  //
  // command channel
  // This module Do not support the id and snoop
  input  ibp_cmd_valid,
  output ibp_cmd_accept,
  input  ibp_cmd_read,
  input  [ADDR_W-1:0] ibp_cmd_addr,
  input  ibp_cmd_wrap,
  input  [2:0] ibp_cmd_data_size,
  input  [3:0] ibp_cmd_burst_size,
  input  ibp_cmd_lock,
  input  ibp_cmd_excl,
  input  [1:0] ibp_cmd_prot,
  input  [3:0] ibp_cmd_cache,
  input  [RGON_W-1:0] ibp_cmd_region,
  //
  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  output ibp_rd_valid,
  input  ibp_rd_accept,
  output [DATA_W-1:0] ibp_rd_data,
  output ibp_rd_last,
  output ibp_err_rd,
  output ibp_rd_excl_ok,
  //
  // write data channel
  input  ibp_wr_valid,
  output ibp_wr_accept,
  input  [DATA_W-1:0] ibp_wr_data,
  input  [(DATA_W/8)-1:0] ibp_wr_mask,
  input  ibp_wr_last,
  //
  // write response channel
  // This module do not support id
  output ibp_wr_done,
  output ibp_wr_excl_done,
  output ibp_err_wr,
  input  ibp_wr_resp_accept,

  input  [ID_W-1:0] ibp_cmd_chnl_id ,
  output [ID_W-1:0] ibp_rd_chnl_id  ,
  input  [ID_W-1:0] ibp_wd_chnl_id  ,
  output [ID_W-1:0] ibp_wrsp_chnl_id,

  // The "axi_xxx" bus is the one AXI after converted
  //
  output [ID_W-1:0]   axi_arid,
  output [ID_W-1:0]   axi_awid,
  output [ID_W-1:0]   axi_wid,
  input  [ID_W-1:0]   axi_rid,
  input  [ID_W-1:0]   axi_bid,
  // Read address channel
  output axi_arvalid,
  input  axi_arready,
  output [RGON_W-1:0] axi_arregion,
  output [ADDR_W-1:0] axi_araddr,
  output [3:0] axi_arcache,
  output [2:0] axi_arprot,
  output [1:0] axi_arlock,
  output [1:0] axi_arburst,
  output [3:0] axi_arlen,
  output [2:0] axi_arsize,

  // Write address channel
  output axi_awvalid,
  input  axi_awready,
  output [RGON_W-1:0] axi_awregion,
  output [ADDR_W-1:0] axi_awaddr,
  output [3:0] axi_awcache,
  output [2:0] axi_awprot,
  output [1:0] axi_awlock,
  output [1:0] axi_awburst,
  output [3:0] axi_awlen,
  output [2:0] axi_awsize,

  // Read data channel
  input  axi_rvalid,
  output axi_rready,
  input  [DATA_W-1:0] axi_rdata,
  input  [1:0] axi_rresp,
  input  axi_rlast,

  // Write data channel
  output axi_wvalid,
  input  axi_wready,
  output [DATA_W-1:0] axi_wdata,
  output [(DATA_W/8)-1:0] axi_wstrb,
  output axi_wlast,

  // Write response channel
  input  axi_bvalid,
  output axi_bready,
  input  [1:0] axi_bresp,

  input  clk,  // clock signal
  input  bus_clk_en,  // clock enable signal to control the 1:N clock ratios
  input  rst_a // reset signal
  );

alb_mss_fab_ibp2axi #(
     .CHNL_FIFO_DEPTH(CHNL_FIFO_DEPTH),
     .USER_W(1),
     .ID_W(ID_W),
     .ADDR_W(RGON_W+ADDR_W), //packed the region signal along with addr
     .DATA_W(DATA_W),
     .OUT_CMD_NUM(8),
     .OUT_CMD_CNT_W(3)
   ) u_fab_ibp2axi (
        .ibp_cmd_valid(ibp_cmd_valid),
        .ibp_cmd_accept(ibp_cmd_accept),
        .ibp_cmd_read(ibp_cmd_read),
        .ibp_cmd_addr({ibp_cmd_region,ibp_cmd_addr}),
        .ibp_cmd_wrap(ibp_cmd_wrap),
        .ibp_cmd_data_size(ibp_cmd_data_size),
        .ibp_cmd_burst_size(ibp_cmd_burst_size),
        .ibp_cmd_lock(ibp_cmd_lock),
        .ibp_cmd_excl(ibp_cmd_excl),
        .ibp_cmd_prot(ibp_cmd_prot),
        .ibp_cmd_cache(ibp_cmd_cache),
        .ibp_cmd_user(1'b0),

        .ibp_rd_valid(ibp_rd_valid),
        .ibp_rd_accept(ibp_rd_accept),
        .ibp_rd_data(ibp_rd_data),
        .ibp_rd_last(ibp_rd_last),
        .ibp_err_rd(ibp_err_rd),
        .ibp_rd_excl_ok(ibp_rd_excl_ok),

        .ibp_wr_valid(ibp_wr_valid),
        .ibp_wr_accept(ibp_wr_accept),
        .ibp_wr_data(ibp_wr_data),
        .ibp_wr_mask(ibp_wr_mask),
        .ibp_wr_last(ibp_wr_last),

        .ibp_wr_done(ibp_wr_done),
        .ibp_wr_excl_done(ibp_wr_excl_done),
        .ibp_err_wr(ibp_err_wr),
        .ibp_wr_resp_accept(ibp_wr_resp_accept),

        .ibp_cmd_chnl_id (ibp_cmd_chnl_id),
        .ibp_rd_chnl_id  (ibp_rd_chnl_id),
        .ibp_wd_chnl_id  (ibp_wd_chnl_id),
        .ibp_wrsp_chnl_id(ibp_wrsp_chnl_id),

        .axi_arid(axi_arid),
        .axi_awid(axi_awid),
        .axi_wid(axi_wid),
        .axi_rid(axi_rid),
        .axi_bid(axi_bid),

        .axi_arvalid(axi_arvalid),
        .axi_arready(axi_arready),
        .axi_araddr({axi_arregion,axi_araddr}),
        .axi_arcache(axi_arcache),
        .axi_arprot(axi_arprot),
        .axi_arlock(axi_arlock),
        .axi_arburst(axi_arburst),
        .axi_arlen(axi_arlen),
        .axi_arsize(axi_arsize),
        .axi_aruser(),

        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),
        .axi_awaddr({axi_awregion,axi_awaddr}),
        .axi_awcache(axi_awcache),
        .axi_awprot(axi_awprot),
        .axi_awlock(axi_awlock),
        .axi_awburst(axi_awburst),
        .axi_awlen(axi_awlen),
        .axi_awsize(axi_awsize),
        .axi_awuser(),

        .axi_rvalid(axi_rvalid),
        .axi_rready(axi_rready),
        .axi_rdata(axi_rdata),
        .axi_rresp(axi_rresp),
        .axi_rlast(axi_rlast),

        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wlast(axi_wlast),

        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready),
        .axi_bresp(axi_bresp),

        .clk(clk),
        .bus_clk_en(bus_clk_en),
        .rst_a (rst_a)
  );

endmodule //alb_mss_fab_ibp2axi_rg.vpp
