


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TGMR_1', 'TGMR_LIST', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);




Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TGMR-2', 'TGMR_LIST', 'Service Invoice Received', 2, 2, 
    NULL, 'function(){loadServiceInvRecvd();}', NULL, 'TGMR_1', NULL);




