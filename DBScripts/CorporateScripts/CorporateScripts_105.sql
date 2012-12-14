
BEGIN
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP

        Insert into DRF_DOC_REF_NUMBER_FORMAT
           (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
            MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
         Values
           ('DRF-OCI-' || cc.corporate_id, 'OCI_KEY_1', cc.corporate_id, 'OCI-', 0, 
            0, '-' || cc.corporate_id, 1, 'N');

        Insert into DRFM_DOC_REF_NO_MAPPING
           (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
         Values
           ('DRFM-OCI-' || cc.corporate_id, cc.corporate_id, 'CREATE_OCI', 'OCI_KEY_1', 'N');

        Insert into CDC_CORPORATE_DOC_CONFIG
           (DOC_TEMPLATE_ID, CORPORATE_ID, DOC_ID, DOC_TEMPLATE_NAME, DOC_TEMPLATE_NAME_DE, 
            DOC_TEMPLATE_NAME_ES, DOC_PRINT_NAME, DOC_PRINT_NAME_DE, DOC_PRINT_NAME_ES, DOC_RPT_FILE_NAME, 
            IS_ACTIVE, DOC_AUTO_GENERATE)
         Values
           ('CDC-OCI-' || cc.corporate_id, cc.corporate_id, 'CREATE_OCI', 'Output Charge Invoice', NULL, 
            NULL, NULL, NULL, NULL, 'OCInvoiceDocument.rpt', 
            'Y', 'Y');

        Insert into DC_DOCUMENT_CONFIGURATION
           (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
            NAVIGATION)
         Values
           ('CREATE_OCI', cc.corporate_id, 'Y', 'Y', 'select count(*) as countRow
                from IS_D isd
                where isd.INTERNAL_DOC_REF_NO = ?', 
                    '/metals/loadListOfInvoice.action?gridId=LOII_TEST');
    END LOOP;
END;
/