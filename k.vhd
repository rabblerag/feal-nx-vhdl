library ieee;
use ieee.std_logic_1164.all;

entity k is
port(
k: in std_logic_vector(127 downto 0);
k_even: out std_logic_vector(15 downto 0);
k_odd: out std_logic_vector(15 downto 0)
);
end k;

architecture easy of k is
  component fk is
  port(
  a: in std_logic_vector(31 downto 0);
  b: in std_logic_vector(31 downto 0);
  f:  out std_logic_vector(31 downto 0)
  );
  end component;

  type type_1Dx1D is array(1 to 3) of std_logic_vector(31 downto 0);
  signal qr : type_1Dx1D;
  signal a0, b0: std_logic_vector(31 downto 0);

  begin
    a0 <= k(127 downto 96); 
    b0 <= k(95 downto 64);

    qr(0) <= k(63 downto 32) xor k(31 downto 0);
    qr(1) <= k(63 downto 32);
    qr(2) <= k(31 downto 0);
    f <= f3 & f2 & f1 & f0;
end easy;