Insert into ATM_APP_TAB_MASTER
   (TAB_ID, TAB_NAME, IS_DEFAULT, IS_ACTIVE)
 Values
   ('Tolling', 'Tolling', 'N', 'Y');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M', 'Tolling', 21, 1, NULL, 
    NULL, NULL, NULL, 'Tolling', NULL);
    

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M1', 'In Process Stock', 1, 2, '/metals/loadListOfTollingInProcessStock.action?method=loadListOfTollingInProcessStock&gridId=TIPS_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M2', 'Tolling GMR', 2, 2, '/metals/loadListOfTollingGMR.action?method=loadListOfTollingGMR&gridId=TGMR_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);
    

    

  Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('MARK_FOR_TOLLING', 'GMR Tolling ', 'Create GMR Mark For Tolling', 'Y', 'GMR Mark For Tolling Creation', 
    'N');

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MARK_FOR_TOLLING', 'N', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('MFTRefNo', 'MFT Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




  Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE)
 Values
   ('RECORD_OUT_PUT_TOLLING', 'GMR Tolling ', 'Create GMR Record Output Tolling', 'Y', 'GMR Record Output Tolling Creation', 
    'N');

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('RECORD_OUT_PUT_TOLLING', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('ROPTRefNo', 'ROPT Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');