
-- Description:
-- Wrapper for LUTs of deta, dphi, cosh deta and cos dphi for correlation conditions.

-- Version history:
-- HB 2021-04-19: added wrapper for LUTs of deta and dphi. Renamed file.
-- HB 2021-02-18: first design.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.gtl_pkg.all;

entity deta_dphi_cosh_cos_wrapper is
     generic(
        deta_dphi_sel: boolean := false;
        cosh_deta_cos_dphi_sel: boolean := false;
        calo_calo_deta_lut: calo_calo_diff_eta_lut_array := (others => 0);
        calo_calo_dphi_lut: calo_calo_diff_phi_lut_array := (others => 0);
        calo_muon_deta_lut: calo_muon_diff_eta_lut_array := (others => 0);
        calo_muon_dphi_lut: calo_muon_diff_phi_lut_array := (others => 0);
        muon_muon_deta_lut: muon_muon_diff_eta_lut_array := (others => 0);
        muon_muon_dphi_lut: muon_muon_diff_phi_lut_array := (others => 0);
        calo_calo_cosh_deta_lut: calo_calo_cosh_deta_lut_array := (others => 0);
        calo_calo_cos_dphi_lut: calo_calo_cos_dphi_lut_array := (others => 0);
        calo_muon_cosh_deta_lut: calo_muon_cosh_deta_lut_array := (others => 0);
        calo_muon_cos_dphi_lut: calo_muon_cos_dphi_lut_array := (others => 0);
        muon_muon_cosh_deta_lut: muon_muon_cosh_deta_lut_array := (others => 0);
        muon_muon_cos_dphi_lut: muon_muon_cos_dphi_lut_array := (others => 0);
        cosh_cos_vector_width: natural := EG_EG_COSH_COS_VECTOR_WIDTH;
        nr_obj1: natural := NR_EG_OBJECTS;
        type_obj1: natural := EG_TYPE;
        nr_obj2: natural := NR_EG_OBJECTS;
        type_obj2: natural := EG_TYPE
    );
    port(
        dphi_integer: in dim2_max_phi_range_array(0 to nr_obj1-1, 0 to nr_obj2-1) := (others => (others => 0));
        deta_integer: in dim2_max_eta_range_array(0 to nr_obj1-1, 0 to nr_obj2-1) := (others => (others => 0));
        deta_vector: out deta_dphi_vector_array(0 to nr_obj1-1, 0 to nr_obj2-1) := (others => (others => (others => '0')));
        dphi_vector: out deta_dphi_vector_array(0 to nr_obj1-1, 0 to nr_obj2-1) := (others => (others => (others => '0')));
        cosh_deta_vector: out common_cosh_cos_vector_array(0 to nr_obj1-1, 0 to nr_obj2-1) := (others => (others => (others => '0')));
        cos_dphi_vector: out common_cosh_cos_vector_array(0 to nr_obj1-1, 0 to nr_obj2-1) := (others => (others => (others => '0')))
    );
end deta_dphi_cosh_cos_wrapper;

architecture rtl of deta_dphi_cosh_cos_wrapper is

begin

    l1: for i in 0 to nr_obj1-1 generate
        l2: for j in 0 to nr_obj2-1 generate
            deta_dphi_sel_i: if deta_dphi_sel generate
                deta_dphi_i: entity work.deta_dphi_cosh_cos_luts
                    generic map(
--                         calo_calo_deta_lut => calo_calo_deta_lut, calo_calo_dphi_lut => calo_calo_dphi_lut,
--                         calo_muon_deta_lut => calo_muon_deta_lut, calo_muon_dphi_lut => calo_muon_dphi_lut,
--                         muon_muon_deta_lut => muon_muon_deta_lut, muon_muon_dphi_lut => muon_muon_dphi_lut,
                        nr_obj1 => nr_obj1, type_obj1 => type_obj1,
                        nr_obj2 => nr_obj2, type_obj2 => type_obj2,
                        deta_dphi_sel => deta_dphi_sel
                    )
                    port map(deta_integer => deta_integer(i,j), dphi_integer => dphi_integer(i,j),
                        deta_vector => deta_vector(i,j), dphi_vector => dphi_vector(i,j)
                    );
            end generate deta_dphi_sel_i;
            cosh_deta_cos_dphi_sel_i: if cosh_deta_cos_dphi_sel generate
                cosh_deta_cos_dphi_i: entity work.deta_dphi_cosh_cos_luts
                    generic map(
--                         calo_calo_cosh_deta_lut => calo_calo_cosh_deta_lut, calo_calo_cos_dphi_lut => calo_calo_cos_dphi_lut,
--                         calo_muon_cosh_deta_lut => calo_muon_cosh_deta_lut, calo_muon_cos_dphi_lut => calo_muon_cos_dphi_lut,
--                         muon_muon_cosh_deta_lut => muon_muon_cosh_deta_lut, muon_muon_cos_dphi_lut => muon_muon_cos_dphi_lut,
                        nr_obj1 => nr_obj1, type_obj1 => type_obj1,
                        nr_obj2 => nr_obj2, type_obj2 => type_obj2,
                        cosh_cos_vector_width => cosh_cos_vector_width, cosh_deta_cos_dphi_sel => cosh_deta_cos_dphi_sel
                    )
                    port map(deta_integer => deta_integer(i,j), dphi_integer => dphi_integer(i,j),
                        cosh_deta_vector => cosh_deta_vector(i,j), cos_dphi_vector => cos_dphi_vector(i,j)
                    );
            end generate cosh_deta_cos_dphi_sel_i;
        end generate l2;
    end generate l1;

end architecture rtl;
