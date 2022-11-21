----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:00:57 11/22/2022 
-- Design Name: 
-- Module Name:    player_1 - Behavioral 
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity player_1 is
    Port ( Button_L : in STD_LOGIC;
	        CLK : in STD_LOGIC;
           Button_R : in  STD_LOGIC;
			  LED_L : out STD_LOGIC;
			  LED_R : out STD_LOGIC;
			  Pad_X1 : out STD_LOGIC_VECTOR (5 downto 0);
			  Pad_X2 : out STD_LOGIC_VECTOR (5 downto 0));
end player_1;

architecture Behavioral of player_1 is

    signal P_X1 : unsigned(5 downto 0) := "000000";   -- Leftmost X-position of the paddle
    signal P_X2 : unsigned(5 downto 0) := "000100";   -- Rightmost X-position of the paddle
	 
begin

next_paddle:process(CLK,Button_L,Button_R)
begin
  if(rising_edge(CLK)) then
    if((Button_L = '1') and (Button_R = '0')) then
		LED_L <= '1';
		LED_R <= '0';
	   if(P_X1  = "00000") then
			P_X1 <= P_X1;
			P_X2 <= P_X2;
		else
			P_X1 <= P_X1 - 1;
			P_X2 <= P_X2 - 1;
		end if;
	elsif ((Button_L = '0') and (Button_R = '1')) then
		LED_L <= '0';
		LED_R <= '1';
		if (P_X2 = "100111") then
			P_X1 <= P_X1;
			P_X2 <= P_X2;
		else
			P_X1 <= P_X1 + 1;
			P_X2 <= P_X2 + 1;
		end if;
	else
		P_X1 <= P_X1;
		P_X2 <= P_X2;
	end if;
  end if;
end process;
	
	Pad_X1 <= std_logic_vector(P_X1);
	Pad_X2 <= std_logic_vector(P_X2);


end Behavioral;

