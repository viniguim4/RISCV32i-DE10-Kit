-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Extensor de sinais. Replica o bit de sinal da entrada Rs (largura_saida-largura_dado) vezes.
library ieee;
use ieee.std_logic_1164.all;

entity extensor is
	generic (
		largura_dado  : natural := 32;  
		largura_saida : natural := 32
	);

	port (
		entrada_Rs : in std_logic_vector((largura_dado - 1) downto 0); -- 
		extend_sel	: in    std_logic_vector(1 downto 0);
		saida      : out std_logic_vector((largura_saida - 1) downto 0)
	);
end extensor;

architecture dataflow of extensor is
	signal extensao : std_logic_vector((largura_dado - 1) downto 0);
	signal extensao_menor : std_logic_vector(19 downto 0);
	signal aux : std_logic_vector(11 downto 0);
begin
	case extend_sel is
		when "00" =>   -- instrucao tipo i
			extensao <= (others => entrada_Rs(largura_dado - 1));
			saida    <= extensao & entrada_Rs;  
		when "01" => --  instrução tipo s
			aux <= entrada_Rs(11 downto 8) & entrada_Rs(30 downto 25) & entrada_Rs(7) & entrada_Rs(31) ; -- 12 bits
			extensao_menor <= (other => '0');
			saida    <= extensao & aux;    
		when others => -- tipo 
	end case;


 -- todos os bits da extensão correspondem ao bit mais significativo da entrada Rs
	saida    <= extensao & entrada_Rs;                    -- saida com o sinal estendido de Rs, concatenado com Rs. 
end dataflow;