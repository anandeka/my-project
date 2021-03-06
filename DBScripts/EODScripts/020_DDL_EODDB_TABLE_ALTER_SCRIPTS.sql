alter table PCBPHUL_PC_BASE_PRC_HEADER_UL add IS_FREE_METAL_APPLICABLE char(1);
alter table PCBPH_PC_BASE_PRICE_HEADER add IS_FREE_METAL_APPLICABLE char(1);

alter table PCDIUL_PC_DELIVERY_ITEM_UL add ITEM_PRICE_TYPE VARCHAR2(30);
alter table PCDIUL_PC_DELIVERY_ITEM_UL add ITEM_PRICE VARCHAR2(30);
alter table PCDIUL_PC_DELIVERY_ITEM_UL add ITEM_PRICE_UNIT VARCHAR2(30);
alter table PCDIUL_PC_DELIVERY_ITEM_UL add  QTY_DECLARATION_DATE VARCHAR2(15);
alter table PCDIUL_PC_DELIVERY_ITEM_UL add  QUALITY_DECLARATION_DATE VARCHAR2(15);
alter table PCDIUL_PC_DELIVERY_ITEM_UL add  INCO_LOCATION_DECLARATION_DATE VARCHAR2(15);

alter table PCDI_PC_DELIVERY_ITEM add ITEM_PRICE_TYPE VARCHAR2(30);
alter table PCDI_PC_DELIVERY_ITEM add ITEM_PRICE VARCHAR2(30);
alter table PCDI_PC_DELIVERY_ITEM add ITEM_PRICE_UNIT VARCHAR2(30);
alter table PCDI_PC_DELIVERY_ITEM add  QTY_DECLARATION_DATE VARCHAR2(15);
alter table PCDI_PC_DELIVERY_ITEM add  QUALITY_DECLARATION_DATE VARCHAR2(15);
alter table PCDI_PC_DELIVERY_ITEM add  INCO_LOCATION_DECLARATION_DATE VARCHAR2(15);



alter table PCIUL_PHY_CONTRACT_ITEM_UL add EXPECTED_QP_START_DATE VARCHAR2(30);
alter table PCIUL_PHY_CONTRACT_ITEM_UL add EXPECTED_QP_END_DATE  VARCHAR2(30);
alter table PCI_PHYSICAL_CONTRACT_ITEM add EXPECTED_QP_START_DATE DATE;
alter table PCI_PHYSICAL_CONTRACT_ITEM add EXPECTED_QP_END_DATE  DATE;


alter table PCMUL_PHY_CONTRACT_MAIN_UL add APPROVAL_STATUS VARCHAR2(60);
alter table PCMUL_PHY_CONTRACT_MAIN_UL add CP_ADDRESS_ID VARCHAR2(15);
alter table PCMUL_PHY_CONTRACT_MAIN_UL add IS_LOT_LEVEL_INVOICE CHAR(1);

alter table PCM_PHYSICAL_CONTRACT_MAIN add APPROVAL_STATUS VARCHAR2(60);
alter table PCM_PHYSICAL_CONTRACT_MAIN add CP_ADDRESS_ID VARCHAR2(15);
alter table PCM_PHYSICAL_CONTRACT_MAIN add IS_LOT_LEVEL_INVOICE CHAR(1);
alter  table PCM_PHYSICAL_CONTRACT_MAIN add IS_TOLLING_EXTN Char(1) default 'N';


alter table PCPDUL_PC_PRODUCT_DEFINTN_UL add INPUT_OUTPUT VARCHAR2(15);
alter table PCPD_PC_PRODUCT_DEFINITION add INPUT_OUTPUT VARCHAR2(15);


alter table PCPDQDUL_PD_QUALITY_DTL_UL add QUALITY_NAME VARCHAR2(30);
alter table PCPDQD_PD_QUALITY_DETAILS add QUALITY_NAME VARCHAR2(30);

alter table PFQPPUL_PHY_FORMULA_QP_PRC_UL add IS_SPOT_PRICING CHAR(1);
alter table PFQPP_PHY_FORMULA_QP_PRICING add IS_SPOT_PRICING CHAR(1);


alter table PQDUL_PAYABLE_QUALITY_DTL_UL add QUALITY_NAME VARCHAR2 (30);
alter table PQD_PAYABLE_QUALITY_DETAILS add QUALITY_NAME VARCHAR2 (30);

