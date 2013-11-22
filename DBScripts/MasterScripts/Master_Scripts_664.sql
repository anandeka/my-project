SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('HCH-ProcessedQPs', 'List Of Processed QPs', 2, 3, '/metals/loadProcessedQPsListing.action?method=loadProcessedQPsListing&gridId=HCH_QP_LIST', 
    NULL, 'HCH', NULL, 'Period End', NULL, 
    'N');
COMMIT;

SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('HCH_QP_LIST', 'List Of Processed QPs', '[
         {
        header : "Process Ref No.",
        width : 150,
        sortable : true,
        dataIndex : "processId"
    }, {
        header : "Status",
        width : 150,
        sortable : true,
        dataIndex : "status"
    }, {
        header : "Updated By",
        width : 150,
        sortable : true,
        dataIndex : "updatedBy"
    }, {
        header : "Activity Type",
        width : 150,
        sortable : true,
        dataIndex : "activityType"
    }
        
    ]', NULL, NULL, 
    '[
      {
        name : "processId",
        mapping : "processId"
    }, {
        name : "status",
        mapping : "status"
    }, {
        name : "updatedBy",
        mapping : "updatedBy"
    }, {
        name : "activityDate",
        mapping : "activityDate"
    }, {
        name : "status",
        mapping : "status"
    }, {
        name : "activityType",
        mapping : "activityType"
    }
    ]', NULL, 'periodend/listOfProcessedQPs.jsp', '/private/js/periodend/listOfProcessedQPs.js');
COMMIT;


