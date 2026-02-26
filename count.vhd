library ieee;
use ieee.std_logic_1164.all;

entity count is
    generic(N : integer := 32);
    port(
            clk: in std_logic;
            rst: in std_logic;
            encrypt_bar: in std_logic;
            input_text: in std_logic_vector(63 downto 0);
            extended_key: in std_logic_vector(0 to (N+8)*16-1);
            output_text: out std_logic_vector(63 downto 0);
            idling: out std_logic  -- When idling = '1', unit is ready for new computation
                                   -- input changes during idling = '0' will be ignored
        );
end count;

architecture rtl of count is

    component encrypt_decrypt is
    generic (N: integer := 32);
    port(
            clk, rst, encrypt_bar: in std_logic; -- encrypt_bar = 0 -> Encryption; encrypt_bar = 1 -> Decryption
            input_text: in std_logic_vector(63 downto 0);
            extended_key: in std_logic_vector(0 to (N+8)*16-1);
            r: in natural range 0 to N-1; -- Round number
            output_text: out std_logic_vector(63 downto 0)
        );
    end component;

    signal counter: natural range 0 to N-1;
    signal precounter, postcounter: natural range 0 to 2;
    signal input_text_reg: std_logic_vector(63 downto 0);
    signal output_text_sig: std_logic_vector(63 downto 0);
    signal output_text_reg: std_logic_vector(63 downto 0);
    signal enable: std_logic;
    signal idling_sig: std_logic;

    begin
    
    enable <= '1' when input_text /= input_text_reg else '0';

k_r: process(clk, rst)
    
    begin
    if rst = '1' then
      counter <= 0;
      precounter <= 0;
      postcounter <= 0;
      idling_sig <= '1';
      input_text_reg <= (others => '1');
      output_text_reg <= (others => '0');
      
    elsif rising_edge(clk) then
        if (enable = '1') and (idling_sig = '1') then
            input_text_reg <= input_text;
            idling_sig <= '0';
            if encrypt_bar = '0' then counter <= 0 ; else counter <= N-1; end if;
            precounter <= 1;
        end if;
        
        if idling_sig = '0' then
            if precounter = 1 then
              precounter <= 2;

            elsif precounter = 2 then
                if encrypt_bar = '0' then
                    if counter < N-1 then
                        counter <= counter + 1;       -- Encryption
                    else 
                        precounter <= 0;
                        postcounter <= 1;
                    end if;
                else
                    if counter > 0 then
                        counter <= counter - 1;     -- Decryption
                    else 
                        precounter <= 0;
                        postcounter <= 1;
                    end if;
                end if;
            elsif postcounter = 1 then
                postcounter <= 2;
            elsif postcounter = 2 then
                output_text_reg <= output_text_sig;
                precounter <= 0;
                postcounter <= 0;
                counter <= 0;
                idling_sig <= '1'; 
            end if;
        end if;    
    end if;
    end process;



U1: encrypt_decrypt port map(
    clk => clk,
    rst => rst,
    encrypt_bar => encrypt_bar,
    input_text => input_text,
    extended_key => extended_key,
    r => counter,
    output_text => output_text_sig
);

output_text <= output_text_reg;
idling <= idling_sig;

end rtl;

-- extended key test:
-- 751971f984e9488688e5523b4ea47adefe405e769819eeac1bd42455dca0653b3e3246521cc134df778b771dd32484101ca8bc64a0dbbdd21f5f8f1c6b81b560196a9ab1e01581909f726643ad32683a








