library IEEE;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.all;

-- porta logica and 

entity and_port is
    port (
        entrada1   :   in std_logic;
        entrada2   :   in std_logic;

        saida   :   out std_logic
    );
end and_port;

architecture behavior of and_port is
    begin
        saida <= entrada1 and entrada2;
end behavior;
