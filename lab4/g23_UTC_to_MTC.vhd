-- Converts an earth time and date into mars time of day.
--
-- entity name: g23_UTC_to_MTC
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 28/03/2014


library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

library lpm;
USE lpm.lpm_components.all;

entity g23_UTC_to_MTC is
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
		
		Num_days		: out	STD_LOGIC_VECTOR(15 downto 0);
		Num_secs		: out	STD_LOGIC_VECTOR(16 downto 0);
		
		Date_is_reached	: out	STD_LOGIC
	);
end g23_UTC_to_MTC;


architecture cascading of g23_UTC_to_MTC is
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
	
	COMPONENT g23_HMS_Counter
		PORT ( 
			h_set		: in STD_LOGIC_VECTOR(4 downto 0);
			m_set		: in STD_LOGIC_VECTOR(5 downto 0);
			s_set		: in STD_LOGIC_VECTOR(5 downto 0);
			load_enable	: in STD_LOGIC;
			count_enable: in STD_LOGIC;
			sec_clock	: in STD_LOGIC;
			reset		: in STD_LOGIC;
			clk			: in STD_LOGIC;
			hours		: out STD_LOGIC_VECTOR(4 downto 0);
			minutes		: out STD_LOGIC_VECTOR(5 downto 0);
			seconds		: out STD_LOGIC_VECTOR(5 downto 0);
			end_of_day	: out STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT g23_Seconds_to_Days
		port (
			seconds			: in	unsigned(16 downto 0);
			day_fraction	: out	unsigned(39 downto 0)
		);
	END COMPONENT;
	
	signal eod: STD_LOGIC;
	signal date_reached: STD_LOGIC;
	
	signal years_sig		: STD_LOGIC_VECTOR(11 downto 0);
	signal months_sig		: STD_LOGIC_VECTOR(3 downto 0);
	signal days_sig			: STD_LOGIC_VECTOR(4 downto 0);
	signal hours_sig		: STD_LOGIC_VECTOR(4 downto 0);
	signal minutes_sig		: STD_LOGIC_VECTOR(5 downto 0);
	signal seconds_sig		: STD_LOGIC_VECTOR(5 downto 0);
	
	signal Ndays			: STD_LOGIC_VECTOR(15 downto 0);
	signal Nsecs			: STD_LOGIC_VECTOR(16 downto 0);
	
	signal day_end			: STD_LOGIC;
	signal circuit_start	: STD_LOGIC;
	
	signal day_frac			: UNSIGNED(39 downto 0);
	signal JD				: UNSIGNED(55 downto 0);
	signal JD2000			: UNSIGNED(55 downto 0);
	signal MTC				: UNSIGNED(55 downto 0);

BEGIN
	Date_is_reached <= date_reached;
	
	Num_days <= Ndays;
	Num_secs <= Nsecs;
	
	Year_out 		<= years_sig;
	Month_out		<= months_sig;
	Day_out			<= days_sig;
	
	date_reached <= '1' WHEN
		(Year <= years_sig) AND (Month <= months_sig) AND (Day <= days_sig)
	AND (Hour <= hours_sig) AND (Minute <= minutes_sig) AND (Second <= seconds_sig)
	ELSE '0';
	
	circuit_start <= '1' WHEN
		Nsecs = "00000000000000000" AND Ndays = "0000000000000000"
	ELSE '0';
	
	JD2000 <= UNSIGNED(Ndays & STD_LOGIC_VECTOR(day_frac));
	--JD <= UNSIGNED(JD2000) - UNSIGNED("10101111110010000000");
	--MTC <= 24 * JD;
	
	YMD_counter	: g23_YMD_counter
	PORT MAP (
		clock 			=> clock,
		reset 			=> reset,
		day_count_en 	=> enable AND eod AND (NOT date_reached),
		load_enable 	=> reset OR circuit_start,

		Y_set			=> "011111010000",
		M_set			=> "0001",
		D_set			=> "00110",
		
		years			=> years_sig,
		months			=> months_sig,
		days			=> days_sig
	);
			
	HMS_counter : g23_HMS_Counter
	PORT MAP (
		clk 			=> clock,
		reset 			=> reset,
		count_enable 	=> enable AND NOT date_reached,
		load_enable 	=> reset OR circuit_start,
		sec_clock		=> clock AND NOT date_reached,
		
		h_set			=> (others => '0'),
		m_set			=> (others => '0'),
		s_set			=> (others => '0'),
		
		hours			=> hours_sig,
		minutes			=> minutes_sig,
		seconds			=> seconds_sig,
		end_of_day		=> eod
	);
	
	secs_counter : lpm_counter
	GENERIC MAP (
		lpm_width		=> 17,
		lpm_direction	=> "up"
	)
	PORT MAP (
		data	=> (others => '0'),
		sload	=> reset OR eod,
		clock	=> clock,
		cnt_en	=> enable AND NOT date_reached,
		q		=> Nsecs
	);
	
	days_counter : lpm_counter
	GENERIC MAP (
		lpm_width		=> 16,
		lpm_direction	=> "up"
	)
	PORT MAP (
		data	=> (others => '0'),
		sload	=> reset,
		clock	=> clock,
		cnt_en	=> eod AND NOT date_reached,
		q		=> Ndays
	);
	
	seconds_to_days : g23_Seconds_to_Days
	PORT MAP (
		seconds			=> UNSIGNED(Nsecs),
		day_fraction	=> day_frac
	);

end cascading;
