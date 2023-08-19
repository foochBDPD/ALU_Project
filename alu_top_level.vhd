
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ALU_1 is
Generic (
         g_reg_size    : integer := 4;           -- Not Used. Will leave in here for now in case needed 
         g_num_of_clks : integer := 7;           -- Just a default number for now. May be changed as seen fit
         g_operation   : string  := "TEST VALUE" -- Input for Addition, Subtraction, Multiplication, or Division
        );
Port(   
     clk     : in  std_logic; --clock signal
     reg_a    : in  std_logic_vector(7 downto 0);   -- Input register A
     reg_b    : in  std_logic_vector(7 downto 0);   -- Input register B
     alu_output  : out std_logic_vector(7 downto 0);    -- output of ALU
	 
	 instr_ram_data_in : in std_logic_vector(32  - 1 downto 0) := (others => '0');
	 instr_ram_addr    : in unsigned(6 - 1 downto 0) := (others => '0');
	 instr_ram_we        : in std_logic := '0'
		);
     
end ALU_1;

architecture Behavioral of ALU_1 is

-------------------------- Signal Declarations --------------------------
signal s_reg_a   : std_logic_vector(7 downto 0); 
signal s_reg_b   : std_logic_vector(7 downto 0); 
signal s_alu_output : std_logic_vector(7 downto 0); 


BEGIN

------------------------- Process Section -------------------------
process(clk)
begin
if(rising_edge(clk)) then 
    if g_operation = "ADD" then
        s_alu_output <= s_reg_a + s_reg_b;     -- Addition Operation
    elsif g_operation = "Subtract" then
        s_alu_output <= s_reg_a - s_reg_b;     -- Subtraction Operation
    elsif g_operation = "Multiply" then
       -- s_alu_output <= s_reg_a * s_reg_b;     -- Multiplication Operation
    elsif g_operation = "Divide" then
       -- s_alu_output <= s_reg_a / s_reg_b;     -- Division
    else 
        s_alu_output <= s_reg_a + s_reg_b;     -- Default is to perform Addition Operation
    end if;      
end if;
end process;   


------------------------- Logic Section -------------------------
s_reg_a <= reg_a;
s_reg_b <= reg_b;
alu_output <= s_alu_output;

end Behavioral;