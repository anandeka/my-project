alter table CIGCUL_CONTRCT_ITM_GMR_COST_UL add IS_MATERIAL_COST CHAR(1 CHAR);

alter table CSUL_COST_STORE_UL add (ACC_DIRECT_ACTUAL VARCHAR2(20 ),ACC_ORIGINAL_ACCRUAL VARCHAR2(20 ),ACC_OVER_ACCRUAL VARCHAR2(20 ),ACC_UNDER_ACCRUAL VARCHAR2(20 ),DELTA_COST_IN_BASE_PRICE_ID VARCHAR2(30 ),IS_ACTUAL_POSTED_IN_COG CHAR(1 CHAR),REVERSAL_TYPE VARCHAR2(20 ));
