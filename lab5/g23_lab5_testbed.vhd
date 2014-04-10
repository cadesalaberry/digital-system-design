-- A Year Month Day counter
--
-- entity name: g23_lab5_testbed
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 20/04/2014


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY g23_lab5_testbed IS

	PORT (
		clock 			: in 	STD_LOGIC; -- ASYNC, Should be connected to the master 50MHz clock.
		reset 			: in 	STD_LOGIC; -- ASYNC, When high the counts are all set to zero.
		enable			: in	STD_LOGIC;
		
		increment	 	: in 	STD_LOGIC; -- increase the current value
		decrement		: in	STD_LOGIC; -- decrease the current value
		
		dst_set			: in 	STD_LOGIC;
		sync_mars		: in	STD_LOGIC; 
		edit_mode		: in	STD_LOGIC;
		
		period_select	: in	STD_LOGIC_VECTOR(1 downto 0);
		mode			: in	STD_LOGIC_VECTOR(1 downto 0);
		mode2			: in	STD_LOGIC_VECTOR(1 downto 0);
		
		digit_3			: out	STD_LOGIC_VECTOR(6 downto 0);
		digit_2			: out	STD_LOGIC_VECTOR(6 downto 0);
		digit_1			: out	STD_LOGIC_VECTOR(6 downto 0);
		digit_0			: out	STD_LOGIC_VECTOR(6 downto 0);
		
		dst_out			: out	STD_LOGIC
	);
	
end g23_lab5_testbed;


