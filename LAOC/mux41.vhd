-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- MUX 4 para 1 com entrada de dados genérica
library ieee;
use ieee.std_logic_1164.all;

entity mux41 is
    generic (
        largura_dado : natural
    );
    port (
        dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
        sele_ent                                       : in std_logic_vector(1 downto 0);
        dado_sai                                       : out std_logic_vector((largura_dado - 1) downto 0)
    );
end mux41;

architecture dataflow of mux41 is
begin
    with sele_ent select
        dado_sai <= dado_ent_0 when "00",
        dado_ent_1 when "01",
        dado_ent_2 when "10",
        dado_ent_3 when others;
end dataflow;