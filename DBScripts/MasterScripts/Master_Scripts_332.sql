SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('EX', 'Exposure', 4, 2, '/metals/loadListOfQuantityExposureProcess.action?method=loadListOfQuantityExposureProcess&gridId=QEP', 
    NULL, 'PE1', NULL, 'Period End', 'APP-PFL-N-193', 
    'N');


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('EX1', 'Quantity Exposure Process', 1, 3, '/metals/loadListOfQuantityExposureProcess.action?method=loadListOfQuantityExposureProcess&gridId=QEP', 
    NULL, 'EX', NULL, 'Period End', NULL, 
    'N');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('EX2', 'FX Exposure Process', 2, 3, '/metals/loadListOfFxExposureProcess.action?method=loadListOfFxExposureProcess&gridId=FXEP', 
    NULL, 'EX', NULL, 'Period End', NULL, 
    'N');


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('QEP', 'List Of Quantity Exposure Process', '[     
  {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
  {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
  {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
  {header: "Hedge Correction Events", width: 150, sortable: true, dataIndex: "hedgeCorrectionEvents"},
  {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, NULL, 
    '[     
    {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
    {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
    {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
    {header: "Hedge Correction Events", width: 150, sortable: true, dataIndex: "hedgeCorrectionEvents"},
    {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, 'periodend/listOfExposureProcess.jsp', '/private/js/periodend/listOfQuantityExposureProcess.js');


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('FXEP', 'List Of Fx Exposure Process', '[     
  {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
  {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
  {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
  {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, NULL, 
    '[     
    {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
    {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
    {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},    
    {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, 'periodend/listOfExposureProcess.jsp', '/private/js/periodend/listOfFxExposureProcess.js');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX2', 'FXEP', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);

 
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX2_1', 'FXEP', 'Run', 1, 2, 
    NULL, 'function(){loadRun();}', NULL, 'EX2', NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX1', 'QEP', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX1_1', 'QEP', 'Run', 1, 2, 
    NULL, 'function(){loadRun();}', NULL, 'EX1', NULL);
COMMIT;