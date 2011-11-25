set define off;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('MINING_TOL-M4', 'Mining Tolling Contract Items', 4, 2, '/metals/loadMiningContractItemList.action?method=loadTollingContractItemList&gridId=MINING_TOLLING_LOCI', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MINING_TOLLING_LOCI', 'List of Tolling Contract Items', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractNo","header":"Contract Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"itemRefNo","header":"Contract Item Ref. No.","id":2,"sortable":true,"width":150},{"dataIndex":"partnershipType","header":"Contract Type","id":3,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":4,"sortable":true,"width":150},{"dataIndex":"bookProfitCenter","header":"Book/Profit Center","id":5,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":6,"sortable":true,"width":150},{"dataIndex":"counterParty","header":"CP Name","id":7,"sortable":true,"width":150},{"dataIndex":"product","header":"Product","id":8,"sortable":true,"width":150},{"dataIndex":"quality","header":"Quality","id":9,"sortable":true,"width":150},{"dataIndex":"quotaMonth","header":"Quota Period","id":10,"sortable":true,"width":150},{"dataIndex":"incotermLocation","header":"INCO Term & Location","id":11,"sortable":true,"width":150},{"dataIndex":"qty","header":"Item Quantity","id":12,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":14,"sortable":true,"width":150},{"dataIndex":"openQty","header":"Open Quantity","id":13,"sortable":true,"width":150},{"dataIndex":"origin","header":"Origin","id":15,"sortable":true,"width":150}]', NULL, NULL, 
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
                                {name: "origin", mapping: "origin"}
                               ]', NULL, 'mining/tolling/listing/listOfTollingContractItems.jsp', '/private/js/mining/tolling/listing/listOfTollingContractItems.js');




Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_TOLL_1', 'MINING_TOLLING_LOCI', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_TOLL_2', 'MINING_TOLLING_LOCI', 'Mark For Tolling', 1, 2, 
    NULL, 'function(){loadMarkForTolling();}', NULL, 'MINING_TOLL_1', NULL);
    
    
    




