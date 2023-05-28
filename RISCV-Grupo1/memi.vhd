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
  0 =>     "00000000110100000000010110010011",
  1 =>     "00000000000000000000011000010011",
  2 =>     "00000001000100000000011010010011",
  3 =>     "00000000000100000000010010010011",
  4 =>     "00000000000000000000100100010011",
  5 =>     "00000000000000000000100110010011",
  6 =>     "00000000000110010000100100010011",
  7 =>     "00000000100101100010000000100011",
  8 =>     "00000001001001011000011001100011",
  9 =>     "00000001000001100000011000010011",
  10 =>     "11111111000111111111000011101111",
  11 =>     "00000000000000000000001010010011",
  12 =>     "00000000000000000000011000010011",
  13 =>     "00000000000100000000100100010011",
  14 =>     "00000001001000000000001010110011",
  15 =>     "00000011001100101000001001100011",
  16 =>     "00000000000001100010001100000011",
  17 =>     "00000000000101100000011000010011",
  18 =>     "00000000000001100010001110000011",
  19 =>     "00000000011100110000111000110011",
  20 =>     "00000001110001101010000000100011",
  21 =>     "00000000000110011000100110010011",
  22 =>     "00000000000101101000011010010011",
  23 =>     "11111101110111111111000011101111",
  24 =>     "00000000000110010000100100010011",
  25 =>     "00000000101110010000111001100011",
  26 =>     "01000000010101100000011000110011",
  27 =>     "01000000010101101000011010110011",
  28 =>     "00000001000001101000011010010011",
  29 =>     "00000001000001100000011000010011",
  30 =>     "00000000000000000000100110010011",
  31 =>     "11111011110111111111000011101111",
  others =>     X"00000000");

	signal index : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
        begin
					index(29 downto 0)<= Endereco(31 downto 2);
					instrucao <= codigo(to_integer(unsigned(index))) when Endereco < x"10000000" else x"00000000";

end comportamental;