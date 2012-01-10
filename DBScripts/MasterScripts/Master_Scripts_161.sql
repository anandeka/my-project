


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-FS', 'Financial Settlements', 25, 2, '/metals/loadListofFinancialSettlements.action?gridId=FS_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);




Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('FS_LIST', 'List Of Financial Settlements', '[ 
	{
		name : "activityDate",
		mapping : "activityDate"
	},{
		name : "gmrRefNo",
		mapping : "gmrRefNo"
	}, {
		name : "internalGmrRefNo",
		mapping : "internalGmrRefNo"
	},{
		name : "supplierName",
		mapping : "supplierName"
	},{
		name : "supplierId",
		mapping : "supplierId"
	},{
		name : "productName",
		mapping : "productName"
	}, {
		name : "productId",
		mapping : "productId"
	},{
		name : "qty",
		mapping : "qty"
	},{
		name : "qtyUnit",
		mapping : "qtyUnit"
	},{
		name : "qtyUnitId",
		mapping : "qtyUnitId"
	}]', NULL, NULL, 
    '[ 
	{
		name : "activityDate",
		mapping : "activityDate"
	},{
		name : "gmrRefNo",
		mapping : "gmrRefNo"
	}, {
		name : "internalGmrRefNo",
		mapping : "internalGmrRefNo"
	},{
		name : "supplierName",
		mapping : "supplierName"
	},{
		name : "supplierId",
		mapping : "supplierId"
	},{
		name : "productName",
		mapping : "productName"
	}, {
		name : "productId",
		mapping : "productId"
	},{
		name : "qty",
		mapping : "qty"
	},{
		name : "qtyUnit",
		mapping : "qtyUnit"
	},{
		name : "qtyUnitId",
		mapping : "qtyUnitId"
	}]', NULL, '/private/jsp/mining/tolling/listing/ListOfFinancialSettlements.jsp', '/private/js/mining/tolling/listing/ListOfFinancialSettlements.js');





Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FS_LIST_1', 'FS_LIST', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);




Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('FS_LIST_1_1', 'FS_LIST', 'Cancel Financial Settlement', 1, 2, 
    NULL, 'function(){cancelFinancialSettlement();}', NULL, 'FS_LIST_1', NULL);



Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('PM_LIST_1', 'PM_LIST', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);



Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('PM_LIST_1_1', 'PM_LIST', 'Cancel Pledge', 1, 2, 
    NULL, 'function(){cancelPledge();}', NULL, 'PM_LIST_1', NULL);


