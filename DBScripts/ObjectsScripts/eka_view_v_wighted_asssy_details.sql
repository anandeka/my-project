create or replace view v_wighted_asssy_details as
select ash.internal_grd_ref_no,
       ash.internal_gmr_ref_no,
       ash.ash_id,
       ash.assay_type,
       sum(asm.dry_weight) dry_weight,
       sum(asm.net_weight) net_weight,
       asm.net_weight_unit,
       pqca.element_id,
       rm.ratio_id,
       rm.ratio_name,
       pqca.is_deductible,
       pqca.is_elem_for_pricing,
       sum(asm.dry_weight * pqca.typical) / sum(asm.dry_weight) avg_typical
  from ash_assay_header            ash,
       asm_assay_sublot_mapping    asm,
       pqca_pq_chemical_attributes pqca,
       rm_ratio_master             rm
 where ash.ash_id = asm.ash_id
   and asm.asm_id = pqca.asm_id
   and pqca.unit_of_measure = ratio_id
   and asm.is_active = 'Y'
   and ash.is_active = 'Y'
   and rm.is_active = 'Y'
   and pqca.is_active = 'Y'
    group by ash.internal_grd_ref_no,
          ash.internal_gmr_ref_no,
          pqca.element_id,
          ash.ash_id,
          ash.assay_type,
          asm.net_weight_unit,
          pqca.is_elem_for_pricing,
          rm.ratio_id,
           rm.ratio_name,
           pqca.is_deductible
/