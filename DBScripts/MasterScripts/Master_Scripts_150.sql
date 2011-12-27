Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-MACCT', 'Metal Account Transactions', 23, 2, '/metals/loadListofMetalAccountTransactions.action?gridId=METAL_ACCOUNT_TRANSACTIONS_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);



update AMC_APP_MENU_CONFIGURATION amc set AMC.LINK_CALLED='/metals/loadListofMetalAccountTransactions.action?gridId=MACT_LIST'
where AMC.MENU_ID='TOL-MACCT';




Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MACT_LIST', 'Metal Account Transactions', '[ 
	{
		name : "contractRefNo",
		mapping : "contractRefNo"
	},{
		name : "internalContractRefNo",
		mapping : "internalContractRefNo"
	}, {
		name : "contractItemRefNo",
		mapping : "contractItemRefNo"
	},{
		name : "internalContractItemRefNo",
		mapping : "internalContractItemRefNo"
	},{
		name : "gmrRefNo",
		mapping : "gmrRefNo"
	},{
		name : "internalGmrRefNo",
		mapping : "internalGmrRefNo"
	},{
		name : "stockRefNo",
		mapping : "stockRefNo"
	},{
		name : "internalStockRefNo",
		mapping : "internalStockRefNo"
	},{
		name : "deliveryRefNo",
		mapping : "deliveryRefNo"
	},{
		name : "pcdiRefNo",
		mapping : "pcdiRefNo"
    },{
        name : "counterPartyName",
        mapping : "counterPartyName"
    },{
        name : "counterPartyId",
        mapping : "counterPartyId"
    }, {
        name : "activityName",
        mapping : "activityName"
    },{
        name : "activityId",
        mapping : "activityId"
    },{
        name : "gmrActivityDate",
        mapping : "gmrActivityDate"
    },{
        name : "elementName",
        mapping : "elementName"
    },{
        name : "elementId",
        mapping : "elementId"
    },{
        name : "productName",
		mapping : "productName"
	},{
		name : "productId",
		mapping : "productId"
	},{
		name : "metalQty",
		mapping : "metalQty"
	},{
		name : "metalQtyUnit",
		mapping : "metalQtyUnit"
	},{
		name : "metalQtyUnitId",
		mapping : "metalQtyUnitId"
	} ]', NULL, NULL, 
    '[ 
	{
		name : "contractRefNo",
		mapping : "contractRefNo"
	},{
		name : "internalContractRefNo",
		mapping : "internalContractRefNo"
	}, {
		name : "contractItemRefNo",
		mapping : "contractItemRefNo"
	},{
		name : "internalContractItemRefNo",
		mapping : "internalContractItemRefNo"
	},{
		name : "gmrRefNo",
		mapping : "gmrRefNo"
	},{
		name : "internalGmrRefNo",
		mapping : "internalGmrRefNo"
	},{
		name : "stockRefNo",
		mapping : "stockRefNo"
	},{
		name : "internalStockRefNo",
		mapping : "internalStockRefNo"
	},{
		name : "deliveryRefNo",
		mapping : "deliveryRefNo"
	},{
		name : "pcdiRefNo",
		mapping : "pcdiRefNo"
	},{
		name : "counterPartyName",
		mapping : "counterPartyName"
	},{
		name : "counterPartyId",
		mapping : "counterPartyId"
	}, {
		name : "activityName",
		mapping : "activityName"
	},{
		name : "activityId",
		mapping : "activityId"
	},{
		name : "gmrActivityDate",
		mapping : "gmrActivityDate"
	},{
		name : "elementName",
		mapping : "elementName"
	},{
		name : "elementId",
		mapping : "elementId"
	},{
		name : "productName",
		mapping : "productName"
	},{
		name : "productId",
		mapping : "productId"
	},{
		name : "metalQty",
		mapping : "metalQty"
	},{
		name : "metalQtyUnit",
		mapping : "metalQtyUnit"
	},{
		name : "metalQtyUnitId",
		mapping : "metalQtyUnitId"
	} ]', NULL, '/private/jsp/mining/tolling/listing/ListOfMetalAccountTransactions.jsp', '/private/js/mining/tolling/listing/ListOfMetalAccountTransactions.js');





Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('AssayType', 'Provisional Assay', 'N', 1);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('AssayType', 'Final Assay', 'N', 2);

   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('AssayType', 'Contractual Assay', 'N', 3);

