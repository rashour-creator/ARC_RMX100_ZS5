// Library ARC_Soc_Trace-1.0.999999999
//////////////////////
//`define APB_SLAVES 1 
//`define ARRAY_SIZE 2**(`APB_SLAVES)
//`define APB_EP_SEL 1
//`define AXI_EP_SEL 0
`include "dw_dbp_defines.v"
//`include "defines.v"

////////////////////////////////////////
module dw_dbp(
  input                       clk,
 
  input                       test_mode,
  input                       jtag_tck,
  input                       jtag_trst_n,
  
  input                       jtag_tdi,
  input                       jtag_tms,
/////////apb_master inputs ////////////
  //input                         dev0_clk, //pclkdbg,

	//slave 1 =cln

  output  [31:2]             dbg_apb_paddr,
  output                     dbg_apb_psel,
  output                     dbg_apb_penable,
  output                     dbg_apb_pwrite,
  output  [31:0]             dbg_apb_pwdata,
  input                      dbg_apb_pready,
  input [31:0]               dbg_apb_prdata,
  input                      dbg_apb_pslverr,

//  output                       apb_niden,
//  output                       apb_dbgen,



/////////jtag outputs////////////
  output                      jtag_tdo,  // for rascal
  output                      rv_dmihardresetn,
  output                      jtag_tdo_oe,
  output                      jtag_rtck,

//	output dbg_prot_sel,
	
	/////////////////////////
        input                        bri_awready,
	input                        bri_wready,
	input  [4-1:0]        bri_bid,
	input  [2-1:0]       bri_bresp,
	input                        bri_bvalid,
	input                        bri_arready,
	input  [4-1:0]        bri_rid,
	input  [32-1:0]       bri_rdata,
	input                        bri_rlast,
	input                        bri_rvalid,
	input  [2-1:0]       bri_rresp,

//////outputs
	output [4-1:0]        bri_awid,
	output [32-1:0]       bri_awaddr,
	output [4-1:0]        bri_awlen,
	output [3-1:0]       bri_awsize,
	output [2-1:0]      bri_awburst,
//	output [2-1:0]       bri_awlock,
	output [4-1:0]      bri_awcache,
        output [3-1:0]       bri_awprot,
	output                       bri_awvalid,
	output [4-1:0]        bri_wid,
	output [32-1:0]       bri_wdata,
	output [(32/8)-1:0]   bri_wstrb,
	output                       bri_wlast,
	output                       bri_wvalid,
	output                       bri_bready,
	output [4-1:0]        bri_arid,
	output [32-1:0]       bri_araddr,
	output [4-1:0]        bri_arlen,
	output [3-1:0]       bri_arsize,
	output [2-1:0]      bri_arburst,
//	output [2-1:0]       bri_arlock,
	output [4-1:0]      bri_arcache,
	output [3-1:0]       bri_arprot,
	output                       bri_arvalid,
	output                       bri_rready,
//	output                       bri_busy,

input                       rst_a	
);

reg [31:2]            apb_paddrdbg;
reg                   apb_pseldbg;
reg                   apb_penabledbg;
reg                   apb_pwritedbg;
reg [31:0]            apb_pwdatadbg;

wire                  apb_preadydbg;
wire [31:0]           apb_prdatadbg;
wire                  apb_pslverrdbg;

assign dbg_apb_paddr = apb_paddrdbg;
assign dbg_apb_psel = apb_pseldbg;
assign dbg_apb_penable = apb_penabledbg;
assign dbg_apb_pwrite = apb_pwritedbg;
assign dbg_apb_pwdata = apb_pwdatadbg;


assign apb_preadydbg = dbg_apb_pready;
assign apb_prdatadbg = dbg_apb_prdata;
assign apb_pslverrdbg = dbg_apb_pslverr;

////////////////////////////////////

wire [31:2]               ap0_dbg_address;
wire [3:0]                ap0_dbg_be;
wire [1:0]                ap0_dbg_cmd;
wire                      ap0_dbg_cmdval;
//wire                      ap0_dbg_eop;
wire                      ap0_dbg_rspack;
wire [31:0]               ap0_dbg_wdata;
wire                       ap0_dbg_cmdack;
wire [31:0]                ap0_dbg_rdata;
wire                       ap0_dbg_reop;
wire                       ap0_dbg_rspval;
wire                       ap0_dbg_rerr;

wire [31:0]               ap1_dbg_address;
wire [3:0]                ap1_dbg_be;
wire [1:0]                ap1_dbg_cmd;
wire                      ap1_dbg_cmdval;
wire                      ap1_dbg_eop;
wire                      ap1_dbg_rspack;
wire [31:0]               ap1_dbg_wdata;
wire                       ap1_dbg_cmdack;
wire [31:0]                ap1_dbg_rdata;
wire                       ap1_dbg_reop;
wire                       ap1_dbg_rspval;
wire                       ap1_dbg_rerr;

////////////////////////////////////

