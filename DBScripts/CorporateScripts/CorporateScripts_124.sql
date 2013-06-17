/* Formatted on 2013/06/17 18:56 (Formatter Plus v4.8.8) */
-- Bulk Pricing Document.
SET define off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
-- Pledge GMR
      UPDATE drf_doc_ref_number_format drf
         SET drf.prefix = 'BPFDPG-'
       WHERE drf.doc_key_id = 'BFPD-PLGMR'
         AND drf.corporate_id = cc.corporate_id;
   END LOOP;
END;
/