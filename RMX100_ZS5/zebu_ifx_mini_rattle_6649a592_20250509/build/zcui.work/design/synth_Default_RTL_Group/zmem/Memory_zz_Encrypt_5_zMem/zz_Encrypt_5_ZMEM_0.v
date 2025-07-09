/* ###--------------------------------------------------------------------### */
/*   Copyright Emulation And Verification Engineering                         */
/* ###--------------------------------------------------------------------### */
/*   Verilog memory wrapper                                                   */
/* ###--------------------------------------------------------------------### */


// 
// #-------- Basic definition of memory 'zz_Encrypt_5_ZMEM_0'
// memory new                zz_Encrypt_5_ZMEM_0 bram
// memory depth              1024
// memory width              4
// memory set_word_length    8
// 
// memory enable_bram_dual_port_multiplexed  true
// 
// #-------- Memory advanced definition
// memory type                  sync
// memory scalarize             false
// memory set_memory_debug_mode false
// memory set_sys_freq          clk_100
// set_max_sys_freq          clk_100
// 
// 
//   #-------- Definition of port 'w0'
//   memory add_port         w0 w
//   memory set_rw_mode      w0 ReadBeforeWrite
//   memory set_port_latency w0 1
//   memory set_port_access  w0 sync
//   memory_port w0 di     w0di
//   memory_port w0 addr   w0addr
//   memory_port w0 clk    w0clk posedge
//   memory_port w0 we     w0we high
//   memory set_debug_mode w0 true
// 
//   #-------- Definition of port 'r1'
//   memory add_port         r1 r
//   memory set_rw_mode      r1 ReadBeforeWrite
//   memory set_port_latency r1 1
//   memory set_port_access  r1 sync
//   memory_port r1 do     r1do
//   memory_port r1 addr   r1addr
//   memory_port r1 clk    w0clk posedge
//   memory set_debug_mode r1 true
// 
// 

module zz_Encrypt_5_ZMEM_0 (
   w0di
  ,w0addr
  ,w0we
  ,w0clk
  ,r1do
  ,r1addr
);

  input  [  3:  0] w0di;
  input  [  9:  0] w0addr;
  input            w0we;
  input            w0clk;
  output [  3:  0] r1do;
  input  [  9:  0] r1addr;



/* synopsys translate_off */

  reg /*sparse*/ [  3:0] mem [0:1023];


  `ifdef ZFMCHECK_SIM
    reg tb_assert;
    integer zfm_mem_genvar;
    initial begin
      for(zfm_mem_genvar = 0; zfm_mem_genvar < 1024; zfm_mem_genvar = zfm_mem_genvar + 1)
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
   time w0clk_zfm_clk;
   `endif

  reg [  3:0] r1do_reg0;
  assign r1do = r1do_reg0;


  reg [  3:0] maskw0;

  reg [  3:0] maskr1;

  always @ ( posedge w0clk )
  begin

    //-------- Write (port w0)
    if ( w0we ) begin
      mem[w0addr] <= w0di;
    end

  `ifdef ZFMCHECK_SIM
        if (w0we)
          w0clk_zfm_clk <= $time;
   `endif
    //-------- Read (port r1)
    r1do_reg0 <= mem[r1addr];
  `ifdef ZFMCHECK_SIM
        if (1)
          w0clk_zfm_clk <= $time;
   `endif
  end

  `ifdef ZFMCHECK_SIM
    always @(w0clk_zfm_clk)
    begin
      if (1) begin
        if (((w0clk_zfm_clk == w0clk_zfm_clk) && (w0addr == r1addr) && (1 == w0we)))
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
