/* ###--------------------------------------------------------------------### */
/*   Copyright Emulation And Verification Engineering                         */
/* ###--------------------------------------------------------------------### */
/*   Verilog memory wrapper                                                   */
/* ###--------------------------------------------------------------------### */


// 
// #-------- Basic definition of memory 'alb_mss_mem_lat_0000_ZMEM_i_rdel_mem'
// memory new                alb_mss_mem_lat_0000_ZMEM_i_rdel_mem bram
// memory depth              1024
// memory width              131
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
//   memory set_port_access  r1 async
//   memory_port r1 do     r1do
//   memory_port r1 addr   r1addr
//   memory set_debug_mode r1 true
// 
// 

module alb_mss_mem_lat_0000_ZMEM_i_rdel_mem (
   w0di
  ,w0addr
  ,w0we
  ,w0clk
  ,r1do
  ,r1addr
);

  input  [130:  0] w0di;
  input  [  9:  0] w0addr;
  input            w0we;
  input            w0clk;
  output [130:  0] r1do;
  input  [  9:  0] r1addr;



z_alb_mss_mem_lat_0000_ZMEM_i_rdel_mem my_alb_mss_mem_lat_0000_ZMEM_i_rdel_mem (
     .W0DI(w0di)
    ,.W0ADDR(w0addr)
    ,.W0WE(w0we)
    ,.W0CLK(w0clk)
    ,.R1DO(r1do)
    ,.R1ADDR(r1addr)
);


endmodule
