create or replace view v_rpt_assay_deductible as
select asm.ash_id,
       (sum((case
              when nvl(pqca.is_deductible, 'N') = 'Y' then
               pqca.typical * asm.net_weight
              else
               0
            end)) / sum(asm.net_weight)) deductible_content,
        (sum((case
              when nvl(pqca.is_deductible, 'N') = 'Y' then
               pqca.typical * asm.net_weight
              else
               0
            end)) / sum(asm.net_weight))/100 deductibile_ratio ,
       rm.ratio_name as deductible_content_uom
  from asm_assay_sublot_mapping    asm,
       rm_ratio_master             rm,
       pqca_pq_chemical_attributes pqca
 where asm.asm_id = pqca.asm_id
   and pqca.unit_of_measure = rm.ratio_id
   and asm.is_active = 'Y'
   and pqca.is_active = 'Y'
   and nvl(pqca.is_deductible, 'N') = 'Y'
   and asm.ash_id is not null
 group by asm.ash_id,
          rm.ratio_name
/