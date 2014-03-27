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
		load_enable 	: in 	STD_LOGIC; -- SYNC, if high sets count values to Y_Set, M_Set, and D_Set inputs
		load_data		: in	STD_LOGIC_VECTOR(5 downto 0);
		
		period_select	: in	STD_LOGIC_VECTOR(1 downto 0);
		
		EPULSE			: out 	STD_LOGIC;
		
		years			: out	STD_LOGIC_VECTOR(11 downto 0);
		months			: out	STD_LOGIC_VECTOR(3 downto 0);
		days			: out	STD_LOGIC_VECTOR(4 downto 0);
		
		digit_3			: out	STD_LOGIC_VECTOR(6 downto 0);
		digit_2			: out	STD_LOGIC_VECTOR(6 downto 0);
		digit_1			: out	STD_LOGIC_VECTOR(6 downto 0);
		digit_0			: out	STD_LOGIC_VECTOR(6 downto 0)
	);
	
end g23_YMD_testbed;


ARCHITECTURE alpha OF g23_YMD_testbed IS
  	signal years_sig	: STD_LOGIC_VECTOR(11 downto 0);
	signal months_sig	: STD_LOGIC_VECTOR(3 downto 0);
	signal days_sig		: STD_LOGIC_VECTOR(4 downto 0);
  	
  	signal Y_set		: STD_LOGIC_VECTOR(11 downto 0);
	signal M_set		: STD_LOGIC_VECTOR(3 downto 0);
	signal D_set		: STD_LOGIC_VECTOR(4 downto 0);
  	
  	signal pulse	: STD_LOGIC;
  	signal RB_Out3	: STD_LOGIC;
  	signal RB_Out2	: STD_LOGIC;
  	signal RB_Out1	: STD_LOGIC;
  	signal y		: integer range 0 to 4000;
  	signal y_2_temp	: integer range 0 to 4000;
  	signal y_1_temp	: integer range 0 to 4000;
  	signal y_0_temp	: integer range 0 to 4000;
  	signal y_3		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_2		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_1		: STD_LOGIC_VECTOR(3 downto 0);
  	signal y_0		: STD_LOGIC_VECTOR(3 downto 0);
  	
  	signal d_1		: STD_LOGIC_VECTOR(3 downto 0);
  	signal d_0		: STD_LOGIC_VECTOR(3 downto 0);
  	
  	signal all_digits		: STD_LOGIC_VECTOR(15 downto 0);
  	signal year_digits		: STD_LOGIC_VECTOR(15 downto 0);
  	signal year_upper		: STD_LOGIC_VECTOR(7 downto 0);
  	signal year_lower		: STD_LOGIC_VECTOR(7 downto 0);
  	
  	signal month_digits		: STD_LOGIC_VECTOR(15 downto 0);
  	signal month_upper		: STD_LOGIC_VECTOR(7 downto 0);
  	signal month_lower		: STD_LOGIC_VECTOR(7 downto 0);

  	signal day_digits		: STD_LOGIC_VECTOR(15 downto 0);
  	signal day_upper		: STD_LOGIC_VECTOR(7 downto 0);
  	signal day_lower		: STD_LOGIC_VECTOR(7 downto 0);

	
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
	
	COMPONENT g23_basic_timer
		PORT (
			clk		: in	STD_LOGIC;
			enable	: in	STD_LOGIC;
			reset	: in	STD_LOGIC;
			EPULSE	: out	STD_LOGIC;
			MPULSE	: out	STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT g23_7_segment_decoder
		PORT (
			code			: in	std_logic_vector(3 downto 0);
			RippleBlank_In	: in	std_logic;
			RippleBlank_Out	: out	std_logic;
			segments		: out	std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT g23_binary_to_BCD
		PORT (
			clock	: in	std_logic;	-- to clock the lpm_rom register
			bin		: in	unsigned(5 downto 0);
			BCD		: out	std_logic_vector(7 downto 0)
		);
  	END COMPONENT;
		
BEGIN
	EPULSE <= pulse;
	years <= years_sig;
	months <= months_sig;
	days <= days_sig;
	
	y <= TO_INTEGER(UNSIGNED(years_sig));
	y_3	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y/1000, 4));
	y_2_temp <= (y - TO_INTEGER(UNSIGNED(y_3))*1000)/100;
	y_2	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y_2_temp, 4));
	y_1_temp <= (y - TO_INTEGER(UNSIGNED(y_3))*1000 - TO_INTEGER(UNSIGNED(y_2))*100)/10;
	y_1	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y_1_temp, 4));
	y_0_temp <= (y - TO_INTEGER(UNSIGNED(y_3))*1000 - TO_INTEGER(UNSIGNED(y_2))*100 - TO_INTEGER(UNSIGNED(y_1))*10);
	y_0	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y_0_temp, 4));
	
	with period_select select
		all_digits <=
			"00000000" & day_lower 		when "00", -- day select
			"00000000" & month_lower 	when "01", -- month select
			y_3 & y_2 & y_1 & y_0	 	when "10", -- year lower select
			y_3 & y_2 & y_1 & y_0 		when "11"; -- year upper select
	
	with period_select select
		Y_Set <=
			years_sig							when "00", -- day select
			years_sig							when "01", -- month select
			years_sig(11 downto 6) & load_data	when "10", -- year lower select
			load_data & years_sig(5 downto 0)	when "11"; -- year upper select
			
	with period_select select
		M_Set <=
			months_sig					when "00", -- day select
			load_data(3 downto 0)		when "01", -- month select
			months_sig					when "10", -- year lower select
			months_sig					when "11"; -- year upper select
			
	with period_select select
		D_Set <=
			load_data(4 downto 0)		when "00", -- day select
			days_sig					when "01", -- month select
			days_sig					when "10", -- year lower select
			days_sig					when "11"; -- year upper select
			
		
	year_upper_BCD : g23_binary_to_BCD
	PORT MAP (
		clock			=> clock,
		bin				=> UNSIGNED(years_sig(11 downto 6)),
		BCD				=> year_upper
 	);
 	
 	year_lower_BCD : g23_binary_to_BCD
	PORT MAP (
		clock			=> clock,
		bin				=> UNSIGNED(years_sig(5 downto 0)),
		BCD				=> year_lower
 	);
	
	month_BCD : g23_binary_to_BCD
	PORT MAP (
		clock			=> clock,
		bin				=> UNSIGNED("00" & months_sig),
		BCD				=> month_lower
 	);
 	
	day_BCD : g23_binary_to_BCD
	PORT MAP (
		clock			=> clock,
		bin				=> UNSIGNED("0" & days_sig),
		BCD				=> day_lower
 	);
  	
  	decode_3 : g23_7_segment_decoder
  	PORT MAP (
		code			=> all_digits(15 downto 12),
		RippleBlank_In	=> '1',
		RippleBlank_Out	=> RB_Out3,
		segments		=> digit_3
  	);
  	
  	decode_2 : g23_7_segment_decoder
  	PORT MAP (
		code			=> all_digits(11 downto 8),
		RippleBlank_In	=> RB_Out3,
		RippleBlank_Out	=> RB_Out2,
		segments		=> digit_2
  	);
  	
  	decode_1 : g23_7_segment_decoder
  	PORT MAP (
		code			=> all_digits(7 downto 4),
		RippleBlank_In	=> RB_Out2,
		RippleBlank_Out	=> RB_Out1,
		segments		=> digit_1
  	);
  	
  	decode_0 : g23_7_segment_decoder
  	PORT MAP (
		code			=> all_digits(3 downto 0),
		RippleBlank_In	=> RB_Out1,
		segments		=> digit_0
  	);
  	
  	timer : g23_basic_timer
  	PORT MAP (
		clk		=> clock,
		enable	=> enable,
		reset	=> reset,
		EPULSE	=> pulse
	);
  	
  	YMD_counter	: g23_YMD_counter
	PORT MAP (
		clock 			=> clock,
		reset 			=> reset,
		day_count_en 	=> pulse,
		load_enable 	=> load_enable,

		Y_set			=> Y_set,
		M_set			=> M_set,
		D_set			=> D_set,
		
		years			=> years_sig,
		months			=> months_sig,
		days			=> days_sig
	);
  	
END alpha;