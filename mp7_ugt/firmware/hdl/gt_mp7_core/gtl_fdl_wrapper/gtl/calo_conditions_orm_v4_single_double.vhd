
-- Description:

-- Version history:
-- HB 2017-10-04: added limit vectors for correlation cuts.
-- HB 2017-09-06: based on calo_conditions_orm_v2, but only for single and double conditions.
-- HB 2017-09-05: based on calo_conditions_orm, but updated for correct use of object slices.
-- HB 2017-05-16: inserted check for "twobody_pt" cut use only for Double condition.
-- HB 2017-05-10: improved orm-and-structure of "obj_vs_templ_vec".
-- HB 2017-05-10: inserted "twobody_pt" cut for double condition.
-- HB 2017-04-24: inserted "calo2_obj_vs_templ" in and-structure.
-- HB 2017-04-21: wrong typo fixed.
-- HB 2017-04-20: removed "orm mask" (roll back to version from 2017-04-05).
-- HB 2017-04-10: inserted "orm mask" for use in "and structure" of "obj_vs_templ_vec".
-- HB 2017-04-06: max. 6 objects for nr_templates = 3 and nr_templates = 4 are allowed, because of length of "obj_vs_templ_vec".
-- HB 2017-04-05: first design.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; -- for function "CONV_INTEGER"

use work.gtl_pkg.all;

entity calo_conditions_orm_v4_single_double is
     generic(
        deta_orm_cut: boolean := false;
        dphi_orm_cut: boolean := false;
        dr_orm_cut: boolean := true;

        calo1_object_slice_1_low: natural;
        calo1_object_slice_1_high: natural;
        calo1_object_slice_2_low: natural;
        calo1_object_slice_2_high: natural;
        nr_templates: positive;
        et_ge_mode_calo1: boolean;
	obj_type_calo1 : natural := EG_TYPE; -- eg=0, jet=1, tau=2
        et_thresholds_calo1: calo_templates_array;
        eta_full_range_calo1 : calo_templates_boolean_array;
        eta_w1_upper_limits_calo1: calo_templates_array;
        eta_w1_lower_limits_calo1: calo_templates_array;
        eta_w2_ignore_calo1 : calo_templates_boolean_array;
        eta_w2_upper_limits_calo1: calo_templates_array;
        eta_w2_lower_limits_calo1: calo_templates_array;
        phi_full_range_calo1 : calo_templates_boolean_array;
        phi_w1_upper_limits_calo1: calo_templates_array;
        phi_w1_lower_limits_calo1: calo_templates_array;
        phi_w2_ignore_calo1 : calo_templates_boolean_array;
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

        diff_eta_orm_upper_limit_vector: std_logic_vector(MAX_WIDTH_DETA_DPHI_LIMIT_VECTOR-1 downto 0);
        diff_eta_orm_lower_limit_vector: std_logic_vector(MAX_WIDTH_DETA_DPHI_LIMIT_VECTOR-1 downto 0);

        diff_phi_orm_upper_limit_vector: std_logic_vector(MAX_WIDTH_DETA_DPHI_LIMIT_VECTOR-1 downto 0);
        diff_phi_orm_lower_limit_vector: std_logic_vector(MAX_WIDTH_DETA_DPHI_LIMIT_VECTOR-1 downto 0);

        dr_orm_upper_limit_vector: std_logic_vector(MAX_WIDTH_DR_LIMIT_VECTOR-1 downto 0);
        dr_orm_lower_limit_vector: std_logic_vector(MAX_WIDTH_DR_LIMIT_VECTOR-1 downto 0);
        
        twobody_pt_cut: boolean := false;
	pt_width: positive := 1; 
        pt_sq_threshold_vector: std_logic_vector(MAX_WIDTH_TBPT_LIMIT_VECTOR-1 downto 0) := (others => '0');
	sin_cos_width: positive := 1;
	pt_sq_sin_cos_precision : positive := 1
    );
    port(
        clk: in std_logic;
        calo1: in calo_objects_array;
        calo2: in calo_objects_array;
        diff_eta_orm: in deta_dphi_vector_array;
        diff_phi_orm: in deta_dphi_vector_array;
        condition_o: out std_logic;
        pt : in diff_inputs_array(0 to MAX_CALO_OBJECTS-1) := (others => (others => '0'));
        cos_phi_integer : in calo_sin_cos_integer_array(0 to MAX_CALO_OBJECTS-1) := (others => 0);
        sin_phi_integer : in calo_sin_cos_integer_array(0 to MAX_CALO_OBJECTS-1) := (others => 0);
        sim_obj_vs_templ_vec_single: out std_logic_vector(((calo1_object_slice_1_high-calo1_object_slice_1_low+1)*(calo2_object_high-calo2_object_low+1)) downto 1) := (others => '0');
        sim_obj_vs_templ_vec_double: out std_logic_vector(((calo1_object_slice_1_high-calo1_object_slice_1_low+1)*(calo1_object_slice_2_high-calo1_object_slice_2_low+1)
        *(calo2_object_high-calo2_object_low+1)) downto 1) := (others => '0')
    );
