Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MTGMR_LIST_1_4', 'MTGMR_LIST', 'Provisional Assay', 4, 2, 
    NULL, 'function(){createProvisionalAssay();}', NULL, 'MTGMR_LIST_1', NULL);