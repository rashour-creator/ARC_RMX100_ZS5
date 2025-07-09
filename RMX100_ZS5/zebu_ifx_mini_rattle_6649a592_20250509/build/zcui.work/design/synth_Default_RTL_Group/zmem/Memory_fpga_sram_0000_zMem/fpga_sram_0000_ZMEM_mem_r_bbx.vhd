-- ###--------------------------------------------------------------------### --
--   Copyright Emulation And Verification Engineering                         --
-- ###--------------------------------------------------------------------### --
--   VHDL memory wrapper                                                      --
-- ###--------------------------------------------------------------------### --


-- 
-- #-------- Basic definition of memory 'fpga_sram_0000_ZMEM_mem_r'
-- memory new                fpga_sram_0000_ZMEM_mem_r bram
-- memory depth              256
-- memory width              56
-- memory set_word_length    1
-- 
-- memory enable_bram_dual_port_multiplexed  true
-- 
-- #-------- Memory advanced definition
-- memory optimize_capacity true
-- memory type                  sync
-- memory scalarize             false
-- memory set_memory_debug_mode false
-- memory set_sys_freq          clk_100
-- set_max_sys_freq          clk_100
-- 
-- 
--   #-------- Definition of port 'w0'
--   memory add_port         w0 w
--   memory set_rw_mode      w0 ReadBeforeWrite
--   memory set_port_latency w0 1
--   memory set_port_access  w0 sync
--   memory_port w0 di     w0di
--   memory_port w0 addr   w0addr
--   memory_port w0 clk    w0clk posedge
--   memory_port w0 we     w0we high
--   memory_port w0 bie    w0bie high
--   memory set_debug_mode w0 true
-- 
--   #-------- Definition of port 'r1'
--   memory add_port         r1 r
--   memory set_rw_mode      r1 ReadBeforeWrite
--   memory set_port_latency r1 1
--   memory set_port_access  r1 async
--   memory_port r1 do     r1do
--   memory_port r1 addr   r1addr
--   memory set_debug_mode r1 true
-- 
-- 

component fpga_sram_0000_ZMEM_mem_r 
  port (
      w0di : in  std_logic_vector (55 downto 0)
      ;w0addr : in std_logic_vector (7 downto 0)
      ;w0we : in  std_logic 
      ;w0bie : in  std_logic_vector (55 downto 0)
      ;w0clk : in  std_logic 
      ;r1do : out std_logic_vector (55 downto 0)
      ;r1addr : in std_logic_vector (7 downto 0)
       );
end component;

