DROP TABLE INVM_COG;
CREATE TABLE INVM_COG
(
  PROCESS_ID                      VARCHAR2(15 BYTE),
  INTERNAL_GRD_REF_NO             VARCHAR2(15 BYTE),
  MATERIAL_COST_PER_UNIT          NUMBER(20,8),
  SECONDARY_COST_PER_UNIT         NUMBER(20,8),
  PRODUCT_PREMIUM_PER_UNIT        NUMBER(20,8),
  QUALITY_PREMIUM_PER_UNIT        NUMBER(20,8),
  TC_CHARGES_PER_UNIT             NUMBER(20,8),
  RC_CHARGES_PER_UNIT             NUMBER(20,8),
  PC_CHARGES_PER_UNIT             NUMBER(20,8),
  TOTAL_MC_CHARGES                NUMBER(20,8),
  TOTAL_TC_CHARGES                NUMBER(20,8),
  TOTAL_RC_CHARGES                NUMBER(20,8),
  TOTAL_PC_CHARGES                NUMBER(20,8),
  TOTAL_SC_CHARGES                NUMBER(20,8),
  PRICE_TO_BASE_FW_EXCH_RATE_ACT  NUMBER(20,10),
  PRICE_TO_BASE_FW_EXCH_RATE      VARCHAR2(25 BYTE),
  CONTRACT_QP_FW_EXCH_RATE        VARCHAR2(25 BYTE),
  CONTRACT_PP_FW_EXCH_RATE        VARCHAR2(25 BYTE),
  TC_TO_BASE_FW_EXCH_RATE         VARCHAR2(25 BYTE),
  RC_TO_BASE_FW_EXCH_RATE         VARCHAR2(25 BYTE),
  PC_TO_BASE_FW_EXCH_RATE         VARCHAR2(25 BYTE),
  ACCRUAL_TO_BASE_FW_EXCH_RATE    VARCHAR2(50 BYTE),
  PRICE_UNIT_ID                   VARCHAR2(15 BYTE),
  PRICE_UNIT_CUR_ID               VARCHAR2(15 BYTE),
  PRICE_UNIT_CUR_CODE             VARCHAR2(30 BYTE),
  PRICE_UNIT_WEIGHT_UNIT_ID       VARCHAR2(15 BYTE),
  PRICE_UNIT_WEIGHT_UNIT          VARCHAR2(15 BYTE),
  PRICE_UNIT_WEIGHT               NUMBER);
  DROP  TABLE INVM_COGS;
  CREATE TABLE INVM_COGS
( PROCESS_ID                      VARCHAR2(15 BYTE),
  SALES_INTERNAL_GMR_REF_NO       VARCHAR2(15 BYTE),
  INTERNAL_GRD_REF_NO             VARCHAR2(15 BYTE),
  MATERIAL_COST_PER_UNIT          NUMBER(20,8),
  SECONDARY_COST_PER_UNIT         NUMBER(20,8),
  PRODUCT_PREMIUM_PER_UNIT        NUMBER(20,8),
  QUALITY_PREMIUM_PER_UNIT        NUMBER(20,8),
  TC_CHARGES_PER_UNIT             NUMBER(20,8),
  RC_CHARGES_PER_UNIT             NUMBER(20,8),
  PC_CHARGES_PER_UNIT             NUMBER(20,8),
  TOTAL_MC_CHARGES                NUMBER(20,8),
  TOTAL_TC_CHARGES                NUMBER(20,8),
  TOTAL_RC_CHARGES                NUMBER(20,8),
  TOTAL_PC_CHARGES                NUMBER(20,8),
  TOTAL_SC_CHARGES                NUMBER(20,8),
  PRICE_TO_BASE_FW_EXCH_RATE_ACT  NUMBER(20,10),
  PRICE_TO_BASE_FW_EXCH_RATE      VARCHAR2(25 BYTE),
  CONTRACT_QP_FW_EXCH_RATE        VARCHAR2(25 BYTE),
  CONTRACT_PP_FW_EXCH_RATE        VARCHAR2(25 BYTE),
  TC_TO_BASE_FW_EXCH_RATE         VARCHAR2(25 BYTE),
  RC_TO_BASE_FW_EXCH_RATE         VARCHAR2(25 BYTE),
  PC_TO_BASE_FW_EXCH_RATE         VARCHAR2(25 BYTE),
  ACCRUAL_TO_BASE_FW_EXCH_RATE    VARCHAR2(50 BYTE),
  PRICE_UNIT_ID                   VARCHAR2(15 BYTE),
  PRICE_UNIT_CUR_ID               VARCHAR2(15 BYTE),
  PRICE_UNIT_CUR_CODE             VARCHAR2(30 BYTE),
  PRICE_UNIT_WEIGHT_UNIT_ID       VARCHAR2(15 BYTE),
  PRICE_UNIT_WEIGHT_UNIT          VARCHAR2(15 BYTE),
  PRICE_UNIT_WEIGHT               NUMBER);

