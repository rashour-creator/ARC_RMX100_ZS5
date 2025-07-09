// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1995-2011 ARC International (Unpublished)
// All Rights Reserved.
//
// This document, material and/or software contains confidential
// and proprietary information of ARC International and is
// protected by copyright, trade secret and other state, federal,
// and international laws, and may be embodied in patents issued
// or pending.  Its receipt or possession does not convey any
// rights to use, reproduce, disclose its contents, or to
// manufacture, or sell anything it may describe.  Reverse
// engineering is prohibited, and reproduction, disclosure or use
// without specific written authorization of ARC International is
// strictly forbidden.  ARC and the ARC logotype are trademarks of
// ARC International.
// 
// ARC Product:  @@PRODUCT_NAME@@ v@@VERSION_NUMBER@@
// File version: $Revision$
// ARC Chip ID:  0
//
// Description:
//
// ARCAngel pads placeholder.
// 


`define EXT_SMODE_RANGE 2:0


module io_pad_ring(
 
    input               eclk,         // xtal clock
 
    
    input               erst_n,       // reset
    output              orst_n,       // reset output
    input               clk,
    
    output              arc_wake_evt_a,
    output              arc_halt_req_a,
    output              arc_run_req_a,
    output              test_mode,
    output [7:0]        arcnum,
    input               arc_halt_ack,
    input               arc_run_ack,
    input               sys_halt_r,
    input               sys_sleep_r,
    input  [2:0]        sys_sleep_mode_r,
//    input               dbg_tf_r,
//    input               debug_reset,
    output              en,
    input               ejtag_tck,    // JTAG I/Os
    input               ejtag_trst_n,
    input               ejtag_tms,
    input               ejtag_tdi,
    output              ejtag_tdo,
    output              jtag_tck,     // JTAG chain to cores
    output              jtag_trst_n,
    output              jtag_tms,
    output              jtag_tdi,
    input               jtag_tdo,
    input               jtag_tdo_oe,
///    input               jtag_tdo_oe,


//

//


    output              ref_clk,    
    output              ref_clk2,    
    output              rst_a);

    reg rst_n_r; // sync the reset




   
    // clock and reset

 

`ifndef FPGA_MAP
    assign ref_clk = eclk;     
    assign ref_clk2 = eclk;     

    assign jtag_tck = ejtag_tck;

//Sync erst_n for FPGA implementation, Darcy
    //assign rst_a  = !erst_n;
    assign rst_a  = !rst_n_r;

    assign ref_clk = eclk;
    always @(posedge ref_clk or
             negedge erst_n)
      begin : rst_PROC
          if (!erst_n)
            rst_n_r <= 1'b0;
          else
            rst_n_r <= 1'b1;
      end


`else		 
    IBUFG u_clk_buf_inst(.I  ( eclk    ),
                         .O  ( ref_clk ));
    IBUFG u_clk2_buf_inst(.I  ( eclk    ),
                          .O  ( ref_clk2 ));
    IBUFG u_jtag_buf_inst(.I  ( ejtag_tck ),
                          .O  ( jtag_tck  ));
    BUFG u_rst_buf_inst(.I ( !erst_n ),
                        .O ( rst_a    ));
`endif
    assign orst_n = !rst_a;
    assign en = !(
                  sys_halt_r &&
                  1'b1);
    assign arcnum         = 0;
    assign test_mode      = 1'b0;
    assign arc_wake_evt_a = 1'b0;
    assign arc_halt_req_a = 1'b0;
    assign arc_run_req_a  = 1'b0;
    // JTAG interface
    assign jtag_trst_n = ejtag_trst_n;
///    assign ejtag_tdo   = jtag_tdo_oe ? jtag_tdo : 1'bz;
    assign ejtag_tdo   = jtag_tdo;
    assign jtag_tms    = ejtag_tms;
    assign jtag_tdi    = ejtag_tdi;




endmodule // alb_mss_anc_io_pad_ring
