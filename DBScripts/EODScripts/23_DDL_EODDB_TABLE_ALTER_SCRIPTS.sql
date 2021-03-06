UPDATE EEM_EKA_EXCEPTION_MASTER EEM
SET EEM.EXCEPTION_DESC ='Forward Exchange rates are not available - Please enter the values at Market Data -> Bank FX Rates Screen'
WHERE EEM.EXCEPTION_CODE ='PHY-005';

ALTER TABLE INVS_INVENTORY_SALES ADD STOCK_QTY NUMBER(20,5);
ALTER TABLE INVM_INVENTORY_MASTER ADD INTERNAL_DGRD_REF_NO VARCHAR2(15);
ALTER TABLE INVS_INVENTORY_SALES ADD INTERNAL_DGRD_REF_NO VARCHAR2(15);

alter table GRDL_GOODS_RECORD_DETAIL_LOG add (IS_TRANS_SHIP CHAR(1 CHAR)  ,
  IS_MARK_FOR_TOLLING             CHAR(1 CHAR)  ,
  TOLLING_QTY                     NUMBER(20,5),
  TOLLING_STOCK_TYPE              VARCHAR2(30 CHAR) ,
  ELEMENT_ID                      VARCHAR2(15 CHAR),
  EXPECTED_SALES_CCY              VARCHAR2(15 CHAR),
  PROFIT_CENTER_ID                VARCHAR2(15 CHAR),
  STRATEGY_ID                     VARCHAR2(15 CHAR),
  IS_WARRANT                      CHAR(1 CHAR)  ,
  WARRANT_NO                      VARCHAR2(15 CHAR),
  PCDI_ID                         VARCHAR2(15 CHAR),
  SUPP_CONTRACT_ITEM_REF_NO       VARCHAR2(15 CHAR),
  SUPPLIER_PCDI_ID                VARCHAR2(15 CHAR),
  PAYABLE_RETURNABLE_TYPE         VARCHAR2(10 CHAR),
  CARRY_OVER_QTY                  NUMBER(20,5));

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD (IS_TRANS_SHIP                   CHAR(1 CHAR)  ,
  IS_MARK_FOR_TOLLING             CHAR(1 CHAR)  ,
  TOLLING_QTY                     NUMBER(20,5),
  TOLLING_STOCK_TYPE              VARCHAR2(30 CHAR) ,
  ELEMENT_ID                      VARCHAR2(15 CHAR),
  EXPECTED_SALES_CCY              VARCHAR2(15 CHAR),
  CARRY_OVER_QTY                  NUMBER(20,5));

ALTER TABLE TMPC_TEMP_M2M_PRE_CHECK ADD PAYMENT_DUE_DATE DATE;

ALTER TABLE TMPC_TEMP_M2M_PRE_CHECK ADD 
(M2M_QUALITY_PREMIUM NUMBER (25,5),
M2M_PRODUCT_PREMIUM NUMBER(25,5),
M2M_LOC_INCOTERM_DEVIATION NUMBER (25,5));

ALTER TABLE CIPD_CONTRACT_ITEM_PRICE_DAILY MODIFY EXCH_RATE_STRING VARCHAR2(500);

ALTER TABLE TMPC_TEMP_M2M_PRE_CHECK ADD
(M2M_LD_FW_EXCH_RATE VARCHAR2(50),
M2M_QP_FW_EXCH_RATE VARCHAR2(50),
M2M_PP_FW_EXCH_RATE VARCHAR2(50));

ALTER TABLE MD_M2M_DAILY ADD
(M2M_LD_FW_EXCH_RATE VARCHAR2(50),
M2M_QP_FW_EXCH_RATE VARCHAR2(50),
M2M_PP_FW_EXCH_RATE VARCHAR2(50));

ALTER TABLE MD_M2M_DAILY ADD PAYMENT_DUE_DATE DATE;

