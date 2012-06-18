----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Guillermo A. Sandoval-Sanchez
-- 
-- Create Date:    22:38:21 05/31/2012 
-- Design Name: 
-- Module Name:    UARTController - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UARTController is
generic (
	CLOCK_FREQ : integer := 50000000;
	SERIAL_FREQ : integer := 9600;
	STOP_BITS_COUNT : integer := 1;
	PARITY_ENABLED : std_logic := '0'
);
port (
	mclock : in	std_logic;
	reset : in	std_logic;
	tx : out	std_logic := '1';
	tx_clock : buffer std_logic;
	tx_request : in std_logic;
	tx_busy : out std_logic := '0';
	tx_data : in std_logic_vector(7 downto 0);
	rx_data : out std_logic_vector(7 downto 0)
);
end UARTController;

architecture Behavioral of UARTController is
	
	type state is (idle, data, parity, stop);
	constant UART_IDLE	:	std_logic := '1';
	constant UART_START	:	std_logic := '0';
 
	signal tx_fsm : state := idle;
	
begin
	
	send_clock : process(mclock, reset)
		variable counter : integer range 1 to conv_integer(CLOCK_FREQ / SERIAL_FREQ / 2);
	begin
		if reset = '1' then
			tx_clock <= '0';
			counter := 1;
		elsif mclock'event and mclock = '1' then
			if counter = (CLOCK_FREQ / SERIAL_FREQ / 2) then
				tx_clock	<=	not(tx_clock);
				counter := 1;
			else
				counter := counter + 1;
			end if;
		end if;
	end process;
 
	send : process(tx_clock, reset)
		variable parity_bit : std_logic;
		variable data_tmp : std_logic_vector(7 downto 0);
		variable data_count : integer;
		variable stop_bits_count : integer;
	begin
		if reset = '1' then
			tx_fsm <= idle;
			parity_bit := '0';
			data_tmp := (others => '0');
			data_count := 0;
			tx <= UART_IDLE;
			tx_busy <= '0';
			stop_bits_count := 0;
		elsif tx_clock'event and tx_clock = '1' then
			case tx_fsm is
				when idle =>
					if tx_request = '1' then
						tx	<=	UART_START;
						tx_fsm <= data;
						data_tmp	:=	tx_data;
						data_count := 0;
						parity_bit := '0';
						stop_bits_count := 0;
						tx_busy <= '1';
					end if;
				when data =>
					tx <=	data_tmp(0);
					parity_bit := parity_bit xor data_tmp(0);
					data_tmp	:=	'0' & data_tmp(7 downto 1);
					data_count := data_count + 1;
					if data_count = 8 then
						if PARITY_ENABLED = '1' then
							tx_fsm <= parity;
						else
							tx_fsm <= stop;
						end if;
					end if;
				when parity =>
					tx <=	parity_bit;
					tx_fsm <= stop;
				when stop =>
					tx <=	UART_IDLE;
					stop_bits_count := stop_bits_count + 1;
					if stop_bits_count = STOP_BITS_COUNT then
						tx_fsm <= idle;
						tx_busy <= '0';
					end if;
				when others => null;
			end case;
		end if;
	end process;

end Behavioral;
