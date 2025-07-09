-- ###--------------------------------------------------------------------### --
--   Copyright Emulation And Verification Engineering                         --
-- ###--------------------------------------------------------------------### --
--   VHDL memory wrapper                                                      --
-- ###--------------------------------------------------------------------### --


-- 
-- #-------- Basic definition of memory 'alb_mss_fpga_sram_0000_ZMEM_mem_r'
-- memory new                alb_mss_fpga_sram_0000_ZMEM_mem_r zrm
-- memory depth              268435456
-- memory width              128
-- memory set_word_length    8
-- 
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
--   #-------- Definition of port 'rw0'
--   memory add_port         rw0 rw
--   memory set_rw_mode      rw0 ReadBeforeWrite
--   memory set_port_latency rw0 1
--   memory set_port_access  rw0 sync
--   memory_port rw0 di     rw0di
--   memory_port rw0 do     rw0do
--   memory_port rw0 addr   rw0addr
--   memory_port rw0 clk    rw0clk posedge
--   memory_port rw0 we     rw0we high
--   memory_port rw0 re     rw0re high
--   memory_port rw0 fbie   rw0bie high
--   memory set_debug_mode rw0 false
-- 
-- 

component alb_mss_fpga_sram_0000_ZMEM_mem_r 
  port (
      rw0di : in  std_logic_vector (127 downto 0)
      ;rw0do : out std_logic_vector (127 downto 0)
      ;rw0addr : in std_logic_vector (27 downto 0)
      ;rw0we : in  std_logic 
      ;rw0re : in  std_logic 
      ;rw0bie : in  std_logic_vector (127 downto 0)
      ;rw0clk : in  std_logic 
       );
end component;

