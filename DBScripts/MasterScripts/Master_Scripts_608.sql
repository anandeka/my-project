SET define off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      DELETE FROM ARF_ACTION_REF_NUMBER_FORMAT ARF WHERE ARF.PREFIX IN ('DFT-PFI-');
   END LOOP;
END;

commit;

SET define off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      Insert into ARF_ACTION_REF_NUMBER_FORMAT
       (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
        MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED, SEQ_NAME)
     Values
       ('ARF-DFT-PFI-' || cc.corporate_id , 'DFTPFIRefNo', cc.corporate_id, 'DFT-PFI-', 1, 
        0, '-' || cc.corporate_id, NULL, 'N', 'SEQAXM_DFTPFI_' || cc.corporate_id);
   END LOOP;
END;

SET define off;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      DELETE FROM ARFM_ACTION_REF_NO_MAPPING ARFM WHERE ARFM.ACTION_ID = 'CREATE_DFT_PFI';
   END LOOP;
END;

commit;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      Insert into ARFM_ACTION_REF_NO_MAPPING
       (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
     Values
       ('ARFM-DFT-PFI-' || cc.corporate_id, cc.corporate_id, 'CREATE_DFT_PFI', 'DFTPFIRefNo', 'N');
   END LOOP;
END;

BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
      UPDATE ERC_EXTERNAL_REF_NO_CONFIG ERC SET ERC.SUFFIX='-' || cc.corporate_id, ERC.SEQ_NAME='SEQERC_DFTPFI_' || cc.corporate_id WHERE ERC.EXTERNAL_REF_NO_KEY='CREATE_DFT_PFI' AND ERC.CORPORATE_ID = cc.corporate_id;
   END LOOP;
END;

commit;
