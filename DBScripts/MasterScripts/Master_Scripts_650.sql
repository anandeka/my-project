INSERT INTO axm_action_master
            (action_id, entity_id,
             action_name, is_new_gmr_applicable, action_desc,
             is_generate_doc_applicable, is_ref_no_gen_applicable,
             is_event_publish_applicable, is_continuous_middle_no_req,
             is_required_for_eodeom, is_activity_log_applicable,
             is_recent_record_applicable, navigation_url
            )
     VALUES ('HOLIDAY_PRICE_FIXATION', 'HolidayHandling',
             'Holiday Price Fixation', 'N', NULL,
             'N', NULL,
             'N', 'N',
             'N', 'Y',
             'Y', NULL
            );


INSERT INTO akm_action_ref_key_master
            (action_key_id, action_key_desc,
             validation_query
            )
     VALUES ('HHPriceFix', 'Holiday Price Fixation',
             'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id'
            );



INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('HOLIDAY_PRICE_FIXATION', 'N', 'N',
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
           VALUES ('ARF-HH-' || cc.corporate_id, 'HHPriceFix',
                   cc.corporate_id, 'HH-', 1,
                   0, '-' || cc.corporate_id, 1, 'N',
                   ''
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('ARFM-HH-' || cc.corporate_id, cc.corporate_id,
                   'HOLIDAY_PRICE_FIXATION', 'HHPriceFix', 'N'
                  );
   END LOOP;
END;
/