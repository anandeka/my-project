CREATE TABLE CBR_CLOSING_BALANCE_REPORT
(
  PROCESS_ID           VARCHAR2(15 CHAR),
  EOD_TRADE_DATE       DATE,
  CORPORATE_ID         VARCHAR2(15 CHAR),
  CORPORATE_NAME       VARCHAR2(100 CHAR),
  GMR_REF_NO           VARCHAR2(30 CHAR),
  INTERNAL_GMR_REF_NO  VARCHAR2(15 CHAR),
  INTERNAL_GRD_REF_NO  VARCHAR2(15 CHAR),
  STOCK_REF_NO         VARCHAR2(50 CHAR),
  PRODUCT_ID           VARCHAR2(15 CHAR),
  PRODUCT_NAME         VARCHAR2(200 CHAR),
  QUALITY_ID           VARCHAR2(15 CHAR),
  QUALITY_NAME         VARCHAR2(50 CHAR),
  PILE_NAME            VARCHAR2(50 CHAR),
  WAREHOUSE_ID         VARCHAR2(50),
  WAREHOUSE_NAME       VARCHAR2(100),
  SHED_ID              VARCHAR2(15),
  SHED_NAME            VARCHAR2(50),
  GRD_WET_QTY          NUMBER(25,5),
  GRD_DRY_QTY          NUMBER(25,5),
  GRD_QTY_UNIT_ID      VARCHAR2(15 CHAR),
  GRD_QTY_UNIT         VARCHAR2(15 CHAR),
  PAY_CUR_ID          VARCHAR2(15 CHAR),
  PAY_CUR_CODE        VARCHAR2(15),
  CONC_BASE_QTY_UNIT_ID VARCHAR2(15 CHAR),
  CONC_BASE_QTY_UNIT    VARCHAR2(15 CHAR)
   );

  CREATE TABLE CBRE_CLOSING_BAL_REPORT_ELE
  (PROCESS_ID           VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO  VARCHAR2(15 CHAR),
  INTERNAL_GRD_REF_NO  VARCHAR2(15 CHAR),
  ELEMENT_ID           VARCHAR2(15 CHAR),
  ELEMENT_NAME         VARCHAR2(15 CHAR),
  ASSAY_QTY            NUMBER(25,5),
  ASAAY_QTY_UNIT_ID    VARCHAR2(15 CHAR),
  ASAAY_QTY_UNIT       VARCHAR2(15 CHAR),
  PAYABLE_QTY          NUMBER(25,5),
  PAYABLE_QTY_UNIT_ID  VARCHAR2(15 CHAR),
  PAYABLE_QTY_UNIT     VARCHAR2(15 CHAR),
  PAYABLE_RETURNABLE_TYPE VARCHAR2(30 CHAR),
  TC_AMOUNT               NUMBER(25,10),
  RC_AMOUNT               NUMBER(25,10),
  PENALITY_AMOUNT          NUMBER(25,10)  
  );


ALTER TABLE  AR_ARRIVAL_REPORT ADD CONC_BASE_QTY_UNIT_ID VARCHAR2(15);
ALTER TABLE  AR_ARRIVAL_REPORT ADD CONC_BASE_QTY_UNIT VARCHAR2(15);

ALTER TABLE FC_FEED_CONSUMPTION ADD CONC_BASE_QTY_UNIT_ID VARCHAR2(15);
ALTER TABLE FC_FEED_CONSUMPTION ADD CONC_BASE_QTY_UNIT VARCHAR2(15);

CREATE INDEX IDX_CBR1 ON CBR_CLOSING_BALANCE_REPORT (PROCESS_ID);
CREATE INDEX IDX_CBRE1 ON CBRE_CLOSING_BAL_REPORT_ELE (PROCESS_ID);





