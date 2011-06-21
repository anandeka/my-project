update GM_GRID_MASTER gm
set GM.DEFAULT_COLUMN_MODEL_STATE='[     
                                  {header: "Contract Ref. No.", width: 150, sortable: true, dataIndex: "contractRefNo"},
                                  {header: "Delivery Item Ref. No.", width: 150, sortable: true, dataIndex: "deliveryItemRefNo"},
                                  {header: "Call Off Type", width: 150, sortable: true, dataIndex: "callOffType"},
                                  {header: "Called-Off Date", width: 150, sortable: true, dataIndex: "calledOffDate"},
                                  {header: "Called_Off Qty", width: 150, sortable: true, dataIndex: "calledOffQty"},
                                  {header: "Qty UoM", width: 150, sortable: true, dataIndex: "qtyUoM"},
                                  {header: "Inco-term-Delivery Loc", width: 150, sortable: true, dataIndex: "incotermLocation"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "quality"},
                                  {header: "Pricing", width: 150, sortable: true, dataIndex: "pricing"},
                                  {header: "QP", width: 150, sortable: true, dataIndex: "qp"}
                             ]'
    ,GM.DEFAULT_RECORD_MODEL_STATE='[     
                                  {header: "Contract Ref. No.", width: 150, sortable: true, dataIndex: "contractRefNo"},
                                  {header: "Delivery Item Ref. No.", width: 150, sortable: true, dataIndex: "deliveryItemRefNo"},
                                  {header: "Call Off Type", width: 150, sortable: true, dataIndex: "callOffType"},
                                  {header: "Called-Off Date", width: 150, sortable: true, dataIndex: "calledOffDate"},
                                  {header: "Called_Off Qty", width: 150, sortable: true, dataIndex: "calledOffQty"},
                                  {header: "Qty UoM", width: 150, sortable: true, dataIndex: "qtyUoM"},
                                  {header: "Inco-term-Delivery Loc", width: 150, sortable: true, dataIndex: "incotermLocation"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "quality"},
                                  {header: "Pricing", width: 150, sortable: true, dataIndex: "pricing"},
                                  {header: "QP", width: 150, sortable: true, dataIndex: "qp"}
                             ]'
                             
      where GM.GRID_ID ='LOCO';   



Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('P71', 'List Of Price Process', 1, 3, '/metals/loadListOfPriceProcess.action?gridId=LOPP', 
    NULL, 'CDC-MM-9', NULL, 'Derivative', NULL);


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('LOPP', 'List Of Price Process', '[     
                                    {header: "As Of Date", width: 150, sortable: true, dataIndex: "asOfDate"}, 
                                    {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
                                    {header: "Status", width: 150, sortable: true, dataIndex: "status"},
                                    {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
                                    {header: "Data Dump Time", width: 150, sortable: true, dataIndex: "dataDumpTime"},
                                    {header: "Price Process Log Detail", width: 150, sortable: true, renderer:pricingProcessLogDetail, dataIndex: "priceProcessLogDetail"},
                                    {header: "Price Fixed Derivatives", width: 150, sortable: true, dataIndex: "priceFixedDerivatives"},
                                    {header: "Price Fix Failures Derivatives", width: 150, sortable: true, dataIndex: "priceFixFailuresDerivatives"},
                                    {header: "Price Fixed Treasury", width: 150, sortable: true, dataIndex: "priceFixedTreasury"},
                                    {header: "Price Fix Failures Treasury", width: 150, sortable: true, dataIndex: "priceFixFailuresTreasury"}
                             ]', NULL, '/metals/loadListOfPriceProcess.action', 
    '[     
                                    {header: "As Of Date", width: 150, sortable: true, dataIndex: "asOfDate"}, 
                                    {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
                                    {header: "Status", width: 150, sortable: true, dataIndex: "status"},
                                    {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
                                    {header: "Data Dump Time", width: 150, sortable: true, dataIndex: "dataDumpTime"},
                                    {header: "Price Process Log Detail", width: 150, sortable: true, renderer:pricingProcessLogDetail, dataIndex: "priceProcessLogDetail"},
                                    {header: "Price Fixed Derivatives", width: 150, sortable: true, dataIndex: "priceFixedDerivatives"},
                                    {header: "Price Fix Failures Derivatives", width: 150, sortable: true, dataIndex: "priceFixFailuresDerivatives"},
                                    {header: "Price Fixed Treasury", width: 150, sortable: true, dataIndex: "priceFixedTreasury"},
                                    {header: "Price Fix Failures Treasury", width: 150, sortable: true, dataIndex: "priceFixFailuresTreasury"}
                             ]', NULL, 'periodend/listOfPriceProcess.jsp', '/private/js/periodend/listOfPriceProcess.js');
