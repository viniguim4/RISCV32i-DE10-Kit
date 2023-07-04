-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Memória de Programas ou Memória de Instruções de tamanho genérico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memi is
	generic (
		INSTR_WIDTH   : natural := 32; -- tamanho da instrucaoo em numero de bits
		MI_ADDR_WIDTH : natural := 32 -- tamanho do endereco da memoria de instrucoes em numero de bits
	);
	port (
		clk       : in std_logic;
		reset     : in std_logic;
		Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
		Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
	);
end entity;

architecture comportamental of memi is
	type rom_type is array (0 to 2 ** 11 - 1) of std_logic_vector(INSTR_WIDTH - 1 downto 0);
	--signal aux : std_logic_vector(32 downto 0);
	constant codigo : rom_type := (
		0 =>     "00000000011100000000010110010011", --addi 00
		1 =>     "00000000011100000000011000010011", --addi 04
		2 =>     "00000000000000000000000000010011", --nop  08
		3 =>     "00000000000000000000000000010011", --nop  12
		4 =>     "00000000000000000000000000010011", --nop	16
		5 =>     "00000000110001011000011010110011", --add	20
		6 =>     "00000000110001011000100001100011", --beq	24
		7 =>     "00000000100000000000011100010011", --addi	28
		8 =>     "00000000100000000000011110010011", --addi 32
		9 =>     "00000000100000000000100000010011", --addi 36
		10 =>     "00000000011000000000100010010011",--addi 40 branch
		others =>     X"00000013");

	signal index : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
        begin
					index(29 downto 0)<= Endereco(31 downto 2);
					instrucao <= codigo(to_integer(unsigned(index))) when Endereco < x"10000000" else x"00000000";

end comportamental;