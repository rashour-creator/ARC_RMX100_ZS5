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
`include "clint_defines.v"

// Set simulation timescale
//
`include "const.def"
`include "csr_defines.v"


`ifndef SYNTHESIS
`ifndef VERILATOR
`define SIMULATION
`endif
`endif


module arcv_imsic_clint  (
// @@@ temporary waive
// spyglass disable_block RegInputOutput-ML
// SMD: Port is not registered
// SJ : Intended as per the design

  ///////// control interface
  output reg                     irq_trap,   
//  output                         irq_mdel,   
  output reg [7:0]       irq_id,   
  output reg [7:0]       mtopi_iid_int,



  ////////// DMSI interface
 // input                          dmsi_clk,               // separate/independent clock for timers
 // input                          dmsi_rst_a,               // separate/independent clock for timers
  input                          dmsi_valid,
  input                          dmsi_domain,
// spyglass disable_block W240
// SMD: declared but not read
// SJ: Reserved for S-mode
  input  [`CNTXT_IDX_RANGE]      dmsi_context,
// spyglass enable_block W240
  input  [`EIID_IDX_RANGE]       dmsi_eiid,
  output                         dmsi_rdy,          // Data ready

  ////////// CSR interface
  input  [11:0]                  csr_raddr_r, // A is from 1 to 11
  input  [1:0]                   csr_clint_sel_ctl,    // CSR read request
  output                         csr_irq_unimpl,
  output reg                     csr_illegal,
  output reg [`DATA_RANGE]       csr_rdata,   // CSR read data
  input  [11:0]                  csr_waddr_r, // A is from 1 to 11
  input                          csr_wen_r,    // CSR write request
  input  [`DATA_RANGE]           csr_wdata_r, // CSR write data
  input                          csr_ren_r,
  input  [1:0]                   priv_level,
  input  [`DATA_RANGE]           miselect_r,
  input                          mireg_wen,
  output reg [`DATA_RANGE]       mireg_int,



  // core ctrl
  input                          mtvec_mode,
  input                          trap_ack, // core confirm irq is claimed and jump to vector table
  // major irq
  input                          high_prio_ras,
  input                          db_evt,
  input                          mtip_0,
  input                          msip_0,
  input                          irq_wdt,
  input                          cnt_overflow,
  input                          low_prio_ras,
`ifdef SIMULATION
  output reg [`DATA_RANGE]       mip_r,
  output reg [`DATA_RANGE]       mie_r,
`endif

  

  ////////// General input signals /////////////////////////////////////////////
  //
  input                          clk,                   // core clock signal
  input                          rst_a                  // reset signal

  ////////// Output interrpts /////////////////////////////////////////////
  //
//  output reg [NR_CORES-1:0]      irq_timer,
//  output [NR_CORES-1:0]          irq_sw
);

// @@@ these registers are only accessed in m mode.
// @@@ need to find a way to convey this information in the IBP interface
// @@@ and return a bus error should there be an attempt to acceess CLINT registers
// @@@ in u/s mode
reg dmsi_rdy_r;
assign dmsi_rdy = dmsi_rdy_r; // @@@ assert after reset

// Local declarations
//

reg [`DATA_RANGE] mtopi;
reg [`DATA_RANGE] mtopei;
reg [7:0] mtopi_irio;
reg [7:0] mtopi_irio_int;
reg [7:0] mtopi_iid;
reg [7:0] metopi_irio;
reg [7:0] metopi_iid;
reg [7:0] metopi_iid_tmp;
reg       core_csr_unimpl;



reg m_eidelivery_sel;
reg m_eithreshold_sel;
reg m_iprio0_sel;
reg m_iprio1_sel;
reg m_iprio2_sel;
reg m_iprio3_sel;
reg m_iprio4_sel;
reg m_iprio5_sel;
reg m_iprio6_sel;
reg m_iprio7_sel;
reg m_iprio8_sel;
reg m_iprio9_sel;
reg m_iprio10_sel;
reg m_iprio11_sel;
reg m_iprio12_sel;
reg m_iprio13_sel;
reg m_iprio14_sel;
reg m_iprio15_sel;
reg m_icsr_unimplemented;




reg             irq_trap_nxt;
reg [7:0]       irq_id_nxt;  

// iCSR

reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_eip_r;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_eip_nxt;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_eie_r;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_eie_nxt;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_eip_set;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_eip_clr;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_thd_mask;
reg m_eip_sel;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_thd_stk_r; // remember preempted pending irq (for nested vectored mode)
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_thd_stk_nxt;
reg [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_thd_stk_mask;
reg [`DATA_RANGE] m_thd_stk_top;
reg m_eie0_sel;
reg m_eip0_sel;
reg m_eie1_sel;
reg m_eip1_sel;


reg [`DATA_RANGE] m_eidelivery_r;
reg [`DATA_RANGE] m_eidelivery_nxt;
reg [`DATA_RANGE] m_eithreshold_r;
reg [`DATA_RANGE] m_eithreshold_nxt;













`ifndef SIMULATION
reg [`DATA_RANGE] mie_r;
`endif
reg [`DATA_RANGE] mie_nxt;
reg	mie_wen;
reg [`DATA_RANGE] mieh_r;
reg [`DATA_RANGE] mieh_nxt;
reg	mieh_wen;
`ifndef SIMULATION
reg [`DATA_RANGE] mip_r;
`endif
reg [`DATA_RANGE] mip_nxt;
reg	mip_wen;
reg [`DATA_RANGE] miph_r;
reg [`DATA_RANGE] miph_nxt;
reg	miph_wen;
reg [`DATA_RANGE] mtopei_r;
reg	mtopei_wen;
//reg [`DATA_RANGE] mtsp_r;
//reg	mtsp_wen;

wire [`DATA_RANGE]  csr_wa_data_r =         csr_wdata_r;
wire  csr_rd_r = (csr_clint_sel_ctl[0] == 1'b1);
wire  csr_wr_r = (csr_clint_sel_ctl[1] == 1'b1);

wire mtopei_ren =  (csr_raddr_r == `CSR_MTOPEI) & csr_rd_r;
//wire mireg_wen =  (csr_irq_waddr == `CSR_MIREG) & csr_irq_wr;

reg irq_trap_int;






assign csr_irq_unimpl = 1'b0
                   | core_csr_unimpl
                   ;
///////////////////////////////////
//
// dmsi cdc fifo
//
// to be done in IO module


//////////////////////////////////////////////////////////////////////////////////////////
// 
// IMSIC interface
//
///////////////////////////////////////////////////////////////////////////////////////////


// eip set/clr
// spyglass disable_block ImproperRangeIndex-ML
// SMD: Index of width '8' can have max value '255' which is greater than the required max value of the signal
// SJ: When interrupt number is 192 this is inevitable, but this is safe because the max value is restricted from upper stream

always @*
begin : imsic_files_PROC

m_eip_set = `RTIA_IMSIC_M_FILE_SIZE'd0;
m_eip_clr = `RTIA_IMSIC_M_FILE_SIZE'd0;

if (dmsi_valid) begin
  if (dmsi_domain == 1'b0) begin
    m_eip_set[dmsi_eiid[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
  end 

end
///// nested vectored
if (mtvec_mode) begin
   if (|({mip_r[31:12],mip_r[10:0]} & {mie_r[31:12],mie_r[10:0]} 
       )) begin
    m_eip_set[mtopi_irio[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
  end 
end


// for higher 32 bit 
if (mtvec_mode) begin
  if (|(miph_r & mieh_r 
      )) begin
    m_eip_set[mtopi_irio[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
  end 
end





//clr
 if (mtvec_mode) begin
   if (trap_ack & irq_trap)
   m_eip_clr[metopi_iid[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
 
 end

                   
if (mtopei_wen & csr_ren_r  // way1: atomic csrrw read and write to clear eip
//& ~mtvec_mode // in nested mode, it's still a way for software to clear and claim the irq
) begin 
 
   m_eip_clr[csr_wdata_r[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;

end
if (mtopei_wen & ~csr_ren_r
    & ~mtvec_mode
) begin  // way2: csr write to clear top id
   m_eip_clr[metopi_iid[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
end



end // imsic_files_PROC


// spyglass enable_block ImproperRangeIndex-ML
// spyglass disable_block W263
always @*
begin : imsic_thd_PROC
m_thd_mask = {`RTIA_IMSIC_M_FILE_SIZE{1'b1}};
m_thd_stk_mask = {`RTIA_IMSIC_M_FILE_SIZE{1'b1}};
  case (m_eithreshold_r[7:0])
  8'd0: m_thd_mask = {`RTIA_IMSIC_M_FILE_SIZE{1'b1}};
  8'd1:  m_thd_mask = {{63{1'b0}},{1{1'b1}}};
  8'd2:  m_thd_mask = {{62{1'b0}},{2{1'b1}}};
  8'd3:  m_thd_mask = {{61{1'b0}},{3{1'b1}}};
  8'd4:  m_thd_mask = {{60{1'b0}},{4{1'b1}}};
  8'd5:  m_thd_mask = {{59{1'b0}},{5{1'b1}}};
  8'd6:  m_thd_mask = {{58{1'b0}},{6{1'b1}}};
  8'd7:  m_thd_mask = {{57{1'b0}},{7{1'b1}}};
  8'd8:  m_thd_mask = {{56{1'b0}},{8{1'b1}}};
  8'd9:  m_thd_mask = {{55{1'b0}},{9{1'b1}}};
  8'd10:  m_thd_mask = {{54{1'b0}},{10{1'b1}}};
  8'd11:  m_thd_mask = {{53{1'b0}},{11{1'b1}}};
  8'd12:  m_thd_mask = {{52{1'b0}},{12{1'b1}}};
  8'd13:  m_thd_mask = {{51{1'b0}},{13{1'b1}}};
  8'd14:  m_thd_mask = {{50{1'b0}},{14{1'b1}}};
  8'd15:  m_thd_mask = {{49{1'b0}},{15{1'b1}}};
  8'd16:  m_thd_mask = {{48{1'b0}},{16{1'b1}}};
  8'd17:  m_thd_mask = {{47{1'b0}},{17{1'b1}}};
  8'd18:  m_thd_mask = {{46{1'b0}},{18{1'b1}}};
  8'd19:  m_thd_mask = {{45{1'b0}},{19{1'b1}}};
  8'd20:  m_thd_mask = {{44{1'b0}},{20{1'b1}}};
  8'd21:  m_thd_mask = {{43{1'b0}},{21{1'b1}}};
  8'd22:  m_thd_mask = {{42{1'b0}},{22{1'b1}}};
  8'd23:  m_thd_mask = {{41{1'b0}},{23{1'b1}}};
  8'd24:  m_thd_mask = {{40{1'b0}},{24{1'b1}}};
  8'd25:  m_thd_mask = {{39{1'b0}},{25{1'b1}}};
  8'd26:  m_thd_mask = {{38{1'b0}},{26{1'b1}}};
  8'd27:  m_thd_mask = {{37{1'b0}},{27{1'b1}}};
  8'd28:  m_thd_mask = {{36{1'b0}},{28{1'b1}}};
  8'd29:  m_thd_mask = {{35{1'b0}},{29{1'b1}}};
  8'd30:  m_thd_mask = {{34{1'b0}},{30{1'b1}}};
  8'd31:  m_thd_mask = {{33{1'b0}},{31{1'b1}}};
  8'd32:  m_thd_mask = {{32{1'b0}},{32{1'b1}}};
  8'd33:  m_thd_mask = {{31{1'b0}},{33{1'b1}}};
  8'd34:  m_thd_mask = {{30{1'b0}},{34{1'b1}}};
  8'd35:  m_thd_mask = {{29{1'b0}},{35{1'b1}}};
  8'd36:  m_thd_mask = {{28{1'b0}},{36{1'b1}}};
  8'd37:  m_thd_mask = {{27{1'b0}},{37{1'b1}}};
  8'd38:  m_thd_mask = {{26{1'b0}},{38{1'b1}}};
  8'd39:  m_thd_mask = {{25{1'b0}},{39{1'b1}}};
  8'd40:  m_thd_mask = {{24{1'b0}},{40{1'b1}}};
  8'd41:  m_thd_mask = {{23{1'b0}},{41{1'b1}}};
  8'd42:  m_thd_mask = {{22{1'b0}},{42{1'b1}}};
  8'd43:  m_thd_mask = {{21{1'b0}},{43{1'b1}}};
  8'd44:  m_thd_mask = {{20{1'b0}},{44{1'b1}}};
  8'd45:  m_thd_mask = {{19{1'b0}},{45{1'b1}}};
  8'd46:  m_thd_mask = {{18{1'b0}},{46{1'b1}}};
  8'd47:  m_thd_mask = {{17{1'b0}},{47{1'b1}}};
  8'd48:  m_thd_mask = {{16{1'b0}},{48{1'b1}}};
  8'd49:  m_thd_mask = {{15{1'b0}},{49{1'b1}}};
  8'd50:  m_thd_mask = {{14{1'b0}},{50{1'b1}}};
  8'd51:  m_thd_mask = {{13{1'b0}},{51{1'b1}}};
  8'd52:  m_thd_mask = {{12{1'b0}},{52{1'b1}}};
  8'd53:  m_thd_mask = {{11{1'b0}},{53{1'b1}}};
  8'd54:  m_thd_mask = {{10{1'b0}},{54{1'b1}}};
  8'd55:  m_thd_mask = {{9{1'b0}},{55{1'b1}}};
  8'd56:  m_thd_mask = {{8{1'b0}},{56{1'b1}}};
  8'd57:  m_thd_mask = {{7{1'b0}},{57{1'b1}}};
  8'd58:  m_thd_mask = {{6{1'b0}},{58{1'b1}}};
  8'd59:  m_thd_mask = {{5{1'b0}},{59{1'b1}}};
  8'd60:  m_thd_mask = {{4{1'b0}},{60{1'b1}}};
  8'd61:  m_thd_mask = {{3{1'b0}},{61{1'b1}}};
  8'd62:  m_thd_mask = {{2{1'b0}},{62{1'b1}}};
  8'd63:  m_thd_mask = {{1{1'b0}},{63{1'b1}}};
  default: m_thd_mask = {`RTIA_IMSIC_M_FILE_SIZE{1'b1}};
  endcase
if (mtvec_mode) m_thd_mask = {`RTIA_IMSIC_M_FILE_SIZE{1'b1}};

  case (1'b1)
  m_thd_stk_r[0]: m_thd_stk_mask = {{64{1'b0}},{0{1'b1}}};
  m_thd_stk_r[1]: m_thd_stk_mask = {{63{1'b0}},{1{1'b1}}};
  m_thd_stk_r[2]: m_thd_stk_mask = {{62{1'b0}},{2{1'b1}}};
  m_thd_stk_r[3]: m_thd_stk_mask = {{61{1'b0}},{3{1'b1}}};
  m_thd_stk_r[4]: m_thd_stk_mask = {{60{1'b0}},{4{1'b1}}};
  m_thd_stk_r[5]: m_thd_stk_mask = {{59{1'b0}},{5{1'b1}}};
  m_thd_stk_r[6]: m_thd_stk_mask = {{58{1'b0}},{6{1'b1}}};
  m_thd_stk_r[7]: m_thd_stk_mask = {{57{1'b0}},{7{1'b1}}};
  m_thd_stk_r[8]: m_thd_stk_mask = {{56{1'b0}},{8{1'b1}}};
  m_thd_stk_r[9]: m_thd_stk_mask = {{55{1'b0}},{9{1'b1}}};
  m_thd_stk_r[10]: m_thd_stk_mask = {{54{1'b0}},{10{1'b1}}};
  m_thd_stk_r[11]: m_thd_stk_mask = {{53{1'b0}},{11{1'b1}}};
  m_thd_stk_r[12]: m_thd_stk_mask = {{52{1'b0}},{12{1'b1}}};
  m_thd_stk_r[13]: m_thd_stk_mask = {{51{1'b0}},{13{1'b1}}};
  m_thd_stk_r[14]: m_thd_stk_mask = {{50{1'b0}},{14{1'b1}}};
  m_thd_stk_r[15]: m_thd_stk_mask = {{49{1'b0}},{15{1'b1}}};
  m_thd_stk_r[16]: m_thd_stk_mask = {{48{1'b0}},{16{1'b1}}};
  m_thd_stk_r[17]: m_thd_stk_mask = {{47{1'b0}},{17{1'b1}}};
  m_thd_stk_r[18]: m_thd_stk_mask = {{46{1'b0}},{18{1'b1}}};
  m_thd_stk_r[19]: m_thd_stk_mask = {{45{1'b0}},{19{1'b1}}};
  m_thd_stk_r[20]: m_thd_stk_mask = {{44{1'b0}},{20{1'b1}}};
  m_thd_stk_r[21]: m_thd_stk_mask = {{43{1'b0}},{21{1'b1}}};
  m_thd_stk_r[22]: m_thd_stk_mask = {{42{1'b0}},{22{1'b1}}};
  m_thd_stk_r[23]: m_thd_stk_mask = {{41{1'b0}},{23{1'b1}}};
  m_thd_stk_r[24]: m_thd_stk_mask = {{40{1'b0}},{24{1'b1}}};
  m_thd_stk_r[25]: m_thd_stk_mask = {{39{1'b0}},{25{1'b1}}};
  m_thd_stk_r[26]: m_thd_stk_mask = {{38{1'b0}},{26{1'b1}}};
  m_thd_stk_r[27]: m_thd_stk_mask = {{37{1'b0}},{27{1'b1}}};
  m_thd_stk_r[28]: m_thd_stk_mask = {{36{1'b0}},{28{1'b1}}};
  m_thd_stk_r[29]: m_thd_stk_mask = {{35{1'b0}},{29{1'b1}}};
  m_thd_stk_r[30]: m_thd_stk_mask = {{34{1'b0}},{30{1'b1}}};
  m_thd_stk_r[31]: m_thd_stk_mask = {{33{1'b0}},{31{1'b1}}};
  m_thd_stk_r[32]: m_thd_stk_mask = {{32{1'b0}},{32{1'b1}}};
  m_thd_stk_r[33]: m_thd_stk_mask = {{31{1'b0}},{33{1'b1}}};
  m_thd_stk_r[34]: m_thd_stk_mask = {{30{1'b0}},{34{1'b1}}};
  m_thd_stk_r[35]: m_thd_stk_mask = {{29{1'b0}},{35{1'b1}}};
  m_thd_stk_r[36]: m_thd_stk_mask = {{28{1'b0}},{36{1'b1}}};
  m_thd_stk_r[37]: m_thd_stk_mask = {{27{1'b0}},{37{1'b1}}};
  m_thd_stk_r[38]: m_thd_stk_mask = {{26{1'b0}},{38{1'b1}}};
  m_thd_stk_r[39]: m_thd_stk_mask = {{25{1'b0}},{39{1'b1}}};
  m_thd_stk_r[40]: m_thd_stk_mask = {{24{1'b0}},{40{1'b1}}};
  m_thd_stk_r[41]: m_thd_stk_mask = {{23{1'b0}},{41{1'b1}}};
  m_thd_stk_r[42]: m_thd_stk_mask = {{22{1'b0}},{42{1'b1}}};
  m_thd_stk_r[43]: m_thd_stk_mask = {{21{1'b0}},{43{1'b1}}};
  m_thd_stk_r[44]: m_thd_stk_mask = {{20{1'b0}},{44{1'b1}}};
  m_thd_stk_r[45]: m_thd_stk_mask = {{19{1'b0}},{45{1'b1}}};
  m_thd_stk_r[46]: m_thd_stk_mask = {{18{1'b0}},{46{1'b1}}};
  m_thd_stk_r[47]: m_thd_stk_mask = {{17{1'b0}},{47{1'b1}}};
  m_thd_stk_r[48]: m_thd_stk_mask = {{16{1'b0}},{48{1'b1}}};
  m_thd_stk_r[49]: m_thd_stk_mask = {{15{1'b0}},{49{1'b1}}};
  m_thd_stk_r[50]: m_thd_stk_mask = {{14{1'b0}},{50{1'b1}}};
  m_thd_stk_r[51]: m_thd_stk_mask = {{13{1'b0}},{51{1'b1}}};
  m_thd_stk_r[52]: m_thd_stk_mask = {{12{1'b0}},{52{1'b1}}};
  m_thd_stk_r[53]: m_thd_stk_mask = {{11{1'b0}},{53{1'b1}}};
  m_thd_stk_r[54]: m_thd_stk_mask = {{10{1'b0}},{54{1'b1}}};
  m_thd_stk_r[55]: m_thd_stk_mask = {{9{1'b0}},{55{1'b1}}};
  m_thd_stk_r[56]: m_thd_stk_mask = {{8{1'b0}},{56{1'b1}}};
  m_thd_stk_r[57]: m_thd_stk_mask = {{7{1'b0}},{57{1'b1}}};
  m_thd_stk_r[58]: m_thd_stk_mask = {{6{1'b0}},{58{1'b1}}};
  m_thd_stk_r[59]: m_thd_stk_mask = {{5{1'b0}},{59{1'b1}}};
  m_thd_stk_r[60]: m_thd_stk_mask = {{4{1'b0}},{60{1'b1}}};
  m_thd_stk_r[61]: m_thd_stk_mask = {{3{1'b0}},{61{1'b1}}};
  m_thd_stk_r[62]: m_thd_stk_mask = {{2{1'b0}},{62{1'b1}}};
  m_thd_stk_r[63]: m_thd_stk_mask = {{1{1'b0}},{63{1'b1}}};
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue. Added 20240201 for lint.
    default: ; // return a bus error?
// spyglass enable_block W193
  endcase


end // imsic_thd_PROC
// spyglass enable_block W263

wire [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_active_pending = m_eip_r
                                                    & m_eie_r 
                                                    & m_thd_mask
                                                    & m_thd_stk_mask
                                                    ;
wire [`RTIA_IMSIC_M_FILE_SIZE-1:0] m_static_pending = m_eip_r
                                                    & m_eie_r
                                                    ;

always @*
begin
metopi_irio = 8'd0;
metopi_iid = 8'd0;
metopi_iid_tmp = 8'd0;
mtopei = 32'd0;

  case (1'b1)
  m_active_pending[0]: metopi_iid = 0;
  m_active_pending[1]: metopi_iid = 1;
  m_active_pending[2]: metopi_iid = 2;
  m_active_pending[3]: metopi_iid = 3;
  m_active_pending[4]: metopi_iid = 4;
  m_active_pending[5]: metopi_iid = 5;
  m_active_pending[6]: metopi_iid = 6;
  m_active_pending[7]: metopi_iid = 7;
  m_active_pending[8]: metopi_iid = 8;
  m_active_pending[9]: metopi_iid = 9;
  m_active_pending[10]: metopi_iid = 10;
  m_active_pending[11]: metopi_iid = 11;
  m_active_pending[12]: metopi_iid = 12;
  m_active_pending[13]: metopi_iid = 13;
  m_active_pending[14]: metopi_iid = 14;
  m_active_pending[15]: metopi_iid = 15;
  m_active_pending[16]: metopi_iid = 16;
  m_active_pending[17]: metopi_iid = 17;
  m_active_pending[18]: metopi_iid = 18;
  m_active_pending[19]: metopi_iid = 19;
  m_active_pending[20]: metopi_iid = 20;
  m_active_pending[21]: metopi_iid = 21;
  m_active_pending[22]: metopi_iid = 22;
  m_active_pending[23]: metopi_iid = 23;
  m_active_pending[24]: metopi_iid = 24;
  m_active_pending[25]: metopi_iid = 25;
  m_active_pending[26]: metopi_iid = 26;
  m_active_pending[27]: metopi_iid = 27;
  m_active_pending[28]: metopi_iid = 28;
  m_active_pending[29]: metopi_iid = 29;
  m_active_pending[30]: metopi_iid = 30;
  m_active_pending[31]: metopi_iid = 31;
  m_active_pending[32]: metopi_iid = 32;
  m_active_pending[33]: metopi_iid = 33;
  m_active_pending[34]: metopi_iid = 34;
  m_active_pending[35]: metopi_iid = 35;
  m_active_pending[36]: metopi_iid = 36;
  m_active_pending[37]: metopi_iid = 37;
  m_active_pending[38]: metopi_iid = 38;
  m_active_pending[39]: metopi_iid = 39;
  m_active_pending[40]: metopi_iid = 40;
  m_active_pending[41]: metopi_iid = 41;
  m_active_pending[42]: metopi_iid = 42;
  m_active_pending[43]: metopi_iid = 43;
  m_active_pending[44]: metopi_iid = 44;
  m_active_pending[45]: metopi_iid = 45;
  m_active_pending[46]: metopi_iid = 46;
  m_active_pending[47]: metopi_iid = 47;
  m_active_pending[48]: metopi_iid = 48;
  m_active_pending[49]: metopi_iid = 49;
  m_active_pending[50]: metopi_iid = 50;
  m_active_pending[51]: metopi_iid = 51;
  m_active_pending[52]: metopi_iid = 52;
  m_active_pending[53]: metopi_iid = 53;
  m_active_pending[54]: metopi_iid = 54;
  m_active_pending[55]: metopi_iid = 55;
  m_active_pending[56]: metopi_iid = 56;
  m_active_pending[57]: metopi_iid = 57;
  m_active_pending[58]: metopi_iid = 58;
  m_active_pending[59]: metopi_iid = 59;
  m_active_pending[60]: metopi_iid = 60;
  m_active_pending[61]: metopi_iid = 61;
  m_active_pending[62]: metopi_iid = 62;
  m_active_pending[63]: metopi_iid = 63;
    default:
    begin
        metopi_iid = 8'd0;
    end
  endcase
  case (1'b1)
  m_static_pending[0]: metopi_iid_tmp = 0;
  m_static_pending[1]: metopi_iid_tmp = 1;
  m_static_pending[2]: metopi_iid_tmp = 2;
  m_static_pending[3]: metopi_iid_tmp = 3;
  m_static_pending[4]: metopi_iid_tmp = 4;
  m_static_pending[5]: metopi_iid_tmp = 5;
  m_static_pending[6]: metopi_iid_tmp = 6;
  m_static_pending[7]: metopi_iid_tmp = 7;
  m_static_pending[8]: metopi_iid_tmp = 8;
  m_static_pending[9]: metopi_iid_tmp = 9;
  m_static_pending[10]: metopi_iid_tmp = 10;
  m_static_pending[11]: metopi_iid_tmp = 11;
  m_static_pending[12]: metopi_iid_tmp = 12;
  m_static_pending[13]: metopi_iid_tmp = 13;
  m_static_pending[14]: metopi_iid_tmp = 14;
  m_static_pending[15]: metopi_iid_tmp = 15;
  m_static_pending[16]: metopi_iid_tmp = 16;
  m_static_pending[17]: metopi_iid_tmp = 17;
  m_static_pending[18]: metopi_iid_tmp = 18;
  m_static_pending[19]: metopi_iid_tmp = 19;
  m_static_pending[20]: metopi_iid_tmp = 20;
  m_static_pending[21]: metopi_iid_tmp = 21;
  m_static_pending[22]: metopi_iid_tmp = 22;
  m_static_pending[23]: metopi_iid_tmp = 23;
  m_static_pending[24]: metopi_iid_tmp = 24;
  m_static_pending[25]: metopi_iid_tmp = 25;
  m_static_pending[26]: metopi_iid_tmp = 26;
  m_static_pending[27]: metopi_iid_tmp = 27;
  m_static_pending[28]: metopi_iid_tmp = 28;
  m_static_pending[29]: metopi_iid_tmp = 29;
  m_static_pending[30]: metopi_iid_tmp = 30;
  m_static_pending[31]: metopi_iid_tmp = 31;
  m_static_pending[32]: metopi_iid_tmp = 32;
  m_static_pending[33]: metopi_iid_tmp = 33;
  m_static_pending[34]: metopi_iid_tmp = 34;
  m_static_pending[35]: metopi_iid_tmp = 35;
  m_static_pending[36]: metopi_iid_tmp = 36;
  m_static_pending[37]: metopi_iid_tmp = 37;
  m_static_pending[38]: metopi_iid_tmp = 38;
  m_static_pending[39]: metopi_iid_tmp = 39;
  m_static_pending[40]: metopi_iid_tmp = 40;
  m_static_pending[41]: metopi_iid_tmp = 41;
  m_static_pending[42]: metopi_iid_tmp = 42;
  m_static_pending[43]: metopi_iid_tmp = 43;
  m_static_pending[44]: metopi_iid_tmp = 44;
  m_static_pending[45]: metopi_iid_tmp = 45;
  m_static_pending[46]: metopi_iid_tmp = 46;
  m_static_pending[47]: metopi_iid_tmp = 47;
  m_static_pending[48]: metopi_iid_tmp = 48;
  m_static_pending[49]: metopi_iid_tmp = 49;
  m_static_pending[50]: metopi_iid_tmp = 50;
  m_static_pending[51]: metopi_iid_tmp = 51;
  m_static_pending[52]: metopi_iid_tmp = 52;
  m_static_pending[53]: metopi_iid_tmp = 53;
  m_static_pending[54]: metopi_iid_tmp = 54;
  m_static_pending[55]: metopi_iid_tmp = 55;
  m_static_pending[56]: metopi_iid_tmp = 56;
  m_static_pending[57]: metopi_iid_tmp = 57;
  m_static_pending[58]: metopi_iid_tmp = 58;
  m_static_pending[59]: metopi_iid_tmp = 59;
  m_static_pending[60]: metopi_iid_tmp = 60;
  m_static_pending[61]: metopi_iid_tmp = 61;
  m_static_pending[62]: metopi_iid_tmp = 62;
  m_static_pending[63]: metopi_iid_tmp = 63;
    default:
    begin
        metopi_iid_tmp = 8'd0;
    end
  endcase
metopi_irio = metopi_iid;
if (mtvec_mode) 
    mtopei = {8'd0,metopi_iid_tmp,8'd0,metopi_iid_tmp};
else
    mtopei = {8'd0,metopi_iid,8'd0,metopi_irio};


end 


////////////////////////////////////////////////
//
// iCSR
//
////////////////////////////////////////////////



// ?? priority logic, congfigured and arbitrate 
// ?? clr mip bit, how to clear the irq source

reg [`DATA_RANGE] m_iprio0_r;            
reg [`DATA_RANGE] m_iprio0_nxt;            
reg [`DATA_RANGE] m_iprio1_r;            
reg [`DATA_RANGE] m_iprio1_nxt;            
reg [`DATA_RANGE] m_iprio2_r;            
reg [`DATA_RANGE] m_iprio2_nxt;            
reg [`DATA_RANGE] m_iprio3_r;            
reg [`DATA_RANGE] m_iprio3_nxt;            
reg [`DATA_RANGE] m_iprio4_r;            
reg [`DATA_RANGE] m_iprio4_nxt;            
reg [`DATA_RANGE] m_iprio5_r;            
reg [`DATA_RANGE] m_iprio5_nxt;            
reg [`DATA_RANGE] m_iprio6_r;            
reg [`DATA_RANGE] m_iprio6_nxt;            
reg [`DATA_RANGE] m_iprio7_r;            
reg [`DATA_RANGE] m_iprio7_nxt;            
reg [`DATA_RANGE] m_iprio8_r;            
reg [`DATA_RANGE] m_iprio8_nxt;            
reg [`DATA_RANGE] m_iprio9_r;            
reg [`DATA_RANGE] m_iprio9_nxt;            
reg [`DATA_RANGE] m_iprio10_r;            
reg [`DATA_RANGE] m_iprio10_nxt;            
reg [`DATA_RANGE] m_iprio11_r;            
reg [`DATA_RANGE] m_iprio11_nxt;            
reg [`DATA_RANGE] m_iprio12_r;            
reg [`DATA_RANGE] m_iprio12_nxt;            
reg [`DATA_RANGE] m_iprio13_r;            
reg [`DATA_RANGE] m_iprio13_nxt;            
reg [`DATA_RANGE] m_iprio14_r;            
reg [`DATA_RANGE] m_iprio14_nxt;            
reg [`DATA_RANGE] m_iprio15_r;            
reg [`DATA_RANGE] m_iprio15_nxt;            


always @*
begin
 m_eidelivery_sel = 1'b0;
 m_eithreshold_sel = 1'b0;
 m_iprio0_sel = 1'b0;
 m_iprio1_sel = 1'b0;
 m_iprio2_sel = 1'b0;
 m_iprio3_sel = 1'b0;
 m_iprio4_sel = 1'b0;
 m_iprio5_sel = 1'b0;
 m_iprio6_sel = 1'b0;
 m_iprio7_sel = 1'b0;
 m_iprio8_sel = 1'b0;
 m_iprio9_sel = 1'b0;
 m_iprio10_sel = 1'b0;
 m_iprio11_sel = 1'b0;
 m_iprio12_sel = 1'b0;
 m_iprio13_sel = 1'b0;
 m_iprio14_sel = 1'b0;
 m_iprio15_sel = 1'b0;
 m_eip0_sel = 1'b0;
 m_eip1_sel = 1'b0;
 m_eie0_sel = 1'b0;
 m_eie1_sel = 1'b0;
 m_icsr_unimplemented = 1'b0;
  case (miselect_r[7:0])
 8'h30: m_iprio0_sel = 1'b1;
 8'h31: m_iprio1_sel = 1'b1;
 8'h32: m_iprio2_sel = 1'b1;
 8'h33: m_iprio3_sel = 1'b1;
 8'h34: m_iprio4_sel = 1'b1;
 8'h35: m_iprio5_sel = 1'b1;
 8'h36: m_iprio6_sel = 1'b1;
 8'h37: m_iprio7_sel = 1'b1;
 8'h38: m_iprio8_sel = 1'b1;
 8'h39: m_iprio9_sel = 1'b1;
 8'h3a: m_iprio10_sel = 1'b1;
 8'h3b: m_iprio11_sel = 1'b1;
 8'h3c: m_iprio12_sel = 1'b1;
 8'h3d: m_iprio13_sel = 1'b1;
 8'h3e: m_iprio14_sel = 1'b1;
 8'h3f: m_iprio15_sel = 1'b1;
  8'h70: m_eidelivery_sel = 1'b1;
  8'h71: m_eithreshold_sel = 1'b0;
  8'h72: m_eithreshold_sel = 1'b1;
   8'h73: m_eithreshold_sel = 1'b0;
   8'h74: m_eithreshold_sel = 1'b0;
   8'h75: m_eithreshold_sel = 1'b0;
   8'h76: m_eithreshold_sel = 1'b0;
   8'h77: m_eithreshold_sel = 1'b0;
   8'h78: m_eithreshold_sel = 1'b0;
   8'h79: m_eithreshold_sel = 1'b0;
   8'h7a: m_eithreshold_sel = 1'b0;
   8'h7b: m_eithreshold_sel = 1'b0;
   8'h7c: m_eithreshold_sel = 1'b0;
   8'h7d: m_eithreshold_sel = 1'b0;
   8'h7e: m_eithreshold_sel = 1'b0;
   8'h7f: m_eithreshold_sel = 1'b0;

   8'h80: m_eip0_sel = 1'b1;
   8'h81: m_eip1_sel = 1'b1;
   8'hc0: m_eie0_sel = 1'b1;
   8'hc1: m_eie1_sel = 1'b1;
  default: m_icsr_unimplemented = 1'b1;
  endcase

m_eip_sel = 1'b0
          | m_eip0_sel
          | m_eip1_sel
          ;

// indirect write
m_eidelivery_nxt = m_eidelivery_r;
m_eithreshold_nxt = m_eithreshold_r;
m_eie_nxt[31:0] = m_eie_r[31:0];
m_eip_nxt[31:0] = m_eip_r[31:0];
m_eie_nxt[63:32] = m_eie_r[63:32];
m_eip_nxt[63:32] = m_eip_r[63:32];
m_iprio0_nxt = m_iprio0_r;           
m_iprio1_nxt = m_iprio1_r;           
m_iprio2_nxt = m_iprio2_r;           
m_iprio3_nxt = m_iprio3_r;           
m_iprio4_nxt = m_iprio4_r;           
m_iprio5_nxt = m_iprio5_r;           
m_iprio6_nxt = m_iprio6_r;           
m_iprio7_nxt = m_iprio7_r;           
m_iprio8_nxt = m_iprio8_r;           
m_iprio9_nxt = m_iprio9_r;           
m_iprio10_nxt = m_iprio10_r;           
m_iprio11_nxt = m_iprio11_r;           
m_iprio12_nxt = m_iprio12_r;           
m_iprio13_nxt = m_iprio13_r;           
m_iprio14_nxt = m_iprio14_r;           
m_iprio15_nxt = m_iprio15_r;           



//@@@ icsr dmsi set same time?
m_eip_nxt[0] = 1'b0;
// spyglass disable_block CDC_COHERENCY_RECONV_COMB
// SMD: Source signals from same domain converge after synchronization
// SJ: There is no dependency between these source signals
m_eip_nxt[1] = m_eip_clr[1] ^ m_eip_set[1]
              ? (m_eip_clr[1] 
              ? 1'b0 : 1'b1)
              : m_eip_r[1]
              ;
m_eip_nxt[2] = m_eip_clr[2] ^ m_eip_set[2]
              ? (m_eip_clr[2] 
              ? 1'b0 : 1'b1)
              : m_eip_r[2]
              ;
m_eip_nxt[3] = m_eip_clr[3] ^ m_eip_set[3]
              ? (m_eip_clr[3] 
              ? 1'b0 : 1'b1)
              : m_eip_r[3]
              ;
m_eip_nxt[4] = m_eip_clr[4] ^ m_eip_set[4]
              ? (m_eip_clr[4] 
              ? 1'b0 : 1'b1)
              : m_eip_r[4]
              ;
m_eip_nxt[5] = m_eip_clr[5] ^ m_eip_set[5]
              ? (m_eip_clr[5] 
              ? 1'b0 : 1'b1)
              : m_eip_r[5]
              ;
m_eip_nxt[6] = m_eip_clr[6] ^ m_eip_set[6]
              ? (m_eip_clr[6] 
              ? 1'b0 : 1'b1)
              : m_eip_r[6]
              ;
m_eip_nxt[7] = m_eip_clr[7] ^ m_eip_set[7]
              ? (m_eip_clr[7] 
              ? 1'b0 : 1'b1)
              : m_eip_r[7]
              ;
m_eip_nxt[8] = m_eip_clr[8] ^ m_eip_set[8]
              ? (m_eip_clr[8] 
              ? 1'b0 : 1'b1)
              : m_eip_r[8]
              ;
m_eip_nxt[9] = m_eip_clr[9] ^ m_eip_set[9]
              ? (m_eip_clr[9] 
              ? 1'b0 : 1'b1)
              : m_eip_r[9]
              ;
m_eip_nxt[10] = m_eip_clr[10] ^ m_eip_set[10]
              ? (m_eip_clr[10] 
              ? 1'b0 : 1'b1)
              : m_eip_r[10]
              ;
m_eip_nxt[11] = m_eip_clr[11] ^ m_eip_set[11]
              ? (m_eip_clr[11] 
              ? 1'b0 : 1'b1)
              : m_eip_r[11]
              ;
m_eip_nxt[12] = m_eip_clr[12] ^ m_eip_set[12]
              ? (m_eip_clr[12] 
              ? 1'b0 : 1'b1)
              : m_eip_r[12]
              ;
m_eip_nxt[13] = m_eip_clr[13] ^ m_eip_set[13]
              ? (m_eip_clr[13] 
              ? 1'b0 : 1'b1)
              : m_eip_r[13]
              ;
m_eip_nxt[14] = m_eip_clr[14] ^ m_eip_set[14]
              ? (m_eip_clr[14] 
              ? 1'b0 : 1'b1)
              : m_eip_r[14]
              ;
m_eip_nxt[15] = m_eip_clr[15] ^ m_eip_set[15]
              ? (m_eip_clr[15] 
              ? 1'b0 : 1'b1)
              : m_eip_r[15]
              ;
m_eip_nxt[16] = m_eip_clr[16] ^ m_eip_set[16]
              ? (m_eip_clr[16] 
              ? 1'b0 : 1'b1)
              : m_eip_r[16]
              ;
m_eip_nxt[17] = m_eip_clr[17] ^ m_eip_set[17]
              ? (m_eip_clr[17] 
              ? 1'b0 : 1'b1)
              : m_eip_r[17]
              ;
m_eip_nxt[18] = m_eip_clr[18] ^ m_eip_set[18]
              ? (m_eip_clr[18] 
              ? 1'b0 : 1'b1)
              : m_eip_r[18]
              ;
m_eip_nxt[19] = m_eip_clr[19] ^ m_eip_set[19]
              ? (m_eip_clr[19] 
              ? 1'b0 : 1'b1)
              : m_eip_r[19]
              ;
m_eip_nxt[20] = m_eip_clr[20] ^ m_eip_set[20]
              ? (m_eip_clr[20] 
              ? 1'b0 : 1'b1)
              : m_eip_r[20]
              ;
m_eip_nxt[21] = m_eip_clr[21] ^ m_eip_set[21]
              ? (m_eip_clr[21] 
              ? 1'b0 : 1'b1)
              : m_eip_r[21]
              ;
m_eip_nxt[22] = m_eip_clr[22] ^ m_eip_set[22]
              ? (m_eip_clr[22] 
              ? 1'b0 : 1'b1)
              : m_eip_r[22]
              ;
m_eip_nxt[23] = m_eip_clr[23] ^ m_eip_set[23]
              ? (m_eip_clr[23] 
              ? 1'b0 : 1'b1)
              : m_eip_r[23]
              ;
m_eip_nxt[24] = m_eip_clr[24] ^ m_eip_set[24]
              ? (m_eip_clr[24] 
              ? 1'b0 : 1'b1)
              : m_eip_r[24]
              ;
m_eip_nxt[25] = m_eip_clr[25] ^ m_eip_set[25]
              ? (m_eip_clr[25] 
              ? 1'b0 : 1'b1)
              : m_eip_r[25]
              ;
m_eip_nxt[26] = m_eip_clr[26] ^ m_eip_set[26]
              ? (m_eip_clr[26] 
              ? 1'b0 : 1'b1)
              : m_eip_r[26]
              ;
m_eip_nxt[27] = m_eip_clr[27] ^ m_eip_set[27]
              ? (m_eip_clr[27] 
              ? 1'b0 : 1'b1)
              : m_eip_r[27]
              ;
m_eip_nxt[28] = m_eip_clr[28] ^ m_eip_set[28]
              ? (m_eip_clr[28] 
              ? 1'b0 : 1'b1)
              : m_eip_r[28]
              ;
m_eip_nxt[29] = m_eip_clr[29] ^ m_eip_set[29]
              ? (m_eip_clr[29] 
              ? 1'b0 : 1'b1)
              : m_eip_r[29]
              ;
m_eip_nxt[30] = m_eip_clr[30] ^ m_eip_set[30]
              ? (m_eip_clr[30] 
              ? 1'b0 : 1'b1)
              : m_eip_r[30]
              ;
m_eip_nxt[31] = m_eip_clr[31] ^ m_eip_set[31]
              ? (m_eip_clr[31] 
              ? 1'b0 : 1'b1)
              : m_eip_r[31]
              ;
m_eip_nxt[32] = m_eip_clr[32] ^ m_eip_set[32]
              ? (m_eip_clr[32] 
              ? 1'b0 : 1'b1)
              : m_eip_r[32]
              ;
m_eip_nxt[33] = m_eip_clr[33] ^ m_eip_set[33]
              ? (m_eip_clr[33] 
              ? 1'b0 : 1'b1)
              : m_eip_r[33]
              ;
m_eip_nxt[34] = m_eip_clr[34] ^ m_eip_set[34]
              ? (m_eip_clr[34] 
              ? 1'b0 : 1'b1)
              : m_eip_r[34]
              ;
m_eip_nxt[35] = m_eip_clr[35] ^ m_eip_set[35]
              ? (m_eip_clr[35] 
              ? 1'b0 : 1'b1)
              : m_eip_r[35]
              ;
m_eip_nxt[36] = m_eip_clr[36] ^ m_eip_set[36]
              ? (m_eip_clr[36] 
              ? 1'b0 : 1'b1)
              : m_eip_r[36]
              ;
m_eip_nxt[37] = m_eip_clr[37] ^ m_eip_set[37]
              ? (m_eip_clr[37] 
              ? 1'b0 : 1'b1)
              : m_eip_r[37]
              ;
m_eip_nxt[38] = m_eip_clr[38] ^ m_eip_set[38]
              ? (m_eip_clr[38] 
              ? 1'b0 : 1'b1)
              : m_eip_r[38]
              ;
m_eip_nxt[39] = m_eip_clr[39] ^ m_eip_set[39]
              ? (m_eip_clr[39] 
              ? 1'b0 : 1'b1)
              : m_eip_r[39]
              ;
m_eip_nxt[40] = m_eip_clr[40] ^ m_eip_set[40]
              ? (m_eip_clr[40] 
              ? 1'b0 : 1'b1)
              : m_eip_r[40]
              ;
m_eip_nxt[41] = m_eip_clr[41] ^ m_eip_set[41]
              ? (m_eip_clr[41] 
              ? 1'b0 : 1'b1)
              : m_eip_r[41]
              ;
m_eip_nxt[42] = m_eip_clr[42] ^ m_eip_set[42]
              ? (m_eip_clr[42] 
              ? 1'b0 : 1'b1)
              : m_eip_r[42]
              ;
m_eip_nxt[43] = m_eip_clr[43] ^ m_eip_set[43]
              ? (m_eip_clr[43] 
              ? 1'b0 : 1'b1)
              : m_eip_r[43]
              ;
m_eip_nxt[44] = m_eip_clr[44] ^ m_eip_set[44]
              ? (m_eip_clr[44] 
              ? 1'b0 : 1'b1)
              : m_eip_r[44]
              ;
m_eip_nxt[45] = m_eip_clr[45] ^ m_eip_set[45]
              ? (m_eip_clr[45] 
              ? 1'b0 : 1'b1)
              : m_eip_r[45]
              ;
m_eip_nxt[46] = m_eip_clr[46] ^ m_eip_set[46]
              ? (m_eip_clr[46] 
              ? 1'b0 : 1'b1)
              : m_eip_r[46]
              ;
m_eip_nxt[47] = m_eip_clr[47] ^ m_eip_set[47]
              ? (m_eip_clr[47] 
              ? 1'b0 : 1'b1)
              : m_eip_r[47]
              ;
m_eip_nxt[48] = m_eip_clr[48] ^ m_eip_set[48]
              ? (m_eip_clr[48] 
              ? 1'b0 : 1'b1)
              : m_eip_r[48]
              ;
m_eip_nxt[49] = m_eip_clr[49] ^ m_eip_set[49]
              ? (m_eip_clr[49] 
              ? 1'b0 : 1'b1)
              : m_eip_r[49]
              ;
m_eip_nxt[50] = m_eip_clr[50] ^ m_eip_set[50]
              ? (m_eip_clr[50] 
              ? 1'b0 : 1'b1)
              : m_eip_r[50]
              ;
m_eip_nxt[51] = m_eip_clr[51] ^ m_eip_set[51]
              ? (m_eip_clr[51] 
              ? 1'b0 : 1'b1)
              : m_eip_r[51]
              ;
m_eip_nxt[52] = m_eip_clr[52] ^ m_eip_set[52]
              ? (m_eip_clr[52] 
              ? 1'b0 : 1'b1)
              : m_eip_r[52]
              ;
m_eip_nxt[53] = m_eip_clr[53] ^ m_eip_set[53]
              ? (m_eip_clr[53] 
              ? 1'b0 : 1'b1)
              : m_eip_r[53]
              ;
m_eip_nxt[54] = m_eip_clr[54] ^ m_eip_set[54]
              ? (m_eip_clr[54] 
              ? 1'b0 : 1'b1)
              : m_eip_r[54]
              ;
m_eip_nxt[55] = m_eip_clr[55] ^ m_eip_set[55]
              ? (m_eip_clr[55] 
              ? 1'b0 : 1'b1)
              : m_eip_r[55]
              ;
m_eip_nxt[56] = m_eip_clr[56] ^ m_eip_set[56]
              ? (m_eip_clr[56] 
              ? 1'b0 : 1'b1)
              : m_eip_r[56]
              ;
m_eip_nxt[57] = m_eip_clr[57] ^ m_eip_set[57]
              ? (m_eip_clr[57] 
              ? 1'b0 : 1'b1)
              : m_eip_r[57]
              ;
m_eip_nxt[58] = m_eip_clr[58] ^ m_eip_set[58]
              ? (m_eip_clr[58] 
              ? 1'b0 : 1'b1)
              : m_eip_r[58]
              ;
m_eip_nxt[59] = m_eip_clr[59] ^ m_eip_set[59]
              ? (m_eip_clr[59] 
              ? 1'b0 : 1'b1)
              : m_eip_r[59]
              ;
m_eip_nxt[60] = m_eip_clr[60] ^ m_eip_set[60]
              ? (m_eip_clr[60] 
              ? 1'b0 : 1'b1)
              : m_eip_r[60]
              ;
m_eip_nxt[61] = m_eip_clr[61] ^ m_eip_set[61]
              ? (m_eip_clr[61] 
              ? 1'b0 : 1'b1)
              : m_eip_r[61]
              ;
m_eip_nxt[62] = m_eip_clr[62] ^ m_eip_set[62]
              ? (m_eip_clr[62] 
              ? 1'b0 : 1'b1)
              : m_eip_r[62]
              ;
m_eip_nxt[63] = m_eip_clr[63] ^ m_eip_set[63]
              ? (m_eip_clr[63] 
              ? 1'b0 : 1'b1)
              : m_eip_r[63]
              ;
// spyglass enable_block CDC_COHERENCY_RECONV_COMB




if (mireg_wen) begin

  if (m_eidelivery_sel) m_eidelivery_nxt = {1'b0,csr_wa_data_r[30:29],28'd0,csr_wa_data_r[0]};
  else if (m_eithreshold_sel) m_eithreshold_nxt[`RTIA_IMSIC_M_FILE_RANGE] = csr_wa_data_r[`RTIA_IMSIC_M_FILE_RANGE];
  else if (m_eie0_sel) 
  m_eie_nxt[31:0] = csr_wa_data_r;
  else if (m_eie1_sel) 
  m_eie_nxt[63:32] = csr_wa_data_r;
  else if (m_eip0_sel) 
  m_eip_nxt[31:0] = csr_wa_data_r;
  else if (m_eip1_sel) 
  m_eip_nxt[63:32] = csr_wa_data_r;

  m_eie_nxt[0] = 1'b0;
  m_eip_nxt[0] = 1'b0;
if (m_iprio10_sel) m_iprio10_nxt[`PRIO_QRANG3] = csr_wa_data_r[`PRIO_QRANG3];    
if (m_iprio4_sel) m_iprio4_nxt[`PRIO_QRANG1] = csr_wa_data_r[`PRIO_QRANG1];    
//if (m_iprio2_sel) m_iprio2_nxt = {csr_wa_data_r[31:24],24'd0};    
if (m_iprio0_sel) m_iprio0_nxt[`PRIO_QRANG3] = csr_wa_data_r[`PRIO_QRANG3];    
if (m_iprio1_sel) m_iprio1_nxt[`PRIO_QRANG3] = csr_wa_data_r[`PRIO_QRANG3];    
if (m_iprio3_sel) m_iprio3_nxt[`PRIO_QRANG1] = csr_wa_data_r[`PRIO_QRANG1];  
if (m_iprio8_sel) m_iprio8_nxt[`PRIO_QRANG3] = csr_wa_data_r[`PRIO_QRANG3];    
if (m_iprio4_sel) m_iprio4_nxt[`PRIO_QRANG1] = csr_wa_data_r[`PRIO_QRANG1];    
if (m_iprio12_sel) m_iprio12_nxt[`PRIO_QRANG0] = csr_wa_data_r[`PRIO_QRANG0];    

end

// indirect read
// will icsr read ipro?
mireg_int = 0;
  if (m_eidelivery_sel) mireg_int = m_eidelivery_r;
  else
      if (m_eithreshold_sel) begin 
    if (~mtvec_mode) mireg_int = m_eithreshold_r;
    else mireg_int = m_thd_stk_top;
  end
  else if (m_eie0_sel) 
  mireg_int = m_eie_r[31:0];
  else if (m_eie1_sel) 
  mireg_int = m_eie_r[63:32];
  else if (m_eip0_sel) 
  mireg_int = m_eip_r[31:0];
  else if (m_eip1_sel) 
  mireg_int = m_eip_r[63:32];
  else if (m_iprio0_sel) 
  mireg_int = m_iprio0_r;
  else if (m_iprio1_sel) 
  mireg_int = m_iprio1_r;
  else if (m_iprio2_sel) 
  mireg_int = m_iprio2_r;
  else if (m_iprio3_sel) 
  mireg_int = m_iprio3_r;
  else if (m_iprio4_sel) 
  mireg_int = m_iprio4_r;
  else if (m_iprio5_sel) 
  mireg_int = m_iprio5_r;
  else if (m_iprio6_sel) 
  mireg_int = m_iprio6_r;
  else if (m_iprio7_sel) 
  mireg_int = m_iprio7_r;
  else if (m_iprio8_sel) 
  mireg_int = m_iprio8_r;
  else if (m_iprio9_sel) 
  mireg_int = m_iprio9_r;
  else if (m_iprio10_sel) 
  mireg_int = m_iprio10_r;
  else if (m_iprio11_sel) 
  mireg_int = m_iprio11_r;
  else if (m_iprio12_sel) 
  mireg_int = m_iprio12_r;
  else if (m_iprio13_sel) 
  mireg_int = m_iprio13_r;
  else if (m_iprio14_sel) 
  mireg_int = m_iprio14_r;
  else if (m_iprio15_sel) 
  mireg_int = m_iprio15_r;

end

/////////////////////////////
//
// s mode copy



/////////////////////////////
//
// h mode copy






always @(posedge clk or posedge rst_a)
begin : imsic_file_prio_regs_PROC
  if (rst_a == 1'b1)
  begin
      m_eidelivery_r <= 0;
      m_eithreshold_r <= 0;

  end
  else
  begin
      m_eidelivery_r <= m_eidelivery_nxt;
      m_eithreshold_r <= m_eithreshold_nxt;
  end
end


// pending files


always @(posedge clk or posedge rst_a)
begin : imsic_file_regs_PROC
  integer i;
  if (rst_a == 1'b1)
  begin
      m_eip_r <= {`RTIA_IMSIC_M_FILE_SIZE{1'b0}};
      m_eie_r <= {`RTIA_IMSIC_M_FILE_SIZE{1'b0}};
      m_iprio0_r <= 32'd0;           
      m_iprio1_r <= 32'd0;           
      m_iprio2_r <= 32'd0;           
      m_iprio3_r <= 32'd0;           
      m_iprio4_r <= 32'd0;           
      m_iprio5_r <= 32'd0;           
      m_iprio6_r <= 32'd0;           
      m_iprio7_r <= 32'd0;           
      m_iprio8_r <= 32'd0;           
      m_iprio9_r <= 32'd0;           
      m_iprio10_r <= 32'd0;           
      m_iprio11_r <= 32'd0;           
      m_iprio12_r <= 32'd0;           
      m_iprio13_r <= 32'd0;           
      m_iprio14_r <= 32'd0;           
      m_iprio15_r <= 32'd0;           
      m_thd_stk_r <= {`RTIA_IMSIC_M_FILE_SIZE{1'b0}};
  end
  else
  begin
      m_eip_r <= m_eip_nxt;
      m_eie_r <= m_eie_nxt;
      m_iprio0_r <= m_iprio0_nxt;           
      m_iprio1_r <= m_iprio1_nxt;           
      m_iprio2_r <= m_iprio2_nxt;           
      m_iprio3_r <= m_iprio3_nxt;           
      m_iprio4_r <= m_iprio4_nxt;           
      m_iprio5_r <= m_iprio5_nxt;           
      m_iprio6_r <= m_iprio6_nxt;           
      m_iprio7_r <= m_iprio7_nxt;           
      m_iprio8_r <= m_iprio8_nxt;           
      m_iprio9_r <= m_iprio9_nxt;           
      m_iprio10_r <= m_iprio10_nxt;           
      m_iprio11_r <= m_iprio11_nxt;           
      m_iprio12_r <= m_iprio12_nxt;           
      m_iprio13_r <= m_iprio13_nxt;           
      m_iprio14_r <= m_iprio14_nxt;           
      m_iprio15_r <= m_iprio15_nxt;           
      m_thd_stk_r <= m_thd_stk_nxt;

  end
end


// config for iprio
// rtia_hart_major_prio  true/false
// rtia_hart_major_prio_width  6,7,8


// rtia_imsic_num_guests  2,4,8

//////////////////////////
//
// mip mie mideleg
always @*
begin
mip_nxt = mip_r;
miph_nxt = miph_r;
miph_nxt[11] = high_prio_ras | miph_r[11]; // sticky 
mip_nxt[17] = db_evt | mip_r[17]; // sticky 
mip_nxt[11] = |(m_active_pending
            & m_thd_stk_mask
) 
            & m_eidelivery_r[0]
; // meip
mip_nxt[3] = msip_0; // msip
mip_nxt[7] = mtip_0; // mtip
mip_nxt[13] = cnt_overflow | mip_r[13]; // 
miph_nxt[3] = low_prio_ras | miph_r[3];
miph_nxt[16] = irq_wdt; 




mie_nxt = mie_r;
mieh_nxt = mieh_r;



end


//Nested Vectored
//The TVEC field refers to the vector table, indexed by external interrupt identity number. 
//Each interrupt vector consists of a 4-byte address of interrupt handler. The entry with 
//index 0 refers to the exception traps handler.
// for EIID, how the handler aligned in address for m/s/vs ??? major number can distinguish the priviledge mode


reg [31:0] m_major_active;
reg [31:0] m_major_active_h;
reg [31:0] mip_set_done_r;
reg [31:0] mip_set_done_nxt;
reg [31:0] miph_set_done_r;
reg [31:0] miph_set_done_nxt;


reg m_irq_trap;
reg m_nested_irq_trap; 


always @*
begin
irq_trap_int = 1'd0;
m_major_active = mip_r & mie_r 
                            ;
m_major_active_h = miph_r & mieh_r
                            ;
m_irq_trap = |m_major_active
           | (|m_major_active_h)
           ;


m_nested_irq_trap = mip_nxt[11] & mie_r[11];


irq_trap_int = 
           (mtvec_mode) ? m_nested_irq_trap :
            m_irq_trap
            ; 

irq_trap_nxt = 1'd0;
irq_id_nxt = 8'd0;

case (1'b1)

irq_trap_int: begin
irq_trap_nxt = 1'b1;
irq_id_nxt = 
       mtvec_mode ? metopi_iid : 
       mtopi_iid; // select highest priority reslt from arbitration or EIID
end
default: begin
    irq_trap_nxt = 1'b0;
    irq_id_nxt = 8'b0;
end
endcase

end


always @(posedge clk or posedge rst_a)
begin 
  if (rst_a == 1'b1)
  begin
      irq_trap <= 1'b0;
      irq_id   <= 8'd0;
  end
  else
  begin
      irq_trap <= irq_trap_nxt 
      & {
                
        ~(mtvec_mode & trap_ack)
        } // force the request is single cycle to avoid the latency to clearing the pending
          // P10019796-76423
      ;
      irq_id   <= irq_id_nxt;

  end
  
end



//assign irq_id = 
//              mtvec_mode[1] ? metopi_iid : 
//              mtopi_iid; // select highest priority reslt from arbitration or EIID

//assign irq_mdel = ~|(mip_r & mie_r & ~mideleg_r);

//   inactive guest to trap irq
// @@@ hgeip needs to exclude vseip?


// @@@ different privilege level preempt control logic

// @@@ how the xie/xip/xideleg path pass through if global status.mie/sie is disabled.

// @@@ if running in m-mode, a vs-level or lower level irq set, and can be deleg, will the core switch to vs-mode or lower level?


// the m/s/vs_irq_trap cannot guarantee if the trap is accepted by the core.

/////////////////////
//
// irq threshold stack
//

//In Nested Vectored interrupt handling mode, the ARC-V processor supports a hardware stack of interrupt thresholds. 
//In this case the interrupt threshold value is automatically supplied by the IMSIC hardware. Every time the ARC-V processor jumps to an interrupt vector, 
//the threshold is automatically updated with the current interrupt priority, effectively masking lower-priority interrupts. 
//The software still have the possibility to set the external interrupt threshold by writing to the eithreshold iCSR. 
//The read access to the eithreshold iCSR triggers the threshold recovery - the current trheshold value is de-activated and previous 
//threshold value (if exists in hardware threshold stack) becomes active. The read access to the eithreshold iCSR shall be performed 
//by software when interrupt handling is completed to restore the interrupt threshold to its pre-interrupt state.


//It is not recommended to manipulate the interrupt threshold value from within the interrupt context, except during the interrupt completion procedure.

// spyglass disable_block ImproperRangeIndex-ML
// SMD: Index of width '8' can have max value '255' which is greater than the required max value of the signal
// SJ: When interrupt number is 192 this is inevitable, but this is safe because the max value is restricted from upper stre
always@*

begin
m_thd_stk_nxt = m_thd_stk_r;
if (irq_trap & trap_ack) begin
m_thd_stk_nxt[metopi_iid[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
end


if (m_eithreshold_sel & mireg_wen) begin //csr read in wa use addr from waddr

if (csr_wdata_r[`RTIA_IMSIC_M_FILE_RANGE] == 0)
begin
m_thd_stk_nxt[m_thd_stk_top[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b0;
end 
else begin
m_thd_stk_nxt[csr_wdata_r[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
end
end

if ((csr_waddr_r == `CSR_MTOPEI) & csr_wen_r & ~csr_ren_r) begin //csr read in wa use addr from waddr
if (csr_wdata_r == 0)
begin
m_thd_stk_nxt[m_thd_stk_top[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b0;
end 
end

// spyglass enable_block ImproperRangeIndex-ML

// in nested mode, csrrw perform one more step (step2), it behaves as hardware perform the interrupt claim
// 1.Clear the pending interrupt
// 2.update threshold
// if mtopei is 0, the stack will not be updated
// **** removed in latest trm
//if ((csr_waddr_r == `CSR_MTOPEI) & csr_wen_r & csr_ren_r & (csr_wdata_r != 0)) begin 
//m_thd_stk_nxt[metopi_iid[`RTIA_IMSIC_M_FILE_RANGE]] = 1'b1;
//end

if (~mtvec_mode) m_thd_stk_nxt = `RTIA_IMSIC_M_FILE_SIZE'd0;




end


always @*
begin
  m_thd_stk_top = `DATA_SIZE'd0;
  case (1'b1)
  m_thd_stk_r[0]: m_thd_stk_top = `DATA_SIZE'd0;
  m_thd_stk_r[1]: m_thd_stk_top = `DATA_SIZE'd1;
  m_thd_stk_r[2]: m_thd_stk_top = `DATA_SIZE'd2;
  m_thd_stk_r[3]: m_thd_stk_top = `DATA_SIZE'd3;
  m_thd_stk_r[4]: m_thd_stk_top = `DATA_SIZE'd4;
  m_thd_stk_r[5]: m_thd_stk_top = `DATA_SIZE'd5;
  m_thd_stk_r[6]: m_thd_stk_top = `DATA_SIZE'd6;
  m_thd_stk_r[7]: m_thd_stk_top = `DATA_SIZE'd7;
  m_thd_stk_r[8]: m_thd_stk_top = `DATA_SIZE'd8;
  m_thd_stk_r[9]: m_thd_stk_top = `DATA_SIZE'd9;
  m_thd_stk_r[10]: m_thd_stk_top = `DATA_SIZE'd10;
  m_thd_stk_r[11]: m_thd_stk_top = `DATA_SIZE'd11;
  m_thd_stk_r[12]: m_thd_stk_top = `DATA_SIZE'd12;
  m_thd_stk_r[13]: m_thd_stk_top = `DATA_SIZE'd13;
  m_thd_stk_r[14]: m_thd_stk_top = `DATA_SIZE'd14;
  m_thd_stk_r[15]: m_thd_stk_top = `DATA_SIZE'd15;
  m_thd_stk_r[16]: m_thd_stk_top = `DATA_SIZE'd16;
  m_thd_stk_r[17]: m_thd_stk_top = `DATA_SIZE'd17;
  m_thd_stk_r[18]: m_thd_stk_top = `DATA_SIZE'd18;
  m_thd_stk_r[19]: m_thd_stk_top = `DATA_SIZE'd19;
  m_thd_stk_r[20]: m_thd_stk_top = `DATA_SIZE'd20;
  m_thd_stk_r[21]: m_thd_stk_top = `DATA_SIZE'd21;
  m_thd_stk_r[22]: m_thd_stk_top = `DATA_SIZE'd22;
  m_thd_stk_r[23]: m_thd_stk_top = `DATA_SIZE'd23;
  m_thd_stk_r[24]: m_thd_stk_top = `DATA_SIZE'd24;
  m_thd_stk_r[25]: m_thd_stk_top = `DATA_SIZE'd25;
  m_thd_stk_r[26]: m_thd_stk_top = `DATA_SIZE'd26;
  m_thd_stk_r[27]: m_thd_stk_top = `DATA_SIZE'd27;
  m_thd_stk_r[28]: m_thd_stk_top = `DATA_SIZE'd28;
  m_thd_stk_r[29]: m_thd_stk_top = `DATA_SIZE'd29;
  m_thd_stk_r[30]: m_thd_stk_top = `DATA_SIZE'd30;
  m_thd_stk_r[31]: m_thd_stk_top = `DATA_SIZE'd31;
  m_thd_stk_r[32]: m_thd_stk_top = `DATA_SIZE'd32;
  m_thd_stk_r[33]: m_thd_stk_top = `DATA_SIZE'd33;
  m_thd_stk_r[34]: m_thd_stk_top = `DATA_SIZE'd34;
  m_thd_stk_r[35]: m_thd_stk_top = `DATA_SIZE'd35;
  m_thd_stk_r[36]: m_thd_stk_top = `DATA_SIZE'd36;
  m_thd_stk_r[37]: m_thd_stk_top = `DATA_SIZE'd37;
  m_thd_stk_r[38]: m_thd_stk_top = `DATA_SIZE'd38;
  m_thd_stk_r[39]: m_thd_stk_top = `DATA_SIZE'd39;
  m_thd_stk_r[40]: m_thd_stk_top = `DATA_SIZE'd40;
  m_thd_stk_r[41]: m_thd_stk_top = `DATA_SIZE'd41;
  m_thd_stk_r[42]: m_thd_stk_top = `DATA_SIZE'd42;
  m_thd_stk_r[43]: m_thd_stk_top = `DATA_SIZE'd43;
  m_thd_stk_r[44]: m_thd_stk_top = `DATA_SIZE'd44;
  m_thd_stk_r[45]: m_thd_stk_top = `DATA_SIZE'd45;
  m_thd_stk_r[46]: m_thd_stk_top = `DATA_SIZE'd46;
  m_thd_stk_r[47]: m_thd_stk_top = `DATA_SIZE'd47;
  m_thd_stk_r[48]: m_thd_stk_top = `DATA_SIZE'd48;
  m_thd_stk_r[49]: m_thd_stk_top = `DATA_SIZE'd49;
  m_thd_stk_r[50]: m_thd_stk_top = `DATA_SIZE'd50;
  m_thd_stk_r[51]: m_thd_stk_top = `DATA_SIZE'd51;
  m_thd_stk_r[52]: m_thd_stk_top = `DATA_SIZE'd52;
  m_thd_stk_r[53]: m_thd_stk_top = `DATA_SIZE'd53;
  m_thd_stk_r[54]: m_thd_stk_top = `DATA_SIZE'd54;
  m_thd_stk_r[55]: m_thd_stk_top = `DATA_SIZE'd55;
  m_thd_stk_r[56]: m_thd_stk_top = `DATA_SIZE'd56;
  m_thd_stk_r[57]: m_thd_stk_top = `DATA_SIZE'd57;
  m_thd_stk_r[58]: m_thd_stk_top = `DATA_SIZE'd58;
  m_thd_stk_r[59]: m_thd_stk_top = `DATA_SIZE'd59;
  m_thd_stk_r[60]: m_thd_stk_top = `DATA_SIZE'd60;
  m_thd_stk_r[61]: m_thd_stk_top = `DATA_SIZE'd61;
  m_thd_stk_r[62]: m_thd_stk_top = `DATA_SIZE'd62;
  m_thd_stk_r[63]: m_thd_stk_top = `DATA_SIZE'd63;
  endcase

end

/*
// Reading from the iCSR returns the currently active top-priority interrupt threshold and deactivates it, 
// while promoting the next highest priority threshold to the active state.
always @*
begin
m_thd_active = m_thd_stk_r;
m_thd_active[m_eithreshold_r[7:0]] = 1'b1;
  case (1'b1)
  m_thd_active[0]: m_thd_active_id = 0;
  m_thd_active[1]: m_thd_active_id = 1;
  m_thd_active[2]: m_thd_active_id = 2;
  m_thd_active[3]: m_thd_active_id = 3;
  m_thd_active[4]: m_thd_active_id = 4;
  m_thd_active[5]: m_thd_active_id = 5;
  m_thd_active[6]: m_thd_active_id = 6;
  m_thd_active[7]: m_thd_active_id = 7;
  m_thd_active[8]: m_thd_active_id = 8;
  m_thd_active[9]: m_thd_active_id = 9;
  m_thd_active[10]: m_thd_active_id = 10;
  m_thd_active[11]: m_thd_active_id = 11;
  m_thd_active[12]: m_thd_active_id = 12;
  m_thd_active[13]: m_thd_active_id = 13;
  m_thd_active[14]: m_thd_active_id = 14;
  m_thd_active[15]: m_thd_active_id = 15;
  m_thd_active[16]: m_thd_active_id = 16;
  m_thd_active[17]: m_thd_active_id = 17;
  m_thd_active[18]: m_thd_active_id = 18;
  m_thd_active[19]: m_thd_active_id = 19;
  m_thd_active[20]: m_thd_active_id = 20;
  m_thd_active[21]: m_thd_active_id = 21;
  m_thd_active[22]: m_thd_active_id = 22;
  m_thd_active[23]: m_thd_active_id = 23;
  m_thd_active[24]: m_thd_active_id = 24;
  m_thd_active[25]: m_thd_active_id = 25;
  m_thd_active[26]: m_thd_active_id = 26;
  m_thd_active[27]: m_thd_active_id = 27;
  m_thd_active[28]: m_thd_active_id = 28;
  m_thd_active[29]: m_thd_active_id = 29;
  m_thd_active[30]: m_thd_active_id = 30;
  m_thd_active[31]: m_thd_active_id = 31;
  m_thd_active[32]: m_thd_active_id = 32;
  m_thd_active[33]: m_thd_active_id = 33;
  m_thd_active[34]: m_thd_active_id = 34;
  m_thd_active[35]: m_thd_active_id = 35;
  m_thd_active[36]: m_thd_active_id = 36;
  m_thd_active[37]: m_thd_active_id = 37;
  m_thd_active[38]: m_thd_active_id = 38;
  m_thd_active[39]: m_thd_active_id = 39;
  m_thd_active[40]: m_thd_active_id = 40;
  m_thd_active[41]: m_thd_active_id = 41;
  m_thd_active[42]: m_thd_active_id = 42;
  m_thd_active[43]: m_thd_active_id = 43;
  m_thd_active[44]: m_thd_active_id = 44;
  m_thd_active[45]: m_thd_active_id = 45;
  m_thd_active[46]: m_thd_active_id = 46;
  m_thd_active[47]: m_thd_active_id = 47;
  m_thd_active[48]: m_thd_active_id = 48;
  m_thd_active[49]: m_thd_active_id = 49;
  m_thd_active[50]: m_thd_active_id = 50;
  m_thd_active[51]: m_thd_active_id = 51;
  m_thd_active[52]: m_thd_active_id = 52;
  m_thd_active[53]: m_thd_active_id = 53;
  m_thd_active[54]: m_thd_active_id = 54;
  m_thd_active[55]: m_thd_active_id = 55;
  m_thd_active[56]: m_thd_active_id = 56;
  m_thd_active[57]: m_thd_active_id = 57;
  m_thd_active[58]: m_thd_active_id = 58;
  m_thd_active[59]: m_thd_active_id = 59;
  m_thd_active[60]: m_thd_active_id = 60;
  m_thd_active[61]: m_thd_active_id = 61;
  m_thd_active[62]: m_thd_active_id = 62;
  m_thd_active[63]: m_thd_active_id = 63;
  endcase

end
*/


// set: a status bit to remember mip[x] pass to eip already
// clear: mip[x] set to 1
// mip_set_done_r

always @*
begin
mip_set_done_nxt = mip_set_done_r;
miph_set_done_nxt = miph_set_done_r;
if (m_major_active[0] & (mtopi_iid == 8'd0)) mip_set_done_nxt[0] = 1'b1;
else if (mip_set_done_r[0] & ~mip_r[0]) mip_set_done_nxt[0] = 1'b0;
if (m_major_active[1] & (mtopi_iid == 8'd1)) mip_set_done_nxt[1] = 1'b1;
else if (mip_set_done_r[1] & ~mip_r[1]) mip_set_done_nxt[1] = 1'b0;
if (m_major_active[2] & (mtopi_iid == 8'd2)) mip_set_done_nxt[2] = 1'b1;
else if (mip_set_done_r[2] & ~mip_r[2]) mip_set_done_nxt[2] = 1'b0;
if (m_major_active[3] & (mtopi_iid == 8'd3)) mip_set_done_nxt[3] = 1'b1;
else if (mip_set_done_r[3] & ~mip_r[3]) mip_set_done_nxt[3] = 1'b0;
if (m_major_active[4] & (mtopi_iid == 8'd4)) mip_set_done_nxt[4] = 1'b1;
else if (mip_set_done_r[4] & ~mip_r[4]) mip_set_done_nxt[4] = 1'b0;
if (m_major_active[5] & (mtopi_iid == 8'd5)) mip_set_done_nxt[5] = 1'b1;
else if (mip_set_done_r[5] & ~mip_r[5]) mip_set_done_nxt[5] = 1'b0;
if (m_major_active[6] & (mtopi_iid == 8'd6)) mip_set_done_nxt[6] = 1'b1;
else if (mip_set_done_r[6] & ~mip_r[6]) mip_set_done_nxt[6] = 1'b0;
if (m_major_active[7] & (mtopi_iid == 8'd7)) mip_set_done_nxt[7] = 1'b1;
else if (mip_set_done_r[7] & ~mip_r[7]) mip_set_done_nxt[7] = 1'b0;
if (m_major_active[8] & (mtopi_iid == 8'd8)) mip_set_done_nxt[8] = 1'b1;
else if (mip_set_done_r[8] & ~mip_r[8]) mip_set_done_nxt[8] = 1'b0;
if (m_major_active[9] & (mtopi_iid == 8'd9)) mip_set_done_nxt[9] = 1'b1;
else if (mip_set_done_r[9] & ~mip_r[9]) mip_set_done_nxt[9] = 1'b0;
if (m_major_active[10] & (mtopi_iid == 8'd10)) mip_set_done_nxt[10] = 1'b1;
else if (mip_set_done_r[10] & ~mip_r[10]) mip_set_done_nxt[10] = 1'b0;
if (m_major_active[12] & (mtopi_iid == 8'd12)) mip_set_done_nxt[12] = 1'b1;
else if (mip_set_done_r[12] & ~mip_r[12]) mip_set_done_nxt[12] = 1'b0;
if (m_major_active[13] & (mtopi_iid == 8'd13)) mip_set_done_nxt[13] = 1'b1;
else if (mip_set_done_r[13] & ~mip_r[13]) mip_set_done_nxt[13] = 1'b0;
if (m_major_active[14] & (mtopi_iid == 8'd14)) mip_set_done_nxt[14] = 1'b1;
else if (mip_set_done_r[14] & ~mip_r[14]) mip_set_done_nxt[14] = 1'b0;
if (m_major_active[15] & (mtopi_iid == 8'd15)) mip_set_done_nxt[15] = 1'b1;
else if (mip_set_done_r[15] & ~mip_r[15]) mip_set_done_nxt[15] = 1'b0;
if (m_major_active[16] & (mtopi_iid == 8'd16)) mip_set_done_nxt[16] = 1'b1;
else if (mip_set_done_r[16] & ~mip_r[16]) mip_set_done_nxt[16] = 1'b0;
if (m_major_active[17] & (mtopi_iid == 8'd17)) mip_set_done_nxt[17] = 1'b1;
else if (mip_set_done_r[17] & ~mip_r[17]) mip_set_done_nxt[17] = 1'b0;
if (m_major_active[18] & (mtopi_iid == 8'd18)) mip_set_done_nxt[18] = 1'b1;
else if (mip_set_done_r[18] & ~mip_r[18]) mip_set_done_nxt[18] = 1'b0;
if (m_major_active[19] & (mtopi_iid == 8'd19)) mip_set_done_nxt[19] = 1'b1;
else if (mip_set_done_r[19] & ~mip_r[19]) mip_set_done_nxt[19] = 1'b0;
if (m_major_active[20] & (mtopi_iid == 8'd20)) mip_set_done_nxt[20] = 1'b1;
else if (mip_set_done_r[20] & ~mip_r[20]) mip_set_done_nxt[20] = 1'b0;
if (m_major_active[21] & (mtopi_iid == 8'd21)) mip_set_done_nxt[21] = 1'b1;
else if (mip_set_done_r[21] & ~mip_r[21]) mip_set_done_nxt[21] = 1'b0;
if (m_major_active[22] & (mtopi_iid == 8'd22)) mip_set_done_nxt[22] = 1'b1;
else if (mip_set_done_r[22] & ~mip_r[22]) mip_set_done_nxt[22] = 1'b0;
if (m_major_active[23] & (mtopi_iid == 8'd23)) mip_set_done_nxt[23] = 1'b1;
else if (mip_set_done_r[23] & ~mip_r[23]) mip_set_done_nxt[23] = 1'b0;
if (m_major_active[24] & (mtopi_iid == 8'd24)) mip_set_done_nxt[24] = 1'b1;
else if (mip_set_done_r[24] & ~mip_r[24]) mip_set_done_nxt[24] = 1'b0;
if (m_major_active[25] & (mtopi_iid == 8'd25)) mip_set_done_nxt[25] = 1'b1;
else if (mip_set_done_r[25] & ~mip_r[25]) mip_set_done_nxt[25] = 1'b0;
if (m_major_active[26] & (mtopi_iid == 8'd26)) mip_set_done_nxt[26] = 1'b1;
else if (mip_set_done_r[26] & ~mip_r[26]) mip_set_done_nxt[26] = 1'b0;
if (m_major_active[27] & (mtopi_iid == 8'd27)) mip_set_done_nxt[27] = 1'b1;
else if (mip_set_done_r[27] & ~mip_r[27]) mip_set_done_nxt[27] = 1'b0;
if (m_major_active[28] & (mtopi_iid == 8'd28)) mip_set_done_nxt[28] = 1'b1;
else if (mip_set_done_r[28] & ~mip_r[28]) mip_set_done_nxt[28] = 1'b0;
if (m_major_active[29] & (mtopi_iid == 8'd29)) mip_set_done_nxt[29] = 1'b1;
else if (mip_set_done_r[29] & ~mip_r[29]) mip_set_done_nxt[29] = 1'b0;
if (m_major_active[30] & (mtopi_iid == 8'd30)) mip_set_done_nxt[30] = 1'b1;
else if (mip_set_done_r[30] & ~mip_r[30]) mip_set_done_nxt[30] = 1'b0;
if (m_major_active[31] & (mtopi_iid == 8'd31)) mip_set_done_nxt[31] = 1'b1;
else if (mip_set_done_r[31] & ~mip_r[31]) mip_set_done_nxt[31] = 1'b0;
if (m_major_active_h[0] & (mtopi_iid == 8'd32)) miph_set_done_nxt[0] = 1'b1;
else if (miph_set_done_r[0] & ~miph_r[0]) miph_set_done_nxt[0] = 1'b0;
if (m_major_active_h[1] & (mtopi_iid == 8'd33)) miph_set_done_nxt[1] = 1'b1;
else if (miph_set_done_r[1] & ~miph_r[1]) miph_set_done_nxt[1] = 1'b0;
if (m_major_active_h[2] & (mtopi_iid == 8'd34)) miph_set_done_nxt[2] = 1'b1;
else if (miph_set_done_r[2] & ~miph_r[2]) miph_set_done_nxt[2] = 1'b0;
if (m_major_active_h[3] & (mtopi_iid == 8'd35)) miph_set_done_nxt[3] = 1'b1;
else if (miph_set_done_r[3] & ~miph_r[3]) miph_set_done_nxt[3] = 1'b0;
if (m_major_active_h[4] & (mtopi_iid == 8'd36)) miph_set_done_nxt[4] = 1'b1;
else if (miph_set_done_r[4] & ~miph_r[4]) miph_set_done_nxt[4] = 1'b0;
if (m_major_active_h[5] & (mtopi_iid == 8'd37)) miph_set_done_nxt[5] = 1'b1;
else if (miph_set_done_r[5] & ~miph_r[5]) miph_set_done_nxt[5] = 1'b0;
if (m_major_active_h[6] & (mtopi_iid == 8'd38)) miph_set_done_nxt[6] = 1'b1;
else if (miph_set_done_r[6] & ~miph_r[6]) miph_set_done_nxt[6] = 1'b0;
if (m_major_active_h[7] & (mtopi_iid == 8'd39)) miph_set_done_nxt[7] = 1'b1;
else if (miph_set_done_r[7] & ~miph_r[7]) miph_set_done_nxt[7] = 1'b0;
if (m_major_active_h[8] & (mtopi_iid == 8'd40)) miph_set_done_nxt[8] = 1'b1;
else if (miph_set_done_r[8] & ~miph_r[8]) miph_set_done_nxt[8] = 1'b0;
if (m_major_active_h[9] & (mtopi_iid == 8'd41)) miph_set_done_nxt[9] = 1'b1;
else if (miph_set_done_r[9] & ~miph_r[9]) miph_set_done_nxt[9] = 1'b0;
if (m_major_active_h[10] & (mtopi_iid == 8'd42)) miph_set_done_nxt[10] = 1'b1;
else if (miph_set_done_r[10] & ~miph_r[10]) miph_set_done_nxt[10] = 1'b0;
if (m_major_active_h[11] & (mtopi_iid == 8'd43)) miph_set_done_nxt[11] = 1'b1;
else if (miph_set_done_r[11] & ~miph_r[11]) miph_set_done_nxt[11] = 1'b0;
if (m_major_active_h[12] & (mtopi_iid == 8'd44)) miph_set_done_nxt[12] = 1'b1;
else if (miph_set_done_r[12] & ~miph_r[12]) miph_set_done_nxt[12] = 1'b0;
if (m_major_active_h[13] & (mtopi_iid == 8'd45)) miph_set_done_nxt[13] = 1'b1;
else if (miph_set_done_r[13] & ~miph_r[13]) miph_set_done_nxt[13] = 1'b0;
if (m_major_active_h[14] & (mtopi_iid == 8'd46)) miph_set_done_nxt[14] = 1'b1;
else if (miph_set_done_r[14] & ~miph_r[14]) miph_set_done_nxt[14] = 1'b0;
if (m_major_active_h[15] & (mtopi_iid == 8'd47)) miph_set_done_nxt[15] = 1'b1;
else if (miph_set_done_r[15] & ~miph_r[15]) miph_set_done_nxt[15] = 1'b0;
if (m_major_active_h[16] & (mtopi_iid == 8'd48)) miph_set_done_nxt[16] = 1'b1;
else if (miph_set_done_r[16] & ~miph_r[16]) miph_set_done_nxt[16] = 1'b0;
if (m_major_active_h[17] & (mtopi_iid == 8'd49)) miph_set_done_nxt[17] = 1'b1;
else if (miph_set_done_r[17] & ~miph_r[17]) miph_set_done_nxt[17] = 1'b0;
if (m_major_active_h[18] & (mtopi_iid == 8'd50)) miph_set_done_nxt[18] = 1'b1;
else if (miph_set_done_r[18] & ~miph_r[18]) miph_set_done_nxt[18] = 1'b0;
if (m_major_active_h[19] & (mtopi_iid == 8'd51)) miph_set_done_nxt[19] = 1'b1;
else if (miph_set_done_r[19] & ~miph_r[19]) miph_set_done_nxt[19] = 1'b0;
if (m_major_active_h[20] & (mtopi_iid == 8'd52)) miph_set_done_nxt[20] = 1'b1;
else if (miph_set_done_r[20] & ~miph_r[20]) miph_set_done_nxt[20] = 1'b0;
if (m_major_active_h[21] & (mtopi_iid == 8'd53)) miph_set_done_nxt[21] = 1'b1;
else if (miph_set_done_r[21] & ~miph_r[21]) miph_set_done_nxt[21] = 1'b0;
if (m_major_active_h[22] & (mtopi_iid == 8'd54)) miph_set_done_nxt[22] = 1'b1;
else if (miph_set_done_r[22] & ~miph_r[22]) miph_set_done_nxt[22] = 1'b0;
if (m_major_active_h[23] & (mtopi_iid == 8'd55)) miph_set_done_nxt[23] = 1'b1;
else if (miph_set_done_r[23] & ~miph_r[23]) miph_set_done_nxt[23] = 1'b0;
if (m_major_active_h[24] & (mtopi_iid == 8'd56)) miph_set_done_nxt[24] = 1'b1;
else if (miph_set_done_r[24] & ~miph_r[24]) miph_set_done_nxt[24] = 1'b0;
if (m_major_active_h[25] & (mtopi_iid == 8'd57)) miph_set_done_nxt[25] = 1'b1;
else if (miph_set_done_r[25] & ~miph_r[25]) miph_set_done_nxt[25] = 1'b0;
if (m_major_active_h[26] & (mtopi_iid == 8'd58)) miph_set_done_nxt[26] = 1'b1;
else if (miph_set_done_r[26] & ~miph_r[26]) miph_set_done_nxt[26] = 1'b0;
if (m_major_active_h[27] & (mtopi_iid == 8'd59)) miph_set_done_nxt[27] = 1'b1;
else if (miph_set_done_r[27] & ~miph_r[27]) miph_set_done_nxt[27] = 1'b0;
if (m_major_active_h[28] & (mtopi_iid == 8'd60)) miph_set_done_nxt[28] = 1'b1;
else if (miph_set_done_r[28] & ~miph_r[28]) miph_set_done_nxt[28] = 1'b0;
if (m_major_active_h[29] & (mtopi_iid == 8'd61)) miph_set_done_nxt[29] = 1'b1;
else if (miph_set_done_r[29] & ~miph_r[29]) miph_set_done_nxt[29] = 1'b0;
if (m_major_active_h[30] & (mtopi_iid == 8'd62)) miph_set_done_nxt[30] = 1'b1;
else if (miph_set_done_r[30] & ~miph_r[30]) miph_set_done_nxt[30] = 1'b0;
if (m_major_active_h[31] & (mtopi_iid == 8'd63)) miph_set_done_nxt[31] = 1'b1;
else if (miph_set_done_r[31] & ~miph_r[31]) miph_set_done_nxt[31] = 1'b0;




end

always @(posedge clk or posedge rst_a)
begin 
  if (rst_a == 1'b1)
  begin
	mip_set_done_r <= 'b0;
	miph_set_done_r <= 'b0;
  end
  else
  begin
	mip_set_done_r <= mip_set_done_nxt;
	miph_set_done_r <= miph_set_done_nxt;


  end
end
        
        



/////////////////////
//
// iprio arbitration
// up to 64-to-1
//
//Priority  Major Numbers   Description
//--------------------------------------------------------------------------------
//Highest   43              High-priority local RAS event
//          11, 3, 7        Machine external, software, timer interrupt
//          9, 1, 5         Supervisor external, software, timer interrupt
//          12              Hypervisor guest external interrupt
//          10, 2, 6        Virtual supervisor external, software, timer interrupt
//          13              Local counter overflow
//Lowest    35              Low-priority local RAS event
//          17              Debug/trace event
//          48              watchdog timer int

reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio0;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio1;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio2;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio3;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio4;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio5;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio6;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio7;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio8;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio9;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio10;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio11;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio12;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio13;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio14;                
reg [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] in_prio15;                
// make the arbitration tree extensible to 64 source
// input tied to 9'b1_0000_0000 can enable synthesis to optimize the logic


// When the Nested Vectored interrupt handling mode is configured, default priorities are not applied
// to the major interrupt sources and must be explicitly configured in the iprio iCSRs. A value of zero
// in iprio.IPRIO#N effectively disables the major interrupt source N.

always @*
begin
if (mtvec_mode) begin

 in_prio0 = {((~|m_iprio10_r[`PRIO_BYTE_QRANG3]) | ~m_major_active_h[11] | miph_set_done_r[11]), m_iprio10_r[`PRIO_BYTE_QRANG3]}; // 43
 in_prio1 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};  // 11
// in_prio2 = {((~|m_iprio2_r[`PRIO_BYTE_QRANG3]) | ~m_major_active[11]), m_iprio2_r[`PRIO_BYTE_QRANG3]};  // 11
 in_prio2 = {((~|m_iprio0_r[`PRIO_BYTE_QRANG3]) | ~m_major_active[3] | mip_set_done_r[3]), m_iprio0_r[`PRIO_BYTE_QRANG3]};  // 3
 in_prio3 = {((~|m_iprio1_r[`PRIO_BYTE_QRANG3]) | ~m_major_active[7] | mip_set_done_r[7]), m_iprio1_r[`PRIO_BYTE_QRANG3]};  // 7
 in_prio4 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 9
 in_prio5 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 1
 in_prio6 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 5
 in_prio7 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 12
 in_prio8 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 10
 in_prio9 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 2
 in_prio10 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 6
 in_prio11 = {((~|m_iprio3_r[`PRIO_BYTE_QRANG1]) | ~m_major_active[13] | mip_set_done_r[13]), m_iprio3_r[`PRIO_BYTE_QRANG1]};   // 13
 in_prio12 = {((~|m_iprio8_r[`PRIO_BYTE_QRANG3]) | ~m_major_active_h[3] | miph_set_done_r[3]), m_iprio8_r[`PRIO_BYTE_QRANG3]};  //35
 in_prio13 = {((~|m_iprio4_r[`PRIO_BYTE_QRANG1]) | ~m_major_active[17] | mip_set_done_r[17]), m_iprio4_r[`PRIO_BYTE_QRANG1]};  // 17
 in_prio14 = {((~|m_iprio12_r[`PRIO_BYTE_QRANG0]) | ~m_major_active_h[16] | miph_set_done_r[16]), m_iprio12_r[`PRIO_BYTE_QRANG0]}; // 48


 in_prio15 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};             

end
else 
begin
 in_prio0 = {(~m_major_active_h[11]), (~|m_iprio10_r[`PRIO_BYTE_QRANG3]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd0 : m_iprio10_r[`PRIO_BYTE_QRANG3]}; // 43
 in_prio1 = {(~m_major_active[11]),metopi_iid[`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH-1:0]};  // 11
// in_prio2 = {(~m_major_active[11]), (~|m_iprio2_r[`PRIO_BYTE_QRANG3]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd8 : m_iprio2_r[`PRIO_BYTE_QRANG3]};  // 11
 in_prio2 = {(~m_major_active[3]), (~|m_iprio0_r[`PRIO_BYTE_QRANG3]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd`RTIA_M_MAX_EIID : m_iprio0_r[`PRIO_BYTE_QRANG3]};  // 3
 in_prio3 = {(~m_major_active[7]), (~|m_iprio1_r[`PRIO_BYTE_QRANG3]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd`RTIA_M_MAX_EIID : m_iprio1_r[`PRIO_BYTE_QRANG3]};  // 7
 in_prio4 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 9
 in_prio5 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 1
 in_prio6 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 5
 in_prio7 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 12
 in_prio8 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 10
 in_prio9 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 2
 in_prio10 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};     // 6
 in_prio11 = {(~m_major_active[13]), (~|m_iprio3_r[`PRIO_BYTE_QRANG1]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd`RTIA_M_MAX_EIID : m_iprio3_r[`PRIO_BYTE_QRANG1]};   // 13
 in_prio12 = {(~m_major_active_h[3]), (~|m_iprio8_r[`PRIO_BYTE_QRANG3]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd`RTIA_M_MAX_EIID: m_iprio8_r[`PRIO_BYTE_QRANG3]};  //35
 in_prio13 = {(~m_major_active[17]), (~|m_iprio4_r[`PRIO_BYTE_QRANG1]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd`RTIA_M_MAX_EIID: m_iprio4_r[`PRIO_BYTE_QRANG1]};  // 17
 in_prio14 = {(~m_major_active_h[16]), (~|m_iprio12_r[`PRIO_BYTE_QRANG0]) ? `RTIA_HART_MAJOR_PRIO_BYTE_WIDTH'd`RTIA_M_MAX_EIID : m_iprio12_r[`PRIO_BYTE_QRANG0]}; // 48


 in_prio15 = {1'b1, {`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH{1'b0}}};             
end


end

// @@@ to configure iprio registers to read as 0 those are not used 

wire [3:0] out_idx;
wire [`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH:0] out_prio;


iprio_arb u_iprio_arb (
  .in_prio0   (in_prio0),                
  .in_prio1   (in_prio1),                
  .in_prio2   (in_prio2),                
  .in_prio3   (in_prio3),                
  .in_prio4   (in_prio4),                
  .in_prio5   (in_prio5),                
  .in_prio6   (in_prio6),                
  .in_prio7   (in_prio7),                
  .in_prio8   (in_prio8),                
  .in_prio9   (in_prio9),                
  .in_prio10   (in_prio10),                
  .in_prio11   (in_prio11),                
  .in_prio12   (in_prio12),                
  .in_prio13   (in_prio13),                
  .in_prio14   (in_prio14),                
  .in_prio15   (in_prio15),                
  .out_idx       (out_idx),
// spyglass disable_block UnloadedOutTerm-ML
// SMD: Unloaded output terminal
// SJ: Highest bit not useful
  .out_prio      (out_prio)
// spyglass enable_block UnloadedOutTerm-ML
);






// idx mapping
// natural index of the binary tree mapping to actual irq index

always @*
begin
mtopi_iid = 8'd0;
mtopi_irio = 8'd0;
mtopi_irio_int = 8'd0;
case (out_idx)

4'd0: mtopi_iid = 8'd43;
4'd1: mtopi_iid = 8'd11;
4'd2: mtopi_iid = 8'd3;
4'd3: mtopi_iid = 8'd7;
4'd11: mtopi_iid = 8'd13;
4'd12: mtopi_iid = 8'd35;
4'd13: mtopi_iid = 8'd17;
4'd14: mtopi_iid = 8'd48;
default: mtopi_iid = {8{1'b0}};


endcase
mtopi_iid_int = 
(mtvec_mode & (metopi_irio != 0)) ? 8'd11 :
mtopi_iid;

mtopi_irio[`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH-1:0] = out_prio[`RTIA_HART_MAJOR_PRIO_BYTE_WIDTH-1:0];

mtopi_irio_int = 
mtvec_mode ? metopi_irio :
mtopi_irio;




end


//For Direct and Vectored mode the full interrupt source identification requires three numbers:
//    Major Interrupt Identity (IID) number - identifies the CLINT interrupt source. 
//    All external interrupts have the same major interrupt identity number at the privilege level.
//    External Interrupt Identity (EIID) number - identifies the external (reported by IMSIC) interrupt source. 
//    Local interrupts do not have this identity number.
//    Interrupt Priority - specifies the interrupt priority. All external interrupts have priorities equal to their IIDs.
//    Local interrupt priorities configured individually and differ from local interrupt source numbers.

//For Nested Vectored interrupt handling mode all interrupts (incl. local and external) are identified by the EIID. 
//This identity number represents the number of the interrupt source (e.g., index of the pending and enable bit
//in IMSIC interrupt file) as well as its priority. The CLINT reports the local interrupts to the IMSIC file using 
//the configured priorities as the interrupt identity numbers.


// virtual irq not explained clearly in spec 
// some questions not answered.
// sip alias: to be fixed @@@


// vsip alias: to be fixed @@@


////////////////////////////////////////////////////////////////
// emulation access exception
// If the hart has an IMSIC, then when bit 9 of mvien is one, attempts from S-mode to explicitly
// access the supervisor-level interrupt file raise an illegal instruction exception. The exception
// is raised for attempts to access CSR stopei, or to access sireg when siselect has a value
// in the range 0x70��0xFF. Accesses to guest interrupt files (through vstopei or vsiselect +
// vsireg) are not affected.

// in icsr decode logic


////////////////////////////////////////////////
//
// CSR
//
////////////////////////////////////////////////

always @*
begin : csr_read_PROC
csr_rdata = 32'b0;
core_csr_unimpl = 1'b0;
csr_illegal = 1'b0;
if (| csr_clint_sel_ctl)
begin
  case (csr_raddr_r)
    `CSR_MIE:	begin
    csr_illegal = priv_level != `PRIV_M;
        csr_rdata[`DATA_RANGE] =		mie_r;
    end
    `CSR_MIEH:	begin
    csr_illegal = priv_level != `PRIV_M;
    csr_rdata[`DATA_RANGE] =		mieh_r;
    end
    `CSR_MIP:	begin
    csr_illegal = priv_level != `PRIV_M;
    csr_rdata[`DATA_RANGE] =		mip_r;
    end
    `CSR_MIPH:	begin
    csr_illegal = priv_level != `PRIV_M;
    csr_rdata[`DATA_RANGE] =		miph_r;
    end
    `CSR_MTOPEI:	begin
    csr_illegal = priv_level != `PRIV_M;
    csr_rdata[`DATA_RANGE] =		mtopei;
    end
    `CSR_MTOPI:	begin 
    csr_illegal = (priv_level != `PRIV_M) | csr_wr_r;
    csr_rdata[`DATA_RANGE] =		irq_trap ? {8'd0, mtopi_iid_int, 8'd0, mtopi_irio_int} : 32'b0;
    end
    default:
        core_csr_unimpl = 1'b1;
	endcase
  end
  else begin
        csr_rdata = 32'b0;
        core_csr_unimpl = 1'b1;
        csr_illegal = 1'b0;
  end
end


//////////////////////////////////////////////////////////////////
// Write Address Case Statement
//////////////////////////////////////////////////////////////////
always @*
begin : csr_write_enable_PROC
	mie_wen = 1'b0;
	mieh_wen = 1'b0;
	mip_wen = 1'b0;
	miph_wen = 1'b0;
	mtopei_wen = 1'b0;
//	mtsp_wen = 1'b0;
	if (csr_wen_r == 1'b1)
	begin
	case (csr_waddr_r)
	`CSR_MIE:	mie_wen = 1'b1;
	`CSR_MIEH:	mieh_wen = 1'b1;
	`CSR_MIP:	mip_wen = 1'b1;
	`CSR_MIPH:	miph_wen = 1'b1;
	`CSR_MTOPEI:	mtopei_wen = 1'b1;
//	`CSR_MTSP:	mtsp_wen = 1'b1;
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue. Added 20240201 for lint.
    default:;
// spyglass enable_block W193
    endcase
  end
end

always @(posedge clk or posedge rst_a)
begin : csr_write_PROC
  if (rst_a == 1'b1)
  begin
	mie_r <= 'b0;
	mieh_r <= 'b0;
	mip_r <= 'b0;
	miph_r <= 'b0;
	mtopei_r <= 'b0;
//	mtsp_r <= 'b0;
end
	else
	begin

		mie_r <= mie_wen ? {14'd0,csr_wa_data_r[17], 3'd0, csr_wa_data_r[13],1'b0,csr_wa_data_r[11],3'd0, csr_wa_data_r[7],3'd0, csr_wa_data_r[3],3'd0} : mie_nxt;

		mieh_r <= mieh_wen ? {15'd0,csr_wa_data_r[16],4'd0,csr_wa_data_r[11],7'd0,csr_wa_data_r[3],3'd0} : mieh_nxt;
// @@@ level trigger source may not need physical register range of mip
// @@@ for example, mtip is sticky bit in mip or not. TBD. If not these bits are not writable
// P-bit is writable if the interrupt source exists in the privilege mode. The result of writing 0 value to the P-bit 
// depends on interrupt source trigger condition. For edge-triggered interrupts (e.g., RAS interrupts) writing to the 
// P-bit results actual bit clear (SW uses this to complete the interrupt). Fort level-triggered interrupts (timer, SWI, external, guest external)
// the interrupt source has priority on top of SW access. Writing zero will be accepted only if the interrupt 
// request is de-asserted by source, otherwise P-bit should not be updated.

		mip_r <= mip_wen ? {14'd0,csr_wa_data_r[17], 3'd0, csr_wa_data_r[13],1'b0,mip_nxt[11],3'd0, mip_nxt[7],3'd0, mip_nxt[3],3'd0}  : mip_nxt;
		miph_r <= miph_wen ? {15'd0,miph_nxt[16],4'd0,csr_wa_data_r[11],7'd0,csr_wa_data_r[3],3'd0} : miph_nxt;
		mtopei_r <= mtopei_wen ? {8'd0,csr_wa_data_r[23:16],8'd0,csr_wa_data_r[7:0]} : mtopei_r;
//		mtsp_r <= mtsp_wen ? csr_wa_data_r : mtsp_r;

  end
end


always @(posedge clk or posedge rst_a)
begin : dmsi_rdy_regs_PROC
  if (rst_a == 1'b1)
  begin
    dmsi_rdy_r <= 1'b0;
  end
  else
  begin
    dmsi_rdy_r <= 1'b1;
  end
end

// spyglass enable_block RegInputOutput-ML
endmodule // rl_clint

