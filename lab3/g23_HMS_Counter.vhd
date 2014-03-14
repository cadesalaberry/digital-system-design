-- A timer test-bed circuit.
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
USE ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY g23_HMS_counter IS

	PORT ( 
		h_set		: IN STD_LOGIC_VECTOR(4 downto 0);
		m_set		: IN STD_LOGIC_VECTOR(5 downto 0);
		s_set		: IN STD_LOGIC_VECTOR(5 downto 0);
		load_enable	: IN STD_LOGIC;
		count_enable: IN STD_LOGIC;
		sec_clock	: IN STD_LOGIC;
		reset		: IN STD_LOGIC;
		clk			: IN STD_LOGIC;
		hours		: OUT STD_LOGIC_VECTOR(4 downto 0);
		minutes		: OUT STD_LOGIC_VECTOR(5 downto 0);
		seconds		: OUT STD_LOGIC_VECTOR(5 downto 0);
		end_of_day	: OUT STD_LOGIC
	);
	
END g23_HMS_counter;


ARCHITECTURE alpha OF g23_HMS_counter IS

	signal h		: STD_LOGIC_VECTOR(4 downto 0);
	signal m		: STD_LOGIC_VECTOR(5 downto 0);
	signal s		: STD_LOGIC_VECTOR(5 downto 0);

	signal h_maxed	: STD_LOGIC;
	signal m_maxed	: STD_LOGIC;	
	signal s_maxed	: STD_LOGIC;
	
	signal earth_clk	: STD_LOGIC;
	signal reset_inv	: STD_LOGIC;
	
	COMPONENT g23_earth_timer
		PORT (
			clk		: in	STD_LOGIC;
			enable	: in	STD_LOGIC;
			reset	: in	STD_LOGIC;
			pulse	: out	STD_LOGIC
		);
	END COMPONENT;

BEGIN

	reset_inv	<= NOT reset;
	end_of_day	<= h_maxed;
	
	hours <= h;
	minutes <= m;
	seconds <= s;
	
	h_maxed 	<= '1' WHEN (h = "01011") ELSE '0'; 
	m_maxed 	<= '1' WHEN (m = "111011") ELSE '0';
	s_maxed 	<= '1' WHEN (s = "111011") ELSE '0';
	
	seconds_counter : lpm_counter
	GENERIC MAP (
		lpm_direction => "UP",
		lpm_modulus => 60,
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 6
	)
	PORT MAP (
		aload => load_enable,
		aclr => reset_inv,
		clock => clk,
		data => s_set,
		cnt_en => sec_clock,
		q => s
	);
	
	minutes_counter : lpm_counter
	GENERIC MAP (
		lpm_direction => "UP",
		lpm_modulus => 60,
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 6
	)
	PORT MAP (
		aload => load_enable,
		aclr => reset_inv,
		clock => clk,
		data => m_set,
		cnt_en => sec_clock AND s_maxed,
		q => m
	);
	
	hours_counter : lpm_counter
	GENERIC MAP (
		lpm_direction => "UP",
		lpm_modulus => 24,
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 5
	)
	PORT MAP (
		aload => load_enable,
		aclr => reset_inv,
		clock => clk,
		data => h_set,
		cnt_en => sec_clock AND m_maxed AND s_maxed,
		q => h
	);
	
	

		
END alpha;