Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOS-SALESCCY', 'LOS', 'Expected Sales CCY',3, 2, 
    NULL, 'function(){ExpectedSalesCCY();}', NULL, 'LOB-OP', NULL);


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('updateExpectedSalesCCY', 'Stock', 'Update Expected Sales Curreny Unit', 'N', 'Update Expected Sales Curreny Unit', 
    'N', 'N');