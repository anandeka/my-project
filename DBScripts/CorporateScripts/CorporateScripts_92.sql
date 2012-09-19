---------------------------------------------------------------------
---ADDED TO SHOW SALES LANDING DOC TAB (ONLY DOC UPLOAD TAB WILL BE SHOWN)
---------------------------------------------------------------------

Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('salesLandingDetail', 'BLD', 'N', 'Y', 'select count(*) as countRow 
from SAD_D sad
where SAD.INTERNAL_DOC_REF_NO = ?', 
    '/metals/listingOfGMR.do?method=loadListOfGMR&gridId=LOG');