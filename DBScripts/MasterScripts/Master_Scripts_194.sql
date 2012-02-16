SET DEFINE OFF;

Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TOLLING_POOL', 'List Of Pools for allocation', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"poolName","header":"Pool Name","id":1,"sortable":true,"width":100},{"dataIndex":"poolRefNo","header":"Pool Ref No.","id":2,"sortable":true,"width":100},{"dataIndex":"product","header":"Product","id":3,"sortable":true,"width":100},{"dataIndex":"origin","header":"Origin","id":4,"sortable":true,"width":100},{"dataIndex":"quality","header":"Quality","id":5,"sortable":true,"width":100},{"dataIndex":"cropYear","header":"Year","id":6,"sortable":true,"width":100},{"dataIndex":"warehouse","header":"Warehouse ","id":7,"sortable":true,"width":100},{"dataIndex":"currentQuantity","header":"Current Quantity","id":8,"sortable":true,"width":100},{"dataIndex":"unAllocatedQuantity","header":"Unallocated Qty","id":9,"sortable":true,"width":100}]', NULL, '/app/allocateFromPool.do?method=getPoolWarehouse', 
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
                  ]', '/private/jsp/logistics/allocation/popup/stockAllocationPopupButton.jsp', '/private/jsp/mining/tolling/listing/poolAllocationPopUp.jsp', '/metals/private/js/mining/tolling/listing/listOfPoolAllocated.js');

