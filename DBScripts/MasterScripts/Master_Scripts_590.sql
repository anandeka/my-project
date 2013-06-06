 
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P9', 'Templates', 9, 2, NULL, 
    NULL, 'P1', 'APP-ACL-N1117', 'Physical', 'APP-PFL-N-188', 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P91', 'New Purchase Base Metal Template', 1, 3, '/metals/loadContractForCreation.action?tabId=general&contractType=P&productGroupType=BASEMETAL&actionType=current&moduleId=physical&isTemplate=Y', 
    NULL, 'P9', 'APP-ACL-N1401', 'Physical', NULL, 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P92', 'New Purchase Concentrates Template', 2, 3, '/metals/loadContractForCreation.action?tabId=general&contractType=P&productGroupType=CONCENTRATES&actionType=current&moduleId=physical&isTemplate=Y', 
    NULL, 'P9', 'APP-ACL-N1401', 'Physical', NULL, 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P93', 'New Sale Base Metal Template', 3, 3, '/metals/loadContractForCreation.action?tabId=general&contractType=S&productGroupType=BASEMETAL&actionType=current&moduleId=physical&isTemplate=Y', 
    NULL, 'P9', 'APP-ACL-N1401', 'Physical', NULL, 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P94', 'New Sale Concentrates Template', 4, 3, '/metals/loadContractForCreation.action?tabId=general&contractType=S&productGroupType=CONCENTRATES&actionType=current&moduleId=physical&isTemplate=Y', 
    NULL, 'P9', 'APP-ACL-N1401', 'Physical', NULL, 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P95', 'List All', 5, 3, '/metals/loadListOfContractTemplate.action?gridId=LOCT', 
    NULL, 'P9', 'APP-ACL-N1401', 'Physical', NULL, 
    'N');

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOCT', 'List All', '[{"dataIndex":"","fixed":true,"header":"","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"draftType","header":"Draft Type","id":1,"sortable":true,"width":150},{"dataIndex":"draftNo","header":"Draft No.","id":2,"sortable":true,"width":150},{"dataIndex":"cpName","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"profitCenter","header":"Profit Center","id":4,"sortable":true,"width":150},{"dataIndex":"lastUpdatedBy","header":"Last Updated By","id":5,"sortable":true,"width":150},{"dataIndex":"lastUpdatedOnDate","header":"Last Updated On Date","id":6,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":7,"sortable":true,"width":150},{"dataIndex":"executionType","header":"Execution Type","id":8,"sortable":true,"width":150},
{"dataIndex":"strategy","header":"Strategy","id":9,"sortable":true,"width":150},{"dataIndex":"contractIssueDate","header":"Contract Issue Date","id":10,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":11,"sortable":true,"width":150}]', NULL, NULL, 
    '[ 
                                {name: "id", mapping: "id"},
                                {name: "templateNo", mapping: "templateNo"},
                                {name: "templateName", mapping: "templateName"}, 
				{name: "templateType", mapping: "templateType"},
                                {name: "cpName", mapping: "cpName"}, 
                                {name: "profitCenter", mapping: "profitCenter"},                                
                                {name: "trader", mapping: "trader"},
                                {name: "executionType", mapping: "executionType"}, 
                                {name: "strategy", mapping: "strategy"}, 
                                {name: "contractIssueDate", mapping: "contractIssueDate"},
                                {name: "product", mapping: "product"},
                                {name: "pcdtId", mapping: "pcdtId"},
				{name: "lastUpdatedBy", mapping: "lastUpdatedBy"}, 
                                {name: "lastUpdatedOnDate", mapping: "lastUpdatedOnDate"}                                
                               ] ', NULL, 'physical/listing/listOfContractTemplate.jsp', '/private/js/physical/listing/listOfContractTemplate.js');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TEMP_OP', 'LOCT', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TEMP_OP_1', 'LOCT', 'Create Contract', 1, 2, 
    'APP-PFL-N-224', 'function(){createContract();}', NULL, 'TEMP_OP', 'APP-ACL-N1400');
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TEMP_OP_2', 'LOCT', 'Modify Template', 2, 2, 
    'APP-PFL-N-224', 'function(){modifyTemplate();}', NULL, 'TEMP_OP', 'APP-ACL-N1400');
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TEMP_OP_3', 'LOCT', 'Clone Template', 3, 2, 
    'APP-PFL-N-224', 'function(){cloneTemplate();}', NULL, 'TEMP_OP', 'APP-ACL-N1400');
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TEMP_OP_4', 'LOCT', 'Upload Document', 4, 2, 
    'APP-PFL-N-224', 'function(){uploadDocument();}', NULL, 'TEMP_OP', 'APP-ACL-N1400');
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TEMP_OP_5', 'LOCT', 'Delete', 5, 2, 
    'APP-PFL-N-224', 'function(){deleteTemplate();}', NULL, 'TEMP_OP', 'APP-ACL-N1400');




Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('TOL-TEMP', 'Templates', 40, 3, NULL, 
    NULL, 'TOL-M1.2', NULL, 'Tolling', NULL, 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('TOL-TEMP_M1', 'New Buy Tolling Service Template', 1, 4, '/metals/loadMiningContractForCreation.action?method=loadMiningContractForCreation&tabId=general&contractType=S&productGroupType=CONCENTRATES&actionType=current&moduleId=miningContract&isTemplate=Y', 
    NULL, 'TOL-TEMP', NULL, 'Tolling', NULL, 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('TOL-TEMP_M2', 'New Sell Tolling Service Template', 2, 4, '/metals/loadMiningContractForCreation.action?method=loadMiningContractForCreation&tabId=general&contractType=P&productGroupType=CONCENTRATES&actionType=current&moduleId=miningContract&isTemplate=Y', 
    NULL, 'TOL-TEMP', NULL, 'Tolling', NULL, 
    'N');
    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('TOL-TEMP_M3', 'List All', 3, 4, '/metals/loadListOfTollingContractTemplate.action?gridId=TOL_LOCT', 
    NULL, 'TOL-TEMP', NULL, 'Tolling', NULL, 
    'N');
    
    
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TOL_LOCT', 'List of Tolling Contract Template', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"draftType","header":"Draft Type","id":1,"sortable":true,"width":150},{"dataIndex":"draftNo","header":"Draft No.","id":2,"sortable":true,"width":150},{"dataIndex":"cpName","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"profitCenter","header":"Profit Center","id":4,"sortable":true,"width":150},{"dataIndex":"lastUpdatedBy","header":"Last Updated By","id":5,"sortable":true,"width":150},{"dataIndex":"lastUpdatedOnDate","header":"Last Updated On Date","id":6,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":7,"sortable":true,"width":150},{"dataIndex":"executionType","header":"Execution Type","id":8,"sortable":true,"width":150},
{"dataIndex":"strategy","header":"Strategy","id":9,"sortable":true,"width":150},{"dataIndex":"contractIssueDate","header":"Contract Issue Date","id":10,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":11,"sortable":true,"width":150}]', NULL, NULL, 
    '[ 
                                {name: "id", mapping: "id"},
                                {name: "templateNo", mapping: "templateNo"},
                                {name: "templateName", mapping: "templateName"}, 
				{name: "templateType", mapping: "templateType"},
                                {name: "cpName", mapping: "cpName"}, 
                                {name: "profitCenter", mapping: "profitCenter"},                                
                                {name: "trader", mapping: "trader"},
                                {name: "executionType", mapping: "executionType"}, 
                                {name: "strategy", mapping: "strategy"}, 
                                {name: "contractIssueDate", mapping: "contractIssueDate"},
                                {name: "product", mapping: "product"},
                                {name: "pcdtId", mapping: "pcdtId"},
				{name: "lastUpdatedBy", mapping: "lastUpdatedBy"}, 
                                {name: "lastUpdatedOnDate", mapping: "lastUpdatedOnDate"}                                
                               ] ', NULL, 'mining/physical/listing/listOfTollingContractTemplate.jsp', '/private/js/mining/physical/listing/listOfTollingContractTemplate.js');
                               
                               
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOL_TEMP_OP', 'TOL_LOCT', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);     
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOL_TEMP_OP_1', 'TOL_LOCT', 'Create Contract', 1, 2, 
    'APP-PFL-N-224', 'function(){createContract();}', NULL, 'TOL_TEMP_OP', 'APP-ACL-N1400');    
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOL_TEMP_OP_2', 'TOL_LOCT', 'Modify Template', 2, 2, 
    'APP-PFL-N-224', 'function(){modifyTemplate();}', NULL, 'TOL_TEMP_OP', 'APP-ACL-N1400');
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOL_TEMP_OP_3', 'TOL_LOCT', 'Clone Template', 3, 2, 
    'APP-PFL-N-224', 'function(){cloneTemplate();}', NULL, 'TOL_TEMP_OP', 'APP-ACL-N1400');
    
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOL_TEMP_OP_4', 'TOL_LOCT', 'Upload Document', 4, 2, 
    'APP-PFL-N-224', 'function(){uploadDocument();}', NULL, 'TOL_TEMP_OP', 'APP-ACL-N1400');

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TOL_TEMP_OP_5', 'TOL_LOCT', 'Delete', 5, 2, 
    'APP-PFL-N-224', 'function(){deleteTemplate();}', NULL, 'TOL_TEMP_OP', 'APP-ACL-N1400'); 