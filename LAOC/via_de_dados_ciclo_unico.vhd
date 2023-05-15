-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico

library IEEE;
use IEEE.std_logic_1164.all;

entity via_de_dados_ciclo_unico is
	port (
		--nosso
		clock     : in std_logic;
		reset     : in std_logic;

		-- entradas
        opcode                                  :   out std_logic_vector(6 downto 0);
        funct3                                  :   out std_logic_vector(14 downto 12);
        funct7                                  :   out std_logic_vector(31 downto 25);
        --saidas
        --sinais enviados para multiplexadores
        extend_sel, jal                         :   in std_logic;
        MUX_final                               :   in std_logic_vector(1 downto 0);
        --sinal para instrucao b
        branch                                  :   in std_logic;
        --sinal para blocos
        RegWEN, men_sel                         :   in std_logic;
        extendop                                :   in  std_logic_vector(1 downto 0);
        ALUOP                                   :   in std_logic_vector(3 downto 0);
        --sinal enviado para o banco de registradores
        load_len                                :   in std_logic_vector(1 downto 0);
        store_len                                :   in std_logic_vector(1 downto 0)   
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
			reset   : in std_logic
		);
	end component;

	component Adder_4 is
		port (
			adder4_in	        :   in std_logic_vector(31 downto 0);	

			adder4_out	        :   out std_logic_vector(31 downto 0)
		);
	end component;

	component Adder_normal is
		port (
			adder_in1	        :   in std_logic_vector(31 downto 0);	
			adder_in2	        :   in std_logic_vector(31 downto 0);	
	
			adder_out	        :   out std_logic_vector(31 downto 0)
		);
	end component;

	component shift_left2 is
		port (
			signal_extend_in   :   in  std_logic_vector (31 downto 0);
        
			exit_sll2           :   out  std_logic_vector (31 downto 0)
		);
	end component;

	component extensor is
		generic (
			largura_dado  : natural := 32;  
			largura_saida : natural := 32
		);
		port (
			entrada_Rs : in std_logic_vector((largura_dado - 1) downto 0); 		
			extend_sel	: in std_logic_vector(1 downto 0);				 
			saida      : out std_logic_vector((largura_saida - 1) downto 0)
		);
	end component;

	component mux21 is
		generic (
			largura_dado : natural := 32
		);
		port (
			dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent               : in std_logic; --vai vim do controlador
	
			dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component mux41 is
		generic (
			largura_dado : natural := 32
		);
		port (
			dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent                                       : in std_logic_vector(1 downto 0);
			dado_sai                                       : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component banco_registradores is
		generic (
			largura_dado : natural  :=  32; --  tamnho da instrução de RISCV32i 32 
			largura_ende : natural  :=  5   --  tamnho do endereço de RISCV32i 5
		);
	
		port (
			ent_Rs1_ende : in std_logic_vector((largura_ende - 1) downto 0);    -- (19 - 15)
			ent_Rs2_ende : in std_logic_vector((largura_ende - 1) downto 0);    -- (24 - 20)
			ent_Rd_ende : in std_logic_vector((largura_ende - 1) downto 0);     -- (11 - 7)
			ent_Rd_dado : in std_logic_vector((largura_dado - 1) downto 0);     
			sai_Reg1_dado : out std_logic_vector((largura_dado - 1) downto 0);
			sai_Reg2_dado : out std_logic_vector((largura_dado - 1) downto 0);
			clk, WE     : in std_logic;
			--sinal do tamanho do dado
			--para diferenciar lw,lh e lb
			data_len_breg    : in std_logic_vector(1 downto 0)
		);
	end component;

	component ula is
		generic (
			largura_dado : natural := 32
		);
	
		port (
			--entrada 
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			seletor   : in std_logic_vector(3 downto 0);  -- é o aluoop
			--saida
			saida     : out std_logic_vector((largura_dado - 1) downto 0);
			b         : out std_logic
		);
	end component;

	component and_port is
		port (
			entrada1   :   in std_logic;
			entrada2   :   in std_logic;
	
			saida   :   out std_logic
		);
	end component;

	component memd is
		generic (
			number_of_words : natural := 512; -- número de words que a sua memória é capaz de armazenar
			MD_DATA_WIDTH   : natural := 32; -- tamanho da palavra em bits
			MD_ADDR_WIDTH   : natural := 11  -- tamanho do endereco da memoria de dados em bits
		);
		port (
			clk                 : in std_logic;
			mem_write, mem_read : in std_logic; --sinais do controlador
			write_data_mem      : in std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
			adress_mem          : in std_logic_vector(MD_ADDR_WIDTH - 1 downto 0);
			read_data_mem       : out std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
			--sinal do tamanho do dado
			--para diferenciar sw,sh e sb
			data_len_memd    : in std_logic_vector(1 downto 0) 
		);
	end component;
	
	component memi is
		generic (
			INSTR_WIDTH   : natural := 32; -- tamanho da instrucaoo em numero de bits
			MI_ADDR_WIDTH : natural := 11 -- tamanho do endereco da memoria de instrucoes em numero de bits
		);
		port (
			clk       : in std_logic;
			reset     : in std_logic;
			Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
			Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
		);
	end component;


    -- Aqui os sinais repsentam os fios que ligam os componentes. tudo em letra maiuscula 
    -- representa a saida dos controladores.
    -- sinais internos
    signal aux_saida_pc : std_logic_Vector(31 downto 0);
	signal aux_saida_memi : std_logic_Vector(31 downto 0);
	signal aux_saida_data_reg1 : std_logic_Vector(31 downto 0);
	signal aux_saida_data_reg2 : std_logic_Vector(31 downto 0);
	signal aux_saida_extensor : std_logic_Vector(31 downto 0);
	signal aux_saida_mux21_extend : std_logic_Vector(31 downto 0);
	signal aux_saida_alu : std_logic_Vector(31 downto 0);
	signal aux_saida_memd : std_logic_Vector(31 downto 0);
	signal aux_saida_mux41 : std_logic_Vector(31 downto 0);
	signal aux_saida_adder4 : std_logic_Vector(31 downto 0);
	signal aux_saida_sll2 : std_logic_Vector(31 downto 0);
	signal aux_saida_addnormal_sleft : std_logic_Vector(31 downto 0);
	signal aux_saida_addnormal_4 : std_logic_Vector(31 downto 0);
	signal aux_saida_mux_branch : std_logic_Vector(31 downto 0);
	signal aux_saida_mux_jump : std_logic_Vector(31 downto 0);
	signal aux_saida_and : std_logic_Vector(31 downto 0);

	--sinais de controle

begin

	instancia_pc : component pc
	port map(
		entrada => aux_saida_mux_jump,
		saida   => aux_saida_pc,
		clk     => clock,
		reset   => reset
	);

	instancia_adder4 : component Adder_4
	port map(
		adder4_in =>	aux_saida_pc,

		adder4_out =>    aux_saida_adder4
	);
	
	instancia_adder_normal_sll : component Adder_normal
	port map(
		adder_in1	 =>	aux_saida_adder4,
		adder_in2 => aux_saida_sll2,
		adder_out =>    aux_saida_addnormal_sleft
	);

	instancia_adder_normal_pc : component Adder_normal
	port map(
		adder_in1	 =>	aux_saida_pc,
		adder_in2 => aux_saida_sll2,
		adder_out =>    aux_saida_addnormal_4
	);






end architecture comportamento;