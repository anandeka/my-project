SET DEFINE OFF;

INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called,
             icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID,
             is_deleted
            )
     VALUES ('P9', 'List of Templates', 6, 2,
             '/metals/loadListOfContractTemplate.action?method=loadListOfContractTemplate&gridId=LOCT',
             NULL, 'P1', 'APP-ACL-N1101', 'Physical', 'APP-PFL-N-188',
             'N'
            );

INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url, screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('LOCT', 'List of Templates',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"draftType","header":"Template Type","id":1,"sortable":true,"width":150},{"dataIndex":"draftNo","header":"Template No.","id":2,"sortable":true,"width":150},{"dataIndex":"cpName","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"profitCenter","header":"Profit Center","id":4,"sortable":true,"width":150},{"dataIndex":"lastUpdatedBy","header":"Last Updated By","id":5,"sortable":true,"width":150},{"dataIndex":"lastUpdatedOnDate","header":"Last Updated On Date","id":6,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":7,"sortable":true,"width":150},{"dataIndex":"executionType","header":"Execution Type","id":8,"sortable":true,"width":150},
{"dataIndex":"strategy","header":"Strategy","id":9,"sortable":true,"width":150},{"dataIndex":"contractIssueDate","header":"Contract Issue Date","id":10,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":11,"sortable":true,"width":150}]',
             NULL, NULL,
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
                                {name: "draftOrTemplateType", mapping: "draftOrTemplateType"}
                               ] ',
             NULL, 'physical/listing/listOfContractTemplate.jsp',
             '/private/js/physical/listing/listOfContractTemplate.js'
            );

INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('LOCT_1', 'LOCT', 'Operations', 1,
             1, NULL, 'function(){}', NULL,
             NULL, NULL
            );
INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('LOCT_1_1', 'LOCT', 'Create Contract', 2,
             2, NULL, 'function(){modifyTemplate();}', NULL,
             'LOCT_1', NULL
            );

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCT_1_2', 'LOCT', 'Delete Template', 3, 2, 
    NULL, 'function(){deleteTemplate();}', NULL, 'LOCT_1', NULL);

