--NOTE:
-- Once std_logic_unsigned was dropped and inputs/outputs with their respective
-- Signals were changed to integers, synthesis worked. Not yet simulated...next step
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

entity ALU_1 is
Generic (
         g_reg_size    : integer := 4;           -- Not Used. Will leave in here for now in case needed 
         g_num_of_clks : integer := 7;           -- Just a default number for now. May be changed as seen fit
         g_operation   : string  := "TEST VALUE" -- Input for Addition, Subtraction, Multiplication, or Division
        );
Port(   
     i_Clk     : in  std_logic; --clock signal
     i_RegA    : in  integer;   -- Input register A
     i_RegB    : in  integer;   -- Input register B
     o_Result  : out integer    -- output of ALU
     );
end ALU_1;

architecture Behavioral of ALU_1 is

-------------------------- Signal Declarations --------------------------
signal s_RegA   : integer;
signal s_RegB   : integer;
signal s_Result : integer;


BEGIN

------------------------- Process Section -------------------------
process(i_Clk)
begin
if(rising_edge(i_Clk)) then 
    if g_operation = "ADD" then
        s_Result <= s_RegA + s_RegB;     -- Addition Operation
    elsif g_operation = "Subtract" then
        s_Result <= s_RegA - s_RegB;     -- Subtraction Operation
    elsif g_operation = "Multiply" then
        s_Result <= s_RegA * s_RegB;     -- Multiplication Operation
    elsif g_operation = "Divide" then
        s_Result <= s_RegA / s_RegB;     -- Division
    else 
        s_Result <= s_RegA + s_RegB;     -- Default is to perform Addition Operation
    end if;      
end if;
end process;   


------------------------- Logic Section -------------------------
s_RegA   <= i_RegA;
s_RegB   <= i_RegB;
o_Result <= s_Result;

end Behavioral;