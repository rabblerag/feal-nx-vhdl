library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity control is
    generic (N: integer := 32);
    port (
            clk, rst, start, do_encrypt: in std_logic;
            encrypt_bar, done, key_start, enc_dec_start: out std_logic;
            key: in std_logic_vector(127 downto 0);
            enc_dec_round: out natural range 0 to N-1;
            key_round: out natural range 0 to N/2+3
    );  
end control;

architecture rtl of control is
    
    type state_type is (idle, key_sched, preproc, enc_dec, postproc, finished);
    signal state : state_type := idle;

    signal key_reg : std_logic_vector(127 downto 0);
    signal new_key, key_counter_enable, enc_dec_counter_enable : std_logic := '0';

    signal enc_dec_counter : natural range 0 to N;
    signal key_counter : natural range 0 to N/2+4;

    constant key_counter_len : integer := integer(ceil(log2(real(N/2)+real(5))));
    constant enc_dec_counter_len : integer := integer(ceil(log2(real(N)+real(1))));

begin

    encrypt_bar <= start xnor do_encrypt;

-- Register for storing key
key_reg_process: process (clk, rst)
    variable key_diff : std_logic_vector(127 downto 0);
    variable is_new_key : std_logic := '0';

begin
    key_diff := key_reg xor key; -- If input key is same as stored, their bitwise xor will be all 0
    -- Iterate over all bits. If even 1 is on, the keys are different
    
    if key_diff = (0 to 127 => '0') then
        is_new_key := '0';
    else
        is_new_key := '1';
    end if;

    new_key <= is_new_key;

    if rst = '1' then
        key_reg <= (others => '0');
    elsif rising_edge(clk) and (is_new_key and start) = '1' then
        key_reg <= key;
    end if;

end process;

-- State machine 
d: process (clk, rst)

begin

    if rst = '1' then
        state <= idle;
    elsif rising_edge(clk) and start = '1' then
        case state is
            when idle => if new_key = '1' then state <= key_sched; else state <= enc_dec; end if;
            when key_sched => if key_counter = N/2+4 then state <= enc_dec; else state <= key_sched; end if;
            when preproc => state <= enc_dec;
            when enc_dec => if enc_dec_counter = N then state <= postproc; else state <= enc_dec; end if;
            when postproc => state <= finished;
            when finished => state <= idle; 
        end case;
    end if;

end process;

output_state: process (state)
begin
    case state is
        when idle => done <= '0'; key_start <= '0'; enc_dec_start <= '0';
        when key_sched => done <= '0'; key_start <= '1'; enc_dec_start <= '0';
        when preproc => done <= '0'; key_start <= '0'; enc_dec_start <= '0';
        when enc_dec => done <= '0'; key_start <= '0'; enc_dec_start <= '1';
        when postproc => done <= '0'; key_start <= '0'; enc_dec_start <= '0';
        when finished => done <= '1'; key_start <= '0'; enc_dec_start <= '0';
    end case;

end process;


counters: process (clk, rst)

begin
    if rst = '1' then
        key_counter <= 0;
    elsif rising_edge(clk) and state = key_sched then
            if key_counter = N/2+4 then
                key_counter <= 0;
            else
                key_counter <= key_counter + 1;
            end if;
    end if;

    if rst = '1' then
        enc_dec_counter <= 0;
    elsif rising_edge(clk) and state = enc_dec then
            if enc_dec_counter = N then
                enc_dec_counter <= 0;
            else
                enc_dec_counter <= enc_dec_counter + 1;
            end if;
    end if;
end process;

enc_dec_round <= enc_dec_counter;
key_round <= key_counter;

end architecture rtl;