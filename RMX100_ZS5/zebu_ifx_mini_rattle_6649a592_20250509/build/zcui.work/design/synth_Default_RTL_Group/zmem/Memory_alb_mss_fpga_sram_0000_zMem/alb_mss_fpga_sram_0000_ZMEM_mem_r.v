/* ###--------------------------------------------------------------------### */
/*   Copyright Emulation And Verification Engineering                         */
/* ###--------------------------------------------------------------------### */
/*   Verilog memory wrapper                                                   */
/* ###--------------------------------------------------------------------### */


// 
// #-------- Basic definition of memory 'alb_mss_fpga_sram_0000_ZMEM_mem_r'
// memory new                alb_mss_fpga_sram_0000_ZMEM_mem_r zrm
// memory depth              268435456
// memory width              128
// memory set_word_length    8
// 
// 
// #-------- Memory advanced definition
// memory optimize_capacity true
// memory type                  sync
// memory scalarize             false
// memory set_memory_debug_mode false
// memory set_sys_freq          clk_100
// set_max_sys_freq          clk_100
// 
// 
//   #-------- Definition of port 'rw0'
//   memory add_port         rw0 rw
//   memory set_rw_mode      rw0 ReadBeforeWrite
//   memory set_port_latency rw0 1
//   memory set_port_access  rw0 sync
//   memory_port rw0 di     rw0di
//   memory_port rw0 do     rw0do
//   memory_port rw0 addr   rw0addr
//   memory_port rw0 clk    rw0clk posedge
//   memory_port rw0 we     rw0we high
//   memory_port rw0 re     rw0re high
//   memory_port rw0 fbie   rw0bie high
//   memory set_debug_mode rw0 false
// 
// 

module alb_mss_fpga_sram_0000_ZMEM_mem_r (
   rw0di
  ,rw0do
  ,rw0addr
  ,rw0we
  ,rw0bie
  ,rw0clk
  ,rw0re
);

  input  [127:  0] rw0di;
  output [127:  0] rw0do;
  input  [ 27:  0] rw0addr;
  input            rw0we;
  input            rw0re;
  input  [127:  0] rw0bie;
  input            rw0clk;



/* synopsys translate_off */

  reg /*sparse*/ [127:0] mem [0:268435455];


  `ifdef ZFMCHECK_SIM
    reg tb_assert;
    integer zfm_mem_genvar;
    initial begin
      for(zfm_mem_genvar = 0; zfm_mem_genvar < 268435456; zfm_mem_genvar = zfm_mem_genvar + 1)
        mem[zfm_mem_genvar] = 'b0;
      tb_assert = 1'b1; 
    end
  `endif

  `ifdef ZFMCHECK_SIM
    reg [0:0] rw_tb_assert;
    initial begin
      rw_tb_assert = ~0;
    end
  `endif
  `ifdef ZFMCHECK_SIM
   time rw0clk_zfm_clk;
   `endif
  reg [127:0] rw0do_reg0;
  assign rw0do = rw0do_reg0;


  reg [127:0] maskrw0;

  always @ ( posedge rw0clk )
  begin

    //-------- Mask (port rw0)
    maskrw0 = ( { {8{rw0bie[120]}}, {8{rw0bie[112]}}, {8{rw0bie[104]}}, {8{rw0bie[96]}}, {8{rw0bie[88]}}, {8{rw0bie[80]}}, {8{rw0bie[72]}}, {8{rw0bie[64]}}, {8{rw0bie[56]}}, {8{rw0bie[48]}}, {8{rw0bie[40]}}, {8{rw0bie[32]}}, {8{rw0bie[24]}}, {8{rw0bie[16]}}, {8{rw0bie[8]}}, {8{rw0bie[0]}} }  );

    //-------- Write (port rw0)
    if ( rw0we ) begin
      if (maskrw0)
        mem[rw0addr] <= (rw0di & maskrw0) | (mem[rw0addr] & ~maskrw0);
    end

    //-------- Read (port rw0)
    if ( rw0re ) begin
      rw0do_reg0 <= mem[rw0addr];
    end
  `ifdef ZFMCHECK_SIM
        if (rw0re)
          rw0clk_zfm_clk <= $time;
   `endif
  end

  `ifdef ZFMCHECK_SIM
    always @(rw0clk_zfm_clk)
    begin
      if (rw0re) begin
        if (((rw0clk_zfm_clk == rw0clk_zfm_clk) && (rw0addr == rw0addr) && (rw0re == rw0we)))
          rw_tb_assert[0] = 0;
        else
          rw_tb_assert[0] = 1;
      end
    end
  `endif
  `ifdef ZFMCHECK_SIM
    assign tb_assert = &rw_tb_assert;
  `endif

/* synopsys translate_on */


endmodule
