/* ###--------------------------------------------------------------------### */
/*   Copyright Emulation And Verification Engineering                         */
/* ###--------------------------------------------------------------------### */
/*   Verilog memory wrapper                                                   */
/* ###--------------------------------------------------------------------### */


// 
// #-------- Basic definition of memory 'fpga_sram_0002_0000_ZMEM_mem_r'
// memory new                fpga_sram_0002_0000_ZMEM_mem_r uram
// memory depth              131072
// memory width              40
// memory set_word_length    8
// 
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
//   #-------- Definition of port 'r2'
//   memory add_port         r2 r
//   memory set_rw_mode      r2 ReadBeforeWrite
//   memory set_port_latency r2 1
//   memory set_port_access  r2 async
//   memory_port r2 do     r2do
//   memory_port r2 addr   r2addr
//   memory set_debug_mode r2 true
// 
// 

module fpga_sram_0002_0000_ZMEM_mem_r (
   w0di
  ,w0addr
  ,w0we
  ,w0clk
  ,r1do
  ,r1addr
  ,r2do
  ,r2addr
);

  input  [ 39:  0] w0di;
  input  [ 16:  0] w0addr;
  input            w0we;
  input            w0clk;
  output [ 39:  0] r1do;
  input  [ 16:  0] r1addr;
  output [ 39:  0] r2do;
  input  [ 16:  0] r2addr;



endmodule
