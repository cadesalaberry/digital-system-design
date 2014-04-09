-- A Year Month Day counter
--
-- entity name: g23_12_to_BCD
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 18/02/2014


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY g23_12_to_BCD IS

	PORT (
		input			: in	STD_LOGIC_VECTOR(11 downto 0);

		output			: out	STD_LOGIC_VECTOR(15 downto 0)
	);
	
end g23_12_to_BCD;


ARCHITECTURE alpha OF g23_12_to_BCD IS
  	signal y		: integer range 0 to 4000;
  	
	signal y_3		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_2		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_1		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_0		: STD_LOGIC_VECTOR(3 downto 0);
  	
  	signal y_2_temp	: integer range 0 to 4000;
  	signal y_1_temp	: integer range 0 to 4000;
  	signal y_0_temp	: integer range 0 to 4000;
BEGIN
  	
  	y <= TO_INTEGER(UNSIGNED(input));
	y_3	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y/1000, 4));
	y_2_temp <= (y - TO_INTEGER(UNSIGNED(y_3))*1000)/100;
	y_2	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y_2_temp, 4));
	y_1_temp <= (y - TO_INTEGER(UNSIGNED(y_3))*1000 - TO_INTEGER(UNSIGNED(y_2))*100)/10;
	y_1	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y_1_temp, 4));
	y_0_temp <= (y - TO_INTEGER(UNSIGNED(y_3))*1000 - TO_INTEGER(UNSIGNED(y_2))*100 - TO_INTEGER(UNSIGNED(y_1))*10);
	y_0	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y_0_temp, 4));
	
	output <= y_3 & y_2 & y_1 & y_0;

END alpha;