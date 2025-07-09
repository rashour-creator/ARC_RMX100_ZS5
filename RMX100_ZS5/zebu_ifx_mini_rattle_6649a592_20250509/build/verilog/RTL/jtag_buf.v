// Library ARC_Soc_Trace-1.0.999999999
// Library ARC_Trace-3.0.999999999

module jtag_buf (
  input clk,
  input rst_a,
  input [31:0]               in_dbg_address,
  input [3:0]                in_dbg_be,
  input [1:0]                in_dbg_cmd,
  input                      in_dbg_cmdval,
  input                      in_dbg_eop,
  input                      in_dbg_rspack,
  input [31:0]               in_dbg_wdata,
  input [31:0]              in_dbg_rdata,
  input                     in_dbg_reop,
  input                     in_dbg_rspval,
  input                     in_dbg_rerr,

  output reg [31:0]               out_dbg_address,
  output     [3:0]                out_dbg_be,
  output reg [1:0]                out_dbg_cmd,
  output reg                      out_dbg_cmdval,
  output                      out_dbg_eop,
  output                      out_dbg_rspack,
  output reg [31:0]               out_dbg_wdata,
  output reg [31:0]          out_dbg_rdata,
  output reg                 out_dbg_reop,
  output reg                 out_dbg_rspval,
  output reg                 out_dbg_rerr
);


assign out_dbg_be = in_dbg_be;
assign out_dbg_eop = in_dbg_eop;

localparam DB_STATUS_ADDR = 32'h7fc0_0000;
localparam DB_DATA_ADDR =  32'h7fc0_000c;
localparam DB_CMD_ADDR  = 32'h7fc0_0004;
localparam DB_ADDR_ADDR  = 32'h7fc0_0008;
localparam DB_RESET_ADDR = 32'h7fc0_0010;
localparam DB_CSR1_ADDR = 32'h7fc0_0400;
localparam DB_CSR2_ADDR = 32'h7fc0_0404;
localparam DB_CSR3_ADDR = 32'h7fc0_0408;
localparam DB_CSR4_ADDR = 32'h7fc0_040c;
localparam DB_CSR5_ADDR = 32'h7fc0_0410;

localparam DB_STATUS = 12'h000;
localparam DB_DATA =  12'h00c;
localparam DB_CMD  = 12'h004;
localparam DB_ADDR  = 12'h008;
localparam DB_RESET = 12'h010;
localparam DB_CSR1 = 12'h400;
localparam DB_CSR2 = 12'h404;
localparam DB_CSR3 = 12'h408;
localparam DB_CSR4 = 12'h40c;
localparam DB_CSR5 = 12'h410;

reg [31:0]  db_addr;
reg [31:0]  db_data;
reg [31:0]  db_cmd;
reg [31:0]  db_stat;
reg [31:0]  db_rst;
reg [31:0]  db_csr1, db_csr2, db_csr3, db_csr4, db_csr5;

reg [31:0]               i_dbg_address;
reg [1:0]                i_dbg_cmd;
wire                      i_dbg_cmdval;
wire                      int_dbg_cmdval;
//reg                      i_dbg_rspack;
reg [31:0]               i_dbg_wdata;


reg stall;
reg [2:0] wait_count;
//wire [2:0] fifo_stack;

reg in_dbg_cmdval_r; 
reg int_cmdval, int_cmdval_r;
reg addr_wr_sel, data_wr_sel, cmd_wr_sel, stat_wr_sel, rst_wr_sel;
reg csr1_rd_sel, csr2_rd_sel, csr3_rd_sel, csr4_rd_sel, csr5_rd_sel;

//assign i_dbg_cmdval = int_cmdval & (~int_cmdval_r);

always@(posedge clk or posedge rst_a)
begin
  if(rst_a)
    int_cmdval_r <= 1'b0;
  else
    int_cmdval_r <= int_cmdval;
