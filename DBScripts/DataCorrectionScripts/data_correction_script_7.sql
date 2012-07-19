
UPDATE asm_assay_sublot_mapping asm
   SET asm.dry_wet_qty_ratio = (asm.dry_weight / asm.net_weight) * 100
 WHERE asm.ash_id IN (
          SELECT ash.ash_id
            FROM ash_assay_header ash, asm_assay_sublot_mapping asm
           WHERE asm.ash_id = ash.ash_id
             AND asm.dry_weight IS NOT NULL
             AND asm.is_active = 'Y'
             AND ash.is_active = 'Y');