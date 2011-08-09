Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('PID1', 'List Of Collaterals', 5, 3, '/metals/loadListOfCollaterals.action?gridId=COLLATERAL_LIST', 
    NULL, 'F2', NULL, 'Finance', NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LODI_1_4', 'LODI', 'Attach LC', 5, 2, 
    NULL, 'function(){attachLCDetails();}', NULL, 'LODI_1', NULL);


SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('COLLATERAL_LIST', 'List Of Collaterals ', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractNo","header":"Contract Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":2,"sortable":true,"width":150},{"dataIndex":"counterParty","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"partnershipType","header":"Execution Type","id":4,"sortable":true,"width":150},{"dataIndex":"tradeType","header":"Product Group Type","id":5,"sortable":true,"width":150},{"dataIndex":"itemStatus","header":"Item Status","id":6,"sortable":true,"width":150},{"dataIndex":"deliveryRefNo","header":"Delivery Ref. No.","id":7,"sortable":true,"width":150},{"dataIndex":"itemRefNo","header":"Item Ref. No.","id":8,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":9,"sortable":true,"width":150},{"dataIndex":"quality","header":"Quality","id":10,"sortable":true,"width":150},{"dataIndex":"attributes","header":"Attributes","id":11,"sortable":true,"width":150},{"dataIndex":"issueDate","header":"Issue Date","id":12,"sortable":true,"width":150},{"dataIndex":"quotaMonth","header":"Quota Period","id":13,"sortable":true,"width":150},{"dataIndex":"location","header":"Location","id":14,"sortable":true,"width":150},{"dataIndex":"traxysOrg","header":"Org","id":15,"sortable":true,"width":150},{"dataIndex":"incotermLocation","header":"INCO Term & Location","id":16,"sortable":true,"width":150},{"dataIndex":"qty","header":"Item Quantity","id":17,"sortable":true,"width":150},{"dataIndex":"openQty","header":"Open Qty.","id":18,"sortable":true,"width":150},{"dataIndex":"allocatedQty","header":"Allocated Qty.","id":19,"sortable":true,"width":150},{"dataIndex":"incoterm","header":"Incoterm","id":20,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":21,"sortable":true,"width":150},{"dataIndex":"bookProfitCenter","header":"Book/Profit Center","id":22,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":23,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":24,"sortable":true,"width":150},{"dataIndex":"titleTransferQty","header":"Title Transfer Quantity","id":25,"sortable":true,"width":150},{"dataIndex":"provInvoicedQty","header":"Prov. Invoiced Quantity","id":26,"sortable":true,"width":150},{"dataIndex":"finalInvoicedQty","header":"Final Invoiced Quantity","id":27,"sortable":true,"width":150},{"dataIndex":"payInCurrency","header":"Pay-In Currency","id":28,"sortable":true,"width":150}]', NULL, NULL, 
    '[     
                                 {header: "Contract Ref No.", width: 150, sortable: true, dataIndex: "contractRefNo"}, 
                                 {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"}, 
                                 {header: " Item No", width: 150, sortable: true, dataIndex: "itemNo"}
                              ]', NULL, NULL, '/private/js/physical/paymentInstrument/listing/listOfCollaterals.js');