ALTER TABLE POUD_PHY_OPEN_UNREAL_DAILY ADD
(
PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(25),
M2M_TO_BASE_FW_EXCH_RATE VARCHAR2(50),
M2M_LD_FW_EXCH_RATE VARCHAR2(50),
M2M_QP_FW_EXCH_RATE VARCHAR2(50),
M2M_PP_FW_EXCH_RATE VARCHAR2(50),
CONTRACT_QP_FW_EXCH_RATE VARCHAR2(25),
CONTRACT_PP_FW_EXCH_RATE VARCHAR2(25));

ALTER TABLE PSU_PHY_STOCK_UNREALIZED ADD
(PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(25),
M2M_TO_BASE_FW_EXCH_RATE VARCHAR2(50),
M2M_LD_FW_EXCH_RATE VARCHAR2(50),
M2M_QP_FW_EXCH_RATE VARCHAR2(50),
M2M_PP_FW_EXCH_RATE VARCHAR2(50),
CONTRACT_QP_FW_EXCH_RATE VARCHAR2(25),
CONTRACT_PP_FW_EXCH_RATE VARCHAR2(25));

ALTER TABLE PRD_PHYSICAL_REALIZED_DAILY ADD
(PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(25),
CONTRACT_QP_FW_EXCH_RATE VARCHAR2(25),
CONTRACT_PP_FW_EXCH_RATE VARCHAR2(25));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD PRODUCT_ID VARCHAR2(15);

DROP TABLE  CISC_CONTRACT_ITEM_SEC_COST;
CREATE TABLE CISC_CONTRACT_ITEM_SEC_COST 
(INTERNAL_CONTRACT_ITEM_REF_NO VARCHAR2 (15),        
PROCESS_ID VARCHAR2 (15),
COST_COMPONENT_ID VARCHAR2(15),        
AVG_COST NUMBER (25,5),        
SECONDARY_COST NUMBER (25,5),        
AVG_COST_IN_TRN_CUR NUMBER,        
AVG_COST_PRICE_UNIT_ID VARCHAR2 (15),
PAYMENT_DUE_DATE DATE,
PRODUCT_ID VARCHAR2(15),
CORPORATE_ID VARCHAR2(15),
TRANSACT_PRICE_UNIT_ID VARCHAR2(15),
TRANSACT_QTY_UNIT_ID   VARCHAR2(15),
PRICE_QTY_UNIT_ID   VARCHAR2(15),
COST_VALUE          NUMBER,
TRANSACT_CUR_ID VARCHAR2(15),
TRANSACT_MAIN_CUR_ID VARCHAR2(15),
CURRENCY_FACTOR NUMBER,
BASE_CUR_ID VARCHAR2(15),
BASE_QTY_UNIT_ID VARCHAR2(15),
AVG_COST_FW_RATE NUMBER(25,5),
BASE_PRICE_UNIT_ID VARCHAR2(15),
FW_RATE_TRANS_TO_BASE_CURRENCY   NUMBER(25,10) DEFAULT 1,
BASE_TO_PRICE_WEIGHT_FACTOR           NUMBER DEFAULT 1,
FW_RATE_STRING VARCHAR2(50));

drop TABLE GSC_GMR_SEC_COST;
CREATE TABLE GSC_GMR_SEC_COST
(INTERNAL_GMR_REF_NO            VARCHAR2(15),
COST_COMPONENT_ID              VARCHAR2(15),
AVG_COST                       NUMBER(25,5),
PROCESS_ID                     VARCHAR2(20),
SECONDARY_COST                 NUMBER(25,5),
INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
AVG_COST_IN_TRN_CUR            VARCHAR2(15),
AVG_COST_PRICE_UNIT_ID         VARCHAR2(15),
PAYMENT_DUE_DATE DATE,
PRODUCT_ID VARCHAR2(15),
CORPORATE_ID VARCHAR2(15),
TRANSACT_PRICE_UNIT_ID VARCHAR2(15),
TRANSACT_QTY_UNIT_ID   VARCHAR2(15),
PRICE_QTY_UNIT_ID   VARCHAR2(15),
COST_VALUE          NUMBER,
TRANSACT_CUR_ID VARCHAR2(15),
TRANSACT_MAIN_CUR_ID VARCHAR2(15),
CURRENCY_FACTOR NUMBER,
BASE_CUR_ID VARCHAR2(15),
BASE_QTY_UNIT_ID VARCHAR2(15),
AVG_COST_FW_RATE NUMBER(25,5),
BASE_PRICE_UNIT_ID VARCHAR2(15),
FW_RATE_TRANS_TO_BASE_CURRENCY   NUMBER(25,10) DEFAULT 1,
BASE_TO_PRICE_WEIGHT_FACTOR           NUMBER DEFAULT 1,
FW_RATE_STRING VARCHAR2(50));

