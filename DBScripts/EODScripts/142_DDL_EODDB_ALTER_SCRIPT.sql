ALTER TABLE MBV_METAL_BALANCE_VALUATION RENAME COLUMN  PHY_REALIZED_OB TO PHY_REALIZED_OB_PNL;
ALTER TABLE MBV_METAL_BALANCE_VALUATION RENAME COLUMN  PHY_REALIZED_CB TO PHY_REALIZED_CB_PNL;
ALTER TABLE MBV_METAL_BALANCE_VALUATION RENAME COLUMN  CONTANGO_BW_DIFF TO CONTANGO_BW_DIFF_VALUE;
ALTER TABLE MBV_METAL_BALANCE_VALUATION RENAME COLUMN  DER_REALIZED_OB TO DER_REALIZED_OB_PNL;
ALTER TABLE MBV_METAL_BALANCE_VALUATION RENAME COLUMN  DER_REF_PRICE_DIFF TO DER_REF_PRICE_DIFF_VALUE;
ALTER TABLE MBV_METAL_BALANCE_VALUATION RENAME COLUMN  PHY_REF_PRICE_DIFF TO PHY_REF_PRICE_DIFF_VALUE;

ALTER TABLE MBV_ALLOCATION_REPORT_HEADER ADD ACTUAL_HEDGED_QTY NUMBER(25,5);
ALTER TABLE MBV_ALLOCATION_REPORT_HEADER ADD CONTANGO_DUE_TO_QTY_AND_PRICE NUMBER(25,5);

DROP INDEX IDX_PFRH1;
DROP INDEX IDX_PFRD1;

CREATE INDEX IDX_PFRH1 ON PFRH_PRICE_FIX_REPORT_HEADER(CORPORATE_ID,EOD_TRADE_DATE,PRODUCT_ID);
CREATE INDEX IDX_PFRD1 ON PFRD_PRICE_FIX_REPORT_DETAIL(CORPORATE_ID,EOD_TRADE_DATE,PRODUCT_ID);

CREATE INDEX IDX_ARD1 ON MBV_ALLOCATION_REPORT(CORPORATE_ID,EOD_TRADE_DATE,PRODUCT_ID);
CREATE INDEX IDX_ARH1 ON MBV_ALLOCATION_REPORT_HEADER(CORPORATE_ID,EOD_TRADE_DATE,PRODUCT_ID);

CREATE INDEX IDX_MBV_DFR1 ON MBV_DERIVATIVE_DIFF_REPORT(CORPORATE_ID,PROCESS_DATE);

CREATE INDEX IDX_MBVPDR1 ON MBV_PHY_POSTION_DIFF_REPORT(CORPORATE_ID,EOD_TRADE_DATE,PRODUCT_ID);

ALTER TABLE CSS_CONTRACT_STATUS_SUMMARY DROP COLUMN PURCHASE_SALES;

ALTER TABLE PFRD_PRICE_FIX_REPORT_DETAIL ADD(
BASE_QTY_UNIT_ID                       VARCHAR2(15),
BASE_QTY_UNIT                          VARCHAR2(15));

ALTER TABLE PFRH_PRICE_FIX_REPORT_HEADER ADD(
BASE_QTY_UNIT_ID                       VARCHAR2(15),
BASE_QTY_UNIT                          VARCHAR2(15),
BASE_CUR_DECIMALS                      NUMBER(2),
BASE_QTY_DECIMALS                      NUMBER(2));

ALTER TABLE PFRD_PRICE_FIX_REPORT_DETAIL DROP (GMR_REF_NO,INTERNAL_GMR_REF_NO);

COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.PRICED_NOT_ARRIVED_BM IS 'Priced Not Arrived Base Metal Quantity';
COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.PRICED_NOT_ARRIVED_RM IS 'Priced Not Arrived Concentrate Quantity';        
COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.UNPRICED_ARRIVED_BM IS 'Unpriced Arrived Base Metal Quantity';       
COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.UNPRICED_ARRIVED_RM IS 'Unpriced Arrived Concentrate Quantity';        
COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.SALES_UNPRICED_DELIVERED_BM IS 'Sales Unpriced Delivered Base Metal Quantity';
COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.SALES_UNPRICED_DELIVERED_RM IS 'Sales Unpriced Delivered Concentrate Quantity';       
COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.SALES_PRICED_NOT_DELIVERED_BM IS 'Sales Priced Not Delivered Base Metal Quantity';		
COMMENT ON COLUMN MBV_METAL_BALANCE_VALUATION.SALES_PRICED_NOT_DELIVERED_RM IS 'ales Priced Not Delivered Concentrate Quantity';

 alter  table GERC_GMR_ELEMENT_RC_CHARGES add RANGE_TYPE varchar2(20);