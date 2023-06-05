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
		extendop	: in std_logic_vector(2 downto 0);				 
		saida      : out std_logic_vector(31 downto 0)
	);
end extensor;

architecture behavior of extensor is
	--signal extensao_20 : std_logic_vector(19 downto 0);	--20 bits
	signal aux_12 : std_logic_vector(11 downto 0);		--12 bits
	signal extensao_12 : std_logic_vector(11 downto 0); --12 bits JAL
	signal aux_20 : std_logic_vector(19 downto 0);		--20 bits JAL
begin
	process (extendop, entrada_Rs, aux_12, extensao_12, aux_20)
	variable tipo_i : std_logic_vector(31 downto 0);
	variable extensao_20 : std_logic_vector(19 downto 0);
	begin
	extensao_20 := (others => entrada_Rs(31));
	tipo_i := (extensao_20 & entrada_Rs(31 downto 20));
	
			if (extendop = "000") then   -- instrucao tipo i
				saida <= tipo_i;	  					
			elsif (extendop = "001" ) then --  instrução tipo b			
				aux_12 <=  entrada_Rs(31)  & entrada_Rs(7) & entrada_Rs(30 downto 25) & entrada_Rs(11 downto 8);
				saida <= std_logic_vector(shift_right(unsigned(extensao_20 & aux_12), 1) -1  );   
			elsif (extendop = "010" ) then --  instrução tipo s			
				aux_12 <=  entrada_Rs(31)  & entrada_Rs(7) & entrada_Rs(30 downto 25) & entrada_Rs(11 downto 8);
				saida <= std_logic_vector(shift_right(unsigned(extensao_20 & aux_12), 1) );   
			elsif (extendop = "011" ) then --  instrução tipo u			
				saida <= entrada_Rs(31 downto 12) &  "000000000000";
				--saida <= std_logic_vector( shift_left( entrada_Rs(31 downto 12) ,12)) & ;
			else  --instrucao tipo j -- arrumar
				extensao_12 <= ((others => entrada_Rs(largura_dado - 1)));
				aux_20 <= entrada_Rs(31) & entrada_Rs(19 downto 12) & entrada_Rs(20) & entrada_Rs(30 downto 21);
				saida <= std_logic_vector(shift_right(unsigned(extensao_12 & aux_20), 1) );  
		end if;
	end process;
 	-- todos os bits da extensão correspondem ao bit mais significativo da entrada Rs
end behavior;
