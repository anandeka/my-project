SET DEFINE OFF;

delete from AMC_APP_MENU_CONFIGURATION where menu_id='CDC-MM-9';

delete from AMC_APP_MENU_CONFIGURATION where menu_id='CDC-P7';


Insert into METALS_MAIN_DEV.AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P_PROCESS', 'Pricing Process', 5, 2, '/metals/loadPeriodEndPricing.action', 
    NULL, 'PE1', NULL, 'Period End', 'APP-PFL-N-193', 
    'N');

Insert into METALS_MAIN_DEV.AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('CDC-MM-9', 'New', 1, 3, '/metals/loadPeriodEndPricing.action', 
    NULL, 'P_PROCESS', NULL, 'Period End', NULL, 
    'N');

Insert into METALS_MAIN_DEV.AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('CDC-P7', 'List All', 2, 3, '/metals/loadListOfPriceProcess.action?gridId=LOPP', 
    NULL, 'P_PROCESS', NULL, 'Period End', NULL, 
    'N');

COMMIT;
