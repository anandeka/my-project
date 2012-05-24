Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('LOIU', 'List Of Invoice Utility', 9, 3, '/metals/loadListOfInvoiceUtility.action?gridId=LOIU', 
    NULL, 'F2', 'APP-ACL-N1085', 'Finance', 'APP-PFL-N-187', 
    'N');



SET DEFINE OFF;
INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url, screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('LOIU', 'List of Invoice Utility',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"utilityRefNo","header":"Utility Ref No.","id":1,"sortable":true,"width":150},{"dataIndex":"smelter","header":"Smelter","id":2,"sortable":true,"width":150},{"dataIndex":"status","header":"Status","id":3,"sortable":true,"width":150},{"dataIndex":"runBy","header":"Run By","id":4,"sortable":true,"width":150},{"dataIndex":"runDate","header":"Run Date & Time","id":5,"sortable":true,"width":150},{"dataIndex":"generateDoc","header":"Generate Doc","id":6,"sortable":true,"width":150}]',
             'Finance', '/metals/loadListOfInvoiceUtility.action',
             '[ 
                                   {name: "utilityRefNo", mapping: "utilityRefNo"},
                                   {name: "smelter", mapping: "smelter"},
                                {name: "status", mapping: "status"}, 
                                {name: "runBy", mapping: "runBy"}, 
                                {name: "runDate", mapping: "runDate"},
                                {name: "generateDoc", mapping: "generateDoc"},
                                {name: "iusId", mapping: "iusId"}
                               ] ',
             NULL, 'mining/invoice/listing/listOfInvoiceUtility.jsp',
             '/private/js/mining/invoice/listing/listOfInvoiceUtility.js'
            );




Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOIU_1', 'LOIU', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOIU_1_1', 'LOIU', 'Run Utility', 2, 2, 
    'APP-PFL-N-187', 'function(){loadForRunUtility();}', NULL, 'LOIU_1', 'APP-ACL-N1087');

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOIU_1_2', 'LOIU', 'Roll Back', 3, 2, 
    'APP-PFL-N-187', 'function(){rollback();}', NULL, 'LOIU_1', 'APP-ACL-N1087');







Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Successful', 'Successful');
   
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Rolled Back', 'Rolled Back');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InvoiceUtilityStatus', 'Successful', 'N', 1);
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('InvoiceUtilityStatus', 'Rolled Back', 'N', 2);

