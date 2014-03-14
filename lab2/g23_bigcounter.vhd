-- A simple 0-59 up counter.
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

LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY g23_count_to_59 IS

	PORT (
		clk		: in	STD_LOGIC;
		enable	: in	STD_LOGIC;
		reset	: in	STD_LOGIC;
		sec_msd	: out STD_LOGIC_VECTOR(2 downto 0);
		sec_lsd	: out STD_LOGIC_VECTOR(3 downto 0)
	);
	
END g23_count_to_59;


ARCHITECTURE alpha OF g23_count_to_59 IS

	signal decade_reached	: STD_LOGIC;
	signal seconds_msd		: STD_LOGIC_VECTOR (2 downto 0);
	signal seconds_lsd		: STD_LOGIC_VECTOR (3 downto 0);

BEGIN

	decade_reached	<= '1' when (seconds_lsd = "1001") else '0';
	sec_msd			<= seconds_msd;
	sec_lsd			<= seconds_lsd;

	count_to_9 : lpm_counter
	GENERIC MAP (
		lpm_modulus	=> 10,
		lpm_width	=> 4
	)
	PORT MAP (
		clock	=> clk,
		aclr	=> reset,
		q		=> seconds_lsd
	);
	
	count_to_5 : lpm_counter
	GENERIC MAP(
		lpm_modulus	=> 6,
		lpm_width	=> 3
	)
	PORT MAP(
		cnt_en	=> decade_reached,
		clock	=> clk,
		aclr	=> reset,
		q		=> seconds_msd
	);
		
END alpha;

