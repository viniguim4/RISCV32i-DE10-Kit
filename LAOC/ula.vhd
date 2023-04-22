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
        largura_dado : natural
    );

    port (
        entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
        entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
        seletor   : in std_logic_vector(2 downto 0);
        saida     : out std_logic_vector((largura_dado - 1) downto 0)
    );
end ula;

architecture comportamental of ula is
    signal resultado_ula : std_logic_vector((largura_dado - 1) downto 0);
begin
    process (entrada_a, entrada_b, seletor) is
    begin
        case(seletor) is
            when "000" => -- soma com sinal
            resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
            when "001" => -- soma estendida
            resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
            when "100" => -- and lógico
            resultado_ula <= entrada_a and entrada_b;
            when "101" => -- or lógico
            resultado_ula <= entrada_a or entrada_b;
            when "110" => -- xor lógico
            resultado_ula <= entrada_a xor entrada_b;
            when "111" => -- not lógico
            resultado_ula <= not(entrada_a);
            when others => -- xnor lógico
            resultado_ula <= entrada_a xnor entrada_b;
        end case;
    end process;
    saida <= resultado_ula;
end comportamental;