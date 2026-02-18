library ieee;
use ieee.std_logic_1164.all;

-- Postprocessing hardware is the same for encryption and decryption
entity postprocess is
    port(
        -- When encrypting, msb_half=RN and lsb_half=LN
        -- When decrypting, msb_half=L0 and lsb_half=R0
        msb_half, lsb_half: in std_logic_vector(31 downto 0);
        extended_key: in std_logic_vector(63 downto 0);
        -- When encrypting, output is the ciphertext in the form (RN, LN)
        -- When decrypting, output is the plaintext in the form (L0, R0)
        output: out std_logic_vector(63 downto 0)
    );
end postprocess;

architecture rtl of postprocess is

    signal temp_lsb_half: std_logic_vector(31 downto 0);

begin

    temp_lsb_half <= lsb_half xor msb_half;

    output <= (msb_half & temp_lsb_half) xor extended_key;

end rtl;