alter table TEDUL_TREATMENT_ELEMENT_DTL_UL add ELEMENT_NAME VARCHAR2 (30);
alter table TED_TREATMENT_ELEMENT_DETAILS add ELEMENT_NAME VARCHAR2 (30);

alter table TQDUL_TREATMENT_QUALITY_DTL_UL add QUALITY_NAME VARCHAR2 (30);
alter table TQD_TREATMENT_QUALITY_DETAILS add QUALITY_NAME VARCHAR2 (30);

alter table PCARUL_ASSAYING_RULES_UL add QUALITY_ID VARCHAR2 (30);
alter table PCARUL_ASSAYING_RULES_UL add ELEMENT_NAME VARCHAR2 (30);
alter table PCAR_PC_ASSAYING_RULES add QUALITY_ID VARCHAR2 (30);
alter table PCAR_PC_ASSAYING_RULES add ELEMENT_NAME VARCHAR2 (30);

alter table ARQDUL_ASSAY_QUALITY_DTL_UL add QUALITY_NAME VARCHAR2 (30);
alter table ARQD_ASSAY_QUALITY_DETAILS add QUALITY_NAME VARCHAR2 (30);

alter table RQDUL_REFINING_QUALITY_DTL_UL add QUALITY_NAME VARCHAR2 (30);
alter table RQD_REFINING_QUALITY_DETAILS add QUALITY_NAME VARCHAR2 (30);

alter table REDUL_REFINING_ELEMENT_DTL_UL add ELEMENT_NAME VARCHAR2 (30);
alter table RED_REFINING_ELEMENT_DETAILS add ELEMENT_NAME VARCHAR2 (30);

alter table CIPQ_CONTRACT_ITEM_PAYABLE_QTY add QTY_TYPE VARCHAR2(30);
alter table CIPQ_CONTRACT_ITEM_PAYABLE_QTY  add INTERNAL_ACTION_REF_NO VARCHAR2(30);
alter table CIPQL_CTRT_ITM_PAYABLE_QTY_LOG add QTY_TYPE VARCHAR2(30);

alter table DIPQ_DELIVERY_ITEM_PAYABLE_QTY add QTY_TYPE VARCHAR2(30);
alter table DIPQ_DELIVERY_ITEM_PAYABLE_QTY add INTERNAL_ACTION_REF_NO VARCHAR2(30);
alter table DIPQL_DEL_ITM_PAYBLE_QTY_LOG add QTY_TYPE VARCHAR2(30);

alter table SPQ_STOCK_PAYABLE_QTY add QTY_TYPE VARCHAR2(10);
alter table SPQ_STOCK_PAYABLE_QTY add ACTIVITY_ACTION_ID VARCHAR2(30);
alter table SPQ_STOCK_PAYABLE_QTY add IS_STOCK_SPLIT CHAR(1);
alter table SPQ_STOCK_PAYABLE_QTY add SUPPLIER_ID VARCHAR2(20);
alter table SPQ_STOCK_PAYABLE_QTY add SMELTER_ID VARCHAR2(20);
alter table SPQ_STOCK_PAYABLE_QTY add IN_PROCESS_STOCK_ID VARCHAR2(20);
alter table SPQ_STOCK_PAYABLE_QTY add FREE_METAL_STOCK_ID VARCHAR2(20);
alter table SPQ_STOCK_PAYABLE_QTY add FREE_METAL_QTY NUMBER(25,10);
alter table SPQ_STOCK_PAYABLE_QTY add INTERNAL_ACTION_REF_NO VARCHAR2(30);  
alter table SPQL_STOCK_PAYABLE_QTY_LOG add QTY_TYPE VARCHAR2(10);
alter table SPQL_STOCK_PAYABLE_QTY_LOG add ACTIVITY_ACTION_ID VARCHAR2(30);
alter table SPQL_STOCK_PAYABLE_QTY_LOG add IS_STOCK_SPLIT CHAR(1);
alter table SPQL_STOCK_PAYABLE_QTY_LOG add SUPPLIER_ID VARCHAR2(20);
alter table SPQL_STOCK_PAYABLE_QTY_LOG add SMELTER_ID VARCHAR2(20);
alter table SPQL_STOCK_PAYABLE_QTY_LOG add IN_PROCESS_STOCK_ID VARCHAR2(20);
alter table SPQL_STOCK_PAYABLE_QTY_LOG add FREE_METAL_STOCK_ID VARCHAR2(20);
alter table SPQL_STOCK_PAYABLE_QTY_LOG add FREE_METAL_QTY NUMBER(25,10);


