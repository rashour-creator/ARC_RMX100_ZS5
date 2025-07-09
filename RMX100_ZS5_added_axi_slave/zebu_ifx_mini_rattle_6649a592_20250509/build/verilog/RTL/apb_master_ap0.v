// Library ARC_Soc_Trace-1.0.999999999

`include "defines.v"
`include "dw_dbp_defines.v"

module apb_master_ap0 (
  input		[31:0]          select_in,
  input                         clk,
  input                         rst_a,

  input                         dbg_cmdval,     // |cmdval| from JTAG
  output                        dbg_cmdack,     // BVCI |cmd| acknowledge
  input       [31:2]            dbg_address,    // |address| from JTAG
  input       [`DBG_BE_RANGE]   dbg_be,         // |be| from JTAG
  input       [`DBG_CMD_RANGE]  dbg_cmd,        // |cmd| from JTAG
  input       [`DBG_DATA_RANGE] dbg_wdata,      // |wdata| from JTAG

  input                         dbg_rspack,     // |rspack| from JTAG
  output                        dbg_rspval,     // BVCI response valid
  output  reg [`DBG_DATA_RANGE] dbg_rdata,     // BVCI data to Debug host 
  output                        dbg_reop,      // BVCI response EOP 
  output                        dbg_rerr,      // BVCI response error 


  output reg                    pseldbg,
  output reg [31:2]             paddrdbg,
  output reg                    pwritedbg,
  output reg                    penabledbg,
  output reg [31:0]             pwdatadbg,

  input [31:0]                  prdatadbg,
  input                         preadydbg,
  input                         pslverrdbg
);

//probably only works with pclk_en true (PCLK = CPU CLK)
reg [31:0] i_prdatadbg;
reg bvci_read;
reg bvci_write;

reg                         rspval_r;         // rspval state variable
reg                         rspval_nxt; 

/////////////////////////////////////////
//`define APB_ROM_SPACE 20'hFFFF4 //10001
//`define APB_ROM_BASE_ADDR 32'h00001000 //10001000
//`define APB_AP_REG_SPACE 20'hFFFF3 //10000

localparam DB_STATUS  = 32'hFFFF3000; //10000000;
localparam DB_DATA  = 32'hFFFF300c; //1000000c;
localparam DB_CMD  = 32'hFFFF3004; //10000004;
localparam DB_ADDR =  32'hFFFF3008; //10000008;

localparam APB_STATUS  = 10'h000; //10000000;
localparam APB_DATA    = 10'h003; //1000000c;
localparam APB_CMD     = 10'h001; //10000004;
localparam APB_ADDR    = 10'h002; //10000008;
localparam APB_RESET   = 10'h004; //10000008;

localparam APB_CSR1 =  10'h100;
localparam APB_CSR2 =  10'h101;
localparam APB_CSR3 =  10'h102;
localparam APB_CSR4 =  10'h103;
localparam APB_CSR5 =  10'h104;

reg [31:0] apb_addr_nxt;
reg [31:0] apb_data_nxt;
reg [31:0] apb_cmd_nxt;
//reg apb_rom_sel_nxt;
//reg cln_rom_sel_nxt;

wire [31:0] i_apb_data;
reg [31:0] apb_addr;
reg [31:0] apb_data;
reg [31:0] apb_cmd;

wire  apb_addr_wen;
wire  apb_data_wen;
wire  apb_cmd_wen;

//reg apb_rom_sel;
//reg cln_rom_sel;
reg [31:0] rom_prdata;
wire cln_rom_sel;
wire csr_access_en;

reg [31:0] apb_rdata;
wire apb_rerr;
wire apb_reop;
wire apb_cmdack, apb_rspval;
wire invalid_select;
wire slv_rspval_nxt;
reg slv_rspval_r;
reg pslverrdbg_r;
reg [1:0] dbg_trans_state_r;
reg [1:0] dbg_trans_state_nxt;
//reg i_write_r, i_write_nxt;
reg i_cmd_en;
reg reset_done_r;
reg i_dbg_cmdack, i_dbg_rspval;

reg                         db_addr_match;    // 1 if no address match

reg                         db_addr_err;      // 1 if unmatched access
reg                         db_cmd_err;       // 1 if illegal cmd given
reg                         db_read_err;      // 1 if read from reset reg
reg                         db_be_err;        // 1 if some BE bits not set
reg rerr_nxt;
reg rerr_r;

reg i_write_r, i_write_nxt;
reg i_enable_r, i_enable_nxt;
wire [11:2] val_dbg_address;

