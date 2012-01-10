
Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-DFT-PI-&corpId', '&corpId', 'CREATE_DFT_PI', 'DFT-PI', 'N');

Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-DFT-PI-&corpId', 'DFT-PI', '&corpId', 'DFT-PI-', 0, 
    0, '-&corpId', 1, 'N');

    Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('CREATE_DFT_PI', '&corpId', 'Y', 'Y', 'select count(*) as countRow
from IS_D isd
where isd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfInvoiceDraft.action?gridId=LOID');

    Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-DFT-FI-&corpId', '&corpId', 'CREATE_DFT_FI', 'DFT-FI', 'N');

   Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-DFT-FI-&corpId', 'DFT-FI', '&corpId', 'DFT-FI-', 0, 
    0, '-&corpId', 1, 'N');

    

Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('DGM-DFT-FI', '&corpId', 'Y', 'Y', 'select count(*) as countRow
from IS_D isd
where isd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfInvoiceDraft.action?gridId=LOID');

    Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-DFI-&corpId', '&corpId', 'CREATE_DFT_DFI', 'DFT-DFI', 'N');

Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-DFT-DFI-&corpId', 'DFT-DFI', '&corpId', 'DFT-DFI-', 0, 
    0, '-&corpId', 1, 'N');

    

Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('CREATE_DFT_DFI', '&corpId', 'Y', 'Y', 'select count(*) as countRow
from IS_D isd
where isd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfInvoiceDraft.action?gridId=LOID');

Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DFT-API-&corpId', '&corpId', 'CREATE_DFT_API', 'DFT-API', 'N');

Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-DFT-API-&corpId', 'DFT-API', '&corpId', 'DFT-API-', 0, 
    0, '-&corpId', 1, 'N');

Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('CREATE_DFT_API', '&corpId', 'Y', 'Y', 'select count(*) as countRow
from API_D isd
where isd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfInvoiceDraft.action?gridId=LOID');


Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DFT-VAT-&corpId', '&corpId', 'CREATE_DFT_VAT', 'VAT_DFT_KEY', 'N');

Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-DFT-VAT-&corpId', 'VAT_DFT_KEY', '&corpId', 'DFT-VAT-', 0, 
    0, '-&corpId', 1, 'N');


    Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('CREATE_DFT_VAT', '&corpId', 'Y', 'Y', 'select count(*) as countRow
from VAT_D isd
where isd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfInvoiceDraft.action?gridId=LOID');

