ALTER TABLE CSUL_COST_STORE_UL ADD(
ACC_DIRECT_ACTUAL               VARCHAR2(20),
ACC_ORIGINAL_ACCRUAL            VARCHAR2(20),
ACC_OVER_ACCRUAL                VARCHAR2(20),
ACC_UNDER_ACCRUAL               VARCHAR2(20),
DELTA_COST_IN_BASE_PRICE_ID     VARCHAR2(30),
REVERSAL_TYPE                   VARCHAR2(20));

ALTER TABLE CS_COST_STORE ADD(
ACC_DIRECT_ACTUAL               VARCHAR2(20),
ACC_ORIGINAL_ACCRUAL            VARCHAR2(20),
ACC_OVER_ACCRUAL                VARCHAR2(20),
ACC_UNDER_ACCRUAL               VARCHAR2(20),
DELTA_COST_IN_BASE_PRICE_ID     VARCHAR2(30),
REVERSAL_TYPE                   VARCHAR2(20));