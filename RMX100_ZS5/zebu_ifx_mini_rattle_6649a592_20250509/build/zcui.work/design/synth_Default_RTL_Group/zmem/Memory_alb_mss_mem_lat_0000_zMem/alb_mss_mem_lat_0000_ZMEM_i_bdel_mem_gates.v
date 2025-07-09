// Emulation Verification Engineering - verilog generator
// ------------------------------------------------------
// Netlist : alb_mss_mem_lat_0000_ZMEM_i_bdel_mem   -   root module : z_alb_mss_mem_lat_0000_ZMEM_i_bdel_mem

`timescale 100 ps / 10 ps

// library : znetgen --------------------------------------------

module zview (
   I
  );
input   I;



endmodule


// library : work --------------------------------------------

module ZXLSYS (
   CLK_200
  ,CLK_100
  ,CLK_50
  ,CLK_25
  );
output  CLK_200;
output  CLK_100;
output  CLK_50;
output  CLK_25;



endmodule

module z_alb_mss_mem_lat_0000_ZMEM_i_bdel_mem (
   W0WE
  ,W0CLK
  ,W0DI
  ,W0ADDR
  ,R1DO
  ,R1ADDR
  );
input   W0WE;
input   W0CLK;
input  [1:0] W0DI;
input  [9:0] W0ADDR;
output [1:0] R1DO;
input  [9:0] R1ADDR;

wire alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd;
wire RAMB36E1_DOBDO_0_;
wire alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_vcc;
wire PROTECTED_SETUP_r1addr_0_;
wire wire_sysFreq;
wire PROTECTED_SETUP_r1addr_1_;
wire PROTECTED_SETUP_r1addr_2_;
wire PROTECTED_SETUP_r1addr_3_;
wire PROTECTED_SETUP_r1addr_4_;
wire PROTECTED_SETUP_r1addr_5_;
wire PROTECTED_SETUP_r1addr_6_;
wire PROTECTED_SETUP_r1addr_7_;
wire PROTECTED_SETUP_r1addr_8_;
wire PROTECTED_SETUP_r1addr_9_;
wire w0di_0_;
wire w0di_1_;
wire w0we;
wire w0clk;
wire w0addr_0_;
wire w0addr_1_;
wire w0addr_2_;
wire w0addr_3_;
wire w0addr_4_;
wire w0addr_5_;
wire w0addr_6_;
wire w0addr_7_;
wire w0addr_8_;
wire w0addr_9_;
wire r1do_0_;
wire r1do_1_;
wire r1addr_0_;
wire r1addr_1_;
wire r1addr_2_;
wire r1addr_3_;
wire r1addr_4_;
wire r1addr_5_;
wire r1addr_6_;
wire r1addr_7_;
wire r1addr_8_;
wire r1addr_9_;
wire zsimv_ucon_0;
wire zsimv_ucon_1;
wire zsimv_ucon_2;
wire zsimv_ucon_3;
wire zsimv_ucon_4;
wire zsimv_ucon_5;
wire zsimv_ucon_6;
wire zsimv_ucon_7;
wire zsimv_ucon_8;
wire zsimv_ucon_9;
wire zsimv_ucon_10;
wire zsimv_ucon_11;
wire zsimv_ucon_12;
wire zsimv_ucon_13;
wire zsimv_ucon_14;
wire zsimv_ucon_15;
wire zsimv_ucon_16;
wire zsimv_ucon_17;
wire zsimv_ucon_18;
wire zsimv_ucon_19;
wire zsimv_ucon_20;
wire zsimv_ucon_21;
wire zsimv_ucon_22;
wire zsimv_ucon_23;
wire zsimv_ucon_24;
wire zsimv_ucon_25;
wire zsimv_ucon_26;
wire zsimv_ucon_27;
wire zsimv_ucon_28;
wire zsimv_ucon_29;
wire zsimv_ucon_30;
wire zsimv_ucon_31;
wire zsimv_ucon_32;
wire zsimv_ucon_33;
wire zsimv_ucon_34;
wire zsimv_ucon_35;
wire zsimv_ucon_36;
wire zsimv_ucon_37;
wire zsimv_ucon_38;
wire zsimv_ucon_39;
wire zsimv_ucon_40;
wire zsimv_ucon_41;
wire zsimv_ucon_42;
wire zsimv_ucon_43;
wire zsimv_ucon_44;
wire zsimv_ucon_45;
wire zsimv_ucon_46;
wire zsimv_ucon_47;
wire zsimv_ucon_48;
wire zsimv_ucon_49;
wire zsimv_ucon_50;
wire zsimv_ucon_51;
wire zsimv_ucon_52;
wire zsimv_ucon_53;
wire zsimv_ucon_54;
wire zsimv_ucon_55;
wire zsimv_ucon_56;
wire zsimv_ucon_57;
wire zsimv_ucon_58;
wire zsimv_ucon_59;
wire zsimv_ucon_60;
wire zsimv_ucon_61;
wire zsimv_ucon_62;
wire zsimv_ucon_63;
wire zsimv_ucon_64;
wire zsimv_ucon_65;
wire zsimv_ucon_66;
wire zsimv_ucon_67;
wire zsimv_ucon_68;
wire zsimv_ucon_69;
wire zsimv_ucon_70;
wire zsimv_ucon_71;
wire zsimv_ucon_72;
wire zsimv_ucon_73;
wire zsimv_ucon_74;
wire zsimv_ucon_75;
wire zsimv_ucon_76;
wire zsimv_ucon_77;
wire zsimv_ucon_78;
wire zsimv_ucon_79;
wire zsimv_ucon_80;
wire zsimv_ucon_81;
wire zsimv_ucon_82;
wire zsimv_ucon_83;
wire zsimv_ucon_84;
wire zsimv_ucon_85;
wire zsimv_ucon_86;
wire zsimv_ucon_87;
wire zsimv_ucon_88;
wire zsimv_ucon_89;
wire zsimv_ucon_90;
wire zsimv_ucon_91;
wire zsimv_ucon_92;
wire zsimv_ucon_93;
wire zsimv_ucon_94;
wire zsimv_ucon_95;
wire zsimv_ucon_96;

assign w0di_0_ = W0DI[0];
assign w0di_1_ = W0DI[1];
assign w0we = W0WE;
assign w0clk = W0CLK;
assign w0addr_0_ = W0ADDR[0];
assign w0addr_1_ = W0ADDR[1];
assign w0addr_2_ = W0ADDR[2];
assign w0addr_3_ = W0ADDR[3];
assign w0addr_4_ = W0ADDR[4];
assign w0addr_5_ = W0ADDR[5];
assign w0addr_6_ = W0ADDR[6];
assign w0addr_7_ = W0ADDR[7];
assign w0addr_8_ = W0ADDR[8];
assign w0addr_9_ = W0ADDR[9];
assign R1DO[0] = r1do_0_;
assign R1DO[1] = r1do_1_;
assign r1addr_0_ = R1ADDR[0];
assign r1addr_1_ = R1ADDR[1];
assign r1addr_2_ = R1ADDR[2];
assign r1addr_3_ = R1ADDR[3];
assign r1addr_4_ = R1ADDR[4];
assign r1addr_5_ = R1ADDR[5];
assign r1addr_6_ = R1ADDR[6];
assign r1addr_7_ = R1ADDR[7];
assign r1addr_8_ = R1ADDR[8];
assign r1addr_9_ = R1ADDR[9];

GND I_alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd (
    .G(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd)
  );

VCC I_alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_vcc (
    .P(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_vcc)
  );

FD \I_PROTECTED_SETUP_r1addr[0]  (
    .Q(PROTECTED_SETUP_r1addr_0_)
  , .C(wire_sysFreq)
  , .D(r1addr_0_)
  );

ZXLSYS I_zgatezxlsys (
    .CLK_200(zsimv_ucon_0)
  , .CLK_100(wire_sysFreq)
  , .CLK_50(zsimv_ucon_1)
  , .CLK_25(zsimv_ucon_2)
  );

FD \I_PROTECTED_SETUP_r1addr[1]  (
    .Q(PROTECTED_SETUP_r1addr_1_)
  , .C(wire_sysFreq)
  , .D(r1addr_1_)
  );

FD \I_PROTECTED_SETUP_r1addr[2]  (
    .Q(PROTECTED_SETUP_r1addr_2_)
  , .C(wire_sysFreq)
  , .D(r1addr_2_)
  );

FD \I_PROTECTED_SETUP_r1addr[3]  (
    .Q(PROTECTED_SETUP_r1addr_3_)
  , .C(wire_sysFreq)
  , .D(r1addr_3_)
  );

FD \I_PROTECTED_SETUP_r1addr[4]  (
    .Q(PROTECTED_SETUP_r1addr_4_)
  , .C(wire_sysFreq)
  , .D(r1addr_4_)
  );

FD \I_PROTECTED_SETUP_r1addr[5]  (
    .Q(PROTECTED_SETUP_r1addr_5_)
  , .C(wire_sysFreq)
  , .D(r1addr_5_)
  );

FD \I_PROTECTED_SETUP_r1addr[6]  (
    .Q(PROTECTED_SETUP_r1addr_6_)
  , .C(wire_sysFreq)
  , .D(r1addr_6_)
  );

FD \I_PROTECTED_SETUP_r1addr[7]  (
    .Q(PROTECTED_SETUP_r1addr_7_)
  , .C(wire_sysFreq)
  , .D(r1addr_7_)
  );

FD \I_PROTECTED_SETUP_r1addr[8]  (
    .Q(PROTECTED_SETUP_r1addr_8_)
  , .C(wire_sysFreq)
  , .D(r1addr_8_)
  );

FD \I_PROTECTED_SETUP_r1addr[9]  (
    .Q(PROTECTED_SETUP_r1addr_9_)
  , .C(wire_sysFreq)
  , .D(r1addr_9_)
  );

defparam I_RAMB36E1.SRVAL_A = "000000000000000000000000000000000000";
defparam I_RAMB36E1.SRVAL_B = "000000000000000000000000000000000000";
defparam I_RAMB36E1.WRITE_MODE_A = "READ_FIRST";
defparam I_RAMB36E1.WRITE_MODE_B = "READ_FIRST";
defparam I_RAMB36E1.WRITE_WIDTH_B = 2;
defparam I_RAMB36E1.READ_WIDTH_A = 2;
RAMB36E1 I_RAMB36E1 (
    .CASCADEOUTA(zsimv_ucon_3)
  , .CASCADEOUTB(zsimv_ucon_4)
  , .DBITERR(zsimv_ucon_5)
  , .SBITERR(zsimv_ucon_92)
  , .CASCADEINA(zsimv_ucon_93)
  , .CASCADEINB(zsimv_ucon_94)
  , .CLKARDCLK(wire_sysFreq)
  , .CLKBWRCLK(w0clk)
  , .ENARDEN(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_vcc)
  , .ENBWREN(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_vcc)
  , .INJECTDBITERR(zsimv_ucon_95)
  , .INJECTSBITERR(zsimv_ucon_96)
  , .REGCEAREGCE(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd)
  , .REGCEB(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd)
  , .RSTRAMARSTRAM(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd)
  , .RSTRAMB(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd)
  , .RSTREGARSTREG(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd)
  , .RSTREGB(alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd)
  , .DIPADIP(
   {  alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
   } )
  , .DIPBDIP(
   {  alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
   } )
  , .WEA(
   {  alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
   } )
  , .WEBWE(
   {  w0we, w0we, w0we, w0we
  , w0we, w0we, w0we, w0we
   } )
  , .ADDRARDADDR(
   {  alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, PROTECTED_SETUP_r1addr_9_, PROTECTED_SETUP_r1addr_8_, PROTECTED_SETUP_r1addr_7_
  , PROTECTED_SETUP_r1addr_6_, PROTECTED_SETUP_r1addr_5_, PROTECTED_SETUP_r1addr_4_, PROTECTED_SETUP_r1addr_3_
  , PROTECTED_SETUP_r1addr_2_, PROTECTED_SETUP_r1addr_1_, PROTECTED_SETUP_r1addr_0_, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
   } )
  , .ADDRBWRADDR(
   {  alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, w0addr_9_, w0addr_8_, w0addr_7_
  , w0addr_6_, w0addr_5_, w0addr_4_, w0addr_3_
  , w0addr_2_, w0addr_1_, w0addr_0_, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
   } )
  , .DIADI(
   {  alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
   } )
  , .DIBDI(
   {  alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd
  , alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, alb_mss_mem_lat_0000_ZMEM_i_bdel_mem_add_gnd, w0di_1_, w0di_0_
   } )
  , .DOPADOP(
   {  zsimv_ucon_70, zsimv_ucon_69, zsimv_ucon_68, zsimv_ucon_67
   } )
  , .DOPBDOP(
   {  zsimv_ucon_74, zsimv_ucon_73, zsimv_ucon_72, zsimv_ucon_71
   } )
  , .ECCPARITY(
   {  zsimv_ucon_82, zsimv_ucon_81, zsimv_ucon_80, zsimv_ucon_79
  , zsimv_ucon_78, zsimv_ucon_77, zsimv_ucon_76, zsimv_ucon_75
   } )
  , .RDADDRECC(
   {  zsimv_ucon_91, zsimv_ucon_90, zsimv_ucon_89, zsimv_ucon_88
  , zsimv_ucon_87, zsimv_ucon_86, zsimv_ucon_85, zsimv_ucon_84
  , zsimv_ucon_83 } )
  , .DOADO(
   {  zsimv_ucon_28, zsimv_ucon_27, zsimv_ucon_25, zsimv_ucon_24
  , zsimv_ucon_23, zsimv_ucon_22, zsimv_ucon_21, zsimv_ucon_20
  , zsimv_ucon_19, zsimv_ucon_18, zsimv_ucon_17, zsimv_ucon_16
  , zsimv_ucon_15, zsimv_ucon_14, zsimv_ucon_13, zsimv_ucon_12
  , zsimv_ucon_11, zsimv_ucon_10, zsimv_ucon_9, zsimv_ucon_8
  , zsimv_ucon_7, zsimv_ucon_6, zsimv_ucon_35, zsimv_ucon_34
  , zsimv_ucon_33, zsimv_ucon_32, zsimv_ucon_31, zsimv_ucon_30
  , zsimv_ucon_29, zsimv_ucon_26, r1do_1_, r1do_0_
   } )
  , .DOBDO(
   {  zsimv_ucon_59, zsimv_ucon_58, zsimv_ucon_56, zsimv_ucon_55
  , zsimv_ucon_54, zsimv_ucon_53, zsimv_ucon_52, zsimv_ucon_51
  , zsimv_ucon_50, zsimv_ucon_49, zsimv_ucon_48, zsimv_ucon_47
  , zsimv_ucon_45, zsimv_ucon_44, zsimv_ucon_43, zsimv_ucon_42
  , zsimv_ucon_41, zsimv_ucon_40, zsimv_ucon_39, zsimv_ucon_38
  , zsimv_ucon_37, zsimv_ucon_36, zsimv_ucon_66, zsimv_ucon_65
  , zsimv_ucon_64, zsimv_ucon_63, zsimv_ucon_62, zsimv_ucon_61
  , zsimv_ucon_60, zsimv_ucon_57, zsimv_ucon_46, RAMB36E1_DOBDO_0_
   } )
  );

zview I_zview_w0we (
    .I(w0we)
  );

zview \I_zview_w0addr[9]  (
    .I(w0addr_9_)
  );

zview \I_zview_w0addr[8]  (
    .I(w0addr_8_)
  );

zview \I_zview_w0addr[7]  (
    .I(w0addr_7_)
  );

zview \I_zview_w0addr[6]  (
    .I(w0addr_6_)
  );

zview \I_zview_w0addr[5]  (
    .I(w0addr_5_)
  );

zview \I_zview_w0addr[4]  (
    .I(w0addr_4_)
  );

zview \I_zview_w0addr[3]  (
    .I(w0addr_3_)
  );

zview \I_zview_w0addr[2]  (
    .I(w0addr_2_)
  );

zview \I_zview_w0addr[1]  (
    .I(w0addr_1_)
  );

zview \I_zview_w0addr[0]  (
    .I(w0addr_0_)
  );

zview \I_zview_w0di[1]  (
    .I(w0di_1_)
  );

zview \I_zview_w0di[0]  (
    .I(w0di_0_)
  );

zview \I_zview_r1addr[9]  (
    .I(r1addr_9_)
  );

zview \I_zview_r1addr[8]  (
    .I(r1addr_8_)
  );

zview \I_zview_r1addr[7]  (
    .I(r1addr_7_)
  );

zview \I_zview_r1addr[6]  (
    .I(r1addr_6_)
  );

zview \I_zview_r1addr[5]  (
    .I(r1addr_5_)
  );

zview \I_zview_r1addr[4]  (
    .I(r1addr_4_)
  );

zview \I_zview_r1addr[3]  (
    .I(r1addr_3_)
  );

zview \I_zview_r1addr[2]  (
    .I(r1addr_2_)
  );

zview \I_zview_r1addr[1]  (
    .I(r1addr_1_)
  );

zview \I_zview_r1addr[0]  (
    .I(r1addr_0_)
  );

zview \I_zview_r1do[1]  (
    .I(r1do_1_)
  );

zview \I_zview_r1do[0]  (
    .I(r1do_0_)
  );

endmodule

