library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity s1 is
port(
x1: in std_logic_vector(7 downto 0);
x2: in std_logic_vector(7 downto 0);
y:  out std_logic_vector(7 downto 0)
);
end s1;

architecture easy of s1 is
  signal sum: std_logic_vector(7 downto 0);

  begin
    sum <= std_logic_vector(unsigned(x1) + unsigned(x2) + 1);
    y <= sum(5 downto 0) & sum(7 downto 6);
end easy;