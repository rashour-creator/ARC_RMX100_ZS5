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
`include "csr_defines.v"
`include "rv_safety_exported_defines.v"


// Set simulation timescale
//
`include "const.def"


module arcv_watchdog_csr (

  ////////// CSR access interface /////////////////////////////////////////
  //
  input [1:0]                     csr_sel_ctl,           // (X1) CSR slection (01 = read, 10 = write)
  input [11:0]                    csr_sel_addr,          // (X1) CSR address
  
  output reg [`DATA_RANGE]        csr_rdata,             // (X1) CSR read data
  output reg                      csr_illegal,           // (X1) illegal
  output reg                      csr_unimpl,            // (X1) Invalid CSR
  output reg                      csr_serial_sr,         // (X1) SR group flush pipe
  output reg                      csr_strict_sr,         // (X1) SR flush pipe
  
  input                           csr_write,             // (X2) CSR operation (01 = read, 10 = write)
  input [11:0]                    csr_waddr,             // (X2) CSR addr
  input [`DATA_RANGE]             csr_wdata,             // (X2) Write data

  input                           x2_pass,               // (X2) commit
  input [1:0]                     priv_level_r,
  output                          csr_raw_hazard,

  ////////// Control signals interface /////////////////////////////////////////
  //
  input [`WDT_CTRL_RANGE]         wdt_control0_r,
  input [31:0]          wdt_period0_r,
  input [31:0]          wdt_period_cnt0_r,
  input [31:0]          wdt_lthresh0_r,
  input [31:0]          wdt_uthresh0_r,
  input                           i_enable_regs_in,

  input                           wdt_en_control_r,
  input                           wdt_en_period_r,
  input                           wdt_en_lthresh_r,
  input                           wdt_en_uthresh_r,
  input                           wdt_en_index_r,
  input                           wdt_en_passwd_r,

  input                           mst_passwd_match,
  input                           valid_wr,
  input                           db_active,

  output reg [`DATA_RANGE]        csr_wr_data,

  output reg                      csr_password_wen,
  output reg                      csr_ctrl_wen,
  output reg                      csr_period_wen,
  output reg                      csr_index_wen,
  output reg                      csr_lthresh_wen,
  output reg                      csr_uthresh_wen,
  output reg                      csr_passwd_pw0_wen,
  output reg                      csr_passwd_rst0_wen,
  output reg                      csr_ctrl0_wen,
  output reg                      csr_period0_wen,
  output reg                      csr_lthresh0_wen,
  output reg                      csr_uthresh0_wen,

  input [1:0]                     wdt_index_r,
  input [`WATCHDOG_NUM-1:0]       wdt_index_sel

);


////////////////////////////////////////////////////////////////////////////
//                                                                        //
// @CSR_PROC: WDT CSR register interface                                  //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

always @*
begin: csr_read_PROC

  csr_rdata            = {`DATA_SIZE{1'b0}};             
  csr_illegal          = 1'b0;    
  csr_unimpl           = 1'b1;    
  csr_serial_sr        = 1'b0; 
  csr_strict_sr        = 1'b0;

  if (csr_sel_ctl != 2'b00)
  begin
    case (csr_sel_addr)
//!BCR { num: 2000, val: 0, name: "MWDT_PASSWD" }
    `MWDT_PASSWD:
	begin
	  csr_rdata = {`DATA_SIZE{1'b0}};
	  csr_illegal      = (priv_level_r != `PRIV_M);
      csr_unimpl       = 1'b0;
	end
    `MWDT_CTRL:
	begin
      csr_illegal      = (~i_enable_regs_in & csr_sel_ctl[1]) | (priv_level_r != `PRIV_M);
      csr_unimpl       = 1'b0;
	  case (wdt_index_r)
          0:   csr_rdata = {{((`DATA_SIZE) - (`WDT_CTRL_SIZE) - 3){1'b0}}, wdt_index_r, i_enable_regs_in, wdt_control0_r};
          default:
	  begin
                 csr_unimpl  = 1'b1;	  
	  end
	  endcase
	end
	`MWDT_PERIOD:
	begin
      csr_illegal      = (~i_enable_regs_in & csr_sel_ctl[1]) | (priv_level_r != `PRIV_M);
      csr_unimpl       = 1'b0;
	  case (wdt_index_r)
          0: csr_rdata  = wdt_period0_r;
	  default:
	  begin
               csr_unimpl  = 1'b1;		  
	  end
	  endcase
	end
    `MWDT_COUNT:
	begin
      csr_illegal      = csr_sel_ctl[1] | (priv_level_r != `PRIV_M);
      csr_unimpl       = 1'b0;
	  case (wdt_index_r)
	   0: csr_rdata  =  wdt_period_cnt0_r;
	  default:
	  begin
               csr_unimpl  = 1'b1;		  
	  end
	  endcase
	end
    `MWDT_LTHRESH:
    begin
      csr_illegal      = (~i_enable_regs_in & csr_sel_ctl[1]) | (priv_level_r != `PRIV_M);
      csr_unimpl       = 1'b0;
          case (wdt_index_r)
              0: csr_rdata    = wdt_lthresh0_r;
	  default:
	  begin
                   csr_unimpl  = 1'b1;		  
	  end
          endcase
	end
    `MWDT_UTHRESH:
	begin
      csr_illegal      = (~i_enable_regs_in & csr_sel_ctl[1]) | (priv_level_r != `PRIV_M);
      csr_unimpl       = 1'b0;
          case (wdt_index_r)
              0: csr_rdata    = wdt_uthresh0_r;
	  default:
	  begin
                   csr_unimpl  = 1'b1;		  
	  end
          endcase
	end



