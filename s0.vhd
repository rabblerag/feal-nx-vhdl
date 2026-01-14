library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity s0 is
port(
x1: in std_logic_vector(7 downto 0);
x2: in std_logic_vector(7 downto 0);
y:  out std_logic_vector(7 downto 0)
);
end s0;

architecture easy of s0 is
  signal sum: std_logic_vector(7 downto 0);

  begin
    sum <= std_logic_vector(unsigned(x1) + unsigned(x2));
    y <= sum(5 downto 0) & sum(7 downto 6);
end easy;