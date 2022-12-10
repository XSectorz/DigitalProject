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
           BTN_START : in  STD_LOGIC;
           BTN_RESTART : in  STD_LOGIC;
			  Player1_Button_L : in STD_LOGIC;
			  Player1_Button_R : in STD_LOGIC;
			  Player2_Button_L : in STD_LOGIC;
			  Player2_Button_R : in STD_LOGIC;
			  BUZZER : out STD_LOGIC;
			  outputScore1 : out STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (7 downto 0));	  
end vga_driver;

architecture Behavioral of vga_driver is
		
	signal clk25 : std_logic := '0';
	signal clkDiv1M : std_logic := '0';
	
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
	
	signal P1_X1 : integer := 210; -- left border player 1
	signal P2_X1 : integer := 210; -- left border player 2
	constant P1_WIDTH : integer := 45;
	constant P2_WIDTH : integer := 45;
	
	signal Ball_X1 : integer := 230; -- Ball Position X
	signal Ball_Y1 : integer := 230; -- Ball Position Y
	signal Ball_width : integer := 5; -- BallWidth
	signal Ball_height : integer := 10; -- BallHeight
	signal Ball_Direction_X : integer := 1; -- Ball Direction Horizontal
	signal Ball_Direction_Y : integer := 1; -- Ball Direction Vertical
	
	signal P1_Move_counter : integer := 0;
	signal P2_Move_counter : integer := 0;
	signal Ball_Move_counter : integer := 0;
	signal BallCollision : integer := 0;
	signal Sound_counter : integer := 0;
	constant P1_Move_counter_delay : integer := 60000;
	constant P2_Move_counter_delay : integer := 60000;
	constant Ball_Move_counter_delay : integer := 120000;
	constant Sound_counter_delay : integer := 200000;
	
	constant P1_Y : integer := 60;
	constant P2_Y : integer := 440;
	constant Ball_SpawnPosX : integer := 230;
	constant Ball_SpawnPosY : integer := 230;
	constant Ball_SpawnDirectionX : integer := 1;
	constant Ball_SpawnDirectionY : integer := 1;
	constant Ball_StartMoveCounter : integer := 250000;
	
	signal videoOn : std_logic := '1';
	signal rand_num : integer := -20;
	signal rand_type : integer := 0;
	signal rand_type2 : integer := 0;
	signal clockCount : integer := 0;
	
	signal gameStart : std_logic := '0';
