library ieee;
use ieee.std_logic_1164.all;

-- Iterative calculation hardware is the same for encryption and decryption
entity iterative is
    port(
        -- When encrypting, msb_half_input=L0 and lsb_half_input=R0
        -- When decrypting, msb_half_input=RN and lsb_half_input=LN
        msb_half_input, lsb_half_input: in std_logic_vector(31 downto 0);
        extended_key: in std_logic_vector(15 downto 0);
        -- When encrypting, msb_half_output=LN and lsb_half_output=RN
        -- When decrypting, msb_half_output=R0 and lsb_half_output=L0
        msb_half_output, lsb_half_output: out std_logic_vector(31 downto 0)
    );
end iterative;

architecture rtl of iterative is
    component f is
        port(
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(15 downto 0);
        f:  out std_logic_vector(31 downto 0)
        );
    end component;

    signal f_out : std_logic_vector(31 downto 0);

begin

    U1: f port map(a => lsb_half_input, b => extended_key, f => f_out);
    
    lsb_half_output <= msb_half_input xor f_out;
    msb_half_output <= lsb_half_input;


end rtl;