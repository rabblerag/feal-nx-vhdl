library ieee;
use ieee.std_logic_1164.all;

-- Preprocessing hardware is the same for encryption and decryption
entity preprocess is
    port(
        input, extended_key: in std_logic_vector(63 downto 0);
        -- When encrypting, msb_half=L0 and lsb_half=R0
        -- When decrypting, msb_half=RN and lsb_half=LN
        msb_half, lsb_half: out std_logic_vector(31 downto 0)
    );
end preprocess;

architecture rtl of preprocess is

    signal input_xor_key : std_logic_vector(63 downto 0);

begin

    input_xor_key <= input xor extended_key;

    msb_half <= input_xor_key(63 downto 32);
    lsb_half <= input_xor_key(63 downto 32) xor input_xor_key(31 downto 0);

end rtl;