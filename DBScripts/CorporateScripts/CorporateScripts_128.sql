

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      UPDATE cdc_corporate_doc_config cdc
         SET cdc.doc_rpt_file_name = 'PurchaseDebitCreditNote.rpt'
       WHERE cdc.doc_id = 'CREATE_DFT_DC'
         AND cdc.corporate_id = cc.corporate_id;
   END LOOP;
END;