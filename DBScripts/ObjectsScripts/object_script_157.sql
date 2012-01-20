ALTER TABLE SAM_STOCK_ASSAY_MAPPING
 ADD (IS_PROPAGATED_ASSAY  CHAR(1 CHAR)             DEFAULT 'N');

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GmrPriceAllocationMethod', 'Weighted Average Price', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('GmrPriceAllocationMethod', 'Price Allocation', 'N', 2);

