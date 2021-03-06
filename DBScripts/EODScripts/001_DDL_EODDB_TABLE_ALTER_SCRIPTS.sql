alter table PCAD_PC_AGENCY_DETAIL modify  COMMISSION_VALUE NUMBER(25,10);
alter table PCBPD_PC_BASE_PRICE_DETAIL modify  QTY_TO_BE_PRICED NUMBER(25,10);
alter table PCDB_PC_DELIVERY_BASIS modify  PREMIUM NUMBER(25,10);
alter table PCDI_PC_DELIVERY_ITEM modify  QTY_MIN_VAL NUMBER(25,10);
alter table PCDI_PC_DELIVERY_ITEM modify  QTY_MAX_VAL NUMBER(25,10);
alter table PCDI_PC_DELIVERY_ITEM modify  MIN_TOLERANCE NUMBER(25,10);
alter table PCDI_PC_DELIVERY_ITEM modify  MAX_TOLERANCE NUMBER(25,10);
alter table PCJV_PC_JV_DETAIL modify  PROFIT_SHARE_PERCENTAGE NUMBER(25,10);
alter table PCJV_PC_JV_DETAIL modify  LOSS_SHARE_PERCENTAGE NUMBER(25,10);
alter table PCM_PHYSICAL_CONTRACT_MAIN modify  WEIGHT_ALLOWANCE NUMBER(25,10);
alter table PCM_PHYSICAL_CONTRACT_MAIN modify  PROVISIONAL_PYMT_PCTG NUMBER(25,10);
alter table PCPD_PC_PRODUCT_DEFINITION modify  QTY_MIN_VAL NUMBER(25,10);
alter table PCPD_PC_PRODUCT_DEFINITION modify  QTY_MAX_VAL NUMBER(25,10);
alter table PCPD_PC_PRODUCT_DEFINITION modify  MIN_TOLERANCE NUMBER(25,10);
alter table PCPD_PC_PRODUCT_DEFINITION modify  MAX_TOLERANCE NUMBER(25,10);
alter table PCPQ_PC_PRODUCT_QUALITY modify  QTY_MIN_VAL NUMBER(25,10);
alter table PCPQ_PC_PRODUCT_QUALITY modify  QTY_MAX_VAL NUMBER(25,10);
alter table PCQPD_PC_QUAL_PREMIUM_DISCOUNT modify  PREMIUM_DISC_VALUE NUMBER(25,10);
alter table PFFXD_PHY_FORMULA_FX_DETAILS modify  FIXED_FX_RATE NUMBER(25,10);
alter table PCI_PHYSICAL_CONTRACT_ITEM modify ITEM_QTY  NUMBER(25,10);
alter table PCADUL_PC_AGENCY_DETAIL_UL modify  COMMISSION_VALUE VARCHAR2(30);
alter table PCBPDUL_PC_BASE_PRICE_DTL_UL modify  QTY_TO_BE_PRICED VARCHAR2(30);
alter table PCDBUL_PC_DELIVERY_BASIS_UL modify  PREMIUM VARCHAR2(30);
alter table PCDIUL_PC_DELIVERY_ITEM_UL modify  QTY_MIN_VAL VARCHAR2(30);
alter table PCDIUL_PC_DELIVERY_ITEM_UL modify  QTY_MAX_VAL VARCHAR2(30);
alter table PCDIUL_PC_DELIVERY_ITEM_UL modify  MIN_TOLERANCE VARCHAR2(30);
alter table PCDIUL_PC_DELIVERY_ITEM_UL modify  MAX_TOLERANCE VARCHAR2(30);
alter table PCJVUL_PC_JV_DETAIL_UL modify  PROFIT_SHARE_PERCENTAGE VARCHAR2(30);
alter table PCJVUL_PC_JV_DETAIL_UL modify  LOSS_SHARE_PERCENTAGE VARCHAR2(30);
alter table PCMUL_PHY_CONTRACT_MAIN_UL modify  WEIGHT_ALLOWANCE VARCHAR2(30);
alter table PCMUL_PHY_CONTRACT_MAIN_UL modify  PROVISIONAL_PYMT_PCTG VARCHAR2(30);
alter table PCPDUL_PC_PRODUCT_DEFINTN_UL modify  QTY_MIN_VAL VARCHAR2(30);
alter table PCPDUL_PC_PRODUCT_DEFINTN_UL modify  QTY_MAX_VAL VARCHAR2(30);
alter table PCPDUL_PC_PRODUCT_DEFINTN_UL modify  MIN_TOLERANCE VARCHAR2(30);
alter table PCPDUL_PC_PRODUCT_DEFINTN_UL modify  MAX_TOLERANCE VARCHAR2(30);
alter table PCPQUL_PC_PRODUCT_QUALITY_UL modify  QTY_MIN_VAL VARCHAR2(30);
alter table PCPQUL_PC_PRODUCT_QUALITY_UL modify  QTY_MAX_VAL VARCHAR2(30);
alter table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify  PREMIUM_DISC_VALUE VARCHAR2(30);
alter table PFFXDUL_PHY_FORMULA_FX_DTL_UL modify  FIXED_FX_RATE VARCHAR2(30);
alter table PCIUL_PHY_CONTRACT_ITEM_UL modify ITEM_QTY  VARCHAR2(30);
alter table PCM_PHYSICAL_CONTRACT_MAIN add IS_TOLLING_CONTRACT char(1) default 'N';
alter table PCMUL_PHY_CONTRACT_MAIN_UL add is_tolling_contract char(1) default 'N';