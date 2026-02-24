library library IEEE;
use IEEE.std_logic_1164.all;

entity encrypt_decrypt is
    generic (N: integer := 32);
    port(
            clk, rst, encrypt_bar, done_flag: in std_logic; -- encrypt_bar = 0 -> Encryption; encrypt_bar = 1 -> Decryption
            input_text: in std_logic_vector(63 downto 0);
            extended_key: in std_logic_vector(0 to (N+8)*16-1);
            ciphertext: out std_logic_vector(63 downto 0)
        );
end encypt_decrypt;

architecture rtl of encrypt_decrypt is
    
        component preprocess is
    port(
        input, extended_key: in std_logic_vector(63 downto 0);
        -- When encrypting, msb_half=L0 and lsb_half=R0
        -- When decrypting, msb_half=RN and lsb_half=LN
        msb_half, lsb_half: out std_logic_vector(31 downto 0)
    );
    end component;

    component postprocess is
    port(
        -- When encrypting, msb_half=RN and lsb_half=LN
        -- When decrypting, msb_half=L0 and lsb_half=R0
        msb_half, lsb_half: in std_logic_vector(31 downto 0);
        extended_key: in std_logic_vector(63 downto 0);
        -- When encrypting, output is the ciphertext in the form (RN, LN)
        -- When decrypting, output is the plaintext in the form (L0, R0)
        output: out std_logic_vector(63 downto 0)
    );
    end component;

    component iterative is
    port(
        -- When encrypting, msb_half_input=L0 and lsb_half_input=R0
        -- When decrypting, msb_half_input=RN and lsb_half_input=LN
        msb_half_input, lsb_half_input: in std_logic_vector(31 downto 0);
        extended_key: in std_logic_vector(15 downto 0);
        -- When encrypting, msb_half_output=LN and lsb_half_output=RN
        -- When decrypting, msb_half_output=R0 and lsb_half_output=L0
        msb_half_output, lsb_half_output: out std_logic_vector(31 downto 0)
    );
    end component;

    signal preprocess_key, postprocess_key : std_logic_vector(0 to 63);
    signal input_text_reg, output_text_reg, preprocess_reg,


begin

    -- When encrypting, preprocess with K_N...K_N+3
    -- When decrypting, preprocess with K_N+4...K_N+7
    with encrypt_bar select 
    preprocess_key <= extended_key(N*16 to (N+4)*16-1) when '0',
                      extended_key((N+4)*16 to (N+8)*16-1) when '1',
                      (others => 'Z') when others;
    
    -- When encrypting, postprocess with K_N+4...K_N+7
    -- When decrypting, postprocess with K_N...K_N+3
    with encrypt_bar select
    postprocess_key <= extended_key((N+4)*16 to (N+8)*16-1) when '0',
                       extended_key(N*16 to (N+4)*16-1) when '1',
                      (others => 'Z') when others;

    
U_pre: preprocess port map(
    input => plaintext, msb_half => msb_half_wires(0), lsb_half => lsb_half_wires(0),
    extended_key => preprocess_key 
);


U_iter : iterative port map (
    msb_half_input => msb_half_wires(r-1), lsb_half_input => lsb_half_wires(r-1),
    extended_key => extended_key((r-1)*16 to r*16-1), msb_half_output => msb_half_wires(r),
    lsb_half_output => lsb_half_wires(r)
    );


U_post: postprocess port map(
    msb_half => lsb_half_wires(N), lsb_half => msb_half_wires(N),
    extended_key => postprocess_key,
    output => ciphertext
);


-- Flip-flops

d: process(clk, rst) 

begin

    if rst = '1' then
        input_text_reg <= (others => '0');
        output_text_reg <= (others => '0');
        preprocess_reg <= (others => '0');
        postprocess_reg <= (others => '0');
        iterative_reg <= (others => '0');
    elsif rising_edge(clk) then


    end if;


end d;


    
end architecture rtl;