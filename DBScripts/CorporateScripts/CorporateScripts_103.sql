
BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id,
                   corporate_id, prefix, middle_no_start_value,
                   middle_no_last_used_value, suffix, VERSION, is_deleted
                  )
           VALUES ('ARF-DSPA-' || cc.corporate_id, 'cancelSPARefNo',
                   cc.corporate_id, 'DSPA-', 1,
                   0, '-' || cc.corporate_id, 1, 'N'
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id,
                   action_id, action_key_id, is_deleted
                  )
           VALUES ('ARFM-DSPA-' || cc.corporate_id, cc.corporate_id,
                   'CANCEL_SECONDARY_PROV_ASSAY', 'cancelSPARefNo', 'N'
                  );

      INSERT INTO erc_external_ref_no_config
                  (corporate_id, external_ref_no_key, prefix,
                   middle_no_last_used_value, suffix
                  )
           VALUES (cc.corporate_id, 'CANCEL_SECONDARY_PROV_ASSAY', 'DSPA-',
                   0, '-' || cc.corporate_id
                  );
   END LOOP;
END;
/