DROP TABLE GSCS_GMR_SEC_COST_SUMMARY;
CREATE TABLE GSCS_GMR_SEC_COST_SUMMARY
( INTERNAL_GMR_REF_NO  VARCHAR2(15),
  PROCESS_ID           VARCHAR2(15),
  AVG_COST             NUMBER(25,5),
  AVG_COST_FW_RATE NUMBER(25,5),
  FW_RATE_STRING VARCHAR2(50));

 CREATE TABLE CISCS_CISC_SUMMARY
( INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
  PROCESS_ID           VARCHAR2(15),
  AVG_COST             NUMBER(25,5),
  AVG_COST_FW_RATE NUMBER(25,5),
  FW_RATE_STRING VARCHAR2(50));


ALTER TABLE POUD_PHY_OPEN_UNREAL_DAILY ADD ACCRUAL_TO_BASE_FW_EXCH_RATE VARCHAR2(50);
ALTER TABLE PSU_PHY_STOCK_UNREALIZED ADD ACCRUAL_TO_BASE_FW_EXCH_RATE VARCHAR2(50);
ALTER TABLE PRD_PHYSICAL_REALIZED_DAILY ADD ACCRUAL_TO_BASE_FW_EXCH_RATE VARCHAR2(50);

CREATE TABLE TINVP_TEMP_INVM_COG (
CORPORATE_ID                  VARCHAR2(15),
PROCESS_ID                  VARCHAR2(15),
INTERNAL_COST_ID            VARCHAR2(15),
COST_TYPE                   VARCHAR2(25),
INTERNAL_GRD_REF_NO         VARCHAR2(15),
PRODUCT_ID VARCHAR2(15),
BASE_QTY_UNIT_ID VARCHAR2(15),
BASE_QTY_UNIT VARCHAR2(15),
GRD_CURRENT_QTY             NUMBER,
GRD_QTY_UNIT_ID             VARCHAR2(15),
COST_VALUE                  NUMBER,
TRANSFORMATION_RATIO        NUMBER,
TRANSACTION_PRICE_UNIT_ID   VARCHAR2(15),
TRANSACTION_CUR_FACTOR      NUMBER,
TRANSACTION_AMT_CUR_ID      VARCHAR2(15),
TRANSACTION_AMT_MAIN_CUR_ID VARCHAR2(15),
BASE_CUR_ID                 VARCHAR2(15),
BASE_CUR_CODE                 VARCHAR2(15),
BASE_PRICE_UNIT_ID          VARCHAR2(15),
BASE_PRICE_UNIT_ID_IN_PPU          VARCHAR2(15),
PRICE_QTY_UNIT_ID           VARCHAR2(15),
PRICE_WEIGHT                NUMBER,
PRICE_TO_STOCK_WT_CONVERSION NUMBER,
VALUE_IN_TRANSACT_CURRENCY   NUMBER(25,5),
TRANSACT_TO_BASE_FW_EXCH_RATE NUMBER,
TRANS_TO_BASE_FW_EXCH_RATE  VARCHAR2(25),
STOCK_TO_BASE_WT_CONVERSION NUMBER,
VALUE_IN_BASE_CURRENCY      NUMBER(25,5),
AVG_COST                    NUMBER);

