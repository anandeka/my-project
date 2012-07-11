UPDATE asm_assay_sublot_mapping asm
   SET asm.ordering = 1
 WHERE asm.ash_id IN (
          SELECT ash.ash_id
            FROM ash_assay_header ash, asm_assay_sublot_mapping asm
           WHERE ash.ash_id = asm.ash_id
             AND ash.is_active = 'Y'
             AND ash.is_sublots_as_stock = 'Y'
             AND ash.assay_type = 'Weighing and Sampling Assay'
             AND asm.ordering > 1
             AND ash.internal_gmr_ref_no = 'GMR-348')