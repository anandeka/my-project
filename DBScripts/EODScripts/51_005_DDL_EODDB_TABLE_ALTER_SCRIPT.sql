ALTER TABLE PRCE_PHY_REALIZED_CONC_ELEMENT ADD
(
TC_IN_BASE_CUR NUMBER(25,10),
RC_IN_BASE_CUR NUMBER(25,10),
TC_TO_BASE_FW_EXCH_RATE VARCHAR2(50),
RC_TO_BASE_FW_EXCH_RATE VARCHAR2(50),
PREV_TC_IN_BASE_CUR NUMBER(25,10),
PREV_RC_IN_BASE_CUR NUMBER(25,10),
PREV_TC_TO_BASE_FW_EXCH_RATE VARCHAR2(50),
PREV_RC_TO_BASE_FW_EXCH_RATE VARCHAR2(50));
