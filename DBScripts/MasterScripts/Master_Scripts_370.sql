SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Premium', 'Premium');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Fixed TC Charges', 'Fixed TC Charges');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Fixed RC Charges', 'Fixed RC Charges');
COMMIT;

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ChargeNames', 'Commercial Fee', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ChargeNames', 'Premium', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ChargeNames', 'Fixed TC Charges', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ChargeNames', 'Fixed RC Charges', 'N', 1);
COMMIT;

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ChargeTypes', 'Rate', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ChargeTypes', 'Absolute', 'N', 1);
COMMIT;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('AC', 'Additional Charges', 3, 2, '/metals/loadListOfAdditionalCharges.action?gridId=LOAC', 
    NULL, 'F1', 'APP-ACL-N1093', 'Finance', 'APP-PFL-N-187', 
    'N');

set Define Off
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, DEFAULT_RECORD_MODEL_STATE,
    SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS, URL,OTHER_URL,TAB_ID)
 Values
   ('LOAC', 'Additional Charges', '[ {header : "Smelter",
		width : 150,
		sortable : true,
		dataIndex : "smelter"
	},  {
		header : "Quality",
		width : 150,
		sortable : true,
		dataIndex : "quality"
	}, {
		header : "Product",
		width : 150,
		sortable : true,
		dataIndex : "product"
	} , {
		header : "Charge Name",
		width : 150,
		sortable : true,
		dataIndex : "chargeName"
	} , {
		header : "Charge Type",
		width : 150,
		sortable : true,
		dataIndex : "chargeType"
	} , {
		header : "Charge",
		width : 150,
		sortable : true,
		dataIndex : "charge"
	}, {
		header : "From Date",
		width : 150,
		sortable : true,
		dataIndex : "fromDate"
	}, {
		header : "To Date",
		width : 150,
		sortable : true,
		dataIndex : "toDate"
	}, {
		header : "Dry/Wet",
		width : 150,
		sortable : true,
		dataIndex : "weightRateBasis"
	}, {
		header : "FX Rate",
		width : 150,
		sortable : true,
		dataIndex : "fxRate"
	}, {
		header : "Element",
		width : 150,
		sortable : true,
		dataIndex : "elementName"
	}]', '[ {name : "smelter",
		mapping : "smelter"
	}, {
		name : "quality",
		mapping : "quality"
	}, {
		name : "product",
		mapping : "product"
	},{
		name : "chargeName",
		mapping : "chargeName"
	}, {
		name : "chargeType",
		mapping : "chargeType"
	}, {
		name : "charge",
		mapping : "charge"
	},{
		name : "fromDate",
		mapping : "fromDate"
	}, {
		name : "toDate",
		mapping : "toDate"
	}, {
		name : "weightRateBasis",
		mapping : "weightRateBasis"
	}, {
		name : "fxRate",
		mapping : "fxRate"
	}, {
		name : "elementName",
		mapping : "elementName"
	}]', '/private/jsp/invoice/ListOfAdditionalCharges.jsp', '/private/js/invoice/ListOfAdditionalCharges.js','','','');




