------------------------------------------------------------------------------------------------------------------------------------
-- Title      : VHDL-2008 Test Package
-- Project    : 
------------------------------------------------------------------------------------------------------------------------------------
-- Description: Package full of nice goodies for test benching.
------------------------------------------------------------------------------------------------------------------------------------
-- Revisions History:
--     Changes tracked in git
------------------------------------------------------------------------------------------------------------------------------------
---                                                 BAE PROPRIETARY INFORMATION                                                    -
------------------------------------------------------------------------------------------------------------------------------------
---                                                ITAR Technical Data / US ONLY                                                   -
------------------------------------------------------------------------------------------------------------------------------------
---                                                    Copyright 2022,                                                             -
---                                                    BAE SYSTEMS                                                                 -
---                                                    All Rights Reserved                                                         -
------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.env.all;
use std.textio.all;

------------------------------------------------------------------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------------------------------------------------------------------
package pkg_testbench is
  ----------------------------------------------------------------------------------------
  -- Constants
  ----------------------------------------------------------------------------------------
  constant MHz              : real   := real(10 ** 6);
  constant KHz              : real   := real(10 ** 3);
  constant end_test_message : string := "! ! !   S I M U L A T I O N   C O M P L E T E   ! ! !";

  ----------------------------------------------------------------------------------------
  -- Functions
  ----------------------------------------------------------------------------------------
  function real2str (
    constant real_val   : real;
    constant dec_places : natural)
    return string;

  function time2real (
    constant time_in : time;
    constant unit    : time)
    return real;

  function resize (
    constant string_in : string;
    constant out_len   : natural)
    return string;

  function resize (
    constant val_in    : std_logic_vector;
    constant new_size  : natural;
    constant ascending : boolean)
    return std_logic_vector;

  function hstring2slv (
    constant string_in : string)
    return std_logic_vector;

  function istring2intg (
    constant string_in : string)
    return integer;

  ----------------------------------------------------------------------------------------
  -- Procedures
  ----------------------------------------------------------------------------------------
  procedure print (
    string_to_print : in string);

  procedure print (
    string_to_print : in string;
    end_char        : in character);

  procedure print (
    string_to_print : in string;
    verbose         : in boolean);

  procedure clk_wait (
    signal clk_in        : in std_logic;      -- Clock to wait on
    constant num_to_wait : in natural := 1);  -- Number of clocks to wait

  procedure Clock_Generator(
    constant clk_Hz       : in    real;        -- Frequency of the clock
    constant scale_factor : in    real;        -- Scaling for speeding/slowing the clock
    signal clk_out        : inout std_logic);  -- Clock Output

  procedure update_testname (
    constant unit_name   : in  string;   -- Testbench or module name
    constant test_name   : in  string;   -- Name for the particular test
    signal test_name_sig : out string);  -- Test name signal that is going to be updated

  procedure end_test;

end package pkg_testbench;

