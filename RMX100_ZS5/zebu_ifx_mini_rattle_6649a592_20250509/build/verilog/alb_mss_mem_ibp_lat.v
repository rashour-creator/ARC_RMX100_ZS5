// Library ARCv2MSS-2.1.999999999
module alb_mss_mem_ibp_lat
    #(
      parameter a_w = 32,
      parameter d_w = 32,
      parameter u_w = 1,
      parameter depl2 = 5
    )
    (
     input  wire                clk,
     input  wire                clk_en,
     input  wire                rst_b,

     input  wire                i_ibp_cmd_valid,
     output wire                i_ibp_cmd_accept,
     input  wire                i_ibp_cmd_read,
     input  wire  [a_w-1:0]     i_ibp_cmd_addr,
     input  wire                i_ibp_cmd_wrap,
     input  wire  [2:0]         i_ibp_cmd_data_size,
     input  wire  [3:0]         i_ibp_cmd_burst_size,
     input  wire  [1:0]         i_ibp_cmd_prot,
     input  wire  [3:0]         i_ibp_cmd_cache,
     input  wire                i_ibp_cmd_lock,
     input  wire                i_ibp_cmd_excl,
     input  wire  [u_w-1:0]     i_ibp_cmd_user,

     output wire                i_ibp_rd_valid,
     input  wire                i_ibp_rd_accept,
     output wire  [d_w-1:0]     i_ibp_rd_data,
     output wire                i_ibp_err_rd,
     output wire                i_ibp_rd_last,
     output wire                i_ibp_rd_excl_ok,

     input  wire                i_ibp_wr_valid,
     output wire                i_ibp_wr_accept,
     input  wire  [d_w-1:0]     i_ibp_wr_data,
     input  wire  [(d_w/8)-1:0] i_ibp_wr_mask,
     input  wire                i_ibp_wr_last,

     output wire                i_ibp_wr_done,
     input  wire                i_ibp_wr_resp_accept,
     output wire                i_ibp_wr_excl_done,
     output wire                i_ibp_err_wr,

     output  wire                o_ibp_cmd_valid,
     input   wire                o_ibp_cmd_accept,
     output  wire                o_ibp_cmd_read,
     output  wire  [a_w-1:0]     o_ibp_cmd_addr,
     output  wire                o_ibp_cmd_wrap,
     output  wire  [2:0]         o_ibp_cmd_data_size,
     output  wire  [3:0]         o_ibp_cmd_burst_size,
     output  wire  [1:0]         o_ibp_cmd_prot,
     output  wire  [3:0]         o_ibp_cmd_cache,
     output  wire                o_ibp_cmd_lock,
     output  wire                o_ibp_cmd_excl,
     output  wire  [u_w-1:0]     o_ibp_cmd_user,

     input   wire                o_ibp_rd_valid,
     output  wire                o_ibp_rd_accept,
     input   wire  [d_w-1:0]     o_ibp_rd_data,
     input   wire                o_ibp_err_rd,
     input   wire                o_ibp_rd_last,
     input   wire                o_ibp_rd_excl_ok,

     output  wire                o_ibp_wr_valid,
     input   wire                o_ibp_wr_accept,
     output  wire  [d_w-1:0]     o_ibp_wr_data,
     output  wire  [(d_w/8)-1:0] o_ibp_wr_mask,
     output  wire                o_ibp_wr_last,

     input   wire                o_ibp_wr_done,
     output  wire                o_ibp_wr_resp_accept,
     input   wire                o_ibp_wr_excl_done,
     input   wire                o_ibp_err_wr,

     input  wire  [9:0]          cfg_lat_w,
     input  wire  [9:0]          cfg_lat_r,
     output wire                 perf_awf,
     output wire                 perf_arf,
     output wire                 perf_aw,
     output wire                 perf_ar,
     output wire                 perf_w,
     output wire                 perf_wl,
     output wire                 perf_r,
     output wire                 perf_rl,
     output wire                 perf_b
);


wire  [7:0]         i_bus_alen;
wire  [1:0]         i_bus_rresp;
wire  [1:0]         i_bus_bresp;
wire  [7:0]         o_bus_alen;
wire  [1:0]         o_bus_rresp;
wire  [1:0]         o_bus_bresp;

wire i_bus_bvalid;
wire i_bus_rvalid;
wire i_buss_rvalid;
wire i_buss_bvalid;

// command attributes directly forwarded
assign o_ibp_cmd_prot = i_ibp_cmd_prot;
assign o_ibp_cmd_cache = i_ibp_cmd_cache;
assign o_ibp_cmd_user = i_ibp_cmd_user;

