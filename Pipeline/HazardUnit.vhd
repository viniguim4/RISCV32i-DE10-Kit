library ieee;
use ieee.std_logic_1164.all;

entity HazardUnit is
  port (
    -- entradas da vinda da controladora
    branch : in std_logic;
    jal : in std_logic;
    instrucao : in std_logic_vector(31 downto 0);  -- vai usar opcode e funct3 
    --entradas vinda do reg dec (nada)

    -- entradas vinda do reg exec
    RegWEN_exe, MUX_final_exe : in std_logic; --(men_sel = Menwrite) (RegWEN = RegWrite)
    Rs1D, Rs2D : in std_logic_vector(4 downto 0);
    Rs1E, Rs2E : in std_logic_vector(4 downto 0);
    --entrada vinda do reg mem
    RegWEN_mem, MUX_final_mem: in std_logic;
    WriteRegE, WriteRegM : in std_logic_vector(4 downto 0);

    -- entradas vinda dp reg wb
    RegWEN_wb : in std_logic;
    WriteRegW : in std_logic_vector(4 downto 0);

    --saidas
    stall_pc : out std_logic ;

    stall_dec : out std_logic;
    forwardAD, forwardBD : out  std_logic;

    flush_exe : out std_logic;
    forwardAE, forwardBE : out  std_logic_vector(1 downto 0)

  );
end HazardUnit;

architecture Behavioral of HazardUnit is
  signal hazardDetected : std_logic; -- Internal signal to detect hazards
  signal lwstall, branchstall : std_logic;
  begin
    
    process(lwstall, branchstall, branch, RegWEN_exe, MUX_final_exe, RegWEN_mem, MUX_final_mem, WriteRegE, WriteRegM, RegWEN_wb, WriteRegW) is
      begin
        --logia mux_exe_alu forwardAE
        if ((RS1E /= "00000") and (RS1E = WriteRegM) and (RegWEN_mem = '1') )then
            ForwardAE <= "10";
        elsif ((RS1E /= "00000") and (RS1E = WriteRegW) and RegWEN_wb = '1') then
            ForwardAE <= "01";
        else ForwardAE <= "00";
        end if;
        
        --logia mux_exe_alu forwardBE
        if ((RS2E /= "00000") and (RS2E = WriteRegM) and RegWEN_mem = '1') then
          ForwardBE <= "10";
        elsif ((RS2E /= "00000") and (RS2E = WriteRegW)and RegWEN_wb = '1') then
            ForwardBE <= "01";
        else ForwardBE <= "00";
        end if;
        
          --stalls
        if(((RS1D = RS2E) OR (RS2D = RS2E)) and MUX_final_exe = '1') then
          lwstall <= '1';
        else lwstall <= '0';
        end if;
            --(branch= '1' and RegWEN_exe= '1' and (WriteRegE = RS1D  OR WriteRegE = RS2D )) OR (branch= '1' and MUX_final_mem = '1' and (WriteRegM = RS1D OR WriteRegM = RS2D)) )
        if( (branch= '1' and RegWEN_exe= '1') OR (branch= '1' and MUX_final_mem = '1' and (WriteRegM = RS1D OR WriteRegM = RS2D)) ) then
          branchstall <= '1';
        else branchstall <= '0';
        end if;

        stall_pc <= lwstall or branchstall;
        stall_dec <= lwstall or branchstall;
        flush_exe <= lwstall or branchstall;

        --instrução b
        if((RS1D /= "00000") and (RS1D = WriteRegM) and RegWEN_mem = '1') then 
          forwardAD  <= '1';
        else forwardAD <= '0';
        end if;

        if((RS2D /= "00000") and (RS2D = WriteRegM) and RegWEN_mem = '1') then 
          forwardBD  <= '1';
        else forwardBD <= '0';
        end if;

    end process;

end Behavioral;
