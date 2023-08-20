--DP_RAM Block For XILINX FPGAS
--Mike Palladino
--8_19_23

library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity dp_ram is
Generic (
         simulation      : boolean := false;           
         output_regs     : boolean := false; 
		 addr_width 	 : natural := 6;
		 data_width 	 : natural := 32
        );
Port(   
     --Port 1
	 p1_clk              : in  std_logic; 
     p1_we               : in std_logic;    
	 p1_addr             : in unsigned(addr_width  - 1 downto 0);
	 p1_din              : in std_logic_vector(data_width - 1 downto 0);        
	 p1_dout             : out std_logic_vector(data_width - 1 downto 0);       

	  --Port 1
	 p2_clk              : in  std_logic; 
     p2_we               : in std_logic;    
	 p2_addr             : in unsigned(addr_width  - 1 downto 0);
	 p2_din              : in std_logic_vector(data_width - 1 downto 0);        
	 p2_dout             : out std_logic_vector(data_width - 1 downto 0)       
		);
end entity dp_ram;

architecture mem of dp_ram is
 signal p1_dout_int : std_logic_vector(data_width - 1 downto 0);
 signal p2_dout_int : std_logic_vector(data_width - 1 downto 0);
 type dp_ram_type is array (2**addr_width - 1 downto 0) of std_logic_vector(data_width - 1 downto 0);
 shared variable RAM : dp_ram_type; --Actual RAM

 BEGIN

  Opt_Reg_Gen: if output_regs = true generate
	Port1_Data_Out_Reg: Process (p1_clk) is
	begin 
		if p1_clk'event and p1_clk = '1' then
			p1_dout <= p1_dout_int;
		end if;
	end process;
	
    Port2_Data_Out_Reg: process (p2_clk) is
	BEGIN
		if p2_clk'event and p2_clk = '1' then
			p2_dout <= p2_dout_int;
		end if;
	end process Port2_Data_Out_Reg;
  end generate;
  
  Opt_Reg_No: if output_regs = false generate
	p1_dout <= p1_dout_int;
	p2_dout <= p2_dout_int;
  end generate;
  
  Port1_Mem_access : process (p1_clk) is
  begin
	if p1_clk'event and p1_clk = '1' then
		if p1_we = '1' then 
			RAM(to_integer(p1_addr)) := p1_din;
		end if;
		p1_dout_int <= RAM(to_integer(p1_addr));
	end if;
   end process Port1_Mem_Access;
   
  Port2_Mem_access : process (p2_clk) is
  begin
	if p2_clk'event and p2_clk = '1' then
		if p2_we = '1' then 
			if simulation = true then
				assert (p2_we /= p1_we) or (p1_addr /= p2_addr)
					report"[dp_ram] Write Collision in dual-port memory. Address " & integer'image(to_integer(p2_addr)) severity error;
			end if;
			RAM(to_integer(p2_addr)) := p2_din;
		end if;
		p2_dout_int <= RAM(to_integer(p2_addr));
	end if;
  end process Port2_Mem_Access;
 
end architecture mem;