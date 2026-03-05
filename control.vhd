library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity control is
    generic (N: integer := 32);
    port (
            clk, rst, start, encrypt_bar: in std_logic;
            ready, done, key_start, enc_dec_start: out std_logic;
            key: in std_logic_vector(127 downto 0);
            enc_dec_round: out natural range 1 to N;
            key_round: out natural range 1 to N/2+4
    );  
end control;

architecture rtl of control is
    
    type state_type is (idle, key_sched, preproc, enc, dec, postproc, finished);
    signal state : state_type := idle;

    signal key_reg : std_logic_vector(127 downto 0);
    signal new_key : std_logic := '0';

    signal enc_counter : natural range 1 to N := 1;
    signal dec_counter : natural range N downto 1 := N;
    signal key_counter : natural range 1 to N/2+4 := 1;

begin

-- Register for storing key
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
            when idle => if new_key = '1' then state <= key_sched; else state <= preproc; end if;
            when key_sched => if key_counter = N/2+4 then state <= preproc; else state <= key_sched; end if;
            when preproc => if encrypt_bar = '0' then state <= enc; elsif encrypt_bar = '1' then state <= dec; end if;
            when enc => if enc_counter = N then state <= postproc; else state <= enc; end if;
            when dec => if dec_counter = 1 then state <= postproc; else state <= dec; end if;
            when postproc => state <= finished;
            when finished => state <= idle; 
        end case;
    end if;

end process;

output_state: process (state)
begin
    case state is
        when idle => done <= '0'; key_start <= '0'; enc_dec_start <= '0'; ready <= '1';
        when key_sched => done <= '0'; key_start <= '1'; enc_dec_start <= '0'; ready <= '0';
        when preproc => done <= '0'; key_start <= '0'; enc_dec_start <= '0'; ready <= '0';
        when enc => done <= '0'; key_start <= '0'; enc_dec_start <= '1'; ready <= '0';
        when dec => done <= '0'; key_start <= '0'; enc_dec_start <= '1'; ready <= '0';
        when postproc => done <= '0'; key_start <= '0'; enc_dec_start <= '0'; ready <= '0';
        when finished => done <= '1'; key_start <= '0'; enc_dec_start <= '0'; ready <= '1';
    end case;

end process;


counters: process (clk, rst)

begin
    if rst = '1' then
        key_counter <= 1;
    elsif rising_edge(clk) and state = key_sched then
            if key_counter = N/2+4 then
                key_counter <= 1;
            else
                key_counter <= key_counter + 1;
            end if;
    end if;

    if rst = '1' then
        enc_counter <= 1;
    elsif rising_edge(clk) and state = enc then
            if enc_counter = N then
                enc_counter <= 1;
            else
                enc_counter <= enc_counter + 1;
            end if;
    end if;

    if rst = '1' then
        dec_counter <= N;
    elsif rising_edge(clk) and state = dec then
            if dec_counter = 1 then
                dec_counter <= N;
            else
                dec_counter <= dec_counter - 1;
            end if;
    end if;

end process;

with encrypt_bar select
enc_dec_round <= enc_counter when '0',
                 dec_counter when '1',
                 0 when others;

key_round <= key_counter;

end architecture rtl;