end
//always@(posedge clk or posedge rst_a)
//begin 
//  if (rst_a) 
//  begin
//    wait_count <= 1'b0;
//  end
//  else if (wait_count == 0 && stall == 1 && in_dbg_cmdval == 1)wait_count <= 1;
//  //else if (wait_count > 0 && in_dbg_cmdval ) wait_count <= wait_count + 1;
//  else 
//  begin
//    if (wait_count > 0 && in_dbg_cmdval ) wait_count <= wait_count + 1;
//    if (wait_count > 0 && ( stall == 0 )) wait_count <= wait_count - 1;
//  end
//end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a) 
  begin 
    addr_wr_sel <= 0;
    data_wr_sel <= 0;
    cmd_wr_sel  <= 0;
    stat_wr_sel <= 0;
    rst_wr_sel <= 0;
    csr1_rd_sel <= 0;
    csr2_rd_sel <= 0;
    csr3_rd_sel <= 0;
    csr4_rd_sel <= 0;
    csr5_rd_sel <= 0;
    wait_count  <= 0;
  end
  else 
  begin //{
    //if (wait_count == 0 && stall == 1 && in_dbg_cmdval == 1) wait_count <= 1;
    if((wait_count > 0) || (wait_count == 0 && stall == 1))
    begin //{
      if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_ADDR)   && in_dbg_cmd == `BVCI_CMD_WR)
      begin 
        addr_wr_sel <= 1;
        wait_count <= wait_count + 1;
      end
      if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_DATA)   && in_dbg_cmd == `BVCI_CMD_WR) 
      begin 
	data_wr_sel <= 1;
	wait_count <= wait_count + 1;
      end
      if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CMD)    && in_dbg_cmd == `BVCI_CMD_WR) 
      begin 
	cmd_wr_sel  <= 1;
	wait_count <= wait_count + 1;
      end
      if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_STATUS) && in_dbg_cmd == `BVCI_CMD_WR) 
      begin 
	stat_wr_sel <= 1;
	wait_count <= wait_count + 1;
      end 
      if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_RESET) && in_dbg_cmd == `BVCI_CMD_WR) 
      begin 
	rst_wr_sel <= 1;
	wait_count <= wait_count + 1;
      end
       if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR1) && in_dbg_cmd == `BVCI_CMD_RD) 
      begin 
	csr1_rd_sel <= 1;
	wait_count <= wait_count + 1;
      end
       if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR2) && in_dbg_cmd == `BVCI_CMD_RD) 
      begin 
	csr2_rd_sel <= 1;
	wait_count <= wait_count + 1;
      end
       if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR3) && in_dbg_cmd == `BVCI_CMD_RD) 
      begin 
	csr3_rd_sel <= 1;
	wait_count <= wait_count + 1;
      end
       if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR4) && in_dbg_cmd == `BVCI_CMD_RD) 
      begin 
	csr4_rd_sel <= 1;
	wait_count <= wait_count + 1;
      end
       if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR5) && in_dbg_cmd == `BVCI_CMD_RD) 
      begin 
	csr5_rd_sel <= 1;
	wait_count <= wait_count + 1;
      end
   
     if(stall == 0)
     begin //{
      if      (addr_wr_sel == 1) addr_wr_sel <= 0;
      else if (data_wr_sel == 1) data_wr_sel <= 0;
      else if (cmd_wr_sel  == 1) cmd_wr_sel  <= 0;
      else if (stat_wr_sel == 1) stat_wr_sel <= 0;
      else if (rst_wr_sel == 1)  rst_wr_sel  <= 0;
      else if (csr1_rd_sel == 1) csr1_rd_sel <= 0;
      else if (csr2_rd_sel == 1) csr2_rd_sel <= 0;
      else if (csr3_rd_sel == 1) csr3_rd_sel <= 0;
      else if (csr4_rd_sel == 1) csr4_rd_sel <= 0;
      else if (csr5_rd_sel == 1) csr5_rd_sel <= 0;
      wait_count <= wait_count - 1;
     end //}
    end //}

  end //}
end

always@(posedge clk or posedge rst_a)
begin
  if (rst_a) 
  begin 
    db_addr <= 32'b0;
    db_data <= 32'b0;
    db_cmd  <= 32'b0;
    db_stat <= 32'b0;
    db_rst  <= 32'b0;
    db_csr1 <= 32'b0;
    db_csr2 <= 32'b0;
    db_csr3 <= 32'b0;
    db_csr4 <= 32'b0;
    db_csr5 <= 32'b0;
  end
  else  //updating/storing local registers with the input data 
  begin
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_ADDR)   && in_dbg_cmd == `BVCI_CMD_WR) db_addr <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_DATA)   && in_dbg_cmd == `BVCI_CMD_WR) db_data <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CMD)    && in_dbg_cmd == `BVCI_CMD_WR) db_cmd  <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_STATUS) && in_dbg_cmd == `BVCI_CMD_WR) db_stat <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_RESET)  && in_dbg_cmd == `BVCI_CMD_WR) db_rst  <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR1)  && in_dbg_cmd == `BVCI_CMD_RD) db_csr1  <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR2)  && in_dbg_cmd == `BVCI_CMD_RD) db_csr2  <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR3)  && in_dbg_cmd == `BVCI_CMD_RD) db_csr3  <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR4)  && in_dbg_cmd == `BVCI_CMD_RD) db_csr4  <= in_dbg_wdata;
    if (in_dbg_cmdval && (in_dbg_address[11:0] == DB_CSR5)  && in_dbg_cmd == `BVCI_CMD_RD) db_csr5  <= in_dbg_wdata;
  end