end calo_conditions_orm_v4_single_double;

architecture rtl of calo_conditions_orm_v4_single_double is

    constant nr_objects_slice_1_int: natural := calo1_object_slice_1_high-calo1_object_slice_1_low+1;
    constant nr_objects_slice_2_int: natural := calo1_object_slice_2_high-calo1_object_slice_2_low+1;

    constant nr_calo2_objects_int: natural := calo2_object_high-calo2_object_low+1;

-- fixed pipeline structure, 2 stages total
    constant obj_vs_templ_pipeline_stage: boolean := true; -- pipeline stage for obj_vs_templ (intermediate flip-flop)
    constant conditions_pipeline_stage: boolean := true; -- pipeline stage for condition output

    type object_slice_1_vs_template_array is array (calo1_object_slice_1_low to calo1_object_slice_1_high, 1 to 1) of std_logic;
    type object_slice_2_vs_template_array is array (calo1_object_slice_2_low to calo1_object_slice_2_high, 1 to 1) of std_logic;

    signal calo1_obj_slice_1_vs_templ, calo1_obj_slice_1_vs_templ_pipe  : object_slice_1_vs_template_array;
    signal calo1_obj_slice_2_vs_templ, calo1_obj_slice_2_vs_templ_pipe  : object_slice_2_vs_template_array;
    
    signal diff_eta_orm_comp, diff_eta_orm_comp_pipe : std_logic_2dim_array(0 to MAX_CALO_OBJECTS-1, calo2_object_low to calo2_object_high) := (others => (others => '0'));
    signal diff_phi_orm_comp, diff_phi_orm_comp_pipe : std_logic_2dim_array(0 to MAX_CALO_OBJECTS-1, calo2_object_low to calo2_object_high) := (others => (others => '0'));
    signal dr_orm_comp, dr_orm_comp_pipe : std_logic_2dim_array(0 to MAX_CALO_OBJECTS-1, calo2_object_low to calo2_object_high) := (others => (others => '0'));
    signal calo2_obj_vs_templ, calo2_obj_vs_templ_pipe : std_logic_2dim_array(calo2_object_low to calo2_object_high, 1 to 1) := (others => (others => '0'));

    signal condition_and_or : std_logic;

    signal twobody_pt_comp, twobody_pt_comp_pipe : 
	std_logic_2dim_array(calo1_object_slice_1_low to calo1_object_slice_1_high, calo1_object_slice_2_low to calo1_object_slice_2_high) := (others => (others => '1'));

begin

-- HB 2017-05-16: TBPT only for Double condition
    check_tbpt_i: if twobody_pt_cut generate
        assert (nr_templates = 2) report 
            "two-body pt cut only for Double condition - nr_templates = " & integer'image(nr_templates) 
        severity failure;       
    end generate check_tbpt_i;
    
-- Instantiation of two-body pt cut.
    twobody_pt_cut_i: if twobody_pt_cut = true and nr_templates = 2 generate
	twobody_pt_l_1: for i in calo1_object_slice_1_low to calo1_object_slice_1_high generate 
	    twobody_pt_l_2: for j in calo1_object_slice_2_low to calo1_object_slice_2_high generate
		if_j_ne_i: if j /= i generate
		    twobody_pt_calculator_i: entity work.twobody_pt_calculator_v2
			generic map(
			    pt1_width => pt_width, 
			    pt2_width => pt_width, 
			    pt_sq_threshold_vector => pt_sq_threshold_vector,
			    sin_cos_width => sin_cos_width,
			    pt_sq_sin_cos_precision => pt_sq_sin_cos_precision
			)
			port map(
			    pt1 => pt(i)(pt_width-1 downto 0),
			    pt2 => pt(j)(pt_width-1 downto 0),
			    cos_phi_1_integer => cos_phi_integer(i),
			    cos_phi_2_integer => cos_phi_integer(j),
			    sin_phi_1_integer => sin_phi_integer(i),
			    sin_phi_2_integer => sin_phi_integer(j),
			    pt_square_comp => twobody_pt_comp(i,j)
		    );
		end generate if_j_ne_i;
	    end generate twobody_pt_l_2;
	end generate twobody_pt_l_1;
    end generate twobody_pt_cut_i;
    
