
-- Description:
-- A three object condition for calos, where two objects are of same type.There is the possibility of "overlap removal" with second object type.
-- There are cuts for "overlap removal" between different object types and cuts for the correlations of same object type.

-- Version history:
-- HB 2017-04-21: implemented use of "cuts_instances" module.
-- HB 2017-04-21: inserted "calo2_obj_vs_templ" and "twobody_pt_comp" in and-structure.
-- HB 2017-04-20: removed "orm mask" (roll back to version from 2017-04-05).
-- HB 2017-04-10: inserted "orm mask" for use in "and structure" of "obj_vs_templ_vec".
-- HB 2017-04-05: corrected "and structure" of obj_vs_templ_vec.
-- HB 2017-03-30: updated pt, cos_phi_integer and sin_phi_integer ports.
-- HB 2017-03-29: updated for one "sin_cos_width" in mass_cuts.
-- HB 2017-03-16: first design.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.math_pkg.all;
use work.gtl_pkg.all;

entity calo_2plus1_orm_condition is
     generic(

        deta_orm_cut: boolean := false;
        dphi_orm_cut: boolean := false;
        dr_orm_cut: boolean := true;

        deta_cut: boolean := true;
        dphi_cut: boolean := false;
        dr_cut: boolean := false;
        mass_cut: boolean := false;
	mass_type : natural := INVARIANT_MASS_TYPE;
        twobody_pt_cut: boolean := false;

        calo1_object_low: natural;
        calo1_object_high: natural;
        et_ge_mode_calo1: boolean;
        obj_type_calo1: natural := JET_TYPE;
        et_thresholds_calo1: calo_templates_array;
        eta_full_range_calo1: calo_templates_boolean_array;
        eta_w1_upper_limits_calo1: calo_templates_array;
        eta_w1_lower_limits_calo1: calo_templates_array;
        eta_w2_ignore_calo1: calo_templates_boolean_array;
        eta_w2_upper_limits_calo1: calo_templates_array;
        eta_w2_lower_limits_calo1: calo_templates_array;
        phi_full_range_calo1: calo_templates_boolean_array;
        phi_w1_upper_limits_calo1: calo_templates_array;
        phi_w1_lower_limits_calo1: calo_templates_array;
        phi_w2_ignore_calo1: calo_templates_boolean_array;
        phi_w2_upper_limits_calo1: calo_templates_array;
        phi_w2_lower_limits_calo1: calo_templates_array;
        iso_luts_calo1: calo_templates_iso_array;

	calo2_object_low: natural;
	calo2_object_high: natural;
        et_ge_mode_calo2: boolean;
        obj_type_calo2: natural := TAU_TYPE;
        et_threshold_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        eta_full_range_calo2: boolean;
        eta_w1_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        eta_w1_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        eta_w2_ignore_calo2: boolean;
        eta_w2_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        eta_w2_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        phi_full_range_calo2: boolean;
        phi_w1_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        phi_w1_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        phi_w2_ignore_calo2: boolean;
        phi_w2_upper_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
        phi_w2_lower_limit_calo2: std_logic_vector(MAX_CALO_TEMPLATES_BITS-1 downto 0);
	iso_lut_calo2: std_logic_vector(2**MAX_CALO_ISO_BITS-1 downto 0);

	deta_dphi_orm_precision: positive;

	diff_eta_orm_upper_limit: diff_eta_range_real;
        diff_eta_orm_lower_limit: diff_eta_range_real;

        diff_phi_orm_upper_limit: diff_phi_range_real;
        diff_phi_orm_lower_limit: diff_phi_range_real;

        dr_orm_upper_limit: dr_squared_range_real;
        dr_orm_lower_limit: dr_squared_range_real;

	deta_dphi_vector_width: positive ;
	deta_dphi_precision: positive;

	diff_eta_upper_limit: diff_eta_range_real;
        diff_eta_lower_limit: diff_eta_range_real;

        diff_phi_upper_limit: diff_phi_range_real;
        diff_phi_lower_limit: diff_phi_range_real;

        dr_upper_limit: dr_squared_range_real;
        dr_lower_limit: dr_squared_range_real;

	mass_upper_limit: real;
        mass_lower_limit: real;
        
        mass_precision: positive;
	pt_width: positive; 
	mass_cosh_cos_precision : positive;
	cosh_cos_width: positive;
	
	pt_sq_threshold: real;
	sin_cos_width: positive;
	pt_precision : positive;
	pt_sq_sin_cos_precision : positive

    );
    port(
        lhc_clk: in std_logic;
        calo1: in calo_objects_array;
        calo2: in calo_objects_array;
        diff_eta_orm: in deta_dphi_vector_array;
        diff_phi_orm: in deta_dphi_vector_array;
        diff_eta: in deta_dphi_vector_array;
        diff_phi: in deta_dphi_vector_array;
        pt : in diff_inputs_array;
	cosh_deta : in calo_cosh_cos_vector_array;
        cos_dphi : in calo_cosh_cos_vector_array;
        cos_phi_integer : in calo_sin_cos_integer_array;
        sin_phi_integer : in calo_sin_cos_integer_array;
        condition_o: out std_logic;
        sim_obj_vs_templ_vec: out std_logic_vector(((calo1_object_high-calo1_object_low+1)*(calo1_object_high-calo1_object_low+1)*(calo2_object_high-calo2_object_low+1)) downto 1)
    );
