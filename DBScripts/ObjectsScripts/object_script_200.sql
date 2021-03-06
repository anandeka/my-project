alter table IS_D add(MOISTURE NUMBER(10,5));

alter table IS_D add(INVOICE_DRY_QUANTITY VARCHAR2(30 CHAR), INVOICE_WET_QUANTITY VARCHAR2(30 CHAR));

CREATE TABLE IOC_D
(
  INTERNAL_INVOICE_REF_NO  VARCHAR2(15),
  OTHER_CHARGE_COST_NAME   VARCHAR2(50),
  CHARGE_TYPE              VARCHAR2(30),
  FX_RATE                  NUMBER(38,18),
  QUANTITY                 NUMBER(38,18),
  AMOUNT                   NUMBER(38,18),
  INVOICE_AMOUNT           NUMBER(38,18),
  INVOICE_CUR_NAME         VARCHAR2(15),
  RATE_PRICE_UNIT_NAME     VARCHAR2(30),
  INTERNAL_DOC_REF_NO      VARCHAR2(15)
);

CREATE TABLE ITD_D
(
  INTERNAL_INVOICE_REF_NO  VARCHAR2(15),
  OTHER_CHARGE_COST_NAME   VARCHAR2(50),
  TAX_CODE                 VARCHAR2(30),
  TAX_RATE                 NUMBER(38,18),
  INVOICE_CURRENCY         VARCHAR2(15),
  FX_RATE                  NUMBER(38,18),
  AMOUNT                   NUMBER(38,18),
  TAX_CURRENCY             VARCHAR2(15),
  INVOICE_AMOUNT           NUMBER(38,18),
  INTERNAL_DOC_REF_NO      VARCHAR2(15)
);