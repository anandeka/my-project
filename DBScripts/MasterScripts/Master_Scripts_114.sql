SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MLODI', 'List Of Mining Delivery Items', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"contractRefNo","header":"Contract No.","id":1,"sortable":true,"width":150},{"dataIndex":"contractType","header":"Contract Type","id":2,"sortable":true,"width":150},{"dataIndex":"cpName","header":"CP Name","id":3,"sortable":true,"width":150},{"dataIndex":"tradeType","header":"Execution Type","id":4,"sortable":true,"width":150},{"dataIndex":"deliveryItemRefNo","header":"Delivery Ref. No.","id":5,"sortable":true,"width":150},{"dataIndex":"assetclass","header":"Product","id":6,"sortable":true,"width":150},{"dataIndex":"qualityName","header":"Quality","id":7,"sortable":true,"width":150},{"dataIndex":"attributes","header":"Attributes","id":8,"sortable":true,"width":150},{"dataIndex":"issueDate","header":"Issue Date","id":9,"sortable":true,"width":150},{"dataIndex":"quotaMonth","header":"Quota Period","id":10,"sortable":true,"width":150},{"dataIndex":"location","header":"Location","id":11,"sortable":true,"width":150},{"dataIndex":"traxysOrg","header":"Org","id":12,"sortable":true,"width":150},{"dataIndex":"incotermLocation","header":"Incoterm & Location","id":13,"sortable":true,"width":150},{"dataIndex":"quotaQty","header":"Quota Quantity(Min)","id":14,"sortable":true,"width":150},{"dataIndex":"quotaQtyUnit","header":"Quota Qty. Unit","id":15,"sortable":true,"width":150},{"dataIndex":"quotaOpenQty","header":"Quota Open Qty.","id":16,"sortable":true,"width":150},{"dataIndex":"allocatedQty","header":"Allocated Qty.","id":17,"sortable":true,"width":150},{"dataIndex":"strategy","header":"Strategy","id":18,"sortable":true,"width":150},{"dataIndex":"bookProfitCenter","header":"Book/Profit Center","id":19,"sortable":true,"width":150},{"dataIndex":"trader","header":"Trader","id":20,"sortable":true,"width":150},{"dataIndex":"qpPricingBasis","header":"QP-Pricing Basis","id":21,"sortable":true,"width":150},{"dataIndex":"qpPricing","header":"QP-Pricing","id":22,"sortable":true,"width":150},{"dataIndex":"pricing","header":"Pricing","id":23,"sortable":true,"width":150},{"dataIndex":"quotaQuantityMax","header":"Quota Quantity(Max)","id":24,"sortable":true,"width":150},{"dataIndex":"quotaQuantityBasis","header":"Quota Quantity Basis","id":25,"sortable":true,"width":150},{"dataIndex":"toBeCalledOffQty","header":"To be called Off Quantity","id":26,"sortable":true,"width":150},{"dataIndex":"calledOffQty","header":"Called Off Quantity","id":27,"sortable":true,"width":150},{"dataIndex":"executedQty","header":"Executed Quantity","id":28,"sortable":true,"width":150},{"dataIndex":"pricingStatus","header":"Pricing Status","id":29,"sortable":true,"width":150},{"dataIndex":"fixedPriceQty","header":"Fixed Price Quantity","id":30,"sortable":true,"width":150},{"dataIndex":"titleTransferQty","header":"Title Transfer Quantity","id":31,"sortable":true,"width":150},{"dataIndex":"provInvoicedQty","header":"Prov. Invoiced Quantity","id":32,"sortable":true,"width":150},{"dataIndex":"finalInvoicedQty","header":"Final Invoiced Quantity","id":33,"sortable":true,"width":150},{"dataIndex":"payInCurrency","header":"Pay-In Currency","id":34,"sortable":true,"width":150},{"dataIndex":"fullfillmentStatus","header":"Fullfillment Status","id":35,"sortable":true,"width":150}]', NULL, '/metals/loadListOfDeliveryItems.action', 
    '[     
                                  {header: "Contract No.", width: 150, sortable: true, dataIndex: "contractRefNo"},
                                  {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"},
                                  {header: "Counter Party", width: 150, sortable: true, dataIndex: "cpName"},
                                  {header: "Trade Type", width: 150, sortable: true, dataIndex: "tradeType"},
                                  {header: "Item Status", width: 150, sortable: true, dataIndex: "itemStatus"},
                                  {header: "Delivery Ref. No.", width: 150, sortable: true,renderer:deliveryItemOrderStatus, dataIndex: "deliveryItemRefNo"},
                                  {header: "Product", width: 150, sortable: true, dataIndex: "assetclass"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "qualityName"},
                                  {header: "Attributes", width: 150, sortable: true, dataIndex: "attributes"},
                                  {header: "Issue Date", width: 150, sortable: true, dataIndex: "issueDate"},
                                  {header: "Quota Month", width: 150, sortable: true, dataIndex: "quotaMonth"},
                                  {header: "Location", width: 150, sortable: true, dataIndex: "location"},
                                  {header: "Traxys Org", width: 150, sortable: true, dataIndex: "traxysOrg"},
                                  {header: "Incoterm & Location", width: 150, sortable: true, dataIndex: "incotermLocation"},
                                  {header: "Pricing", width: 150, sortable: true, dataIndex: "pricing"},
                                  {header: "QP", width: 150, sortable: true, dataIndex: "qp"},
                                  {header: "Quota Qty.", width: 150, sortable: true, dataIndex: "quotaQty"},
                                  {header: "Quota Qty. Unit", width: 150, sortable: true, dataIndex: "quotaQtyUnit"},
                                  {header: "Quota Qty Basis", width: 150, sortable: true, dataIndex: "quotaQtyBasis"},
                                  {header: "Quota Open Qty.", width: 150, sortable: true, dataIndex: "quotaOpenQty"},
                                  {header: "Quota Call-off Qty.", width: 150, sortable: true, dataIndex: "quotaCalloffQty"},
                                  {header: "Quota Delivered/Received Qty.", width: 150, sortable: true, dataIndex: "quotaDeliveredReceivedQty"},
                                  {header: "Quota Invoiced Qty.", width: 150, sortable: true, dataIndex: "quotaInvoicedQty"},
                                  {header: "Quota Price Fixed Qty.", width: 150, sortable: true, dataIndex: "quotaPriceFixedQty"},
                                  {header: "Allocated Qty.", width: 150, sortable: true, dataIndex: "allocatedQty"}
                             ]', NULL, 'mining/physical/listing/listOfMiningDeliveryItems.jsp', 'private/js/mining/physical/listing/listOfMiningDeliveryItems.js');

