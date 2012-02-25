CREATE TABLE CFID_COMM_FEE_INVOICE_DETAILS
(
  CFID_ID                  VARCHAR2(15),
  INTERNAL_INVOICE_REF_NO  VARCHAR2(30),
  FEE_CHARGE               NUMBER(38,18),
  PRICE_UNIT_ID            VARCHAR2(15),
  STOCK_ID                 VARCHAR2(15),
  QUANTITY                 NUMBER(38,18),
  INVOICE_CUR_ID           VARCHAR2(15),
  QTY_UNIT_ID              VARCHAR2(15),
  INVOICE_AMOUNT           NUMBER(38,18),
  QUALITY_ID               VARCHAR2(15),
  PRODUCT_ID               VARCHAR2(15),
  SMELTER_CP_ID            VARCHAR2(15)
);

ALTER TABLE II_INVOICABLE_ITEM ADD(IS_COMMERCIAL_FEE CHAR(1));

CREATE SEQUENCE SEQ_CFID
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;