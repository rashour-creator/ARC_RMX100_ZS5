-- ###--------------------------------------------------------------------### --
--   Copyright Emulation And Verification Engineering                         --
-- ###--------------------------------------------------------------------### --
--   VHDL memory wrapper                                                      --
-- ###--------------------------------------------------------------------### --


-- 
-- #-------- Basic definition of memory 'zz_Encrypt_6_ZMEM_0'
-- memory new                zz_Encrypt_6_ZMEM_0 bram
-- memory depth              1024
-- memory width              4
-- memory set_word_length    8
-- 
-- memory enable_bram_dual_port_multiplexed  true
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
--   memory set_port_access  r1 sync
--   memory_port r1 do     r1do
--   memory_port r1 addr   r1addr
--   memory_port r1 clk    w0clk posedge
--   memory set_debug_mode r1 true
-- 
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity zz_Encrypt_6_ZMEM_0 is 
  port (
      w0di : in  std_logic_vector (3 downto 0)
      ;w0addr : in std_logic_vector (9 downto 0)
      ;w0we : in  std_logic 
      ;w0clk : in  std_logic 
      ;r1do : out std_logic_vector (3 downto 0)
      ;r1addr : in std_logic_vector (9 downto 0)
       );
end zz_Encrypt_6_ZMEM_0;

architecture zMem of zz_Encrypt_6_ZMEM_0 is

-- synopsys translate_off
type mem_type is array (0 to 1023) of std_logic_vector(3 downto 0);
signal mem : mem_type;

signal r1do_reg0: std_logic_vector (3 downto 0);
-- synopsys translate_on

begin
-- synopsys translate_off
  r1do <= r1do_reg0;

process ( w0clk )
  variable Y : integer ;
  begin

    --w0
    if ( w0clk'event and w0clk = '1' ) then
      for N in 0 to 3 loop
        if ( (w0we = '1') ) then
          mem(conv_integer(w0addr))(N) <= w0di(N);
        end if;
      end loop;
    end if;

    --r1
    if ( w0clk'event and w0clk = '1' ) then
        r1do_reg0 <= mem(conv_integer(r1addr)); -- READ_BEFORE_WRITE
    end if;
end process;

-- synopsys translate_on

end zMem;
