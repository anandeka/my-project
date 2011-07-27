Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOI_7', 'LOII_TEST', 'Jv Settlement Sheet', 7, 2, 
    NULL, 'function(){loadJvSettlementSheet();}', NULL, 'LOI_1', NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOI_8', 'LOII_TEST', 'Agency Settlement Sheet', 8, 2, 
    NULL, 'function(){loadAgencySettlementSheet();}', NULL, 'LOI_1', NULL);
