-- Calculates extended key, then encrypts and decrypts some plaintext based on the extended key

library ieee;
use ieee.std_logic_1164.all;

entity count is
    generic(N : integer := 32);
    port(
            clk: in std_logic;
            rst: in std_logic;
            encrypt_bar: in std_logic;
            -- enable: std_logic;
            input_text: in std_logic_vector(63 downto 0);
            -- key_input: in std_logic_vector(0 to 127);
            extended_key: in std_logic_vector(0 to (N+8)*16-1);
            output_text: out std_logic_vector(63 downto 0)
        );
end count;

architecture rtl of count is
    -- component k is
    -- generic (N : integer := 32);
    -- port(
    -- k: in std_logic_vector(127 downto 0);
    -- clk: in std_logic;
    -- rst: in std_logic;
    -- k_even: out std_logic_vector(15 downto 0);
    -- k_odd: out std_logic_vector(15 downto 0);
    -- extended_k: out std_logic_vector(0 to (N+8)*16-1);
    -- ready: out std_logic
    -- );
    -- end component;

    component encrypt_decrypt is
    generic (N: integer := 32);
    port(
            clk, rst, encrypt_bar, enable_in_out_ff: in std_logic; -- encrypt_bar = 0 -> Encryption; encrypt_bar = 1 -> Decryption
            input_text: in std_logic_vector(63 downto 0);
            extended_key: in std_logic_vector(0 to (N+8)*16-1);
            r: in natural range 0 to N-1; -- Round number
            output_text: out std_logic_vector(63 downto 0)
            -- ready: out std_logic
        );
    end component;

    signal counter: natural range 0 to N-1;
    signal post_flag: std_logic;
    signal enable_in: std_logic;
    signal enable_out: std_logic;
    signal enable_in_out: std_logic;
    signal input_text_reg: std_logic_vector(63 downto 0);
    signal process_output: std_logic_vector(63 downto 0);
    begin

-- U0: k port map(
--     k => keytest, clk => clk, rst => rst, k_even => test_even, k_odd => test_odd,
--     extended_k => extension, ready => test_ready
-- );

-- signal preflag: std_logic;
    
    enable_in <= '1' when input_text /= input_text_reg else '0';
    enable_in_out <= enable_in xor enable_out;

k_r: process(clk, rst)
    
    begin
    if rst = '1' then
      counter <= 0;
      post_flag <= '0';
      enable_out <= '0';
      input_text_reg <= (others => '1');
    
      
    elsif rising_edge(clk) then
        if (enable_in = '1') then
            input_text_reg <= input_text;
            counter <=  0;
        elsif post_flag = '1' then
            enable_out <= '1';
        else
            if (counter /= N-1) then
              counter <= counter + 1;
            else 
              post_flag <= '1';
            end if;    
        end if;    
    end if;
    end process;



U1: encrypt_decrypt port map(
    clk => clk,
    rst => rst,
    encrypt_bar => encrypt_bar,
    enable_in_out_ff => enable_in_out,
    input_text => input_text,
    extended_key => extended_key,
    r => counter,
    output_text => output_text
);

end rtl;

-- add_force {/test/clk} -radix hex {0 0ns} {1 500000ps} -repeat_every 1000000ps
-- add_force {/test/rst} -radix hex {1 0ns}
-- add_force {/test/keytest} -radix hex {0123456789abcdef0123456789abcdef 0ns}
-- run 1000 ns
-- add_force {/test/rst} -radix hex {0 0ns}

-- extended key test:
-- 751971f984e9488688e5523b4ea47adefe405e769819eeac1bd42455dca0653b3e3246521cc134df778b771dd32484101ca8bc64a0dbbdd21f5f8f1c6b81b560196a9ab1e01581909f726643ad32683a