wire [4-1:0]        i_bri_awid;
wire [32-1:0]       i_bri_awaddr;
wire [4-1:0]        i_bri_awlen;
wire [3-1:0]       i_bri_awsize;
wire [2-1:0]      i_bri_awburst;
wire [2-1:0]       i_bri_awlock;
wire [4-1:0]      i_bri_awcache;
wire [3-1:0]       i_bri_awprot;
wire                       i_bri_awvalid;
wire [4-1:0]        i_bri_wid;
wire [32-1:0]       i_bri_wdata;
wire [(32/8)-1:0]   i_bri_wstrb;
wire                       i_bri_wlast;
wire                       i_bri_wvalid;
wire                       i_bri_bready;
wire [4-1:0]        i_bri_arid;
wire [32-1:0]       i_bri_araddr;
wire [4-1:0]        i_bri_arlen;
wire [3-1:0]       i_bri_arsize;
wire [2-1:0]      i_bri_arburst;
wire [2-1:0]       i_bri_arlock;
wire [4-1:0]      i_bri_arcache;
wire [3-1:0]       i_bri_arprot;
wire                       i_bri_arvalid;
wire                       i_bri_rready;
wire                       i_bri_busy;

////////////////////////////////////////////// 
wire pseldbg_mst;
//`for (1 = 0;	1 < `APB_SLAVES; 1++)//{
		wire preadydbg_i;
//`endfor //}
//wire [`ARRAY_SIZE:0]pseldbg;
///////for inputs////
wire                       dbg_cmdack;
wire [31:0]                dbg_rdata;
wire                       dbg_reop;
wire                       dbg_rspval;
wire                       dbg_rerr;

wire [31:0]                int_dbg_rdata;
wire                       int_dbg_reop;
wire                       int_dbg_rspval;
wire                       int_dbg_rerr;



///sel declarations///
wire axi_cmdack;
wire [31:0] axi_rdata;
wire axi_reop;
wire axi_rspval;
wire axi_rerr;

wire apb_cmdack;
wire [31:0] apb_rdata;
wire apb_reop;
wire apb_rspval;
wire apb_rerr;
reg [31:0]               dbg_address;
reg [3:0]                dbg_be;
reg [1:0]                dbg_cmd;
reg                      dbg_cmdval;
reg                      dbg_daddrval;
reg                      dbg_eop;
reg                      dbg_rspack;
reg [31:0]               dbg_wdata;

wire [31:0]              int_dbg_address;
wire [3:0]               int_dbg_be;
wire [1:0]               int_dbg_cmd;
wire                     int_dbg_cmdval;
wire                     int_dbg_daddrval;
wire                     int_dbg_eop;
wire                     int_dbg_rspack;
wire [31:0]              int_dbg_wdata;
///////////////////////////////////
reg [31:0]               axi_address;
reg [3:0]                axi_be;
reg [1:0]                axi_cmd;
reg                      axi_cmdval;
reg                      axi_eop;
reg                      axi_rspack;
reg [31:0]               axi_wdata;

reg [31:0]               apb_address;
reg [3:0]                apb_be;
reg [1:0]                apb_cmd;
reg                      apb_cmdval;
reg                      apb_eop;
reg                      apb_rspack;
reg [31:0]               apb_wdata;

///////////////dp declarations////////////////////////
reg [31:0]  dp_addr_nxt;
reg [31:0]  dp_data_nxt;
reg [31:0]  dp_cmd_nxt;

//reg rom_sel_nxt;

reg [31:0]  dp_addr;
reg [31:0]  dp_data;
reg [31:0]  dp_cmd;

//reg rom_sel;
reg [31:0] rom_rdata;

//reg [31:0] dp_identity;
//reg [31:0] dp_identity1;
//reg [31:0] dp_base_ptr0;
//reg [31:0] dp_base_ptr1;

wire [31:0] dp_identity;
wire [31:0] dp_identity0;
wire [31:0] dp_identity1;
wire [31:0] dp_base_ptr0;
wire [31:0] dp_base_ptr1;
reg [31:0] dp_rdata, dp_rdata_r;

wire dp_cmdack;
wire dp_reop;
wire dp_rspval;
wire dp_rerr;

localparam DP_STATUS = 12'h000;
localparam DP_DATA_HI =  12'h014;
localparam DP_DATA =  12'h00c;
localparam DP_CMD  = 12'h004;
localparam DP_ADDR_HI  = 12'h018;
localparam DP_ADDR  = 12'h008;
localparam DP_RESET = 12'h010;

localparam BVCI_CMD_RD = 2'b01;
localparam BVCI_CMD_WR = 2'b10;


  localparam DB_CSR1 =  12'h400;
  localparam DB_CSR2  = 12'h404;
  localparam DB_CSR3  = 12'h408;
  localparam DB_CSR4  = 12'h40C;
  localparam DB_CSR5 =  12'h410;
  localparam DP_SELECT =  12'h20;

  reg bvci_read;
  reg bvci_write;
  wire [31:0] i_dp_data;
///////////////////////////////////////
/////////////////select division//////////


wire rst_a_s;
//////////////////////////////////////////////////////////////////////////////
// Module instantiation - reset_ctrl                                        //
//rst_a_s
//////////////////////////////////////////////////////////////////////////////

dwt_reset_ctrl u_dwt_reset_ctrl(
  .clk                (clk            ),
  .rst_a              (rst_a          ),
  .test_mode          (test_mode      ),
  .rst                (rst_a_s        )
);
//////////////////////////////////////////////////////////////////////////////
// Module instantiation - apb_rst_ctrl                                        //
//////////////////////////////////////////////////////////////////////////////

