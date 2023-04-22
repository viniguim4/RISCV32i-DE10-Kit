-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Registrador de carga paralela de tamanho genérico com WE e reset síncrono em nível lógico 1
library ieee;
use ieee.std_logic_1164.all;

entity registrador is
    generic (
        largura_dado : natural
    );
    port (
        entrada_dados  : in std_logic_vector((largura_dado - 1) downto 0);
        WE, clk, reset : in std_logic;
        saida_dados    : out std_logic_vector((largura_dado - 1) downto 0)
    );
end registrador;

architecture comportamental of registrador is
begin
    process (clk) is
    begin
        if (rising_edge(clk)) then
            if (WE = '1') then
                saida_dados <= entrada_dados;
            end if;
            if (reset = '1') then
                saida_dados <= (others =>'0');
            end if;
        end if;
    end process;
end comportamental;