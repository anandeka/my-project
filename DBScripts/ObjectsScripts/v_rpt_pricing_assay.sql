create or replace view v_rpt_pricing_assay as
select asm.ash_id,
       pqca.element_id,
       (case
         when sum(asm.dry_weight) = 0 then
          0
         else
          (sum(asm.dry_weight * pqca.typical) / sum(asm.dry_weight))
       end) typical,
       (case when rm.ratio_name = '%' then
       round((case
         when sum(asm.dry_weight) = 0 then
          0
         else
          (sum(asm.dry_weight * pqca.typical) / sum(asm.dry_weight))
       end)/100,8) else
       round((case
         when sum(asm.dry_weight) = 0 then
          0
         else
          (sum(asm.dry_weight * pqca.typical) / sum(asm.dry_weight))
       end),8) end )typical_ratio,
       pqca.unit_of_measure,
       rm.ratio_name as deductible_content_uom
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