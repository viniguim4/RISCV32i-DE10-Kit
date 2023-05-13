library ieee;
use ieee.std_logic_1164.all;

-- esse arquivo irá certificar que todos os componentes do datapath estejam funcionando
-- perfeitamente, ademais irá certificar que os sinais cheguem aos componentes corretos.


entity controlador is
    port(
        -- entradas
        opcode                                  :   in std_logic_vector(6 downto 0);
        funct3                                  :   in std_logic_vector(14 downto 12);
        funct7                                  :   in std_logic_vector(31 downto 25);
        --saidas
        --sinais enviados para multiplexadores
        extend_sel, jal                         :   out std_logic;
        MUX_final                               :   out std_logic_vector(1 downto 0);
        --sinal para instrucao b
        branch                                  :   out std_logic;
        --sinal para blocos
        RegWEN, men_sel                         :   out std_logic;
        extendop                                :   out  std_logic_vector(1 downto 0);
        ALUOP                                   :   out std_logic_vector(3 downto 0);
        --sinal enviado para o banco de registradores
        load_len                                :   out std_logic_vector(1 downto 0)  
    );
end entity controlador;

architecture behavior of controlador is
    --concatenatar functs
    signal funct  : std_logic_vector(9 downto 0) := funct7 & funct3;

    begin
        process(opcode)
            begin
                case opcode is

                    when "0000011" =>   -- lw,lh,lb 
                        extendop <= "00";
                        extend_sel <= '1';
                        RegWEN <= '1';
                        branch <= '0';
                        men_sel <= '0';
                        MUX_final <= "00";
                        jal <= '0';
                        ALUOP <="0000"; --somar
                        case funct3 is
                            when "000" => load_len <= "00"; --lb
                            when "001" => load_len <= "01"; --lh
                            when "010" => load_len <= "10"; --lw
                        end case;
                    
                    when "0010011" =>   -- instrucao tipo i
                        extendop <= "00";
                        extend_sel <= '1';
                        RegWEN <= '1';
                        branch <= '0';
                        men_sel <= '0';
                        MUX_final <= "01";
                        jal <= '0';
                        load_len <= "10";
                        case funct3 is
                            when "000" => ALUOP <= "0000";  -- addi usar adição
                            when "010" => ALUOP <= "0011";  -- slti usar slt
                            when "100" => ALUOP <= "0100";  -- xori usar xor
                            when "110" => ALUOP <= "1001";  -- ori usar or
                            when "111" => ALUOP <= "0110";  -- andi usar and
                            when "001" => ALUOP <= "0010";  -- slli usar sll
                            when "001" => ALUOP <= "1010";  -- nop(soma com 2 0)
                            when others => ALUOP <= "1111"; -- nao faz nada
                        end case;


                    when "0110011" =>   -- instrucao tipo R
                        extendop <= "00"; -- tanto faz
                        extend_sel <= '0';
                        RegWEN <= '1';
                        men_sel <= '0';
                        MUX_final <= "01";
                        branch <= '0';
                        jal <= '0';
                        load_len <= "10";
                        --definir operação da alu
                        case funct is
                            when "0000000000" => ALUOP <= "0000";  -- adição
                            when "0100000000" => ALUOP <= "0001"; -- subtração                                
                            when "0000000001" => ALUOP <= "0010"; -- sll
                            when "0000000010" => ALUOP <= "0011"; -- slt
                            when "0000000100" => ALUOP <= "0100"; -- xor
                            when "0000000101" => ALUOP <= "0101"; -- srl
                            when "0000000111" => ALUOP <= "0110"; -- and
                            when "0000001000" => ALUOP <= "0111"; -- mul
                            when "0000001100" => ALUOP <= "1000"; -- div
                            when "0000000110" => ALUOP <= "1001"; -- or
                            when others => ALUOP <= "1111"; -- nao faz nada
                        end case;

                    when "0100011" =>   -- instrucao tipo S
                        extendop <= "01"; 
                        extend_sel <= '1';
                        RegWEN <= '0';
                        men_sel <= '1';
                        MUX_final <= "00";
                        branch <= '0';
                        jal <= '0';
                        load_len <= "10";
                        ALUOP <= "0000";  -- realizar uma soma

                    when "1100011" =>   -- instrucao tipo b
                        extendop <= "01"; 
                        extend_sel <= '0';
                        RegWEN <= '0';
                        men_sel <= '0';
                        MUX_final <= "01";
                        branch <= '1';
                        jal <= '0';
                        load_len <= "10";
                        -- para todos os casos fazer uma sub e então decidir
                        case funct3 is
                            when "000" => ALUOP <= "1011";  -- beq
                            when "100" => ALUOP <= "1100";  -- blt
                            when "101" => ALUOP <= "1101";  -- bge
                            when others => ALUOP <= "1111"; -- nao faz nada
                        end case;

                    when "0110111" =>   -- instrucao tipo u
                        extendop <= "10"; 
                        extend_sel <= '1';
                        RegWEN <= '1';
                        men_sel <= '0';
                        MUX_final <= "01";
                        branch <= '0';
                        jal <= '0';
                        load_len <= "10";
                        --vai deslocar 12 bits
                        ALUOP <= "1110";
                    
                    when "0110111" =>   -- instrucao tipo j
                        extendop <= "11"; 
                        extend_sel <= '0';
                        RegWEN <= '1';
                        men_sel <= '0';
                        MUX_final <= "10";
                        branch <= '0';
                        jal <= '1';
                        load_len <= "10";
                        ALUOP <="1111"; -- faz nada na alu

                    when others => 
                        extendop <= "11"; 
                        extend_sel <= '0';
                        RegWEN <= '0';
                        men_sel <= '0';
                        MUX_final <= "10";
                        branch <= '0';
                        jal <= '0';
                        load_len <= "10";
                        ALUOP <= "1111"; -- faz nada no alu

                end case;
        end process;
end architecture behavior;