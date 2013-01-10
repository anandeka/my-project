UPDATE asm_assay_sublot_mapping asm
   SET asm.dry_wet_qty_ratio = ROUND((asm.dry_weight / asm.net_weight) * 100,5)
 WHERE asm.ash_id IN (
          SELECT ash.ash_id
            FROM ash_assay_header ash, asm_assay_sublot_mapping asm1
           WHERE asm1.ash_id = ash.ash_id);