set define off;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('SMELTER_LIST', 'Receive Material', '[ 
    {
        name : "smelter",
        mapping : "smelter"
    }, {
        name : "element",
        mapping : "element"
    }, {
        name : "debtQuality",
        mapping : "debtQuality"
    } ]', NULL, NULL, 
    '[ 
    {
        name : "smelter",
        mapping : "smelter"
    }, {
        name : "element",
        mapping : "element"
    }, {
        name : "debtQuality",
        mapping : "debtQuality"
    } ]', NULL, '/private/jsp/mining/tolling/listing/listOfReceiveMaterial.jsp', '/private/js/mining/tolling/listing/listOfReceiveMaterial.js');

