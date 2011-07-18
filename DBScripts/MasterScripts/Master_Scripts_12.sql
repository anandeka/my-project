




SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('CDC-M6', 'TC RC Charges', 5, 2, '/metals/loadDeductionChargeDetails.action?method=loadDeductionChargeDetails', 
    NULL, 'CDC-M1', NULL, 'Market Data', NULL);
COMMIT;




SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('CDC-M5', 'Valuation Curve Setup', 4, 2, '/metals/loadListOfValuationCurve.action?method=loadListOfValuationCurve&gridId=VCS_LIST', 
    NULL, 'CDC-M1', NULL, 'Market Data', NULL);
COMMIT;



SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('VCS_LIST', 'List Of Valuation Curve', '[ {
        name : "vcsId",
        mapping : "vcsId"
	}, {
		name : "productName",
		mapping : "productName"
	}, {
		name : "valuationCurveName",
		mapping : "valuationCurveName"
	}, {
		name : "priceUnitName",
		mapping : "priceUnitName"
	}, {
		name : "applicableFor",
		mapping : "applicableFor"
	}  ]', NULL, NULL, 
    '[ {
		name : "vcsId",
		mapping : "vcsId"
	}, {
		name : "productName",
		mapping : "productName"
	}, {
		name : "valuationCurveName",
		mapping : "valuationCurveName"
	}, {
		name : "priceUnitName",
		mapping : "priceUnitName"
	}, {
		name : "applicableFor",
		mapping : "applicableFor"
	}  ]', NULL, '/private/jsp/m2m/listOfValuationCurves.jsp', '/private/js/m2m/listOfValuationCurves.js');
COMMIT;






SET DEFINE OFF;
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('VCS_LIST-1', 'VCS_LIST', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('VCS_LIST-1-1', 'VCS_LIST', 'Add', 2, 2, 
    NULL, 'function(){addVCS();}', NULL, 'VCS_LIST-1', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('VCS_LIST-1-2', 'VCS_LIST', 'Modify', 3, 2, 
    NULL, 'function(){modifyVCS();}', NULL, 'VCS_LIST-1', NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('VCS_LIST-1-3', 'VCS_LIST', 'Delete', 4, 2, 
    NULL, 'function(){deleteVCS();}', NULL, 'VCS_LIST-1', NULL);
COMMIT;






SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Quality Premium', 'Quality Premium');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Product Premium', 'Product Premium');
COMMIT;



SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('applicableFor', 'Quality Premium', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('applicableFor', 'Product Premium', 'N', 2);
COMMIT;





SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Treatment Charges', 'Treatment Charges');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Refining Charges', 'Refining Charges');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Penalties', 'Penalties');
COMMIT;

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('applicableForConcentrate', 'Treatment Charges', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('applicableForConcentrate', 'Refining Charges', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('applicableForConcentrate', 'Penalties', 'N', 3);
COMMIT;



