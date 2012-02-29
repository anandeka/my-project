
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_WI', 'Invoice ', 'Create Washout Invoice', 'N', 'Washout Invoice Creation', 
    'Y', NULL);
    
    
Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('WIRefNo', 'WI Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no 

= :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');    
    
    
    

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_WI', NULL, NULL, NULL, 'Y', 
    NULL, NULL, NULL, 'Y');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOII_4', 'LOIID_TEST', 'Special Settlement Invoice', 5, 2, 
    NULL, 'function(){loadSpecialSettlementInvoice();}', NULL, 'LOII', NULL);



Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('WO_LOSS', 'List of Special Settlement', '[ 
                                 {name: "activityDate", mapping: "activityDate"}, 
                                 {name: "settlementType", mapping: "settlementType"}, 
                                 {name: "salesContractItemRefNo", mapping: "salesContractItemRefNo"},
                                 {name: "purchaseContractItemRefNo", mapping: "purchaseContractItemRefNo"},
                                 {name: "specialSettlementRefNo", mapping: "specialSettlementRefNo"},
                                 {name: "cpName", mapping: "cpName"},
                                 {name: "salesPriceDesc", mapping: "salesPriceDesc"},
                                 {name: "purchasePriceDesc", mapping: "purchasePriceDesc"},
                                 {name: "purchasePrice", mapping: "purchasePrice"},
                                 {name: "salesPrice", mapping: "salesPrice"}
                                
                               ]', NULL, NULL, 
    NULL, NULL, '/private/jsp/physical/itemoperation/listing/ListOfSpecialSettlementFilter.jsp', '/private/js/physical/itemoperation/listing/listOfSpecialSettlement.js');




Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('LOSS', 'List Of Special Settlement', 8, 3, '/metals/loadListOfSpecialSettlement.action?gridId=WO_LOSS', 
    NULL, 'F2', NULL, 'Finance', NULL, 
    'N');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOSS', 'WO_LOSS', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOSS_1', 'WO_LOSS', 'Cancel Special Settlement', 2, 2, 
    NULL, 'function(){cancelSpecialSettlement();}', NULL, 'LOSS', NULL);
