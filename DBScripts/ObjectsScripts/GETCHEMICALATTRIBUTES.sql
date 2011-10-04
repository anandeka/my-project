CREATE OR REPLACE FUNCTION GETCHEMICALATTRIBUTES (p_ashid VARCHAR2)
   RETURN VARCHAR2
IS
   CURSOR cr_chemattr
   IS
      SELECT (   aml.attribute_name
              || ' :'
              || pqca.min_value
              || ' - '
              || pqca.max_value
              || ' '
              || rm.ratio_name
              || ' '
              || (CASE
                     WHEN pqca.rejection IS NOT NULL
                        THEN ' Rejection: ' || pqca.rejection
                  END
                 )
             ) AS chem_attr
        FROM pqca_pq_chemical_attributes pqca,
             aml_attribute_master_list aml,
             rm_ratio_master rm,
             asm_assay_sublot_mapping asm
       WHERE asm.asm_id = pqca.asm_id
         AND pqca.element_id = aml.attribute_id
         AND pqca.unit_of_measure = rm.ratio_id
         AND PQCA.IS_ACTIVE = 'Y'
         AND asm.ash_id = p_ashid;

   qualitydescription   VARCHAR2 (4000) := '';
BEGIN
   FOR chem_rec IN cr_chemattr
   LOOP
      qualitydescription :=
           qualitydescription || ' ' || chem_rec.chem_attr || ' ' || CHR (10);
   END LOOP;

   RETURN qualitydescription;
END;
/
