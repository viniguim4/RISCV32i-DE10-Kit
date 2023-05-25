-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memd is
    generic (
        number_of_words : natural := 512; -- número de words que a sua memória é capaz de armazenar
        MD_DATA_WIDTH   : natural := 32; -- tamanho da palavra em bits
        MD_ADDR_WIDTH   : natural := 11  -- tamanho do endereco da memoria de dados em bits
    );
    port (
        clk                 : in std_logic;
        mem_sel             : in std_logic; --sinais do controlador
        write_data_mem      : in std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
        adress_mem          : in std_logic_vector(31 downto 0);
        read_data_mem       : out std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
        --sinal do tamanho do dado
        --para diferenciar sw,sh e sb
        data_len_memd    : in std_logic_vector(1 downto 0) 
    );
end memd;

architecture comportamental of memd is
    --alocar espaço para a memoria e iniciar com 0
    type data_mem is array (0 to number_of_words - 1) of std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
    signal ram      : data_mem := (others => (others => '0'));
    signal ram_addr : std_logic_vector(MD_ADDR_WIDTH - 1 downto 0);

begin
    ram_addr <= adress_mem(MD_ADDR_WIDTH - 1 downto 0);
    process (clk, ram, ram_addr, write_data_mem)
    variable sb_conc : std_logic_vector(31 downto 0);
    variable sh_conc : std_logic_vector(31 downto 0);
    begin
        sb_conc :=  ram(to_integer(unsigned(ram_addr)))(31 downto 8) & write_data_mem(7 downto 0);
        sh_conc := ram(to_integer(unsigned(ram_addr)))(31 downto 16) & write_data_mem(15 downto 0);

        if (rising_edge(clk)) then
            if (mem_sel = '1') then
                case data_len_memd is
                    when "00" =>    --sb
                    ram(to_integer(unsigned(ram_addr))) <= sb_conc;
                    when "01" =>    --sh
                    ram(to_integer(unsigned(ram_addr))) <= sh_conc;

                    when others =>  --sw
                    ram(to_integer(unsigned(ram_addr))) <= write_data_mem(31 downto 0);
                end case;
            end if;
        end if;
    end process;
    with mem_sel select
        read_data_mem <= ram(to_integer(unsigned(ram_addr))) when '0', 
        x"00000000" when others;            
    --read_data_mem <= ram(to_integer(unsigned(ram_addr))) when (mem_sel = '0');
end comportamental;