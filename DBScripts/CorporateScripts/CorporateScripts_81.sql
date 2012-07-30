DECLARE
count1 Number(10);
BEGIN

   count1 := 1;   
   delete from CDC_CORPORATE_DOC_CONFIG where doc_id IN ('CREATE_SI','CREATE_DC'); 
   delete from DRF_DOC_REF_NUMBER_FORMAT where DOC_KEY_ID IN ('SI_KEY_2','SI_KEY_1','DC_KEY_1','DC_KEY_2');
   delete from DRFM_DOC_REF_NO_MAPPING where doc_id IN ('CREATE_SI','CREATE_DC');
   
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
   /* Corporate Script for Service Invoice */
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id, doc_template_name,
                   doc_template_name_de, doc_template_name_es,
                   doc_print_name, doc_print_name_de, doc_print_name_es,
                   doc_rpt_file_name, is_active, doc_auto_generate
                  )
           VALUES ('CDC-SI-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_SI', 'Service',
                   NULL, NULL,
                   NULL, NULL, NULL,
                   'ServiceInvoice.rpt', 'Y', 'Y'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id, corporate_id,
                   prefix, middle_no_start_value, middle_no_last_used_value,
                   suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-SI-'||TO_CHAR(count1), 'SI_KEY_2', cc.corporate_id,
                   'SI-', 0, 0,
                   '-' || cc.corporate_id, 1, 'N'
                  );

      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id, doc_id, doc_key_id,
                   is_deleted
                  )
           VALUES ('DRFM-SI-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_SI', 'SI_KEY_2',
                   'N'
                  );
    /* Corporate Script for Debit Credit Note */
      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id, doc_id, doc_key_id,
                   is_deleted
                  )
           VALUES ('DRFM-DC-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_DC', 'DC_KEY_2',
                   'N'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id, corporate_id,
                   prefix, middle_no_start_value, middle_no_last_used_value,
                   suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-DC-'||TO_CHAR(count1), 'DC_KEY_2', cc.corporate_id,
                   'DC-', 0, 0,
                   '-' || cc.corporate_id, 1, 'N'
                  );

      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id, doc_template_name,
                   doc_template_name_de, doc_template_name_es,
                   doc_print_name, doc_print_name_de, doc_print_name_es,
                   doc_rpt_file_name, is_active, doc_auto_generate
                  )
           VALUES ('CDC-DC-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_DC', 'DebitCredit',
                   NULL, NULL,
                   NULL, NULL, NULL,
                   'PurchaseDebitCreditNote.rpt', 'Y', 'Y'
                  );
                  
      count1 := count1 + 1;
       
   END LOOP;
   COMMIT;
END;