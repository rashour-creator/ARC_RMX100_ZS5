// Copyright (C) 2012-2013 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
//----------------------------------------------------------------------------
//
//   dm mst access GPRs
//
// Description:        a mem from 0x1000-0x101f
//

//
// =========================================================================== 
//
//
`include "arcv_dm_defines.v"   ///////
// Set simulation timescale
//
`include "const.def"
module dm_hmst #(  
  parameter         HMIBP_ADDR_W     = 64,//TBD       
  parameter         HMIBP_DATA_W     = 64,//TBD       
  parameter         HMIBP_READ_BE    = 1   //TBD       
)(
  input                     dm_clk,       // Clock
  input                     rst_a,
  input                     dmactive_i,  // synchronous reset active low
                       
//hmsta from dm IF
  input   [HMIBP_ADDR_W-1:0]  hmstaddress_i,                  //addr ->cmd ch
  // control signals in write read addr
  // data in
  input   [HMIBP_DATA_W-1:0]  hmstdata_i,                     //rdat from ibp    <- iBP to dm
  input                     hmstdata_read_fire,          //read  data trig point   @dmread   to ABS
  input                     hmstdata_write_fire,         //write data trig point   @dmwrite  to ABS
//to ABC IF------------------------------------------------------------
  // excute
  output  reg               hmst_busy,
  // read data to dm
  output  [HMIBP_DATA_W-1:0]  hmstdata_o,                     //r dat to dm      <-
  // to abc because mst or slv err
  output                    hmsterr_o,
  output                    hmstaddr_err_o,
  input   [7:0]             cmdtype_i,
  input   [2:0]             aarsize_i,
//IBP IF------------------------------------------------------------
// cmd, r ch, w ch
//1 cmd
  output                    cmd_valid_o,
  input reg                 cmd_accept_i,
  output                    cmd_read_o,
  output  [HMIBP_ADDR_W-1:0]cmd_addr_o,
  output  [3:0]             cmd_space_o,

//2 r data ch
  input                     rd_valid_i,        //from ibp
  output  reg               rd_accept_o,       //to ibp
  input   [HMIBP_DATA_W-1:0]rd_data_i,
  input                     rd_err_i,

//3 w data ch
  output                    wr_valid_o,
  input                     wr_accept_i,
  output  [HMIBP_DATA_W-1:0]wr_data_o,
  output  [HMIBP_DATA_W/8-1:0]  wr_mask_o,
//4 w resp ch
  input                     wr_done_i,
  input                     wr_err_i,
  output                    wr_resp_accept_o
  );
//loc para
localparam DM_HMST_IDLE   = 3'b000;   //               0 know W or R
localparam DM_HMST_RE_REQ = 3'b010;   //R !last        2 send read  Addr
localparam DM_HMST_RE_ACK = 3'b011;   //                3 wait Rlast
localparam DM_HMST_W_REQ  = 3'b100;   //send W        4 send Write Addr
localparam DM_HMST_W_ACK  = 3'b101;   //wait last           5 send last
localparam DM_HMST_WR_REQ = 3'b111;   //w resp accept  6 send accept to IBP

  wire [1:0]          hmst_burst;           //[1]burst [0]w

reg  [2:0]              state_q;
reg  [2:0]              state_n;   
reg                     cmd_valid_n;

wire                    wr_err_mask;
reg                     cmd_read;
reg [HMIBP_ADDR_W-1:0] cmd_addr_n;
wire[HMIBP_ADDR_W-1:0]  hmstaddress_zscaled;                  //addr -> zero scaled  
reg [3:0]              cmd_space_n;
reg [HMIBP_DATA_W-1:0] wr_data_n;
reg                    wr_resp_accept_n;
reg [HMIBP_DATA_W-1:0] hmstdata_n;
reg                    wr_valid_n;
reg                    rd_accept_n;
wire [HMIBP_DATA_W-1:0] rd_data_mask;
wire [HMIBP_DATA_W/8-1:0] be_idx_masked;  
//reg/mem data msg                     //group    cond       cmd_space
  wire                    abc_reg;     //reg    cmdtyp=0         1-4
  wire                    abc_mem;     //mem    cmdtyp=2         0
  wire                    abc_csr;     //csr    r_no=4'h0        1
  wire                    abc_gpr;     //gpr        =11'h080     2
  wire                    abc_fpr;     //fpr        =11'h081     3
  wire                    abc_nsint;   //nsint      =2'h3        4
  wire                    abc_icsr8;   //icsr   cmdtyp=8         5
  wire                    abc_icsr9;   //icsr   cmdtyp=9         5
  wire                    abc_value5;   //icsr   cmdtyp=9         5
  wire                    abc_aux;     //aux    cmdtyp=15        F  
  wire [6:0]              cmd_space_sel;
