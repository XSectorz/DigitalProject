----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:17:27 12/28/2016 
-- Design Name: 
-- Module Name:    vga_driver - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_driver is
  Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           HSYNC : out  STD_LOGIC;
           VSYNC : out  STD_LOGIC;
			  Player1_Button_L : in STD_LOGIC;
			  Player1_Button_R : in STD_LOGIC;
			  BUZZER : out STD_LOGIC;
			  LED_L : out STD_LOGIC;
			  LED_R : out STD_LOGIC;
			  LED_TEST : out STD_LOGIC;
			  LED_TEST2 : out STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (7 downto 0));	  
end vga_driver;

architecture Behavioral of vga_driver is
		
	signal clk25 : std_logic := '0';
	
	constant HD : integer := 449;  --  639   Horizontal Display (640)
	constant HFP : integer := 20;         --   16   Right border (front porch)
	constant HSP : integer := 64;       --   96   Sync pulse (Retrace)
	constant HBP : integer := 44;        --   48   Left boarder (back porch)
	
	constant VD : integer := 479;   --  479   Vertical Display (480)
	constant VFP : integer := 10;       	 --   10   Right border (front porch)
	constant VSP : integer := 2;				 --    2   Sync pulse (Retrace)
	constant VBP : integer := 33;       --   33   Left boarder (back porch)
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
	signal P1_X1 : integer := 20; -- left border player 1
	
	signal P1_Move_counter : integer := 0;
	constant P1_Move_counter_delay : integer := 100000;
	
	signal videoOn : std_logic := '1';

begin

	clk_div:process(CLK)
	begin
		clk25 <= CLK;
	end process;

	Horizontal_position_counter:process(clk25, RST)
	begin
		if(RST = '1')then
			hpos <= 0;
		elsif(clk25'event and clk25 = '1')then
			if (hPos = (HD + HFP + HSP + HBP)) then
				hPos <= 0;
			else
				hPos <= hPos + 1;
			end if;
		end if;
	end process;

	Vertical_position_counter:process(clk25, RST, hPos)
	begin
		if(RST = '1')then
			vPos <= 0;
		elsif(clk25'event and clk25 = '1')then
			if(hPos = (HD + HFP + HSP + HBP))then
				if (vPos = (VD + VFP + VSP + VBP)) then
					vPos <= 0;
				else
					vPos <= vPos + 1;
				end if;
			end if;
		end if;
	end process;

	Horizontal_Synchronisation:process(clk25, RST, hPos)
	begin
		if(RST = '1')then
			HSYNC <= '0';
		elsif(clk25'event and clk25 = '1')then
			if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
				HSYNC <= '1';
			else
				HSYNC <= '0';
			end if;
		end if;
	end process;

	Vertical_Synchronisation:process(clk25, RST, vPos)
	begin
		if(RST = '1')then
			VSYNC <= '0';
		elsif(clk25'event and clk25 = '1')then
			if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
				VSYNC <= '1';
			else
				VSYNC <= '0';
			end if;
		end if;
	end process;

	Player1Movement:process(CLK,Player1_Button_L,Player1_Button_R)
	begin
		if(clk25'event and clk25 = '1') then
			LED_L <= Player1_Button_L;
			LED_R <= Player1_Button_R;
			LED_TEST <= '0';
			LED_TEST2 <= '0';
			--if(P1_X1 = 100) then
			--	LED_TEST <= '1';
			--else
			--	LED_TEST <= '0';
			--end if;
			
			--if(P1_X1 <= 80) then
			--	LED_TEST2 <= '1';
			--else
			--	LED_TEST2 <= '0';
			--end if;
			
			if(P1_Move_counter <= 0) then
				if (Player1_Button_L = '1') and (Player1_Button_R = '0') then
					if(P1_X1 <= 20) then
					  P1_X1 <= P1_X1;
					  BUZZER <= '1';
					else
					  BUZZER <= '0';
					  P1_X1 <= P1_X1 - 1;
					  P1_Move_counter <= P1_Move_counter_delay;
					end if;
				elsif (Player1_Button_L = '0') and (Player1_Button_R = '1') then
					if(P1_X1+80 >= 440) then
					  P1_X1 <= P1_X1;
					  BUZZER <= '1';
					else
					  BUZZER <= '0';
					  P1_X1 <= P1_X1 + 1;
					  P1_Move_counter <= P1_Move_counter_delay;
					end if;
				end if;
			else
			  P1_Move_counter <= P1_Move_counter - 1;
			end if;
		end if;
	end process;

	video_on:process(clk25, RST, hPos, vPos)
	begin
		if(RST = '1')then
			videoOn <= '0';
		elsif(clk25'event and clk25 = '1')then
			if(hPos <= HD and vPos <= VD)then
				videoOn <= '1';
			else
				videoOn <= '0';
			end if;
		end if;
	end process;
	-------------------------------------------------------------------------------------

	drawtable:process(clk25, RST, hPos, vPos, videoOn) --hpos 0 - 383 vpos 0 - 450
	begin
		
		if(RST = '1')then
			RGB <= "00000000";
		elsif(clk25'event and clk25 = '1')then
			if(videoOn = '1')then
				if((hPos >= P1_X1 and hPos <= P1_X1+80) AND (vPos >= 20 and vPos <= 40))then
					RGB <= "11100010";
				else
					RGB <= "00000000";
				end if;
			else
				RGB <= "00000000";
			end if;
		end if;
	end process;


end Behavioral;

