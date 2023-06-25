-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico

library IEEE;
use IEEE.std_logic_1164.all;

entity pipeline is
	port (
		clock     : in std_logic;
		reset     : in std_logic
	);
end entity pipeline;

architecture comportamento of pipeline is

	-- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
	component pc is
		generic (
			pc_width : natural := 32
		);
		port (
			entrada : in std_logic_vector(pc_width - 1 downto 0);
			saida   : out std_logic_vector(pc_width - 1 downto 0);
			clk     : in std_logic;
			reset, stall_pc   : in std_logic
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
			extendop	: in std_logic_vector(2 downto 0);				 
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
			write_data_reg : in std_logic_vector((largura_dado - 1) downto 0);     
			sai_Reg1_dado : out std_logic_vector((largura_dado - 1) downto 0);
			sai_Reg2_dado : out std_logic_vector((largura_dado - 1) downto 0);
			clk, RegWEN     : in std_logic;
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
			saida     : out std_logic_vector((largura_dado - 1) downto 0)
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
			MD_ADDR_WIDTH   : natural := 9  -- tamanho do endereco da memoria de dados em bits
		);
		port (
			clk                 : in std_logic;
			mem_sel : in std_logic; --sinais do controlador
			write_data_mem      : in std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
			adress_mem          : in std_logic_vector(31 downto 0);
			read_data_mem       : out std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
			--sinal do tamanho do dado
			--para diferenciar sw,sh e sb
			data_len_memd    : in std_logic_vector(1 downto 0) 
		);
	end component;
	
	component memi is
		generic (
			INSTR_WIDTH   : natural := 32; -- tamanho da instrucaoo em numero de bits
			MI_ADDR_WIDTH : natural := 32 -- tamanho do endereco da memoria de instrucoes em numero de bits
		);
		port (
			clk       : in std_logic;
			reset     : in std_logic;
			Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
			Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
		);
	end component;

	component reg_decod is
		port (
			entrada_memi    : in std_logic_vector(31 downto 0);
			entrada_pc4    : in std_logic_vector(31 downto 0);
			clk, flush_dec      : in std_logic;
			stall_dec        : in std_logic;
			saida_memi    : out std_logic_vector(31 downto 0);
			saida_pc4     : out std_logic_vector(31 downto 0)
		);
	end component;

	component reg_exe is 
		port(
			Rs1D : in std_logic_vector(4 downto 0);    -- (19 - 15)
			Rs2D  : in std_logic_vector(4 downto 0);    -- (24 - 20)
			RdD : in std_logic_vector(4 downto 0);     -- (11 - 7)
			clk         : in std_logic;
			flush_exe         : in std_logic;
			entrada_sinal_extend : in std_logic_vector(31 downto 0);
			entra_Reg1_dado : in std_logic_vector(31 downto 0);
			entra_Reg2_dado : in std_logic_vector(31 downto 0);

			Rs1E : out std_logic_vector(4 downto 0);    -- (19 - 15)
			Rs2E : out std_logic_vector(4 downto 0);    -- (24 - 20)
			RdE : out std_logic_vector(4 downto 0);     -- (11 - 7)
			sai_Reg1_dado : out std_logic_vector(31 downto 0);
			sai_Reg2_dado : out std_logic_vector(31 downto 0);
			sai_sinal_extend : out std_logic_vector(31 downto 0);

			--sinais de controle
			--sinais enviados para multiplexadores
			i_extend_sel                        :   in std_logic;
			i_MUX_final                               :   in std_logic_vector(1 downto 0);
			--sinal para blocos
			i_RegWEN, i_mem_sel                         :   in std_logic;
			i_extendop                               :   in  std_logic_vector(2 downto 0);
			i_ALUOP                                   :   in std_logic_vector(3 downto 0);
			--sinal enviado para o banco de registradores
			i_load_len                                :   in std_logic_vector(1 downto 0);
			i_store_len                               :   in std_logic_vector(1 downto 0);   

			o_extend_sel                               :   out std_logic;
			o_MUX_final                               :   out std_logic_vector(1 downto 0);

			--sinal para blocos
			o_RegWEN, o_mem_sel                         :   out std_logic;
			o_extendop                               :   out  std_logic_vector(2 downto 0);
			o_ALUOP                                   :   out std_logic_vector(3 downto 0);
			--sinal enviado para o banco de registradores
			o_load_len                                :   out std_logic_vector(1 downto 0);
			o_store_len                               :   out std_logic_vector(1 downto 0)   
		);
	end component;

	component reg_memd is
		port (
			i_alu: in std_logic_vector(31 downto 0);   
			i_WriteDataE : in std_logic_vector(31 downto 0);  
			i_WriteRegE : in std_logic_vector(31 downto 0);  
			clk         : in std_logic;
		
			o_alu: out std_logic_vector(31 downto 0);  
			o_WriteDataM  : out std_logic_vector(31 downto 0);  
			o_WriteRegM  : out std_logic_vector(31 downto 0);  

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
	end component;

	component reg_writeback is
		port (
			i_memd: in std_logic_vector(31 downto 0);   
			i_ALUoutW: in std_logic_vector(31 downto 0);  
			i_WriteRegW : in std_logic_vector(31 downto 0);  
			clk         : in std_logic;
		
			o_memd: out std_logic_vector(31 downto 0);  
			o_ALUoutW  : out std_logic_vector(31 downto 0);  
			o_WriteRegW  : out std_logic_vector(31 downto 0);  

			--sinais de controle

			i_MUX_final                               :   in std_logic_vector(1 downto 0);
			i_RegWEN                       :   in std_logic;
			i_load_len                                :   in std_logic_vector(1 downto 0);

			o_MUX_final                               :   out std_logic_vector(1 downto 0);
			o_RegWEN                        :   out std_logic;
			o_load_len                                :   out std_logic_vector(1 downto 0)
		);
	end component;

	component HazardUnit is
		port (
			-- entradas da vinda da controladora
			branch : in std_logic;
			jal : in std_logic;
			instrucao : in std_logic_vector(31 downto 0);  -- vai usar opcode e funct3 
			--entradas vinda do reg dec (nada)
		
			-- entradas vinda do reg exec
			RegWEN__exe, MUX_final_exe : in std_logic; --(men_sel = Menwrite) (RegWEN = RegWrite)
			Rs1D, Rs2D : in std_logic_vector(4 downto 0);
			Rs1E, Rs2E : in std_logic_vector(4 downto 0);
			--entrada vinda do reg mem
			RegWEN__mem, MUX_final_mem: in std_logic;
			WriteRegE, WriteRegM : in std_logic_vector(4 downto 0);
		
			-- entradas vinda dp reg wb
			RegWEN__wb : in std_logic;
			WriteRegW : in std_logic_vector(4 downto 0);
		
			--saidas
			stall_pc : out std_logic ;
		
			flush_dec, stall_dec : out std_logic;
			forwardAD, forwardBD : out  std_logic_vector(1 downto 0);
		
			flush_exe : out std_logic;
			forwardAE, forwardBE : out  std_logic_vector(1 downto 0)
		);
	end component;

	component branch is
		port (
			--entrada 
			entrada_a : in std_logic_vector(31 downto 0);
			entrada_b : in std_logic_vector(31 downto 0);
			seletor   : in std_logic_vector(3 downto 0);  -- é o aluoop
			--saida
			pcSrcD     : out std_logic
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
	
    -- Aqui os sinais repsentam os fios que ligam os componentes. tudo em letra maiuscula 
    -- representa a saida dos controladores.
    -- sinais internos
   	signal aux_saida_pc : std_logic_Vector(31 downto 0);
	signal aux_saida_memi : std_logic_Vector(31 downto 0);
	signal aux_saida_regD : std_logic_Vector(31 downto 0);
	signal aux_saida_regD_inst : std_logic_Vector(31 downto 0);
	signal aux_saida_regD_pc4 : std_logic_Vector(31 downto 0);
	signal aux_saida_data_reg1 : std_logic_Vector(31 downto 0);
	signal aux_saida_data_reg2 : std_logic_Vector(31 downto 0);
	signal aux_saida_extensor : std_logic_Vector(31 downto 0);
	signal aux_saida_mux1 : std_logic_Vector(31 downto 0);
	signal aux_saida_mux2 : std_logic_Vector(31 downto 0);
	signal aux_saida_branch : std_logic;
	signal aux_saida_sll2 : std_logic_Vector(31 downto 0);
	signal aux_saida_regE_Rs1E : std_logic_Vector(31 downto 0);
	signal aux_saida_regE_Rs2E : std_logic_Vector(31 downto 0);
	signal aux_saida_regE_RdE : std_logic_Vector(31 downto 0);
	signal aux_saida_regE_Reg1_dado : std_logic_Vector(31 downto 0);
	signal aux_saida_regE_Reg2_dado : std_logic_Vector(31 downto 0);
	signal aux_saida_regE_sinal_extend : std_logic_Vector(31 downto 0);
	signal aux_saida_regE_extend_sel  : std_logic;
	signal aux_saida_regE_MUX_final   : std_logic_Vector(1 downto 0);
	signal aux_saida_regE_RegWEN   : std_logic;
	signal aux_saida_regE_mem_sel   : std_logic;
	signal aux_saida_regE_extendop   : std_logic_vector(2 downto 0);
	signal aux_saida_regE_ALUOP  : std_logic_vector(3 downto 0);
	signal aux_saida_regE_load_len  : std_logic_vector(1 downto 0);
	signal aux_saida_regE_store_len  : std_logic_vector(1 downto 0);
	signal aux_saida_mux3 : std_logic_Vector(31 downto 0);
	signal aux_saida_mux4 : std_logic_Vector(31 downto 0);
	signal aux_saida_mux5 : std_logic_Vector(31 downto 0);
	signal aux_saida_mux6 : std_logic_Vector(31 downto 0);
	signal aux_saida_alu : std_logic_Vector(31 downto 0);
	signal aux_saida_regM_alu: std_logic_Vector(31 downto 0);
	signal aux_saida_regM_WriteDataM : std_logic_Vector(31 downto 0);
	signal aux_saida_regM_WriteRegM : std_logic_Vector(31 downto 0);
	signal aux_saida_regM_MUX_final   : std_logic_Vector(1 downto 0);
	signal aux_saida_regM_RegWEN   : std_logic;
	signal aux_saida_regM_mem_sel   : std_logic;
	signal aux_saida_regM_load_len  : std_logic_vector(1 downto 0);
	signal aux_saida_regM_store_len  : std_logic_vector(1 downto 0);
	signal aux_saida_memd : std_logic_Vector(31 downto 0);
	signal aux_saida_regWB_memd : std_logic_Vector(31 downto 0);
	signal aux_saida_regWB_ALUoutW  : std_logic_Vector(31 downto 0);
	signal aux_saida_regWB_WriteRegW : std_logic_Vector(31 downto 0);
	signal aux_saida_regWB_MUX_final   : std_logic_Vector(1 downto 0);
	signal aux_saida_regWB_RegWEN   : std_logic;
	signal aux_saida_regWB_load_len  : std_logic_vector(1 downto 0);
	signal aux_saida_mux7 : std_logic_Vector(31 downto 0);
	signal aux_saida_adder4 : std_logic_Vector(31 downto 0);
	signal aux_saida_addnormal_cima : std_logic_Vector(31 downto 0);
	signal aux_saida_addnormal_baixo : std_logic_Vector(31 downto 0);
	signal aux_saida_mux_branch : std_logic_Vector(31 downto 0);
	signal aux_saida_mux_jump : std_logic_Vector(31 downto 0);
	
	--sinais de controle
	signal aux_saida_control_extend_sel : std_logic;
	signal aux_saida_control_jal : std_logic;
	signal aux_saida_control_MUX_final : std_logic_vector(1 downto 0);
	signal aux_saida_control_branch  : std_logic;
	signal aux_saida_control_RegWEN  : std_logic;
	signal aux_saida_control_mem_sel  : std_logic;
	signal aux_saida_control_extendop  : std_logic_vector(2 downto 0);
	signal aux_saida_control_ALUOP   : std_logic_vector(3 downto 0);
	signal aux_saida_control_load_len  : std_logic_vector(1 downto 0);
	signal aux_saida_control_store_len   :std_logic_vector(1 downto 0);

	--sinais hazard
	signal aux_saida_hazard_stall_pc : std_logic;
	signal aux_saida_hazard_flush_dec : std_logic;
	signal aux_saida_hazard_stall_dec : std_logic;
	signal aux_saida_hazard_flush_exe : std_logic;
	signal aux_saida_hazard_forwardAD : std_logic_vector(1 downto 0);
	signal aux_saida_hazard_forwardBD : std_logic_vector(1 downto 0);
	signal aux_saida_hazard_forwardBE : std_logic_vector(1 downto 0);
	signal aux_saida_hazard_forwardAE : std_logic_vector(1 downto 0);

begin
	--funct3 <= aux_saida_memi(14 downto 12);
	--funct7 <= aux_saida_memi(31 downto 25);
	--opcode <= aux_saida_memi(6 downto 0);

	instancia_pc : component pc
	port map(
		entrada => aux_saida_mux_jump,
		stall_pc => aux_saida_hazard_stall_pc,
		saida   => aux_saida_pc,
		clk     => clock,
		reset   => reset
	);

	instancia_adder4 : component Adder_4
	port map(
		adder4_in =>	aux_saida_pc,
		adder4_out =>    aux_saida_adder4
	);
	
	instancia_adder_normal_cima : component Adder_normal
	port map(
		adder_in1	 =>	aux_saida_adder4,
		adder_in2 => aux_saida_sll2,
		adder_out =>   aux_saida_addnormal_cima 
	);

	instancia_adder_normal_baixo : component Adder_normal
	port map(
		adder_in1	 =>	aux_saida_regD_pc4,
		adder_in2 => aux_saida_sll2,
		adder_out =>   aux_saida_addnormal_baixo
	);

	instancia_and : component and_port
	port map(
        entrada1   =>   aux_saida_alu_b ,
        entrada2   =>  branch,
        saida   =>   aux_saida_and
	);

	instancia_mux21_branch : component mux21
	port map(
		dado_ent_0 => aux_saida_adder4,
		dado_ent_1 => aux_saida_addnormal_sleft,
        sele_ent  =>    aux_saida_and,
        dado_sai  =>  aux_saida_mux_branch 
	);

	instancia_mux21_jal : component mux21
	port map(
		dado_ent_0 => aux_saida_mux_branch,
		dado_ent_1 => aux_saida_addnormal_4,
        sele_ent  =>    jal,
        dado_sai  =>  aux_saida_mux_jump
	);

	instancia_sll2 : component shift_left2
	port map(
		signal_extend_in  => aux_saida_extensor,
		exit_sll2  => aux_saida_sll2
	);

	instancia_memi : component memi
	port map(
		clk  => clock,
		reset  => reset,
		Endereco => aux_saida_pc,
		Instrucao => aux_saida_memi
	);

	instancia_banco_reg : component banco_registradores
	port map(
		ent_Rs1_ende => aux_saida_memi(19 downto 15),
        ent_Rs2_ende => aux_saida_memi(24 downto 20),
        ent_Rd_ende => aux_saida_memi(11 downto 7),
        write_data_reg => aux_saida_mux41,
        sai_Reg1_dado => aux_saida_data_reg1,
        sai_Reg2_dado => aux_saida_data_reg2,
        clk    => clock,
		RegWEN => RegWEN,
        data_len_breg => load_len
	);

	instancia_extensor : component extensor
	port map(
		entrada_Rs  => aux_saida_memi,
		extendop  => extendop,
		saida => aux_saida_extensor
	);

	instancia_mux21_extend : component mux21
	port map(
		dado_ent_0 => aux_saida_data_reg2,
		dado_ent_1 => aux_saida_extensor,
        sele_ent  => extend_sel,
        dado_sai  =>  aux_saida_mux21_extend
	);

	instancia_alu: component ula
	port map(
		entrada_a => aux_saida_data_reg1,
		entrada_b  => aux_saida_mux21_extend,
        seletor  => ALUOP,
		saida  =>  aux_saida_alu ,
		b  => aux_saida_alu_b
	);

	instancia_memd: component memd
	port map(
		clk => clock,
		mem_sel  => mem_sel,
        adress_mem  => aux_saida_alu,
		write_data_mem =>  aux_saida_data_reg2,
		read_data_mem => aux_saida_memd,
		data_len_memd  => store_len 
	);

	instancia_mux41 : component mux41
	port map(
		dado_ent_0 => aux_saida_memd,
		dado_ent_1 => aux_saida_alu,
		dado_ent_2 => aux_saida_adder4,
		dado_ent_3 => aux_saida_adder4, -- nao usar
        sele_ent  =>    MUX_final,
        dado_sai  =>  aux_saida_mux41
	);

	funct3 <= aux_saida_memi(14 downto 12);
	funct7 <= aux_saida_memi(31 downto 25);
	opcode <= aux_saida_memi(6 downto 0);
	
end architecture comportamento;