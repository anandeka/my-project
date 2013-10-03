
set define off;
DECLARE
   CURSOR samplinglabel_dc
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_dc IN samplinglabel_dc
   LOOP
      INSERT INTO dc_document_configuration
                  (activity_id, corporate_id, is_generate_doc_reqd,
                   is_upload_doc_reqd,
                   doc_validation_query,
                   navigation
                  )
           VALUES ('SL_DOC', sl_dc.corporate_id, 'Y',
                   'N',
                   'select count(*) as countRow 
                        from ASD_ASSAY_SAMPLE_D ASD
                        where ASD.INTERNAL_DOC_REF_NO = ?',
                   '/metals/listingOfGMR.do?method=loadListOfGMR&gridId=LOG'
                  );
   END LOOP;

   COMMIT;
END;

---------------------------------------------------------------------------------


DECLARE
   CURSOR samplinglabel_cdc
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_cdc IN samplinglabel_cdc
   LOOP
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id,
                   doc_template_name, doc_template_name_de,
                   doc_template_name_es, doc_print_name, doc_print_name_de,
                   doc_print_name_es, doc_rpt_file_name, is_active,
                   doc_auto_generate
                  )
           VALUES ('CDC_SL', sl_cdc.corporate_id, 'SL_DOC',
                   'Sampling Label Document', NULL,
                   NULL, 'DOC', NULL,
                   NULL, 'AssaySampleMain.rpt', 'Y',
                   'Y'
                  );
   END LOOP;

   COMMIT;
END;

------------------------------------------------------------------------------------

DECLARE
     CURSOR samplinglabel_drfm   IS
        (SELECT akc.corporate_id
           FROM ak_corporate akc
          WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
  BEGIN
     FOR sl_drfm IN samplinglabel_drfm
     LOOP
        INSERT INTO DRFM_DOC_REF_NO_MAPPING
                    (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED
                    )
             VALUES ('DRFM-SL-'|| sl_drfm.corporate_id, sl_drfm.corporate_id, 'SL_DOC', 'DKM-SL', 'N');
     END LOOP;
  
     COMMIT;
END;

------------------------------------------------------------------------------------------

DECLARE
   CURSOR samplinglabel_drf
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_drf IN samplinglabel_drf
   LOOP
      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted,
                   seq_name
                  )
           VALUES ('DRF-SL-' || sl_drf.corporate_id, 'DKM-SL',
                   sl_drf.corporate_id, 'SL-', 0,
                   0, '-' || sl_drf.corporate_id, NULL, 'N',
                   'SEQDOC_SL'
                  );
   END LOOP;

   COMMIT;
END;

--------------------------------------------------------------------------------------------

DECLARE
   CURSOR samplinglabel_seq
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_seq IN samplinglabel_seq
   LOOP
     BEGIN
     EXECUTE IMMEDIATE 'DROP SEQUENCE SEQDOC_SL_' || sl_seq.corporate_id;
     EXCEPTION WHEN OTHERS THEN
      NULL;
     END;
      EXECUTE IMMEDIATE    'CREATE SEQUENCE SEQDOC_SL_'
                        || sl_seq.corporate_id
                        || ' START WITH 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE NOCACHE NOORDER';
   END LOOP;

   COMMIT;
END;
