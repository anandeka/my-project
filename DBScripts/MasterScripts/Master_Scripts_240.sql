Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('CREATE_DC', 'Debit Credit note', 48, NULL, 'Y', 
    'N', NULL);

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DC_KEY_1', 'Debit Credit Note', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DC_KEY_2', 'Debit Credit Note', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

---SI

update DC_DOCUMENT_CONFIGURATION dc set DC.IS_GENERATE_DOC_REQD = 'Y' where DC.ACTIVITY_ID = 'CREATE_SI';



Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('CREATE_SI', 'Service Invoice', 48, NULL, 'Y', 
    'N', NULL);

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('SI_KEY_1', 'Service Invoice', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('SI_KEY_2', 'Service Invoice', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');