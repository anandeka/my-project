set define off;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-P7', 'Processing Activity', 7, 2, NULL, 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);





Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-P1', 'New Processing Activity', 1, 3, '/metals/processingActivity.do?method=loadGMRActivity&ActionId=processActivity', 
    NULL, 'TOL-P7', NULL, 'Tolling', NULL);





Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-P2', 'List All', 2, 3, '/metals/loadListOfProcessActivity.action?gridId=LOPA', 
    NULL, 'TOL-P7', NULL, 'Tolling', NULL);


    
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('PROCESS_LOS', 'List of Stocks For Process Activity', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"stockRefNo","header":"Stock Ref No.","id":1,"sortable":true,"width":100},
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
   ]', NULL, NULL, 
    NULL, '/private/jsp/tolling/logistics/ListOfStockPopProcessActivity.jsp', '/private/jsp/tolling/logistics/StockProcessActivityPopUpListingFilter.jsp', '/metals/private/js/tolling/logistics/ListOfStockPopUpProcessActivity.js');



Insert into METAL_DEV_APP.GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('PROCESS_ALLOC_POOL', 'List Of Pools for Process Activity', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"poolName","header":"Pool Name","id":1,"sortable":true,"width":100},{"dataIndex":"poolRefNo","header":"Pool Ref No.","id":2,"sortable":true,"width":100},{"dataIndex":"product","header":"Product","id":3,"sortable":true,"width":100},{"dataIndex":"origin","header":"Origin","id":4,"sortable":true,"width":100},{"dataIndex":"quality","header":"Quality","id":5,"sortable":true,"width":100},{"dataIndex":"cropYear","header":"Year","id":6,"sortable":true,"width":100},{"dataIndex":"warehouse","header":"Warehouse ","id":7,"sortable":true,"width":100},{"dataIndex":"currentQuantity","header":"Current Quantity","id":8,"sortable":true,"width":100},{"dataIndex":"unAllocatedQuantity","header":"Unallocated Qty","id":9,"sortable":true,"width":100}]', NULL, '/app/allocateFromPool.do?method=getPoolWarehouse', 
    '[
                    {name: ''internalPoolId'', mapping: ''internalPoolId''},
                    {name: ''poolQtyUnit'', mapping: ''poolQtyUnit''},
                    {name: ''poolQtyUnitId'', mapping: ''poolQtyUnitId''},
                    {name: ''poolName'', mapping: ''poolName''},
                    {name: ''poolRefNo'', mapping: ''poolRefNo''},
                    {name: ''product'', mapping: ''product''},
                    {name: ''origin'', mapping: ''origin''},
                    {name: ''quality'', mapping: ''quality''},
                    {name: ''cropYear'', mapping: ''cropYear''},
                    {name: ''currentQuantity'', mapping: ''currentQuantity''},
                    {name: ''warehouse'', mapping: ''warehouse''},
                    {name: ''warehouseShed'', mapping: ''warehouseShed''},
                    {name: ''allocatedQuantity'', mapping: ''allocatedQuantity''},
                    {name: ''minUnalllocatedQty'', mapping: ''minUnalllocatedQty''},    
                    {name: ''maxUnalllocatedQty'', mapping: ''maxUnalllocatedQty''},    
                    {name: ''minUnalllocatedQtyString'', mapping: ''minUnalllocatedQtyString''},
                    {name: ''maxUnalllocatedQtyString'', mapping: ''maxUnalllocatedQtyString''},
                    {name: ''productId'', mapping: ''productId''},
                    {name: ''unAllocatedQuantity'', mapping: ''unAllocatedQuantity''}
                  ]', '/private/jsp/tolling/logistics/pooledStockAllocationPopupButton.jsp', '/private/jsp/tolling/logistics/PooledStockProcessActivityPopUpListingFilter.jsp', '/metals/private/js/tolling/logistics/ListOfPooledStockPopUpProcessActivity.js');



Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('blending', 'Blending');
   
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('crushing', 'Crushing');
   
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('sieving', 'Sieving');      

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('stockToWarrant', 'Stock To Warrant');

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('warrantToStock', 'Warrant To Stock');   


Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listActivityType', 'blending', 'N', 1);
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listActivityType', 'crushing', 'N', 2);
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listActivityType', 'sieving', 'N', 3);
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listActivityType', 'stockToWarrant', 'N', 4);
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('listActivityType', 'warrantToStock', 'N', 5);   