------------------------------------------------------------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------------------------------------------------------------
package body pkg_testbench is

  ----------------------------------------------------------------------------------------
  -- Functions
  ----------------------------------------------------------------------------------------
  -- real2str
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- This function takes in a real value as well as a natural indicating the desired number of decimal places and converts the value
  -- to a string representing a decimal representation with the requested number of decimal places (returns a string of 2.45)
  -- instead of the scientific notation string value returned by real'image(number) (resturns a string of 2.450000e+00).
  function real2str (
    constant real_val   : in real;
    constant dec_places : in natural)
    return string is

    variable wholes     : real;
    variable remain     : real;
    variable place      : natural;
    variable remain_str : string(1 to dec_places);
  begin  -- procedure real2str
    assert dec_places > 0 report "real2str: Need at least 1 decimal place" severity failure;

    wholes := trunc(real_val);
    remain := trunc((real_val mod 1.0) * real(10 ** dec_places));

    remain_str := (others => '0');
    place      := integer'image(integer(remain))'length;

    remain_str(1 + (dec_places - place) to dec_places) := integer'image(integer(remain));
    return integer'image(integer(wholes)) & "." & remain_str;
  end function real2str;

  -- time2real
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- This function converts a time type value to a real value based on the provided unit
  function time2real (
    constant time_in : time;
    constant unit    : time)
    return real is

    variable v_div_int : integer;
  begin  -- procedure time2real
    assert time_in > unit report "time2real: The input time is smaller than the unit. Returning 0." severity warning;
    v_div_int := time_in / unit;
    return real(v_div_int);
  end time2real;

  -- resize
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- Acts like a string version the IEEE numeric_std resize functions for signed/unsigned. Note that this creates a left-justified
  -- string output.
  function resize (
    constant string_in : string;
    constant out_len   : natural)
    return string is

    -- Impose a direction on the input string to avoid direction warnings
    alias a_string_in : string(1 to string_in'length) is string_in;
    variable tmp_str  : string(1 to out_len) := (others => ' ');
  begin  -- function resize

    -- Input string longer then output length
    if string_in'length > out_len then
      -- Set warning to alert user
      report "[ resize ] Truncating input string." severity warning;
      -- Truncate the string by setting as much as we can
      tmp_str := a_string_in(1 to out_len);
    -- Input string is shorter than output length
    elsif string_in'length < out_len then
      -- Set all of tmp_str to ' '
      tmp_str                        := (others => ' ');
      -- Then set the appropriate characters
      tmp_str(1 to string_in'length) := a_string_in;
    -- Input and output are the same size
    elsif string_in'length = out_len then
      -- Just set tmp_str to the input string
      tmp_str := a_string_in;
    end if;

    return tmp_str;
  end function resize;

  -- resize
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- Acts like a string version the IEEE numeric_std resize functions for signed/unsigned. Note that this creates a left-justified
  -- string output. There is an additional boolean input, 'ascending', which indicates the direction of the output. The
  -- justification (left or right) is determined based on the direction such that the resized value occupies the low-order bits of
  -- the output. Ascending values are therefore left-justified and descending values are right-justified.
  function resize (
    constant val_in    : std_logic_vector;
    constant new_size  : natural;
    constant ascending : boolean)
    return std_logic_vector is

    alias a_temp       : std_logic_vector(val_in'high downto val_in'low) is val_in;
    variable size_diff : integer;
    variable v_temp    : std_logic_vector(new_size - 1 downto 0);
  begin  -- function resize
    v_temp := (others => '0');

    size_diff := new_size - val_in'length;

    -- If sizes are equal, send it straight through.
    if size_diff = 0 then
      v_temp := val_in;
    else
      -- If the input is ascending (X to Y)
      if ascending = true then
        -- If the new size is larger than the width of the input, 0 pad
        if size_diff > 0 then
          v_temp(v_temp'left downto v_temp'left - size_diff + 1) := val_in;
        -- If the new size is smaller, drop bits to the right (left-aligned data)
        else
          v_temp := a_temp(a_temp'left downto (a_temp'left + size_diff + 1));
        end if;
      -- If the input is descending (X downto Y)
      else
        -- If the new size is larger than the width of the input, 0 pad
        if size_diff > 0 then
          v_temp(new_size - 1 - (new_size - val_in'length) downto 0) := a_temp;
        -- If the new size is smaller, drop bits to the left (right-aligned data)
        else
          v_temp := a_temp(a_temp'left + size_diff downto a_temp'right);
        end if;
      end if;
    end if;

    -- Return the value
    return v_temp;
  end function resize;

  -- HString2SLV
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Converts a hex value, as a string, to the equivalent std_logic_vector
  function hstring2slv (
    constant string_in : string)
    return std_logic_vector is

    alias a_string_in : string(string_in'length downto 1) is string_in;  -- Impose a direction on the string
    variable v_retval : std_logic_vector(string_in'length * 4 - 1 downto 0);
    variable v_index  : natural;
  begin  -- function string2slv

    for i in a_string_in'range loop
      v_index := 4 * (i - 1);
      case a_string_in(i) is
        when '0'       => v_retval(v_index + 3 downto v_index) := x"0";
        when '1'       => v_retval(v_index + 3 downto v_index) := x"1";
        when '2'       => v_retval(v_index + 3 downto v_index) := x"2";
        when '3'       => v_retval(v_index + 3 downto v_index) := x"3";
        when '4'       => v_retval(v_index + 3 downto v_index) := x"4";
        when '5'       => v_retval(v_index + 3 downto v_index) := x"5";
        when '6'       => v_retval(v_index + 3 downto v_index) := x"6";
        when '7'       => v_retval(v_index + 3 downto v_index) := x"7";
        when '8'       => v_retval(v_index + 3 downto v_index) := x"8";
        when '9'       => v_retval(v_index + 3 downto v_index) := x"9";
        when 'A' | 'a' => v_retval(v_index + 3 downto v_index) := x"A";
        when 'B' | 'b' => v_retval(v_index + 3 downto v_index) := x"B";
        when 'C' | 'c' => v_retval(v_index + 3 downto v_index) := x"C";
        when 'D' | 'd' => v_retval(v_index + 3 downto v_index) := x"D";
        when 'E' | 'e' => v_retval(v_index + 3 downto v_index) := x"E";
        when 'F' | 'f' => v_retval(v_index + 3 downto v_index) := x"F";
        when others    => report "[ hstring2slv ] Invalid hex character!" severity failure;
      end case;
    end loop;  -- i

    return v_retval;
  end function hstring2slv;

  -- IString2Intg
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Converts a integer value, as a string, to the equivalent integer
  -- Does some simple checks, but hard to do real good checks for avoiding overruns. Flags a warning is the length of the input
  -- string is greater than 10 characters, as we might overrun a 32-bit integer.
  -- Example Runs
  -- # ** Warning: [ istring2intg ] Integer string my be larger than a 32-bit signed value. Please verify output.
  -- #    Time: 0 ns  Iteration: 0  Instance: /bfm_lpc_cntlr
  -- # ** Warning: [ istring2intg ] Integer string my be larger than a 32-bit signed value. Please verify output.
  -- #    Time: 0 ns  Iteration: 0  Instance: /bfm_lpc_cntlr
  -- # ** Warning: [ istring2intg ] Integer string my be larger than a 32-bit signed value. Please verify output.
  -- #    Time: 0 ns  Iteration: 0  Instance: /bfm_lpc_cntlr
  -- # :: Print Valid Command List
  -- # :: Testing new functions
  -- # -- hstring2slv
  -- # Input:  0123456789ABCDEF
  -- # Output: 0123456789ABCDEF
  -- # -- istring2intg
  -- # Input:  987654321
  -- # Output: 987654321
  -- # -- istring2intg, negative
  -- # Input:  -987654321
  -- # Output: -987654321
  -- # -- istring2intg, overrun (First warning above)
  -- # Input:  2147483648
  -- # Output: -2147483648
  -- # -- istring2intg, long negative (Second warning above)
  -- # Input:  -2147483648
  -- # Output: -2147483648
  -- # -- istring2intg, negative overrun (Third warning above)
  -- # Input:  -2147483648
  -- # Output: 2147483647
  function istring2intg (
    constant string_in : string)
    return integer is

    alias a_string_in   : string(string_in'length downto 1) is string_in;
    variable v_high_pos : integer;
    variable v_is_neg   : boolean;
    variable v_intermed : integer;
    variable v_retval   : integer := 0;
  begin
    -- If we're at length=10 and highest order number is 2, flag a warning that the out number may not be right if the overall value
    -- is larger than 2147483647
    assert (string_in'length < 10 and a_string_in(a_string_in'left) /= '-') or
      (string_in'length < 11 and a_string_in(a_string_in'left) = '-')
      report "[ istring2intg ] Integer string my be larger than a 32-bit signed value. Please verify output." severity warning;

    if a_string_in(a_string_in'left) = '-' then
      v_high_pos := string_in'length - 1;
      v_is_neg   := true;
    else
      v_high_pos := string_in'length;
      v_is_neg   := false;
    end if;

    for i in v_high_pos downto 1 loop
      v_intermed := 0;
      case a_string_in(i) is
        when '0'    => v_intermed := 0;
        when '1'    => v_intermed := 1;
        when '2'    => v_intermed := 2;
        when '3'    => v_intermed := 3;
        when '4'    => v_intermed := 4;
        when '5'    => v_intermed := 5;
        when '6'    => v_intermed := 6;
        when '7'    => v_intermed := 7;
        when '8'    => v_intermed := 8;
        when '9'    => v_intermed := 9;
        when others => report "[ istring2intg ] Invalid integer character!" severity failure;
      end case;
--       print("[ istring2intg ] Iteration " & to_string(i) & ": v_retval = " & to_string(v_retval) & " + " & to_string(v_intermed * 10**(i-1)));
      v_retval := v_retval + (v_intermed * 10**(i-1));
    end loop;  -- i

    if v_is_neg = true then
      v_retval := -1 * v_retval;
    end if;

    return v_retval;
  end function istring2intg;

  ----------------------------------------------------------------------------------------
  -- Procedures
  ----------------------------------------------------------------------------------------
  procedure print (
    string_to_print : in string) is
  begin
    write(output, string_to_print & LF);
  end procedure print;

  procedure print (
    string_to_print : in string;
    end_char        : in character) is
  begin
    write(output, string_to_print & end_char);
  end procedure print;

  procedure print (
    string_to_print : in string;
    verbose         : in boolean) is
  begin
    if verbose = true then
      write(output, string_to_print & LF);
    end if;
  end procedure print;

  -- Clock Generator
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- Generates a 50% duty cycle clock output based on the inputs specified
  procedure Clock_Generator (
    constant clk_Hz       : in    real;  -- Period of the clock in seconds
    constant scale_factor : in    real;  -- Scaling for speed/slowing clock
    signal clk_out        : inout std_logic) is

    variable print_Hz     : real;
    variable clk_period   : real;
    variable clk_per_time : time;
  begin  -- procedure Clock_Generator
    clk_period := 1.0 / (clk_Hz * scale_factor);

    clk_per_time := (clk_period / 2.0) * 1 sec;
    clk_out      <= '0';

    report "< " & real2str(clk_Hz, 3) & " Hz Clock Generator > Clock Period is " & real2str(clk_period * real(10 ** 9), 2) & " ns (" &
      real2str(1.0 / clk_period, 3) & " Hz)";

    loop
      wait for clk_per_time;
      clk_out <= not clk_out;
    end loop;

  end procedure Clock_Generator;

  -- Clock Wait
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- Wait for the specified number of rising edges of the specified clock
  procedure clk_wait (
    signal clk_in : in std_logic;        -- Clock to wait on
    num_to_wait   : in natural := 1) is  -- Number of rising edges to wait for
  begin
    for index in 1 to num_to_wait loop   -- Loop for 1 to num_to_wait rising edges
      wait until rising_edge(clk_in);
    end loop;  -- index
  end procedure clk_wait;

  -- End Test
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- Prints the updated test name to the transcript, then sets the test name in a string signal for display in the testbench
  procedure update_testname (
    constant unit_name   : in  string;
    constant test_name   : in  string;
    signal test_name_sig : out string) is
  begin  -- procedure update_testname
    print("[ " & unit_name & " ] :: " & test_name & " at " & time'image(now));
    test_name_sig <= resize(test_name, test_name_sig'length);
  end procedure update_testname;

  -- End Test
  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  -- Prints the end of test message and finishes the simulation
  procedure end_test is
  begin  -- procedure end_test
    print(cr & end_test_message);
    finish(0);
    wait;
  end procedure end_test;

end package body pkg_testbench;
