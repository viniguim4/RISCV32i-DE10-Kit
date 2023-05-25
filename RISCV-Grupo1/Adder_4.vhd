library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- esse component ira realizar a soma de +4 à um sinal

entity Adder_4 is
	port(
		adder4_in	        :   in std_logic_vector(31 downto 0);	

		adder4_out	        :   out std_logic_vector(31 downto 0)
    );
end entity Adder_4;


architecture  behavior of Adder_4 is
	begin
        -- incrementa 4 na entrada para poder ir para a proxima instrução
		adder4_out <= std_logic_vector(unsigned(adder4_in) +  x"00000004");  
			
end architecture behavior;