//!BCR { num: 4032, val: 2409708545, name: "ARCV_MWDT_BUILD" }
    `ARCV_WDT_BUILD:
	begin
      csr_illegal      = csr_sel_ctl[1] | (priv_level_r != `PRIV_M);
      csr_unimpl       = 1'b0;
      csr_rdata        = {1'b`WATCHDOG_CLK,
	                      14'd2000,
	                      3'd4,
						  4'd15,
                          2'd0,
						  8'h1
	  };
	end
    default:
    begin
      // csr_addr is not implemented in this module
      //
      csr_unimpl    = 1'b1;
    end
	endcase
  end
end

always @*
begin: csr_write_PROC
  // Write enable signals
  //
  csr_wr_data          = csr_wdata;

  csr_password_wen     = 1'b0;
  csr_ctrl_wen         = 1'b0;
  csr_period_wen       = 1'b0;
  csr_index_wen        = 1'b0;
  csr_lthresh_wen      = 1'b0;
  csr_uthresh_wen      = 1'b0; 
  csr_passwd_pw0_wen   = 1'b0;
  csr_passwd_rst0_wen  = 1'b0;
  csr_ctrl0_wen        = 1'b0;
  csr_period0_wen      = 1'b0;
  csr_lthresh0_wen     = 1'b0;
  csr_uthresh0_wen     = 1'b0;

  case (csr_waddr)
  `MWDT_PASSWD:
  begin
    csr_password_wen  = x2_pass & csr_write;
	csr_index_wen     = wdt_en_index_r & x2_pass & csr_write & (csr_wdata[`WDT_PASSWD_RST] == 1'b0);
    csr_passwd_pw0_wen = wdt_en_passwd_r & x2_pass & csr_write & wdt_index_sel[0];
    csr_passwd_rst0_wen = ~wdt_en_passwd_r & mst_passwd_match & (csr_wdata[`WDT_PASSWD_TN] == 0) & (csr_wdata[`WDT_PASSWD_RST] == 1'b1) &  x2_pass & csr_write & valid_wr;
  end
  `MWDT_CTRL:
  begin
    csr_ctrl_wen = csr_write & x2_pass;
          csr_ctrl0_wen = x2_pass & csr_write & wdt_index_sel[0] & (wdt_en_control_r
           | db_active
       ); 

  end
  `MWDT_PERIOD:
  begin
    csr_period_wen = csr_write & x2_pass;
          csr_period0_wen  = x2_pass & csr_write & wdt_index_sel[0] & (wdt_en_period_r
           | db_active
       );
  end
  `MWDT_LTHRESH:
  begin
    csr_lthresh_wen      = csr_write & x2_pass;
          csr_lthresh0_wen = x2_pass & csr_write & wdt_index_sel[0] & (wdt_en_lthresh_r
           | db_active
       );
  end
  `MWDT_UTHRESH:
  begin
    csr_uthresh_wen      = csr_write & x2_pass;
          csr_uthresh0_wen = x2_pass & csr_write & wdt_index_sel[0] & (wdt_en_uthresh_r
           | db_active
       );
  end
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue
  default: ;
// spyglass enable_block W193
  endcase
end

wire x2_index_write = csr_write & (csr_waddr == `MWDT_PASSWD) & |(csr_wdata[`WDT_PASSWD_TN] ^ wdt_index_r);
wire x1_rd_csr = 1'b0 |
                 (csr_sel_addr == `MWDT_CTRL) | 
                 (csr_sel_addr == `MWDT_PERIOD) | 
                 (csr_sel_addr == `MWDT_COUNT) | 
                 (csr_sel_addr == `MWDT_LTHRESH) | 
                 (csr_sel_addr == `MWDT_UTHRESH)
                 ;
assign csr_raw_hazard = x2_index_write & x1_rd_csr;


endmodule // arcv_watchdog_csr