CREATE TABLE TINVS_TEMP_INVM_COGS (
CORPORATE_ID                  VARCHAR2(15),
PROCESS_ID                  VARCHAR2(15),
SALES_INTERNAL_GMR_REF_NO   VARCHAR2(15),
INTERNAL_COST_ID            VARCHAR2(15),
COST_TYPE                   VARCHAR2(25),
INTERNAL_GRD_REF_NO         VARCHAR2(15),
PRODUCT_ID VARCHAR2(15),
BASE_QTY_UNIT_ID VARCHAR2(15),
BASE_QTY_UNIT VARCHAR2(15),
GRD_CURRENT_QTY             NUMBER,
GRD_QTY_UNIT_ID             VARCHAR2(15),
COST_VALUE                  NUMBER,
TRANSFORMATION_RATIO        NUMBER,
TRANSACTION_PRICE_UNIT_ID   VARCHAR2(15),
TRANSACTION_CUR_FACTOR      NUMBER,
TRANSACTION_AMT_CUR_ID      VARCHAR2(15),
TRANSACTION_AMT_MAIN_CUR_ID VARCHAR2(15),
BASE_CUR_ID                 VARCHAR2(15),
BASE_CUR_CODE                 VARCHAR2(15),
BASE_PRICE_UNIT_ID          VARCHAR2(15),
BASE_PRICE_UNIT_ID_IN_PPU          VARCHAR2(15),
PRICE_QTY_UNIT_ID           VARCHAR2(15),
PRICE_WEIGHT                NUMBER,
PRICE_TO_STOCK_WT_CONVERSION NUMBER,
VALUE_IN_TRANSACT_CURRENCY   NUMBER(25,5),
TRANSACT_TO_BASE_FW_EXCH_RATE NUMBER,
TRANS_TO_BASE_FW_EXCH_RATE  VARCHAR2(25),
STOCK_TO_BASE_WT_CONVERSION NUMBER,
VALUE_IN_BASE_CURRENCY      NUMBER(25,5),
AVG_COST                    NUMBER);

CREATE TABLE INVM_COG(
PROCESS_ID VARCHAR2(15),
INTERNAL_GRD_REF_NO VARCHAR2(15),
MATERIAL_COST_PER_UNIT NUMBER (20,8),
SECONDARY_COST_PER_UNIT NUMBER (20,8),
PRODUCT_PREMIUM_PER_UNIT NUMBER (20,8),
QUALITY_PREMIUM_PER_UNIT NUMBER (20,8),
PRICE_TO_BASE_FW_EXCH_RATE_ACT NUMBER(20,10),    
PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(25),    
CONTRACT_QP_FW_EXCH_RATE  VARCHAR2(25),        
CONTRACT_PP_FW_EXCH_RATE  VARCHAR2(25),        
ACCRUAL_TO_BASE_FW_EXCH_RATE  VARCHAR2(50),
PRICE_UNIT_ID VARCHAR2(15),
PRICE_UNIT_CUR_ID VARCHAR2(15),
PRICE_UNIT_CUR_CODE VARCHAR2(30),
PRICE_UNIT_WEIGHT_UNIT_ID VARCHAR2(15),
PRICE_UNIT_WEIGHT_UNIT VARCHAR2(15),
PRICE_UNIT_WEIGHT NUMBER);
		
