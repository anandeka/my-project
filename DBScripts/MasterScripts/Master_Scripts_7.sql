Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('FINAL_ASSAY', 'Assay', 'Final Assay', 'N', 'Final Assay', 
    'N');
 

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('FinalAssayRefNo', 'Final Assay', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-ASSAY-'||SEQ_ARF.nextval, 'FinalAssayRefNo', '&corporateId', 'FI-ASSAY-', 1, 
    0, '&corporateId', 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARF-ASSAY-'||SEQ_ARF.nextval, '&corporateId', 'FINAL_ASSAY', 'FinalAssayRefNo', 'N');  