end calo_2plus1_orm_condition; 

architecture rtl of calo_2plus1_orm_condition is

-- fixed pipeline structure
    constant obj_vs_templ_pipeline_stage: boolean := true; -- pipeline stage for obj_vs_templ (intermediate flip-flop)
    constant conditions_pipeline_stage: boolean := true; -- pipeline stage for condition output 

    signal diff_eta_orm_comp, diff_eta_orm_comp_pipe : std_logic_2dim_array(calo1_object_low to calo1_object_high, calo2_object_low to calo2_object_high) := (others => (others => '0'));
    signal diff_eta_orm_upper_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
    signal diff_eta_orm_lower_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
    signal diff_phi_orm_comp, diff_phi_orm_comp_pipe : std_logic_2dim_array(calo1_object_low to calo1_object_high, calo2_object_low to calo2_object_high) := (others => (others => '0'));
    signal diff_phi_orm_upper_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
    signal diff_phi_orm_lower_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
    signal dr_orm_comp, dr_orm_comp_pipe : std_logic_2dim_array(calo1_object_low to calo1_object_high, calo2_object_low to calo2_object_high) := (others => (others => '0'));
    signal calo1_obj_vs_templ, calo1_obj_vs_templ_pipe : std_logic_2dim_array(calo1_object_low to calo1_object_high, 1 to 2) := (others => (others => '0'));
    signal calo2_obj_vs_templ, calo2_obj_vs_templ_pipe : std_logic_2dim_array(calo2_object_low to calo2_object_high, 1 to 1) := (others => (others => '0'));
    signal diff_eta_upper_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
    signal diff_eta_lower_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
    signal diff_phi_upper_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
    signal diff_phi_lower_limit_int : std_logic_vector(deta_dphi_vector_width-1 downto 0);
-- HB 2017-03-27: default values of cut comps -> '1' because of AND in formular of obj_vs_templ_vec
    signal diff_eta_comp, diff_eta_comp_temp, diff_eta_comp_pipe, diff_phi_comp, diff_phi_comp_temp, diff_phi_comp_pipe, dr_comp, dr_comp_temp, dr_comp_pipe, 
	mass_comp, mass_comp_temp, mass_comp_pipe, twobody_pt_comp, twobody_pt_comp_temp, twobody_pt_comp_pipe : 
	std_logic_2dim_array(calo1_object_low to calo1_object_high, calo1_object_low to calo1_object_high) := (others => (others => '1'));
    signal condition_and_or : std_logic;
    
begin

