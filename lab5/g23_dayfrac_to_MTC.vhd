-- Converts an earth time and date into mars time of day.
--
-- entity name: g23_dayfrac_to_MTC
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 04/04/2014


library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity g23_dayfrac_to_MTC is
	PORT (
		clock		: in STD_LOGIC;
		enable		: in STD_LOGIC;
		Ndays		: in STD_LOGIC_VECTOR(13 downto 0);
		day_frac	: in STD_LOGIC_VECTOR(39 downto 0);
		
		-- Time corresponding to the fraction of the day.
		Hours		: out	STD_LOGIC_VECTOR(4 downto 0);
		Minutes		: out	STD_LOGIC_VECTOR(5 downto 0);
		Seconds		: out	STD_LOGIC_VECTOR(5 downto 0)
	);
end g23_dayfrac_to_MTC;


architecture cascading of g23_dayfrac_to_MTC is

	signal mult_in_frac		: UNSIGNED(63 downto 0);
	signal sbct_in_frac		: INTEGER;
	signal JD2000			: UNSIGNED(31 downto 0);
	signal frac				: UNSIGNED(31 downto 0);
	signal MTC				: STD_LOGIC_VECTOR(63 downto 0);
	signal int_out			: STD_LOGIC_VECTOR(9 downto 0);
	signal frac_part		: STD_LOGIC_VECTOR(11 downto 0);
	signal full_minutes		: UNSIGNED(35 downto 0);
	signal full_seconds		: UNSIGNED(35 downto 0);
	
	-- 14 bits for int and 18 bits for fraction = 32 bits
	constant multiplyConst	: UNSIGNED := "00000000000000111110010010011010"; -- .973244297 in binary
	-- 28 bits for int 0 and 36 bits for fraction = 64 bits
	-- 18 bit frac * 18 frac int gives 36 bit frac
	
	constant subConst		: UNSIGNED := "0000000000000000000000000000000000000010111100101111100110000000";
	-- 5 bits to represent 24 and the rest 0's for the frac (32 bits total)
	constant twentyfour		: UNSIGNED := "11000000000000000000000000000000";
	
	-- 6 bits for int and 12 bits for frac
	constant sixty			: UNSIGNED := "111100000000000000";

BEGIN
	day_frac_to_MTC : PROCESS(enable, clock) BEGIN
		
		IF enable = '0' THEN
			Hours 	<= "00000";
			Minutes <= "000000";
			Seconds <= "000000";
			
		ELSE
			
			-- JD2000 = NDays.day_frac
			-- size =   16   +(39-23)  = 32 = 16.16
			-- JD2000 <= UNSIGNED(Ndays & STD_LOGIC_VECTOR(day_frac(39 downto 23))); 
			JD2000 <= UNSIGNED(Ndays(13 downto 0) & STD_LOGIC_VECTOR(day_frac(39 downto 22)));
			
			mult_in_frac <= JD2000 * multiplyConst - subConst;
			
			frac <= "00000" & mult_in_frac(35 downto 9);
			
			-- upper 10 bits are integer, bottom 54 are decimal
			MTC <= STD_LOGIC_VECTOR(frac * twentyfour);
			
			-- Ignores the first 5 bits, and takes the 5 following as hour.
			Hours			<= MTC(58 downto 54);
			
			frac_part		<= MTC(53 downto 42);
			
			full_minutes	<= sixty * UNSIGNED("000000" & frac_part);
			
			Minutes			<= STD_LOGIC_VECTOR(full_minutes(29 downto 24));
			
			full_seconds	<= sixty * ("000000" & full_minutes(23 downto 12));
			
			Seconds			<= STD_LOGIC_VECTOR(full_seconds(29 downto 24));
		
		END IF; --if reset
		
	END PROCESS day_frac_to_MTC;

end cascading;
