ALTER TABLE PRCE_PHY_REALIZED_CONC_ELEMENT  ADD(
P_PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(25));

ALTER TABLE PRCH_PHY_REALIZED_CONC_HEADER ADD(
P_PRICE_TO_BASE_FW_EXCH_RATE VARCHAR2(100), 
P_TC_TO_BASE_FW_EXCH_RATE  VARCHAR2(50), 
P_RC_TO_BASE_FW_EXCH_RATE  VARCHAR2(50),
P_PC_TO_BASE_FW_EXCH_RATE  VARCHAR2(50),
P_ACCRUAL_TO_BASE_FW_EXCH_RATE  VARCHAR2(50));
