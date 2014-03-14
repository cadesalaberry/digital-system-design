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

LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY g23_timer_test_bed IS

	PORT ( 
		earth_5_led	: OUT STD_LOGIC_VECTOR(6 downto 0);
		earth_9_led	: OUT STD_LOGIC_VECTOR(6 downto 0);
		mars_5_led	: OUT STD_LOGIC_VECTOR(6 downto 0);
		mars_9_led	: OUT STD_LOGIC_VECTOR(6 downto 0);
		reset		: IN STD_LOGIC;
		clk			: IN STD_LOGIC
	);
	
END g23_timer_test_bed;


ARCHITECTURE alpha OF g23_timer_test_bed IS

	signal earth_clk	: STD_LOGIC;
	signal mars_clk		: STD_LOGIC;
	signal earth_tens	: STD_LOGIC_VECTOR(2 downto 0);
	signal earth_ones	: STD_LOGIC_VECTOR(3 downto 0);
	signal mars_tens	: STD_LOGIC_VECTOR(2 downto 0);
	signal mars_ones	: STD_LOGIC_VECTOR(3 downto 0);
	signal reset_inv	: STD_LOGIC;
	
	COMPONENT g23_7_segment_decoder
		PORT (
			code			: IN STD_LOGIC_VECTOR(3 downto 0);
			RippleBlank_In	: IN STD_LOGIC;
			RippleBlank_Out	: OUT STD_LOGIC;
			segments		: OUT STD_LOGIC_VECTOR(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT g23_count_to_59
		PORT (
			clk		: in	STD_LOGIC;
			enable	: in	STD_LOGIC;
			reset	: in	STD_LOGIC;
			sec_msd	: out STD_LOGIC_VECTOR(2 downto 0);
			sec_lsd	: out STD_LOGIC_VECTOR(3 downto 0)
		);
	END COMPONENT;
	
	COMPONENT g23_basic_timer
		PORT (
			clk		: in	STD_LOGIC;
			enable	: in	STD_LOGIC;
			reset	: in	STD_LOGIC;
			EPULSE	: out	STD_LOGIC;
			MPULSE	: out	STD_LOGIC
		);
	END COMPONENT;
BEGIN

	reset_inv	<= NOT reset;
	

	timer : g23_basic_timer
	PORT MAP (
		clk		=> clk,
		reset	=> reset_inv,
		enable	=> '1',
		EPULSE	=> earth_clk,
		MPULSE	=> mars_clk
	);
	
	earth_counter : g23_count_to_59
	PORT MAP (
		clk			=> earth_clk,
		enable		=> '1',
		reset		=> reset_inv,
		sec_msd		=> earth_tens,
		sec_lsd		=> earth_ones
	);
	
	mars_counter : g23_count_to_59
	PORT MAP (
		clk			=> mars_clk,
		enable		=> '1',
		reset		=> reset_inv,
		sec_msd		=> mars_tens,
		sec_lsd		=> mars_ones
	);
	
	earth_msd : g23_7_segment_decoder
	PORT MAP (
		code			=> '0' & earth_tens,
		RippleBlank_In	=> '1',
		segments		=> earth_5_led
	);
	
	earth_lsd : g23_7_segment_decoder
	PORT MAP (
		code			=> earth_ones,
		RippleBlank_In	=> '0',
		segments		=> earth_9_led
	);
	
	mars_tens_display : g23_7_segment_decoder
	PORT MAP (
		code			=> '0' & mars_tens,
		RippleBlank_In	=> '1',
		segments		=> mars_5_led
	);
	
	mars_ones_display : g23_7_segment_decoder
	PORT MAP (
		code			=> mars_ones,
		RippleBlank_In	=> '0',
		segments		=> mars_9_led
	);
		
END alpha;