library ieee;
use ieee.std_logic_1164.all;

entity f is
port(
a: in std_logic_vector(31 downto 0);
b: in std_logic_vector(15 downto 0);
f:  out std_logic_vector(31 downto 0)
);
end f;

architecture easy of f is
  component s0 is
  port(
  x1: in std_logic_vector(7 downto 0);
  x2: in std_logic_vector(7 downto 0);
  y:  out std_logic_vector(7 downto 0)
  );
  end component;

  component s1 is
  port(
  x1: in std_logic_vector(7 downto 0);
  x2: in std_logic_vector(7 downto 0);
  y:  out std_logic_vector(7 downto 0)
  );
  end component;

  signal a0, a1, a2, a3, b0, b1: std_logic_vector(7 downto 0);
  signal s1_internal, s0_internal: std_logic_vector(7 downto 0);
  signal f0, f1, f2, f3: std_logic_vector(7 downto 0);

  begin
    a0 <= a(7 downto 0);
    a1 <= a(15 downto 8);
    a2 <= a(23 downto 16);
    a3 <= a(31 downto 24);
    b0 <= b(7 downto 0);
    b1 <= b(15 downto 8);

    s1_internal <= (b0 xor a1) xor a0;
    s0_internal <= (b1 xor a2) xor a3;
U1: s1 port map (x1 => s0_internal, x2 => s1_internal, y => f1);
U2: s0 port map (x1 => s0_internal, x2 => f1, y => f2);
U0: s0 port map (x1 => a0, x2 => f1, y => f0);
U3: s1 port map (x1 => a3, x2 => f2, y => f3);

    f <= f3 & f2 & f1 & f0;
end easy;