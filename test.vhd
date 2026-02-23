-- Calculates extended key, then encrypts and decrypts some plaintext based on the extended key

library ieee;
use ieee.std_logic_1164.all;

entity test is
    port(
            clk: in std_logic;
            rst: std_logic;
            keytest: in std_logic_vector(0 to 127);
            dumoutput: out std_logic_vector(63 downto 0)
        );
end test;

architecture rtl of test is
    component k is
    generic (N : integer := 32);
    port(
    k: in std_logic_vector(127 downto 0);
    clk: in std_logic;
    rst: in std_logic;
    k_even: out std_logic_vector(15 downto 0);
    k_odd: out std_logic_vector(15 downto 0);
    extended_k: out std_logic_vector(0 to (N+8)*16-1);
    ready: out std_logic
    );
    end component;

    component encrypt is
    generic(N: integer := 32);
    port(
    plaintext: in std_logic_vector(63 downto 0);
    extended_key: in std_logic_vector(0 to (N+8)*16-1);
    ciphertext: out std_logic_vector(63 downto 0)
    );
    end component;

    component decrypt is
    generic(N: integer := 32);
    port(
    ciphertext: in std_logic_vector(63 downto 0);
    extended_key: in std_logic_vector(0 to (N+8)*16-1);
    plaintext: out std_logic_vector(63 downto 0)
    );
    end component;

    signal test_even, test_odd: std_logic_vector(15 downto 0);
    signal extension, extension_swap: std_logic_vector(0 to 639);

    signal test_ready: std_logic;
    signal dumminput: std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000";
    signal cipher: std_logic_vector(63 downto 0);

begin

U0: k port map(
    k => keytest, clk => clk, rst => rst, k_even => test_even, k_odd => test_odd,
    extended_k => extension, ready => test_ready
);

U1: encrypt port map(
    plaintext => dumminput, 
    extended_key => extension,
    ciphertext => cipher
);

U2: decrypt port map(
    ciphertext => cipher, 
    extended_key => extension,
    plaintext => dumoutput
);

end rtl;

-- add_force {/test/clk} -radix hex {0 0ns} {1 500000ps} -repeat_every 1000000ps
-- add_force {/test/rst} -radix hex {1 0ns}
-- add_force {/test/keytest} -radix hex {0123456789abcdef0123456789abcdef 0ns}
-- run 1000 ns
-- add_force {/test/rst} -radix hex {0 0ns}

-- extended key test:
-- 751971f984e9488688e5523b4ea47adefe405e769819eeac1bd42455dca0653b3e3246521cc134df778b771dd32484101ca8bc64a0dbbdd21f5f8f1c6b81b560196a9ab1e01581909f726643ad32683a