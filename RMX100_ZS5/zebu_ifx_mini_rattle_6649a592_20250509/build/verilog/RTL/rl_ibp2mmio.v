// Library ARCv5EM-3.5.999999999
//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Description:
// @p
//  
//  
// @e
//
//  
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions 
//
`include "defines.v"
`include "ifu_defines.v"
`include "dmp_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_ibp2mmio (

  /////////////////// LSQ Memory-maped CSR IBP target interface /////////////////////
  // 
  input                          lsq_ibp_cmd_valid, 
  input  [3:0]                   lsq_ibp_cmd_cache, 
  input                          lsq_ibp_cmd_burst_size,                 
  input                          lsq_ibp_cmd_read,                
  input                          lsq_ibp_cmd_aux,                
  output reg                     lsq_ibp_cmd_accept,              
  input  [`ADDR_RANGE]           lsq_ibp_cmd_addr,                             
  input                          lsq_ibp_cmd_excl,
  input  [5:0]                   lsq_ibp_cmd_atomic,
  input  [2:0]                   lsq_ibp_cmd_data_size,                
  input  [1:0]                   lsq_ibp_cmd_prot,                

  input                          lsq_ibp_wr_valid,    
  input                          lsq_ibp_wr_last,    
  output reg                     lsq_ibp_wr_accept,   
  input  [3:0]                   lsq_ibp_wr_mask,    
  input  [`DATA_RANGE]           lsq_ibp_wr_data,    
  
  output reg                     lsq_ibp_rd_valid,                
  output reg                     lsq_ibp_rd_err,                
  output reg                     lsq_ibp_rd_excl_ok,
  output reg                     lsq_ibp_rd_last,                 
  input                          lsq_ibp_rd_accept,               
  output reg [`DATA_RANGE]       lsq_ibp_rd_data,     
  
  output reg                     lsq_ibp_wr_done,
  output reg                     lsq_ibp_wr_excl_okay,
  output reg                     lsq_ibp_wr_err,
  input                          lsq_ibp_wr_resp_accept,

  /////////////////// External Memory-maped CSR IBP target interface /////////////////////
  // 
  input                          dmi_ibp_cmd_prio,

  input                          dmi_ibp_cmd_valid, 
  input  [3:0]                   dmi_ibp_cmd_cache, 
  input                          dmi_ibp_cmd_burst_size,                 
  input                          dmi_ibp_cmd_read,                
  input                          dmi_ibp_cmd_aux,                
  output reg                     dmi_ibp_cmd_accept,              
  input  [`ADDR_RANGE]           dmi_ibp_cmd_addr,                             
  input                          dmi_ibp_cmd_excl,
  input  [5:0]                   dmi_ibp_cmd_atomic,
  input  [2:0]                   dmi_ibp_cmd_data_size,                
  input  [1:0]                   dmi_ibp_cmd_prot,                

  input                          dmi_ibp_wr_valid,    
  input                          dmi_ibp_wr_last,    
  output reg                     dmi_ibp_wr_accept,   
  input  [3:0]                   dmi_ibp_wr_mask,    
  input  [`DATA_RANGE]           dmi_ibp_wr_data,    
  
  output reg                     dmi_ibp_rd_valid,                
  output reg                     dmi_ibp_rd_err,                
  output reg                     dmi_ibp_rd_excl_ok,
  output reg                     dmi_ibp_rd_last,                 
  input                          dmi_ibp_rd_accept,               
  output reg [`DATA_RANGE]       dmi_ibp_rd_data,     
  
  output reg                     dmi_ibp_wr_done,
  output reg                     dmi_ibp_wr_excl_okay,
  output reg                     dmi_ibp_wr_err,
  input                          dmi_ibp_wr_resp_accept,

  /////////////////// Distributed Memory-maped CSR IBP initiator interface //////////////
  // 
  output reg                     mmio0_cmd_valid, 
  output reg [3:0]               mmio0_cmd_cache, 
  output reg                     mmio0_cmd_burst_size,                 
  output reg                     mmio0_cmd_read,                
  output reg                     mmio0_cmd_aux,                
  input                          mmio0_cmd_accept,              
  output reg [`ADDR_RANGE]       mmio0_cmd_addr,                             
  output reg                     mmio0_cmd_excl,
  output reg [5:0]               mmio0_cmd_atomic,
  output reg [2:0]               mmio0_cmd_data_size,                
  output reg [1:0]               mmio0_cmd_prot,                

  output reg                     mmio0_wr_valid,    
  output reg                     mmio0_wr_last,    
  input                          mmio0_wr_accept,   
  output reg [3:0]               mmio0_wr_mask,    
  output reg [`DATA_RANGE]       mmio0_wr_data,    
  
  input                          mmio0_rd_valid,                
  input                          mmio0_rd_err,                
  input                          mmio0_rd_excl_ok,
  input                          mmio0_rd_last,                 
  output reg                     mmio0_rd_accept,               
  input  [`DATA_RANGE]           mmio0_rd_data,     
  
  input                          mmio0_wr_done,
  input                          mmio0_wr_excl_okay,
  input                          mmio0_wr_err,
  output reg                     mmio0_wr_resp_accept,


  output reg                     mmio1_cmd_valid, 
  output reg [3:0]               mmio1_cmd_cache, 
  output reg                     mmio1_cmd_burst_size,                 
  output reg                     mmio1_cmd_read,                
  output reg                     mmio1_cmd_aux,                
  input                          mmio1_cmd_accept,              
  output reg [`ADDR_RANGE]       mmio1_cmd_addr,                             
  output reg                     mmio1_cmd_excl,
  output reg [5:0]               mmio1_cmd_atomic,
  output reg [2:0]               mmio1_cmd_data_size,                
  output reg [1:0]               mmio1_cmd_prot,                

  output reg                     mmio1_wr_valid,    
  output reg                     mmio1_wr_last,    
  input                          mmio1_wr_accept,   
  output reg [3:0]               mmio1_wr_mask,    
  output reg [`DATA_RANGE]       mmio1_wr_data,    
  
  input                          mmio1_rd_valid,                
  input                          mmio1_rd_err,                
  input                          mmio1_rd_excl_ok,
  input                          mmio1_rd_last,                 
  output reg                     mmio1_rd_accept,               
  input  [`DATA_RANGE]           mmio1_rd_data,     
  
  input                          mmio1_wr_done,
  input                          mmio1_wr_excl_okay,
  input                          mmio1_wr_err,
  output reg                     mmio1_wr_resp_accept,


  output reg                     mmio2_cmd_valid, 
  output reg [3:0]               mmio2_cmd_cache, 
  output reg                     mmio2_cmd_burst_size,                 
  output reg                     mmio2_cmd_read,                
  output reg                     mmio2_cmd_aux,                
  input                          mmio2_cmd_accept,              
  output reg [`ADDR_RANGE]       mmio2_cmd_addr,                             
  output reg                     mmio2_cmd_excl,
  output reg [5:0]               mmio2_cmd_atomic,
  output reg [2:0]               mmio2_cmd_data_size,                
  output reg [1:0]               mmio2_cmd_prot,                

  output reg                     mmio2_wr_valid,    
  output reg                     mmio2_wr_last,    
  input                          mmio2_wr_accept,   
  output reg [3:0]               mmio2_wr_mask,    
  output reg [`DATA_RANGE]       mmio2_wr_data,    
  
  input                          mmio2_rd_valid,                
  input                          mmio2_rd_err,                
  input                          mmio2_rd_excl_ok,
  input                          mmio2_rd_last,                 
  output reg                     mmio2_rd_accept,               
  input  [`DATA_RANGE]           mmio2_rd_data,     
  
  input                          mmio2_wr_done,
  input                          mmio2_wr_excl_okay,
  input                          mmio2_wr_err,
  output reg                     mmio2_wr_resp_accept,


  ///////// BIU idle signals ///////////////////////////////////////////////////
  //
  output                         biu_mmio_idle,

  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                   // clock signal
  input                          rst_a                  // reset signal
);

