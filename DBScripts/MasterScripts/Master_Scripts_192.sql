
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('RETURN_MATERIAL_CANCEL', 'CancelRetMat', 'Cancel Return Material', 'Y', 'Cancel Return Material', 
    'N', NULL);


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('FREE_MATERIAL_CANCEL', 'CancelFreMat', 'Cancel Free Material', 'Y', 'Cancel Free Material', 
    'N', NULL);





Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('CancelRetMat', 'Cancel Return Material Ref No.', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('CancelFreMat', 'Cancel Free Material Ref No.', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');





Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('RETURN_MATERIAL_CANCEL', 'N', 'N', 'activityDate', 'N',  NULL, NULL, 'N', 'N');



Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('FREE_MATERIAL_CANCEL', 'N', 'N', 'activityDate', 'N',  NULL, NULL, 'N', 'N');






Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('MINING_YIELD', 'Yield', 17, 4, '/metals/loadListOfYield.action?gridId=MINING_YIELD', 
    NULL, 'TOL-M1.2.2', NULL, 'Tolling', NULL, 'N');


SET DEFINE OFF;

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MINING_YIELD', 'Yield', '[     
{header: "Smelter", width: 150, sortable: true, dataIndex: "smelter"}
]', NULL, NULL, 
    '[ 
                                {name: "smelter", mapping: "smelter"}
                               ] ', NULL, '/private/jsp/mining/tolling/listing/YieldListingFilter.jsp', '/private/js/mining/tolling/listing/YieldListing.js ');




SET DEFINE OFF;

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_YD', 'MINING_YIELD', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_YD_1', 'MINING_YIELD', 'Cancel Yield %', 1, 2, 
    NULL, 'function(){loadYield();}', NULL, 'MINING_YD', NULL);


