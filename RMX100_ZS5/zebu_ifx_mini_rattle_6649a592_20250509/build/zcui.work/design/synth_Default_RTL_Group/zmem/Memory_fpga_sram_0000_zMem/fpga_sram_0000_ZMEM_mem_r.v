/* ###--------------------------------------------------------------------### */
/*   Copyright Emulation And Verification Engineering                         */
/* ###--------------------------------------------------------------------### */
/*   Verilog memory wrapper                                                   */
/* ###--------------------------------------------------------------------### */


// 
// #-------- Basic definition of memory 'fpga_sram_0000_ZMEM_mem_r'
// memory new                fpga_sram_0000_ZMEM_mem_r bram
// memory depth              256
// memory width              56
// memory set_word_length    1
// 
// memory enable_bram_dual_port_multiplexed  true
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
//   #-------- Definition of port 'w0'
//   memory add_port         w0 w
//   memory set_rw_mode      w0 ReadBeforeWrite
//   memory set_port_latency w0 1
//   memory set_port_access  w0 sync
//   memory_port w0 di     w0di
//   memory_port w0 addr   w0addr
//   memory_port w0 clk    w0clk posedge
//   memory_port w0 we     w0we high
//   memory_port w0 bie    w0bie high
//   memory set_debug_mode w0 true
// 
//   #-------- Definition of port 'r1'
//   memory add_port         r1 r
//   memory set_rw_mode      r1 ReadBeforeWrite
//   memory set_port_latency r1 1
//   memory set_port_access  r1 async
//   memory_port r1 do     r1do
//   memory_port r1 addr   r1addr
//   memory set_debug_mode r1 true
// 
// 

module fpga_sram_0000_ZMEM_mem_r (
   w0di
  ,w0addr
  ,w0we
  ,w0bie
  ,w0clk
  ,r1do
  ,r1addr
);

  input  [ 55:  0] w0di;
  input  [  7:  0] w0addr;
  input            w0we;
  input  [ 55:  0] w0bie;
  input            w0clk;
  output [ 55:  0] r1do;
  input  [  7:  0] r1addr;



/* synopsys translate_off */

  reg /*sparse*/ [ 55:0] mem [0:255];


  `ifdef ZFMCHECK_SIM
    reg tb_assert;
    integer zfm_mem_genvar;
    initial begin
      for(zfm_mem_genvar = 0; zfm_mem_genvar < 256; zfm_mem_genvar = zfm_mem_genvar + 1)
        mem[zfm_mem_genvar] = 'b0;
      tb_assert = 1'b1; 
    end
  `endif


  reg [ 55:0] r1do_reg0;
  assign r1do = r1do_reg0;


  reg [ 55:0] maskw0;

  reg [ 55:0] maskr1;

  always @ ( posedge w0clk )
  begin

    //-------- Mask (port w0)
    maskw0 = ( w0bie  );

    //-------- Write (port w0)
    if ( w0we ) begin
      if (maskw0)
        mem[w0addr] <= (w0di & maskw0) | (mem[w0addr] & ~maskw0);
    end

  end

  always @ (  r1addr,  mem[r1addr]) begin

    //-------- Read (port r1)
    r1do_reg0 <= mem[r1addr];
  end


/* synopsys translate_on */


endmodule