begin

	clk_div:process(CLK)
	begin
		clk25 <= CLK;
	end process;
	
	gameProcess:process(BTN_START,BTN_RESTART)
	begin
		if (BTN_START = '1' and BTN_RESTART = '0') then
			gameStart <= '1';
		elsif (BTN_RESTART = '1' and BTN_START = '0') then
			gameStart <= '0';
		end if;
	end process;
	
	clk_div1M:process(CLK)
	begin
		if(clk25'event and clk25 = '1') then
			clockCount <= clockCount + 1;
			if clockCount = 1000000 then
				clkDiv1M <= NOT clkDiv1M;
				clockCount <= 1;
			end if;
		end if;
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
	
	PsudoRandom:process
	begin
		if(clkDiv1M'event and clkDiv1M = '1') then
			rand_num <= rand_num + 1;
			rand_type <= rand_type + 1;
			rand_type2 <= rand_type2 + 1;
			if rand_num = 21 then
				rand_num <= -20;
			end if;
			if rand_type = 50 then
				rand_type <= 0;
			end if;
			if rand_type2 = 100 then
				rand_type2 <= 0;
			end if;
		end if;
	end process;
	
	BallCollisionChecker:process(CLK)
	begin
		if(clk25'event and clk25 = '1') then
		
			if (Sound_counter > 0) then
				--BUZZER <= '1';
				Sound_counter <= Sound_counter - 1;
			else
				BUZZER <= '0';
			end if;
				
			if gameStart = '1' then
				if ((Ball_X1+Ball_width >= P2_X1) and (Ball_X1+Ball_width <= (P2_X1+P2_WIDTH)) and (Ball_Y1+Ball_height = P2_Y)) then --Interact Player 2
					Sound_counter <= Sound_counter_delay;
					Ball_Direction_Y <= -1;
					if ((Ball_X1+(Ball_X1+Ball_width))/2 <= ((P2_X1+(P2_X1+P2_WIDTH))/2)-10) then --fist half 
						Ball_Direction_X <= -1;
					elsif ((Ball_X1+(Ball_X1+Ball_width))/2 <= ((P2_X1+(P2_X1+P2_WIDTH))/2)+10) then
						Ball_Direction_X <= 1;
					else --middle	
						Ball_Direction_X <= 0;
					end if;
					BallCollision <= BallCollision + 1;
				elsif ((Ball_X1+Ball_width >= P1_X1) and (Ball_X1+Ball_width <= (P1_X1+P1_WIDTH)) and (Ball_Y1-2 = P1_Y)) then --Interact Player 1
					Sound_counter <= Sound_counter_delay;
					Ball_Direction_Y <= 1;
					if ((Ball_X1+(Ball_X1+Ball_width))/2 <= ((P1_X1+(P1_X1+P1_WIDTH))/2)-10) then --fist half
						Ball_Direction_X <= -1;
					elsif ((Ball_X1+(Ball_X1+Ball_width))/2 <= ((P1_X1+(P1_X1+P1_WIDTH))/2)+10) then
						Ball_Direction_X <= 1;
					else
						Ball_Direction_X <= 0;
					end if;
					BallCollision <= BallCollision + 1;
				else
					if (Ball_Y1+Ball_height >= 464) or (Ball_Y1 <= 29) then --Ball Out of Border
						
						if (Ball_Y1+Ball_height >= 464) then
							--Player 2 lose send score to player 1
							--output_p1 -> 1
							outputScore1 <= '1';
						else
							--output_p1 -> 0
							outputScore1 <= '0';
						end if;
						
						if (Ball_Y1 <= 29) then
							--Player 1 lose send score to player 2
						end if;
						
						
						if rand_type <= 26 then
							Ball_X1 <= Ball_SpawnPosX+rand_num;
						else
							Ball_X1 <= Ball_SpawnPosX-rand_num;
						end if;
						
						Ball_Y1 <= Ball_SpawnPosY;
						
						if rand_type <= 25 then
							Ball_Direction_X <= -1*Ball_SpawnDirectionX;
						else
							Ball_Direction_X <= Ball_SpawnDirectionX;
						end if;
						
						if rand_type2 >= 50 then
							Ball_Direction_Y <= 1*Ball_SpawnDirectionY;
						else
							Ball_Direction_Y <= -1*Ball_SpawnDirectionY;
						end if;
						
						Sound_counter <= Sound_counter_delay + 1000000;
						Ball_Move_counter <= Ball_StartMoveCounter;
						BallCollision <= 0;
					elsif (Ball_X1 <= 47) then
						if (Ball_Direction_Y = 1) then
							Ball_Direction_X <= 1;
							Ball_Direction_Y <= 1;
						else
							Ball_Direction_X <= 1;
							Ball_Direction_Y <= -1;
						BallCollision <= BallCollision + 1;
						Sound_counter <= Sound_counter_delay;
						end if;
					elsif (Ball_X1+Ball_width >= HD-21) then
						if (Ball_Direction_Y = -1) then
							Ball_Direction_X <= -1;
							Ball_Direction_Y <= -1;
						else
							Ball_Direction_X <= -1;
							Ball_Direction_Y <= 1;
						BallCollision <= BallCollision + 1;
						Sound_counter <= Sound_counter_delay;
						end if;
					end if;
				end if;
				
				if(Ball_Move_counter <= 0) then
					if (Ball_Direction_X = 1)then
						Ball_X1 <= Ball_X1+1;
					elsif Ball_Direction_X = -1 then
						Ball_X1 <= Ball_X1-1;
					else
						Ball_X1 <= Ball_X1;
					end if;
					if (Ball_Direction_Y = 1)then
						Ball_Y1 <= Ball_Y1+2;
					else
						Ball_Y1 <= Ball_Y1-2;
					end if;
					if BallCollision <= 0 then
						Ball_Move_counter <= Ball_StartMoveCounter;
					else
						Ball_Move_counter <= Ball_Move_counter_delay;
					end if;
					
				else
					Ball_Move_counter <= Ball_Move_counter - 1;
				end if;		
			else
				Ball_X1 <= Ball_SpawnPosX;
				Ball_Y1 <= Ball_SpawnPosY;
						
				if rand_type <= 25 then
					Ball_Direction_X <= -1*Ball_SpawnDirectionX;
				else
					Ball_Direction_X <= Ball_SpawnDirectionX;
				end if;
						
				if rand_type2 >= 50 then
					Ball_Direction_Y <= 1*Ball_SpawnDirectionY;
				else
					Ball_Direction_Y <= -1*Ball_SpawnDirectionY;
				end if;
						
				Ball_Move_counter <= Ball_StartMoveCounter;
				BallCollision <= 0;
			end if;
				
		end if;
	end process;

	Player1Movement:process(CLK,Player1_Button_L,Player1_Button_R)
	begin
		
		if(clk25'event and clk25 = '1') then
			
			if gameStart = '1' then
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
			else
				P1_X1 <= 210;
				P2_X1 <= 210;
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

