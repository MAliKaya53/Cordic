
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sincos_tb is
end sincos_tb;

architecture Behavioral of sincos_tb is

constant CLOCK_PERIOD : time 			    := 10 ns;
constant PI_POS	      : signed(15 downto 0) := "0110010010001000"; -- 16-bit signed fixed-point karşılıkları
constant PI_NEG	      : signed(15 downto 0) := "1001101101111000"; -- -- -3.14159 (yaklaşık -π)
constant PHASE_INC    : integer		        := 256;
					  
signal 	 clk		  : std_logic 		    := '0';
signal 	 rst		  : std_logic 		    := '1';
					  
signal   phase        : signed(15 downto 0);
signal   phase_tvalid : std_logic;
signal   cos		  : std_logic_vector(15 downto 0);
signal   sin		  : std_logic_vector(15 downto 0);
signal   sincos_tvalid: std_logic;


begin

sincos_inst: entity work.sincos
	port map(
		clk   		 => clk,
		phase 		 => std_logic_vector(phase),
		phase_tvalid => phase_tvalid, 
		cos 		 => cos,
		sin			 => sin,
		sincos_tvalid=> sincos_tvalid
	);

-- pulse clock signal
process begin
	clk <= '0';
	wait for CLOCK_PERIOD/2;
	clk <= '1';
	wait for CLOCK_PERIOD/2;
end process;

-- drive reset signal
process begin
	rst <= '1';
	wait for CLOCK_PERIOD*10;
	rst <= '0';
	wait;
end process;

-- drive phase input
process (clk) begin
	if rst = '1' then
		phase 		<= (others => '0');
		phase_tvalid <= '0';
	else
		phase_tvalid <= '1';
		if (phase + PHASE_INC < PI_POS) then
			phase <= phase + PHASE_INC; -- Fazı sürekli PHASE_INC kadar artırıyoruz → sanki açıyı 0’dan π’ye kadar döndürüyoruz.
		else
			phase <= PI_NEG; -- Eğer faz +π sınırını aşarsa, tekrar -π'den başlatıyoruz.
		end if;
	end if;
end process;

end Behavioral;
