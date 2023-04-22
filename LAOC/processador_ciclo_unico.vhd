-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
library IEEE;
use IEEE.std_logic_1164.all;

entity processador_ciclo_unico is
	generic (
		DATA_WIDTH        : natural; -- tamanho do barramento de dados em bits
		PROC_INSTR_WIDTH  : natural; -- tamanho da instrução do processador em bits
		PROC_ADDR_WIDTH   : natural; -- tamanho do endereço da memória de programa do processador em bits
		DP_CTRL_BUS_WIDTH : natural  -- tamanho do barramento de controle em bits
	);
	port (
		--		Chaves_entrada 			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		--		Chave_enter				: in std_logic;
		Leds_vermelhos_saida : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		Chave_reset          : in std_logic;
		Clock                : in std_logic
	);
end processador_ciclo_unico;

architecture comportamento of processador_ciclo_unico is
	-- declare todos os componentes que serão necessários no seu processador_ciclo_unico a partir deste comentário
	component via_de_dados_ciclo_unico is
		generic (
			-- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
			DP_CTRL_BUS_WIDTH : natural := 6;  -- tamanho do barramento de controle da via de dados (DP) em bits
			DATA_WIDTH        : natural := 16; -- tamanho do dado em bits
			PC_WIDTH          : natural := 8;  -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
			FR_ADDR_WIDTH     : natural := 4;  -- tamanho da linha de endereços do banco de registradores em bits
			INSTR_WIDTH       : natural := 16  -- tamanho da instrução em bits
		);
		port (
			-- declare todas as portas da sua via_dados_ciclo_unico aqui.
			clock     : in std_logic;
			reset     : in std_logic;
			controle  : in std_logic_vector (DP_CTRL_BUS_WIDTH - 1 downto 0);
			instrucao : in std_logic_vector (INSTR_WIDTH - 1 downto 0);
			pc_out    : out std_logic_vector (PC_WIDTH - 1 downto 0);
			saida     : out std_logic_vector (DATA_WIDTH - 1 downto 0);
			zero      : out std_logic;
			negativo  : out std_logic
		);
	end component;

	component unidade_de_controle_ciclo_unico is
		generic (
			INSTR_WIDTH       : natural := 16; -- OP OP OP OP RD RD RD RD RS RS RS RS RT RT RT RT
			OPCODE_WIDTH      : natural := 4;
			DP_CTRL_BUS_WIDTH : natural := 6; -- WE RW UL UL UL UL
			ULA_CTRL_WIDTH    : natural := 4
		);
		port (
			instrucao : in std_logic_vector(INSTR_WIDTH - 1 downto 0);       -- instrução
			controle  : out std_logic_vector(DP_CTRL_BUS_WIDTH - 1 downto 0) -- controle da via
		);
	end component;

	component memi is
		generic (
			INSTR_WIDTH   : natural := 16; -- tamanho da instrução em número de bits
			MI_ADDR_WIDTH : natural := 8   -- tamanho do endereço da memória de instruções em número de bits
		);
		port (
			clk       : in std_logic;
			reset     : in std_logic;
			Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
			Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
		);
	end component;

	-- Declare todos os sinais auxiliares que serão necessários no seu processador_ciclo_unico a partir deste comentário.
	-- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
	-- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
	-- componentes onde serão usados.
	-- Veja os exemplos abaixo:

	-- A partir deste comentário faça associações necessárias das entradas declaradas na entidade do seu processador_ciclo_unico com 
	-- os sinais que você acabou de definir.
	-- Veja os exemplos abaixo:
	signal aux_instrucao : std_logic_vector(PROC_INSTR_WIDTH - 1 downto 0);
	signal aux_controle  : std_logic_vector(DP_CTRL_BUS_WIDTH - 1 downto 0);
	signal aux_endereco  : std_logic_vector(PROC_ADDR_WIDTH - 1 downto 0);

begin
	-- A partir deste comentário instancie todos o componentes que serão usados no seu processador_ciclo_unico.
	-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
	-- que você atribuiu ao componente.
	-- Depois segue o port map do referido componente instanciado.
	-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da 
	-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade processador_ciclo_unico,
	-- ou ainda uma das saídas da entidade processador_ciclo_unico.
	-- Veja os exemplos de instanciação a seguir:

	instancia_memi : memi
	port map(
		clk       => Clock,
		reset     => Chave_reset,
		Endereco  => aux_endereco,
		Instrucao => aux_instrucao
	);

	instancia_unidade_de_controle_ciclo_unico : unidade_de_controle_ciclo_unico
	port map(
		instrucao => aux_instrucao, -- instrução
		controle  => aux_controle   -- controle da via
	);

	instancia_via_de_dados_ciclo_unico : via_de_dados_ciclo_unico
	port map(
		-- declare todas as portas da sua via_dados_ciclo_unico aqui.
		clock     => Clock,
		reset     => Chave_reset,
		controle  => aux_controle,
		instrucao => aux_instrucao,
		pc_out    => aux_endereco,
		saida     => Leds_vermelhos_saida
	);
end comportamento;