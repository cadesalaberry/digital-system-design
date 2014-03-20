-- this circuit converts a 6-bit binary number to a 2-digit BCD representation
--
-- entity name: g23_binary_to_BCD
--
-- Copyright (C) 2014 cadesalaberry, grahamludwinski
--
-- Version 1.0
--
-- Author:
--		Charles-Antoine de Salaberry; ca.desalaberry@mail.mcgill.ca,
--		Graham Ludwinski; graham.ludwinski@mail.mcgill.ca
--
-- Date: 11/02/2014

library ieee;					-- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		-- allows use of the unsigned type

library lpm;					-- allows use of the Altera library modules
use lpm.lpm_components.all;

entity g23_12_bit_to_BCD is
	port (
		clock	: in	std_logic;	-- to clock the lpm_rom register
		bin		: in	unsigned(11 downto 0);
		BCD		: out	std_logic_vector(15 downto 0)
	);
end g23_12_bit_to_BCD;

architecture look_up_table of g23_binary_to_BCD is
begin
	b2BCD_table : lpm_rom		-- use the altera rom library macrocell
	GENERIC MAP (
		lpm_widthad		=> 12,	-- sets the width of the ROM address bus
		lpm_numwords	=> 4096,	-- sets the words stored in the ROM
		lpm_outdata		=> "UNREGISTERED", -- no register on the output
		lpm_address_control => "REGISTERED", -- register on the input
		lpm_file		=> "g23_binary_to_BCD.mif", -- the ascii file containing the ROM data
		lpm_width		=> 16	-- the width of the word stored in each ROM location
	) 
	PORT MAP (
		inclock	=> clock,
		address	=> std_logic_vector(bin),
		q		=> BCD
	);
end look_up_table;

