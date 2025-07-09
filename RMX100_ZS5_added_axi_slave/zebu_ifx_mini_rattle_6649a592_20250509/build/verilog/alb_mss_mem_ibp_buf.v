// Library ARCv2MSS-2.1.999999999
module alb_mss_mem_ibp_buf
      #(
        parameter id_w = 5,
        parameter rg_w = 1,
        parameter u_w = 1,
        parameter a_w = 32,
        parameter d_w = 32
       )
       (
     input  wire                clk,
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
     input  wire  [id_w-1:0]    i_ibp_cmd_id,
     input  wire  [u_w-1:0]     i_ibp_cmd_user,
     input  wire  [rg_w-1:0]    i_ibp_cmd_region,

     input  wire                i_ibp_wr_valid,
     output wire                i_ibp_wr_accept,
     input  wire  [d_w-1:0]     i_ibp_wr_data,
     input  wire  [(d_w/8)-1:0] i_ibp_wr_mask,
     input  wire                i_ibp_wr_last,

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
     output  wire  [id_w-1:0]    o_ibp_cmd_id,
     output  wire  [u_w-1:0]     o_ibp_cmd_user,
     output  wire  [rg_w-1:0]    o_ibp_cmd_region,

     output  wire                o_ibp_wr_valid,
     input   wire                o_ibp_wr_accept,
     output  wire  [d_w-1:0]     o_ibp_wr_data,
     output  wire  [(d_w/8)-1:0] o_ibp_wr_mask,
     output  wire                o_ibp_wr_last
     );


wire [a_w+id_w+u_w+rg_w+17-1:0] i_ibp_cmd_chnl;
wire [a_w+id_w+u_w+rg_w+17-1:0] o_ibp_cmd_chnl;
wire [d_w+d_w/8+1-1:0] i_ibp_wr_chnl;
wire [d_w+d_w/8+1-1:0] o_ibp_wr_chnl;
wire i_ibp_wr_valid_pre;
wire i_ibp_wr_accept_pre;

assign i_ibp_cmd_chnl = {i_ibp_cmd_read,
                         i_ibp_cmd_addr,
                         i_ibp_cmd_wrap,
                         i_ibp_cmd_data_size,
                         i_ibp_cmd_burst_size,
                         i_ibp_cmd_prot,
                         i_ibp_cmd_cache,
                         i_ibp_cmd_lock,
                         i_ibp_cmd_excl,
                         i_ibp_cmd_id,
                         i_ibp_cmd_user,
                         i_ibp_cmd_region};

assign {o_ibp_cmd_read,
        o_ibp_cmd_addr,
        o_ibp_cmd_wrap,
        o_ibp_cmd_data_size,
        o_ibp_cmd_burst_size,
        o_ibp_cmd_prot,
        o_ibp_cmd_cache,
        o_ibp_cmd_lock,
        o_ibp_cmd_excl,
        o_ibp_cmd_id,
        o_ibp_cmd_user,
        o_ibp_cmd_region} = o_ibp_cmd_chnl;


assign i_ibp_wr_chnl = {i_ibp_wr_data,
                        i_ibp_wr_mask,
                        i_ibp_wr_last};

assign {o_ibp_wr_data,
        o_ibp_wr_mask,
        o_ibp_wr_last} = o_ibp_wr_chnl;


// instantiation
alb_mss_mem_bypbuf #(
   .BUF_DEPTH(1),
   .BUF_WIDTH(a_w+id_w+u_w+rg_w+17)
) u_mss_mem_cmd_chnl_bypbuf (
    .i_ready (i_ibp_cmd_accept),
    .i_valid (i_ibp_cmd_valid),
    .i_data  (i_ibp_cmd_chnl),
    .o_ready (o_ibp_cmd_accept),
    .o_valid (o_ibp_cmd_valid),
    .o_data  (o_ibp_cmd_chnl),
    .clk     (clk),
    .rst_a   (~rst_b)
);

alb_mss_mem_bypbuf #(
   .BUF_DEPTH(1),
   .BUF_WIDTH(d_w+d_w/8+1)
) u_mss_mem_wr_chnl_bypbuf (
    .i_ready (i_ibp_wr_accept_pre),
    .i_valid (i_ibp_wr_valid_pre),
    .i_data  (i_ibp_wr_chnl),
    .o_ready (o_ibp_wr_accept),
    .o_valid (o_ibp_wr_valid),
    .o_data  (o_ibp_wr_chnl),
    .clk     (clk),
    .rst_a   (~rst_b)
);
// The IBP protocol require wr_accept cannot proceed the cmd_accept,
// so means wr_accept can only get asserted after some IBP write
// command have passed from command channel indicated by
// "ibp_cmd_wait_wd". If there is a incoming wr cmd accepted, the wr_accept
// can also asserted at the same cycle.
wire ibp_cmd_wait_wd;
wire cmd_wait_wd_cnt_udf;
wire cmd_wait_wd_cnt_inc;
wire cmd_wait_wd_cnt_dec;
wire cmd_wait_wd_cnt_ena;
wire [1:0] cmd_wait_wd_cnt_nxt;
reg [1:0] cmd_wait_wd_cnt_r;
//
assign ibp_cmd_wait_wd = i_ibp_cmd_accept | (~cmd_wait_wd_cnt_udf);
assign i_ibp_wr_accept    = i_ibp_wr_accept_pre & ibp_cmd_wait_wd;
assign i_ibp_wr_valid_pre = i_ibp_wr_valid  & ibp_cmd_wait_wd;


assign cmd_wait_wd_cnt_udf = (cmd_wait_wd_cnt_r == 2'b00);

assign cmd_wait_wd_cnt_inc = i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read);
assign cmd_wait_wd_cnt_dec = i_ibp_wr_valid  & i_ibp_wr_accept & i_ibp_wr_last;
assign cmd_wait_wd_cnt_ena = cmd_wait_wd_cnt_inc | cmd_wait_wd_cnt_dec;
assign cmd_wait_wd_cnt_nxt =
                            (cmd_wait_wd_cnt_inc & (~cmd_wait_wd_cnt_dec))? (cmd_wait_wd_cnt_r + 1'b1)
                          : ((~cmd_wait_wd_cnt_inc) & cmd_wait_wd_cnt_dec)? (cmd_wait_wd_cnt_r - 1'b1)
                          : cmd_wait_wd_cnt_r;

always @(posedge clk or negedge rst_b)
begin : cmd_wait_wd_cnt_DFFEAR_PROC
  if (rst_b == 1'b0) begin
      cmd_wait_wd_cnt_r        <= 2'b00;
  end
  else if (cmd_wait_wd_cnt_ena == 1'b1) begin
      cmd_wait_wd_cnt_r        <= cmd_wait_wd_cnt_nxt;
  end
end

endmodule //alb_mss_mem_ibp_buf.vpp

