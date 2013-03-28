

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('PricedandProvInvoiced', 'Arrived&Priced/Unpriced/Partial Priced & Prov Inv', 12, 3, '/metals/loadPricedandProvInvoiced.action?gridId=PPI', 
    NULL, 'LRPTS', 'APP-ACL-N1085', 'Reports', 'APP-PFL-N-187', 
    'N');




Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('PPI', 'Priced And ProvInvoiced', '[{"dataIndex":"","gmrRefNo":true,"header":"<div class=\"x-grid3-hd-checker\"><subst>;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"productName","header":"Product","id":1,"sortable":true,"width":160}]', 'Finance', '/metals/loadPricedandProvInvoiced.do?method=loadPricedandProvInvoicedList', 
    '[{name: ''gmrRefNo'', mapping: ''gmrRefNo''},
                        {name: ''counterPartyName'', mapping: ''counterPartyName''},   
                        {name: ''metalName'', mapping: ''metalName''},
                        {name: ''containedQty'', mapping: ''containedQty''},
                        {name: ''payableQty'', mapping: ''payableQty''},  
                        {name: ''priceFixedQty'', mapping: ''priceFixedQty''},            
                        {name: ''unPricedQty'', mapping: ''unPricedQty''},
                        {name: ''qtyUnit'', mapping: ''qtyUnit''},
                        {name: ''paPayableAmount'', mapping: ''paPayableAmount''},
                        {name: ''payInCurrency'', mapping: ''payInCurrency''},
                        {name: ''paPrice'', mapping: ''paPrice''},
                        {name: ''priceUnit'', mapping: ''priceUnit''},
                        {name: ''fxPriceToPayIn'', mapping: ''fxPriceToPayIn''},
                        {name: ''priceFixationPrice'', mapping: ''priceFixationPrice''},
                        {name: ''pricedQtyPriceUnit'', mapping: ''pricedQtyPriceUnit''},
                        {name: ''pricedValue'', mapping: ''pricedValue''},
                        {name: ''pricingValueUnit'', mapping: ''pricingValueUnit''},
                        {name: ''pricedValueInPayInCCY'', mapping: ''pricedValueInPayInCCY''},
                        {name: ''recType'', mapping: ''recType''}
                      ]', NULL, '/private/jsp/invoice/listing/PricedandProvInvoiced.jsp', '/private/js/invoice/listing/PricedandProvInvoiced.js');





Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('arrivedPricedandProvSearch', 'GMR Ref No', 'N', 1);