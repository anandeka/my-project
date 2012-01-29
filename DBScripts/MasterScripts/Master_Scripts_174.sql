
--- CREATE  ACTIVITY   

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_DER_ALLOCATION', 'ModifyDerAlloc', 'Modify Dervative Allocation', 'Y', 'Modify Dervative Allocation', 
    'N', NULL);


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('DERIVATIVE_ALLOCATION', 'DerivativeAlloc', 'Dervative Allocation', 'Y', 'Dervative Allocation', 
    'N', NULL);



Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('ModifyDerAlloc', 'Modify Der. Alloc. Ref No.', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('DerivativeAlloc', 'Derivative Alloc. Ref No.', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MODIFY_DER_ALLOCATION', 'N', 'N', 'activityDate', 'N', 
    NULL, NULL, 'N', 'N');



Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('DERIVATIVE_ALLOCATION', 'N', 'N', 'activityDate', 'N', 
    NULL, NULL, 'N', 'N');




Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_RETURN_MATERIAL', 'GMR Tolling ', 'Tolling Return Material', 'Y', 'Create Return Material', 
    'N', NULL);


Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('ReturnMaterial', 'Return Material Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_RETURN_MATERIAL', 'N', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');




--- CREATE  LINKS 

    
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('MINING_RMA', 'Mining Return Material', 22, 2, '/metals/loadMiningTollingReturnMaterialTabs.action?tabId=returnMaterial&moduleId=returnMaterialCreation&tollingType=Return Material Tolling', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);




Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('MINING_PF', 'Price Fixation', 24, 2, '/metals/loadListOfTollingPriceFixations.action?gridId=TPF_LIST', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);




Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('MINING_DDA', 'Derivative Allocation', 26, 2, '/metals/loadListOfDeAllocation.action?gridId=DERIVATIVE_DEALLOC', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


----- LISTING 

SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('DERIVATIVE_DEALLOC', 'List Of Trade', '[   
    {
        name : "derivativeRefNo",
        mapping : "derivativeRefNo"
    }, {
        name : "profitCenter",
        mapping : "profitCenter"
    }, {
        name : "product",
        mapping : "product"
    }, {
        name : "totalQuantity",
        mapping : "totalQuantity"
    }, {
        name : "qtyPriced",
        mapping : "qtyPriced"
    }, {
        name : "allocatedPhysicalQty",
        mapping : "allocatedPhysicalQty"
    }, {
        name : "deliveryItemRefNo",
        mapping : "deliveryItemRefNo"
    }, {
        name : "priceFixationRefNo",
        mapping : "priceFixationRefNo"
    }, {
        name : "contractType",
        mapping : "contractType"
    }, {
        name : "priceFixationDate",
        mapping : "priceFixationDate"
    }, {
        name : "price",
        mapping : "price"
    }, {
        name : "qpPeriod",
        mapping : "qpPeriod"
    }, {
        name : "instrument",
        mapping : "instrument"
    },{
        name : "exchange",
        mapping : "exchange"
    },{
        name : "tradeType",
        mapping : "tradeType"
    }, {
        name : "deliveryItemPeriod",
        mapping : "deliveryItemPeriod"
    }   ]', NULL, NULL, 
    '[ 
    {
        name : "derivativeRefNo",
        mapping : "derivativeRefNo"
    }, {
        name : "profitCenter",
        mapping : "profitCenter"
    }, {
        name : "product",
        mapping : "product"
    }, {
        name : "totalQuantity",
        mapping : "totalQuantity"
    }, {
        name : "qtyPriced",
        mapping : "qtyPriced"
    }, {
        name : "allocatedPhysicalQty",
        mapping : "allocatedPhysicalQty"
    }, {
        name : "deliveryItemRefNo",
        mapping : "deliveryItemRefNo"
    }, {
        name : "priceFixationRefNo",
        mapping : "priceFixationRefNo"
    }, {
        name : "contractType",
        mapping : "contractType"
    }, {
        name : "priceFixationDate",
        mapping : "priceFixationDate"
    }, {
        name : "price",
        mapping : "price"
    }, {
        name : "qpPeriod",
        mapping : "qpPeriod"
    }, {
        name : "instrument",
        mapping : "instrument"
    },{
        name : "exchange",
        mapping : "exchange"
    }, {
        name : "tradeType",
        mapping : "tradeType"
    }, {
        name : "deliveryItemPeriod",
        mapping : "deliveryItemPeriod"
    } ]', NULL, 'physical/derivative/listing/DerivativeAllocationListingFilter.jsp', '/private/js/physical/derivative/listing/DeAllocationListing.js');

SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TPF_LIST', 'Price Fixations', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\"></div>","hideable":false,"id":"checker","sortable":false,"width":20},
   {"dataIndex":"product","header":"Product","id":1,"sortable":true,"width":150},
   {"dataIndex":"priceFixationRefNo","header":"Price Fixation Ref.No.","id":2,"sortable":true,"width":150},
   {"dataIndex":"contractType","header":"Contract Type","id":3,"sortable":true,"width":150},
   {"dataIndex":"deliveryItemRefNo","header":"Dl Ref.No.","id":4,"sortable":true,"width":150},
   {"dataIndex":"profitCenter","header":"Profit Center","id":5,"sortable":true,"width":150},
   {"dataIndex":"priceFixationDate","header":"Price Fixation Date","id":6,"sortable":true,"width":150},
   {"dataIndex":"price","header":"Price","id":7,"sortable":true,"width":150},
   {"dataIndex":"qpPeriod","header":"QP Period","id":8,"sortable":true,"width":150},
   {"dataIndex":"qtyPriced","header":"Qty.Priced","id":9,"sortable":true,"width":150},
   {"dataIndex":"gmrAllocatedQty","header":"GMR Allocated Qty.","id":10,"sortable":true,"width":150},
   {"dataIndex":"cpName","header":"CP Name","id":11,"sortable":true,"width":150},
   {"dataIndex":"deliveryItemPeriod","header":"Dl Period","id":12,"sortable":true,"width":150},
   {"dataIndex":"hedgeAllocationStatus","header":"Hedge Allocation Status","id":13,"sortable":true,"width":150}]', NULL, NULL, 
    '[ 
                {name: "product", mapping: "product"}, 
                {name: "priceFixationRefNo", mapping: "priceFixationRefNo"},
                {name: "contractType", mapping: "contractType"},
                {name: "deliveryItemRefNo", mapping: "deliveryItemRefNo"},
                {name: "profitCenter", mapping: "profitCenter"},
                {name: "priceFixationDate", mapping: "priceFixationDate"},
                {name: "price", mapping: "price"},
                {name: "qpPeriod", mapping: "qpPeriod"},
                {name: "qtyPriced", mapping: "qtyPriced"},
                {name: "gmrAllocatedQty", mapping: "gmrAllocatedQty"},
                {name: "cpName", mapping: "cpName"},
                {name: "deliveryItemPeriod", mapping: "deliveryItemPeriod"},
                {name: "hedgeAllocationStatus", mapping: "hedgeAllocationStatus"}
                                
                               ]', NULL, 'physical/derivative/listing/ListOfPriceFixations.jsp', '/private/js/physical/derivative/listing/ListOfPriceFixations.js');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_PF', 'TPF_LIST', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_PF_1', 'TPF_LIST', 'Allocate Hedge', 1, 2, 
    NULL, 'function(){loadAllocateHedge();}', NULL, 'MINING_PF', NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_DDA', 'DERIVATIVE_DEALLOC', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MINING_DDA_1', 'DERIVATIVE_DEALLOC', 'Modify Allocation', 1, 2, 
    NULL, 'function(){loadDeAllocation();}', NULL, 'MINING_PF', NULL);




SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('DERIVATIVE_ALLOC', 'List Of Trade', '[   
    {
        name : "derivativeRefNo",
        mapping : "derivativeRefNo"
    }, {
        name : "originalTradeRefNo",
        mapping : "originalTradeRefNo"
    }, {
        name : "tradeDate",
        mapping : "tradeDate"
    }, {
        name : "profitCenter",
        mapping : "profitCenter"
    }, {
        name : "totalQuantity",
        mapping : "totalQuantity"
    }, {
        name : "allocQuantity",
        mapping : "allocQuantity"
    }, {
        name : "trader",
        mapping : "trader"
    }, {
        name : "nominee",
        mapping : "nominee"
    }, {
        name : "extTradeRefNo",
        mapping : "extTradeRefNo"
    }, {
        name : "deliveryDate",
        mapping : "deliveryDate"
    }, {
        name : "tradeType",
        mapping : "tradeType"
    }, {
        name : "clearer",
        mapping : "clearer"
    }, {
        name : "clearerCommission",
        mapping : "clearerCommission"
    }, {
        name : "clearerAccount",
        mapping : "clearerAccount"
    }, {
        name : "broker",
        mapping : "broker"
    }, {
        name : "brokerCommission",
        mapping : "brokerCommission"
    }, {
        name : "purpose",
        mapping : "purpose"
    }, {
        name : "dealType",
        mapping : "dealType"
    }, {
        name : "internalDerRefNo",
        mapping : "internalDerRefNo"
    }, {
        name : "strategy",
        mapping : "strategy"
    }, {
        name : "exchangeInstrument",
        mapping : "exchangeInstrument"
    }, {
        name : "totalLots",
        mapping : "totalLots"
    }, {
        name : "openLots",
        mapping : "openLots"
    }, {
        name : "closedLots",
        mapping : "closedLots"
    }, {
        name : "status",
        mapping : "status"
    }, {
        name : "price",
        mapping : "price"
    }, {
        name : "createdBy",
        mapping : "createdBy"
    }, {
        name : "createdDate",
        mapping : "createdDate"
    }, {
        name : "createdThrough",
        mapping : "createdThrough"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "product",
        mapping : "product"
    }, {
        name : "productId",
        mapping : "productId"
    }   ]', NULL, NULL, 
    '[ 
    {
        name : "derivativeRefNo",
        mapping : "derivativeRefNo"
    }, {
        name : "originalTradeRefNo",
        mapping : "originalTradeRefNo"
    }, {
        name : "tradeDate",
        mapping : "tradeDate"
    }, {
        name : "profitCenter",
        mapping : "profitCenter"
    }, {
        name : "totalQuantity",
        mapping : "totalQuantity"
    }, {
        name : "allocQuantity",
        mapping : "allocQuantity"
    }, {
        name : "trader",
        mapping : "trader"
    }, {
        name : "nominee",
        mapping : "nominee"
    }, {
        name : "extTradeRefNo",
        mapping : "extTradeRefNo"
    }, {
        name : "deliveryDate",
        mapping : "deliveryDate"
    }, {
        name : "tradeType",
        mapping : "tradeType"
    }, {
        name : "clearer",
        mapping : "clearer"
    }, {
        name : "clearerCommission",
        mapping : "clearerCommission"
    }, {
        name : "clearerAccount",
        mapping : "clearerAccount"
    }, {
        name : "broker",
        mapping : "broker"
    }, {
        name : "brokerCommission",
        mapping : "brokerCommission"
    }, {
        name : "purpose",
        mapping : "purpose"
    }, {
        name : "dealType",
        mapping : "dealType"
    }, {
        name : "internalDerRefNo",
        mapping : "internalDerRefNo"
    }, {
        name : "strategy",
        mapping : "strategy"
    }, {
        name : "exchangeInstrument",
        mapping : "exchangeInstrument"
    }, {
        name : "totalLots",
        mapping : "totalLots"
    }, {
        name : "openLots",
        mapping : "openLots"
    }, {
        name : "closedLots",
        mapping : "closedLots"
    }, {
        name : "status",
        mapping : "status"
    }, {
        name : "price",
        mapping : "price"
    }, {
        name : "createdBy",
        mapping : "createdBy"
    }, {
        name : "createdDate",
        mapping : "createdDate"
    }, {
        name : "createdThrough",
        mapping : "createdThrough"
    }, {
        name : "qtyUnitId",
        mapping : "qtyUnitId"
    }, {
        name : "product",
        mapping : "product"
    }, {
        name : "productId",
        mapping : "productId"
    } ]', 'physical/derivative/listing/DerivativeFutureTradeBtn.jsp', 'physical/derivative/listing/DerivativeFutureTradeFilter.jsp', '/private/js/physical/derivative/listing/DerivativeFutureTrade.js');






