--------------------------------------------------------------------------------
-- Synthesizer : ISE 14.6
-- Platform    : Linux Ubuntu 10.04
-- Targets     : Synthese
--------------------------------------------------------------------------------
-- This work is held in copyright as an unpublished work by HEPHY (Institute
-- of High Energy Physics) All rights reserved.  This work may not be used
-- except by authorized licensees of HEPHY. This work is the
-- confidential information of HEPHY.
--------------------------------------------------------------------------------
-- $HeadURL: svn://heros.hephy.at/GlobalTriggerUpgrade/firmware/gt_mp7/branches/hb_algo_2_buffer/src/gt_mp7_core/gtl_fdl_wrapper/gtl/esums_conditions.vhd $
-- $Date: 2015-06-12 12:26:03 +0200 (Fre, 12 Jun 2015) $
-- $Author: bergauer $
-- $Revision: 4032 $
--------------------------------------------------------------------------------

-- Desription:

-- Version history:
-- HB 2015-12-09: removed clk in esums_comparators
-- HB 2015-05-29: removed "use work.gtl_lib.all;" - using "entity work.xxx" for instances

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; -- for function "CONV_INTEGER"

use work.gtl_pkg.all;

entity min_bias_hf_conditions is
    generic	(
        et_ge_mode : boolean;
	obj_type : natural := MBHFPT0_TYPE;
        count_threshold: std_logic_vector(MAX_MBHF_TEMPLATES_BITS-1 downto 0)
   );
    port(
        clk : in std_logic;
        data_i : in std_logic_vector(MAX_ESUMS_BITS-1 downto 0);
        condition_o : out std_logic
    );
end min_bias_hf_conditions;

architecture rtl of min_bias_hf_conditions is

    constant ZERO : std_logic_vector(MAX_ESUMS_BITS-1 downto 0) := (others => '0');
-- fixed pipeline structure, 2 stages total
    constant conditions_pipeline_stages: natural := 2; -- pipeline stages for output signal of esums_conditions.vhd (0 => no flip-flop) 

    signal comp_o : std_logic;

begin

    mbhfpt0_sel: if obj_type=0 generate
        comp_o <= '0' when data_i = ZERO else
		  '1' when (data_i(D_S_I_MBHFPT0_V2.count_high downto D_S_I_MBHFPT0_V2.count_low) >= count_threshold) and et_ge_mode else            
                  '1' when (data_i(D_S_I_MBHFPT0_V2.count_high downto D_S_I_MBHFPT0_V2.count_low) = count_threshold) and not et_ge_mode else '0';            
    
    end generate mbhfpt0_sel;
    
    mbhfmt0_sel: if obj_type=1 generate
        comp_o <= '0' when data_i = ZERO else
		  '1' when (data_i(D_S_I_MBHFMT0_V2.count_high downto D_S_I_MBHFMT0_V2.count_low) >= count_threshold) and et_ge_mode else            
                  '1' when (data_i(D_S_I_MBHFMT0_V2.count_high downto D_S_I_MBHFMT0_V2.count_low) = count_threshold) and not et_ge_mode else '0';            
    
    end generate mbhfmt0_sel;
    
    mbhfpt1_sel: if obj_type=2 generate
        comp_o <= '0' when data_i = ZERO else
		  '1' when (data_i(D_S_I_MBHFPT1_V2.count_high downto D_S_I_MBHFPT1_V2.count_low) >= count_threshold) and et_ge_mode else            
                  '1' when (data_i(D_S_I_MBHFPT1_V2.count_high downto D_S_I_MBHFPT1_V2.count_low) = count_threshold) and not et_ge_mode else '0';            
    
    end generate mbhfpt1_sel;
    
    mbhfmt1_sel: if obj_type=3 generate
        comp_o <= '0' when data_i = ZERO else
		  '1' when (data_i(D_S_I_MBHFMT1_V2.count_high downto D_S_I_MBHFMT1_V2.count_low) >= count_threshold) and et_ge_mode else            
                  '1' when (data_i(D_S_I_MBHFMT1_V2.count_high downto D_S_I_MBHFMT1_V2.count_low) = count_threshold) and not et_ge_mode else '0';            
    
    end generate mbhfmt1_sel;
    
-- Pipeline stages for condition output.
    condition_o_pipeline: process(clk, comp_o)
	variable pipeline_temp : std_logic_vector(0 to conditions_pipeline_stages+1) := (others => '0');
    begin
        pipeline_temp(conditions_pipeline_stages+1) := comp_o;
        if (conditions_pipeline_stages > 0) then 
            if (clk'event and (clk = '1') ) then
                pipeline_temp(0 to conditions_pipeline_stages) := pipeline_temp(1 to conditions_pipeline_stages+1);
            end if;
        end if;
        condition_o <= pipeline_temp(1); -- used pipeline_temp(1) instead of pipeline_temp(0), to prevent warnings in compilation
    end process;

end architecture rtl;
