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
end HazardUnit;

architecture Behavioral of HazardUnit is
  signal hazardDetected : std_logic; -- Internal signal to detect hazards

begin
  process
  signal lwstall, branchstall : std_logic;
  begin
    --logia mux_exe_alu forwardAE
    if ((RS1E /= "00000") AND (RS1E = WriteRegM) AND RegWEN__mem) then
        ForwardAE <= "10";
    elsif ((RS1E /= "00000") AND (RS1E = WriteRegW) AND RegWEN__wb) then
        ForwardAE <= "01";
    else ForwardAE <= "00";
    end if;
    
    --logia mux_exe_alu forwardBE
    if ((RS2E /= "00000") AND (RS2E = WriteRegM) AND RegWEN__mem) then
      ForwardAE <= "10";
    elsif ((RS2E /= "00000") AND (RS2E = WriteRegW) AND RegWEN__wb) then
        ForwardAE <= "01";
    else ForwardAE <= "00";
    end if;
     
      --stalls
    lwstall <= ((RS1D = RS2E) OR (RS2D = RS2E)) AND MUX_final_exe;
    branchstall <= branch AND RegWEN__exe AND (WriteRegE = RS1D  OR WriteRegE = RS2D )
              OR
              branch AND MemtoRegM AND (WriteRegM = RS1D OR WriteRegM = RS2D);

    stall_pc <= lwstall or branchstall;
    stall_dec <= lwstall or branchstall;
    flush_dec <= lwstall or branchstall;

    --instrução b
    forwardAD <= (RS1D /= "00000") AND (RS1D = WriteRegM) AND RegWEN__mem;
    forwardBD <= (RS2D /= "00000") AND (RS2D = WriteRegM) AND RegWEN__mem;
  end process;

end Behavioral;
