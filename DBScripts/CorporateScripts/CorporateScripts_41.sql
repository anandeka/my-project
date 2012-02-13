
Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('landingDetail', '&corpId', 'Y', 'Y', 'select count(*) as countRow 
from SDD_D sdd
where SDD.INTERNAL_DOC_REF_NO = ?', 
    '/metals/listingOfGMR.do?method=loadListOfGMR&gridId=LOG');


Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFM-LD-&corpId, '&corpId', 'landingDetail', 'LD_KEY_1', 'N');


Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRF-LD-&corpId', 'LD_KEY_1', '&corpId', 'LD-', 0, 
    10, '-&corpId', NULL, 'N');