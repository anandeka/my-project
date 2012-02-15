INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url, default_record_model_state,
             other_url,
             screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('FS_LOCI', 'List of Contract Items For Finacial Settlements',
             '[ 
                                {name: "contractNo", mapping: "contractNo"}, 
                                {name: "contractType", mapping: "contractType"}, 
                                {name: "counterParty", mapping: "counterParty"},
                                {name: "tradeType", mapping: "tradeType"},
                                {name: "allocationStatus", mapping: "allocationStatus"},
                                {name: "itemStatus", mapping: "itemStatus"},
                                {name: "deliveryRefNo", mapping: "deliveryRefNo"},
                                {name: "itemRefNo", mapping: "itemRefNo"},
                                {name: "internalContractItemRefNo", mapping: "internalContractItemRefNo"},
                                {name: "internalContractRefNo", mapping: "internalContractRefNo"},
                                {name: "product", mapping: "product"},
                                {name: "quality", mapping: "quality"},
                                {name: "attributes", mapping: "attributes"},
                                {name: "issueDate", mapping: "issueDate"},
                                {name: "quotaMonth", mapping: "quotaMonth"},
                                {name: "location", mapping: "location"},
                                {name: "traxysOrg", mapping: "traxysOrg"},
                                {name: "incotermLocation", mapping: "incotermLocation"},
                                {name: "pricing", mapping: "pricing"},
                                {name: "qp", mapping: "qp"},
                                {name: "qty", mapping: "qty"},
                                {name: "openQty", mapping: "openQty"},
                                {name: "qtyBasis", mapping: "qtyBasis"},
                                {name: "allocatedQty", mapping: "allocatedQty"},
                                {name: "partnershipType", mapping: "partnershipType"},
                                {name: "incoterm", mapping: "incoterm"},
                                {name: "pcdiId", mapping: "pcdiId"},
                                {name: "strategy", mapping: "strategy"},
                                {name: "bookProfitCenter", mapping: "bookProfitCenter"},
                                {name: "trader", mapping: "trader"},
                                {name: "pricing", mapping: "pricing"},
                                {name: "executedQty", mapping: "executedQty"},
                                {name: "titleTransferQty", mapping: "titleTransferQty"},
                                {name: "provInvoicedQty", mapping: "provInvoicedQty"},
		    {name: "finalInvoicedQty", mapping: "finalInvoicedQty"},
		    {name: "payInCurrency", mapping: "payInCurrency"},
		    {name: "payableContent", mapping: "payableContent"},
                                {name: "origin", mapping: "origin"}
                               ]',
             NULL, NULL, NULL,
             '/private/jsp/mining/tolling/ListOfContractPopupFS.jsp',
             '/private/jsp/mining/tolling/listing/ListOfContractItemForFS.jsp',
             '/private/js/mining/tolling/listing/ListOfContractItemForFS.js'
            );


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('METAL_ACCOUNT_LIST_1', 'METAL_ACCOUNT_LIST', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('METAL_ACCOUNT_LIST_1_1', 'METAL_ACCOUNT_LIST', 'Financial Settlements', 1, 2, 
    NULL, 'function(){createFinancialSettlements();}', NULL, 'METAL_ACCOUNT_LIST_1', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('METAL_ACCOUNT_LIST_1_2', 'METAL_ACCOUNT_LIST', 'Metal Transfer', 2, 2, 
    NULL, 'function(){loadMetalBalanceTransfer();}', NULL, 'METAL_ACCOUNT_LIST_1', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('SMELTER_LIST_1', 'SMELTER_LIST', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('SMELTER_LIST_1_1', 'SMELTER_LIST', 'Financial Settlements', 1, 2, 
    NULL, 'function(){createFinancialSettlements();}', NULL, 'SMELTER_LIST_1', NULL);


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('FSRefNo', 'FS Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
