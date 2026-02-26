library IEEE;
use IEEE.std_logic_1164.all;

entity feal is
    generic (N: integer := 32);
    port (
            clk, rst, start, encrypt : in std_logic;
            key : in std_logic_vector(127 downto 0);
            input_text : in std_logic_vector(63 downto 0);
            output_text : out std_logic_vector(63 downto 0);
    )
end feal;

architecture rtl of feal is
    
begin
    
    
    
end architecture rtl;