CREATE TABLE INVM_COGS(
PROCESS_ID VARCHAR2(15),
SALES_INTERNAL_GMR_REF_NO   VARCHAR2(15),
INTERNAL_GRD_REF_NO VARCHAR2(15),
MATERIAL_COST_PER_UNIT NUMBER (20,8),
SECONDARY_COST_PER_UNIT NUMBER (20,8),
PRODUCT_PREMIUM_PER_UNIT NUMBER (20,8),
QUALITY_PREMIUM_PER_UNIT NUMBER (20,8),
PRICE_TO_BASE_FW_EXCH_RATE_ACT NUMBER(20,10),
PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(25),    
CONTRACT_QP_FW_EXCH_RATE  VARCHAR2(25),        
CONTRACT_PP_FW_EXCH_RATE  VARCHAR2(25),        
ACCRUAL_TO_BASE_FW_EXCH_RATE  VARCHAR2(50),
PRICE_UNIT_ID VARCHAR2(15),
PRICE_UNIT_CUR_ID VARCHAR2(15),
PRICE_UNIT_CUR_CODE VARCHAR2(30),
PRICE_UNIT_WEIGHT_UNIT_ID VARCHAR2(15),
PRICE_UNIT_WEIGHT_UNIT VARCHAR2(15),
PRICE_UNIT_WEIGHT NUMBER);

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD( LATEST_INTERNAL_INVOICE_REF_NO VARCHAR2(15));
ALTER TABLE RGMRD_REALIZED_GMR_DETAIL ADD ( LATEST_INTERNAL_INVOICE_REF_NO VARCHAR2(15));

ALTER TABLE PRD_PHYSICAL_REALIZED_DAILY ADD
(P_PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(25),
P_CONTRACT_QP_FW_EXCH_RATE VARCHAR2(25),
P_CONTRACT_PP_FW_EXCH_RATE VARCHAR2(25),
P_ACCRUAL_TO_BASE_FW_EXCH_RATE VARCHAR2(50));

ALTER TABLE RGMR_REALIZED_GMR DROP COLUMN IS_MC_CHANGE_FOR_PURCHASE;
ALTER TABLE TRGMR_TEMP_RGMR DROP COLUMN IS_MC_CHANGE_FOR_PURCHASE;

CREATE TABLE PA_PURCHASE_ACCURAL
(
  CORPORATE_ID             VARCHAR2(15),
  PROCESS_ID               VARCHAR2(15),
  PRODUCT_ID               VARCHAR2(15),
  PRODUCT_TYPE             VARCHAR2(20),
  CONTRACT_TYPE            VARCHAR2(30),
  CP_ID                    VARCHAR2(15),
  COUNTERPARTY_NAME        VARCHAR2(20),
  GMR_REF_NO               VARCHAR2(20),
  INTERNAL_GMR_REF_NO      VARCHAR2(20),
  INTERNAL_GRD_REF_NO      VARCHAR2(20),
  ELEMENT_ID               VARCHAR2(15),
  ELEMENT_NAME             VARCHAR2(15),
  PAYABLE_RETURNABLE_TYPE  VARCHAR2(15),
  ASSAY_CONTENT            NUMBER(25,10),
  ASSAY_CONTENT_UNIT       VARCHAR2(15),
  PAYABLE_QTY              NUMBER(25,10),
  PAYABLE_QTY_UNIT_ID      VARCHAR2(15),
  PRICE                    NUMBER(25,10),
  PRICE_UNIT_ID            VARCHAR2(20),
  PRICE_UNIT_CUR_ID        VARCHAR2(15),
  PRICE_UNIT_CUR_CODE      VARCHAR2(15),
  PAY_IN_CUR_ID            VARCHAR2(15),
  PAY_IN_CUR_CODE          VARCHAR2(15),
  PAYABLE_AMT_PRICE_CCY    NUMBER(38,18),
  PAYABLE_AMT_PAY_CCY      NUMBER(38,18),
  FX_RATE_PRICE_TO_PAY     NUMBER(38,18),
  TCHARGES_AMOUNT          NUMBER(38,18),
  RCHARGES_AMOUNT          NUMBER(38,18),
  PENALTY_AMOUNT           NUMBER(38,18),
  FRIGHTCHARGES_AMOUNT     NUMBER(38,18),
  OTHERCHARGES_AMOUNT      NUMBER(38,18)
);


