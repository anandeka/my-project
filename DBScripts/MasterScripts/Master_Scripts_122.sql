SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('tollingListElementsSearch', 'Contract Item Ref No', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('tollingListElementsSearch', 'Contract Ref.No.', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('tollingListElementsSearch', 'DeliveryItemRefNo', 'N', 2);



INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called,
             icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID
            )
     VALUES ('TOL-M12', 'Contract Position By Element', 12, 2,
             '/metals/loadTollingContractItemListByElements.action?method=loadTollingContractItemListByElements&gridId=TOLLING_LOCIBE',
             NULL, 'TOL-M', NULL, 'Tolling', NULL);




Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TOLLING_LOCIBE', 'List of Mining Contract Item Elements', '[{header: "Contract Ref.No.", width: 150, sortable: true, dataIndex: "contractRefNo"},
{header: "Delivery Ref.No.", width: 150, sortable: true, dataIndex: "deliveryRefNo"},
{header: "Contract Item Ref.No.", width: 150, sortable: true, dataIndex: "contractItemRefNo"},
{header: "Input Product", width: 150, sortable: true, dataIndex: "inputProduct"},
{header: "Input Quality", width: 150, sortable: true, dataIndex: "inputQuality"},
{header: "Element", width: 150, sortable: true, dataIndex: "element"},
{header: "Executed Percentage", width: 150, sortable: true, dataIndex: "executedPercentage"},
{header: "Payable/Returnable", width: 150, sortable: true, dataIndex: "payableReturnable"},
{header: "Payable/Returnable Qty.", width: 150, sortable: true, dataIndex: "payableReturnableQty"}]', NULL, NULL, 
    '[ {name: "contractRefNo", mapping: "contractRefNo"},
  {name: "deliveryRefNo", mapping: "deliveryRefNo"},
  {name: "contractItemRefNo", mapping: "contractItemRefNo"},
  {name: "inputProduct", mapping: "inputProduct"},
  {name: "inputQuality", mapping: "inputQuality"},
  {name: "element", mapping: "element"},
  {name: "executedPercentage", mapping: "executedPercentage"},
  {name: "payableReturnable", mapping: "payableReturnable"},
  {name: "payableReturnableQty", mapping: "payableReturnableQty"}]', NULL, '/private/jsp/mining/physical/listing/listOfMiningContractItemElements.jsp', '/private/js/mining/physical/listing/listOfMiningContractItemElements.js');

