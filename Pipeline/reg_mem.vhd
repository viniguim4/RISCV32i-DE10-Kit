-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- reg_memi de carga paralela de tamanho genérico com WE e reset síncrono em nível lógico 1
library ieee;
use ieee.std_logic_1164.all;

entity reg_mem is
    port (
        i_alu: in std_logic_vector(31 downto 0);   
        i_WriteDataE : in std_logic_vector(31 downto 0);  
        i_WriteRegE : in std_logic_vector(4 downto 0);  
        clk         : in std_logic;
       
        o_alu: out std_logic_vector(31 downto 0);  
        o_WriteDataM : out std_logic_vector(31 downto 0);  
        o_WriteRegM  : out std_logic_vector(4 downto 0);  

        --sinais de controle
         --sinais enviados para multiplexadores

         i_MUX_final                               :   in std_logic_vector(1 downto 0);
         --sinal para blocos
         i_RegWEN, i_mem_sel                         :   in std_logic;
         --sinal enviado para o banco de registradores
         i_load_len                                :   in std_logic_vector(1 downto 0);
         i_store_len                               :   in std_logic_vector(1 downto 0);   

         o_MUX_final                               :   out std_logic_vector(1 downto 0);
         --sinal para blocos
         o_RegWEN, o_mem_sel                         :   out std_logic;
         --sinal enviado para o banco de registradores
         o_load_len                                :   out std_logic_vector(1 downto 0);
         o_store_len                               :   out std_logic_vector(1 downto 0)   

    );
end reg_mem;

architecture comportamental of reg_mem is
begin
    process (clk, i_alu, i_WriteDataE, i_WriteRegE, i_MUX_final, i_RegWEN, i_mem_sel, i_load_len, i_store_len) is
    begin
        if (rising_edge(clk) ) then
            o_alu <= i_alu;
            o_WriteDataM <= i_WriteDataE;
            o_WriteRegM     <=  i_WriteRegE;
            o_MUX_final     <= i_MUX_final;        

            o_RegWEN     <= i_RegWEN;       
            o_mem_sel   <= i_mem_sel;   
            o_load_len      <= i_load_len;               
            o_store_len         <= i_store_len;   
        end if;
    end process;
end comportamental;

