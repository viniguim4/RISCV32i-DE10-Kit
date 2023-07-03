-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Program Counter tamanho genérico
library ieee;
use ieee.std_logic_1164.all;

entity pc is
	generic (
		PC_WIDTH : natural := 32
	);
	port (
		entrada : in std_logic_vector (PC_WIDTH - 1 downto 0);
		saida   : out std_logic_vector(PC_WIDTH - 1 downto 0);
		clk     : in std_logic;
		reset, stall_pc   : in std_logic
	);
end entity;

architecture comportamental of pc is
	begin
		process (clk, reset, entrada)
		begin
		if (reset = '1') then
			saida <= (others => '0');
		elsif rising_edge(clk) then
			if( stall_pc = '0') then -- Only update if not stalled
			saida <= entrada;
			end if;
		end if;
		end process;
end comportamental;

