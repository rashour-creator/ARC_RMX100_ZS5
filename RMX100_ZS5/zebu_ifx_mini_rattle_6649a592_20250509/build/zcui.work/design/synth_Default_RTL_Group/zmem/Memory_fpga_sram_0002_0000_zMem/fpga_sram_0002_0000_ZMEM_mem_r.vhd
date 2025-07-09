-- ###--------------------------------------------------------------------### --
--   Copyright Emulation And Verification Engineering                         --
-- ###--------------------------------------------------------------------### --
--   VHDL memory wrapper                                                      --
-- ###--------------------------------------------------------------------### --


-- 
-- #-------- Basic definition of memory 'fpga_sram_0002_0000_ZMEM_mem_r'
-- memory new                fpga_sram_0002_0000_ZMEM_mem_r uram
-- memory depth              131072
-- memory width              40
-- memory set_word_length    8
-- 
-- 
-- #-------- Memory advanced definition
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
--   #-------- Definition of port 'r2'
--   memory add_port         r2 r
--   memory set_rw_mode      r2 ReadBeforeWrite
--   memory set_port_latency r2 1
--   memory set_port_access  r2 async
--   memory_port r2 do     r2do
--   memory_port r2 addr   r2addr
--   memory set_debug_mode r2 true
-- 
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity fpga_sram_0002_0000_ZMEM_mem_r is 
  port (
      w0di : in  std_logic_vector (39 downto 0)
      ;w0addr : in std_logic_vector (16 downto 0)
      ;w0we : in  std_logic 
      ;w0clk : in  std_logic 
      ;r1do : out std_logic_vector (39 downto 0)
      ;r1addr : in std_logic_vector (16 downto 0)
      ;r2do : out std_logic_vector (39 downto 0)
      ;r2addr : in std_logic_vector (16 downto 0)
       );
end fpga_sram_0002_0000_ZMEM_mem_r;

architecture zMem of fpga_sram_0002_0000_ZMEM_mem_r is

-- synopsys translate_off
type mem_type is array (0 to 131071) of std_logic_vector(39 downto 0);
signal mem : mem_type;

signal r1do_reg0: std_logic_vector (39 downto 0);
signal r2do_reg1: std_logic_vector (39 downto 0);
-- synopsys translate_on

begin
-- synopsys translate_off
  r1do <= r1do_reg0;
  r2do <= r2do_reg1;

process ( w0clk,  r1addr,  mem,  r2addr )
  variable Y : integer ;
  begin

    --w0
    if ( w0clk'event and w0clk = '1' ) then
      for N in 0 to 39 loop
        if ( (w0we = '1') ) then
          mem(conv_integer(w0addr))(N) <= w0di(N);
        end if;
      end loop;
    end if;
        r1do_reg0 <= mem(conv_integer(r1addr)); -- READ_BEFORE_WRITE
        r2do_reg1 <= mem(conv_integer(r2addr)); -- READ_BEFORE_WRITE
end process;

-- synopsys translate_on

end zMem;
