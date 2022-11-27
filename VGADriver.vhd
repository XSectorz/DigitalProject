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
           LED_OUT_X : out  STD_LOGIC;
           LED_OUT_X_MINUS : out  STD_LOGIC;
			  Player1_Button_L : in STD_LOGIC;
			  Player1_Button_R : in STD_LOGIC;
			  Player2_Button_L : in STD_LOGIC;
			  Player2_Button_R : in STD_LOGIC;
			  BUZZER : out STD_LOGIC;
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
	
	signal P1_X1 : integer := 140; -- left border player 1
	signal P2_X1 : integer := 140; -- left border player 2
	constant P1_WIDTH : integer := 30;
	constant P2_WIDTH : integer := 30;
	
	signal Ball_X1 : integer := 230; -- Ball Position X
	signal Ball_Y1 : integer := 230; -- Ball Position Y
	signal Ball_width : integer := 5; -- BallWidth
	signal Ball_height : integer := 10; -- BallHeight
	signal Ball_Direction_X : integer := 1; -- Ball Direction Horizontal
	signal Ball_Direction_Y : integer := 1; -- Ball Direction Vertical
	
	signal P1_Move_counter : integer := 0;
	signal P2_Move_counter : integer := 0;
	signal Ball_Move_counter : integer := 0;
	signal Sound_counter : integer := 0;
	constant P1_Move_counter_delay : integer := 100000;
	constant P2_Move_counter_delay : integer := 100000;
	constant Ball_Move_counter_delay : integer := 120000;
	constant Sound_counter_delay : integer := 200000;
	
	constant P1_Y : integer := 60;
	constant P2_Y : integer := 440;
	constant Ball_SpawnPosX : integer := 230;
	constant Ball_SpawnPosY : integer := 230;
	constant Ball_SpawnDirectionX : integer := 1;
	constant Ball_SpawnDirectionY : integer := 1;
	
	signal videoOn : std_logic := '1';

