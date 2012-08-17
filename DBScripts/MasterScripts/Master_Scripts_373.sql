
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LSMIP', 'List of Stock Moved in Pile', '[ 
     {name: "warehouse", mapping: "warehouse"},
     {name: "shed", mapping: "shed"},
     {name: "pileName", mapping: "pileName"},
     {name: "pileRefNo", mapping: "pileRefNo"},
     {name: "product", mapping: "product"},
     {name: "quality", mapping: "quality"},
     {name: "gmrRefNo", mapping: "gmrRefNo"},
     {name: "gmrActivityDate", mapping: "gmrActivityDate"},
     {name: "stockRefNo", mapping: "stockRefNo"},
     {name: "parentStockRefNo", mapping: "parentStockRefNo"},
     {name: "parentGmrRefNo", mapping: "parentGmrRefNo"},
     {name: "supplerStockRefNo", mapping: "supplerStockRefNo"},
     {name: "supplierGmrRefNo", mapping: "supplierGmrRefNo"},
     {name: "supplierContractRefNo", mapping: "supplierContractRefNo"},
     {name: "supplierContractItemRefNo", mapping: "supplierContractItemRefNo"},
     {name: "originalWetQty", mapping: "originalWetQty"},
     {name: "originalDeductibleQty", mapping: "originalDeductibleQty"},
     {name: "originalDryQty", mapping: "originalDryQty"},
     {name: "stockQtyUnit", mapping: "stockQtyUnit"},
     {name: "elementName", mapping: "elementName"},
     {name: "pricingAssayValue", mapping: "pricingAssayValue"},
     {name: "pricingAssayValueUnit", mapping: "pricingAssayValueUnit"},
     {name: "originalContainedQty", mapping: "originalContainedQty"},
     {name: "originalPayableQty", mapping: "originalPayableQty"},
     {name: "consumedContainedQty", mapping: "consumedContainedQty"},
     {name: "consumedPayableQty", mapping: "consumedPayableQty"},
     {name: "currentContainedQty", mapping: "currentContainedQty"},
     {name: "currentPayableQty", mapping: "currentPayableQty"},
     {name: "qtyUnit", mapping: "qtyUnit"}
         
]', NULL, NULL, 
    '[ 
     {name: "warehouse", mapping: "warehouse"},
     {name: "shed", mapping: "shed"},
     {name: "pileName", mapping: "pileName"},
     {name: "pileRefNo", mapping: "pileRefNo"},
     {name: "product", mapping: "product"},
     {name: "quality", mapping: "quality"},
     {name: "gmrRefNo", mapping: "gmrRefNo"},
     {name: "gmrActivityDate", mapping: "gmrActivityDate"},
     {name: "stockRefNo", mapping: "stockRefNo"},
     {name: "parentStockRefNo", mapping: "parentStockRefNo"},
     {name: "parentGmrRefNo", mapping: "parentGmrRefNo"},
     {name: "supplerStockRefNo", mapping: "supplerStockRefNo"},
     {name: "supplierGmrRefNo", mapping: "supplierGmrRefNo"},
     {name: "supplierContractRefNo", mapping: "supplierContractRefNo"},
     {name: "supplierContractItemRefNo", mapping: "supplierContractItemRefNo"},
     {name: "originalWetQty", mapping: "originalWetQty"},
     {name: "originalDeductibleQty", mapping: "originalDeductibleQty"},
     {name: "originalDryQty", mapping: "originalDryQty"},
     {name: "stockQtyUnit", mapping: "stockQtyUnit"},
     {name: "elementName", mapping: "elementName"},
     {name: "pricingAssayValue", mapping: "pricingAssayValue"},
     {name: "pricingAssayValueUnit", mapping: "pricingAssayValueUnit"},
     {name: "originalContainedQty", mapping: "originalContainedQty"},
     {name: "originalPayableQty", mapping: "originalPayableQty"},
     {name: "consumedContainedQty", mapping: "consumedContainedQty"},
     {name: "consumedPayableQty", mapping: "consumedPayableQty"},
     {name: "currentContainedQty", mapping: "currentContainedQty"},
     {name: "currentPayableQty", mapping: "currentPayableQty"},
     {name: "qtyUnit", mapping: "qtyUnit"}
         
]', '/private/jsp/logistics/poolmanagement/ListOfStockMovedInPileFilter.jsp', '/private/jsp/logistics/poolmanagement/ListOfStockMovedInPile.jsp', '/private/js/logistics/poolmanagement/ListOfStockMovedInPile.js');

