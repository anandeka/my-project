ALTER TABLE SPQ_STOCK_PAYABLE_QTY ADD(
QTY_UNIT            VARCHAR2(15));

ALTER TABLE AR_ARRIVAL_REPORT ADD(
IS_NEW                        VARCHAR2(1),
MTD_YTD                       VARCHAR2(3),
OTHER_CHARGES_AMT             NUMBER(38,18),
PAY_CUR_ID                    VARCHAR2(15),
PAY_CUR_CODE                  VARCHAR2(15),
PAY_CUR_DECIMAL               NUMBER(10),
GRD_TO_GMR_QTY_FACTOR         NUMBER,
GMR_QTY                       NUMBER(25,10));

ALTER TABLE ARE_ARRIVAL_REPORT_ELEMENT ADD(
MTD_YTD                                VARCHAR2(3),
SECTION_NAME                           VARCHAR2(15),
QTY_TYPE                               VARCHAR2(10),
PRICE                                  NUMBER(25,5),
PRICE_UNIT_ID                          VARCHAR2(15),
PAYABLE_AMT_PRICE_CCY                  NUMBER(38,18),
PAYABLE_AMT_PAY_CCY                    NUMBER(38,18),
FX_RATE_PRICE_TO_PAY                   NUMBER(38,18),
BASE_TC_CHARGES_AMT                    NUMBER(38,18),
ESC_DESC_TC_CHARGES_AMT                NUMBER(38,18),
RC_CHARGES_AMT                         NUMBER(38,18),
PC_CHARGES_AMT                         NUMBER(38,18));

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD(
BASE_QTY_UNIT_ID                    VARCHAR2(15),
BASE_QTY_UNIT                       VARCHAR2(15),
BASE_QTY_CONV_FACTOR                NUMBER);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD TOLLING_SERVICE_TYPE VARCHAR2(1);


CREATE TABLE ARO_AR_ORIGINAL(
  PROCESS_ID             VARCHAR2(15 CHAR),
  EOD_TRADE_DATE         DATE,
  CORPORATE_ID           VARCHAR2(15 CHAR),
  CORPORATE_NAME         VARCHAR2(15 CHAR),
  GMR_REF_NO             VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO    VARCHAR2(15 CHAR),
  INTERNAL_GRD_REF_NO    VARCHAR2(15 CHAR),
  STOCK_REF_NO           VARCHAR2(50 CHAR),
  PRODUCT_ID             VARCHAR2(15 CHAR),
  PRODUCT_NAME           VARCHAR2(100 CHAR),
  QUALITY_ID             VARCHAR2(15 CHAR),
  QUALITY_NAME           VARCHAR2(50 CHAR),
  ARRIVAL_STATUS         VARCHAR2(100 CHAR),
  WAREHOUSE_ID           VARCHAR2(50 CHAR),
  WAREHOUSE_NAME         VARCHAR2(100 CHAR),
  SHED_ID                VARCHAR2(15 CHAR),
  SHED_NAME              VARCHAR2(50 CHAR),
  GRD_WET_QTY            NUMBER(25,5),
  GRD_DRY_QTY            NUMBER(25,5),
  GRD_QTY_UNIT_ID        VARCHAR2(15 CHAR),
  GRD_QTY_UNIT           VARCHAR2(15 CHAR),
  CONC_BASE_QTY_UNIT_ID  VARCHAR2(15 CHAR),
  CONC_BASE_QTY_UNIT     VARCHAR2(15 CHAR),
  OTHER_CHARGES_AMT      NUMBER(38,18),
  PAY_CUR_ID             VARCHAR2(15 CHAR),
  PAY_CUR_CODE           VARCHAR2(15 CHAR),
  PAY_CUR_DECIMAL        NUMBER(10),
  GRD_TO_GMR_QTY_FACTOR  NUMBER,
  GMR_QTY                NUMBER(25,10));
  
  CREATE TABLE AREO_AR_ELEMENT_ORIGINAL(
  PROCESS_ID               VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO      VARCHAR2(15 CHAR),
  INTERNAL_GRD_REF_NO      VARCHAR2(15 CHAR),
  ELEMENT_ID               VARCHAR2(15 CHAR),
  ELEMENT_NAME             VARCHAR2(15 CHAR),
  ASSAY_QTY                NUMBER(25,5),
  ASAAY_QTY_UNIT_ID        VARCHAR2(15 CHAR),
  ASAAY_QTY_UNIT           VARCHAR2(15 CHAR),
  PAYABLE_QTY              NUMBER(25,5),
  PAYABLE_QTY_UNIT_ID      VARCHAR2(15 CHAR),
  PAYABLE_QTY_UNIT         VARCHAR2(15 CHAR),
  SECTION_NAME             VARCHAR2(15 CHAR),
  QTY_TYPE                 VARCHAR2(10 CHAR),
  PRICE                    NUMBER(25,5),
  PRICE_UNIT_ID            VARCHAR2(15 CHAR),
  PAYABLE_AMT_PRICE_CCY    NUMBER(38,18),
  PAYABLE_AMT_PAY_CCY      NUMBER(38,18),
  FX_RATE_PRICE_TO_PAY     NUMBER(38,18),
  BASE_TC_CHARGES_AMT      NUMBER(38,18),
  ESC_DESC_TC_CHARGES_AMT  NUMBER(38,18),
  RC_CHARGES_AMT           NUMBER(38,18),
  PC_CHARGES_AMT           NUMBER(38,18));

CREATE INDEX IDX_ARO1 ON ARO_AR_ORIGINAL(PROCESS_ID);
CREATE INDEX IDX_ARE01 ON AREO_AR_ELEMENT_ORIGINAL(PROCESS_ID);

CREATE INDEX IDX_AR2 ON AR_ARRIVAL_REPORT(CORPORATE_ID,EOD_TRADE_DATE,MTD_YTD);
CREATE INDEX IDX_ARE2 ON ARE_ARRIVAL_REPORT_ELEMENT(PROCESS_ID,INTERNAL_GMR_REF_NO,INTERNAL_GRD_REF_NO,MTD_YTD,SECTION_NAME);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD GMR_ARRIVAL_STATUS VARCHAR2(50);

