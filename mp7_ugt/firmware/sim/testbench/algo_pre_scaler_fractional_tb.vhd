
-- Description:
-- Testbench for prescalers (FDL) with fractional prescale values
-- bits 31:24 => fractional value (precision 2), bits 23:0 => integer digits
-- (for backward compatibility)

-- Version history:
-- HB 2019-05-31: first design

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
library std;                  -- for Printing
use std.textio.all;

use work.gtl_pkg.all;

entity algo_pre_scaler_fractional_TB is
end algo_pre_scaler_fractional_TB;

architecture beh of algo_pre_scaler_fractional_TB is

    constant SIM : boolean := true;
    constant COUNTER_WIDTH : natural := 24;
    constant FRACTION_WIDTH : natural := 8;
    constant PRESCALE_FACTOR_INIT : std_logic_vector(31 downto 0) := X"00000001";
    
    constant PRESCALE_FACTOR_VAL : std_logic_vector(31 downto 0) := X"42000003"; -- actual factor for test = 3.66
    
    constant LHC_CLK_PERIOD  : time :=  25 ns;

    signal lhc_clk : std_logic;
    signal sres_counter, request_update_factor_pulse, update_factor_pulse : std_logic := '0';
    signal algo : std_logic := '1';
    signal algo_o : std_logic;
    signal prescale_factor : std_logic_vector(COUNTER_WIDTH+FRACTION_WIDTH-1 downto 0) := (others => '0');
    signal index_sim : integer;
    signal algo_cnt : integer := 0;

--*********************************Main Body of Code**********************************
begin
    
    -- Clock
    process
    begin
        lhc_clk  <=  '1';
        wait for LHC_CLK_PERIOD/2;
        lhc_clk  <=  '0';
        wait for LHC_CLK_PERIOD/2;
    end process;

    -- Algo
    process
    begin
        algo  <=  '1';
        wait for LHC_CLK_PERIOD;
        algo  <=  '0';
        wait for 10*LHC_CLK_PERIOD;
    end process;

    process
    begin
	wait for LHC_CLK_PERIOD; 
        sres_counter <= '1';
	wait for LHC_CLK_PERIOD; 
        sres_counter <= '0';
        prescale_factor <= PRESCALE_FACTOR_VAL;
	wait for 5*LHC_CLK_PERIOD;
	request_update_factor_pulse <= '1';
	wait for LHC_CLK_PERIOD;
	request_update_factor_pulse <= '0';
	wait for 5*LHC_CLK_PERIOD;
	update_factor_pulse <= '1';
	wait for LHC_CLK_PERIOD;
	update_factor_pulse <= '0';
        wait;
    end process;

 ------------------- Instantiate  modules  -----------------

  dut: entity work.algo_pre_scaler
    generic map(COUNTER_WIDTH, PRESCALE_FACTOR_INIT, FRACTION_WIDTH, SIM)
    port map(
      clk => lhc_clk,
      sres_counter => sres_counter,
      algo_i => algo,
      request_update_factor_pulse => request_update_factor_pulse,
      update_factor_pulse => update_factor_pulse,
      prescale_factor => prescale_factor,
      prescaled_algo_o => open,
      index_sim => open,
      prescaled_algo_cnt_sim => open,
      algo_cnt_sim => open
    );
 
end beh;

