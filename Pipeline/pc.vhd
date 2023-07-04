-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Program Counter tamanho genérico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
	signal aux : std_logic_vector (PC_WIDTH - 1 downto 0);
    signal entrou : std_logic;
    signal nop : std_logic_vector(PC_WIDTH - 1 downto 0) := "00000000000000000000011111111111";
	begin
		process (clk, reset, entrada, stall_pc, entrou,aux)
        begin
        if (reset = '1') then
            saida <= (others => '0');

        elsif rising_edge(clk) then
            if (entrou =  '1') then
                saida <= aux;
                entrou <= '0';
            elsif(stall_pc = '0') then 
                    saida <= entrada;
                    entrou <='0';
            elsif(stall_pc =  '1') then
                saida <= nop;
                aux <= entrada;
                entrou <= '1';

            end if;
        end if;
        end process;
end comportamental;

