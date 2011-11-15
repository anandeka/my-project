Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P4', 'List of Drafts', 3, 2, '/metals/loadListOfContractDraft.action?method=loadListOfContractDraft&gridId=LOCDT', 
    NULL, 'P1', NULL, 'Physical', NULL);


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOCDT', 'List of Contract Drafts', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"draftType","header":"Draft Type","id":1,"sortable":true,"width":150},{"dataIndex":"draftNo","header":"Draft No.","id":2,"sortable":true,"width":150},{"dataIndex":"cpName","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"profitCenter","header":"Profit Center","id":4,"sortable":true,"width":150},{"dataIndex":"lastUpdatedBy","header":"Last Updated By","id":5,"sortable":true,"width":150},{"dataIndex":"lastUpdatedOnDate","header":"Last Updated On Date","id":6,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":7,"sortable":true,"width":150},{"dataIndex":"executionType","header":"Execution Type","id":8,"sortable":true,"width":150},
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
                               ] ', NULL, 'physical/listing/listOfContractDraft.jsp', '/private/js/physical/listing/listOfContractDraft.js');



Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCDT_1', 'LOCDT', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCDT_1_1', 'LOCDT', 'Modify Contract', 2, 2, 
    NULL, 'function(){modifyContract();}', NULL, 'LOCDT_1', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOCDT_1_2', 'LOCDT', 'Delete Contract', 3, 2, 
    NULL, 'function(){deleteContract();}', NULL, 'LOCDT_1', NULL);



Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('salesPartnerShipType', 'Normal', 'Y', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('salesPartnerShipType', 'Consignment', 'N', 2);




Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DraftFilterPartnershipType', 'Joint Venture', 'N', 3);
Insert into METAL_DEV_APP.SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DraftFilterPartnershipType', 'Agency', 'N', 2);
Insert into METAL_DEV_APP.SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DraftFilterPartnershipType', 'Normal', 'N', 1);


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DR', 'Contract', 'Draft Creation', 'N', 'Draft Created', 
    'N', NULL);

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_DR', 'Contract', 'Draft Modification', 'N', 'Draft Modified', 
    'N', NULL);

Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DR', NULL, NULL, NULL, 'Y', 
    NULL, NULL, NULL, 'Y');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DraftRefNo', 'Draft Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-DR-&corpId', 'DraftRefNo', '&corpId', 'DR-', 1, 
    0,  '-&corpId', 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DR-&corpId', '&corpId', 'CREATE_DR', 'DraftRefNo', 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   ('&corpId', 'CREATE_DR', 'DR-', 0, '-&corpId');
   


Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_PCDT', 'DR', 'SEQ_PCDT');

