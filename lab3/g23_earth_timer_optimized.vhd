-- Copyright (C) 1991-2010 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 9.1 Build 350 03/24/2010 Service Pack 2 SJ Full Version"
-- CREATED		"Tue Feb 25 14:44:05 2014"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY g23_earth_timer_optimized IS 
	PORT (
		clock 	: IN  STD_LOGIC;
		enable	: IN  STD_LOGIC;
		reset	: IN  STD_LOGIC;
		EarthSecond	: OUT  STD_LOGIC;
		MarsSecond	: OUT  STD_LOGIC;	
	);
END g23_earth_timer_optimized;

ARCHITECTURE bdf_type OF g23_earth_timer_optimized IS 

COMPONENT lpm_counter0
	PORT(
		sload	: IN STD_LOGIC;
		clock	: IN STD_LOGIC;
		cnt_en	: IN STD_LOGIC;
		data	: IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
	);
END COMPONENT;

COMPONENT lpm_or0
	PORT(data0 : IN STD_LOGIC;
		 data1 : IN STD_LOGIC;
		 result : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT lpm_constant0
	PORT(		 result : OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
	);
END COMPONENT;

COMPONENT lpm_or2
	PORT(
		data0x	: IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		result	: OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	sload :  STD_LOGIC;
SIGNAL	result :  STD_LOGIC;
SIGNAL	inverted_result :  STD_LOGIC;
SIGNAL	counter_out :  STD_LOGIC_VECTOR(25 DOWNTO 0);


BEGIN 
PULSE	<= result;
result	<= NOT(inverted_result);


earth_counter : lpm_counter0
PORT MAP(sload => sload,
		 clock => clock,
		 cnt_en => enable,
		 data => "00000000001100001101001111",
		 q => counter_out);
		 
mars_counter : lpm_counter0
PORT MAP(sload => sload,
		 clock => clock,
		 cnt_en => enable,
		 data => "00000000001100001101001111",
		 q => counter_out);
		 -- 10111110101111000001111111 is 49,999,999 in binary
		 -- 00000000001100001101001111 is 49,999 in binary


b2v_inst1 : lpm_or0
PORT MAP(data0 => result,
		 data1 => reset,
		 result => sload);


b2v_inst8 : lpm_or2
PORT MAP(data0x => counter_out,
		 result => inverted_result);


END bdf_type;