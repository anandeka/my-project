CREATE TABLE VAT_D
(
  INTERNAL_INVOICE_REF_NO         VARCHAR2(30 BYTE),
  INTERNAL_DOC_REF_NO             VARCHAR2(30 BYTE),
  CONTRACT_REF_NO                 VARCHAR2(30 BYTE),
  CP_CONTRACT_REF_NO              VARCHAR2(30 BYTE),
  INCO_TERM_LOCATION              VARCHAR2(100 BYTE),
  CONTRACT_DATE                   DATE,
  CP_NAME                         VARCHAR2(100 BYTE),
  CONTRACT_QUANTITY               VARCHAR2(30 BYTE),
  CONTRACT_QUANTITY_UNIT          VARCHAR2(30 BYTE),
  CONTRACT_TOLERANCE              VARCHAR2(30 BYTE),
  PRODUCT                         VARCHAR2(30 BYTE),
  QUALITY                         VARCHAR2(30 BYTE),
  NOTIFY_PARTY                    VARCHAR2(30 BYTE),
  INVOICE_REF_NO                  VARCHAR2(30 BYTE),
  INVOICE_CREATION_DATE           VARCHAR2(30 BYTE),
  SELLER                          VARCHAR2(100 BYTE) 
)


CREATE TABLE VAT_CHILD_D
(
  INTERNAL_INVOICE_REF_NO         VARCHAR2(30 BYTE),
  INTERNAL_DOC_REF_NO             VARCHAR2(30 BYTE),
  VAT_NO                          VARCHAR2(30 BYTE),
  CP_VAT_NO                       VARCHAR2(30 BYTE),
  VAT_CODE                        VARCHAR2(30 BYTE),
  VAT_RATE                        VARCHAR2(30 BYTE),
  VAT_AMOUNT                      VARCHAR2(30 BYTE),
  VAT_AMOUNT_CUR                  VARCHAR2(30 BYTE) 
)


ALTER TABLE VAT_D
 ADD (CONTRACT_TYPE  VARCHAR2(30 BYTE));

ALTER TABLE VAT_D
 ADD (INVOICE_STATUS  VARCHAR2(30 BYTE));

ALTER TABLE VAT_D
 ADD (SALES_PURCHASE  VARCHAR2(30 BYTE));