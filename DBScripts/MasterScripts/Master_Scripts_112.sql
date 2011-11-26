SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M6_M3', 'List all', 3, 3, '/metals/loadListOfMiningContracts.action?gridId=MIN_LOC', 
    NULL, 'TOL-M6', NULL, 'Tolling', NULL);

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M9', 'Contract item', 10, 2, '/metals/loadListOfMiningContractItem.action?gridId=MLOCI', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M7', 'Delivery Item', 9, 2, '/metals/loadListOfMiningDeliveryItems.action?gridId=MLODI', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);

