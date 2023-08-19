library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_1 is
Generic (
         g_REG_SIZE      : integer := 8;           -- Not Used. Will leave in here for now in case needed 
         g_operation     : string  := "ADD"; -- Input for Addition, Subtraction, Multiplication, or Division
		 g_RAM_ADDR_SIZE : natural := 6;
		 g_RAM_DATA_SIZE : natural := 32
        );
Port(   
     clk               : in  std_logic; --clock signal
     alu_output        : out std_logic_vector(7 downto 0);    -- output of ALU
	 instr_ram_data_in : in std_logic_vector(g_RAM_DATA_SIZE  - 1 downto 0) := (others => '0');
	 instr_ram_addr    : in unsigned(g_RAM_ADDR_SIZE - 1 downto 0)          := (others => '0');
	 instr_ram_we      : in std_logic                                       := '0'
		);
end entity ALU_1;

architecture Behavioral of ALU_1 is

-------------------------- Signal Declarations --------------------------
signal s_reg_a         : std_logic_vector(g_REG_SIZE - 1 downto 0) := x"00"; 
signal s_reg_b         : std_logic_vector(g_REG_SIZE - 1 downto 0) := x"00"; 
signal s_alu_output    : std_logic_vector(7 downto 0)              := x"00";


BEGIN

------------------------- Process Section -------------------------
	process(clk)
		begin
			if(rising_edge(clk)) then 
				if  g_operation = "ADD" then
       -- s_alu_output <= s_reg_a + '1';     -- Addition Operation
				elsif g_operation = "Subtract" then
      --  s_alu_output <= s_reg_a - s_reg_b;     -- Subtraction Operation
				elsif g_operation = "Multiply" then
       -- s_alu_output <= s_reg_a * s_reg_b;     -- Multiplication Operation
				elsif g_operation = "Divide" then
       -- s_alu_output <= s_reg_a / s_reg_b;     -- Division
				else 
        --s_alu_output <= s_reg_a + s_reg_b;     -- Default is to perform Addition Operation
				end if;      
			end if;
	end process;   

end Behavioral;