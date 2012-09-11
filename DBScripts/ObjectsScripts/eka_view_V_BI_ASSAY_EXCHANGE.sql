create or replace view v_assay_excahnge as
select pcm.internal_contract_ref_no,
       pcar.element_id
  from pcm_physical_contract_main pcm,
       pcar_pc_assaying_rules     pcar
 where pcm.internal_contract_ref_no = pcar.internal_contract_ref_no
   and pcm.is_active = 'Y'
   and pcar.is_active = 'Y'
   and pcar.final_assay_basis_id = 'Assay Exchange'
 group by pcm.internal_contract_ref_no,
          pcar.element_id