// IBP SM            
  always_ff @(posedge dm_clk or posedge rst_a) begin : sm_reg_PROC
    if (rst_a) begin
      state_q <= DM_HMST_IDLE;
    end else begin
      state_q <= state_n & {3{dmactive_i}};
    end
  end // sm_reg_PROC   

  always_comb begin : HMST_SM_PROC   // to hmsta IBP bus
    hmst_busy   = 1'b0;
    cmd_valid_n = 1'b0;
    cmd_read    = 1'b1;
    hmstdata_n  = {HMIBP_DATA_W{1'b0}};    //to dm_hmsta
    wr_data_n   = {HMIBP_DATA_W{1'b0}};    //hmsta to ibp 
    wr_valid_n  = 1'b0; //w
    rd_accept_n = 1'b0; //w
//ctrl signal
//1  cmd resp ch
    cmd_addr_n = {HMIBP_ADDR_W{1'b0}}; //from hmsta
//4  w resp ch
    wr_resp_accept_n  = 1'b0;
    state_n = state_q;     
    unique case (state_q)     
       DM_HMST_IDLE   : begin  //               0 W or R or burst LSB32  
                           // data trig Write SM
                           if (hmstdata_write_fire | (hmst_burst==2'b11))  begin 
                               state_n = DM_HMST_W_REQ;
                               hmst_busy = 1'b1; 
                           end    
                           // read data trig read from IBP to hmstdata
                           if (hmstdata_read_fire  | (hmst_burst==2'b10)) begin
                               state_n = DM_HMST_RE_REQ;
                               hmst_busy = 1'b1; 
                           end    
                        end

       DM_HMST_RE_REQ : begin  //R !last        2 send read  Addr
                         hmst_busy = 1'b1; 
                         cmd_valid_n = 1'b1;
                         cmd_addr_n =  hmstaddress_zscaled; 
                //       cmd_read = 1'b1; //r
                         if (cmd_accept_i && rd_valid_i)
                         begin  //same cyc
                             state_n     = DM_HMST_IDLE;//back at same cycle.
                             hmst_busy   = 1'b0; 
                             rd_accept_n = 1'b1; //ready to accept
                             hmstdata_n  = rd_data_i & rd_data_mask;     //rec cmd ack
                         end
                         else if (cmd_accept_i ) begin            
                               state_n      = DM_HMST_RE_ACK;  //rec cmd ack
                         end      
                        end

       DM_HMST_RE_ACK : begin  //last           3 wait Rlast 
                           hmst_busy    = 1'b1; 
                           if (rd_valid_i)begin    //TBD to know if  always last
                               state_n = DM_HMST_IDLE;     //rec last data
                               rd_accept_n  = 1'b1; 
                               hmst_busy    = 1'b0; 
                               hmstdata_n   = rd_data_i & rd_data_mask;     //ibp to hmsta
                           end
                        end

       DM_HMST_W_REQ  : begin  //W cmd accept        4 send Write Addr
                         hmst_busy = 1'b1; 
                         cmd_valid_n = 1'b1;
                         cmd_addr_n = hmstaddress_zscaled; //from hmsta
                         wr_data_n= hmstdata_i[31:0]; //hmsta to ibp
                         cmd_read = 1'b0; //w
                         wr_valid_n = 1'b1; //w
                         if (cmd_accept_i) begin
                             if(wr_accept_i)begin
                                if(wr_done_i)begin
                                 state_n = DM_HMST_IDLE;     //rec wr channel
                                 hmst_busy = 1'b0; 
                                 wr_resp_accept_n = 1'b1;       
                                end 
                                else begin
                                    state_n = DM_HMST_WR_REQ;     //rec w channel
                                    wr_resp_accept_n = 1'b1;        
                                end    
                             end    
                             else begin
                                 state_n = DM_HMST_W_ACK;     //rec w channel
                             end    
                         end    
                        end

       DM_HMST_W_ACK  : begin  //last           5 send last 
                          hmst_busy = 1'b1; 
                          cmd_read = 1'b0; //w
                          wr_valid_n = 1'b1; //w
                          wr_data_n= hmstdata_i[31:0]; //hmsta to ibp
                          if (!wr_done_i&wr_accept_i) begin   // by spec rise at same cyc
                              state_n = DM_HMST_WR_REQ;     //rec done
                              wr_resp_accept_n = 1'b1;       
                          end
                          if (wr_accept_i & wr_done_i) begin  //resp done rise at same cyc
                              state_n = DM_HMST_IDLE;     //rec last data
                              hmst_busy = 1'b0; 
                              wr_resp_accept_n = 1'b1;       
                          end    
                        end

       DM_HMST_WR_REQ : begin  //rec resp  7 
                          hmst_busy = 1'b1; 
                          cmd_read = 1'b0; //w
                          wr_resp_accept_n = 1'b1;
                          if (wr_done_i) begin             // by spec rise at same cyc
                             state_n = DM_HMST_IDLE;     //rec done
                             hmst_busy = 1'b0; 
                          //   wr_resp_accept_n = 1'b1;
                          end    
                        end
              default :  state_n = DM_HMST_IDLE; // catch parasitic state
    endcase  
  end // HMST_SM_PROC

// to 0.DM 1.cmd 2.r ch 3.w ch 4.w resp
//0 
  // read data out to dm
  assign      hmstdata_o       = hmstdata_n;  //from IBP                   //w dat to dm      <-
  // control signals to dm
//1  
  assign      cmd_valid_o      = cmd_valid_n ;
  assign      cmd_read_o       = cmd_read;
  assign      cmd_addr_o       = cmd_addr_n;             
  assign      cmd_space_o      = (aarsize_i == 3'b11) ? (cmd_read ? (hmst_burst[1] ? cmd_space_n : 4'd4) :
                                                                    (hmst_burst[1] ? 4'd4 : cmd_space_n)) : cmd_space_n;             
//2 r ch
  assign      rd_accept_o      = rd_accept_n;               
//3 w ch
  assign      wr_valid_o       = wr_valid_n;             
  assign      wr_data_o        = wr_data_n;             
  assign      wr_mask_o        = be_idx_masked;             
//4      
  assign      wr_resp_accept_o = wr_resp_accept_n;                

assign be_idx_masked =(aarsize_i==3'b11)?  {4{wr_valid_n}}:
                      (aarsize_i==3'b10)?  {4{wr_valid_n}}:
                      (aarsize_i==3'b01)?  {2'b0, {2{wr_valid_n}}}:{3'b0, {1{wr_valid_n}}} ;
                      
assign rd_data_mask = (aarsize_i==3'b11)? {HMIBP_DATA_W{1'b1}} :
                      (aarsize_i==3'b10)? {          32{1'b1}} :
                      (aarsize_i==3'b01)? {16'b0,  {16{1'b1}}} : {24'b0,{8{1'b1}}};

assign hmsterr_o =  wr_err_i | rd_err_i;   
assign hmstaddr_err_o = (cmd_space_n ==4'he) ;  

assign abc_mem   = ( cmdtype_i == 8'd2 );              

assign abc_reg   = ( cmdtype_i == 8'd0 );   

assign abc_csr   = abc_reg & (hmstaddress_i[15:12] == 4'h0 );              
assign abc_gpr   = abc_reg & (hmstaddress_i[15:5]  == 11'h080 );              
assign abc_fpr   = abc_reg & (hmstaddress_i[15:5]  == 11'h081 );              
assign abc_nsint = abc_reg & (hmstaddress_i[15:14] == 2'h3  );              
assign hmstaddress_zscaled =  abc_csr           ? {{(HMIBP_ADDR_W-16){1'b0}},  4'b0, hmstaddress_i[11:0]} :
                             (abc_gpr||abc_fpr) ? {{(HMIBP_ADDR_W-16){1'b0}}, 11'b0, hmstaddress_i[4:0] } :
                              abc_nsint         ? {{(HMIBP_ADDR_W-16){1'b0}},  2'b0, hmstaddress_i[13:0]} : hmstaddress_i;

assign abc_icsr8 = ( cmdtype_i == 8'd8 );              
assign abc_icsr9 = ( cmdtype_i == 8'd9 );              
assign abc_value5 = abc_icsr8 | abc_icsr9;              
assign abc_aux   = ( cmdtype_i == 8'hF );              
assign cmd_space_sel = {abc_aux, abc_value5, abc_nsint, abc_fpr, abc_gpr, abc_csr, abc_mem};

always_comb 
  begin : p_abc_cmd_space_n_PROC
      // this abstract command is currently supported
      case (cmd_space_sel)  
    7'b001_0000: cmd_space_n = 4'h4; //Access Register Command
    7'b000_1000: cmd_space_n = 4'h3; //Access Register Command
    7'b000_0100: cmd_space_n = 4'h2; //Access Register Command
    7'b000_0010: cmd_space_n = 4'h1; //Access Register Command
    7'b000_0001: cmd_space_n = 4'h0; //Access Register Command
        default: cmd_space_n = 4'he ;  //TBD
      endcase 
  end   // p_abc_cmd_space_n_PROC   
assign hmst_burst  = 2'b0;

endmodule
