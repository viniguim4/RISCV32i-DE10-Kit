-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
library IEEE;
use IEEE.std_logic_1164.all;

entity processador_ciclo_unico is
	port (
		--		Chaves_entrada 			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		--		Chave_enter				: in std_logic;
		--		Leds_vermelhos_saida : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		Chave_reset          : in std_logic;
		Clock                : in std_logic
	);
end processador_ciclo_unico;

architecture comportamento of processador_ciclo_unico is
	-- declare todos os componentes que serão necessários no seu processador_ciclo_unico a partir deste comentário
	component via_de_dados_ciclo_unico is
		port (
		--nosso
		clock     : in std_logic;
		reset     : in std_logic;
		-- entradas
        opcode                                  :   out std_logic_vector(6 downto 0);
        funct3                                  :   out std_logic_vector(14 downto 12);
        funct7                                  :   out std_logic_vector(31 downto 25);
        --saidas----------------------------------------------------------------------------
        --sinais enviados para multiplexadores
        extend_sel, jal                         :   in std_logic;
        MUX_final                               :   in std_logic_vector(1 downto 0);
        --sinal para instrucao b
        branch                                  :   in std_logic;
        --sinal para blocos
        RegWEN, mem_sel                         :   in std_logic;
        extendop                                :   in std_logic_vector(2 downto 0);
        ALUOP                                   :   in std_logic_vector(3 downto 0);
        --sinal enviado para o banco de registradores
        load_len                                :   in std_logic_vector(1 downto 0);
        store_len                               :   in std_logic_vector(1 downto 0)   
		);
	end component;

	component Controlador is
		port (
			------------------- Entradas ---------------------
			opcode      :   in std_logic_vector(6 downto 0);
        	funct3      :   in std_logic_vector(14 downto 12);
        	funct7      :   in std_logic_vector(31 downto 25);
			------------------- Saidas -----------------------
			extendop 	: out std_logic_vector(2 downto 0);	--
			RegWEn		: out std_logic;					--
			load_len	: out std_logic_vector(1 downto 0);	--
			extend_sel	: out std_logic;					--
			ALUOP		: out std_logic_vector(3 downto 0);	--
			branch		: out std_logic;					--
			JAL			: out std_logic;					--
			mem_sel		: out std_logic;					--
			MUX_final	: out std_logic_vector(1 downto 0);	--
			store_len	: out std_logic_vector(1 downto 0)	--
			--------------------------------------------------
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
	--------------------------------------------------------------------------------------------
	-- entradas
	signal aux_opcode                                  : std_logic_vector(6 downto 0);
	signal aux_funct3                                  : std_logic_vector(14 downto 12);
	signal aux_funct7                                  : std_logic_vector(31 downto 25);
	--saidas
	--sinais enviados para multiplexadores
	signal aux_extend_sel, aux_jal                     : std_logic;
	signal aux_MUX_final                               : std_logic_vector(1 downto 0);
	--sinal para instrucao b
	signal aux_branch                                  : std_logic;
	--sinal para blocos
	signal aux_RegWEN, aux_mem_sel                     : std_logic;
	signal aux_extendop                                : std_logic_vector(2 downto 0);
	signal aux_ALUOP                                   : std_logic_vector(3 downto 0);
	--sinal enviado para o banco de registradores
	signal aux_load_len                                : std_logic_vector(1 downto 0);
	signal aux_store_len                               : std_logic_vector(1 downto 0); 
	--------------------------------------------------------------------------------------------
begin
	-- A partir deste comentário instancie todos o componentes que serão usados no seu processador_ciclo_unico.
	-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
	-- que você atribuiu ao componente.
	-- Depois segue o port map do referido componente instanciado.
	-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da 
	-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade processador_ciclo_unico,
	-- ou ainda uma das saídas da entidade processador_ciclo_unico.
	-- Veja os exemplos de instanciação a seguir:

	instancia_unidade_de_controle_ciclo_unico : Controlador
	port map(
		opcode => aux_opcode,
		funct3 => aux_funct3,
		funct7 => aux_funct7,
		------------------------------------
		extendop => aux_extendop,
		RegWEn => aux_RegWEN,
		load_len => aux_load_len,
		extend_sel => aux_extend_sel,
		ALUOP => aux_ALUOP,
		branch => aux_branch,
		JAL => aux_jal,
		mem_sel => aux_mem_sel,
		MUX_final => aux_MUX_final,
		store_len => aux_store_len
	);

	instancia_via_de_dados_ciclo_unico : via_de_dados_ciclo_unico
	port map(
		-- declare todas as portas da sua via_dados_ciclo_unico aqui.
		clock     	=>  Clock,
		reset     	=>  Chave_reset,
		-- entradas
        opcode 		=>  aux_opcode,                             
        funct3 		=>  aux_funct3,                           
        funct7   	=>  aux_funct7,                         
        --saidas
        --sinais enviados para multiplexadores
        extend_sel 	=>  aux_extend_sel,
		jal   		=>  aux_jal,      
        MUX_final 	=>  aux_MUX_final,                   
        --sinal para instrucao b
        branch    	=>  aux_branch,                      
        --sinal para blocos
        RegWEN 		=>  aux_RegWEN,
		mem_sel  	=>  aux_mem_sel,       
        extendop 	=>  aux_extendop,                
        ALUOP 		=>  aux_ALUOP,                 
        --sinal enviado para o banco de registradores
        load_len 	=> aux_load_len,                              
        store_len   => aux_store_len                 
	);
end comportamento;