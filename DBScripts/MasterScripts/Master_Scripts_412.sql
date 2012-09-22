Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('CREATE_MINING_PRICE_FIXATION', 'BLD', 'Y', 'Y', 'select count(*) as countRow
from PFD_D pfd
where pfd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfMiningDeliveryItems.action?gridId=MLODI');
Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('CREATE_MINING_PRICE_FIXATION', 'EKA', 'Y', 'Y', 'select count(*) as countRow
from PFD_D pfd
where pfd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfMiningDeliveryItems.action?gridId=MLODI');
Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('CREATE_MINING_PRICE_FIXATION', 'LDE', 'Y', 'Y', 'select count(*) as countRow
from PFD_D pfd
where pfd.INTERNAL_DOC_REF_NO = ?', 
    '/metals/loadListOfMiningDeliveryItems.action?gridId=MLODI');