ARCHITECTURE alpha OF g23_lab5_testbed IS
	
	COMPONENT g23_7_segment_decoder
		PORT (
			code			: in	std_logic_vector(3 downto 0);
			RippleBlank_In	: in	std_logic;
			RippleBlank_Out	: out	std_logic;
			segments		: out	std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT g23_YMD_counter
		PORT (
			clock 			: in 	STD_LOGIC; -- ASYNC, Should be connected to the master 50MHz clock.
			reset 			: in 	STD_LOGIC; -- ASYNC, When high the counts are all set to zero.
			count_enable 	: in 	STD_LOGIC; -- SYNC, A pulse with a width of 1 master clock cycle.
			load_enable 	: in 	STD_LOGIC; -- SYNC, if high sets count values to Y_Set, M_Set, and D_Set inputs

			y_inc			: in	STD_LOGIC;
			m_inc			: in	STD_LOGIC;
			d_inc			: in	STD_LOGIC;
			
			y_set			: in	STD_LOGIC_VECTOR(11 downto 0);
			m_set			: in	STD_LOGIC_VECTOR(3 downto 0);
			d_set			: in	STD_LOGIC_VECTOR(4 downto 0);
			
			years			: out	STD_LOGIC_VECTOR(11 downto 0);
			months			: out	STD_LOGIC_VECTOR(3 downto 0);
			days			: out	STD_LOGIC_VECTOR(4 downto 0)
		);
	END COMPONENT;
	
	COMPONENT g23_HMS_counter
		PORT ( 
			clk			: IN STD_LOGIC;
			reset		: IN STD_LOGIC;
			
			load_enable	: IN STD_LOGIC;
			count_enable: IN STD_LOGIC;
			
			h_set		: IN STD_LOGIC_VECTOR(4 downto 0);
			m_set		: IN STD_LOGIC_VECTOR(5 downto 0);
			s_set		: IN STD_LOGIC_VECTOR(5 downto 0);
			
			h_inc		: IN STD_LOGIC;
			m_inc		: IN STD_LOGIC;
			s_inc		: IN STD_LOGIC;
		
			hours		: OUT STD_LOGIC_VECTOR(4 downto 0);
			minutes		: OUT STD_LOGIC_VECTOR(5 downto 0);
			seconds		: OUT STD_LOGIC_VECTOR(5 downto 0);
			end_of_day	: OUT STD_LOGIC
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
	
	COMPONENT g23_UTC_to_MTC
		PORT (
			clock 			: in 	STD_LOGIC; -- ASYNC, Should be connected to the master 50MHz clock.
			reset 			: in 	STD_LOGIC; -- ASYNC, When high the counts are all set to zero.
			enable		 	: in 	STD_LOGIC; -- SYNC, A pulse with a width of 1 master clock cycle.

			-- Earth date input
			Year			: in	STD_LOGIC_VECTOR(11 downto 0);
			Month			: in	STD_LOGIC_VECTOR(3 downto 0);
			Day				: in	STD_LOGIC_VECTOR(4 downto 0);
			
			-- Earth time input
			Hour			: in	STD_LOGIC_VECTOR(4 downto 0);
			Minute			: in	STD_LOGIC_VECTOR(5 downto 0);
			Second			: in	STD_LOGIC_VECTOR(5 downto 0);
			
			-- MTC time on the prime meridian on Mars
			Mars_hours		: out	STD_LOGIC_VECTOR(4 downto 0);
			Mars_minutes	: out	STD_LOGIC_VECTOR(5 downto 0);
			Mars_seconds	: out	STD_LOGIC_VECTOR(5 downto 0);
			
			-- Debug
			Year_out		: out	STD_LOGIC_VECTOR(11 downto 0);
			Month_out		: out	STD_LOGIC_VECTOR(3 downto 0);
			Day_out			: out	STD_LOGIC_VECTOR(4 downto 0);
			
			Num_days		: out	STD_LOGIC_VECTOR(13 downto 0);
			Num_secs		: out	STD_LOGIC_VECTOR(16 downto 0);
			
			Date_is_reached	: out	STD_LOGIC
		);
  	END COMPONENT;
	
	signal RB_Out3	: STD_LOGIC;
  	signal RB_Out2	: STD_LOGIC;
  	signal RB_Out1	: STD_LOGIC;
  	
  	signal all_digits		: STD_LOGIC_VECTOR(15 downto 0);
  	
  	signal earth_time_sig	: STD_LOGIC_VECTOR(15 downto 0);
  	signal earth_date_sig	: STD_LOGIC_VECTOR(15 downto 0);
  	signal mars_time_sig	: STD_LOGIC_VECTOR(15 downto 0);
	signal time_zone_sig	: STD_LOGIC_VECTOR(15 downto 0);
	
	signal earth_hour_sig	: STD_LOGIC_VECTOR(4 downto 0);
	signal earth_min_sig	: STD_LOGIC_VECTOR(5 downto 0);
	signal earth_sec_sig	: STD_LOGIC_VECTOR(5 downto 0);
	
	signal earth_year_sig	: STD_LOGIC_VECTOR(11 downto 0);
	signal earth_month_sig	: STD_LOGIC_VECTOR(3 downto 0);
	signal earth_day_sig	: STD_LOGIC_VECTOR(4 downto 0);
	
	signal mars_hour_sig	: STD_LOGIC_VECTOR(4 downto 0);
	signal mars_min_sig		: STD_LOGIC_VECTOR(5 downto 0);
	signal mars_sec_sig		: STD_LOGIC_VECTOR(5 downto 0);
		
	signal earth_y_inc, earth_mo_inc, earth_d_inc : STD_LOGIC;
	signal earth_h_inc, earth_mi_inc, earth_s_inc : STD_LOGIC;
	
	signal mars_h_inc, mars_mi_inc, mars_s_inc : STD_LOGIC;
	signal mars_hour_set                : STD_LOGIC_VECTOR(4 downto 0);
	signal mars_min_set, mars_sec_set	: STD_LOGIC_VECTOR(5 downto 0);
	
	signal eod		: STD_LOGIC;
	
	signal epulse	: STD_LOGIC;
	signal mpulse	: STD_LOGIC;
	
	signal last_increment_state		: STD_LOGIC;
	signal inc_pulse			: STD_LOGIC;
	
BEGIN
	
	process(clock)
  	begin
		if(rising_edge(clock)) then
			if(inc_pulse = '1') then
				inc_pulse <= '0';
			end if;
			
			if(increment = '1' AND last_increment_state = '0') then
				inc_pulse <= '1';
			end if;
			
			last_increment_state <= increment;
		end if;
	end process;
	
	--mode
	with mode select
		all_digits <=
			earth_time_sig		 		when "00", -- earth time
			earth_date_sig			 	when "01", -- earth date
			mars_time_sig			 	when "10", -- mars time
			time_zone_sig			 	when "11"; -- time zone
			
	--mode 2: allows you to choose year,month,day for dates and hours,minutes,seconds for times and mars,earth for time zone
	with mode2 select
		earth_time_sig <=
			"00000000000" & earth_hour_sig		when "00",
			"0000000000" & earth_min_sig		when "01",
			"0000000000" & earth_sec_sig		when "10",
			"0000000000000000"		 			when "11";
	with mode2 select
		earth_date_sig <=
			"0000" & earth_year_sig				when "00",
			"000000000000" & earth_month_sig	when "01",
			"00000000000" & earth_day_sig		when "10",
			"0000000000000000"		 			when "11";
	with mode2 select
		mars_time_sig <=
			"00000000000" & mars_hour_sig		when "00",
			"0000000000" & mars_min_sig			when "01",
			"0000000000" & mars_sec_sig		 	when "10",
			"0000000000000000"		 			when "11";
	with mode2 select
		time_zone_sig <=
			"00000000000" & mars_hour_sig		when "00",
			"0000000000" & mars_min_sig			when "01",
			"0000000000" & mars_sec_sig		 	when "10",
			"0000000000000000"		 			when "11";
	
	
	--manually set day light savings time
	dst_out <= dst_set;
	
--	earth_hms_inc	<= '1' when (mode & inc_pulse)="001" else '0';
--	earth_ymd_inc	<= '1' when (mode & inc_pulse)="011" else '0';
--	mars_hms_inc	<= '1' when (mode & inc_pulse)="101" else '0';
	
	earth_y_inc     <= '1' when (inc_pulse & mode & mode2 = "10100") else '0';
	earth_mo_inc    <= '1' when (inc_pulse & mode & mode2 = "10101") else '0';
	earth_d_inc     <= '1' when (inc_pulse & mode & mode2 = "10110") else '0';
	
	earth_h_inc     <= '1' when (inc_pulse & mode & mode2 = "10000") else '0';
	earth_mi_inc    <= '1' when (inc_pulse & mode & mode2 = "10001") else '0';
	earth_s_inc     <= '1' when (inc_pulse & mode & mode2 = "10010") else '0';
	
	mars_h_inc      <= '1' when (inc_pulse & mode & mode2 = "11000") else '0';
	mars_mi_inc     <= '1' when (inc_pulse & mode & mode2 = "11001") else '0';
	mars_s_inc      <= '1' when (inc_pulse & mode & mode2 = "11010") else '0';
	
	

	--Earth YMD counter
	YMD_counter	: g23_YMD_counter
	PORT MAP (
		clock 			=> clock,
		reset 			=> reset,
		count_enable 	=> eod,
		load_enable		=> '0',

		y_inc			=> earth_y_inc,
		m_inc			=> earth_mo_inc,
		d_inc			=> earth_d_inc,
		
		y_set			=> "000000000000",
		m_set			=> "0000",
		d_set			=> "00000",
		
		years			=> earth_year_sig,
		months			=> earth_month_sig,
		days			=> earth_day_sig
	);
				
	-- Earth HMS counter
	earth_hms	: g23_HMS_counter
	PORT MAP (
		clk				=> clock,
		reset			=> reset,
		load_enable		=> '0',
		count_enable	=> epulse,
		
		h_inc			=> earth_h_inc,
		m_inc			=> earth_mi_inc,
		s_inc			=> earth_s_inc,
		
		h_set			=> "00000",
		m_set			=> "000000",
		s_set			=> "000000",
		
		hours			=> earth_hour_sig,
		minutes			=> earth_min_sig,
		seconds			=> earth_sec_sig,
		end_of_day		=> eod
	);

	
	-- Mars HMS counter
	mars_hms	: g23_HMS_counter
	PORT MAP (
		clk				=> clock,
		reset			=> reset,
		
		load_enable		=> sync_mars,
		count_enable	=> mpulse,
		
		h_set			=> mars_hour_set,
		m_set			=> mars_min_set,
		s_set			=> mars_sec_set,
		
		h_inc			=> mars_h_inc,
		m_inc			=> mars_mi_inc,
		s_inc			=> mars_s_inc,
		
		hours			=> mars_hour_sig,
		minutes			=> mars_min_sig,
		seconds			=> mars_sec_sig
	);

	
	-- Mars HMS counter
	utc_mtc	: g23_UTC_to_MTC
	PORT MAP (
		clock 			=> clock,
		reset 			=> reset,
		enable		 	=> enable,

		Year			=> earth_year_sig,
		Month			=> earth_month_sig,
		Day				=> earth_day_sig,
		
		Hour			=> earth_hour_sig,
		Minute			=> earth_min_sig,
		Second			=> earth_sec_sig,
		
		-- MTC time on the prime meridian on Mars
		Mars_hours		=> mars_hour_set,
		Mars_minutes	=> mars_min_set,
		Mars_seconds	=> mars_sec_set
	);
	
	basic_timer : g23_basic_timer
	PORT MAP (
		clk		=> clock,
		enable	=> enable,
		reset	=> reset,
		EPULSE	=> epulse,
		MPULSE	=> mpulse
  	);
	
	--LCD outputs
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
  	
END alpha;