CREATE TABLE PA_PURCHASE_ACCURAL_GMR
(
  CORPORATE_ID             VARCHAR2(15),
  PROCESS_ID               VARCHAR2(15),
  EOD_TRADE_DATE           DATE,
  PRODUCT_ID               VARCHAR2(15),
  PRODUCT_TYPE             VARCHAR2(20),
  CONTRACT_TYPE            VARCHAR2(30),
  CP_ID                    VARCHAR2(15),
  COUNTERPARTY_NAME        VARCHAR2(20),
  GMR_REF_NO               VARCHAR2(20),
  ELEMENT_ID               VARCHAR2(15),
  ELEMENT_NAME             VARCHAR2(15),
  PAYABLE_RETURNABLE_TYPE  VARCHAR2(15),
  ASSAY_CONTENT            NUMBER(25,10),
  ASSAY_CONTENT_UNIT       VARCHAR2(15),
  PAYABLE_QTY              NUMBER(25,10),
  PAYABLE_QTY_UNIT_ID      VARCHAR2(15),
  PRICE                    NUMBER(25,10),
  PRICE_UNIT_ID            VARCHAR2(20),
  PRICE_UNIT_CUR_ID        VARCHAR2(15),
  PRICE_UNIT_CUR_CODE      VARCHAR2(15),
  PAY_IN_CUR_ID            VARCHAR2(15),
  PAY_IN_CUR_CODE          VARCHAR2(15),
  PAYABLE_AMT_PRICE_CCY    NUMBER(38,18),
  PAYABLE_AMT_PAY_CCY      NUMBER(38,18),
  FX_RATE_PRICE_TO_PAY     NUMBER(38,18),
  TRANASCATION_TYPE        VARCHAR2(20),
  TCHARGES_AMOUNT          NUMBER(38,18),
  RCHARGES_AMOUNT          NUMBER(38,18),
  PENALTY_AMOUNT           NUMBER(38,18),
  FRIGHTCHARGES_AMOUNT     NUMBER(38,18),
  OTHERCHARGES_AMOUNT      NUMBER(38,18)
  );

alter table PSUE_ELEMENT_DETAILS add INTERNAL_GRD_DGRD_REF_NO VARCHAR2(15);

CREATE MATERIALIZED VIEW  GTH_GMR_TREATMENT_HEADER  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  GTH_GMR_TREATMENT_HEADER@eka_appdb;
CREATE MATERIALIZED VIEW  GRH_GMR_REFINING_HEADER REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  GRH_GMR_REFINING_HEADER@eka_appdb;
CREATE MATERIALIZED VIEW  GPH_GMR_PENALTY_HEADER  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  GPH_GMR_PENALTY_HEADER@eka_appdb;
CREATE MATERIALIZED VIEW  SAC_STOCK_ASSAY_CONTENT  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  SAC_STOCK_ASSAY_CONTENT@eka_appdb;
CREATE MATERIALIZED VIEW  IIED_INV_ITEM_ELEMENT_DETAILS  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  IIED_INV_ITEM_ELEMENT_DETAILS@eka_appdb;
CREATE MATERIALIZED VIEW  INTC_INV_TREATMENT_CHARGES REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  INTC_INV_TREATMENT_CHARGES@eka_appdb;
CREATE MATERIALIZED VIEW  INRC_INV_REFINING_CHARGES  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  INRC_INV_REFINING_CHARGES@eka_appdb;
CREATE MATERIALIZED VIEW  IEPD_INV_EPENALTY_DETAILS  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  IEPD_INV_EPENALTY_DETAILS@eka_appdb;
CREATE MATERIALIZED VIEW  IAM_INVOICE_ASSAY_MAPPING  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  IAM_INVOICE_ASSAY_MAPPING@eka_appdb;
CREATE MATERIALIZED VIEW  IAM_INVOICE_ACTION_MAPPING  REFRESH FAST ON DEMAND WITH PRIMARY KEY AS  SELECT * FROM  IAM_INVOICE_ACTION_MAPPING@eka_appdb;

