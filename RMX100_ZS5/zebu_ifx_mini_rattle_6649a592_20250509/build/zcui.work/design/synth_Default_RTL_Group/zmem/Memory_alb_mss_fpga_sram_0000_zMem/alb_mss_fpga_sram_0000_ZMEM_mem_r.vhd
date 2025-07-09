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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity alb_mss_fpga_sram_0000_ZMEM_mem_r is 
  port (
      rw0di : in  std_logic_vector (127 downto 0)
      ;rw0do : out std_logic_vector (127 downto 0)
      ;rw0addr : in std_logic_vector (27 downto 0)
      ;rw0we : in  std_logic 
      ;rw0re : in  std_logic 
      ;rw0bie : in  std_logic_vector (127 downto 0)
      ;rw0clk : in  std_logic 
       );
end alb_mss_fpga_sram_0000_ZMEM_mem_r;

architecture zMem of alb_mss_fpga_sram_0000_ZMEM_mem_r is

-- synopsys translate_off
type mem_type is array (0 to 268435455) of std_logic_vector(127 downto 0);
signal mem : mem_type;

signal rw0do_reg0: std_logic_vector (127 downto 0);
-- synopsys translate_on

begin
-- synopsys translate_off
  rw0do <= rw0do_reg0;

process ( rw0clk )
  variable Y : integer ;
  begin

    --rw0
    if ( rw0clk'event and rw0clk = '1' ) then
      for N in 0 to 127 loop
        if ( (rw0we = '1') and (rw0bie((N/8)*8) = '1') ) then
          mem(conv_integer(rw0addr))(N) <= rw0di(N);
        end if;
      end loop;
      if ( (rw0re = '1') ) then
          rw0do_reg0 <= mem(conv_integer(rw0addr)); -- READ_BEFORE_WRITE
      end if;
    end if;
end process;

-- synopsys translate_on

end zMem;
