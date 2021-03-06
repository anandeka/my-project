DROP TABLE DPR_DAILY_POSITION_RECORD CASCADE CONSTRAINTS;

CREATE TABLE DPR_DAILY_POSITION_RECORD
(
  TRADE_DATE        DATE,
  CORPORATE_ID      VARCHAR2(15 BYTE),
  PRODUCT_ID        VARCHAR2(15 BYTE),
  PROFIT_CENTER_ID  VARCHAR2(15 BYTE),
  BUSINESS_LINE_ID  VARCHAR2(15 BYTE),
  FIXED_QTY         NUMBER(25,10),
  QUOTATIONAL_QTY   NUMBER(25,10),
  PROCESS_ID        VARCHAR2(15 BYTE)
);

