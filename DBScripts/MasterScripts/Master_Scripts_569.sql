SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('HCL', 'List Of Hegde Correction', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"priceFixationRefNo","header":"Exposure Ref. No.","id":1,"sortable":true,"width":150},{"dataIndex":"hedgeCorrectionDate","header":"Qty Exposure Date","id":2,"sortable":true,"width":150},{"dataIndex":"fxFixationDate","header":"Fx Fixation Date","id":3,"sortable":true,"width":150},{"dataIndex":"asOfDate","header":"Price Fixation Date","id":4,"sortable":true,"width":150},{"dataIndex":"fxCorrectionDate","header":"Fx Exposure Date","id":5,"sortable":true,"width":150},{"dataIndex":"qtyFixed","header":"Qty","id":6,"sortable":true,"width":150},{"dataIndex":"qtyUnitName","header":"Qty Unit Name","id":7,"sortable":true,"width":150},{"dataIndex":"userPrice","header":"Price","id":8,"sortable":true,"width":150},{"dataIndex":"priceUnitName","header":"Priceing Unit Name","id":9,"sortable":true,"width":150},{"dataIndex":"fxRate","header":"Fx","id":10,"sortable":true,"width":150},{"dataIndex":"priceInPayInCurrency","header":"Price In Pay In Currency","id":11,"sortable":true,"width":150},{"dataIndex":"payInPriceUnitName","header":"Pay In Unit Name","id":12,"sortable":true,"width":150},{"dataIndex":"amtInPayInCurrency","header":"Amount","id":13,"sortable":true,"width":150},{"dataIndex":"currencyName","header":"Currency","id":14,"sortable":true,"width":150},{"dataIndex":"activityName","header":"Activity Name","id":15,"sortable":true,"width":150},{"dataIndex":"actionRefNo","header":"Action Ref No","id":16,"sortable":true,"width":150},{"dataIndex":"eventSequenceNo","header":"Event No","id":17,"sortable":true,"width":150},{"dataIndex":"isHedgeCorrectionDuringQp","header":"Is Hedge Correction During Qp","id":18,"sortable":true,"width":150}]', NULL, NULL, 
    '[ {
        name : "priceFixationRefNo",
        mapping : "priceFixationRefNo"
    }, {
        name : "hedgeCorrectionDate",
        mapping : "hedgeCorrectionDate"
    }, {
        name : "fxFixationDate",
        mapping : "fxFixationDate"
    }, {
        name : "asOfDate",
        mapping : "asOfDate"
    }, {
        name : "fxCorrectionDate",
        mapping : "fxCorrectionDate"
    }, {
        name : "qtyFixed",
        mapping : "qtyFixed"
    }, {
        name : "qtyUnitName",
        mapping : "qtyUnitName"
    }, {
        name : "userPrice",
        mapping : "userPrice"
    }, {
        name : "priceUnitName",
        mapping : "priceUnitName"
    }, {
        name : "fxRate",
        mapping : "fxRate"
    }, {
        name : "priceInPayInCurrency",
        mapping : "priceInPayInCurrency"
    }, {
        name : "payInPriceUnitName",
        mapping : "payInPriceUnitName"
    }, {
        name : "amtInPayInCurrency",
        mapping : "amtInPayInCurrency"
    }, {
        name : "currencyName",
        mapping : "currencyName"
    }, {
        name : "activityName",
        mapping : "activityName"
    }, {
        name : "actionRefNo",
        mapping : "actionRefNo"
    }, {
        name : "eventSequenceNo",
        mapping : "eventSequenceNo"
    },
    {   name : "isHedgeCorrectionDuringQp",
        mapping : "isHedgeCorrectionDuringQp"
    } 
]', NULL, '/private/jsp/physical/listing/listOfHedgeCorrection.jsp', '/private/js/physical/listing/listOfHedgeCorrection.js');
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOFM_UTILITY', 'List Of Free Metal Utility', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"freeMetalUtilityRefNo","header":"Free Metal Utility Ref. No","id":1,"sortable":true,"width":150},{"dataIndex":"cpName","header":"Smelter","id":2,"sortable":true,"width":150},{"header":"Free Metal","id":3,"sortable":false,"width":150},{"dataIndex":"qpMonthYear","header":"QP Pricing","id":4,"sortable":false,"width":150},{"dataIndex":"yearMonthOfConsumption","header":"Consumption Month/Year","id":5,"sortable":true,"width":150},{"dataIndex":"runBy","header":"Run By","id":6,"sortable":true,"width":150},{"dataIndex":"runOn","header":"Run On","id":7,"sortable":true,"width":150},{"dataIndex":"status","header":"Status","id":8,"sortable":true,"width":150}]', 'Finance', '/metals/loadListOfFreeMetalUtility.action', 
    '[ {name : ''utilityHeaderId'',mapping : ''utilityHeaderId''}, 
  {name : ''freeMetalUtilityRefNo'',mapping : ''freeMetalUtilityRefNo''},
  {name : ''cpName'',mapping : ''cpName''},
  {name : ''qpMonthYear'',mapping : ''qpMonthYear''},
  {name : ''yearMonthOfConsumption'',mapping : ''yearMonthOfConsumption''},
  {name : ''runBy'',mapping : ''runBy''},
  {name : ''runOn'',mapping : ''runOn''},
  {name : ''status'',mapping : ''status''} ]', NULL, '/private/jsp/mining/physical/pricing/freemetalpricing/listOfFreeMetalUtility.jsp', '/private/js/mining/physical/pricing/freemetalpricing/listOfFreeMetalUtility.js');
COMMIT;


SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Qty Exposure Date', 'Qty Exposure Date');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Price Fixation Date', 'Price Fixation Date');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Fx Fixation Date', 'Fx Fixation Date');
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Fx Exposure Date', 'Fx Exposure Date');
COMMIT;



SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ishedgecorrectionduringqp', 'No', 'N', 2);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ishedgecorrectionduringqp', 'Yes', 'N', 1);
COMMIT;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('pricefixationdates', 'Qty Exposure Date', 'N', 2);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('pricefixationdates', 'Price Fixation Date', 'N', 2);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('pricefixationdates', 'Fx Fixation Date', 'N', 2);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('pricefixationdates', 'Fx Exposure Date', 'N', 2);