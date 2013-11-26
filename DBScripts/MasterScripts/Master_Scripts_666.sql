
UPDATE gmc_grid_menu_configuration gmc
   SET gmc.menu_display_name = 'Show Impacted QPs Physical',GMC.LINK_CALLED='function(){loadlistofImpactedQPsPhysicals();}'
 WHERE gmc.menu_id = 'HCH_LIST_1_1' AND gmc.grid_id = 'HCH_LIST';
 
 
 SET DEFINE OFF;
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('HCH_LIST_1_2', 'HCH_LIST', 'Show Impacted QPs Derivatives', 2, 2, 
    NULL, 'function(){loadlistofImpactedQPsDerivatives();}', NULL, 'HCH_LIST_1', NULL);
COMMIT;