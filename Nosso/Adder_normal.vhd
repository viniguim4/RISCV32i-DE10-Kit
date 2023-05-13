library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- esse component ira realizar a soma de +4 à um sinal

entity adder_normal is
	port(
		adder_in1	        :   in std_logic_vector(31 downto 0);	
        adder_in2	        :   in std_logic_vector(31 downto 0);	

		adder_out	        :   out std_logic_vector(31 downto 0)
    );
end entity adder_normal;


architecture  behavior of adder_normal is
	begin
        -- incrementa 4 na entrada para poder ir para a proxima instrução
		adder_out <= std_logic_vector(unsigned(adder_in1) +  unsigned(adder_in2));  
			
end architecture behavior;