localparam my_bits = 2;
reg [31:0] select_in;
reg [31:0] select_nxt;
wire select_wen;
wire dp_addr_wen;
wire dp_data_wen;
wire dp_cmd_wen;
// spyglass disable_block Ar_resetcross01
// SMD: Unsynchronized reset crossing detected
// SJ:  reconfigurable code
// spyglass disable_block Ac_unsync01
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck
always@(posedge clk or posedge rst_a_s)
begin
   if(rst_a_s == 1'b1)
   begin //{
     select_in  <= 32'd10;
     dp_addr <= 32'b0;
     dp_data <= 32'b0;
     dp_cmd  <= 32'b0;
     //rom_sel = 1'b0;
   end //}
   else 
   begin //{
     if(select_wen)
     select_in   <= select_nxt;
     if(dp_addr_wen)
     dp_addr  <= dp_addr_nxt;
     if(dp_data_wen)
     dp_data  <= dp_data_nxt;
     if(dp_cmd_wen)
     dp_cmd   <= dp_cmd_nxt;
     //rom_sel  = rom_sel_nxt;
   end //}
end
// spyglass enable_block Ac_unsync01

reg [31:0] valid_select;

reg reset_done_r;
always @(posedge clk or posedge rst_a_s)
begin : reset_done_PROC
  if (rst_a_s == 1'b1)
    reset_done_r  <=  1'b0;
  else
    reset_done_r  <=  1'b1;
end

reg                         rspval_r;         // rspval state variable
reg                         rspval_nxt;
reg [4:0]                   rspval_r_cntr;    // rspval state variable

reg [my_bits-1:0] my_select; 
reg sel_rw;
// spyglass disable_block Ac_unsync01
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck

always@(posedge clk or posedge rst_a_s)
begin
  if (rst_a_s) sel_rw <= 0;
  else 
  begin
    if (dbg_cmdval && ((dbg_address[11:0] == DP_SELECT) && (~dbg_daddrval))) sel_rw <= 1;
    else sel_rw <= 0;
  end
end
// spyglass enable_block Ac_unsync01

always@*
begin
   my_select    = select_in[my_bits-1:0];
   valid_select = select_in;
end

// Select for non-leaf kid: strip off my bits.
wire [31:0] next_select =  valid_select >> my_bits;
wire dp_cmdval;
assign dp_cmdval = (dbg_cmdval && ((dbg_address[11:0] == DP_SELECT) && (~dbg_daddrval))) ? dbg_cmdval : (((my_select == 0)||(my_select == 1)) ? dbg_cmdval : 1'b0);
/////////////////////////////////////////
/////////////for rspval

  always @*
  begin : rspval_nxt_PROC
  rspval_nxt =   (    dp_cmdval & dp_cmdack & ~rspval_r)  
              || (   rspval_r & (~dbg_rspack));
  end 
  
// spyglass disable_block Ac_unsync01 Ac_unsync02
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck
  always @(posedge clk or posedge rst_a_s)
  begin : db_state_PROC
    if (rst_a_s == 1'b1)
      begin
      rspval_r      <=  1'b0;
      dp_rdata_r    <=  32'b0;
      end
    else
      begin
      rspval_r      <=  rspval_nxt;
      dp_rdata_r    <=  dp_rdata;
      end
  end
// spyglass enable_block Ac_unsync01 Ac_unsync02
  
  //////////rerr
reg                         db_addr_match;    // 1 if no address match

reg                         db_addr_err;      // 1 if unmatched access
reg                         db_cmd_err;       // 1 if illegal cmd given
reg                         db_read_err;      // 1 if read from reset reg
reg                         db_be_err;        // 1 if some BE bits not set
reg			    invalid_sel_err;
reg rerr_nxt;
reg rerr_r;
always@*
begin
  db_addr_match = (dbg_address[11:0] == DP_STATUS) |(dbg_address[11:0] == DP_CMD)|  
                  (dbg_address[11:0] == DP_ADDR_HI)|(dbg_address[11:0] == DP_DATA_HI)|
                  (dbg_address[11:0] == DP_ADDR)   |(dbg_address[11:0] == DP_DATA)|
                  (dbg_address[11:0] == DP_RESET)  | (dbg_address[11:0] == DP_SELECT)|
                  (dbg_address[11:0] == DB_CSR1)    | (dbg_address[11:0] == DB_CSR2)|(dbg_address[11:0] == DB_CSR3)|
                  (dbg_address[11:0] == DB_CSR4)| (dbg_address[11:0] == DB_CSR5);
  db_cmd_err     = dp_cmdval & (~(bvci_read | bvci_write));
  db_addr_err   = dp_cmdval & (~db_addr_match);
  db_be_err      = dp_cmdval & (~(&dbg_be));
  db_read_err  = (dbg_address[11:0] == DP_RESET) ? bvci_read : 1'b0;
  invalid_sel_err = (dbg_cmdval && select_wen && ((select_nxt[my_bits-1:0] > (`NUM_AP+1)) || ((select_nxt[(1 + my_bits -1):my_bits] == 4'h2) && (select_nxt[31:(1 + my_bits)] != 0)))) ? 1'b1 :1'b0;
  rerr_nxt      =   (  // invalid_sel_err
                           | db_addr_err
                           | db_cmd_err
                           | db_read_err
                           | db_be_err
                        ) |  (   rerr_r & (~dbg_rspack));
end

// spyglass disable_block Ac_unsync01
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck
  always @(posedge clk or posedge rst_a_s)
  begin : rerr_r_PROC
    if (rst_a_s == 1'b1)
    begin
      rerr_r <= 1'b0;
    end
    else
    begin
      rerr_r <= rerr_nxt;
    end
  end 
// spyglass enable_block Ac_unsync01
// spyglass enable_block Ar_resetcross01
///////////////////////////////////////////////////
	assign       bri_awid = (my_select == 3) ? i_bri_awid : {4{1'b0}};
	assign       bri_awaddr = (my_select == 3) ? i_bri_awaddr : {32{1'b0}};
	assign       bri_awlen = (my_select == 3) ? i_bri_awlen : {4{1'b0}};
	assign       bri_awsize = (my_select == 3) ? i_bri_awsize : {3{1'b0}};
	assign       bri_awburst = (my_select == 3) ? i_bri_awburst : {2{1'b0}};
//	assign       bri_awlock = (my_select == 3) ? i_bri_awlock : {2{1'b0}};
	assign       bri_awcache = (my_select == 3) ? i_bri_awcache :{4{1'b0}};
        assign       bri_awprot = (my_select == 3) ? i_bri_awprot : {3{1'b0}};
	assign       bri_awvalid = (my_select == 3) ? i_bri_awvalid : 1'b0;
	assign       bri_wid = (my_select == 3) ? i_bri_wid : {4{1'b0}};
	assign       bri_wdata = (my_select == 3) ? i_bri_wdata :{32{1'b0}};
	assign       bri_wstrb = (my_select == 3) ? i_bri_wstrb :{32/8{1'b0}};
	assign       bri_wlast = (my_select == 3) ? i_bri_wlast : 1'b0;
	assign       bri_wvalid=(my_select == 3) ? i_bri_wvalid : 1'b0;
	assign       bri_bready=(my_select == 3) ? i_bri_bready :1'b0;
	assign       bri_arid = (my_select == 3) ? i_bri_arid :{4{1'b0}};
	assign       bri_araddr = (my_select == 3) ? i_bri_araddr :{32{1'b0}};
	assign       bri_arlen = (my_select == 3) ? i_bri_arlen :{4{1'b0}};
	assign       bri_arsize = (my_select == 3) ? i_bri_arsize :{3{1'b0}};
	assign       bri_arburst = (my_select == 3) ? i_bri_arburst :{2{1'b0}};
//	assign       bri_arlock = (my_select == 3) ? i_bri_arlock:{2{1'b0}};
	assign       bri_arcache = (my_select == 3) ? i_bri_arcache :{4{1'b0}};
	assign       bri_arprot = (my_select == 3) ? i_bri_arprot:{3{1'b0}};
	assign       bri_arvalid= (my_select == 3) ? i_bri_arvalid :1'b0;
	assign       bri_rready= (my_select == 3) ? i_bri_rready:1'b0;
//	assign       bri_busy = (my_select == 3) ? i_bri_busy: 1'b0;



wire [31:0]               i_dbg_address;
wire [1:0]                i_dbg_cmd;
wire                      i_dbg_cmdval;
wire [31:0]               i_dbg_wdata;
wire [31:0]		  i_dbg_rdata;

  assign dp_identity ={ 4'h0,  //revision code 
			                  8'h0, //part number
			                  4'h0, //reserved
			                  4'h1, //version , ARC DPv1
			                  11'h258 ,// Designer, JEDEC Code of DP 
			                  1'h0 //reserved
			                  };

  assign dp_identity0 = { 32'h0}; //reserved
  assign dp_identity1 = { 25'h0, //reserved
			                    7'd32 //address size
			                    };
  assign dp_base_ptr0 = {20'h00001, //base address of dp rom table(4kb aligned)
		                      11'h0, //reserved
                     			1'h0 //valid bit
		                      };
  assign dp_base_ptr1 = 32'h0 ;

// spyglass disable_block Ac_conv01 Ac_conv02
// SMD: converge on combinational gate
// SJ:  Debug Programming model

wire [31:0] val_dbg_address;
assign val_dbg_address =  dp_cmdval ? dbg_address : 32'b0 ;   
// spyglass enable_block Ac_conv01 Ac_conv02

  always @*
  begin //{
    bvci_read   = dp_cmdval & (dbg_cmd == BVCI_CMD_RD);
    bvci_write  = dp_cmdval & (dbg_cmd == BVCI_CMD_WR);
    select_nxt  = select_in;
    dp_rdata    = dp_rdata_r;
    dp_data_nxt = dp_data;
    dp_addr_nxt = dp_addr;
    dp_cmd_nxt  = dp_cmd;
    if(rspval_nxt)
    begin //{
    if(bvci_read)
    begin //{
      case(val_dbg_address[11:0])
        DP_STATUS: //read-only
          dp_rdata = 32'h24;
        DP_CMD:
          dp_rdata = dp_cmd;
        DP_ADDR:
          dp_rdata = dp_addr;
        DP_DATA:
          dp_rdata = i_dp_data; 
        DP_ADDR_HI:
          dp_rdata = dp_addr;
        DP_DATA_HI:
          dp_rdata = i_dp_data; 
        //DP_RESET:
        DP_SELECT:
          dp_rdata  = select_in;
        DB_CSR1: //read-only
          dp_rdata = (my_select == 1) ? 32'h10 : dp_identity;
        DB_CSR2: //read-only
          dp_rdata = (my_select == 1) ? 32'h0 : dp_identity0;
        DB_CSR3: //read-only
          dp_rdata = (my_select == 1) ? 32'h0 :  dp_identity1;
        DB_CSR4: //read-only
          dp_rdata = (my_select == 1) ? 32'h0 :  dp_base_ptr0;
        DB_CSR5: //read-only
          dp_rdata = (my_select == 1) ? 32'h0 :  dp_base_ptr1;

        default: dp_rdata = 32'b0;
      endcase
    end //}
    end //}
    else
    begin //{
        dp_rdata = dp_rdata_r;
    end //}

    if(bvci_write)
    begin //{
      if((dbg_address[11:0] == DP_CMD) && dp_cmd[2])	
		    dp_data_nxt = i_dp_data;
      if(dbg_address[11:0] == DP_ADDR)	
		    dp_addr_nxt = dbg_wdata;
      if(dbg_address[11:0] == DP_DATA)
		    dp_data_nxt = dbg_wdata;
      if(dbg_address[11:0] == DP_CMD)
		    dp_cmd_nxt = dbg_wdata;
      if(dbg_address[11:0] == DP_SELECT)
		    select_nxt = dbg_wdata;
    end //}


  end //}

assign select_wen = (bvci_write && dbg_address[11:0] == DP_SELECT);
assign dp_addr_wen = (bvci_write && dbg_address[11:0] == DP_ADDR);
assign dp_data_wen = ((dbg_address[11:0] == DP_DATA) || (dbg_address[11:0] == DP_CMD));
assign dp_cmd_wen = (bvci_write && dbg_address[11:0] == DP_CMD);

//always @*
//begin : dp_rom_space_sel_PROC
//	if(dp_addr[31:12] == `DP_ROM_SPACE)
//	begin
//		rom_sel_nxt = 1;
//	end
//	else if ((rom_sel_nxt ==1) && (dbg_address[11:0] == DP_STATUS))
//	begin
//		rom_sel_nxt = 0;
//	end
//	
//end



  assign i_dp_data = (my_select == 1) ? rom_rdata : dp_data;
  assign dp_cmdack = dp_cmdval& reset_done_r; 
  assign dp_reop = rspval_r;
  assign dp_rspval = rspval_r;
  assign dp_rerr = rerr_r;
  

always@*
begin: rom_table_PROC
  rom_rdata = 32'b0;
  if (my_select == 1) //(rom_sel)
  begin
    casez(dp_addr[11:0])//(dbg_address[11:0])
    12'd0: 
    begin
      rom_rdata = {20'h0000_2, //10000, // [31:12] entry offset
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
      rom_rdata = {20'h0000_3, //10000, // [31:12] entry offset
                  3'b0, // [11:9] reserv
                  5'd0, // [8:4] pwrid
                  1'b0, // [3] reserv
                  1'b0, // [2] pwrvld
                  1'b1, // [1] 32-bit format
                  1'b1  // [0] present 
                  };
    end

    12'd8: 
    begin
      rom_rdata = {20'h0000_0, //20000, // [31:12] entry offset
                  3'b0, // [11:9] reserv
                  5'd0, // [8:4] pwrid
                  1'b0, // [3] reserv
                  1'b0, // [2] pwrvld
                  1'b0, // [1] 32-bit format
                  1'b0  // [0] present 
                  };
    end
    12'h400: rom_rdata = {24'h0,8'h10}; // [7:4] Component class (0x1 Rom Table) [3:0] Preamble 1 (0x0)
    12'hFCC: rom_rdata = 32'b0; // memory_type
    12'hFD0: rom_rdata = {24'h0,8'h04}; // PIDR4 // [7:4] size // [3:0] DES_2
    12'hFD4: rom_rdata = {24'h0,8'h00}; // PIDR5 // reserv
    12'hFD8: rom_rdata = {24'h0,8'h00}; // PIDR6 // reserv
    12'hFDC: rom_rdata = {24'h0,8'h00}; // PIDR7 // reserv
    12'hFE0: rom_rdata = {24'h0,8'h01}; // PIDR0 // [7:0] Part number bits
    12'hFE4: rom_rdata = {24'h0,8'h80}; // PIDR1 // [7:4] JEP106 identification code bits[3:0] // [3:0] Part number bits[11:8]
    12'hFE8: rom_rdata = {24'h0,8'h0D}; // PIDR2 // [7:4] Revision // [3] JEDEC // [2:0] JEP106 identification code[6:4]
    12'hFEC: rom_rdata = {24'h0,8'h00}; // PIDR3 // [7:4] RevAnd // [3:0] Customer Modified
    12'hFF0: rom_rdata = {24'h0,8'h0D}; // CIDR0 // [7:0] Preamble 0 (0x0D)
    12'hFF4: rom_rdata = {24'h0,8'h10}; // CIDR1 // [7:4] Component class (0x1 Rom Table) [3:0] Preamble 1 (0x0)
    12'hFF8: rom_rdata = {24'h0,8'h05}; // CIDR2 // [7:0] Preamble 2 (0x05)
    12'hFFC: rom_rdata = {24'h0,8'hB1}; // CIDR3 // [7:0] Preamble 3 (0xB1)
    default: rom_rdata = 32'b0;                      
    endcase
  end
end // rom_table_PROC
//////////////////////////////////////////////////////////////////////////////
//wire ra_select=2'b1;
//reg sel_tran;
//wire i_sel_tran;
//assign i_sel_tran = ((rspval_r == 0) & (rspval_del == 1));
//always@*
//begin
//  if(dbg_cmdval && (dbg_address[11:0] == DP_SELECT)) sel_tran = 1;
//  else if ((sel_tran==1)&&(i_sel_tran)) sel_tran = 0;
//  else sel_tran = 0;
//end

//assign dbg_cmdack = (dbg_address[11:0] == DP_SELECT) ? dp_cmdack :( 
assign dbg_cmdack = (dbg_cmdval && ((dbg_address[11:0] == DP_SELECT) && (~dbg_daddrval))) ? dp_cmdack :  
        (my_select == (0+2)) ? ap0_dbg_cmdack :
        (my_select == (1+2)) ? ap1_dbg_cmdack :
         dp_cmdack;
assign dbg_rdata = (sel_rw) ? dp_rdata_r : (
        (my_select == (0+2)) ? ap0_dbg_rdata :
        (my_select == (1+2)) ? ap1_dbg_rdata :
 	dp_rdata_r);

assign dbg_reop = (sel_rw) ? dp_reop :(  
        (my_select == (0+2)) ? ap0_dbg_reop:
        (my_select == (1+2)) ? ap1_dbg_reop:
 	dp_reop);
assign dbg_rspval = (sel_rw) ? dp_rspval :( 
        (my_select == (0+2)) ? ap0_dbg_rspval :
        (my_select == (1+2)) ? ap1_dbg_rspval :
	dp_rspval);
assign dbg_rerr = ((select_nxt[my_bits-1:0] > (`NUM_AP+1)) || ((select_nxt[(1 + my_bits -1):my_bits] == 4'h2) && (select_nxt[31:(1 + my_bits)] != 0))) ? 1'b1 : ((sel_rw) ? dp_rerr :(  
        (my_select == 1)  ? 1'b0:
        (my_select == (0+2)) ? ap0_dbg_rerr :
        (my_select == (1+2)) ? ap1_dbg_rerr :
 	dp_rerr));

//`for (2 = 0;	2 < `APB_SLAVES; 2++)//{
	wire pseldbg_i; 
//`endfor //}
	//wire inv_clk; //for_jtag
////for outputs/////
//reg penabledbg;
//reg [31:2]paddrdbg;
//reg pwritedbg;
//reg [31:0]pwdatadbg;

reg [31:2] i_paddrdbg;

////////////////////////////////////

/////
reg preadydbg_mst;


wire  jtag_tck_s_clk;
reg jtag_tck_s_clk_r1;
wire tckRiseEn;

////////////////////////////////////
// leda NTL_CLK07 off
// spyglass disable_block Clock_converge01
// SMD: clock domain convergence
// SJ:  Inverted clock used in functional mode. Mux controlled during test mode.
// Invert jtag_tck for negative edge triggered DFF's 
//
// SMD: clock domain convergence
// SJ:  Inverted clock used in functional mode. Mux controlled during test mode.
//
  wire jtag_tck_inv =  (test_mode ? jtag_tck : ~jtag_tck);
//
// leda NTL_CLK07 on
// spyglass enable_block Clock_converge01
  

// spyglass disable_block Clock_check10 Ac_coherency06 Clock_check10
// spyglass disable_block STARC05-1.4.3.4
// SMD: Clock signal is reaching data input of flop
// SJ:  return clock (rtck) is spec'd to be sync'd to core clk
// SMD: Source primary input "archipelago.jtag_tck" is synchronized twice
// SJ:  each hs core (domain 'clk') has its own synchronizer
dw_dbp_cdc_sync #(.SYNC_FF_LEVELS(`DBP_SYNC_FF_LEVELS)
              ) u_cdc_sync (
                                   .clk   (clk),
                                   .rst_a (rst_a_s), 
                                   .din   (jtag_tck),
                                   .dout  (jtag_tck_s_clk)
                                  );   
assign jtag_rtck = jtag_tck_s_clk;

// spyglass enable_block Clock_check10 Ac_coherency06 Clock_check10
// spyglass enable_block STARC05-1.4.3.4

  always @(posedge clk or posedge rst_a_s)
  begin : jtag_tck_s_clk_delay
    if (rst_a_s == 1'b1)
      begin
        jtag_tck_s_clk_r1<= 1'b0;
      end
    else
      begin
        jtag_tck_s_clk_r1<= jtag_tck_s_clk;
      end
  end
assign tckRiseEn = jtag_tck_s_clk && !jtag_tck_s_clk_r1;



wire                        jtag_trst_n_s;


// This process synchronizes the removal of the JTAG reset. It might go
// metastable because the external reset can be removed in any relationship to
// the clock, so it's resynchronized here.
// spyglass disable_block Reset_sync04 STARC05-1.3.1.3
// SMD: asynchronous reset signal is synchronized at least twice
// SJ:  needs to be synchronized
// SMD: Asynchronous reset/preset signal must be used as non-reset/preset or synchronous reset/preset signal
// SJ:  done on purpose
dwt_reset_ctrl #(.POS_ACTIVE_RST (0))
  u_dwt_jtag_reset_ctrl (
  .clk                (jtag_tck       ),
  .rst_a              (jtag_trst_n    ),
  .test_mode          (test_mode      ),
  .rst                (jtag_trst_n_s  )
                                  );   
// spyglass enable_block Reset_sync04 STARC05-1.3.1.3

always @*
begin //{
dbg_address = int_dbg_address;
dbg_be      = int_dbg_be;
dbg_cmd     = int_dbg_cmd;
dbg_cmdval  = int_dbg_cmdval;
dbg_daddrval  = int_dbg_daddrval;
dbg_eop     = int_dbg_eop;
dbg_rspack  = int_dbg_rspack;
dbg_wdata   = int_dbg_wdata;
end //}

reg [31:0] dbg_rdata_r1;
reg        dbg_rspval_r1;
reg        dbg_reop_r1;

// spyglass disable_block Ar_resetcross01
// SMD: Unsynchronized reset crossing detected
// SJ:  reconfigurable code
// spyglass disable_block Ac_unsync01
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck
// spyglass disable_block Ac_unsync02
// SMD: Unsynchronized Crossing
// SJ:  Debug Programming model ensures dbg_cmdval synchronization with jtag_tck
  always @(posedge clk or posedge rst_a_s)
  begin : db_rspval_PROC
    if (rst_a_s == 1'b1)
      begin
      dbg_rdata_r1  <= 32'b0;
      dbg_rspval_r1 <= 1'b0;
      dbg_reop_r1   <= 1'b0;
      end
    else
      begin
      dbg_rspval_r1 <= dbg_rspval;
      dbg_reop_r1 <= dbg_reop;
      if (dbg_rspval) begin
        dbg_rdata_r1  <= dbg_rdata;
        end
      end
  end
// spyglass enable_block Ac_unsync02 
// spyglass enable_block Ac_unsync01 
// spyglass enable_block Ar_resetcross01

assign int_dbg_rdata  = dbg_rdata_r1;
assign int_dbg_reop   = dbg_reop_r1;
assign int_dbg_rspval = dbg_rspval_r1;
assign int_dbg_rerr   = dbg_rerr;

assign rv_dmihardresetn = ~rst_a;

  dwt_jtag_port u_jtag_port (
    .clk (clk),
    .jtag_tck (jtag_tck),
    .jtag_tck_inv (jtag_tck_inv),
    .jtag_trst_n (jtag_trst_n_s),
    .tckRiseEn(tckRiseEn),
    .rst_a (rst_a_s),
    .jtag_tdi (jtag_tdi),
    .jtag_tms (jtag_tms),
    .jtag_tdo (jtag_tdo),
    .jtag_tdo_zen_n (jtag_tdo_oe),
    .dbg_address (int_dbg_address),
    .dbg_be (int_dbg_be),
    .dbg_cmd (int_dbg_cmd),
    .dbg_cmdval(int_dbg_cmdval),
    .dbg_daddrval(int_dbg_daddrval),
    .dbg_eop (int_dbg_eop),
    .dbg_rspack (int_dbg_rspack),
    .dbg_wdata(int_dbg_wdata),
    .dbg_rdata (int_dbg_rdata),
    .dbg_reop (int_dbg_reop),
    .dbg_rspval (int_dbg_rspval),
    .dbg_rerr (int_dbg_rerr)//,
    //.dp_sel_r (dp_sel_r1)
  );
wire [31:2]            paddrdbg0_r;
wire                   pseldbg0_r;
wire                   penabledbg0_r;
wire                   pwritedbg0_r;
wire [31:0]            pwdatadbg0_r;

wire                   i_preadydbg0;
wire [31:0]            i_prdatadbg0;
wire                   i_pslverrdbg0;



wire [2-1:0]apb_select;
assign apb_select = next_select[2-1:0];

always@*
begin //{
	if(apb_select==2'h2)
	begin //{ 
		apb_paddrdbg    = paddrdbg0_r[31:2];
		apb_pseldbg     = pseldbg0_r;
		apb_penabledbg  = penabledbg0_r;
		apb_pwritedbg   = pwritedbg0_r;
		apb_pwdatadbg   = pwdatadbg0_r;	
	end //}
	else
	begin //{
		apb_paddrdbg    = 30'b0; 
		apb_pseldbg     = 1'b0;
		apb_penabledbg  = 1'b0;
		apb_pwritedbg   = 1'b0;
		apb_pwdatadbg   = 32'b0;
	end //}
end //}







assign i_preadydbg0 = 
		     apb_preadydbg;
assign i_prdatadbg0 = 
		      apb_prdatadbg;
assign i_pslverrdbg0 = 
		     apb_pslverrdbg ;

//////////////////////////////////

assign ap0_dbg_address = dbg_address[31:2];
assign ap0_dbg_be = dbg_be;
assign ap0_dbg_cmd = dbg_cmd;

//spyglass disable_block Ac_conv02 
assign ap0_dbg_cmdval = (dbg_cmdval && ((dbg_address[11:0] == DP_SELECT) && (~dbg_daddrval))) ? 1'b0 : ((my_select == (0+2)) ? (dbg_cmdval && |dbg_cmd) : 1'b0);
//spyglass enable_block Ac_conv02

assign ap0_dbg_rspack = dbg_rspack;
assign ap0_dbg_wdata = dbg_wdata;

  apb_master_ap0 u0_apb_master (
    .select_in(next_select),
    .clk(clk), //
    .rst_a(rst_a_s), //
    

    .dbg_address(ap0_dbg_address),
    .dbg_be(ap0_dbg_be),
    .dbg_cmd(ap0_dbg_cmd),
    .dbg_cmdval (ap0_dbg_cmdval),
    .dbg_rspack(ap0_dbg_rspack), 
    .dbg_wdata(ap0_dbg_wdata),
    
    .dbg_cmdack(ap0_dbg_cmdack), 
    .dbg_rdata(ap0_dbg_rdata),
    .dbg_rspval(ap0_dbg_rspval), //
    .dbg_reop(ap0_dbg_reop),  //
    .dbg_rerr(ap0_dbg_rerr), //

    .preadydbg (i_preadydbg0), //(preadydbg),
    .prdatadbg (i_prdatadbg0), //(prdatadbg),
    .pslverrdbg(i_pslverrdbg0), //
    .pseldbg (pseldbg0_r), //(pseldbg),
    .penabledbg (penabledbg0_r), //(penabledbg),
    .paddrdbg (paddrdbg0_r), //(i_paddrdbg),
    .pwritedbg (pwritedbg0_r),//(pwritedbg),
    .pwdatadbg (pwdatadbg0_r) //(pwdatadbg)
  );

/////////////////////////////////////////////////////////////
//adding APB Async bridge btw apb_ap and destination apb clk domain (cln/trace)
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////


//`for(1=0;1<`NUM_AXI_AP;1++) //{

assign ap1_dbg_address = dbg_address;
assign ap1_dbg_be = dbg_be;
assign ap1_dbg_eop = dbg_eop;
assign ap1_dbg_cmd = dbg_cmd;
assign ap1_dbg_cmdval = (dbg_cmdval && (((dbg_address[11:0] == DP_SELECT) && (~dbg_daddrval)) && (~dbg_daddrval))) ? 1'b0 : ((my_select == (1+2)) ? (dbg_cmdval && |dbg_cmd) : 1'b0);
assign ap1_dbg_rspack = dbg_rspack;
assign ap1_dbg_wdata = dbg_wdata;

  bvci_to_axi u1_bvci_to_axi (
    .select_in(next_select),
    .clk (clk),
    .rst_a(rst_a_s),
    .sync (1'b1),
    .t_address(ap1_dbg_address),
    .t_be(ap1_dbg_be),
    .t_cmd(ap1_dbg_cmd),
    .t_eop(ap1_dbg_eop),
    .t_plen(9'b100),
    .t_wdata(ap1_dbg_wdata),
    .t_cmdval(ap1_dbg_cmdval),
    .bri_awready(bri_awready),
    .bri_wready( bri_wready),
    .bri_bid( bri_bid),
    .bri_bresp( bri_bresp),
    .bri_bvalid( bri_bvalid),
    .bri_arready( bri_arready),
    .bri_rid( bri_rid),
    .bri_rdata( bri_rdata),
    .bri_rlast( bri_rlast),
    .bri_rvalid( bri_rvalid),
    .bri_rresp( bri_rresp),
    .t_cmdack(ap1_dbg_cmdack),
    .t_rdata(ap1_dbg_rdata),
    .t_reop(ap1_dbg_reop),
    .t_rspval(ap1_dbg_rspval),
    .t_rerror(ap1_dbg_rerr),
    .bri_awid( i_bri_awid),
    .bri_awaddr( i_bri_awaddr),
    .bri_awlen( i_bri_awlen),
    .bri_awsize( i_bri_awsize),
    .bri_awburst( i_bri_awburst),
    .bri_awlock( i_bri_awlock),
    .bri_awcache( i_bri_awcache),
    .bri_awprot( i_bri_awprot),
    .bri_awvalid( i_bri_awvalid),
    .bri_wid( i_bri_wid),
    .bri_wdata( i_bri_wdata),
    .bri_wstrb( i_bri_wstrb),
    .bri_wlast( i_bri_wlast),
    .bri_wvalid( i_bri_wvalid),
    .bri_bready( i_bri_bready),
    .bri_arid( i_bri_arid),
    .bri_araddr( i_bri_araddr),
    .bri_arlen( i_bri_arlen),
    .bri_arsize( i_bri_arsize),
    .bri_arburst( i_bri_arburst),
    .bri_arlock( i_bri_arlock),
    .bri_arcache( i_bri_arcache),
    .bri_arprot( i_bri_arprot),
    .bri_arvalid( i_bri_arvalid),
    .bri_rready( i_bri_rready),
    .bri_busy(i_bri_busy)
  );
//`endfor //}


//below signals may not be needed, test with removing
  //	assign dbg_prot_sel=1'b1;
//assign apb_dbgen = 1'b1;
//assign apb_niden = 1'b1;
////////////////////
endmodule
