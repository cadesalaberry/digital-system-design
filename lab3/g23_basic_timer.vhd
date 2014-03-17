-- A Mars and Earth timer calibrated for a 50MHz clock.
--
-- entity name: g23_mars_timer
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
-- Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
-- Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 13/03/2014


LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY g23_basic_timer IS

	PORT (
		clk		: in	STD_LOGIC;
		enable	: in	STD_LOGIC;
		reset	: in	STD_LOGIC;
		EPULSE	: out	STD_LOGIC;
		MPULSE	: out	STD_LOGIC
	);
	
END g23_basic_timer;


ARCHITECTURE alpha OF g23_basic_timer IS

	COMPONENT g23_generic_timer
		GENERIC (max : natural := 0);
		PORT (
			clk		: in	STD_LOGIC;
			enable	: in	STD_LOGIC;
			reset	: in	STD_LOGIC;
			pulse	: out	STD_LOGIC
		);
	END COMPONENT;
	
BEGIN

	earth	: g23_generic_timer
--	GENERIC MAP (max => 49999999)
--	GENERIC MAP (max => 1000)
	GENERIC MAP (max => 100)
	PORT MAP (
		clk => clk,
		enable => enable,
		reset => reset,
		pulse => EPULSE
	);
	
	mars	: g23_generic_timer
--	GENERIC MAP (max => 51374562)
--	GENERIC MAP (max => 1027)
	GENERIC MAP (max => 102)
	PORT MAP (
		clk => clk,
		enable => enable,
		reset => reset,
		pulse => MPULSE
	);
	
END alpha;

