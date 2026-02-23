library ieee;
use ieee.std_logic_1164.all;

entity encrypt is
    generic(N: integer := 32 );
    port(
            plaintext: in std_logic_vector(63 downto 0);
            extended_key: in std_logic_vector(0 to (N+8)*16-1);
            ciphertext: out std_logic_vector(63 downto 0)
        );
end encrypt;

architecture rtl of encrypt is
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

    type wires_array_type is array(0 to N) of std_logic_vector(31 downto 0);
    signal msb_half_wires, lsb_half_wires : wires_array_type := (others => (others => '0'));

begin

U0: preprocess port map(
    input => plaintext, msb_half => msb_half_wires(0), lsb_half => lsb_half_wires(0),
    extended_key => extended_key(N*16 to (N+4)*16-1)  
);

iterative_generate: for r in 1 to N generate
begin
    U_i : iterative port map (
        msb_half_input => msb_half_wires(r-1), lsb_half_input => lsb_half_wires(r-1),
        extended_key => extended_key((r-1)*16 to r*16-1), msb_half_output => msb_half_wires(r),
        lsb_half_output => lsb_half_wires(r)
        );
end generate;

U_N: postprocess port map(
    msb_half => lsb_half_wires(N), lsb_half => msb_half_wires(N),
    extended_key => extended_key((N+4)*16 to (N+8)*16-1),
    output => ciphertext
);


end rtl;