CREATE TABLE ECS_ELEMENT_COST_STORE
(
  ELEMENT_COST_ID                 VARCHAR2(15),
  INTERNAL_COST_ID                VARCHAR2(15) NOT NULL,
  ELEMENT_ID                      VARCHAR2(15) NOT NULL,
  PAYABLE_QTY                     NUMBER(25,10),
  PAYABLE_QTY_IN_BASE_QTY_UNIT    NUMBER(25,10),
  QTY_UNIT_ID                     VARCHAR2(15),
  COST_VALUE                      NUMBER(25,10),
  RATE_PRICE_UNIT_ID              VARCHAR2(15),
  TRANSACTION_AMT                 NUMBER(25,10),
  TRANSACTION_AMT_CUR_ID          VARCHAR2(15),
  FX_TO_BASE                      NUMBER(25,10),
  BASE_AMT                        NUMBER(25,10),
  BASE_AMT_CUR_ID                 VARCHAR2(15),
  COST_IN_BASE_PRICE_UNIT_ID      NUMBER(25,10),
  COST_IN_TRANSACT_PRICE_UNIT_ID  NUMBER(25,10),
  VERSION                         NUMBER(10),
  IS_DELETED                      CHAR(1),
  TRANSACTION_PRICE_UNIT_ID       VARCHAR2(15),
  DBD_ID                          VARCHAR2(15),
  PROCESS_ID                      VARCHAR2(15) );

ALTER TABLE POUE_PHY_OPEN_UNREAL_ELEMENT MODIFY UNREAL_PNL_IN_BASE_PER_UNIT NUMBER;
ALTER TABLE POUD_PHY_OPEN_UNREAL_DAILY MODIFY UNREAL_PNL_IN_BASE_PER_UNIT NUMBER;
ALTER TABLE PSU_PHY_STOCK_UNREALIZED MODIFY UNREAL_PNL_IN_BASE_PER_UNIT NUMBER;
ALTER TABLE PSUE_PHY_STOCK_UNREALIZED_ELE MODIFY PNL_IN_PER_BASE_UNIT NUMBER;

DROP MATERIALIZED VIEW PP_PRODUCT_PREMIUM;
CREATE MATERIALIZED VIEW PP_PRODUCT_PREMIUM AS SELECT * FROM PP_PRODUCT_PREMIUM@EKA_APPDB;

UPDATE EEM_EKA_EXCEPTION_MASTER EEM
SET EEM.EXCEPTION_DESC ='Product Premium not available for the Product,Month-year, Valuation Point'
where eem.exception_code ='PHY-100';

alter table SSWH_SPE_SETTLE_WASHOUT_HEADER drop(IS_CANCELLED_PROCESS_ID);
alter table SSWH_SPE_SETTLE_WASHOUT_HEADER add(CANCELLED_PROCESS_ID varchar2(15));
