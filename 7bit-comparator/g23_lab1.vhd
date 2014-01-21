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

entity g23_Seconds_to_Days is
	port (
		seconds			: in	unsigned(16 downto 0);
		day_fraction	: out	unsigned(39 downto 0);
	);
end g23_Seconds_to_Days;

