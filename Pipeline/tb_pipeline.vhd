-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Testbench para o processador_ciclo_unico
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Este arquivo irá gerar um sinal de clock e reset de modo a possibilitar a simulação do DUT processador_ciclo_unico

entity tb_pipeline is
end tb_pipeline;

architecture estimulos of tb_pipeline is
	-- Declarar a unidade sob teste
	component via_de_dados_pipeline
		port (
			reset : in std_logic;
			clock : in std_logic
		);
	end component;

	signal clock : std_logic;
	signal reset : std_logic;

	-- Definição das configurações de clock				
	constant PERIODO    : time := 20 ns;
	constant DUTY_CYCLE : real := 0.5;
	constant OFFSET     : time := 15 ns;
begin
	-- instancia o componente 
	instancia : via_de_dados_pipeline port map(clock => clock, reset => reset);
	-- processo para gerar o sinal de clock 		
	gera_clock : process
	begin
		wait for OFFSET;
		CLOCK_LOOP : loop
			clock <= '1';
			wait for (PERIODO - (PERIODO * DUTY_CYCLE));
			clock <= '0';
			wait for (PERIODO * DUTY_CYCLE);
		end loop CLOCK_LOOP;
	end process gera_clock;
	-- processo para gerar o estimulo de reset		
	gera_reset : process
	begin
		reset <= '1';
		--for i in 1 to 2 loop
		--	wait until rising_edge(clock);
		--end loop;
		wait for 10 ns;
		reset <= '0';
		wait;
	end process gera_reset;
end;