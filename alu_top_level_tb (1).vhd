library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std_logic_textio.all;
use work.pkg_testbench.all;

entity alu_testbench is
	generic (
		g_command_file : string := "alu_command_file.txt");
	port (
        clk              : out      std_logic;                      -- Clock signal
        reg_a            : out      std_logic_vector(7 downto 0);   -- Input register A to alu_top_level
        reg_b            : out      std_logic_vector(7 downto 0);   -- Input register B to alu_top_level
		opcode           : out      string;                         -- Instruction to alu_top_level.vhd
        alu_output       : in       std_logic_vector(7 downto 0);   -- Output of "alu_top_level" for test bench to print to screen
		alu_carry_out    : in	    std_logic_vector(7 downto 0);	-- Carry if we over flow for test bench to print to screen
end entity alu_testbench;

architecture alu_testbench of alu_top_level is
	
  ---------------------------------------
  -- Constants
  -------------------------------------
  
  --   n/a
    
  ---------------------------------------
  -- Components
  ---------------------------------------
  
  --  n/a
  
  ---------------------------------------
  -- Signals
  ---------------------------------------
	signal clk           : out     std_logic;					--Clock out to the "alu_top_level"
	signal reg_a         : out	   std_logic_vector(7 downto 0);--Register A data sending to "alu_top_level"
	signal reg_b         : out     std_logic_vector(7 downto 0);--Register B data sending to "alu_top_level"
	signal opcode        : out     string; 						--Opcode instruction sending to "alu_top_level"
	signal alu_output    : in      std_logic_vector(7 downto 0);--"alu_top_level" output which we will print to the screen 
	signal alu_carry_out : in      std_logic;					--"alu_top_level" output carry bit indicating overflow

  ---------------------------------------
  -- Procedures
  ---------------------------------------


begin
	
  ---------------------------------------
  -- Instantiations
  ---------------------------------------	
	
		--Instantiate the Unit under Test "alu_top_level.vhd" 
		UUT : alu_top_level port map(
			clk   <= clk,										--clock driving from "alu_top_level_tb.vhd" to UUT(alu_top_level.vhd)
			reg_a <= reg_a,										--reg_a data from "alu_command_file.txt" being sent to UUT(alu_top_level.vhd)
			reg_b <= reg_b,										--reg_b data from "alu_command_file.txt" being sent to UUT(alu_top_level.vhd)
			opcode <= opcode,									--Operation data from "alu_command_file.txt" being sent to UUT(alu_top_level.vhd)
			alu_output => alu_output,							--Operation output from UUT(alu_top_level.vhd) to be displayed on screen by Test Bench
			alu_carry_out => alu_carry_out
			);

  ---------------------------------------
  -- Combinational Logic
  ---------------------------------------	
	
	
	
  ---------------------------------------
  -- Logic
  ---------------------------------------
  
  Proc_Alu_Run_Test : process is
    file test_input_file : text open read_mode is g_command_file;
    variable v_file_line : line;

    variable v_read_data : std_logic_vector(7 downto 0); 	
	    
		
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --		
	    STIMULUS : process
		--read in the text file
		file Fin : TEXT open READ_MODE is "assembly_instr_input.txt";   
		
		--line variables for when i read that file line by line
		variable current_read_line  : line;					 --variable i use to read in the line
		variable current_read_field : std_logic_textio;      --variable i use to acutally use the data read
		
		--variable i set to write to the console window
		variable current_write_line : line:                  --STD_OUTPUT, write it to the console window
			

		begin  --Test Bench Here
		
		while (not endfile(Fin)) loop
 
			readline(Fin, current_read_line);                        --read the first line of the file "assembly_instr_input.txt"
			read(current_read_line, current_read_field)              --load current_read_field with the line we just read 
			end loop;											     -- so we can use the read data
																	 
			--ALU Output printed to Terminal with the carry
			write(current_write_line, string'("ALU Output is = ")
			write(current_write_line, alu_output);
			write(current_write_line, string'("With a Carry of = "
			write(current_write_line, alu_carry_out);
		
		end loop;	
		end process;


end architecture alu_testbench;
