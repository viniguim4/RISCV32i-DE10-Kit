-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico

library IEEE;
use IEEE.std_logic_1164.all;

entity via_de_dados_ciclo_unico is
	generic (
		-- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
		dp_ctrl_bus_width : natural; -- tamanho do barramento de controle da via de dados (DP) em bits
		data_width        : natural; -- tamanho do dado em bits
		pc_width          : natural; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
		fr_addr_width     : natural; -- tamanho da linha de endereços do banco de registradores em bits
		ula_ctrl_width    : natural; -- tamanho da linha de controle da ULA
		instr_width       : natural  -- tamanho da instrução em bits
	);
	port (
		-- declare todas as portas da sua via_dados_ciclo_unico aqui.
		clock     : in std_logic;
		reset     : in std_logic;
		controle  : in std_logic_vector(dp_ctrl_bus_width - 1 downto 0);
		instrucao : in std_logic_vector(instr_width - 1 downto 0);
		pc_out    : out std_logic_vector(pc_width - 1 downto 0);
		saida     : out std_logic_vector(data_width - 1 downto 0)
	);
end entity via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

	-- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
	component pc is
		generic (
			pc_width : natural := 32
		);
		port (
			entrada : in std_logic_vector(pc_width - 1 downto 0);
			saida   : out std_logic_vector(pc_width - 1 downto 0);
			clk     : in std_logic;
			we      : in std_logic;
			reset   : in std_logic
		);
	end component;

	component somador is
		generic (
			largura_dado : natural := 32
		);
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			saida     : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component banco_registradores is
		generic (
			largura_dado : natural := 32;
			largura_ende : natural := 32
		);
		port (
			ent_rs_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rt_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rd_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rd_dado : in std_logic_vector((largura_dado - 1) downto 0);
			sai_rs_dado : out std_logic_vector((largura_dado - 1) downto 0);
			sai_rt_dado : out std_logic_vector((largura_dado - 1) downto 0);
			clk         : in std_logic;
			we          : in std_logic
		);
	end component;

	component ula is
		generic (
			largura_dado : natural := 32
		);
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			seletor   : in std_logic_vector(2 downto 0);
			saida     : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	-- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
	-- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
	-- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
	-- componentes onde serão usados.
	-- Veja os exemplos abaixo:
	signal aux_read_rs    : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_read_rt    : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_write_rd   : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_data_in    : std_logic_vector(data_width - 1 downto 0);
	signal aux_data_outrs : std_logic_vector(data_width - 1 downto 0);
	signal aux_data_outrt : std_logic_vector(data_width - 1 downto 0);
	signal aux_reg_write  : std_logic;

	signal aux_ula_ctrl : std_logic_vector(ula_ctrl_width - 1 downto 0);

	signal aux_pc_out  : std_logic_vector(pc_width - 1 downto 0);
	signal aux_novo_pc : std_logic_vector(pc_width - 1 downto 0);
	signal aux_we      : std_logic;

begin

	-- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
	-- os sinais que você acabou de definir.
	-- Veja os exemplos abaixo:
	aux_read_rs   <= instrucao(7 downto 4);  -- OP OP OP OP RD RD RD RD RS RS RS RS RT RT RT RT
	aux_read_rt   <= instrucao(3 downto 0);  -- OP OP OP OP RD RD RD RD RS RS RS RS RT RT RT RT
	aux_write_rd  <= instrucao(11 downto 8); -- OP OP OP OP RD RD RD RD RS RS RS RS RT RT RT RT
	aux_reg_write <= controle(4);            -- WE RW UL UL UL UL
	aux_ula_ctrl  <= controle(3 downto 0);   -- WE RW UL UL UL UL
	aux_we        <= controle(5);            -- WE RW UL UL UL UL
	saida         <= aux_data_outrt;
	pc_out        <= aux_pc_out;

	-- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
	-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
	-- que você atribuiu ao componente.
	-- Depois segue o port map do referido componente instanciado.
	-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
	-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
	-- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
	-- Veja os exemplos de instanciação a seguir:

	instancia_ula1 : component ula
  		port map(
			entrada_a => aux_data_outrs,
			entrada_b => aux_data_outrt,
			seletor => aux_ula_ctrl,
			saida => aux_data_in
 		);

	instancia_banco_registradores : component banco_registradores
		port map(
			ent_rs_ende => aux_read_rs,
			ent_rt_ende => aux_read_rt,
			ent_rd_ende => aux_write_rd,
			ent_rd_dado => aux_data_in,
			sai_rs_dado => aux_data_outrs,
			sai_rt_dado => aux_data_outrt,
			clk => clock,
			we => aux_reg_write
		);

    instancia_pc : component pc
    	port map(
			entrada => aux_novo_pc,
			saida => aux_pc_out,
			clk => clock,
			we => aux_we,
			reset => reset
      	);

    instancia_somador : component somador
        port map(
			entrada_a => aux_pc_out,
			entrada_b => "0001",
			saida => aux_novo_pc
        );
end architecture comportamento;