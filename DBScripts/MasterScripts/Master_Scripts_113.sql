SET DEFINE OFF;
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('MIN_LOC', 'List Of Mining Contracts', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},
{"dataIndex":"contractRefNo","header":"Contract Ref No.","id":1,"sortable":true,"width":150},
{"dataIndex":"issueDate","header":"Issue Date","id":2,"sortable":true,"width":150},
{"dataIndex":"cpName","header":"CP Name","id":3,"sortable":true,"width":150},
{"dataIndex":"contractType","header":"Contract Type","id":4,"sortable":true,"width":150},
{"dataIndex":"assetclass","header":"Product ","id":5,"sortable":true,"width":150},
{"dataIndex":"productGroupType","header":"Product Type ","id":6,"sortable":true,"width":150},
{"dataIndex":"noOfItems","header":"No. Of. Delivery Items","id":7,"sortable":true,"width":150},
{"dataIndex":"contractqty","header":"Contract Quanity","id":8,"sortable":true,"width":150},
{"dataIndex":"contractStatus","header":"Contract Status","id":9,"sortable":true,"width":150},
{"dataIndex":"org","header":"Org.","id":10,"sortable":true,"width":150},
{"dataIndex":"strategy","header":"Strategy","id":11,"sortable":true,"width":150},
{"dataIndex":"trader","header":"Trader","id":12,"sortable":true,"width":150},
{"dataIndex":"executedQty","header":"Executed Quantity","id":13,"sortable":true,"width":150},
{"dataIndex":"allocatedQty","header":"Allocated Quantity","id":14,"sortable":true,"width":150},
{"dataIndex":"passThrough","header":"Pass Through","id":15,"sortable":true,"width":150},
{"dataIndex":"provInvoiceQty","header":"Prov. Invoice Quantity","id":16,"sortable":true,"width":150},
{"dataIndex":"finalInvoiceQty","header":"Final Invoice Quantity","id":17,"sortable":true,"width":150},
{"dataIndex":"payInCurrency","header":"Pay-In Currency","id":18,"sortable":true,"width":150}]', NULL, '/metals/loadListOfMiningContracts.action', 
    '[   
                              {header: "Contract Ref No.", width: 150, sortable: true,renderer:contractOrderStatus, dataIndex: "contractRefNo"},
                                 {header: "Issue Date", width: 150, sortable: true, dataIndex: "issueDate"},
                                 {header: "CP Name", width: 150, sortable: true, dataIndex: "cpName"},
                                 {header: "Contract Type", width: 150, sortable: true, dataIndex: "contractType"},
                                 
                                 {header: "Product ", width: 150, sortable: true, dataIndex: "assetclass"},
                                 {header: "Product Type ", width: 150, sortable: true, dataIndex: "productGroupType"},
                                 {header: "No. Of. Delivery Items", width: 150, sortable: true, dataIndex: "noOfItems"},
                                 {header: "Contract Quanity", width: 150, sortable: true, dataIndex: "contractqty"},
                                 {header: "Pass Through", width: 150, sortable: true, dataIndex: "passThrough"},
                                 {header: "Contract Status", width: 150, sortable: true, dataIndex: "contractStatus"}
                              ]', NULL, 'mining/physical/listing/listOfMiningContracts.jsp', '/private/js/mining/physical/listing/listOfMiningContracts.js');

