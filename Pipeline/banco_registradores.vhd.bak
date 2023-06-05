-- vsg_off
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
        largura_dado : natural  :=  32; --  tamnho da instrução de RISCV32i 32 
        largura_ende : natural  :=  5   --  tamnho do endereço de RISCV32i 5
    );

    port (
        ent_Rs1_ende : in std_logic_vector((largura_ende - 1) downto 0);    -- (19 - 15)
        ent_Rs2_ende : in std_logic_vector((largura_ende - 1) downto 0);    -- (24 - 20)
        ent_Rd_ende : in std_logic_vector((largura_ende - 1) downto 0);     -- (11 - 7)
        write_data_reg : in std_logic_vector((largura_dado - 1) downto 0);     
        sai_Reg1_dado : out std_logic_vector((largura_dado - 1) downto 0);
        sai_Reg2_dado : out std_logic_vector((largura_dado - 1) downto 0);
        clk, RegWEN     : in std_logic;
        --sinal do tamanho do dado
        --para diferenciar lw,lh e lb
        data_len_breg    : in std_logic_vector(1 downto 0)
    );
end banco_registradores;

architecture comportamental of banco_registradores is
    type registerfile is array(0 to ((2 ** largura_ende) - 1)) of std_logic_vector((largura_dado - 1) downto 0);
    signal banco : registerfile;
begin
    leitura : process (clk) is
    begin
        -- lê o registrador de endereço Rs1 da instrução apontada por PC no ciclo anterior,
        -- lê o registrador de endereço Rs2 da instrução apontada por PC no ciclo anterior.
        sai_Reg1_dado <= banco(to_integer(unsigned(ent_Rs1_ende)));
        sai_Reg2_dado <= banco(to_integer(unsigned(ent_Rs2_ende)));
    end process;

    escrita : process (clk) is
    begin
        if rising_edge(clk) then
            if RegWEN  = '1' then
                case data_len_breg is
                    when "00" =>
                    banco(to_integer(unsigned(ent_Rd_ende))) <= write_data_reg(7 downto 0);

                    when "01" =>
                    banco(to_integer(unsigned(ent_Rd_ende))) <= write_data_reg(15 downto 0);

                    when others =>
                    banco(to_integer(unsigned(ent_Rd_ende))) <= write_data_reg((largura_dado -1) downto 0);
                end case;
            end if;
        end if;
    end process;
end comportamental;