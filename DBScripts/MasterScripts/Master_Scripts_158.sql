

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('L6', 'List Of Pledge', 6, 2, '/metals/loadListofPledgeMaterial.action?gridId=PM_LIST', 
    NULL, 'L1', NULL, 'Logistics', NULL);



Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('PM_LIST', 'List Of Pledge', '[ 
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
		name : "pledgedPartyName",
		mapping : "pledgedPartyName"
	},{
		name : "pledgedPartyId",
		mapping : "pledgedPartyId"
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
		name : "pledgedPartyName",
		mapping : "pledgedPartyName"
	},{
		name : "pledgedPartyId",
		mapping : "pledgedPartyId"
	},{
		name : "qty",
		mapping : "qty"
	},{
		name : "qtyUnit",
		mapping : "qtyUnit"
	},{
		name : "qtyUnitId",
		mapping : "qtyUnitId"
	}]', NULL, '/private/jsp/mining/tolling/listing/ListOfPledgeMaterial.jsp', '/private/js/mining/tolling/listing/ListOfPledgeMaterial.js');
