---- generates the appropriate 7-segment display associated with the input code
--
-- entity name: g23_7_segment_decoder
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 13/02/2014

library ieee;					-- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		-- allows use of the unsigned type


entity g23_7_segment_decoder is
	port (
		code			: in	std_logic_vector(3 downto 0);
		RippleBlank_In	: in	std_logic;
		RippleBlank_Out	: out	std_logic;
		segments		: out	std_logic_vector(6 downto 0)
	);
end g23_7_segment_decoder;

architecture alpha of g23_7_segment_decoder is

	signal temp : std_logic_vector(7 downto 0);
	
begin

	RippleBlank_Out	<= temp(7);
	segments		<= temp(6 downto 0);

	with RippleBlank_In & code select
		temp <=
			"01000000" when "00000", -- '0'
			"01111001" when "00001", -- '1'
			"00100100" when "00010", -- '2'
			"00110000" when "00011", -- '3'
			"00011001" when "00100", -- '4'
			"00010010" when "00101", -- '5'
			"00000010" when "00110", -- '6'
			"01111000" when "00111", -- '7'
			"00000000" when "01000", -- '8'
			"00011000" when "01001", -- '9'
			
			"00001000" when "01010", -- 'A'
			"00000011" when "01011", -- 'b'
			"00100111" when "01100", -- 'C'
			"00100001" when "01101", -- 'd'
			"00000110" when "01110", -- 'E'
			"00001110" when "01111", -- 'F'
			
			"11111111" when "10000", -- ripple_blank out
			
			"01111001" when "10001", -- '1'
			"00100100" when "10010", -- '2'
			"00110000" when "10011", -- '3'
			"00011001" when "10100", -- '4'
			"00010010" when "10101", -- '5'
			"00000010" when "10110", -- '6'
			"01111000" when "10111", -- '7'
			"00000000" when "11000", -- '8'
			"00011000" when "11001", -- '9'
			
			"00001000" when "11010", -- 'A'
			"00000011" when "11011", -- 'b'
			"00100111" when "11100", -- 'C'
			"00100001" when "11101", -- 'd'
			"00000110" when "11110", -- 'E'
			"00001110" when "11111", -- 'F'
			
			"01011010" when others;

end alpha;