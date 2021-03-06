
DROP TABLE DIM_MONTH CASCADE CONSTRAINTS
/

CREATE TABLE DIM_MONTH
(
  MNTH_DESC     VARCHAR2(2000 BYTE),
  MNTH_ID       VARCHAR2(2000 BYTE),
  MNTH_NM       VARCHAR2(2000 BYTE),
  QUARTER_DESC  VARCHAR2(2000 BYTE),
  YEAR_ID       VARCHAR2(2000 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/


DROP TABLE DIM_TIME CASCADE CONSTRAINTS
/

CREATE TABLE DIM_TIME
(
  DATE_ID       VARCHAR2(10 BYTE)               NOT NULL,
  MNTH_ID       VARCHAR2(2000 BYTE),
  MNTH_NM       VARCHAR2(2000 BYTE),
  QUARTER_DESC  VARCHAR2(20 BYTE),
  YEAR          VARCHAR2(4 BYTE)
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING
/



ALTER TABLE DIM_MONTH ADD (
  CONSTRAINT DIM_MONTH_PK
 PRIMARY KEY
 (MNTH_DESC))
/

ALTER TABLE DIM_TIME ADD (
  CONSTRAINT DIM_TIME_PK
 PRIMARY KEY
 (DATE_ID))
/

