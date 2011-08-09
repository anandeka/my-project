

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOS-Blend', 'LOS', 'Blend Analyser', 2, 2, 
    NULL, 'function(){blendAnalysingDetails();}', NULL, 'LOB-OP', NULL); 




Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('BLEND_LOS', 'List of Stocks For Blend Analyzing', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"stockRefNo","header":"Stock Ref No.","id":1,"sortable":true,"width":100},
   {"dataIndex":"gmrRefNo","header":"GMR Ref. No.","id":2,"sortable":true,"width":100},
   {"dataIndex":"concItemRefNoString","header":"Contract Item Ref. No.","id":3,"sortable":true,"width":100},
   {"dataIndex":"cmaContractRefNo","header":"CMA Contract Item Ref. No.","id":4,"sortable":true,"width":100},
   {"dataIndex":"vesselVoyageName","header":"Vessel / Voyage Name","id":5,"sortable":true,"width":100},
   {"dataIndex":"supplierCPName","header":"Supplier CP Name","id":6,"sortable":true,"width":100},
   {"dataIndex":"buyerCPName","header":"Buyer CP Name","id":7,"sortable":true,"width":100},
   {"dataIndex":"productName","header":"Product","id":8,"sortable":true,"width":100},
   {"dataIndex":"origin","header":"Origin","id":9,"sortable":true,"width":100},
   {"dataIndex":"quality","header":"Quality","id":10,"sortable":true,"width":100},
   {"align":"right","dataIndex":"noOfBags","header":"Number Of Bags","id":11,"sortable":true,"width":100},
   {"align":"left","dataIndex":"cropYear","header":"Crop Year","id":12,"sortable":true,"width":100},
   {"dataIndex":"warehouseName","header":"Warehouse (Shed)","id":13,"sortable":true,"width":100},
   {"dataIndex":"warehouseCountryName","header":"Location","id":14,"sortable":true,"width":100},
   {"dataIndex":"warehouseReceiptNo","header":"Warehouse Receipt No","id":15,"sortable":true,"width":100},
   {"align":"right","dataIndex":"totalQty","header":"Original Quantity","id":16,"sortable":true,"width":100},
   {"align":"right","dataIndex":"netWeight","header":"Current Quantity","id":17,"sortable":true,"width":100},
   {"align":"right","dataIndex":"soldOutQty","header":"Released Quantity","id":18,"sortable":true,"width":100},
   {"align":"right","dataIndex":"movedOutQty","header":"Internally moved Quantity","id":19,"sortable":true,"width":100},
   {"align":"right","dataIndex":"writeOffQty","header":"Written off Quantity","id":20,"sortable":true,"width":100},
   {"align":"right","dataIndex":"allocatedQty","header":"Allocated Quantity","id":21,"sortable":true,"width":100},
   {"align":"right","dataIndex":"unAllocatedQty","header":"Unallocated Quantity","id":22,"sortable":true,"width":100},
   {"dataIndex":"stockStatus","header":"Stock Status","id":23,"sortable":true,"width":100},
   {"dataIndex":"packingCondition","header":"Packing Condition","id":24,"sortable":true,"width":100},
   {"dataIndex":"bankName","header":"Financing Bank","id":25,"sortable":true,"width":100},
   {"dataIndex":"bankAccountName","header":"Bank Account","id":26,"sortable":true,"width":100},
   {"dataIndex":"storageDate","header":"Storing Date","id":27,"sortable":true,"width":100},
   {"dataIndex":"truckRailBLWhrRefNo","header":"BL No,Truck/Rail Receipt No,Warehouse Ref No.","id":28,"sortable":true,"width":100},
   {"dataIndex":"truckRailBLWhrDate","header":"BL,Truck/Rail Receipt,Warehouse Ref Date","id":29,"sortable":true,"width":100},
   {"dataIndex":"inventoryStatus","header":"Inventory Status","id":30,"sortable":true,"width":100},
   {"dataIndex":"contractType","header":"Contract Type","id":31,"sortable":true,"width":100}
   ]', NULL, NULL, NULL, 
        '/private/jsp/logistics/blending/ListOfStockPopBlendAnalyzing.jsp',
        '/private/jsp/logistics/blending/StockBlendAnalyzerPopUpListingFilter.jsp',
        '/metals/private/js/logistics/blending/ListOfStockPopUpBlendAnalyzer.js'
   );

	