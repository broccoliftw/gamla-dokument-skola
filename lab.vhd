library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab is
    Port ( clk,rst, rx : in  STD_LOGIC;
           seg: out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0));
end lab;

architecture Behavioral of lab is
    component leddriver
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           value : in  STD_LOGIC_VECTOR (15 downto 0));
    end component;
    signal sreg : STD_LOGIC_VECTOR(9 downto 0) := B"0_00000000_0";  -- 10 bit skiftregister
    signal tal : STD_LOGIC_VECTOR(15 downto 0) := X"0000";  
    signal taldel : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal rx1,rx2 : std_logic;         -- vippor på insignalen
    signal sp : std_logic;              -- skiftpuls
    signal lp : std_logic;         -- laddpuls
    signal pos : STD_LOGIC_VECTOR(1 downto 0) := "00";
	
	--signal y,x : std_logic;
	--signal a,b : std_logic;
	signal bitcounter : STD_LOGIC_VECTOR(4 downto 0);
	signal counter : STD_LOGIC_VECTOR(12 downto 0);	

    signal idle : std_logic;
begin

sync: process(clk) begin
	if rising_edge(clk) then
	    if rst = '1' then
		rx1 <= '1';
		rx2 <= '1';
	    else
		rx1 <= rx;
		rx2 <= rx1;
            end if;
	end if;
end process;

styr: process(clk) begin
	if rising_edge(clk) then
		if (rst='1') then
			bitcounter <= (others => '0');
			counter <= (others => '0');
			idle <= '1';
			sp <= '0';
			lp <= '0';

		elsif (bitcounter = 10 ) then
			idle <= '1';
			bitcounter <= (others => '0');
			-- skicka lp
			sp <= '0';
			lp <= '1';
	
		elsif (idle = '1' and rx2 ='0') then -- starta rakning
			bitcounter <= (others => '0');
			idle <= '0';
			sp <= '0';
			lp <= '0';

		elsif (bitcounter = 0 and counter = 434 and idle = '0') then
			counter <= (others => '0');
			bitcounter <= bitcounter +1;
			-- skicka sp
			sp <= '1';
			lp <= '0';
			idle <= '0';

		elsif (counter >= 868) then
			counter <= (others => '0');
			bitcounter <= bitcounter +1;
			--skicka sp
			sp <= '1';
			lp <= '0';
			idle <= '0';
			
		elsif (idle = '0') then
			counter <= counter +1;
			sp <= '0';
			lp <= '0';
			idle <= '0';
		else
			idle <= '1';
			sp <= '0';
			lp <= '0';
		end if;		
	end if;
end process;

--sp <= a and (not b); 
--lp <= x and (not y);






skiftreg: process(clk) begin
	if rising_edge(clk) then

		if sp = '1' then
			--sreg(0) <= rx2; -- borde funka va? kanske 9 istället för 0
			if rst='1' then
				sreg <= "0000000000";
			else -- skifta
				--sreg <= rx2 & sreg(9 downto 1);
				sreg(9) <= rx2;
				sreg(8) <= sreg(9);
				sreg(7) <= sreg(8);
				sreg(6) <= sreg(7);
				sreg(5) <= sreg(6);
				sreg(4) <= sreg(5);
				sreg(3) <= sreg(4);
				sreg(2) <= sreg(3);
				sreg(1) <= sreg(2);
				sreg(0) <= sreg(1);
			end if;


		
		end if;
	 --byt från ASCII till binärkodning
		
	end if;
end process;


raknare: process(clk) begin -- fungerar så länge vi inte får sp signaler utanför siffrorna
	if lp = '1' and rising_edge(clk) then
		if rst='1' then
			pos <= "00";
		elsif pos>3 then
			pos <= "00";
		else
			pos <= pos+1;
		end if;
	end if;
end process;

taldel <= sreg(4 downto 1);

talreg: process(clk) begin 
	if rising_edge(clk) then 
		if rst='1' then
			tal <= "0000000000000000";

		elsif lp = '1' then
			if pos = 0 then
			--tal (15 downto 12) <= taldel(3 downto 0);
			tal (15) <= taldel (3);
			tal (14) <= taldel (2);
			tal (13) <= taldel (1);
			tal (12) <= taldel (0);

			elsif pos = 1 then
			tal (11) <= taldel (3);
			tal (10) <= taldel (2);
			tal (9) <= taldel (1);
			tal (8) <= taldel (0);

			elsif pos = 2 then
			tal (7) <= taldel (3);
			tal (6) <= taldel (2);
			tal (5) <= taldel (1);
			tal (4) <= taldel (0);


			else
			tal (3) <= taldel (3);
			tal (2) <= taldel (2);
			tal (1) <= taldel (1);
			tal (0) <= taldel (0);
			end if;

		end if;
			
	end if;
		 
end process;


  led: leddriver port map (clk, rst, seg, an, tal);
end Behavioral;

