-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Somador de n bits unsigned
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador is
	generic (
		largura_dado : natural
	);

	port (
		entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
		entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
		saida     : out std_logic_vector((largura_dado - 1) downto 0)
	);
end somador;

architecture dataflow of somador is
begin
	saida <= std_logic_vector(unsigned(entrada_a) + unsigned(entrada_b));
end dataflow;