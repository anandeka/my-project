
DECLARE
-- get all the GMR sublots where element count is not same as that of the number of elements in the sublot
   CURSOR wns_details
   IS
      SELECT t.gmr_ref_no, t.asm_id, t.elementscount, t.maxorder
        FROM (SELECT   gmr.gmr_ref_no, asm.asm_id, COUNT (*) elementscount,
                       MAX (pqca.ordering) maxorder
                  FROM ash_assay_header ash,
                       asm_assay_sublot_mapping asm,
                       pqca_pq_chemical_attributes pqca,
                       gmr_goods_movement_record gmr
                 WHERE ash.ash_id = asm.ash_id
                   AND asm.asm_id = pqca.asm_id
                   AND ash.is_active = 'Y'
                   AND gmr.internal_gmr_ref_no = ash.internal_gmr_ref_no
                   GROUP BY gmr.gmr_ref_no, asm.asm_id) t,
             gmr_goods_movement_record gmr
       WHERE t.elementscount != t.maxorder AND gmr.gmr_ref_no = t.gmr_ref_no;

   elementcount     NUMBER;
   correctedcount   NUMBER;
BEGIN
   correctedcount := 0;

-- for each WmS Sublot with ordering issue, change the order
   FOR wns IN wns_details
   LOOP
      elementcount := 0;
      DBMS_OUTPUT.put_line ('GMR -- ' || wns.gmr_ref_no);

-- for each elements of the sublot change the order
      FOR elements IN (SELECT pqca.pqca_id, pqca.element_id, pqca.ordering
                         FROM pqca_pq_chemical_attributes pqca
                        WHERE pqca.asm_id = wns.asm_id)
      LOOP
         elementcount := elementcount + 1;

         UPDATE pqca_pq_chemical_attributes pqca
            SET pqca.ordering = elementcount
          WHERE pqca.pqca_id = elements.pqca_id;

         DBMS_OUTPUT.put_line (   'Data updated'
                               || elements.pqca_id
                               || ' Count '
                               || elementcount
                              );
      END LOOP;

      correctedcount := correctedcount + 1;
   END LOOP;

   DBMS_OUTPUT.put_line ('Corrected Count :: ' || correctedcount);
END;
/