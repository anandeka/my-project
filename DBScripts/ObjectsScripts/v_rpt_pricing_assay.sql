create or replace view v_rpt_pricing_assay as
select asm.ash_id,
       pqca.element_id,
       (case
         when sum(asm.dry_weight) = 0 then
          0
         else
          (sum(asm.dry_weight * pqca.typical) / sum(asm.dry_weight))
       end) typical,
       pqca.unit_of_measure,
       rm.ratio_name as deductible_content_uom,
       (sum(asm.dry_weight)/sum(asm.net_weight))*100 dry_wet_ratio
  from asm_assay_sublot_mapping    asm,
       rm_ratio_master             rm,
       pqca_pq_chemical_attributes pqca
 where asm.asm_id = pqca.asm_id
   and pqca.unit_of_measure = rm.ratio_id
   and asm.is_active = 'Y'
   and pqca.is_active = 'Y'
   and nvl(pqca.is_deductible, 'N') = 'N'
 group by asm.ash_id,
          pqca.element_id,
          pqca.unit_of_measure,
          rm.ratio_name
/