assign o_bus_bresp = o_ibp_err_wr ? 2'b10 // SLVERR
                     : o_ibp_wr_excl_done ? 2'b01 // EXOKAY
                     : 2'b00; // OKAY

assign o_bus_rresp = o_ibp_err_rd ? 2'b10 // SLVERR
                     : o_ibp_rd_excl_ok ? 2'b01 //EXOKAY
                     : 2'b00; // OKAY

assign i_bus_alen = {{4{1'b0}},i_ibp_cmd_burst_size};

assign o_ibp_cmd_burst_size = o_bus_alen[3:0];

assign i_ibp_wr_done = i_bus_bvalid & (~(|i_bus_bresp));
assign i_ibp_wr_excl_done = i_bus_bvalid & i_bus_bresp[0];
assign i_ibp_err_wr = i_bus_bvalid & i_bus_bresp[1];

assign i_ibp_rd_valid = i_bus_rvalid & (~i_bus_rresp[1]);
assign i_ibp_rd_excl_ok = i_bus_rvalid & i_bus_rresp[0];
assign i_ibp_err_rd =  i_bus_rvalid & i_bus_rresp[1];

assign i_buss_rvalid = o_ibp_rd_valid | o_ibp_err_rd;
assign i_buss_bvalid = o_ibp_wr_done | o_ibp_wr_excl_done | o_ibp_err_wr;

alb_mss_mem_lat #(a_w, d_w, depl2) u_mem_bus_lat
(
    .clk(clk),
    .clk_en(clk_en),
    .rst_b(rst_b),
    .busp_avalid(i_ibp_cmd_valid),
    .busp_aready(i_ibp_cmd_accept),
    .busp_aread(i_ibp_cmd_read),
    .busp_aaddr(i_ibp_cmd_addr),
    .busp_alock({i_ibp_cmd_lock,i_ibp_cmd_excl}),
    .busp_aburst(i_ibp_cmd_wrap),
    .busp_alen(i_bus_alen),
    .busp_asize(i_ibp_cmd_data_size),
    .busp_rvalid(i_bus_rvalid),
    .busp_rready(i_ibp_rd_accept),
    .busp_rdata(i_ibp_rd_data),
    .busp_rresp(i_bus_rresp),
    .busp_rlast(i_ibp_rd_last),
    .busp_wvalid(i_ibp_wr_valid),
    .busp_wready(i_ibp_wr_accept),
    .busp_wdata(i_ibp_wr_data),
    .busp_wstrb(i_ibp_wr_mask),
    .busp_wlast(i_ibp_wr_last),
    .busp_bvalid(i_bus_bvalid),
    .busp_bready(i_ibp_wr_resp_accept),
    .busp_bresp(i_bus_bresp),

    .buss_avalid(o_ibp_cmd_valid),
    .buss_aready(o_ibp_cmd_accept),
    .buss_aread(o_ibp_cmd_read),
    .buss_aaddr(o_ibp_cmd_addr),
    .buss_alock({o_ibp_cmd_lock,o_ibp_cmd_excl}),
    .buss_aburst(o_ibp_cmd_wrap),
    .buss_alen(o_bus_alen),
    .buss_asize(o_ibp_cmd_data_size),
    .buss_rvalid(i_buss_rvalid),
    .buss_rready(o_ibp_rd_accept),
    .buss_rdata(o_ibp_rd_data),
    .buss_rresp(o_bus_rresp),
    .buss_rlast(o_ibp_rd_last),
    .buss_wvalid(o_ibp_wr_valid),
    .buss_wready(o_ibp_wr_accept),
    .buss_wdata(o_ibp_wr_data),
    .buss_wstrb(o_ibp_wr_mask),
    .buss_wlast(o_ibp_wr_last),
    .buss_bvalid(i_buss_bvalid),
    .buss_bready(o_ibp_wr_resp_accept),
    .buss_bresp(o_bus_bresp),

    .cfg_lat_w(cfg_lat_w),
    .cfg_lat_r(cfg_lat_r),
    .perf_awf(perf_awf),
    .perf_arf(perf_arf),
    .perf_aw(perf_aw),
    .perf_ar(perf_ar),
    .perf_w(perf_w),
    .perf_wl(perf_wl),
    .perf_r(perf_r),
    .perf_rl(perf_rl),
    .perf_b(perf_b)
);

endmodule //alb_mss_mem_ibp_lat
