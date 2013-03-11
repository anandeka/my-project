

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('LRPTS', 'Listing Reports', 27, 2, NULL, 
    NULL, 'IEKA-1', NULL, 'Reports', NULL, 
    'N');



Insert into AMC_APP_MENU_CONFIGURATION
       (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
        ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
        IS_DELETED)
     Values
       ('LOAPANI', 'Arrived&Priced/Unpriced/Partial Priced And Not Inv', 11, 3, '/metals/loadListOfArrivedPricedAndNotInvoiced.action?gridId=LOAPANI', 
        NULL, 'LRPTS', 'APP-ACL-N1085', 'Reports', 'APP-PFL-N-187', 
        'N');



Insert into GM_GRID_MASTER
	   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
	    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
	 Values
	   ('LOAPANI', 'List Of Arrived Priced And Not Invoiced', '[{"dataIndex":"","gmrRefNo":true,"header":"<div class=\"x-grid3-hd-checker\"><subst>;</div>","id":"checker","sortable":false,"width":20},{"dataIndex":"productName","header":"Product","id":1,"sortable":true,"width":160}]', 'Finance', '/metals/loadListOfArrivedPricedAndNotInvoiced.do?method=loadArrivedPricedAndNotInvoicedList', 
	    '[{name: ''''gmrRefNo'''', mapping: ''''gmrRefNo''''},
	                    {name: ''''counterPartyName'''', mapping: ''''counterPartyName''''},   
	                    {name: ''''metalName'''', mapping: ''''metalName''''},
	                    {name: ''''containedQty'''', mapping: ''''containedQty''''},
	                    {name: ''''payableQty'''', mapping: ''''payableQty''''},  
	                    {name: ''''priceFixedQty'''', mapping: ''''priceFixedQty''''},            
	                    {name: ''''unPricedQty'''', mapping: ''''unPricedQty''''},
	                    {name: ''''qtyUnit'''', mapping: ''''qtyUnit''''},
	                    {name: ''''paPayableAmount'''', mapping: ''''paPayableAmount''''},
	                    {name: ''''payInCurrency'''', mapping: ''''payInCurrency''''},
	                    {name: ''''paPrice'''', mapping: ''''paPrice''''},
	                    {name: ''''priceUnit'''', mapping: ''''priceUnit''''},
	                    {name: ''''fxPriceToPayIn'''', mapping: ''''fxPriceToPayIn''''},
	                    {name: ''''priceFixationPrice'''', mapping: ''''priceFixationPrice''''},
	                    {name: ''''pricedQtyPriceUnit'''', mapping: ''''pricedQtyPriceUnit''''},
	                    {name: ''''pricedValue'''', mapping: ''''pricedValue''''},
	                    {name: ''''pricingValueUnit'''', mapping: ''''pricingValueUnit''''},
	                    {name: ''''pricedValueInPayInCCY'''', mapping: ''''pricedValueInPayInCCY''''},
	                    {name: ''''recType'''', mapping: ''''recType''''}]', NULL, '/private/jsp/invoice/listing/listOfArrivedPricedAndNotInvoiced.jsp', '/private/js/invoice/listing/listOfArrivedPricedAndNotInvoiced.js');
	




Create or Replace Force view v_eod_GMR as select * from GMR_GOODS_MOVEMENT_RECORD@EKA_EODDB;

Create or Replace Force view v_eod_PAGMR as select * from pa_purchase_accural_gmr@EKA_EODDB;


Create or Replace Force view v_eod_PA as select * from pa_purchase_accural@EKA_EODDB;

Create or Replace Force view v_eod_TDC as select * from tdc_trade_date_closure@EKA_EODDB;