-- Instance of comparators for calorimeter objects. All permutations between objects and thresholds/luts.
    calo1_obj_slice_1_l: for i in calo1_object_slice_1_low to calo1_object_slice_1_high generate
        comp_i: entity work.calo_comparators_v2
            generic map(et_ge_mode_calo1, obj_type_calo1,
                et_thresholds_calo1(1),
                eta_full_range_calo1(1),
                eta_w1_upper_limits_calo1(1),
                eta_w1_lower_limits_calo1(1),
                eta_w2_ignore_calo1(1),
                eta_w2_upper_limits_calo1(1),
                eta_w2_lower_limits_calo1(1),
                phi_full_range_calo1(1),
                phi_w1_upper_limits_calo1(1),
                phi_w1_lower_limits_calo1(1),
                phi_w2_ignore_calo1(1),
                phi_w2_upper_limits_calo1(1),
                phi_w2_lower_limits_calo1(1),
                iso_luts_calo1(1)
                )
            port map(calo1(i), calo1_obj_slice_1_vs_templ(i,1));
    end generate calo1_obj_slice_1_l;

    calo1_obj_slice_2_l: for i in calo1_object_slice_2_low to calo1_object_slice_2_high generate
        comp_i: entity work.calo_comparators_v2
            generic map(et_ge_mode_calo1, obj_type_calo1,
                et_thresholds_calo1(2),
                eta_full_range_calo1(2),
                eta_w1_upper_limits_calo1(2),
                eta_w1_lower_limits_calo1(2),
                eta_w2_ignore_calo1(2),
                eta_w2_upper_limits_calo1(2),
                eta_w2_lower_limits_calo1(2),
                phi_full_range_calo1(2),
                phi_w1_upper_limits_calo1(2),
                phi_w1_lower_limits_calo1(2),
                phi_w2_ignore_calo1(2),
                phi_w2_upper_limits_calo1(2),
                phi_w2_lower_limits_calo1(2),
                iso_luts_calo1(2)
                )
            port map(calo1(i), calo1_obj_slice_2_vs_templ(i,1));
    end generate calo1_obj_slice_2_l;

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

-- HB 2017-09-05: for optimisation - splitting to different loops with "calo1_object_slice_1_low to calo1_object_slice_1_high", etc.
    cuts_orm_l_1: for i in 0 to MAX_CALO_OBJECTS-1 generate 
	cuts_orm_l_2: for k in calo2_object_low to calo2_object_high generate
	    deta_orm_cut_i: if deta_orm_cut = true generate
		diff_eta_orm_comp(i,k) <= '1' when diff_eta_orm(i,k) >= diff_eta_orm_lower_limit_vector and diff_eta_orm(i,k) <= diff_eta_orm_upper_limit_vector else '0';
	    end generate deta_orm_cut_i;
	    dphi_orm_cut_i: if dphi_orm_cut = true generate
		diff_phi_orm_comp(i,k) <= '1' when diff_phi_orm(i,k) >= diff_phi_orm_lower_limit_vector and diff_phi_orm(i,k) <= diff_phi_orm_upper_limit_vector else '0';
	    end generate dphi_orm_cut_i;
	    dr_orm_cut_i: if dr_orm_cut = true generate
		dr_calculator_i: entity work.dr_calculator_v3
		generic map(
		    upper_limit_vector => dr_orm_upper_limit_vector,
		    lower_limit_vector => dr_orm_lower_limit_vector
		)
		port map(
		    diff_eta => diff_eta_orm(i,k),
		    diff_phi => diff_phi_orm(i,k),
		    dr_comp => dr_orm_comp(i,k)
		);
	    end generate dr_orm_cut_i;
	end generate cuts_orm_l_2;
    end generate cuts_orm_l_1;

