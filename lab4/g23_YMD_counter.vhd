-- A Year Month Day counter
--
-- entity name: g23_YMD_counter
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 18/02/2014


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY g23_YMD_counter IS

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
	
end g23_YMD_counter;


ARCHITECTURE alpha OF g23_YMD_counter IS
		
		signal y			: integer range 0 to 4000;
		signal m			: integer range 1 to 12;
		signal d			: integer range 1 to 31;
		
		signal last_year	: STD_LOGIC;
		signal last_month	: STD_LOGIC;
		signal last_day		: STD_LOGIC;

		signal leap_year	: STD_LOGIC;
		
		signal mth_31d		: STD_LOGIC;
		signal mth_30d		: STD_LOGIC;
		signal mth_29d		: STD_LOGIC;
		signal mth_28d		: STD_LOGIC;
BEGIN
  	
  	years	<= STD_LOGIC_VECTOR(TO_UNSIGNED(y, 12));
  	months	<= STD_LOGIC_VECTOR(TO_UNSIGNED(m, 4));
  	days	<= STD_LOGIC_VECTOR(TO_UNSIGNED(d, 5));
  	
  	last_year	<= '1' WHEN y = 4000 else '0';
  	last_month	<= '1' WHEN m = 12 else '0';
  	
  	leap_year	<= '1' WHEN ((y mod 4) = 0 AND (y mod 100) /= 0 AND (y mod 400) = 0) else '0';

	mth_31d		<= '1' WHEN (m=1) OR (m=3) OR (m=5) OR (m=7) OR (m=8) OR (m=10) OR (m=12) else '0';
  	mth_30d		<= '1' WHEN (m=4) OR (m=6) OR (m=9) OR (m=11) else '0';
  	mth_29d		<= '1' WHEN (m=2) AND leap_year = '1' else '0';
  	mth_28d		<= '1' WHEN (m=2) AND leap_year = '0' else '0';

  	
  	-- The counters are copycats from slide 43 in the VHDL 3 pdf
  	-- counts from 1 to 31
  	day_counter : PROCESS(reset, clock) BEGIN
		
		IF reset ='1' THEN
			
			d <= 1;
			
		ELSIF clock = '1' AND clock'event THEN
			
			last_day <= '0';
			
			IF day_count_en = '1' THEN
			
				if load_enable = '1' THEN
					d <= TO_INTEGER(UNSIGNED(D_set));
				ELSE
					IF mth_31d = '1' AND d < 31 THEN
						d <= d + 1;
					ELSIF mth_30d = '1' AND d < 30 THEN
						d <= d + 1;
					ELSIF mth_29d = '1' AND d < 29 THEN
						d <= d + 1;
					ELSIF mth_28d = '1' AND d < 28 THEN
						d <= d + 1;
					ELSE
						-- RESET EVERYTHING
						d			<= 1;
						last_day	<= '1';
					END IF;
				END IF; --if load
				
			END IF; --if enable
			
		END IF; --if reset
		
  	END PROCESS day_counter;


  	-- counts from 1 to 12
	month_counter : PROCESS(reset, clock, last_day) BEGIN 
		
		IF reset ='1' THEN
			
			m <= 1;
			
		ELSIF clock = '1' AND clock'event THEN

			IF last_day = '1' THEN
			
				IF load_enable = '1' THEN
					m <= TO_INTEGER(UNSIGNED(M_set));
				ELSIF last_month = '0' THEN
					m <= m + 1;
				ELSE
					m <= 1;
					
				END IF; --if load
				
			END IF; --if enable
			
		END IF; --if reset
		
  	END PROCESS month_counter;
  

  	-- counts from 0 to 4000
  	year_counter : PROCESS(reset, clock, last_month, last_day) BEGIN 
 
		IF reset ='1' THEN
			
			y <= 0;
			
		ELSIF clock = '1' AND clock'event THEN
  	
			IF last_day = '1' AND last_month = '1' THEN
			
				IF load_enable = '1' THEN
					y <= TO_INTEGER(UNSIGNED(Y_set));
				ELSIF last_year = '1' THEN
					y <= 0;
				ELSE
					y <= y + 1;
				END IF; --if load
			
			END IF; --if enable
			
		END IF; --if reset
		
  	END PROCESS year_counter;
END alpha;