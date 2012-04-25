Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('TOL-M21', 'Contract Draft', 21, 3, '/metals/loadListOfMiningContractDraft.action?gridId=MLOCDT', 
    NULL, 'TOL-M1.2', 'APP-ACL-N1355', 'Tolling', 'APP-PFL-N-221', 
    'N');


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MLOCDT', 'List of Mining Contract Drafts', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"draftType","header":"Draft Type","id":1,"sortable":true,"width":150},{"dataIndex":"draftNo","header":"Draft No.","id":2,"sortable":true,"width":150},{"dataIndex":"cpName","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"profitCenter","header":"Profit Center","id":4,"sortable":true,"width":150},{"dataIndex":"lastUpdatedBy","header":"Last Updated By","id":5,"sortable":true,"width":150},{"dataIndex":"lastUpdatedOnDate","header":"Last Updated On Date","id":6,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":7,"sortable":true,"width":150},{"dataIndex":"executionType","header":"Execution Type","id":8,"sortable":true,"width":150},
{"dataIndex":"strategy","header":"Strategy","id":9,"sortable":true,"width":150},{"dataIndex":"contractIssueDate","header":"Contract Issue Date","id":10,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":11,"sortable":true,"width":150}]', NULL, NULL, 
    '[ 
                               	{name: "id", mapping: "id"},
                               	{name: "draftType", mapping: "draftType"},
                                {name: "draftNo", mapping: "draftNo"}, 
                                {name: "cpName", mapping: "cpName"}, 
                                {name: "profitCenter", mapping: "profitCenter"},
                                {name: "lastUpdatedBy", mapping: "lastUpdatedBy"}, 
                                {name: "lastUpdatedOnDate", mapping: "lastUpdatedOnDate"},
                                {name: "trader", mapping: "trader"},
                                {name: "executionType", mapping: "executionType"}, 
                                {name: "strategy", mapping: "strategy"}, 
                                {name: "contractIssueDate", mapping: "contractIssueDate"},
                                {name: "product", mapping: "product"},
                                {name: "pcdtId", mapping: "pcdtId"}
                               ] ', NULL, 'mining/physical/listing/listOfMiningContractDraft.jsp', '/private/js/mining/physical/listing/listOfMiningContractDraft.js');



INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('MLOCDT_1', 'MLOCDT', 'Operations', 1,
             1, NULL, 'function(){}', NULL,
             NULL, NULL
            );
INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called,
             icon_class, menu_parent_id, acl_id
            )
     VALUES ('MLOCDT_1_1', 'MLOCDT', 'Modify Contract', 2,
             2, 'APP-PFL-N-188', 'function(){modifyMiningContractDraft();}',
             NULL, 'MLOCDT_1', 'APP-ACL-N1102'
            );
INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called,
             icon_class, menu_parent_id, acl_id
            )
     VALUES ('MLOCDT_1_2', 'MLOCDT', 'Delete Contract', 3,
             2, 'APP-PFL-N-188', 'function(){deleteMiningContractDraft();}',
             NULL, 'MLOCDT_1', 'APP-ACL-N1103'
            );