begin

	clk_div:process(CLK)
	begin
		clk25 <= CLK;
	end process;
	
	test:process(Player1_Button_L,Player1_Button_R)
	begin
		LED_OUT_X <= Player1_Button_L;
		LED_OUT_X_MINUS <= Player1_Button_R;
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
	
	BallCollision:process(CLK)
	begin
		if(clk25'event and clk25 = '1') then
			
			if (Sound_counter > 0) then
				--BUZZER <= '1';
				Sound_counter <= Sound_counter - 1;
			else
				BUZZER <= '0';
			end if;
			
			if ((Ball_X1+Ball_width >= P2_X1) and (Ball_X1+Ball_width <= (P2_X1+P2_WIDTH)) and (Ball_Y1+Ball_height = P2_Y)) then --Interact Player 2
				Sound_counter <= Sound_counter_delay;
				if ((Ball_X1+(Ball_X1+Ball_width))/2 <=((P2_X1+(P2_X1+P2_WIDTH))/2)) then --fist half
					Ball_Direction_X <= -1;
					Ball_Direction_Y <= -1;
				else
					Ball_Direction_X <= 1;
					Ball_Direction_Y <= -1;
				end if;
			elsif ((Ball_X1+Ball_width >= P1_X1) and (Ball_X1+Ball_width <= (P1_X1+P1_WIDTH)) and (Ball_Y1-2 = P1_Y)) then --Interact Player 1
				Sound_counter <= Sound_counter_delay;
				if ((Ball_X1+(Ball_X1+Ball_width))/2 <= ((P1_X1+(P1_X1+P1_WIDTH))/2)) then --fist half
					Ball_Direction_X <= -1;
					Ball_Direction_Y <= 1;
				else
					Ball_Direction_X <= 1;
					Ball_Direction_Y <= 1;
				end if;
			else
				if (Ball_Y1+Ball_height >= 464) or (Ball_Y1 <= 29) then --Ball Out of Border
					Ball_X1 <= Ball_SpawnPosX;
					Ball_Y1 <= Ball_SpawnPosY;
					Ball_Direction_X <= Ball_SpawnDirectionX;
					Ball_Direction_Y <= Ball_SpawnDirectionY;
					Sound_counter <= Sound_counter_delay + 1000000;
				elsif (Ball_X1 <= 47) then
					if (Ball_Direction_Y = 1) then
						Ball_Direction_X <= 1;
						Ball_Direction_Y <= 1;
					else
						Ball_Direction_X <= 1;
						Ball_Direction_Y <= -1;
					Sound_counter <= Sound_counter_delay;
					end if;
				elsif (Ball_X1+Ball_width >= HD-21) then
					if (Ball_Direction_Y = -1) then
						Ball_Direction_X <= -1;
						Ball_Direction_Y <= -1;
					else
						Ball_Direction_X <= -1;
						Ball_Direction_Y <= 1;
					Sound_counter <= Sound_counter_delay;
					end if;
				end if;
			end if;
			
			if(Ball_Move_counter <= 0) then
				if (Ball_Direction_X = 1)then
					Ball_X1 <= Ball_X1+1;
				else
					Ball_X1 <= Ball_X1-1;
				end if;
				if (Ball_Direction_Y = 1)then
					Ball_Y1 <= Ball_Y1+1;
				else
					Ball_Y1 <= Ball_Y1-1;
				end if;
				Ball_Move_counter <= Ball_Move_counter_delay;
			else
				Ball_Move_counter <= Ball_Move_counter - 1;
			end if;			
		end if;
	end process;

	Player1Movement:process(CLK,Player1_Button_L,Player1_Button_R)
	begin
		
		if(clk25'event and clk25 = '1') then
			
			--Player 1 Movement
			if(P1_Move_counter <= 0) then
				if (Player1_Button_L = '1') and (Player1_Button_R = '0') then
					if(P1_X1 <= 47) then
					  P1_X1 <= P1_X1;
					else
					  P1_X1 <= P1_X1 - 1;
					  P1_Move_counter <= P1_Move_counter_delay;
					end if;
				elsif (Player1_Button_L = '0') and (Player1_Button_R = '1') then
					if(P1_X1+P1_WIDTH >= HD-21) then
					  P1_X1 <= P1_X1;
					else
					  P1_X1 <= P1_X1 + 1;
					  P1_Move_counter <= P1_Move_counter_delay;
					end if;
				end if;
			else
			  P1_Move_counter <= P1_Move_counter - 1;
			end if;
			
			--Player 2 Movement
			if(P2_Move_counter <= 0) then
				if (Player2_Button_L = '1') and (Player2_Button_R = '0') then
					if(P2_X1 <= 47) then
					  P2_X1 <= P2_X1;
					else
					  P2_X1 <= P2_X1 - 1;
					  P2_Move_counter <= P2_Move_counter_delay;
					end if;
				elsif (Player2_Button_L = '0') and (Player2_Button_R = '1') then
					if(P2_X1+P2_WIDTH >= HD-21) then
					  P2_X1 <= P2_X1;
					else
					  P2_X1 <= P2_X1 + 1;
					  P2_Move_counter <= P2_Move_counter_delay;
					end if;
				end if;
			else
			  P2_Move_counter <= P2_Move_counter - 1;
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
				if((hPos >= P1_X1 and hPos <= P1_X1+P1_WIDTH) AND (vPos >= P1_Y and vPos <= P1_Y+10))then
					RGB <= "11100010";
				elsif((hPos >= P2_X1 and hPos <= P2_X1+P2_WIDTH) AND (vPos >= P2_Y and vPos <= P2_Y+10))then
					RGB <= "00011110";
				elsif((hPos >= Ball_X1 and hPos <= Ball_X1+Ball_width) AND (vPos >= Ball_Y1 and vPos <= Ball_Y1+Ball_height))then
					RGB <= "11111100";
				elsif((hPos >= 40 and hPos <= HD-20) AND (vPos >= 22 and vPos <= 28))then
					RGB <= "00111100";
				elsif((hPos >= 40 and hPos <= HD-20) AND (vPos >= 465 and vPos <= 471))then
					RGB <= "00111100";
				elsif((hPos >= 40 and hPos <= 46) AND (vPos >= 22 and vPos <= VD-15))then
					RGB <= "00111100";
				elsif((hPos >=	HD-20 and hPos <= HD-14) AND (vPos >= 22 and vPos <= VD-8))then
					RGB <= "00111100";
				else
					RGB <= "00000000";
				end if;
			else
				RGB <= "00000000";
			end if;
		end if;
	end process;


end Behavioral;

