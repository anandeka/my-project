-- updating pqcq where isDiductible is null

UPDATE pqca_pq_chemical_attributes pqca
   SET pqca.is_deductible = 'N'
 WHERE pqca.pqca_id IN (
          SELECT PQCA1.PQCA_ID
            FROM ash_assay_header ash,
                 asm_assay_sublot_mapping asm,
                 pqca_pq_chemical_attributes pqca1
           WHERE ash.ash_id = asm.ash_id
             AND asm.asm_id = pqca1.asm_id
            and PQCA1.IS_DEDUCTIBLE is null)