// FSM
localparam S_IDLE         =  2'b00;
localparam S_WDATA        =  2'b01;
localparam S_RDATA        =  2'b10;


// Declarations

reg  [2:0] mmio_id_nxt;
wire [2:0] mmio_id_next;
reg  [2:0] mmio_id_r;
reg             arb_id_nxt; // 0: LSQ, 1: DMI
reg             arb_id_r;
reg             arb_id_cg;

reg [1:0]       ibp_state_nxt;
reg [1:0]       ibp_state_r;

reg                 ibp_cmd_valid;
reg  [3:0]          ibp_cmd_cache;
reg                 ibp_cmd_burst_size;                
reg                 ibp_cmd_read;              
reg                 ibp_cmd_aux;              
reg                 ibp_cmd_accept;            
reg  [`ADDR_RANGE]  ibp_cmd_addr;                           
reg                 ibp_cmd_excl;
reg  [5:0]          ibp_cmd_atomic;
reg  [2:0]          ibp_cmd_data_size;             
reg  [1:0]          ibp_cmd_prot;              

reg                 ibp_wr_valid; 
reg                 ibp_wr_last;  
reg                 ibp_wr_accept;   
reg  [3:0]          ibp_wr_mask;  
reg  [`DATA_RANGE]  ibp_wr_data;    

