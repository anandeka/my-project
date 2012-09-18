
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('AS4', 'List Of Assay Exchange Elements', 4, 2, '/metals/loadListOfAssayExchangeElement.action?gridId=EVD_LIST', 
    NULL, 'AS1', NULL, 'Assay', 'APP-PFL-N-160', 
    'N');


INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url, screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('EVD_LIST', 'List of Assay Exchange Elements',
             '[     
                                  {header: "Contract Ref No", width: 90, sortable: true, dataIndex: "contractRefNo"},
                                  {header: "Counterparty ", width: 90, sortable: true, dataIndex: "cpName"},
                                  {header: "Gmr Ref No", width: 90, sortable: true, dataIndex: "gmrRefNo"},
                                  {header: "Stock Ref No", width: 90, sortable: true, dataIndex: "stockRefNo"},
                                  {header: "Element", width: 90, sortable: true, dataIndex: "elementName"},
                                  {header: "SubLot Ref No", width: 90, sortable: true, dataIndex: "sublotNo"},
                                  {header: "Self Assay Ref No", width: 90, sortable: true, dataIndex: "cpAssayRefNo"},
                                  {header: "Self Assay", width: 90, sortable: true, dataIndex: "selfAssayValue"},
                                  {header: "Cp Assay Ref No", width: 90, sortable: true, dataIndex: "cpAssayRefNo"},
                                  {header: "Cp Assay", width: 90, sortable: true, dataIndex: "cpAssayValue"},
                                  {header: "Diffrentail Analysis", width: 90, sortable: true, dataIndex: "diffAssayValue"},
                                  {header: "Self Split Limit", width: 90, sortable: true, dataIndex: "selfAssaySplitLimit"},
                                  {header: "Cp Split Limit", width: 90, sortable: true, dataIndex: "cpAssaySplitLimit"},
                                  {header: "Cp Split Limit", width: 90, sortable: true, dataIndex: "cpAssaySplitLimit"},
                                  {header: "Wet Weight", width: 90, sortable: true, dataIndex: "dryWeight"},
                                  {header: "Dry Weight", width: 90, sortable: true, dataIndex: "wetWeight"},
                                  {header: "Dry/Wet Weight Unit", width: 90, sortable: true, dataIndex: "wetWeightUnitName"},
                                  {header: "Diffrence in Payable Qty", width: 90, sortable: true, dataIndex: "diffPayableQty"},
                                  {header: "Split Quantity", width: 90, sortable: true, dataIndex: "diffAssayValue"},
                                {header: "Provisional Price", width: 90, sortable: true, dataIndex: "provPrice"},
                            	{header: "Currency Unit", width: 90, sortable: true, dataIndex: "provPriceUnitName"},
                            	{header: "Economic Value", width: 90, sortable: true, dataIndex: "economicValue"},
                            	{header: "Last Updated On", width: 90, sortable: true, dataIndex: "lastUpdatedOn"}
                              ]',
             NULL, NULL,
             '[ 
                               {name: "evdId", mapping: "evdId"}, 
                               {name: "wnsRefNo", mapping: "wnsRefNo"}, 
                               {name: "selfAssayRefNo", mapping: "selfAssayRefNo"}, 
                               {name: "cpAssayRefNo", mapping: "cpAssayRefNo"}, 
                               {name: "stockId", mapping: "stockId"}, 
                               {name: "stockRefNo", mapping: "stockRefNo"}, 
                               {name: "sublotNo", mapping: "sublotNo"}, 
                               {name: "selfAssayValue", mapping: "contractRefNo"}, 
                               {name: "cpAssayValue", mapping: "cpAssayValue"}, 
                               {name: "diffAssayValue", mapping: "diffAssayValue"}, 
                               {name: "diffPayableQty", mapping: "diffPayableQty"}, 
                               {name: "splitPayableQty", mapping: "splitPayableQty"}, 
                               {name: "provPrice", mapping: "provPrice"}, 
                               {name: "economicValue", mapping: "economicValue"}, 
                               {name: "provPriceUnitId", mapping: "provPriceUnitId"}, 
                               {name: "provPriceUnitName", mapping: "provPriceUnitName"}, 
                               {name: "qtyUnitId", mapping: "qtyUnitId"}, 
                               {name: "qtyUnitName", mapping: "qtyUnitName"}, 
                               {name: "curId", mapping: "curId"}, 
                               {name: "curName", mapping: "curName"}, 
                               {name: "selfAssaySplitLimit", mapping: "selfAssaySplitLimit"}, 
                               {name: "cpAssaySplitLimit", mapping: "cpAssaySplitLimit"}, 
                               {name: "elementId", mapping: "elementId"}, 
                               {name: "elementName", mapping: "elementName"}, 
                               {name: "isDeleted", mapping: "isDeleted"}, 
                               {name: "dryWeight", mapping: "dryWeight"}, 
                               {name: "wetWeight", mapping: "wetWeight"}, 
                               {name: "wetWeightUnitId", mapping: "wetWeightUnitId"}, 
                               {name: "wetWeightUnitName", mapping: "wetWeightUnitName"}, 
                               {name: "elementType", mapping: "elementType"}, 
                               {name: "isDeductable", mapping: "isDeductable"},
                               {name: "internalContractRefNo", mapping: "internalContractRefNo"},
                               {name: "contractRefNo", mapping: "contractRefNo"},
                               {name: "internalGmrRefNo", mapping: "internalGmrRefNo"},
                               {name: "cpId", mapping: "cpId"}, 
                               {name: "cpName", mapping: "cpName"}, 
                               {name: "gmrRefNo", mapping: "gmrRefNo"},
                               {name: "assayValueUnitId", mapping: "assayValueUnitId"},
                               {name: "assayValueUnitName", mapping: "assayValueUnitName"},
                               {name: "pcarId", mapping: "pcarId"},
                               {name: "lastUpdatedOn", mapping: "lastUpdatedOn"}   
                               ]',
             NULL, '/private/jsp/assay/listOfEconomicValueDetail.jsp',
             'private/js/assay/listOfEconomicValueDetail.js'
            );



Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EVD-OP', 'EVD_LIST', 'Operations', 2, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EVD-1', 'EVD_LIST', 'Calculate Economic Value', 1, 2, 
    NULL, 'function(){updateEconomicValueDetail()}', NULL, 'EVD-OP', NULL);

INSERT INTO AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 VALUES
   ('CALCULATE_ECONOMIC_VALUE', 'Assay ', 'Calculate Economic Value', 'N', 'Calculate Economic Value', 
    'N', NULL);