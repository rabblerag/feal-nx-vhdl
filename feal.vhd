library IEEE;
use IEEE.std_logic_1164.all;

entity feal is
    generic (N: integer := 32);
    port (
            clk, rst, start, encrypt_bar : in std_logic;
            key : in std_logic_vector(127 downto 0);
            input_text : in std_logic_vector(63 downto 0);
            ready : out std_logic;
            output_text : out std_logic_vector(63 downto 0)
    );
end feal;

architecture rtl of feal is
    component control is
        generic (N: integer := 32);
        port (
                clk, rst, start, encrypt_bar, new_key: in std_logic;
                ready, key_start, enc_dec_start: out std_logic;
                enc_dec_round: out natural range 1 to N;
                key_round: out natural range 1 to N/2+4
        );  
    end component;
    
    component encrypt_decrypt is
        generic (N: integer := 32);
        port(
                clk, rst, encrypt_bar, enable: in std_logic; -- encrypt_bar = 0 -> Encryption; encrypt_bar = 1 -> Decryption
                input_text: in std_logic_vector(63 downto 0);
                extended_key: in std_logic_vector(0 to (N+8)*16-1);
                r: in natural range 1 to N; -- Round number
                output_text: out std_logic_vector(63 downto 0)
            );
    end component;

    component k is
        generic (N : integer := 32);
        port(
                k: in std_logic_vector(127 downto 0);
                counter: in natural range 1 to N/2+4;
                clk, rst, enable: in std_logic;
                extended_k: out std_logic_vector(0 to (N+8)*16 - 1)
            );

    end component;

    -- signal clk, rst, ready, done, key_enable, enc_dec_enable : std_logic;

    signal ready_sig, key_enable, new_key_sig, enc_dec_enable, encrypt_bar_reg, new_key_reg: std_logic;

    signal key_reg : std_logic_vector(127 downto 0);

    signal extended_key : std_logic_vector(0 to (N+8)*16-1);

    signal key_round_signal : natural range 1 to N/2+4;
    signal enc_dec_round_signal : natural range 1 to N;

    signal in_reg, out_reg : std_logic_vector(63 downto 0);


begin

U_control : control generic map (N => N) port map(
            clk => clk, rst => rst, start => start, encrypt_bar => encrypt_bar_reg, new_key => new_key_reg,
            ready => ready_sig, key_start => key_enable, enc_dec_start => enc_dec_enable,
            enc_dec_round => enc_dec_round_signal, key_round => key_round_signal
);

U_key : k generic map (N => N) port map(
    clk => clk, rst => rst, enable => key_enable, k => key_reg,
    counter => key_round_signal, extended_k => extended_key
);

U_encdec : encrypt_decrypt generic map (N => N) port map(
    clk => clk, rst => rst, encrypt_bar => encrypt_bar_reg, enable => enc_dec_enable,
    input_text => in_reg, extended_key => extended_key, r => enc_dec_round_signal,
    output_text => out_reg
);


key_reg_process: process (clk, rst, key, key_reg)
    variable key_diff : std_logic_vector(127 downto 0);
    variable is_new_key : std_logic := '0';

begin
    key_diff := key_reg xor key; -- If input key is same as stored, their bitwise xor will be all 0
    
    if key_diff = (0 to 127 => '0') then
        is_new_key := '0';
    else
        is_new_key := '1';
    end if;

    new_key_sig <= is_new_key;

    if rst = '1' then
        key_reg <= (others => '0');
    elsif rising_edge(clk) and (is_new_key and ready_sig) = '1' then
        key_reg <= key;
    end if;

end process;

registers: process (clk, rst)

begin

    if rst = '1' then
        in_reg <= (others => '0');
        output_text <= (others => '0');
        encrypt_bar_reg <= '0';
        new_key_reg <= '1';
    elsif rising_edge(clk) and ready_sig = '1' then
        in_reg <= input_text;
        output_text <= out_reg;
        encrypt_bar_reg <= encrypt_bar;
        new_key_reg <= new_key_sig;
    end if;


end process;

ready <= ready_sig;
    
    
    
end architecture rtl;