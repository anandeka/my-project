SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('R4-3-Physical', 'Physical', 3, 3, '/metals/loadContractForCreation.action?tabId=general&contractType=P&productGroupType=BASEMETAL&actionType=current&moduleId=physical', 
    NULL, 'R4', 'APP-ACL-N1122', 'Risk', 'APP-PFL-N-200', 
    'N');
