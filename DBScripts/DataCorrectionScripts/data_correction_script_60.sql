UPDATE asm_assay_sublot_mapping asm
   SET asm.is_active = 'Y'
 WHERE asm.ash_id IN (
                 SELECT ash.ash_id
                   FROM ash_assay_header ash,
                        asm_assay_sublot_mapping asm_inner
                  WHERE ash.ash_id = asm_inner.ash_id AND ASH.IS_ACTIVE='Y'
                  and ASM_INNER.IS_ACTIVE is null)