-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Multiplicador puramente combinacional
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplicador is
    generic (
        largura_dado : natural
    );

    port (
        entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
        entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
        saida     : out std_logic_vector((2 * largura_dado - 1) downto 0)
    );
end multiplicador;

architecture comportamental of multiplicador is
begin
    saida <= std_logic_vector(signed(entrada_a) * signed(entrada_b));
end comportamental;