------------------------------------------------------------------------------------------------------------

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LFPD', 'List of Feed and Produced Details', '[ 
     {name: "activity", mapping: "activity"},
     {name: "activityDate", mapping: "activityDate"},
     {name: "mftRmNo", mapping: "mftRmNo"},
     {name: "tollingContractItemRefNo", mapping: "tollingContractItemRefNo"},
     {name: "gmrRefNo", mapping: "gmrRefNo"},
     {name: "smelter", mapping: "smelter"},
     {name: "passthrough", mapping: "passthrough"},
     {name: "stockRefNo", mapping: "stockRefNo"},
     {name: "pileName", mapping: "pileName"},
     {name: "wetQty", mapping: "wetQty"},
     {name: "dryQty", mapping: "dryQty"},
     {name: "parentStockRefNumber", mapping: "parentStockRefNumber"},
     {name: "parentGmrRefNumber", mapping: "parentGmrRefNumber"},
     {name: "supplierStockRefNo", mapping: "supplierStockRefNo"},     
     {name: "supplierGmrRefNo", mapping: "supplierGmrRefNo"},
     {name: "suppContractDeliveryItemRefNo", mapping: "suppContractDeliveryItemRefNo"},
     {name: "product", mapping: "product"},
     {name: "stockQuality", mapping: "stockQuality"},
     {name: "qtyUnit", mapping: "qtyUnit"}
     
         
]', NULL, NULL, 
    '[ 
     {name: "activity", mapping: "activity"},
     {name: "activityDate", mapping: "activityDate"},
     {name: "mftRmNo", mapping: "mftRmNo"},
     {name: "tollingContractItemRefNo", mapping: "tollingContractItemRefNo"},
     {name: "gmrRefNo", mapping: "gmrRefNo"},
     {name: "smelter", mapping: "smelter"},
     {name: "passthrough", mapping: "passthrough"},
     {name: "stockRefNo", mapping: "stockRefNo"},
     {name: "pileName", mapping: "pileName"},
     {name: "wetQty", mapping: "wetQty"},
     {name: "dryQty", mapping: "dryQty"},
     {name: "parentStockRefNumber", mapping: "parentStockRefNumber"},
     {name: "parentGmrRefNumber", mapping: "parentGmrRefNumber"},
     {name: "supplierStockRefNo", mapping: "supplierStockRefNo"},     
     {name: "supplierGmrRefNo", mapping: "supplierGmrRefNo"},
     {name: "suppContractDeliveryItemRefNo", mapping: "suppContractDeliveryItemRefNo"},
     {name: "product", mapping: "product"},
     {name: "stockQuality", mapping: "stockQuality"},
     {name: "qtyUnit", mapping: "qtyUnit"}    
         
]', '/private/jsp/mining/tolling/ListOfFeedAndProducedFilter.jsp', '/private/jsp/mining/tolling/ListOfFeedAndProduced.jsp', '/private/js/mining/tolling/ListOfFeedAndProduced.js');


-------------------------------------------------------------------------


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LFPD', 'MTGMR_LIST', 'List of Feed and Produced Details', 7, 2, 
    NULL, 'function(){listOfFeedAndProducedDetails();}', NULL, 'MTGMR_LIST_1', NULL);



-------------------------------------------------------------------------

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('PM-009', 'LOP', 'List of Stock Moved in Pile', 9, 2, 
    'APP-PFL-N-185', 'function(){listOfStockMovedInPile();}', NULL, 'PM-001', 'APP-ACL-N1075');
