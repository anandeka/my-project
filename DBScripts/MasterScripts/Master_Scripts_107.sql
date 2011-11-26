SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M6', 'New Mining Tolling Contracts', 6, 2, '', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M6_M2', 'SellTollingService', 2, 3, NULL, 
    NULL, 'TOL-M6', NULL, 'Tolling', NULL);

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
   ('TOL-M6_M1', 'BuyTollingService', 1, 3, '/metals/loadMiningContractForCreation.action?method=loadMiningContractForCreation&tabId=general&contractType=S&productGroupType=CONCENTRATES&actionType=current&moduleId=miningContract', 
    NULL, 'TOL-M6', NULL, 'Tolling', NULL);