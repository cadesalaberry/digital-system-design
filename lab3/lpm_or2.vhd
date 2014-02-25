-- OR gate that takes 26 inputs and returns 1 if all of them are 0.
--
-- entity name: g23_26_input_or_gate
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 25/02/2014


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY lpm_or2 IS
	PORT (
		data0x		: IN STD_LOGIC_VECTOR (25 DOWNTO 0);
		result		: OUT STD_LOGIC
	);
END lpm_or2;


ARCHITECTURE alpha OF lpm_or2 IS

BEGIN
	
	WITH data0x select
	result <=
		'0' when "00000000000000000000000000",
		'1' when others;

END alpha;