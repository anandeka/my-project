Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID)
 Values
   ('TOL-M14', 'List Of Call offs', 19, 2, '/metals/loadMiningListOfCallOffs.action?gridId=MLOCO', 
    NULL, 'TOL-M', NULL, 'Tolling', NULL);


SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MLOCO', 'List Of Mining Call-Offs', '[     
                                  {header: "Contract Ref. No.", width: 150, sortable: true, dataIndex: "contractRefNo"},
                                  {header: "Delivery Item Ref. No.", width: 150, sortable: true, dataIndex: "deliveryItemRefNo"},
                                  {header: "Call Off Type", width: 150, sortable: true, dataIndex: "callOffType"},
                                  {header: "Called-Off Date", width: 150, sortable: true, dataIndex: "calledOffDate"},
                                  {header: "Called_Off Qty", width: 150, sortable: true, dataIndex: "calledOffQty"},
                                  {header: "Qty UoM", width: 150, sortable: true, dataIndex: "qtyUoM"},
                                  {header: "Inco-term-Delivery Loc", width: 150, sortable: true, dataIndex: "incotermLocation"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "quality"},
                                  {header: "Pricing", width: 150, sortable: true, dataIndex: "pricing"},
                                  {header: "QP", width: 150, sortable: true, dataIndex: "qp"},
                                  {header: "Element", width: 150, sortable: true, dataIndex: "elementName"}
                             ]', NULL, '/metals/loadMiningListOfCallOffs.action', 
    '[     
                                  {header: "Contract Ref. No.", width: 150, sortable: true, dataIndex: "contractRefNo"},
                                  {header: "Delivery Item Ref. No.", width: 150, sortable: true, dataIndex: "deliveryItemRefNo"},
                                  {header: "Call Off Type", width: 150, sortable: true, dataIndex: "callOffType"},
                                  {header: "Called-Off Date", width: 150, sortable: true, dataIndex: "calledOffDate"},
                                  {header: "Called_Off Qty", width: 150, sortable: true, dataIndex: "calledOffQty"},
                                  {header: "Qty UoM", width: 150, sortable: true, dataIndex: "qtyUoM"},
                                  {header: "Inco-term-Delivery Loc", width: 150, sortable: true, dataIndex: "incotermLocation"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "quality"},
                                  {header: "Pricing", width: 150, sortable: true, dataIndex: "pricing"},
                                  {header: "QP", width: 150, sortable: true, dataIndex: "qp"},
                                  
                             ]', NULL, 'mining/physical/listing/listOfMiningCallOffs.jsp', '/private/js/mining/physical/listing/listOfMiningCallOffs.js');



Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MLOCO_1', 'MLOCO', 'Operations', 1, 1, 
    NULL, 'function(){}', NULL, NULL, NULL);
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('MLOCO_1_1', 'MLOCO', 'Delete', 1, 2, 
    NULL, 'function(){deleteCallOff();}', NULL, 'MLOCO_1', NULL);


UPDATE GMC_GRID_MENU_CONFIGURATION 
SET LINK_CALLED ='function(){loadListOfPricingCallOff();}'
WHERE MENU_ID = 'MLODI_1_3'

UPDATE GMC_GRID_MENU_CONFIGURATION 
SET LINK_CALLED ='function(){loadListOfPhysicalCallOff();}'
WHERE MENU_ID = 'MLODI_1_2'