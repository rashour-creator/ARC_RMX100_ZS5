// Library ARCv2MSS-2.1.999999999
module mss_bus_switch_default_slv
 #(
    parameter AW = 32,
    parameter DW = 64,
    parameter RET_ERR = 1
 )
 (
  input                                   bus_switch_def_slv_ibp_cmd_valid,
  output                                  bus_switch_def_slv_ibp_cmd_accept,
  input                                   bus_switch_def_slv_ibp_cmd_read,
  input   [AW                -1:0]       bus_switch_def_slv_ibp_cmd_addr,
  input                                   bus_switch_def_slv_ibp_cmd_wrap,
  input   [3-1:0]       bus_switch_def_slv_ibp_cmd_data_size,
  input   [4-1:0]       bus_switch_def_slv_ibp_cmd_burst_size,
  input   [2-1:0]       bus_switch_def_slv_ibp_cmd_prot,
  input   [4-1:0]       bus_switch_def_slv_ibp_cmd_cache,
  input                                   bus_switch_def_slv_ibp_cmd_lock,
  input                                   bus_switch_def_slv_ibp_cmd_excl,

  output                                  bus_switch_def_slv_ibp_rd_valid,
  output                                  bus_switch_def_slv_ibp_rd_excl_ok,
  input                                   bus_switch_def_slv_ibp_rd_accept,
  output                                  bus_switch_def_slv_ibp_err_rd,
  output  [DW               -1:0]        bus_switch_def_slv_ibp_rd_data,
  output                                  bus_switch_def_slv_ibp_rd_last,

  input                                   bus_switch_def_slv_ibp_wr_valid,
  output                                  bus_switch_def_slv_ibp_wr_accept,
  input   [DW               -1:0]        bus_switch_def_slv_ibp_wr_data,
  input   [(DW         /8)  -1:0]        bus_switch_def_slv_ibp_wr_mask,
  input                                   bus_switch_def_slv_ibp_wr_last,

  output                                  bus_switch_def_slv_ibp_wr_done,
  output                                  bus_switch_def_slv_ibp_wr_excl_done,
  output                                  bus_switch_def_slv_ibp_err_wr,
  input                                   bus_switch_def_slv_ibp_wr_resp_accept,


    input clk,
    input rst_a

 );




wire cmd_ready_nxt;
wire cmd_stg_valid_nxt, cmd_stg_valid_set, cmd_stg_valid_clr, cmd_stg_valid_ena;
reg cmd_ready_r, cmd_stg_valid_r;
reg [3:0] cmd_burst_size_r;
reg cmd_read_r;

assign cmd_ready_nxt = (bus_switch_def_slv_ibp_cmd_valid & (~cmd_ready_r) & (~cmd_stg_valid_r));

