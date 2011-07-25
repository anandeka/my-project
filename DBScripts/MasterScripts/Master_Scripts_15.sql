Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOLL_1', 'TOLLING_LOCI', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MFTOLL_2', 'TOLLING_LOCI', 'Mark For Tolling', 1, 2, 
    NULL, 'function(){loadMarkForTolling();}', NULL, 'TOLL_1', NULL);
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('ROTOLL_2', 'TOLLING_LOCI', 'Record Output ', 2, 2, 
    NULL, 'function(){loadRecordOutputTolling();}', NULL, 'TOLL_1', NULL);



Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Tolling', 'Tolling');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('Process', 'Tolling', 'Y', 1);