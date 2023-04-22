-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade de controle ciclo único (look-up table) do processador
-- puramente combinacional
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unidade de controle
entity unidade_de_controle_ciclo_unico is
    generic (
        INSTR_WIDTH       : natural := 16;
        OPCODE_WIDTH      : natural := 4;
        DP_CTRL_BUS_WIDTH : natural := 6;
        ULA_CTRL_WIDTH    : natural := 4
    );
    port (
        instrucao : in std_logic_vector(INSTR_WIDTH - 1 downto 0);       -- instrução
        controle  : out std_logic_vector(DP_CTRL_BUS_WIDTH - 1 downto 0) -- controle da via
    );
end unidade_de_controle_ciclo_unico;

architecture beh of unidade_de_controle_ciclo_unico is
    -- As linhas abaixo não produzem erro de compilação no Quartus II, mas no Modelsim (GHDL) produzem.	
    --signal inst_aux : std_logic_vector (INSTR_WIDTH-1 downto 0);			-- instrucao
    --signal opcode   : std_logic_vector (OPCODE_WIDTH-1 downto 0);			-- opcode
    --signal ctrl_aux : std_logic_vector (DP_CTRL_BUS_WIDTH-1 downto 0);		-- controle

    signal inst_aux : std_logic_vector (15 downto 0); -- instrucao
    signal opcode   : std_logic_vector (3 downto 0);  -- opcode
    signal ctrl_aux : std_logic_vector (5 downto 0);  -- controle

begin
    inst_aux <= instrucao;
    -- A linha abaixo não produz erro de compilação no Quartus II, mas no Modelsim (GHDL) produz.	
    --	opcode <= inst_aux (INSTR_WIDTH-1 downto INSTR_WIDTH-OPCODE_WIDTH);
    opcode <= inst_aux (15 downto 12);

    process (opcode)
    begin
        case opcode is
                -- NAND	
            when "0000" =>
                ctrl_aux <= "110000";
                -- OR
            when "0001" =>
                ctrl_aux <= "110001";
                -- ADD
            when "0010" =>
                ctrl_aux <= "110010";
                -- SUB	
            when "0100" =>
                ctrl_aux <= "110100";
                -- XOR
            when "1100" =>
                ctrl_aux <= "111100";
            when others =>
                ctrl_aux <= (others => '0');
        end case;
    end process;
    controle <= ctrl_aux;
end beh;