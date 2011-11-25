Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M13', 'Shipment Against Conversion Contract GMR', 13, 2, '/metals/loadListOfMiningTollingGMR.action?gridId=MTGMR_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);



Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MTGMR_LIST', 'List Of Shipment Against Conversion Contract GMR', '[ 
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
    } ]', NULL, '/private/jsp/mining/tolling/ListOfMiningTollingGMR.jsp', '/private/js/mining/tolling/ListOfMiningTollingGMR.js');

