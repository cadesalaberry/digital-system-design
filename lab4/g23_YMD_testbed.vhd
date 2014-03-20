-- A Year Month Day counter
--
-- entity name: g23_YMD_testbed
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 20/03/2014


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY g23_YMD_testbed IS

	PORT (
		clock 			: in 	STD_LOGIC; -- ASYNC, Should be connected to the master 50MHz clock.
		reset 			: in 	STD_LOGIC; -- ASYNC, When high the counts are all set to zero.
		enable			: in	STD_LOGIC; 
		day_count_en 	: in 	STD_LOGIC; -- SYNC, A pulse with a width of 1 master clock cycle.
		load_enable 	: in 	STD_LOGIC; -- SYNC, if high sets count values to Y_Set, M_Set, and D_Set inputs

		Y_set			: in	STD_LOGIC_VECTOR(11 downto 0);
		M_set			: in	STD_LOGIC_VECTOR(3 downto 0);
		D_set			: in	STD_LOGIC_VECTOR(4 downto 0);
		
		years			: out	STD_LOGIC_VECTOR(11 downto 0);
		months			: out	STD_LOGIC_VECTOR(3 downto 0);
		days			: out	STD_LOGIC_VECTOR(4 downto 0)
	);
	
end g23_YMD_testbed;


ARCHITECTURE alpha OF g23_YMD_testbed IS
  	
  	signal EPULSE	: STD_LOGIC;
  	signal y		: integer range 0 to 4000;
  	signal y_3		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_2		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_1		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_0		: STD_LOGIC_VECTOR(3 downto 0);
  	
	COMPONENT g23_YMD_counter
		PORT (
			clock 			: in 	STD_LOGIC; -- ASYNC, Should be connected to the master 50MHz clock.
			reset 			: in 	STD_LOGIC; -- ASYNC, When high the counts are all set to zero.
			day_count_en 	: in 	STD_LOGIC; -- SYNC, A pulse with a width of 1 master clock cycle.
			load_enable 	: in 	STD_LOGIC; -- SYNC, if high sets count values to Y_Set, M_Set, and D_Set inputs

			Y_set			: in	STD_LOGIC_VECTOR(11 downto 0);
			M_set			: in	STD_LOGIC_VECTOR(3 downto 0);
			D_set			: in	STD_LOGIC_VECTOR(4 downto 0);
			
			years			: out	STD_LOGIC_VECTOR(11 downto 0);
			months			: out	STD_LOGIC_VECTOR(3 downto 0);
			days			: out	STD_LOGIC_VECTOR(4 downto 0)
		);
	END COMPONENT;
	
	COMPONENT basic_timer
		PORT (
			clk		: in	STD_LOGIC;
			enable	: in	STD_LOGIC;
			reset	: in	STD_LOGIC;
			EPULSE	: out	STD_LOGIC;
			MPULSE	: out	STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT 7_segment_decoder
		PORT (
			code			: in	std_logic_vector(3 downto 0);
			RippleBlank_In	: in	std_logic;
			RippleBlank_Out	: out	std_logic;
			segments		: out	std_logic_vector(6 downto 0)
		);
	END COMPONENT;
		
BEGIN
	y <= TO_INTEGER(UNSIGNED(years));
	y_3	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y/1000, 4));
	y_2_temp <= y/100 - y_3*10;
	y_2	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y_2_temp, 4));
	y_1_temp <= y/10 - y_3*10 - y_2*100;
	y_1	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y/10, 4));
	y_0_temp <= y/100 - y_3*10 - y_2*100 - y_1*1000;
	y_0	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y, 4));
	
  	digit_3 : 7_segment_decoder
  	PORT MAP (
		code			=> ,
		RippleBlank_In	=> ,
		RippleBlank_Out	=> ,
		segments		=> 
  	);
  	
  	digit_2 : 7_segment_decoder
  	PORT MAP (
		code			=> ,
		RippleBlank_In	=> ,
		RippleBlank_Out	=> ,
		segments		=> 
  	);
  	
  	digit_1 : 7_segment_decoder
  	PORT MAP (
		code			=> ,
		RippleBlank_In	=> ,
		RippleBlank_Out	=> ,
		segments		=> 
  	);
  	
  	digit_0 : 7_segment_decoder
  	PORT MAP (
		code			=> ,
		RippleBlank_In	=> ,
		RippleBlank_Out	=> ,
		segments		=> 
  	);
  	
  	timer : basic_timer
  	PORT MAP (
		clk		=> clock,
		enable	=> enable,
		reset	=> reset,
		EPULSE	=> EPULSE
	);
  	
  	YMD_counter	: g23_YMD_counter
	PORT MAP (
		clock 			=> clock,
		reset 			=> reset,
		day_count_en 	=> EPULSE,
		load_enable 	=> load_enable,

		Y_set			=> Y_set,
		M_set			=> M_set,
		D_set			=> D_set,
		
		years			=> years,
		months			=> months,
		days			=> days
	);
	
	port (
		code			: in	std_logic_vector(3 downto 0);
		RippleBlank_In	: in	std_logic;
		RippleBlank_Out	: out	std_logic;
		segments		: out	std_logic_vector(6 downto 0)
	);
  	
END alpha;