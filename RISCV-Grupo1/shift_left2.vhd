library ieee;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;

-- Deslocador à esquerda de 2 bits.

entity shift_left2 is
    port ( 
        signal_extend_in   :   in  std_logic_vector (31 downto 0);
        
        exit_sll2           :   out  std_logic_vector (31 downto 0)
    );
end shift_left2;

architecture Hardware of shift_left2 is

    begin
        -- Desloca-se 2 bits à esquerda da variável de entrada.
        exit_sll2 <= signal_extend_in(29 downto 0) & "00"; 

end Hardware;