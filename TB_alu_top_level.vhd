library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.PKG_TESTBENCH.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE STD.TEXTIO.ALL;

entity alu_testbench is
	generic (
		g_COMMAND_FILE : string := "alu_command_file.txt";
		g_VERBOSE      : boolean := false;
		g_FRAME_CLKS   : positive := 1;
		g_RAM_ADDR_SIZE : natural := 6;
		g_RAM_DATA_SIZE : natural := 32
		);
	port (
        tb_clk                 : out      std_logic;                      -- Clock signal
       
		tb_alu_output          : inout    std_logic_vector(7 downto 0);   -- Output of "alu_top_level" for test bench to print to screen
		
		tb_instr_ram_data_in   : out      std_logic_vector(g_RAM_DATA_SIZE - 1 downto 0) := (others => '0');
		tb_instr_ram_addr      : out      unsigned        (g_RAM_ADDR_SIZE - 1 downto 0) := (others => '0');
		tb_dp_instr_ram_we     : out      std_logic                                      :=            '0'
		);
end entity alu_testbench;

architecture TB of alu_testbench is
	
  ---------------------------------------
  -- Constants
  -------------------------------------
  constant tb_name           : string  := "ALU_1_Test_Bench";
  constant c_data_word       : natural := 32;
  constant c_addr_index      : natural := 21;
  constant c_inst_data_index : natural := 4;
  
  constant tb_ram_addr_size  : natural := 6;
  constant tb_ram_data_size  : natural := 32;
  constant SixtyFour_Count   : natural := 64;
  constant Thirty_Two_Count  : natural := 32;
  constant Eight_Count       : natural := 64;
  
  --time constants
  constant sim_time_limit    : time    := 1000 ns;  -- Simulation time limit (adjust as needed)
  constant clock_period      : time    := 10 ns;  -- Desired clock period (adjust as needed)
       
  ---------------------------------------
  -- Components
  ---------------------------------------
  
  --  n/a
  
  ---------------------------------------
  -- Signals
  ---------------------------------------
	
	signal testname      : string(1 to 64)              := (others => ' ');
	signal clock_internal  : std_logic := '0';
	signal instr_command : std_logic_vector(7 downto 0) := (others => '0');

  ---------------------------------------
  -- Procedures
  ---------------------------------------
begin
	
  ---------------------------------------
  -- Instantiations
  ---------------------------------------	
	
		--Instantiate the Unit under Test "alu_top_level.vhd" 
		UUT : entity work.ALU_1 
			port map(
				clk           => tb_clk,										--clock driving from "alu_top_level_tb.vhd" to UUT(alu_top_level.vhd)
				
				alu_output    => tb_alu_output,							--Operation output from UUT(alu_top_level.vhd) to be displayed on screen by Test Bench
								
				instr_ram_data_in => tb_instr_ram_data_in,
				instr_ram_addr    => tb_instr_ram_addr,
				instr_ram_we      => tb_dp_instr_ram_we
			);

  ---------------------------------------
  -- Combinational Logic
  ---------------------------------------	

-- Clock generation process
    process
    begin
        while now < sim_time_limit loop
            clock_internal <= not clock_internal;
            tb_clk <= clock_internal;  -- Output the clock signal

            wait for clock_period / 2;  -- Half the period for 50% duty cycle
        end loop;
        wait;
    end process;
	
	
  ---------------------------------------
  -- Logic
  ---------------------------------------
  
  Proc_Alu_Run_Test : process is
  
    file test_input_file : text open read_mode is g_command_file;
    variable v_file_line : line;
    variable v_read_data : std_logic_vector(7 downto 0); 	
		
  ---------------------------------------------		
  -- Procedures	for TestBench	
  ---------------------------------------------	
  procedure parse_command(variable this_line : line) is 
	variable v_cmd      : string(1 to 32);
	variable v_arg1      : string(1 to 32);	
	variable v_arg2      : string(1 to 32);	
	variable v_cmd_len      : natural := 1;
	variable v_arg1_len      : natural := 1;
	variable v_arg2_len      : integer := 1;
  
	begin 
	
		sread(v_file_line, v_cmd, v_cmd_len);
		if v_cmd_len > 0 then
			if v_cmd(1) /= '#' then 
				if v_cmd(1 to v_cmd_len) = "STR" then
					--tb_instr_ram_data_in <=
					sread(v_file_line, v_arg1, v_arg1_len);
					sread(v_file_line, v_arg2, v_arg2_len);
					
				end if;
			end if;
			 print("MADE IT TO THE PARSE COMMAND");
		end if;
	 
	end procedure parse_command;
	
 
-----------------------------------------------------------------  
-- Testbench
-----------------------------------------------------------------  
  		begin  --Test Bench Here
		wait for 1 fs;
		while not endfile(test_input_file) loop
 			readline(test_input_file, v_file_line);                        --read the first line of the file "assembly_instr_input.txt"
			parse_command(v_file_line);
			end loop;											     -- so we can use the read data
																	 
		print(cr & "===> End of File Reached");
		
		update_testname(tb_name, "DONE", testname);
				wait;
		
		end process;


end architecture TB;
