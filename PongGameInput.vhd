----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:55:35 12/10/2022 
-- Design Name: 
-- Module Name:    PongGameInput - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.ALL;
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PongGameInput is
    Port ( P1_L : in  STD_LOGIC;
           P1_R : in  STD_LOGIC;
           P1_L_OUT : out  STD_LOGIC;
           P1_R_OUT : out  STD_LOGIC;
			  P2_L : in  STD_LOGIC;
           P2_R : in  STD_LOGIC;
           P2_L_OUT : out  STD_LOGIC;
           P2_R_OUT : out  STD_LOGIC;
           ForceStop : out  STD_LOGIC;
           restart : in  STD_LOGIC;
           isGameStart : in  STD_LOGIC;
           inputScore1 : in STD_LOGIC_VECTOR (3 downto 0);
           inputScore2 : in STD_LOGIC_VECTOR (3 downto 0);
			  SEVENSEGMENT : out STD_LOGIC_VECTOR (6 downto 0);
			  SEVENSEGMENT_COMMON : out STD_LOGIC_VECTOR (3 downto 0);
			  SEVENSEGMENTTime : out STD_LOGIC_VECTOR (6 downto 0);
			  SEVENSEGMENT_COMMON_Time : out STD_LOGIC_VECTOR (1 downto 0);
			  CLK : in STD_LOGIC);
end PongGameInput;

architecture Behavioral of PongGameInput is

	signal clk25 : std_logic := '0';
	signal clkDiv50K : std_logic := '0';
	signal clkDiv10M : std_logic := '0';
	
	signal Stop : std_logic := '0';


	signal scoreP1 : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	signal scoreP2 : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	signal ten : STD_LOGIC_VECTOR (3 downto 0) := "1010";
	
	signal scoreDigit : STD_LOGIC_VECTOR (3 downto 0) := "0000";

	signal bcdDigit : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	
	signal commonSegment : STD_LOGIC_VECTOR (3 downto 0) := "1110";
	signal commonSegment2Digit : STD_LOGIC_VECTOR (1 downto 0) := "10";
	signal tempBCD: std_logic_vector(3 downto 0);
	signal timeleft : integer := 99;
	
	signal Sound_counter : integer := 0;
	signal clockCount : integer := 0;
	signal clockCount10M : integer := 0;
	
	
begin

	clkD50K:process(CLK)
	begin
		if(clk25'event and clk25 = '1') then
			clockCount <= clockCount + 1;
			if clockCount = 50000 then
				clkDiv50K <= NOT clkDiv50K;
				clockCount <= 1;
			end if;
		end if;
	end process;
	
	clkD20M:process(CLK)
	begin
		if(clk25'event and clk25 = '1') then
			clockCount10M <= clockCount10M + 1;
			if clockCount10M = 10000000 then
				clkDiv10M <= NOT clkDiv10M;
				clockCount10M <= 1;
			end if;
		end if;
	end process;

	clk_div:process(CLK)
	begin
		clk25 <= CLK;
	end process;
	
	scoreP1 <= inputScore1;
	scoreP2 <= inputScore2;
	
	gamePr:process
	begin
		if clk25'event and clk25 = '1' then
			ForceStop <= Stop; --send stop signal to main board
			
			if restart = '1' then
				timeleft <= 99;
				Stop <= '0';
			else
				if clkDiv10M'event and clkDiv10M = '1' then
					if timeleft > 0 and isGameStart = '1' and Stop = '0' then
						timeleft <= timeleft - 1;
					end if;
				end if;
				if timeleft <= 0 and isGameStart = '1' and Stop = '0' then
					Stop <= '1';
				end if;
				if isGameStart = '0' then
					Stop <= '0';
				end if;
			end if;
		end if;
	end process;
	
	BCDTO7SEGMENTCOV2Digit:process
	begin
		if clkDiv50K'event and clkDiv50K = '1' then
			
			if to_integer(unsigned(commonSegment2Digit)) = 2 then
				commonSegment2Digit <= "01";
				--bcdDigit <= "0001";
				bcdDigit <= std_logic_vector(to_unsigned(timeleft mod 10,tempBCD'length));
			else
				commonSegment2Digit <= "10";
				--bcdDigit <= "0000";
				bcdDigit <= std_logic_vector(to_unsigned(timeleft/10 mod 10,tempBCD'length));
			end if;
			
			SEVENSEGMENT_COMMON_Time <= commonSegment2Digit;
			
			case bcdDigit is
			when "0000" =>		
				SEVENSEGMENTTime <= "1111110";
			when "0001" =>
				SEVENSEGMENTTime <= "0110000";
			when "0010" =>
				SEVENSEGMENTTime <= "1101101";
			when "0011" =>
				SEVENSEGMENTTime <= "1111001";
			when "0100" =>
				SEVENSEGMENTTime <= "0110011";
			when "0101" =>
				SEVENSEGMENTTime <= "1011011";
			when "0110" =>
				SEVENSEGMENTTime <= "1011111";
			when "0111" =>
				SEVENSEGMENTTime <= "1110000";
			when "1000" =>
				SEVENSEGMENTTime <= "1111111";
			when "1001" =>
				SEVENSEGMENTTime <= "1111011";
			when others =>
				SEVENSEGMENTTime <= "1111111";
			end case;
			
		end if;
	end process;
	
	BCDTO7SEGMENTCOV:process
	begin
		if clkDiv50K'event and clkDiv50K = '1' then
			
			if to_integer(unsigned(commonSegment)) = 14 then
				commonSegment <= "1101";
				if to_integer(unsigned(scoreP1)) < 10 then
					scoreDigit <= "0000";
				else
					scoreDigit <= "0001";
				end if;
			elsif to_integer(unsigned(commonSegment)) = 13 then
				commonSegment <= "1011";
				if to_integer(unsigned(scoreP2)) < 10 then
					scoreDigit <= scoreP2;
				else
					scoreDigit <= std_logic_vector(unsigned(scoreP2) - unsigned(ten));
				end if;
			elsif to_integer(unsigned(commonSegment)) = 11 then
				commonSegment <= "0111";
				if to_integer(unsigned(scoreP2)) < 10 then
					scoreDigit <= "0000";
				else
					scoreDigit <= "0001";
				end if;
			else
				commonSegment <= "1110";
				if to_integer(unsigned(scoreP1)) < 10 then
					scoreDigit <= scoreP1;
				else
					scoreDigit <= std_logic_vector(unsigned(scoreP1) - unsigned(ten));
				end if;
			end if;
			
			SEVENSEGMENT_COMMON <= commonSegment;
			
			case scoreDigit is
			when "0000" =>
				SEVENSEGMENT <= "1111110";
			when "0001" =>
				SEVENSEGMENT <= "0110000";
			when "0010" =>
				SEVENSEGMENT <= "1101101";
			when "0011" =>
				SEVENSEGMENT <= "1111001";
			when "0100" =>
				SEVENSEGMENT <= "0110011";
			when "0101" =>
				SEVENSEGMENT <= "1011011";
			when "0110" =>
				SEVENSEGMENT <= "1011111";
			when "0111" =>
				SEVENSEGMENT <= "1110000";
			when "1000" =>
				SEVENSEGMENT <= "1111111";
			when "1001" =>
				SEVENSEGMENT <= "1111011";
			when others =>
				SEVENSEGMENT <= "1111111";
			end case;
			
		end if;
	end process;


	P1_L_OUT <= P1_L;
	P1_R_OUT <= P1_R;
	P2_L_OUT <= P2_L;
	P2_R_OUT <= P2_R;


end Behavioral;

