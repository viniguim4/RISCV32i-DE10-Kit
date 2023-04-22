-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Deslocador de barril com entrada e saída de dados genérica.
-- entrada com a quantidade de bits a ser deslocada como log2 da entrada genérica.
-- de acordo com o sinal de seleção faz as seguintes operações:
-- "00" deslocamento lógico para a direita
-- "01" deslocamento lógico para a esquerda
-- "10" deslocamento de rotação para a direita
-- "11" copia o conteúdo de rs para rd, equivale a uma rotação total do número de bits do deslocador para a direita
-- os dois bits que selecionam o tipo de deslocamento são os 2 bits menos significativos do opcode (vide aqrquivo: par.xls)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deslocador is
	generic (
		largura_dado : natural;
		largura_qtde : natural
	);

	port (
		ent_rs_dado           : in std_logic_vector((largura_dado - 1) downto 0);
		ent_rt_ende           : in std_logic_vector((largura_qtde - 1) downto 0); -- o campo de endereços de rt, representa a quantidade a ser deslocada nesse contexto.
		ent_tipo_deslocamento : in std_logic_vector(1 downto 0);
		sai_rd_dado           : out std_logic_vector((largura_dado - 1) downto 0)
	);
end deslocador;

architecture comportamental of deslocador is
	subtype temp_result is std_logic_vector((largura_dado - 1) downto 0);
	type temp_vetor is array (natural range <>) of temp_result;
	signal vetor_parcial : temp_vetor(largura_qtde downto 0);
begin
	vetor_parcial(0) <= ent_rs_dado;
	sai_rd_dado      <= vetor_parcial(largura_qtde);

	genstage : for i in 0 to largura_qtde - 1 generate
		process (vetor_parcial(i), ent_tipo_deslocamento, ent_rt_ende)
		begin
			if (ent_rt_ende(i) = '0') then
				vetor_parcial(i + 1) <= vetor_parcial(i); -- nop
			else
				if (ent_tipo_deslocamento = "00") then
					vetor_parcial(i + 1) <= ((2 ** i - 1) downto 0 => '0') & vetor_parcial(i)(largura_dado - 1 downto 2 ** i); -- srl                    
				elsif (ent_tipo_deslocamento = "01") then
					vetor_parcial(i + 1) <= vetor_parcial(i)((largura_dado - 2 ** i - 1) downto 0) & ((2 ** i - 1) downto 0 => '0'); -- sll
				elsif (ent_tipo_deslocamento = "10") then
					vetor_parcial(i + 1) <= vetor_parcial(i)((2 ** i - 1) downto 0) & vetor_parcial(i)(largura_dado - 1 downto 2 ** i); -- rr
				else                                                                                                                -- situação que ent_tipo_deslocamento = "11", ou seja, instrução "copy" ou "move", como queiram chamar.
					vetor_parcial(i + 1) <= vetor_parcial(i);
				end if;
			end if;
		end process;
	end generate;
end comportamental;