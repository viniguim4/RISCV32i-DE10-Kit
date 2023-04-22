-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Banco de registradores com entradas e saída de dados de tamanho genérico
-- entradas de endereço de tamanho genérico
-- clock e sinal de WE
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_registradores is
    generic (
        largura_dado : natural;
        largura_ende : natural
    );

    port (
        ent_Rs_ende : in std_logic_vector((largura_ende - 1) downto 0);
        ent_Rt_ende : in std_logic_vector((largura_ende - 1) downto 0);
        ent_Rd_ende : in std_logic_vector((largura_ende - 1) downto 0);
        ent_Rd_dado : in std_logic_vector((largura_dado - 1) downto 0);
        sai_Rs_dado : out std_logic_vector((largura_dado - 1) downto 0);
        sai_Rt_dado : out std_logic_vector((largura_dado - 1) downto 0);
        clk, WE     : in std_logic
    );
end banco_registradores;

architecture comportamental of banco_registradores is
    type registerfile is array(0 to ((2 ** largura_ende) - 1)) of std_logic_vector((largura_dado - 1) downto 0);
    signal banco : registerfile;
begin
    leitura : process (clk) is
    begin
        -- lê o registrador de endereço Rs da instrução apontada por PC no ciclo anterior,
        -- lê o registrador de endereço Rt da instrução apontada por PC no ciclo anterior.
        sai_Rs_dado <= banco(to_integer(unsigned(ent_Rs_ende)));
        sai_Rt_dado <= banco(to_integer(unsigned(ent_Rt_ende)));
    end process;

    escrita : process (clk) is
    begin
        if rising_edge(clk) then
            if WE = '1' then
                banco(to_integer(unsigned(ent_Rd_ende))) <= ent_Rd_dado;
            end if;
        end if;
    end process;
end comportamental;