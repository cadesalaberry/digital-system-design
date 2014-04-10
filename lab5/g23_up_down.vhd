-- A Generic timer with a 40 bit natural number as input.
--
-- entity name: g23_up_down
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
-- Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
-- Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 27/02/2014


LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.STD_LOGIC_arith.all;

library lpm;
USE lpm.lpm_components.all;


ENTITY g23_up_down IS

	GENERIC (
		max : natural := 1
	);
	
	PORT (
		clock 	: in 	STD_LOGIC;
		enable 	: in 	STD_LOGIC;
		reset 	: in 	STD_LOGIC;
		
		up		: in	STD_LOGIC;
		down	: in	STD_LOGIC;
		
		pulse 	: out	STD_LOGIC
	);
	
end g23_up_down;


ARCHITECTURE alpha OF g23_up_down IS
	
	signal data		: STD_LOGIC_VECTOR(39 downto 0);
	signal q		: STD_LOGIC_VECTOR(39 downto 0);
	signal sload	: STD_LOGIC;
	signal done		: STD_LOGIC;
	
BEGIN

	data	<= CONV_STD_LOGIC_VECTOR(max,40);
	sload	<= reset OR done;
	done	<= '1' WHEN (q = "0000000000000000000000000000000000000000") ELSE '0';
	pulse	<= done;

	counter : lpm_counter
	GENERIC MAP (
		lpm_width		=> 40,
		lpm_direction	=> "down"
	)
	PORT MAP (
		data	=> data,
		sload	=> sload,
		clock	=> clock,
		cnt_en	=> enable,
		q		=> q
	);
	
END alpha;