reg                 ibp_rd_valid;                
reg                 ibp_rd_err;              
reg                 ibp_rd_excl_ok;
reg                 ibp_rd_last;              
reg                 ibp_rd_accept;               
reg [`DATA_RANGE]   ibp_rd_data;   

reg                 ibp_wr_done;
reg                 ibp_wr_excl_okay;
reg                 ibp_wr_err;
reg                 ibp_wr_resp_accept;

wire                ibp_target0;
wire                ibp_target1;
wire                ibp_target2;

assign              biu_mmio_idle = (ibp_state_r == S_IDLE) & !ibp_cmd_valid;

// mmio transfer ID decode
assign ibp_target0 = (ibp_cmd_addr[19:16] == 1);
assign ibp_target1 = (ibp_cmd_addr[19:8] == 768);
assign ibp_target2 = (ibp_cmd_addr[19:8] == 769);
assign mmio_id_next = {
                        ibp_target2,
                        ibp_target1,
                        ibp_target0
	};


// FSM process
always @*
begin : fsm_state_PROC
  mmio_id_nxt = mmio_id_r;
  ibp_state_nxt = ibp_state_r;
  mmio0_cmd_valid      = 1'b0;
  mmio0_cmd_cache      = 4'b0;
  mmio0_cmd_burst_size = 1'b0;
  mmio0_cmd_read       = 1'b0;
  mmio0_cmd_aux        = 1'b0;
  mmio0_cmd_addr       = `ADDR_SIZE'b0;
  mmio0_cmd_excl       = 1'b0;
  mmio0_cmd_atomic     = 6'b0;
  mmio0_cmd_data_size  = 3'b0;
  mmio0_cmd_prot       = 2'b0;

  mmio0_rd_accept      = 1'b0;

  mmio0_wr_valid       = 1'b0;
  mmio0_wr_last        = 1'b0;
  mmio0_wr_mask        = 4'b0;
  mmio0_wr_data        = `DATA_SIZE'b0;

  mmio0_wr_resp_accept = 1'b0;

  mmio1_cmd_valid      = 1'b0;
  mmio1_cmd_cache      = 4'b0;
  mmio1_cmd_burst_size = 1'b0;
  mmio1_cmd_read       = 1'b0;
  mmio1_cmd_aux        = 1'b0;
  mmio1_cmd_addr       = `ADDR_SIZE'b0;
  mmio1_cmd_excl       = 1'b0;
  mmio1_cmd_atomic     = 6'b0;
  mmio1_cmd_data_size  = 3'b0;
  mmio1_cmd_prot       = 2'b0;

  mmio1_rd_accept      = 1'b0;

  mmio1_wr_valid       = 1'b0;
  mmio1_wr_last        = 1'b0;
  mmio1_wr_mask        = 4'b0;
  mmio1_wr_data        = `DATA_SIZE'b0;

  mmio1_wr_resp_accept = 1'b0;

  mmio2_cmd_valid      = 1'b0;
  mmio2_cmd_cache      = 4'b0;
  mmio2_cmd_burst_size = 1'b0;
  mmio2_cmd_read       = 1'b0;
  mmio2_cmd_aux        = 1'b0;
  mmio2_cmd_addr       = `ADDR_SIZE'b0;
  mmio2_cmd_excl       = 1'b0;
  mmio2_cmd_atomic     = 6'b0;
  mmio2_cmd_data_size  = 3'b0;
  mmio2_cmd_prot       = 2'b0;

  mmio2_rd_accept      = 1'b0;

  mmio2_wr_valid       = 1'b0;
  mmio2_wr_last        = 1'b0;
  mmio2_wr_mask        = 4'b0;
  mmio2_wr_data        = `DATA_SIZE'b0;

  mmio2_wr_resp_accept = 1'b0;

  arb_id_nxt                 = 1'b0;
  arb_id_cg                  = 1'b0;

  ibp_cmd_valid              = 1'b0;
  ibp_cmd_cache              = 4'b0;
  ibp_cmd_burst_size         = 1'b0;                
  ibp_cmd_read               = 1'b0;              
  ibp_cmd_aux                = 1'b0;              
  ibp_cmd_accept             = 1'b0;            
  ibp_cmd_addr               = `ADDR_SIZE'b0;                           
  ibp_cmd_excl               = 1'b0;
  ibp_cmd_atomic             = 6'b0;
  ibp_cmd_data_size          = 3'b0;             
  ibp_cmd_prot               = 2'b0;              

  ibp_wr_valid               = 1'b0; 
  ibp_wr_last                = 1'b0;  
  ibp_wr_accept              = 1'b0;   
  ibp_wr_mask                = 4'b0;  
  ibp_wr_data                = `DATA_SIZE'b0;    

  ibp_rd_valid               = 1'b0;                
  ibp_rd_err                 = 1'b0;              
  ibp_rd_excl_ok             = 1'b0;
  ibp_rd_last                = 1'b0;              
  ibp_rd_accept              = 1'b0;               
  ibp_rd_data                = `DATA_SIZE'b0;   

  ibp_wr_done                = 1'b0;
  ibp_wr_excl_okay           = 1'b0;
  ibp_wr_err                 = 1'b0;
  ibp_wr_resp_accept         = 1'b0;

  lsq_ibp_cmd_accept         = 1'b0;
  lsq_ibp_wr_accept          = 1'b0;
  lsq_ibp_rd_valid           = 1'b0;
  lsq_ibp_rd_err             = 1'b0;
  lsq_ibp_rd_excl_ok         = 1'b0;
  lsq_ibp_rd_last            = 1'b0;
  lsq_ibp_rd_data            = `DATA_SIZE'b0;
  lsq_ibp_wr_done            = 1'b0;
  lsq_ibp_wr_excl_okay       = 1'b0;
  lsq_ibp_wr_err             = 1'b0;

  dmi_ibp_cmd_accept         = 1'b0;
  dmi_ibp_wr_accept          = 1'b0;
  dmi_ibp_rd_valid           = 1'b0;
  dmi_ibp_rd_err             = 1'b0;
  dmi_ibp_rd_excl_ok         = 1'b0;
  dmi_ibp_rd_last            = 1'b0;
  dmi_ibp_rd_data            = `DATA_SIZE'b0;
  dmi_ibp_wr_done            = 1'b0;
  dmi_ibp_wr_excl_okay       = 1'b0;
  dmi_ibp_wr_err             = 1'b0;

// Arbitration logic: by default, LSQ access has higher priority. unless dmi_ibp_cmd_prio is asserted high.
  if (dmi_ibp_cmd_prio && dmi_ibp_cmd_valid)
	begin
      arb_id_nxt                 = 1'b1;

      ibp_cmd_valid              = dmi_ibp_cmd_valid;
      ibp_cmd_cache              = dmi_ibp_cmd_cache;
      ibp_cmd_burst_size         = dmi_ibp_cmd_burst_size;                
      ibp_cmd_read               = dmi_ibp_cmd_read;              
      ibp_cmd_aux                = dmi_ibp_cmd_aux;              
      ibp_cmd_addr               = dmi_ibp_cmd_addr;                           
      ibp_cmd_excl               = dmi_ibp_cmd_excl;
      ibp_cmd_atomic             = dmi_ibp_cmd_atomic;
      ibp_cmd_data_size          = dmi_ibp_cmd_data_size;            
      ibp_cmd_prot               = dmi_ibp_cmd_prot;              
    
      ibp_wr_valid               = dmi_ibp_wr_valid; 
      ibp_wr_last                = dmi_ibp_wr_last;  
      ibp_wr_mask                = dmi_ibp_wr_mask;  
      ibp_wr_data                = dmi_ibp_wr_data;    
    
      ibp_rd_accept              = dmi_ibp_rd_accept;               
    
      ibp_wr_resp_accept         = dmi_ibp_wr_resp_accept;
	end
  else if (lsq_ibp_cmd_valid)
	begin
      arb_id_nxt                 = 1'b0;

      ibp_cmd_valid              = lsq_ibp_cmd_valid;
      ibp_cmd_cache              = lsq_ibp_cmd_cache;
      ibp_cmd_burst_size         = lsq_ibp_cmd_burst_size;                
      ibp_cmd_read               = lsq_ibp_cmd_read;              
      ibp_cmd_aux                = lsq_ibp_cmd_aux;              
      ibp_cmd_addr               = lsq_ibp_cmd_addr;                           
      ibp_cmd_excl               = lsq_ibp_cmd_excl;
      ibp_cmd_atomic             = lsq_ibp_cmd_atomic;
      ibp_cmd_data_size          = lsq_ibp_cmd_data_size;            
      ibp_cmd_prot               = lsq_ibp_cmd_prot;              
    
      ibp_wr_valid               = lsq_ibp_wr_valid; 
      ibp_wr_last                = lsq_ibp_wr_last;  
      ibp_wr_mask                = lsq_ibp_wr_mask;  
      ibp_wr_data                = lsq_ibp_wr_data;    
    
      ibp_rd_accept              = lsq_ibp_rd_accept;               
    
      ibp_wr_resp_accept         = lsq_ibp_wr_resp_accept;
	end
  else if (dmi_ibp_cmd_valid)
    begin
      arb_id_nxt                 = 1'b1;

      ibp_cmd_valid              = dmi_ibp_cmd_valid;
      ibp_cmd_cache              = dmi_ibp_cmd_cache;
      ibp_cmd_burst_size         = dmi_ibp_cmd_burst_size;                
      ibp_cmd_read               = dmi_ibp_cmd_read;              
      ibp_cmd_aux                = dmi_ibp_cmd_aux;              
      ibp_cmd_addr               = dmi_ibp_cmd_addr;                           
      ibp_cmd_excl               = dmi_ibp_cmd_excl;
      ibp_cmd_atomic             = dmi_ibp_cmd_atomic;
      ibp_cmd_data_size          = dmi_ibp_cmd_data_size;            
      ibp_cmd_prot               = dmi_ibp_cmd_prot;              
    
      ibp_wr_valid               = dmi_ibp_wr_valid; 
      ibp_wr_last                = dmi_ibp_wr_last;  
      ibp_wr_mask                = dmi_ibp_wr_mask;  
      ibp_wr_data                = dmi_ibp_wr_data;    
    
      ibp_rd_accept              = dmi_ibp_rd_accept;               
    
      ibp_wr_resp_accept         = dmi_ibp_wr_resp_accept;
	end

  case (ibp_state_r)
    S_IDLE:
	begin
	  case (1'b1)
        mmio_id_next[0] :
	    begin
          mmio0_cmd_valid      = ibp_cmd_valid;
		  mmio0_cmd_cache      = ibp_cmd_cache;
		  mmio0_cmd_burst_size = ibp_cmd_burst_size;
		  mmio0_cmd_read       = ibp_cmd_read;
		  mmio0_cmd_aux        = ibp_cmd_aux;
		  ibp_cmd_accept             = mmio0_cmd_accept;
		  mmio0_cmd_addr       = ibp_cmd_addr;
		  mmio0_cmd_excl       = ibp_cmd_excl;
		  mmio0_cmd_atomic     = ibp_cmd_atomic;
		  mmio0_cmd_data_size  = ibp_cmd_data_size;
		  mmio0_cmd_prot       = ibp_cmd_prot;

		  mmio0_wr_valid       = ibp_wr_valid;
		  mmio0_wr_last        = ibp_wr_last;
		  ibp_wr_accept              = mmio0_wr_accept;
		  mmio0_wr_mask        = ibp_wr_mask;
		  mmio0_wr_data        = ibp_wr_data;
	    end
        mmio_id_next[1] :
	    begin
          mmio1_cmd_valid      = ibp_cmd_valid;
		  mmio1_cmd_cache      = ibp_cmd_cache;
		  mmio1_cmd_burst_size = ibp_cmd_burst_size;
		  mmio1_cmd_read       = ibp_cmd_read;
		  mmio1_cmd_aux        = ibp_cmd_aux;
		  ibp_cmd_accept             = mmio1_cmd_accept;
		  mmio1_cmd_addr       = ibp_cmd_addr;
		  mmio1_cmd_excl       = ibp_cmd_excl;
		  mmio1_cmd_atomic     = ibp_cmd_atomic;
		  mmio1_cmd_data_size  = ibp_cmd_data_size;
		  mmio1_cmd_prot       = ibp_cmd_prot;

		  mmio1_wr_valid       = ibp_wr_valid;
		  mmio1_wr_last        = ibp_wr_last;
		  ibp_wr_accept              = mmio1_wr_accept;
		  mmio1_wr_mask        = ibp_wr_mask;
		  mmio1_wr_data        = ibp_wr_data;
	    end
        mmio_id_next[2] :
	    begin
          mmio2_cmd_valid      = ibp_cmd_valid;
		  mmio2_cmd_cache      = ibp_cmd_cache;
		  mmio2_cmd_burst_size = ibp_cmd_burst_size;
		  mmio2_cmd_read       = ibp_cmd_read;
		  mmio2_cmd_aux        = ibp_cmd_aux;
		  ibp_cmd_accept             = mmio2_cmd_accept;
		  mmio2_cmd_addr       = ibp_cmd_addr;
		  mmio2_cmd_excl       = ibp_cmd_excl;
		  mmio2_cmd_atomic     = ibp_cmd_atomic;
		  mmio2_cmd_data_size  = ibp_cmd_data_size;
		  mmio2_cmd_prot       = ibp_cmd_prot;

		  mmio2_wr_valid       = ibp_wr_valid;
		  mmio2_wr_last        = ibp_wr_last;
		  ibp_wr_accept              = mmio2_wr_accept;
		  mmio2_wr_mask        = ibp_wr_mask;
		  mmio2_wr_data        = ibp_wr_data;
	    end
        default:
		  begin
            if (dmi_ibp_cmd_prio && dmi_ibp_cmd_valid)
            begin
              ibp_cmd_accept         = 1'b1;
              ibp_wr_accept          = dmi_ibp_wr_valid;
            end
            else if (lsq_ibp_cmd_valid)
            begin
              ibp_cmd_accept         = 1'b1;
              ibp_wr_accept          = lsq_ibp_wr_valid;
            end
            else if (dmi_ibp_cmd_valid)
            begin
              ibp_cmd_accept         = 1'b1;
              ibp_wr_accept          = dmi_ibp_wr_valid;
            end
		  end
	  endcase

	  if (dmi_ibp_cmd_prio && dmi_ibp_cmd_valid)
	  begin
        dmi_ibp_cmd_accept         = ibp_cmd_accept;
        dmi_ibp_wr_accept          = ibp_wr_accept;
        dmi_ibp_rd_valid           = ibp_rd_valid;                
        dmi_ibp_rd_err             = ibp_rd_err;              
        dmi_ibp_rd_excl_ok         = ibp_rd_excl_ok;
        dmi_ibp_rd_last            = ibp_rd_last;              
        dmi_ibp_rd_data            = ibp_rd_data;    
        dmi_ibp_wr_done            = ibp_wr_done;
        dmi_ibp_wr_excl_okay       = ibp_wr_excl_okay;
        dmi_ibp_wr_err             = ibp_wr_err;
	  end
      else if (lsq_ibp_cmd_valid)
	  begin
        lsq_ibp_cmd_accept         = ibp_cmd_accept;
        lsq_ibp_wr_accept          = ibp_wr_accept;
        lsq_ibp_rd_valid           = ibp_rd_valid;                
        lsq_ibp_rd_err             = ibp_rd_err;              
        lsq_ibp_rd_excl_ok         = ibp_rd_excl_ok;
        lsq_ibp_rd_last            = ibp_rd_last;              
        lsq_ibp_rd_data            = ibp_rd_data;    
        lsq_ibp_wr_done            = ibp_wr_done;
        lsq_ibp_wr_excl_okay       = ibp_wr_excl_okay;
        lsq_ibp_wr_err             = ibp_wr_err;
	  end
      else if (dmi_ibp_cmd_valid)
      begin
        dmi_ibp_cmd_accept         = ibp_cmd_accept;
        dmi_ibp_wr_accept          = ibp_wr_accept;
        dmi_ibp_rd_valid           = ibp_rd_valid;                
        dmi_ibp_rd_err             = ibp_rd_err;              
        dmi_ibp_rd_excl_ok         = ibp_rd_excl_ok;
        dmi_ibp_rd_last            = ibp_rd_last;              
        dmi_ibp_rd_data            = ibp_rd_data;    
        dmi_ibp_wr_done            = ibp_wr_done;
        dmi_ibp_wr_excl_okay       = ibp_wr_excl_okay;
        dmi_ibp_wr_err             = ibp_wr_err;
	  end

      if (ibp_cmd_valid)
	  begin
	    arb_id_cg   = 1'b1;
        mmio_id_nxt = mmio_id_next;      
        if (ibp_cmd_read)
		  ibp_state_nxt = S_RDATA;
		else
		  ibp_state_nxt = S_WDATA;
	  end
	end
    S_WDATA :
	begin
	  if (arb_id_r == 1'b0)
	    begin
          ibp_cmd_valid              = lsq_ibp_cmd_valid;
          ibp_cmd_cache              = lsq_ibp_cmd_cache;
          ibp_cmd_burst_size         = lsq_ibp_cmd_burst_size;                
          ibp_cmd_read               = lsq_ibp_cmd_read;              
          ibp_cmd_aux                = lsq_ibp_cmd_aux;              
          ibp_cmd_addr               = lsq_ibp_cmd_addr;                           
          ibp_cmd_excl               = lsq_ibp_cmd_excl;
          ibp_cmd_atomic             = lsq_ibp_cmd_atomic;
          ibp_cmd_data_size          = lsq_ibp_cmd_data_size;            
          ibp_cmd_prot               = lsq_ibp_cmd_prot;              
    
          ibp_wr_valid               = lsq_ibp_wr_valid; 
          ibp_wr_last                = lsq_ibp_wr_last;  
          ibp_wr_mask                = lsq_ibp_wr_mask;  
          ibp_wr_data                = lsq_ibp_wr_data;    
    
          ibp_rd_accept              = lsq_ibp_rd_accept;               
    
          ibp_wr_resp_accept         = lsq_ibp_wr_resp_accept;
		end
	  else
		begin
          ibp_cmd_valid              = dmi_ibp_cmd_valid;
          ibp_cmd_cache              = dmi_ibp_cmd_cache;
          ibp_cmd_burst_size         = dmi_ibp_cmd_burst_size;                
          ibp_cmd_read               = dmi_ibp_cmd_read;              
          ibp_cmd_aux                = dmi_ibp_cmd_aux;              
          ibp_cmd_addr               = dmi_ibp_cmd_addr;                           
          ibp_cmd_excl               = dmi_ibp_cmd_excl;
          ibp_cmd_atomic             = dmi_ibp_cmd_atomic;
          ibp_cmd_data_size          = dmi_ibp_cmd_data_size;            
          ibp_cmd_prot               = dmi_ibp_cmd_prot;              
    
          ibp_wr_valid               = dmi_ibp_wr_valid; 
          ibp_wr_last                = dmi_ibp_wr_last;  
          ibp_wr_mask                = dmi_ibp_wr_mask;  
          ibp_wr_data                = dmi_ibp_wr_data;    
    
          ibp_rd_accept              = dmi_ibp_rd_accept;               
    
          ibp_wr_resp_accept         = dmi_ibp_wr_resp_accept;
		end

      case (1'b1)
        mmio_id_r[0] :
		begin
          mmio0_cmd_valid        = ibp_cmd_valid;
		  mmio0_cmd_cache        = ibp_cmd_cache;
		  mmio0_cmd_burst_size   = ibp_cmd_burst_size;
		  mmio0_cmd_read         = ibp_cmd_read;
		  mmio0_cmd_aux          = ibp_cmd_aux;
		  ibp_cmd_accept               = mmio0_cmd_accept;
		  mmio0_cmd_addr         = ibp_cmd_addr;
		  mmio0_cmd_excl         = ibp_cmd_excl;
		  mmio0_cmd_atomic       = ibp_cmd_atomic;
		  mmio0_cmd_data_size    = ibp_cmd_data_size;
		  mmio0_cmd_prot         = ibp_cmd_prot;

          mmio0_wr_valid         = ibp_wr_valid;
		  mmio0_wr_last          = ibp_wr_last;
		  ibp_wr_accept                = mmio0_wr_accept;
		  mmio0_wr_mask          = ibp_wr_mask;
		  mmio0_wr_data          = ibp_wr_data;

		  ibp_wr_done                  = mmio0_wr_done;
		  ibp_wr_excl_okay             = mmio0_wr_excl_okay;
		  ibp_wr_err                   = mmio0_wr_err;
		  mmio0_wr_resp_accept   = ibp_wr_resp_accept;
		end
        mmio_id_r[1] :
		begin
          mmio1_cmd_valid        = ibp_cmd_valid;
		  mmio1_cmd_cache        = ibp_cmd_cache;
		  mmio1_cmd_burst_size   = ibp_cmd_burst_size;
		  mmio1_cmd_read         = ibp_cmd_read;
		  mmio1_cmd_aux          = ibp_cmd_aux;
		  ibp_cmd_accept               = mmio1_cmd_accept;
		  mmio1_cmd_addr         = ibp_cmd_addr;
		  mmio1_cmd_excl         = ibp_cmd_excl;
		  mmio1_cmd_atomic       = ibp_cmd_atomic;
		  mmio1_cmd_data_size    = ibp_cmd_data_size;
		  mmio1_cmd_prot         = ibp_cmd_prot;

          mmio1_wr_valid         = ibp_wr_valid;
		  mmio1_wr_last          = ibp_wr_last;
		  ibp_wr_accept                = mmio1_wr_accept;
		  mmio1_wr_mask          = ibp_wr_mask;
		  mmio1_wr_data          = ibp_wr_data;

		  ibp_wr_done                  = mmio1_wr_done;
		  ibp_wr_excl_okay             = mmio1_wr_excl_okay;
		  ibp_wr_err                   = mmio1_wr_err;
		  mmio1_wr_resp_accept   = ibp_wr_resp_accept;
		end
        mmio_id_r[2] :
		begin
          mmio2_cmd_valid        = ibp_cmd_valid;
		  mmio2_cmd_cache        = ibp_cmd_cache;
		  mmio2_cmd_burst_size   = ibp_cmd_burst_size;
		  mmio2_cmd_read         = ibp_cmd_read;
		  mmio2_cmd_aux          = ibp_cmd_aux;
		  ibp_cmd_accept               = mmio2_cmd_accept;
		  mmio2_cmd_addr         = ibp_cmd_addr;
		  mmio2_cmd_excl         = ibp_cmd_excl;
		  mmio2_cmd_atomic       = ibp_cmd_atomic;
		  mmio2_cmd_data_size    = ibp_cmd_data_size;
		  mmio2_cmd_prot         = ibp_cmd_prot;

          mmio2_wr_valid         = ibp_wr_valid;
		  mmio2_wr_last          = ibp_wr_last;
		  ibp_wr_accept                = mmio2_wr_accept;
		  mmio2_wr_mask          = ibp_wr_mask;
		  mmio2_wr_data          = ibp_wr_data;

		  ibp_wr_done                  = mmio2_wr_done;
		  ibp_wr_excl_okay             = mmio2_wr_excl_okay;
		  ibp_wr_err                   = mmio2_wr_err;
		  mmio2_wr_resp_accept   = ibp_wr_resp_accept;
		end
        default:
          begin
		    ibp_cmd_accept         = 1'b0;
			ibp_wr_accept          = 1'b0;
            ibp_wr_done            = 1'b1;
            ibp_wr_excl_okay       = 1'b0;
            ibp_wr_err             = 1'b0;
		  end
	  endcase
	  
	  if (arb_id_r == 1'b0)
	  begin
        lsq_ibp_cmd_accept         = ibp_cmd_accept;
        lsq_ibp_wr_accept          = ibp_wr_accept;
        lsq_ibp_rd_valid           = ibp_rd_valid;                
        lsq_ibp_rd_err             = ibp_rd_err;              
        lsq_ibp_rd_excl_ok         = ibp_rd_excl_ok;
        lsq_ibp_rd_last            = ibp_rd_last;              
        lsq_ibp_rd_data            = ibp_rd_data;    
        lsq_ibp_wr_done            = ibp_wr_done;
        lsq_ibp_wr_excl_okay       = ibp_wr_excl_okay;
        lsq_ibp_wr_err             = ibp_wr_err;
	  end
	  else
	  begin
        dmi_ibp_cmd_accept         = ibp_cmd_accept;
        dmi_ibp_wr_accept          = ibp_wr_accept;
        dmi_ibp_rd_valid           = ibp_rd_valid;                
        dmi_ibp_rd_err             = ibp_rd_err;              
        dmi_ibp_rd_excl_ok         = ibp_rd_excl_ok;
        dmi_ibp_rd_last            = ibp_rd_last;              
        dmi_ibp_rd_data            = ibp_rd_data;    
        dmi_ibp_wr_done            = ibp_wr_done;
        dmi_ibp_wr_excl_okay       = ibp_wr_excl_okay;
        dmi_ibp_wr_err             = ibp_wr_err;
	  end

	  if (ibp_wr_done && ibp_wr_resp_accept)
	  begin
        ibp_state_nxt = S_IDLE;
	  end
	end
    default :  //S_RDATA
	begin
	  if (arb_id_r == 1'b0)
	    begin
          ibp_cmd_valid              = lsq_ibp_cmd_valid;
          ibp_cmd_cache              = lsq_ibp_cmd_cache;
          ibp_cmd_burst_size         = lsq_ibp_cmd_burst_size;                
          ibp_cmd_read               = lsq_ibp_cmd_read;              
          ibp_cmd_aux                = lsq_ibp_cmd_aux;              
          ibp_cmd_addr               = lsq_ibp_cmd_addr;                           
          ibp_cmd_excl               = lsq_ibp_cmd_excl;
          ibp_cmd_atomic             = lsq_ibp_cmd_atomic;
          ibp_cmd_data_size          = lsq_ibp_cmd_data_size;            
          ibp_cmd_prot               = lsq_ibp_cmd_prot;              
    
          ibp_wr_valid               = lsq_ibp_wr_valid; 
          ibp_wr_last                = lsq_ibp_wr_last;  
          ibp_wr_mask                = lsq_ibp_wr_mask;  
          ibp_wr_data                = lsq_ibp_wr_data;    
    
          ibp_rd_accept              = lsq_ibp_rd_accept;               
    
          ibp_wr_resp_accept         = lsq_ibp_wr_resp_accept;
		end
	  else
		begin
          ibp_cmd_valid              = dmi_ibp_cmd_valid;
          ibp_cmd_cache              = dmi_ibp_cmd_cache;
          ibp_cmd_burst_size         = dmi_ibp_cmd_burst_size;                
          ibp_cmd_read               = dmi_ibp_cmd_read;              
          ibp_cmd_aux                = dmi_ibp_cmd_aux;              
          ibp_cmd_addr               = dmi_ibp_cmd_addr;                           
          ibp_cmd_excl               = dmi_ibp_cmd_excl;
          ibp_cmd_atomic             = dmi_ibp_cmd_atomic;
          ibp_cmd_data_size          = dmi_ibp_cmd_data_size;            
          ibp_cmd_prot               = dmi_ibp_cmd_prot;              
    
          ibp_wr_valid               = dmi_ibp_wr_valid; 
          ibp_wr_last                = dmi_ibp_wr_last;  
          ibp_wr_mask                = dmi_ibp_wr_mask;  
          ibp_wr_data                = dmi_ibp_wr_data;    
    
          ibp_rd_accept              = dmi_ibp_rd_accept;               
    
          ibp_wr_resp_accept         = dmi_ibp_wr_resp_accept;
		end

      case (1'b1)
        mmio_id_r[0] :
        begin
          mmio0_cmd_valid        = ibp_cmd_valid;
		  mmio0_cmd_cache        = ibp_cmd_cache;
		  mmio0_cmd_burst_size   = ibp_cmd_burst_size;
		  mmio0_cmd_read         = ibp_cmd_read;
		  mmio0_cmd_aux          = ibp_cmd_aux;
		  ibp_cmd_accept               = mmio0_cmd_accept;
		  mmio0_cmd_addr         = ibp_cmd_addr;
		  mmio0_cmd_excl         = ibp_cmd_excl;
		  mmio0_cmd_atomic       = ibp_cmd_atomic;
		  mmio0_cmd_data_size    = ibp_cmd_data_size;
		  mmio0_cmd_prot         = ibp_cmd_prot;

          ibp_rd_valid                 = mmio0_rd_valid;
		  ibp_rd_err                   = mmio0_rd_err;
		  ibp_rd_excl_ok               = mmio0_rd_excl_ok;
		  ibp_rd_last                  = mmio0_rd_last;
		  mmio0_rd_accept        = ibp_rd_accept;
		  ibp_rd_data                  = mmio0_rd_data;
		end
        mmio_id_r[1] :
        begin
          mmio1_cmd_valid        = ibp_cmd_valid;
		  mmio1_cmd_cache        = ibp_cmd_cache;
		  mmio1_cmd_burst_size   = ibp_cmd_burst_size;
		  mmio1_cmd_read         = ibp_cmd_read;
		  mmio1_cmd_aux          = ibp_cmd_aux;
		  ibp_cmd_accept               = mmio1_cmd_accept;
		  mmio1_cmd_addr         = ibp_cmd_addr;
		  mmio1_cmd_excl         = ibp_cmd_excl;
		  mmio1_cmd_atomic       = ibp_cmd_atomic;
		  mmio1_cmd_data_size    = ibp_cmd_data_size;
		  mmio1_cmd_prot         = ibp_cmd_prot;

          ibp_rd_valid                 = mmio1_rd_valid;
		  ibp_rd_err                   = mmio1_rd_err;
		  ibp_rd_excl_ok               = mmio1_rd_excl_ok;
		  ibp_rd_last                  = mmio1_rd_last;
		  mmio1_rd_accept        = ibp_rd_accept;
		  ibp_rd_data                  = mmio1_rd_data;
		end
        mmio_id_r[2] :
        begin
          mmio2_cmd_valid        = ibp_cmd_valid;
		  mmio2_cmd_cache        = ibp_cmd_cache;
		  mmio2_cmd_burst_size   = ibp_cmd_burst_size;
		  mmio2_cmd_read         = ibp_cmd_read;
		  mmio2_cmd_aux          = ibp_cmd_aux;
		  ibp_cmd_accept               = mmio2_cmd_accept;
		  mmio2_cmd_addr         = ibp_cmd_addr;
		  mmio2_cmd_excl         = ibp_cmd_excl;
		  mmio2_cmd_atomic       = ibp_cmd_atomic;
		  mmio2_cmd_data_size    = ibp_cmd_data_size;
		  mmio2_cmd_prot         = ibp_cmd_prot;

          ibp_rd_valid                 = mmio2_rd_valid;
		  ibp_rd_err                   = mmio2_rd_err;
		  ibp_rd_excl_ok               = mmio2_rd_excl_ok;
		  ibp_rd_last                  = mmio2_rd_last;
		  mmio2_rd_accept        = ibp_rd_accept;
		  ibp_rd_data                  = mmio2_rd_data;
		end
        default:
          begin
            ibp_rd_valid           = 1'b1;                
            ibp_rd_err             = 1'b0;              
            ibp_rd_excl_ok         = 1'b0;
            ibp_rd_last            = 1'b1;              
            ibp_rd_data            = `DATA_SIZE'h0;    
          end
      endcase

	  if (arb_id_r == 1'b0)
	  begin
        lsq_ibp_cmd_accept         = ibp_cmd_accept;
        lsq_ibp_wr_accept          = ibp_wr_accept;
        lsq_ibp_rd_valid           = ibp_rd_valid;                
        lsq_ibp_rd_err             = ibp_rd_err;              
        lsq_ibp_rd_excl_ok         = ibp_rd_excl_ok;
        lsq_ibp_rd_last            = ibp_rd_last;              
        lsq_ibp_rd_data            = ibp_rd_data;    
        lsq_ibp_wr_done            = ibp_wr_done;
        lsq_ibp_wr_excl_okay       = ibp_wr_excl_okay;
        lsq_ibp_wr_err             = ibp_wr_err;
	  end
	  else
	  begin
        dmi_ibp_cmd_accept         = ibp_cmd_accept;
        dmi_ibp_wr_accept          = ibp_wr_accept;
        dmi_ibp_rd_valid           = ibp_rd_valid;                
        dmi_ibp_rd_err             = ibp_rd_err;              
        dmi_ibp_rd_excl_ok         = ibp_rd_excl_ok;
        dmi_ibp_rd_last            = ibp_rd_last;              
        dmi_ibp_rd_data            = ibp_rd_data;    
        dmi_ibp_wr_done            = ibp_wr_done;
        dmi_ibp_wr_excl_okay       = ibp_wr_excl_okay;
        dmi_ibp_wr_err             = ibp_wr_err;
	  end

	  if (ibp_rd_valid & ibp_rd_last & ibp_rd_accept)
	  begin
        ibp_state_nxt = S_IDLE;
	  end
	end
  endcase
end

/////////////////////////////////////////////////////////////////////////////////////////
//
// Synchronous processes
//
/////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst_a)
begin : regs_PROC
  if (rst_a == 1'b1)
  begin
    mmio_id_r   <= `BIU_MMIO_NUM'b0;
    ibp_state_r <= 2'b0;
  end
  else
  begin
    mmio_id_r   <= mmio_id_nxt;
    ibp_state_r <= ibp_state_nxt;
  end
end

always @(posedge clk or posedge rst_a)
begin : arb_id_r_PROC
  if (rst_a == 1'b1)
  begin
    arb_id_r   <= 1'b0;
  end
  else if (arb_id_cg)
  begin
    arb_id_r   <= arb_id_nxt;
  end
end


endmodule // rl_ibp2mmio

