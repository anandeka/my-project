
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-MBT', 'Metal Balance Transfer', 27, 2, '/metals/loadListOfMetalBalanceTransfer.action?gridId=METAL_TRANSFER', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('METAL_TRANSFER', 'Metal Balance Transfer', '[ 
	{
		name : "activityRefNo",
		mapping : "activityRefNo"
	},{
		name : "supplierName",
		mapping : "supplierName"
	},{
		name : "supplierId",
		mapping : "supplierId"
	},{
		name : "toSupplierId",
		mapping : "toSupplierId"
	},{
		name : "toSupplierName",
		mapping : "toSupplierName"
	}, {
		name : "productName",
		mapping : "productName"
	},{
		name : "productId",
		mapping : "productId"
	},{
		name : "movedDebtQty",
		mapping : "movedDebtQty"
	},{
		name : "debtQtyUnit",
		mapping : "debtQtyUnit"
	},{
		name : "debtQtyUnitId",
		mapping : "debtQtyUnitId"
	},{
		name : "activityDate",
		mapping : "activityDate"
	},{
		name : "qualityName",
		mapping : "qualityName"
	},{
		name : "qualityId",
		mapping : "qualityId"
	} ]', NULL, NULL, 
    '[ 
	{
		name : "activityRefNo",
		mapping : "activityRefNo"
	},{
		name : "supplierName",
		mapping : "supplierName"
	},{
		name : "supplierId",
		mapping : "supplierId"
	},{
		name : "toSupplierId",
		mapping : "toSupplierId"
	},{
		name : "toSupplierName",
		mapping : "toSupplierName"
	}, {
		name : "productName",
		mapping : "productName"
	},{
		name : "productId",
		mapping : "productId"
	},{
		name : "movedDebtQty",
		mapping : "movedDebtQty"
	},{
		name : "debtQtyUnit",
		mapping : "debtQtyUnit"
	},{
		name : "debtQtyUnitId",
		mapping : "debtQtyUnitId"
	},{
		name : "activityDate",
		mapping : "activityDate"
	},{
		name : "qualityName",
		mapping : "qualityName"
	},{
		name : "qualityId",
		mapping : "qualityId"
	} ]', NULL, '/private/jsp/mining/tolling/listing/ListOfMetalTransfer.jsp', '/private/js/mining/tolling/listing/ListOfMetalTransfer.js');
