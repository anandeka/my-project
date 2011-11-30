
--Add  Reveived Materials link

SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('MINING_RM', 'Mining Receive Materials', 16, 2, '/metals/loadMiningTollingTabs.action?tabId=RecordOutputTollingDetails&moduleId=recordOutputTollingCreation&tollingType=Record Output Tolling', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);

---Add  List of smleter

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('MINING_SMELT', 'Smelter In Process', 15, 2, '/metals/loadListOfReceiveMaterial.action?gridId=SMELTER_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);

--- List of stock popup for MFT

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MINING_TOLL_LOS', 'List of  Stocks For Tolling', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"stockNo","header":"Stock Ref No.","id":1,"sortable":true,"width":75},{"dataIndex":"contractItemRefNo","header":"Contract Item Ref No.","id":2,"sortable":true,"width":75},{"dataIndex":"gmrRefNo","header":"GMR Ref No.","id":3,"sortable":true,"width":75},{"dataIndex":"productName","header":"Product ","id":4,"sortable":true,"width":160},{"dataIndex":"qualityName","header":"Quality","id":5,"sortable":true,"width":160},{"dataIndex":"warehouseCountryName","header":"WarehouseCountryName","id":6,"sortable":true,"width":160},{"dataIndex":"currentQty","header":"Stock Quantity","id":7,"sortable":true,"width":100},{"dataIndex":"duty","header":"Duty","id":8,"sortable":true,"width":75},{"dataIndex":"customs","header":"Custom","id":9,"sortable":true,"width":75},{"dataIndex":"tax","header":"Tax","id":10,"sortable":true,"width":160}]', NULL, NULL, 
    NULL, '/private/jsp/mining/tolling/ListOfStockPopTolling.jsp', '/private/jsp/mining/tolling/StockPopUpListingFilter.jsp', '/metals/private/js/mining/tolling/ListOfStockPopUpTolling.js');



-- Add  link  In Process Stock

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-MFT_IN', 'Mining In Process Stock', 17, 2, '/metals/loadMiningListOfTollingInProcessStock.action?gridId=MINING_TIPS_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


-- List of  In process Stocks

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MINING_TIPS_LIST', 'List Of In Process Stock', '[ 
    {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "internalGrdRefNo",
        mapping : "internalGrdRefNo"
    }, {
        name : "stockRefNo",
        mapping : "stockRefNo"
    }, {
        name : "internalGmrRefNo",
        mapping : "internalGmrRefNo"
    }, {
        name : "gmrRefNo",
        mapping : "gmrRefNo"
    }, {
        name : "internalContractItemRefNo",
        mapping : "internalContractItemRefNo"
    }, {
        name : "contractItemRefNo",
        mapping : "contractItemRefNo"
    }, {
        name : "productId",
        mapping : "productId"
    }, {
        name : "productName",
        mapping : "productName"
    }, {
        name : "qualityId",
        mapping : "qualityId"
    }, {
        name : "qualityName",
        mapping : "qualityName"
    }, {
        name : "elementByProduct",
        mapping : "elementByProduct"
    }, {
        name : "warehouseProfileId",
        mapping : "warehouseProfileId"
    }, {
        name : "warehouse",
        mapping : "warehouse"
    }, {
        name : "shedId",
        mapping : "shedId"
    }, {
        name : "shedName",
        mapping : "shedName"
    }, {
        name : "stockQty",
        mapping : "stockQty"
    }, {
        name : "recordOutputQty",
        mapping : "recordOutputQty"
    }, {
        name : "balanceQty",
        mapping : "balanceQty"
    }, {
        name : "qtyUnit",
        mapping : "qtyUnit"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "inputStockRefNo",
        mapping : "inputStockRefNo"
    } ]', NULL, NULL, 
    '[ 
    {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "internalGrdRefNo",
        mapping : "internalGrdRefNo"
    }, {
        name : "stockRefNo",
        mapping : "stockRefNo"
    }, {
        name : "internalGmrRefNo",
        mapping : "internalGmrRefNo"
    }, {
        name : "gmrRefNo",
        mapping : "gmrRefNo"
    }, {
        name : "internalContractItemRefNo",
        mapping : "internalContractItemRefNo"
    }, {
        name : "contractItemRefNo",
        mapping : "contractItemRefNo"
    }, {
        name : "productId",
        mapping : "productId"
    }, {
        name : "productName",
        mapping : "productName"
    }, {
        name : "qualityId",
        mapping : "qualityId"
    }, {
        name : "qualityName",
        mapping : "qualityName"
    }, {
        name : "elementByProduct",
        mapping : "elementByProduct"
    }, {
        name : "warehouseProfileId",
        mapping : "warehouseProfileId"
    }, {
        name : "warehouse",
        mapping : "warehouse"
    }, {
        name : "shedId",
        mapping : "shedId"
    }, {
        name : "shedName",
        mapping : "shedName"
    }, {
        name : "stockQty",
        mapping : "stockQty"
    }, {
        name : "recordOutputQty",
        mapping : "recordOutputQty"
    }, {
        name : "balanceQty",
        mapping : "balanceQty"
    }, {
        name : "qtyUnit",
        mapping : "qtyUnit"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "inputStockRefNo",
        mapping : "inputStockRefNo"
    } ]', NULL, '/private/jsp/mining/tolling/listOfTollingInProcessStock.jsp', '/private/js/mining/tolling/listOfTollingInProcessStock.js');


