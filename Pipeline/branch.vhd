library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
 entity branch is 
 port (
    --entrada 
    entrada_a : in std_logic_vector(31 downto 0);
    entrada_b : in std_logic_vector(31 downto 0);
    seletor   : in std_logic_vector(3 downto 0);  -- é o aluoop
    --saida
    pcSrcD     : out std_logic
);
end branch;
 
architecture comportamental of branch is
    signal aux : std_logic;

begin
    process (entrada_a, entrada_b, seletor, aux) is
    begin
        case(seletor) is
            -- tipo b
            when "1011" => --beq
                if(entrada_a = entrada_b) then aux <= '1';
                else aux <= '0';
                end if;
            when "1100" => --blt
                if(entrada_a < entrada_b) then aux <= '1';
                else aux <= '0';
                end if;
            when "1101" => --bge
                if(entrada_a >= entrada_b) then aux <= '1';
                else aux <= '0';
                end if;
            -- faz nada
            when others => 
            aux <= '0';
    end case;
    end process;
    pcSrcD <= aux; -- Valor da saída zero

end comportamental;