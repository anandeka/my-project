BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      INSERT INTO arf_action_ref_number_format
                  (action_ref_number_format_id, action_key_id, corporate_id,
                   prefix, middle_no_start_value, middle_no_last_used_value,
                   suffix, VERSION, is_deleted
                  )
           VALUES ('ARF-RMM-'||cc.corporate_id, 'RMMRefNo', cc.corporate_id,
                   'RMM-', 1, 1,
                   '-'||cc.corporate_id, 1, 'N'
                  );

      INSERT INTO arfm_action_ref_no_mapping
                  (action_ref_no_mapping_id, corporate_id, action_id,
                   action_key_id, is_deleted
                  )
           VALUES ('ARFM-RMM-'||cc.corporate_id, cc.corporate_id, 'RECORD_MINING_OUTPUT',
                   'RMMRefNo', 'N'
                  );
   END LOOP;
END;