INSERT INTO IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 VALUES
   ('PK_SPQ', 'SPQ', 'SEQ_SPQ');

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('PurchaseContractItemRefNo', 'Purchase Contract Item Ref. No.');


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('allocStockSearchCriteria', 'PurchaseContractItemRefNo', 'N', 4);


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('aflaotAllocSearchCriteria', 'PurchaseContractItemRefNo', 'N', 4);

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('ALLOC_AFLOAT_TRAN', 'List of Stocks In Afloat Transhippment', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\"><subst>;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"stockNo","header":"Stock Ref No.","id":1,"sortable":true,"width":75},{"dataIndex":"contractRefNo","header":"Contract Ref No.","id":2,"sortable":true,"width":75},{"dataIndex":"gmrRefNo","header":"GMR Ref No.","id":3,"sortable":true,"width":75},{"dataIndex":"productSpecs","header":"Product Specs","id":4,"sortable":true,"width":160},{"dataIndex":"warehouse","header":"Warehouse","id":5,"sortable":true,"width":160},{"dataIndex":"warehouseRefNo","header":"Warehouse Ref. No.","id":6,"sortable":true,"width":160},{"dataIndex":"locationCountry","header":"Location","id":7,"sortable":true,"width":100},{"dataIndex":"stockQty","header":"Stock Quantity","id":8,"sortable":true,"width":75},{"dataIndex":"unAllocQty","header":"Unallocated Quantity","id":9,"sortable":true,"width":75},{"dataIndex":"noOfUnits","header":"No. Of Bags","id":10,"sortable":true,"width":160},{"dataIndex":"containerNo","header":"Container No","id":11,"sortable":true,"width":160}]', NULL, NULL, 
    NULL, '/private/jsp/logistics/allocation/popup/stockAllocationPopupButton.jsp', '/private/jsp/logistics/allocation/popup/stockAllocationPopup.jsp', '/metals/private/js/logistics/allocation/listOfAfloatTransStocks.js');

