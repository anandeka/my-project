
   
   Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('PCTSRefNo', 'Create Purchase Toll Servicee', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-PCTS-'||SEQ_ARF.nextval, 'PCTSRefNo', '&corporateId', 'PCT-', 1, 
    0, '&corporateId', 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-PCTS-&corpId', '&corpId', 'CREATE_PURCHASE_TOLL_SERVICE', 'PCTSRefNo', 'N');  



    Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('SCTSRefNo', 'Create Sales Toll Servicee', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-SCTS-'||SEQ_ARF.nextval, 'SCTSRefNo', '&corporateId', 'SCT-', 1, 
    0, '&corporateId', 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-SCTS-&corpId', '&corpId', 'CREATE_SALES_TOLL_SERVICE', 'SCTSRefNo', 'N');  



Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('&corpID', 'PCTSRefNo', 'PCTS-', 0, '-&corpID');
   
   
Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('&corpID', 'SCTSRefNo', 'SCTS-', 0, '-&corpID');