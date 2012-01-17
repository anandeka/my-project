ALTER TABLE CIPQ_CONTRACT_ITEM_PAYABLE_QTY
 ADD (RETURNABLE_QTY  NUMBER(25,10));
ALTER TABLE DIPQ_DELIVERY_ITEM_PAYABLE_QTY
 ADD (RETURNABLE_QTY  NUMBER(25,10));


ALTER TABLE CIPQL_CTRT_ITM_PAYABLE_QTY_LOG
 ADD (RETURNABLE_QTY_DELTA  NUMBER(25,10));
ALTER TABLE DIPQL_DEL_ITM_PAYBLE_QTY_LOG
 ADD (RETURNABLE_QTY_DELTA  NUMBER(25,10));


ALTER TABLE SAM_STOCK_ASSAY_MAPPING
MODIFY(PREV_POSITION_ASSAY_ID VARCHAR2(15 CHAR));
ALTER TABLE SAM_STOCK_ASSAY_MAPPING
MODIFY(PREV_PRICING_ASSAY_ID VARCHAR2(15 CHAR));
ALTER TABLE SAM_STOCK_ASSAY_MAPPING
MODIFY(PREV_WEIGHTED_AVG_PRICINGASSAY VARCHAR2(15 CHAR));


ALTER TABLE PCDI_PC_DELIVERY_ITEM
 ADD (PRICE_ALLOCATION_METHOD  VARCHAR2(30 CHAR));
ALTER TABLE PCDIUL_PC_DELIVERY_ITEM_UL
 ADD (PRICE_ALLOCATION_METHOD  VARCHAR2(30 CHAR));


SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Weighted Average Price', 'Weighted Average Price');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Price Allocation', 'Price Allocation');

SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('PriceAllocationMethod', 'Weighted Average Price', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('PriceAllocationMethod', 'Price Allocation', 'N', 2);



