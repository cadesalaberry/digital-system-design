-- describe what this circuit does
--
-- entity name: g23_Seconds_to_Days
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 21/01/2014

library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity g23_Seconds_to_Days is
	port (
		seconds			: in	unsigned(16 downto 0);
		day_fraction	: out	unsigned(39 downto 0)
	);
end g23_Seconds_to_Days;


architecture cascading of g23_Seconds_to_Days is

	signal adder1: unsigned(19 downto 0);
	signal adder2: unsigned(23 downto 0);
	signal adder3: unsigned(26 downto 0);
	signal adder4: unsigned(27 downto 0);
	signal adder5: unsigned(28 downto 0);
	signal adder6: unsigned(30 downto 0);
	signal adder7: unsigned(34 downto 0);
	signal adder8: unsigned(39 downto 0);
	signal adder9: unsigned(40 downto 0);

begin
	
	adder1 <= seconds + (seconds & "00");
	adder2 <= adder1  + (seconds & "000000");
	adder3 <= adder2  + (seconds & "000000000");
	adder4 <= adder3  + (seconds & "0000000000");
	adder5 <= adder4  + (seconds & "00000000000");
	adder6 <= adder5  + (seconds & "0000000000000");
	adder7 <= adder6  + (seconds & "00000000000000000");
	adder8 <= adder7  + (seconds & "0000000000000000000000");
	adder9 <= adder8  + (seconds & "00000000000000000000000");
	
	day_fraction <= adder9;

end cascading;
