-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Extensor de sinais. Replica o bit de sinal da entrada Rs (largura_saida-largura_dado) vezes.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity extensor is
	generic (
		largura_dado  : natural := 32;  
		largura_saida : natural := 32
	);

	port (
		entrada_Rs : in std_logic_vector((largura_dado - 1) downto 0); 		
		extendop	: in std_logic_vector(1 downto 0);				 
		saida      : out std_logic_vector(31 downto 0)
	);
end extensor;

architecture behavior of extensor is
	--signal extensao_20 : std_logic_vector(19 downto 0);	--20 bits
	signal aux_12 : std_logic_vector(11 downto 0);		--12 bits
	signal extensao_12 : std_logic_vector(11 downto 0); --12 bits JAL
	signal aux_20 : std_logic_vector(19 downto 0);		--20 bits JAL
begin
	process (extendop, entrada_Rs)
	variable tipo_i : std_logic_vector(31 downto 0);
	variable extensao_20 : std_logic_vector(19 downto 0);
	begin
	extensao_20 := (others => entrada_Rs(31));
	tipo_i := (extensao_20 & entrada_Rs(31 downto 20));
	
			if (extendop = "00") then   -- instrucao tipo i
				--extensao_20 <= (others => entrada_Rs(largura_dado - 1));
				--aux_12 <= entrada_Rs(31 downto 20);
				saida <= tipo_i;	  					
			elsif (extendop = "01" ) then --  instrução tipo s			
				aux_12 <= entrada_Rs(11 downto 8) & entrada_Rs(30 downto 25) & entrada_Rs(7) & entrada_Rs(31) ; -- 12 bits 
				--extensao_20 <= (others => entrada_Rs(11)); --20 bits	
				saida <= aux_12 & extensao_20; -- 20 + 12 = 32 bits    
			else  --instrucao tipo j -- arrumar
				extensao_12 <= ((others => entrada_Rs(largura_dado - 1)));
				aux_20 <= entrada_Rs(31) & entrada_Rs(21 downto 12) & entrada_Rs(22) & entrada_Rs(30 downto 23);
				saida <= extensao_12 & aux_20;
		end if;
	end process;
 	-- todos os bits da extensão correspondem ao bit mais significativo da entrada Rs
end behavior;
