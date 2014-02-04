-- This circuit computes the number of seconds since midnight given
-- the current time in Hours (using a 24-hour notation), Minutes, and Seconds
--
-- entity name: g23_dayseconds
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 04/02/2014

library ieee;
use ieee.std_logic_1164.all; -- allows use of the std_logic_vector type
use IEEE.numeric_std.all; -- allows use of the unsigned type

library lpm;
use lpm.lpm_components.all; -- allows use of the Altera library modules


entity g23_dayseconds is
	port (
		Hours		: in	unsigned(4 downto 0);
		Minutes		: in	unsigned(5 downto 0);
		Seconds		: in	unsigned(5 downto 0);
		DaySeconds	: out	unsigned(16 downto 0)
	);
end g23_dayseconds;


architecture cascading of g23_dayseconds is

	signal HoursMinutes		: STD_LOGIC_VECTOR(10 downto 0);
	signal TotalMinutes		: STD_LOGIC_VECTOR(11 downto 0);
	signal MinutSeconds		: STD_LOGIC_VECTOR(16 downto 0);
	signal TotalSeconds		: STD_LOGIC_VECTOR(16 downto 0);

begin
	-- HoursMinutes <= Hours * 60;
	lpm_mult_component : lpm_mult
	GENERIC MAP (
		lpm_hint => "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 5,
		lpm_widthb => 6,
		lpm_widthp => 11
	)
	PORT MAP (
		dataa => STD_LOGIC_VECTOR(Hours),
		datab => "111100",
		result => HoursMinutes
	);
	
	
	-- TotalMinutes <= HoursMinutes + Minutes;
	lpm_add_sub_component : lpm_add_sub
	GENERIC MAP (
		lpm_direction => "ADD",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 11
	)
	PORT MAP (
		dataa => HoursMinutes,
		datab => STD_LOGIC_VECTOR(Minutes),
		result => TotalMinutes
	);
	
	-- MinutSeconds <= TotalMinutes * 60;
	lpm_mult_component : lpm_mult
	GENERIC MAP (
		lpm_hint => "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 11,
		lpm_widthb => 6,
		lpm_widthp => 17
	)
	PORT MAP (
		dataa => TotalMinutes,
		datab => "111100",
		result => MinutSeconds
	);
	
	
	-- DaySeconds <= TotalSeconds + Seconds;
	lpm_add_sub_component : lpm_add_sub
	GENERIC MAP (
		lpm_direction => "ADD",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 17
	)
	PORT MAP (
		dataa => TotalSeconds,
		datab => STD_LOGIC_VECTOR(Seconds),
		result => DaySeconds
	);

end cascading;
