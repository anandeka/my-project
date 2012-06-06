DROP TABLE POFHD_POFH_DAILY CASCADE CONSTRAINTS;

CREATE TABLE POFHD_POFH_DAILY
(
  POFH_ID                     VARCHAR2(15 CHAR),
  POCD_ID                     VARCHAR2(15 CHAR),
  INTERNAL_GMR_REF_NO         VARCHAR2(15 CHAR),
  QP_START_DATE               DATE,
  QP_END_DATE                 DATE,
  PRICED_DATE                 DATE,
  QTY_TO_BE_FIXED             NUMBER(25,10),
  PRICED_QTY                  NUMBER(25,10),
  NO_OF_PROMPT_DAYS           NUMBER(25,10),
  PER_DAY_PRICING_QTY         NUMBER(25,10),
  FINAL_PRICE                 NUMBER(25,10),
  FINALIZE_DATE               DATE,
  VERSION                     NUMBER(10),
  IS_ACTIVE                   CHAR(1 CHAR),
  AVG_PRICE_IN_PRICE_IN_CUR   NUMBER(25,10),
  AVG_FX                      NUMBER(25,10),
  NO_OF_PROMPT_DAYS_FIXED     NUMBER(25,10)     DEFAULT 0,
  EVENT_NAME                  VARCHAR2(50 CHAR),
  DELTA_PRICED_QTY            NUMBER(25,10),
  FINAL_PRICE_IN_PRICING_CUR  NUMBER(25,10)
);
/