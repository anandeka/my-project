Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('CREATE_PURCHASE_TOLL_SERVICE', 'Tolling ', 'Create Purchase Tolling Service', 'N', 'Create Purchase Tolling Service', 
    'Y');


   
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('CREATE_SALES_TOLL_SERVICE', 'Tolling ', 'Create Sales Tolling Service', 'N', 'Create Sales Tolling Service', 
    'Y');
   Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('PCTSRefNo', 'Create Purchase Toll Servicee', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

 Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('SCTSRefNo', 'Create Sales Toll Servicee', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');