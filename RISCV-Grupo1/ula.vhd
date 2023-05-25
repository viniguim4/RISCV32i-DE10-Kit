-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade Lógica e Aritmética com capacidade para 8 operações distintas, além de entradas e saída de dados genérica.
-- Os três bits que selecionam o tipo de operação da ULA são os 3 bits menos significativos do OPCODE (vide aqrquivo: par.xls)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    generic (
        largura_dado : natural := 32
    );

    port (
        --entrada 
        entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
        entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
        seletor   : in std_logic_vector(3 downto 0);  -- é o aluoop
        --saida
        saida     : out std_logic_vector((largura_dado - 1) downto 0);
        b         : out std_logic
    );
end ula;

architecture comportamental of ula is
    signal resultado_ula : std_logic_vector((largura_dado - 1) downto 0);
    -- para checar se tem um beq , bgl ou blt
    signal aux : std_logic;

begin
    process (entrada_a, entrada_b, seletor, aux) is
    begin
        case(seletor) is
            --tipos R
            when "0000" => -- adicao
                resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
                aux <= '0';
            when "0001" => -- subtração
                resultado_ula <= std_logic_vector(signed(entrada_a) - signed(entrada_b));
                aux <= '0';
            when "0010" => -- sll
                resultado_ula <= std_logic_vector(shift_left(signed(entrada_a), to_integer(signed(entrada_b) ) ) );
                aux <= '0';
            when "0011" => -- slt
                if(unsigned(entrada_a) < unsigned(entrada_b)) then   resultado_ula<= x"00000001";
                else    resultado_ula <= x"00000000";
                end if;
                aux <= '0';
            when "0100" => --xor
                resultado_ula <= entrada_a xor entrada_b;
                aux <= '0';
            when "0101" => --srl
                resultado_ula <= std_logic_vector(shift_right(signed(entrada_a), to_integer(signed(entrada_b) ) ));
                aux <= '0';
            when "0110" => -- and
                resultado_ula <= entrada_a and entrada_b;
                aux <= '0';
            when "0111" => -- mul
                resultado_ula <= std_logic_vector(signed(entrada_a(15 downto 0)) * signed(entrada_b(15 downto 0)));
                aux <= '0';
            when "1000" => -- div
                resultado_ula <= std_logic_vector(signed(entrada_a) / signed(entrada_b));
                aux <= '0';
            when "1001" => -- or
                resultado_ula <= entrada_a or entrada_b;
                aux <= '0';
            -- tipo b
            when "1011" => --beq
                resultado_ula <= std_logic_vector(signed(entrada_a) - signed(entrada_b));
                if(entrada_a = entrada_b) then aux <= '1';
					 resultado_ula <= x"00000000";
                else aux <= '0';
                end if;
            when "1100" => --blt
                resultado_ula <= std_logic_vector(signed(entrada_a) - signed(entrada_b));
                if(entrada_a < entrada_b) then aux <= '1';
                else aux <= '0';
                end if;
            when "1101" => --bge
                resultado_ula <= std_logic_vector(signed(entrada_a) - signed(entrada_b));
                if(entrada_a >= entrada_b) then aux <= '1';
                else aux <= '0';
                end if;
            -- tipo u
            when "1110" => --lui
                resultado_ula <= std_logic_vector(shift_right(signed(entrada_a), 12 ));
                aux <= '0';

            -- faz nada
            when others => 
                resultado_ula <= X"00000000";
                aux <= '0';
        end case;
    end process;
    b <= aux; -- Valor da saída zero
    saida <= resultado_ula;
end comportamental;