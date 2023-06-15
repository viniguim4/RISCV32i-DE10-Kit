-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- reg_memi de carga paralela de tamanho genérico com WE e reset síncrono em nível lógico 1
library ieee;
use ieee.std_logic_1164.all;

entity reg_decod is
    port (
        entrada_memi    : in std_logic_vector(31 downto 0);
        entrada_pc4    : in std_logic_vector(31 downto 0);
        clk, clear      : in std_logic;
        stalld         : in std_logic;
        saida_memi    : out std_logic_vector(31 downto 0);
        saida_pc4     : out std_logic_vector(31 downto 0)
    );
end reg_decod;

architecture comportamental of reg_decod is
begin
    process (clk) is
    begin
        if (rising_edge(clk) ) then
            if(stalld = '0') then
                saida_memi <= entrada_memi ;
                saida_pc4 <= entrada_pc4 ;
            elsif (clear = '1') then
                saida_memi <= (others =>'0');
                saida_pc4 <= (others =>'0');
            elsif(stalld = '1') then
                wait until (falling_edge(clk));
            end if;
        end if;
    end process;
end comportamental;

