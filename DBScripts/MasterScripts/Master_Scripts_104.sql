Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOAS-DAM', 'LOAD', 'Delete Assay Mining',5, 2, 
    NULL, 'function(){callDeleteMiningAssay()}', NULL, 'LOAS', NULL);

