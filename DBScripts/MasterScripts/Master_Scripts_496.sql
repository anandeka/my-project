


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('OC', 'List Of Other Charges', 14, 3, '/metals/loadListOfOtherCharges.action?gridId=OC', 
    NULL, 'F2', 'APP-ACL-N1085', 'Finance', 'APP-PFL-N-187', 
    'N');


Insert into GM_GRID_MASTER
       (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
        DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
     Values
       ('OC', 'List Of Other Charges', '[{"dataIndex":"","contractRefNo":true,"header":"<div class=\"x-grid3-hd-checker\"><subst>;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"productName","header":"Product","id":1,"sortable":true,"width":160}]', 'Finance', '/metals/loadListOfOtherCharges.do?method=loadOtherChargesList', 
        '[{name: ''contractRefNo'', mapping: ''contractRefNo''},
                {name: ''curCode'', mapping: ''curCode''},
                        {name: ''qtyUnit'', mapping: ''qtyUnit''},
                        {name: ''pcmacId'', mapping: ''pcmacId''},
                        {name: ''intContractRefNo'', mapping: ''intContractRefNo''},
                        {name: ''addnChargeId'', mapping: ''addnChargeId''},
                        {name: ''addnChargeName'', mapping: ''addnChargeName''},
                        {name: ''chargeType'', mapping: ''chargeType''},
                        {name: ''position'', mapping: ''position''},
                        {name: ''rangeMinOp'', mapping: ''rangeMinOp''},
                        {name: ''rangeMinValue'', mapping: ''rangeMinValue''},
                        {name: ''rangeMaxOp'', mapping: ''rangeMaxOp''},
                        {name: ''rangeMaxValue'', mapping: ''rangeMaxValue''},
                        {name: ''rangeUnitId'', mapping: ''rangeUnitId''},
                        {name: ''charge'', mapping: ''charge''},
                        {name: ''chargeCurId'', mapping: ''chargeCurId''},
                        {name: ''chargeRateBasis'', mapping: ''chargeRateBasis''},
                        {name: ''containerSize'', mapping: ''containerSize''},
                        {name: ''fxRate'', mapping: ''fxRate''},
                        {name: ''isActive'', mapping: ''isActive''},
                        {name: ''qtyUnitId'', mapping: ''qtyUnitId''},
                        {name: ''version'', mapping: ''version''},
                        {name: ''isAutomaticCharge'', mapping: ''isAutomaticCharge''}]', NULL, '/private/jsp/invoice/listing/listOfOtherCharges.jsp', '/private/js/invoice/listing/listOfOtherCharges.js');