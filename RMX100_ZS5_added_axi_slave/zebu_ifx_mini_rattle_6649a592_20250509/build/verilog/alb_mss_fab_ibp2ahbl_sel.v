// Library ARCv2MSS-2.1.999999999
module alb_mss_fab_ibp2ahbl_sel #(
    parameter CHNL_FIFO_DEPTH = 2,
    // ADDR_W indicate the width of address
        // It can be any value
    parameter ADDR_W = 32,
    // DATA_W indicate the width of data
        // It can be 32, 64, 128
    parameter DATA_W = 64,
    // ALSB indicate least significant bit of the address
        // It should be log2(DATA_W/8), eg: 2 for 32b, 3 for 64b, 4 for 128b
    parameter ALSB = 3,

    parameter RGON_W = 4,
        // Number of select outputs, support 32 outputs at the moment
    parameter L_W = 1

)
(
  input  wire                  ibp_cmd_valid,
  output wire                  ibp_cmd_accept,
  input  wire                  ibp_cmd_read,
  input  wire [ADDR_W-1:0]     ibp_cmd_addr,
  input  wire                  ibp_cmd_wrap,
  input  wire [2:0]            ibp_cmd_data_size,
  input  wire [3:0]            ibp_cmd_burst_size,
  input  wire                  ibp_cmd_lock,
  input  wire                  ibp_cmd_excl,
  input  wire [1:0]            ibp_cmd_prot,
  input  wire [3:0]            ibp_cmd_cache,
  input  wire [RGON_W-1:0]     ibp_cmd_region,
  //
  // read data channel
  // This module do not support id, snoop rd_resp, rd_ack and rd_abort
  output wire                  ibp_rd_valid,
  output wire                  ibp_rd_excl_ok,
  input  wire                  ibp_rd_accept,
  output wire [DATA_W-1:0]     ibp_rd_data,
  output wire                  ibp_rd_last,
  output wire                  ibp_err_rd,
  //
  // write data channel
  input  wire                  ibp_wr_valid,
  output wire                  ibp_wr_accept,
  input  wire [DATA_W-1:0]     ibp_wr_data,
  input  wire [(DATA_W/8)-1:0] ibp_wr_mask,
  input  wire                  ibp_wr_last,
  //
  // write response channel
  // This module do not support id
  output wire                  ibp_wr_done,
  output wire                  ibp_wr_excl_done,
  output wire                  ibp_err_wr,
  input  wire                  ibp_wr_resp_accept,

  // The "ahb_xxx" bus is the AHB-Lite interface after converted
  output reg  [L_W-1:0]        ahb_hsel,
  output wire [1:0]            ahb_htrans,    // AHB transaction type (IDLE, BUSY, SEQ, NSEQ)
  output wire                  ahb_hwrite,    // If true then write
  output wire [ADDR_W-1:0]     ahb_haddr,     // Address
  output wire [2:0]            ahb_hsize,     // Transaction size
  output wire [2:0]            ahb_hburst,    // Burst type SINGLE, INCR, etc
  output wire [DATA_W-1:0]     ahb_hwdata,    // Write data
  input  wire [DATA_W-1:0]     ahb_hrdata,    // Read data
  input  wire                  ahb_hresp,     // Response 0=OK, 1=ERROR
  input  wire                  ahb_hready_resp,
  output wire                  ahb_hready,    // AHB transfer ready

  // Clock and reset
  input                   clk,           // clock signal
  input                   bus_clk_en,    // clock enable signal to control the N:1 clock ratios
  input                   rst_a,         // reset signal
  input                   bigendian      // If true, then bigendian
);


wire [RGON_W-1:0] ahb_region;
    // AHB select
    // outputs: ahb_sel
    always @*
      begin : sel_PROC
          integer i;
          ahb_hsel = {L_W{1'b0}};
            for (i = 0; i < L_W; i = i + 1)
              ahb_hsel[i] = (ahb_region == i);
      end // sel_PROC


alb_mss_fab_ibp2ahbl #(
   .CHNL_FIFO_DEPTH(CHNL_FIFO_DEPTH),
   .ADDR_W(RGON_W+ADDR_W),
   .DATA_W(DATA_W),
   .ALSB(ALSB)) u_ibp2ahb_without_sel (
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
  .ibp_rd_valid(ibp_rd_valid),
  .ibp_rd_excl_ok(ibp_rd_excl_ok),
  .ibp_rd_accept(ibp_rd_accept),
  .ibp_rd_data(ibp_rd_data),
  .ibp_rd_last(ibp_rd_last),
  .ibp_err_rd(ibp_err_rd),
  .ibp_wr_valid(ibp_wr_valid),
  .ibp_wr_accept(ibp_wr_accept),
  .ibp_wr_data(ibp_wr_data),
  .ibp_wr_mask(ibp_wr_mask),
  .ibp_wr_last(ibp_wr_last),
  .ibp_wr_done(ibp_wr_done),
  .ibp_wr_excl_done(ibp_wr_excl_done),
  .ibp_err_wr(ibp_err_wr),
  .ibp_wr_resp_accept(ibp_wr_resp_accept),

  .ahb_htrans(ahb_htrans),
  .ahb_hwrite(ahb_hwrite),
  .ahb_hlock(),
  .ahb_haddr({ahb_region,ahb_haddr}),
  .ahb_hsize(ahb_hsize),
  .ahb_hburst(ahb_hburst),
  .ahb_hprot(),
  .ahb_hexcl(),
  .ahb_hwdata(ahb_hwdata),
  .ahb_hrdata(ahb_hrdata),
  .ahb_hresp(ahb_hresp),
  .ahb_hrexok(1'b0),
  .ahb_hready(ahb_hready_resp),

  .clk(clk),
  .bus_clk_en(bus_clk_en),
  .rst_a(rst_a),
  .bigendian(bigendian)
);

assign ahb_hready = ahb_hready_resp;

endmodule
