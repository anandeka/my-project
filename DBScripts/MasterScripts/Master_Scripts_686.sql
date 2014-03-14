-- Create GMR Link Action Scripts 

INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable,
             is_ref_no_gen_applicable, is_event_publish_applicable,
             is_continuous_middle_no_req, is_required_for_eodeom,
             is_activity_log_applicable, is_recent_record_applicable,
             navigation_url
            )
     VALUES ('gmrLinking', 'GMR', 'GMR Linking ', 'Y',
             NULL, 'N',
             NULL, 'N',
             'N', 'Y',
             'Y', 'Y',
             NULL
            );


INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('gmrLinkingRefNo', 'Gmr Linking Ref No',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );


INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('gmrLinking', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted,
                   seq_name
                  )
           VALUES ('ARF-LINK-' || cc.corporate_id, 'gmrLinkingRefNo',
                   cc.corporate_id, 'LINK-', 1,
                   0, '-' || cc.corporate_id, 1, 'N',
                   ''
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('ARFM-LINK-' || cc.corporate_id, cc.corporate_id,
                   'gmrLinking', 'gmrLinkingRefNo', 'N'
                  );
   END LOOP;
END;

-- ARF Sequence Scripts 

DECLARE
   CURSOR blen_create_id
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_drf IN blen_create_id
   LOOP
      EXECUTE IMMEDIATE    'CREATE SEQUENCE SEQAXM_LINK_'
                        || sl_drf.corporate_id
                        || ' START WITH 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE NOCACHE NOORDER';

      UPDATE arf_action_ref_number_format arf
         SET arf.seq_name = 'SEQAXM_LINK_' || sl_drf.corporate_id
       WHERE arf.action_key_id = 'gmrLinkingRefNo'
         AND arf.corporate_id = sl_drf.corporate_id;
   END LOOP;

   COMMIT;
END;




-- Cancel GMR Link Action Scripts 

INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable,
             is_ref_no_gen_applicable, is_event_publish_applicable,
             is_continuous_middle_no_req, is_required_for_eodeom,
             is_activity_log_applicable, is_recent_record_applicable,
             navigation_url
            )
     VALUES ('gmrLinkingCancel', 'GMR', 'Cancel GMR Linking ', 'Y',
             NULL, 'N',
             NULL, 'N',
             'N', 'Y',
             'Y', 'Y',
             NULL
            );


INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('gmrLinkCanRefNo', 'Gmr Linking Ref No',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );


INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('gmrLinkingCancel', 'N', 'N',
             'action_date', 'N', NULL,
             NULL, NULL, 'N'
            );

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted,
                   seq_name
                  )
           VALUES ('ARF-CANLINK-' || cc.corporate_id, 'gmrLinkCanRefNo',
                   cc.corporate_id, 'CANLINK-', 1,
                   0, '-' || cc.corporate_id, 1, 'N',
                   ''
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('ARFM-CANLINK-' || cc.corporate_id, cc.corporate_id,
                   'gmrLinkingCancel', 'gmrLinkCanRefNo', 'N'
                  );
   END LOOP;
END;

-- ARF Sequence Scripts 

DECLARE
   CURSOR blen_create_id
   IS
      (SELECT akc.corporate_id
         FROM ak_corporate akc
        WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N');
BEGIN
   FOR sl_drf IN blen_create_id
   LOOP
      EXECUTE IMMEDIATE    'CREATE SEQUENCE SEQAXM_CANLINK_'
                        || sl_drf.corporate_id
                        || ' START WITH 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE NOCACHE NOORDER';

      UPDATE arf_action_ref_number_format arf
         SET arf.seq_name = 'SEQAXM_CANLINK_' || sl_drf.corporate_id
       WHERE arf.action_key_id = 'gmrLinkCanRefNo'
         AND arf.corporate_id = sl_drf.corporate_id;
   END LOOP;

   COMMIT;
END;