-- Pipeline stage for obj_vs_templ
    obj_vs_templ_pipeline_p: process(clk, calo1_obj_slice_1_vs_templ, calo1_obj_slice_2_vs_templ, calo2_obj_vs_templ, diff_eta_orm_comp, 
        diff_phi_orm_comp, dr_orm_comp, twobody_pt_comp)
	begin
	    if obj_vs_templ_pipeline_stage = false then
                calo1_obj_slice_1_vs_templ_pipe <= calo1_obj_slice_1_vs_templ;
                calo1_obj_slice_2_vs_templ_pipe <= calo1_obj_slice_2_vs_templ;
		calo2_obj_vs_templ_pipe <= calo2_obj_vs_templ;
		diff_eta_orm_comp_pipe <= diff_eta_orm_comp;
		diff_phi_orm_comp_pipe <= diff_phi_orm_comp;
		dr_orm_comp_pipe <= dr_orm_comp;
		twobody_pt_comp_pipe <= twobody_pt_comp;
	    else
		if (clk'event and clk = '1') then
                    calo1_obj_slice_1_vs_templ_pipe <= calo1_obj_slice_1_vs_templ;
                    calo1_obj_slice_2_vs_templ_pipe <= calo1_obj_slice_2_vs_templ;
		    calo2_obj_vs_templ_pipe <= calo2_obj_vs_templ;
		    diff_eta_orm_comp_pipe <= diff_eta_orm_comp;
		    diff_phi_orm_comp_pipe <= diff_phi_orm_comp;
		    dr_orm_comp_pipe <= dr_orm_comp;
		    twobody_pt_comp_pipe <= twobody_pt_comp;
		end if;
	    end if;
    end process;

-- "Matrix" of permutations in an and-or-structure.
-- Selection of calorimeter condition types ("single", "double", "triple" and "quad") by 'nr_templates' and 'double_wsc'.

-- Condition type: "single".
    matrix_single_i: if nr_templates = 1 generate
	matrix_single_p: process(calo1_obj_slice_1_vs_templ_pipe, calo2_obj_vs_templ_pipe, diff_eta_orm_comp_pipe, diff_phi_orm_comp_pipe, dr_orm_comp_pipe)
	    variable index : integer := 0;
	    variable obj_vs_templ_vec : std_logic_vector((nr_objects_slice_1_int*nr_calo2_objects_int) downto 1) := (others => '0');
	    variable condition_and_or_tmp : std_logic := '0';
	begin
	    index := 0;
	    obj_vs_templ_vec := (others => '0');
	    condition_and_or_tmp := '0';
	    for i in calo1_object_slice_1_low to calo1_object_slice_1_high loop
		for j in calo2_object_low to calo2_object_high loop
		    index := index + 1;
		    obj_vs_templ_vec(index) := calo1_obj_slice_1_vs_templ_pipe(i,1) and calo2_obj_vs_templ_pipe(j,1) and
					      not ((diff_eta_orm_comp_pipe(i,j) or diff_phi_orm_comp_pipe(i,j) or dr_orm_comp_pipe(i,j)) and calo2_obj_vs_templ_pipe(j,1));
		end loop;
	    end loop;
	    for i in 1 to index loop
		condition_and_or_tmp := condition_and_or_tmp or obj_vs_templ_vec(i);
	    end loop;
	    sim_obj_vs_templ_vec_single <= obj_vs_templ_vec;
	    condition_and_or <= condition_and_or_tmp;
	end process matrix_single_p;
    end generate matrix_single_i;

-- Condition type: "double".
    matrix_double_i: if nr_templates = 2 generate
	matrix_double_p: process(calo1_obj_slice_1_vs_templ_pipe, calo1_obj_slice_2_vs_templ_pipe, calo2_obj_vs_templ_pipe, diff_eta_orm_comp_pipe, diff_phi_orm_comp_pipe, dr_orm_comp_pipe, twobody_pt_comp_pipe)
	    variable index : integer := 0;
	    variable obj_vs_templ_vec : std_logic_vector((nr_objects_slice_1_int*nr_objects_slice_2_int*nr_calo2_objects_int) downto 1) := (others => '0');
	    variable condition_and_or_tmp : std_logic := '0';
	begin
	    index := 0;
	    obj_vs_templ_vec := (others => '0');
	    condition_and_or_tmp := '0';
	    for i in calo1_object_slice_1_low to calo1_object_slice_1_high loop
		for j in calo1_object_slice_2_low to calo1_object_slice_2_high loop
		    for k in calo2_object_low to calo2_object_high loop
			if j/=i then
			    index := index + 1;
			    obj_vs_templ_vec(index) := 	calo1_obj_slice_1_vs_templ_pipe(i,1) and calo1_obj_slice_2_vs_templ_pipe(j,1) and calo2_obj_vs_templ_pipe(k,1) and twobody_pt_comp_pipe(i,j) and
							not (
							(diff_eta_orm_comp_pipe(i,k) or diff_eta_orm_comp_pipe(j,k) or diff_phi_orm_comp_pipe(i,k) or 
							diff_phi_orm_comp_pipe(j,k) or dr_orm_comp_pipe(i,k) or dr_orm_comp_pipe(j,k)) 
							and calo2_obj_vs_templ_pipe(k,1)
							); 
			end if;
		    end loop;
		end loop;
	    end loop;
	    for i in 1 to index loop
		condition_and_or_tmp := condition_and_or_tmp or obj_vs_templ_vec(i);
	    end loop;
	    sim_obj_vs_templ_vec_double <= obj_vs_templ_vec;
	    condition_and_or <= condition_and_or_tmp;
	end process matrix_double_p;
    end generate matrix_double_i;

-- Pipeline stage for condition output.
    condition_o_pipeline_p: process(clk, condition_and_or)
	begin
	    if conditions_pipeline_stage = false then
		condition_o <= condition_and_or;
	    else
		if (clk'event and clk = '1') then
		    condition_o <= condition_and_or;
		end if;
	    end if;
    end process;

end architecture rtl;