end

always@(posedge clk or posedge rst_a)
begin // giving rspval in next cycle of cmdval
  if (rst_a) 
  begin
    out_dbg_rspval <= 1'b0;
    out_dbg_rdata  <= 32'b0;
    out_dbg_reop   <= 1'b0;
    out_dbg_rerr   <= 1'b0;
  end
  else
  begin
    out_dbg_rspval <= in_dbg_rspval;
    if(in_dbg_rspval)
    begin
    out_dbg_rdata  <= in_dbg_rdata;
    out_dbg_reop   <= in_dbg_reop;
    out_dbg_rerr   <= in_dbg_rerr;
    end
  end
end
always@(posedge clk or posedge rst_a)
begin
  if (rst_a) 
  begin
    in_dbg_cmdval_r   <= 1'b0;
  end
  else
  begin
    in_dbg_cmdval_r   <= in_dbg_cmdval;
  end
end


always@(posedge clk or posedge rst_a)
begin 
  if (rst_a) 
  begin //{
    stall <= 1'b0;
  end //}
  else if (((stall == 0) && (in_dbg_cmdval))||(wait_count > 0 && ( stall == 0 )))
  begin //{
    stall <= 1'b1;
    //out_dbg_cmdval <= in_dbg_cmdval;
  end
  else if ((stall == 1) && in_dbg_rspval) 
  begin //{
    stall <= 1'b0;
  end
end

always@(posedge clk or posedge rst_a)
begin //{
  if (rst_a) 
  begin //{
    out_dbg_cmdval  <= 1'b0;
  end //}
  else
  begin //{
    out_dbg_cmdval  <= int_dbg_cmdval;
  end //}

end //}

assign int_dbg_cmdval = (int_cmdval & ~(int_cmdval_r)) ? (int_cmdval & ~(int_cmdval_r)) :((~stall) ? in_dbg_cmdval : 0);
//(((stall == 0) && (in_dbg_cmdval)) || ((stall == 1) && (in_dbg_cmdval_r))) ? in_dbg_cmdval : 
  //                      ((wait_count > 0 && ( stall == 0 )) && (addr_wr_sel | data_wr_sel | cmd_wr_sel | stat_wr_sel | rst_wr_sel | csr_rd_sel )) ? 
    //                    (int_cmdval & ~(int_cmdval_r)) : 0 ;

always@(posedge clk or posedge rst_a)
begin 
  if (rst_a) 
  begin //{
      out_dbg_address <= 32'b0;
      out_dbg_cmd     <= 2'b0;
      //out_dbg_cmdval  <= 1'b0;
      out_dbg_wdata   <= 32'b0;
      int_cmdval      <= 1'b0;
  end //}
  else if (((stall == 0) && (in_dbg_cmdval)) || ((stall == 1) && (in_dbg_cmdval_r))) 
  begin //{
    //if((wait_count == 0) || ~(stall == 1 && in_dbg_cmdval == 1))
    //if(~(wait_count == 0 && stall == 1 && in_dbg_cmdval == 1))
    if((wait_count == 0))
    begin //{
      out_dbg_address <= in_dbg_address;
      out_dbg_cmd     <= in_dbg_cmd;
      //out_dbg_cmdval  <= in_dbg_cmdval;
      //out_dbg_rspack  <= in_dbg_rspack;
      out_dbg_wdata   <= in_dbg_wdata;
      int_cmdval      <= 1'b0;
    end //}
