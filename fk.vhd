library ieee;
use ieee.std_logic_1164.all;

entity fk is
port(
a: in std_logic_vector(31 downto 0);
b: in std_logic_vector(31 downto 0);
f:  out std_logic_vector(31 downto 0)
);
end fk;

architecture easy of fk is
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

  signal a0, a1, a2, a3, b0, b1, b2, b3: std_logic_vector(7 downto 0);
  signal f0, f1, f2, f3: std_logic_vector(7 downto 0);
  signal u1_1, u1_2, u2_1, u2_2, u3_2, u4_2: std_logic_vector(7 downto 0);


  begin
    a0 <= a(7 downto 0);
    a1 <= a(15 downto 8);
    a2 <= a(23 downto 16);
    a3 <= a(31 downto 24);
    b0 <= b(7 downto 0);
    b1 <= b(15 downto 8);
    b2 <= b(23 downto 16);
    b3 <= b(31 downto 24);

    u1_1 <= a0 xor a1;
    u1_2 <= (a2 xor a3) xor b0;
    u2_1 <= f1 xor b1;
    u2_2 <= a2 xor a3;
    u3_2 <= f1 xor b2;
    u4_2 <= f2 xor b3;

U1: s1 port map (x1 => u1_1, x2 => u2_2, y => f1);
U2: s0 port map (x1 => u2_1, x2 => u2_2, y => f2);
U0: s0 port map (x1 => a0, x2 => u3_2, y => f0);
U3: s1 port map (x1 => a3, x2 => u4_2, y => f3);

    f <= f3 & f2 & f1 & f0;
end easy;