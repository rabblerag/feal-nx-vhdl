library ieee;
use ieee.std_logic_1164.all;

entity k is
generic (N : integer := 32);
port(
k: in std_logic_vector(127 downto 0);
clk: in std_logic;
rst: in std_logic;
-- TO BE REMOVED ---------------------------
k_even: out std_logic_vector(15 downto 0);
k_odd: out std_logic_vector(15 downto 0);
--------------------------------------------
extended_k: out std_logic_vector(0 to (N+8)*16 - 1);
ready: out std_logic
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

  signal q_sel: natural range 0 to 2 := 0;
  signal counter: natural range 0 to N/2+5 := 0;
  
  signal a_reg, b_reg, d_reg, q, xor_1, xor_2, fk_out: std_logic_vector(31 downto 0);
    
  begin

    xor_1 <= d_reg xor b_reg;
    xor_2 <= xor_1 xor q;

    with q_sel select
      q <= k(63 downto 32) xor k(31 downto 0) when 0,
           k(63 downto 32)                    when 1,
           k(31 downto 0)                     when others;
    
    

U0: fk port map (a => a_reg , b => xor_2 , f => fk_out);

    k_even <= fk_out(31 downto 16);
    k_odd  <= fk_out(15 downto 0);

    k_r: process(clk, rst)
    
    begin
    if rst = '1' then
      a_reg <= k(127 downto 96);
      b_reg <= k(95 downto 64);
      d_reg <= (others => '0'); 
      q_sel <= 0;
      counter <= 1;
      ready <= '0';
    
    elsif rising_edge(clk) then
        if (counter = N/2+5) then 
          ready <= '1';
        else
          if(q_sel = 2) then q_sel <= 0;
          else q_sel <= q_sel + 1;
          end if;

          b_reg <= fk_out;
          a_reg <= b_reg;
          d_reg <= a_reg;
          counter <= counter + 1;

          extended_k(32*(counter - 1) to 32*(counter) - 17) <= fk_out(31 downto 16);
          extended_k(32*counter - 16 to 32*(counter) - 1) <= fk_out(15 downto 0);
          
        end if;        
    end if;
    end process;
    end easy;


-- add_force {/k/k} -radix hex {0123456789abcdef0123456789abcdef 0ns}
-- add_force {/k/clk} -radix hex {0 0ns} {1 500000ps} -repeat_every 1000000ps
-- add_force {/k/rst} -radix hex {1 0ns}
-- run 1000 ns
-- add_force {/k/rst} -radix hex {0 0ns}