end //}
else if(wait_count > 0 && ( stall == 0 ))
begin //{
    if(addr_wr_sel == 1)
    begin
      out_dbg_address <= DB_ADDR_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_WR;
      int_cmdval      <= 1'b1;
      //out_dbg_cmdval  <= int_cmdval & ~(int_cmdval_r); //???
      out_dbg_wdata   <= db_addr;

    end
    else if(data_wr_sel == 1)
    begin
      out_dbg_address <= DB_DATA_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_WR;
      int_cmdval      <= 1'b1;
      //out_dbg_cmdval  <= int_cmdval & ~(int_cmdval_r); //???
      out_dbg_wdata   <= db_data;
    end
    else if(cmd_wr_sel == 1)
    begin
      out_dbg_address <= DB_CMD_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_WR;
      int_cmdval      <= 1'b1;
      //out_dbg_cmdval  <= int_cmdval & ~(int_cmdval_r); //???
      out_dbg_wdata   <= db_cmd;
    end
    else if(stat_wr_sel == 1)
    begin
      out_dbg_address <= DB_STATUS_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_WR;
      int_cmdval      <= 1'b1;
      //out_dbg_cmdval  <= int_cmdval & ~(int_cmdval_r); //???
      out_dbg_wdata   <= db_stat;
    end
    else if(rst_wr_sel == 1)
    begin
      out_dbg_address <= DB_RESET_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_WR;
      int_cmdval      <= 1'b1;
      //out_dbg_cmdval  <= int_cmdval & ~(int_cmdval_r); //???
      out_dbg_wdata   <= db_rst;
    end
    else if(csr1_rd_sel == 1)
    begin
      out_dbg_address <= DB_CSR1_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_RD;
      int_cmdval      <= 1'b1;
      out_dbg_wdata   <= db_csr1;
    end
    else if(csr2_rd_sel == 1)
    begin
      out_dbg_address <= DB_CSR2_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_RD;
      int_cmdval      <= 1'b1;
      out_dbg_wdata   <= db_csr2;
    end
    else if(csr3_rd_sel == 1)
    begin
      out_dbg_address <= DB_CSR3_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_RD;
      int_cmdval      <= 1'b1;
      out_dbg_wdata   <= db_csr3;
    end
    else if(csr4_rd_sel == 1)
    begin
      out_dbg_address <= DB_CSR4_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_RD;
      int_cmdval      <= 1'b1;
      out_dbg_wdata   <= db_csr4;
    end
    else if(csr5_rd_sel == 1)
    begin
      out_dbg_address <= DB_CSR5_ADDR; 
      out_dbg_cmd     <= `BVCI_CMD_RD;
      int_cmdval      <= 1'b1;
      out_dbg_wdata   <= db_csr5;
    end

end //}
else int_cmdval <=1'b0;
    //stall = 1;      
//  end //}
  //else if (in_dbg_rspval == 1) stall = 0 ;
end

//always@*
//begin
//  if(stall ==0)
//  begin
//    if(addr_wr_sel = 1)
//    begin
//      i_dbg_address = DB_ADDR; 
//      i_dbg_cmd     = `BVCI_CMD_WR;
//      i_dbg_cmdval  = 1'b1; //???
//      i_dbg_wdata   = db_addr;
//    end
//    else if(data_wr_sel = 1)
//    begin
//      i_dbg_address = DB_DATA; 
//      i_dbg_cmd     = `BVCI_CMD_WR;
//      i_dbg_cmdval  = 1'b1; //???
//      i_dbg_wdata   = db_data;
//    end
//    else if(cmd_wr_sel = 1)
//    begin
//      i_dbg_address = DB_CMD; 
//      i_dbg_cmd     = `BVCI_CMD_WR;
//      i_dbg_cmdval  = 1'b1; //???
//      i_dbg_wdata   = db_cmd;
//    end
//    else if(stat_wr_sel = 1)
//    begin
//      i_dbg_address = DB_STAT; 
//      i_dbg_cmd     = `BVCI_CMD_WR;
//      i_dbg_cmdval  = 1'b1; //???
//      i_dbg_wdata   = db_stat;
//    end
//    else if(addr_wr_sel = 1)
//    begin
//      i_dbg_address = in_dbg_address; 
//      i_dbg_cmd     = in_dbg_cmd;
//      i_dbg_cmdval  = in_dbg_cmdvali
//      i_dbg_wdata   = in_dbg_wdata ;
//    end
//
//  end
//end


//assign out_dbg_address = in_dbg_address;
//assign out_dbg_cmd = in_dbg_cmd;
//assign out_dbg_cmdval = in_dbg_cmdval;
assign out_dbg_rspack = in_dbg_rspack;
//assign out_dbg_wdata = in_dbg_wdata;
endmodule
