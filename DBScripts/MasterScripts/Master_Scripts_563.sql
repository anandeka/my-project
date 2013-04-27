
DECLARE
   fetchqry1   CLOB
      := 'INSERT INTO as_assay_child_d
            (lot_ref_no, sublotordering, elementordering, net_weight,
             dry_weight, is_deductible, is_elem_for_pricing,
             net_weight_unit_name, element_name, assay_value, assay_uom,
             internal_doc_ref_no)
   SELECT DISTINCT  case 
                    when ASH.IS_SUBLOTS_AS_STOCK=''N''
                        then ASM.SUB_LOT_NO 
                        else asm.sublot_ref_no 
                        end lot_ref_no,
                   asm.ordering AS sublotordering,
                   pqca.ordering AS elementordering,
                   (CASE
                       WHEN (ash.assay_type) NOT IN
                              (''Provisional Assay'',
                               ''Secondary Provisional Assay'')
                          THEN (asm.dry_weight)
                       ELSE (asm.net_weight)
                    END
                   ) AS net_weight,
                   asm.dry_weight AS dry_weight,
                   pqca.is_deductible AS is_deductible,
                   pqca.is_elem_for_pricing AS is_elem_for_pricing,
                   qum.qty_unit AS net_weight_unit_name,
                   aml.attribute_name AS element_name,
                   pqca.typical AS assay_value, rm.ratio_name AS assay_uom, ?
              FROM asm_assay_sublot_mapping asm,
                   ash_assay_header ash,
                   qum_quantity_unit_master qum,
                   rm_ratio_master rm,
                   pqca_pq_chemical_attributes pqca,
                   aml_attribute_master_list aml
             WHERE asm.net_weight_unit = qum.qty_unit_id
               AND asm.ash_id = ash.ash_id
               AND asm.asm_id = pqca.asm_id
               AND pqca.unit_of_measure = rm.ratio_id
               AND pqca.element_id = aml.attribute_id
               AND asm.ash_id = ?
               AND pqca.element_id IN (?)
          ORDER BY asm.ordering, pqca.ordering';
BEGIN
   UPDATE dgm_document_generation_master
      SET fetch_query = fetchqry1
    WHERE dgm_id = 'DGM-ASC' AND activity_id = 'CREATE_ASSAY';
END;