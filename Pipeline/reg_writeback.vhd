-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- reg_writebacki de carga paralela de tamanho genérico com WE e reset síncrono em nível lógico 1
library ieee;
use ieee.std_logic_1164.all;

entity reg_writeback is
    port (
        i_memd: in std_logic_vector(31 downto 0);   
        i_ALUoutW: in std_logic_vector(31 downto 0);  
        i_WriteRegW: in std_logic_vector(31 downto 0);  
        clk         : in std_logic;
       
        o_memd: out std_logic_vector(31 downto 0);  
        o_ALUoutW : out std_logic_vector(31 downto 0);  
        o_WriteRegW : out std_logic_vector(31 downto 0);  

        --sinais de controle

         i_MUX_final                               :   in std_logic_vector(1 downto 0);
         i_RegWEN                       :   in std_logic;
         i_load_len                                :   in std_logic_vector(1 downto 0);

         o_MUX_final                               :   out std_logic_vector(1 downto 0);
         o_RegWEN                        :   out std_logic;
         o_load_len                                :   out std_logic_vector(1 downto 0)


    );
end reg_writeback;

architecture comportamental of reg_writeback is
begin
    process (clk) is
    begin
        if (rising_edge(clk) ) then
            o_memd <= i_memd;
            o_ALUoutW   <= i_ALUoutW;
            o_WriteRegW     <= i_WriteRegW;       
            o_MUX_final <= i_MUX_final;          
            o_RegWEN  <= i_RegWEN;       
            o_load_len      <= i_load_len;  
        end if;
    end process;
end comportamental;

