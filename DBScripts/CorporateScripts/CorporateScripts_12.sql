Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('updateStockDutyCustomTax', 'LDE', 'N', 'Y', 'select count(*) as countRow 
from SDD_D sdd
where SDD.INTERNAL_DOC_REF_NO = ?', 
    '/metals/listingOfStocks.do?method=loadListOfStocks&gridId=LOS');
Insert into DC_DOCUMENT_CONFIGURATION
   (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD, DOC_VALIDATION_QUERY, 
    NAVIGATION)
 Values
   ('updateStockDutyCustomTax', 'EKA', 'N', 'Y', 'select count(*) as countRow 
from SDD_D sdd
where SDD.INTERNAL_DOC_REF_NO = ?', 
    '/metals/listingOfStocks.do?method=loadListOfStocks&gridId=LOS');