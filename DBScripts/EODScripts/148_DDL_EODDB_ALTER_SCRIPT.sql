DROP TABLE FXAR_FX_ALLOCATION_REPORT;
CREATE TABLE FXAR_FX_ALLOCATION_REPORT
(
  PROCESS_ID                 VARCHAR2(15 CHAR),
  EOD_TRADE_DATE             DATE,
  CORPORATE_ID               VARCHAR2(15 CHAR),
  CORPORATE_NAME             VARCHAR2(100 CHAR),
  SECTION_NAME               VARCHAR2(200 CHAR),
  MAIN_SECTION               VARCHAR2(200 CHAR),
  PROFIT_CENTER_ID           VARCHAR2(15 CHAR),
  PROFIT_CENTER_NAME         VARCHAR2(200 CHAR),
  PRODUCT_ID                 VARCHAR2(15 CHAR),
  PRODUCT_DESC               VARCHAR2(200 CHAR),
  INSTRUMENT_ID              VARCHAR2(15 CHAR),
  INSTRUMENT_NAME            VARCHAR2(200 CHAR),
  TRADER_ID                  VARCHAR2(15 CHAR),
  TRADER_NAME                VARCHAR2(200 CHAR),
  PCDI_ID                    VARCHAR2(15 CHAR),
  INTERNAL_CONTRACT_REF_NO   VARCHAR2(15 CHAR),
  DELIVERY_ITEM_NO           VARCHAR2(100 CHAR), 
  EXTERNAL_REF_NO            VARCHAR2(50 CHAR),
  TRADE_REF_NO               VARCHAR2(30 CHAR),
  PURCHASE_QTY               NUMBER(25,4),
  SALES_QTY                  NUMBER(25,4),
  QTY_UNIT_ID                VARCHAR2(15 CHAR),
  QTY_UNIT                   VARCHAR2(15 CHAR),
  EXPOSURE_DATE              DATE,
  PRICE                      NUMBER(25,5),
  PRICE_UNIT_ID              VARCHAR2(15 CHAR),
  PRICE_UNIT_NAME            VARCHAR2(15 CHAR),
  HEDGE_AMOUNT               NUMBER(25,5),
  BASE_CUR_ID                VARCHAR2(15 CHAR),
  BASE_CUR_NAME              VARCHAR2(25 CHAR),
  EXPOSURE_CUR_ID            VARCHAR2(15 CHAR),
  EXPOSURE_CUR_NAME          VARCHAR2(25 CHAR),
  EXCHANGE_RATE              NUMBER(25,10),
  VALUE_DATE                 DATE,
  PURCHASE_SALES             CHAR(1)
);



alter table  PCDB_PC_DELIVERY_BASIS add PFFXD_ID varchar2(15);
alter table  PCDBUL_PC_DELIVERY_BASIS_UL add PFFXD_ID varchar2(15);



DROP MATERIALIZED VIEW IVD_INVOICE_VAT_DETAILS;
DROP TABLE IVD_INVOICE_VAT_DETAILS;
CREATE MATERIALIZED VIEW  IVD_INVOICE_VAT_DETAILS  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  IVD_INVOICE_VAT_DETAILS@eka_appdb;


CREATE INDEX IDC_FXAR ON FXAR_FX_ALLOCATION_REPORT(PROCESS_ID,EOD_TRADE_DATE);



