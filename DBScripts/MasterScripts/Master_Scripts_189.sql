Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('landingDetail', 'Landing Detail', 60, NULL, 'Y', 
    'N', NULL);

Insert into ADM_ACTION_DOCUMENT_MASTER
   (ADM_ID, ACTION_ID, DOC_ID, IS_DELETED)
 Values
   ('ADM-LD', 'landingDetail', 'landingDetail', 'N');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('LD_KEY_1', 'Landing Detail', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