Insert into IRC_INTERNAL_REF_NO_CONFIG
   (INTERNAL_REF_NO_KEY, PREFIX, SEQ_NAME)
 Values
   ('PK_PA', 'PA', 'SEQ_PA');


   
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOPA', 'List Of Tolling Process Activity GMR', '[ 
    {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "internalGmrRefNo",
        mapping : "internalGmrRefNo"
    }, {
        name : "gmrRefNo",
        mapping : "gmrRefNo"
    }, {
        name : "actionNo",
        mapping : "actionNo"
    }, {
        name : "internalActionRefNo",
        mapping : "internalActionRefNo"
    }, {
        name : "activity",
        mapping : "activity"
    }, 
    {
        name : "activityType",
        mapping : "activityType"
    }, 
    {
        name : "receiptNo",
        mapping : "receiptNo"
    },
    {
        name : "activityDate",
        mapping : "activityDate"
    }, {
        name : "activityRefNo",
        mapping : "activityRefNo"
    }, {
        name : "latestActionId",
        mapping : "latestActionId"
    }, {
        name : "latestActionName",
        mapping : "latestActionName"
    }, {
        name : "warehouseProfileId",
        mapping : "warehouseProfileId"
    }, {
        name : "warehouse",
        mapping : "warehouse"
    }, {
        name : "shedName",
        mapping : "shedName"
    }, {
        name : "productName",
        mapping : "productName"
    }, {
        name : "qualityName",
        mapping : "qualityName"
    }, {
        name : "gmrQty",
        mapping : "gmrQty"
    }, {
        name : "outputQty",
        mapping : "outputQty"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "qtyUnit",
        mapping : "qtyUnit"
    }, {
        name : "cpProfileId",
        mapping : "cpProfileId"
    }, {
        name : "cpName",
        mapping : "cpName"
    }, {
        name : "internalContractItemRefNo",
        mapping : "internalContractItemRefNo"
    }, {
        name : "tollingContractItemRefNo",
        mapping : "tollingContractItemRefNo"
    }, {
        name : "internalContractRefNo",
        mapping : "internalContractRefNo"
    }, {
        name : "contractRefNo",
        mapping : "contractRefNo"
    } ]', NULL, NULL, 
    '[ 
    {
        name : "corporateId",
        mapping : "corporateId"
    }, {
        name : "internalGmrRefNo",
        mapping : "internalGmrRefNo"
    }, {
        name : "gmrRefNo",
        mapping : "gmrRefNo"
    }, {
        name : "actionNo",
        mapping : "actionNo"
    }, {
        name : "internalActionRefNo",
        mapping : "internalActionRefNo"
    }, {
        name : "activity",
        mapping : "activity"
    }, 
    {
        name : "activityType",
        mapping : "activityType"
    },
    {
        name : "receiptNo",
        mapping : "receiptNo"
    },
    {
        name : "activityDate",
        mapping : "activityDate"
    }, {
        name : "activityRefNo",
        mapping : "activityRefNo"
    }, {
        name : "latestActionId",
        mapping : "latestActionId"
    }, {
        name : "latestActionName",
        mapping : "latestActionName"
    }, {
        name : "warehouseProfileId",
        mapping : "warehouseProfileId"
    }, {
        name : "warehouse",
        mapping : "warehouse"
    }, {
        name : "shedName",
        mapping : "shedName"
    }, {
        name : "productName",
        mapping : "productName"
    }, {
        name : "qualityName",
        mapping : "qualityName"
    }, {
        name : "gmrQty",
        mapping : "gmrQty"
    }, {
        name : "outputQty",
        mapping : "outputQty"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "qtyUnit",
        mapping : "qtyUnit"
    }, {
        name : "cpProfileId",
        mapping : "cpProfileId"
    }, {
        name : "cpName",
        mapping : "cpName"
    }, {
        name : "internalContractItemRefNo",
        mapping : "internalContractItemRefNo"
    }, {
        name : "tollingContractItemRefNo",
        mapping : "tollingContractItemRefNo"
    }, {
        name : "internalContractRefNo",
        mapping : "internalContractRefNo"
    }, {
        name : "contractRefNo",
        mapping : "contractRefNo"
    } ]', NULL, '/private/jsp/tolling/logistics/listOfProcessActivityGMR.jsp', '/private/js/tolling/logistics/listOfProcessActivityGMR.js');



Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TPA_1', 'LOPA', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('TPA-2', 'LOPA', 'Service Invoice Received', 2, 2, 
    NULL, 'function(){loadServiceInvRecvd();}', NULL, 'TPA_1', NULL);