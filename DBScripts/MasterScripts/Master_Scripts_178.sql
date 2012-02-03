
delete from DRF_DOC_REF_NUMBER_FORMAT where DOC_REF_NUMBER_FORMAT_ID in ('DRF-PFD-1','DRF-PFD-2');
delete from DRFM_DOC_REF_NO_MAPPING  where DOC_REF_NO_MAPPING_ID in ('DRFM-PFD-1','DRFM-PFD-2');
delete from CDC_CORPORATE_DOC_CONFIG  where DOC_TEMPLATE_ID in ('CDC-PFD-1','CDC-PFD-2');
delete from DC_DOCUMENT_CONFIGURATION  where ACTIVITY_ID in ('CREATE_PFD');

delete from ADM_ACTION_DOCUMENT_MASTER where doc_id='CREATE_PFD';
delete from DKM_DOC_REF_KEY_MASTER where DOC_KEY_ID in ('PFD_KEY_1','PFD_KEY_2');
delete from DGM_DOCUMENT_GENERATION_MASTER where dgm_id in ('DGM-PFD-1','DGM-PFD-2');
delete from DM_DOCUMENT_MASTER where doc_id='CREATE_PFD';

Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('CREATE_PRICE_FIXATION', 'Price Fixation', 1, NULL, 'Y', 
    'N', NULL);

Insert into ADM_ACTION_DOCUMENT_MASTER
   (ADM_ID, ACTION_ID, DOC_ID, IS_DELETED)
 Values
   ('ADM-PFD-1', 'CREATE_PRICE_FIXATION', 'CREATE_PRICE_FIXATION', 'N');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('PFD_KEY_1', 'Price Fixation', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('PFD_KEY_2', 'Price Fixation', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-PFD-1', 'CREATE_PRICE_FIXATION', 'Price Fixation', 'CREATE_PRICE_FIXATION', 1, 
    '{call generatePriceFixationDocument(?,?,?)}','N');
    
