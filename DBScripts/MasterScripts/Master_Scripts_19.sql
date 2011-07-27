UPDATE AXM_ACTION_MASTER SET ACTION_NAME = 'Mark For Tolling'
WHERE ACTION_ID = 'MARK_FOR_TOLLING';

UPDATE AXM_ACTION_MASTER SET ACTION_NAME = 'Returned Output'
WHERE ACTION_ID = 'RECORD_OUT_PUT_TOLLING';

UPDATE AMC_APP_MENU_CONFIGURATION SET LINK_CALLED = '/metals/loadListOfTollingInProcessStock.action?gridId=TIPS_LIST'
WHERE MENU_ID = 'TOL-M1';
UPDATE AMC_APP_MENU_CONFIGURATION SET LINK_CALLED = '/metals/loadListOfTollingGMR.action?gridId=TGMR_LIST'
WHERE MENU_ID = 'TOL-M2';

UPDATE GMC_GRID_MENU_CONFIGURATION SET MENU_DISPLAY_NAME = 'Returned Output'
WHERE MENU_ID = 'ROTOLL_2';


SET DEFINE OFF;
INSERT INTO GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 VALUES
   ('TIPS_LIST', 'List Of In Process Stock', '[ 
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
    } ]', NULL, '/private/jsp/tolling/logistics/listOfTollingInProcessStock.jsp', '/private/js/tolling/logistics/listOfTollingInProcessStock.js');


INSERT INTO GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 VALUES
   ('TGMR_LIST', 'List Of Tolling GMR', '[ 
    {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "internalGmrRefNo",
        mapping : "internalGmrRefNo"
    }, {
        name : "gmrRefNo",
        mapping : "gmrRefNo"
    }, {
        name : "actionNo",
        mapping : "actionNo"
    }, {
        name : "internalActionRefNo",
        mapping : "internalActionRefNo"
    }, {
        name : "activity",
        mapping : "activity"
    }, {
        name : "activityDate",
        mapping : "activityDate"
    }, {
        name : "activityRefNo",
        mapping : "activityRefNo"
    }, {
        name : "latestActionId",
        mapping : "latestActionId"
    }, {
        name : "latestActionName",
        mapping : "latestActionName"
    }, {
        name : "warehouseProfileId",
        mapping : "warehouseProfileId"
    }, {
        name : "warehouse",
        mapping : "warehouse"
    }, {
        name : "shedName",
        mapping : "shedName"
    }, {
        name : "productName",
        mapping : "productName"
    }, {
        name : "qualityName",
        mapping : "qualityName"
    }, {
        name : "gmrQty",
        mapping : "gmrQty"
    }, {
        name : "outputQty",
        mapping : "outputQty"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "qtyUnit",
        mapping : "qtyUnit"
    }, {
        name : "cpProfileId",
        mapping : "cpProfileId"
    }, {
        name : "cpName",
        mapping : "cpName"
    }, {
        name : "internalContractItemRefNo",
        mapping : "internalContractItemRefNo"
    }, {
        name : "tollingContractItemRefNo",
        mapping : "tollingContractItemRefNo"
    }, {
        name : "internalContractRefNo",
        mapping : "internalContractRefNo"
    }, {
        name : "contractRefNo",
        mapping : "contractRefNo"
    } ]', NULL, NULL, 
    '[ 
    {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "internalGmrRefNo",
        mapping : "internalGmrRefNo"
    }, {
        name : "gmrRefNo",
        mapping : "gmrRefNo"
    }, {
        name : "actionNo",
        mapping : "actionNo"
    }, {
        name : "internalActionRefNo",
        mapping : "internalActionRefNo"
    }, {
        name : "activity",
        mapping : "activity"
    }, {
        name : "activityDate",
        mapping : "activityDate"
    }, {
        name : "activityRefNo",
        mapping : "activityRefNo"
    }, {
        name : "latestActionId",
        mapping : "latestActionId"
    }, {
        name : "latestActionName",
        mapping : "latestActionName"
    }, {
        name : "warehouseProfileId",
        mapping : "warehouseProfileId"
    }, {
        name : "warehouse",
        mapping : "warehouse"
    }, {
        name : "shedName",
        mapping : "shedName"
    }, {
        name : "productName",
        mapping : "productName"
    }, {
        name : "qualityName",
        mapping : "qualityName"
    }, {
        name : "gmrQty",
        mapping : "gmrQty"
    }, {
        name : "outputQty",
        mapping : "outputQty"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "qtyUnit",
        mapping : "qtyUnit"
    }, {
        name : "cpProfileId",
        mapping : "cpProfileId"
    }, {
        name : "cpName",
        mapping : "cpName"
    }, {
        name : "internalContractItemRefNo",
        mapping : "internalContractItemRefNo"
    }, {
        name : "tollingContractItemRefNo",
        mapping : "tollingContractItemRefNo"
    }, {
        name : "internalContractRefNo",
        mapping : "internalContractRefNo"
    }, {
        name : "contractRefNo",
        mapping : "contractRefNo"
    } ]', NULL, '/private/jsp/tolling/logistics/listOfTollingGMR.jsp', '/private/js/tolling/logistics/listOfTollingGMR.js');
SET DEFINE ON;