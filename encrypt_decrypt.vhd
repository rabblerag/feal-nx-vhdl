library IEEE;
use IEEE.std_logic_1164.all;

entity encrypt_decrypt is
    generic (N: integer := 32);
    port(
            clk, rst, encrypt_bar, enable_in_out_ff: in std_logic; -- encrypt_bar = 0 -> Encryption; encrypt_bar = 1 -> Decryption
            input_text: in std_logic_vector(63 downto 0);
            extended_key: in std_logic_vector(0 to (N+8)*16-1);
            r: in natural range 0 to N-1; -- Round number
            output_text: out std_logic_vector(63 downto 0)
        );
end encrypt_decrypt;

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
    signal input_text_reg, preprocess_reg, postprocess_reg, iter_reg : std_logic_vector(63 downto 0);
    signal iter_in, preprocess_out, iter_out, postprocess_out : std_logic_vector(63 downto 0);
    signal r_reg: natural range 0 to N-1;


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
    input => input_text_reg, msb_half => preprocess_out(63 downto 32), lsb_half => preprocess_out(31 downto 0),
    extended_key => preprocess_key 
);


    with r_reg select
    iter_in <= preprocess_reg when 0,
                iter_reg when others;

U_iter : iterative port map (
    msb_half_input => iter_in(63 downto 32), lsb_half_input => iter_in(31 downto 0),
    extended_key => extended_key(r_reg*16 to (r_reg+1)*16-1), msb_half_output => iter_out(63 downto 32),
    lsb_half_output => iter_out(31 downto 0)
    );


U_post: postprocess port map(
    msb_half => iter_reg(31 downto 0), lsb_half => iter_reg(63 downto 32),
    extended_key => postprocess_key,
    output => postprocess_out
);

output_text <= postprocess_reg;

-- Flip-flops

d_with_en: process(clk, rst) 

begin

    if rst = '1' then
        input_text_reg <= (others => '0');
        postprocess_reg <= (others => '0');
    elsif rising_edge(clk) and enable_in_out_ff = '1' then
        input_text_reg <= input_text;
        postprocess_reg <= postprocess_out;
    end if;


end process;

d: process(clk, rst)

begin

    if rst = '1' then
        preprocess_reg <= (others => '0');
        iter_reg <= (others => '0');
        r_reg <= 0;
    elsif rising_edge(clk) then
        preprocess_reg <= preprocess_out;
        iter_reg <= iter_out;
        r_reg <= r;
    end if;

end process;


    
end architecture rtl;