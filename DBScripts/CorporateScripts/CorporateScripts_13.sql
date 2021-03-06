Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-API-1', 'API_KEY_1', 'LDE', 'API-', 0, 
    0, '-LDE', 1, 'N');
    
Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-API-2', 'API_KEY_2', 'EKA', 'API-', 0, 
    0, '-EKA', 1, 'N');
      
Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-API-1', 'LDE', 'CREATE_API', 'API_KEY_1', 'N');
   
Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-API-2', 'EKA', 'CREATE_API', 'API_KEY_2', 'N');
   
Insert into CDC_CORPORATE_DOC_CONFIG
   (DOC_TEMPLATE_ID, CORPORATE_ID, DOC_ID, DOC_TEMPLATE_NAME, DOC_TEMPLATE_NAME_DE, 
    DOC_TEMPLATE_NAME_ES, DOC_PRINT_NAME, DOC_PRINT_NAME_DE, DOC_PRINT_NAME_ES, DOC_RPT_FILE_NAME, 
    IS_ACTIVE, DOC_AUTO_GENERATE)
 Values
   ('CDC-API-1', 'LDE', 'CREATE_API', 'Advance', NULL, 
    NULL, NULL, NULL, NULL, 'AdvancePaymentDocument.rpt', 
    'Y', 'Y');
    
Insert into CDC_CORPORATE_DOC_CONFIG
   (DOC_TEMPLATE_ID, CORPORATE_ID, DOC_ID, DOC_TEMPLATE_NAME, DOC_TEMPLATE_NAME_DE, 
    DOC_TEMPLATE_NAME_ES, DOC_PRINT_NAME, DOC_PRINT_NAME_DE, DOC_PRINT_NAME_ES, DOC_RPT_FILE_NAME, 
    IS_ACTIVE, DOC_AUTO_GENERATE)
 Values
   ('CDC-API-2', 'EKA', 'CREATE_API', 'Advance', NULL, 
    NULL, NULL, NULL, NULL, 'AdvancePaymentDocument.rpt', 
    'Y', 'Y');