alter table DGRD_DELIVERED_GRD add PROFIT_CENTER_ID VARCHAR2(15);
alter table DGRD_DELIVERED_GRD add STRATEGY_ID VARCHAR2(15);
alter table DGRD_DELIVERED_GRD add IS_WARRANT CHAR(1);
alter table DGRD_DELIVERED_GRD add WARRANT_NO VARCHAR2(15);
alter table DGRDUL_DELIVERED_GRD_UL add PROFIT_CENTER_ID VARCHAR2(15);
alter table DGRDUL_DELIVERED_GRD_UL add STRATEGY_ID VARCHAR2(15);
alter table DGRDUL_DELIVERED_GRD_UL add IS_WARRANT CHAR(1);
alter table DGRDUL_DELIVERED_GRD_UL add WARRANT_NO VARCHAR2(15);


alter table GMR_GOODS_MOVEMENT_RECORD add TOLLING_QTY NUMBER(20,5);
alter table GMR_GOODS_MOVEMENT_RECORD add TOLLING_GMR_TYPE VARCHAR2(30);
alter table GMR_GOODS_MOVEMENT_RECORD add POOL_ID VARCHAR2(15);
alter table GMR_GOODS_MOVEMENT_RECORD add IS_WARRANT CHAR(1);
alter table GMR_GOODS_MOVEMENT_RECORD add IS_PASS_THROUGH CHAR(1);
alter table GMR_GOODS_MOVEMENT_RECORD add PLEDGE_INPUT_GMR VARCHAR2(15);
alter table GMR_GOODS_MOVEMENT_RECORD add IS_APPLY_FREIGHT_ALLOWANCE CHAR(1);

alter table GMRUL_GMR_UL add TOLLING_QTY NUMBER(20,5);
alter table GMRUL_GMR_UL add TOLLING_GMR_TYPE VARCHAR2(30);
alter table GMRUL_GMR_UL add POOL_ID VARCHAR2(15);
alter table GMRUL_GMR_UL add IS_WARRANT CHAR(1);
alter table GMRUL_GMR_UL add IS_PASS_THROUGH CHAR(1);
alter table GMRUL_GMR_UL add PLEDGE_INPUT_GMR VARCHAR2(15);
alter table GMRUL_GMR_UL add IS_APPLY_FREIGHT_ALLOWANCE CHAR(1);


alter table TMPC_TEMP_M2M_PRE_CHECK add IS_TOLLING_CONTRACT Char(1);
alter table TMPC_TEMP_M2M_PRE_CHECK add IS_TOLLING_EXTN Char(1);
alter table MD_M2M_DAILY add IS_TOLLING_CONTRACT Char(1);
alter table MD_M2M_DAILY add IS_TOLLING_EXTN Char(1);


CREATE TABLE DIPCH_DI_PAYABLECONTENT_HEADER
(
  DIPCH_ID   VARCHAR2(15),
  PCDI_ID    VARCHAR2(15),
  PCPCH_ID   VARCHAR2(15),
  VERSION    NUMBER(10),
  IS_ACTIVE  CHAR(1),
  DBD_ID     VARCHAR2(15),
  PROCESS_ID VARCHAR2(15)
  );


CREATE TABLE DIPCHUL_DI_PAYBLECON_HEADER_UL
(
  DIPCHUL_ID              VARCHAR2(15),
  INTERNAL_ACTION_REF_NO  VARCHAR2(15),
  ENTRY_TYPE              VARCHAR2(30),
  DIPCH_ID                VARCHAR2(15),
  PCDI_ID                 VARCHAR2(15),
  PCPCH_ID                VARCHAR2(15),
  VERSION                 NUMBER(10),
  IS_ACTIVE               CHAR(1 CHAR),
  DBD_ID                  VARCHAR2(15)
   );

alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL add PAYABLE_TYPE varchar2(15);
alter table PCPCH_PC_PAYBLE_CONTENT_HEADER add PAYABLE_TYPE varchar2(15);