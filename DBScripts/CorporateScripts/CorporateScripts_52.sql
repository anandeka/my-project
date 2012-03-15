Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-GEPD-1', 'GEPD_KEY_1', 'LDE', 'GEPD-', 0, 
    0, '-LDE', 1, 'N');
    
Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-GEPD-2', 'GEPD_KEY_2', 'EKA', 'GEPD-', 0, 
    0, '-EKA', 1, 'N');
      
Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-GEPD-1', 'LDE', 'pledgeTransfer', 'GEPD_KEY_1', 'N');
   
Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-GEPD-2', 'EKA', 'pledgeTransfer', 'GEPD_KEY_2', 'N');
   
Insert into CDC_CORPORATE_DOC_CONFIG
   (DOC_TEMPLATE_ID, CORPORATE_ID, DOC_ID, DOC_TEMPLATE_NAME, DOC_TEMPLATE_NAME_DE, 
    DOC_TEMPLATE_NAME_ES, DOC_PRINT_NAME, DOC_PRINT_NAME_DE, DOC_PRINT_NAME_ES, DOC_RPT_FILE_NAME, 
    IS_ACTIVE, DOC_AUTO_GENERATE)
 Values
   ('CDC-GEPD-1', 'LDE', 'pledgeTransfer', 'Pledge Letter', NULL, 
    NULL, NULL, NULL, NULL, 'PledgeLetterFormat.rpt', 
    'Y', 'Y');
    
Insert into CDC_CORPORATE_DOC_CONFIG
   (DOC_TEMPLATE_ID, CORPORATE_ID, DOC_ID, DOC_TEMPLATE_NAME, DOC_TEMPLATE_NAME_DE, 
    DOC_TEMPLATE_NAME_ES, DOC_PRINT_NAME, DOC_PRINT_NAME_DE, DOC_PRINT_NAME_ES, DOC_RPT_FILE_NAME, 
    IS_ACTIVE, DOC_AUTO_GENERATE)
 Values
   ('CDC-GEPD-2', 'EKA', 'pledgeTransfer', 'Pledge Letter', NULL, 
    NULL, NULL, NULL, NULL, 'PledgeLetterFormat.rpt', 
    'Y', 'Y');


Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('pledgeTransfer', 'LDE', 'Y', 'Y', 'select count(*) as countRow
from GEPD_D gepd
where gepd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListofPledgeMaterial.action?gridId=PM_LIST');


Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('pledgeTransfer', 'EKA', 'Y', 'Y', 'select count(*) as countRow
from GEPD_D gepd
where gepd.INTERNAL_DOC_REF_NO = ?',
    '/metals/loadListofPledgeMaterial.action?gridId=PM_LIST');