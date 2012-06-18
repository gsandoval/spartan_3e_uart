----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:17:36 06/15/2012 
-- Design Name: 
-- Module Name:    Main - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main is
port(
	mclock : in std_logic;
	reset : in std_logic;
	tx : out	std_logic;
	leds : out std_logic_vector(7 downto 0)
);
end Main;

architecture Behavioral of Main is
	
	signal tx_clock : std_logic;
	signal tx_request : std_logic;
	signal tx_data : std_logic_vector(7 downto 0);
	signal rx_data : std_logic_vector(7 downto 0);
	signal tx_busy : std_logic;
	
begin
	
	uartController : entity work.UARTController
	generic map(
		CLOCK_FREQ	=> 50000000,
		SERIAL_FREQ	=> 9600,
		STOP_BITS_COUNT => 1,
		PARITY_ENABLED => '0'
	)
	port map(
		mclock => mclock,
		reset => reset,
		tx => tx,
		tx_clock => tx_clock,
		tx_request => tx_request,
		tx_data => tx_data,
		rx_data => rx_data,
		tx_busy => tx_busy
	);
	
	leds <= rx_data;
	
	send_str : process(reset, tx_clock, tx_busy)
		variable sent : integer := 0;
		variable message : string(1 to 19) := "This is Spartan 3E!";
	begin
		if reset = '1' then
			sent := 0;
			tx_request <= '0';
		elsif tx_clock'event and tx_clock = '1' then
			if tx_busy = '0' and tx_request = '0' and sent < message'length then
				sent := sent + 1;
				tx_data <= conv_std_logic_vector(character'pos(message(sent)), 8);
				tx_request <= '1';
			else
				tx_request <= '0';
			end if;
		end if;
	end process;
	
end Behavioral;

