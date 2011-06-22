Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('AS2', 'List Of Assay', 2, 2, '/metals/loadListOfAssay.action?gridId=LOAD', 
    NULL, 'AS1', NULL, 'Assay', NULL);

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('AS1', 'Assay', 19, 1, NULL, 
    NULL, NULL, NULL, 'Assay', NULL);


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('AS3', 'List Of Weighing and Sampling', 3, 2, '/metals/loadListOfAssayFinalization.action?gridId=LOAFD', 
    NULL, 'AS1', NULL, 'Assay', NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOGA', 'LOG', 'Assay', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOGA-1', 'LOG', 'New Provisional Assay', 1, 2, 
    NULL, 'function(){loadNewAssay();}', NULL, 'LOGA', NULL);

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOAD', 'List of Assay', '[     
                                  {header: "Lot No.", width: 150, sortable: true, dataIndex: "lotNo"},
                                  {header: "Used For Assay Exchange", width: 150, sortable: true, dataIndex: "usedForAssayExchange"},
                                  {header: "Assay Ref. No.", width: 150, sortable: true, dataIndex: "assayRefNo"},
                                  {header: "Our Ref. No.", width: 150, sortable: true, dataIndex: "ourRefNo"},
                                  {header: "External Ref. No.", width: 150, sortable: true, dataIndex: "externalRefNo"},
                                  {header: "Assay Type", width: 150, sortable: true, dataIndex: "assayType"},
                                  {header: "Net Wet Wt.", width: 150, sortable: true, dataIndex: "netWetWt"},
                                  {header: "Net Wet Wt. UoM", width: 150, sortable: true, dataIndex: "netWetWtUoM"},
                                  {header: "Assay Details", width: 150, sortable: true, dataIndex: "assayDetails"},
                                  {header: "Contract No.", width: 150, sortable: true, dataIndex: "contractNo"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "quality"},
                                  {header: "Stock Status", width: 150, sortable: true, dataIndex: "stockStatus"},
                                  {header: "Available Qty", width: 150, sortable: true, dataIndex: "availableQty"},
                                  {header: "Organization", width: 150, sortable: true, dataIndex: "organization"},
                                  {header: "Location", width: 150, sortable: true, dataIndex: "location"},
                                  {header: "Assay Received Form", width: 150, sortable: true, dataIndex: "assayReceivedForm"},
                                  {header: "Assayer", width: 150, sortable: true, dataIndex: "assayer"},
                                  {header: "Sampling Date", width: 150, sortable: true, dataIndex: "samplingDate"},
                                  {header: "Assay Received Date", width: 150, sortable: true, dataIndex: "assayReceivedDate"},
                                  {header: "Activity Name", width: 150, sortable: true, dataIndex: "activityName"},
                                  {header: "Activity Ref. No.", width: 150, sortable: true, dataIndex: "activityRefNo"},
                                  {header: "Contract Item No.", width: 150, sortable: true, dataIndex: "contractItemNo"},
                                  {header: "Delivery Item No.", width: 150, sortable: true, dataIndex: "deliveryItemNo"}                         
                              ]', 'Logistics', '/app/voyageAllocationList.do?method=getListOfAllocationGroup', 
    '[
                    {name: "allocationGrpId", mapping: "allocationGrpId"},
                    {name: "salesContractRefNo", mapping: "salesContractRefNo"},
                    {name: "productSpec", mapping: "productSpec"},
                    {name: "profitCenter", mapping: "profitCenter"},
                    {name: "deliveryPeriod", mapping: "deliveryPeriod"},
                    {name: "qtyUnit", mapping: "qtyUnit"}, 
                    {name: "contractAllocation", mapping: "contractAllocation"},
                    {name: "fromStock", mapping: "fromStock"},
                    {name: "fromOpen", mapping: "fromOpen"},  
                    {name: "fromPool", mapping: "fromPool"},
                    {name: "totalAllocatedQty", mapping: "totalAllocatedQty"},
                    {name: "titleTransferStatus", mapping: "titleTransferStatus"}            
                  ]', NULL, '/private/jsp/assay/listOfAssay.jsp', 'private/js/assay/listOfAssay.js');




Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOAFD', 'List of Assay Finalization', '[     
                              	{header: "Contract No.", width: 150, sortable: true, dataIndex: "contractNo"},
                              	{header: "Counterparty", width: 150, sortable: true, dataIndex: "counterparty"},
                              	{header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"},
                              	{header: "Activity Ref. No.", width: 150, sortable: true, dataIndex: "activityRefNo"},
                              	{header: "Activity Type", width: 150, sortable: true, dataIndex: "activityType"},
                              	{header: "No. of Lots", width: 150, sortable: true, dataIndex: "noOfLots"},
                              	{header: "All Lot Finalizad", width: 150, sortable: true, dataIndex: "allLotFinalizad"},
                              	{header: "Finalized By", width: 150, sortable: true, dataIndex: "finalizedBy"},
                              	{header: "Finalized On", width: 150, sortable: true, dataIndex: "finalizedOn"}
                              ]', 'Logistics', '/app/voyageAllocationList.do?method=getListOfAllocationGroup', 
    '[ 
                                {name: "contractNo", mapping: "contractNo"}, 
                                {name: "counterparty", mapping: "counterparty"}, 
                                {name: "contractType", mapping: "contractType"},
                                {name: "activityRefNo", mapping: "activityRefNo"}, 
                                {name: "activityType", mapping: "activityType"}, 
                                {name: "noOfLots", mapping: "noOfLots"}, 
                                {name: "allLotFinalizad", mapping: "allLotFinalizad"}, 
                                {name: "finalizedBy", mapping: "finalizedBy"}, 
                                {name: "finalizedOn", mapping: "finalizedOn"}
                               ] ', NULL, '/private/jsp/assay/listOfAssayFinalization.jsp', 'private/js/assay/listOfAssayFinalization.js');