always @(posedge clk or posedge rst_a)
begin : cmd_ready_PROC
    if( rst_a == 1'b1)
        cmd_ready_r <= 1'b0;
    else
        cmd_ready_r <= cmd_ready_nxt;
end


assign bus_switch_def_slv_ibp_cmd_accept = cmd_ready_r;

assign cmd_stg_valid_set = bus_switch_def_slv_ibp_cmd_accept & bus_switch_def_slv_ibp_cmd_valid;
assign cmd_stg_valid_clr = ((bus_switch_def_slv_ibp_wr_done | bus_switch_def_slv_ibp_wr_excl_done | bus_switch_def_slv_ibp_err_wr) & bus_switch_def_slv_ibp_wr_resp_accept)
                           | bus_switch_def_slv_ibp_rd_last;
assign cmd_stg_valid_ena = cmd_stg_valid_set | cmd_stg_valid_clr;
assign cmd_stg_valid_nxt = cmd_stg_valid_set & (~cmd_stg_valid_clr);

always @(posedge clk or posedge rst_a)
begin : cmd_stg_valid_PROC
    if( rst_a == 1'b1)
        cmd_stg_valid_r <= 1'b0;
    else
        if(cmd_stg_valid_ena == 1'b1)
            cmd_stg_valid_r <= cmd_stg_valid_nxt;
end

always @(posedge clk or posedge rst_a)
begin : cmd_burst_size_PROC
    if( rst_a == 1'b1)
    begin
        cmd_burst_size_r <= 4'b0;
        cmd_read_r <= 1'b0;
    end
    else
    begin
        if(cmd_stg_valid_set == 1'b1)
        begin
            cmd_burst_size_r <= bus_switch_def_slv_ibp_cmd_burst_size;
            cmd_read_r <= bus_switch_def_slv_ibp_cmd_read;
        end
    end
end

reg wr_resp_valid_r;

assign bus_switch_def_slv_ibp_wr_accept = bus_switch_def_slv_ibp_wr_valid & cmd_stg_valid_r & (~wr_resp_valid_r);


wire wr_resp_valid_set, wr_resp_valid_clr, wr_resp_valid_nxt, wr_resp_valid_ena;

assign wr_resp_valid_set = bus_switch_def_slv_ibp_wr_valid & bus_switch_def_slv_ibp_wr_accept & bus_switch_def_slv_ibp_wr_last;
assign wr_resp_valid_clr = bus_switch_def_slv_ibp_wr_resp_accept & wr_resp_valid_r;
assign wr_resp_valid_ena = wr_resp_valid_set | wr_resp_valid_clr;
assign wr_resp_valid_nxt = (~wr_resp_valid_clr) & wr_resp_valid_set;

always @(posedge clk or posedge rst_a)
begin : wresp_valid_PROC
    if(rst_a == 1'b1)
        wr_resp_valid_r <= 1'b0;
    else
        if(wr_resp_valid_ena == 1'b1)
            wr_resp_valid_r <= wr_resp_valid_nxt;
end

    assign bus_switch_def_slv_ibp_err_wr =  wr_resp_valid_r;
    assign bus_switch_def_slv_ibp_wr_done = 0;
    assign bus_switch_def_slv_ibp_wr_excl_done = 0;

reg [5:0] cnt_r;
wire cnt_incr, cnt_clr;
wire [5:0] cnt_nxt;

reg rd_valid_r;

assign cnt_incr =  (rd_valid_r & bus_switch_def_slv_ibp_rd_accept);

assign cnt_clr = bus_switch_def_slv_ibp_rd_last;
assign cnt_nxt = cnt_clr ? 0 :
                 cnt_incr ? (cnt_r + 1) : cnt_r;

always @(posedge  clk or posedge rst_a)
begin : cnt_PROC
    if(rst_a == 1'b1)
        cnt_r <= 5'b0;
    else
        cnt_r <= cnt_nxt;
end


wire rd_valid_nxt, rd_valid_set, rd_valid_clr, rd_valid_en;

assign rd_valid_set = cmd_stg_valid_set & bus_switch_def_slv_ibp_cmd_read;
assign rd_valid_clr = bus_switch_def_slv_ibp_rd_last;
assign rd_valid_nxt = rd_valid_set & (~rd_valid_clr);
assign rd_valid_en = rd_valid_set | rd_valid_clr;

always @(posedge clk or posedge rst_a)
begin
    if(rst_a == 1'b1)
        rd_valid_r <= 1'b0;
    else
        if(rd_valid_en == 1'b1)
            rd_valid_r <= rd_valid_nxt;
end

generate if (RET_ERR == 1)
  begin: def_slv_ret_err_PROC
assign bus_switch_def_slv_ibp_err_rd = rd_valid_r;
assign bus_switch_def_slv_ibp_rd_valid = 0;
  end
else
  begin: def_slv_ret_ok_PROC
assign bus_switch_def_slv_ibp_err_rd = 0;
assign bus_switch_def_slv_ibp_rd_valid = rd_valid_r;
  end
endgenerate
assign bus_switch_def_slv_ibp_rd_excl_ok = 1'b0;
assign bus_switch_def_slv_ibp_rd_data = {DW{1'b0}};



assign bus_switch_def_slv_ibp_rd_last = (cnt_r == cmd_burst_size_r) & rd_valid_r & bus_switch_def_slv_ibp_rd_accept;

 endmodule