-- Conversion of limits to std_logic_vector.
    diff_eta_orm_upper_limit_int <= conv_std_logic_vector(integer(diff_eta_orm_upper_limit*real(10**deta_dphi_orm_precision)),deta_dphi_vector_width);
    diff_eta_orm_lower_limit_int <= conv_std_logic_vector(integer(diff_eta_orm_lower_limit*real(10**deta_dphi_orm_precision)),deta_dphi_vector_width);
    diff_phi_orm_upper_limit_int <= conv_std_logic_vector(integer(diff_phi_orm_upper_limit*real(10**deta_dphi_orm_precision)),deta_dphi_vector_width);
    diff_phi_orm_lower_limit_int <= conv_std_logic_vector(integer(diff_phi_orm_lower_limit*real(10**deta_dphi_orm_precision)),deta_dphi_vector_width);
    diff_eta_upper_limit_int <= conv_std_logic_vector(integer(diff_eta_upper_limit*real(10**deta_dphi_precision)),deta_dphi_vector_width);
    diff_eta_lower_limit_int <= conv_std_logic_vector(integer(diff_eta_lower_limit*real(10**deta_dphi_precision)),deta_dphi_vector_width);
    diff_phi_upper_limit_int <= conv_std_logic_vector(integer(diff_phi_upper_limit*real(10**deta_dphi_precision)),deta_dphi_vector_width);
    diff_phi_lower_limit_int <= conv_std_logic_vector(integer(diff_phi_lower_limit*real(10**deta_dphi_precision)),deta_dphi_vector_width);

    calo1_obj_l: for i in calo1_object_low to calo1_object_high generate
	templ_l: for j in 1 to 2 generate
	    calo1_comp_i: entity work.calo_comparators_v2
		generic map(et_ge_mode_calo1, obj_type_calo1,
		    et_thresholds_calo1(j),
		    eta_full_range_calo1(j),
		    eta_w1_upper_limits_calo1(j),
		    eta_w1_lower_limits_calo1(j),
		    eta_w2_ignore_calo1(j),
		    eta_w2_upper_limits_calo1(j),
		    eta_w2_lower_limits_calo1(j),
		    phi_full_range_calo1(j),
		    phi_w1_upper_limits_calo1(j),
		    phi_w1_lower_limits_calo1(j),
		    phi_w2_ignore_calo1(j),
		    phi_w2_upper_limits_calo1(j),
		    phi_w2_lower_limits_calo1(j),
		    iso_luts_calo1(j)
		)
		port map(calo1(i), calo1_obj_vs_templ(i,j));
	end generate templ_l;
    end generate calo1_obj_l;

    calo2_obj_l: for i in calo2_object_low to calo2_object_high generate
	    calo2_comp_i: entity work.calo_comparators_v2
		generic map(et_ge_mode_calo2, obj_type_calo2,
		    et_threshold_calo2,
		    eta_full_range_calo2,
		    eta_w1_upper_limit_calo2,
		    eta_w1_lower_limit_calo2,
		    eta_w2_ignore_calo2,
		    eta_w2_upper_limit_calo2,
		    eta_w2_lower_limit_calo2,
		    phi_full_range_calo2,
		    phi_w1_upper_limit_calo2,
		    phi_w1_lower_limit_calo2,
		    phi_w2_ignore_calo2,
		    phi_w2_upper_limit_calo2,
		    phi_w2_lower_limit_calo2,
		    iso_lut_calo2
		)
		port map(calo2(i), calo2_obj_vs_templ(i,1));
    end generate calo2_obj_l;

    cuts_orm_l_1: for i in calo1_object_low to calo1_object_high generate 
	cuts_orm_l_2: for k in calo2_object_low to calo2_object_high generate
	    deta_orm_cut_i: if deta_orm_cut = true generate
		diff_eta_orm_comp(i,k) <= '1' when diff_eta_orm(i,k) >= diff_eta_orm_lower_limit_int and diff_eta_orm(i,k) <= diff_eta_orm_upper_limit_int else '0';
	    end generate deta_orm_cut_i;
	    dphi_orm_cut_i: if dphi_orm_cut = true generate
		diff_phi_orm_comp(i,k) <= '1' when diff_phi_orm(i,k) >= diff_phi_orm_lower_limit_int and diff_phi_orm(i,k) <= diff_phi_orm_upper_limit_int else '0';
	    end generate dphi_orm_cut_i;
	    dr_orm_cut_i: if dr_orm_cut = true generate
		dr_calculator_i: entity work.dr_calculator_v2
		generic map(
		    upper_limit => dr_orm_upper_limit,
		    lower_limit => dr_orm_lower_limit,
		    DETA_DPHI_VECTOR_WIDTH => deta_dphi_vector_width,
		    DETA_DPHI_PRECISION => deta_dphi_orm_precision
		)
		port map(
		    diff_eta => diff_eta_orm(i,k),
		    diff_phi => diff_phi_orm(i,k),
		    dr_comp => dr_orm_comp(i,k)
		);
	    end generate dr_orm_cut_i;
	end generate cuts_orm_l_2;
    end generate cuts_orm_l_1;

    cuts_l_1: for i in calo1_object_low to calo1_object_high generate 
	cuts_l_2: for j in calo1_object_low to calo1_object_high generate
	    if_j_gr_i: if j > i generate
		cuts_instances_i: entity work.cuts_instances
		    generic map(
			deta_cut => deta_cut,
			dphi_cut => dphi_cut,
			dr_cut => dr_cut,
			mass_cut => mass_cut,
			mass_type => mass_type,
			twobody_pt_cut => twobody_pt_cut,
			object1_low => calo1_object_low,
			object1_high => calo1_object_high,
			object2_low => calo2_object_low,
			object2_high => calo2_object_high,
			diff_eta_upper_limit => diff_eta_upper_limit,
			diff_eta_lower_limit => diff_eta_lower_limit,
			diff_phi_upper_limit => diff_phi_upper_limit,
			diff_phi_lower_limit => diff_phi_lower_limit,
			dr_upper_limit => dr_upper_limit,
			dr_lower_limit => dr_lower_limit,
			deta_dphi_vector_width => deta_dphi_vector_width,
			deta_dphi_precision => deta_dphi_precision,
			mass_upper_limit => mass_upper_limit,
			mass_lower_limit => mass_lower_limit,
			mass_precision => mass_precision,
			pt1_width => pt_width, 
			pt2_width => pt_width, 
			cosh_cos_precision => mass_cosh_cos_precision,
			cosh_cos_width => cosh_cos_width,
			pt_sq_threshold => pt_sq_threshold,
			sin_cos_width => sin_cos_width,
			pt_precision => pt_precision,
			pt_sq_sin_cos_precision => pt_sq_sin_cos_precision
		    )
		    port map(
			diff_eta => diff_eta(i,j),
			diff_phi => diff_phi(i,j),
			pt1 => pt(i),
			pt2 => pt(j),
			cosh_deta => cosh_deta(i,j),
			cos_dphi => cos_dphi(i,j),
			cos_phi_1_integer => cos_phi_integer(i),
			cos_phi_2_integer => cos_phi_integer(j),
			sin_phi_1_integer => sin_phi_integer(i),
			sin_phi_2_integer => sin_phi_integer(j),
			diff_eta_comp => diff_eta_comp_temp(i,j),
			diff_phi_comp => diff_phi_comp_temp(i,j),
			dr_comp => dr_comp_temp(i,j),
			mass_comp => mass_comp_temp(i,j),
			twobody_pt_comp => twobody_pt_comp_temp(i,j)
		    );
		diff_eta_comp(i,j) <= diff_eta_comp_temp(i,j);
		diff_eta_comp(j,i) <= diff_eta_comp_temp(i,j);
		diff_phi_comp(i,j) <= diff_phi_comp_temp(i,j);
		diff_phi_comp(j,i) <= diff_phi_comp_temp(i,j);
		dr_comp(i,j) <= dr_comp_temp(i,j);
		dr_comp(j,i) <= dr_comp_temp(i,j);
		mass_comp(i,j) <= mass_comp_temp(i,j);
		mass_comp(j,i) <= mass_comp_temp(i,j);
		twobody_pt_comp(i,j) <= twobody_pt_comp_temp(i,j);
		twobody_pt_comp(j,i) <= twobody_pt_comp_temp(i,j);
	    end generate if_j_gr_i;
	end generate cuts_l_2;
    end generate cuts_l_1;

    comb_cuts_pipeline_p: process(lhc_clk, calo1_obj_vs_templ, calo2_obj_vs_templ, diff_eta_orm_comp, diff_phi_orm_comp, dr_orm_comp, diff_eta_comp, 
	diff_phi_comp, dr_comp, mass_comp, twobody_pt_comp)
        begin
        if obj_vs_templ_pipeline_stage = false then 
	    calo1_obj_vs_templ_pipe <= calo1_obj_vs_templ;
	    calo2_obj_vs_templ_pipe <= calo2_obj_vs_templ;
	    diff_eta_orm_comp_pipe <= diff_eta_orm_comp;
	    diff_phi_orm_comp_pipe <= diff_phi_orm_comp;
	    dr_orm_comp_pipe <= dr_orm_comp;
	    diff_eta_comp_pipe <= diff_eta_comp;
	    diff_phi_comp_pipe <= diff_phi_comp;
	    dr_comp_pipe <= dr_comp;
            mass_comp_pipe <= mass_comp;
	    twobody_pt_comp_pipe <= twobody_pt_comp;
        else
            if (lhc_clk'event and lhc_clk = '1') then
		calo1_obj_vs_templ_pipe <= calo1_obj_vs_templ;
		calo2_obj_vs_templ_pipe <= calo2_obj_vs_templ;
		diff_eta_orm_comp_pipe <= diff_eta_orm_comp;
		diff_phi_orm_comp_pipe <= diff_phi_orm_comp;
		dr_orm_comp_pipe <= dr_orm_comp;
		diff_eta_comp_pipe <= diff_eta_comp;
		diff_phi_comp_pipe <= diff_phi_comp;
		dr_comp_pipe <= dr_comp;
                mass_comp_pipe <= mass_comp;
		twobody_pt_comp_pipe <= twobody_pt_comp;
            end if;
        end if;
    end process;
    
-- HB 2017-03-27: values of orm cuts between orm limits -> removal !!!
    matrix_and_or_p: process(calo1_obj_vs_templ_pipe, calo2_obj_vs_templ_pipe, diff_eta_orm_comp_pipe, diff_phi_orm_comp_pipe, dr_orm_comp_pipe, diff_eta_comp_pipe, diff_phi_comp_pipe, 
	    dr_comp_pipe, mass_comp_pipe, twobody_pt_comp_pipe)
	variable index : integer := 0;
	variable obj_vs_templ_vec : std_logic_vector(((calo1_object_high-calo1_object_low+1)*(calo1_object_high-calo1_object_low+1)*(calo2_object_high-calo2_object_low+1)) downto 1) := 
	    (others => '0');
	variable condition_and_or_tmp : std_logic := '0';
    begin
	index := 0;
	obj_vs_templ_vec := (others => '0');
	condition_and_or_tmp := '0';
	for i in calo1_object_low to calo1_object_high loop 
	    for j in calo1_object_low to calo1_object_high loop
		for k in calo2_object_low to calo2_object_high loop
		    if j/=i then
			index := index + 1;
			obj_vs_templ_vec(index) := calo1_obj_vs_templ_pipe(i,1) and calo1_obj_vs_templ_pipe(j,2) and calo2_obj_vs_templ_pipe(k,1) and
						   mass_comp_pipe(i,j) and dr_comp_pipe(i,j) and diff_phi_comp_pipe(i,j) and 
						   diff_eta_comp_pipe(i,j) and twobody_pt_comp_pipe(i,j) and
						   not (dr_orm_comp_pipe(i,k) and calo2_obj_vs_templ_pipe(k,1)) and 
						   not (dr_orm_comp_pipe(j,k) and calo2_obj_vs_templ_pipe(k,1)) and
						   not (diff_phi_orm_comp_pipe(i,k) and calo2_obj_vs_templ_pipe(k,1)) and 
						   not (diff_phi_orm_comp_pipe(j,k) and calo2_obj_vs_templ_pipe(k,1)) and
						   not (diff_eta_orm_comp_pipe(i,k) and calo2_obj_vs_templ_pipe(k,1)) and 
						   not (diff_eta_orm_comp_pipe(j,k) and calo2_obj_vs_templ_pipe(k,1));			
		    end if;
		end loop;
	    end loop;
	end loop;	
	for i in 1 to index loop 
	    -- ORs for matrix
	    condition_and_or_tmp := condition_and_or_tmp or obj_vs_templ_vec(i);
	end loop;
	sim_obj_vs_templ_vec <= obj_vs_templ_vec;
	condition_and_or <= condition_and_or_tmp;
    end process;

-- Pipeline stage for condition output.
    condition_o_pipeline_p: process(lhc_clk, condition_and_or)
        begin
            if conditions_pipeline_stage = false then 
                condition_o <= condition_and_or;
            else
                if (lhc_clk'event and lhc_clk = '1') then
                    condition_o <= condition_and_or;
                end if;
            end if;
    end process;
    
end architecture rtl;