/////////////////select division//////////
localparam my_bits = 2;
wire [my_bits-1:0] my_select = select_in[my_bits-1:0];

// Select for non-leaf kid: strip off my bits.
wire [31:0] next_select =  select_in >> my_bits;
/////////////////////////////////////////
wire db_cmdval, client_cmdval, csr_acc_en;
assign csr_access_en = (dbg_cmdval & ((dbg_address[11:2] == APB_CSR1) | //to enable direct access to CSR registers 
				      (dbg_address[11:2] == APB_CSR2) |
				      (dbg_address[11:2] == APB_CSR3) |
				      (dbg_address[11:2] == APB_CSR4) |
                                      (dbg_address[11:2] == APB_CSR5)));
assign db_cmdval = (dbg_cmdval & ((my_select == 0) | (my_select == 1) | (cln_rom_sel) | (csr_access_en)));
assign client_cmdval = (dbg_cmdval & ~((my_select == 0) | (my_select == 1)));
//

assign invalid_select = ((next_select != 32'b0) & (my_select == 3)) && dbg_cmdval;
//////////////
//assign cln_rom_sel = ((my_select == 2) & (next_select ==32'b0));
assign cln_rom_sel = 1'b0;

assign apb_addr_wen = (bvci_write && dbg_address[11:2] == APB_ADDR);
assign apb_data_wen = (bvci_write && dbg_address[11:2] == APB_DATA);
assign apb_cmd_wen  = (bvci_write && dbg_address[11:2] == APB_CMD);

always @*
begin //{
  apb_addr_nxt = apb_addr_wen ? dbg_wdata : apb_addr;
  apb_data_nxt = apb_data_wen ? dbg_wdata : apb_data;
  apb_cmd_nxt  = apb_cmd_wen  ? dbg_wdata : apb_cmd;
end //}


// spyglass disable_block Ar_resetcross01
// SMD: Unsynchronized reset crossing detected
// SJ:  reconfigurable code
always@(posedge clk or posedge rst_a)
begin
   if(rst_a == 1'b1)
   begin //{
     apb_addr <= 32'b0;
     apb_data <= 32'b0;
     apb_cmd  <= 32'b0;
     //apb_rom_sel = 1'b0;
     //cln_rom_sel = 1'b0;
   end //}
   else begin //{
     apb_addr  <= apb_addr_nxt;
     apb_data  <= apb_data_nxt;
     apb_cmd   <= apb_cmd_nxt;
     //apb_rom_sel  = apb_rom_sel_nxt;
     //cln_rom_sel  = cln_rom_sel_nxt;
   end //}
end
// spyglass enable_block Ar_resetcross01

///Rom Table of APB ///
always@*
begin: rom_table_PROC
  rom_prdata = 32'b0;
  if (my_select == 1) //(apb_rom_sel)
  begin
    casez(apb_addr[11:0])

    12'd0: 
    begin
      rom_prdata = {20'h0000_2,//00002, // [31:12] entry offset
                  3'b0, // [11:9] reserv
                  5'd0, // [8:4] pwrid
                  1'b0, // [3] reserv
                  1'b0, // [2] pwrvld
                  1'b1, // [1] 32-bit format
                  1'b1  // [0] present 
                  };
    end
    12'd4: 
    begin
      rom_prdata = {20'h0000_0, //20000, // [31:12] entry offset
                  3'b0, // [11:9] reserv
                  5'd0, // [8:4] pwrid
                  1'b0, // [3] reserv
                  1'b0, // [2] pwrvld
                  1'b0, // [1] 32-bit format
                  1'b0  // [0] present 
                  };
    end
    12'h400: rom_prdata = {24'h0,8'h10}; // [7:4] Component class (0x1 Rom Table) [3:0] Preamble 1 (0x0)
    12'hFCC: rom_prdata = 32'b0; // memory_type
    12'hFD0: rom_prdata = {24'h0,8'h04}; // PIDR4 // [7:4] size // [3:0] DES_2
    12'hFD4: rom_prdata = {24'h0,8'h00}; // PIDR5 // reserv
    12'hFD8: rom_prdata = {24'h0,8'h00}; // PIDR6 // reserv
    12'hFDC: rom_prdata = {24'h0,8'h00}; // PIDR7 // reserv
    12'hFE0: rom_prdata = {24'h0,8'h01}; // PIDR0 // [7:0] Part number bits
    12'hFE4: rom_prdata = {24'h0,8'h80}; // PIDR1 // [7:4] JEP106 identification code bits[3:0] // [3:0] Part number bits[11:8]
    12'hFE8: rom_prdata = {24'h0,8'h0D}; // PIDR2 // [7:4] Revision // [3] JEDEC // [2:0] JEP106 identification code[6:4]
    12'hFEC: rom_prdata = {24'h0,8'h00}; // PIDR3 // [7:4] RevAnd // [3:0] Customer Modified
    12'hFF0: rom_prdata = {24'h0,8'h0D}; // CIDR0 // [7:0] Preamble 0 (0x0D)
    12'hFF4: rom_prdata = {24'h0,8'h10}; // CIDR1 // [7:4] Component class (0x1 Rom Table) [3:0] Preamble 1 (0x0)
    12'hFF8: rom_prdata = {24'h0,8'h05}; // CIDR2 // [7:0] Preamble 2 (0x05)
    12'hFFC: rom_prdata = {24'h0,8'hB1}; // CIDR3 // [7:0] Preamble 3 (0xB1)
    default: rom_prdata = 32'b0;                      
    endcase
  end
end // rom_table_PROC

//as muxing btw cln and trace is done in dw_dbp module => prdatadbg/pslverrdbg;
//here only muxing between rom (rom_prdata) and apb regfile data(apb_rdata)
//assign dbg_rdata = (my_select == 1)? rom_prdata:
//        	   (my_select == 0) ? apb_rdata:  prdatadbg;
//assign dbg_rdata = apb_rdata;

// spyglass disable_block Ar_resetcross01
// SMD: Unsynchronized reset crossing detected
// SJ:  reconfigurable code
// spyglass disable_block Ac_unsync01 Ac_unsync02
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck
always@(posedge clk or posedge rst_a)
begin
if(rst_a) dbg_rdata <= 32'b0;
else 
begin
  if(my_select == 1) dbg_rdata <= apb_rdata; //rom_prdata;
  else if (my_select == 0) dbg_rdata <= apb_rdata;
  else if (bvci_read && rspval_nxt) dbg_rdata <= apb_rdata;
  else if (slv_rspval_nxt & ~slv_rspval_r) dbg_rdata <= prdatadbg;
end
end
// spyglass enable_block Ac_unsync01 Ac_unsync02

always@(posedge clk or posedge rst_a)
begin
if(rst_a) pslverrdbg_r <= 1'b0;
else 
begin
  if (slv_rspval_nxt & ~slv_rspval_r) pslverrdbg_r <= pslverrdbg;
end
end
// spyglass enable_block Ar_resetcross01


assign i_apb_data = (my_select == 1)? rom_prdata: apb_data;

assign dbg_rerr = (invalid_select) ? 1'b1:
                  (my_select == 1)? 1'b0:
		  (my_select == 0) ? apb_rerr: pslverrdbg_r;
assign dbg_reop = (my_select == 0) ? apb_reop:1'b1;

// spyglass disable_block Ar_resetcross01
// SMD: Unsynchronized reset crossing detected
// SJ:  reconfigurable code
always@(posedge clk or posedge rst_a)
begin
if(rst_a) slv_rspval_r <= 1'b0;
else slv_rspval_r <= slv_rspval_nxt;
end
// spyglass enable_block Ar_resetcross01

assign slv_rspval_nxt = ((i_dbg_rspval ) | (slv_rspval_r & ~dbg_rspack));



assign dbg_cmdack = (invalid_select) ? (dbg_cmdval & reset_done_r) : (((my_select == 0) || (my_select == 1)) ? apb_cmdack : i_dbg_cmdack);
assign dbg_rspval = ((invalid_select) || (my_select == 0) || (my_select == 1)) ? apb_rspval:slv_rspval_r ;

always @(posedge clk or posedge rst_a)
begin : reset_done_PROC
  if (rst_a == 1'b1)
    reset_done_r  <=  1'b0;
  else
    reset_done_r  <=  1'b1;
end

//state machine for BVCI2APB
always @*
begin //{
  //defaults
  pseldbg = 1'b0;
  pwritedbg = i_write_r;
  penabledbg = 1'b0;
  i_dbg_cmdack = 1'b0;
  i_dbg_rspval = 1'b0;
  i_write_nxt = 1'b0;
  i_enable_nxt = 1'b0;
  i_cmd_en = 1'b0;
  dbg_trans_state_nxt = 2'b00;
  //if (dbg_address[31:12] == `APB_AP_REG_SPACE)
  //begin //{
  case (dbg_trans_state_r)
    2'b00: // IDLE
    begin //{
	  if (client_cmdval == 1'b1)
      begin //{
		if (dbg_cmd == 2'b01)
			i_write_nxt = 1'b0;
		else if (dbg_cmd == 2'b10)
			i_write_nxt = 1'b1;
		else if (dbg_cmd == 2'b00)
			i_enable_nxt = 1'b1;
		i_cmd_en = 1'b1;
		if (reset_done_r == 1'b1)
		begin
		  i_dbg_cmdack = 1'b1;
		  dbg_trans_state_nxt = 2'b01;
		end
		else
		  dbg_trans_state_nxt = 2'b00;
     end //}
	end //}

    2'b01: // SETUP
    begin //{
	  i_write_nxt = i_write_r;
	  i_enable_nxt = i_enable_r;
	  pseldbg = 1'b1;
	  if(cln_rom_sel == 1'b1)
	  begin
		if (apb_cmd == 2'b01) pwritedbg  = 1'b0;
		else if (apb_cmd == 2'b10) pwritedbg  = 1'b1;
	  end
	    dbg_trans_state_nxt = 2'b10;
    end //}

    2'b10: // ACCESS
    begin //{
	  i_enable_nxt = i_enable_r;
	  pseldbg = 1'b1;
	  penabledbg = ~i_enable_r;
	  if (preadydbg == 1'b1) begin //{
            i_dbg_rspval = 1'b1;
	    if(dbg_rspack == 1'b1)
              dbg_trans_state_nxt = 2'b00;
            else
              i_write_nxt = i_write_r;
	  end //}
          else begin
            dbg_trans_state_nxt = 2'b10;
            i_write_nxt = i_write_r;
          end
    end //}

    default:
    begin
      pwritedbg = i_write_r;
    end
  endcase
  //end //}
end //}

always @*
begin : rspval_nxt_PROC
  rspval_nxt =   ((invalid_select) ? (dbg_cmdval & reset_done_r) : ( db_cmdval & apb_cmdack  )) || (rspval_r & (~dbg_rspack));
end 

always@*
begin
  db_addr_match = (dbg_address[11:2] == APB_STATUS)|(dbg_address[11:2] == APB_CMD)|  
                  (dbg_address[11:2] == APB_ADDR)  |(dbg_address[11:2] == APB_DATA)|
                  (dbg_address[11:2] == APB_RESET) |(dbg_address[11:2] == APB_CSR1)|
                  (dbg_address[11:2] == APB_CSR2)  |(dbg_address[11:2] == APB_CSR3)|
                  (dbg_address[11:2] == APB_CSR4)  |(dbg_address[11:2] == APB_CSR5);
  db_cmd_err     = db_cmdval & (~(bvci_read | bvci_write));
  db_addr_err   = db_cmdval & (~db_addr_match);
  db_be_err      = db_cmdval & (~(&dbg_be));
  db_read_err  = (dbg_address[11:2] == APB_RESET) ? bvci_read : 1'b0;
  rerr_nxt      =   (   db_addr_err
                           | db_cmd_err
                           | db_read_err
                           | db_be_err
                         ) |  (   rerr_r & (~dbg_rspack));
end

// spyglass disable_block Ar_resetcross01
// SMD: Unsynchronized reset crossing detected
// SJ:  reconfigurable code
// spyglass disable_block Ac_unsync01 Ac_unsync02
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck
always @(posedge clk or posedge rst_a)
begin //{
	if (rst_a == 1'b1)
		i_write_r <= 1'b0;
	else
		i_write_r <= i_write_nxt;
end //}
always @(posedge clk or posedge rst_a)
begin //{
	if (rst_a == 1'b1)
		i_enable_r <= 1'b0;
	else
		i_enable_r <= i_enable_nxt;
end //}

always @(posedge clk or posedge rst_a)
begin : db_state_PROC
  if (rst_a == 1'b1)
    begin
    rspval_r      <=  1'b0;
    end
  else
    begin
    rspval_r      <=  rspval_nxt;
    end
end

always @(posedge clk or posedge rst_a)
begin : rerr_r_PROC
  if (rst_a == 1'b1)
  begin
    rerr_r <= 1'b0;
  end
  else
  begin
    rerr_r <= rerr_nxt;
  end
end 

always @(posedge clk or posedge rst_a)
begin //{
	if (rst_a == 1'b1)
	begin
		paddrdbg <= 30'b0; // may need translation & registering?
		pwdatadbg <= 32'b0; // needs to be sampled, and write
	end
	else if (i_cmd_en == 1'b1)
	begin
//		if(cln_rom_sel==1'b1)
//		begin
//		 paddrdbg <= apb_addr;
//		 pwdatadbg <= apb_data;
//		end
//		else
		begin
		paddrdbg[31:12] <= next_select[19:0];
		paddrdbg[11:2] <= dbg_address[11:2];  //_nxt;//[31:2]; 
		pwdatadbg <= dbg_wdata;
		end
	end
end  //}

always @(posedge clk or posedge rst_a)
begin //{
  if (rst_a == 1'b1)
  begin
    dbg_trans_state_r <= 2'b00;
  end
  else
  begin
    dbg_trans_state_r <= dbg_trans_state_nxt;
  end
end //}

// spyglass enable_block Ac_unsync01 Ac_unsync02
// spyglass enable_block Ar_resetcross01

///////////////////////////////////////////////////
////////////////////////////////////////////////

assign val_dbg_address =  db_cmdval ? dbg_address[11:2] : 10'b0;
  

always @*
  begin //{
    bvci_read    = db_cmdval & (dbg_cmd == `BVCI_CMD_RD);
    bvci_write   = db_cmdval & (dbg_cmd == `BVCI_CMD_WR);
    apb_rdata    = dbg_rdata;
    if(bvci_read)
    begin //{
      case(val_dbg_address)
        APB_STATUS: //read-only
          apb_rdata = 32'h24;
        APB_CMD:
          apb_rdata = apb_cmd;
        APB_ADDR:
          apb_rdata = apb_addr;
        APB_DATA:
          apb_rdata = i_apb_data; //i_apb_data; //apb_data should be updated to include rom_rdata also
        //APB_RESET:
        APB_CSR1: //read-only
          apb_rdata = (my_select == 1) ? 32'h10 :
		       32'h90; // 31:8- reserved ; 7:0 - class
        APB_CSR2: //read-only
          apb_rdata = (my_select == 1) ? 32'h0 :
		       32'h14B0_0003; 
        APB_CSR3: //read-only
          apb_rdata = (my_select == 1) ? 32'h0 :
		       32'h0; //2- LD; 1-LA
        APB_CSR4: //read-only
          apb_rdata = (my_select == 1) ? 32'h0 :
		       32'h00001000; //`APB_ROM_BASE_ADDR;
	APB_CSR5: //read-only
          apb_rdata = (my_select == 1) ? 32'h0 :
		       32'h0; //`APB_ROM_UPPER_BASE_ADDR;
        12'hFBC>>2: apb_rdata = {11'h258,1'b1,4'h1,16'h0301};  // DEVARCH
        12'hFC0>>2: apb_rdata = 32'h0000000;           // DEVID2
        12'hFC4>>2: apb_rdata = 32'h0000000;           // DEVID1
        12'hFC8>>2: apb_rdata = 32'h0000020;           // DEVID
        12'hFCC>>2: apb_rdata = {24'h000000, 8'h00};   // DEVTYPE Other Misc
	12'hFD0>>2: apb_rdata = {24'h000000, 8'h04};   // PIDR4
	12'hFD4>>2: apb_rdata = {24'h000000, 8'h00};   // PIDR5
	12'hFD8>>2: apb_rdata = {24'h000000, 8'h00};   // PIDR6
	12'hFDC>>2: apb_rdata = {24'h000000, 8'h00};   // PIDR7
	12'hFE0>>2: apb_rdata = {24'h000000, 8'h01};   // PIDR0
	12'hFE4>>2: apb_rdata = {24'h000000, 8'h80};   // PIDR1
	12'hFE8>>2: apb_rdata = {24'h000000, 8'h0D};   // PIDR2
	12'hFEC>>2: apb_rdata = {24'h000000, 8'h00};   // PIDR3
	12'hFF0>>2: apb_rdata = {24'h000000, 8'h0D};   // CIDR0
	12'hFF4>>2: apb_rdata = {24'h000000, 8'h90};   // CIDR1
	12'hFF8>>2: apb_rdata = {24'h000000, 8'h05};   // CIDR2
	12'hFFC>>2: apb_rdata = {24'h000000, 8'hB1};   // CIDR3
	default: apb_rdata = 32'b0;
      endcase
    end //} 
  end //}
//wire apb_cmdack , apb_reop, apb_rspval, apb_rerr;
//assign i_apb_data = rom_sel ? rom_rdata : apb_data;
assign apb_cmdack = db_cmdval & reset_done_r; //how to generate this cmd_ack? nd rspval, rerr?
assign apb_reop = rspval_r;
assign apb_rspval = rspval_r;
assign apb_rerr = rerr_r;


endmodule

