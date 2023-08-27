library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity TB_dp_ram_controller is
Generic (
         g_REG_SIZE      : integer := 8;           
         g_operation     : string  := "ADD"; 
		 g_RAM_ADDR_SIZE : natural := 6;
		 g_RAM_DATA_SIZE : natural := 32
        );
Port(   
     clk                 : in  std_logic; --clock signal
     alu_output          : out std_logic_vector(7 downto 0);    -- output of ALU
	 instr_ram_data_in   : in std_logic_vector(g_RAM_DATA_SIZE  - 1 downto 0)  := (others => '0');
	 instr_ram_addr      : in unsigned(g_RAM_ADDR_SIZE - 1 downto 0)          := (others => '0');
	 instr_ram_we        : in std_logic                                        := '0'
		);
end entity ALU_1;

architecture Behavioral of TB_dp_ram_controller is



-------------------------- Signal Declarations --------------------------
--RAM Signals 
--signal instr_ram_we : std_logic;
--signal instr_ram_data_in  : std_logic_vector(g_ram_data_size - 1 downto 0);
signal instr_ram_data_out : string(1 to 3) := "000";
--signal instr_ram_addr     : unsigned(g_ram_addr_size - 1 downto 0);

--RAM Signals
signal data_ram_we : std_logic;
signal data_ram_data_in : std_logic_vector(g_RAM_DATA_SIZE - 1 downto 0);
signal data_ram_data_out : std_logic_vector(g_RAM_DATA_SIZE - 1 downto 0);
signal data_ram_addr : unsigned(g_RAM_ADDR_SIZE -1 downto 0);

		
	

BEGIN
 		
------------------------- Process Section -------------------------
	process(clk)
		begin
			if(rising_edge(clk)) then 
				
			end if;
	
	end process;   

end Behavioral;