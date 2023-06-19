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
	process (clk, reset) is
	begin		
		if (rising_edge(clk)) then
			if (reset = '1') then
				saida <= (others => '0');
			elsif(stall_pc = '0') then
				saida <= entrada;
			elsif( stall_pc = '1') then
				wait until (falling_edge(clk));
			end if;
		end if;
	end process;
end comportamental;