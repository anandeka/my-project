Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('LOPR', 'List All', 2, 3, '/metals/loadListOfPriceRecords.action?gridId=LOPR', 
    NULL, 'PPR', 'APP-ACL-N1094', 'Finance', 'APP-PFL-N-187', 
    'N');


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('PPR', 'Provisional Price Record', 2, 2, NULL, 
    NULL, 'F1', 'APP-ACL-N1093', 'Finance', 'APP-PFL-N-187', 
    'N');


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('PPR_NEW', 'New', 1, 3, '/metals/provisionalPriceRecord.action', 
    NULL, 'PPR', 'APP-ACL-N1094', 'Finance', 'APP-PFL-N-187', 
    'N');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOPR_1', 'LOPR', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOPR_1', 'LOPR', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOPR_1_1', 'LOPR', 'Modify', 2, 2, 
    'APP-PFL-N-187', 'function(){modifyProvisionalRecord();}', NULL, 'LOPR_1', 'APP-ACL-N1087');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, DEFAULT_RECORD_MODEL_STATE,
    SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS, URL,OTHER_URL,TAB_ID)
 Values
   ('LOPR', 'List Of Provisional Price Records', '[ {
        header : "Effective Date",
        width : 150,
        sortable : true,
        dataIndex : "effectiveDate"
    },  {
        header : "Last Recorded By",
        width : 150,
        sortable : true,
        dataIndex : "recordedBy"
    }, {
        header : "Last Recorded Date",
        width : 150,
        sortable : true,
        dataIndex : "recordedDate"
    } ]', '[ {
        name : "effectiveDate",
        mapping : "effectiveDate"
    }, {
        name : "recordedBy",
        mapping : "recordedBy"
    }, {
        name : "recordedDate",
        mapping : "recordedDate"
    }]', '/private/jsp/invoice/ListOfProvisionalPriceRecords.jsp', '/private/js/invoice/ListOfProvisionalPriceRecords.js','','','');


