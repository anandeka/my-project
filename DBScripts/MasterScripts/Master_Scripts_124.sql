Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-MACC', 'Metal Accounts', 18, 2, '/metals/loadListofMetalAccount.action?gridId=METAL_ACCOUNT_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);





Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('METAL_ACCOUNT_LIST', 'Metal Accounts', '[ 
    {
        name : "supplierName",
        mapping : "supplierName"
    },{
        name : "supplierId",
        mapping : "supplierId"
    }, {
        name : "productName",
        mapping : "productName"
    },{
        name : "productId",
        mapping : "productId"
    },{
        name : "debtQty",
        mapping : "debtQty"
    },{
        name : "debtQtyUnit",
        mapping : "debtQtyUnit"
    },{
        name : "debtQtyUnitId",
        mapping : "debtQtyUnitId"
    },{
        name : "elementname",
        mapping : "elementname"
    },{
        name : "elementId",
        mapping : "elementId"
    } ]', NULL, NULL, 
    '[ 
    {
        name : "supplierName",
        mapping : "supplierName"
    },{
        name : "supplierId",
        mapping : "supplierId"
    }, {
        name : "productName",
        mapping : "productName"
    },{
        name : "productId",
        mapping : "productId"
    },{
        name : "debtQty",
        mapping : "debtQty"
    },{
        name : "debtQtyUnit",
    	mapping : "debtQtyUnit"
	},{
		name : "debtQtyUnitId",
		mapping : "debtQtyUnitId"
	},{
		name : "elementname",
		mapping : "elementname"
	},{
		name : "elementId",
		mapping : "elementId"
	} ]', NULL, '/private/jsp/mining/tolling/listing/ListOfMetalAccount.jsp', '/private/js/mining/tolling/listing/ListOfMetalAccount.js');