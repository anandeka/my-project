
Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_DEAL', 'Deal ', 'Create Deal', 'N', 'Create Deal', 
    'N', NULL);


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('createDeal', 'Create Deal Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DEAL-1', 'LDE', 'CREATE_DEAL', 'createDeal', 'N');


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-DEAL-2', 'createDeal', 'LDE', 'DMS-', 0, 
    0, '-LDE', NULL, 'N');
    
    
     Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_DEAL', 'Y', 'N', 'activityDate', 'N', 
    '', '', '', '');




Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Close', 'Close');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DealStatus', 'Close', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DealStatus', 'Open', 'N', 1);




set escape '\';
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P78', 'Deal Creation', 9, 2, NULL, 
    NULL, 'P1', NULL, 'Physical', NULL);

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P79', 'New Deal Creation', 1, 3, '/metals/loadDealManagementTabs.action?tabId=dealSummary\&moduleId=dealManagementModule\&productGroupType=BASEMETAL\&actionType=current', 
    NULL, 'P78', NULL, 'Physical', NULL);

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P80', 'List of Deal', 2, 3, '/metals/loadListOfDeal.action?gridId=DEAL_LIST', 
    NULL, 'P78', NULL, 'Physical', NULL);




/* Formatted on 2011/07/28 11:49 (Formatter Plus v4.8.8) */
SET escape '\';
/* Formatted on 2011/07/28 20:18 (Formatter Plus v4.8.8) */
INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url,
             screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('DEAL_LOCI', 'List Of Contract Items',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractNo","header":"Contract Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":2,"sortable":true,"width":150},{"dataIndex":"counterParty","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"partnershipType","header":"Execution Type","id":4,"sortable":true,"width":150},{"dataIndex":"tradeType","header":"Product Group Type","id":5,"sortable":true,"width":150},{"dataIndex":"itemStatus","header":"Item Status","id":6,"sortable":true,"width":150},{"dataIndex":"deliveryRefNo","header":"Delivery Ref. No.","id":7,"sortable":true,"width":150},{"dataIndex":"itemRefNo","header":"Item Ref. No.","id":8,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":9,"sortable":true,"width":150},{"dataIndex":"quality","header":"Quality","id":10,"sortable":true,"width":150},{"dataIndex":"attributes","header":"Attributes","id":11,"sortable":true,"width":150},{"dataIndex":"issueDate","header":"Issue Date","id":12,"sortable":true,"width":150},{"dataIndex":"quotaMonth","header":"Quota Period","id":13,"sortable":true,"width":150},{"dataIndex":"location","header":"Location","id":14,"sortable":true,"width":150},{"dataIndex":"traxysOrg","header":"Org","id":15,"sortable":true,"width":150},{"dataIndex":"incotermLocation","header":"INCO Term & Location","id":16,"sortable":true,"width":150},{"dataIndex":"qty","header":"Item Quantity","id":17,"sortable":true,"width":150},{"dataIndex":"openQty","header":"Open Qty.","id":18,"sortable":true,"width":150},{"dataIndex":"allocatedQty","header":"Allocated Qty.","id":19,"sortable":true,"width":150},{"dataIndex":"incoterm","header":"Incoterm","id":20,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":21,"sortable":true,"width":150},{"dataIndex":"bookProfitCenter","header":"Book/Profit Center","id":22,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":23,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":24,"sortable":true,"width":150},{"dataIndex":"titleTransferQty","header":"Title Transfer Quantity","id":25,"sortable":true,"width":150},{"dataIndex":"provInvoicedQty","header":"Prov. Invoiced Quantity","id":26,"sortable":true,"width":150},{"dataIndex":"finalInvoicedQty","header":"Final Invoiced Quantity","id":27,"sortable":true,"width":150},{"dataIndex":"payInCurrency","header":"Pay-In Currency","id":28,"sortable":true,"width":150}]',
             NULL, NULL,
             '[     
                                 {header: "Contract Ref No.", width: 150, sortable: true, dataIndex: "contractRefNo"}, 
                                 {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"}, 
                                 {header: " Item No", width: 150, sortable: true, dataIndex: "itemNo"}
                              ]',
             'dealmanagement/listing/DealManagementPopupButton.jsp',
             'dealmanagement/listing/ListOfOpenContractItems.jsp',
             '/private/js/dealmanagement/listing/listOfOpenContractItems.js'
            );
INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url,
             screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('DEAL_DERIVATIVE', 'List Of Derivative Items',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractNo","header":"Contract Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":2,"sortable":true,"width":150},{"dataIndex":"counterParty","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"partnershipType","header":"Execution Type","id":4,"sortable":true,"width":150},{"dataIndex":"tradeType","header":"Product Group Type","id":5,"sortable":true,"width":150},{"dataIndex":"itemStatus","header":"Item Status","id":6,"sortable":true,"width":150},{"dataIndex":"deliveryRefNo","header":"Delivery Ref. No.","id":7,"sortable":true,"width":150},{"dataIndex":"itemRefNo","header":"Item Ref. No.","id":8,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":9,"sortable":true,"width":150},{"dataIndex":"quality","header":"Quality","id":10,"sortable":true,"width":150},{"dataIndex":"attributes","header":"Attributes","id":11,"sortable":true,"width":150},{"dataIndex":"issueDate","header":"Issue Date","id":12,"sortable":true,"width":150},{"dataIndex":"quotaMonth","header":"Quota Period","id":13,"sortable":true,"width":150},{"dataIndex":"location","header":"Location","id":14,"sortable":true,"width":150},{"dataIndex":"traxysOrg","header":"Org","id":15,"sortable":true,"width":150},{"dataIndex":"incotermLocation","header":"INCO Term & Location","id":16,"sortable":true,"width":150},{"dataIndex":"qty","header":"Item Quantity","id":17,"sortable":true,"width":150},{"dataIndex":"openQty","header":"Open Qty.","id":18,"sortable":true,"width":150},{"dataIndex":"allocatedQty","header":"Allocated Qty.","id":19,"sortable":true,"width":150},{"dataIndex":"incoterm","header":"Incoterm","id":20,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":21,"sortable":true,"width":150},{"dataIndex":"bookProfitCenter","header":"Book/Profit Center","id":22,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":23,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":24,"sortable":true,"width":150},{"dataIndex":"titleTransferQty","header":"Title Transfer Quantity","id":25,"sortable":true,"width":150},{"dataIndex":"provInvoicedQty","header":"Prov. Invoiced Quantity","id":26,"sortable":true,"width":150},{"dataIndex":"finalInvoicedQty","header":"Final Invoiced Quantity","id":27,"sortable":true,"width":150},{"dataIndex":"payInCurrency","header":"Pay-In Currency","id":28,"sortable":true,"width":150}]',
             NULL, NULL,
             '[     
                                 {header: "Contract Ref No.", width: 150, sortable: true, dataIndex: "contractRefNo"}, 
                                 {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"}, 
                                 {header: " Item No", width: 150, sortable: true, dataIndex: "itemNo"}
                              ]',
             'dealmanagement/listing/DealManagementPopupButton.jsp',
             'dealmanagement/listing/ListOfDerivatives.jsp',
             '/private/js/dealmanagement/listing/listOfDerivatives.js'
            );
INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url, screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('DEAL_LIST', 'List Of Deal',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractNo","header":"Contract Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":2,"sortable":true,"width":150},{"dataIndex":"counterParty","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"partnershipType","header":"Execution Type","id":4,"sortable":true,"width":150},{"dataIndex":"tradeType","header":"Product Group Type","id":5,"sortable":true,"width":150},{"dataIndex":"itemStatus","header":"Item Status","id":6,"sortable":true,"width":150},{"dataIndex":"deliveryRefNo","header":"Delivery Ref. No.","id":7,"sortable":true,"width":150},{"dataIndex":"itemRefNo","header":"Item Ref. No.","id":8,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":9,"sortable":true,"width":150},{"dataIndex":"quality","header":"Quality","id":10,"sortable":true,"width":150},{"dataIndex":"attributes","header":"Attributes","id":11,"sortable":true,"width":150},{"dataIndex":"issueDate","header":"Issue Date","id":12,"sortable":true,"width":150},{"dataIndex":"quotaMonth","header":"Quota Period","id":13,"sortable":true,"width":150},{"dataIndex":"location","header":"Location","id":14,"sortable":true,"width":150},{"dataIndex":"traxysOrg","header":"Org","id":15,"sortable":true,"width":150},{"dataIndex":"incotermLocation","header":"INCO Term & Location","id":16,"sortable":true,"width":150},{"dataIndex":"qty","header":"Item Quantity","id":17,"sortable":true,"width":150},{"dataIndex":"openQty","header":"Open Qty.","id":18,"sortable":true,"width":150},{"dataIndex":"allocatedQty","header":"Allocated Qty.","id":19,"sortable":true,"width":150},{"dataIndex":"incoterm","header":"Incoterm","id":20,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":21,"sortable":true,"width":150},{"dataIndex":"bookProfitCenter","header":"Book/Profit Center","id":22,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":23,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":24,"sortable":true,"width":150},{"dataIndex":"titleTransferQty","header":"Title Transfer Quantity","id":25,"sortable":true,"width":150},{"dataIndex":"provInvoicedQty","header":"Prov. Invoiced Quantity","id":26,"sortable":true,"width":150},{"dataIndex":"finalInvoicedQty","header":"Final Invoiced Quantity","id":27,"sortable":true,"width":150},{"dataIndex":"payInCurrency","header":"Pay-In Currency","id":28,"sortable":true,"width":150}]',
             NULL, NULL,
             '[     
                                 {header: "Contract Ref No.", width: 150, sortable: true, dataIndex: "contractRefNo"}, 
                                 {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"}, 
                                 {header: " Item No", width: 150, sortable: true, dataIndex: "itemNo"}
                              ]',
             NULL, 'dealmanagement/listing/ListOfDeal.jsp',
             '/private/js/dealmanagement/listing/listOfDeal.js'
            );
INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url,
             screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('DEAL_LOI', 'List Of Inventory',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"stockStatus","header":"Stock Status","id":28,"sortable":true,"width":150}]'',
             NULL, NULL,
             ''[     
                                 {header: "Contract Ref No.", width: 150, sortable: true, dataIndex: "contractRefNo"}, 
                                 {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"}
                              ]',
             NULL, NULL,
             '[     
                                 {header: "Contract Ref No.", width: 150, sortable: true, dataIndex: "contractRefNo"}, 
                                 {header: "Contract Type", width: 150, sortable: true, dataIndex: "stockStatus"}, 
                                 {header: " Item No", width: 150, sortable: true, dataIndex: "itemNo"}
                              ]',
             'dealmanagement/listing/DealManagementPopupButton.jsp',
             'dealmanagement/listing/listOfInventory.jsp',
             '/private/js/dealmanagement/listing/listOfInventory.js'
            );

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('DEAL_LIST', 'DEAL_LIST', 'Operation', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('DEAL_LIST_1', 'DEAL_LIST', 'View Modify Deal', 1, 2, 
    NULL, 'function(){viewModifyDeal();}', NULL, '7', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('DEAL_LIST_2', 'DEAL_LIST', 'Delete Deal', 2, 2, 
    NULL, 'function(){delateDeal();}', NULL, '7', NULL);



