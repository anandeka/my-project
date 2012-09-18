---------------------------------------------------------------------
---ADDED FOR RELEASEORDER DOCUMENT
---------------------------------------------------------------------


Insert into DRFM_DOC_REF_NO_MAPPING
   (DOC_REF_NO_MAPPING_ID, CORPORATE_ID, DOC_ID, DOC_KEY_ID, IS_DELETED)
 Values
   ('DRFMRO-1', 'BLD', 'releaseOrder', 'DKMRO-1', 'N');


Insert into DRF_DOC_REF_NUMBER_FORMAT
   (DOC_REF_NUMBER_FORMAT_ID, DOC_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('DRFRO-1', 'DKMRO-1', 'BLD', 'RO-', 0, 
    0, '-BLD', NULL, 'N');