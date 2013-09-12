Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOG_QPC', 'LOG', 'QP Confirmation Documnet', 14, 2, 
    NULL, 'function(){generateQPConfirmationDocument();}', NULL, '102', NULL);


INSERT INTO dm_document_master
            (doc_id, doc_name, display_order, VERSION, is_active, is_deleted,
             activity_id, is_continuous_middle_no_req
            )
     VALUES ('QPC_DOC', 'Qp Confirmation', 61, NULL, 'Y', 'N',
             NULL, 'Y'
            );



INSERT INTO dkm_doc_ref_key_master
            (doc_key_id, doc_key_desc,
             validation_query
            )
     VALUES ('DKM-QPC', 'Qp Confirmation',
             'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
            );

SET define Off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO dc_document_configuration
                  (activity_id, corporate_id, is_generate_doc_reqd,
                   is_upload_doc_reqd,
                   doc_validation_query,
                   navigation
                  )
           VALUES ('QPC_DOC', cc.corporate_id, 'Y',
                   'N',
                   'select count(*) as countRow 
                        from GMRQP_QUOTA_PERIOD_D GMRQP
                        where GMRQP.INTERNAL_DOC_REF_NO = ?',
                   '/metals/listingOfGMR.do?method=loadListOfGMR&gridId=LOG'
                  );
   END LOOP;
END;

SET define on;
SET define off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted,
                   seq_name
                  )
           VALUES ('DRF-QPC-' || cc.corporate_id, 'DKM-QPC',
                   cc.corporate_id, 'QPC', 0,
                   0, '-' || cc.corporate_id, NULL, 'N',
                   ''
                  );

      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id,
                   doc_id, doc_key_id, is_deleted
                  )
           VALUES ('DRFM-QPC-' || cc.corporate_id, cc.corporate_id,
                   'QPC_DOC', 'DKM-QPC', 'N'
                  );
   END LOOP;
END;

SET define on;
SET define off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id,
                   doc_template_name, doc_template_name_de,
                   doc_template_name_es, doc_print_name, doc_print_name_de,
                   doc_print_name_es, doc_rpt_file_name, is_active,
                   doc_auto_generate
                  )
           VALUES ('CDC-QPC' || cc.corporate_id, cc.corporate_id, 'QPC_DOC',
                   'Qp Confirmation Document', NULL,
                   NULL, NULL, NULL,
                   NULL, 'QpConfirmationDocument.rpt', 'Y',
                   'Y'
                  );
   END LOOP;
END;

SET define on;

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-QPC', 'QPC_DOC', 'Qp Confirmation ', 'QPC_DOC', 1, 
    '{call GENERATE_QUOTA_PERIOD_DOCUMENT(?,?,?,?)}', 'N');