Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MIN_2', 'MIN_LOC', 'Invoice Operations', 2, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MIN_2_1', 'MIN_LOC', 'Advance Payment Invoice', 1, 2, 
    NULL, 'function(){loadAdvancePayment();}', NULL, 'MIN_2', NULL);
