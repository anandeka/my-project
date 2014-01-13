UPDATE asm_assay_sublot_mapping asm
   SET asm.is_active = 'Y'
 WHERE exists (SELECT ash.ash_id
                   FROM ash_assay_header ash
                        --asm_assay_sublot_mapping asm_inner
                  WHERE ash.ash_id = asm.ash_id AND ASH.IS_ACTIVE='Y')
      and ASM.IS_ACTIVE is null;
commit;
UPDATE asm_assay_sublot_mapping asm
   SET asm.is_active = 'N'
 WHERE exists (SELECT ash.ash_id
                   FROM ash_assay_header ash
                        --asm_assay_sublot_mapping asm_inner
                  WHERE ash.ash_id = asm.ash_id AND ASH.IS_ACTIVE='N')
and ASM.IS_ACTIVE is null;                  
commit;