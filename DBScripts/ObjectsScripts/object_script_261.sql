CREATE TABLE IUH_INVOICE_UTILITY_HEADER
(
  CORPORATE_ID           VARCHAR2(15),
  CORPORATE_NAME         VARCHAR2(15),
  INVOICE_UTILITY_ID     VARCHAR2(15),
  UTILITY_REF_NO         VARCHAR2(15),
  UTILITY_RUN_DATE       DATE,
  CREATED_DATE           DATE,
  CREATED_BY             VARCHAR2(15),
  UTILITY_STATUS         VARCHAR2(15),
  CANCELLED_DATE         DATE,
  CANCELLED_BY           VARCHAR2(15)
);


CREATE TABLE IUES_INV_UTILITY_ELEM_SUMMARY
(
  INVOICE_UTILITY_ID          VARCHAR2(15),
  SMELTER_ID                  VARCHAR2(15),
  SMELTER_NAME                VARCHAR2(50),
  ELEMENT_ID                  VARCHAR2(15),
  ELEMENT_NAME                VARCHAR2(20),
  CURRENCY_ID                 VARCHAR2(15),
  CURRENCY_CODE               VARCHAR2(15),
  AMOUNT_TYPE                 VARCHAR2(15),
  AMOUNT                      NUMBER(25,10)
);


CREATE TABLE IUD_INVOICE_UTILITY_DETAIL
(
  INVOICE_UTILITY_ID                      VARCHAR2(15),
  SMELTER_ID                              VARCHAR2(15),
  SMELTER_NAME                            VARCHAR2(50),
  CURRENCY_ID                             VARCHAR2(15),
  CURRENCY_CODE                           VARCHAR2(15),
  INVOICE_MAIN_TYPE                       VARCHAR2(15),
  INVOICE_TYPE                            VARCHAR2(30),
  INTERNAL_INVOICE_REF_NO                 VARCHAR2(15),
  INVOICE_REF_NO                          VARCHAR2(15),
  PREV_PARENT_INTERNL_INV_REF_NO          VARCHAR2(15),
  PREV_PARENT_INVOICE_REF_NO              VARCHAR2(15),
  INTERNAL_CONTRACT_ITEM_REF_NO           VARCHAR2(15),
  CONTRACT_REF_NO                         VARCHAR2(15),
  PCDI_ID                                 VARCHAR2(15),
  DELIVERY_ITEM_REF_NO                    VARCHAR2(15),
  PRODUCT_ID                              VARCHAR2(15),
  PRODUCT_NAME                            VARCHAR2(30),
  INTERNAL_GMR_REF_NO                     VARCHAR2(15),
  FEED_REG_REF_NO                         VARCHAR2(15),
  FEED_REG_DATE                           DATE,
  FEED_QTY                                NUMBER(25,10),
  FEED_QTY_UNIT_ID                        VARCHAR2(15),
  FEED_QTY_UNIT                           VARCHAR2(15),
  PAYABLE_QTY_DISPLAY                     NUMBER(25,10),
  FREE_METAL_QTY_DISPLAY                  NUMBER(25,10),
  TC_AMOUNT_DISPLAY                       NUMBER(25,10),
  RC_AMOUNT_DISPLAY                       NUMBER(25,10),
  PENALTY_AMOUNT_DISPLAY                  NUMBER(25,10),
  FREE_METAL_AMOUNT_DISPLAY               NUMBER(25,10),
  TOTAL_INVOICE_AMOUNT                    NUMBER(25,10),
  PARENT_INVOICE_AMOUNT                   NUMBER(25,10),
  PARENT_INVOICE_CURRENCY_ID              VARCHAR2(15),
  PARENT_INVOICE_CURRENCY_CODE            VARCHAR2(15),
  VAT_AMOUNT_IN_INVOICE_CURRENCY          NUMBER(25,10),
  FX_RATE                                 NUMBER(25,10)
);