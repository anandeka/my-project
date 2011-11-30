SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P5', 'List of Contract Approvals', 4, 2, '/metals/loadListOfContractApprovals.action?method=loadListOfContractApprovals&gridId=LOCA', 
    NULL, 'P1', NULL, 'Physical', NULL);


INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url, screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('LOCA', 'List of Contract Approvals',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractRefNo","header":"Contract Ref No.","id":1,"sortable":true,"width":150},{"dataIndex":"action","header":"Action","id":2,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":3,"sortable":true,"width":150},{"dataIndex":"cpName","header":"CP Name","id":4,"sortable":true,"width":150},{"dataIndex":"dateSent","header":"Date Sent","id":5,"sortable":true,"width":150},{"dataIndex":"sentBy","header":"Sent By","id":6,"sortable":true,"width":150},{"dataIndex":"suggestedApprover","header":"Suggested Approver","id":7,"sortable":true,"width":150},{"dataIndex":"approvalStatus","header":"Approval Status","id":8,"sortable":true,"width":150},
{"dataIndex":"actualApprover","header":"Actual Approver","id":9,"sortable":true,"width":150},{"dataIndex":"approvalRejectionOn","header":"Approval/Rejection On","id":10,"sortable":true,"width":150},{"dataIndex":"remarks","header":"Remarks","id":11,"sortable":true,"width":150}]',
             NULL, NULL,
             '[ 
                                   {name: "contractRefNo", mapping: "contractRefNo"},
                                   {name: "action", mapping: "action"},
                                {name: "contractType", mapping: "contractType"}, 
                                {name: "cpName", mapping: "cpName"}, 
                                {name: "dateSent", mapping: "dateSent"},
                                {name: "sentBy", mapping: "sentBy"}, 
                                {name: "suggestedApprover", mapping: "suggestedApprover"},
                                {name: "approvalStatus", mapping: "approvalStatus"},
                                {name: "actualApprover", mapping: "actualApprover"}, 
                                {name: "approvalRejectionOn", mapping: "approvalRejectionOn"}, 
                                {name: "remarks", mapping: "remarks"}
                               ] ',
             NULL, 'physical/listing/listOfContractApprovals.jsp',
             '/private/js/physical/listing/listOfContractApprovals.js'
            );


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCA_1', 'LOCA', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCA_1_1', 'LOCA', 'Modify Contract', 2, 2, 
    NULL, 'function(){modifyContract();}', NULL, 'LOCA_1', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCA_1_2', 'LOCA', 'Cancle Contract', 3, 2, 
    NULL, 'function(){cancelContract();}', NULL, 'LOCA_1', NULL);

