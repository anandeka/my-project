SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('INV_LIST', 'List Of Inventory', 6, 3, '/metals/loadListOfInventory.action?gridId=INV_LIST', 
    NULL, 'F2', NULL, 'Finance', NULL);





Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_CS', 'CRF', 'SEQ_CS_INTERNAL_REF_NO');
