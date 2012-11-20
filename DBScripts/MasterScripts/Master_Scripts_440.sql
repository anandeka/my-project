SET DEFINE OFF;
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOGA-2', 'LOG', 'Secondary Provisional Assay', 3, 2, 
    'APP-PFL-N-182', 'function(){loadSecondaryProvisionalAssay();}', NULL, 'LOGA', NULL);
COMMIT;


SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('SecondaryProvisionalAssay', 'Secondary Provisional Assay');
COMMIT;

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteria', 'SecondaryProvisionalAssay', 'N', 7);
COMMIT;