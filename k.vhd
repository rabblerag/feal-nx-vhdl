library ieee;
use ieee.std_logic_1164.all;

entity k is
generic (N : integer := 32);
port(
k: in std_logic_vector(127 downto 0);
counter: in natural range 1 to N/2+4;
clk, rst, enable: in std_logic;
extended_k: out std_logic_vector(0 to (N+8)*16 - 1)
);
end k;

architecture rtl of k is
  component fk is
  port(
  a: in std_logic_vector(31 downto 0);
  b: in std_logic_vector(31 downto 0);
  f:  out std_logic_vector(31 downto 0)
  );
  end component;
  
  signal a_reg, b_reg, d_reg, a_in, b_in, d_in, q, xor_out, fk_out: std_logic_vector(31 downto 0);
  signal k_reg : std_logic_vector(127 downto 0);
  signal extended_key_reg : std_logic_vector(0 to (N+8)*16-1);
    
  begin

    xor_out <= (d_reg xor b_reg) xor q;

    with (counter mod 3) select
      q <= k_reg(63 downto 32) xor k_reg(31 downto 0) when 1,
           k_reg(63 downto 32)                    when 2,
           k_reg(31 downto 0)                     when others;

    with counter select
      a_in <= k_reg(127 downto 96) when 1,
              b_reg when others;
    
    with counter select
      b_in <= k_reg(95 downto 64) when 1,
              fk_out when others;
    
    with counter select
      d_in <= (others => '0') when 1,
              a_reg when others;
    
    

U0: fk port map (a => a_reg , b => xor_out , f => fk_out);

k_r: process(clk, rst)
    
begin
  if rst = '1' then
    a_reg <= (others => '0');
    b_reg <= (others => '0');
    d_reg <= (others => '0');
    extended_key_reg <= (others => '0');
  
  elsif rising_edge(clk) and enable = '1' then
      b_reg <= b_in;
      a_reg <= a_in;
      d_reg <= d_in;

      extended_key_reg <= extended_key_reg(0 to (N+6)*16-1) & fk_out;

  end if;

  if rst = '1' then
    k_reg <= (others => '0');
  elsif rising_edge(clk) and (enable = '1' and counter = 1) then
      k_reg <= k;
  end if;
    

end process;

extended_k <= extended_key_reg;
end rtl;


-- add_force {/k/k} -radix hex {0123456789abcdef0123456789abcdef 0ns}
-- add_force {/k/clk} -radix hex {0 0ns} {1 500000ps} -repeat_every 1000000ps
-- add_force {/k/rst} -radix hex {1 0ns}
-- run 1000 ns
-- add_force {/k/rst} -radix hex {0 0ns}