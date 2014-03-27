------- binary to bcd converter
------- Uses the ADD-3 (or Double-Dabble) algorithm
------- 12 bit std_logic_vector in, 16 bit std_logic_vector out (4 BCD digits)
------- USAGE:   BCD <= to_bcd(BIN);
-------
------- include this text at the beginning of the architecture body, after the signal declarations
-------
------- (adapted from an 8-bit design from http://vhdlguru.blogspot.ca/2010/04/8-bit-binary-to-bcd-converter-double.html)
-------
--
function to_bcd ( bin : std_logic_vector((11) downto 0) ) return std_logic_vector is

variable i : integer:=0;
variable j : integer:=1;
variable bcd : std_logic_vector((15) downto 0) := (others => '0');
variable bint : std_logic_vector((11) downto 0) := bin;

begin
for i in 0 to 11 loop -- repeating 12 times.
bcd((15) downto 1) := bcd((14) downto 0); --shifting the bits.
bcd(0) := bint(11);
bint((11) downto 1) := bint((10) downto 0);
bint(0) :='0';

l1: for j in 1 to 4 loop
if(i < 11 and bcd(((4*j)-1) downto ((4*j)-4)) > "0100") then --add 3 if BCD digit is greater than 4.
bcd(((4*j)-1) downto ((4*j)-4)) := std_logic_vector(unsigned(bcd(((4*j)-1) downto ((4*j)-4))) + "0011");

end if;

end loop l1;
end loop;
return bcd;
end to_bcd; 